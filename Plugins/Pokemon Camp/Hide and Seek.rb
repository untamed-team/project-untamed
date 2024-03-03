class Camping
	HIDE_AND_SEEK_TIMER_SECONDS = 60

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
			
			#for bug reporting purposes
			print "We need more hiding spots on this map. Please report this as a bug." if hidingSpotsAvailable.length <= 0
			
			#random chance for the pkmn not to find a hiding spot
			chance = rand(1..100)
			if chance <= 5
				#pkmn did not find a hiding spot
				$PokemonGlobal.campers[i].failedToHide = true
				#put the pkmn back in its starting spot when entering camp
				$PokemonGlobal.campers[i].campEvent.moveto($PokemonGlobal.campers[i].campStartX, $PokemonGlobal.campers[i].campStartY)
				next
			end #if chance <= 5
			
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
		$PokemonGlobal.hideAndSeekPause = true
		pkmn.hideAndSeekFound = true
		self.updatePkmnIcon(pkmn)
		self.leapOut(pkmn)
		pbWait(Graphics.frame_rate/2)
		
		#check how many pkmn are still hiding and end hide and seek round if none left hiding
		self.howManyLeft
		$PokemonGlobal.hideAndSeekPause = false
	end #def self.foundPkmn(pkmn)
	
	def self.leapOut(pkmn)
		#get the event we just talked to
		hidingSpotEvent = $game_player.pbFacingEvent
		return if hidingSpotEvent.nil? #a rescue for a crash
		
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
		
		pbWait(Graphics.frame_rate)
		#fade to black
		self.fadeToBlack
		#make the event opacity 0
		pbMoveRoute(pkmn.campEvent, [PBMoveRoute::Opacity, 0])
		#move the event to the top left corner of the map
		pkmn.campEvent.moveto(0, 0)
		pbWait(Graphics.frame_rate)
		#fade in
		self.fadeInFromBlack
		$PokemonGlobal.hideAndSeekPause = false
	end #def self.leapOut(pkmn)
	
	def self.leapOutNotFound(pkmn)
		$PokemonGlobal.hideAndSeekPause = true
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
		
		pbWait(Graphics.frame_rate)
		#fade to black
		self.fadeToBlack
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
		
		pbWait(Graphics.frame_rate)
		#fade in
		self.fadeInFromBlack
	end #def self.leapOutNotFound(pkmn)
	
	def self.howManyLeft
		#check all pkmn in the party and see if any are still not found
		for i in 0...$PokemonGlobal.campers.length
			pkmn = $PokemonGlobal.campers[i]
			return if pkmn.hideAndSeekFound == false
		end #for i in 0...$Trainer.pokemon_count
		
		#say when we've found the whole team
		#print "found them all!"
		$PokemonGlobal.hideAndSeekSuccessfulConsecutiveRounds += 1
		self.goAgain
	end #def howManyLeft

	def self.goAgain
		$PokemonGlobal.hideAndSeekPause = true
		if pbConfirmMessage(_INTL("Play again?"))
			self.replayHideAndSeek
		else
			self.stopHideAndSeek
		end
	end #goAgain
	
	def self.revealHidingPkmn
		$PokemonGlobal.hideAndSeekPause = true
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
		
		self.stopHideAndSeek
	end #def self.revealHidingPkmn

	def self.interactHideAndSeek
		$PokemonGlobal.hideAndSeekPause = true
		event = $game_player.pbFacingEvent
		pkmn = $player.pokemon_party[event.id-1] #this means that events 1-6 MUST be reserved for the pkmn in the player's party
		species = pkmn.species.to_s
		pbSEPlay("Cries/"+species,100)
		pbTurnTowardEvent(pkmn.campEvent, $game_player)
		pbMessage(_INTL("#{pkmn.name} couldn't find a hiding spot in time!"))
		
		self.updatePkmnIcon(pkmn)
		
		pbWait(Graphics.frame_rate)
		#fade to black
		self.fadeToBlack
		#make the event opacity 0
		pbMoveRoute(pkmn.campEvent, [PBMoveRoute::Opacity, 0])
		#move the event to the top left corner of the map
		pkmn.campEvent.moveto(0, 0)
		pbWait(Graphics.frame_rate)
		#fade in
		self.fadeInFromBlack
		pkmn.hideAndSeekFound = true
		self.howManyLeft
		$PokemonGlobal.hideAndSeekPause = false
	end #def interactHideAndSeek

	def self.emoteWhileHiding(pkmn)
		emoteIDs = [3,4,9,10,11,12,13,18]
		emoteID = emoteIDs.sample
		self.showEventAnimation(pkmn.campEvent.id, animation_id=emoteID)
	end #def self.emoteWhileHiding
	
	def self.fadeToBlack
		@sprites = $PokemonGlobal.hideAndSeekSprites
		framesOverDuration = 6 * Graphics.frame_rate / 20
		opacityAmountChange = 255/framesOverDuration.ceil

		loop do
			Graphics.update
			@sprites["black_screen"].opacity += opacityAmountChange
			break if @sprites["black_screen"].opacity >= 255
		end #loop do
	end #def self.fadeToBlack
	
	def self.fadeInFromBlack
		@sprites = $PokemonGlobal.hideAndSeekSprites
		framesOverDuration = 6 * Graphics.frame_rate / 20
		opacityAmountChange = 255/framesOverDuration.ceil

		loop do
			Graphics.update
			@sprites["black_screen"].opacity -= opacityAmountChange
			break if @sprites["black_screen"].opacity <= 0
		end #loop do
	end #def self.fadeInFromBlack
	
	def self.drawHUD
		$PokemonGlobal.hideAndSeekViewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport = $PokemonGlobal.hideAndSeekViewport
		$PokemonGlobal.hideAndSeekSprites = {}
		@sprites = $PokemonGlobal.hideAndSeekSprites
		
		#draw black screen so we can make the entire screen black including the HUD sprites
		@sprites["black_screen"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
		@sprites["black_screen"].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0))
		@sprites["black_screen"].z = 9999999
		@sprites["black_screen"].opacity = 0
		
		self.drawTimer
		self.drawPkmnIcons
	end #def self.drawTimer
	
	def self.drawTimer
		@sprites["timer"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
		base   = Color.new(248,248,248)
        shadow = Color.new(104,104,104)
		timerText = [[_INTL("#{$PokemonGlobal.hideAndSeekTimer}"),Graphics.width/2,Graphics.height-70,2,base,shadow]]
		pbSetSystemFont(@sprites["timer"].bitmap)
        pbDrawTextPositions(@sprites["timer"].bitmap,timerText)
	end #def self.drawTimer

	def self.drawPkmnIcons
		@sprites["foundPkmnBitmap"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
		overlay = @sprites["foundPkmnBitmap"].bitmap
		
		imagepos = []
		for i in 0...$PokemonGlobal.campers.length
			@sprites["camper#{i}"] = PokemonIconSprite.new($PokemonGlobal.campers[i], @viewport)
			@sprites["camper#{i}"].setOffset(PictureOrigin::TOP_LEFT)
			@sprites["camper#{i}"].x = (Graphics.width/2 - @sprites["camper#{i}"].width/2) + i*@sprites["camper#{i}"].width/1.5
			@sprites["camper#{i}"].y = Graphics.height-@sprites["camper#{i}"].height-3
			@sprites["camper#{i}"].z = 99999
			
			#assign each pkmn their icon sprite
			$PokemonGlobal.campers[i].hideAndSeekIcon = @sprites["camper#{i}"]
			
			#set tone for the icon to black
			@sprites["camper#{i}"].tone = Tone.new(-255,-255,-255,0)
		end #for i in 0...$PokemonGlobal.campers.length
		
		#center the sprites by figuring out how much space they need to shift left
		case $PokemonGlobal.campers.length
		when 1
			padding = 0
		when 2
			padding = (@sprites["camper0"].width/1.5) * 0.5
		when 3
			padding = (@sprites["camper0"].width/1.5)
		when 4
			padding = (@sprites["camper0"].width/1.5) * 1.5
		when 5
			padding = (@sprites["camper0"].width/1.5) * 2
		when 6
			padding = (@sprites["camper0"].width/1.5) * 2.5
		end #case $PokemonGlobal.campers.length
		
		for i in 0...$PokemonGlobal.campers.length
			@sprites["camper#{i}"].x -= padding
		end #for i in 0...$PokemonGlobal.campers.length
	end #def self.drawPkmnIcons

	def self.updateTimer
		if $PokemonGlobal.campGenericTimer <= 0
			$PokemonGlobal.hideAndSeekTimer -= 1
			$PokemonGlobal.hideAndSeekSprites
			base   = Color.new(248,248,248)
			shadow = Color.new(104,104,104)
			timerText = [[_INTL("#{$PokemonGlobal.hideAndSeekTimer}"),Graphics.width/2,Graphics.height-70,2,base,shadow]]
			@sprites["timer"].bitmap.clear
			pbDrawTextPositions(@sprites["timer"].bitmap,timerText)
		end #if $PokemonGlobal.campGenericTimer <= 0
	end #def updateTimer

	def self.updatePkmnIcon(pkmn)
		pkmn.hideAndSeekIcon.tone = Tone.new(0,0,0,0)
	end #def self.updatePkmnIcons

	def self.failHideAndSeek
		$PokemonGlobal.hideAndSeekPause = true
		#fade bgm
		pbBGMFade(1)
		#whistle blow
		pbSEPlay("Whistle Blow")
		pbWait(Graphics.frame_rate*2)
		
		pbMessage(_INTL("Come out, come out, wherever you are!"))
		pbWait(Graphics.frame_rate/2)
		self.revealHidingPkmn
	end #def self.failHideAndSeek

	def self.hideAndSeek
		pbBGMFade(1)
		self.startHideAndSeek
	end #def hideAndSeek
	
	def self.startHideAndSeek
		$game_system.menu_disabled
		self.findHidingSpots
		self.assignHidingSpots
		$PokemonGlobal.hideAndSeekSuccessfulConsecutiveRounds = 0
		$PokemonGlobal.campGenericTimer = Graphics.frame_rate
		$PokemonGlobal.hideAndSeekTimer = HIDE_AND_SEEK_TIMER_SECONDS
		self.drawHUD
		pbBGMPlay("ORAS 088 The Trick House")
		pbMessage(_INTL("Ready or not, here I come!"))
		$PokemonGlobal.playingHideAndSeek = true
		$PokemonGlobal.hideAndSeekPause = false
		
		#stop movement of all pkmn events
		for i in 0...$PokemonGlobal.campers.length
			pkmn = $PokemonGlobal.campers[i]
			pkmn.campEvent.move_type = 0
		end #for i in 0...$PokemonGlobal.campers.length
	end
		
	def self.stopHideAndSeek
		$PokemonGlobal.playingHideAndSeek = false
		$game_system.menu_disabled = false
		$PokemonGlobal.hideAndSeekViewport.dispose
		
		for i in 0...$PokemonGlobal.campers.length
			pkmn = $PokemonGlobal.campers[i]
			#resume movement of all pkmn events
			pkmn.campEvent.move_type = 1
			#set all hide and seek icons to nil for pkmn to prevent a crash when saving
			$PokemonGlobal.campers[i].hideAndSeekIcon = nil
		end #for i in 0...$PokemonGlobal.campers.length
		
		$PokemonGlobal.hideAndSeekViewport = nil
		$PokemonGlobal.hideAndSeekSprites = nil
		self.resetCamperPositions
		pbBGMFade(1)
		
		#if currently doing camp quest, mark task as complete it not complete already
		markQuestTaskComplete(:Quest8, task=3) if getActiveQuests.include?(:Quest8) && !isTaskComplete(:Quest8,"Play hide and seek")
	end
	
	def self.replayHideAndSeek
		$PokemonGlobal.hideAndSeekViewport.dispose
		self.resetCamperPositions
		self.findHidingSpots
		self.assignHidingSpots
		$PokemonGlobal.campGenericTimer = Graphics.frame_rate
		if $PokemonGlobal.hideAndSeekSuccessfulConsecutiveRounds <= HIDE_AND_SEEK_TIMER_SECONDS/10
			$PokemonGlobal.hideAndSeekTimer = HIDE_AND_SEEK_TIMER_SECONDS - ($PokemonGlobal.hideAndSeekSuccessfulConsecutiveRounds*10)
		else
			#don't subtract all time from the timer, starting the player with 0 seconds
			$PokemonGlobal.hideAndSeekTimer = HIDE_AND_SEEK_TIMER_SECONDS
		end
		self.drawHUD
		pbMessage(_INTL("Ready or not, here I come!"))
		$PokemonGlobal.playingHideAndSeek = true
		$PokemonGlobal.hideAndSeekPause = false
	end #def self.replayHideAndSeek
	
	#on_player_interact with hiding spot
	EventHandlers.add(:on_player_interact, :hideAndSeek_CheckSpot, proc {
		next if !$PokemonGlobal.camping
		next if !$PokemonGlobal.playingHideAndSeek
		facingEvent = $game_player.pbFacingEvent
		self.checkHidingSpot(facingEvent) if facingEvent && facingEvent.name.match(/Hiding_Spot/i)
	})
	
	EventHandlers.add(:on_frame_update, :pressed_back_during_hideAndSeek, proc {
		next if !$PokemonGlobal.camping
		next if !$PokemonGlobal.playingHideAndSeek
		next if $PokemonGlobal.hideAndSeekPause
		#check if player wants to give up on hide and seek
		if Input.trigger?(Input::BACK)
			$PokemonGlobal.hideAndSeekPause = true
			if pbConfirmMessage(_INTL("Give up?"))
				pbMessage(_INTL("Come out, come out, wherever you are!"))
				pbWait(Graphics.frame_rate/2)
				self.revealHidingPkmn
			else
				$PokemonGlobal.hideAndSeekPause = false
			end
		end # if Input.trigger?(Input::BACK)
		
		#subtract from hide and seek generic timer
		$PokemonGlobal.campGenericTimer = Graphics.frame_rate if $PokemonGlobal.campGenericTimer <= 0
		$PokemonGlobal.campGenericTimer -= 1
		self.updateTimer
		
		#fail hide and seek if out of time
		if $PokemonGlobal.hideAndSeekTimer <= 0
			self.failHideAndSeek
		end #if $PokemonGlobal.hideAndSeekTimer <= 0
	})
	
	#on_player_interact with camper
	EventHandlers.add(:on_player_interact, :interact_with_camper_pkmn_during_hideAndSeek, proc {
		next if !$PokemonGlobal.camping
		next if !$PokemonGlobal.playingHideAndSeek
		facingEvent = $game_player.pbFacingEvent
		self.interactHideAndSeek if facingEvent && facingEvent.name.match(/CamperPkmn/i)
	})
	
	EventHandlers.add(:on_step_taken, :emote_during_hideAndSeek, proc {
		next if !$PokemonGlobal.camping
		next if !$PokemonGlobal.playingHideAndSeek
		#check all pkmn in the party and see if any are still not found
		for i in 0...$PokemonGlobal.campers.length
			pkmn = $PokemonGlobal.campers[i]
			next if pkmn.hideAndSeekFound == true
			next if pkmn.failedToHide == true
			#if within a set amount of tiles from the player's X and Y
			distanceX = (pkmn.hideAndSeekSpot.x - $game_player.x).abs
			distanceY = (pkmn.hideAndSeekSpot.y - $game_player.y).abs
			if distanceX <= 8 && distanceY <= 8
				#if on screen, roll the dice to see if the pkmn emotes
				chance = rand(1..100)
				self.emoteWhileHiding(pkmn) if chance == 1
			end #if distanceX <= 8 && distanceY <= 8
		end #for i in 0...$Trainer.pokemon_count
	})

end #class Camping