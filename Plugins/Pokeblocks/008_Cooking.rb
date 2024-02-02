class CookingMixing
	include BopModule

	STAGE_TIMER_SECONDS = 1#30
	BURN_TIMER_SECONDS = 5

	def initialize
		if !$bag.has?(:CANDYBASE) && !$bag.has?(:REDCANDYBASE) && !$bag.has?(:BLUECANDYBASE) && !$bag.has?(:PINKCANDYBASE) && !$bag.has?(:GREENCANDYBASE) && !$bag.has?(:YELLOCANDYBASE)
			pbMessage(_INTL("You don't have any candy bases!"))
			return
		end
		if !$bag.hasAnyBerry?
			pbMessage(_INTL("You don't have any berries!"))
			return
		end
	
		@sprites = {}
		@viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
		@viewport.z = 99999
	
		#Graphics
		backdrop = pbBackdrop
		@sprites["background"] = IconSprite.new(0, 0, @viewport)
		@sprites["background"].setBitmap("Graphics/Pictures/Pokemon Amie/"+pbBackdrop)
		@sprites["background"].x = 0
		@sprites["background"].y = 0
		@sprites["background"].z = 9999
		
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
		@sprites["candy_base"].opacity = 230
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
		@stirsCompleted = 0
		@resultingBaseHue = []
		@hues = {
			"Black" => [60,60,60],
			"Blue" => [6,155,216],
			"Gold" => [194,154,42],
			"Gray" => [158,158,158],
			"Green" => [136,194,75],
			"Indigo" => [124,115,251],
			"LiteBlue" => [8,203,248],
			"Olive" => [177,175,81],
			"Pink" => [241,140,164],
			"Purple" => [218,107,251],
			"Red" => [235,113,80],
			"White" => [224,224,224],
			"Yellow" => [252,204,84]
		}
		@gradualHueTimer = 0
		
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
			
			@stirsCompleted += 1
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
		#print "burn"
		pbSEPlay("GUI Misc7")
		@burnTimer = BURN_TIMER_SECONDS * Graphics.frame_rate
		
		@numberOfBlocks -= 1
	end #def burnedNotif
	
	def pbEndScene
		pbFadeOutAndHide(@sprites)
		pbDisposeSpriteHash(@sprites)
		@viewport.dispose
	end #def pbEndScene
	
	def failStage
		pbMessage(_INTL("You burned the entire mixture..."))
		pbEndScene
	end #def failStage
	
	def decideBaseHue
		if @berries.nil? || @berries.empty?
			#if we haven't picked berries yet, decide hue from base used
			case @candyBase
			when :CANDYBASE
				#default candy base is just off white, same color as the white block
				@resultingBaseHue = @hues["White"]
			when :REDCANDYBASE
				#make hue match base used
				@resultingBaseHue = @hues["Red"]
			when :BLUECANDYBASE
				#make hue match base used
				@resultingBaseHue = @hues["Blue"]
			when :PINKCANDYBASE
				#make hue match base used
				@resultingBaseHue = @hues["Pink"]
			when :GREENCANDYBASE
				#make hue match base used
				@resultingBaseHue = @hues["Green"]
			when :YELLOWCANDYBASE		
				#make hue match base used
				@resultingBaseHue = @hues["Yellow"]
			end
		else
			#if we have picked berries, decide hue from berries if a regular base was used
			if @candyBase == :CANDYBASE
				#get resulting color of pokeblock
				print "rainbow" if @colorOfBlocks == "Rainbow"
				@resultingBaseHue = @hues["#{@colorOfBlocks}"]
		
				#how many frames are needed to go from White's hue to the resulting hue?
				differenceRed = (@hues["White"][0] - @resultingBaseHue[0].abs)
				differenceGreen = (@hues["White"][1] - @resultingBaseHue[1].abs)
				differenceBlue = (@hues["White"][2] - @resultingBaseHue[2].abs)
				differences = [differenceRed, differenceGreen, differenceBlue].sort
				largestDifference = differences.last
				#timeNeeded = (30*40)/218, which is 5.5, so we need to subtract 1 every 5 frames
				if largestDifference != 0
					@timeNeeded = ((STAGE_TIMER_SECONDS*Graphics.frame_rate)/largestDifference).floor
					#print "Need to subtract every #{@timeNeeded} frames"
				else
					@timeNeeded = 1
				end #if largestDifference != 0
			else
				#@resultingBaseHue is already set
				return
			end
		end #if @berries.nil? || @berries.empty?		
	end #def decideBaseHue
	
	def changeBaseHueImmediate
		if @candyBase != :CANDYBASE
			#if used a colored base, set candy base sprite tones to @resultingBaseHue immediately
		else
			#set the base color to the white hue immediately
			@resultingBaseHue = @hues["White"]
		end #if @candyBase != :CANDYBASE
		
		@sprites["candy_base"].color.set(@resultingBaseHue[0], @resultingBaseHue[1], @resultingBaseHue[2])
		Graphics.update
		pbUpdateSpriteHash(@sprites)
	end #def changeBaseHueImmediate
	
	def changeBaseHueGradual
		#return if candybase is a colored base
		return if @candyBase != :CANDYBASE
	
		#this happens too quickly, so it needs to be slowed down by about half the speed
		@gradualHueTimer += 1
			
		if @gradualHueTimer >= @timeNeeded
			#this will run every frame until the color is equal to the resultingBaseHue
			if @sprites["candy_base"].color.red < @resultingBaseHue[0]
				@sprites["candy_base"].color.red += 1
			elsif @sprites["candy_base"].color.red > @resultingBaseHue[0]
				@sprites["candy_base"].color.red -= 1
			end
			if @sprites["candy_base"].color.green < @resultingBaseHue[1]
				@sprites["candy_base"].color.green += 1
			elsif @sprites["candy_base"].color.green > @resultingBaseHue[1]
				@sprites["candy_base"].color.green -= 1
			end
			if @sprites["candy_base"].color.blue < @resultingBaseHue[2]
				@sprites["candy_base"].color.blue += 1
			elsif @sprites["candy_base"].color.blue > @resultingBaseHue[2]
				@sprites["candy_base"].color.blue -= 1
			end
			
			#not sure why this is needed, but it doesn't update the sprite otherwise
			@sprites["candy_base"].color.set(@sprites["candy_base"].color.red, @sprites["candy_base"].color.green, @sprites["candy_base"].color.blue)
			#reset the timer
			@gradualHueTimer = 0
			
			#print "color achieved" if @sprites["candy_base"].color.red == @resultingBaseHue[0] && @sprites["candy_base"].color.green == @resultingBaseHue[1] && @sprites["candy_base"].color.blue == @resultingBaseHue[2]
		end #if @gradualHueTimer >= @timeNeeded
	end #changeBaseHueGradual
	
	def overridePokeblockColor
		#override the resulting pokeblock colors
		case @candyBase
		when :REDCANDYBASE
			color = "Red"
		when :BLUECANDYBASE
			color = "Blue"
		when :PINKCANDYBASE
			color = "Pink"
		when :GREENCANDYBASE
			color = "Green"
		when :YELLOWCANDYBASE
			color = "Yellow"
		end #case @candyBase
		
		for i in 0...@results.length
			@results[i].color = color.to_sym
		end
	end #def overridePokeblockColor
	
	def pbmain
		pbFadeInAndShow(@sprites) { pbUpdateSpriteHash(@sprites) }
		
		Graphics.update
		#pbUpdateSpriteHash(@sprites)
		
		pbWait(1*Graphics.frame_rate)
		
		#choose a candy base
		pbMessage(_INTL("Select a candy base from your bag to put in the pot."))
		#@berries = BerryPoffin.pbPickBerryForBlenderSimple
		
		@candyBase = pbPickCandyBase
		while @candyBase.nil? do
			if pbConfirmMessage(_INTL("Give up on cooking?"))
				pbEndScene
				return
			else
				pbPickCandyBase
			end
		end #while @candyBase.nil? do
		decideBaseHue
		
		changeBaseHueImmediate
		@sprites["candy_base"].visible = true
				
		#add berries
		pbMessage(_INTL("Select some berries from your bag to put in the pot."))
		@berries = BerryPoffin.pbPickBerryForBlenderSimple
		
		#exit cooking if exiting selecting berries
		if @berries.nil? || @berries.empty?
			pbEndScene
			return
		end #if @berries.nil? || @berries.empty?
		
		animationBerry(@berries)
		
		@results = pbCalculateSimplePokeblock(@berries)
		
		overridePokeblockColor if @candyBase != :CANDYBASE
		
		@numberOfBlocks = @results.length
		@colorOfBlocks = @results[0].color_name
		@qualityOfBlocks = (@results[0].plus ? " +" : "")
		
		#print "this will make #{@numberOfBlocks} #{@colorOfBlocks} pokeblocks#{@qualityOfBlocks}!"
		#@results.each { |pb| pbGainPokeblock(pb) }
		
		decideBaseHue
		
		#decide initial stir direction
		decideStirDir
		
		loop do
			Graphics.update
			Input.update
			updateCursorPos
			pbUpdateSpriteHash(@sprites)
			detectInput
			
			changeBaseHueGradual
			
			stirArrowBlink if @arrowBlinkTimer > 0
			@arrowBlinkTimer -= 1
			
			burnedNotif if @burnTimer <= 0
			if @numberOfBlocks < 0
				#you get 1 free burn (which is why this says '< 0'), so if you burn the mixture once, you will then after be losing a block from the output per burn. fail stage if no output blocks left
				failStage
				return
			end #if @numberOfBlocks < 0
			########################################################################################@burnTimer -= 1
			break if @stageTimer <= 0
			@stageTimer -= 1
		end #loop do
		#print "Stirs completed: #{@stirsCompleted}"
		
		#roll for possibility of getting extra pokeblocks based on @stirsCompleted
		
		#end cooking stage
		pbEndScene
		
		#hash of variables we want to take with us to other stages
		variables = {
			"resultingBaseHue" => @resultingBaseHue,
			"results"          => @results,
			"numberOfBlocks"   => @numberOfBlocks,
			"colorOfBlocks"    => @colorOfBlocks,
			"qualityOfBlocks"  => @qualityOfBlocks
		}
		#next stage
		CookingCooling.new(variables)
	end
