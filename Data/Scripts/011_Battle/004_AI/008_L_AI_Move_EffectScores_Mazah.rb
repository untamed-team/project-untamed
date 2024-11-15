class Battle::AI
  #=============================================================================
  # Get a score for the given move based on its effect
  #=============================================================================
  alias aiEffectScorePart3_pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode

  def pbGetMoveScoreFunctionCode(score, move, user, target, skill = 100)
	mold_broken = moldbroken(user,target,move)
	globalArray = pbGetMidTurnGlobalChanges
	procGlobalArray = processGlobalArray(globalArray)
	expectedWeather = procGlobalArray[0]
	expectedTerrain = procGlobalArray[1]
	aspeed = pbRoughStat(user,:SPEED,skill)
	ospeed = pbRoughStat(target,:SPEED,skill)
	userFasterThanTarget = ((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
    case move.function
    #---------------------------------------------------------------------------
    when "ProtectUser" # Protect, Detect
		if user.effects[PBEffects::ProtectRate] > 1
			score = 0
		else
			score*=1.3 if globalArray.any? { |element| element.include?("weather") }
			if target.turnCount==0
				score*=1.5
			end
			if user.hasActiveAbility?(:SPEEDBOOST) && !userFasterThanTarget
				score*=4
			end
			if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true)) || 
			   user.effects[PBEffects::Ingrain] || user.effects[PBEffects::AquaRing] || 
			   expectedTerrain == :Grassy
				score*=1.2
			end
			if user.poisoned? || user.burned? || user.frozen?
				score*=0.8
				if user.effects[PBEffects::Toxic]>0
					score*=0.3
				end
			end   
			if target.effects[PBEffects::LeechSeed]>=0
				score*=1.3
			end
			if target.effects[PBEffects::PerishSong]!=0
				score*=2
			end
			if target.asleep?
				score*=0.3
			end
			score*=0.1 if target.moves.any? { |m| ["HoopaRemoveProtectionsBypassSubstituteLowerUserDef1", 
													"RemoveProtectionsBypassSubstitute", 
													"RemoveProtections"].includes?(m&.id) }
			if user.effects[PBEffects::Wish]>0
				bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
				maxdam=bestmove[0]
				if maxdam>user.hp
					score*=3
				else
					score*=1.4
				end
			end
			if !user.pbHasAnyStatus?
				score*=0.7 if target.moves.any? { |j| [:WILLOWISP, :THUNDERWAVE, :TOXIC, :BITINGCOLD, :CONFUSERAY].include?(j&.id) }
			end
			if targetWillMove?(target)
				targetMove = @battle.choices[target.index][2]
				if targetMove.statusMove?
					score *= 1.1
					score *= 0.3 if pbHasSetupMove?(target, false)
				else
					if !targetSurvivesMove(targetMove,target,user)
						score *= 5.0
					else
						expectedDmg = pbRoughDamage(targetMove,target,user,100,targetMove.baseDamage)
						expectedPrcnt = expectedDmg * 100.0 / user.hp
						score *= (expectedPrcnt * 0.05)
					end
				end
			end
		end
    #---------------------------------------------------------------------------
    when "ProtectUserBanefulBunker", "ProtectUserFromTargetingMovesSpikyShield" 
		# Baneful Bunker, Spiky Shield
		if user.effects[PBEffects::ProtectRate] > 1
			score = 0
		else
			contactcheck = target.moves.any? { |m| m&.pbContactMove?(target) }
			score*=1.3 if globalArray.any? { |element| element.include?("weather") }
			if target.turnCount==0
				score*=1.5
			end
			if user.hasActiveAbility?(:SPEEDBOOST) && !userFasterThanTarget
				score*=4
			end
			if user.hasActiveItem?(:LEFTOVERS) || 
			   (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true)) || 
			   user.effects[PBEffects::Ingrain] || user.effects[PBEffects::AquaRing] || 
			   expectedTerrain == :Grassy
				score*=1.2
			end  
			if move.function == "ProtectUserBanefulBunker"
				if target.pbHasAnyStatus?
					score*=0.8
				else
					if target.pbCanPoison?(user, false) && contactcheck
						miniscore = pbTargetBenefitsFromStatus?(user, target, :POISON, 90, move, globalArray, 100)
						miniscore/=100.0
						score*=miniscore
					end
				end
			end
			if user.poisoned? || user.burned? || user.frozen?
				score*=0.8
				if user.effects[PBEffects::Toxic]>0
					score*=0.3
				end
			end   
			if target.effects[PBEffects::LeechSeed]>=0
				score*=1.3
			end
			if target.effects[PBEffects::PerishSong]!=0
				score*=2
			end
			if target.asleep?
				score*=0.3
			end
			movecheck=target.moves.any? { |m| m&.ignoresSubstitute?(target) }
			movecheck=true if target.moves.any? { |m| ["HoopaRemoveProtectionsBypassSubstituteLowerUserDef1", 
														"RemoveProtectionsBypassSubstitute", 
														"RemoveProtections"].includes?(m&.id) }
			score*=0.1 if movecheck
			if user.effects[PBEffects::Wish]>0
				bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
				maxdam=bestmove[0]
				if maxdam>user.hp
					score*=3
				else
					score*=1.4
				end
			end  
			if contactcheck
				score*=1.3
			end
			if pbRoughStat(target,:ATTACK,skill)>pbRoughStat(target,:SPECIAL_ATTACK,skill)
				score*=1.5
			end
			if !user.pbHasAnyStatus?
				score*=0.7 if target.moves.any? { |j| [:WILLOWISP, :THUNDERWAVE, :TOXIC, :BITINGCOLD, :CONFUSERAY].include?(j&.id) }
			end
			if targetWillMove?(target)
				targetMove = @battle.choices[target.index][2]
				if targetMove.statusMove?
					score *= 1.1
					score *= 0.3 if pbHasSetupMove?(target, false)
				else
					if !targetSurvivesMove(targetMove,target,user)
						score *= 5.0
					else
						expectedDmg = pbRoughDamage(targetMove,target,user,100,targetMove.baseDamage)
						expectedPrcnt = expectedDmg * 100.0 / user.hp
						score *= (expectedPrcnt * 0.05)
					end
					score *= 1.5 if targetMove.pbContactMove?(user)
				end
			end
		end
    #---------------------------------------------------------------------------
    when "ProtectUserFromDamagingMovesKingsShield",
		 "ProtectUserFromDamagingMovesObstruct"
		# King's Shield, Obstruct
		if user.effects[PBEffects::ProtectRate] > 1
			score = 0
		else
			if target.turnCount==0
				score*=1.5
			end        
			if user.hasActiveAbility?(:SPEEDBOOST) && 
			   aspeed > ospeed && @battle.field.effects[PBEffects::TrickRoom]==0
				score*=4
			end
			if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true)) || 
			   user.effects[PBEffects::Ingrain] || user.effects[PBEffects::AquaRing] || 
			   expectedTerrain == :Grassy
				score*=1.2
			end  
			if target.poisoned? || target.burned? || target.frozen?
				score*=1.2
				if target.effects[PBEffects::Toxic]>0
					score*=1.3
				end
			end
			if user.poisoned? || user.burned? || user.frozen?
				score*=0.8
				if user.effects[PBEffects::Toxic]>0
					score*=0.3
				end
			end   
			if target.effects[PBEffects::LeechSeed]>=0
				score*=1.3
			end
			if target.effects[PBEffects::PerishSong]!=0
				score*=2
			end
			if target.asleep?
				score*=0.3
			end
			if move.function == "ProtectUserFromDamagingMovesKingsShield"
				if user.isSpecies?(:AEGISLASH) && user.form == 1
					if userFasterThanTarget
						bestmove=bestMoveVsTarget(user,target,skill) # [maxdam,maxmove,maxprio,physorspec]
						maxmove = bestmove[1]
						if targetSurvivesMove(maxmove,user,target)
							score*=1.2
						else
							score*=0.8
						end
					else
						score*=4
					end
				end
			end
			movecheck=target.moves.any? { |m| m&.ignoresSubstitute?(target) }
			movecheck=true if target.moves.any? { |m| ["HoopaRemoveProtectionsBypassSubstituteLowerUserDef1", 
														"RemoveProtectionsBypassSubstitute", 
														"RemoveProtections"].includes?(m&.id) }
			score*=0.1 if movecheck
			score*=1.3 if target.moves.any? { |m| m&.pbContactMove?(target) }
			if user.effects[PBEffects::Wish]>0
				bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
				maxdam = bestmove[0]
				if maxdam>user.hp
					score*=3
				else
					score*=1.4
				end
			end
			if pbRoughStat(target,:ATTACK,skill)>pbRoughStat(target,:SPECIAL_ATTACK,skill)
				score*=1.5
			end
			if !user.pbHasAnyStatus?
				score*=0.7 if target.moves.any? { |j| [:WILLOWISP, :THUNDERWAVE, :TOXIC, :BITINGCOLD, :CONFUSERAY].include?(j&.id) }
			end
			if targetWillMove?(target)
				targetMove = @battle.choices[target.index][2]
				if targetMove.statusMove?
					score *= 0.3
					score *= 0.3 if pbHasSetupMove?(target, false)
				else
					if !targetSurvivesMove(targetMove,target,user)
						score *= 5.0
					else
						expectedDmg = pbRoughDamage(targetMove,target,user,100,targetMove.baseDamage)
						expectedPrcnt = expectedDmg * 100.0 / user.hp
						score *= (expectedPrcnt * 0.05)
					end
					score *= 1.5 if targetMove.pbContactMove?(user)
				end
			end
		end
    #---------------------------------------------------------------------------
    when "ProtectUserSideFromDamagingMovesIfUserFirstTurn" # mat block
     	if user.turnCount == 0
			hasAlly = !user.allAllies.empty?
			if hasAlly
				healcheck = target.moves.any? { |m| m&.healingMove? }
				setupcheck = pbHasSetupMove?(target, false)
				score*=1.3
				if userFasterThanTarget
					score*=1.2
				else
					score*=0.7
				end
				if setupcheck && healcheck
					score*=0.3
				end
				if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true)) || 
				   user.effects[PBEffects::Ingrain] || user.effects[PBEffects::AquaRing] || 
				   expectedTerrain == :Grassy
					score*=1.2
				end  
				if target.poisoned? || target.burned? || target.frozen?
					score*=1.2
					if target.effects[PBEffects::Toxic]>0
						score*=1.3
					end
				end
				if user.poisoned? || user.burned? || user.frozen? 
					score*=0.8
					if user.effects[PBEffects::Toxic]>0
						score*=0.3
					end
				end   
				if target.effects[PBEffects::LeechSeed]>=0
					score*=1.3
				end
				if target.effects[PBEffects::PerishSong]!=0
					score*=2
				end
				if target.asleep?
					score*=0.3
				end
				if user.effects[PBEffects::Wish]>0
					score*=1.3
				end
			end
		else
			score = 0
		end
		score = 0 if user.effects[PBEffects::ProtectRate] > 1
    #---------------------------------------------------------------------------
    when "ProtectUserSideFromStatusMoves" # crafty shield
		if target.moves.none? { |m| m.baseDamage > 0 }
			score *= 1.2
		end
		if user.hp==user.totalhp
			score *= 1.5
		end  
		if pbHasPhazingMove?(target)
			score *= 1.3
		end
		hasAlly = !user.allAllies.empty?
		if hasAlly
			score *= 1.2
		else
			score *= 0.8
		end
		if targetWillMove?(target, "status")
			target_data = @battle.choices[target.index][2].pbTarget(target)
			if [:User, :UserSide, :UserAndAllies, :AllAllies, :FoeSide].include?(target_data.id)
				score *= 0.4
			else
				score *= 2.5
			end
		else
			score*=0.2
			score*=0.5 if user.lastMoveUsed == :CRAFTYSHIELD
		end
    #---------------------------------------------------------------------------
    when "ProtectUserSideFromPriorityMoves" # Quick Guard
		if user.effects[PBEffects::ProtectRate] > 1
			score = 0
		else
			if target.moves.none? { |m| priorityAI(target,m) > 0 }
				score *= 0.5
			else
				score *= 1.2
			end
			if user.allAllies.empty?
				score *= 0.8
			end
			if user.hp==user.totalhp
				score *= 1.5
			end
			if targetWillMove?(target)
				targetMove = @battle.choices[target.index][2]
				if priorityAI(target,targetMove) > 0
					score *= 2.0 
					if targetMove.statusMove?
						score *= 1.1
					else
						if !targetSurvivesMove(targetMove,target,user)
							score *= 5.0
						else
							expectedDmg = pbRoughDamage(targetMove,target,user,100,targetMove.baseDamage)
							expectedPrcnt = expectedDmg * 100.0 / user.hp
							score *= (expectedPrcnt * 0.05)
						end
					end
				else
					score *= 0.6
				end
			end
		end
    #---------------------------------------------------------------------------
    when "ProtectUserSideFromMultiTargetDamagingMoves" # Wide Guard
		if user.effects[PBEffects::ProtectRate] > 1
			score = 0
		else
			if target.moves.none? { |m| pbTargetsMultiple?(m, target) }
				score *= 0.5
			else
				score *= 1.2
			end
			if user.hp==user.totalhp
				score *= 1.5
			end
			if targetWillMove?(target)
				targetMove = @battle.choices[target.index][2]
				if pbTargetsMultiple?(targetMove, target)
					score *= 2.0 
					if targetMove.statusMove?
						score *= 0.5
					else
						if !targetSurvivesMove(targetMove,target,user)
							score *= 5.0
						else
							expectedDmg = pbRoughDamage(targetMove,target,user,100,targetMove.baseDamage)
							expectedPrcnt = expectedDmg * 100.0 / user.hp
							score *= (expectedPrcnt * 0.05)
						end
					end
				else
					score *= 0.6
				end
			end
		end
    #------------------------------------------------------------------------------------------------------------------------------------------------------
	# Actual Untamed exclusive moves
    #------------------------------------------------------------------------------------------------------------------------------------------------------
	when "UseUserBaseSpecialDefenseInsteadOfUserBaseSpecialAttack" # Psycrush
    #---------------------------------------------------------------------------
	when "TitanWrath" # Titan's Wrath
    #---------------------------------------------------------------------------
	when "Rebalancing" # Rebalancing
		if target.effects[PBEffects::Substitute]>0
			score = 0
		else
			targetStats = target.plainStats
			highestStatValue = highestStatID = 0
			targetStats.each_value { |value| highestStatValue = value if highestStatValue < value }
			GameData::Stat.each_main_battle do |s|
				next if targetStats[s.id] < highestStatValue
				highestStatID = s.id
				break
			end
			miniscore=100
			if user.opposes?(target) # is enemy
				miniscore*=1.2
				livecountuser 	 = @battle.pbAbleNonActiveCount(user.idxOwnSide)
				livecounttarget  = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
				case highestStatID
				when :ATTACK
					roles = pbGetPokemonRole(user, target)
					if roles.include?("Physical Wall") || roles.include?("Special Wall")
						miniscore*=1.3
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
						miniscore*=1.1
					end
					if livecounttarget==0 || user.hasActiveAbility?([:SHADOWTAG, :ARENATRAP]) || target.effects[PBEffects::MeanLook]>0
						miniscore*=1.4
					end
					if target.poisoned? || target.frozen?
						miniscore*=1.2
					end
					if target.stages[:ATTACK]!=0
						minimini = 5*target.stages[:ATTACK]
						minimini *= 1.1 if move.baseDamage==0
						minimini+=100
						minimini/=100.0
						miniscore*=minimini
					end
					if user.pbHasMove?(:FOULPLAY)
						miniscore*=0.5
					end  
					if target.burned? && !target.hasActiveAbility?(:GUTS)
						miniscore*=0.5
					end       
					if livecountuser==1
						miniscore*=0.5
					end
					miniscore=0 if !target.pbCanLowerStatStage?(:ATTACK)
				when :DEFENSE
					miniscore*=1.5 if target.moves.any? { |m| m&.healingMove? }
					if livecounttarget==0 || user.hasActiveAbility?([:SHADOWTAG, :ARENATRAP]) || target.effects[PBEffects::MeanLook]>0
						miniscore*=1.4
					end
					if target.poisoned? || target.burned? || target.frozen?
						miniscore*=1.2
					end
					if target.stages[:DEFENSE]!=0
						minimini = 5*target.stages[:DEFENSE]
						minimini *= 1.1 if move.baseDamage==0
						minimini+=100
						minimini/=100.0
						miniscore*=minimini
					end
					if user.burned?
						miniscore*=0.7
					end
					if livecountuser==1
						miniscore*=0.5
					end
					if user.pbHasAnyStatus?
						miniscore*=0.7
					end
					miniscore=0 if !target.pbCanLowerStatStage?(:DEFENSE)
				when :SPEED
					if livecounttarget==0 || user.hasActiveAbility?([:SHADOWTAG, :ARENATRAP]) || target.effects[PBEffects::MeanLook]>0
						miniscore*=1.3
					end
					if target.stages[:SPEED]!=0
						minimini = 5*target.stages[:SPEED]
						minimini *= 1.1 if move.baseDamage==0
						minimini+=100
						minimini/=100.0
						miniscore*=minimini
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
					if target.hasActiveItem?([:LAGGINGTAIL, :IRONBALL])
						miniscore*=0.1
					end
					miniscore*=1.3 if target.moves.any? { |j| j&.id == :ELECTROBALL }
					miniscore*=0.5 if target.moves.any? { |j| j&.id == :GYROBALL }
					miniscore=0 if !target.pbCanLowerStatStage?(:SPEED)
				when :SPECIAL_ATTACK
					roles = pbGetPokemonRole(user, target)
					if roles.include?("Physical Wall") || roles.include?("Special Wall")
						miniscore*=1.3
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
						miniscore*=1.1
					end
					if livecounttarget==0 || user.hasActiveAbility?([:SHADOWTAG, :ARENATRAP]) || target.effects[PBEffects::MeanLook]>0
						miniscore*=1.4
					end
					if target.poisoned? || target.burned? || target.frozen?
						miniscore*=1.2
					end
					if target.stages[:SPECIAL_ATTACK]!=0
						minimini = 5*target.stages[:SPECIAL_ATTACK]
						minimini *= 1.1 if move.baseDamage==0
						minimini+=100
						minimini/=100.0
						miniscore*=minimini
					end
					if livecountuser==1
						miniscore*=0.5
					end
					miniscore=0 if !target.pbCanLowerStatStage?(:SPECIAL_ATTACK)
				when :SPECIAL_DEFENSE
					miniscore*=1.3 if target.moves.any? { |m| m&.healingMove? }
					if livecounttarget==0 || user.hasActiveAbility?([:SHADOWTAG, :ARENATRAP]) || target.effects[PBEffects::MeanLook]>0
						miniscore*=1.4
					end
					if target.poisoned? || target.burned? || target.frozen?
						miniscore*=1.2
					end
					if target.stages[:SPECIAL_DEFENSE]!=0
						minimini = 5*target.stages[:SPECIAL_DEFENSE]
						minimini *= 1.1 if move.baseDamage==0
						minimini+=100
						minimini/=100.0
						miniscore*=minimini
					end
					if user.frozen?
						miniscore*=0.5
					end
					if livecountuser==1
						miniscore*=0.5
					end
					if user.pbHasAnyStatus?
						miniscore*=0.9
					end
					miniscore=0 if !target.pbCanLowerStatStage?(:SPECIAL_DEFENSE)
				end
				if target.hasActiveAbility?([:COMPETITIVE, :DEFIANT, :CONTRARY])
					miniscore*=0.1
				end
				if target.hasActiveAbility?(:UNAWARE) && highestStatID != :SPEED
					miniscore*=0.1
				end
			else                     # is ally
				miniscore*=-1 # neg due to being ally
				if !target.SetupMovesUsed.include?(move.id)
					if (1.0/target.totalhp)*target.hp < 0.6
						miniscore*=0.3
					end
					if target.paralyzed? || target.asleep? || 
					   target.effects[PBEffects::Yawn]>0
						miniscore*=0.3
					end
					enemy1 = user.pbDirectOpposing
					enemy2 = enemy1.allAllies.first
					e1sped = pbRoughStat(enemy1,:SPEED,skill)
					e2sped = pbRoughStat(enemy2,:SPEED,skill)
					if ospeed > e1sped && ospeed > e2sped
						miniscore*=1.3
					else
						if highestStatID == :SPEED
							ospeed2 = ospeed * (3.0 / 2.0)
							if ospeed2 > e1sped && ospeed2 > e2sped
								miniscore*=1.3
							else
								miniscore*=0.7
							end
						else
							miniscore*=0.7
						end
					end
					if (enemy1.pbHasMove?(:FOULPLAY) || enemy2.pbHasMove?(:FOULPLAY)) &&
					   highestStatID == :ATTACK
						miniscore*=0.3
					end
				else
					miniscore = 0
				end
			end
			miniscore/=100.0
			score*=miniscore
		end
    #---------------------------------------------------------------------------
	when "HigherDamageInRain" # Steam Burst (not properly implemented)
		if @battle.pbCheckGlobalAbility(:AIRLOCK) || @battle.pbCheckGlobalAbility(:CLOUDNINE)
			score *= 0.7
		elsif user.hasActiveAbility?(:PRESAGE)
			score *= 1.3
		elsif @battle.field.weather != :Rain
			score *= 0.7
		else
			score *= 1.3
		end
    #---------------------------------------------------------------------------
	when "OverrideTargetStatusWithPoison" # Crimson Surge
		if $game_variables[MECHANICSVAR] >= 2 && target.status == :NONE
			score *= 0.3
		elsif target.asleep? && target.statusCount <= 2
			score = 0
		elsif target.pbCanInflictStatus?(:POISON, user, false, self, true)
			miniscore = pbTargetBenefitsFromStatus?(user, target, :POISON, 90, move, globalArray, skill)
			score *= (miniscore / 100.0)
			score *= 1.2 if user.hasActiveAbility?(:MERCILESS)
			score *= 1.2 if (target.hasActiveAbility?(:GUTS) && target.burned?) || target.hasActiveAbility?(:FLAREBOOST)
			score *= 0.6 if target.hasActiveAbility?(:SYNCHRONIZE) && target.pbCanPoisonSynchronize?(user)
			score = 0 if (target.hasActiveAbility?(:POISONHEAL) || target.hasActiveAbility?(:TOXICBOOST)) && !target.poisoned?
		else
			score *= 0.8
		end
    #---------------------------------------------------------------------------
	when "DoubleDamageIfTargetHasChoiceItem" # Unused
		if !target.unlosableItem?(target.item) && !target.hasActiveAbility?(:STICKYHOLD)
			if [:CHOICEBAND, :CHOICESPECS, :CHOICESCARF].include?(target.initialItem)
				score *= 1.3
				score *= 1.4 if aspeed <= ospeed && target.hasActiveItem?(:CHOICESCARF)
			end
		end
	#---------------------------------------------------------------------------
	when "PeperSpray" # Pepper Spray
		score *= 1.4 if [:Sun, :HarshSun].include?(expectedWeather) && !user.hasActiveItem?(:UTILITYUMBRELLA)
    #---------------------------------------------------------------------------
	when "BOOMInstall" # BOOM! BOOM!!! BOOM!!!!!
		if target.effects[PBEffects::BoomInstalled]
			score = 0 if move.baseDamage == 0
		else
			targetpercent = (target.hp * 100.0 / target.totalhp)
			if targetpercent > 70
				score *= 1 + ((targetpercent - 70) / 100)
			else
				score *= targetpercent / 100
			end

			score *= 1.1 if target.stages[:DEFENSE] > 0 && user.moves.any? { |j| j&.physicalMove?(j&.type) }
			score *= 1.1 if target.stages[:SPECIAL_DEFENSE] > 0 && user.moves.any? { |j| j&.specialMove?(j&.type) }
			score *= 1.2 if target.moves.any? { |m| m&.healingMove? } 
			score *= 1.2 if target.trappedInBattle?
			if !user.allAllies.empty?
				roles = pbGetPokemonRole(user, target)
				score *= 1.2 if roles.include?("Lead")
				userAlly = user.allAllies.first
				roles = pbGetPokemonRole(userAlly, target)
				score *= 1.3 if roles.include?("Sweeper") || roles.include?("Stallbreaker")
			end
			if target.takesIndirectDamage?
				score *= 2.0 if @battle.pbCheckGlobalAbility(:STALL)
				score *= 1.3 if target.burned? || target.frozen? || target.poisoned?
				score *= 1.3 if user.pbHasMoveFunction?("BindTarget", "BindTargetDoublePowerIfTargetUnderwater") ||
								target.effects[PBEffects::Trapping] > 0
				score *= 1.3 if target.hasActiveItem?(:LIFEORB)
				score *= 1.3 if target.moves.any? { |j| j&.recoilMove? } && !target.hasActiveAbility?(:ROCKHEAD)
				if user.hasActiveAbility?([:ROUGHSKIN, :IRONBARBS])
					score *= 1.2 if target.moves.any? { |m| m&.pbContactMove?(user) }
				end
				if target.hasActiveAbility?(:SOLARPOWER) && [:Sun, :HarshSun].include?(expectedWeather)
					score *= 1.3
				end
				if (expectedWeather == :Hail && target.takesHailDamage?) || 
				   (expectedWeather == :Sandstorm && target.takesSandstormDamage?)
					score *= 1.3
				end
			end
		end
    #---------------------------------------------------------------------------
    else
    	return aiEffectScorePart3_pbGetMoveScoreFunctionCode(score, move, user, target, skill)
    end
    return score
  end
	
	# Utilities Check ############################################################
  	# ill let you know that this is longer than the actual effect score part of this page
	# it started so normal, how could i forsee me making this much coding?
	
	def pbHasSetupMove?(pokemon, countother = true)
		setuparray = ["RaiseUserAttack1", "RaiseUserDefense1", "RaiseUserSpeed1", "RaiseUserSpAtk1", "RaiseUserSpDef1",
					  "RaiseUserAttack2", "RaiseUserDefense2", "RaiseUserSpeed2", "RaiseUserSpAtk2", "RaiseUserSpDef2",
					  "RaiseUserAttack3", "RaiseUserDefense3", "RaiseUserSpeed3", "RaiseUserSpAtk3", "RaiseUserSpDef3",
					  "RaiseUserSpeed2LowerUserWeight", "RaiseUserAtk1Spd2", "RaiseUserSpAtkSpDefSpd1", 
					  "RaiseUserDefSpDef1", "RaiseUserAtkAcc1", "RaiseUserMainStats1LoseThirdOfTotalHP", 
					  "RaiseUserAtkSpd1", "RaiseUserSpDef1PowerUpElectricMove", "RaiseUserAtkDef1", 
					  "RaiseUserAndAlliesAtkDef1", "RaiseUserAtkSpAtk1", "RaiseUserDefense1CurlUpUser", 
					  "RaiseUserAtkSpAtk1Or2InSun", "RaiseUserMainStats1TrapUserInBattle", "RaiseUserAtkDefAcc1", 
					  "RaiseUserSpAtkSpDef1", "RaiseUserDefSpDef1", "RaiseUserAtkDefAcc1"]
		return true if movesetCheck(pokemon, setuparray, countother, true)
		return false	
	end
	
	def pbHasDebuffMove?(pokemon, countother = true)
		debuffarray = ["LowerTargetAttack1", "LowerTargetDefense1", "LowerTargetSpeed1", "LowerTargetSpAtk1", "LowerTargetSpDef1",
					   "LowerTargetAttack2", "LowerTargetDefense2", "LowerTargetSpeed2", "LowerTargetSpAtk2", "LowerTargetSpDef2",
					   "LowerTargetAttack3", "LowerTargetDefense3", "LowerTargetSpeed3", "LowerTargetSpAtk3", "LowerTargetSpDef3",
					   "LowerTargetEvasion1RemoveSideEffects", "LowerTargetAtkDef1", "LowerTargetSpAtk2IfCanAttract", 
					   "UserFaintsLowerTargetAtkSpAtk2", "LowerTargetAtkSpAtk1", "LowerPoisonedTargetAtkSpAtkSpd1"]
		return true if movesetCheck(pokemon, debuffarray, countother, true)
		return false
	end
	
	def pbHasSingleTargetProtectMove?(pokemon, countother = true) # should add unseen fist here somewhere but w/e
		if pokemon.is_a?(Battle::Battler) && countother
			return false if pokemon.effects[PBEffects::ProtectRate] > 1
		end
		protectarray = ["ProtectUser", "ProtectUserBanefulBunker", 
						"ProtectUserFromTargetingMovesSpikyShield", 
						"ProtectUserFromDamagingMovesKingsShield",
						"ProtectUserFromDamagingMovesObstruct"]
		return true if movesetCheck(pokemon, protectarray, countother)
		return false
	end
	
	def pbHasPivotMove?(pokemon, countother = true)
		pivotarray = ["SwitchOutUserDamagingMove", "SwitchOutUserStatusMove", 
						"LowerTargetAtkSpAtk1SwitchOutUser", "SwitchOutUserPassOnEffects"]
		return true if movesetCheck(pokemon, pivotarray, countother)
		return true if pokemon.ability == :REGENERATOR && countother
		return false
	end
	
	def pbHasPhazingMove?(pokemon, countother = true)
		phazearray = ["SwitchOutTargetStatusMove", "SwitchOutTargetDamagingMove", 
					  "SleepTargetNextTurn", "StartPerishCountsForAllBattlers"]
		return true if movesetCheck(pokemon, phazearray, countother)
		return true if pokemon.ability == :SLIPPERYPEEL && countother
		return true if pokemon.item_id == :REDCARD && countother
		return false
	end
	
	def pbHasHazardCleaningMove?(pokemon, countother = true)
		jannymarray = ["RemoveUserBindingAndEntryHazards", "LowerTargetEvasion1RemoveSideEffects"]
		return true if movesetCheck(pokemon, jannymarray, countother)
		return true if pokemon.ability == :TILEWORKER && countother
		return false
	end
	
	# movecateg array needs to be functions
	def movesetCheck(pokemon, movecateg, countother, addeffect = false)
		if pokemon.is_a?(Battle::Battler) # an active battler
			if addeffect
				pokemon.moves.each do |m|
					next unless movecateg.include?(m.function)
					return true if m.baseDamage == 0 || (m.addlEffect.to_f == 100 && countother)
				end
			else
				return true if pokemon.moves.any? { |m| movecateg.include?(m&.function) }
			end
		elsif pokemon.is_a?(Pokemon) # an inactive party member
			movelist = []
			pokemon.moves.each do |i|
				next if i.nil?
				movedummy = Pokemon::Move.new(i.id)
				movedummy = Battle::Move.from_pokemon_move(@battle, movedummy)
				movelist.push(movedummy)
			end
			if addeffect
				movelist.each do |m|
					next unless movecateg.include?(m.function)
					return true if m.baseDamage == 0 || (m.addlEffect.to_f == 100 && countother)
				end
			else
				return true if movelist.any? { |m| movecateg.include?(m&.function) }
			end
		end
		return false
	end

	##############################################################################

	def futureSightRoughDamage(user, target, skill)
		futureDmg = 0
		targetPosi = @battle.positions[target.index]
		if targetPosi.effects[PBEffects::FutureSightCounter] == 1
			futureMove = targetPosi.effects[PBEffects::FutureSightMove]
			return 0 if futureMove.nil?
			moveUser = sacrifice = nil
			@battle.allBattlers.each do |battler|
				next if battler.opposes?(targetPosi.effects[PBEffects::FutureSightUserIndex])
				sacrifice = battler
				next if battler.pokemonIndex != targetPosi.effects[PBEffects::FutureSightUserPartyIndex]
				moveUser = battler
				break
			end
			if moveUser.nil? # User isn't in battle, get it from the party
				party = @battle.pbParty(targetPosi.effects[PBEffects::FutureSightUserIndex])
				pkmn = party[targetPosi.effects[PBEffects::FutureSightUserPartyIndex]]
				moveUser = @battle.pbMakeFakeBattler(pkmn,false,sacrifice) if pkmn&.able?
			end
			return 0 if !moveUser
			futureUsableMove = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(futureMove))
			futureBaseDmg = pbMoveBaseDamage(futureUsableMove, user, moveUser, skill)
			futureRealDamage = pbRoughDamage(futureUsableMove, user, moveUser, skill, futureBaseDmg)
			futureRealDamage /= 2 if ![:DOOMDESIRE, :FUTURESIGHT].include?(futureMove)
			futureDmg = futureRealDamage if futureRealDamage > 0
		end
		return futureDmg
	end

	def targetWillMove?(target, action = "AG")
		if @battle.choices[target.index][0] == :UseMove
			if @battle.choices[target.index][1] # checking if there is a move index
				return true if @battle.choices[target.index][2].physicalMove? && action == "phys"
				return true if @battle.choices[target.index][2].specialMove? && action == "spec"
				return true if @battle.choices[target.index][2].statusMove? && action == "status"
				return true if action == "AG"
				return false
			end
		end
		return false
	end

	def pbTargetBenefitsFromStatus?(user, target, status, miniscore, move, globalArray = [], skill = 100)
		globalArray = pbGetMidTurnGlobalChanges if globalArray.empty?
		procGlobalArray = processGlobalArray(globalArray)
		expectedWeather = procGlobalArray[0]
		expectedTerrain = procGlobalArray[1]
		if target.affectedByTerrain?
			return 0 if expectedTerrain == :Misty
			return 0 if expectedTerrain == :Electric && status == :SLEEP
		end
		if !target.hasActiveItem?(:UTILITYUMBRELLA)
			if target.hasActiveAbility?(:HYDRATION) && [:Rain, :HeavyRain].include?(expectedWeather)
				miniscore*=0.2
			end
			if target.hasActiveAbility?(:LEAFGUARD) && [:Sun, :HarshSun].include?(expectedWeather)
				miniscore*=0.2
			end
		end
		miniscore*=0.2 if target.hasActiveAbility?(:GUTS) && !(status == :SLEEP && target.pbHasMoveFunction?("UseRandomUserMoveIfAsleep"))
		miniscore*=0.3 if target.hasActiveAbility?(:NATURALCURE)
		miniscore*=0.3 if target.hasActiveAbility?(:QUICKFEET) && status == :PARALYSIS
		miniscore*=0.5 if target.hasActiveAbility?(:MARVELSCALE)
		miniscore*=0.7 if target.hasActiveAbility?(:SHEDSKIN)
		miniscore*=0.4 if target.effects[PBEffects::Yawn]>0 && status != :SLEEP
		miniscore*=1.5 if target.effects[PBEffects::BoomInstalled] && [:BURN, :FREEZE, :POISON].include?(status)
		if target.effects[PBEffects::Confusion]>0
			miniscore *= (status == :SLEEP) ?  0.4 : 1.1
		end
		# trust me this works *and* makes sense
		facade = false
		facade = true if target.pbHasMoveFunction?("DoublePowerIfUserPoisonedBurnedParalyzed") && 
						!(status == :SLEEP && target.pbHasMoveFunction?("UseRandomUserMoveIfAsleep"))
		facade = true if target.pbHasMoveFunction?("HealUserFullyAndFallAsleep") && status != :SLEEP
		facade = false if status == :PARALYSIS && !target.hasActiveAbility?(:QUICKFEET)
		miniscore*=0.3 if facade
		if move.baseDamage>0 && status != :PARALYSIS
			if target.hasActiveAbility?(:STURDY)
				miniscore*=1.1
			end
		end
		miniscore*=1.4 if user.pbHasMoveFunction?("DoublePowerIfTargetStatusProblem")
		case status
		when :PARALYSIS
			if target.hasActiveAbility?(:SYNCHRONIZE) && target.pbCanParalyzeSynchronize?(user)
				miniscore*=0.5
			end
			if pbRoughStat(target, :SPEED, skill) > pbRoughStat(user,:SPEED,skill) && 
			  (pbRoughStat(target, :SPEED, skill)/2.0) < pbRoughStat(user,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom] <= 0
				miniscore*=1.5
			end
			miniscore*=0.5 if target.hasActiveItem?([:CHERIBERRY, :LUMBERRY])
		when :BURN
			if target.hasActiveAbility?(:SYNCHRONIZE) && target.pbCanBurnSynchronize?(user)
				miniscore*=0.5
			end
			if target.hasActiveAbility?([:GUTS, :FLAREBOOST])
				miniscore*=0.1
			end
			if target.effects[PBEffects::AquaRing]
				miniscore*=0.1
			end
			if pbRoughStat(target, :ATTACK, skill) > pbRoughStat(target, :SPECIAL_ATTACK, skill)
				miniscore*=1.7
			else
				miniscore*=0.8
				if target.hasActiveAbility?(:MAGICGUARD)
					miniscore*=0.2
				end
			end
			miniscore*=0.3 if target.hasActiveItem?([:RAWSTBERRY,:LUMBERRY])
		when :POISON
			if target.hasActiveAbility?(:SYNCHRONIZE) && target.pbCanPoisonSynchronize?(user)
				miniscore*=0.5
			end
			if target.hasActiveAbility?([:TOXICBOOST, :POISONHEAL, :MAGICGUARD])
				miniscore*=0.1
			end
			if user.hasActiveAbility?(:MERCILESS) || 
			   user.pbHasMoveFunction?("DoublePowerIfTargetPoisoned", "LowerPoisonedTargetAtkSpAtkSpd1")
				miniscore*=1.6
			end
			miniscore*=2 if target.moves.any? { |m| m&.healingMove? }
			if move.id == :TOXIC
				miniscore*=1.1 if user.pbHasType?(:POISON, true)
			end
			miniscore*=0.5 if target.hasActiveItem?([:PECHABERRY, :LUMBERRY])
		when :FREEZE
			if target.hasActiveAbility?(:SYNCHRONIZE) && target.pbCanFreezeSynchronize?(user)
				miniscore*=0.5
			end
			if pbRoughStat(target, :SPECIAL_ATTACK, skill) > pbRoughStat(target, :ATTACK, skill)
				miniscore*=1.7
			else
				miniscore*=0.8
				if target.hasActiveAbility?(:MAGICGUARD)
					miniscore*=0.2
				end
			end
			miniscore*=0.3 if target.hasActiveItem?([:ASPEARBERRY, :LUMBERRY])
		when :SLEEP
			miniscore*=1.3
			if user.pbHasMove?(:DREAMEATER) || user.pbHasMove?(:NIGHTMARE) || user.hasActiveAbility?(:BADDREAMS)
				miniscore*=1.5
			end
			if user.pbHasMove?(:LEECHSEED) || user.pbHasMove?(:SUBSTITUTE)
				miniscore*=1.3
			end
			if target.hp==target.totalhp
				miniscore*=1.2
			end
			if target.turnCount == 0 && !target.pbHasMoveFunction?("FlinchTargetFailsIfNotUserFirstTurn")
				miniscore*=1.2
			end
			if (pbRoughStat(target, :SPEED, skill) > pbRoughStat(user,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
				miniscore*=1.3
			end
			if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveAbility?(:POISONHEAL) && user.poisoned?)
				miniscore*=1.2
			end
			if pbHasSetupMove?(user, false)
				miniscore*=1.3
			end
			if pbHasSetupMove?(target, true)
				miniscore*=1.2
			end
			miniscore*=0.1 if target.moves.any? { |j| [:SLEEPTALK, :SNORE].include?(j&.id) }
			if move.powderMove? && !target.affectedByPowder?
				miniscore=0
			end
			if move.id == :DARKVOID && !user.isSpecies?(:DARKRAI)
				miniscore=0
			end
			miniscore*=0.7 if target.hasActiveItem?([:CHESTOBERRY, :LUMBERRY])
		when :DIZZY
			minimi = getAbilityDisruptScore(move,user,target,skill)
			if !user.opposes?(target) # is ally
				minimi = 1.0 / minimi 
				minimi *= 2 if target.hasActiveAbility?(:TANGLEDFEET)
				minimi *= 2 if target.hasActiveItem?([:PERSIMBERRY, :LUMBERRY]) && 
							   ["RaiseTargetSpAtk1ConfuseTarget", "RaiseTargetAttack2ConfuseTarget"].include?(move.function)
			else
				minimi *= 0.3 if target.hasActiveItem?([:PERSIMBERRY, :LUMBERRY])
				minimi = 0 if target.hasActiveAbility?(:TANGLEDFEET)
			end
			miniscore*=minimi
		end
		return miniscore
	end
	
	# Pokemon Roles System #######################################################
	
	def pbGetPokemonRole(pokemon, target, position = 0, party = nil)
		roles = []
		if pokemon.is_a?(Battle::Battler) # used for a single (active) pokemon
			if [:MODEST, :JOLLY, :TIMID, :ADAMANT].include?(pokemon.nature) || 
				 [:CHOICEBAND, :CHOICESPECS, :CHOICESCARF].include?(pokemon.item_id)
				roles.push("Sweeper")
			end
			healingmove = pokemon.moves.any? { |m| m&.healingMove? }
			if healingmove
				if [:BOLD, :RELAXED, :IMPISH, :LAX].include?(pokemon.nature)
					roles.push("Physical Wall")
				elsif [:CALM, :GENTLE, :SASSY, :CAREFUL].include?(pokemon.nature)
					roles.push("Special Wall")
				end
			else
				if pokemon.item_id == :ASSAULTVEST || pokemon.item_id == :MELEEVEST
					roles.push("Tank")
				end
			end
			if pokemon.pokemonIndex == 0
				roles.push("Lead")
			end
			if pokemon.pbHasMoveFunction?("CureUserPartyStatus", "HealUserPositionNextTurn")
				roles.push("Cleric")
			end
			if pbHasPhazingMove?(pokemon, false)
				roles.push("Phazer")
			end
			if pokemon.item_id == :LIGHTCLAY
				roles.push("Screener")
			end
			priorityko=false
			for zzz in pokemon.moves
				next if zzz.nil? || priorityAI(target,zzz)<1
				dam=pbRoughDamage(zzz, pokemon, target, 100, zzz.baseDamage)
				if target.hp>0
					percentage=(dam*100.0)/target.hp
					priorityko=true if percentage>100
				end
			end
			if priorityko #|| (pokemon.pbSpeed>target.pbSpeed)
				roles.push("Revenge Killer")
			end
			if pbHasPivotMove?(pokemon, false) && (healingmove || pokemon.ability == :REGENERATOR)
				roles.push("Pivot")
			end
			if pbHasHazardCleaningMove?(pokemon)
				roles.push("Spinner")
			end
			if pokemon.pbHasMoveFunction?("SwitchOutUserPassOnEffects")
				roles.push("Baton Passer")
			end
			if pokemon.pbHasMoveFunction?("DisableTargetStatusMoves") || 
				 [:CHOICEBAND, :CHOICESPECS].include?(pokemon.item_id)
				roles.push("Stallbreaker")
			end
			if pokemon.pbHasMoveFunction?("HealUserFullyAndFallAsleep") || 
				 [:TOXICORB, :FLAMEORB].include?(pokemon.item_id) ||
				 [:COMATOSE, :GUTS, :QUICKFEET, :FLAREBOOST, :TOXICBOOST, 
					:NATURALCURE, :MAGICGUARD, :MAGICBOUNCE].include?(pokemon.ability) ||
				 (pokemon.ability == :HYDRATION && [:HeavyRain, :Rain].include?(@battle.field.weather))
				roles.push("Status Absorber")
			end
			if [:SHADOWTAG, :ARENATRAP, :MAGNETPULL, :BAITEDLINE].include?(pokemon.ability)
				roles.push("Trapper")
			end
			if pokemon.pbHasMoveFunction?("StartSunWeather", "StartRainWeather", "StartSandstormWeather", "StartHailWeather") || 
				 [:DROUGHT, :DRIZZLE, :SANDSTREAM, :SNOWWARNING, 
				  :PRIMORDIALSEA, :DESOLATELAND, :DELTASTREAM, 
				  :FORECAST, :PRESAGE, :DUSTSENTINEL].include?(pokemon.ability) ||
				 (pokemon.ability == :FREEZEOVER && pokemon.item_id == :ICYROCK) ||
				 (pokemon.species == :ZARCOIL  && (pokemon.item_id == :ZARCOILITE || pokemon.hasMegaEvoMutation?)) ||
				 (pokemon.species == :ZOLUPINE && (pokemon.item_id == :ZOLUPINEITE || pokemon.hasMegaEvoMutation?)) ||
				 (pokemon.species == :CACTURNE && (pokemon.item_id == :CACTURNITE || pokemon.hasMegaEvoMutation?)) ||
				 (pokemon.species == :FRIZZARD && (pokemon.item_id == :FRIZZARDITE || pokemon.hasMegaEvoMutation?))
				roles.push("Weather Setter")
			end
			if pokemon.pbHasMoveFunction?("StartElectricTerrain", "StartGrassyTerrain", "StartMistyTerrain", "StartPsychicTerrain") || 
				 [:ELECTRICSURGE, :PSYCHICSURGE, :MISTYSURGE, :GRASSYSURGE].include?(pokemon.ability) ||
				 (pokemon.species == :BEHEEYEM  && (pokemon.item_id == :BEHEEYEMITE || pokemon.hasMegaEvoMutation?)) ||
				 (pokemon.species == :MILOTIC   && (pokemon.item_id == :MILOTITE || pokemon.hasMegaEvoMutation?)) ||
				 (pokemon.species == :TREVENANT && (pokemon.item_id == :TREVENANTITE || pokemon.hasMegaEvoMutation?)) ||
				 (pokemon.species == :BEAKRAFT  && (pokemon.item_id == :BEAKRAFTITE || pokemon.hasMegaEvoMutation?))
				roles.push("Field Setter")
			end
			pokemonPartyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(pokemon.index).length
			if pokemon.pokemonIndex == pokemonPartyEnd
				roles.push("Ace")
			end
			if pokemon.pokemonIndex == (pokemonPartyEnd - 1)
				roles.push("Second")
			end
		elsif pokemon.is_a?(Pokemon) # used for the whole party
			movelist = []
			for i in pokemon.moves
				next if i.nil?
				movedummy = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(i.id))
				movelist.push(movedummy)
			end
			if [:MODEST, :JOLLY, :TIMID, :ADAMANT].include?(pokemon.nature) || 
				 [:CHOICEBAND, :CHOICESPECS, :CHOICESCARF].include?(pokemon.item_id)
				roles.push("Sweeper")
			end
			healingmove = movelist.any? { |m| m&.healingMove? }
			if healingmove
				if [:BOLD, :RELAXED, :IMPISH, :LAX].include?(pokemon.nature)
					roles.push("Physical Wall")
				elsif [:CALM, :GENTLE, :SASSY, :CAREFUL].include?(pokemon.nature)
					roles.push("Special Wall")
				end
			else
				if pokemon.item_id == :ASSAULTVEST || pokemon.item_id == :MELEEVEST
					roles.push("Tank")
				end
			end
			if position == 0
				roles.push("Lead")
			end
			cleric=false
			for mmm in movelist
				if [:HEALBELL, :AROMATHERAPY, :WISH].include?(mmm.id)
					cleric=true
				end
			end
			if cleric
				roles.push("Cleric")
			end
			phaze=false
			for mmm in movelist
				if [:YAWN, :PERISHSONG, :DRAGONTAIL, :CIRCLETHROW, :WHIRLWIND, :ROAR].include?(mmm.id)
					phaze=true
				end
			end
			if phaze
				roles.push("Phazer")
			end
			if pokemon.item_id == :LIGHTCLAY
				roles.push("Screener")
			end
			# the index here is (probably) wrong but lets see what will happen
			fakemon = @battle.pbMakeFakeBattler(pokemon,false,target.pbDirectOpposing)
			priorityko=false
			for zzz in fakemon.moves
				next if zzz.nil? || priorityAI(target,zzz)<1
				dam=pbRoughDamage(zzz, fakemon, target, 100, zzz.baseDamage)
				if target.hp>0
					percentage=(dam*100.0)/target.hp
					priorityko=true if percentage>100
				end
			end
			if priorityko || (pokemon.speed>target.pbSpeed)
				roles.push("Revenge Killer")
			end
			pivot=false
			for mmm in movelist
				if [:UTURN, :FLIPTURN, :VOLTSWITCH, :PARTINGSHOT, :BATONPASS, :TELEPORT].include?(mmm.id)
					pivot=true
				end
			end
			if (pivot && healingmove) || pokemon.ability == :REGENERATOR
				roles.push("Pivot")
			end
			spinmove=false
			for mmm in movelist
				if [:RAPIDSPIN].include?(mmm.id)
					spinmove=true
				end
			end
			if spinmove
				roles.push("Spinner")
			end
			batonpass=false
			for mmm in movelist
				if [:BATONPASS].include?(mmm.id)
					batonpass=true
				end
			end
			if batonpass
				roles.push("Baton Passer")
			end
			tauntmove=false
			for mmm in movelist
				if [:TAUNT].include?(mmm.id)
					tauntmove=true
				end
			end
			if tauntmove || [:CHOICEBAND, :CHOICESPECS].include?(pokemon.item_id)
				roles.push("Stallbreaker")
			end
			restmove=false
			for mmm in movelist
				if [:REST].include?(mmm.id)
					restmove=true
				end
			end
			if restmove || [:TOXICORB, :FLAMEORB].include?(pokemon.item_id) ||
				 [:COMATOSE, :GUTS, :QUICKFEET, :FLAREBOOST, :TOXICBOOST, 
					:NATURALCURE, :MAGICGUARD, :MAGICBOUNCE].include?(pokemon.ability) ||
				 (pokemon.ability == :HYDRATION && [:HeavyRain, :Rain].include?(@battle.field.weather))
				roles.push("Status Absorber")
			end
			if [:SHADOWTAG, :ARENATRAP, :MAGNETPULL, :BAITEDLINE].include?(pokemon.ability)
				roles.push("Trapper")
			end
			weathermove=false
			for mmm in movelist
				if [:RAINDANCE, :SUNNYDAY, :SANDSTORM, :HAIL].include?(mmm.id)
					weathermove=true
				end
			end
			if weathermove || 
				 [:DROUGHT, :DRIZZLE, :SANDSTREAM, :SNOWWARNING, 
				  :PRIMORDIALSEA, :DESOLATELAND, :DELTASTREAM, 
				  :FORECAST, :PRESAGE, :DUSTSENTINEL].include?(pokemon.ability) ||
				 (pokemon.ability == :FREEZEOVER && pokemon.item_id == :ICYROCK) ||
				 (pokemon.species == :ZARCOIL  && (pokemon.item_id == :ZARCOILITE || pokemon.hasMegaEvoMutation?)) ||
				 (pokemon.species == :ZOLUPINE && (pokemon.item_id == :ZOLUPINEITE || pokemon.hasMegaEvoMutation?)) ||
				 (pokemon.species == :CACTURNE && (pokemon.item_id == :CACTURNITE || pokemon.hasMegaEvoMutation?)) ||
				 (pokemon.species == :FRIZZARD && (pokemon.item_id == :FRIZZARDITE || pokemon.hasMegaEvoMutation?))
				roles.push("Weather Setter")
			end
			terrainmove=false
			for mmm in movelist
				if [:GRASSYTERRAIN, :ELECTRICTERRAIN, :MISTYTERRAIN, :PSYCHICTERRAIN].include?(mmm.id)
					terrainmove=true
				end
			end
			if terrainmove || 
				 [:ELECTRICSURGE, :PSYCHICSURGE, :MISTYSURGE, :GRASSYSURGE].include?(pokemon.ability) ||
				 (pokemon.species == :BEHEEYEM  && (pokemon.item_id == :BEHEEYEMITE || pokemon.hasMegaEvoMutation?)) ||
				 (pokemon.species == :MILOTIC   && (pokemon.item_id == :MILOTITE || pokemon.hasMegaEvoMutation?)) ||
				 (pokemon.species == :TREVENANT && (pokemon.item_id == :TREVENANTITE || pokemon.hasMegaEvoMutation?)) ||
				 (pokemon.species == :BEAKRAFT  && (pokemon.item_id == :BEAKRAFTITE || pokemon.hasMegaEvoMutation?))
				roles.push("Field Setter")
			end
			if position == (party.length - 1)
				roles.push("Ace")
			end
			if position == (party.length - 2)
				roles.push("Second")
			end
		end
		#~ print roles
		return roles
	end
	
	# Status Moves "Damage" Multiplier ###########################################

	def pbStatusDamage(move)
		moveScoores = {
		  0 => [:AFTERYOU, :ATTRACT, :BESTOW, :CELEBRATE, :HAPPYHOUR, :HOLDHANDS,
				 :QUASH, :SPLASH, :SWEETSCENT, :TELEKINESIS],
		  5 => [:ALLYSWITCH, :AROMATICMIST, :COACHING, :CONVERSION, :CRAFTYSHIELD, :ENDURE, :ENTRAINMENT, 
				 :FAIRYLOCK, :FORESIGHT, :FORESTSCURSE, :GRUDGE, :GUARDSPLIT, :GUARDSWAP, :HEALBLOCK, 
				 :HELPINGHAND, :IMPRISON, :LOCKON, :LUCKYCHANT, :MAGICROOM, :MAGNETRISE, 
				 :MINDREADER, :MIRACLEEYE, :MUDSPORT, :NIGHTMARE, :ODORSLEUTH, :POWERSPLIT, :POWERSWAP, 
				 :POWERTRICK, :QUICKGUARD, :RECYCLE, :REFLECTTYPE, :ROTOTILLER, :SAFEGUARD, :SANDATTACK, 
				 :SKILLSWAP, :SPEEDSWAP, :SPOTLIGHT, :SPITE, :SHARPEN, :TEATIME, :TEETERDANCE, :WATERSPORT, 
				 :LASERFOCUS],
		  10 => [:ACUPRESSURE, :CAMOUFLAGE, :CHARM, :CONFIDE, :DEFENSECURL, :DECORATE, :EMBARGO,
				 :FLASH, :FOCUSENERGY, :GROWL, :HARDEN, :HAZE, :KINESIS, :LEER, :LIFEDEW,
				 :METALSOUND, :MEMENTO, :NOBLEROAR, :PLAYNICE, :POWDER, :PSYCHUP, 
				 :SMOKESCREEN, :STRINGSHOT, :SUPERSONIC, :TAILWHIP, :TORMENT, :TEARFULLOOK,
				 :WITHDRAW, :EXCITE, :HOWL, :MEDITATE, :GROWTH, :WORKUP],
		  20 => [:AGILITY, :ASSIST, :BABYDOLLEYES, :CAPTIVATE, :CHARGE, :CORROSIVEGAS, :COTTONSPORE,
				 :COURTCHANGE, :DEFOG, :DOUBLETEAM, :EERIEIMPULSE, :FAKETEARS, :FEATHERDANCE,
				 :FLORALHEALING, :GEARUP, :HEALINGWISH, :HEALPULSE, :INGRAIN, :INSTRUCT, :LUNARDANCE,
				 :MEFIRST, :MIMIC, :POISONPOWDER, :REFRESH, :ROLEPLAY, :SCARYFACE,
				 :SCREECH, :SKETCH, :STUFFCHEEKS, :TARSHOT, :TICKLE, :TRICKORTREAT, :VENOMDRENCH,
				 :MAGNETICFLUX, :JUNGLEHEALING],
		  25 => [:AQUARING, :BLOCK, :CONVERSION2, :COPYCAT, :ELECTRIFY, :FLATTER, :FLOWERSHIELD,
				 :GASTROACID, :HEARTSWAP, :IONDELUGE, :MAGICCOAT, :MEANLOOK, :METRONOME,
				 :MIRRORMOVE, :MIST, :PERISHSONG, :POISONGAS, :REST, :ROAR, :SIMPLEBEAM, :SNATCH,
				 :SPIDERWEB, :SWAGGER, :SWEETKISS, :TRANSFORM, :WHIRLWIND, :WORRYSEED, :YAWN],
		  30 => [:ACIDARMOR, :AMNESIA, :AUTOTOMIZE, :BARRIER, :BELLYDRUM, :COSMICPOWER, :COTTONGUARD,
				 :DEFENDORDER, :DESTINYBOND, :DISABLE, :FOLLOWME, :GRAVITY, :IRONDEFENSE,
				 :MINIMIZE, :OCTOLOCK, :POLLENPUFF, :PSYCHOSHIFT, :RAGEPOWDER, :REBALANCING,
				 :ROCKPOLISH, :SANDSTORM, :STOCKPILE, :SUBSTITUTE, :SWALLOW, :SWITCHEROO, :TAUNT,
				 :TRICK, :HAIL],
		  35 => [:BATONPASS, :BULKUP, :CALMMIND, :CLANGOROUSSOUL, :COIL, :CURSE, :ELECTRICTERRAIN,
				 :ENCORE, :GRASSYTERRAIN, :LEECHSEED, :MAGICPOWDER, :MISTYTERRAIN, :NATUREPOWER,
				 :NORETREAT, :PAINSPLIT, :PSYCHICTERRAIN, :PURIFY, :SLEEPTALK, :SOAK, :SUNNYDAY,
				 :TELEPORT, :TRICKROOM, :WISH, :WONDERROOM, :RAINDANCE],
		  40 => [:AROMATHERAPY, :AURORAVEIL, :BITINGCOLD, :BOOMINSTALL, :CONFUSERAY, :GLARE, :HEALBELL, 
				 :HONECLAWS, :LIGHTSCREEN, :MATBLOCK, :PARTINGSHOT, :REFLECT, :SPIKES, :STUNSPORE, 
				 :TAILWIND, :THUNDERWAVE, :TOXIC, :TOXICSPIKES, :TOXICTHREAD, :WIDEGUARD, :WILLOWISP],
		  50 => [:NASTYPLOT, :STEALTHROCK, :SWORDSDANCE, :STICKYWEB, :TOPSYTURVY],
		  60 => [:DRAGONDANCE, :GEOMANCY, :QUIVERDANCE, :SHELLSMASH, :SHIFTGEAR, :TAILGLOW],
		  70 => [:HEALORDER, :MILKDRINK, :MOONLIGHT, :MORNINGSUN, :RECOVER, :ROOST,
				 :SHOREUP, :SLACKOFF, :SOFTBOILED, :STRENGTHSAP, :SYNTHESIS],
		  80 => [:BANEFULBUNKER, :KINGSSHIELD, :OBSTRUCT, :PROTECT, :SPIKYSHIELD, :DETECT],
		  100 => [:DARKVOID, :GRASSWHISTLE, :HYPNOSIS, :LOVELYKISS, :SING, :SLEEPPOWDER, :SPORE]
		}

		moveid = move.id
		moveScoores.each do |score, moves|
		  return score if moves.include?(moveid)
		end
	  
		print "why are you stupid; #{move.name}"
		return 10
	end			

	# Disrupting Scores ##########################################################
	
	def getFieldDisruptScore(user, target, globalArray = [], skill = 100) 
		# probably redundant with the check WeatherBenefit script but eh
		globalArray = pbGetMidTurnGlobalChanges if globalArray.empty?
		procGlobalArray = processGlobalArray(globalArray)
		expectedTerrain = procGlobalArray[1]
		# modified by JZ
    	fieldscore = 100.0
		aroles = pbGetPokemonRole(user, target)
		oroles = pbGetPokemonRole(target, user)
		if expectedTerrain == :Electric # Electric Terrain
			echo("\nElectric Terrain Disrupt") if $AIGENERALLOG
			target.eachAlly do |b|
				next if !b.affectedByTerrain?
				if b.pbHasType?(:ELECTRIC, true)
					fieldscore*=1.5
				end
			end
			if user.pbHasType?(:ELECTRIC, true)
				fieldscore*=0.5
			end
			partyelec=false
			@battle.pbParty(user.index).each do |m|
				next if m.fainted?
				partyelec=true if m.pbHasType?(:ELECTRIC, true)
				for z in m.moves
					sleepmove = true if [:DARKVOID, :GRASSWHISTLE, :HYPNOSIS, 
										 :LOVELYKISS, :SING, :SLEEPPOWDER, :SPORE].include?(z.id)
				end
			end
			if partyelec
				fieldscore*=0.5
			end
			if sleepmove
				fieldscore*=0.5
			end
			if target.hasActiveAbility?(:SURGESURFER)
				fieldscore*=1.3
			end
			if user.hasActiveAbility?(:SURGESURFER)
				fieldscore*=0.7
			end
		end
		if expectedTerrain == :Grassy # Grassy Terrain
			echo("\nGrassy Terrain Disrupt") if $AIGENERALLOG
			target.eachAlly do |b|
				next if !b.affectedByTerrain?
				if b.pbHasType?(:GRASS, true)
					fieldscore*=1.5
				end
			end
			if user.pbHasType?(:GRASS, true)
				fieldscore*=0.5
			end
			partygrass=false
			@battle.pbParty(user.index).each do |m|
				next if m.fainted?
				partygrass=true if m.pbHasType?(:GRASS, true)
			end
			if partygrass
				fieldscore*=0.5
			end
			if aroles.include?("Special Wall") || aroles.include?("Physical Wall")
				fieldscore*=0.8
			end
			if oroles.include?("Special Wall") || oroles.include?("Physical Wall")
				fieldscore*=1.2
			end
		end
		if expectedTerrain == :Misty # Misty Terrain
			echo("\nMisty Terrain Disrupt") if $AIGENERALLOG
			if user.spatk>user.attack
				target.eachAlly do |b|
					next if !b.affectedByTerrain?
					if b.pbHasType?(:FAIRY, true)
						fieldscore*=1.3
					end
				end
			end
			if target.spatk>target.attack
				if user.pbHasType?(:FAIRY, true)
					fieldscore*=0.7
				end
			end
			if target.pbHasType?(:DRAGON, true) || target.pbPartner.pbHasType?(:DRAGON, true)
				fieldscore*=0.5
			end
			if user.pbHasType?(:DRAGON, true)
				fieldscore*=1.5
			end
			partyfairy=false
			@battle.pbParty(user.index).each do |m|
				next if m.fainted?
				partyfairy=true if m.pbHasType?(:FAIRY, true)
			end
			if partyfairy
				fieldscore*=0.7
			end
			partydragon=false
			@battle.pbParty(user.index).each do |m|
				next if m.fainted?
				partydragon=true if m.pbHasType?(:DRAGON, true)
			end
			if partydragon
				fieldscore*=1.5
			end
		end
		if expectedTerrain == :Psychic # Psychic Terrain
			echo("\nPsychic Terrain Disrupt") if $AIGENERALLOG
			target.eachAlly do |b|
				next if !b.affectedByTerrain?
				if b.pbHasType?(:PSYCHIC, true)
					fieldscore*=1.7
				end
			end
			if user.pbHasType?(:PSYCHIC, true)
				fieldscore*=0.3
			end
			partypsy=false
			@battle.pbParty(user.index).each do |m|
				next if m.fainted?
				partypsy=true if m.pbHasType?(:PSYCHIC, true)
			end
			if partypsy
				fieldscore*=0.3
			end
			if target.hasActiveAbility?(:TELEPATHY)
				fieldscore*=1.3
			end
			if user.hasActiveAbility?(:TELEPATHY)
				fieldscore*=0.7
			end 
		end
		fieldscore*=0.01
		return fieldscore
  	end

	def getAbilityDisruptScore(move,user,target,skill)
		abilityscore=100.0
		if target.unstoppableAbility?
			echo("\nUnstoppable Ability Disrupt") if $AIGENERALLOG
			return 0
		end 
		if target.hasActiveAbility?(:SPEEDBOOST)
			echo("\nSpeedboost Disrupt") if $AIGENERALLOG
			abilityscore*=1.1
			if target.stages[:SPEED]<2
				abilityscore*=1.3
			end
		end
		if target.hasActiveAbility?([:SANDVEIL, :DUSTSENTINEL])
			echo("\nSand veil Disrupt") if $AIGENERALLOG
			if target.effectiveWeather == :Sandstorm
				abilityscore*=1.3
			end
		end
		if target.hasActiveAbility?(:SNOWCLOAK)
			echo("\nSnow Cloak Disrupt") if $AIGENERALLOG
			if target.effectiveWeather == :Hail
				abilityscore*=1.3
			end
		end
		if target.hasActiveAbility?([:VOLTABSORB, :LIGHTNINGROD, :MOTORDRIVE])
			echo("\nElectric Immunity Disrupt") if $AIGENERALLOG
			elecvar = false
			totalelec=true
			elecmove=nil
			for i in user.moves
				if i.type != :ELECTRIC
					totalelec=false
				end
				if i.type == :ELECTRIC
					elecvar=true
					elecmove=i
				end
			end
			if elecvar
				if totalelec
					abilityscore*=3
				end
				targetTypes = target.pbTypes(true)
				if Effectiveness.calculate(elecmove.type, targetTypes[0], targetTypes[1], targetTypes[2])>4
					abilityscore*=2
				end
			end
		end
		if target.hasActiveAbility?([:WATERABSORB, :STORMDRAIN, :DRYSKIN])
			echo("\nWater Immunity Disrupt") if $AIGENERALLOG
			watervar = false
			totalwater=true
			watermove=nil
			firevar=false
			for i in user.moves
				if i.type != :WATER
					totalwater=false
				end
				if i.type == :WATER
					watervar=true
					watermove=i
				end
				if i.type == :FIRE
					firevar=true
				end
			end
			if watervar
				if totalwater
					abilityscore*=3
				end
				targetTypes = target.pbTypes(true)
				if Effectiveness.calculate(watermove.type, targetTypes[0], targetTypes[1], targetTypes[2])>4
					abilityscore*=2
				end
			end
			if target.hasActiveAbility?(:DRYSKIN)
				if firevar
					abilityscore*=0.5
				end
			end              
		end
		if target.hasActiveAbility?([:FLASHFIRE, :HEATPROOF])
			if $AIGENERALLOG
				if target.hasActiveAbility?(:FLASHFIRE)
					echo("\nFlash Fire Disrupt")
				else 
					echo("\nHeatproof Disrupt")
				end
			end		
			firevar = false
			totalfire=true
			firemove=nil
			for i in user.moves
				if i.type != :FIRE
					totalfire=false	
				end
				if i.type == :FIRE
					firevar=true
					firemove=i
				end
			end
			if firevar
				if totalfire
					abilityscore*=3
				end
				targetTypes = target.pbTypes(true)
				if Effectiveness.calculate(firemove.type, targetTypes[0], targetTypes[1], targetTypes[2])>4
					abilityscore*=3
				end
			end
		end
		if target.hasActiveAbility?(:LEVITATE)
			echo("\nLevitate Disrupt") if $AIGENERALLOG
			groundvar = false
			totalground=true
			groundmove=nil
			for i in user.moves
				if i.type != :GROUND
					totalground=false
				end
				if i.type == :GROUND
					groundvar=true
					groundmove=i
				end
			end
			if groundvar
				if totalground
					abilityscore*=3
				end
				targetTypes = target.pbTypes(true)
				if Effectiveness.calculate(groundmove.type, targetTypes[0], targetTypes[1], targetTypes[2])>4
					abilityscore*=2
				end
			end
		end
		if target.hasActiveAbility?(:SHADOWTAG)
			echo("\nShadow Tag Disrupt") if $AIGENERALLOG
			if !user.hasActiveAbility?(:SHADOWTAG) || !(user.pbHasType?(:GHOST, true) && (Settings::MORE_TYPE_EFFECTS && !$game_switches[OLDSCHOOLBATTLE]))
				abilityscore*=1.5
			end
		end    
		if target.hasActiveAbility?(:ARENATRAP)
			echo("\nArena Trap Disrupt") if $AIGENERALLOG
			mold_bonkers=moldbroken(user,target,move)
			if !user.airborneAI(mold_bonkers)
				abilityscore*=1.5
			end
		end  
		if target.hasActiveAbility?(:WONDERGUARD)
			echo("\nWonder Guard Disrupt") if $AIGENERALLOG
			wondervar=false
			for i in user.moves
				typeMod = pbCalcTypeMod(i.type, user, target)
				wondervar=true if Effectiveness.super_effective?(typeMod)
			end
			if !wondervar
				abilityscore*=5
			end      
		end
		if target.hasActiveAbility?(:SERENEGRACE)
			echo("\nSerene Grace Disrupt") if $AIGENERALLOG
			abilityscore*=1.3
		end  
		if target.hasActiveAbility?([:PUREPOWER, :HUGEPOWER])
			echo("\nPure/Huge Power Disrupt") if $AIGENERALLOG
			abilityscore*=2
		end
		if target.hasActiveAbility?(:SOUNDPROOF)
			echo("\nSoundproof Disrupt") if $AIGENERALLOG
			if user.moves.any? { |m| m&.soundMove? }
				abilityscore*=3
			end      
		end
		if target.hasActiveAbility?(:STAMINA)
			echo("\nStamina Disrupt") if $AIGENERALLOG
			if user.moves.any? { |m| m&.pbContactMove?(user) }
				abilityscore*=1.3
				abilityscore*=1.5 if user.moves.any? { |m| m&.multiHitMove? }
			end
		end
		if target.hasActiveAbility?(:STEAMENGINE)
			echo("\nSteam Engine Disrupt") if $AIGENERALLOG
			totalguard=true
			for i in user.moves
				if i.type == :FIRE || i.type == :WATER
					totalguard=false
				end
			end
			if totalguard
				abilityscore*=1.5
			end
		end
		if target.hasActiveAbility?(:THICKFAT)
			echo("\nThick Fat Disrupt") if $AIGENERALLOG
			totalguard=true
			for i in user.moves
				if i.type == :FIRE || i.type == :ICE
					totalguard=false
				end
			end      
			if totalguard
				abilityscore*=1.5
			end
		end
		if target.hasActiveAbility?(:TRUANT)
			echo("\nTruant Disrupt") if $AIGENERALLOG
			abilityscore*=0.1
		end 
		if target.hasActiveAbility?([:GUTS, :QUICKFEET, :MARVELSCALE])
			echo("\nGuts/Quick Feet/Marvel Scale Disrupt") if $AIGENERALLOG
			if target.pbHasAnyStatus?
				abilityscore*=1.5
			end      
		end 
		if target.hasActiveAbility?(:LIQUIDOOZE)
			echo("\nLiquid Ooze Disrupt") if $AIGENERALLOG
			if target.effects[PBEffects::LeechSeed]>=0 || user.pbHasMove?(:LEECHSEED)
				abilityscore*=2
			end              
		end 
		if target.hasActiveAbility?([:AIRLOCK, :CLOUDNINE])
			echo("\nAirlock Disrupt") if $AIGENERALLOG
			abilityscore*=1.1
		end 
		if target.hasActiveAbility?(:HYDRATION)
			echo("\nHydration Disrupt") if $AIGENERALLOG
			if [:Rain, :HeavyRain].include?(target.effectiveWeather)
				abilityscore*=1.3
			end
		end
		if target.hasActiveAbility?(:ADAPTABILITY)
			echo("\nAdaptability Disrupt") if $AIGENERALLOG
			abilityscore*=1.3
		end 
		if target.hasActiveAbility?(:SKILLLINK)
			echo("\nSkill Link Disrupt") if $AIGENERALLOG
			abilityscore*=1.5
		end 
		if target.hasActiveAbility?(:POISONHEAL)
			echo("\nPoison Heal Disrupt") if $AIGENERALLOG
			if target.poisoned?
				abilityscore*=2
			end      
		end 
		if target.hasActiveAbility?(:NORMALIZE)
			echo("\nNormalize Disrupt") if $AIGENERALLOG
			abilityscore*=0.5
		end 
		if target.hasActiveAbility?(:MAGICGUARD)
			echo("\nMagic Guard Disrupt") if $AIGENERALLOG
			abilityscore*=1.4
		end 
		if target.hasActiveAbility?(:STALL)
			echo("\nStall Disrupt") if $AIGENERALLOG
			abilityscore*=1.5
		end 
		if target.hasActiveAbility?(:TECHNICIAN)
			echo("\nTechnician Disrupt") if $AIGENERALLOG
			abilityscore*=1.3
		end 
		if target.hasActiveAbility?(:GALEWINGS)
			echo("\nGale Wings Disrupt") if $AIGENERALLOG
			abilityscore*=2 if target.moves.any? { |m| [:FLYING].include?(m&.type) } && target.hp >= (target.totalhp/2)
		end 	
		if target.hasActiveAbility?(:UNBURDEN)
			if target.effects[PBEffects::Unburden]
				echo("\nUnburden Disrupt") if $AIGENERALLOG
				abilityscore*=2
			end	
		end 			
		if target.hasMoldBreaker? || ((target.isSpecies?(:GYARADOS) || target.isSpecies?(:LUPACABRA)) && target.pokemon.willmega)
			echo("\nMold Breaker (and clones) Disrupt") if $AIGENERALLOG
			abilityscore*=1.1
		end 
		if target.hasActiveAbility?(:UNAWARE)
			echo("\nUnaware Disrupt") if $AIGENERALLOG
			abilityscore*=1.7
		end 
		if target.hasActiveAbility?(:SLOWSTART)
			echo("\nSlow Start Disrupt") if $AIGENERALLOG
			abilityscore*=0.3
		end 
		if target.hasActiveAbility?(:SHEERFORCE)
			echo("\nSheer Force Disrupt") if $AIGENERALLOG
			abilityscore*=1.2
		end 
		if target.hasActiveAbility?([:PUNKROCK, :AMPLIFIER])
			echo("\nPunk / Amp Disrupt") if $AIGENERALLOG
			abilityscore*=1.2
		end 
		if target.hasActiveAbility?(:CONTRARY)
			echo("\nContrary Disrupt") if $AIGENERALLOG
			abilityscore*=1.4
			if target.stages[:ATTACK]>0  || target.stages[:SPECIAL_ATTACK]>0  || 
			   target.stages[:DEFENSE]>0 || target.stages[:SPECIAL_DEFENSE]>0 || 
			   target.stages[:SPEED]>0
				if target.pbHasMove?(:CLOSECOMBAT) || target.pbHasMove?(:DRAGONASCENT) || 
				   target.pbHasMove?(:LEAFSTORM) || target.pbHasMove?(:DRACOMETEOR) || 
				   target.pbHasMove?(:OVERHEAT) || target.pbHasMove?(:PSYCHOBOOST) || 
				   target.pbHasMove?(:HAMMERARM) || target.pbHasMove?(:SUPERPOWER) || 
				   target.pbHasMove?(:VCREATE)
					abilityscore*=3
				end		
			end              
		end 
		if target.hasActiveAbility?(:DEFEATIST)
			echo("\nDefeatist Disrupt") if $AIGENERALLOG
			abilityscore*=0.5
		end 
		if target.hasActiveAbility?([:MULTISCALE, :SHADOWSHIELD])
			echo("\nMultiscale Disrupt") if $AIGENERALLOG
			abilityscore*=1.5 if target.hp==target.totalhp
		end 
		if target.hasActiveAbility?(:HARVEST)
			echo("\nHarvest Disrupt") if $AIGENERALLOG
			abilityscore*=1.2
			abilityscore*=1.2 if [:Sun, :HarshSun].include?(target.effectiveWeather)
		end 
		if target.hasActiveAbility?(:MOODY)
			echo("\nMoody Disrupt") if $AIGENERALLOG
			abilityscore*=1.8
		end 
		if target.hasActiveAbility?(:SAPSIPPER)
			echo("\nSap Sipper Disrupt") if $AIGENERALLOG
			grassvar = false
			totalgrass=true
			grassmove=nil
			for i in user.moves
				if i.type != :GRASS
					totalgrass=false
				end
				if i.type == :GRASS
					grassvar=true
					grassmove=i
				end
			end
			if grassvar
				if totalgrass
					abilityscore*=3
				end
				targetTypes = target.pbTypes(true)
				if Effectiveness.calculate(groundmove.type, targetTypes[0], targetTypes[1], targetTypes[2])>4
					abilityscore*=2
				end
			end
		end
		if target.hasActiveAbility?(:PRANKSTER)
			echo("\nPrankster Disrupt") if $AIGENERALLOG
			abilityscore*=1.5 if pbRoughStat(user,:SPEED,skill)>pbRoughStat(target,:SPEED,skill) && !user.pbHasType?(:DARK, false)
		end
		if target.hasActiveAbility?(:FURCOAT)
			echo("\nFur Coat Disrupt") if $AIGENERALLOG
			abilityscore*=1.5 if user.attack>user.spatk
		end
		if target.hasActiveAbility?(:ICESCALES)
			echo("\nIce Scales Disrupt") if $AIGENERALLOG
			abilityscore*=1.5 if user.attack<user.spatk
		end
		if target.hasActiveAbility?(:PARENTALBOND)
			echo("\nParental Bond Disrupt") if $AIGENERALLOG
			abilityscore*=3
		end 
		if target.hasActiveAbility?([:PROTEAN, :LIBERO])
			echo("\nProtean Disrupt") if $AIGENERALLOG
			abilityscore*=3
		end 
		if target.hasActiveAbility?(:TOUGHCLAWS)
			echo("\nTough Claws Disrupt") if $AIGENERALLOG
			abilityscore*=1.2
		end
		if target.hasActiveAbility?(:UNSEENFIST)
			echo("\nUnseen Fist Disrupt") if $AIGENERALLOG
			if pbHasSingleTargetProtectMove?(user, false) && target.moves.any? { |m| m&.pbContactMove?(target) }
				abilityscore*=1.5
			end
		end
		if target.hasActiveAbility?(:BEASTBOOST)
			echo("\nBeast Boost Disrupt") if $AIGENERALLOG
			abilityscore*=1.1
		end 
		if target.hasActiveAbility?(:COMATOSE)
			echo("\nComatose Disrupt") if $AIGENERALLOG
			abilityscore*=1.3
		end 
		if target.hasActiveAbility?(:FLUFFY)
			echo("\nFluffy Disrupt") if $AIGENERALLOG
			abilityscore*=1.5
			firevar = false
			for i in user.moves
				if i.type == :FIRE
				firevar=true
				end
			end
			if firevar
				abilityscore*=0.5
			end      
		end
		if target.hasActiveAbility?(:MERCILESS)
			echo("\nMerciless Disrupt") if $AIGENERALLOG
			abilityscore*=1.3
		end 
		if target.hasActiveAbility?(:WATERBUBBLE)
			echo("\nWater Bubble Disrupt") if $AIGENERALLOG
			abilityscore*=1.5
			firevar = false
			for i in user.moves
				if i.type == :FIRE
					firevar=true
				end
			end
			if firevar
				abilityscore*=1.3
			end      
		end
		# Disrupt scores for Untamed abilities
		if target.hasActiveAbility?(:BAITEDLINE)
			echo("\nBaited Line Disrupt") if $AIGENERALLOG
			abilityscore*=1.5 if user.pbHasType?(:WATER, true)
			abilityscore*=1.5 if user.allAllies.any? { |b| b&.pbHasType?(:WATER, true) }
		end
		if target.hasActiveAbility?(:MICROSTRIKE)
			echo("\nMicro Strike Disrupt") if $AIGENERALLOG
			abilityscore*=1.2 if user.pbWeight > target.pbWeight
		end
		if target.hasActiveAbility?(:BLADEMASTER)
			echo("\nBlademaster Disrupt") if $AIGENERALLOG
			abilityscore*=1.2 if target.moves.any? { |i| i.bladeMove? }
		end
		if target.hasActiveAbility?(:JUNGLEFURY)
			echo("\nJungle Fury Disrupt") if $AIGENERALLOG
			abilityscore*=1.4 if target.affectedByTerrain? && @battle.field.terrain == :Grassy
		end
		if target.hasActiveAbility?(:WARRIORSPIRIT)
			echo("\nWarrior Spirit Disrupt") if $AIGENERALLOG
			supervar=false
			for i in target.moves
				break if supervar
				typeMod = pbCalcTypeMod(i.type, target, user)
				supervar=true if Effectiveness.super_effective?(typeMod)
			end
			if supervar
				abilityscore*=2.0
			end      
		end
		if target.hasActiveAbility?(:SLIPPERYPEEL)
			echo("\nSlippery Peel Disrupt") if $AIGENERALLOG
			if user.moves.any? { |m| m&.pbContactMove?(user) } && !target.effects[PBEffects::SlipperyPeel] && 
			  (!user.trappedInBattle? || user.effects[PBEffects::Substitute] <= 0)
				abilityscore*=1.5
			end
		end
		if target.hasActiveAbility?(:CARPENTER)
			echo("\nCarpenter Disrupt") if $AIGENERALLOG
			if target.allAllies.any?
				target.allAllies.each do |b|
					abilityscore*=1.3 if b.pbHasType?(:GRASS, true) || b.pbHasType?(:ROCK, true) || b.pbHasType?(:STEEL, true)
				end
			end
		end
		if target.hasActiveAbility?(:MOMENTUM)
			echo("\nMomentum Disrupt") if $AIGENERALLOG
			abilityscore *= 1 + (0.25 * [user.effects[PBEffects::Momentum], 5].min)
		end
		if target.hasActiveAbility?(:CRYSTALJAW)
			echo("\nCrystal Jaw Disrupt") if $AIGENERALLOG
			if target.moves.any? { |i| i.bitingMove? }
				abilityscore*=1.2
				abilityscore*=1.1 if user.attack<user.spatk
			end
		end
		if target.hasActiveAbility?(:TRICKSTER)
			echo("\nTrickster Disrupt") if $AIGENERALLOG
			abilityscore*=1.3 if target.moves.any? { |j| [:TRICKROOM, :MAGICROOM, :WONDERROOM].include?(j&.id) }
			abilityscore*=1.3 if target.moves.any? { |j| j&.id == :TRICKROOM }
		end
		if target.hasActiveAbility?(:PREMONITION)
			echo("\nPremonition Disrupt") if $AIGENERALLOG
			abilityscore*=1.3
			abilityscore*=1.3 if target.moves.any? { |j| [:FUTURESIGHT, :DOOMDESIRE].include?(j&.id) }
		end
		if target.hasActiveAbility?(:MASSEXTINCTION)
			echo("\nMass Extinction Disrupt") if $AIGENERALLOG
			abilityscore*=1.5 if user.pbHasType?(:DRAGON, true)
			abilityscore*=1.5 if user.allAllies.any? { |b| b&.pbHasType?(:DRAGON, true) }
		end
		if target.hasActiveAbility?(:ECHOCHAMBER)
			echo("\nEcho Chamber Disrupt") if $AIGENERALLOG
			if target.moves.any? { |i| i.soundMove? }
				abilityscore*=1.2
			end
			if target.moves.any? { |i| i.soundMove? && i.statusMove? } && 
			   pbRoughStat(user,:SPEED,skill)>pbRoughStat(target,:SPEED,skill)
				abilityscore*=1.4
			end
		end
		if target.hasActiveAbility?(:HONORBOUND)
			echo("\nHonorbound Disrupt") if $AIGENERALLOG
			abilityscore*=0.6
		end
		if target.hasActiveAbility?(:ACCUMULATOR)
			echo("\nAccumulator Disrupt") if $AIGENERALLOG
			if !target.item && target.moves.any? { |j| [:SPITUP, :SWALLOW, :STOCKPILE].include?(j&.id) }
				abilityscore*=1.2
			end
		end
		if target.hasActiveAbility?(:SEANCE)
			echo("\nMinor Impact Untamed Ability Disrupt") if $AIGENERALLOG
			abilityscore*=1.2
		end
		if target.hasActiveAbility?(:FERVOR)
			echo("\nMedium Impact Untamed Ability Disrupt") if $AIGENERALLOG
			abilityscore*=1.3
		end
		if target.hasActiveAbility?(:PARTYPOPPER)
			echo("\nHigh Impact Untamed Ability Disrupt") if $AIGENERALLOG
			abilityscore*=1.6
		end
		# id add showtime here since its a pretty good ability in 2v2, but i made it so it cant be stopped
		abilityscore*=0.01
		return abilityscore
	end

	# Megas' Mid Turn A.T.W. changes #############################################
	
	def pbGetMidTurnGlobalChanges
		globalArray = []
		globalEffects = {
			:NOCTAVISPA => "dark aura",
			:SPECTERZAL => "spooper aura",
			:BEAKRAFT   => "electric terrain",
			:MILOTIC    => "misty terrain",
			:TREVENANT  => "grassy terrain",
			:BEHEEYEM   => "psychic terrain",
			:ZARCOIL    => "sun weather",
			:ZOLUPINE   => "rain weather",
			:CACTURNE   => "sand weather",
			:FRIZZARD   => "hail weather"
		}
		megaStones = {
			:NOCTAVISPA => :NOCTAVISPITE,
			:SPECTERZAL => :SPECTERZITE,
			:BEAKRAFT   => :BEAKRAFTITE,
			:MILOTIC    => :MILOTITE,
			:TREVENANT  => :TREVENANTITE,
			:BEHEEYEM   => :BEHEEYEMITE,
			:ZARCOIL    => :ZARCOILITE,
			:ZOLUPINE   => :ZOLUPINEITE,
			:CACTURNE   => :CACTURNITE,
			:FRIZZARD   => :FRIZZARDITE
		}
	
		# if multiple weathers/terrains are pushed only the slowest one should be acounted
		# very very VERY niche situation, but hey, i am bored.
		slowestWeather = nil
		slowestTerrain = nil
		slowestWeatherSpeed = 9 ** 9
		slowestTerrainSpeed = 9 ** 9
		@battle.allBattlers.each do |j|
			megaSpecies = j.pokemon.species
			if globalEffects.key?(megaSpecies) && j.pokemon.willmega && 
			  (j.item == megaStones[megaSpecies] || j.hasMegaEvoMutation?)
			  	effectne = globalEffects[megaSpecies]
			  	jspeed = pbRoughStat(j,:SPEED,100,false)
 				if effectne.include?("weather")
					if jspeed < slowestWeatherSpeed
						slowestWeather = effectne
						slowestWeatherSpeed = jspeed
					end
				elsif effectne.include?("terrain")
					if jspeed < slowestTerrainSpeed
						slowestTerrain = effectne
						slowestTerrainSpeed = jspeed
					end
				else
					globalArray.push(effectne) # auras can stack
				end
			end
		end
		globalArray.push(slowestWeather) if slowestWeather
  		globalArray.push(slowestTerrain) if slowestTerrain

		# airlock/cloud9 interaction
		weatherNeg=false
		@battle.allBattlers.each do |n|
			weatherNeg = true if n.hasActiveAbility?([:AIRLOCK, :CLOUDNINE]) && 
								 n.battle.choices[n.index][0] != :SwitchOut
		end
		globalArray.reject! { |w| w.include?("weather") } if weatherNeg
		globalArray.uniq!
		#echoln globalArray
		return globalArray
	end

	def processGlobalArray(globalArray)
		expectedWeather = @battle.pbWeather
		expectedTerrain = @battle.field.terrain
		globalArray.each do |wtz|
			case wtz
			when "sun weather"  then expectedWeather = :Sun
			when "rain weather" then expectedWeather = :Rain
			when "sand weather" then expectedWeather = :Sandstorm
			when "hail weather" then expectedWeather = :Hail
			when "electric terrain" then expectedTerrain = :Electric
			when "grassy terrain"   then expectedTerrain = :Grassy
			when "misty terrain"    then expectedTerrain = :Misty
			when "psychic terrain"  then expectedTerrain = :Psychic
			end
		end
		return [expectedWeather, expectedTerrain]
	end

	# Priority Moves Scoring #####################################################
	
	def pbAIPrioSpeedCheck(user, target, move, score, globalArray, aspeed = 0, ospeed = 0)
		skill = 100
		thisprio = priorityAI(user,move)
		if thisprio>0 
			aspeed = pbRoughStat(user,:SPEED,skill) if aspeed == 0
			ospeed = pbRoughStat(target,:SPEED,skill) if ospeed == 0
			if move.baseDamage>0  
				fastermon = ((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
				if fastermon
					echo("\n"+user.name+" is faster than "+target.name+".\n")
				else
					echo("\n"+target.name+" is faster than "+user.name+".\n")
				end
				if !targetSurvivesMove(move,user,target)
					echo("\n"+target.name+" will not survive.")
					if fastermon
						echo("Score x1.3\n")
						score*=1.3
					else
						echo("Score x2\n")
						score*=2
					end
				end   
				movedamage = -1
				maxpriomove=nil
				maxmove = nil
				opppri = false     
				pridam = -1
				for j in target.moves
					tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
					tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
					if priorityAI(target,j)>0
						opppri=true
						if tempdam>pridam
							pridam = tempdam
							maxpriomove=j
						end              
					end    
					if tempdam>movedamage
						movedamage = tempdam
						maxmove=j
					end 
				end 
				if opppri
					echo("Expected priority damage taken by "+target.name+": "+pridam.to_s+"\n") 
				end
				if !fastermon
					echo("Expected damage taken by "+target.name+": "+movedamage.to_s+"\n") 
					maxdam=0
					maxmove2=nil
					if !targetSurvivesMove(maxmove,target,user)
						echo(user.name+" does not survive. Score +150. \n")
						score+=150
						for j in target.moves
							if target.effects[PBEffects::ChoiceBand] &&
								target.hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF])
								if target.lastMoveUsed && target.pbHasMove?(target.lastMoveUsed)
									next if j.id!=target.lastMoveUsed
								end
							end		
							tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage)
							tempdam = 0 if pbCheckMoveImmunity(1,j,target,user,100)
							maxdam=tempdam if tempdam>maxdam
							maxmove2=j
						end
						if !targetSurvivesMove(maxmove2,target,user)
							score+=30
						end
					end
				end     
				if opppri
					score*=1.1
					if !targetSurvivesMove(maxpriomove,target,user)
						if fastermon
							echo(user.name+" does not survive piority move. Score x3. \n")
							score*=3
						else
							echo(user.name+" does not survive priority move but is faster. Score -100 \n")
							score-=100
						end
					end
				end
				if !fastermon && 
						target.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
													"TwoTurnAttackInvulnerableUnderground",
													"TwoTurnAttackInvulnerableInSkyParalyzeTarget",
													"TwoTurnAttackInvulnerableUnderwater",
													"TwoTurnAttackInvulnerableInSkyTargetCannotAct")
					echo("Player Pokemon is invulnerable. Score-300. \n")
					score-=300
				end
				procGlobalArray = processGlobalArray(globalArray)
				expectedTerrain = procGlobalArray[1]
				if expectedTerrain == :Psychic && target.affectedByTerrain?
					echo("Blocked by Psychic Terrain. Score-300. \n")
					score-=300
				end
				@battle.allSameSideBattlers(target.index).each do |b|
					priobroken=moldbroken(user,b,move)
					if b.hasActiveAbility?([:DAZZLING, :QUEENLYMAJESTY],false,priobroken) &&
						 !(b.isSpecies?(:LAGUNA) && b.pokemon.willmega && !b.hasAbilityMutation?) # laguna can have dazz in pre-mega form
						score-=300 
						echo("Blocked by enemy ability. Score-300. \n")
					end
				end 
				if pbTargetsMultiple?(move,user) && pbHasSingleTargetProtectMove?(target)
					quickcheck = false 
					for j in target.moves
						quickcheck = true if j.function=="ProtectUserSideFromPriorityMoves"
					end          
					if quickcheck
						echo("Expecting quick guard. Score-200. \n")
						score-=200
					end  
				end    
			end      
		elsif thisprio<0
			if fastermon
				score*=0.9
				if move.baseDamage>0
					if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
													"TwoTurnAttackInvulnerableUnderground",
													"TwoTurnAttackInvulnerableInSkyParalyzeTarget",
													"TwoTurnAttackInvulnerableUnderwater",
													"TwoTurnAttackInvulnerableInSkyTargetCannotAct")
						echo("Negative priority move and AI pokemon is faster. Score x2 because Player Pokemon is invulnerable. \n")
						score*=2
					end
				end
			end      
		end
		return
	end
end