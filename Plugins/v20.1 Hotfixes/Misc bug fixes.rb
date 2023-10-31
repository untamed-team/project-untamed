#===============================================================================
# "v20.1 Hotfixes" plugin
# This file contains fixes for miscellaneous bugs in Essentials v20.1.
# These bug fixes are also in the dev branch of the GitHub version of
# Essentials:
# https://github.com/Maruno17/pokemon-essentials
#===============================================================================

Essentials::ERROR_TEXT += "[v20.1 Hotfixes 1.0.7]\r\n"

#===============================================================================
# Fixed the "See ya!" option in the PC menu not working properly.
#===============================================================================
MenuHandlers.add(:pc_menu, :pokemon_storage, {
  "name"      => proc {
    next ($player.seen_storage_creator) ? _INTL("{1}'s PC", pbGetStorageCreator) : _INTL("Someone's PC")
  },
  "order"     => 10,
  "effect"    => proc { |menu|
    pbMessage(_INTL("\\se[PC access]The Pokémon Storage System was opened."))
    command = 0
    loop do
      command = pbShowCommandsWithHelp(nil,
         [_INTL("Organize Boxes"),
          _INTL("Withdraw Pokémon"),
          _INTL("Deposit Pokémon"),
          _INTL("See ya!")],
         [_INTL("Organize the Pokémon in Boxes and in your party."),
          _INTL("Move Pokémon stored in Boxes to your party."),
          _INTL("Store Pokémon in your party in Boxes."),
          _INTL("Return to the previous menu.")], -1, command)
      break if command < 0
      case command
      when 0   # Organize
        pbFadeOutIn {
          scene = PokemonStorageScene.new
          screen = PokemonStorageScreen.new(scene, $PokemonStorage)
          screen.pbStartScreen(0)
        }
      when 1   # Withdraw
        if $PokemonStorage.party_full?
          pbMessage(_INTL("Your party is full!"))
          next
        end
        pbFadeOutIn {
          scene = PokemonStorageScene.new
          screen = PokemonStorageScreen.new(scene, $PokemonStorage)
          screen.pbStartScreen(1)
        }
      when 2   # Deposit
        count = 0
        $PokemonStorage.party.each do |p|
          count += 1 if p && !p.egg? && p.hp > 0
        end
        if count <= 1
          pbMessage(_INTL("Can't deposit the last Pokémon!"))
          next
        end
        pbFadeOutIn {
          scene = PokemonStorageScene.new
          screen = PokemonStorageScreen.new(scene, $PokemonStorage)
          screen.pbStartScreen(2)
        }
      else
        break
      end
    end
    next false
  }
})

#===============================================================================
# Fixed Pokémon icons sometimes disappearing in Pokémon storage screen.
#===============================================================================
class PokemonBoxPartySprite < Sprite
  alias __hotfixes__refresh refresh
  def refresh
    __hotfixes__refresh
    Settings::MAX_PARTY_SIZE.times do |j|
      sprite = @pokemonsprites[j]
      sprite.z = 1 if sprite && !sprite.disposed?
    end
  end
end

class PokemonBoxSprite < Sprite
  alias __hotfixes__refresh refresh
  def refresh
    __hotfixes__refresh
    PokemonBox::BOX_HEIGHT.times do |j|
      PokemonBox::BOX_WIDTH.times do |k|
        sprite = @pokemonsprites[(j * PokemonBox::BOX_WIDTH) + k]
        sprite.z = 1 if sprite && !sprite.disposed?
      end
    end
  end
end

