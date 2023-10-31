#===============================================================================
# "v20.1 Hotfixes" plugin
# This file contains fixes for bugs in battle code in Essentials v20.1.
# These bug fixes are also in the dev branch of the GitHub version of
# Essentials:
# https://github.com/Maruno17/pokemon-essentials
#===============================================================================

#===============================================================================
# Fixed Heavy Ball's catch rate calculation being inaccurate.
#===============================================================================
Battle::PokeBallEffects::ModifyCatchRate.add(:HEAVYBALL, proc { |ball, catchRate, battle, battler|
  next 0 if catchRate == 0
  weight = battler.pbWeight
  if Settings::NEW_POKE_BALL_CATCH_RATES
    if weight >= 3000
      catchRate += 30
    elsif weight >= 2000
      catchRate += 20
    elsif weight < 1000
      catchRate -= 20
    end
  else
    if weight >= 4096
      catchRate += 40
    elsif weight >= 3072
      catchRate += 30
    elsif weight >= 2048
      catchRate += 20
    else
      catchRate -= 20
    end
  end
  next catchRate.clamp(1, 255)
})

#===============================================================================
# Added Obstruct to the blacklists of Assist and Copycat.
#===============================================================================
class Battle::Move::UseRandomMoveFromUserParty < Battle::Move
  alias __hotfixes__initialize initialize
  def initialize(battle, move)
    __hotfixes__initialize(battle, move)
    @moveBlacklist.push("ProtectUserFromDamagingMovesObstruct")
  end
end

class Battle::Move::UseLastMoveUsed < Battle::Move
  alias __hotfixes__initialize initialize
  def initialize(battle, move)
    __hotfixes__initialize(battle, move)
    @moveBlacklist.push("ProtectUserFromDamagingMovesObstruct")
  end
end

#===============================================================================
# Fixed battle rule "forceCatchIntoParty" being circumventable.
#===============================================================================
module Battle::CatchAndStoreMixin
  def pbStorePokemon(pkmn)
    # Nickname the Pokémon (unless it's a Shadow Pokémon)
    if !pkmn.shadowPokemon?
      if $PokemonSystem.givenicknames == 0 &&
         pbDisplayConfirm(_INTL("Would you like to give a nickname to {1}?", pkmn.name))
        nickname = @scene.pbNameEntry(_INTL("{1}'s nickname?", pkmn.speciesName), pkmn)
        pkmn.name = nickname
      end
    end
    # Store the Pokémon
    if pbPlayer.party_full? && (@sendToBoxes == 0 || @sendToBoxes == 2)   # Ask/must add to party
      cmds = [_INTL("Add to your party"),
              _INTL("Send to a Box"),
              _INTL("See {1}'s summary", pkmn.name),
              _INTL("Check party")]
      cmds.delete_at(1) if @sendToBoxes == 2
      loop do
        cmd = pbShowCommands(_INTL("Where do you want to send {1} to?", pkmn.name), cmds, 99)
        break if cmd == 99   # Cancelling = send to a Box
        cmd += 1 if cmd >= 1 && @sendToBoxes == 2
        case cmd
        when 0   # Add to your party
          pbDisplay(_INTL("Choose a Pokémon in your party to send to your Boxes."))
          party_index = -1
          @scene.pbPartyScreen(0, (@sendToBoxes != 2), 1) { |idxParty, _partyScene|
            party_index = idxParty
            next true
          }
          next if party_index < 0   # Cancelled
          party_size = pbPlayer.party.length
          # Send chosen Pokémon to storage
          # NOTE: This doesn't work properly if you catch multiple Pokémon in
          #       the same battle, because the code below doesn't alter the
          #       contents of pbParty(0), only pbPlayer.party. This means that
          #       viewing the party in battle after replacing a party Pokémon
          #       with a caught one (which is possible if you've caught a second
          #       Pokémon) will not show the first caught Pokémon in the party
          #       but will still show the boxed Pokémon in the party. Correcting
          #       this would take a surprising amount of code, and it's very
          #       unlikely to be needed anyway, so I'm ignoring it for now.
          send_pkmn = pbPlayer.party[party_index]
          stored_box = @peer.pbStorePokemon(pbPlayer, send_pkmn)
          pbPlayer.party.delete_at(party_index)
          box_name = @peer.pbBoxName(stored_box)
          pbDisplayPaused(_INTL("{1} has been sent to Box \"{2}\".", send_pkmn.name, box_name))
          # Rearrange all remembered properties of party Pokémon
          (party_index...party_size).each do |idx|
            if idx < party_size - 1
              @initialItems[0][idx] = @initialItems[0][idx + 1]
              $game_temp.party_levels_before_battle[idx] = $game_temp.party_levels_before_battle[idx + 1]
              $game_temp.party_critical_hits_dealt[idx] = $game_temp.party_critical_hits_dealt[idx + 1]
              $game_temp.party_direct_damage_taken[idx] = $game_temp.party_direct_damage_taken[idx + 1]
            else
              @initialItems[0][idx] = nil
              $game_temp.party_levels_before_battle[idx] = nil
              $game_temp.party_critical_hits_dealt[idx] = nil
              $game_temp.party_direct_damage_taken[idx] = nil
            end
          end
          break
        when 1   # Send to a Box
          break
        when 2   # See X's summary
          pbFadeOutIn {
            summary_scene = PokemonSummary_Scene.new
            summary_screen = PokemonSummaryScreen.new(summary_scene, true)
            summary_screen.pbStartScreen([pkmn], 0)
          }
        when 3   # Check party
          @scene.pbPartyScreen(0, true, 2)
        end
      end
    end
    # Store as normal (add to party if there's space, or send to a Box if not)
    stored_box = @peer.pbStorePokemon(pbPlayer, pkmn)
    if stored_box < 0
      pbDisplayPaused(_INTL("{1} has been added to your party.", pkmn.name))
      @initialItems[0][pbPlayer.party.length - 1] = pkmn.item_id if @initialItems
      return
    end
    # Messages saying the Pokémon was stored in a PC box
    box_name = @peer.pbBoxName(stored_box)
    pbDisplayPaused(_INTL("{1} has been sent to Box \"{2}\"!", pkmn.name, box_name))
  end
