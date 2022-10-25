#===============================================================================
# Revamps base Essentials code related to NPC Trainers to allow for plugin 
# compatibility.
#===============================================================================


#-------------------------------------------------------------------------------
# Rewrites Trainer data to consider plugin properties.
#-------------------------------------------------------------------------------
module GameData
  class Trainer
    SCHEMA["Ace"]        = [:trainer_ace, "b"]
    SCHEMA["Focus"]      = [:focus,       "u"] # Placeholder
    SCHEMA["Birthsign"]  = [:birthsign,   "u"] # Placeholder
    SCHEMA["DynamaxLvl"] = [:dynamax_lvl, "u"]
    SCHEMA["Gigantamax"] = [:gmaxfactor,  "b"]
	SCHEMA["Mastery"]    = [:mastery,     "b"]
    
    def to_trainer
      tr_name = self.name
      Settings::RIVAL_NAMES.each do |rival|
        next if rival[0] != @trainer_type || !$game_variables[rival[1]].is_a?(String)
        tr_name = $game_variables[rival[1]]
        break
      end
      trainer = NPCTrainer.new(tr_name, @trainer_type)
      trainer.id        = $player.make_foreign_ID
      trainer.items     = @items.clone
      trainer.lose_text = self.lose_text
      @pokemon.each do |pkmn_data|
        species = GameData::Species.get(pkmn_data[:species]).species
        pkmn = Pokemon.new(species, pkmn_data[:level], trainer, false)
        trainer.party.push(pkmn)
        if pkmn_data[:form]
          pkmn.forced_form = pkmn_data[:form] if MultipleForms.hasFunction?(species, "getForm")
          pkmn.form_simple = pkmn_data[:form]
        end
        pkmn.item = pkmn_data[:item]
        if pkmn_data[:moves] && pkmn_data[:moves].length > 0
          pkmn_data[:moves].each { |move| pkmn.learn_move(move) }
        else
          pkmn.reset_moves
        end
        pkmn.ability_index = pkmn_data[:ability_index] || 0
        pkmn.ability = pkmn_data[:ability]
        pkmn.gender = pkmn_data[:gender] || ((trainer.male?) ? 0 : 1)
        pkmn.shiny = (pkmn_data[:shininess]) ? true : false
        pkmn.super_shiny = (pkmn_data[:super_shininess]) ? true : false
        if pkmn_data[:nature]
          pkmn.nature = pkmn_data[:nature]
        else
          species_num = GameData::Species.keys.index(species) || 1
          tr_type_num = GameData::TrainerType.keys.index(@trainer_type) || 1
          idx = (species_num + tr_type_num) % GameData::Nature.count
          pkmn.nature = GameData::Nature.get(GameData::Nature.keys[idx]).id
        end
        GameData::Stat.each_main do |s|
          if pkmn_data[:iv]
            pkmn.iv[s.id] = pkmn_data[:iv][s.id]
          else
            pkmn.iv[s.id] = [pkmn_data[:level] / 2, Pokemon::IV_STAT_LIMIT].min
          end
          if pkmn_data[:ev]
            pkmn.ev[s.id] = pkmn_data[:ev][s.id]
          else
            pkmn.ev[s.id] = [pkmn_data[:level] * 3 / 2, Pokemon::EV_LIMIT / 6].min
          end
        end
        pkmn.happiness = pkmn_data[:happiness] if pkmn_data[:happiness]
        pkmn.name = pkmn_data[:name] if pkmn_data[:name] && !pkmn_data[:name].empty?
        #-----------------------------------------------------------------------
        # Sets the default values for plugin properties on trainer's Pokemon.
        #-----------------------------------------------------------------------
        pkmn.ace = (pkmn_data[:trainer_ace]) ? true : false
        if PluginManager.installed?("Focus Meter System")
          pkmn.focus_style = pkmn_data[:focus] || Settings::FOCUS_STYLE_DEFAULT
        end
        if PluginManager.installed?("Pokémon Birthsigns")
          pkmn.birthsign = pkmn_data[:birthsign] || :VOID
        end
        if PluginManager.installed?("ZUD Mechanics")
          pkmn.dynamax_lvl = pkmn_data[:dynamax_lvl]
          pkmn.gmax_factor = (pkmn_data[:gmaxfactor]) ? true : false
        end
		if PluginManager.installed?("PLA Battle Styles")
		  if pkmn_data[:mastery]
			pkmn.moves.each { |m| m.mastered = m.canMaster? }
          end
        end
        #-----------------------------------------------------------------------
        if pkmn_data[:shadowness]
          pkmn.makeShadow
          pkmn.update_shadow_moves(true)
          pkmn.shiny = false
          #---------------------------------------------------------------------
          # Sets base values for plugin properties on shadow Pokemon.
          #---------------------------------------------------------------------
          if PluginManager.installed?("Focus Meter System")
            pkmn.focus_style = :None
          end
          if PluginManager.installed?("Pokémon Birthsigns")
            pkmn.birthsign = :VOID
          end
          if PluginManager.installed?("ZUD Mechanics")
            pkmn.dynamax_lvl = 0
            pkmn.gmax_factor = false
          end
		  if PluginManager.installed?("PLA Battle Styles")
			pkmn.moves.each { |m| m.mastered = false }
          end
          #---------------------------------------------------------------------
        end
        pkmn.poke_ball = pkmn_data[:poke_ball] if pkmn_data[:poke_ball]
        pkmn.calc_stats
      end
      return trainer
    end
  end
