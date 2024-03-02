class Acting
  #=========================================================
  # Move Methods
  #=========================================================
  def self.segregateMovesByContestType
    @coolMoves        = []
    @beautyMoves      = []
    @smartMoves       = []
    @cuteMoves        = []
    @toughMoves       = []
    
    GameData::Move.each do |move|
      moveData = Pokemon::Move.new(move)
      if self.moveCool?(moveData)
        @coolMoves.push(moveData.id)
        next
      end
      if self.moveBeauty?(moveData)
        @beautyMoves.push(moveData.id)
        next
      end
      if self.moveSmart?(moveData)
        @smartMoves.push(moveData.id)
        next
      end
      if self.moveCute?(moveData)
        @cuteMoves.push(moveData.id)
        next
      end
      if self.moveTough?(moveData)
        @toughMoves.push(moveData.id)
        next
      end
      #when the loop gets here, a Contest_type flag was not found for the move
      #add to cool moves by default
      @coolMoves.push(moveData.id)
    end #GameData::Move.each do |move|
      
    #set what moves match, oppose, and do not oppose based on the chosen
    #contest type
    @matchingMoves    = []
    @nonOpposingMoves = []
    @opposingMoves    = []
    
    #get the opposing moves and non-opposing moves the pokemon can learn
    #what opposes each move type in the chart?
    #cool   - non-opposing: beauty, tough | opposing: smart, cute
    #beauty - non-opposing: cool, cute    | opposing: tough, smart
    #smart  - non-opposing: cute, tough   | opposing: cool, beauty
    #cute   - non-opposing: beauty, smart | opposing: cool, tough
    #tough  - non-opposing: cool, smart   | opposing: beauty, cute
    
    case @chosenType
    when "Coolness"
      #matching
      for i in 0...@coolMoves.length
        @matchingMoves.push(@coolMoves[i])
      end
      #non-opposing
      for i in 0...@beautyMoves.length
        @nonOpposingMoves.push(@beautyMoves[i])
      end
      for i in 0...@toughMoves.length
        @nonOpposingMoves.push(@toughMoves[i])
      end
      #opposing
      for i in 0...@smartMoves.length
        @opposingMoves.push(@smartMoves[i])
      end
      for i in 0...@cuteMoves.length
        @opposingMoves.push(@cuteMoves[i])
      end
    when "Beauty"
      #matching
      for i in 0...@beautyMoves.length
        @matchingMoves.push(@beautyMoves[i])
      end
      #non-opposing
      for i in 0...@coolMoves.length
        @nonOpposingMoves.push(@coolMoves[i])
      end
      for i in 0...@cuteMoves.length
        @nonOpposingMoves.push(@cuteMoves[i])
      end
      #opposing
      for i in 0...@smartMoves.length
        @opposingMoves.push(@smartMoves[i])
      end
      for i in 0...@toughMoves.length
        @opposingMoves.push(@toughMoves[i])
      end
    when "Cuteness"
      #matching
      for i in 0...@cuteMoves.length
        @matchingMoves.push(@cuteMoves[i])
      end
      #non-opposing
      for i in 0...@beautyMoves.length
        @nonOpposingMoves.push(@beautyMoves[i])
      end
      for i in 0...@smartMoves.length
        @nonOpposingMoves.push(@smartMoves[i])
      end
      #opposing
      for i in 0...@coolMoves.length
        @opposingMoves.push(@coolMoves[i])
      end
      for i in 0...@toughMoves.length
        @opposingMoves.push(@toughMoves[i])
      end
    when "Smartness"
      #matching
      for i in 0...@smartMoves.length
        @matchingMoves.push(@smartMoves[i])
      end
      #non-opposing
      for i in 0...@cuteMoves.length
        @nonOpposingMoves.push(@cuteMoves[i])
      end
      for i in 0...@toughMoves.length
        @nonOpposingMoves.push(@toughMoves[i])
      end
      #opposing
      for i in 0...@coolMoves.length
        @opposingMoves.push(@coolMoves[i])
      end
      for i in 0...@beautyMoves.length
        @opposingMoves.push(@beautyMoves[i])
      end
    when "Toughness"
      #matching
      for i in 0...@toughMoves.length
        @matchingMoves.push(@toughMoves[i])
      end
      #non-opposing
      for i in 0...@coolMoves.length
        @nonOpposingMoves.push(@coolMoves[i])
      end
      for i in 0...@smartMoves.length
        @nonOpposingMoves.push(@smartMoves[i])
      end
      #opposing
      for i in 0...@cuteMoves.length
        @opposingMoves.push(@cuteMoves[i])
      end
      for i in 0...@beautyMoves.length
        @opposingMoves.push(@beautyMoves[i])
      end
    end #case @chosenType
  end #def self.segregateMoves
  
  def self.askPlayerMove
    loop do
      self.pickMove
      self.disposeMoves
      self.pickJudge
      if @exitPressed == true #went back from selecting judge to selecting move
        self.disposeJudgeButtons
      else
        self.disposeJudgeButtons
        break
      end #if @exitPressed == true
    end #loop do
  end #self.askPlayerMove
  
  def self.pickMove
    #pick one of your moves to show to the judges
    if @performanceNumber < 4
      msgwindow = pbMessageContest(_INTL("\\^\\ts[]Performance <c3=E82010,F8A8B8>no. #{@performanceNumber}</c3>! \\nWhich move is your choice?"), nil, 0, nil, 0, clear=false)
    else
      msgwindow = pbMessageContest(_INTL("\\^\\ts[]It's the <c3=E82010,F8A8B8>last</c3> performance! \\nChoose your move!"), nil, 0, nil, 0, clear=false)
    end
    self.drawMoves
    
    #find the index of the move last performed
    for i in 0...@chosenContestants[3][:PkmnMoves].length
      if @chosenContestants[3][:PkmnMoves][i].id == @chosenContestants[3][:MoveLastPerformed]
        lastUsedMoveArrayPos = i
      end
    end
    
    loop do
      #detect button input to move cursor over moves
      self.updateSprites
      Input.update
      cursor=@cursor1
      self.updateCursor(cursor)
      if Input.trigger?(Input::LEFT) || Input.trigger?(Input::RIGHT)
        case @cursor1Pos
        when 1
          #in the top left, so go to position 2
          pbPlayCursorSE
          @cursor1Pos = 2
        when 2
          #in the top right, so go to position 1
          pbPlayCursorSE
          @cursor1Pos = 1
        when 3
          #in the bottom left, so go to position 4
          if @playerPkmn.moves.length >= 4
            pbPlayCursorSE
            @cursor1Pos = 4
          end
        when 4
          #in the bottom right, so go to position 3
          if @playerPkmn.moves.length >= 3
            pbPlayCursorSE
            @cursor1Pos = 3
          end
        end #case position
      elsif Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN)
        case @cursor1Pos
        when 1
          #in the top left, so go to position 3
          if @playerPkmn.moves.length >= 3
            pbPlayCursorSE
            @cursor1Pos = 3
          end
        when 2
          #in the top right, so go to position 4
          if @playerPkmn.moves.length >= 4
            pbPlayCursorSE
            @cursor1Pos = 4
          end
        when 3
          #in the bottom left, so go to position 1
          pbPlayCursorSE
          @cursor1Pos = 1
        when 4
          #in the bottom right, so go to position 2
          pbPlayCursorSE
          @cursor1Pos = 2
        end #case @cursor1Pos
      end #if Input.trigger?(Input::LEFT)
      
      #can we perform the same move again?
      if @chosenContestants[3][:MoveLastPerformed] != ""
        tempMove = GameData::Move.get(@chosenContestants[3][:MoveLastPerformed])
        lastTurnEffect = self.getEffect(tempMove, "effectCode")
      end
      
      #detect selection
      if Input.trigger?(Input::USE)
        next if lastUsedMoveArrayPos == @cursor1Pos-1 && lastTurnEffect != "CanPerformMoveTwiceInARow"
        next if lastUsedMoveArrayPos == @cursor1Pos-1 && @chosenContestants[3][:MovePerformedTwoTurnsAgo] == @chosenContestants[3][:MoveLastPerformed]
        pbSEPlay("Contests_Acting_Select_Move")
        @playerSelectedMove = @playerPkmn.moves[@cursor1Pos-1]
        break
      end #if Input.trigger?(Input::USE)
    end #loop do
    msgwindow.text = ""
  end #def self.pickMove
  
  def self.pickJudge
    #pick one of your moves to show to the judges
    msgwindow = pbMessageContest(_INTL("\\^\\ts[]Choose the Judge you want to rate the move."), nil, 0, nil, 0, clear=false)
    self.drawJudgeButtons
    
    @exitPressed = false
    
    loop do
      #detect button input to move cursor over moves
      self.updateSprites
      Input.update
      cursor=@cursor2
      self.updateCursor(cursor)
      if Input.trigger?(Input::LEFT)
        pbPlayCursorSE
        if @cursor2Pos > 1
          @cursor2Pos -= 1
        elsif @cursor2Pos <= 1
          @cursor2Pos = 3
        end
      elsif Input.trigger?(Input::RIGHT)
        pbPlayCursorSE
        if @cursor2Pos >= 3
          @cursor2Pos = 1
        elsif @cursor2Pos < 3
          @cursor2Pos += 1
        end
      end #if Input.trigger?(Input::LEFT)
      
      #detect selection
      if Input.trigger?(Input::USE)
        pbSEPlay("Contests_Acting_Select_Move")
        @playerSelectedJudge = ContestSettings::JUDGES[@cursor2Pos-1]
        break
      end #if Input.trigger?(Input::USE)
      
      if Input.trigger?(Input::BACK)
        #pbPlayCancelSE
        @exitPressed = true
        break
      end #if Input.trigger?(Input::BACK)
    end #loop do
    msgwindow.text = ""
  end #def self.pickJudge
  
  #=========================================================
  # Drawing/Disposing Sprites Methods
  #=========================================================
  def self.drawMoves
    moveTileXStart = @sprites["tile1"].x + @sprites["tile1"].width
    moveTileXEnd = Graphics.width
    moveTileXArea = moveTileXEnd - moveTileXStart
    
    #display moves on the screen
    @sprites["move1"] = IconSprite.new(0, 0, @viewport)
    
    #set bitmap depending on move's attribute
    @sprites["move1"].setBitmap("Graphics/Pictures/Contest/acting/move_used")
    @sprites["move1"].x = moveTileXStart + moveTileXArea/2 - @sprites["move1"].width
    @sprites["move1"].y = 100
    @sprites["move1"].z = 99999
    self.setMoveBitmap(moveNumber=1)
    self.drawMoveText(moveNumber=1)
    self.drawMoveAppeal(moveNumber=1)
    
    @sprites["move2"] = IconSprite.new(0, 0, @viewport)
    @sprites["move2"].setBitmap("Graphics/Pictures/Contest/acting/move_used")
    @sprites["move2"].x = @sprites["move1"].x + @sprites["move1"].width + 6
    @sprites["move2"].y = 100
    @sprites["move2"].z = 99999
    self.setMoveBitmap(moveNumber=2)
    self.drawMoveText(moveNumber=2)
    self.drawMoveAppeal(moveNumber=2)
    
    if @playerPkmn.moves.length >= 3
      @sprites["move3"] = IconSprite.new(0, 0, @viewport)
      @sprites["move3"].setBitmap("Graphics/Pictures/Contest/acting/move_used")
      @sprites["move3"].x = @sprites["move1"].x
      @sprites["move3"].y = @sprites["move1"].y + @sprites["move1"].height + 6
      @sprites["move3"].z = 99999
      self.setMoveBitmap(moveNumber=3)
      self.drawMoveText(moveNumber=3)
      self.drawMoveAppeal(moveNumber=3)
    end
    
    if @playerPkmn.moves.length >= 4
      @sprites["move4"] = IconSprite.new(0, 0, @viewport)
      @sprites["move4"].setBitmap("Graphics/Pictures/Contest/acting/move_used")
      @sprites["move4"].x = @sprites["move2"].x
      @sprites["move4"].y = @sprites["move2"].y + @sprites["move2"].height + 6
      @sprites["move4"].z = 99999
      self.setMoveBitmap(moveNumber=4)
      self.drawMoveText(moveNumber=4)
      self.drawMoveAppeal(moveNumber=4)
    end
  end #def self.drawMoves
  
  def self.setMoveBitmap(moveNumber)
    #set the bitmap for the move depending on its condition, and show the
    #condition name icon too
    @sprites["move#{moveNumber}Condition"] = AnimatedSprite.new("Graphics/Pictures/Contest/acting/move_categories", 5, 38, 13, 0, @viewport)
    @sprites["move#{moveNumber}Condition"].x = @sprites["move#{moveNumber}"].x + 10
    @sprites["move#{moveNumber}Condition"].y = @sprites["move#{moveNumber}"].y + 34
    @sprites["move#{moveNumber}Condition"].z = 99999
    
    case @move_attributes[moveNumber-1][0]
    when "Cool"
      @sprites["move#{moveNumber}"].setBitmap("Graphics/Pictures/Contest/acting/move_coolness")
      @sprites["move#{moveNumber}Condition"].frame = 1
    when "Beauty"
      @sprites["move#{moveNumber}"].setBitmap("Graphics/Pictures/Contest/acting/move_beauty")
      @sprites["move#{moveNumber}Condition"].frame = 2
    when "Smart"
      @sprites["move#{moveNumber}"].setBitmap("Graphics/Pictures/Contest/acting/move_smartness")
      @sprites["move#{moveNumber}Condition"].frame = 3
    when "Cute"
      @sprites["move#{moveNumber}"].setBitmap("Graphics/Pictures/Contest/acting/move_cuteness")
      @sprites["move#{moveNumber}Condition"].frame = 4
    when "Tough"
      @sprites["move#{moveNumber}"].setBitmap("Graphics/Pictures/Contest/acting/move_toughness")
      @sprites["move#{moveNumber}Condition"].frame = 0
    end
    
    #if the move was used last turn by the player, make the bitmap of the move tile gray
    #can we perform the same move again?
      if @chosenContestants[3][:MoveLastPerformed] != ""
        tempMove = GameData::Move.get(@chosenContestants[3][:MoveLastPerformed])
        lastTurnEffect = self.getEffect(tempMove, "effectCode")
      end
    
    moveID = @chosenContestants[3][:PkmnMoves][moveNumber-1].id
    if @chosenContestants[3][:MoveLastPerformed] == moveID  && lastTurnEffect != "CanPerformMoveTwiceInARow"
      @sprites["move#{moveNumber}"].setBitmap("Graphics/Pictures/Contest/acting/move_used")
    end
    if @chosenContestants[3][:MovePerformedTwoTurnsAgo] == @chosenContestants[3][:MoveLastPerformed] && @chosenContestants[3][:MoveLastPerformed] == moveID
      @sprites["move#{moveNumber}"].setBitmap("Graphics/Pictures/Contest/acting/move_used")
    end
    
  end
  
  def self.drawMoveText(moveNumber)
    @sprites["moveTextBitmap#{moveNumber}"] = BitmapSprite.new(@sprites["move#{moveNumber}"].width, @sprites["move#{moveNumber}"].height, @viewport)
    @sprites["moveTextBitmap#{moveNumber}"].x = @sprites["move#{moveNumber}"].x
    @sprites["moveTextBitmap#{moveNumber}"].y = @sprites["move#{moveNumber}"].y
    @sprites["moveTextBitmap#{moveNumber}"].z = 99999
    pbSetSystemFont(@sprites["moveTextBitmap#{moveNumber}"].bitmap)
    textBitmap = @sprites["moveTextBitmap#{moveNumber}"].bitmap
    textBitmap.font.size = 14
    textBitmap.font.bold = true

    #white base
    base   = Color.new(255, 255, 255)
    #gray shadow
    shadow = Color.new(130, 130, 130)
    
    #set move name
    moveName = @playerPkmn.moves[moveNumber-1].name
    #draw move name on move tile
    #drawTextEx(bitmap=textBitmap, x=10, y=20, width=textBitmap.width, numlines=2, _INTL("#{moveName}"), base, shadow)
    drawFormattedTextEx(bitmap=textBitmap, x=10, y=20, width=textBitmap.width-14, text=_INTL("#{moveName}"), baseColor=base, shadowColor=shadow, lineheight=16)
    #@move_attributes
    moveDescription = @move_attributes[moveNumber-1][2]
    drawFormattedTextEx(bitmap=textBitmap, x=10, y=56, width=textBitmap.width-14, text=_INTL("#{moveDescription}"), baseColor=base, shadowColor=shadow, lineheight=16)
  end
  
  def self.drawMoveAppeal(moveNumber)
    textBitmap = @sprites["moveTextBitmap#{moveNumber}"].bitmap
    moveAppeal = @move_attributes[moveNumber-1][1]
    imagepos = []
    
    heartX = 54
    heartY = 38
    
    moveAppeal.times do
      imagepos.push(["Graphics/Pictures/Contest/acting/score_heart", x=heartX, y=heartY])
      heartX += 8
    end
  
    pbDrawImagePositions(bitmap=textBitmap, imagepos)
  end
  
  def self.disposeMoves
    @cursor1.visible = false
    i = 0
    @playerPkmn.moves.length.times do
      i += 1
      if @sprites["move#{i}"] && !@sprites["move#{i}"].disposed?
        @sprites["move#{i}"].dispose
        @sprites["moveTextBitmap#{i}"].dispose
        @sprites["move#{i}Condition"].dispose
      end
    end
  end #def self.disposeMoves
  
  def self.drawJudgeButtons
    judgeButtonXStart = @sprites["tile1"].x + @sprites["tile1"].width
    judgeButtonXEnd = Graphics.width
    judgeButtonXArea = judgeButtonXEnd - judgeButtonXStart
    
    #display judges on the screen
    @sprites["judgeButton1"] = IconSprite.new(0, 0, @viewport)
    @sprites["judgeButton1"].setBitmap("Graphics/Pictures/Contest/acting/judge_button_left")
    @sprites["judgeButton1"].x = judgeButtonXStart + judgeButtonXArea/3 - @sprites["judgeButton1"].width
    @sprites["judgeButton1"].y = 160
    @sprites["judgeButton1"].z = 99999
    
    @sprites["judgeButton2"] = IconSprite.new(0, 0, @viewport)
    @sprites["judgeButton2"].setBitmap("Graphics/Pictures/Contest/acting/judge_button_center")
    @sprites["judgeButton2"].x = judgeButtonXStart + judgeButtonXArea/2 - @sprites["judgeButton1"].width/2
    @sprites["judgeButton2"].y = 160
    @sprites["judgeButton2"].z = 99999
    
    @sprites["judgeButton3"] = IconSprite.new(0, 0, @viewport)
    @sprites["judgeButton3"].setBitmap("Graphics/Pictures/Contest/acting/judge_button_right")
    @sprites["judgeButton3"].x = judgeButtonXStart + judgeButtonXArea - @sprites["judgeButton1"].width*1.5
    @sprites["judgeButton3"].y = 160
    @sprites["judgeButton3"].z = 99999
    
    self.drawJudgeNames
  end #self.drawJudgeButtons
  
  def self.drawJudgeNames
    #white base
    base   = Color.new(255, 255, 255)
    #gray shadow
    shadow = Color.new(130, 130, 130)
    
    i = 0
    3.times do
      i += 1
      @sprites["judgeNameBitmap#{i}"] = BitmapSprite.new(@sprites["judgeButton#{i}"].width, @sprites["judgeButton#{i}"].height, @viewport)
      @sprites["judgeNameBitmap#{i}"].x = @sprites["judgeButton#{i}"].x
      @sprites["judgeNameBitmap#{i}"].y = @sprites["judgeButton#{i}"].y
      @sprites["judgeNameBitmap#{i}"].z = 99999
      pbSetSystemFont(@sprites["judgeNameBitmap#{i}"].bitmap)
      textBitmap = @sprites["judgeNameBitmap#{i}"].bitmap
      textBitmap.font.size = 16
      textBitmap.font.bold = true
    
      #set judge name
      judgeName = ContestSettings::JUDGES[i-1][:Name]
      #draw move name on move tile
      drawFormattedTextEx(bitmap=textBitmap, x=0, y=@sprites["judgeNameBitmap#{i}"].height/2, width=textBitmap.width, text=_INTL("<ac>#{judgeName}"), baseColor=base, shadowColor=shadow, lineheight=16)
    end #3.times do
  end #def self.drawJudgeNames
  
  def self.disposeJudgeButtons
    @cursor2.visible = false
    i = 0
    3.times do
      i += 1
      if @sprites["judgeButton#{i}"] && !@sprites["judgeButton#{i}"].disposed?
        @sprites["judgeButton#{i}"].dispose
        @sprites["judgeNameBitmap#{i}"].dispose
      end
    end
  end #def self.disposeJudgeButtons
  
  #=========================================================
  # Cursor Methods
  #=========================================================
  def self.updateCursor(cursor)
    #shows the cursor for selecting a move/judge
    
    if cursor == @cursor1
      #cursor for selecting moves
      #hide judge cursor
      @cursor2.visible = false
      
      cursor.x = @sprites["move#{@cursor1Pos}"].x - 6
      cursor.y = @sprites["move#{@cursor1Pos}"].y - 5
      cursor.z = 99999
      cursor.visible = true
    else
      #cursor for selecting a judge
      #hide moves cursor
      @cursor1.visible = false
      
      cursor.x = @sprites["judgeButton#{@cursor2Pos}"].x - 6
      cursor.y = @sprites["judgeButton#{@cursor2Pos}"].y - 5
      cursor.z = 99999
      cursor.visible = true
    end #if cursor == @cursor1
    
  end #def self.updateCursor(cursor, position)
  
  def self.transform
    #if used the move transform, change sprite for @sprites["pkmn"]
    #change into pokemon that's right before, or if none, right after
    if @contestantTurn == 1
      pkmnSpecies = @contestant_order[1][:PkmnSpecies]
      pkmnGender = @contestant_order[1][:PkmnGender]
      pkmnForm = @contestant_order[1][:PkmnForm]
      pkmnShiny = @contestant_order[1][:PkmnShiny]
    else
      pkmnSpecies = @contestant_order[@contestantTurn-2][:PkmnSpecies]
      pkmnGender = @contestant_order[@contestantTurn-2][:PkmnGender]
      pkmnForm = @contestant_order[@contestantTurn-2][:PkmnForm]
      pkmnShiny = @contestant_order[@contestantTurn-2][:PkmnShiny]
    end
    @sprites["pkmn"].setSpeciesBitmap(pkmnSpecies, pkmnGender, pkmnForm, pkmnShiny, false, true)
    self.updateSprites
  end #def self.transform

end #class Acting