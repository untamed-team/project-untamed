#added by Gardenette to provide the following functionality:
#if a pokemon tries to evolve by itself, and the player cancels that evolution,
#the pokemon will not try to evolve on its own again until the evolution is
#initiated by the player
class Pokemon
  attr_accessor :triedEvolving
  
  # Returns whether the pokemon has tried evolving as its current species.
  def triedEvolving?
    return true if @triedEvolving
    return false if !@triedEvolving
  end
  
end #of class Pokemon

#=============================================================================
# Evolving
# set triedEvolving = true if cancelled
# set triedEvolving = false if successful
#=============================================================================
class PokemonEvolutionScene
# Opens the evolution screen
  def pbEvolution(cancancel = true)
    metaplayer1 = SpriteMetafilePlayer.new(@metafile1, @sprites["rsprite1"])
    metaplayer2 = SpriteMetafilePlayer.new(@metafile2, @sprites["rsprite2"])
    metaplayer1.play
    metaplayer2.play
    pbBGMStop
    pbMessageDisplay(@sprites["msgwindow"], "\\se[]" + _INTL("What?") + "\\1") { pbUpdate }
    pbPlayDecisionSE
    @pokemon.play_cry
    @sprites["msgwindow"].text = _INTL("{1} is evolving!", @pokemon.name)
    timer = 0.0
    loop do
      Graphics.update
      Input.update
      pbUpdate
      timer += Graphics.delta_s
      break if timer >= 1.0
    end
    oldstate  = pbSaveSpriteState(@sprites["rsprite1"])
    oldstate2 = pbSaveSpriteState(@sprites["rsprite2"])
    pbMEPlay("Evolution start")
    pbBGMPlay("Evolution")
    canceled = false
    loop do
      pbUpdateNarrowScreen
      metaplayer1.update
      metaplayer2.update
      Graphics.update
      Input.update
      pbUpdate(true)
      if Input.trigger?(Input::BACK) && cancancel
        pbBGMStop
        pbPlayCancelSE
        canceled = true
        break
      end
      break unless metaplayer1.playing? && metaplayer2.playing?
    end
    pbFlashInOut(canceled, oldstate, oldstate2)
    if canceled
      $stats.evolutions_cancelled += 1
      
      #added by Gardenette
      @pokemon.triedEvolving = true
      pbMessageDisplay(@sprites["msgwindow"],
                       _INTL("Huh? {1} stopped evolving!", @pokemon.name)) { pbUpdate }
      pbMessageDisplay(@sprites["msgwindow"],
                       _INTL("You can still evolve {1} from the <c3=0070F8,78B8E8>party screen</c3> when ready!", @pokemon.name)) { pbUpdate }
    else
      pbEvolutionSuccess
    end
  end

  def pbEvolutionSuccess
    $stats.evolution_count += 1
    
    #added by Gardenette
    @pokemon.triedEvolving = false
    
    # Play cry of evolved species
    frames = (GameData::Species.cry_length(@newspecies, @pokemon.form) * Graphics.frame_rate).ceil
    Pokemon.play_cry(@newspecies, @pokemon.form)
    (frames + 4).times do
      Graphics.update
      pbUpdate
    end
    pbBGMStop
    # Success jingle/message
    pbMEPlay("Evolution success")
    newspeciesname = GameData::Species.get(@newspecies).name
    pbMessageDisplay(@sprites["msgwindow"],
                     _INTL("\\se[]Congratulations! Your {1} evolved into {2}!\\wt[80]",
                           @pokemon.name, newspeciesname)) { pbUpdate }
    @sprites["msgwindow"].text = ""
    # Check for consumed item and check if Pokémon should be duplicated
    pbEvolutionMethodAfterEvolution
    # Modify Pokémon to make it evolved
    @pokemon.species = @newspecies
    @pokemon.calc_stats
    @pokemon.ready_to_evolve = false
    # See and own evolved species
    was_owned = $player.owned?(@newspecies)
    $player.pokedex.register(@pokemon)
    $player.pokedex.set_owned(@newspecies)
    moves_to_learn = []
    movelist = @pokemon.getMoveList
    movelist.each do |i|
      next if i[0] != 0 && i[0] != @pokemon.level   # 0 is "learn upon evolution"
      moves_to_learn.push(i[1])
    end
    # Show Pokédex entry for new species if it hasn't been owned before
    if Settings::SHOW_NEW_SPECIES_POKEDEX_ENTRY_MORE_OFTEN && !was_owned && $player.has_pokedex
      pbMessageDisplay(@sprites["msgwindow"],
                       _INTL("{1}'s data was added to the Pokédex.", newspeciesname)) { pbUpdate }
      $player.pokedex.register_last_seen(@pokemon)
      pbFadeOutIn {
        scene = PokemonPokedexInfo_Scene.new
        screen = PokemonPokedexInfoScreen.new(scene)
        screen.pbDexEntry(@pokemon.species)
        @sprites["msgwindow"].text = "" if moves_to_learn.length > 0
        pbEndScreen(false) if moves_to_learn.length == 0
      }
    end
    # Learn moves upon evolution for evolved species
    moves_to_learn.each do |move|
      pbLearnMove(@pokemon, move, true) { pbUpdate }
    end
  end
end #of class PokemonEvolutionScene

#=============================================================================
# Evolution checks - evolution will initiate if !pkmn.triedEvolving
#=============================================================================
def check_evolution_on_level_up
    return check_evolution_internal { |pkmn, new_species, method, parameter|
      success = GameData::Evolution.get(method).call_level_up(pkmn, parameter)
      next (success) ? new_species : nil
    }
  end
  
  def trigger_event_evolution(number)
    new_species = check_evolution_by_event(number)
    if new_species && !@pokemon.triedEvolving
      pbFadeOutInWithMusic {
        evo = PokemonEvolutionScene.new
        evo.pbStartScreen(self, new_species)
        evo.pbEvolution
        evo.pbEndScreen
      }
      return true
    end
    return false
  end
  
