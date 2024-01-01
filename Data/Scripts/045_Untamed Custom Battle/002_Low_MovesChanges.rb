#===============================================================================
# OHKO. Accuracy increases by difference between levels of user and target.
#===============================================================================
class Battle::Move::OHKO < Battle::Move::FixedDamageMove
  def pbFailsAgainstTarget?(user, target, show_message)
    if target.level >= user.level #by low
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
		acc = 0 if $game_variables[MECHANICSVAR] >= 2 #by low
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
		if $game_variables[MECHANICSVAR] < 3
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

#==================================
# Raise one of user's stats.
#==================================
class Battle::Move::StatUpMove < Battle::Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user, targets)
    return false if damagingMove?
		if !damagingMove? && user.SetupMovesUsed.include?(@id) && $game_variables[MECHANICSVAR] >= 3
      @battle.pbDisplay(_INTL("But it failed! {1} has already used {2}!", user.pbThis, GameData::Move.get(@id).name))
      return true
		end
    return !user.pbCanRaiseStatStage?(@statUp[0], user, self, true)
  end

  def pbEffectGeneral(user)
    return if damagingMove?
    user.pbRaiseStatStage(@statUp[0], @statUp[1], user)
		user.SetupMovesUsed.push(@id)
  end

  def pbAdditionalEffect(user, target)
    if user.pbCanRaiseStatStage?(@statUp[0], user, self) && 
			 !user.SetupMovesUsed.include?(@id) && $game_variables[MECHANICSVAR] >= 3
      user.pbRaiseStatStage(@statUp[0], @statUp[1], user)
    end
		if damagingMove? && @addlEffect == 100
			user.SetupMovesUsed.push(@id)
    end
  end
end

#==================================
# Raise multiple of user's stats.
#==================================
class Battle::Move::MultiStatUpMove < Battle::Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user, targets)
    return false if damagingMove?
    failed = true
    (@statUp.length / 2).times do |i|
      next if !user.pbCanRaiseStatStage?(@statUp[i * 2], user, self)
      failed = false
      break
    end
		if !damagingMove? && user.SetupMovesUsed.include?(@id) && $game_variables[MECHANICSVAR] >= 3
      @battle.pbDisplay(_INTL("But it failed! {1} has already used {2}!", user.pbThis, GameData::Move.get(@id).name))
      return true
		end
    if failed
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!", user.pbThis))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    return if damagingMove?
    showAnim = true
    (@statUp.length / 2).times do |i|
      next if !user.pbCanRaiseStatStage?(@statUp[i * 2], user, self)
      if user.pbRaiseStatStage(@statUp[i * 2], @statUp[(i * 2) + 1], user, showAnim)
        showAnim = false
				user.SetupMovesUsed.push(@id)
				user.SetupMovesUsed |= []
      end
    end
  end

  def pbAdditionalEffect(user, target)
    showAnim = true
    (@statUp.length / 2).times do |i|
      next if !user.pbCanRaiseStatStage?(@statUp[i * 2], user, self)
      if user.pbRaiseStatStage(@statUp[i * 2], @statUp[(i * 2) + 1], user, showAnim) && 
				 !user.SetupMovesUsed.include?(@id) && $game_variables[MECHANICSVAR] >= 3
        showAnim = false
				if damagingMove? && @addlEffect == 100
					user.SetupMovesUsed.push(@id)
					user.SetupMovesUsed |= []
				end
      end
    end
  end
end


