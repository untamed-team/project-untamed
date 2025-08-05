#Helper Methods
class RotatonaPuzzle
	attr_accessor :currentRoomPuzzleEvents

	#######################################
	#============== Player ================
	#######################################
	def self.playerStandingOnTrackTileOrEvent?
		return true if $game_player.pbTerrainTag.id == :RotatonaPuzzle_Track_Corner1 || $game_player.pbTerrainTag.id == :RotatonaPuzzle_Track_Corner2 || $game_player.pbTerrainTag.id == :RotatonaPuzzle_Track_Corner3 || $game_player.pbTerrainTag.id == :RotatonaPuzzle_Track_Corner4 || $game_player.pbTerrainTag.id == :RotatonaPuzzle_Track_Horizontal || $game_player.pbTerrainTag.id == :RotatonaPuzzle_Track_Vertical || $game_player.pbTerrainTag.id == :RotatonaPuzzle_Track_Crossroad || $game_player.pbTerrainTag.id == :RotatonaPuzzle_Track_DeadEndUp || $game_player.pbTerrainTag.id == :RotatonaPuzzle_Track_DeadEndDown || $game_player.pbTerrainTag.id == :RotatonaPuzzle_Track_DeadEndLeft || $game_player.pbTerrainTag.id == :RotatonaPuzzle_Track_DeadEndRight || !self.touchingCornerTrackEvent?($game_player).nil? || !self.touchingCatcherEvent?($game_player).nil? || !self.touchingStraightTrackEvent?($game_player).nil? || !self.touchingRampEvent?($game_player).nil? || !self.touchingLauncherEvent?($game_player).nil?
		return false
	end #def self.playerStandingOnTrackTileOrEvent
	
	#######################################
	#============== Camera ================
	#######################################
	def self.cameraPanningToPlayer?
		return @cameraPanning
	end
	
	#######################################
	#=========== Disc Events =============
	#######################################
	def self.discRolling?
		$rotatona_puzzle.currentRoomPuzzleEvents[:Discs].each do |event|
			return true if event.discRolling
		end #$rotatona_puzzle.currentRoomPuzzleEvents[:Discs].each do |event|
		return false
	end #def self.discRolling?
	
	def self.checkIfDiscTurning
		$rotatona_puzzle.currentRoomPuzzleEvents[:Discs].each do |event|
			next if !event.discRolling
			next if event.discTurningDirection.nil?

			#stop disc from turning if it's not on a turning sprite
			if event.direction != event.discTurningDirection
				#Console.echo_warn "turning"
			else
				#Console.echo_warn "done turning"
				event.direction = event.discTurningDirection
				event.discTurningDirection = nil
			end
		end #$rotatona_puzzle.currentRoomPuzzleEvents[:Discs].each do |event|
	end #def self.turnDisc(event, oldDirection, newDirection)
	
	def self.determinePatterForTurning(event, newDirection)
		#determine pattern for turning
		if event.direction == 2 && newDirection == 6 #going down, turning right
			turnSpritePattern = 0
		elsif event.direction == 4 && newDirection == 8 #going left and turning up
			turnSpritePattern = 0
		elsif event.direction == 6 && newDirection == 2 #going right and turning down
			turnSpritePattern = 0
		elsif event.direction == 8 && newDirection == 4 #going up and turning left
			turnSpritePattern = 0
		elsif event.direction == 4 && newDirection == 2 #going left and turning down
			turnSpritePattern = 3
		elsif event.direction == 2 && newDirection == 4 #going down and turning left
			turnSpritePattern = 3
		elsif event.direction == 8 && newDirection == 6 #going up and turning right
			turnSpritePattern = 3
		elsif event.direction == 6 && newDirection == 8 #going right and turning up
			turnSpritePattern = 3
		end
		
		print "Due to an unforeseen edge case, you're about to crash :) Please report this as a bug. Event direction is #{event.direction} and it's turning #{newDirection}" if turnSpritePattern.nil?
		
		return turnSpritePattern
	end #def self.determinePatterForTurning
	
	def self.touchingCornerTrackEvent?(discEvent)
		#print "checking for corner track. this should print twice when touching one" #it didn't work on event 29
		#iterate through rotatable corner track events
		touchingTrack = nil
		$rotatona_puzzle.currentRoomPuzzleEvents[:CornerTracks].each do |event|
			if discEvent.x == event.x && discEvent.y == event.y
				touchingTrack = event #need to know the event the disc is touching to know the direction
			end
		end #$rotatona_puzzle.currentRoomPuzzleEvents
		return touchingTrack
	end #def self.touchingCornerTrackEvent?(discEvent)
	
	def self.touchingCatcherEvent?(discEvent)
		#iterate through catcher events
		touchingCatcher = nil
		$rotatona_puzzle.currentRoomPuzzleEvents[:Catchers].each do |event|
			if discEvent.x == event.x && discEvent.y == event.y
				touchingCatcher = event #need to know the event the disc is touching to know the direction
			end
		end #$rotatona_puzzle.currentRoomPuzzleEvents
		return touchingCatcher
	end #def self.touchingCatcherEvent?(discEvent)
	
	def self.touchingStraightTrackEvent?(discEvent)
		touchingTrack = nil
		#iterate through rotatable straight track events
		$rotatona_puzzle.currentRoomPuzzleEvents[:StraightTracks].each do |event|
			if discEvent.x == event.x && discEvent.y == event.y
				touchingTrack = event #need to know the event the disc is touching to know the direction
			end
		end #$rotatona_puzzle.currentRoomPuzzleEvents
		return touchingTrack
	end #def self.touchingStraightTrackEvent?(discEvent)
	
	def self.touchingRampEvent?(discEvent)
		#iterate through togglable ramp events
		touchingRamp = nil
		#iterate through rotatable straight track events
		$rotatona_puzzle.currentRoomPuzzleEvents[:Ramps].each do |event|
			if discEvent.x == event.x && discEvent.y == event.y
				touchingRamp = event #need to know the event the disc is touching to know the direction
			end
		end #$rotatona_puzzle.currentRoomPuzzleEvents
		return touchingRamp
	end #def self.touchingRampEvent?(discEvent)
	
	def self.touchingLauncherEvent?(discEvent)
		#iterate through rotatable corner track events
		touchingLauncher = nil
		$rotatona_puzzle.currentRoomPuzzleEvents[:Launchers_Rotatable].each do |launcherEvent|
			#get the center X and center Y of the launcher
			launcherCenterX = launcherEvent.x+1
			launcherCenterY = launcherEvent.y-1
				#check if disc is touching center of launcher
				#print "disc event #{discEvent.id} is docked at launcher event #{launcherEvent.id}" if discEvent.x == launcherCenterX && discEvent.y == launcherCenterY
				if discEvent.x == launcherCenterX && discEvent.y == launcherCenterY
					#Console.echo_warn "touching launcher event"
					#discEvent.launcherThisDiscIsDockedIn = launcherEvent #shoudn't be needed since this is done when docking disc
					#launcherEvent.discThisLauncherHasDocked = discEvent #shoudn't be needed since this is done when docking disc
					
					touchingLauncher = launcherEvent
					return touchingLauncher
				end
		end #$rotatona_puzzle.currentRoomPuzzleEvents
		$rotatona_puzzle.currentRoomPuzzleEvents[:Launchers_Stationary].each do |launcherEvent|
			#get the center X and center Y of the launcher
			launcherCenterX = launcherEvent.x+1
			launcherCenterY = launcherEvent.y-1
				#check if disc is touching center of launcher
				#print "disc event #{discEvent.id} is docked at launcher event #{launcherEvent.id}" if discEvent.x == launcherCenterX && discEvent.y == launcherCenterY
				if discEvent.x == launcherCenterX && discEvent.y == launcherCenterY
					#Console.echo_warn "touching launcher event"
					#discEvent.launcherThisDiscIsDockedIn = launcherEvent #shoudn't be needed since this is done when docking disc
					#launcherEvent.discThisLauncherHasDocked = discEvent #shoudn't be needed since this is done when docking disc
					
					touchingLauncher = launcherEvent
					return touchingLauncher
				end
		end #$rotatona_puzzle.currentRoomPuzzleEvents

		return touchingLauncher
	end #def self.touchingLauncherEvent?(discEvent)
	
	#######################################
	#=============== Misc =================
	#######################################
	def self.moveDiscsPuzzleSolved
		#run this if on specific map and certain switch is turned on
		#do this before self.getPuzzleEvents
		#find all rotatona disc events
		discEvents = []
		catcherEvents = []
		
		$game_map.events.each_value do |event|
			discEvents.push(event) if event.name.match(/RotaPuzzle_Disc/i)
			catcherEvents.push(event) if event.name.match(/RotaPuzzle_Catcher/i)
		end #$game_map.events.each_value do |event|
		
		#move the discs to catchers because the puzzle is solved
		for discEvent in discEvents
			if catcherEvents.empty?
				print "not enough catcher events"
			end
			discEvent.moveto(catcherEvents[0].x, catcherEvents[0].y)
			#change direction if disc so it matches direction of catcher event
			discEvent.direction = catcherEvents[0].direction
			#remove catcher as possibility
			catcherEvents.delete_at(0)
		end
		
	end #def self.moveDiscsPuzzleSolved
	
	def self.getPuzzleEvents	
		Console.echo_warn "identifying puzzle pieces from scratch"
		#identify all the events on the map which correspond with the puzzle
		#print "identifying puzzle pieces on the map"
		$rotatona_puzzle.currentRoomPuzzleEvents = {
			:Discs	 			  		  => [],
			:Launchers_Rotatable  		  => [],
			:Launchers_Overlay_Rotatable  => [],
			:Launchers_Stationary 		  => [],
			:Launchers_Overlay_Stationary => [],
			:Catchers             		  => [],
			:Ramps           	  		  => [],
			:StraightTracks       	 	  => [],
			:CornerTracks  		  	  	  => []
		}
		$game_map.events.each_value do |event|
			#set all variables to nil
			event.associatedLauncher = nil
			event.associatedOverlay = nil
			event.launcherThisDiscIsDockedIn = nil
			event.launcherThisDiscWasLaunchedFrom = nil
			event.discThisLauncherHasDocked = nil
			event.discRolling = false
			event.discTouchingTile = []
			event.discTurningDirection = nil
			event.discJumping = false
			event.discLandingSpot = []
			event.catcherHasDisc = false
			@frameWaitCounter = 0
			@timer = 0
		
			$rotatona_puzzle.currentRoomPuzzleEvents[:Discs].push(event) if event.name.match(/RotaPuzzle_Disc/i)
			if event.name.match(/RotaPuzzle_Launcher_Rotatable/i)
				#identify launchers and their associated overlay events
				$rotatona_puzzle.currentRoomPuzzleEvents[:Launchers_Rotatable].push(event)
				#check coordinate to the right of the event, as this should be the associated overlay
				$game_map.events.each_value do |overlayEvent|
					if overlayEvent.x == event.x+1 && overlayEvent.y == event.y
						event.associatedOverlay = overlayEvent
						overlayEvent.associatedLauncher = event
						#turn overlay to be same direction as associated launcher
						overlayEvent.direction = event.direction
						break
					end
				end #$game_map.events.each_value do |overlayEvent|
			end
			$rotatona_puzzle.currentRoomPuzzleEvents[:Launchers_Overlay_Rotatable].push(event) if event.name.match(/RotaPuzzle_Launcher_Overlay_Rotatable/i)
			if event.name.match(/RotaPuzzle_Launcher_Stationary/i)
				#identify launchers and their associated overlay events
				$rotatona_puzzle.currentRoomPuzzleEvents[:Launchers_Stationary].push(event)
				#check coordinate to the right of the event, as this should be the associated overlay
				$game_map.events.each_value do |overlayEvent|
					if overlayEvent.x == event.x+1 && overlayEvent.y == event.y
						event.associatedOverlay = overlayEvent
						overlayEvent.associatedLauncher = event
						break
					end
				end #$game_map.events.each_value do |overlayEvent|
			end
			$rotatona_puzzle.currentRoomPuzzleEvents[:Launchers_Overlay_Stationary].push(event) if event.name.match(/RotaPuzzle_Launcher_Overlay_Stationary/i)
			$rotatona_puzzle.currentRoomPuzzleEvents[:Catchers].push(event) if event.name.match(/RotaPuzzle_Catcher/i)
			$rotatona_puzzle.currentRoomPuzzleEvents[:Ramps].push(event) if event.name.match(/RotaPuzzle_Ramp/i)
			$rotatona_puzzle.currentRoomPuzzleEvents[:StraightTracks].push(event) if event.name.match(/RotaPuzzle_StraightTrack/i)
			$rotatona_puzzle.currentRoomPuzzleEvents[:CornerTracks].push(event) if event.name.match(/RotaPuzzle_CornerTrack/i)
		end
		
		#dock rotatona disc at start
		#if rotatona disc is touching launcher event, dock it to that launcher
		$game_map.events.each_value do |event|
			#skip event if it's not a disc
			next if !$rotatona_puzzle.currentRoomPuzzleEvents[:Discs].include?(event)
			$game_map.events.each_value do |launcherEvent|
				next if !$rotatona_puzzle.currentRoomPuzzleEvents[:Launchers_Rotatable].include?(launcherEvent) && !$rotatona_puzzle.currentRoomPuzzleEvents[:Launchers_Stationary].include?(launcherEvent)
				#get the center X and center Y of the launcher
				centerX = launcherEvent.x+1
				centerY = launcherEvent.y-1
				#check if disc is touching center of launcher
				#print "disc event #{event.id} is docked at launcher event #{launcherEvent.id}" if event.x == centerX && event.y == centerY
				if event.x == centerX && event.y == centerY
					event.launcherThisDiscIsDockedIn = launcherEvent
					launcherEvent.discThisLauncherHasDocked = event
					#turn rotatona disc event to match direction of launcher it's docked in
					event.direction = event.launcherThisDiscIsDockedIn.direction
				end
			end
		end
	end #def self.getPuzzleEvents
	
	#save all events' current X, Y, and direction
	def self.saveEventVariables
		#I might need to save event IDs somewhere because restoring values to an event object might vary in result. Event objects could be different values when the game reloads
		#if I start a new game, then identify puzzle pieces, will the puzzle pieces variable exist if I enter the room again without identifying pieces? If so, I don't need to store event IDs and assign stored values based on event ID
		$game_map.events.each_value do |event|
			event.storedPuzzleID = event.id
			event.storedX = event.x
			event.storedY = event.y
			event.storedDirection = event.direction
			event.storedAssociatedLauncher = event.associatedLauncher
			event.storedAssociatedOverlay = event.associatedOverlay
			event.storedLauncherThisDiscIsDockedIn = event.launcherThisDiscIsDockedIn
			event.storedLauncherThisDiscWasLaunchedFrom = event.launcherThisDiscWasLaunchedFrom
			event.storedDiscThisLauncherHasDocked = event.discThisLauncherHasDocked
			event.storedDiscRolling = event.discRolling
			event.storedTouchingTile = event.discTouchingTile
			event.storedDiscTurningDirection = event.discTurningDirection
			event.storedDiscJumping = event.discJumping
			event.storedDiscLandingSpot = event.discLandingSpot
			event.storedCatcherHasDisc = event.catcherHasDisc
		end
	end #def self.saveEventVariables
	
	def self.loadEventPositions
		#go through each of the map's current events
		$game_map.events.each_value do |event|
			#and compare the currently selected event to each of the events stored in $rotatona_puzzle.currentRoomPuzzleEvents until we find a match in the id vs storedPuzzleID
			$rotatona_puzzle.currentRoomPuzzleEvents.each_value do |storedEventsArray|
				for oldEvent in storedEventsArray
						if 	event.id == oldEvent.storedPuzzleID
							Console.echo_warn "map event with id #{event.id} matches with an event in $rotatona_puzzle.currentRoomPuzzleEvents with storedPuzzleID #{oldEvent.storedPuzzleID}"
							event.moveto(oldEvent.storedX, oldEvent.storedY)
							event.direction = oldEvent.storedDirection
							
							event.associatedLauncher = event.storedAssociatedLauncher
							event.associatedOverlay = event.storedAssociatedOverlay
							event.launcherThisDiscIsDockedIn = event.storedLauncherThisDiscIsDockedIn
							event.launcherThisDiscWasLaunchedFrom = event.storedLauncherThisDiscWasLaunchedFrom
							event.discThisLauncherHasDocked = event.storedDiscThisLauncherHasDocked
							event.discRolling = event.storedDiscRolling
							event.discTouchingTile = event.storedTouchingTile
							event.discTurningDirection = event.storedDiscTurningDirection
							event.discJumping = event.storedDiscJumping
							event.discLandingSpot = event.storedDiscLandingSpot
							event.catcherHasDisc = event.storedCatcherHasDisc
							next
						end #if event.id == oldEvent.storedPuzzleID
				end #for oldEvent in storedEventsArray
			end #$rotatona_puzzle.currentRoomPuzzleEvents.each_value do |oldEvent|
		end #$game_map.events.each_value do |event|
	end #self.loadEventPositions
