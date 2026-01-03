class PokemonRegionMap_Scene
  def confirmMessageMap(message, &block)
    return (messageMap(message, [_INTL("Yes"), _INTL("No")], 2, nil, 0, false, &block) == 0)
  end

  def messageMap(message, commands = nil, cmdIfCancel = 0, skin = nil, defaultCmd = 0, choiceUpdate = false, &block)
    ret = 0
    msgwindow = pbCreateMessageWindow(nil, skin)
    msgwindow.z = 100002
    if commands
      ret = pbMessageDisplay(msgwindow, message, true,
                             proc { |msgwindow|
                               next showCommandsMap(msgwindow, commands, cmdIfCancel, defaultCmd, choiceUpdate, &block)
                             }, &block)
    else
      pbMessageDisplay(msgwindow, message, &block)
    end
    pbDisposeMessageWindow(msgwindow)
    Input.update
    return ret
  end
  
  def showCommandsMap(msgwindow, commands = nil, cmdIfCancel = 0, defaultCmd = 0, choiceUpdate = false)
    return 0 if !commands
    cmdwindow = Window_CommandPokemonEx.new(commands, nil, true)
    cmdwindow.z = 100002
    cmdwindow.visible = true
    cmdwindow.resizeToFit(cmdwindow.commands)
    pbPositionNearMsgWindow(cmdwindow, msgwindow, :right)
    cmdwindow.index = defaultCmd
    command = 0
    sorted = false
    loop do
      Graphics.update
      Input.update
      cmdwindow.update
      if @mode == 2 && @ChangeQuestIcon
        quest = @questInfo[cmdwindow.index][3]
        icon = @questMap.find { |ar| ar[3] == quest }[1..5]
        changeQuestIconChoice(icon) if !icon.nil?
      end 
      if choiceUpdate && ARMSettings::AUTO_CURSOR_MOVEMENT
        if @mode == 1
          @mapX = @visited[cmdwindow.index][:x]
          @mapY = @visited[cmdwindow.index][:y]
        else
          @mapX = @listMaps[cmdwindow.index][:pos][:x]
          @mapY = @listMaps[cmdwindow.index][:pos][:y]
        end 
        @sprites["cursor"].x = 8 + (@mapX * ARMSettings::SQUARE_WIDTH)
        @sprites["cursor"].y = 24 + (@mapY * ARMSettings::SQUARE_HEIGHT)
        @sprites["cursor"].x -= UI_BORDER_WIDTH if ARMSettings::REGION_MAP_BEHIND_UI
        @sprites["cursor"].y -= UI_BORDER_HEIGHT if ARMSettings::REGION_MAP_BEHIND_UI
        showAndUpdateMapInfo
        centerMapOnCursor
        updateMapRange
      end
      msgwindow&.update
      yield if block_given?
      if Input.trigger?(Input::BACK)
        if cmdIfCancel > 0
          command = cmdIfCancel - 1
          break
        elsif cmdIfCancel < 0
          command = cmdIfCancel
          break
        end
      end
      if Input.trigger?(Input::USE)
        command = cmdwindow.index
        break
      elsif @searchActive
        if Input.trigger?(ARMSettings::QUICK_SEARCH_BUTTON)
          if $resultWindow
            $resultWindow.dispose
            $resultWindow = nil 
          end
          term = pbMessageFreeTextMap("", "", 32)
          @listMaps = updateLocationList(term).sort_by { |loc| loc[:name].downcase }
          times = sorted ? "once" : "twice"
          msgwindow.text = _INTL("Choose a Location (press #{convertButtonToString(ARMSettings::ORDER_SEARCH_BUTTON)} #{times} to undo the Quick Search.)")
          msgwindow.letterbyletter = false
          updateCmdWindowMap(cmdwindow, msgwindow)
          pbPositionNearMsgWindow($resultWindow, msgwindow, :left)
          cmdwindow.index = 0
          findChoice = @listMaps.find_index { |pos| @curMapLoc == pos[:name] }
        elsif Input.trigger?(ARMSettings::ORDER_SEARCH_BUTTON)
          if !sorted
            if @listMaps.length == updateLocationList("").length
              msgwindow.text = _INTL("Choose a Location (press #{convertButtonToString(ARMSettings::ORDER_SEARCH_BUTTON)} to unorder the list.)")
              msgwindow.letterbyletter = false
            end
            @listMaps = @listMaps.sort_by { |loc| loc[:name].downcase }
            sorted = true
          else
            if $resultWindow
              $resultWindow.dispose
              $resultWindow = nil
            end
            msgwindow.text = _INTL("Choose a Location (press #{convertButtonToString(ARMSettings::ORDER_SEARCH_BUTTON)} to order the list.)")
            msgwindow.letterbyletter = false
            @listMaps = updateLocationList("")
            sorted = false
          end 
          updateCmdWindowMap(cmdwindow, msgwindow)
          findChoice = @listMaps.find_index { |pos| @curMapLoc == pos[:name] }
        end
      end
      cmdwindow.index = findChoice if findChoice
      pbUpdateSceneMap
    end
    ret = command
    cmdwindow.dispose
    Input.update
    return ret
  end

  def updateCmdWindowMap(cmdwindow, msgwindow)
    cmdwindow.commands = @listMaps.map { |mapData| mapData[:name] }
    cmdwindow.update
    cmdwindow.resizeToFit(cmdwindow.commands)
    pbPositionNearMsgWindow(cmdwindow, msgwindow, :right)
  end 

  def freeTextMap(msgwindow, currenttext, maxlength, width = 240)
    window = Window_TextEntry_Keyboard.new(currenttext, 0, 0, width, 64)
    ret = ""
    window.maxlength = maxlength
    window.visible = true
    window.z = 100002
    pbPositionNearMsgWindow(window, msgwindow, :left)
    window.text = currenttext
    Input.text_input = true
    index = @termList.length - 1 if @termList
    loop do
      Graphics.update
      Input.update
      if Input.triggerex?(:ESCAPE)
        ret = ""
        break
      elsif Input.triggerex?(:RETURN)
        ret = window.text
        break
      elsif @termList # @termList does exist.
        if Input.trigger?(Input::CTRL)
          index = (@termList.length - 1) if index < 0 
          window.text = @termList[index]
          index -= 1
        end 
      end
      window.update
      msgwindow&.update
      yield if block_given?
    end
    Input.text_input = false
    window.dispose
    Input.update
    return ret
  end
  
  def pbMessageFreeTextMap(message, currenttext, maxlength, width = 240, &block)
    msgwindow = pbCreateMessageWindow
    retval = pbMessageDisplay(msgwindow, message, true,
                              proc { |msgwndw|
                                next freeTextMap(msgwndw, currenttext, maxlength, width, &block)
                              }, &block)
    pbDisposeMessageWindow(msgwindow)
    return retval
  end
end 