#===============================================================================
# Removes trapping moves, entry hazards and Leech Seed on user/user's side.
# Raises user's Speed by 1 stage IF REMOVED SOMETHING #by low (Rapid Spin)
#===============================================================================
class Battle::Move::RemoveUserBindingAndEntryHazards < Battle::Move
  def pbEffectAfterAllHits(user, target)
    return if user.fainted? || target.damageState.unaffected
		didsomething=false
    if user.effects[PBEffects::Trapping] > 0
      trapMove = GameData::Move.get(user.effects[PBEffects::TrappingMove]).name
      trapUser = @battle.battlers[user.effects[PBEffects::TrappingUser]]
      @battle.pbDisplay(_INTL("{1} got free of {2}'s {3}!", user.pbThis, trapUser.pbThis(true), trapMove))
      user.effects[PBEffects::Trapping]     = 0
      user.effects[PBEffects::TrappingMove] = nil
      user.effects[PBEffects::TrappingUser] = -1
			didsomething=true
    end
    if user.effects[PBEffects::LeechSeed] >= 0
      user.effects[PBEffects::LeechSeed] = -1
      @battle.pbDisplay(_INTL("{1} shed Leech Seed!", user.pbThis))
			didsomething=true
    end
    if user.pbOwnSide.effects[PBEffects::StealthRock]
      user.pbOwnSide.effects[PBEffects::StealthRock] = false
      @battle.pbDisplay(_INTL("{1} blew away stealth rocks!", user.pbThis))
			didsomething=true
    end
    if user.pbOwnSide.effects[PBEffects::Spikes] > 0
      user.pbOwnSide.effects[PBEffects::Spikes] = 0
      @battle.pbDisplay(_INTL("{1} blew away spikes!", user.pbThis))
			didsomething=true
    end
    if user.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
      user.pbOwnSide.effects[PBEffects::ToxicSpikes] = 0
      @battle.pbDisplay(_INTL("{1} blew away poison spikes!", user.pbThis))
			didsomething=true
    end
    if user.pbOwnSide.effects[PBEffects::StickyWeb] > 0
      user.pbOwnSide.effects[PBEffects::StickyWeb] = 0
      @battle.pbDisplay(_INTL("{1} blew away sticky webs!", user.pbThis))
			didsomething=true
    end
		if didsomething && !user.SetupMovesUsed.include?(@id)
			user.pbRaiseStatStage(:SPEED, 1, user)
			user.SetupMovesUsed.push(@id)
    end
  end
end

#===============================================================================
# Raises the Attack and Defense of all user's allies by 1 stage each. Bypasses
# protections, including Crafty Shield. Fails if there is no ally. (Coaching)
#===============================================================================
class Battle::Move::RaiseUserAndAlliesAtkDef1 < Battle::Move
  def ignoresSubstitute?(user); return true; end
  def canSnatch?; return true; end

  def pbMoveFailed?(user, targets)
    @validTargets = []
    @battle.allSameSideBattlers(user).each do |b|
      next if b.index == user.index
      next if !b.pbCanRaiseStatStage?(:ATTACK, user, self) &&
              !b.pbCanRaiseStatStage?(:DEFENSE, user, self)
      next if b.SetupMovesUsed.include?(@id) && $game_variables[MECHANICSVAR] >= 3
			@validTargets.push(b)
    end
    if @validTargets.length == 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    return false if @validTargets.any? { |b| b.index == target.index }
    @battle.pbDisplay(_INTL("{1}'s stats can't be raised further!", target.pbThis)) if show_message
    return true
  end

  def pbEffectAgainstTarget(user, target)
    showAnim = true
    if target.pbCanRaiseStatStage?(:ATTACK, user, self)
      showAnim = false if target.pbRaiseStatStage(:ATTACK, 1, user, showAnim)
    end
    if target.pbCanRaiseStatStage?(:DEFENSE, user, self)
      target.pbRaiseStatStage(:DEFENSE, 1, user, showAnim)
    end
		target.SetupMovesUsed.push(@id)
  end
end

