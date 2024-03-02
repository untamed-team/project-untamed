class Acting
  
  #=========================================================
  # Points Methods
  #=========================================================
  def self.sortPoints(reverse=false)
    #sorts from least total points to most total points
    if reverse == true
      #sortedContestants = @chosenContestants.sort_by{|a,b,c,d,e,f,g,h,i,j,k,l,m,n|c}.reverse
      sortedContestants = @chosenContestants.sort_by { |hsh| hsh[:TotalPoints] }.reverse
    else
      sortedContestants = @chosenContestants.sort_by { |hsh| hsh[:TotalPoints] }
    end
    return sortedContestants
  end
  
  #=========================================================
  # Contestant Order Methods
  #=========================================================
  def self.decideContestantOrder
    #decide contestants' move order
    if @performanceNumber <= 0
      @contestant_order = self.sortPoints(reverse=true)
    else
      @contestant_order = self.sortPoints
    end
    
    if @performanceNumber > 0
      #then change depending on whether a pokemon's moves made them go 1st, 2nd,
      #3rd, or 4th next round
    
      #@nextRoundContestantOrder = ["","","",""] when it's unmodified
    
      #take @nextRoundContestantOrder and get what contestants are in there
      #then remove all contestants in @nextRoundContestantOrder from
      #@contestant_order
      for i in 0...@nextRoundContestantOrder.length
        if @contestant_order.include?(@nextRoundContestantOrder[i])
          @contestant_order.delete(@nextRoundContestantOrder[i])
        end
      end
    
      #whatever contestants are left in @contestant_order are already sorted by
      #points
      #take the index of the elements in @nextRoundContestantOrder that are not ""
      #and insert those contestants at the same index in @contestant_order
      #skip if @contestant_order is now empty
      while !@contestant_order.empty?
        for i in 0...@nextRoundContestantOrder.length
          if @nextRoundContestantOrder[i] == ""
            @nextRoundContestantOrder[i] = @contestant_order[0]
            @contestant_order.delete_at(0)
            break
          end #if @nextRoundContestantOrder[i] == ""
        end #for i in 0...@nextRoundContestantOrder.length
      end #while !@contestant_order.empty?
    
      #once we're done filling in any gaps in @nextRoundContestantOrder and moving
      #contestants around, make @contestant_order a clone of @nextRoundContestantOrder
      #as long as it's not before the first performance
      @contestant_order = @nextRoundContestantOrder.clone
    end #if @performanceNumber > 0
    
    #set all ShowTurnOrder to false before going to the next round
    for i in 0...@contestant_order.length
        @contestant_order[i][:ShowTurnOrder] = false
    end #for i in 0...@contestant_order.length
    
    self.updateNextSprites if @performanceNumber > 0
    
    #reset the array that keeps track of Next round order
    @nextRoundContestantOrder = ["","","",""]
    
  end #def self.decideContestantOrder

  #=========================================================
  # Move Info Methods
  #=========================================================
  def self.getMoveFlags
    @move_attributes = [] #the array for your Pokemon's moves' attributes (cool,
    #smart, etc.)
    for i in 0...@playerPkmn.moves.length
      #push condition
      @move_attributes.push(["Cool"]) if self.moveCool?(@playerPkmn.moves[i])
      @move_attributes.push(["Beauty"]) if self.moveBeauty?(@playerPkmn.moves[i])
      @move_attributes.push(["Smart"]) if self.moveSmart?(@playerPkmn.moves[i])
      @move_attributes.push(["Cute"]) if self.moveCute?(@playerPkmn.moves[i])
      @move_attributes.push(["Tough"]) if self.moveTough?(@playerPkmn.moves[i])
      
      #make condition cool if not set up
      @move_attributes.push(["Cool"]) if !self.moveCool?(@playerPkmn.moves[i]) && !self.moveBeauty?(@playerPkmn.moves[i]) && !self.moveSmart?(@playerPkmn.moves[i]) && !self.moveCute?(@playerPkmn.moves[i]) && !self.moveTough?(@playerPkmn.moves[i])
      
      #push appeal
      @move_attributes[i].push(self.getAppeal(@playerPkmn.moves[i]))
      
      #push move effectText
      @move_attributes[i].push(self.getEffect(@playerPkmn.moves[i],"effectText"))
      #push move effectCode
      @move_attributes[i].push(self.getEffect(@playerPkmn.moves[i],"effectCode"))

    end #for i in 0...@playerPkmn.moves.length
    
  end #def self.getMoveFlags
  
  def self.moveCool?(move)
    #if move has Cool flag OR if move doesn't have any of the flags
    if move.flags.any? { |f| f[/^Contest_Cool$/i] } || (!move.flags.any? { |f| f[/^Contest_Cool$/i] } && !move.flags.any? { |f| f[/^Contest_Beauty$/i] } && !move.flags.any? { |f| f[/^Contest_Smart$/i] } && !move.flags.any? { |f| f[/^Contest_Cute$/i] } && !move.flags.any? { |f| f[/^Contest_Tough$/i] })
      return true
    else
      return false
    end
    #return move.flags.any? { |f| f[/^Contest_Cool$/i] }
  end
  def self.moveBeauty?(move)
    return move.flags.any? { |f| f[/^Contest_Beauty$/i] }
  end
  def self.moveSmart?(move)
    return move.flags.any? { |f| f[/^Contest_Smart$/i] }
  end
  def self.moveCute?(move)
    return move.flags.any? { |f| f[/^Contest_Cute$/i] }
  end
  def self.moveTough?(move)
    return move.flags.any? { |f| f[/^Contest_Tough$/i] }
  end
  
  def self.getAppeal(move)
    amount = nil
    move.flags.each do |flag|
      next if !flag[/^Contest_Appeal_(\d+)$/i]
      amount = $~[1]
      break
    end
    
    if amount == nil
      return 1
    else
      return amount.to_i
    end
  end #def self.getAppeal(move)
  
  def self.getEffect(move, requestedVar)
    #VALID EFFECTS:
    #Contest_Effect_Basic
    #Contest_Effect_Next1
    #Contest_Effect_Next4
    #Contest_Effect_RaiseScoreIfVoltageLow
    #Contest_Effect_Plus2IfFirst
    #Contest_Effect_Plus2IfLast
    #Contest_Effect_Plus2IfVoltageUp
    #Contest_Effect_Plus3If2VoltageInARow
    #Contest_Effect_Plus3IfNoPokemonChoseJudge
    #Contest_Effect_Plus3IfGetLowestScore
    #Contest_Effect_Plus3IfPreviousPokemonHitMaxVoltage
    #Contest_Effect_Plus15IfAllChoseSameJudge
    #Contest_Effect_StealVoltagePreviousPokemon
    #Contest_Effect_CanPerformMoveTwiceInARow
    #Contest_Effect_DoubleScoreNextTurn
    #Contest_Effect_DoubleScoreIfFinalTurn
    #Contest_Effect_IncreasedVoltageAddedToScore
    #Contest_Effect_PreventVoltageUpSameTurn
    #Contest_Effect_PreventVoltageDownSameTurn
    #Contest_Effect_HigherScoreTheLaterPerforms
    #Contest_Effect_LowerVoltageOfAllJudges1
    #Contest_Effect_RandomOrder
    #Contest_Effect_PointsEqualToOrder
    
    effectText = nil
    effectCode = nil
    
    if effectCode == nil && move.flags.any? { |f| f[/^Contest_Effect_Next1$/i] }
      #The user performs first next turn.
      effectText = _INTL("Perform first next turn.")
      effectCode = "Next1"      
    end
    if effectCode == nil && move.flags.any? { |f| f[/^Contest_Effect_Next4$/i] }
      #Enables the user to perform last in the next turn.
      effectText = _INTL("Perform last next turn.")
      effectCode = "Next4"
    end
    if effectCode == nil && move.flags.any? { |f| f[/^Contest_Effect_RaiseScoreIfVoltageLow$/i] }
      #Raises the score if the Voltage is low.
      effectText = _INTL("High score for low Voltage.")
      effectCode = "RaiseScoreIfVoltageLow"
    end
    if effectCode == nil && move.flags.any? { |f| f[/^Contest_Effect_Plus2IfFirst$/i] }
      #Earn +2 if the Pokémon performs first in the turn.
      effectText = _INTL("If first performance: +2")
      effectCode = "Plus2IfFirst"
    end
    if effectCode == nil && move.flags.any? { |f| f[/^Contest_Effect_Plus2IfLast$/i] }
      #Earn +2 if the Pokémon performs last in the turn.
      effectText = _INTL("If final performance: +2")
      effectCode = "Plus2IfLast"
    end
    if effectCode == nil && move.flags.any? { |f| f[/^Contest_Effect_Plus2IfVoltageUp$/i] }
      #Earn +2 if the Judge's Voltage goes up.
      effectText = _INTL("If the Voltage goes up: +2")
      effectCode = "Plus2IfVoltageUp"
    end
    if effectCode == nil && move.flags.any? { |f| f[/^Contest_Effect_Plus3If2VoltageInARow$/i] }
      #Earn +3 if two Pokémon raise the Voltage in a row.
      effectText = _INTL("If Voltage goes up in a row: +3")
      effectCode = "Plus3If2VoltageInARow"
    end
    if effectCode == nil && move.flags.any? { |f| f[/^Contest_Effect_Plus3IfNoPokemonChoseJudge$/i] }
      #Earn +3 if no other Pokémon has chosen the same Judge.
      effectText = _INTL("If Judges are not doubled: +3")
      effectCode = "Plus3IfNoPokemonChoseJudge"
    end
    if effectCode == nil && move.flags.any? { |f| f[/^Contest_Effect_Plus3IfGetLowestScore$/i] }
      #Earn +3 if the Pokémon gets the lowest score.
      effectText = _INTL("If rated the worst: +3")
      effectCode = "Plus3IfGetLowestScore"
    end
    if effectCode == nil && move.flags.any? { |f| f[/^Contest_Effect_Plus3IfPreviousPokemonHitMaxVoltage$/i] }
      #Earn +3 if the Pokémon that just went hit max Voltage.
      effectText = _INTL("After Voltage hits max: +3")
      effectCode = "Plus3IfPreviousPokemonHitMaxVoltage"
    end
    if effectCode == nil && move.flags.any? { |f| f[/^Contest_Effect_Plus15IfAllChoseSameJudge$/i] }
      #Earn +15 if all the Pokémon choose the same Judge.
      effectText = _INTL("If all choose same Judge: +15")
      effectCode = "Plus15IfAllChoseSameJudge"
    end
    if effectCode == nil && move.flags.any? { |f| f[/^Contest_Effect_StealVoltagePreviousPokemon$/i] }
      #Steals the Voltage of the Pokémon that just went.
      effectText = _INTL("Get Voltage from one ahead.")
      effectCode = "StealVoltagePreviousPokemon"
    end
    if effectCode == nil && move.flags.any? { |f| f[/^Contest_Effect_CanPerformMoveTwiceInARow$/i] }
      #Allows performance of the same move twice in a row.
      effectText = _INTL("Performable two turns in a row.")
      effectCode = "CanPerformMoveTwiceInARow"
    end
    if effectCode == nil && move.flags.any? { |f| f[/^Contest_Effect_DoubleScoreNextTurn$/i] }
      #Earn double the score in the next turn.
      effectText = _INTL("Double score in next turn.")
      effectCode = "DoubleScoreNextTurn"
    end
    if effectCode == nil && move.flags.any? { |f| f[/^Contest_Effect_DoubleScoreIfFinalTurn$/i] }
      #Earns double the score on the final performance.
      effectText = _INTL("Double score for final act.")
      effectCode = "DoubleScoreIfFinalTurn"
    end
    if effectCode == nil && move.flags.any? { |f| f[/^Contest_Effect_IncreasedVoltageAddedToScore$/i] }
      #Increased Voltage is added to the performance score.
      effectText = _INTL("Voltage pts. are added.")
      effectCode = "IncreasedVoltageAddedToScore"
    end
    if effectCode == nil && move.flags.any? { |f| f[/^Contest_Effect_PreventVoltageUpSameTurn$/i] }
      #Prevents the Voltage from going up in the same turn.
      effectText = _INTL("No Voltage up this turn.")
      effectCode = "PreventVoltageUpSameTurn"
    end
    if effectCode == nil && move.flags.any? { |f| f[/^Contest_Effect_PreventVoltageDownSameTurn$/i] }
      #Prevents the Voltage from going down in the same turn.
      effectText = _INTL("No Voltage down this turn.")
      effectCode = "PreventVoltageDownSameTurn"
    end
    if effectCode == nil && move.flags.any? { |f| f[/^Contest_Effect_HigherScoreTheLaterPerforms$/i] }
      #Earn a higher score the later the Pokémon performs.
      effectText = _INTL("Higher score for a later turn.")
      effectCode = "HigherScoreTheLaterPerforms"
    end
    if effectCode == nil && move.flags.any? { |f| f[/^Contest_Effect_LowerVoltageOfAllJudges1$/i] }
      #Lowers the Voltage of all Judges by one each.
      effectText = _INTL("Lowers Voltage of Judges by 1.")
      effectCode = "LowerVoltageOfAllJudges1"
    end
    if effectCode == nil && move.flags.any? { |f| f[/^Contest_Effect_RandomOrder$/i] }
      #Makes the order of contestants random in the next turn.
      effectText = _INTL("Random order next turn.")
      effectCode = "RandomOrder"
    end
    if effectCode == nil && move.flags.any? { |f| f[/^Contest_Effect_PointsEqualToOrder$/i] }
      #Earn +1 if the Pokémon performs first in the turn, +2 if performs second, +3 if performs third and +4 if performs last.
      effectText = _INTL("High score for a later turn.")
      effectCode = "PointsEqualToOrder"
    end
    if effectCode == nil || move.flags.any? { |f| f[/^Contest_Effect_Basic$/i] }
      #A basic act.
      effectText = _INTL("A basic act.")
      effectCode = "Basic"
      #####THIS SHOULD BE CHECKED LAST
    end
    
    if requestedVar == "effectText"
      return effectText
    else
      return effectCode
    end
  end #def self.getEffect(move, requestedVar)
  
  #=========================================================
  # UI Methods
  #=========================================================
  def self.addAppealHeartSprite(contestant)
    #get the tile card sprite to draw the heart on
    cardSprite = self.getCardSprite(contestant)
    
    #the 14 is the height of the heart and the 4 is the offset from the bottom
    #of the tile card
    heartY = cardSprite.y + cardSprite.height - 14 - 4
    
    c = cardSprite.y
    h = contestant[:CurrentRoundHearts]
    
    #setting the heartX
    #if contestant[:CurrentRoundHearts] == 7, 13, 19, 25, or 31, reset
    #heartX to 0
    #it's 10:51pm and I'm too tired to be smart
    if h == 1 || h == 7 || h == 13
      heartX = 0*17
    elsif h == 2 || h == 8 || h == 14
      heartX = 1*17
    elsif h == 3 || h == 9 || h == 15
      heartX = 2*17
    elsif h == 4 || h == 10 || h == 16
      heartX = 3*17
    elsif h == 5 || h == 11 || h == 17
      heartX = 4*17
    elsif h == 6 || h == 12 || h >= 18
      heartX = 5*17
    end
    
    #the name variation of the heart sprite is a combination of the height of
    #the cardsprite and contestant[:CurrentRoundHearts] to reflect the latest
    #heart for that contestant
    
    #the most hearts you can get is probably 18? 15 for moves with effect 
    #Plus15IfAllChoseSameJudge, and a max of 3 from judges
    if contestant[:CurrentRoundHearts].between?(1,6)
      image = "move_heart"
    elsif contestant[:CurrentRoundHearts].between?(7,12)
      image = "move_heart_pink"
    else
      image = "move_heart_yellow"
    end
    
    #make new heart sprites
    #(animname, framecount, framewidth, frameheight, frameskip)
    @heartSprites["heart#{c}#{h}"] = AnimatedSprite.new("Graphics/Pictures/Contest/acting/#{image}", 4, 16, 14, 0, @tilesViewport)
    @heartSprites["heart#{c}#{h}"].x = heartX
    @heartSprites["heart#{c}#{h}"].y = heartY
    @heartSprites["heart#{c}#{h}"].z = 99999
    @heartSprites["heart#{c}#{h}"].play
    #pitch = 100+(h*5)
    pitch = 100+(h*2)
    pbSEPlay("Contests_Acting_Heart_Increase", 100, pitch)

    loop do
      self.updateSprites
      if @heartSprites["heart#{c}#{h}"].frame == 3
        @heartSprites["heart#{c}#{h}"].stop
        break
      end
    end
    
  end #def self.addAppealHeartSprite(contestant)
  
  def self.deleteAppealHeartSprite
    cardSprite0 = self.getCardSprite(@contestant_order[0])
    c0 = cardSprite0.y
    h0 = @contestant_order[0][:CurrentRoundHearts]
    
    cardSprite1 = self.getCardSprite(@contestant_order[1])
    c1 = cardSprite1.y
    h1 = @contestant_order[1][:CurrentRoundHearts]
    
    cardSprite2 = self.getCardSprite(@contestant_order[2])
    c2 = cardSprite2.y
    h2 = @contestant_order[2][:CurrentRoundHearts]
    
    cardSprite3 = self.getCardSprite(@contestant_order[3])
    c3 = cardSprite3.y
    h3 = @contestant_order[3][:CurrentRoundHearts]
    
    loop do
      if @heartSprites["heart#{c0}#{h0}"] && !@heartSprites["heart#{c0}#{h0}"].disposed?
        @heartSprites["heart#{c0}#{h0}"].dispose
        h0 -= 1
      end
      
      if @heartSprites["heart#{c1}#{h1}"] && !@heartSprites["heart#{c1}#{h1}"].disposed?
        @heartSprites["heart#{c1}#{h1}"].dispose
        h1 -= 1
      end
      
      if @heartSprites["heart#{c2}#{h2}"] && !@heartSprites["heart#{c2}#{h2}"].disposed?
        @heartSprites["heart#{c2}#{h2}"].dispose
        h2 -= 1
      end
      
      if @heartSprites["heart#{c3}#{h3}"] && !@heartSprites["heart#{c3}#{h3}"].disposed?
        @heartSprites["heart#{c3}#{h3}"].dispose
        h3 -= 1
      end
      
      self.updateSprites
      
      pbSEPlay("Contests_Acting_Voltage_Hit_Card")
      #pbWait(1 * Graphics.frame_rate/8)
      self.pbWaitUpdateSprites(1 * Graphics.frame_rate/8)
      
      break if h0 <= 0 && h1 <= 0 && h2 <= 0 && h3 <= 0
    end #loop do
      
  end #def self.deleteAppealHeartSprite(contestant)
  
  def self.hideTiles
    @tilesViewport.visible = false
  end #def self.hideTiles
  
  def self.showTiles
    @tilesViewport.visible = true
  end #def self.showTiles
  
  def self.updateNextSprites
    for i in 0...@nextRoundContestantOrder.length
      if @nextRoundContestantOrder[i] != ""
        cardSprite = getCardSprite(@nextRoundContestantOrder[i])
        case cardSprite
        when @sprites["tile1"]
          j = 1
        when @sprites["tile2"]
          j = 2
        when @sprites["tile3"]
          j = 3
        when @sprites["tile4"]
          j = 4
        end
        @sprites["NextIcon#{j}"].frame = i
        #show the Next# sprite or not?
        if @nextRoundContestantOrder[i][:ShowTurnOrder] == true
          @sprites["NextIcon#{j}"].visible = true
        else
          @sprites["NextIcon#{j}"].visible = false
        end
      end #if @nextRoundContestantOrder[i] != ""
    end #for i in 0...@nextRoundContestantOrder.length
  end #def self.updateNextSprites
  
  def self.getCardSprite(contestant)
    #get cardSprite of specified contestant by comparing them to current order:
    #@chosenContestants[0], @chosenContestants[1], etc.
    case contestant
    when @contestant_order[0]
      return @sprites["tile1"]
    when @contestant_order[1]
      return @sprites["tile2"]
    when @contestant_order[2]
      return @sprites["tile3"]
    when @contestant_order[3]
      return @sprites["tile4"]
    end #case contestant
  end #def self.getCardSprite(contestant)
  
  def self.displayContestantInfo
    #change text color and tile color depending on what order the player is in
    #set player tile based on order
    if @contestant_order[0][:Player] == true
      @sprites["tile1"].setBitmap("Graphics/Pictures/Contest/acting/player_tile")
    else
      @sprites["tile1"].setBitmap("Graphics/Pictures/Contest/acting/nonplayer_contestant_tile")
    end
    if @contestant_order[1][:Player] == true
      @sprites["tile2"].setBitmap("Graphics/Pictures/Contest/acting/player_tile")
    else
      @sprites["tile2"].setBitmap("Graphics/Pictures/Contest/acting/nonplayer_contestant_tile")
    end
    if @contestant_order[2][:Player] == true
      @sprites["tile3"].setBitmap("Graphics/Pictures/Contest/acting/player_tile")
    else
      @sprites["tile3"].setBitmap("Graphics/Pictures/Contest/acting/nonplayer_contestant_tile")
    end
    if @contestant_order[3][:Player] == true
      @sprites["tile4"].setBitmap("Graphics/Pictures/Contest/acting/player_tile")
    else
      @sprites["tile4"].setBitmap("Graphics/Pictures/Contest/acting/nonplayer_contestant_tile")
    end
    
    #dispose of text bitmap if it exists
    if @sprites["emptyBitmap"] && !@sprites["emptyBitmap"].disposed?
      @sprites["emptyBitmap"].dispose
    end
    
    @sprites["emptyBitmap"] = BitmapSprite.new(Graphics.width, Graphics.height, @tilesViewport)
    @sprites["emptyBitmap"].z = 99999
    pbSetSystemFont(@sprites["emptyBitmap"].bitmap)
    textBitmap = @sprites["emptyBitmap"].bitmap
    
    if @contestant_order[0][:Player] == true
      #white base
      base   = Color.new(255, 255, 255)
      #gray shadow
      shadow = Color.new(220, 220, 220)
    else
      #pink base
      base   = Color.new(255, 75, 255)
      #lighter pink shadow
      shadow = Color.new(255, 153, 118)
    end
    
    textpos = [
    [_INTL("#{@contestant_order[0][:PkmnName]}"), 4, @sprites["tile1"].y+12, 0, base, shadow],
    [_INTL("#{@contestant_order[0][:TrainerName]}"), 4, @sprites["tile1"].y+48, 0, base, shadow]
    ]
    #put contestant names on tiles
    pbDrawTextPositions(textBitmap, textpos)
    
    if @contestant_order[1][:Player] == true
      #white base
      base   = Color.new(255, 255, 255)
      #gray shadow
      shadow = Color.new(220, 220, 220)
    else
      #pink base
      base   = Color.new(255, 75, 255)
      #lighter pink shadow
      shadow = Color.new(255, 153, 118)
    end
    
    textpos = [
    [_INTL("#{@contestant_order[1][:PkmnName]}"), 4, @sprites["tile2"].y+12, 0, base, shadow],
    [_INTL("#{@contestant_order[1][:TrainerName]}"), 4, @sprites["tile2"].y+48, 0, base, shadow]
    ]
    pbDrawTextPositions(textBitmap, textpos)
    
    if @contestant_order[2][:Player] == true
      #white base
      base   = Color.new(255, 255, 255)
      #gray shadow
      shadow = Color.new(220, 220, 220)
    else
      #pink base
      base   = Color.new(255, 75, 255)
      #lighter pink shadow
      shadow = Color.new(255, 153, 118)
    end
    
    textpos = [
    [_INTL("#{@contestant_order[2][:PkmnName]}"), 4, @sprites["tile3"].y+12, 0, base, shadow],
    [_INTL("#{@contestant_order[2][:TrainerName]}"), 4, @sprites["tile3"].y+48, 0, base, shadow]
    ]
    pbDrawTextPositions(textBitmap, textpos)
    
    if @contestant_order[3][:Player] == true
      #white base
      base   = Color.new(255, 255, 255)
      #gray shadow
      shadow = Color.new(220, 220, 220)
    else
      #pink base
      base   = Color.new(255, 75, 255)
      #lighter pink shadow
      shadow = Color.new(255, 153, 118)
    end
    
    textpos = [
    [_INTL("#{@contestant_order[3][:PkmnName]}"), 4, @sprites["tile4"].y+12, 0, base, shadow],
    [_INTL("#{@contestant_order[3][:TrainerName]}"), 4, @sprites["tile4"].y+48, 0, base, shadow]
    ]
    pbDrawTextPositions(textBitmap, textpos)
  end
  
  #=========================================================
  # Judge Methods
  #=========================================================
  def self.judgePerformedTo?(judge)
    if @chosenContestants[0][:JudgeLastPerformedTo] == judge[:ID].to_i
      #judge performed to
      return true
    end
    if @chosenContestants[1][:JudgeLastPerformedTo] == judge[:ID].to_i
      #judge performed to
      return true
    end
    if @chosenContestants[2][:JudgeLastPerformedTo] == judge[:ID].to_i
      #judge performed to
      return true
    end
    if @chosenContestants[3][:JudgeLastPerformedTo] == judge[:ID].to_i
      #judge performed to
      return true
    end
    return false
  end #self.judgePerformedTo?(judgeNumber)
  
  #=========================================================
  # Misc Methods
  #=========================================================
  def self.updateSprites
    Graphics.update
    pbUpdateSpriteHash(@sprites)
    pbUpdateSpriteHash(@heartSprites)
  end
  
  def self.audienceCheer(loop=nil)
    pbSEPlay("Contests_Crowd",80,100)
    @sprites["background"].play
    timer = 0
    if loop
      loop do
        self.updateSprites
        timer += 1
        if timer >= (Graphics.frame_rate*1.5) && @sprites["background"].frame == 0
          self.audienceStop
          break
        end #if timer >= (Graphics.frame_rate*1.5)
      end #loop do
    end #if loop
  end #def self.audienceCheer(loop=nil)
  
  def self.audienceStop
    @sprites["background"].stop
    @sprites["background"].frame = 0
    self.updateSprites
  end #def self.audienceStop
  
  def self.pbWaitUpdateSprites(numFrames)
    numFrames.times do
      self.updateSprites
      Input.update
      pbUpdateSceneMap
    end
  end #def self.pbWaitUpdateSprites(numFrames, spritehash)
  
end #class Acting