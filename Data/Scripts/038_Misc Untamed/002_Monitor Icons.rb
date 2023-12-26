# Pokemon monitor icons
# Credit: Ulithium_Dragon, bo4p5687
# Some content recycled from Encounter List UI
# - ELUI Credit: ThatWelshOne_,raZ,Marin,Maruno,Nuri Yuri,PurpleZaffre,Savordez,Vendily
# Modified by Gardenette and SpaceWestern
#
# Call: MonitorIcons.displayScreen
# If you want to change coordinate of bitmap, call like this MonitorIcons.show(x', y')
# 	-> x', y' are numbers that have equation: x (real) = x (recent) + x'; y (real) = y (recent) + y'
# You can change zoom with this method -> MonitorIcons.show(x', y', zoom)
# If you want to change zoom but you don't want to change x and y, just call MonitorIcons.show(0, 0, zoom)
# It uses icon file of PE
#
# Some helpful info by Space:
# The pokecenter monitor is 144px wide and 60 px tall
# - If putting all 6 pokemon in at once, that means 144/6=24, so each pokemon has 24 px to work with
# - This means sprites would have to be reduced to 40% to be guaranteed to fit side by side
# - Since you want to position the centers of each sprite, this means the first and last sprites should be 12px away from the edge of the screen
# - In reality, most sprites barely come close to reaching their limits to the sides, but it's good to keep in mind
# - An alternate option is to stagger the sprites in a zig-zag pattern, which would let them be spaced a little closer together
# - Will try to implement this at a later date
#
# All box icons (as of 8/1/22) are 64px square
# Opacity for sprites is on a scale from 0 to 255
  
class MonitorDisplay

  # Constructor method, modified from Encounter List UI
  # Sets a handful of key variables needed throughout the script
  def initialize
    # Initialize the viewport (the canvas on which the sprites are displayed
    #@viewport = Viewport.new(198, 32, 144, 60)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    # Initialize an empty list to store the sprites
    @sprites = {}
    # Store the current party size for indexing purposes
    @pSize = $Trainer.pokemon_count
    
    #set zoom amount
    @zoom = 0.5
  end

  def loadSprites
    
    #set starting position of pokeballs
    ballX = 207
    ballY = 60
    # starting position of first sprite: 1px away from screen edge
    x = 201
    #y = event.screen_y
    y = 36
    yOffset = -6
    @pSize.times do |i|
      #determine pokemon species and form
      pkmn = $Trainer.pokemon_party[i]
      species = pkmn.species
      species_data = GameData::Species.get(species)
      species_form = pkmn.form
			bmpkmn  = GameData::Species.icon_bitmap(species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?)
			realw   = bmpkmn.width / 2
			realh   = bmpkmn.height
      
      #initializes pokemon sprites
      @sprites["icon_#{i}"] = PokemonSpeciesIconSprite.new(species,@viewport)
      @sprites["icon_#{i}"].pbSetParams(species,0,species_form,false)
			@sprites["icon_#{i}"].bitmap = bmpkmn
			@sprites["icon_#{i}"].src_rect.width = realw
			@sprites["icon_#{i}"].ox = @sprites["icon_#{i}"].src_rect.width / 2
			@sprites["icon_#{i}"].oy = @sprites["icon_#{i}"].src_rect.height / 2
      @sprites["icon_#{i}"].x = x
      @sprites["icon_#{i}"].y = y-yOffset
      @sprites["icon_#{i}"].zoom_x = @sprites["icon_#{i}"].zoom_y = @zoom
      @sprites["icon_#{i}"].opacity = 178
      @sprites["icon_#{i}"].visible = false
      
      # initializes ball sprites
      # this can probably be in a more efficient container, but Changelings work for now
      @sprites["ball_#{i}"] = ChangelingSprite.new(0,0,@viewport)
      @sprites["ball_#{i}"].x = ballX
      @sprites["ball_#{i}"].y = ballY
      file_path = sprintf("Graphics/Pictures/Pokemon Monitor Icons/%s", pkmn.poke_ball)
      @sprites["ball_#{i}"].addBitmap("phase1",file_path)
      @sprites["ball_#{i}"].changeBitmap("phase1")
      # actually set current phase
      @sprites["ball_#{i}"].visible = false
      
      # move to next position
      ballX += 18
      x += 22
      yOffset = -yOffset
    end
  end
  
  def pbMonitorView
    # display sprites and balls one by one
    for i in 0...@pSize
      @sprites["icon_#{i}"].visible = true
      @sprites["ball_#{i}"].visible = true
      pbSEPlay("Battle ball shake")
      pbWait(16)
    end
    
    #play healing done sound
    pbMEPlay("Pkmn healing")
    
    # pokemon and ball sprites blinking yellow
    for t in 0...4
      for i in 0...@pSize
        @sprites["icon_#{i}"].tone.set(255,239,0,50)
        @sprites["ball_#{i}"].tone.set(255,239,0,50)
      end
      pbWait(10)
      
      for i in 0...@pSize
        @sprites["icon_#{i}"].tone.set(0,0,0,0)
        @sprites["ball_#{i}"].tone.set(0,0,0,0)
      end
      pbWait(10)
    end
  end

  # Hide sprites one by one
  def hideSprites
    for i in 0...@pSize
      @sprites["icon_#{i}"].visible = false
      @sprites["ball_#{i}"].visible = false
      pbSEPlay("Battle ball shake")
      pbWait(16)
    end
  end

  # Dipose stuff at the end
  def finish
    hideSprites
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

module MonitorIcons
  
  def self.displayScreen
    displayMon = MonitorDisplay.new
    displayMon.loadSprites
    displayMon.pbMonitorView
    displayMon.finish
  end
end