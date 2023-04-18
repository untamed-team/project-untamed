def pbUnlockOutfit(outfit_index)
    $player.pbUnlockOutfit(outfit_index)
end

class Player < Trainer
    # @return [Array<Array>] for unlocked outfits
    attr_accessor :outfit_unlocked

    alias initialize_outfit initialize
    def initialize(name, trainer_type)
        initialize_outfit(name, trainer_type)
        super
        @outfit_unlocked  = [WardrobeConfig::OUTFITS[0]]
    end

    def pbUnlockOutfit(outfit_index)
        outfit_unlock = WardrobeConfig::OUTFITS[outfit_index]
        if !@outfit_unlocked.include?(outfit_unlock)
            @outfit_unlocked.push(outfit_unlock)
            echoln "Outfit #{outfit_unlock} Unlocked"
        else
            echoln "Outfit #{outfit_unlock} already unlocked"
        end
    end
end
class Window_Wardrobe < Window_DrawableCommand
    def initialize(outfits, x, y, width, height, viewport, index)
        @outfits = outfits
        super(x, y, width, height, viewport)
        @selarrow        = AnimatedBitmap.new("Graphics/Pictures/TC Wardrobe/cursor")
        @baseColor       = Color.new(88, 88, 80)
        @shadowColor     = Color.new(168, 184, 184)
        @outfit_selected = index
        self.index       = index
        self.windowskin  = nil
    end

    def itemCount
        return @outfits.length
    end

    def drawItem(index, count, rect)
        rect = Rect.new(rect.x + 16, rect.y, rect.width - 16, rect.height)
        textpos = []
        outfit = @outfits[index]
        baseColor   = self.baseColor
        shadowColor = self.shadowColor
        textpos.push([outfit, rect.x, rect.y + 6, false, baseColor, shadowColor])
        pbDrawTextPositions(self.contents, textpos)
        pbDrawImagePositions(self.contents,[["Graphics/Pictures/TC Wardrobe/check", rect.x + rect.width - 34, rect.y + 8, 0, 0, -1, 24]]) if (index == @outfit_selected)
    end

    def drawCursor(index, rect)
        if self.index == index
            pbCopyBitmap(self.contents, @selarrow.bitmap, rect.x, rect.y + 4)
        end
    end

    def outfit_selected=(value)
        @outfit_selected = value
        refresh
    end

    def refresh
      @item_max = itemCount
      self.update_cursor_rect
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
end

class WardrobeScene
    def initialize(ordered_list, index, overlay_text)
        @viewport         = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport.z       = 99999
        @sprites          = {}
        @baseColor       = Color.new(88, 88, 80)
        @shadowColor     = Color.new(168, 184, 184)

        @outfit_all       = WardrobeConfig::OUTFITS
        bg_type           = WardrobeConfig::BG_TYPE
        @outfit_selected  = $player.outfit
        @outfit_current   = $player.outfit
        @outfit_hover     = $player.outfit
        @ordered_list     = ordered_list

        addBackgroundPlane(@sprites, "bg", _INTL("TC Wardrobe/bg_{1}", bg_type), @viewport)
        @sprites["outfitlist"] = Window_Wardrobe.new(@ordered_list, Graphics.width - 300, 74, 282, 236, @viewport, index)
        @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        pbSetSystemFont(@sprites["overlay"].bitmap)
        pbDrawTextPositions(@sprites["overlay"].bitmap, [[overlay_text, 16, 18, false, @baseColor, @shadowColor]])
        @sprites["player"] = IconSprite.new(12, 112, @viewport)
        pbUpdateTrainerGraphic
        pbUpdateSpriteHash(@sprites)
        @sprites["outfitlist"].refresh
        pbFadeInAndShow(@sprites)
    end
    
    def pbMain
        loop do
            Graphics.update
            Input.update
            if Input.repeat?(Input::UP)
                if !(@sprites["outfitlist"].index > 0)
                    pbEdgeBlock(Input::UP)
                    next
                end
                @sprites["outfitlist"].index -= 1
                pbSwitchOutfit
            elsif Input.repeat?(Input::DOWN)
                if !(@sprites["outfitlist"].index < (@ordered_list.length - 1))
                    pbEdgeBlock(Input::DOWN)
                    next
                end
                @sprites["outfitlist"].index += 1
                pbSwitchOutfit
            elsif Input.trigger?(Input::USE)
                if @outfit_selected == @outfit_hover
                    pbPlayBuzzerSE
                    next
                end
                @outfit_selected = @outfit_hover
                @sprites["outfitlist"].outfit_selected = @sprites["outfitlist"].index
                pbPlayCursorSE
            elsif Input.trigger?(Input::BACK)
                break if @outfit_selected == @outfit_current
                comfirm = pbMessage(_INTL("Would you like to go with this outfit?"), [_INTL("Yes"), _INTL("No"), _INTL("Leave without changing")], 2)
                $player.outfit = @outfit_selected if comfirm == 0
                break if comfirm == 0 || comfirm == 2
            end
        end
    end

    # make sure Buzzer doesn't play multiple times when holding key
    def pbEdgeBlock(input)
        block = false
        loop do
            Graphics.update
            Input.update
            break if Input.release?(input)
            pbPlayBuzzerSE if !block
            block = true
        end
    end

    # switches outfit of player in UI
    def pbSwitchOutfit
        outfit_sel    = @ordered_list[@sprites["outfitlist"].index]
        @outfit_hover = @outfit_all.find_index(outfit_sel)
        pbUpdateTrainerGraphic
        pbPlayCursorSE
    end

    def pbUpdateTrainerGraphic
        player_filename = $player.trainer_type.to_s
        player_filename += _INTL("_{1}",@outfit_hover) if @outfit_hover > 0
        @sprites["player"].setBitmap(_INTL("Graphics/Trainers/{1}",player_filename))
    end

    def pbEndScene
        pbFadeOutAndHide(@sprites)
        pbDisposeSpriteHash(@sprites)
        @viewport.dispose
    end
end

class Wardrobe
    def initialize(overlay_text)
        @GUI_ENABLED         = (WardrobeConfig::TYPE == 1)
        @outfit_current      = $player.outfit
        @outfit_all          = WardrobeConfig::OUTFITS
        @unlocked_outfits    = $player.outfit_unlocked
        @selected_index      = 0
        @outfit_list_ordered = []
        for i in @outfit_all
            @outfit_list_ordered.push(i) if @unlocked_outfits.include?(i)
            @selected_index = @outfit_list_ordered.find_index(i) if (@outfit_all.find_index(i) == @outfit_current)
        end

        if @GUI_ENABLED
            pbFadeOutIn {
                @scene = WardrobeScene.new(@outfit_list_ordered, @selected_index, overlay_text)
                @scene.pbMain
                @scene.pbEndScene
            }
        else
            outfit_chosen = pbMessage(_INTL("Choose an outfit"), @outfit_list_ordered, -1, nil, @selected_index)
            return false if outfit_chosen < 0
            outfit_selected = @outfit_list_ordered[outfit_chosen]
            $player.outfit  = @outfit_all.find_index(outfit_selected)
        end
        
        return false if $player.outfit == @outfit_current
        return true
    end
end

def pbWardrobe(overlay_text = _INTL("{1}'s Wardrobe", $player.name))
    ret = Wardrobe.new(overlay_text)
    return ret
end