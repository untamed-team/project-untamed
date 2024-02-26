class Dressup_Debug
  #=========================================================
  # Main, update, EndScene
  #=========================================================
  
  #to call Dressup Debug:
  #Dressup_Debug.pbMain(:PIKACHU, "Normal")
  
  #main loop for the scene
  def self.pbMain(pkmn, rank)
    
    self.setup(rank)
    self.enterDressup(pkmn)
    self.updateSelectionWindowItems
    
    #to make all sprites fade in at once
    @tempSpriteHash = {}
    @tempSpriteHash.merge!(@sprites)
    @tempSpriteHash.merge!(@accessorySprites)
    @tempSpriteHash.merge!(@backdropSprites)
    
    #fade in
    pbFadeInAndShow(@tempSpriteHash) { update }
    
    #fade out bgm from the map
    pbBGMFade(0.8)
    
    pbSEPlay("Contests_Enter_Dressup",100,100)
    
    #play bgm for dressup
    pbBGMPlay("Contests_Dress Up",100,100)
    
    # Loop called once per frame.
    loop do
      Graphics.update
      Input.update
      self.update
      if Input.trigger?(Input::BACK)
        pbPlayCancelSE
        self.pbEndScene
        break
      end
      if Mouse.click?(@sprites["accessoryButton"])
        #update the current selection mode to accessory
        self.clickedAccessoryButton
      end
      if Mouse.click?(@sprites["backdropButton"])
        #update the current selection mode to backdrop
        self.clickedBackdropButton
      end
      if Mouse.click?(@sprites["upButton"])
        #update the current accessory/backdrop page
        self.clickedUpButton
      end
      if Mouse.click?(@sprites["downButton"])
        #update the current accessory/backdrop page
        self.clickedDownButton
      end
      
      if Mouse.click?(@sprites["doneButton"])        
        self.clickedDoneButton
      end
      
      if Mouse.click?(@sprites["rank"]) && @currentlyDragging != true
        self.changeRank
      end
      
      if Mouse.click?(@sprites["pokeball"])        
        self.changeContestant
      end
      
    end #loop do
  end #def self.pbMain(pkmn, rank)
    
  def self.update
    pbUpdateSpriteHash(@sprites)
    self.updateDraggableItems
    #detect button presses
  end
  
  def self.pbEndScene
    # Hide all sprites with FadeOut effect.
    pbFadeOutAndHide(@sprites) { update }
    # Remove all sprites.
    pbDisposeSpriteHash(@sprites)
    # Remove the viewpoint.
    @viewport.dispose
  end
  
end #class Dressup_Debug