class PokemonRegionMap_Scene
  def addRoamingIconSprites
    return if !enableMode(ARMSettings::SHOW_ROAMING_ICONS) || Settings::ROAMING_SPECIES.nil?
    if !@spritesMap["RoamingIcons"]
      @spritesMap["RoamingIcons"] = BitmapSprite.new(@mapWidth, @mapHeight, @viewportMap)
      @spritesMap["RoamingIcons"].x = @spritesMap["map"].x
      @spritesMap["RoamingIcons"].y = @spritesMap["map"].y
      @spritesMap["RoamingIcons"].z = 89
      @spritesMap["RoamingIcons"].visible = @mode == 4
    end
    $PokemonGlobal.roamPosition.each do |roamPos|
      active = getActiveRoaming(roamPos)
      next if !active
      roamTownMapPos = getRoamingTownMapPos(roamPos)
      next if !roamTownMapPos
      icon = getRoamingIcon(Settings::ROAMING_SPECIES[roamPos[0]][0])
      pbDrawImagePositions(@spritesMap["RoamingIcons"].bitmap,
        [[icon, pointXtoScreenX(roamTownMapPos[1]), pointYtoScreenY(roamTownMapPos[2])]])
    end
  end

  def getRoamingName(x, y)
    value = ""
    @previewWidth = 100
    roamingInfo = []
    $PokemonGlobal.roamPosition.each do |roamPos|
      next if getRoamingTownMapPos(roamPos)[1] != x || getRoamingTownMapPos(roamPos)[2] != y || !getActiveRoaming(roamPos)
      roamingInfo << roamPos
    end
    unless roamingInfo.empty?
      frames = ARMSettings::BUTTON_PREVIEW_TIME_CHANGE * Graphics.frame_rate
      indRoaming = (@timer / frames) % roamingInfo.length
      species = GameData::Species.try_get(Settings::ROAMING_SPECIES[roamingInfo[indRoaming][0]][0])
      value = species.real_name if species
    end
    updateButtonInfo if !ARMSettings::BUTTON_BOX_POSITION.nil?
    @sprites["modeName"].bitmap.clear
    mapModeSwitchInfo if value == ""
    return value
  end

  def getActiveRoaming(roamPos)
    return false if roamPos.nil?
    return $game_switches[Settings::ROAMING_SPECIES[roamPos[0]][2]] && (
           $PokemonGlobal.roamPokemon.size <= roamPos[0] ||
           $PokemonGlobal.roamPokemon[roamPos[0]]!=true
          )
  end

  def getRoamingTownMapPos(roamPos)
    mapPos = GameData::MapMetadata.try_get(roamPos[1])&.town_map_position
    return mapPos if mapPos[0] == @region
  end

  def getRoamingIcon(species)
    speciesData = GameData::Species.try_get(species)
    return nil if !speciesData
    path = "#{FOLDER}Icons/Roaming/map"
    if speciesData.form > 0
      ret = pbResolveBitmap("#{path + speciesData.species.to_s}_#{speciesData.form}")
      return ret if ret
    end
    ret = pbResolveBitmap("#{path + speciesData.species.to_s}")
    return ret if ret
    return pbResolveBitmap("#{path}000")
  end
end