end #class CookingMixing

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

def pbCalculateSimplePokeblock(berries)
		probability = 0
		posColors = []
		@berries.each { |berry| 
			data = GameData::BerryData.get(berry.id)
			probability += data.plusProbability
			posColors.push(data.block_color)
		}
		color = nil
		uniqColors = posColors.uniq
		if uniqColors.length >=4 then color = :Rainbow;
		elsif uniqColors.length == 1 then color = uniqColors[0]; 
		elsif uniqColors.length == posColors.length then color = posColors.sample;
		else
			c = []
			uniqColors.each { |color| 
				next c.push(color) if c.empty? || posColors.count(color) == posColors.count(c[0])
				c[0] = color if posColors.count(color) > posColors.count(c[0])
			}
			color = c.sample
		end
		plus = rand(100)<probability
		flavor = [0,0,0,0,0]
		fVal = (plus ? 15 : 5 )
		case color
		when :Rainbow then flavor = [fVal,fVal,fVal,fVal,fVal]
		when :Red then flavor[0] = fVal
		when :Blue then flavor[1] = fVal
		when :Pink then flavor[2] = fVal
		when :Green then flavor[3] = fVal
		when :Yellow then flavor[4] = fVal
		end
		results = []
		qty = berries.length
		qty.times { results.push(Pokeblock.new(color,flavor,0,plus)) }	
		return results
	end

