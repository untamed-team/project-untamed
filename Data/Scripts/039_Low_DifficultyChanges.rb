#this script isnt made by only me but i wanted to keep organized
#ty garden for the work

#added by Low for selecting trainer teams
DIFFICULTYVAR = 100
#added by Gardenette for selecting game mechanics in intro (vanilla, rebalanced, low mode)
MECHANICSVAR = 101

def pbUpdatePBSFilesForDifficulty(thing = false)
	if $game_variables[MECHANICSVAR] >= 3 # Hard / "Low" mode
		print _INTL("Updating files...") if thing
		Compiler.compile_moves("PBS/moves_2.txt")
		Compiler.compile_items # here for dependances
		Compiler.compile_pokemon("PBS/pokemon_2.txt")
		Compiler.compile_pokemon_forms("PBS/pokemon_forms_2.txt")
		Compiler.compile_encounters("PBS/encounters_2.txt")
	else
		print _INTL("Updating files...") if thing
		Compiler.compile_moves
		Compiler.compile_items # here for dependances
		Compiler.compile_pokemon
		Compiler.compile_pokemon_forms
		Compiler.compile_encounters
	end
end

class Battle
  #=============================================================================
  # Switching Pokémon
  #=============================================================================
  # General switching method that checks if any Pokémon need to be sent out and,
  # if so, does. Called at the end of each round.
  def pbEORSwitch(favorDraws = false)
    return if @decision > 0 && !favorDraws
    return if @decision == 5 && favorDraws
    pbJudge
    return if @decision > 0
    # Check through each fainted battler to see if that spot can be filled.
    switched = []
    loop do
      switched.clear
      @battlers.each do |b|
        next if !b || !b.fainted?
        idxBattler = b.index
        next if !pbCanChooseNonActive?(idxBattler)
        if !pbOwnedByPlayer?(idxBattler)   # Opponent/ally is switching in
          next if b.wild?   # Wild Pokémon can't switch
          idxPartyNew = pbSwitchInBetween(idxBattler)
          opponent = pbGetOwnerFromBattlerIndex(idxBattler)
          # NOTE: The player is only offered the chance to switch their own
          #       Pokémon when an opponent replaces a fainted Pokémon in single
          #       battles. In double battles, etc. there is no such offer.
          if @internalBattle && (@switchStyle && $game_variables[MECHANICSVAR] <= 2) && #edits #by low
						 trainerBattle? && pbSideSize(0) == 1 && opposes?(idxBattler) && 
						 !@battlers[0].fainted? && !switched.include?(0) &&
             pbCanChooseNonActive?(0) && @battlers[0].effects[PBEffects::Outrage] == 0 &&
            idxPartyForName = idxPartyNew
            enemyParty = pbParty(idxBattler)
            if enemyParty[idxPartyNew].ability == :ILLUSION && !pbCheckGlobalAbility(:NEUTRALIZINGGAS)
              new_index = pbLastInTeam(idxBattler)
              idxPartyForName = new_index if new_index >= 0 && new_index != idxPartyNew
            end
            if pbDisplayConfirm(_INTL("{1} is about to send out {2}. Will you switch your Pokémon?",
                                      opponent.full_name, enemyParty[idxPartyForName].name))
              idxPlayerPartyNew = pbSwitchInBetween(0, false, true)
              if idxPlayerPartyNew >= 0
                pbMessageOnRecall(@battlers[0])
                pbRecallAndReplace(0, idxPlayerPartyNew)
                switched.push(0)
              end
            end
          end
          pbRecallAndReplace(idxBattler, idxPartyNew)
          switched.push(idxBattler)
        elsif trainerBattle?   # Player switches in in a trainer battle
          idxPlayerPartyNew = pbGetReplacementPokemonIndex(idxBattler)   # Owner chooses
          pbRecallAndReplace(idxBattler, idxPlayerPartyNew)
          switched.push(idxBattler)
        else   # Player's Pokémon has fainted in a wild battle
          switch = false
          if pbDisplayConfirm(_INTL("Use next Pokémon?"))
            switch = true
          else
            switch = (pbRun(idxBattler, true) <= 0)
          end
          if switch
            idxPlayerPartyNew = pbGetReplacementPokemonIndex(idxBattler)   # Owner chooses
            pbRecallAndReplace(idxBattler, idxPlayerPartyNew)
            switched.push(idxBattler)
          end
        end
      end
      break if switched.length == 0
      pbOnBattlerEnteringBattle(switched)
    end
  end
  
	
	def pbCommandPhaseLoop(isPlayer)
    # NOTE: Doing some things (e.g. running, throwing a Poké Ball) takes up all
    #       your actions in a round.
    actioned = []
    idxBattler = -1
    loop do
      break if @decision != 0   # Battle ended, stop choosing actions
      idxBattler += 1
      break if idxBattler >= @battlers.length
      next if !@battlers[idxBattler] || pbOwnedByPlayer?(idxBattler) != isPlayer
      next if @choices[idxBattler][0] != :None    # Action is forced, can't choose one
      next if !pbCanShowCommands?(idxBattler)   # Action is forced, can't choose one
      # AI controls this battler
      if @controlPlayer || !pbOwnedByPlayer?(idxBattler)
        @battleAI.pbDefaultChooseEnemyCommand(idxBattler)
        next
      end
      # Player chooses an action
      actioned.push(idxBattler)
      commandsEnd = false   # Whether to cancel choosing all other actions this round
      loop do
        cmd = pbCommandMenu(idxBattler, actioned.length == 1)
        # If being Sky Dropped, can't do anything except use a move
        if cmd > 0 && @battlers[idxBattler].effects[PBEffects::SkyDrop] >= 0
          pbDisplay(_INTL("Sky Drop won't let {1} go!", @battlers[idxBattler].pbThis(true)))
          next
        end
        case cmd
        when 0    # Fight
          break if pbFightMenu(idxBattler)
        when 1    # Bag
					# items ban #by low
					if $game_variables[MECHANICSVAR] == 1 && $game_variables[MAXITEMSVAR]>=3 && @opponent
						pbDisplay(_INTL("But 3 items have already been used in this Trainer Battle!"))
					elsif $game_variables[MECHANICSVAR] >= 2 && @opponent
						pbDisplay(_INTL("Items are banned during Trainer Battles."))
					else
						if pbItemMenu(idxBattler, actioned.length == 1)
							commandsEnd = true if pbItemUsesAllActions?(@choices[idxBattler][1])
							break
						end
          end
        when 2    # Pokémon
          break if pbPartyMenu(idxBattler)
        when 3    # Run
          # NOTE: "Run" is only an available option for the first battler the
          #       player chooses an action for in a round. Attempting to run
          #       from battle prevents you from choosing any other actions in
          #       that round.
          if pbRunMenu(idxBattler)
            commandsEnd = true
            break
          end
        when 4    # Call
          break if pbCallMenu(idxBattler)
        when -2   # Debug
          pbDebugMenu
          next
        when -1   # Go back to previous battler's action choice
          next if actioned.length <= 1
          actioned.pop   # Forget this battler was done
          idxBattler = actioned.last - 1
          pbCancelChoice(idxBattler + 1)   # Clear the previous battler's choice
          actioned.pop   # Forget the previous battler was done
          break
        end
        pbCancelChoice(idxBattler)
      end
      break if commandsEnd
    end
  end
  
	#=============================================================================
  # End Of Round deal damage from status problems
  #=============================================================================
  def pbEORStatusProblemDamage(priority)
    # Damage from poisoning
    priority.each do |battler|
      next if battler.fainted?
      next if battler.status != :POISON
      next if battler.hasActiveAbility?(:TOXICBOOST) #by low
      if battler.statusCount > 0
        battler.effects[PBEffects::Toxic] += 1
        battler.effects[PBEffects::Toxic] = 16 if battler.effects[PBEffects::Toxic] > 16
      end
      if battler.hasActiveAbility?(:POISONHEAL)
        if battler.canHeal?
          anim_name = GameData::Status.get(:POISON).animation
          pbCommonAnimation(anim_name, battler) if anim_name
          pbShowAbilitySplash(battler)
          battler.pbRecoverHP(battler.totalhp / 8)
          if Scene::USE_ABILITY_SPLASH
            pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
          else
            pbDisplay(_INTL("{1}'s {2} restored its HP.", battler.pbThis, battler.abilityName))
          end
          pbHideAbilitySplash(battler)
        end
      elsif battler.takesIndirectDamage?
        battler.droppedBelowHalfHP = false
        dmg = battler.totalhp / 8
				if battler.statusCount > 0
					if $game_variables[MECHANICSVAR] >= 3 #by low
						if battler.effects[PBEffects::Toxic] > 2
							dmg = battler.totalhp / 4
							battler.effects[PBEffects::Toxic] = 0
							battler.statusCount = 2 #for "pbContinueStatus" to say a different message
							#~ print "super damage"
						end
					else
						dmg = battler.totalhp * battler.effects[PBEffects::Toxic] / 16
					end
				end
        battler.pbContinueStatus { battler.pbReduceHP(dmg, false) }
        battler.pbItemHPHealCheck
        battler.pbAbilitiesOnDamageTaken
        battler.pbFaint if battler.fainted?
        battler.droppedBelowHalfHP = false
      end
    end
    # Damage from burn
    priority.each do |battler|
      next if battler.status != :BURN || !battler.takesIndirectDamage? || battler.hasActiveAbility?(:FLAREBOOST) #by low
      battler.droppedBelowHalfHP = false
      dmg = (Settings::MECHANICS_GENERATION >= 7) ? battler.totalhp / 16 : battler.totalhp / 8
      dmg = (dmg / 2.0).round if battler.hasActiveAbility?(:HEATPROOF)
      battler.pbContinueStatus { battler.pbReduceHP(dmg, false) }
      battler.pbItemHPHealCheck
      battler.pbAbilitiesOnDamageTaken
      battler.pbFaint if battler.fainted?
      battler.droppedBelowHalfHP = false
    end
    # Damage from frostbite #by low
    priority.each do |battler|
      next if battler.status != :FROZEN || !battler.takesIndirectDamage?
      battler.droppedBelowHalfHP = false
      dmg = (Settings::MECHANICS_GENERATION >= 7) ? battler.totalhp / 16 : battler.totalhp / 8
      dmg = (dmg / 2.0).round if battler.hasActiveAbility?(:THICKFAT)
      battler.pbContinueStatus { battler.pbReduceHP(dmg, false) }
      battler.pbItemHPHealCheck
      battler.pbAbilitiesOnDamageTaken
      battler.pbFaint if battler.fainted?
      battler.droppedBelowHalfHP = false
    end
		# dizzy #by low
    priority.each do |battler|
      next if battler.status != :DIZZY
      battler.statusCount -= 1
      if battler.statusCount <= 0
        battler.pbCureStatus
      else
				battler.pbContinueStatus
			end
    end
		# paralyzis rework #by low
    priority.each do |battler|
      next if battler.status != :PARALYSIS
      next if $game_variables[MECHANICSVAR] < 3
      battler.statusCount -= 1
      battler.pbCureStatus if battler.statusCount <= 0
    end
  end
	
  def pbGainExpOne(idxParty, defeatedBattler, numPartic, expShare, expAll, showMessages = true)
    pkmn = pbParty(0)[idxParty]   # The Pokémon gaining Exp from defeatedBattler
    growth_rate = pkmn.growth_rate
		if defeatedBattler.isSpecies?(:PHYTIDE) && pkmn.isSpecies?(:PHYTIDE) # Phytide evolution method
			pkmn.evolution_steps += 1
		end
    # Don't bother calculating if gainer is already at max Exp
    if pkmn.exp >= growth_rate.maximum_exp
      pkmn.calc_stats   # To ensure new EVs still have an effect
      return
    end
    isPartic    = defeatedBattler.participants.include?(idxParty)
    hasExpShare = expShare.include?(idxParty)
    level = defeatedBattler.level
    exp = 0
		if !expAll # if someone has exp leech
			haveexpshare = numPartic # number of mons with exp leech
		else
			haveexpshare = 1	
		end
    a = level * defeatedBattler.pokemon.base_exp
		exp = (a/defeatedBattler.participants.length).floor * haveexpshare
    return if exp <= 0
		# level cap #by low
		truelevel = defeatedBattler.level															# stuff
		truelevel -= 10 if $game_variables[MASTERMODEVARS][7]==true		# for
		truelevel -= 20 if $game_variables[MASTERMODEVARS][22]==true	# master
		truelevel -= 30 if $game_variables[MASTERMODEVARS][24]==true	# mode
		truelevel -= 60 if $game_variables[MASTERMODEVARS][27]==true	# settings
		exp = (exp / 3).floor
		expvariable = ($game_switches[LOWEREXPGAINSWITCH]) ? 50 : 33
		exp = (exp * (100 + expvariable * (truelevel - pkmn.level)) / 100).floor
		exp = 0 if pkmn.level - truelevel == 3
		exp = (exp / 2).floor if pkmn.level>40
		#exp = (exp * 0.2).floor if $game_switches[319] 				# custom wild
		#exp = 0 if $game_switches[305] && pkmn.level>=level 		# leader rematch
		# exp leech #by low
		if !expAll
			# exp is multiplied by (number of allies in party) / (number of allies with exp leech) 
			# 100.0 so we get some not round numbers
			exp *= ((defeatedBattler.participants.length)*100)/(numPartic*100.0)
		end
    return if exp <= 0
    expFinal = growth_rate.add_exp(pkmn.exp, exp)
    expGained = expFinal - pkmn.exp
    return if expGained <= 0
    # "Exp gained" message
    pbDisplayPaused(_INTL("{1} got {2} Exp. Points!", pkmn.name, expGained)) if showMessages && !$game_switches[101]
    curLevel = pkmn.level
    newLevel = growth_rate.level_from_exp(expFinal)
    if newLevel < curLevel
      debugInfo = "Levels: #{curLevel}->#{newLevel} | Exp: #{pkmn.exp}->#{expFinal} | gain: #{expGained}"
      raise _INTL("{1}'s new level is less than its\r\ncurrent level, which shouldn't happen.\r\n[Debug: {2}]",
                  pkmn.name, debugInfo)
    end
    # Give Exp
    if pkmn.shadowPokemon?
      if pkmn.heartStage <= 3
        pkmn.exp += expGained
        $stats.total_exp_gained += expGained
      end
      return
    end
    $stats.total_exp_gained += expGained
    tempExp1 = pkmn.exp
    battler = pbFindBattler(idxParty)
    loop do   # For each level gained in turn...
      # EXP Bar animation
      levelMinExp = growth_rate.minimum_exp_for_level(curLevel)
      levelMaxExp = growth_rate.minimum_exp_for_level(curLevel + 1)
      tempExp2 = (levelMaxExp < expFinal) ? levelMaxExp : expFinal
      pkmn.exp = tempExp2
      @scene.pbEXPBar(battler, levelMinExp, levelMaxExp, tempExp1, tempExp2)
      tempExp1 = tempExp2
      curLevel += 1
      if curLevel > newLevel
        # Gained all the Exp now, end the animation
        pkmn.calc_stats
        battler&.pbUpdate(false)
        @scene.pbRefreshOne(battler.index) if battler
        break
      end
      # Levelled up
      pbCommonAnimation("LevelUp", battler) if battler
      oldTotalHP = pkmn.totalhp
      oldAttack  = pkmn.attack
      oldDefense = pkmn.defense
      oldSpAtk   = pkmn.spatk
      oldSpDef   = pkmn.spdef
      oldSpeed   = pkmn.speed
      if battler&.pokemon
        battler.pokemon.changeHappiness("levelup")
      end
      pkmn.calc_stats
      battler&.pbUpdate(false)
      @scene.pbRefreshOne(battler.index) if battler
      pbDisplayPaused(_INTL("{1} grew to Lv. {2}!", pkmn.name, curLevel))
      @scene.pbLevelUp(pkmn, battler, oldTotalHP, oldAttack, oldDefense,
                       oldSpAtk, oldSpDef, oldSpeed)
      # Learn all moves learned at this level
      moveList = pkmn.getMoveList
      moveList.each { |m| pbLearnMove(idxParty, m[1]) if m[0] == curLevel }
    end
  end
