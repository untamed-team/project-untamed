class CookingStage1
	def initialize
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
		#always on top of other things
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
		@sprites["spoon"].z = 99999
		
		pbmain
	end #def initialize
	
	def updateCursorPos
		@sprites["spoon"].x=Mouse.x-@sprites["spoon"].width/2 if defined?(Mouse.x)
		@sprites["spoon"].y=Mouse.y-@sprites["spoon"].height+40 if defined?(Mouse.y)
	end #updateCursorPos
	
	def pbmain
		#pbMessage(_INTL("Adding candy base"))
		@sprites["candy_base"].visible = true
		
		loop do
			Graphics.update
			Input.update
			updateCursorPos
			pbUpdateSpriteHash(@sprites)
		end #loop do
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