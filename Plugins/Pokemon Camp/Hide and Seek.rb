class Camping
	#as long as event name contains "Hiding_Spot", it will be chosen as a hiding spot by the player's pokemon
	def self.findHidingSpots
		@hidingSpots = []
		#get map events
		$game_map.events.values.each {|event|
			#if name contains "Hiding_Spot", add it to the list of available hiding spots, the array @hidingSpots
			@hidingSpots.push(event) if event.name.match(/Hiding_Spot/i)
		} #end of $game_map.events.values.each {|event|
	end
	
	def self.assignHidingSpots
		#fade to black
		$game_screen.start_tone_change(Tone.new(-255,-255,-255,0), 6 * Graphics.frame_rate / 20)
		pbWait(Graphics.frame_rate)
		hidingSpotsAvailable = @hidingSpots.clone
		for i in 0...$PokemonGlobal.campers.length
			#reset variables
			$PokemonGlobal.campers[i].failedToHide = false
			$PokemonGlobal.campers[i].hideAndSeekSpot = nil
			$PokemonGlobal.campers[i].hideAndSeekFound = false
			
			print "We need more hiding spots on this map" if hidingSpotsAvailable.length <= 0
			
			#random chance for the pkmn not to find a hiding spot
			chance = rand(1..33)
			if chance == 1
				#pkmn did not find a hiding spot
				$PokemonGlobal.campers[i].failedToHide = true
				#put the pkmn back in its starting spot when entering camp
				$PokemonGlobal.campers[i].campEvent.moveto($PokemonGlobal.campers[i].campStartX, $PokemonGlobal.campers[i].campStartY)
				next
			end #if chance == 1
			
			spotChosen = hidingSpotsAvailable.sample
			$PokemonGlobal.campers[i].hideAndSeekSpot = spotChosen
			hidingSpotsAvailable.delete(spotChosen)
			#make the event opacity 0
			pbMoveRoute($PokemonGlobal.campers[i].campEvent, [PBMoveRoute::Opacity, 0])
			#move the event to the top left corner of the map
			$PokemonGlobal.campers[i].campEvent.moveto(0, 0)
		end #for i in 0...$PokemonGlobal.campers.length
		
		self.resetPlayerPosition
		
		$game_screen.start_tone_change(Tone.new(0,0,0,0), 6 * Graphics.frame_rate / 20)
	end #def assignHidingSpots

	def self.checkHidingSpot(spotChecked)
		#check all pokemon in the party, and if they haven't been found, check if this is their hiding spot
		for i in 0...$PokemonGlobal.campers.length
			#get the pokemon in the party
			pkmn = $PokemonGlobal.campers[i]
			next if pkmn.hideAndSeekFound
			if pkmn.hideAndSeekFound == false
				#is this $PokemonGlobal.campers[i]'s hiding spot event?
				if spotChecked == pkmn.hideAndSeekSpot
					self.foundPkmn(pkmn)
				end #if spotChecked == pkmn.hideAndSeekSpot
			end #if pkmn.hideAndSeekFound == false
		end #for i in 0...$PokemonGlobal.campers.length
	end #def checkHidingSpot
	
	def self.foundPkmn(pkmn)
		pkmn.hideAndSeekFound = true
		self.leapOut(pkmn)
		pbWait(Graphics.frame_rate/2)
		#check how many pkmn are still hiding and end hide and seek round if none left hiding
		self.howManyLeft
	end #def self.foundPkmn(pkmn)
	
	def self.leapOut(pkmn)
		#get the event we just talked to
		hidingSpotEvent = $game_player.pbFacingEvent
		
		#set move route of corresponding camper event to move to hiding spot
		pkmn.campEvent.moveto(hidingSpotEvent.x, hidingSpotEvent.y)
		
		#make the event opacity 255
		pbMoveRoute(pkmn.campEvent, [PBMoveRoute::Opacity, 255])
		
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

		if !$game_map.passable?(desiredX, desiredY, 2, pkmn.campEvent)
			#try to the left of the player
			desiredX = $game_player.x-1
			desiredY = $game_player.y
		end #if !pkmn.campEvent.passable? - behind player
		
		#if left of the player is not passable
		if !$game_map.passable?(desiredX, desiredY, 2, pkmn.campEvent)
			#try to the right of the player
			desiredX = $game_player.x+1
			desiredY = $game_player.y
		end #if !pkmn.campEvent.passable? - left of player
		
		#if right of the player is not passable
		if !$game_map.passable?(desiredX, desiredY, 2, pkmn.campEvent)
			#try below the player
			desiredX = $game_player.x
			desiredY = $game_player.y+1
		end #if !pkmn.campEvent.passable? - right of player
		
		#if below the player is not passable
		if !$game_map.passable?(desiredX, desiredY, 2, pkmn.campEvent)
			#try above the player
			desiredX = $game_player.x
			desiredY = $game_player.y-1
		end #if !pkmn.campEvent.passable? - below player
		
		distanceX = (hidingSpotEvent.x - desiredX) * -1
		distanceY = (hidingSpotEvent.y - desiredY) * -1
		
		#play pkmn cry
		pbSEPlay("Cries/"+pkmn.species.to_s,100)
		
		#make camper event jump from hiding spot to passable location
		pbMoveRoute(pkmn.campEvent, [PBMoveRoute::Jump, distanceX, distanceY])
		
		#turn to face player
		pbTurnTowardEvent(pkmn.campEvent, $game_player)
		
		#player faces pkmn
		pbTurnTowardEvent($game_player, pkmn.campEvent)
		
		#fade to black
		pbWait(Graphics.frame_rate)
		$game_screen.start_tone_change(Tone.new(-255,-255,-255,0), 6 * Graphics.frame_rate / 20)
		pbWait(Graphics.frame_rate)
		#make the event opacity 0
		pbMoveRoute(pkmn.campEvent, [PBMoveRoute::Opacity, 0])
		#move the event to the top left corner of the map
		pkmn.campEvent.moveto(0, 0)
		#fade in
		$game_screen.start_tone_change(Tone.new(0,0,0,0), 6 * Graphics.frame_rate / 20)
	end #def self.leapOut(pkmn)
	
	def self.leapOutNotFound(pkmn)
		#add to the variable hideAndSeekGamesWon
		pkmn.hideAndSeekGamesWon = 0 if pkmn.hideAndSeekGamesWon.nil?
		pkmn.hideAndSeekGamesWon += 1
	
		hidingSpotEvent = pkmn.hideAndSeekSpot
		
		#set move route of corresponding camper event to move to hiding spot
		pkmn.campEvent.moveto(hidingSpotEvent.x, hidingSpotEvent.y)
		
		#make the event opacity 255
		pbMoveRoute(pkmn.campEvent, [PBMoveRoute::Opacity, 255])
		
		#try to jump out to the right
		desiredX = hidingSpotEvent.x+1
		desiredY = hidingSpotEvent.y
		
		if !$game_map.passable?(desiredX, desiredY, 2, pkmn.campEvent)
			#try to the left of the hiding spot
			desiredX = hidingSpotEvent.x-1
			desiredY = hidingSpotEvent.y
		end #if !pkmn.campEvent.passable?
		
		if !$game_map.passable?(desiredX, desiredY, 2, pkmn.campEvent)
			#try below the hiding spot
			desiredX = hidingSpotEvent.x
			desiredY = hidingSpotEvent.y+1
		end #if !pkmn.campEvent.passable?
		
		if !$game_map.passable?(desiredX, desiredY, 2, pkmn.campEvent)
			#try above the hiding spot
			desiredX = hidingSpotEvent.x
			desiredY = hidingSpotEvent.y-1
		end #if !pkmn.campEvent.passable?
		
		distanceX = (hidingSpotEvent.x - desiredX) * -1
		distanceY = (hidingSpotEvent.y - desiredY) * -1
		
		#play pkmn cry
		pbSEPlay("Cries/"+pkmn.species.to_s,100)
		
		#make camper event jump from hiding spot to passable location
		pbMoveRoute(pkmn.campEvent, [PBMoveRoute::Jump, distanceX, distanceY])
		
		#turn to face camera, so down, direction 2
		pbMoveRoute(pkmn.campEvent, [PBMoveRoute::TurnDown])
		
		#fade to black
		pbWait(Graphics.frame_rate)
		$game_screen.start_tone_change(Tone.new(-255,-255,-255,0), 6 * Graphics.frame_rate / 20)
		pbWait(Graphics.frame_rate)
		#make the event opacity 0
		pbMoveRoute(pkmn.campEvent, [PBMoveRoute::Opacity, 0])
		#move the event to the top left corner of the map
		pkmn.campEvent.moveto(0, 0)
		
		#center screen back on player
		speed = 0
		distance = (pkmn.hideAndSeekSpot.x - $game_player.x).abs
		if pkmn.hideAndSeekSpot.x < $game_player.x
			#go right towards the player
			direction = 6
		else
			#hiding spot X is either equal to or greater than where the player is
			#go left towards the player
			direction = 4
		end
			
		pbScrollMap(direction, distance, speed)
		
		distance = (pkmn.hideAndSeekSpot.y - $game_player.y).abs
		if pkmn.hideAndSeekSpot.y < $game_player.y
			#go down towards the player
			direction = 2
		else
			#hiding spot Y is either equal to or greater than where the player is
			#go up towards the player
			direction = 8
		end
			
		pbScrollMap(direction, distance, speed)
		
		#fade in
		$game_screen.start_tone_change(Tone.new(0,0,0,0), 6 * Graphics.frame_rate / 20)
	end #def self.leapOutNotFound(pkmn)
	
	def self.howManyLeft
		#check all pkmn in the party and see if any are still not found
		for i in 0...$PokemonGlobal.campers.length
			pkmn = $PokemonGlobal.campers[i]
			return if pkmn.hideAndSeekFound == false
		end #for i in 0...$Trainer.pokemon_count
		
		#say when we've found the whole team
		#print "found them all!"
		self.goAgain
	end #def howManyLeft

	def self.goAgain
		if pbConfirmMessage(_INTL("Play again?"))
			self.findHidingSpots
			self.assignHidingSpots
			pbMessage(_INTL("Ready or not, here I come!"))
			$PokemonGlobal.playingHideAndSeek = true
		else
			$PokemonGlobal.playingHideAndSeek = false
			$game_system.menu_disabled = false
			self.resetCamperPositions
			pbBGMFade(1)
		end
	end #goAgain
	
	def self.revealHidingPkmn
		for i in 0...$PokemonGlobal.campers.length
			pkmn = $PokemonGlobal.campers[i]
			next if pkmn.hideAndSeekFound
			next if pkmn.hideAndSeekSpot.nil?
			
			#scroll map to their hidingSpot event's X
			speed = 5
			distance = (pkmn.hideAndSeekSpot.x - $game_player.x).abs
			if pkmn.hideAndSeekSpot.x < $game_player.x
				#go left towards the hiding spot
				direction = 4
			else
				#hiding spot X is either equal to or greater than where the player is
				#go right towards the hiding spot
				direction = 6
			end
			
			pbScrollMap(direction, distance, speed)
			
			#scroll map to their hidingSpot event's Y
			speed = 5
			distance = (pkmn.hideAndSeekSpot.y - $game_player.y).abs
			if pkmn.hideAndSeekSpot.y < $game_player.y
				#go up towards the hiding spot
				direction = 8
			else
				#hiding spot Y is either equal to or greater than where the player is
				#go down towards the hiding spot
				direction = 2
			end
			
			pbScrollMap(direction, distance, speed)
			
			self.leapOutNotFound(pkmn)
			pbWait(Graphics.frame_rate/2)
		end #for i in 0...$PokemonGlobal.campers.length
		
		$PokemonGlobal.playingHideAndSeek = false
		$game_system.menu_disabled = false
		self.resetCamperPositions
		pbBGMFade(1)
	end #def self.revealHidingPkmn

	def self.hideAndSeek
		$game_system.menu_disabled
		pbBGMFade(1)
		self.findHidingSpots
		self.assignHidingSpots
		pbBGMPlay("ORAS 088 The Trick House")
		pbMessage(_INTL("Ready or not, here I come!"))
		$PokemonGlobal.playingHideAndSeek = true
	end #def hideAndSeek
	
	#on_player_interact with hiding spot
	EventHandlers.add(:on_player_interact, :hideAndSeek_CheckSpot, proc {
		next if !$PokemonGlobal.playingHideAndSeek
		facingEvent = $game_player.pbFacingEvent
		self.checkHidingSpot(facingEvent) if facingEvent && facingEvent.name.match(/Hiding_Spot/i)
	})
	
	#check if player wants t o give up on hide and seek
	EventHandlers.add(:on_frame_update, :back_when_hideAndSeek, proc {
		next if !$PokemonGlobal.playingHideAndSeek
		if Input.trigger?(Input::BACK)
			if pbConfirmMessage(_INTL("Give up?"))
				pbMessage(_INTL("Come out, come out, wherever you are!"))
				pbWait(Graphics.frame_rate/2)
				self.revealHidingPkmn
			end
		end # if Input.trigger?(Input::BACK)
	})

end #class Camping