#===============================================================================
# Fixed Rare Candy not reviving a fainted Shedinja.
#===============================================================================
def pbChangeLevel(pkmn, new_level, scene)
  new_level = new_level.clamp(1, GameData::GrowthRate.max_level)
  if pkmn.level == new_level
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1}'s level remained unchanged.", pkmn.name))
    else
      pbMessage(_INTL("{1}'s level remained unchanged.", pkmn.name))
    end
    return
  end
  old_level           = pkmn.level
  old_total_hp        = pkmn.totalhp
  old_attack          = pkmn.attack
  old_defense         = pkmn.defense
  old_special_attack  = pkmn.spatk
  old_special_defense = pkmn.spdef
  old_speed           = pkmn.speed
  pkmn.level = new_level
  pkmn.calc_stats
  pkmn.hp = 1 if new_level > old_level && pkmn.species_data.base_stats[:HP] == 1
  scene.pbRefresh
  if old_level > new_level
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1} dropped to Lv. {2}!", pkmn.name, pkmn.level))
    else
      pbMessage(_INTL("{1} dropped to Lv. {2}!", pkmn.name, pkmn.level))
    end
    total_hp_diff        = pkmn.totalhp - old_total_hp
    attack_diff          = pkmn.attack - old_attack
    defense_diff         = pkmn.defense - old_defense
    special_attack_diff  = pkmn.spatk - old_special_attack
    special_defense_diff = pkmn.spdef - old_special_defense
    speed_diff           = pkmn.speed - old_speed
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
                           total_hp_diff, attack_diff, defense_diff, special_attack_diff, special_defense_diff, speed_diff), scene)
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
                           pkmn.totalhp, pkmn.attack, pkmn.defense, pkmn.spatk, pkmn.spdef, pkmn.speed), scene)
  else
    pkmn.changeHappiness("vitamin")
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1} grew to Lv. {2}!", pkmn.name, pkmn.level))
    else
      pbMessage(_INTL("{1} grew to Lv. {2}!", pkmn.name, pkmn.level))
    end
    total_hp_diff        = pkmn.totalhp - old_total_hp
    attack_diff          = pkmn.attack - old_attack
    defense_diff         = pkmn.defense - old_defense
    special_attack_diff  = pkmn.spatk - old_special_attack
    special_defense_diff = pkmn.spdef - old_special_defense
    speed_diff           = pkmn.speed - old_speed
    pbTopRightWindow(_INTL("Max. HP<r>+{1}\r\nAttack<r>+{2}\r\nDefense<r>+{3}\r\nSp. Atk<r>+{4}\r\nSp. Def<r>+{5}\r\nSpeed<r>+{6}",
                           total_hp_diff, attack_diff, defense_diff, special_attack_diff, special_defense_diff, speed_diff), scene)
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
                           pkmn.totalhp, pkmn.attack, pkmn.defense, pkmn.spatk, pkmn.spdef, pkmn.speed), scene)
    # Learn new moves upon level up
    movelist = pkmn.getMoveList
    movelist.each do |i|
      next if i[0] <= old_level || i[0] > pkmn.level
      pbLearnMove(pkmn, i[1], true) { scene.pbUpdate }
    end
    # Check for evolution
    new_species = pkmn.check_evolution_on_level_up
    if new_species
      pbFadeOutInWithMusic {
        evo = PokemonEvolutionScene.new
        evo.pbStartScreen(pkmn, new_species)
        evo.pbEvolution
        evo.pbEndScreen
        scene.pbRefresh if scene.is_a?(PokemonPartyScreen)
      }
    end
  end
end

