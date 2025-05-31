#=============================================================================
# Rototona Puzzle
#=============================================================================
def self.initialize
	#when entering the map with the puzzle
	self.getPuzzleEvents
	#self.resetRototonas #might only be necessary for debug purposes
end #self.initialize

def self.getPuzzleEvents
	#identify all the events on the map which correspond with the puzzle
	puzzleEvents = {
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
      puzzleEvents[:Rototona1] = event if event.name == "Rototona1"
	  puzzleEvents[:Rototona2] = event if event.name == "Rototona2"
	  puzzleEvents[:Launcher1] = event if event.name == "Launcher1"
	  puzzleEvents[:Launcher2] = event if event.name == "Launcher2"
	  puzzleEvents[:Catcher1] = event if event.name == "Catcher1"
	  puzzleEvents[:Catcher2] = event if event.name == "Catcher2"
	  puzzleEvents[:Barriers].push(event) if event.name == "Barrier"
	  puzzleEvents[:Ramps].push(event) if event.name == "Ramp"
	  puzzleEvents[:StraightTracks].push(event) if event.name == "StraightTrack"
	  puzzleEvents[:CornerTracks].push(event) if event.name == "CornerTrack"
    end
end #def self.getPuzzleEvents

def self.resetRototonas
	
end #def self.resetRototonas