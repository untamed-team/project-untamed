class Battle::AI
  #=============================================================================
  # Get a score for the given move based on its effect
  #=============================================================================
  alias aiEffectScorePart1_pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode

  def pbGetMoveScoreFunctionCode(score, move, user, target, skill = 100)
    case move.function
    #---------------------------------------------------------------------------
    when "SleepTarget", "SleepTargetIfUserDarkrai", "SleepTargetChangeUserMeloettaForm" # hypnosis
			theresone=false
			@battle.allBattlers.each do |j|
				if (j.isSpecies?(:BEAKRAFT) && j.item == :BEAKRAFTITE && j.willmega && !target.affectedByTerrain?) || 
					 (j.isSpecies?(:MILOTIC) && j.item == :MILOTITE && j.willmega && !target.affectedByTerrain?)
					theresone=true
				end
			end
      if target.pbCanSleep?(user, false) && !theresone
        miniscore = pbTargetBenefitsFromStatus?(user, target, :SLEEP, 130, move, 100)
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
				if move.id == :SING
					if target.hasActiveAbility?(:SOUNDPROOF)
						miniscore=0
					end
				end
				if move.id == :GRASSWHISTLE
					if target.hasActiveAbility?(:SOUNDPROOF)
						miniscore=0
					end
				end
				if move.id == :SLEEPPOWDER
					if target.hasActiveItem?(:SAFETYGOGGLES) || target.hasActiveAbility?(:OVERCOAT) || target.pbHasType?(:GRASS)
						miniscore=0
					end
				end
				if move.id == :SPORE
					if target.hasActiveItem?(:SAFETYGOGGLES) || target.hasActiveAbility?(:OVERCOAT) || target.pbHasType?(:GRASS)
						miniscore=0
					end
				end
      end
    #---------------------------------------------------------------------------
    when "SleepTargetNextTurn" # yawn
			theresone=false
			@battle.allBattlers.each do |j|
				if (j.isSpecies?(:BEAKRAFT) && j.item == :BEAKRAFTITE && j.willmega && !target.affectedByTerrain?) || 
					 (j.isSpecies?(:MILOTIC) && j.item == :MILOTITE && j.willmega && !target.affectedByTerrain?)
					theresone=true
				end
			end
      if target.effects[PBEffects::Yawn]<=0 && target.pbCanSleepYawn? && !theresone
        miniscore = pbTargetBenefitsFromStatus?(user, target, :SLEEP, 130, move, 100)
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
			else
				score = 0
			end
    #---------------------------------------------------------------------------
    when "PoisonTarget", "BadPoisonTarget" # poison moves, toxic
      if target.pbCanPoison?(user, false)
        miniscore = pbTargetBenefitsFromStatus?(user, target, :POISON, 120, move, 100)
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
				if move.baseDamage>0
					miniscore-=100
					miniscore*=(move.addlEffect.to_f/100)
					if user.hasActiveAbility?(:SERENEGRACE)
						miniscore*=2
					end
					miniscore+=100
					miniscore/=100.0
					score*=miniscore
				else
					miniscore/=100.0
					score*=miniscore
				end
      end
    #---------------------------------------------------------------------------
    when "PoisonTargetLowerTargetSpeed1" # Toxic Thread
			roles = pbGetPokemonRole(user, target)
			if target.pbCanPoison?(user, false)
				miniscore = pbTargetBenefitsFromStatus?(user, target, :POISON, 100, move, skill)
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
				hasAlly = !target.allAllies.empty?
				if !hasAlly && move.statusMove? && target.battle.choices[target.index][0] == :SwitchOut
					miniscore*=1.1
				end
				if user.pbHasMove?(:VENOSHOCK) || user.pbHasMove?(:VENOMDRENCH) || 
					user.hasActiveAbility?(:MERCILESS)
					miniscore*=1.6
				end
				miniscore/=100.0
				score*=miniscore
      end
			if target.stages[:SPEED]>0 || target.stages[:SPEED]==-6
				score*=0.5
			else          
				miniscore=100
				if roles.include?("Physical Wall") || roles.include?("Special Wall")
					miniscore*=1.1
				end
				userlivecount   = @battle.pbAbleNonActiveCount(user.idxOwnSide)
				targetlivecount = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
				if targetlivecount==1 || user.hasActiveAbility?(:SHADOWTAG) || target.effects[PBEffects::MeanLook]>0
					miniscore*=1.4
				end
				if target.stages[:SPEED]<0
					minimini = 5*target.stages[:SPEED]
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
					movechecktrickroom=false
					for j in target.moves
						movechecktrickroom=true if j.id == :TRICKROOM
					end
					miniscore*=0.1 if movechecktrickroom
				end   
				if target.hasActiveItem?(:LAGGINGTAIL) || target.hasActiveItem?(:IRONBALL)
					miniscore*=0.1
				end
				movecheckelectroball	= false
				movecheckgyroball			= false
				for j in target.moves
					movecheckelectroball = true if j.id == :ELECTROBALL
					movecheckgyroball		 = true if j.id == :GYROBALL
				end
				miniscore*=1.3 if movecheckelectroball
				miniscore*=0.5 if movecheckgyroball
				if (user.pbSpeed<pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
					score*=0.5
				end              
				miniscore/=100.0    
				score*=miniscore
			end
    #---------------------------------------------------------------------------
    when "ParalyzeTarget", "ParalyzeTargetIfNotTypeImmune",
         "ParalyzeTargetAlwaysHitsInRainHitsTargetInSky", "ParalyzeFlinchTarget"
			if move.id == :THUNDERWAVE &&
         Effectiveness.ineffective?(pbCalcTypeMod(move.type, user, target))
				score = 0
			end
			if move.id == :THUNDER
				if (user.pbSpeed>pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0) && 
						target.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
																	  "TwoTurnAttackInvulnerableInSkyParalyzeTarget",
																	  "TwoTurnAttackInvulnerableInSkyTargetCannotAct")
					score *= 1.5
				end
				movecheck=false
				for m in target.moves
					movecheck=true if [:BOUNCE,:FLY,:SKYDROP].include?(move.id)
				end
				score*=1.2 if movecheck
			end
			if move.id == :THUNDERFANG
				if target.effects[PBEffects::Substitute]<=0 && !target.hasActiveAbility?(:INNERFOCUS)
					if (user.pbSpeed>pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
						score*=1.1
					end
					if target.hasActiveAbility?(:STEADFAST)
						score*=0.3
					end            
				end
			end
      if target.pbCanParalyze?(user, false)
				miniscore = pbTargetBenefitsFromStatus?(user, target, :PARALYSIS, 100, move, skill)
				if pbHasSetupMove?(user, false)
					score*=1.1
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
					miniscore-=100
					miniscore*=(move.addlEffect.to_f/100)
					if user.hasActiveAbility?(:SERENEGRACE)
						miniscore*=2
					end
					miniscore+=100
					miniscore/=100.0
					score*=miniscore
				else
					miniscore/=100.0
					score*=miniscore
				end
			else
				score=0
      end
    #---------------------------------------------------------------------------
    when "BurnTarget", "BurnTargetIfTargetStatsRaisedThisTurn"
      if target.pbCanBurn?(user, false)
        miniscore = pbTargetBenefitsFromStatus?(user, target, :BURN, 110, move, 100)
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
					miniscore*=(move.addlEffect.to_f/100)
					if user.hasActiveAbility?(:SERENEGRACE)
						miniscore*=2
					end
					miniscore+=100
					miniscore/=100.0
					score*=miniscore
				else
					miniscore/=100.0
					score*=miniscore
				end
      end
    #---------------------------------------------------------------------------
    when "BurnFlinchTarget"
      if target.pbCanBurn?(user, false)
        miniscore = pbTargetBenefitsFromStatus?(user, target, :BURN, 110, move, 100)
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
					miniscore*=(move.addlEffect.to_f/100)
					if user.hasActiveAbility?(:SERENEGRACE)
						miniscore*=2
					end
					miniscore+=100
					miniscore/=100.0
					score*=miniscore
				else
					miniscore/=100.0
					score*=miniscore
				end
      end
			if target.effects[PBEffects::Substitute]<=0 && !target.hasActiveAbility?(:INNERFOCUS)
				if (user.pbSpeed>pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
					score*=1.1
				end
				if target.hasActiveAbility?(:STEADFAST)
					score*=0.3
				end            
			end
    #---------------------------------------------------------------------------
    when "FreezeTarget", "FreezeFlinchTarget", "FreezeTargetSuperEffectiveAgainstWater"
      if target.pbCanFreeze?(user, false)
        miniscore = pbTargetBenefitsFromStatus?(user, target, :FREEZE, 110, move, 100)
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
					miniscore*=(move.addlEffect.to_f/100)
					if user.hasActiveAbility?(:SERENEGRACE)
						miniscore*=2
					end
					miniscore+=100
					miniscore/=100.0
					score*=miniscore
				else
					miniscore/=100.0
					score*=miniscore
				end
      end
			if move.id == :ICEFANG
				if target.effects[PBEffects::Substitute]<=0 && !target.hasActiveAbility?(:INNERFOCUS)
					if (user.pbSpeed>pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
						score*=1.1
					end
					if target.hasActiveAbility?(:STEADFAST)
						score*=0.3
					end            
				end
			end
    #---------------------------------------------------------------------------
    when "FreezeTargetAlwaysHitsInHail" # blizzard
      if target.pbCanFreeze?(user, false)
        miniscore = pbTargetBenefitsFromStatus?(user, target, :FREEZE, 110, move, 100)
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
					miniscore*=(move.addlEffect.to_f/100)
					if user.hasActiveAbility?(:SERENEGRACE)
						miniscore*=2
					end
					miniscore+=100
					miniscore/=100.0
					score*=miniscore
				else
					miniscore/=100.0
					score*=miniscore
				end
      end
    #---------------------------------------------------------------------------
    when "ParalyzeBurnOrFreezeTarget" # tri attack
			if target.status == :NONE
				miniscore=100
				miniscore*=1.4
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
				miniscore*=(move.addlEffect.to_f/100)
				if user.hasActiveAbility?(:SERENEGRACE)
					miniscore*=2
				end
				miniscore+=100
				miniscore/=100.0       
				score*=miniscore if !user.hasActiveAbility?(:SHEERFORCE)
			end
    #---------------------------------------------------------------------------
    when "GiveUserStatusToTarget" # Psycho Shift
      if user.status == :NONE
        score -= 90
      else
        score += 40
      end
			if user.pbHasAnyStatus? && target.status==:NONE && target.effects[PBEffects::Yawn]==0
				score*=1.3
				if target.status==0 && target.effects[PBEffects::Yawn]==0
					score*=1.3
					if user.status==:BURN && target.pbCanBurn?(user, false)
						if pbRoughStat(target,:ATTACK,skill)>pbRoughStat(target,:SPECIAL_ATTACK,skill)
							score*=1.2
						end
						if target.hasActiveAbility?(:FLAREBOOST)
							score*=0.7
						end
						miniscore = pbTargetBenefitsFromStatus?(user, target, :BURN, 100, move, 100)
						score*=miniscore
					end
					if user.status==:PARALYSIS && target.pbCanParalyze?(user, false)
						if pbRoughStat(target,:ATTACK,skill)<pbRoughStat(target,:SPECIAL_ATTACK,skill)
							score*=1.1
						end
						if (user.pbSpeed<pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
							score*=1.2
						end
						miniscore = pbTargetBenefitsFromStatus?(user, target, :PARALYSIS, 100, move, skill)
						score*=miniscore
					end
					if user.status==:POISON && target.pbCanPoison?(user, false)
						healmove=false
						for j in user.moves
							healmove=true if j.healingMove?
						end
						score*=1.1 if healmove
						if user.effects[PBEffects::Toxic]>0
							score*=1.4
						end
						miniscore = pbTargetBenefitsFromStatus?(user, target, :POISON, 100, move, skill)
						score*=miniscore
					end          
				end
				if user.pbHasMove?(:HEX)
					score*=1.3
				end
			else
				score=0
			end
    #---------------------------------------------------------------------------
    when "CureUserBurnPoisonParalysis" # refresh
			if user.burned? || user.poisoned? || user.paralyzed?
				score*=3
			else
				score=0
			end
			if (user.hp.to_f)/user.totalhp>0.5
				score*=1.5
			else
				score*=0.3
			end
			if target.effects[PBEffects::Yawn]>0
				score*=0.1
			end      
			maxdam=0
			movecheck=false
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				maxdam = tempdam if tempdam > maxdam
				movecheck=true if m.id == :HEX
			end
			if maxdam>user.hp
				score*=0.1
			end
			if target.effects[PBEffects::Toxic]>2
				score*=1.3
			end   
			score*=1.3 if movecheck
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
					if i.ability == :GUTS || 
						 i.ability == :QUICKFEET || 
						 i.hasMove?(:FACADE)
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
				movecheck=false
				for m in target.moves
					movecheck=true if m.healingMove?
				end
				score*=1.1 if movecheck 
			else
				score=0
			end
    #---------------------------------------------------------------------------
    when "CureTargetBurn" # Sparkling Aria
      if target.opposes?(user)
        score -= 40 if target.status == :BURN
      elsif target.status == :BURN
        score += 40
      end
    #---------------------------------------------------------------------------
    when "StartUserSideImmunityToInflictedStatus" # Safeguard
			roles = pbGetPokemonRole(user, target)
			if user.pbOwnSide.effects[PBEffects::Safeguard]<=0 && 
				 ((user.pbSpeed>pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)) && 
				 user.status == :NONE && !roles.include?("Status Absorber") 
				movecheck=false
				for j in target.moves
					movecheck=true if j.id==:SPORE
				end  
				score+=50 if movecheck  
			else
				score=0
			end
    #---------------------------------------------------------------------------
    when "FlinchTarget" # flinching moves
			if target.effects[PBEffects::Substitute]==0 && !target.hasActiveAbility?(:INNERFOCUS)
				if (pbRoughStat(target,:SPEED,skill)<user.pbSpeed) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
					miniscore=100
					miniscore*=1.3
					if target.poisoned? || target.burned? || (user.takesHailDamage? && !user.takesSandstormDamage?) || 
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
						miniscore*=(move.addlEffect.to_f/100)
						if user.hasActiveAbility?(:SERENEGRACE)
							miniscore*=2
						end     
					end
					miniscore+=100
					miniscore/=100.0       
					score*=miniscore             
				end
			end
    #---------------------------------------------------------------------------
    when "FlinchTargetFailsIfUserNotAsleep" # snore
      if user.asleep?
        score *= 2
				if target.effects[PBEffects::Substitute]==0 && !target.hasActiveAbility?(:INNERFOCUS)
					if (pbRoughStat(target,:SPEED,skill)<user.pbSpeed) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
						miniscore=100
						miniscore*=1.3
						if target.poisoned? || target.burned? || (user.takesHailDamage? && !user.takesSandstormDamage?) || 
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
							miniscore*=(move.addlEffect.to_f/100)
							if user.hasActiveAbility?(:SERENEGRACE)
								miniscore*=2
							end     
						end
						miniscore+=100
						miniscore/=100.0       
						score*=miniscore             
					end
				end
      else
        score = 0
      end
    #---------------------------------------------------------------------------
    when "FlinchTargetFailsIfNotUserFirstTurn" # fake out
			if user.turnCount==0
				if target.effects[PBEffects::Substitute]==0 && !target.hasActiveAbility?(:INNERFOCUS)
					if score>1
						if ((user.pbSpeed<pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0))
							score=120
						else
							score=100
						end
					end
					if user.hasActiveItem?(:NORMALGEM)
						score*=1.1
						if user.hasActiveAbility?(:UNBURDEN)
							score*=2
						end
					end          
					if target.hasActiveAbility?(:STEADFAST)
						score*=0.3
					end          
				end
				score*=0.3 if user.hasActiveAbility?(:SHEERFORCE)
				score*=30 if !target.hasActiveAbility?(:INNERFOCUS)
			else
				score=0
			end
    #---------------------------------------------------------------------------
    when "FlinchTargetDoublePowerIfTargetInSky" # twister
			if target.effects[PBEffects::Substitute]==0 && !target.hasActiveAbility?(:INNERFOCUS)
				if (user.pbSpeed>pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
					miniscore=100
					miniscore*=1.3
					if target.hasActiveAbility?(:STEADFAST)
						miniscore*=0.3
					end
					miniscore-=100
					if move.addlEffect.to_f != 100
						miniscore*=(move.addlEffect.to_f/100)
					end   
					miniscore+=100
					if move.addlEffect.to_f != 100
						if user.hasActiveAbility?(:SERENEGRACE)
							miniscore*=2
						end     
					end        
					miniscore/=100.0       
					score*=miniscore             
				end            
			end
    #---------------------------------------------------------------------------
    when "ConfuseTarget", "ConfuseTargetAlwaysHitsInRainHitsTargetInSky"
			if target.pbCanConfuse?(user, false)
				if $game_variables[MECHANICSVAR] >= 3
					miniscore = pbTargetBenefitsFromStatus?(user, target, :DIZZY, 120, move, skill)
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
				if target.hasActiveAbility?(:TANGLEDFEET)
					miniscore*=0.7
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
				miniscore/=100.0
				if move.baseDamage>0
					miniscore-=100
					miniscore*=(move.addlEffect.to_f/100)
					if user.hasActiveAbility?(:SERENEGRACE)
						miniscore*=2
					end
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
    when "AttractTarget"
      score = 0
    #---------------------------------------------------------------------------
    when "SetUserTypesBasedOnEnvironment"
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
    when "SetUserTypesToResistLastAttack"
      if !user.canChangeType?
        score -= 90
      elsif !target.lastMoveUsed || !target.lastMoveUsedType ||
            GameData::Type.get(target.lastMoveUsedType).pseudo_type
        score -= 90
      else
        aType = nil
        target.eachMove do |m|
          next if m.id != target.lastMoveUsed
          aType = m.pbCalcType(user)
          break
        end
        if aType
          has_possible_type = false
          GameData::Type.each do |t|
            next if t.pseudo_type || user.pbHasType?(t.id) ||
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
    when "SetUserTypesToTargetTypes"
      if !user.canChangeType? || target.pbTypes(true).length == 0
        score -= 90
      elsif user.pbTypes == target.pbTypes &&
            user.effects[PBEffects::Type3] == target.effects[PBEffects::Type3]
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "SetUserTypesToUserMoveType"
      if user.canChangeType?
        has_possible_type = false
        user.eachMoveWithIndex do |m, i|
          break if Settings::MECHANICS_GENERATION >= 6 && i > 0
          next if GameData::Type.get(m.type).pseudo_type
          next if user.pbHasType?(m.type)
          has_possible_type = true
          break
        end
        score -= 90 if !has_possible_type
      else
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "SetTargetTypesToPsychic" # Magic Powder
			sevar = false
			for i in user.moves
				if i.type == :DARK || i.type == :GHOST
					sevar = true
				end
			end
			if sevar
				score*=1.5
			else
				score*=0.7
			end
			roles = pbGetPokemonRole(user, target)
			if roles.include?("Physical Wall") || roles.include?("Special Wall")
				if user.pbHasMove?(:TOXIC)
					if target.pbHasType?(:STEEL) || target.pbHasType?(:POISON)
						score*=1.5
					end
				end
			end
			movecheck=false
			for j in target.moves
				movecheck=true if j.type == :PSYCHIC
			end  
			if movecheck
				score*=0.5
			else
				score*=1.1
			end
			if target.pbHasOtherType?(:PSYCHIC)
				score=0
			end
			if !target.canChangeType?
        score = 0
      end
    #---------------------------------------------------------------------------
    when "SetTargetTypesToWater" # soak
			sevar = false
			for i in user.moves
				if i.type == :ELECTRIC || i.type == :GRASS
					sevar = true
				end
			end
			if sevar
				score*=1.5
			else
				score*=0.7
			end
			roles = pbGetPokemonRole(user, target)
			if roles.include?("Physical Wall") || roles.include?("Special Wall")
				if user.pbHasMove?(:TOXIC)
					if target.pbHasType?(:STEEL) || target.pbHasType?(:POISON)
						score*=1.5
					end
				end
			end
			movecheck=false
			for j in target.moves
				movecheck=true if j.type == :WATER
			end  
			if movecheck
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
			ghostvar = false
			for i in target.moves
				ghostvar=true if i.type == :GHOST
			end
			effmove = false
			for m in user.moves
				if [:DARK, :GHOST].include?(m.type)
					effmove = true
					break
				end
			end        
			if effmove
				score*=1.5
			else
				score*=0.7
			end
			roles = pbGetPokemonRole(user, target)
			if roles.include?("Physical Wall") || roles.include?("Special Wall")
				if user.pbHasMove?(:TOXIC) && (target.pbHasType?(:STEEL) || target.pbHasType?(:POISON))
					score*=1.5
				end
			end
			if ghostvar
				score*=0.5
			else
				score*=1.1
			end
			if target.pbHasType?(:GHOST) || target.canChangeType? || 
				 target.hasActiveAbility?([:PROTEAN, :COLORCHANGE])
				score*=0
			end
    #---------------------------------------------------------------------------
    when "AddGrassTypeToTarget" # Forest's Curse
			grassvar = false
			for i in target.moves
				grassvar=true if i.type == :GRASS
			end
			effmove = false
			for m in user.moves
				if [:FIRE, :ICE, :BUG, :FLYING, :POISON].include?(m.type)
					effmove = true
					break
				end
			end        
			if effmove
				score*=1.5
			else
				score*=0.7
			end
			roles = pbGetPokemonRole(user, target)
			if roles.include?("Physical Wall") || roles.include?("Special Wall")
				if user.pbHasMove?(:TOXIC) && (target.pbHasType?(:STEEL) || target.pbHasType?(:POISON))
					score*=1.5
				end
			end
			if grassvar
				score*=0.5
			else
				score*=1.1
			end
			if target.pbHasType?(:GRASS) || target.canChangeType? || 
				 target.hasActiveAbility?([:PROTEAN, :COLORCHANGE])
				score*=0
			end
    #---------------------------------------------------------------------------
    when "UserLosesFireType" # burn up
			maxdam = 0
			maxtype = -1
			healvar = false
			for m in target.moves
				healvar = true if m.healingMove?
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				if tempdam>maxdam
					maxdam=tempdam 
					maxtype = m.type
				end  
			end
			if !user.pbHasType?(:FIRE)
				score = 0
			else
				userlivecount 	= @battle.pbAbleNonActiveCount(user.idxOwnSide)
				targetlivecount = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
				if score<100
					score*=0.9
					if healvar
						score*=0.5
					end
				end
				miniscore=100
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
				userTypes = user.pbTypes(false)
				if (user.pbSpeed>pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
					if user.hasActiveAbility?(:WONDERGUARD) && (userTypes[0] == :FIRE || userTypes[1] == :FIRE || userTypes[2] == :FIRE)
						score*=8
					end
				end
			end
    #---------------------------------------------------------------------------
    when "SetTargetAbilityToSimple" # simple beam
			if target.ability == :SIMPLE ||
				 (target.hasActiveAbility?(:DISGUISE) && target.form == 0) || target.effects[PBEffects::Substitute]>0
				score = 0
			else
				miniscore = getAbilityDisruptScore(move,user,target,skill)
				if user.opposes?(target)
					if miniscore < 2
						miniscore = 2 - miniscore
					else
						miniscore = 0
					end
				end
				score*=miniscore
				movecheck=false
				movecheck=true if pbHasSetupMove?(target, false)
				if movecheck
					if user.opposes?(target)
						score*=1.3
					else
						score*=0.5
					end
				end
			end
    #---------------------------------------------------------------------------
    when "SetTargetAbilityToInsomnia" # worry seed
			if target.ability == :INSOMNIA ||
				 (target.hasActiveAbility?(:DISGUISE) && target.form == 0) || target.effects[PBEffects::Substitute]>0
				score = 0
			else
				miniscore = getAbilityDisruptScore(move,user,target,skill)
				restcheck=false
				snorecheck=false
				for m in target.moves
					restcheck=true if m.id == :REST
					snorecheck=true if m.id == :SNORE || m.id == :SLEEPTALK
				end
				if snorecheck
					score*=1.3
				end
				if restcheck
					score*=2
				end
				if user.pbHasMove?(:SPORE) || user.pbHasMove?(:SLEEPPOWDER) ||
					 user.pbHasMove?(:HYPNOSIS) || user.pbHasMove?(:SING) || 
					 user.pbHasMove?(:GRASSWHISTLE) || user.pbHasMove?(:DREAMEATER) || 
					 user.pbHasMove?(:NIGHTMARE) || user.hasActiveAbility?(:BADDREAMS)
					score*=0.7
				end
			end
    #---------------------------------------------------------------------------
    when "SetUserAbilityToTargetAbility" # role play
      if target.effects[PBEffects::Substitute] > 0
        score = 0
      elsif !target.ability || user.ability == target.ability ||
				 ![:MULTITYPE, :RKSSYSTEM].include?(user.ability_id) ||
				 ![:FLOWERGIFT, :FORECAST, :ILLUSION, :IMPOSTER, :MULTITYPE, :RKSSYSTEM,
					:TRACE, :WONDERGUARD, :ZENMODE].include?(target.ability_id)
				miniscore = getAbilityDisruptScore(move,target,user,skill)
				minimini = getAbilityDisruptScore(move,user,target,skill)
				score *= (1 + (minimini-miniscore))
			end
    #---------------------------------------------------------------------------
    when "SetTargetAbilityToUserAbility"
      if target.effects[PBEffects::Substitute] > 0
        score = 0
      elsif !user.ability || user.ability == target.ability ||
            ![:MULTITYPE, :RKSSYSTEM, :TRUANT].include?(target.ability_id) ||
            ![:FLOWERGIFT, :FORECAST, :ILLUSION, :IMPOSTER, :MULTITYPE, :RKSSYSTEM,
             :TRACE, :ZENMODE].include?(user.ability_id)
				miniscore = getAbilityDisruptScore(move,target,user,skill)
				minimini = getAbilityDisruptScore(move,user,target,skill)
				if user.opposes?(target)
					score *= (1 + (minimini-miniscore))
					if user.ability == :TRUANT
						score*=3
					elsif user.ability == :WONDERGUARD
						score=0
					end
				else
					score *= (1 + (miniscore-minimini))
					if user.ability == :WONDERGUARD
						score +=85
					elsif user.ability == :SPEEDBOOST
						score +=25
					elsif user.ability == :DEFEATIST
						score +=30
					elsif user.ability == :SLOWSTART
						score +=50
					end
				end
      end
    #---------------------------------------------------------------------------
    when "UserTargetSwapAbilities"
      if target.effects[PBEffects::Substitute] > 0
        score = 0
      elsif !user.ability || user.ability == target.ability ||
            ![:MULTITYPE, :RKSSYSTEM, :TRUANT].include?(target.ability_id) ||
            ![:FLOWERGIFT, :FORECAST, :ILLUSION, :IMPOSTER, :MULTITYPE, :RKSSYSTEM,
             :TRACE, :ZENMODE].include?(user.ability_id)
				miniscore = getAbilityDisruptScore(move,target,user,skill)
				minimini = getAbilityDisruptScore(move,user,target,skill)
				if !user.opposes?(target)
					if minimini < 2
						minimini = 2 - minimini
					else
						minimini = 0
					end
				end
          if target.ability == :TRUANT && !user.opposes?(target)
            score*=2
          end       
          if target.ability == :TRUANT && user.opposes?(target)
            score*=2
          end
      end
    #---------------------------------------------------------------------------
    when "NegateTargetAbility" # Gastro Acid
      if target.effects[PBEffects::Substitute] > 0 ||
         target.effects[PBEffects::GastroAcid]
        score -= 90
      elsif !target.unstoppableAbility?
				miniscore = getAbilityDisruptScore(move,user,target,skill)
				score*=miniscore
      end
    #---------------------------------------------------------------------------
    when "NegateTargetAbilityIfTargetActed" # Core Enforcer
			privar=false
			for j in target.moves
				privar=true if j.priority>0
			end
			if !target.unstoppableAbility?
				miniscore = getAbilityDisruptScore(move,user,target,skill)
				if (user.pbSpeed<pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
					miniscore*=1.3
				else
					miniscore*=0.5
				end
				if privar
					miniscore*=1.3
				end                  
				score*=miniscore
			end
    #---------------------------------------------------------------------------
    when "IgnoreTargetAbility" # Moongeist Beam
			targetTypes = target.pbTypes(true)
			if target.hasActiveAbility?(:SANDVEIL)
				if target.effectiveWeather == :Sandstorm
					score*=1.1
				end
			elsif target.hasActiveAbility?(:VOLTABSORB) || target.hasActiveAbility?(:LIGHTNINGROD)
				if move.type==:ELECTRIC
					if damcount==1
						score*=3
					end
					if Effectiveness.calculate(:ELECTRIC, targetTypes[0], targetTypes[1], targetTypes[2])>4
						score*=2
					end
				end
			elsif target.hasActiveAbility?(:WATERABSORB) || target.hasActiveAbility?(:STORMDRAIN) || target.hasActiveAbility?(:DRYSKIN)
				if move.type==:WATER
					if damcount==1
						score*=3
					end
					if Effectiveness.calculate(:WATER, targetTypes[0], targetTypes[1], targetTypes[2])>4
						score*=2
					end
				end
				if target.hasActiveAbility?(:DRYSKIN) && firemove
					score*=0.5
				end
			elsif target.hasActiveAbility?(:FLASHFIRE)
				if move.type==:FIRE
					if damcount==1
						score*=3
					end
					if Effectiveness.calculate(:FIRE, targetTypes[0], targetTypes[1], targetTypes[2])>4
						score*=2
					end
				end
			elsif target.hasActiveAbility?(:LEVITATE)
				if move.type==:GROUND
					if damcount==1
						score*=3
					end
					if Effectiveness.calculate(:GROUND, targetTypes[0], targetTypes[1], targetTypes[2])>4
						score*=2
					end
				end
			elsif target.hasActiveAbility?(:WONDERGUARD)
				score*=5
			elsif target.hasActiveAbility?(:SOUNDPROOF)
				if move.soundMove?
					score*=3
				end
			elsif target.hasActiveAbility?(:THICKFAT)
				if move.type==:FIRE || move.type==:ICE
					score*=1.5
				end
			elsif target.hasActiveAbility?(:MOLDBREAKER)
				score*=1.1
			elsif target.hasActiveAbility?(:UNAWARE)
				score*=1.7
			elsif target.hasActiveAbility?(:MULTISCALE)
				if user.hp==user.totalhp
					score*=1.5
				end
			elsif target.hasActiveAbility?(:SAPSIPPER)
				if move.type==:GRASS
					if damcount==1
						score*=3
					end
					if Effectiveness.calculate(:GROUND, targetTypes[0], targetTypes[1], targetTypes[2])>4
						score*=2
					end
				end
			elsif target.hasActiveAbility?(:SNOWCLOAK)
				if target.effectiveWeather == :Hail
					score*=1.1
				end
			elsif target.hasActiveAbility?(:FURCOAT)
				if user.attack>user.spatk
					score*=1.5
				end
			elsif target.hasActiveAbility?(:FLUFFY)
				score*=1.5
				if move.type==:FIRE
					score*=0.5
				end
			elsif target.hasActiveAbility?(:WATERBUBBLE)
				score*=1.5
				#~ if move.type==:FIRE
					#~ score*=1.3
				#~ end
			end
    #---------------------------------------------------------------------------
    when "StartUserAirborne" # Magnet Rise
			maxdam = 0
			maxtype = -1
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				if tempdam > maxdam
					maxdam = tempdam
					maxtype = m.type
				end
			end
			if user.effects[PBEffects::MagnetRise] > 0 ||
         user.effects[PBEffects::Ingrain] ||
         user.effects[PBEffects::SmackDown]
				score=0
			else
				if maxtype == :GROUND # Highest expected dam from a ground move
					score*=3
				end
				if target.pbHasType?(:GROUND)
					score*=3
				end
			end
    #---------------------------------------------------------------------------
    when "StartTargetAirborneAndAlwaysHitByMoves" # Telekinesis
			healvar=false
			for j in target.moves
				healvar=true if j.healingMove?
			end
      if target.effects[PBEffects::Telekinesis] > 0 ||
         target.effects[PBEffects::Ingrain] ||
         target.effects[PBEffects::SmackDown]
				score=0
			else
				for i in user.moves 
					if i.accuracy<=70
						score*=2
						break
					end
				end
				if user.pbHasMove?(:ZAPCANNON) || user.pbHasMove?(:INFERNO)
					score*=3
				end
      end
    #---------------------------------------------------------------------------
    when "HitsTargetInSky" # sky uppercut
			if (user.pbSpeed>pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0) && 
					target.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
																	"TwoTurnAttackInvulnerableInSkyParalyzeTarget",
																	"TwoTurnAttackInvulnerableInSkyTargetCannotAct")
				score *= 1.5
			end
			movecheck=false
			for m in target.moves
				movecheck=true if [:BOUNCE,:FLY,:SKYDROP].include?(move.id)
			end
			score*=1.2 if movecheck
    #---------------------------------------------------------------------------
    when "HitsTargetInSkyGroundsTarget" # smack down
			miniscore=100
			if (user.pbSpeed < pbRoughStat(target, :SPEED, skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
				if target.pbHasMove?(:BOUNCE) || target.pbHasMove?(:FLY) || target.pbHasMove?(:SKYDROP)
					miniscore*=1.3
				else
					target.effects[PBEffects::TwoTurnAttack]!=0
					miniscore*=2
				end
			end
			groundmove = false
			for i in user.moves
				if i.type == :GROUND
					groundmove = true
				end
			end
			miniscore*=1.3 if groundmove
			if target.pbHasType?(:FLYING) || target.hasActiveAbility?(:LEVITATE) || target.hasActiveItem?(:AIRBALLOON)
				miniscore*=2
			end
			miniscore/=100.0
			score*=miniscore
    #---------------------------------------------------------------------------
    when "StartGravity" # gravity
			maxdam = 0
			maxid = -1
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				if tempdam > maxdam
					maxdam = tempdam
					maxid = m.id
				end
			end
			if @battle.field.effects[PBEffects::Gravity]>0
				score*=0
			else
				for i in user.moves 
					if i.accuracy<=70
						score*=2
						break
					end
				end
				if user.pbHasMove?(:ZAPCANNON) || user.pbHasMove?(:INFERNO)
					score*=3
				end
				if [:SKYDROP, :BOUNCE, :FLY, :JUMPKICK, :FLYINGPRESS, :HIJUMPKICK, :SPLASH].include?(maxid)
					score*=2
				end
				for m in user.moves
					if [:SKYDROP, :BOUNCE, :FLY, :JUMPKICK, :FLYINGPRESS, :HIJUMPKICK, :SPLASH].include?(m.id) && m.pp > 0
						score*=0
						break
					end
				end
				if user.pbHasType?(:GROUND) && target.airborne?
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
