#===================================================================================================================
# Always inside Bushes - By Kotaro with huge contributions by Titania318 [v20.1]
# Idea based of KleinStudio's "Overworlds always within grass" Script [v17]
# For water tiles: idea based on derFischae's "Always in bush and in water" Script [v17]
# Updated to be fully compatible the Following Pokemon EX Plugin by Golisopod User [v20.1]
#===================================================================================================================

module Always_in_Bush_in_Water
  # Constants to disable either AiB or AiW if you only want 1 of them to be active
  # Bush
  AIB_ACTIVE  = true
  # Water
  AIW_ACTIVE  = true
  # Sand
  AIS_ACTIVE  = true
  # Configurable constants for bush depth,water depth and sand depth
  BUSH_DEPTH     = 12
  WATER_DEPTH    = 15
  SAND_DEPTH     = 7
  # List of event IDs that are allowed to be submerged in water. Note that by default events are not allowed in water.
  EVENTS_ALLOWED_IN_WATER = []
  # List of event IDs not allowed in bush. In general, all events aer allowed to be in bush, except ones added to the list below.
  EVENTS_NOT_ALLOWED_IN_GRASS = []
  # List of event IDs that are not allowed to sink into the sand.
  EVENTS_NOT_ALLOWED_IN_SAND = []
  # Note that the following Pokémon Event is handled in code already
  if PluginManager.findDirectory("Following Pokemon EX")
    FOLLOWING_POKEMON = true
  else
    FOLLOWING_POKEMON = false
  end  
end

#===================================================================================================================
class Game_Character
    def calculate_bush_depth
      if @tile_id > 0 || @always_on_top || jumping?
        @bush_depth = 0
      else
        xbehind = @x + (@direction == 4 ? 1 : @direction == 6 ? -1 : 0)
        ybehind = @y + (@direction == 8 ? 1 : @direction == 2 ? -1 : 0)
        this_map = (self.map.valid?(@x, @y)) ? [self.map, @x, @y] : $map_factory&.getNewMap(@x, @y, self.map.map_id)
        behind_map = (self.map.valid?(xbehind, ybehind)) ? [self.map, xbehind, ybehind] : $map_factory&.getNewMap(xbehind, ybehind, self.map.map_id)
        if this_map[0].deepBush?(this_map[1], this_map[2]) && behind_map[0].deepBush?(behind_map[1], behind_map[2])
          @bush_depth = Game_Map::TILE_HEIGHT
        elsif !moving? && this_map[0].bush?(this_map[1], this_map[2]) && Always_in_Bush_in_Water::AIB_ACTIVE
          if !Always_in_Bush_in_Water::EVENTS_NOT_ALLOWED_IN_GRASS.include?(@id)
            @bush_depth = Always_in_Bush_in_Water::BUSH_DEPTH
          end
        elsif moving? && this_map[0].bush?(this_map[1], this_map[2]) && behind_map[0].bush?(behind_map[1], behind_map[2]) && Always_in_Bush_in_Water::AIB_ACTIVE
          if !Always_in_Bush_in_Water::EVENTS_NOT_ALLOWED_IN_GRASS.include?(@id)
            @bush_depth = Always_in_Bush_in_Water::BUSH_DEPTH
          end

        # added for sand  
        elsif !moving? && this_map[0].sand?(this_map[1], this_map[2]) && Always_in_Bush_in_Water::AIS_ACTIVE
          if !Always_in_Bush_in_Water::EVENTS_NOT_ALLOWED_IN_SAND.include?(@id)
            @bush_depth = Always_in_Bush_in_Water::SAND_DEPTH
          end
        elsif moving? && this_map[0].sand?(this_map[1], this_map[2]) && behind_map[0].sand?(behind_map[1], behind_map[2]) && Always_in_Bush_in_Water::AIS_ACTIVE
          if !Always_in_Bush_in_Water::EVENTS_NOT_ALLOWED_IN_SAND.include?(@id)
            @bush_depth = Always_in_Bush_in_Water::SAND_DEPTH
          end  

        # added for water
        elsif !moving? && this_map[0].water?(this_map[1], this_map[2]) && Always_in_Bush_in_Water::AIW_ACTIVE
          if self == $game_player && $PokemonGlobal.surfing
            @bush_depth = 0
          elsif !Always_in_Bush_in_Water::EVENTS_ALLOWED_IN_WATER.include?(@id)
            @bush_depth = 0
          else
            @bush_depth = Always_in_Bush_in_Water::WATER_DEPTH   
          end
          
        elsif moving? && this_map[0].water?(this_map[1], this_map[2]) && behind_map[0].water?(behind_map[1], behind_map[2]) && Always_in_Bush_in_Water::AIW_ACTIVE
          if self == $game_player && $PokemonGlobal.surfing
            @bush_depth = 0
          elsif !Always_in_Bush_in_Water::EVENTS_ALLOWED_IN_WATER.include?(@id)
            @bush_depth = 0
          else
            @bush_depth = Always_in_Bush_in_Water::WATER_DEPTH   
          end
        else
          @bush_depth = 0
        end
        
        
        if Always_in_Bush_in_Water::FOLLOWING_POKEMON
          if FollowingPkmn.active?
            if self == FollowingPkmn.get_event
              if FollowingPkmn.airborne_follower?
                @bush_depth = 0
              elsif !moving? && this_map[0].water?(this_map[1], this_map[2]) && Always_in_Bush_in_Water::AIW_ACTIVE
                @bush_depth = Always_in_Bush_in_Water::WATER_DEPTH
              elsif moving? && this_map[0].water?(this_map[1], this_map[2]) && behind_map[0].water?(behind_map[1], behind_map[2]) && Always_in_Bush_in_Water::AIW_ACTIVE
                @bush_depth = Always_in_Bush_in_Water::WATER_DEPTH
              end
            end   
          end
        end       
      end
    end
