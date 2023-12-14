# ==============================================================================
# Trainers Gimmick Traits
# ==============================================================================
module Compiler
  def compile_trainer_types(path = "PBS/trainer_types.txt")
    compile_pbs_file_message_start(path)
    GameData::TrainerType::DATA.clear
    schema = GameData::TrainerType::SCHEMA
    tr_type_names = []
    tr_type_hash  = nil
    # Read each line of trainer_types.txt at a time and compile it into a trainer type
    pbCompilerEachPreppedLine(path) { |line, line_no|
      if line[/^\s*\[\s*(.+)\s*\]\s*$/]   # New section [tr_type_id]
        # Add previous trainer type's data to records
        GameData::TrainerType.register(tr_type_hash) if tr_type_hash
        # Parse trainer type ID
        tr_type_id = $~[1].to_sym
        if GameData::TrainerType.exists?(tr_type_id)
          raise _INTL("Trainer Type ID '{1}' is used twice.\r\n{2}", tr_type_id, FileLineData.linereport)
        end
        # Construct trainer type hash
        tr_type_hash = {
          :id => tr_type_id
        }
      elsif line[/^\s*(\w+)\s*=\s*(.*)\s*$/]   # XXX=YYY lines
        if !tr_type_hash
          raise _INTL("Expected a section at the beginning of the file.\r\n{1}", FileLineData.linereport)
        end
        # Parse property and value
        property_name = $~[1]
        line_schema = schema[property_name]
        next if !line_schema
        property_value = pbGetCsvRecord($~[2], line_no, line_schema)
        # Record XXX=YYY setting
        tr_type_hash[line_schema[0]] = property_value
        tr_type_names.push(tr_type_hash[:name]) if property_name == "Name"
      else   # Old format
        # Add previous trainer type's data to records
        GameData::TrainerType.register(tr_type_hash) if tr_type_hash
        # Parse trainer type
        line = pbGetCsvRecord(line, line_no,
                              [0, "snsUSSSeUS",
                               nil, nil, nil, nil, nil, nil, nil,
                               { "Male"   => 0, "M" => 0, "0" => 0,
                                 "Female" => 1, "F" => 1, "1" => 1,
                                 "Mixed"  => 2, "X" => 2, "2" => 2, "" => 2 },
                               nil, nil])
        tr_type_id = line[1].to_sym
        if GameData::TrainerType.exists?(tr_type_id)
          raise _INTL("Trainer Type ID '{1}' is used twice.\r\n{2}", tr_type_id, FileLineData.linereport)
        end
        # Construct trainer type hash
        tr_type_hash = {
          :id          => tr_type_id,
          :name        => line[2],
          :base_money  => line[3],
          :battle_BGM  => line[4],
          :victory_BGM => line[5],
          :intro_BGM   => line[6],
          :gender      => line[7],
          :skill_level => line[8],
          :flags       => line[9]
        }
        # Add trainer type's data to records
        GameData::TrainerType.register(tr_type_hash)
        tr_type_names.push(tr_type_hash[:name])
        tr_type_hash = nil
      end
    }
    # Add last trainer type's data to records
    GameData::TrainerType.register(tr_type_hash) if tr_type_hash
    # Save all data
    GameData::TrainerType.save
    MessageTypes.setMessagesAsHash(MessageTypes::TrainerTypes, tr_type_names)
    process_pbs_file_message_end
  end
end #of module Compiler

class NPCTrainer < Trainer
  attr_accessor :items
  attr_accessor :lose_text
  attr_accessor :win_text
  attr_accessor :gimmick #by low

  def initialize(name, trainer_type)
    super
    @items     = []
    @lose_text = nil
    @win_text  = nil
    @gimmick   = nil #by low
  end
end #of NPCTrainer < Trainer

class Battle
  def pbEndPrimordialWeather
    oldWeather = @field.weather
=begin
    # End Primordial Sea, Desolate Land, Delta Stream
or dont
    case @field.weather
    when :HarshSun
      if !pbCheckGlobalAbility(:DESOLATELAND)
        @field.weather = :None
        pbDisplay("The harsh sunlight faded!")
      end
    when :HeavyRain
      if !pbCheckGlobalAbility(:PRIMORDIALSEA)
        @field.weather = :None
        pbDisplay("The heavy rain has lifted!")
      end
    when :StrongWinds
      if !pbCheckGlobalAbility(:DELTASTREAM)
        @field.weather = :None
        pbDisplay("The mysterious air current has dissipated!")
      end
    end
