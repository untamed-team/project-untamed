#####################################################################
#
#                  Voltseon's A-Star Pathfinding
#                 Made for Pokémon Essentials v19
#
#               Credit: Voltseon and Golisopod User
#
#####################################################################
#
# How A-Star (A*) works:
#
# There's 3 values given to every tile that is being calculated.
# G-Cost = Distance between this tile & starting point.
# H-Cost = Distance between this tile & destination point.
# F-Cost = The sum of G-Cost and H-Cost.
#
# First there's an object made using the event's location (current)
# Until current reaches its destination it calculates the costs for the tiles surrounding it.
# It then stores these in tile objects. These are used to calculate which path is the best route.
# The neighbour is stored and saves the tile that found it as its parent.
# It moves the tile to the tile that has the smallest F-Cost.
# If the tile is impassable it skips that tile.
#
# If there are multiple tiles with the same F-Cost, it should look for the minimum H-Cost.
# If there are multiple tiles with the same F-Cost and H-Cost it should look for the maximum G-Cost. (This should never happen)
#
# If it is stuck (surrounded by impassable tiles) it should stop the calculation.
# It adds every movement calculation to a variable (moveroute)
#
# There's also two arrays that store tiles their data
# Open Tiles = All the tiles that are yet to be calculated
#              But they are still close to the path
# Closed Tiles = All the tiles that benefit the move route
#
# When the tile has reached the goal it stops the loop
# And starts the moveroute for the event.
#
#####################################################################

# Banned Terrain Tags
TERRAIN_BLOCKS = [GameData::TerrainTag.get(:Ice), GameData::TerrainTag.get(:Ledge)]

# Used for storing all the map's impassable tiles
$impassable_tiles = []

# A tile contains the following data:
# x and y position
# g- h- and f-costs
# A parent which is also a tile
class PathfindingTile
  attr_writer :x
  attr_writer :y
  attr_writer :g_cost
  attr_writer :h_cost
  attr_writer :f_cost
  attr_writer :parent

  def initialize(x, y)
    @x = x
    @y = y
    @g_cost = self.g_cost
    @h_cost = self.h_cost
    @f_cost = self.f_cost
    @parent = self.parent
  end

  def x; return @x; end
  def y; return @y; end

  def g_cost; return @g_cost; end

  def h_cost; return @h_cost; end

  def f_cost
    @f_cost = @g_cost + @h_cost if @g_cost && @h_cost
    return @f_cost
  end

  def parent; return @parent; end
end

# Calls whenever you change maps
# Updates the array with all the tiles that are passable
EventHandlers.add(:on_enter_map, :update_passable_tiles,
  proc { |_sender, e|
    update_passable_tiles(true)
  }
)

# Moves the designated event to the defined coordinates
# Usage: move_to_location(EventID,X,Y,WaitForComplete)
# Example: move_to_location(20,77,52,true)
def move_to_location(event = nil, desired_x = 0, desired_y = 0, wait_for_completion = false)
  # Get the event from the specified event ID if specified
  event = get_event_from_id(event) if event.is_a?(Integer)
  # Make event the current one if none is specified
  event = pbMapInterpreter.get_character(0) if event.nil? && pbMapInterpreter
  # Return if the event is already at the desired location
  return if !event || (event.x == desired_x && event.y == desired_y)
  # Calculates the pathfinding
  if event.through
    moveroute = calc_path_through(event,[desired_x, desired_y])
  else
    moveroute = calc_path(event,[desired_x, desired_y])
  end
  # Performs the moveroute
  pbAStarMoveRoute(event,moveroute,wait_for_completion)
end

# Moves the designated event to the defined event
# Usage: move_to_event(EventID1,EventID2,WaitForComplete)
# Example: move_to_event(20,34,true)
def move_to_event(event_a = nil, event_b = nil, wait_for_completion = false)
  # Get the event from the specified event ID if specified
  event_a = get_event_from_id(event_a) if event_a.is_a?(Integer)
  event_b = get_event_from_id(event_b) if event_b.is_a?(Integer)
  # Sets a default event if none is specified
  event_a = pbMapInterpreter.get_character(0) if event_a.nil? && pbMapInterpreter
  event_b = pbMapInterpreter.get_character(-1) if event_b.nil? && pbMapInterpreter
  # Return if the event is already at the desired location
  return if (!event_a || !event_b) || (event_a.x == event_b.x && event_a.y == event_b.y)
  # Calculates the pathfinding based on whether through is on
  if event_a.through
    moveroute = calc_path_through(event_a, [event_b.x, event_b.y])
  else
    moveroute = calc_path(event_a, [event_b.x, event_b.y])
  end
  # Performs the moveroute
  pbAStarMoveRoute(event_a, moveroute, wait_for_completion)
