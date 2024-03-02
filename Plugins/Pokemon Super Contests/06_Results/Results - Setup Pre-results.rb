class Results
  #=====================
  # Setup Pre-results
  #=====================
  def self.setupPreResults
    #initialize important variables
    @chosenType = ContestTypeRank.getChosenType
    @chosenRank = ContestTypeRank.getChosenRank
    
    @playerPkmn = ContestContestant.getPlayerPkmn
    
    #initialize graphics
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    
    @whiteFadeViewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @whiteFadeViewport.z = 999999
    @fadeSprite = {}

    
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/Contest/dressup/reveal_background")
    @sprites["background"].x = 0
    @sprites["background"].y = 0
    @sprites["background"].z = 99999
    
    @sprites["crowd"] = IconSprite.new(0, 0, @viewport)
    @sprites["crowd"].setBitmap("Graphics/Pictures/Contest/dressup/reveal_crowd")
    @sprites["crowd"].x = 0
    @sprites["crowd"].y = Graphics.height/2
    @sprites["crowd"].z = 99999
    
    #=====================
    # Contestant 1
    #=====================
    pkmnSpecies = @chosenContestants[0][:PkmnSpecies]
    pkmnGender = @chosenContestants[0][:PkmnGender]
    pkmnForm = @chosenContestants[0][:PkmnForm]
    pkmnShiny = @chosenContestants[0][:PkmnShiny]
    
    @sprites["contestant1"] = PokemonSprite.new(@viewport)
    @sprites["contestant1"].setSpeciesBitmap(pkmnSpecies, pkmnGender, pkmnForm, pkmnShiny, false, false)
    @sprites["contestant1"].setOffset(PictureOrigin::BOTTOM)
    @sprites["contestant1"].x = @sprites["contestant1"].width/2
    @sprites["contestant1"].y = Graphics.height/2 + @sprites["contestant1"].height/4
    @sprites["contestant1"].z = 99999
    
    #=====================
    # Contestant 2
    #=====================
    pkmnSpecies = @chosenContestants[1][:PkmnSpecies]
    pkmnGender = @chosenContestants[1][:PkmnGender]
    pkmnForm = @chosenContestants[1][:PkmnForm]
    pkmnShiny = @chosenContestants[1][:PkmnShiny]

    @sprites["contestant2"] = PokemonSprite.new(@viewport)
    @sprites["contestant2"].setSpeciesBitmap(pkmnSpecies, pkmnGender, pkmnForm, pkmnShiny, false, false)
    @sprites["contestant2"].setOffset(PictureOrigin::BOTTOM)
    @sprites["contestant2"].x = Graphics.width/2 - @sprites["contestant2"].width/3
    @sprites["contestant2"].y = Graphics.height/2 + @sprites["contestant2"].height/4
    @sprites["contestant2"].z = 99999
    
    #=====================
    # Contestant 3
    #=====================
    pkmnSpecies = @chosenContestants[2][:PkmnSpecies]
    pkmnGender = @chosenContestants[2][:PkmnGender]
    pkmnForm = @chosenContestants[2][:PkmnForm]
    pkmnShiny = @chosenContestants[2][:PkmnShiny]

    @sprites["contestant3"] = PokemonSprite.new(@viewport)
    @sprites["contestant3"].setSpeciesBitmap(pkmnSpecies, pkmnGender, pkmnForm, pkmnShiny, false, false)
    @sprites["contestant3"].setOffset(PictureOrigin::BOTTOM)
    @sprites["contestant3"].x = Graphics.width/2 + @sprites["contestant3"].width/3
    @sprites["contestant3"].y = Graphics.height/2 + @sprites["contestant3"].height/4
    @sprites["contestant3"].z = 99999
    
    #=====================
    # Contestant 4
    #=====================
    pkmnSpecies = @chosenContestants[3][:PkmnSpecies]
    pkmnGender = @chosenContestants[3][:PkmnGender]
    pkmnForm = @chosenContestants[3][:PkmnForm]
    pkmnShiny = @chosenContestants[3][:PkmnShiny]
    
    @sprites["contestant4"] = PokemonSprite.new(@viewport)
    @sprites["contestant4"].setSpeciesBitmap(pkmnSpecies, pkmnGender, pkmnForm, pkmnShiny, false, false)
    @sprites["contestant4"].setOffset(PictureOrigin::BOTTOM)
    @sprites["contestant4"].x = Graphics.width - @sprites["contestant4"].width/2
    @sprites["contestant4"].y = Graphics.height/2 + @sprites["contestant4"].height/4
    @sprites["contestant4"].z = 99999
  end #def self.setupPreResults

end #class Results