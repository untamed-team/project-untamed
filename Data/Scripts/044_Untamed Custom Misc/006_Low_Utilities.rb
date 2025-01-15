OLDSCHOOLBATTLE = 101
INVERSEBATTLESWITCH = 100
LOWEREXPGAINSWITCH = 99
RELEARNERSWITCH = 98
NOINITIALVALUES = 97

MAXITEMSVAR = 99
MASTERMODEVARS = 98
DEXREWARDSVAR = 102

def pbNatureChanger(pkmn)
  commands = []
  ids = []
  naturenum=0
  GameData::Nature.each do |nature|
    if nature.stat_changes.length == 0
      commands.push(_INTL("{1} (---)", nature.real_name))
    else
      plus_text = ""
      minus_text = ""
      nature.stat_changes.each do |change|
        if change[1] > 0
          plus_text += "/" if !plus_text.empty?
          plus_text += GameData::Stat.get(change[0]).name_brief
        elsif change[1] < 0
          minus_text += "/" if !minus_text.empty?
          minus_text += GameData::Stat.get(change[0]).name_brief
        end
      end
      commands.push(_INTL("{1} (+{2}, -{3})", nature.real_name, plus_text, minus_text))
    end
    ids.push(nature.id)
    naturenum+=1
  end
  commands.push(_INTL("Cancel"))
  helpwindow = Window_UnformattedTextPokemon.new("")
  helpwindow.visible = false
  cmd = UIHelper.pbShowCommands(helpwindow,"Choose new nature.",commands) {}
  Input.update
  if cmd >= 0 && cmd < naturenum
    pkmn.nature = ids[cmd]
    pkmn.calc_stats
    return [cmd, commands[cmd]]
  else
    return [-1]
  end
end

def pbIsBadPokemon?(pkmn)
  return true if [:EEVEE, :VAPOREON, :JOLTEON, :FLAREON, :ESPEON, :UMBREON, :LEAFEON, :GLACEON, :SLYVEON, :GUSTEON, :TERREON].include?(pkmn.species)
  return false
end

MenuHandlers.add(:debug_menu, :set_time, {
  "name"        => _INTL("Set Time"),
  "parent"      => :field_menu,
  "description" => _INTL("Change time. The World or something."),
  "effect"      => proc {
    params = ChooseNumberParams.new
    params.setRange(0, 23)
    params.setDefaultValue(12)
    hour = pbMessageChooseNumber(_INTL("Set the time."), params)
    if hour > 0
      UnrealTime.advance_to(hour)
      $game_map.need_refresh = true
      pbMessage(_INTL("The map will refresh."))
    end
  }
})

ItemHandlers::UseOnPokemon.add(:HYPERABILITYCAPSULE,proc{ |item, qty, pkmn, scene|
  if pbIsBadPokemon?(pkmn) || [:XOLSMOL, :AMPHIBARK, :PEROXOTAL, :DRILBUR, :EXCADRILL].include?(pkmn.species)
    scene.pbDisplay(_INTL("{1} refuses to ingest this item. What a picky eater.", pkmn.name))
    next false
  end
  abils = pkmn.getAbilityList
  ability_commands = []
  abil_cmd = 0
  for i in abils
    next if i[1] > 2 # "event only" abilities
    ability_commands.push(((i[1] < 2) ? "" : "(H) ") + GameData::Ability.get(i[0]).name)
    abil_cmd = ability_commands.length - 1 if pkmn.ability_id == i[0]
  end
  abil_cmd = scene.pbShowCommands(_INTL("Choose an ability."), ability_commands, abil_cmd)
  next if abil_cmd < 0
  pkmn.ability_index = abils[abil_cmd][1]
  pkmn.ability = nil
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1}'s Ability changed! Its Ability is now {2}!", pkmn.name, pkmn.ability.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:SHINYBERRY,proc{ |item, qty, pkmn, scene|
  command2 = (pkmn.shiny?) ? "Normalize" : "Shinyfy"
  command = scene.pbShowCommands(_INTL("{1} this Pokémon?", command2), [_INTL("Yes"), _INTL("No")])
  if command == 0
    pkmn.shiny = (pkmn.shiny?) ? false : true
    pkmn.happiness += 75
    pbMessage(_INTL("This Pokémon color palette was swapped."))
    next true
  else
    next false
  end
})

class Battle
  def pbBattleLoop
    @turnCount = 0
    loop do   # Now begin the battle loop
      PBDebug.log("")
      PBDebug.log("***Round #{@turnCount + 1}***")
      if @debug && @turnCount >= 100
        @decision = pbDecisionOnTime
        PBDebug.log("")
        PBDebug.log("***Undecided after 100 rounds, aborting***")
        pbAbort
        break
      end
      PBDebug.log("")
      # Command phase
      PBDebug.logonerr { pbCommandPhase }
      break if @decision > 0
      # Attack phase
      PBDebug.logonerr { pbAttackPhase }
      break if @decision > 0
      # End of round phase
      PBDebug.logonerr { pbEndOfRoundPhase }
      # End of round extra, for Stall #by low
      @battlers.each do |b|
        next if !b
        next if b.hp <= 0
        #~ next if !b.hasActiveAbility?(:STALL)
        if b.hasActiveAbility?(:STALL) && b.turnCount > 0
          pbShowAbilitySplash(b)
          pbDisplay(_INTL("{1} stalls for time.",b.name))
          PBDebug.logonerr { pbEndOfRoundPhase }
          pbHideAbilitySplash(b)
        end
      end
      break if @decision > 0
      @turnCount += 1
    end
    pbEndOfBattle
  end
end

