MAX_MOVES_FOR_BOSSES = 2
BOSS_NOCTAVISPA_MOVESET = [[:MEGAHORN, :POWERWHIP], # last phase
												  [:RAZORLEAF, :TOXIC]]   # second phase

class Pokemon
  attr_accessor :bossmonMutation
	# Enables Mega Evolution Mutation.
	bossmonMutation = false
	def enableBossPokemonMutation
		bossmonMutation = true
	end  
	# Disables Mega Evolution Mutation.
	def disableBossPokemonMutation
		bossmonMutation = false
	end    

	# Toggles Mega Evolution Mutation.
	def toggleBossPokemonMutation
		if !bossmonMutation
			bossmonMutation = true
		else	
			bossmonMutation = false
		end	
	end 		
	
	def isBossPokemon?
		if bossmonMutation==true || Settings::GLOBAL_MUTATION==true
			return true 
		end	
	end
end

class Battle::Battler
  def isBossPokemon?
    return (@pokemon) ? @pokemon.isBossPokemon? : false
  end
	
  def pbReduceHP(amt, anim = true, registerDamage = true, anyAnim = true)
    amt = amt.round
    amt = @hp if amt > @hp
    amt = 1 if amt < 1 && !fainted?
    oldHP = @hp
		if amt >= self.hp
			amt = self.hp
			if self.effects[PBEffects::RemaningHPBars]>0 && self.isBossPokemon?
				amt -= 1
				self.effects[PBEffects::RemaningHPBars]-=1
				self.pbRecoverHP((self.totalhp - 1), true)
				@battle.pbDisplay(_INTL("Enraged, {1} toughed out the hit!", self.pbThis))
			end
		end
    self.hp -= amt if amt > 0
    PBDebug.log("[HP change] #{pbThis} lost #{amt} HP (#{oldHP}=>#{@hp})") if amt > 0
    raise _INTL("HP less than 0") if @hp < 0
    raise _INTL("HP greater than total HP") if @hp > @totalhp
    @battle.scene.pbHPChanged(self, oldHP, anim) if anyAnim && amt > 0
    if amt > 0 && registerDamage
      @droppedBelowHalfHP = true if @hp < @totalhp / 2 && @hp + amt >= @totalhp / 2
      @tookDamageThisRound = true
    end
    return amt
  end
end

class Battle::FakeBattler
  def isBossPokemon?
    return (@pokemon) ? @pokemon.isBossPokemon? : false
  end
end

def convertMoves(moves)
  return moves.map do |m|
		#~ Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(m))
		Pokemon::Move.new(m) rescue nil
  end
end

def convertBattlerMoves(pokemon, movess)
	moves = convertMoves(movess)
	#~ for i in 1..MAX_MOVES_FOR_BOSSES
		#~ pokemon.moves[i] = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(movess[i])) if movess[i]
	#~ end
	return moves.map {|m| Battle::Move.from_pokemon_move(@battle, m)}
end

class Battle::Move
  def pbReduceDamage(user, target)
    damage = target.damageState.calcDamage
    # Substitute takes the damage
    if target.damageState.substitute
      damage = target.effects[PBEffects::Substitute] if damage > target.effects[PBEffects::Substitute]
      target.damageState.hpLost       = damage
      target.damageState.totalHPLost += damage
      return
    end
    # Disguise/Ice Face takes the damage
    return if target.damageState.disguise || target.damageState.iceFace
    # Target takes the damage
    if damage >= target.hp
      damage = target.hp
      # Survive a lethal hit with 1 HP effects
      if nonLethal?(user, target)
        damage -= 1
      elsif target.effects[PBEffects::Endure]
        target.damageState.endured = true
        damage -= 1
      elsif target.effects[PBEffects::RemaningHPBars]>0 && target.isBossPokemon?
        target.damageState.endured = true # reused, who is gonna give a boss mon endure anyway?
        damage -= 1
      elsif damage == target.totalhp
        if target.hasActiveAbility?(:STURDY) && !@battle.moldBreaker
          target.damageState.sturdy = true
          damage -= 1
        elsif target.hasActiveItem?(:FOCUSSASH) && target.hp == target.totalhp
          target.damageState.focusSash = true
          damage -= 1
        elsif target.hasActiveItem?(:FOCUSBAND) && @battle.pbRandom(100) < 10
          target.damageState.focusBand = true
          damage -= 1
        end
      end
    end
    damage = 0 if damage < 0
    target.damageState.hpLost       = damage
    target.damageState.totalHPLost += damage
		#~ target.pbRecoverHP((target.totalhp - 1), true) if target.damageState.endured && target.isBossPokemon?
  end

  def pbEndureKOMessage(target)
    if target.damageState.disguise
      @battle.pbShowAbilitySplash(target)
      if Battle::Scene::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("Its disguise served it as a decoy!"))
      else
        @battle.pbDisplay(_INTL("{1}'s disguise served it as a decoy!", target.pbThis))
      end
      @battle.pbHideAbilitySplash(target)
      target.pbChangeForm(1, _INTL("{1}'s disguise was busted!", target.pbThis))
      target.pbReduceHP(target.totalhp / 8, false) #if Settings::MECHANICS_GENERATION >= 8
    elsif target.damageState.iceFace
      @battle.pbShowAbilitySplash(target)
      if !Battle::Scene::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1}'s {2} activated!", target.pbThis, target.abilityName))
      end
      target.pbChangeForm(1, _INTL("{1} transformed!", target.pbThis))
      @battle.pbHideAbilitySplash(target)
    elsif target.damageState.endured
			if target.isBossPokemon? #by low
				if target.effects[PBEffects::RemaningHPBars]>0
					target.effects[PBEffects::RemaningHPBars]-=1
					target.pbRecoverHP((target.totalhp - 1), true)
					@battle.pbDisplay(_INTL("Enraged, {1} toughed out the hit!", target.pbThis))
=begin
					moveset = nil
					case target.species
						when :NOCTAVISPA
							moveset = BOSS_NOCTAVISPA_MOVESET
					end
					if !moveset.nil?
						target.moves = convertBattlerMoves(target, moveset[target.effects[PBEffects::RemaningHPBars]])
					end
=end
				end
			else
				@battle.pbDisplay(_INTL("{1} endured the hit!", target.pbThis))
			end
    elsif target.damageState.sturdy
      @battle.pbShowAbilitySplash(target)
      if Battle::Scene::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1} endured the hit!", target.pbThis))
      else
        @battle.pbDisplay(_INTL("{1} hung on with Sturdy!", target.pbThis))
      end
      @battle.pbHideAbilitySplash(target)
    elsif target.damageState.focusSash
      @battle.pbCommonAnimation("UseItem", target)
      @battle.pbDisplay(_INTL("{1} hung on using its Focus Sash!", target.pbThis))
      target.pbConsumeItem
    elsif target.damageState.focusBand
      @battle.pbCommonAnimation("UseItem", target)
      @battle.pbDisplay(_INTL("{1} hung on using its Focus Band!", target.pbThis))
    end
  end
end