end #class RotatonaPuzzle

#######################################
#========== Event Handlers ============
#######################################
#on_player_interact with puzzle event
EventHandlers.add(:on_player_interact, :rototona_puzzle_interact_with_puzzle_event, proc {
	#skip this check if not on Canyon Temple Left and Canyon Temple Right maps
	next if $game_map.map_id != 59 && $game_map.map_id != 120
	facingEvent = $game_player.pbFacingEvent
	RotatonaPuzzle.playerInteract(facingEvent) if facingEvent && facingEvent.name.match(/RotaPuzzle/i) && !RotatonaPuzzle.discRolling?
})

EventHandlers.add(:on_frame_update, :rotatona_puzzle_logic_listener, proc {
	#skip this check if not on Canyon Temple Left, Canyon Temple Right, or Canyon Temple Entrance maps
	next if $game_map.map_id != 59 && $game_map.map_id != 120 && $game_map.map_id != 128
	RotatonaPuzzle.cameraLogic if ! RotatonaPuzzle.cameraPanningToPlayer?
	RotatonaPuzzle.checkForRotatonaCollisions
	RotatonaPuzzle.updateRollingAnimation
	RotatonaPuzzle.discMoveForward
	RotatonaPuzzle.checkIfDiscTurning
})

EventHandlers.add(:on_enter_map, :rotatona_puzzle_get_puzzle_pieces_when_enter_map,
  proc { |_old_map_id|
	#skip this check if not on Canyon Temple Left and Canyon Temple Right maps
	next if $game_map.map_id != 59 && $game_map.map_id != 120
	#if old map is the same as new map, only identify puzzle pieces and load old values
	if $game_map.map_id == _old_map_id
		#restore stored values for events
		RotatonaPuzzle.loadEventPositions
	else
		#if old map ID is a different map, reset the pieces variables
		case $game_map.map_id
		when 59 #canyon temple left
			RotatonaPuzzle.moveDiscsPuzzleSolved if $game_switches[142]
		when 120 #canyon temple right
			RotatonaPuzzle.moveDiscsPuzzleSolved if $game_switches[143]
		when 128 #canyon temple entrance
			RotatonaPuzzle.moveDiscsPuzzleSolved if $game_switches[141]
		end
		RotatonaPuzzle.getPuzzleEvents
	end
  }
)

