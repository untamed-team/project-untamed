#===============================================================================
# Turn certain settings on/off according to your preferences.
#===============================================================================
module RegionMapSettings
    #===============================================================================
    # Hidden Region Locations
    #===============================================================================
    # This is similar to the REGION_MAP_EXTRAS you set-up in the Settings script section.
    # Why it is here? Well this is simply because it's easier to access if it's all on 1 place.
    # A set of arrays, each containing details of a graphic to be shown on the
    # region map if appropriate. The values for each array are as follows:
    # - Region number.
    # - Game Switch; The graphic is shown if this is ON (non-wall maps only unless you set the last setting to nil).
    # - X coordinate of the graphic on the map, in squares.
    # - Y coordinate of the graphic on the map, in squares.
    # - Name of the graphic, found in the Graphics/Pictures folder.
    # - The graphic will always (true), never (false) or only when the switch is ON (nil) be shown on a wall map.
    REGION_MAP_EXTRAS = [
      [0, 51, 16, 15, "mapHiddenBerth"], #last option is set to nil
      [0, 52, 20, 14, "mapHiddenFaraday", true] #last option is set to true
    ]
    #===============================================================================
    # Fly From Town Map
    #===============================================================================
    # Whether the player can use Fly while looking at the Town Map. This is only
    # allowed if the player can use Fly normally.
    CAN_FLY_FROM_TOWN_MAP = true

    #===============================================================================
    # Quick Fly Feature Settings
    #===============================================================================
    # Set this to true if you want to enable the Quick Fly feature.
    # Set this to false if you don't want to use this feature, all other settings below will be ignored.
    CAN_QUICK_FLY = true

    # Choose which button will activate the Quick Fly Feature
    # Possible buttons are: JUMPUP, JUMPDOWN, SPECIAL, AUX1 and AUX2. any other buttons are not recommended.
    # Press F1 in game to know which key a button is linked to.
    # IMPORTANT: only change the "JUMPUP" to SPECIAL for example so QUICK_FLY_BUTTON = Input::SPECIAL
    QUICK_FLY_BUTTON = Input::JUMPUP

    # Set this to true if you want to enable that the cursor moves automatically to the selected map from the Quick Fly Menu (on selecting, not confirming).
    # Set this to false if you don't want to enable this.
    AUTO_CURSOR_MOVEMENT = true 

    # Set a Switch that needs to be ON in order to enable the Quick Fly Feature.
    # Set this to nil if you don't want to require any switch to be ON.
    # Example: SWITCH_TO_ENABLE_QUICK_FLY = 11 # Quick Fly will be enabled when Switch with ID 11 (Defeated Gym 8) is set to ON. (This is a default essentials Switch) 
    SWITCH_TO_ENABLE_QUICK_FLY = nil

    #===============================================================================
    # Show Quest Icons on the Region Map (IMPORTANT: Required the MQS Plugin to funcion correctly!)
    #===============================================================================
    # Set this to true if you want to display Quest Icons on the Region map (this only shows on the Town Map the player owns and the PokeGear map).
    # Set this to false if you don't want to display Quest Icons or if you are simply not using the MQS Plugin.
    # If the MQS is not installed and this is set to true, it won't harm anything.
    SHOW_QUEST_ICONS = false    

    # Choose which button will activate the Quest Review. 
    # Possible buttons are: USE, JUMPUP, JUMPDOWN, SPECIAL, AUX1 and AUX2. any other buttons are not recommended.
    # USE can be used this time because unlike with the fly map, it won't do anything.
    # Press F1 in game to know which key a button is linked to.
    # IMPORTANT: only change the "JUMPUP" to JUMPDOWN for example so SHOW_QUEST_BUTTON = Input::JUMPDOWN
    SHOW_QUEST_BUTTON = Input::JUMPUP

    # Set the max lines the quest preview can take (default is 4 lines). 
    # This includes the Task and Location information.
    MAX_QUEST_LINES = 4
    #===============================================================================
    # Cursor Map Movement Offset
    #===============================================================================
    # This is a optional Setting to make the map move before the Cursor is at the edge of the map screen.
    # - false = No offset, the map will only move (if possible) when the cursor is on the direction's edge of the screen.
    #   example: When you  want to move to the Right, the map will only start moving once the cursor is all the way on the Right edge of the screen. 
    # - true = the map will move (if possible) when the cursor is 1 position away from the direction's edge of the screen.
    #   example: When you want to move to the Right, the map will start moving once the cursor is 1 tile away from the Right edge of the screen. 
    CURSOR_MAP_OFFSET = true
    #===============================================================================
    # Region District Names
    #===============================================================================
    # Set this to true if you want to change the default name (defined in the PBS) for certain parts of your Region Map.
    USE_REGION_DISTRICTS_NAMES = false  

    # - Region Number
    # - [min X, max X]; the minimum X value and the maximum X value, in squares.
    #    example: [0, 32]; when the cursor is between 0 and 32 (including 0 and 32) the name of the region changes (depending on the Y value as well).
    # - [min Y, max Y]; the minimum Y value and the maximum Y value, in squares.
    #    example: [0, 10]; when the cursor is between 0 and 10 (including 0 and 10) the name of the region changes (depending on the X value as well).
    # - Region District Name; this is the name the script will use only when the cursor is inside X and Y range.
    REGION_DISTRICTS = [
      [0, [9, 12], [8, 11], "West Essen"],
      [0, [9, 19], [12, 15], "South Essen"],
      [0, [9, 19], [4, 7], "North Essen"],
      [0, [15, 19], [7, 11], "East Essen"],
      [0, [13, 14], [8, 11], "Central Essen"],
      [1, [10, 20], [5, 15], "Central Tiall"]
    ]
    #===============================================================================
    # Unvisited Map Image name exceptions
    #===============================================================================
    # Add the Healspot of the map and a new image name you want the script to use a different unvisited map image for.
    # Healspot = mapID, mapX, mapY (this is where you'll fly to when using fly with that map as destination).
    # The image name should not include map, just like in the PBS.
    # This exception can be used when the top left point of a city/town has a different highlight image, like a location in a town/city.
    # example USE_UNVISITED_IMAGE_EXCEPTION = [[11, 19, 32, "Size2x2Special1"]]
    # There might be a different work around but this setting makes it much easier and prevents you from having to make tons of new images with different names which can get confusing.
    USE_UNVISITED_IMAGE_EXCEPTION = [
      [11, 19, 32, "Size2x2Special1"]
    ]
    #===============================================================================
    # Replace Unvisited Map Names and Point of Interests with "???"
    #===============================================================================
    # set this to true if you want the name of a location when hovered over in the Region Map being replaced with "???" if it has not been visited yet.
    # set this to false if you don't want this setting. 
    NO_UNVISITED_MAP_INFO = true  
    # set this to whatever text you want the map to show instead of the Location's name if it hasn't been visited yet (only applies if above's setting is set to true).
    UNVISITED_MAP_TEXT = "???"
    # set this to whatever text you want the map to show for the current Location's Point of Interest if it has one. ("" means it'll not show anything)
    UNVISITED_POI_TEXT = ""

    #===============================================================================
    # Highlight Opacity
    #===============================================================================
    # Set the opacity of the Highlight images to any value between 0 and 100 in steps of 5.
    # Possible values: 0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100.
    # Any other values than the one mentioned above will be converted to the closest one accepted.
    # For example 97 will be converted to 95 which will result in the Highlight Images having an opacity of 95%.
    # Any values higher than 100 will be converted to 100%.
    HIGHLIGHT_OPACITY = 85

    #===============================================================================
    # Region Map Modes
    #===============================================================================
    # Choose which button needs to be pressed to change the map mode. ACTION is the default one in essentials.
    # ATTENTION: if you set this to any button that has been asigned for quick fly and/or quest preview then you won't be able to change modes anymore.
    CHANGE_MODE_BUTTON = Input::ACTION
    # Set the name for each mode you want to display on the Region Map. 
    # Only change what's between the " ". quest and berry are modes that requires a plugin to be installed in order to be activated on the Region Map.
    MODE_NAMES = {
      normal: "Normal Map",
      fly: "Fly Map",
      quest: "Quest Map", #requires the "Modern Quest System + UI" plugin to use.
      berry: "Berry Map" #requires the "TDW Berry Planting Improvements" plugin to use.
    }

    # Set this to true if you want to have a choice menu when you have 3 or more available modes (by default you won't have choice menu when 2 or 1).
    # Set this to false if you want to change the mode by pressing the set button above (CHANGE_MODE_BUTTON) each time (no choice menu will be shown).
    CHANGE_MODE_MENU = true 

    # Choose where you want to display the Button Preview Box on the Region Map.
    # - Set this to 1 to display it in the Top Right.
    # - Set this to 2 to display it in the Bottom Right.
    # - Set this to 3 to display it in the Top Left default position).
    # - Set this to 4 to display it in the Bottom Left.
    BUTTON_PREVIEW_BOX_POSITION = 3

    # Set the opacity of the Button Preview Box when you move the Cursor behind it.
    # Any value is accepted between 0 and 100 in steps of 5. (Just like the Highlight Opacity Setting).
    BUTTON_PREVIEW_BOX_OPACITY = 50
    
    #===============================================================================
    # Region Map Music
    #===============================================================================
    # Set this to true if you want to have the BGM change when opening the Region Map.
    # The BGM that was playing before will be restored when closing the Region Map.
    CHANGE_MUSIC_IN_REGION_MAP = false

    # You can set different BGM for each region, change the volume and pitch. Volume and Pitch are 100 by default.
    # - The Region number.
    # - The name of the BGM
    # - Volume level.
    # - Pitch level.
    MUSIC_PER_REGION = [
      [0, "Radio - Oak", 90, 100], #Volume will be set to 90% and Pitch to 100%
      [0, "Radio - March"] #Volume and Pitch are both set to 100 by default if not given here.
    ]

    #===============================================================================
    # Region Map Text Positions
    #===============================================================================
    # Add an offset to each Text individually (optional). This could be handy if you're using a custom UI.
    REGION_NAME_OFFSET_X = 0
    REGION_NAME_OFFSET_Y = 0

    LOCATION_NAME_OFFSET_X = 0
    LOCATION_NAME_OFFSET_Y = 0

    POI_NAME_OFFSET_X = 0
    POI_NAME_OFFSET_Y = 0

    MODE_NAME_OFFSET_X = 0
    MODE_NAME_OFFSET_Y = 0

    #===============================================================================
    # Region Map Text Colors
    #===============================================================================
    # Set a color to each Text individually (opational).
    # Color used for Region, Mode, Location, Point Of Interest and Quest Name.
    UI_TEXT_MAIN = Color.new(248, 248, 248)
    UI_TEXT_SHADOW = Color.new(0, 0, 0)

    # Color used for Button Preview and Quest Information (Task and Location).
    BOX_TEXT_MAIN = Color.new(255, 255, 255)
    BOX_TEXT_SHADOW = Color.new(0, 0, 0)
  end