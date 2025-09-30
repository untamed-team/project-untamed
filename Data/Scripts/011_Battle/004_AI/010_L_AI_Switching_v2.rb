class Battle::AI  
  def pbEnemyShouldWithdrawEx?(idxBattler, forceSwitch)
    party = @battle.pbParty(idxBattler)
    return false if @battle.pbParty(idxBattler).length==1
    return false if @battle.wildBattle?
    return false if !@battle.pbCanSwitch?(idxBattler)
    shouldSwitch = forceSwitch
    batonPass = -1
    moveType = nil
    skill = 100#@battle.pbGetOwnerFromBattlerIndex(idxBattler).skill_level || 0
    battler = @battle.battlers[idxBattler]
    # If Pokémon is within 6 levels of the foe, and foe's last move was
    # super-effective and powerful
    if !shouldSwitch && battler.turnCount > 0 && skill >= PBTrainerAI.highSkill
      target = battler.pbDirectOpposing(true)
      if !target.fainted? && target.lastMoveUsed &&
        (target.level - battler.level).abs <= 6
        moveData = GameData::Move.get(target.lastMoveUsed)
        moveType = moveData.type
        typeMod = pbCalcTypeMod(moveType, target, battler)
        if Effectiveness.super_effective?(typeMod) && moveData.base_damage > 50
          switchChance = (moveData.base_damage > 70) ? 30 : 20
          if switchChance>80 #(pbAIRandom(100) < switchChance) # DemICE removing randomness
            shouldSwitch = true 
            echo("If you ever see this message, you are witnessing a miracle. Start praying.\n")
          end  
        end
      end
    end
    tickdamage=false
    maxdam=0
    maxdampercent=0
    maxspeed=0
    aspeed = pbRoughStat(battler,:SPEED,100)
    battler.eachOpposing do |b|
      ospeed = pbRoughStat(b,:SPEED,100)
      maxspeed = ospeed if ospeed>maxspeed
      for j in battler.moves
        if (j.function=="BadPoisonTarget" && j.statusMove? && b.pbCanPoison?(battler,false,j)) ||# Toxic
           (j.name=="Will-O-Wisp" && b.pbCanBurn?(battler,false,j)) ||# Willo
           (j.name=="Biting Cold" && b.pbCanFreeze?(battler,false,j)) ||# Biting Cold #untamed specifics
           (j.function=="StartLeechSeedTarget" && !b.pbHasType?(:GRASS,true) && b.effects[PBEffects::Substitute]<=0) # Leech Seed
          tickdamage=true
        end  
        if b.hp==1
          tickdamage=true if j.function=="StartHailWeather" && !b.pbHasType?(:ICE,true) && !b.takesHailDamage?
          tickdamage=true if j.function=="StartSandstormWeather" && !b.pbHasType?(:ROCK,true) && !b.pbHasType?(:GROUND,true) && !b.pbHasType?(:STEEL,true) && !b.takesSandstormDamage?
          tickdamage=true if j.function=="AddStealthRocksToFoeSide" && !battler.pbOpposingSide.effects[PBEffects::StealthRock]
          tickdamage=true if j.function=="SwitchOutTargetStatusMove" && !b.effects[PBEffects::Ingrain]
          tickdamage=true if j.function=="NegateTargetAbility"
          tickdamage=true if j.function=="LowerPPOfTargetLastMoveBy4"
          tickdamage=true if j.function=="SetTargetTypesToWater"
          tickdamage=true if j.function=="StartDamageTargetEachTurnIfTargetAsleep" && battler.pbHasMoveFunction?("SleepTarget", "SleepTargetIfUserDarkrai", "SleepTargetNextTurn") && b.pbCanSleep?(battler,false,j)
        end  
        tempdam = pbRoughDamage(j, battler, b, 100, j.baseDamage)
        tempdam = 0 if pbCheckMoveImmunity(1,j,battler,b,100)
        maxdam=tempdam if tempdam>maxdam
      end 
      maxdampercent = maxdam *100.0 / b.hp
    end  
    mindamage=20
    if battler.effects[PBEffects::LeechSeed]>=0 && (battler.hp > battler.totalhp*0.66)
      mindamage=33 
      if battler.status==:SLEEP && battler.statusCount>1
        mindamage=50
        mindamage=100 if ((maxspeed>aspeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>0))
      end  
    end  
    echoln("maxdam = #{maxdampercent}") if $AIGENERALLOG
    echoln("mindam = #{mindamage}") if $AIGENERALLOG
    if maxdampercent<mindamage && !tickdamage
      shouldSwitch = true 
      echo("Switching because of dealing little to no direct or indirect damage.\n") if $AIGENERALLOG
    end  
    # Pokémon can't do anything (must have been in battle for at least 5 rounds)
    if !@battle.pbCanChooseAnyMove?(idxBattler) &&
       battler.turnCount && battler.turnCount >= 3
      shouldSwitch = true
      echo("Switching because 3 turns of nothing.\n") if $AIGENERALLOG
    end
    # Pokémon is Perish Songed and has Baton Pass
    if skill >= PBTrainerAI.highSkill && battler.effects[PBEffects::PerishSong] == 1
      battler.eachMoveWithIndex do |m, i|
        next if m.function != "SwitchOutUserPassOnEffects"   # Baton Pass
        next if !@battle.pbCanChooseMove?(idxBattler, i, false)
        batonPass = i
        shouldSwitch = true
        echo("Switching because of perish song.\n") if $AIGENERALLOG
        break
      end
    end
    # Pokémon will faint because of bad poisoning at the end of this round, but
    # would survive at least one more round if it were regular poisoning instead
    #   if battler.status == :POISON && battler.statusCount > 0 &&
    #      skill >= PBTrainerAI.highSkill
    #     toxicHP = battler.totalhp / 16
    #     nextToxicHP = toxicHP * (battler.effects[PBEffects::Toxic] + 1)
    #     if battler.hp <= nextToxicHP && battler.hp > toxicHP * 2 #&& pbAIRandom(100) < 80 # DemICE removing randomness
    #       shouldSwitch = true
    #     end
    #   end
    # Pokémon is Encored into an unfavourable move
    if battler.effects[PBEffects::Encore] > 0 && skill >= PBTrainerAI.mediumSkill
      idxEncoredMove = battler.pbEncoredMoveIndex
      if idxEncoredMove >= 0
        scoreSum   = 0
        scoreCount = 0
        battler.allOpposing.each do |b|
          scoreSum += pbGetMoveScore(battler.moves[idxEncoredMove], battler, b, skill)
          scoreCount += 1
        end
        if scoreCount > 0 && scoreSum / scoreCount <= 120 #&& pbAIRandom(100) < 80 # DemICE removing randomness
          shouldSwitch = true if battler.hp>battler.totalhp/2
          echo("Switching because of being encored into a bad move.\n") if $AIGENERALLOG
        end
      end
    end
    if moveLocked(battler)
      if battler.lastMoveUsed && battler.pbHasMove?(battler.lastMoveUsed)
        choicedmove=nil
        for choice in battler.moves
          next if choice.id!=battler.lastMoveUsed
          choicedmove=choice
        end
        scoreSum   = 0
        scoreCount = 0
        battler.allOpposing.each do |b|
          scoreSum += pbGetMoveScore(choicedmove, battler, b, skill)
          scoreCount += 1
        end
        if scoreCount > 0 && scoreSum / scoreCount <= 120 #&& pbAIRandom(100) < 80 # DemICE removing randomness
          shouldSwitch = true if battler.hp>battler.totalhp/3
          echo("Switching because of being choice locked into a bad move.\n") if $AIGENERALLOG
        end
      end
    end
    # If there is a single foe and it is resting after Hyper Beam or is
    # Truanting (i.e. free turn)
    # if @battle.pbSideSize(battler.index + 1) == 1 &&
    #   !battler.pbDirectOpposing.fainted? && skill >= PBTrainerAI.highSkill
    #   opp = battler.pbDirectOpposing
    #   if (opp.effects[PBEffects::HyperBeam] > 0 ||
    #       (opp.hasActiveAbility?(:TRUANT) && opp.effects[PBEffects::Truant])) #&& pbAIRandom(100) < 80 # DemICE removing randomness
    #     shouldSwitch = false
    #   end
    # end
    # Sudden Death rule - I'm not sure what this means
    if @battle.rules["suddendeath"] && battler.turnCount > 0
      if battler.hp <= battler.totalhp / 4 #&& pbAIRandom(100) < 30 # DemICE removing randomness
        shouldSwitch = true
        echo("The fuck's a sudden death\n")
      elsif battler.hp <= battler.totalhp / 2 #&& pbAIRandom(100) < 80 # DemICE removing randomness
        shouldSwitch = true
        echo("The fuck's a sudden death\n")
      end
    end
    # Pokémon is about to faint because of Perish Song
    if battler.effects[PBEffects::PerishSong] == 1
      shouldSwitch = true
      echo("Switching because of perish song.\n") if $AIGENERALLOG
    end
    #shouldSwitch = true # REMOVE THIS YOU PIECE OF SHIT BRAIDEAD MORRON - #by low
    incoming = nil
    weight = 1
    canheswitch=false
    party.each_with_index do |_pkmn, i|
      canheswitch=true if @battle.pbCanHardSwitchLax?(idxBattler, i)
    end
    shouldSwitch = false if !canheswitch
    return false if !shouldSwitch
    newindex=pbHardSwitchChooseNewEnemy(idxBattler,party,true) if shouldSwitch
    if newindex
      if newindex.is_a?(Array)
        swapper=newindex[0]
      else
        swapper=newindex
      end
      if swapper==battler.pokemonIndex && shouldSwitch  
        echo("\nRegretting the switch because there is no good pokemon to hard switch in.\n") if $AIGENERALLOG
        shouldSwitch=false 
      end
    else
      shouldSwitch=false   
    end
    if shouldSwitch
      incoming=[swapper,weight]
      if batonPass >= 0 && @battle.pbRegisterMove(idxBattler, batonPass, false)
        PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will use Baton Pass to avoid Perish Song")
        return true
      end
      if @battle.pbRegisterSwitch(idxBattler, incoming[0]) # DemICE Applying the new way to determine the next switch-in
        PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will switch with " + @battle.pbParty(idxBattler)[incoming[0]].name)
        return true
      end
    end
    return false
  end
  
  
  #=============================================================================
  # Choose a replacement Pokémon
  #=============================================================================
  def pbHardSwitchChooseNewEnemy(idxBattler,party,sack=false,batonpasscheck=false)
    enemies = []
    activemon=-1
    party.each_with_index do |_p,i|
      activemon=i if i==@battle.battlers[idxBattler].pokemonIndex && sack
      enemies.push(i) if @battle.pbCanHardSwitchLax?(idxBattler,i)
    end
    return -1 if enemies.length==0
    return pbChooseBestNewEnemy(idxBattler,party,enemies,sack,activemon,batonpasscheck)
  end
  
  #=============================================================================
  # Choose a replacement Pokémon
  #=============================================================================
  def pbChooseBestNewEnemy(idxBattler, party, enemies, sack=false, activemon=-1, batonpasscheck=false, retvrnspeed=false)
    return -1 if !enemies || enemies.length == 0
    currentBattler = @battle.battlers[idxBattler]
    best    = -1
    bestSum = 0
    speedsarray = []
    enemies.each do |i|
      pokmon = @battle.pbMakeFakeBattler(party[i],batonpasscheck,@battle.battlers[idxBattler]) 
      if !retvrnspeed && $AIGENERALLOG
        echo("\nSwitch score for: "+pokmon.name)
        echo("\n----------------------------------------\n")
      end  
      sum  = 0
      maxdam=0
      aspeed = pbRoughStat(pokmon,:SPEED,100)
      if @battle.field.terrain != :None && pokmon.hasActiveAbility?(:UNBURDEN)
        case @battle.field.terrain
        when :Electric
          aspeed *= 2 if pokmon.hasActiveItem?(:ELECTRICSEED)
        when :Grassy
          aspeed *= 2 if pokmon.hasActiveItem?(:GRASSYSEED)
        when :Misty
          aspeed *= 2 if pokmon.hasActiveItem?(:MISTYSEED)
        when :Psychic
          aspeed *= 2 if pokmon.hasActiveItem?(:PSYCHICSEED)
        end
      end
      if retvrnspeed
        speedsarray.push(aspeed)
        next
      end
      if @battle.field.effects[PBEffects::TrickRoom]>0
        maxspeed = 6900
      else
        maxspeed = 0
      end
      hasprio=0
      priodamage=0
      damagetakenPercent=0
      priodamagepercent=0
      death=false  
      roomturn=0
      roomturn=1 if sack
      if $player.difficulty_mode?("chaos")
        # no need to do abilityWeather or abilityTerrain checks here
        w_damage_multiplier = 1.25
        t_damage_multiplier = 1.15
        w_damage_divider = t_damage_divider = 1.5
      else
        w_damage_multiplier = 1.5
        t_damage_multiplier = 1.3
        w_damage_divider = t_damage_divider = 2.0
      end
      if pokmon.hasActiveAbility?(:TRACE)
        traced = pokmon.pbDirectOpposing(true)
        if !traced.ungainableAbility? && ![:POWEROFALCHEMY, :RECEIVER, :TRACE].include?(traced.ability_id)
          pokmon.ability_id = traced.ability_id
        end
      end
      pokmon.eachOpposing do |newenemy|
        # speed checks
        ospeed = pbRoughStat(newenemy,:SPEED,100)
        if pokmon.hasActiveAbility?([:INTIMIDATE,:GRIMTEARS]) &&
          (newenemy.hasActiveAbility?(:RATTLED) || newenemy.hasActiveItem?(:ADRENALINEORB))
          ospeed *= 1.5
        end
        if pokmon.hasActiveAbility?(:DRIZZLE) && 
           @battle.pbWeather != :Rain && newenemy.item != :UTILITYUMBRELLA
          ospeed *= 2 if newenemy.hasActiveAbility?(:SWIFTSWIM)
        end
        if pokmon.hasActiveAbility?(:DROUGHT) && 
           @battle.pbWeather != :Sun && newenemy.item != :UTILITYUMBRELLA
          ospeed *= 2 if newenemy.hasActiveAbility?(:CHLOROPHYLL)
        end
        if pokmon.hasActiveAbility?([:SANDSTREAM, :DUSTSENTINEL]) && 
           @battle.pbWeather != :Sandstorm 
          ospeed *= 2 if newenemy.hasActiveAbility?(:SANDRUSH)
        end
        if pokmon.hasActiveAbility?(:SNOWWARNING) && 
           @battle.pbWeather != :Hail 
          ospeed *= 2 if newenemy.hasActiveAbility?(:SLUSHRUSH)
        end
        if pokmon.hasActiveAbility?(:ELECTRICSURGE) && 
           @battle.field.terrain != :Electric
          ospeed *= 2 if newenemy.hasActiveAbility?(:SURGESURFER)
        end
        ###############
        for j in newenemy.moves
          mold_broken=moldbroken(newenemy,pokmon,j)
          if moveLocked(newenemy)
            if newenemy.lastMoveUsed && newenemy.pbHasMove?(newenemy.lastMoveUsed)
              next if j.id!=newenemy.lastMoveUsed
            end
          end  
          if (j.function=="BadPoisonTarget" && j.statusMove? && pokmon.pbCanPoison?(newenemy,false,j)) ||# Toxic
             (j.name=="Will-O-Wisp" && pokmon.pbCanBurn?(newenemy,false,j)) ||# Willo
             (j.name=="Biting Cold" && pokmon.pbCanFreeze?(newenemy,false,j)) ||# Biting Cold #untamed specifics
             (j.function=="StartLeechSeedTarget" && !pokmon.pbHasType?(:GRASS) && pokmon.effects[PBEffects::Substitute]<=0) # Leech Seed
            death=true  
          end  
          # damage calcs
          tempdam = pbRoughDamage(j,newenemy,pokmon,100,j.baseDamage)
          if pbCheckMoveImmunity(1,j,newenemy,pokmon,100) || 
            (newenemy.status==:SLEEP && newenemy.statusCount>1 && !newenemy.pbHasMoveFunction?("UseRandomUserMoveIfAsleep"))
            tempdam = 0 
          else
            thispriority = priorityAI(newenemy,j,[],true)
            if !mold_broken && pokmon.hasActiveAbility?(:DISGUISE) && pokmon.form==0  
              if j.multiHitMove?
                tempdam*=0.6
              else
                tempdam=1
              end
            end  
            if pokmon.hasActiveAbility?(:DRIZZLE) && @battle.pbWeather != :Rain &&
               newenemy.item != :UTILITYUMBRELLA
              tempdam*=w_damage_multiplier if j.type == :WATER
              tempdam/=w_damage_divider if j.type == :FIRE
            end
            if pokmon.hasActiveAbility?(:DROUGHT) && @battle.pbWeather != :Sun &&
               newenemy.item != :UTILITYUMBRELLA
              tempdam*=w_damage_multiplier if j.type == :FIRE
              tempdam/=w_damage_divider if j.type == :WATER
              tempdam*=1.3 if j.function=="PeperSpray" && !newenemy.hasActiveItem?(:UTILITYUMBRELLA)
              tempdam*=1.5 if newenemy.hasActiveAbility?(:SOLARPOWER) && j.specialMove?
            end
            if pokmon.hasActiveAbility?([:SANDSTREAM, :DUSTSENTINEL]) && @battle.pbWeather != :Sandstorm 
              tempdam*=0.67 if pokmon.pbHasType?(:ROCK) && j.specialMove?
              tempdam*=0.67 if pokmon.hasActiveAbility?(:SANDVEIL) && j.physicalMove?
              tempdam*=1.3 if [:GROUND,:ROCK,:STEEL].include?(j.type) && newenemy.hasActiveAbility?([:SANDFORCE, :DUSTSENTINEL])
            end
            if pokmon.hasActiveAbility?(:SNOWWARNING) && @battle.pbWeather != :Hail 
              if pokmon.pbHasType?(:ICE)
                moveType = j.type
                typeMod = pbCalcTypeMod(moveType, newenemy, pokmon)
                tempdam*=0.75 if Effectiveness.super_effective?(typeMod)
              end
              tempdam*=0.67 if pokmon.hasActiveAbility?(:SNOWCLOAK) && j.specialMove?
            end
            if pokmon.hasActiveAbility?(:ELECTRICSURGE) && @battle.field.terrain != :Electric
              tempdam*=t_damage_multiplier if newenemy.affectedByTerrain? && j.type == :ELECTRIC
              tempdam*=1.6 if j.function=="DoublePowerInElectricTerrain" && newenemy.affectedByTerrain?
              tempdam*=0.67 if pokmon.hasActiveItem?(:ELECTRICSEED) && j.physicalMove?
            end
            if pokmon.hasActiveAbility?(:GRASSYSURGE) && @battle.field.terrain != :Grassy
              tempdam*=t_damage_multiplier if j.type == :GRASS && newenemy.affectedByTerrain?
              thispriority +=1 if j.function=="HigherPriorityInGrassyTerrain" && newenemy.affectedByTerrain?
              tempdam*=0.67 if pokmon.hasActiveItem?(:GRASSYSEED) && j.physicalMove?
              if ["DoublePowerIfTargetUnderground","LowerTargetSpeed1WeakerInGrassyTerrain",
                "RandomPowerDoublePowerIfTargetUnderground"].include?(j.function) && newenemy.affectedByTerrain?
                tempdam*=0.5
              end
            end
            if pokmon.hasActiveAbility?(:PSYCHICSURGE) && @battle.field.terrain != :Psychic
              tempdam*=t_damage_multiplier if j.type == :PSYCHIC && newenemy.affectedByTerrain?
              tempdam*=1.3 if j.function=="HitsAllFoesAndPowersUpInPsychicTerrain" && newenemy.affectedByTerrain?
              tempdam*=0.67 if pokmon.hasActiveItem?(:PSYCHICSEED) && j.specialMove?
            end
            if pokmon.hasActiveAbility?(:MISTYSURGE) && @battle.field.terrain != :Misty
              tempdam/=t_damage_divider if j.type == :DRAGON && pokmon.affectedByTerrain?
              tempdam*=1.5 if j.function=="UserFaintsPowersUpInMistyTerrainExplosive" && newenemy.affectedByTerrain?
              tempdam*=0.67 if pokmon.hasActiveItem?(:MISTYSEED) && j.specialMove?
            end
            if pokmon.hasActiveAbility?(:INTIMIDATE) && 
               newenemy.pbCanLowerAttackStatStageIntimidateAI(pokmon)
              if j.physicalMove?
                if newenemy.hasActiveAbility?([:DEFIANT,:CONTRARY])
                  tempdam*=1.5
                else
                  tempdam*=0.67 
                end
              end
              if j.specialMove? && newenemy.hasActiveAbility?(:COMPETITIVE)
                tempdam*=2
              end
            end
            if pokmon.hasActiveAbility?(:GRIMTEARS) && 
               newenemy.pbCanLowerAttackStatStageGrimTearsAI(pokmon)
              if j.specialMove?
                if newenemy.hasActiveAbility?([:COMPETITIVE,:CONTRARY])
                  tempdam*=1.5
                else
                  tempdam*=0.67 
                end
              end
              if j.physicalMove? && newenemy.hasActiveAbility?(:DEFIANT)
                tempdam*=2
              end
            end
            if thispriority>0 
              tempdam=0 if pokmon.hasActiveAbility?(:PSYCHICSURGE) && pokmon.affectedByTerrain?
              hasprio=thispriority
              priodamage=tempdam if tempdam>priodamage
            end    
            maxdam=tempdam if tempdam>maxdam
          end 
          ##############
          if @battle.field.effects[PBEffects::TrickRoom]>0
            maxspeed = ospeed if ospeed<maxspeed
          else
            maxspeed = ospeed if ospeed>maxspeed
          end
        end  
      end
      damagetakenPercent = maxdam *100.0 / pokmon.hp
      priodamagepercent = priodamage *100.0 / pokmon.hp
      if damagetakenPercent>100
        damagetakenPercent =100 
        damagetakenPercent =99 if (pokmon.hasActiveItem?(:FOCUSSASH) || pokmon.hasActiveAbility?(:STURDY)) && (pokmon.hp==pokmon.totalhp)
      end  
      damagetakenPercent = 100 if pokmon.hasActiveAbility?(:WONDERGUARD) && death
      maxscore=0
      scoresum=0
      damagesum=0
      ownmaxdmg=0
      ownmaxmove=nil
      tickdamage=false
      maxprio=0
      fakedmg=0
      damagedealtPercent=0
      if pokmon.hasActiveAbility?(:DOWNLOAD)
        oDef = oSpDef = 0
        @battle.allOtherSideBattlers(pokmon.index).each do |data|
          oDef   += data.defense
          oSpDef += data.spdef
        end
        downloadStat = (oDef < oSpDef) ? :ATTACK : :SPECIAL_ATTACK
      end
      if pokmon.hasActiveAbility?(:FOREWARN) && $player.difficulty_mode?("chaos")
        # added f_ to everything to ensure nothing blows up
        f_stageMul, f_stageDiv = @battle.pbGetStatMath
        oAtk = 0
        oSpAtk = 0
        battle.allOtherSideBattlers(pokmon.index).each do |data|
          f_atk        = data.attack
          f_atkStage   = data.stages[:ATTACK] + 6
          f_realAtk    = (f_atk.to_f * f_stageMul[f_atkStage] / f_stageDiv[f_atkStage]).floor
          oAtk   += f_realAtk
          f_spAtk      = data.spatk
          f_spAtkStage = data.stages[:SPECIAL_ATTACK] + 6
          f_realSpAtk  = (f_spAtk.to_f * f_stageMul[f_spAtkStage] / f_stageDiv[f_spAtkStage]).floor
          oSpAtk += f_realSpAtk
        end
        forewarnStat = (oAtk > oSpAtk) ? :DEFENSE : :SPECIAL_DEFENSE
      end
      pokmon.moves.each do |m|
        pokmon.eachOpposing do |b|
          mold_broken=moldbroken(pokmon,b,m)
          if (m.function=="BadPoisonTarget" && m.statusMove? && b.pbCanPoison?(pokmon,false,m)) ||# Toxic
             (m.name=="Will-O-Wisp" && b.pbCanBurn?(pokmon,false,m)) ||# Willo
             (m.name=="Biting Cold" && b.pbCanFreeze?(pokmon,false,m)) ||# Biting Cold #untamed specifics
             (m.function=="StartLeechSeedTarget" && !b.pbHasType?(:GRASS,true) && b.effects[PBEffects::Substitute]<=0) # Leech Seed
            tickdamage=true
            sum+=150
            if pokmon.pbHasMoveFunction?(
                "HealUserHalfOfTotalHP", "HealUserHalfOfTotalHPLoseFlyingTypeThisTurn",  # Recovery, Roost
                "HealUserDependingOnWeather", "HealUserDependingOnSandstorm", # Synthesis, Shore up 
                "HealUserFullyAndFallAsleep", "HealUserByTargetAttackLowerTargetAttack1", "HealUserDependingOnHail")  # Rest, Strength Sap
              if ((aspeed>maxspeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>roomturn))
                sum+=40 if damagetakenPercent<50
              else  
                sum+=40 if damagetakenPercent<33
              end  
            end    
          end    
          #  Recovery
          if ["HealUserHalfOfTotalHP", "HealUserHalfOfTotalHPLoseFlyingTypeThisTurn", 
              "HealUserDependingOnWeather", "HealUserDependingOnSandstorm", "HealUserFullyAndFallAsleep", "HealUserDependingOnHail"].include?(m.function)
            if ((aspeed>maxspeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>roomturn))
              sum+=80 if damagetakenPercent<50
            else  
              sum+=80 if damagetakenPercent<33
            end  
          end
          if currentBattler.hasActiveAbility?(:REGENERATOR)
            if currentBattler.hp < (currentBattler.totalhp * 2.0/3.0)
              sum+=30
              sum+=20 if sack && i!=activemon
            end
          end
          if pokmon.effects[PBEffects::Wish]>0
            wishhealPercent = (pokmon.effects[PBEffects::WishAmount] * 100.0 / pokmon.hp)
            if wishhealPercent >= 50 && damagetakenPercent<50
              sum+=80
            elsif wishhealPercent >= 33 && damagetakenPercent<33
              sum+=80
            elsif wishhealPercent >= 60 && damagetakenPercent<20 && 
               ((pokmon.hp/pokmon.totalhp) < 0.6 && (pokmon.hp / pokmon.totalhp) > 0.3)
              sum+=80
            end
          end
          battlePos = @battle.positions[pokmon.index]
          if battlePos.effects[PBEffects::HealingWish] || battlePos.effects[PBEffects::LunarDance] ||
             battlePos.effects[PBEffects::PartyPopper]
            poshealPercent = 100
            poshealPercent = 50 if battlePos.effects[PBEffects::PartyPopper]
            if (poshealPercent >= 50 && damagetakenPercent < 50) ||
               (poshealPercent >= 33 && damagetakenPercent < 33)
              sum+=80
            elsif poshealPercent >= 60 && damagetakenPercent<20 && 
                ((pokmon.hp/pokmon.totalhp) < 0.6 && (pokmon.hp / pokmon.totalhp) > 0.3)
              sum+=80
            end
            healsStatus = battlePos.effects[PBEffects::HealingWish] || battlePos.effects[PBEffects::LunarDance]
            if healsStatus && pokmon.status != :NONE
              case pokmon.status
              when :POISON
                if pokmon.hasActiveAbility?([:GUTS, :MARVELSCALE, :QUICKFEET, :TOXICBOOST, :POISONHEAL]) && 
                  !pokmon.hasActiveItem?(:TOXICORB)
                  sum-=50
                else
                  sum+=50
                end
              when :BURN
                if pokmon.hasActiveAbility?([:GUTS, :MARVELSCALE, :QUICKFEET, :FLAREBOOST]) && 
                  !pokmon.hasActiveItem?(:FLAMEORB)
                  sum-=50
                else
                  sum+=50
                end
              when :PARALYSIS
                if pokmon.hasActiveAbility?([:GUTS, :MARVELSCALE, :QUICKFEET])
                  sum-=50
                else
                  sum+=50
                end
              when :FREEZE
                if pokmon.hasActiveAbility?([:GUTS, :MARVELSCALE, :QUICKFEET])
                  sum-=50
                else
                  sum+=50
                end
              when :SLEEP
                if pokmon.pbHasMoveFunction?("UseRandomUserMoveIfAsleep")
                  sum-=20
                  sum-=15 if pokmon.hasActiveAbility?(:GUTS)
                else
                  sum+=75
                end
              when :DIZZY
                dummymove = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(:SPLASH))
                minimi = getAbilityDisruptScore(dummymove,b,pokmon,100,false)
                minimi /= 2 if pokmon.hasActiveAbility?(:TANGLEDFEET)
                sum *= minimi
              end
            end
            if battlePos.effects[PBEffects::LunarDance]
              sum+=60 if m.total_pp <= 16 && (m.pp / m.total_pp) <= 0.625
            end
          end
          if pokmon.hasActiveAbility?(:DOWNLOAD)
            oldStatD = pokmon.stages[downloadStat]
            # why would you combo download and contrary?
            increment = 1
            increment *= 2 if pokmon.hasActiveAbility?(:SIMPLE)
            increment *= -1 if pokmon.hasActiveAbility?(:CONTRARY)
            pokmon.stages[downloadStat] += increment if pokmon.pbCanRaiseStatStage?(downloadStat, pokmon)
            pokmon.stages[downloadStat] = [[pokmon.stages[downloadStat], -6].max, 6].min
          end
          if pokmon.hasActiveAbility?(:FOREWARN) && $player.difficulty_mode?("chaos")
            oldStatF = pokmon.stages[forewarnStat]
            # why would you combo forewarn and contrary?
            increment = 1
            increment *= 2 if pokmon.hasActiveAbility?(:SIMPLE)
            increment *= -1 if pokmon.hasActiveAbility?(:CONTRARY)
            pokmon.stages[forewarnStat] += increment if pokmon.pbCanRaiseStatStage?(forewarnStat, pokmon)
            pokmon.stages[forewarnStat] = [[pokmon.stages[forewarnStat], -6].max, 6].min
          end
          tempdam = pbRoughDamage(m,pokmon,b,100,m.baseDamage)
          if pokmon.hasActiveAbility?(:DOWNLOAD)
            pokmon.stages[downloadStat] = oldStatD
          end
          if pokmon.hasActiveAbility?(:FOREWARN) && $player.difficulty_mode?("chaos")
            pokmon.stages[forewarnStat] = oldStatF
          end
          thispriority=priorityAI(pokmon,m,[],true)
          tempdam = 0 if thispriority>0 && pokmon.hasActiveAbility?(:PSYCHICSURGE) && b.affectedByTerrain?
          maxprio=thispriority if tempdam>=b.hp && thispriority>0
          tempdam = 0 if pbCheckMoveImmunity(1,m,pokmon,b,100)
          if pokmon.hasActiveAbility?(:DRIZZLE) && @battle.pbWeather != :Rain && pokmon.item != :UTILITYUMBRELLA
            tempdam*=w_damage_multiplier if m.type == :WATER
            tempdam/=w_damage_divider if m.type == :FIRE
          end
          if pokmon.hasActiveAbility?(:DROUGHT) && @battle.pbWeather != :Sun && pokmon.item != :UTILITYUMBRELLA
            tempdam*=w_damage_multiplier if m.type == :FIRE
            tempdam/=w_damage_divider if m.type == :WATER
            tempdam*=1.3 if m.function=="PeperSpray" && !pokmon.hasActiveItem?(:UTILITYUMBRELLA)
            tempdam*=1.5 if pokmon.hasActiveAbility?(:SOLARPOWER) && m.specialMove?
          end
          if pokmon.hasActiveAbility?([:SANDSTREAM, :DUSTSENTINEL]) && @battle.pbWeather != :Sandstorm 
            tempdam*=0.67 if b.pbHasType?(:ROCK,true) && m.specialMove?
            tempdam*=0.77 if b.hasActiveAbility?(:SANDVEIL) && m.physicalMove?
            tempdam*=1.3 if [:GROUND,:ROCK,:STEEL].include?(m.type) && pokmon.hasActiveAbility?([:SANDFORCE, :DUSTSENTINEL])
          end
          if pokmon.hasActiveAbility?(:SNOWWARNING) && @battle.pbWeather != :Hail 
            if b.pbHasType?(:ICE,true)
              moveType = m.type
              typeMod = pbCalcTypeMod(moveType, b, pokmon)
              tempdam*=0.75 if Effectiveness.super_effective?(typeMod)
            end
            tempdam*=0.77 if b.hasActiveAbility?(:SNOWCLOAK) && m.specialMove?
          end
          if pokmon.hasActiveAbility?(:ELECTRICSURGE) && @battle.field.terrain != :Electric
            tempdam*=t_damage_multiplier if pokmon.affectedByTerrain? if m.type == :ELECTRIC && m.function!="DoublePowerInElectricTerrain"
            tempdam*=1.6 if m.function=="DoublePowerInElectricTerrain" && pokmon.affectedByTerrain?
            tempdam*=0.67 if b.hasActiveItem?(:ELECTRICSEED) && m.physicalMove?
          end
          if pokmon.hasActiveAbility?(:GRASSYSURGE) && @battle.field.terrain != :Grassy
            tempdam*=t_damage_multiplier if m.type == :GRASS && pokmon.affectedByTerrain? && m.function != "HigherPriorityInGrassyTerrain"
            tempdam*=0.67 if b.hasActiveItem?(:GRASSYSEED) && m.physicalMove?
            tempdam*=0.67 if b.hasActiveAbility?(:GRASSPELT) && m.physicalMove?
            if ["DoublePowerIfTargetUnderground", "LowerTargetSpeed1WeakerInGrassyTerrain",
              "RandomPowerDoublePowerIfTargetUnderground"].include?(m.function) && pokmon.affectedByTerrain?
              tempdam*=0.5
            end
          end
          if pokmon.hasActiveAbility?(:PSYCHICSURGE) && @battle.field.terrain != :Psychic
            tempdam*=t_damage_multiplier if m.type == :PSYCHIC && pokmon.affectedByTerrain? && m.function!="HitsAllFoesAndPowersUpInPsychicTerrain"
            tempdam*=1.3 if m.function=="HitsAllFoesAndPowersUpInPsychicTerrain" && pokmon.affectedByTerrain?
            tempdam*=0.67 if b.hasActiveItem?(:PSYCHICSEED) && m.specialMove?
          end
          if pokmon.hasActiveAbility?(:MISTYSURGE) && @battle.field.terrain != :Misty
            tempdam/=t_damage_divider if m.type == :DRAGON && b.affectedByTerrain?
            tempdam*=1.5 if m.function=="UserFaintsPowersUpInMistyTerrainExplosive" && pokmon.affectedByTerrain?
            tempdam*=0.67 if b.hasActiveItem?(:MISTYSEED) && m.specialMove?
          end
          if !mold_broken && b.hasActiveAbility?(:DISGUISE) && b.form==0  
            if m.multiHitMove?
              tempdam*=2.2
            end
          end  
          if m.function=="FlinchTargetFailsIfNotUserFirstTurn" && 
             tempdam>1 && canFlinchTarget(pokmon,b)
            fakedmg = tempdam *100.0 / b.hp
            fakedmg = 100 if fakedmg>100
          end
          ownmaxdmg=tempdam if tempdam>ownmaxdmg
          ownmaxmove=m
          damagedealtPercent = ownmaxdmg *100.0 / b.hp
          # teleport, u-turn / volt switch, Parting Shot, baton pass
          if ["SwitchOutUserStatusMove", "SwitchOutUserDamagingMove",
              "LowerTargetAtkSpAtk1SwitchOutUser", "SwitchOutUserPassOnEffects"].include?(m.function)
            score=120
          elsif ["UseRandomMove", "UseRandomMoveFromUserParty"].include?(m.function) #by low
            score=95
          else  
            score=pbGetMoveScore(m, pokmon, b, 100)
          end  
          maxscore=score if score>maxscore
          scoresum+=score
          damagesum+=tempdam 
          #   bTypes = b.pbTypes(true)
          #   sum += Effectiveness.calculate(m.type, bTypes[0], bTypes[1], bTypes[2]) if !pbCheckMoveImmunity(1,m,pokmon,b,100)
        end
        damagedealtPercent+=fakedmg
        damagedealtPercent =100 if damagedealtPercent>100
        if damagesum<=5 || tickdamage
          maxscore=0
          maxscore=0
        end
      end
      sum+=maxscore+(scoresum*0.01) #if damagesum>0 || tickdamage
      #if $consoleenabled
        echo("\nScore after factoring offense: "+sum.to_s+" (Maximum potential damage dealt: "+damagedealtPercent.to_s+" percent)") if $AIGENERALLOG
      #end  
      if ownmaxmove
        sum-=100 if (ownmaxmove.physicalMove? && pokmon.stages[:SPECIAL_ATTACK]>0) || (ownmaxmove.specialMove? && pokmon.stages[:ATTACK]>0)
      end  
      willtakedamage=false
      pokmon.eachOpposing do |b|
        if ((aspeed>maxspeed) ^ (@battle.field.effects[PBEffects::TrickRoom]>roomturn)) && (damagedealtPercent>=100 || maxprio>0)
          if hasprio>maxprio
            willtakedamage=true
            damagetakenPercent = priodamagepercent
          else  
            damagetakenPercent = 0
          end  
        else
          if maxprio>hasprio
            damagetakenPercent = 0
          else  
            willtakedamage=true  
          end  
        end  
        
        sum*=(100.1-damagetakenPercent)*0.01
        if pokmon.hasActiveItem?(:AIRBALLOON) && willtakedamage
          playerparty = @battle.pbParty(0)
          groundvar=false
          playerparty.each_with_index do |pkmn, idxParty|
            next if !pkmn ||!pkmn.able?
            next if idxParty==b.pokemonIndex
            pkmn.eachMove do |m|
              next if m.base_damage==0 || m.type != :GROUND
              groundvar=true
            end 
          end   
          sum-=20 if groundvar  
        end  
      end  
      #if $consoleenabled
        echo("\nScore after factoring defense: "+sum.to_s+" (Maximum expected damage taken: "+damagetakenPercent.to_s+" percent)") if $AIGENERALLOG
      #end  
      ownparty = @battle.pbParty(1)
      ownparty.each_with_index do |pkmn, idxParty|
        next if !pkmn || !pkmn.able?
        next if pkmn==pokmon
        if pokmon.ability==:DROUGHT
          sum+=20 if pkmn.ability == :CHLOROPHYLL
          sum+=10 if pkmn.ability == :FLOWERGIFT || pkmn.ability == :SOLARPOWER
          sum+=5 if pkmn.ability == :HEALINGSUN
          pkmn.eachMove do |m|
            next if m.base_damage==0 || m.type != :FIRE
            sum += 10
          end   
          pkmn.eachMove do |m|
            next if m.base_damage==0 || m.type != :WATER
            sum -= 5
          end   
          sum+=5 if pkmn.pbHasMoveFunction?("HealUserDependingOnWeather", "RaiseUserAtkSpAtk1Or2InSun")
          sum+=5 if pkmn.pbHasMoveFunction?("TwoTurnAttackOneTurnInSun", "HigherDamageInSunVSNonFireTypes") 
          sum-=5 if pkmn.pbHasMoveFunction?("ParalyzeTargetAlwaysHitsInRainHitsTargetInSky", "ConfuseTargetAlwaysHitsInRainHitsTargetInSky") && @battle.field.weather == :Rain
        end
        if pokmon.ability==:DRIZZLE
          sum+=20 if pkmn.ability == :SWIFTSWIM
          sum+=5 if pkmn.ability == :RAINDISH || pkmn.ability == :DRYSKIN || pkmn.ability == :HYDRATION
          pkmn.eachMove do |m|
            next if m.base_damage==0 || m.type != :WATER
            sum += 10
          end   
          pkmn.eachMove do |m|
            next if m.base_damage==0 || m.type != :FIRE
            sum -= 5
          end   
          sum-=5 if pkmn.pbHasMoveFunction?("HealUserDependingOnWeather", "RaiseUserAtkSpAtk1Or2InSun", "TwoTurnAttackOneTurnInSun") && @battle.field.weather == :Sun
          sum+=5 if pkmn.pbHasMoveFunction?("ParalyzeTargetAlwaysHitsInRainHitsTargetInSky", "HigherDamageInRain") #untamed specifics
        end
        if pokmon.ability==:SANDSTREAM || pokmon.ability==:DUSTSENTINEL
          sum+=20 if pkmn.ability == :SANDRUSH
          sum+=15 if pkmn.ability == :SANDFORCE
          sum+=10 if pkmn.ability == :SANDVEIL
          sum+=10 if pkmn.hasType?(:ROCK)
          sum+=5 if pkmn.ability == :PARTICURE
          sum-=5 if pkmn.pbHasMoveFunction?("HealUserDependingOnWeather", "RaiseUserAtkSpAtk1Or2InSun", "TwoTurnAttackOneTurnInSun") && @battle.field.weather == :Sun
          sum+=5 if pkmn.pbHasMoveFunction?("HealUserDependingOnSandstorm") 
        end
        if pokmon.ability==:SNOWWARNING
          sum+=20 if pkmn.ability == :SLUSHRUSH
          sum+=10 if pkmn.ability == :SNOWCLOAK
          sum+=10 if pkmn.hasType?(:ICE)
          sum+=5 if pkmn.ability == :ICEBODY
          sum-=5 if pkmn.pbHasMoveFunction?("HealUserDependingOnWeather", "RaiseUserAtkSpAtk1Or2InSun", "TwoTurnAttackOneTurnInSun") && @battle.field.weather == :Sun
          sum+=5 if pkmn.pbHasMoveFunction?("FreezeTargetAlwaysHitsInHail") 
          sum+=5 if pkmn.pbHasMoveFunction?("StartWeakenDamageAgainstUserSideIfHail", "HealUserDependingOnHail") 
        end
        if pokmon.ability==:ELECTRICSURGE
          sum+=5 if pkmn.item == :ELECTRICSEED
          sum+=10 if pkmn.ability == :SURGESURFER
          pkmn.eachMove do |m|
            next if m.base_damage==0 || m.type != :ELECTRIC
            sum += 5
          end   
          sum+=5 if pkmn.pbHasMoveFunction?("TypeAndPowerDependOnTerrain", "DoublePowerInElectricTerrain")
        end
        if pokmon.ability==:GRASSYSURGE
          sum+=5 if pkmn.item == :GRASSYSEED
          sum+=5 if pkmn.ability == :GRASSPELT
          pkmn.eachMove do |m|
            next if m.base_damage==0 || m.type != :GRASS
            sum += 5
          end   
          sum-=5 if pkmn.pbHasMoveFunction?("DoublePowerIfTargetUnderground", "RandomPowerDoublePowerIfTargetUnderground",
                                              "LowerTargetSpeed1WeakerInGrassyTerrain")
          sum+=5 if pkmn.pbHasMoveFunction?("TypeAndPowerDependOnTerrain", "HealTargetDependingOnGrassyTerrain", "HigherPriorityInGrassyTerrain")
        end
        if pokmon.ability==:MISTYSURGE
          sum+=5 if pkmn.item == :MISTYSEED
          pkmn.eachMove do |m|
            next if m.base_damage==0 || m.type != :DRAGON
            sum -= 5
          end   
          sum-=5 if pkmn.pbHasMoveFunction?("SleepTarget", "SleepTargetIfUserDarkrai", "SleepTargetChangeUserMeloettaForm", 
                                              "ParalyzeTargetIfNotTypeImmune", "BadPoisonTarget")
          sum+=5 if pkmn.pbHasMoveFunction?("TypeAndPowerDependOnTerrain", "UserFaintsPowersUpInMistyTerrainExplosive")
        end
        if pokmon.ability==:PSYCHICSURGE
          sum+=5 if pkmn.item == :PSYCHICSEED
          sum-=5 if pkmn.ability == :PRANKSTER
          pkmn.eachMove do |m|
            next if m.base_damage==0 || m.type != :PSYCHIC
            sum += 5
          end  
          pkmn.eachMove do |m|
            sum -= 1 if m.priority>0
          end   
          sum+=5 if pkmn.pbHasMoveFunction?("TypeAndPowerDependOnTerrain", "HitsAllFoesAndPowersUpInPsychicTerrain")
        end
      end
      if batonpasscheck
        sum-=30 if pokmon.hasActiveAbility?(:WONDERGUARD)
      end  
      pokmon.eachOpposing do |enemy|
        sum*=0.2 if pokmon.hasActiveAbility?(:TRACE) && enemy.hasActiveAbility?([:TRUANT,:SLOWSTART,:DEFEATIST])
        sum*=0.2 if pokmon.hasActiveAbility?(:IMPOSTER) && enemy.hp == 0
      end
      if i==party.length-1
        if sum>0
          sum*=0.7
        else
          sum=-1
        end  
      end  
      hazarddamage=0
      if !pokmon.hasActiveItem?(:HEAVYDUTYBOOTS)
        if pokmon.takesIndirectDamage?
          if !pokmon.airborneAI(false)
            if pokmon.pbOwnSide.effects[PBEffects::Spikes]>0 && pokmon.hasActiveAbility?(:OVERCOAT)
              spikesDiv = [8, 6, 4][pokmon.pbOwnSide.effects[PBEffects::Spikes] - 1]
              hazarddamage += pokmon.totalhp/spikesDiv
            end
            if pokmon.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
              if pokmon.pbHasType?(:POISON) ||
                 pokmon.hasActiveAbility?(:TILEWORKER)
                sum+=5
                sum+=20 if sack && i!=activemon
              elsif pokmon.pbCanPoison?(nil, false)
                hazarddamage += pokmon.totalhp / 8
              end
            end
          end
          if pokmon.pbOwnSide.effects[PBEffects::StealthRock] && pokmon.hasActiveAbility?(:OVERCOAT)
            airdamage = (pokmon.airborneAI(false)) ? 4 : 8
            hazarddamage += (pokmon.totalhp/airdamage)
          end
        end
      end  
      sum=0 if damagetakenPercent>33 && sack && i!=activemon
      if pokmon.hasActiveAbility?(:TILEWORKER)
        if hazarddamage > 0
          sum+=20
          sum=2010 if sack && i!=activemon
        end
      else
        if hazarddamage > pokmon.hp
          sum=0
          sum=2000 if sack && i!=activemon
        end
      end
      #if $consoleenabled
        echo("\nScore after various other factors: "+sum.to_s+"\n") if $AIGENERALLOG
      #end  
      if best == -1 || sum > bestSum
        best = i
        bestSum = sum
      end
    end
    return speedsarray if retvrnspeed
    return [best,bestSum] if batonpasscheck
    return best
  end
end