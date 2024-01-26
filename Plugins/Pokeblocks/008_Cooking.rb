class CookingStage1
	include BopModule

	STAGE_TIMER_SECONDS = 30
	BURN_TIMER_SECONDS = 5

	def initialize
		if !$bag.hasAnyBerry?
			pbMessage(_INTL("You don't have any berries!"))
			return
		end
	
		@sprites = {}
		@viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
		@viewport.z = 99999
	
		#Graphics
		@sprites["pot_upper"] = IconSprite.new(0, 0, @viewport)
		@sprites["pot_upper"].setBitmap("Graphics/Pictures/Pokeblock/Candy Making/stewpot_base_upper - large")
		@sprites["pot_upper"].x = Graphics.width/2 - @sprites["pot_upper"].width/2
		@sprites["pot_upper"].y = 70
		@sprites["pot_upper"].z = 99999
		
		@sprites["pot_lower"] = IconSprite.new(0, 0, @viewport)
		@sprites["pot_lower"].setBitmap("Graphics/Pictures/Pokeblock/Candy Making/stewpot_base_lower - large")
		@sprites["pot_lower"].x = Graphics.width/2 - @sprites["pot_lower"].width/2
		@sprites["pot_lower"].y = 70
		#always on top of the spoon when submerged
		@sprites["pot_lower"].z = 999999
		
		@sprites["stove"] = IconSprite.new(0, 0, @viewport)
		@sprites["stove"].setBitmap("Graphics/Pictures/Pokeblock/Candy Making/stove - large")
		@sprites["stove"].x = Graphics.width/2 - @sprites["stove"].width/2
		@sprites["stove"].y = @sprites["pot_upper"].y + 160
		@sprites["stove"].z = 99998
		
		@sprites["candy_base"] = IconSprite.new(0, 0, @viewport)
		@sprites["candy_base"].setBitmap("Graphics/Pictures/Pokeblock/Candy Making/candy_base_in_pot")
		@sprites["candy_base"].x = Graphics.width/2 - @sprites["candy_base"].width/2
		@sprites["candy_base"].y = 70
		@sprites["candy_base"].z = 99999
		@sprites["candy_base"].visible = false
		
		@sprites["spoon"] = IconSprite.new(0, 0, @viewport)
		@sprites["spoon"].setBitmap("Graphics/Pictures/Pokeblock/Candy Making/spoon")
		@sprites["spoon"].x = Graphics.width/2 - @sprites["spoon"].width/2
		@sprites["spoon"].y = 0
		@sprites["spoon"].z = 999999
		@lastX = Graphics.width/2 - @sprites["spoon"].width/2
		@lastY = 0
		
		@edgeOfPotLeft = @sprites["pot_lower"].x + (83+@sprites["spoon"].width/2)
		@edgeOfPotRight = @sprites["pot_lower"].x + @sprites["pot_lower"].width - (83+@sprites["spoon"].width/2)
		@edgeOfPotTop = @sprites["pot_lower"].y + 50
		@edgeOfPotBottom = @sprites["pot_lower"].y + 270
		
		@sprites["boundaries"] = IconSprite.new(0, 0, @viewport)
		@sprites["boundaries"].setBitmap("Graphics/Pictures/Pokeblock/Candy Making/stewpot_stirring_boundaries")
		@sprites["boundaries"].x = @sprites["pot_upper"].x
		@sprites["boundaries"].y = @sprites["pot_upper"].y
		@sprites["boundaries"].z = 99999999
		@sprites["boundaries"].visible = false
		
		@sprites["boundaryQ1"] = IconSprite.new(0, 0, @viewport)
		@sprites["boundaryQ1"].setBitmap("Graphics/Pictures/Pokeblock/Candy Making/boundary_quadrant1")
		@sprites["boundaryQ1"].x = @sprites["pot_upper"].x
		@sprites["boundaryQ1"].y = @sprites["pot_upper"].y
		@sprites["boundaryQ1"].z = 99999999
		@sprites["boundaryQ1"].visible = false
		
		@sprites["boundaryQ2"] = IconSprite.new(0, 0, @viewport)
		@sprites["boundaryQ2"].setBitmap("Graphics/Pictures/Pokeblock/Candy Making/boundary_quadrant2")
		@sprites["boundaryQ2"].x = @sprites["pot_upper"].x
		@sprites["boundaryQ2"].y = @sprites["pot_upper"].y
		@sprites["boundaryQ2"].z = 99999999
		@sprites["boundaryQ2"].visible = false
		
		@sprites["boundaryQ3"] = IconSprite.new(0, 0, @viewport)
		@sprites["boundaryQ3"].setBitmap("Graphics/Pictures/Pokeblock/Candy Making/boundary_quadrant3")
		@sprites["boundaryQ3"].x = @sprites["pot_upper"].x
		@sprites["boundaryQ3"].y = @sprites["pot_upper"].y
		@sprites["boundaryQ3"].z = 99999999
		@sprites["boundaryQ3"].visible = false
		
		@sprites["boundaryQ4"] = IconSprite.new(0, 0, @viewport)
		@sprites["boundaryQ4"].setBitmap("Graphics/Pictures/Pokeblock/Candy Making/boundary_quadrant4")
		@sprites["boundaryQ4"].x = @sprites["pot_upper"].x
		@sprites["boundaryQ4"].y = @sprites["pot_upper"].y
		@sprites["boundaryQ4"].z = 99999999
		@sprites["boundaryQ4"].visible = false
		
		@sprites["stirDirectionArrow"] = IconSprite.new(0, 0, @viewport)
		@sprites["stirDirectionArrow"].setBitmap("Graphics/Pictures/Pokeblock/Candy Making/arrow_left")
		@sprites["stirDirectionArrow"].x = Graphics.width/2 - @sprites["stirDirectionArrow"].width/2
		@sprites["stirDirectionArrow"].y = Graphics.height/2 - @sprites["stirDirectionArrow"].height/4 - 16
		@sprites["stirDirectionArrow"].z = 99999
		@sprites["stirDirectionArrow"].visible = false
		
		@lastQuadrant = nil
		@currentQuadrant = nil
		@quadrantsStirredIn = []
		@requiredStirDir = nil
		@playerStirDir = nil
		@stageTimer = Graphics.frame_rate * STAGE_TIMER_SECONDS
		@burnTimer = Graphics.frame_rate * BURN_TIMER_SECONDS
		@arrowBlinkTimer = 0
		
		pbmain
	end #def initialize
	
	def stirArrowBlink
		case @arrowBlinkTimer
		when Graphics.frame_rate*3
			@sprites["stirDirectionArrow"].visible = true
		when Graphics.frame_rate*2.5
			@sprites["stirDirectionArrow"].visible = false
		when Graphics.frame_rate*2
			@sprites["stirDirectionArrow"].visible = true
		when Graphics.frame_rate*1.5
			@sprites["stirDirectionArrow"].visible = false
		when Graphics.frame_rate*1
			@sprites["stirDirectionArrow"].visible = true
		when Graphics.frame_rate*0.5
			@sprites["stirDirectionArrow"].visible = false
		end #case @arrowBlinkTimer
	end #def stirArrowBlink
	
	def decideStirDir
		dir = rand(1..2)
		case dir
		when 1
			@requiredStirDir = "left"
			@sprites["stirDirectionArrow"].setBitmap("Graphics/Pictures/Pokeblock/Candy Making/arrow_left")
		when 2
			@requiredStirDir = "right"
			@sprites["stirDirectionArrow"].setBitmap("Graphics/Pictures/Pokeblock/Candy Making/arrow_right")
		end #case dir
		
		@arrowBlinkTimer = Graphics.frame_rate * 3
	end #def decideStirDir
	
	def outOfBounds?
		return true if !Mouse.over_pixel?(@sprites["boundaries"])
		return false
	end
	
	def updateCursorPos
		@lastX = @sprites["spoon"].x
		@lastY = @sprites["spoon"].y
		
		#if the mouse leaves the game window, put the spoon at its last X and Y rather than in the top left of the screen
		if !System.mouse_in_window
			@sprites["spoon"].x = @lastX
			@sprites["spoon"].y = @lastY
		elsif outOfBounds? && @spoonSubmerged #if the cursor goes outside of what's allowed for stirring and they are currently stirring, don't follow the cursor
			@sprites["spoon"].x = @lastX
			@sprites["spoon"].y = @lastY
		else
			@sprites["spoon"].x=Mouse.x-@sprites["spoon"].width/2 if defined?(Mouse.x)
			@sprites["spoon"].y=Mouse.y-@sprites["spoon"].height+40 if defined?(Mouse.y)
		end
	end #updateCursorPos
	
	def detectStirDirection
		@lastQuadrant = @currentQuadrant
		getCurrentQuandrant
		if @currentQuadrant != @lastQuadrant #needed so this doesn't invalidate the stir if staying still in the same quadrant
			#detect whether we've gone completely around the pot
			if @quadrantsStirredIn.include?(@currentQuadrant) && @quadrantsStirredIn.length >= 4 && @quadrantsStirredIn[0] == @currentQuadrant #complete circle
				stirCompleted
			elsif @quadrantsStirredIn.include?(@currentQuadrant)
				#if we've already been in this quadrant before completing a stir around the pot, we have not gone in a circle, and the array should start over with this quadrant
				@quadrantsStirredIn = [@currentQuadrant]
			elsif !@quadrantsStirredIn.include?(@currentQuadrant)
				#if we weren't in this quadrant during this stir around the pot, add the quadrant number to the array of quadrants we've been through
				@quadrantsStirredIn.push(@currentQuadrant)
			end #if @quadrantsStirredIn.include?(@currentQuadrant)
		end #if @currentQuadrant != @lastQuadrant
	end #detectStirDirection
	
	def stirCompleted
		case @quadrantsStirredIn[0]
		when 1
			if @quadrantsStirredIn[1] == 2
				@playerStirDir = "right"
			else
				@playerStirDir = "left"
			end
		when 2
			if @quadrantsStirredIn[1] == 3
				@playerStirDir = "right"
			else
				@playerStirDir = "left"
			end
		when 3
			if @quadrantsStirredIn[1] == 4
				@playerStirDir = "right"
			else
				@playerStirDir = "left"
			end
		when 4
			if @quadrantsStirredIn[1] == 1
				@playerStirDir = "right"
			else
				@playerStirDir = "left"
			end
		end #case @quadrantsStirredIn[0]
				
		#if stirred the correct direction
		if @requiredStirDir == @playerStirDir
			#play chime to let player know a stir was complete
			pbSEPlay("Mining reveal")
			#change stir direction since the stir was completed
			decideStirDir
			#reset burn timer
			@burnTimer = BURN_TIMER_SECONDS * Graphics.frame_rate
		end #if @requiredStirDir == @playerStirDir
	end #def stirCompleted
	
	def getCurrentQuandrant
		#get the current quadrant the spoon is submerged in
		@currentQuadrant = 1 if Mouse.over_pixel?(@sprites["boundaryQ1"])
		@currentQuadrant = 2 if Mouse.over_pixel?(@sprites["boundaryQ2"])
		@currentQuadrant = 3 if Mouse.over_pixel?(@sprites["boundaryQ3"])
		@currentQuadrant = 4 if Mouse.over_pixel?(@sprites["boundaryQ4"])
	end #getCurrentQuandrant
	
	def submergeSpoon
		@spoonSubmerged = true
		@sprites["spoon"].setBitmap("Graphics/Pictures/Pokeblock/Candy Making/spoon_ submerged")
		@sprites["spoon"].z = 99999
		#getCurrentQuandrant
	end #def submergeSpoon
	
	def pullSpoon
		@spoonSubmerged = false
		@sprites["spoon"].setBitmap("Graphics/Pictures/Pokeblock/Candy Making/spoon")
		@sprites["spoon"].z = 999999
		
		#clear the current quadrant the spoon was submerged in
		@currentQuadrant = nil
		#clear the history of quadrants stirred in since we're starting over with stirring
		@quadrantsStirredIn = []
	end #def pullSpoon
	
	def detectInput
		if Mouse.press? && !outOfBounds?
			submergeSpoon
			detectStirDirection
		end #if Mouse.press?
		if Input.release?(Input::MOUSELEFT)
			pullSpoon
		end #Input.release?(Input::MOUSELEFT)
		
		detectStirDirection if @submerged
	end #detectInput
	
	def burnedNotif
		print "you burned the mixture"
		@burnTimer = BURN_TIMER_SECONDS * Graphics.frame_rate
	end #def burnedNotif
	
	
	
	
	
	
	
	
	
	def pbmain		
		#pbMessage(_INTL("Adding candy base"))
		@sprites["candy_base"].visible = true
		Graphics.update
		pbUpdateSpriteHash(@sprites)
		
		pbWait(1*Graphics.frame_rate)
		
		#add berries
		pbMessage(_INTL("Select some berries from your bag to put in the pot."))
		@berries = BerryPoffin.pbPickBerryForBlenderSimple
		
		#print "no berry selected" if @berries.nil? || @berries.empty?
		#then exit cooking
		
		animationBerry(@berries)
		
		#pbBerryBlenderSimple
		
		#decide initial stir direction
		decideStirDir
		
		loop do
			Graphics.update
			Input.update
			updateCursorPos
			pbUpdateSpriteHash(@sprites)
			detectInput
			
			stirArrowBlink if @arrowBlinkTimer > 0
			@arrowBlinkTimer -= 1
			
			burnedNotif if @burnTimer <= 0
			@burnTimer -= 1
			break if @stageTimer <= 0
			@stageTimer -= 1
		end #loop do
		print "stage1 done"
	end
