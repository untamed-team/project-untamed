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
		@sprites["track1"].setBitmap("Graphics/Pictures/Crustang Racing/track")
		@sprites["track1"].x = 0
		@sprites["track1"].y = 0
		@sprites["track1"].z = 99998
		
		@sprites["track2"] = IconSprite.new(0, 0, @viewport)
		@sprites["track2"].setBitmap("Graphics/Pictures/Crustang Racing/track")
		@sprites["track2"].x = @sprites["track1"].width
		@sprites["track2"].y = 0
		@sprites["track2"].z = 99998
		@sprites["track2"].src_rect = Rect.new(0, 0, 1024, @sprites["track1"].height)
		
		@sprites["trackOverviewEllipses"] = IconSprite.new(0, 0, @viewport)
		@sprites["trackOverviewEllipses"].setBitmap("Graphics/Pictures/Crustang Racing/trackOverviewEllipses")
		@sprites["trackOverviewEllipses"].x = Graphics.width - @sprites["trackOverviewEllipses"].width - 16
		@sprites["trackOverviewEllipses"].y = 6
		@sprites["trackOverviewEllipses"].z = 99999
		
		@sprites["lapLine"] = IconSprite.new(0, 0, @viewport)
		@sprites["lapLine"].setBitmap("Graphics/Pictures/Crustang Racing/lapLine")
		@sprites["lapLine"].x = 140
		@sprites["lapLine"].y = 74
		@sprites["lapLine"].z = 99999
		
		@sprites["lapLineCopy"] = IconSprite.new(0, 0, @viewport)
		@sprites["lapLineCopy"].setBitmap("Graphics/Pictures/Crustang Racing/lapLine")
		@sprites["lapLineCopy"].x = 140 + @sprites["track1"].width #to put the lap line on the backup track
		@sprites["lapLineCopy"].y = 74
		@sprites["lapLineCopy"].z = 99999
		
		@lapLineStartingX = @sprites["lapLine"].x
		
		#track ellipses points
		startingPointX = @sprites["trackOverviewEllipses"].x + 144 #center X of the ellipses
		startingPointY = @sprites["trackOverviewEllipses"].y + 59 #bottom pixel of the ellipses
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
		
		@trackDistanceBetweenPoints = @sprites["track1"].width / @trackEllipsesPoints.length
		
		#calculate how much distance on the long track background translates to one lap on the tracker overview
		#track background is 6144 pixels wide
		#track overview has 24 points
		#6144 / 24 is 256, so every 256 pixels traveled should equal one point on the track overview traveled
		
	end #def setup
	
	def self.drawContestants
		#in relay run, the player's pkmn is always at the same exact X on the screen, so the camera is always centered on them, about a third of the screen's width inward
		@playerFixedX = 100 #this is where all racers will start, and the "camera" will stay here, focused on the player
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
		
		@racerPlayer["RacerSprite"] = @sprites["racingPkmnPlayer"]
		@racerPlayer["PositionOnTrack"] = @playerFixedX
		
	end #def drawContestants
	
	def self.drawMovesUI
		#draw boost button
		#animname, framecount, framewidth, frameheight, frameskip
		@sprites["boostButton"] = AnimatedSprite.create("Graphics/Pictures/Crustang Racing/boost button", 2, 86, @viewport)
		#@sprites["boostButton"].setBitmap("Graphics/Pictures/Crustang Racing/boost button")
		@sprites["boostButton"].x = Graphics.width/2 - @sprites["boostButton"].width/2
		@sprites["boostButton"].y = Graphics.height - @sprites["boostButton"].height - 4
		@sprites["boostButton"].z = 999999

		@racerPlayer["BoostButtonSprite"] = @sprites["boostButton"]
		
		#draw cooldown mask
		@racerPlayer["BoostButtonCooldownMaskSprite"] = IconSprite.new(0, 0, @viewport)
		@racerPlayer["BoostButtonCooldownMaskSprite"].setBitmap("Graphics/Pictures/Crustang Racing/boost button mask")
		@racerPlayer["BoostButtonCooldownMaskSprite"].x = @racerPlayer["BoostButtonSprite"].x
		@racerPlayer["BoostButtonCooldownMaskSprite"].y = @racerPlayer["BoostButtonSprite"].y
		@racerPlayer["BoostButtonCooldownMaskSprite"].z = 999999
		@racerPlayer["BoostButtonCooldownMaskSprite"].opacity = 100
		@racerPlayer["BoostButtonCooldownMaskSprite"].src_rect = Rect.new(0, 0, @racerPlayer["BoostButtonCooldownMaskSprite"].width, 0)
		
		#numbers for cooldown mask
		number = @racerPlayer["BoostButtonSprite"].height.percent_of(CrustangRacingSettings::BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate)
		@boostCooldownPixelsToMovePerFrame = number / 100
		
		#draw text over button saying how to use it
		
		
		#draw moves depending on what racer knows
		#for now, draw specific moves, 4 at a time for testing
		#will hold off until other racers are in the game
	end
	
	def self.detectInput
		Input.update
		if Input.trigger?(CrustangRacingSettings::BOOST_BUTTON) && @racerPlayer[:BoostCooldownTimer] <= 0
			@sprites["boostButton"].frame = 1
			self.beginCooldown(@racerPlayer, 0)
		end
		if Input.release?(Input::SPECIAL)
			@sprites["boostButton"].frame = 0
		end
	end #self.detectInput
	
	def self.beginCooldown(racer, moveNumber)
		#move number 0 is boost
		#Move1: nil, Move1Effect: nil, Move1CooldownTimer: nil, Move1ButtonSprite: nil
		case moveNumber
		when 0
			#boost
			#start cooldown timer
			racer[:BoostCooldownTimer] = CrustangRacingSettings::BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate
			#show that button is cooling down
			#racer["BoostButtonSprite"] ........ draw a black rect with opacity 50 or 100 or something at the x and y of the button, with a width and height of the button
		when 1
		when 2
		when 3
		when 4
		end #case moveNumber
		
	end #def self.beginCooldown(move)
	
	def self.updateCooldownTimers
		#player moves' cooldown timers
		if @racerPlayer[:BoostCooldownTimer] > 0
			@racerPlayer[:BoostCooldownTimer] -= 1 
			#cooldown mask over move
			@racerPlayer["BoostButtonCooldownMaskSprite"].src_rect = Rect.new(0, 0, @racerPlayer["BoostButtonCooldownMaskSprite"].width, @boostCooldownPixelsToMovePerFrame*@racerPlayer[:BoostCooldownTimer].ceil)
		end #if @racerPlayer[:BoostCooldownTimer] > 0
		
		#move1
		#move2
		#move3
		#move4
		
		#do not update cooldown sprites for non-player racers because they don't have any
		#racer1 moves' cooldown timers
	end
	
	def self.drawContestantsOnOverview
		#draw the player racer's sprite over on the track overview (box sprite)
		pokemon = Pokemon.new(:BATHYGIGAS, 1)
		@sprites["racingPkmnPlayerOverview"] = PokemonBoxIcon.new(pokemon, @viewport)
        @sprites["racingPkmnPlayerOverview"].x = @trackEllipsesPoints[0][0] - @sprites["racingPkmnPlayerOverview"].width/4
        @sprites["racingPkmnPlayerOverview"].y = @trackEllipsesPoints[0][1] - @sprites["racingPkmnPlayerOverview"].height/4
		@sprites["racingPkmnPlayerOverview"].z = 99999
		@sprites["racingPkmnPlayerOverview"].zoom_x = 0.5
		@sprites["racingPkmnPlayerOverview"].zoom_y = 0.5
		@racerPlayer["RacerTrackOverviewSprite"] = @sprites["racingPkmnPlayerOverview"]
	end #def self.drawContestantsOnOverview
	
	def self.moveSpritesWithTrack
		#move sprites like the lap line, any obstacles, etc. along with the track as it passes by
		#lap line
		@sprites["lapLine"].x -= @racerPlayer[:CurrentSpeed]
		@sprites["lapLineCopy"].x -= @racerPlayer[:CurrentSpeed]
		
	end #def self.moveSpritesWithTrack
	
	def self.trackMovementUpdate
		@sprites["track1"].x -= @racerPlayer[:CurrentSpeed]
		@sprites["track2"].x -= @racerPlayer[:CurrentSpeed]
		
		#track image looping logic
		#if track2 is now on the screen, track2's X is now 0 or less, and track1's X is still < 0, move track1 to the end of track2 for a loop
		if @sprites["track2"].x <= 0 && @sprites["track1"].x < 0
			@sprites["track1"].x = @sprites["track2"].x + @sprites["track2"].width - 1024
			#any racers off screen teleport to their same positions on the track when it teleports
			
		end
		#if track2's X is < 0, move track2 to the end of track1 for a loop
		if @sprites["track2"].x < 0
			@sprites["track2"].x = @sprites["track1"].x + @sprites["track1"].width
			#any racers off screen teleport to their same positions on the track when it teleports
			
		end
		
	end #def trackMovementUpdate
	
	def self.trackOverviewMovementUpdate
		#the array with the points on the track are @trackEllipsesPoints
		#@trackDistanceBetweenPoints is currently 256 pixels
		
		#player point on overview
		@racerPlayer["PointOnTrackOverview"] = (@racerPlayer["PositionOnTrack"] / @trackDistanceBetweenPoints).floor
		#PositionXOnTrackOverview
		#PositionYXOnTrackOverview
		
		#calculate overX and Y like so:
		#Current overviewX is the number of pixels in distance between current point and next point on the X axis. We'll say we are at point 0 and the next point is at 1.
		#Regardless of where we are, we want to use the distance in pixels between those points to calculate.
		#If we are at point 0.9, that's 90% of the distance between points.
		#Let's say 72 pixels are between the points on the X axis.
		#90% of 72 pixels is 66.6 so we put the current X of the overview icon at the X of the current point PLUS 66.6 (use floor)
		#to get the percentage of the distance we are into the point, use this:
		#DistanceCurrentToNextPointX = blah blah blah, we'll say it's 74 pixels, the amount between point 0 and point 1
		#PercentageIntoCurrentPoint = pointOnTrack / @distanceBetweenPoints (get remainder, and the remainder is the PercentageIntoCurrentPoint)
		
		#get the amount of pixels past the point we are at on the overview
		remainder = @racerPlayer["PositionOnTrack"] % @trackDistanceBetweenPoints
		#get the percentage we have traveled into the point, 100% being when we reach the next point
		percentageIntoCurrentPoint = remainder.percent_of(@trackDistanceBetweenPoints)
		percentageIntoCurrentPoint = percentageIntoCurrentPoint / 100
		
		if @racerPlayer["PointOnTrackOverview"] >= @trackEllipsesPoints.length-1
			nextPoint = @trackEllipsesPoints[0]
		else
			nextPoint = @trackEllipsesPoints[@racerPlayer["PointOnTrackOverview"]+1]
		end
		
		#how many pixels in distance is it on the X axis between this point and the next one coming up?
		distanceBetweenPixelsX = (@trackEllipsesPoints[@racerPlayer["PointOnTrackOverview"]][0] - nextPoint[0]).abs
		distanceBetweenPixelsY = (@trackEllipsesPoints[@racerPlayer["PointOnTrackOverview"]][1] - nextPoint[1]).abs
		#how many pixels away are we on the overview from the current point e.g. @racerPlayer["PointOnTrackOverview"]
		pixelsAwayFromCurrentPointX = distanceBetweenPixelsX * percentageIntoCurrentPoint
		pixelsAwayFromCurrentPointY = distanceBetweenPixelsY * percentageIntoCurrentPoint
		
		
		#calculate whether we need to increase X or decrease X for the overview icon sprite
		if @trackEllipsesPoints[@racerPlayer["PointOnTrackOverview"]][0] > nextPoint[0]
			#decrease X
			currentOverviewX = @trackEllipsesPoints[@racerPlayer["PointOnTrackOverview"]][0] - (pixelsAwayFromCurrentPointX.floor)
		elsif @trackEllipsesPoints[@racerPlayer["PointOnTrackOverview"]][0] < nextPoint[0]
			#increase X
			currentOverviewX = @trackEllipsesPoints[@racerPlayer["PointOnTrackOverview"]][0] + (pixelsAwayFromCurrentPointX.floor)
		end
		
		#calculate whether we need to increase Y or decrease Y for the overview icon sprite
		if @trackEllipsesPoints[@racerPlayer["PointOnTrackOverview"]][1] > nextPoint[1]
			#decrease Y
			currentOverviewY = @trackEllipsesPoints[@racerPlayer["PointOnTrackOverview"]][1] - (pixelsAwayFromCurrentPointY.floor)
		elsif @trackEllipsesPoints[@racerPlayer["PointOnTrackOverview"]][1] < nextPoint[1]
			#increase Y
			currentOverviewY = @trackEllipsesPoints[@racerPlayer["PointOnTrackOverview"]][1] + (pixelsAwayFromCurrentPointY.floor)
		end
		
		
		#print "current point is at X #{@trackEllipsesPoints[@racerPlayer["PointOnTrackOverview"]][0]}, overview sprite should be at X #{currentOverviewX}, and the next point to reach is at X #{@trackEllipsesPoints[@racerPlayer["PointOnTrackOverview"]+1][0]}"
		#print "current point is at Y #{@trackEllipsesPoints[@racerPlayer["PointOnTrackOverview"]][1]}, overview sprite should be at Y #{currentOverviewY}, and the next point to reach is at Y #{@trackEllipsesPoints[@racerPlayer["PointOnTrackOverview"]+1][1]}"
		
		@racerPlayer["PositionXOnTrackOverview"] = currentOverviewX - @sprites["racingPkmnPlayerOverview"].width/4
		@racerPlayer["PositionYOnTrackOverview"] = currentOverviewY - @sprites["racingPkmnPlayerOverview"].height/4
		
		#put the overview icon sprite where it should be
		@sprites["racingPkmnPlayerOverview"].x = @racerPlayer["PositionXOnTrackOverview"]
		@sprites["racingPkmnPlayerOverview"].y = @racerPlayer["PositionYOnTrackOverview"]
		
	end #def self.trackOverviewMovementUpdate
	
	def self.updateRacerPositionOnTrack
		#this is the position on the entire track, not the track overview
		#player position
		@racerPlayer["PositionOnTrack"] = @sprites["track1"].x.abs
		#calculate the position of the other racers differently. It would involve their X and the X of the track
		#racer1 position		
		#racer2 position
		#racer3 position
		
	end #def self.updateRacerPositionOnTrack
	
	def self.collides_with?(player,object)
		if (object.x + object.width  >= player.x) && (object.x <= player.x + player.width) &&
			 (object.y + object.height >= player.y) && (object.y <= player.y + player.height)
			return true
		end
	end
	
	def self.setupRacerHashes
		#set up racer hashes
		@racer1 = {}
		@racer2 = {}
		@racer3 = {}
		@racerPlayer = {
			#racer sprite
			RacerSprite: nil,
			#boost button sprites & cooldown timer
			BoostButtonSprite: nil, BoostCooldownTimer: 0, BoostButtonCooldownMaskSprite: nil,
			#moves, move effects, cooldown timers, & move sprites
			Move1: nil, Move1Effect: nil, Move1CooldownTimer: 0, Move1ButtonSprite: nil, Move2: nil, Move2Effect: nil, Move2CooldownTimer: 0, Move2ButtonSprite: nil, Move3: nil, Move3Effect: nil, Move3CooldownTimer: 0, Move3ButtonSprite: nil, Move4: nil, Move4Effect: nil, Move4CooldownTimer: 0, Move4ButtonSprite: nil, 
			#track positioning & speed
			PositionOnTrack: nil, CurrentSpeed: CrustangRacingSettings::STARTING_SPEED,
			#track overview positioning
			PointOnTrackOverview: nil, PositionXOnTrackOverview: nil, PositionYOnTrackOverview: nil, RacerTrackOverviewSprite: nil,
		}
	end #def self.setupRacerHashes
	
	def self.main
		self.setup
		self.setupRacerHashes
		self.drawContestants
		self.drawContestantsOnOverview
		self.drawMovesUI
		loop do
			Graphics.update
			pbUpdateSpriteHash(@sprites)
			self.trackMovementUpdate
			self.moveSpritesWithTrack
			self.updateRacerPositionOnTrack
			self.trackOverviewMovementUpdate
			self.detectInput
			self.updateCooldownTimers
		end
	end #def self.main
	
end #class CrustangRacing

#from http://stackoverflow.com/questions/3668345/calculate-percentage-in-ruby
class Numeric
  def percent_of(n)
    self.to_f / n.to_f * 100.0
  end
end