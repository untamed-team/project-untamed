#===============================================================================
# Revamps base Essentials battle code related to the attack/command phases to
# allow for plugin compatibility.
#===============================================================================


#-------------------------------------------------------------------------------
# Battle mechanics.
#-------------------------------------------------------------------------------
class Battle
  attr_reader :raid_battle
  
  alias dx_initialize initialize
  def initialize(*args)
    @raid_battle = false
    dx_initialize(*args)
    @scriptedMechanics = {}
    if $game_temp.dx_rules?
      @controlPlayer = true if $game_temp.dx_rules[:autobattle]
      if $game_temp.dx_rules.has_key?(:scripted)
        rule = $game_temp.dx_rules[:scripted]
        rule.each do |mechanic, trainers|
          @scriptedMechanics[mechanic] = [
            [false] * (@player ? @player.length : 1),
            [false] * (@opponent ? @opponent.length : 1)
          ]
          trainers.each do |trainer|
            case trainer
            when :Player, :Ally
              side = 0
              case trainer
              when :Player   then owner = 0
              when :Ally     then owner = 1
              end
              next if !@scriptedMechanics[mechanic][side][owner]
              @scriptedMechanics[mechanic][side][owner] = true
            when :PlayerSide, :AllySide
              @player.length.times { |owner| @scriptedMechanics[mechanic][0][owner] = true }
            when :Foe, :FoeAlly, :FoeAlly1, :FoeAlly2
              side = 1
              case trainer
              when :Foe      then owner = 0
              when :FoeAlly  then owner = 1
              when :FoeAlly1 then owner = 1
              when :FoeAlly2 then owner = 2
              end
              next if !@scriptedMechanics[mechanic][side][owner]
              @scriptedMechanics[mechanic][side][owner] = true
            when :FoeSide
              @opponent.length.times { |owner| @scriptedMechanics[mechanic][1][owner] = true }
            end
          end		
        end
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Checks if certain battle mechanics only trigger as part of a scripted battle.
  #-----------------------------------------------------------------------------
  def pbScriptedMechanic?(idxBattler, mechanic)
    return false if !@scriptedMechanics[mechanic]
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @scriptedMechanics[mechanic][side][owner]
  end
  
  #-----------------------------------------------------------------------------
  # Compatibility across multiple plugins.
  #-----------------------------------------------------------------------------
  def pbAttackPhaseZMoves;       end
  def pbAttackPhaseUltraBurst;   end
  def pbAttackPhaseDynamax;      end
  def pbAttackPhaseRaidBoss;     end
  def pbAttackPhaseCheer;        end
  def pbAttackPhaseStyles;       end
  def pbAttackPhaseTerastallize; end
  def pbAttackPhaseZodiacPower;  end
  def pbAttackPhaseFocus;        end

  #-----------------------------------------------------------------------------
  # Tool for resetting a variety of specific battle mechanics.
  #-----------------------------------------------------------------------------
  def pbSetBattleMechanicUsage(idxBattler, mode, set = -2)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    case mode
    when 0, "Mega"    then @megaEvolution[side][owner] = set
    when 1, "Z-Move"  then @zMove[side][owner]         = set
    when 2, "Ultra"   then @ultraBurst[side][owner]    = set
    when 3, "Dynamax" then @dynamax[side][owner]       = set
    when 4, "Style"   then @battleStyle[side][owner]   = set
    when 5, "Tera"    then @terastallize[side][owner]  = set
    when 6, "Zodiac"  then @zodiac[side][owner]        = set
    when 7, "Custom"  then @custom[side][owner]        = set
    end
  end

  #-----------------------------------------------------------------------------
  # Checks if any battle mechanic is usable.
  #-----------------------------------------------------------------------------
  def pbCanUseBattleMechanic?(idxBattler)
    return true if pbCanMegaEvolve?(idxBattler)
    if PluginManager.installed?("ZUD Mechanics")
      return true if pbCanZMove?(idxBattler)
      return true if pbCanUltraBurst?(idxBattler)
      return true if pbCanDynamax?(idxBattler)
    end
    if PluginManager.installed?("PLA Battle Styles")
      return true if pbCanUseStyle?(idxBattler)
    end
    if PluginManager.installed?("Terastal Phenomenon")
      return true if pbCanTerastallize?(idxBattler)
    end
    if PluginManager.installed?("Pokémon Birthsigns")
      return true if pbCanZodiacPower?(idxBattler)
    end
    if PluginManager.installed?("Focus Meter System")
      return true if pbCanUseFocus?(idxBattler)
    end
    return true if pbCanCustom?(idxBattler)
    return false
  end
  
  #-----------------------------------------------------------------------------
  # Aliased for new item flag.
  #-----------------------------------------------------------------------------
  alias zud_pbItemUsesAllActions? pbItemUsesAllActions?
  def pbItemUsesAllActions?(item)
    return true if GameData::Item.get(item).has_flag?("UsesAllBattleActions")
    return zud_pbItemUsesAllActions?(item)
  end
  
  #-----------------------------------------------------------------------------
  # Cancels battle mechanic selections.
  #-----------------------------------------------------------------------------
  def pbCancelChoice(idxBattler)
    if @choices[idxBattler][0] == :UseItem
      item = @choices[idxBattler][1]
      pbReturnUnusedItemToBag(item, idxBattler) if item
    end
    pbUnregisterMegaEvolution(idxBattler)
    if PluginManager.installed?("ZUD Mechanics")
      pbUnregisterUltraBurst(idxBattler)
      if pbRegisteredZMove?(idxBattler)
        pbUnregisterZMove(idxBattler)
        @battlers[idxBattler].power_trigger = false
        @battlers[idxBattler].display_base_moves
      end
      if pbRegisteredDynamax?(idxBattler)
        pbUnregisterDynamax(idxBattler)
        @battlers[idxBattler].power_trigger = false
        @battlers[idxBattler].display_base_moves
      end
    end
    pbUnregisterStyle(idxBattler)        if PluginManager.installed?("PLA Battle Styles")
    pbUnregisterTerastallize(idxBattler) if PluginManager.installed?("Terastal Phenomenon")
    pbUnregisterZodiacPower(idxBattler)  if PluginManager.installed?("Pokémon Birthsigns")
    pbUnregisterFocus(idxBattler)        if PluginManager.installed?("Focus Meter System")
    pbUnregisterCustom(idxBattler)
    pbClearChoice(idxBattler)
  end
  
  #-----------------------------------------------------------------------------
  # Allows the move window to be opened even when Encored if a mechanic is usable.
  #-----------------------------------------------------------------------------
  def pbCanShowFightMenu?(idxBattler)
    battler = @battlers[idxBattler]
    return false if battler.effects[PBEffects::Encore] > 0 && !pbCanUseBattleMechanic?(idxBattler)
    usable = false
    battler.eachMoveWithIndex do |_m, i|
      next if !pbCanChooseMove?(idxBattler, i, false)
      usable = true
      break
    end
    return usable
  end
  
  #-----------------------------------------------------------------------------
  # Considers a variety of battle mechanics during the command phase.
  #-----------------------------------------------------------------------------
  def pbCommandPhase
    @scene.dx_midbattle(nil, nil, "turnCommand", "turnCommand_" + (1 + @turnCount).to_s)
    @scene.pbBeginCommandPhase
    @battlers.each_with_index do |b, i|
      next if !b
      pbClearChoice(i) if pbCanShowCommands?(i)
    end
    2.times do |side|
      @megaEvolution[side].each_with_index do |megaEvo, i|
        @megaEvolution[side][i] = -1 if megaEvo >= 0
      end
      if PluginManager.installed?("ZUD Mechanics")
        @ultraBurst[side].each_with_index do |uBurst, i|
          @ultraBurst[side][i] = -1 if uBurst >= 0
        end
        @zMove[side].each_with_index do |zMove, i|
          @zMove[side][i] = -1 if zMove >= 0
        end
        @dynamax[side].each_with_index do |dmax, i|
          @dynamax[side][i] = -1 if dmax >= 0
        end
      end
      if PluginManager.installed?("PLA Battle Styles")
        @battleStyle[side].each_with_index do |style, i|
          @battleStyle[side][i] = -1 if style >= 0
        end
      end
      if PluginManager.installed?("Terastal Phenomenon")
        @terastallize[side].each_with_index do |tera, i|
          @terastallize[side][i] = -1 if tera >= 0
        end
      end
      if PluginManager.installed?("Pokémon Birthsigns")
        @zodiacPower[side].each_with_index do |zodiac, i|
          @zodiacPower[side][i] = -1 if zodiac >= 0
        end
      end
      if PluginManager.installed?("Focus Meter System")
        @focusMeter[side].each_with_index do |meter, i|
          @focusMeter[side][i] = -1 if meter >= 0
        end
      end
      @custom[side].each_with_index do |custom, i|
        @custom[side][i] = -1 if custom >= 0
      end
    end
    pbCommandPhaseLoop(true)
    return if @decision != 0
    pbCommandPhaseLoop(false)
  end
  
  #-----------------------------------------------------------------------------
  # Ensures certain battle mechanics trigger prior to using Pursuit.
  #-----------------------------------------------------------------------------
  def pbPursuit(idxSwitcher)
    @switching = true
    pbPriority.each do |b|
      next if b.fainted? || !b.opposes?(idxSwitcher)
      next if b.movedThisRound? || !pbChoseMoveFunctionCode?(b.index, "PursueSwitchingFoe")
      next unless pbMoveCanTarget?(b.index, idxSwitcher, @choices[b.index][2].pbTarget(b))
      next unless pbCanChooseMove?(b.index, @choices[b.index][1], false)
      next if b.status == :SLEEP || b.status == :FROZEN
      next if b.effects[PBEffects::SkyDrop] >= 0
      next if b.hasActiveAbility?(:TRUANT) && b.effects[PBEffects::Truant]
      owner = pbGetOwnerIndexFromBattlerIndex(b.index)
      pbMegaEvolve(b.index) if @megaEvolution[b.idxOwnSide][owner] == b.index
      if PluginManager.installed?("ZUD Mechanics")
        pbUltraBurst(b.index) if @ultraBurst[b.idxOwnSide][owner] == b.index
      end
      if PluginManager.installed?("PLA Battle Styles")
        pbBattleStyle(b.index) if @battleStyle[b.idxOwnSide][owner] == b.index
      end
      if PluginManager.installed?("Terastal Phenomenon")
        pbTerastallize(b.index) if @terastallize[b.idxOwnSide][owner] == b.index
      end
      @choices[b.index][3] = idxSwitcher
      b.pbProcessTurn(@choices[b.index], false)
      break if @decision > 0 || @battlers[idxSwitcher].fainted?
    end
    @switching = false
  end
  
  #-----------------------------------------------------------------------------
  # Considers a variety of battle mechanics during the attack phase.
  #-----------------------------------------------------------------------------
  def pbAttackPhase
    @scene.pbBeginAttackPhase
    @scene.dx_midbattle(nil, nil, "turnAttack", "turnAttack_" + (1 + @turnCount).to_s)
    @battlers.each_with_index do |b, i|
      next if !b
      b.turnCount += 1 if !b.fainted?
      @successStates[i].clear
      if @choices[i][0] != :UseMove && @choices[i][0] != :Shift && @choices[i][0] != :SwitchOut
        b.effects[PBEffects::DestinyBond] = false
        b.effects[PBEffects::Grudge]      = false
      end
      b.effects[PBEffects::Rage] = false if !pbChoseMoveFunctionCode?(i, "StartRaiseUserAtk1WhenDamaged")	  
    end
    PBDebug.log("")
    pbCalculatePriority(true)
    pbAttackPhaseFocus
    pbAttackPhasePriorityChangeMessages
    pbAttackPhaseCall
    pbAttackPhaseZodiacPower
    pbAttackPhaseSwitch
    return if @decision > 0
    pbAttackPhaseItems
    return if @decision > 0
    pbAttackPhaseMegaEvolution
    pbAttackPhaseUltraBurst
    pbAttackPhaseZMoves
    pbAttackPhaseDynamax
    pbAttackPhaseTerastallize
    pbAttackPhaseCustom
    pbAttackPhaseStyles
    pbAttackPhaseRaidBoss
    pbAttackPhaseCheer
    pbAttackPhaseMoves
  end