end #class CookingStage1

class CookingStage2
	def initialize
		@sprites = {}
		@viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
		@viewport.z = 99999
	
		#Graphics
		@sprites["firewood"] = IconSprite.new(0, 0, @viewport)
		@sprites["firewood"].setBitmap("Graphics/Pictures/Pokeblock/Candy Making/firewood")
		@sprites["firewood"].x = Graphics.width/2 - @sprites["firewood"].width/2
		@sprites["firewood"].y = Graphics.height/2
		@sprites["firewood"].z = 99999
		
		#animname, framecount, framewidth, frameheight, frameskip
		@sprites["fire"] = AnimatedSprite.new("Graphics/Pictures/Pokeblock/Candy Making/fire_anim",3,274,201,4,@viewport)
		@sprites["fire"].x = @sprites["firewood"].x + @sprites["firewood"].width/2 - @sprites["fire"].width/4
		@sprites["fire"].y = @sprites["firewood"].y + @sprites["firewood"].height/2 - @sprites["fire"].height/3
		@sprites["fire"].z = 99999
		@sprites["fire"].zoom_x = 0.5
		@sprites["fire"].zoom_y = 0.5
		@sprites["fire"].play
		
		@sprites["stove"] = IconSprite.new(0, 0, @viewport)
		@sprites["stove"].setBitmap("Graphics/Pictures/Pokeblock/Candy Making/stove")
		@sprites["stove"].x = Graphics.width/2 - @sprites["stove"].width/2
		@sprites["stove"].y = @sprites["firewood"].y - @sprites["stove"].height/3
		@sprites["stove"].z = 99999
		
		@sprites["pot"] = IconSprite.new(0, 0, @viewport)
		@sprites["pot"].setBitmap("Graphics/Pictures/Pokeblock/Candy Making/stewpot_base")
		@sprites["pot"].x = Graphics.width/2 - @sprites["pot"].width/2
		@sprites["pot"].y = @sprites["stove"].y - 80
		@sprites["pot"].z = 99999
		
		pbmain
	end #def initialize
	
	def pbmain
		loop do
			Graphics.update
			pbUpdateSpriteHash(@sprites)
		end #loop do
	end