=end
    if @field.weather != oldWeather
      # Check for form changes caused by the weather changing
      allBattlers.each { |b| b.pbCheckFormOnWeatherChange }
      # Start up the default weather
      pbStartWeather(nil, @field.defaultWeather) if @field.defaultWeather != :None
    end
  end
	
  def pbStartWeatherAbility(new_weather, battler, ignore_primal = false, presage = false)
    #~ return if !ignore_primal && [:HarshSun, :HeavyRain, :StrongWinds].include?(@field.weather)
		return if @field.weather == :HarshSun  && new_weather == :Sun
		return if @field.weather == :HeavyRain && new_weather == :Rain
    return if @field.weather == new_weather
    pbShowAbilitySplash(battler)
    if !Scene::USE_ABILITY_SPLASH
      pbDisplay(_INTL("{1}'s {2} activated!", battler.pbThis, battler.abilityName))
    end
		@field.presageBackup = [@field.weather, (@field.weatherDuration - 1), @field.abilityWeather] if presage && (@field.weatherDuration - 1) > 0
		@field.abilityWeather = true
    fixed_duration = false
    fixed_duration = true if (Settings::FIXED_DURATION_WEATHER_FROM_ABILITY && !$game_switches[OLDSCHOOLBATTLE]) &&
                             ![:HarshSun, :HeavyRain, :StrongWinds].include?(new_weather)
    pbStartWeather(battler, new_weather, fixed_duration, true, presage)
    # NOTE: The ability splash is hidden again in def pbStartWeather.
  end
	
  def pbStartWeather(user, newWeather, fixedDuration = false, showAnim = true, presage = false, presagenum = 0)
    return if @field.weather == newWeather
    @field.weather = newWeather
    duration = (fixedDuration) ? 5 : -1
    if duration > 0 && user && user.itemActive? && !user.hasActiveAbility?(:FREEZEOVER) #by low
      duration = Battle::ItemEffects.triggerWeatherExtender(user.item, @field.weather,duration, user, self)
    end
		if duration > 0 && @field.defaultWeather != :None #by low
			duration = (duration / 3).floor
			duration = 2 if duration >= 1 # at least a turn
			duration = 1 if [:HarshSun, :HeavyRain, :StrongWinds, :ShadowSky].include?(@field.defaultWeather)
		end
		duration = presagenum if presagenum > 0 && user.nil?
		duration = 1 if presage
    @field.weatherDuration = duration
    weather_data = GameData::BattleWeather.try_get(@field.weather)
    pbCommonAnimation(weather_data.animation) if showAnim && weather_data
    pbHideAbilitySplash(user) if user
		#~ echo ("\nWas this "+@field.weather.to_s+" set by an ability?        "+@field.abilityWeather.to_s+"\n")
    case @field.weather
    when :Sun         then pbDisplay(_INTL("The sunlight turned harsh!"))
    when :Rain        then pbDisplay(_INTL("It started to rain!"))
    when :Sandstorm   then pbDisplay(_INTL("A sandstorm brewed!"))
    when :Hail        then pbDisplay(_INTL("It started to hail!"))
    when :HarshSun    then pbDisplay(_INTL("The sunlight turned extremely harsh!"))
    when :HeavyRain   then pbDisplay(_INTL("A heavy rain began to fall!"))
    when :StrongWinds then pbDisplay(_INTL("Mysterious strong winds are protecting Flying-type Pokémon!"))
    when :ShadowSky   then pbDisplay(_INTL("A shadow sky appeared!"))
    when :None				then pbDisplay(_INTL("The sky was cleared!"))
    end
    # Check for end of primordial weather, and weather-triggered form changes
    allBattlers.each { |b| b.pbCheckFormOnWeatherChange }
    pbEndPrimordialWeather
  end

  def pbStartTerrain(user, newTerrain, fixedDuration = true, setByAbility = false)
    return if @field.terrain == newTerrain
    @field.terrain = newTerrain
		@field.abilityTerrain = (setByAbility) ? true : false
    duration = (fixedDuration) ? 5 : -1
    if duration > 0 && user && user.itemActive?
      duration = Battle::ItemEffects.triggerTerrainExtender(user.item, newTerrain,duration, user, self)
    end
		if duration > 0 && @field.defaultTerrain != :None #by low
			duration = (duration / 3).floor
			duration = 2 if duration >= 1 # at least a turn
		end
    @field.terrainDuration = duration
    terrain_data = GameData::BattleTerrain.try_get(@field.terrain)
    pbCommonAnimation(terrain_data.animation) if terrain_data
    pbHideAbilitySplash(user) if user
    case @field.terrain
    when :Electric
      pbDisplay(_INTL("An electric current runs across the battlefield!"))
    when :Grassy
      pbDisplay(_INTL("Grass grew to cover the battlefield!"))
    when :Misty
      pbDisplay(_INTL("Mist swirled about the battlefield!"))
    when :Psychic
      pbDisplay(_INTL("The battlefield got weird!"))
    end
    # Check for abilities/items that trigger upon the terrain changing
    allBattlers.each { |b| b.pbAbilityOnTerrainChange }
    allBattlers.each { |b| b.pbItemTerrainStatBoostCheck }
  end
	
  def pbStartBattleCore
    # Set up the battlers on each side
    sendOuts = pbSetUpSides
    # Create all the sprites and play the battle intro animation
    @scene.pbStartBattle(self)
    # Show trainers on both sides sending out Pokémon
    pbStartBattleSendOut(sendOuts)
		# the great TGT list
		if trainerBattle?
			@opponent.each_with_index do |trainer, i|
				funstuff = trainer.gimmick.to_s
				
        gimmickString = funstuff.clone
        polishedarray = []
        
        loop do
          if !gimmickString.include?("_")
            #no more separators, so one item remains in the string
            #push the remainer of gimmickString into  polishedarray
            polishedarray.push(gimmickString)
            break
          end #if !gimmickString.include?("_")
					
          for c in 0...gimmickString.length
            if gimmickString[c] == "_"
              #found a separator
              separatorPosition = c
              
              #add findings to polishedArray
              polishedarray.push(gimmickString[0...c])
              
              #delete finding from array and start over
              #replace the finding with nothing, removing it from the string
              gimmickString[0,c+1]=""
              break
            end
          end #for c in 0...gimmickString.length
        end #loop do
				
				#~ print "#{polishedarray}"
				#~ castername = trainer.full_name
				#~ print "#{castername}"
				for i in 0...polishedarray.length
					case polishedarray[i]
					# weather
					when "Sun" 							then @field.weather = :Sun
					when "Rain" 						then @field.weather = :Rain
					when "Sandstorm" 				then @field.weather = :Sandstorm
					when "Hail" 						then @field.weather = :Hail
					when "HarshSun" 				then @field.weather = :HarshSun
					when "HeavyRain" 				then @field.weather = :HeavyRain
					when "StrongWinds"			then @field.weather = :StrongWinds
					when "ShadowSky" 				then @field.weather = :ShadowSky
					# terrains
					when "ElectricTerrain" 	then @field.terrain = :Electric
					when "GrassyTerrain" 		then @field.terrain = :Grassy
					when "MistyTerrain" 		then @field.terrain = :Misty
					when "PsychicTerrain" 	then @field.terrain = :Psychic
					# zones
					when "NormalZone"				then @field.typezone = :NORMAL
					when "FightingZone"			then @field.typezone = :FIGHTING
					when "PoisonZone"				then @field.typezone = :POISON
					when "GroundZone"				then @field.typezone = :GROUND
					when "FlyingZone"				then @field.typezone = :FLYING
					when "BugZone"					then @field.typezone = :BUG
					when "RockZone"					then @field.typezone = :ROCK
					when "GhostZone"				then @field.typezone = :GHOST
					when "IceZone"					then @field.typezone = :ICE
					when "DragonZone"				then @field.typezone = :DRAGON
					when "DarkZone"					then @field.typezone = :DARK
					when "SteelZone"				then @field.typezone = :STEEL
					when "FairyZone"				then @field.typezone = :FAIRY
					when "QMARKSZone"				then @field.typezone = :QMARKS
					# rooms
					when "TrickRoom"				then @field.effects[PBEffects::TrickRoom]   = 999
					when "WonderRoom"				then @field.effects[PBEffects::WonderRoom]  = 999
					when "MagicRoom"				then @field.effects[PBEffects::MagicRoom]   = 999
					# misc 
					# sides[1] == AI, sides[0] == Player
					when "Gravity"					then @field.effects[PBEffects::Gravity] 	  		= 999
					when "Tailwind"					then @sides[1].effects[PBEffects::Tailwind] 		= 999
					when "LightScreen"			then @sides[1].effects[PBEffects::LightScreen] 	= 999
					when "Reflect"					then @sides[1].effects[PBEffects::Reflect] 			= 999
					when "Mist"							then @sides[1].effects[PBEffects::Mist] 				= 999
					when "Safeguard"				then @sides[1].effects[PBEffects::Safeguard] 		= 999
					when "LuckyChant"				then @sides[1].effects[PBEffects::LuckyChant] 	= 999
					when "AuroraVeil"				then @sides[1].effects[PBEffects::AuroraVeil] 	= 999; @field.weather = :Hail
					when "StatDropImmunity"	then @sides[1].effects[PBEffects::StatDropImmunity] = true
					when "Spikes"						then @sides[0].effects[PBEffects::Spikes]  			+= 1
					when "ToxicSpikes"			then @sides[0].effects[PBEffects::ToxicSpikes]  += 1
					when "StickyWeb"				then @sides[0].effects[PBEffects::StickyWeb]  	+= 3 # = true
					when "StealthRock"			then @sides[0].effects[PBEffects::StealthRock]  = true
					end
				end
			end
		end
    # Weather announcement
    weather_data = GameData::BattleWeather.try_get(@field.weather)
    pbCommonAnimation(weather_data.animation) if weather_data
		if @field.weather != :None
			@field.defaultWeather = @field.weather
			@field.weatherDuration = -1
		end
    case @field.weather
    when :Sun         then pbDisplay(_INTL("The sunlight is strong."))
    when :Rain        then pbDisplay(_INTL("It is raining."))
    when :Sandstorm   then pbDisplay(_INTL("A sandstorm is raging."))
    when :Hail        then pbDisplay(_INTL("Hail is falling."))
    when :HarshSun    then pbDisplay(_INTL("The sunlight is extremely harsh."))
    when :HeavyRain   then pbDisplay(_INTL("It is raining heavily."))
    when :StrongWinds then pbDisplay(_INTL("The wind is strong."))
    when :ShadowSky   then pbDisplay(_INTL("The sky is shadowy."))
    end
    # Terrain announcement
    terrain_data = GameData::BattleTerrain.try_get(@field.terrain)
    pbCommonAnimation(terrain_data.animation) if terrain_data
		if @field.terrain != :None
			@field.defaultTerrain = @field.terrain
			@field.terrainDuration = -1
		end
    case @field.terrain
    when :Electric
      pbDisplay(_INTL("An electric current runs across the battlefield!"))
    when :Grassy
      pbDisplay(_INTL("Grass is covering the battlefield!"))
    when :Misty
      pbDisplay(_INTL("Mist swirls about the battlefield!"))
    when :Psychic
      pbDisplay(_INTL("The battlefield is weird!"))
    end
    # Zones announcement
    if @field.typezone != :None && GameData::Type.exists?(@field.typezone)
			typeofzone = GameData::Type.get(@field.typezone).name
			pbDisplay(_INTL("A {1} Zone was summoned, it will power up {1}-type attacks!",typeofzone))
		end
		@sides[1].effects[PBEffects::Reflect] 		= 999 if $game_variables[MASTERMODEVARS][1]==true
		@sides[1].effects[PBEffects::LightScreen] = 999 if $game_variables[MASTERMODEVARS][2]==true
		@sides[1].effects[PBEffects::StatDropImmunity] = true if $game_variables[MASTERMODEVARS][11]==true
		# Room effects / general effects announcement
		pbDisplay(_INTL("The dimensions are twisted!")) if @field.effects[PBEffects::TrickRoom] > 0
		pbDisplay(_INTL("A bizzare area in which the Defense stats are swapped has appeared!")) if @field.effects[PBEffects::WonderRoom] > 0
		pbDisplay(_INTL("A bizzare area in which items have no effect has appeared!"))if @field.effects[PBEffects::MagicRoom] > 0
		pbDisplay(_INTL("Gravity intensified!")) if @field.effects[PBEffects::Gravity] > 0
		pbDisplay(_INTL("A Tailwind blows from behind the enemy's team!")) if @sides[1].effects[PBEffects::Tailwind] > 0
		pbDisplay(_INTL("A wall of light specially protects the enemy's team!"))  if @sides[1].effects[PBEffects::LightScreen] > 0
		pbDisplay(_INTL("A wall of light physically protects the enemy's team!")) if @sides[1].effects[PBEffects::Reflect] > 0
		pbDisplay(_INTL("A beautiful aurora protects the enemy's team!")) if @sides[1].effects[PBEffects::AuroraVeil] > 0
		pbDisplay(_INTL("The enemy's team is shrouded in mist!")) if @sides[1].effects[PBEffects::Mist] > 0
		pbDisplay(_INTL("The enemy's team is cloaked in a mystical veil!")) if @sides[1].effects[PBEffects::Safeguard] > 0
		pbDisplay(_INTL("The opponent chants an incantation towards the sky!")) if @sides[1].effects[PBEffects::LuckyChant] > 0
		pbDisplay(_INTL("A mystical enchant protects the enemy from all stat drops!")) if @sides[1].effects[PBEffects::StatDropImmunity]
		if @sides[0].effects[PBEffects::Spikes] > 0 || @sides[0].effects[PBEffects::ToxicSpikes] > 0 ||
			 @sides[0].effects[PBEffects::StickyWeb] > 0 || @sides[0].effects[PBEffects::StealthRock]
			pbDisplay(_INTL("Hazards are scattered all around your side of the field!"))
		end
    #~ print "#{@field.defaultWeather},#{@field.defaultTerrain}"
		#~ print "#{@field.weatherDuration},#{@field.terrainDuration}"
		#~ print battle.turnCount
		# Abilities upon entering battle
    pbOnAllBattlersEnteringBattle
    # Main battle loop
    pbBattleLoop
  end
