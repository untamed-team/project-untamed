#######################Confirm Forget Move#######################
#===============================================================================
# Confirm Forget Move (Fear not a Misclick!)
#===============================================================================
class PokemonSummary_Scene
  def pbChooseMoveToForget(move_to_learn)
    new_move = (move_to_learn) ? Pokemon::Move.new(move_to_learn) : nil
    selmove = 0
    maxmove = (new_move) ? Pokemon::MAX_MOVES : Pokemon::MAX_MOVES - 1
    while !@confirmed
      loop do
        Graphics.update
        Input.update
        pbUpdate
        if Input.trigger?(Input::BACK)
          selmove = Pokemon::MAX_MOVES
          pbPlayCloseMenuSE if new_move
          #confirm the player wants to back out if BACK is pressed before a move
          #is selected
          @confirmed = true
          break
        elsif Input.trigger?(Input::USE)
          #pbPlayDecisionSE
          break
        elsif Input.trigger?(Input::UP)
          selmove -= 1
          selmove = maxmove if selmove < 0
          if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
            selmove = @pokemon.numMoves - 1
          end
          @sprites["movesel"].index = selmove
          selected_move = (selmove == Pokemon::MAX_MOVES) ? new_move : @pokemon.moves[selmove]
          drawSelectedMove(new_move, selected_move)
        elsif Input.trigger?(Input::DOWN)
          selmove += 1
          selmove = 0 if selmove > maxmove
          if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
            selmove = (new_move) ? maxmove : 0
          end
          @sprites["movesel"].index = selmove
          selected_move = (selmove == Pokemon::MAX_MOVES) ? new_move : @pokemon.moves[selmove]
          drawSelectedMove(new_move, selected_move)
        end
      end #of loop do
      if selmove < 4
        #a move was selected and the player did not back out
        oldMoveName = @pokemon.moves[selmove].name
        if pbConfirmMessage(_INTL("Forget {1} to learn {2}?", oldMoveName, new_move.name))
          @confirmed = true
        else
          #go back into the loop
          @confirmed = false
        end
      end
    end #of while !@confirmed
    return (selmove == Pokemon::MAX_MOVES) ? -1 : selmove
  end
end

#######################Sweet Scent Modifications#######################
#===============================================================================
# Sweet Scent
#===============================================================================
def pbSweetScent
  #if $game_screen.weather_type != :None
  #  pbMessage(_INTL("The sweet scent faded for some reason..."))
  #  return
  #end
 
  #play the se for sweet scent
  pbSEPlay("Anim/Sweet Scent")
 
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 999999
  count = 0
  viewport.color.red   = 255
  viewport.color.green = 105
  viewport.color.blue  = 180
  #was alphaDiff = 12 * 20 / Graphics.frame_rate
  #changed from 12 to 4 to slow down the animation
  alphaDiff = 4 * 20 / Graphics.frame_rate
  loop do
    if count==0 && viewport.color.alpha<128
      viewport.color.alpha += alphaDiff
    elsif count>Graphics.frame_rate/4
      viewport.color.alpha -= alphaDiff
      break if viewport.color.alpha<=0
    else
      count += 1
    end
    Graphics.update
    Input.update
    pbUpdateSceneMap

  end
  viewport.dispose
  enctype = $PokemonEncounters.encounter_type
  if !enctype || !$PokemonEncounters.encounter_possible_here? ||
     !pbEncounter(enctype)
    pbMessage(_INTL("There appears to be nothing here..."))
  end
end

#######################Pokemon Storage Modifications#######################

#===============================================================================
# Pokémon storage visuals
#===============================================================================
class PokemonStorageScene
  attr_reader :quickswap

def pbSetArrow(arrow, selection)
    case selection
    when -1, -4, -5 # Box name, move left, move right
      #added by Gardenette
      if !Input.press?(Input::CTRL)
      arrow.x = 157 * 2
      arrow.y = -12 * 2
      end #added by Gardenette
    when -2 # Party Pokémon
      arrow.x = 119 * 2
      arrow.y = 139 * 2
    when -3 # Close Box
      arrow.x = 207 * 2
      arrow.y = 139 * 2
    else
      arrow.x = (97 + (24 * (selection % PokemonBox::BOX_WIDTH))) * 2
      arrow.y = (8 + (24 * (selection / PokemonBox::BOX_WIDTH))) * 2
    end
  end

  def pbChangeSelection(key, selection)
    case key
    when Input::UP
      case selection
      when -1   # Box name
        selection = -2
      when -2   # Party
        selection = PokemonBox::BOX_SIZE - 1 - (PokemonBox::BOX_WIDTH * 2 / 3)   # 25
      when -3   # Close Box
        selection = PokemonBox::BOX_SIZE - (PokemonBox::BOX_WIDTH / 3)   # 28
      else
        selection -= PokemonBox::BOX_WIDTH
        selection = -1 if selection < 0
      end
    when Input::DOWN
      case selection
      when -1   # Box name
        selection = PokemonBox::BOX_WIDTH / 3   # 2
      when -2   # Party
        selection = -1
      when -3   # Close Box
        selection = -1
      else
        selection += PokemonBox::BOX_WIDTH
        if selection >= PokemonBox::BOX_SIZE
          if selection < PokemonBox::BOX_SIZE + (PokemonBox::BOX_WIDTH / 2)
            selection = -2   # Party
          else
            selection = -3   # Close Box
          end
        end
      end
    when Input::LEFT
      #added by Gardenette
      if !Input.press?(Input::CTRL)

      if selection == -1   # Box name
        selection = -4   # Move to previous box
      elsif selection == -2
        selection = -3
      elsif selection == -3
        selection = -2
      elsif (selection % PokemonBox::BOX_WIDTH) == 0   # Wrap around
        selection += PokemonBox::BOX_WIDTH - 1
      else
        selection -= 1
      end
      
      end #added by Gardenette
    when Input::RIGHT
      #added by Gardenette
      if !Input.press?(Input::CTRL)

      if selection == -1   # Box name
        selection = -5   # Move to next box
      elsif selection == -2
        selection = -3
      elsif selection == -3
        selection = -2
      elsif (selection % PokemonBox::BOX_WIDTH) == PokemonBox::BOX_WIDTH - 1   # Wrap around
        selection -= PokemonBox::BOX_WIDTH - 1
      else
        selection += 1
      end
      end #added by Gardenette
    end
    return selection
  end

  def pbPartySetArrow(arrow, selection)
    return if selection < 0
    xvalues = []   # [200, 272, 200, 272, 200, 272, 236]
    yvalues = []   # [2, 18, 66, 82, 130, 146, 220]
    Settings::MAX_PARTY_SIZE.times do |i|
      xvalues.push(200 + (72 * (i % 2)))
      yvalues.push(2 + (16 * (i % 2)) + (64 * (i / 2)))
    end
    xvalues.push(236)
    yvalues.push(220)
    arrow.angle = 0
    arrow.mirror = false
    arrow.ox = 0
    arrow.oy = 0
    arrow.x = xvalues[selection]
    arrow.y = yvalues[selection]
  end

  def pbPartyChangeSelection(key, selection)
    case key
    when Input::LEFT
      selection -= 1
      selection = Settings::MAX_PARTY_SIZE if selection < 0
    when Input::RIGHT
      selection += 1
      selection = 0 if selection > Settings::MAX_PARTY_SIZE
    when Input::UP
      if selection == Settings::MAX_PARTY_SIZE
        selection = Settings::MAX_PARTY_SIZE - 1
      else
        selection -= 2
        selection = Settings::MAX_PARTY_SIZE if selection < 0
      end
    when Input::DOWN
      if selection == Settings::MAX_PARTY_SIZE
        selection = 0
      else
        selection += 2
        selection = Settings::MAX_PARTY_SIZE if selection > Settings::MAX_PARTY_SIZE
      end
    end
    return selection
  end

  def pbSelectBoxInternal(_party)
    selection = @selection
    pbSetArrow(@sprites["arrow"], selection)
    pbUpdateOverlay(selection)
    pbSetMosaic(selection)
    loop do
      Graphics.update
      Input.update
      key = -1
      key = Input::DOWN if Input.repeat?(Input::DOWN)
      key = Input::RIGHT if Input.repeat?(Input::RIGHT)
      key = Input::LEFT if Input.repeat?(Input::LEFT)
      key = Input::UP if Input.repeat?(Input::UP)
      if key >= 0
        pbPlayCursorSE
        selection = pbChangeSelection(key, selection)
        pbSetArrow(@sprites["arrow"], selection)
        case selection
        when -4
          nextbox = (@storage.currentBox + @storage.maxBoxes - 1) % @storage.maxBoxes
          pbSwitchBoxToLeft(nextbox)
          @storage.currentBox = nextbox
        when -5
          nextbox = (@storage.currentBox + 1) % @storage.maxBoxes
          pbSwitchBoxToRight(nextbox)
          @storage.currentBox = nextbox
        end
        selection = -1 if [-4, -5].include?(selection)
        pbUpdateOverlay(selection)
        pbSetMosaic(selection)
      end
      self.update
      #edited by Gardenette to be friendly towards WASD players
      #if Input.trigger?(Input::JUMPUP)
      if Input.press?(Input::CTRL) && Input.trigger?(Input::LEFT)
        pbPlayCursorSE
        nextbox = (@storage.currentBox + @storage.maxBoxes - 1) % @storage.maxBoxes
        pbSwitchBoxToLeft(nextbox)
        @storage.currentBox = nextbox
        pbUpdateOverlay(selection)
        pbSetMosaic(selection)
      #edited by Gardenette to be friendly towards WASD players
      #elsif Input.trigger?(Input::JUMPDOWN)
      elsif Input.press?(Input::CTRL) && Input.trigger?(Input::RIGHT)
        pbPlayCursorSE
        nextbox = (@storage.currentBox + 1) % @storage.maxBoxes
        pbSwitchBoxToRight(nextbox)
        @storage.currentBox = nextbox
        pbUpdateOverlay(selection)
        pbSetMosaic(selection)
      elsif Input.trigger?(Input::SPECIAL)   # Jump to box name
        if selection != -1
          pbPlayCursorSE
          selection = -1
          pbSetArrow(@sprites["arrow"], selection)
          pbUpdateOverlay(selection)
          pbSetMosaic(selection)
        end
      elsif Input.trigger?(Input::ACTION) && @command == 0   # Organize only
        pbPlayDecisionSE
        pbSetQuickSwap(!@quickswap)
      elsif Input.trigger?(Input::BACK)
        @selection = selection
        return nil
      elsif Input.trigger?(Input::USE)
        @selection = selection
        if selection >= 0
          return [@storage.currentBox, selection]
        elsif selection == -1   # Box name
          return [-4, -1]
        elsif selection == -2   # Party Pokémon
          return [-2, -1]
        elsif selection == -3   # Close Box
          return [-3, -1]
        end
      end
    end
  end
