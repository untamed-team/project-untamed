#==============================================================================
# Extra Fogs & Panorama Lock
# ---
# Author: Jaiden Alemni
# https://github.com/JaidenAlemni/rmxp-scripts
# --------------------------------------------------------------------------- 
# v1.0 - September 2019
# * Allows for an additional fog, which is per map instead of per tileset
# * Allows a panorama to lock so it doesn't scroll, allowing it to be used
#  as a ground layer
#  (Thanks to Game_Guy from www.chaos-project.com for help on this)
# * Designated fog for parallax/detail mapping 
# * Designated fog for lighting overlay
#
# [Compatibility]
# This script aliases the Spriteset_Map class. Place it above main
# like any other custom script. 
# It hasn't been extensively tested, but should otherwise play nicely
# with other map scripts. 
#
# [How to Use]
# The "fogs" folder should contains two subfolders:
# /Fogs/Lightmaps
# /Fogs/Parallax
#
# In these folders, place a file named "Map[MAPID]" (no leading zeros), 
# such as "Map2.png".
# If the file is detected, it will be applied to the map.
#
# ***NOTE: In order to get the desired effect, these files MUST be the same size
# as the map they're applied to. If they are not, the panorama/lights will not
# match up with the tilemap / player. 
#
# Lightmaps will always have subtractive blending, and "parallax" will always 
# be drawn above the ground layer but below the player. This means the player 
# can always walk over items in the parallax, and is best reserved for things 
# like vegetation, etc.
#
#==============================================================================
module CustomFogsPanorama
    #--------------------------------------------------------------------------
    # * Constants (Please do not modify)
    #--------------------------------------------------------------------------
    NORMAL = 0
    ADD = 1
    SUB = 2
    
    #well I HAD TO modify to prevent a crash my dude :) - Gardenette
    #it seems you put map IDs (without leading 0s) in the array below to tell
    #the game which maps will have their panoramas locked
    LOCK_PANORAMA_IDS = []
    
    #--------------------------------------------------------------------------
    def self.fogs(map_id)
      case map_id
      #==============================================================================
      #
      # BEGIN CONFIGURATION
      #
      # When a fog is specified here, it will be drawn in ADDITION to the 
      # already existing map fog. 
      #
      # Configuration values are identical to that of the editor.
      # Please follow the format exactly, and do not modify the "else"
      # or the lines below it. Mind your commas!
      
      # when MAPID then ["Name", Zoom_x (%), Zoom_y (%), Opacity (0-255), Blend Type (NORMAL, ADD, SUB), Tone.new(r,g,b,grey), scroll x, scroll y]
      # when 1 then ["003-Shade01", 100, 100, 50, SUB, Tone.new(0,0,0,0), -1, 5]
      # when 2 then ["Fog Name", 100, 100, 255, NORMAL, Tone.new(0,0,0,0), 0, 0]
      
      #the below line works - Gardenette
      when 64 then ["dandelion", 100, 100, 255, NORMAL, Tone.new(0,0,0,0), 0, 0]
      
      #
      #---- End Extra Fog Config -------------------------------------------------
      else 
        [""]
      end
    end
  # END CONFIGURATION
  # (Do not modify below this line unless you know what you're doing!)
  #
  #==============================================================================
  end
  
