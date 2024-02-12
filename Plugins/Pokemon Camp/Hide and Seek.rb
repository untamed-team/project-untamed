class Camping
	#as long as event name contains "Hiding_Spot", it will be chosen as a hiding spot by the player's pokemon
	def findHidingSpots
		@hidingSpots = []
		#get map events
		$game_map.events.values.each {|event|
			#if name contains "Hiding_Spot", add it to the list of available hiding spots, the array @hidingSpots
			@hidingSpots.push(event) if event.name.match(/Hiding_Spot/i)
		} #end of $game_map.events.values.each {|event|
	end
	
	def assignHidingSpots
		getCampers
		for i in 0...@campers.length
			hidingSpotsAvailable = @hidingSpots.clone
			spotChosen = @hidingSpots.sample
			@campers[i].hidingSpot = spotChosen
			hidingSpotsAvailable.delete(spotChosen)
			print "#{@campers[i].name}'s hiding spot is event #{@campers[i].hidingSpot}"
		end #for i in 0...@campers.length
		#print @hidingSpots
	end #def assignHidingSpots

	def self.checkHidingSpot(spot)
		#print "checking if pkmn is hiding in #{spot}"
	end #def checkHidingSpot

	def hideAndSeek
		findHidingSpots
		assignHidingSpots
	end #def hideAndSeek
	
	#on_player_interact with hiding spot
	EventHandlers.add(:on_player_interact, :hidingSpot, proc {
		facingEvent = $game_player.pbFacingEvent
		self.checkHidingSpot(facingEvent) if facingEvent && facingEvent.name.match(/Hiding_Spot/i)
	})

end #class Camping

class Pokemon
  attr_accessor :hidingSpot
end