end #of class


##############################################
#===============================================================================
# Wild Pokemon Knock away Pokeballs
#===============================================================================
module Battle::CatchAndStoreMixin
def pbThrowPokeBall(idxBattler, ball, catch_rate = nil, showPlayer = false)
    # Determine which Pokémon you're throwing the Poké Ball at
    battler = nil
    if opposes?(idxBattler)
      battler = @battlers[idxBattler]
    else
      battler = @battlers[idxBattler].pbDirectOpposing(true)
    end
    battler = battler.allAllies[0] if battler.fainted?
    # Messages
    itemName = GameData::Item.get(ball).name
    if battler.fainted?
      if itemName.starts_with_vowel?
        pbDisplay(_INTL("{1} threw an {2}!", pbPlayer.name, itemName))
      else
        pbDisplay(_INTL("{1} threw a {2}!", pbPlayer.name, itemName))
      end
      pbDisplay(_INTL("But there was no target..."))
      return
    end
    if itemName.starts_with_vowel?
      pbDisplayBrief(_INTL("{1} threw an {2}!", pbPlayer.name, itemName))
    else
      pbDisplayBrief(_INTL("{1} threw a {2}!", pbPlayer.name, itemName))
    end
    
    #Pokemon knocked away Pokeball
    if $game_switches[66]
      @scene.pbThrowAndDeflect(ball, 1)
      pbDisplay(_INTL("The Poké Ball was knocked away!"))
      return
    end
    
    # Animation of opposing trainer blocking Poké Balls (unless it's a Snag Ball
    # at a Shadow Pokémon)
    if trainerBattle? && !(GameData::Item.get(ball).is_snag_ball? && battler.shadowPokemon?)
      @scene.pbThrowAndDeflect(ball, 1)
      pbDisplay(_INTL("The Trainer blocked your Poké Ball! Don't be a thief!"))
      return
    end
    # Calculate the number of shakes (4=capture)
    pkmn = battler.pokemon
    @criticalCapture = false
    numShakes = pbCaptureCalc(pkmn, battler, catch_rate, ball)
    PBDebug.log("[Threw Poké Ball] #{itemName}, #{numShakes} shakes (4=capture)")
    # Animation of Ball throw, absorb, shake and capture/burst out
    @scene.pbThrow(ball, numShakes, @criticalCapture, battler.index, showPlayer)
    # Outcome message
    case numShakes
    when 0
      pbDisplay(_INTL("Oh no! The Pokémon broke free!"))
      Battle::PokeBallEffects.onFailCatch(ball, self, battler)
    when 1
      pbDisplay(_INTL("Aww! It appeared to be caught!"))
      Battle::PokeBallEffects.onFailCatch(ball, self, battler)
    when 2
      pbDisplay(_INTL("Aargh! Almost had it!"))
      Battle::PokeBallEffects.onFailCatch(ball, self, battler)
    when 3
      pbDisplay(_INTL("Gah! It was so close, too!"))
      Battle::PokeBallEffects.onFailCatch(ball, self, battler)
    when 4
      pbDisplayBrief(_INTL("Gotcha! {1} was caught!", pkmn.name))
      @scene.pbThrowSuccess   # Play capture success jingle
      pbRemoveFromParty(battler.index, battler.pokemonIndex)
      # Gain Exp
      if Settings::GAIN_EXP_FOR_CAPTURE
        battler.captured = true
        pbGainExp
        battler.captured = false
      end
      battler.pbReset
      if pbAllFainted?(battler.index)
        @decision = (trainerBattle?) ? 1 : 4   # Battle ended by win/capture
      end
			if @decision == 4 # battle ended by catching a wild mon
				increaseChain(pkmn.species)
      end
      # Modify the Pokémon's properties because of the capture
      if GameData::Item.get(ball).is_snag_ball?
        pkmn.owner = Pokemon::Owner.new_from_trainer(pbPlayer)
      end
      Battle::PokeBallEffects.onCatch(ball, self, pkmn)
      pkmn.poke_ball = ball
      pkmn.makeUnmega if pkmn.mega?
      pkmn.makeUnprimal
      pkmn.update_shadow_moves if pkmn.shadowPokemon?
      pkmn.record_first_moves
      # Reset form
      pkmn.forced_form = nil if MultipleForms.hasFunction?(pkmn.species, "getForm")
      @peer.pbOnLeavingBattle(self, pkmn, true, true)
      # Make the Poké Ball and data box disappear
      @scene.pbHideCaptureBall(idxBattler)
      # Save the Pokémon for storage at the end of battle
      @caughtPokemon.push(pkmn)
    end
    if numShakes != 4
      @first_poke_ball = ball if !@poke_ball_failed
      @poke_ball_failed = true
    end
  end #pbThrowPokeBall
end #module Battle::CatchAndStoreMixin

