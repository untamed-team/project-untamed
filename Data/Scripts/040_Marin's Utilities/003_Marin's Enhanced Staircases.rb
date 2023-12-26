#==============================================================================#
#                             Enhanced Staircases                              #
#                                  by Marin                                    #
#------------------------------------------------------------------------------#
# This script provides pixel movement while walking on staircases, while also  #
# slowing down movement to capture the real feeling and motion of a staircase. #
#------------------------------------------------------------------------------#
#                                  Usage                                       #
#                                                                              #
# To make a stair work smoothly, it must have one event at the bottom, and one #
# at the top (not on the staircase; one tile outwards).                        #
# Staircase events utilize comments to configure the properties of the stairs. #
# These comments are not compiled it any different format unlike, say, trainer #
# generation, and as such do not require you to restart RPG Maker XP.          #
#                                                                              #
# The name of a staircase event must be `Slope` (without the backticks ``),    #
# and the event must contain a comment with the following text:                #
# `Slope: AxB` where A and B are integers, specifying how many tiles           #
# away the second event is. If the staircase is wider than 1 tile, this must   #
# match up with event that has the same stair index, as explained below.       #
#                                                                              #
# If your staircase is more than 1 tile wide, you require an additional        #
# `Width: A/B` comment, where A is the index of the event in the staircase     #
# (i.e. if it's the bottom part of the staircase 0, if it's one higher 1, etc) #
# and B is the total width of the staircase. If you understand the explanation,#
# you'll agree that this means that the top event of a 3-wide staircase will   #
# say `Width: 2/3`.                                                            #
#                                                                              #
# It is also possible to specify at which point during movement from the event #
# to the start of the staircase to increment the vertical offset.              #
# By default, this is a value of 16 pixels. This means that you move without   #
# any vertical increase for the first 16 pixels, and after that start climbing #
# the staircase.                                                               #
# To change this offset, write in a comment, `Offset: Apx`, where A is the     #
# number of pixels after which to start climbing the staircase.                #
#------------------------------------------------------------------------------#
#                    Please give credit when using this.                       #
#==============================================================================#

# If true, overwrites default scrolling behaviour to make stair movement smooth
# and to reduce improper scrolling offsets after walking on stairs wider than 1.
# NOTE: Disabling breaks scrolling on stairs in v20.
SMOOTH_SCROLLING = true

# The factor at which move speed is reduced when walking on stairs.
# Note that this is not linear; this is a factor applied after the steepness
# of the staircase. That is to say, steep staircases will reduce move speed in itself,
# this factor is then applied on top of that reduction.
SPEED_REDUCTION_ON_STAIRS = 0.85

$DisableScrollCounter = 0

def pbTurnTowardEvent(event,otherEvent)
  sx = 0; sy = 0
  if $MapFactory
    relativePos=$MapFactory.getThisAndOtherEventRelativePos(otherEvent,event)
    sx = relativePos[0]
    sy = relativePos[1]
  else
    sx = event.x - otherEvent.x
    sy = event.y - otherEvent.y
  end
  sx += (event.width - otherEvent.width) / 2.0
  sy -= (event.height - otherEvent.height) / 2.0
  return if sx == 0 and sy == 0
  if event.on_middle_of_stair? && !otherEvent.on_middle_of_stair?
    sx > 0 ? event.turn_left : event.turn_right
    return
  end
  if sx.abs > sy.abs
    (sx > 0) ? event.turn_left : event.turn_right
  else
    (sy > 0) ? event.turn_up : event.turn_down
  end
end

class Scene_Map
  alias stair_transfer_player transfer_player
  def transfer_player(cancelVehicles = true)
    stair_transfer_player(cancelVehicles)
    $game_player.clear_stair_data
  end
end

