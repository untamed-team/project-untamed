class Dressup_Debug
  #=========================================================
  # Display Accessory/Backdrop Sprites
  #=========================================================
  def self.updateSelectionWindowItems
    #delete all accessory sprites in the selection window
    @accessorySprites.each do |sprite|
      #if the sprite is within the selection window, dispose of it
      if !sprite[1].disposed? && self.withinSelectionWindow?(sprite[1])
        sprite[1].dispose
      end #if !sprite[1].disposed? && self.withinSelectionWindow?(sprite[1])
    end #@accessorySprites.each do |i|
    
    #delete all backdrop cards in the selection window
    @backdropSprites.each do |sprite|
      #if the sprite is within the selection window, dispose of it
      if !sprite[1].disposed? && self.withinSelectionWindow?(sprite[1])
        sprite[1].dispose
      end #if !sprite[1].disposed? && self.withinSelectionWindow?(sprite[1])
    end #@backdropSprites.each do |i|
    
    #now that we have deleted all accessories and/or backdrop cards in the
    #selection window, display the sprites that should be displayed
    if @selection_window_mode == "accessory"
      self.displayAccessoriesForPage
    else #if the selection mode is backdrop
      self.displayBackdropsForPage
    end #if @selection_window_mode == "accessory"
  end #def self.updateSelectionWindowItems
  
  def self.displayAccessoriesForPage
    @available_accessories[@accessoryPage].each do |hash|
      accessory = hash
      accessoryName = accessory[0]
      quanitity = accessory[1][:Quantity]
      attached = accessory[1][:Attached]
      #display the accessory a number of times
      #the number of times is accessory[:Quantity] - accessory[:Attached]
      displayNum = quanitity - attached
      i = 0
      displayNum.times do
        i += 1
        #create the sprite for the accessory
        if !@accessorySprites["#{accessoryName}_#{i}"] || (@accessorySprites["#{accessoryName}_#{i}"] && @accessorySprites["#{accessoryName}_#{i}"].disposed?)
          @accessorySprites["#{accessoryName}_#{i}"] = Sprite.new(@viewport)
          @accessorySprites["#{accessoryName}_#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Contest/dressup/accessories/#{accessoryName}")
          @accessorySprites["#{accessoryName}_#{i}"].x = rand(@selectionWindowAreaX[0]..@selectionWindowAreaX[1]-@accessorySprites["#{accessoryName}_#{i}"].width)
          @accessorySprites["#{accessoryName}_#{i}"].y = rand(@selectionWindowAreaY[0]..@selectionWindowAreaY[1]-@accessorySprites["#{accessoryName}_#{i}"].height)
          @accessorySprites["#{accessoryName}_#{i}"].z = 99998
          @accessorySprites["#{accessoryName}_#{i}"].zoom_x = 0.5 if ContestSettings::DRESS_UP_ITEMS_SMALL == true
          @accessorySprites["#{accessoryName}_#{i}"].zoom_y = 0.5 if ContestSettings::DRESS_UP_ITEMS_SMALL == true
          
        end #if !@sprites["#{accessoryName}"]
      end #displayNum.times do
    end #@available_accessories[i].each do |hash|
  end #def self.displayAccessoriesForPage
  
  def self.displayBackdropsForPage
    row = 0
    column = 0
    background = 0
    #display backdrops
    #for every background available to us
    
    for i in 0...@available_backdrops.length
      #if the background position in the array is between 9*page number (0)
      #and 9*next page number (1)
      #so if position in array is between 1 and 9 (0 to 8), display it
      if i >= 9*@backdropPage && i < 9*(@backdropPage+1)
        #display the backdrop
        backdropName = @available_backdrops[i]
          
        if !@backdropSprites["#{backdropName}"] || @backdropSprites["#{backdropName}"].disposed?
          @backdropSprites["#{backdropName}"] = Sprite.new(@viewport)
          @backdropSprites["#{backdropName}"].bitmap = Bitmap.new("Graphics/Pictures/Contest/dressup/backdrops/card_#{backdropName}")
          @backdropSprites["#{backdropName}"].z = 99998
            
          #control the x of the sprite
          #@backdropSprites["#{backdropName}"].x = 0
          case column
          when 0
            @backdropSprites["#{backdropName}"].x = @selectionWindowAreaX[0] + 17
          when 1
            @backdropSprites["#{backdropName}"].x = @selectionWindowAreaX[0] + 34 + @backdropSprites["#{backdropName}"].width
          when 2
            @backdropSprites["#{backdropName}"].x = @selectionWindowAreaX[0] + 52 + @backdropSprites["#{backdropName}"].width*2
          end
            
          #control the y of the sprite
          #@backdropSprites["#{backdropName}"].y = 0
          case row
          when 0
            @backdropSprites["#{backdropName}"].y = @selectionWindowAreaY[0] + 10
          when 1
            @backdropSprites["#{backdropName}"].y = @selectionWindowAreaY[0] + 20 + @backdropSprites["#{backdropName}"].height
          when 2
            @backdropSprites["#{backdropName}"].y = @selectionWindowAreaY[0] + 30 + @backdropSprites["#{backdropName}"].height*2
          end

          if column < 2
            column += 1
          else
            column = 0
            row += 1
          end

          if row >= 3
            row = 0
          end
        end #if !@backdropSprites["#{backdropName}"]
      end #if i >= 9*@backdropPage && i < 9*(@backdropPage+1)
    end #for i in 0...@available_backdrops.length
  end #def self.displayBackdropsForPage
  
  #=========================================================
  # Click and Drag Functionality
  #=========================================================
  def self.getClickedObject
    #for detecting if a backdrop was clicked
    if @selection_window_mode == "backdrop"
      @backdropSprites.each do |sprite|
        #if the sprite exists and is not disposed
        backdropName = sprite[0]
        #if left-clicked a backdrop
        if !sprite[1].disposed? && Mouse.click?(@backdropSprites["#{backdropName}"])
          #change the backdrop
          @sprites["backdrop"].bitmap = Bitmap.new("Graphics/Pictures/Contest/dressup/backdrops/#{backdropName}")
          pbSEPlay("Contests_Dressup_Apply_Backdrop",100,100)
        end #if !sprite[1].disposed? && Mouse.press?(@sprites["#{accessoryName}"])
      end #@backdropSprites.each do |i|
    end #if @selection_window_mode == "backdrop"
    
    #if not dragging an object, we don't need to see what object is being clicked
    #because we already know
    if @currentlyDragging != true
      #list all clickable objects that can be on the screen here and set @object
      #to whatever was clicked
      @accessorySprites.each do |sprite|
        #if the sprite exists and is not disposed
        accessoryName = sprite[0]
        #if left-clicked an accessory
        if !sprite[1].disposed? && Mouse.press?(@accessorySprites["#{accessoryName}"])
          @draggedAccessory = accessoryName
          @object = sprite[1]
        end #if !sprite[1].disposed? && Mouse.press?(@sprites["#{accessoryName}"])
      end #@accessorySprites.each do |i|
        
      #if right-clicked the pokemon
      if @sprites["pkmn"] && !@sprites["pkmn"].disposed?
        #drag the pokemon
        if Mouse.press?(@sprites["pkmn"], :right)
          @draggedAccessory = "pkmn" 
          @object = @sprites["pkmn"]
        end #if Mouse.press?(@sprites["pkmn"], :right)
      end #if @sprites["pkmn"] && !@sprites["pkmn"].disposed?
    end #if @currentlyDragging != true
  end #def self.getClickedObject
  
  def self.updateDraggableItems
    #get clicked object if not already dragging an object
    self.getClickedObject
    
    if @object != nil && !@object.disposed?
      if @currentlyDragging == true
        #set the currently dragging object to a z above other sprites
        @object.z = 99999
        #make the object normal size if dragging it around
        @object.zoom_x = 1.0
        @object.zoom_y = 1.0
      end #if @currentlyDragging == true
      
      #move sprites with the mouse
      if @draggedAccessory == "pkmn"
        Mouse.drag_object(@object, :right) if !@object.disposed?
      else
        Mouse.drag_object(@object, :left) if !@object.disposed?
      end
    
      #if not dragging an accessory, save the accessory's X and Y when clicking it
      if Mouse.press?(@object, :left)
        @accessoryX = @object.x if @currentlyDragging != true
        @accessoryY = @object.y if @currentlyDragging != true
        
        #play the pickup sound when clicking or dragging an accessory with left
        #click
        if @currentlyDragging != true && @draggedAccessory != "pkmn"
          pbSEPlay("Contests_Dressup_Pick_up",100,100)
        end #@currentlyDragging != true
        
        @currentlyDragging = true
      end #if Mouse.press?(@object, :left)
    
      #drag the pokemon
      if Mouse.press?(@object, :right)
        if @currentlyDragging != true
          @pkmnX = @object.x
          @pkmnY = @object.y
        end #if @currentlyDragging != true
        
        #play the pickup sound when clicking or dragging an accessory with left
        #click
        if @currentlyDragging != true && @draggedAccessory == "pkmn"
          pbSEPlay("Contests_Dressup_Pick_up",100,100)
        end #@currentlyDragging != true
        
        @currentlyDragging = true
      end #if Mouse.press?(@object, :right)
      
      self.attachDetach
      
    end #if @object
  end #def self.updateDraggableItems
  
  #=========================================================
  # Attaching and Detaching Accessories
  #=========================================================
  def self.attachDetach
    #this method attached and detaches accessories from the pokemon
    #if you let go of the object, check to see if it is in the accessory window
    #or in the pokemon window. If neither, reset the sprite's x when letting go
    #================================
    #====== Release Left-Click ======
    #================================
    if Input.release?(Input::MOUSELEFT) && @currentlyDragging == true && @draggedAccessory != "pkmn"
      #when letting go of the accessory, put its z back to normal like the other
      #accessories
      @object.z = 99998
      
      accessoryHash = self.getAccessoryHash(@draggedAccessory)
      pageNumber = accessoryHash[1][:PageNumber]
      
      #================================
      #= Dropped in Accessory Window =
      #================================
      #if the accessory was dropped into the selection window
      if self.withinSelectionWindow?(@object)
        #================================
        #======= Detach Accessory =======
        #================================
        #if the object was not already in the selection window, detach
        if !@accessoryX.between?(@selectionWindowAreaX[0], @selectionWindowAreaX[1])
          
            
          #if the accessory was dropped onto a page it does not belong to,
          #delete the sprite
          if @accessoryPage != pageNumber
            #delete the sprite from the screen
            @object.dispose
          else
            #the accessory was put back on the page it came from
            #shrink the accessory if setting for that is true
            @object.zoom_x = 0.5 if ContestSettings::DRESS_UP_ITEMS_SMALL == true
            @object.zoom_y = 0.5 if ContestSettings::DRESS_UP_ITEMS_SMALL == true
          end #if @accessoryPage != pageNumber
          
          #detach from pkmn and play the put down sound
          accessoryHash[1][:Attached] -= 1
          pbSEPlay("Contests_Dressup_Put_down",100,100)
            
          #subtract 1 from attached accessories
          @attached_accessories -= 1
          self.updateAccessoryLimitText
          
          #================================
          #===== Reset Dragged Object =====
          #================================
          @object = nil
          @currentlyDragging = false
          return
          
        else
          #if the accessory was put down in the same window it was already in
          #play the put down sound
          pbSEPlay("Contests_Dressup_Put_down",100,100)
          
          #shrink the accessory again if setting is true
          #make the object normal size if dragging it around
          if ContestSettings::DRESS_UP_ITEMS_SMALL == true
            @object.zoom_x = 0.5
            @object.zoom_y = 0.5
          end #if ContestSettings::DRESS_UP_ITEMS_SMALL == true
          
          #================================
          #===== Reset Dragged Object =====
          #================================
          @object = nil
          @currentlyDragging = false
          return
          
        end #if !@accessoryX.between?(@selectionWindowAreaX[0], @selectionWindowAreaX[1])
      end #if self.withinSelectionWindow?(@object)
    
      #================================
      #== Dropped in Backdrop Window ==
      #================================
      #if the accessory was dropped into the backdrop window
      if self.withinBackdropWindow?(@object)
        #================================
        #======= Attach Accessory =======
        #================================
        #if the object was not already in the backdrop window
        if !@accessoryX.between?(@backdropAreaX[0], @backdropAreaX[1])
          #if there is room for another accessory on the pokemon
          if @attached_accessories < @max_accessories
            #attach to pkmn and play the put down sound
            accessoryHash[1][:Attached] += 1
            pbSEPlay("Contests_Dressup_Put_down",100,100)
            
            #add 1 from attached accessories
            @attached_accessories += 1
            self.updateAccessoryLimitText
            
            #shrink the accessory again if setting is true
            #make the object normal size if dragging it around
            if ContestSettings::DRESS_UP_ITEMS_SMALL == true
              @object.zoom_x = 0.5
              @object.zoom_y = 0.5
            end #if ContestSettings::DRESS_UP_ITEMS_SMALL == true
            
            #================================
            #===== Reset Dragged Object =====
            #================================
            @object = nil
            @currentlyDragging = false
            return
            
          else
            #no more room for accessories on the pkmn
            #put it back in the selection window
            self.returnAccessory
          end #if @attached_accessories < @max_accessories
        else
          #if the accessory was put down in the same window it was already in
          #play the put down sound and do nothing else
          pbSEPlay("Contests_Dressup_Put_down",100,100)
          
          #================================
          #===== Reset Dragged Object =====
          #================================
          @object = nil
          @currentlyDragging = false
          return
          
        end #if !@accessoryX.between?(@backdropAreaX[0], @backdropAreaX[1])
      end #if self.withinBackdropWindow?(@object)
    
      #================================
      #=== Dropped in Invalid Area ===
      #================================
      #if an accessory was dropped off somewhere outside of the backdrop window
      #and the selection window, return if to where it came from
      if !self.withinSelectionWindow?(@object) && !self.withinBackdropWindow?(@object)
        self.returnAccessory
      end
    end #if Input.release?(Input::MOUSELEFT) && @currentlyDragging == true
    
    #================================
    #===== Release Right-Click =====
    #================================
    if Input.release?(Input::MOUSERIGHT)
      #when letting go of the pokemon, put its z back to normal
      @object.z = 99997
      
      if @currentlyDragging == true && self.withinBackdropWindow?(@object) && @draggedAccessory == "pkmn"
        pbSEPlay("Contests_Dressup_Put_down",100,100)
      end
      
      #if pokemon is not in the backdrop window, return it to the backdrop window
      if !self.withinBackdropWindow?(@object) && @draggedAccessory == "pkmn"
        self.returnPkmn
      end
      
      #================================
      #===== Reset Dragged Object =====
      #================================
      @object = nil
      @currentlyDragging = false
      return
      
    end #if Input.release?(Input::MOUSERIGHT)
  end #def self.attachDetach
  
  #=========================================================
  # Button UI Click Functionality
  #=========================================================
  #================================
  #========= Done Button =========
  #================================
  def self.clickedDoneButton
    self.saveContestantBitmap
  end #def self.clickedDoneButton
  
  #================================
  #======= Accessory Button =======
  #================================
  def self.clickedAccessoryButton
     #change from accessories to backdrops and vice versa
    if @selection_window_mode == "backdrop"
      @selection_window_mode = "accessory"
      @sprites["accessoryButton"].bitmap = Bitmap.new("Graphics/Pictures/Contest/dressup/accessory_sel")
      @sprites["backdropButton"].bitmap = Bitmap.new("Graphics/Pictures/Contest/dressup/backdrop_desel")
      self.updateSelectionWindowItems
      pbSEPlay("Contests_Dressup_Change_Mode",100,100)
    end
  end
  
  #================================
  #======= Backdrop Button =======
  #================================
  def self.clickedBackdropButton
    #change from accessories to backdrops and vice versa
    if @selection_window_mode == "accessory"
      @selection_window_mode = "backdrop"
      @sprites["accessoryButton"].bitmap = Bitmap.new("Graphics/Pictures/Contest/dressup/accessory_desel")
      @sprites["backdropButton"].bitmap = Bitmap.new("Graphics/Pictures/Contest/dressup/backdrop_sel")
      self.updateSelectionWindowItems
      pbSEPlay("Contests_Dressup_Change_Mode",100,100)
    end
  end
  
  #================================
  #========== Up Button ==========
  #================================
  def self.clickedUpButton
    #for accessory pages
    if @selection_window_mode == "accessory"
      if @accessoryPage == 0
        #loop around to max page
        @accessoryPage = @maxAccessoryPage
      else
        #subtract one page
        @accessoryPage -= 1
      end
    else
      #for backdrop pages
      if @backdropPage == 0
        #loop around to max page
        @backdropPage = @maxBackdropPage
      else
        #subtract one page
        @backdropPage -= 1
      end
    end #if @selection_window_mode == "accessory"
    
    pbSEPlay("Contests_Dressup_Change_Page",100,100)
    self.updateSelectionWindowItems
  end #def self.clickedUpButton
  
  #================================
  #========= Down Button =========
  #================================
  def self.clickedDownButton
    #for accessory pages
    if @selection_window_mode == "accessory"
      if @accessoryPage == @maxAccessoryPage
        #loop around to first page, which is 0
        @accessoryPage = 0
      else
        #add one page
        @accessoryPage += 1
      end
    else
      #for backdrop pages
      if @backdropPage == @maxBackdropPage
        #loop around to first page, which is 0
        @backdropPage = 0
      else
        #add one page
        @backdropPage += 1
      end
    end #if @selection_window_mode == "accessory"
    
    pbSEPlay("Contests_Dressup_Change_Page",100,100)
    self.updateSelectionWindowItems
  end
  
  #================================
  #========= Change Rank =========
  #================================
  def self.changeRank
    case @chosenRank
    when "Normal"
      @chosenRank = "Great"
      @max_accessories = ContestSettings::MAX_ACCESSORIES_GREAT
    when "Great"
      @chosenRank = "Ultra"
      @max_accessories = ContestSettings::MAX_ACCESSORIES_ULTRA
    when "Ultra"
      @chosenRank = "Master"
      @max_accessories = ContestSettings::MAX_ACCESSORIES_MASTER
    when "Master"
      @chosenRank = "Normal"
      @max_accessories = ContestSettings::MAX_ACCESSORIES_NORMAL
    end
    #clear text on the bitmap
    @rank_window.clear
    rank_text = sprintf("<ac>#{@chosenRank} Rank</ac>")
    drawFormattedTextEx(@rank_window, 0, 14, @sprites["selectionWindow"].width, rank_text, @textBaseColor, @textShadowColor)
    pbSEPlay("Contests_Dressup_Apply_Backdrop",100,100)
    
    self.updateAccessoryLimitText
  end
  
  #================================
  #====== Change Contestant ======
  #================================
  def self.changeContestant
    options = [
    "Set Species",
    "Set Form",
    "Set Gender",
    "Set Shininess",
    "Nevermind"
    ]
    choice = pbMessage(_INTL("Do what with the contestant?"), options, -1)
    
    pkmn = @contestantPkmn
    
    case choice
    when 0
      pkmn = pbChooseSpeciesList
      if pkmn != nil
        @contestantPkmn = Pokemon.new(pkmn, 1)
        @sprites["pkmn"].setSpeciesBitmap(@contestantPkmn.species, @contestantPkmn.gender, @contestantPkmn.form, @contestantPkmn.shiny?)
      end
      
    when 1
      forms = []
      #get all the forms of the pokemon
      cmd2 = 0
        formcmds = [[], []]
        GameData::Species.each do |sp|
          if sp.species == pkmn.species
            form_name = sp.form_name
            form_name = _INTL("Unnamed form") if !form_name || form_name.empty?
            form_name = sprintf("%d: %s", sp.form, form_name)
            formcmds[0].push(sp.form)
            formcmds[1].push(form_name)
            cmd2 = sp.form if pkmn.form == sp.form
          end
        end
        
      choice = pbMessage(_INTL("Set to which form?"), formcmds[1], -1)
      
      if choice != nil && choice != -1
        @contestantPkmn.form = choice
        @sprites["pkmn"].setSpeciesBitmap(@contestantPkmn.species, @contestantPkmn.gender, @contestantPkmn.form, @contestantPkmn.shiny?)
      end
          
    when 2
      if pkmn.singleGendered?
        pbMessage(_INTL("{1} is single-gendered or genderless.", pkmn.speciesName))
      elsif pkmn.gender == 0
        pkmn.gender = 1 if pbConfirmMessage(_INTL("Gender is Male. Set to Female?"))
      elsif pkmn.gender == 1
        pkmn.gender = 0 if pbConfirmMessage(_INTL("Gender is Female. Set to Male?"))
      end
      
      @sprites["pkmn"].setSpeciesBitmap(@contestantPkmn.species, @contestantPkmn.gender, @contestantPkmn.form, @contestantPkmn.shiny?)
    
    when 3
      options = [
      "Make Normal",
      "Make Shiny",
      "Make Super Shiny"
      ]
      choice = pbMessage(_INTL("Set to which type of shininess?"), options, -1)
    
      case choice
      when 0
        pkmn.shiny = false
        pkmn.super_shiny = false
        @sprites["pkmn"].setSpeciesBitmap(@contestantPkmn.species, @contestantPkmn.gender, @contestantPkmn.form, @contestantPkmn.shiny?)
      when 1
        pkmn.shiny = true
        pkmn.super_shiny = false
        @sprites["pkmn"].setSpeciesBitmap(@contestantPkmn.species, @contestantPkmn.gender, @contestantPkmn.form, @contestantPkmn.shiny?)
      when 2
        pkmn.super_shiny = true
        @sprites["pkmn"].setSpeciesBitmap(@contestantPkmn.species, @contestantPkmn.gender, @contestantPkmn.form, @contestantPkmn.shiny?)
      end
    end
  end #def self.changeContestant
  
end #class Dressup_Debug