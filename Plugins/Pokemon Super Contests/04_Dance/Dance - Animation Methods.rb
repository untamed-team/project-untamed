class Dance
  #================================================
  #=============== Button Presses ================
  #================================================
  def self.updateButtonAnimation
    ######### Press Button Jump #########
    if Input.press?(Input::UP) || Mouse.press?(@sprites["button_jump"])
      if @sprites["button_jump"].frame >= 2
        @sprites["button_jump"].stop
      end
    end #if Input.press?(Input::UP)
    
    ######### Release Button Jump #########
    if !Input.press?(Input::UP) && !Mouse.press?(@sprites["button_jump"])
      @button_held = false if @animTimer <= 0
      if @sprites["button_jump"].frame >= 2
        @sprites["button_jump"].play if !@sprites["button_jump"].playing?
      end
      if @sprites["button_jump"].frame == 0 && @animTimer <= 0
        @sprites["button_jump"].stop
      end
      @animTimer -= 1
    end #if !Input.press?(Input::UP)
    
    ######### Press Button Front #########
    if Input.press?(Input::DOWN) || Mouse.press?(@sprites["button_front"])
      if @sprites["button_front"].frame >= 2
        @sprites["button_front"].stop
      end
    end #if Input.press?(Input::DOWN)
    
    ######### Release Button Front #########
    if !Input.press?(Input::DOWN) && !Mouse.press?(@sprites["button_front"])
      @button_held = false if @animTimer <= 0
      if @sprites["button_front"].frame >= 2
        @sprites["button_front"].play if !@sprites["button_front"].playing?
      end
      if @sprites["button_front"].frame == 0 && @animTimer <= 0
        @sprites["button_front"].stop
      end
      @animTimer -= 1
    end #if !Input.press?(Input::DOWN)
    
    ######### Press Button Left #########
    if Input.press?(Input::LEFT) || Mouse.press?(@sprites["button_left"])
      if @sprites["button_left"].frame >= 2
        @sprites["button_left"].stop
      end
    end #if Input.press?(Input::LEFT)
    
    ######### Release Button Left #########
    if !Input.press?(Input::LEFT) && !Mouse.press?(@sprites["button_left"])
      @button_held = false if @animTimer <= 0
      if @sprites["button_left"].frame >= 2
        @sprites["button_left"].play if !@sprites["button_left"].playing?
      end
      if @sprites["button_left"].frame == 0 && @animTimer <= 0
        @sprites["button_left"].stop
      end
      @animTimer -= 1
    end #if !Input.press?(Input::LEFT)
    
    ######### Press Button Right #########
    if Input.press?(Input::RIGHT) || Mouse.press?(@sprites["button_right"])
      if @sprites["button_right"].frame >= 2
        @sprites["button_right"].stop
      end
    end #if Input.press?(Input::RIGHT)
    
    ######### Release Button Right #########
    if !Input.press?(Input::RIGHT) && !Mouse.press?(@sprites["button_right"])
      @button_held = false if @animTimer <= 0
      if @sprites["button_right"].frame >= 2
        @sprites["button_right"].play if !@sprites["button_right"].playing?
      end
      if @sprites["button_right"].frame == 0 && @animTimer <= 0
        @sprites["button_right"].stop
      end
      @animTimer -= 1
    end #if !Input.press?(Input::RIGHT)
    
  end #def self.updateButtonAnimation
  
  #=========================================================
  # Update Button Animations
  #=========================================================
  def self.updateMoveButtonAnimations
    #used for detecting when a move button has reached its last frame
    #when the button has reached its last frame, it will be stopped if it's
    #playing
    #amount of possible moves per track run: 16
    @moveButtonSprites["move1"].stop if @moveButtonSprites["move1"] && !@moveButtonSprites["move1"].disposed? && @moveButtonSprites["move1"].playing? && @moveButtonSprites["move1"].frame == 2
    @moveButtonSprites["move2"].stop if @moveButtonSprites["move2"] && !@moveButtonSprites["move2"].disposed? && @moveButtonSprites["move2"].playing? && @moveButtonSprites["move2"].frame == 2
    @moveButtonSprites["move3"].stop if @moveButtonSprites["move3"] && !@moveButtonSprites["move3"].disposed? && @moveButtonSprites["move3"].playing? && @moveButtonSprites["move3"].frame == 2
    @moveButtonSprites["move4"].stop if @moveButtonSprites["move4"] && !@moveButtonSprites["move4"].disposed? && @moveButtonSprites["move4"].playing? && @moveButtonSprites["move4"].frame == 2
    @moveButtonSprites["move5"].stop if @moveButtonSprites["move5"] && !@moveButtonSprites["move5"].disposed? && @moveButtonSprites["move5"].playing? && @moveButtonSprites["move5"].frame == 2
    @moveButtonSprites["move6"].stop if @moveButtonSprites["move6"] && !@moveButtonSprites["move6"].disposed? && @moveButtonSprites["move6"].playing? && @moveButtonSprites["move6"].frame == 2
    @moveButtonSprites["move7"].stop if @moveButtonSprites["move7"] && !@moveButtonSprites["move7"].disposed? && @moveButtonSprites["move7"].playing? && @moveButtonSprites["move7"].frame == 2
    @moveButtonSprites["move8"].stop if @moveButtonSprites["move8"] && !@moveButtonSprites["move8"].disposed? && @moveButtonSprites["move8"].playing? && @moveButtonSprites["move8"].frame == 2
    @moveButtonSprites["move9"].stop if @moveButtonSprites["move9"] && !@moveButtonSprites["move9"].disposed? && @moveButtonSprites["move9"].playing? && @moveButtonSprites["move9"].frame == 2
    @moveButtonSprites["move10"].stop if @moveButtonSprites["move10"] && !@moveButtonSprites["move10"].disposed? && @moveButtonSprites["move10"].playing? && @moveButtonSprites["move10"].frame == 2
    @moveButtonSprites["move11"].stop if @moveButtonSprites["move11"] && !@moveButtonSprites["move11"].disposed? && @moveButtonSprites["move11"].playing? && @moveButtonSprites["move11"].frame == 2
    @moveButtonSprites["move12"].stop if @moveButtonSprites["move12"] && !@moveButtonSprites["move12"].disposed? && @moveButtonSprites["move12"].playing? && @moveButtonSprites["move12"].frame == 2
    @moveButtonSprites["move13"].stop if @moveButtonSprites["move13"] && !@moveButtonSprites["move13"].disposed? && @moveButtonSprites["move13"].playing? && @moveButtonSprites["move13"].frame == 2
    @moveButtonSprites["move14"].stop if @moveButtonSprites["move14"] && !@moveButtonSprites["move14"].disposed? && @moveButtonSprites["move14"].playing? && @moveButtonSprites["move14"].frame == 2
    @moveButtonSprites["move15"].stop if @moveButtonSprites["move15"] && !@moveButtonSprites["move15"].disposed? && @moveButtonSprites["move15"].playing? && @moveButtonSprites["move15"].frame == 2
    @moveButtonSprites["move16"].stop if @moveButtonSprites["move16"] && !@moveButtonSprites["move16"].disposed? && @moveButtonSprites["move16"].playing? && @moveButtonSprites["move16"].frame == 2
  end
  
  def self.disposeMoveButtons
    pbDisposeSpriteHash(@moveButtonSprites)
    #dispose of the markings "match direction"
    @sprites["copy1"].dispose if @sprites["copy1"] && !@sprites["copy1"].disposed?
    @sprites["copy2"].dispose if @sprites["copy2"] && !@sprites["copy2"].disposed?
    @sprites["copy3"].dispose if @sprites["copy3"] && !@sprites["copy3"].disposed?
    @sprites["copy4"].dispose if @sprites["copy4"] && !@sprites["copy4"].disposed?
  end
  
  #================================================
  #================ Judge Grades =================
  #================================================
  def self.updateJudgeAnimations
    #=========================
    #===== Contestant 1 ======
    #=========================
    #only runs once when judged on a move
    if @chosenContestants[0][:DanceMoves][:gradeCountdown] == nil
      grade = @chosenContestants[0][:DanceMoves][:gradeValue]
      @sprites["gradeContestant1"].setBitmap("Graphics/Pictures/Contest/dance/#{grade}")
      @sprites["gradeContestant1"].opacity = 255
      @chosenContestants[0][:DanceMoves][:gradeCountdown] = (1*Graphics.frame_rate)
      
      streak = @chosenContestants[0][:DanceMoves][:gradeExcellentStreak]
      self.playJudgeSound(grade, streak)
      
    end #if @chosenContestants[0][:DanceMoves][:gradeCountdown] == nil
    
    #runs every frame until gradeValue is nil
    if @chosenContestants[0][:DanceMoves][:gradeValue] != nil
      if @chosenContestants[0][:DanceMoves][:gradeCountdown] > 0
        #subtract from the countdown until it reaches 0 or less
        @chosenContestants[0][:DanceMoves][:gradeCountdown] -= 1
      else
        #start disappearing until opacity is 0
        if @sprites["gradeContestant1"].opacity > 0
          @sprites["gradeContestant1"].opacity -= 17
        else
          #runs when the countdown is over and the grade has disappeared
          @chosenContestants[0][:DanceMoves][:gradeValue] == nil
        end #if @sprites["gradeContestant1"].opacity > 0
      end #if @chosenContestants[0][:DanceMoves][:gradeCountdown] > 0
    end #@chosenContestants[0][:DanceMoves][:gradeValue] != nil
    
    #=========================
    #===== Contestant 2 ======
    #=========================
    #only runs once when judged on a move
    if @chosenContestants[1][:DanceMoves][:gradeCountdown] == nil
      grade = @chosenContestants[1][:DanceMoves][:gradeValue]
      @sprites["gradeContestant2"].setBitmap("Graphics/Pictures/Contest/dance/#{grade}")
      @sprites["gradeContestant2"].opacity = 255
      @chosenContestants[1][:DanceMoves][:gradeCountdown] = (1*Graphics.frame_rate)
      
      streak = @chosenContestants[1][:DanceMoves][:gradeExcellentStreak]
      self.playJudgeSound(grade, streak)
      
    end #if @chosenContestants[1][:DanceMoves][:gradeCountdown] == nil
    
    #runs every frame until gradeValue is nil
    if @chosenContestants[1][:DanceMoves][:gradeValue] != nil
      if @chosenContestants[1][:DanceMoves][:gradeCountdown] > 0
        #subtract from the countdown until it reaches 0 or less
        @chosenContestants[1][:DanceMoves][:gradeCountdown] -= 1
      else
        #start disappearing until opacity is 0
        if @sprites["gradeContestant2"].opacity > 0
          @sprites["gradeContestant2"].opacity -= 17
        else
          #runs when the countdown is over and the grade has disappeared
          @chosenContestants[1][:DanceMoves][:gradeValue] == nil
        end #if @sprites["gradeContestant2"].opacity > 0
      end #if @chosenContestants[1][:DanceMoves][:gradeCountdown] > 0
    end #@chosenContestants[1][:DanceMoves][:gradeValue] != nil
    
    #=========================
    #===== Contestant 3 ======
    #=========================
    #only runs once when judged on a move
    if @chosenContestants[2][:DanceMoves][:gradeCountdown] == nil
      grade = @chosenContestants[2][:DanceMoves][:gradeValue]
      @sprites["gradeContestant3"].setBitmap("Graphics/Pictures/Contest/dance/#{grade}")
      @sprites["gradeContestant3"].opacity = 255
      @chosenContestants[2][:DanceMoves][:gradeCountdown] = (1*Graphics.frame_rate)
      
      streak = @chosenContestants[2][:DanceMoves][:gradeExcellentStreak]
      self.playJudgeSound(grade, streak)
      
    end #if @chosenContestants[2][:DanceMoves][:gradeCountdown] == nil
    
    #runs every frame until gradeValue is nil
    if @chosenContestants[2][:DanceMoves][:gradeValue] != nil
      if @chosenContestants[2][:DanceMoves][:gradeCountdown] > 0
        #subtract from the countdown until it reaches 0 or less
        @chosenContestants[2][:DanceMoves][:gradeCountdown] -= 1
      else
        #start disappearing until opacity is 0
        if @sprites["gradeContestant3"].opacity > 0
          @sprites["gradeContestant3"].opacity -= 17
        else
          #runs when the countdown is over and the grade has disappeared
          @chosenContestants[2][:DanceMoves][:gradeValue] == nil
        end #if @sprites["gradeContestant3"].opacity > 0
      end #if @chosenContestants[2][:DanceMoves][:gradeCountdown] > 0
    end #@chosenContestants[2][:DanceMoves][:gradeValue] != nil
    
    #=========================
    #===== Contestant 4 ======
    #=========================
    #only runs once when judged on a move
    if @chosenContestants[3][:DanceMoves][:gradeCountdown] == nil
      grade = @chosenContestants[3][:DanceMoves][:gradeValue]
      @sprites["gradeContestant4"].setBitmap("Graphics/Pictures/Contest/dance/#{grade}")
      @sprites["gradeContestant4"].opacity = 255
      @chosenContestants[3][:DanceMoves][:gradeCountdown] = (1*Graphics.frame_rate)
      
      streak = @chosenContestants[3][:DanceMoves][:gradeExcellentStreak]
      self.playJudgeSound(grade, streak)
      
    end #if @chosenContestants[3][:DanceMoves][:gradeCountdown] == nil
    
    #runs every frame until gradeValue is nil
    if @chosenContestants[3][:DanceMoves][:gradeValue] != nil
      if @chosenContestants[3][:DanceMoves][:gradeCountdown] > 0
        #subtract from the countdown until it reaches 0 or less
        @chosenContestants[3][:DanceMoves][:gradeCountdown] -= 1
      else
        #start disappearing until opacity is 0
        if @sprites["gradeContestant4"].opacity > 0
          @sprites["gradeContestant4"].opacity -= 17
        else
          #runs when the countdown is over and the grade has disappeared
          @chosenContestants[3][:DanceMoves][:gradeValue] == nil
        end #if @sprites["gradeContestant3"].opacity > 0
      end #if @chosenContestants[3][:DanceMoves][:gradeCountdown] > 0
    end #@chosenContestants[3][:DanceMoves][:gradeValue] != nil
        
  end #def self.updateJudgeAnimations
  
  def self.setGradeXYZoom
    case @dancerTurn
    when 1
      @chosenContestants[0][:DanceMoves][:gradeSpriteX] = @leadGradeX
      @chosenContestants[0][:DanceMoves][:gradeSpriteY] = @leadGradeY
      @chosenContestants[0][:DanceMoves][:gradeZoom] = @leadGradeZoom
      
      @chosenContestants[1][:DanceMoves][:gradeSpriteX] = @backLeftGradeX
      @chosenContestants[1][:DanceMoves][:gradeSpriteY] = @backGradeY
      @chosenContestants[1][:DanceMoves][:gradeZoom] = @backupGradeZoom
      
      @chosenContestants[2][:DanceMoves][:gradeSpriteX] = @backMiddleGradeX
      @chosenContestants[2][:DanceMoves][:gradeSpriteY] = @backGradeY
      @chosenContestants[2][:DanceMoves][:gradeZoom] = @backupGradeZoom
      
      @chosenContestants[3][:DanceMoves][:gradeSpriteX] = @backRightGradeX
      @chosenContestants[3][:DanceMoves][:gradeSpriteY] = @backGradeY
      @chosenContestants[3][:DanceMoves][:gradeZoom] = @backupGradeZoom
      
    when 2
      @chosenContestants[0][:DanceMoves][:gradeSpriteX] = @backRightGradeX
      @chosenContestants[0][:DanceMoves][:gradeSpriteY] = @backGradeY
      @chosenContestants[0][:DanceMoves][:gradeZoom] = @backupGradeZoom
      
      @chosenContestants[1][:DanceMoves][:gradeSpriteX] = @leadGradeX
      @chosenContestants[1][:DanceMoves][:gradeSpriteY] = @leadGradeY
      @chosenContestants[1][:DanceMoves][:gradeZoom] = @leadGradeZoom
      
      @chosenContestants[2][:DanceMoves][:gradeSpriteX] = @backLeftGradeX
      @chosenContestants[2][:DanceMoves][:gradeSpriteY] = @backGradeY
      @chosenContestants[2][:DanceMoves][:gradeZoom] = @backupGradeZoom
      
      @chosenContestants[3][:DanceMoves][:gradeSpriteX] = @backMiddleGradeX
      @chosenContestants[3][:DanceMoves][:gradeSpriteY] = @backGradeY
      @chosenContestants[3][:DanceMoves][:gradeZoom] = @backupGradeZoom
      
    when 3
      @chosenContestants[0][:DanceMoves][:gradeSpriteX] = @backMiddleGradeX
      @chosenContestants[0][:DanceMoves][:gradeSpriteY] = @backGradeY
      @chosenContestants[0][:DanceMoves][:gradeZoom] = @backupGradeZoom
      
      @chosenContestants[1][:DanceMoves][:gradeSpriteX] = @backRightGradeX
      @chosenContestants[1][:DanceMoves][:gradeSpriteY] = @backGradeY
      @chosenContestants[1][:DanceMoves][:gradeZoom] = @backupGradeZoom
      
      @chosenContestants[2][:DanceMoves][:gradeSpriteX] = @leadGradeX
      @chosenContestants[2][:DanceMoves][:gradeSpriteY] = @leadGradeY
      @chosenContestants[2][:DanceMoves][:gradeZoom] = @leadGradeZoom
      
      @chosenContestants[3][:DanceMoves][:gradeSpriteX] = @backLeftGradeX
      @chosenContestants[3][:DanceMoves][:gradeSpriteY] = @backGradeY
      @chosenContestants[3][:DanceMoves][:gradeZoom] = @backupGradeZoom
      
    when 4
      @chosenContestants[0][:DanceMoves][:gradeSpriteX] = @backLeftGradeX
      @chosenContestants[0][:DanceMoves][:gradeSpriteY] = @backGradeY
      @chosenContestants[0][:DanceMoves][:gradeZoom] = @backupGradeZoom
      
      @chosenContestants[1][:DanceMoves][:gradeSpriteX] = @backMiddleGradeX
      @chosenContestants[1][:DanceMoves][:gradeSpriteY] = @backGradeY
      @chosenContestants[1][:DanceMoves][:gradeZoom] = @backupGradeZoom
      
      @chosenContestants[2][:DanceMoves][:gradeSpriteX] = @backRightGradeX
      @chosenContestants[2][:DanceMoves][:gradeSpriteY] = @backGradeY
      @chosenContestants[2][:DanceMoves][:gradeZoom] = @backupGradeZoom
      
      @chosenContestants[3][:DanceMoves][:gradeSpriteX] = @leadGradeX
      @chosenContestants[3][:DanceMoves][:gradeSpriteY] = @leadGradeY
      @chosenContestants[3][:DanceMoves][:gradeZoom] = @leadGradeZoom
      
    end #case @dancerTurn
    
    @sprites["gradeContestant1"].x = @chosenContestants[0][:DanceMoves][:gradeSpriteX]
    @sprites["gradeContestant1"].y = @chosenContestants[0][:DanceMoves][:gradeSpriteY]
    @sprites["gradeContestant1"].zoom_x = @chosenContestants[0][:DanceMoves][:gradeZoom]
    @sprites["gradeContestant1"].zoom_y = @chosenContestants[0][:DanceMoves][:gradeZoom]
    
    @sprites["gradeContestant2"].x = @chosenContestants[1][:DanceMoves][:gradeSpriteX]
    @sprites["gradeContestant2"].y = @chosenContestants[1][:DanceMoves][:gradeSpriteY]
    @sprites["gradeContestant2"].zoom_x = @chosenContestants[1][:DanceMoves][:gradeZoom]
    @sprites["gradeContestant2"].zoom_y = @chosenContestants[1][:DanceMoves][:gradeZoom]
    
    @sprites["gradeContestant3"].x = @chosenContestants[2][:DanceMoves][:gradeSpriteX]
    @sprites["gradeContestant3"].y = @chosenContestants[2][:DanceMoves][:gradeSpriteY]
    @sprites["gradeContestant3"].zoom_x = @chosenContestants[2][:DanceMoves][:gradeZoom]
    @sprites["gradeContestant3"].zoom_y = @chosenContestants[2][:DanceMoves][:gradeZoom]
    
    @sprites["gradeContestant4"].x = @chosenContestants[3][:DanceMoves][:gradeSpriteX]
    @sprites["gradeContestant4"].y = @chosenContestants[3][:DanceMoves][:gradeSpriteY]
    @sprites["gradeContestant4"].zoom_x = @chosenContestants[3][:DanceMoves][:gradeZoom]
    @sprites["gradeContestant4"].zoom_y = @chosenContestants[3][:DanceMoves][:gradeZoom]
    
    #reset grade countdown
    @chosenContestants[0][:DanceMoves][:gradeCountdown] = 0
    @chosenContestants[1][:DanceMoves][:gradeCountdown] = 0
    @chosenContestants[2][:DanceMoves][:gradeCountdown] = 0
    @chosenContestants[3][:DanceMoves][:gradeCountdown] = 0
    
  end #def self.setGradeXYZoom
  
  #================================================
  #=============== Dancer Sprites ================
  #================================================
  def self.setContestantXY
    case @dancerTurn
    when 1
      @chosenContestants[0][:DanceMoves][:PkmnSpriteStartX] = @leadDancerX
      @chosenContestants[0][:DanceMoves][:PkmnSpriteStartY] = @leadDancerY
      @chosenContestants[1][:DanceMoves][:PkmnSpriteStartX] = @backupDancer1X
      @chosenContestants[1][:DanceMoves][:PkmnSpriteStartY] = @backupDancer1Y
      @chosenContestants[2][:DanceMoves][:PkmnSpriteStartX] = @backupDancer2X
      @chosenContestants[2][:DanceMoves][:PkmnSpriteStartY] = @backupDancer2Y
      @chosenContestants[3][:DanceMoves][:PkmnSpriteStartX] = @backupDancer3X
      @chosenContestants[3][:DanceMoves][:PkmnSpriteStartY] = @backupDancer3Y
       
    when 2
      @chosenContestants[0][:DanceMoves][:PkmnSpriteStartX] = @backupDancer3X
      @chosenContestants[0][:DanceMoves][:PkmnSpriteStartY] = @backupDancer3Y
      @chosenContestants[1][:DanceMoves][:PkmnSpriteStartX] = @leadDancerX
      @chosenContestants[1][:DanceMoves][:PkmnSpriteStartY] = @leadDancerY
      @chosenContestants[2][:DanceMoves][:PkmnSpriteStartX] = @backupDancer1X
      @chosenContestants[2][:DanceMoves][:PkmnSpriteStartY] = @backupDancer1Y
      @chosenContestants[3][:DanceMoves][:PkmnSpriteStartX] = @backupDancer2X
      @chosenContestants[3][:DanceMoves][:PkmnSpriteStartY] = @backupDancer2Y
      
    when 3
      @chosenContestants[0][:DanceMoves][:PkmnSpriteStartX] = @backupDancer2X
      @chosenContestants[0][:DanceMoves][:PkmnSpriteStartY] = @backupDancer2Y
      @chosenContestants[1][:DanceMoves][:PkmnSpriteStartX] = @backupDancer3X
      @chosenContestants[1][:DanceMoves][:PkmnSpriteStartY] = @backupDancer3Y
      @chosenContestants[2][:DanceMoves][:PkmnSpriteStartX] = @leadDancerX
      @chosenContestants[2][:DanceMoves][:PkmnSpriteStartY] = @leadDancerY
      @chosenContestants[3][:DanceMoves][:PkmnSpriteStartX] = @backupDancer1X
      @chosenContestants[3][:DanceMoves][:PkmnSpriteStartY] = @backupDancer1Y
      
    when 4
      @chosenContestants[0][:DanceMoves][:PkmnSpriteStartX] = @backupDancer1X
      @chosenContestants[0][:DanceMoves][:PkmnSpriteStartY] = @backupDancer1Y
      @chosenContestants[1][:DanceMoves][:PkmnSpriteStartX] = @backupDancer2X
      @chosenContestants[1][:DanceMoves][:PkmnSpriteStartY] = @backupDancer2Y
      @chosenContestants[2][:DanceMoves][:PkmnSpriteStartX] = @backupDancer3X
      @chosenContestants[2][:DanceMoves][:PkmnSpriteStartY] = @backupDancer3Y
      @chosenContestants[3][:DanceMoves][:PkmnSpriteStartX] = @leadDancerX
      @chosenContestants[3][:DanceMoves][:PkmnSpriteStartY] = @leadDancerY
    end #case @dancerTurn

    @chosenContestants[0][:DanceMoves][:PkmnSpriteCurrentX] = @chosenContestants[0][:DanceMoves][:PkmnSpriteStartX]
    @chosenContestants[0][:DanceMoves][:PkmnSpriteCurrentY] = @chosenContestants[0][:DanceMoves][:PkmnSpriteStartY]
    @chosenContestants[1][:DanceMoves][:PkmnSpriteCurrentX] = @chosenContestants[1][:DanceMoves][:PkmnSpriteStartX]
    @chosenContestants[1][:DanceMoves][:PkmnSpriteCurrentY] = @chosenContestants[1][:DanceMoves][:PkmnSpriteStartY]
    @chosenContestants[2][:DanceMoves][:PkmnSpriteCurrentX] = @chosenContestants[2][:DanceMoves][:PkmnSpriteStartX]
    @chosenContestants[2][:DanceMoves][:PkmnSpriteCurrentY] = @chosenContestants[2][:DanceMoves][:PkmnSpriteStartY]
    @chosenContestants[3][:DanceMoves][:PkmnSpriteCurrentX] = @chosenContestants[3][:DanceMoves][:PkmnSpriteStartX]
    @chosenContestants[3][:DanceMoves][:PkmnSpriteCurrentY] = @chosenContestants[3][:DanceMoves][:PkmnSpriteStartY]
  end #def self.setContestantXY
  
  def self.updateDancerSpriteMoving
    #run every frame and makes the sprites move when prompted
    #make the sin wave for the dancer to move on
    
    #===================================
    #======= Update Contestant 1 =======
    #===================================
    if !@chosenContestants[0][:DanceMoves][:DanceDirection].nil?
      @chosenContestants[0][:DanceMoves][:DanceSinWave] = Math.sin(@chosenContestants[0][:DanceMoves][:PkmnSpriteMoveTimer] * @moveSpeed) * @moveDistance
      
      case @chosenContestants[0][:DanceMoves][:DanceDirection]
      when "Front"
        @sprites["contestant1"].y = @chosenContestants[0][:DanceMoves][:PkmnSpriteStartY] + @chosenContestants[0][:DanceMoves][:DanceSinWave].abs.truncate
      when "Jump"
        @sprites["contestant1"].y = @chosenContestants[0][:DanceMoves][:PkmnSpriteStartY] - @chosenContestants[0][:DanceMoves][:DanceSinWave].abs.truncate
      when "Left"
        @sprites["contestant1"].x = @chosenContestants[0][:DanceMoves][:PkmnSpriteStartX] - @chosenContestants[0][:DanceMoves][:DanceSinWave].abs.truncate
      when "Right"
        @sprites["contestant1"].x = @chosenContestants[0][:DanceMoves][:PkmnSpriteStartX] + @chosenContestants[0][:DanceMoves][:DanceSinWave].abs.truncate
      end #case @chosenContestants[0][:DanceMoves][:DanceDirection]
      
      @chosenContestants[0][:DanceMoves][:PkmnSpriteMoveTimer] += 1
      
      #if the sin wave is < 0
      if @chosenContestants[0][:DanceMoves][:DanceSinWave] < 0
        #set the contestant's direction to nil to stop this code block
        @chosenContestants[0][:DanceMoves][:DanceDirection] = nil
        #set the contestant's X and Y back to the StartX and StartY
        @sprites["contestant1"].x = @chosenContestants[0][:DanceMoves][:PkmnSpriteStartX]
        @sprites["contestant1"].y = @chosenContestants[0][:DanceMoves][:PkmnSpriteStartY]
        #set the move timer back to 0
        @chosenContestants[0][:DanceMoves][:PkmnSpriteMoveTimer] = 0
      end #if @chosenContestants[0][:DanceMoves][:DanceSinWave] < 0
    end #if !@chosenContestants[0][:DanceMoves][:DanceDirection].nil?
    
    #===================================
    #======= Update Contestant 2 =======
    #===================================
    if !@chosenContestants[1][:DanceMoves][:DanceDirection].nil?
      @chosenContestants[1][:DanceMoves][:DanceSinWave] = Math.sin(@chosenContestants[1][:DanceMoves][:PkmnSpriteMoveTimer] * @moveSpeed) * @moveDistance
      
      case @chosenContestants[1][:DanceMoves][:DanceDirection]
      when "Front"
        @sprites["contestant2"].y = @chosenContestants[1][:DanceMoves][:PkmnSpriteStartY] + @chosenContestants[1][:DanceMoves][:DanceSinWave].abs.truncate
      when "Jump"
        @sprites["contestant2"].y = @chosenContestants[1][:DanceMoves][:PkmnSpriteStartY] - @chosenContestants[1][:DanceMoves][:DanceSinWave].abs.truncate
      when "Left"
        @sprites["contestant2"].x = @chosenContestants[1][:DanceMoves][:PkmnSpriteStartX] - @chosenContestants[1][:DanceMoves][:DanceSinWave].abs.truncate
      when "Right"
        @sprites["contestant2"].x = @chosenContestants[1][:DanceMoves][:PkmnSpriteStartX] + @chosenContestants[1][:DanceMoves][:DanceSinWave].abs.truncate
      end #case @chosenContestants[1][:DanceMoves][:DanceDirection]
      
      @chosenContestants[1][:DanceMoves][:PkmnSpriteMoveTimer] += 1
      
      #if the sin wave is < 0
      if @chosenContestants[1][:DanceMoves][:DanceSinWave] < 0
        #set the contestant's direction to nil to stop this code block
        @chosenContestants[1][:DanceMoves][:DanceDirection] = nil
        #set the contestant's X and Y back to the StartX and StartY
        @sprites["contestant2"].x = @chosenContestants[1][:DanceMoves][:PkmnSpriteStartX]
        @sprites["contestant2"].y = @chosenContestants[1][:DanceMoves][:PkmnSpriteStartY]
        #set the move timer back to 0
        @chosenContestants[1][:DanceMoves][:PkmnSpriteMoveTimer] = 0
      end #if @chosenContestants[1][:DanceMoves][:DanceSinWave] < 0
    end #if !@chosenContestants[1][:DanceMoves][:DanceDirection].nil?
    
    #===================================
    #======= Update Contestant 3 =======
    #===================================
    if !@chosenContestants[2][:DanceMoves][:DanceDirection].nil?
      @chosenContestants[2][:DanceMoves][:DanceSinWave] = Math.sin(@chosenContestants[2][:DanceMoves][:PkmnSpriteMoveTimer] * @moveSpeed) * @moveDistance
      
      case @chosenContestants[2][:DanceMoves][:DanceDirection]
      when "Front"
        @sprites["contestant3"].y = @chosenContestants[2][:DanceMoves][:PkmnSpriteStartY] + @chosenContestants[2][:DanceMoves][:DanceSinWave].abs.truncate
      when "Jump"
        @sprites["contestant3"].y = @chosenContestants[2][:DanceMoves][:PkmnSpriteStartY] - @chosenContestants[2][:DanceMoves][:DanceSinWave].abs.truncate
      when "Left"
        @sprites["contestant3"].x = @chosenContestants[2][:DanceMoves][:PkmnSpriteStartX] - @chosenContestants[2][:DanceMoves][:DanceSinWave].abs.truncate
      when "Right"
        @sprites["contestant3"].x = @chosenContestants[2][:DanceMoves][:PkmnSpriteStartX] + @chosenContestants[2][:DanceMoves][:DanceSinWave].abs.truncate
      end #case @chosenContestants[2][:DanceMoves][:DanceDirection]
      
      @chosenContestants[2][:DanceMoves][:PkmnSpriteMoveTimer] += 1
      
      #if the sin wave is < 0
      if @chosenContestants[2][:DanceMoves][:DanceSinWave] < 0
        #set the contestant's direction to nil to stop this code block
        @chosenContestants[2][:DanceMoves][:DanceDirection] = nil
        #set the contestant's X and Y back to the StartX and StartY
        @sprites["contestant3"].x = @chosenContestants[2][:DanceMoves][:PkmnSpriteStartX]
        @sprites["contestant3"].y = @chosenContestants[2][:DanceMoves][:PkmnSpriteStartY]
        #set the move timer back to 0
        @chosenContestants[2][:DanceMoves][:PkmnSpriteMoveTimer] = 0
      end #if @chosenContestants[2][:DanceMoves][:DanceSinWave] < 0
    end #if !@chosenContestants[2][:DanceMoves][:DanceDirection].nil?
    
    #===================================
    #========== Update Player ==========
    #===================================
    if !@chosenContestants[3][:DanceMoves][:DanceDirection].nil?
      @chosenContestants[3][:DanceMoves][:DanceSinWave] = Math.sin(@chosenContestants[3][:DanceMoves][:PkmnSpriteMoveTimer] * @moveSpeed) * @moveDistance
      case @chosenContestants[3][:DanceMoves][:DanceDirection]
      when "Front"
        @sprites["contestant4"].y = @chosenContestants[3][:DanceMoves][:PkmnSpriteStartY] + @chosenContestants[3][:DanceMoves][:DanceSinWave].abs.truncate
      when "Jump"
        @sprites["contestant4"].y = @chosenContestants[3][:DanceMoves][:PkmnSpriteStartY] - @chosenContestants[3][:DanceMoves][:DanceSinWave].abs.truncate
      when "Left"
        @sprites["contestant4"].x = @chosenContestants[3][:DanceMoves][:PkmnSpriteStartX] - @chosenContestants[3][:DanceMoves][:DanceSinWave].abs.truncate
      when "Right"
        @sprites["contestant4"].x = @chosenContestants[3][:DanceMoves][:PkmnSpriteStartX] + @chosenContestants[3][:DanceMoves][:DanceSinWave].abs.truncate
      end #case @chosenContestants[3][:DanceMoves][:DanceDirection]
      
      @chosenContestants[3][:DanceMoves][:PkmnSpriteMoveTimer] += 1
      
      #if the sin wave is < 0
      if @chosenContestants[3][:DanceMoves][:DanceSinWave] < 0
        #set the contestant's direction to nil to stop this code block
        @chosenContestants[3][:DanceMoves][:DanceDirection] = nil
        #set the contestant's X and Y back to the StartX and StartY
        @sprites["contestant4"].x = @chosenContestants[3][:DanceMoves][:PkmnSpriteStartX]
        @sprites["contestant4"].y = @chosenContestants[3][:DanceMoves][:PkmnSpriteStartY]
        #set the move timer back to 0
        @chosenContestants[3][:DanceMoves][:PkmnSpriteMoveTimer] = 0
      end #if @chosenContestants[3][:DanceMoves][:DanceSinWave] < 0
    end #if !@chosenContestants[3][:DanceMoves][:DanceDirection].nil?

  end #def self.updateDancerSpriteMoving
  
  #================================================
  #================ Star Sprites =================
  #================================================
  def self.updateStarAnimations
    @sprites["starsContestant1"].dispose if @sprites["starsContestant1"] && !@sprites["starsContestant1"].disposed? && @sprites["starsContestant1"].frame == 5
    @sprites["starsContestant2"].dispose if @sprites["starsContestant2"] && !@sprites["starsContestant2"].disposed? && @sprites["starsContestant2"].frame == 5
    @sprites["starsContestant3"].dispose if @sprites["starsContestant3"] && !@sprites["starsContestant3"].disposed? && @sprites["starsContestant3"].frame == 5
    @sprites["starsContestant4"].dispose if @sprites["starsContestant4"] && !@sprites["starsContestant4"].disposed? && @sprites["starsContestant4"].frame == 5
  end #def self.showStars(contestant)
  
end #class Dance