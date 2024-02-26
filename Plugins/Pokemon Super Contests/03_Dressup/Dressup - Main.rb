class Dressup
  #=========================================================
  # Main, update, EndScene
  #=========================================================
  #main loop for the scene
  def self.pbMain(chosenContestants)
    
    @chosenContestants = chosenContestants
    
    @theme = nil
    self.chooseTheme
    self.setup
	
	pbMessage(_INTL("Let's have the contestants move backstage!"))
	
	self.enterDressup
	
    self.updateSelectionWindowItems
    
    #to make all sprites fade in at once
    @tempSpriteHash = {}
    @tempSpriteHash.merge!(@sprites)
    @tempSpriteHash.merge!(@accessorySprites)
    @tempSpriteHash.merge!(@backdropSprites)
    
    #fade in
    pbFadeInAndShow(@tempSpriteHash) { update }
	
	pbMessage(_INTL("You have 60 seconds to dress up your Pokemon with accessories."))
    pbMessage(_INTL("Match the theme and earn higher scores!"))
    pbMessage(_INTL("OK, our theme this time is... \\n\"#{@theme}\"!"))
    pbMessage(_INTL("The time limit is 60 seconds! You are allowed #{@max_accessories} accessories!"))
    pbMessage(_INTL("Your fashion sense is on trial! Begin dressing up now!"))
    
    #fade out bgm from the map
    pbBGMFade(0.8)
    
    pbSEPlay("Contests_Enter_Dressup",100,100)
    
    #play bgm for dressup
    pbBGMPlay("Contests_Dress Up",100,100)
    
    #initialize timer variable "time"
    time = 0
    
    # Loop called once per frame.
    loop do
      Graphics.update
      Input.update
      self.update
      
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
        break
      end
      
      #subtract from the timer
      time += 1
      #update the timer text
      if time >= 1*Graphics.frame_rate && @timer > 0
        @timer -= 1
        timer_text = sprintf("<ac>#{@timer}</ac>")
        #clear text on the bitmap
        @timer_window.clear
        drawFormattedTextEx(@timer_window, 0, 14, 64, timer_text, @textBaseColor, @textShadowColor)
        time = 0
        
        if @timer <= 5 && @timer > 0
          pbSEPlay("Contests_Dressup_Timer",100,100)
        end
        
        if @timer == 0
          self.saveContestantBitmap
          break
        end
      end #if time >= 1*Graphics.frame_rate
    end #loop do
      
    self.endDressup
  end #def pbMain
    
  def self.update
    pbUpdateSpriteHash(@sprites)
    pbUpdateSpriteHash(@accessorySprites)
    self.updateDraggableItems
  end
  
  def self.pbEndScene
    # Hide all sprites with FadeOut effect.
    #pbFadeOutAndHide(@accessorySprites) { update }
    pbFadeOutAndHide(@sprites) { update }
    # Remove all sprites.
    pbDisposeSpriteHash(@sprites)
    pbDisposeSpriteHash(@accessorySprites)
    pbDisposeSpriteHash(@backdropSprites)
    # Remove the viewpoint.
    @viewport.dispose
  end
  
end #class Dressup