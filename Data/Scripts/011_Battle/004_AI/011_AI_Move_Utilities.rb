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
  def pbCheckMoveImmunity(score, move, user, target, skill)
    type = pbRoughType(move, user, skill)
    typeMod = pbCalcTypeMod(type, user, target)
    # Type effectiveness
    return true if (move.damagingMove? && Effectiveness.ineffective?(typeMod)) || score <= 0
		#~ theresone=false
		#~ @battle.allBattlers.each do |j|
			#~ if (j.isSpecies?(:BEHEEYEM) && j.item == :BEHEEYEMITE && j.willmega && target.affectedByTerrain?)
				#~ theresone=true
			#~ end
		#~ end
    # Immunity due to ability/item/other effects
    if skill >= PBTrainerAI.mediumSkill
      case type
      when :GROUND
        return true if target.airborne? && !move.hitsFlyingTargets?
      when :FIRE
        return true if target.hasActiveAbility?(:FLASHFIRE)
      when :WATER
        return true if target.hasActiveAbility?([:DRYSKIN, :STORMDRAIN, :WATERABSORB])
      when :GRASS
        return true if target.hasActiveAbility?(:SAPSIPPER)
      when :ELECTRIC
        return true if target.hasActiveAbility?([:LIGHTNINGROD, :MOTORDRIVE, :VOLTABSORB])
      end
      return true if move.damagingMove? && Effectiveness.not_very_effective?(typeMod) &&
                     target.hasActiveAbility?(:WONDERGUARD)
      return true if move.damagingMove? && user.index != target.index && !target.opposes?(user) &&
                     target.hasActiveAbility?(:TELEPATHY)
      return true if move.statusMove? && move.canMagicCoat? && target.hasActiveAbility?(:MAGICBOUNCE) &&
                     target.opposes?(user)
      return true if move.soundMove? && target.hasActiveAbility?(:SOUNDPROOF)
      return true if move.bombMove? && target.hasActiveAbility?(:BULLETPROOF)
      if move.powderMove?
        return true if target.pbHasType?(:GRASS, true)
        return true if target.hasActiveAbility?(:OVERCOAT)
        return true if target.hasActiveItem?(:SAFETYGOGGLES)
      end
      return true if move.statusMove? && target.effects[PBEffects::Substitute] > 0 &&
                     !move.ignoresSubstitute?(user) && user.index != target.index
      return true if move.statusMove? && Settings::MECHANICS_GENERATION >= 7 &&
                     user.hasActiveAbility?(:PRANKSTER) && target.pbHasType?(:DARK, true) &&
                     target.opposes?(user)
      return true if move.priority > 0 && (@battle.field.terrain == :Psychic) &&
                     target.affectedByTerrain? && target.opposes?(user)
    end
    return false
  end

  #=============================================================================
  # Get approximate properties for a battler
  #=============================================================================
  def pbRoughType(move, user, skill)
    ret = move.type
    if skill >= PBTrainerAI.highSkill
      ret = move.pbCalcType(user)
    end
    return ret
  end

  def pbRoughStat(battler, stat, skill)
		# WillMega / Mid-turn mega stat calculation #by low
		atkmul=defmul=spemul=spamul=spdmul=1
		if battler.pokemon.willmega
			# Gen 1
			if battler.isSpecies?(:GYARADOS) && battler.form == 0 && # special stuff for only kanto trash
				 (battler.item == :GYARADOSITE || battler.hasMegaEvoMutation?)
				atkmul=1.24
				defmul=1.38
				spemul=1
				spamul=1.166
				spdmul=1.3
			# Gen 2
			elsif battler.isSpecies?(:AMPHAROS) && 
				 (battler.item == :AMPHAROSITE || battler.hasMegaEvoMutation?)
				atkmul=1
				defmul=1.352
				spemul=0.909
				spamul=1.434
				spdmul=1.333
			elsif battler.isSpecies?(:XATU) && 
				 (battler.item == :XATUNITE || battler.hasMegaEvoMutation?)
				atkmul=1.187
				defmul=1.015
				spemul=1.011
				spamul=1.295
				spdmul=1.8
			elsif battler.isSpecies?(:SKARMORY) && 
				 (battler.item == :SKARMORITE || battler.hasMegaEvoMutation?)
				atkmul=1.5
				defmul=1.143
				spemul=1.143
				spamul=1.5
				spdmul=1.143
			# Gen 3
			elsif battler.isSpecies?(:SABLEYE) && 
				 (battler.item == :SABLEYEITE || battler.hasMegaEvoMutation?)
				atkmul=1
				defmul=1.665
				spemul=0.4
				spamul=1
				spdmul=1.769
			elsif battler.isSpecies?(:FLYGON) && 
				 (battler.item == :FLYGONITE || battler.hasMegaEvoMutation?)
				atkmul=1.3
				defmul=1
				spemul=1.2
				spamul=1.625
				spdmul=1
			elsif battler.isSpecies?(:MILOTIC) && 
				 (battler.item == :MILOTITE || battler.hasMegaEvoMutation?)
				atkmul=1.417
				defmul=1.216
				spemul=1.013
				spamul=1.26
				spdmul=1.248
			# Gen Mazah
			elsif battler.isSpecies?(:NOCTAVISPA) && 
				 (battler.item == :NOCTAVISPITE || battler.hasMegaEvoMutation?)
				atkmul=1.538
				defmul=1.052
				spemul=1.184
				spamul=1.329
				spdmul=1.19
			elsif battler.isSpecies?(:GOHILA) && 
				 (battler.item == :GOHILITE || battler.hasMegaEvoMutation?)
				atkmul=1.304
				defmul=1.029
				spemul=1.021
				spamul=1.5
				spdmul=1.493
			elsif battler.isSpecies?(:ATELANGLER) && 
				 (battler.item == :ATELANGLITE || battler.hasMegaEvoMutation?)
				atkmul=1.538
				defmul=1.248
				spemul=1.08
				spamul=1.38
				spdmul=1.12
			elsif battler.isSpecies?(:CHIXULOB) && 
				 (battler.item == :CHIXULITE || battler.hasMegaEvoMutation?)
				atkmul=1.269
				defmul=1.883
				spemul=1.148
				spamul=0.928
				spdmul=1.393
			elsif battler.isSpecies?(:SUCHOBILE) && 
				 (battler.item == :SUCHOBITE || battler.hasMegaEvoMutation?)
				atkmul=1.184
				defmul=1.587
				spemul=0.746
				spamul=1.248
				spdmul=1.386
			# 05/09/2023 Update
			elsif battler.isSpecies?(:BEHEEYEM) && 
				 (battler.item == :BEHEEYEMITE || battler.hasMegaEvoMutation?)
				atkmul=1.400
				defmul=1.000
				spemul=1.750
				spamul=1.080
				spdmul=1.316
			elsif battler.isSpecies?(:GOLURK) && 
				 (battler.item == :GOLURKITE || battler.hasMegaEvoMutation?)
				atkmul=1.161
				defmul=1.313
				spemul=1.818
				spamul=1.182
				spdmul=1.000
			elsif battler.isSpecies?(:HAWLUCHA) && 
				 (battler.item == :HAWLUCHITE || battler.hasMegaEvoMutation?)
				atkmul=1.435
				defmul=1.267
				spemul=1.000
				spamul=1.270
				spdmul=1.317
			elsif battler.isSpecies?(:CACTURNE) && 
				 (battler.item == :CACTURNITE || battler.hasMegaEvoMutation?)
				atkmul=1.174
				defmul=1.167
				spemul=1.727
				spamul=1.261
				spdmul=1.000
			elsif battler.isSpecies?(:FROSMOTH) && 
				 (battler.item == :FROSMOTHITE || battler.hasMegaEvoMutation?)
				atkmul=1.000
				defmul=1.333
				spemul=1.308
				spamul=1.080
				spdmul=1.556
			elsif battler.isSpecies?(:CHIMECHO) && 
				 (battler.item == :CHIMECHITE || battler.hasMegaEvoMutation?)
				atkmul=1.000
				defmul=1.250
				spemul=1.000
				spamul=1.211
				spdmul=1.667
			elsif battler.isSpecies?(:PORYGONZ) && 
				 (battler.item == :PORYGONZITE || battler.hasMegaEvoMutation?)
				atkmul=1.600
				defmul=1.143
				spemul=1.133
				spamul=1.148
				spdmul=1.133
			elsif battler.isSpecies?(:MAGCARGO) && 
				 (battler.item == :MAGCARGOITE || battler.hasMegaEvoMutation?)
				atkmul=1.200
				defmul=1.333
				spemul=1.667
				spamul=1.111
				spdmul=1.250
			elsif battler.isSpecies?(:SPECTERZAL) && 
				 (battler.item == :SPECTERZITE || battler.hasMegaEvoMutation?)
				atkmul=1.112
				defmul=2.000
				spemul=1.000
				spamul=1.118
				spdmul=1.154
			elsif battler.isSpecies?(:TREVENANT) && 
				 (battler.item == :TREVENANTITE || battler.hasMegaEvoMutation?)
				atkmul=1.167
				defmul=1.305
				spemul=0.821
				spamul=1.385
				spdmul=1.488
			elsif battler.isSpecies?(:M_ROSERADE) && 
				 (battler.item == :M_ROSERADITE || battler.hasMegaEvoMutation?)
				atkmul=1.462
				defmul=1.383
				spemul=1.022
				spamul=1.190
				spdmul=1.200
			elsif battler.isSpecies?(:LUPACABRA) && 
				 (battler.item == :LUPACABRITE || battler.hasMegaEvoMutation?)
				atkmul=1.286
				defmul=1.421
				spemul=1.182
				spamul=1.118
				spdmul=1.143
			elsif battler.isSpecies?(:ROADRAPTOR) && 
				 (battler.item == :ROADRAPTORITE || battler.hasMegaEvoMutation?)
				atkmul=1.372
				defmul=1.385
				spemul=1.000
				spamul=1.625
				spdmul=1.000
			elsif battler.isSpecies?(:FRIZZARD) && 
				 (battler.item == :FRIZZARDITE || battler.hasMegaEvoMutation?)
				atkmul=1.231
				defmul=1.133
				spemul=1.056
				spamul=1.381
				spdmul=1.330
			elsif battler.isSpecies?(:ZARCOIL) && 
				 (battler.item == :ZARCOILITE || battler.hasMegaEvoMutation?)
				atkmul=1.227
				defmul=1.290
				spemul=1.282
				spamul=1.217
				spdmul=1.133
			elsif battler.isSpecies?(:LAGUNA) && 
				 (battler.item == :LAGUNITE || battler.hasMegaEvoMutation?)
				atkmul=1.200
				defmul=1.100
				spemul=1.288
				spamul=1.571
				spdmul=1.182
			elsif battler.isSpecies?(:LEDIAN) && 
				 (battler.item == :LEDINITE || battler.hasMegaEvoMutation?)
				atkmul=1.625
				defmul=1.000
				spemul=1.471
				spamul=0.778
				spdmul=1.200
			# 14/10/2023 Update
			elsif battler.isSpecies?(:BEAKRAFT) && 
				 (battler.item == :BEAKRAFTITE || battler.hasMegaEvoMutation?)
				if battler.gender == 0 #male
					atkmul=1.211
					defmul=1.250
					spemul=1.051
					spamul=1.520
					spdmul=1.333
				end
				if battler.gender == 1 #female
					atkmul=1.167
					defmul=1.105
					spemul=1.051
					spamul=2.000
					spdmul=1.267
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
    return (value.to_f * stageMul[stage] / stageDiv[stage]).floor
  end

  #=============================================================================
  # Get a better move's base damage value
  #=============================================================================
  def pbMoveBaseDamage(move, user, target, skill)
    baseDmg = move.baseDamage
    baseDmg = 60 if baseDmg == 1
    return baseDmg if skill < PBTrainerAI.mediumSkill
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
      baseDmg = 71
      baseDmg *= 2 if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground")   # Dig
    when "TypeAndPowerDependOnUserBerry"   # Natural Gift
      baseDmg = move.pbNaturalGiftBaseDamage(user.item_id)
    when "PowerHigherWithUserHeavierThanTarget"   # Heavy Slam
      baseDmg = move.pbBaseDamage(baseDmg, user, target)
      baseDmg *= 2 if Settings::MECHANICS_GENERATION >= 7 && skill >= PBTrainerAI.mediumSkill &&
                      target.effects[PBEffects::Minimize]
    when "AlwaysCriticalHit", "HitTwoTimes", "HitTwoTimesPoisonTarget"   # Frost Breath, Double Kick, Twineedle
      baseDmg *= 2
    when "HitThreeTimesPowersUpWithEachHit"   # Triple Kick
      baseDmg *= 6   # Hits do x1, x2, x3 baseDmg in turn, for x6 in total
    when "HitTwoToFiveTimes", "HitThreeToFiveTimes"   # Fury Attack
      if user.hasActiveAbility?(:SKILLLINK)
        baseDmg *= 5
      else
        baseDmg = (baseDmg * 31 / 10).floor   # Average damage dealt
      end
    when "HitTwoToFiveTimesOrThreeForAshGreninja"
      if user.isSpecies?(:GRENINJA) && user.form == 2
        baseDmg *= 4   # 3 hits at 20 power = 4 hits at 15 power
      elsif user.hasActiveAbility?(:SKILLLINK)
        baseDmg *= 5
      else
        baseDmg = (baseDmg * 31 / 10).floor   # Average damage dealt
      end
    when "HitOncePerUserTeamMember"   # Beat Up
      mult = 0
      @battle.eachInTeamFromBattlerIndex(user.index) do |pkmn, _i|
        mult += 1 if pkmn&.able? && pkmn.status == :NONE
      end
      baseDmg *= mult
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
          targetTypes = target.pbTypes(true)
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
			baseDmg *= scald_damage_multiplier if user.effectiveWeather == :Sun && !target.pbHasType?(:FIRE)
    end
    return baseDmg
  end

  #=============================================================================
  # Damage calculation
  #=============================================================================
