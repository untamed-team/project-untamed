#===============================================================================
#
#===============================================================================
class PokemonPokedexInfo_Scene
  def pbStartScene(dexlist, index, region)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 100000
    @viewportMap = Viewport.new(16, 48, 480, 320)
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
      @region = (mappos) ? mappos[0] : 0                      # Region 0 default
    end
    @sprites["areamap"] = IconSprite.new(0, 0, @viewportMap)
    @sprites["areamap"].setBitmap("Graphics/Pictures/RegionMap/Regions/#{@mapdata[@region][1]}")
    Settings::REGION_MAP_EXTRAS.each do |hidden|
      next if hidden[0] != @region || hidden[1] <= 0 || !$game_switches[hidden[1]]
      pbDrawImagePositions(
        @sprites["areamap"].bitmap,
        [["Graphics/Pictures/#{hidden[4]}",
          hidden[2] * PokemonRegionMap_Scene::SQUARE_WIDTH,
          hidden[3] * PokemonRegionMap_Scene::SQUARE_HEIGHT]]
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
    map_metadata = $game_map.metadata
    playerpos = map_metadata && map_metadata.town_map_position ? map_metadata.town_map_position : [0, 0, 0]
    @mapWidth = @sprites["areamap"].bitmap.width
    @mapHeigth = @sprites["areamap"].bitmap.height
    @mapMaxX = -1 * (@mapWidth - 480)
    @mapMaxY = -1 * (@mapHeigth - 320)
    @mapPosX = (480 / 2) - (playerpos[1] * PokemonRegionMap_Scene::SQUARE_WIDTH)
    @mapPosY = (320 / 2) - (playerpos[2] * PokemonRegionMap_Scene::SQUARE_HEIGHT)
    if playerpos[1] * 16 > (Settings::SCREEN_WIDTH / 2) 
      if @mapWidth > 480
        @sprites["areamap"].x = @mapPosX % PokemonRegionMap_Scene::SQUARE_WIDTH != 0 ? @mapPosX + 8 : @mapPosX
        if @sprites["areamap"].x < @mapMaxX
          @sprites["areamap"].x = @mapMaxX
        end    
      end
    else  
      @sprites["areamap"].x = 0
    end
    if playerpos[2] * 16 > (Settings::SCREEN_HEIGHT / 2)
      if @mapHeigth > 320
        @sprites["areamap"].y = @mapPosY % PokemonRegionMap_Scene::SQUARE_HEIGHT != 0 ? @mapPosY + 8 : @mapPosY
        if @sprites["areamap"].y < @mapMaxY
          @sprites["areamap"].y = @mapMaxY
        end    
      end
    else  
      @sprites["areamap"].y = 0
    end
    @mapX = -(@sprites["areamap"].x / PokemonRegionMap_Scene::SQUARE_WIDTH)
    @mapY = -(@sprites["areamap"].y / PokemonRegionMap_Scene::SQUARE_HEIGHT)
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
    town_map_width = @mapWidth / PokemonRegionMap_Scene::SQUARE_WIDTH
    ret = []
    GameData::Encounter.each_of_version($PokemonGlobal.encounter_version) do |enc_data|
      next if !pbFindEncounter(enc_data.types, @species)   # Species isn't in encounter table
      # Get the map belonging to the encounter table
      map_metadata = GameData::MapMetadata.try_get(enc_data.map)
      next if !map_metadata || map_metadata.has_flag?("HideEncountersInPokedex")
      mappos = map_metadata.town_map_position
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
    @sprites["upArrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow", 8, 28, 40, 2, @viewport)
    @sprites["upArrow"].x = Graphics.width / 2
    @sprites["upArrow"].y = 32
    @sprites["upArrow"].play 
    @sprites["upArrow"].visible = false
    @sprites["downArrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow", 8, 28, 40, 2, @viewport)
    @sprites["downArrow"].x = Graphics.width / 2
    @sprites["downArrow"].y = Graphics.height - 60
    @sprites["downArrow"].play 
    @sprites["downArrow"].visible = false
    @sprites["leftArrow"] = AnimatedSprite.new("Graphics/Pictures/leftarrow", 8, 40, 28, 2, @viewport)
    @sprites["leftArrow"].y = Graphics.height / 2
    @sprites["leftArrow"].play
    @sprites["leftArrow"].visible = false
    @sprites["rightArrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow", 8, 40, 28, 2, @viewport)
    @sprites["rightArrow"].x = Graphics.width - 40
    @sprites["rightArrow"].y = Graphics.height / 2
    @sprites["rightArrow"].play 
    @sprites["rightArrow"].visible = false
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
        @sprites["upArrow"].visible = -(@mapY * 16) < 0 ? true : false
        @sprites["downArrow"].visible = -(@mapY * 16) > @mapMaxY ? true : false
        @sprites["leftArrow"].visible = -(@mapX * 16) < 0 ? true : false 
        @sprites["rightArrow"].visible = -(@mapX * 16) > @mapMaxX ? true : false 
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
          pbPlayCursorSE
          @mapMovement = true if !@noArea && @sprites["areamap"].bitmap.width > 480
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
            oy = -1 * PokemonRegionMap_Scene::SQUARE_HEIGHT
            new_y = @sprites["areamap"].y + oy
          end 
        when 7, 8, 9
          if -(@mapY * 16) < 0
            @mapY -= 1
            oy = 1 * PokemonRegionMap_Scene::SQUARE_HEIGHT
            new_y = @sprites["areamap"].y + oy
          end 
        end 
        case Input.dir8 
        when 1, 4, 7
          if -(@mapX * 16) < 0
            @mapX -= 1
            ox = 1 * PokemonRegionMap_Scene::SQUARE_WIDTH
            new_x = @sprites["areamap"].x + ox
          end 
        when 3, 6, 9
          if -(@mapX * 16) > @mapMaxX
            @mapX += 1
            ox = -1 * PokemonRegionMap_Scene::SQUARE_WIDTH
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