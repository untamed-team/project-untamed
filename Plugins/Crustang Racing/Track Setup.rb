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
		
		#the track length should be something divisible by the number of points on the track overview, which is currently 24
		#set the x of track1 to where the player would start so the starting point of the track matches up with the starting point on the track overview
		@sprites["track1"] = IconSprite.new(0, 0, @viewport)
		@sprites["track1"].setBitmap("Graphics/Pictures/Crustang Racing/trackPart1")
		@sprites["track1"].x = 0 #######################################################################
		@sprites["track1"].y = 0
		@sprites["track1"].z = 99998
		
		@sprites["track2"] = IconSprite.new(0, 0, @viewport)
		@sprites["track2"].setBitmap("Graphics/Pictures/Crustang Racing/trackPart2")
		@sprites["track2"].x = @sprites["track1"].width
		@sprites["track2"].y = 0
		@sprites["track2"].z = 99998
		
		@sprites["trackOverviewEllipses"] = IconSprite.new(0, 0, @viewport)
		@sprites["trackOverviewEllipses"].setBitmap("Graphics/Pictures/Crustang Racing/trackOverviewEllipses")
		@sprites["trackOverviewEllipses"].x = Graphics.width - @sprites["trackOverviewEllipses"].width - 16
		@sprites["trackOverviewEllipses"].y = 6
		@sprites["trackOverviewEllipses"].z = 99998
		
		#set up racer hashes
		@racer1 = {}
		@racer2 = {}
		@racer3 = {}
		@racerPlayer = {}
		
		#track ellipses points
		startingPointX = @sprites["trackOverviewEllipses"].x + 144 #center X of the ellipses
		startingPointY = @sprites["trackOverviewEllipses"].y + 60 #bottom pixel of the ellipses
		#there are 24 total elements in the array below, so 24 points on the ellipses
		@trackEllipsesPoints = [
		[startingPointX,startingPointY],
		[startingPointX+72,startingPointY-5],
		[startingPointX+107,startingPointY-11],
		[startingPointX+125,startingPointY-16],
		[startingPointX+134,startingPointY-20],
		[startingPointX+140,startingPointY-24],
		[startingPointX+144,startingPointY-30],
		[startingPointX+140,startingPointY-37],
		[startingPointX+138,startingPointY-41],
		[startingPointX+125,startingPointY-45],
		[startingPointX+107,startingPointY-50],
		[startingPointX+72,startingPointY-56],
		[startingPointX+1,startingPointY-60],
		[startingPointX-71,startingPointY-56],
		[startingPointX-106,startingPointY-50],
		[startingPointX-124,startingPointY-45],
		[startingPointX-133,startingPointY-41],
		[startingPointX-139,startingPointY-37],
		[startingPointX-143,startingPointY-31],
		[startingPointX-139,startingPointY-24],
		[startingPointX-133,startingPointY-20],
		[startingPointX-124,startingPointY-16],
		[startingPointX-106,startingPointY-11],
		[startingPointX-71,startingPointY-5],
		]
		
		#calculate how much distance on the long track background translates to one lap on the tracker overview
		#track background is 6144 pixels wide
		#track overview has 24 points
		#6144 / 24 is 256, so every 256 pixels traveled should equal one point on the track overview traveled		
		
	end #def setup
	
	def self.drawContestants
		#in relay run, the player's pkmn is always at the same exact X on the screen, so the camera is always centered on them, about a third of the screen's width inward
		#so startingX should be 512/3, but since that is not an even number, we'll do 513/3, which is 171
		@playerFixedX = 171 #this is where all racers will start, and the "camera" will stay here, focused on the player
		@racingPkmnStartingY = 52
		#i = 0
		#3.times do
			#draw the crustang sprite with step animation on
		#	filename = "Followers/BATHYGIGAS"
		#	@sprites["racingPkmn#{i}"] = TrainerWalkingCharSprite.new(filename, @viewport)
		#	charwidth  = @sprites["racingPkmn#{i}"].bitmap.width
		#	charheight = @sprites["racingPkmn#{i}"].bitmap.height
		#	@sprites["racingPkmn#{i}"].x        = playerFixedX# - (charwidth / 8)
		#	@sprites["racingPkmn#{i}"].y        = @racingPkmnStartingY# - (charheight / 8)
		#	@sprites["racingPkmn#{i}"].z = 99999
		#	#sprite turn right
		#	@sprites["racingPkmn#{i}"].src_rect = Rect.new(0, 128, charwidth / 4, charheight / 4)

			#turn down
			#@sprites["racingPkmn#{i}"].src_rect = Rect.new(0, 0, charwidth / 4, charheight / 4)
			#turn left
			#@sprites["racingPkmn#{i}"].src_rect = Rect.new(0, 64, charwidth / 4, charheight / 4)
			#turn right
			#@sprites["racingPkmn#{i}"].src_rect = Rect.new(0, 128, charwidth / 4, charheight / 4)
			#turn up
			#@sprites["racingPkmn#{i}"].src_rect = Rect.new(0, 128, charwidth / 4, charheight / 4)
			
		#	#@racerPlayer.merge!({RacerSprite: @sprites["racingPkmn#{i}"]})
			
		#	@racingPkmnStartingY += 8 + 64 #size of each follower pkmn sprite
		#	i += 1
		#end #3.times do
		
		#draw the player racer
		filename = "Followers/BATHYGIGAS"
		@sprites["racingPkmnPlayer"] = TrainerWalkingCharSprite.new(filename, @viewport)
		charwidth  = @sprites["racingPkmnPlayer"].bitmap.width
		charheight = @sprites["racingPkmnPlayer"].bitmap.height
		@sprites["racingPkmnPlayer"].x        = @playerFixedX# - (charwidth / 8)
		@sprites["racingPkmnPlayer"].y        = @racingPkmnStartingY# - (charheight / 8)
		@sprites["racingPkmnPlayer"].z = 99999
		#sprite turn right
		@sprites["racingPkmnPlayer"].src_rect = Rect.new(0, 128, charwidth / 4, charheight / 4)
		
		@racerPlayer.merge!({RacerSprite: @sprites["racingPkmnPlayer"]})
		
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
	
	def self.trackOverviewMovementUpdate
		
	end #def self.trackOverviewMovementUpdate
	
	def self.main
		self.setup
		self.drawContestants
		loop do
			Graphics.update
			pbUpdateSpriteHash(@sprites)
			self.trackMovementUpdate
			self.trackOverviewMovementUpdate
		end
	end #def self.main
	
end #class CrustangRacing