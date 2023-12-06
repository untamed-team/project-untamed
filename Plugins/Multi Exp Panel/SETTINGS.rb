#===============================================================================
# Multi Exp Panel
# By Swdfm
#===============================================================================
# Settings
#===============================================================================
# The colours of the text used in the panel
PANEL_BASE_COLOUR   = Color.new(80, 80, 88)
PANEL_SHADOW_COLOUR = Color.new(160, 160, 168)
class Swdfm_Exp_Screen
  # The width in pixels in between the left/right side of the screen and the left/right side of the panel
  BORDER_WIDTH      = 64
  # The height in pixels in between the top/lower side of the screen and the top/lower side of the panel
  BORDER_HEIGHT     = 64
  # What colour is the edge of the panel?
  PANEL_EDGE_COLOUR = Color.new(57, 69, 81)
  # What is the main colour of the panel?
  PANEL_FILL_COLOUR = Color.new(206, 206, 206)
  # What colour is the edge of the Exp bars?
  EXP_EDGE_COLOUR   = PANEL_EDGE_COLOUR
  # What colour is the fill of the exp bar (without exp)
  EXP_FILL_COLOUR   = PANEL_FILL_COLOUR
  # What colour is the exp in the exp bar?
  EXP_EXP_COLOUR    = Color.new(229, 0, 0)
  # The size in pixels of the edge of the panel
  PANEL_EDGE_SIZE   = 8
  # The height in pixels of the exp bar
  EXP_BAR_HEIGHT    = 24
  # (Quite complicated!)
  # Half of the difference, in pixels, between 1/3 of the width of the panel and the width of an exp bar
  # Basically, make smaller for a wider exp bar
  EXP_WIDTH_GAP     = 16
  # The size, in pixels, of the edge of each exp bar
  EXP_BAR_EDGE_SIZE = 4
  # What is the shortest amount of time (In seconds, assuming 40fps) that it takes for the exp bars to animate?
  FASTEST_TIME      = 0.5
  # What is the longest amount of time (In seconds, assuming 40fps) that it takes for the exp bars to animate?
  SLOWEST_TIME      = 2.5
  # For how long (In seconds, assuming 40fps) does the amount of gained exp stay there for?
  ANNOUCE_TIME      = 1
  # In exp per frame, assuming 40fps, how fast is the bar?
  # Any value lower than 0 is treated as 0
  # Any value higher than 199 is treated as 199
  BAR_SPEED         = 100
  # How many pixels LEFT OF the right side of bar is midpoint of the Level of the Pokemon?
  LEVEL_X           = 64
  # How many pixels ABOVE the bar is the Level of the Pokemon?
  LEVEL_Y           = 48
  # How many pixels to the RIGHT of the left side of the bar is the left side of the Pokemon?
  POKE_X            = 0
  # How many pixels BELOW where the Pokemon would be it it sat on top of the top of the bar is the Pokemon?
  # Not sure why you'd change this, but it's here!
  POKE_Y            = 0
  # How many pixels to the right of the midpoint of the bar is the announced experience?
  EXP_X             = 0
  # How many pixels BELOW the underside of the bar is the announced experience?
  EXP_Y             = 4
  # Decides positions of where bars go
  # Best leave these alone!
  #...
  # But if you do want to modify these, here is a brief explanarion
  # The decimals here explain where the midpoint of the bar is in relation to the screen [width, height].
  # For example, a value of 0.5 means the bar is halfway across the screen. 0.33 means the bar is a third of a way across the screen.
  CO_ORDINATES = [
    [[0.5, 0.5]],   # Party Of 1: 1st Pokemon
	[[0.33, 0.5],   # Party Of 2: 1st Pokemon
 	 [0.67, 0.5]],  #             2nd Pokemon
	[[0.25, 0.5],   # Party Of 3, 1st Pokemon
	 [0.5,  0.5],   #             2nd Pokemon
	 [0.75, 0.5]],  #             3rd Pokemon
	[[0.33, 0.25],  # Party Of 4, 1st Pokemon
	 [0.67, 0.25],  #             2nd Pokemon
	 [0.33, 0.67],  #             3rd Pokemon
	 [0.67, 0.67]], #             4th Pokemon
    [[0.25, 0.25],  # Party Of 5, 1st Pokemon
	 [0.5,  0.25],  #             2nd Pokemon
	 [0.75, 0.25],  #             3rd Pokemon
	 [0.33, 0.67],  #             4th Pokemon
	 [0.67, 0.67]], #             5th Pokemon
	[[0.18, 0.25],  # Party Of 6, 1st Pokemon
	 [0.5,  0.25],  #             2nd Pokemon
	 [0.82, 0.25],  #             3rd Pokemon
	 [0.18, 0.67],  #             4th Pokemon
	 [0.5,  0.67],  #             5th Pokemon
	 [0.82, 0.67]]  #             6th Pokemon
  ]
  # How many pixels everything on the screen is dragged down (except for the backing panel)
  MOVE_DOWN_PIXELS = 16
end