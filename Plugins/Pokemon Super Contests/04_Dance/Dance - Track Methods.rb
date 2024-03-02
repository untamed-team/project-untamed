class Dance
  #=========================================================
  # Track Methods
  #=========================================================  
  def self.advanceBarLine
    @sprites["bar_line"].x += 2
  end
  
  def self.advanceJigglypuff
    @sprites["jigglypuff"].x += 2
    @timerX += 1
    if @timerX == (1*Graphics.frame_rate/2)
      @timerX = 0
    end
  end
  
  def self.bobJigglypuff
    @bobY = Math.sin(@timerY * @bobSpeed) * @bobDistance
    @absBobY = @bobY.abs
    @sprites["jigglypuff"].y = @jigglypuffStartY - @absBobY.truncate
    @timerY += 1
  end
  
  def self.advanceBar
    #start the bar animation after 2 frames
    if @timerY == 2
      @sprites["bar1"].visible = true if @sprites["bar1"].visible == false
      @sprites["bar1"].play if !@sprites["bar1"].playing?
    end
    @sprites["bar1"].stop if @sprites["bar1"].frame == 31 && @sprites["bar1"].playing?
    
    #play the second bar's animation
    if @timerY == 2 + (Graphics.frame_rate * 2)
      @sprites["bar2"].visible = true if @sprites["bar2"].visible == false
      @sprites["bar2"].play if !@sprites["bar2"].playing?
    end
    @sprites["bar2"].stop if @sprites["bar2"].frame == 31 && @sprites["bar2"].playing?
    
    #play the third bar's animation
    if @timerY == 4 + (Graphics.frame_rate * 4)
      @sprites["bar3"].visible = true if @sprites["bar3"].visible == false
      @sprites["bar3"].play if !@sprites["bar3"].playing?
    end
    @sprites["bar3"].stop if @sprites["bar3"].frame == 31 && @sprites["bar3"].playing?
    
    #play the fourth bar's animation
    if @timerY == 2 + (Graphics.frame_rate * 6)
      @sprites["bar4"].visible = true if @sprites["bar4"].visible == false
      @sprites["bar4"].play if !@sprites["bar4"].playing?
    end
    @sprites["bar4"].stop if @sprites["bar4"].frame == 31 && @sprites["bar4"].playing?
  end
  
  def self.resetTrack
    @trackRunCount += 1
    if @setOfMoves == 1
      @setOfMoves = 2
    else
      @setOfMoves = 1
    end
    
    @moveButtonCounter = 0 #to reset the number that goes into the move sprites'
    #naming convention
    self.disposeMoveButtons
    
    #refill everyone's dance moves amount
    @danceMovesLeft = @maxDanceMoves
    
    #reset Jigglypuff
    @sprites["jigglypuff"].x = @jigglypuffStartX
    @sprites["jigglypuff"].y = @jigglypuffStartY
    @timerY = 0
    @bobY = 0
    
    #reset bar line
    @sprites["bar_line"].x = 0 - @sprites["bar_line"].width
    
    #reset the bar animation
    @sprites["bar1"].visible = false
    @sprites["bar1"].frame = 0
    @sprites["bar2"].visible = false
    @sprites["bar2"].frame = 0
    @sprites["bar3"].visible = false
    @sprites["bar3"].frame = 0
    @sprites["bar4"].visible = false
    @sprites["bar4"].frame = 0
    
    #when it's time to switch dancers
    if @trackRunCount == 2 || @trackRunCount == 4 || @trackRunCount == 6
      @sprites["jigglypuff"].visible = false
      Graphics.update
      self.update
      self.nextDancer
      
      #clear all current moves and timings
      @chosenContestants[0][:DanceMoves][:ButtonPlacementTimings1] = []
      @chosenContestants[0][:DanceMoves][:ButtonPlacementTimings2] = []
      @chosenContestants[0][:DanceMoves][:DistortedTimings1] = []
      @chosenContestants[0][:DanceMoves][:DistortedTimings2] = []
      @chosenContestants[0][:DanceMoves][:ButtonTypes1] = []
      @chosenContestants[0][:DanceMoves][:ButtonTypes2] = []
      @chosenContestants[0][:DanceMoves][:DistortedTypes1] = []
      @chosenContestants[0][:DanceMoves][:DistortedTypes2] = []
      @chosenContestants[0][:DanceMoves][:PkmnSpriteMoveTiming1] = []
      @chosenContestants[0][:DanceMoves][:PkmnSpriteMoveTiming2] = []
      @chosenContestants[0][:DanceMoves][:PkmnSpriteMoveDirection1] = []
      @chosenContestants[0][:DanceMoves][:PkmnSpriteMoveDirection2] = []
    
      @chosenContestants[1][:DanceMoves][:ButtonPlacementTimings1] = []
      @chosenContestants[1][:DanceMoves][:ButtonPlacementTimings2] = []
      @chosenContestants[1][:DanceMoves][:DistortedTimings1] = []
      @chosenContestants[1][:DanceMoves][:DistortedTimings2] = []
      @chosenContestants[1][:DanceMoves][:ButtonTypes1] = []
      @chosenContestants[1][:DanceMoves][:ButtonTypes2] = []
      @chosenContestants[1][:DanceMoves][:DistortedTypes1] = []
      @chosenContestants[1][:DanceMoves][:DistortedTypes2] = []
      @chosenContestants[1][:DanceMoves][:PkmnSpriteMoveTiming1] = []
      @chosenContestants[1][:DanceMoves][:PkmnSpriteMoveTiming2] = []
      @chosenContestants[1][:DanceMoves][:PkmnSpriteMoveDirection1] = []
      @chosenContestants[1][:DanceMoves][:PkmnSpriteMoveDirection2] = []
    
      @chosenContestants[2][:DanceMoves][:ButtonPlacementTimings1] = []
      @chosenContestants[2][:DanceMoves][:ButtonPlacementTimings2] = []
      @chosenContestants[2][:DanceMoves][:DistortedTimings1] = []
      @chosenContestants[2][:DanceMoves][:DistortedTimings2] = []
      @chosenContestants[2][:DanceMoves][:ButtonTypes1] = []
      @chosenContestants[2][:DanceMoves][:ButtonTypes2] = []
      @chosenContestants[2][:DanceMoves][:DistortedTypes1] = []
      @chosenContestants[2][:DanceMoves][:DistortedTypes2] = []
      @chosenContestants[2][:DanceMoves][:PkmnSpriteMoveTiming1] = []
      @chosenContestants[2][:DanceMoves][:PkmnSpriteMoveTiming2] = []
      @chosenContestants[2][:DanceMoves][:PkmnSpriteMoveDirection1] = []
      @chosenContestants[2][:DanceMoves][:PkmnSpriteMoveDirection2] = []
    
      self.setContestantXY
      self.setGradeXYZoom
      self.setMoveYZ
          
      if @dancerTurn == 2 || @dancerTurn == 3
        self.decideLeadDancerMoves(contestantNumber = @dancerTurn-1)
        self.copyAIDanceMovesToBackups(contestantNumber = @dancerTurn-1)
      end #if @dancerTurn == 2 || @dancerTurn == 3
    end #if @trackRunCount == 2 || @trackRunCount == 4 || @trackRunCount == 6
  end #def self.resetTrack
  
  def self.setMoveYZ
    #set the height and z of the button sprites for each contestant including
    #the player
    case @dancerTurn
    when 1
      @chosenContestants[0][:DanceMoves][:MoveSpriteY] = @leadButtonHeight
      @chosenContestants[1][:DanceMoves][:MoveSpriteY] = @leadButtonHeight - 16
      @chosenContestants[2][:DanceMoves][:MoveSpriteY] = @leadButtonHeight
      @chosenContestants[3][:DanceMoves][:MoveSpriteY] = @leadButtonHeight + 16
      
      @chosenContestants[0][:DanceMoves][:MoveSpriteZ] = @leadButtonZ
      @chosenContestants[1][:DanceMoves][:MoveSpriteZ] = @backup1ButtonZ
      @chosenContestants[2][:DanceMoves][:MoveSpriteZ] = @backup2ButtonZ
      @chosenContestants[3][:DanceMoves][:MoveSpriteZ] = @backup3ButtonZ
    when 2
      @chosenContestants[0][:DanceMoves][:MoveSpriteY] = @leadButtonHeight + 16
      @chosenContestants[1][:DanceMoves][:MoveSpriteY] = @leadButtonHeight
      @chosenContestants[2][:DanceMoves][:MoveSpriteY] = @leadButtonHeight - 16
      @chosenContestants[3][:DanceMoves][:MoveSpriteY] = @leadButtonHeight
      
      @chosenContestants[0][:DanceMoves][:MoveSpriteZ] = @backup3ButtonZ
      @chosenContestants[1][:DanceMoves][:MoveSpriteZ] = @leadButtonZ
      @chosenContestants[2][:DanceMoves][:MoveSpriteZ] = @backup1ButtonZ
      @chosenContestants[3][:DanceMoves][:MoveSpriteZ] = @backup2ButtonZ
    when 3
      @chosenContestants[0][:DanceMoves][:MoveSpriteY] = @leadButtonHeight
      @chosenContestants[1][:DanceMoves][:MoveSpriteY] = @leadButtonHeight +16
      @chosenContestants[2][:DanceMoves][:MoveSpriteY] = @leadButtonHeight
      @chosenContestants[3][:DanceMoves][:MoveSpriteY] = @leadButtonHeight - 16
      
      @chosenContestants[0][:DanceMoves][:MoveSpriteZ] = @backup2ButtonZ
      @chosenContestants[1][:DanceMoves][:MoveSpriteZ] = @backup3ButtonZ
      @chosenContestants[2][:DanceMoves][:MoveSpriteZ] = @leadButtonZ
      @chosenContestants[3][:DanceMoves][:MoveSpriteZ] = @backup1ButtonZ
    when 4
      @chosenContestants[0][:DanceMoves][:MoveSpriteY] = @leadButtonHeight - 16
      @chosenContestants[1][:DanceMoves][:MoveSpriteY] = @leadButtonHeight
      @chosenContestants[2][:DanceMoves][:MoveSpriteY] = @leadButtonHeight + 16
      @chosenContestants[3][:DanceMoves][:MoveSpriteY] = @leadButtonHeight
      
      @chosenContestants[0][:DanceMoves][:MoveSpriteZ] = @backup1ButtonZ
      @chosenContestants[1][:DanceMoves][:MoveSpriteZ] = @backup2ButtonZ
      @chosenContestants[2][:DanceMoves][:MoveSpriteZ] = @backup3ButtonZ
      @chosenContestants[3][:DanceMoves][:MoveSpriteZ] = @leadButtonZ
    end #case @dancerTurn
  end #def self.setMoveYX
  
  def self.nextDancer
    @pauseDancing = true
    
    tempTimer = 0
    
    loop do
      Graphics.update
      self.update
      
      #we need to give the above methods time to finish before we do the below
      #about 1 second should do
      break if tempTimer >= ((Graphics.frame_rate * 1)/2)
      tempTimer += 1
    end
    
    @dancerTurn += 1
    
    #find out role of contestants on this current turn
    case @dancerTurn
    when 2
      @leadDancerSprite = @sprites["contestant2"]
      @backupDancer1Sprite = @sprites["contestant3"]
      @backupDancer2Sprite = @sprites["contestant4"]
      @backupDancer3Sprite = @sprites["contestant1"]
    when 3
      @leadDancerSprite = @sprites["contestant3"]
      @backupDancer1Sprite = @sprites["contestant4"]
      @backupDancer2Sprite = @sprites["contestant1"]
      @backupDancer3Sprite = @sprites["contestant2"]
    when 4
      @leadDancerSprite = @sprites["contestant4"]
      @backupDancer1Sprite = @sprites["contestant1"]
      @backupDancer2Sprite = @sprites["contestant2"]
      @backupDancer3Sprite = @sprites["contestant3"]
    end
    
    pbSEPlay("Contests_Dance_Next_Contestant",100,100)
    @sprites["instructions"].text = _INTL("<c2=65467b14>Perform 3 steps as the main dancer!</c2>") if @dancerTurn >= 4
    @sprites["instructions"].visible = true
    
    loop do
      Graphics.update
      self.update
      
      self.darkToneBackupDancers
      
      #move the now lead dancer left until off screen
      @leadDancerSprite.x -= 16 if @leadDancerSprite.x > 0 - @leadDancerSprite.width && @leadDancerSprite.y != @leadDancerY
    
      #move the now backup dancer 3 right until off screen
      @backupDancer3Sprite.x += 16 if @backupDancer3Sprite.x < Graphics.width && @backupDancer3Sprite.y != @backupDancer3Y
    
      #move backup dancers to the left
      if @backupDancer1Sprite.x != @backupDancer1X
        if @backupDancer1Sprite.x >= 16 + @backupDancer1X
          @backupDancer1Sprite.x -= 16 
        elsif @backupDancer1Sprite.x < 16 + @backupDancer1X
          @backupDancer1Sprite.x -= 2
        elsif @backupDancer1Sprite.x < 2 + @backupDancer1X
          @backupDancer1Sprite.x -= 1
        end
      end
      
      if @backupDancer2Sprite.x != @backupDancer2X
        if @backupDancer2Sprite.x >= 16 + @backupDancer2X
          @backupDancer2Sprite.x -= 16 
        elsif @backupDancer2Sprite.x < 16 + @backupDancer2X
          @backupDancer2Sprite.x -= 2
        elsif @backupDancer2Sprite.x < 2 + @backupDancer2X
          @backupDancer2Sprite.x -= 1
        end
      end
      
      if @backupDancer3Sprite.x >= Graphics.width
        #once the sprite is off screen, change its zoom to be 0.8
        @backupDancer3Sprite.zoom_x = 0.8
        @backupDancer3Sprite.zoom_y = 0.8
        @backupDancer3Sprite.y = @backupDancer3Y
        @backupDancer3Sprite.z = 99998
      end
      
      #once we have the new backup dancer 3 off screen and set its y to be
      #correct, begin sliding it on screen
      if @backupDancer3Sprite.y == @backupDancer3Y && @backupDancer3Sprite.x != @backupDancer3X
        if @backupDancer3Sprite.x >= @backupDancer3X + 16
          @backupDancer3Sprite.x -= 16 
        elsif @backupDancer3Sprite.x < @backupDancer3X + 16
          @backupDancer3Sprite.x -= 2
        elsif @backupDancer3Sprite.x < @backupDancer3X + 2
          @backupDancer3Sprite.x -= 1
        end
      end
      
      if @leadDancerSprite.x <= 0 - @leadDancerSprite.width
        #once the sprite is off screen, change its zoom to be 1.0
        @leadDancerSprite.zoom_x = 1.0
        @leadDancerSprite.zoom_y = 1.0
        @leadDancerSprite.y = @leadDancerY
        @leadDancerSprite.z = 99999
      end
      
      #once we have the new lead dancer off screen and set its y to be correct,
      #begin sliding it on screen
      if @leadDancerSprite.y == @leadDancerY && @leadDancerSprite.x != @leadDancerX
        if @leadDancerSprite.x <= @leadDancerX + 16 
          @leadDancerSprite.x += 16 
        elsif @leadDancerSprite.x > @leadDancerX - 16
          @leadDancerSprite.x += 2
        elsif @leadDancerSprite.x > @leadDancerX - 2
          @leadDancerSprite.x += 1
        end
      end
      
      @leadDancerSprite.x = @leadDancerX if @leadDancerSprite.x > @leadDancerX
      @backupDancer1Sprite.x = @backupDancer1X if @backupDancer1Sprite.x < @backupDancer1X
      @backupDancer2Sprite.x = @backupDancer2X if @backupDancer2Sprite.x < @backupDancer2X
      @backupDancer3Sprite.x = @backupDancer3X if @backupDancer3Sprite.x < @backupDancer3X
      
      break if @leadDancerSprite.x == @leadDancerX && @backupDancer1Sprite.x == @backupDancer1X && @backupDancer2Sprite.x == @backupDancer2X && @backupDancer3Sprite.x == @backupDancer3X
    end #loop do
    
    #once done with the shift to next dancer, make jigglypuff visible again
    @sprites["jigglypuff"].visible = true
    
    if @dancerTurn == 1 || @dancerTurn == 2
      pbWait(2*Graphics.frame_rate) { update }
    else
      pbWait(2*Graphics.frame_rate) { update }
    end
    
    @sprites["instructions"].visible = false
    @pauseDancing = false
  end
end #class Dance