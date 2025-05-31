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

	def self.interact
		#print "interacting"
		print "Rotatona1 events are #{$game_temp.puzzleEvents[:Rotatona1]}"
		print "Rotatona2 events are #{$game_temp.puzzleEvents[:Rotatona2]}"
		print "Launcher1 events are #{$game_temp.puzzleEvents[:Launcher1]}"
		print "Launcher2 events are #{$game_temp.puzzleEvents[:Launcher2]}"
		print "Catcher1 events are #{$game_temp.puzzleEvents[:Catcher1]}"
		print "Catcher2 events are #{$game_temp.puzzleEvents[:Catcher2]}"
		print "Barrier events are #{$game_temp.puzzleEvents[:Barriers]}"
		print "Ramps events are #{$game_temp.puzzleEvents[:Ramps]}"
		print "StraightTracks events are #{$game_temp.puzzleEvents[:StraightTracks]}"
		print "CornerTracks events are #{$game_temp.puzzleEvents[:CornerTracks]}"
	end #def self.interact

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
	RotatonaPuzzle.interact if facingEvent && facingEvent.name.match(/RotaPuzzle/i)
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