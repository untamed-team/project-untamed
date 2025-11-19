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
  def pbCalcTypeModSingle(moveType, defType, user, target, move=nil)
    ret = Effectiveness.calculate_one(moveType, defType)
    if Effectiveness.ineffective_type?(moveType, defType)
      # Ring Target
      if target.hasActiveItem?(:RINGTARGET)
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE
      end
      # Foresight
      if (user.hasActiveAbility?([:SCRAPPY, :NORMALIZE]) || target.effects[PBEffects::Foresight]) &&
         defType == :GHOST
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE
      end
      # Corrosion #by low
      if (user.hasActiveAbility?(:CORROSION) ||
         (user.isSpecies?(:SUCHOBILE) && user.pokemon.willmega && $player.difficulty_mode?("chaos"))) && defType == :STEEL
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
      if (user.hasActiveAbility?(:MASSEXTINCTION) || 
         (user.isSpecies?(:CHIXULOB) && user.pokemon.willmega && user.pokemon.hasHiddenAbility? && $player.difficulty_mode?("chaos"))) && 
         defType == :DRAGON
        ret = Effectiveness::SUPER_EFFECTIVE_ONE
      end
    end
    # Grounded Flying-type Pokémon become susceptible to Ground moves
    if !target.airborne? && defType == :FLYING && moveType == :GROUND
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE
    end
    # Freeze-Dry / Kinetic Rend
    if move
      if (move.function == "FreezeTargetSuperEffectiveAgainstWater" && defType == :WATER) ||
         (move.function == "SuperEffectiveAgainstSteel" && defType == :STEEL)
        ret = Effectiveness::SUPER_EFFECTIVE_ONE
      end
    end
    # Special interaction for color change + protean ability combo
    if target.hasActiveAbility?([:PROTEAN, :LIBERO]) && !target.pbOwnedByPlayer? &&
       target.hasActiveAbility?(:COLORCHANGE) && target.hasAbilityMutation?
      ret = Effectiveness::NOT_VERY_EFFECTIVE_ONE
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if moveType == :QMARKS
    end
    return ret
  end

  def pbCalcTypeMod(moveType, user, target, move=nil)
    return Effectiveness::NORMAL_EFFECTIVE if !moveType
    return Effectiveness::NORMAL_EFFECTIVE if moveType == :GROUND &&
                                              hasTypeAI?(:FLYING, target, user, 100) &&
                                              target.hasActiveItem?(:IRONBALL)
    # Determine types
    tTypes = typesAI(target, user, 100)
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
        typeMods[i] = pbCalcTypeModSingle(moveType, type, user, target, move)
      end
    end
    # Multiply all effectivenesses together
    ret = 1
    typeMods.each { |m| ret *= m }
    ret *= 2 if target.effects[PBEffects::TarShot] && moveType == :FIRE
    ret = 16 if target.effects[PBEffects::SuperEffEye] > 0
    # Inverse Battle Switch #by low
    # 8x = ret 64; 4x = ret 32
    if @battle.inverseBattle
      if ret == 0
        ret = 16
      elsif ret >= 64
        ret = 0
      else
        ret = (64 / ret)
      end
    end
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
    ret = move.pbCalcType(user)
    # WillMega / Mid-turn mega move type calcuation
    if user.pokemon.willmega
      if move.type == :NORMAL # -ate / -ize abilities
        if user.isSpecies?(:HAWLUCHA) && $player.difficulty_mode?("chaos") && !user.pokemon.hasHiddenAbility?
          ret = :ELECTRIC
        elsif user.isSpecies?(:GOLURK) && !$player.difficulty_mode?("chaos")
          ret = :FLYING
        elsif user.isSpecies?(:GLALIE)
          ret = :ICE
        elsif user.isSpecies?(:ALTARIA)
          ret = :FAIRY
        end
      end
    end
    # only need the globalarray here since pbCalcType should get the type in the normal way
    if ["TypeAndPowerDependOnWeather", "TypeAndPowerDependOnTerrain"].include?(move.function)
      globalArray = @megaGlobalArray
      if move.function == "TypeAndPowerDependOnWeather"
        if !user.hasActiveItem?(:UTILITYUMBRELLA)
          ret = :FIRE  if globalArray.include?("sun weather")
          ret = :WATER if globalArray.include?("rain weather")
        end
        ret = :ICE   if globalArray.include?("sand weather")
        ret = :ROCK  if globalArray.include?("hail weather")
      elsif move.function == "TypeAndPowerDependOnTerrain" && user.affectedByTerrain?
        ret = :ELECTRIC if globalArray.include?("electric terrain")
        ret = :GRASS    if globalArray.include?("grassy terrain")
        ret = :FAIRY    if globalArray.include?("misty terrain")
        ret = :PSYCHIC  if globalArray.include?("psychic terrain")
      end
    end
    # electrify logic
    user.eachOpposing do |b|
      if targetWillMove?(b, "status")
        targetIntent = @battle.choices[b.index]
        targetMove = targetIntent[2]
        targetAim = targetIntent[3]
        if targetMove.function == "TargetMovesBecomeElectric" && targetAim == user.index
          thisprio = priorityAI(user, move, globalArray)
          thatprio = priorityAI(b, targetMove, globalArray)
          aspeed = pbRoughStat(user,:SPEED,skill)
          ospeed = pbRoughStat(b,:SPEED,skill)
          outsped = ((ospeed>aspeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
          outsped = true if thatprio > thisprio && thatprio != 0
          ret = :ELECTRIC if outsped
        end
      end
    end
    return ret
  end

  def pbRoughStat(battler, stat, skill=100, target=nil, move=nil, moldbroken=false, dontignorespeb=true)
    # WillMega / Mid-turn stat calcuation
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
    megaSpeed = false
    if (stat == :SPEED && dontignorespeb) && Settings::RECALCULATE_TURN_ORDER_AFTER_SPEED_CHANGES && !$game_switches[OLDSCHOOLBATTLE]
      globalArray = @megaGlobalArray
      if globalArray.any? { |element| element.match?(/terrain|weather/) }
        megaSpeed = true
        weatherSpeed_hash = {
          "rain weather" => :SWIFTSWIM,
          "sun weather"  => :CHLOROPHYLL,
          "hail weather" => :SLUSHRUSH,
          "sand weather" => :SANDRUSH,
          "electric terrain" => :SURGESURFER
        }
        weatherSpeed_hash.each do |weather, abil|
          next unless globalArray.include?(weather)
          spemul*=2 if battler.ability == abil && battler.abilityActive?
        end
      end
    end
    # i am so fucking retarded
    return (battler.pbSpeed(megaSpeed)*spemul).floor if stat == :SPEED
    stageMul, stageDiv = @battle.pbGetStatMath
    stage = battler.stages[stat] + 6
    value = 0
    case stat
    when :ATTACK
      value = battler.attack*atkmul
      if target
        return value if target.hasActiveAbility?(:UNAWARE,false,moldbroken)
      end
    when :DEFENSE
      value = battler.defense*defmul
      if target
        return value if target.hasActiveAbility?(:UNAWARE,false,moldbroken) || 
                        move.function == "IgnoreTargetDefSpDefEvaStatStages"
      end
    when :SPEED
      value = battler.speed*spemul
    when :SPECIAL_ATTACK
      value = battler.spatk*spamul
      if target
        return value if target.hasActiveAbility?(:UNAWARE,false,moldbroken)
      end
    when :SPECIAL_DEFENSE
      value = battler.spdef*spdmul
      if target
        return value if target.hasActiveAbility?(:UNAWARE,false,moldbroken) || 
                        move.function == "IgnoreTargetDefSpDefEvaStatStages"
      end
    end
    return (value.to_f * stageMul[stage] / stageDiv[stage]).floor
  end

  #=============================================================================
  # Get a better move's base damage value
  # so much shit was missing from here what the fuck
  #=============================================================================
  def pbMoveBaseDamage(move, user, target, skill)
    globalArray = @megaGlobalArray
    procGlobalArray = processGlobalArray(globalArray)
    expectedWeather = procGlobalArray[0]
    expectedTerrain = procGlobalArray[1]
    baseDmg = move.baseDamage
    # Covers all function codes which have their own def pbBaseDamage
    case move.function
    # Sonic Boom, Dragon Rage, Super Fang, Night Shade, Endeavor
    when "FixedDamage20", "FixedDamage40", "FixedDamageHalfTargetHP",
         "FixedDamageUserLevel", "LowerTargetHPToUserHP"
      baseDmg = move.pbFixedDamage(user, target)
    when "FixedDamageUserLevelRandom"   # Psywave
      baseDmg = (user.level * 3 / 2).floor
    when "OHKO", "OHKOIce", "OHKOHitsUndergroundTarget"
      baseDmg = 200
    when "CounterPhysicalDamage", "CounterSpecialDamage", "CounterDamagePlusHalf"
      baseDmg = 5
      if (move.function == "CounterPhysicalDamage" && targetWillMove?(target, "phys")) ||
         (move.function == "CounterSpecialDamage"  && targetWillMove?(target, "spec")) ||
         (move.function == "CounterDamagePlusHalf" && targetWillMove?(target, "dmg"))
        targetMove = @battle.choices[target.index][2]
        if targetSurvivesMove(targetMove,target,user)
          baseDmg = pbRoughDamage(targetMove,target,user,skill,targetMove.baseDamage)
          baseDmg *= 2.0 if ["CounterPhysicalDamage","CounterSpecialDamage"].include?(move.function)
          if move.function == "CounterDamagePlusHalf"
            baseDmg *= 1.5
            aspeed = pbRoughStat(user,:SPEED,skill)
            ospeed = pbRoughStat(target,:SPEED,skill)
            fasterFoe = ((ospeed>aspeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) || priorityAI(target, targetMove, globalArray) > 0
            baseDmg = 1 if !fasterFoe
          end
        end
      end
    when "DoublePowerIfTargetUnderwater",
         "BindTargetDoublePowerIfTargetUnderwater"
      baseDmg = move.pbModifyDamage(baseDmg, user, target)
    # Gust, Twister, Venoshock, Smelling Salts, Wake-Up Slap, Facade, Hex, Brine,
    # Retaliate, Weather Ball, Return, Frustration, Eruption, Crush Grip,
    # Stored Power, Punishment, Hidden Power, Trump Card, Flail, Electro Ball, 
    # Low Kick, Fling, Spit Up, Future Sight / Doom Desire
    when "DoublePowerIfTargetInSky",
         "FlinchTargetDoublePowerIfTargetInSky",
         "DoublePowerIfTargetPoisoned",
         "DoublePowerIfTargetParalyzedCureTarget",
         "DoublePowerIfTargetAsleepCureTarget",
         "DoublePowerIfUserPoisonedBurnedParalyzed",
         "DoublePowerIfTargetStatusProblem",
         "DoublePowerIfTargetHPLessThanHalf",
         "DoublePowerIfAllyFaintedLastTurn",
         "PowerHigherWithUserHappiness",
         "PowerLowerWithUserHappiness",
         "PowerHigherWithUserHP",
         "PowerHigherWithTargetHP",
         "PowerHigherWithUserPositiveStatStages",
         "PowerHigherWithTargetPositiveStatStages",
         "TypeDependsOnUserIVs",
         "PowerHigherWithLessPP",
         "PowerLowerWithUserHP",
         "PowerHigherWithUserFasterThanTarget",
         "PowerHigherWithTargetWeight",
         "ThrowUserItemAtTarget",
         "PowerDependsOnUserStockpile",
         "AttackTwoTurnsLater"
      baseDmg = move.pbBaseDamage(baseDmg, user, target)
    # Fury Cutter, Echoed Voice (counter goes up before usage)
    when "PowerHigherWithConsecutiveUse",
         "PowerHigherWithConsecutiveUseOnUserSide"
      oldFury = user.effects[PBEffects::FuryCutter]
      oldEcho = user.pbOwnSide.effects[PBEffects::EchoedVoiceCounter]
      user.effects[PBEffects::FuryCutter] += 1
      user.pbOwnSide.effects[PBEffects::EchoedVoiceCounter] += 1
      baseDmg = move.pbBaseDamage(baseDmg, user, target)
      user.effects[PBEffects::FuryCutter] = oldFury
      user.pbOwnSide.effects[PBEffects::EchoedVoiceCounter] = oldEcho
    when "DoublePowerIfUserHasNoItem"   # Acrobatics
      baseDmg *= 2 if !user.item || user.hasActiveItem?(:FLYINGGEM)
    when "PowerHigherWithTargetFasterThanUser"   # Gyro Ball
      targetSpeed = pbRoughStat(target, :SPEED, skill)
      userSpeed = pbRoughStat(user, :SPEED, skill)
      baseDmg = [[(25 * targetSpeed / userSpeed).floor, 150].min, 1].max
    when "RandomlyDamageOrHealTarget"   # Present
      averagegift = [23, 37, 54, 64, 76]
      maxgift = [40, 60, 80, 100, 120]
      lvl = case user.level
        when 0..16 then 0
        when 17..24 then 1
        when 25..33 then 2
        when 34..44 then 3
        else 4
      end
      baseDmg = averagegift[lvl]
      baseDmg = maxgift[lvl] if !user.pbOwnedByPlayer?
    when "TypeAndPowerDependOnWeather"
      baseDmg *= 2 if user.effectiveWeather != :None || 
                      globalArray.any? { |element| element.include?("weather") }
    when "TypeAndPowerDependOnTerrain"
      baseDmg *= 2 if user.affectedByTerrain? && (@battle.field.terrain != :None || 
                      globalArray.any? { |element| element.include?("terrain") })
    when "HitsAllFoesAndPowersUpInPsychicTerrain"
      baseDmg *= 1.5 if expectedTerrain == :Psychic && user.affectedByTerrain?
    when "DoublePowerInElectricTerrain"
      baseDmg *= 2.0 if expectedTerrain == :Electric && target.affectedByTerrain?
    when "DoublePowerIfTargetUnderground", "RandomPowerDoublePowerIfTargetUnderground"   # Magnitude
      if move.function == "RandomPowerDoublePowerIfTargetUnderground"
        # Average damage dealt for each stage
        baseDmg = case user.level
          when 0..16 then 48
          when 17..24 then 65
          when 25..33 then 82
          when 34..44 then 94
          else 108
        end
      end
      baseDmg *= 2 if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground")   # Dig
      baseDmg /= 2 if expectedTerrain == :Grassy
    when "LowerTargetSpeed1WeakerInGrassyTerrain"
      baseDmg /= 2 if expectedTerrain == :Grassy
    when "TypeAndPowerDependOnUserBerry"   # Natural Gift
      baseDmg = move.pbNaturalGiftBaseDamage(user.item_id)
    when "PowerHigherWithUserHeavierThanTarget"   # Heavy Slam
      baseDmg = move.pbBaseDamage(baseDmg, user, target)
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
        baseDmg += 5+(atk/10)
      end
      baseDmg *= 1.5 if user.hasActiveAbility?(:TECHNICIAN)
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
        targetTypes = typesAI(target, user, skill)
        while targetTypes.length < 3
          targetTypes.push(:QMARKS)
        end
        mult = Effectiveness.calculate(
          :FLYING, targetTypes[0], targetTypes[1], targetTypes[2]
        )
        baseDmg = (baseDmg.to_f * mult / Effectiveness::NORMAL_EFFECTIVE).round
      end
    when "DoublePowerIfUserLastMoveFailed"   # Stomping Tantrum
      baseDmg *= 2 if user.lastRoundMoveFailed
    when "PursueSwitchingFoe" # Pursuit
      baseDmg *= 2 if @battle.choices[target.index][0] == :SwitchOut
    when "RemoveTargetItem" # knock off
      if !$player.difficulty_mode?("chaos")
        if target.item && !target.unlosableItem?(target.item) && !target.hasActiveAbility?(:STICKYHOLD)
          baseDmg *= 1.5
        end
      end
    when "DoublePowerIfTargetNotActed" # Fishious Rend / Bolt Beak
      aspeed = pbRoughStat(user,:SPEED,skill)
      ospeed = pbRoughStat(target,:SPEED,skill)
      fasterAtk = ((aspeed>=ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
      if targetWillMove?(target) && fasterAtk
        targetMove = @battle.choices[target.index][2]
        thisprio = priorityAI(user, move, globalArray)
        thatprio = priorityAI(target, targetMove, globalArray)
        fasterAtk = (thisprio >= thatprio) ? true : false if thatprio != 0
      end
      if @battle.choices[target.index][0] == :SwitchOut || fasterAtk
        baseDmg *= 2
      end
    when "HigherDamageInRain" # move i dont give 2 shits about is not properly implemented, wowie
      baseDmg *= 2.25 if user.effectiveWeather == :Rain
    #by low
    when "DoubleDamageIfTargetHasChoiceItem" # unused
      if !target.unlosableItem?(target.item) && [:CHOICEBAND, :CHOICESPECS, :CHOICESCARF].include?(target.item)
        baseDmg *= 2
      end
    when "PeperSpray"
      peper_dmg_mult = (@battle.field.abilityWeather) ? (5 / 4.0) : (4 / 3.0)
      baseDmg *= peper_dmg_mult if [:Sun, :HarshSun].include?(expectedWeather) && !user.hasActiveItem?(:UTILITYUMBRELLA)
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
      procGlobalArray = processGlobalArray(@megaGlobalArray)
      expectedWeather = procGlobalArray[0]
      sage = false
      if ["ParalyzeTargetAlwaysHitsInRainHitsTargetInSky",
          "ConfuseTargetAlwaysHitsInRainHitsTargetInSky",
          "FreezeTargetAlwaysHitsInHail"].include?(move.function) &&
          expectedWeather != @battle.pbWeather
        case move.function
        when "ParalyzeTargetAlwaysHitsInRainHitsTargetInSky",
             "ConfuseTargetAlwaysHitsInRainHitsTargetInSky"
          if !target.hasActiveItem?(:UTILITYUMBRELLA)
            sage = true  if [:Rain, :HeavyRain].include?(expectedWeather)
            baseAcc = 50 if [:Sun, :HarshSun].include?(expectedWeather)
          end
        when "FreezeTargetAlwaysHitsInHail"
          sage = true if expectedWeather == :Hail
        end
      end
      sage = true if user.hasActiveAbility?(:PRESAGE)
      baseAcc = 0 if sage
    end
    return 125 if baseAcc == 0 && skill >= PBTrainerAI.mediumSkill
    # Get the move's type
    type = pbRoughType(move, user, skill)
    # Calculate all modifier effects
    modifiers = {}
    modifiers[:base_accuracy]  = baseAcc
    # acc and evasion murder / sleep moves acc buff #by low
    modifiers[:base_accuracy]  = 85 if !user.pbOwnedByPlayer? && [:HYPNOSIS, :GRASSWHISTLE, :SLEEPPOWDER, :LOVELYKISS, :SING, :DARKVOID].include?(move.id)
    modifiers[:accuracy_stage] = user.stages[:ACCURACY]
    modifiers[:evasion_stage]  = [target.stages[:EVASION], 0].min
    if modifiers[:accuracy_stage] < 0
      if $player.difficulty_mode?("hard")
        modifiers[:accuracy_stage] = 0
      else 
        modifiers[:accuracy_stage] += 1 if !user.pbOwnedByPlayer?
      end
    end
    modifiers[:accuracy_multiplier] = 1.0
    modifiers[:evasion_multiplier]  = 1.0
    pbCalcAccuracyModifiers(user, target, modifiers, move, type, skill)
    minAcc = (user.hasActiveAbility?(:HUSTLE)) ? 0.8 : 1.0
    modifiers[:accuracy_multiplier] = [modifiers[:accuracy_multiplier], minAcc].max
    modifiers[:evasion_multiplier]  = [modifiers[:evasion_multiplier], 1.0].min
    # Check if move can't miss
    return 125 if modifiers[:base_accuracy] == 0
    # Calculation
    accStage = [[modifiers[:accuracy_stage], -6].max, 6].min + 6
    evaStage = [[modifiers[:evasion_stage], -6].max, 6].min + 6
    stageMul, stageDiv = @battle.pbGetStatMath(:ACCURACY)
    accuracy = 100.0 * stageMul[accStage] / stageDiv[accStage]
    evasion  = 100.0 * stageMul[evaStage] / stageDiv[evaStage]
    accuracy = (accuracy * modifiers[:accuracy_multiplier]).round
    evasion  = (evasion  * modifiers[:evasion_multiplier]).round
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
        modifiers[:accuracy_multiplier] *= 1.3 if user.isSpecies?(:FLYGON) && user.pokemon.willmega
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
    # klutz buff #by low
    klut = user.hasActiveAbility?(:KLUTZ)
    klut = false if !$player.difficulty_mode?("chaos")
    if skill >= PBTrainerAI.bestSkill && target.itemActive? && !klut
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
         (Settings::MORE_TYPE_EFFECTS && !$game_switches[OLDSCHOOLBATTLE]) && move.statusMove? && hasTypeAI?(:POISON, user, target, skill)
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
    modifiers[:accuracy_multiplier] *= 1.15 if !user.pbOwnedByPlayer?
  end
end
