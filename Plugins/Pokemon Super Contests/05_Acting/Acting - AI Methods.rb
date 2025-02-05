class Acting
  #=========================================================
  # Move Selection
  #=========================================================
  #===================
  # Giving the AIs Movesets
  #===================
  def self.setAIMoves
    #I used bulbapedia to reference moves' style and appeal
    #https://bulbapedia.bulbagarden.net/wiki/Pikachu_(Pok%C3%A9mon)/Generation_IV_learnset#By_leveling_up
    
    #create a pokemon from the defined species of the contestant pokemon so we
    #can search its possible moves
    for h in 0...@chosenContestants.length-1
      pkmn = Pokemon.new(@chosenContestants[h][:PkmnSpecies], 100)
      tutorMoves = pkmn.species_data.tutor_moves
      levelMoves = pkmn.species_data.moves
    
      #add all tutor moves to the list of possible moves
      possibleMoves = tutorMoves.clone
      #add all level moves to the list of possible moves
      for i in 0...levelMoves.length
        possibleMoves.push(levelMoves[i][1])
      end
      
      #get a list of possible matching moves for the pokemon,
      #possible nonOpposing moves, and possible opposingMoves
      possibleMatchingMoves    = []
      possibleNonOpposingMoves = []
      possibleOpposingMoves    = []
      
      for i in 0...@matchingMoves.length
        #if i is in the list of possible moves for a pokemon, push that to
        #possibleMatchingMoves
        if possibleMoves.include?(@matchingMoves[i])
          possibleMatchingMoves.push(@matchingMoves[i])
        end
      end
      
      for i in 0...@nonOpposingMoves.length
        #if i is in the list of possible moves for a pokemon, push that to
        #possibleNonOpposingMoves
        if possibleMoves.include?(@nonOpposingMoves[i])
          possibleNonOpposingMoves.push(@nonOpposingMoves[i])
        end
      end
      
      for i in 0...@opposingMoves.length
        #if i is in the list of possible moves for a pokemon, push that to
        #possibleOpposingMoves
        if possibleMoves.include?(@opposingMoves[i])
          possibleOpposingMoves.push(@opposingMoves[i])
        end
      end
      
      #choose the moves for the AI      
      chosenMoves = []
      case @chosenRank
      when "Normal"
        #give the AI 2 moves that match the contest type and 2 moves that do
        #not oppose (opposing moves are useful for strategy)
        typeMoves = possibleMatchingMoves.sample(2)
        chosenMoves.push(typeMoves[0])
        chosenMoves.push(typeMoves[1])
        
        otherMoves = possibleNonOpposingMoves.sample(2)
        chosenMoves.push(otherMoves[0])
        chosenMoves.push(otherMoves[1])
        
      when "Great"
        #give the AI 2 moves that match the contest type and 2 moves that do
        #not oppose
        typeMoves = possibleMatchingMoves.sample(2)
        chosenMoves.push(typeMoves[0])
        chosenMoves.push(typeMoves[1])
        
        otherMoves = possibleNonOpposingMoves.sample(2)
        chosenMoves.push(otherMoves[0])
        chosenMoves.push(otherMoves[1])
        
      when "Ultra"
        #give the AI 2 moves that match the contest type, 1 move that does not
        #oppose, and 1 move that opposes
        typeMoves = possibleMatchingMoves.sample(2)
        chosenMoves.push(typeMoves[0])
        chosenMoves.push(typeMoves[1])
        
        otherMoves = possibleNonOpposingMoves.sample(1)
        chosenMoves.push(otherMoves[0])
        
        otherMoves1 = possibleOpposingMoves.sample(1)
        chosenMoves.push(otherMoves1[0])
        
      when "Master"
        #give the AI 2 moves that match the contest type and 2 moves that oppose
        typeMoves = possibleMatchingMoves.sample(2)
        chosenMoves.push(typeMoves[0])
        chosenMoves.push(typeMoves[1])
        
        otherMoves = possibleOpposingMoves.sample(2)
        chosenMoves.push(otherMoves[0])
        chosenMoves.push(otherMoves[1])
      end #case @chosenRank
      
      #convert all chosenMoves into actual moves instead of just IDs
      temp = []
	  print chosenMoves
      for i in 0...chosenMoves.length
        temp.push(Pokemon::Move.new(chosenMoves[i]))
      end
      chosenMoves = temp
      
      #assign to the contestant
      @chosenContestants[h][:PkmnMoves] = chosenMoves
    end #for h in 0...@chosenContestants.length
  end
  
  #===================
  # AI Selects a Move for the Round
  #===================
  def self.chooseAIMoves
    #===================
    # CONTESTANT 1
    #===================
    @contestant1SelectedMove = nil
    #choose a move
    moves = @chosenContestants[0][:PkmnMoves].clone
    
    if @chosenContestants[0][:MoveLastPerformed] != ""
      #can we perform the same move again?
      tempMove = GameData::Move.get(@chosenContestants[0][:MoveLastPerformed])
      lastTurnEffect = self.getEffect(tempMove, "effectCode")
    end
    
    if lastTurnEffect != "CanPerformMoveTwiceInARow"
      #get index of move that matches [:MoveLastPerformed]
      for i in 0...moves.length
        if moves[i].id == @chosenContestants[0][:MoveLastPerformed]
          #remove invalid move from list of moves to perform this turn since it was performed last turn
          moves.delete_at(i)
          break
        end #if moves[i].id == @chosenContestants[0][:MoveLastPerformed]
      end #for i in 0...moves.length
    end #if lastTurnEffect != "CanPerformMoveTwiceInARow"
    
    if @chosenContestants[0][:MovePerformedTwoTurnsAgo] == @chosenContestants[0][:MoveLastPerformed]
      #get index of move that matches [:MoveLastPerformed]
      for i in 0...moves.length
        if moves[i].id == @chosenContestants[0][:MoveLastPerformed]
          #remove invalid move from list of moves to perform this turn since it was performed twice in a row
          moves.delete_at(i)
          break
        end #if moves[i].id == @chosenContestants[0][:MoveLastPerformed]
      end #for i in 0...moves.length
    end #if @chosenContestants[0][:MovePerformedTwoTurnsAgo] == @chosenContestants[0][:MoveLastPerformed]
    
    #if the contestant is going first and there's a judge with max voltage, make
    #sure to perform a matching move if there's one available
    if @contestant_order[0] == @chosenContestants[0] && (ContestSettings::JUDGES[0][:Voltage] == 4 || ContestSettings::JUDGES[1][:Voltage] == 4 || ContestSettings::JUDGES[2][:Voltage] == 4)
      #pick a matching move if one is available
      for i in 0...moves.length
        if @matchingMoves.include?(moves[i].id)
          @contestant1SelectedMove = moves[i]
        end
      end
    else
      #pick a random available move
      @contestant1SelectedMove = moves[rand(0...moves.length)]
    end #if @contestant_order[0] == @chosenContestants[0] && (ContestSettings::JUDGES[0][:Voltage] == 4
    
    #failsafe
    @contestant1SelectedMove = moves[rand(0...moves.length)] if @contestant1SelectedMove == nil
    
    #===================
    # CONTESTANT 2
    #===================
    @contestant2SelectedMove = nil
    #choose a move
    moves = @chosenContestants[1][:PkmnMoves].clone
    
    if @chosenContestants[1][:MoveLastPerformed] != ""
      #can we perform the same move again?
      tempMove = GameData::Move.get(@chosenContestants[1][:MoveLastPerformed])
      lastTurnEffect = self.getEffect(tempMove, "effectCode")
    end
    
    if lastTurnEffect != "CanPerformMoveTwiceInARow"
      #get index of move that matches [:MoveLastPerformed]
      for i in 0...moves.length
        if moves[i].id == @chosenContestants[1][:MoveLastPerformed]
          #remove invalid move from list of moves to perform this turn since it was performed last turn
          moves.delete_at(i)
          break
        end #if moves[i].id == @chosenContestants[1][:MoveLastPerformed]
      end #for i in 0...moves.length
    end #if lastTurnEffect != "CanPerformMoveTwiceInARow"
    
    if @chosenContestants[1][:MovePerformedTwoTurnsAgo] == @chosenContestants[1][:MoveLastPerformed]
      #get index of move that matches [:MoveLastPerformed]
      for i in 0...moves.length
        if moves[i].id == @chosenContestants[1][:MoveLastPerformed]
          #remove invalid move from list of moves to perform this turn since it was performed twice in a row
          moves.delete_at(i)
          break
        end #if moves[i].id == @chosenContestants[1][:MoveLastPerformed]
      end #for i in 0...moves.length
    end #if @chosenContestants[1][:MovePerformedTwoTurnsAgo] == @chosenContestants[1][:MoveLastPerformed]
    
    #if the contestant is going first and there's a judge with max voltage, make
    #sure to perform a matching move if there's one available
    if @contestant_order[0] == @chosenContestants[1] && (ContestSettings::JUDGES[0][:Voltage] == 4 || ContestSettings::JUDGES[1][:Voltage] == 4 || ContestSettings::JUDGES[2][:Voltage] == 4)
      #pick a matching move if one is available
      for i in 0...moves.length
        if @matchingMoves.include?(moves[i].id)
          @contestant2SelectedMove = moves[i]
        end
      end
    else
      #pick a random available move
      @contestant2SelectedMove = moves[rand(0...moves.length)]
    end #if @contestant_order[0] == @chosenContestants[1] && (ContestSettings::JUDGES[0][:Voltage] == 4
    
    #failsafe
    @contestant2SelectedMove = moves[rand(0...moves.length)] if @contestant2SelectedMove == nil
    
    #===================
    # CONTESTANT 3
    #===================
    @contestant3SelectedMove = nil
    #choose a move
    moves = @chosenContestants[2][:PkmnMoves].clone
    
    if @chosenContestants[1][:MoveLastPerformed] != ""
      #can we perform the same move again?
      tempMove = GameData::Move.get(@chosenContestants[1][:MoveLastPerformed])
      lastTurnEffect = self.getEffect(tempMove, "effectCode")
    end
    
    if lastTurnEffect != "CanPerformMoveTwiceInARow"
      #get index of move that matches [:MoveLastPerformed]
      for i in 0...moves.length
        if moves[i].id == @chosenContestants[2][:MoveLastPerformed]
          moves.delete_at(i)
          break
        end #if moves[i].id == @chosenContestants[2][:MoveLastPerformed]
      end #for i in 0...moves.length
    end #if lastTurnEffect != "CanPerformMoveTwiceInARow"
    
    if @chosenContestants[2][:MovePerformedTwoTurnsAgo] == @chosenContestants[2][:MoveLastPerformed]
      #get index of move that matches [:MoveLastPerformed]
      for i in 0...moves.length
        if moves[i].id == @chosenContestants[2][:MoveLastPerformed]
          #remove invalid move from list of moves to perform this turn since it was performed twice in a row
          moves.delete_at(i)
          break
        end #if moves[i].id == @chosenContestants[2][:MoveLastPerformed]
      end #for i in 0...moves.length
    end #if @chosenContestants[2][:MovePerformedTwoTurnsAgo] == @chosenContestants[2][:MoveLastPerformed]
    
    #if the contestant is going first and there's a judge with max voltage, make
    #sure to perform a matching move if there's one available
    if @contestant_order[0] == @chosenContestants[2] && (ContestSettings::JUDGES[0][:Voltage] == 4 || ContestSettings::JUDGES[1][:Voltage] == 4 || ContestSettings::JUDGES[2][:Voltage] == 4)
      #pick a matching move if one is available
      for i in 0...moves.length
        if @matchingMoves.include?(moves[i].id)
          @contestant2SelectedMove = moves[i]
        end
      end
    else
      #pick a random available move
      @contestant2SelectedMove = moves[rand(0...moves.length)]
    end #if @contestant_order[0] == @chosenContestants[2] && (ContestSettings::JUDGES[0][:Voltage] == 4
    
    #failsafe
    @contestant3SelectedMove = moves[rand(0...moves.length)] if @contestant3SelectedMove == nil
    
  end #def self.chooseAIMoves
  
  #=========================================================
  # Judge Selection
  #=========================================================
  def self.chooseAIJudges
    case @chosenRank
    when "Normal"
      avoidanceChance = ContestSettings::JUDGE_AVOIDANCE_NORMAL
    when "Super"
      avoidanceChance = ContestSettings::JUDGE_AVOIDANCE_GREAT
    when "Hyper"
      avoidanceChance = ContestSettings::JUDGE_AVOIDANCE_ULTRA
    when "Master"
      avoidanceChance = ContestSettings::JUDGE_AVOIDANCE_MASTER
    end
    
    #========================
    # Contestant 1 Judge Pick
    #========================
    decision = rand(1..100)
    if decision.between?(1,avoidanceChance)
      #avoid same judge as player picked
      loop do
        @contestant1SelectedJudge = ContestSettings::JUDGES[rand(0...ContestSettings::JUDGES.length)]
        if @contestant1SelectedJudge != @playerSelectedJudge
          break
        end
      end #loop do
    else
      #do not do any calculation to avoid, but still might pick same judge due
      #to random chance
      @contestant1SelectedJudge = ContestSettings::JUDGES[rand(0...ContestSettings::JUDGES.length)]
    end
    
    #========================
    # Contestant 2 Judge Pick
    #========================
    decision = rand(1..100)
    if decision.between?(1,avoidanceChance)
      #avoid same judge as player picked
      loop do
        @contestant2SelectedJudge = ContestSettings::JUDGES[rand(0...ContestSettings::JUDGES.length)]
        if @contestant2SelectedJudge != @playerSelectedJudge
          break
        end
      end #loop do
    else
      #do not do any calculation to avoid, but still might pick same judge due
      #to random chance
      @contestant2SelectedJudge = ContestSettings::JUDGES[rand(0...ContestSettings::JUDGES.length)]
    end
    
    #========================
    # Contestant 3 Judge Pick
    #========================
    decision = rand(1..100)
    if decision.between?(1,avoidanceChance)
      #avoid same judge as player picked
      loop do
        @contestant3SelectedJudge = ContestSettings::JUDGES[rand(0...ContestSettings::JUDGES.length)]
        if @contestant3SelectedJudge != @playerSelectedJudge
          break
        end
      end #loop do
    else
      #do not do any calculation to avoid, but still might pick same judge due
      #to random chance
      @contestant3SelectedJudge = ContestSettings::JUDGES[rand(0...ContestSettings::JUDGES.length)]
    end

    #========================
    # Go for Max Voltage if First to Perform
    #========================
    #if a judge is at 4 voltage before the round starts, and if an AI is first,
    #make the AI perform a matchingMove to that judge in an attempt to hit max
    #voltage
    if @contestant_order[0][:Player] == false
      #if the first contestant to go this turn is not an AI
      if ContestSettings::JUDGES[0][:Voltage] == 4
        case @contestant_order[0]
        when @chosenContestants[0]
          @contestant1SelectedJudge = ContestSettings::JUDGES[0]
        when @chosenContestants[1]
          @contestant2SelectedJudge = ContestSettings::JUDGES[0]
        when @chosenContestants[2]
          @contestant3SelectedJudge = ContestSettings::JUDGES[0]
        end #case @contestant_order[0]
      elsif ContestSettings::JUDGES[1][:Voltage] == 4
        case @contestant_order[0]
        when @chosenContestants[0]
          @contestant1SelectedJudge = ContestSettings::JUDGES[1]
        when @chosenContestants[1]
          @contestant2SelectedJudge = ContestSettings::JUDGES[1]
        when @chosenContestants[2]
          @contestant3SelectedJudge = ContestSettings::JUDGES[1]
        end #case @contestant_order[0]
      elsif ContestSettings::JUDGES[2][:Voltage] == 4
        case @contestant_order[0]
        when @chosenContestants[0]
          @contestant1SelectedJudge = ContestSettings::JUDGES[2]
        when @chosenContestants[1]
          @contestant2SelectedJudge = ContestSettings::JUDGES[2]
        when @chosenContestants[2]
          @contestant3SelectedJudge = ContestSettings::JUDGES[2]
        end #case @contestant_order[0]
      end #if ContestSettings::JUDGES[0][:Voltage] == 4
    end #if @contestant_order[0][:Player] == false
  end #def self.chooseAIJudges
end #class Acting