#===============================================================================
# DDT Spray
#===============================================================================
class PokemonEncounters
  attr_reader :step_count

  # For the current map, randomly chooses a species and level from the encounter
  # list for the given encounter type. Returns nil if there are none defined.
  # A higher chance_rolls makes this method prefer rarer encounter slots.
  def choose_wild_pokemon(enc_type, chance_rolls = 1)
    if !enc_type || !GameData::EncounterType.exists?(enc_type)
      raise ArgumentError.new(_INTL("Encounter type {1} does not exist", enc_type))
    end
    enc_list = @encounter_tables[enc_type]
    return nil if !enc_list || enc_list.length == 0
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
      # DDT Spray #by low
      if $PokemonGlobal.ddtspray
        uncaptured = []
        enc_list.each do |enc|
          next if enc==nil || enc==0
          uncaptured.push(enc) if !$player.pokedex.owned?(enc[1])
        end
        enc_list = uncaptured if uncaptured.length > 0
      end
    end
    enc_list.sort! { |a, b| b[0] <=> a[0] }   # Highest probability first
    # Calculate the total probability value
    chance_total = 0
    enc_list.each { |a| chance_total += a[0] }
    # Choose a random entry in the encounter table based on entry probabilities
    rnd = 0
    chance_rolls.times do
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
    if Settings::FLUTES_CHANGE_WILD_ENCOUNTER_LEVELS
      if $PokemonMap.blackFluteUsed
        level = [level + rand(1..4), GameData::GrowthRate.max_level].min
      elsif $PokemonMap.whiteFluteUsed
        level = [level - rand(1..4), 1].max
      end
    end
    # Return [species, level]
    return [encounter[1], level]
  end

end #of class PokemonEncounters

#===============================================================================
# New Evolution Methods
#===============================================================================
  #by low  
GameData::Evolution.register({  
  :id            => :HappinessLevel,  
  :parameter     => Integer,  
  :level_up_proc => proc { |pkmn, parameter|  
    if pkmn.level >= parameter  
      next pkmn.happiness == 255  
    end  
  }  
})

#by low
def pbRaiseTropiusEvolutionStep(pkmn)
  if pkmn.isSpecies?(:TROPIUS)
    pkmn.evolution_steps += 1
    return
  end
end

GameData::Evolution.register({ # the big funny 
  :id            => :Titanotrop,  
  :parameter     => Integer,  
  :after_battle_proc => proc { |pkmn, party_index, parameter|  
    if pkmn.level >= parameter  
      next pkmn.evolution_steps >= 10  
    end  
  }  
})  
GameData::Evolution.register({ # the big funny 2: revengeance
  :id            => :Dunsended,  
  :parameter     => Integer,  
  :after_battle_proc => proc { |pkmn, party_index, parameter|  
    if pkmn.level >= parameter  
      next pkmn.evolution_steps >= 5  
    end  
  }  
})
GameData::Evolution.register({ # the big funny 3: the prequel
  :id            => :Venorayge,  
  :parameter     => Integer,  
  :after_battle_proc => proc { |pkmn, party_index, parameter|  
    if pkmn.level >= parameter  
      next pkmn.evolution_steps >= 10
    end  
  }  
})
GameData::Evolution.register({ # rotten bananas  
  :id            => :Potassopod,  
  :parameter     => Integer,  
  :after_battle_proc => proc { |pkmn, party_index, parameter|  
    if pkmn.level >= parameter  
      next $game_temp.party_dead_bananas &&  
           $game_temp.party_dead_bananas[party_index] &&  
           $game_temp.party_dead_bananas[party_index] > 0  
    end  
  }  
})

GameData::Evolution.register({
  :id            => :Diancie,
  :parameter     => Integer,
  :use_item_proc => proc { |pkmn, parameter, item|  
    if pkmn.female? && pkmn.happiness > 200 && pkmn.level >= parameter
      next item == :ROSEDIAMOND
    end
  }
})

#===============================================================================  
# Link Cable #by low  
#===============================================================================  
GameData::Evolution.register({  
  :id            => :Trade,  
  :use_item_proc => proc { |pkmn, parameter, item|  
    next item == :LINKCABLE  
  }  
})  
GameData::Evolution.register({  
  :id            => :TradeMale,  
  :use_item_proc => proc { |pkmn, parameter, item|  
    next pkmn.male? && item == :LINKCABLE  
  }  
})  
GameData::Evolution.register({  
  :id            => :TradeFemale,  
  :use_item_proc => proc { |pkmn, parameter, item|  
    next pkmn.female? && item == :LINKCABLE  
  }  
})  
GameData::Evolution.register({  
  :id                   => :TradeItem,  
  :parameter            => :Item,  
  :use_item_proc        => proc { |pkmn, parameter, item|  
    next pkmn.item == parameter && item == :LINKCABLE  
  },  
  :after_evolution_proc => proc { |pkmn, new_species, parameter, evo_species|  
    next false if evo_species != new_species || !pkmn.hasItem?(parameter)  
    pkmn.item = nil   # Item is now consumed
  }
})
  
  # these 2 are the same thing, fsr it doesnt check night/day when using items and its such a niche problem  
GameData::Evolution.register({  
  :id            => :TradeDay,  
  :use_item_proc => proc { |pkmn, parameter, item|  
    if PBDayNight.isDay?  
      next item == :LINKCABLE  
    end  
  }  
})

GameData::Evolution.register({  
  :id            => :TradeNight,  
  :use_item_proc => proc { |pkmn, parameter, item|  
    if PBDayNight.isNight?  
      next item == :LINKCABLE  
    end  
  }  
})

