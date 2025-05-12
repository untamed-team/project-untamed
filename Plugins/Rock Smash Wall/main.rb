#=============================================================================
# Rock Smash Wall
#=============================================================================
#keep the fossil as the first item in the loot table

def pbRockSmashWall(chance, lootTable)
  if pbRockSmashWallQuestion
    #player used rock smash successfully
    outcome = rand(100)
    if outcome <= chance
      #success, get loot
	  fossilID = lootTable[0]
	  fossilData = GameData::Item.get(fossilID)
	  
	  if !$item_log.found_items.contains?(fossilData) #check if player already has the fossil
		#player does not have the fossil yet
		fossilRoll = rand(100)
		if fossilRoll <= INITIAL_FOSSIL_CHANCE
			pbItemBall(fossilID)
		else
			item = lootTable.sample
			pbItemBall(item)
		end
		
	  else
		#player already has the fossil
		item = lootTable.sample
		pbItemBall(item)
	  end
	  return 1
    else
		#player failed to get loot even though they used Rock Smash successfully
		return 2
	end #if outcome <= chance
  end #if pbRockSmashWallQuestion
end #def pbRockSmashWall(chance)

def pbRockSmashWallQuestion
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

#create the loot table as if chances will not be modified
#if the player does not have the fossil yet, the plugin will add extra entries for the fossil until the amount of entries for the fossil is equal to INITIAL_FOSSIL_CHANCE
#keep the fossil as the first element in the array
ROCK_SMASH_WALL_LOOT_TABLE_OPAL = [
:OPALFOSSIL,
:OPALFOSSIL,
:OPALFOSSIL,
:OPALFOSSIL,
:OPALFOSSIL,
:OPALFOSSIL,
:OPALFOSSIL,
:OPALFOSSIL,
:OPALFOSSIL,
:OPALFOSSIL,
:POTION,
:POTION,
:POTION,
:POTION,
:POTION,
:POTION,
:POTION,
:POTION,
:POTION,
:POTION,
:SUPERPOTION,
:SUPERPOTION,
:SUPERPOTION,
:SUPERPOTION,
:SUPERPOTION,
:SUPERPOTION,
:SUPERPOTION,
:SUPERPOTION,
:SUPERPOTION,
:SUPERPOTION,
:HYPERPOTION,
:HYPERPOTION,
:HYPERPOTION,
:HYPERPOTION,
:HYPERPOTION,
:HYPERPOTION,
:HYPERPOTION,
:HYPERPOTION,
:HYPERPOTION,
:HYPERPOTION,
:MAXPOTION,
:MAXPOTION,
:MAXPOTION,
:MAXPOTION,
:MAXPOTION,
:MAXPOTION,
:MAXPOTION,
:MAXPOTION,
:MAXPOTION,
:MAXPOTION,
:POKEBALL,
:POKEBALL,
:POKEBALL,
:POKEBALL,
:POKEBALL,
:POKEBALL,
:POKEBALL,
:POKEBALL,
:POKEBALL,
:POKEBALL,
:GREATBALL,
:GREATBALL,
:GREATBALL,
:GREATBALL,
:GREATBALL,
:GREATBALL,
:GREATBALL,
:GREATBALL,
:GREATBALL,
:GREATBALL,
:ULTRABALL,
:ULTRABALL,
:ULTRABALL,
:ULTRABALL,
:ULTRABALL,
:ULTRABALL,
:ULTRABALL,
:ULTRABALL,
:ULTRABALL,
:ULTRABALL,
:MASTERBALL,
:MASTERBALL,
:MASTERBALL,
:MASTERBALL,
:MASTERBALL,
:MASTERBALL,
:MASTERBALL,
:MASTERBALL,
:MASTERBALL,
:MASTERBALL,
:TINYMUSHROOM,
:TINYMUSHROOM,
:TINYMUSHROOM,
:TINYMUSHROOM,
:TINYMUSHROOM,
:TINYMUSHROOM,
:TINYMUSHROOM,
:TINYMUSHROOM,
:TINYMUSHROOM,
:TINYMUSHROOM,
]

ROCK_SMASH_WALL_LOOT_TABLE_TAR = [
:TARFOSSIL,
:TARFOSSIL,
:TARFOSSIL,
:TARFOSSIL,
:TARFOSSIL,
:TARFOSSIL,
:TARFOSSIL,
:TARFOSSIL,
:TARFOSSIL,
:TARFOSSIL,
:POTION,
:POTION,
:POTION,
:POTION,
:POTION,
:POTION,
:POTION,
:POTION,
:POTION,
:POTION,
:SUPERPOTION,
:SUPERPOTION,
:SUPERPOTION,
:SUPERPOTION,
:SUPERPOTION,
:SUPERPOTION,
:SUPERPOTION,
:SUPERPOTION,
:SUPERPOTION,
:SUPERPOTION,
:HYPERPOTION,
:HYPERPOTION,
:HYPERPOTION,
:HYPERPOTION,
:HYPERPOTION,
:HYPERPOTION,
:HYPERPOTION,
:HYPERPOTION,
:HYPERPOTION,
:HYPERPOTION,
:MAXPOTION,
:MAXPOTION,
:MAXPOTION,
:MAXPOTION,
:MAXPOTION,
:MAXPOTION,
:MAXPOTION,
:MAXPOTION,
:MAXPOTION,
:MAXPOTION,
:POKEBALL,
:POKEBALL,
:POKEBALL,
:POKEBALL,
:POKEBALL,
:POKEBALL,
:POKEBALL,
:POKEBALL,
:POKEBALL,
:POKEBALL,
:GREATBALL,
:GREATBALL,
:GREATBALL,
:GREATBALL,
:GREATBALL,
:GREATBALL,
:GREATBALL,
:GREATBALL,
:GREATBALL,
:GREATBALL,
:ULTRABALL,
:ULTRABALL,
:ULTRABALL,
:ULTRABALL,
:ULTRABALL,
:ULTRABALL,
:ULTRABALL,
:ULTRABALL,
:ULTRABALL,
:ULTRABALL,
:MASTERBALL,
:MASTERBALL,
:MASTERBALL,
:MASTERBALL,
:MASTERBALL,
:MASTERBALL,
:MASTERBALL,
:MASTERBALL,
:MASTERBALL,
:MASTERBALL,
:TINYMUSHROOM,
:TINYMUSHROOM,
:TINYMUSHROOM,
:TINYMUSHROOM,
:TINYMUSHROOM,
:TINYMUSHROOM,
:TINYMUSHROOM,
:TINYMUSHROOM,
:TINYMUSHROOM,
:TINYMUSHROOM,
]