#==============================================================================
# * Game_Map
#==============================================================================
  class Game_Map
    #--------------------------------------------------------------------------
    # * Public Instance Variables
    #--------------------------------------------------------------------------
    attr_accessor :parallax_lock
    attr_accessor :fog2_ox
    attr_accessor :fog2_oy
    #--------------------------------------------------------------------------
    # * Setup
    #    map_id : map ID
    #--------------------------------------------------------------------------
    alias jaiden_parallax_map_setup setup
    def setup(map_id)
      # Call original
      jaiden_parallax_map_setup(map_id)
      # Initialize fog variables
      @fog2_ox = 0
      @fog2_oy = 0
      # Get fog sx/sy
      @fog2 = CustomFogsPanorama.fogs(@map_id)
      @fog2_sx = @fog2[6]
      @fog2_sy = @fog2[7]
      # Check if map_id includes parallax
      if CustomFogsPanorama::LOCK_PANORAMA_IDS.include?(@map_id)
        @parallax_lock = true
      else
        @parallax_lock = false
      end
    end
    #--------------------------------------------------------------------------
    # * Frame Update
    #--------------------------------------------------------------------------
    alias jaiden_second_fog_update update
    def update
      # Call original / aliases
      jaiden_second_fog_update
      # Manage fog scrolling
      if @fog2[0] != ""
        @fog2_ox -= @fog2_sx / 8.0
        @fog2_oy -= @fog2_sy / 8.0
      end
    end
  end
  
  class Spriteset_Map
    #--------------------------------------------------------------------------
    # * Initialize
    #--------------------------------------------------------------------------
    alias jaiden_lights_initialize_spritemap initialize
    def initialize(map)
      # Call original
      jaiden_lights_initialize_spritemap(map)
      # Reassign fog plane if a custom one is assigned
      second_fog = CustomFogsPanorama.fogs($game_map.map_id)
      if second_fog[0] != ""
        @fog2 = Plane.new(@viewport1)
        @fog2.bitmap = RPG::Cache.fog(second_fog[0], 0)
        @fog2.zoom_x = second_fog[1] / 100.0
        @fog2.zoom_y = second_fog[2] / 100.0
        @fog2.opacity = second_fog[3]
        @fog2.blend_type = second_fog[4]
        @fog2.tone = second_fog[5]
        @fog2.z = 3500
      end
      # Create parallax (unlike panorama, this overlays the map and should always = map size)
      if FileTest.exist?("Graphics/Fogs/Parallax/Map#{$game_map.map_id}.png")
        #@parallax = Plane.new(@viewport1)
		#changed by Gardenette so parallaxes appear under the player
		#it will still appear above layer 2 and probably layer 3 as well
		@parallax = Plane.new(@@viewport1)
        @parallax.bitmap = RPG::Cache.fog("/Parallax/Map#{$game_map.map_id}", 0)
        @parallax.blend_type = 0 # Normal blending
        @parallax.opacity = 255
        @parallax.ox = $game_map.display_x / 4
        @parallax.oy = $game_map.display_y / 4		
      end
      # Create lightmap (above everything else)
      if FileTest.exist?("Graphics/Fogs/Lightmaps/Map#{$game_map.map_id}.png")
        @lightmap = Plane.new(@viewport1)
        @lightmap.z = 4000  
        @lightmap.bitmap = RPG::Cache.fog("/Lightmaps/Map#{$game_map.map_id}", 0)
        #@lightmap.blend_type = 2 # Subtractive blending
        @lightmap.blend_type = 0 #changed to normal blending - Gardenette
        @lightmap.opacity = 255 
        @lightmap.ox = $game_map.display_x / 4
        @lightmap.oy = $game_map.display_y / 4
      end
    end
    #--------------------------------------------------------------------------
    # * Dispose
    #--------------------------------------------------------------------------
    alias jaiden_lights_dispose_spritemap dispose
    def dispose
      @fog2.dispose if @fog2
      @parallax.dispose if @parallax
      @lightmap.dispose if @lightmap
      # Call original
      jaiden_lights_dispose_spritemap 
    end  
    #--------------------------------------------------------------------------
    # * Update
    #--------------------------------------------------------------------------
    alias jaiden_lights_spriteset_update update
    def update
      # Update second fog
      if @fog2
        @fog2.ox = $game_map.display_x / 4 + $game_map.fog2_ox
        @fog2.oy = $game_map.display_y / 4 + $game_map.fog2_oy
      end
      # Update parallax
      if @parallax
        @parallax.ox = $game_map.display_x / 4 
        @parallax.oy = $game_map.display_y / 4
      end
      # Update lightmap
      if @lightmap
        @lightmap.ox = $game_map.display_x / 4 
        @lightmap.oy = $game_map.display_y / 4
      end
      # Call original / aliased methods
      jaiden_lights_spriteset_update
      # Check for locked parallax 
      if $game_map.parallax_lock
        @panorama.ox = $game_map.display_x / 4
        @panorama.oy = $game_map.display_y / 4
      else
        @panorama.ox = $game_map.display_x / 8
        @panorama.oy = $game_map.display_y / 8
      end
    end
  end