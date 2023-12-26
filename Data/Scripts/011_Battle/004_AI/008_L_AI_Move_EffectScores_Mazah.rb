class Battle::AI
# added the new status nerf if $game_variables[MECHANICSVAR] is above or equal to 3 #by low
  #=============================================================================
  # Get a score for the given move based on its effect
  #=============================================================================
  alias aiEffectScorePart3_pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode

  def pbGetMoveScoreFunctionCode(score, move, user, target, skill = 100)
    case move.function
    #---------------------------------------------------------------------------
    when "ProtectUser"
			theresone=false
			@battle.allBattlers.each do |j|
				if j.opposes?(user)
					if (j.isSpecies?(:CACTURNE) && j.item == :CACTURNITE && j.willmega) || 	# sand
						 (j.isSpecies?(:ZOLUPINE) && j.item == :ZOLUPINEITE && j.willmega) || # rain
						 (j.isSpecies?(:ZARCOIL) && j.item == :ZARCOILITE && j.willmega) || 	# sun
						 (j.isSpecies?(:FRIZZARD) && j.item == :FRIZZARDITE && j.willmega) 		# hail
						theresone=true
					end
				end
			end
			score*=1.3 if theresone
			if target.turnCount==0
				score*=1.5
			end
			if pbHasSetupMove?(target, false)
				score*=0.3
			end
			if user.hasActiveAbility?(:SPEEDBOOST) && 
				 user.pbSpeed > pbRoughStat(target, :SPEED, skill) && @battle.field.effects[PBEffects::TrickRoom]==0
				score*=4
				initialscores = [] #pbCheckOtherMovesScore(user, target, move, true, score)
				#experimental -- cancels out drop if killing moves
				if initialscores.length>0
					greatmoves=false
					for i in 0...initialscores.length
						if initialscores[i]>=100
							greatmoves=true
						end
					end
					score*=6 if greatmoves
				end
				#end experimental
			end
			if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON)) || 
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
			maxdam = 0
			contactcheck=false
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				if tempdam > maxdam
					maxdam = tempdam
					contactcheck=true if m.contactMove?
				end
			end
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
					movecheck=true if [:WILLOWISP, :THUNDERWAVE, :TOXIC, :BITINGCOLD].include?(m.id)
				end
				score*=0.7 if movecheck
			end
			score = 0 if user.effects[PBEffects::ProtectRate] > 1
    #---------------------------------------------------------------------------
    when "ProtectUserBanefulBunker" # baneful bunker
			if target.turnCount==0
				score*=1.5
			end        
			if pbHasSetupMove?(target, false)
				score*=0.3
			end
			if user.hasActiveAbility?(:SPEEDBOOST) && 
				 user.pbSpeed > pbRoughStat(target, :SPEED, skill) && @battle.field.effects[PBEffects::TrickRoom]==0
				score*=4
				initialscores = [] #pbCheckOtherMovesScore(user, target, move, true, score)
				#experimental -- cancels out drop if killing moves
				if initialscores.length>0
					greatmoves=false
					for i in 0...initialscores.length
						if initialscores[i]>=100
							greatmoves=true
						end
					end
					score*=6 if greatmoves
				end
				#end experimental
			end
			if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON)) || 
				 user.effects[PBEffects::Ingrain] || user.effects[PBEffects::AquaRing] || 
				 @battle.field.terrain == :Grassy
				score*=1.2
			end  
			if target.pbHasAnyStatus?
				score*=0.8
			else
				if target.pbCanPoison?(user, false)
					miniscore = pbTargetBenefitsFromStatus?(user, target, :POISON, 110, move, 100)
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
				movecheck=true if ["RemoveProtections", "RemoveProtectionsBypassSubstitute", "HoopaRemoveProtectionsBypassSubstituteLowerUserDef1"].includes?(m.id)
			end
			score*=0.1 if movecheck
			maxdam = 0
			contactcheck=false
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				if tempdam > maxdam
					maxdam = tempdam
					contactcheck=true if m.contactMove?
				end
			end
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
					movecheck=true if [:WILLOWISP, :THUNDERWAVE, :TOXIC, :BITINGCOLD].include?(m.id)
				end
				score*=0.7 if movecheck
			end
			score = 0 if user.effects[PBEffects::ProtectRate] > 1
    #---------------------------------------------------------------------------
    when "ProtectUserFromDamagingMovesKingsShield" # King's Shield
			if target.turnCount==0
				score*=1.5
			end        
			if pbHasSetupMove?(target, false)
				score*=0.6
			end
			if user.hasActiveAbility?(:SPEEDBOOST) && 
				 user.pbSpeed > pbRoughStat(target, :SPEED, skill) && @battle.field.effects[PBEffects::TrickRoom]==0
				score*=4
				initialscores = [] #pbCheckOtherMovesScore(user, target, move, true, score)
				#experimental -- cancels out drop if killing moves
				if initialscores.length>0
					greatmoves=false
					for i in 0...initialscores.length
						if initialscores[i]>=100
							greatmoves=true
						end
					end
					score*=6 if greatmoves
				end
				#end experimental
			end
			if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON)) || 
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
			if (user.pbSpeed < pbRoughStat(target, :SPEED, skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0) && 
				 user.isSpecies?(:AEGISLASH) && user.form == 1
				score*=4
				initialscores = [] #pbCheckOtherMovesScore(user, target, move, true, score)
				#experimental -- cancels out drop if killing moves
				if initialscores.length>0
					greatmoves=false
					for i in 0...initialscores.length
						if initialscores[i]>=100
							greatmoves=true
						end
					end
					score*=6 if greatmoves
				end
				#end experimental
			else
				score*=0.8
			end
			movecheck=false
			for m in target.moves
				movecheck=true if m.ignoresSubstitute?(target)
			end
			score*=0.1 if movecheck
			maxdam = 0
			contactcheck=false
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				if tempdam > maxdam
					maxdam = tempdam
					contactcheck=true if m.contactMove?
				end
			end
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
					movecheck=true if [:WILLOWISP, :THUNDERWAVE, :TOXIC, :BITINGCOLD].include?(m.id)
				end
				score*=0.7 if movecheck
			end
			score = 0 if user.effects[PBEffects::ProtectRate] > 1
    #---------------------------------------------------------------------------
    when "ProtectUserFromDamagingMovesObstruct"
      if target.effects[PBEffects::HyperBeam] > 0
        score -= 90
      else
        score += 50 if user.turnCount == 0
        score += 30 if target.effects[PBEffects::TwoTurnAttack]
        score = 0 if user.effects[PBEffects::ProtectRate] > 1
      end
    #---------------------------------------------------------------------------
    when "ProtectUserFromTargetingMovesSpikyShield" # Spiky Shield
			if target.turnCount==0
				score*=1.5
			end        
			if pbHasSetupMove?(target, false)
				score*=0.6
			end
			if user.hasActiveAbility?(:SPEEDBOOST) && 
				 user.pbSpeed > pbRoughStat(target, :SPEED, skill) && @battle.field.effects[PBEffects::TrickRoom]==0
				score*=4
				initialscores = [] #pbCheckOtherMovesScore(user, target, move, true, score)
				#experimental -- cancels out drop if killing moves
				if initialscores.length>0
					greatmoves=false
					for i in 0...initialscores.length
						if initialscores[i]>=100
							greatmoves=true
						end
					end
					score*=6 if greatmoves
				end
				#end experimental
			end
			if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON)) || 
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
			movecheck=false
			for m in target.moves
				movecheck=true if m.ignoresSubstitute?(target)
			end
			score*=0.1 if movecheck
			maxdam = 0
			contactcheck=false
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				if tempdam > maxdam
					maxdam = tempdam
					contactcheck=true if m.contactMove?
				end
			end
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
					movecheck=true if [:WILLOWISP, :THUNDERWAVE, :TOXIC, :BITINGCOLD].include?(m.id)
				end
				score*=0.7 if movecheck
			end
			score = 0 if user.effects[PBEffects::ProtectRate] > 1
    #---------------------------------------------------------------------------
    when "ProtectUserSideFromDamagingMovesIfUserFirstTurn" # mat block
			soundcheck=false
			healcheck = false
			for m in target.moves
				soundcheck = true if ["RemoveProtections", "RemoveProtectionsBypassSubstitute", "HoopaRemoveProtectionsBypassSubstituteLowerUserDef1"].includes?(m.id)
				healcheck = true if m.healingMove?
			end
			setupcheck = false
			setupcheck = true if pbHasSetupMove?(target, false)
      if user.turnCount == 0
				hasAlly = !user.allAllies.empty?
				if hasAlly
					score*=1.3
					if (user.pbSpeed>pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
						score*=1.2
					else
						score*=0.7
						if (user.pbSpeed>pbRoughStat(target,:SPEED,skill) && @battle.field.effects[PBEffects::TrickRoom]!=0)
							score*=0
						end
					end
					if setupcheck && healcheck
						score*=0.3
					end
					if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON)) || 
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
			maxdam = 0
			for m in target.moves
				tempdam = pbRoughDamage(m, user, target, skill, m.baseDamage)
				maxdam = tempdam if tempdam > maxdam
			end
			movecheck = false
			movecheck = true if pbHasPhazingMove?(target)
			if user.effects[PBEffects::ProtectRate] > 1
				score = 0
			elsif user.lastMoveUsed == :CRAFTYSHIELD
				score*=0.5
			else
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
			end
    #---------------------------------------------------------------------------
    when "ProtectUserSideFromPriorityMoves"
			if user.effects[PBEffects::ProtectRate] > 1
				score = 0
			else
				noprio = true
				ally = false
				user.allAllies.each do |b|
					next if b.nil?
					ally = true
				end
				for m in target.moves
					if m.priority > 0
						noprio = false
						break
					end
					if target.hasActiveAbility?(:GALEWINGS) && (target.hp >= (target.totalhp/2)) && m.type == :FLYING
						noprio = false
						break
					end
					if target.hasActiveAbility?(:PRANKSTER) && !user.pbHasType?(:DARK) && m.statusMove?
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
				end
				if !ally
					score -= 20
				end
				if user.hp==user.totalhp
					score *= 1.5
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
					score += 20
				end
				if user.hp==user.totalhp
					score *= 1.5
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
    #---------------------------------------------------------------------------
		when "HigherDamageInRain"
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
         @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 30
      elsif user.hasActiveAbility?(:PRESAGE)
				score += 30
      elsif @battle.field.weather != :Rain
				score -= 30
			else
				score += 30
			end
    #---------------------------------------------------------------------------
		when "HitThreeToFiveTimes"
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
		when "OverrideTargetStatusWithPoison"
			if $game_variables[MECHANICSVAR] >= 2 && target.status == :NONE
				score *= 0.7
			elsif target.asleep? && (target.statusCount <= 2 && target.pbSpeed < user.pbSpeed)
				score = 0
			elsif target.pbCanInflictStatus?(:POISON, user, false, self, true)
				miniscore = pbTargetBenefitsFromStatus?(user, target, :POISON, 100, move, skill)
				score*=miniscore
				score += 20
				score += 20 if user.hasActiveAbility?(:MERCILESS)
				score += 20 if (target.hasActiveAbility?(:GUTS) && target.burned?) || target.hasActiveAbility?(:FLAREBOOST)
				score -= 20 if target.hasActiveAbility?(:SYNCHRONIZE) && target.pbCanPoisonSynchronize?(user)
				score -= 90 if (target.hasActiveAbility?(:POISONHEAL) || target.hasActiveAbility?(:TOXICBOOST)) && !target.poisoned?
			else
				score *= 0.8
			end
    #---------------------------------------------------------------------------
		when "DoubleDamageIfTargetHasChoiceItem"
			if !target.unlosableItem?(target.item) && !target.hasActiveAbility?(:STICKYHOLD)
				score += 30 if [:CHOICEBAND, :CHOICESPECS, :CHOICESCARF].include?(target.initialItem)
				score += 40 if user.pbSpeed <= target.pbSpeed
			end
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
		protectarray = ["ProtectUser", "ProtectUserFromDamagingMovesKingsShield",
										"ProtectUserFromTargetingMovesSpikyShield", "ProtectUserBanefulBunker", 
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
	
	def pbCheckOtherMovesScore(pokemon, opposing, thismove, array = false, score = 1) # dont use this
		if array
			startscore = [score]
		else
			startscore = 0
		end
		for i in pokemon.moves
			next if i == thismove
			phantomdata = Pokemon::Move.new(i.id)
			phantommove = Battle::Move.from_pokemon_move(@battle, phantomdata)
			next if phantomdata.nil? || phantommove.nil?
			if phantommove.baseDamage<=0
				phantomdam = pbStatusDamage(phantommove)
			else
				tempdam = pbRoughDamage(phantommove, pokemon, opposing, 100, phantommove.baseDamage)
				phantomdam = (tempdam*100)/(opposing.hp.to_f)
			end
			phantomdam = 110 if phantomdam>110
			miniscore = pbGetMoveScore(phantommove, pokemon, opposing, 100, phantomdam)
			if array
				startscore.push(miniscore)
			else
				startscore = miniscore if miniscore > startscore
			end
		end
		return startscore
	end

	def pbTargetBenefitsFromStatus?(user, target, status, miniscore, move, skill = 100)
		theresone=false
		@battle.allBattlers.each do |j|
			if (j.isSpecies?(:MILOTIC) && j.item == :MILOTITE && j.willmega && target.affectedByTerrain?)
				theresone=true
			end
		end
		miniscore*=0.2 if theresone || @battle.field.terrain == :Misty
		if target.hasActiveAbility?(:QUICKFEET) || (target.hasActiveAbility?(:GUTS) && status != :BURN)
			miniscore*=0.2
		end
		if target.hasActiveAbility?(:HYDRATION) && [:Rain, :HeavyRain].include?(target.effectiveWeather)
			miniscore*=0.2
		end
		if target.hasActiveAbility?(:NATURALCURE);	miniscore*=0.3; end
		if target.hasActiveAbility?(:MARVELSCALE);	miniscore*=0.5; end
		if target.hasActiveAbility?(:SHEDSKIN);			miniscore*=0.7; end
		if target.effects[PBEffects::Yawn]>0 && status != :SLEEP
			miniscore*=0.4
		end
		if target.effects[PBEffects::Confusion]>0
			if status != :SLEEP
				miniscore*=1.1
			else
				miniscore*=0.4
			end
		end
		#~ if target.effects[PBEffects::Attract]>=0;miniscore*=1.1; end # attract does nothing so
		facade = false
		for m in target.moves
			if (m.function == "DoublePowerIfUserPoisonedBurnedParalyzed" && [:POISON, :BURN, :PARALYSIS].include?(status)) ||
				 (m.function == "HealUserFullyAndFallAsleep" && status != :SLEEP)
				facade = true
				break
			end
		end
		if !(status == :PARALYSIS && !target.hasActiveAbility?(:QUICKFEET))
			miniscore*=0.3 if facade
		end
		if move.baseDamage>0 && status != :PARALYSIS
			if target.hasActiveAbility?(:STURDY)
				miniscore*=1.1
			end
		end
		case status
			when :PARALYSIS
				if target.hasActiveAbility?(:SYNCHRONIZE) && target.pbCanParalyzeSynchronize?(user)
					miniscore*=0.5
				end
				if pbRoughStat(target, :SPEED, skill) > user.pbSpeed && 
					 (pbRoughStat(target, :SPEED, skill)/2) < user.pbSpeed && 
					 @battle.field.effects[PBEffects::TrickRoom] <= 0
					miniscore*=1.5
				end
				if pbRoughStat(target, :SPECIAL_ATTACK, skill) > pbRoughStat(target, :ATTACK, skill)
					miniscore*=1.3
				end
			when :BURN
				if target.hasActiveAbility?(:SYNCHRONIZE) && target.pbCanBurnSynchronize?(user)
					miniscore*=0.5
				end
				if target.hasActiveAbility?(:FLAREBOOST) || target.hasActiveAbility?(:MAGICGUARD)
					miniscore*=0.2
				end
				if target.hasActiveAbility?(:GUTS)
					miniscore*=0.1
				end
				if pbRoughStat(target, :ATTACK, skill) > pbRoughStat(target, :SPECIAL_ATTACK, skill)
					miniscore*=1.7
				end
			when :POISON
				if target.hasActiveAbility?(:SYNCHRONIZE) && target.pbCanPoisonSynchronize?(user)
					miniscore*=0.5
				end
				if target.hasActiveAbility?(:TOXICBOOST) || target.hasActiveAbility?(:POISONHEAL) || target.hasActiveAbility?(:MAGICGUARD)
					miniscore*=0.1
				end
				if user.hasActiveAbility?(:MERCILESS) || user.pbHasMove?(:VENOSHOCK) || user.pbHasMove?(:VENOMDRENCH)
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
					miniscore*=1.1 if user.pbHasType?(:POISON)
				end
			when :FREEZE
				if target.hasActiveAbility?(:SYNCHRONIZE) && target.pbCanFreezeSynchronize?(user)
					miniscore*=0.5
				end
				if target.hasActiveAbility?(:MAGICGUARD)
					miniscore*=0.2
				end
				if pbRoughStat(target, :SPECIAL_ATTACK, skill) > pbRoughStat(target, :ATTACK, skill)
					miniscore*=1.7
				end
			when :DIZZY
				minimini = getAbilityDisruptScore(move,user,target,skill)
				if target.opposes?(user)
					miniscore = (10)*minimini
				else
					miniscore = (-10)*minimini
					miniscore*=0.8 if move.damagingMove?
				end
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
				if (pbRoughStat(target, :SPEED, skill) > user.pbSpeed) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
					miniscore*=1.3
				end
				if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveAbility?(:POISONHEAL) && user.poisoned?)
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
				if (move.id == :SPORE || move.id == :SLEEPPOWDER) && target.affectedByPowder?
					miniscore=0
				end
				if move.id == :DARKVOID && !user.isSpecies?(:DARKRAI)
					miniscore=0
				end
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
				if pokemon.item_id == :ASSAULTVEST
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
					:FORECAST, :PRESAGE].include?(pokemon.ability) ||
				 (pokemon.ability == :FREEZEOVER && pokemon.item_id == :ICYROCK) ||
				 (pokemon.species == :ZARCOIL && pokemon.item_id == :ZARCOILITE) ||
				 (pokemon.species == :ZOLUPINE && pokemon.item_id == :ZOLUPINEITE) ||
				 (pokemon.species == :CACTURNE && pokemon.item_id == :CACTURNITE) ||
				 (pokemon.species == :FRIZZARD && pokemon.item_id == :FRIZZARDITE)
				roles.push("Weather Setter")
			end
			if pokemon.pbHasMoveFunction?("StartElectricTerrain", "StartGrassyTerrain", "StartMistyTerrain", "StartPsychicTerrain") || 
				 [:ELECTRICSURGE, :PSYCHICSURGE, :MISTYSURGE, :GRASSYSURGE].include?(pokemon.ability) ||
				 (pokemon.species == :BEHEEYEM && pokemon.item_id == :BEHEEYEMITE) ||
				 (pokemon.species == :MILOTIC && pokemon.item_id == :MILOTITE) ||
				 (pokemon.species == :TREVENANT && pokemon.item_id == :TREVENANTITE) ||
				 (pokemon.species == :BEAKRAFT && pokemon.item_id == :BEAKRAFTITE)
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
				if pokemon.item_id == :ASSAULTVEST
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
					:FORECAST, :PRESAGE].include?(pokemon.ability) ||
				 (pokemon.ability == :FREEZEOVER && pokemon.item_id == :ICYROCK) ||
				 (pokemon.species == :ZARCOIL && pokemon.item_id == :ZARCOILITE) ||
				 (pokemon.species == :ZOLUPINE && pokemon.item_id == :ZOLUPINEITE) ||
				 (pokemon.species == :CACTURNE && pokemon.item_id == :CACTURNITE) ||
				 (pokemon.species == :FRIZZARD && pokemon.item_id == :FRIZZARDITE)
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
				 (pokemon.species == :BEHEEYEM && pokemon.item_id == :BEHEEYEMITE) ||
				 (pokemon.species == :MILOTIC && pokemon.item_id == :MILOTITE) ||
				 (pokemon.species == :TREVENANT && pokemon.item_id == :TREVENANTITE) ||
				 (pokemon.species == :BEAKRAFT && pokemon.item_id == :BEAKRAFTITE)
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
		if (move.id == :AFTERYOU || move.id == :BESTOW ||
				move.id == :CRAFTYSHIELD || move.id == :LUCKYCHANT ||
				move.id == :MEMENTO || move.id == :QUASH ||
				move.id == :SAFEGUARD || move.id == :SPITE ||
				move.id == :SPLASH || move.id == :SWEETSCENT ||
				move.id == :TELEKINESIS || 
				move.id == :HAPPYHOUR || 
				move.id == :HOLDHANDS || 
				move.id == :CELEBRATE)
			return 0
		elsif (move.id == :ALLYSWITCH || move.id == :AROMATICMIST ||
				move.id == :CONVERSION || move.id == :ENDURE ||
				move.id == :ENTRAINMENT || move.id == :FORESIGHT || 
				move.id == :FORESTSCURSE || move.id == :DEFOG || 
				move.id == :GUARDSWAP || move.id == :HEALBLOCK ||
				move.id == :IMPRISON || 
				move.id == :HELPINGHAND || move.id == :MAGICROOM ||
				move.id == :MAGNETRISE || 
				move.id == :LOCKON || move.id == :MINDREADER || 
				move.id == :MIRACLEEYE || move.id == :MUDSPORT ||
				move.id == :NIGHTMARE || move.id == :ODORSLEUTH ||
				move.id == :POWERSPLIT || move.id == :POWERSWAP ||
				move.id == :GRUDGE || move.id == :GUARDSPLIT ||
				move.id == :POWERTRICK || move.id == :QUICKGUARD ||
				move.id == :RECYCLE || move.id == :REFLECTTYPE ||
				move.id == :ROTOTILLER || move.id == :SANDATTACK ||
				move.id == :SKILLSWAP || move.id == :SNATCH ||
				move.id == :MAGICCOAT || 
				move.id == :FAIRYLOCK || 
				move.id == :COACHING || 
				move.id == :SPOTLIGHT || 
				move.id == :TEATIME || 
				move.id == :MAGICPOWDER || 
				move.id == :SPEEDSWAP || 
				move.id == :LIFEDEW || 
				move.id == :COURTCHANGE || move.id == :LASERFOCUS ||
				move.id == :TEETERDANCE || move.id == :WATERSPORT)
			return 5
		elsif (move.id == :ACUPRESSURE || move.id == :CAMOUFLAGE ||      
				move.id == :CHARM || move.id == :CONFIDE ||
				move.id == :DEFENSECURL || move.id == :GROWTH ||
				move.id == :EMBARGO || move.id == :FLASH ||
				move.id == :FOCUSENERGY || move.id == :GROWL ||
				move.id == :HARDEN || move.id == :HAZE ||
				move.id == :HOWL || move.id == :EXCITE ||
				move.id == :KINESIS || move.id == :LEER ||
				move.id == :METALSOUND || move.id == :NOBLEROAR ||
				move.id == :PLAYNICE || move.id == :POWDER ||
				move.id == :PSYCHUP || move.id == :SHARPEN ||
				move.id == :SMOKESCREEN || move.id == :STRINGSHOT ||
				move.id == :SUPERSONIC || move.id == :TAILWHIP ||
				move.id == :TORMENT ||
				move.id == :DECORATE ||
				move.id == :TEARFULLOOK ||
				move.id == :WITHDRAW || move.id == :WORKUP)
			return 10
		elsif (move.id == :ASSIST || move.id == :BABYDOLLEYES || 
				move.id == :CAPTIVATE || move.id == :COTTONSPORE ||
				move.id == :AGILITY ||
				move.id == :DOUBLETEAM || move.id == :EERIEIMPULSE ||
				move.id == :FAKETEARS || move.id == :FEATHERDANCE ||
				move.id == :HEALPULSE || move.id == :HEALINGWISH ||
				move.id == :INGRAIN ||
				move.id == :LUNARDANCE || move.id == :MEFIRST ||
				move.id == :MEDITATE || move.id == :MIMIC ||
				move.id == :POISONPOWDER ||
				move.id == :REFRESH || move.id == :ROLEPLAY ||
				move.id == :SCARYFACE || move.id == :SCREECH ||
				move.id == :SKETCH ||
				move.id == :INSTRUCT ||
				move.id == :FLORALHEALING ||
				move.id == :TARSHOT ||
				move.id == :GEARUP ||
				move.id == :STUFFCHEEKS ||
				move.id == :CORROSIVEGAS ||
				move.id == :TICKLE || move.id == :CHARGE ||
				move.id == :TRICKORTREAT || move.id == :VENOMDRENCH ||
				move.id == :MAGNETICFLUX || move.id == :FALLOUT ||
				move.id == :SANDSTORM || move.id == :HAIL ||
				move.id == :SUNNYDAY || move.id == :RAINDANCE)
			return 15
		elsif (move.id == :AQUARING || move.id == :BLOCK ||
				move.id == :CONVERSION2 || move.id == :ELECTRIFY ||
				move.id == :FLATTER || move.id == :GASTROACID ||
				move.id == :HEARTSWAP || move.id == :IONDELUGE ||
				move.id == :MEANLOOK ||
				move.id == :METRONOME || move.id == :COPYCAT ||
				move.id == :MIRRORMOVE || move.id == :MIST ||
				move.id == :PERISHSONG || move.id == :REST ||
				move.id == :ROAR || move.id == :SIMPLEBEAM || 
				move.id == :SPIDERWEB || move.id == :FLOWERSHIELD ||
				move.id == :SWAGGER || move.id == :SWEETKISS ||
				move.id == :POISONGAS || 
				move.id == :TOXICTHREAD || 
				move.id == :REBALANCING || 
				move.id == :TRANSFORM || move.id == :WHIRLWIND ||
				move.id == :WORRYSEED || move.id == :YAWN)
			return 20
		elsif (move.id == :AMNESIA || move.id == :ATTRACT ||
				move.id == :BARRIER || move.id == :BELLYDRUM ||
				move.id == :DESTINYBOND ||
				move.id == :DETECT || move.id == :DISABLE ||
				move.id == :ACIDARMOR || move.id == :COSMICPOWER ||
				move.id == :COTTONGUARD || move.id == :DEFENDORDER ||
				move.id == :FOLLOWME || move.id == :AUTOTOMIZE ||
				move.id == :IRONDEFENSE || move.id == :MINIMIZE || 
				move.id == :PSYCHOSHIFT || move.id == :GRAVITY ||
				move.id == :RAGEPOWDER || move.id == :ROCKPOLISH ||
				move.id == :STOCKPILE || move.id == :SUBSTITUTE ||
				move.id == :SWITCHEROO ||  move.id == :SWALLOW ||
				move.id == :TAUNT || 
				move.id == :OCTOLOCK || 
				move.id == :TOPSYTURVY ||
				move.id == :TRICK)
			return 25
		elsif (move.id == :BATONPASS || move.id == :BULKUP ||
				move.id == :CALMMIND || move.id == :COIL || 
				move.id == :CURSE || move.id == :ELECTRICTERRAIN ||
				move.id == :ENCORE || move.id == :SOAK ||
				move.id == :LEECHSEED || 
				move.id == :PAINSPLIT ||
				move.id == :WISH ||
				move.id == :GRASSYTERRAIN || move.id == :MISTYTERRAIN ||
				move.id == :NATUREPOWER || 
				move.id == :SLEEPTALK ||
				move.id == :NORETREAT ||
				move.id == :CLANGOROUSSOUL || 
				move.id == :TELEPORT ||
				move.id == :PURIFY ||
				move.id == :PSYCHICTERRAIN ||
				move.id == :TRICKROOM || move.id == :WONDERROOM)
			return 30
		elsif (move.id == :AROMATHERAPY || move.id == :NUCLEARWASTE ||
				move.id == :HEALBELL || move.id == :PARTINGSHOT || 
				move.id == :LIGHTSCREEN || move.id == :MATBLOCK ||
				move.id == :NASTYPLOT || move.id == :REFLECT ||
				move.id == :TAILWIND || move.id == :SPIKES ||
				move.id == :STEALTHROCK || move.id == :THUNDERWAVE ||
				move.id == :WILLOWISP ||  move.id == :TOXICSPIKES ||
				move.id == :TOXIC || 
				move.id == :GLARE ||
				move.id == :BITINGCOLD ||
				move.id == :WIDEGUARD || move.id == :HONECLAWS ||
				move.id == :STUNSPORE || move.id == :CONFUSERAY || 
				move.id == :SWORDSDANCE || move.id == :TAILGLOW)
			return 35
		elsif (move.id == :DRAGONDANCE || move.id == :GEOMANCY ||
				move.id == :QUIVERDANCE || move.id == :SHELLSMASH ||
				move.id == :SHIFTGEAR)
			return 40
		elsif (move.id == :STICKYWEB || move.id == :ROOST ||
				move.id == :SLACKOFF || move.id == :MILKDRINK ||
				move.id == :HEALORDER || move.id == :MOONLIGHT || move.id == :MORNINGSUN ||
				move.id == :SOFTBOILED ||	
				move.id == :JUNGLEHEALING || 
				move.id == :STRENGTHSAP || 
				move.id == :SHOREUP || 
				move.id == :AURORAVEIL || 
				move.id == :SYNTHESIS || 
				move.id == :RECOVER)
			return 60
		elsif (move.id == :PROTECT || move.id == :SPIKYSHIELD || move.id == :KINGSSHIELD || 
				move.id == :OBSTRUCT || move.id == :BANEFULBUNKER)
			return 80
		elsif (move.id == :SPORE ||  move.id == :HYPNOSIS || move.id == :SLEEPPOWDER || move.id == :SING ||
				move.id == :DARKVOID || move.id == :GRASSWHISTLE || move.id == :LOVELYKISS) 
			return 100
		else
			print move.name
			return 10
		end
	end
	
	# Disrupting Scores ##########################################################
	
	def getFieldDisruptScore(user, target, skill = 100)
    fieldscore = 100.0
		aroles = pbGetPokemonRole(user, target)
		oroles = pbGetPokemonRole(target, user)
    if @battle.field.terrain == :Electric # Electric Terrain, modified by JZ
      PBDebug.log(sprintf("Electric Terrain Disrupt")) if $INTERNAL
			target.eachAlly do |b|
				if target.pbHasType?(:ELECTRIC)
					fieldscore*=1.5
				end
      end
      if user.pbHasType?(:ELECTRIC)
        fieldscore*=0.5
      end
      partyelec=false
			@battle.pbParty(user.index).each do |m|
				next if m.fainted?
				partyelec=true if m.pbHasType?(:ELECTRIC)
				for z in m.moves
					sleepmove = true if [:HYPNOSIS, :GRASSWHISTLE, :LOVELYKISS, :SING, :DARKVOID].include?(z.id)
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
    if @battle.field.terrain == :Grassy # Grassy Terrain
      PBDebug.log(sprintf("Grassy Terrain Disrupt")) if $INTERNAL
			target.eachAlly do |b|
				if target.pbHasType?(:GRASS)
					fieldscore*=1.5
				end
      end
      if user.pbHasType?(:GRASS)
        fieldscore*=0.5
      end
      partygrass=false
			@battle.pbParty(user.index).each do |m|
				next if m.fainted?
				partygrass=true if m.pbHasType?(:GRASS)
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
    if @battle.field.terrain == :Misty # Misty Terrain
      PBDebug.log(sprintf("Misty Terrain Disrupt")) if $INTERNAL
      if user.spatk>user.attack
				target.eachAlly do |b|
					if target.pbHasType?(:FAIRY)
						fieldscore*=1.3
					end
				end
      end
      if target.spatk>target.attack
        if user.pbHasType?(:FAIRY)
          fieldscore*=0.7
        end
      end
      if target.pbHasType?(:DRAGON) || target.pbPartner.pbHasType?(:DRAGON)
        fieldscore*=0.5
      end
      if user.pbHasType?(:DRAGON)
        fieldscore*=1.5
      end
      partyfairy=false
			@battle.pbParty(user.index).each do |m|
				next if m.fainted?
				partyfairy=true if m.pbHasType?(:FAIRY)
			end
      if partyfairy
        fieldscore*=0.7
      end
      partydragon=false
			@battle.pbParty(user.index).each do |m|
				next if m.fainted?
				partydragon=true if m.pbHasType?(:DRAGON)
			end
      if partydragon
        fieldscore*=1.5
      end
    end
    if @battle.field.terrain == :Psychic # Psychic Terrain
      PBDebug.log(sprintf("Psychic Terrain Disrupt")) if $INTERNAL
			target.eachAlly do |b|
				if target.pbHasType?(:PSYCHIC)
					fieldscore*=1.7
				end
			end
      if user.pbHasType?(:PSYCHIC)
        fieldscore*=0.3
      end
      partypsy=false
			@battle.pbParty(user.index).each do |m|
				next if m.fainted?
				partypsy=true if m.pbHasType?(:PSYCHIC)
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
		if target.hasActiveAbility?(:SPEEDBOOST)
			PBDebug.log(sprintf("Speedboost Disrupt")) if $INTERNAL
			abilityscore*=1.1
			if target.stages[:SPEED]<2
				abilityscore*=1.3
			end
		end
		if target.hasActiveAbility?(:SANDVEIL)
			PBDebug.log(sprintf("Sand veil Disrupt")) if $INTERNAL
			if target.effectiveWeather == :Sandstorm
				abilityscore*=1.3
			end
		end
		if target.hasActiveAbility?([:VOLTABSORB, :LIGHTNINGROD, :MOTORDRIVE])
			PBDebug.log(sprintf("Volt Absorb Disrupt")) if $INTERNAL
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
			PBDebug.log(sprintf("Water Absorb Disrupt")) if $INTERNAL
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
			if $INTERNAL
				if target.hasActiveAbility?(:FLASHFIRE)
					PBDebug.log(sprintf("Flash Fire Disrupt"))
				else 
					PBDebug.log(sprintf("Heatproof Disrupt"))
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
			PBDebug.log(sprintf("Levitate Disrupt")) if $INTERNAL
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
			PBDebug.log(sprintf("Shadow Tag Disrupt")) if $INTERNAL
			if !user.hasActiveAbility?(:SHADOWTAG)
				abilityscore*=1.5
			end
		end    
		if target.hasActiveAbility?(:ARENATRAP)
			PBDebug.log(sprintf("Arena Trap Disrupt")) if $INTERNAL
			if !user.airborne?
				abilityscore*=1.5
			end
		end  
		if target.hasActiveAbility?(:WONDERGUARD)
			PBDebug.log(sprintf("Wonder Guard Disrupt")) if $INTERNAL
			wondervar=false
			for i in user.moves
				if Effectiveness.super_effective?(i.type)
					wondervar=true
				end
			end
			if !wondervar
				abilityscore*=5
			end      
		end
		if target.hasActiveAbility?(:SERENEGRACE)
			PBDebug.log(sprintf("Serene Grace Disrupt")) if $INTERNAL
			abilityscore*=1.3
		end  
		if target.hasActiveAbility?(:PUREPOWER) || target.hasActiveAbility?(:HUGEPOWER)
			PBDebug.log(sprintf("Pure Power Disrupt")) if $INTERNAL
			abilityscore*=2
		end
		if target.hasActiveAbility?(:SOUNDPROOF)
			PBDebug.log(sprintf("Soundproof Disrupt")) if $INTERNAL
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
			PBDebug.log(sprintf("Thick Fat Disrupt")) if $INTERNAL
			totalguard=true
			for i in user.moves
				if i.type == :FIRE && i.type == :ICE
					totalguard=false
				end
			end      
			if totalguard
				abilityscore*=1.5
			end
		end
		if target.hasActiveAbility?(:TRUANT)
			PBDebug.log(sprintf("Truant Disrupt")) if $INTERNAL
			abilityscore*=0.1
		end 
		if target.hasActiveAbility?(:GUTS) || target.hasActiveAbility?(:QUICKFEET) || target.hasActiveAbility?(:MARVELSCALE)
			PBDebug.log(sprintf("Guts Disrupt")) if $INTERNAL
			if target.pbHasAnyStatus?
				abilityscore*=1.5
			end      
		end 
		if target.hasActiveAbility?(:LIQUIDOOZE)
			PBDebug.log(sprintf("Liquid Ooze Disrupt")) if $INTERNAL
			if target.effects[PBEffects::LeechSeed]>=0 || user.pbHasMove?(:LEECHSEED)
				abilityscore*=2
			end              
		end 
		if target.hasActiveAbility?(:AIRLOCK) || target.hasActiveAbility?(:CLOUDNINE)
			PBDebug.log(sprintf("Airlock Disrupt")) if $INTERNAL
			abilityscore*=1.1
		end 
		if target.hasActiveAbility?(:HYDRATION)
			PBDebug.log(sprintf("Hydration Disrupt")) if $INTERNAL
			if [:Rain, :HeavyRain].include?(target.effectiveWeather)
				abilityscore*=1.3
			end
		end
		if target.hasActiveAbility?(:ADAPTABILITY)
			PBDebug.log(sprintf("Adaptability Disrupt")) if $INTERNAL
			abilityscore*=1.3
		end 
		if target.hasActiveAbility?(:SKILLLINK)
			PBDebug.log(sprintf("Skill Link Disrupt")) if $INTERNAL
			abilityscore*=1.5
		end 
		if target.hasActiveAbility?(:POISONHEAL)
			PBDebug.log(sprintf("Poison Heal Disrupt")) if $INTERNAL
			if target.poisoned?
				abilityscore*=2
			end      
		end 
		if target.hasActiveAbility?(:NORMALIZE)
			PBDebug.log(sprintf("Normalize Disrupt")) if $INTERNAL
			abilityscore*=0.6
		end 
		if target.hasActiveAbility?(:MAGICGUARD)
			PBDebug.log(sprintf("Magic Guard Disrupt")) if $INTERNAL
			abilityscore*=1.4
		end 
		if target.hasActiveAbility?(:STALL)
			PBDebug.log(sprintf("Stall Disrupt")) if $INTERNAL
			abilityscore*=1.5
		end 
		if target.hasActiveAbility?(:TECHNICIAN)
			PBDebug.log(sprintf("Technician Disrupt")) if $INTERNAL
			abilityscore*=1.3
		end 
		if target.hasActiveAbility?(:GALEWINGS)
			PBDebug.log(sprintf("Gale Wings Disrupt")) if $INTERNAL
			abilityscore*=2
		end 	
		if target.hasActiveAbility?(:UNBURDEN)
			if target.effects[PBEffects::Unburden] && target.hasActiveAbility?(:UNBURDEN)
				PBDebug.log(sprintf("Unburden Disrupt")) if $INTERNAL
				abilityscore*=2
			end	
		end 			
		if target.hasActiveAbility?(:MOLDBREAKER) || 
			 (target.isSpecies?(:GYARADOS) && (target.item == :GYARADOSITE || target.hasMegaEvoMutation?)) ||
			 (target.isSpecies?(:LUPACABRA) && (target.item == :LUPACABRITE || target.hasMegaEvoMutation?))
			PBDebug.log(sprintf("Mold Breaker Disrupt")) if $INTERNAL
			abilityscore*=1.1
		end 
		if target.hasActiveAbility?(:UNAWARE)
			PBDebug.log(sprintf("Unaware Disrupt")) if $INTERNAL
			abilityscore*=1.7
		end 
		if target.hasActiveAbility?(:SLOWSTART)
			PBDebug.log(sprintf("Slow Start Disrupt")) if $INTERNAL
			abilityscore*=0.3
		end 
		if target.hasActiveAbility?(:SHEERFORCE)
			PBDebug.log(sprintf("Sheer Force Disrupt")) if $INTERNAL
			abilityscore*=1.2
		end 
		if target.hasActiveAbility?(:PUNKROCK)
			PBDebug.log(sprintf("Soundboost Disrupt")) if $INTERNAL
			abilityscore*=1.2
		end 
		if target.hasActiveAbility?(:CONTRARY)
			PBDebug.log(sprintf("Contrary Disrupt")) if $INTERNAL
			abilityscore*=1.4
			if target.stages[:ATTACK]>0 || target.stages[:SPECIAL_ATTACK]>0 || target.stages[:DEFENSE]>0 || 
				 target.stages[:SPECIAL_DEFENSE]>0 || target.stages[:SPEED]>0
				if target.pbHasMove?(:CLOSECOMBAT) || target.pbHasMove?(:OVERHEAT) || target.pbHasMove?(:LEAFSTORM) ||
					 target.pbHasMove?(:DRACOMETEOR) || target.pbHasMove?(:SUPERPOWER) ||
					 target.pbHasMove?(:PSYCHOBOOST) || target.pbHasMove?(:VCREATE) ||
					 target.pbHasMove?(:HAMMERARM) || target.pbHasMove?(:DRAGONASCENT)
					abilityscore*=3
				end		
			end              
		end 
		if target.hasActiveAbility?(:DEFEATIST)
			PBDebug.log(sprintf("Defeatist Disrupt")) if $INTERNAL
			abilityscore*=0.5
		end 
		if target.hasActiveAbility?(:MULTISCALE) || target.hasActiveAbility?(:SHADOWSHIELD)
			PBDebug.log(sprintf("Multiscale Disrupt")) if $INTERNAL
			if target.hp==target.totalhp
				abilityscore*=1.5
			end      
		end 
		if target.hasActiveAbility?(:HARVEST)
			PBDebug.log(sprintf("Harvest Disrupt")) if $INTERNAL
			abilityscore*=1.2
		end 
		if target.hasActiveAbility?(:MOODY)
			PBDebug.log(sprintf("Moody Disrupt")) if $INTERNAL
			abilityscore*=1.8
		end 
		if target.hasActiveAbility?(:SAPSIPPER)
			PBDebug.log(sprintf("Sap Sipper Disrupt")) if $INTERNAL
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
			PBDebug.log(sprintf("Prankster Disrupt")) if $INTERNAL
			if user.speed>target.speed
				abilityscore*=1.5
			end      
		end
		if target.hasActiveAbility?(:SNOWCLOAK)
			PBDebug.log(sprintf("Snow Cloak Disrupt")) if $INTERNAL
			if target.effectiveWeather == :Hail
				abilityscore*=1.1
			end
		end
		if target.hasActiveAbility?(:FURCOAT)
			PBDebug.log(sprintf("Fur Coat Disrupt")) if $INTERNAL
			if user.attack>user.spatk
				abilityscore*=1.5
			end      
		end
		if target.hasActiveAbility?(:PARENTALBOND)
			PBDebug.log(sprintf("Parental Bond Disrupt")) if $INTERNAL
			abilityscore*=3
		end 
		if target.hasActiveAbility?(:PROTEAN)
			PBDebug.log(sprintf("Protean Disrupt")) if $INTERNAL
			abilityscore*=3
		end 
		if target.hasActiveAbility?(:TOUGHCLAWS)
			PBDebug.log(sprintf("Tough Claws Disrupt")) if $INTERNAL
			abilityscore*=1.2
		end 
    if target.hasActiveAbility?(:BEASTBOOST)
      PBDebug.log(sprintf("Beast Boost Disrupt")) if $INTERNAL
      abilityscore*=1.1
    end 
    if target.hasActiveAbility?(:COMATOSE)
      PBDebug.log(sprintf("Comatose Disrupt")) if $INTERNAL
      abilityscore*=1.3
    end 
    if target.hasActiveAbility?(:FLUFFY)
      PBDebug.log(sprintf("Fluffy Disrupt")) if $INTERNAL
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
      PBDebug.log(sprintf("Merciless Disrupt")) if $INTERNAL
      abilityscore*=1.3
    end 
    if target.hasActiveAbility?(:WATERBUBBLE)
      PBDebug.log(sprintf("Water Bubble Disrupt")) if $INTERNAL
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
		if target.unstoppableAbility?
			PBDebug.log(sprintf("Unstoppable Ability Disrupt")) if $INTERNAL
			abilityscore*=0
		end 
		# Disrupt scores for Untamed abilities
    if target.hasActiveAbility?([:AMPLIFIER, :SEANCE, :MICROSTRIKE, :BLADEMASTER, :MOMENTUM, :ANGELICBEAUTY])
			abilityscore*=1.2
		end
    if target.hasActiveAbility?([:BAITEDLINE, :FERVOR, :CRYSTALJAW, :JUNGLEFURY, :ENIGMIZE])
			abilityscore*=1.3
		end
    if target.hasActiveAbility?([:PARTYPOPPER, :WARRIORSPIRIT, :SLIPPERYPEEL, :TRICKSTER, :MASSEXTINCTION, :PREMONITION, :PRESAGE])
			abilityscore*=1.6
		end
		abilityscore*=0.01
		return abilityscore
	end
	
	def pbAICritRate(attacker,opponent,move)
		return 0 if opponent.hasActiveAbility?([:BATTLEARMOR, :SHELLARMOR])
		return 0 if opponent.pbOwnSide.effects[PBEffects::LuckyChant]>0
		return 3 if move.function=="AlwaysCriticalHit" # Frost Breath
		c=0
		c+=attacker.effects[PBEffects::FocusEnergy]
		c+=1 if move.highCriticalRate?
		c+=1 if attacker.hasActiveAbility?(:SUPERLUCK)
		c+=1 if attacker.hasActiveItem?(:RAZORCLAW)
		c+=1 if attacker.hasActiveItem?(:SCOPELENS)
		c=50 if attacker.hasActiveAbility?(:MERCILESS) && opponent.poisoned?
		c=3 if c>3
		return c
	end
end