#for evolving after battle
def pbEvolutionCheck
  $player.party.each_with_index do |pkmn, i|
    next if !pkmn || pkmn.egg?
    next if pkmn.fainted? && !Settings::CHECK_EVOLUTION_FOR_FAINTED_POKEMON
    # Find an evolution
    new_species = nil
    if new_species.nil? && $game_temp.party_levels_before_battle &&
       $game_temp.party_levels_before_battle[i] &&
       $game_temp.party_levels_before_battle[i] < pkmn.level
      new_species = pkmn.check_evolution_on_level_up
    end
    new_species = pkmn.check_evolution_after_battle(i) if new_species.nil?
    next if new_species.nil?
    
    #added by Gardenette
    if !pkmn.triedEvolving
      # Evolve Pokémon if possible
      evo = PokemonEvolutionScene.new
      evo.pbStartScreen(pkmn, new_species)
      evo.pbEvolution
      evo.pbEndScreen
    end
  end
end

#when using an item to change experience
def pbChangeExp(pkmn, new_exp, scene)
  new_exp = new_exp.clamp(0, pkmn.growth_rate.maximum_exp)
  if pkmn.exp == new_exp
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1}'s Exp. Points remained unchanged.", pkmn.name))
    else
      pbMessage(_INTL("{1}'s Exp. Points remained unchanged.", pkmn.name))
    end
    return
  end
  old_level           = pkmn.level
  old_total_hp        = pkmn.totalhp
  old_attack          = pkmn.attack
  old_defense         = pkmn.defense
  old_special_attack  = pkmn.spatk
  old_special_defense = pkmn.spdef
  old_speed           = pkmn.speed
  if pkmn.exp > new_exp   # Loses Exp
    difference = pkmn.exp - new_exp
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1} lost {2} Exp. Points!", pkmn.name, difference))
    else
      pbMessage(_INTL("{1} lost {2} Exp. Points!", pkmn.name, difference))
    end
    pkmn.exp = new_exp
    pkmn.calc_stats
    scene.pbRefresh
    return if pkmn.level == old_level
    # Level changed
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1} dropped to Lv. {2}!", pkmn.name, pkmn.level))
    else
      pbMessage(_INTL("{1} dropped to Lv. {2}!", pkmn.name, pkmn.level))
    end
    total_hp_diff        = pkmn.totalhp - old_total_hp
    attack_diff          = pkmn.attack - old_attack
    defense_diff         = pkmn.defense - old_defense
    special_attack_diff  = pkmn.spatk - old_special_attack
    special_defense_diff = pkmn.spdef - old_special_defense
    speed_diff           = pkmn.speed - old_speed
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
                           total_hp_diff, attack_diff, defense_diff, special_attack_diff, special_defense_diff, speed_diff), scene)
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
                           pkmn.totalhp, pkmn.attack, pkmn.defense, pkmn.spatk, pkmn.spdef, pkmn.speed), scene)
  else   # Gains Exp
    difference = new_exp - pkmn.exp
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1} gained {2} Exp. Points!", pkmn.name, difference))
    else
      pbMessage(_INTL("{1} gained {2} Exp. Points!", pkmn.name, difference))
    end
    pkmn.exp = new_exp
    pkmn.changeHappiness("vitamin")
    pkmn.calc_stats
    scene.pbRefresh
    return if pkmn.level == old_level
    # Level changed
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1} grew to Lv. {2}!", pkmn.name, pkmn.level))
    else
      pbMessage(_INTL("{1} grew to Lv. {2}!", pkmn.name, pkmn.level))
    end
    total_hp_diff        = pkmn.totalhp - old_total_hp
    attack_diff          = pkmn.attack - old_attack
    defense_diff         = pkmn.defense - old_defense
    special_attack_diff  = pkmn.spatk - old_special_attack
    special_defense_diff = pkmn.spdef - old_special_defense
    speed_diff           = pkmn.speed - old_speed
    pbTopRightWindow(_INTL("Max. HP<r>+{1}\r\nAttack<r>+{2}\r\nDefense<r>+{3}\r\nSp. Atk<r>+{4}\r\nSp. Def<r>+{5}\r\nSpeed<r>+{6}",
                           total_hp_diff, attack_diff, defense_diff, special_attack_diff, special_defense_diff, speed_diff), scene)
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
                           pkmn.totalhp, pkmn.attack, pkmn.defense, pkmn.spatk, pkmn.spdef, pkmn.speed), scene)
    # Learn new moves upon level up
    movelist = pkmn.getMoveList
    movelist.each do |i|
      next if i[0] <= old_level || i[0] > pkmn.level
      pbLearnMove(pkmn, i[1], true) { scene.pbUpdate }
    end
    # Check for evolution
    new_species = pkmn.check_evolution_on_level_up
    if new_species && !pkmn.triedEvolving
      pbFadeOutInWithMusic {
        evo = PokemonEvolutionScene.new
        evo.pbStartScreen(pkmn, new_species)
        evo.pbEvolution
        evo.pbEndScreen
        scene.pbRefresh if scene.is_a?(PokemonPartyScreen)
      }
    end
  end
end

#for evolving after trade
class PokemonTrade_Scene
  def pbEndScreen(need_fade_out = true)
    pbDisposeMessageWindow(@sprites["msgwindow"]) if @sprites["msgwindow"]
    pbFadeOutAndHide(@sprites) if need_fade_out
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    newspecies = @pokemon2.check_evolution_on_trade(@pokemon)
    if newspecies && !@pokemon2.triedEvolving
      evo = PokemonEvolutionScene.new
      evo.pbStartScreen(@pokemon2, newspecies)
      evo.pbEvolution(false)
      evo.pbEndScreen
    end
  end
