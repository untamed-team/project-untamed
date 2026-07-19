#===============================================================================
#
#===============================================================================
class Window_Berrydex < Window_DrawableCommand
    def initialize(x, y, width, height, viewport)
        @commands = []
        @file_location = Essentials::VERSION.include?("21") ? "UI" : "Pictures"
        super(x, y, width, height, viewport)
        @selarrow     = AnimatedBitmap.new("Graphics/#{@file_location}/Berrydex/cursor_list")
        @found        = AnimatedBitmap.new("Graphics/#{@file_location}/Berrydex/icon_found")
        self.baseColor   = Color.new(88, 88, 80)
        self.shadowColor = Color.new(168, 184, 184)
        self.windowskin  = nil
    end
  
    def commands=(value)
        @commands = value
        refresh
    end
  
    def dispose
        @found.dispose
        super
    end
  
    def berry
        return (@commands.length == 0) ? 0 : @commands[self.index][0]
    end
  
    def itemCount
        return @commands.length
    end
  
    def drawItem(index, _count, rect)
      return if index >= self.top_row + self.page_item_max
      rect = Rect.new(rect.x + 16, rect.y, rect.width - 16, rect.height)
      berry     = @commands[index][0]
      indexNumber = @commands[index][2]
      if pbBerryRegistered?(berry)
            if Settings::BERRYDEX_SHOW_NUMBER
                text = sprintf("%02d%s %s", indexNumber, " ", @commands[index][1])
            else
                text = sprintf("%s", @commands[index][1])
            end
            pbCopyBitmap(self.contents, @found.bitmap, rect.x - 6, rect.y + 10)
      else
            if Settings::BERRYDEX_SHOW_NUMBER
                text = sprintf("%02d  ----------", indexNumber)
            else
                text = sprintf("----------")
            end
      end
      pbDrawShadowText(self.contents, rect.x + 36, rect.y + 6, rect.width, rect.height,
                       text, self.baseColor, self.shadowColor)
    end
  
    def refresh
        @item_max = itemCount
        dwidth  = self.width - self.borderX
        dheight = self.height - self.borderY
        self.contents = pbDoEnsureBitmap(self.contents, dwidth, dheight)
        self.contents.clear
        @item_max.times do |i|
            next if i < self.top_item || i > self.top_item + self.page_item_max
            drawItem(i, @item_max, itemRect(i))
        end
        drawCursor(self.index, itemRect(self.index))
    end
  
    def update
        super
        @uparrow&.visible   = false
        @downarrow&.visible = false
    end
end