end #of Battle

################################################################################
# move edits
################################################################################

# trick room ###################################################################
class Battle::Move::StartSlowerBattlersActFirst < Battle::Move
  def pbMoveFailed?(user, targets)
    if @battle.field.effects[PBEffects::TrickRoom] > 100
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
	
  def pbEffectGeneral(user)
    if @battle.field.effects[PBEffects::TrickRoom] > 0
      @battle.field.effects[PBEffects::TrickRoom] = 0
      @battle.pbDisplay(_INTL("{1} reverted the dimensions!", user.pbThis))
    else
      @battle.field.effects[PBEffects::TrickRoom] = 5
      @battle.field.effects[PBEffects::TrickRoom] += 2 if user.hasActiveAbility?(:TRICKSTER)
      @battle.pbDisplay(_INTL("{1} twisted the dimensions!", user.pbThis))
    end
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    return if @battle.field.effects[PBEffects::TrickRoom] > 0   # No animation
    super
  end
end

# wonder room ##################################################################
class Battle::Move::StartSwapAllBattlersBaseDefensiveStats < Battle::Move
  def pbMoveFailed?(user, targets)
    if @battle.field.effects[PBEffects::WonderRoom] > 100
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
	
  def pbEffectGeneral(user)
    if @battle.field.effects[PBEffects::WonderRoom] > 0
      @battle.field.effects[PBEffects::WonderRoom] = 0
      @battle.pbDisplay(_INTL("Wonder Room wore off, and the Defense and Sp. Def stats returned to normal!"))
    else
      @battle.field.effects[PBEffects::WonderRoom] = 5
      @battle.field.effects[PBEffects::WonderRoom] += 2 if user.hasActiveAbility?(:TRICKSTER)
      @battle.pbDisplay(_INTL("It created a bizarre area in which the Defense and Sp. Def stats are swapped!"))
    end
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    return if @battle.field.effects[PBEffects::WonderRoom] > 0   # No animation
    super
  end