end #of class
  
#when changing level of pokemon
def pbChangeLevelNoAutoEvolve(pkmn, new_level, scene)
  new_level = new_level.clamp(1, GameData::GrowthRate.max_level)
  if pkmn.level == new_level
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1}'s level remained unchanged.", pkmn.name))
    else
      pbMessage(_INTL("{1}'s level remained unchanged.", pkmn.name))
    end
    return
  end
  old_level           = pkmn.level
  old_total_hp        = pkmn.totalhp
  old_attack          = pkmn.attack
  old_defense         = pkmn.defense
  old_special_attack  = pkmn.spatk
  old_special_defense = pkmn.spdef
  old_speed           = pkmn.speed
  pkmn.level = new_level
  pkmn.calc_stats
  pkmn.hp = 1 if new_level > old_level && pkmn.species_data.base_stats[:HP] == 1
  scene.pbRefresh
  if old_level > new_level
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1} dropped to Lv. {2}!", pkmn.name, pkmn.level))
    else
      pbMessage(_INTL("{1} dropped to Lv. {2}!", pkmn.name, pkmn.level))
    end
    total_hp_diff        = pkmn.totalhp - old_total_hp
    attack_diff          = pkmn.attack - old_attack
    defense_diff         = pkmn.defense - old_defense
    special_attack_diff  = pkmn.spatk - old_special_attack
    special_defense_diff = pkmn.spdef - old_special_defense
    speed_diff           = pkmn.speed - old_speed
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
                           total_hp_diff, attack_diff, defense_diff, special_attack_diff, special_defense_diff, speed_diff), scene)
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
                           pkmn.totalhp, pkmn.attack, pkmn.defense, pkmn.spatk, pkmn.spdef, pkmn.speed), scene)
  else
    pkmn.changeHappiness("vitamin")
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1} grew to Lv. {2}!", pkmn.name, pkmn.level))
    else
      pbMessage(_INTL("{1} grew to Lv. {2}!", pkmn.name, pkmn.level))
    end
    total_hp_diff        = pkmn.totalhp - old_total_hp
    attack_diff          = pkmn.attack - old_attack
    defense_diff         = pkmn.defense - old_defense
    special_attack_diff  = pkmn.spatk - old_special_attack
    special_defense_diff = pkmn.spdef - old_special_defense
    speed_diff           = pkmn.speed - old_speed
    pbTopRightWindow(_INTL("Max. HP<r>+{1}\r\nAttack<r>+{2}\r\nDefense<r>+{3}\r\nSp. Atk<r>+{4}\r\nSp. Def<r>+{5}\r\nSpeed<r>+{6}",
                           total_hp_diff, attack_diff, defense_diff, special_attack_diff, special_defense_diff, speed_diff), scene)
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
                           pkmn.totalhp, pkmn.attack, pkmn.defense, pkmn.spatk, pkmn.spdef, pkmn.speed), scene)
    # Learn new moves upon level up
    movelist = pkmn.getMoveList
    movelist.each do |i|
      next if i[0] <= old_level || i[0] > pkmn.level
      pbLearnMove(pkmn, i[1], true) { scene.pbUpdate }
    end
    # Check for evolution
    new_species = pkmn.check_evolution_on_level_up
    if new_species && !pkmn.triedEvolving
      pbFadeOutInWithMusic {
        evo = PokemonEvolutionScene.new
        evo.pbStartScreen(pkmn, new_species)
        evo.pbEvolution
        evo.pbEndScreen
        scene.pbRefresh if scene.is_a?(PokemonPartyScreen)
      }
    end
  end
end

