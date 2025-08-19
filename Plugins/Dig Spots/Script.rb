#Summary
#Lets do it this way: Around the region we will have dig spots in various shorelines/dirt/sand/soot areas, represented by a pile similar to the soot items on Route 113 in Hoenn. Interacting with it will allow you to fill your pan which is stored in your key items, you can only hold one of these at a time. Using your panning kit on any body of water or at the panning camp, you get an item from the table. The original idea had dig spots that were considered more rare as well, and maybe we could have those have a small chance to spawn or guaranteed in harder to reach places. 

#I think it would be good to have a debris item that you can get when you would otherwise get nothing, that the older panner at the camp will buy from you for cheap just in case there are any smaller gold flakes hidden in it.

#If you do decide to reset you'd have to leave the area, which would mean that the dig spots reroll but arent guaranteed to show up again

#I think it just creates a easy reset opportunity which is what we are trying to avoid. While the event itself gets re-rolled when you open the map on whether it spawns, The areas the event could spawn would still be limited. So you can just continually reset on a beach or something, check all the dirt piles in the body of water next to it, and then save and reload until you get more dirt piles. Having to leave the map at least requires more work to reload depending on event placement

#need to register empty pan when the full pan is registered and washed, then vice versa

SaveData.register(:dig_spots) do
  save_value { $digSpotPanLoot }
  load_value { |value|  $digSpotPanLoot = value }
  new_game_value { DigSpots.new }
end

class DigSpots
	def initialize
		$digSpotPanLoot = nil
	end #def generateDigSpotsOnMap
  
	def self.findDigSpotsOnMap
		#go through all events on the current map and only do something if an event on the map is named "DigSpot"
		$game_map.events.each_value do |event|
			next if event.name != "DigSpot"
			Console.echo_warn "found a DigSpot with event id #{event.id}"
			
			#roll to activate dig spots
			if self.rollToActivateDigSpot
				Console.echo_warn "roll successful for dig spot. Activiating dig spot with event ID #{event.id}"
				pbMapInterpreter.pbSetSelfSwitch(event.id, "A", true)
			else
				Console.echo_warn "roll unsuccessful for dig spot. Dig spot with event ID #{event.id} will not be activated"
				pbMapInterpreter.pbSetSelfSwitch(event.id, "A", false)
			end #if self.rollToActivateDigSpot
		end #$game_map.events.each_value do |event|

	end #def self.findDigSpotsOnMap

	def self.rollToActivateDigSpot
		chance = rand(100)
		return true if chance <= CHANCE_TO_ACTIVATE_DIG_SPOT
		return false
	end
	
	def self.interact(lootTable, eventID)
		#does the player have a washing pan? Is it full or empty?
		if $bag.has?(:WASHINGPANEMPTY)
			if pbConfirmMessage(_INTL("There's something here. Dig it up?"))
				self.digUpTreasure(lootTable) 
				#set event's self switch A to off
				pbMapInterpreter.pbSetSelfSwitch(eventID, "A", false)
			end
		elsif $bag.has?(:WASHINGPANFULL)
			pbMessage(_INTL("There's something here. You could dig it up, but your \\c[1]Washing Pan\\c[0] is already full..."))
		else #no washing pan in the bag at all
			pbMessage(_INTL("There's something here. You could dig it up if you had a \\c[1]Washing Pan\\c[0]..."))
		end
	end #def self.interact
	
	def self.digUpTreasure(lootTable)
		item = self.selectItemFromLootTable(lootTable)
		Console.echo_warn "washing pan contains #{item}"
		$digSpotPanLoot = item
		$bag.remove(:WASHINGPANEMPTY)
		$bag.add(:WASHINGPANFULL)
		
		#replace registered item if washing pan was registered
		if $bag.pbIsRegistered?(:WASHINGPANEMPTY)
			$bag.pbUnregisterItem(:WASHINGPANEMPTY)
			$bag.pbRegisterItem(:WASHINGPANFULL)
		end
	end #def self.digUpTreasure
	
	def self.selectItemFromLootTable(lootTable)
		total_chance = 0
		lootTable.each do |entry|
			total_chance += entry[:chance]
		end
		echoln "warning: total cumulative is not equal to 100" if total_chance != 100 && $DEBUG
		echoln "warning: total cumulative is not equal to 100" if total_chance != 100 && $DEBUG
		roll = rand(total_chance)
		cumulative_chance = 0
		lootTable.shuffle.each do |entry|
			cumulative_chance += entry[:chance]
			return entry[:item] if roll < cumulative_chance
		end
	end #def selectItemFromLootTable(lootTable)
	
	def self.getLootFromWashingPan
		if pbConfirmMessage(_INTL("Do you want to wash the contents of your washing pan?"))
			$bag.remove(:WASHINGPANFULL)
			$bag.add(:WASHINGPANEMPTY)			
			pbItemBall($digSpotPanLoot)
			$digSpotPanLoot = nil
			
			#replace registered item if washing pan was registered
			if $bag.pbIsRegistered?(:WASHINGPANFULL)
				$bag.pbUnregisterItem(:WASHINGPANFULL)
				$bag.pbRegisterItem(:WASHINGPANEMPTY)
			end
		end
	end #def self.getLootFromWashingPan
