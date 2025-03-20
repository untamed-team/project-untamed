# selects trainer teams  = $player.difficulty
# selects game mechanics = $player.mechanics
ItemCAP = 3

class Player < Trainer
  attr_accessor :difficulty
  attr_accessor :mechanics
  alias initialize_diff initialize
  def initialize(name, trainer_type)
    initialize_diff(name, trainer_type)
    super
    @difficulty = 0
    @mechanics  = 0
  end

  def difficulty_mode?(mode)
    case mode.downcase
    when "easy"
      return true if @difficulty == 0 && @mechanics == 0
    when "normal"
      return true if @difficulty == 0 && @mechanics >= 1
    when "hard"
      return true if @difficulty >= 1 && @mechanics >= 2
    when "chaos"
      return true if @difficulty >= 2 && @mechanics >= 3
    else
      return false
    end
  end
end

def pbUpdatePBSFilesForDifficulty(thing = false)
  if $player.difficulty_mode?("chaos") # Hard / "Low" mode
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
          if @internalBattle && (@switchStyle && $player.difficulty_mode?("easy")) && #edits #by low
             trainerBattle? && pbSideSize(0) == 1 && opposes?(idxBattler) && 
             !@battlers[0].fainted? && !switched.include?(0) &&
             pbCanChooseNonActive?(0) && @battlers[0].effects[PBEffects::Outrage] == 0 &&
            idxPartyForName = idxPartyNew
            enemyParty = pbParty(idxBattler)
            if enemyParty[idxPartyNew].ability == :ILLUSION && !pbCheckGlobalAbility(:NEUTRALIZINGGAS)
              new_index = pbLastInTeam(idxBattler)
              idxPartyForName = new_index if new_index >= 0 && new_index != idxPartyNew
            end
            unless isWildBoss?(opponent)
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
      if !@controlPlayer && pbOwnedByPlayer?(idxBattler)
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
            if $player.difficulty_mode?("normal") && @numberOfUsedItems[idxBattler % 2] >= ItemCAP && @opponent
              pbDisplay(_INTL("But {1} items have already been used in this Trainer Battle!", ItemCAP))
            elsif $player.difficulty_mode?("hard") && @opponent
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
      else
        # DemICE moved the AI decision after player decision.
        # AI controls this battler
        @battleAI.pbDefaultChooseEnemyCommand(idxBattler)
        next
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
      next if battler.status != :POISON || battler.fainted? || battler.hasActiveAbility?(:TOXICBOOST) #by low
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
          if $player.difficulty_mode?("chaos") #by low
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
      battler.pbCureStatus if battler.statusCount <= 0
    end
    # paralyzis rework #by low
    priority.each do |battler|
      next if battler.status != :PARALYSIS
      next if !$player.difficulty_mode?("chaos")
      battler.statusCount -= 1
      battler.pbCureStatus if battler.statusCount <= 0
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

    @sprites["overlay"].x = @sprites["bg"].x
    @sprites["overlay"].y = @sprites["bg"].y
    @sprites["overlay"].z = 99999

    page = 1
    drawPage(page)

    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def drawPage(page)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = MessageConfig::LIGHT_TEXT_MAIN_COLOR
    shadow = MessageConfig::LIGHT_TEXT_SHADOW_COLOR
    overlay.font.size = 22

    difficulty_desc = [
      "The typical main series Pokémon experience.\n\nMinor Pokémon, move, ability, type, and battle feature adjustments have been made, along with other changes to the typical format.\nCheck the Project Untamed Wiki for more changes.",
      "Casual mode with some extra limitations for added difficulty.\n\n-Experience has diminishing returns\n-Only 10 items allowed per trainer battle\n-Select limited number of Pokémon for gym battles\nCheck the Project Untamed Wiki for more changes.",
      "For expert trainers looking for a challenge.\n\n-More difficult trainers\n-Experience caps\n-No items in battle\n-Set style enforced\nCheck the Project Untamed Wiki for more changes.",
      "Chaos Mode is a rebalanced gamemode that differs from the intended experience. We do not recommend it for a first playthrough.\n\n-Major Pokemon stats, abilities, learnset, distribution differences.\n-Certain move and battle features changed or removed.\n-New gimmicks (Type Zones, AAM, etc.)\n-Completely overhauled trainers.\nCheck Chaos Codex ingame for more Info."
    ]
    @sprites["bg"].setBitmap(_INTL("Graphics/Pictures/difficulty_select_#{page - 1}"))
    difficultyDesc = _INTL(difficulty_desc[page - 1])

    #difficulty name, always present
    drawFormattedTextEx(bitmap=overlay, x=52, y=52, width=overlay.width-58, text=_INTL("Casual"), baseColor=base, shadowColor=shadow, lineheight=16)
    drawFormattedTextEx(bitmap=overlay, x=122, y=52, width=overlay.width-58, text=_INTL("Normal"), baseColor=base, shadowColor=shadow, lineheight=16)
    drawFormattedTextEx(bitmap=overlay, x=198, y=52, width=overlay.width-58, text=_INTL("Hard"), baseColor=base, shadowColor=shadow, lineheight=16)
    drawFormattedTextEx(bitmap=overlay, x=260, y=52, width=overlay.width-58, text=_INTL("Chaos"), baseColor=base, shadowColor=shadow, lineheight=16)

    # fs = font size
    difficultyDesc = "<fs=24><al>" + difficultyDesc + "</al></fs>"
    #difficulty description, changes per page
    drawFormattedTextEx(bitmap=overlay, x=64, y=88, width=overlay.width-120, text=difficultyDesc, baseColor=base, shadowColor=shadow, lineheight=20)
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
            $player.mechanics=0
            $player.difficulty=0
            enditall=true
          end
        when 2   # normal
          if @scene.pbConfirm(_INTL("Are you sure? This cannot be altered during gameplay."))
            $player.mechanics=1
            $player.difficulty=0
            enditall=true
          end
        when 3   # hard
          if @scene.pbConfirm(_INTL("Are you sure? This cannot be altered during gameplay."))
            $player.mechanics=2
            $player.difficulty=1
            enditall=true
          end
        when 4   # meme
          if @scene.pbConfirm(_INTL("Are you sure? This cannot be altered during gameplay."))
            $player.mechanics=3
            $player.difficulty=2
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