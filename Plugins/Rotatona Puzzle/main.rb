#=============================================================================
# Rotatona Puzzle
#=============================================================================
class Game_Temp
  attr_accessor :puzzleEvents
end

class RotatonaPuzzle
	def self.getPuzzleEvents
		#identify all the events on the map which correspond with the puzzle
		print "identifying puzzle pieces on the map"
		$game_temp.puzzleEvents = {
			:Rotatona1      => nil,
			:Rotatona2      => nil,
			:Launcher1      => nil,
			:Launcher2      => nil,
			:Catcher1       => nil,
			:Catcher2       => nil,
			:Barriers       => [],
			:Ramps          => [],
			:StraightTracks => [],
			:CornerTracks   => []
		}
		$game_map.events.each_value do |event|
			$game_temp.puzzleEvents[:Rotatona1] = event if event.name.match(/RotaPuzzle_Rotatona1/i)
			$game_temp.puzzleEvents[:Rotatona2] = event if event.name.match(/RotaPuzzle_Rotatona2/i)
			$game_temp.puzzleEvents[:Launcher1] = event if event.name.match(/RotaPuzzle_Launcher1/i)
			$game_temp.puzzleEvents[:Launcher2] = event if event.name.match(/RotaPuzzle_Launcher2/i)
			$game_temp.puzzleEvents[:Catcher1] = event if event.name.match(/RotaPuzzle_Catcher1/i)
			$game_temp.puzzleEvents[:Catcher2] = event if event.name.match(/RotaPuzzle_Catcher2/i)
			$game_temp.puzzleEvents[:Barriers].push(event) if event.name.match(/RotaPuzzle_Barrier/i)
			$game_temp.puzzleEvents[:Ramps].push(event) if event.name.match(/RotaPuzzle_Ramp/i)
			$game_temp.puzzleEvents[:StraightTracks].push(event) if event.name.match(/RotaPuzzle_StraightTrack/i)
			$game_temp.puzzleEvents[:CornerTracks].push(event) if event.name.match(/RotaPuzzle_CornerTrack/i)
		end
	end #def self.getPuzzleEvents

	def self.playerInteract(event)
		#events are passed in as GameData
		if event == $game_temp.puzzleEvents[:Rotatona1]
			#print "this is rota1"
			#option to launch if docked
			rota1LaunchChoice = pbConfirmMessage("Launch the disc?")
			print "launching disc from launcher 1" if rota1LaunchChoice
			
		elsif event == $game_temp.puzzleEvents[:Rotatona2]
			#print "this is rota2"
			#option to launch if docked
			rota2LaunchChoice = pbConfirmMessage("Launch the disc?")
			print "launching disc from launcher 2" if rota2LaunchChoice
			
		elsif event == $game_temp.puzzleEvents[:Launcher1]
			#print "this is launcher1"
			#option to turn launcher 90 degrees
			choices = [
				_INTL("Turn Left"), #0
				_INTL("Turn Right"), #1
				_INTL("Nevermind") #2 or -1
			]
			launcher1Choice = pbMessage(_INTL("There are arrow buttons here."), choices, choices.length)
			case launcher1Choice
			when 0
				print "turning launcher1 left"
			when 1
				print "turning launcher1 right"
			end
			
		elsif event == $game_temp.puzzleEvents[:Launcher2]
			#print "this is launcher2"
			#option to turn launcher 90 degrees
			choices = [
				_INTL("Turn Left"), #0
				_INTL("Turn Right"), #1
				_INTL("Nevermind") #2 or -1
			]
			launcher2Choice = pbMessage(_INTL("There are arrow buttons here."), choices, choices.length)
			case launcher2Choice
			when 0
				print "turning launcher2 left"
			when 1
				print "turning launcher2 right"
			end
			
		elsif event == $game_temp.puzzleEvents[:Catcher1]
			#print "this is catcher1"
			#maybe some text about how the rota would seem to fit perfectly in here
			pbMessage(_INTL("A large disc looks like it would fit perfectly in here."))
			
		elsif event == $game_temp.puzzleEvents[:Catcher2]
			#print "this is catcher2"
			#maybe some text about how the rota would seem to fit perfectly in here
			pbMessage(_INTL("A large disc looks like it would fit perfectly in here."))
			
		elsif $game_temp.puzzleEvents[:Barriers].include?(event)
			#print "this is a barrier"
			#nothing, this probably doesn't need to be an elsif statement
			
		elsif $game_temp.puzzleEvents[:Ramps].include?(event)
			#print "this is a ramp"
			#option to switch 180 degrees
			rampChoice = pbConfirmMessage("There's a switch here. Press it?")
			print "switching ramp 180 degrees" if rampChoice
			
		elsif $game_temp.puzzleEvents[:StraightTracks].include?(event)
			#print "this is a straight track"
			#option to turn track 90 degrees
			straightTrackChoice = pbConfirmMessage("There's a switch here. Press it?")
			print "turning straight track 90 degrees" if straightTrackChoice
			
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
				print "turning corner track left"
			when 1
				print "turning corner track right"
			end
		end #if event == $game_temp.puzzleEvents[:Rotatona1]
		
	end #def self.playerInteract

	def self.resetRotatonas
		
	end #def self.resetRotatonas
	
	def self.checkForRotatonaCollisions
		#Console.echo_warn "this is a parallel process - #{rand(100)}"
	end #self.checkForRotatonaCollisions
	
	def self.crashRotatona(rotatonaNumber)
		#check common event Temple_Right_Crash_Rotatona1
	end #def self.crashRotatona(rotatonaNumber)
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