#===============================================================================
# JUMPUP/JUPDOWN Changed to Control+Up or Control+Down
#===============================================================================
class SpriteWindow_Selectable < SpriteWindow_Base
def update
    super
    if self.active && @item_max > 0 && @index >= 0 && !@ignore_input
      if Input.repeat?(Input::UP) && !Input.press?(Input::CTRL)
        if @index >= @column_max ||
           (Input.trigger?(Input::UP) && (@item_max % @column_max) == 0)
          oldindex = @index
          @index = (@index - @column_max + @item_max) % @item_max
          if @index != oldindex
            pbPlayCursorSE
            update_cursor_rect
          end
        end
      elsif Input.repeat?(Input::DOWN) && !Input.press?(Input::CTRL)
        if @index < @item_max - @column_max ||
           (Input.trigger?(Input::DOWN) && (@item_max % @column_max) == 0)
          oldindex = @index
          @index = (@index + @column_max) % @item_max
          if @index != oldindex
            pbPlayCursorSE
            update_cursor_rect
          end
        end
      elsif Input.repeat?(Input::LEFT)
        if @column_max >= 2 && @index > 0
          oldindex = @index
          @index -= 1
          if @index != oldindex
            pbPlayCursorSE
            update_cursor_rect
          end
        end
      elsif Input.repeat?(Input::RIGHT)
        if @column_max >= 2 && @index < @item_max - 1
          oldindex = @index
          @index += 1
          if @index != oldindex
            pbPlayCursorSE
            update_cursor_rect
          end
        end
      elsif Input.repeat?(Input::UP) && Input.press?(Input::CTRL)
        if @index > 0
          oldindex = @index
          @index = [self.index - self.page_item_max, 0].max
          if @index != oldindex
            pbPlayCursorSE
            self.top_row -= self.page_row_max
            update_cursor_rect
          end
        end
      elsif Input.repeat?(Input::DOWN) && Input.press?(Input::CTRL)
        if @index < @item_max - 1
          oldindex = @index
          @index = [self.index + self.page_item_max, @item_max - 1].min
          if @index != oldindex
            pbPlayCursorSE
            self.top_row += self.page_row_max
            update_cursor_rect
          end
        end
      end
    end
  end #end of update
end #end of class

#===============================================================================
# Change Player Battle Back Depending on whether Pokemon Followers are on
#===============================================================================
module GameData
  class TrainerType
    def self.player_back_sprite_filename(tr_type)
      outfit = ($player) ? $player.outfit : 0
      
      #return self.check_file(tr_type, "Graphics/Trainers/", sprintf("_%d", outfit), "_back")
      
      #if Pokemon Followers EX - slide into battle - is on, use the
      #pointing backsprite for the player. Otherwise, use the regular
      if FollowingPkmn::SLIDE_INTO_BATTLE && !FollowingPkmn::FAINTED_FOLLOWERS
        #slide into battle and use the first pokemon since the first pokemon
        #can't be fainted, so point
        return self.check_file(tr_type, "Graphics/Trainers/", sprintf("_%d", outfit), "_back_point")
      elsif FollowingPkmn::SLIDE_INTO_BATTLE && !$Trainer.pokemon_party[0].fainted?
        #slide into battle is on, fainted followers are allowed, and the first
        #pokemon in the party is not fainted, so point
        return self.check_file(tr_type, "Graphics/Trainers/", sprintf("_%d", outfit), "_back_point")
      else
        #use the regular back sprite
        return self.check_file(tr_type, "Graphics/Trainers/", sprintf("_%d", outfit), "_back")
      end
      
      
    end
  end #of class
end #of module

#===============================================================================
# Trainer Card UI Tweaks
#===============================================================================
class PokemonTrainerCard_Scene
def pbDrawTrainerCardFront
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    #baseColor   = Color.new(72, 72, 72)
    #shadowColor = Color.new(160, 160, 160)
    baseColor   = Color.new(255, 255, 255)
    shadowColor = Color.new(0, 0, 0)
    totalsec = $stats.play_time.to_i
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    time = (hour > 0) ? _INTL("{1}h {2}m", hour, min) : _INTL("{1}m", min)
    $PokemonGlobal.startTime = pbGetTimeNow if !$PokemonGlobal.startTime
    starttime = _INTL("{1} {2}, {3}",
                      pbGetAbbrevMonthName($PokemonGlobal.startTime.mon),
                      $PokemonGlobal.startTime.day,
                      $PokemonGlobal.startTime.year)
    textPositions = [
      [_INTL("Name"), 34, 70, 0, baseColor, shadowColor],
      [$player.name, 302, 70, 1, baseColor, shadowColor],
      [_INTL("ID No."), 332, 70, 0, baseColor, shadowColor],
      [sprintf("%05d", $player.public_ID), 468, 70, 1, baseColor, shadowColor],
      [_INTL("Money"), 34, 118, 0, baseColor, shadowColor],
      [_INTL("${1}", $player.money.to_s_formatted), 302, 118, 1, baseColor, shadowColor],
      [_INTL("Pokédex"), 34, 166, 0, baseColor, shadowColor],
      [sprintf("%d/%d", $player.pokedex.owned_count, $player.pokedex.seen_count), 302, 166, 1, baseColor, shadowColor],
      [_INTL("Time"), 34, 214, 0, baseColor, shadowColor],
      [time, 302, 214, 1, baseColor, shadowColor],
      [_INTL("Started"), 34, 262, 0, baseColor, shadowColor],
      [starttime, 302, 262, 1, baseColor, shadowColor]
    ]
    pbDrawTextPositions(overlay, textPositions)
    x = 72
    region = pbGetCurrentRegion(0) # Get the current region
    imagePositions = []
    8.times do |i|
      if $player.badges[i + (region * 8)]
        imagePositions.push(["Graphics/Pictures/Trainer Card/icon_badges", x, 310, i * 32, region * 32, 32, 32])
      end
      x += 48
    end
    pbDrawImagePositions(overlay, imagePositions)
  end
end

#===============================================================================
# Max out AI for all Trainer Types
#===============================================================================
module PBTrainerAI
  # Minimum skill level to be in each AI category.
  def self.minimumSkill; return 255;   end
  def self.mediumSkill;  return 255;  end
  def self.highSkill;    return 255;  end
  def self.bestSkill;    return 255; end
  end
  
  
  
#===============================================================================
# Always get a Bite when Fishing
#===============================================================================
def pbFishing(hasEncounter, rodType = 1)
  $stats.fishing_count += 1
  speedup = ($player.first_pokemon && [:STICKYHOLD, :SUCTIONCUPS].include?($player.first_pokemon.ability_id))
  #biteChance = 20 + (25 * rodType)   # 45, 70, 95
  biteChance = 9999
  biteChance *= 1.5 if speedup   # 67.5, 100, 100
  hookChance = 100
  pbFishingBegin
  msgWindow = pbCreateMessageWindow
  ret = false
  loop do
    time = rand(5..10)
    time = [time, rand(5..10)].min if speedup
    message = ""
    time.times { message += ".   " }
    if pbWaitMessage(msgWindow, time)
      pbFishingEnd {
        pbMessageDisplay(msgWindow, _INTL("Reeled it in too fast..."))
      }
      break
    end
    if hasEncounter && rand(100) < biteChance
      $scene.spriteset.addUserAnimation(Settings::EXCLAMATION_ANIMATION_ID, $game_player.x, $game_player.y, true, 3)
      frames = Graphics.frame_rate - rand(Graphics.frame_rate / 2)   # 0.5-1 second
      if !pbWaitForInput(msgWindow, message + _INTL("\r\nOh! A bite!"), frames)
        pbFishingEnd {
          pbMessageDisplay(msgWindow, _INTL("The Pokémon got away..."))
        }
        break
      end
      if Settings::FISHING_AUTO_HOOK || rand(100) < hookChance
        pbFishingEnd {
          pbMessageDisplay(msgWindow, _INTL("Landed a Pokémon!")) if !Settings::FISHING_AUTO_HOOK
        }
        ret = true
        break
      end