end

#===============================================================================
# Fixed typo in Grassy Glide's effect.
#===============================================================================
class Battle::Move::HigherPriorityInGrassyTerrain < Battle::Move
  def pbPriority(user)
    ret = super
    ret += 1 if @battle.field.terrain == :Grassy && user.affectedByTerrain?
    return ret
  end
end

#===============================================================================
# Fixed Eerie Spell's effect working like a status move.
#===============================================================================
class Battle::Move::LowerPPOfTargetLastMoveBy3 < Battle::Move
  def pbFailsAgainstTarget?(user, target, show_message)
    return super
  end

  def pbEffectAgainstTarget(user, target)
    return if target.fainted?
    last_move = target.pbGetMoveWithID(target.lastRegularMoveUsed)
    return if !last_move || last_move.pp == 0 || last_move.total_pp <= 0
    reduction = [3, last_move.pp].min
    target.pbSetPP(last_move, last_move.pp - reduction)
    @battle.pbDisplay(_INTL("It reduced the PP of {1}'s {2} by {3}!",
                            target.pbThis(true), last_move.name, reduction))
  end
end

#===============================================================================
# Fixed error when shifting Pokémon at the end of a battle round.
#===============================================================================
class Battle
  def pbEORShiftDistantBattlers
    # Move battlers around if none are near to each other
    # NOTE: This code assumes each side has a maximum of 3 battlers on it, and
    #       is not generalised to larger side sizes.
    if !singleBattle?
      swaps = []   # Each element is an array of two battler indices to swap
      2.times do |side|
        next if pbSideSize(side) == 1   # Only battlers on sides of size 2+ need to move
        # Check if any battler on this side is near any battler on the other side
        anyNear = false
        allSameSideBattlers(side).each do |battler|
          anyNear = allOtherSideBattlers(battler).any? { |other| nearBattlers?(other.index, battler.index) }
          break if anyNear
        end
        break if anyNear
        # No battlers on this side are near any battlers on the other side; try
        # to move them
        # NOTE: If we get to here (assuming both sides are of size 3 or less),
        #       there is definitely only 1 able battler on this side, so we
        #       don't need to worry about multiple battlers trying to move into
        #       the same position. If you add support for a side of size 4+,
        #       this code will need revising to account for that, as well as to
        #       add more complex code to ensure battlers will end up near each
        #       other.
        allSameSideBattlers(side).each do |battler|
          # Get the position to move to
          pos = -1
          case pbSideSize(side)
          when 2 then pos = [2, 3, 0, 1][battler.index]   # The unoccupied position
          when 3 then pos = (side == 0) ? 2 : 3    # The centre position
          end
          next if pos < 0
          # Can't move if the same trainer doesn't control both positions
          idxOwner = pbGetOwnerIndexFromBattlerIndex(battler.index)
          next if pbGetOwnerIndexFromBattlerIndex(pos) != idxOwner
          swaps.push([battler.index, pos])
        end
      end
      # Move battlers around
      swaps.each do |pair|
        next if pbSideSize(pair[0]) == 2 && swaps.length > 1
        next if !pbSwapBattlers(pair[0], pair[1])
        case pbSideSize(pair[1])
        when 2
          pbDisplay(_INTL("{1} moved across!", @battlers[pair[1]].pbThis))
        when 3
          pbDisplay(_INTL("{1} moved to the center!", @battlers[pair[1]].pbThis))
        end
      end
    end
  end