class Game_Event
  alias stair_cetc check_event_trigger_touch
  def check_event_trigger_touch(dir)
    return if on_stair?
    return stair_cetc(dir)
  end

  alias stair_ceta check_event_trigger_auto
  def check_event_trigger_auto
    if $game_map && $game_map.events
      for event in $game_map.events.values
        next if self.is_stair_event? || @id == event.id
        if !on_stair? && (@real_x / Game_Map::REAL_RES_X).round == event.x &&
           (@real_y / Game_Map::REAL_RES_Y).round == event.y
          if event.is_stair_event?
            next if $game_player.x == event.x && $game_player.y == event.y
            self.slope(*event.get_stair_data)
            return
          end
        end
      end
    end
    return if on_stair? || $game_player.on_stair?
    return stair_ceta
  end
  
  alias stair_start start
  def start
    if is_stair_event?
      $game_player.slope(*self.get_stair_data)
    else
      stair_start
    end
  end
  
  def is_stair_event?
    return self.name == "Slope"
  end
  
  def get_stair_data
    return if !is_stair_event?
    return if !@list
    for cmd in @list
      if cmd.code == 108
        if cmd.parameters[0] =~ /Slope: (\d+)x(\d+)/
          xincline, yincline = $1.to_i, $2.to_i
        elsif cmd.parameters[0] =~ /Slope: -(\d+)x(\d+)/
          xincline, yincline = -$1.to_i, $2.to_i
        elsif cmd.parameters[0] =~ /Slope: (\d+)x-(\d+)/
          xincline, yincline = $1.to_i, -$2.to_i
        elsif cmd.parameters[0] =~ /Slope: -(\d+)x-(\d+)/
          xincline, yincline = -$1.to_i, -$2.to_i
        elsif cmd.parameters[0] =~ /Width: (\d+)\/(\d+)/
          ypos, yheight = $1.to_i, $2.to_i
        elsif cmd.parameters[0] =~ /Offset: (\d+)px/
          offset = $1.to_i
        end
      end
      if xincline && yincline && ypos && yheight && offset
        return [xincline, yincline, ypos, yheight, offset]
      end
    end
    return [xincline, yincline, ypos, yheight, 16]
  end
end

class Game_Player
  alias stair_cetc check_event_trigger_touch
  def check_event_trigger_touch(dir)
    return if on_stair?
    return stair_cetc(dir)
  end
  
  alias stair_ceth check_event_trigger_here
  def check_event_trigger_here(triggers)
    return if on_stair?
    return stair_ceth(triggers)
  end
  
  alias stair_cett check_event_trigger_there
  def check_event_trigger_there(triggers)
    return if on_stair?
    return stair_cett(triggers)
  end

  def move_generic(dir, turn_enabled = true)
    turn_generic(dir, true) if turn_enabled
    if !$game_temp.encounter_triggered
      if can_move_in_direction?(dir)
        x_offset = (dir == 4) ? -1 : (dir == 6) ? 1 : 0
        y_offset = (dir == 8) ? -1 : (dir == 2) ? 1 : 0
        return if pbLedge(x_offset, y_offset)
        return if pbEndSurf(x_offset, y_offset)
        turn_generic(dir, true)
        yield if block_given?
        if !$game_temp.encounter_triggered
          @x += x_offset
          @y += y_offset
          if $PokemonGlobal&.diving || $PokemonGlobal&.surfing
            $stats.distance_surfed += 1
          elsif $PokemonGlobal&.bicycle
            $stats.distance_cycled += 1
          else
            $stats.distance_walked += 1
          end
          $stats.distance_slid_on_ice += 1 if $PokemonGlobal.sliding
          increase_steps
        end
      elsif !check_event_trigger_touch(dir)
        bump_into_object
      end
    end
    $game_temp.encounter_triggered = false
  end
  
  def move_down(turn_enabled = true)
    move_generic(2, turn_enabled) { moving_vertically(1) }
  end
  
  def move_up(turn_enabled = true)
    move_generic(8, turn_enabled) { moving_vertically(-1) }
  end
end

class Game_Map
  alias stair_scroll_down scroll_down
  def scroll_down(distance)
    return if $DisableScrollCounter == 1
    return stair_scroll_down(distance)
  end
  
  alias stair_scroll_left scroll_left
  def scroll_left(distance)
    return if $DisableScrollCounter == 1
    return stair_scroll_left(distance)
  end
  
  alias stair_scroll_right scroll_right
  def scroll_right(distance)
    return if $DisableScrollCounter == 1
    return stair_scroll_right(distance)
  end
  
  alias stair_scroll_up scroll_up
  def scroll_up(distance)
    return if $DisableScrollCounter == 1
    return stair_scroll_up(distance)
  end
