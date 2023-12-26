#===============================================================================
# BerryPlantData
#===============================================================================
class BerryPlantData
    attr_accessor :event
    attr_accessor :event_base_speed
    attr_accessor :town_map_location
    attr_accessor :town_map_checking
    attr_accessor :mutated_berry_tried
    attr_accessor :mutated_berry_info
    attr_accessor :preferred_weather
    attr_accessor :exposed_to_preferred_weather
    attr_accessor :plant_zone
    attr_accessor :preferred_zone
    attr_accessor :unpreferred_zone
    attr_accessor :weeds
    attr_accessor :weeds_timer
    attr_accessor :pests
    attr_accessor :pests_timer
    attr_accessor :withered_item
    attr_accessor :persistent
    attr_accessor :watering_cans_used

    alias tdw_berry_plant_init initialize
    def initialize(event = nil)
        tdw_berry_plant_init
        tdw_new_init(event)
    end

    def tdw_new_init(event)
        @event = event || pbMapInterpreter.get_self
        @event_base_speed = @event.move_speed
        @town_map_location = nil
        @town_map_location = [$~[1].to_i,$~[2].to_i,$~[3].to_i] if @event.name[/map\((\d+),(\d+),(\d+)\)/i]
        @plant_zone = $~[1].to_s if @event.name[/berryzone\((\w+)\)$/i]
        @mutated_berry_tried = false
        @mutated_berry_info = nil
        @exposed_to_preferred_weather = false
        @preferred_zone = nil
        @unpreferred_zone = nil
        @withered_item = nil
        @persistent = nil
        @watering_cans_used = []
        if Settings::BERRY_USE_WEED_MECHANICS
            @weeds = false
            @weeds_timer = nil
        end
        if Settings::BERRY_USE_PEST_MECHANICS
            @pests = false
            @pests_timer = nil
        end
    end

    # alias tdw_berry_plant_update update
    # def update
    #     tdw_berry_plant_update
    #     @exposed_to_preferred_weather = true if pbBerryPreferredWeatherEnabled? && checkPreferredWeather
    #     return if !planted? || !@event || @mutated_berry_tried || @growth_stage < 2 || 
    #                 (Settings::ALLOW_BERRY_MUTATIONS_SWITCH_ID > 0 && !$game_switches[Settings::ALLOW_BERRY_MUTATIONS_SWITCH_ID])
    #     checkNearbyPlantsForMutation
    # end

    def update
        return update_new if Settings::BERRY_USE_NEW_UPDATE_LOGIC && @event
        return if !planted?
        time_now = pbGetTimeNow
        time_delta = time_now.to_i - @time_last_updated
        return if time_delta <= 0
        new_time_alive = @time_alive + time_delta
        # Get all growth data
        plant_data = GameData::BerryPlant.get(@berry_id)
        time_per_stage = plant_data.hours_per_stage * 3600   # In seconds
        time_per_stage += (Settings::BERRY_PREFERRED_WEATHER_TRAITS[:hours_per_stage] * 3600) if @exposed_to_preferred_weather
        time_per_stage += (Settings::BERRY_PREFERRED_ZONE_TRAITS[:hours_per_stage] * 3600) if @preferred_zone
        time_per_stage += (Settings::BERRY_UNPREFERRED_ZONE_TRAITS[:hours_per_stage] * 3600) if @unpreferred_zone
        time_per_stage += (Settings::BERRY_HAS_WEEDS_TRAITS[:hours_per_stage] * 3600) if Settings::BERRY_USE_WEED_MECHANICS && @event && @weeds
        time_per_stage += (Settings::BERRY_HAS_PESTS_TRAITS[:hours_per_stage] * 3600) if Settings::BERRY_USE_PEST_MECHANICS && @event && @pests
        time_per_stage += (getWateringCansUsedTraits(:hours_per_stage) * 3600)
        time_per_stage = 3600 if time_per_stage < 3600
        drying_per_hour = plant_data.drying_per_hour
        drying_per_hour += (Settings::BERRY_PREFERRED_WEATHER_TRAITS[:drying_per_hour]) if @exposed_to_preferred_weather
        drying_per_hour += (Settings::BERRY_PREFERRED_ZONE_TRAITS[:drying_per_hour]) if @preferred_zone
        drying_per_hour += (Settings::BERRY_UNPREFERRED_ZONE_TRAITS[:drying_per_hour]) if @unpreferred_zone
        drying_per_hour += Settings::BERRY_HAS_WEEDS_TRAITS[:drying_per_hour] if Settings::BERRY_USE_WEED_MECHANICS && @event && @weeds
        drying_per_hour += Settings::BERRY_HAS_PESTS_TRAITS[:drying_per_hour] if Settings::BERRY_USE_PEST_MECHANICS && @event && @pests
        drying_per_hour += getWateringCansUsedTraits(:drying_per_hour)
        drying_per_hour = 0 if drying_per_hour < 0
        max_replants = GameData::BerryPlant::NUMBER_OF_REPLANTS
        max_replants += (Settings::BERRY_PREFERRED_WEATHER_TRAITS[:max_replants]) if @exposed_to_preferred_weather
        max_replants += (Settings::BERRY_PREFERRED_ZONE_TRAITS[:max_replants]) if @preferred_zone
        max_replants += (Settings::BERRY_UNPREFERRED_ZONE_TRAITS[:max_replants]) if @unpreferred_zone
        max_replants = 1 if max_replants < 1
        stages_growing = GameData::BerryPlant::NUMBER_OF_GROWTH_STAGES
        stages_fully_grown = GameData::BerryPlant::NUMBER_OF_FULLY_GROWN_STAGES
        case @mulch_id
        when :GROWTHMULCH
            time_per_stage = (time_per_stage * 0.75).to_i
            drying_per_hour = (drying_per_hour * 1.5).ceil
        when :DAMPMULCH
            time_per_stage = (time_per_stage * 1.25).to_i
            drying_per_hour /= 2
        when :GOOEYMULCH
            max_replants = (max_replants * 1.5).ceil
        when :STABLEMULCH
            stages_fully_grown = (stages_fully_grown * 1.5).ceil
        when :BOOSTMULCH
            drying_per_hour = (drying_per_hour * 2).ceil
        when :AMAZEMULCH
            drying_per_hour = (drying_per_hour * 2).ceil
        end
        # Do replants
        done_replant = false
        loop do
            stages_this_life = stages_growing + stages_fully_grown - (replanted? ? 1 : 0)
            break if new_time_alive < stages_this_life * time_per_stage
            if @replant_count >= max_replants
                reset_withered
                return
            end
            replant
            done_replant = true
            new_time_alive -= stages_this_life * time_per_stage
        end
        # Weed counts
        if Settings::BERRY_USE_WEED_MECHANICS && @event && @weeds_timer && !@weeds && @growth_stage > 1
            weed_delta = time_now.to_i - @weeds_timer
            time_for_checks = Settings::BERRY_WEED_HOURS_BETWEEN_CHECKS * 3600
            rolls = (weed_delta / time_for_checks).floor
            rolls.times do 
                @weeds = true if rand(100) < getWeedGrowthChance
                @weeds_timer += time_for_checks
                break if @weeds
            end   
        end
        #Pests
        if Settings::BERRY_USE_PEST_MECHANICS && @event && @pests_timer
            if !@pests && @growth_stage > 2
                pests_delta = time_now.to_i - @pests_timer
                time_for_checks = Settings::BERRY_PEST_HOURS_BETWEEN_CHECKS * 3600
                rolls = (pests_delta / time_for_checks).floor
                rolls.times do 
                    @pests = true if rand(100) < getPestAppearChance
                    @pests_timer += time_for_checks
                    break if @pests
                end  
            end
            @event.move_speed = @pests ? 6 : @event_base_speed
            $game_map.events[@event.id].move_speed = @event.move_speed if $game_map.map_id == @event.map_id
        end
        # Update how long plant has been alive for
        old_growth_stage = @growth_stage
        @time_alive = new_time_alive
        @growth_stage = 1 + (@time_alive / time_per_stage)
        @growth_stage += 1 if replanted?   # Replants start at stage 2
        @time_last_updated = time_now.to_i
        @weeds_timer += time_per_stage if Settings::BERRY_USE_WEED_MECHANICS && @event && @weeds_timer && old_growth_stage == 1 && @growth_stage > old_growth_stage
        @pests_timer += time_per_stage*2 if Settings::BERRY_USE_PEST_MECHANICS && @event && @pests_timer && old_growth_stage <= 2 && @growth_stage > old_growth_stage
        # Record watering (old mechanics), and apply drying out per hour (new mechanics)
        if @new_mechanics
            old_growth_hour = (done_replant) ? 0 : (@time_alive - time_delta) / 3600
            new_growth_hour = @time_alive / 3600
            if new_growth_hour > old_growth_hour
                (new_growth_hour - old_growth_hour).times do
                    if @moisture_level > 0
                        @moisture_level -= drying_per_hour
                    else
                        @yield_penalty += 1
                    end
                end
            end
            water if $game_screen && Settings::BERRY_WATER_IF_RAINING && GameData::Weather.get($game_screen.weather_type).category == :Rain
        else
            old_growth_stage = 0 if done_replant
            new_growth_stage = [@growth_stage, stages_growing + 1].min
            @watered_this_stage = false if new_growth_stage > old_growth_stage
            water if $game_screen && Settings::BERRY_WATER_IF_RAINING && GameData::Weather.get($game_screen.weather_type).category == :Rain
        end
        @exposed_to_preferred_weather = true if pbBerryPreferredWeatherEnabled? && checkPreferredWeather
        return if !planted? || !@event || @mutated_berry_tried || @growth_stage < 2 || !pbAllowBerryMutations?
        checkNearbyPlantsForMutation
    end

    def update_new
        return if !planted?
        time_now = pbGetTimeNow
        time_delta = time_now.to_i - @time_last_updated
        return if time_delta <= 0
        new_time_alive = @time_alive + time_delta
        # Get all growth data
        plant_data = GameData::BerryPlant.get(@berry_id)

        time_per_stage = plant_data.hours_per_stage * 3600   # In seconds
        dynamic_time_per_stage = 0
        time_per_stage += (Settings::BERRY_PREFERRED_WEATHER_TRAITS[:hours_per_stage] * 3600) if @exposed_to_preferred_weather
        time_per_stage += (Settings::BERRY_PREFERRED_ZONE_TRAITS[:hours_per_stage] * 3600) if @preferred_zone
        time_per_stage += (Settings::BERRY_UNPREFERRED_ZONE_TRAITS[:hours_per_stage] * 3600) if @unpreferred_zone
        time_per_stage += (getWateringCansUsedTraits(:hours_per_stage) * 3600)
        time_per_stage = 3600 if time_per_stage < 3600
        dynamic_time_per_stage += (Settings::BERRY_HAS_WEEDS_TRAITS[:hours_per_stage] * 3600) if Settings::BERRY_USE_WEED_MECHANICS && @event && @weeds
        dynamic_time_per_stage += (Settings::BERRY_HAS_PESTS_TRAITS[:hours_per_stage] * 3600) if Settings::BERRY_USE_PEST_MECHANICS && @event && @pests

        drying_per_hour = plant_data.drying_per_hour
        dynamic_drying_per_hour = 0
        drying_per_hour += (Settings::BERRY_PREFERRED_WEATHER_TRAITS[:drying_per_hour]) if @exposed_to_preferred_weather
        drying_per_hour += (Settings::BERRY_PREFERRED_ZONE_TRAITS[:drying_per_hour]) if @preferred_zone
        drying_per_hour += (Settings::BERRY_UNPREFERRED_ZONE_TRAITS[:drying_per_hour]) if @unpreferred_zone
        drying_per_hour += getWateringCansUsedTraits(:drying_per_hour)
        drying_per_hour = 0 if drying_per_hour < 0
        dynamic_drying_per_hour += Settings::BERRY_HAS_WEEDS_TRAITS[:drying_per_hour] if Settings::BERRY_USE_WEED_MECHANICS && @event && @weeds
        dynamic_drying_per_hour += Settings::BERRY_HAS_PESTS_TRAITS[:drying_per_hour] if Settings::BERRY_USE_PEST_MECHANICS && @event && @pests

        max_replants = GameData::BerryPlant::NUMBER_OF_REPLANTS
        max_replants += (Settings::BERRY_PREFERRED_WEATHER_TRAITS[:max_replants]) if @exposed_to_preferred_weather
        max_replants += (Settings::BERRY_PREFERRED_ZONE_TRAITS[:max_replants]) if @preferred_zone
        max_replants += (Settings::BERRY_UNPREFERRED_ZONE_TRAITS[:max_replants]) if @unpreferred_zone
        max_replants = 1 if max_replants < 1

        stages_growing = GameData::BerryPlant::NUMBER_OF_GROWTH_STAGES
        stages_fully_grown = GameData::BerryPlant::NUMBER_OF_FULLY_GROWN_STAGES
        case @mulch_id
        when :GROWTHMULCH
            time_per_stage = (time_per_stage * 0.75).to_i
            drying_per_hour = (drying_per_hour * 1.5).ceil
            dynamic_time_per_stage = (time_per_stage * 0.75).to_i
            dynamic_drying_per_hour = (drying_per_hour * 1.5).ceil
        when :DAMPMULCH
            time_per_stage = (time_per_stage * 1.25).to_i
            drying_per_hour /= 2
            dynamic_time_per_stage = (time_per_stage * 1.25).to_i
            dynamic_drying_per_hour /= 2
        when :GOOEYMULCH
            max_replants = (max_replants * 1.5).ceil
        when :STABLEMULCH
            stages_fully_grown = (stages_fully_grown * 1.5).ceil
        when :BOOSTMULCH
            drying_per_hour = (drying_per_hour * 2).ceil
        when :AMAZEMULCH
            drying_per_hour = (drying_per_hour * 2).ceil
        end
        # Weed counts
        if Settings::BERRY_USE_WEED_MECHANICS && @event && @weeds_timer && !@weeds && @growth_stage > 1
            weed_delta = time_now.to_i - @weeds_timer
            time_for_checks = Settings::BERRY_WEED_HOURS_BETWEEN_CHECKS * 3600
            rolls = (weed_delta / time_for_checks).floor
            rolls.times do 
                @weeds = true if rand(100) < getWeedGrowthChance
                @weeds_timer += time_for_checks
                break if @weeds
            end   
        end
        #Pests
        if Settings::BERRY_USE_PEST_MECHANICS && @event && @pests_timer 
            if !@pests && @growth_stage > 2
                pests_delta = time_now.to_i - @pests_timer
                time_for_checks = Settings::BERRY_PEST_HOURS_BETWEEN_CHECKS * 3600
                rolls = (pests_delta / time_for_checks).floor
                rolls.times do 
                    @pests = true if rand(100) < getPestAppearChance
                    @pests_timer += time_for_checks
                    break if @pests
                end  
            end
            @event.move_speed = @pests ? 6 : @event_base_speed
            $game_map.events[@event.id].move_speed = @event.move_speed if $game_map.map_id == @event.map_id
        end

        # Update how long plant has been alive for
        old_growth_stage = @growth_stage
        old_time_alive = @time_alive
        countdown = time_delta
        @time_in_stage += time_delta
        total_time_per_stage = [(time_per_stage + dynamic_time_per_stage), 3600].max
        done_replant = false
        loop do
            tps = (@growth_stage > 4) ? time_per_stage : total_time_per_stage
            countdown -= tps
            break if @time_in_stage < tps
            @time_in_stage -= tps
            @growth_stage += 1
            if @growth_stage > stages_growing + stages_fully_grown
                if @replant_count >= max_replants
                    reset_withered
                    return
                end
                replant
                done_replant = true
                new_time_alive = countdown
            end
            @weeds_timer += tps if Settings::BERRY_USE_WEED_MECHANICS && @event && @weeds_timer && @growth_stage == 2
            @pests_timer += tps*2 if Settings::BERRY_USE_PEST_MECHANICS && @event && @pests_timer && @growth_stage == 3
        end
        @time_alive = new_time_alive
        @time_last_updated = time_now.to_i

        # Record watering (old mechanics), and apply drying out per hour (new mechanics)
        if @new_mechanics
            old_growth_hour = (done_replant) ? 0 : (@time_alive - time_delta) / 3600
            new_growth_hour = @time_alive / 3600
            if new_growth_hour > old_growth_hour
                (new_growth_hour - old_growth_hour).times do
                    if @moisture_level > 0
                        @moisture_level -= drying_per_hour
                    else
                        @yield_penalty += 1
                    end
                end
            end
            water if $game_screen && Settings::BERRY_WATER_IF_RAINING && GameData::Weather.get($game_screen.weather_type).category == :Rain
        else
            old_growth_stage = 0 if done_replant
            new_growth_stage = [@growth_stage, stages_growing + 1].min
            @watered_this_stage = false if new_growth_stage > old_growth_stage
            water if $game_screen && Settings::BERRY_WATER_IF_RAINING && GameData::Weather.get($game_screen.weather_type).category == :Rain
        end
        @exposed_to_preferred_weather = true if pbBerryPreferredWeatherEnabled? && checkPreferredWeather
        return if !planted? || !@event || @mutated_berry_tried || @growth_stage < 2 || !pbAllowBerryMutations?
        checkNearbyPlantsForMutation
    end


    alias tdw_berry_plant_plant plant
    def plant(berry_id)
        tdw_berry_plant_plant(berry_id)
        @withered_item = nil
        @preferred_weather = (@berry_id && @event && pbBerryPreferredWeatherEnabled? ) ? GameData::BerryData.try_get(@berry_id).preferred_weather : nil
        @preferred_zone = @berry_id && @event && pbBerryPreferredZonesEnabled? && GameData::BerryData.try_get(@berry_id).preferred_zones.include?(@plant_zone)
        @unpreferred_zone = @berry_id && @event && pbBerryUnpreferredZonesEnabled? && !@preferred_zone && 
                GameData::BerryData.try_get(@berry_id).unpreferred_zones.include?(@plant_zone)
        @time_in_stage = 0
        @watering_cans_used = []
        if Settings::BERRY_USE_WEED_MECHANICS
            @weeds = false
            @weeds_timer = pbGetTimeNow.to_i
        end
        if Settings::BERRY_USE_PEST_MECHANICS
            @pests = false
            @pests_timer = pbGetTimeNow.to_i
        end
    end

    alias tdw_berry_plant_reset reset
    def reset(planting = false)
        if !planting && persistent && @growth_stage && @growth_stage > 1
            persistent_replant
            persistent = nil
            return 
        end
        tdw_berry_plant_reset(planting)
        @exposed_to_preferred_weather = false
        @mutated_berry_tried = false
        @mutated_berry_info = nil
        @preferred_zone = nil
        @unpreferred_zone = nil
        @time_in_stage = 0
        @watering_cans_used = []
        if Settings::BERRY_USE_WEED_MECHANICS
            @weeds = false
            @weeds_timer = nil
        end
        if Settings::BERRY_USE_PEST_MECHANICS
            @pests = false
            @pests_timer = nil
        end
    end

    def reset_withered
        item_list = Settings::BERRY_WITHERED_ITEMS
        if item_list.length > 0
            item_list.sort! { |a, b| b[0] <=> a[0] }
            r = rand(100)
            item_list.each do |item|
                r -= item[0]
                next if r >= 0
                itm = item[1]
                itm = @berry_id if itm == :DropParentBerry
                @withered_item = itm
                break
            end
        end
        reset
    end

    alias tdw_berry_plant_replant replant
    def replant
        propagate if pbAllowBerryPropagation?
        tdw_berry_plant_replant
        @exposed_to_preferred_weather = false
        @watering_cans_used = []
        if Settings::BERRY_REPLANT_RESETS_MUTATION
            @mutated_berry_tried = false
            @mutated_berry_info = nil
        end
        if Settings::BERRY_USE_PEST_MECHANICS 
            @pests = false
            @pests_timer = pbGetTimeNow.to_i
        end
    end

    def persistent_replant
        @time_alive         = 0
        @growth_stage       = Settings::BERRY_PERSISTENT_REPLANT_STAGE
        @replant_count      += 1 if Settings::BERRY_PERSISTENT_COUNTS_AS_REPLANT
        @watered_this_stage = false
        @watering_count     = 0
        @moisture_level     = 100
        @yield_penalty      = 0
        @watering_cans_used = []
        @exposed_to_preferred_weather = false
        if Settings::BERRY_REPLANT_RESETS_MUTATION
            @mutated_berry_tried = false
            @mutated_berry_info = nil
        end
        if Settings::BERRY_USE_PEST_MECHANICS 
            @pests = false
            @pests_timer = pbGetTimeNow.to_i
        end
    end

    alias tdw_berry_plant_water water
    def water(used_can = nil)
        return if @town_map_checking
        if Settings::BERRY_SHOW_WATERING_ANIMATION && used_can
            $game_player.set_watering_charset(used_can)
        end
        @watering_cans_used.push(used_can) if used_can && Settings::BERRY_WATERING_CAN_TRAITS[used_can] && !@watering_cans_used.include?(used_can)
        tdw_berry_plant_water
    end

    alias tdw_berry_plant_berry_yield berry_yield
    def berry_yield
        ret = tdw_berry_plant_berry_yield
        ret += 2 if [:RICHMULCH, :AMAZEMULCH].include?(@mulch_id)
        ret += Settings::BERRY_PREFERRED_WEATHER_TRAITS[:yield] if @exposed_to_preferred_weather
        ret += Settings::BERRY_PREFERRED_ZONE_TRAITS[:yield] if @preferred_zone
        ret += Settings::BERRY_UNPREFERRED_ZONE_TRAITS[:yield] if @unpreferred_zone
        ret += getWateringCansUsedTraits(:yield)
        return ret
    end

    def propagate
        return if !@event
        propagation = []
        berry = @berry_id
        qty = berry_yield
        qty.times { propagation.push(berry) }
        if @mutation_info
            mut_berry = @mutation_info[0] 
            mut_berry_qty = @mutation_info[1]
            mut_berry_qty -= 1 while qty - mut_berry_qty < 1
            mut_berry_qty.times { propagation.push(mut_berry) }
        end
        checkNearbyPlantsForPropagation(propagation)
    end

    def pullWeeds
        @weeds = false
        @weeds_timer = pbGetTimeNow.to_i
        $stats.berry_weeds_pulled ||= 0
        $stats.berry_weeds_pulled += 1
    end

    def pbGetNeighbors(position_array = nil, map = nil)
        position = position_array || [@event.map_id, @event.x, @event.y]
        map = map || $map_factory.getMap(position[0])
        neighbors = []
        neighbors[0] = $PokemonGlobal.eventvars[[position[0],map.check_event(position[1], position[2]-1)]]
        neighbors[1] = $PokemonGlobal.eventvars[[position[0],map.check_event(position[1]+1, position[2])]]
        neighbors[2] = $PokemonGlobal.eventvars[[position[0],map.check_event(position[1], position[2]+1)]]
        neighbors[3] = $PokemonGlobal.eventvars[[position[0],map.check_event(position[1]-1, position[2])]]
        return neighbors
    end

    def checkNearbyPlantsForMutation
        $PokemonGlobal.compilePlantMutationParents if !$PokemonGlobal.berry_plant_mutation_parents
        @mutated_berry_tried = true
        return if !@event || !$PokemonGlobal.berry_plant_mutation_parents.include?(@berry_id)
        mutation_chance = Settings::BERRY_MULCHES_IMPACTING_MUTATIONS[@mulch_id] || Settings::BERRY_BASE_MUTATION_CHANCE
        mutation_chance += Settings::BERRY_PREFERRED_WEATHER_TRAITS[:mutation_chance] if @exposed_to_preferred_weather
        mutation_chance += Settings::BERRY_PREFERRED_ZONE_TRAITS[:mutation_chance] if @preferred_zone
        mutation_chance += Settings::BERRY_UNPREFERRED_ZONE_TRAITS[:mutation_chance] if @unpreferred_zone
        mutation_chance += Settings::BERRY_HAS_WEEDS_TRAITS[:mutation_chance] if Settings::BERRY_USE_WEED_MECHANICS && @event && @weeds
        mutation_chance += Settings::BERRY_HAS_PESTS_TRAITS[:mutation_chance] if Settings::BERRY_USE_PEST_MECHANICS && @event && @pests
        mutation_chance += getWateringCansUsedTraits(:mutation_chance)
        return if mutation_chance <= 0 || rand(100) >= mutation_chance
        #position = [@event.map_id, @event.x, @event.y]
        #map = $map_factory.getMap(position[0])
        neighbors = pbGetNeighbors
        possible = []
        neighbors.each do |data|
            next if data.nil? || !data.is_a?(BerryPlantData) || !data.planted?
            id = data.berry_id
            if Settings::BERRY_MUTATION_POSSIBILITIES[[@berry_id,id]]
                possible.concat(Settings::BERRY_MUTATION_POSSIBILITIES[[@berry_id,id]])
            elsif Settings::BERRY_MUTATION_POSSIBILITIES[[id,@berry_id]]
                possible.concat(Settings::BERRY_MUTATION_POSSIBILITIES[[id,@berry_id]])
            end
        end
        @mutated_berry_info = [possible.sample,Settings::BERRY_MUTATION_COUNT] if possible.length > 0
    end

    def checkNearbyPlantsForPropagation(dropped_berries)
        return if dropped_berries.nil? || dropped_berries.empty?
        neighbors = pbGetNeighbors
        neighbors.each do |data|
            next if data.nil? || !data.is_a?(BerryPlantData) || data.planted?
            mulch_id = data.mulch_id
            propagation_chance = Settings::BERRY_MULCHES_IMPACTING_PROPAGATION[mulch_id] || Settings::BERRY_BASE_PROPAGATION_CHANCE
            next if propagation_chance <= 0 || rand(1000) >= propagation_chance
            data.plant(dropped_berries.sample)
            $stats.berries_propagated ||= 0
            $stats.berries_propagated += 1
        end
    end

    def checkPreferredWeather
        return true if @exposed_to_preferred_weather 
        return false if !@preferred_weather || @growth_stage <= 1 || @growth_stage >= 5 
        return true if $game_screen && @preferred_weather.include?($game_screen.weather_type)
        return false
    end

    def getWeedGrowthChance
        return 0 unless Settings::BERRY_USE_WEED_MECHANICS
        weeds_chance =  Settings::BERRY_MULCHES_IMPACTING_WEEDS[@mulch_id] || Settings::BERRY_WEED_GROWTH_CHANCE
        weeds_chance += getWateringCansUsedTraits(:weed_chance) if @event
        return weeds_chance
    end

    def getPestAppearChance
        return 0 unless Settings::BERRY_USE_PEST_MECHANICS
        pests_chance =  Settings::BERRY_MULCHES_IMPACTING_PESTS[@mulch_id] || Settings::BERRY_PEST_APPEAR_CHANCE
        pests_chance += Settings::BERRY_HAS_WEEDS_TRAITS[:pest_chance] if Settings::BERRY_USE_WEED_MECHANICS && @event && @weeds
        pests_chance += getWateringCansUsedTraits(:pest_chance) if @event
        return pests_chance
    end

    def getWateringCansUsedTraits(trait_sym)
        return 0 if !@watering_cans_used || @watering_cans_used.empty?
        ret = 0
        @watering_cans_used.each do |can|
            next if !Settings::BERRY_WATERING_CAN_TRAITS[can]
            traits = Settings::BERRY_WATERING_CAN_TRAIT_DEFINITIONS[Settings::BERRY_WATERING_CAN_TRAITS[can]]
            next if !traits
            ret += traits[trait_sym] || 0
        end
        return ret
    end

