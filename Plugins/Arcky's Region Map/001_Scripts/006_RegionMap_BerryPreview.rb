class PokemonRegionMap_Scene
  def addBerryIconSprites
    return if !BERRYPLUGIN || !allowShowingBerries
    if !@spritesMap["BerryIcons"]
      @berryIcons = {}
      regionID = -1
      if @region >= 0 && @playerPos && @region != @playerPos[0]
        regionID = @region
      elsif @playerPos
        regionID = @playerPos[0]
      end
      berryPlants = pbForceUpdateAllBerryPlants(mapOnly: true, region: regionID, returnArray: true)
      settings = Settings::BERRIES_ON_MAP_SHOW_PRIORITY
      berryPlants.each do |plant|
        img = 999
        settings.each_with_index { |set, i|
            if set == :ReadyToPick && plant.grown? then img = i
            elsif set == :HasPests && plant.pests then img = i
            elsif set == :NeedsWater && plant.moisture_stage == 0 then img = i
            elsif set == :HasWeeds && plant.weeds then img = i
            end
            break if img != 999
          }
          if @berryIcons[plant.town_map_location]
            @berryIcons[plant.town_map_location] = img if img < @berryIcons[plant.town_map_location]
          else
            @berryIcons[plant.town_map_location] = img
          end
      end
      @spritesMap["BerryIcons"] = BitmapSprite.new(@mapWidth, @mapHeight, @viewportMap)
      @spritesMap["BerryIcons"].x = @spritesMap["map"].x
      @spritesMap["BerryIcons"].y = @spritesMap["map"].y
      @spritesMap["BerryIcons"].z = 59
      @spritesMap["BerryIcons"].visible = @mode == 3
    end
    @berryIcons.each { |key, value|
      conversion = {:NeedsWater => "mapBerryDry", :ReadyToPick => "mapBerryReady",
              :HasPests => "mapBerryPest", :HasWeeds => "mapBerryWeeds"}[settings[value]] || "mapBerry"
      pbDrawImagePositions(@spritesMap["BerryIcons"].bitmap,
        [[pbGetBerryMapIcon(conversion), pointXtoScreenX(key[1]), pointYtoScreenY(key[2])]])
    }
  end

  def pbGetBerriesAtMapPoint(region, x = nil, y = nil)
    array = []
    $PokemonGlobal.eventvars.each do |info|
      plant = info[1]
      next if !plant.is_a?(BerryPlantData) || plant.town_map_location.nil? || !plant.planted? || plant.town_map_location[0] != region ||
              (!x.nil? && plant.town_map_location[1] != x) || (!y.nil? && plant.town_map_location[2] != y)
      array.push(plant)
    end
    return array
  end

  def getBerryName(x, y)
    berries = pbGetBerriesAtMapPoint(@region, x, y)
    value = ""
    unless berries.empty?
      count = berries.length
      if count >= 1
        @berryPlants = { }
        berryCounter = Hash.new { |h, k| h[k] = { amount: 0, stages: Hash.new { |h, k| h[k] = 0 } } }
        berries.each do |berry|
          berryCounter[berry.berry_id][:amount] += 1
          case berry.growth_stage
          when 1
            stage = "Planted"
          when 2
            stage = "Sprouted"
          when 3
            stage = "Grown"
          else
            stage = "Flowered"
          end
          berryCounter[berry.berry_id][:stages][stage] += 1
        end
        stageOrder = ["Planted", "Sprouted", "Grown", "Flowered"]
        @berryPlants = berryCounter.transform_values do |info|
          {
            amount: info[:amount],
            stages: info[:stages].sort_by { |s, _| stageOrder.index(s) }.to_h
          }
        end
        if @berryPlants.length >= 2
          value = "#{count} Berries planted"
        else
          value = getBerryNameAndAmount(berries[0].berry_id)
        end
      end
    end
    updateButtonInfo if !ARMSettings::BUTTON_BOX_POSITION.nil?
    @sprites["modeName"].bitmap.clear
    mapModeSwitchInfo if value == ""
    return value
  end

  def getBerryNameAndAmount(berry)
    amount = @berryPlants[berry][:amount]
    if ENGINE20
      if amount >= 2
        value = "#{amount} #{GameData::Item.get(berry).name_plural}"
      else
        value = "#{amount} #{GameData::Item.get(berry).name}"
      end
    elsif ENGINE21
      if amount >= 2
        value = "#{amount} #{GameData::Item.get(berry).portion_name_plural}"
      else
        value = "#{amount} #{GameData::Item.get(berry).portion_name}"
      end
    end
    return value
  end

  def showBerryInformation(lastChoiceBerries)
    return choice = -1 if @berryPlants.nil?
    input, berry, choice = getCurrentBerryInfo(lastChoiceBerries)
    if input && berry
      berryInfoText = []
      name = getBerryNameAndAmount(berry)
      @sprites["mapbottom"].previewName = ["#{name}", @sprites["previewBox"].width]
      if !@sprites["locationText"]
        @sprites["locationText"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        pbSetSystemFont(@sprites["locationText"].bitmap)
        @sprites["locationText"].visible = false
      end
      @sprites["locationText"].bitmap.clear
      if ENGINE20
        base = colorToRgb16(ARMSettings::BERRY_INFO_MAIN)
        shadow = colorToRgb16(ARMSettings::BERRY_INFO_SHADOW)
      elsif ENGINE21
        base = (ARMSettings::BERRY_INFO_MAIN).to_rgb15
        shadow = (ARMSettings::BERRY_INFO_SHADOW).to_rgb15
      end
      selBerry = @berryPlants[berry]
      amount = selBerry[:amount]
      selBerry[:stages].each do |stage,value|
        text = "<c2=#{base}#{shadow}>#{stage}: #{value}"
        berryInfoText << text
      end
      x = 16
      y = 8
      lineHeight = ARMSettings::PREVIEW_LINE_HEIGHT
      berryInfoText.each do |text|
        chars = getFormattedText(@sprites["locationText"].bitmap, x, y, 272, -1, text, lineHeight)
        y += (1 + chars.count { |item| item[0] == "\n" }) * lineHeight
        drawFormattedChars(@sprites["locationText"].bitmap, chars)
        @lineCount = (y / lineHeight)
      end
      @lineCount = ARMSettings::MAX_BERRY_LINES if @lineCount > ARMSettings::MAX_BERRY_LINES
      getPreviewBox
      @sprites["locationText"].x = Graphics.width - (@sprites["previewBox"].width + UI_BORDER_WIDTH + ARMSettings::BERRY_INFO_OFFSET_X)
      @sprites["locationText"].y = UI_BORDER_HEIGHT + ARMSettings::BERRY_INFO_OFFSET_Y
      @sprites["locationText"].z = 28
    end
    return choice
  end

  def getCurrentBerryInfo(lastchoiceBerries)
    if @berryPlants.length >= 2
      choice = messageMap(_INTL("Which berry would you like to view info about?"),
      @berryPlants.keys.map { |berry|
        next "#{pbGetMessageFromHash(SCRIPTTEXTS, getBerryNameAndAmount(berry))}"
      }, -1, nil, lastchoiceBerries) { pbUpdate }
      input = choice != -1
      berry = @berryPlants.keys[choice]
    else
      input = 0
      berry = @berryPlants.keys[0]
    end
    return input, berry, choice
  end

  def checkBerriesOnPosition(multiple = false)
    unless multiple
      return !pbGetBerriesAtMapPoint(@region, @mapX, @mapY).empty? && pbGetBerriesAtMapPoint(@region, @mapX, @mapY).length == 1
    else
      return !pbGetBerriesAtMapPoint(@region, @mapX, @mapY).empty? && pbGetBerriesAtMapPoint(@region, @mapX, @mapY).length > 1
    end
  end
end