#===============================================================================
# powertrip
#===============================================================================
def pbFieldEvolutionCheck(hm_used)
  return if hm_used.nil?
  $player.party.each_with_index do |pkmn, index|
    next if !pkmn || pkmn.egg?
    next if pkmn.fainted?
    new_species = nil
    decoder = PersonalNumberGenerator.new
    evo1 = decoder.decode_personal_number("045033039041043033050048")
    evo2 = decoder.decode_personal_number("039057033050033036047051")
    if pkmn.isSpecies?(evo1.to_sym) && pkmn.level >= 20 && index == 0
      case pkmn.form
      when 0
        if hm_used == "087065084069082070065076076"
          new_species = evo2.to_sym
        end
      when 2
        if hm_used == "068073086069" && pkmn.happiness >= 200
          new_species = evo2.to_sym
        end
      end
    end
    next if new_species.nil?
    pbWait(60)
    evo = PokemonEvolutionScene.new
    evo.pbStartScreen(pkmn, new_species)
    evo.pbEvolution
    evo.pbEndScreen
  end
end

def pbAscendWaterfall
  return if $game_player.direction != 8   # Can't ascend if not facing up
  terrain = $game_player.pbFacingTerrainTag
  return if !terrain.waterfall && !terrain.waterfall_crest
  $stats.waterfall_count += 1
  oldthrough   = $game_player.through
  oldmovespeed = $game_player.move_speed
  $game_player.through    = true
  $game_player.move_speed = 2
  loop do
    $game_player.move_up
    terrain = $game_player.pbTerrainTag
    if !terrain.waterfall && !terrain.waterfall_crest
      pbFieldEvolutionCheck("087065084069082070065076076")
      break
    end
  end
  $game_player.through    = oldthrough
  $game_player.move_speed = oldmovespeed
end

def pbDive
  return false if $game_player.pbFacingEvent
  map_metadata = $game_map.metadata
  return false if !map_metadata || !map_metadata.dive_map_id
  move = :DIVE
  movefinder = $player.get_pokemon_with_move(move)
  if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_DIVE, false) || (!$DEBUG && !movefinder)
    pbMessage(_INTL("The sea is deep here. A Pokémon may be able to go underwater."))
    return false
  end
  if pbConfirmMessage(_INTL("The sea is deep here. Would you like to use Dive?"))
    speciesname = (movefinder) ? movefinder.name : $player.name
    pbMessage(_INTL("{1} used {2}!", speciesname, GameData::Move.get(move).name))
    pbHiddenMoveAnimation(movefinder)
    pbFadeOutIn {
      $game_temp.player_new_map_id    = map_metadata.dive_map_id
      $game_temp.player_new_x         = $game_player.x
      $game_temp.player_new_y         = $game_player.y
      $game_temp.player_new_direction = $game_player.direction
      $PokemonGlobal.surfing = false
      $PokemonGlobal.diving  = true
      $stats.dive_count += 1
      pbUpdateVehicle
      $scene.transfer_player(false)
      $game_map.autoplay
      $game_map.refresh
      pbFieldEvolutionCheck("068073086069")
    }
    return true
  end
  return false
end

#===============================================================================  
# Universal TMs/Move Tutors #by low  
#===============================================================================  
class Pokemon
  def compatible_with_move?(move_id)  
    return false if species_data.species == :M_DITTO
    move_data = GameData::Move.try_get(move_id)  
    # Universal TMs/Move Tutors #by low  
    unimovelist = [:ATTRACT,:FACADE,:FRUSTRATION,:PROTECT,:REST,:RETURN,:SLEEPTALK,:SUBSTITUTE,:HIDDENPOWER]  
    unimovelist.push(:HYPERBEAM,:GIGAIMPACT) if species_data.get_evolutions(true).length == 0
    return true if move_data && unimovelist.include?(move_data.id)
    return move_data && species_data.tutor_moves.include?(move_data.id)  
  end
end

#===============================================================================  
# Check if Pokemon has Egg Moves #by low  
#===============================================================================  
class Pokemon
  def has_any_egg_moves? #by low  
    return false if egg? || shadowPokemon?  
    eggmove = []  
    GameData::Species.get(self.species).get_egg_moves.each do |m|  
      eggmove.push(m)  
    end  
    return true if eggmove != []  
    return false  
  end
end

#===============================================================================  
# Tropius Evolution #by low  
#===============================================================================  
class Pokemon
# The core method that performs evolution checks. Needs a block given to it,  
  # which will provide either a GameData::Species ID (the species to evolve  
  # into) or nil (keep checking).  
  # @return [Symbol, nil] the ID of the species to evolve into  
  def check_evolution_internal  
    return nil if egg? || shadowPokemon?  
    return nil if hasItem?(:EVERSTONE)  
    return nil if hasAbility?(:BATTLEBOND)  
    return nil if isSpecies?(:TROPIUS) && self.moves.any? { |m| m && m.type == :FLYING } #by low  
    species_data.get_evolutions(true).each do |evo|   # [new_species, method, parameter, boolean]  
      next if evo[3]   # Prevolution  
      ret = yield self, evo[0], evo[1], evo[2]   # pkmn, new_species, method, parameter  
      return ret if ret  
    end  
    return nil  
  end
end

#===============================================================================  
# Dragtaco Calc Stats #by low  
#===============================================================================  
class Pokemon
  def calcHP(base, level, iv, ev)
    return 1 if base == 1   # For Shedinja
    ev = 0 if $player.difficulty_mode?("chaos")
    # made ivs be a brute stat boost #by low
    return (((((base * 2) + (ev / 4)) * level / 100).floor + level + 10) * (1+iv/100.0)).floor
  end
  
  def calcStat(base, level, iv, ev, nat, realStat = :HP)
    #dragtaco things #by low
    if self.species == :DRAGTACO
      return 10 if realStat == :SPEED
      return 7 if realStat == :SPECIAL_ATTACK
    end
    ev = 0 if $player.difficulty_mode?("chaos")
    # made ivs be a brute stat boost #by low
    return ((((((base * 2) + (ev / 4)) * level / 100).floor + 5) * nat / 100) * (1+iv/100.0)).floor
  end