end

# magic room ###################################################################
class Battle::Move::StartNegateHeldItems < Battle::Move
  def pbMoveFailed?(user, targets)
    if @battle.field.effects[PBEffects::MagicRoom] > 100
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
	
  def pbEffectGeneral(user)
    if @battle.field.effects[PBEffects::MagicRoom] > 0
      @battle.field.effects[PBEffects::MagicRoom] = 0
      @battle.pbDisplay(_INTL("The area returned to normal!"))
    else
      @battle.field.effects[PBEffects::MagicRoom] = 5
      @battle.field.effects[PBEffects::MagicRoom] += 2 if user.hasActiveAbility?(:TRICKSTER)
      @battle.pbDisplay(_INTL("It created a bizarre area in which Pokémon's held items lose their effects!"))
    end
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    return if @battle.field.effects[PBEffects::MagicRoom] > 0   # No animation
    super
  end
end

# generic setup weather, took out the primal weather immunity to other weather seutups
# made primal weather replace this after a single turn, though
class Battle::Move::WeatherMove < Battle::Move
  def initialize(battle, move)
    super
    @weatherType = :None
  end

  def pbMoveFailed?(user, targets)
    if @battle.field.weather == @weatherType ||
			(@battle.field.weather == :HarshSun  && @weatherType == :Sun) ||
			(@battle.field.weather == :HeavyRain && @weatherType == :Rain)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
		@battle.field.abilityWeather = false #by low
    @battle.pbStartWeather(user, @weatherType, true, false)
  end
