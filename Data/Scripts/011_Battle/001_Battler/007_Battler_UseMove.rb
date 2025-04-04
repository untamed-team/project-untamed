class Battle::Battler
  #=============================================================================
  # Turn processing
  #=============================================================================
  def pbProcessTurn(choice, tryFlee = true)
    return false if fainted?
    # Wild roaming Pokémon always flee if possible
    if tryFlee && wild? &&
       @battle.rules["alwaysflee"] && @battle.pbCanRun?(@index)
      pbBeginTurn(choice)
      pbSEPlay("Battle flee")
      @battle.pbDisplay(_INTL("{1} fled from battle!", pbThis))
      @battle.decision = 3
      pbEndTurn(choice)
      return true
    end
    # Shift with the battler next to this one
    if choice[0] == :Shift
      idxOther = -1
      case @battle.pbSideSize(@index)
      when 2
        idxOther = (@index + 2) % 4
      when 3
        if @index != 2 && @index != 3   # If not in middle spot already
          idxOther = (@index.even?) ? 2 : 3
        end
      end
      if idxOther >= 0
        @battle.pbSwapBattlers(@index, idxOther)
        case @battle.pbSideSize(@index)
        when 2
          @battle.pbDisplay(_INTL("{1} moved across!", pbThis))
        when 3
          @battle.pbDisplay(_INTL("{1} moved to the center!", pbThis))
        end
      end
      pbBeginTurn(choice)
      pbCancelMoves
      @lastRoundMoved = @battle.turnCount   # Done something this round
      return true
    end
    # If this battler's action for this round wasn't "use a move"
    if choice[0] != :UseMove
      # Clean up effects that end at battler's turn
      pbBeginTurn(choice)
      pbEndTurn(choice)
      return false
    end
    # Use the move
    PBDebug.log("[Move usage] #{pbThis} started using #{choice[2].name}")
    PBDebug.logonerr {
      pbUseMove(choice, choice[2] == @battle.struggle)
    }
    @battle.pbJudge
    # Update priority order
    @battle.pbCalculatePriority if Settings::RECALCULATE_TURN_ORDER_AFTER_SPEED_CHANGES && !$game_switches[OLDSCHOOLBATTLE]
    return true
  end

  #=============================================================================
  #
  #=============================================================================
  def pbBeginTurn(_choice)
    # Cancel some lingering effects which only apply until the user next moves
    @effects[PBEffects::DestinyBondPrevious] = @effects[PBEffects::DestinyBond]
    @effects[PBEffects::DestinyBond]         = false
    @effects[PBEffects::Grudge]              = false
    @effects[PBEffects::MoveNext]            = false
    @effects[PBEffects::Quash]               = 0
    # Encore's effect ends if the encored move is no longer available
    if @effects[PBEffects::Encore] > 0 && pbEncoredMoveIndex < 0
      @effects[PBEffects::Encore]     = 0
      @effects[PBEffects::EncoreMove] = nil
    end
  end

  # Called when the usage of various multi-turn moves is disrupted due to
  # failing pbTryUseMove, being ineffective against all targets, or because
  # Pursuit was used specially to intercept a switching foe.
  # Cancels the use of multi-turn moves and counters thereof. Note that Hyper
  # Beam's effect is NOT cancelled.
  def pbCancelMoves(full_cancel = false)
    # Outragers get confused anyway if they are disrupted during their final
    # turn of using the move
    if @effects[PBEffects::Outrage] == 1 && pbCanConfuseSelf?(false) && !full_cancel
      pbConfuse(_INTL("{1} became confused due to fatigue!", pbThis))
    end
    # Cancel usage of most multi-turn moves
    @effects[PBEffects::TwoTurnAttack] = nil
    @effects[PBEffects::Rollout]       = 0
    @effects[PBEffects::Outrage]       = 0
    @effects[PBEffects::Uproar]        = 0
    @effects[PBEffects::Bide]          = 0
    @currentMove = nil
    # Reset counters for moves which increase them when used in succession
    @effects[PBEffects::FuryCutter] = 0
  end

  def pbEndTurn(_choice)
    @lastRoundMoved = @battle.turnCount   # Done something this round
    if !@effects[PBEffects::ChoiceBand] &&
       (hasActiveItem?([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF]) ||
       hasActiveAbility?(:GORILLATACTICS))
      if @lastMoveUsed && pbHasMove?(@lastMoveUsed)
        @effects[PBEffects::ChoiceBand] = @lastMoveUsed
      elsif @lastRegularMoveUsed && pbHasMove?(@lastRegularMoveUsed)
        @effects[PBEffects::ChoiceBand] = @lastRegularMoveUsed
      end
    end
    @effects[PBEffects::BeakBlast]   = false
    @effects[PBEffects::Charge]      = 0 if @effects[PBEffects::Charge] == 1
    @effects[PBEffects::GemConsumed] = nil
    @effects[PBEffects::ShellTrap]   = false
    @battle.allBattlers.each { |b| b.pbContinualAbilityChecks }   # Trace, end primordial weathers
  end

  def pbConfusionDamage(msg)
    @damageState.reset
    confusionMove = Battle::Move::Confusion.new(@battle, nil)
    confusionMove.calcType = confusionMove.pbCalcType(self)   # nil
    @damageState.typeMod = confusionMove.pbCalcTypeMod(confusionMove.calcType, self, self)   # 8
    confusionMove.pbCheckDamageAbsorption(self, self)
    confusionMove.pbCalcDamage(self, self)
    confusionMove.pbReduceDamage(self, self)
    self.hp -= @damageState.hpLost
    confusionMove.pbAnimateHitAndHPLost(self, [self])
    @battle.pbDisplay(msg)   # "It hurt itself in its confusion!"
    confusionMove.pbRecordDamageLost(self, self)
    confusionMove.pbEndureKOMessage(self)
    pbFaint if fainted?
    pbItemHPHealCheck
  end

  #=============================================================================
  # Simple "use move" method, used when a move calls another move and for Future
  # Sight's attack
  #=============================================================================
  def pbUseMoveSimple(moveID, target = -1, idxMove = -1, specialUsage = true)
    choice = []
    choice[0] = :UseMove   # "Use move"
    choice[1] = idxMove    # Index of move to be used in user's moveset
    if idxMove >= 0
      choice[2] = @moves[idxMove]
    else
      choice[2] = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(moveID))
      choice[2].pp = -1
    end
    choice[3] = target     # Target (-1 means no target yet)
    PBDebug.log("[Move usage] #{pbThis} started using the called/simple move #{choice[2].name}")
    pbUseMove(choice, specialUsage)
  end

  #=============================================================================
  # Master "use move" method
  #=============================================================================
  def pbUseMove(choice, specialUsage = false)
    # NOTE: This is intentionally determined before a multi-turn attack can
    #       set specialUsage to true.
    skipAccuracyCheck = (specialUsage && choice[2] != @battle.struggle)
    # Start using the move
    pbBeginTurn(choice)
    # Force the use of certain moves if they're already being used
    if usingMultiTurnAttack?
      choice[2] = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(@currentMove))
      specialUsage = true
    elsif @effects[PBEffects::Encore] > 0 && choice[1] >= 0 &&
          @battle.pbCanShowCommands?(@index)
      idxEncoredMove = pbEncoredMoveIndex
      if idxEncoredMove >= 0 && choice[1] != idxEncoredMove &&
         @battle.pbCanChooseMove?(@index, idxEncoredMove, false)   # Change move if battler was Encored mid-round
        choice[1] = idxEncoredMove
        choice[2] = @moves[idxEncoredMove]
        choice[3] = -1   # No target chosen
      end
    end
    # Labels the move being used as "move"
    move = choice[2]
    return if !move   # if move was not chosen somehow
    # Try to use the move (inc. disobedience)
    @lastMoveFailed = false
    if !pbTryUseMove(choice, move, specialUsage, skipAccuracyCheck)
      @lastMoveUsed     = nil
      @lastMoveUsedType = nil
      if !specialUsage
        @lastRegularMoveUsed   = nil
        @lastRegularMoveTarget = -1
      end
      @battle.pbGainExp   # In case self is KO'd due to confusion
      pbCancelMoves
      pbEndTurn(choice)
      return
    end
    move = choice[2]   # In case disobedience changed the move to be used
    return if !move   # if move was not chosen somehow
    # Subtract PP
    if !specialUsage && !pbReducePP(move)
      @battle.pbDisplay(_INTL("{1} used {2}!", pbThis, move.name))
      @battle.pbDisplay(_INTL("But there was no PP left for the move!"))
      @lastMoveUsed          = nil
      @lastMoveUsedType      = nil
      @lastRegularMoveUsed   = nil
      @lastRegularMoveTarget = -1
      @lastMoveFailed        = true
      pbCancelMoves
      pbEndTurn(choice)
      return
    end
    # Stance Change
    if isSpecies?(:AEGISLASH) && self.ability == :STANCECHANGE
      if move.damagingMove?
        pbChangeForm(1, _INTL("{1} changed to Blade Forme!", pbThis))
      elsif move.id == :KINGSSHIELD
        pbChangeForm(0, _INTL("{1} changed to Shield Forme!", pbThis))
      end
    end
    # Presage #by low (placed here so it triggers before doing damage)
    if self.hasActiveAbility?(:PRESAGE)
      if move.function == "TypeAndPowerDependOnWeather"
        possible_weathers = [:Sun, :Rain, :Sandstorm, :Hail, :StrongWinds, :ShadowSky]
        new_weather = possible_weathers[@battle.pbRandom(possible_weathers.length)] if $player.difficulty_mode?("easy")
      else
        weather_hash = {
          "RaiseUserAtkSpAtk1Or2InSun" => :Sun, # growth
          "HealUserDependingOnWeather" => :Sun, # morning sun
          "TwoTurnAttackOneTurnInSun"  => :Sun, # solar beam / solar blade
          "FreezeTargetAlwaysHitsInHail" => :Hail, # blizzard
          "HealUserDependingOnHail"      => :Hail, # glacial gulf
          "HealUserDependingOnSandstorm" => :Sandstorm, # shore up
          "StartUserSideDoubleSpeed"     => :StrongWinds,  # tailwind
          "ConfuseTargetAlwaysHitsInRainHitsTargetInSky"  => :Rain, # hurricane
          "ParalyzeTargetAlwaysHitsInRainHitsTargetInSky" => :Rain, # thunder
          "HigherDamageInRain"                            => :Rain, # stream burst
          "HigherDamageInSunVSNonFireTypes"               => :Sun,  # scald
          "PeperSpray"                                    => :Sun   # pepper spray
        }
        new_weather = weather_hash[move.function]
        if !new_weather && move.damagingMove?
          case move.type
            when :FIRE
              new_weather = :Sun
            when :WATER
              new_weather = :Rain
            when :ICE
              new_weather = :Hail
            when :GROUND, :ROCK
              new_weather = :Sandstorm
            when :NORMAL
              new_weather = :None
            when :QMARKS
              new_weather = :ShadowSky
          end
        end
      end
      battle.pbStartWeatherAbility(new_weather, self, false, true) if new_weather
    end
    # Calculate the move's type during this usage
    move.calcType = move.pbCalcType(self)
    # Start effect of Mold Breaker
    @battle.moldBreaker = hasMoldBreaker?
    # Remember that user chose a two-turn move
    if move.pbIsChargingTurn?(self)
      # Beginning the use of a two-turn attack
      @effects[PBEffects::TwoTurnAttack] = move.id
      @currentMove = move.id
    else
      @effects[PBEffects::TwoTurnAttack] = nil   # Cancel use of two-turn attack
    end
    # Add to counters for moves which increase them when used in succession
    move.pbChangeUsageCounters(self, specialUsage)
    # Charge up Metronome item or Momentum ability #by low
    if !move.callsAnotherMove? && (@lastMoveUsed && @lastMoveUsed == move.id && !@lastMoveFailed)
      if hasActiveItem?(:METRONOME)
        @effects[PBEffects::Metronome] += 1
			end
      if hasActiveAbility?(:MOMENTUM)
        @effects[PBEffects::Momentum] += 1
			end
    else
			if hasActiveItem?(:METRONOME)
        @effects[PBEffects::Metronome] = 0
      end
			if hasActiveAbility?(:MOMENTUM)
        @effects[PBEffects::Momentum] = 0
      end
    end
    # Record move as having been used
    @lastMoveUsed     = move.id
    @lastMoveUsedType = move.calcType   # For Conversion 2
    if !specialUsage
      @lastRegularMoveUsed   = move.id   # For Disable, Encore, Instruct, Mimic, Mirror Move, Sketch, Spite
      @lastRegularMoveTarget = choice[3]   # For Instruct (remembering original target is fine)
      @movesUsed.push(move.id) if !@movesUsed.include?(move.id)   # For Last Resort
    end
    @battle.lastMoveUsed = move.id   # For Copycat
    @battle.lastMoveUser = @index   # For "self KO" battle clause to avoid draws
    @battle.successStates[@index].useState = 1   # Battle Arena - assume failure
    # Find the default user (self or Snatcher) and target(s)
    user = pbFindUser(choice, move)
    user = pbChangeUser(choice, move, user)
    targets = pbFindTargets(choice, move, user)
    targets = pbChangeTargets(move, user, targets)
		# double pp move flag / Cologne Case #by low
		user.pbReducePP(move) if move.doublePPMove?
		user.pbReducePP(move) if user.hasActiveItem?(:COLOGNECASE) && move.healingMove?
		user.pbReducePP(move) if $game_variables[MASTERMODEVARS][13]==true && self.pbOwnedByPlayer?
    # Pressure
    if !specialUsage
      targets.each do |b|
        next unless b.opposes?(user) && b.hasActiveAbility?(:PRESSURE)
        PBDebug.log("[Ability triggered] #{b.pbThis}'s #{b.abilityName}")
        user.pbReducePP(move)
      end
      if move.pbTarget(user).affects_foe_side
        @battle.allOtherSideBattlers(user).each do |b|
          next unless b.hasActiveAbility?(:PRESSURE)
          PBDebug.log("[Ability triggered] #{b.pbThis}'s #{b.abilityName}")
          user.pbReducePP(move)
        end
      end
    end
    # Dazzling/Queenly Majesty make the move fail here
    @battle.pbPriority(true).each do |b|
      next if !b || !b.abilityActive?
      if Battle::AbilityEffects.triggerMoveBlocking(b.ability, b, user, targets, move, @battle)
        @battle.pbDisplayBrief(_INTL("{1} used {2}!", user.pbThis, move.name))
        @battle.pbShowAbilitySplash(b)
        @battle.pbDisplay(_INTL("{1} cannot use {2}!", user.pbThis, move.name))
        @battle.pbHideAbilitySplash(b)
        user.lastMoveFailed = true
        pbCancelMoves
        pbEndTurn(choice)
        return
      end
    end
    # "X used Y!" message
    # Can be different for Bide, Fling, Focus Punch and Future Sight
    # NOTE: This intentionally passes self rather than user. The user is always
    #       self except if Snatched, but this message should state the original
    #       user (self) even if the move is Snatched.
    move.pbDisplayUseMessage(self) if move.id != :PREMONITIONMOVE # Premonition #by low
    # Snatch's message (user is the new user, self is the original user)
    if move.snatched
      @lastMoveFailed = true   # Intentionally applies to self, not user
      @battle.pbDisplay(_INTL("{1} snatched {2}'s move!", user.pbThis, pbThis(true)))
    end
    # "But it failed!" checks
    if move.pbMoveFailed?(user, targets)
      PBDebug.log(sprintf("[Move failed] In function code %s's def pbMoveFailed?", move.function))
      user.lastMoveFailed = true
      pbCancelMoves
      pbEndTurn(choice)
      return
    end
    # Perform set-up actions and display messages
    # Messages include Magnitude's number and Pledge moves' "it's a combo!"
    move.pbOnStartUse(user, targets)
    # Self-thawing due to the move
    # Powder
    if user.effects[PBEffects::Powder] && move.calcType == :FIRE && move.damagingMove?
      @battle.pbCommonAnimation("Powder", user)
      @battle.pbDisplay(_INTL("When the flame touched the powder on the Pokémon, it exploded!"))
      user.lastMoveFailed = true
      if ![:HeavyRain].include?(user.effectiveWeather) && user.takesIndirectDamage?
        user.pbTakeEffectDamage((user.totalhp / 4.0).round, false) { |hp_lost|
          @battle.pbDisplay(_INTL("{1} was hurt!", user.pbThis))
        }
        @battle.pbGainExp   # In case user is KO'd by this
      end
      pbCancelMoves
      pbEndTurn(choice)
      return
    end
    # Primordial Sea, Desolate Land
    if move.damagingMove?
      case @battle.pbWeather
      when :HeavyRain
        if move.calcType == :FIRE
          @battle.pbDisplay(_INTL("The Fire-type attack fizzled out in the heavy rain!"))
          user.lastMoveFailed = true
          pbCancelMoves
          pbEndTurn(choice)
          return
        end
      when :HarshSun
				# scald rework #by low
				targetisonfire = false # dont make scald spread kthx
				targets.each do |b|
					next if !b.pbHasType?(:FIRE)
					targetisonfire = true
				end
        if move.calcType == :WATER && !(move.function == "HigherDamageInSunVSNonFireTypes" && !targetisonfire)
          @battle.pbDisplay(_INTL("The Water-type attack evaporated in the harsh sunlight!"))
          user.lastMoveFailed = true
          pbCancelMoves
          pbEndTurn(choice)
          return
        end
      end
    end
    # Protean
    if user.hasActiveAbility?([:LIBERO, :PROTEAN]) &&
       !move.callsAnotherMove? && !move.snatched &&
       user.pbHasOtherType?(move.calcType) && !GameData::Type.get(move.calcType).pseudo_type
      @battle.pbShowAbilitySplash(user)
      user.pbChangeTypes(move.calcType)
      typeName = GameData::Type.get(move.calcType).name
      @battle.pbDisplay(_INTL("{1}'s type changed to {2}!", user.pbThis, typeName))
      @battle.pbHideAbilitySplash(user)
      # NOTE: The GF games say that if Curse is used by a non-Ghost-type
      #       Pokémon which becomes Ghost-type because of Protean, it should
      #       target and curse itself. I think this is silly, so I'm making it
      #       choose a random opponent to curse instead.
      if move.function == "CurseTargetOrLowerUserSpd1RaiseUserAtkDef1" && targets.length == 0
        choice[3] = -1
        targets = pbFindTargets(choice, move, user)
      end
    end
    #---------------------------------------------------------------------------
    magicCoater  = -1
    magicBouncer = -1
    if targets.length == 0 && move.pbTarget(user).num_targets > 0 && !move.worksWithNoTargets?
      # def pbFindTargets should have found a target(s), but it didn't because
      # they were all fainted
      # All target types except: None, User, UserSide, FoeSide, BothSides
      @battle.pbDisplay(_INTL("But there was no target..."))
      user.lastMoveFailed = true
    else   # We have targets, or move doesn't use targets
      # Reset whole damage state, perform various success checks (not accuracy)
      @battle.allBattlers.each do |b|
        b.droppedBelowHalfHP = false
        b.statsDropped = false
      end
      targets.each do |b|
        b.damageState.reset
        next if pbSuccessCheckAgainstTarget(move, user, b, targets)
        b.damageState.unaffected = true
      end
      # Magic Coat/Magic Bounce checks (for moves which don't target Pokémon)
      if targets.length == 0 && move.statusMove? && move.canMagicCoat?
        @battle.pbPriority(true).each do |b|
          next if b.fainted? || !b.opposes?(user)
          next if b.semiInvulnerable?
          if b.effects[PBEffects::MagicCoat]
            magicCoater = b.index
            b.effects[PBEffects::MagicCoat] = false
            break
          elsif b.hasActiveAbility?(:MAGICBOUNCE) && !@battle.moldBreaker &&
                !b.effects[PBEffects::MagicBounce]
            magicBouncer = b.index
            b.effects[PBEffects::MagicBounce] = true
            break
          end
        end
      end
      # Get the number of hits
      numHits = move.pbNumHits(user, targets)
      # Process each hit in turn
      realNumHits = 0
      numHits.times do |i|
        break if magicCoater >= 0 || magicBouncer >= 0
        success = pbProcessMoveHit(move, user, targets, i, skipAccuracyCheck)
        if !success
          if i == 0 && targets.length > 0
            hasFailed = false
            targets.each do |t|
              next if t.damageState.protected
              hasFailed = t.damageState.unaffected
              break if !t.damageState.unaffected
            end
            user.lastMoveFailed = hasFailed
          end
          break
        end
        realNumHits += 1
        break if user.fainted?
        break if [:SLEEP].include?(user.status)
        # NOTE: If a multi-hit move becomes disabled partway through doing those
        #       hits (e.g. by Cursed Body), the rest of the hits continue as
        #       normal.
        break if targets.none? { |t| !t.fainted? }   # All targets are fainted
      end
      # Battle Arena only - attack is successful
      @battle.successStates[user.index].useState = 2
      if targets.length > 0
        @battle.successStates[user.index].typeMod = 0
        targets.each do |b|
          next if b.damageState.unaffected
          @battle.successStates[user.index].typeMod += b.damageState.typeMod
        end
      end
      # Effectiveness message for multi-hit moves
      # NOTE: No move is both multi-hit and multi-target, and the messages below
      #       aren't quite right for such a hypothetical move.
      if numHits > 1
        if move.damagingMove?
          targets.each do |b|
            next if b.damageState.unaffected || b.damageState.substitute
            move.pbEffectivenessMessage(user, b, targets.length)
          end
        end
        # ignore the normal multi hit text Splinter Shot #by low
        if move.function != "HitTwoTimesReload"
          if realNumHits == 1
            @battle.pbDisplay(_INTL("Hit 1 time!"))
          elsif realNumHits > 1
            @battle.pbDisplay(_INTL("Hit {1} times!", realNumHits))
          end
        end
      end
      # Magic Coat's bouncing back (move has targets)
      targets.each do |b|
        next if b.fainted?
        next if !b.damageState.magicCoat && !b.damageState.magicBounce
        @battle.pbShowAbilitySplash(b) if b.damageState.magicBounce
        @battle.pbDisplay(_INTL("{1} bounced the {2} back!", b.pbThis, move.name))
        @battle.pbHideAbilitySplash(b) if b.damageState.magicBounce
        newChoice = choice.clone
        newChoice[3] = user.index
        newTargets = pbFindTargets(newChoice, move, b)
        newTargets = pbChangeTargets(move, b, newTargets)
        success = false
        if !move.pbMoveFailed?(b, newTargets)
          newTargets.each_with_index do |newTarget, idx|
            if pbSuccessCheckAgainstTarget(move, b, newTarget, newTargets)
              success = true
              next
            end
            newTargets[idx] = nil
          end
          newTargets.compact!
        end
        pbProcessMoveHit(move, b, newTargets, 0, false) if success
        b.lastMoveFailed = true if !success
        targets.each { |otherB| otherB.pbFaint if otherB&.fainted? }
        user.pbFaint if user.fainted?
      end
      # Magic Coat's bouncing back (move has no targets)
      if magicCoater >= 0 || magicBouncer >= 0
        mc = @battle.battlers[(magicCoater >= 0) ? magicCoater : magicBouncer]
        if !mc.fainted?
          user.lastMoveFailed = true
          @battle.pbShowAbilitySplash(mc) if magicBouncer >= 0
          @battle.pbDisplay(_INTL("{1} bounced the {2} back!", mc.pbThis, move.name))
          @battle.pbHideAbilitySplash(mc) if magicBouncer >= 0
          success = false
          if !move.pbMoveFailed?(mc, [])
            success = pbProcessMoveHit(move, mc, [], 0, false)
          end
          mc.lastMoveFailed = true if !success
          targets.each { |b| b.pbFaint if b&.fainted? }
          user.pbFaint if user.fainted?
        end
      end
      # Move-specific effects after all hits
      targets.each { |b| move.pbEffectAfterAllHits(user, b) }
      # Faint if 0 HP
      targets.each { |b| b.pbFaint if b&.fainted? }
      user.pbFaint if user.fainted?
      # External/general effects after all hits. Eject Button, Shell Bell, etc.
      pbEffectsAfterMove(user, targets, move, realNumHits)
      @battle.allBattlers.each do |b|
        b.droppedBelowHalfHP = false
        b.statsDropped = false
      end
    end
    # End effect of Mold Breaker
    @battle.moldBreaker = false
    # Gain Exp
    @battle.pbGainExp
    # Battle Arena only - update skills
    @battle.allBattlers.each { |b| @battle.successStates[b.index].updateSkill }
    # Shadow Pokémon triggering Hyper Mode
    pbHyperMode if @battle.choices[@index][0] != :None   # Not if self is replaced
    # End of move usage
    pbEndTurn(choice)
    # Instruct
    @battle.allBattlers.each do |b|
      next if !b.effects[PBEffects::Instruct] || !b.lastMoveUsed
      b.effects[PBEffects::Instruct] = false
      idxMove = -1
      b.eachMoveWithIndex { |m, i| idxMove = i if m.id == b.lastMoveUsed }
      next if idxMove < 0
      oldLastRoundMoved = b.lastRoundMoved
      @battle.pbDisplay(_INTL("{1} used the move instructed by {2}!", b.pbThis, user.pbThis(true)))
      b.effects[PBEffects::Instructed] = true
      if b.pbCanChooseMove?(@moves[idxMove], false)
        PBDebug.logonerr {
          b.pbUseMoveSimple(b.lastMoveUsed, b.lastRegularMoveTarget, idxMove, false)
        }
        b.lastRoundMoved = oldLastRoundMoved
        @battle.pbJudge
        return if @battle.decision > 0
      end
      b.effects[PBEffects::Instructed] = false
    end
    # Dancer
    if !@effects[PBEffects::Dancer] && !user.lastMoveFailed && realNumHits > 0 &&
       !move.snatched && magicCoater < 0 && @battle.pbCheckGlobalAbility(:DANCER) &&
       move.danceMove?
      dancers = []
      @battle.pbPriority(true).each do |b|
        dancers.push(b) if b.index != user.index && b.hasActiveAbility?(:DANCER)
      end
      while dancers.length > 0
        nextUser = dancers.pop
        oldLastRoundMoved = nextUser.lastRoundMoved
        # NOTE: Petal Dance being used because of Dancer shouldn't lock the
        #       Dancer into using that move, and shouldn't contribute to its
        #       turn counter if it's already locked into Petal Dance.
        oldOutrage = nextUser.effects[PBEffects::Outrage]
        nextUser.effects[PBEffects::Outrage] += 1 if nextUser.effects[PBEffects::Outrage] > 0
        oldCurrentMove = nextUser.currentMove
        preTarget = choice[3]
        preTarget = user.index if nextUser.opposes?(user) || !nextUser.opposes?(preTarget)
        @battle.pbShowAbilitySplash(nextUser, true)
        @battle.pbHideAbilitySplash(nextUser)
        if !Battle::Scene::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} kept the dance going with {2}!",
                                  nextUser.pbThis, nextUser.abilityName))
        end
        nextUser.effects[PBEffects::Dancer] = true
        if nextUser.pbCanChooseMove?(move, false)
          PBDebug.logonerr {
            nextUser.pbUseMoveSimple(move.id, preTarget)
          }
          nextUser.lastRoundMoved = oldLastRoundMoved
          nextUser.effects[PBEffects::Outrage] = oldOutrage
          nextUser.currentMove = oldCurrentMove
          @battle.pbJudge
          return if @battle.decision > 0
        end
        nextUser.effects[PBEffects::Dancer] = false
      end
    end
    # Premonition
		if user.hasActiveAbility?(:PREMONITION) && 
       !move.callsAnotherMove? && !move.snatched && move.damagingMove? && 
       !@battle.futureSight && targets.length == 1 && !user.lastMoveFailed && 
       !targets[0].damageState.missed && user.pbHasType?(move.calcType) #&& user.premonitionMove != move.id
			
			oldLastRoundMoved = user.lastRoundMoved
			oldOutrage = user.effects[PBEffects::Outrage]
			oldOutrage += 1 if user.effects[PBEffects::Outrage] > 0
			oldCurrentMove = user.currentMove
			user.premonitionMove = move.id
			
      #set up a dummy move and call Premonition
      dummy_move = Pokemon::Move.new(:PREMONITIONMOVE)
			#~ @battle.pbDisplayPaused(_INTL("move {1}",move.id))
			#~ @battle.pbDisplayPaused(_INTL("dum {1}",dummy_move.id))
			if user.pbCanChooseMove?(move, false)
				@battle.pbShowAbilitySplash(user)
        preTarget = choice[3]
        preTarget = user.index if user.opposes?(user) || !user.opposes?(preTarget)
				user.pbUseMoveSimple(dummy_move.id, preTarget)
				user.lastRoundMoved = oldLastRoundMoved
				user.effects[PBEffects::Outrage] = oldOutrage
				user.currentMove = dummy_move
				@battle.pbJudge
				@battle.pbHideAbilitySplash(user)
				return if @battle.decision > 0
			end
      return if @battle.decision > 0
    end
		# switch abuse prevention #by low
		user.pbOwnSide.effects[PBEffects::SwitchAbuse] = 0
	end

  #=============================================================================
  # Attack a single target
  #=============================================================================
  def pbProcessMoveHit(move, user, targets, hitNum, skipAccuracyCheck)
    return false if user.fainted?
    # For two-turn attacks being used in a single turn
    move.pbInitialEffect(user, targets, hitNum)
    numTargets = 0   # Number of targets that are affected by this hit
    # Count a hit for Parental Bond (if it applies)
    user.effects[PBEffects::ParentalBond] -= 1 if user.effects[PBEffects::ParentalBond] > 0
    # Accuracy check (accuracy/evasion calc)
    if hitNum == 0 || move.successCheckPerHit?
      targets.each do |b|
        b.damageState.missed = false
        next if b.damageState.unaffected
        if pbSuccessCheckPerHit(move, user, b, skipAccuracyCheck)
          numTargets += 1
        else
          b.damageState.missed     = true
          b.damageState.unaffected = true
        end
      end
      # If failed against all targets
      if targets.length > 0 && numTargets == 0 && !move.worksWithNoTargets?
        targets.each do |b|
          next if !b.damageState.missed || b.damageState.magicCoat
          pbMissMessage(move, user, b)
          if user.itemActive?
            Battle::ItemEffects.triggerOnMissingTarget(user.item, user, b, move, hitNum, @battle)
          end
          break if move.pbRepeatHit?   # Dragon Darts only shows one failure message
        end
        move.pbCrashDamage(user)
        user.pbItemHPHealCheck
        pbCancelMoves
        return false
      end
    end
    # If we get here, this hit will happen and do something
    all_targets = targets
    targets = move.pbDesignateTargetsForHit(targets, hitNum)   # For Dragon Darts
    targets.each { |b| b.damageState.resetPerHit }
    #---------------------------------------------------------------------------
    # Calculate damage to deal
    if move.pbDamagingMove?
      targets.each do |b|
        next if b.damageState.unaffected
        # Check whether Substitute/Disguise will absorb the damage
        move.pbCheckDamageAbsorption(user, b)
        # Calculate the damage against b
        # pbCalcDamage shows the "eat berry" animation for SE-weakening
        # berries, although the message about it comes after the additional
        # effect below
        move.pbCalcDamage(user, b, targets.length)   # Stored in damageState.calcDamage
				# premonition garbage #by low
				b.damageState.calcDamage /= 2 if @battle.futureSight && move.id != :FUTURESIGHT && move.id != :DOOMDESIRE
        # Lessen damage dealt because of False Swipe/Endure/etc.
        move.pbReduceDamage(user, b)   # Stored in damageState.hpLost
      end
    end
    # Show move animation (for this hit)
    move.pbShowAnimation(move.id, user, targets, hitNum)
    # Type-boosting Gem consume animation/message
    if user.effects[PBEffects::GemConsumed] && hitNum == 0
      # NOTE: The consume animation and message for Gems are shown now, but the
      #       actual removal of the item happens in def pbEffectsAfterMove.
      @battle.pbCommonAnimation("UseItem", user)
      @battle.pbDisplay(_INTL("The {1} strengthened {2}'s power!",
                              GameData::Item.get(user.effects[PBEffects::GemConsumed]).name, move.name))
    end
    # Messages about missed target(s) (relevant for multi-target moves only)
    if !move.pbRepeatHit?
      targets.each do |b|
        next if !b.damageState.missed
        pbMissMessage(move, user, b)
        if user.itemActive?
          Battle::ItemEffects.triggerOnMissingTarget(user.item, user, b, move, hitNum, @battle)
        end
      end
    end
    # Deal the damage (to all allies first simultaneously, then all foes
    # simultaneously)
    if move.pbDamagingMove?
      # This just changes the HP amounts and does nothing else
      targets.each { |b| move.pbInflictHPDamage(b) if !b.damageState.unaffected }
      # Animate the hit flashing and HP bar changes
      move.pbAnimateHitAndHPLost(user, targets)
    end
    # Self-Destruct/Explosion's damaging and fainting of user
    move.pbSelfKO(user) if hitNum == 0
    user.pbFaint if user.fainted?
    if move.pbDamagingMove?
      targets.each do |b|
        next if b.damageState.unaffected
        # NOTE: This method is also used for the OHKO special message.
        move.pbHitEffectivenessMessages(user, b, targets.length)
        # Record data about the hit for various effects' purposes
        move.pbRecordDamageLost(user, b)
      end
      # Close Combat/Superpower's stat-lowering, Flame Burst's splash damage,
      # and Incinerate's berry destruction
      targets.each do |b|
        next if b.damageState.unaffected
        move.pbEffectWhenDealingDamage(user, b)
      end
      # Ability/item effects such as Static/Rocky Helmet, and Grudge, etc.
      targets.each do |b|
        next if b.damageState.unaffected
        pbEffectsOnMakingHit(move, user, b)
      end
      # Disguise/Endure/Sturdy/Focus Sash/Focus Band messages
      targets.each do |b|
        next if b.damageState.unaffected
        move.pbEndureKOMessage(b)
      end
      # HP-healing held items (checks all battlers rather than just targets
      # because Flame Burst's splash damage affects non-targets)
      @battle.pbPriority(true).each { |b| b.pbItemHPHealCheck }
      # Animate battlers fainting (checks all battlers rather than just targets
      # because Flame Burst's splash damage affects non-targets)
      @battle.pbPriority(true).each { |b| b.pbFaint if b&.fainted? }
    end
    @battle.pbJudgeCheckpoint(user, move)
    # Main effect (recoil/drain, etc.)
    targets.each do |b|
      next if b.damageState.unaffected
      move.pbEffectAgainstTarget(user, b)
    end
    move.pbEffectGeneral(user)
    targets.each { |b| b.pbFaint if b&.fainted? }
    user.pbFaint if user.fainted?
    # Additional effect
    if !user.hasActiveAbility?(:SHEERFORCE)
      targets.each do |b|
        next if b.damageState.calcDamage == 0
        chance = move.pbAdditionalEffectChance(user, b)
        next if chance <= 0
        if @battle.pbRandom(100) < chance
          move.pbAdditionalEffect(user, b)
        end
      end
    end
    # Make the target flinch (because of an item/ability)
    targets.each do |b|
      next if b.fainted?
      next if b.damageState.calcDamage == 0 || b.damageState.substitute
      chance = move.pbFlinchChance(user, b)
      next if chance <= 0
      if @battle.pbRandom(100) < chance
        PBDebug.log("[Item/ability triggered] #{user.pbThis}'s King's Rock/Razor Fang or Stench")
        b.pbFlinch(user)
      end
    end
    # Message for and consuming of type-weakening berries
    # NOTE: The "consume held item" animation for type-weakening berries occurs
    #       during pbCalcDamage above (before the move's animation), but the
    #       message about it only shows here.
    targets.each do |b|
      next if b.damageState.unaffected
      next if !b.damageState.berryWeakened
      @battle.pbDisplay(_INTL("The {1} weakened the damage to {2}!", b.itemName, b.pbThis(true)))
      b.pbConsumeItem
    end
    # Steam Engine (goes here because it should be after stat changes caused by
    # the move)
    if [:FIRE, :WATER].include?(move.calcType)
      targets.each do |b|
        next if b.damageState.unaffected
        next if b.damageState.calcDamage == 0 || b.damageState.substitute
        next if !b.hasActiveAbility?(:STEAMENGINE)
        b.pbRaiseStatStageByAbility(:SPEED, 6, b) if b.pbCanRaiseStatStage?(:SPEED, b)
      end
    end
    # redundant text for Splinter Shot #by low
    if move.function == "HitTwoTimesReload"
      mimicHitNum = hitNum + 1
      roundnabout = (mimicHitNum > 1) ? "rounds" : "round"
      @battle.pbDisplay(_INTL("{1} {2}!", mimicHitNum, roundnabout))
    end
    # Fainting
    targets.each { |b| b.pbFaint if b&.fainted? }
    user.pbFaint if user.fainted?
    # Dragon Darts' second half of attack
    if move.pbRepeatHit? && hitNum == 0 &&
       targets.any? { |b| !b.fainted? && !b.damageState.unaffected }
      pbProcessMoveHit(move, user, all_targets, 1, skipAccuracyCheck)
    end
    # damage message #by low
    if $player.difficulty_mode?("hard")
      targets.each do |b|
        if b.damageState.calcDamage > 0
          damagetotal = b.damageState.calcDamage
          #damagetotal = b.totalhp.to_f if b.totalhp.to_f < damagetotal
          @battle.pbDisplay(_INTL("{1} damage on {2}! ({3}%)",damagetotal, b.pbThis(true),((damagetotal/b.totalhp.to_f)*100).floor)) if !$game_switches[101]
        end
      end
    end
    return true
  end
end