end # of class Battle

################################################################################
# diff select v.dos
# quite sloppy but hey, it works
################################################################################

def pbDifficultySelectScreen
  retval = true
  pbFadeOutIn {
    scene = DifficultySelectMenu_Scene.new
    screen = DifficultySelectMenuScreen.new(scene)
    retval = screen.pbStartScreen
  }
  return retval
end

class DifficultySelectMenu_Scene
  def pbDisplay(msg, brief = false)
    UIHelper.pbDisplay(@sprites["msgwindow"], msg, brief) { pbUpdate }
  end
	
  def pbConfirm(msg)
    UIHelper.pbConfirm(@sprites["msgwindow"], msg) { pbUpdate }
  end
	
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end
	
  def pbStartScene
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["bg"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg"].setBitmap("Graphics/Pictures/difficulty_select_0")
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["msgwindow"] = Window_AdvancedTextPokemon.new("")
    @sprites["msgwindow"].visible = false
    @sprites["msgwindow"].viewport = @viewport
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def drawPage(page)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
		# this could be more compact but whatever im gonna pull a yandev
    case page
    when 1 
			@sprites["bg"].setBitmap(_INTL("Graphics/Pictures/difficulty_select_0"))
    when 2 
			@sprites["bg"].setBitmap(_INTL("Graphics/Pictures/difficulty_select_1"))
    when 3 
			@sprites["bg"].setBitmap(_INTL("Graphics/Pictures/difficulty_select_2"))
    when 4 
			@sprites["bg"].setBitmap(_INTL("Graphics/Pictures/difficulty_select_3"))
    end
  end
	
  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

class DifficultySelectMenuScreen
  def initialize(scene)
    @scene = scene
  end
	
  def pbStartScreen
    @scene.pbStartScene
		@page = 1
    loop do
      Graphics.update
      Input.update
      @scene.pbUpdate
      dorefresh = false
      enditall = false
      if Input.trigger?(Input::USE)
        case @page
        when 1   # casual
					if @scene.pbConfirm(_INTL("Are you sure? This cannot be altered during gameplay."))
						$game_variables[MECHANICSVAR]=0
						$game_variables[DIFFICULTYVAR]=0
						enditall=true
					end
        when 2   # normal
					if @scene.pbConfirm(_INTL("Are you sure? This cannot be altered during gameplay."))
						$game_variables[MECHANICSVAR]=1
						$game_variables[DIFFICULTYVAR]=0
						enditall=true
					end
        when 3   # hard
					if @scene.pbConfirm(_INTL("Are you sure? This cannot be altered during gameplay."))
						$game_variables[MECHANICSVAR]=2
						$game_variables[DIFFICULTYVAR]=1
						enditall=true
					end
        when 4   # meme
					if @scene.pbConfirm(_INTL("Are you sure? This cannot be altered during gameplay."))
						$game_variables[MECHANICSVAR]=3
						$game_variables[DIFFICULTYVAR]=1
						enditall=true
					end
        end
				if enditall
					@scene.pbDisplay(_INTL("Updating files..."), true)
					pbUpdatePBSFilesForDifficulty#(true)
					@scene.pbEndScene
					break
				end
      elsif Input.trigger?(Input::LEFT)
        oldpage = @page
        @page -= 1
        @page = 4 if @page < 1
        @page = 1 if @page > 4
        if @page != oldpage
          pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.trigger?(Input::RIGHT)
        oldpage = @page
        @page += 1
        @page = 4 if @page < 1
        @page = 1 if @page > 4
        if @page != oldpage
          pbPlayCursorSE
          dorefresh = true
        end
      end
      if dorefresh
        @scene.drawPage(@page)
      end
    end
    return @index
	end
end