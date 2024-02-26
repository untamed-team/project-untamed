class Acting
  #=========================================================
  # Setup
  #=========================================================
  def self.setup
    
    @animations   = []
    @frameCounter = 0
    
    pbSEStop
    
    #initialize important variables
    @chosenType = ContestTypeRank.getChosenType
    @chosenRank = ContestTypeRank.getChosenRank
    @playerPkmn = ContestContestant.getPlayerPkmn

    #new keys for judge hashes
    ContestSettings::JUDGES[0].merge!({ID: 0})
    ContestSettings::JUDGES[1].merge!({ID: 1})
    ContestSettings::JUDGES[2].merge!({ID: 2})
    
    ContestSettings::JUDGES[0].merge!({Voltage: 0})
    ContestSettings::JUDGES[1].merge!({Voltage: 0})
    ContestSettings::JUDGES[2].merge!({Voltage: 0})
    
    ContestSettings::JUDGES[0].merge!({TimesPerformedTo: 0})
    ContestSettings::JUDGES[1].merge!({TimesPerformedTo: 0})
    ContestSettings::JUDGES[2].merge!({TimesPerformedTo: 0})
    
    @voltagePreventDown = false
    @voltagePreventUp = false
    @judgeNumberPreviousTurnVoltageUp = nil
    @judgeNumberThisTurnVoltageUp = nil
    @judgeNumberVoltagePeakPreviousTurn = nil
    
    @performanceNumber = 0
    @contestantTurn = 0
    
    #turn order variables
    @nextRoundContestantOrder = ["","","",""]
    
    self.getMoveFlags #used to check flags of your Pokemon's moves
    #should only need to run once per contest
    
    #decide contestants' move order
    self.decideContestantOrder
    
    #initialize graphics
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @moveAnimViewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @moveAnimViewport.z = 999999
    @tilesViewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @tilesViewport.z = 999999
    
    @sprites = {}
    @heartSprites = {}
    
    #cursors for selecting moves and choice of judge to perform for
    @sprites["cursor1"] = IconSprite.new(0, 0, @viewport)
    @cursor1 = @sprites["cursor1"]
    @cursor1.setBitmap("Graphics/Pictures/Contest/acting/cursor1")
    @cursor1.visible = false
    #starting cursor1 position
    @cursor1Pos = 1
    
    @scene = @sprites["cursor1"]
    
    @sprites["cursor2"] = IconSprite.new(0, 0, @viewport)
    @cursor2 = @sprites["cursor2"]
    @cursor2.setBitmap("Graphics/Pictures/Contest/acting/cursor2")
    @cursor2.visible = false
    #starting cursor2 position
    @cursor2Pos = 1
        
    #background
    @sprites["background"] = AnimatedSprite.new("Graphics/Pictures/Contest/acting/bgAnimation", 2, 512, 400, 4, @viewport)
    @sprites["background"].x = 0
    @sprites["background"].y = 0
    @sprites["background"].z = 99997
    
    #textbox decoration
    @sprites["text_box_deco"] = IconSprite.new(0, 0, @viewport)
    @sprites["text_box_deco"].setBitmap("Graphics/Pictures/Contest/acting/decorative_left_of_textbox")
    @sprites["text_box_deco"].x = 0
    @sprites["text_box_deco"].y = Graphics.height - @sprites["text_box_deco"].height
    @sprites["text_box_deco"].z = 99998
    
    #textbox
    @sprites["message_box"] = IconSprite.new(0, 0, @moveViewport)
    @sprites["message_box"].setBitmap("Graphics/Pictures/Contest/acting/message_box")
    @sprites["message_box"].x = @sprites["text_box_deco"].width
    @sprites["message_box"].y = Graphics.height - @sprites["message_box"].height
    @sprites["message_box"].z = 999999
    
    #judge panel
    @sprites["judge_panel"] = IconSprite.new(0, 0, @viewport)
    @sprites["judge_panel"].setBitmap("Graphics/Pictures/Contest/acting/judge_panel")
    @sprites["judge_panel"].x = @sprites["text_box_deco"].width
    @sprites["judge_panel"].y = 0
    @sprites["judge_panel"].z = 99998
    
    #judges
    @sprites["temp"] = IconSprite.new(0, 0, @viewport)
    @sprites["temp"].visible = false
    
    #left judge
    #sprite_file = "Graphics/characters/#{ContestSettings::JUDGES[0][1]}"
    sprite_file = "Graphics/characters/#{ContestSettings::JUDGES[0][:Sprite]}"
    @sprites["temp"].setBitmap(sprite_file)
    characterWidth = @sprites["temp"].width
    characterHeight = @sprites["temp"].height
    
    @sprites["judge_left"] = AnimatedSprite.new(sprite_file, 4, characterWidth/4, characterHeight/4, 0, @viewport)
    @sprites["judge_left"].x = @sprites["judge_panel"].x + ContestSettings::OFFSET_JUDGE_LEFT_X
    @sprites["judge_left"].y = (@sprites["judge_panel"].y + @sprites["judge_panel"].height/2) - characterHeight/8 + ContestSettings::OFFSET_JUDGE_LEFT_Y
    @sprites["judge_left"].z = 99997
    
    #center judge
    #sprite_file = "Graphics/characters/#{ContestSettings::JUDGES[1][1]}"
    sprite_file = "Graphics/characters/#{ContestSettings::JUDGES[1][:Sprite]}"
    @sprites["temp"].setBitmap(sprite_file)
    characterWidth = @sprites["temp"].width
    characterHeight = @sprites["temp"].height
    
    @sprites["judge_center"] = AnimatedSprite.new(sprite_file, 4, characterWidth/4, characterHeight/4, 0, @viewport)
    @sprites["judge_center"].x = (@sprites["judge_panel"].x + @sprites["judge_panel"].width/2) - characterWidth/8 + ContestSettings::OFFSET_JUDGE_CENTER_X
    @sprites["judge_center"].y = (@sprites["judge_panel"].y + @sprites["judge_panel"].height/2) - characterHeight/8 + ContestSettings::OFFSET_JUDGE_CENTER_Y
    @sprites["judge_center"].z = 99997
    
    #right judge
    #sprite_file = "Graphics/characters/#{ContestSettings::JUDGES[2][1]}"
    sprite_file = "Graphics/characters/#{ContestSettings::JUDGES[2][:Sprite]}"
    @sprites["temp"].setBitmap(sprite_file)
    characterWidth = @sprites["temp"].width
    characterHeight = @sprites["temp"].height
    
    @sprites["judge_right"] = AnimatedSprite.new(sprite_file, 4, characterWidth/4, characterHeight/4, 0, @viewport)
    @sprites["judge_right"].x = @sprites["judge_panel"].x + @sprites["judge_panel"].width - characterWidth/4 - ContestSettings::OFFSET_JUDGE_LEFT_X
    @sprites["judge_right"].y = (@sprites["judge_panel"].y + @sprites["judge_panel"].height/2) - characterHeight/8 + ContestSettings::OFFSET_JUDGE_LEFT_Y
    @sprites["judge_right"].z = 99997
    
    @sprites["tile1"] = IconSprite.new(0, 0, @tilesViewport)
    @sprites["tile1"].setBitmap("Graphics/Pictures/Contest/acting/nonplayer_contestant_tile")
    @sprites["tile1"].x = 0
    @sprites["tile1"].y = 0
    @sprites["tile1"].z = 99998
    
    @sprites["tile2"] = IconSprite.new(0, 0, @tilesViewport)
    @sprites["tile2"].setBitmap("Graphics/Pictures/Contest/acting/nonplayer_contestant_tile")
    @sprites["tile2"].x = 0
    @sprites["tile2"].y = @sprites["tile1"].y + @sprites["tile1"].height
    @sprites["tile2"].z = 99998
    
    @sprites["tile3"] = IconSprite.new(0, 0, @tilesViewport)
    @sprites["tile3"].setBitmap("Graphics/Pictures/Contest/acting/nonplayer_contestant_tile")
    @sprites["tile3"].x = 0
    @sprites["tile3"].y = @sprites["tile2"].y + @sprites["tile2"].height
    @sprites["tile3"].z = 99998
    
    @sprites["tile4"] = IconSprite.new(0, 0, @tilesViewport)
    @sprites["tile4"].setBitmap("Graphics/Pictures/Contest/acting/nonplayer_contestant_tile")
    @sprites["tile4"].x = 0
    @sprites["tile4"].y = @sprites["tile3"].y + @sprites["tile3"].height
    @sprites["tile4"].z = 99998
    
    #nextIcons
    @sprites["NextIcon1"] = AnimatedSprite.new("Graphics/Pictures/Contest/acting/next_numbers", 4, 52, 20, 0, @tilesViewport)
    @sprites["NextIcon1"].x = @sprites["tile1"].width - 58
    @sprites["NextIcon1"].y = @sprites["tile1"].y + @sprites["tile1"].height - 2 - 20
    @sprites["NextIcon1"].z = 99999
    @sprites["NextIcon1"].visible = false
    
    @sprites["NextIcon2"] = AnimatedSprite.new("Graphics/Pictures/Contest/acting/next_numbers", 4, 52, 20, 0, @tilesViewport)
    @sprites["NextIcon2"].x = @sprites["tile2"].width - 58
    @sprites["NextIcon2"].y = @sprites["tile2"].y + @sprites["tile2"].height - 2 - 20
    @sprites["NextIcon2"].z = 99999
    @sprites["NextIcon2"].visible = false
    
    @sprites["NextIcon3"] = AnimatedSprite.new("Graphics/Pictures/Contest/acting/next_numbers", 4, 52, 20, 0, @tilesViewport)
    @sprites["NextIcon3"].x = @sprites["tile3"].width - 58
    @sprites["NextIcon3"].y = @sprites["tile3"].y + @sprites["tile2"].height - 2 - 20
    @sprites["NextIcon3"].z = 99999
    @sprites["NextIcon3"].visible = false
    
    @sprites["NextIcon4"] = AnimatedSprite.new("Graphics/Pictures/Contest/acting/next_numbers", 4, 52, 20, 0, @tilesViewport)
    @sprites["NextIcon4"].x = @sprites["tile4"].width - 58
    @sprites["NextIcon4"].y = @sprites["tile4"].y + @sprites["tile2"].height - 2 - 20
    @sprites["NextIcon4"].z = 99999
    @sprites["NextIcon4"].visible = false
    
    #invisible target for moves
    #by wrigty12
    @sprites["opponent"] = IconSprite.new(0, 0, @viewport)	
		@sprites["opponent"].setBitmap(sprintf("Graphics/Pictures/Contest/acting/animation_target"))
		@sprites["opponent"].ox = @sprites["opponent"].bitmap.width / 2
		@sprites["opponent"].oy = @sprites["opponent"].bitmap.height / 2
		@sprites["opponent"].x = @sprites["background"].width/4 #@sprites["opponent"].ox
		@sprites["opponent"].y = @sprites["judge_panel"].y + @sprites["judge_panel"].height #@sprites["opponent"].oy
    
    self.segregateMovesByContestType
    self.setAIMoves
    self.displayContestantInfo
    
  end #def self.setup
  
end #of class Acting