end


#===================================================================================================================
# Adds new method water?(x,y) + sand?(x,y) to the class Game_Map
#===================================================================================================================
class Game_Map
  def water?(x,y)
    [2, 1, 0].each do |i|
      tile_id = data[x, y, i]
      terrain = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
      return false if terrain.bridge && $PokemonGlobal.bridge > 0
      return false if terrain.id_number == 17
      return false if terrain.id_number == 3
      return true if terrain.can_surf && @passages[tile_id]
    end
    return false
  end

  def sand?(x,y)
    [2, 1, 0].each do |i|
      tile_id = data[x, y, i]
      terrain = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
      return false if terrain.id_number == 17
      return true if terrain.id_number == 3
    end
    return false
  end  
end


#===================================================================================================================
# Overrides the Script Command to toggle Following Pokemon
# This is in order to recalculate bush depth when following Pokemon are toggled
#===================================================================================================================
if Always_in_Bush_in_Water::FOLLOWING_POKEMON
  module FollowingPkmn

    def self.toggle(forced = nil, anim = nil)
      return if !FollowingPkmn.can_check? || !FollowingPkmn.get
      return if !FollowingPkmn.get_pokemon
      anim_1 = FollowingPkmn.active?
      if !forced.nil?
        # This may seem redundant but it keeps follower_toggled a boolean always
        $PokemonGlobal.follower_toggled = !(!forced)
      else
        $PokemonGlobal.follower_toggled = !($PokemonGlobal.follower_toggled)
      end
      anim_2 = FollowingPkmn.active?
      anim = anim_1 != anim_2 if anim.nil?
      FollowingPkmn.refresh(anim)
      $game_temp.followers.move_followers
      $game_temp.followers.turn_followers
      
      #additions
      even=FollowingPkmn.get_event
      even.calculate_bush_depth
    end
  end
end

#===================================================================================================================