end

#===============================================================================
# GameStats
#===============================================================================

class GameStats
    attr_accessor :mutated_berries_picked
    attr_accessor :berries_propagated
    attr_accessor :berry_weeds_pulled
    attr_accessor :berry_pest_battles
    attr_accessor :berries_auto_planted

    alias tdw_berry_improvements_stats_init initialize
    def initialize
        tdw_berry_improvements_stats_init
        @mutated_berries_picked = 0
        @berries_propagated = 0
        @berry_weeds_pulled = 0
        @berry_pest_battles = 0
        @berries_auto_planted = 0
    end
end

#===============================================================================
# BerryPlant Overwrite
#===============================================================================

def pbBerryPlantOrig
    interp = pbMapInterpreter
    this_event = interp.get_self
    berry_plant = interp.getVariable
    if !berry_plant
        berry_plant = BerryPlantData.new
        interp.setVariable(berry_plant)
    end
    berry = berry_plant.berry_id
    # Interact with the event based on its growth
    if berry_plant.grown?
        this_event.turn_up   # Stop the event turning towards the player
        berry_plant.reset if pbPickBerry(berry, berry_plant.berry_yield)
        return
    elsif berry_plant.growing?
        berry_name = GameData::Item.get(berry).name
        case berry_plant.growth_stage
        when 1   # X planted
            this_event.turn_down   # Stop the event turning towards the player
            if berry_name.starts_with_vowel?
                pbMessage(_INTL("An {1} was planted here.", berry_name))
            else
                pbMessage(_INTL("A {1} was planted here.", berry_name))
            end
        when 2   # X sprouted
            this_event.turn_down   # Stop the event turning towards the player
            pbMessage(_INTL("The {1} has sprouted.", berry_name))
        when 3   # X taller
            this_event.turn_left   # Stop the event turning towards the player
            pbMessage(_INTL("The {1} plant is growing bigger.", berry_name))
        else     # X flowering
            this_event.turn_right   # Stop the event turning towards the player
            if Settings::NEW_BERRY_PLANTS
                pbMessage(_INTL("This {1} plant is in bloom!", berry_name))
            else
                case berry_plant.watering_count
                when 4
                    pbMessage(_INTL("This {1} plant is in fabulous bloom!", berry_name))
                when 3
                    pbMessage(_INTL("This {1} plant is blooming very beautifully!", berry_name))
                when 2
                    pbMessage(_INTL("This {1} plant is blooming prettily!", berry_name))
                when 1
                    pbMessage(_INTL("This {1} plant is blooming cutely!", berry_name))
                else
                    pbMessage(_INTL("This {1} plant is in bloom!", berry_name))
                end
            end
        end
        # Water the growing plant
        pbBerryPlantWater(berry_plant)
        return
    end
    # Nothing planted yet
    ask_to_plant = true
    if Settings::NEW_BERRY_PLANTS
        # New mechanics
        if berry_plant.mulch_id
            pbMessage(_INTL("{1} has been laid down.", GameData::Item.get(berry_plant.mulch_id).name))
        else
            case pbMessage(_INTL("It's soft, earthy soil."),
                       [_INTL("Fertilize"), _INTL("Plant Berry"), _INTL("Exit")], -1)
            when 0   # Fertilize
                mulch = nil
                pbFadeOutIn do
                    scene = PokemonBag_Scene.new
                    screen = PokemonBagScreen.new(scene, $bag)
                    mulch = screen.pbChooseItemScreen(proc { |item| GameData::Item.get(item).is_mulch? })
                end
                return if !mulch
                mulch_data = GameData::Item.get(mulch)
                if mulch_data.is_mulch?
                    berry_plant.mulch_id = mulch
                    $bag.remove(mulch)
                    pbMessage(_INTL("The {1} was scattered on the soil.", mulch_data.name))
                else
                    pbMessage(_INTL("That won't fertilize the soil!"))
                    return
                end
            when 1   # Plant Berry
                ask_to_plant = false
            else   # Exit/cancel
                return
            end
        end
    else
        # Old mechanics
        return if !pbConfirmMessage(_INTL("It's soft, loamy soil. Want to plant a berry?"))
        ask_to_plant = false
    end
    if !ask_to_plant || pbConfirmMessage(_INTL("Want to plant a Berry?"))
        pbFadeOutIn do
            scene = PokemonBag_Scene.new
            screen = PokemonBagScreen.new(scene, $bag)
            berry = screen.pbChooseItemScreen(proc { |item| GameData::Item.get(item).is_berry? })
        end
        if berry
            $stats.berries_planted += 1
            berry_plant.plant(berry)
            $bag.remove(berry)
            if Settings::NEW_BERRY_PLANTS
                pbMessage(_INTL("The {1} was planted in the soft, earthy soil.",
                                GameData::Item.get(berry).name))
            elsif GameData::Item.get(berry).name.starts_with_vowel?
                pbMessage(_INTL("{1} planted an {2} in the soft loamy soil.",
                                $player.name, GameData::Item.get(berry).name))
            else
                pbMessage(_INTL("{1} planted a {2} in the soft loamy soil.",
                                $player.name, GameData::Item.get(berry).name))
            end
        end
    end
