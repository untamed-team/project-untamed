# not actually a utilities page, rather it is a "too lazy to create a new page for this"

#----------------------------------------------------------------------------
# Names for switches [bool]
#----------------------------------------------------------------------------
OLDSCHOOLBATTLE = 101 # Whether the battle mechanics are roughly converted to RSE mechanics
MIRRORCONTAINER = 100 # Whether the trainer's team is mirrored to a modified player's team
LOWEREXPGAIN    = 99  # Whether the exp gain is divided/multipled by 50% or 33% per level difference
RELEARNERSWITCH = 98  # Whether the player can relearn moves on the summary screen
NOINITIALVALUES = 97  # Whether the initial values screen is skipped

#----------------------------------------------------------------------------
# Names for variables
#----------------------------------------------------------------------------
MASTERMODEVARS = 98 # [array] unused 
DEXREWARDSVAR = 102 # [int] Where dex rewards counters are stored

#----------------------------------------------------------------------------
# Whether all stats follow accuracy/evasion stages or not ((in chaos mode)).
# With this enabled, max boost is 3x and min is 0.33x
# With this not enabled, max boost is 4x and min is 0.25x
#----------------------------------------------------------------------------
$GLOBALSETUPNERF = true

#===============================================================================
# Nature Changer (NPC)
#===============================================================================
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

# i hate this piece of shit
def pbIsBadPokemon?(pkmn)
  return true if pkmn.species_data.get_baby_species == :EEVEE
  return false
end

# debug commands
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

#===============================================================================
# newish items
#===============================================================================
ItemHandlers::UseOnPokemon.add(:HYPERABILITYCAPSULE,proc{ |item, qty, pkmn, scene|
  if pbIsBadPokemon?(pkmn) || [:XOLSMOL, :AMPHIBARK, :PEROXOTAL, :DRILBUR, :EXCADRILL, :MURKROW].include?(pkmn.species)
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
    pkmn.happiness = [(pkmn.happiness - 75), 0].max
    pbMessage(_INTL("This Pokémon color palette was swapped."))
    next true
  else
    next false
  end
})

#===============================================================================
# stall edits
#===============================================================================
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
GameData::Evolution.register({  
  :id            => :HappinessLevel,  
  :parameter     => Integer,  
  :level_up_proc => proc { |pkmn, parameter|  
    if pkmn.level >= parameter  
      next pkmn.happiness == 255  
    end  
  }  
})

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
# (this used to be the only way for evolving trade mons)
#===============================================================================

GameData::Evolution.register({  
  :id            => :Link,  
  :use_item_proc => proc { |pkmn, parameter, item|  
    next item == :LINKCABLE  
  }  
})  
GameData::Evolution.register({  
  :id            => :LinkMale,  
  :use_item_proc => proc { |pkmn, parameter, item|  
    next pkmn.male? && item == :LINKCABLE  
  }  
})  
GameData::Evolution.register({  
  :id            => :LinkFemale,  
  :use_item_proc => proc { |pkmn, parameter, item|  
    next pkmn.female? && item == :LINKCABLE  
  }  
})  
GameData::Evolution.register({  
  :id                   => :LinkItem,  
  :parameter            => :Item,  
  :use_item_proc        => proc { |pkmn, parameter, item|  
    next pkmn.item == parameter && item == :LINKCABLE  
  },  
  :after_evolution_proc => proc { |pkmn, new_species, parameter, evo_species|  
    next false if evo_species != new_species || !pkmn.hasItem?(parameter)  
    pkmn.item = nil   # Item is now consumed
  }
})

# Pokedex evolution msgs edits
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
      when :Trade, :Link
        _INTL("{1} trading",evoName)
      when :TradeItem, :LinkItem
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
        _INTL("{1} at level {2} with a {3} move",evoName,requiredType,requiredLevel)
      else
        evoName
    end
    return ret    
  end
end

#===============================================================================
# powertrip + Noseponch
#===============================================================================
def pbFieldEvolutionCheck(hm_used)
  return if hm_used.nil?
  partycount = $player.party.count
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
    if pkmn.isSpecies?(:M_NOSEPASS) && pkmn.level >= 30 && hm_used == "king of the ring" && partycount == 1
      new_species = :NOSEPONCH
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
    #return false if self.obtain_method == 4 # <- works but i am not sure if i should go through with it
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
# Tropius Evolution blockage
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
# Calc Stats edits
#===============================================================================  
class Pokemon
  def calcHP(base, level, iv, ev)
    return 1 if base == 1   # For Shedinja
    ev = 0 if $player.difficulty_mode?("chaos")
    # made ivs be a brute stat boost #by low
    hp = (((((base * 2) + (ev / 4)) * level / 100).floor + level + 10) * (1+iv/100.0)).floor
    self.remaningHPBars = [0, 0] if !self.remaningHPBars
    hp *= self.remaningHPBars[1] if self.remaningHPBars[1] > 0
    return hp
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
  highestlvl = 0
  $player.party.each do |mon|
    highestlvl = mon.level if mon.level > highestlvl
  end
  proceed = false
  proceed = true if pkmn.level < highestlvl
  unless proceed
    scene.pbDisplay(_INTL("This Pokémon already has the highest level possible at the moment (lvl. {1}).", highestlvl))
    next false
  end
  if pkmn.shadowPokemon?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  if pkmn.level >= GameData::GrowthRate.max_level
    new_species = pkmn.check_evolution_on_level_up
    if !Settings::RARE_CANDY_USABLE_AT_MAX_LEVEL || !new_species
      scene.pbDisplay(_INTL("It won't have any effect."))
      next false
    end
    pbMessage(_INTL("\\c[1]{1} can now evolve!", pkmn.name))
    next true
  end
  # Level up
  pbChangeLevelNoAutoEvolve(pkmn, pkmn.level + qty, scene)
  scene.pbHardRefresh
  next true
})