=begin
	def pbRoughDamage(move, user, target, skill, baseDmg)
    # Fixed damage moves
    return baseDmg if move.is_a?(Battle::Move::FixedDamageMove)
    # Get the move's type
    type = pbRoughType(move, user, skill)
    ##### Calculate user's attack stat #####
    atk = pbRoughStat(user, :ATTACK, skill)
    if move.function == "UseTargetAttackInsteadOfUserAttack"   # Foul Play
      atk = pbRoughStat(target, :ATTACK, skill)
    elsif move.function == "UseUserBaseDefenseInsteadOfUserBaseAttack"   # Body Press
      atk = pbRoughStat(user, :DEFENSE, skill)
    elsif move.function == "UseUserBaseSpecialDefenseInsteadOfUserBaseSpecialAttack"   # Psycrush
      atk = pbRoughStat(user, :SPECIAL_DEFENSE, skill)
    elsif move.specialMove?(type)
      if move.function == "UseTargetAttackInsteadOfUserAttack"   # Foul Play
        atk = pbRoughStat(target, :SPECIAL_ATTACK, skill)
      else
        atk = pbRoughStat(user, :SPECIAL_ATTACK, skill)
      end
    end
    ##### Calculate target's defense stat #####
    defense = pbRoughStat(target, :DEFENSE, skill)
    if move.specialMove?(type) && move.function != "UseTargetDefenseInsteadOfTargetSpDef"   # Psyshock
      defense = pbRoughStat(target, :SPECIAL_DEFENSE, skill)
    end
    ##### Calculate all multiplier effects #####
    multipliers = {
      :base_damage_multiplier  => 1.0,
      :attack_multiplier       => 1.0,
      :defense_multiplier      => 1.0,
      :final_damage_multiplier => 1.0
    }
    # Ability effects that alter damage
    moldBreaker = false
    if skill >= PBTrainerAI.highSkill && target.hasMoldBreaker?
      moldBreaker = true
    end
    if skill >= PBTrainerAI.mediumSkill && user.abilityActive?
      # NOTE: These abilities aren't suitable for checking at the start of the
      #       round.
      abilityBlacklist = [:ANALYTIC, :SNIPER, :TINTEDLENS, :AERILATE, :PIXILATE, :REFRIGERATE]
      canCheck = true
      abilityBlacklist.each do |m|
        next if move.id != m
        canCheck = false
        break
      end
      if canCheck
        Battle::AbilityEffects.triggerDamageCalcFromUser(
          user.ability, user, target, move, multipliers, baseDmg, type
        )
      end
    end
    if skill >= PBTrainerAI.mediumSkill && !moldBreaker
      user.allAllies.each do |b|
        next if !b.abilityActive?
        Battle::AbilityEffects.triggerDamageCalcFromAlly(
          b.ability, user, target, move, multipliers, baseDmg, type
        )
      end
    end
    if skill >= PBTrainerAI.bestSkill && !moldBreaker && target.abilityActive?
      # NOTE: These abilities aren't suitable for checking at the start of the
      #       round.
      abilityBlacklist = [:FILTER, :SOLIDROCK]
      canCheck = true
      abilityBlacklist.each do |m|
        next if move.id != m
        canCheck = false
        break
      end
      if canCheck
        Battle::AbilityEffects.triggerDamageCalcFromTarget(
          target.ability, user, target, move, multipliers, baseDmg, type
        )
      end
    end
    if skill >= PBTrainerAI.bestSkill && !moldBreaker
      target.allAllies.each do |b|
        next if !b.abilityActive?
        Battle::AbilityEffects.triggerDamageCalcFromTargetAlly(
          b.ability, user, target, move, multipliers, baseDmg, type
        )
      end
    end
    # Item effects that alter damage
    # NOTE: Type-boosting gems aren't suitable for checking at the start of the
    #       round.
    if skill >= PBTrainerAI.mediumSkill && user.itemActive?
      # NOTE: These items aren't suitable for checking at the start of the
      #       round.
      itemBlacklist = [:EXPERTBELT, :LIFEORB]
      if !itemBlacklist.include?(user.item_id)
        Battle::ItemEffects.triggerDamageCalcFromUser(
          user.item, user, target, move, multipliers, baseDmg, type
        )
        user.effects[PBEffects::GemConsumed] = nil   # Untrigger consuming of Gems
      end
    end
    if skill >= PBTrainerAI.bestSkill &&
       target.itemActive? && target.item && !target.item.is_berry?
      Battle::ItemEffects.triggerDamageCalcFromTarget(
        target.item, user, target, move, multipliers, baseDmg, type
      )
    end
    # Global abilities
    if skill >= PBTrainerAI.mediumSkill &&
       ((@battle.pbCheckGlobalAbility(:DARKAURA) && type == :DARK) ||
        (@battle.pbCheckGlobalAbility(:FAIRYAURA) && type == :FAIRY) ||
        (@battle.pbCheckGlobalAbility(:SPOOPERAURA) && type == :GHOST)) # spooper aura
      if @battle.pbCheckGlobalAbility(:AURABREAK)
        multipliers[:base_damage_multiplier] *= 2 / 3.0
      else
        multipliers[:base_damage_multiplier] *= 4 / 3.0
      end
    end
    # Parental Bond
    if skill >= PBTrainerAI.mediumSkill && user.hasActiveAbility?(:PARENTALBOND)
      multipliers[:base_damage_multiplier] *= 1.25
    end
    # Me First
    # TODO
    # Helping Hand - n/a
    # Charge
    if skill >= PBTrainerAI.mediumSkill &&
       user.effects[PBEffects::Charge] > 0 && type == :ELECTRIC
      multipliers[:base_damage_multiplier] *= 2
    end
		# Zealous Dance
    if skill >= PBTrainerAI.mediumSkill &&
       user.effects[PBEffects::ZealousDance] > 0 && type == :FIRE
      multipliers[:base_damage_multiplier] *= 1.5
    end
    # Mud Sport and Water Sport
    if skill >= PBTrainerAI.mediumSkill
      if type == :ELECTRIC
        if @battle.allBattlers.any? { |b| b.effects[PBEffects::MudSport] }
          multipliers[:base_damage_multiplier] /= 3
        end
        if @battle.field.effects[PBEffects::MudSportField] > 0
          multipliers[:base_damage_multiplier] /= 3
        end
      end
      if type == :FIRE
        if @battle.allBattlers.any? { |b| b.effects[PBEffects::WaterSport] }
          multipliers[:base_damage_multiplier] /= 3
        end
        if @battle.field.effects[PBEffects::WaterSportField] > 0
          multipliers[:base_damage_multiplier] /= 3
        end
      end
    end
    # Terrain moves
    if skill >= PBTrainerAI.mediumSkill
      case @battle.field.terrain
      when :Electric
        multipliers[:base_damage_multiplier] *= 1.5 if type == :ELECTRIC && user.affectedByTerrain?
      when :Grassy
        multipliers[:base_damage_multiplier] *= 1.5 if type == :GRASS && user.affectedByTerrain?
      when :Psychic
        multipliers[:base_damage_multiplier] *= 1.5 if type == :PSYCHIC && user.affectedByTerrain?
      when :Misty
        multipliers[:base_damage_multiplier] /= 2 if type == :DRAGON && target.affectedByTerrain?
      end
			#mastersex type zones
			multipliers[:base_damage_multiplier] *= 1.5 if @battle.field.typezone != :None && type == @battle.field.typezone
			thereselec=false
			theresmisty=false
			theresgrassy=false
			therespsychic=false
			@battle.allBattlers.each do |j|
				thereselec=true if (j.isSpecies?(:BEAKRAFT) && j.item == :BEAKRAFTITE && j.willmega && user.affectedByTerrain?)
				theresmisty=true if (j.isSpecies?(:MILOTIC) && j.item == :MILOTITE && j.willmega && target.affectedByTerrain?)
				theresgrassy=true if (j.isSpecies?(:TREVENANT) && j.item == :TREVENANTITE && j.willmega && user.affectedByTerrain?)
				therespsychic=true if (j.isSpecies?(:BEHEEYEM) && j.item == :BEHEEYEMITE && j.willmega && user.affectedByTerrain?)
			end
			multipliers[:base_damage_multiplier] *= 1.5 if type == :ELECTRIC 	&& thereselec
			multipliers[:base_damage_multiplier] /= 2.0 if type == :DRAGON 		&& theresmisty
			multipliers[:base_damage_multiplier] *= 1.5 if type == :GRASS 		&& theresgrassy
			multipliers[:base_damage_multiplier] *= 1.5 if type == :PSYCHIC 	&& therespsychic
			# Specific Field Effect Boosts
			if theresgrassy && [:EARTHQUAKE, :MAGNITUDE, :BULLDOZE].include?(move.id)
				multipliers[:base_damage_multiplier] /= 2.0
			end
    end
    # Badge multipliers
    if skill >= PBTrainerAI.highSkill && @battle.internalBattle && target.pbOwnedByPlayer?
      if move.physicalMove?(type) && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_DEFENSE
        multipliers[:defense_multiplier] *= 1.1
      elsif move.specialMove?(type) && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPDEF
        multipliers[:defense_multiplier] *= 1.1
      end
    end
    # Multi-targeting attacks
    if skill >= PBTrainerAI.highSkill && pbTargetsMultiple?(move, user)
      multipliers[:final_damage_multiplier] *= 0.75
    end
    # Weather
    if skill >= PBTrainerAI.mediumSkill
      case user.effectiveWeather
      when :Sun, :HarshSun
        case type
        when :FIRE
          multipliers[:final_damage_multiplier] *= 1.5
        when :WATER
          multipliers[:final_damage_multiplier] /= 2
        end
      when :Rain, :HeavyRain
        case type
        when :FIRE
          multipliers[:final_damage_multiplier] /= 2
        when :WATER
          multipliers[:final_damage_multiplier] *= 1.5
        end
      when :Sandstorm
        if target.pbHasType?(:ROCK, true) && move.specialMove?(type) &&
           move.function != "UseTargetDefenseInsteadOfTargetSpDef"   # Psyshock
          multipliers[:defense_multiplier] *= 1.5
        end
			when :Hail # hail buff
				if target.pbHasType?(:ICE, true) && Effectiveness.super_effective?(target.damageState.typeMod)
					multipliers[:final_damage_multiplier] *= 0.75
				end
      end
			# specific weather checks
			theressun=false
			thereswet=false
			theressad=false
			thereshal=false
			@battle.allBattlers.each do |j|
				theressun=true if (j.isSpecies?(:ZARCOIL)  && j.item == :ZARCOILITE  && j.willmega)
				thereswet=true if (j.isSpecies?(:ZOLUPINE) && j.item == :ZOLUPINEITE && j.willmega)
				theressad=true if (j.isSpecies?(:CACTURNE) && j.item == :CACTURNITE  && j.willmega)
				thereshal=true if (j.isSpecies?(:FRIZZARD) && j.item == :FRIZZARDITE && j.willmega)
			end
			if theressun # sunny day
        case type
        when :FIRE
          multipliers[:final_damage_multiplier] *= 1.5
        when :WATER
          multipliers[:final_damage_multiplier] /= 2
        end
				if move.specialMove?(type) && user.hasActiveAbility?(:SOLARPOWER)
					multipliers[:attack_multiplier] *= 1.5
				end
			end
			if thereswet # rain dance
        case type
        when :FIRE
          multipliers[:final_damage_multiplier] /= 2
        when :WATER
          multipliers[:final_damage_multiplier] *= 1.5
        end
			end
			if theressad # sandstorm
        if target.pbHasType?(:ROCK, true) && move.specialMove?(type) &&
           move.function != "UseTargetDefenseInsteadOfTargetSpDef"   # Psyshock
          multipliers[:defense_multiplier] *= 1.5
        end
			end
			if thereshal # hail
				if target.pbHasType?(:ICE, true) && Effectiveness.super_effective?(target.damageState.typeMod)
					multipliers[:final_damage_multiplier] *= 0.75
				end
			end
    end
		# Master Mode stuff
		if $game_variables[MASTERMODEVARS][28]==true && !target.pbOwnedByPlayer? && Effectiveness.super_effective?(target.damageState.typeMod)
			multipliers[:final_damage_multiplier] *= 0.75
		end
		# Gravity Boost 
		if move.boostedByGravity? && @battle.field.effects[PBEffects::Gravity] > 0
			multipliers[:base_damage_multiplier] *= 4 / 3.0
		end
    # Critical hits - n/a
    # Random variance - n/a
    # STAB
    if skill >= PBTrainerAI.mediumSkill && type && user.pbHasType?(type, true)
      if user.hasActiveAbility?(:ADAPTABILITY)
        multipliers[:final_damage_multiplier] *= 2
      else
        multipliers[:final_damage_multiplier] *= 1.5
      end
    end
    # Type effectiveness
    if skill >= PBTrainerAI.mediumSkill
      typemod = pbCalcTypeMod(type, user, target)
      multipliers[:final_damage_multiplier] *= typemod.to_f / Effectiveness::NORMAL_EFFECTIVE
    end
		damagenerf = 0.5
		damagenerf = (2 / 3.0) if $game_variables[MECHANICSVAR] >= 3
    # Burn
    if skill >= PBTrainerAI.highSkill && move.physicalMove?(type) &&
       user.status == :BURN && !user.hasActiveAbility?(:GUTS) &&
       !(Settings::MECHANICS_GENERATION >= 6 &&
         move.function == "DoublePowerIfUserPoisonedBurnedParalyzed")   # Facade
      multipliers[:final_damage_multiplier] *= damagenerf
    end
    # Frostbite
    if user.status == :FREEZE && move.specialMove?(type) && skill >= PBTrainerAI.highSkill
      multipliers[:final_damage_multiplier] *= damagenerf
    end
    # Aurora Veil, Reflect, Light Screen
    if skill >= PBTrainerAI.highSkill && !move.ignoresReflect? && !user.hasActiveAbility?(:INFILTRATOR)
      if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
        if @battle.pbSideBattlerCount(target) > 1
          multipliers[:final_damage_multiplier] *= 1.5 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 1.5
        end
      elsif target.pbOwnSide.effects[PBEffects::Reflect] > 0 && move.physicalMove?(type)
        if @battle.pbSideBattlerCount(target) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      elsif target.pbOwnSide.effects[PBEffects::LightScreen] > 0 && move.specialMove?(type)
        if @battle.pbSideBattlerCount(target) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      end
    end
    # Minimize
    if skill >= PBTrainerAI.highSkill && target.effects[PBEffects::Minimize] && move.tramplesMinimize?
      multipliers[:final_damage_multiplier] *= 2
    end
    # Move-specific base damage modifiers
    # TODO
    # Move-specific final damage modifiers
    # TODO
    ##### Main damage calculation #####
    baseDmg = [(baseDmg * multipliers[:base_damage_multiplier]).round, 1].max
    atk     = [(atk     * multipliers[:attack_multiplier]).round, 1].max
    defense = [(defense * multipliers[:defense_multiplier]).round, 1].max
    damage  = ((((2.0 * user.level / 5) + 2).floor * baseDmg * atk / defense).floor / 50).floor + 2
    damage  = [(damage * multipliers[:final_damage_multiplier]).round, 1].max
    # "AI-specific calculations below"
    # Increased critical hit rates
    if skill >= PBTrainerAI.mediumSkill
      c = 0
      # Ability effects that alter critical hit rate
      if c >= 0 && user.abilityActive?
        c = Battle::AbilityEffects.triggerCriticalCalcFromUser(user.ability, user, target, c)
      end
      if skill >= PBTrainerAI.bestSkill && c >= 0 && !moldBreaker && target.abilityActive?
        c = Battle::AbilityEffects.triggerCriticalCalcFromTarget(target.ability, user, target, c)
      end
      # Item effects that alter critical hit rate
      if c >= 0 && user.itemActive?
        c = Battle::ItemEffects.triggerCriticalCalcFromUser(user.item, user, target, c)
      end
      if skill >= PBTrainerAI.bestSkill && c >= 0 && target.itemActive?
        c = Battle::ItemEffects.triggerCriticalCalcFromTarget(target.item, user, target, c)
      end
      # Other efffects
      c = -1 if target.pbOwnSide.effects[PBEffects::LuckyChant] > 0
			c = 4 if user.effects[PBEffects::LaserFocus] > 0
      if c >= 0
        c += 1 if move.highCriticalRate?
        c += user.effects[PBEffects::FocusEnergy]
        c += 1 if user.inHyperMode? && move.type == :SHADOW
      end
      if c >= 0
        c = 4 if c > 4
        damage += damage * 0.1 * c
      end
    end
    return damage.floor
  end

