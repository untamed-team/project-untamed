class Cooking
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
		@sprites["fire"] = AnimatedSprite.new("Graphics/Pictures/Pokeblock/Candy Making/fire_anim",4,274,201,4,@viewport)
		@sprites["fire"].x = @sprites["firewood"].x + @sprites["firewood"].width/2 - @sprites["fire"].width/4
		@sprites["fire"].y = @sprites["firewood"].y + @sprites["firewood"].height/2 - @sprites["fire"].height/3
		@sprites["fire"].z = 99999
		@sprites["fire"].zoom_x = 0.5
		@sprites["fire"].zoom_y = 0.5
		@sprites["fire"].play
		pbmain
	end #def initialize
	
	def pbmain
		loop do
			Graphics.update
			pbUpdateSpriteHash(@sprites)
		end #loop do
	end
end #class Cooking