class Pokemon
  attr_accessor :megaevoMutation
	################################################################################
	# Mega Evolution Mutation
	################################################################################ 
	# Enables Mega Evolution Mutation.
	@megaevoMutation = false
	def enableMegaEvoMutation
		@megaevoMutation = true
	end  
	# Disables Mega Evolution Mutation.
	def disableMegaEvoMutation
		@megaevoMutation = false
	end    

	# Toggles Mega Evolution Mutation.
	def toggleMegaEvoMutation
		if !@megaevoMutation
			@megaevoMutation = true
		else	
			@megaevoMutation = false
		end	
	end 		
	
	def hasMegaEvoMutation?
		if @megaevoMutation==true || Settings::GLOBAL_MUTATION==true
			return true 
		end	
	end
end

class Battle::Battler
  def hasMegaEvoMutation?
    return (@pokemon) ? @pokemon.hasMegaEvoMutation? : false
  end
  def willmega
    return @pokemon.willmega
  end
end
class Battle::FakeBattler
  def hasMegaEvoMutation?
    return (@pokemon) ? @pokemon.hasMegaEvoMutation? : false
  end
  def willmega
    return @pokemon.willmega
  end
end
class Battle
  def pbCanMegaEvolve?(idxBattler)
    return false if $game_switches[Settings::NO_MEGA_EVOLUTION]
    return true if $DEBUG && Input.press?(Input::CTRL)
    return false if @battlers[idxBattler].effects[PBEffects::SkyDrop] >= 0
    #~ return false if !pbHasMegaRing?(idxBattler)
		# MEM stuff #by low
		if !@battlers[idxBattler].hasMegaEvoMutation?
			return false if !@battlers[idxBattler].hasMega?
			return false if @battlers[idxBattler].mega?
			return false if @battlers[idxBattler].wild?
			side  = @battlers[idxBattler].idxOwnSide
			owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
			return @megaEvolution[side][owner] == -1
		end
		######################
    return true
  end
	
	def pbMegaEvolve(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.hasMega? || battler.mega?
    triggers = ["mega", "mega" + battler.species.to_s]
    battler.pokemon.types.each { |t| triggers.push("mega" + t.to_s) }
    @scene.pbDeluxeTriggers(idxBattler, nil, triggers)
    $stats.mega_evolution_count += 1 if battler.pbOwnedByPlayer?
    old_ability = battler.ability_id
    if battler.hasActiveAbility?(:ILLUSION)
      Battle::AbilityEffects.triggerOnBeingHit(battler.ability, nil, battler, nil, self)
    end
		# MEM stuff #by low
    if battler.wild? || battler.hasMegaEvoMutation?
		###################
      case battler.pokemon.megaMessage
      when 1
        pbDisplay(_INTL("{1} radiates with Mega energy!", battler.pbThis))
      else
        pbDisplay(_INTL("{1}'s {2}radiates with Mega energy!", battler.pbThis, battler.itemName))
      end
    else
      trainerName = pbGetOwnerName(idxBattler)
      case battler.pokemon.megaMessage
      when 1
        pbDisplay(_INTL("{1}'s fervent wish has reached {2}!", trainerName, battler.pbThis))
      else
        pbDisplay(_INTL("{1}'s {2} is reacting to {3}'s {4}!",
                        battler.pbThis, battler.itemName, trainerName, pbGetMegaRingName(idxBattler)))
      end
    end
    if @scene.pbCommonAnimationExists?("MegaEvolution")
      pbCommonAnimation("MegaEvolution", battler)
      battler.pokemon.makeMega
      battler.form = battler.pokemon.form
      @scene.pbChangePokemon(battler, battler.pokemon)
      pbCommonAnimation("MegaEvolution2", battler)
    else 
      if Settings::SHOW_MEGA_ANIM && $PokemonSystem.battlescene == 0
        @scene.pbShowMegaEvolution(idxBattler)
        battler.pokemon.makeMega
        battler.form = battler.pokemon.form
        @scene.pbChangePokemon(battler, battler.pokemon)
      else
        @scene.pbRevertBattlerStart(idxBattler)
        battler.pokemon.makeMega
        battler.form = battler.pokemon.form
        @scene.pbChangePokemon(battler, battler.pokemon)
        @scene.pbRevertBattlerEnd
      end
    end
    battler.pbUpdate(true)
    @scene.pbRefreshOne(idxBattler)
    megaName = battler.pokemon.megaName
    megaName = _INTL("Mega {1}", battler.pokemon.speciesName) if nil_or_empty?(megaName)
    pbDisplay(_INTL("{1} has Mega Evolved into {2}!", battler.pbThis, megaName))
		if battler.hasMegaEvoMutation?
			#nothing
		else
			side  = battler.idxOwnSide
			owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
			@megaEvolution[side][owner] = -2
		end
    if battler.isSpecies?(:GENGAR) && battler.mega?
      battler.effects[PBEffects::Telekinesis] = 0
    end
    battler.pbOnLosingAbility(old_ability)
    battler.pbTriggerAbilityOnGainingIt
    pbCalculatePriority(false, [idxBattler]) if Settings::RECALCULATE_TURN_ORDER_AFTER_MEGA_EVOLUTION && !$game_switches[OLDSCHOOLBATTLE]
    
    #increment achievement
    if battler.mega? && pbOwnedByPlayer?(battler)
      Achievements.incrementProgress("MEGA_EVOLUTIONS",1)
    end
    
  end
end

class Pokemon
  def getMegaForm
    ret = 0
    GameData::Species.each do |data|
      next if data.species != @species || data.unmega_form != form_simple
			# MEM stuff #by low
      if data.mega_stone && (hasItem?(data.mega_stone) || hasMegaEvoMutation?)
        ret = data.form
				if self.species == :BEAKRAFT
					case self.gender
						when 0 #male
							ret = 2
						when 1 #female
							ret = 3
						when 2 #genderless
							ret = 0 #what the fuck
					end
				end
        break
      elsif data.mega_move && (hasMove?(data.mega_move) || hasMegaEvoMutation?)
        ret = data.form
        break
      end
			###################
    end
    return ret   # form number, or 0 if no accessible Mega form
  end
end