#######################################
#=========== Terrain Tags =============
#######################################
#terrain tags used for rotatona disc logic
GameData::TerrainTag.register({
  :id                     => :RotatonaPuzzle_Track_Corner1, #corner going left and down / up and right
  :id_number              => 19,
  :shows_grass_rustle     => false,
  :land_wild_encounters   => false,
})
GameData::TerrainTag.register({
  :id                     => :RotatonaPuzzle_Track_Corner2, #corner going right and down / up and left
  :id_number              => 20,
  :shows_grass_rustle     => false,
  :land_wild_encounters   => false,
})
GameData::TerrainTag.register({
  :id                     => :RotatonaPuzzle_Track_Corner3, #corner going down and right / left and up
  :id_number              => 21,
  :shows_grass_rustle     => false,
  :land_wild_encounters   => false,
})
GameData::TerrainTag.register({
  :id                     => :RotatonaPuzzle_Track_Corner4, #corner going down and left / right and up
  :id_number              => 22,
  :shows_grass_rustle     => false,
  :land_wild_encounters   => false,
})
GameData::TerrainTag.register({
  :id                     => :RotatonaPuzzle_Track_Horizontal,
  :id_number              => 23,
  :shows_grass_rustle     => false,
  :land_wild_encounters   => false,
})
GameData::TerrainTag.register({
  :id                     => :RotatonaPuzzle_Track_Vertical,
  :id_number              => 24,
  :shows_grass_rustle     => false,
  :land_wild_encounters   => false,
})
GameData::TerrainTag.register({
  :id                     => :RotatonaPuzzle_Track_Crossroad,
  :id_number              => 25,
  :shows_grass_rustle     => false,
  :land_wild_encounters   => false,
})
GameData::TerrainTag.register({
  :id                     => :RotatonaPuzzle_Track_DeadEndUp,
  :id_number              => 26,
  :shows_grass_rustle     => false,
  :land_wild_encounters   => false,
})
GameData::TerrainTag.register({
  :id                     => :RotatonaPuzzle_Track_DeadEndDown,
  :id_number              => 27,
  :shows_grass_rustle     => false,
  :land_wild_encounters   => false,
})
GameData::TerrainTag.register({
  :id                     => :RotatonaPuzzle_Track_DeadEndLeft,
  :id_number              => 28,
  :shows_grass_rustle     => false,
  :land_wild_encounters   => false,
})
GameData::TerrainTag.register({
  :id                     => :RotatonaPuzzle_Track_DeadEndRight,
  :id_number              => 29,
  :shows_grass_rustle     => false,
  :land_wild_encounters   => false,
})