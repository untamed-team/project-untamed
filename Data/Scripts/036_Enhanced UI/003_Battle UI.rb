#===============================================================================
# Initializes Battle UI elements.
#===============================================================================
class Battle::Scene
  #-----------------------------------------------------------------------------
  # White text.
  #-----------------------------------------------------------------------------
  BASE_LIGHT     = Color.new(232, 232, 232)
  SHADOW_LIGHT   = Color.new(72, 72, 72)
  #-----------------------------------------------------------------------------
  # Black text.
  #-----------------------------------------------------------------------------
  BASE_DARK      = Color.new(56, 56, 56)
  SHADOW_DARK    = Color.new(184, 184, 184)
  #-----------------------------------------------------------------------------
  # Green text. Used to display bonuses.
  #-----------------------------------------------------------------------------
  BASE_RAISED    = Color.new(50, 205, 50)
  SHADOW_RAISED  = Color.new(9, 121, 105)
  #-----------------------------------------------------------------------------
  # Red text. Used to display penalties.
  #-----------------------------------------------------------------------------
  BASE_LOWERED   = Color.new(248, 72, 72)
  SHADOW_LOWERED = Color.new(136, 48, 48)


  alias enhanced_pbInitSprites pbInitSprites
  def pbInitSprites
    enhanced_pbInitSprites
    @path = "Graphics/Plugins/Enhanced UI/Battle/"
    #---------------------------------------------------------------------------
    # Move info UI.
    #---------------------------------------------------------------------------
    @moveUIToggle = false
    @sprites["moveinfo"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["moveinfo"].z = 300
    @sprites["moveinfo"].visible = @moveUIToggle
    pbSetSmallFont(@sprites["moveinfo"].bitmap)
    @moveUIOverlay = @sprites["moveinfo"].bitmap
    #---------------------------------------------------------------------------
    # Battle info UI.
    #---------------------------------------------------------------------------
    @infoUIToggle = false
    @sprites["infobitmap"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["infobitmap"].z = 300
    @sprites["infobitmap"].visible = @infoUIToggle
    @infoUIOverlay1 = @sprites["infobitmap"].bitmap
    @sprites["infoselect"] = IconSprite.new(0, 0, @viewport)
    @sprites["infoselect"].setBitmap("Graphics/Plugins/Enhanced UI/Battle/battler_sel")
    @sprites["infoselect"].src_rect.set(0, 52, 166, 52)
    @sprites["infoselect"].visible = @infoUIToggle
    @sprites["infoselect"].z = 300
    @sprites["infotext"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["infotext"].z = 300
    @sprites["infotext"].visible = @infoUIToggle
    pbSetSmallFont(@sprites["infotext"].bitmap)
    @infoUIOverlay2 = @sprites["infotext"].bitmap
    @sprites["leftarrow"] = AnimatedSprite.new("Graphics/Pictures/leftarrow", 8, 40, 28, 2, @viewport)
    @sprites["leftarrow"].x = -2
    @sprites["leftarrow"].y = 71
    @sprites["leftarrow"].z = 300
    @sprites["leftarrow"].play
    @sprites["leftarrow"].visible = false
    @sprites["rightarrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow", 8, 40, 28, 2, @viewport)
    @sprites["rightarrow"].x = Graphics.width - 38
    @sprites["rightarrow"].y = 71
    @sprites["rightarrow"].z = 300
    @sprites["rightarrow"].play
    @sprites["rightarrow"].visible = false
  end
  
  #-----------------------------------------------------------------------------
  # Toggles the display of battle UI's while in the Fight Menu.
  #-----------------------------------------------------------------------------
  def pbFightMenu_EnhancedUI(battler, cw)
    #if Input.triggerex?(Settings::MOVE_INFO_KEY)
    #modified by Gardenette
    if Input.trigger?(Settings::MOVE_INFO_KEY)
      pbHideBattleInfo
      pbHideFocusPanel
      pbToggleMoveInfo(battler, cw.index)
    #elsif Input.triggerex?(Settings::BATTLE_INFO_KEY)
    #modified by Gardenette
    elsif Input.trigger?(Settings::BATTLE_INFO_KEY)
      pbHideMoveInfo
      pbHideFocusPanel
      pbToggleBattleInfo
    end
  end


#===============================================================================
# Move Info UI
#===============================================================================

  #-----------------------------------------------------------------------------
  # Draws the Move Info UI.
  #-----------------------------------------------------------------------------
  def pbUpdateMoveInfoWindow(battler, index)
    @moveUIOverlay.clear
    return if !@moveUIToggle
    xpos = 0
    ypos = 94
    move = battler.moves[index]
    type = move.pbCalcType(battler)
    if battler.power_trigger && move.function == "CategoryDependsOnHigherDamageTera"
      type = battler.tera_type
    end
    #---------------------------------------------------------------------------
    # Draws images.
    typenumber = GameData::Type.get(type).icon_position
    imagePos = [
      [@path + "move_info_bg",       xpos, ypos],
      ["Graphics/Pictures/types",    xpos + 272, ypos + 4, 0, typenumber * 28, 64, 28],
      ["Graphics/Pictures/category", xpos + 336, ypos + 4, 0, move.category * 28, 64, 28]
    ]
    imagePos += pbDrawMoveFlagIcons(xpos, ypos, move)
    imagePos += pbDrawTypeEffectiveness(xpos, ypos, move, type)
    pbDrawImagePositions(@moveUIOverlay, imagePos)
    #---------------------------------------------------------------------------
    # Move damage calculations (for display purposes).
    @dmg_base   = @acc_base   = @eff_base   = BASE_LIGHT
    @dmg_shadow = @acc_shadow = @eff_shadow = SHADOW_LIGHT
    damage = base_dmg = calc_dmg = move.baseDamage
    stab = 1
    if battler.tera? || (battler.power_trigger && @sprites["fightWindow"].teraType > 0)
      if battler.tera_type == type && battler.pokemon.types.include?(type)
        stab = 2
      elsif battler.tera_type == type || battler.pokemon.types.include?(type)
        stab = 1.5
      end
    else
      stab = 1.5 if battler.pbHasType?(type)
    end
    if move.damagingMove?
      if pbVariablePowerFunctions.include?(move.function) ||
         # Natural Gift called here specifically to check for a berry first.
         move.function == "TypeAndPowerDependOnUserBerry" && battler.item
        calc_dmg = move.pbBaseDamage(move.baseDamage, battler, battler.pbDirectOpposing)
      # Earthquake weakened in Grassy Terrain.
      elsif move.function == "DoublePowerIfTargetUnderground"
        calc_dmg /= 2 if @battle.field.terrain == :Grassy
      end
      range = base_dmg - calc_dmg
      # Calc is inverted for Eruption/Water Spout.
      range = -range if move.function == "PowerHigherWithUserHP"
      real_dmg = (calc_dmg * stab).floor
      damage = (real_dmg >= range) ? real_dmg : (base_dmg * stab).floor
      calc_dmg = damage if damage > base_dmg
      if damage > 1
        if calc_dmg > base_dmg
          @dmg_base, @dmg_shadow = BASE_RAISED, SHADOW_RAISED
        elsif damage < (base_dmg * stab).floor
          @dmg_base, @dmg_shadow = BASE_LOWERED, SHADOW_LOWERED
        end
      end
    end
    #---------------------------------------------------------------------------
    # Draws text.
    textPos = []
    textPos += pbAddPluginText(xpos, ypos, move, battler)
    power = (damage == 0) ? "---" : (damage == 1) ? "???" : damage.to_s
    accuracy = (move.accuracy == 0) ? "---" : move.accuracy.to_s
    fangmove = ["ParalyzeFlinchTarget", "BurnFlinchTarget", "FreezeFlinchTarget"].include?(move.function)
    effectrate = (move.addlEffect == 0) ? "---" : fangmove ? "10%" : move.addlEffect.to_s + "%"
    textPos.push(
      [move.name,       xpos + 10,            ypos + 8,  0, BASE_LIGHT, SHADOW_LIGHT],
      [_INTL("Pow:"),   Graphics.width - 86,  ypos + 10, 2, BASE_LIGHT, SHADOW_LIGHT],
      [_INTL("Acc:"),   Graphics.width - 86,  ypos + 39, 2, BASE_LIGHT, SHADOW_LIGHT],
      [_INTL("Effct:"), xpos + 287,           ypos + 39, 0, BASE_LIGHT, SHADOW_LIGHT],
      [power,           Graphics.width - 34,  ypos + 10, 2, @dmg_base, @dmg_shadow],
      [accuracy,        Graphics.width - 34,  ypos + 39, 2, @acc_base, @acc_shadow],
      [effectrate,      Graphics.width - 146, ypos + 39, 2, @eff_base, @eff_shadow]
    )
    pbDrawTextPositions(@moveUIOverlay, textPos)
    drawTextEx(@moveUIOverlay, xpos + 10, ypos + 70, Graphics.width - 10, 2, GameData::Move.get(move.id).description, BASE_LIGHT, SHADOW_LIGHT)
  end
  
  
  #-----------------------------------------------------------------------------
  # Toggles the visibility of the Move Info UI.
  #-----------------------------------------------------------------------------
  def pbToggleMoveInfo(battler, index = 0)
    @moveUIToggle = !@moveUIToggle
    (@moveUIToggle) ? pbSEPlay("GUI party switch") : pbPlayCloseMenuSE
    @sprites["moveinfo"].visible = @moveUIToggle
    pbUpdateTargetIcons
    pbUpdateMoveInfoWindow(battler, index)
  end


  #-----------------------------------------------------------------------------
  # Updates icon sprites to be used for the Move Info UI.
  #-----------------------------------------------------------------------------
  def pbUpdateTargetIcons
    idx = 0
    @battle.allBattlers.each do |b|
      if b && !b.fainted? && b.index.odd?
        @sprites["battler_icon#{b.index}"].pokemon = b.displayPokemon
        @sprites["battler_icon#{b.index}"].visible = @moveUIToggle
        @sprites["battler_icon#{b.index}"].x = Graphics.width - 32 - (idx * 64)
        @sprites["battler_icon#{b.index}"].y = 68
        @sprites["battler_icon#{b.index}"].zoom_x = 1
        @sprites["battler_icon#{b.index}"].zoom_y = 1
        @sprites["battler_icon#{b.index}"].applyIconEffects
        idx += 1
      else
        @sprites["battler_icon#{b.index}"].visible = false
      end
    end
  end
  
  
  #-----------------------------------------------------------------------------
  # Function codes for moves that display variable power in the Move Info UI.
  #-----------------------------------------------------------------------------
  def pbVariablePowerFunctions
    return [
	  "LowerTargetDefense1PowersUpInGravity",      # Grav Apple
	  "LowerTargetSpeed1WeakerInGrassyTerrain",    # Bulldoze
	  "PowerHigherWithUserHP",                     # Eruption, Water Spout
	  "PowerLowerWithUserHP",                      # Flail, Reversal
	  "PowerHigherWithUserPositiveStatStages",     # Power Trip, Stored Power
	  "PowerHigherWithLessPP",                     # Trump Card
	  "PowerHigherWithUserHappiness",              # Return
	  "PowerLowerWithUserHappiness",               # Frustration
	  "PowerHigherWithConsecutiveUse",             # Fury Cutter
	  "PowerHigherWithConsecutiveUseOnUserSide",   # Echoed Voice
	  "DoublePowerIfUserPoisonedBurnedParalyzed",  # Facade
	  "DoublePowerInElectricTerrain",              # Rising Voltage
	  "DoublePowerIfUserLastMoveFailed",           # Stomping Tantrum
	  "DoublePowerIfAllyFaintedLastTurn",          # Retaliate
	  "TypeDependsOnUserIVs",                      # Hidden Power
	  "TypeAndPowerDependOnWeather",               # Weather Ball
	  "TypeAndPowerDependOnTerrain",               # Terrain Pulse
	  "HitTwoToFiveTimesOrThreeForAshGreninja",    # Water Shuriken
	  "UserFaintsPowersUpInMistyTerrainExplosive", # Misty Explosion
	  "ThrowUserItemAtTarget",                     # Fling
	  "HitsAllFoesAndPowersUpInPsychicTerrain",    # Expanding Force
	  "PowerDependsOnUserStockpile"                # Spit Up
	]
  end
  
  
  #-----------------------------------------------------------------------------
  # Draws the type effectiveness display for each opponent in the Move Info UI.
  #-----------------------------------------------------------------------------
  def pbDrawTypeEffectiveness(xpos, ypos, move, type)
    images = []
    idx = 0
    @battle.allBattlers.each do |b|
      next if b.index.even?
      if b && !b.fainted? && move.category < 2
        poke = b.displayPokemon
        unknown_species = ($player.pokedex.battled_count(poke.species) == 0 && !$player.pokedex.owned?(poke.species))
        unknown_species = false if Settings::ALWAYS_DISPLAY_TYPES
        unknown_species = true if b.celestial?
        value = Effectiveness.calculate(type, poke.types[0], poke.types[1])
        if unknown_species                             then effct = 0
        elsif Effectiveness.ineffective?(value)        then effct = 1
        elsif Effectiveness.not_very_effective?(value) then effct = 2
        elsif Effectiveness.super_effective?(value)    then effct = 3
        else effct = 4
        end
        images.push([@path + "move_effectiveness", Graphics.width - 64 - (idx * 64), ypos - 76, effct * 64, 0, 64, 76])
        @sprites["battler_icon#{b.index}"].visible = true
      else
        @sprites["battler_icon#{b.index}"].visible = false
      end
      idx += 1
    end
    return images
  end
  
  
  #-----------------------------------------------------------------------------
  # Draws the move flag icons for each move in the Move Info UI.
  #-----------------------------------------------------------------------------
  def pbDrawMoveFlagIcons(xpos, ypos, move)
    flagX = xpos + 5
    flagY = ypos + 32
    images = []
    if PluginManager.installed?("ZUD Mechanics")
      if move.zMove?
        images.push([@path + "move_icons", flagX + (images.length * 26), flagY, 0 * 26, 0, 26, 28])
      elsif move.maxMove?
        images.push([@path + "move_icons", flagX + (images.length * 26), flagY, 1 * 26, 0, 26, 28])
      end
    end
    if GameData::Target.get(move.target).targets_foe
      images.push([@path + "move_icons", flagX + (images.length * 26), flagY, 2 * 26, 0, 26, 28]) if !move.flags.include?("CanProtect")
      images.push([@path + "move_icons", flagX + (images.length * 26), flagY, 3 * 26, 0, 26, 28]) if !move.flags.include?("CanMirrorMove")
    end
    move.flags.each do |flag|
      idx = -1
      case flag
      when "Contact"             then idx = 4
      when "TramplesMinimize"    then idx = 5
      when "HighCriticalHitRate" then idx = 6
      when "ThawsUser"           then idx = 7
      when "Sound"               then idx = 8
      when "Punching"            then idx = 9
      when "Biting"              then idx = 10
      when "Bomb"                then idx = 11
      when "Pulse"               then idx = 12
      when "Powder"              then idx = 13
      when "Dance"               then idx = 14
      when "Slicing"             then idx = 15
      when "Wind"                then idx = 16
      end
      next if idx < 0
      images.push([@path + "move_icons", flagX + (images.length * 26), flagY, idx * 26, 0, 26, 28])
    end
    return images
  end
  
  
  #-----------------------------------------------------------------------------
  # Draws additional plugin-specific text to be displayed in the Move Info UI.
  #-----------------------------------------------------------------------------
  def pbAddPluginText(xpos, ypos, move, battler)
    addText = []
    #---------------------------------------------------------------------------
    # Sets up additional text for Z-Moves. (ZUD)
    #---------------------------------------------------------------------------
    if PluginManager.installed?("ZUD Mechanics") && move.zMove? && move.category == 2
      if GameData::PowerMove.stat_booster?(move.id)
        stats, stage = GameData::PowerMove.stat_with_stage(move.id)
        statname = (stats.length > 1) ? "stats" : GameData::Stat.get(stats.first).name
        case stage
        when 3 then boost = " drastically"
        when 2 then boost = " sharply"
        else        boost = ""
        end
        text = _INTL("Raises the user's #{statname}#{boost}.")
      elsif GameData::PowerMove.boosts_crit?(move.id)  then text = _INTL("Raises the user's critical hit rate.")
      elsif GameData::PowerMove.resets_stats?(move.id) then text = _INTL("Resets the user's lowered stat stages.")
      elsif GameData::PowerMove.heals_self?(move.id)   then text = _INTL("Fully restores the user's HP.")
      elsif GameData::PowerMove.heals_switch?(move.id) then text = _INTL("Fully restores an incoming Pokémon's HP.")
      elsif GameData::PowerMove.focus_user?(move.id)   then text = _INTL("The user becomes the center of attention.")
      end
      addText.push([_INTL("Z-Power: #{text}"), xpos + 10, ypos + 128, 0, BASE_RAISED, SHADOW_RAISED]) if text
    #---------------------------------------------------------------------------
    # Sets up additional text for moves affected by Battle Styles. (PLA)
    #---------------------------------------------------------------------------
    elsif PluginManager.installed?("PLA Battle Styles") && move.mastered?
      case battler.style_trigger
      when 1
        if move.baseDamage > 1
          @dmg_base, @dmg_shadow = BASE_RAISED, SHADOW_RAISED
        end
        if ![0, 100].include?(move.old_accuracy)
          @acc_base, @acc_shadow = BASE_RAISED, SHADOW_RAISED
        end
        if ![0, 100].include?(move.old_addlEffect)
          @eff_base, @eff_shadow = BASE_RAISED, SHADOW_RAISED
        end
        if move.strongStyleStatUp?
          addText.push([_INTL("Strong Style: Number of stat stages raised +1."), xpos + 10, ypos + 128, 0, BASE_RAISED, SHADOW_RAISED])
        elsif move.strongStyleStatDown?
          addText.push([_INTL("Strong Style: Number of stat stages lowered +1."), xpos + 10, ypos + 128, 0, BASE_RAISED, SHADOW_RAISED])
        elsif move.strongStyleHealing?
          addText.push([_INTL("Strong Style: The amount of HP healed is increased."), xpos + 10, ypos + 128, 0, BASE_RAISED, SHADOW_RAISED])
        elsif move.strongStyleRecoil?
          addText.push([_INTL("Strong Style: The amount of recoil taken is increased."), xpos + 10, ypos + 128, 0, BASE_LOWERED, SHADOW_LOWERED])
        end
      when 2
        if move.baseDamage > 1 
          @dmg_base, @dmg_shadow = BASE_LOWERED, SHADOW_LOWERED
        end
        if move.agileStyleStatUp?
          addText.push([_INTL("Agile Style: Number of stat stages raised -1."), xpos + 10, ypos + 128, 0, BASE_LOWERED, SHADOW_LOWERED])
          elsif move.agileStyleStatDown?
          addText.push([_INTL("Agile Style: Number of stat stages lowered -1."), xpos + 10, ypos + 128, 0, BASE_LOWERED, SHADOW_LOWERED])
        elsif move.agileStyleHealing?
          addText.push([_INTL("Agile Style: The amount of HP healed is reduced."), xpos + 10, ypos + 128, 0, BASE_LOWERED, SHADOW_LOWERED])
        elsif move.agileStyleRecoil?
          addText.push([_INTL("Agile Style: The amount of recoil taken is reduced."), xpos + 10, ypos + 128, 0, BASE_RAISED, SHADOW_RAISED])
        end
      end
    #---------------------------------------------------------------------------
    # Sets up additional text for moves affected by Terastallization. (Terastal)
    #---------------------------------------------------------------------------
    elsif PluginManager.installed?("Terastal Phenomenon") && battler.tera? && battler.tera_type == move.pbCalcType(battler)
      addText.push([_INTL("Tera Type: Power boosted by Terastallization."), xpos + 10, ypos + 128, 0, BASE_RAISED, SHADOW_RAISED])
    end
    return addText
  end
  
  
#===============================================================================
# Battle Info UI
#===============================================================================
  
  #-----------------------------------------------------------------------------
  # Handles the controls for the selection screen for the Battle Info UI.
  #-----------------------------------------------------------------------------
  def pbSelectBattlerInfo
    return if !@infoUIToggle
    idxSide = 0
    idxPoke = (@battle.pbSideBattlerCount(0) < 3) ? 0 : 1
    @sprites["infoselect"].x = (@battle.pbSideBattlerCount(0) == 2) ? 68 : 173 
    @sprites["infoselect"].y = 154
    battlers = [[], []]
    @battle.allSameSideBattlers.each { |b| battlers[0].push(b) }
    @battle.allOtherSideBattlers.reverse.each { |b| battlers[1].push(b) }
    battler = battlers[idxSide][idxPoke]
    pbShowOutline("battler_icon#{battler.index}")
    cw = @sprites["fightWindow"]
    switchUI = 0
    loop do
      pbUpdate(cw)
      pbUpdateSpriteHash(@sprites)
      oldSide = idxSide
      oldPoke = idxPoke
      #break if Input.trigger?(Input::BACK) || Input.triggerex?(Settings::BATTLE_INFO_KEY)
      #modified by Gardenette
      break if Input.trigger?(Input::BACK) || Input.trigger?(Settings::BATTLE_INFO_KEY)
      if Input.trigger?(Input::USE)
        pbPlayDecisionSE
        ret = pbOpenBattlerInfo(battler, battlers)
        case ret
        when Array
          idxSide, idxPoke = ret[0], ret[1]
          battler = battlers[idxSide][idxPoke]
          pbUpdateBattlerSelection(ret)
          pbShowOutline("battler_icon#{battler.index}")
        when Numeric
          switchUI = ret
          break
        when nil then break
        end
      elsif Input.trigger?(Input::LEFT) && @battle.pbSideBattlerCount(idxSide) > 1
        idxPoke -= 1
        idxPoke = @battle.pbSideBattlerCount(idxSide) - 1 if idxPoke < 0
        pbPlayCursorSE
      elsif Input.trigger?(Input::RIGHT) && @battle.pbSideBattlerCount(idxSide) > 1
        idxPoke += 1
        idxPoke = 0 if idxPoke > @battle.pbSideBattlerCount(idxSide) - 1
        pbPlayCursorSE
      elsif Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN)
        idxSide = (idxSide == 0) ? 1 : 0
        if idxPoke > @battle.pbSideBattlerCount(idxSide) - 1
          until idxPoke == @battle.pbSideBattlerCount(idxSide) - 1
            idxPoke -= 1
          end
        end
        pbPlayCursorSE
      #elsif cw.visible && Input.triggerex?(Settings::MOVE_INFO_KEY)
      #modified by Gardenette
      elsif cw.visible && Input.trigger?(Settings::MOVE_INFO_KEY)
        switchUI = 1
        break
      elsif PluginManager.installed?("Focus Meter System") && Input.triggerex?(Settings::FOCUS_PANEL_KEY)
        switchUI = 2
        break
      end
      if oldSide != idxSide || oldPoke != idxPoke
        pbUpdateBattlerSelection([idxSide, idxPoke])
        @sprites["infoselect"].y = (idxSide == 0) ? 154 : 78
        case @battle.pbSideBattlerCount(idxSide)
        when 1 then @sprites["infoselect"].x = 173
        when 2 then @sprites["infoselect"].x = 68 + (208 * idxPoke)
        when 3 then @sprites["infoselect"].x = 4 + (169 * idxPoke)
        end
        battler = battlers[idxSide][idxPoke]
        @battle.allBattlers.each do |b|
          if b.index == battler.index
            pbShowOutline("battler_icon#{b.index}")
          else
            pbShowOutline("battler_icon#{b.index}", false)
          end
        end
      end
    end
    pbHideBattleInfo
    pbUpdateBattlerIcons
    case switchUI
    when 0 then pbPlayCloseMenuSE
    when 1 then pbToggleMoveInfo(battler, cw.index)
    when 2 then pbToggleFocusPanel if !cw.visible
    end
  end
  
  
  #-----------------------------------------------------------------------------
  # Draws the selection screen for the Battle Info UI.
  #-----------------------------------------------------------------------------
  def pbUpdateBattlerSelection(index, select = false)
    @infoUIOverlay1.clear
    @infoUIOverlay2.clear
    return if !@infoUIToggle
    xpos = 0
    ypos = 68
    textPos = []
    imagePos1 = [[@path + "battler_sel_bg", xpos, ypos]]
    imagePos2 = []
    2.times do |side|
      count = @battle.pbSideBattlerCount(side)
      case side
      #-------------------------------------------------------------------------
      # Player's side.
      #-------------------------------------------------------------------------
      when 0
        @battle.allSameSideBattlers.each_with_index do |b, i|
          case count
          when 1 then iconX, bgX = 202, 173
          when 2 then iconX, bgX = 96 + (208 * i), 68 + (208 * i)
          when 3 then iconX, bgX = 32 + (168 * i), 4 + (169 * i)
          end
          iconY = ypos + 114
          nameX = iconX + 82
          if index == [side, i]
            base, shadow = BASE_LIGHT, SHADOW_LIGHT
            if b.dynamax?
              shadow = (b.isSpecies?(:CALYREX)) ? Color.new(48, 206, 216) : Color.new(248, 32, 32)
            end			  
          else
            base, shadow = BASE_DARK, SHADOW_DARK
          end
          @sprites["battler_icon#{b.index}"].x = iconX
          @sprites["battler_icon#{b.index}"].y = iconY
          pbSetWithOutline("battler_icon#{b.index}", [iconX, iconY, 400])
          imagePos1.push([@path + "battler_sel", bgX, iconY - 28, 0, 0, 166, 52])
          imagePos2.push([@path + "battler_owner", bgX + 36, iconY + 11],
                         [@path + "battler_gender", bgX + 146, iconY - 37, b.gender * 22, 0, 22, 20])
          textPos.push([_INTL("{1}", b.pokemon.name), nameX, iconY - 16, 2, base, shadow],
                       [@battle.pbGetOwnerFromBattlerIndex(b.index).name, nameX - 10, iconY + 13, 2, BASE_LIGHT, SHADOW_LIGHT])
        end
        trainers = []
        @battle.player.each { |p| trainers.push(p) if p.able_pokemon_count > 0 }
        ballY = ypos + 154
        ballXFirst = 35
        ballXLast = Graphics.width - (16 * NUM_BALLS) - 35
        ballOffset = 2
      #-------------------------------------------------------------------------
      # Opponent's side.
      #-------------------------------------------------------------------------
      when 1
        @battle.allOtherSideBattlers.reverse.each_with_index do |b, i|
          case count
          when 1 then iconX, bgX = 202, 173
          when 2 then iconX, bgX = 96 + (208 * i), 68 + (208 * i)
          when 3 then iconX, bgX = 32 + (168 * i), 4 + (169 * i)
          end
          iconY = ypos + 38
          nameX = iconX + 82
          if index == [side, i]
            base, shadow = BASE_LIGHT, SHADOW_LIGHT
            if b.dynamax?
              shadow = (b.isSpecies?(:CALYREX)) ? Color.new(48, 206, 216) : Color.new(248, 32, 32)
            end			  
          else
            base, shadow = BASE_DARK, SHADOW_DARK
          end
          @sprites["battler_icon#{b.index}"].x = iconX
          @sprites["battler_icon#{b.index}"].y = iconY
          pbSetWithOutline("battler_icon#{b.index}", [iconX, iconY, 400])
          imagePos1.push([@path + "battler_sel", bgX, iconY - 28, 0, 0, 166, 52])
          textPos.push([_INTL("{1}", b.displayPokemon.name), nameX, iconY - 16, 2, base, shadow])
          if @battle.trainerBattle?
            imagePos2.push([@path + "battler_owner", bgX + 36, iconY + 11])
            textPos.push([@battle.pbGetOwnerFromBattlerIndex(b.index).name, nameX - 10, iconY + 13, 2, BASE_LIGHT, SHADOW_LIGHT])
          end
          imagePos2.push([@path + "battler_gender", bgX + 146, iconY - 37, b.displayPokemon.gender * 22, 0, 22, 20])
        end
        trainers = []
        @battle.opponent.each { |p| trainers.push(p) if p.able_pokemon_count > 0 } if @battle.opponent
        ballY = ypos - 17
        ballXFirst = Graphics.width - (16 * NUM_BALLS) - 35
        ballXLast = 35
        ballOffset = 3
      end
      #-------------------------------------------------------------------------
      # Draws party ball lineups.
      #-------------------------------------------------------------------------
      ballXMiddle = (Graphics.width / 2) - 48
      ballX = ballXMiddle
      trainers.each do |trainer|
        if trainers.length > 1
          case trainer
          when trainers.first then ballX = ballXFirst
          when trainers.last  then ballX = ballXLast
          else                     ballX = ballXMiddle
          end
        end
        imagePos1.push([@path + "battler_owner", ballX - 16, ballY - ballOffset])
        NUM_BALLS.times do |slot|
          idx = 0
          if !trainer.party[slot]                   then idx = 3 # Empty
          elsif !trainer.party[slot].able?          then idx = 2 # Fainted
          elsif trainer.party[slot].status != :NONE then idx = 1 # Status
          end
          imagePos2.push([@path + "battler_ball", ballX + (slot * 16), ballY, idx * 15, 0, 15, 15])
        end
      end
    end
    pbUpdateBattlerIcons
    pbDrawImagePositions(@infoUIOverlay1, imagePos1)
    pbDrawImagePositions(@infoUIOverlay2, imagePos2)
    pbDrawTextPositions(@infoUIOverlay2, textPos)
    @sprites["infoselect"].visible = true
    pbSelectBattlerInfo if select
  end


  #-----------------------------------------------------------------------------
  # Handles the controls for the Battle Info UI.
  #-----------------------------------------------------------------------------
  def pbOpenBattlerInfo(battler, battlers)
    return if !@infoUIToggle
    ret = nil
    idx = 0
    battlerTotal = battlers.flatten
    for i in 0...battlerTotal.length
      idx = i if battler == battlerTotal[i]
    end
    maxSize = battlerTotal.length - 1
    @sprites["infoselect"].visible = false
    pbUpdateBattlerInfo(battler)
    cw = @sprites["fightWindow"]
    @sprites["leftarrow"].visible = true
    @sprites["rightarrow"].visible = true
    loop do
      oldIdx = idx
      pbUpdate(cw)
      pbUpdateSpriteHash(@sprites)
      break if Input.trigger?(Input::BACK)
      if Input.trigger?(Input::LEFT)
        idx -= 1
        idx = maxSize if idx < 0
      elsif Input.trigger?(Input::RIGHT)
        idx += 1
        idx = 0 if idx > maxSize
      elsif cw.visible && Input.triggerex?(Settings::MOVE_INFO_KEY)
        ret = 1
        break
      elsif PluginManager.installed?("Focus Meter System") && Input.triggerex?(Settings::FOCUS_PANEL_KEY)
        ret = 2
        break
      #elsif Input.trigger?(Input::USE) || Input.triggerex?(Settings::BATTLE_INFO_KEY)
      #modified by Gardenette
      elsif Input.trigger?(Input::USE) || Input.trigger?(Settings::BATTLE_INFO_KEY)
        ret = [0, 0]
        if battler.opposes?
          ret[0] = 1
          @battle.allOtherSideBattlers.reverse.each_with_index { |b, i| ret[1] = i if b == battler }
        else
          ret[0] = 0
          @battle.allSameSideBattlers.each_with_index { |b, i| ret[1] = i if b == battler }
        end
        pbPlayDecisionSE
        break
      end
      if oldIdx != idx
        pbPlayCursorSE
        battler = battlerTotal[idx]
        pbUpdateBattlerInfo(battler)
      end
    end
    @sprites["leftarrow"].visible = false
    @sprites["rightarrow"].visible = false
    return ret
  end
  
  
  #-----------------------------------------------------------------------------
  # Draws the Battle Info UI.
  #-----------------------------------------------------------------------------
  def pbUpdateBattlerInfo(battler)
    @infoUIOverlay1.clear
    @infoUIOverlay2.clear
    pbUpdateBattlerIcons
    return if !@infoUIToggle
    xpos = 28
    ypos = 25
    iconX = xpos + 29
    iconY = ypos + 62
    panelX = xpos + 239
    #---------------------------------------------------------------------------
    # General UI elements.
    poke = (battler.opposes?) ? battler.displayPokemon : battler.pokemon
    imagePos = [[@path + "battle_info_bg", 0, 0],
                [@path + "battle_info_ui", 0, 0],
                [@path + "battler_gender", xpos + 146, ypos + 24, poke.gender * 22, 0, 22, 20]]
    textPos  = [[_INTL("{1}", poke.name), iconX + 83, iconY - 16, 2, BASE_DARK, SHADOW_DARK],
                [_INTL("Lv. {1}", battler.level), xpos + 17, ypos + 106, 0, BASE_LIGHT, SHADOW_LIGHT],
                [_INTL("Turn {1}", @battle.turnCount + 1), Graphics.width - xpos - 32, ypos + 6, 2, BASE_LIGHT, SHADOW_LIGHT]]
    #---------------------------------------------------------------------------
    # Battler icon.
    @battle.allBattlers.each do |b|
      @sprites["battler_icon#{b.index}"].x = iconX
      @sprites["battler_icon#{b.index}"].y = iconY
      @sprites["battler_icon#{b.index}"].visible = (b == battler)
    end
    #---------------------------------------------------------------------------
    # Battler HP.
    if battler.hp > 0
      w = battler.hp * 96 / battler.totalhp.to_f
      w = 1 if w < 1
      w = ((w / 2).round) * 2
      hpzone = 0
      hpzone = 1 if battler.hp <= (battler.totalhp / 2).floor
      hpzone = 2 if battler.hp <= (battler.totalhp / 4).floor
      imagePos.push(["Graphics/Pictures/Battle/overlay_hp", 86, 89, 0, hpzone * 6, w, 6])
    end
    # Battler status.
    if battler.status != :NONE
      iconPos = GameData::Status.get(battler.status).icon_position
      imagePos.push(["Graphics/Pictures/statuses", xpos + 86, ypos + 105, 0, iconPos * 16, 44, 16])
    end
    # Shininess
    imagePos.push(["Graphics/Pictures/shiny", xpos + 143, ypos + 105]) if poke.shiny?
    # Owner
    if !battler.wild?
      imagePos.push([@path + "battler_owner", xpos - 34, ypos + 4])
      textPos.push([@battle.pbGetOwnerFromBattlerIndex(battler.index).name, xpos + 32, ypos + 6, 2, BASE_LIGHT, SHADOW_LIGHT])
    end
    # Battler's last move used.
    if battler.lastMoveUsed
      movename = GameData::Move.get(battler.lastMoveUsed).name
	  movename = movename[0..12] + "..." if movename.length > 16
      textPos.push([_INTL("Used: #{movename}"), xpos + 348, ypos + 106, 2, BASE_LIGHT, SHADOW_LIGHT])
    end
    #---------------------------------------------------------------------------
    # Battler info for player-owned Pokemon.
    if battler.pbOwnedByPlayer?
      imagePos.push(
        [@path + "battler_owner", xpos + 36, iconY + 11],
        [@path + "battle_info_panel", panelX, 65, 0, 0, 218, 24],
        [@path + "battle_info_panel", panelX, 89, 0, 0, 218, 24]
      )
      textPos.push(
        [_INTL("Abil."), xpos + 272, ypos + 44, 2, BASE_LIGHT, SHADOW_LIGHT],
        [_INTL("Item"), xpos + 272, ypos + 68, 2, BASE_LIGHT, SHADOW_LIGHT],
        [_INTL("{1}", battler.abilityName), xpos + 375, ypos + 44, 2, BASE_DARK, SHADOW_DARK],
        [_INTL("{1}", battler.itemName), xpos + 375, ypos + 68, 2, BASE_DARK, SHADOW_DARK],
        [sprintf("%d/%d", battler.hp, battler.totalhp), iconX + 73, iconY + 13, 2, BASE_LIGHT, SHADOW_LIGHT]
      )
    end
    #---------------------------------------------------------------------------
    # Battler's stat stages.
    stat_images, stat_text = pbAddStatsDisplay(xpos, ypos, battler)
    imagePos += stat_images
    textPos  += stat_text
    #---------------------------------------------------------------------------
    # Effects in play that affect the battler.
    effect_images, effect_text = pbAddEffectsDisplay(xpos, ypos, panelX, battler)
    imagePos += effect_images
    textPos  += effect_text
    #---------------------------------------------------------------------------
    pbDrawImagePositions(@infoUIOverlay1, imagePos)
    pbDrawTextPositions(@infoUIOverlay2, textPos)
    #---------------------------------------------------------------------------
    # Battler's typing.
    pbAddTypesDisplay(xpos, ypos, battler, poke)
  end


  #-----------------------------------------------------------------------------
  # Toggles the visibility of the Battle Info UI.
  #-----------------------------------------------------------------------------
  def pbToggleBattleInfo
    return if pbInSafari?
    @infoUIToggle = !@infoUIToggle
    (@infoUIToggle) ? pbSEPlay("GUI party switch") : pbPlayCloseMenuSE
    @sprites["infobitmap"].visible = @infoUIToggle
    @sprites["infotext"].visible = @infoUIToggle
    pos = (@battle.pbSideBattlerCount(0) == 3) ? 1 : 0
    pbUpdateBattlerSelection([0, pos], true)
  end
  
  
  #-----------------------------------------------------------------------------
  # Updates icon sprites to be used for the Battle Info UI.
  #-----------------------------------------------------------------------------
  def pbUpdateBattlerIcons
    @battle.allBattlers.each do |b|
      next if !b
      poke = (b.opposes?) ? b.displayPokemon : b.pokemon
      if !b.fainted?
        @sprites["battler_icon#{b.index}"].pokemon = poke
        @sprites["battler_icon#{b.index}"].visible = @infoUIToggle
        @sprites["battler_icon#{b.index}"].setOffset(PictureOrigin::CENTER)
        @sprites["battler_icon#{b.index}"].zoom_x = 1
        @sprites["battler_icon#{b.index}"].zoom_y = 1
        @sprites["battler_icon#{b.index}"].applyIconEffects
        color = (!b.dynamax?) ? Color.white : (b.isSpecies?(:CALYREX)) ? Color.new(36, 243, 243) : Color.new(250, 57, 96)
      else
        @sprites["battler_icon#{b.index}"].visible = false
      end
      pbUpdateOutline("battler_icon#{b.index}", poke, true)
      pbColorOutline("battler_icon#{b.index}", color)
      pbShowOutline("battler_icon#{b.index}", false)
    end
  end
  
  
  #-----------------------------------------------------------------------------
  # Draws the typing for each Pokemon in the Battle Info UI.
  #-----------------------------------------------------------------------------
  def pbAddTypesDisplay(xpos, ypos, battler, poke)
    illusion = battler.effects[PBEffects::Illusion] && !battler.pbOwnedByPlayer?
    if battler.tera?
      displayTypes = (illusion) ? poke.types : battler.pokemon.types
    elsif illusion
      displayTypes = poke.types
      displayTypes.push(battler.effects[PBEffects::Type3]) if battler.effects[PBEffects::Type3]
    else
      displayTypes = battler.pbTypes(true)
    end
    unknown_species = !(
      battler.pbOwnedByPlayer? ||
      $player.pokedex.owned?(poke.species) ||
      $player.pokedex.battled_count(poke.species) > 0
    )
    unknown_species = false #if Settings::ALWAYS_DISPLAY_TYPES
    #~ unknown_species = true if battler.celestial?
    # Displays the "???" type on newly encountered species, or battlers with no typing.
    displayTypes = [:QMARKS] if unknown_species || displayTypes.empty?
		case displayTypes.length #triple type UI #by low
			when 3
				typeY = ypos + 7
			when 4
				typeY = ypos - 21
			else
				typeY = ypos + 35
		end
    typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    displayTypes.each_with_index do |type, i|
      type_number = GameData::Type.get(type).icon_position
      type_rect = Rect.new(0, type_number * 28, 64, 28)
      @infoUIOverlay1.blt(xpos + 171, typeY + (i * 30), typebitmap.bitmap, type_rect)
    end
    #---------------------------------------------------------------------------
    # Tera Types
    if PluginManager.installed?("Terastal Phenomenon")
      poke = battler if !illusion
      pbDisplayTeraType(poke, @infoUIOverlay1, xpos + 187, ypos + 98)
    end
  end
  
  
  #-----------------------------------------------------------------------------
  # Draws the stat display for each Pokemon in the Battle Info UI.
  #-----------------------------------------------------------------------------
  def pbAddStatsDisplay(xpos, ypos, battler)
    images = []
    addText = []
    [[:ATTACK,          _INTL("Attack")],
     [:DEFENSE,         _INTL("Defense")], 
     [:SPECIAL_ATTACK,  _INTL("Sp. Atk")], 
     [:SPECIAL_DEFENSE, _INTL("Sp. Def")], 
     [:SPEED,           _INTL("Speed")], 
     [:ACCURACY,        _INTL("Accuracy")], 
     [:EVASION,         _INTL("Evasion")],
     _INTL("Crit. Hit")
    ].each_with_index do |stat, i|
      if stat.is_a?(Array)
        color = SHADOW_LIGHT
        if battler.pbOwnedByPlayer?
          battler.pokemon.nature_for_stats.stat_changes.each do |s|
            if stat[0] == s[0]
              color = Color.new(136, 96, 72)  if s[1] > 0 # Red Nature text.
              color = Color.new(64, 120, 152) if s[1] < 0 # Blue Nature text.
            end
          end
        end
        addText.push([stat[1], xpos + 17, ypos + 139 + (i * 24), 0, BASE_LIGHT, color])
        stage = battler.stages[stat[0]]
      else
        addText.push([stat, xpos + 17, ypos + 139 + (i * 24), 0, BASE_LIGHT, SHADOW_LIGHT])
        stage = [battler.effects[PBEffects::FocusEnergy] + battler.effects[PBEffects::CriticalBoost], 4].min
      end
      arrow = (stage > 0) ? 0 : 1
      stage.abs.times { |t| images.push([@path + "battler_stats", xpos + 105 + (t * 18), ypos + 139 + (i * 24), arrow * 18, 0, 18, 18]) }
    end
    return images, addText
  end
  
  
  #-----------------------------------------------------------------------------
  # Draws the battle effects in play affecting each Pokemon in the Battle Info UI.
  #-----------------------------------------------------------------------------
  def pbAddEffectsDisplay(xpos, ypos, panelX, battler)
    images = []
    addText = []
    effects = []
    # Effects that apply to the whole field.
    field_effects = {
      PBEffects::MudSportField   => [_INTL("Mud Sport"),    5],
      PBEffects::WaterSportField => [_INTL("Water Sport"),  5],
      PBEffects::TrickRoom       => [_INTL("Trick Room"),   5], 
      PBEffects::MagicRoom       => [_INTL("Magic Room"),   5],
      PBEffects::WonderRoom      => [_INTL("Wonder Room"),  5],
      PBEffects::Gravity         => [_INTL("Gravity"),      5],
      PBEffects::FairyLock       => [_INTL("Fairy Lock"),   2]
    }
    # Effects that apply to one side of the field.
    team_effects = {
      PBEffects::AuroraVeil      => [_INTL("Aurora Veil"),  5], 
      PBEffects::Reflect         => [_INTL("Reflect"),      5],
      PBEffects::LightScreen     => [_INTL("Light Screen"), 5],
      PBEffects::Mist            => [_INTL("Mist"),         5],
      PBEffects::Safeguard       => [_INTL("Safeguard"),    5],
      PBEffects::LuckyChant      => [_INTL("Lucky Chant"),  5],
      PBEffects::Tailwind        => [_INTL("Tailwind"),     4],
      PBEffects::Rainbow         => [_INTL("Rainbow"),      4],
      PBEffects::SeaOfFire       => [_INTL("Sea of Fire"),  4],
      PBEffects::Swamp           => [_INTL("Swamp"),        4]
    }
    # Effects that apply to an individual battler.
    battler_effects = {
      PBEffects::Disable         => [_INTL("Disable"),      5],
      PBEffects::Embargo         => [_INTL("Embargo"),      5],
      PBEffects::HealBlock       => [_INTL("Heal Block"),   5],
      PBEffects::MagnetRise      => [_INTL("Magnet Rise"),  5],
      PBEffects::Encore          => [_INTL("Encore"),       4],
      PBEffects::Taunt           => [_INTL("Taunt"),        4],
      PBEffects::PerishSong      => [_INTL("Perish Song"),  3],
      PBEffects::Telekinesis     => [_INTL("Telekinesis"),  3],
      PBEffects::ThroatChop      => [_INTL("Throat Chop"),  2]
    }
    if battler.effects[PBEffects::Trapping] > 0
      moveName = GameData::Move.get(battler.effects[PBEffects::TrappingMove]).name
      battler_effects[PBEffects::Trapping]  = [_INTL("{1}", moveName),   5]
    end
    # Adds plugin-specific effects.
    if PluginManager.installed?("ZUD Mechanics")
      team_effects[PBEffects::VineLash]     = [_INTL("G-Max Vine Lash"), 4]
      team_effects[PBEffects::Wildfire]     = [_INTL("G-Max Wildfire"),  4]
      team_effects[PBEffects::Cannonade]    = [_INTL("G-Max Cannonade"), 4]
      team_effects[PBEffects::Volcalith]    = [_INTL("G-Max Volcalith"), 4]
      if battler.effects[PBEffects::Dynamax] > 0
        count = (battler.effects[PBEffects::MaxRaidBoss]) ? "---" : "#{battler.effects[PBEffects::Dynamax]}/#{Settings::DYNAMAX_TURNS}"
        effects.push([_INTL("Dynamax"), count])
      end
    end
    if PluginManager.installed?("Focus Meter System")
      team_effects[PBEffects::FocusedGuard] = [_INTL("Focused Guard"),   4]
      battler_effects[PBEffects::FocusLock] = [_INTL("Focus Lock"),      4]
    end
    # Weather
    if @battle.field.weather != :None
      count = @battle.field.weatherDuration
      count = (count > 0) ? "#{count}/5" : "---"
      effects.push([GameData::BattleWeather.get(@battle.field.weather).name, count])
    end
    # Terrain
    if @battle.field.terrain != :None
      count = @battle.field.terrainDuration
      count = (count > 0) ? "#{count}/5" : "---"
      effects.push([GameData::BattleTerrain.get(@battle.field.terrain).name + " " + _INTL("Terrain"), count])
    end
    # mastersex type zones #by low
    if @battle.field.typezone != :None && GameData::Type.exists?(@battle.field.typezone)
      effects.push([GameData::Type.get(@battle.field.typezone).name + " " + _INTL("Zone"), "---"])
    end
    # Draws a list of each of the above effects currently in play.
    field_effects.each do |key, value|
      next if @battle.field.effects[key] == 0
      count = @battle.field.effects[key]
      count = (count < 100) ? "#{count}/#{value[1]}" : "---"
      effects.push([value[0], count])
    end
    team_effects.each do |key, value|
      next if battler.pbOwnSide.effects[key] == 0
      count = battler.pbOwnSide.effects[key]
      count = (count < 100) ? "#{count}/#{value[1]}" : "---"
      effects.push([value[0], count])
    end
    battler_effects.each do |key, value|
      next if battler.effects[key] == 0
      count = battler.effects[key]
      count = (count < 100) ? "#{count}/#{value[1]}" : "---"
      effects.push([value[0], count])
    end
    # Draws panels and text for all relevant battle effects affecting the battler.
    effects.each_with_index do |effect, i|
      break if i == 8
      images.push([@path + "battle_info_panel", panelX, ypos + 136 + (i * 24), 0, 24, 218, 24])
      addText.push([effect[0], xpos + 321, ypos + 140 + (i * 24), 2, BASE_DARK, SHADOW_DARK],
                   [effect[1], xpos + 425, ypos + 140 + (i * 24), 2, BASE_LIGHT, SHADOW_LIGHT])
    end
    return images, addText
  end
end