class DressupReveal
  
  def self.setStage(contestant)
    #initialize graphics
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/Contest/dressup/reveal_background")
    @sprites["background"].x = 0
    @sprites["background"].y = 0
    @sprites["background"].z = 99996
    
    @sprites["crowd"] = IconSprite.new(0, 0, @viewport)
    @sprites["crowd"].setBitmap("Graphics/Pictures/Contest/dressup/reveal_crowd")
    @sprites["crowd"].x = 0
    @sprites["crowd"].y = Graphics.height/2
    @sprites["crowd"].z = 99998
    
    @sprites["curtain"] = IconSprite.new(0, 0, @viewport)
    @sprites["curtain"].setBitmap("Graphics/Pictures/Contest/dressup/reveal_curtain")
    @sprites["curtain"].x = 0
    @sprites["curtain"].y = 0
    @sprites["curtain"].z = 99997
    
    #the value 'contestant' that is passed into this method is an integer telling
    #the method which contestant to load
    
    #load contestant graphic behind curtain
    @sprites["contestant"] = IconSprite.new(0, 0, @viewport)
    
    if contestant == @playerPkmn
      @sprites["contestant"].setBitmap("Graphics/Pictures/Contest/dressup/contestants/#{$player.id}.png")
    else
      @sprites["contestant"].setBitmap("Graphics/Pictures/Contest/dressup/contestants/#{@chosenRank}/#{contestant}")
    end
    
    @sprites["contestant"].x = Graphics.width/2 - @sprites["contestant"].width/2
    @sprites["contestant"].y = 10
    @sprites["contestant"].z = 99996
  end
  
  def self.whiteFade
    #play crowd cheering se
    pbSEPlay("Contests_Crowd",80,100)
    
    pbWait(1 * Graphics.frame_rate/2)
    loop do
      @sprites["white_fade"].opacity -= 15
      pbWait(1 * Graphics.frame_rate/8)
      break if @sprites["white_fade"].opacity <= 0
    end
  end
  
  def self.pullCurtain
    pbSEPlay("Contests_Start",80,100)
    pbWait(1 * Graphics.frame_rate/2)
    pbSEPlay("Contests_Dressup_Apply_Backdrop",100,100)
    loop do
      @sprites["curtain"].y -= 5
      pbWait(1 * Graphics.frame_rate/32)
      break if @sprites["curtain"].y <= (@sprites["curtain"].height * - 1)
    end
  end
  
  def self.dropCurtain
    loop do
      @sprites["curtain"].y += 5
      pbWait(1 * Graphics.frame_rate/32)
      break if @sprites["curtain"].y >= 0
    end
  end
  
  def self.getDressupHearts(contestant)
    #dressup hearts are pink
    dressup_points = contestant[:DressupPoints]
    dressup_hearts = 0
    
    #number of hearts increases with rank, and there does not appear to be a
    #multiplier with the way DPPT did this scoring
    case @chosenRank
    when "Normal"
      dressup_hearts = 1 if dressup_points >= 1 && dressup_points <= 2
      dressup_hearts = 2 if dressup_points >= 3 && dressup_points <= 4
      dressup_hearts = 3 if dressup_points >= 5 && dressup_points <= 7
      dressup_hearts = 4 if dressup_points >= 8
    when "Great"
      dressup_hearts = 1 if dressup_points >= 1 && dressup_points <= 4
      dressup_hearts = 2 if dressup_points >= 5 && dressup_points <= 9
      dressup_hearts = 3 if dressup_points >= 10 && dressup_points <= 14
      dressup_hearts = 4 if dressup_points >= 15
    when "Ultra"
      dressup_hearts = 1 if dressup_points >= 1 && dressup_points <= 6
      dressup_hearts = 2 if dressup_points >= 7 && dressup_points <= 14
      dressup_hearts = 3 if dressup_points >= 15 && dressup_points <= 22
      dressup_hearts = 4 if dressup_points >= 23
    when "Master"
      dressup_hearts = 1 if dressup_points >= 1 && dressup_points <= 9
      dressup_hearts = 2 if dressup_points >= 10 && dressup_points <= 19
      dressup_hearts = 3 if dressup_points >= 20 && dressup_points <= 29
      dressup_hearts = 4 if dressup_points >= 30
    end
    
    return dressup_hearts
  end #def self.getDressupHearts(contestant)
  
  def self.getConditionHearts(contestant)
    #condition hearts are red
    condition_points = contestant[:ConditionPoints]
    condition_hearts = 0
    
    #number of hearts increases with rank, and there does not appear to be a
    #multiplier with the way DPPT did this scoring
    case @chosenRank
    when "Normal"
      condition_hearts = 1 if condition_points >= 10 && condition_points < 20
      condition_hearts = 2 if condition_points >= 20 && condition_points < 30
      condition_hearts = 3 if condition_points >= 30 && condition_points < 40
      condition_hearts = 4 if condition_points >= 40 && condition_points < 50
      condition_hearts = 5 if condition_points >= 50 && condition_points < 60
      condition_hearts = 6 if condition_points >= 60 && condition_points < 70
      condition_hearts = 7 if condition_points >= 70 && condition_points < 80
      condition_hearts = 8 if condition_points >= 80
    when "Great"
      condition_hearts = 1 if condition_points >= 90 && condition_points < 110
      condition_hearts = 2 if condition_points >= 110 && condition_points < 130
      condition_hearts = 3 if condition_points >= 130 && condition_points < 150
      condition_hearts = 4 if condition_points >= 150 && condition_points < 170
      condition_hearts = 5 if condition_points >= 170 && condition_points < 190
      condition_hearts = 6 if condition_points >= 190 && condition_points < 210
      condition_hearts = 7 if condition_points >= 210 && condition_points < 230
      condition_hearts = 8 if condition_points >= 230
    when "Ultra"
      condition_hearts = 1 if condition_points >= 170 && condition_points < 200
      condition_hearts = 2 if condition_points >= 200 && condition_points < 230
      condition_hearts = 3 if condition_points >= 230 && condition_points < 260
      condition_hearts = 4 if condition_points >= 260 && condition_points < 290
      condition_hearts = 5 if condition_points >= 290 && condition_points < 320
      condition_hearts = 6 if condition_points >= 320 && condition_points < 350
      condition_hearts = 7 if condition_points >= 350 && condition_points < 380
      condition_hearts = 8 if condition_points >= 380
    when "Master"
      condition_hearts = 1 if condition_points >= 320 && condition_points < 360
      condition_hearts = 2 if condition_points >= 360 && condition_points < 400
      condition_hearts = 3 if condition_points >= 400 && condition_points < 440
      condition_hearts = 4 if condition_points >= 440 && condition_points < 480
      condition_hearts = 5 if condition_points >= 480 && condition_points < 520
      condition_hearts = 6 if condition_points >= 520 && condition_points < 560
      condition_hearts = 7 if condition_points >= 560 && condition_points < 600
      condition_hearts = 8 if condition_points >= 600
    end
    
    return condition_hearts
  end #def self.getConditionHearts(contestant)
  
  def self.displayHearts(contestant)
    #this will be used for showing hearts
    dressup_hearts = self.getDressupHearts(contestant)
    condition_hearts = self.getConditionHearts(contestant)
    
    condition_hearts_left = condition_hearts
    dressup_hearts_left = dressup_hearts
    
    i = 0
    timer = 1 * (Graphics.frame_rate/6)
    heart_kind = "condition"
    loop do
      Graphics.update
      self.update
      if timer == 1 * (Graphics.frame_rate/6)
        
      should_switch = true
        
        #when the timer is reset, display the next heart
        if condition_hearts_left > 0 && heart_kind == "condition"
          @sprites["heart#{i}"] = AnimatedSprite.new("Graphics/Pictures/Contest/dressup/condition_heart_animation", 30, 45, 82, 0, @viewport)
          condition_hearts_left -= 1
        end
        
        if dressup_hearts_left > 0 && heart_kind == "dressup"
          @sprites["heart#{i}"] = AnimatedSprite.new("Graphics/Pictures/Contest/dressup/dressup_heart_animation", 30, 45, 82, 0, @viewport)
          dressup_hearts_left -= 1
        end
        
        #choose a position for the next heart to appear
        randX = rand(@crowdAreaX[0]..@crowdAreaX[1])
        randY = rand(@crowdAreaY[0]..@crowdAreaY[1])
        
        if @sprites["heart#{i}"]
          @sprites["heart#{i}"].play
          @sprites["heart#{i}"].x = randX
          @sprites["heart#{i}"].y = randY - @sprites["heart#{i}"].height
          @sprites["heart#{i}"].z = 99999
          pbSEPlay("Contests_Heart",100,100)
          i += 1
        end
      end
      timer -= 1
      timer = 1 * (Graphics.frame_rate/6) if timer <= 0
      
      #search for up to 12 heart sprites (12 is the max amount of condition
      #hearts and dressup hearts that should ever be on the screen)
      for j in 0..11
        #dispose of them once they reach frame 29
        if @sprites["heart#{j}"] && @sprites["heart#{j}"].frame == 29
          @sprites["heart#{j}"].dispose
        end
      end
      
      #before looping back around to show the next heart, change the kind of
      #heart that will show next
      if heart_kind == "condition" && should_switch == true
        if dressup_hearts_left > 0
          heart_kind = "dressup" 
          should_switch = false
        end
      end
      
      if heart_kind == "dressup" && should_switch == true
        if condition_hearts_left > 0
          heart_kind = "condition" 
          should_switch = false
        end
      end

      break if condition_hearts_left <= 0 && dressup_hearts_left <= 0
    end
    
    #one more loop to finish off the hearts that are still floating around
    loop do
      Graphics.update
      self.update
      #search for up to 12 heart sprites (12 is the max amount of condition
      #hearts and dressup hearts that should ever be on the screen)
      for j in 0..11
        #dispose of them once they reach frame 29
        if @sprites["heart#{j}"] && @sprites["heart#{j}"].frame == 29
          @sprites["heart#{j}"].dispose
        end #if @sprites["heart#{j}"] && @sprites["heart#{j}"].frame == 29
      end #for j in 0..11
      
      total_hearts = dressup_hearts + condition_hearts
      last_heart = total_hearts - 1
      break if total_hearts <= 0
      break if @sprites["heart#{last_heart}"].disposed?
      
    end #loop do
      
    pbWait(2 * Graphics.frame_rate)
  end #self.displayHearts(contestant)
  
end #class DressupReveal