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
			spotChosen = hidingSpotsAvailable.sample
			@campers[i].hideAndSeekSpot = spotChosen
			@campers[i].hideAndSeekFound = false
			hidingSpotsAvailable.delete(spotChosen)
			#print "#{@campers[i].name}'s hiding spot is event #{@campers[i].hideAndSeekSpot.id}"
		end #for i in 0...@campers.length
		#print @hidingSpots
	end #def assignHidingSpots

	def self.checkHidingSpot(spotChecked)
		#print "checking if pkmn is hiding in #{spot}"
		
		#check all pokemon in the party, and if they haven't been found, check if this is their hiding spot
		for i in 0...$Trainer.pokemon_count
			#get the pokemon in the party
			pkmn = $Trainer.pokemon_party[i]
			next if pkmn.hideAndSeekFound
			if pkmn.hideAndSeekFound == false
				#is this @campers[i]'s hiding spot event?
				if spotChecked == pkmn.hideAndSeekSpot
					self.foundPkmn(pkmn)
				end #if spotChecked == pkmn.hideAndSeekSpot
			end #if pkmn.hideAndSeekFound == false
		end #for i in 0...$Trainer.pokemon_count
		
		#check how many pkmn are still hiding and end hide and seek round if none left hiding
		self.howManyLeft
	end #def checkHidingSpot
	
	def self.foundPkmn(pkmn)
		print "you found #{pkmn.name}!"
		pkmn.hideAndSeekFound = true
		self.leapOut(pkmn)
	end #def self.foundPkmn(pkmn)
	
	def self.leapOut(pkmn)
		#get the event we just talked to
		event = $game_player.pbFacingEvent
		
		#get direction player is facing
		case $game_player.direction
		when 2 #down
			desiredX = $game_player.x
			desiredY = $game_player.y-1
		when 4 #left
			desiredX = $game_player.x+1
			desiredY = $game_player.y
		when 6 #right
			desiredX = $game_player.x-1
			desiredY = $game_player.y
		when 8 #up
			desiredX = $game_player.x
			desiredY = $game_player.y+1
		end #case $game_player.direction
		
		#try going behind player if it's passable
		#passable?(x, y, direction, strict=true)
		if event.passable?(desiredX, desiredY, 2, true)
			
		end
	end #def self.leapOut(pkmn)
	
	def self.howManyLeft
		#check all pkmn in the party and see if any are still not found
		for i in 0...$Trainer.pokemon_count
			pkmn = $Trainer.pokemon_party[i]
			return if pkmn.hideAndSeekFound == false
		end #for i in 0...$Trainer.pokemon_count
		
		#say when we've found the whole team
		print "found them all!"
		EventHandlers.remove(:on_player_interact, :hideAndSeek_CheckSpot)
		goAgain
	end #def howManyLeft

	def goAgain
	end #goAgain

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