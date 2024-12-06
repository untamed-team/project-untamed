class Battle::AI
  #=============================================================================
  # Get a score for the given move based on its effect
  #=============================================================================
  alias aiEffectScorePart1_pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode

  def pbGetMoveScoreFunctionCode(score, move, user, target, skill = 100)
	mold_broken = moldbroken(user,target,move)
	globalArray = pbGetMidTurnGlobalChanges
	aspeed = pbRoughStat(user,:SPEED,skill)
	ospeed = pbRoughStat(target,:SPEED,skill)
	userFasterThanTarget = ((aspeed>=ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
    case move.function
    #---------------------------------------------------------------------------
    when "SleepTarget", "SleepTargetIfUserDarkrai", "SleepTargetChangeUserMeloettaForm" # hypnosis
		if canSleepTarget(user,target,globalArray,true)
			miniscore = pbTargetBenefitsFromStatus?(user, target, :SLEEP, 140, move, globalArray, 100)
			ministat=0
			ministat+=target.stages[:ATTACK]
			ministat+=target.stages[:DEFENSE]
			ministat+=target.stages[:SPECIAL_ATTACK]
			ministat+=target.stages[:SPECIAL_DEFENSE]
			ministat+=target.stages[:SPEED]
			ministat+=target.stages[:ACCURACY]
			ministat+=target.stages[:EVASION]
			if ministat>0
				minimini=5*ministat
				minimini+=100
				minimini/=100.0
				miniscore*=minimini
			end
			if move.baseDamage>0
				miniscore-=100
				if move.addlEffect.to_f != 100
					miniscore*=(move.addlEffect.to_f/100.0)
					miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
				end
				miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
				miniscore+=100
			else
				@battle.pbParty(target.index).each do |i|
					next if i.nil? || i.egg? || i.status != :SLEEP || i.hasMove?(:SLEEPTALK)
					miniscore*=0.4 if (i.hp/i.totalhp.to_f)>0.3
				end
			end
			score *= (miniscore / 100.0)
		else
			score = 0 if move.baseDamage == 0
		end
    #---------------------------------------------------------------------------
    when "SleepTargetNextTurn" # yawn
		if canSleepTarget(user,target,globalArray,true) && target.effects[PBEffects::Yawn]<=0
			miniscore = pbTargetBenefitsFromStatus?(user, target, :SLEEP, 120, move, globalArray, 100)
			ministat=0
			ministat+=target.stages[:ATTACK]
			ministat+=target.stages[:DEFENSE]
			ministat+=target.stages[:SPECIAL_ATTACK]
			ministat+=target.stages[:SPECIAL_DEFENSE]
			ministat+=target.stages[:SPEED]
			ministat+=target.stages[:ACCURACY]
			ministat+=target.stages[:EVASION]
			if ministat>0
				minimini=5*ministat
				minimini+=100
				minimini/=100.0
				miniscore*=minimini
			end
			if target.trappedInBattle?
				miniscore*=1.2
			else
				miniscore*=1.1 if target.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
				miniscore*=1.2 if target.pbOwnSide.effects[PBEffects::StealthRock]
				if target.pbOwnSide.effects[PBEffects::Spikes] > 0
					miniscore*=(1.1**target.pbOwnSide.effects[PBEffects::Spikes])
				end
				miniscore*=0.7 if target.hasActiveAbility?([:INTIMIDATE, :GRIMTEARS])
				miniscore*=0.6 if target.hasActiveAbility?([:REGENERATOR, :NATURALCURE])
			end
			score *= (miniscore / 100.0)
		else
			score = 0 if move.baseDamage == 0
		end
    #---------------------------------------------------------------------------
    when "PoisonTarget", "BadPoisonTarget", "CategoryDependsOnHigherDamagePoisonTarget" 
		# poison moves, toxic, shell side arm
		if target.pbCanPoison?(user, false)
			miniscore = pbTargetBenefitsFromStatus?(user, target, :POISON, 100, move, globalArray, 100)
			ministat=0
			ministat+=target.stages[:DEFENSE]
			ministat+=target.stages[:SPECIAL_DEFENSE]
			ministat+=target.stages[:EVASION]
			if ministat>0
				minimini=5*ministat
				minimini+=100
				minimini/=100.0
				miniscore*=minimini
			end
			miniscore*=1.2 if user.moves.any? { |m| m&.healingMove? }
			if move.baseDamage>0
				miniscore-=100
				if move.addlEffect.to_f != 100
					miniscore*=(move.addlEffect.to_f/100.0)
					miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
				end
				miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
				miniscore+=100
				miniscore/=100.0
				score*=miniscore
			else
				miniscore/=100.0
				score*=miniscore
			end
		else
			score = 0 if move.statusMove?
    	end
    #---------------------------------------------------------------------------
    when "PoisonTargetLowerTargetSpeed1" # Toxic Thread
		roles = pbGetPokemonRole(user, target)
		if target.pbCanPoison?(user, false)
			miniscore = pbTargetBenefitsFromStatus?(user, target, :POISON, 110, move, globalArray, skill)
			miniscore*=1.2
			ministat=0
			ministat+=target.stages[:DEFENSE]
			ministat+=target.stages[:SPECIAL_DEFENSE]
			ministat+=target.stages[:EVASION]
			if ministat>0
				minimini=5*ministat
				minimini+=100
				minimini/=100.0
				miniscore*=minimini
			end
			if roles.include?("Physical Wall") || roles.include?("Special Wall")
				miniscore*=1.5
			end
			if user.pbHasMove?(:VENOSHOCK) || user.pbHasMove?(:VENOMDRENCH) || user.pbHasMove?(:HEX) || 
			   user.hasActiveAbility?(:MERCILESS)
				miniscore*=1.6
			end
			miniscore/=100.0
			score*=miniscore
     	end
		allOutspeed = userFasterThanTarget
		if user.allAllies.any?
			user.allAllies.each do |b|
				user.allOpposing.each do |z|
					if (pbRoughStat(b,:SPEED,skill)<pbRoughStat(z,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
						allOutspeed = false
						break
					end
				end
				break if !allOutspeed
			end
		end
		if allOutspeed || !target.pbCanLowerStatStage?(:SPEED)
			score*=0.5
		else          
			miniscore=110
			if roles.include?("Physical Wall") || roles.include?("Special Wall")
				miniscore*=1.1
			end
			userlivecount   = @battle.pbAbleNonActiveCount(user.idxOwnSide)
			targetlivecount = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
			if targetlivecount==0 || user.hasActiveAbility?([:SHADOWTAG, :ARENATRAP]) || target.effects[PBEffects::MeanLook]>0
				miniscore*=1.4
			end
			if target.stages[:SPEED]!=0
				minimini = 5*target.stages[:SPEED]
				minimini *= 1.1 if move.baseDamage==0
				minimini+=100
				minimini/=100.0
				miniscore*=minimini
			end       
			if userlivecount==1
				miniscore*=0.5
			end
			if target.hasActiveAbility?([:UNAWARE, :DEFIANT, :COMPETITIVE, :CONTRARY])
				miniscore*=0.1
			end
			if target.hasActiveAbility?(:SPEEDBOOST)
				miniscore*=0.5
			end
			if user.pbHasMove?(:ELECTROBALL)
				miniscore*=1.5
			end  
			if user.pbHasMove?(:GYROBALL)
				miniscore*=0.5
			end   
			if @battle.field.effects[PBEffects::TrickRoom]!=0
				miniscore*=0.1
			else
				miniscore*=0.1 if target.moves.any? { |j| j&.id == :TRICKROOM }
			end   
			if target.hasActiveItem?(:LAGGINGTAIL) || target.hasActiveItem?(:IRONBALL)
				miniscore*=0.1
			end
			miniscore*=1.3 if target.moves.any? { |j| j&.id == :ELECTROBALL }
			miniscore*=0.5 if target.moves.any? { |j| j&.id == :GYROBALL }
			miniscore*=0.7 if userFasterThanTarget    
			miniscore/=100.0    
			score*=miniscore
		end
    #---------------------------------------------------------------------------
    when "ParalyzeTarget", "ParalyzeTargetIfNotTypeImmune",
         "ParalyzeTargetAlwaysHitsInRainHitsTargetInSky", "ParalyzeFlinchTarget"
		# paralysis moves, Thunder Wave, Thunder
		if target.pbCanParalyze?(user, false)
			miniscore = pbTargetBenefitsFromStatus?(user, target, :PARALYSIS, 120, move, globalArray, skill)
			if aspeed < ospeed
				miniscore *= 1.2
			elsif aspeed > ospeed
				miniscore *= 0.8
			end
			if pbHasSetupMove?(user, false)
				miniscore*=1.1
			end
			if target.hp==target.totalhp
				miniscore*=1.2
			end
			ministat=0
			ministat+=target.stages[:ATTACK]
			ministat+=target.stages[:SPECIAL_ATTACK]
			ministat+=target.stages[:SPEED]
			if ministat>0
				minimini=5*ministat
				minimini+=100
				minimini/=100.0
				miniscore*=minimini
			end
			count=0
			@battle.pbParty(user.index).each do |i|
				next if i.nil?
				count+=1
				next if count==user.pokemonIndex
				temproles = pbGetPokemonRole(i, target, count, @battle.pbParty(user.index))
				if temproles.include?("Sweeper")
					sweepvar = true
				end
			end
			if move.baseDamage>0
				if move.addlEffect.to_f == 100
					if !user.hasActiveAbility?(:SHEERFORCE) && move.id == :NUZZLE
						score*=1.37 # twave's usual score boost
						score*=1.1 if target.moves.any? { |j| j&.id == :TAUNT }
					end
				else
					miniscore-=100
					miniscore*=(move.addlEffect.to_f/100.0)
					miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
					miniscore+=100
				end
				miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
			end
			miniscore/=100.0
			score*=miniscore
		else
			score = 0 if move.statusMove?
		end
		if move.function == "ParalyzeTargetIfNotTypeImmune" &&
		   Effectiveness.ineffective?(pbCalcTypeMod(move.type, user, target))
			score = 0
		end
		if move.function == "ParalyzeTargetAlwaysHitsInRainHitsTargetInSky"
			if userFasterThanTarget && 
				target.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
										"TwoTurnAttackInvulnerableInSkyParalyzeTarget",
										"TwoTurnAttackInvulnerableInSkyTargetCannotAct")
				score *= 1.5
			end
			score*=1.2 if target.moves.any? { |j| [:BOUNCE,:FLY,:SKYDROP].include?(j&.id) }
		end
		if move.function == "ParalyzeFlinchTarget"
			if canFlinchTarget(user,target,mold_broken)
				if userFasterThanTarget
					score*=1.1
				end
				if target.hasActiveAbility?(:STEADFAST)
					score*=0.3
				end            
			end
		end
    #---------------------------------------------------------------------------
    when "BurnTarget", "BurnTargetIfTargetStatsRaisedThisTurn", "BurnFlinchTarget"
		# burning moves, Burning Jealousy (shouldn't be here but who will use that trash move anyway kekeros)
		if target.pbCanBurn?(user, false)
			miniscore = pbTargetBenefitsFromStatus?(user, target, :BURN, 110, move, globalArray, 100)
			ministat=0
			ministat+=target.stages[:SPECIAL_ATTACK]
			ministat+=target.stages[:SPECIAL_DEFENSE]
			ministat+=target.stages[:SPEED]
			if ministat>0
				minimini=5*ministat
				minimini+=100
				minimini/=100.0
				miniscore*=minimini
			end
			if move.baseDamage>0
				miniscore-=100
				if move.addlEffect.to_f != 100
					miniscore*=(move.addlEffect.to_f/100.0)
					miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
				end
				miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
				miniscore+=100
			end
			miniscore/=100.0
			if move.function == "BurnTargetIfTargetStatsRaisedThisTurn"
				if !userFasterThanTarget && pbHasSetupMove?(target) && targetWillMove?(target)
					score*=(miniscore*0.75)
				end
			else
				score*=miniscore
			end
		else
			score = 0 if move.statusMove?
     	end
		if move.function == "BurnFlinchTarget"
			if canFlinchTarget(user,target,mold_broken)
				if userFasterThanTarget
					score*=1.1
				end
				if target.hasActiveAbility?(:STEADFAST)
					score*=0.3
				end            
			end
		end
    #---------------------------------------------------------------------------
    when "FreezeTarget", "FreezeFlinchTarget", "FreezeTargetAlwaysHitsInHail",
		 "FreezeTargetSuperEffectiveAgainstWater"
		 # biting cold, ice fang, freeze dry, blizzard
		if target.pbCanFreeze?(user, false)
			miniscore = pbTargetBenefitsFromStatus?(user, target, :FREEZE, 110, move, globalArray, 100)
			ministat=0
			ministat+=target.stages[:SPECIAL_ATTACK]
			ministat+=target.stages[:SPECIAL_DEFENSE]
			ministat+=target.stages[:SPEED]
			if ministat>0
				minimini=5*ministat
				minimini+=100
				minimini/=100.0
				miniscore*=minimini
			end
			if move.baseDamage>0
				miniscore-=100
				if move.addlEffect.to_f != 100
					miniscore*=(move.addlEffect.to_f/100.0)
					miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
				end
				miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
				miniscore+=100
			end
			miniscore/=100.0
			score*=miniscore
		else
			score = 0 if move.statusMove?
      	end
		if move.function == "FreezeFlinchTarget"
			if canFlinchTarget(user,target,mold_broken)
				if userFasterThanTarget
					score*=1.1
				end
				if target.hasActiveAbility?(:STEADFAST)
					score*=0.3
				end            
			end
		end
    #---------------------------------------------------------------------------
    when "ParalyzeBurnOrFreezeTarget" # tri attack
		if !target.pbHasAnyStatus?
			miniscore=140
			ministat=0
			ministat+=target.stages[:ATTACK]
			ministat+=target.stages[:DEFENSE]
			ministat+=target.stages[:SPECIAL_ATTACK]
			ministat+=target.stages[:SPECIAL_DEFENSE]
			ministat+=target.stages[:SPEED]
			ministat+=target.stages[:ACCURACY]
			ministat+=target.stages[:EVASION]
			if ministat>0
				minimini=5*ministat
				minimini+=100
				minimini/=100.0
				miniscore*=minimini
			end
			if target.hasActiveAbility?(:QUICKFEET) || target.hasActiveAbility?(:GUTS)
				miniscore*=0.3
			end  
			miniscore-=100
			if move.addlEffect.to_f != 100
				miniscore*=(move.addlEffect.to_f/100.0)
				miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
			end
			miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
			miniscore+=100
			miniscore/=100.0       
			score*=miniscore
		end
    #---------------------------------------------------------------------------
    when "GiveUserStatusToTarget" # Psycho Shift
		if user.pbHasAnyStatus?
			score*=1.3
			if !target.pbHasAnyStatus? && target.effects[PBEffects::Yawn]==0
				score*=1.3
				if user.burned? && target.pbCanBurn?(user, false)
					if pbRoughStat(target,:ATTACK,skill)>pbRoughStat(target,:SPECIAL_ATTACK,skill)
						score*=1.2
					end
					if target.hasActiveAbility?([:FLAREBOOST, :GUTS])
						score*=0.2
					end
					miniscore = pbTargetBenefitsFromStatus?(user, target, :BURN, 110, move, globalArray, skill)
					score*=(miniscore/100.0)
				end
				if user.paralyzed? && target.pbCanParalyze?(user, false)
					if !userFasterThanTarget
						score*=1.2
					end
					miniscore = pbTargetBenefitsFromStatus?(user, target, :PARALYSIS, 120, move, globalArray, skill)
					score*=(miniscore/100.0)
				end
				if user.poisoned? && target.pbCanPoison?(user, false)
					score*=1.1 if user.moves.any? { |m| m&.healingMove? }
					if user.effects[PBEffects::Toxic]>0
						score*=1.4
					end
					miniscore = pbTargetBenefitsFromStatus?(user, target, :POISON, 100, move, globalArray, skill)
					score*=(miniscore/100.0)
				end
				if user.frozen? && target.pbCanFreeze?(user, false)
					if pbRoughStat(target,:ATTACK,skill)<pbRoughStat(target,:SPECIAL_ATTACK,skill)
						score*=1.2
					end
					miniscore = pbTargetBenefitsFromStatus?(user, target, :FREEZE, 110, move, globalArray, skill)
					score*=(miniscore/100.0)
				end
				if user.dizzy? && target.pbCanDizzy?(user, false)
					if target.hasActiveAbility?(:TANGLEDFEET)
						score*=0.2
					end
					miniscore = pbTargetBenefitsFromStatus?(user, target, :DIZZY, 110, move, globalArray, skill)
					score*=(miniscore/100.0)
				end
			else
				score = 0  
			end
			if user.pbHasMoveFunction?("DoublePowerIfTargetStatusProblem")
				score*=1.3
			end
		else
			score=0
		end
#---------------------------------------------------------------------------
    when "CureUserBurnPoisonParalysis" # refresh
		if user.burned? || user.poisoned? || user.paralyzed? #|| user.frozen?
			score*=3
			if (user.hp.to_f)/user.totalhp>0.5
				score*=1.5
			else
				score*=0.3
			end
			if target.effects[PBEffects::Yawn]>0
				score*=0.1
			end      
			bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
			maxdam = bestmove[0]
			if maxdam>user.hp
				score*=0.1
			end
			if target.effects[PBEffects::Toxic]>2
				score*=1.3
			end   
			score*=1.3 if target.pbHasMoveFunction?("DoublePowerIfTargetStatusProblem")
		else
			score=0
		end
    #---------------------------------------------------------------------------
    when "CureUserPartyStatus" # aromatherapy
		statuses = 0
		@battle.pbParty(user.index).each do |pkmn|
			statuses += 1 if pkmn && pkmn.status != :NONE
		end
		if statuses!=0
			score*=1.2
			statuses=0
			count=-1
			@battle.pbParty(user.index).each do |i|
				count+=1
				temproles = pbGetPokemonRole(i, target, count, @battle.pbParty(user.index))
				if i.status==:POISON && i.ability == :POISONHEAL
					score*=0.5
				end
				if i.ability == :GUTS || i.ability == :QUICKFEET || i.hasMove?(:FACADE)
					score*=0.8
				end
				if i.status==:SLEEP
					score*=1.1
				end
				if (temproles.include?("Physical Wall") || temproles.include?("Special Wall")) && i.status==:POISON
					score*=1.2
				end
				if temproles.include?("Sweeper") && i.status==:PARALYSIS
					score*=1.2
				end
				if i.attack>i.spatk && i.status==:BURN
					score*=1.2
				end
				if i.attack<i.spatk && i.status==:FROZEN
					score*=1.2
				end
			end
			if user.pbHasAnyStatus?
				score*=1.3
			end
			if user.effects[PBEffects::Toxic]>2
				score*=1.3
			end
			score*=1.1 if user.moves.any? { |m| m&.healingMove? } 
			score*=1.1 if target.moves.any? { |m| m&.healingMove? } 
		else
			score=0
		end
    #---------------------------------------------------------------------------
    when "CureTargetBurn" # Sparkling Aria
		if user.opposes?(target)
			score -= 40 if target.status == :BURN
		elsif target.status == :BURN
			score -= 40
		end
    #---------------------------------------------------------------------------
    when "StartUserSideImmunityToInflictedStatus" # Safeguard
		roles = pbGetPokemonRole(user, target)
		if user.pbOwnSide.effects[PBEffects::Safeguard]<=0 && userFasterThanTarget && 
		  (!user.pbHasAnyStatus? && !roles.include?("Status Absorber")) 
			ebinstatuscheck = target.moves.any? { |j| [:WILLOWISP, :BITINGCOLD, :TOXIC, :THUNDERWAVE, :GLARE, :NUZZLE, :STUNSPORE].include?(j&.id) }
			statuscheck     = target.moves.any? { |j| [:POISONPOWDER, :POISONGAS, :CONFUSERAY].include?(j&.id) }
			sleepcheck      = target.moves.any? { |j| [:SPORE, :SLEEPPOWDER, :LOVELYKISS, :HYPNOSIS, :GRASSWHISTLE, :DARKVOID].include?(j&.id) }
			statusrng       = target.moves.any? { |m| m&.baseDamage > 0 && ["BurnTarget", "ParalyzeTarget", "FreezeTarget", "SleepTarget", "SleepTargetChangeUserMeloettaForm", "PoisonTarget", "BadPoisonTarget"].include?(m&.function) }
			score*=1.7 if sleepcheck
			score*=1.2 if statuscheck
			score*=1.5 if ebinstatuscheck
			score*=1.2 if statusrng
			score*=1.5 if (sleepcheck || statuscheck || ebinstatuscheck) && 
			              targetWillMove?(target,"status")
			score*=1.3 if user.hasActiveItem?(:LIGHTCLAY) || roles.include?("Screener")
			score*=0.3 if !sleepcheck && !statuscheck && !ebinstatuscheck
		else
			score=0
		end
    #---------------------------------------------------------------------------
    when "FlinchTarget", "FlinchTargetDoublePowerIfTargetInSky" # flinching moves, twister
		if canFlinchTarget(user,target,mold_broken)
			if userFasterThanTarget
				miniscore=100
				miniscore*=1.3
				if target.poisoned? || target.burned? || target.frozen? || (user.takesHailDamage? && !user.takesSandstormDamage?) || 
				   target.effects[PBEffects::LeechSeed]>-1 || target.effects[PBEffects::Curse]
					miniscore*=1.1
					if target.effects[PBEffects::Toxic]>0
						miniscore*=1.2
					end
				end            
				if target.hasActiveAbility?(:STEADFAST)
					miniscore*=0.3
				end
				miniscore-=100
				if move.addlEffect.to_f != 100
					miniscore*=(move.addlEffect.to_f/100.0)
					miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
				end
				miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
				miniscore+=100
				miniscore/=100.0       
				score*=miniscore             
			end
		end
		if move.function == "FlinchTargetDoublePowerIfTargetInSky"
			if userFasterThanTarget && 
				target.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
										"TwoTurnAttackInvulnerableInSkyParalyzeTarget",
										"TwoTurnAttackInvulnerableInSkyTargetCannotAct")
				score *= 1.5
			end
			score*=1.2 if target.moves.any? { |j| [:BOUNCE,:FLY,:SKYDROP].include?(j&.id) }
		end
    #---------------------------------------------------------------------------
    when "FlinchTargetFailsIfUserNotAsleep" # snore
		if user.asleep?
			if user.statusCount <= 1
				score = 0
			else
				score *= 2
				if canFlinchTarget(user,target,mold_broken)
					if userFasterThanTarget
						miniscore=100
						miniscore*=1.3
						if target.poisoned? || target.burned? || target.frozen? || (user.takesHailDamage? && !user.takesSandstormDamage?) || 
								target.effects[PBEffects::LeechSeed]>-1 || target.effects[PBEffects::Curse]
							miniscore*=1.1
							if target.effects[PBEffects::Toxic]>0
								miniscore*=1.2
							end
						end            
						if target.hasActiveAbility?(:STEADFAST)
							miniscore*=0.3
						end
						miniscore-=100
						if move.addlEffect.to_f != 100
							miniscore*=(move.addlEffect.to_f/100.0)
							miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
						end
						miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
						miniscore+=100
						miniscore/=100.0       
						score*=miniscore             
					end
				end
			end
		else
			score = 0
		end
    #---------------------------------------------------------------------------
    when "FlinchTargetFailsIfNotUserFirstTurn" # fake out
		if user.turnCount==0
			if canFlinchTarget(user,target,mold_broken)
				if !userFasterThanTarget && !target.hasActiveAbility?(:STEADFAST)
					score*=1.2
				end
				if user.hasActiveItem?(:NORMALGEM)
					score*=1.1
					score*=2.0 if user.hasActiveAbility?(:UNBURDEN)
				end          
				score*=0.03 if target.hasActiveAbility?(:STEADFAST)
				score*=0.3 if user.hasActiveAbility?(:SHEERFORCE)
				# try to negate a turn of powered up stab
				if target.pokemon.willmega
					if targetWillMove?(target)
						protectarray = ["ProtectUser", "ProtectUserBanefulBunker", 
										"ProtectUserFromTargetingMovesSpikyShield", 
										"ProtectUserFromDamagingMovesKingsShield",
										"ProtectUserFromDamagingMovesObstruct"]
				  		if !protectarray.include?(@battle.choices[target.index][2].function)
							score*=2 if globalArray.any? { |element| element.include?("weather") }
							score*=2 if globalArray.any? { |element| element.include?("terrain") }
						end
					end
				end
				score*=30 # fake out good 
			end
		else
			score=0
		end
    #---------------------------------------------------------------------------
    when "ConfuseTarget", "ConfuseTargetAlwaysHitsInRainHitsTargetInSky"
		# confusion moves / hurricane
		if target.pbCanConfuse?(user, false)
			if $player.difficulty_mode?("chaos")
				miniscore = pbTargetBenefitsFromStatus?(user, target, :DIZZY, 100, move, globalArray, skill)
			else
				miniscore = 100
				if target.paralyzed?
					miniscore*=1.3
				end
			end
			if target.effects[PBEffects::Attract]>=0
				miniscore*=1.3
			end
			if target.effects[PBEffects::Yawn]>0 || target.asleep?
				miniscore*=0.4
			end
			if target.hasActiveAbility?(:CONTRARY)
				miniscore*=1.5
			end
			if user.pbHasMove?(:SUBSTITUTE)
				miniscore*=1.2
				if user.effects[PBEffects::Substitute]>0
					miniscore*=1.3
				end
			end
			# confusion/dizzy with hurricane is unlikely for chaos mode, so skip applying the calc
			if move.baseDamage>0
				miniscore-=100
				if move.addlEffect.to_f != 100
					miniscore*=(move.addlEffect.to_f/100.0)
					miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
				end
				miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
				miniscore+=100
				miniscore/=100.0
				miniscore = 1 if move.function == "ConfuseTargetAlwaysHitsInRainHitsTargetInSky" && $player.difficulty_mode?("chaos")
				score*=miniscore
			else
				miniscore/=100.0
				score*=miniscore
			end
		else
			score = 0 if move.statusMove?
		end
		if move.function == "ConfuseTargetAlwaysHitsInRainHitsTargetInSky"
			if userFasterThanTarget && 
				target.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
										"TwoTurnAttackInvulnerableInSkyParalyzeTarget",
										"TwoTurnAttackInvulnerableInSkyTargetCannotAct")
				score *= 1.5
			end
			score*=1.2 if target.moves.any? { |j| [:BOUNCE,:FLY,:SKYDROP].include?(j&.id) }
		end
    #---------------------------------------------------------------------------
    when "AttractTarget" # Attract
    	score = 0
    #---------------------------------------------------------------------------
    when "SetUserTypesBasedOnEnvironment" # Camouflage
		if !user.canChangeType?
			score -= 90
		elsif skill >= PBTrainerAI.mediumSkill
			new_type = nil
			case @battle.field.terrain
			when :Electric
				new_type = :ELECTRIC if GameData::Type.exists?(:ELECTRIC)
			when :Grassy
				new_type = :GRASS if GameData::Type.exists?(:GRASS)
			when :Misty
				new_type = :FAIRY if GameData::Type.exists?(:FAIRY)
			when :Psychic
				new_type = :PSYCHIC if GameData::Type.exists?(:PSYCHIC)
			end
			if !new_type
				envtypes = {
					:None        => :NORMAL,
					:Grass       => :GRASS,
					:TallGrass   => :GRASS,
					:MovingWater => :WATER,
					:StillWater  => :WATER,
					:Puddle      => :WATER,
					:Underwater  => :WATER,
					:Cave        => :ROCK,
					:Rock        => :GROUND,
					:Sand        => :GROUND,
					:Forest      => :BUG,
					:ForestGrass => :BUG,
					:Snow        => :ICE,
					:Ice         => :ICE,
					:Volcano     => :FIRE,
					:Graveyard   => :GHOST,
					:Sky         => :FLYING,
					:Space       => :DRAGON,
					:UltraSpace  => :PSYCHIC
				}
				new_type = envtypes[@battle.environment]
				new_type = nil if !GameData::Type.exists?(new_type)
				new_type ||= :NORMAL
			end
			score -= 90 if !user.pbHasOtherType?(new_type)
		end
    #---------------------------------------------------------------------------
    when "SetUserTypesToResistLastAttack" # Conversion 2
		# the scoring for this move was using the user to calculate the target's last move type
		# this means that if the user had galvanize and the target's last move was normal
		# this very well tested code would have said "hey he just used a electric attack"
		# ffs essentials
		if !user.canChangeType?
			score -= 90
		elsif !target.lastMoveUsed || !target.lastMoveUsedType ||
				GameData::Type.get(target.lastMoveUsedType).pseudo_type
			score -= 90
		else
			aType = nil
			target.eachMove do |m|
				next if m.id != target.lastMoveUsed
				aType = m.pbCalcType(target)
				break
			end
			if aType
				has_possible_type = false
				GameData::Type.each do |t|
					next if t.pseudo_type || user.pbHasType?(t.id, true) ||
							!Effectiveness.resistant_type?(target.lastMoveUsedType, t.id)
					has_possible_type = true
					break
				end
				score -= 90 if !has_possible_type
			else
				score -= 90
			end
		end
    #---------------------------------------------------------------------------
    when "SetUserTypesToTargetTypes" # Reflect Type
		if !user.canChangeType? || target.pbTypes(true).length == 0
			score -= 90
		elsif user.pbTypes == target.pbTypes &&
				user.effects[PBEffects::Type3] == target.effects[PBEffects::Type3]
			score -= 90
		end
    #---------------------------------------------------------------------------
    when "SetUserTypesToUserMoveType" # Conversion (you cant say that, d*scord will think its le bad!)
		if user.canChangeType?
			has_possible_type = false
			user.eachMoveWithIndex do |m, i|
				break if Settings::MECHANICS_GENERATION >= 6 && i > 0
				next if GameData::Type.get(m.type).pseudo_type
				next if user.pbHasType?(m.type, true)
				has_possible_type = true
				break
			end
			score -= 90 if !has_possible_type
		else
			score -= 90
		end
    #---------------------------------------------------------------------------
    when "SetTargetTypesToPsychic" # Magic Powder
		if user.moves.any? { |m| [:DARK, :GHOST].include?(m&.type) }
			score*=1.5
		else
			score*=0.7
		end
		roles = pbGetPokemonRole(user, target)
		if roles.include?("Physical Wall") || roles.include?("Special Wall")
			if user.pbHasMove?(:TOXIC)
				if target.pbHasType?(:STEEL, true) || target.pbHasType?(:POISON, true)
					score*=1.5
				end
			end
		end
		if target.moves.any? { |j| j.type == :PSYCHIC }
			score*=0.5
		else
			score*=1.1
		end
		if target.pbHasOtherType?(:PSYCHIC)
			score=0
		end
		if !target.canChangeType?
			score=0
		end
    #---------------------------------------------------------------------------
    when "SetTargetTypesToWater" # soak
		if user.moves.any? { |m| [:ELECTRIC, :GRASS].include?(m&.type) }
			score*=1.5
		else
			score*=0.7
		end
		roles = pbGetPokemonRole(user, target)
		if roles.include?("Physical Wall") || roles.include?("Special Wall")
			if user.pbHasMove?(:TOXIC)
				if target.pbHasType?(:STEEL, true) || target.pbHasType?(:POISON, true)
					score*=1.5
				end
			end
		end
		if target.moves.any? { |j| j.type == :WATER }
			score*=0.5
		else
			score*=1.1
		end
		if target.pbHasOtherType?(:WATER)
			score=0
		end
		if !target.canChangeType?
			score = 0
		end
    #---------------------------------------------------------------------------
    when "AddGhostTypeToTarget" # Trick or Treat
		if user.moves.any? { |m| [:DARK, :GHOST].include?(m&.type) }
			score*=1.5
		else
			score*=0.7
		end
		roles = pbGetPokemonRole(user, target)
		if roles.include?("Physical Wall") || roles.include?("Special Wall")
			if user.pbHasMove?(:TOXIC) && (target.pbHasType?(:STEEL, true) || target.pbHasType?(:POISON, true))
				score*=1.5
			end
		end
		if target.moves.any? { |j| j.type == :GHOST }
			score*=0.5
		else
			score*=1.1
		end
		if target.pbHasType?(:GHOST, true) || !target.canChangeType? || 
				target.hasActiveAbility?([:PROTEAN, :COLORCHANGE])
			score*=0
		end
    #---------------------------------------------------------------------------
    when "AddGrassTypeToTarget" # Forest's Curse
		# compare this to soak, damn
		if user.moves.any? { |m| [:FIRE, :ICE, :BUG, :FLYING, :POISON].include?(m&.type) }
			score*=1.5
		else
			score*=0.7
		end
		roles = pbGetPokemonRole(user, target)
		if roles.include?("Physical Wall") || roles.include?("Special Wall")
			if user.pbHasMove?(:TOXIC) && (target.pbHasType?(:STEEL, true) || target.pbHasType?(:POISON, true))
				score*=1.5
			end
		end
		if target.moves.any? { |j| j.type == :GRASS }
			score*=0.5
		else
			score*=1.1
		end
		if target.pbHasType?(:GRASS, true) || !target.canChangeType? || 
				target.hasActiveAbility?([:PROTEAN, :COLORCHANGE])
			score*=0
		end
    #---------------------------------------------------------------------------
    when "UserLosesFireType" # burn up
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		maxmove=bestmove[1]
		maxtype=maxmove.type
		if !user.pbHasType?(:FIRE, true)
			score = 0
		else
			miniscore=100
			userlivecount 	= @battle.pbAbleNonActiveCount(user.idxOwnSide)
			targetlivecount = @battle.pbAbleCount(user.idxOpposingSide)
			if targetSurvivesMove(move,user,target)
				score*=0.9
				score*=0.5 if target.moves.any? { |m| m&.healingMove? }
			else
				targetlivecount -= 1
			end
			if targetlivecount!=0
				miniscore*=targetlivecount
				miniscore/=100.0
				miniscore*=0.05
				miniscore = 1-miniscore
				score*=miniscore
			end
			if userlivecount==0 && targetlivecount!=0
				score*=0.7
			end
			targetTypes = target.pbTypes(true)
			effcheck = Effectiveness.calculate(targetTypes[0], :FIRE, :FIRE, :FIRE)
			if effcheck > 4
				score*=1.5
			else            
				if effcheck<4
					score*=0.5
				end
			end
			effcheck = Effectiveness.calculate(targetTypes[1], :FIRE, :FIRE, :FIRE)
			if effcheck > 4
				score*=1.5
			else            
				if effcheck<4
					score*=0.5
				end
			end
			effcheck = Effectiveness.calculate(targetTypes[2], :FIRE, :FIRE, :FIRE)
			if effcheck > 4
				score*=1.5
			else            
				if effcheck<4
					score*=0.5
				end
			end
			if maxtype!=-1
				effcheck = Effectiveness.calculate(maxtype, :FIRE, :FIRE, :FIRE)
				if effcheck > 4
					score*=1.5
				else            
					if effcheck<4
						score*=0.5
					end
				end
			end
			userTypes = user.pbTypes(true)
			if userFasterThanTarget
				if user.hasActiveAbility?(:WONDERGUARD) && userTypes.all? { |typo| typo == :FIRE }
					score*=8
				end
			end
		end
    #---------------------------------------------------------------------------
    when "SetTargetAbilityToSimple" # simple beam
		if target.ability == :SIMPLE || target.unstoppableAbility? ||
		   target.hasActiveAbility?(:DISGUISE) || target.effects[PBEffects::Substitute]>0
			score = 0
		else
			miniscore=100
			minimi = getAbilityDisruptScore(move,user,target,skill)
			minimi = 1.0 / minimi if !user.opposes?(target) # is ally
			miniscore*=minimi
			if user.opposes?(target) # is enemy
				miniscore = 0 if minimi < 1.4
			else
				miniscore *= -1
			end
			if pbHasSetupMove?(target, false)
				if !user.opposes?(target)  # is ally
					miniscore*=1.5
				else                      # is enemy
					miniscore*=0.2
				end
			end
			miniscore/=100
			score*=miniscore
		end
    #---------------------------------------------------------------------------
    when "SetTargetAbilityToInsomnia" # worry seed
		if target.ability == :INSOMNIA || target.unstoppableAbility? ||
		   target.hasActiveAbility?(:DISGUISE) || target.effects[PBEffects::Substitute]>0
			score = 0
		else
			miniscore = 100
			minimi = getAbilityDisruptScore(move,user,target,skill)
			minimi = 1.0 / minimi if !user.opposes?(target) # is ally
			miniscore*=minimi
			score*=(miniscore/100.0)
			score*=1.3 if target.moves.any? { |j| [:SNORE, :SLEEPTALK].include?(j&.id) }
			score*=2.0 if target.moves.any? { |j| j&.id == :REST }
			if user.pbHasMove?(:SPORE) || user.pbHasMove?(:SLEEPPOWDER) ||
					user.pbHasMove?(:HYPNOSIS) || user.pbHasMove?(:SING) || 
					user.pbHasMove?(:GRASSWHISTLE) || user.pbHasMove?(:DREAMEATER) || 
					user.pbHasMove?(:NIGHTMARE) || user.hasActiveAbility?(:BADDREAMS)
				score*=0.7
			end
		end
    #---------------------------------------------------------------------------
    when "SetUserAbilityToTargetAbility" # role play
		if target.effects[PBEffects::Substitute] > 0 || target.ungainableAbility?
			score = 0
		elsif !target.ability || user.ability == target.ability ||
			![:MULTITYPE, :RKSSYSTEM].include?(user.ability_id) ||
			![:FLOWERGIFT, :FORECAST, :ILLUSION, :IMPOSTER, :MULTITYPE, :RKSSYSTEM,
				:TRACE, :WONDERGUARD, :ZENMODE].include?(target.ability_id)
			miniscore = getAbilityDisruptScore(move,target,user,skill) # how good is our ability?
			minimini = getAbilityDisruptScore(move,user,target,skill)  # how good is the target's ability?
			if minimini > miniscore
				score *= minimini / miniscore
			else
				score = 0
			end
		else
			score = 0 if move.statusMove?
		end
    #---------------------------------------------------------------------------
    when "SetTargetAbilityToUserAbility" # EEEEEEEEE-ntertainment !!
		if target.effects[PBEffects::Substitute] > 0 || target.unstoppableAbility?
			score = 0
		elsif !user.ability || user.ability == target.ability ||
				![:MULTITYPE, :RKSSYSTEM].include?(target.ability_id) ||
				![:FLOWERGIFT, :FORECAST, :ILLUSION, :IMPOSTER, :MULTITYPE, :RKSSYSTEM,
				:TRACE, :ZENMODE].include?(user.ability_id)
			miniscore = getAbilityDisruptScore(move,target,user,skill) # how good is our ability?
			minimini = getAbilityDisruptScore(move,user,target,skill)  # how good is the target's ability?
			if user.opposes?(target) # is enemy
				if minimini > miniscore
					score*=(minimini/miniscore)
				end
				if user.ability == :TRUANT
					score*=3
				elsif user.ability == :SLOWSTART
					score*=3
				elsif user.ability == :DEFEATIST
					score*=2
				end
				if target.hasActiveAbility?([:TRUANT,:SLOWSTART,:DEFEATIST]) ||
				   user.hasActiveAbility?([:WONDERGUARD, :SPEEDBOOST])
					score=0
				end
			else                    # is ally
				if minimini < miniscore
					score *= (miniscore/minimini)
				end
				if user.ability == :WONDERGUARD
					score *= 5
				elsif user.ability == :SPEEDBOOST
					score *= 3
				end
				score *= -1
			end
		else
			score = 0 if move.statusMove?
		end
    #---------------------------------------------------------------------------
    when "UserTargetSwapAbilities" # Skill Swap
		if target.effects[PBEffects::Substitute] > 0 || target.unstoppableAbility? || user.ungainableAbility?
			score = 0
		elsif !user.ability || user.ability == target.ability ||
				![:MULTITYPE, :RKSSYSTEM].include?(target.ability_id) ||
				![:FLOWERGIFT, :FORECAST, :ILLUSION, :IMPOSTER, :MULTITYPE, :RKSSYSTEM,
				:TRACE, :ZENMODE].include?(user.ability_id)
			miniscore = getAbilityDisruptScore(move,target,user,skill) # how good is our ability?
			minimini = getAbilityDisruptScore(move,user,target,skill)  # how good is the target's ability?
			if user.opposes?(target) # is enemy
				score *= 1.0 / miniscore
				score *= minimini if minimini > 1.0
				if user.ability == :TRUANT
					score*=3
				elsif user.ability == :SLOWSTART
					score*=3
				elsif user.ability == :DEFEATIST
					score*=2
				end
				if target.hasActiveAbility?([:TRUANT,:SLOWSTART,:DEFEATIST]) ||
				   user.hasActiveAbility?([:WONDERGUARD, :SPEEDBOOST])
					score=0
				end
			else                    # is ally
				if miniscore > minimini
					score *= (miniscore / minimini)
				else
					score = 0
				end
				if user.ability == :WONDERGUARD
					score *= 5
				elsif user.ability == :SPEEDBOOST
					score *= 3
				end
				score *= -1
			end
		else
			score = 0 if move.statusMove?
		end
    #---------------------------------------------------------------------------
    when "NegateTargetAbility" # Gastro Acid
		if target.effects[PBEffects::Substitute] > 0 || target.effects[PBEffects::GastroAcid]
			score = 0
		elsif !target.unstoppableAbility?
			minimi = getAbilityDisruptScore(move,user,target,skill)
			if !user.opposes?(target) # is ally
				minimi = 1.0 / minimi
				minimi *= -1 
			end
			score*=minimi
		else
			score = 0 if move.statusMove?
		end
    #---------------------------------------------------------------------------
    when "NegateTargetAbilityIfTargetActed" # Core Enforcer
		if target.effects[PBEffects::Substitute] > 0 || target.effects[PBEffects::GastroAcid]
			score = 0 if move.baseDamage == 0
		elsif !target.unstoppableAbility?
			miniscore = (getAbilityDisruptScore(move,user,target,skill)*100)
			if !userFasterThanTarget
				miniscore*=1.3
			else
				miniscore*=0.7
			end
			if target.moves.any? { |m| priorityAI(target,m,globalArray)>0 }
				miniscore*=1.3
			end
			miniscore/=100
			score*=miniscore
		end
    #---------------------------------------------------------------------------
    when "IgnoreTargetAbility", "CategoryDependsOnHigherDamageIgnoreTargetAbility" # Moongeist Beam / Photon Geyser
		targetTypes = target.pbTypes(true)
		if target.hasActiveAbility?(:WONDERGUARD)
			score*=5
		elsif target.hasActiveAbility?([:VOLTABSORB, :LIGHTNINGROD])
			if move.type==:ELECTRIC
				if Effectiveness.calculate(:ELECTRIC, targetTypes[0], targetTypes[1], targetTypes[2])>4
					score*=2
				end
			end
		elsif target.hasActiveAbility?([:WATERABSORB, :STORMDRAIN, :DRYSKIN])
			if move.type==:WATER
				if Effectiveness.calculate(:WATER, targetTypes[0], targetTypes[1], targetTypes[2])>4
					score*=2
				end
			end
			if move.type==:FIRE && target.hasActiveAbility?(:DRYSKIN) 
				score*=0.5
			end
		elsif target.hasActiveAbility?(:FLASHFIRE)
			if move.type==:FIRE
				if Effectiveness.calculate(:FIRE, targetTypes[0], targetTypes[1], targetTypes[2])>4
					score*=2
				end
			end
		elsif target.hasActiveAbility?(:SAPSIPPER)
			if move.type==:GRASS
				if Effectiveness.calculate(:GRASS, targetTypes[0], targetTypes[1], targetTypes[2])>4
					score*=2
				end
			end
		elsif target.hasActiveAbility?(:LEVITATE)
			if move.type==:GROUND
				if Effectiveness.calculate(:GROUND, targetTypes[0], targetTypes[1], targetTypes[2])>4
					score*=2
				end
			end
		elsif target.hasActiveAbility?(:THICKFAT)
			score*=1.5 if [:FIRE, :ICE].include?(move.type)
		elsif target.hasActiveAbility?(:SOUNDPROOF)
			score*=3.0 if move.soundMove?
		elsif target.hasActiveAbility?(:MULTISCALE)
			score*=1.5 if user.hp==user.totalhp
		elsif target.hasActiveAbility?(:SNOWCLOAK) && expectedWeather == :Hail
			score*=1.2 if move.specialMove?(move.type)
		elsif target.hasActiveAbility?(:SANDVEIL)  && expectedWeather == :Sandstorm
			score*=1.2 if move.physicalMove?(move.type)
		elsif target.hasActiveAbility?(:FURCOAT)
			score*=1.5 if move.physicalMove?(move.type)
		elsif target.hasActiveAbility?(:FLUFFY)
			score*=1.5 if move.pbContactMove?(user)
			score*=0.5 if move.type==:FIRE
		elsif target.hasActiveAbility?(:MOLDBREAKER)
			score*=1.1
		elsif target.hasActiveAbility?(:UNAWARE)
			score*=1.7
		end
    #---------------------------------------------------------------------------
    when "StartUserAirborne" # Magnet Rise
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxmove=bestmove[1]
		maxtype=maxmove.type
		if user.effects[PBEffects::MagnetRise] > 0 ||
           user.effects[PBEffects::Ingrain] ||
           user.effects[PBEffects::SmackDown]
			score=0
		else
			if maxtype == :GROUND # Highest expected dam from a ground move
				score*=3
			end
			if target.pbHasType?(:GROUND, true)
				score*=3
			end
			if (userFasterThanTarget || priorityAI(user, move, globalArray) > 0) && targetWillMove?(target)
				if @battle.choices[target.index][2].type == :GROUND
					score*=3
				end
			end
		end
    #---------------------------------------------------------------------------
    when "StartTargetAirborneAndAlwaysHitByMoves" # Telekinesis
		if target.effects[PBEffects::Telekinesis] > 0 ||
		   target.effects[PBEffects::Ingrain] ||
		   target.effects[PBEffects::SmackDown]
			score=0
		else
			score*=2 if user.moves.any? { |m| m&.accuracy <= 70 }
			if user.pbHasMove?(:ZAPCANNON) || user.pbHasMove?(:INFERNO)
				score*=3
			end
		end
    #---------------------------------------------------------------------------
    when "HitsTargetInSky" # sky uppercut
		if userFasterThanTarget && 
			target.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
									"TwoTurnAttackInvulnerableInSkyParalyzeTarget",
									"TwoTurnAttackInvulnerableInSkyTargetCannotAct")
			score *= 1.5
		end
		score*=1.2 if target.moves.any? { |j| [:BOUNCE,:FLY,:SKYDROP].include?(j&.id) }
    #---------------------------------------------------------------------------
    when "HitsTargetInSkyGroundsTarget" # smack down
		miniscore=100
		if !userFasterThanTarget
			if target.pbHasMove?(:BOUNCE) || target.pbHasMove?(:FLY) || target.pbHasMove?(:SKYDROP)
				miniscore*=1.3
			end
		end
		miniscore*=1.3 if user.moves.any? { |m| m&.type == :GROUND }
		miniscore*=2 if target.airborneAI(mold_broken)
		miniscore/=100.0
		score*=miniscore
	#---------------------------------------------------------------------------
    when "StartGravity" # gravity
		if @battle.field.effects[PBEffects::Gravity]>0
			score=0
		else
			score*=2.0 if user.moves.any? { |m| m&.accuracy <= 70 }
			@battle.pbParty(user.index).each_with_index do |pkmn, i|
				next if !pkmn || pkmn.fainted?
				pkmn.moves.each do |move|
					gravMov = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(move.id))
					score*=0.5 if gravMov.unusableInGravity?
					score*=1.2 if gravMov.boostedByGravity?
					score*=1.3 if gravMov.accuracy <= 70
				end
			end
			if user.pbHasMove?(:ZAPCANNON) || user.pbHasMove?(:INFERNO)
				score*=3
			end
			bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
			maxmove=bestmove[1]
			if maxmove.unusableInGravity? && !target.hasActiveItem?(:FLOATSTONE)
				score*=2
			end
			if user.pbHasType?(:GROUND, true) && target.airborneAI(mold_broken)
				score*=2
			end
		end
    #---------------------------------------------------------------------------
    when "TransformUserIntoTarget" # transform
		if user.effects[PBEffects::Transform] || 
		   user.effects[PBEffects::Illusion] ||
		   user.effects[PBEffects::Substitute]>0
			score=0
		else
			miniscore = target.level
			miniscore -= user.level
			miniscore*=5
			miniscore+=100
			miniscore/=100.0
			score*=miniscore
			miniscore=0
			miniscore+=target.stages[:ATTACK]
			miniscore+=target.stages[:SPECIAL_ATTACK]
			miniscore+=target.stages[:DEFENSE]
			miniscore+=target.stages[:SPECIAL_DEFENSE]
			miniscore+=target.stages[:SPEED]
			miniscore*=10
			miniscore+=100
			miniscore/=100.0
			score*=miniscore
			miniscore+=user.stages[:ATTACK]
			miniscore+=user.stages[:SPECIAL_ATTACK]
			miniscore+=user.stages[:DEFENSE]
			miniscore+=user.stages[:SPECIAL_DEFENSE]
			miniscore+=user.stages[:SPEED]
			miniscore*=(-10)
			miniscore+=100
			miniscore/=100.0
			score*=miniscore
		end   
    #---------------------------------------------------------------------------
    else
      return aiEffectScorePart1_pbGetMoveScoreFunctionCode(score, move, user, target, skill)
    end
    return score
  end
end