end

#===============================================================================  
# Use Rare Candy - Level Cap #by low  
#===============================================================================  
ItemHandlers::UseOnPokemon.add(:RARECANDY, proc { |item, qty, pkmn, scene|
  # level cap #by low
  proceed=false
  for i in $Trainer.party
    if i.level>pkmn.level
      proceed=true
      break
    end  
  end
  if pkmn.shadowPokemon?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  if proceed==false
    scene.pbDisplay(_INTL("This Pokémon already has the highest level possible at the moment."))
    next false
  end
  if pkmn.level >= GameData::GrowthRate.max_level
    new_species = pkmn.check_evolution_on_level_up
    if !Settings::RARE_CANDY_USABLE_AT_MAX_LEVEL || !new_species
      scene.pbDisplay(_INTL("It won't have any effect."))
      next false
    end
    #edited by Gardenette to work with No Auto Evolve script
    # Check for evolution
    #pbFadeOutInWithMusic {
      #  evo = PokemonEvolutionScene.new
      #  evo.pbStartScreen(pkmn, new_species)
      #  evo.pbEvolution
      #  evo.pbEndScreen
      #  scene.pbRefresh if scene.is_a?(PokemonPartyScreen)
      #}
      pbMessage(_INTL("\\c[1]{1} can now evolve!", pkmn.name))
    next true
  end
  # Level up
  pbChangeLevelNoAutoEvolve(pkmn, pkmn.level + qty, scene)
  scene.pbHardRefresh
  next true
})

GameData::Evolution.register({
  :id            => :LevelHasTypeMove,
  :parameter     => String, #take in a string so DARK_32 in pokemon.txt does not crash the game
  :level_up_proc => proc { |pkmn, parameter|
  #get the level from the string
  array = parameter
  for i in 0...array.length
    if array[i] == "_"
      separatorPosition = i
    end
  end
  
  requiredType = array[0,separatorPosition]
  if array[separatorPosition+1,array.length] != ""
    requiredLevel = array[separatorPosition+1,array.length]
  else
    requiredLevel = 1
  end
  if pkmn.level >= requiredLevel.to_i
    next pkmn.moves.any? { |m| m && m.type == requiredType.to_sym }
  end
  }
})

class PokemonPokedexInfo_Scene
  # Gets the evolution array and return evolution message
  def getEvolutionMessage(evolution, method, parameter)
    evoName = GameData::Species.get(evolution).name
    ret = case method
      when :Level
        _INTL("{1} at level {2}", evoName,parameter)
      when :LevelMale
        _INTL("{1} at level {2} and it's male", evoName,parameter)
      when :LevelFemale
        _INTL("{1} at level {2} and it's female", evoName,parameter)
      when :LevelRain
        _INTL("{1} at level {2} when raining", evoName,parameter)
      when :DefenseGreater
        _INTL("{1} at level {2} and ATK > DEF",evoName,parameter)
      when :AtkDefEqual
        _INTL("{1} at level {2} and ATK = DEF",evoName,parameter) 
      when :AttackGreater
        _INTL("{1} at level {2} and DEF < ATK",evoName,parameter)
      when :Silcoon,:Cascoon
        _INTL("{1} at level {2} with personalID", evoName,parameter)
      when :Ninjask
        _INTL("{1} at level {2}",evoName,parameter)
      when :Shedinja
        _INTL("{1} at level {2} with empty space",evoName,parameter)
      when :Happiness
        _INTL("{1} when happy",evoName)
      when :HappinessDay
        _INTL("{1} when happy at day",evoName)
      when :HappinessNight
        _INTL("{1} when happy at night",evoName)
      when :Beauty
        _INTL("{1} when beauty is greater than {2}",evoName,parameter) 
      when :DayHoldItem
        _INTL("{1} holding {2} at day",evoName,GameData::Item.get(parameter).name)
      when :NightHoldItem
        _INTL("{1} holding {2} at night",evoName,GameData::Item.get(parameter).name)
      when :HasMove
        _INTL("{1} when has move {2}",evoName,GameData::Move.get(parameter).name)
      when :HappinessMoveType
        _INTL("{1} when is happy with {2} move",evoName,GameData::Type.get(parameter).name)
      when :HasInParty
        _INTL("{1} when has {2} at party",evoName,GameData::Species.get(parameter).name)
      when :Location
        _INTL("{1} at {2}",evoName, pbGetMapNameFromId(parameter))
      when :Item
        _INTL("{1} using {2}",evoName,GameData::Item.get(parameter).name)
      when :ItemMale
        _INTL("{1} using {2} and it's male",evoName,GameData::Item.get(parameter).name)
      when :ItemFemale
        _INTL("{1} using {2} and it's female",evoName,GameData::Item.get(parameter).name)
      when :Trade
        _INTL("{1} trading",evoName)
      when :TradeItem
        _INTL("{1} trading holding {2}",evoName,GameData::Item.get(parameter).name)
      when :TradeSpecies
        _INTL("{1} trading by {2}",evoName,GameData::Species.get(parameter).name)
      # edits #by low
      when :None
        _INTL("None")
      when :LevelDay
        _INTL("{1} at level {2} at day", evoName,parameter)
      when :LevelNight
        _INTL("{1} at level {2} at night", evoName,parameter)
      when :HappinessLevel
        _INTL("{1} at level {2} and when happy", evoName,parameter)
      when :Level30HasTypeMove
        _INTL("{1} at level 30 with {2} move",evoName,GameData::Type.get(parameter).name)
      when :ItemLevel
        array = parameter
        for i in 0...array.length
          if array[i] == "_"
            separatorPosition = i # found the separator
          end
        end
        requiredItem = array[0,separatorPosition]
        if array[separatorPosition+1,array.length] != ""
          requiredLevel = array[separatorPosition+1,array.length]
        else
          requiredLevel = 1
        end
        _INTL("{1} at level {2} and using {3}",evoName,requiredLevel,GameData::Item.get(requiredItem).name)
      when :LevelHasTypeMove
        array = parameter
        for i in 0...array.length
          if array[i] == "_"
            separatorPosition = i # found the separator
          end
        end
        requiredType = array[0,separatorPosition]
        if array[separatorPosition+1,array.length] != ""
          requiredLevel = array[separatorPosition+1,array.length]
        else
          requiredLevel = 1
        end
        _INTL("{1} at level {2} with a {3} move",evoName,requiredLevel,requiredType)
      else
        evoName
    end
    return ret    
  end