end

# Calculates the pathfinding liniar
# event = designated event to move
# destination = an array of the desired location [x,y]
def calc_path_through(event, destination)
  # Array containing the move route
  move_route = []
  # Currently selected tile
  this_tile = PathfindingTile.new(event.x, event.y)
  # Target tile of where to move towards
  destination_tile = PathfindingTile.new(destination[0], destination[1])
  # Loop until the selected tile is at the target
  loop do
    # Move the selection based on whether the
    # x or y value of the target is smaller
    # or bigger than the selected one's.
    if this_tile.x < destination_tile.x
      this_tile.x += 1
    elsif this_tile.x > destination_tile.x
      this_tile.x -= 1
    elsif this_tile.y > destination_tile.y
      this_tile.y -= 1
    elsif this_tile.y < destination_tile.y
      this_tile.y += 1
    end
    # Break the loop if at the location
    break if this_tile.x == destination_tile.x && this_tile.y == destination_tile.y
    # Store the move route needed to move towards the target
    movement = calc_move_route(this_tile, destination_tile)
    # Add movement to the move route
    move_route.push(movement)
  end
  return move_route
end



# Calculates the pathfinding (A*)
# initial = start location
# destination = an array of the desired location [x,y]
def calc_path(event, destination)
  # Updates the array with all the tiles that are passable
  update_passable_tiles
  # Starting point is always on the designated event
  initial_point = [event.x, event.y]
  # The bare minimum distance that needs to be traveled
  distance_needed = calc_dist(initial_point, destination)
  # Array containing the move route
  move_route = []
  # Array containing all the possible movable tiles that have not been checked
  open_tiles = []
  # Array containing the path that's best suited for moving to the destination
  closed_tiles = []
  # Defining tiles
  initial_tile = PathfindingTile.new(initial_point[0], initial_point[1])
  destination_tile = PathfindingTile.new(destination[0], destination[1])
  # Adds the first tile to the open tiles
  open_tiles.push(initial_tile)
  # Loops until every possible tile is checked
  while open_tiles.length > 0
    # Select the first tile
    current = open_tiles[0]
    # Select the tile with the lowest f-cost
    for i in 1...open_tiles.length
      if open_tiles[i].f_cost <= current.f_cost && open_tiles[i].h_cost < current.h_cost
        current = open_tiles[i]
      end
    end
    # Remove the selected tile from open and add to closed
    open_tiles.delete(current)
    closed_tiles.push(current)
    # Save the selected location
    current_location = [current.x, current.y]
    # Stop when the destination is not reachable
    break if $impassable_tiles.any? { |new_tile| destination[0] == new_tile[0] && destination[1] == new_tile[1] }
    # Stop when it has reached its destination
    break if current_location == destination
    # Select a neighbour and save it
    current_neighbours = get_neighbours(current, closed_tiles, open_tiles)
    # Calculate the costs of the selected tile
    calc_tile_costs(current, initial_point, destination)
    # Get data from all 4 neighbours
    for neighbour in current_neighbours
      # Get the selected neighbour's location
      neighbour_location = [neighbour.x, neighbour.y]
      # Get the cost between current and neighbour
      cost_to_neighbour = current.g_cost + calc_dist(current_location, neighbour_location)
      # Set costs of the neighbour
      neighbour.g_cost = cost_to_neighbour
      neighbour.h_cost = calc_dist(neighbour_location, destination)
      # Make the selected tile a parent of the neighbour
      neighbour.parent = current
      # Add neighbour to the open tiles
      open_tiles.push(neighbour)
    end
  end
  # Sort the path (it's reversed at first)
  move_route = calc_sorted_path(closed_tiles)
  return move_route
end