#===============================================================================
# Fixed fainted Pokémon reviving if they evolve.
#===============================================================================
class PokemonEvolutionScene
  def pbEvolutionSuccess
    $stats.evolution_count += 1
    # Play cry of evolved species
    frames = (GameData::Species.cry_length(@newspecies, @pokemon.form) * Graphics.frame_rate).ceil
    Pokemon.play_cry(@newspecies, @pokemon.form)
    (frames + 4).times do
      Graphics.update
      pbUpdate
    end
    pbBGMStop
    # Success jingle/message
    pbMEPlay("Evolution success")
    newspeciesname = GameData::Species.get(@newspecies).name
    pbMessageDisplay(@sprites["msgwindow"],
                     _INTL("\\se[]Congratulations! Your {1} evolved into {2}!\\wt[80]",
                           @pokemon.name, newspeciesname)) { pbUpdate }
    @sprites["msgwindow"].text = ""
    # Check for consumed item and check if Pokémon should be duplicated
    pbEvolutionMethodAfterEvolution
    # Modify Pokémon to make it evolved
    was_fainted = @pokemon.fainted?
    @pokemon.species = @newspecies
    @pokemon.hp = 0 if was_fainted
    @pokemon.calc_stats
    @pokemon.ready_to_evolve = false
    # See and own evolved species
    was_owned = $player.owned?(@newspecies)
    $player.pokedex.register(@pokemon)
    $player.pokedex.set_owned(@newspecies)
    moves_to_learn = []
    movelist = @pokemon.getMoveList
    movelist.each do |i|
      next if i[0] != 0 && i[0] != @pokemon.level   # 0 is "learn upon evolution"
      moves_to_learn.push(i[1])
    end
    # Show Pokédex entry for new species if it hasn't been owned before
    if Settings::SHOW_NEW_SPECIES_POKEDEX_ENTRY_MORE_OFTEN && !was_owned && $player.has_pokedex
      pbMessageDisplay(@sprites["msgwindow"],
                       _INTL("{1}'s data was added to the Pokédex.", newspeciesname)) { pbUpdate }
      $player.pokedex.register_last_seen(@pokemon)
      pbFadeOutIn {
        scene = PokemonPokedexInfo_Scene.new
        screen = PokemonPokedexInfoScreen.new(scene)
        screen.pbDexEntry(@pokemon.species)
        @sprites["msgwindow"].text = "" if moves_to_learn.length > 0
        pbEndScreen(false) if moves_to_learn.length == 0
      }
    end
    # Learn moves upon evolution for evolved species
    moves_to_learn.each do |move|
      pbLearnMove(@pokemon, move, true) { pbUpdate }
    end
  end
end

#===============================================================================
# Fixed some special battle intro animations not playing when they should.
#===============================================================================
SpecialBattleIntroAnimations.get("vs_trainer_animation")[2] = proc { |battle_type, foe, location|   # Condition
  next false if battle_type.even? || foe.length != 1   # Trainer battle against 1 trainer
  tr_type = foe[0].trainer_type
  next pbResolveBitmap("Graphics/Transitions/hgss_vs_#{tr_type}") &&
       pbResolveBitmap("Graphics/Transitions/hgss_vsBar_#{tr_type}")
}

SpecialBattleIntroAnimations.get("vs_elite_four_animation")[2] = proc { |battle_type, foe, location|   # Condition
    next false if battle_type.even? || foe.length != 1   # Trainer battle against 1 trainer
    tr_type = foe[0].trainer_type
    next pbResolveBitmap("Graphics/Transitions/vsE4_#{tr_type}") &&
         pbResolveBitmap("Graphics/Transitions/vsE4Bar_#{tr_type}")
  }

SpecialBattleIntroAnimations.get("alternate_vs_trainer_animation")[2] = proc { |battle_type, foe, location|   # Condition
    next false if battle_type.even? || foe.length != 1   # Trainer battle against 1 trainer
    tr_type = foe[0].trainer_type
    next pbResolveBitmap("Graphics/Transitions/vsTrainer_#{tr_type}") &&
         pbResolveBitmap("Graphics/Transitions/vsBar_#{tr_type}")
  }

#===============================================================================
# Fixed play time carrying over to new games.
#===============================================================================
module SaveData
  class Value
    def reset_on_new_game
      @reset_on_new_game = true
    end

    def reset_on_new_game?
      return @reset_on_new_game
    end
  end

  def self.unregister(id)
    validate id => Symbol
    @values.delete_if { |value| value.id == id }
  end

  def self.mark_values_as_unloaded
    @values.each do |value|
      value.mark_as_unloaded if !value.load_in_bootup? || value.reset_on_new_game?
    end
  end

  def self.load_new_game_values
    @values.each do |value|
      value.load_new_game_value if value.has_new_game_proc? && (!value.loaded? || value.reset_on_new_game?)
    end
  end
end

SaveData.unregister(:stats)

SaveData.register(:stats) do
  load_in_bootup
  ensure_class :GameStats
  save_value { $stats }
  load_value { |value| $stats = value }
  new_game_value { GameStats.new }
  reset_on_new_game
end

