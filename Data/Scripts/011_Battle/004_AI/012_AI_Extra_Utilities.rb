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
	
	
  #=============================================================================
  # Damage calculation (v2)
  #=============================================================================
	def pbRoughDamage(move, user, target, skill, baseDmg=0)
		skill=100
		baseDmg = pbMoveBaseDamage(move, user, target, skill) if baseDmg==0
		# Fixed damage moves
		return baseDmg if move.is_a?(Battle::Move::FixedDamageMove)
		# Get the move's type
		type = pbRoughType(move, user, skill)
		typeMod = pbCalcTypeMod(type,user,target)
		##### Calculate user's attack stat #####
		# shellysidearm isnt being calc'd correctly, but i dont really care desu
		atk = pbRoughStat(user, :ATTACK, skill)
		if move.function == "UseTargetAttackInsteadOfUserAttack" # Foul Play
			atk = pbRoughStat(target, :ATTACK, skill)
		elsif move.function == "UseUserBaseDefenseInsteadOfUserBaseAttack" # Body Press
			atk = pbRoughStat(user, :DEFENSE, skill)
		elsif move.function == "UseUserBaseSpecialDefenseInsteadOfUserBaseSpecialAttack" # Psycrush
			atk = pbRoughStat(user, :SPECIAL_DEFENSE, skill)
		elsif ["CategoryDependsOnHigherDamageIgnoreTargetAbility", 
			   "CategoryDependsOnHigherDamagePoisonTarget"].include?(move.function) # Photon Geyser, Shell Side Arm
			atk = [pbRoughStat(user, :ATTACK, skill), pbRoughStat(user, :SPECIAL_ATTACK, skill)].max
		elsif move.function == "TitanWrath" # Titan's Wrath (atk calc)
			userStats = user.plainStats
			highestStatValue = higheststat = 0
			userStats.each_value { |value| highestStatValue = value if highestStatValue < value }
			GameData::Stat.each_main_battle do |s|
				next if userStats[s.id] < highestStatValue
				higheststat = s.id
				break
			end
			atk = pbRoughStat(user, higheststat, skill)
		elsif move.specialMove?(type)
			if move.function == "UseTargetAttackInsteadOfUserAttack" # Foul Play
				atk = pbRoughStat(target, :SPECIAL_ATTACK, skill)
			else
				atk = pbRoughStat(user, :SPECIAL_ATTACK, skill)
			end
		end
		if user.hasActiveAbility?(:CRYSTALJAW) && move.bitingMove?
			atk = pbRoughStat(user, :SPECIAL_ATTACK, skill)
		end
		# taking in account intimidate from mons with AAM
		if !user.hasActiveAbility?([:DEFIANT, :CONTRARY, :UNAWARE])
			user.allOpposing.each do |b|
				if (b.isSpecies?(:GYARADOS) || b.isSpecies?(:LUPACABRA)) && 
				   b.pokemon.willmega && b.hasAbilityMutation? && move.physicalMove?(type)
					atk *= 2 / 3.0
				end
			end
		end
		##### Calculate target's defense stat #####
		defense = pbRoughStat(target, :DEFENSE, skill)
		if move.specialMove?(type) && move.function != "UseTargetDefenseInsteadOfTargetSpDef" # Psyshock
			defense = pbRoughStat(target, :SPECIAL_DEFENSE, skill)
		end
		if move.function == "TitanWrath" # Titan's Wrath (def calc)
			case higheststat
			when :ATTACK, :DEFENSE
				defense = pbRoughStat(target, :DEFENSE, skill)
			when :SPECIAL_ATTACK, :SPECIAL_DEFENSE, :SPEED
				defense = pbRoughStat(target, :SPECIAL_DEFENSE, skill)
			end
		elsif move.function == "CategoryDependsOnHigherDamagePoisonTarget" # Shell Side Arm (def calc)
			defense = [pbRoughStat(target, :DEFENSE, skill), pbRoughStat(target, :SPECIAL_DEFENSE, skill)].min
		end
		##### Calculate all multiplier effects #####
		multipliers = {
			:base_damage_multiplier  => 1.0,
			:attack_multiplier       => 1.0,
			:defense_multiplier      => 1.0,
			:final_damage_multiplier => 1.0
		}
		globalArray = pbGetMidTurnGlobalChanges
		# Ability effects that alter damage
		moldBreaker = moldbroken(user,target,move) # updated to take in the better mold breaker check
		if skill >= PBTrainerAI.mediumSkill && user.abilityActive?
			# NOTE: These abilities aren't suitable for checking at the start of the
			#       round.    # DemICE: some of them.
			abilityBlacklist = [:ANALYTIC, :SNIPER, :TINTEDLENS, :NEUROFORCE, :WARRIORSPIRIT]
			canCheck = true
			abilityBlacklist.each do |m|
				# Really? comparing a move id with an ability id? This blacklisting never worked.
				# it was also checking if the *target* had analytic/sniper, janky jank!
				next if user.ability != m
				if user.hasActiveAbility?(m)
					canCheck = false
					break
				end
			end
			if canCheck
				Battle::AbilityEffects.triggerDamageCalcFromUser(
					user.ability, user, target, move, multipliers, baseDmg, type
				)
			end
			# this doesnt take in foes' negative priority themselves, but lets be real very few would
			# use that anyway
			# also yes, this is taking in account allies, because for some reason thats a real check
			if user.hasActiveAbility?(:ANALYTIC)
				willOutslow = true
				aspeed = pbRoughStat(user,:SPEED,skill)
				@battle.allBattlers.each do |j|
					next if j.index == user.index
					break if !willOutslow
					willOutslow = false if ((aspeed > pbRoughStat(j,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
				end
				if priorityAI(user,move) < 0 || willOutslow
					multipliers[:base_damage_multiplier] *= 1.3
				end
			end
		end
		# if i didnt remove this mold breaker check, i would fake the AI out when she uses
		# moves that have mold breaker built in
		if skill >= PBTrainerAI.mediumSkill #&& !moldBreaker
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
				next if target.ability != m 
				# Really? comparing a move id with an ability id? This blacklisting never worked.
				if target.hasActiveAbility?(m)
					canCheck = false
					break
				end
			end
			if canCheck
				Battle::AbilityEffects.triggerDamageCalcFromTarget(
					target.ability, user, target, move, multipliers, baseDmg, type
				)
				# if laguna already has fur coat in base, there is no need to take it in acc again
				if target.isSpecies?(:LAGUNA) && target.pokemon.willmega && target.ability != :FURCOAT && move.physicalMove?(type)
					multipliers[:defense_multiplier] *= 2
				end
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
		if skill >= PBTrainerAI.bestSkill &&                           # DemICE: I now have high suspicions that the chilan berry thing doesn't work.
			target.itemActive? && target.item && !target.item.is_berry?# && target.item_id!=:CHILANBERRY)
			Battle::ItemEffects.triggerDamageCalcFromTarget(
				target.item, user, target, move, multipliers, baseDmg, type
			)
		end
		# Global abilities
		if skill >= PBTrainerAI.mediumSkill &&
			(((@battle.pbCheckGlobalAbility(:DARKAURA)    || globalArray.include?("dark aura"))    && type == :DARK)  ||
			 ((@battle.pbCheckGlobalAbility(:SPOOPERAURA) || globalArray.include?("spooper aura")) && type == :GHOST) ||
			 (@battle.pbCheckGlobalAbility(:FAIRYAURA)                                             && type == :FAIRY))
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
		# Zealous Dance
		if skill >= PBTrainerAI.mediumSkill &&
			 user.effects[PBEffects::ZealousDance] > 0 && type == :FIRE
			multipliers[:base_damage_multiplier] *= 1.5
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
		# DemICE adding resist berries ### i made it a hash cuz i was bored
		if Effectiveness.super_effective?(typeMod)
			multipliers[:final_damage_multiplier] *= 1.2 if user.hasActiveAbility?(:NEUROFORCE)
			multipliers[:final_damage_multiplier] *= 1.2 if user.hasActiveItem?(:EXPERTBELT)
			multipliers[:final_damage_multiplier] *= 1.5 if user.hasActiveAbility?(:WARRIORSPIRIT)
			if target.hasActiveAbility?([:SOLIDROCK, :FILTER],false,moldBreaker)
				multipliers[:final_damage_multiplier] *= 0.75
			end
			berryTypesArray = {
				:OCCABERRY   => :FIRE,
				:PASSHOBERRY => :WATER,
				:WACANBERRY  => :ELECTRIC,
				:RINDOBERRY  => :GRASS,
				:YACHEBERRY  => :ICE,
				:CHOPLEBERRY => :FIGHTING,
				:KEBIABERRY  => :POISON,
				:SHUCABERRY  => :GROUND,
				:COBABERRY   => :FLYING,
				:PAYAPABERRY => :PSYCHIC,
				:TANGABERRY  => :BUG,
				:CHARTIBERRY => :ROCK,
				:KASIBBERRY  => :GHOST,
				:HABANBERRY  => :DRAGON,
				:COLBURBERRY => :DARK,
				:ROSELIBERRY => :FAIRY,
				:BABIRIBERRY => :STEEL
			}
			berry_type = berryTypesArray[target.item_id]
			multipliers[:final_damage_multiplier] *= 0.5 if berry_type && type == berry_type
		elsif Effectiveness.resistant?(typeMod)
			multipliers[:final_damage_multiplier] *= 2.0 if user.hasActiveAbility?(:TINTEDLENS)
		end
		# Terrain moves
		if skill >= PBTrainerAI.mediumSkill
			if globalArray.none? { |element| element.include?("terrain") }
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
					multipliers[:base_damage_multiplier] /= t_damage_divider    if type == :DRAGON && target.affectedByTerrain?
				end
			else	
				if $game_variables[MECHANICSVAR] >= 3 # on "low mode"
					t_damage_multiplier = 1.15
					t_damage_divider    = 1.5
				else
					t_damage_multiplier = 1.3
					t_damage_divider    = 2
				end
				multipliers[:base_damage_multiplier] *= t_damage_multiplier if type == :ELECTRIC && globalArray.include?("electric terrain") && user.affectedByTerrain?
				multipliers[:base_damage_multiplier] /= t_damage_divider    if type == :DRAGON   && globalArray.include?("misty terrain") && target.affectedByTerrain?
				multipliers[:base_damage_multiplier] *= t_damage_multiplier if type == :GRASS    && globalArray.include?("grassy terrain") && user.affectedByTerrain?
				multipliers[:base_damage_multiplier] *= t_damage_multiplier if type == :PSYCHIC  && globalArray.include?("psychic terrain") && user.affectedByTerrain?
			end
		end
		#mastersex type zones #by low
		multipliers[:base_damage_multiplier] *= 1.25 if @battle.field.typezone != :None && type == @battle.field.typezone
		# Multi-targeting attacks
		# Splinter Shot #by low
		if skill >= PBTrainerAI.highSkill && pbTargetsMultiple?(move, user) && move.function != "HitTwoTimesReload"
			multipliers[:final_damage_multiplier] *= 0.75
		end
		# Weather
		if skill >= PBTrainerAI.mediumSkill
			if globalArray.none? { |element| element.include?("weather") }
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
					if target.pbHasType?(:ROCK, true) && move.specialMove?(type) &&
					   move.function != "UseTargetDefenseInsteadOfTargetSpDef"   # Psyshock
						multipliers[:defense_multiplier] *= 1.5
					end
				when :Hail # hail buff #by low
					if target.pbHasType?(:ICE, true) && Effectiveness.super_effective?(typeMod)
						multipliers[:final_damage_multiplier] *= 0.75
					end
				end
			else
				if $game_variables[MECHANICSVAR] >= 3 # on "low mode"
					w_damage_multiplier = 1.25
					w_damage_divider    = 1.5
				else
					w_damage_multiplier = 1.5
					w_damage_divider    = 2
				end
				# abilities *can* overwrite primal weather
				if !user.hasActiveItem?(:UTILITYUMBRELLA)
					if globalArray.include?("sun weather")
						case type
						when :FIRE
							multipliers[:final_damage_multiplier] *= w_damage_multiplier
						when :WATER
							multipliers[:final_damage_multiplier] /= w_damage_divider
						end
						if move.specialMove?(type) && user.hasActiveAbility?(:SOLARPOWER)
							multipliers[:attack_multiplier] *= 1.5
						end
					end
					if globalArray.include?("rain weather")
						case type
						when :FIRE
							multipliers[:final_damage_multiplier] /= w_damage_divider
						when :WATER
							multipliers[:final_damage_multiplier] *= w_damage_multiplier
						end
					end
				end
				if globalArray.include?("sand weather")
					if target.pbHasType?(:ROCK, true) && move.specialMove?(type) &&
						 move.function != "UseTargetDefenseInsteadOfTargetSpDef"   # Psyshock
						multipliers[:defense_multiplier] *= 1.5
					end
				end
				if globalArray.include?("hail weather")
					if target.pbHasType?(:ICE, true) && Effectiveness.super_effective?(typeMod)
						multipliers[:final_damage_multiplier] *= 0.75
					end
				end
			end
		end
		# Master Mode stuff #by low
		if $game_variables[MASTERMODEVARS][28]==true && !target.pbOwnedByPlayer? && Effectiveness.super_effective?(typeMod)
			multipliers[:final_damage_multiplier] *= 0.75
		end
		# Gravity Boost #by low 
		# float stone changes
		if move.boostedByGravity? && @battle.field.effects[PBEffects::Gravity] > 0 && !target.hasActiveItem?(:FLOATSTONE)
			multipliers[:base_damage_multiplier] *= 4 / 3.0
		end
		# Critical hits - n/a
		# Random variance - n/a
		#if $Trainer.difficulty_mode==2
			#if user.pbOwnedByPlayer? # Changed by DemICE 27-Sep-2023 Unfair difficulty
				#multipliers[:final_damage_multiplier] *= 1 - target.level/500.00 
			#else
				#multipliers[:final_damage_multiplier] *= 1 + user.level/300.00 
			#end
		#end
		# STAB
		if skill >= PBTrainerAI.mediumSkill && type && user.pbHasType?(type, true)
			if user.hasActiveAbility?(:ADAPTABILITY)
				multipliers[:final_damage_multiplier] *= 2
			else
				multipliers[:final_damage_multiplier] *= 1.5
			end
		end
		# Type effectiveness
		if skill >= PBTrainerAI.mediumSkill
			#typemod = pbCalcTypeMod(type, user, target) # why are you calculating it again?
			multipliers[:final_damage_multiplier] *= typeMod.to_f / Effectiveness::NORMAL_EFFECTIVE
		end
		damagenerf = (1 / 2.0)
		damagenerf = (2 / 3.0) if $game_variables[MECHANICSVAR] >= 3 #by low
		# Burn
		if move.physicalMove?(type) && move.damageReducedByBurn? && user.status == :BURN && 
		  !user.hasActiveAbility?(:GUTS)
			multipliers[:final_damage_multiplier] *= damagenerf
		end
		# Frostbite #by low
		if move.specialMove?(type) && move.damageReducedByBurn? && user.status == :FREEZE
			multipliers[:final_damage_multiplier] *= damagenerf
		end
		# Aurora Veil, Reflect, Light Screen
		if skill >= PBTrainerAI.highSkill && !move.ignoresReflect? && !user.hasActiveAbility?(:INFILTRATOR)
			if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
				multipliers[:final_damage_multiplier] *= 4 / 5.0
			end
			if target.pbOwnSide.effects[PBEffects::Reflect] > 0 && move.physicalMove?(type)
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
		# Golden Camera calculation
		if $PokemonGlobal.goldencamera
			atk *= 0.8 if user.pbOwnedByPlayer?
			defense *= 0.8 if target.pbOwnedByPlayer?
		end
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
			# Other efffects
			c = -1 if target.pbOwnSide.effects[PBEffects::LuckyChant] > 0
			# Ability effects that alter critical hit rate
			if c >= 0 && user.abilityActive?
				c = Battle::AbilityEffects.triggerCriticalCalcFromUser(user.ability, user, target, c)
			end
			if c >= 0 && target.abilityActive? && !moldBreaker
				c = Battle::AbilityEffects.triggerCriticalCalcFromTarget(target.ability, user, target, c)
			end
			# Item effects that alter critical hit rate
			if c >= 0 && user.itemActive?
				c = Battle::ItemEffects.triggerCriticalCalcFromUser(user.item, user, target, c)
			end
			if c >= 0 && target.itemActive?
				c = Battle::ItemEffects.triggerCriticalCalcFromTarget(target.item, user, target, c)
			end
			if c >= 0
				c += 1 if move.highCriticalRate?
				c += user.effects[PBEffects::FocusEnergy]
				c += 1 if user.inHyperMode? && move.type == :SHADOW
				c = 4 if ["AlwaysCriticalHit", "HitThreeTimesAlwaysCriticalHit"].include?(move.function)
				# DemICE: taking into account 100% crit rate.
				stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
				stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
				vatk, atkStage = move.pbGetAttackStats(user,target)
				vdef, defStage = move.pbGetDefenseStats(user,target)
				atkmult = 1.0*stageMul[atkStage]/stageDiv[atkStage]
				defmult = 1.0*stageMul[defStage]/stageDiv[defStage]
				if c >= 3
					damage = 0.96*damage/atkmult if atkmult<1
					damage = damage*defmult if defmult>1
				end
				if c >= 1
					c = 4 if c > 4
					if c >= 3
						damage*=1.5
						damage*=1.5 if user.hasActiveAbility?(:SNIPER)
					else
						damage += damage*0.1*c
					end
				end
			end
		end
		damage *= (5.0 / 4.0) if target.effects[PBEffects::BoomInstalled]
		return damage.floor
	end
	
	def moldbroken(user, target, move)
		#return false if target.hasActiveAbility?([:SHADOWSHIELD, :FULLMETALBODY])
		return false if target.hasActiveAbility?(:SHADOWSHIELD)
		if (user.hasMoldBreaker? || 
			["IgnoreTargetAbility",
			 "CategoryDependsOnHigherDamageIgnoreTargetAbility"].include?(move.function))
			return true
		end
		if (user.isSpecies?(:GYARADOS)  && (user.item == :GYARADOSITE || user.hasMegaEvoMutation?) && user.pokemon.willmega) ||
		   (user.isSpecies?(:LUPACABRA) && (user.item == :LUPACABRITE || user.hasMegaEvoMutation?) && user.pokemon.willmega)
			return true
		end
		return false
	end
	
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
		elsif move.function == "FailsIfTargetHasNoItem"
			if !target.item || !target.itemActive?
				return true
			end
		end
		
		type = pbRoughType(move,user,skill)
		typeMod = pbCalcTypeMod(type,user,target)
		# Type effectiveness
		return true if (move.damagingMove? && Effectiveness.ineffective?(typeMod)) || 
					   (score <= 0 && !($movesToTargetAllies.include?(move.function) && !user.opposes?(target)))
		# DemICE: Mold Breaker implementation
		mold_broken = moldbroken(user,target,move)
		globalArray = pbGetMidTurnGlobalChanges
		case type
		when :GROUND
			return true if target.airborneAI(mold_broken) && !move.hitsFlyingTargets?
		when :FIRE
			return true if target.hasActiveAbility?(:FLASHFIRE,false,mold_broken)
		when :WATER
			return true if target.hasActiveAbility?([:DRYSKIN,:STORMDRAIN,:WATERABSORB],false,mold_broken)
		when :GRASS
			return true if target.hasActiveAbility?(:SAPSIPPER,false,mold_broken)
		when :ELECTRIC
			return true if target.hasActiveAbility?([:LIGHTNINGROD,:MOTORDRIVE,:VOLTABSORB],false,mold_broken)
			return true if (target.isSpecies?(:GOHILA) || target.isSpecies?(:ROADRAPTOR)) && target.pokemon.willmega && !mold_broken
			# i mean, road is already immune cuz ground, but idk maybe you gave it ring target
			# ¯\_(ツ)_/¯
		end
		return true if !Effectiveness.super_effective?(typeMod) && move.baseDamage>0 && 
						target.hasActiveAbility?(:WONDERGUARD,false,mold_broken)
		return true if move.damagingMove? && user.index != target.index && !target.opposes?(user) &&
					   target.hasActiveAbility?(:TELEPATHY,false,mold_broken)
		return true if move.canMagicCoat? && 
					   (target.hasActiveAbility?(:MAGICBOUNCE,false,mold_broken) || 
					   (target.isSpecies?(:SABLEYE) && target.pokemon.willmega && !mold_broken)) && 
					   target.opposes?(user)
		return true if move.soundMove? && target.hasActiveAbility?(:SOUNDPROOF,false,mold_broken)
		return true if move.bombMove? && (target.hasActiveAbility?(:BULLETPROOF,false,mold_broken) || 
										 (target.isSpecies?(:MAGCARGO) && target.pokemon.willmega && !mold_broken))
		return true if [:HYPNOSIS, :GRASSWHISTLE, :LOVELYKISS, 
						:SING, :DARKVOID, :SLEEPPOWDER, :SPORE, :YAWN].include?(move.id) && 
						(@battle.field.terrain == :Electric || globalArray.include?("electric terrain"))
		if move.powderMove?
			return true if target.pbHasType?(:GRASS, true)
			return true if target.hasActiveAbility?(:OVERCOAT,false,mold_broken)
			return true if target.hasActiveItem?(:SAFETYGOGGLES)
		end
		if priorityAI(user,move) > 0
			@battle.allSameSideBattlers(target.index).each do |b|
				return true if b.hasActiveAbility?([:DAZZLING, :QUEENLYMAJESTY],false,mold_broken)  &&
							 !(b.isSpecies?(:LAGUNA) && b.pokemon.willmega) # laguna can have dazz in pre-mega form
			end
			return true if (@battle.field.terrain == :Psychic || globalArray.include?("psychic terrain")) && target.affectedByTerrain? && target.opposes?(user)
		end
		return true if move.statusMove? && target.effects[PBEffects::Substitute] > 0 &&
					   !move.ignoresSubstitute?(user) && user.index != target.index
		return true if move.statusMove? && Settings::MECHANICS_GENERATION >= 7 &&
					   user.hasActiveAbility?(:PRANKSTER) && target.pbHasType?(:DARK, true) &&
					   target.opposes?(user)
		return false
	end	
	
  	def targetSurvivesMove(move,attacker,opponent,priodamage=0,mult=1)
		return true if !move
		mold_broken=moldbroken(attacker,opponent,move)
		damage = pbRoughDamage(move,attacker,opponent,100, move.baseDamage)
		damage+=priodamage
		damage*=mult
		multiarray = ["HitTwoTimes", "HitTwoTimesReload", "HitTwoTimesFlinchTarget", 
					  "HitTwoTimesTargetThenTargetAlly",
					  "HitTwoTimesPoisonTarget", "HitThreeToFiveTimes", 
					  "HitThreeTimesPowersUpWithEachHit",
					  "HitTwoToFiveTimes", "HitTwoToFiveTimesOrThreeForAshGreninja", 
					  "HitTwoToFiveTimesRaiseUserSpd1LowerUserDef1",
					  "HitThreeTimesAlwaysCriticalHit"]
		if opponent.hasActiveAbility?(:DISGUISE,false,mold_broken) && opponent.form==0	
			if multiarray.include?(move.function)
				damage*=0.6
			else
				damage=1
			end
		end			
		return true if damage < opponent.hp
		return false if priodamage>0
		if (opponent.hasActiveItem?(:FOCUSSASH) || opponent.hasActiveAbility?(:STURDY,false,mold_broken)) && opponent.hp==opponent.totalhp
			return false if multiarray.include?(move.function)
			return true
		end	
		return false
	end

	def canSleepTarget(attacker,opponent,globalArray,berry=false)
		return false if opponent.effects[PBEffects::Substitute]>0 && !attacker.hasActiveAbility?(:INFILTRATOR)
		return false if berry && (opponent.status==:SLEEP)# && opponent.statusCount>1)
		return false if opponent.hasActiveItem?([:LUMBERRY, :CHESTOBERRY]) && berry
		return false if opponent.pbOwnSide.effects[PBEffects::Safeguard] > 0 && !attacker.hasActiveAbility?(:INFILTRATOR)
		if opponent.affectedByTerrain?
			return false if globalArray.any? { |j| ["electric terrain", "misty terrain"].include?(j) }
			return false if (@battle.field.terrain == :Electric || @battle.field.terrain == :Misty)
		end
		return false if !opponent.pbCanSleep?(attacker,false)
		for move in attacker.moves
			if ["SleepTarget", "SleepTargetIfUserDarkrai", "SleepTargetNextTurn"].include?(move.function)
				return false if move.powderMove? && opponent.pbHasType?(:GRASS, true)
				return true	
			end	
		end
		return true if $AIMASTERLOG
		return false
	end

	def canFlinchTarget(user,target,mold_bonkers=false)
		return false if target.effects[PBEffects::Substitute] > 0 && !user.hasActiveAbility?(:INFILTRATOR)
		return false if target.effects[PBEffects::NoFlinch] > 0
		return false if target.hasActiveAbility?([:INNERFOCUS,:SHIELDDUST],false,mold_bonkers)
		target.allAllies.each do |bb|
			break if $game_variables[MECHANICSVAR] <= 1
			return false if bb.hasActiveAbility?(:INNERFOCUS,false,mold_bonkers)
		end
		for move in user.moves
			return true if move.function == "FlinchTargetFailsIfNotUserFirstTurn" && 
						   user.turnCount == 0
			if move.flinchingMove?
				return false if @battle.turnCount == 0
				return true
			end
		end
		return true if user.hasActiveItem?([:KINGSROCK,:RAZORFANG]) || user.hasActiveAbility?(:STENCH)
		return true if $AIMASTERLOG
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

	def checkWeatherBenefit(user, globalArray, weathery = false, requestedWeather = nil, terrainy = false, requestedTerrain = nil)
		sum = 0
		issunny = @battle.field.weather == :Sun || globalArray.include?("sun weather")
		currentWeather = requestedWeather || @battle.pbWeather
		currentTerrain = requestedTerrain || @battle.field.terrain
		if requestedWeather.nil?
			globalArray.each do |weather|
				case weather
				when "sun weather"
					currentWeather = :Sun
				when "rain weather"
					currentWeather = :Rain
				when "sand weather"
					currentWeather = :Sandstorm
				when "hail weather"
					currentWeather = :Hail
				end
			end
		end
		if requestedTerrain.nil?
			globalArray.each do |terrain|
				case terrain
				when "electric terrain"
					currentTerrain = :Electric
				when "grassy terrain"
					currentTerrain = :Grassy
				when "misty terrain"
					currentTerrain = :Misty
				when "psychic terrain"
					currentTerrain = :Psychic
				end
			end
		end
		
		ownparty = @battle.pbParty(user.index)
		ownparty.each_with_index do |pkmn, idxParty|
			next if !pkmn || !pkmn.able?
			if weathery
				if currentWeather == :Sun
					sum += 20 if pkmn.ability == :CHLOROPHYLL
					sum += 10 if pkmn.ability == :FLOWERGIFT || pkmn.ability == :SOLARPOWER
					sum += 5 if pkmn.ability == :HEALINGSUN || pkmn.ability == :HARVEST
					sum -= 5 if pkmn.ability == :DRYSKIN
					pkmn.eachMove do |m|
						next if m.base_damage == 0 || m.type != :FIRE
						sum += 10
					end
					pkmn.eachMove do |m|
						next if m.base_damage == 0 || m.type != :WATER
						sum -= 5
					end
					sum += 5 if pkmn.pbHasMoveFunction?("HealUserDependingOnWeather", "RaiseUserAtkSpAtk1Or2InSun")
					sum += 5 if pkmn.pbHasMoveFunction?("TwoTurnAttackOneTurnInSun", "HigherDamageInSunVSNonFireTypes")
					sum -= 5 if pkmn.pbHasMoveFunction?("ParalyzeTargetAlwaysHitsInRainHitsTargetInSky", "ConfuseTargetAlwaysHitsInRainHitsTargetInSky")
				end
				if currentWeather == :Rain
					sum += 20 if pkmn.ability == :SWIFTSWIM
					sum += 5 if pkmn.ability == :RAINDISH || pkmn.ability == :DRYSKIN || pkmn.ability == :HYDRATION
					pkmn.eachMove do |m|
						next if m.base_damage == 0 || m.type != :WATER
						sum += 10
					end
					pkmn.eachMove do |m|
						next if m.base_damage == 0 || m.type != :FIRE
						sum -= 5
					end
					sum += 5 if pkmn.pbHasMoveFunction?("ParalyzeTargetAlwaysHitsInRainHitsTargetInSky")
					sum -= 5 if pkmn.pbHasMoveFunction?("HealUserDependingOnWeather", "RaiseUserAtkSpAtk1Or2InSun", "TwoTurnAttackOneTurnInSun") && issunny
				end
				if currentWeather == :Sandstorm
					sum += 20 if pkmn.ability == :SANDRUSH
					sum += 10 if pkmn.ability == :SANDVEIL || pkmn.ability == :SANDFORCE
					sum += 10 if pkmn.hasType?(:ROCK)
					sum += 5 if pkmn.pbHasMoveFunction?("HealUserDependingOnSandstorm")
					sum -= 5 if pkmn.pbHasMoveFunction?("HealUserDependingOnWeather", "RaiseUserAtkSpAtk1Or2InSun", "TwoTurnAttackOneTurnInSun", "HigherDamageInSunVSNonFireTypes") && issunny
				end
				if currentWeather == :Hail
					sum += 20 if pkmn.ability == :SLUSHRUSH
					sum += 10 if pkmn.ability == :SNOWCLOAK || pkmn.ability == :ICEBODY
					sum += 15 if pkmn.hasType?(:ICE)
					sum += 15 if pkmn.pbHasMoveFunction?("StartWeakenDamageAgainstUserSideIfHail")
					sum += 5 if pkmn.pbHasMoveFunction?("FreezeTargetAlwaysHitsInHail")
					sum -= 5 if pkmn.pbHasMoveFunction?("HealUserDependingOnWeather", "RaiseUserAtkSpAtk1Or2InSun", "TwoTurnAttackOneTurnInSun", "HigherDamageInSunVSNonFireTypes") && issunny
				end
			end
			if terrainy
				if currentTerrain == :Electric
					sum += 20 if pkmn.ability == :SURGESURFER
					sum += 5 if pkmn.item == :ELECTRICSEED
					pkmn.eachMove do |m|
						next if m.base_damage == 0 || m.type != :ELECTRIC
						sum += 5
					end
					sum += 5 if pkmn.pbHasMoveFunction?("TypeAndPowerDependOnTerrain", "BPRaiseWhileElectricTerrain")
					sum += 5 if pkmn.pbHasMoveFunction?("DoublePowerInElectricTerrain")
				end
				if currentTerrain == :Grassy
					sum += 5 if pkmn.ability == :GRASSPELT
					sum += 5 if pkmn.item == :GRASSYSEED
					pkmn.eachMove do |m|
						next if m.base_damage == 0 || m.type != :GRASS
						sum += 5
					end
					sum -= 5 if pkmn.pbHasMoveFunction?("DoublePowerIfTargetUnderground", "RandomPowerDoublePowerIfTargetUnderground", "LowerTargetSpeed1WeakerInGrassyTerrain")
					sum += 5 if pkmn.pbHasMoveFunction?("TypeAndPowerDependOnTerrain", "HealTargetDependingOnGrassyTerrain")
					sum += 5 if pkmn.pbHasMoveFunction?("HigherPriorityInGrassyTerrain")
				end
				if currentTerrain == :Misty
					sum += 5 if pkmn.item == :MISTYSEED
					pkmn.eachMove do |m|
						next if m.base_damage == 0 || m.type != :DRAGON
						sum -= 5
					end
					sum -= 5 if pkmn.pbHasMoveFunction?("SleepTarget", "SleepTargetIfUserDarkrai", "SleepTargetChangeUserMeloettaForm", "ParalyzeTargetIfNotTypeImmune", "BadPoisonTarget")
					sum += 5 if pkmn.pbHasMoveFunction?("TypeAndPowerDependOnTerrain", "UserFaintsPowersUpInMistyTerrainExplosive")
				end
				if currentTerrain == :Psychic
					sum -= 5 if pkmn.ability == :PRANKSTER
					sum += 5 if pkmn.item == :PSYCHICSEED
					pkmn.eachMove do |m|
						next if m.base_damage == 0 || m.type != :PSYCHIC
						sum += 5
					end
					pkmn.eachMove do |m|
						sum -= 1 if m.priority > 0
					end
					sum += 5 if pkmn.pbHasMoveFunction?("TypeAndPowerDependOnTerrain", "HitsAllFoesAndPowersUpInPsychicTerrain")
				end
			end
		end
		return sum
	end	  

	def priorityAI(user,move,switchin=false)
		turncount = user.turnCount
		turncount = 0 if switchin
		pri = move.priority
		pri +=1 if user.hasActiveAbility?(:GALEWINGS) && user.hp >= (user.totalhp/2.0) && move.type==:FLYING
		pri +=1 if move.baseDamage==0 && user.hasActiveAbility?(:PRANKSTER) 
		pri +=1 if move.function=="HigherPriorityInGrassyTerrain" && @battle.field.terrain==:Grassy && user.affectedByTerrain?
		pri +=1 if move.healingMove? && user.hasActiveAbility?(:TRIAGE)
		pri +=1 if move.soundMove? && move.baseDamage==0 && user.effects[PBEffects::PrioEchoChamber] > 0 && user.hasActiveAbility?(:ECHOCHAMBER)
		pri = -1 if user.hasActiveItem?([:LAGGINGTAIL, :FULLINCENSE])
		return pri
	end
	
	def EndofTurnHPChanges(user,target,heal,chips,both,switching=false,rest=false)
		# sums up all the changes to hp that will occur after the battle round. Healing from various effects/items/statuses or damage from the same. 
		# the arguments above show which ones in specific we're looking for, both being the typical default for most but sometimes we're only looking to see how much damage will occur at the end or how much healing.
		# thus it will return at 3 different points; end of healing if heal is desired, end of chip if chip is desired or at the very end if both.
		healing = 1  
		chip = 0
		if user.effects[PBEffects::HealBlock] > 0
			healing = 0
		else
			if user.effects[PBEffects::AquaRing]
				subscore = 0.0625
				subscore *= 1.3 if user.itemActive? && [:BIGROOT, :COLOGNECASE].include?(user.item)
				healing += subscore
			end
			if user.effects[PBEffects::Ingrain]
				subscore = 0.0625
				subscore *= 1.3 if user.itemActive? && [:BIGROOT, :COLOGNECASE].include?(user.item)
				healing += subscore
			end
			healing += 0.0625 if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
			healing += 0.0625 if user.hasActiveAbility?(:DRYSKIN) && [:Rain, :HeavyRain].include?(user.effectiveWeather)
			healing += 0.0625 if user.hasActiveAbility?(:RAINDISH) && [:Rain, :HeavyRain].include?(user.effectiveWeather)
			healing += 0.0625 if user.hasActiveAbility?(:HEALINGSUN) && [:Sun, :HarshSun].include?(user.effectiveWeather)
			healing += 0.0625 if user.hasActiveAbility?(:ICEBODY) && user.effectiveWeather == :Hail
			healing += 0.125 if user.poisoned? && user.hasActiveAbility?(:POISONHEAL)
			healing += 0.125 if target.effects[PBEffects::LeechSeed]>-1 && !target.hasActiveAbility?(:LIQUIDOOZE)
			healing *= 2 if @battle.pbCheckGlobalAbility(:STALL)
		end
		return healing if heal
		if user.takesIndirectDamage?
			weatherchip = 0
			weatherchip += 0.0625 if [:Sun, :HarshSun].include?(user.effectiveWeather) && user.hasActiveAbility?(:DRYSKIN)
			weatherchip += 0.0625 if user.effectiveWeather == :Sandstorm && user.takesSandstormDamage?
			weatherchip += 0.0625 if user.effectiveWeather == :Hail && user.takesHailDamage?
			chip += weatherchip
			if user.effects[PBEffects::Trapping]>0
				multiturnchip = 0.125 
				multiturnchip *= (4.0 / 3.0) if @battlers[battler.effects[PBEffects::TrappingUser]].hasActiveItem?(:BINDINGBAND)
				chip+=multiturnchip
			end
			chip += 0.125 if user.effects[PBEffects::LeechSeed]>=0 || (target.effects[PBEffects::LeechSeed]>=0 && target.hasActiveAbility?(:LIQUIDOOZE))
			chip += 0.25  if user.effects[PBEffects::Curse]
			if user.pbHasAnyStatus? && !rest
				statuschip = 0
				if user.burned? && !user.hasActiveAbility?(:FLAREBOOST)
					subscore = 0.0625
					subscore /= 2 if user.hasWorkingAbility?(:HEATPROOF)
					statuschip += subscore
				end
				if user.frozen?
					subscore = 0.0625
					subscore /= 2 if user.hasWorkingAbility?(:THICKFAT)
					statuschip += subscore
				end
				if user.asleep?
					user.allOpposing.each do |b|
						statuschip += 0.125 if b.hasActiveAbility?(:BADDREAMS)
						break
					end
				end
				if user.poisoned? && !user.hasActiveAbility?([:POISONHEAL, :TOXICBOOST])
					if $game_variables[MECHANICSVAR] >= 2 || user.effects[PBEffects::Toxic]==0 
						statuschip += 0.125
						statuschip += 0.125 if (user.effects[PBEffects::Toxic]+1) > 2 && $game_variables[MECHANICSVAR] >= 2
					else
						statuschip += (0.0625*user.effects[PBEffects::Toxic])
					end
				end
				chip+=statuschip
			end
			chip*=2 if @battle.pbCheckGlobalAbility(:STALL)
			chip*=(5.0/4.0) if user.effects[PBEffects::BoomInstalled]
		end
		return chip if chips
		diff=(healing-chip)
		return diff if both
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
		pbRaiseTropiusEvolutionStep(self) #by low
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
		if batonpass
			battler.stages[:ATTACK]          = currentmon.stages[:ATTACK]
			battler.stages[:DEFENSE]         = currentmon.stages[:DEFENSE]
			battler.stages[:SPEED]           = currentmon.stages[:SPEED]
			battler.stages[:SPECIAL_ATTACK]  = currentmon.stages[:SPECIAL_ATTACK]
			battler.stages[:SPECIAL_DEFENSE] = currentmon.stages[:SPECIAL_DEFENSE]
			battler.stages[:ACCURACY]        = currentmon.stages[:ACCURACY]
			battler.stages[:EVASION]         = currentmon.stages[:EVASION]
		end	
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