#===============================================================================
# The user's Special Defense user's Special Attack. (Psycrush)
#===============================================================================
class Battle::Move::UseUserBaseSpecialDefenseInsteadOfUserBaseSpecialAttack < Battle::Move
  def pbGetAttackStats(user, target)
    return user.spdef, user.stages[:SPECIAL_DEFENSE] + 6
  end
end

#===============================================================================
# The damage is based on the user's highest plain, non-HP stat. 
# The move's type is set by the user's type.
# The move's animation is set by the user's type.
# (Titan's Wrath)
#===============================================================================
class Battle::Move::TitanWrath < Battle::Move
  def initialize(battle, move)
    super
    @calcCategory = 1
  end

  def physicalMove?(thisType = nil); return (@calcCategory == 0); end
  def specialMove?(thisType = nil);  return (@calcCategory == 1); end
	
	def pbGetAttackStats(user, target)
    userStats = user.plainStats
    highestStatValue = 0;higheststat = 0;statbranch = [0,0]
    userStats.each_value { |value| highestStatValue = value if highestStatValue < value }
    GameData::Stat.each_main_battle do |s|
      next if userStats[s.id] < highestStatValue
			higheststat = s.id
      break
    end
		case higheststat
			when :ATTACK
				@calcCategory = 0
				statbranch = [user.attack, user.stages[:ATTACK] + 6]
			when :DEFENSE
				@calcCategory = 0
				statbranch = [user.defense, user.stages[:DEFENSE] + 6]
			when :SPECIAL_ATTACK
				@calcCategory = 1
				statbranch = [user.spatk, user.stages[:SPECIAL_ATTACK] + 6]
			when :SPECIAL_DEFENSE
				@calcCategory = 1
				statbranch = [user.spdef, user.stages[:SPECIAL_DEFENSE] + 6]
			when :SPEED
				@calcCategory = 1
				statbranch = [user.speed, user.stages[:SPEED] + 6]
		end
		#~ @battle.pbDisplayPaused(_INTL("{1}, {2}, {3}", statbranch[0], statbranch[1], @calcCategory))
		return statbranch
	end
	
  def pbBaseType(user)
    userTypes = user.pbTypes(true)
    return userTypes[0] || @type
  end
  
  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    userTypes = user.pbTypes(true)
    type_moves = {
      special: {
        :NORMAL => :HYPERBEAM, 
        :ROCK => :POWERGEM, :ICE => :SHEERCOLD, :STEEL => :STEELBEAM,
        :ELECTRIC => :THUNDER, :DRAGON => :ETERNABEAM, 
        :GRASS => :SOLARBEAM, :FIGHTING => :FOCUSBLAST, :FAIRY => :LIGHTOFRUIN
      },
      physical: {
        :NORMAL => :GIGAIMPACT, 
        :ROCK => :STONEEDGE, :ICE => :ICICLECRASH, :STEEL => :STEELROLLER,
        :ELECTRIC => :FUSIONBOLT, :DRAGON => :OUTRAGE, 
        :GRASS => :POWERWHIP, :FIGHTING => :CLOSECOMBAT, :FAIRY => :NATURESMADNESS
      }
    }
  
    category = @calcCategory == 1 ? :special : :physical
    type = userTypes[0]
    id = type_moves[category][type] if type_moves[category][type] && 
                                       GameData::Move.exists?(type_moves[category][type])
    super
  end
end

#===============================================================================
# Raises an ally Pokémon's highest stat by one stage.
# Lowers an opposing Pokémon's highest stat by two stages.
# (Rebalancing)
#===============================================================================
class Battle::Move::Rebalancing < Battle::Move
  def pbOnStartUse(user,targets)
    @TargetIsAlly = false
    @TargetIsAlly = !user.opposes?(targets[0]) if targets.length>0
  end

  def pbFailsAgainstTarget?(user,target,show_message)
    if target.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(user)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
		return true if target.SetupMovesUsed.include?(@id)
    targetStats = target.plainStats; highestStatValue = 0
    targetStats.each_value { |value| highestStatValue = value if highestStatValue < value }
		GameData::Stat.each_main_battle do |s|
			next if targetStats[s.id] < highestStatValue
			if @TargetIsAlly
				if !target.pbCanRaiseStatStage?(s.id, target)
					@battle.pbDisplay(_INTL("But it failed!"))
					return true 
				end
			else
				if !target.pbCanLowerStatStage?(s.id, target)
					@battle.pbDisplay(_INTL("But it failed!"))
					return true 
				end
			end
			break
		end
    return false
  end
	
  def pbEffectAgainstTarget(user,target)
    targetStats = target.plainStats
    highestStatValue = 0
    targetStats.each_value { |value| highestStatValue = value if highestStatValue < value }
		GameData::Stat.each_main_battle do |s|
			next if targetStats[s.id] < highestStatValue
			if @TargetIsAlly
				target.pbRaiseStatStage(s.id, 1, target, true) if target.pbCanRaiseStatStage?(s.id, target)
				target.SetupMovesUsed.push(@id)
			else
				target.pbLowerStatStage(s.id, 2, target, true) if target.pbCanLowerStatStage?(s.id, target)
			end
			break
		end
  end
