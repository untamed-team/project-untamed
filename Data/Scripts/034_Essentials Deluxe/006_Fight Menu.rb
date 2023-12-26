#===============================================================================
# Revamps base Essentials code related to the Fight Menu to allow for 
# plugin compatibility.
#===============================================================================


#-------------------------------------------------------------------------------
# Numbers associated with Fight Menu selections.
#-------------------------------------------------------------------------------
module DXTriggers
  MENU_TRIGGER_CANCEL          = -1
  MENU_TRIGGER_SHIFT_BATTLER   = -2
  MENU_TRIGGER_MEGA_EVOLUTION  = -3
  MENU_TRIGGER_Z_MOVE          = -4
  MENU_TRIGGER_ULTRA_BURST     = -5
  MENU_TRIGGER_DYNAMAX         = -6
  MENU_TRIGGER_BATTLE_STYLE    = -7
  MENU_TRIGGER_TERASTALLIZE    = -8
  MENU_TRIGGER_ZODIAC_POWER    = -9
  MENU_TRIGGER_CUSTOM_MECHANIC = -10
  MENU_TRIGGER_FOCUS_METER     = -11
end


#-------------------------------------------------------------------------------
# Revamped Fight Menu class.
#-------------------------------------------------------------------------------
class Battle::Scene::FightMenu < Battle::Scene::MenuBase
  def initialize(viewport, z)
    super(viewport)
    self.x = 0
    self.y = Graphics.height - 96
    @battler     = nil
    @shiftMode   = 0
    @focusMode   = 0
    @battleStyle = -1
    @teraType    = -1
    if USE_GRAPHICS
      @buttonBitmap  = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_fight"))
      @typeBitmap    = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
      @shiftBitmap   = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_shift"))
      @battleButtonBitmap = {}
      @battleButtonBitmap[:mega] = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_mega"))
      if PluginManager.installed?("ZUD Mechanics")
        path = "Graphics/Plugins/ZUD/Battle/"
        @battleButtonBitmap[:ultra] = AnimatedBitmap.new(path + "cursor_ultra")
        @battleButtonBitmap[:zmove] = AnimatedBitmap.new(path + "cursor_zmove")
        @battleButtonBitmap[:dynamax] = AnimatedBitmap.new(path + "cursor_dynamax")
      end
      if PluginManager.installed?("PLA Battle Styles")
        path = "Graphics/Plugins/PLA Battle Styles/"
        @battleButtonBitmap[:style] = AnimatedBitmap.new(path + "cursor_styles")
      end
      if PluginManager.installed?("Terastal Phenomenon")
        path = "Graphics/Plugins/Terastal Phenomenon/"
        @battleButtonBitmap[:tera] = AnimatedBitmap.new(path + "cursor_tera")
      end
      if PluginManager.installed?("Pokémon Birthsigns")
        path = "Graphics/Plugins/Birthsigns/UI/"
        @battleButtonBitmap[:zodiac] = AnimatedBitmap.new(path + "cursor_zodiac")
      end
      if !nil_or_empty?(Settings::CUSTOM_MECH_BUTTON_PATH)
        @battleButtonBitmap[:custom] = AnimatedBitmap.new(_INTL(Settings::CUSTOM_MECH_BUTTON_PATH))
      end
      @chosen_button = :none
      background = IconSprite.new(0, Graphics.height - 96, viewport)
      background.setBitmap("Graphics/Pictures/Battle/overlay_fight")
      addSprite("background", background)
      @buttons = Array.new(Pokemon::MAX_MOVES) do |i|
        button = SpriteWrapper.new(viewport)
        button.bitmap = @buttonBitmap.bitmap
        button.x = self.x + 4
        button.x += (i.even? ? 0 : (@buttonBitmap.width / 2) - 4)
        button.y = self.y + 6
        button.y += (((i / 2) == 0) ? 0 : BUTTON_HEIGHT - 4)
        button.src_rect.width  = @buttonBitmap.width / 2
        button.src_rect.height = BUTTON_HEIGHT
        addSprite("button_#{i}", button)
        next button
      end
      @overlay = BitmapSprite.new(Graphics.width, Graphics.height - self.y, viewport)
      @overlay.x = self.x
      @overlay.y = self.y
      pbSetNarrowFont(@overlay.bitmap)
      addSprite("overlay", @overlay)
      @infoOverlay = BitmapSprite.new(Graphics.width, Graphics.height - self.y, viewport)
      @infoOverlay.x = self.x
      @infoOverlay.y = self.y
      pbSetNarrowFont(@infoOverlay.bitmap)
      addSprite("infoOverlay", @infoOverlay)
      @typeIcon = SpriteWrapper.new(viewport)
      @typeIcon.bitmap = @typeBitmap.bitmap
      @typeIcon.x      = self.x + 416
      @typeIcon.y      = self.y + 20
      @typeIcon.src_rect.height = TYPE_ICON_HEIGHT
      addSprite("typeIcon", @typeIcon)
      @battleButton = SpriteWrapper.new(viewport) # For button graphic
      addSprite("battleButton", @battleButton)
      @shiftButton = SpriteWrapper.new(viewport)
      @shiftButton.bitmap = @shiftBitmap.bitmap
      @shiftButton.x      = self.x + 4
      @shiftButton.y      = self.y - @shiftBitmap.height
      addSprite("shiftButton", @shiftButton)
      if PluginManager.installed?("Focus Meter System")
        path = "Graphics/Plugins/Focus Meter/"
        @focusBitmap = AnimatedBitmap.new(path + "cursor_focus")
        @focusButton = SpriteWrapper.new(viewport)
        @focusButton.bitmap = @focusBitmap.bitmap
        @focusButton.x      = self.x + 4
        @focusButton.y      = self.y - @focusBitmap.height / 2
        @focusButton.src_rect.height = @focusBitmap.height / 2
        addSprite("focusButton", @focusButton)
      end
    else
      @msgBox = Window_AdvancedTextPokemon.newWithSize(
        "", self.x + 320, self.y, Graphics.width - 320, Graphics.height - self.y, viewport
      )
      @msgBox.baseColor   = TEXT_BASE_COLOR
      @msgBox.shadowColor = TEXT_SHADOW_COLOR
      pbSetNarrowFont(@msgBox.contents)
      addSprite("msgBox", @msgBox)
      @cmdWindow = Window_CommandPokemon.newWithSize(
        [], self.x, self.y, 320, Graphics.height - self.y, viewport
      )
      @cmdWindow.columns       = 2
      @cmdWindow.columnSpacing = 4
      @cmdWindow.ignore_input  = true
      pbSetNarrowFont(@cmdWindow.contents)
      addSprite("cmdWindow", @cmdWindow)
    end
    self.z = z
  end
  
  def dispose
    super
    @buttonBitmap&.dispose
    @typeBitmap&.dispose
    @battleButtonBitmap.each { |k, bmp| bmp&.dispose}
    @shiftBitmap&.dispose
    @focusBitmap&.dispose if PluginManager.installed?("Focus Meter System")
  end
  
  def chosen_button=(value)
    oldValue = @chosen_button
    @chosen_button = value
    refresh if @chosen_button != oldValue
  end
  
  def refreshBattleButton
    return if !USE_GRAPHICS
    if @chosen_button == :none
      @visibility["battleButton"] = false
      return
    end
    @battleButton.bitmap = @battleButtonBitmap[@chosen_button].bitmap
    @battleButton.x = self.x + 120
    case @chosen_button
    when :style
      @battleButton.y = self.y - @battleButtonBitmap[@chosen_button].height / 6
      @battleButton.src_rect.height = @battleButtonBitmap[@chosen_button].height / 6
      @battleButton.src_rect.y = @battleStyle * @battleButtonBitmap[@chosen_button].height / 6
    when :tera
      @battleButton.y = self.y - @battleButtonBitmap[@chosen_button].height / 20
      @battleButton.src_rect.height = @battleButtonBitmap[@chosen_button].height / 20
      @battleButton.src_rect.y = @teraType * @battleButtonBitmap[@chosen_button].height / 20
    else
      @battleButton.y = self.y - @battleButtonBitmap[@chosen_button].height / 2
      @battleButton.src_rect.height = @battleButtonBitmap[@chosen_button].height / 2
      @battleButton.src_rect.y = (@mode - 1) * @battleButtonBitmap[@chosen_button].height / 2
    end
    mode = @shiftMode + @focusMode
    @battleButton.x = self.x + ((mode > 0) ? 204 : 120)
    @battleButton.z = self.z - 1
    @visibility["battleButton"] = (@mode > 0)
  end
  
  def refreshButtonNames
    moves = (@battler) ? @battler.moves : []
    if !USE_GRAPHICS
      commands = []
      [4, moves.length].max.times do |i|
        commands.push((moves[i]) ? moves[i].short_name : "-")
      end
      @cmdWindow.commands = commands
      return
    end
    @overlay.bitmap.clear
    textPos = []
    imagePos = []
    @buttons.each_with_index do |button, i|
      next if !@visibility["button_#{i}"]
      x = button.x - self.x + (button.src_rect.width / 2)
      y = button.y - self.y + 14
      #moveNameBase = TEXT_BASE_COLOR
	  #edited by Gardenette
	  moveNameBase = Color.new(255,255,255)
      if GET_MOVE_TEXT_COLOR_FROM_MOVE_BUTTON && moves[i].display_type(@battler)
        moveNameBase = button.bitmap.get_pixel(10, button.src_rect.y + 34)
      end
      textPos.push([moves[i].short_name, x, y, 2, moveNameBase, TEXT_SHADOW_COLOR])
      if PluginManager.installed?("PLA Battle Styles") && @battler.style_trigger > 0
        next if !moves[i].mastered?
        imagePos.push(["Graphics/Plugins/PLA Battle Styles/mastered_icon", button.x - self.x, button.y - self.y + 3])
      end
    end
    pbDrawTextPositions(@overlay.bitmap, textPos)
    pbDrawImagePositions(@overlay.bitmap, imagePos)
  end

  def refresh
    return if !@battler
    refreshSelection
    refreshBattleButton
    refreshShiftButton
    refreshFocusButton if PluginManager.installed?("Focus Meter System")
    refreshButtonNames
  end
