#=====================================================================================================
# Settings
#=====================================================================================================
module Settings

  #---------------------------------------------------------------------------------------------------
  # Choose whether you want tutored moves to be permanently unlocked instead of repeatedly purchased.
  #---------------------------------------------------------------------------------------------------
  PERMANENT_TUTOR_MOVE_UNLOCK = true

  #---------------------------------------------------------------------------------------------------
  # ITEM ABBREVIATION SECTION
  # Here you can assign abbreviated names to specific items to take less space in the Tutor.net list
  #---------------------------------------------------------------------------------------------------

  # Turn Tutor Move Aliases on or off
  USE_TUTOR_MOVE_ALIASES = false

  # Assign aliases of your choice. Below are some Examples (which you can edit if you want):
  TUTOR_MOVE_ALIASES = [
    [:REDSHARD,"Red"],
    [:BLUESHARD,"Blue"],
    [:GREENSHARD,"Green"],
    [:YELLOWSHARD,"Yellow"],
    [:ORANGESHARD,"Orange"],
    [:PURPLESHARD,"Purple"],
    #THIS IS THE MAIN EXAMPLE AND KEEPS THE ARRAY FROM BREAKING.
    #DO NOT EDIT THIS ONE. ADD YOUR ALIASES ABOVE
    [:ITEMWITHVERYBIGNAME,"Beeg"]
  ]

  #---------------------------------------------------------------------------------------------------
  # STYLE SELECTOR
  # Choose if you prefer the Tutor.net Screen with the bigger frame.
  # Bigger frame style has less space for text so you might need to add item aliases.
  #---------------------------------------------------------------------------------------------------
  BIGGER_FRAME_STYLE = false

end