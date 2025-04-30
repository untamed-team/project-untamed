class Battle
  #=============================================================================
  # End Of Round end weather check and weather effects
  #=============================================================================
  def pbEOREndWeather(priority)
    # NOTE: Primordial weather doesn't need to be checked here, because if it
    #       could wear off here, it will have worn off already.
    # Count down weather duration
    @field.weatherDuration -= 1 if @field.weatherDuration > 0
    # Weather wears off
    if @field.weatherDuration == 0
      case @field.weather
      when :Sun       then pbDisplay(_INTL("The sunlight faded."))
      when :Rain      then pbDisplay(_INTL("The rain stopped."))
      when :Sandstorm then pbDisplay(_INTL("The sandstorm subsided."))
      when :Hail      then pbDisplay(_INTL("The hail stopped."))
      when :ShadowSky then pbDisplay(_INTL("The shadow sky faded."))
      end
      @field.weather = :None
      # Check for form changes caused by the weather changing
      allBattlers.each { |battler| battler.pbCheckFormOnWeatherChange }
      # Start up the default weather
      if @field.defaultWeather != :None
        @field.abilityWeather = false
        pbStartWeather(nil, @field.defaultWeather)
      elsif @field.presageBackup[0] != :None # presage stuff  #by low
        pbStartWeather(nil, @field.presageBackup[0], false, true, false, @field.presageBackup[1])
        @field.abilityWeather = @field.presageBackup[2]
        #~ echo ("\nWas the previous "+@field.weather.to_s+" set by an ability?        "+@field.abilityWeather.to_s+"\n")
      end
      return if @field.weather == :None
    end
    # Weather continues
    weather_data = GameData::BattleWeather.try_get(@field.weather)
    pbCommonAnimation(weather_data.animation) if weather_data
    case @field.weather
#    when :Sun         then pbDisplay(_INTL("The sunlight is strong."))
#    when :Rain        then pbDisplay(_INTL("Rain continues to fall."))
    when :Sandstorm   then pbDisplay(_INTL("The sandstorm is raging."))
    when :Hail        then pbDisplay(_INTL("The hail is crashing down."))
