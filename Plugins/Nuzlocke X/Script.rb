#===============================================================================
#  Nuzlocke functionality for vanilla Essentials
#-------------------------------------------------------------------------------
#  creates a Nuzlocke Game Mode complete with all the proper rules
#===============================================================================
module Nuzlocke
  @@nuzlocke = false
  @@rules = []
  #-----------------------------------------------------------------------------
  #  check if nuzlocke is on
  #-----------------------------------------------------------------------------
  def self.running?
    return $PokemonGlobal && $PokemonGlobal.isNuzlocke
  end
  def self.on?
    return self.running? && @@nuzlocke
  end
  #-----------------------------------------------------------------------------
  #  toggle nuzlocke state
  #-----------------------------------------------------------------------------
  def self.toggle(force = nil)
    @@nuzlocke = force.nil? ? !@@nuzlocke : force
  end
  #-----------------------------------------------------------------------------
  #  get nuzlocke rules
  #-----------------------------------------------------------------------------
  def self.rules; return @@rules; end
  def self.set_rules(rules); @@rules = rules; end
  #-----------------------------------------------------------------------------
  #  command selection
  #-----------------------------------------------------------------------------
  def self.commandWindow(commands, index = 0, msgwindow = nil)
    ret = -1
    # creates command window
    cmdwindow = Window_CommandPokemonColor.new(commands)
    cmdwindow.index = index
    cmdwindow.x = Graphics.width - cmdwindow.width
    cmdwindow.z = 99999
    # main loop
    loop do
      # updates graphics, input and OW
      Graphics.update
      Input.update
      pbUpdateSceneMap
      # updates the two windows
      cmdwindow.update
      msgwindow.update if !msgwindow.nil?
      # updates command output
      if Input.trigger?(Input::B)
        pbPlayCancelSE
        ret = -1
        break
      elsif Input.trigger?(Input::C)
        pbPlayDecisionSE
        ret = cmdwindow.index
        break
      end
    end
    # returns command output
    cmdwindow.dispose
    return ret
  end
  #-----------------------------------------------------------------------------
  #  recurring function to get the very first species in the evolutionary line
  #-----------------------------------------------------------------------------
  def self.getFirstEvo(species)
    return nil if species.nil?
    prev = GameData::Species.get(species).get_previous_species
    return species if prev == species
    return self.getFirstEvo(prev)
  end
  #-----------------------------------------------------------------------------
  #  recurring function to get every evolution after defined species
  #-----------------------------------------------------------------------------
  def self.getNextEvos(species)
    return [] if species.nil?
    evo = GameData::Species.get(species).get_evolutions; all = []
    return [species] if evo.length < 1
    for arr in evo
      all += [arr[0]]
      all += self.getNextEvos(arr[0])
    end
    return all.uniq
  end
  #-----------------------------------------------------------------------------
  #  function to get all species inside an evolutionary line
  #-----------------------------------------------------------------------------
  def self.getEvolutionaryLine(species)
    species = self.getFirstEvo(species)
    return [species] + self.getNextEvos(species)
  end
  #-----------------------------------------------------------------------------
  #  checks if an evo line has been caught so far
  #-----------------------------------------------------------------------------
  def self.checkEvoNuzlocke?(species)
    return false if !$PokemonGlobal || !$PokemonGlobal.nuzlockeData
    for poke in self.getEvolutionaryLine(species)
      return true if $Trainer.owned?(poke)
    end
    return false
  end
  #-----------------------------------------------------------------------------
  # get all item keys
  #-----------------------------------------------------------------------------
  def self.all_items
    keys = []
    GameData::Item.each { |item| keys.push(item.id) }
    return keys
  end
  #-----------------------------------------------------------------------------
  # check if battler is on player side
  #-----------------------------------------------------------------------------
  def self.playerBattler?(battler)
    return battler.index%2 == 0
  end
  #-----------------------------------------------------------------------------
  #  starts nuzlocke mode
  #-----------------------------------------------------------------------------
  def self.start(skip = false)
    ret = $PokemonGlobal && $PokemonGlobal.isNuzlocke
    ret = self.selection unless skip
    $PokemonGlobal.qNuzlocke = ret
    # sets the nuzlocke to true if already has a bag and Pokeballs
    for i in self.all_items
      break if !$PokemonBag
      if GameData::Item.get(i).is_poke_ball? && $PokemonBag.pbHasItem?(i)
        @@nuzlocke = ret
        $PokemonGlobal.isNuzlocke = ret
        break
      end
    end
    # creates global variable
    $PokemonGlobal.nuzlockeData = {} if $PokemonGlobal.nuzlockeData.nil?
  end
  #-----------------------------------------------------------------------------
  #  creates an UI to select the nuzlocke options
  #-----------------------------------------------------------------------------
  def self.selection
    # list of all possible rules
    modifiers = [:NOREVIVE, :PERMADEATH, :ONEROUTE, :DUPSCLAUSE, :STATIC, :SHINY]
    # list of rule descriptions
    desc = [
      _INTL("Cannot revive fainted battlers"),
      _INTL("Auto-delete fainted battlers"),
      _INTL("One encounter per map"),
      _INTL("Disregard duplicate species (line)"),
      _INTL("Exclude static from encounter limit"),
      _INTL("Exclude shiny from encounter limit")
    ]
    # default
    added = [:NOREVIVE, :DUPSCLAUSE, :ONEROUTE, :STATIC, :SHINY]; cmd = 0
    # creates help text message window
    msgwindow = pbCreateMessageWindow(nil, "choice 1")
    msgwindow.text = _INTL("Select the Nuzlocke Rules you wish to apply.")
    # main loop
    loop do
      # generates all commands
      commands = []
      for i in 0...modifiers.length
        commands.push(_INTL("{1} {2}",(added.include?(modifiers[i])) ? "[X]" : "[  ]",desc[i]))
      end
      commands.push(_INTL("Done"))
      # goes to command window
      cmd = self.commandWindow(commands, cmd, msgwindow)
      # processes return
      if cmd < 0
        clear = pbConfirmMessage("Do you wish to cancel the Nuzlocke selection?")
        added.clear if clear
        next unless clear
      end
      break if cmd < 0 || cmd >= (commands.length - 1)
      if cmd >= 0 && cmd < (commands.length - 1)
        if added.include?(modifiers[cmd])
          added.delete(modifiers[cmd])
        else
          added.push(modifiers[cmd])
        end
      end
    end
    # disposes of message window
    pbDisposeMessageWindow(msgwindow)
    # adds nuzlocke rules
    $PokemonGlobal.nuzlockeRules = added
    @@rules = added
    # shows message
    msg = _INTL("Your selected Nuzlocke rules have been applied.")
    msg = _INTL("No Nuzlocke rules have been applied.") if added.length < 1
    msg = _INTL("Your selection has been cancelled.") if cmd < 0
    pbMessage(msg)
    Input.update
    return added.length > 0
  end
  #-----------------------------------------------------------------------------
  #  clear the randomizer content
  #-----------------------------------------------------------------------------
  def self.reset
    @@nuzlocke = false
    if $PokemonGlobal
      $PokemonGlobal.qNuzlocke = nil
      $PokemonGlobal.nuzlockeData = nil
      $PokemonGlobal.isNuzlocke = nil
      $PokemonGlobal.nuzlockeRules = nil
    end
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  adding nuzlocke functionality to battler specific classes
#===============================================================================
class Pokemon
  attr_accessor :permaFaint
  #-----------------------------------------------------------------------------
  #  modifies returned HP
  #-----------------------------------------------------------------------------
  alias hpget_nuzlocke_x hp unless self.method_defined?(:hpget_nuzlocke_x)
  def hp
    return (self.permaFaint && Nuzlocke.on?) ? 0 : hpget_nuzlocke_x
  end
  #-----------------------------------------------------------------------------
  #  if HP falls to (or below 0) permanent faint is in effect
  #-----------------------------------------------------------------------------
  alias hpset_nuzlocke_x hp= unless self.method_defined?(:hpset_nuzlocke_x)
  def hp=(val)
    data = Nuzlocke.rules; data = [] if data.nil?
    self.permaFaint = true if Nuzlocke.on? && (data.include?(:NOREVIVE) || data.include?(:PEMADEATH)) && val <= 0
    hpset_nuzlocke_x((self.permaFaint && Nuzlocke.on?) ? 0 : val)
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
class PokeBattle_Battler
  #-----------------------------------------------------------------------------
  #  modifies returned HP
  #-----------------------------------------------------------------------------
  alias hpget_nuzlocke_x hp unless self.method_defined?(:hpget_nuzlocke_x)
  def hp
    return (@pokemon && @pokemon.permaFaint && Nuzlocke.on?) ? 0 : hpget_nuzlocke_x
  end
  #-----------------------------------------------------------------------------
  #  if HP falls to (or below 0) permanent faint is in effect
  #-----------------------------------------------------------------------------
  alias hpset_nuzlocke_x hp= unless self.method_defined?(:hpset_nuzlocke_x)
  def hp=(val)
    data = Nuzlocke.rules; data = [] if data.nil?
    @pokemon.permaFaint = true if Nuzlocke.on? && (data.include?(:NOREVIVE) || data.include?(:PEMADEATH)) && val <= 0
    hpset_nuzlocke_x((@pokemon.permaFaint && Nuzlocke.on?) ? 0 : val)
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  registers battler for map if fainted in battle
#===============================================================================
class PokeBattle_Scene
  attr_accessor :firstFainted
  #-----------------------------------------------------------------------------
  #  registers defeated battler on map
  #-----------------------------------------------------------------------------
  alias pbFaintBattler_nuzlocke_x pbFaintBattler unless self.method_defined?(:pbFaintBattler_nuzlocke_x)
  def pbFaintBattler(battler)
    if !@battle.opponent && !Nuzlocke.playerBattler?(battler)
      data = Nuzlocke.rules; data = [] if data.nil?
      unless (@battle.pbParty(1).length == 2  && !self.firstFainted)
        if Nuzlocke.on? && data.include?(:ONEROUTE) && battler.index%2 == 1
          evo = Nuzlocke.checkEvoNuzlocke?(battler.pokemon.species) && data.include?(:DUPSCLAUSE)
          static = data.include?(:STATIC) && !$nuzx_static_enc
          shiny = data.include?(:SHINY) && battler.shiny?
          map = $PokemonGlobal.nuzlockeData[$game_map.map_id]
          $PokemonGlobal.nuzlockeData[$game_map.map_id] = true if map.nil? && !static && !evo && !shiny
        end
      end
      self.firstFainted = true
    end
    # returns original function
    return pbFaintBattler_nuzlocke_x(battler)
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  adding nuzlocke functionality to delete fainted battlers from party
#  (applied after battle is finished)
#===============================================================================
class PokeBattle_Battle
  #-----------------------------------------------------------------------------
  #  deletes all fainted battlers after battle (if rule is applied)
  #-----------------------------------------------------------------------------
  alias pbEndOfBattle_nuzlocke_x pbEndOfBattle unless self.method_defined?(:pbEndOfBattle_nuzlocke_x)
  def pbEndOfBattle
    ret = pbEndOfBattle_nuzlocke_x
    # applies permadeath
    data = Nuzlocke.rules; data = [] if data.nil?
    if Nuzlocke.on? && data.include?(:PERMADEATH)
      for i in 0...$Trainer.party.length
        k = $Trainer.party.length - 1 - i
        if $Trainer.party[k].hp <= 0
          $PokemonBag.pbStoreItem($Trainer.party[k].item, 1) if $Trainer.party[k].item
          $Trainer.party.delete_at(k)
          $PokemonTemp.evolutionLevels.delete_at(k)
        end
      end
    end
    return ret
  end
  #-----------------------------------------------------------------------------
  #  allows for the catching of only one Pokemon per route
  #-----------------------------------------------------------------------------
  alias pbThrowPokeBall_nuzlocke_x pbThrowPokeBall unless self.method_defined?(:pbThrowPokeBall_nuzlocke_x)
  def pbThrowPokeBall(*args)
    # part to disable Pokeball throwing if already caught
    data = Nuzlocke.rules; data = [] if data.nil?
    if Nuzlocke.on? && data.include?(:ONEROUTE)
      static = data.include?(:STATIC) && !$nuzx_static_enc
      shiny = data.include?(:SHINY) && @battlers[args[0]].shiny?
      map = $PokemonGlobal.nuzlockeData[$game_map.map_id]
      return pbDisplay(_INTL("Nuzlocke rules prevent you from catching a wild Pokémon on a map you already had an encounter on!")) if !map.nil? && !static && !shiny
    end
    pbThrowPokeBall_nuzlocke_x(*args)
    # part that registers caught Pokemon for map
    if Nuzlocke.on? && data.include?(:ONEROUTE) && @decision == 4
      $PokemonGlobal.nuzlockeData[$game_map.map_id] = true unless static || shiny
    end
  end
  #-----------------------------------------------------------------------------
  #  registers Pokemon for nuzlocke map when fleeing
  #-----------------------------------------------------------------------------
  alias pbRun_nuzlocke_x pbRun unless self.method_defined?(:pbRun_nuzlocke_x)
  def pbRun(*args)
    data = Nuzlocke.rules; data = [] if data.nil?
    battler = nil
    for i in 0...self.pbSideSize(1)
      if @battlers[i+1] && @battlers[i+1].hp > 0
        battler = @battlers[i+1]
        break
      end
    end
    if Nuzlocke.on? && data.include?(:ONEROUTE) && !self.opponent
      evo = battler.nil? ? false : Nuzlocke.checkEvoNuzlocke?(battler.displaySpecies) && data.include?(:DUPSCLAUSE)
      static = data.include?(:STATIC) && !$nuzx_static_enc
      shiny = false
      eachOtherSideBattler(args[0]) do |b|
        shiny = true if data.include?(:SHINY) && b.shiny?
      end
      map = $PokemonGlobal.nuzlockeData[$game_map.map_id]
      $PokemonGlobal.nuzlockeData[$game_map.map_id] = true if map.nil? && !static && !evo && !shiny
    end
    # returns original function
    return pbRun_nuzlocke_x(*args)
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  losing the nuzlocke
#===============================================================================
alias pbStartOver_nuzlocke_x pbStartOver unless defined?(pbStartOver_nuzlocke_x)
def pbStartOver(*args)
  if Nuzlocke.on?
    pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]All your Pokémon have fainted. You have lost the Nuzlocke challenge! The challenge will now be turned off."))
    Nuzlocke.toggle(false)
    $PokemonGlobal.isNuzlocke = false
    pbStartOver_nuzlocke_x(*args)
  end
  return pbStartOver_nuzlocke_x(*args)