#===============================================================================
# Increases the user's and its ally's Attack and Special Attack by 1 stage each,
# if they have Plus or Minus. (Gear Up)
#===============================================================================
# NOTE: In Gen 5, this move should have a target of UserSide, while in Gen 6+ it
#       should have a target of UserAndAllies. This is because, in Gen 5, this
#       move shouldn't call def pbSuccessCheckAgainstTarget for each Pokémon
#       currently in battle that will be affected by this move (i.e. allies
#       aren't protected by their substitute/ability/etc., but they are in Gen
#       6+). We achieve this by not targeting any battlers in Gen 5, since
#       pbSuccessCheckAgainstTarget is only called for targeted battlers.
class Battle::Move::RaisePlusMinusUserAndAlliesAtkSpAtk1 < Battle::Move
  def ignoresSubstitute?(user); return true; end
  def canSnatch?;               return true; end

  def pbMoveFailed?(user, targets)
    @validTargets = []
    @battle.allSameSideBattlers(user).each do |b|
      next if !b.hasActiveAbility?([:MINUS, :PLUS])
      next if !b.pbCanRaiseStatStage?(:ATTACK, user, self) &&
              !b.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user, self)
      next if b.SetupMovesUsed.include?(@id) && $game_variables[MECHANICSVAR] >= 3
      @validTargets.push(b)
    end
    if @validTargets.length == 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    return false if @validTargets.any? { |b| b.index == target.index }
    return true if !target.hasActiveAbility?([:MINUS, :PLUS])
    @battle.pbDisplay(_INTL("{1}'s stats can't be raised further!", target.pbThis)) if show_message
    return true
  end

  def pbEffectAgainstTarget(user, target)
    showAnim = true
    if target.pbCanRaiseStatStage?(:ATTACK, user, self)
      showAnim = false if target.pbRaiseStatStage(:ATTACK, 1, user, showAnim)
    end
    if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user, self)
      target.pbRaiseStatStage(:SPECIAL_ATTACK, 1, user, showAnim)
    end
		target.SetupMovesUsed.push(@id)
  end

  def pbEffectGeneral(user)
    return if pbTarget(user) != :UserSide
    @validTargets.each { |b| pbEffectAgainstTarget(user, b) }
  end
end


#===============================================================================
# Increases the user's and its ally's Defense and Special Defense by 1 stage
# each, if they have Plus or Minus. (Magnetic Flux)
#===============================================================================
# NOTE: In Gen 5, this move should have a target of UserSide, while in Gen 6+ it
#       should have a target of UserAndAllies. This is because, in Gen 5, this
#       move shouldn't call def pbSuccessCheckAgainstTarget for each Pokémon
#       currently in battle that will be affected by this move (i.e. allies
#       aren't protected by their substitute/ability/etc., but they are in Gen
#       6+). We achieve this by not targeting any battlers in Gen 5, since
#       pbSuccessCheckAgainstTarget is only called for targeted battlers.
class Battle::Move::RaisePlusMinusUserAndAlliesDefSpDef1 < Battle::Move
  def ignoresSubstitute?(user); return true; end
  def canSnatch?; return true; end

  def pbMoveFailed?(user, targets)
    @validTargets = []
    @battle.allSameSideBattlers(user).each do |b|
      next if !b.hasActiveAbility?([:MINUS, :PLUS])
      next if !b.pbCanRaiseStatStage?(:DEFENSE, user, self) &&
              !b.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, user, self)
      next if b.SetupMovesUsed.include?(@id) && $game_variables[MECHANICSVAR] >= 3
      @validTargets.push(b)
    end
    if @validTargets.length == 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    return false if @validTargets.any? { |b| b.index == target.index }
    return true if !target.hasActiveAbility?([:MINUS, :PLUS])
    @battle.pbDisplay(_INTL("{1}'s stats can't be raised further!", target.pbThis)) if show_message
    return true
  end

  def pbEffectAgainstTarget(user, target)
    showAnim = true
    if target.pbCanRaiseStatStage?(:DEFENSE, user, self)
      showAnim = false if target.pbRaiseStatStage(:DEFENSE, 1, user, showAnim)
    end
    if target.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, user, self)
      target.pbRaiseStatStage(:SPECIAL_DEFENSE, 1, user, showAnim)
    end
		target.SetupMovesUsed.push(@id)
  end

  def pbEffectGeneral(user)
    return if pbTarget(user) != :UserSide
    @validTargets.each { |b| pbEffectAgainstTarget(user, b) }
  end
end

