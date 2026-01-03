#===============================================================================
# UI stuff on loading the Region Map
#===============================================================================
class MapBottomSprite < Sprite
  def initialize(viewport = nil)
    super(viewport)
    @mapname      = ""
    @maplocation  = ""
    @mapdetails   = ""
    @previewName  = ""
    @previewWidth = 0
    self.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    pbSetSystemFont(self.bitmap)
    refresh
  end

  def previewName=(value)
    return if @previewName == value[0]
    @previewName = value[0]
    @previewWidth = value[1] || 0
    refresh
  end

  def refresh
    bitmap.clear
    textpos = [
      [
        @mapname,
        18 + ARMSettings::REGION_NAME_OFFSET_X, 4 + ARMSettings::REGION_NAME_OFFSET_Y, 0,
        ARMSettings::REGION_TEXT_MAIN, ARMSettings::REGION_TEXT_SHADOW
      ],
      [
        @maplocation,
        18 + ARMSettings::LOCATION_NAME_OFFSET_X, (Graphics.height - 24) + ARMSettings::LOCATION_NAME_OFFSET_Y, 0,
        ARMSettings::LOCATION_TEXT_MAIN, ARMSettings::LOCATION_TEXT_SHADOW
      ],
      [
        @mapdetails,
        Graphics.width - (PokemonRegionMap_Scene::UI_BORDER_WIDTH - ARMSettings::POI_NAME_OFFSET_X), (Graphics.height - 24) + ARMSettings::POI_NAME_OFFSET_Y, 1,
        ARMSettings::POI_TEXT_MAIN, ARMSettings::POI_TEXT_SHADOW
      ],
      [
        @previewName,
        Graphics.width - (@previewWidth + PokemonRegionMap_Scene::UI_BORDER_WIDTH + ARMSettings::QUEST_AND_BERRY_NAME_OFFSET_X - 16), 4 + ARMSettings::QUEST_AND_BERRY_NAME_OFFSET_Y, 0,
        ARMSettings::QUEST_AND_BERRY_TEXT_MAIN, ARMSettings::QUEST_AND_BERRY_TEXT_SHADOW
      ]
    ]
    pbDrawTextPositions(bitmap, textpos)
  end