end

# ==============================================================================
# Modified Compiler - to include Gimmick in trainers.txt
# ==============================================================================
=begin #pushed to DemICE_General
module Compiler
  module_function
  #=============================================================================
  # Compile individual trainer data
  #=============================================================================
  def compile_trainers(path = "PBS/trainers.txt")
    compile_pbs_file_message_start(path)
    GameData::Trainer::DATA.clear
    schema = GameData::Trainer::SCHEMA
    max_level = GameData::GrowthRate.max_level
    trainer_names      = []
    trainer_lose_texts = []
    trainer_hash       = nil
    current_pkmn       = nil
    # Read each line of trainers.txt at a time and compile it as a trainer property
    idx = 0
    pbCompilerEachPreppedLine(path) { |line, line_no|
      echo "." if idx % 50 == 0
      idx += 1
      Graphics.update if idx % 250 == 0
      if line[/^\s*\[\s*(.+)\s*\]\s*$/]
        # New section [trainer_type, name] or [trainer_type, name, version]
        if trainer_hash
          if !current_pkmn
            raise _INTL("Started new trainer while previous trainer has no Pokémon.\r\n{1}", FileLineData.linereport)
          end
          # Add trainer's data to records
          trainer_hash[:id] = [trainer_hash[:trainer_type], trainer_hash[:name], trainer_hash[:version]]
          GameData::Trainer.register(trainer_hash)
        end
        line_data = pbGetCsvRecord($~[1], line_no, [0, "esU", :TrainerType])
        # Construct trainer hash
        trainer_hash = {
          :trainer_type => line_data[0],
          :name         => line_data[1],
          :version      => line_data[2] || 0,
          :pokemon      => []
        }
        current_pkmn = nil
        trainer_names.push(trainer_hash[:name])
      elsif line[/^\s*(\w+)\s*=\s*(.*)$/]
        # XXX=YYY lines
        if !trainer_hash
          raise _INTL("Expected a section at the beginning of the file.\r\n{1}", FileLineData.linereport)
        end
        property_name = $~[1]
        line_schema = schema[property_name]
        next if !line_schema
        property_value = pbGetCsvRecord($~[2], line_no, line_schema)
        # Error checking in XXX=YYY lines
        case property_name
        when "Pokemon"
          if property_value[1] > max_level
            raise _INTL("Bad level: {1} (must be 1-{2}).\r\n{3}", property_value[1], max_level, FileLineData.linereport)
          end
        when "Name"
          if property_value.length > Pokemon::MAX_NAME_SIZE
            raise _INTL("Bad nickname: {1} (must be 1-{2} characters).\r\n{3}", property_value, Pokemon::MAX_NAME_SIZE, FileLineData.linereport)
          end
        when "Moves"
          property_value.uniq!
        when "IV"
          property_value.each do |iv|
            next if iv <= Pokemon::IV_STAT_LIMIT
            raise _INTL("Bad IV: {1} (must be 0-{2}).\r\n{3}", iv, Pokemon::IV_STAT_LIMIT, FileLineData.linereport)
          end
        when "EV"
          property_value.each do |ev|
            next if ev <= Pokemon::EV_STAT_LIMIT
            raise _INTL("Bad EV: {1} (must be 0-{2}).\r\n{3}", ev, Pokemon::EV_STAT_LIMIT, FileLineData.linereport)
          end
          ev_total = 0
          GameData::Stat.each_main do |s|
            next if s.pbs_order < 0
            ev_total += (property_value[s.pbs_order] || property_value[0])
          end
          if ev_total > Pokemon::EV_LIMIT
            raise _INTL("Total EVs are greater than allowed ({1}).\r\n{2}", Pokemon::EV_LIMIT, FileLineData.linereport)
          end
        when "Happiness"
          if property_value > 255
            raise _INTL("Bad happiness: {1} (must be 0-255).\r\n{2}", property_value, FileLineData.linereport)
          end
        when "Ball"
          if !GameData::Item.get(property_value).is_poke_ball?
            raise _INTL("Value {1} isn't a defined Poké Ball.\r\n{2}", property_value, FileLineData.linereport)
          end
        end
        # Record XXX=YYY setting
        case property_name
        when "Items", "LoseText", "Gimmick" # added here because fsr TGT_Edits cant change this script #by low
          trainer_hash[line_schema[0]] = property_value
          trainer_lose_texts.push(property_value) if property_name == "LoseText"
        when "Pokemon"
          current_pkmn = {
            :species => property_value[0],
            :level   => property_value[1]
          }
          trainer_hash[line_schema[0]].push(current_pkmn)
        else
          if !current_pkmn
            raise _INTL("Pokémon hasn't been defined yet!\r\n{1}", FileLineData.linereport)
          end
          case property_name
          when "IV", "EV"
            value_hash = {}
            GameData::Stat.each_main do |s|
              next if s.pbs_order < 0
              value_hash[s.id] = property_value[s.pbs_order] || property_value[0]
            end
            current_pkmn[line_schema[0]] = value_hash
          else
            current_pkmn[line_schema[0]] = property_value
          end
        end
      end
    }
    # Add last trainer's data to records
    if trainer_hash
      if !current_pkmn
        raise _INTL("End of file reached while last trainer has no Pokémon.\r\n{1}", FileLineData.linereport)
      end
      trainer_hash[:id] = [trainer_hash[:trainer_type], trainer_hash[:name], trainer_hash[:version]]
      GameData::Trainer.register(trainer_hash)
    end
    # Save all data
    GameData::Trainer.save
    MessageTypes.setMessagesAsHash(MessageTypes::TrainerNames, trainer_names)
    MessageTypes.setMessagesAsHash(MessageTypes::TrainerLoseText, trainer_lose_texts)
    process_pbs_file_message_end
  end
  
  #=============================================================================
  # Compile battle animations
  #=============================================================================
  def compile_animations
    Console.echo_li _INTL("Compiling animations...")
    begin
      pbanims = load_data("Data/PkmnAnimations.rxdata")
    rescue
      pbanims = PBAnimations.new
    end
    changed = false
    move2anim = [{}, {}]
