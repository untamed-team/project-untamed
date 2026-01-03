#===============================================================================
#
#===============================================================================
if Essentials::VERSION.include?("21")
  class PokemonPokedexInfo_Scene
    UI_WIDTH = Settings::SCREEN_WIDTH - 32
    UI_HEIGHT = Settings::SCREEN_HEIGHT - 64
    BEHIND_UI = ARMSettings::REGION_MAP_BEHIND_UI ? [0, 0, 0, 0] : [16, 32, 48, 64]
    THEMEPLUGIN = PluginManager.installed?("Lin's Pokegear Themes")
    FOLDER = "Graphics/UI/Town Map/"

    alias arcky_pbStartScene pbStartScene
    def pbStartScene(*args)
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 100000
      @viewportMap = Viewport.new(BEHIND_UI[0], BEHIND_UI[2], (Graphics.width - BEHIND_UI[1]), (Graphics.height - BEHIND_UI[3]))
      @viewportMap.z = 99999
      arcky_pbStartScene(*args)
      @sprites["areamap"] = IconSprite.new(0, 0, @viewportMap)
      @sprites["areamap"].setBitmap("Graphics/UI/Town Map/Regions/#{@mapdata.filename}")
      Settings::REGION_MAP_EXTRAS.each do |hidden|
        next if hidden[0] != @region || hidden[1] <= 0 || !$game_switches[hidden[1]]
        pbDrawImagePositions(
          @sprites["areamap"].bitmap,
          [["Graphics/UI/Town Map/HiddenRegionMaps/#{hidden[4]}",
            hidden[2] * PokemonRegionMap_Scene::SQUARE_WIDTH,
            hidden[3] * PokemonRegionMap_Scene::SQUARE_HEIGHT]]
        )
      end
      @sprites["areahighlight"] = BitmapSprite.new(@sprites["areamap"].bitmap.width, @sprites["areamap"].bitmap.height, @viewportMap)
      makeMapArrows
      mapMetadata = $game_map.metadata
      if !mapMetadata
        p "There's no mapMetadata for map '#{$game_map.name}' with ID #{$game_map.map_id}. Add it to the map_metadata.txt to fix this error!"
        Console.echo_error _INTL("There's no mapMetadata for map '#{$game_map.name}' with ID #{$game_map.map_id}. \nAdd it to the map_metadata.txt to fix this error!")
      end
      playerPos = mapMetadata && mapMetadata.town_map_position ? mapMetadata.town_map_position : [0, 0, 0]
      mapSize = mapMetadata.town_map_size
      mapX = playerPos[1]
      mapY = playerPos[2]
      if mapSize && mapSize[0] && mapSize[0].ceil
        sqwidth = mapSize[0]
        sqheight = (mapSize[1].length.to_f / mapSize[0]).ceil
        mapX += ($game_player.x * sqwidth / $game_map.width).floor if sqwidth > 1
        mapY += ($game_player.x * sqheight / $game_map.height).floor if sqheight > 1
      end
      @mapWidth = @sprites["areamap"].bitmap.width
      @mapHeight = @sprites["areamap"].bitmap.height
      @playerX = (-8 + BEHIND_UI[0]) + (ARMSettings::SQUARE_WIDTH * mapX)
      @playerY = (-8 + BEHIND_UI[1]) + (ARMSettings::SQUARE_HEIGHT * mapY)
      @mapMaxX = -1 * (@mapWidth - (Graphics.width - BEHIND_UI[1]))
      @mapMaxY = -1 * (@mapHeight - (Graphics.height - BEHIND_UI[3]))
      @mapPosX = (UI_WIDTH / 2) - @playerX
      @mapPosY = (UI_HEIGHT / 2) - @playerY
      @mapOffsetX = @mapWidth < (Graphics.width - BEHIND_UI[1]) ? ((Graphics.width - BEHIND_UI[1]) - @mapWidth) / 2 : 0
      @mapoffsetY = @mapHeight < (Graphics.height - BEHIND_UI[3]) ? ((Graphics.height - BEHIND_UI[3]) - @mapHeight) / 2 : 0
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
        @sprites["areamap"].y = @mapoffsetY
      end
      @mapX = -(@sprites["areamap"].x / ARMSettings::SQUARE_WIDTH)
      @mapY = -(@sprites["areamap"].y / ARMSettings::SQUARE_HEIGHT)
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
      @mapdata.point.each do |loc|
        next if loc[7] && !$game_switches[loc[7]]   # Point is not visible
        visible_points.push([loc[0], loc[1]])
      end
      # Find all points with a visible area for @species
      town_map_width = @mapWidth / PokemonRegionMap_Scene::SQUARE_WIDTH
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
      @sprites["areamap"].visible       = true
      @sprites["areahighlight"].visible = true
      @sprites["areaoverlay"].visible   = true
      @sprites["background"].setBitmap(_INTL("Graphics/UI/Pokedex/bg_area"))
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
      sqwidth = PokemonRegionMap_Scene::SQUARE_WIDTH
      sqheight = PokemonRegionMap_Scene::SQUARE_HEIGHT
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
          [[sprintf("Graphics/UI/Pokedex/overlay_areanone"), 108, 188]]
        )
        textpos.push([_INTL("Area unknown"), Graphics.width / 2, (Graphics.height / 2) + 6, 2, base, shadow])
        @noArea = true
      end
      textpos.push([@mapdata.name, 414, 50, 2, base, shadow])
      textpos.push([_INTL("{1}'s area", GameData::Species.get(@species).name),
                    Graphics.width / 2, 358, 2, base, shadow])
      pbDrawTextPositions(overlay, textpos)
    end

    def makeMapArrows
      @sprites["mapArrowUp"] = AnimatedSprite.new(findUsableUI("mapArrowUp"), 8, 28, 40, 2, @viewport)
      @sprites["mapArrowUp"].x = Graphics.width / 2
      @sprites["mapArrowUp"].y = 32
      @sprites["mapArrowUp"].play
      @sprites["mapArrowUp"].visible = false
      @sprites["mapArrowDown"] = AnimatedSprite.new(findUsableUI("mapArrowDown"), 8, 28, 40, 2, @viewport)
      @sprites["mapArrowDown"].x = Graphics.width / 2
      @sprites["mapArrowDown"].y = Graphics.height - 60
      @sprites["mapArrowDown"].play
      @sprites["mapArrowDown"].visible = false
      @sprites["mapArrowLeft"] = AnimatedSprite.new(findUsableUI("mapArrowLeft"), 8, 40, 28, 2, @viewport)
      @sprites["mapArrowLeft"].y = Graphics.height / 2
      @sprites["mapArrowLeft"].play
      @sprites["mapArrowLeft"].visible = false
      @sprites["mapArrowRight"] = AnimatedSprite.new(findUsableUI("mapArrowRight"), 8, 40, 28, 2, @viewport)
      @sprites["mapArrowRight"].x = Graphics.width - 40
      @sprites["mapArrowRight"].y = Graphics.height / 2
      @sprites["mapArrowRight"].play
      @sprites["mapArrowRight"].visible = false
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

    if PluginManager.installed?("Modular UI Scenes")
      def pbRegionMapControls
        return if @noArea
        new_x = @sprites["areamap"].x
        new_y = @sprites["areamap"].y
        ox = oy = 0
        distPerFrame = System.uptime
        pbPlayCursorSE
        loop do
          Graphics.update
          Input.update
          pbUpdate
          @sprites["mapArrowUp"].visible = -(@mapY * 16) < 0
          @sprites["mapArrowDown"].visible = -(@mapY * 16) > @mapMaxY
          @sprites["mapArrowLeft"].visible = -(@mapX * 16) < 0
          @sprites["mapArrowRight"].visible = -(@mapX * 16) > @mapMaxX
          if ox != 0 || oy != 0
            if ox != 0
              @sprites["areamap"].x = lerp(new_x - ox, new_x, 0.1, distPerFrame, System.uptime)
              @sprites["areahighlight"].x = @sprites["areamap"].x
              ox = 0 if @sprites["areamap"].x == new_x
            end
            if oy != 0
              @sprites["areamap"].y = lerp(new_y - oy, new_y, 0.1, distPerFrame, System.uptime)
              @sprites["areahighlight"].y = @sprites["areamap"].y
              oy = 0 if @sprites["areamap"].y == new_y
            end
            next if ox != 0 || oy != 0
          end
          if Input.trigger?(Input::BACK)
            @sprites["mapArrowUp"].visible = false
            @sprites["mapArrowDown"].visible = false
            @sprites["mapArrowLeft"].visible = false
            @sprites["mapArrowRight"].visible = false
            pbPlayCancelSE
            break
          else
            case Input.dir8
            when 1, 2, 3
              if -(@mapY * 16) > @mapMaxY
                @mapY += 1
                oy = -1 * PokemonRegionMap_Scene::SQUARE_HEIGHT
                new_y = @sprites["areamap"].y + oy
                distPerFrame = System.uptime
              end
            when 7, 8, 9
              if -(@mapY * 16) < 0
                @mapY -= 1
                oy = 1 * PokemonRegionMap_Scene::SQUARE_HEIGHT
                new_y = @sprites["areamap"].y + oy
                distPerFrame = System.uptime
              end
            end
            case Input.dir8
            when 1, 4, 7
              if -(@mapX * 16) < 0
                @mapX -= 1
                ox = 1 * PokemonRegionMap_Scene::SQUARE_WIDTH
                new_x = @sprites["areamap"].x + ox
                distPerFrame = System.uptime
              end
            when 3, 6, 9
              if -(@mapX * 16) > @mapMaxX
                @mapX += 1
                ox = -1 * PokemonRegionMap_Scene::SQUARE_WIDTH
                new_x = @sprites["areamap"].x + ox
                distPerFrame = System.uptime
              end
            end
          end
        end
      end

      alias _region_map_pbPageCustomUse pbPageCustomUse
      def pbPageCustomUse(page_id)
        if page_id == :page_area
          pbRegionMapControls
          return true
        end
        return _region_map_pbPageCustomUse(page_id)
      end
    else
      def pbScene
        Pokemon.play_cry(@species, @form)
        @mapMovement = false
        new_x = 0
        new_y = 0
        ox = 0
        oy = 0
        distPerFrame = System.uptime
        loop do
          Graphics.update
          Input.update
          pbUpdate
          dorefresh = false
          if ox != 0 || oy != 0
            if ox != 0
              @sprites["areamap"].x = lerp(new_x - ox, new_x, 0.1, distPerFrame, System.uptime)
              @sprites["areahighlight"].x = @sprites["areamap"].x
              ox = 0 if @sprites["areamap"].x == new_x
            end
            if oy != 0
              @sprites["areamap"].y = lerp(new_y - oy, new_y, 0.1, distPerFrame, System.uptime)
              @sprites["areahighlight"].y = @sprites["areamap"].y
              oy = 0 if @sprites["areamap"].y == new_y
            end
            next if ox != 0 || oy != 0
          end
          if @mapMovement
            @sprites["mapArrowUp"].visible = -(@mapY * 16) < 0 ? true : false
            @sprites["mapArrowDown"].visible = -(@mapY * 16) > @mapMaxY ? true : false
            @sprites["mapArrowLeft"].visible = -(@mapX * 16) < 0 ? true : false
            @sprites["mapArrowRight"].visible = -(@mapX * 16) > @mapMaxX ? true : false
          end
          if Input.trigger?(Input::ACTION)
            pbSEStop
            Pokemon.play_cry(@species, @form) if @page == 1
          elsif Input.trigger?(Input::BACK)
            if @mapMovement
              @mapMovement = false
              @sprites["mapArrowUp"].visible = false
              @sprites["mapArrowDown"].visible = false
              @sprites["mapArrowLeft"].visible = false
              @sprites["mapArrowRight"].visible = false
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
              if !@noArea && @sprites["areamap"].bitmap.width > 480
                pbPlayCursorSE
                @mapMovement = true
              end 
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
                oy = -1 * PokemonRegionMap_Scene::SQUARE_HEIGHT
                new_y = @sprites["areamap"].y + oy
                distPerFrame = System.uptime
              end
            when 7, 8, 9
              if -(@mapY * 16) < 0
                @mapY -= 1
                oy = 1 * PokemonRegionMap_Scene::SQUARE_HEIGHT
                new_y = @sprites["areamap"].y + oy
                distPerFrame = System.uptime
              end
            end
            case Input.dir8
            when 1, 4, 7
              if -(@mapX * 16) < 0
                @mapX -= 1
                ox = 1 * PokemonRegionMap_Scene::SQUARE_WIDTH
                new_x = @sprites["areamap"].x + ox
                distPerFrame = System.uptime
              end
            when 3, 6, 9
              if -(@mapX * 16) > @mapMaxX
                @mapX += 1
                ox = -1 * PokemonRegionMap_Scene::SQUARE_WIDTH
                new_x = @sprites["areamap"].x + ox
                distPerFrame = System.uptime
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
end
