#===============================================================================
# UI stuff on loading the Region Map
#===============================================================================
class MapBottomSprite < Sprite
  def initialize(viewport = nil)
    super(viewport)
    @mapname     = ""
    @maplocation = ""
    @mapdetails  = ""
    @questName   = ""
    self.bitmap = BitmapWrapper.new(Graphics.width, Graphics.height)
    pbSetSystemFont(self.bitmap)
    refresh
  end

  def questName=(value)
    return if @questName == value 
    @questName = value 
    refresh
  end 

  def refresh
    bitmap.clear
    textpos = [
      [@mapname,     18 + RegionMapSettings::REGION_NAME_OFFSET_X,                   4 + RegionMapSettings::REGION_NAME_OFFSET_Y  , 0, RegionMapSettings::UI_TEXT_MAIN, RegionMapSettings::UI_TEXT_SHADOW],
      [@maplocation, 18 + RegionMapSettings::LOCATION_NAME_OFFSET_X,               360 + RegionMapSettings::LOCATION_NAME_OFFSET_Y, 0, RegionMapSettings::UI_TEXT_MAIN, RegionMapSettings::UI_TEXT_SHADOW],
      [@mapdetails,  Graphics.width - (16 - RegionMapSettings::POI_NAME_OFFSET_X), 360 + RegionMapSettings::POI_NAME_OFFSET_Y     , 1, RegionMapSettings::UI_TEXT_MAIN, RegionMapSettings::UI_TEXT_SHADOW],
      [@questName,   220 + RegionMapSettings::MODE_NAME_OFFSET_X                 ,   4 + RegionMapSettings::MODE_NAME_OFFSET_Y    , 0, RegionMapSettings::UI_TEXT_MAIN, RegionMapSettings::UI_TEXT_SHADOW]
    ]
    pbDrawTextPositions(bitmap, textpos)
  end
