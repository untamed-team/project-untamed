class Battle::AI
	# kiriya ai log settings
	$AIMASTERLOG_TARGET = 0 # 0 = foe, 1 = ally
	$AIMASTERLOG = (false && $DEBUG)
	$AIGENERALLOG = (false && $DEBUG)
	# game dies when instruct is used
	# gastro acid can sometimes make kiriya skip turns?
	$movesToTargetAllies = ["HitThreeTimesAlwaysCriticalHit", "AlwaysCriticalHit",
							"RaiseTargetAttack2ConfuseTarget", "RaiseTargetSpAtk1ConfuseTarget", 
							"RaiseTargetAtkSpAtk2", "InvertTargetStatStages",
							#"TargetUsesItsLastUsedMoveAgain",
							"SetTargetAbilityToSimple", "SetTargetAbilityToUserAbility",
							"SetUserAbilityToTargetAbility", "SetTargetAbilityToInsomnia",
							"UserTargetSwapAbilities", #"NegateTargetAbility", 
							"RedirectAllMovesToTarget", "HitOncePerUserTeamMember", 
							"HealTargetDependingOnGrassyTerrain", "CureTargetStatusHealUserHalfOfTotalHP",
							"HealTargetHalfOfTotalHP", "HealAllyOrDamageFoe", "Rebalancing"] 

	#@battle.choices[index][0] = :UseMove   # Action
	#@battle.choices[index][1] = idxMove    # Index of move to be used
	#@battle.choices[index][2] = move       # Battle::Move object
	#@battle.choices[index][3] = -1         # Index of the target

	#=============================================================================
	# Main move-choosing method (moves with higher scores are more likely to be
	# chosen)
	#=============================================================================
	def pbChooseMoves(idxBattler)
		user        = @battle.battlers[idxBattler]
		wildBattler = user.wild? && !user.isBossPokemon?
		skill       = 100
		# if !wildBattler
		# 	skill     = @battle.pbGetOwnerFromBattlerIndex(user.index).skill_level || 0
		# end
		# Get scores and targets for each move
		# NOTE: A move is only added to the choices array if it has a non-zero
		#       score.
		choices     = []
		user.eachMoveWithIndex do |_m, i|
			next if !@battle.pbCanChooseMove?(idxBattler, i, false)
			if MEGA_EVO_MOVESET.key?(user.species) && $game_variables[MECHANICSVAR] >= 2
				oldmove = MEGA_EVO_MOVESET[user.species][0]
				newmove = MEGA_EVO_MOVESET[user.species][1]
				if _m.id == oldmove
					user.moves[i] = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(newmove))
					user.moves[i].pp       = 5
					user.moves[i].total_pp = 5
				end
			end
			if wildBattler
				pbRegisterMoveWild(user, i, choices)
			else
				pbRegisterMoveTrainer(user, i, choices, skill)
			end
		end
		if $AIGENERALLOG
			echo("\nChoices and scores for: "+user.name+" \n")
			Console.echo_h2(choices)
			echo("----------------------------------------\n")
		end
		# Figure out useful information about the choices
		totalScore = 0
		maxScore   = 0
		choices.each do |c|
			totalScore += c[1]
			echoln("#{c[3]} : #{c[1].to_s}") if !wildBattler && $AIGENERALLOG
			maxScore = c[1] if maxScore < c[1]
		end
		# Log the available choices
		if $INTERNAL
			logMsg = "[AI] Move choices for #{user.pbThis(true)} (#{user.index}): "
			choices.each_with_index do |c, i|
				logMsg += "#{user.moves[c[0]].name}=#{c[1]}"
				logMsg += " (target #{c[2]})" if c[2] >= 0
				logMsg += ", " if i < choices.length - 1
			end
			PBDebug.log(logMsg)
		end
		# if you gradually swap out all parts of a boat, is it still the same boat?
		if $AIMASTERLOG # master debug idea by JZ #by low
			fakeTarget = nil
			if $AIMASTERLOG_TARGET == 1 # ally
				user.allAllies.each do |b|
					next if !b.near?(user.index)
					fakeTarget = @battle.battlers[b.index]
				end
			else						# enemy
				fakeTarget = user.pbDirectOpposing
			end
			File.open("AI_master_log.txt", "a") do |line|
				line.puts "-----------------------------------------------------------------------"
				line.puts "                      Score Board for #{user.name}"
				line.puts "-----------------------------------------------------------------------"
			end
			move_keys = GameData::Move.keys
			bestscore = [["Atomic Splash",-991987]]
			move_keys.each do |i|
				break if fakeTarget.nil?
				mirrored = Pokemon::Move.new(i)
				mirrmove = Battle::Move.from_pokemon_move(@battle, mirrored)
				next if mirrored==nil
				next if !$movesToTargetAllies.include?(mirrmove.function) && $AIMASTERLOG_TARGET == 1
				next if ["AttackOneTurnLater", "DoesNothingUnusableInGravity", "DoesNothingCongratulations", "DoesNothingFailsIfNoAlly", "DoubleMoneyGainedFromBattle"].include?(mirrmove.function)
				case mirrmove.category
				when 0 then moveCateg = "Physical"
				when 1 then moveCateg = "Special"
				when 2 then moveCateg = "Status"
				end
				next if moveCateg.nil?
				
				fakeScore = pbGetMoveScore(mirrmove, user, fakeTarget, 100)
				fakeScore *= -1 if $AIMASTERLOG_TARGET == 1
				File.open("AI_master_log.txt", "a") do |line|
					line.puts "Move " + mirrored.name.to_s + " ( Category: " + moveCateg + " ) " + "has final score " + fakeScore.to_s
				end
				bestscore.push([mirrored.name.to_s, fakeScore])
			end

			sortedscores = bestscore.sort { |a, b| b[1] <=> a[1] }
			File.open("AI_scoreboard.txt", "a") do |line|
				line.puts "-----------------------------------------------------------------------"
				line.puts "                   High Score Board for #{user.name}"
				line.puts "-----------------------------------------------------------------------"
				for i in 0..sortedscores.length
					next if sortedscores[i].nil?
					next if sortedscores[i][0]=="Atomic Splash"
					line.puts "Move " + sortedscores[i][0].to_s + " has the final score " + sortedscores[i][1].to_s
				end
			end
		end
		# Find any preferred moves and just choose from them
		if !wildBattler && maxScore > 100
			#stDev = pbStdDev(choices)
			#if stDev >= 40 && pbAIRandom(100) < 90
			# DemICE removing randomness of AI
			preferredMoves = []
			choices.each do |c|
				next if c[1] < 200 && c[1] < maxScore * 0.8
				#preferredMoves.push(c)
				# DemICE prefer ONLY the best move
				preferredMoves.push(c) if c[1] == maxScore   # Doubly prefer the best move
				echoln(preferredMoves) if $AIGENERALLOG
			end
			if preferredMoves.length > 0
				m = preferredMoves[pbAIRandom(preferredMoves.length)]
				PBDebug.log("[AI] #{user.pbThis} (#{user.index}) prefers #{user.moves[m[0]].name}")
				@battle.pbRegisterMove(idxBattler, m[0], false)
				@battle.pbRegisterTarget(idxBattler, m[2]) if m[2] >= 0
				return
			end
			#end
		end
		choices.shuffle! if wildBattler
		# Decide whether all choices are bad, and if so, try switching instead
		if !user.wild? #!wildBattler
			badMoves = false
			attemptedSwitching = false
			if ((maxScore <= 60 && user.turnCount >= 1) ||
				(maxScore <= 70 && user.turnCount > 3))
				badMoves = true
			end
			if !badMoves && totalScore < 160
				badMoves = true
				choices.each do |c|
					next if !user.moves[c[0]].damagingMove?
					badMoves = false
					break
				end
			end
			if badMoves && pbEnemyShouldWithdrawEx?(idxBattler, true)
				attemptedSwitching = true
				if $INTERNAL
					PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will switch due to terrible moves 1")
				end
				return
			end
		end
		bestScore = ["Splash",0]
		# If there are no calculated choices, pick one at random
		if choices.length == 0
			PBDebug.log("[AI] #{user.pbThis} (#{user.index}) doesn't want to use any moves; picking one at random")
			user.eachMoveWithIndex do |_m, i|
				next if !@battle.pbCanChooseMove?(idxBattler, i, false)
				choices.push([i, 100, -1])   # Move index, score, target
			end
			if choices.length == 0   # No moves are physically possible to use; use Struggle
				@battle.pbAutoChooseMove(user.index)
			end
		else
			choices.each do |c|
				if bestScore[1] < c[1]
					bestScore[1] = c[1]
					bestScore[0] = c[0]
				end
			end
		end
		if bestScore[1] <= 60
			# in case everything sucks, try switching (again)
			if !user.wild? && !attemptedSwitching && pbEnemyShouldWithdrawEx?(idxBattler, true)
				if $INTERNAL
					PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will switch due to terrible moves 2")
				end
				return
			end
			
			# if switching isnt a option, randomly choose a move from the choices and register it 
			randNum = pbAIRandom(totalScore)
			choices.each do |c|
				randNum -= c[1]
				next if randNum >= 0
				@battle.pbRegisterMove(idxBattler, c[0], false)
				@battle.pbRegisterTarget(idxBattler, c[2]) if c[2] >= 0
				break
			end
		else
			# Choose the best move possible always (if one thing does not suck)
			choices.each do |c|
				next if bestScore[0] != c[0]
				@battle.pbRegisterMove(idxBattler, c[0], false)
				@battle.pbRegisterTarget(idxBattler, c[2]) if c[2] >= 0
			end
		end
		# Log the result
		if @battle.choices[idxBattler][2]
			PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will use #{@battle.choices[idxBattler][2].name}")
		end
	end
  
	#=============================================================================
	# Get a score for the given move being used against the given target
	#=============================================================================
	def pbGetMoveScore(move, user, target, skill = 100)
		# Set up initial values
		# for 80 initScore, dmg move = OHKO if score = 230 
		skill = 100
		initScore = 80
		# Main score calcuations
		if move.damagingMove? && !(move.function == "HealAllyOrDamageFoe" && !user.opposes?(target))
			score = pbGetMoveScoreFunctionCode(initScore, move, user, target, skill)
			initScore = score
			# Adjust score based on how much damage it can deal # DemICE moved damage calc to the beginning
			score = pbGetMoveScoreDamage(score, move, user, target, skill, initScore)
		else # Status moves # each status move has a value tied to them
			statusDamage = pbStatusDamage(move)
			return 0 if statusDamage <= 0
			# Mult varies between 1.037x at 5 status dmg and 1.499x at 100 status dmg
			statusDamageMult = 1 + (0.5 / (1 + Math.exp(-0.1 * (statusDamage - 30))))
			score = initScore * statusDamageMult
			initScore = score
			score = pbGetMoveScoreFunctionCode(score, move, user, target, skill)
			# Prefer status moves if level difference is significantly high
			if user.level - 5 > target.level
				score *= 1.1
			else
				# Don't prefer set up moves if it was already used and still have raised stats
				if user.SetupMovesUsed.include?(move.id) && user.hasRaisedStatStages?
					score *= 0.7
				end
			end
			# Prefer Protect-like moves
			# IF future sight is about to hit and if best move does not KO
			# "ProtectRate" check is done above
			if ["ProtectUser", "ProtectUserBanefulBunker", "ProtectUserFromTargetingMovesSpikyShield", 
				"ProtectUserFromDamagingMovesKingsShield", "ProtectUserFromDamagingMovesObstruct"].include?(move.function)
				roughFSDamage = futureSightRoughDamage(user, target, skill)
				if roughFSDamage > 0
					miniscore = 1 + (roughFSDamage / target.hp)
					bestmove = bestMoveVsTarget(user,target,skill) # [maxdam,maxmove,maxprio,physorspec]
					maxmove = bestmove[1]
					if targetSurvivesMove(maxmove,user,target)
						miniscore *= 1.2
					else
						miniscore *= 0.8
					end
					echoln "score for protect+FS #{miniscore}" if $AIGENERALLOG
					score *= miniscore
				end
			end
		end
		if $AIMASTERLOG
			File.open("AI_master_log.txt", "a") do |line|
				line.puts "Move " + move.name.to_s + " has initial score " + initScore.to_s
			end
		end
		# Account for the accuracy of the move
		accuracy = pbRoughAccuracy(move, user, target, skill)
		accuracy = 100 if accuracy > 100
		score -= (100 - accuracy) * (4 / 3.0) if accuracy < 100
		# A score of 0 here means it should not be used 
		# ...unless it is a good move to target allies, which are stored on the negatives
		return 0 if score <= 0 && !$movesToTargetAllies.include?(move.function)
		# DemICE Converted all score alterations to multiplicative
		# Don't prefer moves that directly affect the target if they'd be semi-invulnerable
		target_data = move.pbTarget(user)
		if ![:User, :UserSide, :UserAndAllies, :AllAllies, :AllBattlers, :FoeSide].include?(target_data.id)
			if target.semiInvulnerable? || target.effects[PBEffects::SkyDrop] >= 0
				aspeed = pbRoughStat(user,:SPEED,skill)
				ospeed = pbRoughStat(target,:SPEED,skill)
				miss = true
				miss = false if user.hasActiveAbility?(:NOGUARD) || target.hasActiveAbility?(:NOGUARD)
				miss = false if ((aspeed<=ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) && priorityAI(user,move)<1 # DemICE
				if miss && aspeed > ospeed
					# Knows what can get past semi-invulnerability
					if target.effects[PBEffects::SkyDrop] >= 0 ||
					   target.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
												"TwoTurnAttackInvulnerableInSkyParalyzeTarget",
												"TwoTurnAttackInvulnerableInSkyTargetCannotAct")
						miss = false if move.hitsFlyingTargets?
					elsif target.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground")
						miss = false if move.hitsDiggingTargets?
					elsif target.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderwater")
						miss = false if move.hitsDivingTargets?
					end
				end
				score *= 0.2 if miss
			end
		end
		# Pick a good move for the Choice items
		if user.hasActiveItem?([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF]) ||
		   user.hasActiveAbility?(:GORILLATACTICS)
			if move.baseDamage >= 60
				score *= 1.3
			elsif move.damagingMove?
				score *= 1.1
			elsif move.function == "UserTargetSwapItems" && !user.hasActiveAbility?(:GORILLATACTICS)
				score *= 1.2  # Trick
			else
				score *= 0.8
			end
		end
		# If user is asleep, prefer moves that are usable while asleep
		# DemICE check if it'll wake up this turn
		if user.status == :SLEEP && user.statusCount > 1
			if move.usableWhenAsleep?
				score *= 2
			else
				score *= 0.5
			end
		end
		# If user has Truant, prefer moves that are usable while truanting
		if user.hasActiveAbility?(:TRUANT) && user.effects[PBEffects::Truant]
			if move.healingMove?
				score *= 2
			else
				score *= 0.5
			end
		end
		# Don't prefer moves that are ineffective because of abilities or effects
		return 0 if pbCheckMoveImmunity(score, move, user, target, skill)
		score = score.to_i
		score = 0 if score < 0 && !$movesToTargetAllies.include?(move.function)
		return score
	end

	#=============================================================================
	# Add to a move's score based on how much damage it will deal (as a percentage
	# of the target's current HP)
	#=============================================================================
	def pbGetMoveScoreDamage(score, move, user, target, skill, initialscore = 0)
		return 0 if (score <= 0 && !($movesToTargetAllies.include?(move.function) && !user.opposes?(target)))
		# Calculate how much damage the move will do (roughly)
		baseDmg = pbMoveBaseDamage(move, user, target, skill)
		realDamage = pbRoughDamage(move, user, target, skill, baseDmg)
		mold_broken=moldbroken(user,target,move)

		# Try make AI not trolled by disguise
		# priority over other calcs due to hyper beam
		if target.hasActiveAbility?(:DISGUISE,false,mold_broken) && target.form == 0	
			if ["HitTwoTimes", "HitTwoTimesReload", "HitTwoTimesFlinchTarget",
				 "HitTwoTimesTargetThenTargetAlly", "HitTwoTimesPoisonTarget",
				 "HitTwoToFiveTimes", "HitTwoToFiveTimesOrThreeForAshGreninja",
				 "HitTwoToFiveTimesRaiseUserSpd1LowerUserDef1",
				 "HitThreeToFiveTimes", "HitThreeTimesPowersUpWithEachHit", 
				 "HitThreeTimesAlwaysCriticalHit"].include?(move.function)
				realDamage*=2.2
			else
				realDamage=(target.totalhp / 8.0)
			end
		end	

		# Two-turn attacks waste 2 turns to deal one lot of damage
		# Not halved because semi-invulnerable during use or hits first turn
		if ((["TwoTurnAttackFlinchTarget", "TwoTurnAttackParalyzeTarget", "TwoTurnAttackBurnTarget", 
			  "TwoTurnAttackChargeRaiseUserDefense1", "TwoTurnAttackChargeRaiseUserSpAtk1", 
			  "AttackTwoTurnsLater", "TwoTurnAttack"].include?(move.function) ||
			  (move.function == "TwoTurnAttackOneTurnInSun" && ![:Sun, :HarshSun].include?(user.effectiveWeather))) && 
			  !user.hasActiveItem?(:POWERHERB))
			realDamage *= (2 / 3.0)
		end
		# Special interaction for beeg guns hyper beam clones
		if move.function == "AttackAndSkipNextTurn"
			if [:PRISMATICLASER, :ETERNABEAM].include?(move.id) && !targetSurvivesMove(move,user,target)
			else
				realDamage *= (2 / 3.0)
			end
		end
		# Self-KO moves should avoided (under normal circumstances) if possible
		if ["UserFaintsExplosive", "UserFaintsPowersUpInMistyTerrainExplosive", 
			"UserFaintsFixedDamageUserHP"].include?(move.function) ||
		   (["UserLosesHalfOfTotalHPExplosive", "UserLosesHalfOfTotalHP"].include?(move.function) && user.takesIndirectDamage?)
			if user.hasActiveAbility?(:PARTYPOPPER)
				innatemove = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(:HEALINGWISH))
				innatescore = (pbGetMoveScore(innatemove, user, target, skill) / 2)
				innatescore > 0 ? (score += innatescore) : (realDamage *= (2 / 3.0))
				echoln "#{move.name}'s score (#{score}) was boosted due to party popper. #{innatescore}" if $AIGENERALLOG
			else
				if user.allAllies.none? { |b| b.hasActiveAbility?(:SEANCE) }
					realDamage *= (2 / 3.0)
				end
			end
		end

		# not a fan of randomness one bit, but i cant do much about this move
		# Try play "mind games" instead of just getting baited every time.
		if move.function == "FailsIfTargetActed"
			if @battle.choices[target.index][0]!=:UseMove
				if pbAIRandom(100) < 80	
					echo("\n'Predicting' that opponent will not attack and sucker will fail")
					score=1
					realDamage=0
				end
			else
				if @battle.choices[target.index][1]
					if !@battle.choices[target.index][2].damagingMove? && pbAIRandom(100) < 66	
						echo("\n'Predicting' that opponent will not attack and sucker will fail")
						score=1
						realDamage=0 
					end
				end
			end
		end

		# Prefer flinching external effects (note that move effects which cause
		# flinching are dealt with in the function code part of score calculation)
		if canFlinchTarget(user,target,mold_broken)
			bestmove=bestMoveVsTarget(user,target,skill) # [maxdam,maxmove,maxprio,physorspec]
			maxdam=bestmove[0] #* 0.9
			maxmove=bestmove[1]
			if targetSurvivesMove(maxmove,user,target)
				realDamage *= 1.2 if (realDamage * 100.0 / maxdam) > 75
				realDamage *= 1.2 if move.function == "HitTwoTimesFlinchTarget"
				realDamage *= 1.1 if user.hasActiveItem?([:KINGSROCK,:RAZORFANG]) || user.hasActiveAbility?(:STENCH)
				realDamage *= 2.0 if user.hasActiveAbility?(:SERENEGRACE) || user.pbOwnSide.effects[PBEffects::Rainbow] > 0
			end
		end

		# taking in account the damage of future sight/doom desire/premoniton
		roughFSDamage = futureSightRoughDamage(user, target, skill)
		if roughFSDamage > 0
			echoln "rough dmg for FS #{roughFSDamage}" if $AIGENERALLOG
			realDamage += roughFSDamage
		end 
		realDamage = realDamage.to_i
		if $AIMASTERLOG
			File.open("AI_master_log.txt", "a") do |line|
				line.puts "Move " + move.name + " real damage on "+target.name+": "+realDamage.to_s
			end
		end

		# Convert damage to percentage of target's remaining HP
		damagePercentage = realDamage * 100.0 / target.hp
		# Don't prefer weak attacks
	    damagePercentage *= 0.5 if damagePercentage < 30
		# Prefer status moves if level difference is significantly high
		damagePercentage *= 0.5 if user.level - 5 > target.level
		# Adjust score
		if damagePercentage > 100   # Treat all lethal moves the same # DemICE
			damagePercentage = 110 
			damagePercentage += 40 # Prefer moves likely to be lethal # DemICE
			if ["RaiseUserAttack2IfTargetFaints", "RaiseUserAttack3IfTargetFaints"].include?(move.function) # DemICE: Fell Stinger should be preferred among other moves that KO
				if user.hasActiveAbility?(:CONTRARY)
					damagePercentage-=90    
				else
					damagePercentage+=50    
				end
			end
		end
		if ["HealUserByHalfOfDamageDone","HealUserByThreeQuartersOfDamageDone"].include?(move.function) ||
			(move.function == "HealUserByHalfOfDamageDoneIfTargetAsleep" && target.asleep?)
			missinghp = (user.totalhp-user.hp) * 100.0 / user.totalhp
			if target.hasActiveAbility?(:LIQUIDOOZE)
				damagePercentage -= missinghp*0.5
			else
				damagePercentage += missinghp*0.5
			end
		end
		damagePercentage = damagePercentage.to_i
		score += damagePercentage
		if $AIGENERALLOG
			echo("\n-----------------------------")
			echo("\n#{move.name} score before dmg = #{initialscore}")
			echo("\n#{move.name} real dmg = #{realDamage}")
			echo("\n#{move.name} dmg percent = #{damagePercentage}%%")
			echo("\n#{move.name} score = #{score}")
		end
		if $AIMASTERLOG
			File.open("AI_master_log.txt", "a") do |line|
				line.puts "Move " + move.name + " damage % on "+target.name+": "+damagePercentage.to_s+"%"
			end
		end
		return score
	end
end