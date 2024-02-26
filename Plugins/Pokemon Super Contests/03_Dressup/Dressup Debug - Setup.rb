class Dressup_Debug
  #=========================================================
  # Setup
  #=========================================================
  def self.setup(rank)
    @textBaseColor = Color.new(248, 248, 248)
    @textShadowColor = Color.new(72, 80, 88)
    @accessoryPage = 0
    @backdropPage = 0
    @object = nil
    @currentlyDragging = nil
    @selection_window_mode = "accessory"
    @chosenRank = rank
    
    case @chosenRank
    when "Normal"
      @max_accessories = ContestSettings::MAX_ACCESSORIES_NORMAL
    when "Great"
      @max_accessories = ContestSettings::MAX_ACCESSORIES_GREAT
    when "Ultra"
      @max_accessories = ContestSettings::MAX_ACCESSORIES_ULTRA
    when "Master"
      @max_accessories = ContestSettings::MAX_ACCESSORIES_MASTER
    end
    
    #================================
    #= Make @available_accessories =
    #================================
    self.makeAvailableAccessories
    
    #================================
    #== Make @available_backdrops ==
    #================================
    self.makeAvailableBackdrops

  end #def self.setup
  
  def self.makeAvailableAccessories
    #get the items available for use in dressup (owned items)
    #looks in the array for the fashion case and adds all accessories in there
    #to the array @available_accessories = []
    @available_accessories = []
    @attached_accessories = 0
    
    #give all accessories possible so we can keep the element structure
    for i in 0...ContestSettings::ACCESSORIES.length
      @available_accessories.push(ContestSettings::ACCESSORIES[i].clone)
    end
    
    #delete what is not in the fashion case
    for i in 0...@available_accessories.length
      @available_accessories[i].each do |key, value|
        if !$fashion_case.unlocked_accessories.include?(key.to_s)
          @available_accessories[i].delete(key)
        end #if !$fashion_case.unlocked_accessories.include?(key.to_s)
      end #@available_accessories[i].each do |key, value|
    end #for i in 0...@available_accessories.length
    
    #delete blank hashes {} from the array
    @available_accessories.delete({})
    
    #get max number of pages for all the accessories the player has
    @maxAccessoryPage = @available_accessories.length - 1
    
    #add keys: Quantity, Attached, PageNumber
    for i in 0...@available_accessories.length
      @available_accessories[i].each do |hash|
        hash.each do |h|
          if h.is_a?(Symbol)
            #if in debug, give the developer 5 of each accessory regardless
            #of what's in the fashion case
            @quantity = 5
          elsif h.is_a?(Hash)
            h.merge!({Quantity: @quantity})
            h.merge!({Attached: 0})
            h.merge!({PageNumber: i})
          end #if h.is_a?(Symbol)
        end #hash.each do |h|
      end #@available_accessories[i].each do |hash|
    end #for i in 0...@available_accessories.length
    
  end #def self.makeAvailableAccessories
  
  def self.makeAvailableBackdrops(debug = nil)
    #get the backdrops available for use in dressup
    @available_backdrops = []
    
    for i in 0...ContestSettings::BACKDROPS.length
      backdrop = ContestSettings::BACKDROPS[i]
      if debug == true
        #if in debug, give the developer each backdrop
        @available_backdrops.push(backdrop)
      else
        @available_backdrops.push(backdrop) if $fashion_case.unlocked_backdrops.include?(backdrop)
      end #if debug == true
    end

    #set the max backdrop page
    @maxBackdropPage = 0
    b = 0
    for i in 0...@available_backdrops.length
      if b == 9
        @maxBackdropPage += 1
        b = 0
      end
      b += 1
    end #for i in 0...@available_backdrops.length
  end #def self.makeAvailableBackdrops(debug = nil)
  
  #=========================================================
  # Initialize UI Graphics
  #=========================================================
  def self.enterDressup(pkmn)
    #initialize graphics
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @accessorySprites = {}
    @backdropSprites = {}
    
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/Contest/dressup/background")
    @sprites["background"].x = 0
    @sprites["background"].y = 0
    @sprites["background"].z = 99997
    
    @sprites["selectionWindow"] = Sprite.new(@viewport)
    @sprites["selectionWindow"].bitmap = Bitmap.new("Graphics/Pictures/Contest/dressup/selection window")
    @sprites["selectionWindow"].x = 16
    @sprites["selectionWindow"].y = 46
    @sprites["selectionWindow"].z = 99996
    @selectionWindowAreaX = [@sprites["selectionWindow"].x, @sprites["selectionWindow"].width-10]
    @selectionWindowAreaY = [@sprites["selectionWindow"].y, @sprites["selectionWindow"].y + @sprites["selectionWindow"].height-24]
    
    @sprites["backdrop"] = Sprite.new(@viewport)
    @sprites["backdrop"].bitmap = Bitmap.new("Graphics/Pictures/Contest/dressup/backdrops/dress up")
    @sprites["backdrop"].x = Graphics.width - 16 - (@sprites["backdrop"].width)
    @sprites["backdrop"].y = 46
    @sprites["backdrop"].z = 99996
    @backdropAreaX = [@sprites["backdrop"].x, @sprites["backdrop"].width + @sprites["backdrop"].x-22]
    @backdropAreaY = [@sprites["backdrop"].y, @sprites["backdrop"].height+22]
    
    #rank text
    @sprites["rank"] = BitmapSprite.new(@sprites["selectionWindow"].width, 64, @viewport)
    @sprites["rank"].x = @sprites["selectionWindow"].x
    @sprites["rank"].y = 0
    @sprites["rank"].z = 99999
    pbSetSystemFont(@sprites["rank"].bitmap)
    @rank_window = @sprites["rank"].bitmap
    rank_text = sprintf("<ac>#{@chosenRank} Rank</ac>")
    drawFormattedTextEx(@rank_window, 0, 14, @sprites["selectionWindow"].width, rank_text, @textBaseColor, @textShadowColor)
    
    #accessory limit text
    @sprites["accessory_limit"] = BitmapSprite.new(@sprites["backdrop"].width, 64, @viewport)
    @sprites["accessory_limit"].x = @sprites["backdrop"].x
    @sprites["accessory_limit"].y = 0
    @sprites["accessory_limit"].z = 99999
    pbSetSystemFont(@sprites["accessory_limit"].bitmap)
    @accessory_limit_window = @sprites["accessory_limit"].bitmap
    accessory_limit_text = sprintf("<ac>#{@attached_accessories}/#{@max_accessories}</ac>")
    drawFormattedTextEx(@accessory_limit_window, 0, 14, @sprites["backdrop"].width, accessory_limit_text, @textBaseColor, @textShadowColor)
    
    #accessory limit icon
    @sprites["accessory_limit_icon"] = IconSprite.new(0, 0, @viewport)
    @sprites["accessory_limit_icon"].setBitmap("Graphics/Pictures/Contest/dressup/accessory_icon")
    @sprites["accessory_limit_icon"].x = @sprites["backdrop"].x + @sprites["backdrop"].width/2 + 36
    @sprites["accessory_limit_icon"].y = 12
    @sprites["accessory_limit_icon"].z = 99999
    
    #pokeball icon for changing species
    @sprites["pokeball"] = IconSprite.new(0, 0, @viewport)
    @sprites["pokeball"].setBitmap("Graphics/Pictures/Contest/dressup/pokeball")
    @sprites["pokeball"].x = (Graphics.width / 2) - (@sprites["pokeball"].width / 2)
    @sprites["pokeball"].y = 0#12
    @sprites["pokeball"].z = 99999
    
    @sprites["upButton"] = Sprite.new(@viewport)
    @sprites["upButton"].bitmap = Bitmap.new("Graphics/Pictures/Contest/dressup/up button")
    @sprites["upButton"].x = 20
    @sprites["upButton"].y = (@sprites["backdrop"].y + @sprites["backdrop"].height) + 8
    @sprites["upButton"].z = 99997
    
    @sprites["downButton"] = Sprite.new(@viewport)
    @sprites["downButton"].bitmap = Bitmap.new("Graphics/Pictures/Contest/dressup/down button")
    @sprites["downButton"].x = @sprites["upButton"].x + (@sprites["upButton"].width) + 12
    @sprites["downButton"].y = (@sprites["backdrop"].y + @sprites["backdrop"].height) + 8
    @sprites["downButton"].z = 99997
    
    @sprites["accessoryButton"] = Sprite.new(@viewport)
    @sprites["accessoryButton"].bitmap = Bitmap.new("Graphics/Pictures/Contest/dressup/accessory_sel")
    @sprites["accessoryButton"].x = Graphics.width/2 - @sprites["accessoryButton"].width
    @sprites["accessoryButton"].y = (@sprites["backdrop"].y + @sprites["backdrop"].height) + 8
    @sprites["accessoryButton"].z = 99997
    
    @sprites["backdropButton"] = Sprite.new(@viewport)
    @sprites["backdropButton"].bitmap = Bitmap.new("Graphics/Pictures/Contest/dressup/backdrop_desel")
    @sprites["backdropButton"].x = Graphics.width/2
    @sprites["backdropButton"].y = (@sprites["backdrop"].y + @sprites["backdrop"].height) + 8
    @sprites["backdropButton"].z = 99997
    
    @sprites["doneButton"] = Sprite.new(@viewport)
    @sprites["doneButton"].bitmap = Bitmap.new("Graphics/Pictures/Contest/dressup/done button")
    @sprites["doneButton"].x = (@sprites["backdrop"].x + @sprites["backdrop"].width) - @sprites["doneButton"].width
    @sprites["doneButton"].y = (@sprites["backdrop"].y + @sprites["backdrop"].height) + 8
    @sprites["doneButton"].z = 99997
        
    #=========================================================
    # Initialize Pokemon Graphic
    #=========================================================
    #pokemon sprite
    @contestantPkmn = Pokemon.new(pkmn, 1)
    
    @sprites["pkmn"] = PokemonSprite.new(@viewport)
    @sprites["pkmn"].setSpeciesBitmap(@contestantPkmn.species, @contestantPkmn.gender, @contestantPkmn.form, @contestantPkmn.shiny?)
    @sprites["pkmn"].setOffset(PictureOrigin::CENTER)
    @sprites["pkmn"].x = @sprites["backdrop"].x + @sprites["backdrop"].width/2
    @sprites["pkmn"].y = @sprites["backdrop"].y + @sprites["backdrop"].height/2
    @sprites["pkmn"].z = 99997
  end

end #class Dressup_Debug