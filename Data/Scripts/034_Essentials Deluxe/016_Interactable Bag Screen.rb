#===============================================================================
# Bag Screen compatibility.
#===============================================================================
if PluginManager.installed?("Bag Screen w/int. Party")
  class PokemonBag_Scene
    def pbRefresh
      pocketX = []
      increment = 0
      #-------------------------------------------------------------------------
      # Allows for additional bag pockets beyond the default number.
      #-------------------------------------------------------------------------
      if PluginManager.installed?("ZUD Mechanics") && @sprites["pocketicon"].bitmap.width < 148
        @sprites["pocketicon"].bitmap.clear
        @sprites["pocketicon"] = BitmapSprite.new(148, 52, @viewport)
        @sprites["pocketicon"].x = 362
        @sprites["pocketicon"].y = 0
      end
      @bag.pockets.length.times do |i|
        break if pocketX.length == @bag.pockets.length
        pocketX.push(increment)
        increment += 2 if i.odd?
      end
      #-------------------------------------------------------------------------
      pocketAcc = @sprites["itemlist"].pocket
      @sprites["pocketicon"].bitmap.clear
      if @choosing && @filterlist
        (1...@bag.pockets.length).each do |i|
          next if @filterlist[i].length > 0
          pocketValue = i - 1
          @sprites["pocketicon"].bitmap.blt(
            (i - 1) * 14 + pocketX[pocketValue], (i % 2) * 26, @pocketbitmap.bitmap,
            Rect.new((i - 1) * 28, 28, 28, 28))
        end
      end
      @sprites["pocketicon"].bitmap.blt((pocketAcc - 1) * 14 + pocketX[pocketAcc - 1], (pocketAcc % 2) * 26,
         @pocketbitmap.bitmap, Rect.new((pocketAcc - 1) * 28, 0, 28, 28))
      @sprites["itemlist"].refresh
      pbRefreshIndexChanged
      pbRefreshParty
      pbPocketColor if BagScreenWiInParty::BGSTYLE == 2
    end
    
    def pbUpdateAnnotation
      itemwindow = @sprites["itemlist"]
      item = itemwindow.item
      itm = GameData::Item.get(item) if item
      annotations = []
      if @bag.last_viewed_pocket == 1 && item
        annotations.clear
        if itm.is_evolution_stone?
          for i in $player.party
            elig = i.check_evolution_on_use_item(itm)
            annotations.push((elig) ? _INTL("ABLE") : _INTL("UNABLE"))
          end
        #-----------------------------------------------------------------------
        # Displays Tera Shard compatibility on the party.
        #-----------------------------------------------------------------------
        elsif PluginManager.installed?("Terastal Phenomenon") && itm.is_tera_shard?
          for i in $player.party
            elig = i.tera_type != itm.tera_shard_type
            annotations.push((elig) ? _INTL("ABLE") : _INTL("UNABLE"))
          end
        #-----------------------------------------------------------------------
        else
          for i in 0...Settings::MAX_PARTY_SIZE
            @sprites["pokemon#{i}"].text = annotations[i]
          end
        end
        for i in 0...Settings::MAX_PARTY_SIZE
          @sprites["pokemon#{i}"].text = annotations[i]
        end
      elsif @bag.last_viewed_pocket == 4 && item
        annotations.clear
        if itm.is_machine?
          machine = itm.move
          move = GameData::Move.get(machine).id
          movelist = nil
          if movelist!=nil && movelist.is_a?(Array)
            for i in 0...movelist.length
              movelist[i] = GameData::Move.get(movelist[i]).id
            end
          end
          $player.party.each_with_index do |pkmn, i|
            if pkmn.egg?
              annotations[i] = _INTL("UNABLE")
            elsif pkmn.hasMove?(move)
              annotations[i] = _INTL("LEARNED")
            else
              species = pkmn.species
              if movelist && movelist.any? { |j| j == species }
                annotations[i] = _INTL("ABLE")
              elsif pkmn.compatible_with_move?(move)
                annotations[i] = _INTL("ABLE")
              else
                annotations[i] = _INTL("UNABLE")
              end
            end
          end
        else
          for i in @party
            annotations.push((elig) ? _INTL("ABLE") : _INTL("UNABLE"))
          end
        end
        for i in 0...Settings::MAX_PARTY_SIZE
          @sprites["pokemon#{i}"].text = annotations[i]
        end
      #-------------------------------------------------------------------------
      # Displays Z-Crystal compatibility on the party.
      #-------------------------------------------------------------------------
      elsif PluginManager.installed?("ZUD Mechanics") && 
            @bag.last_viewed_pocket == Settings::BAG_MAX_POCKET_SIZE.length && item
        annotations.clear
        if itm.is_z_crystal?
          for i in $player.party
            elig = i.compat_zmove?(i.moves, item) || i.compat_ultra?(item)
            annotations.push((elig) ? _INTL("ABLE") : _INTL("UNABLE"))
          end
        end
        for i in 0...Settings::MAX_PARTY_SIZE
          @sprites["pokemon#{i}"].text = annotations[i]
        end
      #-------------------------------------------------------------------------
      else
        for i in 0...Settings::MAX_PARTY_SIZE
          @sprites["pokemon#{i}"].text = nil if @sprites["pokemon#{i}"].text 
        end
      end
    end
	
	
    #---------------------------------------------------------------------------
    # Updated to include improved item text.
    #---------------------------------------------------------------------------
    def pbChoosePoke(option, switching = false)
      for i in 0...Settings::MAX_PARTY_SIZE
        @sprites["pokemon#{i}"].preselected = (switching && i == @activecmd)
        @sprites["pokemon#{i}"].switching   = switching
      end
      @sprites["pokemon#{@activecmd}"].selected = false if switching
      @activecmd = 0
      for i in 0...Settings::MAX_PARTY_SIZE
        @sprites["pokemon#{i}"].selected = (i == @activecmd)
      end
      itemwindow = @sprites["itemlist"]
      item = itemwindow.item
      pbChangeCursor(1)
      loop do
        Graphics.update
        Input.update
        pbUpdate
        oldsel = @activecmd
        key = -1
        key = Input::DOWN if Input.repeat?(Input::DOWN) && @party.length > 2
        key = Input::RIGHT if Input.repeat?(Input::RIGHT)
        key = Input::LEFT if Input.repeat?(Input::LEFT)
        key = Input::UP if Input.repeat?(Input::UP) && @party.length > 2
        if key >= 0 && @party.length > 1
          @activecmd = pbChangeSelection(key, @activecmd)
        end
        if @activecmd != oldsel
          pbPlayCursorSE
          numsprites = Settings::MAX_PARTY_SIZE
          for i in 0...numsprites
            @sprites["pokemon#{i}"].selected = (i == @activecmd)
          end
        end
        if Input.trigger?(Input::C)
          pkmn = @party[@activecmd]
          if option == 0
            return @activecmd
          elsif option == 1
            if @activecmd >= 0
              ret = pbGiveItemToPokemon(item, @party[@activecmd], self, @activecmd)
              pbChangeCursor(2)
              @sprites["pokemon#{@activecmd}"].selected = false
              break
            end
          elsif option == 2
            ret = pbBagUseItem(@bag, item, PokemonBagScreen, self, @activecmd)
            pbRefresh; pbUpdateAnnotation
            if !$bag.has?(item)
              @sprites["pokemon#{@activecmd}"].selected = false
              pbChangeCursor(2)
              break
            end
          elsif option == 3
            pbPlayDecisionSE
            loop do
              cmdSummary     = -1
              cmdTake        = -1 
              cmdMove        = -1
              commands = []
              commands[cmdSummary = commands.length]       = _INTL("Summary")
              commands[cmdTake = commands.length]          = _INTL("Take Item") if pkmn.hasItem?
              commands[cmdMove = commands.length]          = _INTL("Move Item") if pkmn.hasItem? && !GameData::Item.get(pkmn.item).is_mail?
              commands[commands.length]                    = _INTL("Cancel")
              if pkmn.hasItem?
                item = pkmn.item
                itemname = item.portion_name
                article = (itemname.starts_with_vowel?) ? "an" : "a"
                command = pbShowCommands(_INTL("{1} is holding {2} {3}.", pkmn.name, article, itemname), commands)
              else
                command = pbShowCommands(_INTL("{1} is selected.", pkmn.name), commands)
              end
              if cmdSummary >= 0 && command == cmdSummary
                pbSummary(@activecmd)
              elsif cmdTake >= 0 && command == cmdTake && pkmn.hasItem?
                if pbTakeItemFromPokemon(pkmn, self)
                  pbRefresh
                end
                break
              elsif cmdMove >= 0 && command == cmdMove && pkmn.hasItem? && !GameData::Item.get(pkmn.item).is_mail?
                oldpkmn = pkmn
                loop do
                  pbPreSelect(oldpkmn)
                  newpkmn = pbChoosePoke(4, true)
                  if newpkmn < 0
                    pbClearSwitching
                    break 
                  end
                  newpkmn = @party[newpkmn]
                  if newpkmn == oldpkmn
                    pbClearSwitching
                    break 
                  end
                  if newpkmn.egg?
                    pbDisplay(_INTL("Eggs can't hold items."))
                  elsif !newpkmn.hasItem?
                    newpkmn.item = item
                    oldpkmn.item = nil
                    pbClearSwitching; pbRefresh
                    pbDisplay(_INTL("{1} was given the {2} to hold.", newpkmn.name, itemname))
                    break
                  elsif GameData::Item.get(newpkmn.item).is_mail?
                    pbDisplay(_INTL("{1}'s mail must be removed before giving it an item.", newpkmn.name))
                  else
                    newitem = newpkmn.item
                    newitemname = newitem.portion_name
                    if newitemname.starts_with_vowel?
                      pbDisplay(_INTL("{1} is already holding an {2}.\1", newpkmn.name, newitemname))
                    else
                      pbDisplay(_INTL("{1} is already holding a {2}.\1", newpkmn.name, newitemname))
                    end
                    if pbConfirm(_INTL("Would you like to switch the two items?"))
                      newpkmn.item = item
                      oldpkmn.item = newitem
                      pbClearSwitching; pbRefresh
                      pbDisplay(_INTL("{1} was given the {2} to hold.", newpkmn.name, itemname))
                      pbDisplay(_INTL("{1} was given the {2} to hold.", oldpkmn.name, newitemname))
                    end
                    break
                  end
                end
                break
              else
                break
              end
            end
          elsif option == 4
            return @activecmd
          end
        elsif Input.trigger?(Input::B)
          pbPlayCancelSE
          itemwindow.partysel = false; pbRefresh
          if switching
            return -1
          elsif option == 0
            @sprites["pokemon#{@activecmd}"].selected = false
            return -1
          else
            @sprites["pokemon#{@activecmd}"].selected = false
            return
          end
        end
        break if ret == 2 && option == 2
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Updated to include improved item text.
  #-----------------------------------------------------------------------------
  class PokemonBagScreen
    def pbStartScreen
      @scene.pbStartScene(@bag, $player.party)
      item = nil
      loop do
        item = @scene.pbChooseItem
        break if !item
        itm = GameData::Item.get(item)
        cmdRead     = -1
        cmdUse      = -1
        cmdRegister = -1
        cmdGive     = -1
        cmdToss     = -1
        cmdDebug    = -1
        commands = []
        commands[cmdRead = commands.length]       = _INTL("Read") if itm.is_mail?
        if ItemHandlers.hasOutHandler(item) || (itm.is_machine? && $player.party.length > 0)
          if ItemHandlers.hasUseText(item)
            commands[cmdUse = commands.length]    = ItemHandlers.getUseText(item)
          else
            commands[cmdUse = commands.length]    = _INTL("Use")
          end
        end
        commands[cmdGive = commands.length]       = _INTL("Give") if $player.pokemon_party.length > 0 && itm.can_hold?
        commands[cmdToss = commands.length]       = _INTL("Toss") if !itm.is_important? || $DEBUG
        if @bag.registered?(item)
          commands[cmdRegister = commands.length] = _INTL("Deselect")
        elsif pbCanRegisterItem?(item)
          commands[cmdRegister = commands.length] = _INTL("Register")
        end
        commands[cmdDebug = commands.length]      = _INTL("Debug") if $DEBUG
        commands[commands.length]                 = _INTL("Cancel")
        itemname = itm.name
        command = @scene.pbShowCommands(_INTL("{1} is selected.", itemname), commands)
        if cmdRead >= 0 && command == cmdRead
          pbFadeOutIn {
            pbDisplayMail(Mail.new(item, "", ""))
          }
        elsif cmdUse >= 0 && command == cmdUse
          useType = itm.field_use
          if useType == 1
            ret = @scene.pbChoosePoke(2, false)
          elsif useType == 3 || useType == 4 || useType == 5
            machine = itm.move
            movename = GameData::Move.get(machine).name
            pbMessage(_INTL("\\se[PC access]You booted up {1}.\1", itm.name)) {@scene.pbUpdate}
            if pbConfirmMessage(_INTL("Do you want to teach {1} to a Pokémon?", movename)) {@scene.pbUpdate}
              ret = @scene.pbChoosePoke(2, false)
            end
          else
            ret = pbUseItem(@bag, item, @scene)
          end
          break if ret == 2
          @scene.pbRefresh
          next
        elsif cmdGive >= 0 && command == cmdGive
          if $player.pokemon_count == 0
            @scene.pbDisplay(_INTL("There is no Pokémon."))
          elsif itm.is_important?
            @scene.pbDisplay(_INTL("The {1} can't be held.",itm.portion_name))
          else
            @scene.pbChoosePoke(1, false)
          end
        elsif cmdToss >= 0 && command == cmdToss
          qty = @bag.quantity(item)
          if qty > 1
            helptext = _INTL("Toss out how many {1}?", itm.portion_name_plural)
            qty = @scene.pbChooseNumber(helptext, qty)
          end
          if qty > 0
            itemname = (qty > 1) ? itm.portion_name_plural : itm.portion_name
            if pbConfirm(_INTL("Is it OK to throw away {1} {2}?", qty, itemname))
              pbDisplay(_INTL("Threw away {1} {2}.",qty, itemname))
              @bag.remove(item, qty)
              @scene.pbRefresh
            end
          end
        elsif cmdRegister >= 0 && command == cmdRegister
          if @bag.registered?(item)
            @bag.unregister(item)
          else
            @bag.register(item)
          end
          @scene.pbRefresh
        elsif cmdDebug >= 0 && command == cmdDebug
          command = 0
          loop do
            command = @scene.pbShowCommands(_INTL("Do what with {1}?", itemname),
                                            [_INTL("Change quantity"),
                                             _INTL("Make Mystery Gift"),
                                             _INTL("Cancel")], command)
            case command
            when -1, 2
              break
            when 0
              qty = @bag.quantity(item)
              itemplural = itm.name_plural
              params = ChooseNumberParams.new
              params.setRange(0, Settings::BAG_MAX_PER_SLOT)
              params.setDefaultValue(qty)
              newqty = pbMessageChooseNumber(
                _INTL("Choose new quantity of {1} (max. #{Settings::BAG_MAX_PER_SLOT}).",itemplural),params
                ) { @scene.pbUpdate }
              if newqty > qty
                @bag.add(item, newqty - qty)
              elsif newqty < qty
                @bag.remove(item, qty - newqty)
              end
              @scene.pbRefresh
              break if newqty == 0
            when 1
              pbCreateMysteryGift(1, item)
            end
          end
        end
      end
      ($game_temp.fly_destination) ? @scene.dispose : @scene.pbEndScene
      return item
    end
    
    def pbWithdrawItemScreen
      if !$PokemonGlobal.pcItemStorage
        $PokemonGlobal.pcItemStorage = PCItemStorage.new
      end
      storage = $PokemonGlobal.pcItemStorage
      @scene.pbStartScene(storage,$player.party)
      loop do
        item = @scene.pbChooseItem
        break if !item
        itm = GameData::Item.get(item)
        qty = storage.quantity(item)
        if qty > 1 && !itm.is_important?
          qty = @scene.pbChooseNumber(_INTL("How many do you want to withdraw?"), qty)
        end
        next if qty <= 0
        if @bag.can_add?(item, qty)
          if !storage.remove(item, qty)
            raise "Can't delete items from storage"
          end
          if !@bag.add(item, qty)
            raise "Can't withdraw items from storage"
          end
          @scene.pbRefresh
          dispqty = (itm.is_important?) ? 1 : qty
          itemname = (dispqty > 1) ? itm.portion_name_plural : itm.portion_name
          pbDisplay(_INTL("Withdrew {1} {2}.", dispqty, itemname))
        else
          pbDisplay(_INTL("There's no more room in the Bag."))
        end
      end
      @scene.pbEndScene
    end
    
    def pbDepositItemScreen
      @scene.pbStartScene(@bag,$player.party)
      if !$PokemonGlobal.pcItemStorage
        $PokemonGlobal.pcItemStorage = PCItemStorage.new
      end
      storage = $PokemonGlobal.pcItemStorage
      loop do
        item = @scene.pbChooseItem
        break if !item
        itm = GameData::Item.get(item)
        qty = @bag.quantity(item)
        if qty > 1 && !itm.is_important?
          qty = @scene.pbChooseNumber(_INTL("How many do you want to deposit?"), qty)
        end
        if qty > 0
          if storage.can_add?(item, qty)
            if !@bag.remove(item, qty)
              raise "Can't delete items from Bag"
            end
            if !storage.add(item, qty)
              raise "Can't deposit items to storage"
            end
            @scene.pbRefresh
            dispqty  = (itm.is_important?) ? 1 : qty
            itemname = (dispqty > 1) ? itm.portion_name_plural : itm.portion_name
            pbDisplay(_INTL("Deposited {1} {2}.", dispqty, itemname))
          else
            pbDisplay(_INTL("There's no room to store items."))
          end
        end
      end
      @scene.pbEndScene
    end
    
    def pbTossItemScreen
      if !$PokemonGlobal.pcItemStorage
        $PokemonGlobal.pcItemStorage = PCItemStorage.new
      end
      storage = $PokemonGlobal.pcItemStorage
      @scene.pbStartScene(storage,$player.party)
      loop do
        item = @scene.pbChooseItem
        break if !item
        itm = GameData::Item.get(item)
        if itm.is_important?
          @scene.pbDisplay(_INTL("That's too important to toss out!"))
          next
        end
        qty = storage.quantity(item)
        itemname       = itm.portion_name
        itemnameplural = itm.portion_name_plural
        if qty > 1
          qty = @scene.pbChooseNumber(_INTL("Toss out how many {1}?", itemnameplural), qty)
        end
        next if qty <= 0
        itemname = itemnameplural if qty > 1
        next if !pbConfirm(_INTL("Is it OK to throw away {1} {2}?", qty, itemname))
        if !storage.remove(item, qty)
          raise "Can't delete items from storage"
        end
        @scene.pbRefresh
        pbDisplay(_INTL("Threw away {1} {2}.", qty, itemname))
      end
      @scene.pbEndScene
    end
  end
  
  #-----------------------------------------------------------------------------
  # Updated to for Tera Shard compatibility.
  #-----------------------------------------------------------------------------
  def pbBagUseItem(bag, item, scene, screen, chosen, bagscene = nil)
    found   = false
    pkmn    = $player.party[chosen]
    itm     = GameData::Item.get(item)
    useType = itm.field_use
    qty     = 1
    if itm.is_machine?
      if $player.pokemon_count == 0
        pbMessage(_INTL("There is no Pokémon.")) { screen.pbUpdate }
        return 0
      end
      machine = itm.move
      return 0 if !machine
      movename = GameData::Move.get(machine).name
      move     = GameData::Move.get(machine).id
      movelist = nil; bymachine = false; oneusemachine = false
      if movelist != nil && movelist.is_a?(Array)
        for i in 0...movelist.length
          movelist[i] = GameData::Move.get(movelist[i]).id
        end
      end
      if pkmn.egg?
        pbMessage(_INTL("Eggs can't be taught any moves.")) { screen.pbUpdate }
      elsif pkmn.shadowPokemon?
        pbMessage(_INTL("Shadow Pokémon can't be taught any moves.")) { screen.pbUpdate }
      elsif movelist && !movelist.any? { |j| j == pkmn.species }
        pbMessage(_INTL("{1} can't learn {2}.", pkmn.name, movename)) { screen.pbUpdate }
      elsif !pkmn.compatible_with_move?(move)
        pbMessage(_INTL("{1} can't learn {2}.", pkmn.name, movename)) { screen.pbUpdate }
      else
        if pbLearnMove(pkmn, move, false, bymachine) { screen.pbUpdate }
          pkmn.add_first_move(move) if oneusemachine
          bag.remove(itm) if itm.consumed_after_use?
        end
      end
      screen.pbRefresh; screen.pbUpdate
      return 1
    elsif useType == 1
      if $player.pokemon_count == 0
        pbMessage(_INTL("There is no Pokémon.")) { screen.pbUpdate }
        return 0
      end
      ret = false
      screen.pbRefresh
      #-------------------------------------------------------------------------
      # Tera Shard compatibility
      #-------------------------------------------------------------------------
      if PluginManager.installed?("Terastal Phenomenon") && itm.is_tera_shard?
        tera = itm.tera_shard_type
        qty = [1, Settings::TERA_SHARDS_REQUIRED].max
        qty = 1 if !GameData::Type.exists?(tera)
        if !$bag.has?(item, qty)
          pbMessage(_INTL("You don't have enough {1}..." +
                          "\nYou need {2} Tera Shards to change a Pokémon's Tera Type.", itm.portion_name_plural, qty))
          return 0
        end
      end
      #-------------------------------------------------------------------------
      if pbCheckUseOnPokemon(item, pkmn, screen)
        ret = ItemHandlers.triggerUseOnPokemon(item, qty, pkmn, screen)
        if ret && useType == 1
          $bag.remove(item, qty)  if itm.consumed_after_use? { screen.pbRefresh }
        end
        if !$bag.has?(item)
          #---------------------------------------------------------------------
          # Tera Shard compatibility
          #---------------------------------------------------------------------
          if itm.is_tera_shard? && qty > 1
            screen.pbDisplay(_INTL("Not enough {1} remaining...", itm.portion_name_plural)) { screen.pbUpdate }
          else
            screen.pbDisplay(_INTL("You used your last {1}.", itm.portion_name_plural)) { screen.pbUpdate }
          end
          screen.pbChangeCursor(2)
        end
        screen.pbRefresh
      end
      bagscene.pbRefresh if bagscene
      return 1
    else
      pbMessage(_INTL("Can't use that here.")) { screen.pbUpdate }
      return 0
    end
  end
end