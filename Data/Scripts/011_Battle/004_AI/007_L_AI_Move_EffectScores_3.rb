class Battle::AI
# added the new status nerf if $game_variables[MECHANICSVAR] is above or equal to 3 #by low
  #=============================================================================
  # Get a score for the given move based on its effect
  #=============================================================================
  alias aiEffectScorePart2_pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode

  def pbGetMoveScoreFunctionCode(score, move, user, target, skill = 100)
    case move.function
    #---------------------------------------------------------------------------
    when "FixedDamage20"
      if target.hp <= 20
        score += 120
      elsif target.level >= 25
        score -= 60   # Not useful against high-level Pokemon
      end
    #---------------------------------------------------------------------------
    when "FixedDamage40"
      score += 120 if target.hp <= 40
    #---------------------------------------------------------------------------
    when "FixedDamageHalfTargetHP"
      score -= 50
      score += target.hp * 100 / target.totalhp
    #---------------------------------------------------------------------------
    when "FixedDamageUserLevel"
      score += 80 if target.hp <= user.level
    #---------------------------------------------------------------------------
    when "FixedDamageUserLevelRandom"
      score += 30 if target.hp <= user.level
    #---------------------------------------------------------------------------
    when "LowerTargetHPToUserHP" # Endeavor
			if user.hp > target.hp
				score=0
			else
				privar = false
				for i in user.moves
					if i.priority>0
						privar=true
					end
				end
				if privar
					score*=1.5
				end
				if (user.hasActiveAbility?(:STURDY) || user.hasActiveItem?(:FOCUSSASH)) && user.hp == user.totalhp
					score*=1.5
				end
				if @battle.field.weather == :Sandstorm && target.takesSandstormDamage?
					score*=1.5
				end
				if target.level - user.level > 9
					score*=2
				end   
			end
    #---------------------------------------------------------------------------
    when "OHKO", "OHKOIce", "OHKOHitsUndergroundTarget"
      score -= 90 if target.hasActiveAbility?(:STURDY)
      score -= 90 if target.level >= user.level
      score = 0 if $game_variables[MECHANICSVAR] >= 2
    #---------------------------------------------------------------------------
    when "DamageTargetAlly" # flame burst
      target.allAllies.each do |b|
        next if !b.near?(target)
				next if b.hp<=0
        score += 10
      end
    #---------------------------------------------------------------------------
    when "PowerHigherWithUserHP"
			if (user.pbSpeed < pbRoughStat(target, :SPEED, skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
				score*=0.5
			end
    #---------------------------------------------------------------------------
    when "PowerLowerWithUserHP"
			if (user.pbSpeed < pbRoughStat(target, :SPEED, skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
				score*=1.1
				if user.hp<user.totalhp
					score*1.3
				end          
			end
    #---------------------------------------------------------------------------
    when "PowerHigherWithTargetHP"
    #---------------------------------------------------------------------------
    when "PowerHigherWithUserHappiness"
    #---------------------------------------------------------------------------
    when "PowerLowerWithUserHappiness"
    #---------------------------------------------------------------------------
    when "PowerHigherWithUserPositiveStatStages"
    #---------------------------------------------------------------------------
    when "PowerHigherWithTargetPositiveStatStages"
    #---------------------------------------------------------------------------
    when "PowerHigherWithUserFasterThanTarget"
    #---------------------------------------------------------------------------
    when "PowerHigherWithTargetFasterThanUser"
    #---------------------------------------------------------------------------
    when "PowerHigherWithLessPP"
			if user.hp==user.totalhp
				score*=1.3
			end
			maxdam = 0
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				maxdam = tempdam if tempdam > maxdam
			end
			if maxdam<(user.hp/3.0)
				score*=1.3
			end
    #---------------------------------------------------------------------------
    when "PowerHigherWithTargetWeight"
    #---------------------------------------------------------------------------
    when "PowerHigherWithUserHeavierThanTarget"
    #---------------------------------------------------------------------------
    when "PowerHigherWithConsecutiveUse"
			if user.paralyzed? 
				score*=0.7
			end
			if user.effects[PBEffects::Confusion]>0
				score*=0.7
			end
			if user.effects[PBEffects::Attract]>=0
				score*=0.7
			end
			if user.hp==user.totalhp
				score*=1.3
			end
			if pbHasSingleTargetProtectMove?(target)
        score*=0.8
			end
			maxdam = 0
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				maxdam = tempdam if tempdam > maxdam
			end
			if maxdam<(user.hp/3.0)
				score*=1.5
			end
    #---------------------------------------------------------------------------
    when "PowerHigherWithConsecutiveUseOnUserSide"
			if user.paralyzed? 
				score*=0.7
			end
			if user.effects[PBEffects::Confusion]>0
				score*=0.7
			end
			if user.effects[PBEffects::Attract]>=0
				score*=0.7
			end
			if user.hp==user.totalhp
				score*=1.3
			end
			maxdam = 0
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				maxdam = tempdam if tempdam > maxdam
			end
			if maxdam<(user.hp/3.0)
				score*=1.5
			end
    #---------------------------------------------------------------------------
    when "RandomPowerDoublePowerIfTargetUnderground"
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetHPLessThanHalf"
    #---------------------------------------------------------------------------
    when "DoublePowerIfUserPoisonedBurnedParalyzed"
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetAsleepCureTarget" # Wake-Up Slap
			if target.asleep? && target.effects[PBEffects::Substitute]<=0
				score*=0.8
				if user.hasWorkingAbility(:BADDREAMS) || user.pbHasMove?(:DREAMEATER) ||
					 user.pbHasMove?(:NIGHTMARE)
					score*=0.3
				end
				if target.pbHasMove?(:SNORE) || opponnet.pbHasMove?(:SLEEPTALK)
					score*=1.3
				end
			end
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetPoisoned"
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetParalyzedCureTarget" # Smelling Salts
			if target.paralyzed?
				score*=0.8
				if target.speed>user.speed && target.speed/2.0<user.speed
					score*=0.5
				end
			end
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetStatusProblem"
    #---------------------------------------------------------------------------
    when "DoublePowerIfUserHasNoItem"
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetUnderwater"
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetUnderground"
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetInSky"
    #---------------------------------------------------------------------------
    when "DoublePowerInElectricTerrain"
      score += 40 if @battle.field.terrain == :Electric && target.affectedByTerrain?
    #---------------------------------------------------------------------------
    when "DoublePowerIfUserLastMoveFailed" # Stomping Tantrum
    #---------------------------------------------------------------------------
    when "DoublePowerIfAllyFaintedLastTurn"
    #---------------------------------------------------------------------------
    when "DoublePowerIfUserLostHPThisTurn" # Avalanche / Revenge
			if (user.pbSpeed>pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
				score*=0.5
			end
			if user.hp==user.totalhp
				score*=1.5
				if user.hasWorkingAbility(:STURDY) || user.hasWorkingItem(:FOCUSSASH)
					score*=1.5
				end
			else
				score*=0.7          
				maxdam=0
				for m in target.moves
					tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
					maxdam = tempdam if tempdam > maxdam
				end
				if maxdam>user.hp
					score*=0.3
				end
			end
			movecheck=false
			movecheck=true if pbHasSetupMove?(target, false)
			if movecheck
				score*=0.8
			end
			miniscore=user.hp*(1.0/user.totalhp)
			score*=miniscore
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetLostHPThisTurn" # Assurance
			if (user.pbSpeed>pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
				score*=1.5
			end
    #---------------------------------------------------------------------------
    when "DoublePowerIfUserStatsLoweredThisTurn"
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetActed" # Payback
			if (user.pbSpeed>pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
				score*=2
			end
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetNotActed"
    #---------------------------------------------------------------------------
    when "AlwaysCriticalHit" # frost breath
			thisinitial = score
			if !target.hasActiveAbility?([:BATTLEARMOR, :SHELLARMOR]) && !user.effects[PBEffects::LaserFocus]
				miniscore = 100
				ministat = 0
				ministat += target.stages[:DEFENSE] if target.stages[:DEFENSE]>0
				ministat += target.stages[:SPECIAL_DEFENSE] if target.stages[:SPECIAL_DEFENSE]>0
				miniscore += 10*ministat
				ministat = 0
				ministat -= user.stages[:ATTACK] if user.stages[:ATTACK]<0
				ministat -= user.stages[:SPECIAL_ATTACK] if user.stages[:SPECIAL_ATTACK]<0
				miniscore += 10*ministat
				if user.effects[PBEffects::FocusEnergy]>0
					miniscore -= 10*user.effects[PBEffects::FocusEnergy]
				end
				miniscore/=100.0
				score*=miniscore
				if target.hasActiveAbility?(:ANGERPOINT) && target.stages[:ATTACK]!=6 
					if target.near?(user)
						if target.attack>target.spatk
							if thisinitial>99
								score=0
							else
								score = (100-thisinitial)
								enemy1 = user.pbDirectOpposing
								enemy1.allAllies do |b|
									enemy2 = b
								end
								if target.pbSpeed > enemy1.pbSpeed && target.pbSpeed > enemy2.pbSpeed
									score*=1.3
								else
									score*=0.7
								end
							end
						else
							score*=0.1
						end
					else
						if thisinitial<100
							score*=0.7
							if target.attack>target.spatk
								score*=0.2
							end
						end
					end
				end
			else
				score*=0.1
			end
    #---------------------------------------------------------------------------
    when "EnsureNextCriticalHit" # Laser Focus
			if !target.hasActiveAbility?([:BATTLEARMOR, :SHELLARMOR]) && user.effects[PBEffects::LaserFocus] == 0
				miniscore = 100
				ministat=0
				ministat+=target.stages[:DEFENSE] 
				ministat+=target.stages[:SPECIAL_DEFENSE] 
				if ministat>0
					miniscore+= 10*ministat
				end
				ministat=0
				ministat+=user.stages[:ATTACK] 
				ministat+=user.stages[:SPECIAL_ATTACK] 
				if ministat>0
					miniscore+= 10*ministat
				end
				if user.effects[PBEffects::FocusEnergy]>0
					miniscore *= 0.8**user.effects[PBEffects::FocusEnergy]
				end
				miniscore/=100.0
				score*=miniscore
				if target.hasActiveAbility?(:ANGERPOINT) && target.stages[:ATTACK] !=6
					score*=0.7
					if target.attack>target.spatk
						score*=0.2
					end
				end
			else
				score*=0
			end
    #---------------------------------------------------------------------------
    when "StartPreventCriticalHitsAgainstUserSide"
      score -= 90 if user.pbOwnSide.effects[PBEffects::LuckyChant] > 0
    #---------------------------------------------------------------------------
    when "CannotMakeTargetFaint" # false swipe
			if score>=100
				score*=0.1
			end
    #---------------------------------------------------------------------------
    when "UserEnduresFaintingThisTurn" # endure
			maxdam = 0
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				maxdam = tempdam if tempdam > maxdam
			end
			if user.hp>1
				if user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY))
					score*=0
				end
				if maxdam>user.hp
					score*=2
				end
				if (user.pbSpeed > pbRoughStat(target, :SPEED, skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
					score*=1.3
				else
					score*0.5
				end
				if user.takesHailDamage? || user.takesSandstormDamage?
					score*=0
				end
				if user.poisoned? || user.burned? || user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Curse]
					score*=0
				end
				if user.pbHasMove?(:PAINSPLIT) || user.pbHasMove?(:FLAIL) || user.pbHasMove?(:REVERSAL)
					score*=2
				end
				if user.pbHasMove?(:ENDEAVOR)
					score*=3
				end
				if target.poisoned? || target.burned? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse]
					score*=1.5
				end
				if target.effects[PBEffects::TwoTurnAttack]!=0
					if (user.pbSpeed>pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
						score*=1.5
					end
				end
			else
				score*=0
			end
    #---------------------------------------------------------------------------
    when "StartWeakenElectricMoves"
      score -= 90 if user.effects[PBEffects::MudSport]
    #---------------------------------------------------------------------------
    when "StartWeakenFireMoves"
      score -= 90 if user.effects[PBEffects::WaterSport]
    #---------------------------------------------------------------------------
    when "StartWeakenPhysicalDamageAgainstUserSide"
			target=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
			maxdam=bestmove[0] 
			maxmove=bestmove[1]
			maxphys=(bestmove[3]=="physical") 
			halfhealth=(user.totalhp/2)
			thirdhealth=(user.totalhp/3)
			score+=30 if user.hasActiveItem?(:LIGHTCLAY)
			if maxphys
				score+=40 if halfhealth>maxdam
				score+=60
				if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
					score -= 50 if maxdam>thirdhealth
				else
					halfdam=maxdam/2
					score+=40 if halfdam<user.hp
				end     
			end 
			score-=90 if target.pbHasMoveFunction?("StealAndUseBeneficialStatusMove", "RemoveScreens", "LowerTargetEvasion1RemoveSideEffects") || 
									(target.pbHasMoveFunction?("DisableTargetStatusMoves") && aspeed<ospeed)
			score = 5 if user.pbOwnSide.effects[PBEffects::Reflect] > 0 || user.pbOwnSide.effects[PBEffects::AuroraVeil] > 1
    #---------------------------------------------------------------------------
    when "StartWeakenSpecialDamageAgainstUserSide"
			score = 5 if user.pbOwnSide.effects[PBEffects::LightScreen] > 0 || user.pbOwnSide.effects[PBEffects::AuroraVeil] > 1
			target=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
			maxdam=bestmove[0] 
			maxmove=bestmove[1]
			maxspec=(bestmove[3]=="special") 
			halfhealth=(user.totalhp/2)
			thirdhealth=(user.totalhp/3)
			score+=30 if user.hasActiveItem?(:LIGHTCLAY)
			if maxspec
				score+=40 if halfhealth>maxdam
				score+=60
				if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
					score -= 50 if maxdam>thirdhealth
				else
					halfdam=maxdam/2
					score+=40 if halfdam<user.hp
				end     
			end 
			score-=90 if target.pbHasMoveFunction?("StealAndUseBeneficialStatusMove", "RemoveScreens", "LowerTargetEvasion1RemoveSideEffects") || 
									(target.pbHasMoveFunction?("DisableTargetStatusMoves") && aspeed<ospeed)
			score = 5 if user.pbOwnSide.effects[PBEffects::LightScreen] > 0 || user.pbOwnSide.effects[PBEffects::AuroraVeil] > 1
    #---------------------------------------------------------------------------
    when "StartWeakenDamageAgainstUserSideIfHail" # aurora veil
      if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0 || user.effectiveWeather != :Hail
        score -= 90
      else
        score += 40
      end
			if user.pbOwnSide.effects[PBEffects::AuroraVeil]>0
				score = 0
			else
				if user.effectiveWeather == :Hail
					score*=1.5
					if user.hasActiveItem?(:LIGHTCLAY)
						score*=1.5
					end
					if (user.pbSpeed>pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
						score*=1.1
						maxdam = 0
						maxid = -1
						for m in target.moves
							tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
							maxdam = tempdam if tempdam > maxdam
						end
						if maxdam>user.hp && (maxdam/2.0)<user.hp
							score*=2
						end 
					end
					if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && 
					  !user.takesHailDamage? && !user.takesSandstormDamage?)
						score*=1.3
					end
					movecheck=false
					for j in target.moves
						movecheck=true if [:DEFOG, :BRICKBREAK, :PSYCHICFANGS].include?(j.id)
					end  
					score*=0.1 if movecheck      
				else
					score=0
				end
			end
    #---------------------------------------------------------------------------
    when "RemoveScreens" # brick break
      score*=1.8 if user.pbOpposingSide.effects[PBEffects::Reflect] > 0
      score*=1.3 if user.pbOpposingSide.effects[PBEffects::LightScreen] > 0
      score*=2.3 if user.pbOpposingSide.effects[PBEffects::AuroraVeil] > 0
    #---------------------------------------------------------------------------
    when "RemoveProtections", "RemoveProtectionsBypassSubstitute", "HoopaRemoveProtectionsBypassSubstituteLowerUserDef1"
			protected = false
			for m in target.moves
				if ["ProtectUser", "ProtectUserBanefulBunker", "ProtectUserFromDamagingMovesKingsShield", 
						"ProtectUserFromDamagingMovesObstruct", "ProtectUserFromTargetingMovesSpikyShield", 
						"ProtectUserSideFromStatusMoves", "ProtectUserSideFromPriorityMoves", 
						"ProtectUserSideFromMultiTargetDamagingMoves"].include?(m.function)
					protected = true
					break
				end
				if m.function == "ProtectUserSideFromDamagingMovesIfUserFirstTurn" && target.turnCount == 0
					protected = true
					break
				end
			end
			if protected
				score *= 1.1
				if target.effects[PBEffects::ProtectRate] == 0
					score *= 1.2
				end
			end
			if move.function == "HoopaRemoveProtectionsBypassSubstituteLowerUserDef1"
				if !user.isSpecies?(:HOOPA) || user.form != 1
					score -= 100
				elsif target.stages[:DEFENSE] > 0
					score += 20
				end
			end
    #---------------------------------------------------------------------------
    when "RecoilQuarterOfDamageDealt" # take down / wild charge
			if !user.hasActiveAbility?(:ROCKHEAD) || !user.takesIndirectDamage?
				score *= 0.9
				if user.hp==user.totalhp && (user.hasActiveAbility?(:STURDY) || user.hasActiveItem?(:FOCUSSASH))
					score *= 0.7
				end
				if user.hp*(1.0/user.totalhp)>0.1 && user.hp*(1.0/user.totalhp)<0.4
					score *= 0.8
				end
			end
    #---------------------------------------------------------------------------
    when "RecoilThirdOfDamageDealt", "RecoilThirdOfDamageDealtParalyzeTarget", "RecoilThirdOfDamageDealtBurnTarget" 
			# brave bird / wood hammer / general check
			if !user.hasActiveAbility?(:ROCKHEAD) || !user.takesIndirectDamage?
				score *= 0.9
				if user.hp==user.totalhp && (user.hasActiveAbility?(:STURDY) || user.hasActiveItem?(:FOCUSSASH))
					score *= 0.7
				end
				if user.hp*(1.0/user.totalhp)>0.15 && user.hp*(1.0/user.totalhp)<0.4
					score *= 0.8
				end
			end
			# volt tackle
			if move.function == "RecoilThirdOfDamageDealtParalyzeTarget"
				if user.pbCanParalyze?(target, false)
					miniscore = pbTargetBenefitsFromStatus?(user, target, :PARALYSIS, 100, move, skill)
					miniscore *= 1.1
					if pbHasSetupMove?(user)
						miniscore *= 1.3
					end
					if target.hp==target.totalhp
						miniscore *= 1.2
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
					miniscore-=100
					miniscore*=(move.addlEffect.to_f/100)
					if user.hasActiveAbility?(:SERENEGRACE) && (@battle.field.terrain == :Misty && !target.affectedByTerrain?)
						miniscore*=2
					end
					miniscore+=100
					miniscore/=100.0
					score*=miniscore
				end
			end
			# flare blitz
			if move.function == "RecoilThirdOfDamageDealtBurnTarget"
				if user.pbCanBurn?(target, false)
					miniscore = pbTargetBenefitsFromStatus?(user, target, :BURN, 100, move, skill)
					miniscore *= 1.2
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
					if move.baseDamage>0
						if target.hasActiveAbility?(:STURDY)
							miniscore*=1.1
						end
					end
					miniscore-=100
					miniscore*=(move.addlEffect.to_f/100)
					if user.hasActiveAbility?(:SERENEGRACE) && (@battle.field.terrain == :Misty && !target.affectedByTerrain?)
						miniscore*=2
					end
					miniscore+=100
					miniscore/=100.0
					score*=miniscore
				end
			end
    #---------------------------------------------------------------------------
    when "RecoilHalfOfDamageDealt" # head smash / light of ruin
			if !user.hasActiveAbility?(:ROCKHEAD) || !user.takesIndirectDamage?
				score *= 0.9
				if user.hp==user.totalhp && (user.hasActiveAbility?(:STURDY) || user.hasActiveItem?(:FOCUSSASH))
					score *= 0.7
				end
				if user.hp*(1.0/user.totalhp)>0.2 && user.hp*(1.0/user.totalhp)<0.4
					score *= 0.8
				end
			end;
    #---------------------------------------------------------------------------
    when "EffectivenessIncludesFlyingType" # flying press
			if target.effects[PBEffects::Minimize]
				score*=2
			end
			if @battle.field.effects[PBEffects::Gravity]>0
				score*=0
			end
    #---------------------------------------------------------------------------
    when "CategoryDependsOnHigherDamagePoisonTarget"
      score += 5 if target.pbCanPoison?(user, false)
    #---------------------------------------------------------------------------
    when "CategoryDependsOnHigherDamageIgnoreTargetAbility" # Photon Geyser
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
    when "UseUserBaseDefenseInsteadOfUserBaseAttack"
    #---------------------------------------------------------------------------
    when "UseTargetAttackInsteadOfUserAttack"
    #---------------------------------------------------------------------------
    when "UseTargetDefenseInsteadOfTargetSpDef"
    #---------------------------------------------------------------------------
    when "EnsureNextMoveAlwaysHits"
      score -= 90 if target.effects[PBEffects::Substitute] > 0
      score -= 90 if user.effects[PBEffects::LockOn] > 0
    #---------------------------------------------------------------------------
    when "StartNegateTargetEvasionStatStageAndGhostImmunity"
      if target.effects[PBEffects::Foresight]
        score -= 90
      elsif target.pbHasType?(:GHOST)
        score += 70
      elsif target.stages[:EVASION] <= 0
        score -= 60
      end
    #---------------------------------------------------------------------------
    when "StartNegateTargetEvasionStatStageAndDarkImmunity"
      if target.effects[PBEffects::MiracleEye]
        score -= 90
      elsif target.pbHasType?(:DARK)
        score += 70
      elsif target.stages[:EVASION] <= 0
        score -= 60
      end
    #---------------------------------------------------------------------------
    when "IgnoreTargetDefSpDefEvaStatStages" # chip away
			ministat = 0
			ministat+=target.stages[:EVASION] if target.stages[:EVASION]>0
			ministat+=target.stages[:DEFENSE] if target.stages[:DEFENSE]>0
			ministat+=target.stages[:SPECIAL_DEFENSE] if target.stages[:SPECIAL_DEFENSE]>0
			ministat*=5
			ministat+=100
			ministat/=100.0
			score*=ministat
    #---------------------------------------------------------------------------
    when "TypeIsUserFirstType"
    #---------------------------------------------------------------------------
    when "TypeDependsOnUserIVs"
    #---------------------------------------------------------------------------
    when "TypeAndPowerDependOnUserBerry"
      score -= 90 if !user.item || !user.item.is_berry? || !user.itemActive?
    #---------------------------------------------------------------------------
    when "TypeDependsOnUserPlate", "TypeDependsOnUserMemory", "TypeDependsOnUserDrive"
    #---------------------------------------------------------------------------
    when "TypeDependsOnUserMorpekoFormRaiseUserSpeed1"
      score += 20 if user.stages[:SPEED] <= 0
    #---------------------------------------------------------------------------
    when "TypeAndPowerDependOnWeather" # weather ball
			if [:Rain, :HeavyRain].include?(user.effectiveWeather) && target.hasActiveAbility?([:DRYSKIN, :STORMDRAIN, :WATERABSORB])
				score*=0.1
			elsif [:Sun, :HarshSun].include?(user.effectiveWeather) && target.hasActiveAbility?(:FLASHFIRE)
				score*=0.1
			end
    #---------------------------------------------------------------------------
    when "TypeAndPowerDependOnTerrain"
      score += 40 if @battle.field.terrain != :None
    #---------------------------------------------------------------------------
    when "TargetMovesBecomeElectric" # Electrify
			pricheck=false
			for j in user.moves
				pricheck=true if j.priority>0
			end
			initialscores = 0 #score
			if (user.pbSpeed>pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
				if user.hasActiveAbility?(:VOLTABSORB)
					if user.hp<user.totalhp*0.8
						score*=1.5
					else
						score*=0.1
					end
				end          
				if user.hasActiveAbility?(:LIGHTNINGROD)
					if user.spatk > user.attack && user.statStageAtMax?(:SPECIAL_ATTACK)
						score*=1.5
					else
						score*=0.1
					end
				end
				if user.hasActiveAbility?(:MOTORDRIVE)
					if user.statStageAtMax?[:SPEED]
						score*=1.2
					else
						score*=0.1
					end
				end
				if user.pbHasType?(:GROUND)
					score*=1.3
				end
				if score==initialscores
					score*=0.1
				end
				if pricheck
					score*=0.5
				end
			else
				score*=0
			end
    #---------------------------------------------------------------------------
    when "NormalMovesBecomeElectric" # ion deluge
			maxdam=0
			maxtype = -1
			sleepcheck = false
			sleepcheck = true if target.pbHasMoveFunction?("SleepTarget","SleepTargetIfUserDarkrai")
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				if tempdam>maxdam
					maxdam=tempdam 
					maxtype = m.type
				end  
			end
			if (user.pbSpeed>pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
				score*=0.9
			elsif user.hasActiveAbility?(:MOTORDRIVE)
				if maxtype == :NORMAL
					score*=1.5
				end
			end
			if user.hasActiveAbility?(:LIGHTNINGROD) || user.hasActiveAbility?(:VOLTABSORB)
				if ((user.hp.to_f)/user.totalhp)<0.6
					if maxtype == :NORMAL
						score*=1.5
					end
				end
			end
			if user.pbHasType?(:GROUND)
				score*=1.1
			end
			user.allAllies.each do |b|
				if b.hasActiveAbility?([:MOTORDRIVE, :LIGHTNINGROD, :VOLTABSORB])
					score*=1.2
				end
				if b.pbHasType?(:GROUND)
					score*=1.1
				end
			end
			if maxtype != :NORMAL
				score*=0.5
			end
    #---------------------------------------------------------------------------
    when "HitTwoTimes", "HitTwoTimesTargetThenTargetAlly" # double kick
			if (target.hasActiveItem?(:ROCKYHELMET) || target.hasActiveAbility?([:IRONBARBS, :ROUGHSKIN])) && user.affectedByContactEffect? && move.pbContactMove?(user)
				score*=0.9
			end
			if target.hp==target.totalhp && (target.hasActiveItem?(:FOCUSSASH) || target.hasActiveAbility?(:STURDY))
				score*=1.3
			end
			if target.effects[PBEffects::Substitute]>0
				score*=1.3
			end
			if user.hasActiveItem?(:RAZORFANG) || user.hasActiveItem?(:KINGSROCK)
				score*=1.1
			end
    #---------------------------------------------------------------------------
    when "HitTwoTimesPoisonTarget" # Twineedle
			if user.pbCanPoison?(target, false)
				miniscore = pbTargetBenefitsFromStatus?(user, target, :POISON, 100, move, skill)
				miniscore-=100
				if move.addlEffect.to_f != 100
					miniscore*=(move.addlEffect.to_f/100)
					if user.hasActiveAbility?(:SERENEGRACE) && (@battle.field.terrain == :Misty && !target.affectedByTerrain?)
						miniscore*=2
					end     
				end   
				miniscore+=100
				miniscore/=100.0
				score*=miniscore
			end
			if (target.hasActiveItem?(:ROCKYHELMET) || target.hasActiveAbility?([:IRONBARBS, :ROUGHSKIN])) && user.affectedByContactEffect? && move.pbContactMove?(user)
				score*=0.9
			end
			if target.hp==target.totalhp && (target.hasActiveItem?(:FOCUSSASH) || target.hasActiveAbility?(:STURDY))
				score*=1.3
			end
			if target.effects[PBEffects::Substitute]>0
				score*=1.3
			end
			if user.hasActiveItem?(:RAZORFANG) || user.hasActiveItem?(:KINGSROCK)
				score*=1.1
			end
    #---------------------------------------------------------------------------
    when "HitTwoTimesFlinchTarget"
			if (target.hasActiveItem?(:ROCKYHELMET) || target.hasActiveAbility?([:IRONBARBS, :ROUGHSKIN])) && user.affectedByContactEffect? && move.pbContactMove?(user)
				score*=0.9
			end
			if target.hp==target.totalhp && (target.hasActiveItem?(:FOCUSSASH) || target.hasActiveAbility?(:STURDY))
				score*=1.3
			end
			if target.effects[PBEffects::Substitute]>0
				score*=1.3
			end
			if user.hasActiveItem?(:RAZORFANG) || user.hasActiveItem?(:KINGSROCK)
				score*=1.1
			end
			if target.effects[PBEffects::Substitute]==0 && !target.hasActiveAbility?(:INNERFOCUS)
				if (pbRoughStat(target,:SPEED,skill)<user.pbSpeed) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
					miniscore=100
					miniscore*=1.3
					if target.poisoned? || target.burned? || user.takesHailDamage? || user.takesSandstormDamage? || 
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
      score += 30 if target.effects[PBEffects::Minimize]
    #---------------------------------------------------------------------------
    when "HitThreeTimesPowersUpWithEachHit" # triple kick
			if (target.hasActiveItem?(:ROCKYHELMET) || target.hasActiveAbility?([:IRONBARBS, :ROUGHSKIN])) && user.affectedByContactEffect? && move.pbContactMove?(user)
				score*=0.8
			end
			if target.hp==target.totalhp && (target.hasActiveItem?(:FOCUSSASH) || target.hasActiveAbility?(:STURDY))
				score*=1.3
			end
			if target.effects[PBEffects::Substitute]>0
				score*=1.3
			end
			if user.hasActiveItem?(:RAZORFANG) || user.hasActiveItem?(:KINGSROCK)
				score*=1.2
			end
    #---------------------------------------------------------------------------
    when "HitThreeTimesAlwaysCriticalHit" # surging strikes
			if user.opposes?(target) # is ally
				if (target.hasActiveItem?(:ROCKYHELMET) || target.hasActiveAbility?([:IRONBARBS, :ROUGHSKIN])) && user.affectedByContactEffect? && move.pbContactMove?(user)
					score*=0.8
				end
				if target.hp==target.totalhp && (target.hasActiveItem?(:FOCUSSASH) || target.hasActiveAbility?(:STURDY))
					score*=1.3
				end
				if target.effects[PBEffects::Substitute]>0
					score*=1.3
				end
				if user.hasActiveItem?(:RAZORFANG) || user.hasActiveItem?(:KINGSROCK)
					score*=1.2
				end
			end
			thisinitial = score
			if !target.hasActiveAbility?([:BATTLEARMOR, :SHELLARMOR]) && !user.effects[PBEffects::LaserFocus]
				if !user.opposes?(target) # is ally
					if target.attack>target.spatk
						if target.hasActiveAbility?(:ANGERPOINT)
							if thisinitial>99
								score=0
							else
								score = (100-thisinitial)
								# checking if the recepient can outspeed
								enemycounter = 0
								user.eachOpposing.each do |m|
									next unless target.pbSpeed < m.pbSpeed
									enemycounter += 1
								end
								if enemycounter == 0
									score*=1.3
								else
									score*=0.7
								end
							end
						end
					end
				else
					miniscore = 100
					ministat = 0
					ministat += target.stages[:DEFENSE] if target.stages[:DEFENSE]>0
					ministat += target.stages[:SPECIAL_DEFENSE] if target.stages[:SPECIAL_DEFENSE]>0
					miniscore += 10*ministat
					ministat = 0
					ministat -= user.stages[:ATTACK] if user.stages[:ATTACK]<0
					ministat -= user.stages[:SPECIAL_ATTACK] if user.stages[:SPECIAL_ATTACK]<0
					miniscore += 10*ministat
					if user.effects[PBEffects::FocusEnergy]>0
						miniscore -= 10*user.effects[PBEffects::FocusEnergy]
					end
					miniscore/=100.0
					score*=miniscore
					score*=0.2 if target.hasActiveAbility?(:ANGERPOINT)
				end
			else
				score*=0.1
			end
    #---------------------------------------------------------------------------
    when "HitTwoToFiveTimes", "HitTwoToFiveTimesOrThreeForAshGreninja" # bullet seed
			if (target.hasActiveItem?(:ROCKYHELMET) || target.hasActiveAbility?([:IRONBARBS, :ROUGHSKIN])) && user.affectedByContactEffect? && move.pbContactMove?(user)
				score*=0.7
				score*=0.5 if user.hasActiveAbility?(:SKILLLINK)
			end
			if target.hp==target.totalhp && (target.hasActiveItem?(:FOCUSSASH) || target.hasActiveAbility?(:STURDY))
				score*=1.3
			end
			if target.effects[PBEffects::Substitute]>0
				score*=1.3
			end
			if user.hasActiveItem?(:RAZORFANG) || user.hasActiveItem?(:KINGSROCK)
				score*=1.3
			end
    #---------------------------------------------------------------------------
    when "HitTwoToFiveTimesRaiseUserSpd1LowerUserDef1"
      aspeed = pbRoughStat(user, :SPEED, skill)
      ospeed = pbRoughStat(target, :SPEED, skill)
      if aspeed > ospeed && aspeed * 2 / 3 < ospeed
        score -= 50
      elsif (aspeed < ospeed && aspeed * 1.5 > ospeed) && ($game_variables[MECHANICSVAR] >= 3 && !user.SetupMovesUsed.include?(move.id))
        score += 50
      end
      score += user.stages[:DEFENSE] * 30
    #---------------------------------------------------------------------------
    when "HitOncePerUserTeamMember" # beat up
			thisinitial = score
			livecountuser = -1
			@battle.pbParty(user.index).each do |m|
				livecountuser+=1 if !m.fainted?
			end
			if livecountuser>0
				if (target.hasActiveItem?(:ROCKYHELMET) || target.hasActiveAbility?([:IRONBARBS, :ROUGHSKIN])) && user.affectedByContactEffect? && move.pbContactMove?(user)
					score*=0.7
				end
				if target.hp==target.totalhp && (target.hasActiveItem?(:FOCUSSASH) || target.hasActiveAbility?(:STURDY))
					score*=1.3
				end
				if target.effects[PBEffects::Substitute]>0
					score*=1.3
				end
				if user.hasActiveItem?(:RAZORFANG) || user.hasActiveItem?(:KINGSROCK)
					score*=1.3
				end
				if !user.opposes?(target) # is ally
					if target.attack>target.spatk
						if thisinitial>99
							score=0
						else
							score = (100-thisinitial)
							# checking if the recepient can outspeed
							enemycounter = 0
							user.eachOpposing.each do |m|
								next unless target.pbSpeed < m.pbSpeed
								enemycounter += 1
							end
							if enemycounter == 0
								score*=1.3
							else
								score*=0.7
							end
						end
					end
				else
				end
			end
    #---------------------------------------------------------------------------
    when "AttackAndSkipNextTurn" # Hyper Beam
			thisinitial = score
			if thisinitial<100
				score*=0.5
				for m in target.moves
					score*=0.5 if m.healingMove?
				end
			end
			miniscore=100
			targetlivecount=@battle.pbAbleNonActiveCount(user.idxOpposingSide)
			if targetlivecount>1
				miniscore*=(targetlivecount-1)
				miniscore/=100.0
				miniscore*=0.1
				miniscore=(1-miniscore)
				score*=miniscore
			else
				score*=1.1
			end
			hasAlly = !target.allAllies.empty?
			if hasAlly
				score*=0.5
			end
			userlivecount=-1
			@battle.pbParty(user.index).each do |m|
				userlivecount+=1 if !m.fainted?
			end
			if targetlivecount>1 && userlivecount==1
				score*=0.7
			end
			# use it to finish off
			tempdam = pbRoughDamage(move, user, target, skill, move.baseDamage)
			if targetlivecount==1 && tempdam<(user.hp/3.0)
				score*=1.3
			end
    #---------------------------------------------------------------------------
    when "TwoTurnAttack" # razor wind
			maxdam = 0
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				maxdam = tempdam if tempdam > maxdam
			end
			movecheck = false
			movecheck = true if pbHasSingleTargetProtectMove?(target)
			if !user.hasActiveItem?(:POWERHERB)          
				if maxdam>user.hp
					score*=0.4
				else
					if user.hp*(1.0/user.totalhp)<0.5
						score*=0.6
					end
				end
				if target.effects[PBEffects::TwoTurnAttack]!=0
					if (user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
						score*=2
					else
						score*=0.5
					end
				end
				hasAlly = !target.allAllies.empty?
				if hasAlly
					score*=0.5
				end
				if movecheck
					score*=0.1
				end          
			else
				score*=1.2
				if user.hasActiveAbility?(:UNBURDEN)
					score*=1.5
				end
			end
    #---------------------------------------------------------------------------
		when "TwoTurnAttackOneTurnInSun" # solar beam
			maxdam = 0
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				maxdam = tempdam if tempdam > maxdam
			end
			movecheck = false
			movecheck = true if pbHasSingleTargetProtectMove?(target)
			theresone=false
			@battle.allBattlers.each do |j|
				if (j.isSpecies?(:ZARCOIL) && j.item == :ZARCOILITE && j.willmega)
					theresone=true
				end
			end
			if !user.hasActiveItem?(:POWERHERB) && !user.hasActiveAbility?(:PRESAGE) && 
				 ![:Sun, :HarshSun].include?(user.effectiveWeather) && !theresone
				if maxdam>user.hp
					score*=0.4
				else
					if user.hp*(1.0/user.totalhp)<0.5
						score*=0.6
					end
				end
				if target.effects[PBEffects::TwoTurnAttack]!=0
					if (user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
						score*=2
					else
						score*=0.5
					end
				end
				hasAlly = !target.allAllies.empty?
				if hasAlly
					score*=0.5
				end
				if movecheck
					score*=0.1
				end          
			else
				score*=1.2
				if user.hasActiveAbility?(:UNBURDEN) && ![:Sun, :HarshSun].include?(user.effectiveWeather)
					score*=1.5
				end
			end
    #---------------------------------------------------------------------------
    when "TwoTurnAttackParalyzeTarget" # freeze shock
			maxdam = 0
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				maxdam = tempdam if tempdam > maxdam
			end
			movecheck = false
			movecheck = true if pbHasSingleTargetProtectMove?(target)
			if !user.hasActiveItem?(:POWERHERB)
				if maxdam>user.hp
					score*=0.4
				else
					if user.hp*(1.0/user.totalhp)<0.5
						score*=0.6
					end
				end
				if target.effects[PBEffects::TwoTurnAttack]!=0
					if (user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
						score*=2
					else
						score*=0.5
					end
				end
				hasAlly = !target.allAllies.empty?
				if hasAlly
					score*=0.5
				end
				if movecheck
					score*=0.1
				end          
			else
				score*=1.2
				if user.hasActiveAbility?(:UNBURDEN)
					score*=1.5
				end
			end
			if user.pbCanParalyze?(target, false)
				miniscore = pbTargetBenefitsFromStatus?(user, target, :PARALYSIS, 100, move, skill)
				miniscore *= 1.1
				if pbHasSetupMove?(user)
					miniscore *= 1.3
				end
				if target.hp==target.totalhp
					miniscore *= 1.2
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
				miniscore-=100
				miniscore*=(move.addlEffect.to_f/100)
				if user.hasActiveAbility?(:SERENEGRACE) && (@battle.field.terrain == :Misty && !target.affectedByTerrain?)
					miniscore*=2
				end
				miniscore+=100
				miniscore/=100.0
				score*=miniscore
			end
    #---------------------------------------------------------------------------
    when "TwoTurnAttackBurnTarget" # ice burn
			maxdam = 0
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				maxdam = tempdam if tempdam > maxdam
			end
			movecheck = false
			movecheck = true if pbHasSingleTargetProtectMove?(target)
			if !user.hasActiveItem?(:POWERHERB)
				if maxdam>user.hp
					score*=0.4
				else
					if user.hp*(1.0/user.totalhp)<0.5
						score*=0.6
					end
				end
				if target.effects[PBEffects::TwoTurnAttack]!=0
					if (user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
						score*=2
					else
						score*=0.5
					end
				end
				hasAlly = !target.allAllies.empty?
				if hasAlly
					score*=0.5
				end
				if movecheck
					score*=0.1
				end          
			else
				score*=1.2
				if user.hasActiveAbility?(:UNBURDEN)
					score*=1.5
				end
			end
			if user.pbCanBurn?(target, false)
				miniscore = pbTargetBenefitsFromStatus?(user, target, :BURN, 100, move, skill)
				miniscore *= 1.2
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
				if move.baseDamage>0
					if target.hasActiveAbility?(:STURDY)
						miniscore*=1.1
					end
				end
				miniscore-=100
				miniscore*=(move.addlEffect.to_f/100)
				if user.hasActiveAbility?(:SERENEGRACE) && (@battle.field.terrain == :Misty && !target.affectedByTerrain?)
					miniscore*=2
				end
				miniscore+=100
				miniscore/=100.0
				score*=miniscore
			end
    #---------------------------------------------------------------------------
    when "TwoTurnAttackFlinchTarget" # Sky Attack
			maxdam = 0
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				maxdam = tempdam if tempdam > maxdam
			end
			movecheck = false
			movecheck = true if pbHasSingleTargetProtectMove?(target)
			if !user.hasActiveItem?(:POWERHERB)
				if maxdam>user.hp
					score*=0.4
				else
					if user.hp*(1.0/user.totalhp)<0.5
						score*=0.6
					end
				end
				if target.effects[PBEffects::TwoTurnAttack]!=0
					if (user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
						score*=2
					else
						score*=0.5
					end
				end
				hasAlly = !target.allAllies.empty?
				if hasAlly
					score*=0.5
				end
				if movecheck
					score*=0.1
				end          
			else
				score*=1.2
				if user.hasActiveAbility?(:UNBURDEN)
					score*=1.5
				end
			end
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
    when "TwoTurnAttackRaiseUserSpAtkSpDefSpd2" # Geomancy
			maxdam = 0
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				maxdam = tempdam if tempdam > maxdam
			end
			movecheck=false
			movecheck=true if pbHasPhazingMove?(target, false)
			if !user.hasActiveItem?(:POWERHERB)
				if maxdam>user.hp
					score*=0.4
				else
					if user.hp*(1.0/user.totalhp)<0.5
						score*=0.6
					end
				end
				if user.turnCount<2
					score*=1.5
				else
					score*=0.7
				end
				if target.effects[PBEffects::TwoTurnAttack]!=0 || target.effects[PBEffects::HyperBeam]>0
					score*=2
				end      
				hasAlly = !target.allAllies.empty?
				if hasAlly
					score*=0.5
				end
			else
				score*=2
				if user.hasActiveAbility?(:UNBURDEN)
					score*=1.5
				end
			end
			miniscore=100
			if (target.hasActiveAbility?(:DISGUISE) && target.form == 0) || target.effects[PBEffects::Substitute]>0
				miniscore*=1.3
			end
			hasAlly = !target.allAllies.empty?
			if !hasAlly && move.statusMove? && target.battle.choices[target.index][0] == :SwitchOut
				miniscore*=2
			end
			if (user.hp.to_f)/user.totalhp>0.75
				miniscore*=1.2
			end
			if target.effects[PBEffects::Yawn]>0
				miniscore*=1.7
			end      
			if maxdam*4<user.hp
				miniscore*=1.2
			else
				if move.baseDamage==0 
					miniscore*=0.8
					if maxdam>user.hp
						miniscore*=0.1
					end
				end
			end                  
			if target.pbHasAnyStatus?
				miniscore*=1.2
			end
			if target.asleep?
				miniscore*=1.3
			end
			if target.effects[PBEffects::Encore]>0
				if GameData::Move.get(target.effects[PBEffects::EncoreMove]).base_damage==0       
					miniscore*=1.5
				end          
			end  
			if user.effects[PBEffects::Confusion]>0
				miniscore*=0.5
			end
			if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
				miniscore*=0.3
			end
			if movecheck
				miniscore*=0.5
			end          
			if user.hasActiveAbility?(:SIMPLE)
				miniscore*=2
			end
			if target.hasActiveAbility?(:UNAWARE)
				miniscore*=0.5
			end
			miniscore/=100.0
			score*=miniscore
			miniscore=100
			if user.stages[:SPEED]<0
				ministat=user.stages[:SPEED]
				minimini=5*ministat
				minimini+=100
				minimini/=100.0
				miniscore*=minimini
			end
			ministat=0
			ministat+=target.stages[:ATTACK]
			ministat+=target.stages[:SPECIAL_ATTACK]
			ministat+=target.stages[:SPEED]
			if ministat>0
				minimini=(-5)*ministat
				minimini+=100
				minimini/=100.0
				miniscore*=minimini
			end
			healvar=false
			priovar=false
			for m in target.moves
				healvar=true if m.healingMove?
				priovar=true if m.priority>0
			end
			if (user.pbSpeed>pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
				miniscore*=1.5
			end
			roles = pbGetPokemonRole(user, target)
			if roles.include?("Sweeper")
				miniscore*=1.3
			end
			if user.paralyzed?
				miniscore*=0.5
			end        
			miniscore/=100.0
			if !user.statStageAtMax?(:SPECIAL_ATTACK)
				score*=miniscore
			end
			miniscore=100 
			if user.effects[PBEffects::Toxic]>0
				miniscore*=0.2
			end        
			if pbRoughStat(target,:ATTACK,skill)<pbRoughStat(target,:SPECIAL_ATTACK,skill)
				miniscore*=1.3
			end        
			if roles.include?("Physical Wall") || roles.include?("Special Wall")
				miniscore*=1.3
			end
			if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON))
				miniscore*=1.2
			end
			healmove=false
			for j in user.moves
				healmove=true if j.healingMove?
			end
			if healmove
				miniscore*=1.3
			end
			if user.pbHasMove?(:LEECHSEED)
				miniscore*=1.3
			end
			if user.pbHasMove?(:PAINSPLIT)
				miniscore*=1.2
			end        
			miniscore/=100.0
			if !user.statStageAtMax?(:SPECIAL_DEFENSE)
				score*=miniscore
			end
			miniscore=100 
			if user.stages[:SPECIAL_ATTACK]<0            
				ministat=user.stages[:SPECIAL_ATTACK]
				minimini=5*ministat
				minimini+=100
				minimini/=100.0
				miniscore*=minimini
			end        
			if (user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
				miniscore*=0.8          
			end
			if @battle.field.effects[PBEffects::TrickRoom]!=0
				miniscore*=0.2
			else
				movecheck3=false
				for j in target.moves
					movecheck3=true if j.id == :TRICKROOM
				end
				miniscore*=0.2 if movecheck3
			end        
			miniscore/=100.0
			if !user.statStageAtMax?(:SPEED)
				score*=miniscore=0
			end
			if user.hasActiveAbility?(:CONTRARY)
				score*=0
			end
			if user.statStageAtMax?(:SPECIAL_ATTACK) && user.statStageAtMax?(:SPECIAL_DEFENSE) && user.statStageAtMax?(:SPEED)
				score*=0
			end
			if $game_variables[MECHANICSVAR] >= 3 && user.SetupMovesUsed.include?(move.id)
				score = 0
			end
    #---------------------------------------------------------------------------
    when "TwoTurnAttackChargeRaiseUserDefense1"
			maxdam = 0
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				maxdam = tempdam if tempdam > maxdam
			end
			movecheck = false
			movecheck = true if pbHasSingleTargetProtectMove?(target)
			if !user.hasActiveItem?(:POWERHERB)
				if maxdam>user.hp
					score*=0.4
				else
					if user.hp*(1.0/user.totalhp)<0.5
						score*=0.6
					end
				end
				if target.effects[PBEffects::TwoTurnAttack]!=0
					if (user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
						score*=2
					else
						score*=0.5
					end
				end
				hasAlly = !target.allAllies.empty?
				if hasAlly
					score*=0.5
				end
				if movecheck
					score*=0.1
				end          
			else
				score*=1.2
				if user.hasActiveAbility?(:UNBURDEN)
					score*=1.5
				end
			end
			miniscore=100
			if user.effects[PBEffects::Substitute]>0 || (user.isSpecies?(:MIMIKYU) && user.form == 0)
				miniscore*=1.3
			end
			if (user.hp.to_f)/user.totalhp>0.75
				miniscore*=1.1
			end    
			if target.effects[PBEffects::HyperBeam]>0
				miniscore*=1.2
			end
			if target.effects[PBEffects::Yawn]>0
				miniscore*=1.3
			end
			for j in target.moves
				tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
				maxdam = tempdam if tempdam>maxdam
			end  
			if maxdam<(user.hp/3.0)
				miniscore*=1.1
			end  
			if user.turnCount<2
				miniscore*=1.1
			end
			if target.pbHasAnyStatus?
				miniscore*=1.1
			end
			if target.asleep?
				miniscore*=1.3
			end
			if target.effects[PBEffects::Encore]>0
				if GameData::Move.get(target.effects[PBEffects::EncoreMove]).base_damage==0
					miniscore*=1.3
				end          
			end  
			if user.effects[PBEffects::Confusion]>0
				miniscore*=0.3
			end
			if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
				miniscore*=0.3
			end
			if user.effects[PBEffects::Toxic]>0
				miniscore*=0.2
			end
			miniscore*=0.2 if pbHasPhazingMove?(target) 
			if user.hasActiveAbility?(:SIMPLE)
				miniscore*=2
			end
			if target.hasActiveAbility?(:UNAWARE)
				miniscore*=0.5
			end
			hasAlly = !target.allAllies.empty?
			if hasAlly
				miniscore*=0.3
			end
			if user.stages[:DEFENSE]>0
				ministat=user.stages[:DEFENSE]
				minimini=-15*ministat
				minimini+=100          
				minimini/=100.0          
				miniscore*=minimini
			end
			if pbRoughStat(target,:ATTACK,skill)>pbRoughStat(target,:SPECIAL_ATTACK,skill)
				miniscore*=1.3
			end
			for j in target.moves
				tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
				maxdam=tempdam if tempdam>maxdam
			end  
			if (maxdam.to_f/user.hp)<0.12
				miniscore*=0.3
			end
			if user.hasActiveItem?(:LEFTOVERS) || 
				(user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON))
				miniscore*=1.2
			end
			for m in user.moves
				miniscore*=1.3 if m.healingMove?
			end
			if user.pbHasMove?(:LEECHSEED)
				miniscore*=1.3
			end
			if user.pbHasMove?(:PAINSPLIT)
				miniscore*=1.2
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
			if user.statStageAtMax?(:DEFENSE) 
				miniscore=1
			end       
			if user.hasActiveAbility?(:CONTRARY)
				miniscore*=0.5
			end                  
			score*=miniscore
    #---------------------------------------------------------------------------
    when "TwoTurnAttackChargeRaiseUserSpAtk1"
      aspeed = pbRoughStat(user, :SPEED, skill)
      ospeed = pbRoughStat(target, :SPEED, skill)
      if ((aspeed > ospeed && user.hp > user.totalhp / 3) || user.hp > user.totalhp / 2) && ($game_variables[MECHANICSVAR] >= 3 && !user.SetupMovesUsed.include?(move.id))
        score += 60
      else
        score -= 90
      end
      score += user.stages[:SPECIAL_ATTACK] * 20
    #---------------------------------------------------------------------------
    when "TwoTurnAttackInvulnerableUnderground" # dig
			targetlivecount=@battle.pbAbleNonActiveCount(user.idxOpposingSide)
			userlivecount=-1
			@battle.pbParty(user.index).each do |m|
				userlivecount+=1 if !m.fainted?
			end
			if target.poisoned?|| target.burned? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::TwoTurnAttack] || target.effects[PBEffects::Curse]
				score*=1.2
			else
				if targetlivecount>1
					score*=0.8
				end
			end
			if user.pbHasAnyStatus? || user.effects[PBEffects::Curse] || user.effects[PBEffects::Attract]>-1 || user.effects[PBEffects::Confusion]>0
				score*=0.5
			end
			if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON))
				score*=1.1
			end
			if user.pbOwnSide.effects[PBEffects::Tailwind]>0 || user.pbOwnSide.effects[PBEffects::Reflect]>0 || user.pbOwnSide.effects[PBEffects::LightScreen]>0
				score*=0.7
			end
			if target.effects[PBEffects::PerishSong]!=0 && user.effects[PBEffects::PerishSong]==0
				score*=1.3
			end
			if user.hasActiveItem?(:POWERHERB)
				score*=1.5
			end
			if user.hasActiveAbility?(:NOGUARD) || target.hasActiveAbility?(:NOGUARD)
				score*=0.1
			end
			if (user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
				score*=1.1
			else
				score*=0.8
				for m in target.moves
					miniscore*=0.5 if m.healingMove?
				end
				nevermiss=false
				for m in user.moves
					nevermiss=true if m.accuracy==0
				end
				if nevermiss
					score*=0.7
				end
			end
			for m in target.moves
				score*=0.3 if [:EARTHQUAKE].include?(m.id)
			end
    #---------------------------------------------------------------------------
    when "TwoTurnAttackInvulnerableUnderwater" # dive
			targetlivecount=@battle.pbAbleNonActiveCount(user.idxOpposingSide)
			userlivecount=-1
			@battle.pbParty(user.index).each do |m|
				userlivecount+=1 if !m.fainted?
			end
			if target.poisoned?|| target.burned? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::TwoTurnAttack] || target.effects[PBEffects::Curse]
				score*=1.2
			else
				if targetlivecount>1
					score*=0.8
				end
			end
			if user.pbHasAnyStatus? || user.effects[PBEffects::Curse] || user.effects[PBEffects::Attract]>-1 || user.effects[PBEffects::Confusion]>0
				score*=0.5
			end
			if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON))
				score*=1.1
			end
			if user.pbOwnSide.effects[PBEffects::Tailwind]>0 || user.pbOwnSide.effects[PBEffects::Reflect]>0 || user.pbOwnSide.effects[PBEffects::LightScreen]>0
				score*=0.7
			end
			if target.effects[PBEffects::PerishSong]!=0 && user.effects[PBEffects::PerishSong]==0
				score*=1.3
			end
			if user.hasActiveItem?(:POWERHERB)
				score*=1.5
			end
			if user.hasActiveAbility?(:NOGUARD) || target.hasActiveAbility?(:NOGUARD)
				score*=0.1
			end
			if (user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
				score*=1.1
			else
				score*=0.8
				for m in target.moves
					miniscore*=0.5 if m.healingMove?
				end
				nevermiss=false
				for m in user.moves
					nevermiss=true if m.accuracy==0
				end
				if nevermiss
					score*=0.7
				end
			end
			for m in target.moves
				score*=0.3 if [:SURF].include?(m.id)
			end
    #---------------------------------------------------------------------------
    when "TwoTurnAttackInvulnerableInSky" # Fly
			targetlivecount=@battle.pbAbleNonActiveCount(user.idxOpposingSide)
			userlivecount=-1
			@battle.pbParty(user.index).each do |m|
				userlivecount+=1 if !m.fainted?
			end
			if target.poisoned? || target.burned? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::TwoTurnAttack] || target.effects[PBEffects::Curse]
				score*=1.2
			else
				if targetlivecount>1
					score*=0.8
				end
			end
			if user.pbHasAnyStatus? || user.effects[PBEffects::Curse] || user.effects[PBEffects::Attract]>-1 || user.effects[PBEffects::Confusion]>0
				score*=0.5
			end
			if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON))
				score*=1.1
			end
			if user.pbOwnSide.effects[PBEffects::Tailwind]>0 || user.pbOwnSide.effects[PBEffects::Reflect]>0 || user.pbOwnSide.effects[PBEffects::LightScreen]>0
				score*=0.7
			end
			if target.effects[PBEffects::PerishSong]!=0 && user.effects[PBEffects::PerishSong]==0
				score*=1.3
			end
			if user.hasActiveItem?(:POWERHERB)
				score*=1.5
			end
			if user.hasActiveAbility?(:NOGUARD) || target.hasActiveAbility?(:NOGUARD)
				score*=0.1
			end
			if (user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
				score*=1.1
			else
				score*=0.8
				for m in target.moves
					miniscore*=0.5 if m.healingMove?
				end
				nevermiss=false
				for m in user.moves
					nevermiss=true if m.accuracy==0
				end
				if nevermiss
					score*=0.7
				end
			end
			for m in target.moves
				score*=0.3 if [:THUNDER, :HURRICANE].include?(m.id)
			end
			if @battle.field.effects[PBEffects::Gravity]>0
				score*=0
			end
    #---------------------------------------------------------------------------
    when "TwoTurnAttackInvulnerableInSkyParalyzeTarget" # Bounce
			if user.pbCanParalyze?(target, false)
				miniscore = pbTargetBenefitsFromStatus?(user, target, :PARALYSIS, 100, move, skill)
				miniscore *= 1.1
				if pbHasSetupMove?(user)
					miniscore *= 1.3
				end
				if target.hp==target.totalhp
					miniscore *= 1.2
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
				miniscore-=100
				miniscore*=(move.addlEffect.to_f/100)
				if user.hasActiveAbility?(:SERENEGRACE) && (@battle.field.terrain == :Misty && !target.affectedByTerrain?)
					miniscore*=2
				end
				miniscore+=100
				miniscore/=100.0
				score*=miniscore
			end
			targetlivecount=@battle.pbAbleNonActiveCount(user.idxOpposingSide)
			userlivecount=-1
			@battle.pbParty(user.index).each do |m|
				userlivecount+=1 if !m.fainted?
			end
			if target.poisoned?|| target.burned? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::TwoTurnAttack] || target.effects[PBEffects::Curse]
				score*=1.2
			else
				if targetlivecount>1
					score*=0.8
				end
			end
			if user.pbHasAnyStatus? || user.effects[PBEffects::Curse] || user.effects[PBEffects::Attract]>-1 || user.effects[PBEffects::Confusion]>0
				score*=0.5
			end
			if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON))
				score*=1.1
			end
			if user.pbOwnSide.effects[PBEffects::Tailwind]>0 || user.pbOwnSide.effects[PBEffects::Reflect]>0 || user.pbOwnSide.effects[PBEffects::LightScreen]>0
				score*=0.7
			end
			if target.effects[PBEffects::PerishSong]!=0 && user.effects[PBEffects::PerishSong]==0
				score*=1.3
			end
			if user.hasActiveItem?(:POWERHERB)
				score*=1.5
			end
			if user.hasActiveAbility?(:NOGUARD) || target.hasActiveAbility?(:NOGUARD)
				score*=0.1
			end
			if (user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
				score*=1.1
			else
				score*=0.8
				for m in target.moves
					miniscore*=0.5 if m.healingMove?
				end
				nevermiss=false
				for m in user.moves
					nevermiss=true if m.accuracy==0
				end
				if nevermiss
					score*=0.7
				end
			end
			for m in target.moves
				score*=0.3 if [:THUNDER, :HURRICANE].include?(m.id)
			end
			if @battle.field.effects[PBEffects::Gravity]>0
				score*=0
			end
    #---------------------------------------------------------------------------
    when "TwoTurnAttackInvulnerableInSkyTargetCannotAct" # sky drop
			if target.pbHasType?(:FLYING)
				score = 5          
			end
			targetlivecount=@battle.pbAbleNonActiveCount(user.idxOpposingSide)
			userlivecount=-1
			@battle.pbParty(user.index).each do |m|
				userlivecount+=1 if !m.fainted?
			end
			if target.poisoned?|| target.burned? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::TwoTurnAttack] || target.effects[PBEffects::Curse]
				score*=1.2
			else
				if targetlivecount>1
					score*=0.8
				end
			end
			if user.pbHasAnyStatus? || user.effects[PBEffects::Curse] || user.effects[PBEffects::Attract]>-1 || user.effects[PBEffects::Confusion]>0
				score*=0.5
			end
			if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON))
				score*=1.1
			end
			if user.pbOwnSide.effects[PBEffects::Tailwind]>0 || user.pbOwnSide.effects[PBEffects::Reflect]>0 || user.pbOwnSide.effects[PBEffects::LightScreen]>0
				score*=0.7
			end
			if target.effects[PBEffects::PerishSong]!=0 && user.effects[PBEffects::PerishSong]==0
				score*=1.3
			end
			if user.hasActiveItem?(:POWERHERB)
				score*=1.5
			end
			if user.hasActiveAbility?(:NOGUARD) || target.hasActiveAbility?(:NOGUARD)
				score*=0.1
			end
			if (user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
				score*=1.1
			else
				score*=0.8
				for m in target.moves
					miniscore*=0.5 if m.healingMove?
				end
				nevermiss=false
				for m in user.moves
					nevermiss=true if m.accuracy==0
				end
				if nevermiss
					score*=0.7
				end
			end
			for m in target.moves
				score*=0.3 if [:THUNDER, :HURRICANE].include?(m.id)
			end
			if @battle.field.effects[PBEffects::Gravity]>0
				score*=0
			end
    #---------------------------------------------------------------------------
    when "TwoTurnAttackInvulnerableRemoveProtections" # phantom / shadow force
			targetlivecount=@battle.pbAbleNonActiveCount(user.idxOpposingSide)
			userlivecount=-1
			@battle.pbParty(user.index).each do |m|
				userlivecount+=1 if !m.fainted?
			end
			if target.poisoned?|| target.burned? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::TwoTurnAttack] || target.effects[PBEffects::Curse]
				score*=1.2
			else
				if targetlivecount>1
					score*=0.8
				end
			end
			if user.pbHasAnyStatus? || user.effects[PBEffects::Curse] || user.effects[PBEffects::Attract]>-1 || user.effects[PBEffects::Confusion]>0
				score*=0.5
			end
			if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON))
				score*=1.1
			end
			if user.pbOwnSide.effects[PBEffects::Tailwind]>0 || user.pbOwnSide.effects[PBEffects::Reflect]>0 || user.pbOwnSide.effects[PBEffects::LightScreen]>0
				score*=0.7
			end
			if target.effects[PBEffects::PerishSong]!=0 && user.effects[PBEffects::PerishSong]==0
				score*=1.3
			end
			if user.hasActiveItem?(:POWERHERB)
				score*=1.5
			end
			if user.hasActiveAbility?(:NOGUARD) || target.hasActiveAbility?(:NOGUARD)
				score*=0.1
			end
			if (user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
				score*=1.1
			else
				score*=0.8
				for m in target.moves
					miniscore*=0.5 if m.healingMove?
				end
				nevermiss=false
				for m in user.moves
					nevermiss=true if m.accuracy==0
				end
				if nevermiss
					score*=0.7
				end
			end
    #---------------------------------------------------------------------------
    when "MultiTurnAttackPreventSleeping" # uproar
			if target.asleep?
				score*=0.7
			end
			if target.pbHasMove?(:REST)
				score*=1.8
			end
			targetlivecount=@battle.pbAbleNonActiveCount(user.idxOpposingSide)
			if targetlivecount>=1 || user.hasActiveAbility?(:SHADOWTAG) || target.effects[PBEffects::MeanLook]>0
				score*=1.1
			end        
			typemod=move.pbCalcTypeMod(move.pbCalcType(user), user, target)
			if typemod<4
				score*=0.7
			end
			if user.hp*(1.0/user.totalhp)<0.75
				score*=0.75
			end
			if user.stages[:SPECIAL_ATTACK]<0
				minimini = user.stages[:SPECIAL_ATTACK]
				minimini*=5
				minimini+=100
				minimini/=100.0
				score*=minimini
			end
			if targetlivecount>1
				miniscore = targetlivecount*0.05
				miniscore = 1-miniscore
				score*=miniscore
			end
    #---------------------------------------------------------------------------
    when "MultiTurnAttackConfuseUserAtEnd" # outrage
			thisinitial = score
			targetlivecount=@battle.pbAbleNonActiveCount(user.idxOpposingSide)
			if user.pbCanConfuseSelf?(false)
				if thisinitial<100
					score*=0.85
				end
				if user.hasActiveItem?([:PERSIMBERRY, :LUMBERRY])
					score*=1.3
				end
				if user.stages[:ATTACK]>0
					miniscore = (-5)*user.stages[:ATTACK]
					miniscore+=100
					miniscore/=100.0
					score*=miniscore
				end
				if targetlivecount>2
					miniscore=100
					miniscore*=(targetlivecount-1)
					miniscore*=0.01
					miniscore*=0.025
					miniscore=1-miniscore
					score*=miniscore
				end
				if pbHasSingleTargetProtectMove?(target)
					score*=1.1
				end
				for m in target.moves
					score*=0.7 if m.healingMove?
				end
			else
				score *= 1.2
			end  
			if move.id == :OUTRAGE
				fairyvar = false
				@battle.pbParty(target.index).each do |m|
					next if m.nil?
					fairyvar=true if m.hasType?(:FAIRY)
				end
				if fairyvar
					score*=0.8
				end
			elsif move.id == :THRASH
				ghostvar = false
				@battle.pbParty(target.index).each do |m|
					next if m.nil?
					ghostvar=true if m.hasType?(:GHOST)
				end
				if ghostvar
					score*=0.8
				end
			end
    #---------------------------------------------------------------------------
    when "MultiTurnAttackPowersUpEachTurn" # Rollout
			maxdam = 0
			movecheck = false
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				maxdam = tempdam if tempdam > maxdam
			end
			if pbHasSingleTargetProtectMove?(target)
				movecheck = true
			end
			targetlivecount=@battle.pbAbleNonActiveCount(user.idxOpposingSide)
			if targetlivecount>=1 || user.hasActiveAbility?(:SHADOWTAG) || target.effects[PBEffects::MeanLook]>0
				score*=1.1
			end
			typemod=move.pbCalcTypeMod(move.pbCalcType(user), user, target)
			if typemod<4
				score*=0.7
			end
			if user.hp*(1.0/user.totalhp)<0.75
				score*=0.75
			end
			if user.stages[:SPECIAL_ATTACK]<0
				minimini = user.stages[:SPECIAL_ATTACK]
				minimini*=5
				minimini+=100
				minimini/=100.0
				score*=minimini
			end
			if targetlivecount>1
				miniscore = 1 - (targetlivecount*0.05)
				score*=miniscore
			end
			if user.paralyzed?
				score*=0.5
			end
			if user.effects[PBEffects::Confusion]>0
				score*=0.5
			end
			if user.effects[PBEffects::Attract]>=0
				score*=0.5
			end
			if user.effects[PBEffects::DefenseCurl]
				score*=1.2
			end
			if maxdam*3<user.hp
				score*=1.5
			end
			if movecheck
				score*=0.8
			end
			if (user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
				score*=1.3
			end
    #---------------------------------------------------------------------------
    when "MultiTurnAttackBideThenReturnDoubleDamage" # bide
			maxdam = 0
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				maxdam = tempdam if tempdam > maxdam
			end
			movecheck = false
			statmove = false
			movelength = -1
			for m in target.moves
				if m.baseDamage == 0
					statmove = true
				else
					movelength += 1
				end
			end
			movecheck = true if pbHasSetupMove?(target)
			if (user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY))
				score*=1.2
			end 
			miniscore = user.hp*(1.0/user.totalhp)
			score*=miniscore
			if maxdam*2 > user.hp
				score*=0.2
			end
			if user.hp*3<user.totalhp
				score*=0.7
			end
			if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON))
				score*=1.1
			end
			if (user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
				score*=1.3
			end
			if movecheck
				score*=0.5
			end
			if statmove
				score*=0.8
			else
				if movelength==4
					score*=1.3
				end
			end
    #---------------------------------------------------------------------------
    when "HealUserFullyAndFallAsleep" # rest
			maxdam = 0
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				maxdam = tempdam if tempdam > maxdam
			end
			if maxdam>user.hp
				if maxdam>(user.hp*1.5)
					score=0
				else
					score*=5
				end
			else
				if maxdam*1.5>user.hp
					score*=2
				end
				if (user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
					if maxdam*2>user.hp
						score*=5
					end                
				end
			end
			if pbHasSetupMove?(target)
				score*=0.7
			end 
			if (user.hp.to_f)/user.totalhp<0.5
				score*=1.5       
			else
				score*=0.5
			end  
			if target.poisoned? || target.burned? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse]
				score*=1.3
				if target.effects[PBEffects::Toxic]>0
					score*=1.3
				end
			end
			if user.poisoned?
				score*=1.3
				if user.effects[PBEffects::Toxic]>0
					score*=1.3
				end
			end
			if user.burned?
				score*=1.3
				if user.spatk<user.attack
					score*=1.5
				end
			end
			if user.frozen?
				score*=1.3
				if user.spatk>user.attack
					score*=1.5
				end
			end
			if user.paralyzed?
				score*=1.3
			end
			if user.effects[PBEffects::Toxic]>0
				score*=0.5
				if user.effects[PBEffects::Toxic]>4
					score*=0.5
				end          
			end
			if user.paralyzed? || user.effects[PBEffects::Attract]>=0 || user.effects[PBEffects::Confusion]>0
				score*=1.1
			end
			sleepcheck = false
			for m in target.moves
				score*=1.2 if [:SUPERPOWER, :OVERHEAT, :DRACOMETEOR, :LEAFSTORM, :FLEURCANNON, :PSYCHOBOOST].include?(m.id)
				sleepcheck = true if [:WAKEUPSLAP, :NIGHTMARE, :DREAMEATER].include?(m.id)
			end
			if user.hp*(1.0/user.totalhp)>=0.8
				score*=0
			end
			if !user.hasActiveItem?([:CHESTOBERRY, :LUMBERRY]) && 
				 !(user.hasActiveAbility?(:HYDRATION) && [:Rain, :HeavyRain].include?(user.effectiveWeather))
				score*=0.8
				if maxdam*2 > user.totalhp
					score*=0.4
				else
					if maxdam*3 < user.totalhp
						score*=1.3
					end
				end
				if sleepcheck || target.hasActiveAbility?(:BADDREAMS)
					score*=0.7
				end
				if user.pbHasMove?(:SLEEPTALK)
					score*=1.3
				end 
				if user.pbHasMove?(:SNORE)
					score*=1.2
				end 
				if user.hasActiveAbility?(:SHEDSKIN)
					score*=1.1
				end
				if user.hasActiveAbility?(:EARLYBIRD)
					score*=1.1
				end
				hasAlly = !target.allAllies.empty?
				if hasAlly
					score*=0.8
				end
			else
				if user.hasActiveItem?([:CHESTOBERRY, :LUMBERRY])
					if user.hasActiveAbility?(:HARVEST)
						score*=1.2
					else
						score*=0.8
					end
				end
			end
			if user.pbHasAnyStatus?
				score*=1.4
				if user.effects[PBEffects::Toxic]>0
					score*=1.2
				end
			end
			if !user.pbCanSleep?(user,false)
				score*=0
			end
    #---------------------------------------------------------------------------
    when "HealUserHalfOfTotalHP" # recover
			maxdam = 0
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				maxdam = tempdam if tempdam > maxdam
			end
			if maxdam>user.hp
				if maxdam>(user.hp*1.5)
					score=0
				else
					score*=5
				end
			else
				if maxdam*1.5>user.hp
					score*=2
				end
				if (user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
					if maxdam*2>user.hp
						score*=5
					end                
				end
			end
			if pbHasSetupMove?(target)
				score*=0.7
			end 
			if (user.hp.to_f)/user.totalhp<0.5
				score*=1.5
				if user.effects[PBEffects::Curse]
					score*=2
				end
				if user.hp*4<user.totalhp
					if user.poisoned?
						score*=1.5
					end
					if user.effects[PBEffects::LeechSeed]>=0
						score*=2
					end
					if user.hp<user.totalhp*0.13
						if user.burned?
							score*=2
						end
						if user.takesHailDamage? || user.takesSandstormDamage?
							score*=2
						end  
					end            
				end          
			else
				score*=0.9
			end  
			if user.effects[PBEffects::Toxic]>0
				score*=0.5
				if user.effects[PBEffects::Toxic]>4
					score*=0.5
				end          
			end
			if user.paralyzed? || user.effects[PBEffects::Attract]>=0 || user.effects[PBEffects::Confusion]>0
				score*=1.1
			end
			if target.poisoned? || target.burned? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse]
				score*=1.3
				if target.effects[PBEffects::Toxic]>0
					score*=1.3
				end
			end
			for m in target.moves
				score*=1.2 if [:SUPERPOWER, :OVERHEAT, :DRACOMETEOR, :LEAFSTORM, :FLEURCANNON, :PSYCHOBOOST].include?(m.id)
			end
			if target.effects[PBEffects::HyperBeam]>0
				score*=1.2
			end
			if [:Sun, :HarshSun].include?(user.effectiveWeather) || user.hasActiveAbility?(:PRESAGE)
				score*=1.3
			elsif [:None, :StrongWinds].include?(user.effectiveWeather)
				score*=1.1
			else
				score*=0.5
			end
			if ((user.hp.to_f)/user.totalhp)>0.8
				score=0
			elsif ((user.hp.to_f)/user.totalhp)>0.6
				score*=0.6
			elsif ((user.hp.to_f)/user.totalhp)<0.25
				score*=2
			end  
			if user.effects[PBEffects::Wish]>0
				score=0
			end
    #---------------------------------------------------------------------------
    when "HealUserDependingOnWeather" # synthesis
			maxdam = 0
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				maxdam = tempdam if tempdam > maxdam
			end
			if maxdam>user.hp
				if maxdam>(user.hp*1.5)
					score=0
				else
					score*=5
				end
			else
				if maxdam*1.5>user.hp
					score*=2
				end
				if (user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
					if maxdam*2>user.hp
						score*=5
					end                
				end
			end
			if pbHasSetupMove?(target)
				score*=0.7
			end 
			if (user.hp.to_f)/user.totalhp<0.5
				score*=1.5
				if user.effects[PBEffects::Curse]
					score*=2
				end
				if user.hp*4<user.totalhp
					if user.poisoned?
						score*=1.5
					end
					if user.effects[PBEffects::LeechSeed]>=0
						score*=2
					end
					if user.hp<user.totalhp*0.13
						if user.burned?
							score*=2
						end
						if user.takesHailDamage? || user.takesSandstormDamage?
							score*=2
						end  
					end            
				end          
			else
				score*=0.9
			end  
			if user.effects[PBEffects::Toxic]>0
				score*=0.5
				if user.effects[PBEffects::Toxic]>4
					score*=0.5
				end          
			end
			if user.paralyzed? || user.effects[PBEffects::Attract]>=0 || user.effects[PBEffects::Confusion]>0
				score*=1.1
			end
			if target.poisoned? || target.burned? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse]
				score*=1.3
				if target.effects[PBEffects::Toxic]>0
					score*=1.3
				end
			end
			for m in target.moves
				score*=1.2 if [:SUPERPOWER, :OVERHEAT, :DRACOMETEOR, :LEAFSTORM, :FLEURCANNON, :PSYCHOBOOST].include?(m.id)
			end
			if target.effects[PBEffects::HyperBeam]>0
				score*=1.2
			end
			if ((user.hp.to_f)/user.totalhp)>0.8
				score=0
			elsif ((user.hp.to_f)/user.totalhp)>0.6
				score*=0.6
			elsif ((user.hp.to_f)/user.totalhp)<0.25
				score*=2
			end  
			if user.effects[PBEffects::Wish]>0
				score=0
			end
    #---------------------------------------------------------------------------
    when "HealUserDependingOnSandstorm" # shore up
			maxdam = 0
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				maxdam=tempdam if tempdam>maxdam
			end
			if maxdam>user.hp
				if maxdam>(user.hp*1.5)
					score=0
				else
					score*=5
				end
			else
				if maxdam*1.5>user.hp
					score*=2
				end
				if (user.pbSpeed<pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
					if maxdam*2>user.hp
						score*=5
					end 
				end              
			end
			if pbHasSetupMove?(target, false)
				score*=0.7
			end 
			if (user.hp.to_f)/user.totalhp<0.5
				score*=1.5
				if user.effects[PBEffects::Curse]
					score*=2
				end
				if user.hp*4<user.totalhp
					if user.poisoned?
						score*=1.5
					end
					if user.effects[PBEffects::LeechSeed]>=0
						score*=2
					end
					if user.hp<user.totalhp*0.13
						if user.burned?
							score*=2
						end
						if !user.takesHailDamage? || !user.takesSandstormDamage?
							score*=2
						end  
					end            
				end          
			else
				score*=0.9
			end  
			if user.effects[PBEffects::Toxic]>0
				score*=0.5
				if user.effects[PBEffects::Toxic]>4
					score*=0.5
				end          
			end
			if user.paralyzed? || user.effects[PBEffects::Attract]>=0 || user.effects[PBEffects::Confusion]>0
				score*=1.1
			end
			if target.poisoned? || target.burned? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse]
				score*=1.3
				if target.effects[PBEffects::Toxic]>0
					score*=1.3
				end
			end
			sleepcheck = false
			for m in target.moves
				score*=1.2 if [:SUPERPOWER, :OVERHEAT, :DRACOMETEOR, :LEAFSTORM, :FLEURCANNON, :PSYCHOBOOST].include?(m.id)
			end
			if target.effects[PBEffects::HyperBeam]>0
				score*=1.2
			end
			if user.effectiveWeather == :Sandstorm || user.hasActiveAbility?(:PRESAGE)
				score*=1.5       
			end
			if ((user.hp.to_f)/user.totalhp)>0.8
				score=0
			elsif ((user.hp.to_f)/user.totalhp)>0.6
				score*=0.6
			elsif ((user.hp.to_f)/user.totalhp)<0.25
				score*=2
			end     
			if user.effects[PBEffects::Wish]>0
				score=0
			end
    #---------------------------------------------------------------------------
    when "HealUserHalfOfTotalHPLoseFlyingTypeThisTurn" # roost
			maxdam = 0
			besttype = -1
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				if tempdam > maxdam
					maxdam = tempdam
					besttype = m.type
				end
			end
			if maxdam>user.hp
				if maxdam>(user.hp*1.5)
					score=0
				else
					score*=5
				end
			else
				if maxdam*1.5>user.hp
					score*=2
				end
				if (user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
					if maxdam*2>user.hp
						score*=5
					end                
				end
			end
			if pbHasSetupMove?(target)
				score*=0.7
			end 
			if (user.hp.to_f)/user.totalhp<0.5
				score*=1.5
				if user.effects[PBEffects::Curse]
					score*=2
				end
				if user.hp*4<user.totalhp
					if user.poisoned?
						score*=1.5
					end
					if user.effects[PBEffects::LeechSeed]>=0
						score*=2
					end
					if user.hp<user.totalhp*0.13
						if user.burned?
							score*=2
						end
						if user.takesHailDamage? || user.takesSandstormDamage?
							score*=2
						end  
					end            
				end          
			else
				score*=0.9
			end  
			if user.effects[PBEffects::Toxic]>0
				score*=0.5
				if user.effects[PBEffects::Toxic]>4
					score*=0.5
				end          
			end
			if user.paralyzed? || user.effects[PBEffects::Attract]>=0 || user.effects[PBEffects::Confusion]>0
				score*=1.1
			end
			if target.poisoned? || target.burned? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse]
				score*=1.3
				if target.effects[PBEffects::Toxic]>0
					score*=1.3
				end
			end
			for m in target.moves
				score*=1.2 if [:SUPERPOWER, :OVERHEAT, :DRACOMETEOR, :LEAFSTORM, :FLEURCANNON, :PSYCHOBOOST].include?(m.id)
			end
			if target.effects[PBEffects::HyperBeam]>0
				score*=1.2
			end
			if besttype!=-1
				if (user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
					if besttype == :ROCK || besttype == :ICE || besttype == :ELECTRIC
						score*=1.5
					else
						if besttype == :BUG || besttype == :FIGHTING || besttype == :GRASS || besttype == :GROUND
							score*=0.5
						end
					end
				end
			end
			if ((user.hp.to_f)/user.totalhp)>0.8
				score=0
			elsif ((user.hp.to_f)/user.totalhp)>0.6
				score*=0.6
			elsif ((user.hp.to_f)/user.totalhp)<0.25
				score*=2
			end  
			if user.effects[PBEffects::Wish]>0
				score=0
			end
    #---------------------------------------------------------------------------
    when "CureTargetStatusHealUserHalfOfTotalHP" # purify
			if target.opposes?(user) && target.status == :NONE
				score*=0
			else
				score*=1.5
				if target.hp>target.totalhp*0.8
					score*=0.8
				else
					if target.hp>target.totalhp*0.3
						score*=2
					end            
				end
				toxicturns = ($game_variables[MECHANICSVAR] >= 3) ? 1 : 3
				if target.effects[PBEffects::Toxic]>toxicturns
					score*=1.3
				end
				if target.pbHasMove?(:HEX)
					score*=1.3
				end
			end
    #---------------------------------------------------------------------------
    when "HealUserByTargetAttackLowerTargetAttack1" # Strength Sap
			if target.effects[PBEffects::Substitute]<=0
				maxdam = 0
				maxtype = -1
				healvar = false
				contactcheck = false
				for m in target.moves
					tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
					if tempdam > maxdam
						maxdam = tempdam
						maxtype = m.type
						contactcheck = m.pbContactMove?(user)
					end
					healvar = true if m.healingMove?
					movecheck = true if [:SUPERPOWER, :OVERHEAT, :DRACOMETEOR, :LEAFSTORM, :FLEURCANNON, :PSYCHOBOOST].include?(m.id)
				end
				if user.effects[PBEffects::HealBlock]>0
					score*=0
				else
					if maxdam>user.hp
						score*=3
						if skill>=PBTrainerAI.bestSkill
							if maxdam*1.5 > user.hp
								score*=1.5
							end
							if (user.pbSpeed<pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
								if maxdam*2 > user.hp
									score*=2
								else
									score*=0.2
								end
							end
						end
					end
				end
				if target.pbHasMove?(:CALMMIND) || target.pbHasMove?(:WORKUP) || target.pbHasMove?(:NASTYPLOT) || 
					 target.pbHasMove?(:TAILGLOW) || target.pbHasMove?(:GROWTH) || target.pbHasMove?(:QUIVERDANCE)
					score*=0.7
				end 
				if (user.hp.to_f)/user.totalhp<0.5
					score*=1.5
				else
					score*=0.5
				end
				roles = pbGetPokemonRole(user, target)
				if !(roles.include?("Physical Wall") || roles.include?("Special Wall"))
					score*=0.8
				end
				if target.poisoned? || target.burned? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse]
					score*=1.3
					if target.effects[PBEffects::Toxic]>0
						score*=1.3
					end
				end
				if movecheck
					score*=1.2
				end        
				if target.effects[PBEffects::HyperBeam]>0
					score*=1.2
				end
				ministat = target.attack
				ministat/=(user.totalhp).to_f
				ministat+=0.5
				score*=ministat
				if target.hasActiveAbility?(:LIQUIDOOZE)
					score*=0.2
				end
				if user.hasActiveItem?([:BIGROOT, :COLOGNECASE])
					score*=1.3
				end        
				miniscore=100
				if roles.include?("Physical Wall") || roles.include?("Special Wall")
					miniscore*=1.3
				end
				sweepvar = false
				count=-1
				@battle.pbParty(user.index).each do |i|
					next if i.nil?
					count+=1
					next if count==user.pokemonIndex
					temproles = pbGetPokemonRole(i, target, count, @battle.pbParty(user.index))
					if temproles.include?("Sweeper")
						sweepvar = true
					end
				end
				if sweepvar
					miniscore*=1.1
				end
				targetlivecount = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
				if targetlivecount==1 || user.hasActiveAbility?(:SHADOWTAG) || target.effects[PBEffects::MeanLook]>0
					miniscore*=1.4
				end
				if target.poisoned?
					miniscore*=1.2
				end
				if target.stages[:ATTACK]<0
					minimini = 5*target.stages[:ATTACK]
					minimini+=100
					minimini/=100.0
					miniscore*=minimini
				end
				if user.pbHasMove?(:FOULPLAY)
					miniscore*=0.5
				end  
				if target.burned?
					miniscore*=0.5
				end          
				if target.hasActiveAbility?(:UNAWARE) || target.hasActiveAbility?(:COMPETITIVE)  
					miniscore*=0.1
				end
				if target.hasActiveAbility?(:DEFIANT) || target.hasActiveAbility?(:CONTRARY)
					miniscore*=0.5
				end
				miniscore/=100.0
				if user.stages[:ATTACK]!=6
					score*=miniscore
				end                   
			else
				score = 0
			end
    #---------------------------------------------------------------------------
    when "HealUserByHalfOfDamageDone" # drain punch
			minimini = score*0.01
			miniscore = (target.hp*minimini)/2.0
			if miniscore > (user.totalhp-user.hp)
				miniscore = (user.totalhp-user.hp)
			end
			if user.totalhp>0
				miniscore/=(user.totalhp).to_f
			end
			if user.hasActiveItem?([:BIGROOT, :COLOGNECASE])
				miniscore*=1.3
			end
			miniscore *= 0.5 #arbitrary multiplier to make it value the HP less
			miniscore+=1
			if target.hasActiveAbility?(:LIQUIDOOZE)
				miniscore = (2-miniscore)
			end
			if (user.hp!=user.totalhp || 
				 ((user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0))) && target.effects[PBEffects::Substitute]==0
				score*=miniscore
			end
    #---------------------------------------------------------------------------
    when "HealUserByHalfOfDamageDoneIfTargetAsleep" # dream eater
      if target.asleep?
				minimini = score*0.01
				miniscore = (target.hp*minimini)/2.0
				if miniscore > (user.totalhp-user.hp)
					miniscore = (user.totalhp-user.hp)
				end
				if user.totalhp>0
					miniscore/=(user.totalhp).to_f
				end
				if user.hasActiveItem?([:BIGROOT, :COLOGNECASE])
					miniscore*=1.3
				end
				miniscore+=1
				if target.hasActiveAbility?(:LIQUIDOOZE)
					miniscore = (2-miniscore)
				end
				if (user.hp!=user.totalhp || 
					 ((user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0))) && target.effects[PBEffects::Substitute]==0
					score*=miniscore
				end
			else
				score = 0
      end
    #---------------------------------------------------------------------------
    when "HealUserByThreeQuartersOfDamageDone" # oblivion wing
			minimini = score*0.01
			miniscore = (target.hp*minimini)*(3.0/4.0)
			if miniscore > (user.totalhp-user.hp)
				miniscore = (user.totalhp-user.hp)
			end
			if user.totalhp>0
				miniscore/=(user.totalhp).to_f
			end
			if user.hasActiveItem?([:BIGROOT, :COLOGNECASE])
				miniscore*=1.3
			end
			miniscore *= 0.5 #arbitrary multiplier to make it value the HP less
			miniscore+=1
			if target.hasActiveAbility?(:LIQUIDOOZE)
				miniscore = (2-miniscore)
			end
			if (user.hp!=user.totalhp || 
				 ((user.pbSpeed<pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0))) && target.effects[PBEffects::Substitute]==0
				score*=miniscore
			end
    #---------------------------------------------------------------------------
    when "HealUserAndAlliesQuarterOfTotalHP"
      ally_amt = 30
      @battle.allSameSideBattlers(user.index).each do |b|
        if b.hp == b.totalhp || (skill >= PBTrainerAI.mediumSkill && !b.canHeal?)
          score -= ally_amt / 2
        elsif b.hp < b.totalhp * 3 / 4
          score += ally_amt
        end
      end
    #---------------------------------------------------------------------------
    when "HealUserAndAlliesQuarterOfTotalHPCureStatus"
      ally_amt = 80 / @battle.pbSideSize(user.index)
      @battle.allSameSideBattlers(user.index).each do |b|
        if b.hp == b.totalhp || (skill >= PBTrainerAI.mediumSkill && !b.canHeal?)
          score -= ally_amt
        elsif b.hp < b.totalhp * 3 / 4
          score += ally_amt
        end
        score += ally_amt / 2 if b.pbHasAnyStatus?
      end
    #---------------------------------------------------------------------------
    when "HealTargetHalfOfTotalHP" # heal pulse
			userAlly = user.allAllies.empty?
      if user.opposes?(target) || userAlly # is opposing or is in a 1v1
        score = 0
			else
				if target.hp*(1.0/target.totalhp)<0.7 && target.hp*(1.0/target.totalhp)>0.3
					score*=3
				elsif target.hp*(1.0/target.totalhp)<0.3
					score*=1.7
				end
				if target.poisoned? || target.burned? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse]
					score*=0.8
					if target.effects[PBEffects::Toxic]>0
						score*=0.7
					end
				end
				if target.hp*(1.0/target.totalhp)>0.8
					if (user.pbSpeed < pbRoughStat(target, :SPEED, skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
						score*=0.5
					else
						score*=0
					end
				end
			end
    #---------------------------------------------------------------------------
    when "HealTargetDependingOnGrassyTerrain" # floral healing
			userAlly = user.allAllies.empty?
      if user.opposes?(target) || userAlly # is opposing or is in a 1v1
				score*=0
			else
				if target.hp*(1.0/target.totalhp)<0.7 && target.hp*(1.0/target.totalhp)>0.3
					score*=3
				elsif target.hp*(1.0/target.totalhp)<0.3
					score*=1.7
				end
				if target.poisoned? || target.burned? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse]
					score*=0.8
					if target.effects[PBEffects::Toxic]>0
						score*=0.7
					end
				end
				if target.hp*(1.0/target.totalhp)>0.8
					if (user.pbSpeed < pbRoughStat(target, :SPEED, skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
						score*=0.5
					else
						score*=0
					end
				end
				score*=1.3 if @battle.field.terrain == :Grassy
			end
			if user.poisoned?
				score*=0.2
			end
    #---------------------------------------------------------------------------
    when "HealUserPositionNextTurn" # wish
			protectmove=false
			protectmove = true if pbHasSingleTargetProtectMove?(target)
			
			maxdam = 0
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				maxdam = tempdam if tempdam > maxdam
			end
			if maxdam>user.hp
				if maxdam>(user.hp*1.5)
					score=0
				else
					score*=5
				end
			else
				if maxdam*1.5>user.hp
					score*=2
				end
				if (user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
					if maxdam*2>user.hp
						score*=5
					end                
				end
			end
			if pbHasSetupMove?(target) 
				score*=0.7
			end
 			if user.effects[PBEffects::Toxic]>0
				score*=0.5
				if user.effects[PBEffects::Toxic]>4
					score*=0.5
				end          
			end
			if user.paralyzed? || user.effects[PBEffects::Attract]>=0 || user.effects[PBEffects::Confusion]>0
				score*=1.1
			end
			if target.poisoned? || target.burned? || target.frozen? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse]
				score*=1.3
				if target.effects[PBEffects::Toxic]>0
					score*=1.3
				end
			end
			for m in target.moves
				score*=1.2 if [:SUPERPOWER, :OVERHEAT, :DRACOMETEOR, :LEAFSTORM, :FLEURCANNON, :PSYCHOBOOST].include?(m.id)
			end
			if target.effects[PBEffects::HyperBeam]>0
				score*=1.2
			end
			if ((user.hp.to_f)/user.totalhp)>0.8
				score=0
			elsif ((user.hp.to_f)/user.totalhp)>0.6
				score*=0.6
			elsif ((user.hp.to_f)/user.totalhp)<0.25
				score*=2
			end  
			if user.effects[PBEffects::Wish]>0
				score=0
			end
			#~ if roles.include?("Cleric")
				wishpass=false
				userlivecount=-1
				@battle.pbParty(user.index).each do |m|
					next if m.nil?
					if m.hp/m.totalhp<0.6 && m.hp/m.totalhp>0.3
						wishpass=true
					end
				end
				score*=1.3 if wishpass
			#~ end
    #---------------------------------------------------------------------------
    when "StartHealUserEachTurn" # aqua ring
			maxdam = 0
			movecheck = false
			protectmove = false
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				maxdam = tempdam if tempdam > maxdam
			end
			movecheck = true if pbHasPhazingMove?(target)
			protectmove = true if pbHasSingleTargetProtectMove?(user)
      if !user.effects[PBEffects::AquaRing]
				if user.hp*(1.0/user.totalhp)>0.75
					score*=1.2
				end
				if user.hp*(1.0/user.totalhp)<0.50
					score*=0.7
					if user.hp*(1.0/user.totalhp)<0.33
						score*=0.5
					end            
				end
				if user.hasActiveItem?(:LEFTOVERS) || 
					 (user.hasActiveAbility?(:RAINDISH) && [:Rain, :HeavyRain].include?(user.effectiveWeather)) || 
					 (user.hasActiveAbility?(:ICEBODY) && [:Hail].include?(user.effectiveWeather)) || 
					 user.effects[PBEffects::Ingrain] || 
					 (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON)) || 
					 (@battle.field.terrain == :Grass && user.affectedByTerrain?)
					score*=1.2
				end
				if protectmove
					score*=1.2
				end
				if maxdam*5 < user.totalhp
					score*=1.2
				end
				if maxdam > user.totalhp*0.4
					score*=0.3
				end
				if pbHasPivotMove?(user)
					score*=0.8
				end
				if movecheck
					score*=0.3
				end
				hasAlly = !target.allAllies.empty?
				if hasAlly
					score*=0.5
				end
			else
				score*=0
			end
    #---------------------------------------------------------------------------
    when "StartHealUserEachTurnTrapUserInBattle" # ingrain
			maxdam = 0
			movecheck = false
			protectmove = false
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				maxdam = tempdam if tempdam > maxdam
			end
			movecheck = true if pbHasPhazingMove?(target)
			protectmove = true if pbHasSingleTargetProtectMove?(user)
      if !user.effects[PBEffects::Ingrain]
				if user.hp*(1.0/user.totalhp)>0.75
					score*=1.2
				end
				if user.hp*(1.0/user.totalhp)<0.50
					score*=0.7
					if user.hp*(1.0/user.totalhp)<0.33
						score*=0.5
					end            
				end
				if user.hasActiveItem?(:LEFTOVERS) || 
					 (user.hasActiveAbility?(:RAINDISH) && [:Rain, :HeavyRain].include?(user.effectiveWeather)) || 
					 (user.hasActiveAbility?(:ICEBODY) && [:Hail].include?(user.effectiveWeather)) || 
					 user.effects[PBEffects::AquaRing] || 
					 (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON)) || 
					 (@battle.field.terrain == :Grass && user.affectedByTerrain?)
					score*=1.2
				end
				if protectmove
					score*=1.2
				end
				if maxdam*5 < user.totalhp
					score*=1.2
				end
				if maxdam > user.totalhp*0.4
					score*=0.3
				end
				if pbHasPivotMove?(user)
					score*=0.8
				end
				if movecheck
					if pbHasSetupMove?(user)
						score*=1.2
					else
						score*=0.3
					end
				end
				hasAlly = !target.allAllies.empty?
				if hasAlly
					score*=0.5
				end
			else
				score*=0
			end
    #---------------------------------------------------------------------------
    when "StartDamageTargetEachTurnIfTargetAsleep" # nightmare
			if !target.effects[PBEffects::Nightmare] && target.asleep? && target.effects[PBEffects::Substitute]<=0
				if target.statusCount>2
					score*=4
				end
				if target.hasActiveAbility?(:EARLYBIRD)
					score*=0.5
				end
				if target.hasActiveAbility?(:COMATOSE)
					score*=6
				end
				if target.hasActiveAbility?(:SHEDSKIN)
					score*=0.5
				end
				if user.hasActiveAbility?([:ARENATRAP, :SHADOWTAG]) || target.effects[PBEffects::MeanLook]>=0 || 
					 @battle.pbAbleNonActiveCount(user.idxOpposingSide)==0
					score*=1.3
				else
					score*=0.8
				end
				hasAlly = !target.allAllies.empty?
				if hasAlly
					score*=0.5
				end
			else
				score*=0
			end
    #---------------------------------------------------------------------------
    when "StartLeechSeedTarget" # leech seed
			movecheck = false
			movecheck = true if pbHasPivotMove?(target)
			for m in target.moves
				movecheck = true if m.id == :RAPIDSPIN
			end
			if target.effects[PBEffects::LeechSeed]<0 && !target.pbHasType?(:GRASS) && target.effects[PBEffects::Substitute]<=0
				if movecheck
					score*=0.2
				end
				if user.effects[PBEffects::Substitute]>0
					score*=1.3
				end
				if target.hp==target.totalhp
					score*=1.1
				else
					score*=(target.hp*(1.0/target.totalhp))
				end
				if target.hasActiveItem?([:LEFTOVERS, :BIGROOT, :COLOGNECASE]) || 
					 (target.hasActiveItem?(:BLACKSLUDGE) && target.pbHasType?(:POISON))
					score*=1.2
				end
				if target.paralyzed? || target.asleep?
					score*=1.2
				end
				if target.poisoned? || target.burned? || target.frozen?
					score*=1.1
				end
				if target.effects[PBEffects::Confusion]>0
					score*=1.2
				end
				if target.effects[PBEffects::Attract]>=0
					score*=1.2
				end
				if (target.hp*2)<target.totalhp
					score*=0.8
					if (target.hp*4)<target.totalhp
						score*=0.2
					end
				end
				protectmove = false
				protectmove = true if pbHasSingleTargetProtectMove?(user)
				if protectmove
					score*=1.2
				end
				ministat=0
				ministat+=target.stages[:ATTACK] if target.stages[:ATTACK]>0
				ministat+=target.stages[:SPECIAL_ATTACK] if target.stages[:SPECIAL_ATTACK]>0
				ministat+=target.stages[:SPEED] if target.stages[:SPEED]>0
				ministat+=target.stages[:DEFENSE] if target.stages[:DEFENSE]>0
				ministat+=target.stages[:SPECIAL_DEFENSE] if target.stages[:SPECIAL_DEFENSE]>0
				ministat+=target.stages[:ACCURACY] if target.stages[:ACCURACY]>0
				ministat+=target.stages[:EVASION] if target.stages[:EVASION]>0
				ministat*=(5)
				ministat+=100
				ministat/=100.0
				score*=ministat
				if target.hasActiveAbility?(:LIQUIDOOZE) || target.effects[PBEffects::Substitute]>0
					score*=0
				end
			else
				score*=0
			end
    #---------------------------------------------------------------------------
    when "UserLosesHalfOfTotalHP", "UserLosesHalfOfTotalHPExplosive"
			maxdam=0
			maxtype = -1
			contactcheck = false
			movecheck = false
			healvar=false
			for m in target.moves
				healvar=true if m.healingMove? 
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				if tempdam>maxdam              
					maxdam=tempdam 
					maxtype = m.type
				end 
			end
			movecheck = true if pbHasSingleTargetProtectMove?(target)
			initialscores = score
			if (!user.hasActiveAbility?(:MAGICGUARD) && user.hp<user.totalhp*0.5) || 
				 (user.hp<user.totalhp*0.75 && 
				 ((user.pbSpeed<pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0))) ||
				 (!@battle.pbCheckGlobalAbility(:DAMP) && move.function == "UserLosesHalfOfTotalHPExplosive")
				if !user.hasActiveAbility?(:MAGICGUARD)
					if user.hasActiveAbility?(:PARTYPOPPER)
						score*=1.2
					end
					score*=0.7
					if initialscores < 100
						score*=0.7
					end
					if (user.pbSpeed<pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
						score*=0.5
					end
					if maxdam < user.totalhp*0.2
						score*=1.3
					end
					healcheck = false
					for m in user.moves 
						healcheck=true if m.healingMove? 
						break
					end
					if healcheck
						score*=1.2
					end
					if movecheck
						score*=0.5
					end
					ministat=0
					ministat+=target.stages[:EVASION]
					minimini=(-10)*ministat
					minimini+=100
					minimini/=100.0
					score*=minimini
					ministat=0
					ministat+=user.stages[:ACCURACY]
					minimini=(10)*ministat
					minimini+=100
					minimini/=100.0
					score*=minimini
					if target.hasActiveItem?(:LAXINCENSE) || target.hasActiveItem?(:BRIGHTPOWDER)
						score*=0.7
					end
					if (target.hasActiveAbility?(:SANDVEIL) && target.effectiveWeather == :Sandstorm) || 
						 (target.hasActiveAbility?(:SNOWCLOAK) && target.effectiveWeather == :Hail)
						score*=0.7
					end
				else
					score*=1.1
				end
			end
      reserves = @battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
      if skill >= PBTrainerAI.mediumSkill && reserves == 0 && foes > 0
        score -= 100   # don't want to lose
      elsif skill >= PBTrainerAI.highSkill && reserves == 0 && foes == 0
        score += 80   # want to draw
      end
    #---------------------------------------------------------------------------
    when "UserFaintsExplosive" # explosion
			protectmove = false
			protectmove = true if pbHasSingleTargetProtectMove?(target)
			score*=0.7
			if user.hp==user.totalhp
				score*=0.2
			else
				miniscore = user.hp*(1.0/user.totalhp)
				miniscore = 1-miniscore
				score*=miniscore
				if user.hp*4<user.totalhp            
					score*=1.3
					if user.hasActiveItem?(:CUSTAPBERRY)
						score*=1.4
					end            
				end          
			end
			if user.pokemonIndex == 0 # on the lead slot
				score*=1.2
			end
			if user.hasActiveAbility?(:PARTYPOPPER)
				score*=1.2
			end
			if (target.hasActiveAbility?(:DISGUISE) && target.form == 0) || target.effects[PBEffects::Substitute]>0
				score*=0.3
			end
			score*=0.3 if protectmove
			if @battle.pbCheckGlobalAbility(:DAMP)
				score=0
			end
      reserves = @battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
      if skill >= PBTrainerAI.mediumSkill && reserves == 0 && foes > 0
        score -= 100   # don't want to lose
      elsif skill >= PBTrainerAI.highSkill && reserves == 0 && foes == 0
        score += 80   # want to draw
      end
    #---------------------------------------------------------------------------
    when "UserFaintsPowersUpInMistyTerrainExplosive" # misty explosion
			protectmove = false
			protectmove = true if pbHasSingleTargetProtectMove?(target)
			score*=0.7
			if user.hp==user.totalhp
				score*=0.2
			else
				miniscore = user.hp*(1.0/user.totalhp)
				miniscore = 1-miniscore
				score*=miniscore
				if user.hp*4<user.totalhp            
					score*=1.3
					if user.hasActiveItem?(:CUSTAPBERRY)
						score*=1.4
					end            
				end          
			end
			if user.pokemonIndex == 0 # on the lead slot
				score*=1.2
			end
			if (target.hasActiveAbility?(:DISGUISE) && target.form == 0) || target.effects[PBEffects::Substitute]>0
				score*=0.3
			end
			score*=0.3 if protectmove
			if @battle.pbCheckGlobalAbility(:DAMP)
				score=0
			end
      reserves = @battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
      if skill >= PBTrainerAI.mediumSkill && reserves == 0 && foes > 0
        score -= 100   # don't want to lose
      elsif skill >= PBTrainerAI.highSkill && reserves == 0 && foes == 0
        score += 80   # want to draw
        score *= 1.2 if @battle.field.terrain == :Misty
      end
    #---------------------------------------------------------------------------
    when "UserFaintsFixedDamageUserHP" # final gambit
			score*=0.7
			if user.hp > target.hp
				score*=1.1
			else
				score*=0.5
			end
			if (user.pbSpeed > pbRoughStat(target, :SPEED, skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
				score*=1.1
			else
				score*=0.5
			end  
			if target.hasActiveItem?(:FOCUSSASH) || target.hasActiveAbility?(:STURDY)
				score*=0.2
			end
      reserves = @battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
      if skill >= PBTrainerAI.mediumSkill && reserves == 0 && foes > 0
        score -= 100   # don't want to lose
      elsif skill >= PBTrainerAI.highSkill && reserves == 0 && foes == 0
        score += 80   # want to draw
      end
    #---------------------------------------------------------------------------
    when "UserFaintsLowerTargetAtkSpAtk2" # memento
			if user.hp==user.totalhp
				score*=0.2
			else
				miniscore = user.hp*(1.0/user.totalhp)
				miniscore = 1-miniscore
				score*=miniscore
				if user.hp*4<user.totalhp 
					score*=1.3
				end
			end
			if target.attack > target.spatk
				if target.stages[:ATTACK]<-1
					score*=0.1
				end
			else
				if target.stages[:SPECIAL_ATTACK]<-1
					score*=0.1
				end
			end
			if target.hasActiveAbility?([:CLEARBODY, :WHITESMOKE])
				score=0
			end
      reserves = @battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
      if skill >= PBTrainerAI.mediumSkill && reserves == 0 && foes > 0
        score -= 100   # don't want to lose
      elsif skill >= PBTrainerAI.highSkill && reserves == 0 && foes == 0
        score += 80   # want to draw
      end
    #---------------------------------------------------------------------------
    when "UserFaintsHealAndCureReplacement", "UserFaintsHealAndCureReplacementRestorePP" # healing wish, lunar dance
			count = @battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes  = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
			count -= 1 if user.hp!=user.totalhp
			if count==0
				score*=0
			else
				maxscore = 0
				@battle.pbParty(target.index).each do |mon|
					next if mon.fainted?
					if mon.hp!=mon.totalhp
						miniscore = 1 - mon.hp*(1.0/mon.totalhp)
						miniscore*=2 if mon.status!=0
						maxscore=miniscore if miniscore>maxscore
					end    
				end
				score*=maxscore
			end
			if user.hp==user.totalhp
				score*=0.2
			else
				miniscore = user.hp*(1.0/user.totalhp)
				miniscore = 1-miniscore
				score*=miniscore
				if user.hp*4<user.totalhp 
					score*=1.3
					if user.hasActiveItem?(:CUSTAPBERRY)
						score*=1.4
					end
				end
			end
			if (user.pbSpeed > pbRoughStat(target, :SPEED, skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
				score*=1.1
			else
				score*0.5
			end
    #---------------------------------------------------------------------------
    when "StartPerishCountsForAllBattlers" # perish song
      userlivecount   = @battle.pbAbleNonActiveCount(user.idxOwnSide)
      targetlivecount = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
			hasAlly = !target.allAllies.empty?
			if targetlivecount==1 || (targetlivecount==2 && hasAlly)
				score*=4
			else
				if pbHasPivotMove?(user)
					score*=1.5
				end
				if user.hasActiveAbility?(:SHADOWTAG) || target.effects[PBEffects::MeanLook]>0
					score*=3
				end
				if pbHasSingleTargetProtectMove?(user)
					score*=1.2
				end
				for j in user.moves
					if j.healingMove?
						score*=1.2
						break
					end
				end
				raisedstats=0
				raisedstats+=target.stages[:ATTACK] if target.stages[:ATTACK]>0
				raisedstats+=target.stages[:DEFENSE] if target.stages[:DEFENSE]>0
				raisedstats+=target.stages[:SPEED] if target.stages[:SPEED]>0
				raisedstats+=target.stages[:SPECIAL_ATTACK] if target.stages[:SPECIAL_ATTACK]>0
				raisedstats+=target.stages[:SPECIAL_DEFENSE] if target.stages[:SPECIAL_DEFENSE]>0
				raisedstats+=target.stages[:EVASION] if target.stages[:EVASION]>0
				miniscore= 5*raisedstats
				miniscore+=100
				miniscore/=100.0
				score*=miniscore          
				loweredstats=0
				loweredstats+=user.stages[:ATTACK] if user.stages[:ATTACK]<0
				loweredstats+=user.stages[:DEFENSE] if user.stages[:DEFENSE]<0
				loweredstats+=user.stages[:SPEED] if user.stages[:SPEED]<0
				loweredstats+=user.stages[:SPECIAL_ATTACK] if user.stages[:SPECIAL_ATTACK]<0
				loweredstats+=user.stages[:SPECIAL_DEFENSE] if user.stages[:SPECIAL_DEFENSE]<0
				miniscore= (-5)*loweredstats
				miniscore+=100
				miniscore/=100.0
				score*=miniscore          
				raisedstats=0
				raisedstats+=user.stages[:ATTACK] if user.stages[:ATTACK]>0
				raisedstats+=user.stages[:DEFENSE] if user.stages[:DEFENSE]>0
				raisedstats+=user.stages[:SPEED] if user.stages[:SPEED]>0
				raisedstats+=user.stages[:SPECIAL_ATTACK] if user.stages[:SPECIAL_ATTACK]>0
				raisedstats+=user.stages[:SPECIAL_DEFENSE] if user.stages[:SPECIAL_DEFENSE]>0
				miniscore= (-5)*raisedstats
				miniscore+=100
				miniscore/=100.0
				score*=miniscore          
				loweredstats=0
				loweredstats+=target.stages[:ATTACK] if target.stages[:ATTACK]<0
				loweredstats+=target.stages[:DEFENSE] if target.stages[:DEFENSE]<0
				loweredstats+=target.stages[:SPEED] if target.stages[:SPEED]<0
				loweredstats+=target.stages[:SPECIAL_ATTACK] if target.stages[:SPECIAL_ATTACK]<0
				loweredstats+=target.stages[:SPECIAL_DEFENSE] if target.stages[:SPECIAL_DEFENSE]<0
				miniscore= 5*loweredstats
				miniscore+=100
				miniscore/=100.0
				score*=miniscore
				
				score*=0.5 if pbHasPivotMove?(target)
				if target.hasActiveAbility?(:SHADOWTAG) || user.effects[PBEffects::MeanLook]>0
					score*=0.1
				end
				score*=1.5 if pbHasPivotMove?(user) # why is this repeated?
				hasAllyDos = !user.allAllies.empty?
				if userlivecount==1 || (userlivecount==2 && hasAllyDos)
					score*=0
				end
			end                
			score=0 if target.effects[PBEffects::PerishSong]>0
    #---------------------------------------------------------------------------
    when "userFaintsIfUserFaints"
			movenum = 0
			damcount = 0
			for m in target.moves
				movenum+=1
				if j.baseDamage>0 && j.pbContactMove?(target) && target.affectedByContactEffect?
					damcount+=1
				end
			end
			if movenum==4 && damcount==1
				score*=3
			end
			if user.hp==user.totalhp
				score*=0.2
			else
				miniscore = user.hp*(1.0/user.totalhp)
				miniscore = 1-miniscore
				score*=miniscore
				if user.hp*4<user.totalhp            
					score*=1.3
					if user.hasActiveItem?(:CUSTAPBERRY)
						score*=1.3
					end            
				end          
			end        
			if (user.pbSpeed > pbRoughStat(target, :SPEED, skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
				score*=1.3
			else
				score*0.5
			end
			if user.effects[PBEffects::DestinyBondPrevious]   
				score=0
			end
    #---------------------------------------------------------------------------
    when "SetuserMovePPTo0IfUserFaints" # grudge
			movenum = 0
			damcount = 0
			for m in target.moves
				movenum+=1
				if j.baseDamage>0
					damcount+=1
				end
			end
			if movenum==4 && damcount==1
				score*=3
			end
			if user.hp==user.totalhp
				score*=0.2
			else
				miniscore = user.hp*(1.0/user.totalhp)
				miniscore = 1-miniscore
				score*=miniscore
				if user.hp*4<user.totalhp            
					score*=1.3
					if user.hasActiveItem?(:CUSTAPBERRY)
						score*=1.3
					end            
				end          
			end        
			if (user.pbSpeed > pbRoughStat(target, :SPEED, skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
				score*=1.3
			else
				score*0.5
			end
    #---------------------------------------------------------------------------
    when "UserTakesTargetItem" # covet
			if !target.hasActiveAbility?(:STICKYHOLD) &&
					target.item && !target.unlosableItem?(target.item)
				miniscore = 1.2
				case target.item_id
					when :LEFTOVERS, :RECOVERYDISC,  :LIFEORB,  :LUMBERRY,  :SITRUSBERRY
						miniscore*=1.5
					when :ASSAULTVEST,  :ROCKYHELMET
						miniscore*=1.3
					when :FOCUSSASH,  :MUSCLEBAND,  :WISEGLASSES,  :EXPERTBELT,  :WIDELENS
						miniscore*=1.2
					when :CHOICESCARF
						if user.pbSpeed<pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]==0
							miniscore*=1.1
						end
					when :CHOICEBAND
						if user.attack>user.spatk
							miniscore*=1.1
						end
					when :CHOICESPECS
						if user.spatk>user.attack
							miniscore*=1.1
						end
					when :BLACKSLUDGE
						if user.pbHasType?(:POISON)
							miniscore*=1.5
						else
							miniscore*=0.5
						end
					when :TOXICORB,  :FLAMEORB,  :LAGGINGTAIL,  :IRONBALL,  :STICKYBARB
						miniscore*=0.5
				end
				score*=miniscore
			else
				score=0
			end
    #---------------------------------------------------------------------------
    when "TargetTakesUserItem" # bestow
			if !target.hasActiveAbility?(:STICKYHOLD) &&
					target.item && user.item && !target.unlosableItem?(target.item) && 
					target.effects[PBEffects::Substitute]<=0
				case user.item_id
					when :CHOICESCARF
						if (user.pbSpeed>pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
							score+=25
						end
					when :CHOICEBAND
						if target.attack<target.spatk
							score+=35
						end
					when :CHOICESPECS
						if target.spatk<target.attack
							score+=35
						end
					when :BLACKSLUDGE
						if target.pbHasType?(:POISON)
							score+=35
						else
							score*=0.5
						end
					when :TOXICORB,  :FLAMEORB,  :LAGGINGTAIL,  :IRONBALL,  :STICKYBARB
						score+=35
				end
				score*=miniscore
			else
				score=0
			end
    #---------------------------------------------------------------------------
    when "UserTargetSwapItems" # trick
			statvar = false
			for m in target.moves
				if m.baseDamage==0
					statvar=true
				end
			end
			if !target.hasActiveAbility?(:STICKYHOLD) && target.effects[PBEffects::Substitute]<=0
				miniscore = 1.2
				minimini  = 0.8
				if target.item && !target.unlosableItem?(target.item)
					case target.item_id
						when :LEFTOVERS, :RECOVERYDISC,  :LIFEORB,  :LUMBERRY,  :SITRUSBERRY
							miniscore*=1.5
						when :ASSAULTVEST,  :ROCKYHELMET
							miniscore*=1.3
						when :FOCUSSASH,  :MUSCLEBAND,  :WISEGLASSES,  :EXPERTBELT,  :WIDELENS
							miniscore*=1.2
						when :CHOICESCARF
							if user.pbSpeed<pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]==0
								miniscore*=1.1
							end
						when :CHOICEBAND
							if user.attack>user.spatk
								miniscore*=1.1
							end
						when :CHOICESPECS
							if user.spatk>user.attack
								miniscore*=1.1
							end
						when :BLACKSLUDGE
							if user.pbHasType?(:POISON)
								miniscore*=1.5
							else
								miniscore*=0.5
							end
						when :TOXICORB,  :FLAMEORB,  :LAGGINGTAIL,  :IRONBALL,  :STICKYBARB
							miniscore*=0.5
					end
				end
				if user.item && !user.unlosableItem?(user.item)
					case user.item_id
						when :LEFTOVERS, :RECOVERYDISC,  :LIFEORB,  :LUMBERRY,  :SITRUSBERRY
							minimini*=0.5
						when :ASSAULTVEST,  :ROCKYHELMET
							minimini*=0.7
						when :FOCUSSASH,  :MUSCLEBAND,  :WISEGLASSES,  :EXPERTBELT,  :WIDELENS
							minimini*=0.8
						when :CHOICESCARF
							if (user.pbSpeed<pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
								minimini*=1.5
							else
								minimini*=0.9
							end
							if statvar
								minimini*=1.3
							end
						when :CHOICEBAND
							if target.attack<target.spatk
								minimini*=1.7
							end
							if user.attack>user.spatk
								minimini*=0.8
							end
							if statvar
								minimini*=1.3
							end
						when :CHOICESPECS
							if target.attack>target.spatk
								minimini*=1.7
							end
							if user.attack<user.spatk
								minimini*=0.8
							end
							if statvar
								minimini*=1.3
							end
						when :BLACKSLUDGE
							if user.pbHasType?(:POISON)
								minimini*=1.5
							else
								minimini*=0.5
							end
							if !target.pbHasType?(:POISON)
								minimini*=1.3
							end
						when :TOXICORB,  :FLAMEORB,  :LAGGINGTAIL,  :IRONBALL,  :STICKYBARB
							minimini*=0.5
					end
				end
				score*=(miniscore*minimini)
			else
				score = 0
			end
			if user.item==target.item
				score*=0
			end
    #---------------------------------------------------------------------------
    when "RestoreUserConsumedItem" # recycle
			movecheck = false
			stealvar = false
			for m in target.moves
				movecheck=true if ["DestroyTargetBerryOrGem","UserConsumeTargetBerry"].include?(m.function)
				stealvar=true if ["RemoveTargetItem","UserTakesTargetItem"].include?(m.function)
			end
			if user.recycleItem
				score*=2
				case user.recycleItem
					when :LUMBERRY
						score*=2 if user.pbHasAnyStatus?
					when :SITRUSBERRY
						score*=1.6 if user.hp*(1.0/user.totalhp)<0.66
						targetroles = pbGetPokemonRole(target)
						if targetroles.include?("Physical Wall") || targetroles.include?("Special Wall") 
							score*=1.5
						end
				end
				if user.recycleItem.is_berry?
					if target.hasActiveAbility?(:UNNERVE)
						score*=0
					end
					if movecheck
						score*=0
					end
				end
				if target.hasActiveAbility?(:MAGICIAN) || stealvar
					score*=0
				end
				if user.hasActiveAbility?([:HARVEST, :UNBURDEN]) || user.pbHasMove?(:ACROBATICS)
					score*=0
				end
			else
				score*=0
			end
    #---------------------------------------------------------------------------
    when "RemoveTargetItem" # knock off
			greatmoves=false
			if !greatmoves && target.effects[PBEffects::Substitute]<=0
				if !target.hasActiveAbility?(:STICKYHOLD) &&
						target.item && !target.unlosableItem?(target.item)
					score*=1.1
					if target.hasActiveItem?(:LEFTOVERS) || (target.hasActiveItem?(:BLACKSLUDGE) && target.pbHasType?(:POISON))
						score*=1.2
					end    
					if target.hasActiveItem?([:LIFEORB, :CHOICESCARF, :CHOICEBAND, :CHOICESPECS, :ASSAULTVEST])
						score*=1.1
					end        
				end
			end
    #---------------------------------------------------------------------------
    when "DestroyTargetBerryOrGem" # incinerate
			if !target.hasActiveAbility?(:STICKYHOLD) && target.effects[PBEffects::Substitute]<=0
				if target.item == :LUMBERRY || target.item == :SITRUSBERRY || target.item == :PETAYABERRY || 
					 target.item == :LIECHIBERRY || target.item == :SALACBERRY || target.item == :CUSTAPBERRY
					score*=1.3
				else
					score*=0.8
				end
      end
    #---------------------------------------------------------------------------
    when "CorrodeTargetItem" # Corrosive Gas
      if @battle.corrosiveGas[target.index % 2][target.pokemonIndex]
        score -= 100
			else
				greatmoves=false
				if !greatmoves && target.effects[PBEffects::Substitute]<=0
					if !target.hasActiveAbility?(:STICKYHOLD) &&
							target.item && !target.unlosableItem?(target.item)
						score*=1.1
						if target.hasActiveItem?(:LEFTOVERS) || (target.hasActiveItem?(:BLACKSLUDGE) && target.pbHasType?(:POISON))
							score*=1.2
						end    
						if target.hasActiveItem?([:LIFEORB, :CHOICESCARF, :CHOICEBAND, :CHOICESPECS, :ASSAULTVEST])
							score*=1.1
						end        
					end
				end
      end
    #---------------------------------------------------------------------------
    when "StartTargetCannotUseItem" # embargo
			initialscores = score
			if target.effects[PBEffects::Embargo]>0  && target.effects[PBEffects::Substitute]>0 && move.baseDamage <=0  # added by JZ for Mind Meld fix
				score*=0
			else
				if !target.item
					score*=1.1
					#~ if target.item.is_berry?
						#~ score*=1.1
					#~ end
					case target.item_id
						when :LAXINCENSE, :SYNTHETICSEED, :TELLURICSEED, :ELEMENTALSEED, :MAGICALSEED, :EXPERTBELT, :MUSCLEBAND, :WISEGLASSES, :LIFEORB, :EVIOLITE, :ASSAULTVEST
							score*=1.2
						when :LEFTOVERS, :BLACKSLUDGE
							score*=1.3
					end
					if target.hp*2<target.totalhp
						score*=1.4
					end
				end
				if score==initialscores && move.baseDamage<=0
					score*=0
				end
			end
    #---------------------------------------------------------------------------
    when "StartNegateHeldItems" # magic room
			if @battle.field.effects[PBEffects::MagicRoom] > 0
				score=0
			else
				if !target.item
					score*=1.1
					#~ if target.item.is_berry?
						#~ score*=1.1
					#~ end
					case target.item_id
						when :LAXINCENSE, :EXPERTBELT, :MUSCLEBAND, :WISEGLASSES, 
								 :LIFEORB, :EVIOLITE, :ASSAULTVEST
							score*=1.2
						when :LEFTOVERS, :BLACKSLUDGE
							score*=1.3
					end
					if target.hp*2<target.totalhp
						score*=1.4
					end
				end
				if !user.item
					score*=0.8
					#~ if user.item.is_berry?
						#~ score*=0.8
					#~ end
					case user.item_id
						when :LAXINCENSE, :EXPERTBELT, :MUSCLEBAND, :WISEGLASSES, 
								 :LIFEORB, :EVIOLITE, :ASSAULTVEST
							score*=0.6
						when :LEFTOVERS, :BLACKSLUDGE
							score*=0.4
					end
					if user.hp*2<user.totalhp
						score*=1.4
					end
				end
				if user.hasActiveAbility?(:TRICKSTER)
					score*=1.4
				end
			end
    #---------------------------------------------------------------------------
    when "UserConsumeBerryRaiseDefense2"
      if !user.item || !user.item.is_berry? || !user.itemActive?
        score -= 100
      else
        if skill >= PBTrainerAI.highSkill
          useful_berries = [
            :ORANBERRY, :SITRUSBERRY, :AGUAVBERRY, :APICOTBERRY, :CHERIBERRY,
            :CHESTOBERRY, :FIGYBERRY, :GANLONBERRY, :IAPAPABERRY, :KEEBERRY,
            :LANSATBERRY, :LEPPABERRY, :LIECHIBERRY, :LUMBERRY, :MAGOBERRY,
            :MARANGABERRY, :PECHABERRY, :PERSIMBERRY, :PETAYABERRY, :RAWSTBERRY,
            :SALACBERRY, :STARFBERRY, :WIKIBERRY
          ]
          score += 30 if useful_berries.include?(user.item_id)
        end
        if skill >= PBTrainerAI.mediumSkill
          score += 20 if user.canHeal? && user.hp < user.totalhp / 3 && user.hasActiveAbility?(:CHEEKPOUCH)
          score += 20 if user.hasActiveAbility?([:HARVEST, :RIPEN]) ||
                         user.pbHasMoveFunction?("RestoreUserConsumedItem")   # Recycle
          score += 20 if !user.canConsumeBerry?
        end
        score -= user.stages[:DEFENSE] * 20
      end
    #---------------------------------------------------------------------------
    when "AllBattlersConsumeBerry"
      useful_berries = [
        :ORANBERRY, :SITRUSBERRY, :AGUAVBERRY, :APICOTBERRY, :CHERIBERRY,
        :CHESTOBERRY, :FIGYBERRY, :GANLONBERRY, :IAPAPABERRY, :KEEBERRY,
        :LANSATBERRY, :LEPPABERRY, :LIECHIBERRY, :LUMBERRY, :MAGOBERRY,
        :MARANGABERRY, :PECHABERRY, :PERSIMBERRY, :PETAYABERRY,
        :RAWSTBERRY, :SALACBERRY, :STARFBERRY, :WIKIBERRY
      ]
      @battle.allSameSideBattlers(user.index).each do |b|
        if !b.item || !b.item.is_berry? || !b.itemActive?
          score -= 100 / @battle.pbSideSize(user.index)
        else
          if skill >= PBTrainerAI.highSkill
            amt = 30 / @battle.pbSideSize(user.index)
            score += amt if useful_berries.include?(b.item_id)
          end
          if skill >= PBTrainerAI.mediumSkill
            amt = 20 / @battle.pbSideSize(user.index)
            score += amt if b.canHeal? && b.hp < b.totalhp / 3 && b.hasActiveAbility?(:CHEEKPOUCH)
            score += amt if b.hasActiveAbility?([:HARVEST, :RIPEN]) ||
                            b.pbHasMoveFunction?("RestoreUserConsumedItem")   # Recycle
            score += amt if !b.canConsumeBerry?
          end
        end
      end
      if skill >= PBTrainerAI.highSkill
        @battle.allOtherSideBattlers(user.index).each do |b|
          amt = 10 / @battle.pbSideSize(target.index)
          score -= amt if b.hasActiveItem?(useful_berries)
          score -= amt if b.canHeal? && b.hp < b.totalhp / 3 && b.hasActiveAbility?(:CHEEKPOUCH)
          score -= amt if b.hasActiveAbility?([:HARVEST, :RIPEN]) ||
                          b.pbHasMoveFunction?("RestoreUserConsumedItem")   # Recycle
          score -= amt if !b.canConsumeBerry?
        end
      end
    #---------------------------------------------------------------------------
    when "UserConsumeTargetBerry" # bug bite
			if target.effects[PBEffects::Substitute]==0 #&& target.item.is_berry?
				case target.item
					when :LUMBERRY
						score*=2 if user.pbHasAnyStatus?
					when :SITRUSBERRY
						score*=1.6 if user.hp*(1.0/user.totalhp)<0.66
					when :LIECHIBERRY
						score*=1.5 if user.attack>user.spatk
					when :PETAYABERRY
						score*=1.5 if user.spatk>user.attack
					when :CUSTAPBERRY, :SALACBERRY
						score*=1.1
						score*=1.4 if ((user.pbSpeed<pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0))
				end 
			end
    #---------------------------------------------------------------------------
    when "ThrowUserItemAtTarget" # fling
			if !user.item || user.unlosableItem?(user.item) || 
				 user.hasActiveAbility?(:KLUTZ) || (user.item.is_berry? && target.hasActiveAbility?(:UNNERVE)) || 
				 user.effects[PBEffects::Embargo]>0 || @battle.field.effects[PBEffects::MagicRoom]>0
				score*=0
			else
				case user.item_id
					when :POISONBARB
						if target.pbCanPoison?(user, false) && !target.hasActiveAbility?(:POISONHEAL)
							score*=1.2
						end
					when :TOXICORB
						if target.pbCanPoison?(user, false) && !target.hasActiveAbility?(:POISONHEAL)
							score*=1.2
							if user.pbCanPoison?(nil, false) && !user.hasActiveAbility?(:POISONHEAL)
								score*=2
							end                
						end
					when :FLAMEORB
						if target.pbCanBurn?(user, false) && !target.hasActiveAbility?(:GUTS)
							score*=1.3
							if user.pbCanBurn?(nil, false) && !user.hasActiveAbility?(:GUTS)
								score*=2
							end                
						end
					when :LIGHTBALL
						if target.pbCanParalyze?(user, false) && !target.hasActiveAbility?(:QUICKFEET)
							score*=1.3
						end
					when :KINGSROCK, :RAZORCLAW
						if !target.hasActiveAbility?(:INNERFOCUS) && (user.pbSpeed>pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
							score*=1.3
						end
					when :POWERHERB
						score*=0
					when :MENTALHERB
						score*=0
					when :LAXINCENSE, :CHOICESCARF, :CHOICEBAND, :CHOICESPECS, 
							 :EXPERTBELT, :FOCUSSASH, :LEFTOVERS, :MUSCLEBAND, 
							 :WISEGLASSES, :LIFEORB, :EVIOLITE, :ASSAULTVEST, :BLACKSLUDGE
						score*=0
					when :STICKYBARB
						score*=1.2
					when :LAGGINGTAIL
						score*=3
					when :IRONBALL
						score*=1.5
				end
				#~ if user.item.is_berry?
					#~ if user.item==:FIGYBERRY || user.item==:WIKIBERRY || user.item==:MAGOBERRY || 
						 #~ user.item==:AGUAVBERRY || user.item==:IAPAPABERRY
						#~ if target.pbCanConfuse?(user, false)
							#~ score*=1.3
						#~ end
					#~ else
						#~ score*=0
					#~ end
				#~ end          
			end
    #---------------------------------------------------------------------------
    when "RedirectAllMovesToUser" # follow me
			if user.allAllies.length == 0
				score*=0
			else
				roles = pbGetPokemonRole(user, target)
				if roles.include?("Physical Wall") || roles.include?("Special Wall")
					score*=1.2
				end
				user.allAllies.each do |m|
					score*=1.3 if m.hasActiveAbility?(:MOODY)
					if m.turnCount<1
						score*=2
					else
						score*=1.2
					end
				end
				if user.hp==user.totalhp
					score*=1.2
				else
					score*=0.8
					if user.hp*2 < user.totalhp
						score*=0.5
					end
				end
				speedcheck=0
				target.allAllies.each do |m|
					speedcheck+= 1 if user.pbSpeed < pbRoughStat(m, :SPEED, skill)
				end
				score*=1.2 if target.allAllies.length == speedcheck
			end
    #---------------------------------------------------------------------------
    when "RedirectAllMovesToTarget" # Spotlight
			maxdam = 0
			maxtype = -1
			healvar = false
			contactcheck = false
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				if tempdam > maxdam
					maxdam = tempdam
					maxtype = m.type
					contactcheck = m.pbContactMove?(user)
				end
				healvar = true if m.healingMove?
			end
			if user.allAllies.length == 0
				score=1
			else
				if user.opposes?(target)
					score=1
				else
					if target.hasActiveAbility?(:FLASHFIRE) && maxtype==:FIRE
						score*=3
					end
					if target.hasActiveAbility?([:DRYSKIN, :STORMDRAIN, :WATERABSORB]) && maxtype==:WATER
						score*=3
					end
					if target.hasActiveAbility?([:MOTORDRIVE, :LIGHTNINGROD, :VOLTABSORB]) && maxtype==:ELECTRIC
						score*=3
					end
					if target.hasActiveAbility?(:SAPSIPPER) && maxtype==:GRASS
						score*=3
					end
					if target.pbHasMove?(:KINGSSHIELD) || target.pbHasMove?(:BANEFULBUNKER) || 
						 target.pbHasMove?(:SPIKYSHIELD) || target.pbHasMove?(:OBSTRUCT)
						if contactcheck
							score*=2
						end
					end
					if target.pbHasMove?(:COUNTER) || target.pbHasMove?(:METALBURST) || target.pbHasMove?(:MIRRORCOAT)
						score*=2
					end
					target.allAllies.each do |barget|
						if ((user.pbSpeed<pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0))
							score*=1.5
						end
						if ((user.pbSpeed<pbRoughStat(barget,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0))
							score*=1.5
						end
					end
				end
			end
    #---------------------------------------------------------------------------
    when "CannotBeRedirected"
      redirection = false
      user.allOpposing.each do |b|
        next if b.index == target.index
        if b.effects[PBEffects::RagePowder] ||
           b.effects[PBEffects::Spotlight] > 0 ||
           b.effects[PBEffects::FollowMe] > 0 ||
           (b.hasActiveAbility?(:LIGHTNINGROD) && move.pbCalcType == :ELECTRIC) ||
           (b.hasActiveAbility?(:STORMDRAIN) && move.pbCalcType == :WATER)
          redirection = true
          break
        end
      end
      score += 50 if redirection && skill >= PBTrainerAI.mediumSkill
    #---------------------------------------------------------------------------
    when "RandomlyDamageOrHealTarget"
    #---------------------------------------------------------------------------
    when "HealAllyOrDamageFoe" # pollen puff
      if !target.opposes?(user)
				score = 15
				if target.hp>target.totalhp*0.3 && target.hp<target.totalhp*0.7
					score*=3
				end
				if target.hp*(1.0/target.totalhp)<0.3
					score*=1.7
				end
				if target.poisoned? || target.burned? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse]
					score*=0.8
					if target.effects[PBEffects::Toxic]>0
						score*=0.7
					end
				end
				target.allAllies.each do |barget|
					if target.hp*(1.0/target.totalhp)>0.8
						if ((user.pbSpeed<pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)) && 
							 ((user.pbSpeed<pbRoughStat(barget,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0))
							score*=0.5
						else
							score*=0
						end
					end
				end
				if user.effects[PBEffects::HealBlock]>0 || target.effects[PBEffects::HealBlock]>0
					score*=0
				end
      end
    #---------------------------------------------------------------------------
    when "CurseTargetOrLowerUserSpd1RaiseUserAtkDef1" # curse
			maxdam = 0
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				maxdam = tempdam if tempdam > maxdam
			end
      if user.pbHasType?(:GHOST) && $game_variables[MECHANICSVAR] < 3
				if target.effects[PBEffects::Curse] || user.hp*2<user.totalhp
          score = 0
        else
					score*=0.7
					if (user.pbSpeed < pbRoughStat(target, :SPEED, skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
						score*=0.5
					end
					if maxdam*5 < user.hp
						score*=1.3
					end
					for j in user.moves
						if j.healingMove?
							score*=1.2
							break
						end
					end
					ministat=0
					ministat+=target.stages[:ATTACK] 
					ministat+=target.stages[:DEFENSE]
					ministat+=target.stages[:SPEED] 
					ministat+=target.stages[:SPECIAL_ATTACK] 
					ministat+=target.stages[:SPECIAL_DEFENSE]
					ministat*=(5)
					ministat+=100
					ministat/=100.0
					score*=ministat  
					if user.hasActiveAbility?([:ARENATRAP, :SHADOWTAG]) || target.effects[PBEffects::MeanLook]>=0 || 
						 @battle.pbAbleNonActiveCount(user.idxOpposingSide)==0
						score*=1.3
					else
						score*=0.8
					end
					hasAlly = !target.allAllies.empty?
					if hasAlly
						score*=0.5
					end
				end
			else
					miniscore=100
          if (target.hasActiveAbility?(:DISGUISE) && target.form == 0) || target.effects[PBEffects::Substitute]>0
            miniscore*=1.3
          end
          if (user.hp.to_f)/user.totalhp>0.75
            miniscore*=1.2
          end
          if (user.hp.to_f)/user.totalhp<0.33
            miniscore*=0.3
          end
          if (user.hp.to_f)/user.totalhp<0.75 && (user.hasActiveAbility?([:WIMPOUT, :EMERGENCYEXIT]) || user.hasActiveItem?(:EJECTBUTTON))
            miniscore*=0.3
          end
          if user.pbOpposingSide.effects[PBEffects::LastRoundFainted] == (@battle.turnCount - 1) # Retaliate
            miniscore*=0.3
          end     
          if target.effects[PBEffects::HyperBeam]>0
            miniscore*=1.3
          end
          if target.effects[PBEffects::Yawn]>0
            miniscore*=1.7
          end
					maxdam = 0
					for m in target.moves
						tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
						maxdam = tempdam if tempdam > maxdam
					end
					if maxdam<(user.hp/4)
						miniscore*=1.2
					end
					if maxdam>(user.hp/2)
						miniscore*=0.3
					end
          if user.turnCount<2
            miniscore*=1.1
          end
          if target.pbHasAnyStatus?
            miniscore*=1.2
          end
          if target.asleep?
            miniscore*=1.3
          end
					if target.effects[PBEffects::Encore]>0
						if GameData::Move.get(target.effects[PBEffects::EncoreMove]).base_damage==0        
              miniscore*=1.5
            end          
          end  
          if user.effects[PBEffects::Confusion]>0
            miniscore*=0.3
          end
          if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
            miniscore*=0.3
          end
					if pbHasPhazingMove?(target)
						miniscore*=0.3
          end
          if user.hasActiveAbility?(:SIMPLE)
            miniscore*=2
          end
          if target.hasActiveAbility?(:UNAWARE)
            miniscore*=0.5
          end
					hasAlly = !target.allAllies.empty?
					if hasAlly
            miniscore*=0.5
          end
          if user.stages[:SPEED]<0
            ministat=user.stages[:SPEED]
            minimini=5*ministat
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
          ministat=0
          ministat+=target.stages[:ATTACK]
          ministat+=target.stages[:SPECIAL_ATTACK]
          ministat+=target.stages[:SPEED]
          if ministat>0
            minimini=(-5)*ministat
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
					for m in target.moves
						miniscore*=1.3 if m.healingMove?
					end
          if (user.pbSpeed > pbRoughStat(target, :SPEED, skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]==0)
            miniscore*=0.5
          else
            miniscore*=1.1
          end
          if user.burned? || user.frozen?
            miniscore*=0.5
          end
          if user.paralyzed?
            miniscore*=0.5
          end
					for m in target.moves
						miniscore*=0.5 if m.id == :FOULPLAY
					end
          physmove=false
					for m in user.moves
						physmove=true if m.physicalMove?
					end
          if physmove && !user.statStageAtMax?(:ATTACK) 
            miniscore/=100.0
            score*=miniscore
          end
          miniscore=100
          if user.effects[PBEffects::Toxic]>0
            miniscore*=0.2
          end
					roles = pbGetPokemonRole(user, target)
          if pbRoughStat(target,:SPECIAL_ATTACK,skill)<pbRoughStat(target,:ATTACK,skill)
            if !(roles.include?("Physical Wall") || roles.include?("Special Wall"))
              if ((user.pbSpeed > pbRoughStat(target, :SPEED, skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)) && (user.hp.to_f)/user.totalhp>0.75
                miniscore*=1.3
              elsif (user.pbSpeed < pbRoughStat(target, :SPEED, skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
                miniscore*=0.7
              end
            end
            miniscore*=1.3
          end
          if roles.include?("Physical Wall") || roles.include?("Special Wall")
            miniscore*=1.1
          end
          if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON))
            miniscore*=1.1
          end
          healmove=false
          for j in user.moves
            if j.healingMove?
              healmove=true
            end
          end
          if healmove
            miniscore*=1.2
          end
          if user.pbHasMove?(:LEECHSEED)
            miniscore*=1.3
          end
          if user.pbHasMove?(:PAINSPLIT)
            miniscore*=1.2
          end 
          if !user.statStageAtMax?(:DEFENSE) 
            miniscore/=100.0
            score*=miniscore
          end
          if user.hasActiveAbility?(:CONTRARY)
            score=0
          end  
          if (user.pbSpeed > pbRoughStat(target, :SPEED, skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)        
            score*=0.7
          end   
          if user.statStageAtMax?(:DEFENSE) && user.statStageAtMax?(:ATTACK) 
            score *= 0
          end
					score = 0 if $game_variables[MECHANICSVAR] >= 3 && user.SetupMovesUsed.include?(move.id)
        end
    #---------------------------------------------------------------------------
    when "EffectDependsOnEnvironment"
    #---------------------------------------------------------------------------
    when "HitsAllFoesAndPowersUpInPsychicTerrain"
			theresone=false
			@battle.allBattlers.each do |j|
				if (j.isSpecies?(:BEHEEYEM) && j.item == :BEHEEYEMITE && j.willmega)
					theresone=true
				end
			end
      score += 40 if (@battle.field.terrain == :Psychic || theresone) && user.affectedByTerrain?
    #---------------------------------------------------------------------------
    when "TargetNextFireMoveDamagesTarget" # powder
			maxdam = 0
			maxtype = -1
			firecheck = false
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				if tempdam > maxdam
					maxdam = tempdam
					maxtype = m.type
				end
				firecheck = true if m.type == :FIRE
			end
			if !(target.pbHasType?(:GRASS) || target.hasActiveAbility?(:OVERCOAT) || target.hasActiveItem?(:SAFETYGOGGLES))
				if (user.pbSpeed<pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
					score*=1.2
				end
				if maxtype == :FIRE
					score*=3
				else
					if target.pbHasType?(:FIRE)
						score*=2
					else
						score*=0.2
					end
				end
				targetTypes = target.pbTypes(true)
				effcheck = Effectiveness.calculate(:FIRE, targetTypes[0], targetTypes[1], targetTypes[2])
				if effcheck>4
					score*=2
					if effcheck>16  # from 8 to 16 changed by JZ
						score*=2
					end
				end
				if user.lastMoveUsed == :POWDER
					score*=0.6
				end        
				if target.hasActiveAbility?(:MAGICGUARD)
					score*=0.5
				end
				if !firecheck
					score*=0
				end   
			else
				score*=0
			end
      aspeed = pbRoughStat(user, :SPEED, skill)
      ospeed = pbRoughStat(target, :SPEED, skill)
      if aspeed > ospeed
        score -= 90
      elsif target.pbHasMoveType?(:FIRE)
        score += 30
      end
    #---------------------------------------------------------------------------
    when "DoublePowerAfterFusionFlare"
    #---------------------------------------------------------------------------
    when "DoublePowerAfterFusionBolt"
    #---------------------------------------------------------------------------
    when "PowerUpAllyMove"
      hasAlly = !user.allAllies.empty?
			if hasAlly
				effvar = false
				for i in user.moves
					if pbCalcTypeMod(i.type, user, target) >= 8            
						effvar = true
					end
				end
				if !effvar
					score*=2
				end
				ministat = 0
				minimini = 0
				user.allAllies.each do |bally|
					target.allAllies.each do |barget|
						if ((user.pbSpeed<pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)) && 
							 ((user.pbSpeed<pbRoughStat(barget,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0))
							score*=1.2
							if user.hp*(1.0/user.totalhp) < 0.33
								score*=1.5
							end
							if bally.pbSpeed<pbRoughStat(target,:SPEED,skill) && bally.pbSpeed<pbRoughStat(barget,:SPEED,skill)
								score*=1.5
							end
						end
					end
					ministat = [bally.attack,bally.spatk].max
					minimini = [user.attack,user.spatk].max
					ministat -= minimini
					ministat+=100
					ministat/=100.0
				end
				score*=ministat
			else
				score -= 90
			end
    #---------------------------------------------------------------------------
    when "CounterPhysicalDamage" # Counter
			maxdam = 0
			maxspec = false
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				if tempdam > maxdam
					maxdam = tempdam
					if m.specialMove?(m.type)
						maxspec = true
					else
						maxspec = false
					end
				end
			end
			if (user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
				score*=0.5
			end
			if user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY))
				score*=1.2
			else
				score*=0.8          
				if maxdam>user.hp
					score*=0.8
				end
			end
			if user.lastRegularMoveUsed == :COUNTER
				score*=0.7
			end
			movecheck=false
			movecheck=true if pbHasSetupMove?(target)
			score*=0.6 if movecheck
			miniscore = user.hp*(1.0/user.totalhp)
			score*=miniscore
			if target.spatk>target.attack
				score*=0.3
			end
			if maxspec
				score*=0.05
			end
			if user.lastRegularMoveUsed == :MIRRORCOAT
				score*=1.1
			end
    #---------------------------------------------------------------------------
    when "CounterSpecialDamage" # mirror coat
			maxdam = 0
			maxspec = false
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				if tempdam > maxdam
					maxdam = tempdam
					if m.specialMove?(m.type)
						maxspec = true
					else
						maxspec = false
					end
				end
			end
			if (user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
				score*=0.5
			end
			if user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY))
				score*=1.2
			else
				score*=0.8          
				if maxdam>user.hp
					score*=0.8
				end
			end
			if user.lastRegularMoveUsed == :MIRRORCOAT
				score*=0.7
			end
			movecheck=false
			movecheck=true if pbHasSetupMove?(target)
			score*=0.6 if movecheck
			miniscore = user.hp*(1.0/user.totalhp)
			score*=miniscore
			if target.spatk<target.attack
				score*=0.3
			end
			if !maxspec
				score*=0.05
			end
			if user.lastRegularMoveUsed == :COUNTER
				score*=1.1
			end
    #---------------------------------------------------------------------------
    when "CounterDamagePlusHalf" # Metal Burst
			maxdam = 0
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				maxdam = tempdam if tempdam > maxdam
			end
			if (user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
				score*=0.5
			end
			if user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY))
				score*=1.2
			else
				score*=0.8          
				if maxdam>user.hp
					score*=0.8
				end
			end
			if user.lastRegularMoveUsed == :METALBURST
				score*=0.7
			end
			movecheck=false
			movecheck=true if pbHasSetupMove?(target)
			score*=0.6 if movecheck
			miniscore = user.hp*(1.0/user.totalhp)
			score*=miniscore
    #---------------------------------------------------------------------------
    when "UserAddStockpileRaiseDefSpDef1" # stockpile
			miniscore=100
			if user.pbHasMoveFunction?("PowerDependsOnUserStockpile","HealUserDependingOnUserStockpile") 
				miniscore*=1.6
			end
			if user.effects[PBEffects::Stockpile]<3
				miniscore/=100.0
				score*=miniscore
			else
				score=0
			end
			if !user.SetupMovesUsed.include?(move.id)
				if (user.hasActiveAbility?(:DISGUISE) && user.form == 0) || user.effects[PBEffects::Substitute]>0
					miniscore*=1.3
				end
				if (user.hp.to_f)/user.totalhp>0.75
					miniscore*=1.1
				end
				if target.effects[PBEffects::HyperBeam]>0
					miniscore*=1.2
				end
				if target.effects[PBEffects::Yawn]>0
					miniscore*=1.3
				end
				maxdam = 0
				for m in target.moves
					tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
					maxdam = tempdam if tempdam > maxdam
				end
				if maxdam<(user.hp/4)
					miniscore*=1.1
				else
					if move.baseDamage==0 
						miniscore*=0.8
						if maxdam>user.hp
							miniscore*=0.1
						end
					end
				end
				if user.turnCount<2
					miniscore*=1.1
				end
				if target.pbHasAnyStatus?
					miniscore*=1.1
				end
				if target.asleep?
					miniscore*=1.3
				end
				if target.effects[PBEffects::Encore]>0
					if GameData::Move.get(target.effects[PBEffects::EncoreMove]).base_damage==0
						miniscore*=1.5
					end          
				end  
				if user.effects[PBEffects::Confusion]>0
					miniscore*=0.5
				end
				if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
					miniscore*=0.3
				end
				if user.effects[PBEffects::Toxic]>0
					miniscore*=0.2
				end
				if pbHasPhazingMove?(target)
					miniscore*=0.2
				end   
				if user.hasActiveAbility?(:SIMPLE)
					miniscore*=2
				end
				if target.hasActiveAbility?(:UNAWARE)
					miniscore*=0.5
				end
				hasAlly = !target.allAllies.empty?
				if hasAlly
					miniscore*=0.3
				end
				maxdam = 0
				for m in target.moves
					tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
					maxdam = tempdam if tempdam > maxdam
				end
				if (maxdam.to_f/user.hp)<0.12
					miniscore*=0.3
				end
				miniscore/=100.0
				score*=miniscore
				miniscore=100
				roles = pbGetPokemonRole(user, target)
				if roles.include?("Physical Wall") || roles.include?("Special Wall")
					miniscore*=1.5
				end   
				if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON))
					miniscore*=1.2
				end        
				healmove=false
				for j in user.moves
					if j.healingMove?
						healmove=true
					end
				end
				if healmove
					miniscore*=1.7
				end
				if user.pbHasMove?(:LEECHSEED)
					miniscore*=1.3
				end
				if user.pbHasMove?(:PAINSPLIT)
					miniscore*=1.2
				end
				if user.hasActiveAbility?(:CONTRARY)
					score=0
				end  
				if user.statStageAtMax?(:SPECIAL_DEFENSE) && user.statStageAtMax?(:DEFENSE)
					score*=0
				end
			end
    #---------------------------------------------------------------------------
    when "PowerDependsOnUserStockpile" # split up
			initialscores = score
			if user.effects[PBEffects::Stockpile]==0
				score*=0
			else
				score*=0.8
				roles = pbGetPokemonRole(user, target)
				if roles.include?("Physical Wall") || roles.include?("Special Wall")
					score*=0.7
				end
				if roles.include?("Tank")
					score*=0.9
				end
				count=0
				for m in user.moves
					count+=1 if m.baseDamage>0
				end
				if count>1
					score*=0.5
				end
				if @battle.pbAbleNonActiveCount(user.idxOpposingSide)==0
					score*=0.7
				else
					score*=1.2
				end
				if initialscores < 110
					score*=0.5
				else
					score*=1.3
				end
				if (user.pbSpeed<pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
					score*=1.1
				else
					score*=0.8
				end
				if user.pbHasMoveFunction?("HealUserDependingOnUserStockpile")
					if user.hp/(user.totalhp).to_f < 0.66
						score*=0.8
						if user.hp/(user.totalhp).to_f < 0.4
							score*=0.5
						end
					end
				end
			end
    #---------------------------------------------------------------------------
    when "HealUserDependingOnUserStockpile" # swallow
			maxdam = 0
			movecheck = false
			movecheck = true if pbHasSetupMove?(target)
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				maxdam = tempdam if tempdam > maxdam
			end
			initialscores = score
			if user.effects[PBEffects::Stockpile]==0
				score*=0
			else
				score+= 10*user.effects[PBEffects::Stockpile]
				score*=0.8
				roles = pbGetPokemonRole(user, target)
				if roles.include?("Physical Wall") || roles.include?("Special Wall")
					score*=0.9
				end
				if roles.include?("Tank")
					score*=0.9
				end
				count=0
				for m in user.moves
					count+=1 if m.healingMove?
				end
				if count>1
					score*=0.5
				end          
				if (user.pbSpeed<pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
					score*=1.1
				else
					score*=0.8
				end
				if maxdam>user.hp
					score*=2
				else
					if maxdam*1.5 > user.hp
						score*=1.5
					end
					if (user.pbSpeed<pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
						if maxdam*2 > user.hp
							score*=2
						else
							score*=0.2
						end
					end
				end
				if movecheck
					score*=0.7
				end
				if user.hp*2 < user.totalhp
					score*=1.5
				end
				if user.poisoned? || user.burned? || user.frozen? || user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Curse]
					score*=1.3
					if user.effects[PBEffects::Toxic]>0
						score*=1.3
					end
				end
				if target.effects[PBEffects::HyperBeam]>0
					score*=1.2
				end
				if user.hp/(user.totalhp).to_f > 0.8
					score*=0
				end
			end
    #---------------------------------------------------------------------------
    when "GrassPledge" # Grass Pledge
    #---------------------------------------------------------------------------
    when "FirePledge" # Fire Pledge
    #---------------------------------------------------------------------------
    when "WaterPledge" # Water Pledge
    #---------------------------------------------------------------------------
    when "UseLastMoveUsed" # copycat
			if target.lastRegularMoveUsed  && target.effects[PBEffects::Substitute]<=0
				copied = Pokemon::Move.new(target.lastRegularMoveUsed)
				copymove = Battle::Move.from_pokemon_move(@battle, copied)
				if target.lastRegularMoveUsed || 
					 GameData::Move.get(copymove).flags.none? { |f| f[/^CanMirrorMove$/i] }
					score*=0
				else
					rough = pbRoughDamage(copymove, user, target, skill, copymove.baseDamage)
					copyscore = pbGetMoveScore(rough, copymove, user, target, skill)
					score = copyscore
					if (user.pbSpeed<pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
						score*=0.5
					end
				end
			else
				score*=0
			end
    #---------------------------------------------------------------------------
    when "UseLastMoveUsedByTarget" # Mirror Move
			if target.lastRegularMoveUsed
				mirrored = Pokemon::Move.new(target.lastRegularMoveUsed)
				mirrmove = Battle::Move.from_pokemon_move(@battle, mirrored)
				if target.lastRegularMoveUsed || 
					 GameData::Move.get(mirrmove).flags.none? { |f| f[/^CanMirrorMove$/i] }
					score *= 0
				else
					rough = pbRoughDamage(mirrmove, user, target, skill, mirrmove.baseDamage)
					mirrorscore = pbGetMoveScore(rough, mirrmove, user, target, skill)
					score = mirrorscore
					if (user.pbSpeed<pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
						score *= 0.5
					end
				end
			else
				score*=0        
			end
    #---------------------------------------------------------------------------
    when "UseMoveTargetIsAboutToUse" # Me First
			if (user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
				privar = false
				setupvar = false
				maxdam = 0
				for m in target.moves
					tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
					maxdam = tempdam if tempdam>maxdam
					privar = true if m.priority > 0
					healvar = true if m.healingMove?
				end
				if pbHasSetupMove?(target)
					score*=0.8
				else
					score*=1.5
				end
				if privar || target.hasActiveAbility?(:PRANKSTER) || (target.hasActiveAbility?(:GALEWINGS) && (target.hp >= (target.totalhp/2))) || (target.hasActiveAbility?(:TRIAGE) && m.healingMove?)
					score*=0.6
				else
					score*=1.5
				end
				if target.hp>0
					score*=0.5
				end
			else
				score*=0
			end
    #---------------------------------------------------------------------------
    when "UseMoveDependingOnEnvironment" # nature power
			newmove = :TRIATTACK
			case @battle.field.terrain
			when :Electric
				newmove = :THUNDERBOLT if GameData::Move.exists?(:THUNDERBOLT)
			when :Grassy
				newmove = :ENERGYBALL if GameData::Move.exists?(:ENERGYBALL)
			when :Misty
				newmove = :MOONBLAST if GameData::Move.exists?(:MOONBLAST)
			when :Psychic
				newmove = :PSYCHIC if GameData::Move.exists?(:PSYCHIC)
			end
			newdata = Pokemon::Move.new(newmove)
			naturemove = Battle::Move.from_pokemon_move(@battle, newdata)
			if naturemove.baseDamage<=0
				naturedam = pbStatusDamage(naturemove)
			else
				tempdam = pbRoughDamage(naturemove, user, target, skill, naturemove.baseDamage)
				naturedam = (tempdam*100)/(target.hp.to_f)
			end
			naturedam = 110 if naturedam>110
			score = pbGetMoveScore(naturemove, user, target, skill, naturedam)
    #---------------------------------------------------------------------------
    when "UseRandomMove" # metronome
			initialscores = 0 #pbCheckOtherMovesScore(user, target, move)
			if initialscores>21
				score*=0.5
			else
				score*=1.2
			end
    #---------------------------------------------------------------------------
    when "UseRandomMoveFromUserParty" # assist
			if @battle.pbAbleNonActiveCount(user.idxOwnSide) > 0
				initialscores = 0 #pbCheckOtherMovesScore(user, target, move)
				if initialscores>25
					score*=0.5
				else
					score*=1.5
				end
			else
				score*=0
			end
    #---------------------------------------------------------------------------
    when "UseRandomUserMoveIfAsleep" # sleep talk
			if user.asleep?
				if user.statusCount<=1
					score*=0
				end
			else
				score*=0
			end
    #---------------------------------------------------------------------------
    when "BounceBackProblemCausingStatusMoves" # magic coat
			if target.lastRegularMoveUsed
				olddata = Pokemon::Move.new(target.lastRegularMoveUsed)
				oldmove = Battle::Move.from_pokemon_move(@battle,olddata)
				if oldmove.function == "BounceBackProblemCausingStatusMoves"
					score*=0.5
				else
					if user.hp==user.totalhp
						score*=1.5
					end
					statvar = true
					for i in target.moves
						if i.baseDamage>0
							statvar=false
						end
					end
					if statvar
						score*=3
					end
				end
			else
				if user.hp==user.totalhp
					score*=1.5
				end
				statvar = true
				for i in target.moves
					if i.baseDamage>0
						statvar=false
					end
				end
				if statvar
					score*=3
				end
			end
    #---------------------------------------------------------------------------
    when "StealAndUseBeneficialStatusMove" # snatch
			setupvar = false
			setupvar = true if pbHasSetupMove?(target)
			if user.lastRegularMoveUsed
				olddata = Pokemon::Move.new(user.lastRegularMoveUsed)
				oldmove = Battle::Move.from_pokemon_move(@battle, olddata)
				if oldmove.function == "StealAndUseBeneficialStatusMove"
					score*=0.5
				else
					if target.hp==target.totalhp
						score*=1.5
					end
					if setupvar
						score*=2
					end
					if target.attack>target.spatk
						if user.attack>user.spatk
							score*=1.5
						else
							score*=0.7
						end
					else
						if user.spatk>user.attack
							score*=1.5
						else
							score*=0.7
						end
					end
				end
			else
				if target.hp==target.totalhp
					score*=1.5
				end
				if setupvar
					score*=2
				end
				if target.attack>target.spatk
					if user.attack>user.spatk
						score*=1.5
					else
						score*=0.7
					end
				else
					if user.spatk>user.attack
						score*=1.5
					else
						score*=0.7
					end
				end
			end
    #---------------------------------------------------------------------------
    when "ReplaceMoveThisBattleWithTargetLastMoveUsed"
      moveBlacklist = [
        "Struggle",   # Struggle
        "ReplaceMoveThisBattleWithTargetLastMoveUsed",   # Mimic
        "ReplaceMoveWithTargetLastMoveUsed",   # Sketch
        "UseRandomMove"   # Metronome
      ]
      if user.effects[PBEffects::Transform] || !target.lastRegularMoveUsed
        score -= 90
      else
        lastMoveData = GameData::Move.get(target.lastRegularMoveUsed)
        if moveBlacklist.include?(lastMoveData.function_code) ||
           lastMoveData.type == :SHADOW
          score -= 90
        end
        user.eachMove do |m|
          next if m != target.lastRegularMoveUsed
          score -= 90
          break
        end
      end
    #---------------------------------------------------------------------------
    when "ReplaceMoveWithTargetLastMoveUsed"
      moveBlacklist = [
        "Struggle",   # Struggle
        "ReplaceMoveWithTargetLastMoveUsed"   # Sketch
      ]
      if user.effects[PBEffects::Transform] || !target.lastRegularMoveUsed
        score -= 90
      else
        lastMoveData = GameData::Move.get(target.lastRegularMoveUsed)
        if moveBlacklist.include?(lastMoveData.function_code) ||
           lastMoveData.type == :SHADOW
          score -= 90
        end
        user.eachMove do |m|
          next if m != target.lastRegularMoveUsed
          score -= 90   # User already knows the move that will be Sketched
          break
        end
      end
    #---------------------------------------------------------------------------
    when "FleeFromBattle"
      score -= 100 if @battle.trainerBattle?
    #---------------------------------------------------------------------------
    when "SwitchOutUserStatusMove"
			target=user.pbDirectOpposing(true)
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			score -= 30 if user.pbOwnSide.effects[PBEffects::StealthRock] || user.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 ||
										 user.pbOwnSide.effects[PBEffects::Spikes]>0 || user.pbOwnSide.effects[PBEffects::StickyWeb]
			score +=30 if user.hasActiveAbility?(:REGENERATOR)
			score +=30 if user.effects[PBEffects::Toxic]>3
			score +=30 if user.effects[PBEffects::Curse]
			score +=30 if user.effects[PBEffects::PerishSong]==1
			score +=30 if user.effects[PBEffects::LeechSeed]>0
			score +=30 if target.status == :SLEEP && target.statusCount>1
    #---------------------------------------------------------------------------
    when "SwitchOutUserDamagingMove" # u-turn
			# why in the actual fuckity fuck, would you ignore your best pokemon in this scenario?????
			# that was so retarded holy shit
			userlivecount = @battle.pbAbleNonActiveCount(user.idxOwnSide)
      if userlivecount>1
				aspeed = pbRoughStat(user,:SPEED,skill)
				ospeed = pbRoughStat(target,:SPEED,skill)
				if aspeed>ospeed && !(target.status == :SLEEP && target.statusCount>1)
					score *= 0.3 # DemICE: Switching AI is dumb so if you're faster, don't sack a healthy mon. Better use another move.
				end
				if user.pbOwnSide.effects[PBEffects::StealthRock]
					score*=0.7
				end
				if user.pbOwnSide.effects[PBEffects::StickyWeb]
					score*=0.6
				end
				if user.pbOwnSide.effects[PBEffects::Spikes]>0
					score*=0.9**user.pbOwnSide.effects[PBEffects::Spikes]
				end
				if user.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
					score*=0.9**user.pbOwnSide.effects[PBEffects::ToxicSpikes]
				end
				count = -1
				sweepvar = false
				@battle.pbParty(user.index).each do |i|
					next if i.nil?
					count+=1
					temproles = pbGetPokemonRole(i, target, count, @battle.pbParty(user.index))
					if temproles.include?("Sweeper")
						sweepvar = true
					end
				end  
				if (user.pbSpeed>pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
					score*=1.2
				else
					if sweepvar
						score*=1.2
					end
				end
				if user.hasActiveAbility?(:REGENERATOR) && ((user.hp.to_f)/user.totalhp)<0.75
					score*=1.2
					if user.hasActiveAbility?(:REGENERATOR) && ((user.hp.to_f)/user.totalhp)<0.5
						score*=1.2
					end
				end
				loweredstats=0
				loweredstats+=user.stages[:ATTACK] if user.stages[:ATTACK]<0
				loweredstats+=user.stages[:DEFENSE] if user.stages[:DEFENSE]<0
				loweredstats+=user.stages[:SPEED] if user.stages[:SPEED]<0
				loweredstats+=user.stages[:SPECIAL_ATTACK] if user.stages[:SPECIAL_ATTACK]<0
				loweredstats+=user.stages[:SPECIAL_DEFENSE] if user.stages[:SPECIAL_DEFENSE]<0
				loweredstats+=user.stages[:EVASION] if user.stages[:EVASION]<0
				miniscore= (-15)*loweredstats    
				miniscore+=100
				miniscore/=100.0
				score*=miniscore
				raisedstats=0
				raisedstats+=user.stages[:ATTACK] if user.stages[:ATTACK]>0
				raisedstats+=user.stages[:DEFENSE] if user.stages[:DEFENSE]>0
				raisedstats+=user.stages[:SPEED] if user.stages[:SPEED]>0
				raisedstats+=user.stages[:SPECIAL_ATTACK] if user.stages[:SPECIAL_ATTACK]>0
				raisedstats+=user.stages[:SPECIAL_DEFENSE] if user.stages[:SPECIAL_DEFENSE]>0
				raisedstats+=user.stages[:EVASION] if user.stages[:EVASION]>0
				miniscore= (-25)*raisedstats
				miniscore+=100
				miniscore/=100.0
				score*=miniscore    
				if user.effects[PBEffects::Toxic]>0 || user.effects[PBEffects::Attract]>-1 || user.effects[PBEffects::Confusion]>0
					score*=1.3
				end
				if user.effects[PBEffects::LeechSeed]>-1
					score*=1.5
				end
			end
    #---------------------------------------------------------------------------
    when "LowerTargetAtkSpAtk1SwitchOutUser" # Parting Shot
			if (!target.pbCanLowerStatStage?(:ATTACK) && !target.pbCanLowerStatStage?(:SPECIAL_ATTACK)) || 
				 (target.stages[:ATTACK]==-6 && target.stages[:SPECIAL_ATTACK]==-6) || 
				 (target.stages[:ATTACK]<0 && target.stages[:SPECIAL_ATTACK]<0)
				score*=0
			else
				if @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
					if user.pbOwnSide.effects[PBEffects::StealthRock]
						score*=0.7
					end
					if user.pbOwnSide.effects[PBEffects::StickyWeb]
						score*=0.6
					end
					if user.pbOwnSide.effects[PBEffects::Spikes]>0
						score*=0.9**user.pbOwnSide.effects[PBEffects::Spikes]
					end
					if user.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
						score*=0.9**user.pbOwnSide.effects[PBEffects::ToxicSpikes]
					end 
					if (user.pbSpeed>pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
						score*=1.1
					end
					sweepvar = false
					count=0
					@battle.pbParty(user.index).each do |i|
						next if i.nil?
						count+=1
						temproles = pbGetPokemonRole(i, target, count, @battle.pbParty(user.index))
						if temproles.include?("Sweeper")
							sweepvar = true
						end
					end
					if sweepvar 
						score*=1.5
					end
					roles = pbGetPokemonRole(user, target)
					if roles.include?("Lead")
						score*=1.1
					end
					if roles.include?("Pivot")
						score*=1.2
					end
					loweredstats=0
					loweredstats+=user.stages[:ATTACK] if user.stages[:ATTACK]<0
					loweredstats+=user.stages[:DEFENSE] if user.stages[:DEFENSE]<0
					loweredstats+=user.stages[:SPEED] if user.stages[:SPEED]<0
					loweredstats+=user.stages[:SPECIAL_ATTACK] if user.stages[:SPECIAL_ATTACK]<0
					loweredstats+=user.stages[:SPECIAL_DEFENSE] if user.stages[:SPECIAL_DEFENSE]<0
					loweredstats+=user.stages[:EVASION] if user.stages[:EVASION]<0
					miniscore= (5)*loweredstats    
					miniscore+=100
					miniscore/=100.0
					score*=miniscore      
					raisedstats=0
					raisedstats+=user.stages[:ATTACK] if user.stages[:ATTACK]>0
					raisedstats+=user.stages[:DEFENSE] if user.stages[:DEFENSE]>0
					raisedstats+=user.stages[:SPEED] if user.stages[:SPEED]>0
					raisedstats+=user.stages[:SPECIAL_ATTACK] if user.stages[:SPECIAL_ATTACK]>0
					raisedstats+=user.stages[:SPECIAL_DEFENSE] if user.stages[:SPECIAL_DEFENSE]>0
					raisedstats+=user.stages[:ACCURACY] if user.stages[:ACCURACY]>0
					miniscore= (-5)*raisedstats
					miniscore+=100
					miniscore/=100.0
					score*=miniscore    
					if user.effects[PBEffects::Toxic]>0 || user.effects[PBEffects::Attract]>-1 || user.effects[PBEffects::Confusion]>0
						score*=1.3
					end
					if user.effects[PBEffects::LeechSeed]>-1
						score*=1.5
					end   
					miniscore=130
					if user.hasActiveAbility?([:ARENATRAP, :SHADOWTAG]) || target.effects[PBEffects::MeanLook]>=0 || 
						 @battle.pbAbleNonActiveCount(user.idxOpposingSide)==0
						miniscore*=1.4
					end
					ministat=0          
					ministat+=target.stages[:ATTACK] if target.stages[:ATTACK]<0
					ministat+=target.stages[:DEFENSE] if target.stages[:DEFENSE]<0
					ministat+=target.stages[:SPEED] if target.stages[:SPEED]<0
					ministat+=target.stages[:SPECIAL_ATTACK] if target.stages[:SPECIAL_ATTACK]<0
					ministat+=target.stages[:SPECIAL_DEFENSE] if target.stages[:SPECIAL_DEFENSE]<0
					ministat+=target.stages[:EVASION] if target.stages[:EVASION]<0
					ministat*=(5)
					ministat+=100
					ministat/=100.0
					miniscore*=ministat  
					if target.hasActiveAbility?([:UNAWARE, :COMPETITIVE, :DEFIANT, :CONTRARY])
						miniscore*=0.1
					end
					miniscore/=100.0
					score*=miniscore
				else
					score = 0
				end    
			end
    #---------------------------------------------------------------------------
    when "SwitchOutUserPassOnEffects" # baton pass
      if @battle.pbCanChooseNonActive?(user.index)
				if user.effects[PBEffects::Substitute]>0
					score*=1.3
				end
				if user.effects[PBEffects::Confusion]>0
					score*=0.5
				end
				if user.effects[PBEffects::LeechSeed]>=0
					score*=0.5
				end
				if user.effects[PBEffects::Curse]
					score*=0.5
				end          
				if user.effects[PBEffects::Yawn]>0
					score*=0.5
				end
				if user.turnCount<1
					score*=0.5
				end
				damvar = false
				for i in user.moves
					if i.damagingMove?
						damvar=true
					end
				end
				if !damvar
					score*1.3
				end
				if user.effects[PBEffects::Ingrain] || user.effects[PBEffects::AquaRing]
					score*=1.2
				end
				if user.pbOwnSide.effects[PBEffects::StealthRock]
					score*=0.8
				end
				if user.pbOwnSide.effects[PBEffects::Spikes] > 0
					score/=(1.2**user.pbOwnSide.effects[PBEffects::Spikes])
				end
				if user.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
					score/=(1.2**user.pbOwnSide.effects[PBEffects::ToxicSpikes])
				end
				if user.effects[PBEffects::PerishSong]>0
					score*=0
				end
      else
        score = 0
			end
    #---------------------------------------------------------------------------
    when "SwitchOutTargetStatusMove" # roar
			if target.pbOwnSide.effects[PBEffects::StealthRock]
				score*=1.3
			else
				score*=0.8
			end
			if target.pbOwnSide.effects[PBEffects::Spikes] > 0
				score*=(1.2**target.pbOwnSide.effects[PBEffects::Spikes])
			else
				score*=0.8
			end
			if target.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
				score*=1.1
			end
			ministat=0
			ministat+=target.stages[:ATTACK] 
			ministat+=target.stages[:DEFENSE]
			ministat+=target.stages[:SPEED] 
			ministat+=target.stages[:SPECIAL_ATTACK] 
			ministat+=target.stages[:SPECIAL_DEFENSE] 
			ministat+=target.stages[:EVASION]
			ministat*=10
			ministat+=100
			ministat/=100.0
			score*=ministat
			if target.effects[PBEffects::PerishSong]>0 || target.effects[PBEffects::Yawn]>0
				score*=0
			end
			if target.asleep?
				score*=1.3
			end
			if target.hasActiveAbility?(:SLOWSTART)
				score*=1.3
			end
			if target.item==0 && target.hasActiveAbility?(:UNBURDEN)
				score*=1.5
			end
			if target.hasActiveAbility?(:INTIMIDATE)
				score*=0.7
			end
			if target.hasActiveAbility?(:REGENERATOR) || target.hasActiveAbility?(:NATURALCURE)
				score*=0.5
			end
			if (user.pbSpeed<pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
				score*=0.8
			end
			if user.effects[PBEffects::Substitute]>0
				score*=1.4
			end
			if target.effects[PBEffects::Ingrain] || target.hasActiveAbility?(:SUCTIONCUPS) || @battle.pbAbleNonActiveCount(user.idxOpposingSide)
				score*=0
			end
    #---------------------------------------------------------------------------
    when "SwitchOutTargetDamagingMove" # dragon tail
      if (target.hasActiveAbility?(:DISGUISE) && target.form == 0) || target.effects[PBEffects::Substitute]>0
				miniscore = 1
				if target.pbOwnSide.effects[PBEffects::StealthRock]
					miniscore*=1.3
				else
					miniscore*=0.8
				end
				if target.pbOwnSide.effects[PBEffects::Spikes] > 0
					miniscore*=(1.2**target.pbOwnSide.effects[PBEffects::Spikes])
				else
					miniscore*=0.8
				end
				if target.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
					miniscore*=1.1
				end
				ministat=0
				ministat+=target.stages[:ATTACK] 
				ministat+=target.stages[:DEFENSE]
				ministat+=target.stages[:SPEED] 
				ministat+=target.stages[:SPECIAL_ATTACK] 
				ministat+=target.stages[:SPECIAL_DEFENSE] 
				ministat+=target.stages[:EVASION]
				ministat*=10
				ministat+=100
				ministat/=100.0
				miniscore*=ministat
				if target.effects[PBEffects::PerishSong]>0 || target.effects[PBEffects::Yawn]>0
					miniscore*=0
				end
				if target.asleep?
					miniscore*=1.3
				end
				if target.hasActiveAbility?(:SLOWSTART)
					miniscore*=1.3
				end
				if target.item==0 && target.hasActiveAbility?(:UNBURDEN)
					miniscore*=1.5
				end
				if target.hasActiveAbility?(:INTIMIDATE)
					miniscore*=0.7
				end
				if target.hasActiveAbility?(:REGENERATOR) || target.hasActiveAbility?(:NATURALCURE)
					miniscore*=0.5
				end
				if (user.pbSpeed<pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
					miniscore*=0.8
				end
				if user.effects[PBEffects::Substitute]>0
					miniscore*=1.4
				end
				if target.effects[PBEffects::Ingrain] || target.hasActiveAbility?(:SUCTIONCUPS) || @battle.pbAbleNonActiveCount(user.idxOpposingSide)
					miniscore*=0
				end
      end
    #---------------------------------------------------------------------------
    when "BindTarget" # fire spin
			maxdam = 0
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				maxdam = tempdam if tempdam > maxdam
			end
			if target.effects[PBEffects::Trapping] == 0 && target.effects[PBEffects::Substitute]<=0
				score*=1.2
				ministat=0
				ministat+=target.stages[:SPEED] if target.stages[:SPEED]>0
				ministat+=target.stages[:ATTACK] if target.stages[:ATTACK]>0
				ministat+=target.stages[:DEFENSE] if target.stages[:DEFENSE]>0
				ministat+=target.stages[:SPECIAL_ATTACK] if target.stages[:SPECIAL_ATTACK]>0
				ministat+=target.stages[:SPECIAL_DEFENSE] if target.stages[:SPECIAL_DEFENSE]>0
				ministat*=(-5)
				ministat+=100
				ministat/=100.0
				score*=ministat
				if target.totalhp == target.hp
					score*=1.2
				elsif target.hp*2 < target.totalhp
					score*=0.8
				end
				if maxdam>user.hp
					score*0.7
				elsif user.hp*3<user.totalhp
					score*0.7
				end
				if target.effects[PBEffects::LeechSeed]>=0
					score*=1.5
				end
				if target.effects[PBEffects::Attract]>-1 
					score*=1.3
				end          
				if target.effects[PBEffects::Confusion]>0
					score*=1.3
				end
				if pbHasSingleTargetProtectMove?(user)
					score*=1.1
				end
				if user.hasActiveItem?(:BINDINGBAND)
					score*=1.3
				end
				if user.hasActiveItem?(:GRIPCLAW)
					score*=1.1
				end  
			end
    #---------------------------------------------------------------------------
    when "BindTargetDoublePowerIfTargetUnderwater" # Whirlpool
			maxdam = 0
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				maxdam = tempdam if tempdam > maxdam
			end
			if target.effects[PBEffects::Trapping] == 0 && target.effects[PBEffects::Substitute]<=0
				score*=1.2
				ministat=0
				ministat+=target.stages[:SPEED] if target.stages[:SPEED]>0
				ministat+=target.stages[:ATTACK] if target.stages[:ATTACK]>0
				ministat+=target.stages[:DEFENSE] if target.stages[:DEFENSE]>0
				ministat+=target.stages[:SPECIAL_ATTACK] if target.stages[:SPECIAL_ATTACK]>0
				ministat+=target.stages[:SPECIAL_DEFENSE] if target.stages[:SPECIAL_DEFENSE]>0
				ministat*=(-5)
				ministat+=100
				ministat/=100.0
				score*=ministat
				if target.totalhp == target.hp
					score*=1.2
				elsif target.hp*2 < target.totalhp
					score*=0.8
				end
				if maxdam>user.hp
					score*0.7
				elsif user.hp*3<user.totalhp
					score*0.7
				end
				if target.effects[PBEffects::LeechSeed]>=0
					score*=1.5
				end
				if target.effects[PBEffects::Attract]>-1 
					score*=1.3
				end          
				if target.effects[PBEffects::Confusion]>0
					score*=1.3
				end
				if pbHasSingleTargetProtectMove?(user)
					score*=1.1
				end
				if user.hasActiveItem?(:BINDINGBAND)
					score*=1.3
				end
				if user.hasActiveItem?(:GRIPCLAW)
					score*=1.1
				end  
				if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderwater")
					score*=1.3
				end  
			end
    #---------------------------------------------------------------------------
    when "TrapTargetInBattle", "TrapTargetInBattleLowerTargetDefSpDef1EachTurn" # mean look / octolock
			movecheck = false
			movecheck = true if pbHasPivotMove?(target)
			if !target.trappedInBattle? && target.effects[PBEffects::Substitute]<=0
				if movecheck
					score*=0.1
				end
				if user.pbHasMove?(:PERISHSONG)
					score*=1.5
				end
				if target.effects[PBEffects::PerishSong]>0
					score*=4
				end
				if user.hasActiveAbility?(:ARENATRAP) || user.hasActiveAbility?(:SHADOWTAG)
					score*=0
				end
				if target.effects[PBEffects::Attract]>=0
					score*=1.3
				end
				if target.effects[PBEffects::LeechSeed]>=0
					score*=1.3
				end
				if target.effects[PBEffects::Curse]
					score*=1.5
				end 
				if pbHasPhazingMove?(user)
					score*=0.7
				end
				ministat=0
				ministat+=target.stages[:ATTACK] 
				ministat+=target.stages[:DEFENSE]
				ministat+=target.stages[:SPEED] 
				ministat+=target.stages[:SPECIAL_ATTACK] 
				ministat+=target.stages[:SPECIAL_DEFENSE] 
				ministat+=target.stages[:EVASION]
				ministat*=(-5)
				ministat+=100
				ministat/=100.0
				score*=ministat    
				if target.effects[PBEffects::Confusion]>0
					score*=1.1
				end
			else
				score*=0
			end
    #---------------------------------------------------------------------------
    when "TrapUserAndTargetInBattle"
      if target.effects[PBEffects::JawLock] < 0
        score += 40 if !user.trappedInBattle? && !target.trappedInBattle?
      end
    #---------------------------------------------------------------------------
    when "TrapAllBattlersInBattleForOneTurn" # Fairy Lock
			if user.effects[PBEffects::PerishSong]==1 || user.effects[PBEffects::PerishSong]==2
				score*=0
			else
				if target.effects[PBEffects::PerishSong]==2
					score*=10
				end
				if target.effects[PBEffects::PerishSong]==1
					score*=20
				end
				if user.effects[PBEffects::LeechSeed]>=0
					score*=0.8
				end
				if target.effects[PBEffects::LeechSeed]>=0
					score*=1.2
				end
				if target.effects[PBEffects::Curse]
					score*=1.3
				end
				if user.effects[PBEffects::Curse]
					score*=0.7
				end
				if target.effects[PBEffects::Confusion]>0
					score*=1.1
				end
				if user.effects[PBEffects::Confusion]>0
					score*=1.1
				end
			end
    #---------------------------------------------------------------------------
    when "PursueSwitchingFoe" # Pursuit
			if target.battle.choices[target.index][0] == :SwitchOut
				score*=3
			end
			miniscore = 0
			miniscore+=target.stages[:ATTACK] if target.stages[:ATTACK]<0
			miniscore+=target.stages[:DEFENSE] if target.stages[:DEFENSE]<0
			miniscore+=target.stages[:SPEED] if target.stages[:SPEED]<0
			miniscore+=target.stages[:SPECIAL_ATTACK] if target.stages[:SPECIAL_ATTACK]<0
			miniscore+=target.stages[:SPECIAL_DEFENSE] if target.stages[:SPECIAL_DEFENSE]<0
			miniscore+=target.stages[:EVASION] if target.stages[:EVASION]<0
			miniscore+=target.stages[:ACCURACY] if target.stages[:ACCURACY]<0
			miniscore*=(-10)
			miniscore+=100
			miniscore/=100.0
			score*=miniscore
			if target.effects[PBEffects::Confusion]>0
				score*=1.2
			end
			if target.effects[PBEffects::LeechSeed]>=0
				score*=1.5
			end
			if target.effects[PBEffects::Attract]>=0
				score*=1.3
			end
			if target.effects[PBEffects::Substitute]>0
				score*=0.7
			end
			if target.effects[PBEffects::Yawn]>0
				score*=1.5
			end
    #---------------------------------------------------------------------------
    when "UsedAfterUserTakesPhysicalDamage" # Shell Trap
			setupcheck = false
			setupcheck = true if pbHasSetupMove?(target, false)
			specialvar = false
			maxdam = 0
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				if tempdam > maxdam
					maxdam = tempdam
					if m.specialMove?
						specialvar = true
					else
						specialvar = false
					end
				end
			end
			if (user.pbSpeed<pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
				score*=0.5
			end
			if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && 
				 !user.takesHailDamage? && !user.takesSandstormDamage?)
				score*=1.2
			else
				score*=0.8
				if maxdam>user.hp
					score*=0.8
				end
			end
			if user.lastMoveUsed == :SHELLTRAP
				score*=0.7
			end
			if setupcheck
				score*=0.6
			end
			miniscore = user.hp*(1.0/user.totalhp)
			score*=miniscore
			if target.spatk > target.attack
				score*=0.3
			end
			if specialvar
				score*=0.05
			end
    #---------------------------------------------------------------------------
    when "UsedAfterAllyRoundWithDoublePower" # round
			user.allAllies.each do |b|
				next if !b.pbHasMove?(move.id)
				score *= 2
			end
    #---------------------------------------------------------------------------
    when "TargetActsNext"
    #---------------------------------------------------------------------------
    when "TargetActsLast"
    #---------------------------------------------------------------------------
    when "TargetUsesItsLastUsedMoveAgain" # instruct
			hasAlly = !user.allAllies.empty?
			if hasAlly || !user.opposes?(target) || !target.lastRegularMoveUsed
				score=0
			else
				score*=3
				user.allAllies.each do |b|
					if b.hp*2 < b.totalhp
						score*=0.5
					else
						if b.hp==b.totalhp
							score*=1.2
						end            
					end
					target.allAllies.each do |z|
						if (b.pbSpeed<pbRoughStat(z,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
							score*=1.4
						end
					end
					ministat = [b.attack,b.spatk].max
					minimini = [user.attack,user.spatk].max
					ministat-=minimini
					ministat+=100
					ministat/=100.0
					score*=ministat
					if b.hp==0
						score=1
					end
				end
			end
    #---------------------------------------------------------------------------
    when "StartSlowerBattlersActFirst" # trick room
			count = -1
			sweepvar = false
			@battle.pbParty(user.index).each do |i|
				next if i.nil?
				count+=1
				temproles = pbGetPokemonRole(i, target, count, @battle.pbParty(user.index))
				if temproles.include?("Sweeper")
					sweepvar = true
				end
			end
			if !sweepvar
				score*=1.3
			end
			roles = pbGetPokemonRole(user, target)
			if roles.include?("Tank") || roles.include?("Physical Wall") || roles.include?("Special Wall")
				score*=1.3
			end
			if roles.include?("Lead")
				score*=1.5
			end
			hasAlly = !target.allAllies.empty?
			if hasAlly
				score*=1.3
			end
			if user.hasActiveAbility?(:TRICKSTER)
				score*=1.4
			end
			if user.hasActiveItem?(:FOCUSSASH)
				score*=1.5
			end
			if user.pbSpeed < pbRoughStat(target, :SPEED, skill) || user.hasActiveItem?(:IRONBALL)
				if @battle.field.effects[PBEffects::TrickRoom] > 0         
					score*=0
				else
					score*=2
				end
			else
				if @battle.field.effects[PBEffects::TrickRoom] > 0 && @battle.field.effects[PBEffects::TrickRoom] < 100
					score*=1.3
				else
					score*=0
				end
			end
    #---------------------------------------------------------------------------
    when "HigherPriorityInGrassyTerrain"
      if skill >= PBTrainerAI.mediumSkill && @battle.field.terrain == :Grassy
        aspeed = pbRoughStat(user, :SPEED, skill)
        ospeed = pbRoughStat(target, :SPEED, skill)
        score += 40 if aspeed < ospeed
      end
    #---------------------------------------------------------------------------
    when "LowerPPOfTargetLastMoveBy4", "LowerPPOfTargetLastMoveBy3" # Spite, eerie spell
			count=0
			for i in target.moves
				if i.baseDamage>0
					count+=1
				end
			end   
			lastmove = target.pbGetMoveWithID(target.lastRegularMoveUsed)
			if target.lastRegularMoveUsed
				if lastmove.baseDamage>0 && count==1
					score+=10
				end
			end
			if (user.pbSpeed < pbRoughStat(target, :SPEED, skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
				score*=0.5
			end
			if target.lastRegularMoveUsed
				if lastmove.total_pp > 0
					if lastmove.total_pp==5
						score*=1.5
					else
						if lastmove.total_pp==10
							score*=1.2
						else
							score*=0.7
						end          
					end
				end
			end
    #---------------------------------------------------------------------------
    when "DisableTargetLastMoveUsed" # Disable
			if target.lastRegularMoveUsed
				olddata = Pokemon::Move.new(target.lastRegularMoveUsed)
				oldmove = Battle::Move.from_pokemon_move(@battle, olddata)
			end
			maxdam = 0
			moveid = -1
			auroma = false
			target.allAllies.each do |b|
				next if !b.hasActiveAbility?(:AROMAVEIL)
				auroma = true
			end
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				if tempdam>maxdam
					maxdam = tempdam
					moveid = m.id
				end
			end
			if (target.effects[PBEffects::Disable]>0 || auroma) && move.baseDamage == 0
				score=0
			else
				if ((user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)) || 
						(user.hasActiveAbility?(:PRANKSTER) && !target.pbHasType?(:DARK))
					score*=1.2
				else
					score*=0.3
				end
				if target.lastRegularMoveUsed
					if oldmove.baseDamage>0
						score*=1.5
						if moveid == oldmove.id
							score*=1.3
							if maxdam*3<user.totalhp
								score*=1.5
							end
						end
					else
						score*=0.5
					end
				end
			end
    #---------------------------------------------------------------------------
    when "DisableTargetUsingSameMoveConsecutively" # torment
			if target.lastRegularMoveUsed
				olddata = Pokemon::Move.new(target.lastRegularMoveUsed)
				oldmove = Battle::Move.from_pokemon_move(@battle, olddata)
			end
			maxdam = 0
			moveid = -1
			auroma = false
			target.allAllies.each do |b|
				next if !b.hasActiveAbility?(:AROMAVEIL)
				auroma = true
			end
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				if tempdam>maxdam
					maxdam = tempdam
					moveid = m.id
				end
			end
			if (target.effects[PBEffects::Torment] || auroma) && move.baseDamage == 0
				score=0
			else
				if ((user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)) || 
						(user.hasActiveAbility?(:PRANKSTER) && !target.pbHasType?(:DARK))
					score*=1.2
				else
					score*=0.7
				end
				if target.lastRegularMoveUsed
					if oldmove.baseDamage>0
						score*=1.5
						if moveid == oldmove.id
							score*=1.3
							if maxdam*3<user.totalhp
								score*=1.5
							end
						end
						if user.pbHasMove?(:PROTECT)
							score*=1.5
						end
						if user.hasActiveItem?(:LEFTOVERS)
							score*=1.3
						end
					else
						score*=0.5
					end
				end
			end
    #---------------------------------------------------------------------------
    when "DisableTargetUsingDifferentMove" # encore
			#~ oldmove = GameData::Move.get(target.lastRegularMoveUsed)
			if target.lastRegularMoveUsed
				olddata = Pokemon::Move.new(target.lastRegularMoveUsed)
				oldmove = Battle::Move.from_pokemon_move(@battle, olddata)
			end
			auroma = false
			target.allAllies.each do |b|
				next if !b.hasActiveAbility?(:AROMAVEIL)
				auroma = true
			end
			if (target.effects[PBEffects::Encore]>0 || auroma) && move.baseDamage == 0
				score=0
			else
				if target.lastRegularMoveUsed
					score*=0.2
				else
					if (user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
						score*=1.5
					else
						if (user.hasActiveAbility?(:PRANKSTER) && !target.pbHasType?(:DARK))
							score*=2
						else              
							score*=0.2
						end            
					end
					if !oldmove.nil?
						if oldmove.baseDamage>0 && pbRoughDamage(oldmove, user, target, skill, oldmove.baseDamage)*5>user.hp
							score*=0.3
						else
							if target.stages[:SPEED]>0
								if (target.pbHasType?(:DARK) || !user.hasActiveAbility?(:PRANKSTER)) || 
										target.hasActiveAbility?(:SPEEDBOOST)
									score*=0.5
								else
									score*=2
								end
							else
								score*=2
							end            
						end
					end
				end 
			end
    #---------------------------------------------------------------------------
    when "DisableTargetStatusMoves" # taunt
			auroma = false
			target.allAllies.each do |b|
				next if !b.hasActiveAbility?(:AROMAVEIL)
				auroma = true
			end
			if (target.effects[PBEffects::Taunt]>0 || auroma) && move.baseDamage == 0
				score=0
			else
				if ((user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)) || 
						(user.hasActiveAbility?(:PRANKSTER) && !target.pbHasType?(:DARK))
					score*=1.5
				else
					score*=0.7
				end
				if target.turnCount<=1
					score*=1.1
				else
					score*=0.9
				end  
				score*=1.3 if pbHasSingleTargetProtectMove?(target)
				for m in target.moves
					score*=1.3 if m.healingMove?
				end
				hasAlly = !target.allAllies.empty?
				if hasAlly
					score *= 0.6
				end
			end
    #---------------------------------------------------------------------------
    when "DisableTargetHealingMoves" # heal block
      score -= 90 if target.effects[PBEffects::HealBlock] > 0
			auroma = false
			target.allAllies.each do |b|
				next if !b.hasActiveAbility?(:AROMAVEIL)
				auroma = true
			end
			if (target.effects[PBEffects::HealBlock]>0 || auroma) && move.baseDamage == 0
				score=0
			else
				if ((user.pbSpeed>pbRoughStat(target,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)) || 
						(user.hasActiveAbility?(:PRANKSTER) && !target.pbHasType?(:DARK))
					score*=1.5
				end
				for m in target.moves
					score*=2.5 if m.healingMove?
				end
				if target.hasActiveItem?(:LEFTOVERS)
					score*=1.3
				end
			end
    #---------------------------------------------------------------------------
    when "DisableTargetSoundMoves" # Throat Chop
			maxdam = 0
			maxsound = false
			soundcheck = false
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				if tempdam > maxdam
					maxdam = tempdam 
					maxsound = m.soundMove?
				end
				soundcheck = true if m.soundMove?
			end
			if maxsound 
				score*=1.5
			else
				if soundcheck
					score*=1.3
				end
			end
    #---------------------------------------------------------------------------
    when "DisableTargetMovesKnownByUser" # Imprison
			if user.effects[PBEffects::Imprison]
				score*=0
			else
				miniscore=1
				ourmoves = []
				if user.lastRegularMoveUsed
					olddata = Pokemon::Move.new(user.lastRegularMoveUsed)
					oldmove = Battle::Move.from_pokemon_move(@battle, olddata)
				end
				for m in user.moves
					ourmoves.push(m.id) unless m.nil?
				end
				for m in target.moves
					if ourmoves.include?(m.id)
						miniscore+=1
						score*=1.5 if m.healingMove?
						score*=1.6 if m.id == :TRICKROOM
					else
						score = 0
					end
				end
				score*=miniscore
			end
    #---------------------------------------------------------------------------
    when "AllBattlersLoseHalfHPUserSkipsNextTurn"
      score += 20   # Shadow moves are more preferable
      score += 20 if target.hp >= target.totalhp / 2
      score -= 20 if user.hp < user.hp / 2
    #---------------------------------------------------------------------------
    when "UserLosesHalfHP"
      score += 20   # Shadow moves are more preferable
      score -= 40
    #---------------------------------------------------------------------------
    when "StartShadowSkyWeather"
      score += 20   # Shadow moves are more preferable
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
         @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.field.weather == :ShadowSky
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "RemoveAllScreens"
      score += 20   # Shadow moves are more preferable
      if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0 ||
         target.pbOwnSide.effects[PBEffects::Reflect] > 0 ||
         target.pbOwnSide.effects[PBEffects::LightScreen] > 0 ||
         target.pbOwnSide.effects[PBEffects::Safeguard] > 0
        score += 30
        score -= 90 if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0 ||
                       user.pbOwnSide.effects[PBEffects::Reflect] > 0 ||
                       user.pbOwnSide.effects[PBEffects::LightScreen] > 0 ||
                       user.pbOwnSide.effects[PBEffects::Safeguard] > 0
      else
        score -= 110
      end
    #---------------------------------------------------------------------------
    else
      return aiEffectScorePart2_pbGetMoveScoreFunctionCode(score, move, user, target, skill)
    end
    return score
  end
end
