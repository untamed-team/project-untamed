$aiberrycheck=false
class Battle::AI
	def pbDefaultChooseEnemyCommand(idxBattler)
		#return if pbEnemyShouldUseItem?(idxBattler)
		return if pbEnemyShouldWithdraw?(idxBattler)
		return if @battle.pbAutoFightMenu(idxBattler)
		@battle.pbRegisterMegaEvolution(idxBattler) if pbEnemyShouldMegaEvolve?(idxBattler)
		if PluginManager.installed?("ZUD Mechanics")
			@battle.pbRegisterUltraBurst(idxBattler) if pbEnemyShouldUltraBurst?(idxBattler)
			@battle.pbRegisterDynamax(idxBattler) if pbEnemyShouldDynamax?(idxBattler)
		end
		if PluginManager.installed?("Terastal Phenomenon")
			@battle.pbRegisterTerastallize(idxBattler) if pbEnemyShouldTerastallize?(idxBattler)
		end
		if PluginManager.installed?("Pokémon Birthsigns")
			@battle.pbRegisterZodiacPower(idxBattler) if pbEnemyShouldZodiacPower?(idxBattler)
		end
		if PluginManager.installed?("Focus Meter System")
			@battle.pbRegisterFocus(idxBattler) if pbEnemyShouldFocus?(idxBattler)
		end
		if PluginManager.installed?("Essentials Deluxe")
			if !@battle.pbScriptedMechanic?(idxBattler, :custom) && pbEnemyShouldCustom?(idxBattler)
				@battle.pbRegisterCustom(idxBattler)
			end
		end	
		pbChooseMoves(idxBattler)
	end
	
	
	def pbRoughDamage(move, user, target, skill, baseDmg=0)
		baseDmg = pbMoveBaseDamage(move, user, target, skill)
		# Fixed damage moves
		return baseDmg if move.is_a?(Battle::Move::FixedDamageMove)
		# Get the move's type
		type = pbRoughType(move, user, skill)
		typeMod = pbCalcTypeMod(type,user,target)
		##### Calculate user's attack stat #####
		atk = pbRoughStat(user, :ATTACK, skill)
		if move.function == "UseTargetAttackInsteadOfUserAttack"   # Foul Play
			atk = pbRoughStat(target, :ATTACK, skill)
		elsif move.function == "UseUserBaseDefenseInsteadOfUserBaseAttack"   # Body Press
			atk = pbRoughStat(user, :DEFENSE, skill)
    elsif move.function == "UseUserBaseSpecialDefenseInsteadOfUserBaseSpecialAttack"   # Psycrush
      atk = pbRoughStat(user, :SPECIAL_DEFENSE, skill)
		elsif move.specialMove?(type)
			if move.function == "UseTargetAttackInsteadOfUserAttack"   # Foul Play
				atk = pbRoughStat(target, :SPECIAL_ATTACK, skill)
			else
				atk = pbRoughStat(user, :SPECIAL_ATTACK, skill)
			end
		end
		##### Calculate target's defense stat #####
		defense = pbRoughStat(target, :DEFENSE, skill)
		if move.specialMove?(type) && move.function != "UseTargetDefenseInsteadOfTargetSpDef"   # Psyshock
			defense = pbRoughStat(target, :SPECIAL_DEFENSE, skill)
		end
		##### Calculate all multiplier effects #####
		multipliers = {
			:base_damage_multiplier  => 1.0,
			:attack_multiplier       => 1.0,
			:defense_multiplier      => 1.0,
			:final_damage_multiplier => 1.0
		}
		# Ability effects that alter damage
		moldBreaker = false
		if skill >= PBTrainerAI.highSkill && target.hasMoldBreaker?
			moldBreaker = true
		end
		if skill >= PBTrainerAI.mediumSkill && user.abilityActive?
			# NOTE: These abilities aren't suitable for checking at the start of the
			#       round.    # DemICE: some of them.
			abilityBlacklist = [:ANALYTIC, :SNIPER]#, :TINTEDLENS, :AERILATE, :PIXILATE, :REFRIGERATE]
			canCheck = true
			abilityBlacklist.each do |m|
				#next if move.id != m # Really? comparing a move id with an ability id? This blacklisting never worked.
				if target.hasActiveAbility?(m)
					canCheck = false
					break
				end
			end
			if canCheck
				Battle::AbilityEffects.triggerDamageCalcFromUser(
					user.ability, user, target, move, multipliers, baseDmg, type
				)
			end
		end
		if skill >= PBTrainerAI.mediumSkill && !moldBreaker
			user.allAllies.each do |b|
				next if !b.abilityActive?
				Battle::AbilityEffects.triggerDamageCalcFromAlly(
					b.ability, user, target, move, multipliers, baseDmg, type
				)
			end
		end
		if skill >= PBTrainerAI.bestSkill && !moldBreaker && target.abilityActive?
			# NOTE: These abilities aren't suitable for checking at the start of the
			#       round.    #DemICE:  WHAT THE FUCK DO YOU MEAN THEY AREN'T SUITABLE FFS
			abilityBlacklist = [:FILTER,:SOLIDROCK]
			canCheck = true
			abilityBlacklist.each do |m|
				#next if move.id != m # Really? comparing a move id with an ability id? This blacklisting never worked.
				if target.hasActiveAbility?(m)
					canCheck = false
					break
				end
			end
			if canCheck
				Battle::AbilityEffects.triggerDamageCalcFromTarget(
					target.ability, user, target, move, multipliers, baseDmg, type
				)
			end
		end
		if skill >= PBTrainerAI.bestSkill && !moldBreaker
			target.allAllies.each do |b|
				next if !b.abilityActive?
				Battle::AbilityEffects.triggerDamageCalcFromTargetAlly(
					b.ability, user, target, move, multipliers, baseDmg, type
				)
			end
		end
		# Item effects that alter damage
		# NOTE: Type-boosting gems aren't suitable for checking at the start of the
		#       round.
		if skill >= PBTrainerAI.mediumSkill && user.itemActive?
			# NOTE: These items aren't suitable for checking at the start of the
			#       round.     #DemICE:  WHAT THE FUCK DO YOU MEAN THEY AREN'T SUITABLE FFS
			itemBlacklist = [:EXPERTBELT]#,:LIFEORB]
			if !itemBlacklist.include?(user.item_id)
				Battle::ItemEffects.triggerDamageCalcFromUser(
					user.item, user, target, move, multipliers, baseDmg, type
				)
				user.effects[PBEffects::GemConsumed] = nil   # Untrigger consuming of Gems
			end
		end
		if skill >= PBTrainerAI.bestSkill &&							# DemICE: I now have high suspicions that the chilan berry thing doesn't work.
			target.itemActive? && target.item && !target.item.is_berry?# && target.item_id!=:CHILANBERRY)
			Battle::ItemEffects.triggerDamageCalcFromTarget(
				target.item, user, target, move, multipliers, baseDmg, type
			)
		end
		# Global abilities
		if skill >= PBTrainerAI.mediumSkill &&
			((@battle.pbCheckGlobalAbility(:DARKAURA) 		&& type == :DARK)  ||
			 (@battle.pbCheckGlobalAbility(:SPOOPERAURA) 	&& type == :GHOST) || # spooper aura #by low
			 (@battle.pbCheckGlobalAbility(:FAIRYAURA) 		&& type == :FAIRY))
			if @battle.pbCheckGlobalAbility(:AURABREAK)
				multipliers[:base_damage_multiplier] *= 2 / 3.0
			else
				multipliers[:base_damage_multiplier] *= 4 / 3.0
			end
		end
		# Parental Bond
		if skill >= PBTrainerAI.mediumSkill && user.hasActiveAbility?(:PARENTALBOND)
			multipliers[:base_damage_multiplier] *= 1.25
		end
		# Me First
		# TODO
		# Helping Hand - n/a
		# Charge
		if skill >= PBTrainerAI.mediumSkill &&
			 user.effects[PBEffects::Charge] > 0 && type == :ELECTRIC
			multipliers[:base_damage_multiplier] *= 2
		end
		# Mud Sport and Water Sport
		if skill >= PBTrainerAI.mediumSkill
			if type == :ELECTRIC
				if @battle.allBattlers.any? { |b| b.effects[PBEffects::MudSport] }
					multipliers[:base_damage_multiplier] /= 3
				end
				if @battle.field.effects[PBEffects::MudSportField] > 0
					multipliers[:base_damage_multiplier] /= 3
				end
			end
			if type == :FIRE
				if @battle.allBattlers.any? { |b| b.effects[PBEffects::WaterSport] }
					multipliers[:base_damage_multiplier] /= 3
				end
				if @battle.field.effects[PBEffects::WaterSportField] > 0
					multipliers[:base_damage_multiplier] /= 3
				end
			end
		end
		# Terrain moves
		if skill >= PBTrainerAI.mediumSkill
			# abilityTerrain #by low
			if $game_variables[MECHANICSVAR] >= 3 # on "low mode"
				t_damage_multiplier = (@battle.field.abilityTerrain) ? 1.15 : 1.3
				t_damage_divider    = (@battle.field.abilityTerrain) ? 1.5 : 2
			else
				t_damage_multiplier = 1.3
				t_damage_divider    = 2
			end
			case @battle.field.terrain
			when :Electric
				multipliers[:base_damage_multiplier] *= t_damage_multiplier if type == :ELECTRIC && user.affectedByTerrain?
			when :Grassy
				multipliers[:base_damage_multiplier] *= t_damage_multiplier if type == :GRASS && user.affectedByTerrain?
			when :Psychic
				multipliers[:base_damage_multiplier] *= t_damage_multiplier if type == :PSYCHIC && user.affectedByTerrain?
			when :Misty
				multipliers[:base_damage_multiplier] /= t_damage_divider 		if type == :DRAGON && target.affectedByTerrain?
			end
			thereselec=false
			theresmisty=false
			theresgrassy=false
			therespsychic=false
			@battle.allBattlers.each do |j|
				thereselec=true if (j.isSpecies?(:BEAKRAFT) && j.item == :BEAKRAFTITE && j.willmega && user.affectedByTerrain?)
				theresmisty=true if (j.isSpecies?(:MILOTIC) && j.item == :MILOTITE && j.willmega && target.affectedByTerrain?)
				theresgrassy=true if (j.isSpecies?(:TREVENANT) && j.item == :TREVENANTITE && j.willmega && user.affectedByTerrain?)
				therespsychic=true if (j.isSpecies?(:BEHEEYEM) && j.item == :BEHEEYEMITE && j.willmega && user.affectedByTerrain?)
			end
			multipliers[:base_damage_multiplier] *= 1.25 if type == :ELECTRIC && thereselec
			multipliers[:base_damage_multiplier] /= 1.5  if type == :DRAGON 	&& theresmisty
			multipliers[:base_damage_multiplier] *= 1.25 if type == :GRASS 		&& theresgrassy
			multipliers[:base_damage_multiplier] *= 1.25 if type == :PSYCHIC 	&& therespsychic
			# Specific Field Effect Boosts
			if theresgrassy && [:EARTHQUAKE, :MAGNITUDE, :BULLDOZE].include?(move.id)
				multipliers[:base_damage_multiplier] /= 2.0
			end
		end
		#mastersex type zones #by low
		multipliers[:base_damage_multiplier] *= 1.5 if @battle.field.typezone != :None && type == @battle.field.typezone
		# DemICE adding resist berries
		if Effectiveness.super_effective?(typeMod)
			if user.hasActiveItem?(:EXPERTBELT)
				multipliers[:final_damage_multiplier]*=1.2
			end
			if target.hasActiveAbility?([:SOLIDROCK, :FILTER]) && !moldBreaker
				multipliers[:final_damage_multiplier]*=0.75
			end
			if target.itemActive?
				case target.item_id
				when :BABIRIBERRY
					multipliers[:final_damage_multiplier]*=0.5 if type==:STEEL
				when :SHUCABERRY
					multipliers[:final_damage_multiplier]*=0.5 if type==:GROUND
				when :CHARTIBERRY
					multipliers[:final_damage_multiplier]*=0.5 if type==:ROCK
				when :CHOPLEBERRY
					multipliers[:final_damage_multiplier]*=0.5 if type==:FIGHTING
				when :COBABERRY
					multipliers[:final_damage_multiplier]*=0.5 if type==:FLYING
				when :COLBURBERRY
					multipliers[:final_damage_multiplier]*=0.5 if type==:DARK
				when :HABANBERRY
					multipliers[:final_damage_multiplier]*=0.5 if type==:DRAGON
				when :KASIBBERRY
					multipliers[:final_damage_multiplier]*=0.5 if type==:GHOST
				when :KEBIABERRY
					multipliers[:final_damage_multiplier]*=0.5 if type==:POISON
				when :OCCABERRY
					multipliers[:final_damage_multiplier]*=0.5 if type==:FIRE
				when :PASSHOBERRY
					multipliers[:final_damage_multiplier]*=0.5 if type==:WATER
				when :PAYAPABERRY
					multipliers[:final_damage_multiplier]*=0.5 if type==:PSYCHIC
				when :RINDOBERRY
					multipliers[:final_damage_multiplier]*=0.5 if type==:GRASS
				when :ROSELIBERRY
					multipliers[:final_damage_multiplier]*=0.5 if type==:FAIRY
				when :TANGABERRY
					multipliers[:final_damage_multiplier]*=0.5 if type==:BUG
				when :WACANBERRY
					multipliers[:final_damage_multiplier]*=0.5 if type==:ELECTRIC
				when :YACHEBERRY
					multipliers[:final_damage_multiplier]*=0.5 if type==:ICE
				end
			end
		end
		# Multi-targeting attacks
		if skill >= PBTrainerAI.highSkill && pbTargetsMultiple?(move, user)
			multipliers[:final_damage_multiplier] *= 0.75
		end
		# Weather
		if skill >= PBTrainerAI.mediumSkill
			# abilityWeather #by low
			if $game_variables[MECHANICSVAR] >= 3 # on "low mode"
				w_damage_multiplier = (@battle.field.abilityWeather) ? 1.25 : 1.5
				w_damage_divider    = (@battle.field.abilityWeather) ? 1.5 : 2
			else
				w_damage_multiplier = 1.5
				w_damage_divider    = 2
			end
			case user.effectiveWeather
			when :Sun, :HarshSun
				case type
				when :FIRE
					multipliers[:final_damage_multiplier] *= w_damage_multiplier
				when :WATER
					multipliers[:final_damage_multiplier] /= w_damage_divider
				end
			when :Rain, :HeavyRain
				case type
				when :FIRE
					multipliers[:final_damage_multiplier] /= w_damage_divider
				when :WATER
					multipliers[:final_damage_multiplier] *= w_damage_multiplier
				end
			when :Sandstorm
				if target.pbHasType?(:ROCK) && move.specialMove?(type) &&
					move.function != "UseTargetDefenseInsteadOfTargetSpDef"   # Psyshock
					multipliers[:defense_multiplier] *= 1.5
				end
			when :Hail # hail buff #by low
				if target.pbHasType?(:ICE, true) && Effectiveness.super_effective?(target.damageState.typeMod)
					multipliers[:final_damage_multiplier] *= 0.75
				end
			end
			# specific weather checks #by low
			theressun=false
			thereswet=false
			theressad=false
			thereshal=false
			@battle.allBattlers.each do |j|
				theressun=true if (j.isSpecies?(:ZARCOIL)  && j.item == :ZARCOILITE  && j.willmega)
				thereswet=true if (j.isSpecies?(:ZOLUPINE) && j.item == :ZOLUPINEITE && j.willmega)
				theressad=true if (j.isSpecies?(:CACTURNE) && j.item == :CACTURNITE  && j.willmega)
				thereshal=true if (j.isSpecies?(:FRIZZARD) && j.item == :FRIZZARDITE && j.willmega)
			end
			if theressun # sunny day
        case type
        when :FIRE
          multipliers[:final_damage_multiplier] *= 1.25
        when :WATER
          multipliers[:final_damage_multiplier] /= 1.5
        end
				if move.specialMove?(type) && user.hasActiveAbility?(:SOLARPOWER)
					multipliers[:attack_multiplier] *= 1.5
				end
			end
			if thereswet # rain dance
        case type
        when :FIRE
          multipliers[:final_damage_multiplier] /= 1.5
        when :WATER
          multipliers[:final_damage_multiplier] *= 1.25
        end
			end
			if theressad # sandstorm
        if target.pbHasType?(:ROCK, true) && move.specialMove?(type) &&
           move.function != "UseTargetDefenseInsteadOfTargetSpDef"   # Psyshock
          multipliers[:defense_multiplier] *= 1.5
        end
			end
			if thereshal # hail
				if target.pbHasType?(:ICE, true) && Effectiveness.super_effective?(target.damageState.typeMod)
					multipliers[:final_damage_multiplier] *= 0.75
				end
			end
		end
		# Master Mode stuff #by low
		if $game_variables[MASTERMODEVARS][28]==true && !target.pbOwnedByPlayer? && Effectiveness.super_effective?(target.damageState.typeMod)
			multipliers[:final_damage_multiplier] *= 0.75
		end
		# Gravity Boost #by low 
		if move.boostedByGravity? && @battle.field.effects[PBEffects::Gravity] > 0
			multipliers[:base_damage_multiplier] *= 4 / 3.0
		end
		# Critical hits - n/a
		# Random variance - n/a
		#~ if $Trainer.difficulty_mode==2
			#~ if user.pbOwnedByPlayer? # Changed by DemICE 27-Sep-2023 Unfair difficulty
				#~ multipliers[:final_damage_multiplier] *= 1 - target.level/500.00 
			#~ else
				#~ multipliers[:final_damage_multiplier] *= 1 + user.level/300.00 
			#~ end
		#~ end
		# STAB
		if skill >= PBTrainerAI.mediumSkill && type && user.pbHasType?(type)
			if user.hasActiveAbility?(:ADAPTABILITY)
				multipliers[:final_damage_multiplier] *= 2
			else
				multipliers[:final_damage_multiplier] *= 1.5
			end
		end
		# Type effectiveness
		if skill >= PBTrainerAI.mediumSkill
			typemod = pbCalcTypeMod(type, user, target)
			multipliers[:final_damage_multiplier] *= typemod.to_f / Effectiveness::NORMAL_EFFECTIVE
		end
		damagenerf = (1 / 2.0)
		damagenerf = (2 / 3.0) if $game_variables[MECHANICSVAR] >= 3 #by low
		# Burn
		if skill >= PBTrainerAI.highSkill && move.physicalMove?(type) &&
			user.status == :BURN && !user.hasActiveAbility?(:GUTS) &&
			!(Settings::MECHANICS_GENERATION >= 6 &&
				move.function == "DoublePowerIfUserPoisonedBurnedParalyzed")   # Facade
			multipliers[:final_damage_multiplier] *= damagenerf
		end
    # Frostbite #by low
    if user.status == :FREEZE && move.specialMove?(type) && skill >= PBTrainerAI.highSkill
      multipliers[:final_damage_multiplier] *= damagenerf
    end
		# Aurora Veil, Reflect, Light Screen
		if skill >= PBTrainerAI.highSkill && !move.ignoresReflect? && !user.hasActiveAbility?(:INFILTRATOR)
			if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
				if @battle.pbSideBattlerCount(target) > 1
					multipliers[:final_damage_multiplier] *= 1.5 / 3.0
				else
					multipliers[:final_damage_multiplier] /= 1.5
				end
			elsif target.pbOwnSide.effects[PBEffects::Reflect] > 0 && move.physicalMove?(type)
				if @battle.pbSideBattlerCount(target) > 1
					multipliers[:final_damage_multiplier] *= 2 / 3.0
				else
					multipliers[:final_damage_multiplier] /= 2
				end
			elsif target.pbOwnSide.effects[PBEffects::LightScreen] > 0 && move.specialMove?(type)
				if @battle.pbSideBattlerCount(target) > 1
					multipliers[:final_damage_multiplier] *= 2 / 3.0
				else
					multipliers[:final_damage_multiplier] /= 2
				end
			end
		end
		# Minimize
		if skill >= PBTrainerAI.highSkill && target.effects[PBEffects::Minimize] && move.tramplesMinimize?
			multipliers[:final_damage_multiplier] *= 2
		end
		# Move-specific base damage modifiers
		# TODO
		# Move-specific final damage modifiers
		# TODO
		##### Main damage calculation #####
		baseDmg = [(baseDmg * multipliers[:base_damage_multiplier]).round, 1].max
		atk     = [(atk     * multipliers[:attack_multiplier]).round, 1].max
		defense = [(defense * multipliers[:defense_multiplier]).round, 1].max
		damage  = ((((2.0 * user.level / 5) + 2).floor * baseDmg * atk / defense).floor / 50).floor + 2
		damage  = [(damage * multipliers[:final_damage_multiplier]).round, 1].max
		# "AI-specific calculations below"
		# Increased critical hit rates
		if skill >= PBTrainerAI.mediumSkill
			c = 0
			# Ability effects that alter critical hit rate
			if c >= 0 && user.abilityActive?
				c = Battle::AbilityEffects.triggerCriticalCalcFromUser(user.ability, user, target, c)
			end
			if skill >= PBTrainerAI.bestSkill && c >= 0 && !moldBreaker && target.abilityActive?
				c = Battle::AbilityEffects.triggerCriticalCalcFromTarget(target.ability, user, target, c)
			end
			# Item effects that alter critical hit rate
			if c >= 0 && user.itemActive?
				c = Battle::ItemEffects.triggerCriticalCalcFromUser(user.item, user, target, c)
			end
			if skill >= PBTrainerAI.bestSkill && c >= 0 && target.itemActive?
				c = Battle::ItemEffects.triggerCriticalCalcFromTarget(target.item, user, target, c)
			end
			# Other efffects
			c = -1 if target.pbOwnSide.effects[PBEffects::LuckyChant] > 0
			if c >= 0
				c += 1 if move.highCriticalRate?
				c += user.effects[PBEffects::FocusEnergy]
				c += 1 if user.inHyperMode? && move.type == :SHADOW
			end
			# DemICE: taking into account 100% crit rate.
			stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
			stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
			vatk, atkStage = move.pbGetAttackStats(user,target)
			vdef, defStage = move.pbGetDefenseStats(user,target)
			atkmult = 1.0*stageMul[atkStage]/stageDiv[atkStage]
			defmult = 1.0*stageMul[defStage]/stageDiv[defStage]
			if c==3 && 
				 !target.hasActiveAbility?(:SHELLARMOR) && !target.hasActiveAbility?(:BATTLEARMOR) && 
				 target.pbOwnSide.effects[PBEffects::LuckyChant]==0
				damage = 0.96*damage/atkmult if atkmult<1
				damage = damage*defmult if defmult>1
			end	
			if c >= 0
				c = 4 if c > 4
				if c>=3
					damage*=1.5
					damage*=1.5 if user.hasActiveAbility?(:SNIPER)
				else
					damage += damage*0.1*c
				end	
			end
		end
		return damage.floor
	end
	
	def moldbroken(attacker,opponent,move=:SPLASH)
		if (attacker.hasActiveAbility?(:MOLDBREAKER) || 
				attacker.hasActiveAbility?(:TURBOBLAZE) || 
				attacker.hasActiveAbility?(:TERAVOLT) ||
				move.function=="IgnoreTargetAbility") && 
				!opponent.hasActiveAbility?(:SHADOWSHIELD) #!opponent.hasActiveAbility?(:FULLMETALBODY) && 
			return true
		end
		return false	
	end
	
	alias stupidity_pbCheckMoveImmunity pbCheckMoveImmunity
	def pbCheckMoveImmunity(score, move, user, target, skill)
		# Changed by DemICE 08-Sep-2023 Yes i had to move Last Resort here to make its score return 0 otherwise it just never became 0.
		if move.function == "FailsIfUserHasUnusedMove" 
			hasThisMove = false
			hasOtherMoves = false
			hasUnusedMoves = false
			user.eachMove do |m|
				hasThisMove    = true if m.id == @id
				hasOtherMoves  = true if m.id != @id
				hasUnusedMoves = true if m.id != @id && !user.movesUsed.include?(m.id)
			end
			if !hasThisMove || !hasOtherMoves || hasUnusedMoves
				return true
			end 
		end  
		# DemICE: Mold Breaker implementation
		type = pbRoughType(move,user,skill)
		typeMod = pbCalcTypeMod(type,user,target)
		mold_broken=moldbroken(user,target,move)
		therespsy=false
		thereselec=false
		@battle.allBattlers.each do |j|
			if (j.isSpecies?(:BEHEEYEM) && j.item == :BEHEEYEMITE && j.willmega && target.affectedByTerrain?)
				therespsy=true
			end
			if (j.isSpecies?(:BEAKRAFT) && j.item == :BEAKRAFTITE && j.willmega && target.affectedByTerrain?)
				thereselec=true
			end
		end
		case type
		when :GROUND
			if (target.airborneAI(mold_broken) && !move.hitsFlyingTargets?)
				return true 
			end
		when :FIRE
			return true if target.hasActiveAbility?(:FLASHFIRE,false,mold_broken)
		when :WATER
			return true if target.hasActiveAbility?([:DRYSKIN,:STORMDRAIN,:WATERABSORB],false,mold_broken)
		when :GRASS
			return true if target.hasActiveAbility?(:SAPSIPPER,false,mold_broken)
		when :ELECTRIC
			return true if target.hasActiveAbility?([:LIGHTNINGROD,:MOTORDRIVE,:VOLTABSORB],false,mold_broken)
		end
		return true if !Effectiveness.super_effective?(typeMod) && move.baseDamage>0 && 
										target.hasActiveAbility?(:WONDERGUARD,false,mold_broken)
		return true if move.canMagicCoat? && target.hasActiveAbility?(:MAGICBOUNCE,false,mold_broken) &&
										target.opposes?(user)
		return true if move.soundMove? && (target.hasActiveAbility?(:SOUNDPROOF,false,mold_broken) || 
																			(target.isSpecies?(:CHIMECHO) && target.willmega && !mold_broken))
		return true if move.bombMove? && target.hasActiveAbility?(:BULLETPROOF,false,mold_broken)
		return true if [:HYPNOSIS, :GRASSWHISTLE, :LOVELYKISS, :SING, :DARKVOID].include?(move.id) && thereselec
		if move.powderMove?
			return true if target.pbHasType?(:GRASS)
			return true if target.hasActiveAbility?(:OVERCOAT,false,mold_broken)
			return true if target.hasActiveItem?(:SAFETYGOGGLES)
		end
		if priorityAI(user,move) > 0
			@battle.allSameSideBattlers(target.index).each do |b|
				return true if b.hasActiveAbility?([:DAZZLING, :QUEENLYMAJESTY],false,mold_broken) 
			end
			return true if (@battle.field.terrain == :Psychic || therespsy) && target.affectedByTerrain? && target.opposes?(user)
		end
		return stupidity_pbCheckMoveImmunity(score, move, user, target, skill)
		#return result   
	end	
	
	#=============================================================================
	# Get a better move's base damage value
	#=============================================================================
	alias stupidity_pbMoveBaseDamage pbMoveBaseDamage
	def pbMoveBaseDamage(move,user,target,skill)
		baseDmg = move.baseDamage
		case move.function
		when "HitOncePerUserTeamMember"   # DemICE beat up was being calculated very wrong.
			beatUpList = []
			@battle.eachInTeamFromBattlerIndex(user.index) do |pkmn,i|
				next if !pkmn.able? || pkmn.status != :NONE
				beatUpList.push(i)
			end
			baseDmg=0
			for i in beatUpList
				atk = @battle.pbParty(user.index)[i].baseStats[:ATTACK]
				baseDmg+= 5+(atk/10)
			end
		else
			baseDmg = stupidity_pbMoveBaseDamage(move,user,target,skill)
		end
		return baseDmg
	end
	
  def targetSurvivesMove(move,attacker,opponent,priodamage=0,mult=1)
		return true if !move
		mold_broken=moldbroken(attacker,opponent,move)
		damage = pbRoughDamage(move,attacker,opponent,100, move.baseDamage)
		damage+=priodamage
		damage*=mult
		if move.name=="Meteor Beam"
			Console.echo_h2("DOES HE LIVE") 
			Console.echo_h2(move.name) 
			Console.echo_h2(damage)
			Console.echo_h2(opponent.hp)
		end
		if !mold_broken && opponent.hasActiveAbility?(:DISGUISE) && opponent.turnCount==0	
			if ["HitTwoToFiveTimes", "HitTwoTimes", "HitThreeTimes",
					"HitTwoTimesFlinchTarget", "HitThreeTimesPowersUpWithEachHit", 
					"HitThreeToFiveTimes"].include?(move.function)
				damage*=0.6
			else
				damage=1
			end
		end			
		return true if damage < opponent.hp
		return false if priodamage>0
		if (opponent.hasActiveItem?(:FOCUSSASH) || (!mold_broken && opponent.hasActiveAbility?(:STURDY))) && opponent.hp==opponent.totalhp
			return false if ["HitTwoToFiveTimes", "HitTwoTimes", "HitThreeTimes" ,"HitTwoTimesFlinchTarget", "HitThreeTimesPowersUpWithEachHit", "HitTenTimesPopulationBomb"].include?(move.function)
			return true
		end	
		return false
	end

	def canSleepTarget(attacker,opponent,berry=false)
		return false if opponent.effects[PBEffects::Substitute]>0
		return false if berry && (opponent.status==:SLEEP)# && opponent.statusCount>1)
		return false if (opponent.hasActiveItem?(:LUMBERRY) || opponent.hasActiveItem?(:CHESTOBERRY)) && berry
		return false if opponent.pbCanSleep?(attacker,false)
		return false if opponent.pbOwnSide.effects[PBEffects::Safeguard] > 0 && !attacker.hasActiveAbility?(:INFILTRATOR)
		for move in attacker.moves
			if ["SleepTarget", "SleepTargetIfUserDarkrai", "SleepTargetNextTurn"].include?(move.function)
				return false if move.powderMove? && opponent.pbHasType?(:GRASS)
				return true	
			end	
		end	
		return false
	end
	
	def bestMoveVsTarget(user,target,skill)
		maxdam=0
		maxmove=nil
		maxprio=0
		physorspec="none"
		for j in user.moves
			if user.effects[PBEffects::ChoiceBand] &&
				user.hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF])
				if user.lastMoveUsed && user.pbHasMove?(user.lastMoveUsed)
					next if j.id!=user.lastMoveUsed
				end
			end		
			tempdam = pbRoughDamage(j,user,target,skill,j.baseDamage)
			tempdam = 0 if pbCheckMoveImmunity(1,j,user,target,100)
			if tempdam>maxdam
				maxdam=tempdam 
				maxmove=j
				physorspec="physical" if j.physicalMove?(j.type)
				physorspec="special" if j.specialMove?(j.type)
			end	
			if priorityAI(user,j)>0
				maxprio=tempdam if tempdam>maxprio
			end	
		end 
		return [maxdam,maxmove,maxprio,physorspec]
	end	

	def checkWeatherBenefit(user)
		sum=0
		ownparty = @battle.pbParty(user.index)
		ownparty.each_with_index do |pkmn, idxParty|
			next if !pkmn || !pkmn.able?
			if @battle.pbWeather==:Sun
				sum+=20 if pkmn.ability == :CHLOROPHYLL
				sum+=10 if pkmn.ability == :FLOWERGIFT || pkmn.ability == :SOLARPOWER
				pkmn.eachMove do |m|
					next if m.base_damage==0 || m.type != :FIRE
					sum += 10
				end   
				pkmn.eachMove do |m|
					next if m.base_damage==0 || m.type != :WATER
					sum -= 5
				end   
				sum+=5 if pkmn.pbHasMoveFunction?("HealUserDependingOnWeather", "RaiseUserAtkSpAtk1Or2InSun")
				sum+=5 if pkmn.pbHasMoveFunction?("TwoTurnAttackOneTurnInSun") 
			end
			if @battle.pbWeather==:Rain
				sum+=20 if pkmn.ability == :SWIFTSWIM
				sum+=5 if pkmn.ability == :RAINDISH || pkmn.ability == :DRYSKIN || pkmn.ability == :HYDRATION
				pkmn.eachMove do |m|
					next if m.base_damage==0 || m.type != :WATER
					sum += 10
				end   
				pkmn.eachMove do |m|
					next if m.base_damage==0 || m.type != :FIRE
					sum -= 5
				end   
				sum-=5 if pkmn.pbHasMoveFunction?("HealUserDependingOnWeather", "RaiseUserAtkSpAtk1Or2InSun", "TwoTurnAttackOneTurnInSun") && @battle.field.weather == :Sun
				sum+=5 if pkmn.pbHasMoveFunction?("ParalyzeTargetAlwaysHitsInRainHitsTargetInSky") 
			end
			if @battle.pbWeather==:Sandstorm
				sum+=20 if pkmn.ability == :SANDRUSH
				sum+=10 if pkmn.ability == :SANDVEIL || pkmn.ability == :SANDFORCE
				sum+=10 if pkmn.hasType?(:ROCK)
				sum-=5 if pkmn.pbHasMoveFunction?("HealUserDependingOnWeather", "RaiseUserAtkSpAtk1Or2InSun", "TwoTurnAttackOneTurnInSun") && @battle.field.weather == :Sun
				sum+=5 if pkmn.pbHasMoveFunction?("HealUserDependingOnSandstorm") 
			end
			if @battle.pbWeather==:Hail
				sum+=20 if pkmn.ability == :SLUSHRUSH
				sum+=10 if pkmn.ability == :SNOWCLOAK || pkmn.ability == :ICEBODY
				sum-=5 if pkmn.pbHasMoveFunction?("HealUserDependingOnWeather", "RaiseUserAtkSpAtk1Or2InSun", "TwoTurnAttackOneTurnInSun") && @battle.field.weather == :Sun
				sum+=5 if pkmn.pbHasMoveFunction?("FreezeTargetAlwaysHitsInHail") 
				sum+=5 if pkmn.pbHasMoveFunction?("StartWeakenDamageAgainstUserSideIfHail") 
			end
			if @battle.field.terrain==:Electric
				sum+=5 if pkmn.item == :ELECTRICSEED
				sum+=10 if pkmn.ability == :SURGESURFER
				pkmn.eachMove do |m|
					next if m.base_damage==0 || m.type != :ELECTRIC
					sum += 5
				end   
				sum+=5 if pkmn.pbHasMoveFunction?("TypeAndPowerDependOnTerrain", "BPRaiseWhileElectricTerrain")
				sum+=5 if pkmn.pbHasMoveFunction?("DoublePowerInElectricTerrain") 
			end
			if @battle.field.terrain==:Grassy
				sum+=5 if pkmn.item == :GRASSYSEED
				sum+=5 if pkmn.ability == :GRASSPELT
				pkmn.eachMove do |m|
					next if m.base_damage==0 || m.type != :GRASS
					sum += 5
				end   
				score-=5 if pkmn.pbHasMoveFunction?("DoublePowerIfTargetUnderground", "RandomPowerDoublePowerIfTargetUnderground",
					"LowerTargetSpeed1WeakerInGrassyTerrain")
				sum+=5 if pkmn.pbHasMoveFunction?("TypeAndPowerDependOnTerrain", "HealTargetDependingOnGrassyTerrain")
				sum+=5 if pkmn.pbHasMoveFunction?("HigherPriorityInGrassyTerrain") 
			end
			if @battle.field.terrain==:Misty
				sum+=5 if pkmn.item == :MISTYSEED
				pkmn.eachMove do |m|
					next if m.base_damage==0 || m.type != :DRAGON
					sum -= 5
				end   
				score-=5 if pkmn.pbHasMoveFunction?("SleepTarget", "SleepTargetIfUserDarkrai", "SleepTargetChangeUserMeloettaForm", 
					"ParalyzeTargetIfNotTypeImmune", "BadPoisonTarget")
				sum+=5 if pkmn.pbHasMoveFunction?("TypeAndPowerDependOnTerrain", "UserFaintsPowersUpInMistyTerrainExplosive")
			end
			if @battle.field.terrain==:Psychic
				sum+=5 if pkmn.item == :PSYCHICSEED
				sum-=5 if pkmn.ability == :PRANKSTER
				pkmn.eachMove do |m|
					next if m.base_damage==0 || m.type != :PSYCHIC
					sum += 5
				end  
				pkmn.eachMove do |m|
					sum -= 1 if m.prio>0
				end   
				sum+=5 if pkmn.pbHasMoveFunction?("TypeAndPowerDependOnTerrain", "HitsAllFoesAndPowersUpInPsychicTerrain")
			end
		end
		return sum
	end

	def priorityAI(user,move,switchin=false)
		turncount = user.turnCount
		turncount = 0 if switchin
		pri = move.priority
		pri +=1 if user.hasActiveAbility?(:GALEWINGS) && user.hp >= (user.totalhp/2)&& move.type==:FLYING
		pri +=1 if move.baseDamage==0 && user.hasActiveAbility?(:PRANKSTER) 
		pri +=1 if move.function=="HigherPriorityInGrassyTerrain" && @battle.field.terrain==:Grassy && user.affectedByTerrain?
		pri +=1 if move.healingMove? && user.hasActiveAbility?(:TRIAGE)
		return pri
	end
	
  def wasUserAbilityActivated?(user) 
		return @battle.activedAbility[user.index & 1][user.pokemonIndex]
	end
