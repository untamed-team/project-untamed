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
  end
end