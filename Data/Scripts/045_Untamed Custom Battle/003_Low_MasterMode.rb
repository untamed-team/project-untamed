=begin
	$game_variables[MASTERMODEVARS][1]  = permanent reflect for opponents
	$game_variables[MASTERMODEVARS][2]  = permanent light screen for opponents
	$game_variables[MASTERMODEVARS][3]  = 10% physical damage boost for opponents
	$game_variables[MASTERMODEVARS][4]  = 10% special damage boost for opponents
	$game_variables[MASTERMODEVARS][5]  = status conditions immunity for opponents
	$game_variables[MASTERMODEVARS][6]  = flinch, confusion and trapping/binding immunity for opponents
	$game_variables[MASTERMODEVARS][7]  = opponents gain 10 levels
	$game_variables[MASTERMODEVARS][8]  = 30% attack / special attack boost for opponents
	$game_variables[MASTERMODEVARS][9]  = 30% defense / special defense boost for opponents
	$game_variables[MASTERMODEVARS][10] = 20% HP boost for opponents
	$game_variables[MASTERMODEVARS][11] = stat drop immunity for opponents
	$game_variables[MASTERMODEVARS][12] = reduces the HP restored by allies' healing moves by 50%.
	$game_variables[MASTERMODEVARS][13] = pressure is always active
	$game_variables[MASTERMODEVARS][14] = opponents get a omniboost on the switch
	$game_variables[MASTERMODEVARS][15] = player gets a omninerf on the switch
	$game_variables[MASTERMODEVARS][16] = 80% physical damage reduction for player
	$game_variables[MASTERMODEVARS][17] = 80% special damage reduction for player
	$game_variables[MASTERMODEVARS][18] = aqua ring is always active for the opponent
	$game_variables[MASTERMODEVARS][19] = critical hit immunity for opponents
	$game_variables[MASTERMODEVARS][20] = 50% attack / special attack boost for opponents
	$game_variables[MASTERMODEVARS][21] = 50% defense / special defense boost for opponents
	$game_variables[MASTERMODEVARS][22] = opponents gain 20 levels
	$game_variables[MASTERMODEVARS][23] = 40% HP boost for opponents
	$game_variables[MASTERMODEVARS][24] = opponents gain 30 levels
	$game_variables[MASTERMODEVARS][25] = 60% HP boost for opponents
	$game_variables[MASTERMODEVARS][26] = 80% HP boost for opponents
	$game_variables[MASTERMODEVARS][27] = opponents gain 60 levels
	$game_variables[MASTERMODEVARS][28] = lowers super effective moves damage by 25%, lowers "4x SE" and up to be 1.75x instead of 2x
	$game_variables[MASTERMODEVARS][29] = for each turn inbattle, the opponents gain +10% attack / special attack
	$game_variables[MASTERMODEVARS][30] = for each turn inbattle, the opponents gain +10% defense / special defense
=end

def switchestesting
	if !$game_variables[MASTERMODEVARS].is_a?(Array)
		$game_variables[MASTERMODEVARS] = []
	end
end

class Battle::Move
  alias old_pbCalcDamageMultipliers pbCalcDamageMultipliers
  def pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
		old_pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
		if !target.pbOwnedByPlayer?
			multipliers[:defense_multiplier] *= 1.3 if $game_variables[MASTERMODEVARS][9]==true
			multipliers[:defense_multiplier] *= 1.5 if $game_variables[MASTERMODEVARS][21]==true
			multipliers[:defense_multiplier] *= (1+target.turnCount/10.0) if $game_variables[MASTERMODEVARS][30]==true
			if physicalMove?
				multipliers[:final_damage_multiplier] *= 0.2 if $game_variables[MASTERMODEVARS][16]==true
			end
			if specialMove?
				multipliers[:final_damage_multiplier] *= 0.2 if $game_variables[MASTERMODEVARS][17]==true
			end
		end
		if !user.pbOwnedByPlayer?
			multipliers[:attack_multiplier] *= 1.3 if $game_variables[MASTERMODEVARS][8]==true
			multipliers[:attack_multiplier] *= 1.5 if $game_variables[MASTERMODEVARS][20]==true
			multipliers[:attack_multiplier] *= (1+target.turnCount/10.0) if $game_variables[MASTERMODEVARS][29]==true
			if physicalMove?
				multipliers[:attack_multiplier] *= 1.1 if $game_variables[MASTERMODEVARS][3]==true
			end
			if specialMove?
				multipliers[:attack_multiplier] *= 1.1 if $game_variables[MASTERMODEVARS][4]==true
			end
		end
	end # of pbCalcDamageMultipliers
