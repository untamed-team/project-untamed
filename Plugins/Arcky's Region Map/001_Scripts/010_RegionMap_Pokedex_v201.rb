#===============================================================================
#
#===============================================================================
if Essentials::VERSION.include?("20")
  class PokemonPokedexInfo_Scene
    UI_WIDTH = Settings::SCREEN_WIDTH - 32
    UI_HEIGHT = Settings::SCREEN_HEIGHT - 64
    BEHIND_UI = ARMSettings::REGION_MAP_BEHIND_UI ? [0, 0, 0, 0] : [16, 32, 48, 64]
    THEMEPLUGIN = PluginManager.installed?("Lin's Pokegear Themes")
    FOLDER = "Graphics/Pictures/RegionMap/"

    def pbStartScene(dexlist, index, region)
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 100000
      @viewportMap = Viewport.new(BEHIND_UI[0], BEHIND_UI[2], (Graphics.width - BEHIND_UI[1]), (Graphics.height - BEHIND_UI[3]))
      @viewportMap.z = 99999
      @dexlist = dexlist
      @index   = index
      @region  = region
      @page = 1
      @show_battled_count = false
      @typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/icon_types"))
      @sprites = {}
      @sprites["background"] = IconSprite.new(0, 0, @viewport)
      @sprites["infosprite"] = PokemonSprite.new(@viewport)
      @sprites["infosprite"].setOffset(PictureOrigin::CENTER)
      @sprites["infosprite"].x = 104
      @sprites["infosprite"].y = 136
      @mapdata = pbLoadTownMapData
      mappos = $game_map.metadata&.town_map_position
      if @region < 0                                 # Use player's current region
        @region = mappos ? mappos[0] : 0                      # Region 0 default
      end
      @sprites["areamap"] = IconSprite.new(0, 0, @viewportMap)
      @sprites["areamap"].setBitmap("#{FOLDER}/Regions/#{@mapdata[@region][1]}")
      Settings::REGION_MAP_EXTRAS.each do |hidden|
        next if hidden[0] != @region || hidden[1] <= 0 || !$game_switches[hidden[1]]
        pbDrawImagePositions(
          @sprites["areamap"].bitmap,
          [["Graphics/Pictures/#{hidden[4]}",
            hidden[2] * ARMSettings::SQUARE_WIDTH,
            hidden[3] * ARMSettings::SQUARE_HEIGHT]]
        )
      end
      @sprites["areahighlight"] = BitmapSprite.new(@sprites["areamap"].bitmap.width, @sprites["areamap"].bitmap.height, @viewportMap)
      @sprites["areaoverlay"] = IconSprite.new(0, 0, @viewport)
      @sprites["areaoverlay"].setBitmap("Graphics/Pictures/Pokedex/overlay_area")
      @sprites["formfront"] = PokemonSprite.new(@viewport)
      @sprites["formfront"].setOffset(PictureOrigin::CENTER)
      @sprites["formfront"].x = 130
      @sprites["formfront"].y = 158
      @sprites["formback"] = PokemonSprite.new(@viewport)
      @sprites["formback"].setOffset(PictureOrigin::BOTTOM)
      @sprites["formback"].x = 382   # y is set below as it depends on metrics
      @sprites["formicon"] = PokemonSpeciesIconSprite.new(nil, @viewport)
      @sprites["formicon"].setOffset(PictureOrigin::CENTER)
      @sprites["formicon"].x = 82
      @sprites["formicon"].y = 328
      @sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow", 8, 28, 40, 2, @viewport)
      @sprites["uparrow"].x = 242
      @sprites["uparrow"].y = 268
      @sprites["uparrow"].play
      @sprites["uparrow"].visible = false
      @sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow", 8, 28, 40, 2, @viewport)
      @sprites["downarrow"].x = 242
      @sprites["downarrow"].y = 348
      @sprites["downarrow"].play
      @sprites["downarrow"].visible = false
      @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      mapMetaData = $game_map.metadata
      if !mapMetaData
        p "There's no mapMetadata for map '#{$game_map.name}' with ID #{$game_map.map_id}. Add it to the map_metadata.txt to fix this error!"
        Console.echo_error _INTL("There's no mapMetadata for map '#{$game_map.name}' with ID #{$game_map.map_id}. \nAdd it to the map_metadata.txt to fix this error!")
      end
      playerPos = mapMetaData && mapMetaData.town_map_position ? mapMetaData.town_map_position : [0, 0, 0]
      mapSize = mapMetaData.town_map_size
      mapX = playerPos[1]
      mapY = playerPos[2]
      if mapSize && mapSize[0] && mapSize[0] > 0
        sqwidth  = mapSize[0]
        sqheight = (mapSize[1].length.to_f / mapSize[0]).ceil
        mapX += ($game_player.x * sqwidth / $game_map.width).floor if sqwidth > 1
        mapY += ($game_player.y * sqheight / $game_map.height).floor if sqheight > 1
      end
      @mapWidth = @sprites["areamap"].bitmap.width
      @mapHeight = @sprites["areamap"].bitmap.height
      @playerX = (-8 + BEHIND_UI[0]) + (ARMSettings::SQUARE_WIDTH * mapX)
      @playerY = (-8 + BEHIND_UI[1]) + (ARMSettings::SQUARE_HEIGHT * mapY)
      @mapMaxX = -1 * (@mapWidth  - (Graphics.width - BEHIND_UI[1]))
      @mapMaxY = -1 * (@mapHeight - (Graphics.height - BEHIND_UI[3]))
      @mapPosX = (UI_WIDTH / 2) - @playerX
      @mapPosY = (UI_HEIGHT / 2) - @playerY
      @mapOffsetX = @mapWidth < (Graphics.width - BEHIND_UI[1]) ? ((Graphics.width - BEHIND_UI[1]) - @mapWidth) / 2 : 0
      @mapOffsetY = @mapHeight < (Graphics.height - BEHIND_UI[3]) ? ((Graphics.height - BEHIND_UI[3]) - @mapHeight) / 2 : 0
      pos = @mapPosX < @mapMaxX ? @mapMaxX : @mapPosX
      if @playerX > (Settings::SCREEN_WIDTH / 2) && ((@mapWidth > Graphics.width && ARMSettings::REGION_MAP_BEHIND_UI) || (@mapWidth > UI_WIDTH && !ARMSettings::REGION_MAP_BEHIND_UI))
        @sprites["areamap"].x = pos % ARMSettings::SQUARE_WIDTH != 0 ? pos + 8 : pos
      else
        @sprites["areamap"].x = @mapOffsetX
      end
      pos = @mapPosY < @mapMaxY ? @mapMaxY : @mapPosY
      if @playerY > (Settings::SCREEN_HEIGHT / 2) && ((@mapHeight > Graphics.height && ARMSettings::REGION_MAP_BEHIND_UI) || (@mapHeight > UI_HEIGHT && !ARMSettings::REGION_MAP_BEHIND_UI))
        @sprites["areamap"].y = pos % ARMSettings::SQUARE_HEIGHT != 0 ? pos + 24 : pos
      else
        @mapOffsetY += 16 if @mapHeight <= UI_HEIGHT && ARMSettings::REGION_MAP_BEHIND_UI
        @sprites["areamap"].y = @mapOffsetY
      end
      @mapX = -(@sprites["areamap"].x / ARMSettings::SQUARE_WIDTH)
      @mapY = -(@sprites["areamap"].y / ARMSettings::SQUARE_HEIGHT)
      pbSetSystemFont(@sprites["overlay"].bitmap)
      pbUpdateDummyPokemon
      @available = pbGetAvailableForms
      drawPage(@page)
      pbFadeInAndShow(@sprites) { pbUpdate }
    end

    def pbFindEncounter(enc_types, species)
      return false if !enc_types
      enc_types.each_value do |slots|
        next if !slots
        slots.each { |slot| return true if GameData::Species.get(slot[1]).species == species }
      end
      return false
    end

    # Returns a 1D array of values corresponding to points on the Town Map. Each
    # value is true or false.
    def pbGetEncounterPoints
      # Determine all visible points on the Town Map (i.e. only ones with a
      # defined point in town_map.txt, and which either have no Self Switch
      # controlling their visibility or whose Self Switch is ON)
      visible_points = []
      @mapdata[@region][2].each do |loc|
        next if loc[7] && !$game_switches[loc[7]]   # Point is not visible
        visible_points.push([loc[0], loc[1]])
      end
      # Find all points with a visible area for @species
      town_map_width = @mapWidth / ARMSettings::SQUARE_WIDTH
      ret = []
      GameData::Encounter.each_of_version($PokemonGlobal.encounter_version) do |enc_data|
        next if !pbFindEncounter(enc_data.types, @species)   # Species isn't in encounter table
        # Get the map belonging to the encounter table
        map_metadata = GameData::MapMetadata.try_get(enc_data.map)
        next if !map_metadata || map_metadata.has_flag?("HideEncountersInPokedex")
        mappos = map_metadata.town_map_position
        if mappos.nil?
          Console.echoln_li _INTL("#{map_metadata.name} has no mapPosition defined in map_metadata.txt PBS file.")
          next
        end
        next if mappos[0] != @region   # Map isn't in the region being shown
        # Get the size and shape of the map in the Town Map
        map_size = map_metadata.town_map_size
        map_width = 1
        map_height = 1
        map_shape = "1"
        if map_size && map_size[0] && map_size[0] > 0   # Map occupies multiple points
          map_width = map_size[0]
          map_shape = map_size[1]
          map_height = (map_shape.length.to_f / map_width).ceil
        end
        # Mark each visible point covered by the map as containing the area
        map_width.times do |i|
          map_height.times do |j|
            next if map_shape[i + (j * map_width), 1].to_i == 0   # Point isn't part of map
            next if !visible_points.include?([mappos[1] + i, mappos[2] + j])   # Point isn't visible
            ret[mappos[1] + i + ((mappos[2] + j) * town_map_width)] = true
          end
        end
      end
      return ret
    end

    def drawPageArea
      @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_area"))
      overlay = @sprites["overlay"].bitmap
      base   = Color.new(88, 88, 80)
      shadow = Color.new(168, 184, 184)
      @sprites["areahighlight"].bitmap.clear
      @sprites["areahighlight"].x = @sprites["areamap"].x
      @sprites["areahighlight"].y = @sprites["areamap"].y
      @noArea = false
      # Get all points to be shown as places where @species can be encountered
      points = pbGetEncounterPoints
      # Draw coloured squares on each point of the Town Map with a nest
      pointcolor   = Color.new(0, 248, 248)
      pointcolorhl = Color.new(192, 248, 248)
      sqwidth = ARMSettings::SQUARE_WIDTH
      sqheight = ARMSettings::SQUARE_HEIGHT
      town_map_width = @mapWidth / sqwidth
      points.length.times do |j|
        next if !points[j]
        x = (j % town_map_width) * sqwidth
        y = (j / town_map_width) * sqheight
        @sprites["areahighlight"].bitmap.fill_rect(x, y, sqwidth, sqheight, pointcolor)
        if j - town_map_width < 0 || !points[j - town_map_width]
          @sprites["areahighlight"].bitmap.fill_rect(x, y - 2, sqwidth, 2, pointcolorhl)
        end
        if j + town_map_width >= points.length || !points[j + town_map_width]
          @sprites["areahighlight"].bitmap.fill_rect(x, y + sqheight, sqwidth, 2, pointcolorhl)
        end
        if j % town_map_width == 0 || !points[j - 1]
          @sprites["areahighlight"].bitmap.fill_rect(x - 2, y, 2, sqheight, pointcolorhl)
        end
        if (j + 1) % town_map_width == 0 || !points[j + 1]
          @sprites["areahighlight"].bitmap.fill_rect(x + sqwidth, y, 2, sqheight, pointcolorhl)
        end
      end

      # Set the text
      textpos = []
      if points.length == 0
        pbDrawImagePositions(
          overlay,
          [[sprintf("Graphics/Pictures/Pokedex/overlay_areanone"), 108, 188]]
        )
        textpos.push([_INTL("Area unknown"), Graphics.width / 2, (Graphics.height / 2) + 6, 2, base, shadow])
        @noArea = true
      end
      textpos.push([pbGetMessage(MessageTypes::RegionNames, @region), 414, 50, 2, base, shadow])
      textpos.push([_INTL("{1}'s area", GameData::Species.get(@species).name),
                    Graphics.width / 2, 358, 2, base, shadow])
      pbDrawTextPositions(overlay, textpos)
    end

    def makeMapArrows
      @sprites["upArrow"] = AnimatedSprite.new(findUsableUI("mapArrowUp"), 8, 28, 40, 2, @viewport)
      @sprites["upArrow"].x = Graphics.width / 2
      @sprites["upArrow"].y = 32
      @sprites["upArrow"].play
      @sprites["upArrow"].visible = false
      @sprites["downArrow"] = AnimatedSprite.new(findUsableUI("mapArrowDown"), 8, 28, 40, 2, @viewport)
      @sprites["downArrow"].x = Graphics.width / 2
      @sprites["downArrow"].y = Graphics.height - 60
      @sprites["downArrow"].play
      @sprites["downArrow"].visible = false
      @sprites["leftArrow"] = AnimatedSprite.new(findUsableUI("mapArrowLeft"), 8, 40, 28, 2, @viewport)
      @sprites["leftArrow"].y = Graphics.height / 2
      @sprites["leftArrow"].play
      @sprites["leftArrow"].visible = false
      @sprites["rightArrow"] = AnimatedSprite.new(findUsableUI("mapArrowRight"), 8, 40, 28, 2, @viewport)
      @sprites["rightArrow"].x = Graphics.width - 40
      @sprites["rightArrow"].y = Graphics.height / 2
      @sprites["rightArrow"].play
      @sprites["rightArrow"].visible = false
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
          return "#{FOLDER}UI/Default/#{image}"
        end
      end
    end

    def pbScene
      Pokemon.play_cry(@species, @form)
      @mapMovement = false
      new_x = @sprites["areamap"].x
      new_y = @sprites["areamap"].y
      ox = 0
      oy = 0
      dist_per_frame = 8 * 20 / Graphics.frame_rate
      loop do
        Graphics.update
        Input.update
        pbUpdate
        dorefresh = false
        if ox != 0 || oy != 0
          ox += (ox > 0) ? -dist_per_frame : (ox < 0) ? dist_per_frame : 0
          oy += (oy > 0) ? -dist_per_frame : (oy < 0) ? dist_per_frame : 0
          @sprites["areamap"].x = new_x - ox
          @sprites["areamap"].y = new_y - oy
          @sprites["areahighlight"].x = @sprites["areamap"].x
          @sprites["areahighlight"].y = @sprites["areamap"].y
          next
        end
        if @mapMovement
          @sprites["upArrow"].visible = -(@mapY * 16) < 0
          @sprites["downArrow"].visible = -(@mapY * 16) > @mapMaxY
          @sprites["leftArrow"].visible = -(@mapX * 16) < 0
          @sprites["rightArrow"].visible = -(@mapX * 16) > @mapMaxX
        end
        if Input.trigger?(Input::ACTION)
          pbSEStop
          Pokemon.play_cry(@species, @form) if @page == 1
        elsif Input.trigger?(Input::BACK)
          if @mapMovement
            @mapMovement = false
            @sprites["upArrow"].visible = false
            @sprites["downArrow"].visible = false
            @sprites["leftArrow"].visible = false
            @sprites["rightArrow"].visible = false
          else
            pbPlayCloseMenuSE
            break
          end
        elsif Input.trigger?(Input::USE)
          case @page
          when 1   # Info
            @show_battled_count = !@show_battled_count
            @mapMovement = false
            dorefresh = true
          when 2   # Area
            if !@noArea && (@sprites["areamap"].bitmap.width > (Graphics.width - BEHIND_UI[1]) || @sprites["areamap"].bitmap.height > (Graphics.height - BEHIND_UI[3]))
              pbPlayCursorSE
              @mapMovement = true
            end 
            makeMapArrows if !@sprites["upArrow"] && !@noArea
            dorefresh = true
          when 3   # Forms
            if @available.length > 1
              pbPlayDecisionSE
              @mapMovement = false
              pbChooseForm
              dorefresh = true
            end
          end
        elsif !@mapMovement
          if Input.trigger?(Input::UP)
            oldindex = @index
            pbGoToPrevious
            if @index != oldindex
              pbUpdateDummyPokemon
              @available = pbGetAvailableForms
              pbSEStop
              (@page == 1) ? Pokemon.play_cry(@species, @form) : pbPlayCursorSE
              dorefresh = true
            end
          elsif Input.trigger?(Input::DOWN)
            oldindex = @index
            pbGoToNext
            if @index != oldindex
              pbUpdateDummyPokemon
              @available = pbGetAvailableForms
              pbSEStop
              (@page == 1) ? Pokemon.play_cry(@species, @form) : pbPlayCursorSE
              dorefresh = true
            end
          elsif Input.trigger?(Input::LEFT)
            oldpage = @page
            @page -= 1
            @page = 1 if @page < 1
            @page = 3 if @page > 3
            if @page != oldpage
              pbPlayCursorSE
              dorefresh = true
            end
          elsif Input.trigger?(Input::RIGHT)
            oldpage = @page
            @page += 1
            @page = 1 if @page < 1
            @page = 3 if @page > 3
            if @page != oldpage
              pbPlayCursorSE
              dorefresh = true
            end
          end
        else
          case Input.dir8
          when 1, 2, 3
            if -(@mapY * 16) > @mapMaxY
              @mapY += 1
              oy = -1 * ARMSettings::SQUARE_HEIGHT
              new_y = @sprites["areamap"].y + oy
            end
          when 7, 8, 9
            if -(@mapY * 16) < 0
              @mapY -= 1
              oy = 1 * ARMSettings::SQUARE_HEIGHT
              new_y = @sprites["areamap"].y + oy
            end
          end
          case Input.dir8
          when 1, 4, 7
            if -(@mapX * 16) < 0
              @mapX -= 1
              ox = 1 * ARMSettings::SQUARE_WIDTH
              new_x = @sprites["areamap"].x + ox
            end
          when 3, 6, 9
            if -(@mapX * 16) > @mapMaxX
              @mapX += 1
              ox = -1 * ARMSettings::SQUARE_WIDTH
              new_x = @sprites["areamap"].x + ox
            end
          end
        end
        if dorefresh
          drawPage(@page)
        end
      end
      return @index
    end
  end
end
