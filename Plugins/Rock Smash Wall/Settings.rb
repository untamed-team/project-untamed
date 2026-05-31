class RockSmashWall
	CHANCE_TO_ACTIVATE_ROCK_SMASH_WALL = 100
	INITIAL_FOSSIL_CHANCE = 80

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

	if $player
		if $player.difficulty_mode?("chaos")
			ROCK_SMASH_WALL_LOOT_TABLE_OPAL = [
				{ item: :SAILFOSSIL, chance: 5 }, 
				{ item: :OVALSTONE, chance: 25 },
				{ item: :REVIVE, chance: 25 },
				{ item: :PEARL, chance: 15 },
				{ item: :MAXREVIVE, chance: 15 },
				{ item: :RAREBONE, chance: 10 },
				{ item: :STARPIECE, chance: 5 }
			]
			ROCK_SMASH_WALL_LOOT_TABLE_TAR = [
				{ item: :JAWFOSSIL, chance: 5 }, 
				{ item: :EVERSTONE, chance: 25 },
				{ item: :REVIVE, chance: 25 },
				{ item: :STARDUST, chance: 15 },
				{ item: :MAXREVIVE, chance: 15 },
				{ item: :RAREBONE, chance: 10 },
				{ item: :STARPIECE, chance: 5 }
			]
		end
	end

end #class RockSmashWall