end


class Battle::Battler
	def pbMoveTypeWeakeningBerry(berry_type, move_type, mults)
		return if move_type != berry_type
		return if !Effectiveness.super_effective?(@damageState.typeMod) && move_type != :NORMAL
		mults[:final_damage_multiplier] /= 2
		@damageState.berryWeakened = true
		ripening = false
		if hasActiveAbility?(:RIPEN)
			@battle.pbShowAbilitySplash(self)
			mults[:final_damage_multiplier] /= 2
			ripening = true
		end
		@battle.pbCommonAnimation("EatBerry", self) if !$aiberrycheck
		@battle.pbHideAbilitySplash(self) if ripening
	end
	
	# Needing AI to account for mold breaker.
	def airborneAI(moldbreaker=false)
		return true if hasActiveAbility?(:LEVITATE) && !moldbreaker
		return airborne?
	end

=begin # moved to AAM
	alias stupidity_hasActiveAbility? hasActiveAbility?
	def hasActiveAbility?(check_ability, ignore_fainted = false, mold_broken=false)
		return false if mold_broken
		return stupidity_hasActiveAbility?(check_ability, ignore_fainted) 
	end
=end

	def pbCanLowerAttackStatStageIntimidateAI(user)
		return false if fainted?
		return false if @effects[PBEffects::Substitute] > 0
		return false if Settings::MECHANICS_GENERATION >= 8 && hasActiveAbility?([:OBLIVIOUS, :OWNTEMPO, :INNERFOCUS, :SCRAPPY])
		return false if !hasActiveAbility?(:CONTRARY)
		return false if !pbCanLowerStatStage?(:ATTACK, user)
	end

	def pbCanLowerAttackStatStageGrimTearsAI(user)
		return false if fainted?
		return false if @effects[PBEffects::Substitute] > 0
		return false if Settings::MECHANICS_GENERATION >= 8 && hasActiveAbility?([:UNNERVE, :SOUNDPROOF, :INSOMNIA])
		return false if !hasActiveAbility?(:CONTRARY)
		return false if !pbCanLowerStatStage?(:SPECIAL_ATTACK, user)
	end