end

#===============================================================================
# Watering Changes
#===============================================================================

def pbBerryPlantWater(berry_plant)
    return if Settings::BERRY_PREVENT_WATERING_IF_MAXED && berry_plant.moisture_level == 100
    cans = []
    commands = []
    cmd = nil
    if Settings::BERRY_WATERING_MUST_FILL
        GameData::BerryPlant::WATERING_CANS.each do |item|
            next if !$bag.has?(item)
            cans.push(item)
            commands.push(_INTL("Use") + " " + GameData::Item.get(item).name + " " + pbGetWateringCanLevel(item,true))
        end
        return if cans.empty?
        commands[0] = _INTL("Yes") + pbGetWateringCanLevel(cans[0],true) if commands.length == 1
        commands.push(_INTL("No"))
        loop do
            cmd = pbMessage(_INTL("Want to sprinkle some water on it?"), commands, -1)
            break unless cans[cmd] && pbGetWateringCanLevel(cans[cmd]).is_a?(Integer) && pbGetWateringCanLevel(cans[cmd]) <= 0
            pbMessage(_INTL("The {1} is empty!",GameData::Item.get(cans[cmd]).name))
        end
        return if cmd < 0 || cmd == commands.length - 1
        berry_plant.water(cans[cmd])
        $PokemonGlobal.watering_can_levels[cans[cmd]] -= 1 unless $PokemonGlobal.watering_can_levels[cans[cmd]] == "Full"
    else
        GameData::BerryPlant::WATERING_CANS.each do |item|
            next if !$bag.has?(item)
            cans.push(item)
            commands.push(_INTL("Use") + " "  + GameData::Item.get(item).name)
        end
        return if cans.empty?
        commands[0] = _INTL("Yes") if commands.length == 1
        commands.push(_INTL("No"))
        cmd = pbMessage(_INTL("Want to sprinkle some water on it?"), commands, -1)
        return if cmd < 0 || cmd == commands.length - 1
        berry_plant.water(cans[cmd])
    end
    pbMessage(_INTL("{1} watered the plant.", $player.name) + "\\wtnp[40]")
    if Settings::NEW_BERRY_PLANTS
        pbMessage(_INTL("There! All happy!"))
    else
        pbMessage(_INTL("The plant seemed to be delighted."))
    end
    pbMessage(_INTL("The {1} is now empty.",GameData::Item.get(cans[cmd]).name)) if Settings::BERRY_WATERING_MUST_FILL && pbGetWateringCanLevel(cans[cmd]).is_a?(Integer) &&
            pbGetWateringCanLevel(cans[cmd]) <= 0

        # break if !pbConfirmMessage(_INTL("Want to sprinkle some water with the {1}?",
        #                                 GameData::Item.get(item).name))
        # berry_plant.water
        # pbMessage(_INTL("{1} watered the plant.", $player.name) + "\\wtnp[40]")
        # if Settings::NEW_BERRY_PLANTS
        #     pbMessage(_INTL("There! All happy!"))
        # else
        #     pbMessage(_INTL("The plant seemed to be delighted."))
        # end
        # break

