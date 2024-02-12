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
		hidingSpotsAvailable = @hidingSpots.clone
		for i in 0...@campers.length
			print "We need more hiding spots on this map" if hidingSpotsAvailable.length <= 0
			spotChosen = @hidingSpots.sample
			@campers[i].hideAndSeekSpot = spotChosen
			@campers[i].hideAndSeekFound = false
			hidingSpotsAvailable.delete(spotChosen)
			print "#{@campers[i].name}'s hiding spot is event #{@campers[i].hideAndSeekSpot.id}"
		end #for i in 0...@campers.length
		#print @hidingSpots
	end #def assignHidingSpots

	def self.checkHidingSpot(spotChecked)
		self.getCampers
		#print "checking if pkmn is hiding in #{spot}"
		
		#check all pokemon in the party, and if they haven't been found, check if this is their hiding spot
		for i in 0...@campers.length
			next if @campers[i].hideAndSeekFound
			if @campers[i].hideAndSeekFound == false
				#is this @campers[i]'s hiding spot event?
				print "found!" if spotChecked == @campers[i].hideAndSeekSpot
			end #if @campers[i].hideAndSeekFound == false
		end #for i in 0...@campers.length
		
		#check how many pkmn are still hiding and end hide and seek round if none left hiding
		howManyLeft
	end #def checkHidingSpot

	def howManyLeft
		#check all pkmn in the party and see if any are still not found
		#for i in 0...@campers.length
		#	if @campers[i].hideAndSeekFound == false
		#	end
			
		#end #for i in 0...@campers.length
	end #def howManyLeft

	def hideAndSeek
		findHidingSpots
		assignHidingSpots
	end #def hideAndSeek
	
	#on_player_interact with hiding spot
	EventHandlers.add(:on_player_interact, :hideAndSeek_CheckSpot, proc {
		facingEvent = $game_player.pbFacingEvent
		self.checkHidingSpot(facingEvent) if facingEvent && facingEvent.name.match(/Hiding_Spot/i)
	})

end #class Camping

class Pokemon
  attr_accessor :hideAndSeekSpot
  attr_accessor :hideAndSeekFound
end