#===============================================================================
# Crits edits
#===============================================================================
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

#===============================================================================
# battle attributes edits
#===============================================================================
class Battle
  attr_reader :activedAbility
  attr_reader :activedItem
  attr_reader :slowstartCount
  attr_reader :overwriteType
  attr_reader :movesRevealed
  
  alias abilactivated_initialize initialize
  def initialize(scene, p1, p2, player, opponent)
    abilactivated_initialize(scene, p1, p2, player, opponent)
    @activedAbility  = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
    @activedItem     = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
    @slowstartCount  = [Array.new(@party1.length, 0), Array.new(@party2.length, 0)]
    @overwriteType   = [Array.new(@party1.length, 0), Array.new(@party2.length, 0)]
    @movesRevealed   = [Array.new(@party1.length, []), Array.new(@party2.length, [])] #kiriya
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
  
  def wasUserItemActivated?(user) 
    return @activedItem[user.index & 1][user.pokemonIndex]
  end
  def activateUserItem(user)
    @activedItem[user.index & 1][user.pokemonIndex] = true
  end
  def deactivateUserItem(user)
    @activedItem[user.index & 1][user.pokemonIndex] = false
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

  def addMoveRevealed(user, move_id)
    if !@movesRevealed[user.index & 1][user.pokemonIndex].include?(move_id)
      @movesRevealed[user.index & 1][user.pokemonIndex].push(move_id)
    end
  end
  def moveRevealed?(user, move_id)
    return @movesRevealed[user.index & 1][user.pokemonIndex].include?(move_id)
  end
  def getMovesRevealed(user)
    return @movesRevealed[user.index & 1][user.pokemonIndex]
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