#===============================================================================
# Fixed Giratina's form code crashing if the current map doesn't have metadata.
#===============================================================================
MultipleForms.register(:GIRATINA, {
  "getForm" => proc { |pkmn|
    next 1 if pkmn.hasItem?(:GRISEOUSORB)
    if $game_map && $game_map.metadata&.has_flag?("DistortionWorld")
      next 1
    end
    next 0
  }
})

#===============================================================================
# Fixed item sell prices being 25% of the buy prices rather than 50%.
#===============================================================================
class PokemonMart_Scene
  def pbChooseNumber(helptext, item, maximum)
    curnumber = 1
    ret = 0
    helpwindow = @sprites["helpwindow"]
    itemprice = @adapter.getPrice(item, !@buying)
    pbDisplay(helptext, true)
    using(numwindow = Window_AdvancedTextPokemon.new("")) do   # Showing number of items
      pbPrepareWindow(numwindow)
      numwindow.viewport = @viewport
      numwindow.width = 224
      numwindow.height = 64
      numwindow.baseColor = Color.new(88, 88, 80)
      numwindow.shadowColor = Color.new(168, 184, 184)
      numwindow.text = _INTL("x{1}<r>$ {2}", curnumber, (curnumber * itemprice).to_s_formatted)
      pbBottomRight(numwindow)
      numwindow.y -= helpwindow.height
      loop do
        Graphics.update
        Input.update
        numwindow.update
        update
        oldnumber = curnumber
        if Input.repeat?(Input::LEFT)
          curnumber -= 10
          curnumber = 1 if curnumber < 1
          if curnumber != oldnumber
            numwindow.text = _INTL("x{1}<r>$ {2}", curnumber, (curnumber * itemprice).to_s_formatted)
            pbPlayCursorSE
          end
        elsif Input.repeat?(Input::RIGHT)
          curnumber += 10
          curnumber = maximum if curnumber > maximum
          if curnumber != oldnumber
            numwindow.text = _INTL("x{1}<r>$ {2}", curnumber, (curnumber * itemprice).to_s_formatted)
            pbPlayCursorSE
          end
        elsif Input.repeat?(Input::UP)
          curnumber += 1
          curnumber = 1 if curnumber > maximum
          if curnumber != oldnumber
            numwindow.text = _INTL("x{1}<r>$ {2}", curnumber, (curnumber * itemprice).to_s_formatted)
            pbPlayCursorSE
          end
        elsif Input.repeat?(Input::DOWN)
          curnumber -= 1
          curnumber = maximum if curnumber < 1
          if curnumber != oldnumber
            numwindow.text = _INTL("x{1}<r>$ {2}", curnumber, (curnumber * itemprice).to_s_formatted)
            pbPlayCursorSE
          end
        elsif Input.trigger?(Input::USE)
          ret = curnumber
          break
        elsif Input.trigger?(Input::BACK)
          pbPlayCancelSE
          ret = 0
          break
        end
      end
    end
    helpwindow.visible = false
    return ret
  end
end

class PokemonMartScreen
  def pbSellScreen
    item = @scene.pbStartSellScene(@adapter.getInventory, @adapter)
    loop do
      item = @scene.pbChooseSellItem
      break if !item
      itemname       = @adapter.getDisplayName(item)
      itemnameplural = @adapter.getDisplayNamePlural(item)
      if !@adapter.canSell?(item)
        pbDisplayPaused(_INTL("Oh, no. I can't buy {1}.", itemnameplural))
        next
      end
      price = @adapter.getPrice(item, true)
      qty = @adapter.getQuantity(item)
      next if qty == 0
      @scene.pbShowMoney
      if qty > 1
        qty = @scene.pbChooseNumber(
          _INTL("How many {1} would you like to sell?", itemnameplural), item, qty
        )
      end
      if qty == 0
        @scene.pbHideMoney
        next
      end
      price *= qty
      if pbConfirm(_INTL("I can pay ${1}.\nWould that be OK?", price.to_s_formatted))
        old_money = @adapter.getMoney
        @adapter.setMoney(@adapter.getMoney + price)
        $stats.money_earned_at_marts += @adapter.getMoney - old_money
        qty.times { @adapter.removeItem(item) }
        sold_item_name = (qty > 1) ? itemnameplural : itemname
        pbDisplayPaused(_INTL("You turned over the {1} and got ${2}.",
                              sold_item_name, price.to_s_formatted)) { pbSEPlay("Mart buy item") }
        @scene.pbRefresh
      end
      @scene.pbHideMoney
    end
    @scene.pbEndSellScene
  end
