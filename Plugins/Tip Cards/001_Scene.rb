def pbShowTipCard(*ids)
    scene = TipCard_Scene.new(ids)
    screen = TipCard_Screen.new(scene)
    screen.pbStartScreen
end

alias pbTipCard pbShowTipCard

def pbShowTipCardsGrouped(*groups, continuous: false)
    sections = groups
    if sections.length > 1 || (sections.length == 1 && Settings::TIP_CARDS_SINGLE_GROUP_SHOW_HEADER)
        scene = TipCardGroups_Scene.new(sections, false, continuous)
        screen = TipCardGroups_Screen.new(scene)
        screen.pbStartScreen
    elsif sections[0]
        tips = Settings::TIP_CARDS_GROUPS[sections[0]][:Tips]
        pbShowTipCard(*tips)
    else
        Console.echo_warn "No available tips to show"
    end
end

alias pbTipCardsGrouped pbShowTipCardsGrouped

#===============================================================================
# Tip Card Scene
#===============================================================================  
class TipCard_Screen
    def initialize(scene)
        @scene = scene
    end
  
    def pbStartScreen
        @scene.pbStartScene
        @scene.pbScene
        @scene.pbEndScene
    end
end
  
class TipCard_Scene
    def initialize(tips)
        @tips = tips
    end

    def pbStartScene
        @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
        @viewport.z = 99999
        @index = 0
        @pages = @tips.length
        @sprites = {}
        @sprites["background"] = IconSprite.new(0, 0, @viewport)
        @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Tip Cards/#{Settings::TIP_CARDS_DEFAULT_BG}"))
        @sprites["background"].x = (Graphics.width - @sprites["background"].bitmap.width) / 2
        @sprites["background"].y = (Graphics.height - @sprites["background"].bitmap.height) / 2
        @sprites["background"].visible = true
        @sprites["image"] = IconSprite.new(0, 0, @viewport)
        @sprites["image"].visible = false
        @sprites["arrow_right"] = IconSprite.new(0, 0, @viewport)
        @sprites["arrow_right"].setBitmap(_INTL("Graphics/Pictures/Tip Cards/arrow_right"))
        @sprites["arrow_right"].x = Graphics.width / 2 + 48
        @sprites["arrow_right"].y = @sprites["background"].y + @sprites["background"].bitmap.height -  @sprites["arrow_right"].bitmap.height - 4
        @sprites["arrow_right"].visible = false
        @sprites["arrow_left"] = IconSprite.new(0, 0, @viewport)
        @sprites["arrow_left"].setBitmap(_INTL("Graphics/Pictures/Tip Cards/arrow_left"))
        @sprites["arrow_left"].x = Graphics.width / 2 - 48 - @sprites["arrow_left"].bitmap.width
        @sprites["arrow_left"].y = @sprites["background"].y + @sprites["background"].bitmap.height -  @sprites["arrow_left"].bitmap.height - 4
        @sprites["arrow_left"].visible = false
      
        @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        @sprites["overlay"].visible = true
        pbSEPlay(Settings::TIP_CARDS_SHOW_SE)
        pbDrawTip
    end
    
    def pbScene
        loop do
            Graphics.update
            Input.update
            pbUpdate
            oldindex = @index
            quit = false
            if Input.trigger?(Input::USE)
                if @index < @pages - 1
                    @index += 1
                else 
                    pbSEPlay(Settings::TIP_CARDS_DISMISS_SE)
                    break
                end
            elsif Input.trigger?(Input::BACK) || Input.trigger?(Input::LEFT)
                @index -= 1 if @index > 0
            elsif Input.trigger?(Input::RIGHT)
                @index += 1 if @index < @pages - 1
            end
            if oldindex != @index
                pbDrawTip
                if Settings::TIP_CARDS_SWITCH_SE
                    pbSEPlay(Settings::TIP_CARDS_SWITCH_SE)
                else
                    pbPlayCursorSE
                end
            end
        end
    end
    
    def pbEndScene
        # pbFadeOutAndHide(@sprites) { pbUpdate }
        pbUpdate
        Graphics.update
        Input.update
        pbDisposeSpriteHash(@sprites)
        @viewport.dispose
    end
  
    def pbUpdate
        pbUpdateSpriteHash(@sprites)
    end

    def pbDrawTip
        overlay = @sprites["overlay"].bitmap
        overlay.clear
        @sprites["image"].visible = false
        @sprites["arrow_right"].visible = false
        @sprites["arrow_left"].visible = false
        pbSetSystemFont(overlay)
        base = Settings::TIP_CARDS_TEXT_MAIN_COLOR
        shadow = Settings::TIP_CARDS_TEXT_SHADOW_COLOR
        tip = @tips[@index]
        info = Settings::TIP_CARDS_CONFIGURATION[tip] || nil
        if info
            text_y_adj = 64
            text_x_adj = 16
            text_width_adj = 0
            pbSetTipCardSeen(tip)
            if info[:Background]
                @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Tip Cards/#{info[:Background]}"))
            else
                @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Tip Cards/#{Settings::TIP_CARDS_DEFAULT_BG}"))
            end
            if info[:Image]
                @sprites["image"].setBitmap(_INTL("Graphics/Pictures/Tip Cards/Images/#{info[:Image]}"))
                image_pos = info[:ImagePosition] || ((@sprites["image"].width > @sprites["image"].height) ? :Top : :Left)
                case image_pos
                when :Top
                    @sprites["image"].x = (Graphics.width - @sprites["image"].bitmap.width) / 2
                    @sprites["image"].y = @sprites["background"].y + 64
                    text_y_adj += @sprites["image"].height + 16
                when :Bottom
                    @sprites["image"].x = (Graphics.width - @sprites["image"].bitmap.width) / 2
                    @sprites["image"].y = @sprites["background"].y + @sprites["background"].height - @sprites["image"].bitmap.height - 32
                when :Left
                    @sprites["image"].x = @sprites["background"].x + 16
                    @sprites["image"].y = @sprites["background"].y + 64
                    text_x_adj += @sprites["image"].width + 16
                when :Right
                    @sprites["image"].x = @sprites["background"].x + @sprites["background"].width - @sprites["image"].bitmap.width - 16
                    @sprites["image"].y = @sprites["background"].y + 64
                    text_width_adj -= @sprites["image"].width + 16
                end
                @sprites["image"].visible = true
            end
            title = "<ac>" + info[:Title] + "</ac>"
            # drawFormattedTextEx(bitmap, x, y, width, text, baseColor = nil, shadowColor = nil, lineheight = 32)
            drawFormattedTextEx(overlay, @sprites["background"].x, @sprites["background"].y + 18, @sprites["background"].width, 
                title, base, shadow)
            text_y_adj += info[:YAdjustment] if info[:YAdjustment]
            text = "<ac>" + info[:Text] + "</ac>"
            drawFormattedTextEx(overlay, @sprites["background"].x + text_x_adj, @sprites["background"].y + text_y_adj, 
                @sprites["background"].width - 16 - text_x_adj + text_width_adj, text, base, shadow)
        else
            Console.echo_warn tip.to_s + " is not defined."
            drawFormattedTextEx(overlay, @sprites["background"].x, @sprites["background"].y + 18, @sprites["background"].width, 
                _INTL("<ac>Tip not defined.</ac>"), base, shadow)
        end
        if @pages > 1
            @sprites["arrow_left"].visible = (@index > 0)
            @sprites["arrow_right"].visible = (@index < @pages - 1)
            pbDrawTextPositions(overlay, [[_INTL("{1}/{2}",@index+1, @pages), Graphics.width/2, @sprites["background"].y + @sprites["background"].bitmap.height - 26, 
                2, base, shadow]])
        end
    end
