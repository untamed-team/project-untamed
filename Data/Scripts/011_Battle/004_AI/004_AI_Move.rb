class Battle::AI
  #=============================================================================
  # Main move-choosing method (moves with higher scores are more likely to be
  # chosen)
  #=============================================================================
  def pbChooseMoves(idxBattler)
    # not used, check Consistent_AI
  end

  #=============================================================================
  # Get scores for the given move against each possible target
  #=============================================================================
  # Wild Pokémon choose their moves randomly.
  def pbRegisterMoveWild(_user, idxMove, choices)
    move = _user.moves[idxMove]
    if ["SwitchOutTargetStatusMove", "SwitchOutUserStatusMove", 
        "SwitchOutTargetDamagingMove", "FleeFromBattle"].include?(move.function)
      score = pbGetMoveScore(move, _user, _user, 100)
      choices.push([idxMove, score, -1]) if score > 0
    else
      choices.push([idxMove, 100, -1])   # Move index, score, target
    end
  end

  # it seems the AI isnt fooled by illusion, thats pretty neat actually
  # Trainer Pokémon calculate how much they want to use each of their moves.
  def pbRegisterMoveTrainer(user, idxMove, choices, skill)
    move = user.moves[idxMove]
    target_data = move.pbTarget(user)
    doublesThreats = pbCalcDoublesThreatsBoost(user, skill)
       # setup moves, screens/tailwi/etc, aromathe/heal bell, coaching, perish song, hazards
    if [:User, :UserSide, :UserAndAllies, :AllAllies, :AllBattlers, :FoeSide].include?(target_data.id)
      # If move does not have a defined target the AI will calculate
      # a average of every enemy currently active
      oppcounter = @battle.allBattlers.count { |b| user.opposes?(b) }
      totalScore = 0
      @battle.allBattlers.each do |b|
        next if !user.opposes?(b)
        score = pbGetMoveScore(move, user, b, skill)
        totalScore += (score / oppcounter)
      end
      choices.push([idxMove, totalScore, -1, move.name]) if totalScore > 0
    elsif target_data.num_targets == 0
      # If move affects multiple Pokémon and the AI calculates an overall
      # score at once instead of per target
      score = pbGetMoveScore(move, user, user, skill)
      choices.push([idxMove, score, -1, move.name]) if score > 0
    elsif target_data.num_targets > 1
      # If move affects multiple battlers and you don't choose a particular one
      totalScore = 0
      @battle.allBattlers.each do |b|
        next if !@battle.pbMoveCanTarget?(user.index, b.index, target_data)
        score = pbGetMoveScore(move, user, b, skill)
        totalScore += ((user.opposes?(b)) ? score : -score)
      end
      choices.push([idxMove, totalScore, -1, move.name]) if totalScore > 0
    else
      # If move affects one battler and you have to choose which one
      scoresAndTargets = []
      @battle.allBattlers.each do |b|
        doublesThreat = doublesThreats[b.index]
        next if !@battle.pbMoveCanTarget?(user.index, b.index, target_data)
        next if (target_data.targets_foe && !$movesToTargetAllies.include?(move.function)) && !user.opposes?(b)
        if !user.opposes?(b) # is ally
          # wip, allows for the AI to target allies if its good to do so (polen puff/swag/etc)
          score = pbGetMoveScore(move, user, b, 100)
          score *= -1
          echoln "\ntargeting ally #{b.name} with #{move.name} for the score of #{score}" if $AIGENERALLOG
          scoresAndTargets.push([score, b.index])
        else
          # switch abuse prevention #by low
          #echoln "target's side SwitchAbuse counter: #{b.pbOwnSide.effects[PBEffects::SwitchAbuse]}"
          if b.battle.choices[b.index][0] == :SwitchOut && b.pbOwnSide.effects[PBEffects::SwitchAbuse]>1 && 
             move.function != "PursueSwitchingFoe"
            echoln "target will switch to #{@battle.pbParty(b.index)[b.battle.choices[b.index][1]].name}" if $AIGENERALLOG
            realTarget = @battle.pbMakeFakeBattler(@battle.pbParty(b.index)[b.battle.choices[b.index][1]],false,b)
          else
            realTarget = b
          end
          score = pbGetMoveScore(move, user, realTarget, 100)
          if @battle.pbSideBattlerCount(b) > 1 # is doubles?
            score *= 1 + (doublesThreat/10.0)
            #if score >= 190 # 40%~ away from KO
            #  doublesThreat += 1 * b.stages[:DEFENSE]
            #  doublesThreat += 1 * b.stages[:SPECIAL_DEFENSE]
            #  score *= 1 + (doublesThreat/10.0)
            #else
            #  score *= 1 + (doublesThreat/10.0) if score < 180
            #end
            score = score.to_i
          end
          scoresAndTargets.push([score, realTarget.index]) if score > 0
        end
      end
      $aisuckercheck = [false, 0]
      $aiguardcheck = [false, "DoesNothingUnusableInGravity"]
      if scoresAndTargets.length > 0
        # Get the one best target for the move
        scoresAndTargets.sort! { |a, b| b[0] <=> a[0] }
        choices.push([idxMove, scoresAndTargets[0][0], scoresAndTargets[0][1], move.name])
      end
    end
  end

  #=============================================================================
  # Get a score for the given move being used against the given target
  #=============================================================================
  def pbGetMoveScore(move, user, target, skill = 100)
    # not used, check Consistent_AI
  end

  #=============================================================================
  # Add to a move's score based on how much damage it will deal (as a percentage
  # of the target's current HP)
  #=============================================================================
  def pbGetMoveScoreDamage(score, move, user, target, skill)
    # not used, check Consistent_AI
  end
end
