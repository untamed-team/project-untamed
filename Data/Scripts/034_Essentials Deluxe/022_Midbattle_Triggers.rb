#===============================================================================
# Makes additions to various battle code to allow mid-battle settings to trigger.
#===============================================================================


class Battle::Scene
  #-----------------------------------------------------------------------------
  # Compiles a list of all viable triggers of each type to check for.
  #-----------------------------------------------------------------------------
  def pbDeluxeTriggers(battler, idxBattler, triggers)
    array = []
    battler = @battle.battlers[battler] if battler.is_a?(Integer)
    triggers.each { |t| array.push((battler.pbOwnedByPlayer?) ? t : (battler.opposes?) ? t + "_foe" : t + "_ally") }
    dx_midbattle(battler.index, idxBattler, *array) if !array.empty?
  end

  #-----------------------------------------------------------------------------
  # Mid-battle triggers for when a Pokemon faints.
  #-----------------------------------------------------------------------------
  alias dx_pbFaintBattler pbFaintBattler
  def pbFaintBattler(battler)
    dx_pbFaintBattler(battler)
    if !@battle.pbAllFainted?(battler.index)
      triggers = ["fainted", "fainted" + battler.species.to_s]
      battler.pokemon.types.each { |t| triggers.push("fainted" + t.to_s) }
      pbDeluxeTriggers(battler, nil, triggers)
    end
  end
end


class Battle
  #-----------------------------------------------------------------------------
  # Mid-battle triggers for when items are used.
  #-----------------------------------------------------------------------------
  alias dx_pbUseItemOnPokemon pbUseItemOnPokemon
  def pbUseItemOnPokemon(item, idxParty, userBattler)
    triggers = ["item", "item" + item.to_s]
    @scene.pbDeluxeTriggers(userBattler, nil, triggers)
    dx_pbUseItemOnPokemon(item, idxParty, userBattler)
  end

  alias dx_pbUseItemOnBattler pbUseItemOnBattler
  def pbUseItemOnBattler(item, idxParty, userBattler)
    triggers = ["item", "item" + item.to_s]
    @scene.pbDeluxeTriggers(userBattler, nil, triggers)
    dx_pbUseItemOnBattler(item, idxParty, userBattler)
  end
  
  alias dx_pbUseItemInBattle pbUseItemInBattle
  def pbUseItemInBattle(item, idxBattler, userBattler)
    triggers = ["item", "item" + item.to_s]
    @scene.pbDeluxeTriggers(userBattler, idxBattler, triggers)
    dx_pbUseItemInBattle(item, idxBattler, userBattler)
  end
  
  #-----------------------------------------------------------------------------
  # Mid-battle triggers for when Pokemon are recalled and sent out.
  #-----------------------------------------------------------------------------
  alias dx_pbMessageOnRecall pbMessageOnRecall
  def pbMessageOnRecall(battler)
    if !battler.fainted?
      triggers = ["recall", "recall" + battler.species.to_s]
      battler.pokemon.types.each { |t| triggers.push("recall" + t.to_s) }
      @scene.pbDeluxeTriggers(battler, nil, triggers)
    end
    dx_pbMessageOnRecall(battler)
  end
  
  alias dx_pbMessagesOnReplace pbMessagesOnReplace
  def pbMessagesOnReplace(idxBattler, idxParty)
    nextPoke = pbParty(idxBattler)[idxParty]
    triggers = ["beforeNext", "beforeNext" + nextPoke.species.to_s]
    nextPoke.types.each { |t| triggers.push("beforeNext" + t.to_s) }
    triggers.push("beforeLast") if pbAbleNonActiveCount(idxBattler) == 1
    @scene.pbDeluxeTriggers(idxBattler, nil, triggers)
    dx_pbMessagesOnReplace(idxBattler, idxParty)
  end
  
  alias dx_pbReplace pbReplace
  def pbReplace(idxBattler, idxParty, batonPass = false)
    dx_pbReplace(idxBattler, idxParty, batonPass)
    battler = @battlers[idxBattler]
    triggers = ["afterNext", "afterNext" + battler.species.to_s]
    battler.pokemon.types.each { |t| triggers.push("afterNext" + t.to_s) }
    triggers.push("afterLast") if pbAbleNonActiveCount(idxBattler) == 0
    @scene.pbDeluxeTriggers(idxBattler, nil, triggers)
  end
  
  #-----------------------------------------------------------------------------
  # Mid-battle triggers for the end of round.
  #-----------------------------------------------------------------------------
  alias dx_pbEndOfRoundPhase pbEndOfRoundPhase
  def pbEndOfRoundPhase
    ret = dx_pbEndOfRoundPhase
    @scene.dx_midbattle(nil, nil, "turnEnd", "turnEnd_" + (1 + @turnCount).to_s)
    return ret
  end
  
  #-----------------------------------------------------------------------------
  # Mid-battle triggers upon losing a battle.
  #-----------------------------------------------------------------------------
  alias dx_pbLoseMoney pbLoseMoney
  def pbLoseMoney
    @scene.dx_midbattle(nil, nil, "loss")
    dx_pbLoseMoney
  end
