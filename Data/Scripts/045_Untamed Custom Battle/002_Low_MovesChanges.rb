#===============================================================================
# OHKO. Accuracy increases by difference between levels of user and target.
#===============================================================================
class Battle::Move::OHKO < Battle::Move::FixedDamageMove
  def pbFailsAgainstTarget?(user, target, show_message)
    if target.level >= user.level || $player.difficulty_mode?("hard") #by low
      @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis)) if show_message
      return true
    end
    if target.hasActiveAbility?(:STURDY) && !@battle.moldBreaker
      if show_message
        @battle.pbShowAbilitySplash(target)
        if Battle::Scene::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("But it failed to affect {1}!", target.pbThis(true)))
        else
          @battle.pbDisplay(_INTL("But it failed to affect {1} because of its {2}!",
                                  target.pbThis(true), target.abilityName))
        end
        @battle.pbHideAbilitySplash(target)
      end
      return true
    end
    return false
  end

  def pbAccuracyCheck(user, target)
    acc = @accuracy + user.level - target.level
    return @battle.pbRandom(100) < acc
  end

  def pbFixedDamage(user, target)
    return target.totalhp
  end

  def pbHitEffectivenessMessages(user, target, numTargets = 1)
    super
    if target.fainted?
      @battle.pbDisplay(_INTL("It's a one-hit KO!"))
    end
  end
end

#===============================================================================
# Target drops its item. It regains the item at the end of the battle. (Knock Off)
# If target has a losable item, damage is multiplied by 1.5. (if on vanilla)
#===============================================================================
class Battle::Move::RemoveTargetItem < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    if !$player.difficulty_mode?("chaos")
      if Settings::MECHANICS_GENERATION >= 6 &&
         target.item && !target.unlosableItem?(target.item) && !target.hasActiveAbility?(:STICKYHOLD)
         # NOTE: Damage is still boosted even if target has a substitute.
        baseDmg = (baseDmg * 1.5).round
      end
    end
    return baseDmg
  end

  def pbEffectAfterAllHits(user, target)
    return if user.wild?   # Wild Pokémon can't knock off
    return if user.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if !target.item || target.unlosableItem?(target.item)
    return if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
    itemName = target.itemName
    target.pbRemoveItem(false)
    @battle.pbDisplay(_INTL("{1} dropped its {2}!", target.pbThis, itemName))
  end
end

# ====================================================================================================================
# Setup moves edits
# ====================================================================================================================

#===============================================================================
# (Shell Smash) edits #by low [dumb move tbdesu]
#===============================================================================
class Battle::Move::LowerUserDefSpDef1RaiseUserAtkSpAtkSpd2 < Battle::Move
  def canSnatch?; return true; end

  def initialize(battle, move)
    super
    @statUp   = [:ATTACK, 2, :SPECIAL_ATTACK, 2]
    if $player.difficulty_mode?("chaos")
      @statUp.push(:SPEED, 1)
    else
      @statUp.push(:SPEED, 2)
    end
    @statDown = [:DEFENSE, 1, :SPECIAL_DEFENSE, 1]
  end

  def pbMoveFailed?(user, targets)
    failed = true
    (@statUp.length / 2).times do |i|
      if user.pbCanRaiseStatStage?(@statUp[i * 2], user, self)
        failed = false
        break
      end
    end
    (@statDown.length / 2).times do |i|
      if user.pbCanLowerStatStage?(@statDown[i * 2], user, self)
        failed = false
        break
      end
    end
    if failed
      @battle.pbDisplay(_INTL("{1}'s stats can't be changed further!", user.pbThis))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    showAnim = true
    (@statDown.length / 2).times do |i|
      next if !user.pbCanLowerStatStage?(@statDown[i * 2], user, self)
      if user.pbLowerStatStage(@statDown[i * 2], @statDown[(i * 2) + 1], user, showAnim, false, self)
        showAnim = false
      end
    end
    showAnim = true
    (@statUp.length / 2).times do |i|
      next if !user.pbCanRaiseStatStage?(@statUp[i * 2], user, self)
      if user.pbRaiseStatStage(@statUp[i * 2], @statUp[(i * 2) + 1], user, showAnim, false, self)
        showAnim = false
      end
    end
  end
end

#===============================================================================
# Hits 2-5 times in a row. If the move does not fail, increases the user's Speed
# by 1 stage and decreases the user's Defense by 1 stage. (Scale Shot)
#===============================================================================
class Battle::Move::HitTwoToFiveTimesRaiseUserSpd1LowerUserDef1 < Battle::Move
  def multiHitMove?; return true; end

  def pbNumHits(user, targets)
    hitChances = [
        2, 2, 2, 2, 2, 2, 2,
        3, 3, 3, 3, 3, 3, 3,
        4, 4, 4,
        5, 5, 5
    ]
    hitChances.map! { |c| c <= 2 ? (c + 1) : c } if !user.pbOwnedByPlayer?
    r = @battle.pbRandom(hitChances.length)
    r = hitChances.length - 1 if user.hasActiveAbility?(:SKILLLINK)
    return hitChances[r]
  end

  def pbEffectAfterAllHits(user, target)
    return if target.damageState.unaffected
    user.pbLowerStatStage(:DEFENSE, 1, user) if user.pbCanLowerStatStage?(:DEFENSE, user, self)
    user.pbRaiseStatStage(:SPEED, 1, user, true, false, self) if user.pbCanRaiseStatStage?(:SPEED, user, self)
  end
end

