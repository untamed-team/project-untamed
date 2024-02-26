class Dance
  #================================================
  # Chance to Distort Move Timings and Directions
  #================================================
  def self.randomChanceDistort(what_to_distort)
    #valid arguments to pass are "timing" and "direction"
    
    case what_to_distort
    when "timing"
      chance_excellent = Object.const_get("ContestSettings::#{@chosenRank.upcase}_CHANCE_DANCE_TIMING_EXCELLENT")
      chance_good = Object.const_get("ContestSettings::#{@chosenRank.upcase}_CHANCE_DANCE_TIMING_GOOD")
      randomNumber = rand(1..100)
      if randomNumber.between?(1,chance_excellent)
        return "Excellent"
      elsif randomNumber.between?(chance_excellent+1,chance_excellent+chance_good)
        return "Good"
      else
        return "Miss"
      end
    when "direction"
      chance_correct = Object.const_get("ContestSettings::#{@chosenRank.upcase}_CHANCE_DANCE_DIRECTION_CORRECT")
      randomNumber = rand(1..100)
      if randomNumber.between?(1,chance_correct)
        return "Correct"
      else
        return "Incorrect"
      end #if randomNumber.between?(1,chance_correct)
    end #case what_to_distort
  end #def self.randomChanceDistort
  
  #================================================
  #==== Chance for Moves in Radid Succession =====
  #================================================
  def self.randomChanceRapidSuccession
    chance_rapid = Object.const_get("ContestSettings::#{@chosenRank.upcase}_CHANCE_MOVE_RAPID_SUCCESSION")
    randomNumber = rand(1..100)
    if randomNumber.between?(1,chance_rapid)
      return true
    else
      return false
    end #if randomNumber.between?(1,chance_rapid)
  end #def self.randomChanceRapidSuccession
  
  def self.randomChanceMoveAtBeginningEnd
    chance_beginning_end = Object.const_get("ContestSettings::#{@chosenRank.upcase}_CHANCE_MOVE_AT_BEGINNING_OR_END")
    randomNumber = rand(1..100)
    if randomNumber.between?(1,chance_beginning_end)
      return true
    else
      return false
    end #if randomNumber.between?(1,chance_beginning_end)
  end #def self.randomChanceMoveAtBeginningEnd
  
  def self.randomChanceNextMoveDifferent
    chance_different_moves = Object.const_get("ContestSettings::#{@chosenRank.upcase}_CHANCE_NEXT_MOVE_DIFFERENT")
    randomNumber = rand(1..100)
    if randomNumber.between?(1,chance_different_moves)
      return true
    else
      return false
    end #if randomNumber.between?(1,chance_different_moves)
  end #def self.randomChanceNextMoveDifferent
  
end #class Dance