class Battle::AI
  #=============================================================================
  # Decide whether the opponent should use an item on the Pokémon
  #=============================================================================
  def pbEnemyShouldUseItem?(idxBattler)
    return false
  end

  # edit this shitcode to account for party members, but first test if AI can use items on inactive mons
  # NOTE: The AI will only consider using an item on the Pokémon it's currently
  #       choosing an action for.
  def pbEnemyItemToUse(idxBattler)
    return nil if !@battle.internalBattle
    items = @battle.pbGetOwnerItems(idxBattler)
    items.push(:POTION, :FULLRESTORE, :AWAKENING, :ANTIDOTE, :BURNHEAL, :PARALYZEHEAL, :ICEHEAL, :FULLHEAL, :MAXREVIVE)
    #items.push(:XATTACK, :XDEFENSE, :XSPATK, :XSPDEF, :XSPEED, :XACCURACY, :DIREHIT)
    return nil if !items || items.length == 0
    # Item categories
    hpItems = {
      :POTION       => 20,
      :SUPERPOTION  => (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 60 : 50,
      :HYPERPOTION  => (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 120 : 200,
      :MAXPOTION    => 999,
      :BERRYJUICE   => 20,
      :SWEETHEART   => 20,
      :FRESHWATER   => (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 30 : 50,
      :SODAPOP      => (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 50 : 60,
      :LEMONADE     => (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 70 : 80,
      :MOOMOOMILK   => 100,
      :ORANBERRY    => 10,
      :ENERGYPOWDER => (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 60 : 50,
      :ENERGYROOT   => (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 120 : 200
    }
    hpItems[:RAGECANDYBAR] = 20 if !Settings::RAGE_CANDY_BAR_CURES_STATUS_PROBLEMS
    fullRestoreItems = [
      :FULLRESTORE
    ]
    oneStatusItems = [   # Preferred over items that heal all status problems
      :AWAKENING, :CHESTOBERRY, :BLUEFLUTE,
      :ANTIDOTE, :PECHABERRY,
      :BURNHEAL, :RAWSTBERRY,
      :PARALYZEHEAL, :PARLYZHEAL, :CHERIBERRY,
      :ICEHEAL, :ASPEARBERRY,
      :PERSIMBERRY
    ]
    allStatusItems = [
      :FULLHEAL, :LAVACOOKIE, :OLDGATEAU, :CASTELIACONE, :LUMIOSEGALETTE,
      :SHALOURSABLE, :BIGMALASADA, :PEWTERCRUNCHIES, :LUMBERRY, :HEALPOWDER
    ]
    allStatusItems.push(:RAGECANDYBAR) if Settings::RAGE_CANDY_BAR_CURES_STATUS_PROBLEMS
    xItems = {
      :XATTACK    => [:ATTACK, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1],
      :XATTACK2   => [:ATTACK, 2],
      :XATTACK3   => [:ATTACK, 3],
      :XATTACK6   => [:ATTACK, 6],
      :XDEFENSE   => [:DEFENSE, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1],
      :XDEFENSE2  => [:DEFENSE, 2],
      :XDEFENSE3  => [:DEFENSE, 3],
      :XDEFENSE6  => [:DEFENSE, 6],
      :XDEFEND    => [:DEFENSE, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1],
      :XDEFEND2   => [:DEFENSE, 2],
      :XDEFEND3   => [:DEFENSE, 3],
      :XDEFEND6   => [:DEFENSE, 6],
      :XSPATK     => [:SPECIAL_ATTACK, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1],
      :XSPATK2    => [:SPECIAL_ATTACK, 2],
      :XSPATK3    => [:SPECIAL_ATTACK, 3],
      :XSPATK6    => [:SPECIAL_ATTACK, 6],
      :XSPECIAL   => [:SPECIAL_ATTACK, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1],
      :XSPECIAL2  => [:SPECIAL_ATTACK, 2],
      :XSPECIAL3  => [:SPECIAL_ATTACK, 3],
      :XSPECIAL6  => [:SPECIAL_ATTACK, 6],
      :XSPDEF     => [:SPECIAL_DEFENSE, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1],
      :XSPDEF2    => [:SPECIAL_DEFENSE, 2],
      :XSPDEF3    => [:SPECIAL_DEFENSE, 3],
      :XSPDEF6    => [:SPECIAL_DEFENSE, 6],
      :XSPEED     => [:SPEED, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1],
      :XSPEED2    => [:SPEED, 2],
      :XSPEED3    => [:SPEED, 3],
      :XSPEED6    => [:SPEED, 6],
      :XACCURACY  => [:ACCURACY, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1],
      :XACCURACY2 => [:ACCURACY, 2],
      :XACCURACY3 => [:ACCURACY, 3],
      :XACCURACY6 => [:ACCURACY, 6],
      # focus energy effect doesnt work here, so jank it is
      :DIREHIT    => [:EVASION, 2],
      :DIREHIT2   => [:EVASION, 2],
      :DIREHIT3   => [:EVASION, 3]
    }
    reviveItems = {
      #:REVIVE = battler.totalhp / 2,
      #:REVIVALHERB = battler.totalhp / 2,
      :MAXREVIVE => 999,
      :MAXHONEY => 999
    }

    partyScores = Array.new(@battle.pbParty(idxBattler).length, [])
    @battle.pbParty(idxBattler).each_with_index do |m, index|
      # Determine target of item
      idxTarget = index # Battler using the item
      activeMon = (idxTarget == idxBattler)
      if activeMon
        battler = @battle.battlers[idxTarget]
      else
        battler = @battle.pbMakeFakeBattler(@battle.pbParty(idxBattler)[index],false,nil,false)
      end
      pkmn = battler.pokemon
      revHP = [battler.totalhp / 2, 1].max
      reviveItems[:REVIVE] = revHP
      reviveItems[:REVIVALHERB] = revHP
      hpItems[:SITRUSBERRY] = battler.totalhp / 4
      losthp = battler.totalhp - battler.hp
      preferFullRestore = (battler.hp <= battler.totalhp * 2 / 3 &&
        (battler.status != :NONE || battler.effects[PBEffects::Confusion] > 0))
      target = battler.pbDirectOpposing(true) # this can lead to some mistakes but it good enough
      user = battler
      skill = 100
      hasPhysicalAttack = battler.moves.any? { |m| m&.physicalMove?(m&.type) }
      hasSpecialAttack = battler.moves.any? { |m| m&.specialMove?(m&.type) }
      aspeed = pbRoughStat(battler,:SPEED,skill)
      aspeed *= 1.5 if battler.hasActiveAbility?(:SPEEDBOOST) && !battler.statStageAtMax?(:SPEED)
      ospeed = pbRoughStat(target,:SPEED,skill)
      ospeed *= 1.5 if target.hasActiveAbility?(:SPEEDBOOST) && !target.statStageAtMax?(:SPEED)
      userFasterThanTarget = ((aspeed>=ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
      globalArray = @megaGlobalArray
      move = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(:SPLASH)) # dummy move for mold breaker checks
      # Find all usable items
      usableHPItems     = []
      usableStatusItems = []
      usableXItems      = []
      usableReviveItems = []
      items.each do |i|
        next if !i
        next if !@battle.pbCanUseItemOnPokemon?(i, pkmn, battler, @battle.scene, false)
        next if !ItemHandlers.triggerCanUseInBattle(i, pkmn, battler, nil,
                                                    false, self, @battle.scene, false)
        # Log HP healing items
        if losthp > 0
          power = hpItems[i]
          if power
            usableHPItems.push([i, 5, power])
            next
          end
        end
        # Log Full Restores (HP healer and status curer)
        if fullRestoreItems.include?(i)
          usableHPItems.push([i, (preferFullRestore) ? 3 : 7, 999]) if losthp > 0
          usableStatusItems.push([i, (preferFullRestore) ? 3 : 9]) if battler.status != :NONE ||
                                                                      battler.effects[PBEffects::Confusion] > 0
          next
        end
        # Log single status-curing items
        if oneStatusItems.include?(i)
          usableStatusItems.push([i, 5])
          next
        end
        # Log Full Heal-type items
        if allStatusItems.include?(i)
          usableStatusItems.push([i, 7])
          next
        end
        # Log stat-raising items
        if xItems[i]
          data = xItems[i]
          usableXItems.push([i, battler.stages[data[0]], data[1]])
          next
        end
        # Log revive items
        if battler.hp == 0
          power = reviveItems[i]
          if power
            usableReviveItems.push([i, 10, power])
            next
          end
        end
      end
      # Prioritise using a HP restoration item
      hpScore = 0
      if usableHPItems.length > 0
        hpScore = 100
        usableHPItems.sort! { |a, b| (a[1] == b[1]) ? a[2] <=> b[2] : a[1] <=> b[1] }
        chosenhpitem = nil
        usableHPItems.each do |i|
          if i[2] >= losthp
            if i[0] == :FULLRESTORE
              if battler.hasActiveAbility?(:GUTS) && hasPhysicalAttack &&
                ((battler.burned? && !battler.hasActiveItem?(:FLAMEORB)) || 
                (battler.poisoned? && !battler.hasActiveItem?(:TOXICORB)))
                break
              elsif ((battler.hasActiveAbility?(:TOXICBOOST) && hasPhysicalAttack) ||
                      battler.hasActiveAbility?(:POISONHEAL)) &&
                      battler.poisoned? && !battler.hasActiveItem?(:TOXICORB)
                break
              elsif battler.hasActiveAbility?(:FLAREBOOST) && hasSpecialAttack &&
                    battler.burned? && !battler.hasActiveItem?(:FLAMEORB)
                break
              elsif battler.hasActiveAbility?(:MARVELSCALE) && hasSpecialAttack && 
                  (battler.burned? && !battler.hasActiveItem?(:FLAMEORB))
                break
              elsif battler.hasActiveAbility?(:QUICKFEET) &&  
                  ((battler.burned? && hasSpecialAttack && !battler.hasActiveItem?(:FLAMEORB)) ||
                    (battler.poisoned? && !battler.hasActiveItem?(:TOXICORB)) ||
                    (battler.frozen? && hasPhysicalAttack) ||
                    battler.paralyzed?)
                break
              end
            end
            chosenhpitem = i
            break
          end
          chosenhpitem = i
        end
        if chosenhpitem
          heal = chosenhpitem[2]
          heal = losthp if heal > losthp
          heal -= (battler.totalhp/10) if battler.hasActiveItem?(:LIFEORB) && battler.takesIndirectDamage?
          halfhealth = (battler.hp+heal)/2
          maxdam = 0
          maxmove = nil
          maxattacker = target
          battler.eachOpposing do |b|
            next unless targetWillMove?(b)
            bestmove=bestMoveVsTarget(b,battler,skill) # [maxdam,maxmove,maxprio,physorspec]
            if bestmove[0] >= maxdam
              maxdam = bestmove[0]
              maxmove = bestmove[1]
              maxattacker = b
            end
          end
          if (target.status == :SLEEP && target.statusCount>1) && 
            (!maxmove.usableWhenAsleep? && !target.pbHasMoveFunction?("UseRandomUserMoveIfAsleep"))
            maxdam = 0
          end
          if !targetSurvivesMove(maxmove,target,battler)
            if maxdam > (battler.hp+heal)
              hpScore=0
            else
              if maxdam>=halfhealth
                hpScore*=0.1
              else
                hpScore*=2
              end
            end
          else
            if (maxdam * 1.5) > battler.hp
              hpScore*=2
            end
            if !userFasterThanTarget
              if (maxdam * 2)>battler.hp
                hpScore*=2
              end
            end
          end
          hpchange=(EndofTurnHPChanges(battler,target,false,false,true)) # what % of our hp will change after end of turn effects go through
          opphpchange=(EndofTurnHPChanges(target,battler,false,false,true)) # what % of our hp will change after end of turn effects go through
          if opphpchange<1 ## we are going to be taking more chip damage than we are going to heal
            oppchipdamage=((target.totalhp*(1-hpchange)))
          end
          thisdam=maxdam#*1.1
          hplost=(battler.totalhp-battler.hp)
          if battler.effects[PBEffects::LeechSeed]>=0 && !userFasterThanTarget && canSleepTarget(target,battler,globalArray)
            hpScore *= 0.1
          end  
          if hpchange<1 ## we are going to be taking more chip damage than we are going to heal
            chipdamage=((battler.totalhp*(1-hpchange)))
            thisdam+=chipdamage
          elsif hpchange>1 ## we are going to be healing more hp than we take chip damage for  
            healing=((battler.totalhp*(hpchange-1)))
            thisdam-=healing if !(thisdam>battler.hp)
          elsif hpchange<=0 ## we are going to a huge overstack of end of turn effects. hence we should just not heal.
            hpScore*=0
          end
          if thisdam>hplost
            hpScore*=0.1
          else
            if @battle.pbAbleNonActiveCount(battler.idxOwnSide) == 0 && hplost<=(halfhealth)
              hpScore*=0.01
            end
            if thisdam<=(halfhealth)
              hpScore*=2
            else
              if userFasterThanTarget
                if hpchange<1 && thisdam>=halfhealth && !(opphpchange<1)
                  hpScore*=0.3
                end
              end
            end
          end 
          if pbHasSetupMove?(target)
            hpScore*=0.3
          end
          if ((battler.hp.to_f)<=halfhealth)
            hpScore*=1.5
          else
            hpScore*=0.2
          end
          hpScore/=(battler.effects[PBEffects::Toxic]) if battler.effects[PBEffects::Toxic]>0
          if maxdam>halfhealth
            hpScore*=0.2 
          end
          if target.hasActiveItem?(:METRONOME)
            met=(1.0+target.effects[PBEffects::Metronome]*0.2) 
            hpScore/=met
          end 
          if battler.paralyzed? || battler.effects[PBEffects::Confusion]>0
            hpScore*=1.1 
          end
          if target.poisoned? || target.burned? || target.frozen? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse]
            hpScore*=1.3
            hpScore*=1.3 if target.effects[PBEffects::Toxic]>0
            hpScore*=1.3 if battler.item == :BINDINGBAND
          end
          if ((battler.hp.to_f)/battler.totalhp)>0.8
            hpScore*=0.1 
          elsif ((battler.hp.to_f)/battler.totalhp)>0.6
            hpScore*=0.6 
          elsif ((battler.hp.to_f)/battler.totalhp)<0.25
            hpScore*=2 
          end
        end
      end
      # Next prioritise using a status-curing item
      statusScore = 0
      maxscore = 0
      chosenstatusitem = nil
      if usableStatusItems.length > 0
        usableStatusItems.sort! { |a, b| a[1] <=> b[1] }
        usableStatusItems.each do |i|
          if i[1] == 7
            if battler.hasActiveAbility?(:GUTS) && hasPhysicalAttack &&
              ((battler.burned? && !battler.hasActiveItem?(:FLAMEORB)) || 
              (battler.poisoned? && !battler.hasActiveItem?(:TOXICORB)) ||
              (battler.asleep? && battler.pbHasMoveFunction?("UseRandomUserMoveIfAsleep")))
              break
            elsif ((battler.hasActiveAbility?(:TOXICBOOST) && hasPhysicalAttack) ||
                    battler.hasActiveAbility?(:POISONHEAL)) &&
                    battler.poisoned? && !battler.hasActiveItem?(:TOXICORB)
              break
            elsif battler.hasActiveAbility?(:FLAREBOOST) && hasSpecialAttack &&
                  battler.burned? && !battler.hasActiveItem?(:FLAMEORB)
              break
            elsif battler.hasActiveAbility?(:MARVELSCALE) && hasSpecialAttack && 
                (battler.burned? && !battler.hasActiveItem?(:FLAMEORB))
              break
            elsif battler.hasActiveAbility?(:QUICKFEET) &&  
                  ((battler.burned? && hasSpecialAttack && !battler.hasActiveItem?(:FLAMEORB)) ||
                  (battler.poisoned? && !battler.hasActiveItem?(:TOXICORB)) ||
                  (battler.frozen? && hasPhysicalAttack) ||
                  battler.paralyzed?)
              break
            elsif battler.status==:SLEEP && (battler.statusCount == 1 || # comatose specific
                                            target.pbHasMoveFunction?("SleepTarget", "SleepTargetIfUserDarkrai"))
              break
            elsif battler.paralyzed? && (target.pbHasMove?(:THUNDERWAVE) || target.pbHasMove?(:GLARE) || target.pbHasMove?(:STUNSPORE))
              break
            elsif battler.burned? && (target.pbHasMove?(:WILLOWISP) || target.pbHasMove?(:SACREDFIRE) || target.pbHasMove?(:INFERNO) || !hasPhysicalAttack)
              break
            else
              if (battler.status==:SLEEP && battler.statusCount>2 && 
                  !target.pbHasMoveFunction?("SleepTarget", "SleepTargetIfUserDarkrai")) ||
                (battler.burned? && !target.pbHasMove?(:WILLOWISP) && (!battler.hasActiveAbility?(:GUTS) && hasPhysicalAttack)) ||
                (battler.frozen? && !target.pbHasMove?(:BITINGCOLD)) ||
                (battler.paralyzed? && (target.pbHasMove?(:THUNDERWAVE) || target.pbHasMove?(:GLARE) || target.pbHasMove?(:STUNSPORE)))
                statusScore = 100
                bestmove = bestMoveVsTarget(target,battler,skill) # [maxdam,maxmove,maxprio,physorspec]
                maxdam = bestmove[0]
                maxmove = bestmove[1]
                maxprio = bestmove[2]
                halfhealth = (user.totalhp / 2)
                thirdhealth = (user.totalhp / 3)
                if targetSurvivesMove(maxmove,target,battler) || (target.status == :SLEEP && target.statusCount>1)
                  statusScore += 50
                  statusScore += 60 if (target.status == :SLEEP && target.statusCount>1)
                  statusScore += 60 if user.hasActiveAbility?(:SPEEDBOOST)
                  statusScore += 20 if halfhealth > maxdam
                  statusScore += 40 if thirdhealth > maxdam
                  if battler.paralyzed?
                    if !userFasterThanTarget && 
                      ((aspeed*2>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1))
                      statusScore += 100
                      mold_broken = moldbroken(user,target,move)
                      if battler.pbHasMoveFunction?("FlinchTarget", "HitTwoTimesFlinchTarget") && 
                         canFlinchTarget(user,target,mold_broken)
                        statusScore += 80
                        statusScore += 80 if battler.hasActiveAbility?(:SERENEGRACE)
                      end
                    end
                  else
                    if !userFasterThanTarget && maxdam>halfhealth
                      if maxprio > 0
                        if maxprio < user.hp
                          statusScore += 90
                        else  
                          statusScore -= 90 
                        end
                      else
                        statusScore -= 60 
                      end
                    else
                      statusScore += 80
                    end
                  end
                end
              elsif battler.dizzy? && !target.pbHasMove?(:CONFUSERAY)
                statusScore = 100
                minimi = getAbilityDisruptScore(move,target,battler,skill)
                minimi = 1.0 / minimi
                minimi /= 2 if battler.hasActiveAbility?(:TANGLEDFEET)
                statusScore *= minimi
              elsif battler.poisoned? && !target.pbHasMove?(:TOXIC)
                statusScore = 100
                bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
                maxdam=bestmove[0] 
                maxmove=bestmove[1]
                maxdam=0 if (target.status == :SLEEP && target.statusCount>1)
                halfhealth = (user.totalhp / 2)
                thirdhealth = (user.totalhp / 3)
                if !targetSurvivesMove(maxmove,target,user)
                  if maxdam>(user.hp+halfhealth)
                    statusScore=0
                  else
                    if maxdam>=halfhealth
                      if userFasterThanTarget
                        statusScore*=0.5
                      else
                        statusScore*=0.1
                      end
                    else
                      statusScore*=2
                    end
                  end
                else
                  if maxdam*1.5>user.hp
                    statusScore*=2
                  end
                  if !userFasterThanTarget
                    if maxdam*2>user.hp
                      statusScore*=2
                    end
                  end
                end
                hpchange=(EndofTurnHPChanges(battler,target,false,false,true)) # what % of our hp will change after end of turn effects go through
                opphpchange=(EndofTurnHPChanges(target,battler,false,false,true)) # what % of our hp will change after end of turn effects go through
                if opphpchange<1 ## we are going to be taking more chip damage than we are going to heal
                  oppchipdamage=((target.totalhp*(1-hpchange)))
                end
                thisdam=maxdam#*1.1
                hplost=(battler.totalhp-battler.hp)
                if battler.effects[PBEffects::LeechSeed]>=0 && !userFasterThanTarget && canSleepTarget(target,battler,globalArray)
                  statusScore *= 0.1
                end  
                if hpchange<1 ## we are going to be taking more chip damage than we are going to heal
                  chipdamage=((battler.totalhp*(1-hpchange)))
                  thisdam+=chipdamage
                elsif hpchange>1 ## we are going to be healing more hp than we take chip damage for  
                  healing=((battler.totalhp*(hpchange-1)))
                  thisdam-=healing if !(thisdam>battler.hp)
                elsif hpchange<=0 ## we are going to a huge overstack of end of turn effects. hence we should just not heal.
                  statusScore*=0
                end
                if thisdam>hplost
                  statusScore*=0.1
                else
                  if @battle.pbAbleNonActiveCount(battler.idxOwnSide) == 0 && hplost<=(halfhealth)
                    statusScore*=0.01
                  end
                  if thisdam<=(halfhealth)
                    statusScore*=2
                  else
                    if userFasterThanTarget
                      if hpchange<1 && thisdam>=halfhealth && !(opphpchange<1)
                        statusScore*=0.3
                      end
                    end
                  end
                end
                statusScore*=0.3 if pbHasSetupMove?(target)
                if ((battler.hp.to_f)<=halfhealth)
                  statusScore*=1.5
                else
                  statusScore*=0.8
                end
                statusScore*=0.8 if maxdam > halfhealth
                if target.hasActiveItem?(:METRONOME)
                  met=(1.0+target.effects[PBEffects::Metronome]*0.2) 
                  statusScore/=met
                end 
                if target.poisoned? || target.burned? || target.frozen? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse]
                  statusScore*=1.3
                  statusScore*=1.3 if target.effects[PBEffects::Toxic]>0
                  statusScore*=1.3 if battler.item == :BINDINGBAND
                end
                if ((battler.hp.to_f)/battler.totalhp)>0.8
                  statusScore*=0.1 
                elsif ((battler.hp.to_f)/battler.totalhp)>0.6
                  statusScore*=0.6 
                elsif ((battler.hp.to_f)/battler.totalhp)<0.25
                  statusScore*=2 
                end
              else
                statusScore=0
              end
            end
          else
            if (battler.status==:SLEEP && battler.statusCount>2 && !target.pbHasMoveFunction?("SleepTarget", "SleepTargetIfUserDarkrai") && [:AWAKENING, :CHESTOBERRY, :BLUEFLUTE].include?(i[0])) ||
              (battler.burned? && !target.pbHasMove?(:WILLOWISP) && (!battler.hasActiveAbility?(:GUTS) && hasPhysicalAttack) && [:BURNHEAL, :RAWSTBERRY].include?(i[0])) ||
              (battler.frozen? && !target.pbHasMove?(:BITINGCOLD) && [:ICEHEAL, :ASPEARBERRY].include?(i[0])) ||
              (battler.paralyzed? && (!target.pbHasMove?(:THUNDERWAVE) || !target.pbHasMove?(:GLARE) || !target.pbHasMove?(:STUNSPORE)) && [:PARALYZEHEAL, :PARLYZHEAL, :CHERIBERRY].include?(i[0]))
              statusScore = 100
              bestmove = bestMoveVsTarget(target,battler,skill) # [maxdam,maxmove,maxprio,physorspec]
              maxdam = bestmove[0]
              maxmove = bestmove[1]
              maxprio = bestmove[2]
              halfhealth = (user.totalhp / 2)
              thirdhealth = (user.totalhp / 3)
              if targetSurvivesMove(maxmove,target,battler) || (target.status == :SLEEP && target.statusCount>1)
                statusScore += 50
                statusScore += 60 if (target.status == :SLEEP && target.statusCount>1)
                statusScore += 60 if user.hasActiveAbility?(:SPEEDBOOST)
                statusScore += 20 if halfhealth > maxdam
                statusScore += 40 if thirdhealth > maxdam
                statusScore -= 60 if user.hasActiveAbility?(:QUICKFEET)
                if battler.paralyzed?
                  if !userFasterThanTarget && 
                    ((aspeed*2>ospeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>1))
                    statusScore += 100
                    mold_broken = moldbroken(user,target,move)
                    if battler.pbHasMoveFunction?("FlinchTarget", "HitTwoTimesFlinchTarget") && 
                      canFlinchTarget(user,target,mold_broken)
                      statusScore += 80
                      statusScore += 80 if battler.hasActiveAbility?(:SERENEGRACE)
                    end
                  end
                else
                  if !userFasterThanTarget && maxdam>halfhealth
                    if maxprio > 0
                      if maxprio < user.hp
                        statusScore += 90
                      else  
                        statusScore -= 90 
                      end
                    else
                      statusScore -= 60 
                    end
                  else
                    statusScore += 80
                  end
                end
              end
            elsif battler.dizzy? && !target.pbHasMove?(:CONFUSERAY) && [:PERSIMBERRY].include?(i[0])
              statusScore = 100
              minimi = getAbilityDisruptScore(move,target,battler,skill)
              minimi = 1.0 / minimi
              minimi /= 2 if battler.hasActiveAbility?(:TANGLEDFEET)
              statusScore *= minimi
            elsif battler.poisoned? && !target.pbHasMove?(:TOXIC) && [:ANTIDOTE, :PECHABERRY].include?(i[0])
              statusScore = 100
              bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
              maxdam=bestmove[0] 
              maxmove=bestmove[1]
              maxdam=0 if (target.status == :SLEEP && target.statusCount>1)
              halfhealth = (user.totalhp / 2)
              thirdhealth = (user.totalhp / 3)
              if !targetSurvivesMove(maxmove,target,user)
                if maxdam > (user.hp + halfhealth)
                  statusScore=0
                else
                  if maxdam>=halfhealth
                    if userFasterThanTarget
                      statusScore*=0.5
                    else
                      statusScore*=0.1
                    end
                  else
                    statusScore*=2
                  end
                end
              else
                if maxdam*1.5>user.hp
                  statusScore*=2
                end
                if !userFasterThanTarget
                  if maxdam*2>user.hp
                    statusScore*=2
                  end
                end
              end
              hpchange=(EndofTurnHPChanges(battler,target,false,false,true)) # what % of our hp will change after end of turn effects go through
              opphpchange=(EndofTurnHPChanges(target,battler,false,false,true)) # what % of our hp will change after end of turn effects go through
              if opphpchange<1 ## we are going to be taking more chip damage than we are going to heal
                oppchipdamage=((target.totalhp*(1-hpchange)))
              end
              thisdam=maxdam#*1.1
              hplost=(battler.totalhp-battler.hp)
              if battler.effects[PBEffects::LeechSeed]>=0 && !userFasterThanTarget && canSleepTarget(target,battler,globalArray)
                statusScore *= 0.1
              end  
              if hpchange<1 ## we are going to be taking more chip damage than we are going to heal
                chipdamage=((battler.totalhp*(1-hpchange)))
                thisdam+=chipdamage
              elsif hpchange>1 ## we are going to be healing more hp than we take chip damage for  
                healing=((battler.totalhp*(hpchange-1)))
                thisdam-=healing if !(thisdam>battler.hp)
              elsif hpchange<=0 ## we are going to a huge overstack of end of turn effects. hence we should just not heal.
                statusScore*=0
              end
              if thisdam>hplost
                statusScore*=0.1
              else
                if @battle.pbAbleNonActiveCount(battler.idxOwnSide) == 0 && hplost<=(halfhealth)
                  statusScore*=0.01
                end
                if thisdam<=(halfhealth)
                  statusScore*=2
                else
                  if userFasterThanTarget
                    if hpchange<1 && thisdam>=halfhealth && !(opphpchange<1)
                      statusScore*=0.3
                    end
                  end
                end
              end
              statusScore*=0.3 if pbHasSetupMove?(target)
              if ((battler.hp.to_f)<=halfhealth)
                statusScore*=1.5
              else
                statusScore*=0.8
              end
              statusScore*=0.8 if maxdam > halfhealth
              if target.hasActiveItem?(:METRONOME)
                met=(1.0+target.effects[PBEffects::Metronome]*0.2) 
                statusScore/=met
              end 
              if target.poisoned? || target.burned? || target.frozen? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse]
                statusScore*=1.3
                statusScore*=1.3 if target.effects[PBEffects::Toxic]>0
                statusScore*=1.3 if battler.item == :BINDINGBAND
              end
              if ((battler.hp.to_f)/battler.totalhp)>0.8
                statusScore*=0.1 
              elsif ((battler.hp.to_f)/battler.totalhp)>0.6
                statusScore*=0.6 
              elsif ((battler.hp.to_f)/battler.totalhp)<0.25
                statusScore*=2 
              end
            else
              statusScore=0
            end
          end
          if statusScore>maxscore
            chosenstatusitem=i
            maxscore=statusScore
          end
        end
      end
      # Next try using an X item
      maxscore = 0
      xitemScore = 0
      chosenXitem = nil
      revitemScore = 0
      chosenRevitem = nil
      if activeMon
        if usableXItems.length > 0
          usableXItems.sort! { |a, b| (a[1] == b[1]) ? a[2] <=> b[2] : a[1] <=> b[1] }
          roles = pbGetPokemonRole(user, target)
          usableXItems.each do |i|
            xitemScore = 90
            xitemScore -= 80 if user.moves.all? { |m| m.statusMove? }
            xitemScore += 20 if roles.include?("Sweeper")
            if user.hasActiveAbility?(:CONTRARY)
              xitemScore = 0
            else
              case i[0]
              when :XATTACK, :XATTACK2, :XATTACK3, :XATTACK6,
                   :XSPATK, :XSPATK2, :XSPATK3, :XSPATK6, :XSPECIAL, :XSPECIAL2, :XSPECIAL3, :XSPECIAL6
                bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
                maxdam=bestmove[0] 
                maxmove=bestmove[1]
                maxprio=bestmove[2]
                halfhealth=(user.totalhp/2)
                thirdhealth=(user.totalhp/3)
                if target.status != :SLEEP && canSleepTarget(user,target,globalArray) && userFasterThanTarget
                  xitemScore-=90
                end  
                if targetSurvivesMove(maxmove,target,user) || (target.status == :SLEEP && target.statusCount>1)
                  xitemScore += 40
                  xitemScore += 60 if (target.status == :SLEEP && target.statusCount>1)
                  xitemScore += 60 if user.hasActiveAbility?(:SPEEDBOOST)
                  xitemScore -= 50 if target.hasActiveAbility?(:SPEEDBOOST)
                  if canSleepTarget(target,user,globalArray) && !userFasterThanTarget
                    xitemScore-=90
                  end  
                  if !userFasterThanTarget && maxdam>halfhealth
                    if maxprio > 0
                      xitemScore -= 60
                    else
                      xitemScore += 60 
                    end
                  else
                    xitemScore += 80
                  end
                  xitemScore += 20 if halfhealth>maxdam
                  xitemScore += 40 if thirdhealth>maxdam
                end 
                xitemScore -= 50 if target.pbHasMoveFunction?("UserCopyTargetStatStages",
                                                              "UserTargetSwapStatStages",
                                                              "UserStealTargetPositiveStatStages") 
                                                            # Psych Up, Heart Swap, Spectral Thief
                xitemScore -= 50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
                if [:XATTACK, :XATTACK2, :XATTACK3, :XATTACK6].include?(i[0])
                  xitemScore -= user.stages[:ATTACK]*20
                  if user.statStageAtMax?(:ATTACK)
                    xitemScore -= 200
                  else
                    if hasPhysicalAttack
                      xitemScore += 20
                    else
                      xitemScore -= 200
                    end
                  end
                else
                  xitemScore -= user.stages[:SPECIAL_ATTACK]*20
                  if user.statStageAtMax?(:SPECIAL_ATTACK)
                    xitemScore -= 200
                  else
                    if hasSpecialAttack
                      xitemScore += 20
                    else
                      xitemScore -= 200
                    end
                  end
                end
                xitemScore -= 60 if !roles.include?("Sweeper")
              when :XDEFENSE, :XDEFENSE2, :XDEFENSE3, :XDEFENSE6, :XDEFEND2, :XDEFEND3, :XDEFEND6,
                   :XSPDEF, :XSPDEF2, :XSPDEF3, :XSPDEF6
                bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
                maxdam=bestmove[0] 
                maxmove=bestmove[1]
                maxprio=bestmove[2]
                maxphys=(bestmove[3]=="physical")
                maxspec=(bestmove[3]=="special")
                halfhealth=(user.totalhp/2)
                thirdhealth=(user.totalhp/3)
                if target.status != :SLEEP && canSleepTarget(user,target,globalArray) && userFasterThanTarget
                  xitemScore-=90
                end
                mult=1.0
                if [:XSPDEF, :XSPDEF2, :XSPDEF3, :XSPDEF6].include?(i[0])
                  mult=mult/2 if maxspec
                else
                  mult=mult/2 if maxphys
                end
                if targetSurvivesMove(maxmove,target,user,0,mult) || (target.status == :SLEEP && target.statusCount>1)
                  if target.pbHasMoveFunction?("HealUserHalfOfTotalHP", 
                        "HealUserHalfOfTotalHPLoseFlyingTypeThisTurn", 
                        "HealUserDependingOnWeather", "HealUserDependingOnSandstorm") ||
                    battler.pbHasMoveFunction?("HealUserHalfOfTotalHP", 
                        "HealUserHalfOfTotalHPLoseFlyingTypeThisTurn", 
                        "HealUserDependingOnWeather", "HealUserDependingOnSandstorm")
                    xitemScore += 40
                  end
                  xitemScore += 20 if user.hasActiveAbility?(:SPEEDBOOST)
                  if [:XSPDEF, :XSPDEF2, :XSPDEF3, :XSPDEF6].include?(i[0])
                    if maxspec
                      xitemScore += 30
                      xitemScore += 20 if halfhealth>maxdam
                    end
                  else
                    if maxphys
                      xitemScore += 30
                      xitemScore += 20 if halfhealth>maxdam
                    end
                  end
                  xitemScore += 40 if thirdhealth>maxdam
                end 
                xitemScore -= 50 if target.pbHasMoveFunction?("UserCopyTargetStatStages",
                                                              "UserTargetSwapStatStages",
                                                              "UserStealTargetPositiveStatStages") 
                                                            # Psych Up, Heart Swap, Spectral Thief
                xitemScore -= 50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
                if [:XSPDEF, :XSPDEF2, :XSPDEF3, :XSPDEF6].include?(i[0])
                  if user.statStageAtMax?(:SPECIAL_DEFENSE)
                    xitemScore -= 200
                  else
                    xitemScore -= user.stages[:SPECIAL_DEFENSE]*20
                  end
                else
                  if user.statStageAtMax?(:DEFENSE)
                    xitemScore -= 200
                  else
                    xitemScore -= user.stages[:DEFENSE]*20
                  end
                end
                xitemScore -= 40 if !roles.include?("Sweeper")
              when :XSPEED, :XSPEED2, :XSPEED3, :XSPEED6
                bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
                maxdam=bestmove[0] 
                maxmove=bestmove[1]
                maxprio=bestmove[2]
                halfhealth=(user.totalhp/2)
                thirdhealth=(user.totalhp/3)
                if target.status != :SLEEP && canSleepTarget(user,target,globalArray) && userFasterThanTarget
                  xitemScore-=90
                end
                if targetSurvivesMove(maxmove,target,battler) || (target.status == :SLEEP && target.statusCount>1)
                  xitemScore += 20
                  xitemScore += 40 if thirdhealth>maxdam
                  if !userFasterThanTarget
                    xitemScore += 100
                    mold_broken = moldbroken(user,target,move)
                    if battler.pbHasMoveFunction?("FlinchTarget", "HitTwoTimesFlinchTarget") && 
                      canFlinchTarget(user,target,mold_broken)
                      xitemScore += 80
                      xitemScore += 80 if battler.hasActiveAbility?(:SERENEGRACE)
                    end
                  end
                end
                xitemScore -= 50 if target.pbHasMoveFunction?("UserCopyTargetStatStages",
                                                              "UserTargetSwapStatStages",
                                                              "UserStealTargetPositiveStatStages") 
                                                            # Psych Up, Heart Swap, Spectral Thief
                xitemScore -= 50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
                if user.statStageAtMax?(:SPEED)
                  xitemScore -= 200
                else
                  xitemScore -= user.stages[:SPEED]*20
                end
                xitemScore -= 40 if !roles.include?("Sweeper")
              when :XACCURACY, :XACCURACY2, :XACCURACY3, :XACCURACY6
                bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
                maxdam=bestmove[0] 
                maxmove=bestmove[1]
                maxprio=bestmove[2]
                halfhealth=(user.totalhp/2)
                thirdhealth=(user.totalhp/3)
                if target.status != :SLEEP && canSleepTarget(user,target,globalArray) && userFasterThanTarget
                  xitemScore-=90
                end
                if targetSurvivesMove(maxmove,target,battler) || (target.status == :SLEEP && target.statusCount>1)
                  xitemScore += 40 if thirdhealth>maxdam
                  xitemScore += 40 if battler.moves.any? { |m| m&.accuracy <= 70 }
                  xitemScore += 60 if battler.pbHasMove?(:ZAPCANNON) || battler.pbHasMove?(:INFERNO)
                end
                xitemScore -= 50 if target.pbHasMoveFunction?("UserCopyTargetStatStages",
                                                              "UserTargetSwapStatStages",
                                                              "UserStealTargetPositiveStatStages") 
                                                            # Psych Up, Heart Swap, Spectral Thief
                xitemScore -= 50 if target.pbHasMove?(:CLEARSMOG) && !user.pbHasType?(:STEEL) # Clear Smog
                if user.statStageAtMax?(:ACCURACY)
                  xitemScore -= 200
                else
                  xitemScore -= user.stages[:ACCURACY]*20
                end
                xitemScore -= 70 if !roles.include?("Sweeper")
              when :DIREHIT, :DIREHIT2, :DIREHIT3
                bestmove=bestMoveVsTarget(target,user,skill) # [maxdam,maxmove,maxprio,physorspec]
                maxdam=bestmove[0] 
                maxmove=bestmove[1]
                maxprio=bestmove[2]
                halfhealth=(user.totalhp/2)
                thirdhealth=(user.totalhp/3)
                if target.status != :SLEEP && canSleepTarget(user,target,globalArray) && userFasterThanTarget
                  xitemScore-=90
                end
                critbuff = 2
                critbuff = 3 if [:DIREHIT3].include?(i[0])
                hascrit = 0
                hascrit += 1 if user.hasActiveAbility?(:SUPERLUCK)
                hascrit += 1 if user.hasActiveItem?(:SCOPELENS)
                user.eachMove do |m|
                  next unless m.highCriticalRate?
                  hascrit +=1
                  break
                end
                if hascrit >= 3
                  xitemScore = -200
                elsif (hascrit + critbuff) >= 3
                  xitemScore += 20
                  xitemScore += 20 if user.hasActiveAbility?(:SNIPER)
                else
                  xitemScore -= 200
                end
                xitemScore -= 120 if target.hasActiveAbility?([:BATTLEARMOR, :SHELLARMOR])
                if targetSurvivesMove(maxmove,target,user) || (target.status == :SLEEP && target.statusCount>1)
                  xitemScore += 40
                  xitemScore += 60 if (target.status == :SLEEP && target.statusCount>1)
                  xitemScore += 60 if user.hasActiveAbility?(:SPEEDBOOST)
                  if canSleepTarget(target,user,globalArray) && !userFasterThanTarget
                    xitemScore-=90
                  end  
                  if !userFasterThanTarget && maxdam>halfhealth
                    if maxprio > 0
                      xitemScore -= 60
                    else
                      xitemScore += 60 
                    end
                  else
                    xitemScore += 80
                  end
                  xitemScore += 20 if halfhealth>maxdam
                  xitemScore += 40 if thirdhealth>maxdam
                end 
              end
            end
            if xitemScore>maxscore
              chosenXitem=i
              maxscore=xitemScore
            end
          end
        end
      else
        if usableReviveItems.length > 0
          echoln "trying for revive"
          usableReviveItems.sort! { |a, b| (a[1] == b[1]) ? a[2] <=> b[2] : a[1] <=> b[1] }
          roles = pbGetPokemonRole(user, target)
          usableReviveItems.each do |i|
            revitemScore = 130
            revitemScore += 40 if [:MAXREVIVE, :MAXHONEY].include?(i)
            #scoringRevitem = i
            #heal = scoringRevitem[2]
            #heal -= (battler.totalhp/10) if battler.hasActiveItem?(:LIFEORB) && battler.takesIndirectDamage?
            revitemScore *= 0.5 if pbHasSetupMove?(target)
            revitemScore *= 1.3 if pbHasSetupMove?(user)
            revitemScore *= 1.4 if roles.include?("Ace")
            revitemScore *= 1.3 if roles.include?("Second")
            revitemScore *= 1.2 if roles.include?("Sweeper")
            revitemScore *= 1.1 if roles.include?("Field Setter")
            revitemScore *= 1.2 if roles.include?("Weather Setter")
            revitemScore *= 1.1 if roles.include?("Tailwind Setter")
            revitemScore *= 1.3 if roles.include?("Trick Room Setter")
            if target.poisoned? || target.burned? || target.frozen? || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::Curse]
              revitemScore*=1.3
              revitemScore*=1.3 if target.effects[PBEffects::Toxic]>0
            end
            if target.hasActiveItem?(:METRONOME)
              met=(1.0+target.effects[PBEffects::Metronome]*0.2) 
              revitemScore/=met
            end
            if revitemScore>maxscore
              chosenRevitem=i
              maxscore=revitemScore
            end
          end
          revitemScore = maxscore
        end
      end
      bestitem = [hpScore, statusScore, xitemScore, revitemScore].max
      case bestitem
      when hpScore
        if chosenhpitem
          partyScores[index] = hpScore, chosenhpitem[0], index
        else
          partyScores[index] = 0, nil, index
        end
      when statusScore
        if chosenstatusitem
          partyScores[index] = statusScore, chosenstatusitem[0], index
        else
          partyScores[index] = 0, nil, index
        end
      when xitemScore
        if chosenXitem
          partyScores[index] = xitemScore, chosenXitem[0], index
        else
          partyScores[index] = 0, nil, index
        end
      when revitemScore
        if chosenRevitem
          partyScores[index] = revitemScore, chosenRevitem[0], index
        else
          partyScores[index] = 0, nil, index
        end
      end
    end
    echoln partyScores
    sortedPartyScores = partyScores.sort_by { |e| -e[0] }
    #echoln sortedPartyScores[0]
    return [sortedPartyScores[0][1], sortedPartyScores[0][0]], sortedPartyScores[0][2]
  end
end
