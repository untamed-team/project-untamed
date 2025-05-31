#=============================================================================
# Rototona Puzzle
#=============================================================================
class Game_Temp
  attr_accessor :puzzleEvents
end

class RototonaPuzzle
	def self.getPuzzleEvents
		#identify all the events on the map which correspond with the puzzle
		print "identifying puzzle pieces on the map"
		$game_temp.puzzleEvents = {
			:Rototona1      => nil,
			:Rototona2      => nil,
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
			$game_temp.puzzleEvents[:Rototona1] = event if event.name.match(/RotoPuzzle_Rototona1/i)
			$game_temp.puzzleEvents[:Rototona2] = event if event.name.match(/RotoPuzzle_Rototona2/i)
			$game_temp.puzzleEvents[:Launcher1] = event if event.name.match(/RotoPuzzle_Launcher1/i)
			$game_temp.puzzleEvents[:Launcher2] = event if event.name.match(/RotoPuzzle_Launcher2/i)
			$game_temp.puzzleEvents[:Catcher1] = event if event.name.match(/RotoPuzzle_Catcher1/i)
			$game_temp.puzzleEvents[:Catcher2] = event if event.name.match(/RotoPuzzle_Catcher2/i)
			$game_temp.puzzleEvents[:Barriers].push(event) if event.name.match(/RotoPuzzle_Barrier/i)
			$game_temp.puzzleEvents[:Ramps].push(event) if event.name.match(/RotoPuzzle_Ramp/i)
			$game_temp.puzzleEvents[:StraightTracks].push(event) if event.name.match(/RotoPuzzle_StraightTrack/i)
			$game_temp.puzzleEvents[:CornerTracks].push(event) if event.name.match(/RotoPuzzle_CornerTrack/i)
		end
	end #def self.getPuzzleEvents

	def self.interact
		#print "interacting"
		print "Rototona1 events are #{$game_temp.puzzleEvents[:Rototona1]}"
		print "Rototona2 events are #{$game_temp.puzzleEvents[:Rototona2]}"
		print "Launcher1 events are #{$game_temp.puzzleEvents[:Launcher1]}"
		print "Launcher2 events are #{$game_temp.puzzleEvents[:Launcher2]}"
		print "Catcher1 events are #{$game_temp.puzzleEvents[:Catcher1]}"
		print "Catcher2 events are #{$game_temp.puzzleEvents[:Catcher2]}"
		print "Barrier events are #{$game_temp.puzzleEvents[:Barriers]}"
		print "Ramps events are #{$game_temp.puzzleEvents[:Ramps]}"
		print "StraightTracks events are #{$game_temp.puzzleEvents[:StraightTracks]}"
		print "CornerTracks events are #{$game_temp.puzzleEvents[:CornerTracks]}"
	end #def self.interact

	def self.resetRototonas
		
	end #def self.resetRototonas
	
	def self.checkForRototonaCollisions
		#Console.echo_warn "this is a parallel process - #{rand(100)}"
	end #self.checkForRototonaCollisions
end #class RototonaPuzzle

#on_player_interact with puzzle event
EventHandlers.add(:on_player_interact, :interact_with_puzzle_event, proc {
	#skip this check if not on Canyon Temple Left and Canyon Temple Right maps
	next if $game_map.map_id != 59 && $game_map.map_id != 120
	facingEvent = $game_player.pbFacingEvent
	RototonaPuzzle.interact if facingEvent && facingEvent.name.match(/RotoPuzzle/i)
})

EventHandlers.add(:on_frame_update, :rototona_puzzle_logic_listener, proc {
	#skip this check if not on Canyon Temple Left and Canyon Temple Right maps
	next if $game_map.map_id != 59 && $game_map.map_id != 120
	RototonaPuzzle.checkForRototonaCollisions
})
