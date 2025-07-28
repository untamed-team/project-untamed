#Helper Methods
class RotatonaPuzzle
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
		@currentRoomPuzzleEvents[:Discs].each do |event|
			return true if event.discRolling
		end #@currentRoomPuzzleEvents[:Discs].each do |event|
		return false
	end #def self.discRolling?
	
	def self.checkIfDiscTurning
		@currentRoomPuzzleEvents[:Discs].each do |event|
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
		end #@currentRoomPuzzleEvents[:Discs].each do |event|
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
		@currentRoomPuzzleEvents[:CornerTracks].each do |event|
			if discEvent.x == event.x && discEvent.y == event.y
				touchingTrack = event #need to know the event the disc is touching to know the direction
			end
		end #@currentRoomPuzzleEvents
		return touchingTrack
	end #def self.touchingCornerTrackEvent?(discEvent)
	
	def self.touchingCatcherEvent?(discEvent)
		#iterate through catcher events
		touchingCatcher = nil
		@currentRoomPuzzleEvents[:Catchers].each do |event|
			if discEvent.x == event.x && discEvent.y == event.y
				touchingCatcher = event #need to know the event the disc is touching to know the direction
			end
		end #@currentRoomPuzzleEvents
		return touchingCatcher
	end #def self.touchingCatcherEvent?(discEvent)
	
	def self.touchingStraightTrackEvent?(discEvent)
		touchingTrack = nil
		#iterate through rotatable straight track events
		@currentRoomPuzzleEvents[:StraightTracks].each do |event|
			if discEvent.x == event.x && discEvent.y == event.y
				touchingTrack = event #need to know the event the disc is touching to know the direction
			end
		end #@currentRoomPuzzleEvents
		return touchingTrack
	end #def self.touchingStraightTrackEvent?(discEvent)
	
	def self.touchingRampEvent?(discEvent)
		#iterate through togglable ramp events
		touchingRamp = nil
		#iterate through rotatable straight track events
		@currentRoomPuzzleEvents[:Ramps].each do |event|
			if discEvent.x == event.x && discEvent.y == event.y
				touchingRamp = event #need to know the event the disc is touching to know the direction
			end
		end #@currentRoomPuzzleEvents
		return touchingRamp
	end #def self.touchingRampEvent?(discEvent)
	
	def self.touchingLauncherEvent?(discEvent)
		#iterate through rotatable corner track events
		touchingLauncher = nil
		@currentRoomPuzzleEvents[:Launchers_Rotatable].each do |launcherEvent|
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
		end #@currentRoomPuzzleEvents
		@currentRoomPuzzleEvents[:Launchers_Stationary].each do |launcherEvent|
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
		end #@currentRoomPuzzleEvents

		return touchingLauncher
	end #def self.touchingLauncherEvent?(discEvent)
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
	#skip this check if old map is the same as new map
	
	#do not uncomment this until you move to another map and save there first
	next if $game_map.map_id == _old_map_id
	RotatonaPuzzle.getPuzzleEvents
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