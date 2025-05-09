class Battle
  #=============================================================================
  # Choosing Pokémon to switch
  #=============================================================================
  # Checks whether the replacement Pokémon (at party index idxParty) can enter
  # battle.
  # NOTE: Messages are only shown while in the party screen when choosing a
  #       command for the next round.
  def pbCanSwitchLax?(idxBattler, idxParty, partyScene = nil)
    return true if idxParty < 0
    party = pbParty(idxBattler)
    return false if idxParty >= party.length
    return false if !party[idxParty]
    if party[idxParty].egg?
      partyScene&.pbDisplay(_INTL("An Egg can't battle!"))
      return false
    end
    if !pbIsOwner?(idxBattler, idxParty)
      if partyScene
        owner = pbGetOwnerFromPartyIndex(idxBattler, idxParty)
        partyScene.pbDisplay(_INTL("You can't switch {1}'s Pokémon with one of yours!",
                                   owner.name))
      end
      return false
    end
    if party[idxParty].fainted?
      partyScene&.pbDisplay(_INTL("{1} has no energy left to battle!", party[idxParty].name))
      return false
    end
    if pbFindBattler(idxParty, idxBattler)
      partyScene&.pbDisplay(_INTL("{1} is already in battle!", party[idxParty].name))
      return false
    end
    return true
  end

  # Check whether the currently active Pokémon (at battler index idxBattler) can
  # switch out (and that its replacement at party index idxParty can switch in).
  # NOTE: Messages are only shown while in the party screen when choosing a
  #       command for the next round.
  def pbCanSwitch?(idxBattler, idxParty = -1, partyScene = nil)
    # Check whether party Pokémon can switch in
    return false if !pbCanSwitchLax?(idxBattler, idxParty, partyScene)
    # Make sure another battler isn't already choosing to switch to the party
    # Pokémon
    allSameSideBattlers(idxBattler).each do |b|
      next if choices[b.index][0] != :SwitchOut || choices[b.index][1] != idxParty
      partyScene&.pbDisplay(_INTL("{1} has already been selected.",
                                  pbParty(idxBattler)[idxParty].name))
      return false
    end
    # Check whether battler can switch out
    battler = @battlers[idxBattler]
    return true if battler.fainted?
    # Ability/item effects that allow switching *no matter what
		# *except if the user has honorbound ability and effect #by low
    if battler.abilityActive? &&
        Battle::AbilityEffects.triggerCertainSwitching(battler.ability, battler, self)
      return true
    end
    if battler.itemActive? &&
        Battle::ItemEffects.triggerCertainSwitching(battler.item, battler, self)
      return true
    end
    # Other certain switching effects
    return true if (Settings::MORE_TYPE_EFFECTS && !$game_switches[OLDSCHOOLBATTLE]) && battler.pbHasType?(:GHOST)
    # Other certain trapping effects
    if battler.trappedInBattle?
      partyScene&.pbDisplay(_INTL("{1} can't be switched out!", battler.pbThis))
      return false
    end
    # Trapping abilities/items
    allOtherSideBattlers(idxBattler).each do |b|
      next if !b.abilityActive?
      if Battle::AbilityEffects.triggerTrappingByTarget(b.ability, battler, b, self)
        partyScene&.pbDisplay(_INTL("{1}'s {2} prevents switching!",
                                    b.pbThis, b.abilityName))
        return false
      end
    end
    allOtherSideBattlers(idxBattler).each do |b|
      next if !b.itemActive?
      if Battle::ItemEffects.triggerTrappingByTarget(b.item, battler, b, self)
        partyScene&.pbDisplay(_INTL("{1}'s {2} prevents switching!",
                                    b.pbThis, b.itemName))
        return false
      end
    end
    return true
  end

  def pbCanChooseNonActive?(idxBattler)
    pbParty(idxBattler).each_with_index do |_pkmn, i|
      return true if pbCanSwitchLax?(idxBattler, i)
    end
    return false
  end

  def pbRegisterSwitch(idxBattler, idxParty)
    return false if !pbCanSwitch?(idxBattler, idxParty)
    @choices[idxBattler][0] = :SwitchOut
    @choices[idxBattler][1] = idxParty   # Party index of Pokémon to switch in
    @choices[idxBattler][2] = nil
    return true
  end

  #=============================================================================
  # Open the party screen and potentially pick a replacement Pokémon (or AI
  # chooses replacement)
  #=============================================================================
  # Open party screen and potentially choose a Pokémon to switch with. Used in
  # all instances where the party screen is opened.
  def pbPartyScreen(idxBattler, checkLaxOnly = false, canCancel = false, shouldRegister = false)
    ret = -1
    @scene.pbPartyScreen(idxBattler, canCancel) { |idxParty, partyScene|
      if checkLaxOnly
        next false if !pbCanSwitchLax?(idxBattler, idxParty, partyScene)
      elsif !pbCanSwitch?(idxBattler, idxParty, partyScene)
        next false
      end
      if shouldRegister && (idxParty < 0 || !pbRegisterSwitch(idxBattler, idxParty))
        next false
      end
      ret = idxParty
      next true
    }
    return ret
  end

  # For choosing a replacement Pokémon when prompted in the middle of other
  # things happening (U-turn, Baton Pass, in def pbEORSwitch).
  def pbSwitchInBetween(idxBattler, checkLaxOnly = false, canCancel = false)
    return pbPartyScreen(idxBattler, checkLaxOnly, canCancel) if pbOwnedByPlayer?(idxBattler)
    return @battleAI.pbDefaultChooseNewEnemy(idxBattler, pbParty(idxBattler))
  end

  #=============================================================================
  # Switching Pokémon
  #=============================================================================
  # General switching method that checks if any Pokémon need to be sent out and,
  # if so, does. Called at the end of each round.
  def pbEORSwitch(favorDraws = false)
  end

  def pbGetReplacementPokemonIndex(idxBattler, random = false)
    if random
      choices = []   # Find all Pokémon that can switch in
      eachInTeamFromBattlerIndex(idxBattler) do |_pkmn, i|
        choices.push(i) if pbCanSwitchLax?(idxBattler, i)
      end
      return -1 if choices.length == 0
      return choices[pbRandom(choices.length)]
    else
      return pbSwitchInBetween(idxBattler, true)
    end
  end

  # Actually performs the recalling and sending out in all situations.
  def pbRecallAndReplace(idxBattler, idxParty, randomReplacement = false, batonPass = false)
    @scene.pbRecall(idxBattler) if !@battlers[idxBattler].fainted?
    @battlers[idxBattler].pbAbilitiesOnSwitchOut   # Inc. primordial weather check
    @scene.pbShowPartyLineup(idxBattler & 1) if pbSideSize(idxBattler) == 1
    pbMessagesOnReplace(idxBattler, idxParty) if !randomReplacement
    pbReplace(idxBattler, idxParty, batonPass)
		# switch abuse prevention #by low
		@battlers[idxBattler].pbOwnSide.effects[PBEffects::SwitchAbuse]+=1
  end

  def pbMessageOnRecall(battler)
    if battler.pbOwnedByPlayer?
      if battler.hp <= battler.totalhp / 4
        pbDisplayBrief(_INTL("Good job, {1}! Come back!", battler.name))
      elsif battler.hp <= battler.totalhp / 2
        pbDisplayBrief(_INTL("OK, {1}! Come back!", battler.name))
      elsif battler.turnCount >= 5
        pbDisplayBrief(_INTL("{1}, that's enough! Come back!", battler.name))
      elsif battler.turnCount >= 2
        pbDisplayBrief(_INTL("{1}, come back!", battler.name))
      else
        pbDisplayBrief(_INTL("{1}, switch out! Come back!", battler.name))
      end
    else
      oppon = @player[0]
      oppon = @opponent[pbGetOwnerIndexFromBattlerIndex(battler.index)] if opposes?(battler.index)
      if isWildBoss?(oppon) #by low
        pbDisplayBrief(_INTL("{1} is retreating!", battler.name))
      else
        owner = pbGetOwnerName(battler.index)
        pbDisplayBrief(_INTL("{1} withdrew {2}!", owner, battler.name))
      end
    end
  end

  # Only called from def pbRecallAndReplace and Battle Arena's def pbSwitch.
  def pbMessagesOnReplace(idxBattler, idxParty)
    party = pbParty(idxBattler)
    newPkmnName = party[idxParty].name
    if party[idxParty].ability == :ILLUSION && !pbCheckGlobalAbility(:NEUTRALIZINGGAS)
      new_index = pbLastInTeam(idxBattler)
      newPkmnName = party[new_index].name if new_index >= 0 && new_index != idxParty
    end
    if pbOwnedByPlayer?(idxBattler)
      opposing = @battlers[idxBattler].pbDirectOpposing
      if opposing.fainted? || opposing.hp == opposing.totalhp
        pbDisplayBrief(_INTL("You're in charge, {1}!", newPkmnName))
      elsif opposing.hp >= opposing.totalhp / 2
        pbDisplayBrief(_INTL("Go for it, {1}!", newPkmnName))
      elsif opposing.hp >= opposing.totalhp / 4
        pbDisplayBrief(_INTL("Just a little more! Hang in there, {1}!", newPkmnName))
      else
        pbDisplayBrief(_INTL("Your opponent's weak! Get 'em, {1}!", newPkmnName))
      end
    else
      oppon = @player[0]
      oppon = @opponent[pbGetOwnerIndexFromBattlerIndex(idxBattler)] if opposes?(idxBattler)
      if isWildBoss?(oppon) #by low
        pbDisplayBrief(_INTL("A {1} appeared!", newPkmnName))
      else
        owner = pbGetOwnerFromBattlerIndex(idxBattler)
        pbDisplayBrief(_INTL("{1} sent out {2}!", owner.full_name, newPkmnName))
      end
    end
  end

  # Only called from def pbRecallAndReplace above and Battle Arena's def
  # pbSwitch.
  def pbReplace(idxBattler, idxParty, batonPass = false)
    party = pbParty(idxBattler)
    idxPartyOld = @battlers[idxBattler].pokemonIndex
    # Initialise the new Pokémon
    @battlers[idxBattler].pbInitialize(party[idxParty], idxParty, batonPass)
    # Reorder the party for this battle
    partyOrder = pbPartyOrder(idxBattler)
    partyOrder[idxParty], partyOrder[idxPartyOld] = partyOrder[idxPartyOld], partyOrder[idxParty]
    # Send out the new Pokémon
    pbSendOut([[idxBattler, party[idxParty]]])
    pbCalculatePriority(false, [idxBattler]) if Settings::RECALCULATE_TURN_ORDER_AFTER_SPEED_CHANGES && !$game_switches[OLDSCHOOLBATTLE]
  end

  # Called from def pbReplace above and at the start of battle.
  # sendOuts is an array; each element is itself an array: [idxBattler,pkmn]
  def pbSendOut(sendOuts, startBattle = false)
    sendOuts.each { |b| @peer.pbOnEnteringBattle(self, @battlers[b[0]], b[1]) }
    @scene.pbSendOutBattlers(sendOuts, startBattle)
    sendOuts.each do |b|
      @scene.pbResetMoveIndex(b[0])
      pbSetSeen(@battlers[b[0]])
      @usedInBattle[b[0] & 1][b[0] / 2] = true
    end
  end

  #=============================================================================
  # Effects upon a Pokémon entering battle
  #=============================================================================
  # Called at the start of battle only.
  def pbOnAllBattlersEnteringBattle
    pbCalculatePriority(true)
    battler_indices = []
    allBattlers.each { |b| battler_indices.push(b.index) }
    pbOnBattlerEnteringBattle(battler_indices, false, true) #by low
    pbCalculatePriority
    # Check forms are correct
    allBattlers.each { |b| b.pbCheckForm }
  end

  # Called when one or more Pokémon switch in. Does a lot of things, including
  # entry hazards, form changes and items/abilities that trigger upon switching
  # in.
  def pbOnBattlerEnteringBattle(battler_index, skip_event_reset = false, tileworker = false) #by low
    battler_index = [battler_index] if !battler_index.is_a?(Array)
    battler_index.flatten!
    # NOTE: This isn't done for switch commands, because they previously call
    #       pbRecallAndReplace, which could cause Neutralizing Gas to end, which
    #       in turn could cause Intimidate to trigger another Pokémon's Eject
    #       Pack. That Eject Pack should trigger at the end of this method, but
    #       this resetting would prevent that from happening, so it is skipped
    #       and instead done earlier in def pbAttackPhaseSwitch.
    if !skip_event_reset
      allBattlers.each do |b|
        b.droppedBelowHalfHP = false
        b.statsDropped = false
      end
    end
    # For each battler that entered battle, in speed order
    pbPriority(true).each do |b|
      next if !battler_index.include?(b.index) || b.fainted?
			# FAILSAFE ANNOUCEMENT #by low
			if !b.pbOwnedByPlayer? && b.name.include?("Failsafe")
				pbDisplay(_INTL("Warning! You have encountered a Failsafe."))
				pbDisplay(_INTL("Please report this as a bug."))
				event = pbMapInterpreter.get_character(0) || "???"
				map_name = ($game_map.name rescue nil) || "???"
				if event == "???"
					print "Failsafe trigger: map #{$game_map.map_id} (#{map_name})\r\n"
				else
					print "Failsafe trigger: event #{event.id} (coords #{event.x},#{event.y}), map #{$game_map.map_id} (#{map_name})\r\n"
				end
			end
      pbRecordBattlerAsParticipated(b)
      pbMessagesOnBattlerEnteringBattle(b)
      # Position/field effects triggered by the battler appearing
      pbEffectsOnBattlerEnteringPosition(b)   # Healing Wish/Lunar Dance
      pbEntryHazards(b) if !tileworker #by low
      # Battler faints if it is knocked out because of an entry hazard above
      if b.fainted?
        b.pbFaint
        pbGainExp
        pbJudge
        next
      end
      b.pbCheckForm
      # Primal Revert upon entering battle
      pbPrimalReversion(b.index)
      # Ending primordial weather, checking Trace
      b.pbContinualAbilityChecks(true)
      # Abilities that trigger upon switching in
      if (!b.fainted? && b.unstoppableAbility?) || b.abilityActive?
				if b.ability == :TILEWORKER && tileworker #by low
					# if ability is tileworker, and its the first turn of the battle, do nothing
				else
					Battle::AbilityEffects.triggerOnSwitchIn(b.ability, b, self, true)
				end
      end
      pbGetMegaEvolutionMove(b) #by low
      pbEndPrimordialWeather   # Checking this again just in case
      # Items that trigger upon switching in (Air Balloon message)
      if b.itemActive?
        Battle::ItemEffects.triggerOnSwitchIn(b.item, b, self)
      end
      # Berry check, status-curing ability check
      b.pbHeldItemTriggerCheck
      b.pbAbilityStatusCureCheck
    end
    # Check for triggering of Emergency Exit/Wimp Out/Eject Pack (only one will
    # be triggered)
    pbPriority(true).each do |b|
      break if b.pbItemOnStatDropped
      break if b.pbAbilitiesOnDamageTaken
    end
    allBattlers.each do |b|
      b.droppedBelowHalfHP = false
      b.statsDropped = false
    end
  end

  def pbRecordBattlerAsParticipated(battler)
    # Record money-doubling effect of Amulet Coin/Luck Incense
    if !battler.opposes? && [:AMULETCOIN, :LUCKINCENSE].include?(battler.item_id)
      @field.effects[PBEffects::AmuletCoin] = true
    end
    # Update battlers' participants (who will gain Exp/EVs when a battler faints)
    allBattlers.each { |b| b.pbUpdateParticipants }
  end

  def pbMessagesOnBattlerEnteringBattle(battler)
    # Introduce Shadow Pokémon
    if battler.shadowPokemon?
      pbCommonAnimation("Shadow", battler)
      pbDisplay(_INTL("Oh!\nA Shadow Pokémon!")) if battler.opposes?
    end
  end

  # Called when a Pokémon enters battle, and when Ally Switch is used.
  def pbEffectsOnBattlerEnteringPosition(battler)
    position = @positions[battler.index]
    # Healing Wish
    if position.effects[PBEffects::HealingWish]
      if battler.canHeal? || battler.status != :NONE
        pbCommonAnimation("HealingWish", battler)
        pbDisplay(_INTL("The healing wish came true for {1}!", battler.pbThis(true)))
        battler.pbRecoverHP(battler.totalhp)
        battler.pbCureStatus(false)
        position.effects[PBEffects::HealingWish] = false
      elsif Settings::MECHANICS_GENERATION < 8
        position.effects[PBEffects::HealingWish] = false
      end
    end
    # Lunar Dance
    if position.effects[PBEffects::LunarDance]
      full_pp = true
      battler.eachMove { |m| full_pp = false if m.pp < m.total_pp }
      if battler.canHeal? || battler.status != :NONE || !full_pp
        pbCommonAnimation("LunarDance", battler)
        pbDisplay(_INTL("{1} became cloaked in mystical moonlight!", battler.pbThis))
        battler.pbRecoverHP(battler.totalhp)
        battler.pbCureStatus(false)
        battler.eachMove { |m| battler.pbSetPP(m, m.total_pp) }
        position.effects[PBEffects::LunarDance] = false
      elsif Settings::MECHANICS_GENERATION < 8
        position.effects[PBEffects::LunarDance] = false
      end
    end
		# Party Popper #by low
    if position.effects[PBEffects::PartyPopper]
      if battler.canHeal?
        pbCommonAnimation("HealingWish", battler)
        pbDisplay(_INTL("{1} healed a bit because of the candy!", battler.pbThis(true)))
        battler.pbRecoverHP((battler.totalhp/2))
      end
      position.effects[PBEffects::PartyPopper] = false
    end
  end

  def pbEntryHazards(battler)
    battler_side = battler.pbOwnSide
    # tileworker, overcoat buff and stealth rock nerf #by low
		if !battler.hasActiveAbility?(:TILEWORKER)
			# Stealth Rock
			if battler_side.effects[PBEffects::StealthRock] && battler.takesIndirectDamage? && 
        !(battler.hasActiveItem?(:HEAVYDUTYBOOTS) || battler.hasActiveAbility?(:OVERCOAT))
				airdamage = (battler.airborne?) ? 4 : 8
				battler.pbReduceHP((battler.totalhp / airdamage), false)
				pbDisplay(_INTL("Pointed stones dug into {1}!", battler.pbThis))
				battler.pbItemHPHealCheck
			end
			# Spikes
			if battler_side.effects[PBEffects::Spikes] > 0 && battler.takesIndirectDamage? &&
				 !battler.airborne? && !(battler.hasActiveItem?(:HEAVYDUTYBOOTS) || battler.hasActiveAbility?(:OVERCOAT))
				spikesDiv = [8, 6, 4][battler_side.effects[PBEffects::Spikes] - 1]
				battler.pbReduceHP(battler.totalhp / spikesDiv, false)
				pbDisplay(_INTL("{1} is hurt by the spikes!", battler.pbThis))
				battler.pbItemHPHealCheck
			end
			# Toxic Spikes
			if battler_side.effects[PBEffects::ToxicSpikes] > 0 && !battler.fainted? && !battler.airborne?
				if battler.pbHasType?(:POISON)
					battler_side.effects[PBEffects::ToxicSpikes] = 0
					pbDisplay(_INTL("{1} absorbed the poison spikes!", battler.pbThis))
				elsif battler.pbCanPoison?(nil, false) && !battler.hasActiveItem?(:HEAVYDUTYBOOTS)
					if battler_side.effects[PBEffects::ToxicSpikes] == 2
						battler.pbPoison(nil, _INTL("{1} was badly poisoned by the poison spikes!", battler.pbThis), true)
					else
						battler.pbPoison(nil, _INTL("{1} was poisoned by the poison spikes!", battler.pbThis))
					end
				end
			end
			# Sticky Web nerf #by low
			if battler_side.effects[PBEffects::StickyWeb] > 0 && !battler.fainted? && !battler.airborne? && !battler.hasActiveItem?(:HEAVYDUTYBOOTS)
				pbDisplay(_INTL("{1} was caught in a sticky web!", battler.pbThis))
				if battler.pbCanLowerStatStage?(:SPEED)
					battler.pbLowerStatStage(:SPEED, 1, nil)
					battler.pbItemStatRestoreCheck
					battler_side.effects[PBEffects::StickyWeb]-=1
					if battler_side.effects[PBEffects::StickyWeb] == 0
						pbDisplay(_INTL("The sticky web was dissolved!"))
					end
				end
			end
		end
  end
end