#=============================================================================
# Evolve from Party script
#=============================================================================
class PokemonPartyPanel < Sprite
  attr_reader :pokemon
  attr_reader :active
  attr_reader :selected
  attr_reader :preselected
  attr_reader :switching
  attr_reader :text

  TEXT_BASE_COLOR    = Color.new(248, 248, 248)
  TEXT_SHADOW_COLOR  = Color.new(40, 40, 40)
  HP_BAR_WIDTH       = 96
  STATUS_ICON_WIDTH  = 44
  STATUS_ICON_HEIGHT = 16

  def initialize(pokemon, index, viewport = nil, evoreqs = nil)
    super(viewport)
    @pokemon = pokemon
    @evoreqs = evoreqs
    refresh_evoreqs
    @active = (index == 0)   # true = rounded panel, false = rectangular panel
    @refreshing = true
    self.x = (index % 2) * Graphics.width / 2
    self.y = (16 * (index % 2)) + (96 * (index / 2))
    @panelbgsprite = ChangelingSprite.new(0, 0, viewport)
    @panelbgsprite.z = self.z
    if @active   # Rounded panel
      @panelbgsprite.addBitmap("able", "Graphics/Pictures/Party/panel_round")
      @panelbgsprite.addBitmap("ablesel", "Graphics/Pictures/Party/panel_round_sel")
      @panelbgsprite.addBitmap("fainted", "Graphics/Pictures/Party/panel_round_faint")
      @panelbgsprite.addBitmap("faintedsel", "Graphics/Pictures/Party/panel_round_faint_sel")
      @panelbgsprite.addBitmap("swap", "Graphics/Pictures/Party/panel_round_swap")
      @panelbgsprite.addBitmap("swapsel", "Graphics/Pictures/Party/panel_round_swap_sel")
      @panelbgsprite.addBitmap("swapsel2", "Graphics/Pictures/Party/panel_round_swap_sel2")
    else   # Rectangular panel
      @panelbgsprite.addBitmap("able", "Graphics/Pictures/Party/panel_rect")
      @panelbgsprite.addBitmap("ablesel", "Graphics/Pictures/Party/panel_rect_sel")
      @panelbgsprite.addBitmap("fainted", "Graphics/Pictures/Party/panel_rect_faint")
      @panelbgsprite.addBitmap("faintedsel", "Graphics/Pictures/Party/panel_rect_faint_sel")
      @panelbgsprite.addBitmap("swap", "Graphics/Pictures/Party/panel_rect_swap")
      @panelbgsprite.addBitmap("swapsel", "Graphics/Pictures/Party/panel_rect_swap_sel")
      @panelbgsprite.addBitmap("swapsel2", "Graphics/Pictures/Party/panel_rect_swap_sel2")
    end
    @hpbgsprite = ChangelingSprite.new(0, 0, viewport)
    @hpbgsprite.z = self.z + 1
    @hpbgsprite.addBitmap("able", "Graphics/Pictures/Party/overlay_hp_back")
    @hpbgsprite.addBitmap("fainted", "Graphics/Pictures/Party/overlay_hp_back_faint")
    @hpbgsprite.addBitmap("swap", "Graphics/Pictures/Party/overlay_hp_back_swap")
    @ballsprite = ChangelingSprite.new(0, 0, viewport)
    @ballsprite.z = self.z + 5
    @ballsprite.addBitmap("desel", "Graphics/Pictures/Party/icon_ball")
    @ballsprite.addBitmap("sel", "Graphics/Pictures/Party/icon_ball_sel")
    @ballsprite.addBitmap("desel_canevo", "Graphics/Pictures/Party/evo_icon_ball") #stygma
    @ballsprite.addBitmap("sel_canevo", "Graphics/Pictures/Party/evo_icon_ball_sel") #stygma
    @pkmnsprite = PokemonIconSprite.new(pokemon, viewport)
    @pkmnsprite.setOffset(PictureOrigin::CENTER)
    @pkmnsprite.active = @active
    @pkmnsprite.z      = self.z + 6
    @helditemsprite = HeldItemIconSprite.new(0, 0, @pokemon, viewport)
    #@helditemsprite.z = self.z + 3
    #edited by Gardenette
    @helditemsprite.z = 99
    @overlaysprite = BitmapSprite.new(Graphics.width, Graphics.height, viewport)
    @overlaysprite.z = self.z + 4
    pbSetSystemFont(@overlaysprite.bitmap)
    @hpbar       = AnimatedBitmap.new("Graphics/Pictures/Party/overlay_hp")
    @statuses    = AnimatedBitmap.new(_INTL("Graphics/Pictures/statuses"))
    @selected      = false
    @preselected   = false
    @switching     = false
    @text          = nil
    @refreshBitmap = true
    @refreshing    = false
    refresh
  end

  def dispose
    @panelbgsprite.dispose
    @hpbgsprite.dispose
    @ballsprite.dispose
    @pkmnsprite.dispose
    @helditemsprite.dispose
    @overlaysprite.bitmap.dispose
    @overlaysprite.dispose
    @hpbar.dispose
    @statuses.dispose
    super
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end

  def color=(value)
    super
    refresh
  end

  def text=(value)
    return if @text == value
    @text = value
    @refreshBitmap = true
    refresh
  end

  def pokemon=(value)
    @pokemon = value
    refresh_evoreqs
    @pkmnsprite.pokemon = value if @pkmnsprite && !@pkmnsprite.disposed?
    @helditemsprite.pokemon = value if @helditemsprite && !@helditemsprite.disposed?
    @refreshBitmap = true
    refresh
  end

  def selected=(value)
    return if @selected == value
    @selected = value
    refresh
  end

  def preselected=(value)
    return if @preselected == value
    @preselected = value
    refresh
  end

  def switching=(value)
    return if @switching == value
    @switching = value
    refresh
  end

  def hp; return @pokemon.hp; end

  def refresh_evoreqs
    return if @pokemon.egg? || @evoreqs.nil?
    # [new_species, item[optional]
    @evoreqs.clear
    # [new_species, method, parameter, boolean]
    GameData::Species.get(@pokemon.species).get_evolutions(true).each do |evo|
      case evo[1].to_s
      when "TradeSpecies"
        # menu handler shouldnt care what species it requires since its checked here
        # its not like you lose the mon or anything
        @evoreqs.push([evo[0], nil]) if $player.has_species?(evo[2])
      when /\AItem/
        @evoreqs.push([evo[0], evo[2]]) if $bag.has?(evo[2]) && @pokemon.check_evolution_on_use_item(evo[2])
      when /\ATrade/
        # technically should pass a Pokemon object but if that ever becomes relevant something must have gone wrong
        @evoreqs.push([evo[0], evo[2]]) if @pokemon.check_evolution_on_trade(nil)
      else
        @evoreqs.push([evo[0], nil]) if @pokemon.check_evolution_on_level_up
      end
    end
  end

  def refresh_panel_graphic
    return if !@panelbgsprite || @panelbgsprite.disposed?
    if self.selected
      if self.preselected
        @panelbgsprite.changeBitmap("swapsel2")
      elsif @switching
        @panelbgsprite.changeBitmap("swapsel")
      elsif @pokemon.fainted?
        @panelbgsprite.changeBitmap("faintedsel")
      else
        @panelbgsprite.changeBitmap("ablesel")
      end
    else
      if self.preselected
        @panelbgsprite.changeBitmap("swap")
      elsif @pokemon.fainted?
        @panelbgsprite.changeBitmap("fainted")
      else
        @panelbgsprite.changeBitmap("able")
      end
    end
    @panelbgsprite.x     = self.x
    @panelbgsprite.y     = self.y
    @panelbgsprite.color = self.color
  end

  def refresh_hp_bar_graphic
    return if !@hpbgsprite || @hpbgsprite.disposed?
    @hpbgsprite.visible = (!@pokemon.egg? && !(@text && @text.length > 0))
    return if !@hpbgsprite.visible
    if self.preselected || (self.selected && @switching)
      @hpbgsprite.changeBitmap("swap")
    elsif @pokemon.fainted?
      @hpbgsprite.changeBitmap("fainted")
    else
      @hpbgsprite.changeBitmap("able")
    end
    @hpbgsprite.x     = self.x + 96
    @hpbgsprite.y     = self.y + 50
    @hpbgsprite.color = self.color
  end

  def refresh_ball_graphic
    return if !@ballsprite || @ballsprite.disposed?
    bitmapname = (self.selected) ? "sel" : "desel"
    bitmapname << "_canevo" unless @evoreqs.nil? || @evoreqs.empty?
    @ballsprite.changeBitmap(bitmapname)
    @ballsprite.x     = self.x + 10
    @ballsprite.y     = self.y
    @ballsprite.color = self.color
  end

  def refresh_pokemon_icon
    return if !@pkmnsprite || @pkmnsprite.disposed?
    @pkmnsprite.x        = self.x + 60
    @pkmnsprite.y        = self.y + 40
    @pkmnsprite.color    = self.color
    @pkmnsprite.selected = self.selected
  end

  def refresh_held_item_icon
    return if !@helditemsprite || @helditemsprite.disposed? || !@helditemsprite.visible
    #@helditemsprite.x     = self.x + 62
    #edited by Gardenette
    @helditemsprite.x     = self.x + 80
    @helditemsprite.y     = self.y + 48
    @helditemsprite.color = self.color
  end

  def refresh_overlay_information
    return if !@refreshBitmap
    @overlaysprite.bitmap&.clear
    draw_name
    draw_level
    draw_gender
    draw_hp
    draw_status
    draw_shiny_icon
    draw_annotation
  end

  def draw_name
    pbDrawTextPositions(@overlaysprite.bitmap,
                        [[@pokemon.name, 96, 22, 0, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR]])
  end

  def draw_level
    return if @pokemon.egg?
    # "Lv" graphic
    pbDrawImagePositions(@overlaysprite.bitmap,
                         [["Graphics/Pictures/Party/overlay_lv", 20, 70, 0, 0, 22, 14]])
    # Level number
    pbSetSmallFont(@overlaysprite.bitmap)
    pbDrawTextPositions(@overlaysprite.bitmap,
                        [[@pokemon.level.to_s, 42, 68, 0, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR]])
    pbSetSystemFont(@overlaysprite.bitmap)
  end

  def draw_gender
    return if @pokemon.egg? || @pokemon.genderless?
    gender_text  = (@pokemon.male?) ? _INTL("♂") : _INTL("♀")
    base_color   = (@pokemon.male?) ? Color.new(0, 112, 248) : Color.new(232, 32, 16)
    shadow_color = (@pokemon.male?) ? Color.new(120, 184, 232) : Color.new(248, 168, 184)
    pbDrawTextPositions(@overlaysprite.bitmap,
                        [[gender_text, 224, 22, 0, base_color, shadow_color]])
  end

  def draw_hp
    return if @pokemon.egg? || (@text && @text.length > 0)
    # HP numbers
    hp_text = sprintf("% 3d /% 3d", @pokemon.hp, @pokemon.totalhp)
    pbDrawTextPositions(@overlaysprite.bitmap,
                        [[hp_text, 224, 66, 1, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR]])
    # HP bar
    if @pokemon.able?
      w = @pokemon.hp * HP_BAR_WIDTH / @pokemon.totalhp.to_f
      w = 1 if w < 1
      w = ((w / 2).round) * 2   # Round to the nearest 2 pixels
      hpzone = 0
      hpzone = 1 if @pokemon.hp <= (@pokemon.totalhp / 2).floor
      hpzone = 2 if @pokemon.hp <= (@pokemon.totalhp / 4).floor
      hprect = Rect.new(0, hpzone * 8, w, 8)
      @overlaysprite.bitmap.blt(128, 52, @hpbar.bitmap, hprect)
    end
  end

  def draw_status
    return if @pokemon.egg? || (@text && @text.length > 0)
    status = -1
    if @pokemon.fainted?
      status = GameData::Status.count - 1
    elsif @pokemon.status != :NONE
      status = GameData::Status.get(@pokemon.status).icon_position
    elsif @pokemon.pokerusStage == 1
      status = GameData::Status.count
    end
    return if status < 0
    statusrect = Rect.new(0, STATUS_ICON_HEIGHT * status, STATUS_ICON_WIDTH, STATUS_ICON_HEIGHT)
    @overlaysprite.bitmap.blt(78, 68, @statuses.bitmap, statusrect)
  end

  def draw_shiny_icon
    return if @pokemon.egg? || !@pokemon.shiny?
    pbDrawImagePositions(@overlaysprite.bitmap,
                         [["Graphics/Pictures/shiny", 80, 48, 0, 0, 16, 16]])
  end

  def draw_annotation
    return if !@text || @text.length == 0
    pbDrawTextPositions(@overlaysprite.bitmap,
                        [[@text, 96, 62, 0, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR]])
  end

  def refresh
    return if disposed?
    return if @refreshing
    @refreshing = true
    refresh_panel_graphic
    refresh_hp_bar_graphic
    refresh_ball_graphic
    refresh_pokemon_icon
    refresh_held_item_icon
    if @overlaysprite && !@overlaysprite.disposed?
      @overlaysprite.x     = self.x
      @overlaysprite.y     = self.y
      @overlaysprite.color = self.color
    end
    refresh_overlay_information
    @refreshBitmap = false
    @refreshing = false
  end

  def update
    super
    @panelbgsprite.update if @panelbgsprite && !@panelbgsprite.disposed?
    @hpbgsprite.update if @hpbgsprite && !@hpbgsprite.disposed?
    @ballsprite.update if @ballsprite && !@ballsprite.disposed?
    @pkmnsprite.update if @pkmnsprite && !@pkmnsprite.disposed?
    @helditemsprite.update if @helditemsprite && !@helditemsprite.disposed?
  end
