class Acting
  #=========================================================
  # Main, update, EndScene
  #=========================================================
  
  #main loop for the scene
  def self.pbMain(chosenContestants)
    
    @chosenContestants = chosenContestants
    self.setup
    
    self.audienceCheer(loop=true)
    
    pbMessageContest(_INTL("OK! It's time for the Acting Competition!"))
    pbMessageContest(_INTL("Show off the moves that exemplify #{@chosenType.downcase}!"))
    pbWait(1 * Graphics.frame_rate/2)
    pbMessageContest(_INTL("Four performances each! Let's see some enthusiasm!"))
    
    #=====================
    # Perform!
    #=====================
    4.times do
      @performanceNumber += 1
      self.askPlayerMove
      self.chooseAIMoves
      self.chooseAIJudges
      self.performMove(@contestant_order[0])
      self.performMove(@contestant_order[1])
      self.performMove(@contestant_order[2])
      self.performMove(@contestant_order[3])
      
      self.giveBonusPoints
      self.afterBonusEffects
      pbWait(1 * Graphics.frame_rate) #temporary
      
      self.tallyPoints
      self.attentionAttracted
      
      if @performanceNumber < 4
        pbMessageContest(_INTL("In the next turn, the lowest-scoring contestants will perform first."))
        #sort and update the bitmaps and text of the tiles
        self.updateTiles
        @contestantTurn = 0
      end
      
      self.resetCurrentRoundHearts
      self.resetLastJudgePerformedTo
      self.resetTimesPerformedTo
      self.resetVoltagePrevention
      self.resetConsecutiveVoltage
      self.resetJudgeVoltagePeak
    end #4.times do
    
    pbSEPlay("Pkmn exp full")
    pbMessageContest(_INTL("That's it! Performance judging is now over!"))

    self.audienceCheer(loop=true)
    #fade out and go to results
    
    self.pbEndScene
    #move on to the next competition
    Results.pbMain(@chosenContestants)
    
  end #def pbMain
  
  def self.pbEndScene
    # Hide all sprites with FadeOut effect.
    pbFadeOutAndHide(@heartSprites) { self.updateSprites }
    pbFadeOutAndHide(@sprites) { pbUpdateSpriteHash(@sprites) }
    # Remove all sprites.
    pbDisposeSpriteHash(@heartSprites)
    pbDisposeSpriteHash(@sprites)
    # Remove the viewpoint.
    @viewport.dispose
    @tilesViewport.dispose
    @moveAnimViewport.dispose
  end
end #class Acting