end # of Battle::Move

class Battle::Battler
  alias old_pbCanInflictStatus? pbCanInflictStatus?
	def pbCanInflictStatus?(newStatus, user, showMessages, move = nil, ignoreStatus = false)
		return false if !pbOwnedByPlayer? && $game_variables[MASTERMODEVARS][5]==true
		old_pbCanInflictStatus?(newStatus, user, showMessages, move, ignoreStatus)
	end # of pbCanInflictStatus
	
  alias old_pbCanConfuse? pbCanConfuse?
	def pbCanConfuse?(user = nil, showMessages = true, move = nil, selfInflicted = false)
		return false if !pbOwnedByPlayer? && $game_variables[MASTERMODEVARS][6]==true
		old_pbCanConfuse?(user, showMessages, move, selfInflicted)
	end # of pbCanConfuse
	
  alias old_pbFlinch pbFlinch
	def pbFlinch(_user = nil)
		return false if !pbOwnedByPlayer? && $game_variables[MASTERMODEVARS][6]==true
		old_pbFlinch(_user)
	end # of pbFlinch
	
	alias old_trappedInBattle? trappedInBattle?
  def trappedInBattle?
		return false if !pbOwnedByPlayer? && $game_variables[MASTERMODEVARS][6]==true
		old_trappedInBattle?
	end # of trappedInBattle?
	
  def pbRecoverHP(amt, anim = true, anyAnim = true, damagemove = false)
    amt = amt.round
    amt = @totalhp - @hp if amt > @totalhp - @hp
    amt = 1 if amt < 1 && @hp < @totalhp
    oldHP = @hp
		#~ print amt
		if hasActiveItem?(:COLOGNECASE)
			amt3 = (damagemove) ? 0.3 : 0.2
			amt2 = ((10.0 - (amt/@totalhp))*amt3).floor
			amt += amt2
		end
		amt /= 2 if !pbOwnedByPlayer? && $game_variables[MASTERMODEVARS][12]==true
		#~ print amt
		amt = @totalhp - @hp if amt > @totalhp - @hp
    self.hp += amt
    PBDebug.log("[HP change] #{pbThis} gained #{amt} HP (#{oldHP}=>#{@hp})") if amt > 0
    raise _INTL("HP less than 0") if @hp < 0
    raise _INTL("HP greater than total HP") if @hp > @totalhp
    @battle.scene.pbHPChanged(self, oldHP, anim) if anyAnim && amt > 0
    @droppedBelowHalfHP = false if @hp >= @totalhp / 2
    return amt
  end

  def pbRecoverHPFromDrain(amt, target, msg = nil)
    if target.hasActiveAbility?(:LIQUIDOOZE)
      @battle.pbShowAbilitySplash(target)
      pbReduceHP(amt)
      @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!", pbThis))
      @battle.pbHideAbilitySplash(target)
      pbItemHPHealCheck
    else
      msg = _INTL("{1} had its energy drained!", target.pbThis) if nil_or_empty?(msg)
      @battle.pbDisplay(msg)
      if canHeal?
        amt = (amt * 1.3).floor if hasActiveItem?(:BIGROOT)
        pbRecoverHP(amt, true, true, true)
      end
    end
  end
end # of Battle::Battler