end

#===============================================================================
# Tip Card Groups Scene
#===============================================================================  
class TipCardGroups_Screen
    def initialize(scene)
        @scene = scene
    end
  
    def pbStartScreen
        @scene.pbStartScene
        @scene.pbScene
        @scene.pbEndScene
    end
end
  
class TipCardGroups_Scene
    def initialize(groups, revisit = true, continuous = false)
        @groups = groups
        @revisit = revisit
        @continuous = continuous
    end

    def pbStartScene
        @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
        @viewport.z = 99999
        @section = 0
        @index = 0
        @sections = @groups.length
        @pages = 0
        @sprites = {}
        @sprites["header"] = IconSprite.new(0, 0, @viewport)
        @sprites["header"].setBitmap(_INTL("Graphics/Pictures/Tip Cards/group_header"))
        @sprites["header"].x = (Graphics.width - @sprites["header"].bitmap.width) / 2
        @sprites["header"].visible = true
        @sprites["background"] = IconSprite.new(0, 0, @viewport)
        @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Tip Cards/#{Settings::TIP_CARDS_DEFAULT_BG}"))
        @sprites["background"].x = (Graphics.width - @sprites["background"].bitmap.width) / 2
        @sprites["background"].visible = true
        
        total_height = @sprites["header"].bitmap.height + @sprites["background"].bitmap.height
        initial_y = (Graphics.height - total_height) / 2
        @sprites["header"].y = initial_y
        @sprites["background"].y = initial_y + @sprites["header"].bitmap.height
        
        @sprites["arrow_right_h"] = IconSprite.new(0, 0, @viewport)
        @sprites["arrow_right_h"].setBitmap(_INTL("Graphics/Pictures/Tip Cards/arrow_right"))
        @sprites["arrow_right_h"].x = @sprites["header"].x + @sprites["header"].bitmap.width - @sprites["arrow_right_h"].bitmap.width - 8
        @sprites["arrow_right_h"].y = @sprites["header"].y + (@sprites["header"].bitmap.height - @sprites["arrow_right_h"].bitmap.height) / 2
        @sprites["arrow_right_h"].visible = false
        @sprites["arrow_left_h"] = IconSprite.new(0, 0, @viewport)
        @sprites["arrow_left_h"].setBitmap(_INTL("Graphics/Pictures/Tip Cards/arrow_left"))
        @sprites["arrow_left_h"].x = @sprites["header"].x + 8 
        @sprites["arrow_left_h"].y = @sprites["header"].y + (@sprites["header"].bitmap.height - @sprites["arrow_left_h"].bitmap.height) / 2
        @sprites["arrow_left_h"].visible = false
        @sprites["image"] = IconSprite.new(0, 0, @viewport)
        @sprites["image"].visible = false
        @sprites["arrow_right"] = IconSprite.new(0, 0, @viewport)
        @sprites["arrow_right"].setBitmap(_INTL("Graphics/Pictures/Tip Cards/arrow_right"))
        @sprites["arrow_right"].x = Graphics.width / 2 + 48
        @sprites["arrow_right"].y = @sprites["background"].y + @sprites["background"].bitmap.height - @sprites["arrow_right"].bitmap.height - 4
        @sprites["arrow_right"].visible = false
        @sprites["arrow_left"] = IconSprite.new(0, 0, @viewport)
        @sprites["arrow_left"].setBitmap(_INTL("Graphics/Pictures/Tip Cards/arrow_left"))
        @sprites["arrow_left"].x = Graphics.width / 2 - 48 - @sprites["arrow_left"].bitmap.width
        @sprites["arrow_left"].y = @sprites["background"].y + @sprites["background"].bitmap.height - @sprites["arrow_left"].bitmap.height - 4
        @sprites["arrow_left"].visible = false
      
        @sprites["overlay_h"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        @sprites["overlay_h"].visible = true
        @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        @sprites["overlay"].visible = true
        pbSEPlay(Settings::TIP_CARDS_SHOW_SE)
        pbDrawGroup
    end
    
    def pbScene
        loop do
            Graphics.update
            Input.update
            pbUpdate
            oldindex = @index
            oldsection = @section
            quit = false
            if Input.trigger?(Input::USE)
                @index += 1 if @index < @pages - 1
            elsif Input.trigger?(Input::BACK)
                pbSEPlay(Settings::TIP_CARDS_DISMISS_SE)
                break
            elsif Input.trigger?(Input::LEFT)
                if @index > 0
                    @index -= 1 
                elsif @continuous && @index <= 0 && @section > 0
                    @section -= 1
                    @last_index = true
                end
            elsif Input.trigger?(Input::RIGHT)
                if @index < @pages - 1
                    @index += 1 
                elsif @continuous && @index >= @pages - 1 && @section < @sections - 1
                    @section += 1
                end
            elsif Input.trigger?(Input::JUMPUP)
                @section -= 1 if @section > 0
            elsif Input.trigger?(Input::JUMPDOWN)
                @section += 1 if @section < @sections - 1
            elsif Input.trigger?(Input::SPECIAL) && Settings::TIP_CARDS_GROUP_LIST && @sections > 1
                list = []
                @groups.each { |group| list.push(Settings::TIP_CARDS_GROUPS[group][:Title]) }
                val = pbShowCommands(nil, list, -1, @section)
                @section = val unless val < 0
            end
            if oldsection != @section
                @index = 0 unless @last_index
                pbDrawGroup
                if Settings::TIP_CARDS_SWITCH_SE
                    pbSEPlay(Settings::TIP_CARDS_SWITCH_SE)
                else
                    pbPlayCursorSE
                end
            elsif oldindex != @index
                pbDrawTip
                if Settings::TIP_CARDS_SWITCH_SE
                    pbSEPlay(Settings::TIP_CARDS_SWITCH_SE)
                else
                    pbPlayCursorSE
                end
            end
            last_index = nil if last_index
        end
    end
    
    def pbEndScene
        pbUpdate
        Graphics.update
        Input.update
        pbDisposeSpriteHash(@sprites)
        @viewport.dispose
    end
  
    def pbUpdate
        pbUpdateSpriteHash(@sprites)
    end

    def pbDrawGroup
        overlay = @sprites["overlay_h"].bitmap
        overlay.clear
        @sprites["arrow_right_h"].visible = false
        @sprites["arrow_left_h"].visible = false
        pbSetSystemFont(overlay)
        base = Settings::TIP_CARDS_TEXT_MAIN_COLOR
        shadow = Settings::TIP_CARDS_TEXT_SHADOW_COLOR
        group = Settings::TIP_CARDS_GROUPS[@groups[@section]]
        title = "<ac>" + group[:Title] + "</ac>"
        # drawFormattedTextEx(bitmap, x, y, width, text, baseColor = nil, shadowColor = nil, lineheight = 32)
        drawFormattedTextEx(overlay, @sprites["header"].x, @sprites["header"].y + 18, @sprites["header"].width, 
            title, base, shadow)
        if @sections > 1
            @sprites["arrow_left_h"].visible = (@section > 0)
            @sprites["arrow_right_h"].visible = (@section < @sections - 1)
        end
        @tips = []
        if @revisit
            group[:Tips].each do |tip|
                next if !Settings::TIP_CARDS_CONFIGURATION[tip] || Settings::TIP_CARDS_CONFIGURATION[tip][:HideRevisit] || 
                    !pbSeenTipCard?(tip)
                @tips.push(tip)
            end
        else
            @tips = group[:Tips]
        end
        @pages = @tips.length
        pbDrawTip
    end

    def pbDrawTip
        overlay = @sprites["overlay"].bitmap
        overlay.clear
        @sprites["image"].visible = false
        @sprites["arrow_right"].visible = false
        @sprites["arrow_left"].visible = false
        pbSetSystemFont(overlay)
        base = Settings::TIP_CARDS_TEXT_MAIN_COLOR
        shadow = Settings::TIP_CARDS_TEXT_SHADOW_COLOR
        if @last_index
            @index = @pages - 1
            @last_index = nil
        end
        tip = @tips[@index]
        info = Settings::TIP_CARDS_CONFIGURATION[tip] || nil
        if info
            text_y_adj = 64
            text_x_adj = 16
            text_width_adj = 0
            pbSetTipCardSeen(tip)
            if info[:Background]
                @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Tip Cards/#{info[:Background]}"))
            else
                @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Tip Cards/#{Settings::TIP_CARDS_DEFAULT_BG}"))
            end
            if info[:Image]
                @sprites["image"].setBitmap(_INTL("Graphics/Pictures/Tip Cards/Images/#{info[:Image]}"))
                image_pos = info[:ImagePosition] || ((@sprites["image"].width > @sprites["image"].height) ? :Top : :Left)
                case image_pos
                when :Top
                    @sprites["image"].x = (Graphics.width - @sprites["image"].bitmap.width) / 2
                    @sprites["image"].y = @sprites["background"].y + 64
                    text_y_adj += @sprites["image"].height + 16
                when :Bottom
                    @sprites["image"].x = (Graphics.width - @sprites["image"].bitmap.width) / 2
                    @sprites["image"].y = @sprites["background"].y + @sprites["background"].height - @sprites["image"].bitmap.height - 32
                when :Left
                    @sprites["image"].x = @sprites["background"].x + 16
                    @sprites["image"].y = @sprites["background"].y + 64
                    text_x_adj += @sprites["image"].width + 16
                when :Right
                    @sprites["image"].x = @sprites["background"].x + @sprites["background"].width - @sprites["image"].bitmap.width - 16
                    @sprites["image"].y = @sprites["background"].y + 64
                    text_width_adj -= @sprites["image"].width + 16
                end
                @sprites["image"].visible = true
            end
            title = "<ac>" + info[:Title] + "</ac>"
            # drawFormattedTextEx(bitmap, x, y, width, text, baseColor = nil, shadowColor = nil, lineheight = 32)
            drawFormattedTextEx(overlay, @sprites["background"].x, @sprites["background"].y + 18, @sprites["background"].width, 
                title, base, shadow)
            text_y_adj += info[:YAdjustment] if info[:YAdjustment]
            text = "<ac>" + info[:Text] + "</ac>"
            drawFormattedTextEx(overlay, @sprites["background"].x + text_x_adj, @sprites["background"].y + text_y_adj, 
                @sprites["background"].width - 16 - text_x_adj + text_width_adj, text, base, shadow)
        else
            Console.echo_warn tip.to_s + " is not defined."
            drawFormattedTextEx(overlay, @sprites["background"].x, @sprites["background"].y + 18, @sprites["background"].width, 
                _INTL("<ac>Tip not defined.</ac>"), base, shadow)
        end
        if @pages > 1
            @sprites["arrow_left"].visible = (@index > 0)
            @sprites["arrow_right"].visible = (@index < @pages - 1)
            pbDrawTextPositions(overlay, [[_INTL("{1}/{2}",@index+1, @pages), Graphics.width/2, @sprites["background"].y + @sprites["background"].bitmap.height - 26, 
                2, base, shadow]])
        end
    end
end