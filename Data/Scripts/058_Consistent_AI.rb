class Battle::AI
	#=============================================================================
	# Main move-choosing method (moves with higher scores are more likely to be
	# chosen)
	#=============================================================================
	def pbChooseMoves(idxBattler)
		user        = @battle.battlers[idxBattler]
		wildBattler = user.wild?
		skill       = 0
		if !wildBattler
			skill     = @battle.pbGetOwnerFromBattlerIndex(user.index).skill_level || 0
		end
		# Get scores and targets for each move
		# NOTE: A move is only added to the choices array if it has a non-zero
		#       score.
		choices     = []
		user.eachMoveWithIndex do |_m, i|
			next if !@battle.pbCanChooseMove?(idxBattler, i, false)
			if wildBattler
				pbRegisterMoveWild(user, i, choices)
			else
				pbRegisterMoveTrainer(user, i, choices, skill)
			end
		end
		#~ Console.echo_h2(choices)
		# Figure out useful information about the choices
		totalScore = 0
		maxScore   = 0
		choices.each do |c|
			totalScore += c[1]
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
			Console.echo_h2(logMsg)
		end
		if $INTERNAL # master debug by JZ, ported #by low
			move_keys = GameData::Move.keys
			bestscore = ["Splash",0]
			move_keys.each do |i|
				mirrored = Pokemon::Move.new(i)
				mirrmove = Battle::Move.from_pokemon_move(@battle, mirrored)
				next if mirrored==nil
				target = user.pbDirectOpposing
				dmgValue = pbRoughDamage(mirrmove, user, target, skill, mirrmove.baseDamage)
				if mirrmove.baseDamage == 0
					dmgPercent = pbStatusDamage(mirrmove)
				else
					dmgPercent = (dmgValue*100)/(target.hp)
					dmgPercent = 110 if dmgPercent > 110 
				end
				File.open("AI_master_log.txt", "a") do |line|
					line.puts "Move " + i.to_s + " aka " + mirrored.name.to_s + " has rough damage " + dmgValue.to_s + " and damage % " + dmgPercent.to_s + " has the function " + mirrmove.function
				end
				score = pbGetMoveScore(mirrmove, user, target, skill, dmgPercent)
				File.open("AI_master_log.txt", "a") do |line|
					line.puts "Move " + i.to_s + " aka " + mirrored.name.to_s + " has final score " + score.to_s
				end
				if bestscore[1] < score
					bestscore[1] = score
					bestscore[0] = mirrored.name.to_s
				end
			end
			File.open("AI_master_log.txt", "a") do |line|
				line.puts "Move " + bestscore[0].to_s + " has the best final score " + bestscore[1].to_s
			end
		end
		# Find any preferred moves and just choose from them
		if !wildBattler && skill >= PBTrainerAI.highSkill && maxScore > 100
			#stDev = pbStdDev(choices)
			#if stDev >= 40 && pbAIRandom(100) < 90
			# DemICE removing randomness of AI
				preferredMoves = []
				choices.each do |c|
					next if c[1] < 200 && c[1] < maxScore * 0.8
					#preferredMoves.push(c)
					# DemICE prefer ONLY the best move
					preferredMoves.push(c) if c[1] == maxScore   # Doubly prefer the best move
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
		# Decide whether all choices are bad, and if so, try switching instead
		if !wildBattler && skill >= PBTrainerAI.highSkill
			badMoves = false
			if ((maxScore <= 20 && user.turnCount > 2) ||
					(maxScore <= 40 && user.turnCount > 5)) #&& pbAIRandom(100) < 80  # DemICE removing randomness
				badMoves = true
			end
			if !badMoves && totalScore < 100 && user.turnCount >= 1
				badMoves = true
				choices.each do |c|
					next if !user.moves[c[0]].damagingMove?
					badMoves = false
					break
				end
				#badMoves = false if badMoves && pbAIRandom(100) < 10 # DemICE removing randomness
			end
			if badMoves && pbEnemyShouldWithdrawEx?(idxBattler, true)
				if $INTERNAL
					PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will switch due to terrible moves")
				end
				return
			end
		end
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
		end
		# Randomly choose a move from the choices and register it
		randNum = pbAIRandom(totalScore)
		choices.each do |c|
			randNum -= c[1]
			next if randNum >= 0
			@battle.pbRegisterMove(idxBattler, c[0], false)
			@battle.pbRegisterTarget(idxBattler, c[2]) if c[2] >= 0
			break
		end
		# Log the result
		if @battle.choices[idxBattler][2]
			PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will use #{@battle.choices[idxBattler][2].name}")
		end
	end
  
	#=============================================================================
	# Get a score for the given move being used against the given target
	#=============================================================================
	def pbGetMoveScore(move, user, target, skill = 100, roughdamage = 10)
		PBDebug.log(sprintf("%s: initial score: %d",move.name,roughdamage)) if $INTERNAL
		skill = PBTrainerAI.minimumSkill if skill < PBTrainerAI.minimumSkill
		if roughdamage <= 1
      roughdamage = 1
    end
		score = roughdamage
		score = pbGetMoveScoreFunctionCode(score, move, user, target, skill)
		accuracy = pbRoughAccuracy(move, user, target, skill)
		accuracy *= 1.15 if !user.pbOwnedByPlayer?
		accuracy = 100 if accuracy>100
		# A score of 0 here means it absolutely should not be used
		return 0 if score <= 0
		# Adjust score based on how much damage it can deal
		# DemICE moved damage calculation to the beginning
		if move.damagingMove?
			score = pbGetMoveScoreDamage(score, move, user, target, skill)
		else   # Status moves
			# Don't prefer attacks which don't deal damage # <- why are you cringe?
			score = pbStatusDamage(move) # each status move now has a value tied to them #by low
			# Account for accuracy of move
			accuracy = pbRoughAccuracy(move, user, target, skill)
			score *= accuracy / 100.0
			score = 0 if score <= 10 && skill >= PBTrainerAI.highSkill
		end
		aspeed = pbRoughStat(user,:SPEED,100)
		ospeed = pbRoughStat(target,:SPEED,100)
		if skill >= PBTrainerAI.mediumSkill
			# Converted all score alterations to multiplicative
			# Don't prefer attacking the target if they'd be semi-invulnerable
			if skill >= PBTrainerAI.highSkill && move.accuracy > 0 &&
				 (target.semiInvulnerable? || target.effects[PBEffects::SkyDrop] >= 0)
				miss = true
				miss = false if user.hasActiveAbility?(:NOGUARD) || target.hasActiveAbility?(:NOGUARD)
				miss = false if ((aspeed<=ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) && priorityAI(user,move)<1 # DemICE
				if miss && pbRoughStat(user, :SPEED, skill) > pbRoughStat(target, :SPEED, skill)
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
			# Pick a good move for the Choice items
			if user.hasActiveItem?([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF]) ||
				 user.hasActiveAbility?(:GORILLATACTICS)
				if move.baseDamage >= 60
					score *= 1.2
				elsif move.damagingMove?
					score *= 1.2
				elsif move.function == "UserTargetSwapItems"
					score *= 1.2  # Trick
				else
					score *= 0.8
				end
			end
			# If user is asleep, prefer moves that are usable while asleep
			if user.status == :SLEEP && !move.usableWhenAsleep? && user.statusCount==1 # DemICE check if it'll wake up this turn
				user.eachMove do |m|
					next unless m.usableWhenAsleep?
					score *= 2
					break
				end
			end
			# truant can, in fact, do something when loafing around
			if user.hasActiveAbility?(:TRUANT) && user.effects[PBEffects::Truant]
				user.eachMove do |m|
					next unless m.healingMove?
					score *= 2
					break
				end
			end
		end
		# Don't prefer moves that are ineffective because of abilities or effects
		return 0 if pbCheckMoveImmunity(score, move, user, target, skill)
		score = score.to_i
		score = 0 if score < 0
		return score
	end

	#=============================================================================
	# Add to a move's score based on how much damage it will deal (as a percentage
	# of the target's current HP)
	#=============================================================================
	def pbGetMoveScoreDamage(score, move, user, target, skill)
		return 0 if score <= 0
		# Calculate how much damage the move will do (roughly)
		baseDmg = pbMoveBaseDamage(move, user, target, skill)
		realDamage = pbRoughDamage(move, user, target, skill, baseDmg)
		# Account for accuracy of move
		accuracy = pbRoughAccuracy(move, user, target, skill)
		accuracy *= 1.15 if !user.pbOwnedByPlayer?
		accuracy = 100 if accuracy > 100
		#realDamage *= accuracy / 100.0 # DemICE
		# Two-turn attacks waste 2 turns to deal one lot of damage
		if ((["TwoTurnAttackFlinchTarget", "TwoTurnAttackParalyzeTarget", 
					"TwoTurnAttackBurnTarget", "TwoTurnAttackChargeRaiseUserDefense1", "TwoTurnAttack", 
					"AttackTwoTurnsLater", "TwoTurnAttackChargeRaiseUserSpAtk1"].include?(move.function) ||
					(move.function=="TwoTurnAttackOneTurnInSun" && user.effectiveWeather!=:Sun)) && !user.hasActiveItem?(:POWERHERB)) ||
			move.function == "AttackAndSkipNextTurn"
		  realDamage *= 2 / 3   # Not halved because semi-invulnerable during use or hits first turn
		end
		# Prefer flinching external effects (note that move effects which cause
		# flinching are dealt with in the function code part of score calculation)
		mold_broken=moldbroken(user,target,move)
		if skill >= PBTrainerAI.mediumSkill 
			if move.function == "FailsIfTargetActed" # Sucker Punch
				if @battle.choices[0][0]!=:UseMove
					chance=80
					if pbAIRandom(100) < chance	# Try play "mind games" instead of just getting baited every time.
						echo("\n'Predicting' that opponent will not attack and sucker will fail")
						score=1
						realDamage=0
					end
				else
					if @battle.choices[0][1]
						if !@battle.choices[0][2].damagingMove? && pbAIRandom(100) < 50	# Try play "mind games" instead of just getting baited every time.
							echo("\n'Predicting' that opponent will not attack and sucker will fail")
							score=1
							realDamage=0 
						end
					end
				end
			end
			# Try make AI not trolled by disguise
			if !mold_broken && target.hasActiveAbility?(:DISGUISE) && target.turnCount==0	
				if ["HitTwoToFiveTimes", "HitTwoTimes", "HitThreeTimes" ,"HitTwoTimesFlinchTarget", 
						"HitThreeTimesPowersUpWithEachHit", "HitTenTimesPopulationBomb"].include?(move.function)
					realDamage*=2.2
				end
			end	
			if ((!target.hasActiveAbility?(:INNERFOCUS) && !target.hasActiveAbility?(:SHIELDDUST)) || mold_broken) &&
				target.effects[PBEffects::Substitute]==0
				canFlinch = false
				if user.hasActiveItem?([:KINGSROCK,:RAZORFANG])
					canFlinch = true
				end
				if user.hasActiveAbility?(:STENCH) || move.flinchingMove?
					canFlinch = true
				end
				canFlinch = false if target.effects[PBEffects::NoFlinch] > 0
				bestmove=bestMoveVsTarget(user,target,skill) # [maxdam,maxmove,maxprio,physorspec]
				maxdam=bestmove[0] #* 0.9
				maxmove=bestmove[1]
				if targetSurvivesMove(maxmove,user,target) && canFlinch
					realDamage *= 1.2 if (realDamage *100.0 / maxdam) > 75
					realDamage *= 1.2 if move.function=="HitTwoTimesFlinchTarget"
					realDamage*=2 if user.hasActiveAbility?(:SERENEGRACE)
				end
			end
		end
		# Convert damage to percentage of target's remaining HP
		damagePercentage = realDamage * 100.0 / target.hp
		# Don't prefer weak attacks
	  #   damagePercentage /= 2 if damagePercentage<20
		# Prefer damaging attack if level difference is significantly high
		#damagePercentage *= 1.2 if user.level - 10 > target.level
		# Adjust score
		if damagePercentage > 100   # Treat all lethal moves the same   # DemICE
			damagePercentage = 110 
			if ["RaiseUserAttack3IfTargetFaints"].include?(move.function) # DemICE: Fell Stinger should be preferred among other moves that KO
				if user.hasActiveAbility?(:CONTRARY)
					damagePercentage-=90    
				else
					damagePercentage+=50    
				end
			end
			if ["HealUserByHalfOfDamageDone","HealUserByThreeQuartersOfDamageDone"].include?(move.function) ||
				(move.function == "HealUserByHalfOfDamageDoneIfTargetAsleep" && target.asleep?)
				missinghp = (user.totalhp-user.hp) *100.0 / user.totalhp
				damagePercentage += missinghp*0.5
			end
		end  
		#~ damagePercentage -= 1 if accuracy < 100  # DemICE
		#damagePercentage += 40 if damagePercentage > 100   # Prefer moves likely to be lethal  # DemICE
		score += damagePercentage.to_i
		return score
	end
end

=begin
class Battle::AI
	def pbEnemyShouldWithdrawEx?(idxBattler, forceSwitch)
		return false if @battle.wildBattle?
		return false if @battle.pbSideSize(idxBattler) == 1
		shouldSwitch = forceSwitch
		batonPass = -1
		moveType = nil
		skill = @battle.pbGetOwnerFromBattlerIndex(idxBattler).skill_level || 0
		battler = @battle.battlers[idxBattler]
		# If Pokémon is within 6 levels of the foe, and foe's last move was
		# super-effective and powerful
		if !shouldSwitch && battler.turnCount > 0 && skill >= PBTrainerAI.highSkill
			target = battler.pbDirectOpposing(true)
			if !target.fainted? && target.lastMoveUsed &&
				(target.level - battler.level).abs <= 6
				moveData = GameData::Move.get(target.lastMoveUsed)
				moveType = moveData.type
				typeMod = pbCalcTypeMod(moveType, target, battler)
				if Effectiveness.super_effective?(typeMod) && moveData.base_damage > 50
					switchChance = (moveData.base_damage > 70) ? 30 : 20
					shouldSwitch = true if switchChance>80 #(pbAIRandom(100) < switchChance) # DemICE removing randomness
				end
			end
		end
		# Pokémon can't do anything (must have been in battle for at least 5 rounds)
		if !@battle.pbCanChooseAnyMove?(idxBattler) &&
			battler.turnCount && battler.turnCount >= 5
			shouldSwitch = true
		end
		# Pokémon is Perish Songed and has Baton Pass
		if skill >= PBTrainerAI.highSkill && battler.effects[PBEffects::PerishSong] == 1
			battler.eachMoveWithIndex do |m, i|
				next if m.function != "SwitchOutUserPassOnEffects"   # Baton Pass
				next if !@battle.pbCanChooseMove?(idxBattler, i, false)
				batonPass = i
				break
			end
		end
		# Pokémon will faint because of bad poisoning at the end of this round, but
		# would survive at least one more round if it were regular poisoning instead
		#   if battler.status == :POISON && battler.statusCount > 0 &&
		#      skill >= PBTrainerAI.highSkill
		#     toxicHP = battler.totalhp / 16
		#     nextToxicHP = toxicHP * (battler.effects[PBEffects::Toxic] + 1)
		#     if battler.hp <= nextToxicHP && battler.hp > toxicHP * 2 #&& pbAIRandom(100) < 80 # DemICE removing randomness
		#       shouldSwitch = true
		#     end
		#   end
		# Pokémon is Encored into an unfavourable move
		if battler.effects[PBEffects::Encore] > 0 && skill >= PBTrainerAI.mediumSkill
			idxEncoredMove = battler.pbEncoredMoveIndex
			if idxEncoredMove >= 0
				scoreSum   = 0
				scoreCount = 0
				battler.allOpposing.each do |b|
					scoreSum += pbGetMoveScore(battler.moves[idxEncoredMove], battler, b, skill)
					scoreCount += 1
				end
				if scoreCount > 0 && scoreSum / scoreCount <= 20 #&& pbAIRandom(100) < 80 # DemICE removing randomness
					shouldSwitch = true
				end
			end
		end
		# If there is a single foe and it is resting after Hyper Beam or is
		# Truanting (i.e. free turn)
		# if @battle.pbSideSize(battler.index + 1) == 1 &&
		# 	!battler.pbDirectOpposing.fainted? && skill >= PBTrainerAI.highSkill
		# 	opp = battler.pbDirectOpposing
		# 	if (opp.effects[PBEffects::HyperBeam] > 0 ||
		# 			(opp.hasActiveAbility?(:TRUANT) && opp.effects[PBEffects::Truant])) #&& pbAIRandom(100) < 80 # DemICE removing randomness
		# 		shouldSwitch = false
		# 	end
		# end
		# Sudden Death rule - I'm not sure what this means
		if @battle.rules["suddendeath"] && battler.turnCount > 0
			if battler.hp <= battler.totalhp / 4 #&& pbAIRandom(100) < 30 # DemICE removing randomness
				shouldSwitch = true
			elsif battler.hp <= battler.totalhp / 2 #&& pbAIRandom(100) < 80 # DemICE removing randomness
				shouldSwitch = true
			end
		end
		# Pokémon is about to faint because of Perish Song
		if battler.effects[PBEffects::PerishSong] == 1
			shouldSwitch = true
		end
		incoming = [nil,0]
		weight = 1
		if shouldSwitch
			idxPartyStart, idxPartyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
			@battle.pbParty(idxBattler).each_with_index do |pkmn, i|
				#next if i == idxPartyEnd - 1   # Don't choose to switch in ace
				next if !@battle.pbCanSwitch?(idxBattler, i)
				# If perish count is 1, it may be worth it to switch
				# even with Spikes, since Perish Song's effect will end
				if battler.effects[PBEffects::PerishSong] != 1
					# Will contain effects that recommend against switching
					spikes = battler.pbOwnSide.effects[PBEffects::Spikes]
					# Don't switch to this if too little HP
					if spikes > 0
						spikesDmg = [8, 6, 4][spikes - 1]
						next if pkmn.hp <= pkmn.totalhp / spikesDmg &&
						!pkmn.hasType?(:FLYING) && !pkmn.hasActiveAbility?(:LEVITATE)
					end
				end
				# moveType is the type of the target's last used move
				if moveType && Effectiveness.ineffective?(pbCalcTypeMod(moveType, battler, battler))
					weight = 65
					typeMod = pbCalcTypeModPokemon(pkmn, battler.pbDirectOpposing(true))
					if Effectiveness.super_effective?(typeMod)
						# Greater weight if new Pokemon's type is effective against target
						weight = 85
					end
					#list.unshift(i) if pbAIRandom(100) < weight   # Put this Pokemon first # DemICE removing randomness
				elsif moveType && Effectiveness.resistant?(pbCalcTypeMod(moveType, battler, battler))
					weight = 40
					typeMod = pbCalcTypeModPokemon(pkmn, battler.pbDirectOpposing(true))
					if Effectiveness.super_effective?(typeMod)
						# Greater weight if new Pokemon's type is effective against target # DemICE removing randomness
						weight = 60
					end
					#list.unshift(i) if pbAIRandom(100) < weight   # Put this Pokemon first # DemICE removing randomness
				else
					#list.push(i)   # put this Pokemon last # DemICE removing randomness
				end
				incoming=[i,weight] if weight > incoming[1]
			end
			#if list.length > 0 # DemICE removing randomness
			if batonPass >= 0 && @battle.pbRegisterMove(idxBattler, batonPass, false)
				PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will use Baton Pass to avoid Perish Song")
				return true
			end
			if @battle.pbRegisterSwitch(idxBattler, incoming[0])
				PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will switch with " +
					@battle.pbParty(idxBattler)[incoming[0]].name)
				return true
			end
			#end
		end
		return false
	end
end
class Battle::AI
	alias stupidity_pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode
	def pbGetMoveScoreFunctionCode(score, move, user, target, skill = 100)
		case move.function
		#---------------------------------------------------------------------------
		when "FlinchTargetFailsIfNotUserFirstTurn"
			if user.turnCount == 0
				if skill >= PBTrainerAI.highSkill
					score +=120 if !target.hasActiveAbility?(:INNERFOCUS) && target.effects[PBEffects::Substitute] == 0
				end
			else
				score -= 90   # Because it will fail here
				score = 0 if skill >= PBTrainerAI.bestSkill
			end
		else
			score = stupidity_pbGetMoveScoreFunctionCode(score, move, user, target, skill)
		end
			# found=false
			# if !move.damagingMove?
			#     for i in user.moves
			#         dmg=pbGetMoveScoreDamage(1, i, user, target, skill)
			#         found if dmg > 50
			#     end  
			#     score *=2 if !found
			# end     
		return score
	end
end
=end