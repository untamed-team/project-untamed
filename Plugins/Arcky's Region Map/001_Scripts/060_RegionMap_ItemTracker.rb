if ARMSettings::PROGRESS_COUNTER && ARMSettings::PROGRESS_COUNT_ITEMS
  #===============================================================================
  # Picking up an item found on the ground
  #===============================================================================
  def pbItemBall(item, quantity = 1)
    item = GameData::Item.get(item)
    return false if !item || quantity < 1
    itemInfo = getItemInfo(item, quantity, false)
    result = getItemMessage(itemInfo)
    if $item_log && result 
      ItemLog.showItemScene(item) if $item_log.register(item) != nil
    end
    return result
  end

  #===============================================================================
  # Being given an item
  #===============================================================================
  def pbReceiveItem(item, quantity = 1)
    item = GameData::Item.get(item)
    return false if !item || quantity < 1
    itemInfo = getItemInfo(item, quantity, true)
    result = getItemMessage(itemInfo)
    if $item_log && result 
      ItemLog.showItemScene(item) if $item_log.register(item) != nil
    end
    return result
  end

  #===============================================================================
  # Item handler
  #===============================================================================
  def getItemInfo(item, quantity, verb)
    if Essentials::VERSION.include?("21")
      itemname = (quantity > 1) ? item.portion_name_plural : item.portion_name
    elsif Essentials::VERSION.include?("20")
      itemname = (quantity > 1) ? item.name_plural : item.name
    end 
    pocket = item.pocket
    move = item.move
    meName = (item.is_key_item?) ? "Key item get" : "Item get"
    verb = verb ? "obtained" : "found" 
    bag = $bag.add(item, quantity) ? true : false 
    return { item: item, itemname: itemname, quantity: quantity, pocket: pocket, move: move, meName: meName, verb: verb, bag: bag }
  end 

  #===============================================================================
  # Item Message handler
  #===============================================================================
  def getItemMessage(itemInfo)
    sound = itemInfo[:bag] ? "\\me[#{itemInfo[:meName]}]" : ""
    wait = itemInfo[:bag] ? "\\wtnp[40]" : ""
    if itemInfo[:item] == :DNASPLICERS && itemInfo[:bag]
      pbMessage("#{sound}" + _INTL("You {1} \\c[1]{2}\\c[0]!", itemInfo[:verb], itemInfo[:itemname]) + "#{wait}")
    elsif itemInfo[:item].is_machine?   # TM or HM
      sound = itemInfo[:bag] ? "\\me[Machine get]" : ""
      wait = itemInfo[:bag] ? "\\wtnp[70]" : ""
      if itemInfo[:quantity] > 1
        pbMessage("#{sound}" + _INTL("You {1} {2} \\c[1]{3} {4}\\c[0]!",
                                              itemInfo[:verb], itemInfo[:quantity], itemInfo[:itemname], GameData::Move.get(itemInfo[:move]).name) + "#{wait}")
      else
        pbMessage("#{sound}" + _INTL("You {1} \\c[1]{2} {3}\\c[0]!",
                                              itemInfo[:verb], itemInfo[:itemname], GameData::Move.get(itemInfo[:move]).name) + "#{wait}")
      end
    elsif itemInfo[:quantity] > 1
      pbMessage("#{sound}" + _INTL("You {1} {2} \\c[1]{3}\\c[0]!", itemInfo[:verb], itemInfo[:quantity], itemInfo[:itemname]) + "#{wait}")
    elsif itemInfo[:itemname].starts_with_vowel?
      pbMessage("#{sound}" + _INTL("You {1} an \\c[1]{2}\\c[0]!", itemInfo[:verb], itemInfo[:itemname]) + "#{wait}")
    else
      pbMessage("#{sound}" + _INTL("You {1} a \\c[1]{2}\\c[0]!", itemInfo[:verb], itemInfo[:itemname]) + "#{wait}")
    end
    if itemInfo[:bag]
      pbMessage(_INTL("You put the {1} in\\nyour Bag's <icon=bagPocket{2}>\\c[1]{3}\\c[0] pocket.",
                    itemInfo[:itemname], itemInfo[:pocket], PokemonBag.pocket_names[itemInfo[:pocket] - 1]))
      countItem(itemInfo)
      return true
    else 
      pbMessage(_INTL("But your Bag is full..."))
      return false
    end
  end 

  def countItem(itemInfo)
    mapID = $game_map.map_id
    map = load_data(sprintf("Data/Map%03d.rxdata", mapID))
    eventID = pbMapInterpreter.get_self.id
    return if map.nil? || !map.events[eventID].name[/item/i]
    map = GameData::MapMetadata.try_get(mapID)
    district = getDistrictName(map)
    $ArckyGlobal.itemTracker[district] ||= { :total => 0 }
    $ArckyGlobal.itemTracker[district][:maps] ||= {}
    $ArckyGlobal.itemTracker[district][:maps][mapID] ||= { :found => 0}
    $ArckyGlobal.itemTracker[district][:maps][mapID][eventID] ||= { :found => 0, :items => [] }
    unless $ArckyGlobal.itemTracker[district][:maps][mapID][eventID][:items].include?(itemInfo[:item])
      $ArckyGlobal.itemTracker[district][:maps][mapID][eventID][:items] += [itemInfo[:item]]
      $ArckyGlobal.itemTracker[district][:maps][mapID][eventID][:found] += itemInfo[:quantity]
      $ArckyGlobal.itemTracker[district][:total] += itemInfo[:quantity]
      $ArckyGlobal.itemTracker[district][:maps][mapID][:found] += itemInfo[:quantity]
    end
  end
end 