#      biteChance += 15
#      hookChance += 15
    else
      pbFishingEnd {
        pbMessageDisplay(msgWindow, _INTL("Reeled it in too fast..."))
      }
      break
    end
  end
  pbDisposeMessageWindow(msgWindow)
  return ret
end

#===============================================================================
# Rick the Voltorb Troll
#===============================================================================
def pbTroll
  system("start https://www.youtube.com/watch?v=dQw4w9WgXcQ")
end

#===============================================================================
# Differentiate between pumpkaboo sizes
#===============================================================================
class Battle
def pbStartBattleSendOut(sendOuts)
    # "Want to battle" messages
    if wildBattle?
      foeParty = pbParty(1)
      case foeParty.length
      when 1
        #added by Gardenette to help differentiate between pumpkaboo sizes in
        #the wild
        if foeParty[0].isSpecies?(:PUMPKABOO)
        #give messages depending on form (size)
        pbDisplayPaused(_INTL("Oh! A wild {1} appeared!", foeParty[0].name))
          if foeParty[0].form == 0
            #small
            pbDisplayPaused(_INTL("It looks pretty small!"))
          end
          if foeParty[0].form == 1
            #average
            pbDisplayPaused(_INTL("It looks to be average size!"))
          end
          if foeParty[0].form == 2
            #large
            pbDisplayPaused(_INTL("It looks pretty large!"))
          end
          if foeParty[0].form == 3
            #super size
            pbDisplayPaused(_INTL("Woah, it's so big!"))
          end
        else
        pbDisplayPaused(_INTL("Oh! A wild {1} appeared!", foeParty[0].name))
        end
      when 2
        pbDisplayPaused(_INTL("Oh! A wild {1} and {2} appeared!", foeParty[0].name,
                              foeParty[1].name))
      when 3
        pbDisplayPaused(_INTL("Oh! A wild {1}, {2} and {3} appeared!", foeParty[0].name,
                              foeParty[1].name, foeParty[2].name))
      end
    else   # Trainer battle
      case @opponent.length
      when 1
        pbDisplayPaused(_INTL("You are challenged by {1}!", @opponent[0].full_name))
      when 2
        pbDisplayPaused(_INTL("You are challenged by {1} and {2}!", @opponent[0].full_name,
                              @opponent[1].full_name))
      when 3
        pbDisplayPaused(_INTL("You are challenged by {1}, {2} and {3}!",
                              @opponent[0].full_name, @opponent[1].full_name, @opponent[2].full_name))
      end
    end
    # Send out Pokémon (opposing trainers first)
    [1, 0].each do |side|
      next if side == 1 && wildBattle?
      msg = ""
      toSendOut = []
      trainers = (side == 0) ? @player : @opponent
      # Opposing trainers and partner trainers's messages about sending out Pokémon
      trainers.each_with_index do |t, i|
        next if side == 0 && i == 0   # The player's message is shown last
        msg += "\r\n" if msg.length > 0
        sent = sendOuts[side][i]
        case sent.length
        when 1
          msg += _INTL("{1} sent out {2}!", t.full_name, @battlers[sent[0]].name)
        when 2
          msg += _INTL("{1} sent out {2} and {3}!", t.full_name,
                       @battlers[sent[0]].name, @battlers[sent[1]].name)
        when 3
          msg += _INTL("{1} sent out {2}, {3} and {4}!", t.full_name,
                       @battlers[sent[0]].name, @battlers[sent[1]].name, @battlers[sent[2]].name)
        end
        toSendOut.concat(sent)
      end
      # The player's message about sending out Pokémon
      if side == 0
        msg += "\r\n" if msg.length > 0
        sent = sendOuts[side][0]
        case sent.length
        when 1
          msg += _INTL("Go! {1}!", @battlers[sent[0]].name)
        when 2
          msg += _INTL("Go! {1} and {2}!", @battlers[sent[0]].name, @battlers[sent[1]].name)
        when 3
          msg += _INTL("Go! {1}, {2} and {3}!", @battlers[sent[0]].name,
                       @battlers[sent[1]].name, @battlers[sent[2]].name)
        end
        toSendOut.concat(sent)
      end
      pbDisplayBrief(msg) if msg.length > 0
      # The actual sending out of Pokémon
      animSendOuts = []
      toSendOut.each do |idxBattler|
        animSendOuts.push([idxBattler, @battlers[idxBattler].pokemon])
      end
      pbSendOut(animSendOuts, true)
    end
  end
end

#===============================================================================
# Weather tweaks
#===============================================================================
#this doesn't work when put in this script. It does not overwrite what is in
#Overworld
#I am putting this here as a reminder that it is set up in the script called
#Overworld
# Set up various data related to the new map
EventHandlers.add(:on_enter_map, :setup_new_map,
  proc { |old_map_id|   # previous map ID, is 0 if no map ID
    # Record new Teleport destination
    new_map_metadata = $game_map.metadata
    if new_map_metadata&.teleport_destination
      $PokemonGlobal.healingSpot = new_map_metadata.teleport_destination
    end
    # End effects that apply only while on the map they were used
    $PokemonMap&.clear
    # Setup new wild encounter tables
    $PokemonEncounters&.setup($game_map.map_id)
    # Record the new map as having been visited
    $PokemonGlobal.visitedMaps[$game_map.map_id] = true
    # Set weather if new map has weather
    next if old_map_id == 0 || old_map_id == $game_map.map_id
    next if !new_map_metadata || !new_map_metadata.weather

    #added by Gardenette with advice from Maruno
    #dismiss weather change if map ID is San Cerigold and game switch for
    #defeated gym 1 is on
    next if $game_map.map_id == 4 && $game_switches[4]
    
    #dismiss weather change if map ID is San Cerigold Cemetery and game switch
    #for defeated gym 1 is on
    next if $game_map.map_id == 5 && $game_switches[4]
    
    map_infos = pbLoadMapInfos
    if $game_map.name == map_infos[old_map_id].name
      old_map_metadata = GameData::MapMetadata.try_get(old_map_id)
      next if old_map_metadata&.weather
    end
    new_weather = new_map_metadata.weather
    $game_screen.weather(new_weather[0], 9, 0) if rand(100) < new_weather[1]
  }
)

#===============================================================================
# Custom Encounter Types
#===============================================================================
class PokemonEncounters
  attr_reader :step_count

 # Returns the encounter method that the current encounter should be generated
  # from, depending on the player's current location.
  def encounter_type
    time = pbGetTimeNow
    ret = nil
    if $PokemonGlobal.surfing
      ret = find_valid_encounter_type_for_time(:Water, time)
     else   # Land/Cave (can have both in the same map)
      if has_land_encounters? && $game_map.terrain_tag($game_player.x, $game_player.y).land_wild_encounters
        ret = :BugContest if pbInBugContest? && has_encounter_type?(:BugContest)
      
        #added by Gardenette for EnCORNters
        if !ret && $game_map.terrain_tag($game_player.x, $game_player.y).id_number == 18
        ret = find_valid_encounter_type_for_time(:Corn, time)
      end
        
      
        ret = find_valid_encounter_type_for_time(:Land, time) if !ret
      end
      
      if !ret && has_cave_encounters?
        ret = find_valid_encounter_type_for_time(:Cave, time)
      end
    end
    return ret
  end
end #of class

