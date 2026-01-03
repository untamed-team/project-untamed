class PokemonRegionMap_Scene
  def showButtonPreview
    if !@sprites["buttonPreview"]
      @sprites["buttonPreview"] = IconSprite.new(0, 0, @viewport)
      @sprites["buttonPreview"].setBitmap(findUsableUI("mapButtonBox"))
      @sprites["buttonPreview"].z = 24
      @sprites["buttonPreview"].visible = !@flyMap && !@wallmap && !ARMSettings::BUTTON_BOX_POSITION.nil?
    end
  end

  def convertButtonToString(button)
    button = [button] unless button.is_a?(Array)
    controlPanel = $PokemonSystem.respond_to?(:game_controls)
    names = []
    button.each do |btn|
      case btn
      when 2
        buttonName = controlPanel ? _INTL("Down") : _INTL("DOWN")
      when 4
        buttonName = controlPanel ? _INTL("Left") : _INTL("LEFT")
      when 6
        buttonName = controlPanel ? _INTL("Right") : _INTL("RIGHT")
      when 8
        buttonName = controlPanel ? _INTL("Up") : _INTL("UP")
      when 11
        buttonName = controlPanel ? _INTL("Menu") : _INTL("ACTION")
      when 12
        buttonName = controlPanel ? _INTL("Cancel") : _INTL("BACK")
      when 13
        buttonName = controlPanel ? _INTL("Action") : _INTL("USE")
      when 14
        buttonName = controlPanel ? _INTL("Scroll Up") : _INTL("JUMPUP")
      when 15
        buttonName = controlPanel ? _INTL("Scroll Down") : _INTL("JUMPDOWN")
      when 16
        buttonName = controlPanel ? _INTL("Ready Menu") : _INTL("SPECIAL")
      when 17
        buttonName = "AUX1" #Unused
      when 18
        buttonName = "AUX2" #Unused
      else
        return buttonName = "Ctrl"
      end
      names << buttonName
    end
    if controlPanel && (!names.any? { |btn| btn == "AUX1" || btn == "AUX2" })
      newNames = []
      names.each_with_index do |buttonName, index|
        buttonName = $PokemonSystem.game_controls.find{|c| c.control_action == buttonName.to_s}.key_name
        buttonName = makeButtonNameShorter(buttonName)
        newNames << buttonName
      end
      names = newNames
    end
    buttonName = names.join("/")
    return buttonName
  end

  def makeButtonNameShorter(button)
    case button
    when "Backspace"
      button = _INTL("Return")
    when "Caps Lock"
      button = _INTL("Caps")
    when "Page Up"
      button = _INTL("pg Up")
    when "Page Down"
      button = _INTL("pg Dn")
    when "Print Screen"
      button = _INTL("prt Scr")
    when "Numpad 0"
      button = _INTL("Num 0")
    when "Numpad 1"
      button = _INTL("Num 1")
    when "Numpad 2"
      button = _INTL("Num 2")
    when "Numpad 3"
      button = _INTL("Num 3")
    when "Numpad 4"
      button = _INTL("Num 4")
    when "Numpad 5"
      button = _INTL("Num 5")
    when "Numpad 6"
      button = _INTL("Num 6")
    when "Numpad 7"
      button = _INTL("Num 7")
    when "Numpad 8"
      button = _INTL("Num 8")
    when "Numpad 9"
      button = _INTL("Num 9")
    when "multiply"
      button = _INTL("Multi")
    when "Separator"
      button = _INTL("Sep")
    when "Subtract"
      button = _INTL("Sub")
    when "Decimal"
      button = _INTL("Dec")
    when "Divide"
      button = _INTL("Div")
    when "Num Lock"
      button = _INTL("Num")
    when "Scroll Lock"
      button = _INTL("Scroll")
    end
    return button
  end

  def updateButtonInfo(name = "", replaceName = "")
    @timer = 0 if !@timer
    frames = ARMSettings::BUTTON_PREVIEW_TIME_CHANGE * Graphics.frame_rate
    if @modeCount > 1 && !@previewBox.isExtShown
      textPos = getTextPosition
      width = @previewBox.isShown && @mode == 2 && BOX_TOP_LEFT ? (Graphics.width - @sprites["previewBox"].width) : @sprites["buttonPreview"].width
      x = (textPos[0] + (width / 2)) + ARMSettings::BUTTON_BOX_TEXT_OFFSET_X
      y = (textPos[1] + 14) + ARMSettings::BUTTON_BOX_TEXT_OFFSET_Y
      align = 2
    else
      x = Graphics.width - (22 - ARMSettings::MODE_NAME_OFFSET_X)
      y = 4 + ARMSettings::MODE_NAME_OFFSET_Y
      align = 1
    end
    getAvailableActions(name, replaceName)
    avActions = @mapActions.select { |_, action| action[:condition] }.values
    avActions.sort_by! { |action| action[:order] }
    if avActions != @prevAvActions
      @prevAvActions = avActions
      @timer = 0
    end
    actionsLength = avActions.length > 0 ? avActions.length : 1
    @indActions = (@timer / frames) % actionsLength || 0
    if avActions.any?
      selActions = avActions[@indActions % actionsLength]
      if selActions[:button]
        button = pbGetMessageFromHash(SCRIPTTEXTS, convertButtonToString(selActions[:button]))
        text = "#{button}: #{selActions[:text]}"
      end
      @sprites["buttonName"].bitmap.clear
      pbDrawTextPositions(
        @sprites["buttonName"].bitmap,
        [[text.to_s, x, y, align, ARMSettings::BUTTON_BOX_TEXT_MAIN, ARMSettings::BUTTON_BOX_TEXT_SHADOW]]
        )
        @sprites["buttonName"].visible = !ARMSettings::BUTTON_BOX_POSITION.nil?
      if @modeCount > 1 && !@previewBox.isExtShown
        @sprites["buttonName"].z = 25
      else
        @sprites["buttonName"].z = 100002
      end
    end
  end

  def getAvailableActions(name = "", replaceName = "")
    getAvailableRegions if !@avRegions
    @mapActions = {
      :ChangeMode => {
        condition: @modeCount >= 2 && !@searchActive && !@previewBox.isExtShown && !@zoom,
        text: _INTL("Change Mode"),
        button: ARMSettings::CHANGE_MODE_BUTTON,
        order: 50
      },
      :ChangeRegion => {
        condition: @avRegions.length >= 2 && @previewBox.isHidden && !@searchActive && !@flyMap && !@zoom,
        text: _INTL("Change Region"),
        button: ARMSettings::CHANGE_REGION_BUTTON,
        order: 60
      },
      :ZoomModeEnable => {
        condition: ARMSettings::USE_REGION_MAP_ZOOM && !@zoom && @mode == 0 && !@previewBox.isExtShown,
        text: _INTL("Enable Zoom"),
        button: ARMSettings::TOGGLE_ZOOM_BUTTON,
        order: 40
      },
      :ZoomModeDisable => {
        condition: ARMSettings::USE_REGION_MAP_ZOOM && @zoom && @mode == 0 && !@previewBox.isExtShown,
        text: _INTL("Disable Zoom"),
        button: ARMSettings::TOGGLE_ZOOM_BUTTON,
        order: 20
      },
      :ZoomMapInOut => {
        condition: ARMSettings::USE_REGION_MAP_ZOOM && @zoom && @mode == 0 && @zoomIndex == 1 && @zoomHash[0][:enabled] && @zoomHash[2][:enabled] && !@previewBox.isExtShown,
        text: _INTL("Zoom In/Out"),
        button: [ARMSettings::ZOOM_IN_BUTTON, ARMSettings::ZOOM_OUT_BUTTON],
        order: 10
      },
      :ZoomMapIn => {
        condition: ARMSettings::USE_REGION_MAP_ZOOM && @zoom && @mode == 0 && (@zoomIndex == 2 || (!@zoomHash[2][:enabled] && @zoomIndex == 1)) && !@previewBox.isExtShown,
        text: _INTL("Zoom In"),
        button: ARMSettings::ZOOM_IN_BUTTON,
        order: 10
      },
      :ZoomMapOut => {
        condition: ARMSettings::USE_REGION_MAP_ZOOM && @zoom && @mode == 0 && (@zoomIndex == 0 || (!@zoomHash[2][:enabled] && @zoomIndex == 1)) && !@previewBox.isExtShown,
        text: _INTL("Zoom Out"),
        button: ARMSettings::ZOOM_OUT_BUTTON,
        order: 10
      },
      :ViewInfo => {
        condition: (@mode == 0 && !@searchActive && @previewBox.isHidden && name != "" && (name != replaceName || ARMSettings::CAN_VIEW_INFO_UNVISITED_MAPS) || @lineCount == 0) && !@wallmap,
        text: _INTL("View Info"),
        button: ARMSettings::SHOW_LOCATION_BUTTON,
        order: 30
      },
      :HideInfo => {
        condition: @mode == 0 && @previewBox.isShown && @lineCount != 0 && @curLocName != "",
        text: _INTL("Hide Info"),
        button: Input::BACK,
        order: 30
      },
      :ViewExtInfo => {
        condition: (@mode == 0 && @previewBox.isShown) && !@cannotExtPreview, # for v2.6.0
        text: _INTL("Extend Info"),
        button: ARMSettings::SHOW_EXTENDED_BUTTON,
        order: 20
      },
      :HideExtInfo => {
        condition: @previewBox.isExtShown && @extendedBox.isMain,
        text: _INTL("Hide Info"),
        button: Input::BACK,
        order: 30
      },
      :ShowEncTable => {
        condition: @previewBox.isExtShown && ARMSettings::PROGRESS_COUNT_POKEMON && !@data.nil? && !@getData.nil? && @getData.values[@dataIndex][:wildAv] && @extendedBox.isMain,
        text: _INTL("View Encounter Info"),
        button: ARMSettings::SHOW_EXTENDED_SUB_MENU,
        order: 10
      },
      :ShowEncDetails => {
        condition: @extendedBox.isSubOne  && !@activeIndex.empty?,
        text: _INTL("Select Species"),
        button: ARMSettings::SELECT_SPECIES_BUTTON,
        order: 10
      },
      :RevealSpecies => {
        condition: !ARMSettings::REVEAL_ALL_SEEN_SPECIES_BUTTON.nil? && @extendedBox.isSubOne && !@revealAllSeen && @countSpecies != updateSpeciesCount(true),
        text: _INTL("Reveal Seen Species"),
        button: ARMSettings::REVEAL_ALL_SEEN_SPECIES_BUTTON,
        order: 20
      },
      :HideSpecies => {
        condition: !ARMSettings::REVEAL_ALL_SEEN_SPECIES_BUTTON.nil? && @extendedBox.isSubOne && @revealAllSeen && @countSpecies != updateSpeciesCount(false),
        text: _INTL("Hide Seen Species"),
        button: ARMSettings::REVEAL_ALL_SEEN_SPECIES_BUTTON,
        order: 20
      },
      :ChangePage => {
        condition: (@previewBox.isExtShown && @getData && @getData.length > 1 && @extendedBox.isMain) || (@extendedBox.isSubOne && @tableData.length > 1) && !@extendedBox.isSubTwo,
        text: _INTL("Change Page"),
        button: [Input::LEFT, Input::RIGHT],
        order: 30
      },
      :ChangeSpecies => {
        condition: @extendedBox.isSubTwo && @activeIndex.length > 1,
        text: _INTL("Change Species"),
        button: [Input::JUMPUP, Input::JUMPDOWN],
        order: 20
      },
      :ChangeSpeciesInfo => {
        condition: @extendedBox.isSubTwo && !@activeIndex.empty? && @activeIndex.include?(@extIndex),
        text: _INTL("Change Info"),
        button: ARMSettings::SELECT_SPECIES_BUTTON,
        order: 10
      },
      :GoPreviousPage => {
        condition: @extendedBox.isSubOne || @extendedBox.isSubTwo,
        text: _INTL("Go Back"),
        button: Input::BACK,
        order: 40
      },
      :SearchLocation => {
        condition: @mode == 0 && @previewBox.isHidden && @listMaps && !@listMaps.empty? && enableMode(ARMSettings::CAN_LOCATION_SEARCH) && @listMaps.length >= ARMSettings::MINIMUM_MAPS_COUNT && !@zoom,
        text: _INTL("Search Location"),
        button: ARMSettings::LOCATION_SEARCH_BUTTON,
        order: 40
      },
      :QuickSearch => {
        condition: @searchActive,
        text: _INTL("Quick Search"),
        button: ARMSettings::QUICK_SEARCH_BUTTON,
        order: 10
      },
      :OrderSearch => {
        condition: @searchActive,
        text: _INTL("Sort Search"),
        button: ARMSettings::ORDER_SEARCH_BUTTON,
        order: 20
      },
      :QuickFly => {
        condition: @mode == 1 && enableMode(ARMSettings::CAN_QUICK_FLY) && !getFlyLocations.empty?,
        text: _INTL("Quick Fly"),
        button: ARMSettings::QUICK_FLY_BUTTON,
        order: 10
      },
      :ShowQuest => {
        condition: @mode == 2 && @questNames.is_a?(Array) && @questNames.length < 2 && @previewBox.isHidden,
        text: _INTL("View Quest"),
        button: ARMSettings::SHOW_QUEST_BUTTON,
        order: 10
      },
      :HideQuest => {
        condition: @mode == 2 && @previewBox.isShown,
        text: _INTL("Hide Quest"),
        button: Input::BACK,
        order: 20
      },
      :ShowQuests => {
        condition: @mode == 2 && @questNames.is_a?(Array) && @questNames.length >= 2 && @previewBox.isHidden,
        text: _INTL("View Quests"),
        button: ARMSettings::SHOW_QUEST_BUTTON,
        order: 10
      },
      :ChangeQuest => {
        condition: @mode == 2 && @questNames.is_a?(Array) && @questNames.length >= 2 && @previewBox.isShown,
        text: _INTL("Change Quest"),
        button: ARMSettings::SHOW_QUEST_BUTTON,
        order: 10
      },
      :ShowBerry => {
        condition: @mode == 3 && checkBerriesOnPosition && @previewBox.isHidden,
        text: _INTL("Show Berry"),
        button: ARMSettings::SHOW_BERRY_BUTTON,
        order: 10
      },
      :ShowBerries => {
        condition: @mode == 3 && checkBerriesOnPosition(true) && @previewBox.isHidden,
        text: _INTL("Show Berries"),
        button: ARMSettings::SHOW_BERRY_BUTTON,
        order: 10
      },
      :ChangeBerry => {
        condition: @mode == 3 && !@berryPlants.nil? && @berryPlants.length >= 2 && @previewBox.isShown,
        text: _INTL("Change Berry"),
        button: ARMSettings::SHOW_BERRY_BUTTON,
        order: 10
      },
      :HideBerry => {
        condition: @mode == 3 && @previewBox.isShown,
        text: _INTL("Hide Berry"),
        button: Input::BACK,
        order: 20
      },
      :Quit => {
        condition: @previewBox.isHidden && !@searchActive,
        text: _INTL("Close Map"),
        button: Input::BACK,
        order: 90
      }
    }
  end
end
