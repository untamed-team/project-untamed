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
#	RotaPuzzle_Barrier
#	RotaPuzzle_Ramp
#	RotaPuzzle_StraightTrack
#	RotaPuzzle_CornerTrack
#2. All launchers' associated overlays must be on the same Y as the associated launcher, and the overlay must be 1 to the right of the launcher (e.g. launcher x is 10 and y is 20, associated overlay x is 11 and y is 20)
#3. Launcher overlays must have "Always on Top" checked
#4. Launcher overlays must have an event number higher than all Rotatona discs
#5. Rotatona discs must have "Always on Top" checked
#6. Launcher events must be 3x3 ( e.g. NAME,size(3,3) )
#7. Launcher overlay events must be 1x3 ( e.g. NAME,size(1,3) )
#8. Only launchers which rotate or are stationary but NOT facing upward need an associated launcher overlay
#9. Rotatona disc events must be placed 1 to the right and 1 up from the launcher you want it to start in
#10. Do not use terrain tags 19 through 29 for anything. Do not change the terrain tags on any of the tiles in the temple tileset

class Game_Temp
  attr_accessor :puzzleEvents
end

class Game_Event
  attr_accessor :associatedLauncher
  attr_accessor :associatedOverlay
  attr_accessor :launcherThisDiscIsDockedIn
  attr_accessor :discThisLauncherHasDocked
  attr_accessor :discRolling
  attr_accessor :discTouchingTile
  attr_accessor :discTurningDirection
end

