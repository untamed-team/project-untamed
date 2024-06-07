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
		#@sprites["trackBorderTop"].visible = false
		@trackBorderTopY = 52
		
		@sprites["trackBorderBottom"] = IconSprite.new(0, 0, @viewport)
		@sprites["trackBorderBottom"].setBitmap("Graphics/Pictures/Crustang Racing/track border bottom")
		@sprites["trackBorderBottom"].x = 0
		@sprites["trackBorderBottom"].y = 0
		@sprites["trackBorderBottom"].z = 999999
		#@sprites["trackBorderBottom"].visible = false
		@trackBorderBottomY = Graphics.height - 110
		
		#the track length should be something divisible by the number of points on the track overview, which is currently 24
		#set the x of track1 to where the player would start so the starting point of the track matches up with the starting point on the track overview
		trackFilename = "desertTrack"
		@sprites["track1"] = IconSprite.new(0, 0, @viewport)
		@sprites["track1"].setBitmap("Graphics/Pictures/Crustang Racing/" + trackFilename)
		@sprites["track1"].x = 0
		@sprites["track1"].y = 0
		@sprites["track1"].z = 99998
		#bottom of the track where objects appear over the player
		@sprites["track1Bottom"] = IconSprite.new(0, 0, @viewport)
		@sprites["track1Bottom"].setBitmap("Graphics/Pictures/Crustang Racing/" + trackFilename + "Bottom")
		@sprites["track1Bottom"].x = 0
		@sprites["track1Bottom"].y = Graphics.height - @sprites["track1Bottom"].height
		@sprites["track1Bottom"].z = 999991
		
		@sprites["track2"] = IconSprite.new(0, 0, @viewport)
		@sprites["track2"].setBitmap("Graphics/Pictures/Crustang Racing/#{trackFilename}")
		@sprites["track2"].x = @sprites["track1"].width
		@sprites["track2"].y = 0
		@sprites["track2"].z = 99998
		@sprites["track2"].src_rect = Rect.new(0, 0, 1024, @sprites["track1"].height)
		#bottom of the track where objects appear over the player
		@sprites["track2Bottom"] = IconSprite.new(0, 0, @viewport)
		@sprites["track2Bottom"].setBitmap("Graphics/Pictures/Crustang Racing/" + trackFilename + "Bottom")
		@sprites["track2Bottom"].x = 0
		@sprites["track2Bottom"].y = Graphics.height - @sprites["track2Bottom"].height
		@sprites["track2Bottom"].z = 999991
		
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
		
		#overlay text bitmaps
		@sprites["kphOverlay"] = BitmapSprite.new(Graphics.width/2, Graphics.height/4, @viewport)
		@sprites["kphOverlay"].x = 0
		@sprites["kphOverlay"].y = 0
		@sprites["kphOverlay"].z = 999999
		@khpOverlay = @sprites["kphOverlay"].bitmap
		pbSetSystemFont(@khpOverlay)
		@khpOverlay.font.size = MessageConfig::SMALL_FONT_SIZE
		@lastCurrentSpeed = 0
		
		@sprites["lapsAndPlaceOverlay"] = BitmapSprite.new(Graphics.width/2, Graphics.height/4, @viewport)
		@sprites["lapsAndPlaceOverlay"].x = 0
		@sprites["lapsAndPlaceOverlay"].y = 0
		@sprites["lapsAndPlaceOverlay"].z = 999999
		@lapsAndPlaceOverlay = @sprites["lapsAndPlaceOverlay"].bitmap
		pbSetSystemFont(@lapsAndPlaceOverlay)
		
		@overlayBaseColor   = MessageConfig::LIGHT_TEXT_MAIN_COLOR
		@overlayShadowColor = MessageConfig::LIGHT_TEXT_SHADOW_COLOR
		
	end #def setup
	
	def self.drawContestants
		#in relay run, the player's pkmn is always at the same exact X on the screen, so the camera is always centered on them, about a third of the screen's width inward
		@playerFixedX = 100 #this is where all racers will start, and the "camera" will stay here, focused on the player
		@racingPkmnStartingY = 52
		
		###################################
		#============= Racer3 =============
		###################################
		filename = "Followers/LILORINA"
		@sprites["racer3Pkmn"] = TrainerWalkingCharSprite.new(filename, @viewport)
		charwidth  = @sprites["racer3Pkmn"].bitmap.width
		charheight = @sprites["racer3Pkmn"].bitmap.height
		@sprites["racer3Pkmn"].x        = @playerFixedX# - (charwidth / 8)
		@sprites["racer3Pkmn"].y        = @racingPkmnStartingY# - (charheight / 8)
		@sprites["racer3Pkmn"].z = 99999
		#sprite turn right
		@sprites["racer3Pkmn"].src_rect = Rect.new(0, 128, charwidth / 4, charheight / 4)
		
		@racer3[:RacerSprite] = @sprites["racer3Pkmn"]
		@racer3[:PositionOnTrack] = @playerFixedX
		
		@racingPkmnStartingY += (8 + 64)

		###################################
		#============= Player =============
		###################################
		#draw the player racer
		filename = "Followers/CRUSTANG"
		@sprites["racerPlayerPkmn"] = TrainerWalkingCharSprite.new(filename, @viewport)
		charwidth  = @sprites["racerPlayerPkmn"].bitmap.width
		charheight = @sprites["racerPlayerPkmn"].bitmap.height
		@sprites["racerPlayerPkmn"].x        = @playerFixedX# - (charwidth / 8)
		@sprites["racerPlayerPkmn"].y        = @racingPkmnStartingY # - (charheight / 8)
		@sprites["racerPlayerPkmn"].z = 99999
		#sprite turn right
		@sprites["racerPlayerPkmn"].src_rect = Rect.new(0, 128, charwidth / 4, charheight / 4)
		
		@racerPlayer[:RacerSprite] = @sprites["racerPlayerPkmn"]
		@racerPlayer[:PositionOnTrack] = @playerFixedX
		
	end #def drawContestants
	
	def self.drawMovesUI
		#draw boost button
		#animname, framecount, framewidth, frameheight, frameskip
		@sprites["boostButton"] = AnimatedSprite.create("Graphics/Pictures/Crustang Racing/boost button", 2, 86, @viewport)
		#@sprites["boostButton"].setBitmap("Graphics/Pictures/Crustang Racing/boost button")
		@sprites["boostButton"].x = Graphics.width/2 - @sprites["boostButton"].width/2
		@sprites["boostButton"].y = Graphics.height - @sprites["boostButton"].height - 4
		@sprites["boostButton"].z = 999999

		@racerPlayer[:BoostButtonSprite] = @sprites["boostButton"]
		
		#draw cooldown mask
		@racerPlayer[:BoostButtonCooldownMaskSprite] = IconSprite.new(0, 0, @viewport)
		@racerPlayer[:BoostButtonCooldownMaskSprite].setBitmap("Graphics/Pictures/Crustang Racing/boost button mask")
		@racerPlayer[:BoostButtonCooldownMaskSprite].x = @racerPlayer[:BoostButtonSprite].x
		@racerPlayer[:BoostButtonCooldownMaskSprite].y = @racerPlayer[:BoostButtonSprite].y
		@racerPlayer[:BoostButtonCooldownMaskSprite].z = 999999
		@racerPlayer[:BoostButtonCooldownMaskSprite].opacity = 100
		@racerPlayer[:BoostButtonCooldownMaskSprite].src_rect = Rect.new(0, 0, @racerPlayer[:BoostButtonCooldownMaskSprite].width, 0)
		
		#numbers for cooldown mask
		number = @racerPlayer[:BoostButtonSprite].height.percent_of(CrustangRacingSettings::BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate)
		@boostCooldownPixelsToMovePerFrame = number / 100
		
		#draw text over button saying how to use it
		
		
		#draw moves depending on what racer knows
		#for now, draw specific moves, 4 at a time for testing
		#will hold off until other racers are in the game
	end
	
	def self.detectInput
		Input.update
		
		#movement up and down
		#@trackBorderTopY
		#@trackBorderBottomY
		if Input.press?(Input::UP)
			@racerPlayer[:RacerSprite].y -= CrustangRacingSettings::BASE_STRAFE_SPEED if @racerPlayer[:RacerSprite].y > @trackBorderTopY
		elsif Input.press?(Input::DOWN)
			@racerPlayer[:RacerSprite].y += CrustangRacingSettings::BASE_STRAFE_SPEED if @racerPlayer[:RacerSprite].y < @trackBorderBottomY
		end
		
		#moves
		if Input.trigger?(CrustangRacingSettings::BOOST_BUTTON) && @racerPlayer[:BoostCooldownTimer] <= 0
			@sprites["boostButton"].frame = 1
			@racerPlayer[:CurrentSpeed] = CrustangRacingSettings::BOOST_SPEED
			@racerPlayer[:BoostTimer] = CrustangRacingSettings::BOOST_LENGTH_SECONDS * Graphics.frame_rate
			self.beginCooldown(@racerPlayer, 0)
		end
		if Input.release?(Input::SPECIAL)
			@sprites["boostButton"].frame = 0
		end
		
	end #self.detectInput
	
	def self.updateOverlayText
		#Laps and Placement
		#@lapsAndPlaceOverlay
		#drawFormattedTextEx(bitmap, x, y, width, text, baseColor = nil, shadowColor = nil, lineheight = 32)
		if @lastLapCount != @racerPlayer[:LapCount]
			@lastLapCount = @racerPlayer[:LapCount]
			@lapsAndPlaceOverlay.clear
		end
		drawFormattedTextEx(@lapsAndPlaceOverlay, 20, 8, Graphics.width, "Place: 4th", @overlayBaseColor, @overlayShadowColor)
		drawFormattedTextEx(@lapsAndPlaceOverlay, 20, 40, Graphics.width, "Lap: #{@lastLapCount}", @overlayBaseColor, @overlayShadowColor)
		
		#KPH
		if @lastCurrentSpeed != @racerPlayer[:CurrentSpeed].truncate(1).to_f
			@lastCurrentSpeed = @racerPlayer[:CurrentSpeed].truncate(1).to_f
			@khpOverlay.clear
		end
		
		#drawFormattedTextEx(bitmap, x, y, width, text, baseColor = nil, shadowColor = nil, lineheight = 32)
		drawFormattedTextEx(@khpOverlay, 120, 45, Graphics.width, "KM/H: #{@lastCurrentSpeed*CrustangRacingSettings::KPH_MULTIPLIER}", @overlayBaseColor, @overlayShadowColor)
	end #def self.updateOverlayText
	
	def self.beginCooldown(racer, moveNumber)
		#move number 0 is boost
		#Move1: nil, Move1Effect: nil, Move1CooldownTimer: nil, Move1ButtonSprite: nil
		case moveNumber
		when 0
			#boost
			#un-press button
			@sprites["boostButton"].frame = 0
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
		###################################
		#============= Racer3 =============
		###################################
		@racer3[:BoostCooldownTimer] -= 1 if @racer3[:BoostCooldownTimer] > 0
		
		#move1
		#move2
		#move3
		#move4
		
		#do not update cooldown sprites for non-player racers because they don't have any
		
		###################################
		#============= Player =============
		###################################
		if @racerPlayer[:BoostCooldownTimer] > 0
			@racerPlayer[:BoostCooldownTimer] -= 1
			#cooldown mask over move
			@racerPlayer[:BoostButtonCooldownMaskSprite].src_rect = Rect.new(0, 0, @racerPlayer[:BoostButtonCooldownMaskSprite].width, @boostCooldownPixelsToMovePerFrame*@racerPlayer[:BoostCooldownTimer].ceil)
		end #if @racerPlayer[:BoostCooldownTimer] > 0
		
		#move1
		#move2
		#move3
		#move4
		
	end
	
	def self.drawContestantsOnOverview
		#draw the player racer's sprite over on the track overview (box sprite)
		###################################
		#============= Racer3 =============
		###################################
		pokemon = Pokemon.new(:LILORINA, 1)
		@sprites["racer3PkmnOverview"] = PokemonBoxIcon.new(pokemon, @viewport)
        @sprites["racer3PkmnOverview"].x = @trackEllipsesPoints[0][0] - @sprites["racer3PkmnOverview"].width/4
        @sprites["racer3PkmnOverview"].y = @trackEllipsesPoints[0][1] - @sprites["racer3PkmnOverview"].height/4
		@sprites["racer3PkmnOverview"].z = 99999
		@sprites["racer3PkmnOverview"].zoom_x = 0.5
		@sprites["racer3PkmnOverview"].zoom_y = 0.5
		@racer3[:RacerTrackOverviewSprite] = @sprites["racer3PkmnOverview"]
		
		###################################
		#============= Player =============
		###################################
		pokemon = Pokemon.new(:BATHYGIGAS, 1)
		@sprites["racerPlayerOverview"] = PokemonBoxIcon.new(pokemon, @viewport)
        @sprites["racerPlayerOverview"].x = @trackEllipsesPoints[0][0] - @sprites["racerPlayerOverview"].width/4
        @sprites["racerPlayerOverview"].y = @trackEllipsesPoints[0][1] - @sprites["racerPlayerOverview"].height/4
		@sprites["racerPlayerOverview"].z = 99999
		@sprites["racerPlayerOverview"].zoom_x = 0.5
		@sprites["racerPlayerOverview"].zoom_y = 0.5
		@racerPlayer[:RacerTrackOverviewSprite] = @sprites["racerPlayerOverview"]
	end #def self.drawContestantsOnOverview
	
	def self.moveSpritesWithTrack
		#move sprites like any obstacles, etc. along with the track as it passes by
		#lap line
		#@sprites["lapLine"].x -= @racerPlayer[:CurrentSpeed]
		#@sprites["lapLineCopy"].x -= @racerPlayer[:CurrentSpeed]
		
	end #def self.moveSpritesWithTrack
	
	def self.trackMovementUpdate
		@sprites["track1"].x -= @racerPlayer[:CurrentSpeed]
		@sprites["track2"].x -= @racerPlayer[:CurrentSpeed]
		
		#track image looping logic
		#if track2 is now on the screen, track2's X is now 0 or less, and track1's X is still < 0, move track1 to the end of track2 for a loop
		if @sprites["track2"].x <= 0 && @sprites["track1"].x < 0
			@sprites["track1"].x = @sprites["track2"].x + @sprites["track2"].width - 1024
			
			#@racer3[:RacerSprite].x -= @sprites["track2"].width - 1024 this made the racer disappear when the lap line is on screen for both of us
			#@racer3[:RacerSprite].x -= @sprites["track2"].width - 1024
			
		end
		#if track2's X is < 0, move track2 to the end of track1 for a loop
		if @sprites["track2"].x < 0
			@sprites["track2"].x = @sprites["track1"].x + @sprites["track1"].width
			#any racers off screen teleport to their same positions on the track when it teleports
			###################################
			#============= Racer3 =============
			###################################
			#@racer3[:RacerSprite].x -= @sprites["track2"].width - 1024
			
			
			
			
			
			
			
			
			
			
			
			
		end
		
		#bottom of the tracks
		@sprites["track1Bottom"].x = @sprites["track1"].x
		@sprites["track2Bottom"].x = @sprites["track2"].x
		
		#lap line
		@sprites["lapLine"].x = @sprites["track1"].x + @lapLineStartingX
		@sprites["lapLineCopy"].x = @sprites["track2"].x + @lapLineStartingX
		
		#any racers off screen teleport to their same positions on the track when it teleports
		
		#make racers move backwards as the track moves backwards
		@racer3[:RacerSprite].x = @sprites["track1"].x + @racer3[:PositionOnTrack]
		
		
	end #def trackMovementUpdate
	
	def self.trackOverviewMovementUpdate
		#the array with the points on the track are @trackEllipsesPoints
		#@trackDistanceBetweenPoints is currently 256 pixels
		
		###################################
		#============= Racer3 =============
		###################################
		#player point on overview
		@racer3[:PointOnTrackOverview] = (@racer3[:PositionOnTrack] / @trackDistanceBetweenPoints).floor
		
		#get the amount of pixels past the point we are at on the overview
		remainder = @racer3[:PositionOnTrack] % @trackDistanceBetweenPoints
		#get the percentage we have traveled into the point, 100% being when we reach the next point
		percentageIntoCurrentPoint = remainder.percent_of(@trackDistanceBetweenPoints)
		percentageIntoCurrentPoint = percentageIntoCurrentPoint / 100
		
		if @racer3[:PointOnTrackOverview] >= @trackEllipsesPoints.length-1
			nextPoint = @trackEllipsesPoints[0]
		else
			nextPoint = @trackEllipsesPoints[@racer3[:PointOnTrackOverview]+1]
		end
		
		
		if @trackEllipsesPoints[@racer3[:PointOnTrackOverview]].nil?
			print "#{@racer3[:PositionOnTrack]} #{(@sprites["track1"].width - @racer3[:RacerSprite].width)}" #6165, needs to teleport to 0 when it reaches the end of the track
		end
		
		
		#how many pixels in distance is it on the X axis between this point and the next one coming up?
		distanceBetweenPixelsX = (@trackEllipsesPoints[@racer3[:PointOnTrackOverview]][0] - nextPoint[0]).abs
		distanceBetweenPixelsY = (@trackEllipsesPoints[@racer3[:PointOnTrackOverview]][1] - nextPoint[1]).abs
		#how many pixels away are we on the overview from the current point e.g. @racer3[:PointOnTrackOverview]
		pixelsAwayFromCurrentPointX = distanceBetweenPixelsX * percentageIntoCurrentPoint
		pixelsAwayFromCurrentPointY = distanceBetweenPixelsY * percentageIntoCurrentPoint
		
		#calculate whether we need to increase X or decrease X for the overview icon sprite
		if @trackEllipsesPoints[@racer3[:PointOnTrackOverview]][0] > nextPoint[0]
			#decrease X
			currentOverviewX = @trackEllipsesPoints[@racer3[:PointOnTrackOverview]][0] - (pixelsAwayFromCurrentPointX.floor)
		elsif @trackEllipsesPoints[@racer3[:PointOnTrackOverview]][0] < nextPoint[0]
			#increase X
			currentOverviewX = @trackEllipsesPoints[@racer3[:PointOnTrackOverview]][0] + (pixelsAwayFromCurrentPointX.floor)
		end
		
		#calculate whether we need to increase Y or decrease Y for the overview icon sprite
		if @trackEllipsesPoints[@racer3[:PointOnTrackOverview]][1] > nextPoint[1]
			#decrease Y
			currentOverviewY = @trackEllipsesPoints[@racer3[:PointOnTrackOverview]][1] - (pixelsAwayFromCurrentPointY.floor)
		elsif @trackEllipsesPoints[@racer3[:PointOnTrackOverview]][1] < nextPoint[1]
			#increase Y
			currentOverviewY = @trackEllipsesPoints[@racer3[:PointOnTrackOverview]][1] + (pixelsAwayFromCurrentPointY.floor)
		end
		
		@racer3[:PositionXOnTrackOverview] = currentOverviewX - @racer3[:RacerTrackOverviewSprite].width/4
		@racer3[:PositionYOnTrackOverview] = currentOverviewY - @racer3[:RacerTrackOverviewSprite].height/4
		
		#put the overview icon sprite where it should be
		@racer3[:RacerTrackOverviewSprite].x = @racer3[:PositionXOnTrackOverview]
		@racer3[:RacerTrackOverviewSprite].y = @racer3[:PositionYOnTrackOverview]
		
		###################################
		#============= Player =============
		###################################
		#player point on overview
		@racerPlayer[:PointOnTrackOverview] = (@racerPlayer[:PositionOnTrack] / @trackDistanceBetweenPoints).floor
		
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
		remainder = @racerPlayer[:PositionOnTrack] % @trackDistanceBetweenPoints
		#get the percentage we have traveled into the point, 100% being when we reach the next point
		percentageIntoCurrentPoint = remainder.percent_of(@trackDistanceBetweenPoints)
		percentageIntoCurrentPoint = percentageIntoCurrentPoint / 100
		
		if @racerPlayer[:PointOnTrackOverview] >= @trackEllipsesPoints.length-1
			nextPoint = @trackEllipsesPoints[0]
		else
			nextPoint = @trackEllipsesPoints[@racerPlayer[:PointOnTrackOverview]+1]
		end
		
		#how many pixels in distance is it on the X axis between this point and the next one coming up?
		distanceBetweenPixelsX = (@trackEllipsesPoints[@racerPlayer[:PointOnTrackOverview]][0] - nextPoint[0]).abs
		distanceBetweenPixelsY = (@trackEllipsesPoints[@racerPlayer[:PointOnTrackOverview]][1] - nextPoint[1]).abs
		#how many pixels away are we on the overview from the current point e.g. @racerPlayer[:PointOnTrackOverview]
		pixelsAwayFromCurrentPointX = distanceBetweenPixelsX * percentageIntoCurrentPoint
		pixelsAwayFromCurrentPointY = distanceBetweenPixelsY * percentageIntoCurrentPoint
		
		
		#calculate whether we need to increase X or decrease X for the overview icon sprite
		if @trackEllipsesPoints[@racerPlayer[:PointOnTrackOverview]][0] > nextPoint[0]
			#decrease X
			currentOverviewX = @trackEllipsesPoints[@racerPlayer[:PointOnTrackOverview]][0] - (pixelsAwayFromCurrentPointX.floor)
		elsif @trackEllipsesPoints[@racerPlayer[:PointOnTrackOverview]][0] < nextPoint[0]
			#increase X
			currentOverviewX = @trackEllipsesPoints[@racerPlayer[:PointOnTrackOverview]][0] + (pixelsAwayFromCurrentPointX.floor)
		end
		
		#calculate whether we need to increase Y or decrease Y for the overview icon sprite
		if @trackEllipsesPoints[@racerPlayer[:PointOnTrackOverview]][1] > nextPoint[1]
			#decrease Y
			currentOverviewY = @trackEllipsesPoints[@racerPlayer[:PointOnTrackOverview]][1] - (pixelsAwayFromCurrentPointY.floor)
		elsif @trackEllipsesPoints[@racerPlayer[:PointOnTrackOverview]][1] < nextPoint[1]
			#increase Y
			currentOverviewY = @trackEllipsesPoints[@racerPlayer[:PointOnTrackOverview]][1] + (pixelsAwayFromCurrentPointY.floor)
		end
		
		@racerPlayer[:PositionXOnTrackOverview] = currentOverviewX - @racerPlayer[:RacerTrackOverviewSprite].width/4
		@racerPlayer[:PositionYOnTrackOverview] = currentOverviewY - @racerPlayer[:RacerTrackOverviewSprite].height/4
		
		#put the overview icon sprite where it should be
		@racerPlayer[:RacerTrackOverviewSprite].x = @racerPlayer[:PositionXOnTrackOverview]
		@racerPlayer[:RacerTrackOverviewSprite].y = @racerPlayer[:PositionYOnTrackOverview]
		
	end #def self.trackOverviewMovementUpdate
	
	def self.checkForLap
		#Lapping: true, LapCount: 0, CurrentPlacement: 1,
		#if the racer is touching the lap line and not currently 'lapping', add a lap to the racer's count
		
		###################################
		#============= Racer3 =============
		###################################
		if self.collides_with?(@racer3[:RacerSprite],@sprites["lapLine"]) && @racer3[:Lapping] != true
			@racer3[:LapCount] += 1
			@racer3[:Lapping] = true
		end
		@racer3[:Lapping] = false if !self.collides_with?(@racer3[:RacerSprite],@sprites["lapLine"])
		
		###################################
		#============= Player =============
		###################################
		if self.collides_with?(@racerPlayer[:RacerSprite],@sprites["lapLine"]) && @racerPlayer[:Lapping] != true
			@racerPlayer[:LapCount] += 1
			@racerPlayer[:Lapping] = true
		end
		@racerPlayer[:Lapping] = false if !self.collides_with?(@racerPlayer[:RacerSprite],@sprites["lapLine"])
		
	end #def self.checkForLap
	
	def self.updateRacerPositionOnTrack
		#this is the position on the entire track, not the track overview
		###################################
		#============= Player =============
		###################################
		#player position
		@racerPlayer[:PositionOnTrack] = @sprites["track1"].x.abs
		
		###################################
		#============= Racer3 =============
		###################################
		#racer3 position
		#if the racer has reached the end of the track + their sprite width, teleport them to x 0 - their sprite width
		if @racer3[:PositionOnTrack] >= @sprites["track1"].width - @racer3[:RacerSprite].width
			print "resetting to beginning of track"
			#@racer3[:RacerSprite].x = -1*@racer3[:RacerSprite].width
			#@racer3[:PositionOnTrack] = @racer3[:RacerSprite].x
			
			#@racer3[:PositionOnTrack] = @sprites["track1"].x - @racer3[:RacerSprite].width #then when the track moves, move the racer with it the same amount of pixels to the left, which should be minus the width of the track
			@racer3[:RacerSprite].x = @sprites["track1"].x - @racer3[:RacerSprite].width #then when the track moves, move the racer with it the same amount of pixels to the left, which should be minus the width of the track
		end
		
		#@racer3[:PositionOnTrack] = @sprites["track1"].x + @racer3[:RacerSprite].x
		#@racer3[:PositionOnTrack] = @sprites["track1"].x.abs# + @racer3[:RacerSprite].x + 24
		
		
		
		
	end #def self.updateRacerPositionOnTrack
	
	def self.collides_with?(player,object)
		if (object.x + object.width  >= player.x) && (object.x <= player.x + player.width) &&
			 (object.y + object.height >= player.y) && (object.y <= player.y + player.height)
			return true
		end
	end
	
	def self.accelerateDecelerate
		###################################
		#============= Racer3 =============
		###################################
		#accelerate
		if @racer3[:CurrentSpeed].floor < @racer3[:DesiredSpeed]
			@racer3[:CurrentSpeed] += @accelerationAmountPerFrame
		end
		#decelerate
		if @racer3[:CurrentSpeed].floor > @racer3[:DesiredSpeed] && @racer3[:BoostTimer] <= 0
			@racer3[:CurrentSpeed] -= @decelerationAmountPerFrame
		end
		#after speeding up or slowing down, if the floor of the current speed is exactly the desired speed, set the current speed to its floor
		if @racer3[:CurrentSpeed].floor == @racer3[:DesiredSpeed]
			@racer3[:CurrentSpeed] = @racer3[:CurrentSpeed].floor
		end
		#update boost timer
		@racer3[:BoostTimer] -= 1
		
		###################################
		#============= Player =============
		###################################
		#accelerate
		if @racerPlayer[:CurrentSpeed].floor < @racerPlayer[:DesiredSpeed]
			@racerPlayer[:CurrentSpeed] += @accelerationAmountPerFrame
		end
		#decelerate
		if @racerPlayer[:CurrentSpeed].floor > @racerPlayer[:DesiredSpeed] && @racerPlayer[:BoostTimer] <= 0
			@racerPlayer[:CurrentSpeed] -= @decelerationAmountPerFrame
		end
		#after speeding up or slowing down, if the floor of the current speed is exactly the desired speed, set the current speed to its floor
		if @racerPlayer[:CurrentSpeed].floor == @racerPlayer[:DesiredSpeed]
			@racerPlayer[:CurrentSpeed] = @racerPlayer[:CurrentSpeed].floor
		end
		#update boost timer
		@racerPlayer[:BoostTimer] -= 1
		
	end #def self.accelerateDecelerate
	
	def self.setMiscVariables
		#the below is how much to decrease speed per frame to reach the desired speed in 3 seconds
		@accelerationAmountPerFrame = CrustangRacingSettings::TOP_BASE_SPEED.to_f / (CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED.to_f * Graphics.frame_rate.to_f)
		#print @accelerationAmountPerFrame
		
		#the below is how much to increase speed per frame to reach the desired speed in 3 seconds
		@decelerationAmountPerFrame = CrustangRacingSettings::BOOST_SPEED / (CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED.to_f * Graphics.frame_rate.to_f)		
	end #def self.setMiscVariables
	
	def self.setupRacerHashes
		#set up racer hashes
		@racer1 = {}
		@racer2 = {}
		###################################
		#============= Racer3 =============
		###################################
		@racer3 = {
			#racer sprite
			RacerSprite: nil,
			#boost button sprites & cooldown timer
			BoostButtonSprite: nil, BoostCooldownTimer: 0, BoostButtonCooldownMaskSprite: nil,
			#moves, move effects, cooldown timers, & move sprites
			Move1: nil, Move1Effect: nil, Move1CooldownTimer: 0, Move1ButtonSprite: nil, Move2: nil, Move2Effect: nil, Move2CooldownTimer: 0, Move2ButtonSprite: nil, Move3: nil, Move3Effect: nil, Move3CooldownTimer: 0, Move3ButtonSprite: nil, Move4: nil, Move4Effect: nil, Move4CooldownTimer: 0, Move4ButtonSprite: nil, 
			#track positioning & speed
			PositionOnTrack: nil, CurrentSpeed: 0, DesiredSpeed: CrustangRacingSettings::TOP_BASE_SPEED.floor, BoostTimer: 0,
			#track overview positioning
			PointOnTrackOverview: nil, PositionXOnTrackOverview: nil, PositionYOnTrackOverview: nil, RacerTrackOverviewSprite: nil,
			#laps and Placement
			Lapping: true, LapCount: 0, CurrentPlacement: 1,
		}
		###################################
		#============= Player =============
		###################################
		@racerPlayer = {
			#racer sprite
			RacerSprite: nil,
			#boost button sprites & cooldown timer
			BoostButtonSprite: nil, BoostCooldownTimer: 0, BoostButtonCooldownMaskSprite: nil,
			#moves, move effects, cooldown timers, & move sprites
			Move1: nil, Move1Effect: nil, Move1CooldownTimer: 0, Move1ButtonSprite: nil, Move2: nil, Move2Effect: nil, Move2CooldownTimer: 0, Move2ButtonSprite: nil, Move3: nil, Move3Effect: nil, Move3CooldownTimer: 0, Move3ButtonSprite: nil, Move4: nil, Move4Effect: nil, Move4CooldownTimer: 0, Move4ButtonSprite: nil, 
			#track positioning & speed
			PositionOnTrack: nil, CurrentSpeed: 0, DesiredSpeed: CrustangRacingSettings::TOP_BASE_SPEED.floor, BoostTimer: 0,
			#track overview positioning
			PointOnTrackOverview: nil, PositionXOnTrackOverview: nil, PositionYOnTrackOverview: nil, RacerTrackOverviewSprite: nil,
			#laps and Placement
			Lapping: true, LapCount: 0, CurrentPlacement: 1,
		}
	end #def self.setupRacerHashes
	
	def self.main
		self.setup
		self.setupRacerHashes
		self.drawContestants
		self.drawContestantsOnOverview
		self.drawMovesUI
		self.setMiscVariables
		
		loop do
			Graphics.update
			pbUpdateSpriteHash(@sprites)
			self.trackMovementUpdate
			self.moveSpritesWithTrack
			self.updateRacerPositionOnTrack
			self.trackOverviewMovementUpdate
			self.detectInput
			self.updateCooldownTimers
			self.accelerateDecelerate
			self.updateOverlayText
			self.checkForLap
		end
	end #def self.main
	
end #class CrustangRacing

#from http://stackoverflow.com/questions/3668345/calculate-percentage-in-ruby
class Numeric
  def percent_of(n)
    self.to_f / n.to_f * 100.0
  end
end