DEX_COMPLETION_MESSAGES = {
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
    rewards_given = false
    while progress < DEX_COMPLETION_REWARDS.length &&
          DEX_COMPLETION_REWARDS[progress][1] &&
          DEX_COMPLETION_REWARDS[progress][0] <= dexcount
      msg = DEX_COMPLETION_MESSAGES[progress] || DEX_COMPLETION_MESSAGES[:default]
      pbMessage(_INTL(msg))
      reward = DEX_COMPLETION_REWARDS[progress][1]
      if reward.is_a?(Symbol) && GameData::Species.exists?(reward)
        egg = Pokemon.new(reward, 1)
        egg.name           = _INTL("Egg")
        egg.steps_to_hatch = 252
        egg.calc_stats
        pbAddPokemon(egg)
      elsif reward.is_a?(Array)
        reward.each { |item| pbReceiveItem(item) }
      else
        pbReceiveItem(reward)
      end
      progress += 1
      $game_variables[DEXREWARDSVAR] += 1
      rewards_given = true
    end
    if rewards_given && progress < DEX_COMPLETION_REWARDS.length
      pbMessage(_INTL("\\xn[Ceiba]\\mr[CEIBA]When you catch {1} Pokémon, come speak to me and I'll give you a special reward!", DEX_COMPLETION_REWARDS[progress][0]))
      pbMessage(_INTL("\\xn[Ceiba]\\mr[CEIBA]Just kidding! just kidding.")) if DEX_COMPLETION_REWARDS[progress][0] == 999
    elsif !rewards_given
      pbMessage(_INTL("\\xn[Ceiba]\\mr[CEIBA]Well, when you catch {1} Pokémon, come speak to me and I'll give you a special reward!", DEX_COMPLETION_REWARDS[progress][0]))
      pbMessage(_INTL("\\xn[Ceiba]\\mr[CEIBA]Just kidding! just kidding.")) if DEX_COMPLETION_REWARDS[progress][0] == 999
      return false
    end
  else
    pbMessage(_INTL("\\xn[Ceiba]\\mr[CEIBA]When you catch {1} Pokémon, come speak to me and I'll give you a special reward!", DEX_COMPLETION_REWARDS[progress][0]))
    pbMessage(_INTL("\\xn[Ceiba]\\mr[CEIBA]Just kidding! just kidding.")) if DEX_COMPLETION_REWARDS[progress][0] == 999
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
    when 0 then msg = (_INTL("A common trash bin."))
    when 1 then msg = (_INTL("An interesting trash bin."))
    when 2 then msg = (_INTL("A trash bin, it has paper in it."))
    when 3 then msg = (_INTL("A trash bin. You wonder how they are made."))
    when 4 then msg = (_INTL("One of the trash bins of all time."))
    when 5 then msg = (_INTL("One of a variety of the mysterious Trash Bins."))
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
    fakeCrashLog
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

def fakeCrashLog
  pbSetWindowText("Kiriya's Playground")
  message = "[Pokémon Essentials version #{Essentials::VERSION}]\r\n"
  message += "Exception: Kiriya's Tantrum\r\n"
  message += "Message: What do mean Quash is 'too complicated' for me to learn!?\r\n"
  message += "\n\r\nBacktrace:\r\n"
  message += "Game crashed due to a unexpected complaint from Kiriya.\r\n"
  message += "Location: /Scripts/011_Battle/004_AI/008_L_AI_Move_EffectScores_Mazah.rb:1363\r\n"
  message += "          /Scripts/011_Battle/004_AI/008_L_AI_Move_EffectScores_Mazah.rb:1360\r\n"
  message += "          /Scripts/045_Untamed Custom Battle/007_Consistent_AI.rb:330\r\n"
  message += "          /Scripts/045_Untamed Custom Battle/007_Consistent_AI.rb:316\r\n"
  message += "          /Scripts/045_Untamed Custom Battle/007_Consistent_AI.rb:169\r\n"
  message += "Kiriya's Suggestion: Just teach me you dumb granny! (๑`^´๑)\r\n"

  errorlog = "errorlog.txt"
  errorlog = RTP.getSaveFileName("errorlog.txt") if (Object.const_defined?(:RTP) rescue false)
  File.open(errorlog, "ab") do |f|
    f.write("\r\n=================\r\n\r\n[#{Time.now}]\r\n")
    f.write(message)
  end

  errorlogline = errorlog.gsub("/", "\\")
  errorlogline.sub!(Dir.pwd + "\\", "")
  errorlogline.sub!(pbGetUserName, "USERNAME")
  errorlogline = "\r\n" + errorlogline if errorlogline.length > 20

  print("#{message}\r\nThis exception was logged in #{errorlogline}.\r\nHold Ctrl when closing this message to copy it to the clipboard.")

  t = System.delta
  until (System.delta - t) >= 500_000
    Input.update
    if Input.press?(Input::CTRL)
      Input.clipboard = message
      break
    end
  end
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

#===============================================================================
# egg moves tutor
#===============================================================================

def eggMoveTutor
  @eggmovesarray = []
  @mother = nil
  @father = nil
  doegg = false
  dadmovelist = []
  mommovelist = []
  pbFadeOutIn {
    scene = PokemonParty_Scene.new
    screen = PokemonPartyScreen.new(scene, $player.party)
    screen.pbStartScene(_INTL(""), false)
    loop do
      chosen1 = screen.pbChoosePokemon
      break if chosen1 < 0
      @father = $player.party[chosen1]
      if @father.egg?
        pbMessage(_INTL("I know it is called egg moves, but come on now.")) { screen.pbUpdate }
      elsif @father.shadowPokemon?
        pbMessage(_INTL("Shadow Pokémon can't give any moves.")) { screen.pbUpdate }
      end
      @father.moves.each do |i|
        break if i.nil? || !@father.hasMove?(i.id)
        dadmovelist.push(i.id)
      end
      break if dadmovelist.nil?
      pbMessage(_INTL("{1} is ready to bestow a move.", @father))
      chosen2 = screen.pbChoosePokemon
      break if chosen2 < 0
      @mother = $player.party[chosen2]
      if @mother.egg?
        pbMessage(_INTL("I know it is called egg moves, but come on now.")) { screen.pbUpdate }
      elsif @mother.shadowPokemon?
        pbMessage(_INTL("Shadow Pokémon can't be taught any moves.")) { screen.pbUpdate }
      elsif !@mother.has_any_egg_moves?
        pbMessage(_INTL("The receiver has no egg moves to learn.")) { screen.pbUpdate }
        break
      end
      @mother.species_data.get_egg_moves.each { |m| mommovelist.push(m) }
      if @mother == @father
        pbMessage(_INTL("These are the same pokemon you fucking idiot.")) { screen.pbUpdate }
        break
      #elsif @mother.gender == @father.gender
      #  pbMessage(_INTL("These species are not of opposite sex.")) { screen.pbUpdate }
      #  break
      #elsif @mother.gender == 2 || @father.gender == 2
      #  pbMessage(_INTL("One of them is genderless.")) { screen.pbUpdate }
      #  break
      elsif @mother.obtain_method == 4 || @father.obtain_method == 4
        pbMessage(_INTL("One of them is too fabulous to do this process.")) { screen.pbUpdate }
        break
      end

      @eggmovesarray = mommovelist & dadmovelist
      egg_groups1 = @father.species_data.egg_groups
      egg_groups2 = @mother.species_data.egg_groups
      if egg_groups1.any? { |e| [:Undiscovered, :Ditto].include?(e) } || 
         egg_groups2.any? { |e| [:Undiscovered, :Ditto].include?(e) } ||
         (egg_groups1 & egg_groups2).length == 0
        pbMessage(_INTL("These species are not compatible.")) { screen.pbUpdate }
        break
      elsif @eggmovesarray.empty?
        pbMessage(_INTL("These species share no possible egg moves.")) { screen.pbUpdate }
        break
      end
      doegg = true
      break
    end
    screen.pbEndScene
  }
  if doegg
    commands = []
    @eggmovesarray.each do |move|
      commands.push(_INTL("#{GameData::Move.get(move).name}"))
    end
    commands.push(_INTL("Cancel"))
    helpwindow = Window_UnformattedTextPokemon.new("")
    helpwindow.visible = false
    cmd = UIHelper.pbShowCommands(helpwindow,"What move should i teach?",commands) {}
    Input.update
    selectedCommander = commands[cmd]
    case selectedCommander
    when "Cancel"
      return false
    else
      @eggmovesarray.each do |move|
        if selectedCommander == "#{GameData::Move.get(move).name}"
          if pbLearnMove(@mother, move, false, false)
            $stats.moves_taught_by_tutor += 1
            return true
          else
            return false
          end
        end
      end
    end
  end
  return false
end

#===============================================================================
# NPC to revive fossils
#===============================================================================
FOSSILREVIVEVAR = 126
def fossilreviveNPC(onlyone = true)
  if !$game_variables[FOSSILREVIVEVAR].is_a?(Array)
    $game_variables[FOSSILREVIVEVAR] = [nil, 0, [], false] 
    # fossil currently being revived, time delay, fossils revived, machine fried
  end
  fossilgens = 2 # normally it would be 5, but dexit means we only have 2 gens of fossils
  fossilarr = {
    #:HELIXFOSSIL => :OMANYTE,
    #:DOMEFOSSIL  => :KABUTO,
    #:ROOTFOSSIL  => :LILEEP,
    #:CLAWFOSSIL  => :ANORITH,
    #:SKULLFOSSIL => :CRANIDOS,
    #:ARMORFOSSIL => :SHIELDON,
    #:COVERFOSSIL => :TIRTOUGA,
    #:PLUMEFOSSIL => :ARCHEN,
    :JAWFOSSIL   => :TYRUNT,
    :SAILFOSSIL  => :AMAURA,
    # gen8 is gake and fay
    :OPALFOSSIL  => :CHARCOPAL,
    :TARFOSSIL   => :ELEGOOP
  }
  if $game_variables[FOSSILREVIVEVAR][0].nil?
    ret = pbChooseFossil
    return if ret.nil?
    species = fossilarr[ret]
    if species.nil?
      pbMessage(_INTL("This fossil cannot be revived."))
      return
    end
    if onlyone
      if $player.difficulty_mode?("chaos")
        if ($game_variables[FOSSILREVIVEVAR][2].include?(:CHARCOPAL) && species == :ELEGOOP) ||
           ($game_variables[FOSSILREVIVEVAR][2].include?(:ELEGOOP) && species == :CHARCOPAL)
          pbMessage(_INTL("You already revived an Opal fossil. My machine can't process a Tar fossil after that.")) if species == :ELEGOOP
          pbMessage(_INTL("You already revived a Tar fossil. My machine can't process an Opal fossil after that.")) if species == :CHARCOPAL
          return
        end
        if ($game_variables[FOSSILREVIVEVAR][2].include?(:TYRUNT) && species == :AMAURA) ||
           ($game_variables[FOSSILREVIVEVAR][2].include?(:AMAURA) && species == :TYRUNT)
          pbMessage(_INTL("You already revived a Sail fossil. My machine can't process a Jaw fossil after that.")) if species == :TYRUNT
          pbMessage(_INTL("You already revived a Jaw fossil. My machine can't process a Sail fossil after that.")) if species == :AMAURA
          return
        end

        if $game_variables[FOSSILREVIVEVAR][2].include?(species)
          pbMessage(_INTL("My machine won't process duplicates. Come back with a different fossil."))
          return
        end
      end
      if $game_variables[FOSSILREVIVEVAR][3]
        pbMessage(_INTL("I told you, it's fried. And I don't have any spare parts out here..."))
        pbMessage(_INTL("Come visit me in my lab in Mazah City, okay? I have my full equipment there."))
        return
      end
    end
    $bag.remove(ret)
    pbMessage(_INTL("The fossil is being revived. Come back later."))
    present = pbGetTimeNow
    future = present + (60 + ((rand(2) == 0 ? -1 : 1) * rand(20..40))) * UnrealTime::PROPORTION
    $game_variables[FOSSILREVIVEVAR][0] = species
    $game_variables[FOSSILREVIVEVAR][1] = future
    return
  else
    present = pbGetTimeNow
    past = $game_variables[FOSSILREVIVEVAR][1]
    timepassed = present>past
    
    if timepassed
      pbMessage(_INTL("Took you long enough to come back! I almost called it a day!\\nLet's see what we've got here..."))
    else
      pbMessage(_INTL("...\\nThe revival process isn't complete yet. Come back later."))
      return
    end

    species = $game_variables[FOSSILREVIVEVAR][0]
    pokemon = Pokemon.new(species, 5)
    pokemon.calc_stats
    pokemon.heal

    if pbAddPokemon(pokemon)
      pbMessage(_INTL("This is good news! The fossil revived into {1}!", pokemon.name))
      $game_variables[FOSSILREVIVEVAR][0] = nil
      $game_variables[FOSSILREVIVEVAR][1] = 0
      $game_variables[FOSSILREVIVEVAR][2].push(species)
      $game_variables[FOSSILREVIVEVAR][2] |= [] # remove duplicates
      fried = onlyone # default to machine fried for normies
      if $player.difficulty_mode?("chaos")
        if ($game_variables[FOSSILREVIVEVAR][2].length.to_i / 2) > fossilgens
          fried = true
        else
          fried = false
        end
      end
      if fried
        pbMessage(_INTL("Ah, dammit. it's fried. And I don't have any spare parts out here..."))
        pbMessage(_INTL("Come visit me in my lab in Mazah City, okay? I have my full equipment there."))
      end
      $game_variables[FOSSILREVIVEVAR][3] = fried
      return
    else
      pbMessage(_INTL("Your party is full. Please make room in your party."))
      return
    end
  end
end

#===============================================================================
# Trash encounters
#===============================================================================
#TO DO
#The idea is to have one eevee available upon first arrival. However the item to summon eevee to the dumpster would be sold in a later town, thus limiting the repeatable encounter until later. This is primarily to avoid the player stacking up on a full team of eeveelutions in the early game as many of them are quite powerful until later in the game.

EventHandlers.add(:on_enter_map, :shake_dumpsters,
  proc { |_old_map_id|
	trashEncounters_ShakeDumpsters if $game_variables[TRASHENCOUNTERVAR].is_a?(Array)
  }
)

TRASHENCOUNTERVAR = 125
TRASH_ENC_MINUTES_UNTIL_ENCOUNTER = 480 #8 hours #amount of in-game minutes (seconds real-time) needed to pass before an encounter happens in the trash bin
TRASH_ENC_MIN_MINUTES_SUBTRACT_UNTIL_ENC = 0 #20 #game will subtract at least this amount from MINUTES UNTIL ENCOUNTER
TRASH_ENC_MAX_MINUTES_SUBTRACT_UNTIL_ENC = 0 #40 #game will subtract at most this amount from MINUTES UNTIL ENCOUNTER

TRASH_HASH1 = {
      :CROMEN => [:NUGGET, :BIGNUGGET, :PEARL, :BIGPEARL, :PEARLSTRING, :COMETSHARD, :RELICGOLD],
      :TRUBBISH => [:BLACKSLUDGE, :LEFTOVERS]
    }
#will not be available on chaos mode
#will combine with possibilities in TRASH_HASH1 if not on chaos mode    
TRASH_HASH2 = {
      :EEVEE => [:MASTERBALL],
      :SKITTY => [:FLUFFYTAIL],
      :PURRLOIN => [:POKETOY]
    }

def trashEncounters_Dumpster
  #this is the main method
  #if game variable is not yet an arary, make it one
  $game_variables[TRASHENCOUNTERVAR] = [] if !$game_variables[TRASHENCOUNTERVAR].is_a?(Array)

  #does an array exist for this map yet, meaning there is an encounter somewhere?
  mapArray = trashEncounters_FindMapArray
  if !mapArray.nil?
    #a dumpster encounter exists or is brewing on this map already
    #check this event's encounter to see if it's ready or not
    encSetForThisDumpster = false
    facingEvent = $game_player.pbFacingEvent(ignoreInterpreter = true)
    #mapArray should look like this: [mapID[eventNumber, item, mon, time][eventNumber, item, mon, time][eventNumber, item, mon, time]]
    mapArray.length.times do |i|
      encSetForThisDumpster = true if mapArray[i][0] == facingEvent.id
    end #mapArray.length.times do |i|
    if encSetForThisDumpster
      #an encounter was confirmed to have been brewing in this event already, so check the encounter to see if it's done
      eventArray = trashEncounters_FindEventArray(mapArray)
      encounterReady = trashEncounters_CheckEncounter(eventArray, mapArray)
      if encounterReady
      else
      end
    else
      chosenItem = trashEncounters_ChooseItem
      return if chosenItem.nil?

      #an encounter was confirmed NOT to exist in this event yet, so prompt to create one
      eventArray = trashEncounters_CreateEventArray(mapArray)

      #create encounter in dumpster event
      trashEncounters_CreateEncounter(eventArray, chosenItem)

      return #exit the event since we just created the encounter, and it therefore will not be ready yet
    end #if encSetForThisDumpster
  else #mapIDIndex is nil, which means no dumpster encounter is brewing on this entire map
    chosenItem = trashEncounters_ChooseItem
    return if chosenItem.nil?
    
    mapArray = trashEncounters_CreatemapArray

    #since no encounter existed on this map, no encounter existed for this event either, so create an event array for this map's array
    eventArray = trashEncounters_CreateEventArray(mapArray)

    #create encounter in dumpster event
    trashEncounters_CreateEncounter(eventArray, chosenItem)

    return #exit the event since we just created the encounter, and it therefore will not be ready yet
  end #if !mapIDIndex.nil?
end #def trashEncounter

def trashEncounters_FindMapArray
  #find mapArray in arrays inside game variable
  mapArray = nil
  $game_variables[TRASHENCOUNTERVAR].length.times do |i|
    #look through each element inside the $game_variables[TRASHENCOUNTERVAR] array to find one that has the mapID in slot 0
    if $game_variables[TRASHENCOUNTERVAR][i][0] == $game_map.map_id
      mapArray = $game_variables[TRASHENCOUNTERVAR][i]
      break
    end
  end
  return mapArray
end

def trashEncounters_CreatemapArray
  #push a new array for this map id to $game_variables[TRASHENCOUNTERVAR]
  $game_variables[TRASHENCOUNTERVAR].push([$game_map.map_id])
  mapArray = $game_variables[TRASHENCOUNTERVAR][-1]
  return mapArray
end

def trashEncounters_FindEventArray(mapArray)
  #find eventID in arrays inside game variable[mapArray]
  eventArray = nil
  eventElement = 1 #start at element 1 since element 0 is the map id
  (mapArray.length-1).times do
    #look through each element inside the $game_variables[TRASHENCOUNTERVAR][mapIDIndex] array for one where the first element of which matches the event number we interacted with
    facingEvent = $game_player.pbFacingEvent(ignoreInterpreter = true)
    if mapArray[eventElement][0] == facingEvent.id
      eventArray = mapArray[eventElement]
      break
    end
    eventElement += 1
  end
  return eventArray
end

def trashEncounters_CreateEventArray(mapArray)
    facingEvent = $game_player.pbFacingEvent(ignoreInterpreter = true)
    #eventArray will look like this: [eventID, item, mon, time]
    mapArray.push([facingEvent.id, nil, nil, 0])
    eventArray = mapArray[-1]
    return eventArray
end

def trashEncounters_CreateEncounter(eventArray, chosenItem)
  #merge hashes together except when on chaos mode
  unless $player.difficulty_mode?("chaos")
      trashHash1 = TRASH_HASH1.clone
      trashHash2 = TRASH_HASH2.clone
      trashHash1.merge!(trashHash2) { |key, oldval, newval| oldval }
  end

  eventArray[1] = chosenItem
    trashHash1.each do |species, requiredItem|
      if requiredItem.include?(chosenItem)
        eventArray[2] = species
        break
      else
        eventArray[2] = :TRUBBISH
      end
    end

    #set targeted time for when ecounter will be ready
    present = pbGetTimeNow
    future = present + (TRASH_ENC_MINUTES_UNTIL_ENCOUNTER + ((rand(2) == 0 ? -1 : 1) * rand(TRASH_ENC_MIN_MINUTES_SUBTRACT_UNTIL_ENC..TRASH_ENC_MAX_MINUTES_SUBTRACT_UNTIL_ENC))) * UnrealTime::PROPORTION
    eventArray[3] = future
    aOrAn = (chosenItem.name.starts_with_vowel?) ? "an" : "a"
    pbMessage(_INTL("You threw {1} {2} inside. Maybe it will attract something...", aOrAn, chosenItem))
    return
end

def trashEncounters_CheckEncounter(eventArray, mapArray)
    targetedReadyTime = eventArray[-1] #last element, or the 4th element
    return if targetedReadyTime.nil?

    present = pbGetTimeNow

    msg = rand(5..10)
    message = ""
    msg.times { message += ".   " }
    pbMessage(_INTL(message))
    if present >= targetedReadyTime
      #pbMessage(_INTL("!\\nSomething jumped out!"))
      #exclamation point above player's head
      $game_player.animation_id = 3
      #wait 1 second
      pbWait(20)
    else
      pbMessage(_INTL("...\\nThe item you threw in is still there..."))
      return
    end

    level = rand(9..13)
    #if level.between?(8,10)
    #  pbMessage(_INTL("It looks quite fierce!"))
    #elsif level.between?(5,7)
    #  pbMessage(_INTL("It looks quite protective!"))
    #elsif level.between?(2,4)
    #  pbMessage(_INTL("It looks quite energetic!"))
    #else
    #  pbMessage(_INTL("It looks quite young!"))
    #end
    species = eventArray[2]
    trashbattler = [species, level]
    $game_temp.encounter_type = :Land
    EventHandlers.trigger(:on_wild_species_chosen, trashbattler)
    WildBattle.start(trashbattler, can_override: false)
    $game_temp.encounter_type = nil
    $game_temp.force_single_battle = false

    #after the battle, delete encounter
    trashEncounters_DeleteEncounter(eventArray, mapArray)
end

def trashEncounters_DeleteEncounter(eventArray, mapArray)
  #delete the array for the event on this map
  mapArray.delete(eventArray)
  #if mapArray is empty, delete it too
  $game_variables[TRASHENCOUNTERVAR].delete(mapArray) if mapArray.length <= 1 #only has the map ID in the mapArray
end

def trashEncounters_ChooseItem
    return nil if !pbConfirmMessage(_INTL("Do you want to throw an item into the dumpster?"))
    chosenItem = nil
    pbFadeOutIn {
      scene = PokemonBag_Scene.new
      screen = PokemonBagScreen.new(scene, $bag)
      chosenItem = screen.pbChooseItemScreen
    }
    if chosenItem.nil?
      pbMessage(_INTL("You decided not to throw in an item."))
      return chosenItem
    end
    itemData = GameData::Item.get(chosenItem)
    if itemData.is_key_item?
      pbMessage(_INTL("You can't throw that away!"))
      return nil
    end
    $bag.remove(chosenItem)
    return chosenItem
end

def trashEncounters_DeleteAllEncounters
    mapArray = trashEncounters_FindMapArray
    return if mapArray.nil?
    eventElement = 1
    (mapArray.length-1).times do
      eventArray = mapArray[eventElement]
      pbMapInterpreter.pbSetSelfSwitch(eventArray[0], "A", false)
    end #(mapArray.length-1).times do
    $game_variables[TRASHENCOUNTERVAR] = []
end

def trashEncounters_ShakeDumpsters
  #go through all dumpster encounters in the mapArray for the current map
  #if any encounters are ready, set self switch A on for those events
  present = pbGetTimeNow
  mapArray = trashEncounters_FindMapArray
  return if mapArray.nil?
  eventElement = 1
  (mapArray.length-1).times do
    eventArray = mapArray[eventElement]
    Console.echo_warn eventArray
    Console.echo_warn eventArray[0]
    targetedReadyTime = eventArray[-1] #last element, or the 4th element
    next if targetedReadyTime.nil?
    if present >= targetedReadyTime
      Console.echo_warn "setting self switch A to ON for event with ID #{eventArray[0]}"
      pbMapInterpreter.pbSetSelfSwitch(eventArray[0], "A", true)
    end
    eventElement += 1
  end #(mapArray.length-1).times do
end

#===============================================================================
# Mirror boss fight (a random idea i had for Kiriya)
# this is *not* a self insert, as I fucking hate myself.
#===============================================================================

MEGA_ITEM_REPLACEMENTS = {
  CHOICEBAND: [:LEDIAN],
  CHOICESPECS: [:FRIZZARD, :ZARCOIL],
  LIFEORB: [:FLYGON, :CACTURNE, :CHIXULOB, :LUPACABRA],
  FIREGEM: [:XATU],
  ICEGEM: [:GLALIE],
  ELECTRICGEM: [:BEHEEYEM, :HAWLUCHA, :BEAKRAFT],
  FLYINGGEM: [:GOLURK, :ROADRAPTOR],
  WATERGEM: [:ZOLUPINE],
  LEFTOVERS: [:MAGCARGO, :SABLEYE, :MILOTIC, :CHIMECHO],
  BLACKSLUDGE: [:GOHILA, :SUCHOBILE],
  ROCKYHELMET: [:SKARMORY],
  ASSAULTVEST: [:MAWILE, :ATELANGLER, :LAGUNA],
  MELEEVEST: [:M_ROSERADE],
  COLBURBERRY: [:BANETTE], # dark resist
  CHARTIBERRY: [:FROSMOTH], # rock resist
  LUMBERRY: [:GYARADOS, :M_ROSERADE],
  SITRUSBERRY: [:DIANCIE, :SPECTERZAL],
  TERRAINEXTENDER: [:TREVENANT]
}

DECENT_STAB_MOVES = {
  special: {
    :NORMAL => :HYPERVOICE, 
    :ROCK => :POWERGEM, :ICE => :ICEBEAM, :STEEL => :FLASHCANNON,
    :ELECTRIC => :THUNDERBOLT, :DRAGON => :DRACOMETEOR, 
    :GRASS => :ENERGYBALL, :FIGHTING => :AURASPHERE, :FAIRY => :MOONBLAST,
    :WATER => :SURF, :FIRE => :FLAMETHROWER, :FLYING => :OBLIVIONWING, 
    :GROUND => :EARTHPOWER, :POISON => :SLUDGEBOMB, :PSYCHIC => :PSYCHIC, 
    :BUG => :BUGBUZZ, :GHOST => :SHADOWBALL, :DARK => :FIERYWRATH
  },
  physical: {
    :NORMAL => :RETURN, 
    :ROCK => :ROCKSLIDE, :ICE => :ICICLECRASH, :STEEL => :IRONHEAD,
    :ELECTRIC => :ZINGZAP, :DRAGON => :DRAGONRUSH, 
    :GRASS => :LEAFBLADE, :FIGHTING => :DRAINPUNCH, :FAIRY => :PLAYROUGH,
    :WATER => :CRABHAMMER, :FIRE => :BLAZEKICK, :FLYING => :AEROBLAST, 
    :GROUND => :EARTHQUAKE, :POISON => :SHELLSIDEARM, :PSYCHIC => :PSYCHICFANGS, 
    :BUG => :ATTACKORDER, :GHOST => :SHADOWBONE, :DARK => :CRUNCH
  }
}

def mirrorBossFight(trainer)
  $player.heal_party
  trainer.party = Marshal.load(Marshal.dump($player.party))
  balancedlevel = pbBalancedLevel($player.party)

  while trainer.party.count < 6 # 1v1? not here, baybee!
    species = GameData::Species.get(:MARIPOME).species
    pkmn = Pokemon.new(species, 50, trainer, false)
    pkmn.bossmonMutation = true
    pkmn.remaningHPBars = [1, 1] # [current hp bars, max hp bars]
    pkmn.learn_move(:BUGBUZZ)
    pkmn.learn_move(:HIGHJUMPKICK)
    pkmn.learn_move(:POISONJAB)
    pkmn.learn_move(:DAZZLINGGLEAM)
    pkmn.learn_move(:SPECTRALTHIEF)
    pkmn.learn_move(:PRISMATICLASER)
    pkmn.ability = :PARENTALBOND
    pkmn.item = :EXPERTBELT
    pkmn.nature = :NAIVE
    pkmn.calc_stats
    pkmn.name = "?QMARKS?"
    trainer.party.push(pkmn)
  end

  trainer.party.each_with_index do |pkmn, i|
    # levels
    pkmn.level = [pkmn.level, balancedlevel, 50].max
    pkmn.level += 3
    pkmn.enableNatureBoostAI
    pkmn.calc_stats

    # mega stones / MEM
    mega_data = MEGA_EVO_STATS[pkmn.species]
    if mega_data
      pkmn.megaevoMutation = true
      if pkmn.item == mega_data[:item]
        MEGA_ITEM_REPLACEMENTS.each do |replacementItem, speciesList|
          if speciesList.include?(pkmn.species)
            pkmn.item = replacementItem
            break
          end
        end
      end
    end
    if [:CHOICEBAND, :CHOICESPECS, :CHOICESCARF].include?(pkmn.item)
      pkmn.learn_move(:TRICK) unless pkmn.hasMove?(:TRICK)
    end

    # AAM
    aamSpeciesBlacklist = [:BURBRAWL, :HUMBEAT, :HUMMIPUMMEL]
    pkmn.abilityMutation = true unless aamSpeciesBlacklist.include?(pkmn.species)
    abilitylist = [pkmn.ability_id]
    if pkmn.abilityMutation
      abilist = [pkmn.ability_id]
      for i in pkmn.getAbilityList
        abilist.push(i[0])
      end
      abilitylist = abilist|[]
    end

    # prestatus
    if abilitylist.include?(:FLAREBOOST) || abilitylist.include?(:GUTS)
      pkmn.status = :BURN
    elsif abilitylist.include?(:TOXICBOOST) || abilitylist.include?(:POISONHEAL)
      pkmn.status = :POISON
    elsif abilitylist.include?(:QUICKFEET)
      pkmn.status = :PARALYSIS
    elsif abilitylist.include?(:TANGLEDFEET)
      pkmn.status = :DIZZY
      pkmn.statusCount = 4
    end
    if pkmn.status != :NONE
      status_berry_map = {
        :FREEZE => :ASPEARBERRY,
        :SLEEP => :CHESTOBERRY,
        :PARALYSIS => :CHERIBERRY,
        :POISON => :PECHABERRY,
        :DIZZY => :PERSIMBERRY,
        :BURN => :RAWSTBERRY
      }
      heldberry = status_berry_map[pkmn.status]
      if pkmn.item == :LUMBERRY || pkmn.item == heldberry
        pkmn.item = :SITRUSBERRY
      end
      pkmn.calc_stats
    end

    # move edits
    uselessarray = [:SPLASH, :CELEBRATE, :HOLDHANDS, :HAPPYHOUR]
    uselessarray += [:SLIMESHOT, :ZEALOUSDANCE, :PSYSONIC, :STEAMBURST, :HAUNT, :SUPERNOVA, :SUPERNOVA_ALT] if $player.difficulty_mode?("chaos")
    pkmn.moves.each_with_index do |move, i|
      new_move = nil
      if (move.category == 2 && [:ASSAULTVEST, :MELEEVEST].include?(pkmn.item)) ||
         uselessarray.include?(move.id)
        pkmn.forget_move_at_index(i)
        desiredCateg = (pkmn.attack > pkmn.spatk) ? :physical : :special
        pkmn.types.each do |type|
          candidate = DECENT_STAB_MOVES[desiredCateg][type]
          unless pkmn.hasMove?(candidate)
            new_move = candidate
            break
          end
        end
        new_move ||= :METRONOME
      end
      if move.id == :FACADE
        if (pkmn.hasType?(:NORMAL) && pkmn.attack > pkmn.spatk) || 
           abilitylist.include?(:FLAREBOOST) || 
           abilitylist.include?(:TOXICBOOST) || 
           abilitylist.include?(:GUTS)
          pkmn.status = :BURN if !abilitylist.include?(:TOXICBOOST)
        else
          pkmn.status = :NONE
          pkmn.forget_move_at_index(i)
          new_move = :METRONOME
        end
      end
      if new_move
        pkmn.learn_move(new_move)
      end
    end
    if pkmn.moves.length == pkmn.moves.count { |move| move.category == 2 }
      pkmn.learn_move(:METRONOME) unless pkmn.hasMove?(:METRONOME)
    end

    # final touches
    pkmn.moves.each_with_index do |m, i| # max out their PP
      m.ppup = 3
      m.pp = (m.pp * 1.6).floor
    end
    if [:BURBRAWL, :HUMBEAT, :HUMMIPUMMEL].include?(pkmn.species)
      pkmn.ability = :LEVITATE
    end
    pkmn.calc_stats
  end
end

EventHandlers.add(:on_trainer_load, :mirror_boss,
  proc { |trainer|
    if trainer
      trainerfullname = "#{trainer.trainer_type}" + " " + "#{trainer.name}"
      mirrorBossFight(trainer) if $game_switches[MIRRORCONTAINER] || trainerfullname == "Princess Kiriya"
    end
  }
)