end

def pbPlayBattleButton
  pbSEPlay("DX Power Button", 80)
end


#-------------------------------------------------------------------------------
# Toggles battle mechanics in the fight menu.
#-------------------------------------------------------------------------------
class Battle
  def pbFightMenu(idxBattler)
    return pbAutoChooseMove(idxBattler) if !pbCanShowFightMenu?(idxBattler)
    return true if pbAutoFightMenu(idxBattler)
    ret = false
    mechanics = []
    mechanics.push(pbCanMegaEvolve?(idxBattler))
    mechanics.push((PluginManager.installed?("ZUD Mechanics"))       ? pbCanUltraBurst?(idxBattler)   : false)
    mechanics.push((PluginManager.installed?("ZUD Mechanics"))       ? pbCanZMove?(idxBattler)        : false)
    mechanics.push((PluginManager.installed?("ZUD Mechanics"))       ? pbCanDynamax?(idxBattler)      : false)
    mechanics.push((PluginManager.installed?("PLA Battle Styles"))   ? pbCanUseStyle?(idxBattler)     : false)
    mechanics.push((PluginManager.installed?("Terastal Phenomenon")) ? pbCanTerastallize?(idxBattler) : false)
    mechanics.push((PluginManager.installed?("Pokémon Birthsigns"))  ? pbCanZodiacPower?(idxBattler)  : false)
    mechanics.push(pbCanCustom?(idxBattler))
    [:mega, :ultra, :zmove, :dynamax, :style, :tera, :zodiac, :custom].each_with_index do |mechanic, i|
      mechanics[i] = false if pbScriptedMechanic?(idxBattler, mechanic)
    end
    @scene.pbFightMenu(idxBattler, *mechanics) { |cmd|
      case cmd
      when DXTriggers::MENU_TRIGGER_CANCEL           # Cancel
      when DXTriggers::MENU_TRIGGER_MEGA_EVOLUTION   # Mega Evolution
        pbToggleRegisteredMegaEvolution(idxBattler)
        next false
      when DXTriggers::MENU_TRIGGER_ULTRA_BURST      # Ultra Burst
        pbToggleRegisteredUltraBurst(idxBattler)   if PluginManager.installed?("ZUD Mechanics")
        next false
      when DXTriggers::MENU_TRIGGER_Z_MOVE           # Z-Moves
        pbToggleRegisteredZMove(idxBattler)        if PluginManager.installed?("ZUD Mechanics")
        next false
      when DXTriggers::MENU_TRIGGER_DYNAMAX          # Dynamax
        pbToggleRegisteredDynamax(idxBattler)      if PluginManager.installed?("ZUD Mechanics")
        next false
      when DXTriggers::MENU_TRIGGER_BATTLE_STYLE     # Style
        pbToggleRegisteredStyle(idxBattler)        if PluginManager.installed?("PLA Battle Styles")
        next false
      when DXTriggers::MENU_TRIGGER_TERASTALLIZE     # Terastallize
        pbToggleRegisteredTerastallize(idxBattler) if PluginManager.installed?("Terastal Phenomenon")
        next false
      when DXTriggers::MENU_TRIGGER_ZODIAC_POWER     # Zodiac Powers
        pbToggleRegisteredZodiacPower(idxBattler)  if PluginManager.installed?("Pokémon Birthsigns")
        next false
      when DXTriggers::MENU_TRIGGER_FOCUS_METER      # Focus
        pbToggleRegisteredFocus(idxBattler)        if PluginManager.installed?("Focus Meter System")
        next false
      when DXTriggers::MENU_TRIGGER_CUSTOM_MECHANIC  # Custom mechanic
        pbToggleRegisteredCustom(idxBattler)
        next false
      when DXTriggers::MENU_TRIGGER_SHIFT_BATTLER    # Shift
        pbUnregisterMegaEvolution(idxBattler)
        if PluginManager.installed?("ZUD Mechanics")
          pbUnregisterUltraBurst(idxBattler)
          pbUnregisterZMove(idxBattler)
          pbUnregisterDynamax(idxBattler)
          @battlers[idxBattler].power_trigger = false
          @battlers[idxBattler].display_base_moves
        end
        pbUnregisterStyle(idxBattler)        if PluginManager.installed?("PLA Battle Styles")
        pbUnregisterTerastallize(idxBattler) if PluginManager.installed?("Terastal Phenomenon")
        pbUnregisterZodiacPower(idxBattler)  if PluginManager.installed?("Pokémon Birthsigns")
        pbUnregisterFocus(idxBattler)        if PluginManager.installed?("Focus Meter System")
        pbRegisterShift(idxBattler)
        pbUnregisterCustom(idxBattler)
        ret = true
      else
        next false if cmd < 0 || !@battlers[idxBattler].moves[cmd] ||
                      !@battlers[idxBattler].moves[cmd].id
        next false if !pbRegisterMove(idxBattler, cmd)
        next false if !singleBattle? &&
                      !pbChooseTarget(@battlers[idxBattler], @battlers[idxBattler].moves[cmd])
        ret = true
      end
      next true
    }
    return ret
  end