#    when :HarshSun    then pbDisplay(_INTL("The sunlight is extremely harsh."))
#    when :HeavyRain   then pbDisplay(_INTL("It is raining heavily."))
#    when :StrongWinds then pbDisplay(_INTL("The wind is strong."))
    when :ShadowSky   then pbDisplay(_INTL("The shadow sky continues."))
    end
    # Effects due to weather
    priority.each do |battler|
      # Weather-related abilities
      if battler.abilityActive?
        Battle::AbilityEffects.triggerEndOfRoundWeather(battler.ability, battler.effectiveWeather, battler, self)
        battler.pbFaint if battler.fainted?
      end
      # Weather damage
      pbEORWeatherDamage(battler)
    end
  end

  def pbEORWeatherDamage(battler)
    return if battler.fainted?
    amt = -1
    case battler.effectiveWeather
    when :Sandstorm
      return if !battler.takesSandstormDamage?
      pbDisplay(_INTL("{1} is buffeted by the sandstorm!", battler.pbThis))
      amt = battler.totalhp / 16
    when :Hail
      return if !battler.takesHailDamage?
      pbDisplay(_INTL("{1} is buffeted by the hail!", battler.pbThis))
      amt = battler.totalhp / 16
    when :ShadowSky
      return if !battler.takesShadowSkyDamage?
      pbDisplay(_INTL("{1} is hurt by the shadow sky!", battler.pbThis))
      amt = battler.totalhp / 16
    end
    return if amt < 0
    @scene.pbDamageAnimation(battler)
    battler.pbReduceHP(amt, false)
    battler.pbItemHPHealCheck
    battler.pbFaint if battler.fainted?
  end

  #=============================================================================
  # End Of Round use delayed moves (Future Sight, Doom Desire)
  #=============================================================================
  def pbEORUseFutureSight(position, position_index)
    return if !position || position.effects[PBEffects::FutureSightCounter] == 0
    position.effects[PBEffects::FutureSightCounter] -= 1
    return if position.effects[PBEffects::FutureSightCounter] > 0
    return if !@battlers[position_index] || @battlers[position_index].fainted?   # No target
    moveUser = nil
    allBattlers.each do |battler|
      next if battler.opposes?(position.effects[PBEffects::FutureSightUserIndex])
      next if battler.pokemonIndex != position.effects[PBEffects::FutureSightUserPartyIndex]
      moveUser = battler
      break
    end
    return if moveUser && moveUser.index == position_index   # Target is the user
    if !moveUser   # User isn't in battle, get it from the party
      party = pbParty(position.effects[PBEffects::FutureSightUserIndex])
      pkmn = party[position.effects[PBEffects::FutureSightUserPartyIndex]]
      if pkmn&.able?
        moveUser = Battler.new(self, position.effects[PBEffects::FutureSightUserIndex])
        moveUser.pbInitDummyPokemon(pkmn, position.effects[PBEffects::FutureSightUserPartyIndex])
      end
    end
    return if !moveUser   # User is fainted
    move = position.effects[PBEffects::FutureSightMove]
    pbDisplay(_INTL("{1} took the {2} attack!", @battlers[position_index].pbThis,GameData::Move.get(move).name))
    # NOTE: Future Sight failing against the target here doesn't count towards
    #       Stomping Tantrum.
    userLastMoveFailed = moveUser.lastMoveFailed
    @futureSight = true
    moveUser.pbUseMoveSimple(move, position_index)
    @futureSight = false
    moveUser.lastMoveFailed = userLastMoveFailed
    moveUser.premonitionMove = 0  # Premonition #by low
    @battlers[position_index].pbFaint if @battlers[position_index].fainted?
    position.effects[PBEffects::FutureSightCounter]        = 0
    position.effects[PBEffects::FutureSightMove]           = nil
    position.effects[PBEffects::FutureSightUserIndex]      = -1
    position.effects[PBEffects::FutureSightUserPartyIndex] = -1
  end

  #=============================================================================
  # End Of Round healing from Wish
  #=============================================================================
  def pbEORWishHealing
    @positions.each_with_index do |pos, idxPos|
      next if !pos || pos.effects[PBEffects::Wish] == 0
      pos.effects[PBEffects::Wish] -= 1
      next if pos.effects[PBEffects::Wish] > 0
      next if !@battlers[idxPos] || !@battlers[idxPos].canHeal?
      wishMaker = pbThisEx(idxPos, pos.effects[PBEffects::WishMaker])
      @battlers[idxPos].pbRecoverHP(pos.effects[PBEffects::WishAmount])
      pbDisplay(_INTL("{1}'s wish came true!", wishMaker))
    end
  end

  #=============================================================================
  # End Of Round Sea of Fire damage (Fire Pledge + Grass Pledge combination)
  #=============================================================================
  def pbEORSeaOfFireDamage(priority)
    2.times do |side|
      next if sides[side].effects[PBEffects::SeaOfFire] == 0
      pbCommonAnimation("SeaOfFire") if side == 0
      pbCommonAnimation("SeaOfFireOpp") if side == 1
      priority.each do |battler|
        next if battler.opposes?(side)
        next if !battler.takesIndirectDamage? || battler.pbHasType?(:FIRE)
        @scene.pbDamageAnimation(battler)
        battler.pbTakeEffectDamage(battler.totalhp / 8, false) { |hp_lost|
          pbDisplay(_INTL("{1} is hurt by the sea of fire!", battler.pbThis))
        }
      end
    end
  end

  #=============================================================================
  # End Of Round healing from Grassy Terrain
  #=============================================================================
  def pbEORTerrainHealing(battler)
    return if battler.fainted?
    # Grassy Terrain (healing)
    if @field.terrain == :Grassy && battler.affectedByTerrain? && battler.canHeal?
      PBDebug.log("[Lingering effect] Grassy Terrain heals #{battler.pbThis(true)}")
      battler.pbRecoverHP(battler.totalhp / 16)
      pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
    end
  end

  #=============================================================================
  # End Of Round various healing effects
  #=============================================================================
  def pbEORHealingEffects(priority)
    # Cologne Case #by low
    # Aqua Ring
    priority.each do |battler|
      next if !battler.effects[PBEffects::AquaRing]
      next if !battler.canHeal?
      hpGain = battler.totalhp / 16
      hpGain = (hpGain * 1.3).floor if battler.hasActiveItem?([:BIGROOT, :COLOGNECASE])
      battler.pbRecoverHP(hpGain)
      pbDisplay(_INTL("Aqua Ring restored {1}'s HP!", battler.pbThis(true)))
    end
    # Ingrain
    priority.each do |battler|
      next if !battler.effects[PBEffects::Ingrain]
      next if !battler.canHeal?
      hpGain = battler.totalhp / 16
      hpGain = (hpGain * 1.3).floor if battler.hasActiveItem?([:BIGROOT, :COLOGNECASE])
      battler.pbRecoverHP(hpGain)
      pbDisplay(_INTL("{1} absorbed nutrients with its roots!", battler.pbThis))
    end
    # Leech Seed
    priority.each do |battler|
      next if battler.effects[PBEffects::LeechSeed] < 0
      next if !battler.takesIndirectDamage?
      recipient = @battlers[battler.effects[PBEffects::LeechSeed]]
      next if !recipient || recipient.fainted?
      pbCommonAnimation("LeechSeed", recipient, battler)
      # leech seed nerf #by low
      dmg = battler.totalhp / 8
      dmg = 100 if dmg > 100 && !battler.pbOwnedByPlayer?
      battler.pbTakeEffectDamage(dmg) { |hp_lost|
        true_hp_lost = hp_lost
        true_hp_lost *= 0.75 if recipient.pbOwnedByPlayer?
        recipient.pbRecoverHPFromDrain(true_hp_lost, battler,
                                       _INTL("{1}'s health is sapped by Leech Seed!", battler.pbThis))
        recipient.pbAbilitiesOnDamageTaken
      }
      recipient.pbFaint if recipient.fainted?
      if !battler.fainted?
        if $player.difficulty_mode?("chaos")
          battler.effects[PBEffects::LeechSeedCount] -= 1
          if battler.effects[PBEffects::LeechSeedCount] <= 0
            battler.effects[PBEffects::LeechSeed]      = -1
            battler.effects[PBEffects::LeechSeedCount] = 0
            pbDisplay(_INTL("{1} was freed from the leech!", battler.pbThis))
          end
        end
      end
    end
  end

  #=============================================================================
  # End Of Round deal damage from status problems
  #=============================================================================
  def pbEORStatusProblemDamage(priority)
  end

  #=============================================================================
  # End Of Round deal damage from effects (except by trapping)
  #=============================================================================
  def pbEOREffectDamage(priority)
    # Damage from sleep (Nightmare)
    priority.each do |battler|
      battler.effects[PBEffects::Nightmare] = false if !battler.asleep?
      next if !battler.effects[PBEffects::Nightmare] || !battler.takesIndirectDamage?
      battler.pbTakeEffectDamage(battler.totalhp / 4) { |hp_lost|
        pbDisplay(_INTL("{1} is locked in a nightmare!", battler.pbThis))
      }
    end
    # Curse
    priority.each do |battler|
      next if !battler.effects[PBEffects::Curse] || !battler.takesIndirectDamage?
      battler.pbTakeEffectDamage(battler.totalhp / 16) { |hp_lost| # 4 -> 16 #by low
        pbDisplay(_INTL("{1} is afflicted by the curse!", battler.pbThis))
      }
    end
  end

  #=============================================================================
  # End Of Round deal damage to trapped battlers
  #=============================================================================
  TRAPPING_MOVE_COMMON_ANIMATIONS = {
    :BIND        => "Bind",
    :CLAMP       => "Clamp",
    :FIRESPIN    => "FireSpin",
    :MAGMASTORM  => "MagmaStorm",
    :SANDTOMB    => "SandTomb",
    :WRAP        => "Wrap",
    :INFESTATION => "Infestation"
  }

  def pbEORTrappingDamage(battler)
    return if battler.fainted? || battler.effects[PBEffects::Trapping] == 0
    battler.effects[PBEffects::Trapping] -= 1
    move_name = GameData::Move.get(battler.effects[PBEffects::TrappingMove]).name
    if battler.effects[PBEffects::Trapping] == 0
      pbDisplay(_INTL("{1} was freed from {2}!", battler.pbThis, move_name))
      return
    end
    anim = TRAPPING_MOVE_COMMON_ANIMATIONS[battler.effects[PBEffects::TrappingMove]] || "Wrap"
    pbCommonAnimation(anim, battler)
    return if !battler.takesIndirectDamage?
    hpLoss = (Settings::MECHANICS_GENERATION >= 6) ? battler.totalhp / 8 : battler.totalhp / 16
    if @battlers[battler.effects[PBEffects::TrappingUser]].hasActiveItem?(:BINDINGBAND)
      hpLoss = (Settings::MECHANICS_GENERATION >= 6) ? battler.totalhp / 6 : battler.totalhp / 8
    end
    @scene.pbDamageAnimation(battler)
    battler.pbTakeEffectDamage(hpLoss, false) { |hp_lost|
      pbDisplay(_INTL("{1} is hurt by {2}!", battler.pbThis, move_name))
    }
  end

  #=============================================================================
  # End Of Round end effects that apply to a battler
  #=============================================================================
  def pbEORCountDownBattlerEffect(priority, effect)
    priority.each do |battler|
      next if battler.fainted? || battler.effects[effect] == 0
      battler.effects[effect] -= 1
      yield battler if block_given? && battler.effects[effect] == 0
    end
  end

  def pbEOREndBattlerEffects(priority)
    # Taunt
    pbEORCountDownBattlerEffect(priority, PBEffects::Taunt) { |battler|
      pbDisplay(_INTL("{1}'s taunt wore off!", battler.pbThis))
    }
    # Encore
    priority.each do |battler|
      next if battler.fainted? || battler.effects[PBEffects::Encore] == 0
      idxEncoreMove = battler.pbEncoredMoveIndex
      if idxEncoreMove >= 0
        battler.effects[PBEffects::Encore] -= 1
        if battler.effects[PBEffects::Encore] == 0 || battler.moves[idxEncoreMove].pp == 0
          battler.effects[PBEffects::Encore] = 0
          pbDisplay(_INTL("{1}'s encore ended!", battler.pbThis))
        end
      else
        PBDebug.log("[End of effect] #{battler.pbThis}'s encore ended (encored move no longer known)")
        battler.effects[PBEffects::Encore]     = 0
        battler.effects[PBEffects::EncoreMove] = nil
      end
    end
    # Disable/Cursed Body
    pbEORCountDownBattlerEffect(priority, PBEffects::Disable) { |battler|
      battler.effects[PBEffects::DisableMove] = nil
      pbDisplay(_INTL("{1} is no longer disabled!", battler.pbThis))
    }
    # Magnet Rise
    pbEORCountDownBattlerEffect(priority, PBEffects::MagnetRise) { |battler|
      pbDisplay(_INTL("{1}'s electromagnetism wore off!", battler.pbThis))
    }
    # Telekinesis
    pbEORCountDownBattlerEffect(priority, PBEffects::Telekinesis) { |battler|
      pbDisplay(_INTL("{1} was freed from the telekinesis!", battler.pbThis))
    }
    # Heal Block
    pbEORCountDownBattlerEffect(priority, PBEffects::HealBlock) { |battler|
      pbDisplay(_INTL("{1}'s Heal Block wore off!", battler.pbThis))
    }
    # Embargo
    pbEORCountDownBattlerEffect(priority, PBEffects::Embargo) { |battler|
      pbDisplay(_INTL("{1} can use items again!", battler.pbThis))
      battler.pbItemTerrainStatBoostCheck
    }
    # Yawn
    pbEORCountDownBattlerEffect(priority, PBEffects::Yawn) { |battler|
      if battler.pbCanSleepYawn?
        PBDebug.log("[Lingering effect] #{battler.pbThis} fell asleep because of Yawn")
        battler.pbSleep
      end
    }
    # Perish Song
    perishSongUsers = []
    priority.each do |battler|
      next if battler.fainted? || battler.effects[PBEffects::PerishSong] == 0
      battler.effects[PBEffects::PerishSong] -= 1
      pbDisplay(_INTL("{1}'s perish count fell to {2}!", battler.pbThis, battler.effects[PBEffects::PerishSong]))
      if battler.effects[PBEffects::PerishSong] == 0
        perishSongUsers.push(battler.effects[PBEffects::PerishSongUser])
        battler.pbReduceHP(battler.hp)
      end
      battler.pbItemHPHealCheck
      battler.pbFaint if battler.fainted?
    end
    # Judge if all remaining Pokemon fainted by a Perish Song triggered by a single side
    if perishSongUsers.length > 0 &&
       ((perishSongUsers.find_all { |idxBattler| opposes?(idxBattler) }.length == perishSongUsers.length) ||
       (perishSongUsers.find_all { |idxBattler| !opposes?(idxBattler) }.length == perishSongUsers.length))
      pbJudgeCheckpoint(@battlers[perishSongUsers[0]])
    end
    return if @decision > 0
  end

  #=============================================================================
  # End Of Round end effects that apply to one side of the field
  #=============================================================================
  def pbEORCountDownSideEffect(side, effect, msg)
    return if @sides[side].effects[effect] <= 0
    @sides[side].effects[effect] -= 1
    pbDisplay(msg) if @sides[side].effects[effect] == 0
  end

  def pbEOREndSideEffects(side, priority)
    # Reflect
    pbEORCountDownSideEffect(side, PBEffects::Reflect,
                             _INTL("{1}'s Reflect wore off!", @battlers[side].pbTeam))
    # Light Screen
    pbEORCountDownSideEffect(side, PBEffects::LightScreen,
                             _INTL("{1}'s Light Screen wore off!", @battlers[side].pbTeam))
    # Safeguard
    pbEORCountDownSideEffect(side, PBEffects::Safeguard,
                             _INTL("{1} is no longer protected by Safeguard!", @battlers[side].pbTeam))
    # Mist
    pbEORCountDownSideEffect(side, PBEffects::Mist,
                             _INTL("{1} is no longer protected by mist!", @battlers[side].pbTeam))
    # Tailwind
    pbEORCountDownSideEffect(side, PBEffects::Tailwind,
                             _INTL("{1}'s Tailwind petered out!", @battlers[side].pbTeam))
    # Lucky Chant
    pbEORCountDownSideEffect(side, PBEffects::LuckyChant,
                             _INTL("{1}'s Lucky Chant wore off!", @battlers[side].pbTeam))
    # Pledge Rainbow
    pbEORCountDownSideEffect(side, PBEffects::Rainbow,
                             _INTL("The rainbow on {1}'s side disappeared!", @battlers[side].pbTeam(true)))
    # Pledge Sea of Fire
    pbEORCountDownSideEffect(side, PBEffects::SeaOfFire,
                             _INTL("The sea of fire around {1} disappeared!", @battlers[side].pbTeam(true)))
    # Pledge Swamp
    pbEORCountDownSideEffect(side, PBEffects::Swamp,
                             _INTL("The swamp around {1} disappeared!", @battlers[side].pbTeam(true)))
    # Aurora Veil
    pbEORCountDownSideEffect(side, PBEffects::AuroraVeil,
                             _INTL("{1}'s Aurora Veil wore off!", @battlers[side].pbTeam))
  end

  #=============================================================================
  # End Of Round end effects that apply to the whole field
  #=============================================================================
  def pbEORCountDownFieldEffect(effect, msg)
    return if @field.effects[effect] <= 0
    @field.effects[effect] -= 1
    return if @field.effects[effect] > 0
    pbDisplay(msg)
    if effect == PBEffects::MagicRoom
      pbPriority(true).each { |battler| battler.pbItemTerrainStatBoostCheck }
    end
  end

  def pbEOREndFieldEffects(priority)
    # Trick Room
    pbEORCountDownFieldEffect(PBEffects::TrickRoom,
                              _INTL("The twisted dimensions returned to normal!"))
    # Gravity
    pbEORCountDownFieldEffect(PBEffects::Gravity,
                              _INTL("Gravity returned to normal!"))
    # Water Sport
    pbEORCountDownFieldEffect(PBEffects::WaterSportField,
                              _INTL("The effects of Water Sport have faded."))
    # Mud Sport
    pbEORCountDownFieldEffect(PBEffects::MudSportField,
                              _INTL("The effects of Mud Sport have faded."))
    # Wonder Room
    pbEORCountDownFieldEffect(PBEffects::WonderRoom,
                              _INTL("Wonder Room wore off, and Defense and Sp. Def stats returned to normal!"))
    # Magic Room
    pbEORCountDownFieldEffect(PBEffects::MagicRoom,
                              _INTL("Magic Room wore off, and held items' effects returned to normal!"))
  end

  #=============================================================================
  # End Of Round end terrain check
  #=============================================================================
  def pbEOREndTerrain
    # Count down terrain duration
    @field.terrainDuration -= 1 if @field.terrainDuration > 0
    # Terrain wears off
    if @field.terrain != :None && @field.terrainDuration == 0
      case @field.terrain
      when :Electric
        pbDisplay(_INTL("The electric current disappeared from the battlefield!"))
      when :Grassy
        pbDisplay(_INTL("The grass disappeared from the battlefield!"))
      when :Misty
        pbDisplay(_INTL("The mist disappeared from the battlefield!"))
      when :Psychic
        pbDisplay(_INTL("The weirdness disappeared from the battlefield!"))
      end
      @field.terrain = :None
      allBattlers.each { |battler| battler.pbAbilityOnTerrainChange }
      # Start up the default terrain
      if @field.defaultTerrain != :None
        pbStartTerrain(nil, @field.defaultTerrain, false)
        allBattlers.each { |battler| battler.pbAbilityOnTerrainChange }
        allBattlers.each { |battler| battler.pbItemTerrainStatBoostCheck }
      end
      return if @field.terrain == :None
    end
    # Terrain continues
    terrain_data = GameData::BattleTerrain.try_get(@field.terrain)
    pbCommonAnimation(terrain_data.animation) if terrain_data
    case @field.terrain
    when :Electric then pbDisplay(_INTL("An electric current is running across the battlefield."))
    when :Grassy   then pbDisplay(_INTL("Grass is covering the battlefield."))
    when :Misty    then pbDisplay(_INTL("Mist is swirling about the battlefield."))
    when :Psychic  then pbDisplay(_INTL("The battlefield is weird."))
    end
  end

  #=============================================================================
  # End Of Round end self-inflicted effects on battler
  #=============================================================================
  def pbEOREndBattlerSelfEffects(battler)
    return if battler.fainted?
    # Hyper Mode (Shadow Pokémon)
    if battler.inHyperMode?
      if pbRandom(100) < 10
        battler.pokemon.hyper_mode = false
        pbDisplay(_INTL("{1} came to its senses!", battler.pbThis))
      else
        pbDisplay(_INTL("{1} is in Hyper Mode!", battler.pbThis))
      end
    end
    # Uproar
    if battler.effects[PBEffects::Uproar] > 0
      battler.effects[PBEffects::Uproar] -= 1
      if battler.effects[PBEffects::Uproar] == 0
        pbDisplay(_INTL("{1} calmed down.", battler.pbThis))
      else
        pbDisplay(_INTL("{1} is making an uproar!", battler.pbThis))
      end
    end
    # moved slow start counter to *Battle_AbilityEffects #by low
  end

  #=============================================================================
  # End Of Round shift distant battlers to middle positions
  #=============================================================================
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
        case pbSideSize(side)
        when 2
          pbDisplay(_INTL("{1} moved across!", @battlers[pair[1]].pbThis))
        when 3
          pbDisplay(_INTL("{1} moved to the center!", @battlers[pair[1]].pbThis))
        end
      end
    end
  end

  #=============================================================================
  # Main End Of Round phase method
  #=============================================================================
  def pbEndOfRoundPhase
    PBDebug.log("")
    PBDebug.log("[End of round]")
    @endOfRound = true
    @scene.pbBeginEndOfRoundPhase
    pbCalculatePriority           # recalculate speeds
    priority = pbPriority(true)   # in order of fastest -> slowest speeds only
    # Weather
    pbEOREndWeather(priority)
    # Future Sight/Doom Desire
    @positions.each_with_index { |pos, idxPos| pbEORUseFutureSight(pos, idxPos) }
    # Wish
    pbEORWishHealing
    # Sea of Fire damage (Fire Pledge + Grass Pledge combination)
    pbEORSeaOfFireDamage(priority)
    # Status-curing effects/abilities and HP-healing items
    priority.each do |battler|
      pbEORTerrainHealing(battler)
      # Healer, Hydration, Shed Skin
      if battler.abilityActive?
        Battle::AbilityEffects.triggerEndOfRoundHealing(battler.ability, battler, self)
      end
      # Black Sludge, Leftovers
      if battler.itemActive?
        Battle::ItemEffects.triggerEndOfRoundHealing(battler.item, battler, self)
      end
    end
    # Self-curing of status due to affection
    # this is disgusting, fuck off
    if Settings::AFFECTION_EFFECTS && @internalBattle
      priority.each do |battler|
        next if battler.fainted? || battler.status == :NONE
        next if !battler.pbOwnedByPlayer? || battler.affection_level < 4 || battler.mega?
        next if pbRandom(100) < 80
        old_status = battler.status
        battler.pbCureStatus(false)
        case old_status
        when :SLEEP
          pbDisplay(_INTL("{1} shook itself awake so you wouldn't worry!", battler.pbThis))
        when :POISON
          pbDisplay(_INTL("{1} managed to expel the poison so you wouldn't worry!", battler.pbThis))
        when :BURN
          pbDisplay(_INTL("{1} healed its burn with its sheer determination so you wouldn't worry!", battler.pbThis))
        when :PARALYSIS
          pbDisplay(_INTL("{1} gathered all its energy to break through its paralysis so you wouldn't worry!", battler.pbThis))
        when :FROZEN
          pbDisplay(_INTL("{1} melted the ice with its fiery determination so you wouldn't worry!", battler.pbThis))
        end
      end
    end
    # Healing from Aqua Ring, Ingrain, Leech Seed
    pbEORHealingEffects(priority)
    # Damage from Hyper Mode (Shadow Pokémon)
    priority.each do |battler|
      next if !battler.inHyperMode? || @choices[battler.index][0] != :UseMove
      hpLoss = battler.totalhp / 24
      @scene.pbDamageAnimation(battler)
      battler.pbReduceHP(hpLoss, false)
      pbDisplay(_INTL("The Hyper Mode attack hurts {1}!", battler.pbThis(true)))
      battler.pbFaint if battler.fainted?
    end
    # Damage from poison/burn
    pbEORStatusProblemDamage(priority)
    # Damage from Nightmare and Curse
    pbEOREffectDamage(priority)
    # Trapping attacks (Bind/Clamp/Fire Spin/Magma Storm/Sand Tomb/Whirlpool/Wrap)
    priority.each { |battler| pbEORTrappingDamage(battler) }
    # Octolock
    priority.each do |battler|
      next if battler.fainted? || battler.effects[PBEffects::Octolock] < 0
      pbCommonAnimation("Octolock", battler)
      battler.pbLowerStatStage(:DEFENSE, 1, nil) if battler.pbCanLowerStatStage?(:DEFENSE)
      battler.pbLowerStatStage(:SPECIAL_DEFENSE, 1, nil) if battler.pbCanLowerStatStage?(:SPECIAL_DEFENSE)
      battler.pbItemOnStatDropped
    end
    # Effects that apply to a battler that wear off after a number of rounds
    pbEOREndBattlerEffects(priority)
    # Check for end of battle (i.e. because of Perish Song)
    if @decision > 0
      pbGainExp
      return
    end
    # Effects that apply to a side that wear off after a number of rounds
    2.times { |side| 
      pbEOREndSideEffects(side, priority)
      if @field.weather != :Hail && @sides[side].effects[PBEffects::AuroraVeil] > 0 #by low
        @sides[side].effects[PBEffects::AuroraVeil] = 0
        pbDisplay(_INTL("Due to the lack of Hail, {1}'s Aurora Veil wore off!", @battlers[side].pbTeam))
      end
    }
    # Effects that apply to the whole field that wear off after a number of rounds
    pbEOREndFieldEffects(priority)
    # End of terrains
    pbEOREndTerrain
    priority.each do |battler|
      # Self-inflicted effects that wear off after a number of rounds
      pbEOREndBattlerSelfEffects(battler)
      # Bad Dreams, Moody, Speed Boost
      if battler.abilityActive?
        Battle::AbilityEffects.triggerEndOfRoundEffect(battler.ability, battler, self)
      end
      # Flame Orb, Sticky Barb, Toxic Orb
      if battler.itemActive?
        Battle::ItemEffects.triggerEndOfRoundEffect(battler.item, battler, self)
      end
      # Harvest, Pickup, Ball Fetch
      if battler.abilityActive?
        Battle::AbilityEffects.triggerEndOfRoundGainItem(battler.ability, battler, self)
      end
    end
    pbGainExp
    return if @decision > 0
    # Form checks
    priority.each { |battler| battler.pbCheckForm(true) }
    # Switch Pokémon in if possible
    pbEORSwitch
    return if @decision > 0
    # In battles with at least one side of size 3+, move battlers around if none
    # are near to any foes
    pbEORShiftDistantBattlers
    # Try to make Trace work, check for end of primordial weather
    priority.each { |battler| battler.pbContinualAbilityChecks }
    allBattlers.each do |battler| # the big funny #by low
      if battler.pbOwnedByPlayer?
        if $game_temp.party_speed_boost_number && $game_temp.party_speed_boost_number[battler.pokemonIndex]
          $game_temp.party_speed_boost_number[battler.pokemonIndex] = battler.stages[:SPEED]
        end
        
        battler.pokemon.evolution_steps += 1 if battler.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky") && battler.isSpecies?(:DUNSPARCE)
        for i in $Trainer.party
          if [:BANAGNAW, :NANAHI, :POTASSOPOD].include?(i.species) && i.fainted?
            $game_temp.party_dead_bananas[battler.pokemonIndex] += 1
          end
        end
      end
    end
    # Reset/count down battler-specific effects (no messages)
    allBattlers.each do |battler|
      battler.effects[PBEffects::BanefulBunker]    = false
      battler.effects[PBEffects::Charge]           -= 1 if battler.effects[PBEffects::Charge] > 0
      battler.effects[PBEffects::Counter]          = -1
      battler.effects[PBEffects::CounterTarget]    = -1
      battler.effects[PBEffects::Electrify]        = false
      battler.effects[PBEffects::Endure]           = false
      battler.effects[PBEffects::FirstPledge]      = nil
      battler.effects[PBEffects::Flinch]           = false
      battler.effects[PBEffects::FocusPunch]       = false
      battler.effects[PBEffects::FollowMe]         = 0
      battler.effects[PBEffects::HelpingHand]      = false
      battler.effects[PBEffects::HyperBeam]        -= 1 if battler.effects[PBEffects::HyperBeam] > 0
      battler.effects[PBEffects::KingsShield]      = false
      battler.effects[PBEffects::LaserFocus]       -= 1 if battler.effects[PBEffects::LaserFocus] > 0
      if battler.effects[PBEffects::LockOn] > 0   # Also Mind Reader
        battler.effects[PBEffects::LockOn]         -= 1
        battler.effects[PBEffects::LockOnPos]      = -1 if battler.effects[PBEffects::LockOn] == 0
      end
      battler.effects[PBEffects::MagicBounce]      = false
      battler.effects[PBEffects::MagicCoat]        = false
      battler.effects[PBEffects::MirrorCoat]       = -1
      battler.effects[PBEffects::MirrorCoatTarget] = -1
      battler.effects[PBEffects::Obstruct]         = false
      battler.effects[PBEffects::Powder]           = false
      battler.effects[PBEffects::Prankster]        = false
      battler.effects[PBEffects::PriorityAbility]  = false
      battler.effects[PBEffects::PriorityItem]     = false
      battler.effects[PBEffects::Protect]          = false
      battler.effects[PBEffects::RagePowder]       = false
      battler.effects[PBEffects::Roost]            = false
      battler.effects[PBEffects::Snatch]           = 0
      battler.effects[PBEffects::SpikyShield]      = false
      battler.effects[PBEffects::Spotlight]        = 0
      battler.effects[PBEffects::ThroatChop]       -= 1 if battler.effects[PBEffects::ThroatChop] > 0
      # new effects #by low
      battler.effects[PBEffects::NoFlinch]         -= 1 if battler.effects[PBEffects::NoFlinch] > 0
      battler.effects[PBEffects::ZealousDance]     -= 1 if battler.effects[PBEffects::ZealousDance] > 0
      battler.effects[PBEffects::PrioEchoChamber]  -= 1 if battler.effects[PBEffects::PrioEchoChamber] > 0
      battler.effects[PBEffects::HoldingHand]      = false
      battler.pokemon.willmega                     = false
      battler.lastHPLost                           = 0
      battler.lastHPLostFromFoe                    = 0
      battler.droppedBelowHalfHP                   = false
      battler.statsDropped                         = false
      battler.tookDamageThisRound                  = false
      battler.tookPhysicalHit                      = false
      battler.statsRaisedThisRound                 = false
      battler.statsLoweredThisRound                = false
      battler.canRestoreIceFace                    = false
      battler.lastRoundMoveFailed                  = battler.lastMoveFailed
      battler.lastAttacker.clear
      battler.lastFoeAttacker.clear
    end
    # Reset/count down side-specific effects (no messages)
    2.times do |side|
      @sides[side].effects[PBEffects::CraftyShield]         = false
      if !@sides[side].effects[PBEffects::EchoedVoiceUsed]
        @sides[side].effects[PBEffects::EchoedVoiceCounter] = 0
      end
      @sides[side].effects[PBEffects::EchoedVoiceUsed]      = false
      @sides[side].effects[PBEffects::MatBlock]             = false
      @sides[side].effects[PBEffects::QuickGuard]           = false
      @sides[side].effects[PBEffects::Round]                = false
      @sides[side].effects[PBEffects::WideGuard]            = false
    end
    # Reset/count down field-specific effects (no messages)
    @field.effects[PBEffects::IonDeluge]   = false
    @field.effects[PBEffects::FairyLock]   -= 1 if @field.effects[PBEffects::FairyLock] > 0
    @field.effects[PBEffects::FusionBolt]  = false
    @field.effects[PBEffects::FusionFlare] = false
    @endOfRound = false
  end
end