end

#===============================================================================
# Fixed having no Pokémon in your party making the cursor not work as expected
# in the party screen.
#===============================================================================
class PokemonParty_Scene
  def pbChangeSelection(key, currentsel)
    numsprites = Settings::MAX_PARTY_SIZE + ((@multiselect) ? 2 : 1)
    case key
    when Input::LEFT
      loop do
        currentsel -= 1
        break unless currentsel > 0 && currentsel < @party.length && !@party[currentsel]
      end
      if currentsel >= @party.length && currentsel < Settings::MAX_PARTY_SIZE
        currentsel = @party.length - 1
      end
      currentsel = numsprites - 1 if currentsel < 0
    when Input::RIGHT
      loop do
        currentsel += 1
        break unless currentsel < @party.length && !@party[currentsel]
      end
      if currentsel == @party.length
        currentsel = Settings::MAX_PARTY_SIZE
      elsif currentsel == numsprites
        currentsel = 0
        currentsel = numsprites - 1 if currentsel >= @party.length
      end
    when Input::UP
      if currentsel >= Settings::MAX_PARTY_SIZE
        currentsel -= 1
        while currentsel > 0 && currentsel < Settings::MAX_PARTY_SIZE && !@party[currentsel]
          currentsel -= 1
        end
        currentsel = numsprites - 1 if currentsel >= @party.length
      else
        loop do
          currentsel -= 2
          break unless currentsel > 0 && !@party[currentsel]
        end
      end
      if currentsel >= @party.length && currentsel < Settings::MAX_PARTY_SIZE
        currentsel = @party.length - 1
      end
      currentsel = numsprites - 1 if currentsel < 0
    when Input::DOWN
      if currentsel >= Settings::MAX_PARTY_SIZE - 1
        currentsel += 1
      else
        currentsel += 2
        currentsel = Settings::MAX_PARTY_SIZE if currentsel < Settings::MAX_PARTY_SIZE && !@party[currentsel]
      end
      if currentsel >= @party.length && currentsel < Settings::MAX_PARTY_SIZE
        currentsel = Settings::MAX_PARTY_SIZE
      elsif currentsel >= numsprites
        currentsel = 0
        currentsel = numsprites - 1 if currentsel >= @party.length
      end
    end
    return currentsel
  end

  def pbHardRefresh
    oldtext = []
    lastselected = -1
    Settings::MAX_PARTY_SIZE.times do |i|
      oldtext.push(@sprites["pokemon#{i}"].text)
      lastselected = i if @sprites["pokemon#{i}"].selected
      @sprites["pokemon#{i}"].dispose
    end
    lastselected = @party.length - 1 if lastselected >= @party.length
    lastselected = Settings::MAX_PARTY_SIZE if lastselected < 0
    Settings::MAX_PARTY_SIZE.times do |i|
      if @party[i]
        @sprites["pokemon#{i}"] = PokemonPartyPanel.new(@party[i], i, @viewport)
      else
        @sprites["pokemon#{i}"] = PokemonPartyBlankPanel.new(@party[i], i, @viewport)
      end
      @sprites["pokemon#{i}"].text = oldtext[i]
    end
    pbSelect(lastselected)
  end
end