end
#===============================================================================
#  additional entry to Global Metadata for randomized data storage
#===============================================================================
class PokemonGlobalMetadata
  attr_accessor :qNuzlocke
  attr_accessor :nuzlockeData
  attr_accessor :isNuzlocke
  attr_accessor :nuzlockeRules
end
#===============================================================================
#  starts nuzlocke only after obtaining a Pokeball
#===============================================================================
class PokemonBag
  alias pbStoreItem_nuzlocke_x pbStoreItem unless self.method_defined?(:pbStoreItem_nuzlocke_x)
  def pbStoreItem(*args)
    ret = pbStoreItem_nuzlocke_x(*args)
    item = args[0]
    if $PokemonGlobal && $PokemonGlobal.qNuzlocke && GameData::Item.get(item).is_poke_ball?
      Nuzlocke.toggle(true)
      Nuzlocke.set_rules($PokemonGlobal.nuzlockeRules) if !$PokemonGlobal.nuzlockeRules.nil?
      $PokemonGlobal.isNuzlocke = true
    end
    return ret
  end
end
#===============================================================================
#  refresh cache on load
#===============================================================================
class PokemonLoadScreen
  alias pbStartLoadScreen_nuzlocke_x pbStartLoadScreen unless self.method_defined?(:pbStartLoadScreen_nuzlocke_x)
  def pbStartLoadScreen
    ret = pbStartLoadScreen_nuzlocke_x
    if $PokemonGlobal && $PokemonGlobal.isNuzlocke
      Nuzlocke.toggle(true)
      Nuzlocke.set_rules($PokemonGlobal.nuzlockeRules) if !$PokemonGlobal.nuzlockeRules.nil?
    end
    return ret
  end
end
