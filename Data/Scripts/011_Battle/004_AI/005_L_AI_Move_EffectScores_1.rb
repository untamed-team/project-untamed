class Battle::AI
  #=============================================================================
  # Get a score for the given move based on its effect
  #=============================================================================
  def pbGetMoveScoreFunctionCode(score, move, user, target, skill = 100)
	mold_broken = moldbroken(user,target,move)
	globalArray = pbGetMidTurnGlobalChanges
	procGlobalArray = processGlobalArray(globalArray)
	expectedWeather = procGlobalArray[0]
	expectedTerrain = procGlobalArray[1]
	aspeed = pbRoughStat(user,:SPEED,skill)
	ospeed = pbRoughStat(target,:SPEED,skill)
	userFasterThanTarget = ((aspeed>=ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
    case move.function
    #---------------------------------------------------------------------------
    when "Struggle"
    #---------------------------------------------------------------------------
    when "None" # No extra effect
    #---------------------------------------------------------------------------
    when "DoesNothingCongratulations", "DoesNothingFailsIfNoAlly", # Hold Hands, Celebrate
         "DoesNothingUnusableInGravity", "DoubleMoneyGainedFromBattle" # Splash, Happy Hour
      score = 0
    #---------------------------------------------------------------------------
    when "FailsIfNotUserFirstTurn" # first impression
		if user.turnCount > 0
			score = 0
		else
			score*=1.1
			if !targetSurvivesMove(move,user,target)
				score*=1.5
			end
		end
    #---------------------------------------------------------------------------
    when "FailsIfUserHasUnusedMove" # Last Resort
		hasThisMove = false
		hasOtherMoves = false
		hasUnusedMoves = false
		user.eachMove do |m|
			hasThisMove    = true if m.id == @id
			hasOtherMoves  = true if m.id != @id
			hasUnusedMoves = true if m.id != @id && !user.movesUsed.include?(m.id)
		end
		if !hasThisMove || !hasOtherMoves || hasUnusedMoves
			score=0
		end
    #---------------------------------------------------------------------------
    when "FailsIfUserNotConsumedBerry" # Belch
      score = 0 if !user.belched?
    #---------------------------------------------------------------------------
    when "FailsIfTargetHasNoItem" # poltergeist
		if !target.item || !target.itemActive?
			score = 0
		else
			score *= 1.3
		end
    #---------------------------------------------------------------------------
    when "FailsUnlessTargetSharesTypeWithUser" # synchronoise
      if !(user.types[0] && target.pbHasType?(user.types[0], true)) &&
         !(user.types[1] && target.pbHasType?(user.types[1], true))
        score = 0
      end
    #---------------------------------------------------------------------------
    when "FailsIfUserDamagedThisTurn" # focus punch
		soundcheck=target.moves.any? { |m| m&.ignoresSubstitute?(target) } # includes infiltrator
		multicheck=target.moves.any? { |m| m&.multiHitMove? }
		if (target.hasActiveAbility?(:DISGUISE,false,mold_broken) && target.form == 0) || target.effects[PBEffects::Substitute]>0
			if multicheck || soundcheck
				score*=0.9
			else
				score*=1.3
			end
		else
			if targetWillMove?(target, "status") || @battle.choices[target.index][0] == :SwitchOut
				score *= 1.3
			else
				score *= 0.5
			end
		end
		if target.asleep? && (target.statusCount>=1 || !target.hasActiveAbility?(:EARLYBIRD)) && !target.hasActiveAbility?(:SHEDSKIN)
			score*=1.2
		end
		hasAlly = !target.allAllies.empty?
		if hasAlly
			score *= 0.5
		end
		if target.effects[PBEffects::HyperBeam]>0
			score*=1.5
		end
    #---------------------------------------------------------------------------
    when "FailsIfTargetActed" # sucker punch
		pricheck = target.moves.any? { |m| priorityAI(target,m)>0 }
		healcheck = target.moves.any? { |m| m&.healingMove? }
		alldam = target.moves.all? { |m| m.baseDamage > 0 }
		setupcheck = pbHasSetupMove?(target, false)
		if targetWillMove?(target)
			if @battle.choices[target.index][2].statusMove?
				score*=0.3
			else
				score*=1.5
			end
		else
			score*=0.1
		end
		if alldam && !pricheck
			score*=1.3
		else
			suckr = (user.lastMoveUsed == :SUCKERPUNCH) # Sucker Punch last turn
			if suckr
				if healcheck
					score*=0.6
				end
				if setupcheck
					score*=0.8
				end
				if setupvar
					score*=0.5
				end
			end
			if userFasterThanTarget
				score*=0.8
			else
				if suckr
					if pricheck
						score*=0.5
					else
						score*=1.3
					end
				end
			end
		end
    #---------------------------------------------------------------------------
    when "CrashDamageIfFailsUnusableInGravity" # high jump kick
		score*=0.5 if pbHasSingleTargetProtectMove?(target) && 
					 !(user.hasActiveAbility?(:UNSEENFIST) && move.pbContactMove?(user))
		currentAcc = pbRoughAccuracy(move,user,target,100)
		if currentAcc < 100
			score*=0.8 if targetSurvivesMove(move,user,target)
			ministat=user.stages[:ACCURACY]
			ministat=0 if user.stages[:ACCURACY]<0
			ministat*=(10)
			ministat+=100
			ministat/=100.0
			score*=ministat
		end
		if @battle.choices[target.index][0] == :SwitchOut
			realTarget = @battle.pbMakeFakeBattler(@battle.pbParty(target.index)[@battle.choices[target.index][1]],false,target)
			score = 0 if pbCheckMoveImmunity(1, move, user, realTarget, skill)
		end
		score = 0 if @battle.field.effects[PBEffects::Gravity] > 0 && !user.hasActiveItem?(:FLOATSTONE)
    #---------------------------------------------------------------------------
    when "StartSunWeather" # sunny day
		if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
		   @battle.pbCheckGlobalAbility(:CLOUDNINE) ||
		   (expectedWeather == :Sun && !user.hasActiveItem?(:UTILITYUMBRELLA))
			score = 0
		else
			score*=1.6 if user.pbOpposingSide.effects[PBEffects::AuroraVeil] > 0
			score*=0.6 if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
			if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && 
			   !user.takesHailDamage? && !user.takesSandstormDamage?)
				score*=1.3
			end
			roles = pbGetPokemonRole(user, target)
			if roles.include?("Lead")
				score*=1.2
			end
			if user.hasActiveItem?(:HEATROCK)
				score*=1.3
			end
			if user.pbHasMove?(:WEATHERBALL)
				score*=2
			end
			if @battle.field.weather != :None && @battle.field.weather != :Sun
				score*=1.5
			end
			if user.pbHasMove?(:MOONLIGHT) || user.pbHasMove?(:SYNTHESIS) || user.pbHasMove?(:MORNINGSUN) ||
			   user.pbHasMove?(:GROWTH) || user.pbHasMove?(:SOLARBEAM) || user.pbHasMove?(:SOLARBLADE)
				score*=1.5
			end
			if user.pbHasType?(:FIRE, true)
				score*=1.5
			end
			if user.hasActiveAbility?([:CHLOROPHYLL, :FLOWERGIFT])
				score*=2
				if user.hasActiveItem?(:FOCUSASH)
					score*=2
				end
				# ???? i dont get what this thing does
				if user.effects[PBEffects::Protect] ||
					user.effects[PBEffects::Obstruct] ||
					user.effects[PBEffects::KingsShield] || 
					user.effects[PBEffects::BanefulBunker] ||
					user.effects[PBEffects::SpikyShield]
					score *=3
				end
			end
			if user.hasActiveAbility?([:SOLARPOWER, :LEAFGUARD, :HEALINGSUN, :COOLHEADED])
				score*=1.3
			end
			watervar=false
			@battle.pbParty(user.index).each_with_index do |m, i|
				next if m.fainted?
				next if [:XOLSMOL, :AMPHIBARK, :PEROXOTAL].include?(m.species)
				watervar=true if m.hasType?(:WATER)
			end
			if watervar
				score*=0.5
			end 
			if user.pbHasMove?(:THUNDER) || user.pbHasMove?(:HURRICANE)
				score*=0.7
			end
			if user.hasActiveAbility?(:DRYSKIN)
				score*=0.5
			end
			if user.hasActiveAbility?(:HARVEST)
				score*=1.5
			end
			# check how good the current/mega ability weather is for the opponent
			score*=(1 + (checkWeatherBenefit(target, globalArray, true)) / 100.0)
			# check how good the potential weather change is for us
			score*=(1 + (checkWeatherBenefit(user, globalArray, true, :Sun) / 100.0))
			# check how good the potential weather change is for the opponent
			score*=(1 / (1 + (checkWeatherBenefit(target, globalArray, true, :Sun) / 100.0)))
		end
    #---------------------------------------------------------------------------
    when "StartRainWeather" # rain dance
		if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
		   @battle.pbCheckGlobalAbility(:CLOUDNINE) ||
		   (expectedWeather == :Rain && !user.hasActiveItem?(:UTILITYUMBRELLA))
			score = 0
		else
			score*=1.6 if user.pbOpposingSide.effects[PBEffects::AuroraVeil] > 0
			score*=0.6 if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
			if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && 
					!user.takesHailDamage? && !user.takesSandstormDamage?)
				score*=1.3
			end
			roles = pbGetPokemonRole(user, target)
			if roles.include?("Lead")
				score*=1.2
			end
			if user.hasActiveItem?(:DAMPROCK)
				score*=1.3
			end
			if user.pbHasMove?(:WEATHERBALL)
				score*=2
			end
			if @battle.field.weather != :None && @battle.field.weather != :Rain
				score*=1.5
			end
			if user.pbHasMove?(:THUNDER) || user.pbHasMove?(:HURRICANE) || user.pbHasMove?(:STEAMBURST)
				score*=1.5
			end
			if user.pbHasType?(:WATER, true)
				score*=1.5
			end
			if user.hasActiveAbility?(:SWIFTSWIM)
				score*=2
				if user.hasActiveItem?(:FOCUSASH)
					score*=2
				end
				# ???? i dont get what this thing does
				if user.effects[PBEffects::Protect] ||
				   user.effects[PBEffects::Obstruct] ||
				   user.effects[PBEffects::KingsShield] || 
				   user.effects[PBEffects::BanefulBunker] ||
				   user.effects[PBEffects::SpikyShield]
					score *=3
				end
			end
			if user.hasActiveAbility?(:DRYSKIN)
				score*=1.3
			end
			firevar=false
			@battle.pbParty(user.index).each_with_index do |m, i|
				next if m.fainted?
				next if [:XOLSMOL, :AMPHIBARK, :PEROXOTAL].include?(m.species)
				firevar=true if m.hasType?(:FIRE)
			end
			if firevar
				score*=0.5
			end 
			if user.pbHasMove?(:MOONLIGHT) || user.pbHasMove?(:SYNTHESIS) || user.pbHasMove?(:MORNINGSUN) ||
			   user.pbHasMove?(:GROWTH) || user.pbHasMove?(:SOLARBEAM) || user.pbHasMove?(:SOLARBLADE)
				score*=0.5
			end
			if user.hasActiveAbility?(:HYDRATION)
				score*=1.5
			end
			score*=(1 + (checkWeatherBenefit(target, globalArray, true)) / 100.0)
			score*=(1 + (checkWeatherBenefit(user, globalArray, true, :Rain) / 100.0))
			score*=(1 / (1 + (checkWeatherBenefit(target, globalArray, true, :Rain) / 100.0)))
		end
    #---------------------------------------------------------------------------
    when "StartSandstormWeather" # sandstorm
		if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
		   @battle.pbCheckGlobalAbility(:CLOUDNINE) ||
		   expectedWeather == :Sandstorm
			score = 0
		else
			score*=1.6 if user.pbOpposingSide.effects[PBEffects::AuroraVeil] > 0
			score*=0.6 if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
			if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && 
			   !user.takesHailDamage? && !user.takesSandstormDamage?)
				score*=1.3
			end
			roles = pbGetPokemonRole(user, target)
			if roles.include?("Lead")
				score*=1.2
			end
			if user.hasActiveItem?(:SMOOTHROCK)
				score*=1.3
			end
			if user.pbHasMove?(:WEATHERBALL)
				score*=2
			end
			if @battle.field.weather != :None && expectedWeather != :Sandstorm
				score*=1.5
			end
			if user.takesSandstormDamage?
				score*=0.7
			else
				score*=1.3
			end
			if user.pbHasType?(:ROCK, true)
				score*=1.5
			end
			if user.hasActiveAbility?(:SANDRUSH)
				score*=2
				if user.hasActiveItem?(:FOCUSASH)
					score*=2
				end
				# ???? i dont get what this thing does
				if user.effects[PBEffects::Protect] ||
				   user.effects[PBEffects::Obstruct] ||
				   user.effects[PBEffects::KingsShield] || 
				   user.effects[PBEffects::BanefulBunker] ||
				   user.effects[PBEffects::SpikyShield]
					score *=3
				end
			end
			if user.hasActiveAbility?(:SANDVEIL)
				score*=1.3
			end
			if user.pbHasMove?(:MOONLIGHT) || user.pbHasMove?(:SYNTHESIS) || user.pbHasMove?(:MORNINGSUN) ||
			   user.pbHasMove?(:GROWTH) || user.pbHasMove?(:SOLARBEAM) || user.pbHasMove?(:SOLARBLADE)
				score*=0.5
			end
			if user.pbHasMove?(:SHOREUP)
				score*=1.5
			end
			if user.hasActiveAbility?(:SANDFORCE)
				score*=1.5
			end
			score*=(1 + (checkWeatherBenefit(target, globalArray, true) / 100.0))
			score*=(1 + (checkWeatherBenefit(user, globalArray, true, :Sandstorm) / 100.0))
			score*=(1 / (1 + (checkWeatherBenefit(target, globalArray, true, :Sandstorm) / 100.0)))
		end
    #---------------------------------------------------------------------------
    when "StartHailWeather" # hail
		if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
		   @battle.pbCheckGlobalAbility(:CLOUDNINE) ||
		   expectedWeather == :Hail
			score = 0
		else
			score*=1.6 if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
			if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && 
			   !user.takesHailDamage? && !user.takesSandstormDamage?)
				score*=1.3
			end
			roles = pbGetPokemonRole(user, target)
			if roles.include?("Lead")
				score*=1.2
			end
			if user.hasActiveItem?(:ICYROCK)
				score*=1.3
			end
			if user.pbHasMove?(:WEATHERBALL)
				score*=2
			end
			if @battle.field.weather != :None && @battle.field.weather != :Hail
				score*=1.5
			end
			if user.takesHailDamage?
				score*=0.7
			else
				score*=1.3
			end
			if user.pbHasType?(:ICE, true)
				score*=5 # jeez thats a fat boost
			end
			if user.hasActiveAbility?(:SLUSHRUSH)
				score*=2
				if user.hasActiveItem?(:FOCUSASH)
					score*=2
				end
				# ???? i dont get what this thing does
				if user.effects[PBEffects::Protect] ||
				   user.effects[PBEffects::Obstruct] ||
				   user.effects[PBEffects::KingsShield] || 
				   user.effects[PBEffects::BanefulBunker] ||
				   user.effects[PBEffects::SpikyShield]
					score *=3
				end
			end
			if user.hasActiveAbility?([:SNOWCLOAK, :ICEBODY, :HOTHEADED])
				score*=1.3
			end
			if user.pbHasMove?(:MOONLIGHT) || user.pbHasMove?(:SYNTHESIS) || user.pbHasMove?(:MORNINGSUN) ||
			   user.pbHasMove?(:GROWTH) || user.pbHasMove?(:SOLARBEAM) || user.pbHasMove?(:SOLARBLADE)
				score*=0.5
			end
			if user.pbHasMove?(:AURORAVEIL)
				score*=2
			end
			if user.pbHasMove?(:BLIZZARD)
				score*=1.3
			end
			score*=(1 + (checkWeatherBenefit(target, globalArray, true) / 100.0))
			score*=(1 + (checkWeatherBenefit(user, globalArray, true, :Hail) / 100.0))
			score*=(1 / (1 + (checkWeatherBenefit(target, globalArray, true, :Hail) / 100.0)))
		end
    #---------------------------------------------------------------------------
    when "StartElectricTerrain" # Electric Terrain
		if expectedTerrain == :Electric
			score=0
		else
			sleepvar=false
			sleepvar=true if target.pbHasMoveFunction?("SleepTarget","SleepTargetIfUserDarkrai")
			miniscore = getFieldDisruptScore(user,target,globalArray,skill)
			if user.hasActiveAbility?(:SURGESURFER)
				miniscore*=1.5
			end
			if user.pbHasType?(:ELECTRIC, true)
				miniscore*=1.5
			end
			elecvar=false
			@battle.pbParty(user.index).each_with_index do |m, i|
				next if m.fainted?
				elecvar=true if m.hasType?(:ELECTRIC)
			end
			if elecvar
				miniscore*=2
			end
			if target.pbHasType?(:ELECTRIC, true)
				miniscore*=0.5
			end
			miniscore*=0.5 if user.pbHasMoveFunction?("SleepTarget","SleepTargetIfUserDarkrai")
			if sleepvar
				miniscore*=2
			end
			if user.hasActiveItem?(:TERRAINEXTENDER)
				miniscore*=2
			end
			score*=miniscore
			score*=(1 + (checkWeatherBenefit(target, globalArray, false, nil, true) / 100.0))
			score*=(1 + (checkWeatherBenefit(user, globalArray, false, nil, true, :Electric) / 100.0))
			score*=(1 / (1 + (checkWeatherBenefit(target, globalArray, false, nil, true, :Electric) / 100.0)))
		end
    #---------------------------------------------------------------------------
    when "StartGrassyTerrain" # grassy terrain
		if expectedTerrain == :Grassy
			score=0
		else
			healvar=target.moves.any? { |m| m&.healingMove? }
			grassvar=false
			@battle.pbParty(user.index).each_with_index do |m, i|
				next if m.fainted?
				grassvar=true if m.hasType?(:GRASS)
			end
			roles = pbGetPokemonRole(user, target)
			miniscore = getFieldDisruptScore(user,target,globalArray,skill)
			if roles.include?("Physical Wall") || roles.include?("Special Wall")
				miniscore*=1.5
			end
			if healvar
				miniscore*=0.5
			end
			if user.pbHasType?(:GRASS, true)
				miniscore*=2
			end
			if grassvar
				miniscore*=2
			end
			if user.hasActiveAbility?(:GRASSPELT)
				miniscore*=1.5
			end
			if user.hasActiveItem?(:TERRAINEXTENDER)
				miniscore*=2
			end
			score*=miniscore
			score*=(1 + (checkWeatherBenefit(target, globalArray, false, nil, true) / 100.0))
			score*=(1 + (checkWeatherBenefit(user, globalArray, false, nil, true, :Grassy) / 100.0))
			score*=(1 / (1 + (checkWeatherBenefit(target, globalArray, false, nil, true, :Grassy) / 100.0)))
		end
    #---------------------------------------------------------------------------
    when "StartMistyTerrain" # misty terrain
		if expectedTerrain == :Misty
			score=0
		else
			healvar=target.moves.any? { |m| m&.healingMove? }
			fairyvar=false
			@battle.pbParty(user.index).each_with_index do |m, i|
				next if m.fainted?
				fairyvar=true if m.hasType?(:FAIRY)
			end
			roles = pbGetPokemonRole(user, target)
			miniscore = getFieldDisruptScore(user,target,globalArray,skill)
			if fairyvar
				miniscore*=2
			end
			if !user.pbHasType?(:FAIRY, true) && target.pbHasType?(:DRAGON, true)
				miniscore*=2
			end
			if user.pbHasType?(:DRAGON, true)
				miniscore*=0.5
			end
			if target.pbHasType?(:FAIRY, true)
				miniscore*=0.5
			end
			if user.pbHasType?(:FAIRY, true) && target.spatk>target.attack
				miniscore*=2
			end
			if user.hasActiveItem?(:TERRAINEXTENDER)
				miniscore*=2
			end
			score*=miniscore
			score*=(1 + (checkWeatherBenefit(target, globalArray, false, nil, true) / 100.0))
			score*=(1 + (checkWeatherBenefit(user, globalArray, false, nil, true, :Misty) / 100.0))
			score*=(1 / (1 + (checkWeatherBenefit(target, globalArray, false, nil, true, :Misty) / 100.0)))
		end
    #---------------------------------------------------------------------------
    when "StartPsychicTerrain" # psychic terrain
		if expectedTerrain == :Psychic
			score=0
		else
			privar=target.moves.any? { |m| priorityAI(target,m)>0 }
			pricheck=user.moves.any? { |m| priorityAI(target,m)>0 }
			psyvar=false
			@battle.pbParty(user.index).each_with_index do |m, i|
				next if m.fainted?
				psyvar=true if m.hasType?(:PSYCHIC)
			end
			roles = pbGetPokemonRole(user, target)
			miniscore = getFieldDisruptScore(user,target,globalArray,skill)
			if user.hasActiveAbility?(:TELEPATHY)
				miniscore*=1.5
			end  
			if user.pbHasType?(:PSYCHIC, true)
				miniscore*=1.5
			end  
			if psyvar
				miniscore*=2
			end
			if pricheck
				miniscore*=0.7
			end
			if privar
				miniscore*=1.3
			end  
			if user.hasActiveItem?(:TERRAINEXTENDER)
				miniscore*=2
			end
			score*=miniscore
			score*=(1 + (checkWeatherBenefit(target, globalArray, false, nil, true) / 100.0))
			score*=(1 + (checkWeatherBenefit(user, globalArray, false, nil, true, :Psychic) / 100.0))
			score*=(1 / (1 + (checkWeatherBenefit(target, globalArray, false, nil, true, :Psychic) / 100.0)))
		end
    #---------------------------------------------------------------------------
    when "RemoveTerrain" # Steel Roller
		miniscore = getFieldDisruptScore(user,target,globalArray,skill) * 100.0
		if expectedTerrain == :Electric
			if target.hasActiveAbility?(:SURGESURFER)
				miniscore*=1.5
			end
			if target.pbHasType?(:ELECTRIC, true)
				miniscore*=1.5
			end
			elecvar=false
			@battle.pbParty(target.index).each_with_index do |m, i|
				next if m.fainted?
				elecvar=true if m.hasType?(:ELECTRIC)
			end
			if elecvar
				miniscore*=2
			end
			if user.pbHasType?(:ELECTRIC, true)
				miniscore*=0.5
			end
			miniscore*=0.5 if target.pbHasMoveFunction?("SleepTarget","SleepTargetIfUserDarkrai")
			miniscore*=2 if user.pbHasMoveFunction?("SleepTarget","SleepTargetIfUserDarkrai")
			if target.hasActiveItem?(:TERRAINEXTENDER)
				miniscore*=1.2
			end
		elsif expectedTerrain == :Grassy
			healvar=target.moves.any? { |m| m&.healingMove? }
			grassvar=false
			@battle.pbParty(target.index).each_with_index do |m, i|
				next if m.fainted?
				grassvar=true if m.hasType?(:GRASS)
			end
			oroles = pbGetPokemonRole(target, user)
			if oroles.include?("Physical Wall") || oroles.include?("Special Wall")
				miniscore*=1.5
			end
			if healvar
				miniscore*=0.5
			end
			if target.pbHasType?(:GRASS, true)
				miniscore*=2
			end
			if grassvar
				miniscore*=2
			end
			if target.hasActiveAbility?(:GRASSPELT)
				miniscore*=1.5
			end
			if target.hasActiveItem?(:TERRAINEXTENDER)
				miniscore*=1.2
			end
		elsif expectedTerrain == :Misty
			healvar=target.moves.any? { |m| m&.healingMove? }
			fairyvar=false
			@battle.pbParty(target.index).each_with_index do |m, i|
				next if m.fainted?
				fairyvar=true if m.hasType?(:FAIRY)
			end
			if fairyvar
				miniscore*=2
			end
			if !target.pbHasType?(:FAIRY, true) && user.pbHasType?(:DRAGON, true)
				miniscore*=2
			end
			if target.pbHasType?(:DRAGON, true)
				miniscore*=0.5
			end
			if user.pbHasType?(:FAIRY, true)
				miniscore*=0.5
			end
			if target.pbHasType?(:FAIRY, true) && user.spatk>user.attack
				miniscore*=2
			end
			if target.hasActiveItem?(:TERRAINEXTENDER)
				miniscore*=1.2
			end
		elsif expectedTerrain == :Psychic
			privar=user.moves.any? { |m| priorityAI(target,m)>0 }
			pricheck=target.moves.any? { |m| priorityAI(target,m)>0 }
			psyvar=false
			@battle.pbParty(target.index).each_with_index do |m, i|
				next if m.fainted?
				psyvar=true if m.hasType?(:PSYCHIC)
			end
			if target.hasActiveAbility?(:TELEPATHY)
				miniscore*=1.5
			end  
			if target.pbHasType?(:PSYCHIC, true)
				miniscore*=1.5
			end  
			if psyvar
				miniscore*=2
			end
			if pricheck
				miniscore*=0.7
			end
			if privar
				miniscore*=1.3
			end  
			if target.hasActiveItem?(:TERRAINEXTENDER)
				miniscore*=1.2
			end
		elsif expectedTerrain == :None
			miniscore = 0
		end
		miniscore/=100.0
		score*=miniscore
    #---------------------------------------------------------------------------
    when "AddSpikesToFoeSide" # spikes
		if user.pbOpposingSide.effects[PBEffects::Spikes] >= 3
			score = 0
		else
			roles = pbGetPokemonRole(user, target)
			if roles.include?("Lead")
				score*=1.2
			end
			if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && 
			   !user.takesHailDamage? && !user.takesSandstormDamage?)
				score*=1.2
			end
			if user.turnCount<2
				score*=1.3
			end
			userlivecount   = @battle.pbAbleNonActiveCount(user.idxOwnSide)
			targetlivecount = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
			if targetlivecount>3
				miniscore=targetlivecount
				miniscore*=0.2
				score*=miniscore
			else
				score*=0.1
			end
			if user.pbOpposingSide.effects[PBEffects::Spikes]>0
				score*=0.9
			end
			score*=0.3 if pbHasHazardCleaningMove?(target)
			if targetWillMove?(target, "status")
				score=0 if @battle.choices[target.index][2].function == "BounceBackProblemCausingStatusMoves"
			end
			if @battle.choices[target.index][0] == :SwitchOut
				realTarget = @battle.pbMakeFakeBattler(@battle.pbParty(target.index)[@battle.choices[target.index][1]],false,target)
				if realTarget.hasActiveAbility?(:MAGICBOUNCE)
					score=0
				else
					score*=2
				end
			end
		end
	#---------------------------------------------------------------------------
    when "AddToxicSpikesToFoeSide" # toxic spikes
		if user.pbOpposingSide.effects[PBEffects::ToxicSpikes] >= 2
			score = 0
		else
			roles = pbGetPokemonRole(user, target)
			if roles.include?("Lead")
				score*=1.2
			end
			if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && 
			   !user.takesHailDamage? && !user.takesSandstormDamage?)
				score*=1.2
			end
			if user.turnCount<2
				score*=1.3
			end
			userlivecount   = @battle.pbAbleNonActiveCount(user.idxOwnSide)
			targetlivecount = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
			if targetlivecount>3
				miniscore=targetlivecount
				miniscore*=0.2
				score*=miniscore
			else
				score*=0.1
			end
			if user.pbOpposingSide.effects[PBEffects::ToxicSpikes]>0
				score*=0.9
			end
			score*=0.7 if pbHasHazardCleaningMove?(target)
			if targetWillMove?(target, "status")
				score=0 if @battle.choices[target.index][2].function == "BounceBackProblemCausingStatusMoves"
			end
			if @battle.choices[target.index][0] == :SwitchOut
				realTarget = @battle.pbMakeFakeBattler(@battle.pbParty(target.index)[@battle.choices[target.index][1]],false,target)
				if realTarget.hasActiveAbility?(:MAGICBOUNCE)
					score=0
				else
					score*=2
				end
			end
		end
    #---------------------------------------------------------------------------
    when "AddStealthRocksToFoeSide" # stealth rock
		if user.pbOpposingSide.effects[PBEffects::StealthRock]
			score = 0
		else
			roles = pbGetPokemonRole(user, target)
			if roles.include?("Lead")
				score*=1.2
			end
			if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && 
			   !user.takesHailDamage? && !user.takesSandstormDamage?)
				score*=1.2
			end
			if user.turnCount<2
				score*=1.3
			end
			userlivecount   = @battle.pbAbleNonActiveCount(user.idxOwnSide)
			targetlivecount = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
			if targetlivecount>3
				miniscore=targetlivecount
				miniscore*=0.2
				score*=miniscore
			else
				score*=0.1
			end
			score*=0.7 if pbHasHazardCleaningMove?(target)
			if targetWillMove?(target, "status")
				score=0 if @battle.choices[target.index][2].function == "BounceBackProblemCausingStatusMoves"
			end
			if @battle.choices[target.index][0] == :SwitchOut
				realTarget = @battle.pbMakeFakeBattler(@battle.pbParty(target.index)[@battle.choices[target.index][1]],false,target)
				if realTarget.hasActiveAbility?(:MAGICBOUNCE)
					score=0
				else
					score*=2
				end
			end
		end
    #---------------------------------------------------------------------------
    when "AddStickyWebToFoeSide" # Sticky Web
		if user.pbOpposingSide.effects[PBEffects::StickyWeb] > 1
			score = 0
		else
			roles = pbGetPokemonRole(user, target)
			if roles.include?("Lead")
				score*=1.1
			end
			if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && 
			   !user.takesHailDamage? && !user.takesSandstormDamage?)
				score*=1.1
			end
			if user.turnCount<2
				score*=1.2
			end
			userlivecount   = @battle.pbAbleNonActiveCount(user.idxOwnSide)
			targetlivecount = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
			if targetlivecount>3
				miniscore=targetlivecount
				miniscore*=0.2
				score*=miniscore
			else
				score*=0.1
			end
			score*=0.7 if pbHasHazardCleaningMove?(target)
			if targetWillMove?(target, "status")
				score=0 if @battle.choices[target.index][2].function == "BounceBackProblemCausingStatusMoves"
			end
			if @battle.choices[target.index][0] == :SwitchOut
				realTarget = @battle.pbMakeFakeBattler(@battle.pbParty(target.index)[@battle.choices[target.index][1]],false,target)
				if realTarget.hasActiveAbility?(:MAGICBOUNCE)
					score=0
				else
					score*=2
				end
			end
		end
    #---------------------------------------------------------------------------
    when "SwapSideEffects" # Court Change
      if skill >= PBTrainerAI.mediumSkill
        good_effects = [:Reflect, :LightScreen, :AuroraVeil, :SeaOfFire,
                        :Swamp, :Rainbow, :Mist, :Safeguard,
                        :Tailwind].map! { |e| PBEffects.const_get(e) }
        bad_effects = [:Spikes, :StickyWeb, :ToxicSpikes, :StealthRock].map! { |e| PBEffects.const_get(e) }
        bad_effects.each do |e|
          score *= 1.1 if ![0, false, nil].include?(user.pbOwnSide.effects[e])
          score *= 0.9 if ![0, 1, false, nil].include?(user.pbOpposingSide.effects[e])
        end
        if skill >= PBTrainerAI.highSkill
          good_effects.each do |e|
            score *= 1.1 if ![0, 1, false, nil].include?(user.pbOpposingSide.effects[e])
            score *= 0.9 if ![0, false, nil].include?(user.pbOwnSide.effects[e])
          end
        end
      end
    #---------------------------------------------------------------------------
    when "UserMakeSubstitute" # substitute
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam = bestmove[0]
		maxprio = bestmove[2]
		if user.hp*4 > user.totalhp && maxprio < user.hp
			if user.effects[PBEffects::Substitute] > 0	
				if userFasterThanTarget
					score = 0
				else
					if target.effects[PBEffects::LeechSeed]<0
						score=0
					end
				end
			else
				if user.hp==user.totalhp
					score*=1.1
				else
					score*= (user.hp*(1.0/user.totalhp))
				end
				if target.effects[PBEffects::LeechSeed]>=0
					score*=1.2
				end
				if user.hasActiveItem?(:LEFTOVERS)
					score*=1.2
				end
				score*=1.2 if user.moves.any? { |m| m&.healingMove? }
				if target.pbHasMove?(:SPORE) || target.pbHasMove?(:SLEEPPOWDER)
					score*=1.2
				end
				if user.pbHasMove?(:FOCUSPUNCH)
					score*=1.5
				end
				if target.asleep?
					score*=1.5
				end
				if target.hasActiveAbility?(:INFILTRATOR)
					score*=0.3
				end
				score*=0.3 if target.moves.any? { |m| m&.ignoresSubstitute?(target) }
				if maxdam*4<user.totalhp
					score*=2
				end
				if target.effects[PBEffects::Confusion]>0
					score*=1.3
				end
				if target.paralyzed?
					score*=1.3
				end            
				if target.effects[PBEffects::Attract]>=0
					score*=1.3
				end 
				if user.pbHasMove?(:BATONPASS)
					score*=1.2
				end
				if user.hasActiveAbility?(:SPEEDBOOST)
					score*=1.1
				end
				hasAlly = !target.allAllies.empty?
				if hasAlly
					score*=0.7
				end
				if target.hasActiveAbility?(:SLIPPERYPEEL,false,mold_broken) && !target.effects[PBEffects::SlipperyPeel]
					score *= 1.4
				end
			end
		else
			score = 0
		end
    #---------------------------------------------------------------------------
    when "RemoveUserBindingAndEntryHazards" # rapid spin
		score *= 1.2 if user.effects[PBEffects::Trapping] > 0
		score *= 1.2 if user.effects[PBEffects::LeechSeed] >= 0
		if @battle.pbAbleNonActiveCount(user.idxOwnSide) > 0
			score *= 1.2 if user.pbOwnSide.effects[PBEffects::Spikes] > 0
			score *= 1.7 if user.pbOwnSide.effects[PBEffects::StickyWeb] > 0
			score *= 1.3 if user.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
			score *= 1.3 if user.pbOwnSide.effects[PBEffects::StealthRock]
		end
		if (user.effects[PBEffects::Trapping] > 0 || 
		   user.effects[PBEffects::LeechSeed] >= 0 ||
		   user.pbOwnSide.effects[PBEffects::Spikes] > 0 || 
		   user.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0 ||
		   user.pbOwnSide.effects[PBEffects::StealthRock] || 
		   user.pbOwnSide.effects[PBEffects::StickyWeb] > 0) && !user.SetupMovesUsed.include?(move.id)
			miniscore = 100
			miniscore*=2 if user.hasActiveAbility?(:SIMPLE)
			if user.attack<user.spatk
				if user.stages[:SPECIAL_ATTACK]<0            
					ministat=user.stages[:SPECIAL_ATTACK]
					minimini=5*ministat
					minimini+=100
					minimini/=100.0
					miniscore*=minimini
				end
			else
				if user.stages[:ATTACK]<0            
					ministat=user.stages[:ATTACK]
					minimini=5*ministat
					minimini+=100
					minimini/=100.0
					miniscore*=minimini
				end
			end
			ministat=0
			ministat+=target.stages[:DEFENSE]
			ministat+=target.stages[:SPECIAL_DEFENSE]
			if ministat>0
				minimini=(-5)*ministat
				minimini+=100
				minimini/=100.0
				miniscore*=minimini
			end
			if userFasterThanTarget
				miniscore*=0.7
				miniscore*=0.1 if @battle.pbAbleNonActiveCount(user.idxOpposingSide)==0
			end
			roles = pbGetPokemonRole(user, target)
			score*=1.5 if roles.include?("Sweeper")
			if @battle.field.effects[PBEffects::TrickRoom]!=0
				miniscore*=0.2
			else
				@battle.pbParty(target.index).each do |i|
					next if i.nil?
					next if i.fainted?
					for z in i.moves
						if z.id == :TRICKROOM
							miniscore*=0.6
						end
					end
				end
				miniscore*=0.8 if target.moves.any? { |j| j&.id == :TRICKROOM }
        	end
			if user.paralyzed?
				miniscore*=0.8
			end
			miniscore*=0.7 if target.moves.any? { |m| priorityAI(target,m)>0 }
			if target.hasActiveAbility?(:SPEEDBOOST)
				miniscore*=0.7
			end
			if user.hasActiveAbility?([:MOXIE, :SOULHEART])
				miniscore*=1.3
			end
			miniscore*=0.6 if target.pbHasMoveFunction?("ResetAllBattlersStatStages","ResetTargetStatStages")
			miniscore/=100.0
			miniscore=1 if user.statStageAtMax?(:SPEED)
			miniscore=1 if user.hasActiveAbility?(:CONTRARY)
			score*=miniscore 
		end
    #---------------------------------------------------------------------------
    when "AttackTwoTurnsLater" # future sight
		if @battle.positions[target.index].effects[PBEffects::FutureSightCounter]>0
			score*=0
		else
			score*=0.7
			hasAlly = !target.allAllies.empty?
			if hasAlly
				score*=0.7
			end          
			if @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
				score*=0.7
			end
			if user.effects[PBEffects::Substitute]>0
				score*=1.2
			end
			if pbHasSingleTargetProtectMove?(user, false)
				score*=1.2
			end
			roles = pbGetPokemonRole(user, target)
			if roles.include?("Physical Wall") || roles.include?("Special Wall")
				score*=1.1
			end
			if user.pbHasMove?(:CALMMIND) || user.pbHasMove?(:QUIVERDANCE) || 
			   user.pbHasMove?(:NASTYPLOT) || user.pbHasMove?(:TAILGLOW) || 
			   user.hasActiveAbility?(:MOODY)
				score*=1.2
			end
			score *= 1.7 if user.hasActiveAbility?(:PREMONITION)
		end
    #---------------------------------------------------------------------------
    when "UserSwapsPositionsWithAlly" # ally switch
		userlivecount   = @battle.pbAbleCount(user.idxOwnSide)
		hasAlly = !user.allAllies.empty?
		bestmove = bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam = bestmove[0]
		if maxdam<user.hp && userlivecount!=0 && hasAlly
			score*=1.3
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
			score*=2 if sweepvar
			score*=2 if userlivecount<3
		else
			score*=0
		end
    #---------------------------------------------------------------------------
    when "BurnAttackerBeforeUserActs" # beak blast
		if user.pbCanBurn?(target, false)
			miniscore = pbTargetBenefitsFromStatus?(user, target, :BURN, 120, move, globalArray, skill)
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
			if !targetSurvivesMove(move,user,target)
				miniscore*=0.8
			end
			miniscore/=100.0
			minimini = 100
			if targetWillMove?(target)
				targetMove = @battle.choices[target.index][2]
				if targetSurvivesMove(targetMove,target,user)
					if target.affectedByContactEffect? && targetMove.pbContactMove?(target)
						minimini*=2.0
					else
						minimini*=0.6
					end
				else
					minimini*=0.3
				end
			end
			minimini/=100.0
			miniscore*=minimini
			score*=miniscore
		end
		if userFasterThanTarget
			score*=0.7
		end
    #---------------------------------------------------------------------------
    when "RaiseUserAttack1", "RaiseUserAttack2", "RaiseUserAttack3", "RaiseTargetAttack1" # Howl
		miniscore=100        
		if (target.hasActiveAbility?(:DISGUISE,false,mold_broken) && target.form == 0) || target.effects[PBEffects::Substitute]>0
			miniscore*=1.3
		end
		hasAlly = !target.allAllies.empty?
		if !hasAlly && move.statusMove? && @battle.choices[target.index][0] == :SwitchOut
			miniscore*=2
		end
		if (user.hp.to_f)/user.totalhp>0.75
			miniscore*=1.2
		end
		if (user.hp.to_f)/user.totalhp<0.33
			miniscore*=0.3
		end
		if (user.hp.to_f)/user.totalhp<0.75 && (user.hasActiveAbility?(:EMERGENCYEXIT) || user.hasActiveAbility?(:WIMPOUT) || user.hasActiveItem?(:EJECTBUTTON))
			miniscore*=0.3
		end    
		if target.effects[PBEffects::HyperBeam]>0
			miniscore*=1.3
		end
		if target.effects[PBEffects::Yawn]>0
			miniscore*=1.7
		end
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		if maxdam<(user.hp/4.0)
			miniscore*=1.2
		else
			if move.baseDamage==0 
				miniscore*=0.8
				if maxdam>user.hp
					miniscore*=0.1
				end
			end              
		end
		if user.turnCount<2
			miniscore*=1.2
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
			miniscore*=0.2
		end
		if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
			miniscore*=0.6
		end
		if pbHasPhazingMove?(target)
			miniscore*=0.5
		end
		if user.hasActiveAbility?(:SIMPLE)
			miniscore*=2
		end
		if hasAlly && move.baseDamage == 0
			miniscore*=0.7
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
		miniscore*=1.3 if target.moves.any? { |m| m&.healingMove? }
		if userFasterThanTarget
			miniscore*=1.5
		end
		roles = pbGetPokemonRole(user, target)
		if roles.include?("Sweeper")
			miniscore*=1.3
		end
		if user.burned?
			miniscore*=0.5
		end
		if user.paralyzed?
			miniscore*=0.5
		end
		miniscore*=0.3 if target.moves.any? { |j| j&.id == :FOULPLAY }
		if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && 
				!user.takesHailDamage? && !user.takesSandstormDamage?)
			miniscore*=1.4
		end
		miniscore*=0.6 if target.moves.any? { |m| priorityAI(target,m)>0 }
		if target.hasActiveAbility?(:SPEEDBOOST)
			miniscore*=0.6
		end
		if move.baseDamage>0
			miniscore-=100
			if move.addlEffect.to_f != 100
				miniscore*=(move.addlEffect.to_f/100.0)
				miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
			end
			miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
			miniscore+=100
			miniscore/=100.0          
			if user.statStageAtMax?(:ATTACK) 
				miniscore=1
			end       
			if user.hasActiveAbility?(:CONTRARY)
				miniscore*=0.5
			end          
		else
			miniscore*=0.5 if (move.function == "RaiseUserAttack1" || move.function == "RaiseTargetAttack1") && 
							   user.level >= 20
			miniscore/=100.0
			if user.statStageAtMax?(:ATTACK)
				miniscore=0
			end
			miniscore=0 if target.moves.any? { |j| [:CLEARSMOG, :HAZE].include?(j&.id) }
			physmove=user.moves.any? { |j| j&.physicalMove?(j&.type) }
			miniscore=0 if !physmove
			if user.hasActiveAbility?(:CONTRARY)
				miniscore*=0
			end            
			if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
				miniscore=1
			end            
		end
		if move.damagingMove? && move.addlEffect.to_f == 100
			if user.SetupMovesUsed.include?(move.id)
				miniscore=1
			else
				bestmove=bestMoveVsTarget(user,target,skill) # [maxdam,maxmove,maxprio,physorspec]
				maxdam = bestmove[0]
				maxphys=(bestmove[3]=="physical")
				if maxdam*5<target.totalhp && maxphys
					miniscore*=0.6
				end
			end
		end
		score*=miniscore
		score=0 if ($player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id) && move.statusMove?)
	#---------------------------------------------------------------------------
    when "MaxUserAttackLoseHalfOfTotalHP" # Belly Drum
		miniscore=100        
		if (target.hasActiveAbility?(:DISGUISE,false,mold_broken) && target.form == 0) || target.effects[PBEffects::Substitute]>0
			miniscore*=1.3
		end
		hasAlly = !target.allAllies.empty?
		if !hasAlly && move.statusMove? && @battle.choices[target.index][0] == :SwitchOut
			miniscore*=2
		end
		if (user.hp.to_f)/user.totalhp>0.75
			miniscore*=1.2
		end
		if (user.hp.to_f)/user.totalhp<0.33
			miniscore*=0.3
		end
		if (user.hp.to_f)/user.totalhp<0.75 && (user.hasActiveAbility?(:EMERGENCYEXIT) || user.hasActiveAbility?(:WIMPOUT) || user.hasActiveItem?(:EJECTBUTTON))
			miniscore*=0.3
		end  
		if target.effects[PBEffects::HyperBeam]>0
			miniscore*=1.3
		end
		if target.effects[PBEffects::Yawn]>0
			miniscore*=1.7
		end
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		if maxdam<(user.hp/4.0)
			miniscore*=1.2
		else
			if move.baseDamage==0 
				miniscore*=0.8
				if maxdam>user.hp
					miniscore*=0.1
				end
			end              
		end
		if user.turnCount<2
			miniscore*=1.2
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
			miniscore*=0.2
		end
		if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
			miniscore*=0.6
		end
		if pbHasPhazingMove?(target)
			miniscore*=0.5
		end
		hasAlly = !target.allAllies.empty?
		if hasAlly
			miniscore*=0.7
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
		miniscore*=1.3 if target.moves.any? { |m| m&.healingMove? }
		if userFasterThanTarget
			miniscore*=1.5
		end
		roles = pbGetPokemonRole(user, target)
		if roles.include?("Sweeper")
			miniscore*=1.3
		end
		if user.burned?
			miniscore*=0.5
		end
		if user.paralyzed?
			miniscore*=0.5
		end
		miniscore*=0.3 if target.moves.any? { |j| j&.id == :FOULPLAY }
		if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && 
		   !user.takesHailDamage? && !user.takesSandstormDamage?)
			miniscore*=1.4
		end
		miniscore*=0.1 if target.moves.any? { |m| priorityAI(target,m)>0 }
		if target.hasActiveAbility?(:SPEEDBOOST)
			miniscore*=0.6
		end
		miniscore/=100.0
		if user.statStageAtMax?(:ATTACK)
			miniscore=0
		end
		movecheck=target.moves.any? { |j| [:CLEARSMOG, :HAZE].include?(j&.id) }
		miniscore*=0 if movecheck
		if user.hasActiveAbility?(:CONTRARY)
			miniscore*=0
		end            
		if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
			miniscore=1
		end
		score*=miniscore
		if move.baseDamage==0
			physmove=user.moves.any? { |j| j&.physicalMove?(j&.type) }
			score=0 if !physmove
		end
		score *= 0.1 if user.SetupMovesUsed.include?(move.id)
		score=0 if ($player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id) && move.statusMove?)
    #---------------------------------------------------------------------------
    when "RaiseUserDefense1", "RaiseUserDefense1CurlUpUser" # Harden
		miniscore=100        
		if (target.hasActiveAbility?(:DISGUISE,false,mold_broken) && target.form == 0) || target.effects[PBEffects::Substitute]>0
			miniscore*=1.3
		end
		hasAlly = !target.allAllies.empty?
		if !hasAlly && move.statusMove? && @battle.choices[target.index][0] == :SwitchOut
			miniscore*=2
		end
		if (user.hp.to_f)/user.totalhp>0.75
			miniscore*=1.2
		end
		if (user.hp.to_f)/user.totalhp<0.33
			miniscore*=0.3
		end
		if (user.hp.to_f)/user.totalhp<0.75 && (user.hasActiveAbility?(:EMERGENCYEXIT) || user.hasActiveAbility?(:WIMPOUT) || user.hasActiveItem?(:EJECTBUTTON))
			miniscore*=0.3
		end
		if target.effects[PBEffects::HyperBeam]>0
			miniscore*=1.3
		end
		if target.effects[PBEffects::Yawn]>0
			miniscore*=1.7
		end
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		if maxdam<(user.hp/4.0)
			miniscore*=1.2
		else
			if move.baseDamage==0 
				miniscore*=0.8
				if maxdam>user.hp
					miniscore*=0.1
				end
			end              
		end
		if user.turnCount<2
			miniscore*=1.2
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
			miniscore*=0.2
		end
		if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
			miniscore*=0.6
		end
		if pbHasPhazingMove?(target)
			miniscore*=0.5
		end
		if user.hasActiveAbility?(:SIMPLE)
			miniscore*=2
		end
		hasAlly = !target.allAllies.empty?
		if hasAlly
			miniscore*=0.7
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
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		if (maxdam.to_f/user.hp)<0.12
			miniscore*=0.3
		end
		roles = pbGetPokemonRole(user, target)
		if roles.include?("Physical Wall") || roles.include?("Special Wall")
			miniscore*=1.3
		end
		if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
			miniscore*=1.2
		end
		miniscore*=1.3 if user.moves.any? { |m| m&.healingMove? }
		if user.pbHasMove?(:LEECHSEED)
			miniscore*=1.3
		end
		if user.pbHasMove?(:PAINSPLIT)
			miniscore*=1.2
		end        
		if targetWillMove?(target, "phys")
			if move.statusMove? && userFasterThanTarget && 
			   priorityAI(target,@battle.choices[target.index][2])<1
				miniscore*=1.2
			end
		end
		if move.baseDamage>0
			miniscore-=100
			if move.addlEffect.to_f != 100
				miniscore*=(move.addlEffect.to_f/100.0)
				miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
			end
			miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
			miniscore+=100
			miniscore/=100.0          
			if user.statStageAtMax?(:DEFENSE) 
				miniscore=1
			end       
			if user.hasActiveAbility?(:CONTRARY)
				miniscore*=0.5
			end          
		else
			miniscore*=0.5 if user.level >= 20
			miniscore/=100.0
			if user.statStageAtMax?(:DEFENSE)
				miniscore=0
			end
			movecheck=target.moves.any? { |j| [:CLEARSMOG, :HAZE].include?(j&.id) }
			miniscore*=0 if movecheck
			if user.hasActiveAbility?(:CONTRARY)
				miniscore*=0
			end            
			if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
				miniscore=1
			end
		end
		score*=miniscore
		mechanicver = ($player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id) && move.statusMove?)
		if move.function == "RaiseUserDefense1CurlUpUser"
			if !user.effects[PBEffects::DefenseCurl]
				movecheck = user.moves.any? { |m| [:ROLLOUT, :ICEBALL].include?(m.id) }
				if movecheck && miniscore>10
					score *= 1.2
					score *= 1.2 if userFasterThanTarget
				end
			else
				score = 0 if mechanicver
			end
		else
			score = 0 if mechanicver
		end
    #---------------------------------------------------------------------------
    when "RaiseUserDefense2", "RaiseUserDefense3" # Iron Defense, Cotton Guard
		miniscore=100        
		if (target.hasActiveAbility?(:DISGUISE,false,mold_broken) && target.form == 0) || target.effects[PBEffects::Substitute]>0
			miniscore*=1.3
		end
		hasAlly = !target.allAllies.empty?
		if !hasAlly && move.statusMove? && @battle.choices[target.index][0] == :SwitchOut
			miniscore*=2
		end
		if (user.hp.to_f)/user.totalhp>0.75
			miniscore*=1.2
		end
		if (user.hp.to_f)/user.totalhp<0.33
			miniscore*=0.3
		end
		if (user.hp.to_f)/user.totalhp<0.75 && (user.hasActiveAbility?(:EMERGENCYEXIT) || user.hasActiveAbility?(:WIMPOUT) || user.hasActiveItem?(:EJECTBUTTON))
			miniscore*=0.3
		end
		if target.effects[PBEffects::HyperBeam]>0
			miniscore*=1.3
		end
		if target.effects[PBEffects::Yawn]>0
			miniscore*=1.7
		end
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		if maxdam<(user.hp/4.0)
			miniscore*=1.2
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
		if user.hasActiveAbility?(:SIMPLE)
			miniscore*=2
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
		if move.statusMove?
			if user.effects[PBEffects::Confusion]>0
				miniscore*=0.5
			end
			if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
				miniscore*=0.3
			end
			if pbHasPhazingMove?(target)
				miniscore*=0.2
			end
			hasAlly = !target.allAllies.empty?
			if hasAlly
				miniscore*=0.5
			end
			bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
			maxdam=bestmove[0]
			if (maxdam.to_f/user.hp)<0.12
				miniscore*=0.3
			end
		end
		roles = pbGetPokemonRole(user, target)
		if roles.include?("Physical Wall") || roles.include?("Special Wall")
			miniscore*=1.3
		end
		if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
			miniscore*=1.2
		end
		miniscore*=1.3 if user.moves.any? { |m| m&.healingMove? }
		if user.pbHasMove?(:LEECHSEED)
			miniscore*=1.3
		end
		if user.pbHasMove?(:PAINSPLIT)
			miniscore*=1.2
		end        
		if targetWillMove?(target, "phys")
			if move.statusMove? && userFasterThanTarget && 
			   priorityAI(target,@battle.choices[target.index][2])<1
				miniscore*=1.5
			end
		end
		if move.baseDamage>0
			miniscore-=100
			if move.addlEffect.to_f != 100
				miniscore*=(move.addlEffect.to_f/100.0)
				miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
			end
			miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
			miniscore+=100
			miniscore/=100.0          
			if user.statStageAtMax?(:DEFENSE) 
				miniscore=1
			end       
			if user.hasActiveAbility?(:CONTRARY)
				miniscore*=0.5
			end          
		else
			miniscore/=100.0
			if user.statStageAtMax?(:DEFENSE)
				miniscore=0
			end
			movecheck=target.moves.any? { |j| [:CLEARSMOG, :HAZE].include?(j&.id) }
			miniscore*=0 if movecheck
			if user.hasActiveAbility?(:CONTRARY)
				miniscore*=0
			end            
			if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
				miniscore=1
			end
		end
		score*=miniscore
		score=0 if ($player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id) && move.statusMove?)
    #---------------------------------------------------------------------------
    when "RaiseUserSpAtk1" # Charge Beam
		miniscore=100        
		if (target.hasActiveAbility?(:DISGUISE,false,mold_broken) && target.form == 0) || target.effects[PBEffects::Substitute]>0
			miniscore*=1.3
		end
		hasAlly = !target.allAllies.empty?
		if !hasAlly && move.statusMove? && @battle.choices[target.index][0] == :SwitchOut
			miniscore*=2
		end
		if (user.hp.to_f)/user.totalhp>0.75
			miniscore*=1.2
		end
		if (user.hp.to_f)/user.totalhp<0.33
			miniscore*=0.3
		end
		if (user.hp.to_f)/user.totalhp<0.75 && (user.hasActiveAbility?(:EMERGENCYEXIT) || user.hasActiveAbility?(:WIMPOUT) || user.hasActiveItem?(:EJECTBUTTON))
			miniscore*=0.3
		end
		if target.effects[PBEffects::HyperBeam]>0
			miniscore*=1.3
		end
		if target.effects[PBEffects::Yawn]>0
			miniscore*=1.7
		end
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		if maxdam<(user.hp/4.0)
			miniscore*=1.2
		else
			if move.baseDamage==0 
				miniscore*=0.8
				if maxdam>user.hp
					miniscore*=0.1
				end
			end              
		end
		if user.turnCount<2
			miniscore*=1.2
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
			miniscore*=0.2
		end
		if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
			miniscore*=0.6
		end
		if pbHasPhazingMove?(target)
			miniscore*=0.5
		end
		if user.hasActiveAbility?(:SIMPLE)
			miniscore*=2
		end
		hasAlly = !target.allAllies.empty?
		if hasAlly && move.baseDamage == 0
			miniscore*=0.7
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
		miniscore*=1.3 if target.moves.any? { |m| m&.healingMove? }
		if userFasterThanTarget
			miniscore*=1.5
		end
		roles = pbGetPokemonRole(user, target)
		if roles.include?("Sweeper")
			miniscore*=1.3
		end
		if user.frozen?
			miniscore*=0.5
		end
		if user.paralyzed?
			miniscore*=0.5
		end
		if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && 
				!user.takesHailDamage? && !user.takesSandstormDamage?)
			miniscore*=1.4
		end
		miniscore*=0.6 if target.moves.any? { |m| priorityAI(target,m)>0 }
		if target.hasActiveAbility?(:SPEEDBOOST,false,mold_broken)
			miniscore*=0.6
		end
		if move.baseDamage>0
			miniscore-=100
			if move.addlEffect.to_f != 100
				miniscore*=(move.addlEffect.to_f/100.0)
				miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
			end
			miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
			miniscore+=100
			miniscore/=100.0          
			if user.statStageAtMax?(:SPECIAL_ATTACK) 
				miniscore=1
			end       
			if user.hasActiveAbility?(:CONTRARY)
				miniscore*=0.5
			end          
		else
			miniscore*=0.5 if user.level >= 20
			miniscore/=100.0
			if user.statStageAtMax?(:SPECIAL_ATTACK)
				miniscore=0
			end
			miniscore*=0 if target.moves.any? { |j| [:CLEARSMOG, :HAZE].include?(j&.id) }
			specmove=user.moves.any? { |j| j&.specialMove?(j&.type) }
			miniscore=0 if !specmove
			miniscore=0 if user.hasActiveAbility?(:CONTRARY)
			miniscore=1 if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
		end
		if move.damagingMove? && move.addlEffect.to_f == 100
			if user.SetupMovesUsed.include?(move.id)
				miniscore=1
			else
				bestmove=bestMoveVsTarget(user,target,skill) # [maxdam,maxmove,maxprio,physorspec]
				maxdam = bestmove[0]
				maxspec=(bestmove[3]=="special")
				if maxdam*5<target.totalhp && maxspec
					miniscore*=0.6
				end
			end
		end
		score*=miniscore
		score=0 if ($player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id) && move.statusMove?)
    #---------------------------------------------------------------------------
    when "RaiseUserSpAtk2", "RaiseUserSpAtk3" # Nasty Plot
		miniscore=100        
		if (target.hasActiveAbility?(:DISGUISE,false,mold_broken) && target.form == 0) || target.effects[PBEffects::Substitute]>0
			miniscore*=1.3
		end
		hasAlly = !target.allAllies.empty?
		if !hasAlly && move.statusMove? && @battle.choices[target.index][0] == :SwitchOut
			miniscore*=2
		end
		if (user.hp.to_f)/user.totalhp>0.75
			miniscore*=1.2
		end
		if (user.hp.to_f)/user.totalhp<0.33
			miniscore*=0.3
		end
		if (user.hp.to_f)/user.totalhp<0.75 && (user.hasActiveAbility?(:EMERGENCYEXIT) || user.hasActiveAbility?(:WIMPOUT) || user.hasActiveItem?(:EJECTBUTTON))
			miniscore*=0.3
		end
		if target.effects[PBEffects::HyperBeam]>0
			miniscore*=1.3
		end
		if target.effects[PBEffects::Yawn]>0
			miniscore*=1.7
		end
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		if maxdam<(user.hp/4.0)
			miniscore*=1.2
		else
			if move.baseDamage==0 
				miniscore*=0.8
				if maxdam>user.hp
					miniscore*=0.1
				end
			end              
		end
		if user.turnCount<2
			miniscore*=1.2
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
			miniscore*=0.2
		end
		if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
			miniscore*=0.6
		end
		if pbHasPhazingMove?(target)
			miniscore*=0.5
		end
		if user.hasActiveAbility?(:SIMPLE)
			miniscore*=2
		end
		hasAlly = !target.allAllies.empty?
		if hasAlly
			miniscore*=0.7
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
		miniscore*=1.3 if target.moves.any? { |m| m&.healingMove? }
		if userFasterThanTarget
			miniscore*=1.5
		end
		roles = pbGetPokemonRole(user, target)
		if roles.include?("Sweeper")
			miniscore*=1.3
		end
		if user.frozen?
			miniscore*=0.5
		end
		if user.paralyzed?
			miniscore*=0.5
		end
		if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && 
				!user.takesHailDamage? && !user.takesSandstormDamage?)
			miniscore*=1.4
		end
		miniscore*=0.6 if target.moves.any? { |m| priorityAI(target,m)>0 }
		if target.hasActiveAbility?(:SPEEDBOOST)
			miniscore*=0.6
		end
		miniscore/=100.0
		if user.statStageAtMax?(:SPECIAL_ATTACK)
			miniscore=0
		end
		miniscore=0 if target.moves.any? { |j| [:CLEARSMOG, :HAZE].include?(j&.id) }
		if user.hasActiveAbility?(:CONTRARY)
			miniscore*=0
		end            
		if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
			miniscore=1
		end
		score*=miniscore
		score=0 if ($player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id) && move.statusMove?)
    #---------------------------------------------------------------------------
    when "RaiseUserSpDef1", "RaiseUserSpDef1PowerUpElectricMove" # Charge
		miniscore=100        
		if (target.hasActiveAbility?(:DISGUISE,false,mold_broken) && target.form == 0) || target.effects[PBEffects::Substitute]>0
			miniscore*=1.3
		end
		hasAlly = !target.allAllies.empty?
		if !hasAlly && move.statusMove? && @battle.choices[target.index][0] == :SwitchOut
			miniscore*=2
		end
		if (user.hp.to_f)/user.totalhp>0.75
			miniscore*=1.2
		end
		if (user.hp.to_f)/user.totalhp<0.33
			miniscore*=0.3
		end
		if (user.hp.to_f)/user.totalhp<0.75 && (user.hasActiveAbility?(:EMERGENCYEXIT) || user.hasActiveAbility?(:WIMPOUT) || user.hasActiveItem?(:EJECTBUTTON))
			miniscore*=0.3
		end
		if target.effects[PBEffects::HyperBeam]>0
			miniscore*=1.3
		end
		if target.effects[PBEffects::Yawn]>0
			miniscore*=1.7
		end
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		if maxdam<(user.hp/4.0)
			miniscore*=1.2
		else
			if move.baseDamage==0 
				miniscore*=0.8
				if maxdam>user.hp
					miniscore*=0.1
				end
			end              
		end
		if user.turnCount<2
			miniscore*=1.2
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
			miniscore*=0.2
		end
		if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
			miniscore*=0.6
		end
		if pbHasPhazingMove?(target)
			miniscore*=0.5
		end
		if user.hasActiveAbility?(:SIMPLE)
			miniscore*=2
		end
		hasAlly = !target.allAllies.empty?
		if hasAlly
			miniscore*=0.7
		end
		if user.stages[:SPECIAL_DEFENSE]>0
			ministat=user.stages[:SPECIAL_DEFENSE]
			minimini=-15*ministat
			minimini+=100          
			minimini/=100.0          
			miniscore*=minimini
		end
		if pbRoughStat(target,:ATTACK,skill)<pbRoughStat(target,:SPECIAL_ATTACK,skill)
			miniscore*=1.3
		end
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		if (maxdam.to_f/user.hp)<0.12
			miniscore*=0.3
		end
		roles = pbGetPokemonRole(user, target)
		if roles.include?("Physical Wall") || roles.include?("Special Wall")
			miniscore*=1.3
		end
		if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
			miniscore*=1.2
		end
		miniscore*=1.3 if user.moves.any? { |m| m&.healingMove? }
		if user.pbHasMove?(:LEECHSEED)
			miniscore*=1.3
		end
		if user.pbHasMove?(:PAINSPLIT)
			miniscore*=1.2
		end        
		if targetWillMove?(target, "spec")
			if move.statusMove? && userFasterThanTarget && 
			   priorityAI(target,@battle.choices[target.index][2])<1
				miniscore*=1.2
			end
		end
		if move.function == "RaiseUserSpDef1PowerUpElectricMove"
			elecmove=user.moves.any? { |j| j.type == :ELECTRIC && j.baseDamage > 0 }
			if elecmove && user.effects[PBEffects::Charge]==0
				miniscore*=1.5
			end
		end
		if move.baseDamage>0
			miniscore-=100
			if move.addlEffect.to_f != 100
				miniscore*=(move.addlEffect.to_f/100.0)
				miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
			end
			miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
			miniscore+=100
			miniscore/=100.0          
			if user.statStageAtMax?(:SPECIAL_DEFENSE) 
				miniscore=1
			end       
			if user.hasActiveAbility?(:CONTRARY)
				miniscore*=0.5
			end          
		else
			miniscore*=0.5 if user.level >= 20
			miniscore/=100.0
			if user.statStageAtMax?(:SPECIAL_DEFENSE)
				miniscore=0
			end
			movecheck=target.moves.any? { |j| [:CLEARSMOG, :HAZE].include?(j&.id) }
			miniscore*=0 if movecheck
			if user.hasActiveAbility?(:CONTRARY)
				miniscore*=0
			end            
			if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
				miniscore=1
			end
		end
		score*=miniscore
		score=0 if ($player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id) && move.statusMove?)
    #---------------------------------------------------------------------------
	when "RaiseUserSpDef2", "RaiseUserSpDef3" # Amnesia
		miniscore=100        
		if (target.hasActiveAbility?(:DISGUISE,false,mold_broken) && target.form == 0) || target.effects[PBEffects::Substitute]>0
			miniscore*=1.3
		end
		hasAlly = !target.allAllies.empty?
		if !hasAlly && move.statusMove? && @battle.choices[target.index][0] == :SwitchOut
			miniscore*=2
		end
		if (user.hp.to_f)/user.totalhp>0.75
			miniscore*=1.2
		end
		if (user.hp.to_f)/user.totalhp<0.33
			miniscore*=0.3
		end
		if (user.hp.to_f)/user.totalhp<0.75 && (user.hasActiveAbility?(:EMERGENCYEXIT) || user.hasActiveAbility?(:WIMPOUT) || user.hasActiveItem?(:EJECTBUTTON))
			miniscore*=0.3
		end
		if target.effects[PBEffects::HyperBeam]>0
			miniscore*=1.3
		end
		if target.effects[PBEffects::Yawn]>0
			miniscore*=1.7
		end
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		if maxdam<(user.hp/4.0)
			miniscore*=1.2
		else
			if move.baseDamage==0 
				miniscore*=0.8
				if maxdam>user.hp
					miniscore*=0.1
				end
			end              
		end
		if user.turnCount<2
			miniscore*=1.2
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
			miniscore*=0.2
		end
		if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
			miniscore*=0.6
		end
		if pbHasPhazingMove?(target)
			miniscore*=0.5
		end
		if user.hasActiveAbility?(:SIMPLE)
			miniscore*=2
		end
		hasAlly = !target.allAllies.empty?
		if hasAlly
			miniscore*=0.7
		end
		if user.stages[:SPECIAL_DEFENSE]>0
			ministat=user.stages[:SPECIAL_DEFENSE]
			minimini=-15*ministat
			minimini+=100          
			minimini/=100.0          
			miniscore*=minimini
		end
		if pbRoughStat(target,:ATTACK,skill)<pbRoughStat(target,:SPECIAL_ATTACK,skill)
			miniscore*=1.3
		end
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		if (maxdam.to_f/user.hp)<0.12
			miniscore*=0.3
		end
		roles = pbGetPokemonRole(user, target)
		if roles.include?("Physical Wall") || roles.include?("Special Wall")
			miniscore*=1.3
		end
		if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
			miniscore*=1.2
		end
		miniscore*=1.3 if user.moves.any? { |m| m&.healingMove? }
		if user.pbHasMove?(:LEECHSEED)
			miniscore*=1.3
		end
		if user.pbHasMove?(:PAINSPLIT)
			miniscore*=1.2
		end        
		if targetWillMove?(target, "spec")
			if move.statusMove? && userFasterThanTarget && 
			   priorityAI(target,@battle.choices[target.index][2])<1
				miniscore*=1.5
			end
		end
		if move.baseDamage>0
			miniscore-=100
			if move.addlEffect.to_f != 100
				miniscore*=(move.addlEffect.to_f/100.0)
				miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
			end
			miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
			miniscore+=100
			miniscore/=100.0          
			if user.statStageAtMax?(:SPECIAL_DEFENSE) 
				miniscore=1
			end       
			if user.hasActiveAbility?(:CONTRARY)
				miniscore*=0.5
			end          
		else
			miniscore/=100.0
			if user.statStageAtMax?(:SPECIAL_DEFENSE)
				miniscore=0
			end
			miniscore*=0 if target.moves.any? { |j| [:CLEARSMOG, :HAZE].include?(j&.id) }
			if user.hasActiveAbility?(:CONTRARY)
				miniscore*=0
			end            
			if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
				miniscore=1
			end
		end
		score*=miniscore
		score=0 if ($player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id) && move.statusMove?)
    #---------------------------------------------------------------------------
    when "RaiseUserSpeed1", "TypeDependsOnUserMorpekoFormRaiseUserSpeed1" # Flame Charge, Aura Wheel
		miniscore=100        
		if ospeed<(aspeed*(3.0/2.0)) && @battle.field.effects[PBEffects::TrickRoom] == 0
			miniscore*=1.2
		end
		if (target.hasActiveAbility?(:DISGUISE,false,mold_broken) && target.form == 0) || target.effects[PBEffects::Substitute]>0
			miniscore*=1.3
		end
		hasAlly = !target.allAllies.empty?
		if !hasAlly && move.statusMove? && @battle.choices[target.index][0] == :SwitchOut
			miniscore*=2
		end
		if (user.hp.to_f)/user.totalhp>0.75
			miniscore*=1.2
		end
		if (user.hp.to_f)/user.totalhp<0.33
			miniscore*=0.3
		end
		if (user.hp.to_f)/user.totalhp<0.75 && (user.hasActiveAbility?(:EMERGENCYEXIT) || user.hasActiveAbility?(:WIMPOUT) || user.hasActiveItem?(:EJECTBUTTON))
			miniscore*=0.3
		end
		if target.effects[PBEffects::HyperBeam]>0
			miniscore*=1.3
		end
		if target.effects[PBEffects::Yawn]>0
			miniscore*=1.7
		end
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		if maxdam<(user.hp/4.0)
			miniscore*=1.2
		else
			if move.baseDamage==0 
				miniscore*=0.8
				if maxdam>user.hp
					miniscore*=0.1
				end
			end              
		end
		if user.turnCount<2
			miniscore*=1.2
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
			miniscore*=0.2
		end
		if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
			miniscore*=0.6
		end
		if pbHasPhazingMove?(target)
			miniscore*=0.5
		end
		if user.hasActiveAbility?(:SIMPLE)
			miniscore*=2
		end
		hasAlly = !target.allAllies.empty?
		if hasAlly
			miniscore*=0.7
		end
		if user.attack<user.spatk
			if user.stages[:SPECIAL_ATTACK]<0            
				ministat=user.stages[:SPECIAL_ATTACK]
				minimini=5*ministat
				minimini+=100
				minimini/=100.0
				miniscore*=minimini
			end
		else
			if user.stages[:ATTACK]<0            
				ministat=user.stages[:ATTACK]
				minimini=5*ministat
				minimini+=100
				minimini/=100.0
				miniscore*=minimini
			end
		end
		ministat=0
		ministat+=target.stages[:DEFENSE]
		ministat+=target.stages[:SPECIAL_DEFENSE]
		if ministat>0
			minimini=(-5)*ministat
			minimini+=100
			minimini/=100.0
			miniscore*=minimini
		end
		roles = pbGetPokemonRole(user, target)
		if roles.include?("Sweeper")
			miniscore*=1.3
		end
		if @battle.field.effects[PBEffects::TrickRoom]!=0
			miniscore*=0.1
		else
			miniscore*=0.1 if target.moves.any? { |j| j&.id == :TRICKROOM }
		end
		if user.paralyzed?
			miniscore*=0.2
		end      
		if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && 
				!user.takesHailDamage? && !user.takesSandstormDamage?)  
			miniscore*=1.4
		end
		miniscore*=0.6 if target.moves.any? { |m| priorityAI(target,m)>0 }    
		if user.hasActiveAbility?([:MOXIE, :SOULHEART])
			miniscore*=1.3
		end        
		if user.pbHasMoveFunction?("UseMoveTargetIsAboutToUse")
			miniscore*=1.3
		end
		if move.baseDamage>0
			miniscore-=100
			if move.addlEffect.to_f != 100
				miniscore*=(move.addlEffect.to_f/100.0)
				miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
			end
			miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
			miniscore+=100
			miniscore/=100.0          
			if user.statStageAtMax?(:SPEED) 
				miniscore=1
			end       
			if user.hasActiveAbility?(:CONTRARY)
				miniscore*=0.5
			end
		else
			miniscore*=0.5 if user.level >= 25
			if target.hasActiveAbility?(:SPEEDBOOST)
				miniscore*=0.6
			end
			miniscore/=100.0
			if user.statStageAtMax?(:SPEED)
				miniscore=0
			end
			movecheck=target.moves.any? { |j| [:CLEARSMOG, :HAZE].include?(j&.id) }
			miniscore*=0 if movecheck
			if user.hasActiveAbility?(:CONTRARY)
				miniscore*=0
			end            
			if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
				miniscore=1
			end
		end
		score*=miniscore
		score=0 if ($player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id) && move.statusMove?)
    #---------------------------------------------------------------------------
    when "RaiseUserSpeed2", "RaiseUserSpeed2LowerUserWeight", "RaiseUserSpeed3" # Agility
		miniscore=110        
		if ospeed<(aspeed*2.0) && @battle.field.effects[PBEffects::TrickRoom] == 0
			miniscore*=1.2
		end
		if (target.hasActiveAbility?(:DISGUISE,false,mold_broken) && target.form == 0) || target.effects[PBEffects::Substitute]>0
			miniscore*=1.3
		end
		hasAlly = !target.allAllies.empty?
		if !hasAlly && move.statusMove? && @battle.choices[target.index][0] == :SwitchOut
			miniscore*=2
		end
		if (user.hp.to_f)/user.totalhp>0.75
			miniscore*=1.2
		end
		if (user.hp.to_f)/user.totalhp<0.33
			miniscore*=0.3
		end
		if (user.hp.to_f)/user.totalhp<0.75 && (user.hasActiveAbility?(:EMERGENCYEXIT) || user.hasActiveAbility?(:WIMPOUT) || user.hasActiveItem?(:EJECTBUTTON))
			miniscore*=0.3
		end
		if target.effects[PBEffects::HyperBeam]>0
			miniscore*=1.3
		end
		if target.effects[PBEffects::Yawn]>0
			miniscore*=1.7
		end
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		if maxdam<(user.hp/4.0)
			miniscore*=1.2
		else
			if move.baseDamage==0 
				miniscore*=0.8
				if maxdam>user.hp
					miniscore*=0.1
				end
			end              
		end
		if user.turnCount<2
			miniscore*=1.2
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
			miniscore*=0.2
		end
		if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
			miniscore*=0.6
		end
		if pbHasPhazingMove?(target)
			miniscore*=0.5
		end
		if user.hasActiveAbility?(:SIMPLE)
			miniscore*=2
		end
		hasAlly = !target.allAllies.empty?
		if hasAlly
			miniscore*=0.7
		end
		if user.attack<user.spatk
			if user.stages[:SPECIAL_ATTACK]<0            
				ministat=user.stages[:SPECIAL_ATTACK]
				minimini=5*ministat
				minimini+=100
				minimini/=100.0
				miniscore*=minimini
			end
		else
			if user.stages[:ATTACK]<0            
				ministat=user.stages[:ATTACK]
				minimini=5*ministat
				minimini+=100
				minimini/=100.0
				miniscore*=minimini
			end
		end
		ministat=0
		ministat+=target.stages[:DEFENSE]
		ministat+=target.stages[:SPECIAL_DEFENSE]
		if ministat>0
			minimini=(-5)*ministat
			minimini+=100
			minimini/=100.0
			miniscore*=minimini
		end
		if userFasterThanTarget
			miniscore*=0.3
			targetlivecount=@battle.pbAbleNonActiveCount(user.idxOpposingSide)
			if targetlivecount<=1
				miniscore*=0.1
			end          
		end
		roles = pbGetPokemonRole(user, target)
		if roles.include?("Sweeper")
			miniscore*=1.3
		end
		if @battle.field.effects[PBEffects::TrickRoom]!=0
			miniscore*=0.1
		else
			miniscore*=0.1 if target.moves.any? { |j| j&.id == :TRICKROOM }
		end
		if user.paralyzed?
			miniscore*=0.2
		end      
		if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && 
				!user.takesHailDamage? && !user.takesSandstormDamage?)  
			miniscore*=1.4
		end
		miniscore*=0.6 if target.moves.any? { |m| priorityAI(target,m)>0 }    
		if user.hasActiveAbility?([:MOXIE, :SOULHEART])
			miniscore*=1.3
		end        
		if user.pbHasMoveFunction?("UseMoveTargetIsAboutToUse")
			miniscore*=1.3
		end
		if move.baseDamage>0
			miniscore-=100
			if move.addlEffect.to_f != 100
				miniscore*=(move.addlEffect.to_f/100.0)
				miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
			end
			miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
			miniscore+=100
			miniscore/=100.0          
			if user.statStageAtMax?(:SPEED) 
				miniscore=1
			end       
			if user.hasActiveAbility?(:CONTRARY)
				miniscore*=0.5
			end          
		else          
			if target.hasActiveAbility?(:SPEEDBOOST)
				miniscore*=0.6
			end
			miniscore/=100.0
			if user.statStageAtMax?(:SPEED)
				miniscore=0
			end
			if move.function == "RaiseUserSpeed2LowerUserWeight" # Autotomize
				miniscore*=1.5 if target.moves.any? { |j| [:LOWKICK, :GRASSKNOT].include?(j&.id) }
				miniscore*=0.5 if target.moves.any? { |j| [:HEATCRASH, :HEAVYSLAM].include?(j&.id) }
				miniscore*=0.8 if user.pbHasMove?(:HEATCRASH) || user.pbHasMove?(:HEAVYSLAM)
			end
			miniscore*=0 if target.moves.any? { |j| [:CLEARSMOG, :HAZE].include?(j&.id) }
			if user.hasActiveAbility?(:CONTRARY)
				miniscore*=0
			end
		end
		score*=miniscore
		score=0 if ($player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id) && move.statusMove?)
    #---------------------------------------------------------------------------
    when "RaiseUserAccuracy1", "RaiseUserAccuracy2", "RaiseUserAccuracy3"
		if move.statusMove?
			if user.statStageAtMax?(:ACCURACY) || ($player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id) && move.statusMove?)
				score -= 90
			else
				score += 40 if user.turnCount == 0
				score -= user.stages[:ACCURACY] * 20
			end
		else
			score += 10 if user.turnCount == 0
			score += 20 if user.stages[:ACCURACY] < 0
		end
    #---------------------------------------------------------------------------
    when "RaiseUserEvasion1", "RaiseUserEvasion2", "RaiseUserEvasion2MinimizeUser", "RaiseUserEvasion3"
		# Double Team, Minimize
		score = 0
    #---------------------------------------------------------------------------
    when "RaiseUserCriticalHitRate2" # Focus Energy
		if user.effects[PBEffects::FocusEnergy] < 2
			miniscore=100        
			if (target.hasActiveAbility?(:DISGUISE,false,mold_broken) && target.form == 0) || target.effects[PBEffects::Substitute]>0
				miniscore*=1.3
			end
			hasAlly = !target.allAllies.empty?
			if !hasAlly && move.statusMove? && @battle.choices[target.index][0] == :SwitchOut
				miniscore*=2
			end
			if (user.hp.to_f)/user.totalhp>0.75
				miniscore*=1.2
			end
			if (user.hp.to_f)/user.totalhp<0.33
				miniscore*=0.3
			end
			if (user.hp.to_f)/user.totalhp<0.75 && (user.hasActiveAbility?(:EMERGENCYEXIT) || user.hasActiveAbility?(:WIMPOUT) || user.hasActiveItem?(:EJECTBUTTON))
				miniscore*=0.3
			end
			if target.effects[PBEffects::HyperBeam]>0
				miniscore*=1.3
			end
			if target.effects[PBEffects::Yawn]>0
				miniscore*=1.7
			end
			bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
			maxdam=bestmove[0]
			if maxdam<(user.hp/4.0)
				miniscore*=1.2
			else
				if move.baseDamage==0 
					miniscore*=0.8
					if maxdam>user.hp
						miniscore*=0.1
					end
				end              
			end
			if user.turnCount<2
				miniscore*=1.2
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
				miniscore*=0.2
			end
			if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
				miniscore*=0.6
			end
			if pbHasPhazingMove?(target)
				miniscore*=0.5
			end
			hasAlly = !target.allAllies.empty?
			if hasAlly
				miniscore*=0.7
			end
			if user.hasActiveAbility?([:SUPERLUCK, :SNIPER])
				miniscore*=2
			end
			if user.hasActiveItem?([:SCOPELENS, :RAZORCLAW]) #|| (user.hasActiveItem?(:STICK) && user.species==83) || (user.hasActiveItem?(:LUCKYPUNCH) && user.species==113)
				miniscore*=1.2
			end
			if user.hasActiveItem?(:LANSATBERRY)
				miniscore*=1.3
			end
			if target.hasActiveAbility?([:ANGERPOINT, :SHELLARMOR, :BATTLEARMOR],false,mold_broken)
				miniscore*=0.2
			end
			if user.pbHasMoveFunction?("AlwaysCriticalHit","HitThreeTimesAlwaysCriticalHit","EnsureNextCriticalHit")
				miniscore*=0.5
			end
			miniscore*=2 if user.moves.any? { |m| m&.highCriticalRate? }
			miniscore/=100.0
			score*=miniscore
		else
			score = 0
		end
    #---------------------------------------------------------------------------
    when "RaiseUserAtkDef1" # Bulk Up
		miniscore=100        
		if (target.hasActiveAbility?(:DISGUISE,false,mold_broken) && target.form == 0) || target.effects[PBEffects::Substitute]>0
			miniscore*=1.3
		end
		hasAlly = !target.allAllies.empty?
		if !hasAlly && move.statusMove? && @battle.choices[target.index][0] == :SwitchOut
			miniscore*=2
		end
		if (user.hp.to_f)/user.totalhp>0.75
			miniscore*=1.2
		end
		if (user.hp.to_f)/user.totalhp<0.33
			miniscore*=0.3
		end
		if (user.hp.to_f)/user.totalhp<0.75 && (user.hasActiveAbility?(:EMERGENCYEXIT) || user.hasActiveAbility?(:WIMPOUT) || user.hasActiveItem?(:EJECTBUTTON))
			miniscore*=0.3
		end
		if target.effects[PBEffects::HyperBeam]>0
			miniscore*=1.3
		end
		if target.effects[PBEffects::Yawn]>0
			miniscore*=1.7
		end
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		if maxdam<(user.hp/4.0)
			miniscore*=1.2
		else
			if move.baseDamage==0 
				miniscore*=0.8
				if maxdam>user.hp
					miniscore*=0.1
				end
			end              
		end
		if user.turnCount<2
			miniscore*=1.2
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
			miniscore*=0.2
		end
		if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
			miniscore*=0.6
		end
		if pbHasPhazingMove?(target)
			miniscore*=0.5
		end
		if user.hasActiveAbility?(:SIMPLE)
			miniscore*=2
		end
		hasAlly = !target.allAllies.empty?
		if hasAlly
			miniscore*=0.7
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
		miniscore*=1.3 if target.moves.any? { |m| m&.healingMove? }
		if userFasterThanTarget
			miniscore*=1.5
		end
		roles = pbGetPokemonRole(user, target)
		if roles.include?("Sweeper")
			miniscore*=1.3
		end
		if user.burned?
			miniscore*=0.5
		end
		if user.paralyzed?
			miniscore*=0.5
		end
		miniscore*=0.3 if target.moves.any? { |j| j&.id == :FOULPLAY }
		if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && 
		   !user.takesHailDamage? && !user.takesSandstormDamage?)
			miniscore*=1.4
		end
		miniscore*=0.6 if target.moves.any? { |m| priorityAI(target,m)>0 }
		if target.hasActiveAbility?(:SPEEDBOOST)
			miniscore*=0.6
		end
		if move.baseDamage>0
			miniscore-=100
			if move.addlEffect.to_f != 100
				miniscore*=(move.addlEffect.to_f/100.0)
				miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
			end
			miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
			miniscore+=100
			miniscore/=100.0
			if user.hasActiveAbility?(:CONTRARY)
				miniscore*=0.5
			end          
			if !user.statStageAtMax?(:ATTACK)
				score*=miniscore
			end
		else
			miniscore/=100.0
			miniscore*=0 if target.moves.any? { |j| [:CLEARSMOG, :HAZE].include?(j&.id) }
			if user.hasActiveAbility?(:CONTRARY)
				miniscore*=0
			end            
			if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
				miniscore=1
			end            
			physmove=user.moves.any? { |j| j&.physicalMove?(j&.type) }
			if physmove && !user.statStageAtMax?(:ATTACK)
				score*=miniscore
			end
		end
		miniscore=100
		roles = pbGetPokemonRole(user, target)
		if pbRoughStat(target,:SPECIAL_ATTACK,skill)<pbRoughStat(target,:ATTACK,skill)
			if !(roles.include?("Physical Wall") || roles.include?("Special Wall"))
				if userFasterThanTarget && (user.hp.to_f)/user.totalhp>0.75
					miniscore*=1.3
				elsif !userFasterThanTarget
					miniscore*=0.7
				end
			end
			miniscore*=1.3
		end
		if roles.include?("Physical Wall") || roles.include?("Special Wall")
			miniscore*=1.3
		end
		if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
			miniscore*=1.2
		end
		miniscore*=1.3 if user.moves.any? { |m| m&.healingMove? }
		if user.pbHasMove?(:LEECHSEED)
			miniscore*=1.3
		end
		if user.pbHasMove?(:PAINSPLIT)
			miniscore*=1.2
		end        
		if targetWillMove?(target, "phys")
			if move.statusMove? && userFasterThanTarget && 
			   priorityAI(target,@battle.choices[target.index][2])<1
				miniscore*=1.2
			end
		end
		if move.baseDamage>0
			miniscore-=100
			if move.addlEffect.to_f != 100
				miniscore*=(move.addlEffect.to_f/100.0)
				miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
			end
			miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
			miniscore+=100
			miniscore/=100.0
			if user.hasActiveAbility?(:CONTRARY)
				miniscore*=0.5
			end          
		else
			miniscore/=100.0
			miniscore*=0 if target.moves.any? { |j| [:CLEARSMOG, :HAZE].include?(j&.id) }
			if user.hasActiveAbility?(:CONTRARY)
				miniscore*=0
			end            
			if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
				miniscore=1
			end
		end
		if !user.statStageAtMax?(:DEFENSE)
			score*=miniscore
		end
		score=0 if ($player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id) && move.statusMove?)
    #---------------------------------------------------------------------------
    when "RaiseUserAtkDefAcc1" # Coil
		miniscore=100        
		if (target.hasActiveAbility?(:DISGUISE,false,mold_broken) && target.form == 0) || target.effects[PBEffects::Substitute]>0
			miniscore*=1.3
		end
		hasAlly = !target.allAllies.empty?
		if !hasAlly && move.statusMove? && @battle.choices[target.index][0] == :SwitchOut
			miniscore*=2
		end
		if (user.hp.to_f)/user.totalhp>0.75
			miniscore*=1.2
		end
		if (user.hp.to_f)/user.totalhp<0.33
			miniscore*=0.3
		end
		if (user.hp.to_f)/user.totalhp<0.75 && (user.hasActiveAbility?(:EMERGENCYEXIT) || user.hasActiveAbility?(:WIMPOUT) || user.hasActiveItem?(:EJECTBUTTON))
			miniscore*=0.3
		end
		if target.effects[PBEffects::HyperBeam]>0
			miniscore*=1.3
		end
		if target.effects[PBEffects::Yawn]>0
			miniscore*=1.7
		end
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		if maxdam<(user.hp/4.0)
			miniscore*=1.2
		else
			if move.baseDamage==0 
				miniscore*=0.8
				if maxdam>user.hp
					miniscore*=0.1
				end
			end              
		end
		if user.turnCount<2
			miniscore*=1.2
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
			miniscore*=0.2
		end
		if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
			miniscore*=0.6
		end
		if pbHasPhazingMove?(target)
			miniscore*=0.5
		end
		if user.hasActiveAbility?(:SIMPLE)
			miniscore*=2
		end
		hasAlly = !target.allAllies.empty?
		if hasAlly
			miniscore*=0.7
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
		miniscore*=1.3 if target.moves.any? { |m| m&.healingMove? }
		if userFasterThanTarget
			miniscore*=1.5
		end
		roles = pbGetPokemonRole(user, target)
		if roles.include?("Sweeper")
			miniscore*=1.3
		end
		if user.burned?
			miniscore*=0.5
		end
		if user.paralyzed?
			miniscore*=0.5
		end
		miniscore*=0.3 if target.moves.any? { |j| j&.id == :FOULPLAY }
		if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && 
				!user.takesHailDamage? && !user.takesSandstormDamage?)
			miniscore*=1.4
		end
		miniscore*=0.6 if target.moves.any? { |m| priorityAI(target,m)>0 }
		if target.hasActiveAbility?(:SPEEDBOOST)
			miniscore*=0.6
		end
		if move.baseDamage>0
			miniscore/=100.0
			if user.hasActiveAbility?(:CONTRARY)
				miniscore*=0.5
			end          
			if !user.statStageAtMax?(:ATTACK)
				score*=miniscore
			end
		else
			miniscore/=100.0
			if user.hasActiveAbility?(:CONTRARY)
				miniscore*=0
			end            
			if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
				miniscore=1
			end            
			physmove=user.moves.any? { |j| j&.physicalMove?(j&.type) }
			if physmove && !user.statStageAtMax?(:ATTACK)
				score*=miniscore
			end
		end

		miniscore=100
		roles = pbGetPokemonRole(user, target)
		if pbRoughStat(target,:SPECIAL_ATTACK,skill)<pbRoughStat(target,:ATTACK,skill)
			if !(roles.include?("Physical Wall") || roles.include?("Special Wall"))
				if userFasterThanTarget && (user.hp.to_f)/user.totalhp>0.75
					miniscore*=1.3
				elsif !userFasterThanTarget
					miniscore*=0.7
				end
			end
			miniscore*=1.3
		end
		if roles.include?("Physical Wall") || roles.include?("Special Wall")
			miniscore*=1.3
		end
		if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
			miniscore*=1.2
		end
		miniscore*=1.3 if user.moves.any? { |m| m&.healingMove? }
		if user.pbHasMove?(:LEECHSEED)
			miniscore*=1.3
		end
		if user.pbHasMove?(:PAINSPLIT)
			miniscore*=1.2
		end
		if targetWillMove?(target, "phys")
			if move.statusMove? && userFasterThanTarget && 
			   priorityAI(target,@battle.choices[target.index][2])<1
				miniscore*=1.2
			end
		end
		miniscore/=100.0
		if !user.statStageAtMax?(:DEFENSE)
			score*=miniscore
		end

		miniscore=100
		miniscore*=1.1 if user.moves.any? { |m| m&.baseDamage <= 95 && m&.damagingMove? }
		miniscore*=1.1 if user.moves.any? { |m| m&.accuracy <= 90 }
		miniscore*=1.2 if user.moves.any? { |m| m&.accuracy <= 70 }
		if target.stages[:EVASION]>0
			ministat=target.stages[:EVASION]
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
			miniscore/=100.0
			if user.hasActiveAbility?(:CONTRARY)
				miniscore*=0.5
			end          
		else
			miniscore/=100.0
			if user.hasActiveAbility?(:CONTRARY)
				miniscore*=0
			end            
			if target.hasActiveAbility?(:UNAWARE)
				miniscore=1
			end
		end
		if !user.statStageAtMax?(:ACCURACY)
			score*=miniscore
		end
		score = 0 if target.moves.any? { |j| [:CLEARSMOG, :HAZE].include?(j&.id) }
		score = 0 if user.statStageAtMax?(:ACCURACY) && user.statStageAtMax?(:ATTACK) && user.statStageAtMax?(:DEFENSE)
		score = 0 if ($player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id) && move.statusMove?)
    #---------------------------------------------------------------------------
    when "RaiseUserAtkSpAtk1", "RaiseUserAtkSpAtk1Or2InSun" # Work Up, Growth
		miniscore=100        
		if (target.hasActiveAbility?(:DISGUISE,false,mold_broken) && target.form == 0) || target.effects[PBEffects::Substitute]>0
			miniscore*=1.3
		end
		hasAlly = !target.allAllies.empty?
		if !hasAlly && move.statusMove? && @battle.choices[target.index][0] == :SwitchOut
			miniscore*=2
		end
		if (user.hp.to_f)/user.totalhp>0.75
			miniscore*=1.2
		end
		if (user.hp.to_f)/user.totalhp<0.33
			miniscore*=0.3
		end
		if (user.hp.to_f)/user.totalhp<0.75 && (user.hasActiveAbility?(:EMERGENCYEXIT) || user.hasActiveAbility?(:WIMPOUT) || user.hasActiveItem?(:EJECTBUTTON))
			miniscore*=0.3
		end
		if target.effects[PBEffects::HyperBeam]>0
			miniscore*=1.3
		end
		if target.effects[PBEffects::Yawn]>0
			miniscore*=1.7
		end
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		if maxdam<(user.hp/4.0)
			miniscore*=1.2
		else
			if move.baseDamage==0 
				miniscore*=0.8
				if maxdam>user.hp
					miniscore*=0.1
				end
			end              
		end
		if user.turnCount<2
			miniscore*=1.2
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
			miniscore*=0.2
		end
		if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
			miniscore*=0.6
		end
		if pbHasPhazingMove?(target)
			miniscore*=0.5
		end
		if user.hasActiveAbility?(:SIMPLE)
			miniscore*=2
		end
		hasAlly = !target.allAllies.empty?
		if hasAlly
			miniscore*=0.7
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
		miniscore*=1.3 if target.moves.any? { |m| m&.healingMove? }
		if userFasterThanTarget
			miniscore*=1.5
		end
		roles = pbGetPokemonRole(user, target)
		if roles.include?("Sweeper")
			miniscore*=1.3
		end
		if user.burned? || user.frozen?
			miniscore*=0.5
		end
		if user.paralyzed?
			miniscore*=0.5
		end
		miniscore*=0.3 if target.moves.any? { |j| j&.id == :FOULPLAY }
		if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && 
				!user.takesHailDamage? && !user.takesSandstormDamage?)
			miniscore*=1.4
		end
		miniscore*=0.6 if target.moves.any? { |m| priorityAI(target,m)>0 }
		if target.hasActiveAbility?(:SPEEDBOOST)
			miniscore*=0.6
		end
		miniscore*=0 if target.moves.any? { |j| [:CLEARSMOG, :HAZE].include?(j&.id) }
		if move.function == "RaiseUserAtkSpAtk1Or2InSun"
			if ([:Sun, :HarshSun].include?(expectedWeather) && !user.hasActiveItem?(:UTILITYUMBRELLA)) || 
			   user.hasActiveAbility?(:PRESAGE)
				miniscore*=2.2
			else
				miniscore*=0.5 if user.level >= 26
			end
		else
			miniscore*=0.5 if user.level >= 26
		end
		if user.hasActiveAbility?(:CONTRARY)
			miniscore*=0
		end            
		if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
			miniscore=1
		end
		physmove=user.moves.any? { |m| m&.physicalMove?(m&.type) }
		specmove=user.moves.any? { |m| m&.specialMove?(m&.type) }
		if (physmove && !user.statStageAtMax?(:ATTACK)) ||
		   (specmove && !user.statStageAtMax?(:SPECIAL_ATTACK))
			miniscore/=100.0
			score*=miniscore
		end
		score = 0 if ($player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id) && move.statusMove?)
    #---------------------------------------------------------------------------
    when "LowerUserDefSpDef1RaiseUserAtkSpAtkSpd2" # shell smash
		miniscore=100
		if (target.hasActiveAbility?(:DISGUISE,false,mold_broken) && target.form == 0) || target.effects[PBEffects::Substitute]>0
			miniscore*=1.3
		end
		hasAlly = !target.allAllies.empty?
		if !hasAlly && move.statusMove? && @battle.choices[target.index][0] == :SwitchOut
			miniscore*=2
		end
		if (user.hp.to_f)/user.totalhp>0.75
			miniscore*=1.3
		end
		if (user.hp.to_f)/user.totalhp<0.33
			miniscore*=0.3
		end
		if (user.hp.to_f)/user.totalhp<0.75 && (user.hasActiveAbility?(:EMERGENCYEXIT) || user.hasActiveAbility?(:WIMPOUT) || user.hasActiveItem?(:EJECTBUTTON))
			miniscore*=0.3
		end
		if target.effects[PBEffects::HyperBeam]>0
			miniscore*=1.3
		end
		if target.effects[PBEffects::Yawn]>0
			miniscore*=1.7
		end
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		if maxdam<(user.hp/4.0)
			miniscore*=1.2
		else
			if move.baseDamage==0 
				miniscore*=0.8
				if maxdam>user.hp
					miniscore*=0.1
				end
			end              
		end
		if user.turnCount<2
			miniscore*=1.3
		end
		if target.pbHasAnyStatus?
			miniscore*=1.2
		end
		if target.asleep?
			miniscore*=1.5
		end
		if target.effects[PBEffects::Encore]>0
			if GameData::Move.get(target.effects[PBEffects::EncoreMove]).base_damage==0      
				miniscore*=1.5
			end          
		end  
		if user.effects[PBEffects::Confusion]>0
			miniscore*=0.1
		end
		if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
			miniscore*=0.3
		end
		if pbHasPhazingMove?(target)
			miniscore*=0.5
		end
		if user.hasActiveAbility?(:SIMPLE)
			miniscore*=2
		end
		hasAlly = !target.allAllies.empty?
		if hasAlly
			miniscore*=0.7
		end
		miniscore*=1.3 if target.moves.any? { |m| m&.healingMove? }    
		if !userFasterThanTarget
			miniscore*=1.3
			if ospeed<(aspeed*(3.0/2.0)) && @battle.field.effects[PBEffects::TrickRoom] == 0
				miniscore*=1.2
			end
		end    
		roles = pbGetPokemonRole(user, target)
		if roles.include?("Sweeper")
			miniscore*=1.5
		end
		physmove=user.moves.any? { |m| m&.physicalMove?(m&.type) }
		specmove=user.moves.any? { |m| m&.specialMove?(m&.type) }
		if user.burned? && !specmove
			miniscore*=0.5
		end
		if user.frozen? && !physmove
			miniscore*=0.5
		end
		if user.paralyzed?
			miniscore*=0.5
		end
		if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && 
				!user.takesHailDamage? && !user.takesSandstormDamage?)
			miniscore*=1.5
		end
		miniscore*=0.2 if target.moves.any? { |m| priorityAI(target,m)>0 }
		if target.hasActiveAbility?(:SPEEDBOOST)
			miniscore*=0.6
		end
		miniscore/=100.0
		score*=miniscore
		miniscore=100
		if user.hasActiveItem?(:WHITEHERB)
			miniscore *= 2.25
		else
			if userFasterThanTarget && targetWillMove?(target, "dmg")
				miniscore*=0.1
			end 
		end
		if @battle.field.effects[PBEffects::TrickRoom]!=0
			miniscore*=0.1
		else
			miniscore*=0.1 if target.moves.any? { |j| j&.id == :TRICKROOM }
		end
		if user.hasActiveAbility?([:MOXIE, :SOULHEART])
			miniscore*=1.3
		end  
		if !user.statStageAtMax?(:SPEED)          
			miniscore/=100.0
			score*=miniscore
		end
		healmove=user.moves.any? { |m| m&.healingMove? }
		miniscore*=0 if target.moves.any? { |j| [:CLEARSMOG, :HAZE].include?(j&.id) }
		if user.hasActiveAbility?(:CONTRARY) && !healmove  
			score=0
		end      
		if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
			score=0
		end
		score/=2.0 if user.SetupMovesUsed.include?(move.id)
		score=0 if ($player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id) && move.statusMove?)
    #---------------------------------------------------------------------------
    when "RaiseUserAtkSpd1" # Dragon Dance
		miniscore=100        
		if (target.hasActiveAbility?(:DISGUISE,false,mold_broken) && target.form == 0) || target.effects[PBEffects::Substitute]>0
			miniscore*=1.3
		end
		if (user.hp.to_f)/user.totalhp>0.75
			miniscore*=1.3
		end
		if (user.hp.to_f)/user.totalhp<0.33
			miniscore*=0.3
		end
		if (user.hp.to_f)/user.totalhp<0.75 && (user.hasActiveAbility?(:EMERGENCYEXIT) || user.hasActiveAbility?(:WIMPOUT) || user.hasActiveItem?(:EJECTBUTTON))
			miniscore*=0.3
		end
		if target.effects[PBEffects::HyperBeam]>0
			miniscore*=1.3
		end
		if target.effects[PBEffects::Yawn]>0
			miniscore*=1.7
		end
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		if maxdam<(user.hp/4.0)
			miniscore*=1.3
		else
			if move.baseDamage==0 
				miniscore*=0.8
				if maxdam>user.hp
					miniscore*=0.1
				end
			end              
		end
		if user.turnCount<2
			miniscore*=1.3
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
			miniscore*=0.2
		end
		if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
			miniscore*=0.6
		end
		if pbHasPhazingMove?(target)
			miniscore*=0.5
		end
		if user.hasActiveAbility?(:SIMPLE)
			miniscore*=2
		end
		hasAlly = !target.allAllies.empty?
		if hasAlly
			miniscore*=0.7
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
		miniscore*=1.3 if target.moves.any? { |m| m&.healingMove? }
		if !userFasterThanTarget
			miniscore*=1.5
			if ospeed<(aspeed*(3.0/2.0)) && @battle.field.effects[PBEffects::TrickRoom] == 0
				miniscore*=1.2
			end
		end
		roles = pbGetPokemonRole(user, target)
		if roles.include?("Sweeper")
			miniscore*=1.3
		end
		if user.burned?
			miniscore*=0.5
		end
		if user.paralyzed?
			miniscore*=0.5
		end
		miniscore*=0.3 if target.moves.any? { |j| j&.id == :FOULPLAY }
		if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && 
				!user.takesHailDamage? && !user.takesSandstormDamage?)
			miniscore*=1.4
		end
		miniscore*=0.6 if target.moves.any? { |m| priorityAI(target,m)>0 }
		if target.hasActiveAbility?(:SPEEDBOOST)
			miniscore*=0.6
		end
		if move.baseDamage==0
			physmove=user.moves.any? { |m| m&.physicalMove?(m&.type) }
			if physmove && !user.statStageAtMax?(:ATTACK)
				miniscore/=100.0
				score*=miniscore
			end
		else
			if !user.statStageAtMax?(:ATTACK)
				miniscore/=100.0
				score*=miniscore
			end
		end
		miniscore=100
		if ospeed<(aspeed*(3.0/2.0)) && @battle.field.effects[PBEffects::TrickRoom] == 0
			miniscore*=1.2
		end
		if user.stages[:SPEED]<0
			ministat=user.stages[:SPEED]
			minimini=5*ministat
			minimini+=100
			minimini/=100.0
			miniscore*=minimini
		end
		roles = pbGetPokemonRole(user, target)
		if roles.include?("Sweeper")
			miniscore*=1.3
		end
		if @battle.field.effects[PBEffects::TrickRoom]!=0
			miniscore*=0.1
		else
			miniscore*=0.1 if target.moves.any? { |j| j&.id == :TRICKROOM }
		end
		if user.hasActiveAbility?(:MOXIE)
			miniscore*=1.3
		end        
		if target.hasActiveAbility?(:SPEEDBOOST)
			miniscore*=0.6
		end
		miniscore*=0 if target.moves.any? { |j| [:CLEARSMOG, :HAZE].include?(j&.id) }
		if user.hasActiveAbility?(:CONTRARY)
			miniscore*=0
		end            
		if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
			miniscore=1
		end
		if !user.statStageAtMax?(:SPEED)
			miniscore/=100.0
			score*=miniscore
		end
		hasAlly = !target.allAllies.empty?
		if !hasAlly && move.statusMove? && @battle.choices[target.index][0] == :SwitchOut
			score*=2
		end
		score=0 if user.statStageAtMax?(:SPEED) && user.statStageAtMax?(:ATTACK)
		score=0 if ($player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id) && move.statusMove?)
    #---------------------------------------------------------------------------
    when "RaiseUserAtk1Spd2" # Shift Gear
		miniscore=100        
		if (target.hasActiveAbility?(:DISGUISE,false,mold_broken) && target.form == 0) || target.effects[PBEffects::Substitute]>0
			miniscore*=1.3
		end
		if (user.hp.to_f)/user.totalhp>0.75
			miniscore*=1.2
		end
		if (user.hp.to_f)/user.totalhp<0.33
			miniscore*=0.3
		end
		if (user.hp.to_f)/user.totalhp<0.75 && (user.hasActiveAbility?(:EMERGENCYEXIT) || user.hasActiveAbility?(:WIMPOUT) || user.hasActiveItem?(:EJECTBUTTON))
			miniscore*=0.3
		end
		if target.effects[PBEffects::HyperBeam]>0
			miniscore*=1.3
		end
		if target.effects[PBEffects::Yawn]>0
			miniscore*=1.7
		end
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		if maxdam<(user.hp/4.0)
			miniscore*=1.3
		else
			if move.baseDamage==0 
				miniscore*=0.8
				if maxdam>user.hp
					miniscore*=0.1
				end
			end              
		end
		if user.turnCount<2
			miniscore*=1.2
		end
		if target.pbHasAnyStatus?
			miniscore*=1.2
		end
		if target.asleep?
			miniscore*=1.5
		end
		if target.effects[PBEffects::Encore]>0
			if GameData::Move.get(target.effects[PBEffects::EncoreMove]).base_damage==0
				miniscore*=1.5
			end          
		end
		if user.effects[PBEffects::Confusion]>0
			miniscore*=0.2
		end
		if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
			miniscore*=0.6
		end
		if pbHasPhazingMove?(target)
			miniscore*=0.5
		end
		if user.hasActiveAbility?(:SIMPLE)
			miniscore*=2
		end
		hasAlly = !target.allAllies.empty?
		if hasAlly
			miniscore*=0.7
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
		miniscore*=1.3 if target.moves.any? { |m| m&.healingMove? }
		if !userFasterThanTarget
			miniscore*=1.5
			if ospeed<(aspeed*2.0) && @battle.field.effects[PBEffects::TrickRoom] == 0
				miniscore*=1.2
			end
		end
		roles = pbGetPokemonRole(user, target)
		if roles.include?("Sweeper")
			miniscore*=1.3
		end
		if user.burned?
			miniscore*=0.5
		end
		if user.paralyzed?
			miniscore*=0.5
		end
		miniscore*=0.3 if target.moves.any? { |j| j&.id == :FOULPLAY }
		if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && 
				!user.takesHailDamage? && !user.takesSandstormDamage?)
			miniscore*=1.4
		end
		miniscore*=0.6 if target.moves.any? { |m| priorityAI(target,m)>0 }
		if target.hasActiveAbility?(:SPEEDBOOST)
			miniscore*=0.6
		end
		if move.baseDamage==0
			physmove=user.moves.any? { |m| m&.physicalMove?(m&.type) }
			if physmove && !user.statStageAtMax?(:ATTACK)
				miniscore/=100.0
				score*=miniscore
			end
		else
			if !user.statStageAtMax?(:ATTACK)
				miniscore/=100.0
				score*=miniscore
			end
		end
		miniscore=125
		if user.stages[:SPEED]<0
			ministat=user.stages[:SPEED]
			minimini=5*ministat
			minimini+=100
			minimini/=100.0
			miniscore*=minimini
		end
		roles = pbGetPokemonRole(user, target)
		if roles.include?("Sweeper")
			miniscore*=1.3
		end
		if @battle.field.effects[PBEffects::TrickRoom]!=0
			miniscore*=0.1
		else
			miniscore*=0.1 if target.moves.any? { |j| j&.id == :TRICKROOM }
		end
		if user.hasActiveAbility?(:MOXIE)
			miniscore*=1.3
		end        
		if target.hasActiveAbility?(:SPEEDBOOST)
			miniscore*=0.6
		end
		miniscore*=0 if target.moves.any? { |j| [:CLEARSMOG, :HAZE].include?(j&.id) }
		if user.hasActiveAbility?(:CONTRARY)
			miniscore*=0
		end            
		if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
			miniscore=1
		end
		if !user.statStageAtMax?(:SPEED)
			miniscore/=100.0
			score*=miniscore
		end
		hasAlly = !target.allAllies.empty?
		if !hasAlly && move.statusMove? && @battle.choices[target.index][0] == :SwitchOut
			score*=2
		end
		score=0 if user.statStageAtMax?(:SPEED) && user.statStageAtMax?(:ATTACK)
		score=0 if ($player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id) && move.statusMove?)
    #---------------------------------------------------------------------------
    when "RaiseUserAtkAcc1" # Hone Claws
		miniscore=100        
		if (target.hasActiveAbility?(:DISGUISE,false,mold_broken) && target.form == 0) || target.effects[PBEffects::Substitute]>0
			miniscore*=1.3
		end
		hasAlly = !target.allAllies.empty?
		if !hasAlly && move.statusMove? && @battle.choices[target.index][0] == :SwitchOut
			miniscore*=2
		end
		if (user.hp.to_f)/user.totalhp>0.75
			miniscore*=1.2
		end
		if (user.hp.to_f)/user.totalhp<0.33
			miniscore*=0.3
		end
		if (user.hp.to_f)/user.totalhp<0.75 && (user.hasActiveAbility?(:EMERGENCYEXIT) || user.hasActiveAbility?(:WIMPOUT) || user.hasActiveItem?(:EJECTBUTTON))
			miniscore*=0.3
		end
		if target.effects[PBEffects::HyperBeam]>0
			miniscore*=1.3
		end
		if target.effects[PBEffects::Yawn]>0
			miniscore*=1.7
		end
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		if maxdam<(user.hp/4.0)
			miniscore*=1.2
		else
			if move.baseDamage==0 
				miniscore*=0.8
				if maxdam>user.hp
					miniscore*=0.1
				end
			end              
		end
		if user.turnCount<2
			miniscore*=1.2
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
			miniscore*=0.2
		end
		if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
			miniscore*=0.6
		end
		if pbHasPhazingMove?(target)
			miniscore*=0.5
		end
		if user.hasActiveAbility?(:SIMPLE)
			miniscore*=2
		end
		hasAlly = !target.allAllies.empty?
		if hasAlly
			miniscore*=0.7
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
		miniscore*=1.3 if target.moves.any? { |m| m&.healingMove? }
		if userFasterThanTarget
			miniscore*=1.5
		end
		roles = pbGetPokemonRole(user, target)
		if roles.include?("Sweeper")
			miniscore*=1.3
		end
		if user.burned?
			miniscore*=0.5
		end
		if user.paralyzed?
			miniscore*=0.5
		end
		miniscore*=0.3 if target.moves.any? { |j| j&.id == :FOULPLAY }
		if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && 
				!user.takesHailDamage? && !user.takesSandstormDamage?)
			miniscore*=1.4
		end
		miniscore*=0.6 if target.moves.any? { |m| priorityAI(target,m)>0 }
		if target.hasActiveAbility?(:SPEEDBOOST)
			miniscore*=0.6
		end
		miniscore*=0 if target.moves.any? { |j| [:CLEARSMOG, :HAZE].include?(j&.id) }
		if user.hasActiveAbility?(:CONTRARY)
			miniscore*=0
		end            
		if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
			miniscore=1
		end    
		if move.baseDamage==0
			physmove=user.moves.any? { |m| m&.physicalMove?(m&.type) }
			if physmove && !user.statStageAtMax?(:ATTACK)
				miniscore/=100.0
				score*=miniscore
			end
		else
			if !user.statStageAtMax?(:ATTACK)
				miniscore/=100.0
				score*=miniscore
			end
		end
		miniscore=100
		miniscore*=1.1 if user.moves.any? { |m| m&.baseDamage <= 95 && m&.damagingMove? }
		miniscore*=1.1 if user.moves.any? { |m| m&.accuracy <= 90 }
		miniscore*=1.2 if user.moves.any? { |m| m&.accuracy <= 70 }
		if target.stages[:EVASION]>0
			ministat=target.stages[:EVASION]
			minimini=5*ministat
			minimini+=100
			minimini/=100.0
			miniscore*=minimini
		end
		miniscore*=0 if target.moves.any? { |j| [:CLEARSMOG, :HAZE].include?(j&.id) }
		if user.hasActiveAbility?(:CONTRARY)
			miniscore*=0
		end            
		if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
			miniscore=1
		end
		if user.statStageAtMax?(:ACCURACY)
			miniscore/=100.0
			score*=miniscore
		end
		score = 0 if user.statStageAtMax?(:ACCURACY) && user.statStageAtMax?(:ATTACK)
		score = 0 if ($player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id) && move.statusMove?)
    #---------------------------------------------------------------------------
    when "RaiseUserDefSpDef1" # Cosmic Power
		miniscore=100        
		if (target.hasActiveAbility?(:DISGUISE,false,mold_broken) && target.form == 0) || target.effects[PBEffects::Substitute]>0
			miniscore*=1.3
		end
		hasAlly = !target.allAllies.empty?
		if !hasAlly && move.statusMove? && @battle.choices[target.index][0] == :SwitchOut
			miniscore*=2
		end
		if (user.hp.to_f)/user.totalhp>0.75
			miniscore*=1.2
		end
		if (user.hp.to_f)/user.totalhp<0.33
			miniscore*=0.3
		end
		if (user.hp.to_f)/user.totalhp<0.75 && (user.hasActiveAbility?(:EMERGENCYEXIT) || user.hasActiveAbility?(:WIMPOUT) || user.hasActiveItem?(:EJECTBUTTON))
			miniscore*=0.3
		end
		if target.effects[PBEffects::HyperBeam]>0
			miniscore*=1.3
		end
		if target.effects[PBEffects::Yawn]>0
			miniscore*=1.7
		end
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		if maxdam<(user.hp/4.0)
			miniscore*=1.2
		else
			if move.baseDamage==0 
				miniscore*=0.8
				if maxdam>user.hp
					miniscore*=0.1
				end
			end              
		end
		if user.turnCount<2
			miniscore*=1.2
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
			miniscore*=0.2
		end
		if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
			miniscore*=0.6
		end
		if pbHasPhazingMove?(target)
			miniscore*=0.5
		end
		if user.hasActiveAbility?(:SIMPLE)
			miniscore*=2
		end
		hasAlly = !target.allAllies.empty?
		if hasAlly
			miniscore*=0.7
		end
		if user.stages[:DEFENSE]>0 || user.stages[:SPECIAL_DEFENSE]>0
			ministat=user.stages[:DEFENSE]
			ministat+=user.stages[:SPECIAL_DEFENSE]
			minimini=-15*ministat
			minimini+=100          
			minimini/=100.0          
			miniscore*=minimini
		end
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		if (maxdam.to_f/user.hp)<0.12
			miniscore*=0.3
		end
		if targetWillMove?(target, "phys")
			if move.statusMove? && userFasterThanTarget && 
			   priorityAI(target,@battle.choices[target.index][2])<1
				miniscore*=1.2
			end
		end
		if !user.statStageAtMax?(:DEFENSE)
			miniscore/=100.0
			score*=miniscore
		end

		miniscore=100
		roles = pbGetPokemonRole(user, target)
		if roles.include?("Physical Wall") || roles.include?("Special Wall")
			miniscore*=1.3
		end
		if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
			miniscore*=1.2
		end
		miniscore*=2 if user.moves.any? { |m| m&.healingMove? }
		if user.pbHasMove?(:STOREDPOWER)
			miniscore*=1.5
		end
		if user.pbHasMove?(:LEECHSEED)
			miniscore*=1.3
		end
		if user.pbHasMove?(:PAINSPLIT)
			miniscore*=1.2
		end
		miniscore*=0 if target.moves.any? { |j| [:CLEARSMOG, :HAZE].include?(j&.id) }
		if user.hasActiveAbility?(:CONTRARY)
			miniscore*=0
		end
		if targetWillMove?(target, "spec")
			if move.statusMove? && userFasterThanTarget && 
			   priorityAI(target,@battle.choices[target.index][2])<1
				miniscore*=1.2
			end
		end
		if !user.statStageAtMax?(:SPECIAL_DEFENSE)
			miniscore/=100.0
			score*=miniscore
		end
		score=0 if user.statStageAtMax?(:DEFENSE) && user.statStageAtMax?(:SPECIAL_DEFENSE)
		score=0 if ($player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id) && move.statusMove?)
    #---------------------------------------------------------------------------
    when "RaiseUserSpAtkSpDef1" # calm mind
		miniscore=100        
		if (target.hasActiveAbility?(:DISGUISE,false,mold_broken) && target.form == 0) || target.effects[PBEffects::Substitute]>0
			miniscore*=1.3
		end
		if (user.hp.to_f)/user.totalhp>0.75
			miniscore*=1.2
		end
		if (user.hp.to_f)/user.totalhp<0.33
			miniscore*=0.3
		end
		if (user.hp.to_f)/user.totalhp<0.75 && (user.hasActiveAbility?(:EMERGENCYEXIT) || user.hasActiveAbility?(:WIMPOUT) || user.hasActiveItem?(:EJECTBUTTON))
			miniscore*=0.3
		end
		if target.effects[PBEffects::HyperBeam]>0
			miniscore*=1.3
		end
		if target.effects[PBEffects::Yawn]>0
			miniscore*=1.7
		end
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		if maxdam<(user.hp/4.0)
			miniscore*=1.2
		else
			miniscore*=0.8
			if maxdam>user.hp
				miniscore*=0.1
			end         
		end
		if user.turnCount<2
			miniscore*=1.2
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
			miniscore*=0.2
		end
		if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
			miniscore*=0.6
		end
		if pbHasPhazingMove?(target)
			miniscore*=0.5
		end
		if user.hasActiveAbility?(:SIMPLE)
			miniscore*=2
		end
		hasAlly = !target.allAllies.empty?
		if hasAlly
			miniscore*=0.7
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
		miniscore*=1.3 if target.moves.any? { |m| m&.healingMove? }
		if userFasterThanTarget
			miniscore*=1.5
		end
		roles = pbGetPokemonRole(user, target)
		if roles.include?("Sweeper")
			miniscore*=1.3
		end
		if user.frozen?
			miniscore*=0.5
		end
		if user.paralyzed?
			miniscore*=0.5
		end
		if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && 
				!user.takesHailDamage? && !user.takesSandstormDamage?)
			miniscore*=1.4
		end
		miniscore*=0.6 if target.moves.any? { |m| priorityAI(target,m)>0 }
		if target.hasActiveAbility?(:SPEEDBOOST)
			miniscore*=0.6
		end
		specmove=user.moves.any? { |m| m&.specialMove?(m&.type) }
		if specmove && !user.statStageAtMax?(:SPECIAL_ATTACK)
			miniscore/=100.0
			score*=miniscore
		end

		miniscore=100
		roles = pbGetPokemonRole(user, target)
		if pbRoughStat(target,:SPECIAL_ATTACK,skill)<pbRoughStat(target,:ATTACK,skill)
			if !(roles.include?("Physical Wall") || roles.include?("Special Wall"))
				if userFasterThanTarget && (user.hp.to_f)/user.totalhp>0.75
					miniscore*=1.3
				elsif !userFasterThanTarget
					miniscore*=0.7
				end
			end
			miniscore*=1.3
		end
		if roles.include?("Physical Wall") || roles.include?("Special Wall")
			miniscore*=1.3
		end
		if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
			miniscore*=1.2
		end
		miniscore*=1.3 if user.moves.any? { |m| m&.healingMove? }
		if user.pbHasMove?(:LEECHSEED)
			miniscore*=1.3
		end
		if user.pbHasMove?(:PAINSPLIT)
			miniscore*=1.2
		end
		miniscore=0 if target.moves.any? { |j| [:CLEARSMOG, :HAZE].include?(j&.id) }
		if user.hasActiveAbility?(:CONTRARY)
			miniscore=0
		end            
		if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
			miniscore=1
		end
		if targetWillMove?(target, "spec")
			if move.statusMove? && userFasterThanTarget && 
			   priorityAI(target,@battle.choices[target.index][2])<1
				miniscore*=1.2
			end
		end
		if !user.statStageAtMax?(:SPECIAL_DEFENSE)
			miniscore/=100.0
			score*=miniscore
		end
		hasAlly = !target.allAllies.empty?
		if !hasAlly && move.statusMove? && @battle.choices[target.index][0] == :SwitchOut
			score*=2
		end
		score=0 if ($player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id) && move.statusMove?)
    #---------------------------------------------------------------------------
    when "RaiseUserSpAtkSpDefSpd1" # Quiver Dance
		#spatk
		miniscore=100        
		if (target.hasActiveAbility?(:DISGUISE,false,mold_broken) && target.form == 0) || target.effects[PBEffects::Substitute]>0
			miniscore*=1.4
		end
		if (user.hp.to_f)/user.totalhp>0.75
			miniscore*=1.3
		end
		if (user.hp.to_f)/user.totalhp<0.33
			miniscore*=0.3
		end
		if (user.hp.to_f)/user.totalhp<0.75 && (user.hasActiveAbility?(:EMERGENCYEXIT) || user.hasActiveAbility?(:WIMPOUT) || user.hasActiveItem?(:EJECTBUTTON))
			miniscore*=0.3
		end
		if target.effects[PBEffects::HyperBeam]>0
			miniscore*=1.3
		end
		if target.effects[PBEffects::Yawn]>0
			miniscore*=1.7
		end
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		if maxdam<(user.hp/4.0)
			miniscore*=1.3
		else
			miniscore*=0.8
			if maxdam>user.hp
				miniscore*=0.1
			end
		end
		if user.turnCount<2
			miniscore*=1.3
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
			miniscore*=0.2
		end
		if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
			miniscore*=0.6
		end
		if pbHasPhazingMove?(target)
			miniscore*=0.5
		end
		if user.hasActiveAbility?(:SIMPLE)
			miniscore*=2
		end
		hasAlly = !target.allAllies.empty?
		if hasAlly
			miniscore*=0.7
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
		miniscore*=1.3 if target.moves.any? { |m| m&.healingMove? }
		if userFasterThanTarget
			miniscore*=1.5
		end
		roles = pbGetPokemonRole(user, target)
		if roles.include?("Sweeper")
			miniscore*=1.3
		end
		if user.frozen?
			miniscore*=0.5
		end
		if user.paralyzed?
			miniscore*=0.5
		end
		if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && 
				!user.takesHailDamage? && !user.takesSandstormDamage?)
			miniscore*=1.4
		end
		miniscore*=0.6 if target.moves.any? { |m| priorityAI(target,m)>0 }
		if target.hasActiveAbility?(:SPEEDBOOST)
			miniscore*=0.6
		end
		specmove=user.moves.any? { |m| m&.specialMove?(m&.type) }
		if specmove && !user.statStageAtMax?(:SPECIAL_ATTACK)
			miniscore/=100.0
			score*=miniscore
		end

		#spdef
		miniscore=100
		roles = pbGetPokemonRole(user, target)
		if pbRoughStat(target,:SPECIAL_ATTACK,skill)<pbRoughStat(target,:ATTACK,skill)
			if !(roles.include?("Physical Wall") || roles.include?("Special Wall"))
				if userFasterThanTarget && (user.hp.to_f)/user.totalhp>0.75
					miniscore*=1.3
				elsif !userFasterThanTarget
					miniscore*=0.7
				end
			end
			miniscore*=1.3
		end
		if roles.include?("Physical Wall") || roles.include?("Special Wall")
			miniscore*=1.3
		end
		if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
			miniscore*=1.2
		end
		miniscore*=1.3 if user.moves.any? { |m| m&.healingMove? }
		if user.pbHasMove?(:LEECHSEED)
			miniscore*=1.3
		end
		if user.pbHasMove?(:PAINSPLIT)
			miniscore*=1.2
		end
		miniscore=0 if target.moves.any? { |j| [:CLEARSMOG, :HAZE].include?(j&.id) }
		if user.hasActiveAbility?(:CONTRARY)
			miniscore=0
		end            
		if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
			miniscore=1
		end
		if targetWillMove?(target, "spec")
			if move.statusMove? && userFasterThanTarget && 
			   priorityAI(target,@battle.choices[target.index][2])<1
				miniscore*=1.2
			end
		end
		if !user.statStageAtMax?(:SPECIAL_DEFENSE)
			miniscore/=100.0
			score*=miniscore
		end

		#speed
		miniscore=100
		if user.stages[:SPECIAL_ATTACK]<0
			ministat=user.stages[:SPECIAL_ATTACK]
			minimini=5*ministat
			minimini+=100
			minimini/=100.0
			miniscore*=minimini
		end
		if userFasterThanTarget
			miniscore*=0.8
		else
			miniscore*=1.2
			if ospeed<(aspeed*(3.0/2.0)) && @battle.field.effects[PBEffects::TrickRoom] == 0
				miniscore*=1.2
			end
		end
		if @battle.field.effects[PBEffects::TrickRoom]!=0
			miniscore*=0.1
		else
			miniscore*=0.1 if target.moves.any? { |j| j&.id == :TRICKROOM }
		end
		miniscore*=0.5 if target.moves.any? { |j| [:CLEARSMOG, :HAZE].include?(j&.id) }
		if user.hasActiveAbility?(:CONTRARY)
			miniscore=0
		end            
		if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
			miniscore=1
		end
		if !user.statStageAtMax?(:SPEED)
			miniscore/=100.0
			score*=miniscore
		end
		hasAlly = !target.allAllies.empty?
		if !hasAlly && move.statusMove? && @battle.choices[target.index][0] == :SwitchOut
			score*=3
		end
		score=0 if ($player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id) && move.statusMove?)
    #---------------------------------------------------------------------------
    when "RaiseUserMainStats1" # Ancient Power
		miniscore=100
		miniscore*=2 
		miniscore*=2 if user.hasActiveAbility?(:SIMPLE)
		miniscore-=100
		if move.addlEffect.to_f != 100
			miniscore*=(move.addlEffect.to_f/100.0)
			miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
		end
		miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
		miniscore+=100
		miniscore/=100.0   
		miniscore=0.1 if user.hasActiveAbility?(:CONTRARY)
		score*=miniscore
    #---------------------------------------------------------------------------
    when "RaiseUserMainStats1LoseThirdOfTotalHP" # Clangorous Soul
		if (user.hp <= user.totalhp / 2) || ($player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id) && move.statusMove?)
			score = 0
		elsif user.hasActiveAbility?(:CONTRARY)
			score = 0
		else
			stats_maxed = true
			GameData::Stat.each_main_battle do |s|
				next if user.statStageAtMax?(s.id)
				stats_maxed = false
				break
			end
			if stats_maxed
				score = 0
			else
				if target.pbHasAnyStatus?
					score*=1.2
				end
				if target.asleep?
					score*=1.3
				end
				if target.effects[PBEffects::Encore]>0
					if GameData::Move.get(target.effects[PBEffects::EncoreMove]).base_damage==0       
						score*=1.5
					end          
				end  
				if user.effects[PBEffects::Confusion]>0
					score*=0.5
				end
				if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
					score*=0.3
				end
				if user.pbHasAnyStatus?
					physmove=user.moves.any? { |m| m&.physicalMove?(m&.type) }
					specmove=user.moves.any? { |m| m&.specialMove?(m&.type) }
					if user.burned? && !specmove
						score*=0.5
					end
					if user.frozen? && !physmove
						score*=0.5
					end
					if user.paralyzed?
						score*=0.5
					end
				end
				score *= 1.2 if target.moves.any? { |m| m&.healingMove? }
				GameData::Stat.each_main_battle { |s| score *= 1.1 if user.stages[s.id] <= 0 }
				score *= 2 if user.hasActiveAbility?(:SIMPLE)
				if user.effects[PBEffects::HealBlock]==0
					healvar = healdam = false
					user.moves.each do |m|
						next if m.nil?
						if m.healingMove?
							healvar = true
							healdam = true if m.baseDamage > 0
						end
					end
					score *= 1.1 if healvar || user.hasActiveAbility?(:REGENERATOR)
					score *= 1.2 if healdam
					if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
						score *= 1.2
					end
				end
				if targetWillMove?(target)
					targetMove = @battle.choices[target.index][2]
					if targetMove.statusMove?
						score *= 1.1
					else
						if !targetSurvivesMove(targetMove,target,user,(user.totalhp / 3)) && userFasterThanTarget
							score = 0
						end
					end
				elsif @battle.choices[target.index][0] == :SwitchOut && target.allAllies.empty?
					score *= 1.5
				end
				if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
					score*=0.5
				end
			end
		end
    #---------------------------------------------------------------------------
    when "RaiseUserMainStats1TrapUserInBattle" # No Retreat
		if user.effects[PBEffects::NoRetreat] || ($player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id) && move.statusMove?)
			score = 0
		elsif user.hasActiveAbility?(:CONTRARY)
			score = 0
		else
			stats_maxed = true
			GameData::Stat.each_main_battle do |s|
				next if user.statStageAtMax?(s.id)
				stats_maxed = false
				break
			end
			if stats_maxed
				score = 0
			else
				if target.pbHasAnyStatus?
					score*=1.2
				end
				if target.asleep?
					score*=1.3
				end
				if target.effects[PBEffects::Encore]>0
					if GameData::Move.get(target.effects[PBEffects::EncoreMove]).base_damage==0       
						score*=1.5
					end          
				end  
				if user.effects[PBEffects::Confusion]>0
					score*=0.5
				end
				if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
					score*=0.3
				end
				if user.pbHasAnyStatus?
					physmove=user.moves.any? { |m| m&.physicalMove?(m&.type) }
					specmove=user.moves.any? { |m| m&.specialMove?(m&.type) }
					if user.burned? && !specmove
						score*=0.5
					end
					if user.frozen? && !physmove
						score*=0.5
					end
					if user.paralyzed?
						score*=0.5
					end
				end
				score *= 1.2 if target.moves.any? { |m| m&.healingMove? }
				score *= 1.3 if user.trappedInBattle?
				GameData::Stat.each_main_battle { |s| score *= 1.1 if user.stages[s.id] <= 0 }
				score *= 2 if user.hasActiveAbility?(:SIMPLE)
				if user.hasActiveAbility?(:RUNAWAY) || user.hasActiveItem?(:SHEDSHELL)
					score *= 2
					score *= 1.5 if @battle.choices[target.index][0] == :SwitchOut && target.allAllies.empty?
				else
					bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
					maxdam = bestmove[0]
					if maxdam>user.hp
						score*=0.4
					else
						if user.hp*(1.0/user.totalhp)>0.75
							score*=1.2
						end
						if user.hp*(1.0/user.totalhp)<0.50
							score*=0.7
							if user.hp*(1.0/user.totalhp)<0.33
								score*=0.5
							end
						end
					end
					if user.hasActiveItem?(:LEFTOVERS) || (expectedTerrain == :Grass && user.affectedByTerrain?)
					  (user.hasActiveAbility?(:HEALINGSUN) && [:Sun, :HarshSun].include?(expectedWeather) && !user.hasActiveItem?(:UTILITYUMBRELLA)) || 
					  (user.hasActiveAbility?(:RAINDISH) && [:Rain, :HeavyRain].include?(expectedWeather) && !user.hasActiveItem?(:UTILITYUMBRELLA)) || 
					  (user.hasActiveAbility?(:ICEBODY) && [:Hail].include?(expectedWeather)) || 
					  (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
						score*=1.2
					end
					if user.turnCount<2
						score*=1.5
					else
						score*=0.7
					end
					if pbHasPivotMove?(user)
						score*=0.8
					end
					if target.effects[PBEffects::TwoTurnAttack] || target.effects[PBEffects::HyperBeam]>0
						score*=2
					end
					if target.allAllies.any?
						score*=0.7
					end
				end
				if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
					score*=0.5
				end
			end
		end
    #---------------------------------------------------------------------------
    when "StartRaiseUserAtk1WhenDamaged" # rage
		if user.attack>user.spatk
			score*=1.2
		end
		if user.hp==user.totalhp
			score*=1.3
		end
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam = bestmove[0]
		if maxdam<(user.hp/4.0)
			score*=1.3
		end
    #---------------------------------------------------------------------------
    when "LowerUserAttack1", "LowerUserAttack2"
      score += user.stages[:ATTACK] * 10
    #---------------------------------------------------------------------------
    when "LowerUserDefense1", "LowerUserDefense2" # Clanging Scales
		if user.hasActiveAbility?(:CONTRARY) || user.pbOwnSide.effects[PBEffects::StatDropImmunity]
			score*=1.5
		else
			miniscore=100
			userlivecount 	= @battle.pbAbleNonActiveCount(user.idxOwnSide)
			targetlivecount = @battle.pbAbleCount(user.idxOpposingSide)
			if targetSurvivesMove(move,user,target)
				score*=0.9
				if !userFasterThanTarget
					score*=1.3
				else
					if target.moves.none? { |m| priorityAI(target,m)>0 }
						score*=1.2
					end
				end  
				if target.moves.any? { |m| m&.healingMove? }
					score*=0.5
				end
				if target.attack>target.spatk
					score*=0.7
				end
				bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
				maxphys = (bestmove[3]=="physical")
				if maxphys
					score*=0.7
				end
			else
				targetlivecount -= 1
			end
			if targetlivecount > 0 
				miniscore*=@battle.pbParty(target.index).length
				miniscore/=100.0
				miniscore*=0.05
				miniscore = 1-miniscore
				score*=miniscore
			end
			if userlivecount == 0 && targetlivecount > 0 
				score*=0.7
			end
		end
    #---------------------------------------------------------------------------
    when "LowerUserSpAtk1", "LowerUserSpAtk2" # Overheat
		if user.hasActiveAbility?(:CONTRARY) || user.pbOwnSide.effects[PBEffects::StatDropImmunity]
			score*=1.7
		else
			miniscore=100
			userlivecount   = @battle.pbAbleNonActiveCount(user.idxOwnSide)
			targetlivecount = @battle.pbAbleCount(user.idxOpposingSide)
			pivotvar = false
			@battle.pbParty(user.index).each do |m|
				next if m.fainted?
				pivotvar = true if pbHasPivotMove?(m)
			end
			if targetSurvivesMove(move,user,target)
				score*=0.9
				miniscore*=0.5 if target.moves.any? { |m| m&.healingMove? }
				doubleTarget = !target.allAllies.empty?
				if pivotvar && doubleTarget
					score*=1.2
				end
				if user.hasActiveAbility?(:SOULHEART)
					score*=1.3
				end
			else
				targetlivecount -= 1
			end
			if targetlivecount>1
				miniscore*=targetlivecount
				miniscore/=100.0
				miniscore*=0.05
				miniscore=(1-miniscore)
				score*=miniscore
			end
			if targetlivecount>1 && userlivecount==1
				score*=0.8
			end
		end
    #---------------------------------------------------------------------------
    when "LowerUserSpDef1", "LowerUserSpDef2"
    	score += user.stages[:SPECIAL_DEFENSE] * 10
    #---------------------------------------------------------------------------
    when "LowerUserSpeed1", "LowerUserSpeed2" # Hammer Arm
		if user.hasActiveAbility?(:CONTRARY) || user.pbOwnSide.effects[PBEffects::StatDropImmunity]
			score*=1.3
		else
			miniscore=100
			livecountuser 	 = @battle.pbAbleNonActiveCount(user.idxOwnSide)
			livecounttarget  = @battle.pbAbleCount(user.idxOpposingSide)
			pivotvar = false
			@battle.pbParty(user.index).each do |m|
				next if m.fainted?
				pivotvar = true if pbHasPivotMove?(m)
			end
			if targetSurvivesMove(move,user,target)
				score*=0.9
				if userFasterThanTarget
					score*=0.8
					if livecounttarget>1 && livecountuser==0
						score*=0.8
					end         
				else
					score*=1.1
				end
				doubleTarget = !target.allAllies.empty?
				if pivotvar && doubleTarget
					score*=1.2
				end
			else
				livecounttarget -= 1
			end
			if livecounttarget>1
				miniscore*=(livecounttarget-2)
				miniscore/=100.0
				miniscore*=0.05
				miniscore=(1-miniscore)
				score*=miniscore
			end
		end
    #---------------------------------------------------------------------------
    when "LowerUserAtkDef1" # Superpower
		if user.hasActiveAbility?(:CONTRARY) || user.pbOwnSide.effects[PBEffects::StatDropImmunity]
			score*=1.7
		else
			miniscore=100
			livecountuser 	 = @battle.pbAbleNonActiveCount(user.idxOwnSide)
			livecounttarget  = @battle.pbAbleCount(user.idxOpposingSide)
			pivotvar = false
			@battle.pbParty(user.index).each do |m|
				next if m.fainted?
				pivotvar = true if pbHasPivotMove?(m)
			end
			if targetSurvivesMove(move,user,target)
				score*=0.9
				if !userFasterThanTarget
					score*=1.2
				else
					score*=0.8 if target.moves.any? { |m| priorityAI(target,m)>0 }
					score*=0.5 if target.moves.any? { |m| m&.healingMove? }
				end
				doubleTarget = !target.allAllies.empty?
				if pivotvar && doubleTarget
					score*=1.2
				end
				if livecounttarget>1 && livecountuser==1
					score*=0.8
				end
			else
				livecounttarget -= 1
			end
			if livecounttarget>1
				miniscore*=(livecounttarget-2)
				miniscore/=100.0
				miniscore*=0.05
				miniscore=(1-miniscore)
				score*=miniscore
			end
			if user.hasActiveAbility?(:MOXIE)
				score*=1.5
			end
		end
    #---------------------------------------------------------------------------
    when "LowerUserDefSpDef1" # close combat
		if user.hasActiveAbility?(:CONTRARY) || user.pbOwnSide.effects[PBEffects::StatDropImmunity]
			score*=1.5
		else
			miniscore=100
			livecountuser 	 = @battle.pbAbleNonActiveCount(user.idxOwnSide)
			livecounttarget  = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
			pivotvar = false
			@battle.pbParty(user.index).each do |m|
				next if m.fainted?
				pivotvar = true if pbHasPivotMove?(m)
			end
			if targetSurvivesMove(move,user,target)
				score*=0.9
				if !userFasterThanTarget
					score*=1.2
				else
					score*=0.7 if target.moves.any? { |m| priorityAI(target,m)>0 }
					score*=0.7 if target.moves.any? { |m| m&.healingMove? }
				end
				doubleTarget = !target.allAllies.empty?
				if pivotvar && doubleTarget
					score*=1.2
				end
				if livecounttarget>1 && livecountuser==1
					score*=0.8
				end
			else
				livecounttarget -= 1
			end
			if livecounttarget>1
				miniscore*=(livecounttarget-2)
				miniscore/=100.0
				miniscore*=0.05
				miniscore=(1-miniscore)
				score*=miniscore
			end
		end
    #---------------------------------------------------------------------------
    when "LowerUserDefSpDefSpd1" # V-Create
		if user.hasActiveAbility?(:CONTRARY) || user.pbOwnSide.effects[PBEffects::StatDropImmunity]
			score*=1.7
		else
			if targetSurvivesMove(move,user,target)
				score*=0.8
				if !userFasterThanTarget
					score*=1.3
				else
					score*=0.7 if target.moves.any? { |m| priorityAI(target,m)>0 }
				end
				miniscore=100
				livecountuser 	 = @battle.pbAbleNonActiveCount(user.idxOwnSide)
				livecounttarget  = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
				if livecounttarget>1
					miniscore*=(livecounttarget-2)
					miniscore/=100.0
					miniscore*=0.05
					miniscore=(1-miniscore)
					score*=miniscore
				end
				pivotvar = false
				@battle.pbParty(user.index).each do |m|
					if pbHasPivotMove?(m)
						pivotvar = true
					end
				end
				doubleTarget = !target.allAllies.empty?
				if pivotvar && doubleTarget
					score*=1.2
				end
				if livecounttarget>1 && livecountuser==1
					score*=0.7
				end
			end
		end
    #---------------------------------------------------------------------------
    when "RaiseTargetAttack2ConfuseTarget" # swagger
		if target.opposes?(user) # is enemy
			if target.pbCanConfuse?(user, false)
				if $player.difficulty_mode?("chaos")
					miniscore = pbTargetBenefitsFromStatus?(user, target, :DIZZY, 90, move, globalArray, skill)
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
				score*=miniscore
			else
				score = 0
			end
		else # is ally
			miniscore = -100 # neg due to being ally
			if target.pbCanConfuse?(user, false)
				miniscore*=0.5
			else
				miniscore*=1.5
			end          
			if target.attack>target.spatk
				miniscore*=1.5
			end
			if (1.0/target.totalhp)*target.hp < 0.6
				miniscore*=0.3
			end
			if target.effects[PBEffects::Attract]>=0 || target.paralyzed? || target.effects[PBEffects::Yawn]>0 || target.asleep?
				miniscore*=0.3
			end    
			if $player.difficulty_mode?("chaos")
				minimi = getAbilityDisruptScore(move,user,target,skill)
				minimi = 1.0 / minimi
				miniscore*=minimi
			else
				if target.hasActiveAbility?(:CONTRARY)
					miniscore = 0
				end
			end
			if target.hasActiveItem?([:PERSIMBERRY, :LUMBERRY])
				miniscore*=1.2
			end
			if target.effects[PBEffects::Substitute]>0
				miniscore = 0
			end
			enemy1 = user.pbDirectOpposing
			enemy2 = enemy1.allAllies.first
			if ospeed > pbRoughStat(enemy1,:SPEED,skill) && 
			   ospeed > pbRoughStat(enemy2,:SPEED,skill)
				miniscore*=1.3
			else
				miniscore*=0.7
			end
			if enemy1.pbHasMove?(:FOULPLAY) || 
				enemy2.pbHasMove?(:FOULPLAY)
				miniscore*=0.3
			end
			miniscore/=100.0
			score *= miniscore
		end
    #---------------------------------------------------------------------------
    when "RaiseTargetSpAtk1ConfuseTarget" # flatter
		if target.opposes?(user) # is enemy
			if target.pbCanConfuse?(user, false)
				if $player.difficulty_mode?("chaos")
					miniscore = pbTargetBenefitsFromStatus?(user, target, :DIZZY, 90, move, globalArray, skill)
				else
					miniscore = 100
				end
				ministat=0
				ministat+=target.stages[:SPECIAL_ATTACK]
				if ministat>0
					minimini=10*ministat
					minimini+=100
					minimini/=100.0
					miniscore*=minimini
				end      
				if target.attack>target.spatk
					miniscore*=1.5
				else
					miniscore*=0.3
				end
				if target.moves.none? { |j| j.specialMove?(j.type) }
					miniscore*=1.5
				else
					miniscore*=0.5
				end
				if target.effects[PBEffects::Attract]>=0
					miniscore*=1.1
				end
				if target.paralyzed?
					miniscore*=1.1
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
				score*=miniscore
			else
				score = 0
			end
		else # is ally
			miniscore = -100 # neg due to being ally
			if target.pbCanConfuse?(user, false)
				miniscore*=0.5
			else
				miniscore*=1.5
			end          
			if target.attack<target.spatk
				miniscore*=1.5
			end
			if (1.0/target.totalhp)*target.hp < 0.6
				miniscore*=0.3
			end
			if target.effects[PBEffects::Attract]>=0 || target.paralyzed? || target.effects[PBEffects::Yawn]>0 || target.asleep?
				miniscore*=0.3
			end    
			if $player.difficulty_mode?("chaos")
				minimi = getAbilityDisruptScore(move,user,target,skill)
				minimi = 1.0 / minimi
				miniscore*=minimi
			else
				if target.hasActiveAbility?(:CONTRARY)
					miniscore = 0
				end
			end
			if target.hasActiveItem?([:PERSIMBERRY, :LUMBERRY])
				miniscore*=1.2
			end
			if target.effects[PBEffects::Substitute]>0
				miniscore = 0
			end
			enemy1 = user.pbDirectOpposing
			enemy2 = enemy1.allAllies.first
			if ospeed > pbRoughStat(enemy1,:SPEED,skill) && 
			   ospeed > pbRoughStat(enemy2,:SPEED,skill)
				miniscore*=1.3
			else
				miniscore*=0.7
			end
			miniscore/=100.0
			score *= miniscore
		end
    #---------------------------------------------------------------------------
    when "RaiseTargetSpDef1" # Aromatic Mist
		hasAlly = !user.allAllies.empty?
		if hasAlly && !target.opposes?(user) && !target.statStageAtMax?(:SPECIAL_DEFENSE)
			t_hasAlly = !target.allAllies.empty?
			if !t_hasAlly && move.statusMove? && @battle.choices[target.index][0] == :SwitchOut
				miniscore*=2
			end
			if target.hp*(1.0/target.totalhp)>0.75
				score*=1.1
			end
			if target.effects[PBEffects::Yawn]>0 || target.effects[PBEffects::LeechSeed]>=0 || 
					target..effects[PBEffects::Attract]>=0 || target.pbHasAnyStatus?
				score*=0.3
			end
			if movecheck
				score*=0.2
			end
			if target.hasActiveAbility?(:SIMPLE)
				score*=2
			end
			if target.hasActiveItem?(:LEFTOVERS) || (target.hasActiveItem?(:BLACKSLUDGE) && target.pbHasType?(:POISON, true))
				score*=1.2
			end
			if target.hasActiveAbility?(:CONTRARY)
				score=0
			end
			score=0 if $player.difficulty_mode?("chaos") && target.SetupMovesUsed.include?(move.id)
		else
			score=0
		end
    #---------------------------------------------------------------------------
    when "RaiseTargetRandomStat2" # Acupressure
		miniscore=100        
		if (target.hasActiveAbility?(:DISGUISE,false,mold_broken) && target.form == 0) || target.effects[PBEffects::Substitute]>0
			miniscore*=1.3
		end
		hasAlly = !target.allAllies.empty?
		if !hasAlly && move.statusMove? && @battle.choices[target.index][0] == :SwitchOut
			miniscore*=2
		end
		if (user.hp.to_f)/user.totalhp>0.75
			miniscore*=1.2
		end
		if (user.hp.to_f)/user.totalhp<0.33
			miniscore*=0.3
		end
		if (user.hp.to_f)/user.totalhp<0.75 && (user.hasActiveAbility?(:EMERGENCYEXIT) || user.hasActiveAbility?(:WIMPOUT) || user.hasActiveItem?(:EJECTBUTTON))
			miniscore*=0.3
		end
		if target.effects[PBEffects::HyperBeam]>0
			miniscore*=1.3
		end
		if target.effects[PBEffects::Yawn]>0
			miniscore*=1.7
		end
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam=bestmove[0]
		if maxdam<(user.hp/4.0)
			miniscore*=1.2
		else
			miniscore*=0.8
			if maxdam>user.hp
				miniscore*=0.1
			end
		end
		if user.turnCount<2
			miniscore*=1.2
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
			miniscore*=0.2
		end
		if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
			miniscore*=0.6
		end
		if pbHasPhazingMove?(target)
			miniscore*=0.5
		end
		if user.hasActiveAbility?(:SIMPLE)
			miniscore*=2
		end
		hasAlly = !target.allAllies.empty?
		if hasAlly
			miniscore*=0.7
		end
		roles = pbGetPokemonRole(user, target)
		if roles.include?("Physical Wall") || roles.include?("Special Wall")
			miniscore*=1.3
		end
		if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
			miniscore*=1.2
		end
		miniscore*=1.3 if user.moves.any? { |m| m&.healingMove? }
		if user.pbHasMove?(:LEECHSEED)
			miniscore*=1.3
		end
		if user.pbHasMove?(:PAINSPLIT)
			miniscore*=1.2
		end
		miniscore/=100.0
		maxstat=0
		maxstat+=1 if user.statStageAtMax?(:ATTACK)        
		maxstat+=1 if user.statStageAtMax?(:DEFENSE)        
		maxstat+=1 if user.statStageAtMax?(:SPECIAL_ATTACK)        
		maxstat+=1 if user.statStageAtMax?(:SPECIAL_DEFENSE)        
		maxstat+=1 if user.statStageAtMax?(:SPEED)        
		maxstat+=1 if user.statStageAtMax?(:ACCURACY)        
		maxstat+=1 if user.statStageAtMax?(:EVASION)        
		if maxstat>1
			miniscore=0
		end
		miniscore*=0 if target.moves.any? { |j| [:CLEARSMOG, :HAZE].include?(j&.id) }
		if user.hasActiveAbility?(:CONTRARY)
			miniscore*=0
		end            
		if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
			miniscore=1
		end
		score*=miniscore
		score=0 if ($player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id) && move.statusMove?)
    #---------------------------------------------------------------------------
    when "RaiseTargetAtkSpAtk2" # Decorate
		if target.hasActiveAbility?(:CONTRARY)
			if target.opposes?(user) && @battle.choices[target.index][0] != :SwitchOut
				score -= target.stages[:ATTACK] * 20
				score -= target.stages[:SPECIAL_ATTACK] * 20
			else
				score -= 100
			end
		elsif target.opposes?(user) || ($player.difficulty_mode?("chaos") && target.SetupMovesUsed.include?(move.id))
			score -= 100
		else
			score -= target.stages[:ATTACK] * 20
			score -= target.stages[:SPECIAL_ATTACK] * 20
			score *= -1
		end
    #---------------------------------------------------------------------------
    when "LowerTargetAttack1", "LowerTargetAttack1BypassSubstitute" # growl
		if (pbRoughStat(target,:SPECIAL_ATTACK,skill)>pbRoughStat(target,:ATTACK,skill)) || 
			!target.pbCanLowerStatStage?(:ATTACK)
			if move.baseDamage==0
				score=0
			end
		else
			miniscore=100
			livecountuser 	 = @battle.pbAbleNonActiveCount(user.idxOwnSide)
			livecounttarget  = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
			if livecounttarget==0 || user.hasActiveAbility?([:SHADOWTAG, :ARENATRAP]) || target.effects[PBEffects::MeanLook]>0
				miniscore*=1.4
			end
			if target.poisoned?
				miniscore*=1.2
			end
			if target.stages[:ATTACK]!=0
				minimini = 10*target.stages[:ATTACK]
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
			if target.hasActiveAbility?([:UNAWARE, :COMPETITIVE, :DEFIANT, :CONTRARY])
				miniscore*=0.1
			end
			if (move.statusMove? || move.addlEffect.to_f == 100) && userFasterThanTarget && targetWillMove?(target, "phys")
				miniscore*=1.2
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
				if livecounttarget==1
					miniscore*=0.5
				end
				if (user.hp.to_f)/user.totalhp>0.8
					miniscore*=1.2
				else
					miniscore*=0.4
				end
				bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
				maxdam = bestmove[0]
				if maxdam>user.hp
					miniscore*=0.1
				end
				physmove=target.moves.any? { |m| m&.physicalMove?(m&.type) }
				miniscore*=0.1 if !physmove
			end
			miniscore/=100.0    
			score*=miniscore
		end
    #---------------------------------------------------------------------------
    when "LowerTargetAttack2", "LowerTargetAttack3" # feather dance
		if (pbRoughStat(target,:SPECIAL_ATTACK,skill)>pbRoughStat(target,:ATTACK,skill)) || 
			!target.pbCanLowerStatStage?(:ATTACK)
			if move.baseDamage==0
				score=0
			end
		else
			miniscore=120
			livecountuser 	 = @battle.pbAbleNonActiveCount(user.idxOwnSide)
			livecounttarget  = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
			if livecounttarget==0 || user.hasActiveAbility?([:SHADOWTAG, :ARENATRAP]) || target.effects[PBEffects::MeanLook]>0
				miniscore*=1.4
			end
			if target.poisoned?
				miniscore*=1.2
			end
			if target.stages[:ATTACK]!=0
				minimini = 10*target.stages[:ATTACK]
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
			if target.hasActiveAbility?([:UNAWARE, :COMPETITIVE, :DEFIANT, :CONTRARY])
				miniscore*=0.1
			end
			if (move.statusMove? || move.addlEffect.to_f == 100) && userFasterThanTarget && targetWillMove?(target, "phys")
				miniscore*=1.2
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
				if livecounttarget==1
					miniscore*=0.5
				end
				if (user.hp.to_f)/user.totalhp>0.8
					miniscore*=1.2
				else
					miniscore*=0.4
				end
				bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
				maxdam = bestmove[0]
				if maxdam>user.hp
					miniscore*=0.1
				end
				physmove=target.moves.any? { |m| m&.physicalMove?(m&.type) }
				miniscore*=0.1 if !physmove
			end
			miniscore/=100.0    
			score*=miniscore
		end
    #---------------------------------------------------------------------------
    when "LowerTargetDefense1", "LowerTargetDefense1PowersUpInGravity" # Tail Whip
		physmove=user.moves.any? { |m| m&.physicalMove?(m&.type) }
		if !physmove || !target.pbCanLowerStatStage?(:DEFENSE)
			if move.baseDamage==0
				score=0
			end
		else
			miniscore=100
			miniscore*=1.5 if target.moves.any? { |m| m&.healingMove? }
			livecountuser 	 = @battle.pbAbleNonActiveCount(user.idxOwnSide)
			livecounttarget  = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
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
			if livecounttarget==1
				miniscore*=0.5
			end
			if target.hasActiveAbility?([:UNAWARE,:COMPETITIVE, :DEFIANT, :CONTRARY])
				miniscore*=0.1
			end
			if user.burned?
				miniscore*=0.7
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
				if livecounttarget==1
					miniscore*=0.5
				end
				if user.pbHasAnyStatus?
					miniscore*=0.7
				end
			end
			miniscore/=100.0    
			score*=miniscore
		end
    #---------------------------------------------------------------------------
    when "LowerTargetDefense2", "LowerTargetDefense3" # screech
		physmove=user.moves.any? { |m| m&.physicalMove?(m&.type) }
		if !physmove || !target.pbCanLowerStatStage?(:DEFENSE)
			if move.baseDamage==0
				score=0
			end
		else
			miniscore=120
			miniscore*=1.5 if target.moves.any? { |m| m&.healingMove? }
			livecountuser 	 = @battle.pbAbleNonActiveCount(user.idxOwnSide)
			livecounttarget  = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
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
			if livecounttarget==1
				miniscore*=0.5
			end
			if target.hasActiveAbility?([:UNAWARE,:COMPETITIVE, :DEFIANT, :CONTRARY])
				miniscore*=0.1
			end
			if user.pbHasAnyStatus?
				miniscore*=0.7
			end
			if user.burned?
				miniscore*=0.7
			end
			miniscore/=100.0    
			score*=miniscore
		end
    #---------------------------------------------------------------------------
    when "LowerTargetSpAtk1" # snarl
		if (pbRoughStat(target,:SPECIAL_ATTACK,skill)<pbRoughStat(target,:ATTACK,skill)) || 
			!target.pbCanLowerStatStage?(:SPECIAL_ATTACK)
			if move.baseDamage==0
				score=0
			end
		else
			miniscore=100
			livecountuser 	 = @battle.pbAbleNonActiveCount(user.idxOwnSide)
			livecounttarget  = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
			if livecounttarget==0 || user.hasActiveAbility?([:SHADOWTAG, :ARENATRAP]) || target.effects[PBEffects::MeanLook]>0
				miniscore*=1.4
			end
			if target.poisoned? || target.burned? || target.frozen?
				miniscore*=1.2
			end
			if target.stages[:SPECIAL_ATTACK]!=0
				minimini = 10*target.stages[:SPECIAL_ATTACK]
				minimini *= 1.1 if move.baseDamage==0
				minimini+=100
				minimini/=100.0
				miniscore*=minimini
			end     
			if target.hasActiveAbility?([:UNAWARE, :COMPETITIVE, :DEFIANT, :CONTRARY])
				miniscore*=0.1
			end
			if (move.statusMove? || move.addlEffect.to_f == 100) && userFasterThanTarget && targetWillMove?(target, "spec")
				miniscore*=1.2
			end
			if user.frozen?
				miniscore*=0.7
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
				if livecounttarget==1
					miniscore*=0.5
				end
			end       
			miniscore/=100.0    
			score*=miniscore
		end
    #---------------------------------------------------------------------------
    when "LowerTargetSpAtk2", "LowerTargetSpAtk3" # eerie impulse
		if (pbRoughStat(target,:SPECIAL_ATTACK,skill)<pbRoughStat(target,:ATTACK,skill)) || 
			!target.pbCanLowerStatStage?(:SPECIAL_ATTACK)
			if move.baseDamage==0
				score=0
			end
		else
			miniscore=120
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
			userlivecount 	= @battle.pbAbleNonActiveCount(user.idxOwnSide)
			targetlivecount = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
			if targetlivecount==0 || user.hasActiveAbility?([:SHADOWTAG, :ARENATRAP]) || target.effects[PBEffects::MeanLook]>0
				miniscore*=1.4
			end
			if target.poisoned? || target.burned? || target.frozen?
				miniscore*=1.2
			end
			if target.stages[:SPECIAL_ATTACK]!=0
				minimini = 10*target.stages[:SPECIAL_ATTACK]
				minimini *= 1.1 if move.baseDamage==0
				minimini+=100
				minimini/=100.0
				miniscore*=minimini
			end       
			if userlivecount==1
				miniscore*=0.5
			end
			if target.hasActiveAbility?([:UNAWARE, :COMPETITIVE, :DEFIANT, :CONTRARY])
				miniscore*=0.1
			end         
			if (move.statusMove? || move.addlEffect.to_f == 100) && userFasterThanTarget && targetWillMove?(target, "spec")
				miniscore*=1.2
			end
			miniscore/=100.0    
			score*=miniscore
		end
    #---------------------------------------------------------------------------
    when "LowerTargetSpAtk2IfCanAttract" # Captivate
		if (pbRoughStat(target,:SPECIAL_ATTACK,skill)<pbRoughStat(target,:ATTACK,skill)) || 
		    !target.pbCanLowerStatStage?(:SPECIAL_ATTACK)
			if move.baseDamage==0
				score=0
			end
		else
			miniscore=120
			livecountuser 	 = @battle.pbAbleNonActiveCount(user.idxOwnSide)
			livecounttarget  = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
			if livecounttarget==0 || user.hasActiveAbility?([:SHADOWTAG, :ARENATRAP]) || target.effects[PBEffects::MeanLook]>0
				miniscore*=1.4
			end
			if target.poisoned? || target.burned? || target.frozen?
				miniscore*=1.2
			end
			if target.stages[:SPECIAL_ATTACK]!=0
				minimini = 10*target.stages[:SPECIAL_ATTACK]
				minimini *= 1.1 if move.baseDamage==0
				minimini+=100
				minimini/=100.0
				miniscore*=minimini
			end     
			if target.hasActiveAbility?([:UNAWARE, :COMPETITIVE, :DEFIANT, :CONTRARY])
				miniscore*=0.1
			end
			if (move.statusMove? || move.addlEffect.to_f == 100) && userFasterThanTarget && targetWillMove?(target, "spec")
				miniscore*=1.2
			end
			if user.frozen?
				miniscore*=0.7
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
				if livecounttarget==1
					miniscore*=0.5
				end
			end       
			miniscore/=100.0    
			score*=miniscore
		end
		if user.gender == 2 || target.gender == 2 || user.gender == target.gender ||
		   target.hasActiveAbility?(:OBLIVIOUS,false,mold_broken)
			score = 0
		end
    #---------------------------------------------------------------------------
    when "LowerTargetSpDef1" # psychic
		specmove=user.moves.any? { |m| m&.specialMove?(m&.type) }
		if !specmove || !target.pbCanLowerStatStage?(:SPECIAL_DEFENSE)
			if move.baseDamage==0
				score=0
			end
		else
			miniscore=100
			miniscore*=1.2 if target.moves.any? { |m| m&.healingMove? }
			livecountuser 	 = @battle.pbAbleNonActiveCount(user.idxOwnSide)
			livecounttarget  = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
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
			if target.hasActiveAbility?([:UNAWARE, :COMPETITIVE, :DEFIANT, :CONTRARY])
				miniscore*=0.1
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
				if livecountuser==1
					miniscore*=0.5
				end
				if user.pbHasAnyStatus?
					miniscore*=0.7
				end
			end
			miniscore/=100.0    
			score*=miniscore
		end
    #---------------------------------------------------------------------------
    when "LowerTargetSpDef2", "LowerTargetSpDef3" # acid spray
		specmove=user.moves.any? { |m| m&.specialMove?(m&.type) }
		if !specmove || !target.pbCanLowerStatStage?(:SPECIAL_DEFENSE)
			if move.baseDamage==0
				score=0
			end
		else
			miniscore=120
			miniscore*=1.3 if target.moves.any? { |m| m&.healingMove? }
			livecountuser 	 = @battle.pbAbleNonActiveCount(user.idxOwnSide)
			livecounttarget  = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
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
			if target.hasActiveAbility?([:UNAWARE, :COMPETITIVE, :DEFIANT, :CONTRARY])
				miniscore*=0.1
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
				if livecountuser==1
					miniscore*=0.5
				end
				if user.pbHasAnyStatus?
					miniscore*=0.9
				end
			end
			miniscore/=100.0    
			score*=miniscore
		end
    #---------------------------------------------------------------------------
	when "LowerTargetSpeed1", "LowerTargetSpeed1WeakerInGrassyTerrain", "LowerTargetSpeed1MakeTargetWeakerToFire" 
		# Rock Tomb, bulldoze, tar shot
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
			if move.baseDamage==0
				if move.function == "LowerTargetSpeed1MakeTargetWeakerToFire" && !target.effects[PBEffects::TarShot]
					score *= 1.2 if user.moves.any? { |m| m.damagingMove? && m.pbCalcType(user) == :FIRE }
				else
					score=0
				end
			end
		else
			miniscore=110
			if (ospeed*(2.0/3.0))<aspeed
				miniscore*=1.2
			end
			if user.allAllies.any?
				user.allAllies.each do |b|
					next if (ospeed*(2.0/3.0))>pbRoughStat(b,:SPEED,skill)
					miniscore*=1.2
					miniscore*=1.2 if userFasterThanTarget
				end
			end
			if target.allAllies.any? && [:GLACIATE, :ICYWIND, :ELECTROWEB].include?(move.id)
				miniscore*=1.2
			end
			livecountuser 	 = @battle.pbAbleNonActiveCount(user.idxOwnSide)
			livecounttarget  = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
			if livecounttarget==0 || user.hasActiveAbility?([:SHADOWTAG, :ARENATRAP]) || target.effects[PBEffects::MeanLook]>0
				miniscore*=1.4
			end
			if target.stages[:SPEED]!=0
				minimini = 5*target.stages[:SPEED]
				minimini *= 1.1 if move.baseDamage==0
				minimini+=100
				minimini/=100.0
				miniscore*=minimini
			end
			if target.hasActiveAbility?([:COMPETITIVE, :DEFIANT, :CONTRARY])
				miniscore*=0.1
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
			
			miniscore*=0.7 if move.function == "LowerTargetSpeed1WeakerInGrassyTerrain" && expectedTerrain == :Grassy
			if move.baseDamage==0
				if move.function == "LowerTargetSpeed1MakeTargetWeakerToFire"
					if target.effects[PBEffects::TarShot]
						miniscore = 0
					else
						miniscore *= 1.2 if user.moves.any? { |m| m.damagingMove? && m.pbCalcType(user) == :FIRE }
					end
				end
			else
				miniscore-=100
				if move.addlEffect.to_f != 100
					miniscore*=(move.addlEffect.to_f/100.0)
					miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
				end
				miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
				miniscore+=100
			end
			miniscore/=100.0    
			if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
				miniscore=1
			end
			if target.hasActiveAbility?(:SPEEDBOOST)
				miniscore=1
			end
			score*=miniscore
		end
    #---------------------------------------------------------------------------
    when "LowerTargetSpeed2", "LowerTargetSpeed3" # scary face
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
			score=0 if move.baseDamage==0
		else
			miniscore=125
			if (ospeed/2.0)<aspeed
				miniscore*=1.2
			end
			if user.allAllies.any?
				user.allAllies.each do |b|
					next if (ospeed/2.0)>pbRoughStat(b,:SPEED,skill)
					miniscore*=1.2
					miniscore*=1.2 if userFasterThanTarget
				end
			end
			livecountuser 	 = @battle.pbAbleNonActiveCount(user.idxOwnSide)
			livecounttarget  = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
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
			if target.hasActiveAbility?([:COMPETITIVE, :DEFIANT, :CONTRARY])
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
			if target.hasActiveItem?([:LAGGINGTAIL, :IRONBALL])
				miniscore*=0.1
			end
			miniscore*=1.3 if target.moves.any? { |j| j&.id == :ELECTROBALL }
			miniscore*=0.5 if target.moves.any? { |j| j&.id == :GYROBALL }
			miniscore/=100.0
			score*=miniscore
		end
    #---------------------------------------------------------------------------
    when "LowerTargetAccuracy1", "LowerTargetAccuracy2", "LowerTargetAccuracy3" # Mud-Slap, Sand Attack
    	score = 0 if move.statusMove? # they do jackshit
    #---------------------------------------------------------------------------
    when "LowerTargetEvasion1"
		if move.statusMove?
			if target.pbCanLowerStatStage?(:EVASION, user)
				score += target.stages[:EVASION] * 10
			else
				score -= 90
			end
		elsif target.stages[:EVASION] > 0
			score += 20
		end
    #---------------------------------------------------------------------------
    when "LowerTargetEvasion1RemoveSideEffects" # defog
		miniscore=100
		livecountuser 	 = @battle.pbAbleNonActiveCount(user.idxOwnSide)
		livecounttarget  = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
		if livecounttarget>1
			miniscore*=2 if user.pbOwnSide.effects[PBEffects::StealthRock]
			miniscore*=(1.8**user.pbOwnSide.effects[PBEffects::StickyWeb])
			miniscore*=(1.5**user.pbOwnSide.effects[PBEffects::Spikes])
			miniscore*=(1.7**user.pbOwnSide.effects[PBEffects::ToxicSpikes])
		end
		miniscore-=100
		miniscore*=livecounttarget if livecounttarget>1
		minimini=100
		if livecountuser>1
			minimini*=0.5 if user.pbOwnSide.effects[PBEffects::StealthRock]
			minimini*=(0.3**user.pbOwnSide.effects[PBEffects::StickyWeb])
			minimini*=(0.7**user.pbOwnSide.effects[PBEffects::Spikes])
			minimini*=(0.6**user.pbOwnSide.effects[PBEffects::ToxicSpikes])
		end
		minimini-=100
		minimini*=livecountuser if livecountuser>1
		miniscore+=minimini
		miniscore+=100
		if miniscore<0
			miniscore=0
		end
		miniscore/=100.0
		score*=miniscore
		if target.pbOwnSide.effects[PBEffects::AuroraVeil]>0
			score*=1.8
		end
		if target.pbOwnSide.effects[PBEffects::Reflect]>0
			score*=2
		end
		if target.pbOwnSide.effects[PBEffects::LightScreen]>0
			score*=2
		end
		if target.pbOwnSide.effects[PBEffects::Mist]>0
			score*=1.3
		end
		if target.pbOwnSide.effects[PBEffects::Safeguard]>0
			score*=1.3
		end
    #---------------------------------------------------------------------------
    when "LowerTargetEvasion2", "LowerTargetEvasion3" # Sweet Scent
		if move.statusMove?
			if target.pbCanLowerStatStage?(:EVASION, user)
				score += target.stages[:EVASION] * 10
			else
				score -= 90
			end
		elsif target.stages[:EVASION] > 0
			score += 20
		end
    #---------------------------------------------------------------------------
    when "LowerTargetAtkDef1" # tickle
		livecountuser 	 = @battle.pbAbleNonActiveCount(user.idxOwnSide)
		livecounttarget  = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
		if (pbRoughStat(target,:SPECIAL_ATTACK,skill)>pbRoughStat(target,:ATTACK,skill)) || 
			!target.pbCanLowerStatStage?(:ATTACK)
			if move.baseDamage==0
				score*=0.5
			end
		else
			miniscore=100
			if livecounttarget==0 || user.hasActiveAbility?([:SHADOWTAG, :ARENATRAP]) || target.effects[PBEffects::MeanLook]>0
				miniscore*=1.4
			end
			if target.poisoned?
				miniscore*=1.2
			end
			if target.stages[:ATTACK]+target.stages[:DEFENSE]!=0
				minimini = 5*target.stages[:ATTACK]
				minimini+= 5*target.stages[:DEFENSE]
				minimini *= 1.1 if move.baseDamage==0
				minimini+=100
				minimini/=100.0
				miniscore*=minimini
			end
			if user.pbHasMove?(:FOULPLAY)
				miniscore*=0.5
			end  
			if livecountuser==1
				miniscore*=0.5
			end
			if target.burned? && !target.hasActiveAbility?(:GUTS)
				miniscore*=0.5
			end       
			if target.hasActiveAbility?([:UNAWARE, :COMPETITIVE, :DEFIANT, :CONTRARY])
				miniscore*=0.1
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
				if livecountuser==1
					miniscore*=0.5
				end
			end
			miniscore/=100.0    
			score*=miniscore
		end
		miniscore=100
		physmove=user.moves.any? { |m| m&.physicalMove?(m&.type) }
		if !physmove || !target.pbCanLowerStatStage?(:DEFENSE)
			if move.baseDamage==0
				score*=0.5
			end
		else
			miniscore*=1.3 if target.moves.any? { |m| m&.healingMove? }
			if livecounttarget==0 || user.hasActiveAbility?([:SHADOWTAG, :ARENATRAP]) || target.effects[PBEffects::MeanLook]>0
				miniscore*=1.4
			end
			if livecountuser==1
				miniscore*=0.5
			end
			if target.poisoned?
				miniscore*=1.2
			end
			if target.stages[:DEFENSE]!=0
				minimini = 5*target.stages[:DEFENSE]
				minimini *= 1.1 if move.baseDamage==0
				minimini+=100
				minimini/=100.0
				miniscore*=minimini
			end     
			if target.hasActiveAbility?([:UNAWARE,:COMPETITIVE, :DEFIANT, :CONTRARY])
				miniscore*=0.1
			end
			if user.pbHasAnyStatus?
				miniscore*=0.7
			end
			if user.burned?
				miniscore*=0.7
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
		end
    #---------------------------------------------------------------------------
    when "LowerTargetAtkSpAtk1" # noble roar
		if !target.pbCanLowerStatStage?(:ATTACK) && !target.pbCanLowerStatStage?(:SPECIAL_ATTACK)
			score*=0
		else
			miniscore=100
			roles = pbGetPokemonRole(user, target)
			if roles.include?("Physical Wall") || roles.include?("Special Wall")
				miniscore=1.3
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
			livecountuser 	 = @battle.pbAbleNonActiveCount(user.idxOwnSide)
			livecounttarget  = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
			if livecounttarget==0 || user.hasActiveAbility?([:SHADOWTAG, :ARENATRAP]) || target.effects[PBEffects::MeanLook]>0
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
			if user.pbHasMove?(:FOULPLAY)
				miniscore*=0.5
			end
			if livecountuser == 0
				miniscore*=0.5
			end
			if target.hasActiveAbility?([:UNAWARE, :DEFIANT, :COMPETITIVE, :CONTRARY])
				miniscore*=0.1
			end
			miniscore/=100.0
			score*=miniscore
		end
    #---------------------------------------------------------------------------
    when "LowerPoisonedTargetAtkSpAtkSpd1" # Venom Drench
		if target.poisoned?
			if !target.pbCanLowerStatStage?(:ATTACK) && !target.pbCanLowerStatStage?(:SPECIAL_ATTACK)
				score=0
			else
				miniscore=100
				roles = pbGetPokemonRole(user, target)
				if roles.include?("Physical Wall") || roles.include?("Special Wall")
					miniscore=1.4
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
				livecountuser 	 = @battle.pbAbleNonActiveCount(user.idxOwnSide)
				livecounttarget  = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
				if livecounttarget==0 || user.hasActiveAbility?([:SHADOWTAG, :ARENATRAP]) || target.effects[PBEffects::MeanLook]>0
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
				if user.pbHasMove?(:FOULPLAY)
					miniscore*=0.5
				end
				if livecountuser == 0
					miniscore*=0.5
				end
				if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
					miniscore*=0.1
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
				miniscore=1
			else
				miniscore=100            
				if target.hasActiveAbility?(:SPEEDBOOST)
					miniscore*=0.9
				end
				if user.pbHasMove?(:ELECTROBALL)
					miniscore*=1.5
				end  
				if target.pbHasMove?(:GYROBALL)
					miniscore*=1.5
				end   
				if @battle.field.effects[PBEffects::TrickRoom]!=0
					miniscore*=0.1
				else
					miniscore*=0.1 if target.moves.any? { |j| j&.id == :TRICKROOM }
				end   
				if target.hasActiveItem?(:LAGGINGTAIL) || target.hasActiveItem?(:IRONBALL)
					miniscore*=0.8
				end
				miniscore*=1.3 if target.moves.any? { |j| j&.id == :ELECTROBALL }
				miniscore*=0.5 if target.moves.any? { |j| j&.id == :GYROBALL }
				miniscore/=100.0    
				score*=miniscore
				if @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
					score*=0.5
				end
			end
			if target.hasActiveAbility?([:COMPETITIVE, :DEFIANT, :CONTRARY])
				score*=0
			end
		else
			score*=0
		end
    #---------------------------------------------------------------------------
    when "RaiseUserAndAlliesAtkDef1" # Coaching
      has_ally = false
      user.allAllies.each do |b|
        next if !b.pbCanLowerStatStage?(:ATTACK, user) &&
                !b.pbCanLowerStatStage?(:SPECIAL_ATTACK, user)
		next if  $player.difficulty_mode?("chaos") && b.SetupMovesUsed.include?(move.id)
        has_ally = true
        if skill >= PBTrainerAI.mediumSkill && b.hasActiveAbility?(:CONTRARY)
          score -= 90
        else
          score += 40
          score -= b.stages[:ATTACK] * 20
          score -= b.stages[:SPECIAL_ATTACK] * 20
        end
      end
      score = 0 if !has_ally
    #---------------------------------------------------------------------------
    when "RaisePlusMinusUserAndAlliesAtkSpAtk1" # Gear Up
		hasEffect = user.statStageAtMax?(:ATTACK) &&
					user.statStageAtMax?(:SPECIAL_ATTACK)
		user.allAllies.each do |b|
			next if b.statStageAtMax?(:ATTACK) && b.statStageAtMax?(:SPECIAL_ATTACK)
					next if $player.difficulty_mode?("chaos") && b.SetupMovesUsed.include?(move.id)
			hasEffect = true
			score -= b.stages[:ATTACK] * 10
			score -= b.stages[:SPECIAL_ATTACK] * 10
		end
		if hasEffect
			score -= user.stages[:ATTACK] * 10
			score -= user.stages[:SPECIAL_ATTACK] * 10
		else
			score -= 90
		end
    #---------------------------------------------------------------------------
    when "RaisePlusMinusUserAndAlliesDefSpDef1" # Magnetic Flux
		bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
		maxdam = bestmove[0]
		movecheck = false
		movecheck = true if pbHasPhazingMove?(target)
		plusminus = false
		user.allAllies.each do |b|
			plusminus = true if b.hasActiveAbility?([:PLUS, :MINUS])
		end
		hasAlly = !target.allAllies.empty?
		if !(user.hasActiveAbility?([:PLUS, :MINUS]) || plusminus)
			score*=0
		else
			if user.hasActiveAbility?([:PLUS, :MINUS])
				miniscore=100
				if user.effects[PBEffects::Substitute]>0
					miniscore*=1.3
				end
				if !hasAlly && move.statusMove? && @battle.choices[target.index][0] == :SwitchOut
					miniscore*=2
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
				if maxdam < 0.3*user.hp
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
					miniscore*=0.5
				end
				if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
					miniscore*=0.3
				end
				if user.effects[PBEffects::Toxic]>0
					miniscore*=0.2
				end
				if movecheck
					miniscore*=0.2
				end            
				if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
					miniscore*=0.5
				end
				if maxdam<0.12*user.hp
					miniscore*=0.2
				end
				score*=miniscore
				miniscore=100
				roles = pbGetPokemonRole(user, target)
				if roles.include?("Physical Wall") || roles.include?("Special Wall")
					miniscore*=1.5
				end
				if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
					miniscore*=1.2
				end
				miniscore*=1.7 if user.moves.any? { |m| m&.healingMove? }
				if user.pbHasMove?(:LEECHSEED)
					miniscore*=1.3
				end
				if user.pbHasMove?(:PAINSPLIT)
					miniscore*=1.2
				end        
				if user.stages[:SPECIAL_DEFENSE]!=6 && user.stages[:DEFENSE]!=6
					score*=miniscore   
				end
			else
				score*=0
			end          
		end
    #---------------------------------------------------------------------------
    when "RaiseGroundedGrassBattlersAtkSpAtk1" # Rototiller
		movecheck = false
		movecheck = true if pbHasPhazingMove?(target)
		count = 0
		@battle.allBattlers.each do |b|
			mold_bonkers=moldbroken(user,b,move)
			if b.pbHasType?(:GRASS, true) && !b.airborneAI(mold_bonkers) &&
			   (!b.statStageAtMax?(:ATTACK) || !b.statStageAtMax?(:SPECIAL_ATTACK)) && ($player.difficulty_mode?("chaos") && !b.SetupMovesUsed.include?(move.id))
				count += 1
				if user.opposes?(b)
					score *= 0.5
				else
					if (b.hp.to_f)/b.totalhp>0.75
						score*=1.1
					end          
					if b.effects[PBEffects::LeechSeed]>=0 || b.effects[PBEffects::Attract]>=0 || 
							b.pbHasAnyStatus? || b.effects[PBEffects::Yawn]>0            
						score*=0.3
					end   
					if movecheck
						score*=0.2
					end          
					if b.hasActiveAbility?(:SIMPLE)
						score*=2
					end
					if b.hasActiveAbility?(:CONTRARY)
						score*=0
					end 
				end
			end
		end
      	score = 0 if count == 0
    #---------------------------------------------------------------------------
    when "RaiseGrassBattlersDef1" # flower shield
		movecheck = pbHasPhazingMove?(target)
		count = 0
		@battle.allBattlers.each do |b|
			if b.pbHasType?(:GRASS, true) && !b.statStageAtMax?(:DEFENSE) && ($player.difficulty_mode?("chaos") && !b.SetupMovesUsed.include?(move.id))
				count += 1
				if user.opposes?(b)
					score *= 0.5
				else
					if (b.hp.to_f)/b.totalhp>0.75
						score*=1.1
					end          
					if b.effects[PBEffects::LeechSeed]>=0 || b.effects[PBEffects::Attract]>=0 || 
						b.pbHasAnyStatus? || b.effects[PBEffects::Yawn]>0            
						score*=0.3
					end   
					if movecheck
						score*=0.2
					end          
					if b.hasActiveAbility?(:SIMPLE)
						score*=2
					end
					if b.hasActiveAbility?(:CONTRARY)
						score*=0
					end 
				end
			end
		end
     	score = 0 if count == 0
    #---------------------------------------------------------------------------
    when "UserTargetSwapAtkSpAtkStages" # power swap
		stages=0
		stages+=user.stages[:ATTACK]       
		stages+=user.stages[:SPECIAL_ATTACK]
		miniscore = (-10)*stages
		if user.attack > user.spatk
			if user.stages[:ATTACK]!=0
				miniscore*=2
			end
		else
			if user.stages[:SPECIAL_ATTACK]!=0
				miniscore*=2
			end
		end
		stages=0
		stages+=target.stages[:ATTACK]       
		stages+=target.stages[:SPECIAL_ATTACK]
		minimini = (10)*stages
		if target.attack > target.spatk
			if target.stages[:ATTACK]!=0
				minimini*=2
			end
		else
			if target.stages[:SPECIAL_ATTACK]!=0
				minimini*=2
			end
		end
		if miniscore==0 && minimini==0
			score*=0
		else
			miniscore+=minimini
			miniscore+=100
			miniscore/=100.0
			score*=miniscore
			doubleTarget = !user.allAllies.empty?
			if doubleTarget
				score*=0.8
			end
		end
    #---------------------------------------------------------------------------
    when "UserTargetSwapDefSpDefStages" # guard swap
		stages=0
		stages+=user.stages[:DEFENSE]       
		stages+=user.stages[:SPECIAL_DEFENSE]
		miniscore = (-10)*stages
		if user.defense > user.spdef
			if user.stages[:DEFENSE]!=0
				miniscore*=2
			end
		else
			if user.stages[:SPECIAL_DEFENSE]!=0
				miniscore*=2
			end
		end
		stages=0
		stages+=target.stages[:DEFENSE]       
		stages+=target.stages[:SPECIAL_DEFENSE]
		minimini = (10)*stages
		if target.defense > target.spdef
			if target.stages[:DEFENSE]!=0
				minimini*=2
			end
		else
			if target.stages[:SPECIAL_DEFENSE]!=0
				minimini*=2
			end
		end
		if miniscore==0 && minimini==0
			score*=0
		else
			miniscore+=minimini
			miniscore+=100
			miniscore/=100.0
			score*=miniscore
			doubleTarget = !user.allAllies.empty?
			if doubleTarget
				score*=0.8
			end
		end
    #---------------------------------------------------------------------------
    when "UserTargetSwapStatStages" # heart swap
		stages=0
		stages+=user.stages[:ATTACK] unless user.attack<user.spatk
		stages+=user.stages[:DEFENSE] unless target.attack<target.spatk
		stages+=user.stages[:SPEED]
		stages+=user.stages[:SPECIAL_ATTACK] unless user.attack>user.spatk
		stages+=user.stages[:SPECIAL_DEFENSE] unless target.attack>target.spatk
		stages+=user.stages[:EVASION]
		stages+=user.stages[:ACCURACY]
		miniscore = (-10)*stages
		stages=0
		stages+=target.stages[:ATTACK] unless target.attack<target.spatk
		stages+=target.stages[:DEFENSE] unless user.attack<user.spatk
		stages+=target.stages[:SPEED]
		stages+=target.stages[:SPECIAL_ATTACK] unless target.attack>target.spatk
		stages+=target.stages[:SPECIAL_DEFENSE] unless user.attack>user.spatk
		stages+=target.stages[:EVASION]
		stages+=target.stages[:ACCURACY]
		minimini = (10)*stages        
		if !(miniscore==0 && minimini==0)         
			miniscore+=minimini
			miniscore+=100
			miniscore/=100.0
			score*=miniscore
			hasAlly = !target.allAllies.empty?
			if hasAlly
				score*=0.8
			end
		else
			score=0
		end
    #---------------------------------------------------------------------------
    when "UserCopyTargetStatStages" # Psych Up
		stages=0
		stages+=user.stages[:ATTACK] unless user.attack<user.spatk
		stages+=user.stages[:DEFENSE] unless target.attack<target.spatk
		stages+=user.stages[:SPEED]
		stages+=user.stages[:SPECIAL_ATTACK] unless user.attack>user.spatk
		stages+=user.stages[:SPECIAL_DEFENSE] unless target.attack>target.spatk
		stages+=user.stages[:EVASION]
		stages+=user.stages[:ACCURACY]
		miniscore = (-10)*stages
		stages=0
		stages+=target.stages[:ATTACK] unless user.attack<user.spatk
		stages+=target.stages[:DEFENSE] unless target.attack<target.spatk
		stages+=target.stages[:SPEED]
		stages+=target.stages[:SPECIAL_ATTACK] unless user.attack>user.spatk
		stages+=target.stages[:SPECIAL_DEFENSE] unless target.attack>target.spatk
		stages+=target.stages[:EVASION]
		stages+=target.stages[:ACCURACY]
		minimini = (10)*stages       
		if !(miniscore==0 && minimini==0)
			miniscore+=minimini
			miniscore+=100
			miniscore/=100.0
			score*=miniscore
		else
			score=0
		end
    #---------------------------------------------------------------------------
    when "UserStealTargetPositiveStatStages" # Spectral Thief
		if target.effects[PBEffects::Substitute]<=0
			ministat = 0
			GameData::Stat.each_battle do |s|
				next if target.stages[s.id] <= 0
				ministat += target.stages[s.id]
			end
			ministat*=(15)
			ministat*=(-1) if user.hasActiveAbility?(:CONTRARY)
			ministat*=2 if user.hasActiveAbility?(:SIMPLE)
			ministat*=1.3 if $player.difficulty_mode?("chaos")
			ministat+=100
			ministat/=100.0
			score*=ministat
		end
    #---------------------------------------------------------------------------
    when "InvertTargetStatStages" # Topsy-Turvy
		if target.effects[PBEffects::Substitute]<=0
			ministat=0
			ministat+=target.stages[:ATTACK] 
			ministat+=target.stages[:DEFENSE]
			ministat+=target.stages[:SPEED] 
			ministat+=target.stages[:SPECIAL_ATTACK] 
			ministat+=target.stages[:SPECIAL_DEFENSE] 
			ministat+=target.stages[:EVASION]
			ministat*=10
			# if ally,  higher score so it inverts negative stat changes
			# if enemy, higher score so it inverts positive stat changes
			if ministat>0
				ministat = 0   if !user.opposes?(target) # ally
				ministat+= 100 if user.opposes?(target) # enemy
			else
				ministat-= 100 if !user.opposes?(target) # ally
				ministat = 0   if user.opposes?(target) # enemy
			end
			ministat*=1.2 if $player.difficulty_mode?("chaos")
			ministat/=100.0
			score*=ministat
		else
			score = 0 if move.baseDamage ==0
		end
    #---------------------------------------------------------------------------
    when "ResetTargetStatStages" # clear smog
		if target.effects[PBEffects::Substitute]<=0
			miniscore=0
			miniscore+= 5*target.stages[:ATTACK] if target.stages[:ATTACK]>0
			miniscore+= 5*target.stages[:DEFENSE] if target.stages[:DEFENSE]>0
			miniscore+= 5*target.stages[:SPECIAL_ATTACK] if target.stages[:SPECIAL_ATTACK]>0
			miniscore+= 5*target.stages[:SPECIAL_DEFENSE] if target.stages[:SPECIAL_DEFENSE]>0
			miniscore+= 5*target.stages[:SPEED] if target.stages[:SPEED]>0
			miniscore+= 5*target.stages[:EVASION] if target.stages[:EVASION]>0
			minimini=0
			minimini+= 5*target.stages[:ATTACK] if target.stages[:ATTACK]<0
			minimini+= 5*target.stages[:DEFENSE] if target.stages[:DEFENSE]<0
			minimini+= 5*target.stages[:SPECIAL_ATTACK] if target.stages[:SPECIAL_ATTACK]<0
			minimini+= 5*target.stages[:SPECIAL_DEFENSE] if target.stages[:SPECIAL_DEFENSE]<0
			minimini+= 5*target.stages[:SPEED] if target.stages[:SPEED]<0
			minimini+= 5*target.stages[:ACCURACY] if target.stages[:ACCURACY]<0
			miniscore+=minimini
			miniscore+=100
			miniscore/=100.0
			score*=miniscore
			score*=1.1 if target.hasActiveAbility?([:SPEEDBOOST, :MOODY])
		end
    #---------------------------------------------------------------------------
    when "ResetAllBattlersStatStages" # haze
		miniscore = minimini = 0
		@battle.allBattlers.each do |b|
			if b.opposes?(user)
				stages=0
				GameData::Stat.each_battle do |s|
					stages+=b.stages[s.id]
				end
				minimini+= (10)*stages
			else
				stages=0
				GameData::Stat.each_battle do |s|
					stages+=b.stages[s.id]
				end
				minimini+= (-10)*stages
			end
		end
		if (miniscore==0 && minimini==0)
			if move.baseDamage <= 0
				score*=0
			end
		else
			miniscore+=minimini
			miniscore+=100
			miniscore/=100.0
			score*=miniscore
		end
		movecheck = false
		@battle.allBattlers.each do |b|
			if pbHasSetupMove?(b) && b.opposes?(user)
				movecheck = true
				break
			end
		end
		score*=0.8 if target.hasActiveAbility?([:SPEEDBOOST, :MOODY]) || movecheck
    #---------------------------------------------------------------------------
    when "StartUserSideImmunityToStatStageLowering" # mist
		minimini = 1
		if user.pbOwnSide.effects[PBEffects::Mist]==0 && !user.pbOwnSide.effects[PBEffects::StatDropImmunity]
			minimini*=1.1
			# check target for stat decreasing moves
			minimini*=1.3 if pbHasDebuffMove?(target)
		end
		score*=minimini
    #---------------------------------------------------------------------------
    when "UserSwapBaseAtkDef" # power trick
		if user.attack - user.defense >= 100
			if aspeed>ospeed || !userFasterThanTarget
				score*=1.5
			end
			if pbRoughStat(target,:ATTACK,skill)>pbRoughStat(target,:SPECIAL_ATTACK,skill)
				score*=2
			end
			score*=2 if user.moves.any? { |m| m&.healingMove? }
		elsif user.defense - user.attack >= 100
			if aspeed>ospeed || !userFasterThanTarget
				score*=1.5
				if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && !user.takesHailDamage? && !user.takesSandstormDamage?)
					score*=2
				end
			else
				score*=0
			end
		else
			score*=0.1
		end
		score=0 if user.effects[PBEffects::PowerTrick]
    #---------------------------------------------------------------------------
    when "UserTargetSwapBaseSpeed" # speed swap
		if !userFasterThanTarget
			miniscore= (10)*target.stages[:SPEED]
			minimini= (-10)*user.stages[:SPEED]
			if miniscore==0 && minimini==0
				score*=0
			else
				miniscore+=minimini
				miniscore+=100
				miniscore/=100.0
				score*=miniscore
				hasAlly = !target.allAllies.empty?
				if hasAlly
					score*=0.8
				end
			end
		else
			score*=0
		end
    #---------------------------------------------------------------------------
    when "UserTargetAverageBaseAtkSpAtk" # Power Split
		if pbRoughStat(target,:ATTACK,skill) > pbRoughStat(target,:SPECIAL_ATTACK,skill)
			if user.attack > pbRoughStat(target,:ATTACK,skill)
				score*=0
			else
				miniscore = pbRoughStat(target,:ATTACK,skill) - user.attack
				miniscore+=100
				miniscore/=100.0
				if user.attack>user.spatk
					miniscore*=2
				else
					miniscore*=0.5
				end
				score*=miniscore
			end
		else
			if user.spatk > pbRoughStat(target,:SPECIAL_ATTACK,skill)
				score*=0
			else
				miniscore = pbRoughStat(target,:SPECIAL_ATTACK,skill) - user.spatk
				miniscore+=100
				miniscore/=100.0
				if user.attack<user.spatk
					miniscore*=2
				else
					miniscore*=0.5
				end
				score*=miniscore
			end
		end
    #---------------------------------------------------------------------------
    when "UserTargetAverageBaseDefSpDef" # Guard Split
		if pbRoughStat(target,:ATTACK,skill) > pbRoughStat(target,:SPECIAL_ATTACK,skill)
			if user.defense > pbRoughStat(target,:DEFENSE,skill)
				score*=0
			else
				miniscore = pbRoughStat(target,:DEFENSE,skill) - user.defense
				miniscore+=100
				miniscore/=100.0
				if user.attack>user.spatk
					miniscore*=2
				else
					miniscore*=0.5
				end
				score*=miniscore
			end
		else
			if user.spdef > pbRoughStat(target,:SPECIAL_DEFENSE,skill)
				score*=0
			else
				miniscore = pbRoughStat(target,:SPECIAL_DEFENSE,skill) - user.spdef
				miniscore+=100
				miniscore/=100.0
				if user.attack<user.spatk
					miniscore*=2
				else
					miniscore*=0.5
				end
				score*=miniscore
			end
		end
    #---------------------------------------------------------------------------
    when "UserTargetAverageHP" # pain split
		if target.effects[PBEffects::Substitute] > 0
			score = 0
		else
			ministat = target.hp + (user.hp/2.0)
			bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
			maxdam = bestmove[0]
			if maxdam>ministat
				score*=0
			elsif maxdam>user.hp
				if userFasterThanTarget
					score*=2
				else
					score*=0
				end 
			else
				miniscore=(target.hp/(user.hp).to_f)
				score*=miniscore
			end
			score = 0 if user.hp==user.totalhp && userFasterThanTarget
		end
    #---------------------------------------------------------------------------
    when "StartUserSideDoubleSpeed" # Tailwind
		if user.pbOwnSide.effects[PBEffects::Tailwind]>0
			score = 0
		else 
			roles = pbGetPokemonRole(user, target)
			score*=1.5
			if userFasterThanTarget && !roles.include?("Lead")
				score*=0.9
				if @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
					score*=0.4
				end          
			end
			if target.hasActiveAbility?(:SPEEDBOOST)
				score*=0.5
			end
			if @battle.field.effects[PBEffects::TrickRoom]!=0
				miniscore*=0.1
			else
				miniscore*=0.1 if target.moves.any? { |j| j&.id == :TRICKROOM }
			end
			if roles.include?("Lead")
				score*=1.4
			end
		end
    #---------------------------------------------------------------------------
    when "StartSwapAllBattlersBaseDefensiveStats" # wonder room
		if @battle.field.effects[PBEffects::WonderRoom]!=0
			score=0
		else
			if user.hasActiveAbility?(:TRICKSTER)
				score*=1.3
			end
			if pbRoughStat(target,:ATTACK,skill)>pbRoughStat(target,:SPECIAL_ATTACK,skill)
				if user.defense>user.spdef
					score*=0.5
				else
					score*=2
				end
			else
				if user.defense<user.spdef
					score*=0.5
				else
					score*=2
				end
			end
			if user.attack>user.spatk
				if pbRoughStat(target,:DEFENSE,skill)>pbRoughStat(target,:SPECIAL_DEFENSE,skill)
					score*=2
				else
					score*=0.5
				end
			else
				if pbRoughStat(target,:DEFENSE,skill)<pbRoughStat(target,:SPECIAL_DEFENSE,skill)
					score*=2
				else
					score*=0.5
				end
			end
		end
    #---------------------------------------------------------------------------
    when "RaiseUserAttack2IfTargetFaints", "RaiseUserAttack3IfTargetFaints" # Fell Stinger
		if !user.statStageAtMax?(:ATTACK)
			if !targetSurvivesMove(move,user,target) && 
			   @battle.choices[target.index][0] != :SwitchOut
				if userFasterThanTarget
					score*=30
				else
					bestTargetMove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
					maxdamTarget = bestTargetMove[0]
					if maxdamTarget>user.hp
						score*=0.5
					else
						score*=2.5
						score*=5 if user.moves.any? { |m| priorityAI(target,m)>0 }
					end
				end
			end
		end
    #---------------------------------------------------------------------------
    end
    return score
  end
end
