class Dance
  #=========================================================
  # Main, update, EndScene
  #=========================================================
  
  #main loop for the scene
  def self.pbMain(chosenContestants)
    
    @chosenContestants = chosenContestants
    
    self.setup
    self.decidePossibleLeadMoves

    self.decideLeadDancerMoves(contestantNumber = 0)
    self.copyAIDanceMovesToBackups(contestantNumber = 0)
    self.setContestantXY
    self.setGradeXYZoom
    
    #fade in
    pbFadeInAndShow(@sprites) { update }
    
    pbWait(1 * Graphics.frame_rate)
    pbMessage(_INTL("The Dance Competition is ready to get underway!"))
    pbMessage(_INTL("Can the backup dancers flawlessly follow the main dancer's steps?!"))
    pbMessage(_INTL("OK! Everybody, let's dance! \\nStart the music!"))
    pbWait(1 * Graphics.frame_rate/2)
    
    pbBGMFade(1.0)
    
    @sprites["dark_tone"].dispose
    
    pbSEPlay("Contests_Start",50,100)
    pbWait(1 * Graphics.frame_rate/2)
    #your pokemon jumps a few times
    self.playerJump
    self.playerJump
    
    #play bgm based on chosen rank
    if @chosenRank == "Normal" || @chosenRank == "Great"
      pbBGMPlay("Contests_Dance_Easy",100,100)
    else
      pbBGMPlay("Contests_Dance_Difficult",100,100)
    end
    
    @sprites["instructions"].visible = true
    
    @sprites["jigglypuff"].play
    
    #save the framerate
    @framerate = Graphics.frame_rate
    #change the framerate temporarily
    Graphics.frame_rate = 32
    
    genericTimer = 0
    loop do
      #we need this loop to wait 2 seconds and still have the jigglypuff
      #bouncing
      Graphics.update
      self.update
      genericTimer += 1
      break if genericTimer >= (2 * Graphics.frame_rate) - 2
    end
    
    @sprites["instructions"].visible = false
    pbSEPlay("Contests_Start",50,100)
      
      
    genericTimer = 0
    # Loop called once per frame
    loop do
      Graphics.update
      Input.update
      self.update
      
      if @pauseDancing == false
        self.toneDancers
        self.bobJigglypuff
        self.advanceJigglypuff
        self.advanceBarLine
        self.advanceBar
        
        self.detectButtonInput if @inputCooldownTimer <= 0 && @pauseDancing != true && @button_held != true
        
        @inputCooldownTimer -= 1 if @inputCooldownTimer > 0
        
        if @timerY == (Graphics.frame_rate * 8) && @trackRunCount < 7
          self.resetTrack
        end #if @timerY == (Graphics.frame_rate * 8) && @trackRunCount < 7
      else
        #this part will run while dancing is paused
      end #if @pauseDancing == false
      
      if @timerY >= (Graphics.frame_rate * 8) + (2*Graphics.frame_rate) && @trackRunCount >= 7
        @pauseDancing = true
        pbBGMFade(0.1)
        self.normalToneLeadDancer
        genericTimer += 1
        break if genericTimer >= (2 * Graphics.frame_rate)
      end
    end #loop do
    #set the framerate back to normal
    Graphics.frame_rate = @framerate
    
    @chosenContestants[0][:TotalPoints] = @chosenContestants[0][:DressupPoints] + @chosenContestants[0][:ConditionPoints] + @chosenContestants[0][:DancePoints]
    @chosenContestants[1][:TotalPoints] = @chosenContestants[1][:DressupPoints] + @chosenContestants[1][:ConditionPoints] + @chosenContestants[1][:DancePoints]
    @chosenContestants[2][:TotalPoints] = @chosenContestants[2][:DressupPoints] + @chosenContestants[2][:ConditionPoints] + @chosenContestants[2][:DancePoints]
    @chosenContestants[3][:TotalPoints] = @chosenContestants[3][:DressupPoints] + @chosenContestants[3][:ConditionPoints] + @chosenContestants[3][:DancePoints]
    
    #this will need to be updated
    sortedContestants = @chosenContestants.sort_by { |hsh| hsh[:TotalPoints] }.reverse

    pbWait(1 * Graphics.frame_rate)
    pbBGMPlay("Contests_Judging",100,100)
    pbMessage(_INTL("That's it for the Dance Competition!"))
    pbMessage(_INTL("Leading points right now is #{sortedContestants[0][:TrainerName]}!"))
    pbMessage(_INTL("Can anyone turn things around in the Acting Competition?"))

    #move all @moveButtonSprites keys to @sprites so ALL sprites fade at once
    #when self.pbEndScene is called
    @sprites.merge!(@moveButtonSprites)
    
    self.pbEndScene
      
    #move on to the next competition
    Acting.pbMain(@chosenContestants)
      
  end #def pbMain
    
  def self.update
    self.placeMoveButtons
    self.moveAIPkmnSprites
    self.updateButtonAnimation
    self.updateMoveButtonAnimations
    self.updateDancerSpriteMoving
    self.updateJudgeAnimations
    pbUpdateSpriteHash(@sprites)
    pbUpdateSpriteHash(@moveButtonSprites)
    
    #we're not gonna show stars when contestants move until the lag is fixed...
    #IF it's fixed
    #self.updateStarAnimations
  end
  
  def self.pbEndScene
    # Hide all sprites with FadeOut effect.
    pbFadeOutAndHide(@sprites) { update }
    # Remove all sprites.
    pbDisposeSpriteHash(@sprites)
    # Remove the viewpoint.
    @viewport.dispose
  end
end #class Dance