end

#===============================================================================
# gets 3x on rain
# in theory it nullifies the nerfs/buffs of a fire type move on those weathers
# (Steam Burst)
#===============================================================================
# i hate pseudos btw
#===============================================================================
class Battle::Move::HigherDamageInRain < Battle::Move
  def pbBaseDamage(baseDmg,user,target)
    case @battle.pbWeather
    when :Rain, :HeavyRain
      baseDmg *= 1.5
      baseDmg *= 1.5
    end
    return baseDmg
  end
end

#===============================================================================
# Charges up user's next attack if it is Dragon-type. (Zealous Dance)
#===============================================================================
class Battle::Move::PowerUpDragonMove < Battle::Move
  def pbAdditionalEffect(user,target)
		if user.effects[PBEffects::ZealousDance] <= 0
			user.effects[PBEffects::ZealousDance] = 2
			@battle.pbDisplay(_INTL("{1} began preparing a devastating blow!", user.pbThis))
		end
  end
end

#===============================================================================
# Effectiveness against Steel-type is 2x. (Kinetic Rend)
#===============================================================================
class Battle::Move::SuperEffectiveAgainstSteel < Battle::Move
  def pbCalcTypeModSingle(moveType, defType, user, target)
    return Effectiveness::SUPER_EFFECTIVE_ONE if defType == :STEEL
    return super
  end
end


#===============================================================================
# Hits three to five times. (Queso Blast)
#===============================================================================
class Battle::Move::HitThreeToFiveTimes < Battle::Move
  def multiHitMove?; return true; end

  def pbNumHits(user, targets)
    if user.pbOwnedByPlayer?
      hitChances = [
        3, 3, 3, 3, 3, 3, 3, 3,
        4, 4, 4, 4, 
        5
      ]
    else
      hitChances = [
        4, 4, 4, 4, 4, 4, 4, 4,
        5, 5, 5, 5
      ]
    end
    r = @battle.pbRandom(hitChances.length)
    r = hitChances.length - 1 if user.hasActiveAbility?(:SKILLLINK)
    return hitChances[r]
  end
end


#===============================================================================
# Attacks 1 round in the future. (Premonition dummy move) # Premonition
#===============================================================================
class Battle::Move::AttackOneTurnLater < Battle::Move
  def pbMoveFailed?(user, targets)
    if user.premonitionMove == nil || user.premonitionMove == 0 # fail-safe
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
	
  def targetsPosition?; return true; end

  def pbDamagingMove?   # Stops damage being dealt in the setting-up turn
    return false if !@battle.futureSight
    return super
  end

  def pbAccuracyCheck(user, target)
    return true if !@battle.futureSight
    return super
  end

  def pbDisplayUseMessage(user)
    super if !@battle.futureSight
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    if !@battle.futureSight && @battle.positions[target.index].effects[PBEffects::FutureSightCounter] > 0
      #~ @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    return if @battle.futureSight   # Attack is hitting
    effects = @battle.positions[target.index].effects
    effects[PBEffects::FutureSightCounter]        = 2
    effects[PBEffects::FutureSightMove]           = user.premonitionMove
    effects[PBEffects::FutureSightUserIndex]      = user.index
    effects[PBEffects::FutureSightUserPartyIndex] = user.pokemonIndex
		#~ user.premonitionMove = 0
    @battle.pbDisplay(_INTL("{1} created an unstable temporal rift around {2}!", user.pbThis, target.pbThis))
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    hitNum = 1 if !@battle.futureSight   # Charging anim
    super
  end