#===============================================================================
# Berrydex main screen
#===============================================================================
class PokemonBerrydex_Scene
  
    def pbUpdate
        pbUpdateSpriteHash(@sprites)
    end
  
    def pbStartScene
        @file_location = Essentials::VERSION.include?("21") ? "UI" : "Pictures"
        @sliderbitmap       = AnimatedBitmap.new("Graphics/#{@file_location}/Berrydex/icon_slider")
        @sprites = {}
        @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport.z = 99999
        #addBackgroundPlane(@sprites, "background", "Berrydex/bg_list", @viewport)
        @sprites["background"] = IconSprite.new(0, 0, @viewport)
        @sprites["background"].setBitmap("Graphics/#{@file_location}/Berrydex/bg_list")
        @sprites["berrydex"] = Window_Berrydex.new(206, 30, 276, 364, @viewport)
        @sprites["itemicon"] = BerrydexItemIconSprite.new(48, Graphics.height - 48, nil, @viewport)
        @sprites["itemicon"].setOffset(PictureOrigin::CENTER)
        @sprites["itemicon"].item = nil
        @sprites["itemicon"].x = 112
        @sprites["itemicon"].y = 196
        @sprites["unknownicon"] = IconSprite.new(48, Graphics.height - 48, @viewport)
        @sprites["unknownicon"].setBitmap("Graphics/#{@file_location}/Berrydex/unknown")
        @sprites["unknownicon"].ox = @sprites["unknownicon"].width / 2
        @sprites["unknownicon"].oy = @sprites["unknownicon"].height / 2
        @sprites["unknownicon"].x = 112
        @sprites["unknownicon"].y = 196
        @sprites["unknownicon"].visible = false
        @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        pbSetSystemFont(@sprites["overlay"].bitmap)
        $PokemonGlobal.init_berry_index if !$PokemonGlobal.berrydexIndex
        pbRefreshDexList($PokemonGlobal.berrydexIndex[0])
        pbDeactivateWindows(@sprites)
        pbFadeInAndShow(@sprites)
    end
  
    def pbEndScene
        pbFadeOutAndHide(@sprites)
        pbDisposeSpriteHash(@sprites)
        @sliderbitmap.dispose
        @viewport.dispose
    end
      
    def pbGetDexList
        list = pbLoadBerryDexes[0]
        ret = []
        list.each_with_index do |berry, i|
            next if !berry
            berry_data = GameData::BerryData.try_get(berry)
            berry_item = GameData::Item.try_get(berry_data.id)
            color  = berry_data.color
            flavor = berry_data.flavor
            smoothness  = berry_data.smoothness
            #ret.push([berry.id, berry_item.name, i + 1, color, flavor, smoothness])
            ret.push([berry.id, berry_item.name, i + 1])
        end
        return ret
    end
  
    def pbRefreshDexList(index = 0)
        dexlist = pbGetDexList
        if Settings::BERRYDEX_SHOW_ENTIRE_LIST
            # if @only_registered
            #     dexlist.each_with_index { |value, i|
            #         dexlist[i] = nil unless pbBerryRegistered?(value[0])
            #     }
            # end
        else
            # Remove unseen species from the end of the list
            i = dexlist.length - 1
            loop do
                break if i < 0 || !dexlist[i] || pbBerryRegistered?(dexlist[i][0])
                dexlist[i] = nil
                i -= 1
            end
        end
        dexlist.compact!
        # Sort species in ascending order by Dex number
        dexlist.sort! { |a, b| a[2] <=> b[2] }
        @dexlist = dexlist
        @sprites["berrydex"].commands = @dexlist
        @sprites["berrydex"].index    = index
        @sprites["berrydex"].refresh
        @sprites["background"].setBitmap("Graphics/#{@file_location}/Berrydex/bg_list")
        pbRefresh
    end
  
    def pbRefresh
      overlay = @sprites["overlay"].bitmap
      overlay.clear
      base   = Color.new(88, 88, 80)
      shadow = Color.new(168, 184, 184)
      iconberry = @sprites["berrydex"].berry
      iconberry = nil if !pbBerryRegistered?(iconberry)
      # Write various bits of text
      dexname = _INTL("Berrydex")
      textpos = [
        [dexname, Graphics.width / 2, 10, 2, Color.new(248, 248, 248), Color.new(0, 0, 0)]
      ]
      textpos.push([GameData::Item.get(iconberry).name, 112, 58, 2, base, shadow]) if iconberry
      textpos.push([_INTL("Gathered:"), 42, 314, 0, base, shadow])
      textpos.push([pbBerryDexCount.to_s, 182, 314, 1, base, shadow])
      textpos.push([_INTL("Planted:"), 42, 346, 0, base, shadow])
      textpos.push([$stats.berries_planted.to_s, 182, 346, 1, base, shadow])
      # Draw all text
      pbDrawTextPositions(overlay, textpos)
      # Set Pokémon sprite
      setIconBitmap(iconberry)
      # Draw slider arrows
      itemlist = @sprites["berrydex"]
      showslider = false
      if itemlist.top_row > 0
        overlay.blt(468, 48, @sliderbitmap.bitmap, Rect.new(0, 0, 40, 30))
        showslider = true
      end
      if itemlist.top_item + itemlist.page_item_max < itemlist.itemCount
        overlay.blt(468, 346, @sliderbitmap.bitmap, Rect.new(0, 30, 40, 30))
        showslider = true
      end
      # Draw slider box
      if showslider
        sliderheight = 268
        boxheight = (sliderheight * itemlist.page_row_max / itemlist.row_max).floor
        boxheight += [(sliderheight - boxheight) / 2, sliderheight / 6].min
        boxheight = [boxheight.floor, 40].max
        y = 78
        y += ((sliderheight - boxheight) * itemlist.top_row / (itemlist.row_max - itemlist.page_row_max)).floor
        overlay.blt(468, y, @sliderbitmap.bitmap, Rect.new(40, 0, 40, 8))
        i = 0
        while i * 16 < boxheight - 8 - 16
          height = [boxheight - 8 - 16 - (i * 16), 16].min
          overlay.blt(468, y + 8 + (i * 16), @sliderbitmap.bitmap, Rect.new(40, 8, 40, height))
          i += 1
        end
        overlay.blt(468, y + boxheight - 16, @sliderbitmap.bitmap, Rect.new(40, 24, 40, 16))
      end
    end
  
    def setIconBitmap(berry)
        if berry
            @sprites["itemicon"].item = berry
            @sprites["itemicon"].visible = true
            @sprites["unknownicon"].visible = false
        else
            @sprites["itemicon"].item = nil
            @sprites["itemicon"].visible = false
            @sprites["unknownicon"].visible = true
        end
    end
    
    def pbDexEntry(index)
        oldsprites = pbFadeOutAndHide(@sprites)
        scene = BerrydexInfo_Scene.new
        screen = BerrydexInfoScreen.new(scene)
        ret = screen.pbStartScreen(@dexlist, index)
        pbRefreshDexList($PokemonGlobal.berrydexIndex[0])
        $PokemonGlobal.berrydexIndex[0] = ret
        @sprites["berrydex"].index = ret
        @sprites["berrydex"].refresh
        pbRefresh
        pbFadeInAndShow(@sprites, oldsprites)
    end
    
    def pbBerrydex
        pbActivateWindow(@sprites, "berrydex") {
            loop do
                Graphics.update
                Input.update
                oldindex = @sprites["berrydex"].index
                pbUpdate
                if oldindex != @sprites["berrydex"].index
                    $PokemonGlobal.berrydexIndex[0] = @sprites["berrydex"].index
                    pbRefresh
                end
                if Input.trigger?(Input::BACK)
                    pbPlayCloseMenuSE
                    break
                elsif Input.trigger?(Input::USE)
                    if pbBerryRegistered?(@sprites["berrydex"].berry)
                        pbPlayDecisionSE
                        pbDexEntry(@sprites["berrydex"].index)
                    end
                end
            end
        }
    end
end

