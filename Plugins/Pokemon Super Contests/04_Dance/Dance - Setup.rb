class Dance
  #=========================================================
  # Setup
  #=========================================================
  def self.setup    
    @chosenRank = ContestTypeRank.getChosenRank
    
    #jigglypuff starting X and Y
    @jigglypuffStartX = -16
    @jigglypuffStartY = Graphics.height - 110
    
    #timer for the beat
    @timerX = 0
    
    #timer and variables for the beat and jigglypuff
    @bobY = 0
    @timerY = 0
    @bobDistance = 24
    @bobSpeed = 0.19635
    
    #this will be used to keep track of which contestant is the lead dancer
    @dancerTurn = 1
    #this will be used for stopping the updating of the bar and bar line while
    #the game switches dancers and when the dancing is all done
    @pauseDancing = false
    #used to keep track of how many times the track has been completed
    #every two times the track is completed, we will switch dancers until
    #everyone has danced
    @trackRunCount = 0
    @setOfMoves = 1
    
    @maxDanceMoves = 3 if @chosenRank == "Normal" || @chosenRank == "Great"
    @maxDanceMoves = 4 if @chosenRank == "Ultra" || @chosenRank == "Master"
    
    @danceMovesLeft = @maxDanceMoves #player's dance moves left
    @possibleMovesForAI = []
    @leadMovesOnBeat = [] #legacy code; afraid to delete
    @backupMovesOnBeat = [] #legacy code; afraid to delete
    @leadPixelPlacementOnBeat = [] #legacy code; afraid to delete
    @backupPixelPlacementOnBeat = [] #legacy code; afraid to delete
    
    @moveButtonCounter = 0 #used for naming sprites individually
    
    #used for dancer sin wave calculation
    @moveDistance = 34
    @moveSpeed = 0.3
    
    @button_held = false #used to make sure the script does not continue to process input if button is held
    @inputCooldownTimer = 0
    #@inputCooldown = (1*Graphics.frame_rate/4)
    @inputCooldown = 16 #was 12
    #used to make sure the button animation does not stop the same frame it is started
    @animTimer = 0
    
    #initialize graphics
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @moveButtonSprites = {}
    
    @sprites["dark_tone"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["dark_tone"].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(-255,-255,-255))
    @sprites["dark_tone"].x = 0
    @sprites["dark_tone"].y = 0
    @sprites["dark_tone"].z = 999999
    @sprites["dark_tone"].opacity = 100
    
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/Contest/dance/stage_background")
    @sprites["background"].x = 0
    @sprites["background"].y = 0
    @sprites["background"].z = 99997
    
    #contestant sprites
    @sprites["contestant1"] = IconSprite.new(0, 0, @viewport)
    @sprites["contestant1"].setBitmap("Graphics/Pictures/Contest/dressup/contestants/#{@chosenRank}/#{@chosenContestants[0][:PkmnName]}")
    @sprites["contestant1"].x = Graphics.width/2 - @sprites["contestant1"].width/2
    @sprites["contestant1"].y = Graphics.height/2 - @sprites["contestant1"].height/2 + 20
    @sprites["contestant1"].z = 99999
    @sprites["contestant1"].zoom_x = 1.0
    @sprites["contestant1"].zoom_y = 1.0
    
    @sprites["contestant2"] = IconSprite.new(0, 0, @viewport)
    @sprites["contestant2"].setBitmap("Graphics/Pictures/Contest/dressup/contestants/#{@chosenRank}/#{@chosenContestants[1][:PkmnName]}")
    @sprites["contestant2"].x = 0
    @sprites["contestant2"].y = 0
    @sprites["contestant2"].z = 99998
    @sprites["contestant2"].zoom_x = 0.8
    @sprites["contestant2"].zoom_y = 0.8
    
    @sprites["contestant3"] = IconSprite.new(0, 0, @viewport)
    @sprites["contestant3"].setBitmap("Graphics/Pictures/Contest/dressup/contestants/#{@chosenRank}/#{@chosenContestants[2][:PkmnName]}")
    @sprites["contestant3"].x = Graphics.width/2 - (@sprites["contestant3"].width * 0.8)/2
    @sprites["contestant3"].y = 0
    @sprites["contestant3"].z = 99998
    @sprites["contestant3"].zoom_x = 0.8
    @sprites["contestant3"].zoom_y = 0.8
    
    #player pokemon
    @sprites["contestant4"] = IconSprite.new(0, 0, @viewport)
    @sprites["contestant4"].setBitmap("Graphics/Pictures/Contest/dressup/contestants/#{$player.id}.png")
    @sprites["contestant4"].x = Graphics.width - (@sprites["contestant4"].width * 0.8)
    @sprites["contestant4"].y = 0
    @sprites["contestant4"].z = 99998
    @sprites["contestant4"].zoom_x = 0.8
    @sprites["contestant4"].zoom_y = 0.8
    
    @leadDancerSprite = @sprites["contestant1"]
    @leadDancerX = @sprites["contestant1"].x
    @leadDancerY = @sprites["contestant1"].y
    @backupDancer1Sprite = @sprites["contestant2"]
    @backupDancer1X = @sprites["contestant2"].x
    @backupDancer1Y = @sprites["contestant2"].y
    @backupDancer2Sprite = @sprites["contestant3"]
    @backupDancer2X = @sprites["contestant3"].x
    @backupDancer2Y = @sprites["contestant3"].y
    @backupDancer3Sprite = @sprites["contestant4"]
    @backupDancer3X = @sprites["contestant4"].x
    @backupDancer3Y = @sprites["contestant4"].y
    
    #(animname, framecount, framewidth, frameheight, frameskip)
    @sprites["button_jump"] = AnimatedSprite.new("Graphics/Pictures/Contest/dance/button jump", 4, 78, 83, 0, @viewport)
    @sprites["button_jump"].x = Graphics.width - (@sprites["button_jump"].width*1.5) - 15
    @sprites["button_jump"].y = Graphics.height/2 - @sprites["button_jump"].height/4
    @sprites["button_jump"].z = 99999
    @sprites["button_jump"].opacity = 150
    
    @sprites["button_right"] = AnimatedSprite.new("Graphics/Pictures/Contest/dance/button right", 4, 78, 83, 0, @viewport)
    @sprites["button_right"].x = Graphics.width - @sprites["button_right"].width - 10
    @sprites["button_right"].y = Graphics.height - @sprites["button_right"].height - 100
    @sprites["button_right"].z = 99999
    @sprites["button_right"].opacity = 150
    
    @sprites["button_left"] = AnimatedSprite.new("Graphics/Pictures/Contest/dance/button left", 4, 78, 83, 0, @viewport)
    @sprites["button_left"].x = @sprites["button_right"].x - @sprites["button_left"].width - 10
    @sprites["button_left"].y = Graphics.height - @sprites["button_left"].height - 100
    @sprites["button_left"].z = 99999
    @sprites["button_left"].opacity = 150
    
    @sprites["button_front"] = AnimatedSprite.new("Graphics/Pictures/Contest/dance/button front", 4, 78, 83, 0, @viewport)
    @sprites["button_front"].x = Graphics.width - (@sprites["button_front"].width*1.5) - 15
    @sprites["button_front"].y = @sprites["button_left"].y + @sprites["button_front"].height/2
    @sprites["button_front"].z = 99999
    @sprites["button_front"].opacity = 150
    
    @sprites["dance_track"] = IconSprite.new(0, 0, @viewport)
    @sprites["dance_track"].setBitmap("Graphics/Pictures/Contest/dance/dance_track")
    @sprites["dance_track"].x = Graphics.width/2 - @sprites["dance_track"].width/2
    @sprites["dance_track"].y = Graphics.height - @sprites["dance_track"].height
    @sprites["dance_track"].z = 99999
    
    @sprites["bar_line"] = IconSprite.new(0, 0, @viewport)
    @sprites["bar_line"].setBitmap("Graphics/Pictures/Contest/dance/bar line")
    @sprites["bar_line"].x = 0 - @sprites["bar_line"].width
    @sprites["bar_line"].y = Graphics.height - @sprites["bar_line"].height
    @sprites["bar_line"].z = 999999
    
    #jigglypuff
    @sprites["jigglypuff"] = AnimatedSprite.new("Graphics/Pictures/Contest/dance/jigglypuff", 2, 32, 30, 4, @viewport)
    @sprites["jigglypuff"].x = @jigglypuffStartX
    @sprites["jigglypuff"].y = @jigglypuffStartY
    @sprites["jigglypuff"].z = 99999
    
    #bar animation
    #(animname, framecount, framewidth, frameheight, frameskip)
    @sprites["bar1"] = AnimatedSprite.new("Graphics/Pictures/Contest/dance/bar animation", 32, 128, 12, 0, @viewport)
    @sprites["bar1"].x = 0
    @sprites["bar1"].y = Graphics.height - @sprites["dance_track"].height + 4
    @sprites["bar1"].z = 99999
    @sprites["bar1"].visible = false
    
    @sprites["bar2"] = AnimatedSprite.new("Graphics/Pictures/Contest/dance/bar animation", 32, 128, 12, 0, @viewport)
    @sprites["bar2"].x = @sprites["bar1"].width
    @sprites["bar2"].y = Graphics.height - @sprites["dance_track"].height + 4
    @sprites["bar2"].z = 99999
    @sprites["bar2"].visible = false
    
    @sprites["bar3"] = AnimatedSprite.new("Graphics/Pictures/Contest/dance/bar animation", 32, 128, 12, 0, @viewport)
    @sprites["bar3"].x = @sprites["bar1"].width * 2
    @sprites["bar3"].y = Graphics.height - @sprites["dance_track"].height + 4
    @sprites["bar3"].z = 99999
    @sprites["bar3"].visible = false
    
    @sprites["bar4"] = AnimatedSprite.new("Graphics/Pictures/Contest/dance/bar animation", 32, 128, 12, 0, @viewport)
    @sprites["bar4"].x = @sprites["bar1"].width * 3
    @sprites["bar4"].y = Graphics.height - @sprites["dance_track"].height + 4
    @sprites["bar4"].z = 99999
    @sprites["bar4"].visible = false
    
    @sprites["instructions"] = Window_AdvancedTextPokemon.new(_INTL("<c2=043c3aff>Copy the Pokémon before you!</c2>"))
    @sprites["instructions"].viewport = @viewport
    @sprites["instructions"].width = Graphics.width
    @sprites["instructions"].x = Graphics.width/2 - @sprites["instructions"].width/2
    @sprites["instructions"].y = Graphics.height/2 - @sprites["instructions"].height/2
    @sprites["instructions"].z = 99999
    @sprites["instructions"].visible = false
    skinfile = MessageConfig.pbGetSpeechFrame
    @sprites["instructions"].setSkin(skinfile)
    
    #for choosing the height of each contestant's button when making a move
    @leadButtonHeight    = (@sprites["dance_track"].y + @sprites["dance_track"].height/2) - 8
    @backup1ButtonHeight = @leadButtonHeight - 16
    @backup2ButtonHeight = @leadButtonHeight
    @backup3ButtonHeight = @leadButtonHeight + 16
    
    #for choosing the z value of each contestant's button when making a move
    @leadButtonZ    = 99999
    @backup1ButtonZ = 100000
    @backup2ButtonZ = 100001
    @backup3ButtonZ = 100002
    
    #================================================
    #================ Set up Grades =================
    #================================================
    @leadGradeZoom = 1.0
    @backupGradeZoom = 0.8
    
    @sprites["gradeContestant1"] = IconSprite.new(0, 0, @viewport)
    @sprites["gradeContestant1"].setBitmap("Graphics/Pictures/Contest/dance/excellent")
    @leadGradeX = (@sprites["contestant1"].x + @sprites["contestant1"].width/2) - @sprites["gradeContestant1"].width/3
    @leadGradeY = @sprites["contestant1"].y
    @sprites["gradeContestant1"].x = @leadGradeX
    @sprites["gradeContestant1"].y = @leadGradeY
    @sprites["gradeContestant1"].zoom_x = @leadGradeZoom
    @sprites["gradeContestant1"].zoom_y = @leadGradeZoom
    @sprites["gradeContestant1"].z = 99999
    @sprites["gradeContestant1"].opacity = 0
    
    @sprites["gradeContestant2"] = IconSprite.new(0, 0, @viewport)
    @sprites["gradeContestant2"].setBitmap("Graphics/Pictures/Contest/dance/excellent")
    @backLeftGradeX = (@sprites["contestant2"].x + (@sprites["contestant2"].width*0.8)/2) - @sprites["gradeContestant2"].width/3
    @backGradeY = @sprites["contestant2"].y
    @sprites["gradeContestant2"].x = @backLeftGradeX
    @sprites["gradeContestant2"].y = @backGradeY
    @sprites["gradeContestant2"].zoom_x = @backupGradeZoom
    @sprites["gradeContestant2"].zoom_y = @backupGradeZoom
    @sprites["gradeContestant2"].z = 99999
    @sprites["gradeContestant2"].opacity = 0
    
    @sprites["gradeContestant3"] = IconSprite.new(0, 0, @viewport)
    @sprites["gradeContestant3"].setBitmap("Graphics/Pictures/Contest/dance/excellent")
    @backMiddleGradeX = (@sprites["contestant3"].x + (@sprites["contestant3"].width*0.8)/2) - @sprites["gradeContestant3"].width/3
    @sprites["gradeContestant3"].x = @backMiddleGradeX
    @sprites["gradeContestant3"].y = @backGradeY
    @sprites["gradeContestant3"].zoom_x = @backupGradeZoom
    @sprites["gradeContestant3"].zoom_y = @backupGradeZoom
    @sprites["gradeContestant3"].z = 99999
    @sprites["gradeContestant3"].opacity = 0
    
    @sprites["gradeContestant4"] = IconSprite.new(0, 0, @viewport)
    @sprites["gradeContestant4"].setBitmap("Graphics/Pictures/Contest/dance/excellent")
    @backRightGradeX = (@sprites["contestant4"].x + (@sprites["contestant4"].width*0.8)/2) - @sprites["gradeContestant4"].width/3
    @sprites["gradeContestant4"].x = @backRightGradeX
    @sprites["gradeContestant4"].y = @backGradeY
    @sprites["gradeContestant4"].zoom_x = @backupGradeZoom
    @sprites["gradeContestant4"].zoom_y = @backupGradeZoom
    @sprites["gradeContestant4"].z = 99999
    @sprites["gradeContestant4"].opacity = 0
    
    #================================================
    #============= Set up Move Sprites ==============
    #================================================
    #bitmap variables
    @opponentFrontButtonBitmap = AnimatedSprite.new("Graphics/Pictures/Contest/dance/opponent front", 3, 28, 32, 2, @viewport)
    @opponentJumpButtonBitmap = AnimatedSprite.new("Graphics/Pictures/Contest/dance/opponent jump", 3, 28, 32, 2, @viewport)
    @opponentLeftButtonBitmap = AnimatedSprite.new("Graphics/Pictures/Contest/dance/opponent left", 3, 28, 32, 2, @viewport)
    @opponentRightButtonBitmap = AnimatedSprite.new("Graphics/Pictures/Contest/dance/opponent right", 3, 28, 32, 2, @viewport)
    
    @playerFrontButtonBitmap = AnimatedSprite.new("Graphics/Pictures/Contest/dance/player front", 3, 28, 32, 2, @viewport)
    @playerJumpButtonBitmap = AnimatedSprite.new("Graphics/Pictures/Contest/dance/player jump", 3, 28, 32, 2, @viewport)
    @playerLeftButtonBitmap = AnimatedSprite.new("Graphics/Pictures/Contest/dance/player left", 3, 28, 32, 2, @viewport)
    @playerRightButtonBitmap = AnimatedSprite.new("Graphics/Pictures/Contest/dance/player right", 3, 28, 32, 2, @viewport)
    
    #@sprites["contestant1Move1"].setBitmap = @opponentFrontButtonBitmap
    
    danceMovesHash = {
        ButtonPlacementTimings1: [], #used for placing button sprites on beat
        ButtonPlacementTimings2: [],
        DistortedTimings1: [], #used for placing button sprites for AI (can be not on beat)
        DistortedTimings2: [],
        ButtonTypes1: [], #used for determining the type of move AIs should match
        ButtonTypes2: [],
        DistortedTypes1: [], #used for determining the type of move AIs did, whether they matched or not
        DistortedTypes2: [],
        PkmnSpriteMoveTiming1: [], #used for moving the AI sprite and judging that movement
        PkmnSpriteMoveTiming2: [],
        PkmnSpriteMoveDirection1: [], #used for moving the AI sprite and judging that movement
        PkmnSpriteMoveDirection2: [],
        MoveSpriteY: 0, #used for button sprite's Y
        MoveSpriteZ: 0, #used for button sprite's Z
        PkmnSpriteStartX: 0, #used for returning pkmn sprite to original X
        PkmnSpriteStartY: 0, #used for returning pkmn sprite to original Y
        PkmnSpriteMoveTimer: 0, #used for controlling the sin wave when moving a pkmn sprite
        DanceSinWave: 0, #contains the sin wave that moves the pkmn sprite smoothly
        DanceDirection: nil, #used for moving the pkmn sprite when making a dance move
        gradeSpriteX: 0, #used for the judge sprite's X
        gradeSpriteY: 0, #used for the judge sprite's Y
        gradeZoom: 0, #used for the judge sprite's zoom
        gradeCountdown: 0, #used for the judge sprite's cooldown - how long it stays on screen
        gradeValue: nil, #used for the method that listens out for a grade to make an animation
        gradeExcellentStreak: 0 #used for keeping track of the contestant's streak of excellent moves (to change the SEs)
    }
    
    @chosenContestants[0][:DanceMoves] = Marshal.load(Marshal.dump(danceMovesHash))
    @chosenContestants[1][:DanceMoves] = Marshal.load(Marshal.dump(danceMovesHash))
    @chosenContestants[2][:DanceMoves] = Marshal.load(Marshal.dump(danceMovesHash))
    @chosenContestants[3][:DanceMoves] = Marshal.load(Marshal.dump(danceMovesHash))
    
    @chosenContestants[0][:DanceMoves][:MoveSpriteY] = @leadButtonHeight
    @chosenContestants[1][:DanceMoves][:MoveSpriteY] = @leadButtonHeight - 16
    @chosenContestants[2][:DanceMoves][:MoveSpriteY] = @leadButtonHeight
    @chosenContestants[3][:DanceMoves][:MoveSpriteY] = @leadButtonHeight + 16
    
    @chosenContestants[0][:DanceMoves][:MoveSpriteZ] = @leadButtonZ
    @chosenContestants[1][:DanceMoves][:MoveSpriteZ] = @backup1ButtonZ
    @chosenContestants[2][:DanceMoves][:MoveSpriteZ] = @backup2ButtonZ
    @chosenContestants[3][:DanceMoves][:MoveSpriteZ] = @backup3ButtonZ
    
    #used for placing sprites to match moves based on the track
    @matchSpriteTimings = {
      ButtonPlacementTimings1: [],
      ButtonPlacementTimings2: [],
      ButtonTypes1: [],
      ButtonTypes2: []
    }
  end #def self.setup
    
end #of class Dance