#===============================================================================
# Play Pokemon Cry from Forms Page in Pokedex
#===============================================================================
#THIS CODE WAS PUT IN THE POKEDEX SECTION OF ARCKY'S REGION MAP FOR COMPATIBILITY
class PokemonPokedexInfo_Scene
  
  def drawPageForms
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_forms"))
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(88, 88, 80)
    shadow = Color.new(168, 184, 184)
    # Write species and form name
    formname = ""
    @available.each do |i|
      if i[1] == @gender && i[2] == @form
        formname = i[0]
        break
      end
    end
    textpos = [
      [GameData::Species.get(@species).name, Graphics.width / 2, Graphics.height - 82, 2, base, shadow],
      [formname, Graphics.width / 2, Graphics.height - 50, 2, base, shadow]
    ]
    
    # Draw text for playing Pokemon cry
    textpos.push([
        #_INTL("{1}/{2}",@subPage,@totalSubPages),
        #edited by Gardenette
        _INTL("{1}: Cry",$PokemonSystem.game_controls.find{|c| c.control_action=="Registered Item"}.key_name),
        Graphics.width-52,Graphics.height-82,1,BASE_COLOR,SHADOW_COLOR
      ])
    
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    
  end
  
  def pbScene
    Pokemon.play_cry(@species, @form)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      dorefresh = false
      if Input.trigger?(Input::ACTION)
        pbSEStop
        Pokemon.play_cry(@species, @form) if @page == 1
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        case @page
        when 1   # Info
          @show_battled_count = !@show_battled_count
          dorefresh = true
        when 2   # Area
#          dorefresh = true
        when 3   # Forms
          if @available.length > 1
            pbPlayDecisionSE
            pbChooseForm
            dorefresh = true
          end
        end
        #added by Gardenette for playing the cry on Forms page
      elsif Input.trigger?(Input::SPECIAL)
        case @page
        when 1   # Info
        when 2   # Area
        when 3   # Forms
          Pokemon.play_cry(@species, @form)
        end
      elsif Input.trigger?(Input::UP)
        #hide evo method again
        @revealEvo = false
        
        oldindex = @index
        pbGoToPrevious
        if @index != oldindex
          pbUpdateDummyPokemon
          @available = pbGetAvailableForms
          pbSEStop
          (@page == 1) ? Pokemon.play_cry(@species, @form) : pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.trigger?(Input::DOWN)
        #hide evo method again
        @revealEvo = false
        
        oldindex = @index
        pbGoToNext
        if @index != oldindex
          pbUpdateDummyPokemon
          @available = pbGetAvailableForms
          pbSEStop
          (@page == 1) ? Pokemon.play_cry(@species, @form) : pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.trigger?(Input::LEFT)
        oldpage = @page
        @page -= 1
        @page = 1 if @page < 1
        #edited for FL's advanced pokedex page
        @page=@maxPage if @page>@maxPage
        if @page != oldpage
          pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.trigger?(Input::RIGHT)
        oldpage = @page
        @page += 1
        @page = 1 if @page < 1
        @page=@maxPage if @page>@maxPage
        if @page != oldpage
          pbPlayCursorSE
          dorefresh = true
        end
      end
      if dorefresh
        drawPage(@page)
      end
    end
    return @index
  end
  
  
end #of class

#===============================================================================
# pbMoveRoute, but it repeats
#===============================================================================
def pbMoveRouteRepeat(event, commands, waitComplete = false)
  route = RPG::MoveRoute.new
  route.repeat    = true
  route.skippable = true
  route.list.clear
  route.list.push(RPG::MoveCommand.new(PBMoveRoute::ThroughOn))
  i = 0
  while i < commands.length
    case commands[i]
    when PBMoveRoute::Wait, PBMoveRoute::SwitchOn, PBMoveRoute::SwitchOff,
       PBMoveRoute::ChangeSpeed, PBMoveRoute::ChangeFreq, PBMoveRoute::Opacity,
       PBMoveRoute::Blending, PBMoveRoute::PlaySE, PBMoveRoute::Script
      route.list.push(RPG::MoveCommand.new(commands[i], [commands[i + 1]]))
      i += 1
    when PBMoveRoute::ScriptAsync
      route.list.push(RPG::MoveCommand.new(PBMoveRoute::Script, [commands[i + 1]]))
      route.list.push(RPG::MoveCommand.new(PBMoveRoute::Wait, [0]))
      i += 1
    when PBMoveRoute::Jump
      route.list.push(RPG::MoveCommand.new(commands[i], [commands[i + 1], commands[i + 2]]))
      i += 2
    when PBMoveRoute::Graphic
      route.list.push(RPG::MoveCommand.new(commands[i],
                                           [commands[i + 1], commands[i + 2],
                                            commands[i + 3], commands[i + 4]]))
      i += 4
    else
      route.list.push(RPG::MoveCommand.new(commands[i]))
    end
    i += 1
  end
  route.list.push(RPG::MoveCommand.new(PBMoveRoute::ThroughOff))
  route.list.push(RPG::MoveCommand.new(0))
  event&.force_move_route(route)
  return route
end

#===============================================================================
# Add Foreign Pokemon to Boxes if Party is Full
#===============================================================================
def pbAddForeignPokemon(pkmn, level = 1, owner_name = nil, nickname = nil, owner_gender = 0, see_form = true)
  #return false if !pkmn || $player.party_full?
  return false if !pkmn
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  pkmn.owner = Pokemon::Owner.new_foreign(owner_name || "", owner_gender)
  pkmn.name = nickname[0, Pokemon::MAX_NAME_SIZE] if !nil_or_empty?(nickname)
  pkmn.calc_stats
  if owner_name
    pbMessage(_INTL("\\me[Pkmn get]{1} received a Pokémon from {2}.\1", $player.name, owner_name))
  else
    pbMessage(_INTL("\\me[Pkmn get]{1} received a Pokémon.\1", $player.name))
  end
  was_owned = $player.owned?(pkmn.species)
  $player.pokedex.set_seen(pkmn.species)
  $player.pokedex.set_owned(pkmn.species)
  $player.pokedex.register(pkmn) if see_form
  # Show Pokédex entry for new species if it hasn't been owned before
  if Settings::SHOW_NEW_SPECIES_POKEDEX_ENTRY_MORE_OFTEN && see_form && !was_owned && $player.has_pokedex
    pbMessage(_INTL("The Pokémon's data was added to the Pokédex."))
    $player.pokedex.register_last_seen(pkmn)
    pbFadeOutIn {
      scene = PokemonPokedexInfo_Scene.new
      screen = PokemonPokedexInfoScreen.new(scene)
      screen.pbDexEntry(pkmn.species)
    }
  end
  # Add the Pokémon
  pbStorePokemon(pkmn)
  return true
end