end

#===============================================================================
# Deal damage, then:
# Replaces the target's status condition with Poison if the target's previous
# status condition was not Poison.
#===============================================================================
# "well it's a signature move so why not make it the most powerful thing ever"
#===============================================================================
class Battle::Move::OverrideTargetStatusWithPoison < Battle::Move
  def pbEffectAgainstTarget(user, target)
    return if target.damageState.substitute
		return if target.poisoned?
		if target.pbCanInflictStatus?(:POISON, user, false, self, true)
			if $game_variables[MECHANICSVAR] >= 3 && target.status != :NONE
				target.pbPoison(user, nil, false) 
			end
			if $game_variables[MECHANICSVAR] < 3
				target.pbPoison(user, nil, false)
			end
		end
  end
end

#===============================================================================
# Deals double damage if the opponent initial item belongs to the "choice" brand
# "Knocks Off" the opponent item if its a choice item
#===============================================================================
class Battle::Move::DoubleDamageIfTargetHasChoiceItem < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
		if target.item &&
			 [:CHOICEBAND, :CHOICESPECS, :CHOICESCARF].include?(target.initialItem)
			baseDmg = (baseDmg * 2).round
		end
    return baseDmg
  end

  def pbEffectAfterAllHits(user, target)
    return if user.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if ![:CHOICEBAND, :CHOICESPECS, :CHOICESCARF].include?(target.item)
    return if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
    itemName = target.itemName
    target.pbRemoveItem(false)
    @battle.pbDisplay(_INTL("{1} was persuaded to give up its {2}!", target.pbThis, itemName))
  end
end

#===============================================================================
# typo on function code is intentional (Pepper Spray)
#===============================================================================
class Battle::Move::PeperSpray < Battle::Move
  def pbTarget(user)
    return GameData::Target.get(:AllNearFoes) if [:Sun, :HarshSun].include?(user.effectiveWeather)
    return super
  end

  def pbBaseDamage(baseDmg, user, target)
    peper_dmg_mult = (@battle.field.abilityWeather) ? 5 / 4 : 4 / 3
    baseDmg *= peper_dmg_mult if [:Sun, :HarshSun].include?(user.effectiveWeather)
    return baseDmg
  end
end

#===============================================================================
# higher dmg during sun vs not fire types
# ignores desolate land vaporization vs non fire types (scald)
#===============================================================================
class Battle::Move::HigherDamageInSunVSNonFireTypes < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
		scald_damage_multiplier = (@battle.field.abilityWeather) ? 1.5 : 2
    baseDmg *= scald_damage_multiplier if user.effectiveWeather == :Sun && !target.pbHasType?(:FIRE)
    return baseDmg
  end
end

#===============================================================================
# Hits two times, ignores multi target debuff. (Splinter Shot)
#===============================================================================
class Battle::Move::HitTwoTimesReload < Battle::Move
  def pbDisplayChargeMessage(user)
    @battle.pbCommonAnimation("FocusPunch", user)
    @battle.pbDisplay(_INTL("{1} is reloading!", user.pbThis))
  end
  def multiHitMove?;            return true; end
  def pbNumHits(user, targets); return 2;    end
end

#===============================================================================
# Increases the damage recived from all sources by 25%. (Virus Inject)
#===============================================================================
class Battle::Move::BOOMInstall < Battle::Move
  def canMagicCoat?; return true; end
  
  def pbFailsAgainstTarget?(user,target,show_message)
    return if damagingMove?
    if target.effects[PBEffects::BoomInstalled]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
  end

  def pbEffectAgainstTarget(user, target)
    return if damagingMove?
    pbSEPlay("BOOM") if rand(2) == 0
    target.effects[PBEffects::BoomInstalled] = true
    @battle.pbDisplay(_INTL("{1}'s code was corrupted!", target.pbThis))
  end

  def pbAdditionalEffect(user, target)
    return if !damagingMove?
    return if target.effects[PBEffects::BoomInstalled]
    pbSEPlay("BOOM") if rand(2) == 0
    target.effects[PBEffects::BoomInstalled] = true
    @battle.pbDisplay(_INTL("{1}'s code was corrupted!", target.pbThis))
  end
end