end
#===============================================================================
# The Region Map and everything else it does and can do.
#===============================================================================
class PokemonRegionMap_Scene
  ZERO_POINT_X  = RegionMapSettings::CURSOR_MAP_OFFSET ? 1 : 0
  ZERO_POINT_Y  = RegionMapSettings::CURSOR_MAP_OFFSET ? 1 : 0
  QUESTPLUGIN = PluginManager.installed?("Modern Quest System + UI") && RegionMapSettings::SHOW_QUEST_ICONS
  CURSOR_MAP_OFFSET = RegionMapSettings::CURSOR_MAP_OFFSET ? SQUARE_WIDTH : 0

  def initialize(region = - 1, wallmap = true)
    @region  = region
    @wallmap = wallmap
  end

  def pbStartScene(editor = false, flyMap = false)
    startFade
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 100001
    @viewportCursor = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewportCursor.z = 100000
    @viewportMap = Viewport.new(16, 32, 480, 320)
    @viewportMap.z = 99999
    @sprites = {}
    @spritesMap = {}
    @mapData = pbLoadTownMapData
    @flyMap = flyMap
    @mode    = flyMap ? 1 : 0
    @mapMetadata = $game_map.metadata
    @playerPos = (@mapMetadata) ? @mapMetadata.town_map_position : nil
    getPlayerPosition 
    @questMap = $quest_data.getQuestMapPositions(@map) if QUESTPLUGIN && $quest_data 
    if !@map
      pbMessage(_INTL("The map data cannot be found."))
      return false
    end
    main 
  end

  def main 
    changeBGM
    addBackgroundAndRegionSprite
    getVisitedMapInfo 
    getUnvisitedGameMaps
    recalculateFlyIconPositions 
    addFlyIconSprites 
    addUnvisitedMapSprites 
    showAndUpdateMapInfo 
    addPlayerIconSprite 
    addQuestIconSprites
    addCursorSprite 
    mapModeSwitchInfo 
    centerMapOnCursor
    refreshFlyScreen
    stopFade { pbUpdate } 
  end 

  def startFade
    return if @FadeViewport || @FadeSprite
    @FadeViewport = Viewport.new(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)
    @FadeViewport.z = 1000000
    @FadeSprite = BitmapSprite.new(Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT, @FadeViewport)
    @FadeSprite.bitmap.fill_rect(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT, Color.new(0, 0, 0))
    @FadeSprite.opacity = 0
    for i in 0..16
      Graphics.update
      yield i if block_given?
      @FadeSprite.opacity += 256 / 16.to_f
    end
  end

  def getPlayerPosition
    @mapX   = ZERO_POINT_X
    @mapY   = ZERO_POINT_Y
    if !@playerPos
      @mapIndex = 0
      @map     = @mapData[0]
    elsif @region >= 0 && @region != @playerPos[0] && @mapData[@region]
      @mapIndex = @region
      @map     = @mapData[@region]
    else
      @mapIndex = @playerPos[0]
      @map     = @mapData[@playerPos[0]]
      @mapX    = @playerPos[1]
      @mapY    = @playerPos[2]
      mapsize = @mapMetadata.town_map_size
      if mapsize && mapsize[0] && mapsize[0] > 0
        sqwidth  = mapsize[0]
        sqheight = (mapsize[1].length.to_f / mapsize[0]).ceil
        @mapX += ($game_player.x * sqwidth / $game_map.width).floor if sqwidth > 1
        @mapY += ($game_player.y * sqheight / $game_map.height).floor if sqheight > 1
      end
    end
  end 

  def changeBGM
    return if !RegionMapSettings::CHANGE_MUSIC_IN_REGION_MAP
    $game_system.bgm_memorize
    newBGM = RegionMapSettings::MUSIC_PER_REGION.find { |region| region[0] == @mapIndex }
    newBGM[2] = 100 if !newBGM[2]
    newBGM[3] = 100 if !newBGM[3]
    pbBGMPlay(newBGM[1], newBGM[2], newBGM[3])
  end 

  def addBackgroundAndRegionSprite
    @sprites["Background"] = IconSprite.new(0, 0, @viewport)
    @sprites["Background"].setBitmap("Graphics/Pictures/RegionMap/UI/mapBackGround")
    @sprites["Background"].x += (Graphics.width - @sprites["Background"].bitmap.width) / 2
    @sprites["Background"].y += (Graphics.height - @sprites["Background"].bitmap.height) / 2
    @sprites["Background"].z = 30
    @spritesMap["map"] = IconSprite.new(0, 0, @viewportMap)
    @spritesMap["map"].setBitmap("Graphics/Pictures/RegionMap/Regions/#{@map[1]}")
    @spritesMap["map"].z = 1
    @mapWidth = @spritesMap["map"].bitmap.width
    @mapHeigth = @spritesMap["map"].bitmap.height
    RegionMapSettings::REGION_MAP_EXTRAS.each do |graphic|
      next if graphic[0] != @mapIndex || !locationShown?(graphic)
      if !@spritesMap["map2"]
        @spritesMap["map2"] = BitmapSprite.new(480, 320, @viewportMap)
        @spritesMap["map2"].x = @spritesMap["map"].x
        @spritesMap["map2"].y = @spritesMap["map"].y
        @spritesMap["map2"].z = 6
      end
      pbDrawImagePositions(
        @spritesMap["map2"].bitmap,
        [["Graphics/Pictures/RegionMap/HiddenRegionMaps/#{graphic[4]}", graphic[2] * SQUARE_WIDTH, graphic[3] * SQUARE_HEIGHT]]
      )
    end
  end

  def locationShown?(point)
    return (point[5] == nil && point[1] > 0 && $game_switches[point[1]]) || point[5] if @wallmap
    return point[1] > 0 && $game_switches[point[1]]
  end

  def getVisitedMapInfo
    @unvisitedMaps = []
    @visitedMaps = []
    newMap = @map[2].sort_by { |index| [index[0], index[1]]}
    (ZERO_POINT_X..(@mapWidth / SQUARE_WIDTH)).each do |i|
      (ZERO_POINT_Y..(@mapHeigth / SQUARE_HEIGHT)).each do |j|
        healspot = pbGetHealingSpot(i, j)
        next if !healspot
        visited = $PokemonGlobal.visitedMaps[healspot[0]]
        map = newMap.find { |point| point[4] == healspot[0] && point[5] == healspot[1] && point[6] == healspot[2]}
        image = RegionMapSettings::USE_UNVISITED_IMAGE_EXCEPTION.find { |array| healspot == array[0..2]}
        map[9] = image ? image[3] : map[8]
        if visited
          @visitedMaps.push(map) if !@visitedMaps.include?(map)
        else
          @unvisitedMaps.push(map) if !@unvisitedMaps.include?(map)
        end
      end
    end
  end 

  def getUnvisitedGameMaps
    @gameMapsUnvisited = []
    return if !RegionMapSettings::NO_UNVISITED_MAP_INFO
    GameData::MapMetadata.each do |gameMap|
      map = $PokemonGlobal.visitedMaps[gameMap.id]
      next if map || !gameMap.outdoor_map
      @gameMapsUnvisited.push(gameMap.name)
    end 
  end 

  def addFlyIconSprites
    if !@spritesMap["FlyIcons"]
      @spritesMap["FlyIcons"] = BitmapSprite.new(@mapWidth, @mapHeigth, @viewportMap)
      @spritesMap["FlyIcons"].x = @spritesMap["map"].x
      @spritesMap["FlyIcons"].y = @spritesMap["map"].y
      @spritesMap["FlyIcons"].visible = @mode == 1
    end 
    @flyIconsPositions.each do |point|
      @spritesMap["FlyIcons"].z = 15
      iconName = @visitedMaps.find { |name| point[2] == name[2] } ? "mapFly" : "mapFlyDis"
      pbDrawImagePositions(
        @spritesMap["FlyIcons"].bitmap,
        [["Graphics/Pictures/RegionMap/Icons/#{iconName}", pointXtoScreenX(point[0]), pointYtoScreenY(point[1])]]
      )
    end
    @spritesMap["FlyIcons"].visible = @mode == 1
  end 

  def pointXtoScreenX(x)
    return ((SQUARE_WIDTH * x + (SQUARE_WIDTH / 2)) - 16)
  end

  def pointYtoScreenY(y)
    return ((SQUARE_HEIGHT * y + (SQUARE_HEIGHT / 2)) - 16)
  end

  def addUnvisitedMapSprites
    if !@spritesMap["Visited"]
      @spritesMap["Visited"] = BitmapSprite.new(@mapWidth, @mapHeigth, @viewportMap)
      @spritesMap["Visited"].x = @spritesMap["map"].x
      @spritesMap["Visited"].y = @spritesMap["map"].y
    end
    @unvisitedMaps.each do |visit|
      @spritesMap["Visited"].z = 10
      pbDrawImagePositions(
        @spritesMap["Visited"].bitmap,
        [["Graphics/Pictures/RegionMap/Unvisited/map#{visit[9]}", ((visit[0] - 1) * SQUARE_WIDTH) , ((visit[1] - 1) * SQUARE_HEIGHT)]]
      )
    end
  end 

  def showAndUpdateMapInfo
    if !@sprites["mapbottom"]
      @sprites["mapbottom"] = MapBottomSprite.new(@viewport)
      @sprites["mapbottom"].z = 40
    end
    @sprites["mapbottom"].mapname     = getMapName(@mapX, @mapY)
    @sprites["mapbottom"].maplocation = pbGetMapLocation(@mapX, @mapY)
    @sprites["mapbottom"].mapdetails  = pbGetMapDetails(@mapX, @mapY)
    @sprites["mapbottom"].questName   = pbGetQuestName(@mapX, @mapY) if QUESTPLUGIN
  end

  def getMapName(x, y)
    district = pbGetMessage(MessageTypes::RegionNames, @mapIndex)
    RegionMapSettings::REGION_DISTRICTS.each do |name|
      break if !RegionMapSettings::USE_REGION_DISTRICTS_NAMES
      next if name[0] != @mapIndex 
      if (x >= name[1][0] && x <= name[1][1]) && (y >= name[2][0] && y <= name[2][1])
        district = name[3]
      end 
    end
    return district 
  end

  def pbGetMapLocation(x, y)
    return "" if !@map[2]
    @routeType = ""
    @mapSize = [[] ,[], []]
    @spritesMap["highlight"].bitmap.clear if @spritesMap["highlight"]
    @map[2].each do |point|
      next if point[0] != x || point[1] != y
      return "" if point[7] && (point[7] <= 0 || !$game_switches[point[7]])
      name = pbGetMessageFromHash(MessageTypes::PlaceNames, point[2])
      selectedMaps = @map[2].select { |point| point[2] == name }
      selectedMaps.each do |select|
        @mapSize[0].push(select[0..1]) if !@mapSize[0].include?(select[0..1])
        @mapSize[1].push(select[8]) if @mapSize[1].length != @mapSize[0].length && select[8] != ""
        @mapSize[2].push(select[2]) if !@mapSize[2].include?(select[2]) && select[2] != ""
      end
      next if @mapSize[0] == []
      transposed = @mapSize[0].transpose
      minValues = [transposed[0].min, transposed[1].min]
      @mapSize[3] = minValues
      colorCurrentLocation
      name = RegionMapSettings::UNVISITED_MAP_TEXT if @gameMapsUnvisited.include?(point[2])
      return name
    end
    return ""
  end

  def pbGetMapDetails(x, y)
    return "" if !@map[2]
    @map[2].each do |point|
      next if point[0] != x || point[1] != y
      return "" if !point[3] ||point[7] && (@wallmap || point[7] <= 0 || !$game_switches[point[7]])
      mapdesc = @gameMapsUnvisited.include?(point[2]) && point[3] != "" ? RegionMapSettings::UNVISITED_POI_TEXT : pbGetMessageFromHash(MessageTypes::PlaceDescriptions, point[3])
      return mapdesc
    end
    return ""
  end

  def pbGetQuestName(x, y)
    return "" if !@map[2] || !@questMap || @mode != 2 || !RegionMapSettings::SHOW_QUEST_ICONS || @wallmap
    questName = []
    value = ""
    text = ""
    @questMap.each do |name|
      next if name[1] != x || name[2] != y
      break if @playerPos && name[0] != @playerPos[0]
      @questNames = nil
      return "" if name[4] && !$game_switches[name[4]]
      unless !name[3]
        questName.push($quest_data.getName(name[3].id)) 
        buttonName = convertButtonToString(RegionMapSettings::SHOW_QUEST_BUTTON)
        if questName.length >= 2
          @questNames = questName 
          value = "#{questName.length} Active Quests"
          text = "#{buttonName}: view Quests"
        else
          value = "Quest: #{questName[0]}"
          text = "#{buttonName}: view Quest"
        end
      else 
        value = "Invalid Quest Position"
        buttonName = convertButtonToString(RegionMapSettings::CHANGE_MODE_BUTTON)
        text = "#{buttonName}: Change Mode"
      end
    end
    textPos = getTextPosition
    @sprites["modeName"].bitmap.clear
    @sprites["buttonName"].bitmap.clear
    width = @sprites["buttonPreview"].width
    pbDrawTextPositions(
      @sprites["buttonName"].bitmap,
      [[text, textPos[0] + (width / 2), textPos[1] + 14, 2, RegionMapSettings::BOX_TEXT_MAIN, RegionMapSettings::BOX_TEXT_SHADOW]]
    )
    mapModeSwitchInfo if text == "" && value == ""
    return value
  end 
  
  def convertButtonToString(button)
    case button 
    when 11
      buttonName = "ACTION"
    when 13 
      buttonName = "USE"
    when 14 
      buttonName = "JUMPUP"
    when 15
      buttonName = "JUMPDOWN"
    when 16
      buttonName = "SPECIAL"
    when 17
      buttonName = "AUX1"
    when 18
      buttonName = "AUX2"
    end 
    return buttonName
  end 

  def addPlayerIconSprite
    if @playerPos && @mapIndex == @playerPos[0]
      if !@spritesMap["player"]
        @spritesMap["player"] = BitmapSprite.new(@mapWidth, @mapHeigth, @viewportMap)
        @spritesMap["player"].x = @spritesMap["map"].x
        @spritesMap["player"].y = @spritesMap["map"].y
      end
	  
	  #added by Gardenette
	  trainerIcon = "Graphics/Pictures/RegionMap/Icons/#{$player.trainer_type.to_s}"
	  
      @spritesMap["player"].z = 60
      pbDrawImagePositions(
        @spritesMap["player"].bitmap,
        #[[GameData::TrainerType.player_map_icon_filename($player.trainer_type), pointXtoScreenX(@mapX) , pointYtoScreenY(@mapY)]]
		
		#added by Gardenette
		[[trainerIcon, pointXtoScreenX(@mapX) , pointYtoScreenY(@mapY)]]
      )
    end
  end

  def addQuestIconSprites
    usedPositions = {}
    if !@spritesMap["QuestIcons"] && QUESTPLUGIN && RegionMapSettings::SHOW_QUEST_ICONS
      @spritesMap["QuestIcons"] = BitmapSprite.new(@mapWidth, @mapHeigth, @viewportMap)
      @spritesMap["QuestIcons"].x = @spritesMap["map"].x
      @spritesMap["QuestIcons"].y = @spritesMap["map"].y
    end 
    return if !@spritesMap["QuestIcons"]
    @questMap.each do |index|
      if @playerPos
        next if index[0] != @playerPos[0]
      else
       index[0] = @mapIndex
      end 
      x = index[1]      
      y = index[2]      
      next if usedPositions.key?([x, y])
      next if index[4] && !$game_switches[index[4]] 
      @spritesMap["QuestIcons"].z = 50
      pbDrawImagePositions(
        @spritesMap["QuestIcons"].bitmap,
        [["Graphics/Pictures/RegionMap/Icons/mapQuest", pointXtoScreenX(x) , pointYtoScreenY(y)]]
      )
      usedPositions[[x, y]] = true
    end
    @spritesMap["QuestIcons"].visible = QUESTPLUGIN && @mode == 2
  end 

  def addCursorSprite
    @sprites["cursor"] = AnimatedSprite.create("Graphics/Pictures/RegionMap/UI/mapCursor", 2, 5)
    @sprites["cursor"].viewport = @viewportCursor
    @sprites["cursor"].x        = 8 + SQUARE_WIDTH * @mapX 
    @sprites["cursor"].y        = 24 + SQUARE_HEIGHT * @mapY
    @sprites["cursor"].play
  end 

  def mapModeSwitchInfo
    if !@sprites["modeName"] && !@sprites["buttonName"]
      @sprites["modeName"] = BitmapSprite.new(Graphics.width, Graphics.height, @Viewport)
      pbSetSystemFont(@sprites["modeName"].bitmap)
      @sprites["buttonName"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      pbSetSystemFont(@sprites["buttonName"].bitmap)
      showButtonPreview
      text2Pos = getTextPosition
      @sprites["buttonPreview"].x = text2Pos[0]
      @sprites["buttonPreview"].y = text2Pos[1]
    end 
    unless @flyMap && (RegionMapSettings::SWITCH_TO_ENABLE_QUICK_FLY.nil? || $game_switches[RegionMapSettings::SWITCH_TO_ENABLE_QUICK_FLY])
      return if !@sprites["modeName"] || !@sprites["buttonName"] || @wallmap || @flyMap
      @modeInfo = {
        :normal => {
          mode: 0,
          text: _INTL("#{RegionMapSettings::MODE_NAMES[:normal]}"),
          condition: true
        },
        :fly => {
          mode: 1,
          text: _INTL("#{RegionMapSettings::MODE_NAMES[:fly]}"),
          condition: pbCanFly?
        },
        :quest => {
          mode: 2,
          text: _INTL("#{RegionMapSettings::MODE_NAMES[:quest]}"),
          condition: QUESTPLUGIN
        },
        :berry => {
          mode: 3,
          text: _INTL("#{RegionMapSettings::MODE_NAMES[:berry]}"),
          condition: PluginManager.installed?("TDW Berry Planting Improvements")
        },
        :roaming => {
          mode: 4,
          text: _INTL("#{RegionMapSettings::MODE_NAMES[:roaming]}"),
          condition: PluginManager.installed?("Roaming Icon")
        }
      }
      @modeCount = @modeInfo.values.count { |mode| mode[:condition] }
      if @modeCount == 1
        text = ""
        @sprites["modeName"].bitmap.clear
        @sprites["buttonName"].bitmap.clear
        @sprites["buttonPreview"].visible = false 
        return 
      end 
      buttonName = convertButtonToString(RegionMapSettings::CHANGE_MODE_BUTTON)
      text = @modeInfo[:normal][:text]
      text2 = "#{buttonName}: Change Mode"
      @modeInfo.each do |mode, data|
        if data[:mode] == @mode && data[:condition]
          text = data[:text]
          if @mode == 1 && RegionMapSettings::CAN_QUICK_FLY && (RegionMapSettings::SWITCH_TO_ENABLE_QUICK_FLY.nil? || $game_switches[RegionMapSettings::SWITCH_TO_ENABLE_QUICK_FLY])
            buttonName = convertButtonToString(RegionMapSettings::QUICK_FLY_BUTTON)
            text2 = _INTL("#{buttonName}: Quick Fly")
          end 
          break 
        end 
      end 
    else 
      buttonName = convertButtonToString(RegionMapSettings::QUICK_FLY_BUTTON)
      text = _INTL("#{buttonName}: Quick Fly")
      text2 = ""
    end 
    @sprites["modeName"].bitmap.clear
    @sprites["buttonName"].bitmap.clear
    text2Pos = getTextPosition
    width = @sprites["buttonPreview"].width
    pbDrawTextPositions(
      @sprites["modeName"].bitmap,
      [[text, Graphics.width - (22 - RegionMapSettings::MODE_NAME_OFFSET_X), 4 + RegionMapSettings::MODE_NAME_OFFSET_Y, 1, RegionMapSettings::UI_TEXT_MAIN, RegionMapSettings::UI_TEXT_SHADOW]]
    )
    pbDrawTextPositions(
      @sprites["buttonName"].bitmap,
       [[text2, text2Pos[0] + (width / 2), text2Pos[1] + 14, 2, RegionMapSettings::BOX_TEXT_MAIN, RegionMapSettings::BOX_TEXT_SHADOW]]
    )
    @sprites["modeName"].z = 100001
    @sprites["buttonName"].z = 25
  end 

  def getTextPosition
    case RegionMapSettings::BUTTON_PREVIEW_BOX_POSITION
    when 1
      x = 4
      y = 22
    when 2
      x = 4
      y = 314
    when 3
      x = 260
      y = 22
    when 4
      x = 260
      y = 314
    end 
    return x, y
  end 

  def showButtonPreview
    if !@sprites["buttonPreview"]
      @sprites["buttonPreview"] = IconSprite.new(0, 0, @viewport)
      @sprites["buttonPreview"].setBitmap("Graphics/Pictures/RegionMap/UI/mapButtonPreview")
      @sprites["buttonPreview"].z = 24
      @sprites["buttonPreview"].visible = !@flyMap && !@wallmap
    end 
  end 
  
  def clearQuestPreview
    return if @sprites["questPreview"].visible == false
    @sprites["questPreviewText"].bitmap.clear if @sprites["questPreviewText"]
    @sprites["modeName"].visible = true
  end 
  
  def centerMapOnCursor
    centerMapX
    centerMapY
    addArrowSprites if !@sprites["upArrow"]
    updateArrows
  end  

  def centerMapX
    mapMaxX = -1 * (@mapWidth - 480)
    mapPosX = (480 / 2) - @sprites["cursor"].x
    if @sprites["cursor"].x > (Settings::SCREEN_WIDTH / 2) 
      if @mapWidth > 480
        @spritesMap.each do |key, value|
          @spritesMap[key].x = mapPosX % SQUARE_WIDTH != 0 ? mapPosX + 8 : mapPosX
        end 
        if @spritesMap["map"].x < mapMaxX
          @spritesMap.each do |key, value|
            @spritesMap[key].x = mapMaxX % SQUARE_WIDTH != 0 ? mapMaxX + 8 : mapMaxX
          end 
        end    
      end
      @sprites["cursor"].x += @spritesMap["map"].x
    else  
      @spritesMap.each do |key, value|
        @spritesMap[key].x = 0
      end
    end
  end 

  def centerMapY
    mapMaxY = -1 * (@mapHeigth - 320)
    mapPosY = (320 / 2) - @sprites["cursor"].y
    if @sprites["cursor"].y > (Settings::SCREEN_HEIGHT / 2)
      if @mapHeigth > 320
        @spritesMap.each do |key, value|
          @spritesMap[key].y = mapPosY % SQUARE_HEIGHT != 0 ? mapPosY + 8 : mapPosY
        end 
        if @spritesMap["map"].y < mapMaxY
          @spritesMap.each do |key, value|
            @spritesMap[key].y = mapMaxY % SQUARE_HEIGHT != 0 ? mapMaxY + 8 : mapMaxY
          end 
        end    
      end
      @sprites["cursor"].y += @spritesMap["map"].y
    else  
      @spritesMap.each do |key, value|
        @spritesMap[key].y = 0
      end
    end
  end 

  def addArrowSprites
    @sprites["upArrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow", 8, 28, 40, 2, @viewport)
    @sprites["upArrow"].x = (Graphics.width / 2) - 14
    @sprites["upArrow"].y = 16
    @sprites["upArrow"].z = 35
    @sprites["upArrow"].play 
    @sprites["downArrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow", 8, 28, 40, 2, @viewport)
    @sprites["downArrow"].x = (Graphics.width / 2) - 14
    @sprites["downArrow"].y = Graphics.height - 60
    @sprites["downArrow"].z = 35
    @sprites["downArrow"].play
    @sprites["leftArrow"] = AnimatedSprite.new("Graphics/Pictures/leftarrow", 8, 40, 28, 2, @viewport)
    @sprites["leftArrow"].y = (Graphics.height / 2) - 14
    @sprites["leftArrow"].z = 35
    @sprites["leftArrow"].play
    @sprites["rightArrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow", 8, 40, 28, 2, @viewport)
    @sprites["rightArrow"].x = Graphics.width - 40
    @sprites["rightArrow"].y = (Graphics.height / 2) - 14
    @sprites["rightArrow"].z = 35
    @sprites["rightArrow"].play
  end 

  def updateArrows
    @sprites["upArrow"].visible = @spritesMap["map"].y < 0 ? true : false
    @sprites["downArrow"].visible = @spritesMap["map"].y > -1 * (@mapHeigth - 320) ? true : false
    @sprites["leftArrow"].visible =  @spritesMap["map"].x < 0 ? true : false 
    @sprites["rightArrow"].visible = @spritesMap["map"].x > -1 * (@mapWidth - 480) ? true : false
  end 

  def refreshFlyScreen
    return if @flyMap
    mapModeSwitchInfo
    showAndUpdateMapInfo
    if @sprites["questPreview"]
      distPerFrame = 8 * 20 / Graphics.frame_rate
      until @sprites["questPreview"].y == (32 - @sprites["questPreview"].height) do
        hideQuestPreview(distPerFrame)
        Graphics.update 
      end 
    end
    @spritesMap["FlyIcons"].visible = @mode == 1
    @spritesMap["QuestIcons"].visible = @mode == 2 if QUESTPLUGIN && RegionMapSettings::SHOW_QUEST_ICONS
    @spritesMap["highlight"].bitmap.clear if @spritesMap["highlight"]
    colorCurrentLocation 
  end

  def stopFade
    return if !@FadeSprite || !@FadeViewport
    for i in 0...(16 + 1)
      Graphics.update
      yield i if block_given?
      @FadeSprite.opacity -= 256 / 16.to_f
    end
    @FadeSprite.dispose
    @FadeSprite = nil
    @FadeViewport.dispose
    @FadeViewport = nil
  end  

  def recalculateFlyIconPositions
    centerHash = {}
    matchingElements = []
    @flyIconsPositions = @visitedMaps.map(&:dup) + @unvisitedMaps.map(&:dup)
    @flyIconsPositions.each do |element|
      mapName = element[2]
      next if centerHash.key?(mapName)
      matchingElements = @map[2].select { |map| map[2] == mapName }
      if matchingElements.any?
        centerX = matchingElements.map { |map| map[0] }.sum.to_f / matchingElements.length
        centerY = matchingElements.map { |map| map[1] }.sum.to_f / matchingElements.length
        centerHash[mapName] = [centerX, centerY]
      end
    end
    @flyIconsPositions.each do |element|
      mapName = element[2]
      if centerHash.key?(mapName)
        element[0] = centerHash[mapName][0]
        element[1] = centerHash[mapName][1]
      end
    end
    return
  end  

  def colorCurrentLocation
    addHighlightSprites if !@spritesMap["highlight"]
    if @mode != 1 
      return if !@mapSize[1][0]
      index = @mapSize[0].index([@mapX, @mapY]) if @mapSize
      mapFolder = getMapFolderName(index)
      unless @mapSize[3][2] 
        @mapSize[3][0] -= 1 if !@mapSize[1][index].include?("Small") && !@mapSize[1][index].include?("Route") 
        @mapSize[3][1] -= 1 if !@mapSize[1][index].include?("Small") && !@mapSize[1][index].include?("Route")
        @mapSize[3][2] = true
      end
      @mapSize[3] = @mapSize[0][index] if @mapSize[1][index] =~ /1x1Small/
      pbDrawImagePositions(
        @spritesMap["highlight"].bitmap,
        [["Graphics/Pictures/RegionMap/Highlights/#{mapFolder}/map#{@mapSize[1][index]}", ((@mapSize[3][0]) * SQUARE_WIDTH) , ((@mapSize[3][1]) * SQUARE_HEIGHT)]]
      )
    else  
      flyMap = @flyIconsPositions.find { |map| map[2] == @mapSize[2][0] }
      return if !flyMap || @unvisitedMaps.find { |name| flyMap[2] == name[2] }
        pbDrawImagePositions(
          @spritesMap["highlight"].bitmap,
          [["Graphics/Pictures/RegionMap/Icons/MapFlySel", (flyMap[0] * SQUARE_WIDTH) - 8 , (flyMap[1] * SQUARE_HEIGHT) - 8]]
        )
    end
  end

  def addHighlightSprites
    @spritesMap["highlight"] = BitmapSprite.new(@mapWidth, @mapHeigth, @viewportMap)
    @spritesMap["highlight"].x = @spritesMap["map"].x
    @spritesMap["highlight"].y = @spritesMap["map"].y
    @spritesMap["highlight"].opacity = convertOpacity(RegionMapSettings::HIGHLIGHT_OPACITY)
    @spritesMap["highlight"].visible = true 
    @spritesMap["highlight"].z = 20
  end 

  def convertOpacity(input)
    return (([0, [100, (input / 5.0).round * 5].min].max) * 2.55).round 
  end 

  def getMapFolderName(index)
    case @mapSize[1][index]
    when /Size/
      mapFolder = "Others"
    when /Route/
      mapFolder = "Routes"
    end
    return mapFolder
  end 

  def pbMapScene
    cursor = createObject
    map = createObject
    opacityBox = convertOpacity(RegionMapSettings::BUTTON_PREVIEW_BOX_OPACITY)
    choice   = nil
    lastChoiceFly = 0
    lastChoiceQuest = 0
    distPerFrame = 8 * 20 / Graphics.frame_rate
    @hideQuest = false 
    loop do
      Graphics.update
      Input.update
      pbUpdate
      toggleButtonBox(opacityBox, distPerFrame)
      hideQuestPreview(distPerFrame) if @hideQuest
      if cursor[:offsetX] != 0 || cursor[:offsetY] != 0
        updateCursor(cursor, distPerFrame)
        updateMap(map, distPerFrame) if map[:offsetX] != 0 || map[:offsetY] != 0 
        next 
      end
      if map[:offsetX] != 0 || map[:offsetY] != 0
        updateMap(map, distPerFrame)
        next 
      end
      if cursor[:offsetX] == 0 && cursor[:offsetY] == 0 && choice && choice >= 0 
        inputFly = true if @mode == 1
        lastChoiceQuest = choice if @mode == 2
        lastChoiceFly = choice if @mode == 1
        choice = nil
      end
      updateArrows if @mapX != cursor[:oldX] || @mapY != cursor[:oldY]
      ox, oy, mox, moy = 0, 0, 0, 0
      cursor[:oldX] = @mapX
      cursor[:oldY] = @mapY
      ox, oy, mox, moy = getDirectionInput(ox, oy, mox, moy)
      choice = canActivateQuickFly(lastChoiceFly, cursor)
      updateCursorPosition(ox, oy, cursor) if ox != 0 || oy != 0
      updateMapPosition(mox, moy, map) if mox != 0 || moy != 0
      showAndUpdateMapInfo if @mapX != cursor[:oldX] || @mapY != cursor[:oldY]
      if (Input.trigger?(Input::USE) && @mode == 1) || inputFly
        return @healspot if getFlyLocationAndConfirm { pbUpdate }
      elsif Input.trigger?(RegionMapSettings::SHOW_QUEST_BUTTON) && QUESTPLUGIN && @mode == 2 
        choice = showQuestInformation(lastChoiceQuest, distPerFrame)
      elsif Input.trigger?(Input::ACTION) && !@wallmap && !@flyMap
        switchMapMode
      end
      break if Input.trigger?(Input::BACK)
    end
    pbPlayCloseMenuSE
    return nil
  end

  def toggleButtonBox(opacityBox, distPerFrame)
    buttonBox = createBoxObject
    if ((@sprites["cursor"].x >= buttonBox[:startX] && @sprites["cursor"].x <= buttonBox[:endX]) && (@sprites["cursor"].y >= buttonBox[:startY] && @sprites["cursor"].y <= buttonBox[:endY])) && @sprites["buttonName"].opacity != opacityBox
      @sprites["buttonPreview"].opacity -= (255 - opacityBox) / distPerFrame
      @sprites["buttonName"].opacity -= (255 - opacityBox) / distPerFrame
    end 
    if ((@sprites["cursor"].x < buttonBox[:startX] || @sprites["cursor"].x > buttonBox[:endX]) || (@sprites["cursor"].y < buttonBox[:startY] || @sprites["cursor"].y > buttonBox[:endY])) && @sprites["buttonName"].opacity != 255
      @sprites["buttonPreview"].opacity += (255 - opacityBox) / distPerFrame
      @sprites["buttonName"].opacity += (255 - opacityBox) / distPerFrame
    end
  end

  def createObject 
    object = {
      offsetX: 0,
      offsetY: 0,
      newX: 0,
      newY: 0,
      oldX: 0,
      oldY: 0 
    }
    return object
  end 

  def createBoxObject
    object = {
      startX: (@sprites["buttonPreview"].x - SQUARE_WIDTH + 8) / SQUARE_WIDTH * SQUARE_WIDTH,
      endX: (((@sprites["buttonPreview"].x - SQUARE_WIDTH) + @sprites["buttonPreview"].width) + 8) / SQUARE_WIDTH * SQUARE_WIDTH,
      startY: (@sprites["buttonPreview"].y - SQUARE_HEIGHT) / SQUARE_HEIGHT * SQUARE_HEIGHT,
      endY: (((@sprites["buttonPreview"].y + @sprites["buttonPreview"].height) - SQUARE_HEIGHT) + 8) / (SQUARE_HEIGHT / 2) * (SQUARE_HEIGHT / 2)
    }
    return object
  end 

  def updateCursor(cursor, distPerFrame)
    cursor[:offsetX] += (cursor[:offsetX] > 0) ? -distPerFrame : (cursor[:offsetX] < 0) ? distPerFrame : 0
    cursor[:offsetY] += (cursor[:offsetY] > 0) ? -distPerFrame : (cursor[:offsetY] < 0) ? distPerFrame : 0
    @sprites["cursor"].x = cursor[:newX] - cursor[:offsetX]
    @sprites["cursor"].y = cursor[:newY] - cursor[:offsetY]
    @hideQuest = true if @sprites["questPreview"] && @sprites["questPreview"].visible
  end 

  def updateMap(map, distPerFrame)
    map[:offsetX] += (map[:offsetX] > 0) ? -distPerFrame : (map[:offsetX] < 0) ? distPerFrame : 0
    map[:offsetY] += (map[:offsetY] > 0) ? -distPerFrame : (map[:offsetY] < 0) ? distPerFrame : 0
    @spritesMap.each do |key, value|
      @spritesMap[key].x = map[:newX] - map[:offsetX]
      @spritesMap[key].y = map[:newY] - map[:offsetY]
    end
    @hideQuest = true if @sprites["questPreview"] && @sprites["questPreview"].visible
  end 

  def getDirectionInput(ox, oy, mox, moy)
    case Input.dir8
    when 1, 2, 3
      oy = 1 if @sprites["cursor"].y < (320 - CURSOR_MAP_OFFSET)
      moy = -1 if @spritesMap["map"].y > -1 * (@mapHeigth - 320) && oy == 0
    when 7, 8, 9
      oy = -1 if @sprites["cursor"].y > (32 + CURSOR_MAP_OFFSET)
      moy = 1 if @spritesMap["map"].y < 0 && oy == 0
    end
    case Input.dir8
    when 1, 4, 7
      ox = -1 if @sprites["cursor"].x > (16 + CURSOR_MAP_OFFSET)
      mox = 1 if @spritesMap["map"].x < 0 && ox == 0
    when 3, 6, 9
      ox = 1 if @sprites["cursor"].x < (464 - CURSOR_MAP_OFFSET)
      mox = -1 if @spritesMap["map"].x > -1 * (@mapWidth - 480) && ox == 0
    end
    return ox, oy, mox, moy
  end

  def canActivateQuickFly(lastChoiceFly, cursor)
    if RegionMapSettings::CAN_QUICK_FLY && Input.trigger?(RegionMapSettings::QUICK_FLY_BUTTON) && @mode == 1 && 
      (RegionMapSettings::SWITCH_TO_ENABLE_QUICK_FLY.nil? || $game_switches[RegionMapSettings::SWITCH_TO_ENABLE_QUICK_FLY])
      findChoice = @visitedMaps.find_index { |mapName| mapName[2] == pbGetMapLocation(@mapX, @mapY)}
      lastChoiceFly = findChoice if findChoice
      choice = pbMessageMap(_INTL("Quick Fly: Choose one of the available locations to fly to."), 
          (0...@visitedMaps.size).to_a.map{|i| 
            next _INTL("#{@visitedMaps[i][2]}")
          }, -1, nil, lastChoiceFly) { pbUpdate }
      if choice != -1 && @visitedMaps[choice][2] != pbGetMapLocation(@mapX, @mapY)
        @mapX = @visitedMaps[choice][0]
        @mapY = @visitedMaps[choice][1]
      elsif choice == -1
        @mapX = cursor[:oldX]
        @mapY = cursor[:oldY]
      end
      @sprites["cursor"].x = 8 + (@mapX * SQUARE_WIDTH)
      @sprites["cursor"].y = 24 + (@mapY * SQUARE_HEIGHT)
      pbGetMapLocation(@mapX, @mapY)
      centerMapOnCursor
    end
    return choice
  end 

  def updateCursorPosition(ox, oy, cursor)
    @mapX += ox
    @mapY += oy
    cursor[:offsetX] = ox * SQUARE_WIDTH
    cursor[:offsetY] = oy * SQUARE_HEIGHT
    cursor[:newX] = @sprites["cursor"].x + cursor[:offsetX]
    cursor[:newY] = @sprites["cursor"].y + cursor[:offsetY]
  end 

  def updateMapPosition(mox, moy, map)
    @mapX -= mox 
    @mapY -= moy
    map[:offsetX] = mox * SQUARE_WIDTH
    map[:offsetY] = moy * SQUARE_HEIGHT 
    map[:newX] = @spritesMap["map"].x + map[:offsetX]
    map[:newY] = @spritesMap["map"].y + map[:offsetY]
  end 

  def getFlyLocationAndConfirm
    @healspot = pbGetHealingSpot(@mapX, @mapY)
    if @healspot && ($PokemonGlobal.visitedMaps[@healspot[0]] || ($DEBUG && Input.press?(Input::CTRL)))
      name = pbGetMapNameFromId(@healspot[0])
      return pbConfirmMessageMap(_INTL("Would you like to use Fly to go to {1}?", name)) 
    end
  end 

  def showQuestInformation(lastChoiceQuest, distPerFrame)
    return if @wallmap
    region = @playerPos ? @playerPos[0] : @mapIndex
    questInfo = @questMap.select { |coords| coords && coords[0..2] == [region, @mapX, @mapY] }
    questInfo = [] if questInfo.empty? || (questInfo[0][4] && !$game_switches[questInfo[0][4]])
    return if questInfo == []
    input, quest, choice = getCurrentQuestInfo(lastChoiceQuest, questInfo)
    if input && quest
      questInfoText = []
      name = $quest_data.getName(quest.id)
      base = colorToRgb16(RegionMapSettings::BOX_TEXT_MAIN)
      shadow = colorToRgb16(RegionMapSettings::BOX_TEXT_SHADOW)
      description = $quest_data.getStageDescription(quest.id, quest.stage)
      description = "Not Given" if description.empty?
      location = $quest_data.getStageLocation(quest.id, quest.stage)
      location = "Unknown" if location.empty?
      questInfoText[0] = "<c2=#{base}#{shadow}>Task: #{description}"
      questInfoText[1] = "<c2=#{base}#{shadow}>Location: #{location}"  
      @sprites["mapbottom"].questName = "Quest: #{name}"
      if !@sprites["questPreviewText"]
        @sprites["questPreviewText"] = BitmapSprite.new(Graphics.width, (32 * (RegionMapSettings::MAX_QUEST_LINES + 1)) , @Viewport)
        pbSetSystemFont(@sprites["questPreviewText"].bitmap)
      end 
      @sprites["questPreviewText"].bitmap.clear
      x = 40
      lineHeight = 32
      getQuestPreview2 if @lineCount
      @sprites["questPreviewText"].visible = false
      questInfoText.each do |text|
        chars = getFormattedText(@sprites["questPreviewText"].bitmap, 220, x, 272, -1, text, lineHeight)
        x += (1 + chars.count { |item| item[0] == "\n" }) * lineHeight
        drawFormattedChars(@sprites["questPreviewText"].bitmap, chars)
        @lineCount = (x / lineHeight) - 1
      end
      @lineCount = RegionMapSettings::MAX_QUEST_LINES if @lineCount > RegionMapSettings::MAX_QUEST_LINES
      @sprites["upArrow"].z = 24 if @sprites["upArrow"].z != 24
      showQuestPreview(distPerFrame)
      if @sprites["questPreviewClone"] && @questVisible
        @sprites["questPreviewClone"].visible = !choice.nil?
        updateQuestPreview(distPerFrame)
      end 
      @questVisible = true 
      @sprites["questPreviewText"].visible = true 
      @sprites["questPreviewText"].z = 100001
    end
    return choice 
  end 

  def getCurrentQuestInfo(lastChoiceQuest, questInfo)
    if @questNames
      choice = pbMessageMap(_INTL("Which quest would you like to view info about?"), 
      (0...@questNames.size).to_a.map{|i| 
        next _INTL("#{@questNames[i]}")
      }, -1, nil, lastChoiceQuest) { pbUpdate }
      input = choice != -1
      quest = questInfo[choice][3]
    else 
      input = true
      quest = questInfo[0][3]
    end
    return input, quest, choice 
  end 

  # creates Quest Preview bitmap with previous line count and places it above the original one.
  def getQuestPreview2
    if !@sprites["questPreviewClone"]
      @sprites["questPreviewClone"] = IconSprite.new(202, 32, @viewport)
      @sprites["questPreviewClone"].z = 24
    end 
    @sprites["questPreviewClone"].setBitmap("Graphics/Pictures/RegionMap/UI/mapQuestPreview#{@lineCount}")
    @sprites["questPreviewClone"].opacity = 0
    @sprites["questPreviewClone"].visible = false 
  end 

  def showQuestPreview(distPerFrame)
    if !@sprites["questPreview"]
      @sprites["questPreview"] = IconSprite.new(202, 32, @viewport) 
      @sprites["questPreview"].z = 25
      @sprites["questPreview"].visible = false
    end
    @sprites["questPreview"].setBitmap("Graphics/Pictures/RegionMap/UI/mapQuestPreview#{@lineCount}")
    makeBitmapVisible(distPerFrame) if !@sprites["questPreview"].visible
  end 

  def makeBitmapVisible(distPerFrame)
    @sprites["questPreview"].y = (32 - @sprites["questPreview"].height)
    @sprites["questPreview"].visible = true
    dist = distPerFrame * 2
    height = @sprites["questPreview"].height
    until @sprites["questPreview"].y == 32 do
      @sprites["questPreview"].y += height / dist
      if RegionMapSettings::BUTTON_PREVIEW_BOX_POSITION == 3
        @sprites["buttonPreview"].y += height / dist
        @sprites["buttonName"].y += height / dist
      end
      if @sprites["questPreview"].y == (32 - height) + (height / dist) * dist
        @sprites["questPreview"].y += 32 - @sprites["questPreview"].y
        if RegionMapSettings::BUTTON_PREVIEW_BOX_POSITION == 3
          @sprites["buttonPreview"].y = 22 + @sprites["questPreview"].height
          @sprites["buttonName"].y = 0 + @sprites["questPreview"].height
        end 
      end
      Graphics.update
    end
  end

  def hideQuestPreview(distPerFrame)
    return if !@sprites["questPreview"]
    dist = SQUARE_WIDTH / (distPerFrame / 2)
    height = @sprites["questPreview"].height
    clearQuestPreview
    if @sprites["questPreview"] && @sprites["questPreview"].y != (32 - @sprites["questPreview"].height) && @sprites["questPreview"].y <= 32
      @sprites["questPreview"].y -= height / dist
      if RegionMapSettings::BUTTON_PREVIEW_BOX_POSITION == 3
        @sprites["buttonPreview"].y -= height / dist
        @sprites["buttonName"].y -= height / dist
      end 
      if @sprites["questPreview"].y == 32 - ((height / dist) * dist)
        @sprites["questPreview"].y += (32 - height) - @sprites["questPreview"].y
        if RegionMapSettings::BUTTON_PREVIEW_BOX_POSITION == 3
          @sprites["buttonPreview"].y = 22
          @sprites["buttonName"].y = 0
        end 
      end 
      @sprites["questPreviewClone"].opacity = 0 if @sprites["questPreviewClone"]
    end 
    @sprites["questPreview"].visible = false if @sprites["questPreview"] && @sprites["questPreview"].y == (32 - @sprites["questPreview"].height)
    @sprites["upArrow"].z = 35 if @sprites["upArrow"].z != 35
    @hideQuest = false if !@sprites["questPreview"].visible
    @sprites["questPreviewClone"].visible = false if @sprites["questPreviewClone"]
    @questVisible = false 
  end 

  def updateQuestPreview(distPerFrame)
    return if !@sprites["questPreviewClone"].visible
    if @sprites["questPreview"].height != @sprites["questPreviewClone"].height
      dist = @sprites["questPreviewClone"].height - @sprites["questPreview"].height
      @sprites["questPreview"].y += dist #102 - 70 = 32 <=> 70 - 134 = -64
      @sprites["questPreviewClone"].y = 32
      @sprites["questPreviewClone"].opacity = 255
      if dist > 0
        @sprites["questPreviewClone"].z = 24
      else 
        @sprites["questPreviewClone"].z = 26
      end
      height = (22 + @sprites["questPreview"].height) - @sprites["buttonPreview"].y
      until @sprites["questPreview"].y == 32 do 
        if RegionMapSettings::BUTTON_PREVIEW_BOX_POSITION == 3
          @sprites["buttonPreview"].y += height / 8
          @sprites["buttonName"].y += height / 8 
        end
        if @sprites["questPreviewClone"]
          @sprites["questPreview"].y -= dist / 8
          @sprites["questPreviewClone"].y -= dist / 8
          if dist > 0
            @sprites["questPreview"].opacity += 255 / 8
          else 
            @sprites["questPreviewClone"].opacity -= 255 / 8
          end 
        end 
        Graphics.update 
      end 
      @sprites["questPreviewClone"].opacity = 0
      @sprites["questPreviewClone"].visible = false
    end 
  end 

  def switchMapMode
    pbPlayDecisionSE
    if @modeCount > 2 && RegionMapSettings::CHANGE_MODE_MENU
      @choiceMode = 0 if !@choiceMode
      avaModes = @modeInfo.values.select { |mode| mode[:condition] }
      choice = pbMessageMap(_INTL("Which mode would you like to switch to?"),
      avaModes.map { |mode| _INTL("#{mode[:text]}") }, -1, nil, @choiceMode, false) { pbUpdate }
      if choice != -1
        @choiceMode = choice
        @mode = avaModes[choice][:mode]
      end 
    else 
      @modeInfo.each do |index, data|
        next if data[:mode] <= @mode 
        if data[:condition]
          @mode = data[:mode]
          break 
        else 
          @mode = 0
        end 
      end 
    end 
    @sprites["modeName"].bitmap.clear 
    @sprites["buttonName"].bitmap.clear
    refreshFlyScreen
  end 

  def pbConfirmMessageMap(message, &block)
    return (pbMessageMap(message, [_INTL("Yes"), _INTL("No")], 2, nil, 0, false, &block) == 0)
  end

  def pbMessageMap(message, commands = nil, cmdIfCancel = 0, skin = nil, defaultCmd = 0, choiceUpdate = true, &block)
    ret = 0
    msgwindow = pbCreateMessageWindow(nil, skin)
    msgwindow.z = 100002
    if commands
      ret = pbMessageDisplay(msgwindow, message, true,
                             proc { |msgwindow|
                               next pbShowCommandsMap(msgwindow, commands, cmdIfCancel, defaultCmd, choiceUpdate, &block)
                             }, &block)
    else
      pbMessageDisplay(msgwindow, message, &block)
    end
    pbDisposeMessageWindow(msgwindow)
    Input.update
    return ret
  end
  
  def pbShowCommandsMap(msgwindow, commands = nil, cmdIfCancel = 0, defaultCmd = 0, choiceUpdate = true)
    return 0 if !commands
    cmdwindow = Window_CommandPokemonEx.new(commands)
    cmdwindow.z = 100002
    cmdwindow.visible = true
    cmdwindow.resizeToFit(cmdwindow.commands)
    pbPositionNearMsgWindow(cmdwindow, msgwindow, :right)
    cmdwindow.index = defaultCmd
    command = 0
    loop do
      Graphics.update
      Input.update
      cmdwindow.update
      if choiceUpdate && RegionMapSettings::AUTO_CURSOR_MOVEMENT && @mode == 1
        @mapX = @visitedMaps[cmdwindow.index][0]
        @mapY = @visitedMaps[cmdwindow.index][1]
        @sprites["cursor"].x = 8 + (@mapX * SQUARE_WIDTH)
        @sprites["cursor"].y = 24 + (@mapY * SQUARE_HEIGHT)
        showAndUpdateMapInfo
        centerMapOnCursor
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
      end
      pbUpdateSceneMap
    end
    ret = command
    cmdwindow.dispose
    Input.update
    return ret
  end

  def pbEndScene
    startFade { pbUpdate }
    $game_system.bgm_restore if RegionMapSettings::CHANGE_MUSIC_IN_REGION_MAP
    pbDisposeSpriteHash(@sprites)
    pbDisposeSpriteHash(@spritesMap)
    @viewport.dispose
    @viewportCursor.dispose 
    @viewportMap.dispose
    stopFade
  end
end
#===============================================================================
# Fly Region Map
#===============================================================================
class PokemonRegionMapScreen
  def pbStartScreen
    @scene.pbStartScene
    ret = @scene.pbMapScene
    @scene.pbEndScene
    return ret
  end
end
#===============================================================================
# Debug menu editor
#===============================================================================
class RegionMapSpritE
  def createRegionMap(map)
    @mapdata = pbLoadTownMapData
    @map = @mapdata[map]
    bitmap = AnimatedBitmap.new("Graphics/Pictures/RegionMap/Regions/#{@map[1]}").deanimate
    retbitmap = BitmapWrapper.new(bitmap.width / 2, bitmap.height / 2)
    retbitmap.stretch_blt(
      Rect.new(0, 0, bitmap.width / 2, bitmap.height / 2),
      bitmap,
      Rect.new(0, 0, bitmap.width, bitmap.height)
    )
    bitmap.dispose
    return retbitmap
  end
end