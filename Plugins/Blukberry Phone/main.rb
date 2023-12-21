#This script will be a separate screen that houses the following apps which will
#unlock as you play
#Pokedex
#Trainer card
#Map
#Wiki
#Objectives

#roadmap:
#access via hotkey which you can change from controls screen

class PhoneScene # The scene class
	
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

	#draw left and right arrows
	@sprites["leftarrow"] = AnimatedSprite.new("Graphics/Pictures/leftarrow",8,40,28,2,@viewport)
	@sprites["leftarrow"].x = 40
	@sprites["leftarrow"].y = Graphics.height/2 - @sprites["leftarrow"].bitmap.height/16
	@sprites["leftarrow"].z = 99999
	@sprites["leftarrow"].visible = false
	@sprites["rightarrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow",8,40,28,2,@viewport)
	@sprites["rightarrow"].x = Graphics.width - 40 - @sprites["rightarrow"].bitmap.width
	@sprites["rightarrow"].y = Graphics.height/2 - @sprites["rightarrow"].bitmap.height/16
	@sprites["rightarrow"].z = 99999
	@sprites["rightarrow"].visible = false
	@sprites["leftarrow"].play
	@sprites["rightarrow"].play

	@currentPage = 0
	@cursorPos = 1

	drawApps
	updateSideArrows
	
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
	updateCursorPos
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
		addPredefinedTutorMoves
		pbFadeOutIn(99999) {
			scene = PokemonTutorNet_Scene.new
			screen = PokemonTutorNetScreen.new(scene)
			screen.pbStartScreen
		}	
	when "phoneTutorials"
		pbFadeOutIn(99999) { pbViewTips }
	when "phoneAchievements"
		pbFadeOutIn(99999) { 
			scene = PokemonAchievements_Scene.new
			screen = PokemonAchievements.new(scene)
			screen.pbStartScreen
		}
	end #case @appHoveredOver[:functionName]
  end #def getAppFunction

  def pbMain
    # Loop called once per frame.
    loop do
      Graphics.update
      Input.update
      self.update
      if Input.trigger?(Input::USE)
		getAppFunction
      elsif Input.trigger?(Input::RIGHT)
        if @cursorPos >= @appsOnThisPage.length && @currentPage >= @maxPages-1
			#if the cursor is already on the last app of the page and there is no next page, don't do anything
		elsif @cursorPos == @maxAppsPerRow && @currentPage < @maxPages-1
			#at the top-right edge of the screen
			#another page exists to the right
			oldCursorPos = @cursorPos
			@cursorPos = 1
			@currentPage += 1
			updateSideArrows
			drawApps
		elsif @cursorPos < @maxAppsPerRow*2 && @cursorPos != @maxAppsPerRow
			#not at the right edge of the screen
			oldCursorPos = @cursorPos
			@cursorPos += 1
		elsif @cursorPos == @maxAppsPerRow*2 && @currentPage < @maxPages-1
			#at the bottom-right edge of the screen
			#another page exists to the right
			oldCursorPos = @cursorPos
			@cursorPos = @maxAppsPerRow+1 #if there's no bottom row of apps on the next page, this messes up. Corrected with 'correctCursorPos', which must run after 'drawApps'
			@currentPage += 1
			updateSideArrows
			drawApps
			correctCursorPos
		end #if @cursorPos >= @maxAppsPerRow && @currentPage < @maxPages-1
		pbPlayCursorSE
		draw_text
      elsif Input.trigger?(Input::LEFT)
		if @cursorPos == 1 && @currentPage > 0
			#at the top-left edge of the screen
			#another page exists to the left
			oldCursorPos = @cursorPos
			@cursorPos = @maxAppsPerRow
			@currentPage -= 1
			updateSideArrows
			drawApps
		elsif @cursorPos > 1 && @cursorPos != @maxAppsPerRow+1
			#not at the left edge of the screen
			oldCursorPos = @cursorPos
			@cursorPos -= 1
		elsif @cursorPos == @maxAppsPerRow+1 && @currentPage > 0
			#at the bottom-left edge of the screen
			#another page exists to the left
			oldCursorPos = @cursorPos
			@cursorPos = @maxAppsPerRow*2
			@currentPage -= 1
			updateSideArrows
			drawApps
		end #if @cursorPos == 1 && @currentPage > 0
		pbPlayCursorSE
		draw_text
      elsif Input.trigger?(Input::DOWN)
		if @cursorPos+@maxAppsPerRow > @appsOnThisPage.length
			#if the cursor cannot go down because an app does not exist below where it tries to go, put the cursor on the last available app
			oldCursorPos = @cursorPos
			@cursorPos = @appsOnThisPage.length
		else
			oldCursorPos = @cursorPos
			@cursorPos += @maxAppsPerRow
		end #if @cursorPos+@maxAppsPerRow > @appsOnThisPage.length
		pbPlayCursorSE
		draw_text
      elsif Input.trigger?(Input::UP)
		if @cursorPos-@maxAppsPerRow < 1
			#if the cursor cannot go up because an app does not exist above where it tries to go
		else
			oldCursorPos = @cursorPos
			@cursorPos -= @maxAppsPerRow
		end #if @cursorPos-@maxAppsPerRow < 1
		pbPlayCursorSE
		draw_text
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
	allSprites = @sprites.merge(@appSprites)
    pbFadeOutAndHide(allSprites) { update }
    # Remove all sprites.
    pbDisposeSpriteHash(allSprites)
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