end


module Battle::CatchAndStoreMixin
  #-----------------------------------------------------------------------------
  # Mid-battle triggers during the capture process.
  #-----------------------------------------------------------------------------
  alias dx_pbThrowPokeBall pbThrowPokeBall
  def pbThrowPokeBall(*args)
    idxBattler = args[0]
    if opposes?(idxBattler)
      battler = @battlers[idxBattler]
    else
      battler = @battlers[idxBattler].pbDirectOpposing(true)
    end
    personalID = battler.pokemon.personalID
    @scene.dx_midbattle(idxBattler, battler.index, "beforeCapture")
    dx_pbThrowPokeBall(*args)
    captured = false
    @caughtPokemon.each { |p| captured = true if p.personalID == personalID }
    if captured
      @scene.dx_midbattle(nil, nil, "afterCapture") 
    else
      @scene.dx_midbattle(nil, nil, "failedCapture") 
    end
  end
end


class Battle::Battler
  #-----------------------------------------------------------------------------
  # Mid-battle triggers for when a move is used.
  #-----------------------------------------------------------------------------
  alias dx_pbTryUseMove pbTryUseMove
  def pbTryUseMove(*args)
    ret = dx_pbTryUseMove(*args)
    if ret
      type = args[1].type.to_s
      triggers = ["move", "move" + type, "move" + args[1].id.to_s]
      if args[1].damagingMove?
        triggers.push("damageMove", "damageMove" + type)
        triggers.push("physicalMove", "physicalMove" + type) if args[1].physicalMove?
        triggers.push("specialMove", "specialMove" + type) if args[1].specialMove?
      else
        triggers.push("statusMove", "statusMove" + type)
      end
      @battle.scene.pbDeluxeTriggers(self, args[0][3], triggers)
    end
    return ret
  end
  
  #-----------------------------------------------------------------------------
  # Mid-battle triggers for when a used move fails.
  #-----------------------------------------------------------------------------
  alias dx_pbSuccessCheckAgainstTarget pbSuccessCheckAgainstTarget
  def pbSuccessCheckAgainstTarget(move, user, target, targets)
    ret = dx_pbSuccessCheckAgainstTarget(move, user, target, targets)
    if !ret
      trigger = (user.pbOwnedByPlayer?) ? "immune" : (user.opposes?) ? "immune_foe" : "immune_ally"
      @battle.scene.dx_midbattle(user.index, target.index, trigger)
    end
    return ret
  end
  
  #-----------------------------------------------------------------------------
  # Mid-battle triggers for when a used move misses.
  #-----------------------------------------------------------------------------
  alias dx_pbMissMessage pbMissMessage
  def pbMissMessage(move, user, target)
    dx_pbMissMessage(move, user, target)
    trigger = (user.pbOwnedByPlayer?) ? "miss" : (user.opposes?) ? "miss_foe" : "miss_ally"
    @battle.scene.dx_midbattle(user.index, target.index, trigger)
  end
  
  #-----------------------------------------------------------------------------
  # Mid-battle triggers for when a status condition is inflicted.
  #-----------------------------------------------------------------------------
  alias dx_pbInflictStatus pbInflictStatus 
  def pbInflictStatus(*args)
    oldStatus = self.status
    dx_pbInflictStatus(*args)
    if ![:NONE, oldStatus].include?(self.status)
      triggers = ["inflictStatus", "inflictStatus" + self.status.to_s]
      @battle.scene.pbDeluxeTriggers(self, nil, triggers)
    end
  end
end


