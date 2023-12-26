module Battle::AbilityEffects
  #Adding a new handler for wandering spirit due to deluxe override
  OnBeingHitSpirit                      = AbilityHandlerHash.new
  $aam_StatusImmunityFromAlly=[] if $aam_StatusImmunityFromAlly.nil?
  $aam_AccuracyCalcFromAlly=[] if $aam_AccuracyCalcFromAlly.nil?
  $aam_DamageCalcFromAlly=[] if $aam_DamageCalcFromAlly.nil?
  $aam_DamageCalcFromTargetAlly=[] if $aam_DamageCalcFromTargetAlly.nil?

  #=============================================================================

  def self.triggerSpeedCalc(ability, battler, mult)
	mult=1.0
    for i in battler.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      ret =  trigger(SpeedCalc, i, battler, mult, ret: mult)
      mult *= ret
    end	
    return mult
  end

  def self.triggerWeightCalc(ability, battler, weight)
	mult=1.0
    for i in battler.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      ret =  trigger(WeightCalc, i, battler, weight, ret: weight)
      mult *= ret
    end	
    return mult
  end

  #=============================================================================

  def self.triggerOnHPDroppedBelowHalf(ability, user, move_user, battle)
	spotted=false
    for i in user.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      ret =  trigger(OnHPDroppedBelowHalf, i, user, move_user, battle)
      spotted=true if ret==true
    end	
    return spotted
  end

  #=============================================================================

  def self.triggerStatusCheckNonIgnorable(ability, battler, status)
	spotted=false
    for i in battler.abilityMutationList
      ret =  trigger(StatusCheckNonIgnorable, i, battler, status)
      if ret==true
        spotted=true 
        $aamName=GameData::Ability.get(i).name
      end  
    end	
	  return spotted
  end

  def self.triggerStatusImmunity(ability, battler, status)
	spotted=false
    for i in battler.abilityMutationList
      ret =  trigger(StatusImmunity, i, battler, status)
      if ret==true
        spotted=true 
        $aamName=GameData::Ability.get(i).name
      end  
    end	
    return spotted
  end

  def self.triggerStatusImmunityNonIgnorable(ability, battler, status)
	spotted=false
    for i in battler.abilityMutationList
      ret =  trigger(StatusImmunityNonIgnorable, i, battler, status)
      if ret==true
        spotted=true 
        $aamName=GameData::Ability.get(i).name
      end  
    end	
    return spotted
  end
  
  def self.triggerStatusImmunityFromAlly(ability, battler, status) 
    spotted=false
    battler.allAllies.each do |b|
      if b.hasActiveAbility?(ability.id) && !$aam_StatusImmunityFromAlly.include?(b)
        $aam_StatusImmunityFromAlly.push(b)
        for i in b.abilityMutationList
          ret =  trigger(StatusImmunityFromAlly, i, battler, status)
          if ret==true
            spotted=true 
            $aamName=GameData::Ability.get(i).name
          end  
        end	
      end  
    end 
	  return spotted
  end

  def self.triggerOnStatusInflicted(ability, battler, user, status)
    for i in battler.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      OnStatusInflicted.trigger(i, battler, user, status)
    end	
  end

  def self.triggerStatusCure(ability, battler)
	spotted=false
    for i in battler.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      ret =  trigger(StatusCure, i, battler)  #check
      spotted=true if ret==true
    end	
    return spotted
  end

  #=============================================================================

  def self.triggerStatLossImmunity(ability, battler, stat, battle, show_messages)
	spotted=false
    for i in battler.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      ret = trigger(StatLossImmunity, i, battler, stat, battle, show_messages)
      spotted=true if ret==true
    end	
    return spotted
  end

  def self.triggerStatLossImmunityNonIgnorable(ability, battler, stat, battle, show_messages)
	spotted=false
    for i in battler.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      ret =  trigger(StatLossImmunityNonIgnorable, i, battler, stat, battle, show_messages)
      spotted=true if ret==true
    end	
    return spotted
  end

  def self.triggerStatLossImmunityFromAlly(ability, bearer, battler, stat, battle, show_messages)
	spotted=false
    for i in bearer.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      ret =  trigger(StatLossImmunityFromAlly, i, bearer, battler, stat, battle, show_messages)
      spotted=true if ret==true
    end	
    return spotted
  end
  
  if PluginManager.installed?("Generation 9 Pack")

	  def self.triggerOnStatGain(ability, battler, stat, user, increment)
      for i in battler.abilityMutationList
        $aamName=GameData::Ability.get(i).name
        OnStatGain.trigger(i, battler, stat, user, increment)
      end	
	  end

    def self.triggerCertainStatGain(ability, battler, battle, stat, user, increment)
      for i in battler.abilityMutationList
        $aamName=GameData::Ability.get(i).name
        CertainStatGain.trigger(ability, battler, battle, stat, user,increment)
      end	
    end
    
  else

	  def self.triggerOnStatGain(ability, battler, stat, user)
      for i in battler.abilityMutationList
        $aamName=GameData::Ability.get(i).name
        OnStatGain.trigger(i, battler, stat, user)
      end	
	  end

  end

  def self.triggerOnStatLoss(ability, battler, stat, user)
    for i in battler.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      OnStatLoss.trigger(i, battler, stat, user)
    end	
  end

  #=============================================================================

  def self.triggerPriorityChange(ability, battler, move, priority)
    for i in battler.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      priority = trigger(PriorityChange, i, battler, move, priority, ret: priority)
    end	
    return priority
  end

  def self.triggerPriorityBracketChange(ability, battler, battle)
    newprio = 0
    for i in battler.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      change = trigger(PriorityBracketChange, i, battler, battle, ret: 0)
      if change < 0 
        newprio = change if newprio < 1
      elsif change > 0
        newprio = change if change > newprio
      end
    end	
    return newprio
  end

  def self.triggerPriorityBracketUse(ability, battler, battle)
    for i in battler.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      PriorityBracketUse.trigger(i, battler, battle)
    end	
  end

  #=============================================================================

  def self.triggerOnFlinch(ability, battler, battle)
    for i in battler.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      OnFlinch.trigger(i, battler, battle)
    end	
  end

  def self.triggerMoveBlocking(ability, bearer, user, targets, move, battle)
	spotted=false
    for i in bearer.abilityMutationList
      ret =  trigger(MoveBlocking, i, bearer, user, targets, move, battle)
      if ret==true
        spotted=true 
        $aamName=GameData::Ability.get(i).name
      end  
    end	
    return spotted
  end

  def self.triggerMoveImmunity(ability, user, target, move, type, battle, show_message)
	spotted=false
    for i in target.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      ret =  trigger(MoveImmunity, i, user, target, move, type, battle, show_message)
      spotted=true if ret==true
    end	
    return spotted
  end

  #=============================================================================

  def self.triggerModifyMoveBaseType(ability, user, move, type)
    for i in user.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      return  trigger(ModifyMoveBaseType, i, user, move, type, ret: type)
    end	
  end

  #=============================================================================

  def self.triggerAccuracyCalcFromUser(ability, mods, user, target, move, type)
    for i in user.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      AccuracyCalcFromUser.trigger(i, mods, user, target, move, type)
    end	
  end

  def self.triggerAccuracyCalcFromAlly(ability, mods, user, target, move, type)
    user.allAllies.each do |b|
      if b.hasActiveAbility?(ability.id) && !$aam_AccuracyCalcFromAlly.include?(b)
        $aam_AccuracyCalcFromAlly.push(b)
        for i in b.abilityMutationList
          $aamName=GameData::Ability.get(i).name
          AccuracyCalcFromAlly.trigger(i, mods, user, target, move, type)
        end	
      end  
    end  
  end

  def self.triggerAccuracyCalcFromTarget(ability, mods, user, target, move, type)
    for i in target.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      AccuracyCalcFromTarget.trigger(i, mods, user, target, move, type)
    end	
  end

  #=============================================================================

  def self.triggerDamageCalcFromUser(ability, user, target, move, mults, base_damage, type)
    for i in user.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      DamageCalcFromUser.trigger(i, user, target, move, mults, base_damage, type)
    end	
  end

  def self.triggerDamageCalcFromAlly(ability, user, target, move, mults, base_damage, type)
    user.allAllies.each do |b|
      if b.hasActiveAbility?(ability.id) && !$aam_DamageCalcFromAlly.include?(b)
        $aam_DamageCalcFromAlly.push(b)
        for i in b.abilityMutationList
          $aamName=GameData::Ability.get(i).name
          DamageCalcFromAlly.trigger(i, user, target, move, mults, base_damage, type)
        end	
      end  
    end 
  end

  def self.triggerDamageCalcFromTarget(ability, user, target, move, mults, base_damage, type)
    for i in user.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      DamageCalcFromTarget.trigger(i, user, target, move, mults, base_damage, type)
    end	
  end

  def self.triggerDamageCalcFromTargetNonIgnorable(ability, user, target, move, mults, base_damage, type)
    for i in user.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      DamageCalcFromTargetNonIgnorable.trigger(i, user, target, move, mults, base_damage, type)
    end	
  end

  def self.triggerDamageCalcFromTargetAlly(ability, user, target, move, mults, base_damage, type)
    target.allAllies.each do |b|
      if b.hasActiveAbility?(ability.id) && !$aam_DamageCalcFromTargetAlly.include?(b)
        $aam_DamageCalcFromTargetAlly.push(b)
        for i in b.abilityMutationList
          $aamName=GameData::Ability.get(i).name
          DamageCalcFromTargetAlly.trigger(i, user, target, move, mults, base_damage, type)
        end	
      end  
    end 
  end

  def self.triggerCriticalCalcFromUser(ability, user, target, crit_stage)
    for i in user.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      crit_stage =  trigger(CriticalCalcFromUser, i, user, target, crit_stage, ret: crit_stage)
    end	
	  return crit_stage
  end

  def self.triggerCriticalCalcFromTarget(ability, user, target, crit_stage)
    vuln=0
    for i in target.abilityMutationList
      ret =  trigger(CriticalCalcFromTarget, i, user, target, crit_stage, ret: crit_stage)
      if ret<0
        $aamName=GameData::Ability.get(i).name
        vuln=ret 
      elsif ret>0
        $aamName=GameData::Ability.get(i).name
        vuln=ret if vuln>=0 && ret>vuln
      end  
    end	
    return vuln
  end

  #=============================================================================

  def self.triggerOnBeingHit(ability, user, target, move, battle)
    for i in target.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      if i == :WANDERINGSPIRIT
        OnBeingHitSpirit.trigger(i, user, target, move, battle)
      else
        OnBeingHit.trigger(i, user, target, move, battle)
      end
    end	
  end

  def self.triggerOnDealingHit(ability, user, target, move, battle)
    for i in user.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      OnDealingHit.trigger(i, user, target, move, battle)
    end	
  end

  #=============================================================================

  def self.triggerOnEndOfUsingMove(ability, user, targets, move, battle)
    for i in user.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      OnEndOfUsingMove.trigger(i, user, targets, move, battle)
    end	
  end

  def self.triggerAfterMoveUseFromTarget(ability, target, user, move, switched_battlers, battle)
    for i in target.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      AfterMoveUseFromTarget.trigger(i, target, user, move, switched_battlers, battle)
    end	
  end

  #=============================================================================

  def self.triggerEndOfRoundWeather(ability, weather, battler, battle)
    for i in battler.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      EndOfRoundWeather.trigger(i, weather, battler, battle)
    end	
  end

  def self.triggerEndOfRoundHealing(ability, battler, battle)
    for i in battler.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      EndOfRoundHealing.trigger(i, battler, battle)
    end	
  end

  def self.triggerEndOfRoundEffect(ability, battler, battle)
    for i in battler.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      EndOfRoundEffect.trigger(i, battler, battle)
    end	
  end

  def self.triggerEndOfRoundGainItem(ability, battler, battle)
    for i in battler.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      EndOfRoundGainItem.trigger(i, battler, battle)
    end	
  end

  #=============================================================================

  def self.triggerCertainSwitching(ability, switcher, battle)
	spotted=false
    for i in switcher.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      ret =  trigger(CertainSwitching, i, switcher, battle)
      spotted=true if ret==true
    end	
    return spotted
  end

  def self.triggerTrappingByTarget(ability, switcher, bearer, battle)
	spotted=false
    for i in bearer.abilityMutationList
      ret =  trigger(TrappingByTarget, i, switcher, bearer, battle)
      if ret==true
        spotted=true 
        $aamName=GameData::Ability.get(i).name
      end  
    end	
    if spotted
      if $aam_trapping
        return true 
      end
      return false
    else  
      return false
    end   
  end

  def self.triggerOnSwitchIn(ability, battler, battle, switch_in = false)
    for i in battler.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      OnSwitchIn.trigger(i, battler, battle, switch_in)
    end	
  end

  def self.triggerOnSwitchOut(ability, battler, end_of_battle)
    for i in battler.abilityMutationList
		  $aamName=GameData::Ability.get(i).name
      OnSwitchOut.trigger(i, battler, end_of_battle)
    end  
  end

  def self.triggerChangeOnBattlerFainting(ability, battler, fainted, battle)
    for i in battler.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      ChangeOnBattlerFainting.trigger(i, battler, fainted, battle)
    end	
  end

  def self.triggerOnBattlerFainting(ability, battler, fainted, battle)
    for i in battler.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      OnBattlerFainting.trigger(i, battler, fainted, battle)
    end	
  end

  def self.triggerOnTerrainChange(ability, battler, battle, ability_changed)
    for i in battler.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      OnTerrainChange.trigger(i, battler, battle, ability_changed)
    end	
  end

  def self.triggerOnIntimidated(ability, battler, battle)
    for i in battler.abilityMutationList
      $aamName=GameData::Ability.get(i).name
      OnIntimidated.trigger(i, battler, battle)
    end	
  end

  #=============================================================================

  def self.triggerCertainEscapeFromBattle(ability, battler)
	spotted=false
    for i in battler.abilityMutationList
      ret =  trigger(CertainEscapeFromBattle, i, battler)
      if ret==true
        spotted=true 
        $aamName=GameData::Ability.get(i).name
      end  
    end	
    return spotted
  end
  
