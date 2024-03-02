def pbMessageNoClear(message, commands = nil, cmdIfCancel = 0, skin = nil, defaultCmd = 0, clear=false, &block)
  ret = 0
  msgwindow = pbCreateMessageWindow(nil, skin)
  if commands
    ret = pbMessageDisplay(msgwindow, message, true,
                           proc { |msgwindow|
                             next Kernel.pbShowCommands(msgwindow, commands, cmdIfCancel, defaultCmd, &block)
                           }, &block)
  else
    pbMessageDisplay(msgwindow, message, &block)
  end
  pbDisposeMessageWindow(msgwindow) if clear != false
  Input.update
  #return ret
  return msgwindow
end

def pbWaitUpdateGraphics(numFrames)
  numFrames.times do
    Graphics.update
    Results.update
    Input.update
    pbUpdateSceneMap
  end
end

class Results
  def self.sortPoints
    #sorts from least total points to most total points
    sortedContestants = @chosenContestants.sort_by { |hsh| hsh[:TotalPoints] }.reverse
    return sortedContestants
  end
  
  def self.placementNumbers
    #contestant1
    @sprites["c1Placement"] = AnimatedSprite.new("Graphics/Pictures/Contest/results/placement_numbers", 4, 28, 28, 0, @viewport)
    @sprites["c1Placement"].x = Graphics.width - 48 - (@sprites["c1Placement"].width/2)
    @sprites["c1Placement"].y = 14
    @sprites["c1Placement"].z = 99999
    @sprites["c1Placement"].visible = false
    
    #contestant2
    @sprites["c2Placement"] = AnimatedSprite.new("Graphics/Pictures/Contest/results/placement_numbers", 4, 28, 28, 0, @viewport)
    @sprites["c2Placement"].x = Graphics.width - 48 - (@sprites["c2Placement"].width/2)
    @sprites["c2Placement"].y = 78
    @sprites["c2Placement"].z = 99999
    @sprites["c2Placement"].visible = false
    
    #contestant3
    @sprites["c3Placement"] = AnimatedSprite.new("Graphics/Pictures/Contest/results/placement_numbers", 4, 28, 28, 0, @viewport)
    @sprites["c3Placement"].x = Graphics.width - 48 - (@sprites["c3Placement"].width/2)
    @sprites["c3Placement"].y = 142
    @sprites["c3Placement"].z = 99999
    @sprites["c3Placement"].visible = false
    
    #contestant4
    @sprites["c4Placement"] = AnimatedSprite.new("Graphics/Pictures/Contest/results/placement_numbers", 4, 28, 28, 0, @viewport)
    @sprites["c4Placement"].x = Graphics.width - 48 - (@sprites["c4Placement"].width/2)
    @sprites["c4Placement"].y = 206
    @sprites["c4Placement"].z = 99999
    @sprites["c4Placement"].visible = false
    
    reversedOrder = @contestant_order.clone
    reversedOrder = reversedOrder.reverse
    
    frame = 3
    
    #set the frame for placement numbers
    for i in 0...reversedOrder.length
      #find the placement sprite of the contestant in order[i]
      case reversedOrder[i]
      when @chosenContestants[0]
        placementSprite = @sprites["c1Placement"]
      when @chosenContestants[1]
        placementSprite = @sprites["c2Placement"]
      when @chosenContestants[2]
        placementSprite = @sprites["c3Placement"]
      when @chosenContestants[3]
        placementSprite = @sprites["c4Placement"]
      end #case reversedOrder[i]
      
      placementSprite.frame = frame
      placementSprite.visible = true
      pbSEPlay("Contests_Acting_Select_Move")
      frame -= 1
      pbWaitUpdateGraphics(1 * Graphics.frame_rate)
    end #for i in 0...@contestant_order.length
  end #def self.placementNumbers
  
  def self.getWinningEntryNumber
    case @contestant_order[0]
      when @chosenContestants[0]
        @winningEntryNumber = 1
      when @chosenContestants[1]
        @winningEntryNumber = 2
      when @chosenContestants[2]
        @winningEntryNumber = 3
      when @chosenContestants[3]
        @winningEntryNumber = 4
      end #case @contestant_order[0]
    end #def self.getWinningEntryNumber
    
  def self.showWinner
    @sprites["spotlight"] = IconSprite.new(0, 0, @viewport)
    @sprites["spotlight"].setBitmap("Graphics/Pictures/Contest/results/winner_spotlight")
    @sprites["spotlight"].x = Graphics.width/2 - @sprites["spotlight"].width/2
    @sprites["spotlight"].y = Graphics.height/2 - @sprites["spotlight"].height/2
    @sprites["spotlight"].z = 99999
    @sprites["spotlight"].opacity = 0
    
    pbBGMPlay("Contests_Winning")
    
    timer = 0
    loop do
      if timer >= (Graphics.frame_rate*1)/32
        @sprites["spotlight"].opacity += 15
        timer = 0
      end
      Graphics.update
      self.update
      break if @sprites["spotlight"].opacity >= 255
      timer += 1
    end
      
    #make the winner's sprite
    pkmnSpecies = @contestant_order[0][:PkmnSpecies]
    pkmnGender = @contestant_order[0][:PkmnGender]
    pkmnForm = @contestant_order[0][:PkmnForm]
    pkmnShiny = @contestant_order[0][:PkmnShiny]
    
    @sprites["pkmn"] = PokemonSprite.new(@viewport)
    @sprites["pkmn"].setSpeciesBitmap(pkmnSpecies, pkmnGender, pkmnForm, pkmnShiny, false, false)
    @sprites["pkmn"].setOffset(PictureOrigin::CENTER)
    @sprites["pkmn"].x = Graphics.width
    @sprites["pkmn"].y = Graphics.height/2
    @sprites["pkmn"].z = 99999
    
    desiredX = Graphics.width/2
    
    loop do
      Graphics.update
      self.update
      if @sprites["pkmn"].x > desiredX + Graphics.width/64
        @sprites["pkmn"].x -= Graphics.width/64
      else
        @sprites["pkmn"].x -= 1
      end
      break if @sprites["pkmn"].x <= desiredX
    end
    Pokemon.play_cry(pkmnSpecies, pkmnForm)
      
  end #def self.showWinner
    
  def self.saveWinner    
    winner = @contestant_order[0].clone
    
    #I can add whatever else I want to the variable winner and then save it to
    #the variables in $contest_save_data
    
    #save the last winner now
    $contest_save_data.lastContestWinner = winner
    
    case @chosenType
    when "Coolness"
      $contest_save_data.normalCoolWinner = winner if @chosenRank == "Normal"
      $contest_save_data.greatCoolWinner = winner if @chosenRank == "Great"
      $contest_save_data.ultraCoolWinner = winner if @chosenRank == "Ultra"
      $contest_save_data.masterCoolWinner = winner if @chosenRank == "Master"
    
    when "Beauty"
      $contest_save_data.normalBeautyWinner = winner if @chosenRank == "Normal"
      $contest_save_data.greatBeautyWinner = winner if @chosenRank == "Great"
      $contest_save_data.ultraBeautyWinner = winner if @chosenRank == "Ultra"
      $contest_save_data.masterBeautyWinner = winner if @chosenRank == "Master"

    when "Cuteness"
      $contest_save_data.normalCuteWinner = winner if @chosenRank == "Normal"
      $contest_save_data.greatCuteWinner = winner if @chosenRank == "Great"
      $contest_save_data.ultraCuteWinner = winner if @chosenRank == "Ultra"
      $contest_save_data.masterCuteWinner = winner if @chosenRank == "Master"
    
    when "Smartness"
      $contest_save_data.normalSmartWinner = winner if @chosenRank == "Normal"
      $contest_save_data.greatSmartWinner = winner if @chosenRank == "Great"
      $contest_save_data.ultraSmartWinner = winner if @chosenRank == "Ultra"
      $contest_save_data.masterSmartWinner = winner if @chosenRank == "Master"
  
    when "Toughness"
      $contest_save_data.normalToughWinner = winner if @chosenRank == "Normal"
      $contest_save_data.greatToughWinner = winner if @chosenRank == "Great"
      $contest_save_data.ultraToughWinner = winner if @chosenRank == "Ultra"
      $contest_save_data.masterToughWinner = winner if @chosenRank == "Master"
    end #case @chosenType

  end #def self.saveWinner
  
  def self.whiteFadeOut
    @fadeSprite["white_fade"] = BitmapSprite.new(Graphics.width, Graphics.height, @whiteFadeViewport)
    @fadeSprite["white_fade"].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(255,255,255))
    @fadeSprite["white_fade"].x = 0
    @fadeSprite["white_fade"].y = 0
    @fadeSprite["white_fade"].z = 999999
    @fadeSprite["white_fade"].opacity = 0
    
    loop do
      @fadeSprite["white_fade"].opacity += 17
      pbWaitUpdateGraphics(1 * Graphics.frame_rate/6)
      self.update
      break if @fadeSprite["white_fade"].opacity >= 255
    end #loop do
  end #def self.whiteFadeOut
    
    def self.whiteFadeIn
    loop do
      @fadeSprite["white_fade"].opacity -= 17
      pbWaitUpdateGraphics(1 * Graphics.frame_rate/16)
      self.update
      break if @fadeSprite["white_fade"].opacity <= 0
    end #loop do
  end #def self.whiteFadeIn

end #class Results