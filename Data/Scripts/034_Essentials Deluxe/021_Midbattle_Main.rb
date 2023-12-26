#===============================================================================
# The main method for executing mid-battle effects once triggered.
#===============================================================================


#-------------------------------------------------------------------------------
# Procs mid-battle effects.
#-------------------------------------------------------------------------------
class Battle::Scene
  def dx_midbattle(idxBattler, idxTarget, *triggers)
    return if !$game_temp.dx_midbattle?
    alt_trainer = alt_battler = nil
    base_battler = midbattle_Battler(idxBattler, idxTarget, :Self)
    base_trainer = (idxBattler) ? @battle.pbGetOwnerIndexFromBattlerIndex(idxBattler) : 0
    midbattle    = $game_temp.dx_midbattle
    all_triggers = []
    #---------------------------------------------------------------------------
    # Creates an array of all possible triggers.
    triggers.each do |trigger|
      all_triggers.push(trigger)
      trig = trigger.split("_")
      if trig.length > 1 && ["turnCommand", "turnAttack", "turnEnd"].include?(trig[0])
        next if trig[1].to_i < 2
        all_triggers.push(trig[0] + "_every_" + trig[1])
      else
        all_triggers.push(trigger + "_random")
        if !trigger.include?("_repeat")
          all_triggers.push(trigger + "_repeat")
          all_triggers.push(trigger + "_repeat_alt")
          all_triggers.push(trigger + "_repeat_random")
        end
      end
    end
    #---------------------------------------------------------------------------
    # Sets the [:delay] and/or [:ignore] keys if conditions have been met.
    $game_temp.dx_midbattle.keys.each do |mid|
      next if !$game_temp.dx_midbattle[mid].is_a?(Hash)
      if $game_temp.dx_midbattle[mid].has_key?(:delay)
        if $game_temp.dx_midbattle[mid][:delay].is_a?(Array)
          $game_temp.dx_midbattle[mid][:delay].each do |delay_trigger|
            $game_temp.dx_midbattle[mid][:delay] = nil if all_triggers.include?(delay_trigger)
          end
        else
          if all_triggers.include?($game_temp.dx_midbattle[mid][:delay])
            $game_temp.dx_midbattle[mid][:delay] = nil 
          end
        end
      end
      if $game_temp.dx_midbattle[mid].has_key?(:ignore)
        if $game_temp.dx_midbattle[mid][:ignore].is_a?(Array)
          $game_temp.dx_midbattle[mid][:ignore].each do |ignore_trigger|
            $game_temp.dx_midbattle[mid][:ignore] = true if all_triggers.include?(ignore_trigger)
          end
        else
          if all_triggers.include?($game_temp.dx_midbattle[mid][:ignore])
            $game_temp.dx_midbattle[mid][:ignore] = true 
          end
        end
      end
    end
    #---------------------------------------------------------------------------
    # Processes each trigger and runs their commands if a match is found.
    all_triggers.each do |trigger|
      if trigger.include?("every")
        trig = trigger.split("_")
        next if !(trig.length == 3 && trig[1] == "every")
        turn = nil
        midbattle.keys.each do |k|
          next if !k.include?(trig[0] + "_every_")
          trigger = k
          turn = k.split("_").last.to_i
        end
        next if !turn || turn < 2 || trig[2].to_i % turn != 0
      else
        next if !midbattle.has_key?(trigger)
      end
      next if trigger.include?("_random") && rand(10) < 5
      next if trigger.include?("repeat_alt") && (1 + @battle.turnCount).even?
      case midbattle[trigger]
      #-------------------------------------------------------------------------
      # When trigger is set to a String or Array, plays trainer speech if possible.
      when String, Array
        pbMidbattleSpeech(base_trainer, idxTarget, base_battler, midbattle[trigger])
        next if trigger.include?("_repeat") || trigger.include?("_every_")
        $game_temp.dx_midbattle.delete(trigger)
      #-------------------------------------------------------------------------
      # When trigger is set to a Proc (not implemented).
      when Proc
        #midbattle[trigger].call
        next if trigger.include?("_repeat") || trigger.include?("_every_")
        $game_temp.dx_midbattle.delete(trigger)
      #-------------------------------------------------------------------------
      # When trigger is set to a hash, applies all effects entered in the hash.
      when Hash
        keys = []
        midbattle[trigger].keys.each do |k|
          string = k.to_s.split("_")
          keys.push([string[0].to_sym, k])
        end
        delay = false
        keys.each do |key|
          trainer = (alt_trainer.nil?) ? base_trainer : alt_trainer
          battler = (alt_battler.nil?) ? base_battler : alt_battler
          next if !midbattle[trigger]
          value = midbattle[trigger][key[1]]
          case key[0]
          #---------------------------------------------------------------------
          # Sets the battler.
          when :battler
            alt_battler = midbattle_Battler(idxBattler, idxTarget, value)
          #---------------------------------------------------------------------
          # Sets the trainer.
          when :trainer
            temp_battler = midbattle_Battler(idxBattler, idxTarget, value)
            alt_trainer = @battle.pbGetOwnerIndexFromBattlerIndex(temp_battler.index)
          #---------------------------------------------------------------------
          # Delays further actions until the inputted trigger has been met.	
          when :delay
            if value.is_a?(String) || value.is_a?(Array)
              delay = true
              break
            end
          #---------------------------------------------------------------------
          # Ignores further actions once the inputted trigger has been met.	
          when :ignore                then break if value == true
          #---------------------------------------------------------------------
          # Pauses further actions for a number of frames.
          when :wait, :pause          then pbWait(value)
          #---------------------------------------------------------------------
          # Changes BGM.
          when :bgm, :music           then midbattle_ChangeBGM(value)
          #---------------------------------------------------------------------
          # Plays a sound effect.
          when :playcry, :cry         then battler.pokemon.play_cry
          when :playsound, :playSE    then pbSEPlay(value)
          #---------------------------------------------------------------------
          # Displays text and speech.
          when :text, :message        then pbMidbattleSpeech(trainer, idxTarget, battler, value, false)
          when :speech, :dialogue     then pbMidbattleSpeech(trainer, idxTarget, battler, value)
          when :blankspeech           then pbMidbattleSpeech(-1, idxTarget, battler, value)
          #---------------------------------------------------------------------
          # Plays an animation.
          when :anim, :animation      then midbattle_PlayAnimation(battler, idxTarget, value)
          #---------------------------------------------------------------------
          # Forces a battler to switch out.
          when :switch                then midbattle_ForceSwitch(battler, value)
          #---------------------------------------------------------------------
          # Uses an item on a battler.
          when :useitem               then midbattle_UseItem(battler, value)
          #---------------------------------------------------------------------
          # Forces a battler to select a particular move.
          when :usemove               then midbattle_UseMove(battler, value)
          #---------------------------------------------------------------------
          # Handles special battle mechanics (Mega, Z-Move, etc.).
          when :usespecial            then midbattle_TriggerBattleMechanic(battler, value)
          when :lockspecial           then midbattle_ToggleBattleMechanic(battler, value)
          #---------------------------------------------------------------------
          # Toggles the charge state of the player's Tera Orb.
          when :teracharge            then $player.tera_charge = value
          #---------------------------------------------------------------------
          # Renames a battler.	
          when :rename
            battler.pokemon.name = value
            battler.name = battler.pokemon.name
            pbRefresh
          #---------------------------------------------------------------------
          # Changes to battler attributes.
          when :hp                    then midbattle_ChangeHP(battler, value)
          when :status                then midbattle_ChangeStatus(battler, value)
          when :form                  then midbattle_ChangeForm(battler, value)
          when :ability               then midbattle_ChangeAbility(battler, value)
          when :item, :helditem       then midbattle_ChangeItem(battler, value)
          when :move, :moves      	  then midbattle_ChangeMoves(battler, value)
          when :stat, :stats          then midbattle_ChangeStats(battler, value)
          when :effect, :effects      then midbattle_BattlerEffects(battler, value)
          #---------------------------------------------------------------------
          # Changes to properties of the battlefield, or one side of the field.
          when :team, :teams          then midbattle_TeamEffects(battler, value)
          when :field                 then midbattle_FieldEffects(battler, value)
          when :weather               then midbattle_ChangeWeather(battler, value)
          when :terrain               then midbattle_ChangeTerrain(battler, value)
          when :environ, :environment then midbattle_ChangeEnvironment(value)
          when :backdrop, :background then midbattle_ChangeBackdrop(value)
          #---------------------------------------------------------------------
          # Prematurely ends the battle.
          when :endbattle
            next if @battle.decision > 0
            @battle.decision = value
          end
        end
        next if trigger.include?("_repeat") || trigger.include?("_every_") || delay
        $game_temp.dx_midbattle.delete(trigger)
      end
    end
  end
            
			
  #-----------------------------------------------------------------------------
  # Displays mid-battle text.
  #-----------------------------------------------------------------------------		
  def pbMidbattleSpeech(idxTrainer, idxTarget, battler, speech, dialogue = true)
    return if speech.empty?
    pbWait(8)
    #---------------------------------------------------------------------------
    # Determines the speaker of the inputted speech.
    speaker = nil
    opposing = false
    if idxTrainer >= 0
      if (@battle.decision == 2 || @battle.pbAllFainted?) ||
         battler.opposes? && !@battle.opponent.nil? && @battle.opponent[idxTrainer]
        speaker = @battle.opponent[idxTrainer]
        opposing = true
      elsif !battler.opposes? && !@battle.player.nil? && @battle.player[idxTrainer]
        speaker = @battle.player[idxTrainer]
      end
    end
    showName = (speaker) ? true : false
    speakerName = (showName) ? speaker.name : $player.name
    displayName = (showName) ? speakerName.upcase + ": " : ""
    playSE = playCry = playAnim = false
    #---------------------------------------------------------------------------
    # Displays the inputted speech.
    if dialogue
      pbToggleDataboxes
      pbToggleBlackBars(true)
    end
    if speech.is_a?(Array)
      speech.each do |sp|
        case sp
        when Integer, :Self, :Ally, :Ally2, :Opposing, :OpposingAlly, :OpposingAlly2
          battlerNew = midbattle_Battler(battler.index, idxTarget, sp)
          if battler.index != battlerNew.index
            battler = battlerNew
            idxTrainer = @battle.pbGetOwnerIndexFromBattlerIndex(battler.index)
            @battle.opponent.length.times { |idx| pbHideOpponent(idx) }
            if (@battle.decision == 2 || @battle.pbAllFainted?) || 
               battler.opposes? && !@battle.opponent.nil? && @battle.opponent[idxTrainer]
              speaker = @battle.opponent[idxTrainer]
              opposing = true
            elsif !battler.opposes? && !@battle.player.nil? && @battle.player[idxTrainer]
              speaker = @battle.player[idxTrainer]
              opposing = false
            end
            showName = true if !showName
            speakerName = (showName) ? speaker.name : $player.name
            displayName = (showName) ? speakerName.upcase + ": " : ""
          end
        when String
          if playCry && !battler.nil?
            battler.pokemon.play_cry
          end
          if playAnim.is_a?(Symbol)
            midbattle_PlayAnimation(battler, idxTarget, playAnim)
          end
          if playSE
            pbSEPlay(sp)
          elsif playAnim && !playAnim.is_a?(Symbol)
            midbattle_PlayAnimation(battler, idxTarget, sp)
          elsif dialogue
            pbShowOpponent(idxTrainer) if speaker && opposing && showName
            @battle.pbDisplayPaused(_INTL("#{displayName}#{sp}", battler.name, speakerName))
            showName = false
            displayName = ""
          else
            lowercase = (sp[0] == "{" && sp[1] == "1") ? false : true
            @battle.pbDisplay(_INTL("#{sp}", battler.pbThis(lowercase), speakerName))
          end
          playSE = playCry = playAnim = false
        when :SE     then playSE   = true
        when :Cry    then playCry  = true
        when :Anim   then playAnim = true
        when Symbol  then playAnim = sp
        end
      end
    else
      if dialogue
        pbShowOpponent(idxTrainer) if speaker && opposing
        @battle.pbDisplayPaused(_INTL("#{displayName}#{speech}", battler.name, speakerName))
      else
        lowercase = (speech[0] == "{" && speech[1] == "1") ? false : true
        @battle.pbDisplay(_INTL("#{speech}", battler.pbThis(lowercase), speakerName))
      end
    end
    if dialogue
      pbToggleBlackBars
      pbToggleDataboxes(true)
      pbHideOpponent(idxTrainer) if speaker && opposing
    end
  end
  
  
  #-----------------------------------------------------------------------------
  # Gets a particular battler to target during midbattle checks.
  #-----------------------------------------------------------------------------
  def midbattle_Battler(idxBattler, idxTarget, index)
    case index
    #---------------------------------------------------------------------------
    # Targets specified index.
    when Numeric
      return (@battle.battlers[index]) ? @battle.battlers[index] : @battle.battlers[0]
    #---------------------------------------------------------------------------
    # Targets a battler on ally's side.
    when :Self, :Ally, :Ally2
      battler = (idxBattler && @battle.battlers[idxBattler]) ? @battle.battlers[idxBattler] : @battle.battlers[0]
      if battler.allAllies.length > 0
        case index
        when :Ally  then return battler.allAllies.first
        when :Ally2 then return battler.allAllies.last
        end
      end
      return battler
    #---------------------------------------------------------------------------
    # Targets a battler on opposing side.
    when :Opposing, :OpposingAlly, :OpposingAlly2
      default = (idxBattler && @battle.battlers[idxBattler]) ? @battle.battlers[idxBattler] : @battle.battlers[0]
      battler = (idxTarget && @battle.battlers[idxTarget])   ? @battle.battlers[idxTarget]  : default.pbDirectOpposing
      if battler.allAllies.length > 0 
        case index
        when :OpposingAlly  then return battler.allAllies.first
        when :OpposingAlly2 then return battler.allAllies.last
        end
      end
      return battler
    end
  end
  
  
  #-----------------------------------------------------------------------------
  # Changes the background music.
  #-----------------------------------------------------------------------------
  def midbattle_ChangeBGM(value)
    return if @battle.decision > 0
    if value.is_a?(Array)
      bgm, fade = value[0], value[1] * 1.0
    else
      bgm, fade = value, 0.0
    end
    pbBGMFade(fade)
    pbWait((fade * 60).round)
    pbBGMPlay(bgm)
  end
  
  
  #-----------------------------------------------------------------------------
  # Plays an animation.
  #-----------------------------------------------------------------------------
  def midbattle_PlayAnimation(battler, idxTarget, value)
    if value.is_a?(Array)
      anim, index = value[0], value[1]
    else
      anim, index = value, nil
    end
    target = (index) ? midbattle_Battler(battler.index, idxTarget, index) : nil
    if !target && GameData::Move.exists?(anim)
      case GameData::Move.get(anim).target
      when :NearAlly
        target = midbattle_Battler(battler.index, idxTarget, :Ally)
      when :Foe, :NearFoe, :RandomNearFoe, :NearOther, :Other
        target = midbattle_Battler(battler.index, idxTarget, :Opposing)
      else
        target = midbattle_Battler(battler.index, idxTarget, :Self)
      end
    end
    case anim
    when Symbol then pbAnimation(anim, battler, target)
    when String then pbCommonAnimation(anim, battler, target)
    end
  end
  
  
  #-----------------------------------------------------------------------------
  # Forces a battler to switch out.
  #-----------------------------------------------------------------------------
  def midbattle_ForceSwitch(battler, value)
    return if !battler || battler.fainted? || @battle.decision > 0
    if value.is_a?(Array)
      switch, msg = value[0], value[1]
    else
      switch, msg = value, nil
    end
    if !battler.wild?
      canSwitch = false
      newPkmn = nil
      #-------------------------------------------------------------------------
      # Checks if switching is possible.
      @battle.eachInTeamFromBattlerIndex(battler.index) do |pkmn, i|
        next if !@battle.pbCanSwitchLax?(battler.index, i)
        case switch
        when :Choose, :Random, :Forced
        when Numeric # Sets switch target to a specified party index.
          next if switch != i
        when Symbol  # Sets switch target to a specified species ID.
          next if !GameData::Species.exists?(switch)
          next if switch != pkmn.species
          newPkmn = i
        end
        canSwitch = true
        break
      end
      #-------------------------------------------------------------------------
      # Forces a switch.
      if canSwitch
        if newPkmn.nil?
          case switch
          when Numeric          then newPkmn = switch
          when :Choose          then newPkmn = @battle.pbSwitchInBetween(battler.index)
          when :Random, :Forced then newPkmn = @battle.pbGetReplacementPokemonIndex(battler.index, true)
          end
        end
        if newPkmn >= 0
          lowercase = (msg && msg[0] == "{" && msg[1] == "1") ? false : true
          trainerName = (battler.wild?) ? "" : @battle.pbGetOwnerName(battler.index)
          @battle.pbDisplay(_INTL("#{msg}", battler.pbThis(lowercase), trainerName)) if msg
          if switch == :Forced
            @battle.pbDisplay(_INTL("{1} went back to {2}!", battler.pbThis, trainerName))
            @battle.pbRecallAndReplace(battler.index, newPkmn, true)
            @battle.pbDisplay(_INTL("{1} was dragged out!", battler.pbThis))
          else
            @battle.pbMessageOnRecall(battler)
            @battle.pbRecallAndReplace(battler.index, newPkmn)
          end
          @battle.pbClearChoice(battler.index)
          @battle.pbOnBattlerEnteringBattle(battler.index)
        end
      end
    end
  end
  
  
  #-----------------------------------------------------------------------------
  # Uses an item on a battler. Item isn't used from the inventory.
  #-----------------------------------------------------------------------------
  def midbattle_UseItem(battler, value)
    return if !battler || battler.fainted? || @battle.decision > 0
    choices = [0] * 4
    battler.moves.each_with_index do |m, i|
      next if i == 0 || m.pp >= m.total_pp
      w = battler.moves[choices[3]]
      prevDiff = w.total_pp - w.pp
      moveDiff = m.total_pp - m.pp
      next if prevDiff > moveDiff 
      choices[3] = i
    end
    item = (value.is_a?(Array)) ? value.sample : value
    return if !ItemHandlers.triggerCanUseInBattle(item, battler.pokemon, battler, choices[3], true, @battle, self, false)
    if GameData::Item.get(item).is_poke_ball?
      battler = battler.pbDirectOpposing(true) if !battler.opposes?
    else
      return if battler.wild?
      trainerName = @battle.pbGetOwnerName(battler.index) 
      @battle.pbUseItemMessage(item, trainerName)
    end
    #---------------------------------------------------------------------------
    # Items that are used directly (Guard Spec., Poke Flute, Poke Ball, etc.)
    if ItemHandlers.hasUseInBattle(item)
      ItemHandlers.triggerUseInBattle(item, battler, @battle)
    #---------------------------------------------------------------------------
    # Items that are used on a battler (Red Flute, X Attack, Max Mushrooms, etc.) 
    elsif ItemHandlers.hasBattleUseOnBattler(item)
      ItemHandlers.triggerBattleUseOnBattler(item, battler, self)
      battler.pbItemOnStatDropped
    #---------------------------------------------------------------------------
    # Items that are used on a Pokemon (Potion, Ether, Full Heal, etc.)
    elsif ItemHandlers.hasBattleUseOnPokemon(item)
      ItemHandlers.triggerBattleUseOnPokemon(item, battler.pokemon, battler, choices, self)
    else
      @battle.pbDisplay(_INTL("But it had no effect!"))
    end
  end
  
  
  #-----------------------------------------------------------------------------
  # Forces the battler to use a specified move.
  #-----------------------------------------------------------------------------
  def midbattle_UseMove(battler, value)
    return if !battler || battler.fainted? || @battle.decision > 0
    return if battler.movedThisRound? ||
              battler.effects[PBEffects::ChoiceBand]    ||
              battler.effects[PBEffects::Instructed]    ||
              battler.effects[PBEffects::TwoTurnAttack] ||
              battler.effects[PBEffects::Encore]    > 0 ||
              battler.effects[PBEffects::HyperBeam] > 0 ||
              battler.effects[PBEffects::Outrage]   > 0 ||
              battler.effects[PBEffects::Rollout]   > 0 ||
              battler.effects[PBEffects::Uproar]    > 0 ||
              battler.effects[PBEffects::SkyDrop]  >= 0
    choice = @battle.choices[battler.index]
    return if choice[0] != :UseMove
    return if PluginManager.installed?("ZUD Mechanics") && choice[2].zMove?
    index = -1
    if value.is_a?(Array)
      move = value[0]
      target = value[1] || -1
    else
      move, target = value, -1
    end
    targBattler = @battle.battlers[target]
    reTarget = !targBattler || targBattler.fainted? || !targBattler.near?(battler)
    case move
    #---------------------------------------------------------------------------
    # Forces a particular kind of move.
    #---------------------------------------------------------------------------
    when :DamageSelf, :DamageAlly, :DamageFoe,     # Damaging moves
         :StatusSelf, :StatusAlly, :StatusFoe,     # Status moves
         :HealSelf,   :HealAlly,   :HealFoe        # Healing moves
      #-------------------------------------------------------------------------
      # Finalizes target.
      case move
      when :DamageSelf, :StatusSelf, :HealSelf     # Targets self
        target = battler.index
      when :DamageAlly, :StatusAlly, :HealAlly     # Targets an ally
        if reTarget || targBattler.idxOwnSide != battler.idxOwnSide
          battler.allAllies.each { |b| target = b.index if battler.near?(b) }
          return if target == -1
        end
      when :DamageFoe, :StatusFoe, :HealFoe        # Targets a foe
        if reTarget || targBattler.idxOwnSide == battler.idxOwnSide
          target = battler.pbDirectOpposing(true).index
        end
      end
      #-------------------------------------------------------------------------
      # Finalizes move.
      battler.moves.each_with_index do |m, i|
        case move
        when :DamageSelf, :DamageAlly
          next if !m.damagingMove?                 # Finds any damaging move.
        when :DamageFoe                            # Finds an effective damage-dealing move.
          next if !m.damagingMove?
          targBattler = @battle.battlers[target]
          effct = Effectiveness.calculate(m.pbCalcType(battler), *targBattler.pbTypes(true))
          next if Effectiveness.ineffective?(effct)
          next if Effectiveness.not_very_effective?(effct)
        when :StatusSelf, :StatusAlly, :StatusFoe  # Finds a status move.
          next if !m.statusMove?
          next if m.healingMove?
        when :HealSelf, :HealAlly, :HealFoe        # Finds a healing move. 
          next if !m.healingMove?		  
        end
        targ = GameData::Move.get(m.id).target
        targ = GameData::Target.get(targ)
        case move
        when :DamageSelf, :StatusSelf, :HealSelf   # Finds a self-targeting move.
          next if ![:User, :UserOrNearAlly, :UserAndAllies].include?(targ.id)
        when :DamageAlly, :StatusAlly, :HealAlly   # Finds a move that targets an ally.
          next if targ.num_targets == 0
          next if ![:NearAlly, :UserOrNearAlly, :AllAllies, :NearOther, :Other].include?(targ.id)
        when :DamageFoe, :StatusFoe, :HealFoe      # Finds a move that targets a foe.
          next if targ.num_targets == 0
          next if !targ.targets_foe
        end
        index = i
      end
      return if index == -1
    #---------------------------------------------------------------------------
    # Forces a move with a specified index or ID.
    #---------------------------------------------------------------------------
    when Integer, Symbol
      #-------------------------------------------------------------------------
      # Finalizes move.
      if move.is_a?(Symbol)
        return if !battler.pbHasMove?(move)
        battler.moves.each_with_index { |m, i| index = i if m.id == move }
      else
        index = move
      end
      return if !battler.moves[index]
      #-------------------------------------------------------------------------
      # Finalizes target.
      targ = GameData::Target.get(battler.moves[index].target)
      if targ.num_targets != 0
        if targ.targets_foe
          if reTarget || targBattler.idxOwnSide == battler.idxOwnSide
            target = battler.pbDirectOpposing(true).index
          end
        elsif targ == :NearAlly
          if reTarget || targBattler.idxOwnSide != battler.idxOwnSide
            target = -1
            battler.allAllies.each { |b| target = b.index if battler.near?(b) }
            return if target == -1
          end
        end
      else
        target = battler.index
      end
    end
    #---------------------------------------------------------------------------
    # Sets the battler's new choices for the forced move.
    #---------------------------------------------------------------------------
    if index >= 0 && @battle.pbCanChooseMove?(battler.index, index, false)
      choice[1] = index
      choice[2] = battler.moves[index]
    end
    choice[3] = target
  end
  
  
  #-----------------------------------------------------------------------------
  # Triggers the use of a special battle mechanic (Mega Evolution, Z-Moves, etc).
  #-----------------------------------------------------------------------------
  def midbattle_TriggerBattleMechanic(battler, value)
    return if !battler || battler.fainted? || @battle.decision > 0
    choice = @battle.choices[battler.index]
    return if choice[0] != :UseMove
    if value.is_a?(Array)
      special, msg = value[0], value[1]
    else
      special, msg = value, nil
    end
    lowercase = (msg && msg[0] == "{" && msg[1] == "1") ? false : true
    trainerName = (battler.wild?) ? "" : @battle.pbGetOwnerName(battler.index)
    case special
    #---------------------------------------------------------------------------
    # Mega Evolution
    when :MegaEvolution, :Megaevolution, :MegaEvolve, :Megaevolve, :Mega
      return if !@battle.pbCanMegaEvolve?(battler.index)
      @battle.pbDisplay(_INTL("#{msg}", battler.pbThis(lowercase), trainerName)) if msg
      @battle.pbMegaEvolve(battler.index)
    #---------------------------------------------------------------------------
    # Z-Moves
    when :ZMove, :Zmove
      return if !PluginManager.installed?("ZUD Mechanics")
      return if battler.movedThisRound?
      return if !@battle.pbCanZMove?(battler.index)
      return if !battler.hasCompatibleZMove?(choice[2])
      @battle.pbDisplay(_INTL("#{msg}", battler.pbThis(lowercase), trainerName)) if msg
      transform = battler.effects[PBEffects::TransformSpecies]
      choice[2] = battler.convert_zmove(choice[2], battler.item, transform)
      battler.power_trigger = true
      battler.display_power_moves("Z-Move")
      battler.selectedMoveIsZMove = true
    #---------------------------------------------------------------------------
    # Ultra Burst
    when :UltraBurst, :Ultraburst, :Ultra
      return if !PluginManager.installed?("ZUD Mechanics")
      return if !@battle.pbCanUltraBurst?(battler.index)
      @battle.pbDisplay(_INTL("#{msg}", battler.pbThis(lowercase), trainerName)) if msg
      battler.power_trigger = true
      @battle.pbUltraBurst(battler.index)
    #---------------------------------------------------------------------------
    # Dynamax
    when :Dynamax, :Dmax
      return if !PluginManager.installed?("ZUD Mechanics")
      return if !@battle.pbCanDynamax?(battler.index)
      @battle.pbDisplay(_INTL("#{msg}", battler.pbThis(lowercase), trainerName)) if msg
      if !battler.movedThisRound?
        transform = battler.effects[PBEffects::TransformSpecies]
        choice[2] = battler.convert_maxmove(choice[2], transform)
      end
      battler.power_trigger = true
      battler.display_power_moves("Max Move")
      @battle.pbDynamax(battler.index)
    #---------------------------------------------------------------------------
    # Battle Styles
    when :BattleStyle, :Battlestyle, :Style,
         :StrongStyle, :Strongstyle, :Strong,
         :AgileStyle,  :Agilestyle,  :Agile
      return if !PluginManager.installed?("PLA Battle Styles")
      return if battler.movedThisRound?
      return if !@battle.pbCanUseStyle?(battler.index)
      return if !choice[2].mastered?
      @battle.pbDisplay(_INTL("#{msg}", battler.pbThis(lowercase), trainerName)) if msg
      case special
      when :StrongStyle, :Strongstyle, :Strong
        battler.style_trigger = 1
      when :AgileStyle,  :Agilestyle,  :Agile
        battler.style_trigger = 2
      else
        battler.style_trigger = [1, 2].sample
      end
      battler.toggle_style_moves(battler.style_trigger)
      @battle.pbBattleStyle(battler.index)
    #---------------------------------------------------------------------------
    # Terastallization
    when :Terastallize, :Tera
      return if !PluginManager.installed?("Terastal Phenomenon")
      $player.tera_charged = true if battler.pbOwnedByPlayer?
      return if !@battle.pbCanTerastallize?(battler.index)
      @battle.pbDisplay(_INTL("#{msg}", battler.pbThis(lowercase), trainerName)) if msg
      @battle.pbTerastallize(battler.index)
    #---------------------------------------------------------------------------
    # Zodiac Powers
    when :ZodiacPower, :Zodiacpower, :Zodiac
      return if !PluginManager.installed?("Pokémon Birthsigns")
      return if !@battle.pbCanZodiacPower?(battler.index)
      @battle.pbDisplay(_INTL("#{msg}", battler.pbThis(lowercase), trainerName)) if msg
      @battle.pbZodiacPower(battler.index)
    #---------------------------------------------------------------------------
    # Focus Meter
    when :Focus, :FocusFull, :FocusEmpty
      return if !PluginManager.installed?("Focus Meter System")
      case special
      when :Focus      then battler.update_focus_meter(value[2]) if value[2]
      when :FocusFull  then battler.update_focus_meter(Settings::FOCUS_METER_SIZE)
      when :FocusEmpty then battler.update_focus_meter(-Settings::FOCUS_METER_SIZE)
      end
      return if battler.movedThisRound?
      return if !@battle.pbCanUseFocus?(battler.index)
      @battle.pbDisplay(_INTL("#{msg}", battler.pbThis(lowercase), trainerName)) if msg
      @battle.pbUseFocus(battler.index)
    #---------------------------------------------------------------------------
    # Custom Mechanic
    when :Custom
      return if !@battle.pbCanCustom?(battler.index)
      @battle.pbDisplay(_INTL("#{msg}", battler.pbThis(lowercase), trainerName)) if msg
      @battle.pbCustomMechanic(battler.index)
    end
  end
  
  
  #-----------------------------------------------------------------------------
  # Toggles the availability of a special battle mechanic (Mega Evolution, Z-Moves, etc).
  #-----------------------------------------------------------------------------
  def midbattle_ToggleBattleMechanic(battler, value)
    case value
    #---------------------------------------------------------------------------
    # Mega Evolution
    when :MegaEvolution, :Megaevolution, :MegaEvolve, :Megaevolve, :Mega
      $game_switches[Settings::NO_MEGA_EVOLUTION] = !$game_switches[Settings::NO_MEGA_EVOLUTION]
    #---------------------------------------------------------------------------
    # Z-Moves
    when :ZMove, :Zmove
      return if !PluginManager.installed?("ZUD Mechanics")
      $game_switches[Settings::NO_Z_MOVE] = !$game_switches[Settings::NO_Z_MOVE]
    #---------------------------------------------------------------------------
    # Ultra Burst
    when :UltraBurst, :Ultraburst, :Ultra
      return if !PluginManager.installed?("ZUD Mechanics")
      $game_switches[Settings::NO_ULTRA_BURST] = !$game_switches[Settings::NO_ULTRA_BURST]
    #---------------------------------------------------------------------------
    # Dynamax
    when :Dynamax, :Dmax
      return if !PluginManager.installed?("ZUD Mechanics")
      $game_switches[Settings::NO_DYNAMAX] = !$game_switches[Settings::NO_DYNAMAX]
    #---------------------------------------------------------------------------
    # Battle Styles
    when :BattleStyle, :BattleStyles, :Battlestyle, :Battlestyles, :Style, :Styles
      return if !PluginManager.installed?("PLA Battle Styles")
      $game_switches[Settings::NO_STYLE_MOVES] = !$game_switches[Settings::NO_STYLE_MOVES]
    #---------------------------------------------------------------------------
    # Terastallization
    when :Terastallize, :Tera
      return if !PluginManager.installed?("Terastal Phenomenon")
      $game_switches[Settings::NO_TERASTALLIZE] = !$game_switches[Settings::NO_TERASTALLIZE]
    #---------------------------------------------------------------------------
    # Zodiac Powers
    when :ZodiacPower, :ZodiacPowers, :Zodiacpower, :Zodiacpowers, :Zodiac
      return if !PluginManager.installed?("Pokémon Birthsigns")
      $game_switches[Settings::NO_ZODIAC_POWER] = !$game_switches[Settings::NO_ZODIAC_POWER]
    #---------------------------------------------------------------------------
    # Focus Meter
    when :Focus, :FocusFull, :FocusEmpty
      return if !PluginManager.installed?("Focus Meter System")
      $game_switches[Settings::NO_FOCUS_MECHANIC] = !$game_switches[Settings::NO_FOCUS_MECHANIC]
    end
  end
  
  
  #-----------------------------------------------------------------------------
  # Changes a battler's HP.
  #-----------------------------------------------------------------------------
  def midbattle_ChangeHP(battler, value)
    return if !battler || battler.fainted? || @battle.decision > 0
    if value.is_a?(Array)
      amt, msg = value[0], value[1]
    else
      amt, msg = value, nil
    end
    lowercase = (msg && msg[0] == "{" && msg[1] == "1") ? false : true
    trainerName = (battler.wild?) ? "" : @battle.pbGetOwnerName(battler.index)
    #---------------------------------------------------------------------------
    # Recovers HP
    if amt > 0
      case amt
      when 1 then healed = battler.pbRecoverHP(battler.totalhp)
      else        healed = battler.pbRecoverHP(battler.totalhp / amt)
      end
      @battle.pbDisplay(_INTL("#{msg}", battler.pbThis(lowercase), trainerName)) if msg && healed > 0
    #---------------------------------------------------------------------------
    # Reduces HP
    elsif amt < 0
      oldHP = battler.hp
      case amt.abs
      when 1 then battler.hp = 0
      else        battler.hp -= (battler.totalhp / amt.abs).round
      end
      battler.hp = 0 if battler.hp < 0
      pbHitAndHPLossAnimation([[battler, oldHP, 0]])
      @battle.pbDisplay(_INTL("#{msg}", battler.pbThis(lowercase), trainerName)) if msg
      battler.pbFaint if battler.fainted?
    end
  end
  
  
  #-----------------------------------------------------------------------------
  # Changes a battler's status.
  #-----------------------------------------------------------------------------
  def midbattle_ChangeStatus(battler, value)
    return if !battler || battler.fainted? || @battle.decision > 0
    if value.is_a?(Array)
      status, msg = value[0], value[1]
    else
      status, msg = value, false
    end
    status = status.sample if status.is_a?(Array)
    case status
    #---------------------------------------------------------------------------
    # Cures status condition.
    when :NONE
      battler.pbCureAttract
      battler.pbCureConfusion
      battler.pbCureStatus(msg)
    #---------------------------------------------------------------------------
    # Inflicts a random status out of the main status conditions.
    when :Random
      statuses = []
      GameData::Status.each { |s| statuses.push(s.id) if s.id != :NONE }
      status = statuses.sample
      return if !battler.pbCanInflictStatus?(status, battler, msg)
      battler.pbInflictStatus(status, (status == :SLEEP) ? battler.pbSleepDuration : 0)
    #---------------------------------------------------------------------------
    # Inflicts the given status condition.
    when :CONFUSION
      battler.pbConfuse(msg) if battler.pbCanConfuse?(battler, msg)
    when :TOXIC
      battler.pbPoison(nil, msg, true) if battler.pbCanPoison?(battler, msg)
    else
      if GameData::Status.exists?(status) && battler.pbCanInflictStatus?(status, battler, msg)
        battler.pbInflictStatus(status, (status == :SLEEP) ? battler.pbSleepDuration : 0)
      end
    end
    battler.pbCheckFormOnStatusChange
  end
  
  
  #-----------------------------------------------------------------------------
  # Changes a battler's form.
  #-----------------------------------------------------------------------------
  def midbattle_ChangeForm(battler, value)
    return if !battler || battler.fainted? || @battle.decision > 0
    if value.is_a?(Array)
      form, msg = value[0], value[1]
    else
      form, msg = value, nil
    end
    if msg.is_a?(String)
      lowercase = (msg[0] == "{" && msg[1] == "1") ? false : true
      trainerName = (battler.wild?) ? "" : @battle.pbGetOwnerName(battler.index)
      msg = _INTL("#{msg}", battler.pbThis(lowercase), trainerName)
    end
    case form
    #---------------------------------------------------------------------------
    # Cycles through each of the battler's eligible forms.
    when :Cycle
      form = battler.form + 1
    #---------------------------------------------------------------------------
    # Randomizes the battler's form.
    when :Random
      total_forms = []
      GameData::Species.each do |s|
        next if s.species != battler.species
        next if s.form == battler.form || s.form == 0			
        total_forms.push(s.form)
      end
      form = total_forms.sample
    end
    #---------------------------------------------------------------------------
    # Changes the battler's form if possilbe.
    return if !form
    species = GameData::Species.get_species_form(battler.species, form)
    form = GameData::Species.get(species).form
    battler.pbChangeForm(form, msg) if battler.form != form
  end
  
  
  #-----------------------------------------------------------------------------
  # Changes a battler's ability.
  #-----------------------------------------------------------------------------
  def midbattle_ChangeAbility(battler, value)
    return if !battler || battler.fainted? || @battle.decision > 0
    if value.is_a?(Array)
      abil, msg = value[0], value[1]
    else
      abil, msg = value, nil
    end
    abil = abil.sample if abil.is_a?(Array)
    abil = battler.pokemon.ability_id if abil == :Reset
    if GameData::Ability.exists?(abil) && !battler.unstoppableAbility? && battler.ability != abil
      @battle.pbShowAbilitySplash(battler, true, false) if msg
      oldAbil = battler.ability
      battler.ability = abil
      if msg
        @battle.pbReplaceAbilitySplash(battler)
        if msg.is_a?(String)
          lowercase = (msg[0] == "{" && msg[1] == "1") ? false : true
          trainerName = (battler.wild?) ? "" : @battle.pbGetOwnerName(battler.index)
          @battle.pbDisplay(_INTL("#{msg}", battler.pbThis(lowercase), trainerName))
        else
          @battle.pbDisplay(_INTL("{1} acquired {2}!", battler.pbThis, battler.abilityName))
        end
        @battle.pbHideAbilitySplash(battler)
      end
      battler.pbOnLosingAbility(oldAbil)
      battler.pbTriggerAbilityOnGainingIt
    end
  end
  
  
  #-----------------------------------------------------------------------------
  # Changes a battler's item.
  #-----------------------------------------------------------------------------
  def midbattle_ChangeItem(battler, value)
    return if !battler || battler.fainted? || @battle.decision > 0
    if value.is_a?(Array)
      item, msg = value[0], value[1]
    else
      item, msg = value, nil
    end
    item = item.sample if item.is_a?(Array)
    olditem = battler.item
    case item
    when :Remove
      battler.item = nil
    else
      battler.item = item if battler.item != item && GameData::Item.exists?(item)
    end
    if battler.item != olditem
      if msg
        if msg.is_a?(String)
          lowercase = (msg[0] == "{" && msg[1] == "1") ? false : true
          trainerName = (battler.wild?) ? "" : @battle.pbGetOwnerName(battler.index)
          @battle.pbDisplay(_INTL("#{msg}", battler.pbThis(lowercase), trainerName))
        else
          if battler.item
            itemName = GameData::Item.get(battler.item).portion_name
            text = (itemName.starts_with_vowel?) ? "an" : "a"
            @battle.pbDisplay(_INTL("{1} obtained {2} {3}!", battler.pbThis, text, itemName))
          elsif olditem
            @battle.pbDisplay(_INTL("{1}'s held {2} was removed!", battler.pbThis, GameData::Item.get(olditem).name))
          end
        end
      end
      battler.pbCheckFormOnHeldItemChange
    end
  end
  
  
  #-----------------------------------------------------------------------------
  # Changes a battler's moves.
  #-----------------------------------------------------------------------------
  def midbattle_ChangeMoves(battler, value)
    return if !battler || battler.fainted? || @battle.decision > 0
    case value
    #---------------------------------------------------------------------------
    # Replaces a battler's moveset with an array of moves.
    when Array
      value.each_with_index do |m, i|
        next if !GameData::Move.exists?(m)
        move = Pokemon::Move.new(m)
        battler.moves[i] = Battle::Move.from_pokemon_move(@battle, move)
      end
    #---------------------------------------------------------------------------
    # Resets a battler's moveset to its original moves.
    when :Reset
      battler.pokemon.reset_moves
      battler.pokemon.numMoves.times do |i|
        move = battler.pokemon.moves[i]
        battler.moves[i] = Battle::Move.from_pokemon_move(@battle, move)
      end
    #---------------------------------------------------------------------------
    # Replaces a battler's first move slot with a specified move.
    else
      if GameData::Move.exists?(value)
        move = Pokemon::Move.new(value)
        battler.moves[0] = Battle::Move.from_pokemon_move(@battle, move)
      end
    end
    battler.pbCheckFormOnMovesetChange
  end
  
  
  #-----------------------------------------------------------------------------
  # Changes a battler's stat stages.
  #-----------------------------------------------------------------------------
  def midbattle_ChangeStats(battler, value)
    return if !battler || battler.fainted? || @battle.decision > 0
    stats = []
    GameData::Stat.each_battle { |s| stats.push(s.id) }
    case value
    #---------------------------------------------------------------------------
    # Changes a battler's stat stages.
    when Array
      showAnim = true
      last_change = 0
      value.each do |s|
        next if s.is_a?(Integer) || s == :Random
        stats.delete(s)
      end
      for i in 0...value.length / 2
        stat, stage = value[i * 2], value[i * 2 + 1]
        #-----------------------------------------------------------------------
        # Determines a stat to change if randomized.
        if stat == :Random
          loop do
            break if stats.empty?
            randstat = stats.sample
            stats.delete(randstat) if randstat
            next if value.include?(randstat)
            stat = randstat
            break
          end
        end
        next if !stat.is_a?(Symbol) || !GameData::Stat.exists?(stat)
        next if !stage.is_a?(Integer) || stage == 0
        #-----------------------------------------------------------------------
        # Raise stat stage.
        if stage > 0
          next if !battler.pbCanRaiseStatStage?(stat, battler)
          showAnim = true if !showAnim && last_change == -1
          if battler.pbRaiseStatStage(stat, stage, battler, showAnim)
            showAnim = false
            last_change = 1
          end
        #-----------------------------------------------------------------------
        # Lower stat stage.
        else
          next if !battler.pbCanLowerStatStage?(stat, battler)
          showAnim = true if !showAnim && last_change == 1
          if battler.pbLowerStatStage(stat, stage.abs, battler, showAnim)
            showAnim = false
            last_change = -1
          end
          break if battler.pbItemOnStatDropped
        end
      end
      battler.pbItemStatRestoreCheck
    #---------------------------------------------------------------------------
    # Resets all of a battler's stat stages.
    when :Reset
      if battler.hasAlteredStatStages?
        battler.pbResetStatStages
        @battle.pbDisplay(_INTL("{1}'s stat changes were removed!", battler.pbThis))
      end
    #---------------------------------------------------------------------------
    # Resets all of a battler's positive stat stages.
    when :Reset_Raised
      if battler.hasRaisedStatStages?
        battler.statsDropped = true
        battler.statsLoweredThisRound = true
        GameData::Stat.each_battle { |s| battler.stages[s.id] = 0 if battler.stages[s.id] > 0 }
        @battle.pbDisplay(_INTL("{1}'s positive stat changes were removed!", battler.pbThis))
      end
    #---------------------------------------------------------------------------
    # Resets all of a battler's negative stat stages.
    when :Reset_Lowered
      if battler.hasLoweredStatStages?
        battler.statsRaisedThisRound = true
        GameData::Stat.each_battle { |s| battler.stages[s.id] = 0 if battler.stages[s.id] < 0 }
        @battle.pbDisplay(_INTL("{1}'s negative stat changes were removed!", battler.pbThis))
      end
    end
  end
  
  
  #-----------------------------------------------------------------------------
  # Applies effects on a battler.
  #-----------------------------------------------------------------------------
  def midbattle_BattlerEffects(battler, value)
    return if !battler || battler.fainted? || @battle.decision > 0
    value.each do |eff|
      effect, setting, msg = eff[0], eff[1], eff[2]
      lowercase = (msg && msg[0] == "{" && msg[1] == "1") ? false : true
      battler.apply_battler_effects(effect, setting, msg, lowercase)
    end
  end
  
  
  #-----------------------------------------------------------------------------
  # Applies effects on a battler's team.
  #-----------------------------------------------------------------------------
  def midbattle_TeamEffects(battler, value)
    return if !battler || @battle.decision > 0
    skip_message = []
    value.each do |eff|
      effect, setting, msg, user_msg = eff[0], eff[1], eff[2], eff[3]
      lowercase = (msg && msg[0] == "{" && msg[1] == "1") ? false : true
      case battler.idxOwnSide
      when 0 then index = (battler.index.even?) ? 0 : 1
      when 1 then index = (battler.index.odd?) ? 0 : 1
      end
      ret = battler.apply_team_effects(effect, setting, index, skip_message, msg, lowercase, user_msg)
      skip_message.push(ret) if ret
    end
  end
  
  
  #-----------------------------------------------------------------------------
  # Applies effects on the battlefield.
  #-----------------------------------------------------------------------------
  def midbattle_FieldEffects(battler, value)
    return if !battler || @battle.decision > 0
    value.each do |eff|
      effect, setting, msg = eff[0], eff[1], eff[2]
      lowercase = (msg && msg[0] == "{" && msg[1] == "1") ? false : true
      battler.apply_field_effects(effect, setting, msg, lowercase)
    end
  end
  
  
  #-----------------------------------------------------------------------------
  # Changes the weather.
  #-----------------------------------------------------------------------------
  def midbattle_ChangeWeather(battler, value)
    return if [:HarshSun, :HeavyRain, :StrongWinds].include?(@battle.field.weather) || @battle.decision > 0
    case value
    #---------------------------------------------------------------------------
    # Starts a random weather.
    when :Random
      array = []
      GameData::BattleWeather::DATA.keys.each do |w_key|
        next if [:None, :HarshSun, :HeavyRain, :StrongWinds, @battle.field.weather].include?(w_key)
        array.push(w_key)
      end
      weather = array.sample
      @battle.pbStartWeather(battler, weather, true)
    #---------------------------------------------------------------------------
    # Clears any active weather.
    when :None
      case @battle.field.weather
      when :Sun       then @battle.pbDisplay(_INTL("The sunlight faded."))
      when :Rain      then @battle.pbDisplay(_INTL("The rain stopped."))
      when :Sandstorm then @battle.pbDisplay(_INTL("The sandstorm subsided."))
      when :Hail      then @battle.pbDisplay(_INTL("The hail stopped."))
      when :ShadowSky then @battle.pbDisplay(_INTL("The shadow sky faded."))
      else                 @battle.pbDisplay(_INTL("The weather cleared."))
      end
      @battle.pbStartWeather(battler, :None, true)
    #---------------------------------------------------------------------------
    # Starts the specified weather.
    else
      if GameData::BattleWeather.exists?(value) && @battle.field.weather != value
        @battle.pbStartWeather(battler, value, true)
      end
    end
  end
  
  
  #-----------------------------------------------------------------------------
  # Changes the terrain.
  #-----------------------------------------------------------------------------
  def midbattle_ChangeTerrain(battler, value)
    return if @battle.decision > 0
    case value
    #---------------------------------------------------------------------------
    # Starts a random terrain.
    when :Random
      array = []
      GameData::BattleTerrain::DATA.keys.each do |t_key|
        next if [:None, @battle.field.terrain].include?(t_key)
        array.push(t_key)
      end
      terrain = array.sample
      @battle.pbStartTerrain(battler, terrain)
    #---------------------------------------------------------------------------
    # Clears any active terrain.
    when :None
      case @battle.field.terrain
      when :Electric  then @battle.pbDisplay(_INTL("The electricity disappeared from the battlefield."))
      when :Grassy    then @battle.pbDisplay(_INTL("The grass disappeared from the battlefield."))
      when :Misty     then @battle.pbDisplay(_INTL("The mist disappeared from the battlefield."))
      when :Psychic   then @battle.pbDisplay(_INTL("The weirdness disappeared from the battlefield."))
      else                 @battle.pbDisplay(_INTL("The battlefield normalized."))
      end
      @battle.pbStartTerrain(battler, :None)
    #---------------------------------------------------------------------------
    # Starts the specified terrain.
    else
      if GameData::BattleTerrain.exists?(value) && @battle.field.terrain != value
        @battle.pbStartTerrain(battler, value)
      end
    end
  end
  
  
  #-----------------------------------------------------------------------------
  # Changes the environment.
  #-----------------------------------------------------------------------------
  def midbattle_ChangeEnvironment(value)
    return if @battle.decision > 0
    case value
    #---------------------------------------------------------------------------
    # Sets a random environment.
    when :Random
      array = []
      GameData::Environment::DATA.keys.each do |e_key|
        next if [:None, @battle.environment].include?(e_key)
        array.push(e_key)
      end
      environ = array.sample
      @battle.environment = environ
    #---------------------------------------------------------------------------
    # Sets the specified environment.
    else
      if GameData::Environment.exists?(value)
        @battle.environment = value
      end
    end
  end
  
  
  #-----------------------------------------------------------------------------
  # Changes the backdrop.
  #-----------------------------------------------------------------------------
  def midbattle_ChangeBackdrop(value)
    return if @battle.decision > 0
    if value.is_a?(Array)
      backdrop, base = value[0], value[1]
    else
      backdrop = base = value
    end
    @battle.backdrop = backdrop if pbResolveBitmap("Graphics/Battlebacks/#{backdrop}_bg")
    if base && pbResolveBitmap("Graphics/Battlebacks/#{base}_base0")
      @battle.backdropBase = base 
      if base.include?("city")          then @battle.environment = :None
      elsif base.include?("grass")      then @battle.environment = :Grass
      elsif base.include?("water")      then @battle.environment = :MovingWater
      elsif base.include?("puddle")     then @battle.environment = :Puddle
      elsif base.include?("underwater") then @battle.environment = :Underwater
      elsif base.include?("cave")       then @battle.environment = :Cave
      elsif base.include?("rocky")      then @battle.environment = :Rock
      elsif base.include?("volcano")    then @battle.environment = :Volcano
      elsif base.include?("sand")       then @battle.environment = :Sand
      elsif base.include?("forest")     then @battle.environment = :Forest
      elsif base.include?("snow")       then @battle.environment = :Snow
      elsif base.include?("ice")        then @battle.environment = :Ice
      elsif base.include?("distortion") then @battle.environment = :Graveyard
      elsif base.include?("sky")        then @battle.environment = :Sky
      elsif base.include?("ultra")      then @battle.environment = :UltraSpace
      elsif base.include?("space")      then @battle.environment = :Space
      end
    end
    pbFlashRefresh
  end
end


#-------------------------------------------------------------------------------
# Battle Facility compatibility.
#-------------------------------------------------------------------------------
class Battle::DebugSceneNoLogging
  def dx_midbattle(idxBattler, idxTarget, *triggers); end
end