def pbAutoPlantBerry(events, map = nil)
    if !PluginManager.installed?("TDW Berry Core and Dex","1.1")
        Console.echo_warn("TDW Berry Core and Dex v1.1 is required to use autoplanting.") 
        return pbMessage(_INTL("Autoplanting cannot be done."))
    end
    if Settings::BERRY_USE_BERRY_SEEDS
        Console.echo_warn("Autoplanting berry seeds is not yet supported.") 
        return pbMessage(_INTL("Oh I don't know how to plant seeds yet. Maybe one day."))
    end
    pbMessage(_INTL("I can plant some Berries for you!"))
    return if !pbConfirmMessage(_INTL("Do you want me to plant some of your Berries?"))
    count = (events.length < 6) ? events.length : 6
    berries = pbChooseBerryMultiple(count, true)
    return pbMessage(_INTL("Let me know if you change your mind!")) if !berries || berries.empty?
    ret = nil
    pbFadeOutIn {
        pbWait(4)
        ret = pbPlantBerriesAutomatically(events, map, berries)
        pbWait(4)
    }
    if ret
        if ret.length == berries.length
            pbMessage(_INTL("I wasn't able to plant the Berries. Here, have them back!"))
        else
            pbMessage(_INTL("I planted some of the Berries, but not all of them. Here are the ones left over!"))
        end
        berries.each {|berry| $bag.add(berry)}
    else
        pbMessage(_INTL("I've planted all of the Berries you gave me!"))
    end
end

def pbPlantBerriesAutomatically(events, map_id, berries)
    map_id ||= $game_map.map_id
    berries.shuffle!
    events.each {|event|
        data = $PokemonGlobal.eventvars[[map_id,event]]
        next Console.echo_warn _INTL("Event #{event} doesn't have BerryPlantData.")  if data.nil? || !data.is_a?(BerryPlantData) 
        next if data.planted?
        data.plant(berries.pop.id)
        $stats.berries_auto_planted ||= 0
        $stats.berries_auto_planted += 1
        break if berries.empty?
    }
    #$scene.updateSpritesets
    return berries.empty? ? nil : berries
end