#===============================================================================
# Increases the Attack and Special Attack of all Grass-type Pokémon in battle by
# 1 stage each. Doesn't affect airborne Pokémon. (Rototiller)
#===============================================================================
class Battle::Move::RaiseGroundedGrassBattlersAtkSpAtk1 < Battle::Move
  def pbMoveFailed?(user, targets)
    @validTargets = []
    @battle.allBattlers.each do |b|
      next if !b.pbHasType?(:GRASS)
      next if b.airborne? || b.semiInvulnerable?
      next if !b.pbCanRaiseStatStage?(:ATTACK, user, self) &&
              !b.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user, self)
      next if b.SetupMovesUsed.include?(@id) && $game_variables[MECHANICSVAR] >= 3
      @validTargets.push(b.index)
    end
    if @validTargets.length == 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    return false if @validTargets.include?(target.index)
    return true if !target.pbHasType?(:GRASS)
    return true if target.airborne? || target.semiInvulnerable?
    @battle.pbDisplay(_INTL("{1}'s stats can't be raised further!", target.pbThis)) if show_message
    return true
  end

  def pbEffectAgainstTarget(user, target)
    showAnim = true
    if target.pbCanRaiseStatStage?(:ATTACK, user, self)
      showAnim = false if target.pbRaiseStatStage(:ATTACK, 1, user, showAnim)
    end
    if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user, self)
      target.pbRaiseStatStage(:SPECIAL_ATTACK, 1, user, showAnim)
    end
		target.SetupMovesUsed.push(@id)
  end
end

#===============================================================================
# Increases the Defense of all Grass-type Pokémon on the field by 1 stage each.
# (Flower Shield)
#===============================================================================
class Battle::Move::RaiseGrassBattlersDef1 < Battle::Move
  def pbMoveFailed?(user, targets)
    @validTargets = []
    @battle.allBattlers.each do |b|
      next if !b.pbHasType?(:GRASS)
      next if b.semiInvulnerable?
      next if !b.pbCanRaiseStatStage?(:DEFENSE, user, self)
      next if b.SetupMovesUsed.include?(@id) && $game_variables[MECHANICSVAR] >= 3
      @validTargets.push(b.index)
    end
    if @validTargets.length == 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    return false if @validTargets.include?(target.index)
    return true if !target.pbHasType?(:GRASS) || target.semiInvulnerable?
    return !target.pbCanRaiseStatStage?(:DEFENSE, user, self, show_message)
  end

  def pbEffectAgainstTarget(user, target)
    target.pbRaiseStatStage(:DEFENSE, 1, user)
		target.SetupMovesUsed.push(@id)
  end
end
#===============================================================================
# Increases the user's and allies' Attack by 1 stage. (Howl (Gen 8+))
#===============================================================================
class Battle::Move::RaiseTargetAttack1 < Battle::Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user, targets)
    return false if damagingMove?
    failed = true
    targets.each do |b|
      next if !b.pbCanRaiseStatStage?(:ATTACK, user, self)
      failed = false
			if b.SetupMovesUsed.include?(@id) && $game_variables[MECHANICSVAR] >= 3
				@battle.pbDisplay(_INTL("But it failed! {1} has already used {2}!", user.pbThis, GameData::Move.get(@id).name))
				failed = false
			end
      break
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    return false if damagingMove?
    return !target.pbCanRaiseStatStage?(:ATTACK, user, self, show_message)
  end

  def pbEffectAgainstTarget(user, target)
    return if damagingMove?
    target.pbRaiseStatStage(:ATTACK, 1, user)
		target.SetupMovesUsed.push(@id)
  end

  def pbAdditionalEffect(user, target)
    return if !target.pbCanRaiseStatStage?(:ATTACK, user, self)
    target.pbRaiseStatStage(:ATTACK, 1, user)
  end
end

#===============================================================================
# Increases target's Special Defense by 1 stage. (Aromatic Mist)
#===============================================================================
class Battle::Move::RaiseTargetSpDef1 < Battle::Move
  def ignoresSubstitute?(user); return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    return true if !target.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, user, self, show_message)
		if target.SetupMovesUsed.include?(@id) && $game_variables[MECHANICSVAR] >= 3
      @battle.pbDisplay(_INTL("But it failed! {1} has already used {2}!", user.pbThis, GameData::Move.get(@id).name))
      return true
		end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    target.pbRaiseStatStage(:SPECIAL_DEFENSE, 1, user)
    target.pbRaiseStatStage(:ATTACK, 1, user)
		target.SetupMovesUsed.push(@id)
  end
