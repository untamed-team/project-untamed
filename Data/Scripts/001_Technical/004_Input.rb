module Input
  USE      = C
  BACK     = B
  ACTION   = A
  JUMPUP   = X
  JUMPDOWN = Y
  SPECIAL  = Z
  AUX1     = L
  AUX2     = R
  AUX3     = F5
  AUX4     = F6
  AUX5     = F7
  #F8 is used for screenshots
  #F9 is used for debug
  AUX6     = ALT #used for quicksave
  AUX7     = 30 #used for battle info
  AUX8     = 31 #used for move info

  unless defined?(update_KGC_ScreenCapture)
    class << Input
      alias update_KGC_ScreenCapture update
    end
  end

  def self.update
    update_KGC_ScreenCapture
    if trigger?(Input::F8)
      pbScreenCapture
    end    
    
  end
end

module Mouse
  module_function

  # Returns the position of the mouse relative to the game window.
  def getMousePos(catch_anywhere = false)
    return nil unless System.mouse_in_window || catch_anywhere
    return Input.mouse_x, Input.mouse_y
  end
end
