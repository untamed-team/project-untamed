#===============================================================================
# pbChooseBerryMultiple
#===============================================================================
def pbChooseBerryMultiple(count = 2, allowLess = true, remove = true, label = :Color)
    count = count.clamp(0,6)
    if !$bag.hasAnyBerry?
        pbMessage(_INTL("You don't have any berries!"))
        return false
    end
    berries = nil
    pbFadeOutIn {
        scene = ChooseBerryMultiple_Scene.new(count, label)
        screen = ChooseBerryMultipleScreen.new(scene, $bag, allowLess)
        berries = screen.pbStartScreen(proc { |item| GameData::Item.get(item).pocket == 5 && GameData::Item.get(item).is_berry? })
    }
    return nil if !berries || berries.empty?
    berries.each { |b| b = GameData::Item.get(b).id; $bag.remove(b, 1) } if remove
    return berries
end

#===============================================================================
# Choose Berry Multiple Scene
#=============================================================================== 
class ChooseBerryMultiple_Scene
    attr_accessor         :selectedBerries
    attr_accessor         :count
    attr_accessor         :label
    ITEMLISTBASECOLOR     = Color.new(88, 88, 80)
    ITEMLISTSHADOWCOLOR   = Color.new(168, 184, 184)
    ITEMTEXTBASECOLOR     = Color.new(248, 248, 248)
    ITEMTEXTSHADOWCOLOR   = Color.new(0, 0, 0)
    ITEMSVISIBLE          = 7
  
    def initialize(count, label)
        @count = count
        @label = label
    end
  
    def pbStartScene(bag, choosing, filterproc)
        @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport.z = 99999
        @file_location = Essentials::VERSION.include?("21") ? "UI" : "Pictures"
        @bag        = bag
        @choosing   = choosing
        @filterproc = filterproc
        @selectedBerries = []
        pbRefreshFilter
        # if @choosing
        #     if (@filterlist && @filterlist.length == 0)
    
        #     end
        # end
        @sliderbitmap = AnimatedBitmap.new("Graphics/#{@file_location}/Bag/icon_slider")
        @sprites = {}
        @sprites["background"] = IconSprite.new(0, 0, @viewport)
        @sprites["background"].setBitmap(sprintf("Graphics/#{@file_location}/Berrydex/bg_berry_selection"))
        @sprites["selectedberries"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        drawSelectedBerryCircles
        @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        pbSetSystemFont(@sprites["overlay"].bitmap)
        @sprites["itemlist"] = Window_ChooseBerryMultiple.new(@bag, @filterlist, self, 168, -8, 314, 40 + 32 + (ITEMSVISIBLE * 32))
        @sprites["itemlist"].viewport    = @viewport
        @sprites["itemlist"].index       = 0
        @sprites["itemlist"].baseColor   = ITEMLISTBASECOLOR
        @sprites["itemlist"].shadowColor = ITEMLISTSHADOWCOLOR
        @sprites["itemicon"] = ItemIconSprite.new(48, Graphics.height - 48, nil, @viewport)
        @sprites["itemtext"] = Window_UnformattedTextPokemon.newWithSize(
            "", 72, 272, Graphics.width - 72 - 24, 128, @viewport
        )
        @sprites["itemtext"].baseColor   = ITEMTEXTBASECOLOR
        @sprites["itemtext"].shadowColor = ITEMTEXTSHADOWCOLOR
        @sprites["itemtext"].visible     = true
        @sprites["itemtext"].windowskin  = nil
        @sprites["itemlabel"] = BitmapSprite.new(186, 64, @viewport)
        @sprites["itemlabel"].y = 224
        pbSetSystemFont(@sprites["itemlabel"].bitmap)
        @sprites["helpwindow"] = Window_UnformattedTextPokemon.new("")
        @sprites["helpwindow"].visible  = false
        @sprites["helpwindow"].viewport = @viewport
        @sprites["msgwindow"] = Window_AdvancedTextPokemon.new("")
        @sprites["msgwindow"].visible  = false
        @sprites["msgwindow"].viewport = @viewport
        pbBottomLeftLines(@sprites["helpwindow"], 1)
        pbDeactivateWindows(@sprites)
        pbRefresh
        pbFadeInAndShow(@sprites)
    end
  
    def pbFadeOutScene
        @oldsprites = pbFadeOutAndHide(@sprites)
    end
  
    def pbFadeInScene
        pbFadeInAndShow(@sprites, @oldsprites)
        @oldsprites = nil
    end

    def pbUpdate
        pbUpdateSpriteHash(@sprites)
    end
  
    def pbEndScene
        pbFadeOutAndHide(@sprites) if !@oldsprites
        @oldsprites = nil
        dispose
    end
  
    def dispose
        pbDisposeSpriteHash(@sprites)
        @sliderbitmap.dispose
        @viewport.dispose
    end
  
    def pbDisplay(msg, brief = false)
        UIHelper.pbDisplay(@sprites["msgwindow"], msg, brief) { pbUpdate }
    end
  
    def pbConfirm(msg)
        UIHelper.pbConfirm(@sprites["msgwindow"], msg) { pbUpdate }
    end
  
    def pbChooseNumber(helptext, maximum, initnum = 1)
        return UIHelper.pbChooseNumber(@sprites["helpwindow"], helptext, maximum, initnum) { pbUpdate }
    end
  
    def pbShowCommands(helptext, commands, index = 0)
        return UIHelper.pbShowCommands(@sprites["helpwindow"], helptext, commands, index) { pbUpdate }
    end
  
    def pbRefresh
        # Refresh the item window
        @sprites["itemlist"].refresh
        # Refresh more things
        drawSelectedBerries
        pbRefreshIndexChanged
    end
    
    def drawSelectedBerryCircles
        imagepos = []
        xPos = 25
        odd = @count.odd?
        case @count
        when 1..2 then yPos = 84
        when 3..4 then yPos = 56
        else yPos = 10
        end
        
        @count.times { |i| 
            xPos += 38 if odd && i+1 == @count
            imagepos.push(["Graphics/#{@file_location}/Berrydex/berry_select_circle", xPos + 74*(i%2), yPos + 74*(i/2)])
            @sprites["berryicon#{i}"] = ItemIconSprite.new(xPos + 30 + 74*(i%2), yPos + 30 + 74*(i/2), nil, @viewport)
            @sprites["berryicon#{i}"].visible = false
        }
        pbDrawImagePositions(@sprites["selectedberries"].bitmap, imagepos)
    end
    
    def drawSelectedBerries
        @count.times { |i| 
            next if !@selectedBerries[i]
            @sprites["berryicon#{i}"].item = @selectedBerries[i]
            @sprites["berryicon#{i}"].visible = true
        }
    end
  
    def pbRefreshIndexChanged
        itemlist = @sprites["itemlist"]
        overlay = @sprites["overlay"].bitmap
        overlay.clear
        # Draw slider arrows
        showslider = false
        if itemlist.top_row > 0
            overlay.blt(470, 16, @sliderbitmap.bitmap, Rect.new(0, 0, 36, 38))
            showslider = true
        end
        if itemlist.top_item + itemlist.page_item_max < itemlist.itemCount
            overlay.blt(470, 228, @sliderbitmap.bitmap, Rect.new(0, 38, 36, 38))
            showslider = true
        end
        # Draw slider box
        if showslider
            sliderheight = 174
            boxheight = (sliderheight * itemlist.page_row_max / itemlist.row_max).floor
            boxheight += [(sliderheight - boxheight) / 2, sliderheight / 6].min
            boxheight = [boxheight.floor, 38].max
            y = 54
            y += ((sliderheight - boxheight) * itemlist.top_row / (itemlist.row_max - itemlist.page_row_max)).floor
            overlay.blt(470, y, @sliderbitmap.bitmap, Rect.new(36, 0, 36, 4))
            i = 0
            while i * 16 < boxheight - 4 - 18
                height = [boxheight - 4 - 18 - (i * 16), 16].min
                overlay.blt(470, y + 4 + (i * 16), @sliderbitmap.bitmap, Rect.new(36, 4, 36, height))
                i += 1
            end
            overlay.blt(470, y + boxheight - 18, @sliderbitmap.bitmap, Rect.new(36, 20, 36, 18))
        end
        # Set the selected item's icon
        @sprites["itemicon"].item = itemlist.item
        # Set the selected item's description
        @sprites["itemtext"].text = (itemlist.item) ? GameData::Item.get(itemlist.item).description : _INTL("Close bag.")
        # Set the selected item's label
        @sprites["itemlabel"].bitmap.clear
        if !itemlist.item
        elsif [:Type, :TypeText].include?(@label)
            type_data = GameData::Type.get(pbBerryGetNaturalGift(itemlist.item)[0])
            pbDrawTextPositions(@sprites["itemlabel"].bitmap, [[type_data.name,
                    92, 18, 2, ITEMLISTBASECOLOR, ITEMLISTSHADOWCOLOR]])
        elsif @label == :TypeIcon
            file_location = Essentials::VERSION.include?("21") ? "UI" : "Pictures"
            type_data = GameData::Type.get(pbBerryGetNaturalGift(itemlist.item)[0])
            type_number = type_data.icon_position
            pbDrawImagePositions(@sprites["itemlabel"].bitmap, [["Graphics/#{file_location}/types", 
                    60, 14, 0, type_number * 28, 64, 28]])
        elsif @label == :Size
            berry_data = GameData::BerryData.get(itemlist.item)
            size = ""
            if System.user_language[3..4] == "US"   # If the user is in the United States
                inches = (berry_data.size / 2.54).round(1)
                size = _ISPRINTF("{1:.1f}\"", inches)
            else
                size = _ISPRINTF("{1:.1f} cm", size)
            end
            pbDrawTextPositions(@sprites["itemlabel"].bitmap, [[size,
                    92, 18, 2, ITEMLISTBASECOLOR, ITEMLISTSHADOWCOLOR]])
        elsif [:Firm, :Firmness].include?(@label)
            berry_data = GameData::BerryData.get(itemlist.item)
            pbDrawTextPositions(@sprites["itemlabel"].bitmap, [[berry_data.firmness,
                    92, 18, 2, ITEMLISTBASECOLOR, ITEMLISTSHADOWCOLOR]])
        elsif @label == :Flavor
            berry_data = GameData::BerryData.get(itemlist.item)
            flavor = berry_data.flavor.max_by{|key,val| val}
            pbDrawTextPositions(@sprites["itemlabel"].bitmap, [[flavor[0],
                    92, 18, 2, ITEMLISTBASECOLOR, ITEMLISTSHADOWCOLOR]])
        else # :Color
            color_data = GameData::BerryColor.get(GameData::BerryData.get(itemlist.item).color)
            pbDrawTextPositions(@sprites["itemlabel"].bitmap, [[(itemlist.item ? color_data.name : ""),
                    92, 18, 2, color_data.base_color, color_data.shadow_color]])
        end
    end
  
    def pbRefreshFilter
        @filterlist = nil
        return if !@choosing
        return if @filterproc.nil?
        @filterlist = []
        (1...@bag.pockets.length).each do |i|
            @bag.pockets[i].length.times do |j|
                @filterlist.push(j) if @filterproc.call(@bag.pockets[i][j][0])
            end
        end
    end
  
    # Called when the item screen wants an item to be chosen from the screen
    def pbChooseItem
        @sprites["helpwindow"].visible = false
        itemwindow = @sprites["itemlist"]
        pbActivateWindow(@sprites, "itemlist") {
            loop do
                oldindex = itemwindow.index
                Graphics.update
                Input.update
                pbUpdate
                if itemwindow.index != oldindex
                    pbRefresh
                end
                if Input.trigger?(Input::BACK)   # Cancel the item screen
                    @selectedBerries.empty? ? pbPlayCloseMenuSE : pbPlayDecisionSE
                    return nil
                elsif Input.trigger?(Input::USE)   # Choose selected item
                    (itemwindow.item) ? pbPlayDecisionSE : pbPlayCloseMenuSE
                    return [itemwindow.item,@bag.pockets[5][@filterlist[itemwindow.index]][1]]
                end
            end
        }
    end  
end
  
class ChooseBerryMultipleScreen
    def initialize(scene, bag, allow_less)
        @bag   = bag
        @scene = scene
        @allow_less = allow_less
    end
  
    def pbStartScreen(proc = nil)
        @scene.pbStartScene(@bag, true, proc)
        item = nil
        ready = false
        loop do
            if ready
                if @scene.pbConfirm(@scene.selectedBerries.length == 1 ? _INTL("Choose this berry?") : _INTL("Choose these berries?"))
                    break
                elsif @scene.pbConfirm(@scene.selectedBerries.length == 1 ? _INTL("Stop choosing a berry?") : _INTL("Stop choosing berries?"))
                    @scene.selectedBerries = []
                    break
                end
            end
            item = @scene.pbChooseItem
            break if !item && @scene.selectedBerries.empty?
            if !item 
                if @allow_less && @scene.pbConfirm(@scene.selectedBerries.length == 1 ? _INTL("Choose this berry?") : _INTL("Choose these berries?")) 
                    break
                elsif @scene.pbConfirm(@scene.selectedBerries.length == 1 ? _INTL("Stop choosing a berry?") : _INTL("Stop choosing berries?"))
                    @scene.selectedBerries = []
                    break
                end
            end
            next if !item
            qty = item[1]
            item = item[0]
            itm = GameData::Item.get(item)
            next pbDisplay(_INTL("You don't have any more of these to choose.")) if qty - @scene.selectedBerries.count(item) <= 0
            cmdUse      = -1
            commands = []
            # Generate command list
            commands[cmdUse = commands.length]    = _INTL("Choose")
            commands[commands.length]             = _INTL("Cancel")
            # Show commands generated above
            itemname = itm.name
            command = @scene.pbShowCommands(_INTL("Choose {1}?", itemname), commands) if !ready
            if cmdUse >= 0 && command == cmdUse   # Use item
                @scene.selectedBerries.push(itm)
                @scene.pbRefresh
                if @scene.selectedBerries.length >= @scene.count
                    ready = true
                end
                next
            end
        end
        @scene.pbEndScene
        return @scene.selectedBerries
    end
  
    def pbDisplay(text)
        @scene.pbDisplay(text)
    end
  
    def pbConfirm(text)
        return @scene.pbConfirm(text)
    end
  
    # UI logic for the item screen for choosing an item.
    def pbChooseItemScreen(proc = nil)
        @scene.pbStartScene(@bag, true, proc)
        berries = @scene.pbChooseItem
        @scene.pbEndScene
        return berries
    end
end
  
class Window_ChooseBerryMultiple < Window_DrawableCommand
  
    def initialize(bag, filterlist, scene, x, y, width, height)
        @file_location = Essentials::VERSION.include?("21") ? "UI" : "Pictures"
        @bag        = bag
        @filterlist = filterlist
        @scene 		= scene
        @sorting = false
        @adapter = PokemonMartAdapter.new
        super(x, y, width, height)
        @selarrow  = AnimatedBitmap.new("Graphics/#{@file_location}/Bag/cursor")
        @swaparrow = AnimatedBitmap.new("Graphics/#{@file_location}/Bag/cursor_swap")
        self.windowskin = nil
    end
  
    def dispose
        @swaparrow.dispose
        super
    end
  
    def page_row_max; return ChooseBerryMultiple_Scene::ITEMSVISIBLE; end
    def page_item_max; return ChooseBerryMultiple_Scene::ITEMSVISIBLE; end
  
    def item
        return nil if @filterlist && !@filterlist[self.index]
        thispocket = @bag.pockets[5]  
        item = thispocket[@filterlist[self.index]]
        return (item) ? item[0] : nil
    end
  
    def itemCount
        return @filterlist.length + 1
    end
  
    def itemRect(item)
        if item < 0 || item >= @item_max || item < self.top_item - 1 ||
            item > self.top_item + self.page_item_max
            return Rect.new(0, 0, 0, 0)
        else
            cursor_width = (self.width - self.borderX - ((@column_max - 1) * @column_spacing)) / @column_max
            x = item % @column_max * (cursor_width + @column_spacing)
            y = (item / @column_max * @row_height) - @virtualOy
            return Rect.new(x, y, cursor_width, @row_height)
        end
    end
  
    def drawCursor(index, rect)
        if self.index == index
            bmp = (@sorting) ? @swaparrow.bitmap : @selarrow.bitmap
            pbCopyBitmap(self.contents, bmp, rect.x, rect.y + 2)
        end
    end
  
    def drawItem(index, _count, rect)
        textpos = []
        rect = Rect.new(rect.x + 16, rect.y + 16, rect.width - 16, rect.height)
        thispocket = @bag.pockets[5]
        if index == self.itemCount - 1
            textpos.push([_INTL("CLOSE BAG"), rect.x, rect.y + 2, false, self.baseColor, self.shadowColor])
        else
            item = thispocket[@filterlist[index]][0]
            baseColor   = self.baseColor
            shadowColor = self.shadowColor
            if @sorting && index == self.index
                baseColor   = Color.new(224, 0, 0)
                shadowColor = Color.new(248, 144, 144)
            end
            textpos.push([@adapter.getDisplayName(item), rect.x, rect.y + 2, false, baseColor, shadowColor])
            qty = thispocket[@filterlist[index]][1] - @scene.selectedBerries.count(GameData::Item.get(thispocket[@filterlist[index]][0]))
            qtytext = _ISPRINTF("x{1: 3d}", qty)
            xQty    = rect.x + rect.width - self.contents.text_size(qtytext).width - 16
            textpos.push([qtytext, xQty, rect.y + 2, false, baseColor, shadowColor])
        end
        pbDrawTextPositions(self.contents, textpos)
    end
  
    def refresh
        @item_max = itemCount
        self.update_cursor_rect
        dwidth  = self.width - self.borderX
        dheight = self.height - self.borderY
        self.contents = pbDoEnsureBitmap(self.contents, dwidth, dheight)
        self.contents.clear
        @item_max.times do |i|
            next if i < self.top_item - 1 || i > self.top_item + self.page_item_max
            drawItem(i, @item_max, itemRect(i))
        end
        drawCursor(self.index, itemRect(self.index))
    end
  
    def update
        super
        @uparrow.visible   = false
        @downarrow.visible = false
    end
end