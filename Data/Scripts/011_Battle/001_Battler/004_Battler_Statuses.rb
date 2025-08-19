class Battle::Battler
# added dizzy #by low
  #=============================================================================
  # Generalised checks for whether a status problem can be inflicted
  #=============================================================================
  # NOTE: Not all "does it have this status?" checks use this method. If the
  #       check is leading up to curing self of that status condition, then it
  #       will look at the value of @status directly instead - if it is that
  #       status condition then it is curable. This method only checks for
  #       "counts as having that status", which includes Comatose which can't be
  #       cured.
  def pbHasStatus?(checkStatus)
    if Battle::AbilityEffects.triggerStatusCheckNonIgnorable(self.ability, self, checkStatus)
      return true
    end
    return @status == checkStatus
  end

  def pbHasAnyStatus?
    if Battle::AbilityEffects.triggerStatusCheckNonIgnorable(self.ability, self, nil)
      return true
    end
    return @status != :NONE
  end

  def pbCanInflictStatus?(newStatus, user, showMessages, move = nil, ignoreStatus = false)
    #^ rewriten in 001_Battle Bug Fixes.rb
    return false if fainted?
    selfInflicted = (user && user.index == @index)
    # Already have that status problem
    if self.status == newStatus && !ignoreStatus
      if showMessages
        msg = ""
        case self.status
        when :SLEEP     then msg = _INTL("{1} is already asleep!", pbThis)
        when :POISON    then msg = _INTL("{1} is already poisoned!", pbThis)
        when :BURN      then msg = _INTL("{1} already has a burn!", pbThis)
        when :PARALYSIS then msg = _INTL("{1} is already paralyzed!", pbThis)
        when :FROZEN    then msg = _INTL("{1} already has frostbite!", pbThis)
        when :DIZZY     then msg = _INTL("{1} is already dizzy!", pbThis)
        end
        @battle.pbDisplay(msg)
      end
      return false
    end
    # Trying to replace a status problem with another one
    if self.status != :NONE && !ignoreStatus && !selfInflicted
      @battle.pbDisplay(_INTL("It doesn't affect {1}...", pbThis(true))) if showMessages
      return false
    end
    # Trying to inflict a status problem on a Pokémon behind a substitute
    if @effects[PBEffects::Substitute] > 0 && !(move && move.ignoresSubstitute?(user)) &&
       !selfInflicted
      @battle.pbDisplay(_INTL("It doesn't affect {1}...", pbThis(true))) if showMessages
      return false
    end
    # Weather immunity
    #~ if newStatus == :FROZEN && [:Sun, :HarshSun].include?(effectiveWeather)
      #~ @battle.pbDisplay(_INTL("It doesn't affect {1}...", pbThis(true))) if showMessages
      #~ return false
    #~ end
    # Terrains immunity
    if affectedByTerrain?
      case @battle.field.terrain
      when :Electric
        if newStatus == :SLEEP
          if showMessages
            @battle.pbDisplay(_INTL("{1} surrounds itself with electrified terrain!", pbThis(true)))
          end
          return false
        end
      when :Misty
        @battle.pbDisplay(_INTL("{1} surrounds itself with misty terrain!", pbThis(true))) if showMessages
        return false
      end
    end
    # Uproar immunity
    if newStatus == :SLEEP && !(hasActiveAbility?(:SOUNDPROOF) && !@battle.moldBreaker)
      @battle.allBattlers.each do |b|
        next if b.effects[PBEffects::Uproar] == 0
        @battle.pbDisplay(_INTL("But the uproar kept {1} awake!", pbThis(true))) if showMessages
        return false
      end
    end
    # Type immunities
    hasImmuneType = false
    case newStatus
    when :SLEEP
      # No type is immune to sleep
    when :POISON
      if !(user && user.hasActiveAbility?(:CORROSION))
        hasImmuneType |= pbHasType?(:POISON)
        hasImmuneType |= pbHasType?(:STEEL)
      end
    when :BURN
      hasImmuneType |= pbHasType?(:FIRE)
    when :PARALYSIS
      hasImmuneType |= pbHasType?(:ELECTRIC) && (Settings::MORE_TYPE_EFFECTS && !$game_switches[OLDSCHOOLBATTLE])
    when :FROZEN
      hasImmuneType |= pbHasType?(:ICE)
    when :DIZZY
      hasImmuneType |= pbHasType?(:PSYCHIC)
    end
    if hasImmuneType
      @battle.pbDisplay(_INTL("It doesn't affect {1}...", pbThis(true))) if showMessages
      return false
    end
    # Ability immunity
    immuneByAbility = false
    immAlly = nil
    if Battle::AbilityEffects.triggerStatusImmunityNonIgnorable(self.ability, self, newStatus)
      immuneByAbility = true
    elsif selfInflicted || !@battle.moldBreaker
      if abilityActive? && Battle::AbilityEffects.triggerStatusImmunity(self.ability, self, newStatus)
        immuneByAbility = true
      else
        allAllies.each do |b|
          next if !b.abilityActive?
          next if !Battle::AbilityEffects.triggerStatusImmunityFromAlly(b.ability, self, newStatus)
          immuneByAbility = true
          immAlly = b
          break
        end
      end
    end
    if immuneByAbility
      if showMessages
        @battle.pbShowAbilitySplash(immAlly || self)
        msg = ""
        if Battle::Scene::USE_ABILITY_SPLASH
          case newStatus
          when :SLEEP     then msg = _INTL("{1} stays awake!", pbThis)
          when :POISON    then msg = _INTL("{1} cannot be poisoned!", pbThis)
          when :BURN      then msg = _INTL("{1} cannot be burned!", pbThis)
          when :PARALYSIS then msg = _INTL("{1} cannot be paralyzed!", pbThis)
          when :FROZEN    then msg = _INTL("{1} cannot gain frostbite!", pbThis)
          when :DIZZY     then msg = _INTL("{1} cannot be dizzied!", pbThis)
          end
        elsif immAlly
          case newStatus
          when :SLEEP
            msg = _INTL("{1} stays awake because of {2}'s {3}!",
                        pbThis, immAlly.pbThis(true), immAlly.abilityName)
          when :POISON
            msg = _INTL("{1} cannot be poisoned because of {2}'s {3}!",
                        pbThis, immAlly.pbThis(true), immAlly.abilityName)
          when :BURN
            msg = _INTL("{1} cannot be burned because of {2}'s {3}!",
                        pbThis, immAlly.pbThis(true), immAlly.abilityName)
          when :PARALYSIS
            msg = _INTL("{1} cannot be paralyzed because of {2}'s {3}!",
                        pbThis, immAlly.pbThis(true), immAlly.abilityName)
          when :FROZEN
            msg = _INTL("{1} cannot be frostbitten because of {2}'s {3}!",
                        pbThis, immAlly.pbThis(true), immAlly.abilityName)
          when :DIZZY
            msg = _INTL("{1} cannot be dizzy because of {2}'s {3}!",
                        pbThis, immAlly.pbThis(true), immAlly.abilityName)
          end
        else
          case newStatus
          when :SLEEP     then msg = _INTL("{1} stays awake because of its {2}!", pbThis, abilityName)
          when :POISON    then msg = _INTL("{1}'s {2} prevents poisoning!", pbThis, abilityName)
          when :BURN      then msg = _INTL("{1}'s {2} prevents burns!", pbThis, abilityName)
          when :PARALYSIS then msg = _INTL("{1}'s {2} prevents paralysis!", pbThis, abilityName)
          when :FROZEN    then msg = _INTL("{1}'s {2} prevents frostbite!", pbThis, abilityName)
          when :DIZZY     then msg = _INTL("{1}'s {2} prevents dizziness!", pbThis, abilityName)
          end
        end
        @battle.pbDisplay(msg)
        @battle.pbHideAbilitySplash(immAlly || self)
      end
      return false
    end
    # Safeguard immunity
    if pbOwnSide.effects[PBEffects::Safeguard] > 0 && !selfInflicted && move &&
       !(user && user.hasActiveAbility?(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!", pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanSynchronizeStatus?(newStatus, target)
    return false if fainted?
    # Trying to replace a status problem with another one
    return false if self.status != :NONE
    # Terrain immunity
    return false if @battle.field.terrain == :Misty && affectedByTerrain?
    # Type immunities
    hasImmuneType = false
    case newStatus
    when :POISON
      # NOTE: target will have Synchronize, so it can't have Corrosion.
      if !(target && target.hasActiveAbility?(:CORROSION))
        hasImmuneType |= pbHasType?(:POISON)
        hasImmuneType |= pbHasType?(:STEEL)
      end
    when :BURN
      hasImmuneType |= pbHasType?(:FIRE)
    when :PARALYSIS
      hasImmuneType |= pbHasType?(:ELECTRIC) && (Settings::MORE_TYPE_EFFECTS && !$game_switches[OLDSCHOOLBATTLE])
    when :DIZZY
      hasImmuneType |= pbHasType?(:PSYCHIC)
    end
    return false if hasImmuneType
    # Ability immunity
    if Battle::AbilityEffects.triggerStatusImmunityNonIgnorable(self.ability, self, newStatus)
      return false
    end
    if abilityActive? && Battle::AbilityEffects.triggerStatusImmunity(self.ability, self, newStatus)
      return false
    end
    allAllies.each do |b|
      next if !b.abilityActive?
      next if !Battle::AbilityEffects.triggerStatusImmunityFromAlly(b.ability, self, newStatus)
      return false
    end
    # Safeguard immunity
    if pbOwnSide.effects[PBEffects::Safeguard] > 0 &&
       !(user && user.hasActiveAbility?(:INFILTRATOR))
      return false
    end
    return true
  end

  #=============================================================================
  # Generalised infliction of status problem
  #=============================================================================
  def pbInflictStatus(newStatus, newStatusCount = 0, msg = nil, user = nil)
    # Inflict the new status
    self.status      = newStatus
    self.statusCount = newStatusCount
    @effects[PBEffects::Toxic] = 0
    # Show animation
    if newStatus == :POISON && newStatusCount > 0
      @battle.pbCommonAnimation("Toxic", self)
    else
      anim_name = GameData::Status.get(newStatus).animation
      @battle.pbCommonAnimation(anim_name, self) if anim_name
    end
    # Show message
    if msg && !msg.empty?
      @battle.pbDisplay(msg)
    else
      case newStatus
      when :SLEEP
        @battle.pbDisplay(_INTL("{1} fell asleep!", pbThis))
      when :POISON
        if newStatusCount > 0
          @battle.pbDisplay(_INTL("{1} was badly poisoned!", pbThis))
        else
          @battle.pbDisplay(_INTL("{1} was poisoned!", pbThis))
        end
      when :BURN
        @battle.pbDisplay(_INTL("{1} was burned!", pbThis))
      when :PARALYSIS
        @battle.pbDisplay(_INTL("{1} is paralyzed! It may be unable to move!", pbThis))
      when :FROZEN
        @battle.pbDisplay(_INTL("{1} gained frostbite!", pbThis))
			when :DIZZY
        @battle.pbDisplay(_INTL("{1} became dizzy! It's ability has been nullified!", pbThis))
      end
    end
    PBDebug.log("[Status change] #{pbThis}'s sleep count is #{newStatusCount}") if newStatus == :SLEEP
    # Form change check
    pbCheckFormOnStatusChange
    # Synchronize
    if abilityActive?
      Battle::AbilityEffects.triggerOnStatusInflicted(self.ability, self, user, newStatus)
    end
    # Status cures
    pbItemStatusCureCheck
    pbAbilityStatusCureCheck
    # Petal Dance/Outrage/Thrash get cancelled immediately by falling asleep
    # NOTE: I don't know why this applies only to Outrage and only to falling
    #       asleep (i.e. it doesn't cancel Rollout/Uproar/other multi-turn
    #       moves, and it doesn't cancel any moves if self becomes frozen/
    #       disabled/anything else). This behaviour was tested in Gen 5.
    if @status == :SLEEP && @effects[PBEffects::Outrage] > 0
      @effects[PBEffects::Outrage] = 0
      @currentMove = nil
    end
  end

  #=============================================================================
  # Sleep
  #=============================================================================
  def asleep?
    return pbHasStatus?(:SLEEP)
  end

  def pbCanSleep?(user, showMessages, move = nil, ignoreStatus = false, restcheck = false)
    if pbHasStatusPokemon?(:SLEEP) && !restcheck && user.pbOwnedByPlayer? #by low
      @battle.pbDisplay(_INTL("But {1} couldn't sleep!", pbThis(true))) if showMessages
      return false
    end
    return pbCanInflictStatus?(:SLEEP, user, showMessages, move, ignoreStatus)
  end

  def pbCanSleepYawn?
    if pbHasStatusPokemon?(:SLEEP) #by low
      @battle.pbDisplay(_INTL("But {1} couldn't sleep!", pbThis(true)))
      return false
    end
    return false if self.status != :NONE
    if affectedByTerrain? && [:Electric, :Misty].include?(@battle.field.terrain)
      return false
    end
    if !hasActiveAbility?(:SOUNDPROOF) && @battle.allBattlers.any? { |b| b.effects[PBEffects::Uproar] > 0 }
      return false
    end
    if Battle::AbilityEffects.triggerStatusImmunityNonIgnorable(self.ability, self, :SLEEP)
      return false
    end
    # NOTE: Bulbapedia claims that Flower Veil shouldn't prevent sleep due to
    #       drowsiness, but I disagree because that makes no sense. Also, the
    #       comparable Sweet Veil does prevent sleep due to drowsiness.
    if abilityActive? && Battle::AbilityEffects.triggerStatusImmunity(self.ability, self, :SLEEP)
      return false
    end
    allAllies.each do |b|
      next if !b.abilityActive?
      next if !Battle::AbilityEffects.triggerStatusImmunityFromAlly(b.ability, self, :SLEEP)
      return false
    end
    # NOTE: Bulbapedia claims that Safeguard shouldn't prevent sleep due to
    #       drowsiness. I disagree with this too. Compare with the other sided
    #       effects Misty/Electric Terrain, which do prevent it.
    return false if pbOwnSide.effects[PBEffects::Safeguard] > 0
    return true
  end

  def pbSleep(msg = nil)
    pbInflictStatus(:SLEEP, pbSleepDuration, msg)
  end

  def pbSleepSelf(msg = nil, duration = -1)
    pbInflictStatus(:SLEEP, pbSleepDuration(duration), msg)
  end

  def pbSleepDuration(duration = -1, status = :None)
    #############################################
    # edits to be more consitent #by low
    # 2 turns of sleep, no matter who moved first
    #############################################
    duration = 3 if duration == -1
    duration -= 1 if @battle.choices[self.index][0] == :None && !self.movedThisRound?
    #############################################
    duration = (duration / 2).floor if hasActiveAbility?(:EARLYBIRD)
    duration = (duration / 2).floor if hasAbilityMutation? && status == :DIZZY
    return duration
  end

  #=============================================================================
  # Poison
  #=============================================================================
  def poisoned?
    return pbHasStatus?(:POISON)
  end

  def pbCanPoison?(user, showMessages, move = nil)
    return pbCanInflictStatus?(:POISON, user, showMessages, move)
  end

  def pbCanPoisonSynchronize?(target)
    return pbCanSynchronizeStatus?(:POISON, target)
  end

  def pbPoison(user = nil, msg = nil, toxic = false)
		if $player.difficulty_mode?("chaos") # on "low mode" #by low
			pbInflictStatus(:POISON, 1, msg, user)
		else
			pbInflictStatus(:POISON, (toxic) ? 1 : 0, msg, user)
		end
  end

  #=============================================================================
  # Burn
  #=============================================================================
  def burned?
    return pbHasStatus?(:BURN)
  end

  def pbCanBurn?(user, showMessages, move = nil)
    return pbCanInflictStatus?(:BURN, user, showMessages, move)
  end

  def pbCanBurnSynchronize?(target)
    return pbCanSynchronizeStatus?(:BURN, target)
  end

  def pbBurn(user = nil, msg = nil)
    pbInflictStatus(:BURN, 0, msg, user)
  end

  #=============================================================================
  # Paralyze
  #=============================================================================
  def paralyzed?
    return pbHasStatus?(:PARALYSIS)
  end

  def pbCanParalyze?(user, showMessages, move = nil)
    return pbCanInflictStatus?(:PARALYSIS, user, showMessages, move)
  end

  def pbCanParalyzeSynchronize?(target)
    return pbCanSynchronizeStatus?(:PARALYSIS, target)
  end

  def pbParalyze(user = nil, msg = nil)
		# paralyzis rework #by low
    pbInflictStatus(:PARALYSIS, ($player.difficulty_mode?("chaos")) ? pbSleepDuration(7) : 0, msg, user)
  end

  #=============================================================================
  # Freeze
  #=============================================================================
  def frozen?
    return pbHasStatus?(:FROZEN)
  end

  def pbCanFreeze?(user, showMessages, move = nil)
    return pbCanInflictStatus?(:FROZEN, user, showMessages, move)
  end

  def pbCanFreezeSynchronize?(target) #by low
    return pbCanSynchronizeStatus?(:FROZEN, target)
  end
	
  def pbFreeze(msg = nil)
    pbInflictStatus(:FROZEN, 0, msg)
  end

  #=============================================================================
  # Dizzy #by low
  #=============================================================================
  def dizzy?
    return pbHasStatus?(:DIZZY)
  end

  def pbCanDizzy?(user, showMessages = true, move = nil)
    return pbCanInflictStatus?(:DIZZY, user, showMessages, move)
  end

  def pbDizzy(user = nil, msg = nil)
    pbInflictStatus(:DIZZY, pbSleepDuration(-1, :DIZZY), msg, user)
  end

  #=============================================================================
  # Generalised status displays
  #=============================================================================
  def pbContinueStatus
    if self.status == :POISON && @statusCount > 0
      @battle.pbCommonAnimation("Toxic", self)
    else
      anim_name = GameData::Status.get(self.status).animation
      @battle.pbCommonAnimation(anim_name, self) if anim_name
    end
    yield if block_given?
    case self.status
    when :SLEEP
      @battle.pbDisplay(_INTL("{1} is fast asleep.", pbThis))
    when :POISON
			if @statusCount >= 2 #by low
				@battle.pbDisplay(_INTL("{1} was hurt badly by poison!", pbThis))
				@statusCount = 1
			else
				@battle.pbDisplay(_INTL("{1} was hurt by poison!", pbThis))
			end
    when :BURN
      @battle.pbDisplay(_INTL("{1} was hurt by its burn!", pbThis))
    when :PARALYSIS
      @battle.pbDisplay(_INTL("{1} is paralyzed! It can't move!", pbThis))
    when :FROZEN
      @battle.pbDisplay(_INTL("{1} was hurt by its frostbite!", pbThis))
    when :DIZZY
      @battle.pbDisplay(_INTL("{1} is dizzy!", pbThis))
    end
    PBDebug.log("[Status continues] #{pbThis}'s sleep count is #{@statusCount}") if self.status == :SLEEP
    PBDebug.log("[Status continues] #{pbThis}'s dizzy count is #{@statusCount}") if self.status == :DIZZY
  end

  def pbCureStatus(showMessages = true)
    oldStatus = status
    self.status = :NONE
    if showMessages
      case oldStatus
      when :SLEEP     then @battle.pbDisplay(_INTL("{1} woke up!", pbThis))
      when :POISON    then @battle.pbDisplay(_INTL("{1} was cured of its poisoning.", pbThis))
      when :BURN      then @battle.pbDisplay(_INTL("{1}'s burn was healed.", pbThis))
      when :PARALYSIS then @battle.pbDisplay(_INTL("{1} was cured of paralysis.", pbThis))
      when :FROZEN    then @battle.pbDisplay(_INTL("{1} thawed out!", pbThis))
      when :DIZZY     then @battle.pbDisplay(_INTL("{1} regained focus!", pbThis))
      end
    end
    PBDebug.log("[Status change] #{pbThis}'s status was cured") if !showMessages
  end

  #=============================================================================
  # Confusion
  #=============================================================================
  def pbCanConfuse?(user = nil, showMessages = true, move = nil, selfInflicted = false)
    return false if fainted?
		if $player.difficulty_mode?("chaos")
			return pbCanDizzy?(user, showMessages, move)
		end
		if pbHasType?(:PSYCHIC) #by low
			@battle.pbDisplay(_INTL("It doesn't affect {1}...", pbThis)) if showMessages
      return false
		end
    if @effects[PBEffects::Confusion] > 0
      @battle.pbDisplay(_INTL("{1} is already confused.", pbThis)) if showMessages
      return false
    end
    if @effects[PBEffects::Substitute] > 0 && !(move && move.ignoresSubstitute?(user)) &&
       !selfInflicted
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    # Terrains immunity
    if affectedByTerrain? && @battle.field.terrain == :Misty && Settings::MECHANICS_GENERATION >= 7
      @battle.pbDisplay(_INTL("{1} surrounds itself with misty terrain!", pbThis(true))) if showMessages
      return false
    end
    if (selfInflicted || !@battle.moldBreaker) && hasActiveAbility?(:OWNTEMPO)
      if showMessages
        @battle.pbShowAbilitySplash(self)
        if Battle::Scene::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} doesn't become confused!", pbThis))
        else
          @battle.pbDisplay(_INTL("{1}'s {2} prevents confusion!", pbThis, abilityName))
        end
        @battle.pbHideAbilitySplash(self)
      end
      return false
    end
    if pbOwnSide.effects[PBEffects::Safeguard] > 0 && !selfInflicted &&
       !(user && user.hasActiveAbility?(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!", pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanConfuseSelf?(showMessages)
    return pbCanConfuse?(nil, showMessages, nil, true)
  end

  def pbConfuse(msg = nil)
		if $player.difficulty_mode?("chaos")
			pbInflictStatus(:DIZZY, pbSleepDuration, msg) # this technically buffs early bird but i think its cool so i will leave it
		else
			@effects[PBEffects::Confusion] = pbConfusionDuration
			@battle.pbCommonAnimation("Confusion", self)
			msg = _INTL("{1} became confused!", pbThis) if nil_or_empty?(msg)
			@battle.pbDisplay(msg)
			PBDebug.log("[Lingering effect] #{pbThis}'s confusion count is #{@effects[PBEffects::Confusion]}")
			# Confusion cures
			pbItemStatusCureCheck
			pbAbilityStatusCureCheck
		end
  end

  def pbConfusionDuration(duration = -1)
    duration = 2 + @battle.pbRandom(4) if duration <= 0
    return duration
  end

  def pbCureConfusion
		if self.dizzy?
			self.status = :NONE
			@battle.pbDisplay(_INTL("{1} regained focus!", pbThis))
		else
			@effects[PBEffects::Confusion] = 0
		end
  end

  #=============================================================================
  # Attraction
  #=============================================================================
  def pbCanAttract?(user, showMessages = true)
    return false if fainted?
    return false if !user || user.fainted?
    if @effects[PBEffects::Attract] >= 0
      @battle.pbDisplay(_INTL("{1} is unaffected!", pbThis)) if showMessages
      return false
    end
    agender = user.gender
    ogender = gender
    if agender == 2 || ogender == 2 || agender == ogender
      @battle.pbDisplay(_INTL("{1} is unaffected!", pbThis)) if showMessages
      return false
    end
    if !@battle.moldBreaker
      if hasActiveAbility?([:AROMAVEIL, :OBLIVIOUS])
        if showMessages
          @battle.pbShowAbilitySplash(self)
          if Battle::Scene::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1} is unaffected!", pbThis))
          else
            @battle.pbDisplay(_INTL("{1}'s {2} prevents romance!", pbThis, abilityName))
          end
          @battle.pbHideAbilitySplash(self)
        end
        return false
      else
        allAllies.each do |b|
          next if !b.hasActiveAbility?(:AROMAVEIL)
          if showMessages
            @battle.pbShowAbilitySplash(self)
            if Battle::Scene::USE_ABILITY_SPLASH
              @battle.pbDisplay(_INTL("{1} is unaffected!", pbThis))
            else
              @battle.pbDisplay(_INTL("{1}'s {2} prevents romance!", b.pbThis, b.abilityName))
            end
            @battle.pbHideAbilitySplash(self)
          end
          return true
        end
      end
    end
    return true
  end

  def pbAttract(user, msg = nil)
    @effects[PBEffects::Attract] = user.index
    @battle.pbCommonAnimation("Attract", self)
    msg = _INTL("{1} fell in love!", pbThis) if nil_or_empty?(msg)
    @battle.pbDisplay(msg)
    # Destiny Knot
    if hasActiveItem?(:DESTINYKNOT) && user.pbCanAttract?(self, false)
      user.pbAttract(self, _INTL("{1} fell in love from the {2}!", user.pbThis(true), itemName))
    end
    # Attraction cures
    pbItemStatusCureCheck
    pbAbilityStatusCureCheck
  end

  def pbCureAttract
    @effects[PBEffects::Attract] = -1
  end

  #=============================================================================
  # Flinching
  #=============================================================================
  def pbFlinch(_user = nil, fakuout = false)
    return if hasActiveAbility?(:INNERFOCUS) && !@battle.moldBreaker
    # first turn immunity, no flinch, inner focus buff #by low
    return if @effects[PBEffects::NoFlinch] > 0
    allAllies.each do |b|
      break if !$player.difficulty_mode?("chaos")
      next unless b.hasActiveAbility?(:INNERFOCUS) && !@battle.moldBreaker
      return
    end
    return if @battle.turnCount == 0 && !fakuout
    @effects[PBEffects::Flinch] = true
    @effects[PBEffects::NoFlinch] = 2
  end
end
