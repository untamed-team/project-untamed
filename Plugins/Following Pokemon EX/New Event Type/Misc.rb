#-------------------------------------------------------------------------------
# Functions for handling the work that the variables did earlier
# Also track new data like the current surfing and diving follower
#-------------------------------------------------------------------------------
class PokemonGlobalMetadata
  # Variable to check whether the Following Pokemon has been toggled
  attr_reader   :follower_toggled
  # Variable to track the time the Following Pokemon has been behind the player
  attr_accessor :time_taken
  # Variable to check whether the Following Pokemon is holding an item
  attr_accessor :follower_hold_item
  # Variable to track the Pokemon that is currently surfing
  attr_accessor :current_surfing
  # Variable to track the Pokemon that is currently diving
  attr_accessor :current_diving
  # Queue a refresh for the Following Pokemon forcefully
  attr_accessor :call_refresh

  def follower_toggled=(value)
    @follower_toggled = value
    FollowingPkmn.refresh_internal
  end

  def call_refresh
    @call_refresh = [false, false] if !@call_refresh
    return @call_refresh
  end

  def call_refresh=(value)
    ret = value
    ret = [value, false] if !value.is_a?(Array)
    @call_refresh = ret
  end

  def time_taken
    @time_taken = 0 if !@time_taken
    return @time_taken
  end
end

#-------------------------------------------------------------------------------
# Adding a few variables to track temporary data
#-------------------------------------------------------------------------------
class Game_Temp
  # Prevent removal of Following Pokemon when starting over
  attr_accessor :starting_over
  # Override to stop animation Following Pokemon field move animation
  attr_accessor :no_follower_field_move
  # Tracking variable for smoothly showing the Following Pokemon animating at
  # a Pokecenter
  attr_writer :pokecenter_following_pkmn
  # Tracking variable for smoothly animating the Following Pokemon's status
  # condition
  attr_accessor :status_pulse

  def status_pulse
    @status_pulse = [50.0, 50.0, 150.0, (100/(Graphics.frame_rate * 2.0))] if !@status_pulse
    return @status_pulse
  end

  def pokecenter_following_pkmn
    @pokecenter_following_pkmn = 0 if !@pokecenter_following_pkmn
    return @pokecenter_following_pkmn
  end
end

#-------------------------------------------------------------------------------
# Prevent other events from passing through Following Pokemon. Toggleable
#-------------------------------------------------------------------------------
class Game_Character
  alias __followingpkmn__passable? passable? unless method_defined?(:__followingpkmn__passable?)
  def passable?(x, y, d, strict = false)
    ret = __followingpkmn__passable?(x, y, d, strict)
    return ret if !FollowingPkmn.active? || !FollowingPkmn::IMPASSABLE_FOLLOWER
    if ret && self != $game_player && !self.is_a?(Game_FollowingPkmn)
      new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
      new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
      $game_temp.followers.each_follower do |e, _|
        return false if e.at_coordinate?(new_x, new_y) && !e.through
      end
    end
    return ret
  end
end

#-------------------------------------------------------------------------------
# Turn on a temporary flag to make sure that when starting over, the Following
# Pokemon method is not removed
#-------------------------------------------------------------------------------
alias __followingpkmn__pbStartOver pbStartOver unless defined?(__followingpkmn__pbStartOver)
def pbStartOver(*args)
  $game_temp.starting_over = true
  __followingpkmn__pbStartOver(*args)
  $game_temp.starting_over = false
end

#-------------------------------------------------------------------------------
# Refresh Following Pokemon after any Followers are removed
#-------------------------------------------------------------------------------
module Followers
  class << self
    alias __followingpkmn__remove remove unless method_defined?(:__followingpkmn__remove)
    alias __followingpkmn__remove_event remove_event unless method_defined?(:__followingpkmn__remove_event)
    alias __followingpkmn__clear clear unless method_defined?(:__followingpkmn__clear)
  end
  module_function

  def remove(*args)
    __followingpkmn__remove(*args)
    FollowingPkmn.refresh(false)
  end

  def remove_event(*args)
    __followingpkmn__remove_event(*args)
    FollowingPkmn.refresh(false)
  end

  def clear(*args)
    # Don't remove the Following Pokemon if game has been started over
    if $game_temp.starting_over
      $game_temp.followers.remove_all_except_following_pkmn
    else
      __followingpkmn__clear(*args)
    end
    FollowingPkmn.refresh(false)
  end
end

#-------------------------------------------------------------------------------
# Edit the follower checks to account for Following Pokemon
#-------------------------------------------------------------------------------
class Game_Player
  # The player can travel anywhere with their Following Pokemon
  alias __followingpkmn__can_map_transfer_with_follower? can_map_transfer_with_follower? unless method_defined?(:__followingpkmn__can_map_transfer_with_follower?)
  def can_map_transfer_with_follower?(*args)
    return true if FollowingPkmn.get && $PokemonGlobal.followers.length == 1
    return __followingpkmn__can_map_transfer_with_follower?(*args)
  end

  # The player can ride (almost) any vehicle with their Following Pokemon
  alias __followingpkmn__can_ride_vehicle_with_follower? can_ride_vehicle_with_follower? unless method_defined?(:__followingpkmn__can_ride_vehicle_with_follower?)
  def can_ride_vehicle_with_follower?(*args)
    return true if FollowingPkmn.get && $PokemonGlobal.followers.length == 1
    return __followingpkmn__can_ride_vehicle_with_follower?(*args)
  end
end