end  


#===============================================================================
# Specific Ability overrides.
#===============================================================================

#===============================================================================
# Wandering Spirit
#===============================================================================
# Ability fails to trigger if the attacker is a Dynamaxed Pokemon.
#-------------------------------------------------------------------------------
Battle::AbilityEffects::OnBeingHitSpirit.add(:WANDERINGSPIRIT,
  proc { |ability, user, target, move, battle|
    next if !move.pbContactMove?(user)
    if PluginManager.installed?("ZUD Mechanics")
      next if user.dynamax?
    end  
    next if user.ungainableAbility? || [:RECEIVER, :WONDERGUARD].include?(user.ability_id)
    next if user.hasActiveItem?(:ABILITYSHIELD) # Generation 9 pack compatibility
    oldUserAbil   = nil
    oldTargetAbil = nil
    $aamName="Wandering Spirit"
    battle.pbShowAbilitySplash(target) if user.opposes?(target)
    if user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
      battle.pbShowAbilitySplash(user, true, false) if user.opposes?(target)
      oldUserAbil   = user.abilityMutationList[0]
      oldTargetAbil = target.abilityMutationList[0]
      index=0
      for i in 0..target.abilityMutationList.length
        oldTargetAbil = target.abilityMutationList[i] if target.abilityMutationList[i] == :WANDERINGSPIRIT
        index=i
      end    
      if user.hasAbilityMutation?
        user.abilityMutationList[0] = oldTargetAbil  
      else
        user.ability   = oldTargetAbil    
      end  
      if target.hasAbilityMutation?
        target.abilityMutationList[index] = oldUserAbil
      else
        target.ability = oldUserAbil  
      end  
      if user.opposes?(target)
        battle.pbReplaceAbilitySplash(user)
        $aamName=GameData::Ability.get(oldUserAbil).name
        battle.pbReplaceAbilitySplash(target)
      end
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} swapped Abilities with {2}!", target.pbThis, user.pbThis(true)))
      else
        battle.pbDisplay(_INTL("{1} swapped its {2} Ability with {3}'s {4} Ability!",
           target.pbThis, user.abilityName, user.pbThis(true), target.abilityName))
      end
      if user.opposes?(target)
        battle.pbHideAbilitySplash(user)
        battle.pbHideAbilitySplash(target)
      end
    end
    battle.pbHideAbilitySplash(target) if user.opposes?(target)
    user.pbOnLosingAbility(oldUserAbil)
    target.pbOnLosingAbility(oldTargetAbil)
    user.pbTriggerAbilityOnGainingIt
    target.pbTriggerAbilityOnGainingIt
  }
)


