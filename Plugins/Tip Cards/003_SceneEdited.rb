#This is currently unfinished. Will need to come back to this once we have so many tips that not all of them can fit on the screen.
#Then I will need to make the list of TipTitles scroll up and down

#===============================================================================
# Tip Card Groups Scene
#===============================================================================  
class AdventureGuide_Screen
    def initialize(scene)
        @scene = scene
    end
  
    def pbStartScreen
        @scene.pbStartScene
        @scene.pbScene
        @scene.pbEndScene
    end
end
  
class AdventureGuide_Scene
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
		
		@sprites["guide_background"] = IconSprite.new(0, 0, @viewport)
        @sprites["guide_background"].setBitmap(_INTL("Graphics/Pictures/Tip Cards/guide_bg"))
        @sprites["guide_background"].x = 0
		@sprites["guide_background"].y = 0
		
        @sprites["header"] = IconSprite.new(0, 0, @viewport)
        @sprites["header"].setBitmap(_INTL("Graphics/Pictures/Tip Cards/group_header"))
        @sprites["header"].x = (Graphics.width - @sprites["header"].bitmap.width) / 2
        @sprites["header"].visible = true
        @sprites["background"] = IconSprite.new(0, 0, @viewport)
        @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Tip Cards/#{Settings::TIP_CARDS_DEFAULT_BG}"))
        @sprites["background"].x = (Graphics.width - @sprites["background"].bitmap.width) / 2
        @sprites["background"].visible = false
        
        total_height = @sprites["header"].bitmap.height + @sprites["background"].bitmap.height
        initial_y = (Graphics.height - total_height) / 2
        @sprites["header"].y = initial_y
		@sprites["header"].visible = false
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
        @sprites["arrow_right"].x = @sprites["guide_background"].width - @sprites["guide_background"].width/4 + @sprites["arrow_right"].bitmap.width
        @sprites["arrow_right"].y = @sprites["guide_background"].y + @sprites["guide_background"].bitmap.height - 62
        @sprites["arrow_right"].visible = false
        @sprites["arrow_left"] = IconSprite.new(0, 0, @viewport)
        @sprites["arrow_left"].setBitmap(_INTL("Graphics/Pictures/Tip Cards/arrow_left"))
        @sprites["arrow_left"].x = @sprites["guide_background"].width - @sprites["guide_background"].width/4 - @sprites["arrow_right"].bitmap.width*2
        @sprites["arrow_left"].y = @sprites["guide_background"].y + @sprites["guide_background"].bitmap.height - 62
        @sprites["arrow_left"].visible = false
      
        @sprites["overlay_h"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        @sprites["overlay_h"].visible = true
		@sprites["overlay_tip_text"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        @sprites["overlay_tip_text"].visible = true
        @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        @sprites["overlay"].visible = true
		@sprites["overlay_tip_title"] = BitmapSprite.new(Graphics.width, 42+(@groups.length*32), @viewport)
        @sprites["overlay_tip_title"].visible = true
        
		drawTipTitles
		
		pbSEPlay(Settings::TIP_CARDS_SHOW_SE)
		pbDrawGroup
		
		#draw cursor
		@sprites["cursor"] = IconSprite.new(0, 0, @viewport)
        @sprites["cursor"].setBitmap(_INTL("Graphics/Pictures/Tip Cards/cursor"))
        @sprites["cursor"].x = 4
        @sprites["cursor"].y = 27
    end
	
	def updateCursorPos
		@sprites["cursor"].y = 27 + (@section*32)
	end #def updateCursorPos
	
	def drawTipTitles
		y = 42
		@groups.each { |group|
			base = Settings::TIP_CARDS_TEXT_MAIN_COLOR
			shadow = Settings::TIP_CARDS_TEXT_SHADOW_COLOR
			overlay = @sprites["overlay_tip_title"].bitmap
			pbSetSystemFont(overlay)
			title = Settings::TIP_CARDS_GROUPS[group][:Title]
			drawFormattedTextEx(overlay, 20, y, @sprites["guide_background"].width/2, title, base, shadow)
			y += 32
		}
	end #drawTipTitles
	
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
            elsif Input.trigger?(Input::UP)
                if @section > 0
					@section -= 1
					updateCursorPos
				end
            elsif Input.trigger?(Input::DOWN)
                if @section < @sections - 1
					@section += 1
					updateCursorPos
				end
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
		overlayText = @sprites["overlay_tip_text"].bitmap
		overlayText.clear
        @sprites["arrow_right_h"].visible = false
        @sprites["arrow_left_h"].visible = false
        pbSetSystemFont(overlay)
        pbSetSystemFont(overlayText)
        base = Settings::TIP_CARDS_TEXT_MAIN_COLOR
        shadow = Settings::TIP_CARDS_TEXT_SHADOW_COLOR
        group = Settings::TIP_CARDS_GROUPS[@groups[@section]]
        title = "<ac>" + group[:Title] + "</ac>"
        # drawFormattedTextEx(bitmap, x, y, width, text, baseColor = nil, shadowColor = nil, lineheight = 32)
        
		#skip drawing header text - Gardenette
		#drawFormattedTextEx(overlay, @sprites["header"].x, @sprites["header"].y + 18, @sprites["header"].width, 
        #    title, base, shadow)
		
		#don't draw the section arrows that indicate you can go to the next tip group left or right - Gardenette
        #if @sections > 1
            #@sprites["arrow_left_h"].visible = (@section > 0)
            #@sprites["arrow_right_h"].visible = (@section < @sections - 1)
        #end
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
		overlayText = @sprites["overlay_tip_text"].bitmap
		overlayText.clear
        @sprites["image"].visible = false
        @sprites["arrow_right"].visible = false
        @sprites["arrow_left"].visible = false
        pbSetSystemFont(overlay)
        pbSetSystemFont(overlayText)
		overlayText.font.size -= 4
        base = Settings::TIP_CARDS_TEXT_MAIN_COLOR
        shadow = Settings::TIP_CARDS_TEXT_SHADOW_COLOR
        if @last_index
            @index = @pages - 1
            @last_index = nil
        end
        tip = @tips[@index]
        info = Settings::TIP_CARDS_CONFIGURATION[tip] || nil
        if info
            text_y_adj = 32
            text_x_adj = 8
            text_width_adj = 0
            pbSetTipCardSeen(tip)
            #if info[:Background]
            #    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Tip Cards/#{info[:Background]}"))
            #else
            #    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Tip Cards/#{Settings::TIP_CARDS_DEFAULT_BG}"))
            #end
            if info[:Image]
                @sprites["image"].setBitmap(_INTL("Graphics/Pictures/Tip Cards/Images/#{info[:ImageAdvGuide]}"))
                #image_pos = info[:ImagePosition] || ((@sprites["image"].width > @sprites["image"].height) ? :Top : :Left)
				image_pos = info[:ImagePosition] || :Top
                case image_pos
                when :Top
                    @sprites["image"].x = (@sprites["guide_background"].width/2 + @sprites["guide_background"].width/4 - @sprites["image"].bitmap.width/2)
                    @sprites["image"].y = @sprites["guide_background"].y + 98
                    text_y_adj += @sprites["image"].y + @sprites["image"].height + 16
                end
                @sprites["image"].visible = true
            end
            title = "<ac>" + info[:Title] + "</ac>"
            # drawFormattedTextEx(bitmap, x, y, width, text, baseColor = nil, shadowColor = nil, lineheight = 32)
            #drawFormattedTextEx(overlay, @sprites["background"].x, @sprites["background"].y + 18, @sprites["background"].width, 
            #    title, base, shadow)
			drawFormattedTextEx(overlay, Graphics.width/2, 48, @sprites["guide_background"].width/2, title, base, shadow)
            text_y_adj += info[:YAdjustmentAdvGuide] if info[:YAdjustmentAdvGuide]
            
            #added by Gardenette
            #$PokemonSystem.game_controls.find{|c| c.control_action=="Up"}.key_name
            if tip == :MULTISAVE2
                info[:Text] = _INTL("If you have multiple save files, you can press <c2=0999367C><b>#{$PokemonSystem.game_controls.find{|c| c.control_action=="Left"}.key_name}</b></c2> or <c2=0999367C><b>#{$PokemonSystem.game_controls.find{|c| c.control_action=="Right"}.key_name}</b></c2> on the continue screen to change save files.")
            elsif tip == :ADVDEX3
                info[:Text] = _INTL("You can press <c2=0999367C><b>#{$PokemonSystem.game_controls.find{|c| c.control_action=="Action"}.key_name}</b></c2> to go to the next page.")
            elsif tip == :ADVDEX5
                info[:Text] = _INTL("You can press <c2=0999367C><b>#{$PokemonSystem.game_controls.find{|c| c.control_action=="Walk/Run"}.key_name}</b></c2> from the main Pokédex page to access the search function.")
            elsif tip == :BATTLEINFO1
                info[:Text] = _INTL("You can view information about a battle by pressing <c2=0999367C><b>#{$PokemonSystem.game_controls.find{|c| c.control_action=="Battle Info"}.key_name}</b></c2>.")
            elsif tip == :BATTLEINFO4
                info[:Text] = _INTL("You can view information about the currently selected move by pressing <c2=0999367C><b>#{$PokemonSystem.game_controls.find{|c| c.control_action=="Move Info"}.key_name}</b></c2>.")
            end
            
            text = "<ac>" + info[:Text] + "</ac>"
            drawFormattedTextEx(overlayText, @sprites["guide_background"].width/2 + text_x_adj, @sprites["guide_background"].y + text_y_adj, @sprites["guide_background"].width/2 - 16, text, base, shadow)
        else
            Console.echo_warn tip.to_s + " is not defined."
            drawFormattedTextEx(overlay, @sprites["background"].x, @sprites["background"].y + 18, @sprites["background"].width, 
                _INTL("<ac>Tip not defined.</ac>"), base, shadow)
        end
        if @pages > 1
            @sprites["arrow_left"].visible = (@index > 0)
            @sprites["arrow_right"].visible = (@index < @pages - 1)
            #pbDrawTextPositions(overlay, [[_INTL("{1}/{2}",@index+1, @pages), Graphics.width/2, @sprites["background"].y + @sprites["background"].bitmap.height - 26, 2, base, shadow]])
			pbDrawTextPositions(overlayText, [[_INTL("{1}/{2}",@index+1, @pages), @sprites["guide_background"].width - @sprites["guide_background"].width/4, @sprites["guide_background"].y + @sprites["guide_background"].bitmap.height - 58, 2, base, shadow]])
        end
    end
end