class Battle
	alias old_pbOnBattlerEnteringBattle pbOnBattlerEnteringBattle
  def pbOnBattlerEnteringBattle(battler_index, skip_event_reset = false, tileworker = false)
		old_pbOnBattlerEnteringBattle(battler_index, skip_event_reset, tileworker)
    pbPriority(true).each do |b|
			if !b.pbOwnedByPlayer? && $game_variables[MASTERMODEVARS][14]==true
				GameData::Stat.each_main_battle do |s|
					b.pbRaiseStatStageBasic(s.id, 1, true) if b.pbCanRaiseStatStage?(s.id, b)
				end
			end
			if b.pbOwnedByPlayer? && $game_variables[MASTERMODEVARS][15]==true
				GameData::Stat.each_main_battle do |s|
					b.pbRaiseStatStageBasic(s.id, 1, true) if b.pbCanLowerStatStage?(s.id, b)
				end
			end
			if !b.pbOwnedByPlayer? && $game_variables[MASTERMODEVARS][18]==true
				b.effects[PBEffects::AquaRing] = true
			end
		end
	end
end

EventHandlers.add(:on_trainer_load, :master_mode,
  proc { |trainer|
    if trainer
      trainer.party.each { |pkmn| 
				oldlevel = pkmn.level
				pkmn.level   += 10 if $game_variables[MASTERMODEVARS][7]==true
				pkmn.level   += 20 if $game_variables[MASTERMODEVARS][22]==true
				pkmn.level   += 30 if $game_variables[MASTERMODEVARS][24]==true
				pkmn.level   += 60 if $game_variables[MASTERMODEVARS][27]==true
				pkmn.iv[:HP] += 20 if $game_variables[MASTERMODEVARS][10]==true
				pkmn.iv[:HP] += 40 if $game_variables[MASTERMODEVARS][23]==true
				pkmn.iv[:HP] += 60 if $game_variables[MASTERMODEVARS][25]==true
				pkmn.iv[:HP] += 80 if $game_variables[MASTERMODEVARS][26]==true
				pkmn.calc_stats
			}
    end
  }
)

#===============================================================================
# Trapping move. Traps for 5 or 6 rounds. Trapped Pokémon lose 1/16 of max HP
# at end of each round.
#===============================================================================
class Battle::Move::BindTarget < Battle::Move
  def pbEffectAgainstTarget(user, target)
    return if target.fainted? || target.damageState.substitute
		
		return if !target.pbOwnedByPlayer? && $game_variables[MASTERMODEVARS][6]==true
		
    return if target.effects[PBEffects::Trapping] > 0
    # Set trapping effect duration and info
    if user.hasActiveItem?(:GRIPCLAW)
      target.effects[PBEffects::Trapping] = (Settings::MECHANICS_GENERATION >= 5) ? 8 : 6
    else
      target.effects[PBEffects::Trapping] = 5 #+ @battle.pbRandom(2)
    end
    target.effects[PBEffects::TrappingMove] = @id
    target.effects[PBEffects::TrappingUser] = user.index
    # Message
    msg = _INTL("{1} was trapped in the vortex!", target.pbThis)
    case @id
    when :BIND
      msg = _INTL("{1} was squeezed by {2}!", target.pbThis, user.pbThis(true))
    when :CLAMP
      msg = _INTL("{1} clamped {2}!", user.pbThis, target.pbThis(true))
    when :FIRESPIN
      msg = _INTL("{1} was trapped in the fiery vortex!", target.pbThis)
    when :INFESTATION
      msg = _INTL("{1} has been afflicted with an infestation by {2}!", target.pbThis, user.pbThis(true))
    when :MAGMASTORM
      msg = _INTL("{1} became trapped by Magma Storm!", target.pbThis)
    when :SANDTOMB
      msg = _INTL("{1} became trapped by Sand Tomb!", target.pbThis)
    when :WHIRLPOOL
      msg = _INTL("{1} became trapped in the vortex!", target.pbThis)
    when :WRAP
      msg = _INTL("{1} was wrapped by {2}!", target.pbThis, user.pbThis(true))
    end
    @battle.pbDisplay(msg)
  end
end