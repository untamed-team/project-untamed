class Dance
  #=========================================================
  # Controlling Dancing and Button Placement
  #=========================================================
  #===========================
  # Deciding Possible Lead Dance Moves
  #===========================
  def self.decidePossibleLeadMoves
    timing = 6
    
    #the player and AIs cannot dance on the first beat and last beat, so exclude
    #beat 6 and beat 126
    loop do
      #move timings
      timing += 4
      @possibleMovesForAI.push(timing)
      @leadMovesOnBeat.push(timing)
      @backupMovesOnBeat.push((timing+128)) #this is for button placement snapping
      break if timing == 122
    end
    
    pixelX = 8 #skip 8. We don't want players or AI putting a move on 8
    loop do
      pixelX += 8
      @leadPixelPlacementOnBeat.push(pixelX)
      break if pixelX == 240 #skip 248. We don't want players or AI putting a move on 248
    end
    
    pixelX = 264 #skip 264. We don't want players or AI putting a move on 264
    loop do
      pixelX += 8
      @backupPixelPlacementOnBeat.push(pixelX)
      break if pixelX == 496 #skip 502. We don't want players or AI putting a move on 502
    end
    
    #trim down the list of possible moves depending on the chosenRank
    #when @chosenRank is Master, all moves no matter how close together are
    #possible
    
    #dancers cannot put moves less than what would be 8 frames apart
    #so when a lead dancer chooses a move, I need to delete adjacent possibilities
    
  end #def self.decidePossibleLeadMoves
  
  def self.decideMoveTimings(contestantMovePool)
    possible_moves = @possibleMovesForAI.clone
    @lastTimingChosen = nil
    @lastTimingChosenTemp = nil
    @maxDanceMoves.times do
      #if we already have a move in the list of timings, this next run will roll
      #to see if the next move will be right next to the last one
      if contestantMovePool.length > 0 && self.randomChanceRapidSuccession
        #choose a move right after or before the last one chosen
        #set move_timing to nil so once we get the correct move_timing, we
        #cannot overwrite it with the statements that follow
        
        move_timing = nil
        
        @lastTimingChosenTemp = @lastTimingChosen.clone
        #add 4 until we find the closest possible move
        for i in 0...possible_moves.length
          if move_timing == nil
            @lastTimingChosenTemp += 4
            move_timing = @lastTimingChosenTemp if possible_moves.include?(@lastTimingChosenTemp)
          end
        end
        
        @lastTimingChosenTemp = @lastTimingChosen.clone
        #subtract 4 until we find the closest possible move
        for i in 0...possible_moves.length
          if move_timing == nil
            @lastTimingChosenTemp -= 4
            move_timing = @lastTimingChosenTemp if possible_moves.include?(@lastTimingChosenTemp)
          end
        end
        
        #for debugging purposes
        print "move-timing is nil" if move_timing == nil
        
      elsif contestantMovePool.empty? && self.randomChanceMoveAtBeginningEnd
        #decide if first move chosen should be at beginning/end of track or not
        decision = rand(1..2)
        move_timing = possible_moves[0] if decision == 1
        move_timing = possible_moves[-1] if decision == 2
      else
        #choose move randomly
        #pick random element left in the array
        move_timing = possible_moves.sample
      end
      
      @lastTimingChosen = move_timing
      
      #dancerTimingPool.push(possible_moves[move_timing])
      contestantMovePool.push(move_timing)
      
      #delete move timing so we cannot choose it again
      #delete possible moves starting with the move adjancent to the right of the
      #chosen move so we don't affect the position of the move timings
      
      #delete move_timing and any timings too close to it from possible_moves
      possible_moves.delete(move_timing-12) if possible_moves.include?(move_timing-12)
      possible_moves.delete(move_timing-8) if possible_moves.include?(move_timing-8)
      possible_moves.delete(move_timing-4) if possible_moves.include?(move_timing-4)
      possible_moves.delete(move_timing)
      possible_moves.delete(move_timing+4) if possible_moves.include?(move_timing+4)
      possible_moves.delete(move_timing+8) if possible_moves.include?(move_timing+8)
      possible_moves.delete(move_timing+12) if possible_moves.include?(move_timing+12)

    end #@maxDanceMoves.times do
    
    contestantMovePool.sort!
    
  end #def self.decideMoveTimings(dancerTimingPool)
  
  #this is the helper method that decides directions when passed the array as an
  #argument
  def self.decideMoveTypes(contestantMovePool)
    
    @lastDirectionChosen = nil
    move_directions = ["Jump", "Front", "Left", "Right"]
    i = 0
    
    @maxDanceMoves.times do
      move_type = move_directions.sample
      #add the type of move to another array
      contestantMovePool.push(move_type)
      #chance to delete that move from the array; cannot delete if it's the last
      #move type in the array, not that it should be a problem with the max
      #amount of moves being 4
      move_directions.delete(move_type) if move_directions.length > 1 && self.randomChanceNextMoveDifferent
    end #@maxDanceMoves.times do
    
  end #def self.decideMoveTypes(contestantMovePool)
  
  #===========================
  # Deciding Lead Dance Moves
  #===========================
  def self.decideLeadDancerMoves(contestantNumber)
    self.decideMoveTimings(@chosenContestants[contestantNumber][:DanceMoves][:ButtonPlacementTimings1])
    self.decideMoveTypes(@chosenContestants[contestantNumber][:DanceMoves][:ButtonTypes1])
    
    self.decideMoveTimings(@chosenContestants[contestantNumber][:DanceMoves][:ButtonPlacementTimings2])
    self.decideMoveTypes(@chosenContestants[contestantNumber][:DanceMoves][:ButtonTypes2])
    
    #copy button timings to distorted timings for lead
    @chosenContestants[contestantNumber][:DanceMoves][:DistortedTimings1] = Marshal.load(Marshal.dump(@chosenContestants[contestantNumber][:DanceMoves][:ButtonPlacementTimings1]))
    @chosenContestants[contestantNumber][:DanceMoves][:DistortedTimings2] = Marshal.load(Marshal.dump(@chosenContestants[contestantNumber][:DanceMoves][:ButtonPlacementTimings2]))
    
    #copy the move types of the lead to its distorted types key since that's
    #what button placement will be based on
    @chosenContestants[contestantNumber][:DanceMoves][:DistortedTypes1] = Marshal.load(Marshal.dump(@chosenContestants[contestantNumber][:DanceMoves][:ButtonTypes1]))
    @chosenContestants[contestantNumber][:DanceMoves][:DistortedTypes2] = Marshal.load(Marshal.dump(@chosenContestants[contestantNumber][:DanceMoves][:ButtonTypes2]))
    
    #copy the move types of the lead to its PkmnSpriteMoveDirection arrays since
    #that's the queueing array that helps pkmn sprite movement
    @chosenContestants[contestantNumber][:DanceMoves][:PkmnSpriteMoveDirection1] = Marshal.load(Marshal.dump(@chosenContestants[contestantNumber][:DanceMoves][:ButtonTypes1]))
    @chosenContestants[contestantNumber][:DanceMoves][:PkmnSpriteMoveDirection2] = Marshal.load(Marshal.dump(@chosenContestants[contestantNumber][:DanceMoves][:ButtonTypes2]))
    
    #copy the distorted timings to the pkmn move sprite timing
    @chosenContestants[contestantNumber][:DanceMoves][:PkmnSpriteMoveTiming1] = Marshal.load(Marshal.dump(@chosenContestants[contestantNumber][:DanceMoves][:DistortedTimings1]))
    @chosenContestants[contestantNumber][:DanceMoves][:PkmnSpriteMoveTiming2] = Marshal.load(Marshal.dump(@chosenContestants[contestantNumber][:DanceMoves][:DistortedTimings2]))
    #distort the pkmn move sprite timing so the lead places buttons on beat but
    #then its actual movement can be off beat
    self.distortMoveTimings(@chosenContestants[contestantNumber][:DanceMoves][:PkmnSpriteMoveTiming1])
    self.distortMoveTimings(@chosenContestants[contestantNumber][:DanceMoves][:PkmnSpriteMoveTiming2])
    
    #make @matchSpriteTimings' button placements the same as buttonplacement timings
    @matchSpriteTimings[:ButtonPlacementTimings1] = Marshal.load(Marshal.dump(@chosenContestants[contestantNumber][:DanceMoves][:ButtonPlacementTimings1]))
    @matchSpriteTimings[:ButtonPlacementTimings2] = Marshal.load(Marshal.dump(@chosenContestants[contestantNumber][:DanceMoves][:ButtonPlacementTimings2]))
    
    #make @matchSpriteTimings' move types the same as buttonplacement timings
    @matchSpriteTimings[:ButtonTypes1] = Marshal.load(Marshal.dump(@chosenContestants[contestantNumber][:DanceMoves][:ButtonTypes1]))
    @matchSpriteTimings[:ButtonTypes2] = Marshal.load(Marshal.dump(@chosenContestants[contestantNumber][:DanceMoves][:ButtonTypes2]))
  end #def self.decideLeadDancerMoves
  
  #===========================
  # Distorting Move Timings
  #===========================
  def self.distortMoveTimings(timing_pool)
    #Distort @chosenContestants[contestantNumber][:DanceMoves][:DistortedTimings1]
    for i in 0...timing_pool.length
      if self.randomChanceDistort("timing") == "Excellent"
        #don't distort timing
      elsif self.randomChanceDistort("timing") == "Good"
        #distort timing by 1
        variance = 1
        #by changing the timings, we risk some moves overlapping
        #therefore, we must check to see if the value matches another in the
        #array
        #timing_pool[i][0] is the pixel placement of the move, while
        #timing_pool[i][1] is the move type: front, jump, left, or right
        if timing_pool[i] == 2
          #we cannot go any lower, so add variance instead of subtracting
          #but if the would-be value of the timing after distortion is equal to
          #a value that is already in the array, don't modify it at all
          timing_pool[i] += variance if !timing_pool.include?(timing_pool[i] + variance)
        elsif timing_pool[i] == 126
          #we cannot go any higher, so subtract variance instead of adding
          timing_pool[i] -= variance if !timing_pool.include?(timing_pool[i] - variance)
        else
          #let rand decide if it should be subtracted or added
          addOrSubtract = rand(1..2)
          timing_pool[i] -= variance if addOrSubtract == 1 && !timing_pool.include?(timing_pool[i] - variance)
          timing_pool[i] += variance if addOrSubtract == 2 && !timing_pool.include?(timing_pool[i] + variance)
        end #if timing_pool[i][0] == 2
      else #miss
        #distort timing by 2
        variance = 2
        if timing_pool[i] == 2
          #we cannot go any lower, so add variance instead of subtracting
          #but if the would-be value of the timing after distortion is equal to
          #a value that is already in the array, don't modify it at all
          timing_pool[i] += variance if !timing_pool.include?(timing_pool[i] + variance)
        elsif timing_pool[i] == 126
          #we cannot go any higher, so subtract variance instead of adding
          timing_pool[i] -= variance if !timing_pool.include?(timing_pool[i] - variance)
        else
          #let rand decide if it should be subtracted or added
          addOrSubtract = rand(1..2)
          timing_pool[i] -= variance if addOrSubtract == 1 && !timing_pool.include?(timing_pool[i] - variance)
          timing_pool[i] += variance if addOrSubtract == 2 && !timing_pool.include?(timing_pool[i] + variance)
        end #if timing_pool[i][0] == 2
      end #if self.randomChanceDistort("timing") == "Excellent"
    end #for i in 0...timing_pool
  end #def self.distortMoveTimings(contestant)
  
  #===========================
  # Copy Lead Moves to Backup Dancers
  #===========================
  def self.copyAIDanceMovesToBackups(contestantNumber)
    #the moves need to be copied to the player's hash as well for judging
    case contestantNumber
    when 0
      leadAI = @chosenContestants[0]
      backupAI1 = @chosenContestants[1]
      backupAI2 = @chosenContestants[2]
    when 1
      leadAI = @chosenContestants[1]
      backupAI1 = @chosenContestants[0]
      backupAI2 = @chosenContestants[2]
    when 2
      leadAI = @chosenContestants[2]
      backupAI1 = @chosenContestants[0]
      backupAI2 = @chosenContestants[1]
    end #case contestantNumber
    
    #copy the lead's timings to the backup AIs
    backupAI1[:DanceMoves][:ButtonPlacementTimings1] = Marshal.load(Marshal.dump(leadAI[:DanceMoves][:ButtonPlacementTimings1]))
    backupAI1[:DanceMoves][:ButtonPlacementTimings2] = Marshal.load(Marshal.dump(leadAI[:DanceMoves][:ButtonPlacementTimings2]))
    backupAI1[:DanceMoves][:DistortedTimings1] = Marshal.load(Marshal.dump(leadAI[:DanceMoves][:DistortedTimings1]))
    backupAI1[:DanceMoves][:DistortedTimings2] = Marshal.load(Marshal.dump(leadAI[:DanceMoves][:DistortedTimings2]))

    backupAI2[:DanceMoves][:ButtonPlacementTimings1] = Marshal.load(Marshal.dump(leadAI[:DanceMoves][:ButtonPlacementTimings1]))
    backupAI2[:DanceMoves][:ButtonPlacementTimings2] = Marshal.load(Marshal.dump(leadAI[:DanceMoves][:ButtonPlacementTimings2]))
    backupAI2[:DanceMoves][:DistortedTimings1] = Marshal.load(Marshal.dump(leadAI[:DanceMoves][:DistortedTimings1]))
    backupAI2[:DanceMoves][:DistortedTimings2] = Marshal.load(Marshal.dump(leadAI[:DanceMoves][:DistortedTimings2]))

    #copy the lead's timings to the player for judging
    @chosenContestants[3][:DanceMoves][:ButtonPlacementTimings1] = Marshal.load(Marshal.dump(leadAI[:DanceMoves][:ButtonPlacementTimings1]))
    @chosenContestants[3][:DanceMoves][:ButtonPlacementTimings2] = Marshal.load(Marshal.dump(leadAI[:DanceMoves][:ButtonPlacementTimings2]))
    
    #add 128 to the timings so they are placed on the second half of the track
    for i in 0...leadAI[:DanceMoves][:ButtonPlacementTimings1].length
      backupAI1[:DanceMoves][:ButtonPlacementTimings1][i] += 128
      backupAI1[:DanceMoves][:ButtonPlacementTimings2][i] += 128
      backupAI1[:DanceMoves][:DistortedTimings1][i] += 128
      backupAI1[:DanceMoves][:DistortedTimings2][i] += 128
        
      backupAI2[:DanceMoves][:ButtonPlacementTimings1][i] += 128
      backupAI2[:DanceMoves][:ButtonPlacementTimings2][i] += 128
      backupAI2[:DanceMoves][:DistortedTimings1][i] += 128
      backupAI2[:DanceMoves][:DistortedTimings2][i] += 128
      
      #do the same for the player's timings
      @chosenContestants[3][:DanceMoves][:ButtonPlacementTimings1][i] += 128
      @chosenContestants[3][:DanceMoves][:ButtonPlacementTimings2][i] += 128
      
    end #for i in 0...leadAI[:DanceMoves][:ButtonPlacementTimings1].length
    
    #before distorting timings for backup dancers, copy the ButtonPlacementTimings
    #to DistortedTimings
    backupAI1[:DanceMoves][:DistortedTimings1] = Marshal.load(Marshal.dump(backupAI1[:DanceMoves][:ButtonPlacementTimings1]))
    backupAI1[:DanceMoves][:DistortedTimings2] = Marshal.load(Marshal.dump(backupAI1[:DanceMoves][:ButtonPlacementTimings2]))
    backupAI2[:DanceMoves][:DistortedTimings1] = Marshal.load(Marshal.dump(backupAI1[:DanceMoves][:ButtonPlacementTimings1]))
    backupAI2[:DanceMoves][:DistortedTimings2] = Marshal.load(Marshal.dump(backupAI1[:DanceMoves][:ButtonPlacementTimings2]))
    
    #distort the backup timings
    self.distortMoveTimings(backupAI1[:DanceMoves][:DistortedTimings1])
    self.distortMoveTimings(backupAI1[:DanceMoves][:DistortedTimings2])
    self.distortMoveTimings(backupAI2[:DanceMoves][:DistortedTimings1])
    self.distortMoveTimings(backupAI2[:DanceMoves][:DistortedTimings2])
    
    #copy the distorted timings (used for button placement) to the
    #PkmnSpriteMoveTiming arrays (used for actual sprite movement)
    backupAI1[:DanceMoves][:PkmnSpriteMoveTiming1] = Marshal.load(Marshal.dump(backupAI1[:DanceMoves][:DistortedTimings1]))
    backupAI1[:DanceMoves][:PkmnSpriteMoveTiming2] = Marshal.load(Marshal.dump(backupAI1[:DanceMoves][:DistortedTimings2]))
    backupAI2[:DanceMoves][:PkmnSpriteMoveTiming1] = Marshal.load(Marshal.dump(backupAI1[:DanceMoves][:DistortedTimings1]))
    backupAI2[:DanceMoves][:PkmnSpriteMoveTiming2] = Marshal.load(Marshal.dump(backupAI1[:DanceMoves][:DistortedTimings2]))
    
    #copy the lead's move types to the backup AIs
    backupAI1[:DanceMoves][:ButtonTypes1] = Marshal.load(Marshal.dump(leadAI[:DanceMoves][:ButtonTypes1]))
    backupAI1[:DanceMoves][:ButtonTypes2] = Marshal.load(Marshal.dump(leadAI[:DanceMoves][:ButtonTypes2]))
    backupAI1[:DanceMoves][:DistortedTypes1] = Marshal.load(Marshal.dump(leadAI[:DanceMoves][:ButtonTypes1]))
    backupAI1[:DanceMoves][:DistortedTypes2] = Marshal.load(Marshal.dump(leadAI[:DanceMoves][:ButtonTypes2]))
    
    backupAI2[:DanceMoves][:ButtonTypes1] = Marshal.load(Marshal.dump(leadAI[:DanceMoves][:ButtonTypes1]))
    backupAI2[:DanceMoves][:ButtonTypes2] = Marshal.load(Marshal.dump(leadAI[:DanceMoves][:ButtonTypes2]))
    backupAI2[:DanceMoves][:DistortedTypes1] = Marshal.load(Marshal.dump(leadAI[:DanceMoves][:ButtonTypes1]))
    backupAI2[:DanceMoves][:DistortedTypes2] = Marshal.load(Marshal.dump(leadAI[:DanceMoves][:ButtonTypes2]))
    
    #copy the lead's move types to the player for judging
    @chosenContestants[3][:DanceMoves][:ButtonTypes1] = Marshal.load(Marshal.dump(leadAI[:DanceMoves][:ButtonTypes1]))
    @chosenContestants[3][:DanceMoves][:ButtonTypes2] = Marshal.load(Marshal.dump(leadAI[:DanceMoves][:ButtonTypes2]))
    
    #distort the backup types
    #this will have a random chance to make the backup dancer AIs choose
    #the wrong move type as a response
    self.distortBackupTypes(backupAI1[:DanceMoves][:DistortedTypes1])
    self.distortBackupTypes(backupAI1[:DanceMoves][:DistortedTypes2])
    self.distortBackupTypes(backupAI2[:DanceMoves][:DistortedTypes1])
    self.distortBackupTypes(backupAI2[:DanceMoves][:DistortedTypes2])
    
    #copy the distorted type moves to the PkmnSpriteMoveDirection arrays since
    #that is the queueing system for moving the pkmn sprite
    backupAI1[:DanceMoves][:PkmnSpriteMoveDirection1] = Marshal.load(Marshal.dump(backupAI1[:DanceMoves][:DistortedTypes1]))
    backupAI1[:DanceMoves][:PkmnSpriteMoveDirection2] = Marshal.load(Marshal.dump(backupAI1[:DanceMoves][:DistortedTypes2]))
    backupAI2[:DanceMoves][:PkmnSpriteMoveDirection1] = Marshal.load(Marshal.dump(backupAI2[:DanceMoves][:DistortedTypes1]))
    backupAI2[:DanceMoves][:PkmnSpriteMoveDirection2] = Marshal.load(Marshal.dump(backupAI2[:DanceMoves][:DistortedTypes2]))
    
  end #def self.copyAIDanceMovesToBackups(contestantNumber)
  
  def self.copyPlayerDanceMovesToBackups
    #this is done as moves are made by the player when the player is the lead
  end #def self.copyPlayerDanceMovesToBackups
  
  #================================================
  #============= Place Move Buttons ==============
  #================================================
  def self.placeMoveButtons
    case @setOfMoves
    when 1
      #ButtonPlacementTimings1
      #this audits each AI contestant's element 0 in [:ButtonPlacementTimings1]
      #and places the button sprite on the track when the time comes
      
      #=========================
      #===== Contestant 1 ======
      #=========================
      if !@chosenContestants[0][:DanceMoves][:DistortedTimings1].empty? && @chosenContestants[0][:DanceMoves][:DistortedTimings1][0] == @timerY
        @moveButtonCounter += 1
        moveType = @chosenContestants[0][:DanceMoves][:DistortedTypes1][0]
        
        #failsafe to fix a crash I can't reproduce
        moveType = "Front" if moveType == nil
        
        #initiate a sprite for the move
        @moveButtonSprites["move#{@moveButtonCounter}"] = AnimatedSprite.new("Graphics/Pictures/Contest/dance/opponent #{moveType}", 3, 28, 32, 2, @viewport)
        @moveButtonSprites["move#{@moveButtonCounter}"].x = @sprites["jigglypuff"].x
        @moveButtonSprites["move#{@moveButtonCounter}"].y = @chosenContestants[0][:DanceMoves][:MoveSpriteY]
        @moveButtonSprites["move#{@moveButtonCounter}"].z = @chosenContestants[0][:DanceMoves][:MoveSpriteZ]
        @moveButtonSprites["move#{@moveButtonCounter}"].play
        
        #delete [:ButtonPlacementTimings1][0] from [:ButtonPlacementTimings1]
        @chosenContestants[0][:DanceMoves][:DistortedTimings1].delete_at(0)
        @chosenContestants[0][:DanceMoves][:DistortedTypes1].delete_at(0)
      end
      
      #=========================
      #===== Contestant 2 ======
      #=========================
      if !@chosenContestants[1][:DanceMoves][:DistortedTimings1].empty? && @chosenContestants[1][:DanceMoves][:DistortedTimings1][0] == @timerY
        @moveButtonCounter += 1
        moveType = @chosenContestants[1][:DanceMoves][:DistortedTypes1][0]
        
        #failsafe to fix a crash I can't reproduce
        moveType = "Front" if moveType == nil
        
        #initiate a sprite for the move
        @moveButtonSprites["move#{@moveButtonCounter}"] = AnimatedSprite.new("Graphics/Pictures/Contest/dance/opponent #{moveType}", 3, 28, 32, 2, @viewport)
        @moveButtonSprites["move#{@moveButtonCounter}"].x = @sprites["jigglypuff"].x
        @moveButtonSprites["move#{@moveButtonCounter}"].y = @chosenContestants[1][:DanceMoves][:MoveSpriteY]
        @moveButtonSprites["move#{@moveButtonCounter}"].z = @chosenContestants[1][:DanceMoves][:MoveSpriteZ]
        @moveButtonSprites["move#{@moveButtonCounter}"].play
        
        @chosenContestants[1][:DanceMoves][:DistortedTimings1].delete_at(0)
        @chosenContestants[1][:DanceMoves][:DistortedTypes1].delete_at(0)
      end
      
      #=========================
      #===== Contestant 3 ======
      #=========================
      if !@chosenContestants[2][:DanceMoves][:DistortedTimings1].empty? && @chosenContestants[2][:DanceMoves][:DistortedTimings1][0] == @timerY
        @moveButtonCounter += 1
        moveType = @chosenContestants[2][:DanceMoves][:DistortedTypes1][0]
        
        #failsafe to fix a crash I can't reproduce
        moveType = "Front" if moveType == nil
        
        #initiate a sprite for the move
        @moveButtonSprites["move#{@moveButtonCounter}"] = AnimatedSprite.new("Graphics/Pictures/Contest/dance/opponent #{moveType}", 3, 28, 32, 2, @viewport)
        @moveButtonSprites["move#{@moveButtonCounter}"].x = @sprites["jigglypuff"].x
        @moveButtonSprites["move#{@moveButtonCounter}"].y = @chosenContestants[2][:DanceMoves][:MoveSpriteY]
        @moveButtonSprites["move#{@moveButtonCounter}"].z = @chosenContestants[2][:DanceMoves][:MoveSpriteZ]
        @moveButtonSprites["move#{@moveButtonCounter}"].play
        
        @chosenContestants[2][:DanceMoves][:DistortedTimings1].delete_at(0)
        @chosenContestants[2][:DanceMoves][:DistortedTypes1].delete_at(0)
      end
      
      #=========================
      #====== Match Move =======
      #=========================
      #place match sprite for copying the lead
      moveType = @matchSpriteTimings[:ButtonTypes1][0]
      
      #failsafe to fix a crash I can't reproduce
      moveType = "Front" if moveType == nil
      
      if !@matchSpriteTimings[:ButtonPlacementTimings1].empty? && @matchSpriteTimings[:ButtonPlacementTimings1][0] == @timerY
        #initiate a sprite for the move
        @moveButtonSprites["copy#{@moveButtonCounter}"] = IconSprite.new(0, 0, @viewport)
        @moveButtonSprites["copy#{@moveButtonCounter}"].setBitmap("Graphics/Pictures/Contest/dance/match #{moveType}")
        @moveButtonSprites["copy#{@moveButtonCounter}"].x = @sprites["jigglypuff"].x + 128*2
        @moveButtonSprites["copy#{@moveButtonCounter}"].y = @chosenContestants[3][:DanceMoves][:MoveSpriteY]
        @moveButtonSprites["copy#{@moveButtonCounter}"].z = 99999
        
        @matchSpriteTimings[:ButtonPlacementTimings1].delete_at(0)
        @matchSpriteTimings[:ButtonTypes1].delete_at(0)
      end
      
    when 2
      #ButtonPlacementTimings2
      #this audits each AI contestant's element 0 in [:ButtonPlacementTimings2]
      #and places the button sprite on the track when the time comes
      
      #=========================
      #===== Contestant 1 ======
      #=========================
      if !@chosenContestants[0][:DanceMoves][:DistortedTimings2].empty? && @chosenContestants[0][:DanceMoves][:DistortedTimings2][0] == @timerY        
        @moveButtonCounter += 1
        moveType = @chosenContestants[0][:DanceMoves][:DistortedTypes2][0]
        
        #failsafe to fix a crash I can't reproduce
        moveType = "Front" if moveType == nil
        
        #initiate a sprite for the move
        @moveButtonSprites["move#{@moveButtonCounter}"] = AnimatedSprite.new("Graphics/Pictures/Contest/dance/opponent #{moveType}", 3, 28, 32, 2, @viewport)
        @moveButtonSprites["move#{@moveButtonCounter}"].x = @sprites["jigglypuff"].x
        @moveButtonSprites["move#{@moveButtonCounter}"].y = @chosenContestants[0][:DanceMoves][:MoveSpriteY]
        @moveButtonSprites["move#{@moveButtonCounter}"].z = @chosenContestants[0][:DanceMoves][:MoveSpriteZ]
        @moveButtonSprites["move#{@moveButtonCounter}"].play
        
        @chosenContestants[0][:DanceMoves][:DistortedTimings2].delete_at(0)
        @chosenContestants[0][:DanceMoves][:DistortedTypes2].delete_at(0)
      end
      
      #=========================
      #===== Contestant 2 ======
      #=========================
      if !@chosenContestants[1][:DanceMoves][:DistortedTimings2].empty? && @chosenContestants[1][:DanceMoves][:DistortedTimings2][0] == @timerY
        @moveButtonCounter += 1
        moveType = @chosenContestants[1][:DanceMoves][:DistortedTypes2][0]
        
        #failsafe to fix a crash I can't reproduce
        moveType = "Front" if moveType == nil
        
        #initiate a sprite for the move
        @moveButtonSprites["move#{@moveButtonCounter}"] = AnimatedSprite.new("Graphics/Pictures/Contest/dance/opponent #{moveType}", 3, 28, 32, 2, @viewport)
        @moveButtonSprites["move#{@moveButtonCounter}"].x = @sprites["jigglypuff"].x
        @moveButtonSprites["move#{@moveButtonCounter}"].y = @chosenContestants[1][:DanceMoves][:MoveSpriteY]
        @moveButtonSprites["move#{@moveButtonCounter}"].z = @chosenContestants[1][:DanceMoves][:MoveSpriteZ]
        @moveButtonSprites["move#{@moveButtonCounter}"].play
        
        @chosenContestants[1][:DanceMoves][:DistortedTimings2].delete_at(0)
        @chosenContestants[1][:DanceMoves][:DistortedTypes2].delete_at(0)
      end
      
      #=========================
      #===== Contestant 3 ======
      #=========================
      if !@chosenContestants[2][:DanceMoves][:DistortedTimings2].empty? && @chosenContestants[2][:DanceMoves][:DistortedTimings2][0] == @timerY
        @moveButtonCounter += 1
        moveType = @chosenContestants[2][:DanceMoves][:DistortedTypes2][0]
        
        #failsafe to fix a crash I can't reproduce
        moveType = "Front" if moveType == nil
                
        #initiate a sprite for the move
        @moveButtonSprites["move#{@moveButtonCounter}"] = AnimatedSprite.new("Graphics/Pictures/Contest/dance/opponent #{moveType}", 3, 28, 32, 2, @viewport)
        @moveButtonSprites["move#{@moveButtonCounter}"].x = @sprites["jigglypuff"].x
        @moveButtonSprites["move#{@moveButtonCounter}"].y = @chosenContestants[2][:DanceMoves][:MoveSpriteY]
        @moveButtonSprites["move#{@moveButtonCounter}"].z = @chosenContestants[2][:DanceMoves][:MoveSpriteZ]
        @moveButtonSprites["move#{@moveButtonCounter}"].play
        
        #delete [:ButtonPlacementTimings2][0] from [:ButtonPlacementTimings2]
        @chosenContestants[2][:DanceMoves][:DistortedTimings2].delete_at(0)
        @chosenContestants[2][:DanceMoves][:DistortedTypes2].delete_at(0)
      end
      
      #=========================
      #====== Match Move =======
      #=========================
      #place match sprite for copying the lead
      moveType = @matchSpriteTimings[:ButtonTypes2][0]
      if !@matchSpriteTimings[:ButtonPlacementTimings2].empty? && @matchSpriteTimings[:ButtonPlacementTimings2][0] == @timerY
        #initiate a sprite for the move
        @moveButtonSprites["copy#{@moveButtonCounter}"] = IconSprite.new(0, 0, @viewport)
        @moveButtonSprites["copy#{@moveButtonCounter}"].setBitmap("Graphics/Pictures/Contest/dance/match #{moveType}")
        @moveButtonSprites["copy#{@moveButtonCounter}"].x = @sprites["jigglypuff"].x + 128*2
        @moveButtonSprites["copy#{@moveButtonCounter}"].y = @chosenContestants[3][:DanceMoves][:MoveSpriteY]
        @moveButtonSprites["copy#{@moveButtonCounter}"].z = 99999
        
        @matchSpriteTimings[:ButtonPlacementTimings2].delete_at(0)
        @matchSpriteTimings[:ButtonTypes2].delete_at(0)
      end
    end #case @trackRunCount
  end #def self.placeMoveButtons
  
  #================================================
  #======== Dictate Pkmn Sprite Movement =========
  #================================================
  def self.moveAIPkmnSprites
    case @setOfMoves
    when 1
      #this audits each AI contestant's element 0 in [:PkmnSpriteMoveTiming1]
      #and makes the pkmn sprite move when the time comes
      #this was created just for the lead pokemon since it's distorted timings
      #(which were used for actually moving the sprite), are actually perfect,
      #since those need to be perfect for button placement
      
      #=========================
      #===== Contestant 1 ======
      #=========================
      if !@chosenContestants[0][:DanceMoves][:PkmnSpriteMoveTiming1].empty? && @chosenContestants[0][:DanceMoves][:PkmnSpriteMoveTiming1][0] == @timerY
        moveType = @chosenContestants[0][:DanceMoves][:PkmnSpriteMoveDirection1][0]
        
        #failsafe to fix a crash I can't reproduce
        moveType = "Front" if moveType == nil
        
        #set the move direction for the contestant to kick off the sprite moving
        @chosenContestants[0][:DanceMoves][:DanceDirection] = moveType
        
        #judge the movement
        self.judgeMove(@chosenContestants[0])
        
        @chosenContestants[0][:DanceMoves][:ButtonPlacementTimings1].delete_at(0)
        @chosenContestants[0][:DanceMoves][:ButtonTypes1].delete_at(0)
        @chosenContestants[0][:DanceMoves][:PkmnSpriteMoveTiming1].delete_at(0)
        @chosenContestants[0][:DanceMoves][:PkmnSpriteMoveDirection1].delete_at(0)
      end
      
      #=========================
      #===== Contestant 2 ======
      #=========================
      if !@chosenContestants[1][:DanceMoves][:PkmnSpriteMoveTiming1].empty? && @chosenContestants[1][:DanceMoves][:PkmnSpriteMoveTiming1][0] == @timerY
        moveType = @chosenContestants[1][:DanceMoves][:PkmnSpriteMoveDirection1][0]
        
        #failsafe to fix a crash I can't reproduce
        moveType = "Front" if moveType == nil
        
        #set the move direction for the contestant to kick off the sprite moving
        @chosenContestants[1][:DanceMoves][:DanceDirection] = moveType
        
        #judge the movement
        self.judgeMove(@chosenContestants[1])
        
        @chosenContestants[1][:DanceMoves][:ButtonPlacementTimings1].delete_at(0)
        @chosenContestants[1][:DanceMoves][:ButtonTypes1].delete_at(0)
        @chosenContestants[1][:DanceMoves][:PkmnSpriteMoveTiming1].delete_at(0)
        @chosenContestants[1][:DanceMoves][:PkmnSpriteMoveDirection1].delete_at(0)
      end
      
      #=========================
      #===== Contestant 3 ======
      #=========================
      if !@chosenContestants[2][:DanceMoves][:PkmnSpriteMoveTiming1].empty? && @chosenContestants[2][:DanceMoves][:PkmnSpriteMoveTiming1][0] == @timerY
        moveType = @chosenContestants[2][:DanceMoves][:PkmnSpriteMoveDirection1][0]
        
        #failsafe to fix a crash I can't reproduce
        moveType = "Front" if moveType == nil
        
        #set the move direction for the contestant to kick off the sprite moving
        @chosenContestants[2][:DanceMoves][:DanceDirection] = moveType
        
        #judge the movement
        self.judgeMove(@chosenContestants[2])
        
        @chosenContestants[2][:DanceMoves][:ButtonPlacementTimings1].delete_at(0)
        @chosenContestants[2][:DanceMoves][:ButtonTypes1].delete_at(0)
        @chosenContestants[2][:DanceMoves][:PkmnSpriteMoveTiming1].delete_at(0)
        @chosenContestants[2][:DanceMoves][:PkmnSpriteMoveDirection1].delete_at(0)
      end
      
    when 2
      #=========================
      #===== Contestant 1 ======
      #=========================
      if !@chosenContestants[0][:DanceMoves][:PkmnSpriteMoveTiming2].empty? && @chosenContestants[0][:DanceMoves][:PkmnSpriteMoveTiming2][0] == @timerY
        moveType = @chosenContestants[0][:DanceMoves][:PkmnSpriteMoveDirection2][0]
        
        #failsafe to fix a crash I can't reproduce
        moveType = "Front" if moveType == nil
        
        #set the move direction for the contestant to kick off the sprite moving
        @chosenContestants[0][:DanceMoves][:DanceDirection] = moveType
        
        #judge the movement
        self.judgeMove(@chosenContestants[0])
        
        @chosenContestants[0][:DanceMoves][:ButtonPlacementTimings2].delete_at(0)
        @chosenContestants[0][:DanceMoves][:ButtonTypes2].delete_at(0)
        @chosenContestants[0][:DanceMoves][:PkmnSpriteMoveTiming2].delete_at(0)
        @chosenContestants[0][:DanceMoves][:PkmnSpriteMoveDirection2].delete_at(0)
      end
      
      #=========================
      #===== Contestant 2 ======
      #=========================
      if !@chosenContestants[1][:DanceMoves][:PkmnSpriteMoveTiming2].empty? && @chosenContestants[1][:DanceMoves][:PkmnSpriteMoveTiming2][0] == @timerY
        moveType = @chosenContestants[1][:DanceMoves][:PkmnSpriteMoveDirection2][0]
        
        #failsafe to fix a crash I can't reproduce
        moveType = "Front" if moveType == nil
        
        #set the move direction for the contestant to kick off the sprite moving
        @chosenContestants[1][:DanceMoves][:DanceDirection] = moveType
        
        #judge the movement
        self.judgeMove(@chosenContestants[1])
        
        @chosenContestants[1][:DanceMoves][:ButtonPlacementTimings2].delete_at(0)
        @chosenContestants[1][:DanceMoves][:ButtonTypes2].delete_at(0)
        @chosenContestants[1][:DanceMoves][:PkmnSpriteMoveTiming2].delete_at(0)
        @chosenContestants[1][:DanceMoves][:PkmnSpriteMoveDirection2].delete_at(0)
      end
      
      #=========================
      #===== Contestant 3 ======
      #=========================
      if !@chosenContestants[2][:DanceMoves][:PkmnSpriteMoveTiming2].empty? && @chosenContestants[2][:DanceMoves][:PkmnSpriteMoveTiming2][0] == @timerY
        moveType = @chosenContestants[2][:DanceMoves][:PkmnSpriteMoveDirection2][0]
        
        #failsafe to fix a crash I can't reproduce
        moveType = "Front" if moveType == nil
        
        #set the move direction for the contestant to kick off the sprite moving
        @chosenContestants[2][:DanceMoves][:DanceDirection] = moveType
        
        #judge the movement
        self.judgeMove(@chosenContestants[2])
        
        @chosenContestants[2][:DanceMoves][:ButtonPlacementTimings2].delete_at(0)
        @chosenContestants[2][:DanceMoves][:ButtonTypes2].delete_at(0)
        @chosenContestants[2][:DanceMoves][:PkmnSpriteMoveTiming2].delete_at(0)
        @chosenContestants[2][:DanceMoves][:PkmnSpriteMoveDirection2 ].delete_at(0)
      end
    end #case @setOfMoves
  end #def self.moveAIPkmnSprites
  
  #================================================
  #================= Move Player ==================
  #================================================
  #=========================
  # Interpret Player Input
  #=========================
  def self.movePlayer(direction)
    #subtract a move from how many moves player can make
    @danceMovesLeft -= 1
    
    #move dance sprite
    #self.moveDancerSprite(dancer=4, direction=direction, startX=@sprites["contestant4"].x, startY=@sprites["contestant4"].y)
    #self.placeMoveClosestToBeat(direction=direction)
    
    self.placePlayerButton(direction=direction)
    
    #set variables in player's dance moves hash that will cause the pkmn sprite
    #to move
    @chosenContestants[3][:DanceMoves][:DanceDirection] = direction
    case @setOfMoves
    when 1
      @chosenContestants[3][:DanceMoves][:PkmnSpriteMoveDirection1] = direction
    when 2
      @chosenContestants[3][:DanceMoves][:PkmnSpriteMoveDirection2] = direction
    end
    
    #judge the movement
    self.judgePlayerMove(direction)
    
    #copy the player's move to all the AIs if player is the lead dancer
    if @dancerTurn == 4 && @setOfMoves == 1
      #copy the player's move timing to all the AIs in real-time
      timing = @timerY
      
      @chosenContestants[0][:DanceMoves][:ButtonPlacementTimings1].push(timing+128)
      @chosenContestants[0][:DanceMoves][:DistortedTimings1].push(timing+128)
      
      @chosenContestants[1][:DanceMoves][:ButtonPlacementTimings1].push(timing+128)
      @chosenContestants[1][:DanceMoves][:DistortedTimings1].push(timing+128)
      
      @chosenContestants[2][:DanceMoves][:ButtonPlacementTimings1].push(timing+128)
      @chosenContestants[2][:DanceMoves][:DistortedTimings1].push(timing+128)
      
      #distort the backup timings
      self.distortMoveTimings(@chosenContestants[0][:DanceMoves][:DistortedTimings1])
      self.distortMoveTimings(@chosenContestants[1][:DanceMoves][:DistortedTimings1])
      self.distortMoveTimings(@chosenContestants[2][:DanceMoves][:DistortedTimings1])
      
      #copy the player's move type to all the AIs in real-time
      @chosenContestants[0][:DanceMoves][:ButtonTypes1].push(direction)
      @chosenContestants[0][:DanceMoves][:DistortedTypes1].push(direction)
      
      @chosenContestants[1][:DanceMoves][:ButtonTypes1].push(direction)
      @chosenContestants[1][:DanceMoves][:DistortedTypes1].push(direction)
      
      @chosenContestants[2][:DanceMoves][:ButtonTypes1].push(direction)
      @chosenContestants[2][:DanceMoves][:DistortedTypes1].push(direction)
    
      #distort the backup types
      #this will have a random chance to make the backup dancer AIs choose
      #the wrong move type as a response
      self.distortBackupTypes(@chosenContestants[0][:DanceMoves][:DistortedTypes1])
      self.distortBackupTypes(@chosenContestants[1][:DanceMoves][:DistortedTypes1])
      self.distortBackupTypes(@chosenContestants[2][:DanceMoves][:DistortedTypes1])
      
      #now that everything is distorted, copy the distorted timings to PkmnSpriteMoveTiming
      #and copy the distorted types to PkmnSpriteMoveDirection
      @chosenContestants[0][:DanceMoves][:PkmnSpriteMoveTiming1] = Marshal.load(Marshal.dump(@chosenContestants[0][:DanceMoves][:DistortedTimings1]))
      @chosenContestants[0][:DanceMoves][:PkmnSpriteMoveDirection1] = Marshal.load(Marshal.dump(@chosenContestants[0][:DanceMoves][:DistortedTypes1]))
      
      @chosenContestants[1][:DanceMoves][:PkmnSpriteMoveTiming1] = Marshal.load(Marshal.dump(@chosenContestants[1][:DanceMoves][:DistortedTimings1]))
      @chosenContestants[1][:DanceMoves][:PkmnSpriteMoveDirection1] = Marshal.load(Marshal.dump(@chosenContestants[1][:DanceMoves][:DistortedTypes1]))
      
      @chosenContestants[2][:DanceMoves][:PkmnSpriteMoveTiming1] = Marshal.load(Marshal.dump(@chosenContestants[2][:DanceMoves][:DistortedTimings1]))
      @chosenContestants[2][:DanceMoves][:PkmnSpriteMoveDirection1] = Marshal.load(Marshal.dump(@chosenContestants[2][:DanceMoves][:DistortedTypes1]))
      
    elsif @dancerTurn == 4 && @setOfMoves == 2
      #copy the player's move timing to all the AIs in real-time
      timing = @timerY
      
      @chosenContestants[0][:DanceMoves][:ButtonPlacementTimings2].push(timing+128)
      @chosenContestants[0][:DanceMoves][:DistortedTimings2].push(timing+128)
      
      @chosenContestants[1][:DanceMoves][:ButtonPlacementTimings2].push(timing+128)
      @chosenContestants[1][:DanceMoves][:DistortedTimings2].push(timing+128)
      
      @chosenContestants[2][:DanceMoves][:ButtonPlacementTimings2].push(timing+128)
      @chosenContestants[2][:DanceMoves][:DistortedTimings2].push(timing+128)
      
      #distort the backup timings
      self.distortMoveTimings(@chosenContestants[0][:DanceMoves][:DistortedTimings2])
      self.distortMoveTimings(@chosenContestants[1][:DanceMoves][:DistortedTimings2])
      self.distortMoveTimings(@chosenContestants[2][:DanceMoves][:DistortedTimings2])
      
      #copy the player's move type to all the AIs in real-time
      @chosenContestants[0][:DanceMoves][:ButtonTypes2].push(direction)
      @chosenContestants[0][:DanceMoves][:DistortedTypes2].push(direction)
      
      @chosenContestants[1][:DanceMoves][:ButtonTypes2].push(direction)
      @chosenContestants[1][:DanceMoves][:DistortedTypes2].push(direction)
      
      @chosenContestants[2][:DanceMoves][:ButtonTypes2].push(direction)
      @chosenContestants[2][:DanceMoves][:DistortedTypes2].push(direction)
    
      #distort the backup types
      #this will have a random chance to make the backup dancer AIs choose
      #the wrong move type as a response
      self.distortBackupTypes(@chosenContestants[0][:DanceMoves][:DistortedTypes2])
      self.distortBackupTypes(@chosenContestants[1][:DanceMoves][:DistortedTypes2])
      self.distortBackupTypes(@chosenContestants[2][:DanceMoves][:DistortedTypes2])
      
      #now that everything is distorted, copy the distorted timings to PkmnSpriteMoveTiming
      #and copy the distorted types to PkmnSpriteMoveDirection
      @chosenContestants[0][:DanceMoves][:PkmnSpriteMoveTiming2] = Marshal.load(Marshal.dump(@chosenContestants[0][:DanceMoves][:DistortedTimings2]))
      @chosenContestants[0][:DanceMoves][:PkmnSpriteMoveDirection2] = Marshal.load(Marshal.dump(@chosenContestants[0][:DanceMoves][:DistortedTypes2]))
      
      @chosenContestants[1][:DanceMoves][:PkmnSpriteMoveTiming2] = Marshal.load(Marshal.dump(@chosenContestants[1][:DanceMoves][:DistortedTimings2]))
      @chosenContestants[1][:DanceMoves][:PkmnSpriteMoveDirection2] = Marshal.load(Marshal.dump(@chosenContestants[1][:DanceMoves][:DistortedTypes2]))
      
      @chosenContestants[2][:DanceMoves][:PkmnSpriteMoveTiming2] = Marshal.load(Marshal.dump(@chosenContestants[2][:DanceMoves][:DistortedTimings2]))
      @chosenContestants[2][:DanceMoves][:PkmnSpriteMoveDirection2] = Marshal.load(Marshal.dump(@chosenContestants[2][:DanceMoves][:DistortedTypes2]))
      
    end #if @dancerTurn == 4 && @setOfMoves == 1
    
  end #def self.movePlayer
  
  #=========================
  # Player Button Sprites
  #=========================
  def self.placePlayerButton(direction)
    #this method will place a button sprite down when the player moves
    @moveButtonCounter += 1
    #initiate a sprite for the move
    @moveButtonSprites["move#{@moveButtonCounter}"] = AnimatedSprite.new("Graphics/Pictures/Contest/dance/player #{direction}", 3, 28, 32, 2, @viewport)
    @moveButtonSprites["move#{@moveButtonCounter}"].x = @sprites["jigglypuff"].x
    @moveButtonSprites["move#{@moveButtonCounter}"].y = @chosenContestants[3][:DanceMoves][:MoveSpriteY]
    @moveButtonSprites["move#{@moveButtonCounter}"].z = @chosenContestants[3][:DanceMoves][:MoveSpriteZ]
    @moveButtonSprites["move#{@moveButtonCounter}"].play
  end #self.placePlayerButton(direction)
  
  #================================================
  #=================== Judging ====================
  #================================================
  def self.judgeMove(contestant)
    #this method will give an "excellent", a "good", or a "miss"
    #this method will need to be called before the dancer's timing and move types
    #are deleted from their queues
    
    case @setOfMoves
    when 1
      spriteMoveDir = contestant[:DanceMoves][:PkmnSpriteMoveDirection1]
      buttonTypes = contestant[:DanceMoves][:ButtonTypes1]
      spriteMoveTiming = contestant[:DanceMoves][:PkmnSpriteMoveTiming1]
      buttonPlacementTiming = contestant[:DanceMoves][:ButtonPlacementTimings1]
    when 2
      spriteMoveDir = contestant[:DanceMoves][:PkmnSpriteMoveDirection2]
      buttonTypes = contestant[:DanceMoves][:ButtonTypes2]
      spriteMoveTiming = contestant[:DanceMoves][:PkmnSpriteMoveTiming2]
      buttonPlacementTiming = contestant[:DanceMoves][:ButtonPlacementTimings2]
    end
    
    #=================================
    #======= Judge Direction ========
    #=================================
    contestant[:DanceMoves][:gradeValue] = nil
    #first is comparing the contestant's PkmnSpriteMoveDirection arrays
    #(depending on @setOfMoves) to ButtonTypes1 arrays
    
    if spriteMoveDir[0] != buttonTypes[0]
      contestant[:DanceMoves][:gradeValue] = "Miss"
    end #if contestant[:DanceMoves][:PkmnSpriteMoveDirection1] != contestant[:DanceMoves][:ButtonTypes1]
    
    #=================================
    #========= Judge Timing ==========
    #=================================
    #next is comparing the contestant's PkmnSpriteMoveTiming arrays to the
    #ButtonPlacementTiming arrays
    #this check is skipped if the contestant has already gotten a miss from
    #judging the move type
    if contestant[:DanceMoves][:gradeValue] != "Miss"
      #is the timing exactly correct?
      if spriteMoveTiming[0] == buttonPlacementTiming[0]
        #excellent timing
        contestant[:DanceMoves][:gradeValue] = "Excellent"
        #add to the contestant's excellent streak
        contestant[:DanceMoves][:gradeExcellentStreak] += 1
        #add 2 points
        contestant[:DancePoints] += 2
      elsif spriteMoveTiming[0] == buttonPlacementTiming[0] - 1 || spriteMoveTiming[0] == buttonPlacementTiming[0] + 1
        #off by only one, goog timing
        contestant[:DanceMoves][:gradeValue] = "Good"
        #end the contestant's excellent streak
        contestant[:DanceMoves][:gradeExcellentStreak] = 0
        #add 1 point
        contestant[:DancePoints] += 1
      else
        #off by two or more, miss
        contestant[:DanceMoves][:gradeValue] = "Miss"
        #end the contestant's excellent streak
        contestant[:DanceMoves][:gradeExcellentStreak] = 0
        #no points added
      end #if spriteMoveTiming[0] == buttonPlacementTiming[0]
    end #if contestant[:DanceMoves][:gradeValue] != "Miss"
    
    #set the grade countdown to nil to signal the code that a move was just
    #judged
    contestant[:DanceMoves][:gradeCountdown] = nil
    
  end #def self.judgeMove
  
  def self.judgePlayerMove(direction)
    #this method will give an "excellent", a "good", or a "miss"
    #this method will need to be called before the dancer's timing and move types
    #are deleted from their queues
    
    if @dancerTurn != 4
      #if @dancerTurn != 4, judge based on lead dancer's moves
    
      case @setOfMoves
      when 1
        buttonTypes = @chosenContestants[3][:DanceMoves][:ButtonTypes1]
        buttonPlacementTiming = @chosenContestants[3][:DanceMoves][:ButtonPlacementTimings1]
      when 2
        buttonTypes = @chosenContestants[3][:DanceMoves][:ButtonTypes2]
        buttonPlacementTiming = @chosenContestants[3][:DanceMoves][:ButtonPlacementTimings2]
      end
    
      #judge move timing first to find out which move the player is trying to
      #match
      #=================================
      #========= Judge Timing ==========
      #=================================
      @chosenContestants[3][:DanceMoves][:gradeValue] = nil
      
      #find out which move in buttonPlacementTiming is closest to the current
      #@timerY. That's the move the player is trying to match
      attemptedTiming = self.closest(buttonPlacementTiming, @timerY)
      
      #is the timing exactly correct?
      if @timerY == attemptedTiming
        #excellent timing
        @chosenContestants[3][:DanceMoves][:gradeValue] = "Excellent"
        #print "excellent, @timerY is #{@timerY}, and you tried to match #{attemptedTiming}"
        #add to the contestant's excellent streak
        @chosenContestants[3][:DanceMoves][:gradeExcellentStreak] += 1
        #add 2 points
        @chosenContestants[3][:DancePoints] += 2
      elsif @timerY == attemptedTiming - 1 || @timerY == attemptedTiming + 1 || @timerY == attemptedTiming - 2 || @timerY == attemptedTiming + 2
        #off by only one, goog timing
        @chosenContestants[3][:DanceMoves][:gradeValue] = "Good"
        #print "good, @timerY is #{@timerY}, and you tried to match #{attemptedTiming}"
        #end the contestant's excellent streak
        @chosenContestants[3][:DanceMoves][:gradeExcellentStreak] = 0
        #add 1 point
        @chosenContestants[3][:DancePoints] += 1
      else
        #off by two or more, miss
        @chosenContestants[3][:DanceMoves][:gradeValue] = "Miss"
        #print "miss, @timerY is #{@timerY}, and you tried to match #{attemptedTiming}"
        #end the contestant's excellent streak
        @chosenContestants[3][:DanceMoves][:gradeExcellentStreak] = 0
        #no points added
      end #if @chosenContestants[3] == buttonPlacementTiming[0]
    
      #=================================
      #======= Judge Direction ========
      #=================================
      #skip checking if the move type matches if the timing is already a miss
      
      #get the index of the timing to see if the player chose the correct
      #direction
      moveTypeToMatch = buttonTypes[buttonPlacementTiming.index(attemptedTiming)]
      
      if @chosenContestants[3][:DanceMoves][:gradeValue] != "Miss"
        if direction != moveTypeToMatch
          @chosenContestants[3][:DanceMoves][:gradeValue] = "Miss"
        end #if direction != buttonTypes[0]
      end #if @chosenContestants[3][:DanceMoves][:gradeValue] != "Miss"
    else
      #if @dancerTurn == 4, judge based on possible move timings and not at all
      #on direction
      
      #judge move timing first to find out which move the player is trying to
      #match    
      #=================================
      #========= Judge Timing ==========
      #=================================
      @chosenContestants[3][:DanceMoves][:gradeValue] = nil
      
      #find out which move in buttonPlacementTiming is closest to the current
      #@timerY. That's the move the player is trying to match
      attemptedTiming = self.closest(@possibleMovesForAI, @timerY)
      #is the timing exactly correct?
      if @timerY == attemptedTiming
        #excellent timing
        @chosenContestants[3][:DanceMoves][:gradeValue] = "Excellent"
        #add to the contestant's excellent streak
        @chosenContestants[3][:DanceMoves][:gradeExcellentStreak] += 1
        #add 2 points
        @chosenContestants[3][:DancePoints] += 2
      elsif @timerY == attemptedTiming - 1 || @timerY == attemptedTiming + 1 || @timerY == attemptedTiming - 2 || @timerY == attemptedTiming + 2
        #off by only one, goog timing
        @chosenContestants[3][:DanceMoves][:gradeValue] = "Good"
        #end the contestant's excellent streak
        @chosenContestants[3][:DanceMoves][:gradeExcellentStreak] = 0
        #add 1 point
        @chosenContestants[3][:DancePoints] += 1
      else
        #off by two or more, miss
        @chosenContestants[3][:DanceMoves][:gradeValue] = "Miss"
        #end the contestant's excellent streak
        @chosenContestants[3][:DanceMoves][:gradeExcellentStreak] = 0
        #no points added
      end #if @chosenContestants[3] == buttonPlacementTiming[0]
      
    end #if @dancerTurn != 4
    
    #set the grade countdown to nil to signal the code that a move was just
    #judged
    @chosenContestants[3][:DanceMoves][:gradeCountdown] = nil
    
  end #def self.judgeMove
  
  def self.closest(moveTimingsToMatch, timing)
    #print "need to match: #{moveTimingsToMatch}, your timing: #{timing}"
    return nil if moveTimingsToMatch.empty?
    return timing if moveTimingsToMatch.include?(timing)
    lowNum = moveTimingsToMatch.reverse.find { |e| e < timing }
    return moveTimingsToMatch[0] if lowNum.nil?
    highNum = moveTimingsToMatch.find { |e| e > timing }
    return moveTimingsToMatch[-1] if highNum.nil?
    distanceFromLowNum = (timing-lowNum).abs
    distanceFromHighNum = (timing-highNum).abs
    closest = lowNum if distanceFromLowNum < distanceFromHighNum
    closest = highNum if distanceFromHighNum < distanceFromLowNum
    closest = lowNum if distanceFromLowNum == distanceFromHighNum
    return closest
  end
  
  def self.playJudgeSound(grade, streak = 0)
    #unfortunately this method causes some lag for some reason
    pbSEPlay("Contests_Dance_#{grade}#{streak}")
  end #def self.playJudgeSound
  
  #================================================
  #================= Distortion ==================
  #================================================ 
  def self.distortBackupTypes(type_pool)
    i = 0
    type_pool.length.times do
      if self.randomChanceDistort("direction") == "Correct"
        #don't distort type
      else #incorrect type
        #distort type
        possible_types = ["Front", "Jump", "Left", "Right"]
        #delete the correct type since we are choosing an incorrect move to
        #give the backup AI
        #possible_types.delete(type_pool[-1])
        possible_types.delete(type_pool[i])
        
        chosenType = rand(0..2)
        incorrectMove = possible_types[chosenType]

        type_pool[i] = incorrectMove
      end
      i += 1
    end #type_pool.length.times do
  end #def self.distortBackupTypes(type_pool)
    
  def self.showStars(contestant)
    @sprites["starsContestant#{contestant}"].dispose if @sprites["starsContestant#{contestant}"] && !@sprites["starsContestant#{contestant}"].disposed?
    #initiate a star sprite
    @sprites["starsContestant#{contestant}"] = AnimatedSprite.new("Graphics/Pictures/Contest/dance/starAnimation", 6, 224, 256, 2, @viewport)
    @sprites["starsContestant#{contestant}"].x = @sprites["contestant#{contestant}"].x
    @sprites["starsContestant#{contestant}"].y = @sprites["contestant#{contestant}"].y
    @sprites["starsContestant#{contestant}"].z = 99999
    @sprites["starsContestant#{contestant}"].play
    
    #if backup dancer, make zoom x and zoom y 80%
    if (contestant == 1 && @dancerTurn != 1) || (contestant == 2 && @dancerTurn != 2) || (contestant == 3 && @dancerTurn != 3) || (contestant == 4 && @dancerTurn != 4)
      @sprites["starsContestant#{contestant}"].zoom_x = 0.8
      @sprites["starsContestant#{contestant}"].zoom_y = 0.8
    end
    
    @sprites["starsContestant#{contestant}"].mirror if rand(1..2) == 1
  end #def self.showStars(contestant)
  
end #class Dance