#===============================================================================
# pbStorePokemon(pkmn) from Essentials Hotfixes, but if you replace the first
#pokemon in your party with what you just caught, it doesn't put it at the back
#of the party
#===============================================================================
module Battle::CatchAndStoreMixin
  def pbStorePokemon(pkmn)
    #reset variable
    @added_to_party = false
    
    # Nickname the Pokémon (unless it's a Shadow Pokémon)
    if !pkmn.shadowPokemon?
      if $PokemonSystem.givenicknames == 0 &&
         pbDisplayConfirm(_INTL("Would you like to give a nickname to {1}?", pkmn.name))
        nickname = @scene.pbNameEntry(_INTL("{1}'s nickname?", pkmn.speciesName), pkmn)
        pkmn.name = nickname
      end
    end
		# setting initial values #by low
		if $game_variables[MECHANICSVAR] >= 2
			if !$game_switches[NOINITIALVALUES]
				if pbDisplayConfirm(_INTL("Would you like to set initial values for {1}?", pkmn.name))
					# choosing an ability
					abils = pkmn.getAbilityList
					commands = []
					cmd = 0
					for i in abils
						next if i[1] > 1 # only natural abilities
						commands.push(GameData::Ability.get(i[0]).name)
						cmd = commands.length - 1 if pkmn.ability_id == i[0]
					end
					cmd = scene.pbShowCommands(_INTL("Choose an ability."), commands, cmd)
					if cmd < 0
						#nothing
					else
						pkmn.ability_index = abils[cmd][1]
						pkmn.ability = nil
					end
					
					# choosing natures
					commands = []
					ids = []
					naturenum = 0
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
					cmd = scene.pbShowCommands(_INTL("Choose an nature."), commands, cmd)
					if cmd < 0
						#nothing
					else
						pkmn.nature = ids[cmd]
						pkmn.calc_stats
					end
					
					# choosing hidden power type
					commands = []
					types = []
					GameData::Type.each do |t|
						if !t.pseudo_type && ![:FAIRY, :SHADOW].include?(t.id)
							commands.push(t.name)
							types.push(t.id) 
					 end
					end
					commands.push(_INTL("Cancel"))
					cmd = types.index(pkmn.hptype) || 0
					cmd = pbMessage(_INTL("Choose the type of {1}'s Hidden Power.",pkmn.name), commands, -1, nil, cmd)
					if cmd >=0 && cmd<types.length && pkmn.hptype != types[cmd]
						pkmn.hptype = types[cmd]
						scene.pbDisplay(_INTL("{1}'s Hidden Power has been set to {2}.",pkmn.name, pkmn.hptype))
					else
						# canceled
					end
				end
			end
		end
    # Store the Pokémon
    if pbPlayer.party_full? && (@sendToBoxes == 0 || @sendToBoxes == 2)   # Ask/must add to party
      cmds = [_INTL("Add to your party"),
              _INTL("Send to a Box"),
              _INTL("See {1}'s summary", pkmn.name),
              _INTL("Check party")]
      cmds.delete_at(1) if @sendToBoxes == 2
      loop do
        cmd = pbShowCommands(_INTL("Where do you want to send {1} to?", pkmn.name), cmds, 99)
        break if cmd == 99   # Cancelling = send to a Box
        cmd += 1 if cmd >= 1 && @sendToBoxes == 2
        case cmd
        when 0   # Add to your party
          pbDisplay(_INTL("Choose a Pokémon in your party to send to your Boxes."))
          party_index = -1
          @scene.pbPartyScreen(0, (@sendToBoxes != 2), 1) { |idxParty, _partyScene|
            party_index = idxParty
            next true
          }
          next if party_index < 0   # Cancelled
          party_size = pbPlayer.party.length
          # Send chosen Pokémon to storage
          # NOTE: This doesn't work properly if you catch multiple Pokémon in
          #       the same battle, because the code below doesn't alter the
          #       contents of pbParty(0), only pbPlayer.party. This means that
          #       viewing the party in battle after replacing a party Pokémon
          #       with a caught one (which is possible if you've caught a second
          #       Pokémon) will not show the first caught Pokémon in the party
          #       but will still show the boxed Pokémon in the party. Correcting
          #       this would take a surprising amount of code, and it's very
          #       unlikely to be needed anyway, so I'm ignoring it for now.
          
          #added by Gardenette
          #get the current party
          partyArray = []
          pbPlayer.party.length.times do |i|
            partyArray[i] = pbPlayer.party[i]
          end
          
          send_pkmn = pbPlayer.party[party_index]
          stored_box = @peer.pbStorePokemon(pbPlayer, send_pkmn)
          #pbPlayer.party.delete_at(party_index)
          
          #added by Gardenette
          #set party members
          pbPlayer.party.length.times do |i|
            #pkmn is the pokemon the player just caught and decided to put in
            #their party
            if partyArray[i] == pbPlayer.party[party_index]
              pbPlayer.party[i] = pkmn
            else
              pbPlayer.party[i] = partyArray[i]
            end
          end
          
          #set variable for whether the pokemon was added to the party
          @added_to_party = true
          
          box_name = @peer.pbBoxName(stored_box)
          pbDisplayPaused(_INTL("{1} has been sent to Box \"{2}\".", send_pkmn.name, box_name))
          # Rearrange all remembered properties of party Pokémon
          (party_index...party_size).each do |idx|
            if idx < party_size - 1
              @initialItems[0][idx] = @initialItems[0][idx + 1]
              $game_temp.party_levels_before_battle[idx] = $game_temp.party_levels_before_battle[idx + 1]
              $game_temp.party_critical_hits_dealt[idx] = $game_temp.party_critical_hits_dealt[idx + 1]
              $game_temp.party_direct_damage_taken[idx] = $game_temp.party_direct_damage_taken[idx + 1]
							# the big funny #by low
              $game_temp.party_speed_boost_number[idx] = $game_temp.party_speed_boost_number[idx + 1]
              $game_temp.party_berries_eaten_number[idx] = $game_temp.party_berries_eaten_number[idx + 1]
              $game_temp.party_fly_turns_number[idx] = $game_temp.party_fly_turns_number[idx + 1]
              $game_temp.party_dead_bananas[idx] = $game_temp.party_dead_bananas[idx + 1]
							#
            else
              @initialItems[0][idx] = nil
              $game_temp.party_levels_before_battle[idx] = nil
              $game_temp.party_critical_hits_dealt[idx] = nil
              $game_temp.party_direct_damage_taken[idx] = nil
							# the big funny #by low
              $game_temp.party_speed_boost_number[idx] = nil 
              $game_temp.party_berries_eaten_number[idx] = nil
              $game_temp.party_fly_turns_number[idx] = nil
              $game_temp.party_dead_bananas[idx] = nil
							#
            end
          end
          break
        when 1   # Send to a Box
          break
        when 2   # See X's summary
          pbFadeOutIn {
            summary_scene = PokemonSummary_Scene.new
            summary_screen = PokemonSummaryScreen.new(summary_scene, true)
            summary_screen.pbStartScreen([pkmn], 0)
          }
        when 3   # Check party
          @scene.pbPartyScreen(0, true, 2)
        end
      end
    end
    
    if @added_to_party
      #do nothing extra
    else
      # Store as normal (add to party if there's space, or send to a Box if not)
      stored_box = @peer.pbStorePokemon(pbPlayer, pkmn)
      if stored_box < 0
        pbDisplayPaused(_INTL("{1} has been added to your party.", pkmn.name))
        @initialItems[0][pbPlayer.party.length - 1] = pkmn.item_id if @initialItems
        return
      end
      # Messages saying the Pokémon was stored in a PC box
      box_name = @peer.pbBoxName(stored_box)
      pbDisplayPaused(_INTL("{1} has been sent to Box \"{2}\"!", pkmn.name, box_name))
    end
  end #of method
end #of 

#===============================================================================
# Misc. Extras
#===============================================================================
def pbFishing101
  pbMessage(_INTL("To fish, walk up to a body of water and use your fishing rod of choice from your bag in the 'key items' pocket. Then... wait..."))
  pbMessage(_INTL("You can also register a fishing rod and use it by selecting it from the ready menu. Press {1} to open the ready menu.",$PokemonSystem.game_controls.find{|c| c.control_action=="Action"}.key_name))
end