# Sort a reversed path
# closed_tiles = Array containing the path backwards
def calc_sorted_path(closed_tiles)
  # Default values
  move_route = []
  current_checking = closed_tiles[closed_tiles.length-1]
  # Loop until there are no more parents
  loop do
    break if !current_checking.parent
    # Get the inverted move route from last position to its parent
    inverted_move_route = calc_move_route_inverted(current_checking, current_checking.parent)
    # Add the inverted move route to the first position in the
    move_route.insert(0, inverted_move_route)
    # Select the parent of this tile
    current_checking = current_checking.parent
  end
  return move_route
end

# Turns towards the designated event
def look_at_event(event_a,event_b)
  # Get the event from the specified event ID if specified
  event_a = get_event_from_id(event_a) if event_a && event_a != $game_player
  event_b = get_event_from_id(event_b) if event_b && event_b != $game_player
  # Sets a default event if none is specified
  event_a = get_character(0) if !event_a
  event_b = get_character(1) if !event_b
  # Get distance between x values and y values
  distance_x = (event_a.x - event_b.x).abs
  distance_y = (event_a.y - event_b.y).abs
  # Turn the event based on the other event's location (Y-Axis is prioritized if both distances are the same)
  if distance_x <= distance_y
    # Prioritize Y
    if event_a.y<event_b.y; pbMoveRoute(event_a,[PBMoveRoute::TurnDown])
    elsif event_a.y>event_b.y; pbMoveRoute(event_a,[PBMoveRoute::TurnUp])
    elsif event_a.x<event_b.x; pbMoveRoute(event_a,[PBMoveRoute::TurnRight])
    elsif event_a.x>event_b.x; pbMoveRoute(event_a,[PBMoveRoute::TurnLeft])
    end
  else
    # Prioritize X
    if event_a.x<event_b.x; pbMoveRoute(event_a,[PBMoveRoute::TurnRight])
    elsif event_a.x>event_b.x; pbMoveRoute(event_a,[PBMoveRoute::TurnLeft])
    elsif event_a.y<event_b.y; pbMoveRoute(event_a,[PBMoveRoute::TurnDown])
    elsif event_a.y>event_b.y; pbMoveRoute(event_a,[PBMoveRoute::TurnUp])
    end
  end
end

# Turns towards the designated location
def look_at_location(event,x,y)
  # Get the event from the specified event ID if specified
  event = get_event_from_id(event) if event && event != $game_player
  # Sets a default event if none is specified
  event = get_character(0) if !event
  destination = [x, y]
  # Get distance between x values and y values
  distance_x = (event.x - x).abs
  distance_y = (event.y - y).abs
  # Turn the event based on the other event's location (Y-Axis is prioritized if both distances are the same)
  if distance_x <= distance_y
    # Prioritize Y
    if event.y<destination[1]; pbMoveRoute(event,[PBMoveRoute::TurnDown])
    elsif event.y>destination[1]; pbMoveRoute(event,[PBMoveRoute::TurnUp])
    elsif event.x<destination[0]; pbMoveRoute(event,[PBMoveRoute::TurnRight])
    elsif event.x>destination[0]; pbMoveRoute(event,[PBMoveRoute::TurnLeft])
    end
  else
    # Prioritize X
    if event.x<destination[0]; pbMoveRoute(event,[PBMoveRoute::TurnRight])
    elsif event.x>destination[0]; pbMoveRoute(event,[PBMoveRoute::TurnLeft])
    elsif event.y<destination[1]; pbMoveRoute(event,[PBMoveRoute::TurnDown])
    elsif event.y>destination[1]; pbMoveRoute(event,[PBMoveRoute::TurnUp])
    end
  end
end

# Get the neighbours of the selected tile
def get_neighbours(tile, closed_tiles, open_tiles)
  # Array containing all the neighbouring tiles
  neighbours = []
  checking_tiles = [[1,0], [0,1], [-1,0], [0,-1]]
  checking_tiles.each do |new_tile|
    x = new_tile[0]; y = new_tile[1]
    # Checking and storing the new x and y values
    check_x = tile.x + x
    check_y = tile.y + y
    # Checks if the x and y values are valid (not outside the map)
    next if check_x < 0 || check_x >= $game_map.width
    next if check_y < 0 || check_y >= $game_map.height
    # Checks if the tiles are passable
    next if $impassable_tiles.any? { |new_tile| check_x == new_tile[0] && check_y == new_tile[1] }
    # Checks whether tile has already been parsed
    next if closed_tiles.any? { |closed_tile| check_x == closed_tile.x && check_y == closed_tile.y }
    next if open_tiles.any? { |open_tile| check_x == open_tile.x && check_y == open_tile.y }
    # Add the neighbouring tile to the array
    neighbours.push(PathfindingTile.new(check_x, check_y))
  end
  return neighbours