end

class Battle::Move
  def pbIsCritical?(user, target, move)
    return false if target.pbOwnSide.effects[PBEffects::LuckyChant] > 0
    # Set up the critical hit ratios
    if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS && !$game_switches[OLDSCHOOLBATTLE]
      ratios = [24, 8, 2, 1]
    else
      ratios = [16, 8, 4, 3, 2]
    end
    c = 0
    # Ability effects that alter critical hit rate
    if c >= 0 && user.abilityActive?
      c = Battle::AbilityEffects.triggerCriticalCalcFromUser(user.ability, user, target, move, c)
    end
    if c >= 0 && target.abilityActive? && !@battle.moldBreaker
      c = Battle::AbilityEffects.triggerCriticalCalcFromTarget(target.ability, user, target, c)
    end
    # Item effects that alter critical hit rate
    if c >= 0 && user.itemActive?
      c = Battle::ItemEffects.triggerCriticalCalcFromUser(user.item, user, target, c)
    end
    if c >= 0 && target.itemActive?
      c = Battle::ItemEffects.triggerCriticalCalcFromTarget(target.item, user, target, c)
    end
    return false if c < 0
    # Move-specific "always/never a critical hit" effects
    case pbCritialOverride(user, target)
    when 1  then return true
    when -1 then return false
    end
    # Other effects
    return true if c > 50   # Merciless
    return true if user.effects[PBEffects::LaserFocus] > 0
    c += 1 if highCriticalRate?
    c += user.effects[PBEffects::FocusEnergy]
    c += 1 if user.inHyperMode? && @type == :SHADOW
    c = ratios.length - 1 if c >= ratios.length
    # Calculation
    return false if c == 0 && $player.difficulty_mode?("chaos") #by low
    return false if !target.pbOwnedByPlayer? && $game_variables[MASTERMODEVARS][19]==true
    return true if ratios[c] == 1
    r = @battle.pbRandom(ratios[c])
    return true if r == 0
    return false
  end
end # of Battle::Move

# making certain abilities trigger once per battle
class Battle
  attr_reader :activedAbility
  attr_reader :slowstartCount
  attr_reader :overwriteType
  
  alias abilactivated_initialize initialize
  def initialize(scene, p1, p2, player, opponent)
    abilactivated_initialize(scene, p1, p2, player, opponent)
    @activedAbility  = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
    @slowstartCount  = [Array.new(@party1.length, 0), Array.new(@party2.length, 0)]
    @overwriteType   = [Array.new(@party1.length, 0), Array.new(@party2.length, 0)]
    @numberOfUsedItems = [0,0]
  end
  def wasUserAbilityActivated?(user) 
    return @activedAbility[user.index & 1][user.pokemonIndex]
  end
  def ActivateUserAbility(user)
    @activedAbility[user.index & 1][user.pokemonIndex] = true
  end
  def DeActivateUserAbility(user)
    @activedAbility[user.index & 1][user.pokemonIndex] = false
  end
  
  def SlowStartCount(battler)
    return @slowstartCount[battler.index & 1][battler.pokemonIndex]
  end
  
  def ReadOverwriteType(user) 
    return @overwriteType[user.index & 1][user.pokemonIndex]
  end
  def WriteOverwriteType(user, move)
    @overwriteType[user.index & 1][user.pokemonIndex] = move.type
  end
end

class Battle::Battler
  def slowstart_count
    return @battle.SlowStartCount(self)
  end
  
  def ReadOverwriteType 
    return @overwriteType[self.index & 1][self.pokemonIndex]
  end
end

#===============================================================================
# Dex Completion Rewards
#===============================================================================

DEX_COMPLETION_REWARDS = [
  [10,:PPUP],
  [20,:PPMAX],
  [30,[:LAVACOOKIE,:CASTELIACONE]],
  [50,:AMULETCOIN],
  [75,:LILORINA],
  [100,:EVIOLITE],
  [125,:ROCKYHELMET],
  [150,:LEFTOVERS],
  [175,:ASSAULTVEST],
  [200,:CHOICESCARF],
  [999]
]