end

def pbGetWateringCanLevel(can, string = false)
    return if !Settings::BERRY_WATERING_MUST_FILL
    $PokemonGlobal.initializeWateringCanLevels if !$PokemonGlobal.watering_can_levels
    level = $PokemonGlobal.watering_can_levels[can]
    return level unless string
    case level
    when pbGetWateringCanMax(can)
        return " (F)"
    when 0
        return " (E)"
    else
        return " (" + level.to_s + ")"
    end
end

def pbFillWateringCans(count_var = 1, single_name_var = 3)
    count = 0
    return pbSet(count_var,count) if !Settings::BERRY_WATERING_MUST_FILL || !$PokemonGlobal.watering_can_levels
    can = ""
    GameData::BerryPlant::WATERING_CANS.each do |item|
        next if !$bag.has?(item)
        count += 1
        can = GameData::Item.get(item).name
        $PokemonGlobal.watering_can_levels[item] = pbGetWateringCanMax(item)
    end
    pbSet(count_var,count)
    pbSet(single_name_var,can)
    return true
end

def pbGetWateringCanMax(can)
    return "Full" if Settings::BERRY_WATERING_USES_ALWAYS_FULL.include?(can)
    ret = Settings::BERRY_WATERING_USES_OVERRIDES[can] || Settings::BERRY_WATERING_USES_BEFORE_EMPTY
    return ret