#===============================================================================
# Draw Happiness in Summary Screen
#===============================================================================
class PokemonSummary_Scene
  def drawPageTwo
    overlay = @sprites["overlay"].bitmap
    memo = ""
    # Write nature
    showNature = !@pokemon.shadowPokemon? || @pokemon.heartStage <= 3
    if showNature
      natureName = @pokemon.nature.name
      memo += _INTL("<c3=F83820,E09890>{1}<c3=404040,B0B0B0> nature.\n", natureName)
    end
    # Write date received
    if @pokemon.timeReceived
      date  = @pokemon.timeReceived.day
      month = pbGetMonthName(@pokemon.timeReceived.mon)
      year  = @pokemon.timeReceived.year
      memo += _INTL("<c3=404040,B0B0B0>{1} {2}, {3}\n", date, month, year)
    end
    # Write map name Pokémon was received on
    mapname = pbGetMapNameFromId(@pokemon.obtain_map)
    mapname = @pokemon.obtain_text if @pokemon.obtain_text && !@pokemon.obtain_text.empty?
    mapname = _INTL("Faraway place") if nil_or_empty?(mapname)
    memo += sprintf("<c3=F83820,E09890>%s\n", mapname)
    # Write how Pokémon was obtained
    mettext = [_INTL("Met at Lv. {1}.", @pokemon.obtain_level),
               _INTL("Egg received."),
               _INTL("Traded at Lv. {1}.", @pokemon.obtain_level),
               "",
               _INTL("Had a fateful encounter at Lv. {1}.", @pokemon.obtain_level)][@pokemon.obtain_method]
    memo += sprintf("<c3=404040,B0B0B0>%s\n", mettext) if mettext && mettext != ""
    # If Pokémon was hatched, write when and where it hatched
    if @pokemon.obtain_method == 1
      if @pokemon.timeEggHatched
        date  = @pokemon.timeEggHatched.day
        month = pbGetMonthName(@pokemon.timeEggHatched.mon)
        year  = @pokemon.timeEggHatched.year
        memo += _INTL("<c3=404040,B0B0B0>{1} {2}, {3}\n", date, month, year)
      end
      mapname = pbGetMapNameFromId(@pokemon.hatched_map)
      mapname = _INTL("Faraway place") if nil_or_empty?(mapname)
      memo += sprintf("<c3=F83820,E09890>%s\n", mapname)
      memo += _INTL("<c3=404040,B0B0B0>Egg hatched.\n")
    else
      memo += "\n"   # Empty line
    end
    # Write characteristic
    if showNature # the gibberish on the middle is to make it blue colored
			memo += _INTL("\Hidden Power:<r><c3=1870D8,88A8D0>{1}<c3=404040,B0B0B0>\n",@pokemon.hptype) #by low
    end #of if show nature
		#draw happiness under nature message
    memo += _INTL("\nHappiness:<r>[{1}/255]\n",@pokemon.happiness)
    
    #drawing hearts
    imagepos = []
    grayHeart = sprintf("Graphics/Pictures/Summary/grayheart")
    pinkHeart = sprintf("Graphics/Pictures/Summary/heart")
    
    i = 0
    5.times do
      #draw all possible hearts but grayed out
      imagepos.push([grayHeart, 240+i, Graphics.height-44])
      i += 36
    end
    
    #max happiness is 255
    #first heart     50
    #second heart   100
    #third heart    150
    #fourth heart   200
    #fifth heart    255
    
    #draw hearts based on happiness
    if @pokemon.happiness >= 50
      imagepos.push([pinkHeart, 240, Graphics.height-44])
    end
    if @pokemon.happiness >= 100
      imagepos.push([pinkHeart, 276, Graphics.height-44])
    end
    if @pokemon.happiness >= 150
      imagepos.push([pinkHeart, 312, Graphics.height-44])
    end
    if @pokemon.happiness >= 200
      imagepos.push([pinkHeart, 348, Graphics.height-44])
    end
    if @pokemon.happiness >= 255
      imagepos.push([pinkHeart, 384, Graphics.height-44])
    end
    
    # Draw all images
    pbDrawImagePositions(overlay, imagepos)
    
    # Write all text
    drawFormattedTextEx(overlay, 232, 86, 268, memo)
  end #of draw page two
end #of class

#===============================================================================
# Gardenette's ItemLevel Evolution Method
#===============================================================================
#to define an ItemLevel evolution, format the pokemon's evolution in pokemon.txt
#like so: MAYZMEN,ItemLevel,SUNSTONE_35,BLAZEA,ItemLevel,FIRESTONE_35

GameData::Evolution.register({
  :id            => :ItemLevel,	#method of evolution put in pokemon.txt
  :parameter     => String, #take in a string so SUNSTONE_30 in pokemon.txt does
  #not crash the game
  #use_item_proc allows use to check for the SUNSTONE being used (I think)
  :use_itemlevel_proc => proc { |pkmn, parameter, item|
  
  #get the level from the string
  array = parameter
  for i in 0...array.length
    if array[i] == "_"
      #found the separator
      separatorPosition = i
    end
  end
  
  #required item to use on pokemon
  requiredItem = array[0,separatorPosition]
  
  if array[separatorPosition+1,array.length] != ""
    #if the level part of the string is not empty, set the level to the result
    #required level before item will evolve pokemon
    requiredLevel = array[separatorPosition+1,array.length]
  else
    #level is invalid, so set level requirement to 1
    #required level before item will evolve pokemon
    requiredLevel = 1
  end
    if pkmn.level >= requiredLevel.to_i
			next item == requiredItem
		end
  }
})

class Pokemon
#added by Gardenette
  def check_evolution_on_use_item(item_used)
    return check_evolution_internal { |pkmn, new_species, method, parameter|
      if method.to_s == "ItemLevel"
        array = parameter
        for i in 0...array.length
          if array[i] == "_"
            #found the separator
            @separatorPosition = i
          end
        end
        requiredItem = array[0,@separatorPosition]
        if array[@separatorPosition+1,array.length] != ""
          #if the level part of the string is not empty, set the level to the result
          requiredLevel = array[@separatorPosition+1,array.length].to_i
        else
          #level is invalid, so set level requirement to 1
          requiredLevel = 1
        end
        if level >= requiredLevel && item_used.to_s == requiredItem
          success = true
        end
      else
        success = GameData::Evolution.get(method).call_use_item(pkmn, parameter, item_used)
      end
      next (success) ? new_species : nil
    }
  end #of def check_evolution_on_use_item(item_used)
end #of class Pokemon

class PokemonBag_Scene
  def pbUpdateAnnotation
    itemwindow = @sprites["itemlist"]
    item = itemwindow.item
    itm = GameData::Item.get(item) if item
    if @bag.last_viewed_pocket == 1 && item #Items Pocket
      annotations = nil
      annotations = []
      if itm.is_evolution_stone?
        for i in $player.party
          #elig = i.check_evolution_on_use_item(itm)
          elig = i.check_evolution_on_use_item(item)
          annotations.push((elig) ? _INTL("ABLE") : _INTL("UNABLE")) #this line is causing issues
        end
      else
        for i in 0...Settings::MAX_PARTY_SIZE
          @sprites["pokemon#{i}"].text = annotations[i] if  annotations
        end
      end
      for i in 0...Settings::MAX_PARTY_SIZE
        @sprites["pokemon#{i}"].text = annotations[i] if  annotations
      end
    elsif @bag.last_viewed_pocket == 4 && item #TMs Pocket
      annotations = nil
      annotations = []
      if itm.is_machine?
        machine = itm.move
        move = GameData::Move.get(machine).id
        movelist = nil
        if movelist!=nil && movelist.is_a?(Array)
          for i in 0...movelist.length
            movelist[i] = GameData::Move.get(movelist[i]).id
          end
        end
        $player.party.each_with_index do |pkmn, i|
          if pkmn.egg?
            annotations[i] = _INTL("UNABLE")
          elsif pkmn.hasMove?(move)
            annotations[i] = _INTL("LEARNED")
          else
            species = pkmn.species
            if movelist && movelist.any? { |j| j == species }
              # Checked data from movelist given in parameter
              annotations[i] = _INTL("ABLE")
            elsif pkmn.compatible_with_move?(move)
              # Checked data from Pokémon's tutor moves in pokemon.txt
              annotations[i] = _INTL("ABLE")
            else
              annotations[i] = _INTL("UNABLE")
            end
          end
        end
      else
        for i in @party
          annotations.push((elig) ? _INTL("ABLE") : _INTL("UNABLE"))
        end
      end
      for i in 0...Settings::MAX_PARTY_SIZE
        @sprites["pokemon#{i}"].text = annotations[i] if  annotations
      end
    else #Others, only show HP
      for i in 0...Settings::MAX_PARTY_SIZE
        @sprites["pokemon#{i}"].text = nil if @sprites["pokemon#{i}"].text 
      end
    end
  end
end #of class PokemonBag_Scene

