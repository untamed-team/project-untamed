class PokemonRegionMap_Scene
  def getExtendedPreview
    if !@sprites["previewExtMain"]
      @sprites["previewExtMain"] = IconSprite.new(UI_BORDER_WIDTH, UI_BORDER_HEIGHT, @viewport)
      @sprites["previewExtMain"].z = 40
      @sprites["previewExtMain"].visible = false
      @sprites["previewExtMain"].setBitmap(findUsableUI("ExtendedPreview/mapExtBoxMain"))
    end
    if !@sprites["extendedText"]
      @sprites["extendedText"] = BitmapSprite.new(UI_WIDTH, UI_HEIGHT, @viewport)
      pbSetSystemFont(@sprites["extendedText"].bitmap)
      @sprites["extendedText"].visible = false
      @sprites["extendedText"].z = 80
      @sprites["extendedText"].x = UI_BORDER_WIDTH
      @sprites["extendedText"].y = UI_BORDER_HEIGHT
    end
    if !@sprites["previewExtTextBoxes"] && SPECIAL_UI
      @sprites["previewExtTextBoxes"] = BitmapSprite.new(UI_WIDTH, UI_HEIGHT, @viewport)
      @sprites["previewExtTextBoxes"].visible = false
      @sprites["previewExtTextBoxes"].z = 50
      @sprites["previewExtTextBoxes"].x = UI_BORDER_WIDTH
      @sprites["previewExtTextBoxes"].y = UI_BORDER_HEIGHT
    end
  end

  def showExtendedPreview
    @sprites["modeName"].visible = false
    @sprites["previewExtMain"].visible = true
    @previewBox.extShow
    updateArrows
    getExtendedInfo
    extendedMain
  end

  def extendedMain
    loop do
      Graphics.update
      Input.update
      pbUpdate
      @timer += 1 if @timer
      updateButtonInfo if !ARMSettings::BUTTON_BOX_POSITION.nil?
      if Input.trigger?(Input::BACK)
        if @previewBox.isExtShown
          hideExtendedPreview
          showAndUpdateMapInfo
          break
        end
      elsif Input.trigger?(Input::LEFT)
        if @dataIndex > 0
          @dataIndex -= 1
        else
          @dataIndex = @getData.length - 1
        end
        drawDataMain
      elsif Input.trigger?(Input::RIGHT)
        if @dataIndex < @getData.length - 1
          @dataIndex += 1
        else
          @dataIndex = 0
        end
        drawDataMain
      elsif ARMSettings::PROGRESS_COUNT_POKEMON && Input.trigger?(ARMSettings::SHOW_EXTENDED_SUB_MENU) && !@data.nil? && @data[:wildAv]
        @sprites["extendedText"].bitmap.clear
        @sprites["previewExtTextBoxes"].bitmap.clear if @sprites["previewExtTextBoxes"]
        @extendedBox.subOne
        showExtendedSub
      end
    end
  end

  def getExtendedInfo
    gameMaps = getGameMaps
    @revealAllSeen = ARMSettings::REVEAL_ALL_SEEN_SPECIES_BUTTON.nil?
    @getData = {}
    gameMaps.each do |gameMap|
      percentage = { progress: 0, total: 0 }
      map = GameData::MapMetadata.try_get(gameMap)
      name = ARMSettings::LINK_POI_TO_MAP.key(map.id) || map.name
      match = name.match(/\\v\[(\d+)\](.*)/)
      if match
        varPart = match[0]
        varNum = match[1]
        varRem = match[2]
        name = "#{$game_variables[varNum.to_i]}#{varRem}"
      end
      next unless $PokemonGlobal.visitedMaps[map.id] || (!ARMSettings::NO_UNVISITED_MAP_INFO && ARMSettings::CAN_VIEW_INFO_UNVISITED_MAPS )
      totalWild, seen, caught, battled, wildText = getWildInfo(map, gameMap)
      district = getDistrictName(map)
      totalTrainers, trainers, defeated, trainerText = getTrainerInfo(map, district)
      totalItems, items, found, itemText = getItemInfo(map, district)
      percentage[:progress] = [seen, caught, battled, defeated, found].each { |value| toNumber(value) }.sum
      percentage[:total] = [totalWild, totalTrainers, totalItems].sum
      unless percentage[:total] == 0
        progress = !ARMSettings::DISABLE_EXTENDED_PREVIEW_PERCENTAGE ? "- #{convertIntegerOrFloat(((percentage[:progress].to_f / percentage[:total]) * 100).round(1))}%" : ""
      end
      if ARMSettings::EXCLUDE_MAPS_WITH_NO_DATA
        next if [wildText, trainerText, itemText].all? { |text| text[0][0..1] == "No" } && !map.has_flag?("EnExtPrev")
      end
      @getData[map.id] = {
        :wild => wildText,
        :wildAv => !wildText[0].include?("No Encounter Data"),
        :trainers => trainerText,
        :trainerAv => !trainerText[0].include?("No Trainers to defeat."),
        :items => itemText,
        :itemAv => !itemText[0].include?("No Items to find."),
        :name => name,
        :progress => progress
      } if !@getData.keys.include?(name)
    end
    @dataIndex = @getData.find_index { |data| data[0] == $game_map.map_id }
    @dataIndex = 0 if @dataIndex.nil?
    drawDataMain
    @sprites["extendedText"].visible = true
  end

  def getGameMaps
    map = nil
    gameMaps = []
    GameData::MapMetadata.each do |gameMap|
      mapPos = gameMap.town_map_position
      next unless (!mapPos.nil? && pbGetMapLocation(@mapX, @mapY) == gameMap.name) ||
                  (gameMap.name.include?($player.name) || gameMap.name.include?("\\v[")) &&
                  gameMap.town_map_position == [@region, @mapX, @mapY]
      next if gameMap.has_flag?("DisExtPrev")
      gameMaps << gameMap.id
      map = gameMap if map.nil?
    end
    mapPosArray = getValidMapPositions(map)
    ARMSettings::LINK_POI_TO_MAP.each do |name, id|
      break if map.nil?
      mapToAdd = GameData::MapMetadata.try_get(id)
      next if mapToAdd.has_flag?("DisExtPrev")
      if !mapToAdd.town_map_position.nil? && mapPosArray.include?(mapToAdd.town_map_position) && !gameMaps.include?(id)
        gameMaps << id
      end
    end
    return gameMaps
  end

  def getWildInfo(map, gameMap)
    return 0, 0, 0, 0, ["Disabled"] if !ARMSettings::PROGRESS_COUNT_POKEMON
    unless GameData::Encounter.get(map.id, $PokemonGlobal.encounter_version).nil?
      list = getEncounterInfo(gameMap).flat_map { |_, value| value.keys }.uniq
      seen, caught, battled = 0, 0, 0
      list.each do |species|
        form = !GameData::Species.get(species).flags.empty? || GameData::Species.get(species).form > 0 ? GameData::Species.get(species).form : nil
        seen += 1 if seenFormAnyGender(gameMap, species, form)
        caught += 1 if caughtFormAnyGender(gameMap, species, form)
        battled += 1 if defeatedFormAnyGender(gameMap, species, form)
      end
      wildText = ["Wild Encounters" , "#{" "*5}#{seen} seen", "#{" "*5}#{caught} caught", "#{" "*5}#{battled} defeated"]
    else
      seen = caught = battled = 0
      wildText = ["No Encounter Data."]
    end
    totalWild = @globalCounter[:gameMaps][:wild][map.id] || 0
    totalWild *= 3 if !totalWild.nil?
    return totalWild, seen, caught, battled, wildText
  end

  def getTrainerInfo(map, district)
    return 0, 0, 0, ["Disabled"] if !ARMSettings::PROGRESS_COUNT_TRAINERS
    totalTrainers = @globalCounter[:gameMaps][:trainers][map.id]
    trainers = $ArckyGlobal.trainerTracker&.dig(district, :maps, map.id) unless $ArckyGlobal.trainerTracker&.dig(district, :maps)&.empty?
    defeated = trainers.nil? ? 0 : trainers[:defeated]
    if totalTrainers == 0
      trainerText = ["No Trainers to defeat."]
    else
      if defeated == totalTrainers
        trainerText = ["Trainers", "Hooray! All trainers are defeated!"]
      else
        trainerText = ["Trainers", "#{" "*5}#{defeated} out of #{totalTrainers} defeated."]
      end
    end
    return totalTrainers, trainers, defeated, trainerText
  end

  def getItemInfo(map, district)
    return 0, 0, 0, ["Disabled"] if !ARMSettings::PROGRESS_COUNT_ITEMS
    totalItems = @globalCounter[:gameMaps][:items][map.id] || 0
    items = $ArckyGlobal.itemTracker&.dig(district, :maps, map.id) unless $ArckyGlobal.itemTracker&.dig(district, :maps)&.empty?
    found = items.nil? ? 0 : items[:found]
    ARMSettings::COUNT_ITEMS_TO_MAIN_MAP.each do |main|
      if main[0] == map.id
        main[1].each do |id|
          totalItems += @globalCounter[:gameMaps][:items][id]
          item = $ArckyGlobal.itemTracker&.dig(district, :maps, id) unless $ArckyGlobal.itemTracker&.dig(district, :maps)&.empty?
          found += item[:found] unless item.nil?
        end
      end
    end
    if totalItems == 0
      itemText = ["No Items to find."]
    else
      if found == totalItems
        itemText = ["Items", "#{" "*5}Hooray! All Items are found!"]
      else
        itemText = ["Items", "#{" "*5}#{found} out of #{totalItems} found."]
      end
    end
    return totalItems, items, found, itemText
  end

  def drawDataMain
    @sprites["extendedText"].bitmap.clear
    @sprites["previewExtTextBoxes"].bitmap.clear if @sprites["previewExtTextBoxes"]
    @extWidth = @sprites["previewExtMain"].width
    @extHeight = @sprites["previewExtMain"].height
    @data = @getData.values[@dataIndex]
    @sprites["mapbottom"].mapname = "#{@data[:name]} #{@data[:progress]}" if !@data.nil?
    @sprites["mapbottom"].maplocation = "Page #{@dataIndex + 1}/#{@getData.length}"
    @sprites["mapbottom"].mapdetails  = ""
    text = []
    image = []
    totalHeight = boxHeight = 0
    @lineHeight = 32
    @fontSize = @sprites["extendedText"].bitmap.font.size
    @base = ARMSettings::EXTENDED_TEXT_MAIN_BASE
    @shadow = ARMSettings::EXTENDED_TEXT_MAIN_SHADOW
    y = 12
    boxY = 4
    lines = 4
    reduce = 0
    unless @data.nil? || [@data[:wild], @data[:trainers], @data[:items]].all? { |value| value[0].include?("No") || value[0] == "Disabled" }
      [@data[:wild], @data[:trainers], @data[:items]].each_with_index do |data, index|
        data.each_with_index do |txt, index2|
          if txt == "Disabled"
            reduce += 6
            next
          end
          x = 16
          align = :left
          if SPECIAL_UI
            if index2 == 0
              graphic = index == 0 ? findUsableUI("ExtendedPreview/mapTextBoxOne") : findUsableUI("ExtendedPreview/mapTextBoxTwo")
              bitmap = Bitmap.new(graphic)
              boxWidth = bitmap.width
              boxHeight = bitmap.height
              boxX = (@extWidth - boxWidth) / 2
              if index != 0
                boxY = (4 + (6 * index) + totalHeight) - reduce
                lines = 2
              end
              totalHeight += boxHeight
            end
            if data.length == 1
              x = boxX + (boxWidth / 2)
              y = boxY + ((boxHeight - @fontSize) / 2)
              align = :center
            else
              y = (boxY + ((boxHeight - ((@lineHeight * lines) - (@lineHeight - @fontSize))) / 2) + (@lineHeight * index2))
            end
            image << [graphic, boxX, boxY] if index2 == 0
          else
            y += @lineHeight unless index == 0 && index == index2
          end
          case index
          when 0
            x += ARMSettings::EXTENDED_TEXT_MAIN_WILD_X
            y += ARMSettings::EXTENDED_TEXT_MAIN_WILD_Y
          when 1
            x += ARMSettings::EXTENDED_TEXT_MAIN_TRAINER_X
            y += ARMSettings::EXTENDED_TEXT_MAIN_TRAINER_Y
          when 2
            x += ARMSettings::EXTENDED_TEXT_MAIN_ITEM_X
            y += ARMSettings::EXTENDED_TEXT_MAIN_ITEM_Y
          end
          text << [txt, x, y, align, @base, @shadow]
        end
      end
    else
      x = (@extWidth / 2)
      y = 4 + ((@extHeight - @fontSize) / 2)
      if SPECIAL_UI
        graphic = findUsableUI("ExtendedPreview/mapTextBoxThree")
        bitmap = Bitmap.new(graphic)
        boxWidth = bitmap.width
        boxHeight = bitmap.height
        boxX = (@extWidth - boxWidth) / 2
        boxY = (@extHeight - boxHeight) / 2
        image << [graphic, boxX, boxY]
      end
      text << ["No Data for this Location", x, y, :center, @base, @shadow]
    end
    pbDrawTextPositions(@sprites["extendedText"].bitmap, text)
    if SPECIAL_UI
      pbDrawImagePositions(@sprites["previewExtTextBoxes"].bitmap, image)
      @sprites["previewExtTextBoxes"].visible = true
    end
  end

  def showExtendedSub
    mapID = @getData.keys[@dataIndex]
    @tableData = getEncounterInfo
    drawEncTable
    extendedSub
  end

  def getEncounterInfo(mapID = nil)
    tableData = {}
    mapID = @getData.keys[@dataIndex] if mapID.nil?
    encounterData = GameData::Encounter.get(mapID, $PokemonGlobal.encounter_version)
    @encounterTables = Marshal.load(Marshal.dump(encounterData.types))
    @encounterTables.each do |type, enc|
      encType = ARMSettings::ENCOUNTER_TYPES[type]
      if encType.nil?
        Console.echoln_li _INTL("Encounter Type '#{type}' has not been added to ENCOUNTER_TYPES in 000_RegionMap_Settings.rb")
        next
      end
      data = getEncChances(enc, encType)
      encounters = enc.map { |enc| enc[1] }.uniq
      tableData[encType] = data
    end
    @tableIndex = 0
    return tableData
  end

  def extendedSub
    loop do
      Graphics.update
      Input.update
      pbUpdate
      @timer += 1 if @timer
      updateButtonInfo if !ARMSettings::BUTTON_BOX_POSITION.nil?
      updateSprites
      if Input.trigger?(Input::BACK)
        @sprites["EncounterBoxes"].visible = false
        disposeSprites
        drawDataMain
        @lastIndex = nil
        @extendedBox.main
        @sprites["previewExtMain"].setBitmap(findUsableUI("ExtendedPreview/mapExtBoxMain"))
        break
      elsif Input.trigger?(Input::LEFT)
        if @tableIndex > 0
          @tableIndex -= 1
        else
          @tableIndex = @tableData.length - 1
        end
        @lastIndex = nil
        disposeSprites
        drawEncTable
      elsif Input.trigger?(Input::RIGHT)
        if @tableIndex < @tableData.length - 1
          @tableIndex += 1
        else
          @tableIndex = 0
        end
        @lastIndex = nil
        disposeSprites
        drawEncTable
      elsif Input.trigger?(ARMSettings::SELECT_SPECIES_BUTTON) && !@activeIndex.empty?
        @extendedBox.subTwo
        getEncCursor
      elsif !ARMSettings::REVEAL_ALL_SEEN_SPECIES_BUTTON.nil? && Input.trigger?(ARMSettings::REVEAL_ALL_SEEN_SPECIES_BUTTON)
        @revealAllSeen = !@revealAllSeen
        if @countSpecies != updateSpeciesCount
          disposeSprites
          drawEncTable
        end
      end
    end
  end

  def drawEncTable
    @pageIndex = 0
    @textRow = 0
    getEncIcons
    @sprites["mapbottom"].mapname = "#{@data[:name]} #{@typeProgress}"
    @sprites["mapbottom"].maplocation = "Page #{@tableIndex + 1}/#{@tableData.length}"
    @sprites["mapbottom"].mapdetails  = @tableData.keys[@tableIndex]
    @sprites["previewExtMain"].setBitmap(changeExtBoxMainAndEncBox("Ext")) if ARMSettings::CHANGE_EXT_BOX_ON_ENCOUNTER_TYPE
  end

  def changeExtBoxMainAndEncBox(type)
    return findUsableUI("ExtendedPreview/mapEncBox") if type == "Enc" && !ARMSettings::CHANGE_ENC_BOX_ON_ENCOUNTER_TYPE
    encType = @tableData.keys[@tableIndex]
    encKey = ARMSettings::ENCOUNTER_TYPES.find { |k, v| v == encType }&.first
    path = findUsableUI("ExtendedPreview/map#{type}Box#{encKey}")
    bitmap = pbResolveBitmap(path)
    if !bitmap
      case encKey
      when /Land/
        path = findUsableUI("ExtendedPreview/map#{type}BoxLand")
      when /Water/
        path = findUsableUI("ExtendedPreview/map#{type}BoxWater")
      when /Rod/
        path = findUsableUI("ExtendedPreview/map#{type}BoxRod")
      when /Cave/
        path = findUsableUI("ExtendedPreview/map#{type}BoxCave")
      when /Headbutt/
        path = findUsableUI("ExtendedPreview/map#{type}BoxHeadbutt")
      end
      bitmap = pbResolveBitmap(path)
      type2 = type == "Ext" ? "Main" : ""
      path = findUsableUI("ExtendedPreview/map#{type}Box#{type2}") if !bitmap
    end
    if !bitmap
      Console.echoln_li _INTL("There was no file named 'map#{type}Box#{encKey}' found.")
    end
    return path
  end

  def getEncIcons
    if SPECIAL_UI
      @sprites["previewExtTextBoxes"].bitmap.clear
    end
    @sprites["extendedText"].bitmap.clear
    @boxWidth = @boxHeight = 76
    @spaceX = @spaceY = 2
    # Calculate the max boxes in a row
    screenWidth = @extWidth # default = 480
    @rowLength = (screenWidth / (@boxWidth + @spaceX)).floor# using .floor to prevent boxes being too close to the edge without spacing.
    textSpace = @lineHeight * 4 # making sure there's enough space for 4 lines of text.
    screenHeight = @extendedBox.isSubTwo ? @extHeight / 2 : @extHeight
    # Calculate the rows and colums needed for the boxes to draw.
    mapID = @getData.keys[@dataIndex]
    @list = @tableData.values[@tableIndex].map { |key, value| key }
    seen = []
    unseen = []
    @list.each do |species|
      form = !GameData::Species.get(species).flags.empty? || GameData::Species.get(species).form > 0 ? GameData::Species.get(species).form : nil
      if seenFormAnyGender(mapID, species, form, @revealAllSeen) || caughtFormAnyGender(mapID, species, form)
        seen << species
      else
        unseen << species
      end
    end
    seen = seen.sort_by { |species| getSpeciesDexNumber(species, @region) }
    unseen = unseen.sort_by { |species| getSpeciesDexNumber(species, @region) }
    @list = seen + unseen
    @rowList = []
    @list.each_slice(@rowLength) { |array| @rowList << array }
    @countSpecies = updateSpeciesCount
    @typeProgress = !ARMSettings::DISABLE_EXTENDED_PREVIEW_PERCENTAGE ? "- #{convertIntegerOrFloat(((@countSpecies.to_f / (@list.length * 3)) * 100).round(1))}%" : ""
    @totalPages = @rowList.length - 1
    @totalPages = 1 if @totalPages <= 0 # making the minimum 1
    @sprites["EncounterBoxes"].bitmap.clear if @sprites["EncounterBoxes"]
    @encSprites = []
    @colLength = [((@list.length).to_f / @rowLength).ceil, screenHeight / (@boxHeight + @spaceY).floor].min
    maxHeight = (@colLength * (@boxHeight + @spaceY)) - @spaceY
    @startY = UI_BORDER_HEIGHT + ((screenHeight - maxHeight) / 2)
    @activeIndex = @list.map.with_index do |species, index|
      speciesData = GameData::Species.get(species)
      form = !speciesData.flags.empty? ? speciesData.form : nil
      seenFormAnyGender(mapID, species, form) || caughtFormAnyGender(mapID, species, form) ? index : nil
    end.compact
    index = @rowLength * @pageIndex
    @rowList[@pageIndex..(@pageIndex + (@colLength - 1))].each_with_index do |rows, j|
      maxWidth = (rows.length * (@boxWidth + @spaceX)) - @spaceX
      @startX = UI_BORDER_WIDTH + (screenWidth - maxWidth) / 2
      rows.each_with_index do |species, i|
        speciesData = GameData::Species.get(species)
        form = !speciesData.flags.empty? || speciesData.form > 0 ? speciesData.form : nil
        @encSprites[index] = PokemonSpeciesIconSprite.new(nil, @viewport)
        formChange = MultipleForms.hasFunction?(species, "getFormOnCreation")
        if formChange
          data = $ArckyGlobal.lastSeenSpeciesForm[speciesData.species]
        else
          date = $ArckyGlobal.lastSeenSpeciesForm&.dig(speciesData.species, speciesData.form)
        end
        if !data.nil?
          speciesGender = data[0]
          speciesShiny = data[1]
          speciesForm = formChange ? data[2] : speciesData.form
        else
          speciesForm = speciesData.form
        end
        if !seenFormAnyGender(mapID, species, form) && !caughtFormAnyGender(mapID, species, form) && !ARMSettings::USE_SPRITES_FOR_UNSEEN_SPECIES
          @encSprites[index].species = nil
        else
          @encSprites[index].species = species
          @encSprites[index].gender = speciesGender
          @encSprites[index].form = speciesForm
          @encSprites[index].shiny = speciesShiny
          @encSprites[index].tone = ARMSettings::UNCAUGHT_SPECIES_TONE if !caughtFormAnyGender(mapID, species, form)
          @encSprites[index].color = ARMSettings::UNSEEN_SPECIES_COLOR if !seenFormAnyGender(mapID, species, form) && !caughtFormAnyGender(mapID, species, form) && ARMSettings::USE_SPRITES_FOR_UNSEEN_SPECIES
        end
        x = @startX + ((@boxWidth + @spaceX) * i)
        y = @startY + ((@boxHeight + @spaceY) * j)
        @encSprites[index].x = x + 6
        @encSprites[index].y = y + 6
        @encSprites[index].z = 48
        @encSprites[index].visible = true
        drawIconBoxes(x, y)
        index += 1
      end
    end
  end

  def drawIconBoxes(x, y)
    if !@sprites["EncounterBoxes"]
      @sprites["EncounterBoxes"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      @sprites["EncounterBoxes"].z = 42
    end
    pbDrawImagePositions(@sprites["EncounterBoxes"].bitmap, [[(changeExtBoxMainAndEncBox("Enc")), x, y]])
    @sprites["EncounterBoxes"].visible = true
  end

  def updateSpeciesCount(revealAllSeen = nil)
    counter = 0
    mapID = @getData.keys[@dataIndex]
    @list.each do |species|
      count = 0
      speciesData = GameData::Species.get(species)
      form = !speciesData.flags.empty? || speciesData.form > 0 ? speciesData.form : nil
      count += 1 if seenFormAnyGender(mapID, species, form, revealAllSeen)
      count += 1 if caughtFormAnyGender(mapID, species, form)
      count += 1 if defeatedFormAnyGender(mapID, species, form)
      counter += 1 if count != 0
    end
    return counter
  end

  def seenFormAnyGender(mapID, species, form, revealAllSeen = nil)
    revealAllSeen = @revealAllSeen if revealAllSeen.nil?
    seen = false
    if revealAllSeen
      if $ArckyGlobal.countSeenSpecies(species, 0, form) > 0 || $ArckyGlobal.countSeenSpecies(species, 1, form) > 0
        seen = true
      end
    else
      if $ArckyGlobal.countSeenSpeciesMap(mapID, species, 0, form) > 0 || $ArckyGlobal.countSeenSpeciesMap(mapID, species, 1, form) > 0
        seen = true
      end
    end
    return seen
  end

  def caughtFormAnyGender(mapID, species, form)
    caught = false
    if $ArckyGlobal.countCaughtSpecies(species, 0, form) > 0 || $ArckyGlobal.countCaughtSpecies(species, 1, form) > 0
      caught = true
    end
    return caught
  end

  def defeatedFormAnyGender(mapID, species, form)
    defeated = false
    if $ArckyGlobal.countDefeatedSpeciesMap(mapID, species, 0, form) > 0 || $ArckyGlobal.countDefeatedSpeciesMap(mapID, species, 1, form) > 0
      defeated = true
    end
    return defeated
  end

  def getEncCursor
    if !@sprites["EncCursor"]
      @sprites["EncCursor"] = IconSprite.new(0, 0, @viewport)
      @sprites["EncCursor"].setBitmap(findUsableUI("ExtendedPreview/mapEncCursor"))
      @sprites["EncCursor"].z = 50
    end
    @sprites["EncCursor"].visible = false
    updateEncCursor(@lastIndex)
    extendedEnc
  end

  def updateEncCursor(index)
    index = @activeIndex.first if index.nil?
    @sprites["EncCursor"].x = @encSprites[index].x - 7
    @sprites["EncCursor"].y = @encSprites[index].y - 7
  end

  def updateSpeciesInfo(index = 0, pageInfo = 0)
    @sprites["extendedText"].bitmap.clear
    @base = ARMSettings::EXTENDED_TEXT_SUB_BASE
    @shadow = ARMSettings::EXTENDED_TEXT_SUB_SHADOW
    if !@sprites["TextRaster"]
      @sprites["TextRaster"] = IconSprite.new(0, 0, @viewport)
      @sprites["TextRaster"].setBitmap(findUsableUI("ExtendedPreview/mapTextRaster"))
      @sprites["TextRaster"].z = 50
    end
    if SPECIAL_UI
      @sprites["previewExtTextBoxes"].bitmap.clear
      graphic = findUsableUI("ExtendedPreview/mapTextBoxOne")
      bitmap = Bitmap.new(graphic)
      @boxWidth = bitmap.width
      @boxHeight = bitmap.height
      @boxX = ((@extWidth - @boxWidth) / 2)
      @boxY = @extHeight - (4 + @boxHeight)
      image = [[graphic, @boxX, @boxY]]
      pbDrawImagePositions(@sprites["previewExtTextBoxes"].bitmap, image)
      @sprites["previewExtTextBoxes"].visible = true
      @rasterX = @boxX + ((@boxWidth - @sprites["TextRaster"].bitmap.width) / 2)
      @rasterY = @boxY + ((@boxHeight - @sprites["TextRaster"].bitmap.height) / 2)
    else
      @rasterX = ((@extWidth - @sprites["TextRaster"].bitmap.width) / 2)
      @rasterY = (@extHeight / 2) + (((@extHeight / 2) - @sprites["TextRaster"].bitmap.height) / 2)
    end
    unless @encSprites[index].species.nil?
      @sprites["TextRaster"].x = @rasterX + UI_BORDER_WIDTH
      @sprites["TextRaster"].y = @rasterY + UI_BORDER_HEIGHT
      @sprites["TextRaster"].src_rect.width = @sprites["TextRaster"].bitmap.width
      @sprites["TextRaster"].src_rect.height = @sprites["TextRaster"].bitmap.height
      @sprites["TextRaster"].src_rect.x = 0
      species = @list[index]
      speciesData = GameData::Species.get(species)
      mapID = @getData.keys[@dataIndex]
      formName = speciesData.real_form_name
      @sprites["mapbottom"].mapname = formName.nil? || speciesData.form == 0 ? "#{speciesData.real_name}" : formName.include?(speciesData.real_name) ? formName : "#{formName} #{speciesData.real_name}"
      case pageInfo
      when 0
        text = getSpeciesInfoPageOne(species)
        @sprites["TextRaster"].visible = false
      when 1
        text = getSpeciesInfoPageTwo(species, speciesData, mapID)
        @sprites["TextRaster"].visible = true
      end
    else
      @sprites["TextRaster"].visible = false
      @sprites["mapbottom"].mapname = "#{@data[:name]} #{@typeProgress}"
      if SPECIAL_UI
        x = @boxWidth / 2
        y = (@boxY + (@boxHeight / 2)) - (@fontSize / 2)
      else
        x = @extWidth / 2
        y = ((@extHeight / 2) + ((@lineHeight * 4) / 2))
      end
      text = [["No Data", x, y, :center, @base, @shadow]]
    end
    if SPECIAL_UI
      @sprites["TextRaster"].x = UI_BORDER_WIDTH + @boxX + ((@boxWidth - @sprites["TextRaster"].bitmap.width) / 2) + @sprites["TextRaster"].src_rect.x
      @sprites["TextRaster"].y = UI_BORDER_HEIGHT + @boxY + ((@boxHeight - @sprites["TextRaster"].bitmap.height) / 2)
    else
      @sprites["TextRaster"].x = UI_BORDER_WIDTH + ((@extWidth - @sprites["TextRaster"].bitmap.width) / 2) + @sprites["TextRaster"].src_rect.x
      @sprites["TextRaster"].y = UI_BORDER_HEIGHT + (@extHeight / 2) + (((@extHeight / 2) - @sprites["TextRaster"].bitmap.height) / 2)
    end
    pbDrawTextPositions(@sprites["extendedText"].bitmap, text) if text
  end

  def getSpeciesInfoPageOne(species)
    text = []
    offsetX = ARMSettings::EXTENDED_TEXT_SUB_X
    offsetY = ARMSettings::EXTENDED_TEXT_SUB_Y
    entryData = @tableData.values[@tableIndex][species]
    if SPECIAL_UI
      x = @boxX + 6 + offsetX
      y = @boxY + ((@boxHeight - ((@lineHeight * 4) - (@lineHeight - @fontSize))) / 2) + offsetY
    else
      x = 16 + offsetX
      y = (@extHeight / 2) + 12 + offsetY
    end
    text << ["Type: #{entryData[:type]}", x, y, :left, @base, @shadow]
    x += 264 + offsetX
    text << ["Catch Rate: #{entryData[:catchRate]}", x, y, :left, @base, @shadow]
    x -= 264 + offsetX
    y += @lineHeight
    text << ["Encounter Rate:", x, y, :left, @base, @shadow]
    array = []
    widths = []
    extra = @sprites["extendedText"].bitmap.text_size(' - ').width
    entryData[:entries].each do |data|
      levelRange = data[:level][:min] == data[:level][:max] ? "#{data[:level][:min]}" : "#{data[:level][:min]} - #{data[:level][:max]}"
      txt = "#{convertIntegerOrFloat(data[:chance])}% (lv. #{levelRange})"
      array << txt
      widths << @sprites["extendedText"].bitmap.text_size(txt).width
    end
    if SPECIAL_UI
      array = textToLines(widths, array, extra, (@boxWidth - 12))
    else
      array = textToLines(widths, array, extra, @extWidth - 32)
    end
    y += @lineHeight + offsetY
    output = []
    array.each do |txt|
      if txt.include?("\n")
        output = []
        y += @lineHeight + offsetY
        if SPECIAL_UI
          break if y + @fontSize > @boxY + @boxHeight
        else
          break if y + @fontSize > @extHeight
        end
      end
      output << txt
      output.map!(&:strip)
      output2 = output.join(' - ')
      text << [output2, x, y, :left, @base, @shadow]
    end
    return text
  end

  def getSpeciesInfoPageTwo(species, speciesData, mapID)
    text = []
    form = !speciesData.flags.empty? ? speciesData.form : nil

    # Get all Seen Counters.
    seen = $ArckyGlobal.countSeenSpeciesMap(mapID, species, nil, form)
    totalSeen = $ArckyGlobal.countSeenSpecies(species, nil, form)
    formsSeen = form.nil? && !speciesData.form_name.nil? ? $ArckyGlobal.countSeenSpeciesForms(species, nil, form) : ""

    # Get all Caught Counters.
    caught = $ArckyGlobal.countCaughtSpeciesMap(mapID, species, nil, form)
    totalCaught = $ArckyGlobal.countCaughtSpecies(species, nil, form)
    formsCaught = form.nil? && !speciesData.form_name.nil? ? $ArckyGlobal.countCaughtSpeciesForms(species, nil, form) : ""

    # Get all Defeated Counters.
    defeated = $ArckyGlobal.countDefeatedSpeciesMap(mapID, species, nil, form)
    totalDefeated = $ArckyGlobal.countDefeatedSpecies(species, nil, form)
    formsDefeated = form.nil? && !speciesData.form_name.nil? ? $ArckyGlobal.countDefeatedSpeciesForms(species, nil, form) : ""

    # Draw text "Forms".
    y = @rasterY + 2
    if formsSeen.is_a?(Numeric)
      x = @rasterX + 350
      text << ["Forms", x, y, :center, @base, @shadow]
    else
      @sprites["TextRaster"].src_rect.width = 299 # Crop Raster if no Forms.
    end

    # Draw text "Globally".
    if totalSeen != seen || (formsSeen.is_a?(Numeric) && formsSeen != 0)
      x = @rasterX + 250
      text << ["Globally", x, y, :center, @base, @shadow]
    else
      @sprites["TextRaster"].src_rect.width = 199 # Crop Raster if totalSeen == seen.
    end

    # Draw Text "This Area"
    x = @rasterX + 150
    text << ["This Area", x, y, :center, @base, @shadow]

    x = @rasterX + 95
    y = totalCaught != 0 ? @rasterY + 108 : @rasterY + 72
    text << ["Defeated", x, y, :right, @base, @shadow] if totalDefeated != 0

    x = @rasterX + 350
    text << [formsDefeated.to_s, x, y, :center, @base, @shadow] if totalDefeated != 0 && formsDefeated.is_a?(Numeric)

    x = @rasterX + 250
    text << [totalDefeated.to_s, x, y, :center, @base, @shadow] if (totalDefeated != defeated || (totalCaught != caught || totalSeen != seen))  || (formsDefeated.is_a?(Numeric) && formsDefeated != 0)

    x = @rasterX + 150
    text << [defeated.to_s, x, y, :center, @base, @shadow] if defeated != 0 || totalDefeated != 0


    x = @rasterX + 95
    y = @rasterY + 72
    text << ["Caught", x, y, :right, @base, @shadow] if totalCaught != 0

    x = @rasterX + 350
    text << [formsCaught.to_s, x, y, :center, @base, @shadow] if totalCaught != 0 && formsCaught.is_a?(Numeric)

    x = @rasterX + 250
    text << [totalSeen.to_s, x, y, :center, @base, @shadow] if totalCaught != caught || (formsCaught.is_a?(Numeric) && formsCaught != 0)

    x = @rasterX + 150
    text << [caught.to_s, x, y, :center, @base, @shadow] if caught != 0 || totalCaught != 0


    x = @rasterX + 95
    y = @rasterY + 36
    text << ["Seen", x, y, :right, @base, @shadow]

    x = @rasterX + 350
    text << [formsSeen.to_s, x, y, :center, @base, @shadow] if totalSeen != 0 && formsSeen.is_a?(Numeric)

    x = @rasterX + 250
    text << [totalSeen.to_s, x, y, :center, @base, @shadow] if totalSeen != seen || (formsSeen.is_a?(Numeric) && formsSeen != 0)

    x = @rasterX + 150
    text << [seen.to_s, x, y, :center, @base, @shadow]

    if totalCaught == 0 && totalDefeated == 0
      @sprites["TextRaster"].src_rect.height = 62
      @sprites["TextRaster"].src_rect.x = 40
      @sprites["TextRaster"].src_rect.width -= 40
    elsif totalCaught != 0 || (totalCaught == 0 && totalDefeated != 0)
      if totalDefeated == 0
        @sprites["TextRaster"].src_rect.x = 20
        @sprites["TextRaster"].src_rect.width -= 20
      end
      @sprites["TextRaster"].src_rect.height = 98 if totalCaught == 0 || totalDefeated == 0
    end

    return text
  end

  def extendedEnc
    index = @lastIndex || @activeIndex.first
    pageInfo = 0
    disposeSprites
    drawEncTable
    updateEncCursor(index)
    @sprites["EncCursor"].visible = true
    loop do
      Graphics.update
      Input.update
      pbUpdate
      @timer += 1 if @timer
      minPageInd = @pageIndex != 0 ? @rowList[0..@pageIndex - 1].map { |row| row.length }.sum : 0
      maxPageInd = @rowList[0..(@pageIndex + (@colLength - 1))].map { |row| row.length }.sum - 1
      updateButtonInfo if !ARMSettings::BUTTON_BOX_POSITION.nil?
      updateSprites
      if Input.trigger?(Input::BACK)
        @lastIndex = nil
        @sprites["EncCursor"].visible = false
        @sprites["mapbottom"].mapname = "#{@data[:name]} #{@typeProgress}"
        @sprites["mapbottom"].maplocation = "Page #{@tableIndex + 1}/#{@tableData.length}"
        @sprites["TextRaster"].visible = false if @sprites["TextRaster"]
        @extendedBox.subOne
        @pageIndex = 0
        disposeSprites
        drawEncTable
        break
      elsif Input.trigger?(Input::RIGHT)
        index += 1
        if index > maxPageInd
          if maxPageInd < @list.length - 1
            @pageIndex += 1
          else
            @pageIndex = 0
            index = 0
          end
        end
        disposeSprites
        getEncIcons
      elsif Input.trigger?(Input::LEFT)
        index -= 1
        if index < minPageInd
          if minPageInd > 0
            @pageIndex -= 1
          else
            @pageIndex = @totalPages - 1
            index = @list.length - 1
          end
        end
        disposeSprites
        getEncIcons
      elsif Input.trigger?(Input::UP)
        if index - @rowLength >= 0
          index -= @rowLength
          if index < minPageInd
            @pageIndex -= 1
          end
        else
          index += @rowLength * @totalPages
          if index > @list.length - 1
            index = @list.length - 1
          end
          @pageIndex = @totalPages - 1
        end
        disposeSprites
        getEncIcons
      elsif Input.trigger?(Input::DOWN)
        if index + @rowLength <= @list.length - 1
          index += @rowLength
          if index > maxPageInd
            @pageIndex += 1
          end
        else
          index -= @rowLength * @totalPages
          if index < 0
            index = @list.length - 1
            @pageIndex = @totalPages - 1
          else
            @pageIndex = 0
          end
        end
        disposeSprites
        getEncIcons
      elsif Input.trigger?(Input::JUMPUP) && !@activeIndex.empty?
        index = @activeIndex.reverse.find { |value| value < index }
        index ||= @activeIndex.last
        if index < minPageInd
          if minPageInd > 0
            if @pageIndex > 0
              @pageIndex = (index / @rowLength)
              @pageIndex = 0 if @pageIndex < 0
            else
              @pageIndex = @totalPages
            end
          end
        elsif index > maxPageInd
          @pageIndex = (index / @rowLength) - 1
        end
        disposeSprites
        getEncIcons
      elsif Input.trigger?(Input::JUMPDOWN) && !@activeIndex.empty?
        index = @activeIndex.find { |value| value > index }
        index ||= @activeIndex.first
        if index > maxPageInd
          if maxPageInd < @list.length - 1
            if @pageIndex < @totalPages
              @pageIndex += 1
            else
              @pageIndex = 0
            end
          end
        elsif index < minPageInd
          @pageIndex = (index / @rowLength)
        end
        disposeSprites
        getEncIcons
      elsif Input.trigger?(ARMSettings::SELECT_SPECIES_BUTTON)
        pageInfo += 1
        if pageInfo > 1
          pageInfo = 0
        end
      end
      updateSpeciesInfo(index, pageInfo)
      updateEncCursor(index)
      @extIndex = index
      @sprites["mapbottom"].maplocation = "Species #{index + 1}/#{@list.length}"
    end
  end

  def updateSprites
    @encSprites.each { |s| s.update if !s.nil? }
    Graphics.update
  end

  def disposeSprites
    @encSprites.each { |s| s.dispose if !s.nil? }
  end

  def hideExtendedPreview
    @sprites["previewExtMain"].visible = false
    @sprites["modeName"].visible = true
    @sprites["extendedText"].visible = false
    @sprites["previewExtTextBoxes"].visible = false if @sprites["previewExtTextBoxes"]
    @previewBox.extHide
    updateArrows
  end
end

class ExtendedState
  def initialize
    @state = :main
  end

  def page
    @state
  end

  def main
    @state = :main
  end

  def subOne
    @state = :subOne
  end

  def subTwo
    @state = :subTwo
  end

  def isMain
    return @state == :main
  end

  def isSubOne
    return @state == :subOne
  end

  def isSubTwo
    return @state == :subTwo
  end
end
