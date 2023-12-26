#https://reliccastle.com/resources/1123/
#by Dracarys

def pbAutoHeal
  pkmn = $healpoke
	
	return if pkmn.nil? #miniscule bug-fix#by low
	
  # Don't do anything (egg)
  if pkmn.egg?
    return pbPlayBuzzerSE
  end
 
  # Don't do anything (fully healed)
  if pkmn.hp == pkmn.totalhp && pkmn.status == :NONE
    return pbPlayBuzzerSE
  end
 
  # [1] Revive fainted Pokémon
  if pkmn.hp == 0 && $bag.has?(:REVIVE)
    pkmn.hp = (pkmn.totalhp / 2).floor
    $bag.remove(:REVIVE)
    return pbSEPlay("Mining reveal", 100)
  elsif pkmn.hp == 0
    # Don't do anything (KO but no Revives)
    return pbPlayBuzzerSE
  end
 
  # [2] Heal status condition
  statuses = [:SLEEP, :POISON, :BURN, :PARALYSIS, :FROZEN]
  items = [:AWAKENING, :ANTIDOTE, :BURNHEAL, :PARALYZEHEAL, :ICEHEAL]
  for i in 0..4
    if pkmn.status == statuses[i] && $bag.has?(items[i])
      $bag.remove(items[i])
      pkmn.heal_status
      return pbSEPlay("Mining reveal", 100)
    end
  end
  if pkmn.status != :NONE && $bag.has?(:FULLHEAL)
    $bag.remove(:FULLHEAL)
    pkmn.heal_status
    return pbSEPlay("Mining reveal", 100)
  end
 
  # Don't do anything (no status item)
  if pkmn.status != :NONE && pkmn.hp == pkmn.totalhp
    return pbPlayBuzzerSE
  end
 
  # [3] Heal HP
  if pkmn.hp < pkmn.totalhp &&  !$bag.has?(:POTION) && !$bag.has?(:FRESHWATER) &&
    !$bag.has?(:SODAPOP) && !$bag.has?(:SUPERPOTION) && !$bag.has?(:LEMONADE) &&
    !$bag.has?(:MOOMOOMILK) && !$bag.has?(:HYPERPOTION)
    return pbPlayBuzzerSE
  else
    loop do
      hptoheal = pkmn.totalhp - pkmn.hp
      if hptoheal > 0 && $bag.has?(:POTION)
        pkmn.hp += 20
        $bag.remove(:POTION)
      elsif hptoheal > 0 && $bag.has?(:FRESHWATER)
        pkmn.hp += 30
        $bag.remove(:FRESHWATER)
      elsif hptoheal > 0 && $bag.has?(:SODAPOP)
        pkmn.hp += 50
        $bag.remove(:SODAPOP)
      elsif hptoheal > 0 && $bag.has?(:SUPERPOTION)
        pkmn.hp += 60
        $bag.remove(:SUPERPOTION)
      elsif hptoheal > 0 && $bag.has?(:LEMONADE)
        pkmn.hp += 70
        $bag.remove(:LEMONADE)
      elsif hptoheal > 0 && $bag.has?(:MOOMOOMILK)
        pkmn.hp += 100
        $bag.remove(:MOOMOOMILK)
      elsif hptoheal > 0 && $bag.has?(:HYPERPOTION)
        pkmn.hp += 120
        $bag.remove(:HYPERPOTION)
      else
        break
      end
    end
    return pbSEPlay("Mining reveal", 100)
  end
end

class PokemonParty_Scene
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
      $game_temp.in_battle ? "" : _INTL("{1}: Auto Heal",$PokemonSystem.game_controls.find{|c| c.control_action=="Registered Item"}.key_name))
    
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
    
    #added by Gardenette
    if !$game_temp.in_battle && !$tips_log.get_log.include?("Auto Heal")
      $tips_log.tipAutoHeal
    end
    
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
      if !Input.press?(Input::CTRL) && Input.trigger?(Input::SPECIAL) && !$game_temp.in_battle && canswitch != 2
        $healpoke = $player.party[@activecmd]
        pbAutoHeal
        pbRefresh
      elsif Input.press?(Input::CTRL) && Input.trigger?(Input::SPECIAL) && !$game_temp.in_battle && canswitch != 2
        activateVial
        pbRefresh
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
end #of class