end

#===============================================================================
# Mutations
#===============================================================================

#alias tdw_berry_improvements_berry_plant pbBerryPlant
def pbBerryPlant
    berry_plant = pbMapInterpreter.getVariable
    not_planted = !berry_plant&.planted?
    pbBerryPlantWitheredItem
    pbPestInteraction
    if berry_plant&.mutated_berry_info
        pbBerryPlantWithMutation
        if Settings::BERRY_SHOW_WATERING_ANIMATION && $game_player.berry_watering
            $game_player.stop_watering_charset
        end
        pbOtherInteractions if !not_planted
    else
        pbBerryPlantOrig
        if Settings::BERRY_SHOW_WATERING_ANIMATION && $game_player.berry_watering
            $game_player.stop_watering_charset
        end
        pbOtherInteractions if !not_planted
    end
    if Settings::BERRY_PREFERRED_ZONE_WARNING && not_planted && berry_plant && 
                berry_plant.berry_id && berry_plant.plant_zone
        if GameData::BerryData.get(berry_plant.berry_id).preferred_zones.include?(berry_plant.plant_zone)
            pbMessage(_INTL("The {1} seemed happy to be planted here!", GameData::Item.get(berry_plant.berry_id).name))
        elsif GameData::BerryData.get(berry_plant.berry_id).unpreferred_zones.include?(berry_plant.plant_zone)
            pbMessage(_INTL("The {1} didn't seem happy to be planted here...", GameData::Item.get(berry_plant.berry_id).name))
        end
    end
end

def pbBerryPlantWithMutation
    interp = pbMapInterpreter
    this_event = interp.get_self
    berry_plant = interp.getVariable
    berry = berry_plant.berry_id
    # Interact with the event based on its growth
    if berry_plant.grown?
        this_event.turn_up   # Stop the event turning towards the player
        berry_plant.reset if pbPickBerryWithMutation(berry, berry_plant.berry_yield, berry_plant.mutated_berry_info)
        return
    elsif berry_plant.growing?
        berry_name = GameData::Item.get(berry).name
        case berry_plant.growth_stage
        when 1   # X planted
            this_event.turn_down   # Stop the event turning towards the player
            if berry_name.starts_with_vowel?
                pbMessage(_INTL("An {1} was planted here.", berry_name))
            else
                pbMessage(_INTL("A {1} was planted here.", berry_name))
            end
        when 2   # X sprouted
            this_event.turn_down   # Stop the event turning towards the player
            pbMessage(_INTL("The {1} has sprouted.", berry_name))
        when 3   # X taller
            this_event.turn_left   # Stop the event turning towards the player
            pbMessage(_INTL("The {1} plant is growing bigger.", berry_name))
        else     # X flowering
            this_event.turn_right   # Stop the event turning towards the player
            mutation_comment = Settings::BERRY_PLANT_BLOOMING_COMMENT
            if Settings::NEW_BERRY_PLANTS
                pbMessage(_INTL("This {1} plant is in bloom!", berry_name))
            else
                case berry_plant.watering_count
                when 4
                    pbMessage(_INTL("This {1} plant is in fabulous bloom!", berry_name))
                when 3
                    pbMessage(_INTL("This {1} plant is blooming very beautifully!", berry_name))
                when 2
                    pbMessage(_INTL("This {1} plant is blooming prettily!", berry_name))
                when 1
                    pbMessage(_INTL("This {1} plant is blooming cutely!", berry_name))
                else
                    pbMessage(_INTL("This {1} plant is in bloom!", berry_name))
                end
            end
            pbMessage(mutation_comment) if mutation_comment
        end
        # Water the growing plant
        pbBerryPlantWater(berry_plant)
        return
    end
end

