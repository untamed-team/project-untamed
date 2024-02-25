#===============================================================================
# BerryPots
#===============================================================================

if PluginManager.installed?("BerryPots for Essentials v20") || PluginManager.installed?("BerryPots for Essentials")
    class ItemBerryPots_Scene
        def pbBerryPlantWater(berry_plant,idx)
            return if !@item
            return if Settings::BERRY_PREVENT_WATERING_IF_MAXED && berry_plant.moisture_level == 100
            if Settings::BERRY_WATERING_MUST_FILL
                commands = [_INTL("Yes") + " " + pbGetWateringCanLevel(@item,true),_INTL("No")]
                cmd = pbMessage(_INTL("Want to sprinkle some water with the {1}?",
                        GameData::Item.get(@item).name), commands, -1)
                return if cmd < 0 || cmd == commands.length - 1
                berry_plant.water
                $PokemonGlobal.watering_can_levels[@item] -= 1 unless $PokemonGlobal.watering_can_levels[@item] == "Full"
                pbWateringAnim(idx)
                pbUpdateSoilSprite(berry_plant,idx)
                pbMessage(_INTL("{1} watered the plant.\\wtnp[40]", $player.name))
                if Settings::NEW_BERRY_PLANTS
                    pbMessage(_INTL("There! All happy!"))
                else
                    pbMessage(_INTL("The plant seemed to be delighted."))
                end
                pbMessage(_INTL("The {1} is now empty.",GameData::Item.get(@item).name)) if Settings::BERRY_WATERING_MUST_FILL && @item.is_a?(Integer) && 
                        pbGetWateringCanLevel(@item) <= 0
            else
                return if !pbConfirmMessage(_INTL("Want to sprinkle some water with the {1}?",
                                    GameData::Item.get(@item).name))
                berry_plant.water
                pbWateringAnim(idx)
                pbUpdateSoilSprite(berry_plant,idx)
                pbMessage(_INTL("{1} watered the plant.\\wtnp[40]", $player.name))
                if Settings::NEW_BERRY_PLANTS
                    pbMessage(_INTL("There! All happy!"))
                else
                    pbMessage(_INTL("The plant seemed to be delighted."))
                end
            end
        end

        alias tdw_pots_start_scene pbStartScene
        def pbStartScene
            tdw_pots_start_scene
            if Settings::BERRY_WATERING_MUST_FILL
                @sprites["waterbg"] = IconSprite.new(390,172,@viewport)
                @sprites["watergauge"] = IconSprite.new(394,176,@viewport)
                if Essentials::VERSION.include?("21")
                    @sprites["waterbg"].setBitmap(_INTL("Graphics/UI/Berry Improvements/potsWaterBg"))
                    @sprites["watergauge"].setBitmap(_INTL("Graphics/UI/Berry Improvements/potsWaterGauge"))
                else
                    @sprites["waterbg"].setBitmap(_INTL("Graphics/Pictures/Berry Improvements/potsWaterBg"))
                    @sprites["watergauge"].setBitmap(_INTL("Graphics/Pictures/Berry Improvements/potsWaterGauge"))
                end
                @sprites["watergauge"].src_rect = Rect.new(0,0,@sprites["watergauge"].bitmap.width,@sprites["watergauge"].bitmap.height)
                @sprites["waterbg"].visible = false
                @sprites["watergauge"].visible = false
            end
        end

        alias tdw_pots_update pbUpdate
        def pbUpdate
            tdw_pots_update
            if Settings::BERRY_WATERING_MUST_FILL && @can_id && @can_temp[@can_id] && @sprites["watergauge"]
                @sprites["waterbg"].visible = @sprites["watergauge"].visible = !@can_temp.empty?
                $PokemonGlobal.initializeWateringCanLevels if !$PokemonGlobal.watering_can_levels
                can = @can_temp[@can_id]
                percent = (pbGetWateringCanMax(can) == "Full") ? 1.0 : $PokemonGlobal.watering_can_levels[can] / pbGetWateringCanMax(can).to_f
                height = (@sprites["watergauge"].bitmap.height*percent).ceil
                @sprites["watergauge"].src_rect = Rect.new(0,@sprites["watergauge"].bitmap.height-height,
                    @sprites["watergauge"].bitmap.width,height)
                    @sprites["watergauge"].y = 176 + @sprites["watergauge"].bitmap.height-height
            end
        end
    end
end