#===============================================================================
# Fixed def pbShowCommandsWithHelp not properly deactivating showing a message
# window if it created one.
#===============================================================================
def pbShowCommandsWithHelp(msgwindow, commands, help, cmdIfCancel = 0, defaultCmd = 0)
  msgwin = msgwindow
  msgwin = pbCreateMessageWindow(nil) if !msgwindow
  oldlbl = msgwin.letterbyletter
  msgwin.letterbyletter = false
  if commands
    cmdwindow = Window_CommandPokemonEx.new(commands)
    cmdwindow.z = 99999
    cmdwindow.visible = true
    cmdwindow.resizeToFit(cmdwindow.commands)
    cmdwindow.height = msgwin.y if cmdwindow.height > msgwin.y
    cmdwindow.index = defaultCmd
    command = 0
    msgwin.text = help[cmdwindow.index]
    msgwin.width = msgwin.width   # Necessary evil to make it use the proper margins
    loop do
      Graphics.update
      Input.update
      oldindex = cmdwindow.index
      cmdwindow.update
      if oldindex != cmdwindow.index
        msgwin.text = help[cmdwindow.index]
      end
      msgwin.update
      yield if block_given?
      if Input.trigger?(Input::BACK)
        if cmdIfCancel > 0
          command = cmdIfCancel - 1
          break
        elsif cmdIfCancel < 0
          command = cmdIfCancel
          break
        end
      end
      if Input.trigger?(Input::USE)
        command = cmdwindow.index
        break
      end
      pbUpdateSceneMap
    end
    ret = command
    cmdwindow.dispose
    Input.update
  end
  msgwin.letterbyletter = oldlbl
  pbDisposeMessageWindow(msgwin) if !msgwindow
  return ret
end

#===============================================================================
# Fixed text underline/strikethrough lines being mispositioned. Also added
# shadows to them.
#===============================================================================
def drawSingleFormattedChar(bitmap, ch)
  if ch[5]   # If a graphic
    graphic = Bitmap.new(ch[0])
    graphicRect = ch[15]
    bitmap.blt(ch[1], ch[2], graphic, graphicRect, ch[8].alpha)
    graphic.dispose
    return
  end
  bitmap.font.size = ch[13] if bitmap.font.size != ch[13]
  if ch[9]   # shadow
    if ch[10]   # underline
      bitmap.fill_rect(ch[1], ch[2] + ch[4] - [(ch[4] - bitmap.font.size) / 2, 0].max - 2, ch[3], 4, ch[9])
    end
    if ch[11]   # strikeout
      bitmap.fill_rect(ch[1], ch[2] + 2 + (ch[4] / 2), ch[3], 4, ch[9])
    end
  end
  if ch[0] == "\n" || ch[0] == "\r" || ch[0] == " " || isWaitChar(ch[0])
    bitmap.font.color = ch[8] if bitmap.font.color != ch[8]
  else
    bitmap.font.bold = ch[6] if bitmap.font.bold != ch[6]
    bitmap.font.italic = ch[7] if bitmap.font.italic != ch[7]
    bitmap.font.name = ch[12] if bitmap.font.name != ch[12]
    offset = 0
    if ch[9]   # shadow
      bitmap.font.color = ch[9]
      if (ch[16] & 1) != 0   # outline
        offset = 1
        bitmap.draw_text(ch[1], ch[2], ch[3] + 2, ch[4], ch[0])
        bitmap.draw_text(ch[1], ch[2] + 1, ch[3] + 2, ch[4], ch[0])
        bitmap.draw_text(ch[1], ch[2] + 2, ch[3] + 2, ch[4], ch[0])
        bitmap.draw_text(ch[1] + 1, ch[2], ch[3] + 2, ch[4], ch[0])
        bitmap.draw_text(ch[1] + 1, ch[2] + 2, ch[3] + 2, ch[4], ch[0])
        bitmap.draw_text(ch[1] + 2, ch[2], ch[3] + 2, ch[4], ch[0])
        bitmap.draw_text(ch[1] + 2, ch[2] + 1, ch[3] + 2, ch[4], ch[0])
        bitmap.draw_text(ch[1] + 2, ch[2] + 2, ch[3] + 2, ch[4], ch[0])
      elsif (ch[16] & 2) != 0   # outline 2
        offset = 2
        bitmap.draw_text(ch[1], ch[2], ch[3] + 4, ch[4], ch[0])
        bitmap.draw_text(ch[1], ch[2] + 2, ch[3] + 4, ch[4], ch[0])
        bitmap.draw_text(ch[1], ch[2] + 4, ch[3] + 4, ch[4], ch[0])
        bitmap.draw_text(ch[1] + 2, ch[2], ch[3] + 4, ch[4], ch[0])
        bitmap.draw_text(ch[1] + 2, ch[2] + 4, ch[3] + 4, ch[4], ch[0])
        bitmap.draw_text(ch[1] + 4, ch[2], ch[3] + 4, ch[4], ch[0])
        bitmap.draw_text(ch[1] + 4, ch[2] + 2, ch[3] + 4, ch[4], ch[0])
        bitmap.draw_text(ch[1] + 4, ch[2] + 4, ch[3] + 4, ch[4], ch[0])
      else
        bitmap.draw_text(ch[1] + 2, ch[2], ch[3] + 2, ch[4], ch[0])
        bitmap.draw_text(ch[1], ch[2] + 2, ch[3] + 2, ch[4], ch[0])
        bitmap.draw_text(ch[1] + 2, ch[2] + 2, ch[3] + 2, ch[4], ch[0])
      end
    end
    bitmap.font.color = ch[8] if bitmap.font.color != ch[8]
    bitmap.draw_text(ch[1] + offset, ch[2] + offset, ch[3], ch[4], ch[0])
  end
  if ch[10]   # underline
    bitmap.fill_rect(ch[1], ch[2] + ch[4] - [(ch[4] - bitmap.font.size) / 2, 0].max - 2, ch[3] - 2, 2, ch[8])
  end
  if ch[11]   # strikeout
    bitmap.fill_rect(ch[1], ch[2] + 2 + (ch[4] / 2), ch[3] - 2, 2, ch[8])
  end
