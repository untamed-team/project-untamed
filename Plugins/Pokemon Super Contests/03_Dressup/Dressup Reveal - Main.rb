class DressupReveal
  #=========================================================
  # Main, update, EndScene
  #=========================================================
  
  #main loop for the scene
  def self.pbMain(chosenContestants)
    
    @chosenContestants = chosenContestants
    
    self.setup
    #fade in
    pbFadeInAndShow(@sprites) { update }
    #fade out bgm from the map
    pbBGMFade(0.8)
    #play bgm for dressup
    pbBGMPlay("Contests_Judging",100,100)
    
    self.whiteFade
    
    #when white screen fades away, announcer starts talking
    pbWait(1 * Graphics.frame_rate/2)
    pbMessage(_INTL("All right, thanks for your patience! \\nLet's begin the Visual Competition!"))

    pbWait(1 * Graphics.frame_rate/2)
    pbMessage(_INTL("Dexter: Entry number 1! \\n#{@chosenContestants[0][:TrainerName]}!"))
    pbWait(1 * Graphics.frame_rate/2)
    pbMessage(_INTL("#{@chosenContestants[0][:TrainerName]} has entered the Contest with #{@chosenContestants[0][:PkmnName]}!"))
    pbWait(1 * Graphics.frame_rate)
    
    #set the stage with the graphic for whichever contestant#PkmnName you want
    #to appear behind the curtain
    self.setStage(@chosenContestants[0][:PkmnName])
    
    self.pullCurtain
    #play crowd cheering se
    pbSEPlay("Contests_Crowd",80,100)
    self.displayHearts(@chosenContestants[0])
    
    #NEXT CONTESTANT
    self.dropCurtain
    
    pbWait(1 * Graphics.frame_rate/2)
    pbMessage(_INTL("Dexter: Entry number 2! \\n#{@chosenContestants[1][:TrainerName]}!"))
    pbWait(1 * Graphics.frame_rate/2)
    pbMessage(_INTL("#{@chosenContestants[1][:TrainerName]} enters our Contest with #{@chosenContestants[1][:PkmnName]}!"))
    pbWait(1 * Graphics.frame_rate)
    
    #set the stage with the graphic for whichever contestant#PkmnName you want
    #to appear behind the curtain
    self.setStage(@chosenContestants[1][:PkmnName])
  
    self.pullCurtain
    #play crowd cheering se
    pbSEPlay("Contests_Crowd",80,100)
    self.displayHearts(@chosenContestants[1])
    
    #NEXT CONTESTANT
    self.dropCurtain
    
    pbWait(1 * Graphics.frame_rate/2)
    pbMessage(_INTL("Dexter: Entry number 3! \\n#{@chosenContestants[2][:TrainerName]}!"))
    pbWait(1 * Graphics.frame_rate/2)
    pbMessage(_INTL("#{@chosenContestants[2][:TrainerName]} is in the Contest with #{@chosenContestants[2][:PkmnName]}!"))
    pbWait(1 * Graphics.frame_rate)
    
    #set the stage with the graphic for whichever contestant#PkmnName you want
    #to appear behind the curtain
    self.setStage(@chosenContestants[2][:PkmnName])
    
    self.pullCurtain
    #play crowd cheering se
    pbSEPlay("Contests_Crowd",80,100)
    self.displayHearts(@chosenContestants[2])
    
    #PLAYER CONTESTANT
    self.dropCurtain
    
    pbWait(1 * Graphics.frame_rate/2)
    pbMessage(_INTL("Dexter: Entry number 4! \\n\\PN!"))
    pbWait(1 * Graphics.frame_rate/2)
    pbMessage(_INTL("\\PN's Contest hopes ride with {1}!",@playerPkmn.name))
    pbWait(1 * Graphics.frame_rate)
    
    #set the stage with the graphic for whichever contestant#PkmnName you want
    #to appear behind the curtain
    self.setStage(@playerPkmn)
    
    self.pullCurtain
    #play crowd cheering se
    pbSEPlay("Contests_Crowd",80,100)
    self.displayHearts(@chosenContestants[3])
    
    #End of Visual Competition
    pbWait(1 * Graphics.frame_rate/2)
    pbMessage(_INTL("The Dance Competition is next! \\nIs everyone up and ready for this?!"))
    
    pbWait(1 * Graphics.frame_rate)
    self.pbEndScene
    
    #move on to the dance competition
    Dance.pbMain(@chosenContestants)
  end #def pbMain
    
  def self.update
    pbUpdateSpriteHash(@sprites)
  end
  
  def self.pbEndScene
    # Hide all sprites with FadeOut effect.
    pbFadeOutAndHide(@sprites) { update }
    # Remove all sprites.
    pbDisposeSpriteHash(@sprites)
    # Remove the viewpoint.
    @viewport.dispose
  end
  
end #class DressupReveal