end


#-------------------------------------------------------------------------------
# Rewrites in-game Trainer editor to consider plugin properties.
#-------------------------------------------------------------------------------
module TrainerPokemonProperty
  def self.set(settingname, initsetting)
    initsetting = { :species => nil, :level => 10 } if !initsetting
    oldsetting = [
      initsetting[:species],
      initsetting[:level],
      initsetting[:name],
      initsetting[:form],
      initsetting[:gender],
      initsetting[:shininess],
      initsetting[:super_shininess],
      initsetting[:shadowness]
    ]
    Pokemon::MAX_MOVES.times do |i|
      oldsetting.push((initsetting[:moves]) ? initsetting[:moves][i] : nil)
    end
    oldsetting.concat([
      initsetting[:ability],
      initsetting[:ability_index],
      initsetting[:item],
      initsetting[:nature],
      initsetting[:iv],
      initsetting[:ev],
      initsetting[:happiness],
      initsetting[:poke_ball],
      initsetting[:trainer_ace],
      initsetting[:focus],
      initsetting[:birthsign],
      initsetting[:dynamax_lvl], 
      initsetting[:gmaxfactor],
	  initsetting[:mastery]
    ])
    max_level = GameData::GrowthRate.max_level
    pkmn_properties = [
      [_INTL("Species"),       SpeciesProperty,                         _INTL("Species of the Pokémon.")],
      [_INTL("Level"),         NonzeroLimitProperty.new(max_level),     _INTL("Level of the Pokémon (1-{1}).", max_level)],
      [_INTL("Name"),          StringProperty,                          _INTL("Name of the Pokémon.")],
      [_INTL("Form"),          LimitProperty2.new(999),                 _INTL("Form of the Pokémon.")],
      [_INTL("Gender"),        GenderProperty,                          _INTL("Gender of the Pokémon.")],
      [_INTL("Shiny"),         BooleanProperty2,                        _INTL("If set to true, the Pokémon is a different-colored Pokémon.")],
      [_INTL("SuperShiny"),    BooleanProperty2,                        _INTL("Whether the Pokémon is super shiny (shiny with a special shininess animation).")],
      [_INTL("Shadow"),        BooleanProperty2,                        _INTL("If set to true, the Pokémon is a Shadow Pokémon.")]
    ]
    Pokemon::MAX_MOVES.times do |i|
      pkmn_properties.push([_INTL("Move {1}", i + 1),
                            MovePropertyForSpecies.new(oldsetting), _INTL("A move known by the Pokémon. Leave all moves blank (use Z key to delete) for a wild moveset.")])
    end
    #---------------------------------------------------------------------------
    # Plugin-specific properties.
    #---------------------------------------------------------------------------
    nil_prop = [_INTL("Plugin Property"), ReadOnlyProperty, _INTL("This property requires a certain plugin to be installed to set.")]
    # Focus Style
    if PluginManager.installed?("Focus Meter System")
      property_Focus = [_INTL("Focus"), GameDataProperty.new(:Focus), _INTL("Focus style of the Pokémon.")]
    else
      plugin_name = "\n[Focus Meter System]"
      property_Focus = [nil_prop[0], nil_prop[1], nil_prop[2] + plugin_name]
    end
    # Birthsign
    if PluginManager.installed?("Pokémon Birthsigns")
      property_Birthsign = [_INTL("Birthsign"), GameDataProperty.new(:Birthsign), _INTL("Birthsign of the Pokémon.")]
    else
      plugin_name = "\n[Pokémon Birthsigns]"
      property_Birthsign = [nil_prop[0], nil_prop[1], nil_prop[2] + plugin_name]
    end
    # Dynamax Level/G-Max Factor
    if PluginManager.installed?("ZUD Mechanics")
      property_DynamaxLvl = [_INTL("Dynamax Lvl"), LimitProperty2.new(10), _INTL("Dynamax level of the Pokémon (0-10).")]
      property_GmaxFactor = [_INTL("G-Max Factor"), BooleanProperty2, _INTL("If set to true, the Pokémon will have G-Max Factor.")]
    else
      plugin_name = "\n[ZUD Plugin]"
      property_DynamaxLvl = [nil_prop[0], nil_prop[1], nil_prop[2] + plugin_name]
      property_GmaxFactor = [nil_prop[0], nil_prop[1], nil_prop[2] + plugin_name]
    end
	# Move Mastery
    if PluginManager.installed?("PLA Battle Styles")
      property_Mastery = [_INTL("Mastery"), BooleanProperty2, _INTL("If set to true, the Pokémon's eligible moves will be mastered.")]
    else
      plugin_name = "\n[PLA Battle Styles]"
      property_Mastery = [nil_prop[0], nil_prop[1], nil_prop[2] + plugin_name]
    end
    #---------------------------------------------------------------------------
    pkmn_properties.concat(
      [[_INTL("Ability"),       AbilityProperty,                         _INTL("Ability of the Pokémon. Overrides the ability index.")],
       [_INTL("Ability index"), LimitProperty2.new(99),                  _INTL("Ability index. 0=first ability, 1=second ability, 2+=hidden ability.")],
       [_INTL("Held item"),     ItemProperty,                            _INTL("Item held by the Pokémon.")],
       [_INTL("Nature"),        GameDataProperty.new(:Nature),           _INTL("Nature of the Pokémon.")],
       [_INTL("IVs"),           IVsProperty.new(Pokemon::IV_STAT_LIMIT), _INTL("Individual values for each of the Pokémon's stats.")],
       [_INTL("EVs"),           EVsProperty.new(Pokemon::EV_STAT_LIMIT), _INTL("Effort values for each of the Pokémon's stats.")],
       [_INTL("Happiness"),     LimitProperty2.new(255),                 _INTL("Happiness of the Pokémon (0-255).")],
       [_INTL("Poké Ball"),     BallProperty.new(oldsetting),            _INTL("The kind of Poké Ball the Pokémon is kept in.")],
       [_INTL("Ace"),           BooleanProperty2,                        _INTL("Flags this Pokémon as this trainer's ace. Used by certain plugins below.")],
       property_Focus, property_Birthsign, property_DynamaxLvl, property_GmaxFactor, property_Mastery
    ])
    pbPropertyList(settingname, oldsetting, pkmn_properties, false)
    return nil if !oldsetting[0]
    ret = {
      :species         => oldsetting[0],
      :level           => oldsetting[1],
      :name            => oldsetting[2],
      :form            => oldsetting[3],
      :gender          => oldsetting[4],
      :shininess       => oldsetting[5],
      :super_shininess => oldsetting[6],
      :shadowness      => oldsetting[7],
      :ability         => oldsetting[8 + Pokemon::MAX_MOVES],
      :ability_index   => oldsetting[9 + Pokemon::MAX_MOVES],
      :item            => oldsetting[10 + Pokemon::MAX_MOVES],
      :nature          => oldsetting[11 + Pokemon::MAX_MOVES],
      :iv              => oldsetting[12 + Pokemon::MAX_MOVES],
      :ev              => oldsetting[13 + Pokemon::MAX_MOVES],
      :happiness       => oldsetting[14 + Pokemon::MAX_MOVES],
      :poke_ball       => oldsetting[15 + Pokemon::MAX_MOVES],
      :trainer_ace     => oldsetting[16 + Pokemon::MAX_MOVES],
      :focus           => oldsetting[17 + Pokemon::MAX_MOVES],
      :birthsign       => oldsetting[18 + Pokemon::MAX_MOVES],
      :dynamax_lvl     => oldsetting[19 + Pokemon::MAX_MOVES],
      :gmaxfactor      => oldsetting[20 + Pokemon::MAX_MOVES],
	  :mastery         => oldsetting[21 + Pokemon::MAX_MOVES]
    }
    moves = []
    Pokemon::MAX_MOVES.times do |i|
      moves.push(oldsetting[7 + i])
    end
    moves.uniq!
    moves.compact!
    ret[:moves] = moves
    return ret
  end
end