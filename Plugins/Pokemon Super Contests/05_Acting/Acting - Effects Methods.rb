class Acting
  #=============================================
  # Pre Move Effects
  #=============================================
  def self.preMoveEffect(move, contestant, judge)
    #get the effect of the move
    effect = self.getEffect(move, "effectCode")
    case effect
    #=====================
    # Plus3IfNoPokemonChoseJudge
    #=====================
    when "Plus3IfNoPokemonChoseJudge"
      pbMessageContest(_INTL("If #{contestant[:PkmnName]}'s move stands out and doesn't share the same Judge with another Pokémon: <c3=E82010,F8A8B8>+3</c3>!"))
    end #case effect
    
    if @msgwindow
      #clear message window that stayed on the screen during the effect
      #announcement
      @msgwindow.text = ""
    end
  end #def self.preMoveEffect(move, contestant, judge)
  
  #=============================================
  # After Move Effects
  #=============================================
  def self.afterMoveEffect(move, contestant, judge)
    #get the effect of the move
    effect = self.getEffect(move, "effectCode")
    case effect
    #=====================
    # RandomOrder
    #=====================
    when "RandomOrder"
      temp = @contestant_order.clone
      @nextRoundContestantOrder = temp.shuffle
      #set every contestant's ShowTurnOrder to true
      for i in 0...@nextRoundContestantOrder.length
        @nextRoundContestantOrder[i][:ShowTurnOrder] = true
      end #for i in 0...@nextRoundContestantOrder.length
      self.updateNextSprites
    #=====================
    # Next1
    #=====================
    when "Next1"
      if @nextRoundContestantOrder.include?(contestant)
        #if already in the array, remove it
        @nextRoundContestantOrder.delete(contestant)
        #then put it at the front
        @nextRoundContestantOrder.insert(0, contestant)
      else
        #if not in the array yet, insert it at the beginning and delete the
        #first "" in the array
        @nextRoundContestantOrder.insert(0, contestant)
        #searching for any ""
        for k in 0...@nextRoundContestantOrder.length
          if @nextRoundContestantOrder[k] == ""
            @nextRoundContestantOrder.delete_at(k)
            break
          end #if @nextRoundContestantOrder[k] == ""
        end #for k in 0...@nextRoundContestantOrder.length
      end #if @nextRoundContestantOrder.include?(contestant)
      
      #we need to update both the passed variable contestant's hash values and
      #the @nextRoundContestantOrder[0] hash values so the hashes match
      #during order sorting
      @nextRoundContestantOrder[0][:CurrentRoundHearts] = contestant[:CurrentRoundHearts]
      contestant[:ShowTurnOrder] = true
      @nextRoundContestantOrder[0][:ShowTurnOrder] = true
      @msgwindow = pbMessageContest(_INTL("\\^\\ts[]#{contestant[:PkmnName]} will perform first the next turn."), nil, 0, nil, 0, clear=false)
      pbWait(1 * Graphics.frame_rate)
      self.updateNextSprites
    #=====================
    # Next4
    #=====================
    when "Next4"
      if @nextRoundContestantOrder.include?(contestant)
        #if already in the array, remove it
        @nextRoundContestantOrder.delete(contestant)
        #then put it at the front
        @nextRoundContestantOrder.push(contestant)
      else
        #if not in the array yet, insert it at the beginning and delete the
        #first "" in the array
        @nextRoundContestantOrder.push(contestant)
        #searching for any ""
        @nextRoundContestantOrder.reverse!
        for k in 0...@nextRoundContestantOrder.length
          if @nextRoundContestantOrder[k] == ""
            @nextRoundContestantOrder.delete_at(k)
            break
          end #if @nextRoundContestantOrder[k] == ""
        end #for k in 0...@nextRoundContestantOrder.length
        @nextRoundContestantOrder.reverse!
      end #if @nextRoundContestantOrder.include?(contestant)
      
      #we need to update both the passed variable contestant's hash values and
      #the @nextRoundContestantOrder[-1] hash values so the hashes match
      #during order sorting
      @nextRoundContestantOrder[-1][:CurrentRoundHearts] = contestant[:CurrentRoundHearts]
      contestant[:ShowTurnOrder] = true
      @nextRoundContestantOrder[-1][:ShowTurnOrder] = true
      @msgwindow = pbMessageContest(_INTL("\\^\\ts[]#{contestant[:PkmnName]} will perform last the next turn."), nil, 0, nil, 0, clear=false)
      pbWait(1 * Graphics.frame_rate)
      self.updateNextSprites
    #=====================
    # Plus2IfFirst
    #=====================
    when "Plus2IfFirst"
      if @contestantTurn == 1
        #award 2 more appeal
        #First performance! Plus 2!
        #the message box does not wait, and the hearts appear
        @msgwindow = pbMessageContest(_INTL("\\^\\ts[]First performance! <c3=E82010,F8A8B8>+2</c3>!"), nil, 0, nil, 0, clear=false)
        #then comes the judge reaction without needing player input on the message
        @effectAppeal = 2
        self.awardEffectAppealHearts(contestant)
        pbWait(1 * Graphics.frame_rate)
      end
    #=====================
    # Plus2IfLast
    #=====================
    when "Plus2IfLast"
      if @contestantTurn == 4
        #award 2 more appeal
        #Last performance! Plus 2!
        #the message box does not wait, and the hearts appear
        @msgwindow = pbMessageContest(_INTL("\\^\\ts[]Last performance! <c3=E82010,F8A8B8>+2</c3>!"), nil, 0, nil, 0, clear=false)
        #then comes the judge reaction without needing player input on the message
        @effectAppeal = 2
        self.awardEffectAppealHearts(contestant)
        pbWait(1 * Graphics.frame_rate)
      end
    #=====================
    # CanPerformMoveTwiceInARow
    #=====================
    when "CanPerformMoveTwiceInARow"
      if contestant[:MovePerformedTwoTurnsAgo] != contestant[:MoveLastPerformed]
        @msgwindow = pbMessageContest(_INTL("\\^\\ts[]#{contestant[:PkmnName]} can perform the same move twice!"), nil, 0, nil, 0, clear=false)
        pbWait(1 * Graphics.frame_rate)
      end
    #=====================
    # IncreasedVoltageAddedToScore
    #=====================
    when "IncreasedVoltageAddedToScore"
      #"The Voltage score is added on! <red>+X</>!" X is the voltage points
      #before the voltage increases
      if judge[:Voltage] > 0
        @msgwindow = pbMessageContest(_INTL("\\^\\ts[]The Voltage score is added on! <c3=E82010,F8A8B8>+#{judge[:Voltage]}!"), nil, 0, nil, 0, clear=false)
        pbWait(1 * Graphics.frame_rate)
        judge[:Voltage].times do
          contestant[:CurrentRoundHearts] += 1
          self.addAppealHeartSprite(contestant)
        end #judge[:Voltage].times do
      end #judge[:Voltage] > 0
    #=====================
    # PreventVoltageDownSameTurn
    #=====================
    when "PreventVoltageDownSameTurn"
      if @voltagePreventDown != true
        @voltagePreventDown = true
        @msgwindow = pbMessageContest(_INTL("\\^\\ts[]The Voltage is prevented from falling!"), nil, 0, nil, 0, clear=false)
        pbWait(1 * Graphics.frame_rate)
      end
    #=====================
    # PreventVoltageUpSameTurn
    #=====================
    when "PreventVoltageUpSameTurn"
      if @voltagePreventUp != true
        @voltagePreventUp = true
        @msgwindow = pbMessageContest(_INTL("\\^\\ts[]The Voltage is prevented from rising!"), nil, 0, nil, 0, clear=false)
        pbWait(1 * Graphics.frame_rate)
      end
    #=====================
    # HigherScoreTheLaterPerforms
    #=====================
    when "HigherScoreTheLaterPerforms"
      case @contestantTurn
      when 1
        order = "first"
      when 2
        order = "second"
      when 3
        order = "third"
      when 4
        order = "fourth"
      end
      @msgwindow = pbMessageContest(_INTL("\\^\\ts[]#{contestant[:PkmnName]}'s performance is #{order}! <c3=E82010,F8A8B8>+#{@contestantTurn}!"), nil, 0, nil, 0, clear=false)
      pbWait(1 * Graphics.frame_rate)
      @contestantTurn.times do
        contestant[:CurrentRoundHearts] += 1
        self.addAppealHeartSprite(contestant)
      end #@contestantTurn.times do
    #=====================
    # PointsEqualToOrder
    #=====================
    when "PointsEqualToOrder"
      case @contestantTurn
      when 1
        order = "first"
      when 2
        order = "second"
      when 3
        order = "third"
      when 4
        order = "fourth"
      end
      @msgwindow = pbMessageContest(_INTL("\\^\\ts[]#{contestant[:PkmnName]}'s performance is #{order}! <c3=E82010,F8A8B8>+#{@contestantTurn}!"), nil, 0, nil, 0, clear=false)
      pbWait(1 * Graphics.frame_rate)
      @contestantTurn.times do
        contestant[:CurrentRoundHearts] += 1
        self.addAppealHeartSprite(contestant)
      end #@contestantTurn.times do
    #=====================
    # LowerVoltageOfAllJudges1
    #=====================
    when "LowerVoltageOfAllJudges1"
      if @voltagePreventDown != true
        @msgwindow = pbMessageContest(_INTL("\\^\\ts[]The Voltage of all the Judges went down!"), nil, 0, nil, 0, clear=false)
        pbWait(1 * Graphics.frame_rate)
        for i in 0...ContestSettings::JUDGES.length
          judge = ContestSettings::JUDGES[i]
          self.decreaseVoltage(judge)
        end
        pbWait(1 * Graphics.frame_rate)
      end #if @voltagePreventDown != true
    #=====================
    # RaiseScoreIfVoltageLow
    #=====================
    when "RaiseScoreIfVoltageLow"
      pointsAwarded = 4 - judge[:Voltage]
      @msgwindow = pbMessageContest(_INTL("\\^\\ts[]Higher score earned for low Voltage! <c3=E82010,F8A8B8>+#{pointsAwarded.abs}</c3>!"), nil, 0, nil, 0, clear=false)
      pbWait(1 * Graphics.frame_rate)
      pointsAwarded.abs.times do
        contestant[:CurrentRoundHearts] += 1
        self.addAppealHeartSprite(contestant)
      end #pointsAwarded.times do
    #=====================
    # DoubleScoreIfFinalTurn
    #=====================
    when "DoubleScoreIfFinalTurn"  
      if @contestantTurn == 4
        @msgwindow = pbMessageContest(_INTL("\\^\\ts[]#{contestant[:PkmnName]} performed last! <c3=E82010,F8A8B8>+#{contestant[:CurrentRoundHearts]}</c3>!"), nil, 0, nil, 0, clear=false)
        pbWait(1 * Graphics.frame_rate)
        contestant[:CurrentRoundHearts].times do
          contestant[:CurrentRoundHearts] += 1
          self.addAppealHeartSprite(contestant)
        end #contestant[:CurrentRoundHearts].times do
      end #if @contestantTurn == 4
    #=====================
    # StealVoltagePreviousPokemon
    #=====================
    when "StealVoltagePreviousPokemon"
      #if a judge's voltage peaked last turn at all and that judge is the same
      #one the contestant just performed to
      if @judgeNumberVoltagePeakPreviousTurn == judge[:ID]
        #get the name of the pkmn who maxed the voltage
        previousPkmnName = @contestant_order[@contestantTurn-2][:PkmnName]
        
        @msgwindow = pbMessageContest(_INTL("\\^\\ts[]#{contestant[:PkmnName]} got the same rating as #{previousPkmnName}, who went before!"), nil, 0, nil, 0, clear=false)
        
        if judge[:ID] == 1
          #second judge, main judge
          pointsAwarded = 8
        else
          pointsAwarded = 5
        end
        
        pbWait(1 * Graphics.frame_rate)
        pointsAwarded.times do
          contestant[:CurrentRoundHearts] += 1
          self.addAppealHeartSprite(contestant)
        end #pointsAwarded.times do
      end #if @judgeNumberVoltagePeakPreviousTurn == judge[:ID]
    #=====================
    # Plus3IfPreviousPokemonHitMaxVoltage
    #=====================
    when "Plus3IfPreviousPokemonHitMaxVoltage"
      if @judgeNumberVoltagePeakPreviousTurn != nil
        @msgwindow = pbMessageContest(_INTL("\\^\\ts[]The performance came after the Voltage peaked! <c3=E82010,F8A8B8>+3</c3>!"), nil, 0, nil, 0, clear=false)
        pbWait(1 * Graphics.frame_rate)
        3.times do
          contestant[:CurrentRoundHearts] += 1
          self.addAppealHeartSprite(contestant)
        end #3.times do
      end #if @judgeNumberVoltagePeakPreviousTurn != nil
      
    end #case effect
    
    if @msgwindow
      #clear message window that stayed on the screen during the effect
      #announcement
      @msgwindow.text = ""
    end
    
    
    ###################Perform this as the last after-move effect
    #give extra hearts if an effect was active from the previous turn that gives
    #more appeal here
    if contestant[:MoveLastPerformed] != ""
      tempMove = GameData::Move.get(contestant[:MoveLastPerformed])
      lastTurnEffect = self.getEffect(tempMove, "effectCode")
    
      case lastTurnEffect
      #=====================
      # DoubleScoreNextTurn
      #=====================
      when "DoubleScoreNextTurn"
        #give what was earned this turn
        currentHearts = contestant[:CurrentRoundHearts]
        if currentHearts > 0
          @msgwindow = pbMessageContest(_INTL("\\^\\ts[]From the previous turn, #{contestant[:PkmnName]} gets <c3=E82010,F8A8B8>+#{currentHearts}!"), nil, 0, nil, 0, clear=false)
          pbWait(1 * Graphics.frame_rate)
          currentHearts.times do
            contestant[:CurrentRoundHearts] += 1
            self.addAppealHeartSprite(contestant)
          end #currentHearts.times do
        end #currentHearts > 0
    
        
      end #case lastTurnEffect
      
      if @msgwindow
        #clear message window that stayed on the screen during the effect
        #announcement
        @msgwindow.text = ""
      end
    end #if contestant[:MoveLastPerformed] != ""
  end #def self.immediateEffect(move, contestant)
  
  #=============================================
  # After Voltage Effects
  #=============================================
  def self.afterVoltageEffects(move, contestant)
    effect = self.getEffect(move, "effectCode")
    
    case effect
    #=====================
    # Plus3If2VoltageInARow
    #=====================
    when "Plus3If2VoltageInARow"
      if @judgeNumberPreviousTurnVoltageUp == @judgeNumberThisTurnVoltageUp && @judgeNumberThisTurnVoltageUp != nil
        @msgwindow = pbMessageContest(_INTL("\\^\\ts[]The Voltage went up consecutively! <c3=E82010,F8A8B8>+3</c3>!"), nil, 0, nil, 0, clear=false)
        pbWait(1 * Graphics.frame_rate)
        3.times do
          contestant[:CurrentRoundHearts] += 1
          self.addAppealHeartSprite(contestant)
        end #3.times do
      end #if @judgeNumberPreviousTurnVoltageUp
    #=====================
    # Plus2IfVoltageUp
    #=====================
    when "Plus2IfVoltageUp"
      if @judgeNumberThisTurnVoltageUp != nil
        @msgwindow = pbMessageContest(_INTL("\\^\\ts[]It excited the audience! <c3=E82010,F8A8B8>+2</c3>!"), nil, 0, nil, 0, clear=false)
        pbWait(1 * Graphics.frame_rate)
        2.times do
          contestant[:CurrentRoundHearts] += 1
          self.addAppealHeartSprite(contestant)
        end #2.times do
      end #if @judgeNumberThisTurnVoltageUp != nil
    
    end #effect
    
    if @msgwindow
      #clear message window that stayed on the screen during the effect
      #announcement
      @msgwindow.text = ""
    end
  end #def self.afterVoltageEffects(move, contestant)
  
  #=============================================
  # After Bonus Effects
  #=============================================
  def self.afterBonusEffects
    #these effects play at the end of the round after everyone has performed a
    #move, after any bonus points are given
    #it works off of contestant[:MoveLastPerformed]
    for i in 0...@contestant_order.length
      tempMove = GameData::Move.get(@contestant_order[i][:MoveLastPerformed])
      effect = self.getEffect(tempMove, "effectCode")
      
      case effect
      #=====================
      # Plus3IfNoPokemonChoseJudge
      #=====================
      when "Plus3IfNoPokemonChoseJudge"
        #what judge did this pokemon perform to?
        judgeID = @contestant_order[i][:JudgeLastPerformedTo]
        if ContestSettings::JUDGES[judgeID][:TimesPerformedTo] > 1
          #judge was performed to more than once
          pbMessageContest(_INTL("#{@contestant_order[i][:PkmnName]} chose the same Judge as another Pokémon!"))
          pbMessageContest(_INTL("The performance didn't stand out! <c3=E82010,F8A8B8>+0!"))
          #@msgwindow = pbMessageContest(_INTL("\\^\\ts[]The performance didn't stand out! <c3=E82010,F8A8B8>+0!"), nil, 0, nil, 0, clear=false)
          #pbWait(1 * Graphics.frame_rate)
        else
          #only this contestant performed for this judge
          pbMessageContest(_INTL("#{@contestant_order[i][:PkmnName]} didn't pick the same Judge as anyone else!"))
          pbMessageContest(_INTL("The performance stood out! <c3=E82010,F8A8B8>+3</c3>!"))
          #@msgwindow = pbMessageContest(_INTL("\\^\\ts[]The performance stood out! <c3=E82010,F8A8B8>+3</c3>!"), nil, 0, nil, 0, clear=false)
          #pbWait(1 * Graphics.frame_rate)
          3.times do
            @contestant_order[i][:CurrentRoundHearts] += 1
            self.addAppealHeartSprite(@contestant_order[i])
          end #3.times do
        end #if ContestSettings::JUDGES[judgeID][:TimesPerformedTo] > 1
      #=====================
      # Plus15IfAllChoseSameJudge
      #=====================
      when "Plus15IfAllChoseSameJudge"
        #what judge did this pokemon perform to?
        judgeID = @contestant_order[i][:JudgeLastPerformedTo]
        if ContestSettings::JUDGES[judgeID][:TimesPerformedTo] >= 4
          pbMessageContest(_INTL("#{@contestant_order[i][:PkmnName]} chose the same Judge as everyone! <c3=E82010,F8A8B8>+15</c3>!"))
          15.times do
            @contestant_order[i][:CurrentRoundHearts] += 1
            self.addAppealHeartSprite(@contestant_order[i])
          end #15.times do
        end #if ContestSettings::JUDGES[judgeID][:TimesPerformedTo] >= 4
        
      end #effect
      
      if @msgwindow
        #clear message window that stayed on the screen during the effect
        #announcement
        @msgwindow.text = ""
      end
    end #for i in 0...@contestant_order.length
    
    #=====================
    # Plus3IfGetLowestScore
    #=====================
    #if the @contestant_order[i] has the lowest [:CurrentRoundHearts],
    #they get +3
    #if it's a tie, they get the points
    
    #=====================
    # @contestant_order[0]
    #=====================
    #this effect must be run last after absolutely all other effects
    tempMove = GameData::Move.get(@contestant_order[0][:MoveLastPerformed])
    effect = self.getEffect(tempMove, "effectCode")
    
    if effect == "Plus3IfGetLowestScore"
      if @contestant_order[0][:CurrentRoundHearts] <= @contestant_order[1][:CurrentRoundHearts] && @contestant_order[0][:CurrentRoundHearts] <= @contestant_order[2][:CurrentRoundHearts] && @contestant_order[0][:CurrentRoundHearts] <= @contestant_order[3][:CurrentRoundHearts]
        @msgwindow = pbMessageContest(_INTL("\\^\\ts[]#{@contestant_order[0][:PkmnName]} has the lowest score! <c3=E82010,F8A8B8>+3</c3>!"), nil, 0, nil, 0, clear=false)
        pbWait(1 * Graphics.frame_rate)
        3.times do
          @contestant_order[0][:CurrentRoundHearts] += 1
          self.addAppealHeartSprite(@contestant_order[0])
        end #3.times do
      end #if @contestant_order[0][:CurrentRoundHearts] <= 
    end #if effect == "Plus3IfGetLowestScore"
    
    #=====================
    # @contestant_order[1]
    #=====================
    #this effect must be run last after absolutely all other effects
    tempMove = GameData::Move.get(@contestant_order[1][:MoveLastPerformed])
    effect = self.getEffect(tempMove, "effectCode")
    
    if effect == "Plus3IfGetLowestScore"
      if @contestant_order[1][:CurrentRoundHearts] <= @contestant_order[0][:CurrentRoundHearts] && @contestant_order[1][:CurrentRoundHearts] <= @contestant_order[2][:CurrentRoundHearts] && @contestant_order[1][:CurrentRoundHearts] <= @contestant_order[3][:CurrentRoundHearts]
        @msgwindow = pbMessageContest(_INTL("\\^\\ts[]#{@contestant_order[1][:PkmnName]} has the lowest score! <c3=E82010,F8A8B8>+3</c3>!"), nil, 0, nil, 0, clear=false)
        pbWait(1 * Graphics.frame_rate)
        3.times do
          @contestant_order[1][:CurrentRoundHearts] += 1
          self.addAppealHeartSprite(@contestant_order[1])
        end #3.times do
      end #if @contestant_order[1][:CurrentRoundHearts] <= 
    end #if effect == "Plus3IfGetLowestScore"
    
    #=====================
    # @contestant_order[2]
    #=====================
    #this effect must be run last after absolutely all other effects
    tempMove = GameData::Move.get(@contestant_order[2][:MoveLastPerformed])
    effect = self.getEffect(tempMove, "effectCode")
    
    if effect == "Plus3IfGetLowestScore"
      if @contestant_order[2][:CurrentRoundHearts] <= @contestant_order[0][:CurrentRoundHearts] && @contestant_order[2][:CurrentRoundHearts] <= @contestant_order[1][:CurrentRoundHearts] && @contestant_order[2][:CurrentRoundHearts] <= @contestant_order[3][:CurrentRoundHearts]
        @msgwindow = pbMessageContest(_INTL("\\^\\ts[]#{@contestant_order[2][:PkmnName]} has the lowest score! <c3=E82010,F8A8B8>+3</c3>!"), nil, 0, nil, 0, clear=false)
        pbWait(1 * Graphics.frame_rate)
        3.times do
          @contestant_order[2][:CurrentRoundHearts] += 1
          self.addAppealHeartSprite(@contestant_order[2])
        end #3.times do
      end #if @contestant_order[2][:CurrentRoundHearts] <= 
    end #if effect == "Plus3IfGetLowestScore"
    
    #=====================
    # @contestant_order[3]
    #=====================
    #this effect must be run last after absolutely all other effects
    tempMove = GameData::Move.get(@contestant_order[3][:MoveLastPerformed])
    effect = self.getEffect(tempMove, "effectCode")
    
    if effect == "Plus3IfGetLowestScore"
      if @contestant_order[3][:CurrentRoundHearts] <= @contestant_order[0][:CurrentRoundHearts] && @contestant_order[3][:CurrentRoundHearts] <= @contestant_order[1][:CurrentRoundHearts] && @contestant_order[3][:CurrentRoundHearts] <= @contestant_order[2][:CurrentRoundHearts]
        @msgwindow = pbMessageContest(_INTL("\\^\\ts[]#{@contestant_order[3][:PkmnName]} has the lowest score! <c3=E82010,F8A8B8>+3</c3>!"), nil, 0, nil, 0, clear=false)
        pbWait(1 * Graphics.frame_rate)
        3.times do
          @contestant_order[3][:CurrentRoundHearts] += 1
          self.addAppealHeartSprite(@contestant_order[3])
        end #3.times do
      end #if @contestant_order[3][:CurrentRoundHearts] <= 
    end #if effect == "Plus3IfGetLowestScore"

    if @msgwindow
      #clear message window that stayed on the screen during the effect
      #announcement
      @msgwindow.text = ""
    end
      
  end #def self.afterBonusEffects
  
  
end #class Acting