end

class Game_Character
  alias stair_passable? passable?
  def passable?(x, y, d, strict = false)
    return stair_passable?(x, y, d, strict) if !on_middle_of_stair?
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    if new_y > self.y
      return stair_y_position > 0
    elsif new_y < self.y
      return stair_y_position + 1 < stair_y_height
    end
    return true
  end

  attr_accessor :stair_start_x
  attr_accessor :stair_start_y
  attr_accessor :stair_end_x
  attr_accessor :stair_end_y
  attr_accessor :stair_y_position
  attr_accessor :stair_y_height
  attr_accessor :stair_begin_offset

  def move_generic(dir, turn_enabled = true)
    turn_generic(dir) if turn_enabled
    if can_move_in_direction?(dir)
      turn_generic(dir)
      @x += (dir == 4) ? -1 : (dir == 6) ? 1 : 0
      @y += (dir == 8) ? -1 : (dir == 2) ? 1 : 0
      increase_steps
      yield if block_given?
    else
      check_event_trigger_touch(dir)
    end
  end
  
  def move_down(turn_enabled = true)
    move_generic(2, turn_enabled) { moving_vertically(1) }
  end
  
  def move_up(turn_enabled = true)
    move_generic(8, turn_enabled) { moving_vertically(-1) }
  end

  def on_stair?
    return @stair_begin_offset && @stair_start_x && @stair_start_y &&
           @stair_end_x && @stair_end_y && @stair_y_position && @stair_y_height
  end
  
  def on_middle_of_stair?
    return false if !on_stair?
    if @stair_start_x > @stair_end_x
      return @real_x < (@stair_start_x * Game_Map::TILE_WIDTH - @stair_begin_offset) * Game_Map::X_SUBPIXELS &&
          @real_x > (@stair_end_x * Game_Map::TILE_WIDTH + @stair_begin_offset) * Game_Map::X_SUBPIXELS
    else
      return @real_x > (@stair_start_x * Game_Map::TILE_WIDTH + @stair_begin_offset) * Game_Map::X_SUBPIXELS &&
          @real_x < (@stair_end_x * Game_Map::TILE_WIDTH - @stair_begin_offset) * Game_Map::X_SUBPIXELS      
    end
  end
  
  def slope(x, y, ypos = 0, yheight = 1, begin_offset = 0)
    @stair_start_x = self.is_a?(Game_Player) ? @x : (@real_x / Game_Map::REAL_RES_X).round
    @stair_start_y = self.is_a?(Game_Player) ? @y : (@real_y / Game_Map::REAL_RES_Y).round
    @stair_end_x = @stair_start_x + x
    @stair_end_y = @stair_start_y + y
    @stair_y_position = ypos
    @stair_y_height = yheight
    @stair_begin_offset = begin_offset
    @stair_start_y += ypos
    @stair_end_y += ypos
  end
  
  def clear_stair_data
    @stair_begin_offset = nil
    @stair_start_x = nil
    @stair_start_y = nil
    @stair_end_x = nil
    @stair_end_y = nil
    @stair_y_position = nil
    @stair_y_height = nil
    @stair_last_increment = nil
  end
  
  def moving_vertically(value)
    if on_stair?      
      @stair_y_position -= value
      if @stair_y_position >= @stair_y_height || @stair_y_position < 0
        clear_stair_data
      end
    end
  end
  
  alias stair_update update
  def update
    if self == $game_player && SMOOTH_SCROLLING && on_stair?
      # Game_Player#update called; now disable Game_Map#scroll_*
      $DisableScrollCounter = 2
    end
    stair_update
    if on_middle_of_stair?
      ptgrs = Math.sqrt((@stair_end_x - @stair_start_x) ** 2 + (@stair_end_y - @stair_start_y) ** 2)
      fraction = (@stair_end_x - @stair_start_x).abs / ptgrs * SPEED_REDUCTION_ON_STAIRS
      self.move_speed_real = (2 ** (fraction * self.move_speed + 1)) * 0.8
    else
      oldspeed = self.move_speed
      self.move_speed = 0
      self.move_speed = oldspeed
    end
  end
  
  alias stair_update_pattern update_pattern
  def update_pattern
    if self == $game_player && $DisableScrollCounter == 2
      $DisableScrollCounter = 1
    end
    stair_update_pattern
  end
  
  alias stair_moving? moving?
  def moving?
    if self == $game_player && $DisableScrollCounter == 1
      # New Game_Player#update scroll method
      $DisableScrollCounter = 0
      @view_offset_x ||= 0
      @view_offset_y ||= 0
      self.center(
          (@real_x + @view_offset_x) / 4 / Game_Map::TILE_WIDTH,
          (@real_y + @view_offset_y) / 4 / Game_Map::TILE_HEIGHT
      )
    end
    return stair_moving?
  end
 
  alias stair_screen_y_ground screen_y_ground
  def screen_y_ground
    real_y = @real_y.to_f
    if on_stair?
      if @real_x / Game_Map::X_SUBPIXELS.to_f <= @stair_start_x * Game_Map::TILE_WIDTH &&
         @stair_end_x < @stair_start_x
        distance = (@stair_start_x - @stair_end_x) * Game_Map::REAL_RES_X -
            2.0 * @stair_begin_offset * Game_Map::X_SUBPIXELS
        rpos = @real_x - @stair_end_x * Game_Map::REAL_RES_X - @stair_begin_offset * Game_Map::X_SUBPIXELS
        fraction = 1 - rpos / distance.to_f
        if fraction >= 0 && fraction <= 1
          diff = fraction * (@stair_end_y - @stair_start_y) * Game_Map::REAL_RES_Y
          real_y += diff
          if self.is_a?(Game_Player)
            if SMOOTH_SCROLLING
              @view_offset_y += diff - (@stair_last_increment || 0)
            else
              $game_map.scroll_down(diff - (@stair_last_increment || 0))
            end
          end
          @stair_last_increment = diff
        end
        if fraction >= 1
          oldy = @y
          endy = @stair_end_y
          if @stair_end_y < @stair_start_y
            endy -= @stair_y_position
          else
            endy -= @stair_y_position
          end
          @y = endy
          @real_y = endy * Game_Map::REAL_RES_Y
          @view_offset_y = 0 if SMOOTH_SCROLLING && self.is_a?(Game_Player)
          clear_stair_data
          return stair_screen_y_ground
        end
      elsif @real_x / Game_Map::X_SUBPIXELS.to_f >= @stair_start_x * Game_Map::TILE_WIDTH &&
          @stair_end_x > @stair_start_x
        distance = (@stair_end_x - @stair_start_x) * Game_Map::REAL_RES_X -
            2.0 * @stair_begin_offset * Game_Map::X_SUBPIXELS
        rpos = @stair_start_x * Game_Map::REAL_RES_X - @real_x + @stair_begin_offset * Game_Map::X_SUBPIXELS
        fraction = rpos / distance.to_f
        if fraction <= 0 && fraction >= -1
          diff = fraction * (@stair_start_y - @stair_end_y) * Game_Map::REAL_RES_Y
          real_y += diff
          if self.is_a?(Game_Player)
            if SMOOTH_SCROLLING
              @view_offset_y += diff - (@stair_last_increment || 0)
            else
              $game_map.scroll_down(diff - (@stair_last_increment || 0))
            end
          end
          @stair_last_increment = diff
        end
        if fraction <= -1
          oldy = @y
          endy = @stair_end_y
          if @stair_end_y < @stair_start_y
            endy -= @stair_y_position
          else
            endy -= @stair_y_position
          end
          @y = endy
          @real_y = endy * Game_Map::REAL_RES_Y
          @view_offset_y = 0 if SMOOTH_SCROLLING && self.is_a?(Game_Player)
          clear_stair_data
          return stair_screen_y_ground
        end
      else
        clear_stair_data
      end
    end
    return ((real_y - self.map.display_y) / Game_Map::Y_SUBPIXELS + Game_Map::TILE_HEIGHT).round
  end
