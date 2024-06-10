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
		@sprites["track2"].x = @sprites["track1"].x + @sprites["track1"].width
		@sprites["track2"].y = 0
		@sprites["track2"].z = 99998
		@sprites["track2"].src_rect = Rect.new(0, 0, 1024, @sprites["track1"].height)
		@sprites["track2"].opacity = 25
		
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
		@racerStartingX = 100 #this is where all racers will start, and the "camera" will stay here, focused on the player
		@racingPkmnStartingY = 52
		
		###################################
		#============= Racer1 =============
		###################################
		filename = "Followers/CRUSTANG"
		@sprites["racer1Pkmn"] = TrainerWalkingCharSprite.new(filename, @viewport)
		charwidth  = @sprites["racer1Pkmn"].bitmap.width
		charheight = @sprites["racer1Pkmn"].bitmap.height
		@sprites["racer1Pkmn"].x        = @racerStartingX# - (charwidth / 8)
		@sprites["racer1Pkmn"].y        = @racingPkmnStartingY# - (charheight / 8)
		@sprites["racer1Pkmn"].z = 99999
		#sprite turn right
		@sprites["racer1Pkmn"].src_rect = Rect.new(0, 128, charwidth / 4, charheight / 4)
		@racer1[:RacerSprite] = @sprites["racer1Pkmn"]
		@racingPkmnStartingY += 72
		
		###################################
		#============= Player =============
		###################################
		filename = "Followers/CRUSTANG"
		@sprites["racerPlayerPkmn"] = TrainerWalkingCharSprite.new(filename, @viewport)
		charwidth  = @sprites["racerPlayerPkmn"].bitmap.width
		charheight = @sprites["racerPlayerPkmn"].bitmap.height
		@sprites["racerPlayerPkmn"].x        = @racerStartingX# - (charwidth / 8)
		@sprites["racerPlayerPkmn"].y        = @racingPkmnStartingY# - (charheight / 8)
		@sprites["racerPlayerPkmn"].z = 99999
		#sprite turn right
		@sprites["racerPlayerPkmn"].src_rect = Rect.new(0, 128, charwidth / 4, charheight / 4)
		@racerPlayer[:RacerSprite] = @sprites["racerPlayerPkmn"]
		
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
	
	def self.setMiscVariables
		#the below is how much to decrease speed per frame to reach the desired speed in 3 seconds
		@accelerationAmountPerFrame = CrustangRacingSettings::TOP_BASE_SPEED.to_f / (CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED.to_f * Graphics.frame_rate.to_f)
		#print @accelerationAmountPerFrame
		
		#the below is how much to increase speed per frame to reach the desired speed in 3 seconds
		@decelerationAmountPerFrame = CrustangRacingSettings::BOOST_SPEED / (CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED.to_f * Graphics.frame_rate.to_f)		
	end #def self.setMiscVariables
	
	def self.setupRacerHashes
		#set up racer hashes
		@racer1 = {
			#racer sprite
			RacerSprite: nil,
			#boost button sprites & cooldown timer
			BoostButtonSprite: nil, BoostCooldownTimer: 0, BoostButtonCooldownMaskSprite: nil,
			#moves, move effects, cooldown timers, & move sprites
			Move1: nil, Move1Effect: nil, Move1CooldownTimer: 0, Move1ButtonSprite: nil, Move2: nil, Move2Effect: nil, Move2CooldownTimer: 0, Move2ButtonSprite: nil, Move3: nil, Move3Effect: nil, Move3CooldownTimer: 0, Move3ButtonSprite: nil, Move4: nil, Move4Effect: nil, Move4CooldownTimer: 0, Move4ButtonSprite: nil, 
			#track positioning & speed
			PositionOnTrack: 0, CurrentSpeed: 0, DesiredSpeed: 0, BoostTimer: 0,
			#track overview positioning
			PointOnTrackOverview: nil, PositionXOnTrackOverview: nil, PositionYOnTrackOverview: nil, RacerTrackOverviewSprite: nil,
			#laps and Placement
			Lapping: true, LapCount: 0, CurrentPlacement: 1,
		}
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
			PositionOnTrack: 0, CurrentSpeed: 0, DesiredSpeed: 0, BoostTimer: 0,
			#track overview positioning
			PointOnTrackOverview: nil, PositionXOnTrackOverview: nil, PositionYOnTrackOverview: nil, RacerTrackOverviewSprite: nil,
			#laps and Placement
			Lapping: true, LapCount: 0, CurrentPlacement: 1,
		}
	end #def self.setupRacerHashes
	
end #class CrustangRacing