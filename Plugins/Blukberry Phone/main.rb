#This script will be a separate screen that houses the following apps which will
#unlock as you play
#Pokedex
#Trainer card
#Map
#Wiki
#Objectives

#roadmap:
#access via hotkey which you can change from controls screen

#saved data
SaveData.register(:blukberry_phone) do
  save_value { $blukberry_phone }
  load_value { |value|  $blukberry_phone = value }
  new_game_value { PhoneScene.new }
end

class PhoneScene # The scene class
	attr_accessor :currentPage
	
	def initialize
		#set the page the first time we enter the phone
		#the starting page is 0
		@currentPage = 0
	end #def initialize
	
  def pbStartScene
    @sprites = {}
	@appSprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
	
	#Graphics
	@sprites["phoneShell"] = IconSprite.new(0, 0, @viewport)
    @sprites["phoneShell"].setBitmap("Graphics/Pictures/BlukBerry Phone/phone shell")
    @sprites["phoneShell"].x = 0
    @sprites["phoneShell"].y = 0
	@sprites["phoneShell"].z = 99999
	
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/BlukBerry Phone/bg")
    @sprites["background"].x = 0
    @sprites["background"].y = 0
	@sprites["background"].z = 99998
    
    @sprites["appname"] = IconSprite.new(0, 0, @viewport)
    @sprites["appname"].setBitmap("Graphics/Pictures/BlukBerry Phone/appname")
    @sprites["appname"].x = (Graphics.width - @sprites["appname"].bitmap.width)/2
    @sprites["appname"].y = 44
	@sprites["appname"].z = 99999
    
    @sprites["cursor"] = IconSprite.new(0, 0, @viewport)
    @sprites["cursor"].setBitmap("Graphics/Pictures/BlukBerry Phone/cursor")
    @sprites["cursor"].x = (Graphics.width - 380)/2
    @sprites["cursor"].y = (Graphics.height - 184)/2
	@sprites["cursor"].z = 99999
		
    # Creates an overlay to write text over it. This is declared after the
    # background, so it will be over it.
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
	@sprites["overlay"].z = 99999
		
    @sprites["msgwindow"] = Window_AdvancedTextPokemon.new("")
    @sprites["msgwindow"].visible = false
    @sprites["msgwindow"].viewport = @viewport
	@sprites["msgwindow"].z = 99999

	drawApps
	
	@cursorPos = 1
	
    # Set the font defined in "options" on overlay
    pbSetSystemFont(@sprites["overlay"].bitmap)
    # Calls the draw_text method
    draw_text
    # After everything is set, show the sprites with FadeIn effect.
    pbFadeInAndShow(@sprites) { update }
  end
  
  # Called every frame.
  def update
    # Updates all sprites in @sprites variable.
    pbUpdateSpriteHash(@sprites)
  end
 
  def draw_text
    overlay = @sprites["overlay"].bitmap
    overlay.clear 
    margin_left = 112
    margin_right = 96
    base_color = Color.new(72, 72, 72)
    shadow_color = Color.new(160, 160, 160)
	@appHoveredOver = @appsOnThisPage[@cursorPos-1]
	@appHoveredOverName = @appHoveredOver[:name]

    text_positions = [
       ["#{@appHoveredOverName}",Graphics.width/2,52,2,base_color,shadow_color]
    ]
    pbDrawTextPositions(overlay, text_positions)
  end
  
  def getAppFunction
	case @appHoveredOver[:functionName]
	when "phonePokedex"
		pbFadeOutIn(99999) {
			scene = PokemonPokedexMenu_Scene.new
			screen = PokemonPokedexMenuScreen.new(scene)
			screen.pbStartScreen
		}
	when "phoneMap"
		pbShowMap(-1,false)
	when "phoneTrainer"
		pbFadeOutIn(99999) {
			scene = PokemonTrainerCard_Scene.new
			screen = PokemonTrainerCardScreen.new(scene)
			screen.pbStartScreen
		}
	when "phoneOptions"
		pbFadeOutIn(99999) {
			scene = PokemonOption_Scene.new
			screen = PokemonOptionScreen.new(scene)
			screen.pbStartScreen
			pbUpdateSceneMap
		}
	when "phoneObjectives"
		pbFadeOutIn(99999) { pbViewQuests }
	when "phoneWiki"
		pbFadeOutIn(99999) { system("start https://pokemon-untamed.fandom.com/wiki/Pok%C3%A9mon_Untamed_Wiki") }
	when "phoneTutorNet"
		
	when "phoneTutorials"
		pbFadeOutIn(99999) { pbViewTips }
	when "phoneAchievements"
		pbFadeOutIn(99999) { 
			scene = PokemonAchievements_Scene.new
			screen = PokemonAchievements.new(scene)
			screen.pbStartScreen
		}
	end #case @appHoveredOver[:functionName]
	
	
	#phonePokedex
  end #def getAppFunction
  

  def pbMain
    # Loop called once per frame.
    loop do
      # Updates the graphics.
      Graphics.update
      # Updates the button/key input check.
      Input.update
      # Calls the update method on this class (look at 'def update' in
      # this class).
      self.update
      # If button C or button B (trigger by keys C and X) is pressed, then
      # exits from loop and from pbMain (since the method contains only the
      # loop), starts pbEndScene (look at 'def pbStartScreen').
      if Input.trigger?(Input::USE)
		getAppFunction
        #case @cursorPos
		#			when 1 # pokedex
		#				pbFadeOutIn(99999) {
		#					scene = PokemonPokedexMenu_Scene.new
		#					screen = PokemonPokedexMenuScreen.new(scene)
		#					screen.pbStartScreen
		#				}
		#			when 2 # map
		#				pbShowMap(-1,false)
		#			when 3 # trainer card
		#				pbFadeOutIn(99999) {
		#					scene = PokemonTrainerCard_Scene.new
		#					screen = PokemonTrainerCardScreen.new(scene)
		#					screen.pbStartScreen
		#				}
		#			when 4 # settings
		#				pbFadeOutIn(99999) {
		#					scene = PokemonOption_Scene.new
		#					screen = PokemonOptionScreen.new(scene)
		#					screen.pbStartScreen
		#					pbUpdateSceneMap
		#				}
		#			when 5 # quests
		#				pbFadeOutIn(99999) { pbViewQuests }
		#			when 6 # fandom wiki
		#		end
      elsif Input.trigger?(Input::RIGHT)
        oldCursorPos = @cursorPos
        @cursorPos += 1
        @cursorPos = 6 if @cursorPos < 1
        @cursorPos = 1 if @cursorPos > 6
				#~ echoln "right #{@page.to_i}"
        if @cursorPos != oldCursorPos
					@sprites["cursor"].x += 148
					case @cursorPos
						when 1
							@sprites["cursor"].x = (Graphics.width - 380)/2
							@sprites["cursor"].y = (Graphics.height - 184)/2
						when 3
							@sprites["cursor"].x = (Graphics.width - 380)/2 + (148 * 2)
							@sprites["cursor"].y = (Graphics.height - 184)/2
						when 4
							@sprites["cursor"].x = (Graphics.width - 380)/2
							@sprites["cursor"].y = (Graphics.height - 184)/2 + 124
						when 6
							@sprites["cursor"].x = (Graphics.width - 380)/2 + (148 * 2)
							@sprites["cursor"].y = (Graphics.height - 184)/2 + 124
					end
          pbPlayCursorSE
          dorefresh = true
					draw_text
        end
      elsif Input.trigger?(Input::LEFT)
        oldCursorPos = @cursorPos
        @cursorPos -= 1
        @cursorPos = 6 if @cursorPos < 1
        @cursorPos = 1 if @cursorPos > 6
				#~ echoln "left #{@page.to_i}"
        if @cursorPos != oldCursorPos
					@sprites["cursor"].x -= 148
					case @cursorPos
						when 1
							@sprites["cursor"].x = (Graphics.width - 380)/2
							@sprites["cursor"].y = (Graphics.height - 184)/2
						when 3
							@sprites["cursor"].x = (Graphics.width - 380)/2 + (148 * 2)
							@sprites["cursor"].y = (Graphics.height - 184)/2
						when 4
							@sprites["cursor"].x = (Graphics.width - 380)/2
							@sprites["cursor"].y = (Graphics.height - 184)/2 + 124
						when 6
							@sprites["cursor"].x = (Graphics.width - 380)/2 + (148 * 2)
							@sprites["cursor"].y = (Graphics.height - 184)/2 + 124
					end
          pbPlayCursorSE
          dorefresh = true
					draw_text
        end
      elsif Input.trigger?(Input::DOWN)
				if @cursorPos <= 3
					oldCursorPos = @cursorPos
					@cursorPos += 3
					@cursorPos = 6 if @cursorPos < 1
					@cursorPos = 1 if @cursorPos > 6
					#~ echoln "down #{@page.to_i}"
					if @cursorPos != oldCursorPos
						@sprites["cursor"].y = (Graphics.height - 184)/2 + 124
						pbPlayCursorSE
						dorefresh = true
						draw_text
					end
				end
      elsif Input.trigger?(Input::UP)
				if @cursorPos >= 4
					oldCursorPos = @cursorPos
					@cursorPos -= 3
					@cursorPos = 6 if @cursorPos < 1
					@cursorPos = 1 if @cursorPos > 6
					#~ echoln "up #{@page.to_i}"
					if @cursorPos != oldCursorPos
						@sprites["cursor"].y = (Graphics.height - 184)/2
						pbPlayCursorSE
						dorefresh = true
						draw_text
					end
				end
      elsif Input.trigger?(Input::BACK)
        # To play the Cancel SE (defined in database) when the diploma is
        # canceled, then uncomment the below line.
        pbPlayCancelSE
        break
      end
    end 
  end

  def pbEndScene
    # Hide all sprites with FadeOut effect.
    pbFadeOutAndHide(@sprites) { update }
    # Remove all sprites.
    pbDisposeSpriteHash(@sprites)
    # Remove the viewpoint.
    @viewport.dispose
  end
end

class PhoneScreen # The screen class
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    # Put the method order in scene. The pbMain have the scene main loop 
    # that only closes the scene when the loop breaks.
    @scene.pbStartScene
    @scene.pbMain
    @scene.pbEndScene
  end
end

# A def for a quick script call. 
# If user doesn't put some parameter, then it uses default values.
def pbPhone
  # Displays a fade out before the scene starts, and a fade in after the scene
  # ends
  pbFadeOutIn(99999) {
    scene = PhoneScene.new
    screen = PhoneScreen.new(scene)
    screen.pbStartScreen
  }
end