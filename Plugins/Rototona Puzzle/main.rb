#=============================================================================
# Rototona Puzzle
#=============================================================================
class Game_Temp
  attr_writer :puzzleEvents
end

class RototonaPuzzle
	def initialize
		#when entering the map with the puzzle
		getPuzzleEvents
		#self.resetRototonas #might only be necessary for debug purposes
	end #self.initialize

	def getPuzzleEvents
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
			$game_temp.puzzleEvents[:Rototona1] = event if event.name == "RotoPuzzle_Rototona1.shadowless"
			$game_temp.puzzleEvents[:Rototona2] = event if event.name == "RotoPuzzle_Rototona2.shadowless"
			$game_temp.puzzleEvents[:Launcher1] = event if event.name == "RotoPuzzle_Launcher1.shadowless"
			$game_temp.puzzleEvents[:Launcher2] = event if event.name == "RotoPuzzle_Launcher2.shadowless"
			$game_temp.puzzleEvents[:Catcher1] = event if event.name == "RotoPuzzle_Catcher1.shadowless"
			$game_temp.puzzleEvents[:Catcher2] = event if event.name == "RotoPuzzle_Catcher2.shadowless"
			$game_temp.puzzleEvents[:Barriers].push(event) if event.name == "RotoPuzzle_Barrier.shadowless"
			$game_temp.puzzleEvents[:Ramps].push(event) if event.name == "RotoPuzzle_Ramp.shadowless"
			$game_temp.puzzleEvents[:StraightTracks].push(event) if event.name == "RotoPuzzle_StraightTrack.shadowless"
			$game_temp.puzzleEvents[:CornerTracks].push(event) if event.name == "RotoPuzzle_CornerTrack.shadowless"
		end
	end #def self.getPuzzleEvents

	def interact
		print "interacting"
		print "Barrier events are #{$game_temp.puzzleEvents[:Barriers]}"
	end #def self.interact

	def resetRototonas
		
	end #def self.resetRototonas
end #class RototonaPuzzle

#on_player_interact with puzzle event
EventHandlers.add(:on_player_interact, :interact_with_puzzle_event, proc {
	#skip this check if not on Canyon Temple Left and Canyon Temple Right maps
	next if $game_map.map_id != 59 && $game_map.map_id != 120
	facingEvent = $game_player.pbFacingEvent
	RototonaPuzzle.interact if facingEvent && facingEvent.name.match(/RotoPuzzle/i)
})