end #class CookingStage2

#########################
#From Pokeblock Script
#########################
def animationBerry(berries)
		b=[true,true,true,true]; x0=[]; y0=[]; d=[rand(10),rand(10),rand(10),rand(10)]
		berries.each_with_index { |berry,pos|
			if !@sprites["berry #{pos}"]
				begin
					filename = GameData::Item.icon_filename(berry)
				rescue 
					p "You have an error when choosing berry"
					Kernel.exit!
				end
				@sprites["berry #{pos}"] = Sprite.new(@viewport)
				@sprites["berry #{pos}"].bitmap = Bitmap.new(filename)
				@sprites["berry #{pos}"].visible = false
				@sprites["berry #{pos}"].z = 999999
				ox = @sprites["berry #{pos}"].bitmap.width/2
				oy = @sprites["berry #{pos}"].bitmap.height/2
				set_oxoy_sprite("berry #{pos}",ox,oy)
				x = Graphics.width / 2 + (pos==0 || pos==2 ? -Graphics.height/2 : Graphics.height/2)
				y = pos==0 || pos==1 ? 0 : Graphics.height
				set_xy_sprite("berry #{pos}",x,y)
				b[pos]=false
				x0[pos] = x
				y0[pos] = y
			end
		}
		t = time = 0
		loop do
			Graphics.update
			#update
			pbUpdateSpriteHash(@sprites)
			r = Graphics.height/4*Math.sqrt(2)
			t += 0.05
			time += 1
			cos = Math.cos(t)
			sin = Math.sin(t)
			if @sprites["berry 0"] && !b[0] && time>d[0]
				@sprites["berry 0"].visible = true
				@sprites["berry 0"].x =  r*(1-cos) + x0[0]
				@sprites["berry 0"].y =  r*(t-sin) + y0[0]
				if @sprites["berry 0"].y >= (Graphics.height/2-10)
					b[0] = true; @sprites["berry 0"].visible = false; end
			end
			if @sprites["berry 1"] && !b[1] && time>d[1]
				@sprites["berry 1"].visible = true
				@sprites["berry 1"].x = -r*(1-cos) + x0[1]
				@sprites["berry 1"].y =  r*(t-sin) + y0[1]
				if @sprites["berry 1"].y >= (Graphics.height/2-10)
					b[1] = true; @sprites["berry 1"].visible = false; end
			end
			if @sprites["berry 2"] && !b[2] && time>d[2]
				@sprites["berry 2"].visible = true
				@sprites["berry 2"].x =  r*(t-sin) + x0[2]
				@sprites["berry 2"].y = -r*(1-cos) + y0[2]
				if @sprites["berry 2"].y <= (Graphics.height/2+10)
					b[2] = true; @sprites["berry 2"].visible = false; end
			end
			if @sprites["berry 3"] && !b[3] && time>d[3]
				@sprites["berry 3"].visible = true
				@sprites["berry 3"].x = -r*(t-sin) + x0[3]
				@sprites["berry 3"].y = -r*(1-cos) + y0[3]
				if @sprites["berry 3"].y <= (Graphics.height/2+10)
					b[3] = true; @sprites["berry 3"].visible = false; end
			end
			break if (b[0]&&b[1]&&b[2]&&b[3])
		end
		dispose("berry 0"); dispose("berry 1"); dispose("berry 2"); dispose("berry 3");
	end
	
def dispose(id=nil)
	(id.nil?)? pbDisposeSpriteHash(@sprites) : pbDisposeSprite(@sprites,id)
end


