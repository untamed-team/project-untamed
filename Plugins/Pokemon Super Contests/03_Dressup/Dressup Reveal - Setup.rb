class DressupReveal
  
  #===========================
  #========= Setup ==========
  #===========================
  def self.setup
    #initialize important variables
    @chosenType = ContestTypeRank.getChosenType
    @chosenRank = ContestTypeRank.getChosenRank
    
    @playerPkmn = ContestContestant.getPlayerPkmn
    
    @crowdAreaX = [32,Graphics.width-32]
    @crowdAreaY = [Graphics.height-150,Graphics.height-20]
    
    #initialize graphics
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/Contest/dressup/reveal_background")
    @sprites["background"].x = 0
    @sprites["background"].y = 0
    @sprites["background"].z = 99997
    
    @sprites["crowd"] = IconSprite.new(0, 0, @viewport)
    @sprites["crowd"].setBitmap("Graphics/Pictures/Contest/dressup/reveal_crowd")
    @sprites["crowd"].x = 0
    @sprites["crowd"].y = Graphics.height/2
    @sprites["crowd"].z = 99998
    
    @sprites["curtain"] = IconSprite.new(0, 0, @viewport)
    @sprites["curtain"].setBitmap("Graphics/Pictures/Contest/dressup/reveal_curtain")
    @sprites["curtain"].x = 0
    @sprites["curtain"].y = 0
    @sprites["curtain"].z = 99997
    
    @sprites["white_fade"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["white_fade"].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(255,255,255))
    @sprites["white_fade"].x = 0
    @sprites["white_fade"].y = 0
    @sprites["white_fade"].z = 99999
  end

end