end

#===============================================================================
# Fixed Shadow Pokémon still knowing some of their original moves after being
# created.
#===============================================================================
class Pokemon
  def update_shadow_moves(_param = nil)
    return if !@shadow_moves || @shadow_moves.empty?
    # Not a Shadow Pokémon (any more); relearn all its original moves
    if !shadowPokemon?
      if @shadow_moves.length > MAX_MOVES
        new_moves = []
        @shadow_moves.each_with_index { |m, i| new_moves.push(m) if m && i >= MAX_MOVES }
        replace_moves(new_moves)
      end
      @shadow_moves = nil
      return
    end
    # Is a Shadow Pokémon; ensure it knows the appropriate moves depending on its heart stage
    # Start with all Shadow moves
    new_moves = []
    @shadow_moves.each_with_index { |m, i| new_moves.push(m) if m && i < MAX_MOVES }
    num_shadow_moves = new_moves.length
    # Add some original moves (skipping ones in the same slot as a Shadow Move)
    num_original_moves = [3, 3, 2, 1, 1, 0][self.heartStage]
    if num_original_moves > 0
      relearned_count = 0
      @shadow_moves.each_with_index do |m, i|
        next if !m || i < MAX_MOVES + num_shadow_moves
        new_moves.push(m)
        relearned_count += 1
        break if relearned_count >= num_original_moves
      end
    end
    # Relearn Shadow moves plus some original moves (may not change anything)
    replace_moves(new_moves)
  end

  def replace_moves(new_moves)
    # Forget any known moves that aren't in new_moves
    @moves.each_with_index do |m, i|
      @moves[i] = nil if !new_moves.include?(m.id)
    end
    @moves.compact!
    # Learn any moves in new_moves that aren't known
    new_moves.each do |move|
      next if !move || !GameData::Move.exists?(move) || hasMove?(move)
      break if numMoves >= Pokemon::MAX_MOVES
      learn_move(move)
    end
  end
end

