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


class Game_Temp
  attr_accessor :puzzleEvents
end

class Game_Event
  attr_accessor :associatedLauncher
  attr_accessor :associatedOverlay
  attr_accessor :launcherThisDiscIsDockedIn
  attr_accessor :discThisLauncherHasDocked
end

class RotatonaPuzzle
	SE_ROTATE_STRAIGHT_TRACK = "Cut"
	SE_SWITCH_RAMP = "Cut"
	SE_ROTATE_CORNER_TRACK = "Cut"
	SE_ROTATE_LAUNCHER = "Cut"

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
	
	def self.checkForRotatonaCollisions
		#Console.echo_warn "this is a parallel process - #{rand(100)}"
	end #self.checkForRotatonaCollisions
	
	def self.crashRotatona(rotatonaNumber)
		#check common event Temple_Right_Crash_Rotatona1
		print "crash"
	end #def self.crashRotatona(rotatonaNumber)
	
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
})

EventHandlers.add(:on_enter_map, :rotatona_puzzle_get_puzzle_pieces_when_enter_map,
  proc { |_old_map_id|
	#skip this check if not on Canyon Temple Left and Canyon Temple Right maps
	next if $game_map.map_id != 59 && $game_map.map_id != 120
	RotatonaPuzzle.getPuzzleEvents
  }
)

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