end	

class Battle
	def pbMakeFakeBattler(pokemon,batonpass=false,currentmon=nil,effectnegate=true)
		if @index.nil? || !currentmon.nil?
			@index=currentmon.index
		end
		wonderroom= @field.effects[PBEffects::WonderRoom]!=0
		battler = Battler.new(self,@index)
		battler.pbInitPokemon(pokemon,@index)
		battler.pbInitEffects(batonpass)#,false,effectnegate)
		#~ if batonpass
			#~ battler.stages[:ATTACK]          = currentmon.stages[:ATTACK]
			#~ battler.stages[:DEFENSE]         = currentmon.stages[:DEFENSE]
			#~ battler.stages[:SPEED]           = currentmon.stages[:SPEED]
			#~ battler.stages[:SPECIAL_ATTACK]  = currentmon.stages[:SPECIAL_ATTACK]
			#~ battler.stages[:SPECIAL_DEFENSE] = currentmon.stages[:SPECIAL_DEFENSE]
			#~ battler.stages[:ACCURACY]        = currentmon.stages[:ACCURACY]
			#~ battler.stages[:EVASION]         = currentmon.stages[:EVASION]
		#~ end	
		return battler
	end	

	def pbCanHardSwitchLax?(idxBattler, idxParty)
		return true if idxParty < 0
		party = pbParty(idxBattler)
		return false if idxParty >= party.length
		return false if !party[idxParty]
		if party[idxParty].egg?
		  return false
		end
		if !pbIsOwner?(idxBattler, idxParty)
		  return false
		end
		if party[idxParty].fainted?
		  return false
		end
		# if pbFindBattler(idxParty, idxBattler)
		#   partyScene.pbDisplay(_INTL("{1} is already in battle!",
		# 							 party[idxParty].name)) if partyScene
		#   return false
		# end
		return true
	end	

	def pbCommandPhaseLoop(isPlayer)
		# NOTE: Doing some things (e.g. running, throwing a Poké Ball) takes up all
		#       your actions in a round.
		actioned = []
		idxBattler = -1
		loop do
			break if @decision != 0   # Battle ended, stop choosing actions
			idxBattler += 1
			break if idxBattler >= @battlers.length
			next if !@battlers[idxBattler] || pbOwnedByPlayer?(idxBattler) != isPlayer
			next if @choices[idxBattler][0] != :None    # Action is forced, can't choose one
			next if !pbCanShowCommands?(idxBattler)   # Action is forced, can't choose one
			if !@controlPlayer && pbOwnedByPlayer?(idxBattler)
				# Player chooses an action
				actioned.push(idxBattler)
				commandsEnd = false   # Whether to cancel choosing all other actions this round
				loop do
					cmd = pbCommandMenu(idxBattler, actioned.length == 1)
					# If being Sky Dropped, can't do anything except use a move
					if cmd > 0 && @battlers[idxBattler].effects[PBEffects::SkyDrop] >= 0
						pbDisplay(_INTL("Sky Drop won't let {1} go!", @battlers[idxBattler].pbThis(true)))
						next
					end
					case cmd
					when 0    # Fight
						break if pbFightMenu(idxBattler)
					when 1    # Bag
						if pbItemMenu(idxBattler, actioned.length == 1)
							commandsEnd = true if pbItemUsesAllActions?(@choices[idxBattler][1])
							break
						end
					when 2    # Pokémon
						break if pbPartyMenu(idxBattler)
					when 3    # Run
						# NOTE: "Run" is only an available option for the first battler the
						#       player chooses an action for in a round. Attempting to run
						#       from battle prevents you from choosing any other actions in
						#       that round.
						if pbRunMenu(idxBattler)
							commandsEnd = true
							break
						end
					when 4    # Call
						break if pbCallMenu(idxBattler)
					when -2   # Debug
						pbDebugMenu
						next
					when -1   # Go back to previous battler's action choice
						next if actioned.length <= 1
						actioned.pop   # Forget this battler was done
						idxBattler = actioned.last - 1
						pbCancelChoice(idxBattler + 1)   # Clear the previous battler's choice
						actioned.pop   # Forget the previous battler was done
						break
					end
					pbCancelChoice(idxBattler)
				end
			else 
				# DemICE moved the AI decision after player decision.
				# AI controls this battler
				@battleAI.pbDefaultChooseEnemyCommand(idxBattler)
			end 
			break if commandsEnd
		end
	end
end

class Pokemon
	def isAirborne?
		return false if @item == :IRONBALL
		return true if hasType?(:FLYING)
		return true if @ability == :LEVITATE
		return true if @item == :AIRBALLOON
		return false
	end
	
	def eachMove
			@moves.each { |m| yield m }
	end
	
	def pbHasMoveFunction?(*arg)
		return false if !arg
		eachMove do |m|
			arg.each { |code| return true if m.function_code == code }
		end
		return false
	end
end  