def pbPickBerryWithMutation(berry, qty = 1, mutation_info)
    berry = GameData::Item.get(berry)
    mut_berry = GameData::Item.get(mutation_info[0])
    mut_berry_qty = mutation_info[1]
    mut_berry_qty -= 1 while qty - mut_berry_qty < 1
    berry_name = (qty > 1) ? berry.name_plural : berry.name
    mut_berry_name = (mut_berry_qty > 1) ? mut_berry.name_plural : mut_berry.name
    if qty > 1 && mut_berry_qty > 1
        message = _INTL("There are {1} \\c[1]{2}\\c[0] and {3} \\c[1]{4}\\c[0]! \1Want to pick them?", qty, berry_name, mut_berry_qty, mut_berry_name)
    elsif qty > 1
        message = _INTL("There are {1} \\c[1]{2}\\c[0] and 1 \\c[1]{3}\\c[0]! \1Want to pick them?", qty, berry_name, mut_berry_name)
    elsif mut_berry_qty > 1
        message = _INTL("There is 1 \\c[1]{1}\\c[0] and {2} \\c[1]{3}\\c[0]! \1Want to pick them?", berry_name, mut_berry_qty, mut_berry_name)
    else
        message = _INTL("There is 1 \\c[1]{1}\\c[0] and 1 \\c[1]{2}\\c[0]! \1Want to pick them?", berry_name, mut_berry_name)
    end
    return false if !pbConfirmMessage(message)
    if !$bag.can_add?(berry, qty) || !$bag.can_add?(mut_berry, mut_berry_qty)
        pbMessage(_INTL("Too bad...\nThe Bag is full..."))
        return false
    end
    $stats.berry_plants_picked += 1
    $stats.mutated_berries_picked ||= 0
    $stats.mutated_berries_picked += mut_berry_qty
    if qty + mut_berry_qty >= GameData::BerryPlant.get(berry.id).maximum_yield
        $stats.max_yield_berry_plants += 1
    end
    $bag.add(berry, qty)
    $bag.add(mut_berry, mut_berry_qty)
    if qty > 1 && mut_berry_qty > 1
        pbMessage(_INTL("\\me[Berry get]You picked the {1} \\c[1]{2}\\c[0] and {3} \\c[1]{4}\\c[0].\\wtnp[30]", qty, berry_name, mut_berry_qty, mut_berry_name))
    elsif qty > 1
        pbMessage(_INTL("\\me[Berry get]You picked the {1} \\c[1]{2}\\c[0] and \\c[1]{3}\\c[0].\\wtnp[30]", qty, berry_name, mut_berry_name))
    elsif mut_berry_qty > 1
        pbMessage(_INTL("\\me[Berry get]You picked the \\c[1]{1}\\c[0] and {2} \\c[1]{3}\\c[0].\\wtnp[30]", berry_name, mut_berry_qty, mut_berry_name))
    else
        pbMessage(_INTL("\\me[Berry get]You picked the \\c[1]{1}\\c[0] and \\c[1]{2}\\c[0].\\wtnp[30]", berry_name, mut_berry_name))
    end
    pocket = berry.pocket
    pbMessage(_INTL("{1} put them in\\nyour Bag's <icon=bagPocket{2}>\\c[1]{3}\\c[0] Pocket.\1", $player.name, pocket, PokemonBag.pocket_names[pocket - 1]))
    berry_plant = pbMapInterpreter.getVariable
    berry_plant.persistent = true if Settings::BERRY_PERSISTENT_PLANT_CHANCE > 0 && berry_plant && berry_plant.replant_count < GameData::BerryPlant::NUMBER_OF_REPLANTS && 
            rand(100) < Settings::BERRY_PERSISTENT_PLANT_CHANCE
    unless berry_plant&.persistent
        if Settings::NEW_BERRY_PLANTS
            pbMessage(_INTL("The soil returned to its soft and earthy state."))
        else
            pbMessage(_INTL("The soil returned to its soft and loamy state."))
        end
    end
    this_event = pbMapInterpreter.get_self
    pbSetSelfSwitch(this_event.id, "A", true)
    return true
end

def pbPickBerryPersistent(berry, qty)
    berry = GameData::Item.get(berry)
    berry_name = (qty > 1) ? berry.name_plural : berry.name
    if qty > 1
        message = _INTL("There are {1} \\c[1]{2}\\c[0]!\nWant to pick them?", qty, berry_name)
    else
        message = _INTL("There is 1 \\c[1]{1}\\c[0]!\nWant to pick it?", berry_name)
    end
    return false if !pbConfirmMessage(message)
    if !$bag.can_add?(berry, qty)
        pbMessage(_INTL("Too bad...\nThe Bag is full..."))
        return false
    end
    $stats.berry_plants_picked += 1
    if qty >= GameData::BerryPlant.get(berry.id).maximum_yield
        $stats.max_yield_berry_plants += 1
    end
    $bag.add(berry, qty)
    if qty > 1
        pbMessage("\\me[Berry get]" + _INTL("You picked the {1} \\c[1]{2}\\c[0].", qty, berry_name) + "\\wtnp[30]")
    else
        pbMessage("\\me[Berry get]" + _INTL("You picked the \\c[1]{1}\\c[0].", berry_name) + "\\wtnp[30]")
    end
    pocket = berry.pocket
    pbMessage(_INTL("You put the {1} in\\nyour Bag's <icon=bagPocket{2}>\\c[1]{3}\\c[0] pocket.",
                    berry_name, pocket, PokemonBag.pocket_names[pocket - 1]) + "\1")
    #Create berry plant data now so preplanted plants can be persistent
    interp = pbMapInterpreter
    berry_plant = interp.getVariable
    preplanted = false
    will_persist = rand(100) < Settings::BERRY_PERSISTENT_PLANT_CHANCE
    if !berry_plant && Settings::BERRY_PERSISTENT_FOR_PREPLANTED && will_persist
        berry_plant = BerryPlantData.new
        interp.setVariable(berry_plant)
        berry_plant = interp.getVariable
        berry_plant.plant(berry.id)
        berry_plant.growth_stage = 2
        preplanted = true
    end
    berry_plant.persistent = true if Settings::BERRY_PERSISTENT_PLANT_CHANCE > 0 && berry_plant && berry_plant.replant_count < GameData::BerryPlant::NUMBER_OF_REPLANTS && will_persist
    unless berry_plant&.persistent
        if Settings::NEW_BERRY_PLANTS
            pbMessage(_INTL("The soil returned to its soft and earthy state."))
        else
            pbMessage(_INTL("The soil returned to its soft and loamy state."))
        end
    end
    this_event = pbMapInterpreter.get_self
    pbSetSelfSwitch(this_event.id, "A", true)
    berry_plant.reset if preplanted
    return true
end

def pbPestInteraction
    interp = pbMapInterpreter
    berry_plant = interp.getVariable
    return if !Settings::BERRY_USE_PEST_MECHANICS || !berry_plant || !berry_plant.pests
    berry = berry_plant.berry_id
    this_event = interp.get_self
    if berry_plant.grown?
        this_event.turn_up
    elsif
        case berry_plant.growth_stage
        when 1 then this_event.turn_down
        when 2 then this_event.turn_down
        when 3 then this_event.turn_left
        else this_event.turn_right
        end
    end
    if Settings::BERRY_REPEL_WORKS_ON_PESTS && $PokemonGlobal.repel > 0
        if $PokemonGlobal.repel_item
            pbMessage(_INTL("A Pokémon jumped out, but the {1} made it run away!",GameData::Item.get($PokemonGlobal.repel_item).name))
        else
            pbMessage(_INTL("A Pokémon jumped out, but the repellent made it run away!"))
        end
    else
        pbMessage(_INTL("A Pokémon jumped out at you!"))
        pbBerryPlantPestRandomEncounter(GameData::BerryData.get(berry).color)
    end
    berry_plant.pests = false
    berry_plant.pests_timer = pbGetTimeNow.to_i
end

def pbOtherInteractions
    berry_plant = pbMapInterpreter.getVariable
    berry = berry_plant.berry_id
    # Dig Up
    if berry_plant.growing? && berry_plant.growth_stage == 1 && pbCanDigUpBerry?
        if pbConfirmMessage(_INTL("You may be able to dig up the berry. Dig up the {1}?", GameData::Item.get(berry).name))
            berry_plant.reset
            if rand(100) < Settings::BERRY_DIG_UP_KEEP_CHANCE
                $bag.add(berry)
                pbMessage(_INTL("The dug up {1} was in good enough condition to keep.",GameData::Item.get(berry).name))
            else
                pbMessage(_INTL("The dug up {1} broke apart in your hands.",GameData::Item.get(berry).name))
            end
        end
    end
    #Weeds
    if Settings::BERRY_USE_WEED_MECHANICS && berry_plant.weeds
        if pbConfirmMessage(_INTL("Weeds are growing here. Pull out the weeds?"))
            berry_plant.pullWeeds
            pbMessage(_INTL("{1} pulled out the weeds!", $player.name))
        end
    end
end

def pbBerryPlantWitheredItem
    berry_plant = pbMapInterpreter.getVariable
    return if !berry_plant
    item = berry_plant.withered_item
    return if berry_plant.planted? || !item
    pbMessage(_INTL("There's something on the ground..."))
    pbReceiveItem(item)
    berry_plant.withered_item = nil
end

class PokemonGlobalMetadata
    attr_accessor :berry_plant_mutation_parents
    attr_accessor :maps_first_setups
    attr_accessor :watering_can_levels

    alias tdw_berry_plant_global_init initialize
    def initialize
        tdw_berry_plant_global_init
        compilePlantMutationParents
        @maps_first_setups = {}
    end

    def compilePlantMutationParents
        @berry_plant_mutation_parents = []
        Settings::BERRY_MUTATION_POSSIBILITIES.each { |key| 
            @berry_plant_mutation_parents.push(key[0][0]) if !@berry_plant_mutation_parents.include?(key[0][0])
            @berry_plant_mutation_parents.push(key[0][1]) if !@berry_plant_mutation_parents.include?(key[0][1])
        }
    end

    def initializeWateringCanLevels
        return if !Settings::BERRY_WATERING_MUST_FILL
        @watering_can_levels = {}
        GameData::BerryPlant::WATERING_CANS.each do |item|
            @watering_can_levels[item] = pbGetWateringCanMax(item)
        end
    end
end