NPC_MESSAGES = {
  0 => "\\xn[Ceiba]\\mr[CEIBA]Oh! You're off to a good start!\\nKeep on catching all the new Pokémon you see!",
  1 => "\\xn[Ceiba]\\mr[CEIBA]You're making good progress.\\nHave you got a fishing rod?\\nMany different species live in lakes, rivers, and the sea.",
  2 => "\\xn[Ceiba]\\mr[CEIBA]Amazing! Over 30 species!\\nEnjoy these Lava Cookie and Casteliacone, which can heal your Pokémon.",
  3 => "\\xn[Ceiba]\\mr[CEIBA]Fantastic! You've caught over 50 species!\\nHere's an Amulet Coin, it will help you earn more money in battles.",
  4 => "\\xn[Ceiba]\\mr[CEIBA]Incredible! Over 75 species!\\nI have a special reward for you, an Egg of a rare Pokémon.",
  5 => "\\xn[Ceiba]\\mr[CEIBA]Outstanding! You've caught over 100 species!\\nHere's an Eviolite to boost the defenses of your unevolved Pokémon.",
  6 => "\\xn[Ceiba]\\mr[CEIBA]Unbelievable! Over 125 species!\\nTake this Rocky Helmet, which damages opponents that make contact.",
  7 => "\\xn[Ceiba]\\mr[CEIBA]Phenomenal! You've caught over 150 species!\\nHere's some Leftovers to keep your Pokémon healthy, it restores HP at the end of each turn.",
  8 => "\\xn[Ceiba]\\mr[CEIBA]Astounding! Over 175 species!\\nTake this Assault Vest to boost your Pokémon's Special Defense.",
  9 => "\\xn[Ceiba]\\mr[CEIBA]Legendary! You've caught over 200 species!\\nHere's a Choice Scarf to increase your Pokémon's Speed. Careful to not lock into a bad move, though!",
  :default => "\\xn[Ceiba]\\mr[CEIBA]zinnia, courtney and hex maniac are the best pokegirls."
}

def pbGiveDexReward
  progress = $game_variables[DEXREWARDSVAR]
  if pbConfirmMessage(_INTL("\\xn[Ceiba]\\mr[CEIBA]Ah, hello \\PN.\\nAre you here to evaluate your PokéDex?"))
    dexseen  = $player.pokedex.seen_count
    dexcount = $player.pokedex.owned_count
    pbMessage(_INTL("\\xn[Ceiba]\\mr[CEIBA]So, you've seen <b>{1}</b> Pokémon\\nand caught <b>{2}</b> of them...", dexseen, dexcount))
    if DEX_COMPLETION_REWARDS[progress][0] > dexcount
      pbMessage(_INTL("\\xn[Ceiba]\\mr[CEIBA]Well, when you catch {1} Pokémon, come speak to me and I'll give you a special reward!", DEX_COMPLETION_REWARDS[progress][0]))
      pbMessage(_INTL("\\xn[Ceiba]\\mr[CEIBA]Just kidding! just kidding.")) if DEX_COMPLETION_REWARDS[progress][0] == 999
      return false
    end
    return false if DEX_COMPLETION_REWARDS[progress][1].nil?
    msg = DEX_COMPLETION_MESSAGES[progress] || DEX_COMPLETION_MESSAGES[:default]
    pbMessage(_INTL(msg))
    if [4].include?(progress)
      egg = Pokemon.new(DEX_COMPLETION_REWARDS[progress][1], 1)
      egg.name           = _INTL("Egg")
      egg.steps_to_hatch = 252
      egg.calc_stats
      pbAddPokemon(egg)
    else
      if DEX_COMPLETION_REWARDS[progress][1].is_a?(Array)
        reward_array = DEX_COMPLETION_REWARDS[progress][1]
        for i in 0...reward_array.length
          pbReceiveItem(DEX_COMPLETION_REWARDS[progress][1][i])
        end
      else
        pbReceiveItem(DEX_COMPLETION_REWARDS[progress][1])
      end
    end
    pbMessage(_INTL("When you catch {1} Pokémon, come speak to me and I'll give you a special reward!", DEX_COMPLETION_REWARDS[progress + 1][0]))
    pbMessage(_INTL("Just kidding! just kidding.")) if DEX_COMPLETION_REWARDS[progress + 1][0] == 999
    $game_variables[DEXREWARDSVAR] += 1
  else
    pbMessage(_INTL("When you catch {1} Pokémon, come speak to me and I'll give you a special reward!", DEX_COMPLETION_REWARDS[progress][0]))
    pbMessage(_INTL("Just kidding! just kidding.")) if DEX_COMPLETION_REWARDS[progress + 1][0] == 999
    return false
  end
  return true
end

#===============================================================================
# Bins
#===============================================================================

class Player < Trainer
  attr_accessor   :bin_array
  alias initialize_bins initialize
  def initialize(name, trainer_type)
    initialize_bins(name, trainer_type)
    super
    @bin_array = ["FakeStone", "Elena", "Kanto", "Pop Culture", "Flygon", 
                  "Book", "AI Art", "Love Advice", "man.", "Hiccups", 
                  "RGB", "Jynx", "Kanto 2", "Code", "Walmart", 
                  "Kettle", "NYC", "AsaCoco", "Kanto 3", "Flavor",
                  "saghex", "HexySexy", "Devstruggle"]
  end
end

