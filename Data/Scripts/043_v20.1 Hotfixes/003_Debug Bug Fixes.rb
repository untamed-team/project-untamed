#===============================================================================
# "v20.1 Hotfixes" plugin
# This file contains fixes for bugs in Debug features in Essentials v20.1.
# These bug fixes are also in the dev branch of the GitHub version of
# Essentials:
# https://github.com/Maruno17/pokemon-essentials
#===============================================================================

#===============================================================================
# Fixed mispositioning of text in Debug features that edit Game Switches and
# Game Variables.
#===============================================================================
class SpriteWindow_DebugVariables < Window_DrawableCommand
  def shadowtext(x, y, w, h, t, align = 0, colors = 0)
    width = self.contents.text_size(t).width
    case align
    when 1   # Right aligned
      x += (w - width)
    when 2   # Centre aligned
      x += (w / 2) - (width / 2)
    end
    y += 8   # TEXT OFFSET
    base = Color.new(12 * 8, 12 * 8, 12 * 8)
    case colors
    when 1   # Red
      base = Color.new(168, 48, 56)
    when 2   # Green
      base = Color.new(0, 144, 0)
    end
    pbDrawShadowText(self.contents, x, y, [width, w].max, h, t, base, Color.new(26 * 8, 26 * 8, 25 * 8))
  end
end