end
#===============================================================================
# The Region Map and everything else it does and can do.
#===============================================================================
class PokemonRegionMap_Scene
  ENGINE20 = Essentials::VERSION.include?("20")
  ENGINE21 = Essentials::VERSION.include?("21")

  QUESTPLUGIN = PluginManager.installed?("Modern Quest System + UI")
  BERRYPLUGIN = PluginManager.installed?("TDW Berry Planting Improvements")
  WEATHERPLUGIN = PluginManager.installed?("Lin's Weather System") && ARMSettings::USE_WEATHER_PREVIEW
  THEMEPLUGIN = PluginManager.installed?("Lin's Pokegear Themes")

  CURSOR_MAP_OFFSET_X = ARMSettings::CURSOR_MAP_OFFSET ? ARMSettings::SQUARE_WIDTH : 0
  CURSOR_MAP_OFFSET_Y = ARMSettings::CURSOR_MAP_OFFSET ? ARMSettings::SQUARE_HEIGHT : 0
  ZERO_POINT_X  = ARMSettings::CURSOR_MAP_OFFSET ? 1 : 0
  ZERO_POINT_Y  = ARMSettings::CURSOR_MAP_OFFSET ? 1 : 0

  REGION_UI = ARMSettings::CHANGE_UI_ON_REGION
  UI_BORDER_WIDTH = 16 # don't edit this
  UI_BORDER_HEIGHT = 32 # don't edit this
  UI_WIDTH = Settings::SCREEN_WIDTH - (UI_BORDER_WIDTH * 2)
  UI_HEIGHT = Settings::SCREEN_HEIGHT - (UI_BORDER_HEIGHT * 2)
  BEHIND_UI = ARMSettings::REGION_MAP_BEHIND_UI ? [0, 0, 0, 0] : [UI_BORDER_WIDTH, (UI_BORDER_WIDTH * 2), UI_BORDER_HEIGHT, (UI_BORDER_HEIGHT * 2)]

  FOLDER = "Graphics/Pictures/RegionMap/" if ENGINE20
  FOLDER = "Graphics/UI/Town Map/" if ENGINE21
  UI_FOLDER = ARMSettings::USE_SPECIAL_UI ? "Special" : "Default"
  SPECIAL_UI = ARMSettings::EXTENDED_MAIN_INFO_FIXED && ARMSettings::USE_SPECIAL_UI && !THEMEPLUGIN

  BOX_BOTTOM_LEFT = ARMSettings::BUTTON_BOX_POSITION == 2
  BOX_BOTTOM_RIGHT = ARMSettings::BUTTON_BOX_POSITION == 4
  BOX_TOP_LEFT = ARMSettings::BUTTON_BOX_POSITION == 1
  BOX_TOP_RIGHT = ARMSettings::BUTTON_BOX_POSITION == 3
  BOX_PREVIEW_DISABLED = ARMSettings::BUTTON_BOX_POSITION.nil?

  REGIONNAMES = MessageTypes::RegionNames if ENGINE20
  REGIONNAMES = MessageTypes::REGION_NAMES if ENGINE21

  LOCATIONNAMES = MessageTypes::PlaceNames if ENGINE20
  LOCATIONNAMES = MessageTypes::REGION_LOCATION_NAMES if ENGINE21

  POINAMES = MessageTypes::PlaceDescriptions if ENGINE20
  POINAMES = MessageTypes::REGION_LOCATION_DESCRIPTIONS if ENGINE21

  SCRIPTTEXTS = MessageTypes::ScriptTexts if ENGINE20
  SCRIPTTEXTS = MessageTypes::SCRIPT_TEXTS if ENGINE21

  def initialize(region = - 1, wallmap = true)
    @region  = region
    @wallmap = wallmap
  end

  def pbStartScene(editor = false, flyMap = false)
    startFade
    @viewport         = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z       = 100001
    @viewportCursor   = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewportCursor.z = 100000
    @viewportMap      = Viewport.new(BEHIND_UI[0], BEHIND_UI[2], (Graphics.width - BEHIND_UI[1]), (Graphics.height - BEHIND_UI[3]))
    @viewportMap.z    = 99999
    @sprites          = {}
    @spritesMap       = {}
    @mapData          = pbLoadTownMapData if ENGINE20
    @flyMap           = flyMap
    @mode             = flyMap ? 1 : 0
    @mapMetadata      = $game_map.metadata
    @playerPos        = (@mapMetadata) ? @mapMetadata.town_map_position : nil
    getPlayerPosition
    @regionName = @map[0] if ENGINE20
    @regionName = @map.name.to_s if ENGINE21
    @regionFile = @map[1] if ENGINE20
    @regionFile = @map.filename if ENGINE21
    if QUESTPLUGIN && $quest_data
      @questMap  = $quest_data.getQuestMapPositions(@map[2], @region) if ENGINE20
      @questMap  = $quest_data.getQuestMapPositions(@map.point, @region) if ENGINE21
    end
    if !@map
      pbMessage(_INTL("The map data cannot be found."))
      return false
    end
    @previewBox = PreviewState.new
    @extendedBox = ExtendedState.new
    @zoomLevel = 1.0
    main
    @playerMapName = !(@playerPos.nil?) ? pbGetMapLocation(@playerPos[1], @playerPos[2]) : ""
  end

  def main
    echoln("#{ARMSettings.constants.size} Settings")
    changeBGM
    addBackgroundAndRegionSprite
    getMapObject
    getFlyIconPositions
    addFlyIconSprites
    addUnvisitedMapSprites
    getCounter
    addCursorSprite
    getZoomLevels
    mapModeSwitchInfo
    showAndUpdateMapInfo
    getExtendedPreview
    addPlayerIconSprite
    addQuestIconSprites
    addBerryIconSprites
    addRoamingIconSprites
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
    if ARMSettings::CENTER_CURSOR_BY_DEFAULT || ARMSettings::SHOW_PLAYER_ON_REGION
      @mapX      = UI_WIDTH % ARMSettings::SQUARE_WIDTH != 0 ? ((UI_WIDTH / 2) + 8) / ARMSettings::SQUARE_WIDTH : (UI_WIDTH / 2) / ARMSettings::SQUARE_WIDTH
      @mapY      = UI_HEIGHT % ARMSettings::SQUARE_HEIGHT != 0 ? ((UI_HEIGHT / 2) + 8) / ARMSettings::SQUARE_HEIGHT : (UI_HEIGHT / 2) / ARMSettings::SQUARE_HEIGHT
    else
      @mapX      = ZERO_POINT_X
      @mapY      = ZERO_POINT_Y
    end
    if !@playerPos
      @region    = 0
      # v20.1.
      @map       = @mapData[0] if ENGINE20
      # v21.1 and above.
      @map       = GameData::TownMap.get(@region) if ENGINE21
    elsif @region >= 0 && @region != @playerPos[0] && ((ENGINE20 && @mapData[@region]) || (ENGINE21 && GameData::TownMap.exists?(@region)))
      # v20.1.
      @map       = @mapData[@region] if ENGINE20
      # v21.1 and above.
      @map       = GameData::TownMap.get(@region) if ENGINE21
    else
      @region    = @playerPos[0]
      # v20.1.
      @map       = @mapData[@playerPos[0]] if ENGINE20
      #v21.1 and above.
      @map       = GameData::TownMap.get(@region) if ENGINE21
      @mapX      = @playerPos[1]
      @mapY      = @playerPos[2]
      ARMSettings::FAKE_REGION_LOCATIONS[$game_map.map_id]&.each do |var, keys|
        keys.each do |value, pos|
          if $game_variables[var] == value
            @region = @playerPos[0] = pos[0]
            @map = @mapData[pos[0]] if ENGINE20
            @map = GameData::TownMap.get(@region) if ENGINE21
            @mapX = @playerPos[1] = pos[1]
            @mapY = @playerPos[2] = pos[2]
          end
        end
      end
      mapsize    = @mapMetadata.town_map_size
      if mapsize && mapsize[0] && mapsize[0] > 0
        sqwidth  = mapsize[0]
        sqheight = (mapsize[1].length.to_f / mapsize[0]).ceil
        @mapX   += ($game_player.x * sqwidth / $game_map.width).floor if sqwidth > 1
        @mapY   += ($game_player.y * sqheight / $game_map.height).floor if sqheight > 1
      end
    end
  end

  def changeBGM
    $game_system.bgm_memorize
    return if !ARMSettings::CHANGE_MUSIC_IN_REGION_MAP
    newBGM = ARMSettings::MUSIC_PER_REGION.find { |region| region[0] == @region }
    return if !newBGM
    newBGM[2] = 100 if !newBGM[2]
    newBGM[3] = 100 if !newBGM[3]
    pbBGMPlay(newBGM[1], newBGM[2], newBGM[3])
  end

  def addBackgroundAndRegionSprite
    @sprites["Background"] = IconSprite.new(0, 0, @viewport)
    @sprites["Background"].setBitmap(findUsableUI("mapBackground"))
    @sprites["Background"].x += (Graphics.width - @sprites["Background"].bitmap.width) / 2
    @sprites["Background"].y += (Graphics.height - @sprites["Background"].bitmap.height) / 2
    @sprites["Background"].z = 30
    if THEMEPLUGIN
      @sprites["BackgroundOver"] = IconSprite.new(0, 0, @viewport)
      @sprites["BackgroundOver"].setBitmap(findUsableUI("mapBackgroundOver"))
      @sprites["BackgroundOver"].x += (Graphics.width - @sprites["BackgroundOver"].bitmap.width) / 2
      @sprites["BackgroundOver"].y += (Graphics.height - @sprites["BackgroundOver"].bitmap.height) / 2
      unless $PokemonSystem.pokegear == "Theme 6"
        @sprites["BackgroundOver"].z = 22
      else
        @sprites["BackgroundOver"].z = 31
      end
    end
    @spritesMap["map"] = IconSprite.new(0, 0, @viewportMap)
    @spritesMap["map"].setBitmap("#{getTimeOfDay}")
    @spritesMap["map"].z = 1
    @mapWidth = @spritesMap["map"].bitmap.width
    @mapHeight = @spritesMap["map"].bitmap.height
    ARMSettings::REGION_MAP_EXTRAS.each do |graphic|
      next if graphic[0] != @region || !locationShown?(graphic)
      if !@spritesMap["map2"]
        @spritesMap["map2"] = BitmapSprite.new(@mapWidth, @mapHeight, @viewportMap)
        @spritesMap["map2"].x = @spritesMap["map"].x
        @spritesMap["map2"].y = @spritesMap["map"].y
        @spritesMap["map2"].z = 6
      end
      pbDrawImagePositions(
        @spritesMap["map2"].bitmap,
        [["#{FOLDER}HiddenRegionMaps/#{graphic[4]}", graphic[2] * ARMSettings::SQUARE_WIDTH, graphic[3] * ARMSettings::SQUARE_HEIGHT]]
      )
    end
    ARMSettings::REGION_MAP_DECORATION.each do |graphic|
      next if graphic[0] != @region || (!graphic[1].nil? && locationShown?(graphic))
      if !@spritesMap["map3"]
        @spritesMap["map3"] = BitmapSprite.new(@mapWidth, @mapHeight, @viewportMap)
        @spritesMap["map3"].x = @spritesMap["map"].x
        @spritesMap["map3"].y = @spritesMap["map"].y
        @spritesMap["map3"].z = 21
      end
      pbDrawImagePositions(
        @spritesMap["map3"].bitmap,
        [["#{FOLDER}Regions/Region Decorations/#{graphic[4]}", graphic[2] * ARMSettings::SQUARE_WIDTH, graphic[3] * ARMSettings::SQUARE_HEIGHT]]
      )
    end
  end

  def findUsableUI(image)
    if THEMEPLUGIN
      # Use Current set Theme's UI Graphics
      return "#{FOLDER}UI/#{$PokemonSystem.pokegear}/#{image}"
    else
      folderUI = "UI/Region#{@region}/"
      bitmap = pbResolveBitmap("#{FOLDER}#{folderUI}#{image}")
      if bitmap && ARMSettings::CHANGE_UI_ON_REGION
        # Use UI Graphics for the Current Region.
        return "#{FOLDER}#{folderUI}#{image}"
      else
        # Use Default UI Graphics.
        return "#{FOLDER}UI/#{UI_FOLDER}/#{image}"
      end
    end
  end

  def getTimeOfDay
    path = "#{FOLDER}Regions/"
    return "#{path}#{@regionFile}" if !ARMSettings::TIME_BASED_REGION_MAP
    if PBDayNight.isDay?
      time = "Day"
    elsif PBDayNight.isNight?
      time = "Night"
    elsif PBDayNight.isMorning?
      time = "Morning"
    elsif PBDayNight.isAfternoon?
      time = "Afternoon"
    elsif PBDayNight.isEvening?
      time = "Evening"
    end
    file = @regionFile.chomp(".png") << time << ".png"
    bitmap = pbResolveBitmap("#{path}#{file}")
    unless bitmap
      case time
      when /Morning|Afternoon|Evening|Night/
        time = "Day"
      else
        Console.echoln_li _INTL("There was no file named '#{file}' found.")
        time = ""
      end
    end
    file = @regionFile.chomp(".png") << time << ".png"
    return "#{path}#{file}"
  end

  def locationShown?(point)
    return (point[5] == nil && point[1] > 0 && $game_switches[point[1]]) || point[5] if @wallmap
    return point[1] > 0 && $game_switches[point[1]]
  end

  def getMapObject
    @mapInfo = {}
    # v20.1.
    @mapPoints = @map[2].map(&:dup).sort_by { |index| [index[2], index[0], index[1]] } if ENGINE20
    # v21.1 and above.
    @mapPoints = @map.point.map(&:dup).sort_by { |index| [index[2], index[0], index[1]] } if ENGINE21
    @mapPoints.each do |mapData|
      # skip locations that are invisible
      next if mapData[7] && (mapData[7] <= 0 || !$game_switches[mapData[7]])
      mapKey = mapData[2].gsub(" ", "").to_sym
      @mapInfo[mapKey] ||= {
        mapname: replaceMapName(mapData[2].clone),
        realname: mapData[2],
        region: @region,
        positions: [],
        flyicons: []
      }
      name = replaceMapPOI(@mapInfo[mapKey][:mapname], mapData[3].clone) if mapData[3]||nil
      position = {
        poiname: name,
        realpoiname: mapData[3],
        x: mapData[0],
        y: mapData[1],
        flyspot: {},
        image: getImagePosition(@mapPoints.clone, mapData.clone),
      }
      unless position[:image].nil?
        existPos = @mapInfo[mapKey][:positions].find { |p| p[:image][:name] == position[:image][:name] } if @mapInfo[mapKey][:positions].any? { |p| p[:image] }
        unless existPos.nil?
          position[:image][:x] = existPos[:image][:x]
          position[:image][:y] = existPos[:image][:y]
        end
      end
      # Add flyspot details
      healSpot = getMapVisited(mapData)
      position[:flyspot] = {
        visited: healSpot,
        map: mapData[4],
        x: mapData[5],
        y: mapData[6]
      } unless healSpot.nil?
      @mapInfo[mapKey][:positions] << position
    end
  end

  def replaceMapName(name)
    return name if !ARMSettings::NO_UNVISITED_MAP_INFO
    repName = ARMSettings::UNVISITED_MAP_TEXT
    oriName = pbGetMessageFromHash(LOCATIONNAMES, name)
    maps = []
    GameData::MapMetadata.each { |gameMap| maps << gameMap if gameMap.name == oriName && (gameMap.announce_location || gameMap.outdoor_map) }
    name = maps.any? { |gameMap| $PokemonGlobal.visitedMaps[gameMap.id] } ? oriName : repName
    return name
  end

  def replaceMapPOI(mapName, poiName)
    return pbGetMessageFromHash(POINAMES, poiName) if poiName == "" || !ARMSettings::NO_UNVISITED_MAP_INFO
    findPOI = ARMSettings::LINK_POI_TO_MAP.keys.find { |key| key.include?(poiName) }
    if findPOI
      poiName = ARMSettings::UNVISITED_POI_TEXT if $PokemonGlobal.visitedMaps[ARMSettings::LINK_POI_TO_MAP[findPOI]].nil?
    else
      poiName = ARMSettings::UNVISITED_POI_TEXT if mapName == ARMSettings::UNVISITED_MAP_TEXT
    end
    return pbGetMessageFromHash(POINAMES, poiName)
  end

  def getMapVisited(mapData)
    healSpot = pbGetHealingSpot(mapData[0], mapData[1])
    if healSpot
      if $PokemonGlobal.visitedMaps[healSpot[0]]
        return true
      else
        return false
      end
    else
      return nil
    end
  end

  def getImagePosition(mapPoints, mapData)
    name = "map#{mapData[8]}"
    if mapData[8].nil?
      #Console.echoln_li _INTL("No Highlight Image defined for point '#{mapData[0]}, #{mapData[1]} - #{mapData[2]}' in PBS file: town_map.txt")
      return
    end
    points = mapPoints.select { |point| point[8] == mapData[8] && point[2] == mapData[2] }.map { |point| point [0..1] }
    x = points.min_by { |xy| xy[0] }[0]
    y = points.min_by { |xy| xy[1] }[1]
    if mapData[8] && !mapData[8].include?("Small") && !mapData[8].include?("Route")
      x -= 1
      y -= 1
    end
    return {name: name, x: x, y: y }
  end

  def getFlyIconPositions
    @mapInfo.each do |key, value|
      selFlySpots = Hash.new { |hash, key| hash[key] = [] }
      value[:positions].each do |pos|
        flySpot = pos[:flyspot]
        next if flySpot.empty?
        key = [flySpot[:map], flySpot[:x], flySpot[:y]]
        selFlySpots[key] << [flySpot, pos[:x], pos[:y]]
      end
      selFlySpots.each do |index, spot|
        visited = visited = spot.any? { |map| map[0][:visited] }
        name = visited ? "mapFly" : "mapFlyDis"
        centerX = spot.map { |map| map[1] }.sum.to_f / spot.length
        centerY = spot.map { |map| map[2] }.sum.to_f / spot.length
        original = spot.map { |map| { x: map[1], y: map[2] } }
        result = [centerX, centerY]
        unless result.nil?
          value[:flyicons] << { name: name, x: result[0], y: result[1], originalpos: original }
        end
      end
    end
  end

  def addFlyIconSprites
    if !@spritesMap["FlyIcons"]
      @spritesMap["FlyIcons"] = BitmapSprite.new(@mapWidth, @mapHeight, @viewportMap)
      @spritesMap["FlyIcons"].x = @spritesMap["map"].x
      @spritesMap["FlyIcons"].y = @spritesMap["map"].y
      @spritesMap["FlyIcons"].visible = @mode == 1
    end
    @spritesMap["FlyIcons"].z = 15
    @mapInfo.each do |key, value|
      value[:flyicons].each do |spot|
        next if spot.nil?
        pbDrawImagePositions(
          @spritesMap["FlyIcons"].bitmap,
          [["#{FOLDER}Icons/Fly/#{spot[:name]}", pointXtoScreenX(spot[:x]), pointYtoScreenY(spot[:y])]]
        )
      end
    end
    @spritesMap["FlyIcons"].visible = @mode == 1
  end

  def pointXtoScreenX(x)
    return ((ARMSettings::SQUARE_WIDTH * x + (ARMSettings::SQUARE_WIDTH / 2)) - 16)
  end

  def pointYtoScreenY(y)
    return ((ARMSettings::SQUARE_HEIGHT * y + (ARMSettings::SQUARE_HEIGHT / 2)) - 16)
  end

  def addUnvisitedMapSprites
    if !@spritesMap["Visited"]
      @spritesMap["Visited"] = BitmapSprite.new(@mapWidth, @mapHeight, @viewportMap)
      @spritesMap["Visited"].x = @spritesMap["map"].x
      @spritesMap["Visited"].y = @spritesMap["map"].y
      @spritesMap["Visited"].z = 10
    end
    curPos = {}
    @mapInfo.each do |key, value|
      value[:positions].each do |pos|
        next if pos[:image].nil?
        # Position has flyspot? Image already drawn (for this location)? Location is visted?
        next if pos[:flyspot].empty? || curPos[:name] == key && curPos[:image] == pos[:image][:name] || pos[:flyspot][:visited]
        curPos = { name: value[:name], image: pos[:image][:name] }
        image = "#{FOLDER}Unvisited/#{pos[:image][:name].to_s}"
        # Image exists?
        if !pbResolveBitmap(image)
          Console.echoln_li _INTL("No Unvisited Image found for point '#{value[:realname]}' in PBS file: town_map.txt")
          next
        end
        pbDrawImagePositions(
          @spritesMap["Visited"].bitmap,
          [[image, (pos[:image][:x].to_i * ARMSettings::SQUARE_WIDTH) , (pos[:image][:y].to_i * ARMSettings::SQUARE_HEIGHT)]]
        )
      end
    end
    curPos.clear
  end

  def getCounter
    @globalCounter = {}
    return if !ARMSettings::PROGRESS_COUNTER
    locations = @mapPoints.map { |mapData| mapData[2] }.uniq
    # separate counter for wild pokemon because different maps can have the same species as another map.
    # They only need to be counted once in a same district.
    wild = Hash.new { |h, k| h[k] = { seen: 0, caught: 0, total: Hash.new(0), map: 0 } }
    # Initialize counters for each district
    gameMaps = { :trainers => {}, :items => {}, :wild => {} }
    districtCounters = Hash.new { |h, k| h[k] = { :progress => 0, :total => 0,
                                                  :maps => { visited: 0, total: 0 },
                                                  :encounters => { pokedex: 0, total: 0 },
                                                  :trainers => { defeated: 0, total: 0 },
                                                  :items => { found: 0, total: 0}
                                                } }
    GameData::MapMetadata.each do |gameMap|
      # check if the gameMap has a town map position and if it's equal to the current region ID.
      next if gameMap.town_map_position.nil? || gameMap.town_map_position[0] != @region
      # get the district name.
      district = getDistrictName(gameMap.town_map_position, @map)
      # get the encounter table for the current gameMap
      encounterData = GameData::Encounter.get(gameMap.id, $PokemonGlobal.encounter_version)
      unless encounterData.nil?
        tally = encounterData.types.values.flatten(1).map { |data| data[1] }.tally
        wild[district][:total].update(tally) { |key, oldVal, newVal| oldVal + newVal }
        gameMaps[:wild][gameMap.id] ||= 0
        gameMaps[:wild][gameMap.id] = tally.length
      end
      # Counting events that have an item
      map = load_data(sprintf("Data/Map%03d.rxdata", gameMap.id))
      items = 0
      trainers = 0
      trainerlist = []
      map.events.each do |event|
        if event[1].name[/item/i]
          next if !ARMSettings::PROGRESS_COUNT_ITEMS
          event[1].pages.each do |page|
            page.list.each do |line|
              # 111 is conditional, 355 is script command.
              next if line.code.nil? || line.code != 111 && line.code != 355
              script = line.code == 111 ? line.parameters[1] : line.parameters[0]
              next if script.nil? || script.is_a?(Numeric) || !(script.include?("pbItemBall") || script.include?("pbReceiveItem") || script.include?("pbGetKeyItem"))
              split = script.split(',').map { |s| s.split(')')[0] }
              number = !(split[1].nil?) ? split[1].to_i : 1
              items += number
            end
          end
        elsif event[1].name[/trainer/i]
          next if !ARMSettings::PROGRESS_COUNT_TRAINERS
          event[1].pages.each do |page|
            page.list.each do |line|
              next if line.code.nil? || line.code != 111
              script = line.parameters[1]
              next if script.nil? || script.is_a?(Numeric) || !(script.include?("TrainerBattle.start"))
              tName = script.split('(').map { |s| s.split(',') }[1][1]
              next if trainerlist.any? { |name, id| name == tName && (event[0] == id || tName.include?("&"))}
              trainerlist << [tName, event[0]]
              trainers += 1
            end
          end
        elsif event[1].name[/wild|static/i]
          next if !ARMSettings::PROGRESS_COUNT_POKEMON
          event[1].pages.each do |page|
            page.list.each do |line|
              next if line.code.nil? || line.code != 355
              script = line.parameters[0]
              next if script.nil? || script.is_a?(Numeric) || !(script.include?("WildBattle.start"))
              split = script.split('(').map { |s| s.split(', ') }
              species = split[1].select { |el| /[A-Z]/.match?(el) }.map! { |sp| sp.gsub(":", "").to_sym }
              wild[district][:total].update(species.tally) { |key, oldVal, newVal| oldVal + newVal }
            end
          end
        end
      end
      gameMaps[:items][gameMap.id] ||= 0
      gameMaps[:items][gameMap.id] += items
      districtCounters[district][:items][:total] += items
      gameMaps[:trainers][gameMap.id] ||= 0
      gameMaps[:trainers][gameMap.id] += trainers
      districtCounters[district][:trainers][:total] += trainers
      # main maps
      map = locations.find { |map| pbGetMessageFromHash(LOCATIONNAMES, map) == gameMap.name && gameMap.outdoor_map }
      # check for POI map if no main map found
      if map.nil?
        findMap = ARMSettings::LINK_POI_TO_MAP.find { |name| gameMap.id == name[1] }
        unless findMap.nil?
          map = GameData::MapMetadata.try_get(findMap[1])
        end
      end
      # skip if there's still no match found
      next if map.nil?
      # Check if the map belongs to any district
      unless district.nil?
        # Update district counters
        next if !ARMSettings::PROGRESS_COUNT_VISITED_LOCATIONS
        districtCounters[district][:maps][:total] += 1
        districtCounters[district][:maps][:visited] += 1 if $PokemonGlobal.visitedMaps[gameMap.id]
      end
    end
    # Wild Encounters
    if ARMSettings::PROGRESS_COUNT_POKEMON
      wild.each do |district, encounters|
        districtCounters[district][:encounters][:total] = encounters[:total].count * 2
        encounters[:total].keys.each do |species|
          districtCounters[district][:encounters][:pokedex] += 1 if $player.seen?(species)
          districtCounters[district][:encounters][:pokedex] += 1 if $player.owned?(species)
        end
      end
    end
    # Create the total count for each district and overall.
    progressCount = totalCount = 0
    districtCounters.each do |district, counters|
      if !$ArckyGlobal.itemTracker.nil?
        districtCounters[district][:items][:found] = $ArckyGlobal.itemTracker[district][:total] if $ArckyGlobal.itemTracker[district]
      end
      if !$ArckyGlobal.trainerTracker.nil?
        districtCounters[district][:trainers][:defeated] = $ArckyGlobal.trainerTracker[district][:total] if $ArckyGlobal.trainerTracker[district]
      end
      total = progress = 0
      counters.each do |key, hash|
        next if key == :gameMap
        next if key == :progress || key == :total
        progress += hash.values[0]
        total += hash[:total]
      end
      districtCounters[district][:progress] = progress
      districtCounters[district][:total] = total
      progressCount += progress
      totalCount += total
    end
    @globalCounter = { progress: progressCount, total: totalCount, districts: districtCounters, gameMaps: gameMaps }
    $ArckyGlobal.globalCounter = convertToRegularHash(@globalCounter)
  end

  def showAndUpdateMapInfo
    if !@sprites["mapbottom"]
      @sprites["mapbottom"] = MapBottomSprite.new(@viewport)
      @sprites["mapbottom"].z = 40
      @lineCount = 2
    end
    getPreviewBox if !@flyMap
    getPreviewWeather if !@flyMap
    @sprites["mapbottom"].mapname = getMapName(@mapX, @mapY)
    @sprites["mapbottom"].maplocation = pbGetMapLocation(@mapX, @mapY)
    @sprites["mapbottom"].mapdetails  = pbGetMapDetails(@mapX, @mapY)
    @sprites["mapbottom"].previewName   = [getPreviewName(@mapX, @mapY), @previewWidth] if @mode == 2 || @mode == 3 || @mode == 4
  end

  def getMapName(x, y)
    district = getDistrictName([@region, x, y], @map)
    if ARMSettings::PROGRESS_COUNTER && !@globalCounter[:districts].empty? && !ARMSettings::DISABLE_PROGRESS_COUNTER_PERCENTAGE
      if (ENGINE20 && district == pbGetMessage(REGIONNAMES, @region)) || (ENGINE21 && district == pbGetMessageFromHash(REGIONNAMES, @map.name.to_s))
        district = "#{district} - #{convertIntegerOrFloat((@globalCounter[:progress].to_f / @globalCounter[:total] * 100).round(1))}%" if @mode == 0
      else
        districtData = @globalCounter[:districts][district]
        district = "#{district} - #{convertIntegerOrFloat((districtData[:progress].to_f / districtData[:total] * 100).round(1))}%" if districtData && districtData[:total] != 0 && @mode == 0
      end
    end
    return district
  end

  def pbGetMapLocation(x, y)
    @curMapLoc = nil
    map = getMapPoints
    return "" if !map
    name = ""
    replaceName = ARMSettings::UNVISITED_MAP_TEXT
    @spritesMap["highlight"].bitmap.clear if @spritesMap["highlight"]
    map.each do |point|
      next if point[0] != x || point[1] != y
      return "" if point[7] && (point[7] <= 0 || !$game_switches[point[7]])
      mapPoint = point[2].gsub(" ", "").to_sym
      if @mapInfo.include?(mapPoint)
        @curMapLoc = @mapInfo[mapPoint][:realname].to_s
        name = @mapInfo[mapPoint][:mapname].to_s
        colorCurrentLocation
      end
    end
    updateButtonInfo(name, replaceName) if !ARMSettings::BUTTON_BOX_POSITION.nil?
    mapModeSwitchInfo if name == "" || (name == replaceName && !ARMSettings::CAN_VIEW_INFO_UNVISITED_MAPS)
    return name
  end

  def pbGetMapDetails(x, y)
    @curPOIname = nil
    map = getMapPoints
    return "" if !map
    map.each do |point|
      next if point[0] != x || point[1] != y
      return "" if !point[3] || (point[7] && (@wallmap || point[7] <= 0 || !$game_switches[point[7]]))
      mapPoint = point[2].gsub(" ", "").to_sym
      @mapInfo[mapPoint][:positions].each do |key, value|
        mapdesc = key[:poiname] if key[:x] == point[0] && key[:y] == point[1]
        @curPOIname = key[:realpoiname]
        return mapdesc if mapdesc
      end
    end
    return ""
  end

  def getMapPoints
    if ENGINE20
      return false if !@map[2]
      return @map[2]
    elsif ENGINE21
      return false if !@map.point
      return @map.point
    end
  end

  def addPlayerIconSprite
    if @playerPos && @region == @playerPos[0]
      if !@spritesMap["player"]
        @spritesMap["player"] = BitmapSprite.new(@mapWidth, @mapHeight, @viewportMap)
        @spritesMap["player"].x = @spritesMap["map"].x
        @spritesMap["player"].y = @spritesMap["map"].y
        @spritesMap["player"].visible = ARMSettings::SHOW_PLAYER_ON_REGION[(@regionName.gsub(' ','')).to_sym]
      end
      @spritesMap["player"].z = 60
      pbDrawImagePositions(
        @spritesMap["player"].bitmap,
        [[GameData::TrainerType.player_map_icon_filename($player.trainer_type), pointXtoScreenX(@mapX) , pointYtoScreenY(@mapY)]]
      )
    end
  end

  def addCursorSprite
    @sprites["cursor"] = AnimatedSprite.create(findUsableUI("mapCursor"), 2, 5)
    @sprites["cursor"].viewport = @viewportCursor
    @sprites["cursor"].x        = (-8 + BEHIND_UI[0]) + ARMSettings::SQUARE_WIDTH * @mapX
    @sprites["cursor"].y        = (-8 + BEHIND_UI[2]) + ARMSettings::SQUARE_HEIGHT * @mapY
    @sprites["cursor"].play
  end

  def mapModeSwitchInfo
    return if @zoom # for v2.7.0
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
    unless @flyMap || @wallmap
      return if !@sprites["modeName"] || !@sprites["buttonName"]
      @modeInfo = {
        :normal => {
          mode: 0,
          text: pbGetMessageFromHash(SCRIPTTEXTS, "#{ARMSettings::MODE_NAMES[:normal]}"),
          condition: true
        },
        :fly => {
          mode: 1,
          text: pbGetMessageFromHash(SCRIPTTEXTS, "#{ARMSettings::MODE_NAMES[:fly]}"),
          condition: pbCanFly? && ((!@playerPos.nil? && @region == @playerPos[0]) || canFlyOtherRegion) && ARMSettings::CAN_FLY_FROM_TOWN_MAP
        },
        :quest => {
          mode: 2,
          text: pbGetMessageFromHash(SCRIPTTEXTS, "#{ARMSettings::MODE_NAMES[:quest]}"),
          condition: QUESTPLUGIN && enableMode(ARMSettings::SHOW_QUEST_ICONS) && !@questMap.empty?
        },
        :berry => {
          mode: 3,
          text: pbGetMessageFromHash(SCRIPTTEXTS, "#{ARMSettings::MODE_NAMES[:berry]}"),
          condition: BERRYPLUGIN && enableMode(ARMSettings::SHOW_BERRY_ICONS) && !pbGetBerriesAtMapPoint(@region).empty?
        },
        :roaming => {
          mode: 4,
          text: pbGetMessageFromHash(SCRIPTTEXTS, "#{ARMSettings::MODE_NAMES[:roaming]}"),
          condition: enableMode(ARMSettings::SHOW_ROAMING_ICONS) && $PokemonGlobal.roamPosition.any? { |roamPos| getActiveRoaming(roamPos) && getRoamingTownMapPos(roamPos) }
        }
      }
      @modeCount = @modeInfo.values.count { |mode| mode[:condition] }
      if @modeCount == 1
        text = ""
        @sprites["modeName"].bitmap.clear
        @sprites["buttonPreview"].visible = false
        return
      end
      text = @modeInfo[:normal][:text]
      @modeInfo.each do |mode, data|
        if data[:mode] == @mode && data[:condition]
          text = data[:text]
          break
        end
      end
    else
      text = ""
      text2 = ""
      @modeCount = 1
    end
    @sprites["mapbottom"].previewName = ["", @previewWidth] if @sprites["mapbottom"]
    updateButtonInfo if !ARMSettings::BUTTON_BOX_POSITION.nil?
    @sprites["modeName"].bitmap.clear
    pbDrawTextPositions(
      @sprites["modeName"].bitmap,
      [[text, Graphics.width - (22 - ARMSettings::MODE_NAME_OFFSET_X), 4 + ARMSettings::MODE_NAME_OFFSET_Y, 1, ARMSettings::MODE_TEXT_MAIN, ARMSettings::MODE_TEXT_SHADOW]]
    )
    @sprites["modeName"].z = 100001
  end

  def canFlyOtherRegion
    @mapName = @playerMapName if !@mapName
    return false if !ARMSettings::ALLOW_FLY_TO_OTHER_REGIONS
    flyRegion = ARMSettings::FLY_TO_REGIONS
    regionName = (@currentRegionName).to_sym
    canFly = flyRegion.key?(regionName) && flyRegion[regionName].include?(@region)
    return true if canFly && ARMSettings::LOCATION_FLY_TO_OTHER_REGION.key?(regionName) && ARMSettings::LOCATION_FLY_TO_OTHER_REGION[regionName].include?(@mapName)
  end

  def getTextPosition
    x = BOX_TOP_LEFT || BOX_BOTTOM_LEFT ? 4 : Graphics.width - (4 + @sprites["buttonPreview"].width)
    y = BOX_TOP_LEFT || BOX_TOP_RIGHT ? 22 : Graphics.height - (22 + @sprites["buttonPreview"].height)
    return x, y
  end

  def enableMode(setting)
    case setting
    when Numeric
      return $game_switches[setting] if setting > 0
    when TrueClass
      return true
    end
    return false
  end

  def centerMapOnCursor
    centerMapX
    centerMapY
    addArrowSprites if !@sprites["upArrow"]
    updateArrows
  end

  def centerMapX
    posX, center = getCenterMapX(@sprites["cursor"].x, true)
    @mapOffsetX = @mapWidth < (Graphics.width - BEHIND_UI[1]) ? ((Graphics.width - BEHIND_UI[1]) - @mapWidth) / 2 : 0
    if center
      @spritesMap.each do |key, value|
        @spritesMap[key].x = posX
      end
    else
      @spritesMap.each do |key, value|
        @spritesMap[key].x = @mapOffsetX
      end
    end
    @sprites["cursor"].x += @spritesMap["map"].x
  end

  def getCenterMapX(cursorX, getCenter = false)
    center = cursorX > (Settings::SCREEN_WIDTH / 2) && ((@mapWidth > Graphics.width && ARMSettings::REGION_MAP_BEHIND_UI) || (@mapWidth > UI_WIDTH && !ARMSettings::REGION_MAP_BEHIND_UI))
    steps = @zoomHash[@zoomIndex][:steps]
    curCorr = @zoomHash[@zoomIndex][:curCorr]
    mapMaxX = -1 * (@mapWidth - UI_WIDTH)
    mapMaxX += UI_BORDER_WIDTH * 2 if ARMSettings::REGION_MAP_BEHIND_UI
    mapPosX = (UI_WIDTH / 2) - cursorX
    pos = mapPosX < mapMaxX ? mapMaxX : mapPosX
    posX = pos % steps != 0 ? pos + curCorr : pos
    if getCenter
      return posX, center
    elsif center
      return posX
    else
      return 0
    end
  end

  def centerMapY
    posY, center = getCenterMapY(@sprites["cursor"].y, true)
    @mapOffsetY = @mapHeight < (Graphics.height - BEHIND_UI[3]) ? ((Graphics.height - BEHIND_UI[3]) - @mapHeight) / 2 : 0
    if center
      @spritesMap.each do |key, value|
        @spritesMap[key].y = posY
      end
    else
      @spritesMap.each do |key, value|
        @spritesMap[key].y = @mapOffsetY
      end
    end
    @sprites["cursor"].y += @spritesMap["map"].y
  end

  def getCenterMapY(cursorY, getCenter = false)
    center = cursorY > (Settings::SCREEN_HEIGHT / 2) && ((@mapHeight > Graphics.height && ARMSettings::REGION_MAP_BEHIND_UI) || (@mapHeight > UI_HEIGHT && !ARMSettings::REGION_MAP_BEHIND_UI))
    steps = @zoomHash[@zoomIndex][:steps]
    curCorr = @zoomHash[@zoomIndex][:curCorr]
    mapMaxY = -1 * (@mapHeight - UI_HEIGHT)
    mapMaxY += UI_BORDER_HEIGHT * 2 if ARMSettings::REGION_MAP_BEHIND_UI
    mapPosY = (UI_HEIGHT / 2) - cursorY
    pos = mapPosY < mapMaxY ? mapMaxY : mapPosY
    posY = pos % steps != 0 ? pos + curCorr : pos
    if getCenter
      return posY, center
    elsif center
      return posY
    else
      return 0
    end
  end

  def addArrowSprites
    @sprites["upArrow"] = AnimatedSprite.new(findUsableUI("mapArrowUp"), 8, 28, 40, 2, @viewport)
    @sprites["upArrow"].x = (Graphics.width / 2) - 14
    @sprites["upArrow"].y = (BOX_TOP_LEFT && (@sprites["buttonPreview"].x + @sprites["buttonPreview"].width) > (Graphics.width / 2)) || (BOX_TOP_RIGHT && @sprites["buttonPreview"].x < (Graphics.width / 2)) ? @sprites["buttonPreview"].height : 16
    @sprites["upArrow"].z = 35
    @sprites["upArrow"].play
    @sprites["downArrow"] = AnimatedSprite.new(findUsableUI("mapArrowDown"), 8, 28, 40, 2, @viewport)
    @sprites["downArrow"].x = (Graphics.width / 2) - 14
    @sprites["downArrow"].y = (BOX_BOTTOM_LEFT && (@sprites["buttonPreview"].x + @sprites["buttonPreview"].width) > (Graphics.width / 2)) || (BOX_BOTTOM_RIGHT && @sprites["buttonPreview"].x < (Graphics.width / 2)) ? (Graphics.height - (44 + @sprites["buttonPreview"].height)) : (Graphics.height - 60)
    @sprites["downArrow"].z = 35
    @sprites["downArrow"].play
    @sprites["leftArrow"] = AnimatedSprite.new(findUsableUI("mapArrowLeft"), 8, 40, 28, 2, @viewport)
    @sprites["leftArrow"].y = (Graphics.height / 2) - 14
    @sprites["leftArrow"].z = 35
    @sprites["leftArrow"].play
    @sprites["rightArrow"] = AnimatedSprite.new(findUsableUI("mapArrowRight"), 8, 40, 28, 2, @viewport)
    @sprites["rightArrow"].x = Graphics.width - 40
    @sprites["rightArrow"].y = (Graphics.height / 2) - 14
    @sprites["rightArrow"].z = 35
    @sprites["rightArrow"].play
  end

  def updateArrows
    @sprites["upArrow"].visible = @spritesMap["map"].y < 0 && !@previewBox.isExtShown
    @sprites["downArrow"].visible = @spritesMap["map"].y > -1 * (@mapHeight - (Graphics.height - BEHIND_UI[3])) && !@previewBox.isExtShown
    @sprites["leftArrow"].visible =  @spritesMap["map"].x < 0 - @cursorCorrZoom && !@previewBox.isExtShown
    @sprites["rightArrow"].visible = @spritesMap["map"].x > -1 * (@mapWidth - (Graphics.width - BEHIND_UI[1])) + @cursorCorrZoom && !@previewBox.isExtShown
  end

  def refreshFlyScreen
    return if @flyMap
    mapModeSwitchInfo
    if @sprites["previewBox"] && @sprites["previewBox"].visible
      hidePreviewBox
    end
    @previewBox.hideIt
    showAndUpdateMapInfo
    getPreviewWeather
    @spritesMap["FlyIcons"].visible = @mode == 1
    @spritesMap["QuestIcons"].visible = @spritesMap["QuestSelect"].visible = @mode == 2 if QUESTPLUGIN && ARMSettings::SHOW_QUEST_ICONS
    @spritesMap["BerryIcons"].visible = @mode == 3 if BERRYPLUGIN && allowShowingBerries
    @spritesMap["RoamingIcons"].visible = @mode == 4 if enableMode(ARMSettings::SHOW_ROAMING_ICONS)
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

  def colorCurrentLocation
    addHighlightSprites if !@spritesMap["highlight"]
    return if @curMapLoc.nil?
    curPos = @curMapLoc.gsub(" ", "").to_sym
    highlight = @mapInfo[curPos][:positions].find { |pos| pos[:x] == @mapX && pos[:y] == @mapY}
    return if highlight.nil? || (highlight[:image].nil? && @mode != 1)
    if @mode != 1
      image = highlight[:image]
      mapFolder = getMapFolderName(image)
      imageName = "#{FOLDER}highlights/#{mapFolder}/#{image[:name]}"
      if !pbResolveBitmap(imageName)
        Console.echoln_li _INTL("No Higlight Image found for point '#{@mapInfo[curPos][:realname].to_s}' in PBS file: town_map.txt")
        return
      end
      pbDrawImagePositions(
        @spritesMap["highlight"].bitmap,
        [["#{FOLDER}highlights/#{mapFolder}/#{image[:name]}", (image[:x] * ARMSettings::SQUARE_WIDTH) , (image[:y] * ARMSettings::SQUARE_HEIGHT)]]
      )
    else
      flyicon = @mapInfo[curPos][:flyicons].find { |icon| icon[:originalpos].any? { |pos| pos[:x] == highlight[:x] && pos[:y] == highlight[:y] } }
      return if flyicon.nil? || flyicon[:name] == "mapFlyDis"
      pbDrawImagePositions(
        @spritesMap["highlight"].bitmap,
        [["#{FOLDER}Icons/Fly/MapFlySel", (flyicon[:x] * ARMSettings::SQUARE_WIDTH) - 8 , (flyicon[:y] * ARMSettings::SQUARE_HEIGHT) - 8]]
      )
    end
  end

  def addHighlightSprites
    @spritesMap["highlight"] = BitmapSprite.new(@mapWidth, @mapHeight, @viewportMap)
    @spritesMap["highlight"].x = @spritesMap["map"].x
    @spritesMap["highlight"].y = @spritesMap["map"].y
    @spritesMap["highlight"].opacity = convertOpacity(ARMSettings::HIGHLIGHT_OPACITY)
    @spritesMap["highlight"].visible = true
    @spritesMap["highlight"].z = 20
  end

  def getMapFolderName(image)
    name = image[:name]
    case name
    when /Route/
      mapFolder = "Routes"
    else
      mapFolder = "Others"
    end
    return mapFolder
  end

  def pbMapScene
    cursor = createObject
    map    = createObject
    opacityBox = convertOpacity(ARMSettings::BUTTON_BOX_OPACITY)
    choice   = nil
    lastChoiceLocation = 0
    lastChoiceFly = 0
    lastChoiceQuest = 0
    lastChoiceBerries = 0
    @zoom = false # for v2.7.0
    @limitCursor = @zoomHash[@zoomIndex][:limits]
    updateMapRange
    @distPerFrame = 8 * 20 / Graphics.frame_rate if ENGINE20
    @distPerFrame = System.uptime if ENGINE21
    @uiWidth = @mapWidth < UI_WIDTH ? @mapWidth : UI_WIDTH
    @uiHeight = @mapHeight < UI_HEIGHT ? @mapHeight : UI_HEIGHT
    loop do
      Graphics.update
      Input.update
      pbUpdate
      @timer += 1 if @timer
      toggleButtonBox(opacityBox) if @modeCount >= 2
      updateButtonInfo if @previewBox.isShown && !ARMSettings::BUTTON_BOX_POSITION.nil?
      hidePreviewBox if @previewBox.canHide
      if @zoomTriggered
        @sprites["cursor"].x = lerp(@ZoomValues[:begin][:cursor][:x], @ZoomValues[:end][:cursor][:x], @zoomSpeed, @distPerFrame, System.uptime)
        @sprites["cursor"].y = lerp(@ZoomValues[:begin][:cursor][:y], @ZoomValues[:end][:cursor][:y], @zoomSpeed, @distPerFrame, System.uptime)
        @spritesMap.each do |key, value|
          @spritesMap[key].zoom_x = @spritesMap[key].zoom_y = lerp(@ZoomValues[:begin][:map][:zoom], @ZoomValues[:end][:map][:zoom], @zoomSpeed, @distPerFrame, System.uptime)
          @spritesMap[key].x = lerp(@ZoomValues[:begin][:map][:x], @ZoomValues[:end][:map][:x], @zoomSpeed, @distPerFrame, System.uptime)
          @spritesMap[key].y = lerp(@ZoomValues[:begin][:map][:y], @ZoomValues[:end][:map][:y], @zoomSpeed, @distPerFrame, System.uptime)
        end
        @sprites["cursor"].zoom_x = @sprites["cursor"].zoom_y = lerp(@ZoomValues[:begin][:cursor][:zoom], @ZoomValues[:end][:cursor][:zoom], @zoomSpeed, @distPerFrame, System.uptime)
        Graphics.update
        if @sprites["cursor"].zoom_x == @ZoomValues[:end][:cursor][:zoom]
          updateMapRange
          updateButtonInfo
          @zoomTriggered = false
        end
        next
      end
      if cursor[:offsetX] != 0 || cursor[:offsetY] != 0
        updateCursor(cursor)
        updateMap(map) if map[:offsetX] != 0 || map[:offsetY] != 0
        next if cursor[:offsetX] != 0 || cursor[:offsetY] != 0
      end
      if map[:offsetX] != 0 || map[:offsetY] != 0
        updateMap(map)
        next if map[:offsetX] != 0 || map[:offsetY] != 0
      end
      if cursor[:offsetX] == 0 && cursor[:offsetY] == 0 && choice && choice.is_a?(Integer) && choice >= 0
        inputFly = true if @mode == 1
        lastChoiceLocation = choice if @mode == 0
        lastChoiceFly = choice if @mode == 1
        lastChoiceQuest = choice if @mode == 2
        lastChoiceBerries = choice if @mode == 3
        choice = nil
      end
      # for v2.7.0
      if Input.trigger?(Input::CTRL) && @mode == 0 && !ENGINE20 && ARMSettings::USE_REGION_MAP_ZOOM
        if !@zoom
          @zoom = true
          @sprites["modeName"].bitmap.clear
          pbDrawTextPositions(
            @sprites["modeName"].bitmap,
            [["Zoom Mode", Graphics.width - (22 - ARMSettings::MODE_NAME_OFFSET_X), 4 + ARMSettings::MODE_NAME_OFFSET_Y, 1, ARMSettings::MODE_TEXT_MAIN, ARMSettings::MODE_TEXT_SHADOW]]
          )
        else
          @zoom = false
          @zoomIndex = 1
          @zoomTriggered = true
          getZoomValues
          next
        end
      elsif @zoom && !ENGINE20
        if Input.trigger?(Input::JUMPUP) && (@zoomIndex != 0 && @zoomHash[@zoomIndex - 1][:enabled]) # zoom in
          @zoomIndex -= 1
          @zoomTriggered = true
        elsif Input.trigger?(Input::JUMPDOWN) && (@zoomIndex != @zoomHash.length - 1 && @zoomHash[@zoomIndex + 1][:enabled]) # zoom out
          @zoomIndex += 1
          @zoomTriggered = true
        end
        if @zoomTriggered
          getZoomValues
          next
        end
      end
      updateArrows
      ox, oy, mox, moy = 0, 0, 0, 0
      cursor[:oldX] = @mapX
      cursor[:oldY] = @mapY
      ox, oy, mox, moy = getDirectionInput(ox, oy, mox, moy)
      ox, oy, mox, moy, lastChoiceQuest, lastChoiceBerries = getMouseInput(ox, oy, mox, moy, lastChoiceQuest, lastChoiceBerries)
      choice = canSearchLocation(lastChoiceLocation, cursor) if @mode == 0
      choice = canActivateQuickFly(lastChoiceFly, cursor) if @mode == 1
      updateCursorPosition(ox, oy, cursor) if ox != 0 || oy != 0
      updateMapPosition(mox, moy, map) if mox != 0 || moy != 0
      updatePreviewBox if @previewBox.canUpdate && (@mapX != cursor[:oldX] || @mapY != cursor[:oldY])
      showAndUpdateMapInfo if (@mapX != cursor[:oldX] || @mapY != cursor[:oldY]) || @previewBox.isHidden
      if !@wallmap
        if (Input.trigger?(ARMSettings::SHOW_LOCATION_BUTTON) && @mode == 0 && ARMSettings::USE_LOCATION_PREVIEW) && getLocationInfo && !@previewBox.isShown
          pbPlayDecisionSE
          @previewBox.showIt
          showPreviewBox
        elsif Input.trigger?(ARMSettings::SHOW_EXTENDED_BUTTON) && @previewBox.isShown && !@cannotExtPreview && @mode == 0 && ARMSettings::PROGRESS_COUNTER
          pbPlayDecisionSE
          showExtendedPreview
        elsif ((Input.trigger?(Input::USE) || Input.trigger?(ARMSettings::MOUSE_BUTTON_SELECT_LOCATION)) && @mode == 1) || inputFly
          return @healspot if getFlyLocationAndConfirm { pbUpdate }
        elsif Input.trigger?(ARMSettings::SHOW_QUEST_BUTTON) && QUESTPLUGIN && @mode == 2
          @ChangeQuestIcon = true
          choice = showQuestInformation(lastChoiceQuest)
          showPreviewBox if choice != -1
        elsif Input.trigger?(ARMSettings::CHANGE_MODE_BUTTON) && !@flyMap && @modeCount >= 2 && !@zoom
          @ChangeQuestIcon = false if @mode == 2
          switchMapMode
        elsif Input.trigger?(ARMSettings::CHANGE_REGION_BUTTON) && @previewBox.isHidden && ((ENGINE20 && @mapData.length >= 2) || (ENGINE21 && GameData::TownMap.count >= 2)) && !@flyMap && !@zoom
          @ChangeQuestIcon = false if @mode == 2
          switchRegionMap
        elsif Input.trigger?(ARMSettings::SHOW_BERRY_BUTTON) && BERRYPLUGIN && @mode == 3
          choice = showBerryInformation(lastChoiceBerries)
          showPreviewBox if choice != -1
        end
      end
      if Input.trigger?(Input::BACK)
        if @previewBox.isShown || @previewBox.isUpdated
          @previewBox.hideIt
          next
        elsif @previewBox.isExtHidden
          @previewBox.shown
          next
        else
          break
        end
      end
    end
    pbPlayCloseMenuSE
    return nil
  end

  def getZoomLevels
    @zoomIndex = 1
    offset = ARMSettings::CURSOR_MAP_OFFSET ? 1 : 0
    @zoomHash = {
      0 => {
        :enabled => !((@mapWidth < UI_WIDTH) || (@mapHeight < UI_HEIGHT)),
        :level => 0.5, #steps 32px
        :steps => 32,
        :curCorr => 16,
        :limits => createCursorLimitObject(32, 16, 0.5),
        :map => {
          :minX => (UI_BORDER_WIDTH.to_f / 32).ceil + offset,
          :maxX => ((@mapWidth / 16) - 1) - (UI_BORDER_WIDTH.to_f / 32).ceil - offset,
          :minY => (UI_BORDER_HEIGHT.to_f / 32).ceil + offset,
          :maxY => ((@mapHeight / 16) - 1) - (UI_BORDER_HEIGHT.to_f / 32).ceil - offset
        }
      },
      1 => {
        :enabled => true,
        :level => 1.0, #steps 16px
        :steps => 16,
        :curCorr => 8,
        :limits => createCursorLimitObject(16, 8, 1.0),
        :map => {
          :minX => (UI_BORDER_WIDTH.to_f / 16).ceil + offset,
          :maxX => ((@mapWidth / 16) - 1) - (UI_BORDER_WIDTH.to_f / 16).ceil - offset,
          :minY => (UI_BORDER_HEIGHT.to_f / 16).ceil + offset,
          :maxY => ((@mapHeight / 16) - 1) - (UI_BORDER_HEIGHT.to_f / 16).ceil - offset
        }
      },
      2 => {
        :enabled => (@mapWidth >= UI_WIDTH * 2.0) && (@mapHeight >= UI_HEIGHT * 2.0),
        :level => 2.0, #steps 8px
        :steps => 8,
        :curCorr => 4,
        :limits => createCursorLimitObject(8, 4, 2.0),
        :map => {
          :minX => (UI_BORDER_WIDTH.to_f / 8).ceil + offset,
          :maxX => ((@mapWidth / 16) - 1) - (UI_BORDER_WIDTH.to_f / 8).ceil - offset,
          :minY => (UI_BORDER_HEIGHT.to_f / 8).ceil + offset,
          :maxY => ((@mapHeight / 16) - 1) - (UI_BORDER_HEIGHT.to_f / 8).ceil - offset
        }
      },
    }
    @cursorCorrZoom = @zoomHash[@zoomIndex][:level] == 0.5 && ARMSettings::REGION_MAP_BEHIND_UI ? @zoomHash[@zoomIndex][:steps] / 2 : 0
  end

  def getZoomValues
    @limitCursor = @zoomHash[@zoomIndex][:limits]
    @cursorCorrZoom = @zoomHash[@zoomIndex][:level] == 0.5 && ARMSettings::REGION_MAP_BEHIND_UI ? @zoomHash[@zoomIndex][:steps] / 2 : 0
    if ARMSettings::REGION_MAP_BEHIND_UI
      if @mapX < @zoomHash[@zoomIndex][:map][:minX]
        @mapX = @zoomHash[@zoomIndex][:map][:minX]
      elsif @mapX > @zoomHash[@zoomIndex][:map][:maxX]
        @mapX = @zoomHash[@zoomIndex][:map][:maxX]
      end
      if @mapY < @zoomHash[@zoomIndex][:map][:minY]
        @mapY = @zoomHash[@zoomIndex][:map][:minY]
      elsif @mapY > @zoomHash[@zoomIndex][:map][:maxY]
        @mapY = @zoomHash[@zoomIndex][:map][:maxY]
      end
    end
    @mapWidth = @spritesMap["map"].bitmap.width
    @mapHeight = @spritesMap["map"].bitmap.height
    @mapWidth /= @zoomHash[@zoomIndex][:level]
    @mapHeight /= @zoomHash[@zoomIndex][:level]
    @zoomLevel = 1.to_f / @zoomHash[@zoomIndex][:level]
    steps = @zoomHash[@zoomIndex][:steps]
    curCorr = @zoomHash[@zoomIndex][:curCorr]
    cursorX = ((-curCorr + BEHIND_UI[0]) + steps * @mapX)
    cursorY = ((-curCorr + BEHIND_UI[2]) + steps * @mapY)
    posX = getCenterMapX(cursorX)
    posY = getCenterMapY(cursorY)
    @ZoomValues = {
      :begin => {
        :cursor => {
          :x => @sprites["cursor"].x,
          :y => @sprites["cursor"].y,
          :zoom => @sprites["cursor"].zoom_x
        },
        :map => {
          :zoom => @spritesMap["map"].zoom_x,
          :x => @spritesMap["map"].x,
          :y => @spritesMap["map"].y
        }
      },
      :end => {
        :cursor => {
          :x => cursorX - @cursorCorrZoom + posX,
          :y => cursorY + posY,
          :zoom => @zoomLevel
        },
        :map => {
          :zoom => @zoomLevel,
          :x => posX - @cursorCorrZoom,
          :y => posY
        }
      }
    }
    mapModeSwitchInfo
    @zoomSpeed = ARMSettings::ZOOM_SPEED.to_f / 500
    @distPerFrame = System.uptime
  end

  def getMouseInput(ox, oy, mox, moy, lastChoiceQuest, lastChoiceBerries)
    return if !ARMSettings::USE_MOUSE_ON_REGION_MAP
    mousePos = Mouse.getMousePos
    if mousePos
      convertMouseToMapPos(mousePos)
      @oldPosX ||= mousePos[0]
      @oldPosY ||= mousePos[1]
      if mousePos.none? { |pos| pos < 0 } #checks if the mouse position is not negative.
        if Input.press?(ARMSettings::MOUSE_BUTTON_MOVE_MAP)
          if @previewBox.isShown || @previewBox.isUpdated
            @previewBox.hideIt
          elsif @previewBox.isExtHidden
            @previewBox.showIt
          else
            if mousePos[0] < @oldPosX
              mox = -1 if @spritesMap["map"].x > -1 * (@mapWidth - (Graphics.width - BEHIND_UI[1])) + @cursorCorrZoom
              ox = -1 if @sprites["cursor"].x > @limitCursor[:minX] && mox == -1
            elsif mousePos[0] > @oldPosX
              mox = 1 if @spritesMap["map"].x < 0 - @cursorCorrZoom
              ox = 1 if @sprites["cursor"].x < @limitCursor[:maxX] && mox == 1
            end
            if mousePos[1] < @oldPosY
              moy = -1 if @spritesMap["map"].y > -1 * (@mapHeight - (Graphics.height - BEHIND_UI[3]))
              oy = -1  if @sprites["cursor"].y > @limitCursor[:minY] && moy == -1
            elsif mousePos[1] > @oldPosY
              moy = 1 if @spritesMap["map"].y < 0
              oy = 1  if @sprites["cursor"].y < @limitCursor[:maxY] && moy == 1
            end
          end
        elsif Input.trigger?(ARMSettings::MOUSE_BUTTON_SELECT_LOCATION)
          if !(mousePos[0] == @mapX && mousePos[1] == @mapY)
            if !mousePos[0].between?(@mapRange[:minX], @mapRange[:maxX])
              if mousePos[0] < @mapRange[:minX]
                mousePos[0] = @mapRange[:minX]
              elsif mousePos[0] > @mapRange[:maxX]
                mousePos[0] = @mapRange[:maxX]
              end
            end
            if !mousePos[1].between?(@mapRange[:minY], @mapRange[:maxY])
              if mousePos[1] < @mapRange[:minY]
                mousePos[1] = @mapRange[:minY]
              elsif mousePos[1] > @mapRange[:maxY]
                mousePos[1] = @mapRange[:maxY]
              end
            end
            @mapX = mousePos[0]
            @mapY = mousePos[1]
            @sprites["cursor"].x = (8 +(@mapX * (ARMSettings::SQUARE_WIDTH * @zoomLevel))) + @spritesMap["map"].x
            @sprites["cursor"].x -= UI_BORDER_WIDTH if ARMSettings::REGION_MAP_BEHIND_UI
            @sprites["cursor"].x -= 8 if @zoomLevel == 2.0
            @sprites["cursor"].x += 4 if @zoomLevel == 0.5
            @sprites["cursor"].y = (24 + (@mapY * (ARMSettings::SQUARE_HEIGHT * @zoomLevel))) + @spritesMap["map"].y
            @sprites["cursor"].y -= UI_BORDER_HEIGHT if ARMSettings::REGION_MAP_BEHIND_UI
            @sprites["cursor"].y -= 8 if @zoomLevel == 2.0
            @sprites["cursor"].y += 4 if @zoomLevel == 0.5
            if @previewBox.isShown
              @previewBox.updateIt
            end
          else
            case @mode
            when 0
              if ARMSettings::USE_LOCATION_PREVIEW && getLocationInfo
                if @previewBox.isShown && !@cannotExtPreview
                  showExtendedPreview
                else
                  @previewBox.showIt
                  showPreviewBox
                end
              end
            when 2
              if QUESTPLUGIN
                choice = showQuestInformation(lastChoiceQuest)
                if choice != -1
                  showPreviewBox
                  lastChoiceQuest = choice
                end
              end
            when 3
              if BERRYPLUGIN
                choice = showBerryInformation(lastChoiceBerries)
                if choice != -1
                  showPreviewBox
                  lastChoiceBerries = choice
                end
              end
            end
          end
        end
      end
      @oldPosX = mousePos[0] if mox == 0
      @oldPosY = mousePos[1] if moy == 0
    end
    return ox, oy, mox, moy, lastChoiceQuest, lastChoiceBerries
  end

  def convertMouseToMapPos(mousePos)
    mousePos[0] -= @spritesMap["map"].x
    mousePos[0] -= UI_BORDER_WIDTH if !ARMSettings::REGION_MAP_BEHIND_UI
    mousePos[1] -= @spritesMap["map"].y
    mousePos[1] -= UI_BORDER_HEIGHT if !ARMSettings::REGION_MAP_BEHIND_UI
    mousePos[0] /= (SQUARE_WIDTH * @zoomLevel).round
    mousePos[1] /= (SQUARE_HEIGHT * @zoomLevel).round
    return mousePos
  end

  def canSearchLocation(lastChoiceLocation, cursor)
    @listMaps = getAllLocations
    return if @listMaps.empty? || (@listMaps.length + 1) <= ARMSettings::MINIMUM_MAPS_COUNT
    if enableMode(ARMSettings::CAN_LOCATION_SEARCH) && Input.trigger?(ARMSettings::LOCATION_SEARCH_BUTTON) && @previewBox.isHidden
      match = ARMSettings::LINK_POI_TO_MAP.find { |_,poi| poi == $game_map.map_id }
      findChoice = @listMaps.find_index { |map| match[0] == map[:name] } if !match.nil?
      findChoice = @listMaps.find_index { |map| @curMapLoc == map[:name] } if !findChoice
      lastChoiceLocation = findChoice if findChoice
      @searchActive = true
      updateButtonInfo if !ARMSettings::BUTTON_BOX_POSITION.nil?
      choice = messageMap(_INTL("Choose a Location (press #{convertButtonToString(ARMSettings::ORDER_SEARCH_BUTTON)} to order the list.)"),
        @listMaps.map { |mapData| mapData[:name] }, -1, nil, lastChoiceLocation, true) { pbUpdate }
      if $resultWindow
        $resultWindow.dispose
        $resultWindow = nil
      end
      if choice.is_a?(String)
        @listMaps = updateLocationList(choice)
      elsif choice.is_a?(Integer)
        if choice != -1
          @mapX = @listMaps[choice][:pos][:x]
          @mapY = @listMaps[choice][:pos][:y]
        else
          @mapX = cursor[:oldX]
          @mapY = cursor[:oldY]
        end
        @sprites["cursor"].x = 8 + (@mapX * ARMSettings::SQUARE_WIDTH)
        @sprites["cursor"].y = 24 + (@mapY * ARMSettings::SQUARE_HEIGHT)
        @sprites["cursor"].x -= UI_BORDER_WIDTH if ARMSettings::REGION_MAP_BEHIND_UI
        @sprites["cursor"].y -= UI_BORDER_HEIGHT if ARMSettings::REGION_MAP_BEHIND_UI
        pbGetMapLocation(@mapX, @mapY)
        centerMapOnCursor
      end
      @searchActive = false
    end
    return choice
  end

  def getAllLocations
    listMaps = []
    unvisited = ARMSettings::INCLUDE_UNVISITED_MAPS
    @mapInfo.each do |_, map|
      usename = unvisited ? "realpoiname" : "poiname"
      poinames = map[:positions].map { |pos| pos[usename.to_sym] }
      next if map[:mapname] == ARMSettings::UNVISITED_MAP_TEXT && !unvisited
      pos = map[:positions][0]
      usename = unvisited ? "realname" : "mapname"
      listMaps << {name: map[usename.to_sym], :pos => {region: map[:region], x: pos[:x], y: pos[:y] } }
      poiMaps = []
      poinames.each_with_index do |name, index|
        next if (name == ARMSettings::UNVISITED_POI_TEXT && !unvisited) || name.nil? || name == "" || poiMaps.any? { |map| map[:name] == name }
        pos = map[:positions][index]
        poiMaps << {name: name, :pos => {region: map[:region], x: pos[:x], y: pos[:y] } }
      end
      listMaps += poiMaps
    end
    return listMaps
  end

  def updateLocationList(term)
    return getAllLocations if term == ""
    @termList = [] if !@termList
    @termList << term
    filtered = @listMaps.select do |location|
      location[:name].downcase.include?(term.downcase)
    end
    if filtered.empty?
      filtered = @listMaps
      text = "No results"
    else
      word = filtered.length > 1 ? "results" : "result"
      text = "#{filtered.length} #{word}"
    end
    unless text == ""
      $resultWindow = Window_AdvancedTextPokemon.new(_INTL(text))
      $resultWindow.resizeToFit($resultWindow.text, Graphics.width)
      $resultWindow.z = 100003
    end
    return filtered
  end

  def switchRegionMap
    getAvailableRegions if !@avRegions
    @avRegions = @avRegions.sort_by { |index| index[1] }
    if @avRegions.length >= 3
      choice = messageMap(_INTL("Which Region would you like to change to?"),
        @avRegions.map { |mode| "#{mode[0]}" }, -1, nil, @region) { pbUpdate }
      return if choice == -1 || @region == @avRegions[choice][1]
      @region = @avRegions[choice][1]
    else
      return if @avRegions.length == 1
      @region = @avRegions[0][1] == @region ? @avRegions[1][1] : @avRegions[0][1]
    end
    @currentRegionName = @regionName
    @choiceMode = 0
    refreshRegionMap
  end

  def getAvailableRegions
    map = []
    GameData::MapMetadata.each do |gameMap|
      next if gameMap.town_map_position.nil?
      map << [gameMap.id, gameMap.real_name, gameMap.town_map_position] if $PokemonGlobal.visitedMaps[gameMap.id]
    end
    @avRegions = []
    map.each do |id, name, region|
      name = pbGetMessage(MessageTypes::RegionNames, region[0]) if ENGINE20
      if ENGINE21 && GameData::TownMap.exists?(region[0])
        name = GameData::TownMap.get(region[0]).name
      elsif ENGINE21 || (ENGINE20 && name == "")
        Console.echoln_li _INTL("Game map: #{id}, #{name}: MapPosition = #{region[0]},#{region[1]},#{region[2]} => #{region[0]} is not a valid Region ID.")
        next
      end
      next if @avRegions.include?([name, region[0]])
      @avRegions << [pbGetMessageFromHash(SCRIPTTEXTS, name), region[0]]
    end
  end

  def refreshRegionMap
    startFade {pbUpdate}
    pbDisposeSpriteHash(@sprites)
    pbDisposeSpriteHash(@spritesMap)
    @viewport.dispose
    @viewportCursor.dispose
    @viewportMap.dispose
    pbStartScene
    # Recalculate the UI sizes and cursor limits
    @uiWidth = @mapWidth < UI_WIDTH ? @mapWidth : UI_WIDTH
    @uiHeight = @mapHeight < UI_HEIGHT ? @mapHeight : UI_HEIGHT
    @limitCursor = createCursorLimitObject(16, 8)
  end

  def toggleButtonBox(opacityBox)
    box = createBoxObject
    if (@sprites["cursor"].x.between?(box[:startX], box[:endX]) && @sprites["cursor"].y.between?(box[:startY], box[:endY])) && @sprites["buttonName"].opacity != opacityBox
      if ENGINE20
        @sprites["buttonPreview"].opacity -= (255 - opacityBox) / @distPerFrame
        @sprites["buttonName"].opacity -= (255 - opacityBox) / @distPerFrame
      elsif ENGINE21
        @sprites["buttonPreview"].opacity = lerp(@sprites["buttonPreview"].opacity, opacityBox, 0.5, @distPerFrame, System.uptime)
        @sprites["buttonName"].opacity = lerp(@sprites["buttonName"].opacity, opacityBox, 0.5, @distPerFrame, System.uptime)
      end
    elsif !(@sprites["cursor"].x.between?(box[:startX], box[:endX]) && @sprites["cursor"].y.between?(box[:startY], box[:endY])) && @sprites["buttonName"].opacity != 255
      if ENGINE20
        @sprites["buttonPreview"].opacity += (255 - opacityBox) / @distPerFrame
        @sprites["buttonName"].opacity += (255 - opacityBox) / @distPerFrame
      elsif ENGINE21
        @sprites["buttonPreview"].opacity = lerp(@sprites["buttonPreview"].opacity, 255, 0.5, @distPerFrame, System.uptime)
        @sprites["buttonName"].opacity = lerp(@sprites["buttonName"].opacity, 255, 0.5, @distPerFrame, System.uptime)
      end
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

  def createCursorLimitObject(offset, curCorr, level = 1.0)
    cursorOffset = ARMSettings::CURSOR_MAP_OFFSET ? offset : 0
    width = @sprites["cursor"].bitmap.width / level # 64, 32, 16
    height = @sprites["cursor"].bitmap.height / level # 64, 32, 16
    @mapOffsetX = 0 if @mapOffsetX.nil?
    @mapOffsetY = 0 if @mapOffsetY.nil?
    minX =  if !ARMSettings::REGION_MAP_BEHIND_UI
              (UI_BORDER_WIDTH + @mapOffsetX + cursorOffset) - curCorr # ok
            else
              if @mapWidth > UI_WIDTH
                (UI_BORDER_WIDTH + cursorOffset) - curCorr # ok
              else
                @mapOffsetX + cursorOffset
              end
            end
    maxX =  if !ARMSettings::REGION_MAP_BEHIND_UI
              (UI_WIDTH + UI_BORDER_WIDTH) - ((width / 2) + @mapOffsetX + cursorOffset)
            else
              if @mapWidth > UI_WIDTH
                (UI_WIDTH + UI_BORDER_WIDTH) - ((width / 2) + cursorOffset)
              else
                UI_WIDTH - (@mapOffsetX + cursorOffset)
              end
            end
    minY = if !ARMSettings::REGION_MAP_BEHIND_UI
              (UI_BORDER_HEIGHT + @mapOffsetY + cursorOffset) - curCorr
            else
              if @mapHeight > UI_HEIGHT
                (UI_BORDER_HEIGHT + cursorOffset) - curCorr
              else
                @mapOffsetY + cursorOffset
              end
            end
    maxY = if !ARMSettings::REGION_MAP_BEHIND_UI
              (UI_HEIGHT + UI_BORDER_HEIGHT) - (height + @mapOffsetY + cursorOffset)
            else
              if @mapHeight > UI_HEIGHT
                (UI_HEIGHT + UI_BORDER_HEIGHT) - (height + cursorOffset)
              else
                (UI_HEIGHT + UI_BORDER_HEIGHT) - (@mapOffsetY + cursorOffset)
              end
            end
    return {
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY
    }
  end

  def createBoxObject
    object = {
      startX: (@sprites["buttonPreview"].x - (ARMSettings::SQUARE_WIDTH * @zoomLevel) + (8 * @zoomLevel)) / (ARMSettings::SQUARE_WIDTH * @zoomLevel) * (ARMSettings::SQUARE_WIDTH * @zoomLevel),
      endX: (((@sprites["buttonPreview"].x - (ARMSettings::SQUARE_WIDTH * @zoomLevel)) + @sprites["buttonPreview"].width) + (8 * @zoomLevel)) / (ARMSettings::SQUARE_WIDTH * @zoomLevel) * (ARMSettings::SQUARE_WIDTH * @zoomLevel),
      startY: (@sprites["buttonPreview"].y - (ARMSettings::SQUARE_HEIGHT * @zoomLevel)) / (ARMSettings::SQUARE_HEIGHT * @zoomLevel) * (ARMSettings::SQUARE_HEIGHT * @zoomLevel),
      endY: (((@sprites["buttonPreview"].y + @sprites["buttonPreview"].height) - (ARMSettings::SQUARE_HEIGHT * @zoomLevel)) + (8 * @zoomLevel)) / ((ARMSettings::SQUARE_HEIGHT * @zoomLevel) / 2) * ((ARMSettings::SQUARE_HEIGHT * @zoomLevel) / 2)
    }
    return object
  end

  def updateCursor(cursor)
    if ENGINE20
      cursor[:offsetX] += (cursor[:offsetX] > 0) ? -@distPerFrame : (cursor[:offsetX] < 0) ? @distPerFrame : 0
      cursor[:offsetY] += (cursor[:offsetY] > 0) ? -@distPerFrame : (cursor[:offsetY] < 0) ? @distPerFrame : 0
      @sprites["cursor"].x = cursor[:newX] - cursor[:offsetX]
      @sprites["cursor"].y = cursor[:newY] - cursor[:offsetY]
    elsif ENGINE21
      if cursor[:offsetX] != 0
        @sprites["cursor"].x = lerp(cursor[:newX] - cursor[:offsetX], cursor[:newX], 0.1, @distPerFrame, System.uptime)
        cursor[:offsetX] = 0 if @sprites["cursor"].x == cursor[:newX]
      end
      if cursor[:offsetY] != 0
        @sprites["cursor"].y = lerp(cursor[:newY] - cursor[:offsetY], cursor[:newY], 0.1, @distPerFrame, System.uptime)
        cursor[:offsetY] = 0 if @sprites["cursor"].y == cursor[:newY]
      end
    end
  end

  def updateMap(map)
    if ENGINE20
      map[:offsetX] += (map[:offsetX] > 0) ? -@distPerFrame : (map[:offsetX] < 0) ? @distPerFrame : 0
      map[:offsetY] += (map[:offsetY] > 0) ? -@distPerFrame : (map[:offsetY] < 0) ? @distPerFrame : 0
      @spritesMap.each do |key, value|
        @spritesMap[key].x = map[:newX] - map[:offsetX]
        @spritesMap[key].y = map[:newY] - map[:offsetY]
      end
    elsif ENGINE21
      if map[:offsetX] != 0
        @spritesMap.each do |key, value|
          @spritesMap[key].x = lerp(map[:newX] - map[:offsetX], map[:newX], 0.1, @distPerFrame, System.uptime)
        end
        map[:offsetX] = 0 if @spritesMap["map"].x == map[:newX]
      end
      if map[:offsetY] != 0
        @spritesMap.each do |key, value|
          @spritesMap[key].y = lerp(map[:newY] - map[:offsetY], map[:newY], 0.1, @distPerFrame, System.uptime)
        end
        map[:offsetY] = 0 if @spritesMap["map"].y == map[:newY]
      end
    end
    updateMapRange
  end

  def updateMapRange
    offset = ARMSettings::CURSOR_MAP_OFFSET ? 16 * @zoomLevel : 0
    mapOffsetX = ARMSettings::REGION_MAP_BEHIND_UI ? UI_BORDER_WIDTH / @zoomHash[@zoomIndex][:steps].ceil : 0
    mapOffsetX += 1 if @zoomHash[@zoomIndex][:level] == 0.5 && ARMSettings::CURSOR_MAP_OFFSET
    mapOffsetY = ARMSettings::REGION_MAP_BEHIND_UI ? UI_BORDER_HEIGHT / @zoomHash[@zoomIndex][:steps].ceil : 0
    @mapRange = {
      :minX => (((@spritesMap["map"].x - offset) / (SQUARE_WIDTH * @zoomLevel)).abs).ceil + mapOffsetX,
      :maxX => (((@spritesMap["map"].x + offset).abs + (UI_WIDTH - (SQUARE_WIDTH * @zoomLevel))) / (SQUARE_WIDTH * @zoomLevel)).ceil + mapOffsetX,
      :minY => (((@spritesMap["map"].y - offset) / (SQUARE_HEIGHT * @zoomLevel)).abs).ceil + mapOffsetY,
      :maxY => (((@spritesMap["map"].y + offset).abs + (UI_HEIGHT - (SQUARE_HEIGHT * @zoomLevel))) / (SQUARE_HEIGHT * @zoomLevel)).ceil + mapOffsetY
    }
    if ARMSettings::CURSOR_MAP_OFFSET
      @mapRange[:maxX] -= 2 if @spritesMap["map"].x == 0
      @mapRange[:maxY] -= 2 if @spritesMap["map"].y == 0
    end
  end

  def getDirectionInput(ox, oy, mox, moy)
    case Input.dir8
    when 1, 2, 3
      oy = 1 if @sprites["cursor"].y < @limitCursor[:maxY]
      moy = -1 if @spritesMap["map"].y > -1 * (@mapHeight - (Graphics.height - BEHIND_UI[3])) && oy == 0
    when 7, 8, 9
      oy = -1 if @sprites["cursor"].y > @limitCursor[:minY]
      moy = 1 if @spritesMap["map"].y < 0 && oy == 0
    end
    case Input.dir8
    when 1, 4, 7
      ox = -1 if @sprites["cursor"].x > @limitCursor[:minX]
      mox = 1 if @spritesMap["map"].x < 0 - @cursorCorrZoom && ox == 0
    when 3, 6, 9
      ox = 1 if @sprites["cursor"].x < @limitCursor[:maxX]
      mox = -1 if @spritesMap["map"].x > -1 * (@mapWidth - (Graphics.width - BEHIND_UI[1])) + @cursorCorrZoom && ox == 0
    end
    return ox, oy, mox, moy
  end

  def canActivateQuickFly(lastChoiceFly, cursor)
    @visited = getFlyLocations
    return if @visited.empty?
    if enableMode(ARMSettings::CAN_QUICK_FLY) && Input.trigger?(ARMSettings::QUICK_FLY_BUTTON)
      findChoice = @visited.find_index { |pos| pos[:x] == @mapX && pos[:y] == @mapY }
      lastChoiceFly = findChoice if findChoice
      choice = messageMap(_INTL("Quick Fly: Choose one of the available locations to fly to."),
          (0...@visited.size).to_a.map{ |i| "#{@visited[i][:name]}" }, -1, nil, lastChoiceFly, true) { pbUpdate }
      if choice != -1
        @mapX = @visited[choice][:x]
        @mapY = @visited[choice][:y]
      elsif choice == -1
        @mapX = cursor[:oldX]
        @mapY = cursor[:oldY]
      end
      @sprites["cursor"].x = 8 + (@mapX * ARMSettings::SQUARE_WIDTH)
      @sprites["cursor"].y = 24 + (@mapY * ARMSettings::SQUARE_HEIGHT)
      @sprites["cursor"].x -= UI_BORDER_WIDTH if ARMSettings::REGION_MAP_BEHIND_UI
      @sprites["cursor"].y -= UI_BORDER_HEIGHT if ARMSettings::REGION_MAP_BEHIND_UI
      pbGetMapLocation(@mapX, @mapY)
      centerMapOnCursor
    end
    return choice
  end

  def getFlyLocations
    visits = []
    @mapInfo.each do |key, value|
      value[:positions].each do |pos|
        next if pos[:flyspot].empty? || !pos[:flyspot][:visited]
        sel = { name: value[:mapname], x: pos[:x], y: pos[:y], flyspot: pos[:flyspot] }
        visits << sel unless visits.any? { |visited| visited[:flyspot] == sel[:flyspot] }
      end
    end
    return visits
  end

  def updateCursorPosition(ox, oy, cursor)
    @mapX += ox
    @mapY += oy
    cursor[:offsetX] = ox * (ARMSettings::SQUARE_WIDTH * @zoomLevel)
    cursor[:offsetY] = oy * (ARMSettings::SQUARE_HEIGHT * @zoomLevel)
    cursor[:newX] = @sprites["cursor"].x + cursor[:offsetX]
    cursor[:newY] = @sprites["cursor"].y + cursor[:offsetY]
    @distPerFrame = System.uptime if ENGINE21
    # Hide Quest Preview when moving cursor.
    if @mode == 2 || @mode == 3
      @previewBox.hideIt
    elsif @mode == 0 && @previewBox.isShown
      @previewBox.updateIt
    end
  end

  def updateMapPosition(mox, moy, map)
    @mapX -= mox
    @mapY -= moy
    map[:offsetX] = mox * (ARMSettings::SQUARE_WIDTH * @zoomLevel)
    map[:offsetY] = moy * (ARMSettings::SQUARE_HEIGHT * @zoomLevel)
    map[:newX] = @spritesMap["map"].x + map[:offsetX]
    map[:newY] = @spritesMap["map"].y + map[:offsetY]
    @distPerFrame = System.uptime if ENGINE21
    if @mode == 2 || @mode == 3
      @previewBox.hideIt
    elsif @mode == 0 && @previewBox.isShown
      @previewBox.updateIt
    end
  end

  def getFlyLocationAndConfirm
    @healspot = pbGetHealingSpot(@mapX, @mapY)
    if @healspot && ($PokemonGlobal.visitedMaps[@healspot[0]] || ($DEBUG && Input.press?(Input::CTRL)))
      name = pbGetMapNameFromId(@healspot[0])
      return confirmMessageMap(_INTL("Would you like to use Fly to go to {1}?", name))
    end
  end

  def switchMapMode
    if @modeCount > 2 && ARMSettings::CHANGE_MODE_MENU
      @choiceMode = 0 if !@choiceMode
      avaModes = @modeInfo.values.select { |mode| mode[:condition] }
      choice = messageMap(_INTL("Which mode would you like to switch to?"),
      avaModes.map { |mode| "#{mode[:text]}" }, -1, nil, @choiceMode) { pbUpdate }
      if choice != -1
        @choiceMode = choice
        @mode = avaModes[choice][:mode]
      end
    elsif @modeCount == 2
      pbPlayDecisionSE
      nextMode = 0
      @modeInfo.each do |index, data|
        next if data[:mode] <= @mode
        if data[:condition]
          nextMode = data[:mode]
          break
        end
      end
      @mode = nextMode
    end
    @sprites["modeName"].bitmap.clear
    refreshFlyScreen
    @sprites["mapbottom"].previewName = [getPreviewName(@mapX, @mapY), @previewWidth] if @mode == 2 || @mode == 3 || @mode == 4
    @sprites["buttonName"].bitmap.clear
  end

  def pbEndScene
    startFade { pbUpdate }
    $game_system.bgm_restore
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
class RegionMapSprite
  def createRegionMap(map)
    if Essentials::VERSION.include?("20")
      @mapdata = pbLoadTownMapData
      @map = @mapdata[map]
      bitmap = AnimatedBitmap.new("Graphics/Pictures/RegionMap/Regions/#{@map[1]}").deanimate
    else
      townMap = GameData::TownMap.get(map)
      bitmap = AnimatedBitmap.new("Graphics/UI/Town Map/Regions/#{townMap.filename}").deanimate
    end
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

#===============================================================================
# SpriteWindow_text
#===============================================================================
class Window_CommandPokemon < Window_DrawableCommand
  def initialize(commands, width = nil, custom = false)
    @starting = true
    @commands = []
    dims = []
    @custom = custom
    super(0, 0, 32, 32)
    getAutoDims(commands, dims, width)
    self.width = dims[0]
    self.height = dims[1]
    @commands = commands
    self.active = true
    colors = getDefaultTextColors(self.windowskin)
    self.baseColor = colors[0]
    self.shadowColor = colors[1]
    refresh
    @starting = false
  end

  def resizeToFit(commands, width = nil)
    dims = []
    getAutoDims(commands, dims, width)
    self.width = dims[0]
    self.height = @custom && @commands.length > ARMSettings::MAX_OPTIONS_CHOICE_MENU ? (32 + (ARMSettings::MAX_OPTIONS_CHOICE_MENU * 32)) : dims[1]
  end
end