#===============================================================================
# Set Up Berry Data sooner
#===============================================================================
# This sets up berry data after a static berry plant is picked.
alias tdw_berry_improvements_pickberry pbPickBerry
def pbPickBerry(berry, qty = 1)
    ret = (Settings::BERRY_PERSISTENT_PLANT_CHANCE > 0) ? pbPickBerryPersistent(berry, qty) : tdw_berry_improvements_pickberry(berry, qty)
    if ret
        interp = pbMapInterpreter
        berry_plant = interp.getVariable
        if !berry_plant
          berry_plant = BerryPlantData.new
          interp.setVariable(berry_plant)
        end
    end
    return ret
end

# This sets up berry data if the event has pbberryplant in the event pages, but not pbpickberry before it.
class Game_Map
    alias tdw_berry_improvements_map_setup setup
    def setup(map_id)
        tdw_berry_improvements_map_setup(map_id)
        return if $PokemonGlobal.maps_first_setups && $PokemonGlobal.maps_first_setups[map_id]
        @events.each do |event|
            next if !event[1].name[/berryplant/i]
            next if $PokemonGlobal.eventvars[[map_id, event[1].id]]
            next if event[1].list.nil?
            next unless event[1].list.is_a?(Array)
            plant = false
            pick = false
            event[1].list.each do |item|
                break if pick || plant
                next if ![355, 655].include?(item.code)
                next plant = true if item.parameters[0][/pbberryplant/i]
                next pick = true if item.parameters[0][/pbpickberry/i]
            end
            if plant && !pick
                berry_plant = $PokemonGlobal.eventvars[[map_id, event[1].id]]
                if !berry_plant
                    berry_plant = BerryPlantData.new(event[1])
                    berry_plant.town_map_location = [$~[1].to_i,$~[2].to_i,$~[3].to_i] if event[1].name[/map\((\d+),(\d+),(\d+)\)/i]
                    berry_plant.plant_zone = $~[1].to_s if event[1].name[/berryzone\((\w+)\)$/i]
                    $PokemonGlobal.eventvars[[map_id, event[1].id]] = berry_plant
                end
            end
        end
        $PokemonGlobal.maps_first_setups ||= {}
        $PokemonGlobal.maps_first_setups[map_id] = true
    end
end


#===============================================================================
# Town Map
#===============================================================================

def pbForceUpdateAllBerryPlants(mapOnly: false, region: -1, returnArray: false)
    array = []
    $PokemonGlobal.eventvars.each do |info|
        plant = info[1]
        next if !plant.is_a?(BerryPlantData)
        Console.echo_warn _INTL("BerryPlant Event #{info[0][1]} on map #{pbGetBasicMapNameFromId(info[0][0])}[#{info[0][0]}] has no map(region,x,y) defined.") if plant.town_map_location.nil?
        next if mapOnly && plant.town_map_location.nil?
        next if region >= 0 && plant.town_map_location[0] != region
        plant.town_map_checking = true
        plant.update
        plant.town_map_checking = nil
        array.push(plant) if plant.planted?
    end
    return returnArray ? array : nil
end

class PokemonRegionMap_Scene
    def allowShowingBerries
        return false if @wallmap
        return pbMapShowBerries?
    end
        
    if PluginManager.installed?("Arcky's Region Map") 
        def berryModeID
            return 3 if PluginManager.installed?("Arcky's Region Map","1.2") 
            return 0
        end
        
        alias tdw_berry_improvements_map_add addFlyIconSprites
        def addFlyIconSprites
            tdw_berry_improvements_map_add
            addBerryIconSprites if allowShowingBerries
        end

        alias tdw_berry_improvements_map_refresh refreshFlyScreen
        def refreshFlyScreen
            tdw_berry_improvements_map_refresh
            refreshBerryScreen if allowShowingBerries
        end

        def addBerryIconSprites
            if !@spritesMap["BerryIcons"]
                @berryIcons = {}
                regionID = -1
                if @region >= 0 && @playerPos && @region != @playerPos[0]
                    regionID = @region
                elsif @playerPos
                    regionID = @playerPos[0]
                end
                berryPlants = pbForceUpdateAllBerryPlants(mapOnly: true, region: regionID, returnArray: true)
                settings = Settings::BERRIES_ON_MAP_SHOW_PRIORITY
                berryPlants.each do |plant|
                    img = 999
                    settings.each_with_index { |set, i|
                        if set == :ReadyToPick && plant.grown? then img = i
                        elsif set == :HasPests && plant.pests then img = i
                        elsif set == :NeedsWater && plant.moisture_stage == 0 then img = i
                        elsif set == :HasWeeds && plant.weeds then img = i
                        end
                        break if img != 999
                    }
                    if @berryIcons[plant.town_map_location]
                        @berryIcons[plant.town_map_location] = img if img < @berryIcons[plant.town_map_location]
                    else
                        @berryIcons[plant.town_map_location] = img
                    end
                end
                @mapHeight = @mapHeigth if @mapHeigth
                @spritesMap["BerryIcons"] = BitmapSprite.new(@mapWidth, @mapHeight, @viewportMap)
                @spritesMap["BerryIcons"].x = @spritesMap["map"].x
                @spritesMap["BerryIcons"].y = @spritesMap["map"].y
                @spritesMap["BerryIcons"].z = 59
                @spritesMap["BerryIcons"].visible = @mode == berryModeID
            end
            @berryIcons.each { |key, value|
                conversion = {:NeedsWater => "mapBerryDry", :ReadyToPick => "mapBerryReady", 
                        :HasPests => "mapBerryPest", :HasWeeds => "mapBerryWeeds"}[settings[value]] || "mapBerry"
                pbDrawImagePositions(@spritesMap["BerryIcons"].bitmap,
                  [[pbGetBerryMapIcon(conversion), pointXtoScreenX(key[1]), pointYtoScreenY(key[2])]])
            }
        end

        def refreshBerryScreen
            @spritesMap["BerryIcons"].visible = @mode == berryModeID
        end
    else
        alias tdw_berry_improvements_map_fy_refresh refresh_fly_screen
        def refresh_fly_screen
            tdw_berry_improvements_map_fy_refresh
            refresh_berry_screen if allowShowingBerries
        end

        def add_berry_icon_sprites
            regionID = -1
            playerpos = ($game_map.metadata) ? $game_map.metadata.town_map_position : nil
            if @region >= 0 && playerpos && @region != playerpos[0]
                regionID = @region
            elsif playerpos
                regionID = playerpos[0]
            end
            berryIcons = {}
            berryPlants = pbForceUpdateAllBerryPlants(mapOnly: true, region: regionID, returnArray: true)
            settings = Settings::BERRIES_ON_MAP_SHOW_PRIORITY
            berryPlants.each do |plant|
                img = 999
                settings.each_with_index { |set, i|
                    if set == :ReadyToPick && plant.grown? then img = i
                    elsif set == :HasPests && plant.pests then img = i
                    elsif set == :NeedsWater && plant.moisture_stage == 0 then img = i
                    elsif set == :HasWeeds && plant.weeds then img = i
                    end
                    break if img != 999
                }
                if @berryIcons[plant.town_map_location]
                    @berryIcons[plant.town_map_location] = img if img < @berryIcons[plant.town_map_location]
                else
                    @berryIcons[plant.town_map_location] = img
                end
            end
            k = 0
            berryIcons.each { |key, value|
                conversion = {:NeedsWater => "mapBerryDry", :ReadyToPick => "mapBerryReady", 
                        :HasPests => "mapBerryPest", :HasWeeds => "mapBerryWeeds"}[settings[value]] || "mapBerry"
                @sprites["berry#{k}"] = IconSprite.new(0, 0, @viewport)
                @sprites["berry#{k}"].setBitmap(pbGetBerryMapIcon(conversion))
                @sprites["berry#{k}"].x        = point_x_to_screen_x(key[1])
                @sprites["berry#{k}"].y        = point_y_to_screen_y(key[2])
                @sprites["berry#{k}"].visible  = @mode == 0
                k += 1
            }
            @sprites.each { |key, sprite|
                next if ["background","map","map2","mapbottom"].include?(key)
                next if key.include?("berry")
                sprite.z += 1
            }
        end

        def refresh_berry_screen
            return if @fly_map || @wallmap
            add_berry_icon_sprites if !@sprites["berry0"]
            @sprites.each do |key, sprite|
                next if !key.include?("berry")
                sprite.visible = (@mode == 0)
            end
        end
    end

    def pbGetBerryMapIcon(id)
        if Essentials::VERSION.include?("21")
            return "Graphics/UI/Berry Improvements/#{id}"
        else
            return "Graphics/Pictures/Berry Improvements/#{id}"
        end
    end
end

#===============================================================================
# Mulch Graphic
#===============================================================================