end

#===============================================================================
# Fixed bugs when the AI determines the best replacement Pokémon to switch into.
#===============================================================================
class Battle::AI
  def pbCalcTypeModPokemon(battlerThis, battlerOther)
    mod1 = Effectiveness.calculate(battlerThis.types[0], battlerOther.types[0], battlerOther.types[1])
    mod2 = Effectiveness::NORMAL_EFFECTIVE
    if battlerThis.types.length > 1
      mod2 = Effectiveness.calculate(battlerThis.types[1], battlerOther.types[0], battlerOther.types[1])
      mod2 = mod2.to_f / Effectiveness::NORMAL_EFFECTIVE
    end
    return mod1 * mod2
  end
end

#===============================================================================
# Fixed Flame Orb/Toxic Orb being able to replace an existing status problem.
#===============================================================================
class Battle::Battler
  def pbCanInflictStatus?(newStatus, user, showMessages, move = nil, ignoreStatus = false)
    return false if fainted?
    self_inflicted = (user && user.index == @index)   # Rest and Flame Orb/Toxic Orb only
    # Already have that status problem
    if self.status == newStatus && !ignoreStatus
      if showMessages
        msg = ""
        case self.status
        when :SLEEP     then msg = _INTL("{1} is already asleep!", pbThis)
        when :POISON    then msg = _INTL("{1} is already poisoned!", pbThis)
        when :BURN      then msg = _INTL("{1} already has a burn!", pbThis)
        when :PARALYSIS then msg = _INTL("{1} is already paralyzed!", pbThis)
        when :FROZEN    then msg = _INTL("{1} is already frozen solid!", pbThis)
        end
        @battle.pbDisplay(msg)
      end
      return false
    end
    # Trying to replace a status problem with another one
    if self.status != :NONE && !ignoreStatus && !(self_inflicted && move)   # Rest can replace a status problem
      @battle.pbDisplay(_INTL("It doesn't affect {1}...", pbThis(true))) if showMessages
      return false
    end
    # Trying to inflict a status problem on a Pokémon behind a substitute
    if @effects[PBEffects::Substitute] > 0 && !(move && move.ignoresSubstitute?(user)) &&
       !self_inflicted
      @battle.pbDisplay(_INTL("It doesn't affect {1}...", pbThis(true))) if showMessages
      return false
    end
    # Weather immunity
    if newStatus == :FROZEN && [:Sun, :HarshSun].include?(effectiveWeather)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...", pbThis(true))) if showMessages
      return false
    end
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
      hasImmuneType |= pbHasType?(:ELECTRIC) && Settings::MORE_TYPE_EFFECTS
    when :FROZEN
      hasImmuneType |= pbHasType?(:ICE)
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
    elsif self_inflicted || !@battle.moldBreaker
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
          when :FROZEN    then msg = _INTL("{1} cannot be frozen solid!", pbThis)
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
            msg = _INTL("{1} cannot be frozen solid because of {2}'s {3}!",
                        pbThis, immAlly.pbThis(true), immAlly.abilityName)
          end
        else
          case newStatus
          when :SLEEP     then msg = _INTL("{1} stays awake because of its {2}!", pbThis, abilityName)
          when :POISON    then msg = _INTL("{1}'s {2} prevents poisoning!", pbThis, abilityName)
          when :BURN      then msg = _INTL("{1}'s {2} prevents burns!", pbThis, abilityName)
          when :PARALYSIS then msg = _INTL("{1}'s {2} prevents paralysis!", pbThis, abilityName)
          when :FROZEN    then msg = _INTL("{1}'s {2} prevents freezing!", pbThis, abilityName)
          end
        end
        @battle.pbDisplay(msg)
        @battle.pbHideAbilitySplash(immAlly || self)
      end
      return false
    end
    # Safeguard immunity
    if pbOwnSide.effects[PBEffects::Safeguard] > 0 && !self_inflicted && move &&
       !(user && user.hasActiveAbility?(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!", pbThis)) if showMessages
      return false
    end
    return true
  end
end

#===============================================================================
# Fixed Pastel Veil not providing poison immunity to allies, and not healing the
# bearer if it becomes poisoned anyway.
#===============================================================================
Battle::AbilityEffects::StatusImmunityFromAlly.add(:PASTELVEIL,
  proc { |ability, battler, status|
    next true if status == :POISON
  }
)

Battle::AbilityEffects::StatusCure.copy(:IMMUNITY, :PASTELVEIL)

#===============================================================================
# Fixed moves that deal fixed damage showing an effectiveness message.
#===============================================================================
class Battle::Move
  alias __hotfixes__pbEffectivenessMessage pbEffectivenessMessage
  def pbEffectivenessMessage(user, target, numTargets = 1)
    return if self.is_a?(Battle::Move::FixedDamageMove)
    __hotfixes__pbEffectivenessMessage(user, target, numTargets)
  end
end

#===============================================================================
# Fixed Chip Away/Darkest Lariat/Sacred Sword not ignoring the target's evasion.
#===============================================================================
class Battle::Move::IgnoreTargetDefSpDefEvaStatStages < Battle::Move
  def pbCalcAccuracyModifiers(user, target, modifiers)
    super
    modifiers[:evasion_stage] = 0
  end
end

#===============================================================================
# Fixed error in battle fight menu when not using graphics for it.
#===============================================================================
class Battle::Scene::FightMenu < Battle::Scene::MenuBase
  alias __hotfixes__refreshMoveData refreshMoveData
  def refreshMoveData(move)
    return if !USE_GRAPHICS && !move
    __hotfixes__refreshMoveData(move)
  end
end

#===============================================================================
# Fixed Liquid Ooze not oozing drained HP if the bearer fainted from that
# draining.
#===============================================================================
class Battle::Battler
  def pbRecoverHPFromDrain(amt, target, msg = nil)
    if target.hasActiveAbility?(:LIQUIDOOZE, true)
      @battle.pbShowAbilitySplash(target)
      pbReduceHP(amt)
      @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!", pbThis))
      @battle.pbHideAbilitySplash(target)
      pbItemHPHealCheck
    else
      msg = _INTL("{1} had its energy drained!", target.pbThis) if nil_or_empty?(msg)
      @battle.pbDisplay(msg)
      if canHeal?
        amt = (amt * 1.3).floor if hasActiveItem?(:BIGROOT)
        pbRecoverHP(amt)
      end
    end
  end
end

class Battle::Move::HealUserByTargetAttackLowerTargetAttack1 < Battle::Move
  def pbEffectAgainstTarget(user, target)
    # Calculate target's effective attack value
    stageMul = [2, 2, 2, 2, 2, 2, 2, 3, 4, 5, 6, 7, 8]
    stageDiv = [8, 7, 6, 5, 4, 3, 2, 2, 2, 2, 2, 2, 2]
    atk      = target.attack
    atkStage = target.stages[:ATTACK] + 6
    healAmt = (atk.to_f * stageMul[atkStage] / stageDiv[atkStage]).floor
    # Reduce target's Attack stat
    if target.pbCanLowerStatStage?(:ATTACK, user, self)
      target.pbLowerStatStage(:ATTACK, 1, user)
    end
    # Heal user
    if target.hasActiveAbility?(:LIQUIDOOZE, true)
      @battle.pbShowAbilitySplash(target)
      user.pbReduceHP(healAmt)
      @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!", user.pbThis))
      @battle.pbHideAbilitySplash(target)
      user.pbItemHPHealCheck
    elsif user.canHeal?
      healAmt = (healAmt * 1.3).floor if user.hasActiveItem?(:BIGROOT)
      user.pbRecoverHP(healAmt)
      @battle.pbDisplay(_INTL("{1}'s HP was restored.", user.pbThis))
    end
  end
end
