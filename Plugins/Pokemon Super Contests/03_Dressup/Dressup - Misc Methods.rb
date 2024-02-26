class Dressup
  
  def self.endDressup
    #end the time and play the chime
    @timer = 0
    timer_text = sprintf("<ac>#{@timer}</ac>")
    #clear text on the bitmap
    @timer_window.clear
    drawFormattedTextEx(@timer_window, 0, 14, 64, timer_text, @textBaseColor, @textShadowColor)
    pbBGMFade(0.8)
    pbSEPlay("Contests_Dressup_Time_up",100,100)
    
    pbWait(2*Graphics.frame_rate)
    
    #move all @accessorySprites keys to @sprites so ALL sprites fade at once
    #when self.pbEndScene is called
    @sprites.merge!(@accessorySprites)
    #do the same for backdrop sprites
    @sprites.merge!(@backdropSprites)
    
    self.tallyPoints
    self.pbEndScene
    
    DressupReveal.pbMain(@chosenContestants)
  end
  
  def self.saveContestantBitmap
    bitmap = Bitmap.new(@sprites["backdrop"].width, @sprites["backdrop"].height)
    
    #move the pokemon to the bitmap that will be saved to a file
    spriteX = @sprites["pkmn"].x - @sprites["backdrop"].x - (@sprites["pkmn"].width/2)
    spriteY = @sprites["pkmn"].y - @sprites["backdrop"].y - (@sprites["pkmn"].height/2)
    bitmap.blt(spriteX, spriteY, @sprites["pkmn"].bitmap, Rect.new(0, 0, @sprites["backdrop"].width, @sprites["backdrop"].height))
    
    #for all accessories attached, move them to the bitmap that will be saved to
    #a file
    #for all accessory sprites in the backdrop windowx get its X and Y and put
    #it on the bitmap the pkmn will be one
    @accessorySprites.each do |sprite|
      if !sprite[1].disposed? && self.withinBackdropWindow?(sprite[1])
        spriteX = sprite[1].x - @sprites["backdrop"].x
        spriteY = sprite[1].y - @sprites["backdrop"].y
        bitmap.blt(spriteX, spriteY, sprite[1].bitmap, Rect.new(0, 0, @sprites["backdrop"].width, @sprites["backdrop"].height))
      end #if !sprite[1].disposed? && self.withinBackdropWindow?(sprite[1])
    end #@accessorySprites.each do |i|

    #export the bitmap to a file
    #if the filename already exists, overwrite it
    bitmap.to_file("Graphics/Pictures/Contest/Dressup/contestants/playerPkmn.png")
  end #def self.saveContestantBitmap
  
  def self.tallyPoints    
    #=========================================================
    # Player Condition Points
    #=========================================================
    case @chosenType
      when "Coolness"
        primary_condition = @playerPkmn.cool
        secondary_condition1 = @playerPkmn.beauty
        secondary_condition2 = @playerPkmn.tough
      when "Beauty"
        primary_condition = @playerPkmn.beauty
        secondary_condition1 = @playerPkmn.cool
        secondary_condition2 = @playerPkmn.cute
      when "Cuteness"
        primary_condition = @playerPkmn.cute
        secondary_condition1 = @playerPkmn.smart
        secondary_condition2 = @playerPkmn.beauty
      when "Smartness"
        primary_condition = @playerPkmn.smart
        secondary_condition1 = @playerPkmn.tough
        secondary_condition2 = @playerPkmn.cute
      when "Toughness"
        primary_condition = @playerPkmn.tough
        secondary_condition1 = @playerPkmn.cool
        secondary_condition2 = @playerPkmn.smart
      end
      
      @chosenContestants[3][:ConditionPoints] = primary_condition + (secondary_condition1 / 2).floor + (secondary_condition2 / 2).floor + (@playerPkmn.sheen / 2).floor
    
    #=========================================================
    # Player Dressup Points
    #=========================================================
    #go through all accessorySprites and if it's attached, count its worth
    #@chosenContestants[3][:DressupPoints]
    for i in 0...@available_accessories.length
      @available_accessories[i].each do |hash|
        accessory = hash
        accessoryWorth = accessory[1][:"#{@theme}"]
        attached = accessory[1][:Attached]
        @chosenContestants[3][:DressupPoints] += attached*accessoryWorth
      end #@available_accessories[i].each do |hash|
    end #for i in @available_accessories.length    
  end #def self.tallyPoints
  
  def self.getGraphicName(value)
    #get the graphic name of the dragged accessory
    #make graphicName = accessoryName with out the ending _#
    separatorPosition = nil
    for s in 0...value.length
      if value[s] == "_"
        #found the separator
        separatorPosition = s
      end
    end
    
    if separatorPosition == nil
      #if no separator, the graphic name is the same as the accessoryName
      graphicName = value
    else
      #if there is a separator, set graphic name based on that
      graphicName = value[0,separatorPosition]
    end
    return graphicName
  end #def self.getGraphicName(value)
  
  def self.getAccessoryHash(accessory)
    #get the hash to which the accessory belongs
    #get the name of the sprite and search the available accessories array to
    #find its hash

    graphicName = self.getGraphicName(accessory)
    
    for i in 0...@available_accessories.length
      @available_accessories[i].each do |hash|
        if hash[0].to_s == graphicName
          #print "hash is #{hash}"
          return hash
        end #if hash[0].to_s == graphicName
      end #@available_accessories[i].each do |key, value|
    end #for i in 0...@available_accessories.length

  end #def self.getAccessoryHash(accessory)
  
  def self.withinSelectionWindow?(object)
    return true if object.x.between?(@selectionWindowAreaX[0], @selectionWindowAreaX[1]-object.width/4) && object.y.between?(@selectionWindowAreaY[0], @selectionWindowAreaY[1]-object.height/4)
  end
  
  def self.withinBackdropWindow?(object)
    #I am not going to make the backdrop window as strict as the selection window
    #since keeping it less strict allows for some more creativity
    return true if object.x.between?(@backdropAreaX[0], @backdropAreaX[1]) && object.y.between?(@backdropAreaY[0], @backdropAreaY[1])
  end
  
end #class Dressup