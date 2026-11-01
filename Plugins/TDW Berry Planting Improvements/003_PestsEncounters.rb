#===============================================================================
# GameData
#===============================================================================

GameData::EncounterType.register({
    :id             => :BerryPlantPest,
    :type           => :berrypest
})

GameData::EncounterType.register({
    :id             => :BerryPlantDefault, #This is just a placeholder to prevent crashes
    :type           => :berrypest
})

GameData::EncounterType.register({
    :id             => :BerryPlantPestRed,
    :type           => :berrypest
})

GameData::EncounterType.register({
    :id             => :BerryPlantPestYellow,
    :type           => :berrypest
})

GameData::EncounterType.register({
    :id             => :BerryPlantPestGreen,
    :type           => :berrypest
})

GameData::EncounterType.register({
    :id             => :BerryPlantPestBlue,
    :type           => :berrypest
})

GameData::EncounterType.register({
    :id             => :BerryPlantPestPurple,
    :type           => :berrypest
})

GameData::EncounterType.register({
    :id             => :BerryPlantPestPink,
    :type           => :berrypest
})

#===============================================================================
# Handling
#===============================================================================

def pbBerryPlantPestRandomEncounter(berry)
    return false if $game_system.encounter_disabled
    enc_type = nil
    if PluginManager.installed?("TDW Berry Core and Dex") && berry
        berryColor = GameData::BerryData.get(berry).color
        color_enc = ("BerryPlantPest" + berryColor.to_s).to_sym
        enc_type = color_enc if $PokemonEncounters.has_encounter_type?(color_enc)
    end
    enc_type = :BerryPlantPest if !enc_type && $PokemonEncounters.has_encounter_type?(:BerryPlantPest)
    enc_type = :BerryPlantDefault if !enc_type
    $stats.berry_pest_battles ||= 0
    $stats.berry_pest_battles += 1
    return pbEncounter(enc_type)
end

class PokemonEncounters
    alias tdw_berry_improvements_choose_wild_pokemon choose_wild_pokemon
    def choose_wild_pokemon(enc_type, chance_rolls = 1)
        if enc_type == :BerryPlantDefault
            choose_wild_pokemon_berry_pest_default
        else
            tdw_berry_improvements_choose_wild_pokemon(enc_type, chance_rolls)
        end
    end

    def choose_wild_pokemon_berry_pest_default
        enc_list = Settings::BERRY_PEST_DEFAULT_ENCOUNTERS
        return nil if !enc_list || enc_list.length == 0
        berry = pbMapInterpreter.getVariable.berry_id
        plant_color = berry ? GameData::BerryData.get(berry).color : nil
        enc_list.each_with_index { |enc, i|
            next if enc.length < 5
            enc[0] += 40 if plant_color && enc[4] == plant_color
            enc.pop
        }
        # Static/Magnet Pull prefer wild encounters of certain types, if possible.
        # If they activate, they remove all Pokémon from the encounter table that do
        # not have the type they favor. If none have that type, nothing is changed.
        first_pkmn = $player.first_pokemon
        if first_pkmn
          favored_type = nil
          case first_pkmn.ability_id
          when :FLASHFIRE
            favored_type = :FIRE if Settings::MORE_ABILITIES_AFFECT_WILD_ENCOUNTERS &&
                                    GameData::Type.exists?(:FIRE) && rand(100) < 50
          when :HARVEST
            favored_type = :GRASS if Settings::MORE_ABILITIES_AFFECT_WILD_ENCOUNTERS &&
                                     GameData::Type.exists?(:GRASS) && rand(100) < 50
          when :LIGHTNINGROD
            favored_type = :ELECTRIC if Settings::MORE_ABILITIES_AFFECT_WILD_ENCOUNTERS &&
                                        GameData::Type.exists?(:ELECTRIC) && rand(100) < 50
          when :MAGNETPULL
            favored_type = :STEEL if GameData::Type.exists?(:STEEL) && rand(100) < 50
          when :STATIC
            favored_type = :ELECTRIC if GameData::Type.exists?(:ELECTRIC) && rand(100) < 50
          when :STORMDRAIN
            favored_type = :WATER if Settings::MORE_ABILITIES_AFFECT_WILD_ENCOUNTERS &&
                                     GameData::Type.exists?(:WATER) && rand(100) < 50
          end
          if favored_type
            new_enc_list = []
            enc_list.each do |enc|
              species_data = GameData::Species.get(enc[1])
              new_enc_list.push(enc) if species_data.types.include?(favored_type)
            end
            enc_list = new_enc_list if new_enc_list.length > 0
          end
        end
        enc_list.sort! { |a, b| b[0] <=> a[0] }   # Highest probability first
        # Calculate the total probability value
        chance_total = 0
        enc_list.each { |a| chance_total += a[0] }
        # Choose a random entry in the encounter table based on entry probabilities
        rnd = 0
        1.times do
          r = rand(chance_total)
          rnd = r if r > rnd   # Prefer rarer entries if rolling repeatedly
        end
        encounter = nil
        enc_list.each do |enc|
          rnd -= enc[0]
          next if rnd >= 0
          encounter = enc
          break
        end
        # Get the chosen species and level
        level = rand(encounter[2]..encounter[3])
        # Some abilities alter the level of the wild Pokémon
        if first_pkmn
         case first_pkmn.ability_id
         when :HUSTLE, :PRESSURE, :VITALSPIRIT
           level = encounter[3] if rand(100) < 50   # Highest possible level
         end
        end
        # Black Flute and White Flute alter the level of the wild Pokémon
        if Essentials::VERSION.include?("21")
            if $PokemonMap.lower_level_wild_pokemon
                level = [level - rand(1..4), 1].max
              elsif $PokemonMap.higher_level_wild_pokemon
                level = [level + rand(1..4), GameData::GrowthRate.max_level].min
            end
        else
            if Settings::FLUTES_CHANGE_WILD_ENCOUNTER_LEVELS
                if $PokemonMap.blackFluteUsed
                level = [level + rand(1..4), GameData::GrowthRate.max_level].min
                elsif $PokemonMap.whiteFluteUsed
                level = [level - rand(1..4), 1].max
                end
            end
        end
        # Return [species, level]
        return [encounter[1], level]
    end

end