def pbPickCandyBase
	ret = nil
	pbFadeOutIn {
		scene = PokemonBag_Scene.new
		screen = PokemonBagScreen.new(scene, $bag)
		ret = screen.pbChooseItemScreen(proc { |item| GameData::Item.get(item) == :CANDYBASE || GameData::Item.get(item) == :REDCANDYBASE || GameData::Item.get(item) == :BLUECANDYBASE || GameData::Item.get(item) == :PINKCANDYBASE || GameData::Item.get(item) == :GREENCANDYBASE || GameData::Item.get(item) == :YELLOWCANDYBASE})
	}
	$bag.remove(ret) if !ret.nil?
	return ret
end

#########################
#from the pokemon Amie Script
def pbBackdrop #gets background based off location
      environ=pbGetEnvironment
      # Choose backdrop
      backdrop="Field"
      if environ==:Cave
        backdrop="Cave"
      elsif environ==:MovingWater
        backdrop="Water"
      elsif environ==:Underwater
        backdrop="Underwater"
      elsif environ==:Rock
        backdrop="Mountain"
      else
          if !$game_map || !$game_map.metadata
          backdrop="IndoorA"
        end
      end
      if $game_map
            back=$game_map.metadata.battle_background
        if back && back!=""
          backdrop=back
        end
      end
      if $PokemonGlobal && $PokemonGlobal.nextBattleBack
        backdrop=$PokemonGlobal.nextBattleBack
      end
      # Apply graphics
      battlebg=backdrop
      return battlebg
    end

