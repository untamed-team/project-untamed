class PokemonRegionMap_Scene
  def getQuestName(x, y)
    return "" if ((ENGINE20 && !@map[2]) || (ENGINE21 && !@map.point)) || !@questMap || @mode != 2 || !ARMSettings::SHOW_QUEST_ICONS || @wallmap
    questName = []
    value = ""
    @questNames = nil
    @questMap.each do |name|
      next if (name[1] != x || name[2] != y)
      return "" if name[4] && !$game_switches[name[4]]
      unless !name[3]
        questName.push($quest_data.getName(name[3].id))
        if questName.length >= 2
          @questNames = questName
          value = _INTL("#{questName.length} Active Quests")
        else
          @questNames = questName
          value = _INTL("Quest: #{questName[0]}")
        end
      else
        value = _INTL("Invalid Quest Position")
      end
    end
    updateButtonInfo if !ARMSettings::BUTTON_BOX_POSITION.nil?
    @sprites["modeName"].bitmap.clear
    mapModeSwitchInfo if value == ""
    return value
  end

  def addQuestIconSprites
    usedPositions = {}
    if !@spritesMap["QuestIcons"] && QUESTPLUGIN && ARMSettings::SHOW_QUEST_ICONS
      @spritesMap["QuestIcons"] = BitmapSprite.new(@mapWidth, @mapHeight, @viewportMap)
      @spritesMap["QuestIcons"].x = @spritesMap["map"].x
      @spritesMap["QuestIcons"].y = @spritesMap["map"].y
      @spritesMap["QuestSelect"] = BitmapSprite.new(@mapWidth, @mapHeight, @viewportMap)
      @spritesMap["QuestSelect"].x = @spritesMap["map"].x
      @spritesMap["QuestSelect"].y = @spritesMap["map"].y
      @folder = FOLDER
    end
    return if !@spritesMap["QuestIcons"]
    @questMap.each do |index|
      x = index[1]
      y = index[2]
      icon = index[5] || ""
      next if usedPositions.key?([x, y, icon])
      next if index[4] && !$game_switches[index[4]]
      @spritesMap["QuestIcons"].z = 50
      pbDrawImagePositions(
        @spritesMap["QuestIcons"].bitmap,
        [["#{FOLDER}Icons/Quest/mapQuest#{icon}", pointXtoScreenX(x) , pointYtoScreenY(y)]]
      )
      usedPositions[[x, y, icon]] = true
    end
    @spritesMap["QuestIcons"].visible = QUESTPLUGIN && @mode == 2
  end

  def showQuestInformation(lastChoiceQuest)
    questInfo = @questMap.select { |coords| coords && coords[0..2] == [@region, @mapX, @mapY] }
    questInfo = [] if questInfo.empty? || questInfo[0][3].nil? || (questInfo[0][4] && !$game_switches[questInfo[0][4]])
    return choice = -1 if questInfo.empty?
    input, quest, choice, icon = getCurrentQuestInfo(lastChoiceQuest, questInfo)
    if input && quest
      questInfoText = []
      name = $quest_data.getName(quest.id)
      if ENGINE20
        base = colorToRgb16(ARMSettings::QUEST_INFO_MAIN)
        shadow = colorToRgb16(ARMSettings::QUEST_INFO_SHADOW)
      elsif ENGINE21
        base = (ARMSettings::QUEST_INFO_MAIN).to_rgb15
        shadow = (ARMSettings::QUEST_INFO_SHADOW).to_rgb15
      end
      description = $quest_data.getStageDescription(quest.id, quest.stage)
      description = _INTL("Not Given") if description.empty?
      location = $quest_data.getStageLocation(quest.id, quest.stage)
      location = "Unknown" if location.empty?
      questInfoText[0] = "<c2=#{base}#{shadow}>Task: #{pbGetMessageFromHash(SCRIPTTEXTS, description)}"
      questInfoText[1] = "<c2=#{base}#{shadow}>Location: #{pbGetMessageFromHash(SCRIPTTEXTS, location)}"
      @sprites["mapbottom"].previewName = ["Quest: #{name}", @sprites["previewBox"].width]
      if !@sprites["locationText"]
        @sprites["locationText"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        pbSetSystemFont(@sprites["locationText"].bitmap)
        @sprites["locationText"].visible = false
      end
      @sprites["locationText"].bitmap.clear
      x = 16
      y = 8
      lineHeight = ARMSettings::PREVIEW_LINE_HEIGHT
      questInfoText.each do |text|
        chars = getFormattedText(@sprites["locationText"].bitmap, x, y, 272, -1, text, lineHeight)
        y += (1 + chars.count { |item| item[0] == "\n" }) * lineHeight
        drawFormattedChars(@sprites["locationText"].bitmap, chars)
        @lineCount = (y / lineHeight)
      end
      @lineCount = ARMSettings::MAX_QUEST_LINES if @lineCount > ARMSettings::MAX_QUEST_LINES
      getPreviewBox
      @sprites["locationText"].x = Graphics.width - (@sprites["previewBox"].width + UI_BORDER_WIDTH + ARMSettings::QUEST_INFO_OFFSET_X)
      @sprites["locationText"].y = UI_BORDER_HEIGHT + ARMSettings::QUEST_INFO_OFFSET_Y
      @sprites["locationText"].z = 28
    end
    return choice
  end

  def getCurrentQuestInfo(lastChoiceQuest, questInfo)
    @questInfo = questInfo
    if @questNames && @questNames.length >= 2
      choice = messageMap(_INTL("Which quest would you like to view info about?"),
      (0...@questNames.size).to_a.map{|i|
        next "#{pbGetMessageFromHash(SCRIPTTEXTS, @questNames[i])}"
      }, -1, nil, lastChoiceQuest) { pbUpdate }
      input = choice != -1
      quest = questInfo[choice][3]
    else
      input = true
      quest = questInfo[0][3]
    end
    return input, quest, choice
  end
end

def changeQuestIconChoice(icon)
  @spritesMap["QuestSelect"].bitmap.clear
  icon[4] = "" if icon[4].nil?
  @spritesMap["QuestSelect"].z = 55
  pbDrawImagePositions(
    @spritesMap["QuestSelect"].bitmap,
    [["#{@folder}Icons/Quest/mapQuest#{icon[4]}", pointXtoScreenX(icon[0]) , pointYtoScreenY(icon[1])]]
  )
end
