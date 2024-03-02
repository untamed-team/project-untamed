class Acting

  def self.giveBonusPoints
    #At the end of each round, the Judges award extra points to the Pokémon:
    #3 points if only one Pokémon performed to them
    #2 points each if two Pokémon performed to them
    #1 point apiece if three Pokémon performed to them
    #none if all Pokémon performed to them
    
    #if judge was performed to three times:
    #tiny jump
    #"Jordan was impressed by the performances of NAME, NAME, and NAME! <red>+1</>!"
    
    #if judge was performed to twice:
    #medium jump
    #Jordan was strongly impressed by the acting of Sparky and Merry! (in red) +2 (not in red)!
    
    #if judge was performed to once:
    #high jump
    #Dexter was very impressed by Precious's performance! (red)+3(not red)!
    
    performedToJudge0 = []
    performedToJudge1 = []
    performedToJudge2 = []
    
    for i in 0...@contestant_order.length
      performedToJudge0.push(@contestant_order[i]) if @contestant_order[i][:JudgeLastPerformedTo] == 0
      performedToJudge1.push(@contestant_order[i]) if @contestant_order[i][:JudgeLastPerformedTo] == 1
      performedToJudge2.push(@contestant_order[i]) if @contestant_order[i][:JudgeLastPerformedTo] == 2
    end #for i in 0...@contestant_order.length
    
    #=====================
    # Judge0
    #=====================
    case performedToJudge0.length
    when 1
      #high jump
      self.judgeReactHighJump(ContestSettings::JUDGES[0])
      pbMessageContest(_INTL("#{ContestSettings::JUDGES[0][:Name]} was very impressed by #{performedToJudge0[0][:PkmnName]}'s performance! <c3=E82010,F8A8B8>+3</c3>!"))
      3.times do
        performedToJudge0[0][:CurrentRoundHearts] += 1
        self.addAppealHeartSprite(performedToJudge0[0])
      end
    when 2
      #medium jump
      self.judgeReactMediumJump(ContestSettings::JUDGES[0])
      pbMessageContest(_INTL("#{ContestSettings::JUDGES[0][:Name]} was strongly impressed by the acting of #{performedToJudge0[0][:PkmnName]} and #{performedToJudge0[1][:PkmnName]}! <c3=E82010,F8A8B8>+2</c3>!"))
      2.times do
        performedToJudge0[0][:CurrentRoundHearts] += 1
        self.addAppealHeartSprite(performedToJudge0[0])
      end
      pbWait(1 * Graphics.frame_rate/4)
      2.times do
        performedToJudge0[1][:CurrentRoundHearts] += 1
        self.addAppealHeartSprite(performedToJudge0[1])
      end
    when 3
      #low jump
      self.judgeReactLowJump(ContestSettings::JUDGES[0])
      pbMessageContest(_INTL("#{ContestSettings::JUDGES[0][:Name]} was impressed by the performances of #{performedToJudge0[0][:PkmnName]}, #{performedToJudge0[1][:PkmnName]}, and #{performedToJudge0[2][:PkmnName]}! <c3=E82010,F8A8B8>+1</c3>!"))
      performedToJudge0[0][:CurrentRoundHearts] += 1
      self.addAppealHeartSprite(performedToJudge0[0])
      pbWait(1 * Graphics.frame_rate/4)
      performedToJudge0[1][:CurrentRoundHearts] += 1
      self.addAppealHeartSprite(performedToJudge0[1])
      pbWait(1 * Graphics.frame_rate/4)
      performedToJudge0[2][:CurrentRoundHearts] += 1
      self.addAppealHeartSprite(performedToJudge0[2])
    when 4
      #no jump
      #shudder sound
      pbSEPlay("Contests_Acting_Judge_Shudder", 100)
      pbMessageContest(_INTL("Everyone performed for #{ContestSettings::JUDGES[0][:Name]}..."))
      pbMessageContest(_INTL("And watered down the Judge's impressions."))
      #no hearts awarded
    end #case performedToJudge0.length
    
    #=====================
    # Judge1
    #=====================
    case performedToJudge1.length
    when 1
      #high jump
      self.judgeReactHighJump(ContestSettings::JUDGES[1])
      pbMessageContest(_INTL("#{ContestSettings::JUDGES[1][:Name]} was very impressed by #{performedToJudge1[0][:PkmnName]}'s performance! <c3=E82010,F8A8B8>+3</c3>!"))
      3.times do
        performedToJudge1[0][:CurrentRoundHearts] += 1
        self.addAppealHeartSprite(performedToJudge1[0])
      end
    when 2
      #medium jump
      self.judgeReactMediumJump(ContestSettings::JUDGES[1])
      pbMessageContest(_INTL("#{ContestSettings::JUDGES[1][:Name]} was strongly impressed by the acting of #{performedToJudge1[0][:PkmnName]} and #{performedToJudge1[1][:PkmnName]}! <c3=E82010,F8A8B8>+2</c3>!"))
      2.times do
        performedToJudge1[0][:CurrentRoundHearts] += 1
        self.addAppealHeartSprite(performedToJudge1[0])
      end
      pbWait(1 * Graphics.frame_rate/4)
      2.times do
        performedToJudge1[1][:CurrentRoundHearts] += 1
        self.addAppealHeartSprite(performedToJudge1[1])
      end
    when 3
      #low jump
      self.judgeReactLowJump(ContestSettings::JUDGES[1])
      pbMessageContest(_INTL("#{ContestSettings::JUDGES[1][:Name]} was impressed by the performances of #{performedToJudge1[0][:PkmnName]}, #{performedToJudge1[1][:PkmnName]}, and #{performedToJudge1[2][:PkmnName]}! <c3=E82010,F8A8B8>+1</c3>!"))
      performedToJudge1[0][:CurrentRoundHearts] += 1
      self.addAppealHeartSprite(performedToJudge1[0])
      pbWait(1 * Graphics.frame_rate/4)
      performedToJudge1[1][:CurrentRoundHearts] += 1
      self.addAppealHeartSprite(performedToJudge1[1])
      pbWait(1 * Graphics.frame_rate/4)
      performedToJudge1[2][:CurrentRoundHearts] += 1
      self.addAppealHeartSprite(performedToJudge1[2])
    when 4
      #no jump
      #shudder sound
      pbSEPlay("Contests_Acting_Judge_Shudder", 100)
      pbMessageContest(_INTL("Everyone performed for #{ContestSettings::JUDGES[1][:Name]}..."))
      pbMessageContest(_INTL("And watered down the Judge's impressions."))
      #no hearts awarded
    end #case performedToJudge1.length
    
    #=====================
    # Judge2
    #=====================
    case performedToJudge2.length
    when 1
      #high jump
      self.judgeReactHighJump(ContestSettings::JUDGES[2])
      pbMessageContest(_INTL("#{ContestSettings::JUDGES[2][:Name]} was very impressed by #{performedToJudge2[0][:PkmnName]}'s performance! <c3=E82010,F8A8B8>+3</c3>!"))
      3.times do
        performedToJudge2[0][:CurrentRoundHearts] += 1
        self.addAppealHeartSprite(performedToJudge2[0])
      end
    when 2
      #medium jump
      self.judgeReactMediumJump(ContestSettings::JUDGES[2])
      pbMessageContest(_INTL("#{ContestSettings::JUDGES[2][:Name]} was strongly impressed by the acting of #{performedToJudge2[0][:PkmnName]} and #{performedToJudge2[1][:PkmnName]}! <c3=E82010,F8A8B8>+2</c3>!"))
      2.times do
        performedToJudge2[0][:CurrentRoundHearts] += 1
        self.addAppealHeartSprite(performedToJudge2[0])
      end
      pbWait(1 * Graphics.frame_rate/4)
      2.times do
        performedToJudge2[1][:CurrentRoundHearts] += 1
        self.addAppealHeartSprite(performedToJudge2[1])
      end
    when 3
      #low jump
      self.judgeReactLowJump(ContestSettings::JUDGES[2])
      pbMessageContest(_INTL("#{ContestSettings::JUDGES[2][:Name]} was impressed by the performances of #{performedToJudge2[0][:PkmnName]}, #{performedToJudge2[1][:PkmnName]}, and #{performedToJudge2[2][:PkmnName]}! <c3=E82010,F8A8B8>+1</c3>!"))
      performedToJudge2[0][:CurrentRoundHearts] += 1
      self.addAppealHeartSprite(performedToJudge2[0])
      pbWait(1 * Graphics.frame_rate/4)
      performedToJudge2[1][:CurrentRoundHearts] += 1
      self.addAppealHeartSprite(performedToJudge2[1])
      pbWait(1 * Graphics.frame_rate/4)
      performedToJudge2[2][:CurrentRoundHearts] += 1
      self.addAppealHeartSprite(performedToJudge2[2])
    when 4
      #no jump
      #shudder sound
      pbSEPlay("Contests_Acting_Judge_Shudder", 100)
      pbMessageContest(_INTL("Everyone performed for #{ContestSettings::JUDGES[2][:Name]}..."))
      pbMessageContest(_INTL("And watered down the Judge's impressions."))
      #no hearts awarded
    end #case performedToJudge2.length
    
  end #def self.giveBonusPoints
  
  def self.attentionAttracted
    #Based on how many hearts you have that round
    if @chosenContestants[3][:CurrentRoundHearts].between?(0,6)
      pbMessageContest(_INTL("#{@chosenContestants[3][:PkmnName]} attracted decent attention."))
    elsif @chosenContestants[3][:CurrentRoundHearts].between?(7,12)
      pbMessageContest(_INTL("#{@chosenContestants[3][:PkmnName]} attracted a lot of attention!"))
    else
      pbMessageContest(_INTL("#{@chosenContestants[3][:PkmnName]} commanded total attention!"))
    end
  end #def self.attentionAttracted
  
  def self.tallyPoints
    #the hearts spiral and disappear
    #pbDisposeSpriteHash(@heartSprites)
    self.audienceCheer
    self.deleteAppealHeartSprite
    
    #short pause so the audience can vibe while tallies happen if it's too fast
    timer = 0
    loop do
      if timer >= Graphics.frame_rate*3
        self.audienceStop
        break
      end
      timer += 1
    end
    
    self.updateSprites
    
    #The number of points earned from the Acting Competition is 10 times the
    #number of hearts received
    #add the current round of hearts received * 10 to the acting points
    #(finalized score for the round after any modifications to appeal hearts)
    @chosenContestants[0][:ActingPoints] += @chosenContestants[0][:CurrentRoundHearts] * 10
    @chosenContestants[1][:ActingPoints] += @chosenContestants[1][:CurrentRoundHearts] * 10
    @chosenContestants[2][:ActingPoints] += @chosenContestants[2][:CurrentRoundHearts] * 10
    @chosenContestants[3][:ActingPoints] += @chosenContestants[3][:CurrentRoundHearts] * 10
    
    #add to contestant[0][:TotalPoints]
    @chosenContestants[0][:TotalPoints] = @chosenContestants[0][:DressupPoints] + @chosenContestants[0][:ConditionPoints] + @chosenContestants[0][:DancePoints] + @chosenContestants[0][:ActingPoints]
    @chosenContestants[1][:TotalPoints] = @chosenContestants[1][:DressupPoints] + @chosenContestants[1][:ConditionPoints] + @chosenContestants[1][:DancePoints] + @chosenContestants[1][:ActingPoints]
    @chosenContestants[2][:TotalPoints] = @chosenContestants[2][:DressupPoints] + @chosenContestants[2][:ConditionPoints] + @chosenContestants[2][:DancePoints] + @chosenContestants[2][:ActingPoints]
    @chosenContestants[3][:TotalPoints] = @chosenContestants[3][:DressupPoints] + @chosenContestants[3][:ConditionPoints] + @chosenContestants[3][:DancePoints] + @chosenContestants[3][:ActingPoints]    
  end #def self.tallyPoints
  
  def self.resetCurrentRoundHearts
    #reset CurrentRoundHearts
    @chosenContestants[0][:CurrentRoundHearts] = 0
    @chosenContestants[1][:CurrentRoundHearts] = 0
    @chosenContestants[2][:CurrentRoundHearts] = 0
    @chosenContestants[3][:CurrentRoundHearts] = 0
  end
  
  def self.resetLastJudgePerformedTo
    #clear out judges performed to in contestant hash
    @chosenContestants[0][:JudgeLastPerformedTo] = ""
    @chosenContestants[1][:JudgeLastPerformedTo] = ""
    @chosenContestants[2][:JudgeLastPerformedTo] = ""
    @chosenContestants[3][:JudgeLastPerformedTo] = ""
  end
  
  def self.resetVoltagePrevention
    @voltagePreventDown = false
    @voltagePreventUp = false
  end
  
  def self.resetConsecutiveVoltage
    @judgeNumberPreviousTurnVoltageUp = nil
    @judgeNumberThisTurnVoltageUp = nil
  end
  
  def self.resetTimesPerformedTo
    ContestSettings::JUDGES[0][:TimesPerformedTo] = 0
    ContestSettings::JUDGES[1][:TimesPerformedTo] = 0
    ContestSettings::JUDGES[2][:TimesPerformedTo] = 0
  end
  
  def self.resetJudgeVoltagePeak
    @judgeNumberVoltagePeakPreviousTurn = nil
  end
  
  def self.updateTiles
    #this will call the sort points method and then update the tile bitmaps and
    #text
    self.decideContestantOrder
    self.displayContestantInfo
  end #def self.updateTiles
end #class Acting