end

#===============================================================================
# Increases one random stat of the target by 2 stages (except HP). (Acupressure)
#===============================================================================
class Battle::Move::RaiseTargetRandomStat2 < Battle::Move
  def pbFailsAgainstTarget?(user, target, show_message)
    @statArray = []
    GameData::Stat.each_battle do |s|
      @statArray.push(s.id) if target.pbCanRaiseStatStage?(s.id, user, self)
    end
    if @statArray.length == 0
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!", target.pbThis)) if show_message
      return true
    end
		if target.SetupMovesUsed.include?(@id) && $game_variables[MECHANICSVAR] >= 3
      @battle.pbDisplay(_INTL("But it failed! {1} has already used {2}!", user.pbThis, GameData::Move.get(@id).name))
      return true
		end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    stat = @statArray[@battle.pbRandom(@statArray.length)]
    target.pbRaiseStatStage(stat, 2, user)
		target.SetupMovesUsed.push(@id)
  end
end

#===============================================================================
# Increases the target's Attack and Special Attack by 2 stages each. (Decorate)
#===============================================================================
class Battle::Move::RaiseTargetAtkSpAtk2 < Battle::Move
  def pbMoveFailed?(user, targets)
    failed = true
    targets.each do |b|
      next if !b.pbCanRaiseStatStage?(:ATTACK, user, self) &&
              !b.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user, self)
			next if b.SetupMovesUsed.include?(@id) && $game_variables[MECHANICSVAR] >= 3
      failed = false
      break
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    if target.pbCanRaiseStatStage?(:ATTACK, user, self)
      target.pbRaiseStatStage(:ATTACK, 2, user)
    end
    if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user, self)
      target.pbRaiseStatStage(:SPECIAL_ATTACK, 2, user)
    end
		target.SetupMovesUsed.push(@id)
  end
end

#===============================================================================
# Decreases the user's Defense and Special Defense by 2 stages each.
# Increases the user's Attack and Special Attack by 2 stages each.
# Increases the user's Speed by 1 stage.
# (Shell Smash) edits #by low
#===============================================================================
class Battle::Move::LowerUserDefSpDef1RaiseUserAtkSpAtkSpd2 < Battle::Move
  def canSnatch?; return true; end

  def initialize(battle, move)
    super
    @statUp   = [:ATTACK, 2, :SPECIAL_ATTACK, 2, :SPEED, 1]
    @statDown = [:DEFENSE, 2, :SPECIAL_DEFENSE, 2]
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
		if user.SetupMovesUsed.include?(@id) && $game_variables[MECHANICSVAR] >= 3
      @battle.pbDisplay(_INTL("But it failed! {1} has already used {2}!", user.pbThis, GameData::Move.get(@id).name))
      return true
		end
    return false
  end

  def pbEffectGeneral(user)
    showAnim = true
    (@statDown.length / 2).times do |i|
      next if !user.pbCanLowerStatStage?(@statDown[i * 2], user, self)
      if user.pbLowerStatStage(@statDown[i * 2], @statDown[(i * 2) + 1], user, showAnim)
        showAnim = false
      end
    end
    showAnim = true
    (@statUp.length / 2).times do |i|
      next if !user.pbCanRaiseStatStage?(@statUp[i * 2], user, self)
      if user.pbRaiseStatStage(@statUp[i * 2], @statUp[(i * 2) + 1], user, showAnim)
        showAnim = false
      end
    end
		user.SetupMovesUsed.push(@id)
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
      2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
      3, 3, 3, 3, 3, 3, 3,
      4, 4, 4,
      5
    ]
    r = @battle.pbRandom(hitChances.length)
    r = hitChances.length - 1 if user.hasActiveAbility?(:SKILLLINK)
    return hitChances[r]
  end

  def pbEffectAfterAllHits(user, target)
    return if target.damageState.unaffected
    if user.pbCanLowerStatStage?(:DEFENSE, user, self)
      user.pbLowerStatStage(:DEFENSE, 1, user)
    end
    if user.pbCanRaiseStatStage?(:SPEED, user, self) && (!user.SetupMovesUsed.include?(@id) && $game_variables[MECHANICSVAR] >= 3)
      user.pbRaiseStatStage(:SPEED, 1, user)
    end
		user.SetupMovesUsed.push(@id)
  end
