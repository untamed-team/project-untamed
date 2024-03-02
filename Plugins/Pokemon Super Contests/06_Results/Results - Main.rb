class Results
  #=========================================================
  # Main, update, EndScene
  #=========================================================
  
  #main loop for the scene
  def self.pbMain(chosenContestants)
    @chosenContestants = chosenContestants
    
    self.setupPreResults
    
    pbSEPlay("Contests_Crowd")
    pbWait(1 * Graphics.frame_rate/2)
    #camera flash
    pbFlash(Color.new(255,255,255), 2)
    pbSEPlay("Contests_Camera_Shutter",80,100)
    
    pbWait(1 * Graphics.frame_rate)
    mainJudge = ContestSettings::JUDGES[1][:Name]
    pbMessage(_INTL("#{mainJudge}: That's it, folks! \nAll judging has been completed!"))
    pbFlash(Color.new(255,255,255), 2)
    pbSEPlay("Contests_Camera_Shutter",80,100)
    pbWait(1 * Graphics.frame_rate/2)
    pbFlash(Color.new(255,255,255), 2)
    pbSEPlay("Contests_Camera_Shutter",80,100)
    
    pbMessage(_INTL("Which Pokémon will be crowned the winner?"))
    pbFlash(Color.new(255,255,255), 2)
    pbSEPlay("Contests_Camera_Shutter",80,100)
    pbWait(1 * Graphics.frame_rate/2)
    pbFlash(Color.new(255,255,255), 2)
    pbSEPlay("Contests_Camera_Shutter",80,100)
    
    pbMessage(_INTL("Let's announce the results!"))
    pbFlash(Color.new(255,255,255), 2)
    pbSEPlay("Contests_Camera_Shutter",80,100)
    pbWait(1 * Graphics.frame_rate/2)
    
    self.pbEndScene
    
    self.setupPointsScreen
    pbBGMPlay("Contests_Results")
    pbWaitUpdateGraphics(1 * Graphics.frame_rate)
    pbMessage(_INTL("And now, it's time to announce the results of the individual categories!")) {Results.update}
    
    @contestant_order = self.sortPoints
    self.setPointsProportion
    
    msgwindow = pbMessageNoClear(_INTL("First, the results of the Visual Competition!")) {Results.update}
    pbWaitUpdateGraphics(1 * Graphics.frame_rate)
    self.dressupPointsBar
    pbWaitUpdateGraphics(1 * Graphics.frame_rate)
    pbDisposeMessageWindow(msgwindow)

    msgwindow = pbMessageNoClear(_INTL("Next, let's have the results of the Dance Competition!")) {Results.update}
    pbWaitUpdateGraphics(1 * Graphics.frame_rate)
    self.dancePointsBar
    pbWaitUpdateGraphics(1 * Graphics.frame_rate)
    pbDisposeMessageWindow(msgwindow)

    msgwindow = pbMessageNoClear(_INTL("And finally, here are the results of the Acting Competition!")) {Results.update}
    pbWaitUpdateGraphics(1 * Graphics.frame_rate)
    self.actingPointsBar
    pbWaitUpdateGraphics(1 * Graphics.frame_rate)
    pbDisposeMessageWindow(msgwindow)
    
    self.placementNumbers
    self.getWinningEntryNumber
    
    pbMessage(_INTL("#{mainJudge}: The winner is... \nEntry number #{@winningEntryNumber}!")) {Results.update}
    msgwindow = pbMessageNoClear(_INTL("#{@chosenContestants[@winningEntryNumber-1][:TrainerName]} and #{@chosenContestants[@winningEntryNumber-1][:PkmnName]}! \nCongratulations!")) {Results.update}
    
    self.showWinner
    self.saveWinner
    
    pbWaitUpdateGraphics(2 * Graphics.frame_rate)
    pbDisposeMessageWindow(msgwindow)
    pbBGMFade(2.0)
    self.whiteFadeOut
    self.pbEndScene
    pbWaitUpdateGraphics(2 * Graphics.frame_rate)

    ContestStage.moveWinnerNextToJudge(@winningEntryNumber)
    pbBGMPlay("Contests_Contest Hall")
    self.whiteFadeIn
    pbDisposeSpriteHash(@fadeSprite)
    @whiteFadeViewport.dispose
    pbWaitUpdateGraphics(1 * Graphics.frame_rate)
    ContestStage.pbMainAfterResults(@chosenContestants[@winningEntryNumber-1], @winningEntryNumber)
  end #def self.pbMain(chosenContestants)
  
  def self.update
    pbUpdateSpriteHash(@sprites)
    pbUpdateSpriteHash(@fadeSprite)
  end
  
  def self.pbEndScene
    # Hide all sprites with FadeOut effect.
    pbFadeOutAndHide(@sprites) { update }
    # Remove all sprites.
    pbDisposeSpriteHash(@sprites)
    # Remove the viewpoint.
    @viewport.dispose
  end
  
end #class Results