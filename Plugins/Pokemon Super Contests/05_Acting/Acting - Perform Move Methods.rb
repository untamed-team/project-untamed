class Acting
  
  #=====================
  # Perform Move
  #=====================
  def self.performMove(contestant)
    @contestantTurn += 1
    
    self.hideTiles
    
    self.pullUpContestant(contestant)
    
    self.audienceCheer(loop=true)
    
    case contestant
    when @chosenContestants[0]
      judge = @contestant1SelectedJudge
      move = @contestant1SelectedMove
    when @chosenContestants[1]
      judge = @contestant2SelectedJudge
      move = @contestant2SelectedMove
    when @chosenContestants[2]
      judge = @contestant3SelectedJudge
      move = @contestant3SelectedMove
    when @chosenContestants[3]
      judge = @playerSelectedJudge
      move = @playerSelectedMove
    end

    self.judgeReact(judge, reactTo=1, move, contestant)
    
    #play move animation
    atself = move.target == GameData::Target.get(:User)
    pbPlayAnimation(move.id, atself)
    
    #transform into another contestant if used moved transfor
    if move.id == :TRANSFORM
      self.transform
    end
    
    pbWait(1 * Graphics.frame_rate/2)
    self.showTiles
    pbWait(1 * Graphics.frame_rate/2)
    
    #give appeal hearts
    #card is the card on the left side to add hearts to
    self.awardMoveAppealHearts(move, contestant)
    
    pbWait(1 * Graphics.frame_rate/2)
    
    if @msgwindow
      #clear message window that stayed on the screen during move animation if
      #contestant performed to a judge who was already performed to
      @msgwindow.text = ""
    end
    
    pbWait(1 * Graphics.frame_rate/2)
    
    self.afterMoveEffect(move, contestant, judge)
    
    if @msgwindow
      #clear message window that stayed on the screen during the effect
      #announcement
      @msgwindow.text = ""
    end
    
    @judgeNumberVoltagePeakPreviousTurn = nil
    
    self.judgeReact(judge, reactTo=2, move, contestant)
    
    self.afterVoltageEffects(move, contestant)
    
    contestant[:MovePerformedTwoTurnsAgo] = contestant[:MoveLastPerformed]
    contestant[:MoveLastPerformed] = move.id
    
    self.pullBackContestant(contestant)
  end #def self.performMove(contestant)
  
  #=====================
  # Judge Reactions
  #=====================
  def self.judgeReact(judge, reactTo, move, contestant)
    case judge[:ID]
    when 0
      reactionX = @sprites["judge_panel"].x + @sprites["judge_panel"].width/6
      reactionY = @sprites["judge_panel"].y + 28
    when 1
      reactionX = @sprites["judge_panel"].x + @sprites["judge_panel"].width/2
      reactionY = @sprites["judge_panel"].y + 28
    when 2
      reactionX = @sprites["judge_panel"].x + @sprites["judge_panel"].width - @sprites["judge_panel"].width/6
      reactionY = @sprites["judge_panel"].y + 28
    end
    
    @sprites["reaction"] = AnimatedSprite.new("Graphics/Pictures/Contest/acting/reactions", 4, 26, 28, 0, @viewport)
    @sprites["reaction"].x = reactionX - @sprites["reaction"].width/2
    @sprites["reaction"].y = reactionY
    @sprites["reaction"].z = 99999
    @sprites["reaction"].visible = false
    
    case reactTo
    when 1
      #initial reaction to being performed to this round
      
      #was the judge already performed to?
      judgePerformedTo = self.judgePerformedTo?(judge)
      contestant[:JudgeLastPerformedTo] = judge[:ID]
      judge[:TimesPerformedTo] += 1
      
      if judgePerformedTo
        #someone already performed for this judge
        #not happy about it
        @sprites["reaction"].frame = 1
        @sprites["reaction"].visible = true
        
        self.judgeShudder(judge)
        
        #wait after judge reaction
        pbWait(1 * Graphics.frame_rate/2)
    
        #dipose judge reaction
        @sprites["reaction"].dispose
        
        pbMessageContest(_INTL("To #{judge[:Name]}, #{contestant[:PkmnName]} performed #{move.name}!"))
        self.preMoveEffect(move, contestant, judge)
        pbMessageContest(_INTL("Oh, no! Someone already performed for that Judge!"))
        #@msgwindow = pbMessageContest(_INTL("\\^\\ts[]Oh, no! Someone already performed for that Judge!"), nil, 0, nil, 0, clear=false)
      else
        #nobody has performed for this judge yet
        #happy about it
        @sprites["reaction"].frame = 0
        @sprites["reaction"].visible = true
        pbSEPlay("Contests_Acting_Heart_Increase")
        
        self.judgeGenericJump(judge)
        self.judgeGenericJump(judge)
        
        #wait after judge reaction
        pbWait(1 * Graphics.frame_rate/2)
    
        #dipose judge reaction
        @sprites["reaction"].dispose

        pbMessageContest(_INTL("To #{judge[:Name]}, #{contestant[:PkmnName]} performed #{move.name}!"))
        self.preMoveEffect(move, contestant, judge)
      end #if judgePerformedTo
    when 2
      @judgeNumberPreviousTurnVoltageUp = @judgeNumberThisTurnVoltageUp
      
      #check the contest type of the move just performed
      type = "Cool"   if self.moveCool?(move)
      type = "Beauty" if self.moveBeauty?(move)
      type = "Smart"  if self.moveSmart?(move)
      type = "Cute"   if self.moveCute?(move)
      type = "Tough"  if self.moveTough?(move)

      #reaction to the move performed
      #was the move fitting for the contest type?
      if @matchingMoves.include?(move.id) && @voltagePreventUp != true
        #frame 2 is gold star
        if judge[:Voltage] >= 4 #checking if voltage is currently 4 because we aren't increasing the variable yet
          @sprites["reaction"].frame = 3
        else
          @sprites["reaction"].frame = 2
        end
        @sprites["reaction"].visible = true
        pbSEPlay("Contests_Acting_Judge_Voltage_Up")
        #judge jump if happy
        self.judgeReactMediumJump(judge, muted=true)
        self.audienceCheer(true)
        if @voltagePreventUp != true
          pbMessageContest(_INTL("Upon seeing the #{type} move performed, #{judge[:Name]}'s Voltage went up!"))
          self.increaseVoltage(judge, contestant)
        end
      elsif @opposingMoves.include?(move.id) && @voltagePreventDown != true && judge[:Voltage] > 0
        #negative reaction since move type opposes contest type
        #if an opposingmove is made but voltage is 0, no reaction is given at
        #all
        @sprites["reaction"].frame = 1
        @sprites["reaction"].visible = true
        if @voltagePreventDown != true
          pbMessageContest(_INTL("Upon seeing the #{type} move performed, #{judge[:Name]}'s Voltage went down!"))
          self.decreaseVoltage(judge)
        end
      else
        #voltage did not rise or fall
        @judgeNumberThisTurnVoltageUp = nil
      end #if @matchingMoves.include?(move)
      
      #wait after judge reaction
      pbWait(1 * Graphics.frame_rate/2)
      
      #dipose judge reaction
      @sprites["reaction"].dispose
    end #case reactTo
  end #def self.judgeReact(judge, reactTo, move)
  
  def self.judgeShudder(judge)
    pbSEPlay("Contests_Acting_Judge_Shudder", 100)
    #shake side to side    
    #timer and variables for judge shaking
    bobX = 0
    timerX = 0
    bobDistance = 5#10
    bobSpeed = 1.28#0.64#0.32#0.165
    
    case judge[:ID]
    when 0
      judgeSprite = @sprites["judge_left"]
    when 1
      judgeSprite = @sprites["judge_center"]
    when 2
      judgeSprite = @sprites["judge_right"]
    end
    
    judgeStartX = judgeSprite.x
    loop do
      self.updateSprites
      bobX = Math.sin(timerX * bobSpeed) * bobDistance
      #absBobX = bobX.abs
      judgeSprite.x = judgeStartX - bobX#absBobX.truncate
      timerX += 1
      
      if timerX >= Graphics.frame_rate/8
        judgeSprite.x = judgeStartX
        self.updateSprites
        break
      end #if timerX >= Graphics.frame_rate
    end #loop do
    
  end #def self.judgeShudder(judge)

  def self.judgeEmotion(judge, animFrame)
    case judge[:ID]
    when 0
      reactionX = @sprites["judge_panel"].x + @sprites["judge_panel"].width/6
      reactionY = @sprites["judge_panel"].y + 28
    when 1
      reactionX = @sprites["judge_panel"].x + @sprites["judge_panel"].width/2
      reactionY = @sprites["judge_panel"].y + 28
    when 2
      reactionX = @sprites["judge_panel"].x + @sprites["judge_panel"].width - @sprites["judge_panel"].width/6
      reactionY = @sprites["judge_panel"].y + 28
    end
    
    @sprites["reaction"] = AnimatedSprite.new("Graphics/Pictures/Contest/acting/reactions", 4, 26, 28, 0, @viewport)
    @sprites["reaction"].x = reactionX - @sprites["reaction"].width/2
    @sprites["reaction"].y = reactionY
    @sprites["reaction"].z = 99999
    @sprites["reaction"].frame = animFrame
  end #def self.judgeEmotion(animFrame)
  
  def self.judgeGenericJump(judge)
    #timer and variables for judge jumping
    bobY = 0
    timerY = 0
    bobDistance = 10
    bobSpeed = 0.32#0.165
    
    case judge[:ID]
    when 0
      judgeSprite = @sprites["judge_left"]
    when 1
      judgeSprite = @sprites["judge_center"]
    when 2
      judgeSprite = @sprites["judge_right"]
    end
    
    judgeStartY = judgeSprite.y
    loop do
      self.updateSprites
      bobY = Math.sin(timerY * bobSpeed) * bobDistance
      absBobY = bobY.abs
      judgeSprite.y = judgeStartY - absBobY.truncate
      timerY += 1
      
      if timerY >= Graphics.frame_rate/4
        judgeSprite.y = judgeStartY
        self.updateSprites
        break
      end #if timerY >= Graphics.frame_rate
    end #loop do
  end #def self.judgeGenericJump(judge)
  
  def self.judgeReactLowJump(judge)
    pbSEPlay("Contests_Acting_Judge_Jump_Low")
    
    #timer and variables for judge jumping
    bobY = 0
    timerY = 0
    bobDistance = 6
    bobSpeed = 0.16
    
    case judge[:ID]
    when 0
      judgeSprite = @sprites["judge_left"]
    when 1
      judgeSprite = @sprites["judge_center"]
    when 2
      judgeSprite = @sprites["judge_right"]
    end
    
    judgeStartY = judgeSprite.y
    loop do
      self.updateSprites
      bobY = Math.sin(timerY * bobSpeed) * bobDistance
      absBobY = bobY.abs
      judgeSprite.y = judgeStartY - absBobY.truncate
      timerY += 1
      
      if timerY >= (Graphics.frame_rate*0.4)
        judgeSprite.y = judgeStartY
        self.updateSprites
        break
      end #if timerY >= Graphics.frame_rate
    end #loop do
  end #def self.judgeReactLowJump(judge)
    
  def self.judgeReactMediumJump(judge, muted=nil)
    pbSEPlay("Contests_Acting_Judge_Jump_Medium") if !muted
    
    #timer and variables for judge jumping
    bobY = 0
    timerY = 0
    bobDistance = 20
    bobSpeed = 0.16
    
    case judge[:ID]
    when 0
      judgeSprite = @sprites["judge_left"]
    when 1
      judgeSprite = @sprites["judge_center"]
    when 2
      judgeSprite = @sprites["judge_right"]
    end
    
    judgeStartY = judgeSprite.y
    loop do
      self.updateSprites
      bobY = Math.sin(timerY * bobSpeed) * bobDistance
      absBobY = bobY.abs
      judgeSprite.y = judgeStartY - absBobY.truncate
      timerY += 1
      
      if timerY >= (Graphics.frame_rate*0.5)
        judgeSprite.y = judgeStartY
        self.updateSprites
        break
      end #if timerY >= Graphics.frame_rate
    end #loop do
  end #def self.judgeReactMediumJump(judge)
    
    def self.judgeReactHighJump(judge)
    pbSEPlay("Contests_Acting_Judge_Jump_High")
    
    #timer and variables for judge jumping
    bobY = 0
    timerY = 0
    bobDistance = 40
    bobSpeed = 0.1#0.25#0.19635
    
    case judge[:ID]
    when 0
      judgeSprite = @sprites["judge_left"]
    when 1
      judgeSprite = @sprites["judge_center"]
    when 2
      judgeSprite = @sprites["judge_right"]
    end
    
    judgeStartY = judgeSprite.y
    loop do
      self.updateSprites
      bobY = Math.sin(timerY * bobSpeed) * bobDistance
      absBobY = bobY.abs
      judgeSprite.y = judgeStartY - absBobY.truncate
      timerY += 1
      
      if timerY >= Graphics.frame_rate*0.798
        judgeSprite.y = judgeStartY
        self.updateSprites
        break
      end #if timerY >= Graphics.frame_rate
    end #loop do
  end #def self.judgeReactHighJump(judge)

  #=====================
  # Change Voltage
  #=====================
  def self.increaseVoltage(judge, contestant)    
    #whose voltage are we changing?
    case judge[:ID]
    when 0
      voltageX = @sprites["judge_panel"].x + 7 + (64*0)
    when 1
      voltageX = @sprites["judge_panel"].x + 7 + (64*1)
    when 2
      voltageX = @sprites["judge_panel"].x + 7 + (64*2)
    end
    #increase the X of the voltage depending on judge[:Voltage]
    voltageX += 10*judge[:Voltage]
    
    #increase voltage by 1
    judge[:Voltage] +=1
    @judgeNumberThisTurnVoltageUp = judge[:ID]
    
    #display sprite    
    @sprites["judge#{judge[:ID]}voltage#{judge[:Voltage]}"] = AnimatedSprite.new("Graphics/Pictures/Contest/acting/voltage", 4, 10, 10, 0, @viewport)
    @sprites["judge#{judge[:ID]}voltage#{judge[:Voltage]}"].x = voltageX
    @sprites["judge#{judge[:ID]}voltage#{judge[:Voltage]}"].y = @sprites["judge_panel"].y + 16
    @sprites["judge#{judge[:ID]}voltage#{judge[:Voltage]}"].z = 999999
    @sprites["judge#{judge[:ID]}voltage#{judge[:Voltage]}"].play
    
    loop do
      self.updateSprites
      if @sprites["judge#{judge[:ID]}voltage#{judge[:Voltage]}"].frame == 3
        @sprites["judge#{judge[:ID]}voltage#{judge[:Voltage]}"].stop
        break
      end
    end
    
    pbSEPlay("Contests_Acting_Voltage")
    
    #check if hit 4 voltage
    #when a judge is at 4 voltage, a message appears saying "The audience is
    #getting pretty excited!"
    pbMessageContest(_INTL("The audience is getting pretty excited!")) if judge[:Voltage] == 4
    
    #check if hit max voltage (5)
    if judge[:Voltage] >= 5
      self.maxVoltage(judge, contestant)
      @judgeNumberVoltagePeakPreviousTurn = judge[:ID]
    end

  end #def self.increaseVoltage(judge)
  
  def self.maxVoltage(judge, contestant)
    #The Pokémon who fills the Voltage meter will receive a bonus from the Judge
    #they performed to: Keira and Jordan give +5, while Dexter gives +8
    #if max voltage is hit, the voltage sprites flash a few times and the game
    #says "The audience is going wild with excitement! <red>+#!</>"
    #There's different voltage sprite animation for max voltage hit
    if judge[:ID] == 1
      #second judge, main judge
      pointsAwarded = 8
    else
      pointsAwarded = 5
    end
    
    @msgwindow = pbMessageContest(_INTL("\\^\\ts[]The audience is going wild with excitement! <c3=E82010,F8A8B8>+#{pointsAwarded}</c3>!"), nil, 0, nil, 0, clear=false)
    
    #flash voltage star sprites
    5.times do
      loop do
        self.updateSprites
        @sprites["judge#{judge[:ID]}voltage1"].opacity -= 15
        @sprites["judge#{judge[:ID]}voltage2"].opacity -= 15
        @sprites["judge#{judge[:ID]}voltage3"].opacity -= 15
        @sprites["judge#{judge[:ID]}voltage4"].opacity -= 15
        @sprites["judge#{judge[:ID]}voltage5"].opacity -= 15
        break if @sprites["judge#{judge[:ID]}voltage1"].opacity <= 10
      end
      loop do
        @sprites["judge#{judge[:ID]}voltage1"].opacity += 15
        @sprites["judge#{judge[:ID]}voltage2"].opacity += 15
        @sprites["judge#{judge[:ID]}voltage3"].opacity += 15
        @sprites["judge#{judge[:ID]}voltage4"].opacity += 15
        @sprites["judge#{judge[:ID]}voltage5"].opacity += 15
        break if @sprites["judge#{judge[:ID]}voltage1"].opacity >= 255
      end
    end #5.times do
    
    #get the cardSprite to send the voltage sprites to
    cardSprite = self.getCardSprite(contestant)
    desiredX = cardSprite.width
    distanceToDesiredX = @sprites["judge#{judge[:ID]}voltage1"].x - desiredX
    speedToDesiredX = distanceToDesiredX/50 + 1
    desiredY = cardSprite.y + cardSprite.height/2
    distanceToDesiredY = @sprites["judge#{judge[:ID]}voltage1"].y + desiredY
    speedToDesiredY = distanceToDesiredY/50 + 1
    
    @sprites["judge#{judge[:ID]}voltage1"].viewport = @tilesViewport
    @sprites["judge#{judge[:ID]}voltage2"].viewport = @tilesViewport
    @sprites["judge#{judge[:ID]}voltage3"].viewport = @tilesViewport
    @sprites["judge#{judge[:ID]}voltage4"].viewport = @tilesViewport
    @sprites["judge#{judge[:ID]}voltage5"].viewport = @tilesViewport
    
    #move the voltage sprites one to the cardSprite
    sePlay = Graphics.frame_rate/2
    seTimesPlayed = 0
    timer = Graphics.frame_rate/2
    loop do
      self.updateSprites
      
      if sePlay >= Graphics.frame_rate && seTimesPlayed < 5
        pbSEPlay("Contests_Acting_Voltage_Float")
        seTimesPlayed += 1
        sePlay = 0
      end
      
      if timer >= Graphics.frame_rate && @sprites["judge#{judge[:ID]}voltage1"] && !@sprites["judge#{judge[:ID]}voltage1"].disposed?
        @sprites["judge#{judge[:ID]}voltage1"].x -= speedToDesiredX if @sprites["judge#{judge[:ID]}voltage1"].x > desiredX
        @sprites["judge#{judge[:ID]}voltage1"].y += speedToDesiredY if @sprites["judge#{judge[:ID]}voltage1"].y < desiredY
      end
      
      if timer >= Graphics.frame_rate*2 && @sprites["judge#{judge[:ID]}voltage2"] && !@sprites["judge#{judge[:ID]}voltage2"].disposed?
        @sprites["judge#{judge[:ID]}voltage2"].x -= speedToDesiredX if @sprites["judge#{judge[:ID]}voltage2"].x > desiredX
        @sprites["judge#{judge[:ID]}voltage2"].y += speedToDesiredY if @sprites["judge#{judge[:ID]}voltage2"].y < desiredY
      end
    
      if timer >= Graphics.frame_rate*3 && @sprites["judge#{judge[:ID]}voltage3"] && !@sprites["judge#{judge[:ID]}voltage3"].disposed?
        @sprites["judge#{judge[:ID]}voltage3"].x -= speedToDesiredX if @sprites["judge#{judge[:ID]}voltage3"].x > desiredX
        @sprites["judge#{judge[:ID]}voltage3"].y += speedToDesiredY if @sprites["judge#{judge[:ID]}voltage3"].y < desiredY
      end
      
      if timer >= Graphics.frame_rate*4 && @sprites["judge#{judge[:ID]}voltage4"] && !@sprites["judge#{judge[:ID]}voltage4"].disposed?
        @sprites["judge#{judge[:ID]}voltage4"].x -= speedToDesiredX if @sprites["judge#{judge[:ID]}voltage4"].x > desiredX
        @sprites["judge#{judge[:ID]}voltage4"].y += speedToDesiredY if @sprites["judge#{judge[:ID]}voltage4"].y < desiredY
      end
      
      if timer >= Graphics.frame_rate*5 && @sprites["judge#{judge[:ID]}voltage5"] && !@sprites["judge#{judge[:ID]}voltage5"].disposed?
        @sprites["judge#{judge[:ID]}voltage5"].x -= speedToDesiredX if @sprites["judge#{judge[:ID]}voltage5"].x > desiredX
        @sprites["judge#{judge[:ID]}voltage5"].y += speedToDesiredY if @sprites["judge#{judge[:ID]}voltage5"].y < desiredY
      end
      
      
      if @sprites["judge#{judge[:ID]}voltage1"] && !@sprites["judge#{judge[:ID]}voltage1"].disposed? && @sprites["judge#{judge[:ID]}voltage1"].x <= desiredX && @sprites["judge#{judge[:ID]}voltage1"].y >= desiredY
        @sprites["judge#{judge[:ID]}voltage1"].dispose
        pbSEPlay("Contests_Acting_Voltage_Hit_Card")
      end
      if @sprites["judge#{judge[:ID]}voltage2"] && !@sprites["judge#{judge[:ID]}voltage2"].disposed? && @sprites["judge#{judge[:ID]}voltage2"].x <= desiredX && @sprites["judge#{judge[:ID]}voltage2"].y >= desiredY
        @sprites["judge#{judge[:ID]}voltage2"].dispose
        pbSEPlay("Contests_Acting_Voltage_Hit_Card")
      end
      if @sprites["judge#{judge[:ID]}voltage3"] && !@sprites["judge#{judge[:ID]}voltage3"].disposed? && @sprites["judge#{judge[:ID]}voltage3"].x <= desiredX && @sprites["judge#{judge[:ID]}voltage3"].y >= desiredY
        @sprites["judge#{judge[:ID]}voltage3"].dispose
        pbSEPlay("Contests_Acting_Voltage_Hit_Card")
      end
      if @sprites["judge#{judge[:ID]}voltage4"] && !@sprites["judge#{judge[:ID]}voltage4"].disposed? && @sprites["judge#{judge[:ID]}voltage4"].x <= desiredX && @sprites["judge#{judge[:ID]}voltage4"].y >= desiredY
        @sprites["judge#{judge[:ID]}voltage4"].dispose
        pbSEPlay("Contests_Acting_Voltage_Hit_Card")
      end
      if @sprites["judge#{judge[:ID]}voltage5"] && !@sprites["judge#{judge[:ID]}voltage5"].disposed? && @sprites["judge#{judge[:ID]}voltage5"].x <= desiredX && @sprites["judge#{judge[:ID]}voltage5"].y >= desiredY
        @sprites["judge#{judge[:ID]}voltage5"].dispose
        pbSEPlay("Contests_Acting_Voltage_Hit_Card")
      end

      timer += 1
      sePlay += 1
      
      if @sprites["judge#{judge[:ID]}voltage1"].disposed? && @sprites["judge#{judge[:ID]}voltage2"].disposed? && @sprites["judge#{judge[:ID]}voltage3"].disposed? && @sprites["judge#{judge[:ID]}voltage4"].disposed? && @sprites["judge#{judge[:ID]}voltage5"].disposed?
        pbWait(1 * Graphics.frame_rate/2)
        break
      end
    end
    
    pointsAwarded.times do
      contestant[:CurrentRoundHearts] += 1
      self.addAppealHeartSprite(contestant)
    end #pointsAwarded.times do
    
    self.resetVoltage(judge)
  end #self.maxVoltage(judge, contestant)
  
  def self.decreaseVoltage(judge)
    #negative reaction since move type opposes contest type
    #if an opposingmove is made but voltage is 0, no reaction is given at
    #all
    if judge[:Voltage] > 0
      #delete last voltage sprite for that judge
      @sprites["judge#{judge[:ID]}voltage#{judge[:Voltage]}"].dispose
      pbSEPlay("Contests_Acting_Judge_Shudder", 100)
      judge[:Voltage] -=1
      @judgeNumberThisTurnVoltageUp = nil
    end
  end #def self.decreaseVoltage(judge)
  
  def self.resetVoltage(judge)
    #dispose that's judge's voltage sprites
    i = 0
    5.times do
      i += 1
      if @sprites["judge#{judge[:ID]}voltage#{i}"] && !@sprites["judge#{judge[:ID]}voltage#{i}"].disposed?
        @sprites["judge#{judge[:ID]}voltage#{i}"].dispose
      end #if @sprites["judge#{judge[:ID]}voltage#{i}"]
    end #5.times do
    judge[:Voltage] = 0
  end #def self.resetVoltage(judge)
  
  #=====================
  # Award Appeal
  #=====================
  def self.awardMoveAppealHearts(move, contestant)
    appeal = self.getAppeal(move)
    #contestant[:CurrentRoundHearts] += appeal
    appeal.times do
      contestant[:CurrentRoundHearts] += 1
      self.addAppealHeartSprite(contestant)
    end
  end #def self.awardMoveAppealHearts(move, contestant)
  
  def self.awardEffectAppealHearts(contestant)
    #contestant[:CurrentRoundHearts] += @effectAppeal
    @effectAppeal.times do
      contestant[:CurrentRoundHearts] += 1
      self.addAppealHeartSprite(contestant)
    end    
  end #def self.awardMoveAppealHearts(move, contestant)
  
  def self.pullUpContestant(contestant)
    pkmnSpecies = contestant[:PkmnSpecies]
    pkmnGender = contestant[:PkmnGender]
    pkmnForm = contestant[:PkmnForm]
    pkmnShiny = contestant[:PkmnShiny]
    
    @sprites["pkmn"] = PokemonSprite.new(@viewport)
    @sprites["pkmn"].setSpeciesBitmap(pkmnSpecies, pkmnGender, pkmnForm, pkmnShiny, false, true)
    @sprites["pkmn"].setOffset(PictureOrigin::CENTER)
    @sprites["pkmn"].mirror = true
    @sprites["pkmn"].x = Graphics.width
    @sprites["pkmn"].y = @sprites["message_box"].y
    @sprites["pkmn"].z = 99998
    
    desiredX = Graphics.width-@sprites["pkmn"].width/2
    desiredY = @sprites["message_box"].y - @sprites["pkmn"].height/2
    
    loop do
      self.updateSprites
      @sprites["pkmn"].x -= 8 if @sprites["pkmn"].x > desiredX
      @sprites["pkmn"].y -= 8 if @sprites["pkmn"].y > desiredY
      if @sprites["pkmn"].x <= desiredX && @sprites["pkmn"].y <= desiredY
        break
      end
    end
    
    pbSEPlay("Contests_Dance_Swap_Dancers2") if contestant == @chosenContestants[3]
  end #def self.pullUpContestant(contestant)
  
  def self.pullBackContestant(contestant)
    pkmnSpecies = contestant[:PkmnSpecies]
    pkmnGender = contestant[:PkmnGender]
    pkmnForm = contestant[:PkmnForm]
    pkmnShiny = contestant[:PkmnShiny]
    
    desiredX = Graphics.width + @sprites["pkmn"].width/2
    desiredY = Graphics.height #@sprites["message_box"].y
    
    loop do
      self.updateSprites
      @sprites["pkmn"].x += 8 if @sprites["pkmn"].x < desiredX
      @sprites["pkmn"].y += 8 if @sprites["pkmn"].y < desiredY
      if @sprites["pkmn"].x >= desiredX && @sprites["pkmn"].y >= desiredY
        break
      end
    end
  end #def self.pullBackContestant(contestant)
end #class Acting