end

#===============================================================================
# Two turn attack. Skips first turn, and increases the user's Special Attack,
# Special Defense and Speed by 2 stages each in the second turn. (Geomancy)
#===============================================================================
class Battle::Move::TwoTurnAttackRaiseUserSpAtkSpDefSpd2 < Battle::Move::TwoTurnMove
  def pbMoveFailed?(user, targets)
    return false if user.effects[PBEffects::TwoTurnAttack]   # Charging turn
    if !user.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user, self) &&
       !user.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, user, self) &&
       !user.pbCanRaiseStatStage?(:SPEED, user, self)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!", user.pbThis))
      return true
    end
		if user.SetupMovesUsed.include?(@id) && $game_variables[MECHANICSVAR] >= 3
      @battle.pbDisplay(_INTL("But it failed! {1} has already used {2}!", user.pbThis, GameData::Move.get(@id).name))
      return true
		end
    return false
  end

  def pbChargingTurnMessage(user, targets)
    @battle.pbDisplay(_INTL("{1} is absorbing power!", user.pbThis))
  end

  def pbEffectGeneral(user)
    return if !@damagingTurn
    showAnim = true
    [:SPECIAL_ATTACK, :SPECIAL_DEFENSE, :SPEED].each do |s|
      next if !user.pbCanRaiseStatStage?(s, user, self)
      if user.pbRaiseStatStage(s, 2, user, showAnim)
        showAnim = false
      end
    end
		user.SetupMovesUsed.push(@id)
  end
end

#===============================================================================
# Two turn attack. Ups user's Defense by 1 stage first turn, attacks second turn.
# (Skull Bash)
#===============================================================================
class Battle::Move::TwoTurnAttackChargeRaiseUserDefense1 < Battle::Move::TwoTurnMove
  def pbChargingTurnMessage(user, targets)
    @battle.pbDisplay(_INTL("{1} tucked in its head!", user.pbThis))
  end

  def pbChargingTurnEffect(user, target)
    if user.pbCanRaiseStatStage?(:DEFENSE, user, self) && (!user.SetupMovesUsed.include?(@id) && $game_variables[MECHANICSVAR] >= 3)
      user.pbRaiseStatStage(:DEFENSE, 1, user)
			user.SetupMovesUsed.push(@id)
    end
  end
end

#===============================================================================
# Two-turn attack. On the first turn, increases the user's Special Attack by 1
# stage. On the second turn, does damage. (Meteor Beam)
#===============================================================================
class Battle::Move::TwoTurnAttackChargeRaiseUserSpAtk1 < Battle::Move::TwoTurnMove
  def pbChargingTurnMessage(user, targets)
    @battle.pbDisplay(_INTL("{1} is overflowing with space power!", user.pbThis))
  end

  def pbChargingTurnEffect(user, target)
    if user.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user, self) && (!user.SetupMovesUsed.include?(@id) && $game_variables[MECHANICSVAR] >= 3)
      user.pbRaiseStatStage(:SPECIAL_ATTACK, 1, user)
			user.SetupMovesUsed.push(@id)
    end
  end
end

