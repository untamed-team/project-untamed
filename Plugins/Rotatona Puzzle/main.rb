#=============================================================================
# Rotatona Puzzle
#=============================================================================
#rules for making a puzzle:
#1. all events must have one of these names
#	RotaPuzzle_Disc
#	RotaPuzzle_Launcher_Rotatable
#	RotaPuzzle_Launcher_Overlay_Rotatable
#	RotaPuzzle_Launcher_Stationary
#	RotaPuzzle_Launcher_Overlay_Stationary
#	RotaPuzzle_Catcher
#	RotaPuzzle_Ramp
#	RotaPuzzle_StraightTrack
#	RotaPuzzle_CornerTrack
#2. All launchers' associated overlays must be on the same Y as the associated launcher, and the overlay must be 1 to the right of the launcher (e.g. launcher x is 10 and y is 20, associated overlay x is 11 and y is 20)
#3. Launcher overlays must have "Always on Top" checked
#4. Launcher overlays must have an event number higher than all Rotatona discs
#5. Rotatona discs must have "Always on Top" checked
#6. Launcher events must be 3x3 ( e.g. NAME,size(3,3) )
#7. Launcher overlay events must be 1x3 ( e.g. NAME,size(1,3) )
#8. All rotatble launchers and launchers which are stationary and not facing down need an associated launcher overlay
#9. Rotatona disc events must be placed 1 to the right and 1 up from the launcher you want it to start in
#10. Do not use terrain tags 19 through 29 for anything. Do not change the terrain tags on any of the tiles in the temple tileset
#11. Do not put events on top of track tiles from the tileset and expect them to work. The script checks for collisions with the track tiles FIRST, then processes any track events if not touching any track tiles
#12. Disc catcher events' ID numbers must be higher than disc events' IDs
#13. Disc catcher must have "Always on Top" checked

class Game_Temp
  attr_accessor :puzzleEvents
end

class Game_Event
  attr_accessor :associatedLauncher
  attr_accessor :associatedOverlay
  attr_accessor :launcherThisDiscIsDockedIn
  attr_accessor :launcherThisDiscWasLaunchedFrom
  attr_accessor :discThisLauncherHasDocked
  attr_accessor :discRolling
  attr_accessor :discTouchingTile
  attr_accessor :discTurningDirection
  attr_accessor :discJumping
  attr_accessor :discLandingSpot
  attr_accessor :catcherHasDisc
end

