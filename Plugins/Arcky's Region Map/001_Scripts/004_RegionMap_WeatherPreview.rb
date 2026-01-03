class PokemonRegionMap_Scene 
  def getPreviewWeather 
    if WEATHERPLUGIN
      if !@sprites["weatherPreview"]
        @sprites["weatherPreview"] = IconSprite.new(0, 0, @viewport)
        @sprites["weatherPreview"].setBitmap(findUsableUI("WeatherPreview/mapWeatherBox"))
        if BOX_TOP_LEFT
          @sprites["weatherPreview"].y = 54
        else
          @sprites["weatherPreview"].y = 22
        end 
        @sprites["weatherPreview"].x = 4
        @sprites["weatherPreview"].z = 23
      end 
      if !ARMSettings::WEATHER_ON_LOCATION_PREVIEW_ACTIVE
        @sprites["weatherPreview"].visible = ARMSettings::WEATHER_ON_MODES.include?(@mode) && pbGetMapLocation(@mapX, @mapY) != ""
      else 
        @sprites["weatherPreview"].visible = @mode == 0 && @previewBox.state == :shown || ARMSettings::WEATHER_ON_MODES.include?(@mode) && @mode != 0 && pbGetMapLocation(@mapX, @mapY) != ""
      end 
      showPreviewWeather
    end 
  end 

  def showPreviewWeather 
    if !@sprites["weatherIcon"]
      @sprites["weatherIcon"] = IconSprite.new(0, 0, @viewport)
      if BOX_TOP_LEFT
        @sprites["weatherIcon"].y = 68
      else 
        @sprites["weatherIcon"].y = 36
      end 
      @sprites["weatherIcon"].x = 20
      @sprites["weatherIcon"].z = 27
    else 
      if @sprites["weatherIcon"]
        @sprites["weatherIcon"].visible = @sprites["weatherPreview"].visible
        return if !@sprites["weatherIcon"].visible 
      end 
      zone = pbGetMapZone(@mapX, @mapY)
      weather = :None
      if zone != nil
        weather = $WeatherSystem.actualWeather[zone].mainWeather
        weather = pbCheckValidWeather(weather, zone)
      end
      conversion = WeatherConfig::WEATHER_IMAGE
      id = conversion[weather]
      unless id.nil?
        @sprites["weatherIcon"].visible = true  
        @sprites["weatherIcon"].setBitmap("#{FOLDER}Icons/Weather/#{id}")
      else 
        @sprites["weatherIcon"].visible = false 
      end 
      @sprites["weatherPreview"].visible = @sprites["weatherIcon"].visible
    end 
  end
end 