end


#-------------------------------------------------------------------------------
# Command window compatibility.
#-------------------------------------------------------------------------------
class Battle::Scene
  def pbCommandMenuEx(idxBattler, texts, mode = 0)
    #has_info  = PluginManager.installed?("Enhanced UI")
    #edited by Gardenette
    has_info  = true
    can_focus = PluginManager.installed?("Focus Meter System")
    pbShowWindow(COMMAND_BOX)
    cw = @sprites["commandWindow"]
    cw.setTexts(texts)
    cw.setIndexAndMode(@lastCmd[idxBattler], mode)
    pbSelectBattler(idxBattler)
    ret = -1
    
    #added by Gardenette
    if !$tips_log.get_log.include?("Battle Info") && $game_variables[27] >= 9 #show only after rival battle
      $tips_log.tipBattleInfo
    end
    
    loop do
      oldIndex = cw.index
      pbUpdate(cw)
      if Input.trigger?(Input::LEFT)
        cw.index -= 1 if (cw.index & 1) == 1
      elsif Input.trigger?(Input::RIGHT)
        cw.index += 1 if (cw.index & 1) == 0
      elsif Input.trigger?(Input::UP)
        cw.index -= 2 if (cw.index & 2) == 2
      elsif Input.trigger?(Input::DOWN)
        cw.index += 2 if (cw.index & 2) == 0
      end
      pbPlayCursorSE if cw.index != oldIndex
      if Input.trigger?(Input::USE)
        pbPlayDecisionSE
        ret = cw.index
        @lastCmd[idxBattler] = ret
        pbHidePluginUI if can_focus && ret > 0
        break
      elsif Input.trigger?(Input::BACK) && mode > 0
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::F9) && $DEBUG
        pbPlayDecisionSE
        pbHidePluginUI
        ret = -2
        break
      #elsif has_info && Input.triggerex?(Settings::BATTLE_INFO_KEY)
      #modified by Gardenette
      elsif has_info && Input.trigger?(Settings::BATTLE_INFO_KEY)
        pbHideFocusPanel
        pbToggleBattleInfo
      elsif can_focus && Input.triggerex?(Settings::FOCUS_PANEL_KEY)
        pbHideBattleInfo
        pbToggleFocusPanel
      end
    end
    return ret
  end
