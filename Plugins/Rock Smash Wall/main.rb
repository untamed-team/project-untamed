#=============================================================================
# Rock Smash Wall
#=============================================================================
#keep the fossil as the first item in the loot table

def pbRockSmashWall(chance, lootTable)
  return if !pbRockSmashWallQuestion #player used rock smash successfully
  outcome = rand(100)
  return 2 if outcome > chance #player failed to get loot even though they used Rock Smash successfully
  #success, get loot
  fossilID = lootTable[0][:item]
  fossilData = GameData::Item.get(fossilID)
  
  if $item_log.found_items.contains?(fossilData) #check if player already has the fossil
    #player already has the fossil
    item = selectItemFromLootTable(lootTable)
    pbItemBall(item)
  else
    #player does not have the fossil yet
    fossilRoll = rand(100)
    if fossilRoll <= INITIAL_FOSSIL_CHANCE
      pbItemBall(fossilID)
    else
      item = selectItemFromLootTable(lootTable)
      pbItemBall(item)
    end
  end
  return 1
end #def pbRockSmashWall(chance)

def pbRockSmashWallQuestion
  return true if $DEBUG && Input.press?(Input::CTRL)
  move = :ROCKSMASH
  movefinder = $player.get_pokemon_with_move(move)
  if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_ROCKSMASH, false) || (!$DEBUG && !movefinder)
    pbMessage(_INTL("It's a cracked, rocky wall, but a Pokémon may be able to smash it."))
    return false
  end
  if pbConfirmMessage(_INTL("This wall seems breakable with a hidden move.\nWould you like to use Rock Smash?"))
    $stats.rock_smash_count += 1
    speciesname = (movefinder) ? movefinder.name : $player.name
    pbMessage(_INTL("{1} used {2}!", speciesname, GameData::Move.get(move).name))
    pbHiddenMoveAnimation(movefinder)
    return true
  end
  return false
end #def pbRockSmashWallQuestion

INITIAL_FOSSIL_CHANCE = 80

def selectItemFromLootTable(lootTable)
  total_chance = 0
  lootTable.each do |entry|
    total_chance += entry[:chance]
  end
  echoln "warning: total cumulative is not equal to 100" if total_chance != 100 && $DEBUG
  roll = rand(total_chance)
  cumulative_chance = 0
  lootTable.shuffle.each do |entry|
    cumulative_chance += entry[:chance]
    return entry[:item] if roll < cumulative_chance
  end
end

#create the loot table as if chances will not be modified
#if the player does not have the fossil yet, the plugin will add extra entries for the fossil until the amount of entries for the fossil is equal to INITIAL_FOSSIL_CHANCE
#keep the fossil as the first element

ROCK_SMASH_WALL_LOOT_TABLE_OPAL = [
 { item: :OPALFOSSIL, chance: 5 }, 
 { item: :OVALSTONE, chance: 25 },
 { item: :REVIVE, chance: 25 },
 { item: :PEARL, chance: 15 },
 { item: :MAXREVIVE, chance: 15 },
 { item: :RAREBONE, chance: 10 },
 { item: :STARPIECE, chance: 5 }
]

ROCK_SMASH_WALL_LOOT_TABLE_TAR = [
 { item: :TARFOSSIL, chance: 5 }, 
 { item: :EVERSTONE, chance: 25 },
 { item: :REVIVE, chance: 25 },
 { item: :STARDUST, chance: 15 },
 { item: :MAXREVIVE, chance: 15 },
 { item: :RAREBONE, chance: 10 },
 { item: :STARPIECE, chance: 5 }
]