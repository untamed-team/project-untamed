class MidnightMotoristParameters
  attr_accessor :initialCarSpeed
  attr_accessor :finalCarSpeed
  attr_accessor :totalLines
  attr_accessor :MPH
  
  # Set the default values
  def initialize 
    @initialBallSpeed = 0
    @finalBallSpeed = 0
		@totalLines = 5
  end
  
  def carSpeed(ratio)
    return lerp(@initialCarSpeed, @finalCarSpeed, ratio) 
  end
end

class MidnightMotoristScene
  X_GAIN = 2
  Y_GAIN = 2
  MAX_MPH = 150
  MAX_ENEMY = 7
  MIN_ENEMY = 4
	#MOVE_SPEED = 0 #was 4
	
  def pbStartScene(parameters)
		$GameSpeed = 0
    pbMEStop
    pbBGSStop
    pbSEStop
    pbBGMFade(2.0)
    @params = parameters ? parameters : MidnightMotoristParameters.new
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/Midnight Motorist/midnightbg")
    @sprites["background"].x=(Graphics.width-@sprites["background"].bitmap.width)/2
    @sprites["background"].y=(Graphics.height-@sprites["background"].bitmap.height)/2
    @sprites["player"]=IconSprite.new(0,0,@viewport)
    @sprites["player"].setBitmap("Graphics/Pictures/Midnight Motorist/midnightplayer")
    @sprites["player"].x=70+@sprites["player"].bitmap.height/2 #85
    @sprites["player"].y=142-@sprites["player"].bitmap.height/2 #127
    @sprites["player"].z = 999999
		@playerXY=[@sprites["player"].x,@sprites["player"].y]
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["lifelayer"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @move_speed = 1
    @mph = 1
    @ballCount = 0
    @score=0
    @lap=1
    @LapLag=900
		@lapbreathroom=0
    @lifes=5
		@playerImmune = false
		@immuneTimer=0.0
    @flashTimer=0.0
    pbDrawText
		pbDrawLifes
    @enemydisapearX=Array.new(10)
		initializeEnemy(true)
		
		@sprites["number"]=IconSprite.new(0,0,@viewport)
		for i in 1..4
			@sprites["number"].setBitmap("Graphics/Pictures/Midnight Motorist/number_#{i}")
			@sprites["number"].z=999
			@sprites["number"].x=(Graphics.width-@sprites["number"].bitmap.width)/2
			@sprites["number"].y=(Graphics.height-@sprites["number"].bitmap.height)/2
      if i == 1
        pbSEPlay("Gear_Low",100)
      end
      if i == 2
        pbSEPlay("Gear_Mid",80)
      end
      if i == 3
        pbSEPlay("Gear_High",80)
      end
      if i == 4
        pbSEPlay("MidnightMotorist-CountdownGo",80)
      end
			pbWait(40)
		end
    @sprites["number"].visible=false
		
    pbBGMPlay("MidnightMotorist_BGM_Base")
    #~ pbFadeInAndShow(@sprites) { update }
  end
  
  def makeLapLine
    #if a lap line is not already on screen
    if !@sprites["lap"]
      #this is used to put the lap line on the level when appropriate
      @sprites["lap"]=IconSprite.new(0,0,@viewport)
      @sprites["lap"].setBitmap("Graphics/Pictures/Midnight Motorist/lap")
      @sprites["lap"].x=(Graphics.width)
      @sprites["lap"].y=(Graphics.height-@sprites["lap"].bitmap.height)/2
      @sprites["lap"].z=1
    end
  end
  
  def updateScore
    if @mph >= MAX_MPH
			@score += 1
    end
  end
  
  def updateMphMeter #update the mph meter
    if @mph < MAX_MPH
      #increase mph quickly until it reaches the defined maximum
      @mph += 0.5
    else
      #increase mph slowly if over the defined maximum
      @mph += 0.05 if @mph < 200
    end
  end
  
  def updateMoveSpeed
    #should change when MPH changes
    if @mph == 0
      @move_speed = 0
    elsif @mph >= 20 && @mph < 50
      @move_speed = 1
    elsif @mph >= 50 && @mph < 100
      @move_speed = 4
    elsif @mph >= 100 && @mph < 150
      @move_speed = 6
    elsif @mph >= 150
      @move_speed = 8
    end
    #if player is dead, set @move_speed to 0
  end
  
	def initializeEnemy(start)
		z = (start ? MIN_ENEMY : MAX_ENEMY)
    for i in 0..z
      if !@sprites["enemycar#{i}"]
        @sprites["enemycar#{i}"]=IconSprite.new(0,0,@viewport)
        @sprites["enemycar#{i}"].setBitmap("Graphics/Pictures/Midnight Motorist/midnightrando")
        @sprites["enemycar#{i}"].ox=@sprites["enemycar#{i}"].bitmap.width/2
        @sprites["enemycar#{i}"].oy=@sprites["enemycar#{i}"].bitmap.height/2
				randyrandomx = (start ? ((Graphics.width/2)..400).to_a.sample : (Graphics.width..(Graphics.width+300)).to_a.sample)
				randyrandomy=(30..356).to_a.sample
				@sprites["enemycar#{i}"].x=randyrandomx
				@sprites["enemycar#{i}"].y=randyrandomy
				@sprites["enemycar#{i}"].z=2
				@enemydisapearX[i]=(rand(-384..-256))
      end
    end
	end
	
  def pbDrawText
    overlay= @sprites["overlay"].bitmap
    @sprites["overlay"].z = 999999
    overlay.clear 
    lap=_INTL("LAP: {1}",@lap)
    score=_INTL("{1}",@score)
    mph=_INTL("MPH: {1}",@mph.round())
    baseColor=Color.new(248,248,248)
    shadowColor=Color.new(112,112,112)
    textPos=[[lap,10,18,false,baseColor,shadowColor]]
    textPos.push([score,Graphics.width-20,18,true,baseColor,shadowColor])
    textPos.push([mph,10,50,false,baseColor,shadowColor])
    pbDrawTextPositions(overlay,textPos)
  end
  
	def pbDrawLifes
    overlay=@sprites["lifelayer"].bitmap
    overlay.clear
    imagepos = []
    for i in 1..5
      img = i <= @lifes ? "Graphics/Pictures/Midnight Motorist/midnightlifes" : "Graphics/Pictures/Midnight Motorist/midnightlifes_empty"
      imagepos.push([img, 2 + i*10, 368, 0, 0, -1, -1])
    end
    
    pbDrawImagePositions(overlay,imagepos)
	end
	
  def updatePlayerPosition #by Gardenette
		if Input.press?(Input::LEFT)
			if @playerXY[0] >= 2
				@playerXY[0] -= @move_speed
				@playerXY[0] = 2 if @playerXY[0] <= 2
			end
    end
		if Input.press?(Input::RIGHT)
			if @playerXY[0] <= 368
				@playerXY[0] += @move_speed
				@playerXY[0] = 368 if @playerXY[0] >= 368
			end
		end
		if Input.press?(Input::UP)
			if @playerXY[1] >= 16
				@playerXY[1] -= @move_speed
				@playerXY[1] = 16 if @playerXY[1] <= 16
			end
    end
		if Input.press?(Input::DOWN)
			if @playerXY[1] <= 338
				@playerXY[1] += @move_speed
				@playerXY[1] = 338 if @playerXY[1] >= 338
			end
		end
		
		@sprites["player"].x=@playerXY[0]
		@sprites["player"].y=@playerXY[1]
  end
  
  def pbPlayerImmune
  	@playerImmune=true
    @immuneTimer=0.0
    #print "immune"
  end
  
  def updateImmunity
    #check for player immunity
		if @playerImmune && @sprites["player"]
			@immuneTimer += Graphics.delta_s
			if @immuneTimer >= 3.0 #3 second timer
				@immuneTimer=0.0
				#print "not immune"
				@playerImmune=false
				@sprites["player"].visible=true
			end
		end #of @playerImmune
  end
  
  def pbPlayerFlash
    @sprites["player"].visible=false
    @flashTimer=0.0
  end
	
  def updateFlash
    @flashTimer += Graphics.delta_s
    if @flashTimer >= 0.2
      if @sprites["player"].visible == true
        @sprites["player"].visible=false
      else
        @sprites["player"].visible=true
      end
      @flashTimer=0.0
    end #@flashTimer >= 1.0
  end #def updateFlash
  
	def checkPlayerCollision
		if @sprites["player"]
			for i in 0..MAX_ENEMY
				if @sprites["enemycar#{i}"] && !@playerimmune
					if collides_with?(@sprites["player"],@sprites["enemycar#{i}"]) && !@playerImmune
						pbDisposeSprite(@sprites, "enemycar#{i}")
						@lifes-=1
						@mph=0
						updateMoveSpeed
						pbSEPlay("GUI sel buzzer",70)
            pbPlayerImmune
            pbPlayerFlash
					end
				end
			end
			if @sprites["lap"]
				if collides_with?(@sprites["player"],@sprites["lap"])
					@lap+=1
					@score+=(100+(2^(@lap/50).round))
					@lapbreathroom=20
					pbSEPlay("Mining found all",70)
					pbDisposeSprite(@sprites, "lap")
					for i in 0..MAX_ENEMY
						if @sprites["enemycar#{i}"]
							@sprites["enemycar#{i}"].y+=Graphics.height
						end
					end
				end
			end
		end
	end
	
	def collides_with?(player,object)
		if (object.x + object.width  >= player.x) && (object.x <= player.x + player.width) &&
			 (object.y + object.height >= player.y) && (object.y <= player.y + player.height)
			return true
		end
	end
	
  def update
    pbUpdateSpriteHash(@sprites)
  end
	
  def pbMain
		loop do
			Input.update
			updatePlayerPosition
      Graphics.update
      self.update
			checkPlayerCollision
			pbDrawLifes
      updateMphMeter
      updateMoveSpeed
      updateScore
      pbDrawText
			initializeEnemy(false) if @lapbreathroom==0
      updateImmunity if @playerImmune
      updateFlash if @playerImmune
      
			for i in 0..MAX_ENEMY
				if @sprites["enemycar#{i}"]
					@sprites["enemycar#{i}"].x -= (rand(5) + @move_speed)
					if @sprites["enemycar#{i}"].x < @enemydisapearX[i]
						pbDisposeSprite(@sprites, "enemycar#{i}")
					end
				end
			end
			if @sprites["background"].x <= -384
        #reset background
        @sprites["background"].x = -256
      else
        #move background left
        @sprites["background"].x-=@move_speed
        @sprites["lap"].x-=@move_speed if @sprites["lap"]
      end
			if @LapLag < 0
				makeLapLine
				@LapLag+=(700+(@lap*55))
			end
      #if the sprite goes off screen, dispose of it
      if @sprites["lap"] && @sprites["lap"].x < -180
        pbDisposeSprite(@sprites, "lap")
      end
			if Input.trigger?(Input::BACK)
        if pbConfirmMessage("Are you sure you want to quit?")
					pbBGMStop
          break
        end
			end
      if @lifes<=0
				pbBGMStop
				@sprites["number"].visible=true
				@sprites["number"].setBitmap("Graphics/Pictures/Midnight Motorist/number_5")
				pbWait(60)
				coinscalc = ((@score/100)+2^@lap)
				if coinscalc>1
					$player.coins += coinscalc
					pbMessage(_INTL("You recieved {1} coins.",coinscalc))
				end
        break
      end
			@LapLag-=1 #if @mph >= MAX_MPH
			@lapbreathroom-=1 if @lapbreathroom > 0
		end #of loop do under pbMain
    return @score
  end #of pbMain
	
  def pbEndScene
    $game_map.autoplay
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end


class MidnightMotorist
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen(parameters)
    @scene.pbStartScene(parameters)
    @scene.pbMain
    @scene.pbEndScene
  end
end

def pbMidnightMotorist(parameters = nil)
  ret = nil
  pbFadeOutIn(99999) { 
    scene=MidnightMotoristScene.new
    screen=MidnightMotorist.new(scene)
    ret = screen.pbStartScreen(parameters)
  }
  return ret
end