class Battle::AI # mostly made obsolete by Consistent_AI
  #=============================================================================
  # Main move-choosing method (moves with higher scores are more likely to be
  # chosen)
  #=============================================================================
  #def pbChooseMoves(idxBattler)
    # not used, check Consistent_AI
  #end

  #=============================================================================
  # Get scores for the given move against each possible target
  #=============================================================================
  # Wild Pokémon choose their moves randomly.
  def pbRegisterMoveWild(_user, idxMove, choices)
    move = _user.moves[idxMove]
    if ["SwitchOutTargetStatusMove", "SwitchOutUserStatusMove", 
        "SwitchOutTargetDamagingMove", "FleeFromBattle"].include?(move.function)
      choices.push([idxMove, 999, -1])
    else
      choices.push([idxMove, 100, -1])   # Move index, score, target
    end
  end

  # Trainer Pokémon calculate how much they want to use each of their moves.
  #def pbRegisterMoveTrainer(user, idxMove, choices, skill)
    # not used, check Consistent_AI
  #end

  #=============================================================================
  # Get a score for the given move being used against the given target
  #=============================================================================
  #def pbGetMoveScore(move, user, target, skill = 100)
    # not used, check Consistent_AI
  #end

  #=============================================================================
  # Add to a move's score based on how much damage it will deal (as a percentage
  # of the target's current HP)
  #=============================================================================
  #def pbGetMoveScoreDamage(score, move, user, target, skill)
    # not used, check Consistent_AI
  #end
end
