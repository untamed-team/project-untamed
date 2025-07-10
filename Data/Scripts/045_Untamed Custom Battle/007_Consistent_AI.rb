class Battle::AI
    # global array initialization
    attr_accessor :megaGlobalArray
    alias kiriya_initialize initialize
    def initialize(battle)
        kiriya_initialize(battle)
        @megaGlobalArray = []
    end

    # kiriya flags
    $aisuckercheck = [false, 0]
    $aiguardcheck = [false, "DoesNothingUnusableInGravity"]

    # kiriya settings
    $AIMASTERLOG_TARGET = 0 # 0 = foe, 1 = ally
    $AIMASTERLOG = (false && $DEBUG)
    $AIGENERALLOG = (false && $DEBUG)
    $movesToTargetAllies = ["HitThreeTimesAlwaysCriticalHit", "AlwaysCriticalHit",
                            "RaiseTargetAttack2ConfuseTarget", "RaiseTargetSpAtk1ConfuseTarget", 
                            "RaiseTargetAtkSpAtk2", "InvertTargetStatStages",
                            #"TargetUsesItsLastUsedMoveAgain", # game dies when instruct is used
                            "SetTargetAbilityToSimple", "SetTargetAbilityToUserAbility",
                            "SetUserAbilityToTargetAbility", "SetTargetAbilityToInsomnia",
                            "UserTargetSwapAbilities", #"NegateTargetAbility", # gastro acid can sometimes make kiriya skip turns?
                            "RedirectAllMovesToTarget", "HitOncePerUserTeamMember", 
                            "HealTargetDependingOnGrassyTerrain", "CureTargetStatusHealUserHalfOfTotalHP",
                            "HealTargetHalfOfTotalHP", "HealAllyOrDamageFoe", "Rebalancing", "RaiseTargetSpDef1"] 

    #@battle.choices[index][0] = :UseMove   # Action
    #@battle.choices[index][1] = idxMove    # Index of move to be used
    #@battle.choices[index][2] = move       # Battle::Move object
    #@battle.choices[index][3] = -1         # Index of the target
    #@battle.choices[index][4] = 0          # pbCalculatePriority of the move

    #=============================================================================
    # Main move-choosing method (moves with higher scores are more likely to be
    # chosen)
    #=============================================================================
    def pbChooseMoves(idxBattler)
        user        = @battle.battlers[idxBattler]
        wildBattler = user.wild? && !user.isBossPokemon?
        skill       = 100
        @megaGlobalArray = pbGetMidTurnGlobalChanges
        # if !wildBattler
        #     skill     = @battle.pbGetOwnerFromBattlerIndex(user.index).skill_level || 0
        # end
        # Gather information regarding opposing Sucker Punch and AoE Protect moves
        user.eachOpposing do |b|
            if targetWillMove?(b)
                targetMove = @battle.choices[b.index][2]
                if targetMove.function == "FailsIfTargetActed" && 
                  (user.moves.any? { |i| i.statusMove? } || user.moves.any? { |i| priorityAI(user,i)>0 })
                    suckerp = 80
                    suckerp = 66 if b.moves.any? { |i| i.statusMove? }
                    if rand(100) < suckerp
                        echoln("\n'prediction(2)'")
                        $aisuckercheck = [true, b]
                    end
                end
                if b.effects[PBEffects::ProtectRate] <= 1
                    if ["ProtectUserSideFromStatusMoves", "ProtectUserSideFromMultiTargetDamagingMoves", 
                        "ProtectUserSideFromPriorityMoves", "ProtectUserSideFromDamagingMovesIfUserFirstTurn"].include?(targetMove.function) &&
                       @battle.moveRevealed?(b, targetMove.id)
                        $aiguardcheck = [true, targetMove.function]
                    end
                end
            end
        end
        # Get scores and targets for each move
        # NOTE: A move is only added to the choices array if it has a non-zero
        #       score.
        choices     = []
        user.eachMoveWithIndex do |_m, i|
            next if !@battle.pbCanChooseMove?(idxBattler, i, false)
            if MEGA_EVO_MOVESET.key?(user.species) && $player.difficulty_mode?("chaos")
                oldmove = MEGA_EVO_MOVESET[user.species][0]
                newmove = MEGA_EVO_MOVESET[user.species][1]
                if _m.id == oldmove
                    user.moves[i] = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(newmove))
                    user.moves[i].pp       = 5
                    user.moves[i].total_pp = 5
                end
            end
            if wildBattler
                pbRegisterMoveWild(user, i, choices)
            else
                pbRegisterMoveTrainer(user, i, choices, skill)
            end
        end
        if $AIGENERALLOG
            echo("\nChoices and scores for: "+user.name+" \n")
            Console.echo_h2(choices)
            echo("----------------------------------------\n")
        end
        # Figure out useful information about the choices
        totalScore = 0
        maxScore   = 0
        choices.each do |c|
            totalScore += c[1]
            echoln("#{c[3]} : #{c[1].to_s}") if !wildBattler && $AIGENERALLOG
            maxScore = c[1] if maxScore < c[1]
        end
        # DemICE: Item usage AI has been moved here.
        item, idxTarget = pbEnemyItemToUse(idxBattler)
        if item
            if item[0]
                party = @battle.pbParty(idxBattler)
                # Determine target of item (always the Pokémon choosing the action)
                useType = GameData::Item.get(item[0]).battle_use
                if [1, 2].include?(useType) # Use on Pokémon
                    #idxTarget = idxTarget # Party Pokémon
                elsif user.index == idxTarget && useType == 3 # Use on Battler
                    idxTarget = @battle.battlers[idxTarget].pokemonIndex
                end
                if user.pokemonIndex == idxTarget && user.pokemonIndex == 0 && party.length>1
                    item[1] *= 0.1 
                    echo(item[0].name+": "+item[1].to_s+" discourage item usage on lead.\n")
                end
                if item[1]>maxScore
                    # Register use of item
                    @battle.pbRegisterItem(idxBattler,item[0],idxTarget)
                    PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will use item #{GameData::Item.get(item[0]).name}")
                    return
                end
            end    
        end
        # Log the available choices
        if $INTERNAL
            logMsg = "[AI] Move choices for #{user.pbThis(true)} (#{user.index}): "
            choices.each_with_index do |c, i|
                logMsg += "#{user.moves[c[0]].name}=#{c[1]}"
                logMsg += " (target #{c[2]})" if c[2] >= 0
                logMsg += ", " if i < choices.length - 1
            end
            PBDebug.log(logMsg)
        end
        # if you gradually swap out all parts of a boat, is it still the same boat?
        if $AIMASTERLOG # master debug idea by JZ #by low
            fakeTarget = nil
            if $AIMASTERLOG_TARGET == 1 # ally
                user.allAllies.each do |b|
                    next if !b.near?(user.index)
                    fakeTarget = @battle.battlers[b.index]
                end
            else                        # enemy
                fakeTarget = user.pbDirectOpposing
            end
            File.open("AI_master_log.txt", "a") do |line|
                line.puts "-----------------------------------------------------------------------"
                line.puts "                      Score Board for #{user.name}"
                line.puts "-----------------------------------------------------------------------"
            end
            move_keys = GameData::Move.keys
            bestscore = [["Atomic Splash",-991987]]
            move_keys.each do |i|
                break if fakeTarget.nil?
                mirrored = Pokemon::Move.new(i)
                mirrmove = Battle::Move.from_pokemon_move(@battle, mirrored)
                next if mirrored==nil
                next if !$movesToTargetAllies.include?(mirrmove.function) && $AIMASTERLOG_TARGET == 1
                next if ["AttackOneTurnLater", "DoesNothingUnusableInGravity", "DoesNothingCongratulations", "DoesNothingFailsIfNoAlly", "DoubleMoneyGainedFromBattle"].include?(mirrmove.function)
                case mirrmove.category
                when 0 then moveCateg = "Physical"
                when 1 then moveCateg = "Special"
                when 2 then moveCateg = "Status"
                end
                next if moveCateg.nil?
                
                fakeScore = pbGetMoveScore(mirrmove, user, fakeTarget, 100)
                fakeScore *= -1 if $AIMASTERLOG_TARGET == 1
                File.open("AI_master_log.txt", "a") do |line|
                    line.puts "Move " + mirrored.name.to_s + " ( Category: " + moveCateg + " ) " + "has final score " + fakeScore.to_s
                end
                bestscore.push([mirrored.name.to_s, fakeScore])
            end

            sortedscores = bestscore.sort { |a, b| b[1] <=> a[1] }
            File.open("AI_scoreboard.txt", "a") do |line|
                line.puts "-----------------------------------------------------------------------"
                line.puts "                   High Score Board for #{user.name}"
                line.puts "-----------------------------------------------------------------------"
                for i in 0..sortedscores.length
                    next if sortedscores[i].nil?
                    next if sortedscores[i][0]=="Atomic Splash"
                    line.puts "Move " + sortedscores[i][0].to_s + " has the final score " + sortedscores[i][1].to_s
                end
            end
        end
        choices.shuffle! if user.wild?
        # Checking if switching is preferred
        if !user.wild? #!wildBattler
            # Decide whether all choices are bad, and if so, try switching instead
            badMoves = attemptedSwitching = false
            if (maxScore <= 90 && user.turnCount > 2) || 
               (maxScore <= 80 && user.turnCount > 3)
                badMoves = true
            end
            if !badMoves && totalScore <= 300
                badMoves = true
                choices.each do |c|
                    next if !user.moves[c[0]].statusMove?
                    badMoves = false if c[1] > 115
                    break
                end
            end
            if badMoves && pbEnemyShouldWithdrawEx?(idxBattler, true)
                attemptedSwitching = true
                if $INTERNAL
                    PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will switch due to terrible moves 1")
                end
                return
            end
            # Check the foe's damage potential, and if it is a lot, try switching
            if !attemptedSwitching
                shouldSwitch = false
                aspeed = pbRoughStat(user,:SPEED,100)
                user.eachOpposing do |b|
                    next if @battle.choices[b.index][0] == :SwitchOut
                    ospeed = pbRoughStat(b,:SPEED,100)
                    userFasterThanTarget = ((aspeed>=ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))

                    bestmove = bestMoveVsTarget(b,user,skill) # [maxdam,maxmove,maxprio,physorspec]
                    maxdam = bestmove[0]
                    maxpri = bestmove[2]
                    maxdampercent = maxdam * 100.0 / user.hp
                    maxpripercent = maxpri * 100.0 / user.hp

                    if userFasterThanTarget
                        userBestmove = bestMoveVsTarget(user,b,skill) # [userMaxdam,0,userMaxpri,0]
                        userMaxdam = userBestmove[0]
                        userMaxpri = userBestmove[2]
                        userMaxdampercent = userMaxdam * 100.0 / b.hp
                        userMaxpripercent = userMaxpri * 100.0 / b.hp

                        if (maxpripercent >= 40 && userMaxpripercent < maxpripercent) ||
                           (maxdampercent >= 50 && userMaxdampercent < maxdampercent)
                            shouldSwitch = true
                            break
                        end
                    else
                        if maxpripercent >= 50 || maxdampercent >= 40
                            shouldSwitch = true
                            break
                        end
                    end
                end

                if shouldSwitch && pbEnemyShouldWithdrawEx?(idxBattler, true)
                    attemptedSwitching = true
                    if $INTERNAL
                        PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will switch due to foe's threatening a lot of damage")
                    end
                    return
                end
            end
        end
        bestScore = ["Splash",0]
        # If there are no calculated choices, pick one at random
        if choices.length == 0
            PBDebug.log("[AI] #{user.pbThis} (#{user.index}) doesn't want to use any moves; picking one at random")
            user.eachMoveWithIndex do |_m, i|
                next if !@battle.pbCanChooseMove?(idxBattler, i, false)
                choices.push([i, 100, -1])   # Move index, score, target
            end
            if choices.length == 0   # No moves are physically possible to use; use Struggle
                @battle.pbAutoChooseMove(user.index)
            end
        else
            choices.each do |c|
                if bestScore[1] < c[1]
                    bestScore[1] = c[1]
                    bestScore[0] = c[0]
                end
            end
        end
        if bestScore[0] == "Splash"
            if !user.wild?
                if !attemptedSwitching && pbEnemyShouldWithdrawEx?(idxBattler, true)
                    PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will switch due to terrible moves 2") if $INTERNAL
                    return
                end
            end
            
            # if switching isnt a option, randomly choose a move from the choices and register it 
            randNum = pbAIRandom(totalScore)
            choices.each do |c|
                randNum -= c[1]
                next if randNum >= 0
                @battle.pbRegisterMove(idxBattler, c[0], false)
                @battle.pbRegisterTarget(idxBattler, c[2]) if c[2] >= 0
                break
            end
        end
        # Choose the best move possible always (if one thing does not suck)
        choices.each do |c|
            next if bestScore[0] != c[0]
            @battle.pbRegisterMove(idxBattler, c[0], false)
            @battle.pbRegisterTarget(idxBattler, c[2]) if c[2] >= 0
        end
        # Log the result
        if @battle.choices[idxBattler][2]
            PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will use #{@battle.choices[idxBattler][2].name}")
        end
        if $AIGENERALLOG
            echoln("")
            echo("\n---------------------------------------------")
            echo("\n          !!! ENDING THE TURN !!!")
            echo("\n---------------------------------------------")
            echoln("")
        end
    end
  
    #=============================================================================
    # Get a score for the given move being used against the given target
    #=============================================================================
    def pbGetMoveScore(move, user, target, skill = 100)
        # Set up initial values
        # for 80 initScore, dmg move = KO if score == 230 
        skill = 100
        initScore = 80
        # Main score calcuations
        if move.damagingMove? && !(move.function == "HealAllyOrDamageFoe" && !user.opposes?(target))
            score = pbGetMoveScoreFunctionCode(initScore, move, user, target, skill)
            # Adjust score if this move has priority, whether that is negative or positive
            score = pbAIPrioSpeedCheck(score, move, user, target)
            initScore = score
            # Adjust score based on how much damage it can deal # DemICE moved damage calc to the beginning
            score = pbGetMoveScoreDamage(score, move, user, target, skill, initScore)
        else # Status moves # each status move has a value tied to them
            statusDamage = pbStatusDamage(move)
            return 0 if statusDamage <= 0
            # Mult varies between 1.037x at 5 status dmg and 1.499x at 100 status dmg
            score = initScore * (1 + (0.5 / (1 + Math.exp(-0.1 * (statusDamage - 30)))))
            initScore = score
            score = pbGetMoveScoreFunctionCode(score, move, user, target, skill)
            score = pbAIPrioSpeedCheck(score, move, user, target)
            # Prefer status moves if level difference is significantly high
            if user.level - 5 > target.level
                score *= 1.1
            else
                # Don't prefer set up moves if it was already used and still have raised stats
                if user.SetupMovesUsed.include?(move.id) && user.hasRaisedStatStages?
                    score *= 0.7
                end
            end
            # IF future sight is about to hit, account for its damage when calcing protect moves
            # ("ProtectRate" check is done above)
            if ["ProtectUser", "ProtectUserBanefulBunker", "ProtectUserFromTargetingMovesSpikyShield", 
                "ProtectUserFromDamagingMovesKingsShield", "ProtectUserFromDamagingMovesObstruct"].include?(move.function)
                roughFSDamage = futureSightRoughDamage(target, skill)
                if roughFSDamage > 0 && score > 80
                    miniscore = 1 + (roughFSDamage / target.hp)
                    echoln "score for protect+FS #{miniscore}" if $AIGENERALLOG
                    score += miniscore
                end
            end
        end
        if $AIMASTERLOG
            File.open("AI_master_log.txt", "a") do |line|
                line.puts "Move " + move.name.to_s + " has initial score " + initScore.to_s
            end
        end
        # Account for the accuracy of the move
        accuracy = pbRoughAccuracy(move, user, target, skill)
        accuracy = 100 if accuracy > 100
        score -= (100 - accuracy) * (4 / 3.0) if accuracy < 100
        # A score of 0 here means it should not be used 
        # ...unless it is a good move to target allies, which are stored on the negatives
        return 0 if score <= 0 && !$movesToTargetAllies.include?(move.function)
        # DemICE Converted all score alterations to multiplicative
        # Don't prefer moves that directly affect the target if they'd be semi-invulnerable
        target_data = move.pbTarget(user)
        if ![:User, :UserSide, :UserAndAllies, :AllAllies, :AllBattlers, :FoeSide].include?(target_data.id)
            if target.semiInvulnerable? || target.effects[PBEffects::SkyDrop] >= 0
                aspeed = pbRoughStat(user,:SPEED,skill)
                ospeed = pbRoughStat(target,:SPEED,skill)
                miss = true
                miss = false if user.hasActiveAbility?(:NOGUARD) || target.hasActiveAbility?(:NOGUARD)
                miss = false if ((aspeed<=ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) && priorityAI(user,move)<1 # DemICE
                if miss && aspeed > ospeed
                    # Knows what can get past semi-invulnerability
                    if target.effects[PBEffects::SkyDrop] >= 0 ||
                       target.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
                                               "TwoTurnAttackInvulnerableInSkyParalyzeTarget",
                                               "TwoTurnAttackInvulnerableInSkyTargetCannotAct")
                        miss = false if move.hitsFlyingTargets?
                    elsif target.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground")
                        miss = false if move.hitsDiggingTargets?
                    elsif target.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderwater")
                        miss = false if move.hitsDivingTargets?
                    end
                end
                score *= 0.2 if miss
            end
        end
        # Pick a good move for the Choice items
        if user.hasActiveItem?([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF]) ||
           user.hasActiveAbility?(:GORILLATACTICS)
            if move.baseDamage >= 60
                score *= 1.3
            elsif move.damagingMove?
                score *= 1.1
            elsif move.function == "UserTargetSwapItems" && !user.hasActiveAbility?(:GORILLATACTICS)
                score *= 1.2  # Trick
            else
                score *= 0.8
            end
        end
        # If user is asleep, prefer moves that are usable while asleep
        # DemICE check if it'll wake up this turn
        if user.status == :SLEEP && user.statusCount > 1
            if move.usableWhenAsleep?
                score *= 2
            else
                score *= 0.5
            end
        end
        # If user has Truant, prefer moves that are usable while truanting
        if user.hasActiveAbility?(:TRUANT) && user.effects[PBEffects::Truant]
            if move.usableWhenTruanting?
                score *= 2
            else
                score *= 0.5
            end
        end
        # account for chip healing from echo chamber
        if (user.hasActiveAbility?(:ECHOCHAMBER) || (user.isSpecies?(:CHIMECHO) && user.pokemon.willmega)) && 
           (move.soundMove? && move.statusMove?)
            missinghp = (user.totalhp-user.hp) * 100.0 / user.totalhp
            score += missinghp * (1.0 / 8)
        end
        # account for foe's multitarget protect moves
        if $aiguardcheck[0]
            checked = false
            case $aiguardcheck[1]
            when "ProtectUserSideFromMultiTargetDamagingMoves"
                checked = true if user.index != target.index && move.pbTarget(user).num_targets > 1 && move.damagingMove?
            when "ProtectUserSideFromStatusMoves"
                checked = true if user.index != target.index && !move.pbTarget(user).targets_all && move.statusMove?
            when "ProtectUserSideFromPriorityMoves"
                checked = true if move.canProtectAgainst? && priorityAI(user,move) > 0
            when "ProtectUserSideFromDamagingMovesIfUserFirstTurn"
                checked = true if move.canProtectAgainst? && target.turnCount == 0 && move.damagingMove?
            end
            score *= (1 / 4.0) if checked
        end
        # Don't prefer moves that are ineffective because of abilities or effects
        return 0 if pbCheckMoveImmunity(score, move, user, target, skill)
        score = score.to_i
        score = 0 if score < 0 && !$movesToTargetAllies.include?(move.function)
        return score
    end

    #=============================================================================
    # Add to a move's score based on how much damage it will deal (as a percentage
    # of the target's current HP)
    #=============================================================================
    def pbGetMoveScoreDamage(score, move, user, target, skill, initialscore = 0)
        return 0 if (score <= 0 && !($movesToTargetAllies.include?(move.function) && !user.opposes?(target)))
        # Calculate how much damage the move will do (roughly)
        baseDmg = pbMoveBaseDamage(move, user, target, skill)
        realDamage = pbRoughDamage(move, user, target, skill, baseDmg)
        mold_broken=moldbroken(user,target,move)
        globalArray = @megaGlobalArray
        procGlobalArray = processGlobalArray(globalArray)
        expectedWeather = procGlobalArray[0]

        # Try make AI not trolled by disguise
        # priority over other calcs due to hyper beam
        if target.hasActiveAbility?(:DISGUISE,false,mold_broken) && target.form == 0    
            if move.multiHitMove? || user.hasActiveAbility?(:PARENTALBOND)
                realDamage*=2.2
            else
                realDamage=(target.totalhp / 8.0)
            end
        end    

        # Two-turn attacks waste 2 turns to deal one lot of damage
        # Not halved because semi-invulnerable during use or hits first turn
        if ((["TwoTurnAttackFlinchTarget", "TwoTurnAttackParalyzeTarget", "TwoTurnAttackBurnTarget", 
              "TwoTurnAttackChargeRaiseUserDefense1", "TwoTurnAttackChargeRaiseUserSpAtk1", 
              "AttackTwoTurnsLater", "TwoTurnAttack"].include?(move.function) ||
              (move.function == "TwoTurnAttackOneTurnInSun" && 
               !([:Sun, :HarshSun].include?(expectedWeather) && !user.hasActiveItem?(:UTILITYUMBRELLA)))) && 
              !user.hasActiveItem?(:POWERHERB))
            realDamage *= (2 / 3.0)
            realDamage = 0 if pbHasSingleTargetProtectMove?(target,false)
        end
        # Special interaction for beeg guns hyper beam clones
        if move.function == "AttackAndSkipNextTurn"
            if [:PRISMATICLASER, :ETERNABEAM, :ROAROFTIME].include?(move.id) && !targetSurvivesMove(move,user,target)
            else
                if targetWillMove?(target)
                    targetMove = @battle.choices[target.index][2]
                    if targetSurvivesMove(targetMove,target,user)
                        realDamage *= 0.2
                    else
                        aspeed = pbRoughStat(user,:SPEED,skill)
                        ospeed = pbRoughStat(target,:SPEED,skill)
                        fasterAtk = ((aspeed>=ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
                        thisprio = priorityAI(user, move, globalArray)
                        thatprio = priorityAI(target, targetMove, globalArray)
                        if thatprio > 0
                            fasterAtk = (thisprio >= thatprio) ? true : false
                        end
                        if fasterAtk
                            realDamage *= 1.5
                        else
                            realDamage *= 0.2
                        end
                    end
                end
            end
        end
        # Self-KO moves should avoided (under normal circumstances) if possible
        if ["UserFaintsExplosive", "UserFaintsPowersUpInMistyTerrainExplosive", 
            "UserFaintsFixedDamageUserHP"].include?(move.function) ||
           (["UserLosesHalfOfTotalHPExplosive", "UserLosesHalfOfTotalHP"].include?(move.function) && user.takesIndirectDamage?)
            if user.hasActiveAbility?(:PARTYPOPPER)
                innatemove = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(:HEALINGWISH))
                innatescore = (pbGetMoveScore(innatemove, user, target, skill) / 2)
                innatescore >= 25 ? (score += innatescore) : (realDamage *= (2 / 3.0))
                echoln "#{move.name}'s score (#{score}) was boosted due to party popper. #{innatescore}" if $AIGENERALLOG
            else
                if user.allAllies.none? { |b| b.hasActiveAbility?(:SEANCE) }
                    wontMove = 0
                    user.allOpposing.each do |m|
                        if targetWillMove?(m)
                            targetMove = @battle.choices[m.index][2]
                            if targetSurvivesMove(targetMove,m,user)
                                realDamage *= 0.2
                            else
                                aspeed = pbRoughStat(user,:SPEED,skill)
                                ospeed = pbRoughStat(m,:SPEED,skill)
                                fasterAtk = ((aspeed>=ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
                                thisprio = priorityAI(user, move, globalArray)
                                thatprio = priorityAI(m, targetMove, globalArray)
                                if thatprio > 0
                                    fasterAtk = (thisprio >= thatprio) ? true : false
                                end
                                if fasterAtk
                                    realDamage *= 1.5
                                else
                                    realDamage *= 0.2
                                end
                            end
                        else
                            wontMove += 1
                        end
                    end
                    realDamage *= 0.2 if wontMove >= user.allOpposing.length
                end
            end
        end
        # try to avoid triggering slippery peel
        if target.hasActiveAbility?(:SLIPPERYPEEL) && !target.effects[PBEffects::SlipperyPeel] && 
           move.pbContactMove?(user) && user.affectedByContactEffect? && user.effects[PBEffects::Substitute] == 0 && 
           !user.hasActiveAbility?(:SUCTIONCUPS) && !user.effects[PBEffects::Ingrain]
            realDamage *= (2 / 3.0)
        end

        # not a fan of randomness one bit, but i cant do much about this move
        # Try play "mind games" instead of just getting baited every time.
        if move.function == "FailsIfTargetActed"
            if @battle.choices[target.index][0]!=:UseMove
                if rand(100) < 80    
                    echo("\n'Predicting' that opponent will not attack and sucker will fail")
                    score=1
                    realDamage=0
                end
            else
                if @battle.choices[target.index][1]
                    if @battle.choices[target.index][2].statusMove? && rand(100) < 66    
                        echo("\n'Predicting' that opponent will not attack and sucker will fail")
                        score=1
                        realDamage=0 
                    end
                end
            end
        end
        if $aisuckercheck[0]
            user.eachOpposing do |b|
                next unless $aisuckercheck[1] == b
                suckermove = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(:SUCKERPUNCH))
                break if pbCheckMoveImmunity(1, suckermove, b, user, 100)
                thisprio = priorityAI(user,move)
                thatprio = priorityAI(b,suckermove)
                if thisprio > thatprio
                    prioCreep = true
                elsif thisprio == thatprio
                    aspeed = pbRoughStat(user,:SPEED,skill)
                    ospeed = pbRoughStat(b,:SPEED,skill)
                    prioCreep = ((aspeed>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
                else
                    prioCreep = false
                end
                if !prioCreep
                    echo("\n'Predicting' that a opponent will use sucker punch and user is 'outspeed', thus removing #{move.name}")
                    score=1
                    realDamage=0
                end
            end
        end

        # try hitting mons that dont have available protect moves if it is a double battle
        if !(user.hasActiveAbility?(:UNSEENFIST) && move.contactMove?)
            realDamage *= (2 / 3.0) if pbHasSingleTargetProtectMove?(target) && target.allAllies.any?
        end

        # Prefer flinching external effects (note that move effects which cause
        # flinching are dealt with in the function code part of score calculation)
        if canFlinchTarget(user,target,mold_broken) && (user.hasActiveItem?([:KINGSROCK,:RAZORFANG]) || user.hasActiveAbility?(:STENCH) || move.function == "HitTwoTimesFlinchTarget")
            bestmove=bestMoveVsTarget(user,target,skill) # [maxdam,maxmove,maxprio,physorspec]
            maxdam=bestmove[0] #* 0.9
            maxmove=bestmove[1]
            if targetSurvivesMove(maxmove,user,target)
                realDamage *= 1.2 if (realDamage * 100.0 / maxdam) > 75
                realDamage *= 1.2 if move.multiHitMove?
                realDamage *= 1.3 if move.multiHitMove? && user.hasActiveAbility?(:SKILLLINK)
                realDamage *= 2.0 if user.hasActiveAbility?(:SERENEGRACE) || user.pbOwnSide.effects[PBEffects::Rainbow] > 0
                realDamage = target.hp * 0.99 if realDamage >= target.hp
            end
        end

        # account for contact punishing traits
        if move.pbContactMove?(user) && user.affectedByContactEffect? && user.takesIndirectDamage?
            if target.hasActiveAbility?([:IRONBARBS,:ROUGHSKIN]) || target.hasActiveItem?(:ROCKYHELMET)
                reflect = 0
                reflect += 12.5 if target.hasActiveAbility?([:IRONBARBS,:ROUGHSKIN])
                reflect += 16.7 if target.hasActiveItem?(:ROCKYHELMET)
                case move.function
                when "HitThreeTimesAlwaysCriticalHit", "HitThreeTimesPowersUpWithEachHit"
                    reflect *= 3
                when "HitTwoTimes", "HitTwoTimesTargetThenTargetAlly", "HitTwoTimesReload", 
                     "HitTwoTimesPoisonTarget", "HitTwoTimesFlinchTarget"
                    reflect *= 2
                when "HitTwoToFiveTimes", "HitTwoToFiveTimesOrThreeForAshGreninja", 
                     "HitTwoToFiveTimesRaiseUserSpd1LowerUserDef1"
                    if user.hasActiveAbility?(:SKILLLINK)
                        reflect *= 5
                    else
                        reflect *= 3.47
                    end
                when "HitOncePerUserTeamMember"
                    livecountuser = 0
                    @battle.eachInTeamFromBattlerIndex(user.index) do |pkmn,i|
                        next if !pkmn.able? || pkmn.status != :NONE
                        livecountuser += 1
                    end
                    reflect *= livecountuser
                when "HitThreeToFiveTimes"
                    if user.hasActiveAbility?(:SKILLLINK)
                        reflect *= 5
                    else
                        reflect *= 4.33
                    end
                end
                reflect = reflect.to_i
                bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
                if targetSurvivesMove(bestmove[1],target,user)
                    realDamage -= reflect
                    realDamage *= 0.6 if (user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && user.hp == user.totalhp
                end
                hpreflected = reflect * user.totalhp / 100
                realDamage *= 0.3 if hpreflected > user.totalhp
            end
        end

        # taking in account the damage of future sight/doom desire/premoniton
        roughFSDamage = futureSightRoughDamage(target, skill)
        if roughFSDamage > 0
            echoln "rough dmg for FS #{roughFSDamage}" if $AIGENERALLOG
            realDamage += roughFSDamage
        end

        realDamage = realDamage.to_i
        if $AIMASTERLOG
            File.open("AI_master_log.txt", "a") do |line|
                line.puts "Move " + move.name + " real damage on "+target.name+": "+realDamage.to_s
            end
        end

        # Convert damage to percentage of target's remaining HP
        damagePercentage = realDamage * 100.0 / target.hp
        #echoln "#{move.name}'s realdamage = #{realDamage}, dmgpercent = #{damagePercentage}" if user.species == :GLALIE && target.species == :GASTRONAUT && (move.type == :ICE || move.id == :RETURN)
        # Don't prefer weak attacks
        damagePercentage *= 0.5 if damagePercentage < 30
        # Prefer status moves if level difference is significantly high
        damagePercentage *= 0.5 if user.level - 5 > target.level
        # Adjust score
        if damagePercentage > 100   # Treat all lethal moves the same # DemICE
            damagePercentage = 110 
            damagePercentage += 40 # Prefer moves likely to be lethal # DemICE
            if ["RaiseUserAttack2IfTargetFaints", "RaiseUserAttack3IfTargetFaints"].include?(move.function) # DemICE: Fell Stinger should be preferred among other moves that KO
                if user.hasActiveAbility?(:CONTRARY)
                    damagePercentage-=90    
                else
                    damagePercentage+=50    
                end
            end
            if targetWillMove?(target)
                if !target.effects[PBEffects::DestinyBondPrevious] && target.hp == target.totalhp && 
                   move.pbContactMove?(user) && user.affectedByContactEffect?
                    aspeed = pbRoughStat(user,:SPEED,skill)
                    ospeed = pbRoughStat(target,:SPEED,skill)
                    fasterDBond = ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0)) || priorityAI(target, @battle.choices[target.index][2])>0
                    if (@battle.choices[target.index][2].function == "AttackerFaintsIfUserFaints" && fasterDBond) || target.effects[PBEffects::DestinyBond]
                        echoln "aborting calculations due to destiny bond, #{move.name} score = 5" if $AIGENERALLOG
                        return 5
                    end
                end
            end
            # if these moves KO, there is no need to account for their addeffect score
            statusKOarray = ["SleepTarget", "SleepTargetChangeUserMeloettaForm",
                             "PoisonTarget", "BadPoisonTarget",
                             "ParalyzeTarget", "ParalyzeFlinchTarget",
                             "BurnTarget", "BurnFlinchTarget", 
                             "FreezeTarget", "FreezeFlinchTarget", "FreezeTargetAlwaysHitsInHail",
                             "FreezeTargetSuperEffectiveAgainstWater", "ParalyzeBurnOrFreezeTarget",
                             "FlinchTarget", "FlinchTargetDoublePowerIfTargetInSky",
                             "ConfuseTarget", "NegateTargetAbilityIfTargetActed", 
                             "LowerTargetAttack1", "LowerTargetDefense1", 
                             "LowerTargetSpeed1", "LowerTargetSpAtk1", "LowerTargetSpDef1",
                             "LowerPPOfTargetLastMoveBy4", "LowerPPOfTargetLastMoveBy3",
                             "OverrideTargetStatusWithPoison", "BOOMInstall"]
            rainKOarray = ["ParalyzeTargetAlwaysHitsInRainHitsTargetInSky", 
                           "ConfuseTargetAlwaysHitsInRainHitsTargetInSky"]
            powerhKOarr = ["TwoTurnAttackParalyzeTarget", "TwoTurnAttackInvulnerableInSkyParalyzeTarget", 
                           "TwoTurnAttackBurnTarget", "TwoTurnAttackFlinchTarget"]
            if statusKOarray.include?(move.function) ||
              (rainKOarray.include?(move.function) && [:Rain, :HeavyRain].include?(expectedWeather) && !user.hasActiveItem?(:UTILITYUMBRELLA)) ||
              (powerhKOarr.include?(move.function) && user.hasActiveItem?(:POWERHERB))
                score = 80
            end
        end
        if ["HealUserByHalfOfDamageDone","HealUserByThreeQuartersOfDamageDone"].include?(move.function) ||
           (move.function == "HealUserByHalfOfDamageDoneIfTargetAsleep" && target.asleep?) ||
           ((user.hasActiveAbility?(:ECHOCHAMBER) || 
            (user.isSpecies?(:CHIMECHO) && user.pokemon.willmega)) && move.soundMove?)
            missinghp = (user.totalhp-user.hp) * 100.0 / user.totalhp
            if target.hasActiveAbility?(:LIQUIDOOZE)
                damagePercentage -= missinghp*0.5
            else
                damagePercentage += missinghp*0.4
            end
        end
        damagePercentage *= 1.3 if move.soundMove? && user.hasActiveItem?(:THROATSPRAY)
        damagePercentage = damagePercentage.to_i
        score += damagePercentage
        if $AIGENERALLOG
            echo("\n-----------------------------")
            echo("\nfor #{target.name}, from #{user.name}")
            echo("\n-----------------------------")
            echo("\n#{move.name} score before dmg = #{initialscore}")
            echo("\n#{move.name} real dmg = #{realDamage}")
            echo("\n#{move.name} dmg percent = #{damagePercentage}%%")
            echo("\n#{move.name} score = #{score}")
            echo("\n-----------------------------")
        end
        if $AIMASTERLOG
            File.open("AI_master_log.txt", "a") do |line|
                line.puts "Move " + move.name + " damage % on "+target.name+": "+damagePercentage.to_s+"%"
            end
        end
        return score
    end

    def pbCalcDoublesThreatsBoost(user,skill=100)
      threatHash = {}
      @battle.allBattlers.each do |target|
        next if !user.opposes?(target)
        aspeed = pbRoughStat(user,:SPEED,skill)
        ospeed = pbRoughStat(target,:SPEED,skill)
        increment = 0
        #threatHash[target.index] = increment
        if @battle.pbSideBattlerCount(target) > 1
          # increase threat level depending on stat boosts
          actualMaxDmg=0
          actualMaxDmg_PhysOrSpec = ""
          @battle.allSameSideBattlers(user.index).each do |b| 
            # calculate how much dmg the foes' can do
            maxFoeDmg=0
            bestTargetMove=bestMoveVsTarget(target,b,skill) # [maxdam,maxmove,maxprio,physorspec]
            maxFoeDmg=bestTargetMove[0] 
            maxFoeMove=bestTargetMove[1]
            if maxFoeDmg >= actualMaxDmg
              actualMaxDmg=maxFoeDmg 
              actualMaxDmg_PhysOrSpec=bestTargetMove[3]
            end
            weSurvive = targetSurvivesMove(maxFoeMove,target,b)
            damagePercentage = maxFoeDmg * 100.0 / b.hp
            damagePercentage = 110 if damagePercentage > 100
            damagePercentage = 99 if damagePercentage >= 100 && weSurvive
            increment += damagePercentage/100.0
          end
          #echo("\nDoubles Threat Level boost for "+target.name+": "+increment.to_s+"\n")
          if actualMaxDmg_PhysOrSpec=="physical"
            increment += 1 * target.stages[:ATTACK]  
          else
            increment += 0.5 * target.stages[:ATTACK]  
          end
          if actualMaxDmg_PhysOrSpec=="special"
            increment += 1 * target.stages[:SPECIAL_ATTACK]
          else
            increment += 0.5 * target.stages[:SPECIAL_ATTACK]
          end
          increment += 0.75 * target.stages[:DEFENSE]
          increment += 0.75 * target.stages[:SPECIAL_DEFENSE]
          increment += 1.10 * target.stages[:SPEED]

          targetRoles = pbGetPokemonRole(target, user)
          increment += 0.6 if targetRoles.include?("Sweeper")
          increment += 0.8 if targetRoles.include?("Screener")
          increment += 1.0 if targetRoles.include?("Field Setter")
          increment += 1.0 if targetRoles.include?("Weather Setter")
          increment += 1.3 if targetRoles.include?("Tailwind Setter")
          increment += 1.3 if targetRoles.include?("Trick Room Setter")

          # simulating bits of pbHardSwitchChooseNewEnemy
          enemies = []
          ownparty = @battle.pbParty(user.index)
          ownparty.each_with_index do |ptmon,i|
            enemies.push(i) if ptmon.hp>0
          end
          #echo("\nDoubles Threat Level boost for "+target.name+": "+increment.to_s+"\n")
          speedsarray = pbChooseBestNewEnemy(user.index,ownparty,enemies,false,-1,false,true)
          speedsarray.each do |switchSpeed|
            increment += 1 if ((ospeed>switchSpeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
          end
          #increment = 0 if increment < 0
          ###############################################
          echo("\nDoubles Threat Level boost from "+user.name+" for "+target.name+": "+increment.to_s+"\n") if $AIGENERALLOG
        end
        if targetWillMove?(target)
          targetMove = @battle.choices[target.index][2]
          if target.effects[PBEffects::ProtectRate] <= 1
            if ["ProtectUser", "ProtectUserBanefulBunker",
                "ProtectUserFromTargetingMovesSpikyShield",
                "ProtectUserFromDamagingMovesKingsShield",
                "ProtectUserFromDamagingMovesObstruct"].include?(targetMove.function) &&
                @battle.moveRevealed?(target, targetMove.id) && !user.hasActiveAbility?(:UNSEENFIST) &&
                !user.pbHasMoveFunction?("RemoveProtections", "RemoveProtectionsBypassSubstitute", 
                                         "HoopaRemoveProtectionsBypassSubstituteLowerUserDef1")
              if rand(100) < 66 || $aiguardcheck[0]
                increment = -10
                $aiguardcheck[0] = true
              else
                increment *= 0.5
                increment = -2 if increment == 0
              end
              echo("\nThreat Level nullified/lowered for "+target.name+": "+increment.to_s+", due to protect.\n") if $AIGENERALLOG
            end
          end
        end
        threatHash[target.index] = increment
      end
      return threatHash
    end
end
# i have a parasocial relationship with this code. it would be funny if it wasnt so pathetic