#===============================================================================
# ChangeOnBattlerFainting handlers
#===============================================================================

Battle::AbilityEffects::ChangeOnBattlerFainting.add(:POWEROFALCHEMY,
  proc { |ability, battler, fainted, battle|
    next if battler.opposes?(fainted)
    next if fainted.ungainableAbility? ||
       [:SEANCE, :POWEROFALCHEMY, :RECEIVER, :TRACE, :WONDERGUARD].include?(fainted.ability_id)
    battle.pbShowAbilitySplash(battler, true)
    index=0
    for i in 0..battler.abilityMutationList.length
      if battler.abilityMutationList[i] == :POWEROFALCHEMY
        index=i 
        $aamName="Power of Alchemy"
      end  
      if battler.abilityMutationList[i] == :RECEIVER
        index=i 
        $aamName="Receiver"
      end  
    end    
    if battler.hasAbilityMutation?
      battler.abilityMutationList[index] = fainted.ability.id
    else
      battler.ability = fainted.ability
    end    
    $aamName=fainted.abilityName
    battle.pbReplaceAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1}'s {2} was taken over!", fainted.pbThis, fainted.abilityName))
    battle.pbHideAbilitySplash(battler)
    #print battler.abilityMutationList
  }
)

Battle::AbilityEffects::ChangeOnBattlerFainting.copy(:POWEROFALCHEMY, :RECEIVER)

