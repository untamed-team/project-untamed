#=============================================================================
# Rock Smash Wall
#=============================================================================
class RockSmashWall
	def self.findRockSmashWallsOnMap
		#go through all events on the current map and only do something if an event on the map is named "DigSpot"
		$game_map.events.each_value do |event|
			next if event.name != "RockSmashWall"
			Console.echo_warn "found a RockSmashWall with event id #{event.id}"
			
			#roll to activate dig spots
			if self.rollToActivateRockSmashWall
				Console.echo_warn "roll successful for RockSmashWall. Activiating RockSmashWall with event ID #{event.id}"
				pbMapInterpreter.pbSetSelfSwitch(event.id, "A", true)
			else
				Console.echo_warn "roll unsuccessful for RockSmashWall. RockSmashWall with event ID #{event.id} will not be activated"
				pbMapInterpreter.pbSetSelfSwitch(event.id, "A", false)
			end #if self.rollToActivateRockSmashWall
		end #$game_map.events.each_value do |event|
	end #def self.findRockSmashWallsOnMap
	
	def self.rollToActivateRockSmashWall
		chance = rand(100)
		return true if chance <= CHANCE_TO_ACTIVATE_ROCK_SMASH_WALL
		return false
	end
	
	def self.interact(lootTable, eventID, fieldMove=nil)
		if fieldMove || self.pbRockSmashWallQuestion
			#roll for successful loot drop
			
			@foundComment = false
			facingEvent = $game_player.pbFacingEvent
			commands = facingEvent.list
	
			comment = ""
			commands.each do |command|
				# Command code for a comment is 108
				if command.code == 108
					# The text is in the first element of the parameters array
					comment = command.parameters[0]
					break if @foundComment # Stop searching after finding the SECOND comment
					@foundComment = true
				end #if command.code == 108
			end #commands.each do |command|
			
			chance = comment.to_i
			self.pbRockSmashWall(chance, lootTable)
			#set event's self switch A to off
			pbMapInterpreter.pbSetSelfSwitch(eventID, "A", false)
		end
	end #def self.interact
	
	
	
	
	
	
	
	
	
	
	
	
	
	def self.pbRockSmashWall(chance, lootTable)
		#return if !pbRockSmashWallQuestion #player used rock smash successfully
		outcome = rand(100)
		if outcome > chance #player failed to get loot even though they used Rock Smash successfully
			pbMessage(_INTL("Nothing of note was found..."))
			return 2 
		end
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
	end #def self.pbRockSmashWall(chance, lootTable)

	def self.pbRockSmashWallQuestion
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
	end #def self.pbRockSmashWallQuestion

	def self.selectItemFromLootTable(lootTable)
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
	end #def self.selectItemFromLootTable(lootTable)
	
	#==============================================
	#Event Handlers
	#==============================================
	EventHandlers.add(:on_enter_map, :spawn_rock_smash_wall,
		proc { |_old_map_id|

		#if oldMapID and currentMapID match, the game was just loaded. Skip generating rock smash wall
		next if _old_map_id == $game_map.map_id
		RockSmashWall.findRockSmashWallsOnMap
	})

	EventHandlers.add(:on_player_interact, :rockSmashWall, proc {
		facingEvent = $game_player.pbFacingEvent
		next if facingEvent.nil?
		#if player is facing an event, check if it's a rockSmashWall
		if !facingEvent.nil?
			next if facingEvent.name != "RockSmashWall"
			commands = facingEvent.list
			next if  commands.nil?
	
			comment = ""
			commands.each do |command|
				# Command code for a comment is 108
				if command.code == 108
					# The text is in the first element of the parameters array
					comment = command.parameters[0]
					break # Stop searching after finding the first comment
				end #if command.code == 108
			end #commands.each do |command|
			lootTable = RockSmashWall.const_get(comment)
			RockSmashWall.interact(lootTable, facingEvent.id) if facingEvent
		end
	})

	HiddenMoveHandlers::CanUseMove.add(:ROCKSMASH, proc { |move, pkmn, showmsg|
		next false if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_ROCKSMASH, showmsg)
		facingEvent = $game_player.pbFacingEvent
		if !facingEvent || (!facingEvent.name[/smashrock/i] && !facingEvent.name[/RockSmashWall/i])
			pbMessage(_INTL("You can't use that here.")) if showmsg
			next false
		end
		next true
	})

	HiddenMoveHandlers::UseMove.add(:ROCKSMASH, proc { |move, pokemon|
		if !pbHiddenMoveAnimation(pokemon)
			pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
		end
		$stats.rock_smash_count += 1
		facingEvent = $game_player.pbFacingEvent
		
		next if !facingEvent
		if facingEvent.name == "RockSmashWall"
			commands = facingEvent.list
			next if  commands.nil?
	
			comment = ""
			commands.each do |command|
				# Command code for a comment is 108
				if command.code == 108
					# The text is in the first element of the parameters array
					comment = command.parameters[0]
					break # Stop searching after finding the first comment
				end #if command.code == 108
			end #commands.each do |command|
			lootTable = RockSmashWall.const_get(comment)
			RockSmashWall.interact(lootTable, facingEvent.id, true) if facingEvent
		else
			pbSmashEvent(facingEvent)
			pbRockSmashRandomEncounter
		end
		next true
	})
end #class RockSmashWall