class PokemonPartyPanel < Sprite
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
      when "Item"
        @evoreqs.push([evo[0], evo[2]]) if $bag.has?(evo[2]) && @pokemon.check_evolution_on_use_item(evo[2])
      when "ItemLevel"
        array = evo[2]
        for i in 0...array.length
          if array[i] == "_"
            #found the separator
            separatorPosition = i
          end
        end
  
        #required item to use on pokemon
        requiredItem = array[0,separatorPosition]
  
        if array[separatorPosition+1,array.length] != ""
          #if the level part of the string is not empty, set the level to the result
          #required level before item will evolve pokemon
          requiredLevel = array[separatorPosition+1,array.length]
        else
          #level is invalid, so set level requirement to 1
          #required level before item will evolve pokemon
          requiredLevel = 1
        end
        @evoreqs.push([evo[0], requiredItem]) if $bag.has?(requiredItem) && @pokemon.level >= requiredLevel.to_i && @pokemon.check_evolution_on_use_item(requiredItem)
      when /\ATrade/
        # technically should pass a Pokemon object but if that ever becomes relevant something must have gone wrong
        @evoreqs.push([evo[0], evo[2]]) if @pokemon.check_evolution_on_trade(nil)
      else
        @evoreqs.push([evo[0], nil]) if @pokemon.check_evolution_on_level_up
      end
    end
  end
end #of class PokemonPartyPanel < Sprite


#===============================================================================
# Stops Cancellation of Evolving when Using Item to Trigger (Evolve from Party Menu)
#===============================================================================
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
      #fixed by Gardenette - can't cancel stone evos now
      if evoreq[1]
        evo.pbEvolution(false) #can't cancel evolving, item consumed
      else
        evo.pbEvolution
      end
      evo.pbEndScreen
      screen.pbRefresh
    }
  }
})

#===============================================================================
# Change mart buy screen item text from white to black
#===============================================================================
class PokemonMart_Scene
  def pbStartBuyOrSellScene(buying, stock, adapter)
    # Scroll right before showing screen
    pbScrollMap(6, 5, 5)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @stock = stock
    @adapter = adapter
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/martScreen")
    @sprites["icon"] = ItemIconSprite.new(36, Graphics.height - 50, nil, @viewport)
    winAdapter = buying ? BuyAdapter.new(adapter) : SellAdapter.new(adapter)
    @sprites["itemwindow"] = Window_PokemonMart.new(
      stock, winAdapter, Graphics.width - 316 - 16, 10, 330 + 16, Graphics.height - 124
    )
    @sprites["itemwindow"].viewport = @viewport
    @sprites["itemwindow"].index = 0
    @sprites["itemwindow"].refresh
    @sprites["itemtextwindow"] = Window_UnformattedTextPokemon.newWithSize(
      "", 64, Graphics.height - 96 - 16, Graphics.width - 64, 128, @viewport
    )
    pbPrepareWindow(@sprites["itemtextwindow"])
    #@sprites["itemtextwindow"].baseColor = Color.new(248, 248, 248)
    #@sprites["itemtextwindow"].shadowColor = Color.new(0, 0, 0)
    @sprites["itemtextwindow"].baseColor = Color.new(80,80,88)
    @sprites["itemtextwindow"].shadowColor = Color.new(160,160,168)   
    
    @sprites["itemtextwindow"].windowskin = nil
    @sprites["helpwindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["helpwindow"])
    @sprites["helpwindow"].visible = false
    @sprites["helpwindow"].viewport = @viewport
    pbBottomLeftLines(@sprites["helpwindow"], 1)
    @sprites["moneywindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["moneywindow"])
    @sprites["moneywindow"].setSkin("Graphics/Windowskins/goldskin")
    @sprites["moneywindow"].visible = true
    @sprites["moneywindow"].viewport = @viewport
    @sprites["moneywindow"].x = 0
    @sprites["moneywindow"].y = 0
    @sprites["moneywindow"].width = 190
    @sprites["moneywindow"].height = 96
    @sprites["moneywindow"].baseColor = Color.new(88, 88, 80)
    @sprites["moneywindow"].shadowColor = Color.new(168, 184, 184)
    @sprites["qtywindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["qtywindow"])
    @sprites["qtywindow"].setSkin("Graphics/Windowskins/goldskin")
    @sprites["qtywindow"].viewport = @viewport
    @sprites["qtywindow"].width = 190
    @sprites["qtywindow"].height = 64
    @sprites["qtywindow"].baseColor = Color.new(88, 88, 80)
    @sprites["qtywindow"].shadowColor = Color.new(168, 184, 184)
    @sprites["qtywindow"].text = _INTL("In Bag:<r>{1}", @adapter.getQuantity(@sprites["itemwindow"].item))
    @sprites["qtywindow"].y    = Graphics.height - 102 - @sprites["qtywindow"].height
    pbDeactivateWindows(@sprites)
    @buying = buying
    pbRefresh
    Graphics.frame_reset
  end
end

#===============================================================================
# Show animation on event
#===============================================================================
def pbOverworldAnimation(event, id, tinting = false)
  if event.is_a?(Array)
    sprite = nil
    done = []
    event.each do |i|
      next if done.include?(i.id)
      spriteset = $scene.spriteset(i.map_id)
      sprite ||= spriteset&.addUserAnimation(id, i.x, i.y, tinting, 2)
      done.push(i.id)
    end
  else
    spriteset = $scene.spriteset(event.map_id)
    sprite = spriteset&.addUserAnimation(id, event.x, event.y, tinting, 2)
  end
  until sprite.disposed?
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end
end


#===============================================================================
# Trigger on hour update
#===============================================================================
EventHandlers.add(:on_frame_update, :hourly_trigger, proc {
  EventHandlers.trigger(:on_hour_change) if pbGetTimeNow.min == 0 && pbGetTimeNow.sec == 0
})

EventHandlers.add(:on_hour_change, :test, proc {
  #do whatever is needed every hour
})

#===============================================================================
# Ceiba show Pokemon in Intro
#===============================================================================
def pbCeibaShowStarters
  pbMessageCeibaShowStarters("\\xn[Ceiba]I'll be away for a few weeks, so I was wondering if you would like to take care of these Pokémon for me while I'm gone.")
end #pbCeibaShowStarters

def pbMessageCeibaShowStarters(message, commands = nil, cmdIfCancel = 0, skin = nil, defaultCmd = 0, &block)
  ret = 0
  msgwindow = pbCreateMessageWindow(nil, skin)
  
  commands = [_INTL("Of course!"), _INTL("Umm, sure?")]
  
  if commands
    ret = pbMessageDisplay(msgwindow, message, true,
                           proc { |msgwindow|
                           
                           pbCommonEvent(14)
                           
                             next Kernel.pbShowCommands(msgwindow, commands, cmdIfCancel, defaultCmd, &block)
                           }, &block)
  else
    pbMessageDisplay(msgwindow, message, &block)
  end
  pbDisposeMessageWindow(msgwindow)
  Input.update
  return ret
end

#===============================================================================
# Control Weather with Switches
#===============================================================================
# Set up various data related to the new map
EventHandlers.add(:on_enter_map, :setup_new_map,
  proc { |old_map_id|   # previous map ID, is 0 if no map ID
    # Record new Teleport destination
    new_map_metadata = $game_map.metadata
    if new_map_metadata&.teleport_destination
      $PokemonGlobal.healingSpot = new_map_metadata.teleport_destination
    end
    # End effects that apply only while on the map they were used
    $PokemonMap&.clear
    # Setup new wild encounter tables
    $PokemonEncounters&.setup($game_map.map_id)
    # Record the new map as having been visited
    $PokemonGlobal.visitedMaps[$game_map.map_id] = true
    # Set weather if new map has weather
    next if old_map_id == 0 || old_map_id == $game_map.map_id
    next if !new_map_metadata || !new_map_metadata.weather

    #added by Gardenette with advice from Maruno
    #dismiss weather change if map ID is San Cerigold and game switch for
    #festival done is true
    next if $game_map.map_id == 4 && $game_switches[91]
    
    #dismiss weather change if map ID is San Cerigold Cemetery and game switch
    #for festival done is true
    next if $game_map.map_id == 5 && $game_switches[91]
    
    map_infos = pbLoadMapInfos
    if $game_map.name == map_infos[old_map_id].name
      old_map_metadata = GameData::MapMetadata.try_get(old_map_id)
      next if old_map_metadata&.weather
    end
    new_weather = new_map_metadata.weather
    $game_screen.weather(new_weather[0], 9, 0) if rand(100) < new_weather[1]
  }
)