#===============================================================================
# Increases the user's Defense and Special Defense by 1 stage each. Ups the
# user's stockpile by 1 (max. 3). (Stockpile)
#===============================================================================
class Battle::Move::UserAddStockpileRaiseDefSpDef1 < Battle::Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user, targets)
    if user.effects[PBEffects::Stockpile] >= 3
      @battle.pbDisplay(_INTL("{1} can't stockpile any more!", user.pbThis))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::Stockpile] += 1
    @battle.pbDisplay(_INTL("{1} stockpiled {2}!",
                            user.pbThis, user.effects[PBEffects::Stockpile]))
    showAnim = true
    if user.pbCanRaiseStatStage?(:DEFENSE, user, self) && (!user.SetupMovesUsed.include?(@id) && $game_variables[MECHANICSVAR] >= 3)
      if user.pbRaiseStatStage(:DEFENSE, 1, user, showAnim)
				user.SetupMovesUsed.push(@id)
        user.effects[PBEffects::StockpileDef] += 1
        showAnim = false
      end
    end
    if user.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, user, self) && (!user.SetupMovesUsed.include?(@id) && $game_variables[MECHANICSVAR] >= 3)
      if user.pbRaiseStatStage(:SPECIAL_DEFENSE, 1, user, showAnim)
				user.SetupMovesUsed.push(@id)
        user.effects[PBEffects::StockpileSpDef] += 1
      end
    end
		user.SetupMovesUsed |= []
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
    if user.pbHasType?(:GHOST) && $game_variables[MECHANICSVAR] < 3
      ghost_target = (Settings::MECHANICS_GENERATION >= 8) ? :RandomNearFoe : :NearFoe
      return GameData::Target.get(ghost_target)
    end
    return super
  end

  def pbMoveFailed?(user, targets)
    return false if user.pbHasType?(:GHOST) && $game_variables[MECHANICSVAR] < 3
    if !user.pbCanLowerStatStage?(:SPEED, user, self) &&
       !user.pbCanRaiseStatStage?(:ATTACK, user, self) &&
       !user.pbCanRaiseStatStage?(:DEFENSE, user, self)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
		if user.SetupMovesUsed.include?(@id) && $game_variables[MECHANICSVAR] >= 3
      @battle.pbDisplay(_INTL("But it failed! {1} has already used {2}!", user.pbThis, GameData::Move.get(@id).name))
      return true
		end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    if user.pbHasType?(:GHOST) && target.effects[PBEffects::Curse] && $game_variables[MECHANICSVAR] < 3
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    return if user.pbHasType?(:GHOST) && $game_variables[MECHANICSVAR] < 3
    # Non-Ghost effect
    if user.pbCanLowerStatStage?(:SPEED, user, self)
      user.pbLowerStatStage(:SPEED, 1, user)
    end
    showAnim = true
    if user.pbCanRaiseStatStage?(:ATTACK, user, self)
      showAnim = false if user.pbRaiseStatStage(:ATTACK, 1, user, showAnim)
    end
    if user.pbCanRaiseStatStage?(:DEFENSE, user, self)
      user.pbRaiseStatStage(:DEFENSE, 1, user, showAnim)
    end
		user.SetupMovesUsed.push(@id)
  end

  def pbEffectAgainstTarget(user, target)
    return if !user.pbHasType?(:GHOST)
		return if $game_variables[MECHANICSVAR] >= 3
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
			if $game_variables[MECHANICSVAR] >= 3
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
					user.pbReduceHP((user.hp/32), false)
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
			if $game_variables[MECHANICSVAR] >= 2
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
# For 3-5 rounds, lowers power of attacks against the user's side. Fails if
# weather is not hail. (Aurora Veil)
#===============================================================================
class Battle::Move::StartWeakenDamageAgainstUserSideIfHail < Battle::Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user, targets)
    if user.effectiveWeather != :Hail
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
		turns 				 = ($game_variables[MECHANICSVAR] >= 3) ? 3 : 5
		lightclayturns = ($game_variables[MECHANICSVAR] >= 3) ? 5 : 8
    user.pbOwnSide.effects[PBEffects::AuroraVeil] = turns
    user.pbOwnSide.effects[PBEffects::AuroraVeil] = lightclayturns if user.hasActiveItem?(:LIGHTCLAY)
    @battle.pbDisplay(_INTL("{1} made {2} stronger against physical and special moves!",
                            @name, user.pbTeam(true)))
  end
end