EventHandlers.add(:on_new_spriteset_map, :add_berry_plant_mulch_graphic,
    proc { |spriteset, viewport|
      next if Settings::BERRY_JUST_MULCH_GRAPHIC.nil? || Settings::BERRY_JUST_MULCH_GRAPHIC.empty?
      map = spriteset.map
      map.events.each do |event|
        next if !event[1].name[/berryplant/i]
        spriteset.addUserSprite(BerryPlantMulchSprite.new(event[1], map, viewport))
      end
    }
)

class BerryPlantMulchSprite
    def initialize(event, map, viewport = nil)
        @event          = event
        @map            = map
        @mulch          = false
        @sprite         = IconSprite.new(0, 0, viewport)
        @sprite.ox      = 16
        @sprite.oy      = 24
        @disposed       = false
        update_graphic
    end
  
    def dispose
        @sprite.dispose
        @map      = nil
        @event    = nil
        @disposed = true
    end
  
    def disposed?
        return @disposed
    end
  
    def update_graphic
        if @mulch  
            @sprite.setBitmap("Graphics/Characters/#{Settings::BERRY_JUST_MULCH_GRAPHIC}")
        else
            @sprite.setBitmap("") 
        end
    end
  
    def update
        return if !@sprite || !@event
        cur_mulch = @mulch
        berry_plant = @event.variable
        return if !berry_plant.is_a?(BerryPlantData)
        if berry_plant.planted? || !berry_plant.mulch_id
            @mulch = false
        else
            @mulch = true
        end
        update_graphic if cur_mulch != @mulch
        @sprite.update
        @sprite.x      = ScreenPosHelper.pbScreenX(@event)
        @sprite.y      = ScreenPosHelper.pbScreenY(@event)
        @sprite.zoom_x = ScreenPosHelper.pbScreenZoomX(@event)
        @sprite.zoom_y = @sprite.zoom_x
        pbDayNightTint(@sprite)
    end
end

#===============================================================================
# Weeds Graphic
#===============================================================================

EventHandlers.add(:on_new_spriteset_map, :add_berry_plant_weed_graphic,
    proc { |spriteset, viewport|
      next if !Settings::BERRY_USE_WEED_MECHANICS
      map = spriteset.map
      map.events.each do |event|
        next if !event[1].name[/berryplant/i]
        spriteset.addUserSprite(BerryPlantWeedSprite.new(event[1], map, viewport))
      end
    }
)

class BerryPlantWeedSprite
    def initialize(event, map, viewport = nil)
        @event          = event
        @map            = map
        @weeds          = false
        @sprite         = IconSprite.new(0, 0, viewport)
        @sprite.ox      = 16
        @sprite.oy      = 24
        @disposed       = false
        update_graphic
    end
  
    def dispose
        @sprite.dispose
        @map      = nil
        @event    = nil
        @disposed = true
    end
  
    def disposed?
        return @disposed
    end
  
    def update_graphic
        if @weeds  
            @sprite.setBitmap("Graphics/Characters/berrytreeweeds")
        else
            @sprite.setBitmap("") 
        end
    end
  
    def update
        return if !@sprite || !@event
        cur_weeds = @weeds
        berry_plant = @event.variable
        return if !berry_plant.is_a?(BerryPlantData)
        @weeds = berry_plant.weeds
        update_graphic if cur_weeds != @weeds
        @sprite.update
        @sprite.x      = ScreenPosHelper.pbScreenX(@event)
        @sprite.y      = ScreenPosHelper.pbScreenY(@event)
        @sprite.zoom_x = ScreenPosHelper.pbScreenZoomX(@event)
        @sprite.zoom_y = @sprite.zoom_x
        pbDayNightTint(@sprite)
    end
end

#===============================================================================
# Preferred Traits checks
#===============================================================================

def pbBerryPreferredWeatherEnabled?
    return PluginManager.installed?("TDW Berry Core and Dex") && Settings::BERRY_PREFERRED_WEATHER_ENABLED
end

def pbBerryPreferredZonesEnabled?
    return PluginManager.installed?("TDW Berry Core and Dex") && Settings::BERRY_PREFERRED_ZONES_ENABLED
end

def pbBerryUnpreferredZonesEnabled?
    return PluginManager.installed?("TDW Berry Core and Dex") && Settings::BERRY_UNPREFERRED_ZONES_ENABLED
end

#===============================================================================
# Settings Checks
#===============================================================================

def pbCanDigUpBerry?
    switch = true
    switch = false if Settings::BERRY_ALLOW_DIGGING_UP_SWITCH_ID == false
    if Settings::BERRY_ALLOW_DIGGING_UP_SWITCH_ID.is_a?(Integer)
        if Settings::BERRY_ALLOW_DIGGING_UP_SWITCH_ID == -1
            switch = false
        elsif Settings::BERRY_ALLOW_DIGGING_UP_SWITCH_ID == 0
            switch = true
        else 
            switch = $game_switches[Settings::BERRY_ALLOW_DIGGING_UP_SWITCH_ID]
        end
    end
    item = !Settings::BERRY_DIG_UP_ITEM || $bag.has?(Settings::BERRY_DIG_UP_ITEM)
    return switch && item
end

def pbAllowBerryMutations?
    switch = true
    switch = false if Settings::ALLOW_BERRY_MUTATIONS_SWITCH_ID == false
    if Settings::ALLOW_BERRY_MUTATIONS_SWITCH_ID.is_a?(Integer)
        if Settings::ALLOW_BERRY_MUTATIONS_SWITCH_ID == -1
            switch = false
        elsif Settings::ALLOW_BERRY_MUTATIONS_SWITCH_ID == 0
            switch = true
        else 
            switch = $game_switches[Settings::ALLOW_BERRY_MUTATIONS_SWITCH_ID]
        end
    end
    return switch
end

def pbAllowBerryPropagation?
    switch = true
    switch = false if Settings::ALLOW_BERRY_PROPAGATION_SWITCH_ID == false
    if Settings::ALLOW_BERRY_PROPAGATION_SWITCH_ID.is_a?(Integer)
        if Settings::ALLOW_BERRY_PROPAGATION_SWITCH_ID == -1
            switch = false
        elsif Settings::ALLOW_BERRY_PROPAGATION_SWITCH_ID == 0
            switch = true
        else 
            switch = $game_switches[Settings::ALLOW_BERRY_PROPAGATION_SWITCH_ID]
        end
    end
    return switch
end

def pbMapShowBerries?
    switch = true
    switch = false if Settings::SHOW_BERRIES_ON_MAP_SWITCH_ID == false
    if Settings::SHOW_BERRIES_ON_MAP_SWITCH_ID.is_a?(Integer)
        if Settings::SHOW_BERRIES_ON_MAP_SWITCH_ID == -1
            switch = false
        elsif Settings::SHOW_BERRIES_ON_MAP_SWITCH_ID == 0
            switch = true
        else 
            switch = $game_switches[Settings::SHOW_BERRIES_ON_MAP_SWITCH_ID]
        end
    end
    return switch
end

#===============================================================================
# Watering sprites
#===============================================================================

module GameData
    class PlayerMetadata

        alias tdw_berry_improvements_player_met_init initialize
        def initialize(hash)
            tdw_berry_improvements_player_met_init(hash)
            init_berry_watering
        end

        def init_berry_watering
            @watering_charset = Settings::BERRY_WATERING_SPRITES[@id-1]
        end

        def watering_charset
            @watering_charset ||= Settings::BERRY_WATERING_SPRITES[@id-1] || nil
            return @watering_charset
        end

    end
end

class Game_Player < Game_Character
    attr_reader :berry_watering

    alias tdw_berry_improvements_player_refresh_charset refresh_charset
    def refresh_charset
        tdw_berry_improvements_player_refresh_charset unless @berry_watering
    end

    def set_watering_charset(used_can)
        meta = GameData::PlayerMetadata.get($player&.character_ID || 1)
        @berry_watering = true
        new_charset = pbGetPlayerCharset(meta.watering_charset)
        if new_charset
            possible = new_charset + get_pail_image(used_can) if pbResolveBitmap("Graphics/Characters/" + new_charset + get_pail_image(used_can))
            @character_name = possible || new_charset
        end
        @step_anime = true
    end

    def stop_watering_charset
        @berry_watering = false
        @step_anime = false
        @pattern = @original_pattern
        @anime_count = 0
        refresh_charset
    end

    def get_pail_image(used_can)
        image = ""
        if used_can && $bag.has?(used_can)
            image = "_" + used_can.to_s
        else
            GameData::BerryPlant::WATERING_CANS.each do |item|
                next if !$bag.has?(item)
                    image = "_" + item.to_s
                break
            end
        end
        return image
    end

end