end #class DigSpots

EventHandlers.add(:on_enter_map, :spawn_dig_spots,
  proc { |_old_map_id|

	#if oldMapID and currentMapID match, the game was just loaded. Skip generating dig spots
	next if _old_map_id == $game_map.map_id
	DigSpots.findDigSpotsOnMap
  }
)
EventHandlers.add(:on_player_interact, :digSpot, proc {
	facingEvent = $game_player.pbFacingEvent
	#if player is facing an event, check if it's a dig spot
	if !facingEvent.nil?
		next if facingEvent.name != "DigSpot"
		commands = facingEvent.list
	
		comment = ""
		commands.each do |command|
			# Command code for a comment is 108
			if command.code == 108
				# The text is in the first element of the parameters array
				comment = command.parameters[0]
				break # Stop searching after finding the first comment
			end #if command.code == 108
		end #commands.each do |command|
		lootTable = DigSpots.const_get(comment)
		DigSpots.interact(lootTable, facingEvent.id) if facingEvent
	else #not facing an event; check if facing water and have washing pan full
		DigSpots.getLootFromWashingPan if $bag.has?(:WASHINGPANFULL) && ($game_player.pbFacingTerrainTag == 5 || $game_player.pbFacingTerrainTag == 6 || $game_player.pbFacingTerrainTag == 7 || $game_player.pbFacingTerrainTag == 8 || $game_player.pbFacingTerrainTag == 9)
	end
})

ItemHandlers::UseFromBag.add(:WASHINGPANEMPTY, proc { |item|
	#next 0: Item use fails, item is not consumed.
	#next 1: Item use succeeds, item is consumed.
	#next 2: Item use succeeds, item is not consumed.

	#looking for a dig spot event to fill the washing pan at
	facingEvent = $game_player.pbFacingEvent
	#if player is facing an event, check if it's a dig spot
	if facingEvent.nil?
		pbMessage(_INTL("Can't use that here."))
		next 0
	end
	
	if facingEvent.name != "DigSpot"
		pbMessage(_INTL("Can't use that here."))
		next 0
	else
		#facing a dig spot
		next 2 #successful use, do not consume, go to useinfield handler for the item to do the actual effect
	end #if facingEvent.name != "DigSpot"
})

ItemHandlers::UseInField.add(:WASHINGPANEMPTY, proc { |item|
	facingEvent = $game_player.pbFacingEvent
	if facingEvent.nil?
		pbMessage(_INTL("Can't use that here."))
		next 0
	end
	
	commands = facingEvent.list
	
	comment = ""
	commands.each do |command|
		# Command code for a comment is 108
		if command.code == 108
			# The text is in the first element of the parameters array
			comment = command.parameters[0]
			break # Stop searching after finding the first comment
		end #if command.code == 108
	end #commands.each do |command|
	lootTable = DigSpots.const_get(comment)
	DigSpots.interact(lootTable, facingEvent.id) if facingEvent
	next 2
})

ItemHandlers::UseFromBag.add(:WASHINGPANFULL, proc { |item|
	#next 0: Item use fails, item is not consumed.
	#next 1: Item use succeeds, item is consumed.
	#next 2: Item use succeeds, item is not consumed.

	if ($game_player.pbFacingTerrainTag == 5 || $game_player.pbFacingTerrainTag == 6 || $game_player.pbFacingTerrainTag == 7 || $game_player.pbFacingTerrainTag == 8 || $game_player.pbFacingTerrainTag == 9)
		#if facing water
		next 2
	else
		#if not facing water
		pbMessage(_INTL("Take this to a body of water to wash it off."))
		next 0
	end
	
})

ItemHandlers::UseInField.add(:WASHINGPANFULL, proc { |item|
	if ($game_player.pbFacingTerrainTag == 5 || $game_player.pbFacingTerrainTag == 6 || $game_player.pbFacingTerrainTag == 7 || $game_player.pbFacingTerrainTag == 8 || $game_player.pbFacingTerrainTag == 9)
		#if facing water
		DigSpots.getLootFromWashingPan
		next 2
	else
		#if not facing water
		pbMessage(_INTL("Take this to a body of water to wash it off."))
		next 0
	end
})