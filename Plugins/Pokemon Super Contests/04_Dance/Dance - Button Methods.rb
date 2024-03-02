class Dance
  #=========================================================
  # Button Methods
  #=========================================================  
  def self.detectButtonInput
    #detect button input, but don't do anything with that input (besides
    #making the buttons play their press animations) unless the player can
    #dance
    
    #if pressed button
    if (Input.press?(Input::UP) || Mouse.press?(@sprites["button_jump"])) && @button_held != true
      @button_held = true
      #set cooldown
      @inputCooldownTimer = @inputCooldown
      
      @animTimer = 4
      if @sprites["button_jump"].frame <= 0
        @sprites["button_jump"].play if !@sprites["button_jump"].playing?
      end
      self.movePlayer("Jump") if self.playerCanDance?
      
    end #if Input.press?(Input::UP)
    
    if (Input.press?(Input::DOWN) || Mouse.press?(@sprites["button_front"])) && @button_held != true
      @button_held = true
      #set cooldown
      @inputCooldownTimer = @inputCooldown
      
      @animTimer = 4
      if @sprites["button_front"].frame <= 0
        @sprites["button_front"].play if !@sprites["button_front"].playing?
      end
      self.movePlayer("Front") if self.playerCanDance?
      
    end #if Input.press?(Input::DOWN)
    
    if (Input.press?(Input::LEFT) || Mouse.press?(@sprites["button_left"])) && @button_held != true
      @button_held = true
      #set cooldown
      @inputCooldownTimer = @inputCooldown
      
      @animTimer = 4
      if @sprites["button_left"].frame <= 0
        @sprites["button_left"].play if !@sprites["button_left"].playing?
      end
      self.movePlayer("Left") if self.playerCanDance?
      
    end #if Input.press?(Input::LEFT)
    
    if (Input.press?(Input::RIGHT) || Mouse.press?(@sprites["button_right"])) && @button_held != true
      @button_held = true
      #set cooldown
      @inputCooldownTimer = @inputCooldown
      
      @animTimer = 4
      if @sprites["button_right"].frame <= 0
        @sprites["button_right"].play if !@sprites["button_right"].playing?
      end
      
      self.movePlayer("Right") if self.playerCanDance?
      
    end #if Input.press?(Input::RIGHT)
    
  end #def self.detectButtonInput
end #class Dance