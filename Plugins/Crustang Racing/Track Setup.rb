#Track Setup
class CrustangRacing
	def self.setup
		@viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z = 99999
		@sprites = {}
		
		@sprites["background"] = IconSprite.new(0, 0, @viewport)
		@sprites["background"].setBitmap("Graphics/Pictures/Crustang Racing/track border")
		@sprites["background"].x = 0
		@sprites["background"].y = 0
		@sprites["background"].z = 99999
		
		@sprites["test"] = IconSprite.new(0, 0, @viewport)
		@sprites["test"].setBitmap("Graphics/Pictures/Crustang Racing/track")
		@sprites["test"].x = 0
		@sprites["test"].y = 0
		@sprites["test"].z = 99998
		
		drawContestants
		
	end #def setup
	
	def self.drawContestants
		racingPkmnStartingX = 20
		racingPkmnStartingY = 64
		i = 0
		#3.times do
			#draw the crustang sprite with step animation on
			@sprites["racingPkmn#{i}"] = IconSprite.new(0, 0, @viewport)
			characterBitmap = AnimatedBitmap.new("Graphics/Characters/Followers/FEEBAS")
			@sprites["racingPkmn#{i}"].bitmap = characterBitmap
			@sprites["racingPkmn#{i}"].x = racingPkmnStartingX + @sprites["racingPkmn#{i}"].width
			@sprites["racingPkmn#{i}"].y = racingPkmnStartingY + @sprites["racingPkmn#{i}"].height
			@sprites["racingPkmn#{i}"].z = 99999
			
			#change the sprite character
			
			racingPkmnStartingY += 20 + 64 #size of each follower pkmn sprite
			i += 1
		#end #3.times do
	end #def drawContestants
	
	def self.main
		self.setup
		self.drawContestants
		loop do
			Graphics.update
		end
	end #def self.main
	
end #class CrustangRacing