#===============================================================================
# Fixed the Interpreter not resetting if the game was saved in the middle of an
# event and then you start a new game.
#===============================================================================
module Game
  def self.start_new
    if $game_map&.events
      $game_map.events.each_value { |event| event.clear_starting }
    end
    $game_temp.common_event_id = 0 if $game_temp
    $game_temp.begun_new_game = true
    pbMapInterpreter&.clear
    pbMapInterpreter&.setup(nil, 0, 0)
    $scene = Scene_Map.new
    SaveData.load_new_game_values
    $stats.play_sessions += 1
    $map_factory = PokemonMapFactory.new($data_system.start_map_id)
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    $game_player.refresh
    $PokemonEncounters = PokemonEncounters.new
    $PokemonEncounters.setup($game_map.map_id)
    $game_map.autoplay
    $game_map.update
  end
end

#===============================================================================
# Fixed ability inheritance when breeding.
#===============================================================================
class DayCare
  module EggGenerator
    module_function

    def inherit_ability(egg, mother, father)
      # mother = [mother, mother_ditto, mother_in_family]
      # father = [father, father_ditto, father_in_family]
      parent = (mother[1]) ? father[0] : mother[0]   # The female or non-Ditto parent
      if parent.hasHiddenAbility?
        egg.ability_index = parent.ability_index if rand(100) < 60
      elsif rand(100) < 80
        egg.ability_index = parent.ability_index
      else
        egg.ability_index = (parent.ability_index + 1) % 2
      end
    end
  end
end

#===============================================================================
# Fixed IV inheritance when breeding.
#===============================================================================
class DayCare
  module EggGenerator
    module_function

    def inherit_IVs(egg, mother, father)
      # Get all stats
      stats = []
      GameData::Stat.each_main { |s| stats.push(s.id) }
      # Get the number of stats to inherit (includes ones inherited via Power items)
      inherit_count = 3
      if Settings::MECHANICS_GENERATION >= 6
        inherit_count = 5 if mother.hasItem?(:DESTINYKNOT) || father.hasItem?(:DESTINYKNOT)
      end
      # Inherit IV because of Power items (if both parents have the same Power
      # item, then the parent that passes that Power item's stat down is chosen
      # randomly)
      power_items = [
        [:POWERWEIGHT, :HP],
        [:POWERBRACER, :ATTACK],
        [:POWERBELT,   :DEFENSE],
        [:POWERLENS,   :SPECIAL_ATTACK],
        [:POWERBAND,   :SPECIAL_DEFENSE],
        [:POWERANKLET, :SPEED]
      ]
      power_stats = {}
      [mother, father].each do |parent|
        power_items.each do |item|
          next if !parent.hasItem?(item[0])
          power_stats[item[1]] ||= []
          power_stats[item[1]].push(parent.iv[item[1]])
          break
        end
      end
      power_stats.each_pair do |stat, new_stats|
        next if !new_stats || new_stats.length == 0
        new_stat = new_stats.sample
        egg.iv[stat] = new_stat
        stats.delete(stat)   # Don't try to inherit this stat's IV again
        inherit_count -= 1
      end
      # Inherit the rest of the IVs
      chosen_stats = stats.sample(inherit_count)
      chosen_stats.each { |stat| egg.iv[stat] = [mother, father].sample.iv[stat] }
    end
  end
end

#===============================================================================
# Fixed roaming Pokémon not remembering whether they have been caught.
#===============================================================================
class PokemonGlobalMetadata
  def roamPokemonCaught
    @roamPokemonCaught = [] if !@roamPokemonCaught
    return @roamPokemonCaught
  end
end

#===============================================================================
# Fixed entering a map always restarting the BGM if that map's BGM has a night
# version, even if it ends up playing the same music.
#===============================================================================
class Scene_Map
  def autofade(mapid)
    playingBGM = $game_system.playing_bgm
    playingBGS = $game_system.playing_bgs
    return if !playingBGM && !playingBGS
    map = load_data(sprintf("Data/Map%03d.rxdata", mapid))
    if playingBGM && map.autoplay_bgm
      test_filename = map.bgm.name
      test_filename += "_n" if PBDayNight.isNight? && FileTest.audio_exist?("Audio/BGM/" + test_filename + "_n")
      pbBGMFade(0.8) if playingBGM.name != test_filename
    end
    if playingBGS && map.autoplay_bgs && playingBGS.name != map.bgs.name
      pbBGMFade(0.8)
    end
    Graphics.frame_reset
  end
end