Battle::AbilityEffects::OnBattlerFainting.add(:SEANCE, #by low
  proc { |ability,battler,fainted,battle|
    next if fainted.ungainableAbility? || [:SEANCE, :POWEROFALCHEMY, :RECEIVER, :TRACE, :WONDERGUARD].include?(fainted.ability_id)
    battle.pbShowAbilitySplash(battler, true)
    index=0
    for i in 0..battler.abilityMutationList.length
      if battler.abilityMutationList[i] == :SEANCE
        index=i 
        $aamName="Seance"
      end
    end    
    if battler.hasAbilityMutation?
      battler.abilityMutationList[index] = fainted.ability.id
    else
      battler.ability = fainted.ability
    end    
    $aamName=fainted.abilityName
    battle.pbReplaceAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1}'s {2} was taken!",fainted.pbThis,fainted.abilityName))
    battle.pbHideAbilitySplash(battler)
    #print battler.abilityMutationList
  }
)

###############################
# Ability Combos Section
###############################

# Immunity x Toxic Boost/Poison Heal:  Poison Is not cured.
Battle::AbilityEffects::StatusCure.add(:IMMUNITY,
  proc { |ability, battler|
    next if battler.status != :POISON
	next if battler.abilityMutationList.include?(:TOXICBOOST)
	next if battler.abilityMutationList.include?(:POISONHEAL)
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(Battle::Scene::USE_ABILITY_SPLASH)
    if !Battle::Scene::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} cured its poisoning!", battler.pbThis, battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)


Battle::AbilityEffects::OnSwitchOut.add(:IMMUNITY,
  proc { |ability, battler, endOfBattle|
    next if battler.status != :POISON
    next if battler.abilityMutationList.include?(:TOXICBOOST)
    next if battler.abilityMutationList.include?(:POISONHEAL)
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
    battler.status = :NONE
  }
)