=begin
    anims = load_data("Data/Animations.rxdata")
    for anim in anims
      next if !anim || anim.frames.length==1
      found = false
      for i in 0...pbanims.length
        if pbanims[i] && pbanims[i].id==anim.id
          found = true if pbanims[i].array.length>1
          break
        end
      end
      pbanims[anim.id] = pbConvertRPGAnimation(anim) if !found
    end
#~ =end
    pbanims.length.times do |i|
      next if !pbanims[i]
      if pbanims[i].name[/^OppMove\:\s*(.*)$/]
        if GameData::Move.exists?($~[1])
          moveid = GameData::Move.get($~[1]).id
          changed = true if !move2anim[0][moveid] || move2anim[1][moveid] != i
          move2anim[1][moveid] = i
        end
      elsif pbanims[i].name[/^Move\:\s*(.*)$/]
        if GameData::Move.exists?($~[1])
          moveid = GameData::Move.get($~[1]).id
          changed = true if !move2anim[0][moveid] || move2anim[0][moveid] != i
          move2anim[0][moveid] = i
        end
      end
    end
    if changed
      save_data(move2anim, "Data/move2anim.dat")
      save_data(pbanims, "Data/PkmnAnimations.rxdata")
    end
    process_pbs_file_message_end
  end
end
=end