end



# Updates the array with all the tiles that are passable
def update_passable_tiles(full_reset = true)
  # Initialize the impassable tiles array
  $impassable_tiles = [] if !$impassable_tiles
  # Reset the impassable tiles array
  $impassable_tiles.clear
  # Go through all the possible tiles in the map
  for i in 0...$game_map.width
    for j in 0...$game_map.height
      # Checks whether the current tile is impassable or is a blocked terrain tag
      next if $game_map.passable?(i, j, 0)
      next if TERRAIN_BLOCKS.include?($game_map.terrain_tag(i, j))
      # Add current tile to the array
      $impassable_tiles.push([i, j])
    end
  end
  # Add the player's location to the array
  $impassable_tiles.push([$game_player.x, $game_player.y])
  # Add dependent events to impassable tiles
  if $PokemonGlobal && $PokemonGlobal.dependentEvents
    $PokemonGlobal.dependentEvents.each_with_index do |e, i|
      $impassable_tiles.push([e[3], e[4]])
    end
  end
end

# Calculate the needed move route
def calc_move_route(position_a, position_b)
  return PBMoveRoute::Right if position_a.x < position_b.x
  return PBMoveRoute::Left if position_a.x > position_b.x
  return PBMoveRoute::Up if position_a.y > position_b.y
  return PBMoveRoute::Down if position_a.y < position_b.y
end

# Calculate the needed move route but inverted
def calc_move_route_inverted(position_a, position_b)
  return PBMoveRoute::Right if position_a.x > position_b.x
  return PBMoveRoute::Left if position_a.x < position_b.x
  return PBMoveRoute::Up if position_a.y < position_b.y
  return PBMoveRoute::Down if position_a.y > position_b.y
end

# Calculates all the costs of a tile
def calc_tile_costs(tile, start, destination)
  tile.g_cost = calc_dist([tile.x,tile.y],start)
  tile.h_cost = calc_dist([tile.x,tile.y],destination)
  tile.f_cost = tile.g_cost + tile.h_cost
end

# Calculates a Distance
def calc_dist(coordinate_a, coordinate_b)
  return Math.sqrt(((coordinate_a[0] - coordinate_b[0])**2) + ((coordinate_a[1] - coordinate_b[1])**2))
end

# Get event from event ID
def get_event_from_id(id)
  return $game_map.events.values.select { |e| e.id == id }[0]
end

# New move route functionality
def pbAStarMoveRoute(event, commands, waitComplete = false)
  route = RPG::MoveRoute.new
  route.repeat    = false
  route.skippable = true
  route.list.clear
  i = 0
  while i<commands.length
    case commands[i]
    when PBMoveRoute::Wait, PBMoveRoute::SwitchOn, PBMoveRoute::SwitchOff,
       PBMoveRoute::ChangeSpeed, PBMoveRoute::ChangeFreq, PBMoveRoute::Opacity,
       PBMoveRoute::Blending, PBMoveRoute::PlaySE, PBMoveRoute::Script
      route.list.push(RPG::MoveCommand.new(commands[i],[commands[i+1]]))
      i += 1
    when PBMoveRoute::ScriptAsync
      route.list.push(RPG::MoveCommand.new(PBMoveRoute::Script,[commands[i+1]]))
      route.list.push(RPG::MoveCommand.new(PBMoveRoute::Wait,[0]))
      i += 1
    when PBMoveRoute::Jump
      route.list.push(RPG::MoveCommand.new(commands[i],[commands[i+1],commands[i+2]]))
      i += 2
    when PBMoveRoute::Graphic
      route.list.push(RPG::MoveCommand.new(commands[i],
         [commands[i+1],commands[i+2],commands[i+3],commands[i+4]]))
      i += 4
    else
      route.list.push(RPG::MoveCommand.new(commands[i]))
    end
    i += 1
  end
  route.list.push(RPG::MoveCommand.new(0))
  if event
    event.force_move_route(route)
    pbMapInterpreter.command_210 if waitComplete
  end
  return route
end