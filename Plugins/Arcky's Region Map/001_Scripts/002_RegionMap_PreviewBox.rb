class PokemonRegionMap_Scene
  def getPreviewName(x, y)
    return getQuestName(x, y) if @mode == 2
    return getBerryName(x, y) if @mode == 3
    return getRoamingName(x, y) if @mode == 4
  end

  def getPreviewBox
    if !@sprites["previewBox"]
      @sprites["previewBox"] = IconSprite.new(0, 0, @viewport)
      @sprites["previewBox"].z = 26
      @sprites["previewBox"].visible = false
    end
    return if @mode == 1 || @mode == 4
    if @mode == 0
      preview = "LocationPreview/mapLocBox#{@useAlt}"
      @sprites["previewBox"].x = 16
    else
      @lineCount = 2 if @lineCount == 1
      preview = "QuestPreview/mapQuestBox" if @mode == 2
      preview = "BerryPreview/mapBerryBox" if @mode == 3
      @sprites["previewBox"].x = Graphics.width - (16 + @sprites["previewBox"].width)
    end
    @sprites["previewBox"].setBitmap(findUsableUI("#{preview}#{@lineCount}"))
    @previewWidth = @sprites["previewBox"].width if @mode == 2 || @mode == 3
  end

  def showPreviewBox
    return if @lineCount == 0
    if @mode == 0
      @sprites["previewBox"].y = Graphics.height - 32
    elsif @mode == 2
      @sprites["previewBox"].y = 32 - @sprites["previewBox"].height
    end
    @sprites["previewBox"].visible = true
    height = @sprites["previewBox"].height
    if @mode == 0
      @sprites["previewBox"].y = (Graphics.height - 32) - height
    elsif @mode == 2 || @mode == 3
      @sprites["previewBox"].y = (32 - @sprites["previewBox"].height) + height
    end
    changePreviewBoxAndArrow(height)
    if @mode == 0
      @sprites["locationDash"].visible = true if @locationDash
      @sprites["locationIcon"].visible = true if @locationIcon
    end
    @sprites["locationText"].visible = true
    @previewBox.shown
    getPreviewWeather
    updateButtonInfo if !ARMSettings::BUTTON_BOX_POSITION.nil?
    @previewMode = @mode
  end

  def changePreviewBoxAndArrow(height)
    previewWidthBiggerButtonX = @sprites["previewBox"].width > @sprites["buttonPreview"].x
    halfScreenWidth = Graphics.width / 2
    previewWidthHalfScreenSize = @sprites["previewBox"].width > halfScreenWidth
    previewWidthDownArrowX = @sprites["previewBox"].width > @sprites["downArrow"].x
    previewXUpArrowX = @sprites["previewBox"].x < @sprites["upArrow"].x
    buttonXDownArrowX = @sprites["buttonPreview"].x > @sprites["downArrow"].x
    buttonWidthDownArrowX = @sprites["buttonPreview"].width > (@sprites["downArrow"].x + 14)
    buttonXHalfScreenSize = @sprites["buttonPreview"].x < halfScreenWidth
    if @mode == 0
      @sprites["downArrow"].y = (Graphics.height - 60) - height if previewWidthDownArrowX
      if BOX_BOTTOM_LEFT
        @sprites["buttonPreview"].y = (Graphics.height - (22 + @sprites["buttonPreview"].height)) - height
        @sprites["buttonName"].y = -height
        if previewWidthHalfScreenSize && previewWidthDownArrowX && buttonWidthDownArrowX
          @sprites["downArrow"].y = (Graphics.height - (44 + @sprites["buttonPreview"].height)) - height
        end
      elsif BOX_BOTTOM_RIGHT
        if previewWidthBiggerButtonX
          @sprites["buttonPreview"].y = (Graphics.height - (22 + @sprites["buttonPreview"].height)) - height
          @sprites["buttonName"].y = -height
        end
        if previewWidthHalfScreenSize && !(previewWidthDownArrowX && buttonXDownArrowX)
          @sprites["downArrow"].y = (Graphics.height - (44 + @sprites["buttonPreview"].height)) - height
        end
      end
    elsif @mode == 2 || @mode == 3
      @sprites["upArrow"].y = 16 + height if previewXUpArrowX
      @sprites["upArrow"].y = @sprites["buttonPreview"].height + height if buttonXHalfScreenSize && BOX_TOP_RIGHT
      if BOX_TOP_RIGHT
        @sprites["buttonPreview"].y = 22 + height
        @sprites["buttonName"].y = height
      end
    end
  end

  def updatePreviewBox
    return if @previewBox.isHidden
    if @curLocName == pbGetMapLocation(@mapX, @mapY)
      getLocationInfo if @mode == 0
      height = @sprites["previewBox"].height
      if @mode == 0
        @sprites["previewBox"].y = (Graphics.height - 32) - height
        changePreviewBoxAndArrow(height)
      elsif @mode == 2 || @mode == 3
        @sprites["previewBox"].y = (32 - @sprites["previewBox"].height) + height
        changePreviewBoxAndArrow(height)
      end
      if @mode == 0
        @sprites["locationDash"].visible = true if @locationDash
        @sprites["locationText"].visible = true
        @sprites["locationIcon"].visible = true if @locationIcon
      end
      getPreviewWeather
      @previewBox.shown
    else
      @previewBox.hideIt
      hidePreviewBox
    end
  end

  def hidePreviewBox
    return false if !@previewBox.canHide
    @sprites["previewBox"].visible = false
    @sprites["locationText"].bitmap.clear if @sprites["locationText"]
    if @locationIcon
      @sprites["locationIcon"].bitmap.clear
      @sprites["locationIcon"].visible = false
    end
    if @locationDash
      @sprites["locationDash"].bitmap.clear
      @sprites["locationDash"].visible = false
    end
    clearPreviewBox
    if @previewMode == 0
      @sprites["previewBox"].y = (Graphics.height - 32)
      @sprites["downArrow"].y = (BOX_BOTTOM_LEFT && (@sprites["buttonPreview"].x + @sprites["buttonPreview"].width) > (Graphics.width / 2)) || (BOX_BOTTOM_RIGHT && @sprites["buttonPreview"].x < (Graphics.width / 2)) ? (Graphics.height - (44 + @sprites["buttonPreview"].height)) : (Graphics.height - 60)
      if BOX_BOTTOM_LEFT || (BOX_BOTTOM_RIGHT && @sprites["previewBox"].width > @sprites["buttonPreview"].y)
        @sprites["buttonPreview"].y = (Graphics.height - (22 + @sprites["buttonPreview"].height))
        @sprites["buttonName"].y = 0
      end
    elsif @previewMode == 2 || @previewMode == 3
      @sprites["previewBox"].y = 32 - @sprites["previewBox"].height
      @sprites["upArrow"].y = (BOX_TOP_LEFT && (@sprites["buttonPreview"].x + @sprites["buttonPreview"].width) > (Graphics.width / 2)) || (BOX_TOP_RIGHT && @sprites["buttonPreview"].x < (Graphics.width / 2)) ? @sprites["buttonPreview"].height : 16
      if BOX_TOP_RIGHT || BOX_TOP_RIGHT
        @sprites["buttonPreview"].y = 22
        @sprites["buttonName"].y = 0
      end
    end
    @previewBox.hidden
    @locationIcon = false
    @locationDash = false
    getPreviewWeather
    return true
  end

  def clearPreviewBox
    return if @sprites["previewBox"].visible == false
    @sprites["locationText"].bitmap.clear if @sprites["locationText"]
    @sprites["modeName"].visible = true
  end
end

class PreviewState
  def initialize
    @state = :hidden
  end

  def state
    @state
  end

  def showIt
    @state = :show
  end

  def shown
    @state = :shown
  end

  def hideIt
    @state = :hide
  end

  def hidden
    @state = :hidden
  end

  def updateIt
    @state = :update
  end

  def updated
    @state = :updated
  end

  def isShown
    return @state == :shown
  end

  def isUpdated
    return @state == :updated
  end

  def isHidden
    return @state == :hidden
  end

  def canShow
    return @state == :show
  end

  def canHide
    return @state == :hide
  end

  def canUpdate
    return @state == :update
  end

  def isExtShown
    return @state == :extShown
  end

  def isExtHidden
    return @state == :extHidden
  end

  def extShow
    @state = :extShown
  end

  def extHide
    @state = :extHidden
  end
end