class CookingCooling
	def initialize(cooking_variables)
		@sprites = {}
		@viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
		@viewport.z = 99999
	
		#variables from other stage
		@resultingBaseHue = cooking_variables["resultingBaseHue"]
		@results = cooking_variables["results"]
		@numberOfBlocks = cooking_variables["numberOfBlocks"]
		@colorOfBlocks = cooking_variables["colorOfBlocks"]
		@qualityOfBlocks = cooking_variables["qualityOfBlocks"]
	
		#Graphics
		backdrop = pbBackdrop
		@sprites["background"] = IconSprite.new(0, 0, @viewport)
		@sprites["background"].setBitmap("Graphics/Pictures/Pokemon Amie/"+pbBackdrop)
		@sprites["background"].x = 0
		@sprites["background"].y = 0
		@sprites["background"].z = 99999
		
		@sprites["stump"] = IconSprite.new(0, 0, @viewport)
		@sprites["stump"].setBitmap("Graphics/Pictures/Pokeblock/Candy Making/stumpStool")
		@sprites["stump"].x = Graphics.width/2 - @sprites["stump"].width/2
		@sprites["stump"].y = Graphics.height/2
		@sprites["stump"].z = 99999
		
		@sprites["panBottom"] = IconSprite.new(0, 0, @viewport)
		@sprites["panBottom"].setBitmap("Graphics/Pictures/Pokeblock/Candy Making/panBottom")
		@sprites["panBottom"].x = Graphics.width/2 - @sprites["panBottom"].width/2
		@sprites["panBottom"].y = Graphics.height/2 - @sprites["panBottom"].height/4
		@sprites["panBottom"].z = 99999
		
		@sprites["panEdges"] = IconSprite.new(0, 0, @viewport)
		@sprites["panEdges"].setBitmap("Graphics/Pictures/Pokeblock/Candy Making/panEdges")
		@sprites["panEdges"].x = Graphics.width/2 - @sprites["panEdges"].width/2
		@sprites["panEdges"].y = @sprites["panBottom"].y
		@sprites["panEdges"].z = 999999
		
		@sprites["pot"] = IconSprite.new(0, 0, @viewport)
		@sprites["pot"].setBitmap("Graphics/Pictures/Pokeblock/Candy Making/pot")
		@sprites["pot"].x = Graphics.width/2 - @sprites["pot"].width/2
		@sprites["pot"].y = -50
		@sprites["pot"].z = 999999
		
		@sprites["candy_base_in_pot"] = IconSprite.new(0, 0, @viewport)
		@sprites["candy_base_in_pot"].setBitmap("Graphics/Pictures/Pokeblock/Candy Making/candy_base_in_pot_small")
		@sprites["candy_base_in_pot"].x = Graphics.width/2 - @sprites["candy_base_in_pot"].width/2
		@sprites["candy_base_in_pot"].y = @sprites["pot"].y
		@sprites["candy_base_in_pot"].z = 999999
		@sprites["candy_base_in_pot"].color.set(@resultingBaseHue[0], @resultingBaseHue[1], @resultingBaseHue[2])
		
		@sprites["heat_guage"] = IconSprite.new(0, 0, @viewport)
		@sprites["heat_guage"].setBitmap("Graphics/Pictures/Pokeblock/Candy Making/gauge")
		@sprites["heat_guage"].x = Graphics.width/2 - @sprites["heat_guage"].width/2
		@sprites["heat_guage"].y = Graphics.height - 20 - @sprites["heat_guage"].height
		@sprites["heat_guage"].z = 999999
		
		@sprites["heat_guage_fill"] = IconSprite.new(0, 0, @viewport)
		@sprites["heat_guage_fill"].setBitmap("Graphics/Pictures/Pokeblock/Candy Making/gauge_fill")
		@sprites["heat_guage_fill"].x = @sprites["heat_guage"].x
		@sprites["heat_guage_fill"].y = @sprites["heat_guage"].y
		@sprites["heat_guage_fill"].z = 99999
		@sprites["heat_guage_fill"].src_rect.width = @sprites["heat_guage"].width
		
		@sprites["fire_icon"] = IconSprite.new(0, 0, @viewport)
		@sprites["fire_icon"].setBitmap("Graphics/Pictures/Pokeblock/Candy Making/fire_icon")
		@sprites["fire_icon"].x = @sprites["heat_guage_fill"].x + @sprites["heat_guage_fill"].width - @sprites["fire_icon"].width/2
		@sprites["fire_icon"].y = @sprites["heat_guage"].y - @sprites["fire_icon"].height/2
		@sprites["fire_icon"].z = 999999
		
		#(animname, framecount, framewidth, frameheight, frameskip)
		@sprites["fan"] = AnimatedSprite.new("Graphics/Pictures/Pokeblock/Candy Making/fan",8,276,336,1,@viewport)
		@sprites["fan"].x = Graphics.width/2 - @sprites["fan"].width/2
		@sprites["fan"].y = Graphics.height/2 - @sprites["fan"].height/2
		@sprites["fan"].z = 999999
		
		pbmain
	end #def initialize
	
	def pbmain
		pbFadeInAndShow(@sprites) { pbUpdateSpriteHash(@sprites) }
		
		pbWait(Graphics.frame_rate*1)
		
		#flip pot and mixture upside down
		@sprites["pot"].angle = 180
		@sprites["pot"].x += @sprites["pot"].width
		@sprites["pot"].y += @sprites["pot"].height
		@sprites["candy_base_in_pot"].visible = false
		
		#change pan bottom to color of mixture
		@sprites["panBottom"].color.set(@resultingBaseHue[0], @resultingBaseHue[1], @resultingBaseHue[2])
		
		pbUpdateSpriteHash(@sprites)
		
		loop do
			Graphics.update
			Input.update
			updateCursorPos
			pbUpdateSpriteHash(@sprites)
			detectInput

		end #loop do
	end
	
	def detectInput
		if Mouse.press?
			@sprites["fan"].play if !@sprites["fan"].playing?
			decreaseGauge
		end #if Mouse.press?
		if Input.release?(Input::MOUSELEFT)
			@sprites["fan"].stop
			@sprites["fan"].frame = 0
		end #Input.release?(Input::MOUSELEFT)
	end #detectInput
	
	def updateCursorPos
		@lastX = @sprites["fan"].x
		@lastY = @sprites["fan"].y
		
		#if the mouse leaves the game window, put the fan at its last X and Y rather than in the top left of the screen
		if !System.mouse_in_window
			@sprites["fan"].x = @lastX
			@sprites["fan"].y = @lastY
		else
			@sprites["fan"].x=Mouse.x-@sprites["fan"].width/2-40 if defined?(Mouse.x)
			@sprites["fan"].y=Mouse.y-@sprites["fan"].height/2-34 if defined?(Mouse.y)
		end
	end #updateCursorPos
	
	def decreaseGauge
		if @sprites["heat_guage_fill"].src_rect.width <= 0
			print "cooled"
		else
			@sprites["heat_guage_fill"].src_rect.width -= 2
			@sprites["fire_icon"].x = @sprites["heat_guage_fill"].x + @sprites["heat_guage_fill"].width - @sprites["fire_icon"].width/2
		end
	end #def decreaseGauge
	
end #class CookingCooling