def pbTrashBin(eventID, specialBin = false)
  if !specialBin
    bin_rng = rand(5)
    case bin_rng
    when 0 then msg = "A common trash bin."
    when 1 then msg = "A interesting trash bin."
    when 2 then msg = "A trash bin, it has paper in it."
    when 3 then msg = "A trash bin. You wonder how they are made."
    when 4 then msg = "One of the trash bins of all time."
    when 5 then msg = "One of a variety of the mysterious Trash Bins."
    end
    pbMessage(msg)
    return
  end
  if $player.bin_array.empty?
    pbMessage(_INTL("A common trash bin."))
    #echoln "no bin 4 u"
    return
  end
  bin_rng2 = semiRandomRNG($player.bin_array.length)
  #echoln "#{bin_rng2} || #{$player.bin_array[bin_rng2]}"
  pbMEPlay("Item get")
  pbSetSelfSwitch(eventID, "B", true)
  ayaya = ($Trainer.they == "he" && $player.gender == 0) # jesus christ this "they" shit is so fucking cringe
  case $player.bin_array[bin_rng2]
  when "FakeStone"
    fake_stonen = rand(4)
    case fake_stonen
    when 0 then fake_stone = "Gastronautite"
    when 1 then fake_stone = "Quetzillianite"
    when 2 then fake_stone = "Bathygigite"
    when 3 then fake_stone = "Crustanite"
    when 4 then fake_stone = "Peroxotalite"
    end
    pbMessage(_INTL("You found a \\c[1]{1}\\c[0]!",fake_stone))
    pbMessage(_INTL("...\\n..."))
    pbMessage(_INTL("You awkwardly put the trash back at the bin."))
  when "Elena"
    pbMessage(_INTL("You found a \\c[1]Old Drawing\\c[0]!"))
    pbMessage(_INTL("It has Gijinkas of the legendary birds. Cute."))
    if ayaya
      pbMessage(_INTL("...'Arti' is pretty hot.")) 
      pbMessage(_INTL("...and this 'Zaza' is so (ToT).")) if rand(3) == 0
    end
    pbMessage(_INTL("You put the \\c[1]Drawing\\c[0] in\\nyour Bag's \\c[1]Spare\\c[0] pocket."))
  when "Kanto"
    pbMessage(_INTL("You found a \\c[1]Crumpled Photo\\c[0]!"))
    pbMessage(_INTL("It's a photo of a little kid from KANTO, he is hugging a Eevee."))
    pbMessage(_INTL("...\\n..."))
    pbMessage(_INTL("Truly repugnant."))
  when "Pop Culture"
    pbMessage(_INTL("You found a \\c[1]Discarted Screenplay\\c[0]!"))
    pbMessage(_INTL("It says something about dramatic entrances and eating garbage."))
  when "Flygon"
    pbMessage(_INTL("You found some \\c[1]Concept Art\\c[0]!"))
    pbMessage(_INTL("It shows many weird looking Flygons. It seems the artist had a art block."))
  when "Book"
    pbMessage(_INTL("You found a \\c[1]Joke Book\\c[0]!"))
    pbMessage(_INTL("'I had a good one but it was rubbish.'"))
  when "AI Art"
    pbMessage(_INTL("You found a \\c[1]Picture\\c[0]!"))
    if ayaya
      pbMessage(_INTL("It's your favorite PokeGirl trying to hug you."))
      pbMessage(_INTL("It has a 'AI Generated' watermark."))
      pbMessage(_INTL("You put the \\c[1]Picture\\c[0] in\\nyour Bag's \\c[1]Spare\\c[0] pocket for later."))
    else
      pbMessage(_INTL("It has a 'AI Generated' watermark."))
      pbMessage(_INTL("It's your favorite PokeGirl trying to hug you."))
      pbMessage(_INTL("You rip the \\c[1]Picture\\c[0] appart."))
    end
  when "Love Advice"
    pbMessage(_INTL("You found stacks of \\c[1]Blank Crumpled Paper\\c[0]!"))
    pbMessage(_INTL("You wish you had a heart as full as this trash bin."))
  when "man."
    pbMessage(_INTL("You found ...\\c[1]Nothing\\c[0]!"))
    pbMessage(_INTL("This trash bin is more empty than you."))
  when "Hiccups"
    pbMessage(_INTL("You found a \\c[1]Thread\\c[0]!"))
    pbMessage(_INTL("\\c[3]>be me\\n>have hiccups\\n>tell myself &quot;i am not a fish&quot;\\n>hiccups gone\\n\\c[0]why does it work?"))
  when "RGB"
    pbSetSelfSwitch(eventID, "B", false)
    pbSetSelfSwitch(eventID, "D", true)
    pbMessage(_INTL("You found a \\c[2]R\\c[3]G\\c[1]Bin\\c[0]!"))
  when "Jynx"
    pbMessage(_INTL("You found some \\c[1]Drafts Art\\c[0]!"))
    pbMessage(_INTL("It shows Jynx evolving into a new cool looking Pokemon. Social recluses might not like this."))
  when "Kanto 2"
    pbMessage(_INTL("You found some \\c[1]Doll\\c[0]!"))
    pbMessage(_INTL("It's a Charizard Doll.\\nWell, can't say it doesn't deserve to be there."))
  when "Code"
    pbMessage(_INTL("You found some ...\\c[1]Crash logs\\c[0]?"))
    print "What do mean Quash is 'too complicated' for me to learn!? Just TEACH ME you dumb granny!!!"
    pbMessage(_INTL("Seems like Kiriya is having a fit. I hope she calms down soon enough."))
  when "Walmart"
    pbMessage(_INTL("You found a \\c[1]Cropped Newspaper\\c[0]!"))
    pbMessage(_INTL("It seems that a unidentified pink bunny has been banned from PokeMarts\\n...in Minecraft?"))
  when "Kettle"
    pbMessage(_INTL("You found a \\c[1]Cropped Ad\\c[0]!"))
    pbMessage(_INTL("It's a yellow kettle. It seems to have a &quot;<i>Dynamically Adjustable Yield Operator</i>&quot; system, or DAYO for short."))
  when "NYC"
    pbMessage(_INTL("You found ...\\c[1]'drawings'\\c[0]..."))
    pbMessage(_INTL("Disregarding how awful it looks, it seems to be a trainer with a black and blue color scheme and a Snake Pokemon?"))
    pbMessage(_INTL("There is a blob of blond-yellow in the snake's mouth...\\nFeeling violated, you put the trash back at the bin."))
  when "AsaCoco"
    pbMessage(_INTL("You found a \\c[1]Indie Newspaper\\c[0]!"))
    pbMessage(_INTL("A discontinued newsletter. The final issue had a interview between a self-proclaimed Phoenix and a Yakuza member."))
    pbMessage(_INTL("Good memories."))
  when "Kanto 3"
    pbMessage(_INTL("You found a \\c[1]Tour Guide\\c[0]!"))
    pbMessage(_INTL("The pictures are pretty.\\n...Though, why is that trainer forcing a Karp climb a waterfall? Isn't that a bit unpractical?"))
  when "Flavor"
    pbMessage(_INTL("You found a \\c[1]Court Transcript\\c[0]!"))
    pbMessage(_INTL("This is long, ridiculously so.\\nSkimming through this snoozefest, it seems that many people were debating about... flavor...?"))
    pbMessage(_INTL("That was a waste of time."))
  when "saghex"
    pbMessage(_INTL("You found a \\c[1]Research Paper\\c[0]!"))
    if ayaya
      pbMessage(_INTL("It shows a steep increase in romantic relationships between 30+ y/o women and 20 y/o men."))
      pbMessage(_INTL("god I wish that was me"))
    else
      pbMessage(_INTL("It shows a increase in general loneliness. I didn't need data to prove that."))
    end
  when "HexySexy"
    pbMessage(_INTL("You found a \\c[1]Crumpled Map\\c[0]!"))
    pbMessage(_INTL("Many cafés are marked. All of them have attached gimmicks."))
    if ayaya
      pbMessage(_INTL("In Kalos, a Hex Maniac Maid Café opened. It specializes in milk beverages."))
      pbMessage(_INTL("You put the \\c[1]Crumpled Map\\c[0] in\\nyour Bag's \\c[1]Spare\\c[0] pocket as a reminder."))
    else
      pbMessage(_INTL("You wonder what the point of these are. StaryuChucks has everything you need anyway."))
    end
  when "Devstruggle"
    pbMessage(_INTL("You found a \\c[1]Scam\\c[0]!"))
    pbMessage(_INTL("The author claims to have found a new region.\\nThe starters change every week, and this has been going for years."))
  else
    pbMessage(_INTL("A Trash bin."))
  end
  $player.bin_array.delete_at(bin_rng2)
  Achievements.incrementProgress("EBIN_BINS",1)