end


#-------------------------------------------------------------------------------
# Revamped Fight Menu scene.
#-------------------------------------------------------------------------------
class Battle::Scene
  def mechanic_params(*params)
    data = {
      :mega     => params[0] || false,
      :ultra    => params[1] || false,
      :zmove    => params[2] || false,
      :dynamax  => params[3] || false,
      :style    => params[4] || false,
      :tera     => params[5] || false,
      :zodiac   => params[6] || false,
      :custom  	=> params[7] || false
    }
    return data
  end
  
  #-----------------------------------------------------------------------------
  # Rewrites the fight menu code.
  #-----------------------------------------------------------------------------
  def pbFightMenu(idxBattler, *params)
    data = mechanic_params(*params)
    battler = @battle.battlers[idxBattler]
    cw = @sprites["fightWindow"]
    cw.battler = battler
    moveIndex  = 0
    if battler.moves[@lastMove[idxBattler]]&.id
      moveIndex = @lastMove[idxBattler]
    end
    cw.shiftMode = (@battle.pbCanShift?(idxBattler)) ? 1 : 0
    if PluginManager.installed?("Focus Meter System")
      cw.focusMode = (@battle.pbCanUseFocus?(idxBattler)) ? 1 : 0
    end
    if PluginManager.installed?("PLA Battle Styles") && !@battle.pbScriptedMechanic?(idxBattler, :style)
      cw.battleStyle = battler.style_trigger if @battle.pbCanUseStyle?(idxBattler)
    end
    if PluginManager.installed?("Terastal Phenomenon")
      cw.teraType = 0 if @battle.pbCanTerastallize?(idxBattler)
    end
    mechanic = pbFightMenu_BattleMechanic(data, cw)
    cw.setIndexAndMode(moveIndex, (mechanic) ? 1 : 0)
    needFullRefresh = true
    needRefresh = false
    loop do
      if needFullRefresh
        pbShowWindow(FIGHT_BOX)
        pbSelectBattler(idxBattler)
        needFullRefresh = false
      end
      if needRefresh
        pbFightMenu_RefreshMechanic(mechanic, idxBattler, cw)
        needRefresh = false
      end
      oldIndex = cw.index
      pbUpdate(cw)
      if Input.trigger?(Input::LEFT)
        cw.index -= 1 if (cw.index & 1) == 1
      elsif Input.trigger?(Input::RIGHT)
        if battler.moves[cw.index + 1]&.id && (cw.index & 1) == 0
          cw.index += 1
        end
      elsif Input.trigger?(Input::UP)
        cw.index -= 2 if (cw.index & 2) == 2
      elsif Input.trigger?(Input::DOWN)
        if battler.moves[cw.index + 2]&.id && (cw.index & 2) == 0
          cw.index += 2
        end
      end
      if cw.index != oldIndex
        pbPlayCursorSE
        pbUpdateMoveInfoWindow(battler, cw.index) if defined?(@moveUIToggle)
      end
      #-------------------------------------------------------------------------
      # Confirm Selection
      if Input.trigger?(Input::USE)
        break if yield pbFightMenu_Confirm(mechanic, battler, cw)
        needFullRefresh = true
        needRefresh = true
      #-------------------------------------------------------------------------
      # Cancel Selection
      elsif Input.trigger?(Input::BACK)
        break if yield pbFightMenu_Cancel(mechanic, battler, cw)
        needRefresh = true
      #-------------------------------------------------------------------------
      # Toggle Battle Mechanic
      elsif Input.trigger?(Input::ACTION)
        trigger, doRefresh = pbFightMenu_Action(mechanic, battler, cw)
        if trigger
          needFullRefresh = doRefresh
          break if yield trigger
          needRefresh = true
        end
      #-------------------------------------------------------------------------
      # Shift Battler
      elsif Input.trigger?(Input::SPECIAL)
        if cw.shiftMode > 0
          break if yield pbFightMenu_Shift
          needRefresh = true
        end
      end
      #-------------------------------------------------------------------------
      # Other Commands
      #if PluginManager.installed?("Enhanced UI")
      #edited by Gardenette
        pbFightMenu_EnhancedUI(battler, cw)
      #end
      if PluginManager.installed?("Focus Meter System")
        ret = pbFightMenu_FocusMeter(cw)
        if ret
          break if yield ret
          needRefresh = true
        end
      end
    end
    pbHidePluginUI
    @lastMove[idxBattler] = cw.index
  end
  
  #-----------------------------------------------------------------------------
  # Returns an available battle mechanic, if any.
  #-----------------------------------------------------------------------------
  def pbFightMenu_BattleMechanic(data, cw)
    mechanic = nil
    button = :none
    data.keys.each do |key|
      next if !data[key]
      mechanic = button = key
    end
    cw.chosen_button = button
    return mechanic
  end
  
  #-----------------------------------------------------------------------------
  # Refreshes the UI if a battle mechanic has been registered for use.
  #-----------------------------------------------------------------------------
  def pbFightMenu_RefreshMechanic(mechanic, idxBattler, cw)
    if mechanic
      case mechanic
      when :mega    then register = @battle.pbRegisteredMegaEvolution?(idxBattler)
      when :ultra   then register = @battle.pbRegisteredUltraBurst?(idxBattler)
      when :zmove   then register = @battle.pbRegisteredZMove?(idxBattler)
      when :dynamax then register = @battle.pbRegisteredDynamax?(idxBattler)
      when :style   then register = @battle.pbRegisteredStyle?(idxBattler)
      when :tera    then register = @battle.pbRegisteredTerastallize?(idxBattler)
      when :zodiac  then register = @battle.pbRegisteredZodiacPower?(idxBattler)
      when :custom  then register = @battle.pbRegisteredCustom?(idxBattler)
      end
      newMode = (register) ? 2 : 1
      cw.mode = newMode if newMode != cw.mode
    end
  end
  
  #-----------------------------------------------------------------------------
  # Confirms the player's move selection.
  # Cancels selection if registered battle mechanic is incompatible with the selected move.
  #-----------------------------------------------------------------------------
  def pbFightMenu_Confirm(mechanic, battler, cw)
    pbHidePluginUI
    ret = cw.index
    cancel = DXTriggers::MENU_TRIGGER_CANCEL
    case mechanic
    when :zmove
      if cw.mode == 2
        if !battler.hasCompatibleZMove?(battler.moves[cw.index])
          itemname = battler.item.name
          movename = battler.moves[cw.index].name
          @battle.pbDisplay(_INTL("{1} is not compatible with {2}!", movename, itemname))
          if battler.power_trigger
            battler.power_trigger = false
            battler.display_base_moves
          end
          ret = cancel
        end
      end
    when :style
      if cw.mode == 2
        if !battler.moves[cw.index].mastered?
          movename = battler.moves[cw.index].name
          @battle.pbDisplay(_INTL("{1} needs to be mastered first before it may be used in that style!", movename))
          battler.style_trigger = 0
          battler.toggle_style_moves
          ret = cancel
        end
      end
    else
      battler.power_trigger = false
    end
    pbPlayDecisionSE if ret != cancel
    return ret
  end
  
  #-----------------------------------------------------------------------------
  # Cancels the player's command selection.
  # Resets various battler properties related to selected battle mechanic.
  #-----------------------------------------------------------------------------
  def pbFightMenu_Cancel(mechanic, battler, cw)
    pbHidePluginUI
    case mechanic
    when :zmove
      battler.display_base_moves if battler.power_trigger
      battler.power_trigger = false
    when :dynamax
      if battler.power_trigger && !battler.dynamax?
        battler.display_base_moves
        battler.power_trigger = false
      end
    when :style
      battler.style_trigger = 0
      battler.toggle_style_moves
    else
      battler.power_trigger = false
    end
    pbPlayCancelSE
    return DXTriggers::MENU_TRIGGER_CANCEL
  end
  
  #-----------------------------------------------------------------------------
  # Toggles the use of an available battle mechanic.
  #-----------------------------------------------------------------------------
  def pbFightMenu_Action(mechanic, battler, cw)
    ret = refresh = false
    case mechanic
    when :mega    then ret, refresh = pbFightMenu_MegaEvolution(battler, cw)
    when :ultra   then ret, refresh = pbFightMenu_UltraBurst(battler, cw)
    when :zmove   then ret, refresh = pbFightMenu_ZMove(battler, cw)
    when :dynamax then ret, refresh = pbFightMenu_Dynamax(battler, cw)
    when :style   then ret, refresh = pbFightMenu_BattleStyle(battler, cw)
    when :tera    then ret, refresh = pbFightMenu_Terastallize(battler, cw)
    when :zodiac  then ret, refresh = pbFightMenu_ZodiacPower(battler, cw)
    when :custom  then ret, refresh = pbFightMenu_CustomMechanic(battler, cw)
    end
    return ret, refresh
  end
  
  #-----------------------------------------------------------------------------
  # Toggles the use of Mega Evolution.
  #-----------------------------------------------------------------------------
  def pbFightMenu_MegaEvolution(battler, cw)
	battler.power_trigger = !battler.power_trigger
    if battler.power_trigger
      pbPlayBattleButton
    else
      pbPlayCancelSE
    end
    return DXTriggers::MENU_TRIGGER_MEGA_EVOLUTION, false
  end
  
  #-----------------------------------------------------------------------------
  # Toggles the use of a custom battle mechanic.
  #-----------------------------------------------------------------------------
  def pbFightMenu_CustomMechanic(battler, cw)
    pbPlayDecisionSE
    return DXTriggers::MENU_TRIGGER_CUSTOM_MECHANIC, false
  end
  
  #-----------------------------------------------------------------------------
  # Toggles the use of the shift mechanic.
  #-----------------------------------------------------------------------------
  def pbFightMenu_Shift
    pbHidePluginUI
    pbPlayDecisionSE
    return DXTriggers::MENU_TRIGGER_SHIFT_BATTLER
  end
  
  #-----------------------------------------------------------------------------
  # Hides various plugin UI's.
  #-----------------------------------------------------------------------------
  def pbHidePluginUI
    pbHideMoveInfo
    pbHideBattleInfo
    pbHideFocusPanel
    return if pbInSafari?
    @battle.allBattlers.each { |b| @sprites["battler_icon#{b.index}"].visible = false }
  end
  
  def pbHideMoveInfo
    if defined?(@moveUIToggle)
      @moveUIToggle = false
      @sprites["moveinfo"].visible = false
      @moveUIOverlay.clear
    end
  end
  
  def pbHideBattleInfo
    if defined?(@infoUIToggle)
      @infoUIToggle = false
      @sprites["infobitmap"].visible = false
      @sprites["infotext"].visible = false
      @sprites["infoselect"].visible = false
      @infoUIOverlay1.clear
      @infoUIOverlay2.clear
    end
  end
  
  def pbHideFocusPanel
    if defined?(@focusToggle)
      @focusToggle = false
      @sprites["panel"].visible = false
      @sprites["focus"].visible = false
      @focusOverlay.clear
    end
  end
end