end

class Game_Follower
  def follow_leader(leader, instant = false, leaderIsTrueLeader = true)
    maps_connected = $map_factory.areConnected?(leader.map.map_id, self.map.map_id)
    target = nil
    # Get the target tile that self wants to move to
    if maps_connected
      behind_direction = 10 - leader.direction
      target = $map_factory.getFacingTile(behind_direction, leader)
      if target && $map_factory.getTerrainTag(target[0], target[1], target[2]).ledge
        # Get the tile above the ledge (where the leader jumped from)
        target = $map_factory.getFacingTileFromPos(target[0], target[1], target[2], behind_direction)
      end
      target = [leader.map.map_id, leader.x, leader.y] if !target
      # Added
      if on_stair?
        if leader.on_stair?
          if leader.stair_start_x != self.stair_start_x
            # Leader stepped on other side so start/end swapped, but not for follower yet
            target[2] = self.y
          elsif leader.stair_start_x < leader.stair_end_x
            # Left to Right
            if leader.x < leader.stair_start_x && self.x != self.stair_start_x
              # Leader stepped off
              target[2] = self.y
            end
          elsif leader.stair_end_x < leader.stair_start_x
            # Right to Left
            if leader.x > leader.stair_start_x && self.x != self.stair_start_x
              # Leader stepped off
              target[2] = self.y
            end
          end
        elsif self.on_middle_of_stair?
          # Leader is no longer on stair but follower is, so player moved up or down at the start or end of the stair
          if leader.y < self.stair_end_y - self.stair_y_height + 1 || leader.y > self.stair_end_y
            target[2] = self.y
          end
        end
      end
    else
      # Map transfer to an unconnected map
      target = [leader.map.map_id, leader.x, leader.y]
    end
    # Move self to the target
    if self.map.map_id != target[0]
      vector = $map_factory.getRelativePos(target[0], 0, 0, self.map.map_id, @x, @y)
      @map = $map_factory.getMap(target[0])
      # NOTE: Can't use moveto because vector is outside the boundaries of the
      #       map, and moveto doesn't allow setting invalid coordinates.
      @x = vector[0]
      @y = vector[1]
      @real_x = @x * Game_Map::REAL_RES_X
      @real_y = @y * Game_Map::REAL_RES_Y
    end
    if instant || !maps_connected
      moveto(target[1], target[2])
    else
      fancy_moveto(target[1], target[2], leader)
    end
  end