end

class PokemonParty_Scene
  attr_reader :all_evoreqs

  def pbStartScene(party, starthelptext, annotations = nil, multiselect = false, can_access_storage = false)
    @sprites = {}
    @party = party
    @all_evoreqs = []
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @multiselect = multiselect
    @can_access_storage = can_access_storage
    addBackgroundPlane(@sprites, "partybg", "Party/bg", @viewport)
    @sprites["messagebox"] = Window_AdvancedTextPokemon.new("")
    @sprites["messagebox"].z              = 50
    @sprites["messagebox"].viewport       = @viewport
    @sprites["messagebox"].visible        = false
    @sprites["messagebox"].letterbyletter = true
    pbBottomLeftLines(@sprites["messagebox"], 2)
    @sprites["storagetext"] = Window_UnformattedTextPokemon.new(
      @can_access_storage ? _INTL("[Special]: To Boxes") : ""
    )
    @sprites["storagetext"].x           = 32
    @sprites["storagetext"].y           = Graphics.height - @sprites["messagebox"].height - 16
    @sprites["storagetext"].z           = 10
    @sprites["storagetext"].viewport    = @viewport
    @sprites["storagetext"].baseColor   = Color.new(248, 248, 248)
    @sprites["storagetext"].shadowColor = Color.new(0, 0, 0)
    @sprites["storagetext"].windowskin  = nil
    @sprites["helpwindow"] = Window_UnformattedTextPokemon.new(starthelptext)
    @sprites["helpwindow"].viewport = @viewport
    @sprites["helpwindow"].visible  = true
    pbBottomLeftLines(@sprites["helpwindow"], 1)
    pbSetHelpText(starthelptext)
    # Add party Pokémon sprites
    Settings::MAX_PARTY_SIZE.times do |i|
      if @party[i]
        @sprites["pokemon#{i}"] = PokemonPartyPanel.new(@party[i], i, @viewport, (@all_evoreqs[i] = []))
      else
        @sprites["pokemon#{i}"] = PokemonPartyBlankPanel.new(@party[i], i, @viewport)
      end
      @sprites["pokemon#{i}"].text = annotations[i] if annotations
    end
    if @multiselect
      @sprites["pokemon#{Settings::MAX_PARTY_SIZE}"] = PokemonPartyConfirmSprite.new(@viewport)
      @sprites["pokemon#{Settings::MAX_PARTY_SIZE + 1}"] = PokemonPartyCancelSprite2.new(@viewport)
    else
      @sprites["pokemon#{Settings::MAX_PARTY_SIZE}"] = PokemonPartyCancelSprite.new(@viewport)
    end
    # Select first Pokémon
    @activecmd = 0
    @sprites["pokemon0"].selected = true
    pbFadeInAndShow(@sprites) { update }
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbDisplay(text)
    @sprites["messagebox"].text    = text
    @sprites["messagebox"].visible = true
    @sprites["helpwindow"].visible = false
    pbPlayDecisionSE
    loop do
      Graphics.update
      Input.update
      self.update
      if @sprites["messagebox"].busy?
        if Input.trigger?(Input::USE)
          pbPlayDecisionSE if @sprites["messagebox"].pausing?
          @sprites["messagebox"].resume
        end
      elsif Input.trigger?(Input::BACK) || Input.trigger?(Input::USE)
        break
      end
    end
    @sprites["messagebox"].visible = false
    @sprites["helpwindow"].visible = true
  end

  def pbDisplayConfirm(text)
    ret = -1
    @sprites["messagebox"].text    = text
    @sprites["messagebox"].visible = true
    @sprites["helpwindow"].visible = false
    using(cmdwindow = Window_CommandPokemon.new([_INTL("Yes"), _INTL("No")])) {
      cmdwindow.visible = false
      pbBottomRight(cmdwindow)
      cmdwindow.y -= @sprites["messagebox"].height
      cmdwindow.z = @viewport.z + 1
      loop do
        Graphics.update
        Input.update
        cmdwindow.visible = true if !@sprites["messagebox"].busy?
        cmdwindow.update
        self.update
        if !@sprites["messagebox"].busy?
          if Input.trigger?(Input::BACK)
            ret = false
            break
          elsif Input.trigger?(Input::USE) && @sprites["messagebox"].resume
            ret = (cmdwindow.index == 0)
            break
          end
        end
      end
    }
    @sprites["messagebox"].visible = false
    @sprites["helpwindow"].visible = true
    return ret
  end

  def pbShowCommands(helptext, commands, index = 0)
    ret = -1
    helpwindow = @sprites["helpwindow"]
    helpwindow.visible = true
    using(cmdwindow = Window_CommandPokemonColor.new(commands)) {
      cmdwindow.z     = @viewport.z + 1
      cmdwindow.index = index
      pbBottomRight(cmdwindow)
      helpwindow.resizeHeightToFit(helptext, Graphics.width - cmdwindow.width)
      helpwindow.text = helptext
      pbBottomLeft(helpwindow)
      loop do
        Graphics.update
        Input.update
        cmdwindow.update
        self.update
        if Input.trigger?(Input::BACK)
          pbPlayCancelSE
          ret = -1
          break
        elsif Input.trigger?(Input::USE)
          pbPlayDecisionSE
          ret = cmdwindow.index
          break
        end
      end
    }
    return ret
  end

  def pbChooseNumber(helptext, maximum, initnum = 1)
    return UIHelper.pbChooseNumber(@sprites["helpwindow"], helptext, maximum, initnum) { update }
  end

  def pbSetHelpText(helptext)
    helpwindow = @sprites["helpwindow"]
    pbBottomLeftLines(helpwindow, 1)
    helpwindow.text = helptext
    helpwindow.width = 398
    helpwindow.visible = true
  end

  def pbHasAnnotations?
    return !@sprites["pokemon0"].text.nil?
  end

  def pbAnnotate(annot)
    Settings::MAX_PARTY_SIZE.times do |i|
      @sprites["pokemon#{i}"].text = (annot) ? annot[i] : nil
    end
  end

  def pbSelect(item)
    @activecmd = item
    numsprites = Settings::MAX_PARTY_SIZE + ((@multiselect) ? 2 : 1)
    numsprites.times do |i|
      @sprites["pokemon#{i}"].selected = (i == @activecmd)
    end
  end

  def pbPreSelect(item)
    @activecmd = item
  end

  def pbSwitchBegin(oldid, newid)
    pbSEPlay("GUI party switch")
    oldsprite = @sprites["pokemon#{oldid}"]
    newsprite = @sprites["pokemon#{newid}"]
    timeTaken = Graphics.frame_rate * 4 / 10
    distancePerFrame = (Graphics.width / (2.0 * timeTaken)).ceil
    timeTaken.times do
      oldsprite.x += (oldid & 1) == 0 ? -distancePerFrame : distancePerFrame
      newsprite.x += (newid & 1) == 0 ? -distancePerFrame : distancePerFrame
      Graphics.update
      Input.update
      self.update
    end
  end

  def pbSwitchEnd(oldid, newid)
    pbSEPlay("GUI party switch")
    oldsprite = @sprites["pokemon#{oldid}"]
    newsprite = @sprites["pokemon#{newid}"]
    oldsprite.pokemon = @party[oldid]
    newsprite.pokemon = @party[newid]
    timeTaken = Graphics.frame_rate * 4 / 10
    distancePerFrame = (Graphics.width / (2.0 * timeTaken)).ceil
    timeTaken.times do
      oldsprite.x -= (oldid & 1) == 0 ? -distancePerFrame : distancePerFrame
      newsprite.x -= (newid & 1) == 0 ? -distancePerFrame : distancePerFrame
      Graphics.update
      Input.update
      self.update
    end
    Settings::MAX_PARTY_SIZE.times do |i|
      @sprites["pokemon#{i}"].preselected = false
      @sprites["pokemon#{i}"].switching   = false
    end
    pbRefresh
  end

  def pbClearSwitching
    Settings::MAX_PARTY_SIZE.times do |i|
      @sprites["pokemon#{i}"].preselected = false
      @sprites["pokemon#{i}"].switching   = false
    end
  end

  def pbSummary(pkmnid, inbattle = false)
    oldsprites = pbFadeOutAndHide(@sprites)
    scene = PokemonSummary_Scene.new
    screen = PokemonSummaryScreen.new(scene, inbattle)
    screen.pbStartScreen(@party, pkmnid)
    yield if block_given?
    pbFadeInAndShow(@sprites, oldsprites)
  end

  def pbChooseItem(bag)
    ret = nil
    pbFadeOutIn {
      scene = PokemonBag_Scene.new
      screen = PokemonBagScreen.new(scene, bag)
      ret = screen.pbChooseItemScreen(proc { |item| GameData::Item.get(item).can_hold? })
      yield if block_given?
    }
    return ret
  end

  def pbUseItem(bag, pokemon)
    ret = nil
    pbFadeOutIn {
      scene = PokemonBag_Scene.new
      screen = PokemonBagScreen.new(scene, bag)
      ret = screen.pbChooseItemScreen(proc { |item|
        itm = GameData::Item.get(item)
        next false if !pbCanUseOnPokemon?(itm)
        next false if pokemon.hyper_mode && !GameData::Item.get(item)&.is_scent?
        if itm.is_machine?
          move = itm.move
          next false if pokemon.hasMove?(move) || !pokemon.compatible_with_move?(move)
        end
        
        #increment achievement
        Achievements.incrementProgress("ITEMS_USED",1)
        next true
      })
      yield if block_given?
    }
    return ret
  end

  def pbChoosePokemon(switching = false, initialsel = -1, canswitch = 0)
    Settings::MAX_PARTY_SIZE.times do |i|
      @sprites["pokemon#{i}"].preselected = (switching && i == @activecmd)
      @sprites["pokemon#{i}"].switching   = switching
    end
    @activecmd = initialsel if initialsel >= 0
    pbRefresh
    loop do
      Graphics.update
      Input.update
      self.update
      oldsel = @activecmd
      key = -1
      key = Input::DOWN if Input.repeat?(Input::DOWN)
      key = Input::RIGHT if Input.repeat?(Input::RIGHT)
      key = Input::LEFT if Input.repeat?(Input::LEFT)
      key = Input::UP if Input.repeat?(Input::UP)
      if key >= 0
        @activecmd = pbChangeSelection(key, @activecmd)
      end
      if @activecmd != oldsel   # Changing selection
        pbPlayCursorSE
        numsprites = Settings::MAX_PARTY_SIZE + ((@multiselect) ? 2 : 1)
        numsprites.times do |i|
          @sprites["pokemon#{i}"].selected = (i == @activecmd)
        end
      end
      cancelsprite = Settings::MAX_PARTY_SIZE + ((@multiselect) ? 1 : 0)
      if Input.trigger?(Input::SPECIAL) && @can_access_storage && canswitch != 2
        pbPlayDecisionSE
        pbFadeOutIn {
          scene = PokemonStorageScene.new
          screen = PokemonStorageScreen.new(scene, $PokemonStorage)
          screen.pbStartScreen(0)
          pbHardRefresh
        }
      elsif Input.trigger?(Input::ACTION) && canswitch == 1 && @activecmd != cancelsprite
        pbPlayDecisionSE
        return [1, @activecmd]
      elsif Input.trigger?(Input::ACTION) && canswitch == 2
        return -1
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE if !switching
        return -1
      elsif Input.trigger?(Input::USE)
        if @activecmd == cancelsprite
          (switching) ? pbPlayDecisionSE : pbPlayCloseMenuSE
          return -1
        else
          pbPlayDecisionSE
          return @activecmd
        end
      end
    end
  end

  def pbChangeSelection(key, currentsel)
    numsprites = Settings::MAX_PARTY_SIZE + ((@multiselect) ? 2 : 1)
    case key
    when Input::LEFT
      loop do
        currentsel -= 1
        break unless currentsel > 0 && currentsel < @party.length && !@party[currentsel]
      end
      if currentsel >= @party.length && currentsel < Settings::MAX_PARTY_SIZE
        currentsel = @party.length - 1
      end
      currentsel = numsprites - 1 if currentsel < 0
    when Input::RIGHT
      loop do
        currentsel += 1
        break unless currentsel < @party.length && !@party[currentsel]
      end
      if currentsel == @party.length
        currentsel = Settings::MAX_PARTY_SIZE
      elsif currentsel == numsprites
        currentsel = 0
      end
    when Input::UP
      if currentsel >= Settings::MAX_PARTY_SIZE
        currentsel -= 1
        while currentsel > 0 && currentsel < Settings::MAX_PARTY_SIZE && !@party[currentsel]
          currentsel -= 1
        end
      else
        loop do
          currentsel -= 2
          break unless currentsel > 0 && !@party[currentsel]
        end
      end
      if currentsel >= @party.length && currentsel < Settings::MAX_PARTY_SIZE
        currentsel = @party.length - 1
      end
      currentsel = numsprites - 1 if currentsel < 0
    when Input::DOWN
      if currentsel >= Settings::MAX_PARTY_SIZE - 1
        currentsel += 1
      else
        currentsel += 2
        currentsel = Settings::MAX_PARTY_SIZE if currentsel < Settings::MAX_PARTY_SIZE && !@party[currentsel]
      end
      if currentsel >= @party.length && currentsel < Settings::MAX_PARTY_SIZE
        currentsel = Settings::MAX_PARTY_SIZE
      elsif currentsel >= numsprites
        currentsel = 0
      end
    end
    return currentsel
  end

  def pbHardRefresh
    oldtext = []
    lastselected = -1
    Settings::MAX_PARTY_SIZE.times do |i|
      oldtext.push(@sprites["pokemon#{i}"].text)
      lastselected = i if @sprites["pokemon#{i}"].selected
      @sprites["pokemon#{i}"].dispose
    end
    lastselected = @party.length - 1 if lastselected >= @party.length
    lastselected = 0 if lastselected < 0
    Settings::MAX_PARTY_SIZE.times do |i|
      if @party[i]
        @sprites["pokemon#{i}"] = PokemonPartyPanel.new(@party[i], i, @viewport, (@all_evoreqs[i] = []))
      else
        @sprites["pokemon#{i}"] = PokemonPartyBlankPanel.new(@party[i], i, @viewport)
      end
      @sprites["pokemon#{i}"].text = oldtext[i]
    end
    pbSelect(lastselected)
  end

  def pbRefresh
    Settings::MAX_PARTY_SIZE.times do |i|
      sprite = @sprites["pokemon#{i}"]
      if sprite
        if sprite.is_a?(PokemonPartyPanel)
          sprite.pokemon = sprite.pokemon
        else
          sprite.refresh
        end
      end
    end
  end

  def pbRefreshSingle(i)
    sprite = @sprites["pokemon#{i}"]
    if sprite
      if sprite.is_a?(PokemonPartyPanel)
        sprite.pokemon = sprite.pokemon
      else
        sprite.refresh
      end
    end
  end

  def update
    pbUpdateSpriteHash(@sprites)
  end
end

MenuHandlers.add(:party_menu, :evolve, {
  "name"      => [_INTL("Evolve"),1],
  "order"     => 39,
  "condition" => proc { |screen, party, party_idx| next !screen.scene.all_evoreqs[party_idx].empty? },
  "effect"    => proc { |screen, party, party_idx|
    evoreqs = screen.scene.all_evoreqs[party_idx]
    case evoreqs.length
    when 0
      pbDisplay(_INTL("This Pokémon can't evolve."))
      next
    when 1
      evoreq = evoreqs[0]
    else
      evoreq = evoreqs[screen.scene.pbShowCommands(
        _INTL("Which species would you like to evolve into?"),
        evoreqs.map { |req| GameData::Species.get(req[0]).real_name }
      )]
    end
    if evoreq[1] # requires an item
      itemname = GameData::Item.get(evoreq[1]).name
      next unless @scene.pbConfirmMessage(_INTL("This will consume a {1}. Do you want to continue?", itemname))
      $bag.remove(evoreq[1])
    end
    pbFadeOutInWithMusic {
      evo = PokemonEvolutionScene.new
      evo.pbStartScreen(party[party_idx], evoreq[0])
      evo.pbEvolution
      evo.pbEndScreen
      screen.pbRefresh
    }
  }
})