class Dressup_Debug
  #=========================================================
  # Helper Functions
  #=========================================================
  def self.withinSelectionWindow?(object)
    return true if object.x.between?(@selectionWindowAreaX[0], @selectionWindowAreaX[1]-object.width/4) && object.y.between?(@selectionWindowAreaY[0], @selectionWindowAreaY[1]-object.height/4)
  end
  
  def self.withinBackdropWindow?(object)
    #I am not going to make the backdrop window as strict as the selection window
    #since keeping it less strict allows for some more creativity
    return true if object.x.between?(@backdropAreaX[0], @backdropAreaX[1]) && object.y.between?(@backdropAreaY[0], @backdropAreaY[1])
  end
  
  def self.returnAccessory
    pbSEPlay("Contests_Dressup_Timer",100,100)
    @object.x = @accessoryX if @accessoryX
    @object.y = @accessoryY if @accessoryY
    
    if self.withinSelectionWindow?(@object)
      #shrink the accessory if setting for that is true
      @object.zoom_x = 0.5 if ContestSettings::DRESS_UP_ITEMS_SMALL == true
      @object.zoom_y = 0.5 if ContestSettings::DRESS_UP_ITEMS_SMALL == true
    end
  end
  
  def self.returnPkmn
    pbSEPlay("Contests_Dressup_Timer",100,100)
    @object.x = @pkmnX if @pkmnX
    @object.y = @pkmnY if @pkmnY
  end
  
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
  end
  
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
    #if the filename already exists, change filename to have the next number at
    #the end
    filename = pbMessageFreeText(_INTL("Contestant file name?"), currenttext="", passwordbox=false, Pokemon::MAX_NAME_SIZE, width = 240)
    
    if filename == nil || filename == ""
      filename = "contestant"
    end
    
    i = 1
    loop do
      if !safeExists?("Graphics/Pictures/Contest/Dressup/contestants/#{@chosenRank}/#{filename}.png")
        break
      else
        #if the file already exists, change filename
        filename = filename + i.to_s
        i += 1
      end
    end
    bitmap.to_file("Graphics/Pictures/Contest/Dressup/contestants/#{@chosenRank}/#{filename}.png")
    pbMEStop(0.0)
    meName = "GUI save game"
    pbMessage(_INTL("\\me[{1}]File saved.", meName))
  end #def self.saveContestantBitmap
  
  #================================================
  #================ Updating Text =================
  #================================================
  def self.updateAccessoryLimitText
    #update the accessory limit text
    accessory_limit_text = sprintf("<ac>#{@attached_accessories}/#{@max_accessories}</ac>")
    #clear text on the bitmap
    @accessory_limit_window.clear
    drawFormattedTextEx(@accessory_limit_window, 0, 14, @sprites["backdrop"].width, accessory_limit_text, @textBaseColor, @textShadowColor)
  end

end #class Dressup_Debug