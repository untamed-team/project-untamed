class Battle::AI
# added the new status nerf if $game_variables[MECHANICSVAR] is above or equal to 3 #by low
  #=============================================================================
  # Get a score for the given move based on its effect
  #=============================================================================
  alias aiEffectScorePart3_pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode

  def pbGetMoveScoreFunctionCode(score, move, user, target, skill = 100)
	mold_broken = moldbroken(user,target,move)
	globalArray = pbGetMidTurnGlobalChanges
	aspeed = pbRoughStat(user,:SPEED,skill)
	ospeed = pbRoughStat(target,:SPEED,skill)
	userFasterThanTarget = ((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
    case move.function
    #---------------------------------------------------------------------------
    when "ProtectUser"
		score*=1.3 if globalArray.any? { |element| element.include?("weather") }
		if target.turnCount==0
			score*=1.5
		end
		if pbHasSetupMove?(target, false)
			score*=0.3
		end
		if user.hasActiveAbility?(:SPEEDBOOST) && 
		   aspeed > ospeed && @battle.field.effects[PBEffects::TrickRoom]==0
			score*=4
		end
		if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true)) || 
		   user.effects[PBEffects::Ingrain] || user.effects[PBEffects::AquaRing] || 
		   @battle.field.terrain == :Grassy
			score*=1.2
		end
		if user.poisoned? || user.burned?        
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
		movecheck=false
		for m in target.moves
			movecheck=true if ["RemoveProtections", "RemoveProtectionsBypassSubstitute", "HoopaRemoveProtectionsBypassSubstituteLowerUserDef1"].includes?(m.id)
		end
		score*=0.1 if movecheck
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		if user.effects[PBEffects::Wish]>0
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
			movecheck=false
			for m in target.moves
				movecheck=true if [:WILLOWISP, :THUNDERWAVE, :TOXIC, :BITINGCOLD, :CONFUSERAY].include?(m.id)
			end
			score*=0.7 if movecheck
		end
		score = 0 if user.effects[PBEffects::ProtectRate] > 1
    #---------------------------------------------------------------------------
    when "ProtectUserBanefulBunker" # baneful bunker
		score*=1.3 if globalArray.any? { |element| element.include?("weather") }
		if target.turnCount==0
			score*=1.5
		end        
		if pbHasSetupMove?(target, false)
			score*=0.3
		end
		if user.hasActiveAbility?(:SPEEDBOOST) && 
		   aspeed > ospeed && @battle.field.effects[PBEffects::TrickRoom]==0
			score*=4
		end
		if user.hasActiveItem?(:LEFTOVERS) || 
		   (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true)) || 
		   user.effects[PBEffects::Ingrain] || user.effects[PBEffects::AquaRing] || 
		   @battle.field.terrain == :Grassy
			score*=1.2
		end  
		if target.pbHasAnyStatus?
			score*=0.8
		else
			if target.pbCanPoison?(user, false)
				miniscore = pbTargetBenefitsFromStatus?(user, target, :POISON, 130, move, globalArray, 100)
				miniscore/=100.0
				score*=miniscore
			end
		end
		if user.poisoned? || user.burned?        
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
		movecheck=false
		for m in target.moves
			movecheck=true if m.ignoresSubstitute?(target)
			movecheck=true if ["RemoveProtections", "RemoveProtectionsBypassSubstitute", "HoopaRemoveProtectionsBypassSubstituteLowerUserDef1"].includes?(m.id)
		end
		score*=0.1 if movecheck
		contactcheck=false
		for m in target.moves
			contactcheck=true if m.pbContactMove?(user)
		end
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		if user.effects[PBEffects::Wish]>0
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
			movecheck=false
			for m in target.moves
				movecheck=true if [:WILLOWISP, :THUNDERWAVE, :TOXIC, :BITINGCOLD, :CONFUSERAY].include?(m.id)
			end
			score*=0.7 if movecheck
		end
		score = 0 if user.effects[PBEffects::ProtectRate] > 1
    #---------------------------------------------------------------------------
    when "ProtectUserFromTargetingMovesSpikyShield",
		 "ProtectUserFromDamagingMovesKingsShield",
		 "ProtectUserFromDamagingMovesObstruct"
		# Spiky Shield, King's Shield, Obstruct
		if target.turnCount==0
			score*=1.5
		end        
		if pbHasSetupMove?(target, false)
			score*=0.6
		end
		if user.hasActiveAbility?(:SPEEDBOOST) && 
		   aspeed > ospeed && @battle.field.effects[PBEffects::TrickRoom]==0
			score*=4
		end
		if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true)) || 
				user.effects[PBEffects::Ingrain] || user.effects[PBEffects::AquaRing] || 
				@battle.field.terrain == :Grassy
			score*=1.2
		end  
		if target.poisoned? || target.burned?        
			score*=1.2
			if target.effects[PBEffects::Toxic]>0
				score*=1.3
			end
		end
		if user.poisoned? || user.burned?        
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
			if !userFasterThanTarget && 
			   user.isSpecies?(:AEGISLASH) && user.form == 1
				score*=4
			else
				score*=0.8
			end
		end
		movecheck=false
		for m in target.moves
			movecheck=true if m.ignoresSubstitute?(target)
		end
		score*=0.1 if movecheck
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam = bestmove[0]
		contactcheck=false
		for m in target.moves
			contactcheck=true if m.pbContactMove?(user)
		end
		score*=1.3 if contactcheck
		if user.effects[PBEffects::Wish]>0
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
			movecheck=false
			for m in target.moves
				movecheck=true if [:WILLOWISP, :THUNDERWAVE, :TOXIC, :BITINGCOLD, :CONFUSERAY].include?(m.id)
			end
			score*=0.7 if movecheck
		end
		score = 0 if user.effects[PBEffects::ProtectRate] > 1
    #---------------------------------------------------------------------------
    when "ProtectUserSideFromDamagingMovesIfUserFirstTurn" # mat block
		healcheck = false
		for m in target.moves
			healcheck = true if m.healingMove?
		end
		setupcheck = false
		setupcheck = true if pbHasSetupMove?(target, false)
     	if user.turnCount == 0
			hasAlly = !user.allAllies.empty?
			if hasAlly
				score*=1.3
				if userFasterThanTarget
					score*=1.2
				else
					score*=0.7
					if userFasterThanTarget
						score*=0
					end
				end
				if setupcheck && healcheck
					score*=0.3
				end
				if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true)) || 
						user.effects[PBEffects::Ingrain] || user.effects[PBEffects::AquaRing] || 
						@battle.field.terrain == :Grassy
					score*=1.2
				end  
				if target.poisoned? || target.burned?        
					score*=1.2
					if target.effects[PBEffects::Toxic]>0
						score*=1.3
					end
				end
				if user.poisoned? || user.burned?        
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
		nodam = true
		for m in target.moves
			if m.baseDamage>0
				nodam=false
				break
			end
		end
		if nodam
			score *= 1.2
		end
		if user.hp==user.totalhp
			score *= 1.5
		end  
		movecheck = false
		movecheck = true if pbHasPhazingMove?(target)
		if movecheck
			score *= 1.3
		end
		hasAlly = !user.allAllies.empty?
		if hasAlly
			score *= 1.2
		else
			score *= 0.8
		end
		if targetWillMove?(target, "status")
			if !target.battle.choices[target.index][2].pbTarget(user).targets_all
				score *= 2
			end
		elsif user.lastMoveUsed == :CRAFTYSHIELD
			score*=0.5
		end
    #---------------------------------------------------------------------------
    when "ProtectUserSideFromPriorityMoves"
		if user.effects[PBEffects::ProtectRate] > 1
			score = 0
		else
			noprio = true
			ally = !user.allAllies.empty?
			for m in target.moves
				if m.priority > 0
					noprio = false
					break
				end
				if target.hasActiveAbility?(:GALEWINGS) && (target.hp >= (target.totalhp/2.0)) && m.type == :FLYING
					noprio = false
					break
				end
				if target.hasActiveAbility?(:PRANKSTER) && !user.pbHasType?(:DARK, true) && m.statusMove?
					noprio = false
					break
				end
				if target.hasActiveAbility?(:ECHOCHAMBER) && target.effects[PBEffects::PrioEchoChamber] > 0 && 
				   m.statusMove? && m.soundMove?
					noprio = false
					break
				end
				if target.hasActiveAbility?(:TRIAGE) && m.healingMove?
					noprio = false
					break
				end
			end
			if noprio
				score *= 0.5
			else
				score *= 1.2
			end
			if !ally
				score *= 0.8
			end
			if user.hp==user.totalhp
				score *= 1.5
			end          
			if targetWillMove?(target)
				if priorityAI(target,target.battle.choices[target.index][2]) > 0
					score *= 3
				end
			end
		end
    #---------------------------------------------------------------------------
    when "ProtectUserSideFromMultiTargetDamagingMoves"
		if user.effects[PBEffects::ProtectRate] > 1
			score = 0
		else
			nospread = true
			for m in target.moves
				if pbTargetsMultiple?(m, target)
					nospread = false
					break
				end
			end
			if !nospread
				score *= 0.5
			else
				score *= 1.2
			end
			if user.hp==user.totalhp
				score *= 1.5
			end
			if targetWillMove?(target)
				if pbTargetsMultiple?(target.battle.choices[target.index][2],user)
					score *= 3
				end
			end
		end
    #------------------------------------------------------------------------------------------------------------------------------------------------------
	# Actual Untamed exclusive moves
    #------------------------------------------------------------------------------------------------------------------------------------------------------
	when "UseUserBaseSpecialDefenseInsteadOfUserBaseSpecialAttack"
    #---------------------------------------------------------------------------
	when "Supernova"
    #---------------------------------------------------------------------------
	when "TitanWrath"
    #---------------------------------------------------------------------------
	when "Rebalancing"
		targetStats = target.plainStats
		highestStatValue = highestStatID = 0
		targetStats.each_value { |value| highestStatValue = value if highestStatValue < value }
		GameData::Stat.each_main_battle do |s|
			next if targetStats[s.id] < highestStatValue
			highestStatID = s.id
			break
		end
		if user.opposes?(target) # is enemy
			miniscore=100
			livecountuser 	 = @battle.pbAbleNonActiveCount(user.idxOwnSide)
			livecounttarget  = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
			case highestStatID # defense nerfs is just kind of whatever so i will skip them for now
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
				if livecounttarget==1 || user.hasActiveAbility?([:SHADOWTAG, :ARENATRAP]) || target.effects[PBEffects::MeanLook]>0
					miniscore*=1.4
				end
				if target.poisoned? || target.frozen?
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
				if target.burned? && !target.hasActiveAbility?(:GUTS)
					miniscore*=0.5
				end       
				if livecountuser==1
					miniscore*=0.5
				end
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
				if livecounttarget==1 || user.hasActiveAbility?([:SHADOWTAG, :ARENATRAP]) || target.effects[PBEffects::MeanLook]>0
					miniscore*=1.4
				end
				if target.poisoned? || target.burned?
					miniscore*=1.2
				end
				if target.frozen?
					miniscore*=0.5
				end
				if target.stages[:SPECIAL_ATTACK]<0
					minimini = 5*target.stages[:SPECIAL_ATTACK]
					minimini+=100
					minimini/=100.0
					miniscore*=minimini
				end       
				if livecountuser==1
					miniscore*=0.5
				end
			when :SPEED
				if livecounttarget==1 || user.hasActiveAbility?([:SHADOWTAG, :ARENATRAP]) || target.effects[PBEffects::MeanLook]>0
					miniscore*=1.3
				end
				if target.stages[:SPEED]<0
					minimini = 5*target.stages[:SPEED]
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
					trickrooom = false
					for j in target.moves
						if j.id == :TRICKROOM
							trickrooom = true
							break
						end
					end
					miniscore*=0.1 if trickrooom
				end
				if target.hasActiveItem?([:LAGGINGTAIL, :IRONBALL])
					miniscore*=0.1
				end
				electroballin = false
				for j in target.moves
					if j.id == :ELECTROBALL
						electroballin = true
						break
					end
				end
				miniscore*=1.3 if electroballin
				gyroballin = false
				for j in target.moves
					if j.id == :GYROBALL
						gyroballin = true
						break
					end
				end
				miniscore*=0.5 if gyroballin
			end
			if target.hasActiveAbility?([:COMPETITIVE, :DEFIANT, :CONTRARY])
				miniscore*=0.1
			end
			if target.hasActiveAbility?(:UNAWARE) && highestStatID != :SPEED
				miniscore*=0.1
			end
			miniscore/=100.0
			score*=miniscore
		else                     # is ally
			miniscore = -100 # neg due to being ally
			if !target.SetupMovesUsed.include?(move.id)
				if (1.0/target.totalhp)*target.hp < 0.6
					miniscore*=0.3
				end
				if target.effects[PBEffects::Attract]>=0 || target.paralyzed? || 
					target.effects[PBEffects::Yawn]>0 || target.asleep?
					miniscore*=0.3
				end
				if target.effects[PBEffects::Substitute]>0
					miniscore = 0
				end
				targetAlly = []
				user.allOpposing.each do |b|
					next if !b.near?(user.index)
					targetAlly.push(b.index)
				end
				if targetAlly.length > 0
					if ospeed > pbRoughStat(@battle.battlers[targetAlly[0]],:SPEED,skill) && 
						ospeed > pbRoughStat(@battle.battlers[targetAlly[1]],:SPEED,skill)
						miniscore*=1.3
					else
						miniscore*=0.7
					end
					if (@battle.battlers[targetAlly[0]].pbHasMove?(:FOULPLAY) || 
						@battle.battlers[targetAlly[1]].pbHasMove?(:FOULPLAY)) &&
						highestStatID == :ATTACK
						miniscore*=0.3
					end
				end
			else
				miniscore = 0
			end
			miniscore/=100.0
			score *= miniscore
		end
    #---------------------------------------------------------------------------
	when "HigherDamageInRain"
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
	when "OverrideTargetStatusWithPoison"
		if $game_variables[MECHANICSVAR] >= 2 && target.status == :NONE
			score *= 0.3
		elsif target.asleep? && target.statusCount <= 2
			score = 0
		elsif target.pbCanInflictStatus?(:POISON, user, false, self, true)
			miniscore = pbTargetBenefitsFromStatus?(user, target, :POISON, 90, move, globalArray, skill)
			score *= (miniscore / 100.0)
			score *= 1.2
			score *= 1.2 if user.hasActiveAbility?(:MERCILESS)
			score *= 1.2 if (target.hasActiveAbility?(:GUTS) && target.burned?) || target.hasActiveAbility?(:FLAREBOOST)
			score *= 0.6 if target.hasActiveAbility?(:SYNCHRONIZE) && target.pbCanPoisonSynchronize?(user)
			score = 0 if (target.hasActiveAbility?(:POISONHEAL) || target.hasActiveAbility?(:TOXICBOOST)) && !target.poisoned?
		else
			score *= 0.8
		end
    #---------------------------------------------------------------------------
	when "DoubleDamageIfTargetHasChoiceItem"
		if !target.unlosableItem?(target.item) && !target.hasActiveAbility?(:STICKYHOLD)
			if [:CHOICEBAND, :CHOICESPECS, :CHOICESCARF].include?(target.initialItem)
				score *= 1.3
				score *= 1.4 if aspeed <= ospeed && target.hasActiveItem?(:CHOICESCARF)
			end
		end
	#---------------------------------------------------------------------------
	when "PeperSpray"
		score *= 1.4 if [:Sun, :HarshSun].include?(user.effectiveWeather) || 
						(globalArray.include?("sun weather") && !user.hasActiveItem?(:UTILITYUMBRELLA))
    #---------------------------------------------------------------------------
    else
      return aiEffectScorePart3_pbGetMoveScoreFunctionCode(score, move, user, target, skill)
    end
    return score
  end
	
	# Utilities Check ############################################################
	
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
		for m in pokemon.moves
			if setuparray.include?(m.function)
				return true if (m.baseDamage == 0 || (m.addlEffect.to_f == 100 && countother))
			end
		end
	end
	
	def pbHasDebuffMove?(pokemon, countother = true)
		debuffarray = ["LowerTargetAttack1", "LowerTargetDefense1", "LowerTargetSpeed1", "LowerTargetSpAtk1", "LowerTargetSpDef1",
					   "LowerTargetAttack2", "LowerTargetDefense2", "LowerTargetSpeed2", "LowerTargetSpAtk2", "LowerTargetSpDef2",
					   "LowerTargetAttack3", "LowerTargetDefense3", "LowerTargetSpeed3", "LowerTargetSpAtk3", "LowerTargetSpDef3",
					   "LowerTargetEvasion1RemoveSideEffects", "LowerTargetAtkDef1", "LowerTargetSpAtk2IfCanAttract", 
					   "UserFaintsLowerTargetAtkSpAtk2", "LowerTargetAtkSpAtk1", "LowerPoisonedTargetAtkSpAtkSpd1"]
		for m in pokemon.moves
			if debuffarray.include?(m.function)
				return true if (m.baseDamage == 0 || (m.addlEffect.to_f == 100 && countother))
			end
		end
	end
	
	def pbHasSingleTargetProtectMove?(pokemon, countother = true)
		protectarray = ["ProtectUser", "ProtectUserBanefulBunker", 
						"ProtectUserFromTargetingMovesSpikyShield", 
						"ProtectUserFromDamagingMovesKingsShield",
						"ProtectUserFromDamagingMovesObstruct"]
		for m in pokemon.moves
			return true if protectarray.include?(m.function)
		end
	end
	
	def pbHasPivotMove?(pokemon, countother = true)
		pivotarray = [:UTURN, :FLIPTURN, :VOLTSWITCH, :PARTINGSHOT, :BATONPASS, :TELEPORT]
		for m in pokemon.moves
			return true if pivotarray.include?(m.id)
		end
		return true if pokemon.ability == :REGENERATOR && countother
	end
	
	def pbHasPhazingMove?(pokemon, countother = true)
		phazearray = ["SwitchOutTargetStatusMove", "SwitchOutTargetDamagingMove", 
					  "SleepTargetNextTurn", "StartPerishCountsForAllBattlers"]
		for m in pokemon.moves
			return true if phazearray.include?(m.function)
		end
		if countother
			return true if pokemon.ability == :SLIPPERYPEEL
			return true if pokemon.item_id == :REDCARD
		end
	end
	
	def pbHasHazardCleaningMove?(pokemon, countother = true)
		jannymarray = ["RemoveUserBindingAndEntryHazards", "LowerTargetEvasion1RemoveSideEffects"]
		for m in pokemon.moves
			return true if jannymarray.include?(m.function)
		end
		return true if pokemon.ability == :TILEWORKER && countother
	end
	
	def pbTargetBenefitsFromStatus?(user, target, status, miniscore, move, globalArray = [], skill = 100)
		globalArray = pbGetMidTurnGlobalChanges if globalArray.empty?
		return 0 if globalArray.include?("misty terrain") || @battle.field.terrain == :Misty
		return 0 if (globalArray.include?("electric terrain") || @battle.field.terrain == :Electric) && status == :SLEEP
		if target.hasActiveAbility?(:HYDRATION) && 
		   ([:Rain, :HeavyRain].include?(target.effectiveWeather) || globalArray.include?("rain weather"))
			miniscore*=0.2
		end
		if target.hasActiveAbility?(:LEAFGUARD) && 
		   ([:Sun, :HarshSun].include?(target.effectiveWeather) || globalArray.include?("sun weather"))
			miniscore*=0.2
		end
		miniscore*=0.2 if target.hasActiveAbility?(:GUTS) && !(status == :SLEEP && target.pbHasMoveFunction?("UseRandomUserMoveIfAsleep"))
		miniscore*=0.3 if target.hasActiveAbility?(:NATURALCURE)
		miniscore*=0.3 if target.hasActiveAbility?(:QUICKFEET) && status == :PARALYSIS
		miniscore*=0.5 if target.hasActiveAbility?(:MARVELSCALE)
		miniscore*=0.7 if target.hasActiveAbility?(:SHEDSKIN)
		miniscore*=0.4 if target.effects[PBEffects::Yawn]>0 && status != :SLEEP
		if target.effects[PBEffects::Confusion]>0
			miniscore *= (status == :SLEEP) ?  0.4 : 1.1
		end
		#if target.effects[PBEffects::Attract]>=0;miniscore*=1.1; end # attract does nothing
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
		miniscore*=1.3 if user.pbHasMoveFunction?("DoublePowerIfTargetStatusProblem")
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
			healingmove = false
			for m in target.moves
				if m.healingMove?
					healingmove = true
					break
				end
			end
			miniscore*=2 if healingmove
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
				if target.hasActiveAbility?(:MAGICGUARD)
					miniscore*=0.2
				end
			end
			miniscore*=0.3 if target.hasActiveItem?([:ASPEARBERRY, :LUMBERRY])
		when :SLEEP
			if user.pbHasMove?(:DREAMEATER) || user.pbHasMove?(:NIGHTMARE) || user.hasActiveAbility?(:BADDREAMS)
				miniscore*=1.5
			end
			if user.pbHasMove?(:LEECHSEED) || user.pbHasMove?(:SUBSTITUTE)
				miniscore*=1.3
			end
			if target.hp==target.totalhp
				miniscore*=1.2
			end
			if (pbRoughStat(target, :SPEED, skill) > pbRoughStat(user,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
				miniscore*=1.3
			end
			if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveAbility?(:POISONHEAL) && user.poisoned?)
				miniscore*=1.2
			end
			if pbHasSetupMove?(user, false)
				miniscore*=1.2
			end
			sleeptalk = false
			for m in target.moves
				if m.id == :SLEEPTALK || m.id == :SNORE
					sleeptalk = true
					break
				end
			end
			miniscore*=0.1 if sleeptalk
			if (move.id == :SPORE || move.id == :SLEEPPOWDER) && !target.affectedByPowder?
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
				# no need to do serene grace check here, 
				# simply because the AI wont try to hit allies with damaging confusing moves
			else
				minimi*=0.3 if target.hasActiveItem?([:PERSIMBERRY, :LUMBERRY])
				minimi = 0 if target.hasActiveAbility?(:TANGLEDFEET)
			end
			miniscore*=minimi
		end
		return miniscore
	end
	
	# Pokemon Roles System #######################################################
	
	def pbGetPokemonRole(pokemon, target, position = 0, party = nil)
		roles = []
		if pokemon.class == Battle::Battler # used for a single pokemon
			if [:MODEST, :JOLLY, :TIMID, :ADAMANT].include?(pokemon.nature) || 
				 [:CHOICEBAND, :CHOICESPECS, :CHOICESCARF].include?(pokemon.item_id)
				roles.push("Sweeper")
			end
			healingmove = false
			for m in pokemon.moves
				if m.healingMove?
					userhealingmove = true
					break
				end
			end
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
			if pokemon.index == 0
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
				next if zzz.nil? || zzz.priority<1
				dam=pbRoughDamage(zzz, pokemon, target, 100, zzz.baseDamage)
				if target.hp>0
					percentage=(dam*100.0)/target.hp
					priorityko=true if percentage>100
				end
			end
			if priorityko #|| (pokemon.speed>target.speed)
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
				 (pokemon.ability == :HYDRATION && (@battle.field.weather == :Rain || @battle.field.weather == :HeavyRain))
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
			if pokemon.pokemonIndex == (pokemonPartyEnd - 1)
				roles.push("Ace")
			end
			if pokemon.pokemonIndex == (pokemonPartyEnd - 2)
				roles.push("Second")
			end
		elsif pokemon.class == Pokemon # used for the whole party
			movelist = []
			for i in pokemon.moves
				next if i.nil?
				movedummy = Pokemon::Move.new(i.id)
				movedummy = Battle::Move.from_pokemon_move(@battle, movedummy)
				movelist.push(movedummy)
			end
			if [:MODEST, :JOLLY, :TIMID, :ADAMANT].include?(pokemon.nature) || 
				 [:CHOICEBAND, :CHOICESPECS, :CHOICESCARF].include?(pokemon.item_id)
				roles.push("Sweeper")
			end
			healingmove = false
			for mmm in movelist
				if mmm.healingMove?
					userhealingmove = true
					break
				end
			end
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
			# pbRoughDamage does not take Pokemon objects, this will cause issues
			priorityko=false
			for zzz in movelist
				next if zzz.priority<1
				next if zzz.baseDamage<10
				priorityko=true
			end
			if priorityko || (pokemon.speed>target.speed)
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
				 (pokemon.ability == :HYDRATION && (@battle.field.weather == :Rain || @battle.field.weather == :HeavyRain))
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
	
	# Status Moves "Damage" ######################################################

	def pbStatusDamage(move)
		moveScoores = {
		  0 => [:AFTERYOU, :ATTRACT, :BESTOW, :CELEBRATE, :HAPPYHOUR, :HOLDHANDS,
				 :QUASH, :SPLASH, :SWEETSCENT, :TELEKINESIS],
		  5 => [:ALLYSWITCH, :AROMATICMIST, :COACHING, :CONVERSION, :CRAFTYSHIELD, :ENDURE, :ENTRAINMENT, 
				 :FAIRYLOCK, :FORESIGHT, :FORESTSCURSE, :GRUDGE, :GUARDSPLIT, :GUARDSWAP, :HEALBLOCK, 
				 :HELPINGHAND, :IMPRISON, :LIFEDEW, :LOCKON, :LUCKYCHANT, :MAGICROOM, :MAGNETRISE, 
				 :MINDREADER, :MIRACLEEYE, :MUDSPORT, :NIGHTMARE, :ODORSLEUTH, :POWERSPLIT, :POWERSWAP, 
				 :POWERTRICK, :QUICKGUARD, :RECYCLE, :REFLECTTYPE, :ROTOTILLER, :SAFEGUARD, :SANDATTACK, 
				 :SKILLSWAP, :SPEEDSWAP, :SPOTLIGHT, :SPITE, :TEATIME, :TEETERDANCE, :WATERSPORT, 
				 :EXCITE, :HOWL, :LASERFOCUS],
		  10 => [:ACUPRESSURE, :CAMOUFLAGE, :CHARM, :CONFIDE, :DEFENSECURL, :DECORATE, :EMBARGO,
				 :FLASH, :FOCUSENERGY, :GROWL, :HARDEN, :HAZE, :KINESIS, :LEER,
				 :METALSOUND, :MEMENTO, :NOBLEROAR, :PLAYNICE, :POWDER, :PSYCHUP, :SHARPEN,
				 :SMOKESCREEN, :STRINGSHOT, :SUPERSONIC, :TAILWHIP, :TORMENT, :TEARFULLOOK,
				 :WITHDRAW, :MEDITATE, :GROWTH, :WORKUP],
		  20 => [:AGILITY, :ASSIST, :BABYDOLLEYES, :CAPTIVATE, :CHARGE, :CORROSIVEGAS, :COTTONSPORE,
				 :COURTCHANGE, :DEFOG, :DOUBLETEAM, :EERIEIMPULSE, :FAKETEARS, :FEATHERDANCE,
				 :FLORALHEALING, :GEARUP, :HEALINGWISH, :HEALPULSE, :INGRAIN, :INSTRUCT, :LUNARDANCE,
				 :MEFIRST, :MIMIC, :POISONPOWDER, :REFRESH, :ROLEPLAY, :SCARYFACE,
				 :SCREECH, :SKETCH, :STUFFCHEEKS, :TARSHOT, :TICKLE, :TRICKORTREAT, :VENOMDRENCH,
				 :MAGNETICFLUX],
		  25 => [:AQUARING, :BLOCK, :CONVERSION2, :COPYCAT, :ELECTRIFY, :FLATTER, :FLOWERSHIELD,
				 :GASTROACID, :HEARTSWAP, :IONDELUGE, :MAGICCOAT, :MEANLOOK, :METRONOME,
				 :MIRRORMOVE, :MIST, :PERISHSONG, :POISONGAS, :REST, :ROAR, :SIMPLEBEAM, :SNATCH,
				 :SPIDERWEB, :SWAGGER, :SWEETKISS, :TRANSFORM, :WHIRLWIND, :WORRYSEED, :YAWN],
		  30 => [:ACIDARMOR, :AMNESIA, :AUTOTOMIZE, :BARRIER, :BELLYDRUM, :COSMICPOWER, :COTTONGUARD,
				 :DEFENDORDER, :DESTINYBOND, :DETECT, :DISABLE, :FOLLOWME, :GRAVITY, :IRONDEFENSE,
				 :MINIMIZE, :OCTOLOCK, :POLLENPUFF, :PSYCHOSHIFT, :RAGEPOWDER, :REBALANCING,
				 :ROCKPOLISH, :SANDSTORM, :STOCKPILE, :SUBSTITUTE, :SWALLOW, :SWITCHEROO, :TAUNT,
				 :TRICK, :HAIL],
		  35 => [:BATONPASS, :BULKUP, :CALMMIND, :CLANGOROUSSOUL, :COIL, :CURSE, :ELECTRICTERRAIN,
				 :ENCORE, :GRASSYTERRAIN, :LEECHSEED, :MAGICPOWDER, :MISTYTERRAIN, :NATUREPOWER,
				 :NORETREAT, :PAINSPLIT, :PSYCHICTERRAIN, :PURIFY, :SLEEPTALK, :SOAK, :SUNNYDAY,
				 :TELEPORT, :TRICKROOM, :WISH, :WONDERROOM, :RAINDANCE],
		  40 => [:AROMATHERAPY, :AURORAVEIL, :BITINGCOLD, :CONFUSERAY, :GLARE, :HEALBELL, :HONECLAWS, 
				 :LIGHTSCREEN, :MATBLOCK, :PARTINGSHOT, :REFLECT, :SPIKES, :STUNSPORE, :TAILWIND, 
				 :THUNDERWAVE, :TOXIC, :TOXICSPIKES, :TOXICTHREAD, :WIDEGUARD, :WILLOWISP],
		  50 => [:NASTYPLOT, :STEALTHROCK, :SWORDSDANCE, :STICKYWEB, :TOPSYTURVY],
		  60 => [:DRAGONDANCE, :GEOMANCY, :QUIVERDANCE, :SHELLSMASH, :SHIFTGEAR, :TAILGLOW],
		  70 => [:HEALORDER, :JUNGLEHEALING, :MILKDRINK, :MOONLIGHT, :MORNINGSUN, :RECOVER, :ROOST,
				 :SHOREUP, :SLACKOFF, :SOFTBOILED, :STRENGTHSAP, :SYNTHESIS],
		  80 => [:BANEFULBUNKER, :KINGSSHIELD, :OBSTRUCT, :PROTECT, :SPIKYSHIELD],
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
		globalArray = pbGetMidTurnGlobalChanges if globalArray.empty?
		# modified by JZ
    	fieldscore = 100.0
		aroles = pbGetPokemonRole(user, target)
		oroles = pbGetPokemonRole(target, user)
		if @battle.field.terrain == :Electric || 
		   globalArray.include?("electric terrain") # Electric Terrain
			echo("\nElectric Terrain Disrupt") if $AIGENERALLOG
			target.eachAlly do |b|
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
		if @battle.field.terrain == :Grassy || 
		   globalArray.include?("grassy terrain") # Grassy Terrain
			echo("\nGrassy Terrain Disrupt") if $AIGENERALLOG
			target.eachAlly do |b|
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
		if @battle.field.terrain == :Misty || 
		   globalArray.include?("misty terrain") # Misty Terrain
			echo("\nMisty Terrain Disrupt") if $AIGENERALLOG
			if user.spatk>user.attack
				target.eachAlly do |b|
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
		if @battle.field.terrain == :Psychic || 
		   globalArray.include?("psychic terrain") # Psychic Terrain
			echo("\nPsychic Terrain Disrupt") if $AIGENERALLOG
			target.eachAlly do |b|
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
		if target.hasActiveAbility?(:SANDVEIL)
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
			if !user.hasActiveAbility?(:SHADOWTAG)
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
			soundvar=false
			for i in user.moves
				if i.soundMove?
					soundvar=true
				end
			end
			if soundvar
				abilityscore*=3
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
			abilityscore*=2
		end 	
		if target.hasActiveAbility?(:UNBURDEN)
			if target.effects[PBEffects::Unburden]
				echo("\nUnburden Disrupt") if $AIGENERALLOG
				abilityscore*=2
			end	
		end 			
		if target.hasActiveAbility?(:MOLDBREAKER) || 
			 (target.isSpecies?(:GYARADOS)  && (target.item == :GYARADOSITE || target.hasMegaEvoMutation?) && target.pokemon.willmega) ||
			 (target.isSpecies?(:LUPACABRA) && (target.item == :LUPACABRITE || target.hasMegaEvoMutation?) && target.pokemon.willmega)
			echo("\nMold Breaker Disrupt") if $AIGENERALLOG
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
		if target.hasActiveAbility?(:PUNKROCK)
			echo("\nSoundboost Disrupt") if $AIGENERALLOG
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
			abilityscore*=1.5 if pbRoughStat(user,:SPEED,skill)>pbRoughStat(target,:SPEED,skill)
		end
		if target.hasActiveAbility?(:ECHOCHAMBER)
			echo("\nEcho Chamber Disrupt") if $AIGENERALLOG
			echohealcheck=false
			echopriocheck=false
			for i in target.moves
				if i.soundMove?
					echohealcheck=true
					echopriocheck=true if i.statusMove?
				end
			end
			if echohealcheck
				abilityscore*=1.15
			end
			if echopriocheck && pbRoughStat(user,:SPEED,skill)>pbRoughStat(target,:SPEED,skill)
				abilityscore*=1.5
			end
		end
		if target.hasActiveAbility?(:FURCOAT)
			echo("\nFur Coat Disrupt") if $AIGENERALLOG
			abilityscore*=1.5 if user.attack>user.spatk
		end
		if target.hasActiveAbility?(:PARENTALBOND)
			echo("\nParental Bond Disrupt") if $AIGENERALLOG
			abilityscore*=3
		end 
		if target.hasActiveAbility?(:PROTEAN)
			echo("\nProtean Disrupt") if $AIGENERALLOG
			abilityscore*=3
		end 
		if target.hasActiveAbility?(:TOUGHCLAWS)
			echo("\nTough Claws Disrupt") if $AIGENERALLOG
			abilityscore*=1.2
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
		if target.hasActiveAbility?([:AMPLIFIER, :SEANCE, :MICROSTRIKE, :BLADEMASTER, :MOMENTUM, :ANGELICBEAUTY])
			echo("\nMinor Impact Untamed Ability Disrupt") if $AIGENERALLOG
			abilityscore*=1.2
		end
		if target.hasActiveAbility?([:BAITEDLINE, :FERVOR, :CRYSTALJAW, :JUNGLEFURY])
			echo("\nMedium Impact Untamed Ability Disrupt") if $AIGENERALLOG
			abilityscore*=1.3
		end
		if target.hasActiveAbility?([:PARTYPOPPER, :WARRIORSPIRIT, :SLIPPERYPEEL, :TRICKSTER, :MASSEXTINCTION, :PREMONITION])
			echo("\nHigh Impact Untamed Ability Disrupt") if $AIGENERALLOG
			abilityscore*=1.6
		end
		abilityscore*=0.01
		return abilityscore
	end
	
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
		#echoln globalArray
		return globalArray
	end
	
	def pbAIPrioSpeedCheck(attacker, opponent, move, score, globalArray, aspeed = 0, ospeed = 0)
		user = attacker
		target = opponent
		skill = 100
		thisprio = priorityAI(user,move)
		if thisprio>0 
			aspeed = pbRoughStat(attacker,:SPEED,skill) if aspeed == 0
			ospeed = pbRoughStat(opponent,:SPEED,skill) if ospeed == 0
			if move.baseDamage>0  
				fastermon = ((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
				if fastermon
					echo("\n"+user.name+" is faster than "+opponent.name+".\n")
				else
					echo("\n"+opponent.name+" is faster than "+user.name+".\n")
				end
				if !targetSurvivesMove(move,attacker,opponent)
					echo("\n"+opponent.name+" will not survive.")
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
				for j in opponent.moves
					tempdam = pbRoughDamage(j,opponent,attacker,skill,j.baseDamage)
					tempdam = 0 if pbCheckMoveImmunity(1,j,opponent,attacker,100)
					if priorityAI(opponent,j)>0
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
					echo("Expected priority damage taken by "+opponent.name+": "+pridam.to_s+"\n") 
				end
				if !fastermon
					echo("Expected damage taken by "+opponent.name+": "+movedamage.to_s+"\n") 
					maxdam=0
					maxmove2=nil
					if !targetSurvivesMove(maxmove,opponent,attacker)
						echo(user.name+" does not survive. Score +150. \n")
						score+=150
						for j in opponent.moves
							if opponent.effects[PBEffects::ChoiceBand] &&
								opponent.hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF])
								if opponent.lastMoveUsed && opponent.pbHasMove?(opponent.lastMoveUsed)
									next if j.id!=opponent.lastMoveUsed
								end
							end		
							tempdam = pbRoughDamage(j,opponent,attacker,skill,j.baseDamage)
							tempdam = 0 if pbCheckMoveImmunity(1,j,opponent,attacker,100)
							maxdam=tempdam if tempdam>maxdam
							maxmove2=j
						end
						if !targetSurvivesMove(maxmove2,opponent,attacker)
							score+=30
						end
					end
				end     
				if opppri
					score*=1.1
					if !targetSurvivesMove(maxpriomove,opponent,attacker)
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
						opponent.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
													"TwoTurnAttackInvulnerableUnderground",
													"TwoTurnAttackInvulnerableInSkyParalyzeTarget",
													"TwoTurnAttackInvulnerableUnderwater",
													"TwoTurnAttackInvulnerableInSkyTargetCannotAct")
					echo("Player Pokemon is invulnerable. Score-300. \n")
					score-=300
				end
				if (@battle.field.terrain == :Psychic || globalArray.include?("psychic terrain")) && opponent.affectedByTerrain?
					echo("Blocked by Psychic Terrain. Score-300. \n")
					score-=300
				end
				@battle.allSameSideBattlers(opponent.index).each do |b|
					priobroken=moldbroken(attacker,b,move)
					if b.hasActiveAbility?([:DAZZLING, :QUEENLYMAJESTY],false,priobroken) &&
						 !(b.isSpecies?(:LAGUNA) && (b.item == :LAGUNITE || b.hasMegaEvoMutation?) && b.pokemon.willmega) # laguna can have dazz in pre-mega form
						score-=300 
						echo("Blocked by enemy ability. Score-300. \n")
					end
				end 
				if pbTargetsMultiple?(move,user)    
					quickcheck = false 
					for j in opponent.moves
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
					if opponent.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
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

	def targetWillMove?(target, action = "AG")
		if @battle.choices[target.index][0] == :UseMove
			return true if @battle.choices[target.index][2].physicalMove? && action == "phys"
			return true if @battle.choices[target.index][2].specialMove? && action == "spec"
			return true if @battle.choices[target.index][2].statusMove? && action == "status"
			return true if action == "AG"
		else
			return false
		end
		return false
	end
end