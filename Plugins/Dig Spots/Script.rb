#summary
#

#To do

class DigSpots
  def initialize
	#go through all events on the current map and only do something if an event on the map is named "DigSpot"
	$game_map.events.each_value do |event|
      next if event.name != "DigSpot"
      print "found a DigSpot"
    end
  end #def generateDigSpotsOnMap
  
end #class DigSpots

EventHandlers.add(:on_enter_map, :spawn_dig_spots,
  proc { |_old_map_id|

	#if oldMapID and currentMapID match, the game was just loaded. Skip generating dig spots
	next if _old_map_id == $game_map.map_id
	DigSpots.new
  }
)