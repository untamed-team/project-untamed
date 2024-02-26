class Results
  #=====================
  # Setup Points Screen
  #=====================
  def self.setupPointsScreen
    #initialize important variables
    @chosenType = ContestTypeRank.getChosenType
    @chosenRank = ContestTypeRank.getChosenRank
    
    @playerPkmn = ContestContestant.getPlayerPkmn
    
    #initialize graphics
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/Contest/results/background")
    @sprites["background"].x = 0
    @sprites["background"].y = 0
    @sprites["background"].z = 99999
    
    #=====================
    # Contestant 1 Sprite
    #=====================
    contestantSpriteY = 45
    
    contestant1Pkmn = Pokemon.new(@chosenContestants[0][:PkmnSpecies], 1)
    contestant1Pkmn.gender = @chosenContestants[0][:PkmnGender]
    contestant1Pkmn.form = @chosenContestants[0][:PkmnForm]
    contestant1Pkmn.shiny = @chosenContestants[0][:PkmnShiny]
    
    @sprites["contestant1"] = PokemonIconSprite.new(contestant1Pkmn, @viewport)
    @sprites["contestant1"].setOffset(PictureOrigin::CENTER)
    @sprites["contestant1"].active = true
    @sprites["contestant1"].z = 99999
    @sprites["contestant1"].x = 54
    @sprites["contestant1"].y = contestantSpriteY
    
    #=====================
    # Contestant 2 Sprite
    #=====================
    contestantSpriteY += 64
    
    contestant2Pkmn = Pokemon.new(@chosenContestants[1][:PkmnSpecies], 1)
    contestant2Pkmn.gender = @chosenContestants[1][:PkmnGender]
    contestant2Pkmn.form = @chosenContestants[1][:PkmnForm]
    contestant2Pkmn.shiny = @chosenContestants[1][:PkmnShiny]
    
    @sprites["contestant2"] = PokemonIconSprite.new(contestant2Pkmn, @viewport)
    @sprites["contestant2"].setOffset(PictureOrigin::CENTER)
    @sprites["contestant2"].active = true
    @sprites["contestant2"].z = 99999
    @sprites["contestant2"].x = 54
    @sprites["contestant2"].y = contestantSpriteY
    
    #=====================
    # Contestant 3 Sprite
    #=====================
    contestantSpriteY += 64
    
    contestant3Pkmn = Pokemon.new(@chosenContestants[2][:PkmnSpecies], 1)
    contestant3Pkmn.gender = @chosenContestants[2][:PkmnGender]
    contestant3Pkmn.form = @chosenContestants[2][:PkmnForm]
    contestant3Pkmn.shiny = @chosenContestants[2][:PkmnShiny]
    
    @sprites["contestant3"] = PokemonIconSprite.new(contestant3Pkmn, @viewport)
    @sprites["contestant3"].setOffset(PictureOrigin::CENTER)
    @sprites["contestant3"].active = true
    @sprites["contestant3"].z = 99999
    @sprites["contestant3"].x = 54
    @sprites["contestant3"].y = contestantSpriteY
    
    #=====================
    # Contestant 4 Sprite
    #=====================
    contestantSpriteY += 64
    
    @sprites["contestant4"] = PokemonIconSprite.new(@playerPkmn, @viewport)
    @sprites["contestant4"].setOffset(PictureOrigin::CENTER)
    @sprites["contestant4"].active = true
    @sprites["contestant4"].z = 99999
    @sprites["contestant4"].x = 54
    @sprites["contestant4"].y = contestantSpriteY
    
    #=====================
    # Set Contestant Names
    #=====================
    @sprites["emptyBitmap"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["emptyBitmap"].z = 99999
    pbSetSystemFont(@sprites["emptyBitmap"].bitmap)
    textBitmap = @sprites["emptyBitmap"].bitmap
    
    base   = MessageConfig::DARK_TEXT_MAIN_COLOR
    shadow = MessageConfig::DARK_TEXT_SHADOW_COLOR

    pkmnNameX = 96
    trainerNameX = Graphics.width/2
    contestantInfoY = 28

    textpos = [
    [_INTL("#{@chosenContestants[0][:PkmnName]}"), pkmnNameX, contestantInfoY, 0, base, shadow],
    [_INTL("#{@chosenContestants[0][:TrainerName]}"), trainerNameX, contestantInfoY, 0, base, shadow]
    ]
    
    for i in 1..3
      contestantInfoY += 64
      textpos.push(
      [_INTL("#{@chosenContestants[i][:PkmnName]}"), pkmnNameX, contestantInfoY, 0, base, shadow],
      [_INTL("#{@chosenContestants[i][:TrainerName]}"), trainerNameX, contestantInfoY, 0, base, shadow]
      )
    end #for i in 1..3
    
    #put contestant names on results background
    pbDrawTextPositions(textBitmap, textpos)
    
  end #def self.setupPointsScreen

end #class Results