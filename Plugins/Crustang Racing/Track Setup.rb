#Track Setup
class CrustangRacing
	def self.setup
		@viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z = 99999
		@sprites = {}
		
		@sprites["trackBorderTop"] = IconSprite.new(0, 0, @viewport)
		@sprites["trackBorderTop"].setBitmap("Graphics/Pictures/Crustang Racing/track border top")
		@sprites["trackBorderTop"].x = 0
		@sprites["trackBorderTop"].y = 0
		@sprites["trackBorderTop"].z = 99999
		
		@sprites["trackBorderBottom"] = IconSprite.new(0, 0, @viewport)
		@sprites["trackBorderBottom"].setBitmap("Graphics/Pictures/Crustang Racing/track border bottom")
		@sprites["trackBorderBottom"].x = 0
		@sprites["trackBorderBottom"].y = 0
		@sprites["trackBorderBottom"].z = 999999
		
		@sprites["track1"] = IconSprite.new(0, 0, @viewport)
		@sprites["track1"].setBitmap("Graphics/Pictures/Crustang Racing/trackPart1")
		@sprites["track1"].x = 0
		@sprites["track1"].y = 0
		@sprites["track1"].z = 99998
		
		@sprites["track2"] = IconSprite.new(0, 0, @viewport)
		@sprites["track2"].setBitmap("Graphics/Pictures/Crustang Racing/trackPart2")
		@sprites["track2"].x = @sprites["track1"].width
		@sprites["track2"].y = 0
		@sprites["track2"].z = 99998
		
		#set up racer hashes
		@racer1 = {}
		@racer2 = {}
		@racer3 = {}
		@racerPlayer = {}
		
	end #def setup
	
	def self.drawContestants
		racingPkmnStartingX = 20
		racingPkmnStartingY = 52
		i = 0
		3.times do
			#draw the crustang sprite with step animation on
			filename = "Followers/BATHYGIGAS"
			@sprites["racingPkmn#{i}"] = TrainerWalkingCharSprite.new(filename, @viewport)
			charwidth  = @sprites["racingPkmn#{i}"].bitmap.width
			charheight = @sprites["racingPkmn#{i}"].bitmap.height
			@sprites["racingPkmn#{i}"].x        = racingPkmnStartingX# - (charwidth / 8)
			@sprites["racingPkmn#{i}"].y        = racingPkmnStartingY# - (charheight / 8)
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
			
			#@racerPlayer.merge!({RacerSprite: @sprites["racingPkmn#{i}"]})
			
			racingPkmnStartingY += 8 + 64 #size of each follower pkmn sprite
			i += 1
		end #3.times do
		
	end #def drawContestants
	
	def self.trackMovementUpdate
		@sprites["track1"].x -= 4
		@sprites["track2"].x -= 4
		
		#track image looping logic
		#if track2 is now on the screen, track2's X is now 0 or less, and track1's X is still < 0, move track1 to the end of track2 for a loop
		if @sprites["track2"].x <= 0 && @sprites["track1"].x < 0
			@sprites["track1"].x = @sprites["track2"].x + @sprites["track2"].width - 1024
		end
		#if track2's X is < 0, move track2 to the end of track1 for a loop
		if @sprites["track2"].x < 0
			@sprites["track2"].x = @sprites["track1"].x + @sprites["track1"].width
		end
		
	end #def trackMovementUpdate
	
	def self.main
		self.setup
		self.drawContestants
		loop do
			Graphics.update
			pbUpdateSpriteHash(@sprites)
			self.trackMovementUpdate
		end
	end #def self.main
	
end #class CrustangRacing