end

class Game_FollowerFactory
  def update
    followers = $PokemonGlobal.followers
    return if followers.length == 0
    # Update all followers
    leader = $game_player
    player_moving = $game_player.moving? || $game_player.jumping?
    followers.each_with_index do |follower, i|
      event = @events[i]
      next if !@events[i]
      if follower.invisible_after_transfer && player_moving
        follower.invisible_after_transfer = false
        event.turn_towards_leader($game_player)
      end
      event.through = event.on_stair? # Added
      event.move_speed_real  = leader.move_speed_real
      event.transparent = !follower.visible?
      if $PokemonGlobal.sliding
        event.straighten
        event.walk_anime = false
      else
        event.walk_anime = true
      end
      if event.jumping? || event.moving? || !player_moving
        event.update
      elsif !event.starting
        event.set_starting
        event.update
        event.clear_starting
      end
      follower.direction = event.direction
      leader = event
    end
    # Check event triggers
    if Input.trigger?(Input::USE) && !$game_temp.in_menu && !$game_temp.in_battle &&
       !$game_player.move_route_forcing && !$game_temp.message_window_showing &&
       !pbMapInterpreterRunning?
      # Get position of tile facing the player
      facing_tile = $map_factory.getFacingTile
      # Assumes player is 1x1 tile in size
      each_follower do |event, follower|
        if event.at_coordinate?($game_player.x, $game_player.y)   # Underneath player
          next if !event.over_trigger?
        elsif facing_tile && event.map.map_id == facing_tile[0] &&
              event.at_coordinate?(facing_tile[1], facing_tile[2])   # On facing tile
          next if event.over_trigger?
        else   # Somewhere else
          next
        end
        next if event.jumping?
        follower.interact(event)
      end
    end
  end
end