end

#===============================================================================
# RNG seeds
#===============================================================================

def semiRandomRNG(x, y = 0)
  funseed = $player.secret_ID.to_s[-3..-1].to_i + y # last 3 digits of secret id + predefined offset
  srand(funseed) # temporarly sets a rng seed
  srng = rand(x)
  srand # reset rng
  return srng 
end

def nameToNumberConvert(name)
  letter_values = {
    #alphabet
    'A' => 1,  'B' => 2,  'C' => 3,  'D' => 4,  'E' => 5,  'F' => 6,  'G' => 7,  'H' => 8,  'I' => 9,
    'J' => 10, 'K' => 11, 'L' => 12, 'M' => 13, 'N' => 14, 'O' => 15, 'P' => 16, 'Q' => 17, 'R' => 18,
    'S' => 19, 'T' => 20, 'U' => 21, 'V' => 22, 'W' => 23, 'X' => 24, 'Y' => 25, 'Z' => 26,

    #numbers
    '0' => 27, '1' => 28, '2' => 29, '3' => 30, '4' => 31, 
    '5' => 32, '6' => 33, '7' => 34, '8' => 35, '9' => 36,

    #symbols
    ' ' => 37, '!' => 38, '"' => 39, '#' => 40, '$' => 41, '%' => 42, '&' => 43, '\'' => 44, '(' => 45, 
    ')' => 46, '*' => 47, '+' => 48, ',' => 49, '-' => 50, '.' => 51, '/' => 52, ':' => 53, ';' => 54, 
    '<' => 55, '=' => 56, '>' => 57, '?' => 58, '@' => 59, '[' => 60, '\\' => 61, ']' => 62, '^' => 63, 
    '_' => 64, '`' => 65, '{' => 66, '|' => 67, '}' => 68, '~' => 69 #nice
  }
  name = name.upcase
  total = 0
  name.each_char do |letter|
    if letter_values[letter].nil?
      echoln "RNG Error. Issue: #{name[letter]}; #{name}"
      next
    end
    total += letter_values[letter]
  end
  return total
end

# look brah i got lazy
class PersonalNumberGenerator
  def initialize
    @char_map = build_char_map
    @reverse_char_map = @char_map.invert
  end

  def build_char_map
    char_map = {}
    (' '..'~').each_with_index do |char, index|
      char_map[char] = format('%03d', index)
    end
    ('À'..'ÿ').each_with_index do |char, index|
      char_map[char] = format('%04d', index + 1000)
    end
    char_map
  end
  
  def decode_personal_number(encoded_text)
    decoded_text = ''
    i = 0
    while i < encoded_text.length
      if encoded_text[i..i+3].to_i <= 999
        code = encoded_text[i..i+2]
        i += 3
      else
        code = encoded_text[i..i+3]
        i += 4
      end

      decoded_char = @reverse_char_map[code]
      if decoded_char.nil?
        #raise "Error: No mapping found for code #{code}"
      else
        decoded_text += decoded_char
      end
    end
    decoded_text
  end
end