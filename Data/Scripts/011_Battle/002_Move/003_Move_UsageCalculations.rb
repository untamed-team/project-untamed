class Battle::Move
  #=============================================================================
  # Move's type calculation
  #=============================================================================
  def pbBaseType(user)
    ret = @type
    if ret && user.abilityActive?
      ret = Battle::AbilityEffects.triggerModifyMoveBaseType(user.ability, user, self, ret)
    end
    return ret
  end

  def pbCalcType(user)
    @powerBoost = false
    ret = pbBaseType(user)
    if ret && GameData::Type.exists?(:ELECTRIC)
      if @battle.field.effects[PBEffects::IonDeluge] && ret == :NORMAL
        ret = :ELECTRIC
        @powerBoost = false
      end
      if user.effects[PBEffects::Electrify]
        ret = :ELECTRIC
        @powerBoost = false
      end
    end
    return ret
  end

  #=============================================================================
  # Type effectiveness calculation
  #=============================================================================
  def pbCalcTypeModSingle(moveType, defType, user, target)
    ret = Effectiveness.calculate_one(moveType, defType)
    if Effectiveness.ineffective_type?(moveType, defType)
      # Ring Target
      if target.hasActiveItem?(:RINGTARGET)
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE
      end
      # Foresight / normalize #by low
      if (user.hasActiveAbility?([:SCRAPPY, :NORMALIZE]) || target.effects[PBEffects::Foresight]) &&
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
                                              target.pbHasType?(:FLYING) &&
                                              target.hasActiveItem?(:IRONBALL)
    # Determine types
    tTypes = target.pbTypes(true)
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
    #~ print ret
    ret = 14 if ret > 14 && !target.pbOwnedByPlayer? && $game_variables[MASTERMODEVARS][28]==true
    return ret
  end

  #=============================================================================
  # Accuracy check
  #=============================================================================
  def pbBaseAccuracy(user, target); return @accuracy; end

  # Accuracy calculations for one-hit KO moves are handled elsewhere.
  def pbAccuracyCheck(user, target)
    # "Always hit" effects and "always hit" accuracy
    return true if target.effects[PBEffects::Telekinesis] > 0
    return true if target.effects[PBEffects::Minimize] && tramplesMinimize? && Settings::MECHANICS_GENERATION >= 6
    baseAcc = pbBaseAccuracy(user, target)
    return true if baseAcc == 0
    # Calculate all multiplier effects
    modifiers = {}
    modifiers[:base_accuracy]  = baseAcc
    modifiers[:accuracy_stage] = user.stages[:ACCURACY]
    modifiers[:evasion_stage]  = [target.stages[:EVASION], 0].min
    # acc and evasion murder / sleep moves acc buff #by low
    if modifiers[:accuracy_stage] < 0
      if $player.difficulty_mode?("hard")
        modifiers[:accuracy_stage] = 0
      else 
        modifiers[:accuracy_stage] += 1 if !user.pbOwnedByPlayer?
      end
    end
    modifiers[:evasion_stage]  = 0 if target.stages[:EVASION] > 0
    modifiers[:base_accuracy] = 85 if !user.pbOwnedByPlayer? && [:HYPNOSIS, :GRASSWHISTLE, :SLEEPPOWDER, :LOVELYKISS, :SING, :DARKVOID].include?(self.id)
    modifiers[:accuracy_multiplier] = 1.0
    modifiers[:evasion_multiplier]  = 1.0
    pbCalcAccuracyModifiers(user, target, modifiers)
    minAcc = (user.hasActiveAbility?(:HUSTLE)) ? 0.8 : 1.0
    modifiers[:accuracy_multiplier] = [modifiers[:accuracy_multiplier], minAcc].max
    modifiers[:evasion_multiplier]  = [modifiers[:evasion_multiplier], 1.0].min
    # Check if move can't miss
    return true if modifiers[:base_accuracy] == 0
    # Calculation
    accStage = [[modifiers[:accuracy_stage], -6].max, 6].min + 6
    evaStage = [[modifiers[:evasion_stage], -6].max, 6].min + 6
    stageMul, stageDiv = @battle.pbGetStatMath(:ACCURACY)
    accuracy = 100.0 * stageMul[accStage] / stageDiv[accStage]
    evasion  = 100.0 * stageMul[evaStage] / stageDiv[evaStage]
    accuracy = (accuracy * modifiers[:accuracy_multiplier]).round
    evasion  = (evasion  * modifiers[:evasion_multiplier]).round
    evasion = 1 if evasion < 1
    threshold = modifiers[:base_accuracy] * accuracy / evasion
    # Calculation
    r = @battle.pbRandom(100)
    return r < threshold
  end

  def pbCalcAccuracyModifiers(user, target, modifiers)
    # Ability effects that alter accuracy calculation
    if user.abilityActive?
      Battle::AbilityEffects.triggerAccuracyCalcFromUser(
        user.ability, modifiers, user, target, self, @calcType
      )
    end
    user.allAllies.each do |b|
      next if !b.abilityActive?
      Battle::AbilityEffects.triggerAccuracyCalcFromAlly(
        b.ability, modifiers, user, target, self, @calcType
      )
    end
    if target.abilityActive? && !@battle.moldBreaker
      Battle::AbilityEffects.triggerAccuracyCalcFromTarget(
        target.ability, modifiers, user, target, self, @calcType
      )
    end
    # Item effects that alter accuracy calculation
    if user.itemActive?
      Battle::ItemEffects.triggerAccuracyCalcFromUser(
        user.item, modifiers, user, target, self, @calcType
      )
    end
    # klutz buff #by low
    klut = user.hasActiveAbility?(:KLUTZ)
    klut = false if !$player.difficulty_mode?("chaos")
    if target.itemActive? && !klut
      Battle::ItemEffects.triggerAccuracyCalcFromTarget(
        target.item, modifiers, user, target, self, @calcType
      )
    end
    # Other effects, inc. ones that set accuracy_multiplier or evasion_stage to
    # specific values
    # float stone changes #by low
    if @battle.field.effects[PBEffects::Gravity] > 0 && !target.hasActiveItem?(:FLOATSTONE)
      modifiers[:accuracy_multiplier] *= 5 / 3.0
    end
    if user.effects[PBEffects::MicleBerry]
      user.effects[PBEffects::MicleBerry] = false
      modifiers[:accuracy_multiplier] *= 1.2
    end
    modifiers[:evasion_stage] = 0 if target.effects[PBEffects::Foresight] && modifiers[:evasion_stage] > 0
    modifiers[:evasion_stage] = 0 if target.effects[PBEffects::MiracleEye] && modifiers[:evasion_stage] > 0
    modifiers[:accuracy_multiplier] *= 1.15 if !user.pbOwnedByPlayer?
  end

  #=============================================================================
  # Critical hit check
  #=============================================================================
  # Return values:
  #   -1: Never a critical hit.
  #    0: Calculate normally.
  #    1: Always a critical hit.
  def pbCritialOverride(user, target); return 0; end

  # Returns whether the move will be a critical hit.
  def pbIsCritical?(user, target, move)
    # low_utilities.rb
  end

  #=============================================================================
  # Damage calculation
  #=============================================================================
  def pbBaseDamage(baseDmg, user, target);              return baseDmg;    end
  def pbBaseDamageMultiplier(damageMult, user, target); return damageMult; end
  def pbModifyDamage(damageMult, user, target);         return damageMult; end

  def pbGetAttackStats(user, target)
    if user.hasActiveAbility?(:CRYSTALJAW) && @battle.choices[user.index][2].bitingMove? #by low
      return user.spatk, user.stages[:SPECIAL_ATTACK] + 6
    end
    if specialMove?
      return user.spatk, user.stages[:SPECIAL_ATTACK] + 6
    end
    return user.attack, user.stages[:ATTACK] + 6
  end

  def pbGetDefenseStats(user, target)
    if specialMove?
      return target.spdef, target.stages[:SPECIAL_DEFENSE] + 6
    end
    return target.defense, target.stages[:DEFENSE] + 6
  end

  def pbCalcDamage(user, target, numTargets = 1)
    return if statusMove?
    if target.damageState.disguise || target.damageState.iceFace
      target.damageState.calcDamage = 1
      return
    end
    stageMul, stageDiv = @battle.pbGetStatMath
    # Get the move's type
    type = @calcType   # nil is treated as physical
    # Calculate whether this hit deals critical damage
    target.damageState.critical = pbIsCritical?(user, target, @battle.choices[user.index][2])
    # Calcuate base power of move
    baseDmg = pbBaseDamage(@baseDamage, user, target)
    # Calculate user's attack stat
    atk, atkStage = pbGetAttackStats(user, target)
    if !target.hasActiveAbility?(:UNAWARE) || @battle.moldBreaker
      atkStage = 6 if target.damageState.critical && atkStage < 6
      atk = (atk.to_f * stageMul[atkStage] / stageDiv[atkStage]).floor
    end
    # Calculate target's defense stat
    defense, defStage = pbGetDefenseStats(user, target)
    if !user.hasActiveAbility?(:UNAWARE)
      defStage = 6 if target.damageState.critical && defStage > 6
      defense = (defense.to_f * stageMul[defStage] / stageDiv[defStage]).floor
    end
    # Calculate all multiplier effects
    multipliers = {
      :base_damage_multiplier  => 1.0,
      :attack_multiplier       => 1.0,
      :defense_multiplier      => 1.0,
      :final_damage_multiplier => 1.0
    }
    pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
    # Golden Camera calculation
    if $PokemonGlobal.goldencamera
      atk *= 0.8 if user.pbOwnedByPlayer?
      defense *= 0.8 if target.pbOwnedByPlayer?
    end
    # Main damage calculation
    baseDmg = [(baseDmg * multipliers[:base_damage_multiplier]).round, 1].max
    atk     = [(atk     * multipliers[:attack_multiplier]).round, 1].max
    defense = [(defense * multipliers[:defense_multiplier]).round, 1].max
    damage  = ((((2.0 * user.level / 5) + 2).floor * baseDmg * atk / defense).floor / 50).floor + 2
    damage  = [(damage * multipliers[:final_damage_multiplier]).round, 1].max
    target.damageState.calcDamage = damage
  end

  def pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
    # Global abilities
    if (@battle.pbCheckGlobalAbility(:DARKAURA) && type == :DARK) ||
       (@battle.pbCheckGlobalAbility(:FAIRYAURA) && type == :FAIRY) ||
       (@battle.pbCheckGlobalAbility(:SPOOPERAURA) && type == :GHOST) # spooper aura #by low
      if @battle.pbCheckGlobalAbility(:AURABREAK)
        multipliers[:base_damage_multiplier] *= 2 / 3.0
      else
        multipliers[:base_damage_multiplier] *= 4 / 3.0
      end
    end
    # Ability effects that alter damage
    if user.abilityActive?
      Battle::AbilityEffects.triggerDamageCalcFromUser(
        user.ability, user, target, self, multipliers, baseDmg, type
      )
    end
    #i edited this, because its stupid
    user.allAllies.each do |b|
      next if !b.abilityActive?
      Battle::AbilityEffects.triggerDamageCalcFromAlly(
        b.ability, user, target, self, multipliers, baseDmg, type
      )
    end
    #wasnt actually non ignorable. Nice
    if target.abilityActive?
      Battle::AbilityEffects.triggerDamageCalcFromTargetNonIgnorable(
        target.ability, user, target, self, multipliers, baseDmg, type
      )
    end
    if !@battle.moldBreaker
      # NOTE: It's odd that the user's Mold Breaker prevents its partner's
      #       beneficial abilities (i.e. Flower Gift boosting Atk), but that's
      #       how it works.
      #look up you fuckhead
      if target.abilityActive?
        Battle::AbilityEffects.triggerDamageCalcFromTarget(
          target.ability, user, target, self, multipliers, baseDmg, type
        )
      end
      target.allAllies.each do |b|
        next if !b.abilityActive?
        Battle::AbilityEffects.triggerDamageCalcFromTargetAlly(
          b.ability, user, target, self, multipliers, baseDmg, type
        )
      end
    end
    # Item effects that alter damage
    if user.itemActive?
      Battle::ItemEffects.triggerDamageCalcFromUser(
        user.item, user, target, self, multipliers, baseDmg, type
      )
    end
    # klutz buff #by low
    klut = user.hasActiveAbility?(:KLUTZ)
    klut = false if !$player.difficulty_mode?("chaos")
    if target.itemActive? && !klut
      Battle::ItemEffects.triggerDamageCalcFromTarget(
        target.item, user, target, self, multipliers, baseDmg, type
      )
    end
    # Parental Bond's second attack
    if user.effects[PBEffects::ParentalBond] == 1
      multipliers[:base_damage_multiplier] /= (Settings::MECHANICS_GENERATION >= 7) ? 4 : 2
    end
    # Other
    if user.effects[PBEffects::MeFirst]
      multipliers[:base_damage_multiplier] *= 1.5
    end
    if user.effects[PBEffects::HelpingHand] && !self.is_a?(Battle::Move::Confusion)
      multipliers[:base_damage_multiplier] *= 1.5
    end
    if target.effects[PBEffects::HoldingHand]
      multipliers[:base_damage_multiplier] *= 2 / 3.0
    end
    if user.effects[PBEffects::Charge] > 0 && type == :ELECTRIC
      multipliers[:base_damage_multiplier] *= 2
    end
    #by low
    if user.effects[PBEffects::ZealousDance] > 0 && type == :FIRE
      multipliers[:base_damage_multiplier] *= 1.5
    end
    # Mud Sport
    if type == :ELECTRIC
      if @battle.allBattlers.any? { |b| b.effects[PBEffects::MudSport] }
        multipliers[:base_damage_multiplier] /= 3
      end
      if @battle.field.effects[PBEffects::MudSportField] > 0
        multipliers[:base_damage_multiplier] /= 3
      end
    end
    # Water Sport
    if type == :FIRE
      if @battle.allBattlers.any? { |b| b.effects[PBEffects::WaterSport] }
        multipliers[:base_damage_multiplier] /= 3
      end
      if @battle.field.effects[PBEffects::WaterSportField] > 0
        multipliers[:base_damage_multiplier] /= 3
      end
    end
    # abilityTerrain #by low
    if $player.difficulty_mode?("chaos") # on "low mode"
      t_damage_multiplier = (@battle.field.abilityTerrain) ? 1.15 : 1.3
      t_damage_divider    = (@battle.field.abilityTerrain) ? 1.5 : 2
    else
      t_damage_multiplier = 1.3
      t_damage_divider    = 2
    end
    # Terrain
    case @battle.field.terrain
    when :Electric
      multipliers[:base_damage_multiplier] *= t_damage_multiplier if type == :ELECTRIC && user.affectedByTerrain? && @function != "DoublePowerInElectricTerrain"
    when :Grassy
      multipliers[:base_damage_multiplier] *= t_damage_multiplier if type == :GRASS && user.affectedByTerrain? && @function != "HigherPriorityInGrassyTerrain"
    when :Psychic
      multipliers[:base_damage_multiplier] *= t_damage_multiplier if type == :PSYCHIC && user.affectedByTerrain? && @function != "HitsAllFoesAndPowersUpInPsychicTerrain"
    when :Misty
      multipliers[:base_damage_multiplier] /= t_damage_divider if type == :DRAGON && target.affectedByTerrain?
    end
    #mastersex type zones #by low
    multipliers[:base_damage_multiplier] *= 1.25 if @battle.field.typezone != :None && type == @battle.field.typezone
    # Multi-targeting attacks
    # Splinter Shot #by low
    if numTargets > 1 && @function != "HitTwoTimesReload"
      multipliers[:final_damage_multiplier] *= 0.75
    end
    # abilityWeather #by low
    if $player.difficulty_mode?("chaos") # on "low mode"
      w_damage_multiplier = (@battle.field.abilityWeather) ? 1.25 : 1.5
      w_damage_divider    = (@battle.field.abilityWeather) ? 1.5 : 2
    else
      w_damage_multiplier = 1.5
      w_damage_divider    = 2
    end
    # Weather
    case user.effectiveWeather
    when :Sun, :HarshSun
      case type
      when :FIRE
        multipliers[:final_damage_multiplier] *= w_damage_multiplier
      when :WATER
        if !(@function == "HigherDamageInSunVSNonFireTypes" && !target.pbHasType?(:FIRE))
          multipliers[:final_damage_multiplier] /= w_damage_divider
        end
      end
    when :Rain, :HeavyRain
      case type
      when :FIRE
        multipliers[:final_damage_multiplier] /= w_damage_divider
      when :WATER
        multipliers[:final_damage_multiplier] *= w_damage_multiplier
      end
    when :Sandstorm
      if target.pbHasType?(:ROCK) && specialMove? && @function != "UseTargetDefenseInsteadOfTargetSpDef"
        multipliers[:defense_multiplier] *= 1.5
      end
    when :Hail # hail buff #by low
      if target.pbHasType?(:ICE) && Effectiveness.super_effective?(target.damageState.typeMod)
        multipliers[:final_damage_multiplier] *= 0.75
      end
    end
    # Master Mode stuff #by low
    #if $game_variables[MASTERMODEVARS][28]==true && !target.pbOwnedByPlayer? && Effectiveness.super_effective?(target.damageState.typeMod)
    #  multipliers[:final_damage_multiplier] *= 0.75
    #end
    # Gravity Boost #by low 
    # float stone changes
    if boostedByGravity? && @battle.field.effects[PBEffects::Gravity] > 0 && !target.hasActiveItem?(:FLOATSTONE)
      multipliers[:base_damage_multiplier] *= 4 / 3.0
    end
    # Critical hits
    if target.damageState.critical
      if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS && !$game_switches[OLDSCHOOLBATTLE]
        multipliers[:final_damage_multiplier] *= 1.5
      else
        multipliers[:final_damage_multiplier] *= 2
      end
    end
    # STAB
    if type && user.pbHasType?(type)
      if user.hasActiveAbility?(:ADAPTABILITY)
        multipliers[:final_damage_multiplier] *= 2
      else
        multipliers[:final_damage_multiplier] *= 1.5
      end
    end
    # Type effectiveness
    #~ print "#{multipliers[:final_damage_multiplier]} *= #{target.damageState.typeMod.to_f} / #{Effectiveness::NORMAL_EFFECTIVE}"
    multipliers[:final_damage_multiplier] *= target.damageState.typeMod.to_f / Effectiveness::NORMAL_EFFECTIVE
    damagenerf = 0.5
    damagenerf = (2 / 3.0) if $player.difficulty_mode?("chaos") #by low
    # Burn
    if user.status == :BURN && physicalMove? && damageReducedByBurn? &&
       !user.hasActiveAbility?(:GUTS)
      multipliers[:final_damage_multiplier] *= damagenerf
    end
    # Frostbite #by low
    if user.status == :FROZEN && specialMove? && damageReducedByBurn?
      multipliers[:final_damage_multiplier] *= damagenerf
    end
    # Aurora Veil, Reflect, Light Screen
    if !ignoresReflect? && !target.damageState.critical &&
       !user.hasActiveAbility?(:INFILTRATOR)
      if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
        multipliers[:final_damage_multiplier] *= 4 / 5.0
      end
      if target.pbOwnSide.effects[PBEffects::Reflect] > 0 && physicalMove?
        if @battle.pbSideBattlerCount(target) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      elsif target.pbOwnSide.effects[PBEffects::LightScreen] > 0 && specialMove?
        if @battle.pbSideBattlerCount(target) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      end
    end
    # Minimize
    if target.effects[PBEffects::Minimize] && tramplesMinimize?
      multipliers[:final_damage_multiplier] *= 2
    end
    # Kiriya targeting allies #by low
    if user.index != target.index && !target.opposes?(user) && !user.pbOwnedByPlayer?
      multipliers[:final_damage_multiplier] *= 0.75
    end
    # Move-specific base damage modifiers
    multipliers[:base_damage_multiplier] = pbBaseDamageMultiplier(multipliers[:base_damage_multiplier], user, target)
    # Move-specific final damage modifiers
    multipliers[:final_damage_multiplier] = pbModifyDamage(multipliers[:final_damage_multiplier], user, target)
  end

  #=============================================================================
  # Additional effect chance
  #=============================================================================
  def pbAdditionalEffectChance(user, target, effectChance = 0)
    return 0 if target.hasActiveAbility?(:SHIELDDUST) && !@battle.moldBreaker
    return 0 if @battle.futureSight #by low
    ret = (effectChance > 0) ? effectChance : @addlEffect
    if (Settings::MECHANICS_GENERATION >= 6 || @function != "EffectDependsOnEnvironment") &&
       (user.hasActiveAbility?(:SERENEGRACE) || user.pbOwnSide.effects[PBEffects::Rainbow] > 0)
      ret *= 2
    end
    ret = 100 if $DEBUG && Input.press?(Input::CTRL)
    return ret
  end

  # NOTE: Flinching caused by a move's effect is applied in that move's code,
  #       not here.
  def pbFlinchChance(user, target)
    return 0 if flinchingMove?
    return 0 if target.hasActiveAbility?(:SHIELDDUST) && !@battle.moldBreaker
    return 0 if target.effects[PBEffects::NoFlinch] > 0
    return 0 if @battle.turnCount == 0
    ret = 0
    if user.hasActiveAbility?(:STENCH, true) ||
       user.hasActiveItem?([:KINGSROCK, :RAZORFANG], true)
      ret = 10
    end
    ret *= 2 if user.pbOwnSide.effects[PBEffects::Rainbow] > 0
    return ret
  end
end