=end 
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
    modifiers[:accuracy_stage] = user.stages[:ACCURACY]
    modifiers[:evasion_stage]  = target.stages[:EVASION]
    modifiers[:accuracy_multiplier] = 1.0
    modifiers[:evasion_multiplier]  = 1.0
    pbCalcAccuracyModifiers(user, target, modifiers, move, type, skill)
    # Check if move can't miss
    return 125 if modifiers[:base_accuracy] == 0
    # Calculation
    accStage = [[modifiers[:accuracy_stage], -6].max, 6].min + 6
    evaStage = [[modifiers[:evasion_stage], -6].max, 6].min + 6
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
    moldBreaker = false
    if skill >= PBTrainerAI.highSkill && target.hasMoldBreaker?
      moldBreaker = true
    end
    # Ability effects that alter accuracy calculation
    if skill >= PBTrainerAI.mediumSkill
      if user.abilityActive?
        Battle::AbilityEffects.triggerAccuracyCalcFromUser(
          user.ability, modifiers, user, target, move, type
        )
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
      if @battle.field.effects[PBEffects::Gravity] > 0
        modifiers[:accuracy_multiplier] *= 5 / 3.0
      end
      if user.effects[PBEffects::MicleBerry]
        modifiers[:accuracy_multiplier] *= 1.2
      end
      modifiers[:evasion_stage] = 0 if target.effects[PBEffects::Foresight] && modifiers[:evasion_stage] > 0
      modifiers[:evasion_stage] = 0 if target.effects[PBEffects::MiracleEye] && modifiers[:evasion_stage] > 0
    end
		modifiers[:accuracy_multiplier] *= 1.1 if !target.pbOwnedByPlayer?
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
        modifiers[:accuracy_multiplier] = 0 if target.level > user.level
        if skill >= PBTrainerAI.bestSkill && target.hasActiveAbility?(:STURDY)
          modifiers[:accuracy_multiplier] = 0
        end
      end
    end
  end
end