class RotatonaPuzzle
	SE_ROTATE_STRAIGHT_TRACK = "Cut"
	SE_SWITCH_RAMP = "Cut"
	SE_ROTATE_CORNER_TRACK = "Cut"
	SE_ROTATE_LAUNCHER = "Cut"
	FRAMES_TO_WAIT_BETWEEN_ROLLING_PATTERNS = 3 #default is 3
	FRAMES_FOR_ROLLING_DISC_TURNING_ANIMATION = 0

	def self.getPuzzleEvents
		#identify all the events on the map which correspond with the puzzle
		#print "identifying puzzle pieces on the map"
		$game_temp.puzzleEvents = {
			:Discs	 			  		  => [],
			:Launchers_Rotatable  		  => [],
			:Launchers_Overlay_Rotatable  => [],
			:Launchers_Stationary 		  => [],
			:Launchers_Overlay_Stationary => [],
			:Catchers             		  => [],
			:Barriers       	  		  => [],
			:Ramps           	  		  => [],
			:StraightTracks       	 	  => [],
			:CornerTracks  		  	  	  => []
		}
		$game_map.events.each_value do |event|
			#set all variables to nil
			event.associatedLauncher = nil
			event.associatedOverlay = nil
			event.launcherThisDiscIsDockedIn = nil
			event.discThisLauncherHasDocked = nil
			################################event.discRolling = nil
			event.discRolling = true
			event.discTouchingTile = []
			event.discTurningDirection = nil
			@frameWaitCounter = 0
		
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
			$game_temp.puzzleEvents[:Launchers_Stationary].push(event) if event.name.match(/RotaPuzzle_Launcher_Stationary/i)
			$game_temp.puzzleEvents[:Launchers_Overlay_Stationary].push(event) if event.name.match(/RotaPuzzle_Launcher_Overlay_Stationary/i)
			$game_temp.puzzleEvents[:Catchers].push(event) if event.name.match(/RotaPuzzle_Catcher/i)
			$game_temp.puzzleEvents[:Barriers].push(event) if event.name.match(/RotaPuzzle_Barrier/i)
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
		
		#self.findAssociatedOverlayForLauncher(launcherEvent)
	end #def self.getPuzzleEvents

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
					#click SE ####################################################################
					self.launchRotatonaDisc(event, event.discThisLauncherHasDocked)
				else
					#click SE ####################################################################
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
					#click SE ####################################################################
					self.launchRotatonaDisc(event.associatedLauncher, event.associatedLauncher.discThisLauncherHasDocked)
				else
					#click SE ####################################################################
					choice = pbMessage(_INTL("Nothing happened."))
				end
			end
		###################################################################	
		elsif $game_temp.puzzleEvents[:Launchers_Stationary].include?(event)
			if !event.discThisLauncherHasDocked.nil?
				#if disc is docked
				choice = pbConfirmMessage(_INTL("There's a square button here. Press it?"))
				#click SE ####################################################################
				self.launchRotatonaDisc(event, event.discThisLauncherHasDocked) if choice
			else
				#if disc not docked
				choice = pbConfirmMessage(_INTL("There's a square button here. Press it?"))
				#click SE ####################################################################
				pbMessage(_INTL("Nothing happened.")) if choice
			end
			
		###################################################################	
		elsif $game_temp.puzzleEvents[:Launchers_Overlay_Stationary].include?(event)
			if !event.associatedLauncher.discThisLauncherHasDocked.nil? #discDocked
				#if disc is docked
				choice = pbConfirmMessage(_INTL("There's a square button here. Press it?"))
				#click SE ####################################################################
				self.launchRotatonaDisc(event.associatedLauncher, event.associatedLauncher.discThisLauncherHasDocked) if choice
			else
				#if disc not docked
				choice = pbConfirmMessage(_INTL("There's a square button here. Press it?"))
				#click SE ####################################################################
				pbMessage(_INTL("Nothing happened.")) if choice
			end
			
		###################################################################
		elsif event == $game_temp.puzzleEvents[:Catchers]
			#print "this is catcher2"
			#maybe some text about how the rota would seem to fit perfectly in here
			pbMessage(_INTL("A large disc looks like it would fit perfectly in here."))
		###################################################################
		elsif $game_temp.puzzleEvents[:Barriers].include?(event)
			#print "this is a barrier"
			#nothing, this probably doesn't need to be an elsif statement
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

	def self.launchRotatonaDisc(launcherEvent, discEvent)
		pbMessage(_INTL("launching disc event #{discEvent.id} from launcher event #{launcherEvent.id}"))
	end #def self.launchRotatonaDisc

	def self.resetRotatonas
		
	end #def self.resetRotatonas
	
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
		return turnSpritePattern
	end #def self.determinePatterForTurning
	
	def self.checkForRotatonaCollisions
		$game_temp.puzzleEvents[:Discs].each do |event|
			next if !event.discRolling
			
			#set the tile the disc is touching if it's different than before (so we can't double dip on the same tile when checking for collisions)
			#this way, a collision check is only done once when the disc touches the tile
			next if event.discTouchingTile == [event.x, event.y]
			event.discTouchingTile = [event.x, event.y] if event.discTouchingTile != [event.x, event.y]
			Console.echo_warn event.discTouchingTile
			
			#we don't want to check for collisions if the disc is currently turning (like when it hits a corner track)
			next if !event.discTurningDirection.nil?
			
			if $game_map.terrain_tag(event.x, event.y).id == :RotatonaPuzzle_Track_Corner1
				#corner going left and down / up and right
				case event.direction
				when 2 #down
					self.crashRotatona(event)
				when 4 #left
					newDirection = 2 #down
					turnSpritePattern = self.determinePatterForTurning(event, newDirection)
					
					#start move route, then turn on discTurningDirection
					pbMoveRoute(event, [
						PBMoveRoute::Graphic, event.character_name, event.character_hue, 8, turnSpritePattern,
						PBMoveRoute::Wait, FRAMES_FOR_ROLLING_DISC_TURNING_ANIMATION,
						PBMoveRoute::Graphic, event.character_name, event.character_hue, newDirection, 1
					], waitComplete = true)
					
					event.discTurningDirection = newDirection
				when 6 #right
					self.crashRotatona(event)
				when 8 #up
					newDirection = 6 #right
					turnSpritePattern = self.determinePatterForTurning(event, newDirection)
					#start move route, then turn on discTurningDirection
					pbMoveRoute(event, [
						PBMoveRoute::Graphic, event.character_name, event.character_hue, 2, turnSpritePattern,
						PBMoveRoute::Wait, FRAMES_FOR_ROLLING_DISC_TURNING_ANIMATION,
						PBMoveRoute::Graphic, event.character_name, event.character_hue, newDirection, 1
					], waitComplete = true)
					
					event.discTurningDirection = newDirection
				end

			elsif $game_map.terrain_tag(event.x, event.y).id == :RotatonaPuzzle_Track_Corner2
				#corner going right and down / up and left
				case event.direction
				when 2 #down
					self.crashRotatona(event)
				when 4 #left
					self.crashRotatona(event)
				when 6 #right
				when 8 #up
				end
			elsif $game_map.terrain_tag(event.x, event.y).id == :RotatonaPuzzle_Track_Corner3
				#corner going down and right / left and up
				case event.direction
				when 2 #down
				when 4 #left
				when 6 #right
					self.crashRotatona(event)
				when 8 #up
					self.crashRotatona(event)
				end
			elsif $game_map.terrain_tag(event.x, event.y).id == :RotatonaPuzzle_Track_Corner4
				#corner going down and left / right and up
				case event.direction
				when 2 #down
				when 4 #left
					self.crashRotatona(event)
				when 6 #right
				when 8 #up
					self.crashRotatona(event)
				end
				
			elsif $game_map.terrain_tag(event.x, event.y).id == :RotatonaPuzzle_Track_Horizontal
				case event.direction
				when 2 #down
					self.crashRotatona(event)
				when 4 #left
				when 6 #right
				when 8 #up
					self.crashRotatona(event)
				end
			elsif $game_map.terrain_tag(event.x, event.y).id == :RotatonaPuzzle_Track_Vertical
				case event.direction
				when 2 #down
				when 4 #left
					self.crashRotatona(event)
				when 6 #right
					self.crashRotatona(event)
				when 8 #up
				end
			elsif $game_map.terrain_tag(event.x, event.y).id == :RotatonaPuzzle_Track_Crossroad
				case event.direction
				when 2 #down
				when 4 #left
				when 6 #right
				when 8 #up
				end
			elsif $game_map.terrain_tag(event.x, event.y).id == :RotatonaPuzzle_Track_DeadEndUp
				#do nothing I guess?
				case event.direction
				when 2 #down
				when 4 #left
				when 6 #right
				when 8 #up
				end
			elsif $game_map.terrain_tag(event.x, event.y).id == :RotatonaPuzzle_Track_DeadEndDown
				case event.direction
				when 2 #down
				when 4 #left
				when 6 #right
				when 8 #up
				end
			elsif $game_map.terrain_tag(event.x, event.y).id == :RotatonaPuzzle_Track_DeadEndLeft
				case event.direction
				when 2 #down
				when 4 #left
				when 6 #right
				when 8 #up
				end
			elsif $game_map.terrain_tag(event.x, event.y).id == :RotatonaPuzzle_Track_DeadEndRight
				case event.direction
				when 2 #down
				when 4 #left
				when 6 #right
				when 8 #up
				end				
			end #if $game_map.terrain_tag(event.x, event.y).id == "RotatonaPuzzle_Track_Corner1"
		end #$game_temp.puzzleEvents[:Discs].each do |event|
	end #self.checkForRotatonaCollisions
	
	def self.checkIfDiscTurning
		$game_temp.puzzleEvents[:Discs].each do |event|
			next if !event.discRolling
			next if event.discTurningDirection.nil?
			
			#stop disc from turning if it's not on a turning sprite
			if event.direction != event.discTurningDirection
				Console.echo_warn "turning"
			else
				Console.echo_warn "done turning"
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
			pbMoveRoute(event, [PBMoveRoute::ChangeSpeed, 4])
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
	end #def self.touchingCornerTrackEvent?(discEvent)
	
	def self.touchingCatcherEvent?(discEvent)
	end #def self.touchingCatcherEvent?(discEvent)
	
	def self.touchingStraightTrackEvent?(discEvent)
	end #def self.touchingStraightTrackEvent?(discEvent)
	
	def self.touchingRampEvent?(discEvent)
	end #def self.touchingRampEvent?(discEvent)
	
	def self.touchingLauncherEvent?(discEvent)
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
	
	def self.crashRotatona(discEvent)
		discEvent.discRolling = false
		Console.echo_warn "disc crashed"
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
	RotatonaPuzzle.playerInteract(facingEvent) if facingEvent && facingEvent.name.match(/RotaPuzzle/i)
})