#===============================================================================
# User is Ghost: User loses 1/2 of max HP, and curses the target.
# Cursed Pokémon lose 1/4 of their max HP at the end of each round.
# User is not Ghost: Decreases the user's Speed by 1 stage, and increases the
# user's Attack and Defense by 1 stage each. (Curse)
#===============================================================================
class Battle::Move::CurseTargetOrLowerUserSpd1RaiseUserAtkDef1 < Battle::Move
  def ignoresSubstitute?(user); return true; end

  def pbTarget(user)
    if user.pbHasType?(:GHOST) && !$player.difficulty_mode?("chaos")
      ghost_target = (Settings::MECHANICS_GENERATION >= 8) ? :RandomNearFoe : :NearFoe
      return GameData::Target.get(ghost_target)
    end
    return super
  end

  def pbMoveFailed?(user, targets)
    return false if user.pbHasType?(:GHOST) && !$player.difficulty_mode?("chaos")
    if !user.pbCanLowerStatStage?(:SPEED, user, self) &&
       !user.pbCanRaiseStatStage?(:ATTACK, user, self) &&
       !user.pbCanRaiseStatStage?(:DEFENSE, user, self)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    if user.pbHasType?(:GHOST) && target.effects[PBEffects::Curse] && !$player.difficulty_mode?("chaos")
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    return if user.pbHasType?(:GHOST) && !$player.difficulty_mode?("chaos")
    # Non-Ghost effect
    if user.pbCanLowerStatStage?(:SPEED, user, self)
      user.pbLowerStatStage(:SPEED, 1, user)
    end
    showAnim = true
    if user.pbCanRaiseStatStage?(:ATTACK, user, self)
      showAnim = false if user.pbRaiseStatStage(:ATTACK, 1, user, showAnim, false, self)
    end
    if user.pbCanRaiseStatStage?(:DEFENSE, user, self)
      user.pbRaiseStatStage(:DEFENSE, 1, user, showAnim, false, self)
    end
  end

  def pbEffectAgainstTarget(user, target)
    return if !user.pbHasType?(:GHOST)
    return if $player.difficulty_mode?("chaos")
    # Ghost effect
    @battle.pbDisplay(_INTL("{1} cut its own HP and laid a curse on {2}!", user.pbThis, target.pbThis(true)))
    target.effects[PBEffects::Curse] = true
    user.pbReduceHP(user.totalhp / 8, false, false) # 2 -> 8
    user.pbItemHPHealCheck
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    hitNum = 1 #if !user.pbHasType?(:GHOST)   # Non-Ghost anim
    super
  end
end

#===============================================================================
# (Fiery Dance)
#===============================================================================
class Battle::Move::RaiseUserSpAtk1 < Battle::Move::StatUpMove
  def initialize(battle, move)
    super
    @statUp = [:SPECIAL_ATTACK, 1]
  end
  
  def pbOnStartUse(user, targets)
    return if user.fainted?
    return if ![:QUETZALIL, :QUEXCELL, :QUETZILLIAN].include?(user.species)
    if @id == :FIERYDANCE && user.pbOwnedByPlayer?
      if $player.difficulty_mode?("chaos")
        rng = rand(1..2)
        case rng
          when 1
            @battle.pbDisplay(_INTL("{1} forgot how to perform its dance!", user.pbThis))
            @battle.pbDisplay(_INTL("{1} exponentially combusts out of embarrassment!", user.pbThis))
          when 2
            @battle.pbDisplay(_INTL("{1} looks at you with immense disapointment.", user.pbThis))
            @battle.pbDisplay(_INTL("{1} exponentially combusts out of shame of its trainer.", user.pbThis))
        end
        user.pbReduceHP(user.hp, false)
        user.pbItemHPHealCheck
      else
        rng = rand(1..4)
        if rng == 1
          @battle.pbDisplay(_INTL("{1} is extremely anxious!", user.pbThis))
          @battle.pbDisplay(_INTL("{1} did a wrong step!", user.pbThis))
          user.pbReduceHP((user.hp/16), false)
          user.pbItemHPHealCheck
          @battle.pbDisplay(_INTL("{1} is trying to play it off cool.", user.pbThis))
        end
      end
    end
  end
end

#===============================================================================
# (Quiver Dance)
#===============================================================================
class Battle::Move::RaiseUserSpAtkSpDefSpd1 < Battle::Move::MultiStatUpMove
  def initialize(battle, move)
    super
    @statUp = [:SPECIAL_ATTACK, 1, :SPECIAL_DEFENSE, 1, :SPEED, 1]
  end
  
  def pbOnStartUse(user, targets)
    return if user.fainted?
    return if ![:QUETZALIL, :QUEXCELL, :QUETZILLIAN].include?(user.species)
    if @id == :QUIVERDANCE && user.pbOwnedByPlayer?
      if $player.difficulty_mode?("hard")
        rng = rand(1..2)
        case rng
          when 1
            @battle.pbDisplay(_INTL("{1} forgot how to perform its dance!", user.pbThis))
            @battle.pbDisplay(_INTL("{1} exponentially combusts out of embarrassment!", user.pbThis))
          when 2
            @battle.pbDisplay(_INTL("{1} looks at you with immense disapointment.", user.pbThis))
            @battle.pbDisplay(_INTL("{1} exponentially combusts out of shame of its trainer.", user.pbThis))
        end
        user.pbReduceHP(user.hp, false)
        user.pbItemHPHealCheck
      else
        rng = rand(1..4)
        if rng == 1
          @battle.pbDisplay(_INTL("{1} is extremely anxious!", user.pbThis))
          @battle.pbDisplay(_INTL("{1} did a wrong step!", user.pbThis))
          user.pbReduceHP((user.hp/16), false)
          user.pbItemHPHealCheck
          @battle.pbDisplay(_INTL("{1} is trying to play it off cool.", user.pbThis))
        end
      end
    end
  end
end