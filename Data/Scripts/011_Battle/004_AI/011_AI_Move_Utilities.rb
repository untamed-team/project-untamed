class Battle::AI
  #=============================================================================
  #
  #=============================================================================
  def pbTargetsMultiple?(move, user)
    target_data = move.pbTarget(user)
    return false if target_data.num_targets <= 1
    num_targets = 0
    case target_data.id
    when :AllAllies
      @battle.allSameSideBattlers(user).each { |b| num_targets += 1 if b.index != user.index }
    when :UserAndAllies
      @battle.allSameSideBattlers(user).each { |_b| num_targets += 1 }
    when :AllNearFoes
      @battle.allOtherSideBattlers(user).each { |b| num_targets += 1 if b.near?(user) }
    when :AllFoes
      @battle.allOtherSideBattlers(user).each { |_b| num_targets += 1 }
    when :AllNearOthers
      @battle.allBattlers.each { |b| num_targets += 1 if b.near?(user) }
    when :AllBattlers
      @battle.allBattlers.each { |_b| num_targets += 1 }
    end
    return num_targets > 1
  end

  #=============================================================================
  # Move's type effectiveness
  #=============================================================================
  def pbCalcTypeModSingle(moveType, defType, user, target)
    ret = Effectiveness.calculate_one(moveType, defType)
    if Effectiveness.ineffective_type?(moveType, defType)
      # Ring Target
      if target.hasActiveItem?(:RINGTARGET)
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE
      end
      # Foresight
      if (user.hasActiveAbility?(:SCRAPPY) || target.effects[PBEffects::Foresight]) &&
         defType == :GHOST
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE
      end
      # Corrosion #by low
      if user.hasActiveAbility?(:CORROSION) && defType == :STEEL
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE
      end
      # Miracle Eye
      if target.effects[PBEffects::MiracleEye] && defType == :DARK
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE
      end
    elsif Effectiveness.super_effective_type?(moveType, defType)
      # Delta Stream's weather
      if target.effectiveWeather == :StrongWinds && defType == :FLYING
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE
      end
		elsif !Effectiveness.super_effective_type?(moveType, defType)
			# Mass Extinction #by low
			if user.hasActiveAbility?(:MASSEXTINCTION) && defType == :DRAGON
				ret = Effectiveness::SUPER_EFFECTIVE_ONE
			end
    end
    # Grounded Flying-type Pokémon become susceptible to Ground moves
    if !target.airborne? && defType == :FLYING && moveType == :GROUND
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE
    end
    return ret
  end

  def pbCalcTypeMod(moveType, user, target)
    return Effectiveness::NORMAL_EFFECTIVE if !moveType
    return Effectiveness::NORMAL_EFFECTIVE if moveType == :GROUND &&
                                              target.pbHasType?(:FLYING, true) &&
                                              target.hasActiveItem?(:IRONBALL)
    # Determine types
    tTypes = target.pbTypes(true, true)
    # Get effectivenesses
    typeMods = [Effectiveness::NORMAL_EFFECTIVE_ONE] * 3   # 3 types max
    if moveType == :SHADOW
      if target.shadowPokemon?
        typeMods[0] = Effectiveness::NOT_VERY_EFFECTIVE_ONE
      else
        typeMods[0] = Effectiveness::SUPER_EFFECTIVE_ONE
      end
    else
      tTypes.each_with_index do |type, i|
        typeMods[i] = pbCalcTypeModSingle(moveType, type, user, target)
      end
    end
    # Multiply all effectivenesses together
    ret = 1
    typeMods.each { |m| ret *= m }
		# Inverse Battle Switch #by low
		# 8x = ret 64
		# 4x = ret 32
		if $game_switches[INVERSEBATTLESWITCH]
			if ret == 0
				ret = 16
			elsif ret >= 64
				ret = 0
			else
				ret = (64 / ret)
			end
		end
		#~ print ret
		ret = 14 if ret > 14 && !target.pbOwnedByPlayer? && $game_variables[MASTERMODEVARS][28]==true
    return ret
  end

  # For switching. Determines the effectiveness of a potential switch-in against
  # an opposing battler.
  def pbCalcTypeModPokemon(battlerThis, _battlerOther)
    mod1 = Effectiveness.calculate(battlerThis.types[0], target.types[0], target.types[1])
    mod2 = Effectiveness::NORMAL_EFFECTIVE
    if battlerThis.types.length > 1
      mod2 = Effectiveness.calculate(battlerThis.types[1], target.types[0], target.types[1])
      mod2 = mod2.to_f / Effectivenesss::NORMAL_EFFECTIVE
    end
    return mod1 * mod2
  end

  #=============================================================================
  # Immunity to a move because of the target's ability, item or other effects
  #=============================================================================
  # moved to extra utilities

  #=============================================================================
  # Get approximate properties for a battler
  #=============================================================================
  def pbRoughType(move, user, skill)
    ret = move.type
    if skill >= PBTrainerAI.highSkill
      ret = move.pbCalcType(user)
    end
    # WillMega / Mid-turn mega move type calcuation
    if user.willmega
      if move.type == :NORMAL # -ate / -ize abilities
        if user.isSpecies?(:HAWLUCHA) && $game_variables[MECHANICSVAR] >= 3 && !user.pokemon.hasHiddenAbility?
          ret = :ELECTRIC
        elsif user.isSpecies?(:GOLURK) && $game_variables[MECHANICSVAR] <= 3
          ret = :FLYING
        end
      end
    end
    return ret
  end

  def pbRoughStat(battler, stat, skill)
    atkmul=defmul=spemul=spamul=spdmul=1
    if battler.pokemon.willmega
      mega_data = MEGA_EVO_STATS[battler.species]
      if mega_data && (battler.item == mega_data[:item] || battler.hasMegaEvoMutation?)
        if battler.species == :BEAKRAFT
          gender_data = battler.gender == 0 ? mega_data[:male] : mega_data[:female]
          atkmul, defmul, spemul, spamul, spdmul = gender_data.values_at(:atkmul, :defmul, :spemul, :spamul, :spdmul)
        else
          atkmul, defmul, spemul, spamul, spdmul = mega_data.values_at(:atkmul, :defmul, :spemul, :spamul, :spdmul)
        end
      end
    end
    return battler.pbSpeed*spemul if skill >= PBTrainerAI.highSkill && stat == :SPEED
    stageMul = [2, 2, 2, 2, 2, 2, 2, 3, 4, 5, 6, 7, 8]
    stageDiv = [8, 7, 6, 5, 4, 3, 2, 2, 2, 2, 2, 2, 2]
    stage = battler.stages[stat] + 6
    value = 0
    case stat
    when :ATTACK          then value = battler.attack*atkmul
    when :DEFENSE         then value = battler.defense*defmul
    when :SPEED           then value = battler.speed*spemul
    when :SPECIAL_ATTACK  then value = battler.spatk*spamul
    when :SPECIAL_DEFENSE then value = battler.spdef*spdmul
    end
    #Console.echo_h2("Stats = #{battler.attack}, #{battler.defense}, #{battler.speed}, #{battler.spatk}, #{battler.spdef}") if battler.pokemon.willmega
    #Console.echo_h2("Multis = (#{atkmul}, #{(battler.attack*atkmul)}), (#{defmul}, #{(battler.defense*defmul)}), (#{spemul}, #{(battler.speed*spemul)}), (#{spamul}, #{(battler.spatk*spamul)}), (#{spdmul}, #{(battler.spdef*spdmul)})") if battler.pokemon.willmega
    return (value.to_f * stageMul[stage] / stageDiv[stage]).floor
  end

  #=============================================================================
  # Get a better move's base damage value
  #=============================================================================
  def pbMoveBaseDamage(move, user, target, skill)
    baseDmg = move.baseDamage
    # Covers all function codes which have their own def pbBaseDamage
    case move.function
    # Sonic Boom, Dragon Rage, Super Fang, Night Shade, Endeavor
    when "FixedDamage20", "FixedDamage40", "FixedDamageHalfTargetHP",
         "FixedDamageUserLevel", "LowerTargetHPToUserHP"
      baseDmg = move.pbFixedDamage(user, target)
    when "FixedDamageUserLevelRandom"   # Psywave
      baseDmg = user.level
    when "OHKO", "OHKOIce", "OHKOHitsUndergroundTarget"
      baseDmg = 200
    when "CounterPhysicalDamage", "CounterSpecialDamage", "CounterDamagePlusHalf"
      baseDmg = 60
    when "DoublePowerIfTargetUnderwater", "DoublePowerIfTargetUnderground",
         "BindTargetDoublePowerIfTargetUnderwater"
      baseDmg = move.pbModifyDamage(baseDmg, user, target)
    # Gust, Twister, Venoshock, Smelling Salts, Wake-Up Slap, Facade, Hex, Brine,
    # Retaliate, Weather Ball, Return, Frustration, Eruption, Crush Grip,
    # Stored Power, Punishment, Hidden Power, Fury Cutter, Echoed Voice,
    # Trump Card, Flail, Electro Ball, Low Kick, Fling, Spit Up
    when "DoublePowerIfTargetInSky",
         "FlinchTargetDoublePowerIfTargetInSky",
         "DoublePowerIfTargetPoisoned",
         "DoublePowerIfTargetParalyzedCureTarget",
         "DoublePowerIfTargetAsleepCureTarget",
         "DoublePowerIfUserPoisonedBurnedParalyzed",
         "DoublePowerIfTargetStatusProblem",
         "DoublePowerIfTargetHPLessThanHalf",
         "DoublePowerIfAllyFaintedLastTurn",
         "TypeAndPowerDependOnWeather",
         "PowerHigherWithUserHappiness",
         "PowerLowerWithUserHappiness",
         "PowerHigherWithUserHP",
         "PowerHigherWithTargetHP",
         "PowerHigherWithUserPositiveStatStages",
         "PowerHigherWithTargetPositiveStatStages",
         "TypeDependsOnUserIVs",
         "PowerHigherWithConsecutiveUse",
         "PowerHigherWithConsecutiveUseOnUserSide",
         "PowerHigherWithLessPP",
         "PowerLowerWithUserHP",
         "PowerHigherWithUserFasterThanTarget",
         "PowerHigherWithTargetWeight",
         "ThrowUserItemAtTarget",
         "PowerDependsOnUserStockpile"
      baseDmg = move.pbBaseDamage(baseDmg, user, target)
    when "DoublePowerIfUserHasNoItem"   # Acrobatics
      baseDmg *= 2 if !user.item || user.hasActiveItem?(:FLYINGGEM)
    when "PowerHigherWithTargetFasterThanUser"   # Gyro Ball
      targetSpeed = pbRoughStat(target, :SPEED, skill)
      userSpeed = pbRoughStat(user, :SPEED, skill)
      baseDmg = [[(25 * targetSpeed / userSpeed).floor, 150].min, 1].max
    when "RandomlyDamageOrHealTarget"   # Present
      baseDmg = 50
    when "RandomPowerDoublePowerIfTargetUnderground"   # Magnitude
      # Average damage dealt for each stage
      case user.level
        when 0..16
          baseDmg = 39
        when 17..24
          baseDmg = 50
        when 25..33
          baseDmg = 67
        when 34..44
          baseDmg = 77
        else
          baseDmg = 91
      end
      baseDmg *= 2 if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground")   # Dig
    when "TypeAndPowerDependOnUserBerry"   # Natural Gift
      baseDmg = move.pbNaturalGiftBaseDamage(user.item_id)
    when "PowerHigherWithUserHeavierThanTarget"   # Heavy Slam
      baseDmg = move.pbBaseDamage(baseDmg, user, target)
      baseDmg *= 2 if Settings::MECHANICS_GENERATION >= 7 && skill >= PBTrainerAI.mediumSkill &&
                      target.effects[PBEffects::Minimize]
    when "AlwaysCriticalHit", "HitTwoTimes", "HitTwoTimesPoisonTarget", "HitTwoTimesReload"   # Frost Breath, Double Kick, Twineedle
      baseDmg *= 2
    when "HitThreeTimesPowersUpWithEachHit"   # Triple Kick
      baseDmg *= 6   # Hits do x1, x2, x3 baseDmg in turn, for x6 in total
    when "HitTwoToFiveTimes", "HitThreeToFiveTimes"   # Fury Attack
      if user.hasActiveAbility?(:SKILLLINK)
        baseDmg *= 5
      else
        baseDmg = (baseDmg * 3.45).floor   # Average damage dealt
      end
    when "HitTwoToFiveTimesOrThreeForAshGreninja"
      if user.isSpecies?(:GRENINJA) && user.form == 2
        baseDmg *= 4   # 3 hits at 20 power = 4 hits at 15 power
      elsif user.hasActiveAbility?(:SKILLLINK)
        baseDmg *= 5
      else
        baseDmg = (baseDmg * 3.45).floor   # Average damage dealt
      end
    when "HitOncePerUserTeamMember"   # Beat Up
      # DemICE beat-up was being calculated very wrong.
			beatUpList = []
			@battle.eachInTeamFromBattlerIndex(user.index) do |pkmn,i|
				next if !pkmn.able? || pkmn.status != :NONE
				beatUpList.push(i)
			end
			baseDmg=0
			for i in beatUpList
				atk = @battle.pbParty(user.index)[i].baseStats[:ATTACK]
				baseDmg+= 5+(atk/10)
			end
    when "TwoTurnAttackOneTurnInSun"   # Solar Beam
      baseDmg = move.pbBaseDamageMultiplier(baseDmg, user, target)
    when "MultiTurnAttackPowersUpEachTurn"   # Rollout
      baseDmg *= 2 if user.effects[PBEffects::DefenseCurl]
    when "MultiTurnAttackBideThenReturnDoubleDamage"   # Bide
      baseDmg = 40
    when "UserFaintsFixedDamageUserHP"   # Final Gambit
      baseDmg = user.hp
    when "EffectivenessIncludesFlyingType"   # Flying Press
      if GameData::Type.exists?(:FLYING)
        if skill >= PBTrainerAI.highSkill
          targetTypes = target.pbTypes(true, true)
          mult = Effectiveness.calculate(
            :FLYING, targetTypes[0], targetTypes[1], targetTypes[2]
          )
        else
          mult = Effectiveness.calculate(
            :FLYING, target.types[0], target.types[1], target.effects[PBEffects::Type3]
          )
        end
        baseDmg = (baseDmg.to_f * mult / Effectiveness::NORMAL_EFFECTIVE).round
      end
      baseDmg *= 2 if skill >= PBTrainerAI.mediumSkill && target.effects[PBEffects::Minimize]
    when "DoublePowerIfUserLastMoveFailed"   # Stomping Tantrum
      baseDmg *= 2 if user.lastRoundMoveFailed
    when "HitTwoTimesFlinchTarget"   # Double Iron Bash
      baseDmg *= 2
      baseDmg *= 2 if skill >= PBTrainerAI.mediumSkill && target.effects[PBEffects::Minimize]
		when "HigherDamageInRain" #by low
			baseDmg *= 2.25 if user.effectiveWeather == :Rain
			# yeah this move is doing 0 damage under heavy rain cuz fire type, but i aint the one "fixing" that
		when "DoubleDamageIfTargetHasChoiceItem" #by low
			if !target.unlosableItem?(target.item) && [:CHOICEBAND, :CHOICESPECS, :CHOICESCARF].include?(target.item)
				baseDmg *= 2
			end
		when "HigherDamageInSunVSNonFireTypes"
			scald_damage_multiplier = (@battle.field.abilityWeather) ? 1.5 : 2
			baseDmg *= scald_damage_multiplier if user.effectiveWeather == :Sun && !target.pbHasType?(:FIRE, true)
    end
    baseDmg = 60 if baseDmg == 1
    return baseDmg
  end

	#=============================================================================
  # Accuracy calculation
  #=============================================================================
  def pbRoughAccuracy(move, user, target, skill)
    # "Always hit" effects and "always hit" accuracy
    if skill >= PBTrainerAI.mediumSkill
      return 125 if target.effects[PBEffects::Minimize] && move.tramplesMinimize? &&
                    Settings::MECHANICS_GENERATION >= 6
      return 125 if target.effects[PBEffects::Telekinesis] > 0
    end
    baseAcc = move.accuracy
    if skill >= PBTrainerAI.highSkill
      baseAcc = move.pbBaseAccuracy(user, target)
    end
    return 125 if baseAcc == 0 && skill >= PBTrainerAI.mediumSkill
    # Get the move's type
    type = pbRoughType(move, user, skill)
    # Calculate all modifier effects
    modifiers = {}
    modifiers[:base_accuracy]  = baseAcc
    # acc and evasion murder / sleep moves acc buff #by low
    modifiers[:base_accuracy]  = 85 if !user.pbOwnedByPlayer? && [:HYPNOSIS, :GRASSWHISTLE, :LOVELYKISS, :SING, :DARKVOID].include?(move.id)
    modifiers[:accuracy_stage] = user.stages[:ACCURACY]
    modifiers[:evasion_stage]  = target.stages[:EVASION]
    if user.stages[:ACCURACY] < 0
      case $game_variables[MECHANICSVAR]
      when 2, 3
        modifiers[:accuracy_stage] = 0
      else
        modifiers[:accuracy_stage] += 1 if !user.pbOwnedByPlayer? 
      end
    end
    modifiers[:evasion_stage]  = 0 if target.stages[:EVASION] > 0
    modifiers[:accuracy_multiplier] = 1.0
		modifiers[:accuracy_multiplier] *= 1.15 if !user.pbOwnedByPlayer?
    modifiers[:evasion_multiplier]  = 1.0
    pbCalcAccuracyModifiers(user, target, modifiers, move, type, skill)
    # Check if move can't miss
    return 125 if modifiers[:base_accuracy] == 0
    # Calculation
    accStage = [[modifiers[:accuracy_stage], -6].max, 6].min + 6
    evaStage = [[modifiers[:evasion_stage], -6].max, 6].min + 6
    accStage = 6 if accStage < 6
    evaStage = 6 if evaStage > 6
    stageMul = [3, 3, 3, 3, 3, 3, 3, 4, 5, 6, 7, 8, 9]
    stageDiv = [9, 8, 7, 6, 5, 4, 3, 3, 3, 3, 3, 3, 3]
    accuracy = 100.0 * stageMul[accStage] / stageDiv[accStage]
    evasion  = 100.0 * stageMul[evaStage] / stageDiv[evaStage]
    accuracy = (accuracy * modifiers[:accuracy_multiplier]).round
    evasion  = (evasion  * modifiers[:evasion_multiplier]).round
    evasion = 1 if evasion < 1
    return modifiers[:base_accuracy] * accuracy / evasion
  end

  def pbCalcAccuracyModifiers(user, target, modifiers, move, type, skill)
    moldBreaker = moldbroken(user,target,move) # updated to take in the better mold breaker check
    # Ability effects that alter accuracy calculation
    if skill >= PBTrainerAI.mediumSkill
      if user.abilityActive?
        Battle::AbilityEffects.triggerAccuracyCalcFromUser(
          user.ability, modifiers, user, target, move, type
        )
        modifiers[:accuracy_multiplier] *= 1.3 if user.isSpecies?(:FLYGON) && user.willmega
      end
      user.allAllies.each do |b|
        next if !b.abilityActive?
        Battle::AbilityEffects.triggerAccuracyCalcFromAlly(
          b.ability, modifiers, user, target, move, type
        )
      end
    end
    if skill >= PBTrainerAI.bestSkill && target.abilityActive? && !moldBreaker
      Battle::AbilityEffects.triggerAccuracyCalcFromTarget(
        target.ability, modifiers, user, target, move, type
      )
    end
    # Item effects that alter accuracy calculation
    if skill >= PBTrainerAI.mediumSkill && user.itemActive?
      Battle::ItemEffects.triggerAccuracyCalcFromUser(
        user.item, modifiers, user, target, move, type
      )
    end
    if skill >= PBTrainerAI.bestSkill && target.itemActive?
      Battle::ItemEffects.triggerAccuracyCalcFromTarget(
        target.item, modifiers, user, target, move, type
      )
    end
    # Other effects, inc. ones that set accuracy_multiplier or evasion_stage to specific values
    if skill >= PBTrainerAI.mediumSkill
      # float stone changes #by low
      if @battle.field.effects[PBEffects::Gravity] > 0 && !target.hasActiveItem?(:FLOATSTONE)
        modifiers[:accuracy_multiplier] *= 5 / 3.0
      end
      if user.effects[PBEffects::MicleBerry]
        modifiers[:accuracy_multiplier] *= 1.2
      end
      modifiers[:evasion_stage] = 0 if target.effects[PBEffects::Foresight] && modifiers[:evasion_stage] > 0
      modifiers[:evasion_stage] = 0 if target.effects[PBEffects::MiracleEye] && modifiers[:evasion_stage] > 0
    end
    # "AI-specific calculations below"
    if skill >= PBTrainerAI.mediumSkill
      modifiers[:evasion_stage] = 0 if move.function == "IgnoreTargetDefSpDefEvaStatStages"   # Chip Away
      modifiers[:base_accuracy] = 0 if user.effects[PBEffects::LockOn] > 0 &&
                                       user.effects[PBEffects::LockOnPos] == target.index
    end
    if skill >= PBTrainerAI.highSkill
      if move.function == "BadPoisonTarget" &&   # Toxic
         (Settings::MORE_TYPE_EFFECTS && !$game_switches[OLDSCHOOLBATTLE]) && move.statusMove? && user.pbHasType?(:POISON, true)
        modifiers[:base_accuracy] = 0
      end
      if ["OHKO", "OHKOIce", "OHKOHitsUndergroundTarget"].include?(move.function)
        modifiers[:base_accuracy] = move.accuracy + user.level - target.level
        modifiers[:accuracy_multiplier] = 0 if target.level >= user.level
        if skill >= PBTrainerAI.bestSkill && target.hasActiveAbility?(:STURDY)
          modifiers[:accuracy_multiplier] = 0
        end
      end
    end
  end
end