end


#-------------------------------------------------------------------------------
# AI Battlers consider a variety of battle mechanics.
#-------------------------------------------------------------------------------
class Battle::AI
  def pbDefaultChooseEnemyCommand(idxBattler)
    return if pbEnemyShouldUseItem?(idxBattler)
    return if pbEnemyShouldWithdraw?(idxBattler) # old switching method
		#~ return if pbShouldSwitch?(idxBattler) #messy switching method
    return if @battle.pbAutoFightMenu(idxBattler)
    @battle.pbRegisterMegaEvolution(idxBattler) if pbEnemyShouldMegaEvolve?(idxBattler)
    if PluginManager.installed?("ZUD Mechanics")
      @battle.pbRegisterUltraBurst(idxBattler) if pbEnemyShouldUltraBurst?(idxBattler)
      @battle.pbRegisterDynamax(idxBattler) if pbEnemyShouldDynamax?(idxBattler)
    end
    if PluginManager.installed?("Terastal Phenomenon")
      @battle.pbRegisterTerastallize(idxBattler) if pbEnemyShouldTerastallize?(idxBattler)
    end
    if PluginManager.installed?("Pokémon Birthsigns")
      @battle.pbRegisterZodiacPower(idxBattler) if pbEnemyShouldZodiacPower?(idxBattler)
    end
    if PluginManager.installed?("Focus Meter System")
      @battle.pbRegisterFocus(idxBattler) if pbEnemyShouldFocus?(idxBattler)
    end
    if !@battle.pbScriptedMechanic?(idxBattler, :custom) && pbEnemyShouldCustom?(idxBattler)
      @battle.pbRegisterCustom(idxBattler)
    end
    pbChooseMoves(idxBattler)
    if PluginManager.installed?("PLA Battle Styles") # Purposefully set after move selection.
      @battle.pbRegisterStyle(idxBattler) if pbEnemyShouldUseStyle?(idxBattler)
    end
  end
end