#===============================================================================
# Fixed error messages appearing in the console because of some script switches
# in the "Switches" debug feature.
#===============================================================================
class SpriteWindow_DebugVariables < Window_DrawableCommand
  def drawItem(index, _count, rect)
    pbSetNarrowFont(self.contents)
    colors = 0
    codeswitch = false
    if @mode == 0
      name = $data_system.switches[index + 1]
      codeswitch = (name[/^s\:/])
      if codeswitch
        code = $~.post_match
        code_parts = code.split(/[(\[=<>. ]/)
        code_parts[0].strip!
        code_parts[0].gsub!(/^\s*!/, "")
        val = nil
        if code_parts[0][0].upcase == code_parts[0][0] &&
           (Kernel.const_defined?(code_parts[0]) rescue false)
          val = (eval(code) rescue nil)   # Code starts with a class/method name
        elsif code_parts[0][0].downcase == code_parts[0][0] &&
           !(Interpreter.method_defined?(code_parts[0].to_sym) rescue false) &&
           !(Game_Event.method_defined?(code_parts[0].to_sym) rescue false)
          val = (eval(code) rescue nil)   # Code starts with a method name (that isn't in Interpreter/Game_Event)
        end
      else
        val = $game_switches[index + 1]
      end
      if val.nil?
        status = "[-]"
        colors = 0
        codeswitch = true
      elsif val   # true
        status = "[ON]"
        colors = 2
      else   # false
        status = "[OFF]"
        colors = 1
      end
    else
      name = $data_system.variables[index + 1]
      status = $game_variables[index + 1].to_s
      status = "\"__\"" if nil_or_empty?(status)
    end
    name ||= ""
    id_text = sprintf("%04d:", index + 1)
    rect = drawCursor(index, rect)
    totalWidth = rect.width
    idWidth     = totalWidth * 15 / 100
    nameWidth   = totalWidth * 65 / 100
    statusWidth = totalWidth * 20 / 100
    self.shadowtext(rect.x, rect.y, idWidth, rect.height, id_text)
    self.shadowtext(rect.x + idWidth, rect.y, nameWidth, rect.height, name, 0, (codeswitch) ? 1 : 0)
    self.shadowtext(rect.x + idWidth + nameWidth, rect.y, statusWidth, rect.height, status, 1, colors)
  end
end

#===============================================================================
# The advanced battle-starting Debug functions now run encounter/trainer
# modifier code on the Pokémon/trainers.
#===============================================================================
MenuHandlers.add(:debug_menu, :test_wild_battle_advanced, {
  "name"        => _INTL("Test Wild Battle Advanced"),
  "parent"      => :battle_menu,
  "description" => _INTL("Start a battle against 1 or more wild Pokémon. Battle size is your choice."),
  "effect"      => proc {
    pkmn = []
    size0 = 1
    pkmnCmd = 0
    loop do
      pkmnCmds = []
      pkmn.each { |p| pkmnCmds.push(sprintf("%s Lv.%d", p.name, p.level)) }
      pkmnCmds.push(_INTL("[Add Pokémon]"))
      pkmnCmds.push(_INTL("[Set player side size]"))
      pkmnCmds.push(_INTL("[Start {1}v{2} battle]", size0, pkmn.length))
      pkmnCmd = pbShowCommands(nil, pkmnCmds, -1, pkmnCmd)
      break if pkmnCmd < 0
      if pkmnCmd == pkmnCmds.length - 1      # Start battle
        if pkmn.length == 0
          pbMessage(_INTL("No Pokémon were chosen, cannot start battle."))
          next
        end
        setBattleRule(sprintf("%dv%d", size0, pkmn.length))
        setBattleRule("canLose")
        $game_temp.encounter_type = nil
        WildBattle.start(*pkmn)
        break
      elsif pkmnCmd == pkmnCmds.length - 2   # Set player side size
        if !pbCanDoubleBattle?
          pbMessage(_INTL("You only have one Pokémon."))
          next
        end
        maxVal = (pbCanTripleBattle?) ? 3 : 2
        params = ChooseNumberParams.new
        params.setRange(1, maxVal)
        params.setInitialValue(size0)
        params.setCancelValue(0)
        newSize = pbMessageChooseNumber(
          _INTL("Choose the number of battlers on the player's side (max. {1}).", maxVal), params
        )
        size0 = newSize if newSize > 0
      elsif pkmnCmd == pkmnCmds.length - 3   # Add Pokémon
        species = pbChooseSpeciesList
        if species
          params = ChooseNumberParams.new
          params.setRange(1, GameData::GrowthRate.max_level)
          params.setInitialValue(5)
          params.setCancelValue(0)
          level = pbMessageChooseNumber(_INTL("Set the wild {1}'s level.",
                                              GameData::Species.get(species).name), params)
          pkmn.push(pbGenerateWildPokemon(species, level)) if level > 0
        end
      else                                   # Edit a Pokémon
        if pbConfirmMessage(_INTL("Change this Pokémon?"))
          scr = PokemonDebugPartyScreen.new
          scr.pbPokemonDebug(pkmn[pkmnCmd], -1, nil, true)
          scr.pbEndScreen
        elsif pbConfirmMessage(_INTL("Delete this Pokémon?"))
          pkmn.delete_at(pkmnCmd)
        end
      end
    end
    next false
  }
})

MenuHandlers.add(:debug_menu, :test_trainer_battle_advanced, {
  "name"        => _INTL("Test Trainer Battle Advanced"),
  "parent"      => :battle_menu,
  "description" => _INTL("Start a battle against 1 or more trainers with a battle size of your choice."),
  "effect"      => proc {
    trainers = []
    size0 = 1
    size1 = 1
    trainerCmd = 0
    loop do
      trainerCmds = []
      trainers.each { |t| trainerCmds.push(sprintf("%s x%d", t[1].full_name, t[1].party_count)) }
      trainerCmds.push(_INTL("[Add trainer]"))
      trainerCmds.push(_INTL("[Set player side size]"))
      trainerCmds.push(_INTL("[Set opponent side size]"))
      trainerCmds.push(_INTL("[Start {1}v{2} battle]", size0, size1))
      trainerCmd = pbShowCommands(nil, trainerCmds, -1, trainerCmd)
      break if trainerCmd < 0
      if trainerCmd == trainerCmds.length - 1      # Start battle
        if trainers.length == 0
          pbMessage(_INTL("No trainers were chosen, cannot start battle."))
          next
        elsif size1 < trainers.length
          pbMessage(_INTL("Opposing side size is invalid. It should be at least {1}.", trainers.length))
          next
        elsif size1 > trainers.length && trainers[0][1].party_count == 1
          pbMessage(
            _INTL("Opposing side size cannot be {1}, as that requires the first trainer to have 2 or more Pokémon, which they don't.",
                  size1)
          )
          next
        end
        setBattleRule(sprintf("%dv%d", size0, size1))
        setBattleRule("canLose")
        battleArgs = []
        trainers.each { |t| battleArgs.push(t[1]) }
        TrainerBattle.start(*battleArgs)
        break
      elsif trainerCmd == trainerCmds.length - 2   # Set opponent side size
        if trainers.length == 0 || (trainers.length == 1 && trainers[0][1].party_count == 1)
          pbMessage(_INTL("No trainers were chosen or trainer only has one Pokémon."))
          next
        end
        maxVal = 2
        maxVal = 3 if trainers.length >= 3 ||
                      (trainers.length == 2 && trainers[0][1].party_count >= 2) ||
                      trainers[0][1].party_count >= 3
        params = ChooseNumberParams.new
        params.setRange(1, maxVal)
        params.setInitialValue(size1)
        params.setCancelValue(0)
        newSize = pbMessageChooseNumber(
          _INTL("Choose the number of battlers on the opponent's side (max. {1}).", maxVal), params
        )
        size1 = newSize if newSize > 0
      elsif trainerCmd == trainerCmds.length - 3   # Set player side size
        if !pbCanDoubleBattle?
          pbMessage(_INTL("You only have one Pokémon."))
          next
        end
        maxVal = (pbCanTripleBattle?) ? 3 : 2
        params = ChooseNumberParams.new
        params.setRange(1, maxVal)
        params.setInitialValue(size0)
        params.setCancelValue(0)
        newSize = pbMessageChooseNumber(
          _INTL("Choose the number of battlers on the player's side (max. {1}).", maxVal), params
        )
        size0 = newSize if newSize > 0
      elsif trainerCmd == trainerCmds.length - 4   # Add trainer
        trainerdata = pbListScreen(_INTL("CHOOSE A TRAINER"), TrainerBattleLister.new(0, false))
        if trainerdata
          tr = pbLoadTrainer(trainerdata[0], trainerdata[1], trainerdata[2])
          EventHandlers.trigger(:on_trainer_load, tr)
          trainers.push([0, tr])
        end
      else                                         # Edit a trainer
        if pbConfirmMessage(_INTL("Change this trainer?"))
          trainerdata = pbListScreen(_INTL("CHOOSE A TRAINER"),
                                     TrainerBattleLister.new(trainers[trainerCmd][0], false))
          if trainerdata
            tr = pbLoadTrainer(trainerdata[0], trainerdata[1], trainerdata[2])
            EventHandlers.trigger(:on_trainer_load, tr)
            trainers[trainerCmd] = [0, tr]
          end
        elsif pbConfirmMessage(_INTL("Delete this trainer?"))
          trainers.delete_at(trainerCmd)
        end
      end
    end
    next false
  }
})

#===============================================================================
# You can now reset a Pokémon's form to 0 in the Pokémon Debug menu if that
# Pokémon only has one defined form but its form is not 0.
#===============================================================================
MenuHandlers.add(:pokemon_debug_menu, :species_and_form, {
  "name"   => _INTL("Species/form..."),
  "parent" => :main,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    cmd = 0
    loop do
      msg = [_INTL("Species {1}, form {2}.", pkmn.speciesName, pkmn.form),
             _INTL("Species {1}, form {2} (forced).", pkmn.speciesName, pkmn.form)][(pkmn.forced_form.nil?) ? 0 : 1]
      cmd = screen.pbShowCommands(msg,
                                  [_INTL("Set species"),
                                   _INTL("Set form"),
                                   _INTL("Remove form override")], cmd)
      break if cmd < 0
      case cmd
      when 0   # Set species
        species = pbChooseSpeciesList(pkmn.species)
        if species && species != pkmn.species
          pkmn.species = species
          pkmn.calc_stats
          $player.pokedex.register(pkmn) if !settingUpBattle && !pkmn.egg?
          screen.pbRefreshSingle(pkmnid)
        end
      when 1   # Set form
        cmd2 = 0
        formcmds = [[], []]
        GameData::Species.each do |sp|
          next if sp.species != pkmn.species
          form_name = sp.form_name
          form_name = _INTL("Unnamed form") if !form_name || form_name.empty?
          form_name = sprintf("%d: %s", sp.form, form_name)
          formcmds[0].push(sp.form)
          formcmds[1].push(form_name)
          cmd2 = sp.form if pkmn.form == sp.form
        end
        if formcmds[0].length <= 1
          screen.pbDisplay(_INTL("Species {1} only has one form.", pkmn.speciesName))
          if pkmn.form != 0 && screen.pbConfirm(_INTL("Do you want to reset the form to 0?"))
            pkmn.form = 0
            $player.pokedex.register(pkmn) if !settingUpBattle && !pkmn.egg?
            screen.pbRefreshSingle(pkmnid)
          end
        else
          cmd2 = screen.pbShowCommands(_INTL("Set the Pokémon's form."), formcmds[1], cmd2)
          next if cmd2 < 0
          f = formcmds[0][cmd2]
          if f != pkmn.form
            if MultipleForms.hasFunction?(pkmn, "getForm")
              next if !screen.pbConfirm(_INTL("This species decides its own form. Override?"))
              pkmn.forced_form = f
            end
            pkmn.form = f
            $player.pokedex.register(pkmn) if !settingUpBattle && !pkmn.egg?
            screen.pbRefreshSingle(pkmnid)
          end
        end
      when 2   # Remove form override
        pkmn.forced_form = nil
        screen.pbRefreshSingle(pkmnid)
      end
    end
    next false
  }
})

#===============================================================================
# Fixed crash when pressing the Action button in the Debug function "Roaming
# Pokémon".
#===============================================================================
def pbDebugRoamers
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  sprites = {}
  sprites["cmdwindow"] = SpriteWindow_DebugRoamers.new(viewport)
  cmdwindow = sprites["cmdwindow"]
  cmdwindow.active = true
  loop do
    Graphics.update
    Input.update
    pbUpdateSpriteHash(sprites)
    if cmdwindow.index < cmdwindow.roamerCount
      pkmn = Settings::ROAMING_SPECIES[cmdwindow.index]
    else
      pkmn = nil
    end
    if Input.trigger?(Input::ACTION) && cmdwindow.index < cmdwindow.roamerCount &&
       (pkmn[2] <= 0 || $game_switches[pkmn[2]]) &&
       $PokemonGlobal.roamPokemon[cmdwindow.index] != true
      # Roam selected Pokémon
      pbPlayDecisionSE
      if Input.press?(Input::CTRL)   # Roam to current map
        if $PokemonGlobal.roamPosition[cmdwindow.index] == pbDefaultMap
          $PokemonGlobal.roamPosition[cmdwindow.index] = nil
        else
          $PokemonGlobal.roamPosition[cmdwindow.index] = pbDefaultMap
        end
      else   # Roam to a random other map
        oldmap = $PokemonGlobal.roamPosition[cmdwindow.index]
        pbRoamPokemonOne(cmdwindow.index)
        if $PokemonGlobal.roamPosition[cmdwindow.index] == oldmap
          $PokemonGlobal.roamPosition[cmdwindow.index] = nil
          pbRoamPokemonOne(cmdwindow.index)
        end
        $PokemonGlobal.roamedAlready = false
      end
      cmdwindow.refresh
    elsif Input.trigger?(Input::BACK)
      pbPlayCancelSE
      break
    elsif Input.trigger?(Input::USE)
      if cmdwindow.index < cmdwindow.roamerCount
        pbPlayDecisionSE
        # Toggle through roaming, not roaming, defeated
        if pkmn[2] > 0 && !$game_switches[pkmn[2]]
          # not roaming -> roaming
          $game_switches[pkmn[2]] = true
        elsif $PokemonGlobal.roamPokemon[cmdwindow.index] != true
          # roaming -> defeated
          $PokemonGlobal.roamPokemon[cmdwindow.index] = true
          $PokemonGlobal.roamPokemonCaught[cmdwindow.index] = false
        elsif $PokemonGlobal.roamPokemon[cmdwindow.index] == true &&
              !$PokemonGlobal.roamPokemonCaught[cmdwindow.index]
          # defeated -> caught
          $PokemonGlobal.roamPokemonCaught[cmdwindow.index] = true
        elsif pkmn[2] > 0
          # caught -> not roaming (or roaming if Switch ID is 0)
          $game_switches[pkmn[2]] = false if pkmn[2] > 0
          $PokemonGlobal.roamPokemon[cmdwindow.index] = nil
          $PokemonGlobal.roamPokemonCaught[cmdwindow.index] = false
        end
        cmdwindow.refresh
      elsif cmdwindow.index == cmdwindow.itemCount - 2   # All roam
        if Settings::ROAMING_SPECIES.length == 0
          pbPlayBuzzerSE
        else
          pbPlayDecisionSE
          pbRoamPokemon
          $PokemonGlobal.roamedAlready = false
          cmdwindow.refresh
        end
      else   # Clear all roaming locations
        if Settings::ROAMING_SPECIES.length == 0
          pbPlayBuzzerSE
        else
          pbPlayDecisionSE
          Settings::ROAMING_SPECIES.length.times do |i|
            $PokemonGlobal.roamPosition[i] = nil
          end
          $PokemonGlobal.roamedAlready = false
          cmdwindow.refresh
        end
      end
    end
  end
  pbDisposeSpriteHash(sprites)
  viewport.dispose
end