class Battle::Move
  #-----------------------------------------------------------------------------
  # Mid-battle triggers for type effectiveness of a used move.
  #-----------------------------------------------------------------------------
  def pbEffectivenessMessage(user, target, numTargets = 1)
    return if target.damageState.disguise || target.damageState.iceFace
    trigger = nil
    if Effectiveness.super_effective?(target.damageState.typeMod)
      if numTargets > 1
        @battle.pbDisplay(_INTL("It's super effective on {1}!", target.pbThis(true)))
      else
        @battle.pbDisplay(_INTL("It's super effective!"))
      end
      trigger = (user.pbOwnedByPlayer?) ? "superEffective" : (user.opposes?) ? "superEffective_foe" : "superEffective_ally"
    elsif Effectiveness.not_very_effective?(target.damageState.typeMod)
      if numTargets > 1
        @battle.pbDisplay(_INTL("It's not very effective on {1}...", target.pbThis(true)))
      else
        @battle.pbDisplay(_INTL("It's not very effective..."))
      end
      trigger = (user.pbOwnedByPlayer?) ? "notVeryEffective" : (user.opposes?) ? "notVeryEffective_foe" : "notVeryEffective_ally"
    end
    return trigger
  end

  #-----------------------------------------------------------------------------
  # Mid-battle triggers for when a used move deals damage.
  #-----------------------------------------------------------------------------
  def pbHitEffectivenessMessages(user, target, numTargets = 1)
    return if target.damageState.disguise || target.damageState.iceFace
    if target.damageState.substitute
      @battle.pbDisplay(_INTL("The substitute took damage for {1}!", target.pbThis(true)))
    end
    user_triggers = []
    target_triggers = []
    if target.damageState.critical
      if $game_temp.party_critical_hits_dealt &&
         $game_temp.party_critical_hits_dealt[user.pokemonIndex] &&
         user.pbOwnedByPlayer?
        $game_temp.party_critical_hits_dealt[user.pokemonIndex] += 1
      end
      if target.damageState.affection_critical
        if numTargets > 1
          @battle.pbDisplay(_INTL("{1} landed a critical hit on {2}, wishing to be praised!",
                                  user.pbThis, target.pbThis(true)))
        else
          @battle.pbDisplay(_INTL("{1} landed a critical hit, wishing to be praised!", user.pbThis))
        end
      elsif numTargets > 1
        @battle.pbDisplay(_INTL("A critical hit on {1}!", target.pbThis(true)))
      else
        @battle.pbDisplay(_INTL("A critical hit!"))
      end
      user_triggers.push((user.pbOwnedByPlayer?) ? "criticalHit" : (user.opposes?) ? "criticalHit_foe" : "criticalHit_ally") if user.opposes?(target.index)
    end
    if !multiHitMove? && user.effects[PBEffects::ParentalBond] == 0
      effectiveness_trigger = pbEffectivenessMessage(user, target, numTargets)
      user_triggers.push(effectiveness_trigger) if effectiveness_trigger && user.opposes?(target.index)
    end
    if target.damageState.substitute && target.effects[PBEffects::Substitute] == 0
      target.effects[PBEffects::Substitute] = 0
      @battle.pbDisplay(_INTL("{1}'s substitute faded!", target.pbThis))
    end
    if !target.damageState.substitute
      @battle.scene.dx_midbattle(user.index, target.index, *user_triggers) if user_triggers.length > 0
      if user.opposes?(target.index)
        target_triggers.push((target.pbOwnedByPlayer?) ? "damageTaken" : (target.opposes?) ? "damageTaken_foe" : "damageTaken_ally")
      end
      if !target.fainted? && user.opposes?(target.index)
        if target.hp <= target.totalhp / 2
          lowHP = target.hp <= target.totalhp / 4
          if @battle.pbParty(target.index).length > @battle.pbSideSize(target.index)
            if @battle.pbAbleNonActiveCount(target.index) == 0
              target_triggers.push((target.pbOwnedByPlayer?) ? "halfHPLast" : (target.opposes?) ? "halfHPLast_foe" : "halfHPLast_ally")
              target_triggers.push((target.pbOwnedByPlayer?) ? "lowHPLast" : (target.opposes?) ? "lowHPLast_foe" : "lowHPLast_ally") if lowHP
            else
              target_triggers.push((target.pbOwnedByPlayer?) ? "halfHP" : (target.opposes?) ? "halfHP_foe" : "halfHP_ally")
              target_triggers.push((target.pbOwnedByPlayer?) ? "lowHP" : (target.opposes?) ? "lowHP_foe" : "lowHP_ally") if lowHP
            end
          else
            target_triggers.push((target.pbOwnedByPlayer?) ? "halfHP" : (target.opposes?) ? "halfHP_foe" : "halfHP_ally")
            target_triggers.push((target.pbOwnedByPlayer?) ? "halfHPLast" : (target.opposes?) ? "halfHPLast_foe" : "halfHPLast_ally")
            target_triggers.push((target.pbOwnedByPlayer?) ? "lowHP" : (target.opposes?) ? "lowHP_foe" : "lowHP_ally") if lowHP
            target_triggers.push((target.pbOwnedByPlayer?) ? "lowHPLast" : (target.opposes?) ? "lowHPLast_foe" : "lowHPLast_ally") if lowHP
          end
        end
      end
      @battle.scene.dx_midbattle(target.index, user.index, *target_triggers) if target_triggers.length > 0
    end
  end
end