class RotatonaPuzzle
	SE_ROTATE_STRAIGHT_TRACK = "Cut"
	SE_SWITCH_RAMP = "Cut"
	SE_ROTATE_CORNER_TRACK = "Cut"
	SE_ROTATE_LAUNCHER = "Cut"
	SE_LAUNCHER_BUTTON = "Cut"
	SE_DOCKING = "Cut"
	SE_CATCHING = "Mining reveal"
	SE_DISC_JUMP = "Player jump"
	SE_DISC_CRASH = "Rock Smash"
	FRAMES_TO_WAIT_BETWEEN_ROLLING_PATTERNS = 3 #default is 3
	FRAMES_FOR_ROLLING_DISC_TURNING_ANIMATION = 0
	DISC_SPEED = 4 #default 4
	TILE_TRANSFER_PLAYER_CANYON_TEMPLE_ENTRANCE = [44,17]
	TILE_TRANSFER_PLAYER_CANYON_TEMPLE_LEFT = [16,21]
	TILE_TRANSFER_PLAYER_CANYON_TEMPLE_RIGHT = [16,21]

	def self.playerStandingOnTrackTileOrEvent?
		return true if $game_player.pbTerrainTag.id == :RotatonaPuzzle_Track_Corner1 || $game_player.pbTerrainTag.id == :RotatonaPuzzle_Track_Corner2 || $game_player.pbTerrainTag.id == :RotatonaPuzzle_Track_Corner3 || $game_player.pbTerrainTag.id == :RotatonaPuzzle_Track_Corner4 || $game_player.pbTerrainTag.id == :RotatonaPuzzle_Track_Horizontal || $game_player.pbTerrainTag.id == :RotatonaPuzzle_Track_Vertical || $game_player.pbTerrainTag.id == :RotatonaPuzzle_Track_Crossroad || $game_player.pbTerrainTag.id == :RotatonaPuzzle_Track_DeadEndUp || $game_player.pbTerrainTag.id == :RotatonaPuzzle_Track_DeadEndDown || $game_player.pbTerrainTag.id == :RotatonaPuzzle_Track_DeadEndLeft || $game_player.pbTerrainTag.id == :RotatonaPuzzle_Track_DeadEndRight || !self.touchingCornerTrackEvent?($game_player).nil? || !self.touchingCatcherEvent?($game_player).nil? || !self.touchingStraightTrackEvent?($game_player).nil? || !self.touchingRampEvent?($game_player).nil? || !self.touchingLauncherEvent?($game_player).nil?
		return false
	end #def self.playerStandingOnTrackTileOrEvent
	
	def self.launchRotatonaDisc(launcherEvent, discEvent)
		#move player off the track if standing on a track tile
		if self.playerStandingOnTrackTileOrEvent?
			#transfer player to designated tile with a fade to black then fade in
			#requires Advanced Map Transfers by Luka S.J.
			case $game_map.map_id
			when 59 #left
				pbTransferWithTransition(59, TILE_TRANSFER_PLAYER_CANYON_TEMPLE_LEFT[0], TILE_TRANSFER_PLAYER_CANYON_TEMPLE_LEFT[1], transition = nil, dir = 8)
			when 120 #right
				pbTransferWithTransition(120, TILE_TRANSFER_PLAYER_CANYON_TEMPLE_RIGHT[0], TILE_TRANSFER_PLAYER_CANYON_TEMPLE_RIGHT[1], transition = nil, dir = 8)
			when 128 #entrance
				pbTransferWithTransition(128, TILE_TRANSFER_PLAYER_CANYON_TEMPLE_ENTRANCE[0], TILE_TRANSFER_PLAYER_CANYON_TEMPLE_ENTRANCE[1], transition = nil, dir = 8)
			end #case $game_map.map_id
		end #if self.playerStandingOnTrackTileOrEvent?
	
		discEvent.launcherThisDiscWasLaunchedFrom = launcherEvent
		#launcherEvent = discEvent.launcherThisDiscIsDockedIn #unnecessary since we have the launcherEvent parameter?
		launcherEvent.discThisLauncherHasDocked = nil
		discEvent.launcherThisDiscIsDockedIn = nil
		
		#pan camera to disc
		pbMapInterpreter.autoscroll(discEvent.x, discEvent.y, 4)
		
		#start disc rolling
		pbSEPlay(SE_LAUNCHER_BUTTON)
		discEvent.discRolling = true
	end #def self.launchRotatonaDisc

	def self.cameraLogic
		#for all discs rolling, camera autoscroll to the disc
		$game_temp.puzzleEvents[:Discs].each do |event|
			next if !event.discRolling
			#start with locking the player in place
			$game_player.lock
			#scroll camera to moving disc
			pbMapInterpreter.autoscroll(event.x, event.y, DISC_SPEED+1)
		end #$game_temp.puzzleEvents[:Discs].each do |event|
		
		#when disc is caught, @needPanCameraToPlayer will be set to true
		#if disc has not been caught, return so we don't pan camera to player
		if @needPanCameraToPlayer.nil? || !@needPanCameraToPlayer
			return
		end
		
		#when disc is caught or crashes, wait 1 second
		if @needPanCameraToPlayer
			@timer = Graphics.frame_rate * 1
			loop do
				Graphics.update
				break if @timer <= 0
				Console.echo_warn @timer
				@timer -= 1
			end
			#pan camera back to player
			@needPanCameraToPlayer = false
			pbMapInterpreter.autoscroll_player(DISC_SPEED+1)
			#release player
			$game_player.unlock
		end #if !@needPanCameraToPlayer.nil? && @needPanCameraToPlayer
	end #def self.cameraLogic

	def self.getPuzzleEvents	
		Console.echo_warn "identifying puzzle pieces from scratch"
		#identify all the events on the map which correspond with the puzzle
		#print "identifying puzzle pieces on the map"
		$game_temp.puzzleEvents = {
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
			@needPanCameraToPlayer = false
		
			$game_temp.puzzleEvents[:Discs].push(event) if event.name.match(/RotaPuzzle_Disc/i)
			if event.name.match(/RotaPuzzle_Launcher_Rotatable/i)
				#identify launchers and their associated overlay events
				$game_temp.puzzleEvents[:Launchers_Rotatable].push(event)
				#check coordinate to the right of the event, as this should be the associated overlay
				$game_map.events.each_value do |overlayEvent|
					if overlayEvent.x == event.x+1 && overlayEvent.y == event.y
						event.associatedOverlay = overlayEvent
						overlayEvent.associatedLauncher = event
						break
					end
				end #$game_map.events.each_value do |overlayEvent|
			end
			$game_temp.puzzleEvents[:Launchers_Overlay_Rotatable].push(event) if event.name.match(/RotaPuzzle_Launcher_Overlay_Rotatable/i)
			if event.name.match(/RotaPuzzle_Launcher_Stationary/i)
				#identify launchers and their associated overlay events
				$game_temp.puzzleEvents[:Launchers_Stationary].push(event)
				#check coordinate to the right of the event, as this should be the associated overlay
				$game_map.events.each_value do |overlayEvent|
					if overlayEvent.x == event.x+1 && overlayEvent.y == event.y
						event.associatedOverlay = overlayEvent
						overlayEvent.associatedLauncher = event
						break
					end
				end #$game_map.events.each_value do |overlayEvent|
			end
			$game_temp.puzzleEvents[:Launchers_Overlay_Stationary].push(event) if event.name.match(/RotaPuzzle_Launcher_Overlay_Stationary/i)
			$game_temp.puzzleEvents[:Catchers].push(event) if event.name.match(/RotaPuzzle_Catcher/i)
			$game_temp.puzzleEvents[:Ramps].push(event) if event.name.match(/RotaPuzzle_Ramp/i)
			$game_temp.puzzleEvents[:StraightTracks].push(event) if event.name.match(/RotaPuzzle_StraightTrack/i)
			$game_temp.puzzleEvents[:CornerTracks].push(event) if event.name.match(/RotaPuzzle_CornerTrack/i)
		end
		
		#dock rotatona disc at start
		#if rotatona disc is touching launcher event, dock it to that launcher
		$game_map.events.each_value do |event|
			#skip event if it's not a disc
			next if !$game_temp.puzzleEvents[:Discs].include?(event)
			$game_map.events.each_value do |launcherEvent|
				next if !$game_temp.puzzleEvents[:Launchers_Rotatable].include?(launcherEvent) && !$game_temp.puzzleEvents[:Launchers_Stationary].include?(launcherEvent)
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

	def self.discRolling?
		$game_temp.puzzleEvents[:Discs].each do |event|
			return true if event.discRolling
		end #$game_temp.puzzleEvents[:Discs].each do |event|
		return false
	end #def self.discRolling?

	def self.playerInteract(event)
		#events are passed in as GameData		
		if $game_temp.puzzleEvents[:Discs].include?(event)
			#print "this is rota1"
			#option to launch if docked
			#rota1LaunchChoice = pbConfirmMessage("Launch the disc?")
			#print "launching disc from launcher 1" if rota1LaunchChoice
		###################################################################	
		elsif $game_temp.puzzleEvents[:Launchers_Rotatable].include?(event)
			#print "this is #{event}, and its associatedOverlay is #{event.associatedOverlay}"
			choices = [
				_INTL("Left Arrow Button"), #0
				_INTL("Right Arrow Button"), #1
				_INTL("Square Button"), #2
				_INTL("Nevermind") #3 or -1
			]
			launcher2Choice = pbMessage(_INTL("There are arrow buttons and a square button here."), choices, choices.length) #if disc not docked
			case launcher2Choice
			when 0
				#print "turning launcer left"
				self.rotateLauncher(event,"left90")
			when 1
				#print "turning launcher right"
				self.rotateLauncher(event,"right90")
			when 2
				if !event.discThisLauncherHasDocked.nil?
					self.launchRotatonaDisc(event, event.discThisLauncherHasDocked)
				else
					pbSEPlay(SE_LAUNCHER_BUTTON)
					choice = pbMessage(_INTL("Nothing happened."))
				end
			end
		###################################################################
		elsif $game_temp.puzzleEvents[:Launchers_Overlay_Rotatable].include?(event)
			#print "this is #{event}, and its associatedLauncher is #{event.associatedLauncher}"
			choices = [
				_INTL("Left Arrow Button"), #0
				_INTL("Right Arrow Button"), #1
				_INTL("Square Button"), #2
				_INTL("Nevermind") #3 or -1
			]
			launcherChoice = pbMessage(_INTL("There are arrow buttons and a square button here."), choices, choices.length) #if disc not docked
			case launcherChoice
			when 0
				#print "turning launcer left"
				self.rotateLauncher(event.associatedLauncher,"left90")
			when 1
				#print "turning launcher right"
				self.rotateLauncher(event.associatedLauncher,"right90")
			when 2
				if !event.associatedLauncher.discThisLauncherHasDocked.nil? #discDocked
					self.launchRotatonaDisc(event.associatedLauncher, event.associatedLauncher.discThisLauncherHasDocked)
				else
					pbSEPlay(SE_LAUNCHER_BUTTON)
					choice = pbMessage(_INTL("Nothing happened."))
				end
			end
		###################################################################	
		elsif $game_temp.puzzleEvents[:Launchers_Stationary].include?(event)
			if !event.discThisLauncherHasDocked.nil?
				#if disc is docked
				choice = pbConfirmMessage(_INTL("There's a square button here. Press it?"))
				self.launchRotatonaDisc(event, event.discThisLauncherHasDocked) if choice
			else
				#if disc not docked
				choice = pbConfirmMessage(_INTL("There's a square button here. Press it?"))
				pbSEPlay(SE_LAUNCHER_BUTTON) if choice
				pbMessage(_INTL("Nothing happened.")) if choice
			end
			
		###################################################################	
		elsif $game_temp.puzzleEvents[:Launchers_Overlay_Stationary].include?(event)
			if !event.associatedLauncher.discThisLauncherHasDocked.nil? #discDocked
				#if disc is docked
				choice = pbConfirmMessage(_INTL("There's a square button here. Press it?"))
				self.launchRotatonaDisc(event.associatedLauncher, event.associatedLauncher.discThisLauncherHasDocked) if choice
			else
				#if disc not docked
				choice = pbConfirmMessage(_INTL("There's a square button here. Press it?"))
				pbSEPlay(SE_LAUNCHER_BUTTON) if choice
				pbMessage(_INTL("Nothing happened.")) if choice
			end
			
		###################################################################
		elsif event == $game_temp.puzzleEvents[:Catchers]
			#print "this is catcher2"
			#maybe some text about how the rota would seem to fit perfectly in here
			pbMessage(_INTL("A large disc looks like it would fit perfectly in here."))
		###################################################################
		elsif $game_temp.puzzleEvents[:Ramps].include?(event)
			#print "this is a ramp"
			#option to switch 180 degrees
			rampChoice = pbConfirmMessage("There's a switch here. Press it?")
			self.switchRamp(event) if rampChoice
		###################################################################
		elsif $game_temp.puzzleEvents[:StraightTracks].include?(event)
			#print "this is a straight track"
			#option to turn track 90 degrees
			straightTrackChoice = pbConfirmMessage("There's a switch here. Press it?")
			self.rotateStraightTrack(event) if straightTrackChoice
		###################################################################
		elsif $game_temp.puzzleEvents[:CornerTracks].include?(event)
			#print "this is a corner track"
			#option to turn track 90 degrees
			choices = [
				_INTL("Turn Left"), #0
				_INTL("Turn Right"), #1
				_INTL("Nevermind") #2 or -1
			]
			cornerTrackChoice = pbMessage(_INTL("There are arrow buttons here."), choices, choices.length)
			case cornerTrackChoice
			when 0
				#print "turning corner track left"
				self.rotateCornerTrack(event,"left90")
			when 1
				#print "turning corner track right"
				self.rotateCornerTrack(event,"right90")
			end
		end #if $game_temp.puzzleEvents[:Discs].include?(event)
	end #def self.playerInteract

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
	
	def self.checkForRotatonaCollisions
		$game_temp.puzzleEvents[:Discs].each do |event|
			next if !event.discRolling
			
			#set the tile the disc is touching if it's different than before (so we can't double dip on the same tile when checking for collisions)
			#this way, a collision check is only done once when the disc touches the tile
			next if event.discTouchingTile == [event.x, event.y]
			event.discTouchingTile = [event.x, event.y] if event.discTouchingTile != [event.x, event.y]
			#Console.echo_warn event.discTouchingTile
			
			#don't check for collisions if currently airborn from ramp
			if event.discJumping
				#Console.echo_warn "jumping to #{event.discLandingSpot}"
				if event.x == event.discLandingSpot[0] && event.y == event.discLandingSpot[1]
					#test for ramp direction on the tile we landed on
					#if ramp isn't facing correct way, crash
					if !self.touchingRampEvent?(event).nil?
						rampEvent = self.touchingRampEvent?(event)
						#since the disc is in mid air, we need to check for a receiving ramp facing the correct direction, not facing the same direction as the previous ramp
						case rampEvent.direction
						when 2 #ramp is facing down
							if event.direction == 8
								#Console.echo_warn "disc received successfully onto 2nd ramp"
							else
								self.crashRotatona(event, "ramp facing down, disc not facing up")
							end

						when 4 #ramp is facing left
							if event.direction == 6
								#Console.echo_warn "disc received successfully onto 2nd ramp"
							else
								self.crashRotatona(event, "ramp facing left, disc not facing right")
							end
					
						when 6 #ramp is facing right
							if event.direction == 4
								Console.echo_warn "disc received successfully onto 2nd ramp"
							else
								self.crashRotatona(event, "ramp facing right, disc not facing left")
							end

						when 8 #ramp is facing up
							if event.direction == 2
								#Console.echo_warn "disc received successfully onto 2nd ramp"
							else
								self.crashRotatona(event, "ramp facing up, disc not facing down")
							end
						end #case rampEvent.direction
					end #if !self.touchingRampEvent?(event).nil?
					next if !event.discRolling					
					
					#if landing is successful
					#Console.echo_warn "landed on #{event.discLandingSpot[0]},#{event.discLandingSpot[1]} - disc location is #{event.x},#{event.y}"
					event.discJumping = false
					event.discLandingSpot = []
					next #disc landed on receiving ramp; skip checking collisions on this tile
				else
					#Console.echo_warn "jumping but not on landing spot yet"
					next					
				end #if event.x == event.discLandingSpot[0] && event.y == event.discLandingSpot[1]
			end #if event.discJumping
			
			#we don't want to check for collisions if the disc is currently turning (like when it hits a corner track)
			next if !event.discTurningDirection.nil?
			turnSpriteDirectionForPattern = 8 #use the turn sprites on the UP direction
			
			if $game_map.terrain_tag(event.x, event.y).id == :RotatonaPuzzle_Track_Corner1
				#corner going left and down / up and right
				case event.direction
				when 2 #down
					self.crashRotatona(event, "touched track corner1, disc facing down")
				when 4 #left
					newDirection = 2 #down
					turnSpritePattern = self.determinePatterForTurning(event, newDirection)
					#start move route, then turn on discTurningDirection
					pbMoveRoute(event, [
						PBMoveRoute::Graphic, event.character_name, event.character_hue, turnSpriteDirectionForPattern, turnSpritePattern,
						PBMoveRoute::Wait, FRAMES_FOR_ROLLING_DISC_TURNING_ANIMATION,
						PBMoveRoute::Graphic, event.character_name, event.character_hue, newDirection, 1
					], waitComplete = true)
					
					event.discTurningDirection = newDirection
				when 6 #right
					self.crashRotatona(event, "touched track corner1, disc facing right")
				when 8 #up
					newDirection = 6 #right
					turnSpritePattern = self.determinePatterForTurning(event, newDirection)
					#start move route, then turn on discTurningDirection
					pbMoveRoute(event, [
						PBMoveRoute::Graphic, event.character_name, event.character_hue, turnSpriteDirectionForPattern, turnSpritePattern,
						PBMoveRoute::Wait, FRAMES_FOR_ROLLING_DISC_TURNING_ANIMATION,
						PBMoveRoute::Graphic, event.character_name, event.character_hue, newDirection, 1
					], waitComplete = true)
					
					event.discTurningDirection = newDirection
				end #case event.direction

			elsif $game_map.terrain_tag(event.x, event.y).id == :RotatonaPuzzle_Track_Corner2
				#corner going right and down / up and left				
				case event.direction
				when 2 #down
					self.crashRotatona(event, "touched track corner2, disc facing down")
				when 4 #left
					self.crashRotatona(event, "touched track corner2, disc facing left")
				when 6 #right
					newDirection = 2 #down
				when 8 #up
					newDirection = 4 #left
				end #case event.direction
				
				#next if disc crashed
				
				turnSpritePattern = self.determinePatterForTurning(event, newDirection)	
				#start move route, then turn on discTurningDirection
				pbMoveRoute(event, [
					PBMoveRoute::Graphic, event.character_name, event.character_hue, turnSpriteDirectionForPattern, turnSpritePattern,
					PBMoveRoute::Wait, FRAMES_FOR_ROLLING_DISC_TURNING_ANIMATION,
					PBMoveRoute::Graphic, event.character_name, event.character_hue, newDirection, 1
				], waitComplete = true)
				event.discTurningDirection = newDirection

			elsif $game_map.terrain_tag(event.x, event.y).id == :RotatonaPuzzle_Track_Corner3
				#corner going down and right / left and up
				case event.direction
				when 2 #down
					newDirection = 6 #right
				when 4 #left
					newDirection = 8 #up
				when 6 #right
					self.crashRotatona(event, "touched track corner3, disc facing right")
				when 8 #up
					self.crashRotatona(event, "touched track corner3, disc facing up")
				end #case event.direction
				
				#next if disc crashed
				
				turnSpritePattern = self.determinePatterForTurning(event, newDirection)	
				#start move route, then turn on discTurningDirection
				pbMoveRoute(event, [
					PBMoveRoute::Graphic, event.character_name, event.character_hue, turnSpriteDirectionForPattern, turnSpritePattern,
					PBMoveRoute::Wait, FRAMES_FOR_ROLLING_DISC_TURNING_ANIMATION,
					PBMoveRoute::Graphic, event.character_name, event.character_hue, newDirection, 1
				], waitComplete = true)
				event.discTurningDirection = newDirection
				
			elsif $game_map.terrain_tag(event.x, event.y).id == :RotatonaPuzzle_Track_Corner4
				#corner going down and left / right and up
				case event.direction
				when 2 #down
					newDirection = 4 #left
				when 4 #left
					self.crashRotatona(event, "touched track corner4, disc facing left")
				when 6 #right
					newDirection = 8 #up
				when 8 #up
					self.crashRotatona(event, "touched track corner4, disc facing up")
				end #case event.direction
				
				#next if disc crashed
				
				turnSpritePattern = self.determinePatterForTurning(event, newDirection)	
				#start move route, then turn on discTurningDirection
				pbMoveRoute(event, [
					PBMoveRoute::Graphic, event.character_name, event.character_hue, turnSpriteDirectionForPattern, turnSpritePattern,
					PBMoveRoute::Wait, FRAMES_FOR_ROLLING_DISC_TURNING_ANIMATION,
					PBMoveRoute::Graphic, event.character_name, event.character_hue, newDirection, 1
				], waitComplete = true)
				event.discTurningDirection = newDirection
				
			elsif $game_map.terrain_tag(event.x, event.y).id == :RotatonaPuzzle_Track_Horizontal
				#no special behavior except crashing when hitting wall of track
				case event.direction
				when 2 #down
					self.crashRotatona(event, "touched horizontal track, disc facing down")
				when 8 #up
					self.crashRotatona(event, "touched horizontal track, disc facing up")
				end #case event.direction
				
			elsif $game_map.terrain_tag(event.x, event.y).id == :RotatonaPuzzle_Track_Vertical
				#no special behavior except crashing when hitting wall of track
				case event.direction
				when 4 #left
					self.crashRotatona(event, "touched vertical track, disc facing left")
				when 6 #right
					self.crashRotatona(event, "touched vertical track, disc facing right")
				end #case event.direction
				
			elsif $game_map.terrain_tag(event.x, event.y).id == :RotatonaPuzzle_Track_Crossroad
				#do nothing, but this keeps the disc from crashing during the 'else' block

			elsif $game_map.terrain_tag(event.x, event.y).id == :RotatonaPuzzle_Track_DeadEndUp
				self.crashRotatona(event, "touched dead end up")

			elsif $game_map.terrain_tag(event.x, event.y).id == :RotatonaPuzzle_Track_DeadEndDown
				self.crashRotatona(event, "touched dead end down")

			elsif $game_map.terrain_tag(event.x, event.y).id == :RotatonaPuzzle_Track_DeadEndLeft
				self.crashRotatona(event, "touched dead end left")

			elsif $game_map.terrain_tag(event.x, event.y).id == :RotatonaPuzzle_Track_DeadEndRight
				self.crashRotatona(event, "touched dead end right")
			
			elsif !self.touchingCornerTrackEvent?(event).nil?
				#print "this will print once per track it touches" #it didn't print for track 29
				cornerTrackEvent = self.touchingCornerTrackEvent?(event)
				case cornerTrackEvent.direction
				when 2 #going up, turning right OR going left, turning down
					case event.direction
					when 2 #down
						self.crashRotatona(event, "touched corner track event, track facing down, disc facing down")
					when 4 #left
						newDirection = 2 #down
					when 6 #right
						self.crashRotatona(event, "touched corner track event, track facing down, disc facing right")
					when 8 #up
						newDirection = 6 #right
					end #case event.direction

				when 4 #going right, turning down OR going up, turning left
					case event.direction
					when 2 #down
						self.crashRotatona(event, "touched corner track event, track facing left, disc facing down")
					when 4 #left
						self.crashRotatona(event, "touched corner track event, track facing left, disc facing left")
					when 6 #right
						newDirection = 2 #down
					when 8 #up
						newDirection = 4 #left
					end #case event.direction
					
				when 6 #going down, turning right OR going left, turning up
					case event.direction
					when 2 #down
						newDirection = 6 #right
					when 4 #left
						newDirection = 8 #up
					when 6 #right
						self.crashRotatona(event, "touched corner track event, track facing right, disc facing right")
					when 8 #up
						self.crashRotatona(event, "touched corner track event, track facing right, disc facing up")
					end #case event.direction
					
				when 8 #going right, turning up OR going down, turning left
					case event.direction
					when 2 #down
						newDirection = 4 #left
					when 4 #left
						self.crashRotatona(event, "touched corner track event, track facing up, disc facing left")
						crashed = true
					when 6 #right
						newDirection = 8 #up
					when 8 #up
						self.crashRotatona(event, "touched corner track event, track facing up, disc facing up")
					end #case event.direction
				end #case cornerTrackEvent.direction
				
				#next if disc crashed
				next if !event.discRolling
				
				turnSpritePattern = self.determinePatterForTurning(event, newDirection)	
				#start move route, then turn on discTurningDirection
				pbMoveRoute(event, [
					PBMoveRoute::Graphic, event.character_name, event.character_hue, turnSpriteDirectionForPattern, turnSpritePattern,
					PBMoveRoute::Wait, FRAMES_FOR_ROLLING_DISC_TURNING_ANIMATION,
					PBMoveRoute::Graphic, event.character_name, event.character_hue, newDirection, 1
				], waitComplete = true)
				event.discTurningDirection = newDirection

			elsif !self.touchingCatcherEvent?(event).nil?
				catcherEvent = self.touchingCatcherEvent?(event)
				if catcherEvent.catcherHasDisc
					#catcher already has a disc docked
					self.crashRotatona(event, "disc touched catcher that already had a disc docked in it")
				else
					self.catchDisc(event, catcherEvent)
				end


			elsif !self.touchingStraightTrackEvent?(event).nil?
				straightTrackEvent = self.touchingStraightTrackEvent?(event)
				case straightTrackEvent.direction
				when 2 #straight track is facing up and down
					case event.direction
					when 4 #left
						self.crashRotatona(event, "touched straight track event, track facing down, disc facing left")
					when 6 #right
						self.crashRotatona(event, "touched straight track event, track facing down, disc facing right")
					end #case event.direction

				when 4 #straight track is facing left and right
					case event.direction
					when 2 #down
						self.crashRotatona(event, "touched straight track event, track facing left, disc facing down")
					when 8 #up
						self.crashRotatona(event, "touched straight track event, track facing left, disc facing up")
					end #case event.direction
					
				when 6 #straight track is facing left and right
					case event.direction
					when 2 #down
						self.crashRotatona(event, "touched straight track event, track facing right, disc facing down")
					when 8 #up
						self.crashRotatona(event, "touched straight track event, track facing right, disc facing up")
					end #case event.direction
					
				when 8 #straight track is facing up and down
					case event.direction
					when 4 #left
						self.crashRotatona(event, "touched straight track event, track facing up, disc facing left")
					when 6 #right
						self.crashRotatona(event, "touched straight track event, track facing up, disc facing right")
					end #case event.direction
				end #case cornerTrackEvent.direction
				
				#next if disc crashed
				next if !event.discRolling
			
			elsif !self.touchingRampEvent?(event).nil?
				rampEvent = self.touchingRampEvent?(event)
				case rampEvent.direction
				when 2 #ramp is facing down
					case event.direction
					when 2 #down
						#jump
						event.discJumping = true
						event.discLandingSpot = [event.x, event.y+2]
						pbSEPlay(SE_DISC_JUMP)
						#PBMoveRoute::Jump, X+, Y+
						pbMoveRoute(event, [PBMoveRoute::Jump, 0, 2])
					when 4 #left
						self.crashRotatona(event, "touched ramp track event, ramp facing down, disc facing left")
					when 6 #right
						self.crashRotatona(event, "touched ramp track event, ramp facing down, disc facing right")
					when 8 #up
						self.crashRotatona(event, "touched ramp track event, ramp facing down, disc facing up")
					end #case event.direction

				when 4 #ramp is facing left
					case event.direction
					when 2 #down
						self.crashRotatona(event, "touched ramp track event, ramp facing left, disc facing down")
					when 4 #left
						#jump
						event.discJumping = true
						event.discLandingSpot = [event.x-2, event.y]
						pbSEPlay(SE_DISC_JUMP)
						#PBMoveRoute::Jump, X+, Y+
						pbMoveRoute(event, [PBMoveRoute::Jump, 0, 2])
					when 6 #right
						self.crashRotatona(event, "touched ramp track event, ramp facing left, disc facing right")
					when 8 #up
						self.crashRotatona(event, "touched ramp track event, ramp facing left, disc facing up")
					end #case event.direction
					
				when 6 #ramp is facing right
					case event.direction
					when 2 #down
						self.crashRotatona(event, "touched ramp track event, ramp facing right, disc facing down")
					when 4 #left
						self.crashRotatona(event, "touched ramp track event, ramp facing right, disc facing left")
					when 6 #right
						#jump
						event.discJumping = true
						event.discLandingSpot = [event.x+2, event.y]
						pbSEPlay(SE_DISC_JUMP)
						#PBMoveRoute::Jump, X+, Y+
						pbMoveRoute(event, [PBMoveRoute::Jump, 0, 2])
					when 8 #up
						self.crashRotatona(event, "touched ramp track event, ramp facing right, disc facing up")
					end #case event.direction
					
				when 8 #ramp is facing up
					case event.direction
					when 2 #down
						self.crashRotatona(event, "touched ramp track event, ramp facing up, disc facing down")
					when 4 #left
						self.crashRotatona(event, "touched ramp track event, ramp facing up, disc facing left")
					when 6 #right
						self.crashRotatona(event, "touched ramp track event, ramp facing up, disc facing right")
					when 8 #up
						#jump
						event.discJumping = true
						event.discLandingSpot = [event.x, event.y-2]
						pbSEPlay(SE_DISC_JUMP)
						#PBMoveRoute::Jump, X+, Y+
						pbMoveRoute(event, [PBMoveRoute::Jump, 0, 2])
					end #case event.direction
				end #case cornerTrackEvent.direction
				
				#next if disc crashed
				next if !event.discRolling
			
			elsif !self.touchingLauncherEvent?(event).nil?
				launcherEvent = self.touchingLauncherEvent?(event)
				#Console.echo_warn "touching launcher event"
				#skip if touching the same launcher we came from
				next if launcherEvent == event.launcherThisDiscWasLaunchedFrom
				
				#disc is not docked, so look for a launcher to dock in
				#Console.echo_warn "disc is touching a launcher event; going to stop disc from rolling"
				case launcherEvent.direction
				when 2 #launcher is facing down
					if event.direction == 8 #disc going up
						#Console.echo_warn "docked successfully"
						self.dockDisc(event, launcherEvent)
					else
						self.crashRotatona(event, "touched launcher event, launcher facing down, disc not facing up")
					end #if event.direction ==

				when 4 #launcher is facing left
					if event.direction == 6 #disc going right
						#Console.echo_warn "docked successfully"
						self.dockDisc(event, launcherEvent)
					else
						self.crashRotatona(event, "touched launcher event, launcher facing left, disc not facing right")
					end #if event.direction ==
					
				when 6 #launcher is facing right
					if event.direction == 4 #disc going left
						#Console.echo_warn "docked successfully"
						self.dockDisc(event, launcherEvent)
					else
						self.crashRotatona(event, "touched launcher event, launcher facing right, disc not facing left")
					end #if event.direction ==
					
				when 8 #launcher is facing up
					if event.direction == 2 #disc going down
						#Console.echo_warn "docked successfully"
						self.dockDisc(event, launcherEvent)
					else
						self.crashRotatona(event, "touched launcher event, launcher facing up, disc not facing down")
					end #if event.direction ==
				end #case launcherEvent.direction				
				
				#next if disc crashed
				next if !event.discRolling
				
			else
				#not on the track, not touching a track event, not jumping from ramp
				#crash
				self.crashRotatona(event, "disc not touching track, not touching track event, not jumping from ramp")
			end #if colliding with something
		end #$game_temp.puzzleEvents[:Discs].each do |event|
	end #self.checkForRotatonaCollisions
	
	def self.dockDisc(discEvent, launcherEvent)
		#Console.echo_warn "docking disc"
		discEvent.launcherThisDiscIsDockedIn = launcherEvent
		launcherEvent.discThisLauncherHasDocked = discEvent
		
		#reset variables for launcher the disc came from
		discEvent.launcherThisDiscWasLaunchedFrom.discThisLauncherHasDocked = nil
		
		discEvent.discRolling = false
		#turn rotatona disc event to match direction of launcher it's docked in
		discEvent.direction = discEvent.launcherThisDiscIsDockedIn.direction
		discEvent.character_name = "Rotatona_Disc_Anim1"
		discEvent.pattern = 1
	end #def self.dockDisc
	
	def self.catchDisc(discEvent, catcherEvent)
		#turn off "always on"
		pbMoveRoute(discEvent, [PBMoveRoute::AlwaysOnTopOff])
		catcherEvent.catcherHasDisc = true
		pbSEPlay(SE_CATCHING)
		discEvent.discRolling = false
		@needPanCameraToPlayer = true
	end #def self.catchDisc
	
	def self.checkIfDiscTurning
		$game_temp.puzzleEvents[:Discs].each do |event|
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
		end #$game_temp.puzzleEvents[:Discs].each do |event|
	end #def self.turnDisc(event, oldDirection, newDirection)
	
	def self.discMoveForward
		$game_temp.puzzleEvents[:Discs].each do |event|
			#don't move if not rolling
			next if !event.discRolling
			#we don't want to move forward if the disc is currently turning
			next if !event.discTurningDirection.nil?

			#set speed
			pbMoveRoute(event, [PBMoveRoute::ChangeSpeed, DISC_SPEED])
			#roll forward
			case event.direction
			when 2 #down
				pbMoveRoute(event, [PBMoveRoute::Down])
			when 4 #left
				pbMoveRoute(event, [PBMoveRoute::Left])
			when 6 #right
				pbMoveRoute(event, [PBMoveRoute::Right])
			when 8 #up
				pbMoveRoute(event, [PBMoveRoute::Up])
			end #case event.direction
		end #$game_temp.puzzleEvents[:Discs].each do |event|
	end #def self.discMoveForward
	
	def self.touchingCornerTrackEvent?(discEvent)
		#print "checking for corner track. this should print twice when touching one" #it didn't work on event 29
		#iterate through rotatable corner track events
		touchingTrack = nil
		$game_temp.puzzleEvents[:CornerTracks].each do |event|
			if discEvent.x == event.x && discEvent.y == event.y
				touchingTrack = event #need to know the event the disc is touching to know the direction
			end
		end #$game_temp.puzzleEvents
		return touchingTrack
	end #def self.touchingCornerTrackEvent?(discEvent)
	
	def self.touchingCatcherEvent?(discEvent)
		#iterate through catcher events
		touchingCatcher = nil
		$game_temp.puzzleEvents[:Catchers].each do |event|
			if discEvent.x == event.x && discEvent.y == event.y
				touchingCatcher = event #need to know the event the disc is touching to know the direction
			end
		end #$game_temp.puzzleEvents
		return touchingCatcher
	end #def self.touchingCatcherEvent?(discEvent)
	
	def self.touchingStraightTrackEvent?(discEvent)
		touchingTrack = nil
		#iterate through rotatable straight track events
		$game_temp.puzzleEvents[:StraightTracks].each do |event|
			if discEvent.x == event.x && discEvent.y == event.y
				touchingTrack = event #need to know the event the disc is touching to know the direction
			end
		end #$game_temp.puzzleEvents
		return touchingTrack
	end #def self.touchingStraightTrackEvent?(discEvent)
	
	def self.touchingRampEvent?(discEvent)
		#iterate through togglable ramp events
		touchingRamp = nil
		#iterate through rotatable straight track events
		$game_temp.puzzleEvents[:Ramps].each do |event|
			if discEvent.x == event.x && discEvent.y == event.y
				touchingRamp = event #need to know the event the disc is touching to know the direction
			end
		end #$game_temp.puzzleEvents
		return touchingRamp
	end #def self.touchingRampEvent?(discEvent)
	
	def self.touchingLauncherEvent?(discEvent)
		#iterate through rotatable corner track events
		touchingLauncher = nil
		$game_temp.puzzleEvents[:Launchers_Rotatable].each do |launcherEvent|
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
		end #$game_temp.puzzleEvents
		$game_temp.puzzleEvents[:Launchers_Stationary].each do |launcherEvent|
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
		end #$game_temp.puzzleEvents

		return touchingLauncher
	end #def self.touchingLauncherEvent?(discEvent)
	
	def self.updateRollingAnimation
		$game_temp.puzzleEvents[:Discs].each do |event|
			next if !event.discRolling
			
			next if @frameWaitCounter < FRAMES_TO_WAIT_BETWEEN_ROLLING_PATTERNS
			next if event.direction == 2 || event.direction == 8 #if facing up or down, no animation needed
			if event.pattern == 0
				event.pattern = 1
			elsif event.pattern == 1
				event.pattern = 2
			elsif event.pattern == 2
				event.pattern = 3
			elsif event.pattern == 3
				#change animation sheet
				if event.character_name == "Rotatona_Disc_Anim1"
					event.character_name = "Rotatona_Disc_Anim2"
				else
					event.character_name = "Rotatona_Disc_Anim1"
				end
				event.pattern = 0
			end #if event.pattern == 0
		end #$game_temp.puzzleEvents[:Discs].each do |event|
		
		@frameWaitCounter = 0 if @frameWaitCounter >= FRAMES_TO_WAIT_BETWEEN_ROLLING_PATTERNS
		@frameWaitCounter += 1
	end #self.updateRollingAnimation
	
	def self.crashRotatona(discEvent, reason="no reason specified")
		discEvent.discRolling = false
		discEvent.discJumping = false
		discEvent.discLandingSpot = []
		Console.echo_warn "disc crashed - #{reason}"
		@needPanCameraToPlayer = true
	end #def self.crashRotatona(discEvent)
	
	def self.rotateStraightTrack(event)
		#get event's current graphic
		#event.character_name
		#event.character_hue
		#event.direction
		#event.pattern
		#PBMoveRoute::Graphic, character_name, hue#, direction#, pattern#,
		case event.direction
		when 2 #down
			newDirection = 4 #left
			#print "currently looking down, turning left"
		when 4 #left
			newDirection = 8 #up
			#print "currently looking left, turning up"
		when 6 #right
			newDirection = 2 #down
			#print "currently looking right, turning down"
		when 8 #up
			newDirection = 6 #right
			#print "currently looking up, turning right"
		end
		pbSEPlay(SE_ROTATE_STRAIGHT_TRACK)
		pbMoveRoute(event, [
			PBMoveRoute::DirectionFixOff,
			PBMoveRoute::Graphic, event.character_name, event.character_hue, event.direction, 1,
			PBMoveRoute::Wait, 2,
			PBMoveRoute::DirectionFixOn,
			PBMoveRoute::Graphic, event.character_name, event.character_hue, newDirection, 0
		])
	end #def self.rotateStraightTrack

	def self.switchRamp(event)
		#get event's current graphic
		#event.character_name
		#event.character_hue
		#event.direction
		#event.pattern
		#PBMoveRoute::Graphic, character_name, hue#, direction#, pattern#,
		case event.direction
		when 2 #down
			newDirection = 8 #up
			#print "currently looking down, turning up"
		when 4 #left
			newDirection = 6 #right
			#print "currently looking left, turning right"
		when 6 #right
			newDirection = 4 #left
			#print "currently looking right, turning left"
		when 8 #up
			newDirection = 2 #down
			#print "currently looking up, turning down"
		end
		pbSEPlay(SE_SWITCH_RAMP)
		pbMoveRoute(event, [
			PBMoveRoute::DirectionFixOff,
			PBMoveRoute::Graphic, event.character_name, event.character_hue, event.direction, 1,
			PBMoveRoute::Wait, 2,
			PBMoveRoute::DirectionFixOn,
			PBMoveRoute::Graphic, event.character_name, event.character_hue, newDirection, 0
		])
	end #def self.switchRamp(event)

	def self.rotateCornerTrack(event,directionString)
		#get event's current graphic
		#event.character_name
		#event.character_hue
		#event.direction
		#event.pattern
		#PBMoveRoute::Graphic, character_name, hue#, direction#, pattern#,
		if directionString == "right90"
			case event.direction
			when 2 #down
				newDirection = 4 #left
				#print "currently looking down, turning to face left"
			when 4 #left
				newDirection = 8 #up
				#print "currently looking left, turning to face up"
			when 6 #right
				newDirection = 2 #down
				#print "currently looking right, turning to face down"
			when 8 #up
				newDirection = 6 #right
				#print "currently looking up, turning to face right"
			end
			pbSEPlay(SE_ROTATE_CORNER_TRACK)
			pbMoveRoute(event, [
				PBMoveRoute::DirectionFixOff,
				PBMoveRoute::Graphic, event.character_name, event.character_hue, event.direction, 1,
				PBMoveRoute::Wait, 2,
				PBMoveRoute::DirectionFixOn,
				PBMoveRoute::Graphic, event.character_name, event.character_hue, newDirection, 0
			])
		else #directionString is "left90"
			case event.direction
			when 2 #down
				newDirection = 6 #right
				#print "currently looking down, turning to face right"
			when 4 #left
				newDirection = 2 #down
				#print "currently looking left, turning to face down"
			when 6 #right
				newDirection = 8 #up
				#print "currently looking right, turning to face up"
			when 8 #up
				newDirection = 4 #left
				#print "currently looking up, turning to face left"
			end
			pbSEPlay(SE_ROTATE_CORNER_TRACK)
			pbMoveRoute(event, [
				PBMoveRoute::DirectionFixOff,
				PBMoveRoute::Graphic, event.character_name, event.character_hue, event.direction, 2,
				PBMoveRoute::Wait, 2,
				PBMoveRoute::DirectionFixOn,
				PBMoveRoute::Graphic, event.character_name, event.character_hue, newDirection, 0
			])
		end #if directionString == "right90"
	end #def self.rotateCornerTrack(event,dirString)

	def self.rotateLauncher(event,directionString)
		#get event's current graphic
		#event.character_name
		#event.character_hue
		#event.direction
		#event.pattern
		#PBMoveRoute::Graphic, character_name, hue#, direction#, pattern#,
		if directionString == "right90"
			case event.direction
			when 2 #down
				newDirection = 4 #left
				#print "currently looking down, turning to face left"
			when 4 #left
				newDirection = 8 #up
				#print "currently looking left, turning to face up"
			when 6 #right
				newDirection = 2 #down
				#print "currently looking right, turning to face down"
			when 8 #up
				newDirection = 6 #right
				#print "currently looking up, turning to face right"
			end
			
			#this event has issues depending on which direction you interact with it from
			#how is there a direction fix issue?
			
			pbSEPlay(SE_ROTATE_LAUNCHER)
			#rotate launcher
			pbMoveRoute(event, [
				#PBMoveRoute::DirectionFixOff,
				PBMoveRoute::Graphic, event.character_name, event.character_hue, event.direction, 1,
				PBMoveRoute::Wait, 2,
				#PBMoveRoute::DirectionFixOn,
				PBMoveRoute::Graphic, event.character_name, event.character_hue, newDirection, 0
			])
			#rotate launcher's overlay
			overlay = event.associatedOverlay
			pbMoveRoute(overlay, [
				PBMoveRoute::Graphic, overlay.character_name, overlay.character_hue, overlay.direction, 1,
				PBMoveRoute::Wait, 2,
				PBMoveRoute::Graphic, overlay.character_name, overlay.character_hue, newDirection, 0
			])
			
			self.rotateDockedDisc(event.discThisLauncherHasDocked, newDirection) if !event.discThisLauncherHasDocked.nil?
		else #directionString is "left90"
			case event.direction
			when 2 #down
				newDirection = 6 #right
				#print "currently looking down, turning to face right"
			when 4 #left
				newDirection = 2 #down
				#print "currently looking left, turning to face down"
			when 6 #right
				newDirection = 8 #up
				#print "currently looking right, turning to face up"
			when 8 #up
				newDirection = 4 #left
				#print "currently looking up, turning to face left"
			end
			pbSEPlay(SE_ROTATE_LAUNCHER)
			pbMoveRoute(event, [
				#PBMoveRoute::DirectionFixOff,
				PBMoveRoute::Graphic, event.character_name, event.character_hue, event.direction, 2,
				PBMoveRoute::Wait, 2,
				#PBMoveRoute::DirectionFixOn,
				PBMoveRoute::Graphic, event.character_name, event.character_hue, newDirection, 0
			])
			#rotate launcher's overlay
			overlay = event.associatedOverlay
			pbMoveRoute(overlay, [
				PBMoveRoute::Graphic, overlay.character_name, overlay.character_hue, overlay.direction, 2,
				PBMoveRoute::Wait, 2,
				PBMoveRoute::Graphic, overlay.character_name, overlay.character_hue, newDirection, 0
			])
			self.rotateDockedDisc(event.discThisLauncherHasDocked, newDirection) if !event.discThisLauncherHasDocked.nil?
		end #if directionString == "right90"
	end #def self.rotateLauncher(event,directionString)

	def self.rotateDockedDisc(discEvent, newDirection)
		transitionPattern = nil
		
		case discEvent.direction
		when 2 #facing down
			transitionPattern = 3 if newDirection == 4 #turning left
			transitionPattern = 0 if newDirection == 6 #turning right
		when 4 #facing left
			transitionPattern = 3 if newDirection == 2 #turning down
			transitionPattern = 0 if newDirection == 8 #turning up
		when 6 #facing right
			transitionPattern = 0 if newDirection == 2 #turning down
			transitionPattern = 3 if newDirection == 8 #turning up
		when 8 #facing up
			transitionPattern = 0 if newDirection == 4 #turning left
			transitionPattern = 3 if newDirection == 6 #turning right
		end
		
		pbMoveRoute(discEvent, [
			PBMoveRoute::Graphic, discEvent.character_name, discEvent.character_hue, 8, transitionPattern,
			PBMoveRoute::Wait, 2,
			PBMoveRoute::Graphic, discEvent.character_name, discEvent.character_hue, newDirection, 1
		])

	end #def self.rotateDockedDisc(discEvent, newDirection)

end #class RotatonaPuzzle

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
	RotatonaPuzzle.cameraLogic
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
	####################next if $game_map.map_id == _old_map_id
	RotatonaPuzzle.getPuzzleEvents
  }
)

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

#logic to do:
#when starting disc rolling, move player off the track (if stepping on terrain tag)
#disc is always on top of player when launched; might need to move player farther away from track
#make launcher overlays always face the same direction as the associated launcher when identifying puzzle pieces
#When a Rota crashes, The screen should go black and the rota should reset back to its last launcher as the camera shifts back to the player
#Upon reentry to the room, the puzzle should reset entirely unless the puzzle has already been fully completed. At which point it shouldn’t reset at all; all events should keep their current position and states when reloading the game; only reset getPuzzleEvents and reset positions when leaving and re-entering the map, including discs "pbMoveRoute(event, [PBMoveRoute::AlwaysOnTopOff])" if docked in a catcher. I need to move puzzle pieces from $game_temp to something that saves with the save file
#resetting rota when it crashes:
#A Rota only resets itself, not other Rotas or puzzle pieces. The entire puzzle should reset itself when exiting the room unless it has already been fully solved
#if collide with disc, crash any rolling disc, so if one is in a catcher and the other crashes into it, the caught one or docked one (launcher) does not break

#bugs
#if launching rota at the bottom launcher, the top launcher looks upward