#===============================================================================
# Berrydex entry screen
#===============================================================================
class BerrydexInfo_Scene
    def pbStartScene(dexlist, index)
        @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport.z = 99999
        @file_location = Essentials::VERSION.include?("21") ? "UI" : "Pictures"
        @dexlist = dexlist
        @index   = index
        @page = 1
        @subpage = 1
        @maxsubpages = 1
        @maxpage = 2
        @maxpage += 1 if pbShowBattlePage?
        @maxpage += 1 if pbShowMutationsPage?
        @berry = @dexlist[@index][0]
        @sprites = {}
        @sprites["background"] = IconSprite.new(0, 0, @viewport)
        @sprites["barcommands"] = IconSprite.new(0, 0, @viewport)
        @sprites["itemicon"] = BerrydexItemIconSprite.new(48, Graphics.height - 48, nil, @viewport)
        @sprites["itemicon"].setOffset(PictureOrigin::CENTER)
        @sprites["itemicon"].item = nil
        @sprites["itemicon"].x = 144
        @sprites["itemicon"].y = 134 - (Settings::BERRYDEX_SHOW_COLOR ? 18 : 0)
        @sprites["berry_plant_dirt"] = IconSprite.new(84, 176, @viewport)
        @sprites["berry_plant_dirt"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/plant_dirt"))
        @sprites["berry_plant_dirt"].zoom_x = @sprites["berry_plant_dirt"].zoom_y = 2
        @sprites["berry_plant_dirt"].visible = false
        @sprites["berry_plant"] = IconSprite.new(112, 108, @viewport)
        @sprites["berry_plant"].visible = false
        if PluginManager.installed?("TDW Berry Planting Improvements","1.3") 
            if pbBerryPreferredWeatherEnabled? && Settings::BERRYDEX_SHOW_PREFERRED_WEATHER && 
                    ((pbBerryPreferredZonesEnabled? && Settings::BERRYDEX_SHOW_PREFERRED_ZONES) || 
                    (pbBerryUnpreferredZonesEnabled? && Settings::BERRYDEX_SHOW_UNPREFERRED_ZONES))
                @sprites["weather_box_split"] = IconSprite.new(12, 268, @viewport)
                @sprites["weather_box_split"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/preferred_weather_box_split"))
                @sprites["weather_box_split"].visible = false
            elsif (pbBerryPreferredWeatherEnabled? && Settings::BERRYDEX_SHOW_PREFERRED_WEATHER) || 
                (pbBerryPreferredZonesEnabled? && Settings::BERRYDEX_SHOW_PREFERRED_ZONES) || 
                (pbBerryUnpreferredZonesEnabled? && Settings::BERRYDEX_SHOW_UNPREFERRED_ZONES)
                @sprites["weather_box"] = IconSprite.new(12, 268, @viewport)
                @sprites["weather_box"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/preferred_weather_box"))
                @sprites["weather_box"].visible = false
            end
        end
        if pbShowBattlePage?


        end
        if pbShowMutationsPage?
            @sprites["barcommands"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/bar_mutations_info"))

            @sprites["mutnamebox"] = IconSprite.new(60, 40, @viewport)
            @sprites["mutnamebox"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/mutation_titles"))
            @sprites["mutnamebox"].visible = false
            @sprites["mutpagebox"] = IconSprite.new(0, 36, @viewport)
            @sprites["mutpagebox"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/mutation_pageindicator"))
            @sprites["mutpagebox"].visible = false
            @sprites["mutbox0"] = IconSprite.new(12, 84, @viewport)
            @sprites["mutbox0"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/mutation_row"))
            @sprites["mutbox0"].visible = false
            @sprites["mutbox1"] = IconSprite.new(12, 234, @viewport)
            @sprites["mutbox1"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/mutation_row2"))
            @sprites["mutbox1"].visible = false
            @sprites["backoverlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
            @sprites["mutboxnone"] = IconSprite.new(146, 192, @viewport)
            @sprites["mutboxnone"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/mutation_none"))
            @sprites["mutboxnone"].visible = false
            6.times { |i|
                @sprites["mutitemicon#{i}"] = BerrydexItemIconSprite.new(0,0, nil, @viewport)
                @sprites["mutitemicon#{i}"].setOffset(PictureOrigin::CENTER)
                @sprites["mutitemicon#{i}"].item = nil
                @sprites["mutitemicon#{i}"].x = 83 + (i%3 == 1 ? 152 : (i%3 == 2 ? 346 : 0 ))
                @sprites["mutitemicon#{i}"].y = 130 + (i>=3 ? 150 : 0)
                @sprites["mutitemicon#{i}"].visible = false
            }
            @sprites["mutmultipleicon0"] = IconSprite.new(0, 0, @viewport)
            @sprites["mutmultipleicon0"].setBitmap("Graphics/#{@file_location}/Berrydex/unknown")
            @sprites["mutmultipleicon0"].ox = @sprites["mutmultipleicon0"].width / 2
            @sprites["mutmultipleicon0"].oy = @sprites["mutmultipleicon0"].height / 2
            @sprites["mutmultipleicon0"].x = 429
            @sprites["mutmultipleicon0"].y = 130
            @sprites["mutmultipleicon0"].visible = false
            @sprites["mutmultipleicon1"] = IconSprite.new(0, 0, @viewport)
            @sprites["mutmultipleicon1"].setBitmap("Graphics/#{@file_location}/Berrydex/unknown")
            @sprites["mutmultipleicon1"].ox = @sprites["mutmultipleicon1"].width / 2
            @sprites["mutmultipleicon1"].oy = @sprites["mutmultipleicon1"].height / 2
            @sprites["mutmultipleicon1"].x = 429
            @sprites["mutmultipleicon1"].y = 280
            @sprites["mutmultipleicon1"].visible = false
        end
        if Essentials::VERSION.include?("21")
            @sprites["uparrow"] = AnimatedSprite.new("Graphics/UI/up_arrow", 8, 28, 40, 2, @viewport)
            @sprites["downarrow"] = AnimatedSprite.new("Graphics/UI/down_arrow", 8, 28, 40, 2, @viewport)
        else
            @sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow", 8, 28, 40, 2, @viewport)
            @sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow", 8, 28, 40, 2, @viewport)
        end
        @sprites["uparrow"].x = 242
        @sprites["uparrow"].y = 268
        @sprites["uparrow"].play
        @sprites["uparrow"].visible = false
        @sprites["downarrow"].x = 242
        @sprites["downarrow"].y = 348
        @sprites["downarrow"].play
        @sprites["downarrow"].visible = false
        if PluginManager.installed?("Better Bitmaps") && Settings::BERRYDEX_USE_PENTAGON_GRAPH
            pentagon_outline_color = Color.new(188,61,219)
            pentagon_back_color = Color.white
            @sprites["pentagonbase"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
            pbDrawStatsPentagonBaseBorder(@sprites["pentagonbase"], 394, 180, 30, 8, pentagon_outline_color, pentagon_back_color)
            @sprites["pentagonbase"].visible = false
            @sprites["pentagonstats"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
            @sprites["pentagonstats"].visible = false
        else
            @sprites["circled_spicy"] = IconSprite.new(356, 92, @viewport)
            @sprites["circled_spicy"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/flavor_selected"))
            @sprites["circled_spicy"].visible = false
            @sprites["circled_dry"] = IconSprite.new(420, 146, @viewport)
            @sprites["circled_dry"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/flavor_selected"))
            @sprites["circled_dry"].visible = false
            @sprites["circled_sweet"] = IconSprite.new(398, 212, @viewport)
            @sprites["circled_sweet"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/flavor_selected"))
            @sprites["circled_sweet"].visible = false
            @sprites["circled_bitter"] = IconSprite.new(314, 212, @viewport)
            @sprites["circled_bitter"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/flavor_selected"))
            @sprites["circled_bitter"].visible = false
            @sprites["circled_sour"] = IconSprite.new(292, 146, @viewport)
            @sprites["circled_sour"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/flavor_selected"))
            @sprites["circled_sour"].visible = false
        end

        @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        pbSetSystemFont(@sprites["overlay"].bitmap)
        drawPage(@page)
        pbFadeInAndShow(@sprites) { pbUpdate }
    end
  
    def pbEndScene
        pbFadeOutAndHide(@sprites) { pbUpdate }
        pbDisposeSpriteHash(@sprites)
        @viewport.dispose
    end
  
    def pbUpdate
        pbUpdateSpriteHash(@sprites)  
    end
  
    def drawPage(page)
        overlay = @sprites["overlay"].bitmap
        overlay.clear
        @sprites["backoverlay"].bitmap.clear if @sprites["backoverlay"]
        # Make certain sprites visible
        @sprites["itemicon"].item = @berry
        @sprites["itemicon"].visible = (@page == 1)
        @sprites["pentagonbase"]&.visible = (@page == 1)
        @sprites["pentagonstats"]&.visible = (@page == 1)
        @sprites["berry_plant"].visible = (@page == 2)
        @sprites["berry_plant_dirt"].visible = (@page == 2)
        @sprites["weather_box"]&.visible = (@page == 2)
        @sprites["weather_box_split"]&.visible = (@page == 2)
        pbHideMutationsIcons if @page < (pbShowBattlePage? ? 4 : 3)
        # Draw page-specific information
        case page
        when 1 
            if pbShowBattlePage? && pbShowMutationsPage?
                @sprites["barcommands"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/bar_battle_mutations_info"))
                @sprites["barcommands"].visible = true
            elsif pbShowBattlePage?
                @sprites["barcommands"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/bar_battle_info"))
                @sprites["barcommands"].visible = true
            elsif pbShowMutationsPage?
                @sprites["barcommands"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/bar_mutations_info"))
                @sprites["barcommands"].visible = true
            else
                @sprites["barcommands"].visible = false
            end
            drawPageInfo
        when 2 
            if pbShowBattlePage? && pbShowMutationsPage?
                @sprites["barcommands"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/bar_battle_mutations_plant"))
                @sprites["barcommands"].visible = true
            elsif pbShowBattlePage?
                @sprites["barcommands"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/bar_battle_plant"))
                @sprites["barcommands"].visible = true
            elsif pbShowMutationsPage?
                @sprites["barcommands"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/bar_mutations_plant"))
                @sprites["barcommands"].visible = true
            else
                @sprites["barcommands"].visible = false
            end
            drawPagePlant
        when 3 
            if pbShowBattlePage?
                if pbShowMutationsPage?
                    @sprites["barcommands"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/bar_mutations_battle"))
                    @sprites["barcommands"].visible = true
                else
                    @sprites["barcommands"].visible = false
                end
                drawPageBattle
            else
                @sprites["barcommands"].visible = false
                drawPageMutations
            end
        when 4 
            @sprites["barcommands"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/bar_battle_mutations"))
            @sprites["barcommands"].visible = true
            drawPageMutations
        end
    end
  
    def drawPageInfo
        draw_color = Settings::BERRYDEX_SHOW_COLOR
        color_path = draw_color ? "_color" : ""
        if PluginManager.installed?("Better Bitmaps") && Settings::BERRYDEX_USE_PENTAGON_GRAPH
            @sprites["background"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/bg_info#{color_path}_graph"))
        else
            @sprites["background"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/bg_info#{color_path}"))
        end
        overlay = @sprites["overlay"].bitmap
        base   = Color.new(88, 88, 80)
        shadow = Color.new(168, 184, 184)
        imagepos = []
        berry_data = GameData::BerryData.try_get(@berry)
        berry_item = GameData::Item.try_get(berry_data.id)
        # Show the found icon
        imagepos.push(["Graphics/#{@file_location}/Berrydex/icon_found", 16, 44])
        # Write various bits of text
        indexText = ""
        if Settings::BERRYDEX_SHOW_NUMBER
            if @dexlist[@index][2] > 0
                indexNumber = @dexlist[@index][2]
                indexText = sprintf("%02d", indexNumber)
            else
                indexText = "??"
            end
        end
        textpos = [
            [_INTL("{1}{2} {3}", indexText, " ", berry_item.name),
            50, 48, 0, Color.new(248, 248, 248), Color.new(0, 0, 0)]
        ]
        yPos = draw_color ? 164 : 198
        textpos.push([_INTL("Size"), 64, yPos, 0, base, shadow])
        textpos.push([_INTL("Firm"), 64, yPos + 34, 0, base, shadow])
        size = berry_data.size
        if System.user_language[3..4] == "US"   # If the user is in the United States
            inches = (size / 2.54).round(1)
            # textpos.push([_ISPRINTF("{1:.1f}\"", inches), 210, yPos, 1, base, shadow])
            textpos.push([_ISPRINTF("{1:.1f}\"", inches), 244, yPos, 1, base, shadow])
        else
            # textpos.push([_ISPRINTF("{1:.1f} cm", size), 220, yPos, 1, base, shadow])
            textpos.push([_ISPRINTF("{1:.1f} cm", size), 244, yPos, 1, base, shadow])
        end
        firmness = berry_data.firmness
        textpos.push([firmness, 244, yPos + 34, 1, base, shadow])
        if draw_color
            textpos.push([_INTL("Color"), 64, yPos + 68, 0, base, shadow])
            color = GameData::BerryColor.get(berry_data.color)
            textpos.push([color.name, 244, yPos + 68, 1, color.base_color, color.shadow_color])
        end
        max_flavor = berry_data.flavor.values.max
        if PluginManager.installed?("Better Bitmaps") && Settings::BERRYDEX_USE_PENTAGON_GRAPH
            pentagon_stat_color = Color.new(71,226,191)
            @sprites["pentagonstats"].bitmap.clear
            @sprites["pentagonstats"].opacity = 180
            flav = []
            berry_data.flavor.each { |key, value| flav.push(value+8) }
            pbDrawStatsPentagonFlavor(@sprites["pentagonstats"],flav, 
                    Settings::BERRYDEX_MAX_FLAVOR + 8, 394, 180, 30, 8, pentagon_stat_color)
        else
            berry_data.flavor.each { |key, value| @sprites["circled_#{key.downcase}"].visible = (value >= max_flavor)}
        end
        drawTextEx(overlay, 40, 278, Graphics.width - (40 * 2), 3,   # overlay, x, y, width, num lines
                berry_data.description, base, shadow)
        # Draw all text
        pbDrawTextPositions(overlay, textpos)
        # Draw all images
        pbDrawImagePositions(overlay, imagepos)
    end
 
    def drawPagePlant
        @sprites["background"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/bg_plant"))
        overlay = @sprites["overlay"].bitmap
        base   = Color.new(88, 88, 80)
        shadow = Color.new(168, 184, 184)
        imagepos = []
        berry_data = GameData::BerryData.try_get(@berry)
        berry_item = GameData::Item.try_get(berry_data.id)
        plant_data = GameData::BerryPlant.try_get(berry_data.id)
        @sprites["circled_spicy"]&.visible = false
        @sprites["circled_dry"]&.visible = false
        @sprites["circled_sweet"]&.visible = false
        @sprites["circled_bitter"]&.visible = false
        @sprites["circled_sour"]&.visible = false
        # Show the found icon
        imagepos.push(["Graphics/#{@file_location}/Berrydex/icon_found", 16, 44])
        # Write various bits of text
        indexText = ""
        if Settings::BERRYDEX_SHOW_NUMBER
            if @dexlist[@index][2] > 0
                indexNumber = @dexlist[@index][2]
                indexText = sprintf("%02d", indexNumber)
            else
                indexText = "??"
            end
        end
        textpos = [
            [_INTL("{1}{2} {3}", indexText, " ", berry_item.name),
            50, 48, 0, Color.new(248, 248, 248), Color.new(0, 0, 0)]
        ]
        if PluginManager.installed?("TDW Berry Planting Improvements","1.9") && Settings::BERRY_PREFERRED_SOIL_ENABLED && Settings::BERRYDEX_SHOW_PREFERRED_SOIL
            if Settings::BERRY_SOIL_DEFINITIONS[berry_data.preferred_soil]
                @sprites["berry_plant_dirt"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/plant_dirt#{Settings::BERRY_SOIL_DEFINITIONS[berry_data.preferred_soil][:dex_graphic_ext]}"))
            else
                @sprites["berry_plant_dirt"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/plant_dirt"))
            end
        end

        filename = sprintf("berrytree_%s", berry_item.id.to_s)
        if pbResolveBitmap("Graphics/Characters/" + filename)
            @sprites["berry_plant"].setBitmap("Graphics/Characters/" + filename)
            @sprites["berry_plant"].src_rect.x = 0
            @sprites["berry_plant"].src_rect.y = @sprites["berry_plant"].height*3/4
            @sprites["berry_plant"].src_rect.width = @sprites["berry_plant"].width/4
            @sprites["berry_plant"].src_rect.height = @sprites["berry_plant"].height/4
            @sprites["berry_plant"].zoom_x = @sprites["berry_plant"].zoom_y = 2
            @sprites["berry_plant"].visible = true
        else
            @sprites["berry_plant"].visible = false
        end

        textpos.push([_INTL("Growth Time"), 286, 150, 0, base, shadow])
        textpos.push([_INTL("Harvest"), 286, 184, 0, base, shadow])
        textpos.push([_INTL("Dry Rate"), 286, 218, 0, base, shadow])

        time = plant_data.hours_per_stage * 4
        textpos.push([_ISPRINTF("{1:d} hrs", time), 498, 150, 1, base, shadow])

        harvest = plant_data.yield
        textpos.push([_ISPRINTF("{1:d} - {2:d}", harvest[0], harvest[1]), 498, 184, 1, base, shadow])

        dry = pbGetDryRateName(plant_data.drying_per_hour)
        textpos.push([dry, 498, 218, 1, base, shadow])

        if @sprites["weather_box"]
            if pbBerryPreferredWeatherEnabled? && Settings::BERRYDEX_SHOW_PREFERRED_WEATHER
                weather = berry_data.preferred_weather
                textpos.push([_INTL("Ideal Weather"), Graphics.width/2, 278, 2, base, shadow])
                if weather.length > 0
                    @sprites["weather_box"].visible = true
                    xPos = 172 # 202, 232
                    xPos = 232 if weather.length == 1
                    xPos = 202 if weather.length == 2
                    weather.each_with_index do |w, i|
                        break if i >= 6
                        w = GameData::Weather.get(w).id.to_sym
                        imagepos.push(["Graphics/#{@file_location}/Berrydex/Plant Icons/#{w}", xPos + i*60, 310])
                    end
                else
                    @sprites["weather_box"].visible = false
                end
            else
                zones = (pbBerryPreferredZonesEnabled? && Settings::BERRYDEX_SHOW_PREFERRED_ZONES) ? berry_data.preferred_zones : []
                unzones = (pbBerryUnpreferredZonesEnabled? && Settings::BERRYDEX_SHOW_UNPREFERRED_ZONES) ? berry_data.unpreferred_zones : []
                zone_text = (pbBerryPreferredZonesEnabled? && Settings::BERRYDEX_SHOW_PREFERRED_ZONES) ? _INTL("Ideal #{Settings::BERRYDEX_PREFERRED_ZONES_TERM}") : _INTL("Unideal #{Settings::BERRYDEX_PREFERRED_ZONES_TERM}")
                textpos.push([zone_text, Graphics.width/2, 278, 2, base, shadow])
                total = zones.length + unzones.length
                total_i = 0
                xPos = 172
                xPos = 232 if total == 1
                xPos = 202 if total == 2
                if zones.length > 0
                    zones.each_with_index do |z, i|
                        z = z.upcase
                        imagepos.push(["Graphics/#{@file_location}/Berrydex/Plant Icons/#{z}", xPos + 60*total_i, 310])
                        total_i += 1
                        break if total_i >= 6
                    end
                end
                if unzones.length > 0
                    unzones.each_with_index do |z, i|
                        break if total_i >= 6
                        z = z.upcase
                        imagepos.push(["Graphics/#{@file_location}/Berrydex/Plant Icons/#{z}_UNPREF", xPos + 60*total_i, 310])
                        total_i += 1
                        break if total_i >= 6
                    end
                end

            end
        end
        if @sprites["weather_box_split"]
            weather = berry_data.preferred_weather
            zones = (pbBerryPreferredZonesEnabled? && Settings::BERRYDEX_SHOW_PREFERRED_ZONES) ? berry_data.preferred_zones : []
            unzones = (pbBerryUnpreferredZonesEnabled? && Settings::BERRYDEX_SHOW_UNPREFERRED_ZONES) ? berry_data.unpreferred_zones : []
            textpos.push([_INTL("Ideal Weather"), Graphics.width/4+2, 278, 2, base, shadow])
            zone_text = (pbBerryPreferredZonesEnabled? && Settings::BERRYDEX_SHOW_PREFERRED_ZONES) ? _INTL("Ideal #{Settings::BERRYDEX_PREFERRED_ZONES_TERM}") : _INTL("Unideal #{Settings::BERRYDEX_PREFERRED_ZONES_TERM}")
            textpos.push([zone_text, 3*Graphics.width/4+2, 278, 2, base, shadow])
            if weather.length > 0
                xPos = 54
                xPos = 106 if weather.length == 1
                xPos = 80 if weather.length == 2
                weather.each_with_index do |w, i|
                    break if i >= 3
                    w = GameData::Weather.get(w).id.to_sym
                    imagepos.push(["Graphics/#{@file_location}/Berrydex/Plant Icons/#{w}", xPos + 52*i, 310])
                end
            end
            if zones.length > 0 || unzones.length > 0
                total = zones.length + unzones.length
                total_i = 0
                xPos = 306
                xPos = 358 if total == 1
                xPos = 332 if total == 2
                if zones.length > 0
                    zones.each_with_index do |z, i|
                        z = z.upcase
                        imagepos.push(["Graphics/#{@file_location}/Berrydex/Plant Icons/#{z}", xPos + 52*total_i, 310])
                        total_i += 1
                        break if total_i >= 3
                    end
                end
                if unzones.length > 0
                    unzones.each_with_index do |z, i|
                        break if total_i >= 3
                        z = z.upcase
                        imagepos.push(["Graphics/#{@file_location}/Berrydex/Plant Icons/#{z}_UNPREF", xPos + 52*total_i, 310])
                        total_i += 1
                        break if total_i >= 3
                    end
                end
            end
        end

        # Draw all text
        pbDrawTextPositions(overlay, textpos)
        # Draw all images
        pbDrawImagePositions(overlay, imagepos)
    end
  
    def drawPageBattle
        @sprites["background"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/bg_battle"))
        overlay = @sprites["overlay"].bitmap
        base   = Color.new(88, 88, 80)
        shadow = Color.new(168, 184, 184)
        imagepos = []
        berry_data = GameData::BerryData.try_get(@berry)
        berry_item = GameData::Item.try_get(berry_data.id)
        # Show the found icon
        imagepos.push(["Graphics/#{@file_location}/Berrydex/icon_found", 16, 44])
        # Write various bits of text
        indexText = ""
        if Settings::BERRYDEX_SHOW_NUMBER
            if @dexlist[@index][2] > 0
                indexNumber = @dexlist[@index][2]
                indexText = sprintf("%02d", indexNumber)
            else
                indexText = "??"
            end
        end
        textpos = [
            [_INTL("{1}{2} {3}", indexText, " ", berry_item.name),
            50, 48, 0, Color.new(248, 248, 248), Color.new(0, 0, 0)]
        ]
        fling = nil
        natural = nil
        berry_item.flags.each do |flag|
            fling = [$~[1].to_i, 10].max if flag[/^Fling_(\d+)$/i]
            natural = [$~[1].to_sym,[$~[2].to_i, 10].max] if flag[/^NaturalGift_(\w+)_(\d+)$/i]
            break if fling && natural
        end

        yPos = 108
        textpos.push([_INTL("Fling"), 176, yPos, 0, base, shadow])
        textpos.push([fling&.to_s || 0, 356, yPos, 1, base, shadow])

        textpos.push([_INTL("Natural Gift"), 260, yPos + 34, 2, base, shadow])
        textpos.push([_INTL("Type"), 176, yPos + 68, 0, base, shadow])
        textpos.push([_INTL("Power"), 176, yPos + 102, 0, base, shadow])
        textpos.push([natural[1].to_s, 356, yPos + 102, 1, base, shadow])

        type_bitmap = AnimatedBitmap.new(_INTL("Graphics/#{@file_location}/types"))
        type_number = GameData::Type.get(natural[0]).icon_position
        type_rect = Rect.new(0, type_number * 28, 64, 28)
        overlay.blt(292, yPos + 64, type_bitmap.bitmap, type_rect)

        battle_description = berry_data.battle_description || berry_item.description
        drawTextEx(overlay, 40, 278, Graphics.width - (40 * 2), 3,   # overlay, x, y, width, num lines
            battle_description, base, shadow)

        # Draw all text
        pbDrawTextPositions(overlay, textpos)
        # Draw all images
        pbDrawImagePositions(overlay, imagepos)
    end

    def drawPageMutations
        pbHideMutationsIcons
        @sprites["background"].setBitmap(_INTL("Graphics/#{@file_location}/Berrydex/bg_mutation"))
        overlay = @sprites["overlay"].bitmap
        base   = Color.new(88, 88, 80)
        shadow = Color.new(168, 184, 184)
        textpos = []
        imagepos = []
        berry_data = GameData::BerryData.try_get(@berry)
        berry_item = GameData::Item.try_get(berry_data.id)
        mutations = pbGetMutationInfo
        # Write various bits of text
        if mutations.length > 0
            @maxsubpages = ((mutations.length-1)/2).floor + 1
            if @maxsubpages > 1
                @sprites["mutpagebox"].visible = true
                textpos.push([_INTL("{1}/{2}",@subpage,@maxsubpages), 24, 40, 2, base, shadow])
            end
            (@subpage-1).times { mutations.shift(2) }
            @sprites["mutnamebox"].visible = true
            @sprites["mutbox0"].visible = true
            @sprites["mutbox1"].visible = true if mutations.length > 1
            textpos.push([_INTL("Parents"), 158, 48, 2, Color.new(248, 248, 248), Color.new(0, 0, 0)])
            textpos.push([_INTL("Offspring"), 428, 48, 2, Color.new(248, 248, 248), Color.new(0, 0, 0)])
            mutations.each_with_index { |mutation,i|
                break if i >= 2
                parent_one = mutation[0]
                parent_two = mutation[1]
                children = mutation[2]
                icon_number = (i == 0 ? 0 : 3)
                imagepos.push(["Graphics/#{@file_location}/Berrydex/mutation_choice", 20, 98 + i*150]) if parent_one == @berry
                if pbBerryRegistered?(parent_one) || !Settings::BERRY_MUTATION_HIDE_UNREGISTERED
                    drawFormattedTextEx(overlay, 22, 168 + i*150, 122,    # overlay, x, y, width, 
                        "<ac>" + GameData::Item.try_get(parent_one).name, base, shadow, 30)
                    @sprites["mutitemicon#{icon_number}"].item = parent_one
                else
                    drawFormattedTextEx(overlay, 22, 168 + i*150, 122,   
                        "<ac>???", base, shadow, 30)
                        @sprites["mutitemicon#{icon_number}"].item = nil
                end
                @sprites["mutitemicon#{icon_number}"].visible = true
                imagepos.push(["Graphics/#{@file_location}/Berrydex/mutation_choice", 172, 98 + i*150]) if parent_two == @berry
                if pbBerryRegistered?(parent_two) || !Settings::BERRY_MUTATION_HIDE_UNREGISTERED
                    drawFormattedTextEx(overlay, 174, 168 + i*150, 122,    # overlay, x, y, width, 
                        "<ac>" + GameData::Item.try_get(parent_two).name, base, shadow, 30)
                    @sprites["mutitemicon#{icon_number+1}"].item = parent_two
                else
                    drawFormattedTextEx(overlay, 174, 168 + i*150, 122,   
                        "<ac>???", base, shadow, 30)
                        @sprites["mutitemicon#{icon_number+1}"].item = nil
                end
                @sprites["mutitemicon#{icon_number+1}"].visible = true
                if children.include?(@berry)
                    imagepos.push(["Graphics/#{@file_location}/Berrydex/mutation_choice", 366, 98 + i*150])
                    drawFormattedTextEx(overlay, 368, 168 + i*150, 122,   # overlay, x, y, width, num lines
                        "<ac>" + berry_item.name, base, shadow, 30)
                    @sprites["mutitemicon#{icon_number+2}"].item = @berry
                    @sprites["mutitemicon#{icon_number+2}"].visible = true
                elsif children.length == 1
                    if pbBerryRegistered?(children[0])
                        drawFormattedTextEx(overlay, 368, 168 + i*150, 122,   # overlay, x, y, width, num lines
                            "<ac>" + GameData::Item.try_get(children[0]).name, base, shadow, 30)
                        @sprites["mutitemicon#{icon_number+2}"].item = children[0]
                        @sprites["mutitemicon#{icon_number+2}"].visible = true
                    else
                        textpos.push([_INTL("???"), 428, 168 + i*150, 2, base, shadow])
                        @sprites["mutmultipleicon0"].visible = true
                    end
                else
                    textpos.push([_INTL("Multiple"), 428, 168 + i*150, 2, base, shadow])
                    @sprites["mutmultipleicon0"].visible = true
                end
            }
        else
            @maxsubpages = 1
            @sprites["mutboxnone"].visible = true
            textpos.push([_INTL("No Mutation Data"), 256, 200, 2, Color.new(248, 248, 248), Color.new(0, 0, 0)])
        end

        # Draw all text
        pbDrawTextPositions(overlay, textpos)
        # Draw all images
        pbDrawImagePositions( @sprites["backoverlay"].bitmap, imagepos)
    end

    def pbGetDryRateName(rate)
        Settings::BERRYDEX_DRY_RATE_CATEGORIES.each do |i|
            return i[0] if rate.between?(i[1],i[2])
        end
        return _INTL("???")
    end

    def pbGetMutationInfo
        info = []
        Settings::BERRY_MUTATION_POSSIBILITIES.each { |key,value| 
            info.push([key[0],key[1],value]) if key.include?(@berry) || value.include?(@berry)
        }
        return info
    end

    def pbGoToPrevious
        newindex = @index
        while newindex > 0
            newindex -= 1
            if pbBerryRegistered?(@dexlist[newindex][0])
                @index = newindex
                break
            end
        end
    end
  
    def pbGoToNext
        newindex = @index
        while newindex < @dexlist.length - 1
            newindex += 1
            if pbBerryRegistered?(@dexlist[newindex][0])
                @index = newindex
                break
            end
        end
    end
    
    def pbScene
        loop do
            Graphics.update
            Input.update
            pbUpdate
            dorefresh = false
            if Input.trigger?(Input::ACTION)
                pbSEStop
            elsif Input.trigger?(Input::BACK)
                pbPlayCloseMenuSE
                break
            elsif Input.trigger?(Input::USE)
                case @page
                when 1   # Info
                    dorefresh = true
                when 2   # Plant
                    dorefresh = true
                when 3   # Mutations
                    if @maxsubpages > 1
                        pbPlayCursorSE
                        @subpage += 1
                        @subpage = 1 if @subpage > @maxsubpages
                    end
                    dorefresh = true
                end 
            elsif Input.trigger?(Input::UP)
                oldindex = @index
                pbGoToPrevious
                if @index != oldindex
                    @berry = @dexlist[@index][0]
                    @subpage = 1
                    pbSEStop
                    pbPlayCursorSE
                    dorefresh = true
                end
            elsif Input.trigger?(Input::DOWN)
                oldindex = @index
                pbGoToNext
                if @index != oldindex
                    @berry = @dexlist[@index][0]
                    @subpage = 1
                    pbSEStop
                    pbPlayCursorSE
                    dorefresh = true
                end
            elsif Input.trigger?(Input::LEFT)
              oldpage = @page
              @page -= 1
              @page = 1 if @page < 1
              @page = @maxpage if @page > @maxpage
              if @page != oldpage
                pbPlayCursorSE
                dorefresh = true
              end
            elsif Input.trigger?(Input::RIGHT)
              oldpage = @page
              @page += 1
              @page = 1 if @page < 1
              @page = @maxpage if @page > @maxpage
              if @page != oldpage
                pbPlayCursorSE
                dorefresh = true
              end
            end
            if dorefresh
                drawPage(@page)
            end
        end
        return @index
    end

    def pbShowBattlePage?
        return Settings::BERRYDEX_BATTLE_PAGE
    end

    def pbShowMutationsPage?
        return PluginManager.installed?("TDW Berry Planting Improvements","1.3") && Settings::BERRYDEX_MUTATIONS_PAGE
    end

    def pbHideMutationsIcons
        return if !pbShowMutationsPage?
        @sprites["mutnamebox"].visible = false
        @sprites["mutpagebox"].visible = false
        @sprites["mutbox0"].visible = false
        @sprites["mutbox1"].visible = false
        @sprites["mutboxnone"].visible = false
        6.times { |i| @sprites["mutitemicon#{i}"].visible = false }
        @sprites["mutmultipleicon0"].visible = false
        @sprites["mutmultipleicon1"].visible = false
    end
  
end
  
class BerrydexInfoScreen
    def initialize(scene)
        @scene = scene
    end
  
    def pbStartScreen(dexlist, index)
        @scene.pbStartScene(dexlist, index)
        ret = @scene.pbScene
        @scene.pbEndScene
        return ret   # Index of last viewed in dexlist
    end
  
    def pbStartSceneSingle(berry)   # For use from an item's command list
        dexnum = pbGetBerrydexNumber(berry)
        dexlist = [[berry, GameData::Item.get(berry).name, dexnum, 0]]
        @scene.pbStartScene(dexlist, 0)
        @scene.pbScene
        @scene.pbEndScene
    end
end

#===============================================================================
#
#===============================================================================
class PokemonBerrydexScreen
    def initialize(scene)
      @scene = scene
    end
  
    def pbStartScreen
      @scene.pbStartScene
      @scene.pbBerrydex
      @scene.pbEndScene
    end
  end

#===============================================================================
# Berrydex Item icon
#===============================================================================
class BerrydexItemIconSprite < Sprite
    attr_reader :item
    attr_reader :tag_icon
  
    def initialize(x, y, item, viewport = nil)
        super(viewport)
        @file_location = Essentials::VERSION.include?("21") ? "UI" : "Pictures"
        @bitmap = nil
        @tag_icon = false
        self.x = x
        self.y = y
        @forceitemchange = true
        self.item = item
        @forceitemchange = false
    end
  
    def dispose
        @bitmap&.dispose
        super
    end
  
    def width
        return 0 if !self.bitmap || self.bitmap.disposed?
        return self.bitmap.width
    end
  
    def height
        return (self.bitmap && !self.bitmap.disposed?) ? self.bitmap.height : 0
    end
  
    def setOffset(offset = PictureOrigin::CENTER)
        @offset = offset
        changeOrigin
    end
  
    def changeOrigin
        @offset = PictureOrigin::CENTER if !@offset
        case @offset
        when PictureOrigin::TOP_LEFT, PictureOrigin::TOP, PictureOrigin::TOP_RIGHT
            self.oy = 0
        when PictureOrigin::LEFT, PictureOrigin::CENTER, PictureOrigin::RIGHT
            self.oy = self.height / 2
        when PictureOrigin::BOTTOM_LEFT, PictureOrigin::BOTTOM, PictureOrigin::BOTTOM_RIGHT
            self.oy = self.height
        end
        case @offset
        when PictureOrigin::TOP_LEFT, PictureOrigin::LEFT, PictureOrigin::BOTTOM_LEFT
            self.ox = 0
        when PictureOrigin::TOP, PictureOrigin::CENTER, PictureOrigin::BOTTOM
            self.ox = self.width / 2
        when PictureOrigin::TOP_RIGHT, PictureOrigin::RIGHT, PictureOrigin::BOTTOM_RIGHT
            self.ox = self.width
        end
    end
  
    def item=(value)
        return if @item == value && !@forceitemchange
        @item = value
        @bitmap&.dispose
        @bitmap = nil
        if @item
            if Settings::BERRYDEX_USE_TAG_ICONS && pbResolveBitmap("Graphics/#{@file_location}/Berrydex/Tag Icons/" + value.to_s)
                @bitmap = AnimatedBitmap.new("Graphics/#{@file_location}/Berrydex/Tag Icons/" + value.to_s)
                self.bitmap = @bitmap.bitmap
                self.src_rect = Rect.new(0, 0, self.bitmap.width, self.bitmap.height)
            else
                @bitmap = AnimatedBitmap.new(GameData::Item.icon_filename(@item))
                self.bitmap = @bitmap.bitmap
                self.src_rect = Rect.new(0, 0, self.bitmap.width, self.bitmap.height)
            end
        else
            @bitmap = AnimatedBitmap.new("Graphics/#{@file_location}/Berrydex/unknown")
            self.bitmap = @bitmap.bitmap
            self.src_rect = Rect.new(0, 0, self.bitmap.width, self.bitmap.height)
        end
        changeOrigin
    end
  end

#===============================================================================
#
#===============================================================================
class PokemonGlobalMetadata
    attr_accessor :berrydexIndex

    alias tdw_berry_dex_ui_global_init initialize
    def initialize
        tdw_berry_dex_ui_global_init
        init_berry_index
    end

    def init_berry_index
        @berrydexIndex = []
        @berrydexIndex[0] = 0
    end
end