class Battle::AI
  #=============================================================================
  # Get a score for the given move based on its effect
  #=============================================================================
  alias aiEffectScorePart2_pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode

  def pbGetMoveScoreFunctionCode(score, move, user, target, skill = 100)
    mold_broken = moldbroken(user,target,move)
    globalArray = pbGetMidTurnGlobalChanges
    procGlobalArray = processGlobalArray(globalArray)
    expectedWeather = procGlobalArray[0]
    expectedTerrain = procGlobalArray[1]
    aspeed = pbRoughStat(user,:SPEED,skill)
    ospeed = pbRoughStat(target,:SPEED,skill)
    userFasterThanTarget = ((aspeed>=ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
    case move.function
    #---------------------------------------------------------------------------
    when "FixedDamage20" # Sonic Boom
        if target.hp <= 20
            score *= 3.0
        elsif target.level >= 25
            score *= 0.5   # Not useful against high-level Pokemon
        end
    #---------------------------------------------------------------------------
    when "FixedDamage40" # dragon rage
        score *= 3 if target.hp <= 40
    #---------------------------------------------------------------------------
    when "FixedDamageHalfTargetHP" # Super Fang
        if target.hp == target.totalhp
            score *= 1.5
        else
            if (target.hp/1.5)<=target.totalhp
                score *= 1.3
            end
            score *= (target.hp * 100.0 / target.totalhp) / 100
        end
    #---------------------------------------------------------------------------
    when "FixedDamageUserLevel", "FixedDamageUserLevelRandom" # Seismic Toss
          score *= 2.5 if target.hp <= user.level
    #---------------------------------------------------------------------------
    when "LowerTargetHPToUserHP" # Endeavor
        if user.hp > target.hp
            score=0
        else
            if user.moves.any? { |m| priorityAI(target,m,globalArray)>0 }
                score*=1.5
            end
            if (user.hasActiveAbility?(:STURDY) || user.hasActiveItem?(:FOCUSSASH)) && user.hp == user.totalhp
                score*=1.5
                bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
                maxdam = bestmove[0]
                maxmove = bestmove[1]
                if maxdam>=user.hp
                    score*=3
                end
            end
            if (user.takesHailDamage? && expectedWeather == :Hail) || 
               (user.takesSandstormDamage? && expectedWeather == :Sandstorm)
                score*=1.5
            end
            if target.level - user.level > 9
                score*=3
            end
            if userFasterThanTarget
                score*=0.7
            end
        end
    #---------------------------------------------------------------------------
    when "OHKO", "OHKOIce", "OHKOHitsUndergroundTarget" # lol
        score -= 90 if target.hasActiveAbility?(:STURDY,false,mold_broken)
        score -= 90 if target.level >= user.level
        score = 0 if $player.difficulty_mode?("hard")
    #---------------------------------------------------------------------------
    when "DamageTargetAlly" # flame burst
        target.allAllies.each do |b|
            next if !b.near?(target)
            next if b.hp<=0
            score *= 1.2
        end
    #---------------------------------------------------------------------------
    when "PowerHigherWithUserHP" # Eruption / water spout / Dragon Energy
        if targetWillMove?(target)
            targetMove = @battle.choices[target.index][2]
            if userFasterThanTarget || priorityAI(target,targetMove,globalArray) < 1
                if !targetSurvivesMove(move,user,target)
                    score*=1.3
                end
            else
                if targetMove.damagingMove?
                    if targetSurvivesMove(targetMove,target,user)
                        damage = pbRoughDamage(targetMove,target,user,skill,targetMove.baseDamage)
                        score *= 1 - (damage / user.hp)
                    else
                        score*=0.01
                    end
                end
            end
        else
            score*=1.3 if (user.hp / user.totalhp) >= 0.75
        end
    #---------------------------------------------------------------------------
    when "PowerLowerWithUserHP" # Flail / Reversal
        if targetWillMove?(target)
            targetMove = @battle.choices[target.index][2]
            if userFasterThanTarget || priorityAI(target,targetMove,globalArray) < 1
                if !targetSurvivesMove(move,user,target)
                    score*=1.3
                else
                    score*=0.7
                end
            else
                if targetMove.damagingMove?
                    if targetSurvivesMove(targetMove,target,user)
                        damage = pbRoughDamage(targetMove,target,user,skill,targetMove.baseDamage)
                        score *= 1 + (damage / user.hp)
                    else
                        score*=0.01
                    end
                end
            end
        else
            score*=1.3 if (user.hp / user.totalhp) <= 0.33
        end
    #---------------------------------------------------------------------------
    when "PowerHigherWithTargetHP" # Crush Grip
    #---------------------------------------------------------------------------
    when "PowerHigherWithUserHappiness" # return
    #---------------------------------------------------------------------------
    when "PowerLowerWithUserHappiness" # Frustration
    #---------------------------------------------------------------------------
    when "PowerHigherWithUserPositiveStatStages" # Stored Power / Power Trip
    #---------------------------------------------------------------------------
    when "PowerHigherWithTargetPositiveStatStages" # Punishment
    #---------------------------------------------------------------------------
    when "PowerHigherWithUserFasterThanTarget" # Electro Ball
    #---------------------------------------------------------------------------
    when "PowerHigherWithTargetFasterThanUser" # Gyro Ball
    #---------------------------------------------------------------------------
    when "PowerHigherWithLessPP" # Trump Card
        if user.hp==user.totalhp
            score*=1.3
        end
        bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
        maxdam = bestmove[0]
        if maxdam<(user.hp/3.0)
            score*=1.3
        end
    #---------------------------------------------------------------------------
    when "PowerHigherWithTargetWeight" # Low Kick / grass knot
    #---------------------------------------------------------------------------
    when "PowerHigherWithUserHeavierThanTarget" # Heavy Slam
    #---------------------------------------------------------------------------
    when "PowerHigherWithConsecutiveUse", "PowerHigherWithConsecutiveUseOnUserSide"
        # Fury Cutter, Echoed Voice
        score*=0.7 if user.paralyzed?
        score*=0.7 if user.effects[PBEffects::Confusion]>0
        score*=0.7 if user.effects[PBEffects::Attract]>=0
        score*=0.8 if pbHasSingleTargetProtectMove?(target, false)
        if move.function == "PowerHigherWithConsecutiveUseOnUserSide"
            if user.lastMoveUsed == :ECHOEDVOICE
                score *= (1.1 + (user.pbOwnSide.effects[PBEffects::EchoedVoiceCounter]/10))
            end
            if !user.allAllies.empty?
                userAlly = user.allAllies.first
                if userAlly.moves.any? { |j| j&.id == :ECHOEDVOICE }
                    score *= 1.1
                    if userAlly.lastMoveUsed == :ECHOEDVOICE
                        score *= (1.2 + (user.pbOwnSide.effects[PBEffects::EchoedVoiceCounter]/10))
                    end
                end
            end
        elsif move.function == "PowerHigherWithConsecutiveUse"
            if user.lastMoveUsed == :FURYCUTTER
                score *= (1.0 + (user.effects[PBEffects::FuryCutter]/10))
            end
        end
        score*=1.1 if user.hp==user.totalhp
        bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
        maxdam = bestmove[0]
        score*=1.1 if maxdam<(user.hp/3.0)
        # these can stack
        score*=1.2 if user.hasActiveAbility?(:MOMENTUM)
        score*=1.2 if user.hasActiveItem?(:METRONOME)
    #---------------------------------------------------------------------------
    when "RandomPowerDoublePowerIfTargetUnderground" # Magnitude
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetHPLessThanHalf" # Brine
    #---------------------------------------------------------------------------
    when "DoublePowerIfUserPoisonedBurnedParalyzed" # Facade
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetAsleepCureTarget" # Wake-Up Slap
        if target.asleep? && target.effects[PBEffects::Substitute]<=0
            score*=0.8
            if user.hasActiveAbility?(:BADDREAMS) || user.pbHasMove?(:DREAMEATER) ||
               user.pbHasMove?(:NIGHTMARE)
                score*=0.3
            end
            if target.pbHasMove?(:SNORE) || target.pbHasMove?(:SLEEPTALK)
                score*=1.3
            end
        end
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetPoisoned" # Venoshock
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetParalyzedCureTarget" # Smelling Salts
        if target.paralyzed?
            score*=0.8
            if target.speed>user.speed && target.speed/2.0<user.speed
                score*=0.5
            end
        end
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetStatusProblem" # Hex (not the sexy hexy)
    #---------------------------------------------------------------------------
    when "DoublePowerIfUserHasNoItem" # Acrobatics
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetUnderwater" # Surf
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetUnderground" # Earthquake
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetInSky"
        if userFasterThanTarget && 
            target.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
                                    "TwoTurnAttackInvulnerableInSkyParalyzeTarget",
                                    "TwoTurnAttackInvulnerableInSkyTargetCannotAct")
            score *= 1.5
        end
        score*=1.2 if target.moves.any? { |j| [:BOUNCE,:FLY,:SKYDROP].include?(j&.id) }
    #---------------------------------------------------------------------------
    when "DoublePowerInElectricTerrain" # Rising Voltage
          score *= 1.4 if expectedTerrain == :Electric && target.affectedByTerrain?
    #---------------------------------------------------------------------------
    when "DoublePowerIfUserLastMoveFailed" # Stomping Tantrum
    #---------------------------------------------------------------------------
    when "DoublePowerIfAllyFaintedLastTurn" # Retaliate
    #---------------------------------------------------------------------------
    when "DoublePowerIfUserLostHPThisTurn" # Avalanche / Revenge
        if userFasterThanTarget
            score*=0.5
        end
        if user.hp==user.totalhp
            score*=1.5
            if user.hasActiveAbility?(:STURDY) || user.hasActiveItem?(:FOCUSSASH)
                score*=1.5
            end
        else
            score*=0.7
            bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
            maxdam = bestmove[0]
            if maxdam>user.hp
                score*=0.3
            end
        end
        if pbHasSetupMove?(target, false)
            score*=0.8
        end
        if targetWillMove?(target, "dmg")
            score*=1.3
        end
        miniscore=user.hp*(1.0/user.totalhp)
        score*=miniscore
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetLostHPThisTurn" # Assurance
    #---------------------------------------------------------------------------
    when "DoublePowerIfUserStatsLoweredThisTurn" # Lash Out
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetActed" # Payback
        if !userFasterThanTarget && targetWillMove?(target)
            score*=2
        end
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetNotActed" # Fishious Rend / Bolt Beak
        if @battle.choices[target.index][0] == :SwitchOut
            score*=1.2
            score*=1.25 if move.baseDamage > 80
        else
            if userFasterThanTarget
                score*=1.2
                score*=1.25 if move.baseDamage > 80
            end
        end
    #---------------------------------------------------------------------------
    when "AlwaysCriticalHit" # frost breath
        if target.hasActiveAbility?([:BATTLEARMOR, :SHELLARMOR],false,mold_broken) #|| user.effects[PBEffects::LaserFocus]
            score*=0.9
        else
            if user.opposes?(target) # is enemy
                if (target.hasActiveAbility?(:ANGERPOINT) && !target.statStageAtMax?(:ATTACK)) && 
                   targetSurvivesMove(move,user,target)
                    score*=0.5
                    score*=0.1 if target.attack>target.spatk
                end
            else # !user.opposes?(target) # is ally
                if target.hasActiveAbility?(:ANGERPOINT)
                    if !targetSurvivesMove(move,user,target) || target.statStageAtMax?(:ATTACK)
                        score=0
                    else
                        score = -100.0
                        score *= 1.2
                        enemy1 = user.pbDirectOpposing(true)
                        if enemy1.allAllies.empty?
                            enemy2 = enemy1
                        else
                            enemy2 = enemy1.allAllies.first
                        end
                        if ospeed > pbRoughStat(enemy1,:SPEED,skill) && 
                           ospeed > pbRoughStat(enemy2,:SPEED,skill)
                            score*=1.3
                        else
                            score*=0.7
                        end
                        targetTypes = typesAI(target, user, skill)
                        if Effectiveness.resistant_type?(move.type, targetTypes[0], targetTypes[1], targetTypes[2])
                            score*=2.5
                        else
                            score*=0.8
                        end
                        damage = pbRoughDamage(move,user,target,skill,move.baseDamage)
                        damage = damage * 100.0 / target.hp
                        score += (damage/2.0)
                        # + since it is on the negatives
                    end
                else
                    score=0
                end
            end
        end
    #---------------------------------------------------------------------------
    when "EnsureNextCriticalHit" # Laser Focus
        if !target.hasActiveAbility?([:BATTLEARMOR, :SHELLARMOR],false,mold_broken) && user.effects[PBEffects::LaserFocus] == 0
            miniscore = 100
            ministat=0
            ministat+=target.stages[:DEFENSE] 
            ministat+=target.stages[:SPECIAL_DEFENSE] 
            if ministat>0
                miniscore+= 10*ministat
            end
            ministat=0
            ministat+=user.stages[:ATTACK] 
            ministat+=user.stages[:SPECIAL_ATTACK] 
            if ministat>0
                miniscore+= 10*ministat
            end
            if user.effects[PBEffects::FocusEnergy]>0
                miniscore *= 0.8**user.effects[PBEffects::FocusEnergy]
            end
            miniscore/=100.0
            score*=miniscore
            if (target.hasActiveAbility?(:ANGERPOINT) && !target.statStageAtMax?(:ATTACK)) && 
               targetSurvivesMove(move,user,target)
                score*=0.5
                score*=0.1 if target.attack>target.spatk
            end
        else
            score*=0
        end
    #---------------------------------------------------------------------------
    when "StartPreventCriticalHitsAgainstUserSide"
        score -= 90 if user.pbOwnSide.effects[PBEffects::LuckyChant] > 0
    #---------------------------------------------------------------------------
    when "CannotMakeTargetFaint" # false swipe
        if !targetSurvivesMove(move,user,target)
            score*=0.1
        end
    #---------------------------------------------------------------------------
    when "UserEnduresFaintingThisTurn" # endure
        if user.hp>1
            if user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY))
                score=0
            end
            bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
            maxdam = bestmove[0]
            if maxdam>user.hp
                score*=2
            end
            if userFasterThanTarget
                score*=1.3
            else
                score*=0.5
            end
            if (user.takesHailDamage? && expectedWeather == :Hail) || 
               (user.takesSandstormDamage? && expectedWeather == :Sandstorm)
                score=0
            end
            if user.poisoned? || user.burned? || user.frozen? || user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Curse]
                score=0
            end
            if user.pbHasMove?(:PAINSPLIT) || user.pbHasMove?(:FLAIL) || user.pbHasMove?(:REVERSAL)
                score*=2
            end
            score*=3 if user.hasActiveItem?(:SALACBERRY)
            score*=2 if user.hasActiveItem?([:LIECHIBERRY, :PETAYABERRY])
            if user.pbHasMove?(:ENDEAVOR)
                score*=3
            end
            if target.poisoned? || target.burned? || target.frozen? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse]
                score*=1.5
            end
            if target.effects[PBEffects::TwoTurnAttack] && !target.inTwoTurnAttack?("TwoTurnAttackRaiseUserSpAtkSpDefSpd2")
                if userFasterThanTarget
                    score*=1.5
                end
            end
        else
            score*=0
        end
    #---------------------------------------------------------------------------
    when "StartWeakenElectricMoves" # Mud Sport
        score -= 90 if user.effects[PBEffects::MudSport]
    #---------------------------------------------------------------------------
    when "StartWeakenFireMoves" # Water Sport
        score -= 90 if user.effects[PBEffects::WaterSport]
    #---------------------------------------------------------------------------
    when "StartWeakenPhysicalDamageAgainstUserSide" # Reflect
        if user.pbOwnSide.effects[PBEffects::Reflect] > 0
            score = 0
        else
            #target=user.pbDirectOpposing(true)
            bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
            maxdam=bestmove[0] 
            maxmove=bestmove[1]
            maxphys=(bestmove[3]=="physical") 
            halfhealth=(user.totalhp/2.0)
            thirdhealth=(user.totalhp/3.0)
            roles = pbGetPokemonRole(user, target)
            score*=1.3 if user.hasActiveItem?(:LIGHTCLAY) || roles.include?("Screener")
            score*=1.3 if roles.include?("Lead")
            score*=1.2 if ["Physical Wall", "Pivot"].any? { |r| roles.include?(r) }
            if maxphys
                score*=1.2
                score*=1.4 if halfhealth>maxdam
                if !userFasterThanTarget
                    score *= 0.5 if maxdam>thirdhealth
                else
                    score *= 1.4 if (maxdam/2.0)<user.hp
                end     
            end 
            if userFasterThanTarget
                if targetWillMove?(target,"phys")
                    score *= 1.2
                end
            end
            score *= 0.1 if target.pbHasMoveFunction?("StealAndUseBeneficialStatusMove", "RemoveScreens", "LowerTargetEvasion1RemoveSideEffects") || 
                            (target.pbHasMoveFunction?("DisableTargetStatusMoves") && !userFasterThanTarget)
        end
    #---------------------------------------------------------------------------
    when "StartWeakenSpecialDamageAgainstUserSide" # Light Screen
        if user.pbOwnSide.effects[PBEffects::LightScreen] > 0
            score = 0 
        else
            #target=user.pbDirectOpposing(true)
            bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
            maxdam=bestmove[0] 
            maxmove=bestmove[1]
            maxspec=(bestmove[3]=="special") 
            halfhealth=(user.totalhp/2.0)
            thirdhealth=(user.totalhp/3.0)
            roles = pbGetPokemonRole(user, target)
            score*=1.3 if user.hasActiveItem?(:LIGHTCLAY) || roles.include?("Screener")
            score*=1.3 if roles.include?("Lead")
            score*=1.2 if ["Special Wall", "Pivot"].any? { |r| roles.include?(r) }
            if maxspec
                score*=1.2
                score*=1.4 if halfhealth>maxdam
                if !userFasterThanTarget
                    score *= 0.5 if maxdam>thirdhealth
                else
                    score *= 1.4 if (maxdam/2.0)<user.hp
                end     
            end 
            if userFasterThanTarget
                if targetWillMove?(target,"spec")
                    score *= 1.2
                end
            end
            score *= 0.1 if target.pbHasMoveFunction?("StealAndUseBeneficialStatusMove", "RemoveScreens", "LowerTargetEvasion1RemoveSideEffects") || 
                            (target.pbHasMoveFunction?("DisableTargetStatusMoves") && !userFasterThanTarget)
        end
    #---------------------------------------------------------------------------
    when "StartWeakenDamageAgainstUserSideIfHail" # aurora veil
        if user.pbOwnSide.effects[PBEffects::AuroraVeil]>0
            score = 0
        else
            if expectedWeather == :Hail
                bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
                maxdam=bestmove[0] 
                maxmove=bestmove[1]
                halfhealth=(user.totalhp/2.0)
                thirdhealth=(user.totalhp/3.0)
                roles = pbGetPokemonRole(user, target)
                score*=1.3 if user.hasActiveItem?(:LIGHTCLAY) || roles.include?("Screener")
                score*=1.3 if roles.include?("Lead")
                score*=1.2 if ["Physical Wall", "Special Wall", "Tank", "Pivot"].any? { |r| roles.include?(r) }
                score*=1.4 if halfhealth>maxdam
                score*=1.3
                if userFasterThanTarget || priorityAI(user, move, globalArray) > 0
                    score *= 1.1
                    halfdam=maxdam*0.8
                    score *= 1.4 if halfdam<user.hp
                else
                    score *= 0.5 if maxdam>thirdhealth
                end   
                score *= 0.1 if target.pbHasMoveFunction?("StealAndUseBeneficialStatusMove", "RemoveScreens", "LowerTargetEvasion1RemoveSideEffects") || 
                                (target.pbHasMoveFunction?("DisableTargetStatusMoves") && !userFasterThanTarget)   
            else
                score=0
            end
        end
    #---------------------------------------------------------------------------
    when "RemoveScreens" # brick break
        score*=1.8 if user.pbOpposingSide.effects[PBEffects::Reflect] > 0
        score*=1.3 if user.pbOpposingSide.effects[PBEffects::LightScreen] > 0
        score*=2.0 if user.pbOpposingSide.effects[PBEffects::AuroraVeil] > 0
    #---------------------------------------------------------------------------
    when "RemoveProtections", "RemoveProtectionsBypassSubstitute", "HoopaRemoveProtectionsBypassSubstituteLowerUserDef1"
        # Feint / Thousand Folds, Hyperspace Hole, Hyperspace Fury
        protected = false
        protectarray = ["ProtectUser", "ProtectUserBanefulBunker", "ProtectUserFromDamagingMovesKingsShield", 
                        "ProtectUserFromDamagingMovesObstruct", "ProtectUserFromTargetingMovesSpikyShield", 
                        "ProtectUserSideFromStatusMoves", "ProtectUserSideFromPriorityMoves", 
                        "ProtectUserSideFromMultiTargetDamagingMoves"]
        for m in target.moves
            if protectarray.include?(m.function)
                protected = true
                break
            end
            if m.function == "ProtectUserSideFromDamagingMovesIfUserFirstTurn" && target.turnCount == 0
                protected = true
                break
            end
        end
        if protected
            score *= 1.1
            if target.effects[PBEffects::ProtectRate] == 0
                score *= 1.2
                if !user.allAllies.empty?
                    ayylly = user.allAllies.first
                    if aspeed > pbRoughStat(ayylly,:SPEED,skill)
                        score *= 1.3
                    end
                end
                if targetWillMove?(target, "status")
                    if protectarray.include?(@battle.choices[target.index][2].function) ||
                        (@battle.choices[target.index][2].function == "ProtectUserSideFromDamagingMovesIfUserFirstTurn" && target.turnCount == 0)
                        score *= 3.0
                    end
                end
            else
                score *= 0.9
            end
        end
        if move.function == "HoopaRemoveProtectionsBypassSubstituteLowerUserDef1"
            if !user.isSpecies?(:HOOPA) || user.form != 1
                score = 0
            elsif user.stages[:DEFENSE] > 0
                score *= 1.2
            end
        end
    #---------------------------------------------------------------------------
    when "RecoilQuarterOfDamageDealt" # take down / wild charge
        if !user.hasActiveAbility?(:ROCKHEAD) && user.takesIndirectDamage?
            score *= 0.9
            if user.hp==user.totalhp && (user.hasActiveAbility?(:STURDY) || user.hasActiveItem?(:FOCUSSASH))
                score *= 0.7
            end
            if user.hp*(1.0/user.totalhp)>0.1 && user.hp*(1.0/user.totalhp)<0.4
                score *= 0.8
            end
            score *= 0.8 if user.effects[PBEffects::BoomInstalled]
        end
    #---------------------------------------------------------------------------
    when "RecoilThirdOfDamageDealt", "RecoilThirdOfDamageDealtParalyzeTarget", "RecoilThirdOfDamageDealtBurnTarget" 
        # brave bird / wood hammer / general recoil check
        if !user.hasActiveAbility?(:ROCKHEAD) && user.takesIndirectDamage?
            score *= 0.9
            if user.hp==user.totalhp && (user.hasActiveAbility?(:STURDY) || user.hasActiveItem?(:FOCUSSASH))
                score *= 0.7
            end
            if user.hp*(1.0/user.totalhp)>0.15 && user.hp*(1.0/user.totalhp)<0.4
                score *= 0.8
            end
            score *= 0.8 if user.effects[PBEffects::BoomInstalled]
        end
        # volt tackle
        if move.function == "RecoilThirdOfDamageDealtParalyzeTarget"
            if user.pbCanParalyze?(target, false)
                miniscore = pbTargetBenefitsFromStatus?(user, target, :PARALYSIS, 100, move, globalArray, skill)
                if pbHasSetupMove?(user)
                    miniscore *= 1.3
                end
                if target.hp==target.totalhp
                    miniscore *= 1.2
                end
                ministat=0
                ministat+=target.stages[:ATTACK]
                ministat+=target.stages[:SPECIAL_ATTACK]
                ministat+=target.stages[:SPEED]
                if ministat>0
                    minimini=5*ministat
                    minimini+=100
                    minimini/=100.0
                    miniscore*=minimini
                end
                miniscore-=100
                if move.addlEffect.to_f != 100
                    miniscore*=(move.addlEffect.to_f/100.0)
                    miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
                end
                miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
                miniscore+=100
                miniscore/=100.0
                score*=miniscore
            end
        end
        # flare blitz
        if move.function == "RecoilThirdOfDamageDealtBurnTarget"
            if user.pbCanBurn?(target, false)
                miniscore = pbTargetBenefitsFromStatus?(user, target, :BURN, 100, move, globalArray, skill)
                ministat=0
                ministat+=target.stages[:ATTACK]
                ministat+=target.stages[:SPECIAL_ATTACK]
                ministat+=target.stages[:SPEED]
                if ministat>0
                    minimini=5*ministat
                    minimini+=100
                    minimini/=100.0
                    miniscore*=minimini
                end 
                if move.baseDamage>0
                    if target.hasActiveAbility?(:STURDY,false,mold_broken)
                        miniscore*=1.1
                    end
                end
                miniscore-=100
                if move.addlEffect.to_f != 100
                    miniscore*=(move.addlEffect.to_f/100.0)
                    miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
                end
                miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
                miniscore+=100
                miniscore/=100.0
                score*=miniscore
            end
        end
    #---------------------------------------------------------------------------
    when "RecoilHalfOfDamageDealt" # head smash / light of ruin
        if !user.hasActiveAbility?(:ROCKHEAD) && user.takesIndirectDamage?
            score *= 0.9
            if user.hp==user.totalhp && (user.hasActiveAbility?(:STURDY) || user.hasActiveItem?(:FOCUSSASH))
                score *= 0.7
            end
            if user.hp*(1.0/user.totalhp)>0.2 && user.hp*(1.0/user.totalhp)<0.4
                score *= 0.8
            end
            score *= 0.75 if user.effects[PBEffects::BoomInstalled]
        end
    #---------------------------------------------------------------------------
    when "EffectivenessIncludesFlyingType" # flying press
        if target.effects[PBEffects::Minimize]
            score*=2
        end
        if @battle.field.effects[PBEffects::Gravity]>0 && !user.hasActiveItem?(:FLOATSTONE)
            score*=0
        end
    #---------------------------------------------------------------------------
    when "UseUserBaseDefenseInsteadOfUserBaseAttack" # Body Press
    #---------------------------------------------------------------------------
    when "UseTargetAttackInsteadOfUserAttack" # Foul Play
    #---------------------------------------------------------------------------
    when "UseTargetDefenseInsteadOfTargetSpDef" # Psystrike
    #---------------------------------------------------------------------------
    when "EnsureNextMoveAlwaysHits" # Lock On
        score *= 0.1 if target.effects[PBEffects::Substitute] > 0
        if user.effects[PBEffects::LockOn] > 0
            score = 0
        else
            score *= 1.3 if user.pbHasMove?(:INFERNO) || user.pbHasMove?(:ZAPCANNON)
        end
    #---------------------------------------------------------------------------
    when "StartNegateTargetEvasionStatStageAndGhostImmunity" # Foresight
        if target.effects[PBEffects::Foresight]
            score *= 0.1
        elsif target.pbHasType?(:GHOST, true)
            score *= 1.7
        elsif target.stages[:EVASION] <= 0
            score *= 0.6
        end
    #---------------------------------------------------------------------------
    when "StartNegateTargetEvasionStatStageAndDarkImmunity" # Miracle Eye
        if target.effects[PBEffects::MiracleEye]
            score *= 0.1
        elsif target.pbHasType?(:DARK, true)
            score *= 1.7
        elsif target.stages[:EVASION] <= 0
            score *= 0.6
        end
    #---------------------------------------------------------------------------
    when "IgnoreTargetDefSpDefEvaStatStages" # chip away
        ministat = 0
        #ministat+=target.stages[:EVASION] if target.stages[:EVASION]>0
        ministat+=target.stages[:DEFENSE] if target.stages[:DEFENSE]>0
        ministat+=target.stages[:SPECIAL_DEFENSE] if target.stages[:SPECIAL_DEFENSE]>0
        ministat*=5
        ministat+=100
        ministat/=100.0
        score*=ministat
    #---------------------------------------------------------------------------
    when "TypeIsUserFirstType" # revelaton dance
    #---------------------------------------------------------------------------
    when "TypeDependsOnUserIVs" # hidden power
    #---------------------------------------------------------------------------
    when "TypeAndPowerDependOnUserBerry" # Natural Gift
        score = 0 if !user.item || !user.item.is_berry? || !user.itemActive?
    #---------------------------------------------------------------------------
    when "TypeDependsOnUserPlate", "TypeDependsOnUserMemory", "TypeDependsOnUserDrive"
        # judgment, Multi-Attack, techno blast 
    #---------------------------------------------------------------------------
    when "TypeAndPowerDependOnWeather" # weather ball
        if [:Rain, :HeavyRain].include?(expectedWeather) && !user.hasActiveItem?(:UTILITYUMBRELLA) &&
           target.hasActiveAbility?([:DRYSKIN, :STORMDRAIN, :WATERABSORB],false,mold_broken)
            score*=0.1
        elsif [:Sun, :HarshSun].include?(expectedWeather) && !user.hasActiveItem?(:UTILITYUMBRELLA) &&
           target.hasActiveAbility?(:FLASHFIRE,false,mold_broken)
            score*=0.1
        end
    #---------------------------------------------------------------------------
    when "TypeAndPowerDependOnTerrain" # Terrain Pulse
        if user.affectedByTerrain?
            if expectedTerrain == :Electric && 
               (target.hasActiveAbility?([:MOTORDRIVE, :LIGHTNINGROD, :VOLTABSORB],false,mold_broken) ||
                target.pbHasType?(:GROUND, true))
                score*=0.1
            end
            if expectedTerrain == :Grassy && target.hasActiveAbility?(:SAPSIPPER,false,mold_broken)
                score*=0.1
            end
            if expectedTerrain == :Psychic && target.pbHasType?(:DARK, true)
                score*=0.1
            end
        end
    #---------------------------------------------------------------------------
    when "TargetMovesBecomeElectric" # Electrify
        if userFasterThanTarget
            if user.hasActiveAbility?(:VOLTABSORB)
                if user.hp<user.totalhp*0.8
                    score*=1.5
                else
                    score*=0.1
                end
            end          
            if user.hasActiveAbility?(:LIGHTNINGROD)
                if user.spatk > user.attack && !user.statStageAtMax?(:SPECIAL_ATTACK)
                    score*=1.5
                else
                    score*=0.1
                end
            end
            if user.hasActiveAbility?(:MOTORDRIVE)
                if !user.statStageAtMax?[:SPEED]
                    score*=1.2
                else
                    score*=0.1
                end
            end
            if user.pbHasType?(:GROUND, true)
                score*=1.3
            end
            if target.moves.any? { |m| priorityAI(target,m,globalArray)>0 }
                score*=0.5
            end
        else
            score*=0
        end
    #---------------------------------------------------------------------------
    when "NormalMovesBecomeElectric" # ion deluge / plasma fists
        bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
        maxdam=bestmove[0]
        maxmove=bestmove[1]
        maxtype=maxmove.type
        if user.hasActiveAbility?(:MOTORDRIVE)
            if maxtype == :NORMAL
                score*=1.5
            end
        end
        if user.hasActiveAbility?([:LIGHTNINGROD, :VOLTABSORB])
            if ((user.hp.to_f)/user.totalhp)<0.6
                if maxtype == :NORMAL
                    score*=1.5
                end
            end
        end
        if user.pbHasType?(:GROUND, true)
            score*=1.1
        end
        if target.moves.any? { |m| m&.pbCalcType(target) == :NORMAL}
            user.allAllies.each do |b|
                if b.hasActiveAbility?([:MOTORDRIVE, :LIGHTNINGROD, :VOLTABSORB])
                    score*=1.2
                end
                if b.pbHasType?(:GROUND, true)
                    score*=1.1
                end
            end
        end
        if maxtype != :NORMAL && move.statusMove?
            score*=0.5
        end
    #---------------------------------------------------------------------------
    when "HitTwoTimes", "HitTwoTimesTargetThenTargetAlly", "HitTwoTimesReload", 
         "HitTwoTimesPoisonTarget", "HitTwoTimesFlinchTarget"
          # double kick, dragon darts, splinter shot, twineedle, double iron bash
        if move.pbContactMove?(user)
            if user.affectedByContactEffect?
                if target.hasActiveItem?(:ROCKYHELMET)
                    score*=0.9
                end
                if target.hasActiveAbility?([:IRONBARBS, :ROUGHSKIN])
                    score*=0.9
                end
            end
            if target.hasActiveAbility?(:STAMINA)
                score*=0.5
            end
        end
        if target.hp==target.totalhp && (target.hasActiveItem?(:FOCUSSASH) || target.hasActiveAbility?(:STURDY,false,mold_broken))
            score*=1.3
        end
        if target.effects[PBEffects::Substitute]>0
            score*=1.3
        end
        if user.hasActiveItem?(:RAZORFANG) || user.hasActiveItem?(:KINGSROCK)
            score*=1.1
        end
        if move.function == "HitTwoTimesPoisonTarget"
            if user.pbCanPoison?(target, false)
                miniscore = pbTargetBenefitsFromStatus?(user, target, :POISON, 100, move, globalArray, skill)
                miniscore-=100
                if move.addlEffect.to_f != 100
                    miniscore*=(move.addlEffect.to_f/100.0)
                    miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
                    miniscore*=1.36 # 2 hits = higher chances
                end
                miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
                miniscore+=100
                miniscore/=100.0
                score*=miniscore
            end
        end
        if move.function == "HitTwoTimesFlinchTarget"
            if canFlinchTarget(user,target,mold_broken)
                if userFasterThanTarget
                    miniscore=100
                    miniscore*=1.3
                    if target.poisoned? || target.burned? || target.frozen? || user.takesHailDamage? || user.takesSandstormDamage? || 
                        target.effects[PBEffects::LeechSeed]>-1 || target.effects[PBEffects::Curse]
                        miniscore*=1.1
                        if target.effects[PBEffects::Toxic]>0
                            miniscore*=1.2
                        end
                    end            
                    if target.hasActiveAbility?(:STEADFAST)
                        miniscore*=0.3
                    end
                    miniscore-=100
                    if move.addlEffect.to_f != 100
                        miniscore*=(move.addlEffect.to_f/100.0)
                        miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
                        miniscore*=1.36 # 2 hits = higher chances
                    end
                    miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
                    miniscore+=100
                    miniscore/=100.0
                    score*=miniscore
                end
            end
            score *= 1.2 if target.effects[PBEffects::Minimize]
        end
    #---------------------------------------------------------------------------
    when "HitThreeTimesPowersUpWithEachHit" # triple kick
        if move.pbContactMove?(user)
            if user.affectedByContactEffect?
                if target.hasActiveItem?(:ROCKYHELMET)
                    score*=0.8
                end
                if target.hasActiveAbility?([:IRONBARBS, :ROUGHSKIN])
                    score*=0.8
                end
            end
            if target.hasActiveAbility?(:STAMINA)
                score*=0.4
            end
        end
        if target.hp==target.totalhp && (target.hasActiveItem?(:FOCUSSASH) || target.hasActiveAbility?(:STURDY,false,mold_broken))
            score*=1.3
        end
        if target.effects[PBEffects::Substitute]>0
            score*=1.3
        end
        if user.hasActiveItem?(:RAZORFANG) || user.hasActiveItem?(:KINGSROCK)
            score*=1.2
        end
    #---------------------------------------------------------------------------
    when "HitThreeTimesAlwaysCriticalHit" # surging strikes
        if target.hasActiveAbility?([:BATTLEARMOR, :SHELLARMOR],false,mold_broken) #|| user.effects[PBEffects::LaserFocus]
            score*=0.9
        else
            if user.opposes?(target) # is enemy
                if (target.hasActiveAbility?(:ANGERPOINT) && !target.statStageAtMax?(:ATTACK)) && 
                   targetSurvivesMove(move,user,target)
                    score*=0.5
                    score*=0.1 if target.attack>target.spatk
                end
                if move.pbContactMove?(user)
                    if user.affectedByContactEffect?
                        if target.hasActiveItem?(:ROCKYHELMET)
                            score*=0.8
                        end
                        if target.hasActiveAbility?([:IRONBARBS, :ROUGHSKIN])
                            score*=0.8
                        end
                    end
                    if target.hasActiveAbility?(:STAMINA)
                        score*=0.4
                    end
                end
                if target.hp==target.totalhp && (target.hasActiveItem?(:FOCUSSASH) || target.hasActiveAbility?(:STURDY,false,mold_broken))
                    score*=1.3
                end
                if target.effects[PBEffects::Substitute]>0
                    score*=1.3
                end
                if user.hasActiveItem?(:RAZORFANG) || user.hasActiveItem?(:KINGSROCK)
                    score*=1.2
                end
            else #if !user.opposes?(target) # is ally
                if target.hasActiveAbility?(:ANGERPOINT)
                    if !targetSurvivesMove(move,user,target) || target.statStageAtMax?(:ATTACK)
                        score=0
                    else
                        score = -100.0
                        score *= 1.2
                        enemy1 = user.pbDirectOpposing(true)
                        if enemy1.allAllies.empty?
                            enemy2 = enemy1
                        else
                            enemy2 = enemy1.allAllies.first
                        end
                        if ospeed > pbRoughStat(enemy1,:SPEED,skill) && 
                           ospeed > pbRoughStat(enemy2,:SPEED,skill)
                            score*=1.3
                        else
                            score*=0.7
                        end
                        targetTypes = typesAI(target, user, skill)
                        if Effectiveness.resistant_type?(move.type, targetTypes[0], targetTypes[1], targetTypes[2])
                            score*=2.5
                        else
                            score*=0.8
                        end
                        damage = pbRoughDamage(move,user,target,skill,move.baseDamage)
                        damage = damage * 100.0 / target.hp
                        score += (damage/2.0)
                        # + since it is on the negatives
                    end
                else
                    score=0
                end
            end
        end
    #---------------------------------------------------------------------------
    when "HitTwoToFiveTimes", "HitTwoToFiveTimesOrThreeForAshGreninja", 
         "HitTwoToFiveTimesRaiseUserSpd1LowerUserDef1", "HitThreeToFiveTimes" 
        # bullet seed, water shuriken, scale shot, queso blast
        if move.pbContactMove?(user)
            badeffect = false
            if user.affectedByContactEffect?
                if target.hasActiveItem?(:ROCKYHELMET)
                    score*=0.7
                    badeffect = true
                end
                if target.hasActiveAbility?([:IRONBARBS, :ROUGHSKIN])
                    score*=0.7
                    badeffect = true
                end
            end
            if target.hasActiveAbility?(:STAMINA)
                score*=0.4
                badeffect = true
            end
            score*=0.5 if user.hasActiveAbility?(:SKILLLINK) && badeffect
        end
        if target.hp==target.totalhp && (target.hasActiveItem?(:FOCUSSASH) || target.hasActiveAbility?(:STURDY,false,mold_broken))
            score*=1.3
        end
        if target.effects[PBEffects::Substitute]>0
            score*=1.3
        end
        if user.hasActiveItem?(:RAZORFANG) || user.hasActiveItem?(:KINGSROCK)
            score*=1.3
        end
        if move.function == "HitTwoToFiveTimesRaiseUserSpd1LowerUserDef1" # scale shot
            if $player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id)
                score*=1.1
            else
                # speed raise
                miniscore=125
                if ospeed<(aspeed*(3.0/2.0)) && @battle.field.effects[PBEffects::TrickRoom] == 0
                    miniscore*=1.2
                end
                if (user.hasActiveAbility?(:DISGUISE) && user.form == 0) || user.effects[PBEffects::Substitute]>0
                    miniscore*=1.3
                end
                if (user.hp.to_f)/user.totalhp>0.75
                    miniscore*=1.2
                end
                if (user.hp.to_f)/user.totalhp<0.33
                    miniscore*=0.3
                end
                if (user.hp.to_f)/user.totalhp<0.75 && (user.hasActiveAbility?(:EMERGENCYEXIT) || user.hasActiveAbility?(:WIMPOUT) || user.hasActiveItem?(:EJECTBUTTON))
                    miniscore*=0.3
                end
                if target.effects[PBEffects::HyperBeam]>0
                    miniscore*=1.3
                end
                if target.effects[PBEffects::Yawn]>0
                    miniscore*=1.7
                end
                bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
                maxdam = bestmove[0]
                if maxdam<(user.hp/4.0)
                    miniscore*=1.2
                else
                    if move.baseDamage==0 
                        miniscore*=0.8
                        if maxdam>user.hp
                            miniscore*=0.1
                        end
                    end              
                end
                if target.pbHasAnyStatus?
                    miniscore*=1.2
                end
                if target.asleep?
                    miniscore*=1.3
                end
                if target.effects[PBEffects::Encore]>0
                    if GameData::Move.get(target.effects[PBEffects::EncoreMove]).base_damage==0
                        miniscore*=1.5
                    end          
                end
                if user.effects[PBEffects::Confusion]>0
                    miniscore*=0.2
                end
                if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
                    miniscore*=0.6
                end
                if pbHasPhazingMove?(target)
                    miniscore*=0.5
                end
                if user.hasActiveAbility?(:SIMPLE)
                    miniscore*=2
                end
                if user.pbHasMoveFunction?("UseMoveTargetIsAboutToUse")
                    miniscore*=1.3
                end
                hasAlly = !target.allAllies.empty?
                if hasAlly
                    miniscore*=0.7
                end
                if user.attack<user.spatk
                    if user.stages[:SPECIAL_ATTACK]<0            
                        ministat=user.stages[:SPECIAL_ATTACK]
                        minimini=5*ministat
                        minimini+=100
                        minimini/=100.0
                        miniscore*=minimini
                    end
                else
                    if user.stages[:ATTACK]<0            
                        ministat=user.stages[:ATTACK]
                        minimini=5*ministat
                        minimini+=100
                        minimini/=100.0
                        miniscore*=minimini
                    end
                end
                ministat=0
                ministat+=target.stages[:DEFENSE]
                ministat+=target.stages[:SPECIAL_DEFENSE]
                if ministat>0
                    minimini=(-5)*ministat
                    minimini+=100
                    minimini/=100.0
                    miniscore*=minimini
                end
                roles = pbGetPokemonRole(user, target)
                if roles.include?("Sweeper")
                    miniscore*=1.3
                end
                if @battle.field.effects[PBEffects::TrickRoom]!=0
                    miniscore*=0.1
                else
                    miniscore*=0.1 if target.moves.any? { |j| j&.id == :TRICKROOM }
                end
                if user.paralyzed?
                    miniscore*=0.2
                end      
                if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && 
                    !user.takesHailDamage? && !user.takesSandstormDamage?)  
                    miniscore*=1.4
                end
                miniscore*=0.6 if target.moves.any? { |m| priorityAI(target,m,globalArray)>0 }    
                if user.hasActiveAbility?(:MOXIE)
                    miniscore*=1.3
                end
                miniscore/=100.0          
                if user.statStageAtMax?(:SPEED) 
                    miniscore=1
                end       
                if user.hasActiveAbility?(:CONTRARY)
                    miniscore*=0.5
                end
                score*=miniscore
                
                # defense drop
                miniscore=100
                if user.hasActiveAbility?(:CONTRARY) || user.pbOwnSide.effects[PBEffects::StatDropImmunity]
                    score*=1.5
                else
                    userlivecount     = @battle.pbAbleNonActiveCount(user.idxOwnSide)
                    targetlivecount = @battle.pbAbleCount(user.idxOpposingSide)
                    if targetSurvivesMove(move,user,target)
                        score*=0.9
                        if !userFasterThanTarget
                            score*=1.3
                        else
                            if target.moves.none? { |m| priorityAI(target,m,globalArray)>0 }
                                score*=1.2
                            end
                        end  
                        if target.moves.any? { |m| m&.healingMove? }
                            score*=0.5
                        end
                        if target.attack>target.spatk
                            score*=0.7
                        end
                        bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
                        maxphys = (bestmove[3]=="physical")
                        if maxphys
                            score*=0.7
                        end
                    else
                        targetlivecount -= 1
                    end
                    minimi=100
                    if targetlivecount > 0 
                        minimi*=@battle.pbParty(target.index).length
                        minimi/=100.0
                        minimi*=0.05
                        minimi = 1-minimi
                        miniscore*=minimi
                    end
                    if userlivecount == 0 && targetlivecount > 0 
                        score*=0.7
                    end
                end
                miniscore/=100.0
                score*=miniscore
            end
        end
    #---------------------------------------------------------------------------
    when "HitOncePerUserTeamMember" # beat up
        livecountuser=0
        @battle.eachInTeamFromBattlerIndex(user.index) do |pkmn,i|
          next if !pkmn.able? || pkmn.status != :NONE
          livecountuser += 1
        end
        if livecountuser>0
            if !user.opposes?(target) # is ally
                if (target.hasActiveAbility?(:JUSTIFIED) && move.type == :DARK) || 
                   (target.hasActiveAbility?(:STAMINA) && move.pbContactMove?(user))
                    if targetSurvivesMove(move,user,target)
                        score = -100.0
                        # checking if the recepient can outspeed
                        enemycounter = 0
                        user.eachOpposing do |m|
                            next unless ospeed < pbRoughStat(m,:SPEED,skill)
                            enemycounter += 1
                        end
                        if enemycounter == 0
                            score*=1.3
                        else
                            score*=0.7
                        end
                        targetTypes = typesAI(target, user, skill)
                        if Effectiveness.resistant_type?(move.type, targetTypes[0], targetTypes[1], targetTypes[2])
                            score*=2.0
                        end
                        if target.hp == target.totalhp
                            score*=2.0
                        else
                            score*=0.8
                        end
                        # adding "damage" since the score is on the negatives
                        damage = pbRoughDamage(move,user,target,skill,move.baseDamage)
                        if target.hasActiveAbility?(:STAMINA)
                            score *= 2.0 if target.pbHasMoveFunction?("UseUserBaseDefenseInsteadOfUserBaseAttack")
                            stageMul = [2, 2, 2, 2, 2, 2, 2, 3, 4, 5, 6, 7, 8]
                            stageDiv = [8, 7, 6, 5, 4, 3, 2, 2, 2, 2, 2, 2, 2]
                            defStage = user.stages[:DEFENSE] + 6
                            defStage += livecountuser
                            defStage = 12 if defStage > 12
                            damage /= stageMul[defStage] / stageDiv[defStage]
                            damage = damage * 100.0 / target.hp
                            score += damage
                        else
                            damage = damage * 100.0 / target.hp
                            score += damage
                            score *= 0.2 if target.stages[:ATTACK]>0
                        end
                    else
                        score=0
                    end
                end
            else
                if move.pbContactMove?(user)
                    if user.affectedByContactEffect?
                        if target.hasActiveItem?(:ROCKYHELMET)
                            score*=0.7
                        end
                        if target.hasActiveAbility?([:IRONBARBS, :ROUGHSKIN])
                            score*=0.7
                        end
                    end
                    if target.hasActiveAbility?(:STAMINA)
                        score*=0.3
                    end
                end
                if target.hp==target.totalhp && (target.hasActiveItem?(:FOCUSSASH) || target.hasActiveAbility?(:STURDY))
                    score*=1.3
                end
                if target.effects[PBEffects::Substitute]>0
                    score*=1.3
                end
                if user.hasActiveItem?(:RAZORFANG) || user.hasActiveItem?(:KINGSROCK)
                    score*=1.3
                end
            end
        end
    #---------------------------------------------------------------------------
    when "AttackAndSkipNextTurn" # Hyper Beam
        doesitdie = !targetSurvivesMove(move,user,target)
        if [:PRISMATICLASER, :ETERNABEAM, :ROAROFTIME].include?(move.id) && doesitdie && 
           @battle.choices[target.index][0] != :SwitchOut
            score*=2
        else
            miniscore=100
            targetlivecount = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
            userlivecount     = @battle.pbAbleNonActiveCount(user.idxOwnSide)
            if targetlivecount>1
                miniscore*=targetlivecount
                miniscore/=100.0
                miniscore*=0.1
                miniscore=(1-miniscore)
                score*=miniscore
            else
                score*=1.1
            end
            hasAlly = !target.allAllies.empty?
            if hasAlly
                score*=0.7
            end
            if targetlivecount>1 && userlivecount==0
                score*=0.7
            end
            # use it to finish off
            if doesitdie && targetlivecount==0
                healmove = priohealmove = false
                target.eachMove do |m|
                    next if !m.healingMove?
                    healmove = true
                    priohealmove = true if priorityAI(target,m,globalArray)>0
                end
                if userFasterThanTarget && !priohealmove
                    score*=2
                else
                    score*=0.5 if healmove
                end
            else
                score*=0.5 if target.moves.any? { |m| m&.healingMove? }
            end
        end
    #---------------------------------------------------------------------------
    when "TwoTurnAttack" # razor wind
        if !user.hasActiveItem?(:POWERHERB)     
            bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
            maxdam = bestmove[0]     
            if maxdam>user.hp
                score*=0.4
            else
                if user.hp*(1.0/user.totalhp)<0.5
                    score*=0.6
                end
            end
            if target.effects[PBEffects::TwoTurnAttack] || target.effects[PBEffects::HyperBeam]>0
                if userFasterThanTarget
                    score*=2
                else
                    score*=0.5
                end
            end
            hasAlly = !target.allAllies.empty?
            if hasAlly
                score*=0.7
            end
            if pbHasSingleTargetProtectMove?(target, false)
                score*=0.1
            end          
        else
            score*=1.2
            if user.hasActiveAbility?(:UNBURDEN) && !$player.difficulty_mode?("chaos")
                score*=1.5
            end
        end
    #---------------------------------------------------------------------------
    when "TwoTurnAttackOneTurnInSun" # solar beam
        if !user.hasActiveItem?(:POWERHERB) && !user.hasActiveAbility?(:PRESAGE) && 
         !([:Sun, :HarshSun].include?(expectedWeather) && !user.hasActiveItem?(:UTILITYUMBRELLA))
            bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
            maxdam = bestmove[0]
            if maxdam>user.hp
                score*=0.4
            else
                if user.hp*(1.0/user.totalhp)<0.5
                    score*=0.6
                end
            end
            if target.effects[PBEffects::TwoTurnAttack] || target.effects[PBEffects::HyperBeam]>0
                if userFasterThanTarget
                    score*=2
                else
                    score*=0.5
                end
            end
            hasAlly = !target.allAllies.empty?
            if hasAlly
                score*=0.7
            end
            if pbHasSingleTargetProtectMove?(target, false)
                score*=0.1
            end          
        else
            score*=1.2
            if (user.hasActiveAbility?(:UNBURDEN) && !$player.difficulty_mode?("chaos")) && !([:Sun, :HarshSun].include?(expectedWeather) && user.hasActiveItem?(:UTILITYUMBRELLA))
                score*=1.5
            end
        end
    #---------------------------------------------------------------------------
    when "TwoTurnAttackParalyzeTarget" # freeze shock
        if !user.hasActiveItem?(:POWERHERB)
            bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
            maxdam = bestmove[0]
            if maxdam>user.hp
                score*=0.4
            else
                if user.hp*(1.0/user.totalhp)<0.5
                    score*=0.6
                end
            end
            if target.effects[PBEffects::TwoTurnAttack] || target.effects[PBEffects::HyperBeam]>0
                if userFasterThanTarget
                    score*=2
                else
                    score*=0.5
                end
            end
            hasAlly = !target.allAllies.empty?
            if hasAlly
                score*=0.7
            end
            if pbHasSingleTargetProtectMove?(target, false)
                score*=0.1
            end          
        else
            score*=1.2
            if user.hasActiveAbility?(:UNBURDEN) && !$player.difficulty_mode?("chaos")
                score*=1.5
            end
        end

        if user.pbCanParalyze?(target, false)
            miniscore = pbTargetBenefitsFromStatus?(user, target, :PARALYSIS, 100, move, globalArray, skill)
            if pbHasSetupMove?(user)
                miniscore *= 1.3
            end
            if target.hp==target.totalhp
                miniscore *= 1.2
            end
            ministat=0
            ministat+=target.stages[:ATTACK]
            ministat+=target.stages[:SPECIAL_ATTACK]
            ministat+=target.stages[:SPEED]
            if ministat>0
                minimini=5*ministat
                minimini+=100
                minimini/=100.0
                miniscore*=minimini
            end
            miniscore-=100
            if move.addlEffect.to_f != 100
                miniscore*=(move.addlEffect.to_f/100.0)
                miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
            end
            miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
            miniscore+=100
            miniscore/=100.0
            score*=miniscore
        end
    #---------------------------------------------------------------------------
    when "TwoTurnAttackBurnTarget" # ice burn
        if !user.hasActiveItem?(:POWERHERB)
            bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
            maxdam = bestmove[0]
            if maxdam>user.hp
                score*=0.4
            else
                if user.hp*(1.0/user.totalhp)<0.5
                    score*=0.6
                end
            end
            if target.effects[PBEffects::TwoTurnAttack] || target.effects[PBEffects::HyperBeam]>0
                if userFasterThanTarget
                    score*=2
                else
                    score*=0.5
                end
            end
            hasAlly = !target.allAllies.empty?
            if hasAlly
                score*=0.7
            end
            if pbHasSingleTargetProtectMove?(target, false)
                score*=0.1
            end          
        else
            score*=1.2
            if user.hasActiveAbility?(:UNBURDEN) && !$player.difficulty_mode?("chaos")
                score*=1.5
            end
        end

        if user.pbCanBurn?(target, false)
            miniscore = pbTargetBenefitsFromStatus?(user, target, :BURN, 100, move, globalArray, skill)
            ministat=0
            ministat+=target.stages[:ATTACK]
            ministat+=target.stages[:SPECIAL_ATTACK]
            ministat+=target.stages[:SPEED]
            if ministat>0
                minimini=5*ministat
                minimini+=100
                minimini/=100.0
                miniscore*=minimini
            end 
            if move.baseDamage>0
                if target.hasActiveAbility?(:STURDY)
                    miniscore*=1.1
                end
            end
            miniscore-=100
            if move.addlEffect.to_f != 100
                miniscore*=(move.addlEffect.to_f/100.0)
                miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
            end
            miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
            miniscore+=100
            miniscore/=100.0
            score*=miniscore
        end
    #---------------------------------------------------------------------------
    when "TwoTurnAttackFlinchTarget" # Sky Attack
        if !user.hasActiveItem?(:POWERHERB)
            bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
            maxdam = bestmove[0]
            if maxdam>user.hp
                score*=0.4
            else
                if user.hp*(1.0/user.totalhp)<0.5
                    score*=0.6
                end
            end
            if target.effects[PBEffects::TwoTurnAttack] || target.effects[PBEffects::HyperBeam]>0
                if userFasterThanTarget
                    score*=2
                else
                    score*=0.5
                end
            end
            hasAlly = !target.allAllies.empty?
            if hasAlly
                score*=0.7
            end
            if pbHasSingleTargetProtectMove?(target, false)
                score*=0.1
            end          
        else
            score*=1.2
            if user.hasActiveAbility?(:UNBURDEN) && !$player.difficulty_mode?("chaos")
                score*=1.5
            end
        end
        
        if canFlinchTarget(user,target,mold_broken)
            if userFasterThanTarget
                miniscore=100
                miniscore*=1.3
                if target.poisoned? || target.burned? || target.frozen? || (user.takesHailDamage? && !user.takesSandstormDamage?) || 
                        target.effects[PBEffects::LeechSeed]>-1 || target.effects[PBEffects::Curse]
                    miniscore*=1.1
                    if target.effects[PBEffects::Toxic]>0
                        miniscore*=1.2
                    end
                end            
                if target.hasActiveAbility?(:STEADFAST)
                    miniscore*=0.3
                end
                miniscore-=100
                if move.addlEffect.to_f != 100
                    miniscore*=(move.addlEffect.to_f/100.0)
                    miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
                end
                miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
                miniscore+=100
                miniscore/=100.0
                score*=miniscore
            end
        end
    #---------------------------------------------------------------------------
    when "TwoTurnAttackRaiseUserSpAtkSpDefSpd2" # Geomancy
        bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
        maxdam = bestmove[0]
        if !user.hasActiveItem?(:POWERHERB)
            if maxdam>user.hp
                score*=0.4
            else
                if user.hp*(1.0/user.totalhp)<0.5
                    score*=0.6
                end
            end
            if user.turnCount<2
                score*=1.5
            else
                score*=0.7
            end
            if target.effects[PBEffects::TwoTurnAttack] || target.effects[PBEffects::HyperBeam]>0
                score*=2
            else
                score*=0.7
            end      
            hasAlly = !target.allAllies.empty?
            if hasAlly
                score*=0.7
            end
        else
            score*=2
            if user.hasActiveAbility?(:UNBURDEN) && !$player.difficulty_mode?("chaos")
                score*=1.5
            end
        end
        miniscore=100
        if user.effects[PBEffects::Substitute]>0 || (user.hasActiveAbility?(:DISGUISE) && user.form == 0)
            miniscore*=1.3
        end
        hasAlly = !target.allAllies.empty?
        if !hasAlly && move.statusMove? && @battle.choices[target.index][0] == :SwitchOut && user.hasActiveItem?(:POWERHERB)
            miniscore*=2
        end
        if (user.hp.to_f)/user.totalhp>0.75
            miniscore*=1.2
        end
        if target.effects[PBEffects::Yawn]>0
            miniscore*=1.7
        end      
        if maxdam*4<user.hp
            miniscore*=1.2
        else
            if move.baseDamage==0 
                miniscore*=0.8
                if maxdam>user.hp
                    miniscore*=0.1
                end
            end
        end                  
        if target.pbHasAnyStatus?
            miniscore*=1.2
        end
        if target.asleep?
            miniscore*=1.3
        end
        if target.effects[PBEffects::Encore]>0
            if GameData::Move.get(target.effects[PBEffects::EncoreMove]).base_damage==0       
                miniscore*=1.5
            end          
        end  
        if user.effects[PBEffects::Confusion]>0
            miniscore*=0.5
        end
        if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
            miniscore*=0.3
        end
        if user.hasActiveAbility?(:SIMPLE)
            miniscore*=2
        end
        if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
            miniscore*=0.5
        end
        miniscore/=100.0
        score*=miniscore
        miniscore=100
        if user.stages[:SPEED]<0
            ministat=user.stages[:SPEED]
            minimini=5*ministat
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
        end
        ministat=0
        ministat+=target.stages[:ATTACK]
        ministat+=target.stages[:SPECIAL_ATTACK]
        ministat+=target.stages[:SPEED]
        if ministat>0
            minimini=(-5)*ministat
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
        end
        priovar=target.moves.any? { |m| priorityAI(target,m,globalArray)>0 }
        healvar=target.moves.any? { |m| m&.healingMove? }
        if userFasterThanTarget
            miniscore*=1.5
        end
        if ospeed<(aspeed*2.0) && @battle.field.effects[PBEffects::TrickRoom] == 0
            miniscore*=1.2
        end
        roles = pbGetPokemonRole(user, target)
        if roles.include?("Sweeper")
            miniscore*=1.3
        end
        if user.paralyzed?
            miniscore*=0.5
        end        
        miniscore/=100.0
        if !user.statStageAtMax?(:SPECIAL_ATTACK)
            score*=miniscore
        end
        miniscore=100 
        if user.effects[PBEffects::Toxic]>0
            miniscore*=0.2
        end        
        if pbRoughStat(target,:ATTACK,skill)<pbRoughStat(target,:SPECIAL_ATTACK,skill)
            miniscore*=1.3
        end        
        if roles.include?("Physical Wall") || roles.include?("Special Wall")
            miniscore*=1.3
        end
        if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
            miniscore*=1.2
        end
        healmove=user.moves.any? { |m| m&.healingMove? }
        miniscore*=1.3 if healmove
        if user.pbHasMove?(:LEECHSEED)
            miniscore*=1.3
        end
        if user.pbHasMove?(:PAINSPLIT)
            miniscore*=1.2
        end        
        if targetWillMove?(target, "spec")
            if move.statusMove? && userFasterThanTarget && 
               priorityAI(target,@battle.choices[target.index][2],globalArray)<1 && user.hasActiveItem?(:POWERHERB)
                miniscore*=1.3
            end
        end
        miniscore/=100.0
        if !user.statStageAtMax?(:SPECIAL_DEFENSE)
            score*=miniscore
        end
        miniscore=100 
        if user.stages[:SPECIAL_ATTACK]<0            
            ministat=user.stages[:SPECIAL_ATTACK]
            minimini=5*ministat
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
        end        
        if userFasterThanTarget
            miniscore*=0.8          
        end
        if @battle.field.effects[PBEffects::TrickRoom]!=0
            miniscore*=0.2
        else
            miniscore*=0.2 if target.moves.any? { |j| j&.id == :TRICKROOM }
        end        
        miniscore/=100.0
        if !user.statStageAtMax?(:SPEED)
            score*=miniscore
        end
        score*=0 if user.hasActiveAbility?(:CONTRARY)
        if user.statStageAtMax?(:SPECIAL_ATTACK) && 
           user.statStageAtMax?(:SPECIAL_DEFENSE) && 
           user.statStageAtMax?(:SPEED)
            score*=0
        end
        score *= 0.4 if user.SetupMovesUsed.include?(move.id)
        score = 0 if $player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id)
    #---------------------------------------------------------------------------
    when "TwoTurnAttackChargeRaiseUserDefense1" # Skull Bash
        bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
        maxdam = bestmove[0]
        if !user.hasActiveItem?(:POWERHERB)
            if maxdam>user.hp
                score*=0.4
            else
                if user.hp*(1.0/user.totalhp)<0.5
                    score*=0.6
                end
            end
            if target.effects[PBEffects::TwoTurnAttack]
                if userFasterThanTarget
                    score*=2
                else
                    score*=0.5
                end
            end
            hasAlly = !target.allAllies.empty?
            if hasAlly
                score*=0.7
            end
            if pbHasSingleTargetProtectMove?(target, false)
                score*=0.1
            end          
        else
            score*=1.2
            if user.hasActiveAbility?(:UNBURDEN) && !$player.difficulty_mode?("chaos")
                score*=1.5
            end
        end
        miniscore=100
        if user.effects[PBEffects::Substitute]>0 || (user.hasActiveAbility?(:DISGUISE) && user.form == 0)
            miniscore*=1.3
        end
        if (user.hp.to_f)/user.totalhp>0.75
            miniscore*=1.1
        end    
        if target.effects[PBEffects::HyperBeam]>0
            miniscore*=1.2
        end
        if target.effects[PBEffects::Yawn]>0
            miniscore*=1.3
        end
        if maxdam<(user.hp/3.0)
            miniscore*=1.1
        end  
        if user.turnCount<2
            miniscore*=1.1
        end
        if target.pbHasAnyStatus?
            miniscore*=1.1
        end
        if target.asleep?
            miniscore*=1.3
        end
        if target.effects[PBEffects::Encore]>0
            if GameData::Move.get(target.effects[PBEffects::EncoreMove]).base_damage==0
                miniscore*=1.3
            end          
        end  
        if user.effects[PBEffects::Confusion]>0
            miniscore*=0.3
        end
        if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
            miniscore*=0.3
        end
        if user.effects[PBEffects::Toxic]>0
            miniscore*=0.2
        end
        miniscore*=0.2 if pbHasPhazingMove?(target) 
        if user.hasActiveAbility?(:SIMPLE)
            miniscore*=2
        end
        if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
            miniscore*=0.5
        end
        if user.stages[:DEFENSE]>0
            ministat=user.stages[:DEFENSE]
            minimini=-15*ministat
            minimini+=100          
            minimini/=100.0          
            miniscore*=minimini
        end
        if pbRoughStat(target,:ATTACK,skill)>pbRoughStat(target,:SPECIAL_ATTACK,skill)
            miniscore*=1.3
        end
        if (maxdam.to_f/user.hp)<0.12
            miniscore*=0.3
        end
        if user.hasActiveItem?(:LEFTOVERS) || 
            (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
            miniscore*=1.2
        end
        miniscore*=1.3 if user.moves.any? { |m| m&.healingMove? }
        if user.pbHasMove?(:LEECHSEED)
            miniscore*=1.3
        end
        if user.pbHasMove?(:PAINSPLIT)
            miniscore*=1.2
        end
        if user.hasActiveAbility?(:CONTRARY)
            miniscore*=0.5
        end
        if targetWillMove?(target, "phys")
            if move.statusMove? && userFasterThanTarget && 
                priorityAI(target,@battle.choices[target.index][2],globalArray)<1
                miniscore*=1.2
            end
        end
        miniscore/=100.0
        if user.statStageAtMax?(:DEFENSE) 
            miniscore=1
        end                
        miniscore = 1 if $player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id)
        score*=miniscore
    #---------------------------------------------------------------------------
    when "TwoTurnAttackChargeRaiseUserSpAtk1" # Meteor Beam
        # charge up
        bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
        maxdam = bestmove[0]
        if !user.hasActiveItem?(:POWERHERB)
            if maxdam>user.hp
                score*=0.4
            else
                if user.hp*(1.0/user.totalhp)<0.5
                    score*=0.6
                end
            end
            if target.effects[PBEffects::TwoTurnAttack]
                if userFasterThanTarget
                    score*=2
                else
                    score*=0.5
                end
            end
            hasAlly = !target.allAllies.empty?
            if hasAlly
                score*=0.7
            end
            if pbHasSingleTargetProtectMove?(target, false)
                score*=0.1
            end          
        else
            score*=1.2
            if user.hasActiveAbility?(:UNBURDEN) && !$player.difficulty_mode?("chaos")
                score*=1.5
            end
        end

        # spatk boost
        miniscore=100        
        if user.effects[PBEffects::Substitute]>0 || (user.hasActiveAbility?(:DISGUISE) && user.form == 0)
            miniscore*=1.3
        end
        if (user.hp.to_f)/user.totalhp>0.75
            miniscore*=1.1
        end
        if target.effects[PBEffects::HyperBeam]>0
            miniscore*=1.2
        end
        if target.effects[PBEffects::Yawn]>0
            miniscore*=1.3
        end
        # no need to recalc maxdam
        if maxdam<(user.hp/4.0)
            miniscore*=1.2         
        end
        if user.turnCount<2
            miniscore*=1.2
        end
        if target.pbHasAnyStatus?
            miniscore*=1.2
        end
        if target.asleep?
            miniscore*=1.3
        end
        if target.effects[PBEffects::Encore]>0
            if GameData::Move.get(target.effects[PBEffects::EncoreMove]).base_damage==0
                miniscore*=1.5
            end          
        end
        if user.effects[PBEffects::Confusion]>0
            miniscore*=0.2
        end
        if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
            miniscore*=0.6
        end
        if pbHasPhazingMove?(target)
            miniscore*=0.5
        end
        if user.hasActiveAbility?(:SIMPLE)
            miniscore*=2
        end
        if user.stages[:SPEED]<0
            ministat=user.stages[:SPEED]
            minimini=5*ministat
            minimini+=100          
            minimini/=100.0          
            miniscore*=minimini
        end
        ministat=0
        ministat+=target.stages[:ATTACK]
        ministat+=target.stages[:SPECIAL_ATTACK]
        ministat+=target.stages[:SPEED]
        if ministat>0
            minimini=(-5)*ministat
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
        end
        movecheck=target.moves.any? { |m| m&.healingMove? }
        miniscore*=1.3 if movecheck
        if userFasterThanTarget
            miniscore*=1.5
        end
        roles = pbGetPokemonRole(user, target)
        if roles.include?("Sweeper")
            miniscore*=1.3
        end
        if user.frozen?
            miniscore*=0.5
        end
        if user.paralyzed?
            miniscore*=0.5
        end
        if user.hp==user.totalhp && ((user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY)) && 
            !user.takesHailDamage? && !user.takesSandstormDamage?)
            miniscore*=1.4
        end
        movecheck=target.moves.any? { |m| priorityAI(target,m,globalArray)>0 }
        miniscore*=0.6 if movecheck
        if target.hasActiveAbility?(:SPEEDBOOST)
            miniscore*=0.6
        end
        if user.statStageAtMax?(:SPECIAL_ATTACK) 
            miniscore*=0.5
        end       
        if user.hasActiveAbility?(:CONTRARY)
            miniscore*=0.5
        end
        miniscore/=100.0
        miniscore = 1 if $player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id)
        score*=miniscore
    #---------------------------------------------------------------------------
    when "TwoTurnAttackInvulnerableUnderground" # dig
        targetlivecount=@battle.pbAbleNonActiveCount(user.idxOpposingSide)
        userlivecount=@battle.pbAbleNonActiveCount(user.idxOwnSide)
        if target.poisoned? || target.burned? || target.frozen? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::TwoTurnAttack] || target.effects[PBEffects::Curse]
            score*=1.2
        else
            if targetlivecount>1
                score*=0.8
            end
        end
        if user.pbHasAnyStatus? || user.effects[PBEffects::Curse] || user.effects[PBEffects::Attract]>-1 || user.effects[PBEffects::Confusion]>0
            score*=0.5
        end
        if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
            score*=1.1
        end
        if user.pbOwnSide.effects[PBEffects::Tailwind]>0 || user.pbOwnSide.effects[PBEffects::Reflect]>0 || user.pbOwnSide.effects[PBEffects::LightScreen]>0
            score*=0.7
        end
        if target.effects[PBEffects::PerishSong]!=0 && user.effects[PBEffects::PerishSong]==0
            score*=1.3
        end
        if user.hasActiveItem?(:POWERHERB)
            score*=1.5
        end
        if user.hasActiveAbility?(:NOGUARD) || target.hasActiveAbility?(:NOGUARD)
            score*=0.1
        end
        if userFasterThanTarget
            score*=1.1
        else
            score*=0.8
            score*=0.5 if target.moves.any? { |m| m&.healingMove? }
            score*=0.7 if target.moves.any? { |m| m&.accuracy == 0 }
        end
        score*=0.3 if target.moves.any? { |j| j&.id == :EARTHQUAKE }
    #---------------------------------------------------------------------------
    when "TwoTurnAttackInvulnerableUnderwater" # dive
        targetlivecount=@battle.pbAbleNonActiveCount(user.idxOpposingSide)
        userlivecount=@battle.pbAbleNonActiveCount(user.idxOwnSide)
        if target.poisoned? || target.burned? || target.frozen? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::TwoTurnAttack] || target.effects[PBEffects::Curse]
            score*=1.2
        else
            if targetlivecount>1
                score*=0.8
            end
        end
        if user.pbHasAnyStatus? || user.effects[PBEffects::Curse] || user.effects[PBEffects::Attract]>-1 || user.effects[PBEffects::Confusion]>0
            score*=0.5
        end
        if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
            score*=1.1
        end
        if user.pbOwnSide.effects[PBEffects::Tailwind]>0 || user.pbOwnSide.effects[PBEffects::Reflect]>0 || user.pbOwnSide.effects[PBEffects::LightScreen]>0
            score*=0.7
        end
        if target.effects[PBEffects::PerishSong]!=0 && user.effects[PBEffects::PerishSong]==0
            score*=1.3
        end
        if user.hasActiveItem?(:POWERHERB)
            score*=1.5
        end
        if user.hasActiveAbility?(:NOGUARD) || target.hasActiveAbility?(:NOGUARD)
            score*=0.1
        end
        if userFasterThanTarget
            score*=1.1
        else
            score*=0.8
            score*=0.5 if target.moves.any? { |m| m&.healingMove? }
            score*=0.7 if target.moves.any? { |m| m&.accuracy == 0 }
        end
        score*=0.3 if target.moves.any? { |j| j&.id == :SURF }
    #---------------------------------------------------------------------------
    when "TwoTurnAttackInvulnerableInSky" # Fly
        targetlivecount=@battle.pbAbleNonActiveCount(user.idxOpposingSide)
        userlivecount=@battle.pbAbleNonActiveCount(user.idxOwnSide)
        if target.poisoned? || target.burned? || target.frozen? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::TwoTurnAttack] || target.effects[PBEffects::Curse]
            score*=1.2
        else
            if targetlivecount>1
                score*=0.8
            end
        end
        if user.pbHasAnyStatus? || user.effects[PBEffects::Curse] || user.effects[PBEffects::Attract]>-1 || user.effects[PBEffects::Confusion]>0
            score*=0.5
        end
        if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
            score*=1.1
        end
        if user.pbOwnSide.effects[PBEffects::Tailwind]>0 || user.pbOwnSide.effects[PBEffects::Reflect]>0 || user.pbOwnSide.effects[PBEffects::LightScreen]>0
            score*=0.7
        end
        if target.effects[PBEffects::PerishSong]!=0 && user.effects[PBEffects::PerishSong]==0
            score*=1.3
        end
        if user.hasActiveItem?(:POWERHERB)
            score*=1.5
        end
        if user.hasActiveAbility?(:NOGUARD) || target.hasActiveAbility?(:NOGUARD)
            score*=0.1
        end
        if userFasterThanTarget
            score*=1.1
        else
            score*=0.8
            score*=0.5 if target.moves.any? { |m| m&.healingMove? }
            score*=0.7 if target.moves.any? { |m| m&.accuracy == 0 }
        end
        score*=0.3 if target.moves.any? { |j| [:THUNDER, :HURRICANE].include?(j&.id) }
        if @battle.field.effects[PBEffects::Gravity]>0 && !user.hasActiveItem?(:FLOATSTONE)
            score=0
        end
    #---------------------------------------------------------------------------
    when "TwoTurnAttackInvulnerableInSkyParalyzeTarget" # Bounce
        if user.pbCanParalyze?(target, false)
            miniscore = pbTargetBenefitsFromStatus?(user, target, :PARALYSIS, 100, move, globalArray, skill)
            miniscore *= 1.1
            if pbHasSetupMove?(user)
                miniscore *= 1.3
            end
            if target.hp==target.totalhp
                miniscore *= 1.2
            end
            ministat=0
            ministat+=target.stages[:ATTACK]
            ministat+=target.stages[:SPECIAL_ATTACK]
            ministat+=target.stages[:SPEED]
            if ministat>0
                minimini=5*ministat
                minimini+=100
                minimini/=100.0
                miniscore*=minimini
            end
            miniscore-=100
            if move.addlEffect.to_f != 100
                miniscore*=(move.addlEffect.to_f/100.0)
                miniscore*=2 if user.hasActiveAbility?(:SERENEGRACE)
            end
            miniscore = 1 if user.hasActiveAbility?(:SHEERFORCE)
            miniscore+=100
            miniscore/=100.0
            score*=miniscore
        end
        targetlivecount=@battle.pbAbleNonActiveCount(user.idxOpposingSide)
        userlivecount=@battle.pbAbleNonActiveCount(user.idxOwnSide)
        if target.poisoned? || target.burned? || target.frozen? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::TwoTurnAttack] || target.effects[PBEffects::Curse]
            score*=1.2
        else
            if targetlivecount>1
                score*=0.8
            end
        end
        if user.pbHasAnyStatus? || user.effects[PBEffects::Curse] || user.effects[PBEffects::Attract]>-1 || user.effects[PBEffects::Confusion]>0
            score*=0.5
        end
        if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
            score*=1.1
        end
        if user.pbOwnSide.effects[PBEffects::Tailwind]>0 || user.pbOwnSide.effects[PBEffects::Reflect]>0 || user.pbOwnSide.effects[PBEffects::LightScreen]>0
            score*=0.7
        end
        if target.effects[PBEffects::PerishSong]!=0 && user.effects[PBEffects::PerishSong]==0
            score*=1.3
        end
        if user.hasActiveItem?(:POWERHERB)
            score*=1.5
        end
        if user.hasActiveAbility?(:NOGUARD) || target.hasActiveAbility?(:NOGUARD)
            score*=0.1
        end
        if userFasterThanTarget
            score*=1.1
        else
            score*=0.8
            score*=0.5 if target.moves.any? { |m| m&.healingMove? }
            score*=0.7 if target.moves.any? { |m| m&.accuracy == 0 }
        end
        score*=0.3 if target.moves.any? { |j| [:THUNDER, :HURRICANE].include?(j&.id) }
        if @battle.field.effects[PBEffects::Gravity]>0 && !user.hasActiveItem?(:FLOATSTONE)
            score*=0
        end
    #---------------------------------------------------------------------------
    when "TwoTurnAttackInvulnerableInSkyTargetCannotAct" # sky drop
        if target.pbHasType?(:FLYING, true)
            score = 0         
        end
        targetlivecount=@battle.pbAbleNonActiveCount(user.idxOpposingSide)
        userlivecount=@battle.pbAbleNonActiveCount(user.idxOwnSide)
        if target.poisoned? || target.burned? || target.frozen? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::TwoTurnAttack] || target.effects[PBEffects::Curse]
            score*=1.2
        else
            if targetlivecount>1
                score*=0.8
            end
        end
        if user.pbHasAnyStatus? || user.effects[PBEffects::Curse] || user.effects[PBEffects::Attract]>-1 || user.effects[PBEffects::Confusion]>0
            score*=0.5
        end
        if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
            score*=1.1
        end
        if user.pbOwnSide.effects[PBEffects::Tailwind]>0 || user.pbOwnSide.effects[PBEffects::Reflect]>0 || user.pbOwnSide.effects[PBEffects::LightScreen]>0
            score*=0.7
        end
        if target.effects[PBEffects::PerishSong]!=0 && user.effects[PBEffects::PerishSong]==0
            score*=1.3
        end
        if user.hasActiveItem?(:POWERHERB)
            score*=1.5
        end
        if user.hasActiveAbility?(:NOGUARD) || target.hasActiveAbility?(:NOGUARD)
            score*=0.1
        end
        if userFasterThanTarget
            score*=1.1
        else
            score*=0.8
            score*=0.5 if target.moves.any? { |m| m&.healingMove? }
            score*=0.7 if target.moves.any? { |m| m&.accuracy == 0 }
        end
        score*=0.3 if target.moves.any? { |j| [:THUNDER, :HURRICANE].include?(j&.id) }
        if @battle.field.effects[PBEffects::Gravity]>0 && !user.hasActiveItem?(:FLOATSTONE)
            score=0
        end
    #---------------------------------------------------------------------------
    when "TwoTurnAttackInvulnerableRemoveProtections" # phantom / shadow force
        targetlivecount=@battle.pbAbleNonActiveCount(user.idxOpposingSide)
        userlivecount=@battle.pbAbleNonActiveCount(user.idxOwnSide)
        if target.poisoned? || target.burned? || target.frozen? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::TwoTurnAttack] || target.effects[PBEffects::Curse]
            score*=1.2
        else
            if targetlivecount>1
                score*=0.8
            end
        end
        if user.pbHasAnyStatus? || user.effects[PBEffects::Curse] || user.effects[PBEffects::Attract]>-1 || user.effects[PBEffects::Confusion]>0
            score*=0.5
        end
        if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
            score*=1.1
        end
        if user.pbOwnSide.effects[PBEffects::Tailwind]>0 || user.pbOwnSide.effects[PBEffects::Reflect]>0 || user.pbOwnSide.effects[PBEffects::LightScreen]>0
            score*=0.7
        end
        if target.effects[PBEffects::PerishSong]!=0 && user.effects[PBEffects::PerishSong]==0
            score*=1.3
        end
        if user.hasActiveItem?(:POWERHERB)
            score*=1.5
        end
        if user.hasActiveAbility?(:NOGUARD) || target.hasActiveAbility?(:NOGUARD)
            score*=0.1
        end
        if userFasterThanTarget
            score*=1.1
        else
            score*=0.8
            score*=0.5 if target.moves.any? { |m| m&.healingMove? }
            score*=0.7 if target.moves.any? { |m| m&.accuracy == 0 }
        end
    #---------------------------------------------------------------------------
    when "MultiTurnAttackPreventSleeping" # uproar
        if target.asleep?
            score*=0.7
        end
        if target.pbHasMove?(:REST) || target.hasActiveItem?(:NYLOBERRY)
            score*=1.8
        end
        targetlivecount=@battle.pbAbleNonActiveCount(user.idxOpposingSide)
        if targetlivecount>=1 || user.hasActiveAbility?([:SHADOWTAG, :ARENATRAP]) || target.effects[PBEffects::MeanLook]>0
            score*=1.1
        end        
        typemod=move.pbCalcTypeMod(move.pbCalcType(user), user, target)
        if typemod<4
            score*=0.7
        end
        if user.hp*(1.0/user.totalhp)<0.75
            score*=0.75
        end
        if user.stages[:SPECIAL_ATTACK]<0
            minimini = user.stages[:SPECIAL_ATTACK]
            minimini*=5
            minimini+=100
            minimini/=100.0
            score*=minimini
        end
        if targetlivecount>1
            miniscore = targetlivecount*0.05
            miniscore = 1-miniscore
            score*=miniscore
        end
    #---------------------------------------------------------------------------
    when "MultiTurnAttackConfuseUserAtEnd" # outrage
        targetlivecount=@battle.pbAbleNonActiveCount(user.idxOpposingSide)
        if user.pbCanConfuseSelf?(false)
            if targetSurvivesMove(move,user,target)
                score*=0.85
            end
            if user.hasActiveItem?([:PERSIMBERRY, :LUMBERRY])
                score*=1.3
            end
            unless $player.difficulty_mode?("chaos")
                unless move.specialMove?(move.type)
                    if user.stages[:ATTACK]>0
                        miniscore = (-5)*user.stages[:ATTACK]
                        miniscore+=100
                        miniscore/=100.0
                        score*=miniscore
                    end
                end
            end
            if targetlivecount>2
                miniscore=100
                miniscore*=targetlivecount
                miniscore*=0.01
                miniscore*=0.025
                miniscore=1-miniscore
                score*=miniscore
            end
            if pbHasSingleTargetProtectMove?(target)
                score*=1.1
            end
            score*=0.7 if target.moves.any? { |m| m&.healingMove? }
        else
            score *= 1.2
        end  
        if move.id == :OUTRAGE
            fairyvar = false
            @battle.pbParty(target.index).each do |m|
                next if m.nil?
                fairyvar=true if m.hasType?(:FAIRY)
            end
            score*=0.8 if fairyvar
        elsif move.id == :THRASH
            ghostvar = false
            @battle.pbParty(target.index).each do |m|
                next if m.nil?
                ghostvar=true if m.hasType?(:GHOST)
            end
            score*=0.8 if ghostvar
        elsif move.id == :PETALDANCE
            sappyvar = false
            @battle.pbParty(target.index).each do |m|
                next if m.nil?
                sappyvar=true if m.hasAbility?(:SAPSIPPER)
            end
            score*=0.8 if sappyvar && !mold_broken
        end
    #---------------------------------------------------------------------------
    when "MultiTurnAttackPowersUpEachTurn" # Rollout
        bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
        maxdam = bestmove[0]
        targetlivecount=@battle.pbAbleNonActiveCount(user.idxOpposingSide)
        if targetlivecount>=1 || user.hasActiveAbility?([:SHADOWTAG, :ARENATRAP]) || target.effects[PBEffects::MeanLook]>0
            score*=1.1
        end
        typemod=move.pbCalcTypeMod(move.pbCalcType(user), user, target)
        if typemod<4
            score*=0.7
        end
        if user.hp*(1.0/user.totalhp)<0.75
            score*=0.75
        end
        if user.stages[:SPECIAL_ATTACK]<0
            minimini = user.stages[:SPECIAL_ATTACK]
            minimini*=5
            minimini+=100
            minimini/=100.0
            score*=minimini
        end
        if targetlivecount>1
            miniscore = 1 - (targetlivecount*0.05)
            score*=miniscore
        end
        if user.paralyzed?
            score*=0.5
        end
        if user.effects[PBEffects::Confusion]>0
            score*=0.5
        end
        if user.effects[PBEffects::Attract]>=0
            score*=0.5
        end
        if user.effects[PBEffects::DefenseCurl]
            score*=1.3
        end
        if maxdam*3<user.hp
            score*=1.5
        end
        if pbHasSingleTargetProtectMove?(target, false)
            score*=0.8
        end
        if userFasterThanTarget
            score*=1.3
        end
        score*=1.2 if user.hasActiveAbility?(:MOMENTUM)
        score*=1.2 if user.hasActiveItem?(:METRONOME)
    #---------------------------------------------------------------------------
    when "MultiTurnAttackBideThenReturnDoubleDamage" # bide
        bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
        maxdam = bestmove[0]
        if (user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY))
            score*=1.2
        end 
        miniscore = user.hp*(1.0/user.totalhp)
        score*=miniscore
        if maxdam*2 > user.hp
            score*=0.2
        end
        if user.hp*3<user.totalhp
            score*=0.7
        end
        if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
            score*=1.1
        end
        if userFasterThanTarget
            score*=1.3
        end
        if pbHasSetupMove?(target)
            score*=0.5
        end
        alldam = target.moves.all? { |m| m.baseDamage > 0 }
        if alldam
            score*=1.3
        else
            score*=0.8
        end
    #---------------------------------------------------------------------------
    when "HealUserFullyAndFallAsleep" # rest
        fasterhealing=userFasterThanTarget || user.hasActiveAbility?(:PRANKSTER) || user.hasActiveAbility?(:TRIAGE)    
        if user.hasActiveItem?(:CHESTOBERRY) || user.hasActiveItem?(:LUMBERRY)
            halfhealth=(user.totalhp*2 / 3.0)
        else    
            halfhealth=(user.totalhp/4.0)
        end    
        bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
        maxdam=bestmove[0] 
        maxmove=bestmove[1]
        maxdam=0 if (target.status == :SLEEP && target.statusCount>1)        
        #if maxdam>user.hp
        if !targetSurvivesMove(maxmove,target,user)
            if maxdam>(user.hp+halfhealth)
                score=0
            else
                if maxdam>=halfhealth
                    if fasterhealing
                        score*=0.5
                    else
                        score*=0.1
                    end
                else
                    score*=2
                end
            end
        else
            if maxdam*1.5>user.hp
                score*=2
            end
            if !userFasterThanTarget
                if maxdam*2>user.hp
                    score*=2
                end
            end
        end
        hpchange=(EndofTurnHPChanges(user,target,false,false,true,false,true)) # what % of our hp will change after end of turn effects go through
        opphpchange=(EndofTurnHPChanges(target,user,false,false,true)) # what % of our hp will change after end of turn effects go through
        if opphpchange<1 ## we are going to be taking more chip damage than we are going to heal
            oppchipdamage=((target.totalhp*(1-hpchange)))
        end
        thisdam=maxdam#*1.1
        hplost=(user.totalhp-user.hp)
        hplost+=maxdam if !fasterhealing
        if user.effects[PBEffects::LeechSeed]>=0 && !userFasterThanTarget && canSleepTarget(target,user,globalArray)
            score *= 0.3 
        end    
        if hpchange<1 ## we are going to be taking more chip damage than we are going to heal
            chipdamage=((user.totalhp*(1-hpchange)))
            thisdam+=chipdamage
        elsif hpchange>1 ## we are going to be healing more hp than we take chip damage for  
            healing=((user.totalhp*(hpchange-1)))
            thisdam-=healing if !(thisdam>user.hp)
        elsif hpchange<=0 ## we are going to a huge overstack of end of turn effects. hence we should just not heal.
            score*=0
        end
        if thisdam>hplost
            score*=0.1
        else
            if @battle.pbAbleNonActiveCount(user.idxOwnSide) == 0 && hplost<=(halfhealth)
                score*=0.01
            end
            if thisdam<=(halfhealth)
                score*=2
            else
                if userFasterThanTarget
                    if hpchange<1 && thisdam>=halfhealth && !(opphpchange<1)
                        score*=0.3
                    end
                end
            end
        end
        if pbHasSetupMove?(target)
            score*=0.7
        end 
        if (user.hp.to_f)/user.totalhp<0.5
            score*=1.5       
        else
            score*=0.5
        end  
        if target.poisoned? || target.burned? || target.frozen? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse]
            score*=1.3
            if target.effects[PBEffects::Toxic]>0
                score*=1.3
            end
        end
        if user.poisoned?
            score*=1.3
            if user.effects[PBEffects::Toxic]>0
                score*=1.3
            end
        end
        if user.burned?
            score*=1.3
            if user.spatk<user.attack
                score*=1.5
            end
        end
        if user.frozen?
            score*=1.3
            if user.spatk>user.attack
                score*=1.5
            end
        end
        if user.paralyzed?
            score*=1.3
        end
        if user.effects[PBEffects::Toxic]>0
            score*=0.5
            if user.effects[PBEffects::Toxic]>4
                score*=0.5
            end          
        end
        if user.paralyzed? || user.effects[PBEffects::Attract]>=0 || user.effects[PBEffects::Confusion]>0
            score*=1.1
        end
        if target.moves.any? { |j| [:SUPERPOWER, :OVERHEAT, :DRACOMETEOR, :LEAFSTORM, :FLEURCANNON, :PSYCHOBOOST].include?(j&.id) }
            score*=1.2
        end
        if user.hp*(1.0/user.totalhp)>=0.8
            score*=0
        end
        score*=0.1 if ((user.hp.to_f)/user.totalhp)>0.8
        score*=0.6 if ((user.hp.to_f)/user.totalhp)>0.6
        score*=2 if ((user.hp.to_f)/user.totalhp)<0.25
        score=0 if user.effects[PBEffects::Wish]>0    
        if !user.hasActiveItem?([:CHESTOBERRY, :LUMBERRY]) && 
           !(user.hasActiveAbility?(:HYDRATION) && 
            [:Rain, :HeavyRain].include?(expectedWeather) && !user.hasActiveItem?(:UTILITYUMBRELLA))
            score*=0.8
            if maxdam*2 > user.totalhp
                score*=0.4
            else
                if maxdam*3 < user.totalhp
                    score*=1.3
                end
            end
            if target.moves.any? { |j| [:WAKEUPSLAP, :NIGHTMARE, :DREAMEATER].include?(j&.id) } || 
               target.hasActiveAbility?(:BADDREAMS)
                score*=0.7
            end
            if user.pbHasMove?(:SLEEPTALK)
                score*=1.3
            end 
            if user.pbHasMove?(:SNORE)
                score*=1.2
            end 
            if user.hasActiveAbility?(:SHEDSKIN)
                score*=1.1
            end
            if user.hasActiveAbility?(:EARLYBIRD)
                score*=1.1
            end
            hasAlly = !target.allAllies.empty?
            if hasAlly
                score*=0.8
            end
        else
            if user.hasActiveItem?([:CHESTOBERRY, :LUMBERRY])
                if user.hasActiveAbility?(:HARVEST)
                    score*=1.2
                else
                    score*=0.8
                end
            end
        end
        if user.pbHasAnyStatus?
            score*=1.4
            if user.effects[PBEffects::Toxic]>0
                score*=1.2
            end
        end
        score=0 if !user.pbCanSleep?(user,false)
    #---------------------------------------------------------------------------
    when "HealUserHalfOfTotalHP", "HealUserHalfOfTotalHPLoseFlyingTypeThisTurn", 
         "HealUserDependingOnWeather", "HealUserDependingOnSandstorm", "HealUserDependingOnHail"
         # Recover, Roost, Synthesis, Shore Up, Glacial Gulf
        fasterhealing=userFasterThanTarget || user.hasActiveAbility?(:PRANKSTER) || user.hasActiveAbility?(:TRIAGE) 
        if move.function == "HealUserDependingOnWeather" 
            case expectedWeather
            when :Sun, :HarshSun
                halfhealth=(user.totalhp*2 / 3.0)
                halfhealth=(user.totalhp/2.0) if user.hasActiveItem?(:UTILITYUMBRELLA)
            when :None
                halfhealth=(user.totalhp/2.0)
            else
                halfhealth=(user.totalhp/4.0)
            end
            halfhealth=(user.totalhp*2 / 3.0) if user.hasActiveAbility?(:PRESAGE)
        elsif move.function == "HealUserDependingOnSandstorm" 
            case expectedWeather
            when :Sandstorm
                halfhealth=(user.totalhp*2 / 3.0)
            else
                halfhealth=(user.totalhp/2.0)
            end   
        elsif move.function == "HealUserDependingOnHail" 
            case expectedWeather
            when :Hail
                halfhealth=(user.totalhp*2 / 3.0)
            else
                halfhealth=(user.totalhp/2.0)
            end
        else     
            halfhealth=(user.totalhp/2)
        end       
        halfhealth=(halfhealth*1.5) if user.hasActiveItem?(:COLOGNECASE)
        bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
        maxdam=bestmove[0] 
        maxmove=bestmove[1]
        maxdam=0 if (target.status == :SLEEP && target.statusCount>1)        
        #if maxdam>user.hp
        if !targetSurvivesMove(maxmove,target,user)
            if maxdam>(user.hp+halfhealth)
                score=0
            else
                if maxdam>=halfhealth
                    if userFasterThanTarget
                        score*=0.5
                    else
                        score*=0.1
                    end
                else
                    score*=2
                end
            end
        else
            if maxdam*1.5>user.hp
                score*=2
            end
            if !userFasterThanTarget
                if maxdam*2>user.hp
                    score*=2
                end
            end
        end
        hpchange=(EndofTurnHPChanges(user,target,false,false,true)) # what % of our hp will change after end of turn effects go through
        opphpchange=(EndofTurnHPChanges(target,user,false,false,true)) # what % of our hp will change after end of turn effects go through
        if opphpchange<1 ## we are going to be taking more chip damage than we are going to heal
            oppchipdamage=((target.totalhp*(1-hpchange)))
        end
        thisdam=maxdam#*1.1
        hplost=(user.totalhp-user.hp)
        hplost+=maxdam if !fasterhealing
        if user.effects[PBEffects::LeechSeed]>=0 && !userFasterThanTarget && canSleepTarget(target,user,globalArray)
            score *= 0.3 
        end    
        if hpchange<1 ## we are going to be taking more chip damage than we are going to heal
            chipdamage=((user.totalhp*(1-hpchange)))
            thisdam+=chipdamage
        elsif hpchange>1 ## we are going to be healing more hp than we take chip damage for  
            healing=((user.totalhp*(hpchange-1)))
            thisdam-=healing if !(thisdam>user.hp)
        elsif hpchange<=0 ## we are going to a huge overstack of end of turn effects. hence we should just not heal.
            score*=0
        end
        if thisdam>hplost
            score*=0.1
        else
            if @battle.pbAbleNonActiveCount(user.idxOwnSide) == 0 && hplost<=(halfhealth)
                score*=0.01
            end
            if thisdam<=(halfhealth)
                score*=2
            else
                if userFasterThanTarget
                    if hpchange<1 && thisdam>=halfhealth && !(opphpchange<1)
                        score*=0.3
                    end
                end
            end
        end
        if ((user.hp.to_f)<=halfhealth)
            score*=1.5
        else
            score*=0.8
        end
        score*=0.8 if maxdam>halfhealth
        if pbHasSetupMove?(target)
            score*=0.7
        end 
        if (user.hp.to_f)/user.totalhp<0.5
            score*=1.5
            if user.effects[PBEffects::Curse]
                score*=2
            end
            if user.hp*4<user.totalhp
                if user.poisoned?
                    score*=1.5
                end
                if user.effects[PBEffects::LeechSeed]>=0
                    score*=2
                end
                if user.hp<user.totalhp*0.13
                    if user.burned? || user.frozen?
                        score*=2
                    end
                    if user.takesHailDamage? || user.takesSandstormDamage?
                        score*=2
                    end  
                end            
            end          
        else
            score*=0.9
        end
        if user.paralyzed? || user.effects[PBEffects::Attract]>=0 || user.effects[PBEffects::Confusion]>0
            score*=1.1
        end
        if target.poisoned? || target.burned? || target.frozen? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse]
            score*=1.3
            if target.effects[PBEffects::Toxic]>0
                score*=1.3
            end
        end
        if target.moves.any? { |j| [:SUPERPOWER, :OVERHEAT, :DRACOMETEOR, :LEAFSTORM, :FLEURCANNON, :PSYCHOBOOST].include?(j&.id) }
            score*=1.2
        end
        if target.effects[PBEffects::HyperBeam]>0
            score*=1.2
        end
        score*=0.1 if ((user.hp.to_f)/user.totalhp)>0.8
        score*=0.6 if ((user.hp.to_f)/user.totalhp)>0.6
        score*=2 if ((user.hp.to_f)/user.totalhp)<0.25
        score=0 if user.effects[PBEffects::Wish]>0    
    #---------------------------------------------------------------------------
    when "CureTargetStatusHealUserHalfOfTotalHP" # purify
        if user.opposes?(target) # is enemy
            score=0
        else                     # is ally
            if target.pbHasAnyStatus?
                score*=1.5
                if target.hp>target.totalhp*0.8
                    score*=0.8
                else
                    if target.hp>target.totalhp*0.3
                        score*=2
                    end            
                end
                toxicturns = ($player.difficulty_mode?("chaos")) ? 1 : 3
                if target.effects[PBEffects::Toxic]>toxicturns
                    score*=1.3
                end
                @battle.allBattlers.each do |b|
                    next unless user.opposes?(b)
                    score*=1.3 if b.pbHasMoveFunction?("DoublePowerIfTargetStatusProblem", "DoublePowerIfTargetPoisoned")
                end
                score*=-1
            end
        end
    #---------------------------------------------------------------------------
    when "HealUserByTargetAttackLowerTargetAttack1" # Strength Sap
        if target.effects[PBEffects::Substitute]<=0
            healvar = target.moves.any? { |m| m&.healingMove? }
            movecheck = target.moves.any? { |j| [:SUPERPOWER, :OVERHEAT, :DRACOMETEOR, :LEAFSTORM, :FLEURCANNON, :PSYCHOBOOST].include?(j&.id) }
            bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
            maxdam=bestmove[0] 
            maxmove=bestmove[1]
            maxtype=maxmove.type
            if user.effects[PBEffects::HealBlock]>0
                score*=0
            else
                if maxdam>user.hp
                    score*=3
                    if maxdam*1.5 > user.hp
                        score*=1.5
                    end
                    if !userFasterThanTarget
                        if maxdam*2 > user.hp
                            score*=2
                        else
                            score*=0.2
                        end
                    end
                end
            end
            if target.pbHasMove?(:CALMMIND) || target.pbHasMove?(:WORKUP) || target.pbHasMove?(:NASTYPLOT) || 
                target.pbHasMove?(:TAILGLOW) || target.pbHasMove?(:GROWTH) || target.pbHasMove?(:QUIVERDANCE)
                score*=0.7
            end 
            if (user.hp.to_f)/user.totalhp<0.5
                score*=1.5
            else
                score*=0.5
            end
            roles = pbGetPokemonRole(user, target)
            if !(roles.include?("Physical Wall") || roles.include?("Special Wall"))
                score*=0.8
            end
            if target.poisoned? || target.burned? || target.frozen? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse]
                score*=1.3
                if target.effects[PBEffects::Toxic]>0
                    score*=1.3
                end
            end
            if movecheck
                score*=1.2
            end        
            if target.effects[PBEffects::HyperBeam]>0
                score*=1.2
            end
            ministat = target.attack
            ministat/=(user.totalhp).to_f
            ministat+=0.5
            score*=ministat
            if target.hasActiveAbility?(:LIQUIDOOZE)
                score*=0.2
            end
            if user.hasActiveItem?([:BIGROOT, :COLOGNECASE])
                score*=1.3
            end        
            miniscore=100
            if roles.include?("Physical Wall") || roles.include?("Special Wall")
                miniscore*=1.3
            end
            sweepvar = false
            count=-1
            @battle.pbParty(user.index).each do |i|
                next if i.nil?
                count+=1
                next if count==user.pokemonIndex
                temproles = pbGetPokemonRole(i, target, count, @battle.pbParty(user.index))
                if temproles.include?("Sweeper")
                    sweepvar = true
                end
            end
            if sweepvar
                miniscore*=1.1
            end
            targetlivecount = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
            if targetlivecount==0 || user.hasActiveAbility?([:SHADOWTAG, :ARENATRAP]) || target.effects[PBEffects::MeanLook]>0
                miniscore*=1.4
            end
            if target.poisoned?
                miniscore*=1.2
            end
            if target.stages[:ATTACK]!=0
                minimini = 5*target.stages[:ATTACK]
                minimini *= 1.1 if move.baseDamage==0
                minimini+=100
                minimini/=100.0
                miniscore*=minimini
            end
            if user.pbHasMove?(:FOULPLAY)
                miniscore*=0.5
            end  
            if target.burned?
                miniscore*=0.5
            end          
            if target.hasActiveAbility?(:UNAWARE,false,mold_broken) || target.hasActiveAbility?(:COMPETITIVE)  
                miniscore*=0.1
            end
            if target.hasActiveAbility?(:DEFIANT) || target.hasActiveAbility?(:CONTRARY)
                miniscore*=0.5
            end
            miniscore/=100.0
            if user.stages[:ATTACK]!=6
                score*=miniscore
            end                   
        else
            score = 0
        end
    #---------------------------------------------------------------------------
    when "HealUserByHalfOfDamageDone" # drain punch
        minimini = pbRoughDamage(move,user,target,skill,move.baseDamage)
        minimini = minimini * 100 / target.hp
        miniscore = minimini / 2.0
        missinghp = (user.totalhp-user.hp) * 100.0
        if miniscore > missinghp
            miniscore = missinghp
        end
        if user.totalhp>0
            miniscore/=(user.totalhp).to_f
        end
        if user.hasActiveItem?([:BIGROOT, :COLOGNECASE])
            miniscore*=1.3
        end
        miniscore *= 0.75 #arbitrary multiplier to make it value the HP less
        miniscore+=1
        if target.hasActiveAbility?(:LIQUIDOOZE)
            miniscore = (2-miniscore)
            score*=miniscore
        else
            if !(user.hp==user.totalhp && userFasterThanTarget) && target.effects[PBEffects::Substitute]==0
                score*=miniscore
            end
        end
    #---------------------------------------------------------------------------
    when "HealUserByHalfOfDamageDoneIfTargetAsleep" # dream eater
          if target.asleep? && (target.statusCount > 1 || userFasterThanTarget)
            minimini = pbRoughDamage(move,user,target,skill,move.baseDamage)
            minimini = minimini / target.hp
            miniscore = minimini / 2.0
            missinghp = (user.totalhp-user.hp) * 100.0
            if miniscore > missinghp
                miniscore = missinghp
            end
            if user.totalhp>0
                miniscore/=(user.totalhp).to_f
            end
            if user.hasActiveItem?([:BIGROOT, :COLOGNECASE])
                miniscore*=1.3
            end
            miniscore+=1
            if target.hasActiveAbility?(:LIQUIDOOZE)
                miniscore = (2-miniscore)
                score*=miniscore
            else
                if !(user.hp==user.totalhp && userFasterThanTarget) && target.effects[PBEffects::Substitute]==0
                    score*=miniscore
                end
            end
            score = 0 if @battle.choices[target.index][0] == :SwitchOut
        else
            score = 0
          end
    #---------------------------------------------------------------------------
    when "HealUserByThreeQuartersOfDamageDone" # oblivion wing
        minimini = pbRoughDamage(move,user,target,skill,move.baseDamage)
        minimini = minimini / target.hp
        miniscore = minimini * (3.0/4.0)
        missinghp = (user.totalhp-user.hp) * 100.0
        if miniscore > missinghp
            miniscore = missinghp
        end
        if user.totalhp>0
            miniscore/=(user.totalhp).to_f
        end
        if user.hasActiveItem?([:BIGROOT, :COLOGNECASE])
            miniscore*=1.3
        end
        miniscore *= 0.9 #arbitrary multiplier to make it value the HP less
        miniscore+=1
        if target.hasActiveAbility?(:LIQUIDOOZE)
            miniscore = (2-miniscore)
            score*=miniscore
        else
            if !(user.hp==user.totalhp && userFasterThanTarget) && target.effects[PBEffects::Substitute]==0
                score*=miniscore
            end
        end
    #---------------------------------------------------------------------------
    when "HealUserAndAlliesQuarterOfTotalHP" # Life Dew
        ally_amt = 30
        @battle.allSameSideBattlers(user.index).each do |b|
            if b.hp == b.totalhp || (skill >= PBTrainerAI.mediumSkill && !b.canHeal?)
                score -= ally_amt / 2
            elsif b.hp < b.totalhp * 3 / 4
                score += ally_amt
            end
        end
    #---------------------------------------------------------------------------
    when "HealUserAndAlliesQuarterOfTotalHPCureStatus" # Jungle Healing
        ally_amt = 80 / @battle.pbSideSize(user.index)
        @battle.allSameSideBattlers(user.index).each do |b|
            if b.hp == b.totalhp || (skill >= PBTrainerAI.mediumSkill && !b.canHeal?)
                score -= ally_amt
            elsif b.hp < b.totalhp * 3 / 4
                score += ally_amt
            end
            score += ally_amt / 2 if b.pbHasAnyStatus?
        end
    #---------------------------------------------------------------------------
    when "HealTargetHalfOfTotalHP" # heal pulse
        userAlly = user.allAllies.empty?
        if user.opposes?(target) || userAlly # is enemy or is in a 1v1
            score = 0
        else
            if target.hp*(1.0/target.totalhp)<0.7 && target.hp*(1.0/target.totalhp)>0.3
                score*=3.0
            elsif target.hp*(1.0/target.totalhp)<0.3
                score*=1.7
            end
            if target.poisoned? || target.burned? || target.frozen? || 
               target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse]
                score*=0.8
                score*=0.7 if target.effects[PBEffects::Toxic]>0
            end
            if target.hp*(1.0/target.totalhp)>0.8
                if !userFasterThanTarget
                    score*=0.5
                else
                    score*=0
                end
            end
            score *= -1
        end
    #---------------------------------------------------------------------------
    when "HealTargetDependingOnGrassyTerrain" # floral healing
        userAlly = user.allAllies.empty?
        if user.opposes?(target) || userAlly # is enemy or is in a 1v1
            score=0
        else
            if target.hp*(1.0/target.totalhp)<0.7 && target.hp*(1.0/target.totalhp)>0.3
                score*=3
            elsif target.hp*(1.0/target.totalhp)<0.3
                score*=1.7
            end
            if target.poisoned? || target.burned? || target.frozen? ||
               target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse]
                score*=0.8
                if target.effects[PBEffects::Toxic]>0
                    score*=0.7
                end
            end
            if target.hp*(1.0/target.totalhp)>0.8
                if !userFasterThanTarget
                    score*=0.5
                else
                    score*=0
                end
            end
            score*=1.3 if expectedTerrain == :Grassy && target.affectedByTerrain?
            score *= -1
        end
    #---------------------------------------------------------------------------
    when "HealUserPositionNextTurn" # wish
        bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
        maxdam=bestmove[0]
        if maxdam>user.hp
            if maxdam>(user.hp*1.5)
                score=0
            else
                score*=5
            end
        else
            if maxdam*1.5>user.hp
                score*=2
            end
            if userFasterThanTarget
                if maxdam*2>user.hp
                    score*=5
                end                
            end
            if pbHasSingleTargetProtectMove?(user, false)
                score*=1.5
            end
        end
        if pbHasSetupMove?(target) 
            score*=0.7
        end
        if user.effects[PBEffects::Toxic]>0
            score*=0.5
            if user.effects[PBEffects::Toxic]>4
                score*=0.5
            end          
        end
        if user.paralyzed? || user.effects[PBEffects::Attract]>=0 || user.effects[PBEffects::Confusion]>0
            score*=1.1
        end
        if target.poisoned? || target.burned? || target.frozen? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse]
            score*=1.3
            if target.effects[PBEffects::Toxic]>0
                score*=1.3
            end
        end
        if target.moves.any? { |j| [:SUPERPOWER, :OVERHEAT, :DRACOMETEOR, :LEAFSTORM, :FLEURCANNON, :PSYCHOBOOST].include?(j&.id) }
            score*=1.2
        end
        if target.effects[PBEffects::HyperBeam]>0
            score*=1.2
        end
        if ((user.hp.to_f)/user.totalhp)>0.8
            score=0
        elsif ((user.hp.to_f)/user.totalhp)>0.6
            score*=0.6
        elsif ((user.hp.to_f)/user.totalhp)<0.25
            score*=2
        end  
        roles = pbGetPokemonRole(user, target)
        if roles.include?("Cleric")
            wishpass=false
            @battle.pbParty(user.index).each do |m|
                next if m.nil?
                if m.hp/m.totalhp.to_f<0.6 && m.hp/m.totalhp.to_f>0.3
                    wishpass=true
                    break
                end
            end
            score*=1.3 if wishpass
        end
        if pbHasPivotMove?(user)
            score*=1.3
        end
        score = 0 if user.effects[PBEffects::Wish]>0
    #---------------------------------------------------------------------------
    when "StartHealUserEachTurn" # aqua ring
          if !user.effects[PBEffects::AquaRing]
            bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
            maxdam = bestmove[0]
            if user.hp*(1.0/user.totalhp)>0.75
                score*=1.2
            end
            if user.hp*(1.0/user.totalhp)<0.50
                score*=0.7
                if user.hp*(1.0/user.totalhp)<0.33
                    score*=0.5
                end            
            end
            if user.hasActiveItem?(:LEFTOVERS) || user.effects[PBEffects::Ingrain] || (expectedTerrain == :Grass && user.affectedByTerrain?) ||
              (user.hasActiveAbility?(:HEALINGSUN) && [:Sun, :HarshSun].include?(expectedWeather) && !user.hasActiveItem?(:UTILITYUMBRELLA)) || 
              (user.hasActiveAbility?(:RAINDISH) && [:Rain, :HeavyRain].include?(expectedWeather) && !user.hasActiveItem?(:UTILITYUMBRELLA)) || 
              (user.hasActiveAbility?(:ICEBODY) && [:Hail].include?(expectedWeather)) || 
              (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
                score*=1.2
            end
            if pbHasSingleTargetProtectMove?(user, false)
                score*=1.2
            end
            if maxdam*5 < user.totalhp
                score*=1.2
            end
            if maxdam > user.totalhp*0.4
                score*=0.3
            end
            if pbHasPivotMove?(user)
                score*=0.8
            end
            if pbHasPhazingMove?(target)
                score*=0.3
            end
            hasAlly = !target.allAllies.empty?
            if hasAlly
                score*=0.5
            end
            burny = target.moves.any? { |m| ["BurnTarget","BurnFlinchTarget","RecoilThirdOfDamageDealtBurnTarget"].include?(m&.function) }
            if user.status == :BURN || burny
                score*=1.3
            end
        else
            score*=0
        end
    #---------------------------------------------------------------------------
    when "StartHealUserEachTurnTrapUserInBattle" # ingrain
          if !user.effects[PBEffects::Ingrain]
            bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
            maxdam = bestmove[0]
            if user.hp*(1.0/user.totalhp)>0.75
                score*=1.2
            end
            if user.hp*(1.0/user.totalhp)<0.50
                score*=0.7
                if user.hp*(1.0/user.totalhp)<0.33
                    score*=0.5
                end            
            end
            if user.hasActiveItem?(:LEFTOVERS) || user.effects[PBEffects::AquaRing] || (expectedTerrain == :Grass && user.affectedByTerrain?) ||
              (user.hasActiveAbility?(:HEALINGSUN) && [:Sun, :HarshSun].include?(expectedWeather) && !user.hasActiveItem?(:UTILITYUMBRELLA)) || 
              (user.hasActiveAbility?(:RAINDISH) && [:Rain, :HeavyRain].include?(expectedWeather) && !user.hasActiveItem?(:UTILITYUMBRELLA)) || 
              (user.hasActiveAbility?(:ICEBODY) && [:Hail].include?(expectedWeather)) || 
              (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
                score*=1.2
            end
            if pbHasSingleTargetProtectMove?(user, false)
                score*=1.2
            end
            if maxdam*5 < user.totalhp
                score*=1.2
            end
            if maxdam > user.totalhp*0.4
                score*=0.3
            end
            if pbHasPivotMove?(user)
                score*=0.8
            end
            if pbHasPhazingMove?(target)
                if pbHasSetupMove?(user)
                    score*=1.2
                else
                    score*=0.3
                end
            end
            hasAlly = !target.allAllies.empty?
            if hasAlly
                score*=0.5
            end
        else
            score*=0
        end
    #---------------------------------------------------------------------------
    when "StartDamageTargetEachTurnIfTargetAsleep" # nightmare
        if !target.effects[PBEffects::Nightmare] && 
           target.effects[PBEffects::Substitute]<=0 && 
           target.asleep?
            if target.statusCount>2
                score*=4
            end
            if target.hasActiveAbility?(:EARLYBIRD)
                score*=0.5
            end
            if target.hasActiveAbility?(:COMATOSE)
                score*=6
            end
            if target.hasActiveAbility?(:SHEDSKIN)
                score*=0.5
            end
            if user.hasActiveAbility?([:ARENATRAP, :SHADOWTAG]) || target.effects[PBEffects::MeanLook]>=0 || 
                    @battle.pbAbleNonActiveCount(user.idxOpposingSide)==0
                score*=1.3
            else
                score*=0.8
            end
            hasAlly = !target.allAllies.empty?
            if hasAlly
                score*=0.5
            end
        else
            score*=0
        end
    #---------------------------------------------------------------------------
    when "StartLeechSeedTarget" # leech seed
        if target.effects[PBEffects::LeechSeed]<0 && !target.pbHasType?(:GRASS, true) && target.effects[PBEffects::Substitute]<=0
            movecheck = pbHasPivotMove?(target)
            movecheck = true if target.moves.any? { |j| j&.id == :RAPIDSPIN }
            if movecheck
                score*=0.2
            end
            if user.effects[PBEffects::Substitute]>0
                score*=1.3
            end
            if target.hp==target.totalhp
                score*=1.1
            else
                score*=(target.hp*(1.0/target.totalhp))
            end
            if target.hasActiveItem?([:LEFTOVERS, :BIGROOT, :COLOGNECASE]) || 
                    (target.hasActiveItem?(:BLACKSLUDGE) && target.pbHasType?(:POISON, true))
                score*=1.2
            end
            if target.paralyzed? || target.asleep?
                score*=1.2
            end
            if target.poisoned? || target.burned? || target.frozen?
                score*=1.1
            end
            if target.effects[PBEffects::Confusion]>0
                score*=1.2
            end
            if target.effects[PBEffects::Attract]>=0
                score*=1.2
            end
            if (target.hp*2)<target.totalhp
                score*=0.8
                if (target.hp*4)<target.totalhp
                    score*=0.2
                end
            end
            if pbHasSingleTargetProtectMove?(user, false)
                score*=1.2
            end
            ministat=0
            ministat+=target.stages[:ATTACK] if target.stages[:ATTACK]>0
            ministat+=target.stages[:SPECIAL_ATTACK] if target.stages[:SPECIAL_ATTACK]>0
            ministat+=target.stages[:SPEED] if target.stages[:SPEED]>0
            ministat+=target.stages[:DEFENSE] if target.stages[:DEFENSE]>0
            ministat+=target.stages[:SPECIAL_DEFENSE] if target.stages[:SPECIAL_DEFENSE]>0
            ministat+=target.stages[:ACCURACY] if target.stages[:ACCURACY]>0
            ministat+=target.stages[:EVASION] if target.stages[:EVASION]>0
            ministat*=(5)
            ministat+=100
            ministat/=100.0
            score*=ministat
            if target.hasActiveAbility?(:LIQUIDOOZE) || target.effects[PBEffects::Substitute]>0
                score*=0
            end
        else
            score*=0
        end
    #---------------------------------------------------------------------------
    when "UserLosesHalfOfTotalHP", "UserLosesHalfOfTotalHPExplosive" # Steel Beam, Mind Blown
        bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
        maxdam=bestmove[0]
        healvar = target.moves.any? { |m| m&.healingMove? }
        movecheck = pbHasSingleTargetProtectMove?(target)
        if (!user.hasActiveAbility?(:MAGICGUARD) && user.hp<user.totalhp*0.5) || 
                (user.hp<user.totalhp*0.75 && 
                ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0))) ||
                (!@battle.pbCheckGlobalAbility(:DAMP) && move.function == "UserLosesHalfOfTotalHPExplosive")
            if !user.hasActiveAbility?(:MAGICGUARD)
                if user.hasActiveAbility?(:PARTYPOPPER)
                    score*=1.2
                end
                score*=0.7
                if targetSurvivesMove(move,user,target)
                    score*=0.7
                end
                if !userFasterThanTarget
                    score*=0.5
                end
                if maxdam < user.totalhp*0.2
                    score*=1.3
                end
                healcheck = user.moves.any? { |m| m&.healingMove? }
                if healcheck
                    score*=1.2
                end
                if movecheck
                    score*=0.5
                end
                ministat=0
                ministat+=target.stages[:EVASION]
                minimini=(-10)*ministat
                minimini+=100
                minimini/=100.0
                score*=minimini
                ministat=0
                ministat+=user.stages[:ACCURACY]
                minimini=(10)*ministat
                minimini+=100
                minimini/=100.0
                score*=minimini
                if target.hasActiveItem?(:LAXINCENSE) || target.hasActiveItem?(:BRIGHTPOWDER)
                    score*=0.7
                end
                #if (target.hasActiveAbility?(:SANDVEIL) && target.effectiveWeather == :Sandstorm) || 
                #        (target.hasActiveAbility?(:SNOWCLOAK) && target.effectiveWeather == :Hail)
                #    score*=0.7
                #end
            else
                score*=1.1
            end
        end
        target_num = move.pbTarget(user)
        miniscore = getAbilityDisruptScore(move,target,user,skill) # how good is our ability?
        user.allAllies.each do |b|
            if user.hp<user.totalhp*0.5
                if b.hasActiveAbility?(:SEANCE)
                    score*=miniscore*1.1
                    if user.hasAbilityMutation? && b.hasAbilityMutation?
                        score*=2
                    end
                end
                if target_num.id == :AllNearOthers && 
                   !Effectiveness.ineffective?(pbCalcTypeMod(move.type, user, b))
                    score*=0.7
                end
            end
        end
        if user.hp<user.totalhp*0.5
            reserves = @battle.pbAbleNonActiveCount(user.idxOwnSide)
            foes     = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
            if skill >= PBTrainerAI.mediumSkill && reserves == 0 && foes > 0
                score = 0      # don't want to lose
            elsif skill >= PBTrainerAI.highSkill && reserves == 0 && foes == 0
                score *= 1.8   # want to draw
            end
        end
    #---------------------------------------------------------------------------
    when "UserFaintsExplosive" # explosion
        score*=0.7
        if user.hp==user.totalhp
            score*=0.2
        else
            miniscore = user.hp*(1.0/user.totalhp)
            miniscore = 1-miniscore
            score*=miniscore
            if user.hp*4<user.totalhp            
                score*=1.3
                if user.hasActiveItem?(:CUSTAPBERRY)
                    score*=1.4
                end            
            end          
        end
        if user.pokemonIndex == 0 # on the lead slot
            score*=1.2
        end
        if user.hasActiveAbility?(:PARTYPOPPER)
            score*=1.2
        end
        if (user.hasActiveAbility?(:DISGUISE) && user.form == 0) || user.effects[PBEffects::Substitute]>0
            score*=0.3
        end
        score*=0.3 if pbHasSingleTargetProtectMove?(target)
        if @battle.pbCheckGlobalAbility(:DAMP)
            score=0
        end
        target_num = move.pbTarget(user)
        miniscore = getAbilityDisruptScore(move,target,user,skill) # how good is our ability?
        user.allAllies.each do |b|
            if b.hasActiveAbility?(:SEANCE)
                score*=miniscore*1.1
                if user.hasAbilityMutation? && b.hasAbilityMutation?
                    score*=2
                end
            end
            if target_num.id == :AllNearOthers && 
              !Effectiveness.ineffective?(pbCalcTypeMod(move.type, user, b))
                score*=0.7
            end
        end
        reserves = @battle.pbAbleNonActiveCount(user.idxOwnSide)
        foes     = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
        if skill >= PBTrainerAI.mediumSkill && reserves == 0 && foes > 0
            score = 0      # don't want to lose
        elsif skill >= PBTrainerAI.highSkill && reserves == 0 && foes == 0
            score *= 1.8   # want to draw
        end
    #---------------------------------------------------------------------------
    when "UserFaintsPowersUpInMistyTerrainExplosive" # misty explosion
        score*=0.7
        if user.hp==user.totalhp
            score*=0.2
        else
            miniscore = user.hp*(1.0/user.totalhp)
            miniscore = 1-miniscore
            score*=miniscore
            if user.hp*4<user.totalhp            
                score*=1.3
                if user.hasActiveItem?(:CUSTAPBERRY)
                    score*=1.4
                end            
            end          
        end
        if user.pokemonIndex == 0 # on the lead slot
            score*=1.2
        end
        if (user.hasActiveAbility?(:DISGUISE) && user.form == 0) || user.effects[PBEffects::Substitute]>0
            score*=0.3
        end
        score*=0.3 if pbHasSingleTargetProtectMove?(target)
        if @battle.pbCheckGlobalAbility(:DAMP)
            score=0
        end
        target_num = move.pbTarget(user)
        miniscore = getAbilityDisruptScore(move,target,user,skill) # how good is our ability?
        user.allAllies.each do |b|
            if b.hasActiveAbility?(:SEANCE)
                score*=miniscore*1.1
                if user.hasAbilityMutation? && b.hasAbilityMutation?
                    score*=2
                end
            end
            if target_num.id == :AllNearOthers && 
              !Effectiveness.ineffective?(pbCalcTypeMod(move.type, user, b))
                score*=0.7
            end
        end
        reserves = @battle.pbAbleNonActiveCount(user.idxOwnSide)
        foes     = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
        if skill >= PBTrainerAI.mediumSkill && reserves == 0 && foes > 0
            score = 0      # don't want to lose
        elsif skill >= PBTrainerAI.highSkill && reserves == 0 && foes == 0
            score *= 1.8   # want to draw
            score *= 1.2 if expectedTerrain == :Misty
        end
    #---------------------------------------------------------------------------
    when "UserFaintsFixedDamageUserHP" # final gambit
        score*=0.7
        if user.hp > target.hp
            score*=1.1
        else
            score*=0.5
        end
        if userFasterThanTarget
            score*=1.1
        else
            score*=0.5
        end  
        if target.hasActiveItem?(:FOCUSSASH) || target.hasActiveAbility?(:STURDY,false,mold_broken)
            score*=0.2
        end
        miniscore = getAbilityDisruptScore(move,target,user,skill) # how good is our ability?
        user.allAllies.each do |b|
            if b.hasActiveAbility?(:SEANCE)
                score*=miniscore*1.1
                if user.hasAbilityMutation? && b.hasAbilityMutation?
                    score*=2
                end
            end
        end
        reserves = @battle.pbAbleNonActiveCount(user.idxOwnSide)
        foes     = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
        if skill >= PBTrainerAI.mediumSkill && reserves == 0 && foes > 0
            score = 0      # don't want to lose
        elsif skill >= PBTrainerAI.highSkill && reserves == 0 && foes == 0
            score *= 1.8   # want to draw
        end
    #---------------------------------------------------------------------------
    when "UserFaintsLowerTargetAtkSpAtk2" # memento
        if user.hp==user.totalhp
            seancecheck = user.allAllies.any? { |b| b&.hasActiveAbility?(:SEANCE) }
            score*=0.2 if !seancecheck
        else
            miniscore = user.hp*(1.0/user.totalhp)
            miniscore = 1-miniscore
            score*=miniscore
            if user.hp*4<user.totalhp 
                score*=1.3
            end
        end
        if target.attack > target.spatk
            if target.stages[:ATTACK]<-1
                score*=0.1
            end
        else
            if target.stages[:SPECIAL_ATTACK]<-1
                score*=0.1
            end
        end
        if target.hasActiveAbility?([:CLEARBODY, :WHITESMOKE],false,mold_broken)
            score=0
        end
        miniscore = getAbilityDisruptScore(move,target,user,skill) # how good is our ability?
        user.allAllies.each do |b|
            if b.hasActiveAbility?(:SEANCE)
                score*=miniscore*1.1
                if user.hasAbilityMutation? && b.hasAbilityMutation?
                    score*=2
                end
            end
        end
        reserves = @battle.pbAbleNonActiveCount(user.idxOwnSide)
        foes     = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
        if skill >= PBTrainerAI.mediumSkill && reserves == 0 && foes > 0
            score = 0      # don't want to lose
        elsif skill >= PBTrainerAI.highSkill && reserves == 0 && foes == 0
            score *= 1.8   # want to draw
        end
    #---------------------------------------------------------------------------
    when "UserFaintsHealAndCureReplacement", "UserFaintsHealAndCureReplacementRestorePP" # healing wish, lunar dance
        if @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
            score=0
        else
            maxscore = 0
            @battle.pbParty(target.index).each do |mon|
                next if mon.fainted?
                if mon.hp!=mon.totalhp
                    miniscore = 1 - mon.hp*(1.0/mon.totalhp)
                    miniscore*=2 if mon.status!=0
                    maxscore=miniscore if miniscore>maxscore
                end    
            end
            score*=maxscore

            if user.hp==user.totalhp
                score*=0.2
            else
                miniscore = user.hp*(1.0/user.totalhp)
                miniscore = 1-miniscore
                score*=miniscore
                if user.hp*4<user.totalhp 
                    score*=1.3
                    if user.hasActiveItem?(:CUSTAPBERRY)
                        score*=1.4
                    end
                end
            end
            if userFasterThanTarget
                score*=1.1
            else
                bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
                maxmove=bestmove[1]
                if !targetSurvivesMove(maxmove,target,user)
                    score*=0.5
                end
            end
            miniscore = getAbilityDisruptScore(move,target,user,skill) # how good is our ability?
            user.allAllies.each do |b|
                if b.hasActiveAbility?(:SEANCE)
                    score*=miniscore*1.1
                    if user.hasAbilityMutation? && b.hasAbilityMutation?
                        score*=2
                    end
                end
            end
        end
    #---------------------------------------------------------------------------
    when "StartPerishCountsForAllBattlers" # perish song
        userlivecount   = @battle.pbAbleCount(user.idxOwnSide)
        targetlivecount = @battle.pbAbleCount(user.idxOpposingSide)
        hasAlly = !target.allAllies.empty?
        if (targetlivecount==1 && !hasAlly) || (targetlivecount==2 && hasAlly)
            score*=4
        else
            if user.hasActiveAbility?(:SHADOWTAG) ||
               (user.hasActiveAbility?(:BAITEDLINE) && target.pbHasType?(:WATER, true)) || 
               (user.hasActiveAbility?(:MAGNETPULL) && target.pbHasType?(:STEEL, true))
                score*=3
            end
            score*=2 if target.trappedInBattle?
            if pbHasSingleTargetProtectMove?(user, false)
                score*=1.2
            end
            score*=1.2 if user.moves.any? { |m| m&.healingMove? }
            raisedstats=0
            raisedstats+=target.stages[:ATTACK] if target.stages[:ATTACK]>0
            raisedstats+=target.stages[:DEFENSE] if target.stages[:DEFENSE]>0
            raisedstats+=target.stages[:SPEED] if target.stages[:SPEED]>0
            raisedstats+=target.stages[:SPECIAL_ATTACK] if target.stages[:SPECIAL_ATTACK]>0
            raisedstats+=target.stages[:SPECIAL_DEFENSE] if target.stages[:SPECIAL_DEFENSE]>0
            #raisedstats+=target.stages[:EVASION] if target.stages[:EVASION]>0
            miniscore= 5*raisedstats
            miniscore+=100
            miniscore/=100.0
            score*=miniscore          
            loweredstats=0
            loweredstats+=user.stages[:ATTACK] if user.stages[:ATTACK]<0
            loweredstats+=user.stages[:DEFENSE] if user.stages[:DEFENSE]<0
            loweredstats+=user.stages[:SPEED] if user.stages[:SPEED]<0
            loweredstats+=user.stages[:SPECIAL_ATTACK] if user.stages[:SPECIAL_ATTACK]<0
            loweredstats+=user.stages[:SPECIAL_DEFENSE] if user.stages[:SPECIAL_DEFENSE]<0
            miniscore= (-5)*loweredstats
            miniscore+=100
            miniscore/=100.0
            score*=miniscore          
            raisedstats=0
            raisedstats+=user.stages[:ATTACK] if user.stages[:ATTACK]>0
            raisedstats+=user.stages[:DEFENSE] if user.stages[:DEFENSE]>0
            raisedstats+=user.stages[:SPEED] if user.stages[:SPEED]>0
            raisedstats+=user.stages[:SPECIAL_ATTACK] if user.stages[:SPECIAL_ATTACK]>0
            raisedstats+=user.stages[:SPECIAL_DEFENSE] if user.stages[:SPECIAL_DEFENSE]>0
            miniscore= (-5)*raisedstats
            miniscore+=100
            miniscore/=100.0
            score*=miniscore          
            loweredstats=0
            loweredstats+=target.stages[:ATTACK] if target.stages[:ATTACK]<0
            loweredstats+=target.stages[:DEFENSE] if target.stages[:DEFENSE]<0
            loweredstats+=target.stages[:SPEED] if target.stages[:SPEED]<0
            loweredstats+=target.stages[:SPECIAL_ATTACK] if target.stages[:SPECIAL_ATTACK]<0
            loweredstats+=target.stages[:SPECIAL_DEFENSE] if target.stages[:SPECIAL_DEFENSE]<0
            miniscore= 5*loweredstats
            miniscore+=100
            miniscore/=100.0
            score*=miniscore
            
            if target.hasActiveAbility?(:SHADOWTAG) ||
               (target.hasActiveAbility?(:BAITEDLINE) && user.pbHasType?(:WATER, true)) || 
               (target.hasActiveAbility?(:MAGNETPULL) && user.pbHasType?(:STEEL, true))
                score*=0.1
            end
            if pbHasPivotMove?(user)
                score*=1.5 
            else
                if user.trappedInBattle?
                    score*=0.1
                end
            end
            score*=0.5 if pbHasPivotMove?(target)
            hasAllyDos = !user.allAllies.empty?
            if (userlivecount==1 && !hasAllyDos) || (userlivecount==2 && hasAllyDos)
                score=0
            end
        end                
        score=0 if target.effects[PBEffects::PerishSong]>0
    #---------------------------------------------------------------------------
    when "AttackerFaintsIfUserFaints" # Destiny Bond
        movenum = 0
        damcount = 0
        for j in target.moves
            movenum+=1
            if j.baseDamage>0 && j.pbContactMove?(target) && target.affectedByContactEffect?
                damcount+=1
            end
        end
        if movenum==4 && damcount>=2
            score*=3
        end
        if user.hp==user.totalhp
            score*=0.2
        else
            miniscore = user.hp*(1.0/user.totalhp)
            miniscore = 1-miniscore
            score*=miniscore
            if user.hp*4<user.totalhp            
                score*=1.3
                if user.hasActiveItem?(:CUSTAPBERRY)
                    score*=1.3
                end            
            end          
        end        
        if userFasterThanTarget
            score*=1.3
        else
            score*0.5
        end
        if user.effects[PBEffects::DestinyBondPrevious] || user.hp<user.totalhp 
            score=0
        end
    #---------------------------------------------------------------------------
    when "SetAttackerMovePPTo0IfUserFaints" # grudge
        movenum = 0
        damcount = 0
        for m in target.moves
            movenum+=1
            if m.baseDamage>0
                damcount+=1
            end
        end
        if movenum==4 && damcount>=2
            score*=3
        end
        if user.hp==user.totalhp
            score*=0.2
        else
            miniscore = user.hp*(1.0/user.totalhp)
            miniscore = 1-miniscore
            score*=miniscore
            if user.hp*4<user.totalhp            
                score*=1.3
                if user.hasActiveItem?(:CUSTAPBERRY)
                    score*=1.3
                end            
            end          
        end        
        if userFasterThanTarget
            score*=1.3
        else
            score*0.5
        end
    #---------------------------------------------------------------------------
    when "UserTakesTargetItem" # covet
        if !target.hasActiveAbility?(:STICKYHOLD) &&
                target.item && !target.unlosableItem?(target.item)
            miniscore = 1.2
            case target.item_id
            when :LEFTOVERS,  :LIFEORB,  :LUMBERRY,  :SITRUSBERRY
                miniscore*=1.5
            when :ASSAULTVEST, :MELEEVEST, :ROCKYHELMET
                miniscore*=1.3
            when :FOCUSSASH,  :MUSCLEBAND,  :WISEGLASSES,  :EXPERTBELT,  :WIDELENS
                miniscore*=1.2
            when :CHOICESCARF
                if aspeed<ospeed && @battle.field.effects[PBEffects::TrickRoom]==0
                    miniscore*=1.1
                end
            when :CHOICEBAND
                if user.attack>user.spatk
                    miniscore*=1.1
                end
            when :CHOICESPECS
                if user.spatk>user.attack
                    miniscore*=1.1
                end
            when :BLACKSLUDGE
                if user.pbHasType?(:POISON, true)
                    miniscore*=1.5
                else
                    miniscore*=0.5
                end
            when :TOXICORB,  :FLAMEORB,  :LAGGINGTAIL,  :IRONBALL,  :STICKYBARB
                miniscore*=0.5
            end
            score*=miniscore
        else
            score=0 if move.statusMove?
        end
    #---------------------------------------------------------------------------
    when "TargetTakesUserItem" # bestow
        if !target.hasActiveAbility?(:STICKYHOLD) &&
           target.item && user.item && 
           !target.unlosableItem?(target.item) && 
           target.effects[PBEffects::Substitute]<=0
            case user.item_id
            when :CHOICESCARF
                if userFasterThanTarget
                    score*=1.2
                end
            when :CHOICEBAND
                if target.attack<target.spatk
                    score*=1.3
                end
            when :CHOICESPECS
                if target.spatk<target.attack
                    score*=1.3
                end
            when :BLACKSLUDGE
                if target.pbHasType?(:POISON, true)
                    score*=1.3
                else
                    score*=0.5
                end
            when :TOXICORB,  :FLAMEORB,  :LAGGINGTAIL,  :IRONBALL,  :STICKYBARB
                score*=1.3
            end
        else
            score=0 if move.statusMove?
        end
    #---------------------------------------------------------------------------
    when "UserTargetSwapItems" # trick
        statvar = target.moves.any? { |m| m&.baseDamage == 0 }
        if !target.hasActiveAbility?(:STICKYHOLD) && target.effects[PBEffects::Substitute]<=0
            miniscore = 1.2
            minimini  = 0.8
            if target.item && !target.unlosableItem?(target.item)
                case target.item_id
                when :LEFTOVERS,  :LIFEORB,  :LUMBERRY,  :SITRUSBERRY
                    miniscore*=1.5
                when :ASSAULTVEST, :MELEEVEST,  :ROCKYHELMET
                    miniscore*=1.3
                when :FOCUSSASH,  :MUSCLEBAND,  :WISEGLASSES,  :EXPERTBELT,  :WIDELENS
                    miniscore*=1.2
                when :CHOICESCARF
                    if aspeed<ospeed && @battle.field.effects[PBEffects::TrickRoom]==0
                        miniscore*=1.1
                    end
                when :CHOICEBAND
                    if user.attack>user.spatk
                        miniscore*=1.1
                    end
                when :CHOICESPECS
                    if user.spatk>user.attack
                        miniscore*=1.1
                    end
                when :BLACKSLUDGE
                    if user.pbHasType?(:POISON, true)
                        miniscore*=1.5
                    else
                        miniscore*=0.5
                    end
                when :TOXICORB,  :FLAMEORB,  :LAGGINGTAIL,  :IRONBALL,  :STICKYBARB
                    miniscore*=0.5
                end
            end
            if user.item && !user.unlosableItem?(user.item)
                case user.item_id
                when :LEFTOVERS,  :LIFEORB,  :LUMBERRY,  :SITRUSBERRY
                    minimini*=0.5
                when :ASSAULTVEST, :MELEEVEST,  :ROCKYHELMET
                    minimini*=0.7
                when :FOCUSSASH,  :MUSCLEBAND,  :WISEGLASSES,  :EXPERTBELT,  :WIDELENS
                    minimini*=0.8
                when :CHOICESCARF
                    if !userFasterThanTarget
                        minimini*=1.5
                    else
                        minimini*=0.9
                    end
                    if statvar
                        minimini*=1.3
                    end
                when :CHOICEBAND
                    if target.attack<target.spatk
                        minimini*=1.7
                    end
                    if user.attack>user.spatk
                        minimini*=0.8
                    end
                    if statvar
                        minimini*=1.3
                    end
                when :CHOICESPECS
                    if target.attack>target.spatk
                        minimini*=1.7
                    end
                    if user.attack<user.spatk
                        minimini*=0.8
                    end
                    if statvar
                        minimini*=1.3
                    end
                when :BLACKSLUDGE
                    if user.pbHasType?(:POISON, true)
                        minimini*=1.5
                    else
                        minimini*=0.5
                    end
                    if !target.pbHasType?(:POISON, true)
                        minimini*=1.3
                    end
                when :TOXICORB,  :FLAMEORB,  :LAGGINGTAIL,  :IRONBALL,  :STICKYBARB
                    minimini*=0.5
                end
            end
            score*=(miniscore*minimini)
        else
            score = 0
        end
        if user.item==target.item
            score=0
        end
    #---------------------------------------------------------------------------
    when "RestoreUserConsumedItem" # recycle
        movecheck = target.pbHasMoveFunction?("DestroyTargetBerryOrGem", "UserConsumeTargetBerry")
        stealvar  = target.pbHasMoveFunction?("RemoveTargetItem", "UserTakesTargetItem")
        if user.recycleItem
            score*=2
            case user.recycleItem
            when :LUMBERRY
                score*=2 if user.pbHasAnyStatus?
            when :SITRUSBERRY, :NYLOBERRY
                score*=1.6 if user.hp*(1.0/user.totalhp)<0.66
                targetroles = pbGetPokemonRole(target)
                if targetroles.include?("Physical Wall") || targetroles.include?("Special Wall") 
                    score*=1.5
                end
            end
            if user.recycleItem.is_berry?
                if target.hasActiveAbility?(:UNNERVE)
                    score=0
                end
                if movecheck
                    score=0
                end
            end
            if target.hasActiveAbility?(:MAGICIAN) || stealvar
                score=0
            end
            if user.hasActiveAbility?([:HARVEST, :UNBURDEN]) || user.pbHasMove?(:ACROBATICS)
                score=0
            end
        else
            score=0
        end
    #---------------------------------------------------------------------------
    when "RemoveTargetItem" # knock off
        if target.effects[PBEffects::Substitute]<=0
            if !target.hasActiveAbility?(:STICKYHOLD) && target.item && !target.unlosableItem?(target.item)
                score*=1.1
                if target.hasActiveItem?(:LEFTOVERS) || (target.hasActiveItem?(:BLACKSLUDGE) && target.pbHasType?(:POISON, true))
                    score*=1.3
                end    
                if target.hasActiveItem?([:LIFEORB, :CHOICESCARF, :CHOICEBAND, :CHOICESPECS, :ASSAULTVEST, :MELEEVEST])
                    score*=1.2
                end        
            end
        end
    #---------------------------------------------------------------------------
    when "DestroyTargetBerryOrGem" # incinerate
        if !target.hasActiveAbility?(:STICKYHOLD) && target.effects[PBEffects::Substitute]<=0
            if target.item == :LUMBERRY || target.item == :SITRUSBERRY || target.item == :PETAYABERRY || 
               target.item == :LIECHIBERRY || target.item == :SALACBERRY || target.item == :CUSTAPBERRY
                score*=1.3
            else
                score*=0.8
            end
         end
    #---------------------------------------------------------------------------
    when "CorrodeTargetItem" # Corrosive Gas
        if @battle.corrosiveGas[target.index % 2][target.pokemonIndex]
            score = 0
        else
            if target.effects[PBEffects::Substitute]<=0
                if !target.hasActiveAbility?(:STICKYHOLD) &&
                   target.item && !target.unlosableItem?(target.item)
                    score*=1.1
                    if target.hasActiveItem?(:LEFTOVERS) || (target.hasActiveItem?(:BLACKSLUDGE) && target.pbHasType?(:POISON, true))
                        score*=1.2
                    end    
                    if target.hasActiveItem?([:LIFEORB, :CHOICESCARF, :CHOICEBAND, :CHOICESPECS, :ASSAULTVEST, :MELEEVEST])
                        score*=1.1
                    end        
                end
            end
        end
    #---------------------------------------------------------------------------
    when "StartTargetCannotUseItem" # embargo
        initialscores = score
        if target.effects[PBEffects::Embargo]>0  && target.effects[PBEffects::Substitute]>0
            score=0 if move.baseDamage == 0
        else
            if target.item
                score*=1.1
                case target.item_id
                when :LAXINCENSE, :ELECTRICSEED, :GRASSYSEED, :MISTYSEED, :PSYCHICSEED, :EXPERTBELT, :MUSCLEBAND, :WISEGLASSES, :LIFEORB, :EVIOLITE, :ASSAULTVEST, :MELEEVEST
                    score*=1.2
                when :LEFTOVERS, :BLACKSLUDGE
                    score*=1.3
                end
                if target.hp*2<target.totalhp
                    score*=1.4
                end
            end
            if score==initialscores
                score*=0 if move.baseDamage == 0
            end
        end
    #---------------------------------------------------------------------------
    when "StartNegateHeldItems" # magic room
        if @battle.field.effects[PBEffects::MagicRoom] > 0
            score=0
        else
            if target.item
                score*=1.1
                case target.item_id
                when :LAXINCENSE, :EXPERTBELT, :MUSCLEBAND, :WISEGLASSES, 
                     :LIFEORB, :EVIOLITE, :ASSAULTVEST, :MELEEVEST
                    score*=1.2
                when :LEFTOVERS, :BLACKSLUDGE
                    score*=1.3
                end
                if target.hp*2<target.totalhp
                    score*=1.4
                end
            end
            if user.item
                score*=0.8
                case user.item_id
                when :LAXINCENSE, :EXPERTBELT, :MUSCLEBAND, :WISEGLASSES, 
                     :LIFEORB, :EVIOLITE, :ASSAULTVEST, :MELEEVEST
                    score*=0.6
                when :LEFTOVERS, :BLACKSLUDGE
                    score*=0.4
                end
                if user.hp*2<user.totalhp
                    score*=1.4
                end
            end
            if user.hasActiveAbility?(:TRICKSTER)
                score*=1.4
            end
        end
    #---------------------------------------------------------------------------
    when "UserConsumeBerryRaiseDefense2" # Stuff Cheeks
        if !user.item || !user.item.is_berry? || !user.itemActive?
            score = 0
        else
            useful_berries = [
                :ORANBERRY, :SITRUSBERRY, :AGUAVBERRY, :APICOTBERRY, :CHERIBERRY,
                :CHESTOBERRY, :FIGYBERRY, :GANLONBERRY, :IAPAPABERRY, :KEEBERRY,
                :LANSATBERRY, :LEPPABERRY, :LIECHIBERRY, :LUMBERRY, :MAGOBERRY,
                :MARANGABERRY, :PECHABERRY, :PERSIMBERRY, :PETAYABERRY, :RAWSTBERRY,
                :SALACBERRY, :STARFBERRY, :WIKIBERRY
            ]
            ebinberry = [:LIECHIBERRY, :GANLONBERRY, :SALACBERRY, :PETAYABERRY, :APICOTBERRY, :STARFBERRY]
            score *= 1.2 if useful_berries.include?(user.item_id)
            if ebinberry.include?(user.item_id)
                score *= 1.2
                score *= 1.2 if user.turnCount<2
            end
            score *= 1.2 if user.canHeal? && user.hp < user.totalhp / 3.0 && user.hasActiveAbility?(:CHEEKPOUCH)
            score *= 1.2 if user.hasActiveAbility?([:HARVEST, :RIPEN]) ||
                            user.pbHasMoveFunction?("RestoreUserConsumedItem")   # Recycle
            score *= 1.2 if !user.canConsumeBerry?

            # defense boost
            miniscore=100
            if (user.hasActiveAbility?(:DISGUISE) && user.form == 0) || user.effects[PBEffects::Substitute]>0
                miniscore*=1.3
            end
            hasAlly = !target.allAllies.empty?
            if !hasAlly && move.statusMove? && @battle.choices[target.index][0] == :SwitchOut
                miniscore*=2
            end
            if (user.hp.to_f)/user.totalhp>0.75
                miniscore*=1.2
            end
            if (user.hp.to_f)/user.totalhp<0.33
                miniscore*=0.3
            end
            if (user.hp.to_f)/user.totalhp<0.75 && (user.hasActiveAbility?(:EMERGENCYEXIT) || user.hasActiveAbility?(:WIMPOUT) || user.hasActiveItem?(:EJECTBUTTON))
                miniscore*=0.3
            end  
            if target.effects[PBEffects::HyperBeam]>0
                miniscore*=1.3
            end
            if target.effects[PBEffects::Yawn]>0
                miniscore*=1.7
            end
            bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
            maxdam=bestmove[0]
            if maxdam<(user.hp/4.0)
                miniscore*=1.2
            else
                if move.baseDamage==0 
                    miniscore*=0.8
                    if maxdam>user.hp
                        miniscore*=0.1
                    end
                end              
            end
            miniscore*=1.3 if target.moves.any? { |m| m&.healingMove? }
            if userFasterThanTarget
                miniscore*=1.5
            else
                miniscore*=1.5 if user.item_id == :SALACBERRY
            end
            if pbHasPhazingMove?(target)
                miniscore*=0.2
            end
            if user.hasActiveAbility?(:SIMPLE)
                miniscore*=2
            end
            hasAlly = !target.allAllies.empty?
            if hasAlly
                miniscore*=0.7
            end
            if user.stages[:DEFENSE]>0
                ministat=user.stages[:DEFENSE]
                minimini=-15*ministat
                minimini+=100          
                minimini/=100.0          
                miniscore*=minimini
            end
            if pbRoughStat(target,:ATTACK,skill)>pbRoughStat(target,:SPECIAL_ATTACK,skill)
                miniscore*=1.3
            end
            bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
            maxdam=bestmove[0]
            if (maxdam.to_f/user.hp)<0.12
                miniscore*=0.3
            end
            roles = pbGetPokemonRole(user, target)
            if roles.include?("Physical Wall") || roles.include?("Special Wall")
                miniscore*=1.3
            end
            if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
                miniscore*=1.2
            end
            miniscore*=1.3 if user.moves.any? { |m| m&.healingMove? }
            if user.pbHasMove?(:LEECHSEED)
                miniscore*=1.3
            end
            if user.pbHasMove?(:PAINSPLIT)
                miniscore*=1.2
            end        
            if targetWillMove?(target, "phys")
                if move.statusMove? && userFasterThanTarget && 
                   priorityAI(target,@battle.choices[target.index][2],globalArray)<1
                    miniscore*=1.2
                end
            end
            if user.statStageAtMax?(:DEFENSE)
                miniscore=0
            end
            movecheck=target.moves.any? { |j| [:CLEARSMOG, :HAZE].include?(j&.id) }
            miniscore*=0 if movecheck
            if user.hasActiveAbility?(:CONTRARY)
                miniscore*=0
            end            
            if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
                miniscore=1
            end
            score*=miniscore
            score = 0 if ($player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id) && move.statusMove?)
        end
    #---------------------------------------------------------------------------
    when "AllBattlersConsumeBerry" # Teatime
        useful_berries = [
            :ORANBERRY, :SITRUSBERRY, :AGUAVBERRY, :APICOTBERRY, :CHERIBERRY,
            :CHESTOBERRY, :FIGYBERRY, :GANLONBERRY, :IAPAPABERRY, :KEEBERRY,
            :LANSATBERRY, :LEPPABERRY, :LIECHIBERRY, :LUMBERRY, :MAGOBERRY,
            :MARANGABERRY, :PECHABERRY, :PERSIMBERRY, :PETAYABERRY,
            :RAWSTBERRY, :SALACBERRY, :STARFBERRY, :WIKIBERRY
        ]
        @battle.allSameSideBattlers(user.index).each do |b|
            if !b.item || !b.item.is_berry? || !b.itemActive?
                score -= 100 / @battle.pbSideSize(user.index)
            else
                amt = 30 / @battle.pbSideSize(user.index)
                score += amt if useful_berries.include?(b.item_id)
                amt = 20 / @battle.pbSideSize(user.index)
                score += amt if b.canHeal? && b.hp < b.totalhp / 3.0 && b.hasActiveAbility?(:CHEEKPOUCH)
                score += amt if b.hasActiveAbility?([:HARVEST, :RIPEN]) ||
                                b.pbHasMoveFunction?("RestoreUserConsumedItem")   # Recycle
                score += amt if !b.canConsumeBerry?
            end
        end
        if skill >= PBTrainerAI.highSkill
            @battle.allOtherSideBattlers(user.index).each do |b|
                amt = 10 / @battle.pbSideSize(target.index)
                score -= amt if b.hasActiveItem?(useful_berries)
                score -= amt if b.canHeal? && b.hp < b.totalhp / 3.0 && b.hasActiveAbility?(:CHEEKPOUCH)
                score -= amt if b.hasActiveAbility?([:HARVEST, :RIPEN]) ||
                                b.pbHasMoveFunction?("RestoreUserConsumedItem")   # Recycle
                score -= amt if !b.canConsumeBerry?
            end
        end
    #---------------------------------------------------------------------------
    when "UserConsumeTargetBerry" # bug bite
        if target.effects[PBEffects::Substitute]==0 #&& target.item.is_berry?
            case target.item
            when :LUMBERRY
                score*=2 if user.pbHasAnyStatus?
            when :SITRUSBERRY
                score*=1.6 if user.hp*(1.0/user.totalhp)<0.66
            when :LIECHIBERRY
                score*=1.5 if user.attack>user.spatk
            when :PETAYABERRY
                score*=1.5 if user.spatk>user.attack
            when :CUSTAPBERRY, :SALACBERRY
                score*=1.1
                score*=1.4 if !userFasterThanTarget
            when :NYLOBERRY
                score*=0.8
            end 
            useful_berries = [
                :ORANBERRY, :SITRUSBERRY, :AGUAVBERRY, :APICOTBERRY, :CHERIBERRY,
                :CHESTOBERRY, :FIGYBERRY, :GANLONBERRY, :IAPAPABERRY, :KEEBERRY,
                :LANSATBERRY, :LEPPABERRY, :LIECHIBERRY, :LUMBERRY, :MAGOBERRY,
                :MARANGABERRY, :PECHABERRY, :PERSIMBERRY, :PETAYABERRY, :RAWSTBERRY,
                :SALACBERRY, :STARFBERRY, :WIKIBERRY
            ]
            score *= 1.2 if useful_berries.include?(user.item_id)
        end
    #---------------------------------------------------------------------------
    when "ThrowUserItemAtTarget" # fling
        if !user.item || user.unlosableItem?(user.item) || 
           user.hasActiveAbility?(:KLUTZ) || (user.item.is_berry? && target.hasActiveAbility?(:UNNERVE)) || 
           user.effects[PBEffects::Embargo]>0 || @battle.field.effects[PBEffects::MagicRoom]>0
            score*=0
        else
            case user.item_id
            when :POISONBARB
                if target.pbCanPoison?(user, false) && !target.hasActiveAbility?(:POISONHEAL)
                    score*=1.2
                end
            when :TOXICORB
                if target.pbCanPoison?(user, false) && !target.hasActiveAbility?(:POISONHEAL)
                    score*=1.2
                    if user.pbCanPoison?(nil, false) && !user.hasActiveAbility?(:POISONHEAL)
                        score*=2
                    end                
                end
            when :FLAMEORB
                if target.pbCanBurn?(user, false) && !target.hasActiveAbility?(:GUTS)
                    score*=1.3
                    if user.pbCanBurn?(nil, false) && !user.hasActiveAbility?(:GUTS)
                        score*=2
                    end                
                end
            when :LIGHTBALL
                if target.pbCanParalyze?(user, false) && !target.hasActiveAbility?(:QUICKFEET)
                    score*=1.3
                end
            when :KINGSROCK, :RAZORCLAW
                if canFlinchTarget(user,target,mold_broken) && userFasterThanTarget
                    score*=1.3
                end
            when :POWERHERB
                score=0
            when :MENTALHERB
                score=0
            when :LAXINCENSE, :CHOICESCARF, :CHOICEBAND, :CHOICESPECS, 
                    :EXPERTBELT, :FOCUSSASH, :LEFTOVERS, :MUSCLEBAND, 
                    :WISEGLASSES, :LIFEORB, :EVIOLITE, :ASSAULTVEST, 
                    :BLACKSLUDGE, :MELEEVEST
                score=0
            when :STICKYBARB
                score*=1.2
            when :LAGGINGTAIL
                score*=3
            when :IRONBALL
                score*=1.5
            end
        end
    #---------------------------------------------------------------------------
    when "RedirectAllMovesToUser" # follow me
        if user.allAllies.length == 0
            score*=0
        else
            roles = pbGetPokemonRole(user, target)
            if roles.include?("Physical Wall") || roles.include?("Special Wall")
                score*=1.2
            end
            user.allAllies.each do |m|
                score*=1.3 if m.hasActiveAbility?(:MOODY)
                if m.turnCount<1
                    score*=2
                else
                    score*=1.2
                end
                score*=1.3 if pbHasSetupMove?(m, false)
            end
            if user.hp==user.totalhp
                score*=1.2
            else
                score*=0.8
                if user.hp*2 < user.totalhp
                    score*=0.5
                end
            end
            speedcheck=0
            target.allAllies.each do |m|
                speedcheck+= 1 if aspeed < pbRoughStat(m, :SPEED, skill)
            end
            score*=1.2 if (target.allAllies.length+1) == speedcheck
        end
    #---------------------------------------------------------------------------
    when "RedirectAllMovesToTarget" # Spotlight
        if user.allAllies.length == 0
            score=0
        else
            if user.opposes?(target) # is enemy
                score=0
            else                     # is ally
                target2 = user.pbDirectOpposing(true)
                if target2.allAllies.empty?
                    target3 = target2
                else
                    target3 = target2.allAllies.first
                end

                bestmove = bestMoveVsTarget(target2,user,skill) # [maxdam,maxmove,maxprio,physorspec]
                maxmove = bestmove[1]
                maxtype2 = maxmove.type
                contactcheck2 = maxmove.pbContactMove?(target2)

                bestmove = bestMoveVsTarget(target3,user,skill) # [maxdam,maxmove,maxprio,physorspec]
                maxmove = bestmove[1]
                maxtype3 = maxmove.type
                contactcheck3 = maxmove.pbContactMove?(target3)

                if target.hasActiveAbility?(:FLASHFIRE) && (maxtype2==:FIRE || maxtype3==:FIRE)
                    score*=3
                end
                if target.hasActiveAbility?([:DRYSKIN, :STORMDRAIN, :WATERABSORB]) && (maxtype2==:WATER || maxtype3==:WATER)
                    score*=3
                end
                if target.hasActiveAbility?([:MOTORDRIVE, :LIGHTNINGROD, :VOLTABSORB]) && (maxtype2==:ELECTRIC || maxtype3==:ELECTRIC)
                    score*=3
                end
                if target.hasActiveAbility?(:SAPSIPPER) && (maxtype2==:GRASS || maxtype3==:GRASS)
                    score*=3
                end
                if target.pbHasMove?(:KINGSSHIELD) || target.pbHasMove?(:BANEFULBUNKER) || 
                   target.pbHasMove?(:SPIKYSHIELD) || target.pbHasMove?(:OBSTRUCT)
                    if contactcheck2 || contactcheck3
                        score*=2
                    end
                end
                if target.pbHasMove?(:COUNTER) || 
                   target.pbHasMove?(:METALBURST) || 
                   target.pbHasMove?(:MIRRORCOAT)
                    score*=2
                end
                target2.allAllies.each do |barget|
                    if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0))
                        score*=1.5
                    end
                    if ((aspeed<pbRoughStat(barget,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0))
                        score*=1.5
                    end
                end
                score *= -1
            end
        end
    #---------------------------------------------------------------------------
    when "CannotBeRedirected" # Snipe Shot
        redirection = false
        user.allOpposing.each do |b|
            next if b.index == target.index
            if b.effects[PBEffects::RagePowder] ||
               b.effects[PBEffects::Spotlight] > 0 ||
               b.effects[PBEffects::FollowMe] > 0 ||
               (b.hasActiveAbility?(:SHOWTIME) && b.form == 1) ||
               (b.hasActiveAbility?(:LIGHTNINGROD) && move.pbCalcType(user) == :ELECTRIC) ||
               (b.hasActiveAbility?(:STORMDRAIN) && move.pbCalcType(user) == :WATER)
                redirection = true
                break
            end
        end
        score *= 1.5 if redirection && skill >= PBTrainerAI.mediumSkill
    #---------------------------------------------------------------------------
    when "RandomlyDamageOrHealTarget" # Present
        score = 0 if user.pbOwnedByPlayer?
    #---------------------------------------------------------------------------
    when "HealAllyOrDamageFoe" # pollen puff
        if user.opposes?(target) # is enemy
        else                     # is ally
            miniscore = -100.0 # heal pulse's score
            if target.hp>target.totalhp*0.3 && target.hp<target.totalhp*0.7
                miniscore*=3.0
            elsif target.hp*(1.0/target.totalhp)<0.3
                miniscore*=1.7
            end
            if target.poisoned? || target.burned? || target.frozen? || 
               target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse]
                miniscore*=0.8
                miniscore*=0.7 if target.effects[PBEffects::Toxic]>0
            end
            @battle.allOtherSideBattlers(user.index).each do |barget|
                if target.hp*(1.0/target.totalhp)>0.8
                    if !userFasterThanTarget && 
                      ((aspeed<pbRoughStat(barget,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0))
                        miniscore*=0.5
                    else
                        miniscore = 0
                    end
                end
            end
            if user.effects[PBEffects::HealBlock]>0 || target.effects[PBEffects::HealBlock]>0
                miniscore=0
            end
            #special circumstance
            score=miniscore
        end
    #---------------------------------------------------------------------------
    when "CurseTargetOrLowerUserSpd1RaiseUserAtkDef1" # curse
        bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
        maxdam=bestmove[0]
        if user.pbHasType?(:GHOST, true) && !$player.difficulty_mode?("chaos")
            if target.effects[PBEffects::Curse] || user.hp*2<user.totalhp
                score = 0
            else
                score*=0.7
                if !userFasterThanTarget
                    score*=0.5
                end
                if maxdam*5 < user.hp
                    score*=1.3
                end
                score*=1.2 if user.moves.any? { |m| m&.healingMove? }
                ministat=0
                ministat+=target.stages[:ATTACK] 
                ministat+=target.stages[:DEFENSE]
                ministat+=target.stages[:SPEED] 
                ministat+=target.stages[:SPECIAL_ATTACK] 
                ministat+=target.stages[:SPECIAL_DEFENSE]
                ministat*=(5)
                ministat+=100
                ministat/=100.0
                score*=ministat  
                if user.hasActiveAbility?([:ARENATRAP, :SHADOWTAG]) || target.effects[PBEffects::MeanLook]>=0 || 
                        @battle.pbAbleNonActiveCount(user.idxOpposingSide)==0
                    score*=1.3
                else
                    score*=0.8
                end
                hasAlly = !target.allAllies.empty?
                if hasAlly
                    score*=0.7
                end
            end
        else
            miniscore=100
            if user.effects[PBEffects::Substitute]>0 || (user.hasActiveAbility?(:DISGUISE) && user.form == 0)
                miniscore*=1.3
            end
            if (user.hp.to_f)/user.totalhp>0.75
                miniscore*=1.2
            end
            if (user.hp.to_f)/user.totalhp<0.33
                miniscore*=0.3
            end
            if (user.hp.to_f)/user.totalhp<0.75 && (user.hasActiveAbility?([:WIMPOUT, :EMERGENCYEXIT]) || user.hasActiveItem?(:EJECTBUTTON))
                miniscore*=0.3
            end
            if target.effects[PBEffects::HyperBeam]>0
                miniscore*=1.3
            end
            if target.effects[PBEffects::Yawn]>0
                miniscore*=1.7
            end
            # no need to recalc maxdam
            if maxdam<(user.hp/4.0)
                miniscore*=1.2
            end
            if maxdam>(user.hp/2.0)
                miniscore*=0.3
            end
            if user.turnCount<2
                miniscore*=1.1
            end
            if target.pbHasAnyStatus?
                miniscore*=1.2
            end
            if target.asleep?
                miniscore*=1.3
            end
            if target.effects[PBEffects::Encore]>0
                if GameData::Move.get(target.effects[PBEffects::EncoreMove]).base_damage==0        
                    miniscore*=1.5
                end          
            end  
            if user.effects[PBEffects::Confusion]>0
                miniscore*=0.3
            end
            if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
                miniscore*=0.3
            end
            if pbHasPhazingMove?(target)
                miniscore*=0.3
            end
            if user.hasActiveAbility?(:SIMPLE)
                miniscore*=2
            end
            if target.hasActiveAbility?(:UNAWARE,false,mold_broken)
                miniscore*=0.5
            end
            hasAlly = !target.allAllies.empty?
            if hasAlly
                miniscore*=0.7
            end
            if user.stages[:SPEED]<0
                ministat=user.stages[:SPEED]
                minimini=5*ministat
                minimini+=100
                minimini/=100.0
                miniscore*=minimini
            end
            ministat=0
            ministat+=target.stages[:ATTACK]
            ministat+=target.stages[:SPECIAL_ATTACK]
            ministat+=target.stages[:SPEED]
            if ministat>0
                minimini=(-5)*ministat
                minimini+=100
                minimini/=100.0
                miniscore*=minimini
            end
            miniscore*=1.3 if target.moves.any? { |m| m&.healingMove? }
            if userFasterThanTarget
                miniscore*=0.7
                if ospeed>(aspeed*(2.0/3.0))
                    miniscore*=0.5
                end
            else
                miniscore*=1.1
            end
            if user.burned? || user.frozen?
                miniscore*=0.5
            end
            if user.paralyzed?
                miniscore*=0.5
            end
            miniscore*=0.5 if target.moves.any? { |j| j&.id == :FOULPLAY }
            physmove = user.moves.any? { |j| j&.physicalMove?(j&.type) }
            if physmove && !user.statStageAtMax?(:ATTACK) 
                miniscore/=100.0
                score*=miniscore
            end
            miniscore=100
            if user.effects[PBEffects::Toxic]>0
                miniscore*=0.2
            end
            roles = pbGetPokemonRole(user, target)
            if pbRoughStat(target,:SPECIAL_ATTACK,skill)<pbRoughStat(target,:ATTACK,skill)
                if !(roles.include?("Physical Wall") || roles.include?("Special Wall"))
                    if userFasterThanTarget && (user.hp.to_f)/user.totalhp>0.75
                        miniscore*=1.3
                    elsif !userFasterThanTarget
                        miniscore*=0.7
                    end
                end
                miniscore*=1.3
            end
            if roles.include?("Physical Wall") || roles.include?("Special Wall")
                miniscore*=1.1
            end
            if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
                miniscore*=1.1
            end
            miniscore *= 1.2 if user.moves.any? { |m| m&.healingMove? }
            if user.pbHasMove?(:LEECHSEED)
                miniscore*=1.3
            end
            if user.pbHasMove?(:PAINSPLIT)
                miniscore*=1.2
            end 
            if targetWillMove?(target, "phys")
                if move.statusMove? && userFasterThanTarget && 
                   priorityAI(target,@battle.choices[target.index][2],globalArray)<1
                    miniscore*=1.2
                end
            end
            if !user.statStageAtMax?(:DEFENSE) 
                miniscore/=100.0
                score*=miniscore
            end
            if user.hasActiveAbility?(:CONTRARY)
                score=0
            end  
            if userFasterThanTarget        
                score*=0.7
            end
            score = 0 if user.statStageAtMax?(:DEFENSE) && user.statStageAtMax?(:ATTACK)
            score = 0 if $player.difficulty_mode?("chaos") && user.SetupMovesUsed.include?(move.id)
        end
    #---------------------------------------------------------------------------
    when "EffectDependsOnEnvironment" # Secret Power
    #---------------------------------------------------------------------------
    when "HitsAllFoesAndPowersUpInPsychicTerrain" # Expanding Force
          score *= 1.4 if expectedTerrain == :Psychic && user.affectedByTerrain?
    #---------------------------------------------------------------------------
    when "TargetNextFireMoveDamagesTarget" # powder
        if target.affectedByPowder?
            bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
            maxmove=bestmove[1]
            maxtype=maxmove.type
            if maxtype == :FIRE
                score*=3
            else
                if target.pbHasType?(:FIRE, true)
                    score*=2
                else
                    score*=0.7
                end
            end
            targetTypes = typesAI(target, user, skill)
            effcheck = Effectiveness.calculate(:FIRE, targetTypes[0], targetTypes[1], targetTypes[2])
            if effcheck>4
                score*=2
                if effcheck>16  # from 8 to 16 changed by JZ
                    score*=2
                end
            end
            if user.lastMoveUsed == :POWDER
                score*=0.6
            end        
            if !target.takesIndirectDamage?
                score=0
            end
            if target.moves.none? { |m| m.type == :FIRE }
                score=0
            else
                if targetWillMove?(target)
                    realtype = pbRoughType(@battle.choices[target.index][2], target, 100)
                    score*=1.5 if realtype == :FIRE
                end
            end   
        else
            score*=0
        end
    #---------------------------------------------------------------------------
    when "DoublePowerAfterFusionFlare" # Fusion Bolt
    #---------------------------------------------------------------------------
    when "DoublePowerAfterFusionBolt" # Fusion Flare
    #---------------------------------------------------------------------------
    when "PowerUpAllyMove" # helping hand
          hasAlly = !user.allAllies.empty?
        if hasAlly
            effvar = user.moves.any? { |move| pbCalcTypeMod(move.type, user, target) >= 8 }
            if !effvar
                score*=2
            end
            ministat = 0
            minimini = 0
            user.allAllies.each do |bally|
                target.allAllies.each do |barget|
                    if ((aspeed<ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)) && 
                            ((aspeed<pbRoughStat(barget,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0))
                        score*=1.2
                        if user.hp*(1.0/user.totalhp) < 0.33
                            score*=1.5
                        end
                        if pbRoughStat(bally,:SPEED,skill)<ospeed && 
                           pbRoughStat(bally,:SPEED,skill)<pbRoughStat(barget,:SPEED,skill)
                            score*=1.5
                        end
                    end
                end
                ministat = [bally.attack,bally.spatk].max
                minimini = [user.attack,user.spatk].max
                ministat -= minimini
                ministat+=100
                ministat/=100.0
            end
            score*=ministat
        else
            score *= 0.1
        end
    #---------------------------------------------------------------------------
    when "CounterPhysicalDamage" # Counter
        if user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY))
            score*=1.1
        end
        score*=0.6 if pbHasSetupMove?(target)
        miniscore = user.hp*(1.0/user.totalhp)
        score*=miniscore
        if target.spatk>target.attack
            score*=0.3
        end
        if user.lastRegularMoveUsed == :COUNTER
            score*=0.7
        end
        if user.lastRegularMoveUsed == :MIRRORCOAT
            score*=1.1
        end
        if targetWillMove?(target,"phys")
            if targetSurvivesMove(@battle.choices[target.index][2],target,user)
                score *= 1.3
            else
                score *= 0.1
            end
        else
            score *= 0.1
        end
    #---------------------------------------------------------------------------
    when "CounterSpecialDamage" # mirror coat
        if user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY))
            score*=1.1
        end
        score*=0.6 if pbHasSetupMove?(target)
        miniscore = user.hp*(1.0/user.totalhp)
        score*=miniscore
        if target.spatk<target.attack
            score*=0.3
        end
        if user.lastRegularMoveUsed == :COUNTER
            score*=1.1
        end
        if user.lastRegularMoveUsed == :MIRRORCOAT
            score*=0.7
        end
        if targetWillMove?(target,"spec")
            if targetSurvivesMove(@battle.choices[target.index][2],target,user)
                score *= 1.3
            else
                score *= 0.1
            end
        else
            score *= 0.1
        end
    #---------------------------------------------------------------------------
    when "CounterDamagePlusHalf" # Metal Burst
        score*=0.3 if userFasterThanTarget
        if user.hp==user.totalhp && (user.hasActiveItem?(:FOCUSSASH) || user.hasActiveAbility?(:STURDY))
            score*=1.1
        end
        if user.lastRegularMoveUsed == :METALBURST
            score*=0.7
        end
        score*=0.6 if pbHasSetupMove?(target)
        miniscore = user.hp*(1.0/user.totalhp)
        score*=miniscore
        if targetWillMove?(target, "dmg")
            if targetSurvivesMove(@battle.choices[target.index][2],target,user)
                score *= 1.2
            else
                score *= 0.1
            end
        else
            score *= 0.1
        end
    #---------------------------------------------------------------------------
    when "UserAddStockpileRaiseDefSpDef1" # stockpile
        if !user.SetupMovesUsed.include?(move.id)
            miniscore=100
            if (user.hasActiveAbility?(:DISGUISE) && user.form == 0) || user.effects[PBEffects::Substitute]>0
                miniscore*=1.3
            end
            if (user.hp.to_f)/user.totalhp>0.75
                miniscore*=1.1
            end
            if target.effects[PBEffects::HyperBeam]>0
                miniscore*=1.2
            end
            if target.effects[PBEffects::Yawn]>0
                miniscore*=1.3
            end
            bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
            maxdam = bestmove[0]
            if maxdam<(user.hp/4.0)
                miniscore*=1.1
            else
                if move.baseDamage==0 
                    miniscore*=0.8
                    if maxdam>user.hp
                        miniscore*=0.1
                    end
                end
            end
            if user.turnCount<2
                miniscore*=1.1
            end
            if target.pbHasAnyStatus?
                miniscore*=1.1
            end
            if target.asleep?
                miniscore*=1.3
            end
            if target.effects[PBEffects::Encore]>0
                if GameData::Move.get(target.effects[PBEffects::EncoreMove]).base_damage==0
                    miniscore*=1.5
                end          
            end  
            if user.effects[PBEffects::Confusion]>0
                miniscore*=0.5
            end
            if user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Attract]>=0
                miniscore*=0.3
            end
            if user.effects[PBEffects::Toxic]>0
                miniscore*=0.2
            end
            if pbHasPhazingMove?(target)
                miniscore*=0.2
            end   
            if user.hasActiveAbility?(:SIMPLE)
                miniscore*=2
            end
            if target.hasActiveAbility?(:UNAWARE)
                miniscore*=0.5
            end
            hasAlly = !target.allAllies.empty?
            if hasAlly
                miniscore*=0.5
            end
            # no need to recalc maxdam
            if (maxdam.to_f/user.hp)<0.12
                miniscore*=0.3
            end
            roles = pbGetPokemonRole(user, target)
            if roles.include?("Physical Wall") || roles.include?("Special Wall")
                miniscore*=1.5
            end   
            if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
                miniscore*=1.2
            end
            if user.moves.any? { |m| m&.healingMove? }
                miniscore*=1.7
            end
            if user.pbHasMove?(:LEECHSEED)
                miniscore*=1.3
            end
            if user.pbHasMove?(:PAINSPLIT)
                miniscore*=1.2
            end
            if targetWillMove?(target, "dmg")
                if move.statusMove? && userFasterThanTarget && 
                   priorityAI(target,@battle.choices[target.index][2],globalArray)<1
                    miniscore*=1.2
                end
            end
            miniscore/=100.0
            score*=miniscore
            score=0 if user.hasActiveAbility?(:CONTRARY)
            score=0 if user.statStageAtMax?(:SPECIAL_DEFENSE) && user.statStageAtMax?(:DEFENSE)
        end
        if user.effects[PBEffects::Stockpile]<3
            if user.pbHasMoveFunction?("PowerDependsOnUserStockpile","HealUserDependingOnUserStockpile") 
                score*=1.6
                bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
                maxdam = bestmove[0]
                score*=1.2 if maxdam*1.2 < user.hp
                if target.allAllies.empty? && @battle.choices[target.index][0] == :SwitchOut
                    score*=1.5
                end
            end
        else
            score=0
        end
    #---------------------------------------------------------------------------
    when "PowerDependsOnUserStockpile" # split up
        if user.effects[PBEffects::Stockpile]==0
            score=0
        else
            score*=0.8
            roles = pbGetPokemonRole(user, target)
            if roles.include?("Physical Wall") || roles.include?("Special Wall")
                score*=0.7
            end
            if roles.include?("Tank")
                score*=0.9
            end
            count=0
            for m in user.moves
                count+=1 if m.baseDamage>0
            end
            if count>1
                score*=0.5
            end
            if @battle.pbAbleNonActiveCount(user.idxOpposingSide)==0
                score*=0.7
            else
                score*=1.2
            end
            if targetSurvivesMove(move,user,target)
                score*=0.5
            else
                score*=1.3
            end
            if !userFasterThanTarget
                score*=1.1
            else
                score*=0.8
            end
            if user.pbHasMoveFunction?("HealUserDependingOnUserStockpile")
                if user.hp/(user.totalhp).to_f < 0.66
                    score*=0.8
                    if user.hp/(user.totalhp).to_f < 0.4
                        score*=0.5
                    end
                end
            end
        end
    #---------------------------------------------------------------------------
    when "HealUserDependingOnUserStockpile" # swallow
        if user.effects[PBEffects::Stockpile]==0
            score=0
        else
            movecheck = pbHasSetupMove?(target)
            bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
            maxdam = bestmove[0]
            score *= (1.1 + (user.effects[PBEffects::Stockpile]/10))
            score *= 0.8 if !user.hasActiveAbility?(:ACCUMULATOR)
            roles = pbGetPokemonRole(user, target)
            if roles.include?("Physical Wall") || roles.include?("Special Wall")
                score*=0.9
            end
            if roles.include?("Tank")
                score*=0.9
            end
            if !userFasterThanTarget
                score*=1.1
            else
                score*=0.8
            end
            if maxdam>user.hp
                score*=2
            else
                if maxdam*1.5 > user.hp
                    score*=1.5
                end
                if !userFasterThanTarget
                    if maxdam*2 > user.hp
                        score*=2
                    else
                        score*=0.2
                    end
                end
            end
            if movecheck
                score*=0.7
            end
            if user.hp*2 < user.totalhp
                score*=1.5
            end
            if user.poisoned? || user.burned? || user.frozen? || user.effects[PBEffects::LeechSeed]>=0 || user.effects[PBEffects::Curse]
                score*=1.3
                if user.effects[PBEffects::Toxic]>0
                    score*=1.3
                end
            end
            if target.effects[PBEffects::HyperBeam]>0
                score*=1.2
            end
            if user.hp/(user.totalhp).to_f > 0.8
                score=0
            end
        end
    #---------------------------------------------------------------------------
    when "GrassPledge", "FirePledge", "WaterPledge" # Grass Pledge, Fire Pledge, Water Pledge
        # janky, and probably not very effective. Better than nothing i guess?
        if !user.allAllies.empty?
            if user.pbOpposingSide.effects[PBEffects::SeaOfFire] == 0 &&
               user.pbOpposingSide.effects[PBEffects::Swamp] == 0 &&
               user.pbOwnSide.effects[PBEffects::Rainbow] == 0
                userAlly = user.allAllies.first
                if userAlly.moves.any? { |m| ["GrassPledge", "FirePledge", "WaterPledge"].include?(m&.function) }
                    score *= 1.5
                end
            end
        end
    #---------------------------------------------------------------------------
    when "UseLastMoveUsed" # copycat
        if userFasterThanTarget || priorityAI(user, move, globalArray) > 0
            if !target.lastRegularMoveUsed.nil? && target.effects[PBEffects::Substitute]<=0
                copymove = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(target.lastRegularMoveUsed))
                score = pbGetMoveScore(copymove, user, target, skill)
            else
                score=0
            end
        else
            if targetWillMove?(target) && target.effects[PBEffects::Substitute]<=0
                copymove = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(@battle.choices[target.index][2].id))
                score = pbGetMoveScore(copymove, user, target, skill)
            else
                score=0
            end
        end
    #---------------------------------------------------------------------------
    when "UseLastMoveUsedByTarget" # Mirror Move
        if userFasterThanTarget || priorityAI(user, move, globalArray) > 0
            if !target.lastRegularMoveUsed.nil?
                if GameData::Move.get(target.lastRegularMoveUsed).flags.none? { |f| f[/^CanMirrorMove$/i] }
                    score = 0
                else
                    mirrmove = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(target.lastRegularMoveUsed))
                    score = pbGetMoveScore(mirrmove, user, target, skill)
                end
            else
                score=0
            end
        else
            if targetWillMove?(target)
                targetMove = @battle.choices[target.index][2]
                if GameData::Move.get(targetMove.id).flags.none? { |f| f[/^CanMirrorMove$/i] }
                    score = 0
                else
                    mirrmove = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(targetMove.id))
                    score = pbGetMoveScore(mirrmove, user, target, skill)
                end
            else
                score=0
            end
        end
    #---------------------------------------------------------------------------
    when "UseMoveTargetIsAboutToUse" # Me First
        userPrio = priorityAI(user, move, globalArray)
        if userFasterThanTarget || userPrio > 0
            if targetWillMove?(target, "dmg")
                targetMove = @battle.choices[target.index][2]
                if priorityAI(target,targetMove,globalArray) > userPrio
                    score = 0
                else
                    memove = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(targetMove.id))
                    user.effects[PBEffects::MeFirst] = true
                    score = pbGetMoveScore(memove, user, target, skill)
                    user.effects[PBEffects::MeFirst] = false
                end
            else
                score = 0
            end
        else
            score = 0
        end
    #---------------------------------------------------------------------------
    when "UseMoveDependingOnEnvironment" # nature power
        newmove = :TRIATTACK
        case expectedTerrain
        when :Electric
            newmove = :THUNDERBOLT if GameData::Move.exists?(:THUNDERBOLT)
        when :Grassy
            newmove = :ENERGYBALL if GameData::Move.exists?(:ENERGYBALL)
        when :Misty
            newmove = :MOONBLAST if GameData::Move.exists?(:MOONBLAST)
        when :Psychic
            newmove = :PSYCHIC if GameData::Move.exists?(:PSYCHIC)
        else
            case @battle.environment
            when :Grass, :TallGrass, :Forest, :ForestGrass
                newmove = (Settings::MECHANICS_GENERATION >= 6) ? :ENERGYBALL : :SEEDBOMB
            when :MovingWater, :StillWater, :Underwater
                newmove = :HYDROPUMP
            when :Puddle
                newmove = :MUDBOMB
            when :Cave
                newmove = (Settings::MECHANICS_GENERATION >= 6) ? :POWERGEM : :ROCKSLIDE
            when :Rock, :Sand
                newmove = (Settings::MECHANICS_GENERATION >= 6) ? :EARTHPOWER : :EARTHQUAKE
            when :Snow
                newmove = :BLIZZARD
                newmove = :FROSTBREATH if Settings::MECHANICS_GENERATION == 6
                newmove = :ICEBEAM if Settings::MECHANICS_GENERATION >= 7
            when :Ice
                newmove = :ICEBEAM
            when :Volcano
                newmove = :LAVAPLUME
            when :Graveyard
                newmove = :SHADOWBALL
            when :Sky
                newmove = :AIRSLASH
            when :Space
                newmove = :DRACOMETEOR
            when :UltraSpace
                newmove = :PSYSHOCK
            end
        end
        naturemove = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(newmove))
        score = pbGetMoveScore(naturemove, user, target, skill)
    #---------------------------------------------------------------------------
    when "UseRandomMove" # metronome
        if $AIMASTERLOG
            File.open("AI_master_log.txt", "a") do |line|
                line.puts "-------Metronome Start--------"
            end
        end
        moveBlacklist = [
            "FlinchTargetFailsIfUserNotAsleep","TargetActsNext","TargetActsLast",
            "TargetUsesItsLastUsedMoveAgain","Struggle","FailsIfUserNotConsumedBerry",
            "ReplaceMoveThisBattleWithTargetLastMoveUsed","ReplaceMoveWithTargetLastMoveUsed",
            "TransformUserIntoTarget","CounterPhysicalDamage","CounterSpecialDamage","CounterDamagePlusHalf",
            "PowerUpAllyMove","RemoveProtections","ProtectUser","ProtectUserSideFromPriorityMoves",
            "ProtectUserSideFromMultiTargetDamagingMoves","UserEnduresFaintingThisTurn",
            "ProtectUserSideFromDamagingMovesIfUserFirstTurn","ProtectUserSideFromStatusMoves",
            "ProtectUserFromDamagingMovesKingsShield","ProtectUserFromDamagingMovesObstruct",
            "ProtectUserFromTargetingMovesSpikyShield","ProtectUserBanefulBunker","UseLastMoveUsedByTarget",
            "UseLastMoveUsed","UseMoveTargetIsAboutToUse","UseMoveDependingOnEnvironment",
            "UseRandomUserMoveIfAsleep","UseRandomMoveFromUserParty","UseRandomMove",
            "BounceBackProblemCausingStatusMoves","StealAndUseBeneficialStatusMove","RedirectAllMovesToUser",
            "RedirectAllMovesToTarget","ReduceAttackerMovePPTo0IfUserFaints","AttackerFaintsIfUserFaints",
            "UserTakesTargetItem","UserTargetSwapItems","TargetTakesUserItem","FailsIfUserDamagedThisTurn",
            "UsedAfterUserTakesPhysicalDamage","BurnAttackerBeforeUserActs","DoesNothingFailsIfNoAlly",
            "DoesNothingCongratulations"
        ]
        metronomeMove = []
        move_keys = GameData::Move.keys
        while metronomeMove.length < 10
            move_id = move_keys[rand(move_keys.length)] # rand instead of pbRandom intentionally
            move_data = GameData::Move.get(move_id)
            next if moveBlacklist.include?(move_data.function_code)
            next if move_data.has_flag?("CannotMetronome")
            next if move_data.type == :SHADOW
            next if user.SetupMovesUsed.include?(move_data.id)
            metroMov = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(move_data.id))
            metroScore = pbGetMoveScore(metroMov, user, target, skill)
            next if metroScore <= 1
            metroScore *= 0.75 if metroMov.chargingTurnMove? && !user.hasActiveItem?(:POWERHERB)
            metronomeMove.push([move_data.id, metroScore])
        end
        if metronomeMove.length > 0
            metronomeMove.sort! { |a, b| b[1] <=> a[1] }
            user.prepickedMove = metronomeMove[0][0]
            echo("\n~~~~Metro Move will be #{user.prepickedMove.name.to_s}") if $AIGENERALLOG
            if $AIMASTERLOG
                File.open("AI_master_log.txt", "a") do |line|
                    line.puts "~~~~Metronome Move will be " + user.prepickedMove.name.to_s
                end
            end
            score = metronomeMove[0][1]
        else
            score=0
        end
        if $AIMASTERLOG
            File.open("AI_master_log.txt", "a") do |line|
                line.puts "-------Metronome End----------"
            end
        end
    #---------------------------------------------------------------------------
    when "UseRandomMoveFromUserParty" # assist
        if @battle.pbAbleNonActiveCount(user.idxOwnSide) > 0
            if $AIMASTERLOG
                File.open("AI_master_log.txt", "a") do |line|
                    line.puts "-------Assist Start--------"
                end
            end
            moveBlacklist = [
                "AllBattlersLoseHalfHPUserSkipsNextTurn", "AttackerFaintsIfUserFaints", "BounceBackProblemCausingStatusMoves",
                "BurnAttackerBeforeUserActs", "CounterDamagePlusHalf", "CounterPhysicalDamage", "CounterSpecialDamage",
                "DoesNothingCongratulations", "DoesNothingFailsIfNoAlly", "FailsIfUserDamagedThisTurn",
                "FailsIfUserNotConsumedBerry", "PowerUpAllyMove", "ProtectUser", "ProtectUserBanefulBunker",
                "ProtectUserFromDamagingMovesKingsShield", "ProtectUserFromTargetingMovesSpikyShield",
                "ProtectUserSideFromDamagingMovesIfUserFirstTurn", "ProtectUserSideFromMultiTargetDamagingMoves",
                "ProtectUserSideFromPriorityMoves", "ProtectUserSideFromStatusMoves", "ReduceAttackerMovePPTo0IfUserFaints",
                "RedirectAllMovesToTarget", "RedirectAllMovesToUser", "RemoveProtections", "ReplaceMoveThisBattleWithTargetLastMoveUsed",
                "ReplaceMoveWithTargetLastMoveUsed", "StealAndUseBeneficialStatusMove", "SwitchOutTargetDamagingMove",
                "SwitchOutTargetStatusMove", "TargetTakesUserItem", "TransformUserIntoTarget", "TwoTurnAttack",
                "TwoTurnAttackBurnTarget", "TwoTurnAttackChargeRaiseUserDefense1", "TwoTurnAttackFlinchTarget",
                "TwoTurnAttackInvulnerableInSky", "TwoTurnAttackInvulnerableInSkyParalyzeTarget",
                "TwoTurnAttackInvulnerableInSkyTargetCannotAct", "TwoTurnAttackInvulnerableRemoveProtections",
                "TwoTurnAttackInvulnerableUnderground", "TwoTurnAttackInvulnerableUnderwater",
                "TwoTurnAttackOneTurnInSun", "TwoTurnAttackParalyzeTarget", "TwoTurnAttackRaiseUserSpAtkSpDefSpd2",
                "UseLastMoveUsed", "UseLastMoveUsedByTarget", "UseMoveDependingOnEnvironment", "UseMoveTargetIsAboutToUse",
                "UseRandomMove", "UseRandomMoveFromUserParty", "UseRandomUserMoveIfAsleep", "UserEnduresFaintingThisTurn",
                "UserTakesTargetItem", "UserTargetSwapItems", "ProtectUserFromDamagingMovesObstruct"
            ]
            assistMoves = []
            @battle.pbParty(user.index).each_with_index do |pkmn, i|
                next if !pkmn || i == user.pokemonIndex
                next if Settings::MECHANICS_GENERATION >= 6 && pkmn.egg?
                pkmn.moves.each do |move|
                    next if moveBlacklist.include?(move.function_code)
                    next if move.type == :SHADOW
                    assMov = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(move.id))
                    assSco = pbGetMoveScore(assMov, user, target, skill)
                    next if assSco <= 1
                    assistMoves.push([move.id, assSco])
                end
            end
            if assistMoves.length > 0
                if true
                    assistMoves.sort! { |a, b| b[1] <=> a[1] }
                    user.prepickedMove = assistMoves[0][0]
                    echo("\n~~~~*Assist Move will be #{user.prepickedMove.name.to_s}") if $AIGENERALLOG
                    score = assistMoves[0][1]
                else
                    newmove = assistMoves[@battle.pbRandom(assistMoves.length)]
                    if newmove
                        user.prepickedMove = newmove[0]
                        echo("\n~~~~Assist Move will be #{user.prepickedMove.name.to_s}") if $AIGENERALLOG
                        score = newmove[1]
                    end
                end
                if $AIMASTERLOG
                    File.open("AI_master_log.txt", "a") do |line|
                        line.puts "~~~~Assist Move will be " + user.prepickedMove.name.to_s
                    end
                end
            else
                score=0
            end
            if $AIMASTERLOG
                File.open("AI_master_log.txt", "a") do |line|
                    line.puts "-------Assist End----------"
                end
            end
        else
            score=0
        end
    #---------------------------------------------------------------------------
    when "UseRandomUserMoveIfAsleep" # sleep talk
        if user.asleep?
            if user.statusCount <= 1
                score = 0
            else
                if $AIMASTERLOG
                    File.open("AI_master_log.txt", "a") do |line|
                        line.puts "-------Sleep Talk Start--------"
                    end
                end
                moveBlacklist = [
                    "MultiTurnAttackPreventSleeping", "MultiTurnAttackBideThenReturnDoubleDamage", "Struggle", 
                    "FailsIfUserNotConsumedBerry", "ReplaceMoveThisBattleWithTargetLastMoveUsed", 
                    "ReplaceMoveWithTargetLastMoveUsed", "UseLastMoveUsedByTarget", "UseLastMoveUsed", 
                    "UseMoveTargetIsAboutToUse", "UseMoveDependingOnEnvironment", "UseRandomUserMoveIfAsleep", 
                    "UseRandomMoveFromUserParty", "UseRandomMove", "TwoTurnAttack", "TwoTurnAttackOneTurnInSun", 
                    "TwoTurnAttackParalyzeTarget", "TwoTurnAttackBurnTarget", "TwoTurnAttackFlinchTarget", 
                    "TwoTurnAttackChargeRaiseUserDefense1", "TwoTurnAttackInvulnerableInSky", 
                    "TwoTurnAttackInvulnerableUnderground", "TwoTurnAttackInvulnerableUnderwater", 
                    "TwoTurnAttackInvulnerableInSkyParalyzeTarget", "TwoTurnAttackInvulnerableRemoveProtections", 
                    "TwoTurnAttackInvulnerableInSkyTargetCannotAct", "AllBattlersLoseHalfHPUserSkipsNextTurn", 
                    "TwoTurnAttackRaiseUserSpAtkSpDefSpd2", "FailsIfUserDamagedThisTurn", 
                    "UsedAfterUserTakesPhysicalDamage", "BurnAttackerBeforeUserActs"
                ]
                sleepTalkMoves = []
                user.eachMoveWithIndex do |m, i|
                    next if moveBlacklist.include?(m.function)
                    next if !@battle.pbCanChooseMove?(user.index, i, false, true)
                    slepSco = pbGetMoveScore(m, user, target, skill)
                    next if slepSco <= 1
                    sleepTalkMoves.push([m.id, slepSco])
                end
                if sleepTalkMoves.length > 0
                    if true
                        sleepTalkMoves.sort! { |a, b| b[1] <=> a[1] }
                        user.prepickedMove = sleepTalkMoves[0][0]
                        echo("\n~~~~*Sleep Talk Move will be #{user.prepickedMove.name.to_s}") if $AIGENERALLOG
                        score = sleepTalkMoves[0][1]
                    else
                        newmove = sleepTalkMoves[@battle.pbRandom(sleepTalkMoves.length)]
                        if newmove
                            user.prepickedMove = newmove[0]
                            echo("\n~~~~Sleep Talk Move will be #{user.prepickedMove.name.to_s}") if $AIGENERALLOG
                            score = newmove[1]
                        end
                    end
                    if $AIMASTERLOG
                        File.open("AI_master_log.txt", "a") do |line|
                            line.puts "~~~~Sleep Talk Move will be " + user.prepickedMove.name.to_s
                        end
                    end
                else
                    score=0
                end
                if $AIMASTERLOG
                    File.open("AI_master_log.txt", "a") do |line|
                        line.puts "-------Sleep Talk End----------"
                    end
                end
            end
        else
            score = 0
        end
    #---------------------------------------------------------------------------
    when "BounceBackProblemCausingStatusMoves" # magic coat
        if targetWillMove?(target, "status")
            if @battle.choices[target.index][2].canMagicCoat?
                score *= 5.0
                score *= 1.5 if user.hp==user.totalhp
                score *= 1.2 if target.moves.any? { |j| j&.baseDamage>0 }
            else
                score *= 0.2
            end
        else
            score *= 0.8 if user.lastMoveUsed == :MAGICCOAT
            score *= 0.2
        end
    #---------------------------------------------------------------------------
    when "StealAndUseBeneficialStatusMove" # snatch
        if targetWillMove?(target, "status")
            if @battle.choices[target.index][2].canSnatch?
                score *= 5.0
                score *= 1.2 if target.hp==target.totalhp
                score *= 1.5 if pbHasSetupMove?(target)
                if target.attack>target.spatk
                    score*=1.2 if user.attack>user.spatk
                else
                    score*=1.2 if user.spatk>user.attack
                end
            else
                score *= 0.2
            end
        else
            score *= 0.8 if user.lastMoveUsed == :SNATCH
            score *= 0.2
        end
    #---------------------------------------------------------------------------
    when "ReplaceMoveThisBattleWithTargetLastMoveUsed", "ReplaceMoveWithTargetLastMoveUsed" # Mimic, Sketch
        moveBlacklist = [
            "Struggle",   # Struggle
            "ReplaceMoveWithTargetLastMoveUsed"   # Sketch
        ]
        if move.function == "ReplaceMoveThisBattleWithTargetLastMoveUsed"
            moveBlacklist.push(
                "ReplaceMoveThisBattleWithTargetLastMoveUsed",   # Mimic
                "UseRandomMove"   # Metronome
            )
        end
        if user.effects[PBEffects::Transform] || target.effects[PBEffects::Substitute] > 0
            score = 0
        else
            lastmove = nil
            if userFasterThanTarget || priorityAI(user, move, globalArray) > 0
                if !target.lastRegularMoveUsed.nil?
                    lastmove = target.pbGetMoveWithID(target.lastRegularMoveUsed)
                end
            else
                if targetWillMove?(target)
                    lastmove = @battle.choices[target.index][2]
                end
            end
            if lastmove.nil?
                score = 0
            else
                user.eachMove do |m|
                    next unless m.id == lastmove.id
                    score = 0
                    break
                end
                copymove = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(lastmove))
                score = 0 if moveBlacklist.include?(copymove.function)
                if score > 0
                    score = pbGetMoveScore(copymove, user, target, skill)
                    if score > 110
                        score *= 0.8 + ((score - 80) / 100.0)
                    else
                        score *= score / 100.0
                    end
                end
            end
        end
    #---------------------------------------------------------------------------
    when "FleeFromBattle" # teleport
        if @battle.trainerBattle?
              score = 0
        else
            score = 999
        end
    #---------------------------------------------------------------------------
    when "SwitchOutUserStatusMove" # teleport
        #target=user.pbDirectOpposing(true)
        userlivecount = @battle.pbAbleNonActiveCount(user.idxOwnSide)
        if userlivecount>1
            score *= 0.8 if userFasterThanTarget && !(target.status == :SLEEP && target.statusCount>1)
            score *= 0.7 if user.pbOwnSide.effects[PBEffects::StealthRock]
            score *= (0.9**user.pbOwnSide.effects[PBEffects::ToxicSpikes])
            score *= (0.9**user.pbOwnSide.effects[PBEffects::Spikes])
            score *= 0.6 if user.pbOwnSide.effects[PBEffects::StickyWeb]>0

            score *= 1.3 if user.effects[PBEffects::Toxic]>3
            score *= 1.3 if user.effects[PBEffects::Curse]
            score *= 1.3 if user.effects[PBEffects::PerishSong]==1
            score *= 1.3 if user.effects[PBEffects::LeechSeed]>0
            score *= 1.3 if target.status == :SLEEP && target.statusCount>1
            score *= 1.3 if user.trappedInBattle?
            score *= 1.3 if @battle.choices[target.index][0] == :SwitchOut
            if user.hasActiveAbility?(:REGENERATOR) && ((user.hp.to_f)/user.totalhp)<0.75
                score*=1.2
                if user.hasActiveAbility?(:REGENERATOR) && ((user.hp.to_f)/user.totalhp)<0.5
                    score*=1.2
                end
            end
            if user.effects[PBEffects::Wish]>0
                currentHPPercent = (user.hp * 100.0 / user.totalhp)
                roles = pbGetPokemonRole(user, target)
                score*=1.2 if ["Cleric", "Pivot"].any? { |r| roles.include?(r) } && currentHPPercent >= 60
                score*=1.3 if currentHPPercent >= 70
            end
            bestmove=bestMoveVsTarget(user,target,skill) # [maxdam,maxmove,maxprio,physorspec]
            maxdam = bestmove[0]
            if maxdam*4<target.totalhp
                if userFasterThanTarget
                    besttargetmove=bestMoveVsTarget(target,user,skill)
                    maxtargetmove = bestmove[1]
                    if targetSurvivesMove(maxtargetmove,target,user)
                        score*=1.2
                    else
                        score*=0.7
                    end
                else
                    score*=2
                end
            end
            score*=2 if @battle.choices[target.index][0] == :SwitchOut
        end
        score = 999 if @battle.wildBattle?
    #---------------------------------------------------------------------------
    when "SwitchOutUserDamagingMove" # u-turn
        userlivecount = @battle.pbAbleNonActiveCount(user.idxOwnSide)
         if userlivecount>1
            if userFasterThanTarget && !(target.status == :SLEEP && target.statusCount>1)
                score *= 0.8
                # DemICE: Switching AI is dumb so if you're faster, don't sack a healthy mon. Better use another move.
                # increased 0.3 to 0.8 since the switching AI is buffed
            end
            if user.pbOwnSide.effects[PBEffects::StealthRock]
                score*=0.7
            end
            if user.pbOwnSide.effects[PBEffects::StickyWeb]>0
                score*=0.6
            end
            if user.pbOwnSide.effects[PBEffects::Spikes]>0
                score*=0.9**user.pbOwnSide.effects[PBEffects::Spikes]
            end
            if user.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
                score*=0.9**user.pbOwnSide.effects[PBEffects::ToxicSpikes]
            end
            count = -1
            sweepvar = false
            @battle.pbParty(user.index).each do |i|
                next if i.nil?
                count+=1
                temproles = pbGetPokemonRole(i, target, count, @battle.pbParty(user.index))
                if temproles.include?("Sweeper")
                    sweepvar = true
                end
            end  
            if userFasterThanTarget
                score*=1.2
            else
                if sweepvar
                    score*=1.2
                end
            end
            if user.hasActiveAbility?(:REGENERATOR) && ((user.hp.to_f)/user.totalhp)<0.75
                score*=1.2
                if user.hasActiveAbility?(:REGENERATOR) && ((user.hp.to_f)/user.totalhp)<0.5
                    score*=1.2
                end
            end
            loweredstats=0
            loweredstats+=user.stages[:ATTACK] if user.stages[:ATTACK]<0
            loweredstats+=user.stages[:DEFENSE] if user.stages[:DEFENSE]<0
            loweredstats+=user.stages[:SPEED] if user.stages[:SPEED]<0
            loweredstats+=user.stages[:SPECIAL_ATTACK] if user.stages[:SPECIAL_ATTACK]<0
            loweredstats+=user.stages[:SPECIAL_DEFENSE] if user.stages[:SPECIAL_DEFENSE]<0
            loweredstats+=user.stages[:EVASION] if user.stages[:EVASION]<0
            miniscore= (-15)*loweredstats    
            miniscore+=100
            miniscore/=100.0
            score*=miniscore
            raisedstats=0
            raisedstats+=user.stages[:ATTACK] if user.stages[:ATTACK]>0
            raisedstats+=user.stages[:DEFENSE] if user.stages[:DEFENSE]>0
            raisedstats+=user.stages[:SPEED] if user.stages[:SPEED]>0
            raisedstats+=user.stages[:SPECIAL_ATTACK] if user.stages[:SPECIAL_ATTACK]>0
            raisedstats+=user.stages[:SPECIAL_DEFENSE] if user.stages[:SPECIAL_DEFENSE]>0
            raisedstats+=user.stages[:EVASION] if user.stages[:EVASION]>0
            miniscore= (-25)*raisedstats
            miniscore+=100
            miniscore/=100.0
            score*=miniscore    
            if user.effects[PBEffects::Toxic]>0 || user.effects[PBEffects::Attract]>-1 || user.effects[PBEffects::Confusion]>0
                score*=1.3
            end
            if user.effects[PBEffects::LeechSeed]>-1
                score*=1.5
            end
            if user.effects[PBEffects::Wish]>0
                currentHPPercent = (user.hp * 100.0 / user.totalhp)
                roles = pbGetPokemonRole(user, target)
                score*=1.2 if ["Cleric", "Pivot"].any? { |r| roles.include?(r) } && currentHPPercent >= 60
                score*=1.3 if currentHPPercent >= 70
            end
            bestmove=bestMoveVsTarget(user,target,skill) # [maxdam,maxmove,maxprio,physorspec]
            maxdam = bestmove[0]
            if maxdam*3<target.totalhp
                if userFasterThanTarget
                    score*=2
                else
                    besttargetmove=bestMoveVsTarget(target,user,skill)
                    maxtargetmove = bestmove[1]
                    if targetSurvivesMove(maxtargetmove,target,user)
                        score*=1.2
                    else
                        score*=0.7
                    end
                end
            end
            score*=2 if @battle.choices[target.index][0] == :SwitchOut
        end
    #---------------------------------------------------------------------------
    when "LowerTargetAtkSpAtk1SwitchOutUser" # Parting Shot
        if !target.pbCanLowerStatStage?(:ATTACK) && !target.pbCanLowerStatStage?(:SPECIAL_ATTACK)
            score=0
        else
            if @battle.pbAbleNonActiveCount(user.idxOwnSide)>0
                if user.pbOwnSide.effects[PBEffects::StealthRock]
                    score*=0.7
                end
                if user.pbOwnSide.effects[PBEffects::StickyWeb]>0
                    score*=0.6
                end
                if user.pbOwnSide.effects[PBEffects::Spikes]>0
                    score*=0.9**user.pbOwnSide.effects[PBEffects::Spikes]
                end
                if user.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
                    score*=0.9**user.pbOwnSide.effects[PBEffects::ToxicSpikes]
                end 
                if user.hasActiveAbility?(:REGENERATOR) && ((user.hp.to_f)/user.totalhp)<0.75
                    score*=1.2
                    if user.hasActiveAbility?(:REGENERATOR) && ((user.hp.to_f)/user.totalhp)<0.5
                        score*=1.2
                    end
                end
                if userFasterThanTarget
                    score*=1.1
                end
                sweepvar = false
                count=0
                @battle.pbParty(user.index).each do |i|
                    next if i.nil?
                    count+=1
                    temproles = pbGetPokemonRole(i, target, count, @battle.pbParty(user.index))
                    if temproles.include?("Sweeper")
                        sweepvar = true
                    end
                end
                if sweepvar 
                    score*=1.5
                end
                roles = pbGetPokemonRole(user, target)
                if roles.include?("Lead")
                    score*=1.1
                end
                if roles.include?("Pivot")
                    score*=1.2
                end
                loweredstats=0
                loweredstats+=user.stages[:ATTACK] if user.stages[:ATTACK]<0
                loweredstats+=user.stages[:DEFENSE] if user.stages[:DEFENSE]<0
                loweredstats+=user.stages[:SPEED] if user.stages[:SPEED]<0
                loweredstats+=user.stages[:SPECIAL_ATTACK] if user.stages[:SPECIAL_ATTACK]<0
                loweredstats+=user.stages[:SPECIAL_DEFENSE] if user.stages[:SPECIAL_DEFENSE]<0
                loweredstats+=user.stages[:EVASION] if user.stages[:EVASION]<0
                miniscore= (5)*loweredstats    
                miniscore+=100
                miniscore/=100.0
                score*=miniscore      
                raisedstats=0
                raisedstats+=user.stages[:ATTACK] if user.stages[:ATTACK]>0
                raisedstats+=user.stages[:DEFENSE] if user.stages[:DEFENSE]>0
                raisedstats+=user.stages[:SPEED] if user.stages[:SPEED]>0
                raisedstats+=user.stages[:SPECIAL_ATTACK] if user.stages[:SPECIAL_ATTACK]>0
                raisedstats+=user.stages[:SPECIAL_DEFENSE] if user.stages[:SPECIAL_DEFENSE]>0
                raisedstats+=user.stages[:ACCURACY] if user.stages[:ACCURACY]>0
                miniscore= (-5)*raisedstats
                miniscore+=100
                miniscore/=100.0
                score*=miniscore    
                if user.effects[PBEffects::Toxic]>0 || user.effects[PBEffects::Attract]>-1 || user.effects[PBEffects::Confusion]>0
                    score*=1.3
                end
                if user.effects[PBEffects::LeechSeed]>-1
                    score*=1.5
                end   
                miniscore=130
                if user.hasActiveAbility?([:ARENATRAP, :SHADOWTAG]) || target.effects[PBEffects::MeanLook]>=0 || 
                        @battle.pbAbleNonActiveCount(user.idxOpposingSide)==0
                    miniscore*=1.4
                end
                if user.effects[PBEffects::Wish]>0
                    currentHPPercent = (user.hp * 100.0 / user.totalhp)
                    roles = pbGetPokemonRole(user, target)
                    score*=1.2 if ["Cleric", "Pivot"].any? { |r| roles.include?(r) } && currentHPPercent >= 60
                    miniscore*=1.3 if currentHPPercent >= 70
                end
                bestmove=bestMoveVsTarget(user,target,skill) # [maxdam,maxmove,maxprio,physorspec]
                maxdam = bestmove[0]
                if maxdam*3<target.totalhp
                    if userFasterThanTarget
                        miniscore*=2
                    else
                        besttargetmove=bestMoveVsTarget(target,user,skill)
                        maxtargetmove = bestmove[1]
                        if targetSurvivesMove(maxtargetmove,target,user)
                            miniscore*=1.2
                        else
                            miniscore*=0.7
                        end
                    end
                end
                score*=2 if @battle.choices[target.index][0] == :SwitchOut
                ministat=0          
                ministat+=target.stages[:ATTACK] if target.stages[:ATTACK]<0
                ministat+=target.stages[:DEFENSE] if target.stages[:DEFENSE]<0
                ministat+=target.stages[:SPEED] if target.stages[:SPEED]<0
                ministat+=target.stages[:SPECIAL_ATTACK] if target.stages[:SPECIAL_ATTACK]<0
                ministat+=target.stages[:SPECIAL_DEFENSE] if target.stages[:SPECIAL_DEFENSE]<0
                ministat+=target.stages[:EVASION] if target.stages[:EVASION]<0
                ministat*=(5)
                ministat+=100
                ministat/=100.0
                miniscore*=ministat  
                if target.hasActiveAbility?([:UNAWARE, :COMPETITIVE, :DEFIANT, :CONTRARY])
                    miniscore*=0.1
                end
                miniscore/=100.0
                score*=miniscore
            else
                score = 0
            end    
        end
    #---------------------------------------------------------------------------
    when "SwitchOutUserPassOnEffects" # baton pass
          if @battle.pbCanChooseNonActive?(user.index)
            score*=1.1 if user.effects[PBEffects::FocusEnergy]
            score*=1.2 if user.effects[PBEffects::Ingrain]
            score*=1.2 if user.effects[PBEffects::AquaRing]
            score*=1.3 if user.effects[PBEffects::Substitute]>0
            score*=1.2 if target.effects[PBEffects::LeechSeed]>=0
            score*=0.5 if user.effects[PBEffects::LeechSeed]>=0
            score*=0.5 if user.effects[PBEffects::BoomInstalled]
            score*=0.5 if user.effects[PBEffects::Confusion]>0
            score*=0.5 if user.effects[PBEffects::Curse]
            score*=0.5 if user.effects[PBEffects::HonorBound]   
            score*=0.5 if user.effects[PBEffects::Yawn]>0
            score*=0.0 if user.effects[PBEffects::PerishSong]>0
            score*=0.6 if user.turnCount<1
            score*=1.4 if user.moves.none? { |m| next m&.damagingMove? }
            if user.pbOwnSide.effects[PBEffects::StealthRock]
                score*=0.8
            end
            if user.pbOwnSide.effects[PBEffects::Spikes] > 0
                score/=(1.2**user.pbOwnSide.effects[PBEffects::Spikes])
            end
            if user.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
                score/=(1.2**user.pbOwnSide.effects[PBEffects::ToxicSpikes])
            end
            if user.hasActiveAbility?(:REGENERATOR) && ((user.hp.to_f)/user.totalhp)<0.75
                score*=1.2
                if user.hasActiveAbility?(:REGENERATOR) && ((user.hp.to_f)/user.totalhp)<0.5
                    score*=1.2
                end
            end
            if user.effects[PBEffects::Wish]>0
                currentHPPercent = (user.hp * 100.0 / user.totalhp)
                roles = pbGetPokemonRole(user, target)
                score*=1.2 if ["Cleric", "Pivot"].any? { |r| roles.include?(r) } && currentHPPercent >= 60
                score*=1.3 if currentHPPercent >= 70
            end
            bestmove=bestMoveVsTarget(user,target,skill) # [maxdam,maxmove,maxprio,physorspec]
            maxdam = bestmove[0]
            if maxdam*3<target.totalhp
                besttargetmove=bestMoveVsTarget(target,user,skill)
                maxtargetmove = bestmove[1]
                if targetSurvivesMove(maxtargetmove,target,user)
                    score*=1.2
                else
                    score*=0.7
                end
            end
            score*=2 if @battle.choices[target.index][0] == :SwitchOut
          else
            score = 0
        end
    #---------------------------------------------------------------------------
    when "SwitchOutTargetStatusMove" # roar
        if target.pbOwnSide.effects[PBEffects::StealthRock]
            score*=1.3
        else
            score*=0.8
        end
        if target.pbOwnSide.effects[PBEffects::Spikes] > 0
            score*=(1.2**target.pbOwnSide.effects[PBEffects::Spikes])
        else
            score*=0.8
        end
        if target.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
            score*=1.1
        end
        ministat=0
        ministat+=target.stages[:ATTACK] 
        ministat+=target.stages[:DEFENSE]
        ministat+=target.stages[:SPEED] 
        ministat+=target.stages[:SPECIAL_ATTACK] 
        ministat+=target.stages[:SPECIAL_DEFENSE] 
        ministat+=target.stages[:EVASION]
        ministat*=10
        ministat+=100
        ministat/=100.0
        score*=ministat
        if target.effects[PBEffects::PerishSong]>0 || target.effects[PBEffects::Yawn]>0
            score*=0
        end
        if target.asleep?
            score*=1.3
        end
        if target.hasActiveAbility?(:SLOWSTART)
            score*=1.3
        end
        if target.item==0 && target.hasActiveAbility?(:UNBURDEN)
            score*=1.5
        end
        if target.hasActiveAbility?([:INTIMIDATE, :GRIMTEARS])
            score*=0.7
        end
        if target.hasActiveAbility?([:REGENERATOR, :NATURALCURE])
            score*=0.5
        end
        if user.effects[PBEffects::Substitute]>0
            score*=1.4
        end
        if target.effects[PBEffects::Ingrain] || target.hasActiveAbility?(:SUCTIONCUPS) || @battle.pbAbleNonActiveCount(user.idxOpposingSide)==0
            score*=0
        end
        score = 999 if @battle.wildBattle?
    #---------------------------------------------------------------------------
    when "SwitchOutTargetDamagingMove" # dragon tail
        if (target.hasActiveAbility?(:DISGUISE,false,mold_broken) && target.form == 0) || target.effects[PBEffects::Substitute]>0
            # just regular dmg
        else
            miniscore = 100
            if target.pbOwnSide.effects[PBEffects::StealthRock]
                miniscore*=1.3
            else
                miniscore*=0.8
            end
            if target.pbOwnSide.effects[PBEffects::Spikes] > 0
                miniscore*=(1.2**target.pbOwnSide.effects[PBEffects::Spikes])
            else
                miniscore*=0.8
            end
            if target.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
                miniscore*=1.1
            end
            ministat=0
            ministat+=target.stages[:ATTACK] 
            ministat+=target.stages[:DEFENSE]
            ministat+=target.stages[:SPEED] 
            ministat+=target.stages[:SPECIAL_ATTACK] 
            ministat+=target.stages[:SPECIAL_DEFENSE] 
            ministat+=target.stages[:EVASION]
            ministat*=10
            ministat+=100
            ministat/=100.0
            miniscore*=ministat
            if target.effects[PBEffects::PerishSong]>0 || target.effects[PBEffects::Yawn]>0
                miniscore*=0
            end
            if target.asleep?
                miniscore*=1.3
            end
            if target.hasActiveAbility?(:SLOWSTART)
                miniscore*=1.3
            end
            if target.item==0 && target.hasActiveAbility?(:UNBURDEN)
                miniscore*=1.5
            end
            if target.hasActiveAbility?([:INTIMIDATE, :GRIMTEARS])
                miniscore*=0.7
            end
            if target.hasActiveAbility?([:REGENERATOR, :NATURALCURE])
                miniscore*=0.5
            end
            if user.effects[PBEffects::Substitute]>0
                miniscore*=1.4
            end
            if target.effects[PBEffects::Ingrain] || target.hasActiveAbility?(:SUCTIONCUPS) || @battle.pbAbleNonActiveCount(user.idxOpposingSide)==0
                miniscore*=0
            end
            miniscore/=100
            score*=miniscore
        end
        score = 999 if @battle.wildBattle?
    #---------------------------------------------------------------------------
    when "BindTarget", "BindTargetDoublePowerIfTargetUnderwater" # fire spin, Whirlpool
        if target.effects[PBEffects::Trapping] == 0 && target.effects[PBEffects::Substitute]<=0
            score*=1.2
            ministat=0
            ministat+=target.stages[:SPEED] if target.stages[:SPEED]>0
            ministat+=target.stages[:ATTACK] if target.stages[:ATTACK]>0
            ministat+=target.stages[:DEFENSE] if target.stages[:DEFENSE]>0
            ministat+=target.stages[:SPECIAL_ATTACK] if target.stages[:SPECIAL_ATTACK]>0
            ministat+=target.stages[:SPECIAL_DEFENSE] if target.stages[:SPECIAL_DEFENSE]>0
            ministat*=(-5)
            ministat+=100
            ministat/=100.0
            score*=ministat
            if target.totalhp == target.hp
                score*=1.2
            elsif target.hp*2 < target.totalhp
                score*=0.8
            end
            bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
            maxdam=bestmove[0]
            if maxdam>user.hp
                score*0.7
            elsif user.hp*3<user.totalhp
                score*0.7
            end
            if target.effects[PBEffects::LeechSeed]>=0
                score*=1.5
            end
            if target.effects[PBEffects::Attract]>-1 
                score*=1.3
            end          
            if target.effects[PBEffects::Confusion]>0
                score*=1.3
            end
            if pbHasSingleTargetProtectMove?(user, false)
                score*=1.1
            end
            if user.hasActiveItem?(:BINDINGBAND)
                score*=1.3
            end
            if user.hasActiveItem?(:GRIPCLAW)
                score*=1.1
            end  
        end
        if move.function == "BindTargetDoublePowerIfTargetUnderwater"
            if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderwater")
                score*=1.3
            end  
        end
    #---------------------------------------------------------------------------
    when "TrapTargetInBattle", "TrapTargetInBattleLowerTargetDefSpDef1EachTurn" # mean look, octolock
        if !target.trappedInBattle? && target.effects[PBEffects::Substitute]<=0
            miniscore=100
            if pbHasPivotMove?(target)
                miniscore*=0.1
            end
            if user.pbHasMove?(:PERISHSONG)
                miniscore*=1.5
            end
            if target.effects[PBEffects::PerishSong]>0
                miniscore*=4
            end
            if target.hasActiveAbility?([:ARENATRAP, :SHADOWTAG])
                miniscore*=0
            end
            if target.effects[PBEffects::Attract]>=0
                miniscore*=1.3
            end
            if target.effects[PBEffects::LeechSeed]>=0
                miniscore*=1.3
            end
            if target.effects[PBEffects::Curse]
                miniscore*=1.5
            end 
            if pbHasPhazingMove?(user) || pbHasPhazingMove?(target) || pbHasSetupMove?(target)
                miniscore*=0.7
            end
            if pbHasSetupMove?(user) && !target.hasActiveAbility?(:UNAWARE,false,mold_broken)
                bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
                maxdam = bestmove[0]
                if maxdam<(user.hp/3.0)
                    miniscore*=1.5
                end
                if (user.hp.to_f)/user.totalhp>0.75
                    miniscore*=1.2
                end
            end
            if target.effects[PBEffects::Confusion]>0
                miniscore*=1.1
            end
            ministat=0
            ministat+=target.stages[:ATTACK] 
            ministat+=target.stages[:DEFENSE]
            ministat+=target.stages[:SPEED] 
            ministat+=target.stages[:SPECIAL_ATTACK] 
            ministat+=target.stages[:SPECIAL_DEFENSE] 
            ministat+=target.stages[:EVASION]
            ministat*=(-5)
            ministat+=100
            ministat/=100.0
            miniscore*=ministat
            if move.function == "TrapTargetInBattleLowerTargetDefSpDef1EachTurn"
                miniscore*=1.3
                miniscore*=1.5 if target.moves.any? { |m| m&.healingMove? }
                if target.hasActiveAbility?([:COMPETITIVE, :DEFIANT, :CONTRARY])
                    miniscore*=0.1
                end
            end
            miniscore/=100.0
            if target.pbHasType?(:GHOST, true) && (Settings::MORE_TYPE_EFFECTS && !$game_switches[OLDSCHOOLBATTLE])
                miniscore = 1
                miniscore = 0 if move.baseDamage == 0
            end
            score*=miniscore
        else
            score=0 if move.baseDamage == 0
        end
    #---------------------------------------------------------------------------
    when "TrapUserAndTargetInBattle" # jaw lock
        if (!user.trappedInBattle? && !target.trappedInBattle?) && 
            target.effects[PBEffects::Substitute]<=0 && target.effects[PBEffects::JawLock] < 0
            miniscore=100
            if pbHasPivotMove?(target)
                miniscore*=0.1
            end
            if user.pbHasMove?(:PERISHSONG)
                miniscore*=1.5
            end
            if target.effects[PBEffects::PerishSong]>0
                miniscore*=4
            end
            if target.hasActiveAbility?([:ARENATRAP, :SHADOWTAG])
                miniscore*=0
            end
            if target.effects[PBEffects::Attract]>=0
                miniscore*=1.3
            end
            if target.effects[PBEffects::LeechSeed]>=0
                miniscore*=1.3
            end
            if target.effects[PBEffects::Curse]
                miniscore*=1.5
            end 
            if pbHasPhazingMove?(user) || pbHasPhazingMove?(target) || pbHasSetupMove?(target)
                miniscore*=0.7
            end
            if pbHasSetupMove?(user) && !target.hasActiveAbility?(:UNAWARE,false,mold_broken)
                bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
                maxdam = bestmove[0]
                if maxdam<(user.hp/3.0)
                    miniscore*=1.5
                end
                if (user.hp.to_f)/user.totalhp>0.75
                    miniscore*=1.2
                end
            end
            if target.effects[PBEffects::Confusion]>0
                miniscore*=1.1
            end
            ministat=0
            ministat+=target.stages[:ATTACK] 
            ministat+=target.stages[:DEFENSE]
            ministat+=target.stages[:SPEED] 
            ministat+=target.stages[:SPECIAL_ATTACK] 
            ministat+=target.stages[:SPECIAL_DEFENSE] 
            ministat+=target.stages[:EVASION]
            ministat*=(-5)
            ministat+=100
            ministat/=100.0
            miniscore*=ministat
            miniscore/=100.0
            if target.pbHasType?(:GHOST, true) && (Settings::MORE_TYPE_EFFECTS && !$game_switches[OLDSCHOOLBATTLE])
                miniscore = 1
                miniscore = 0 if move.baseDamage == 0
            end
            score*=miniscore
        else
            score=0 if move.baseDamage == 0
        end
    #---------------------------------------------------------------------------
    when "TrapAllBattlersInBattleForOneTurn" # Fairy Lock
        if user.effects[PBEffects::PerishSong]==1 || user.effects[PBEffects::PerishSong]==2
            score=0
        else
            if target.effects[PBEffects::PerishSong]==2
                score*=10
            end
            if target.effects[PBEffects::PerishSong]==1
                score*=20
            end
            if user.effects[PBEffects::LeechSeed]>=0
                score*=0.8
            end
            if target.effects[PBEffects::LeechSeed]>=0
                score*=1.2
            end
            if target.effects[PBEffects::Curse]
                score*=1.3
            end
            if user.effects[PBEffects::Curse]
                score*=0.7
            end
            if target.effects[PBEffects::Confusion]>0
                score*=1.1
            end
            if user.effects[PBEffects::Confusion]>0
                score*=1.1
            end
        end
    #---------------------------------------------------------------------------
    when "PursueSwitchingFoe" # Pursuit
        miniscore = 0
        miniscore+=target.stages[:ATTACK] if target.stages[:ATTACK]<0
        miniscore+=target.stages[:DEFENSE] if target.stages[:DEFENSE]<0
        miniscore+=target.stages[:SPEED] if target.stages[:SPEED]<0
        miniscore+=target.stages[:SPECIAL_ATTACK] if target.stages[:SPECIAL_ATTACK]<0
        miniscore+=target.stages[:SPECIAL_DEFENSE] if target.stages[:SPECIAL_DEFENSE]<0
        miniscore+=target.stages[:EVASION] if target.stages[:EVASION]<0
        miniscore+=target.stages[:ACCURACY] if target.stages[:ACCURACY]<0
        miniscore*=(-10)
        miniscore+=100
        miniscore/=100.0
        score*=miniscore
        score*=1.1 if target.effects[PBEffects::Confusion]>0
        #score*=1.15 if target.effects[PBEffects::Attract]>=0
        score*=1.2 if target.effects[PBEffects::LeechSeed]>=0
        score*=1.2 if target.effects[PBEffects::Yawn]>0
        score*=0.8 if target.effects[PBEffects::Substitute]>0

        # i wonder if will tripfags will complain about this
        if @battle.choices[target.index][0] == :SwitchOut
            score*=3
            if !targetSurvivesMove(move,user,target)
                score*=5
            end
        end
    #---------------------------------------------------------------------------
    when "UsedAfterUserTakesPhysicalDamage" # Shell Trap
        bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
        maxmove = bestmove[1]
        score*=0.5 if !userFasterThanTarget
        score*=0.7 if user.lastMoveUsed == :SHELLTRAP
        if targetSurvivesMove(maxmove,target,user) && (!user.takesHailDamage? && !user.takesSandstormDamage?)
            score*=1.2
        else
            score*=0.5
        end
        miniscore = user.hp*(1.0/user.totalhp)
        score*=miniscore
        if targetWillMove?(target,"phys")
            score *= 1.5
        else
            score = 0
        end
    #---------------------------------------------------------------------------
    when "UsedAfterAllyRoundWithDoublePower" # round
        user.allAllies.each do |b|
            next if !b.pbHasMove?(move.id)
            score *= 2
        end
    #---------------------------------------------------------------------------
    when "TargetActsNext" # after you
    #---------------------------------------------------------------------------
    when "TargetActsLast" # squash
    #---------------------------------------------------------------------------
    when "TargetUsesItsLastUsedMoveAgain" # instruct
        hasAlly = !user.allAllies.empty?
        if user.opposes?(target) # is enemy
            score=0
        elsif !hasAlly || !target.lastRegularMoveUsed
            score=0
        else
            score*=3
            user.allAllies.each do |b|
                if b.hp*2 < b.totalhp
                    score*=0.5
                else
                    if b.hp==b.totalhp
                        score*=1.2
                    end            
                end
                user.allOpposing.each do |z|
                    if (pbRoughStat(b,:SPEED,skill)>pbRoughStat(z,:SPEED,skill)) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)
                        score*=1.4
                    end
                end
                ministat = [b.attack,b.spatk].max
                minimini = [user.attack,user.spatk].max
                ministat-=minimini
                ministat+=100
                ministat/=100.0
                score*=ministat
                #score=1 if b.hp==0
            end
            score *= -1
        end
    #---------------------------------------------------------------------------
    when "StartSlowerBattlersActFirst" # trick room
        count = -1
        sweepvar = false
        @battle.pbParty(user.index).each do |i|
            next if i.nil?
            count+=1
            temproles = pbGetPokemonRole(i, target, count, @battle.pbParty(user.index))
            if temproles.include?("Sweeper")
                sweepvar = true
            end
        end
        if !sweepvar
            score*=1.3
        end
        roles = pbGetPokemonRole(user, target)
        if roles.include?("Tank") || roles.include?("Physical Wall") || roles.include?("Special Wall")
            score*=1.3
        end
        if roles.include?("Lead")
            score*=1.5
        end
        hasAlly = !user.allAllies.empty?
        if hasAlly
            score*=1.3
        end
        if user.hasActiveAbility?(:TRICKSTER)
            score*=1.4
        end
        if user.hasActiveItem?(:FOCUSSASH)
            score*=1.5
        end
        if aspeed < ospeed || user.hasActiveItem?(:IRONBALL)
            if @battle.field.effects[PBEffects::TrickRoom] > 0         
                score=0
            else
                score*=2
            end
        else
            if @battle.field.effects[PBEffects::TrickRoom] > 0
                score*=1.3
            else
                score=0
            end
        end
    #---------------------------------------------------------------------------
    when "HigherPriorityInGrassyTerrain" # grassy glide
        score *= 1.4 if expectedTerrain == :Grassy && user.affectedByTerrain?
    #---------------------------------------------------------------------------
    when "LowerPPOfTargetLastMoveBy4", "LowerPPOfTargetLastMoveBy3" # Spite, eerie spell
        miniscore=100
        lastmove = nil
        if userFasterThanTarget || priorityAI(user, move, globalArray) > 0
            if !target.lastRegularMoveUsed.nil?
                lastmove = target.pbGetMoveWithID(target.lastRegularMoveUsed)
            end
        else
            if targetWillMove?(target)
                lastmove = @battle.choices[target.index][2]
            end
        end
        if lastmove.nil?
            miniscore = 0 if move.statusMove?
        else
            count=target.moves.count { |i| i.baseDamage > 0 }
            if lastmove.baseDamage>0 && count==1
                miniscore*=1.2
            end
            if lastmove.total_pp > 0
                if lastmove.total_pp==5
                    miniscore*=1.5
                elsif lastmove.total_pp==10
                    miniscore*=1.2
                else
                    miniscore*=0.7
                end
            end
            miniscore*=1.2 if move.damagingMove?
        end
        miniscore/=100.0
        score*=miniscore
    #---------------------------------------------------------------------------
    when "DisableTargetLastMoveUsed" # Disable
        auroma = false
        target.allAllies.each do |b|
            next if !b.hasActiveAbility?(:AROMAVEIL,false,mold_broken)
            auroma = true
        end
        if (target.effects[PBEffects::Disable]>0 || auroma) && move.baseDamage == 0
            score=0
        else
            if !target.lastRegularMoveUsed.nil?
                oldmove = target.pbGetMoveWithID(target.lastRegularMoveUsed)
                bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
                maxdam=bestmove[0]
                maxmove=bestmove[1]
                moveid=maxmove.id

                if oldmove.baseDamage>0
                    score*=1.5
                    if moveid == oldmove.id
                        score*=1.3
                        if maxdam*3<user.totalhp
                            score*=1.5
                        end
                    end
                else
                    score*=0.5
                end
                if userFasterThanTarget || priorityAI(user, move, globalArray) > 0
                    score*=1.2
                    if targetWillMove?(target)
                        if @battle.choices[target.index][2].id == oldmove.id
                            score*=1.5
                        end
                    end
                else
                    score*=0.3
                end
            else
                score = 0 if move.baseDamage == 0
            end
        end
    #---------------------------------------------------------------------------
    when "DisableTargetUsingSameMoveConsecutively" # torment
        auroma = false
        target.allAllies.each do |b|
            next if !b.hasActiveAbility?(:AROMAVEIL,false,mold_broken)
            auroma = true
        end
        if (target.effects[PBEffects::Torment] || auroma) && move.baseDamage == 0
            score=0
        else
            bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
            maxdam=bestmove[0]
            maxmove=bestmove[1]
            moveid=maxmove.id

            if !target.lastRegularMoveUsed.nil?
                oldmove = target.pbGetMoveWithID(target.lastRegularMoveUsed)
                if oldmove.baseDamage>0
                    score*=1.5
                    if moveid == oldmove.id
                        score*=1.3
                        if maxdam*3<user.totalhp
                            score*=1.5
                        end
                    end
                    if pbHasSingleTargetProtectMove?(user, false)
                        score*=1.5
                    end
                    if user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveItem?(:BLACKSLUDGE) && user.pbHasType?(:POISON, true))
                        score*=1.3
                    end
                else
                    score*=0.5
                end
                if userFasterThanTarget || priorityAI(user, move, globalArray) > 0
                    score*=1.2
                    if targetWillMove?(target)
                        if @battle.choices[target.index][2].id == oldmove.id
                            score*=1.5
                        end
                    end
                else
                    score*=0.3
                end
            else
                score = 0 if move.baseDamage == 0
            end
        end
    #---------------------------------------------------------------------------
    when "DisableTargetUsingDifferentMove" # encore
        auroma = false
        target.allAllies.each do |b|
            next if !b.hasActiveAbility?(:AROMAVEIL,false,mold_broken)
            auroma = true
        end
        if (target.effects[PBEffects::Encore]>0 || auroma) && move.baseDamage == 0
            score=0
        else
            oldmove = nil
            if userFasterThanTarget || priorityAI(user, move, globalArray) > 0
                if !target.lastRegularMoveUsed.nil?
                    oldmove = target.pbGetMoveWithID(target.lastRegularMoveUsed)
                end
            else
                if targetWillMove?(target)
                    oldmove = @battle.choices[target.index][2]
                end
            end
            if oldmove.nil?
                score = 0
            else
                if oldmove.damagingMove? && pbRoughDamage(oldmove, user, target, skill, oldmove.baseDamage)*5>user.hp
                    score*=0.3
                else
                    if target.stages[:SPEED]>0
                        if (target.pbHasType?(:DARK, true) || !user.hasActiveAbility?(:PRANKSTER)) || target.hasActiveAbility?(:SPEEDBOOST)
                            score*=0.5
                        else
                            score*=2
                        end
                    else
                        score*=2
                    end            
                end
                if !target.lastRegularMoveUsed.nil?
                    if oldmove.statusMove? && (userFasterThanTarget || priorityAI(user, move, globalArray) > 0)
                        oldscore = pbGetMoveScore(oldmove, target, user, 100)
                        if oldscore <= 90
                            score *= 1 + ((90 - oldscore) / 100.0)
                        else
                            score /= 1 + ((oldscore - 50) / 100.0)
                        end 
                        score*=1.4 if targetWillMove?(target, "dmg")
                    end
                end
            end
        end
    #---------------------------------------------------------------------------
    when "DisableTargetStatusMoves" # taunt
        auroma = false
        target.allAllies.each do |b|
            next if !b.hasActiveAbility?(:AROMAVEIL,false,mold_broken)
            auroma = true
        end
        if (target.effects[PBEffects::Taunt]>0 || auroma || target.hasActiveAbility?(:OBLIVIOUS,false,mold_broken)) && 
           move.statusMove?
            score=0
        else
            if userFasterThanTarget || priorityAI(user, move, globalArray) > 0
                score*=1.2
                score*=3.0 if targetWillMove?(target, "status")
            else
                score*=0.7
            end
            if target.turnCount<=1
                score*=1.1
            else
                score*=0.9
            end  
            score*=1.3 if pbHasSingleTargetProtectMove?(target, false)
            score*=1.3 if target.moves.any? { |m| m&.healingMove? }
            if target.moves.any? { |m| next m&.statusMove? }
                score*=1.3
            else
                score*=0.3
            end
        end
    #---------------------------------------------------------------------------
    when "DisableTargetHealingMoves" # heal block
        auroma = false
        target.allAllies.each do |b|
            next if !b.hasActiveAbility?(:AROMAVEIL,false,mold_broken)
            auroma = true
        end
        if (target.effects[PBEffects::HealBlock]>0 || auroma) && move.baseDamage == 0
            score=0
        else
            if target.moves.any? { |m| m&.healingMove? }
                score*=1.5
                if userFasterThanTarget || priorityAI(user, move, globalArray) > 0
                    score*=1.5
                    if targetWillMove?(target)
                        if @battle.choices[target.index][2].healingMove?
                            score*=2.5
                        end
                    end
                end
            end
            score*=1.3 if target.hasActiveItem?(:LEFTOVERS) || (target.hasActiveItem?(:BLACKSLUDGE) && target.pbHasType?(:POISON, true))
        end
    #---------------------------------------------------------------------------
    when "DisableTargetSoundMoves" # Throat Chop # did gf forget auroma exists while making this move?
        bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
        maxmove=bestmove[1]
        maxsound=maxmove.soundMove?
        if target.moves.any? { |m| m&.soundMove? }
            if maxsound 
                score*=1.5
            else
                score*=1.3
            end
            if targetWillMove?(target) && userFasterThanTarget
                if @battle.choices[target.index][2].soundMove?
                    score*=2.0
                end
            end
        end
    #---------------------------------------------------------------------------
    when "DisableTargetMovesKnownByUser" # Imprison
        if user.effects[PBEffects::Imprison]
            score = 0
        else
            ourmoves = []
            user.moves.each do |m|
                next if m.nil?
                ourmoves.push(m.id)
            end
            miniscore = 1
            sharedmoves = []
            target.moves.each do |m|
                next if m.nil?
                if ourmoves.include?(m.id)
                    miniscore+=1
                    sharedmoves.push(m.id)
                    score*=1.5 if m.healingMove?
                    score*=1.6 if m.id == :TRICKROOM
                end
            end
            score*=miniscore
            if miniscore == 1
                score = 0
            else
                if targetWillMove?(target) && userFasterThanTarget
                    if sharedmoves.include?(@battle.choices[target.index][2].id)
                        score*=3.0
                    end
                end
            end
        end
    #---------------------------------------------------------------------------
    when "AllBattlersLoseHalfHPUserSkipsNextTurn"
        score += 20   # Shadow moves are more preferable
        score += 20 if target.hp >= target.totalhp / 2
        score -= 20 if user.hp < user.hp / 2
    #---------------------------------------------------------------------------
    when "UserLosesHalfHP"
        score += 20   # Shadow moves are more preferable
        score -= 40
    #---------------------------------------------------------------------------
    when "StartShadowSkyWeather"
        score += 20   # Shadow moves are more preferable
        if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
            @battle.pbCheckGlobalAbility(:CLOUDNINE)
            score -= 90
        elsif @battle.field.weather == :ShadowSky
            score -= 90
        end
    #---------------------------------------------------------------------------
    when "RemoveAllScreens"
        score += 20   # Shadow moves are more preferable
        if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0 ||
           target.pbOwnSide.effects[PBEffects::Reflect] > 0 ||
           target.pbOwnSide.effects[PBEffects::LightScreen] > 0 ||
           target.pbOwnSide.effects[PBEffects::Safeguard] > 0
            score += 30
            score -= 90 if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0 ||
                           user.pbOwnSide.effects[PBEffects::Reflect] > 0 ||
                           user.pbOwnSide.effects[PBEffects::LightScreen] > 0 ||
                           user.pbOwnSide.effects[PBEffects::Safeguard] > 0
        else
            score -= 110
        end
    #---------------------------------------------------------------------------
    else
      return aiEffectScorePart2_pbGetMoveScoreFunctionCode(score, move, user, target, skill)
    end
    return score
  end
end
