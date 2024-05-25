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
		
		#set up racer hashes
		@racer1 = {}
		@racer2 = {}
		@racer3 = {}
		@racerPlayer = {}
		
	end #def setup
	
	def self.drawContestants
		racingPkmnStartingX = 20
		racingPkmnStartingY = 64
		i = 0
		#3.times do
			#draw the crustang sprite with step animation on
			filename = "Followers/FEEBAS"
			@sprites["racingPkmn#{i}"] = TrainerWalkingCharSprite.new(filename, @viewport)
			charwidth  = @sprites["racingPkmn#{i}"].bitmap.width
			charheight = @sprites["racingPkmn#{i}"].bitmap.height
			@sprites["racingPkmn#{i}"].x        = racingPkmnStartingX - (charwidth / 8)
			@sprites["racingPkmn#{i}"].y        = racingPkmnStartingY - (charheight / 8)
			@sprites["racingPkmn#{i}"].z = 99999
			#sprite turn right
			@sprites["racingPkmn#{i}"].src_rect = Rect.new(0, 128, charwidth / 4, charheight / 4)

			#turn down
			#@sprites["racingPkmn#{i}"].src_rect = Rect.new(0, 0, charwidth / 4, charheight / 4)
			#turn left
			#@sprites["racingPkmn#{i}"].src_rect = Rect.new(0, 64, charwidth / 4, charheight / 4)
			#turn right
			#@sprites["racingPkmn#{i}"].src_rect = Rect.new(0, 128, charwidth / 4, charheight / 4)
			#turn up
			#@sprites["racingPkmn#{i}"].src_rect = Rect.new(0, 128, charwidth / 4, charheight / 4)
			
			@racerPlayer.merge!({RacerSprite: @sprites["racingPkmn#{i}"]})
			print @racerPlayer
			
			racingPkmnStartingY += 20 + 64 #size of each follower pkmn sprite
			i += 1
		#end #3.times do
		
	end #def drawContestants
	
	def self.main
		self.setup
		self.drawContestants
		loop do
			Graphics.update
			pbUpdateSpriteHash(@sprites)
		end
	end #def self.main
	
end #class CrustangRacing