EventHandlers.add(:on_frame_update, :rotatona_puzzle_logic_listener, proc {
	#skip this check if not on Canyon Temple Left and Canyon Temple Right maps
	next if $game_map.map_id != 59 && $game_map.map_id != 120
	RotatonaPuzzle.checkForRotatonaCollisions
	RotatonaPuzzle.updateRollingAnimation
	RotatonaPuzzle.discMoveForward
	RotatonaPuzzle.checkIfDiscTurning
})

EventHandlers.add(:on_enter_map, :rotatona_puzzle_get_puzzle_pieces_when_enter_map,
  proc { |_old_map_id|
	#skip this check if not on Canyon Temple Left and Canyon Temple Right maps
	next if $game_map.map_id != 59 && $game_map.map_id != 120
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
#if the launcher has rotatona in it, set rotatona direction to same direction as launcher
#if rota touches ramp & rota is facing same direction as ramp, jump
#if rota touches ramp & rota is not facing same direction as ramp, crash
#if rota touches straight & rota facing up or down & straight facing left or right, crash
#if rota touches straight & rota facing left or right & straight facing up or down, crash
#if rota touches corner & rota is facing right & corner is facing up, rota turn up from right
#if rota touches corner & rota is facing right & corner is facing left, rota turn down from right
#if rota touches corner & rota is facing right & corner is facing down or right, crash
#if rota touches corner & rota is facing down & corner is facing up, rota turn left from down
#if rota touches corner & rota is facing down & corner is facing right, rota turn right from down
#if rota touches corner & rota is facing down & corner is facing left or down, crash
#if rota touches corner & rota is facing left & corner is facing down, rota turn down from left
#if rota touches corner & rota is facing left & corner is facing right, rota turn up from left
#if rota touches corner & rota is facing left & corner is facing up or left, crash
#if rota touches corner & rota is facing up & corner is facing down, rota turn right from up
#if rota touches corner & rota is facing up & corner is facing left, rota turn left from up
#if rota touches corner & rota is facing up & corner is facing up or right, crash
#if rota touches catcher, success sound
#if rota touches barrier, crash