class PokemonRegionMap_Scene
  def getLocationInfo

    # Generate Sprites if they don't exist
    if !@sprites["locationText"]
      @sprites["locationText"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      pbSetSystemFont(@sprites["locationText"].bitmap)
      @sprites["locationText"].visible = false
    end
    if !@sprites["locationIcon"]
      @sprites["locationIcon"] = IconSprite.new(0, 0, @viewport)
      @sprites["locationIcon"].z = 32
      @sprites["locationIcon"].visible = false
    end
    if !@sprites["locationDash"]
      @sprites["locationDash"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      @sprites["locationDash"].z = 33
      @sprites["locationDash"].visible = false
    end
    # Reset the line count to the default value.
    @lineCount = 1
    # update the Current Location Name
    name = @curLocName = pbGetMapLocation(@mapX, @mapY)

    # assign the sprites and clear their content.
    spriteBox = @sprites["previewBox"]

    spriteText = @sprites["locationText"]
    spriteText.bitmap.clear

    spriteIcon = @sprites["locationIcon"]

    spriteDash = @sprites["locationDash"]
    spriteDash.bitmap.clear

    # Get the default width for text.
    locDescrWidth = spriteBox.width - 20

    # by default the Alternative Preview Box is used.
    @useAlt = "Alt"
    mapInfo = @mapInfo[@curMapLoc.gsub(" ", "").to_sym] unless @curMapLoc.nil?
    if !mapInfo.nil? && mapInfo[:mapname] == pbGetMessageFromHash(LOCATIONNAMES, mapInfo[:realname]) && ARMSettings::CAN_VIEW_INFO_UNVISITED_MAPS
      name = mapInfo[:realname].gsub(" ", "").gsub("'", "")
      locDescr = _INTL("No information given.")
      locDescr = pbGetMessageFromHash(SCRIPTTEXTS, locDescr)
      @cannotExtPreview = true
      if ARMLocationPreview.const_defined?(name)
        @locObject = ARMLocationPreview.const_get(name)
        key = "#{:description}_#{@mapX.round}_#{@mapY.round}".to_sym
        key = :description unless @locObject.key?(key)
        unless @locObject[key].nil?
          locDescr = pbGetMessageFromHash(SCRIPTTEXTS, @locObject[key])
          @cannotExtPreview = false if ARMSettings::USE_EXTENDED_PREVIEW && [ARMSettings::PROGRESS_COUNT_ITEMS, ARMSettings::PROGRESS_COUNT_POKEMON, ARMSettings::PROGRESS_COUNT_TRAINERS].any? { |value| value }
        end
        if @locObject[:icon]
          spriteIcon.setBitmap(findUsableUI("LocationPreview/MiniMaps/map#{@locObject[:icon]}"))
          spriteIcon.x = (spriteBox.x + (spriteBox.width - (20 + spriteIcon.width))) + ARMSettings::ICON_OFFSET_X
          locDescrWidth = spriteIcon.x - (spriteBox.x + 20)
          @locationIcon = true
        end
        getDir = []
        dirWidths = []
        directions = [:north, :northEast, :east, :southEast, :south, :southWest, :west, :northWest]
        locDirWidth = spriteBox.width - 20
        directions.each do |dir|
          key = "#{dir}_#{@mapX}_#{@mapY}".to_sym
          key = dir unless @locObject.key?(key)
          loc = @locObject[key]
          name = ""
          if loc.is_a?(Array) && !loc.nil?
            value = @mapInfo.find { |_, location| location[:positions].any? { |pos| pos[:x] == loc[0] && pos[:y] == loc[1] } }
            if value
              name = pbGetMessageFromHash(SCRIPTTEXTS, value[1][:mapname])
            else
              name = pbGetMessageFromHash(SCRIPTTEXTS, _INTL("Invalid Location"))
            end
          else
            name = loc
          end
          if @locObject.key?(key) && name != ""
            name += ' ' * ARMSettings::LOCATION_DIRECTION_SPACES
            dirWidths << (getBitmapWidth("Graphics/Icons/#{dir.to_s}") + spriteText.bitmap.text_size(name.to_s).width)
            getDir << "<icon=#{dir.to_s}>#{name}"
          end
        end
        currSum = 0
        newLines = []
        dirWidths.each_with_index do |width, index|
          currSum += width
          if currSum > locDirWidth
            newLines << index
            currSum = width
          end
        end
        newLines.each do |index|
          getDir[index] = "\n#{getDir[index]}"
        end
        locDir = "#{getDir.join('')}"
      end
    else
      if ARMSettings::CAN_VIEW_INFO_UNVISITED_MAPS && (name == "???" || !ARMSettings::NO_UNVISITED_MAP_INFO)
        locDescr = pbGetMessageFromHash(SCRIPTTEXTS, ARMSettings::UNVISITED_MAP_INFO_TEXT)
        @cannotExtPreview = true
      else
        return false
      end
    end
    @lineCount -= 1 if locDescr.nil? || locDescr == ""
    if @lineCount != 0
      xDescr = 8 + ARMSettings::DESCRIPTION_TEXT_OFFSET_X
      yDescr = 8 + ARMSettings::DESCRIPTION_TEXT_OFFSET_Y
      maxHeight = ARMSettings::MAX_DESCRIPTION_LINES * ARMSettings::PREVIEW_LINE_HEIGHT
      if ENGINE20
        base = colorToRgb16(ARMSettings::DESCRIPTION_TEXT_MAIN)
        shadow = colorToRgb16(ARMSettings::DESCRIPTION_TEXT_SHADOW)
      elsif ENGINE21
        base = (ARMSettings::DESCRIPTION_TEXT_MAIN).to_rgb15
        shadow = (ARMSettings::DESCRIPTION_TEXT_SHADOW).to_rgb15
      end
      text = "<c2=#{base}#{shadow}>#{locDescr}"
      spriteText.bitmap.clear
      spriteDash.visible == false if spriteDash
      chars = drawText(spriteText.bitmap, xDescr, yDescr, locDescrWidth, maxHeight, text)
      @lineCount = 1 + (chars.count { |item| item[0] == "\n"})
      @lineCount = ARMSettings::MAX_DESCRIPTION_LINES if @lineCount > ARMSettings::MAX_DESCRIPTION_LINES
      descrHeight = @lineCount * ARMSettings::PREVIEW_LINE_HEIGHT
      descrOffset = 0
      @totalHeight = descrHeight
      if @locationIcon
        iconHeight = spriteIcon.height
        @iconOffset = 4

        # Adjust Description Lines to Icon Height
        @lineCount += (iconHeight - descrHeight) / ARMSettings::PREVIEW_LINE_HEIGHT if iconHeight > descrHeight && @lineCount <= ARMSettings::MAX_DESCRIPTION_LINES

        # Center Text in height
        if descrHeight < iconHeight && ARMSettings::CENTER_DESCRIPTION_TEXT
          descrOffset = (@lineCount * ARMSettings::PREVIEW_LINE_HEIGHT - descrHeight) / 2
          spriteText.bitmap.clear
          chars = drawText(spriteText.bitmap, xDescr, (yDescr + descrOffset), locDescrWidth, maxHeight, text)
        end

        # Center Icon in height
        if iconHeight < @lineCount * ARMSettings::PREVIEW_LINE_HEIGHT && ARMSettings::CENTER_ICON
          @iconOffset += ((@lineCount * ARMSettings::PREVIEW_LINE_HEIGHT) - iconHeight) / 2
        end
        @totalHeight = iconHeight if iconHeight >= descrHeight
      end
      if locDir && !locDir.empty?
        if ARMSettings::DRAW_DASH_IMAGES
          @useAlt = "" if ARMSettings::DIRECTION_HEIGHT_SPACING != 0
          dashImage = findUsableUI("LocationPreview/mapLocDash")
          dashWidth = getBitmapWidth("#{dashImage}")
          dashHeight = getBitmapHeight("#{dashImage}")
          xDash = 12 + ARMSettings::DASH_OFFSET_X
          yDash = (((yDescr + @totalHeight) - (dashHeight / 2))) + 2 + ARMSettings::DASH_OFFSET_Y
          @totalHeight += ARMSettings::DIRECTION_HEIGHT_SPACING
          spriteDash.bitmap.clear
          @locationDash = true
          if dashHeight <= ARMSettings::DIRECTION_HEIGHT_SPACING
            while xDash <= locDirWidth do
              pbDrawImagePositions(spriteDash.bitmap, [[findUsableUI("LocationPreview/mapLocDash"), xDash, yDash]])
              xDash += dashWidth + (dashWidth / 2)
            end
          end
        end
        xDir = 8 + ARMSettings::DIRECTION_TEXT_OFFSET_X
        yDir = yDescr + @totalHeight + ARMSettings::DIRECTION_TEXT_OFFSET_Y
        maxHeight = ARMSettings::MAX_DIRECTION_LINES * ARMSettings::PREVIEW_LINE_HEIGHT
        if ENGINE20
          base = colorToRgb16(ARMSettings::DIRECTION_TEXT_MAIN)
          shadow = colorToRgb16(ARMSettings::DIRECTION_TEXT_SHADOW)
        elsif ENGINE21
          base = (ARMSettings::DIRECTION_TEXT_MAIN).to_rgb15
          shadow = (ARMSettings::DIRECTION_TEXT_SHADOW).to_rgb15
        end
        text = "<c2=#{base}#{shadow}>#{locDir}"
        chars = drawText(spriteText.bitmap, xDir, yDir, locDirWidth, maxHeight, text)
        count = 1 + (chars.count { |item| item[0] == "\n"})
        count = ARMSettings::MAX_DIRECTION_LINES if count > ARMSettings::MAX_DIRECTION_LINES
        @totalHeight += count * ARMSettings::PREVIEW_LINE_HEIGHT
        @lineCount += count
      end
      getPreviewBox
      @sprites["locationText"].x = @sprites["previewBox"].x
      @sprites["locationText"].y = Graphics.height - (@totalHeight + UI_BORDER_HEIGHT)
      if @locationDash
        @sprites["locationDash"].x = @sprites["locationText"].x
        @sprites["locationDash"].y = @sprites["locationText"].y
      end
      if @locationIcon
        @sprites["locationIcon"].y = @sprites["locationText"].y + @iconOffset + ARMSettings::ICON_OFFSET_Y
      end
      @sprites["locationText"].z = 28
    end
  end

  def drawText(bitmapText, x, y, locDescrWidth, maxHeight, text)
    chars = getFormattedText(bitmapText, x, y, locDescrWidth, maxHeight, text)
    drawFormattedChars(@sprites["locationText"].bitmap, chars)
    return chars
  end
end
