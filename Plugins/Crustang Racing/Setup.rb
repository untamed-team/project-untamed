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
		
		#bottom of the track where objects appear over the player
		@sprites["track2Bottom"] = IconSprite.new(0, 0, @viewport)
		@sprites["track2Bottom"].setBitmap("Graphics/Pictures/Crustang Racing/" + trackFilename + "Bottom")
		@sprites["track2Bottom"].x = 0
		@sprites["track2Bottom"].y = Graphics.height - @sprites["track2Bottom"].height
		@sprites["track2Bottom"].z = 999991
		#@sprites["track2Bottom"].visible = false
		
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
		
		@sprites["racer1SpinOutRange"] = BitmapSprite.new(CrustangRacingSettings::SPINOUT_MAX_RANGE, CrustangRacingSettings::SPINOUT_MAX_RANGE, @viewport)
		@sprites["racer1SpinOutRange"].x = @racer1[:RacerSprite].x - @sprites["racer1SpinOutRange"].width / 2
		@sprites["racer1SpinOutRange"].y = @racer1[:RacerSprite].y - @sprites["racer1SpinOutRange"].height / 2
		@sprites["racer1SpinOutRange"].z = 999999
		@sprites["racer1SpinOutRange"].visible = false
		@sprites["racer1SpinOutRange"].opacity = 100
		@racer1[:SpinOutRangeSprite] = @sprites["racer1SpinOutRange"]
		
		@sprites["racer1OverloadRange"] = BitmapSprite.new(CrustangRacingSettings::OVERLOAD_MAX_RANGE, CrustangRacingSettings::OVERLOAD_MAX_RANGE, @viewport)
		@sprites["racer1OverloadRange"].x = @racer1[:RacerSprite].x - @sprites["racer1OverloadRange"].width / 2
		@sprites["racer1OverloadRange"].y = @racer1[:RacerSprite].y - @sprites["racer1OverloadRange"].height / 2
		@sprites["racer1OverloadRange"].z = 999999
		@sprites["racer1OverloadRange"].visible = false
		@sprites["racer1OverloadRange"].opacity = 100
		@racer1[:OverloadRangeSprite] = @sprites["racer1OverloadRange"]
		
		@racingPkmnStartingY += 72
		
		###################################
		#============= Racer2 =============
		###################################
		filename = "Followers/CRUSTANG"
		@sprites["racer2Pkmn"] = TrainerWalkingCharSprite.new(filename, @viewport)
		charwidth  = @sprites["racer2Pkmn"].bitmap.width
		charheight = @sprites["racer2Pkmn"].bitmap.height
		@sprites["racer2Pkmn"].x        = @racerStartingX# - (charwidth / 8)
		@sprites["racer2Pkmn"].y        = @racingPkmnStartingY# - (charheight / 8)
		@sprites["racer2Pkmn"].z = 99999
		#sprite turn right
		@sprites["racer2Pkmn"].src_rect = Rect.new(0, 128, charwidth / 4, charheight / 4)
		@racer2[:RacerSprite] = @sprites["racer2Pkmn"]
		
		@sprites["racer2SpinOutRange"] = BitmapSprite.new(CrustangRacingSettings::SPINOUT_MAX_RANGE, CrustangRacingSettings::SPINOUT_MAX_RANGE, @viewport)
		@sprites["racer2SpinOutRange"].x = @racer2[:RacerSprite].x - @sprites["racer2SpinOutRange"].width / 2
		@sprites["racer2SpinOutRange"].y = @racer2[:RacerSprite].y - @sprites["racer2SpinOutRange"].height / 2
		@sprites["racer2SpinOutRange"].z = 999999
		@sprites["racer2SpinOutRange"].visible = false
		@sprites["racer2SpinOutRange"].opacity = 100
		@racer2[:SpinOutRangeSprite] = @sprites["racer2SpinOutRange"]
		
		@sprites["racer2OverloadRange"] = BitmapSprite.new(CrustangRacingSettings::OVERLOAD_MAX_RANGE, CrustangRacingSettings::OVERLOAD_MAX_RANGE, @viewport)
		@sprites["racer2OverloadRange"].x = @racer2[:RacerSprite].x - @sprites["racer2OverloadRange"].width / 2
		@sprites["racer2OverloadRange"].y = @racer2[:RacerSprite].y - @sprites["racer2OverloadRange"].height / 2
		@sprites["racer2OverloadRange"].z = 999999
		@sprites["racer2OverloadRange"].visible = false
		@sprites["racer2OverloadRange"].opacity = 100
		@racer2[:OverloadRangeSprite] = @sprites["racer2OverloadRange"]
		
		@racingPkmnStartingY += 72
		
		###################################
		#============= Racer3 =============
		###################################
		filename = "Followers/CRUSTANG"
		@sprites["racer3Pkmn"] = TrainerWalkingCharSprite.new(filename, @viewport)
		charwidth  = @sprites["racer3Pkmn"].bitmap.width
		charheight = @sprites["racer3Pkmn"].bitmap.height
		@sprites["racer3Pkmn"].x        = @racerStartingX# - (charwidth / 8)
		@sprites["racer3Pkmn"].y        = @racingPkmnStartingY# - (charheight / 8)
		@sprites["racer3Pkmn"].z = 99999
		#sprite turn right
		@sprites["racer3Pkmn"].src_rect = Rect.new(0, 128, charwidth / 4, charheight / 4)
		@racer3[:RacerSprite] = @sprites["racer3Pkmn"]
		
		@sprites["racer3SpinOutRange"] = BitmapSprite.new(CrustangRacingSettings::SPINOUT_MAX_RANGE, CrustangRacingSettings::SPINOUT_MAX_RANGE, @viewport)
		@sprites["racer3SpinOutRange"].x = @racer3[:RacerSprite].x - @sprites["racer3SpinOutRange"].width / 2
		@sprites["racer3SpinOutRange"].y = @racer3[:RacerSprite].y - @sprites["racer3SpinOutRange"].height / 2
		@sprites["racer3SpinOutRange"].z = 999999
		@sprites["racer3SpinOutRange"].visible = false
		@sprites["racer3SpinOutRange"].opacity = 100
		@racer3[:SpinOutRangeSprite] = @sprites["racer3SpinOutRange"]
		
		@sprites["racer3OverloadRange"] = BitmapSprite.new(CrustangRacingSettings::OVERLOAD_MAX_RANGE, CrustangRacingSettings::OVERLOAD_MAX_RANGE, @viewport)
		@sprites["racer3OverloadRange"].x = @racer3[:RacerSprite].x - @sprites["racer3OverloadRange"].width / 2
		@sprites["racer3OverloadRange"].y = @racer3[:RacerSprite].y - @sprites["racer3OverloadRange"].height / 2
		@sprites["racer3OverloadRange"].z = 999999
		@sprites["racer3OverloadRange"].visible = false
		@sprites["racer3OverloadRange"].opacity = 100
		@racer3[:OverloadRangeSprite] = @sprites["racer3OverloadRange"]
		
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
		
		@sprites["racerPlayerSpinOutRange"] = BitmapSprite.new(CrustangRacingSettings::SPINOUT_MAX_RANGE, CrustangRacingSettings::SPINOUT_MAX_RANGE, @viewport)
		@sprites["racerPlayerSpinOutRange"].x = @racerPlayer[:RacerSprite].x - @sprites["racerPlayerSpinOutRange"].width / 2
		@sprites["racerPlayerSpinOutRange"].y = @racerPlayer[:RacerSprite].y - @sprites["racerPlayerSpinOutRange"].height / 2
		@sprites["racerPlayerSpinOutRange"].z = 999999
		@sprites["racerPlayerSpinOutRange"].visible = false
		@sprites["racerPlayerSpinOutRange"].opacity = 100
		@racerPlayer[:SpinOutRangeSprite] = @sprites["racerPlayerSpinOutRange"]
		
		@sprites["racerPlayerOverloadRange"] = BitmapSprite.new(CrustangRacingSettings::OVERLOAD_MAX_RANGE, CrustangRacingSettings::OVERLOAD_MAX_RANGE, @viewport)
		@sprites["racerPlayerOverloadRange"].x = @racerPlayer[:RacerSprite].x - @sprites["racerPlayerOverloadRange"].width / 2
		@sprites["racerPlayerOverloadRange"].y = @racerPlayer[:RacerSprite].y - @sprites["racerPlayerOverloadRange"].height / 2
		@sprites["racerPlayerOverloadRange"].z = 999999
		@sprites["racerPlayerOverloadRange"].visible = false
		@sprites["racerPlayerOverloadRange"].opacity = 100
		@racerPlayer[:OverloadRangeSprite] = @sprites["racerPlayerOverloadRange"]
		
	end #def drawContestants
	
	def self.drawMovesUI
		###################################
		#========== Boost Button ==========
		###################################
		#animname, framecount, framewidth, frameheight, frameskip
		@sprites["boostButton"] = AnimatedSprite.create("Graphics/Pictures/Crustang Racing/boost button", 2, 86, @viewport)
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
		number = @racerPlayer[:BoostButtonSprite].height.percent_of(CrustangRacingSettings::BOOST_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate)
		@boostCooldownPixelsToMovePerFrame = number / 100
		
		#draw text over button saying how to use it
		@sprites["boostButtonTextOverlay"] = BitmapSprite.new(Graphics.width/2, Graphics.height/2, @viewport)
		@sprites["boostButtonTextOverlay"].x = @racerPlayer[:BoostButtonSprite].x + @racerPlayer[:BoostButtonSprite].width/2 + 8
		@sprites["boostButtonTextOverlay"].y = @racerPlayer[:BoostButtonSprite].y + @racerPlayer[:BoostButtonSprite].height - 14
		@sprites["boostButtonTextOverlay"].z = 999999
		@boostButtonTextOverlay = @sprites["boostButtonTextOverlay"].bitmap
		pbSetSystemFont(@boostButtonTextOverlay)
		@boostButtonTextOverlay.font.size = MessageConfig::SMALL_FONT_SIZE
		drawFormattedTextEx(@boostButtonTextOverlay, 0, 4, Graphics.width, "#{$PokemonSystem.game_controls.find{|c| c.control_action=="Registered Item"}.key_name}", @overlayBaseColor, @overlayShadowColor)
		
		#draw moves depending on what racer knows
		#for now, draw specific moves, 4 at a time for testing
		###################################
		#============= Move 1 =============
		###################################
		#animname, framecount, framewidth, frameheight, frameskip
		filename = "button_#{@racerPlayer[:Move1][:EffectCode]}"
		@sprites["move1Button"] = AnimatedSprite.create("Graphics/Pictures/Crustang Racing/#{filename}", 2, 38, @viewport)
		@sprites["move1Button"].x = @racerPlayer[:BoostButtonSprite].x + @racerPlayer[:BoostButtonSprite].width + @sprites["move1Button"].width/3
		@sprites["move1Button"].y = Graphics.height - @sprites["move1Button"].height - 4
		@sprites["move1Button"].z = 999999

		@racerPlayer[:Move1ButtonSprite] = @sprites["move1Button"]
		
		#draw cooldown mask
		@racerPlayer[:Move1ButtonCooldownMaskSprite] = IconSprite.new(0, 0, @viewport)
		@racerPlayer[:Move1ButtonCooldownMaskSprite].setBitmap("Graphics/Pictures/Crustang Racing/move_button_msak")
		@racerPlayer[:Move1ButtonCooldownMaskSprite].x = @racerPlayer[:Move1ButtonSprite].x
		@racerPlayer[:Move1ButtonCooldownMaskSprite].y = @racerPlayer[:Move1ButtonSprite].y
		@racerPlayer[:Move1ButtonCooldownMaskSprite].z = 999999
		@racerPlayer[:Move1ButtonCooldownMaskSprite].opacity = 100
		@racerPlayer[:Move1ButtonCooldownMaskSprite].src_rect = Rect.new(0, 0, @racerPlayer[:Move1ButtonCooldownMaskSprite].width, 0)
		
		#numbers for cooldown mask
		number = @racerPlayer[:Move1ButtonSprite].height.percent_of(CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate)
		@move1CooldownPixelsToMovePerFrame = number / 100
		
		#draw text over button saying how to use it
		@sprites["move1ButtonTextOverlay"] = BitmapSprite.new(Graphics.width/2, Graphics.height/2, @viewport)
		@sprites["move1ButtonTextOverlay"].x = @racerPlayer[:Move1ButtonSprite].x + @racerPlayer[:Move1ButtonSprite].width/2 + 8
		@sprites["move1ButtonTextOverlay"].y = @racerPlayer[:Move1ButtonSprite].y + @racerPlayer[:Move1ButtonSprite].height - 14
		@sprites["move1ButtonTextOverlay"].z = 999999
		@move1ButtonTextOverlay = @sprites["move1ButtonTextOverlay"].bitmap
		pbSetSystemFont(@move1ButtonTextOverlay)
		@move1ButtonTextOverlay.font.size = MessageConfig::SMALL_FONT_SIZE
		drawFormattedTextEx(@move1ButtonTextOverlay, 0, 4, Graphics.width, "Z", @overlayBaseColor, @overlayShadowColor)
		
		###################################
		#============= Move 2 =============
		###################################
		if !@racerPlayer[:Move2].nil?
			#animname, framecount, framewidth, frameheight, frameskip
			filename = "button_#{@racerPlayer[:Move2][:EffectCode]}"
			@sprites["move2Button"] = AnimatedSprite.create("Graphics/Pictures/Crustang Racing/#{filename}", 2, 38, @viewport)
			@sprites["move2Button"].x = @racerPlayer[:Move1ButtonSprite].x + @racerPlayer[:Move1ButtonSprite].width + @sprites["move2Button"].width/3
			@sprites["move2Button"].y = Graphics.height - @sprites["move2Button"].height - 4
			@sprites["move2Button"].z = 999999

			@racerPlayer[:Move2ButtonSprite] = @sprites["move2Button"]
		
			#draw cooldown mask
			@racerPlayer[:Move2ButtonCooldownMaskSprite] = IconSprite.new(0, 0, @viewport)
			@racerPlayer[:Move2ButtonCooldownMaskSprite].setBitmap("Graphics/Pictures/Crustang Racing/move_button_msak")
			@racerPlayer[:Move2ButtonCooldownMaskSprite].x = @racerPlayer[:Move2ButtonSprite].x
			@racerPlayer[:Move2ButtonCooldownMaskSprite].y = @racerPlayer[:Move2ButtonSprite].y
			@racerPlayer[:Move2ButtonCooldownMaskSprite].z = 999999
			@racerPlayer[:Move2ButtonCooldownMaskSprite].opacity = 100
			@racerPlayer[:Move2ButtonCooldownMaskSprite].src_rect = Rect.new(0, 0, @racerPlayer[:Move2ButtonCooldownMaskSprite].width, 0)
		
			#numbers for cooldown mask
			number = @racerPlayer[:Move2ButtonSprite].height.percent_of(CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate)
			@move2CooldownPixelsToMovePerFrame = number / 100
		
			#draw text over button saying how to use it
			@sprites["move2ButtonTextOverlay"] = BitmapSprite.new(Graphics.width/2, Graphics.height/2, @viewport)
			@sprites["move2ButtonTextOverlay"].x = @racerPlayer[:Move2ButtonSprite].x + @racerPlayer[:Move2ButtonSprite].width/2 + 8
			@sprites["move2ButtonTextOverlay"].y = @racerPlayer[:Move2ButtonSprite].y + @racerPlayer[:Move2ButtonSprite].height - 14
			@sprites["move2ButtonTextOverlay"].z = 999999
			@move2ButtonTextOverlay = @sprites["move2ButtonTextOverlay"].bitmap
			pbSetSystemFont(@move2ButtonTextOverlay)
			@move2ButtonTextOverlay.font.size = MessageConfig::SMALL_FONT_SIZE
			drawFormattedTextEx(@move2ButtonTextOverlay, 0, 4, Graphics.width, "X", @overlayBaseColor, @overlayShadowColor)
		end #if !@racerPlayer[:Move2].nil?
		
		###################################
		#============= Move 3 =============
		###################################
		if !@racerPlayer[:Move3].nil?
			#animname, framecount, framewidth, frameheight, frameskip
			filename = "button_#{@racerPlayer[:Move3][:EffectCode]}"
			@sprites["move3Button"] = AnimatedSprite.create("Graphics/Pictures/Crustang Racing/#{filename}", 2, 38, @viewport)
			@sprites["move3Button"].x = @racerPlayer[:Move2ButtonSprite].x + @racerPlayer[:Move2ButtonSprite].width + @sprites["move3Button"].width/3
			@sprites["move3Button"].y = Graphics.height - @sprites["move3Button"].height - 4
			@sprites["move3Button"].z = 999999

			@racerPlayer[:Move3ButtonSprite] = @sprites["move3Button"]
		
			#draw cooldown mask
			@racerPlayer[:Move3ButtonCooldownMaskSprite] = IconSprite.new(0, 0, @viewport)
			@racerPlayer[:Move3ButtonCooldownMaskSprite].setBitmap("Graphics/Pictures/Crustang Racing/move_button_msak")
			@racerPlayer[:Move3ButtonCooldownMaskSprite].x = @racerPlayer[:Move3ButtonSprite].x
			@racerPlayer[:Move3ButtonCooldownMaskSprite].y = @racerPlayer[:Move3ButtonSprite].y
			@racerPlayer[:Move3ButtonCooldownMaskSprite].z = 999999
			@racerPlayer[:Move3ButtonCooldownMaskSprite].opacity = 100
			@racerPlayer[:Move3ButtonCooldownMaskSprite].src_rect = Rect.new(0, 0, @racerPlayer[:Move3ButtonCooldownMaskSprite].width, 0)
		
			#numbers for cooldown mask
			number = @racerPlayer[:Move3ButtonSprite].height.percent_of(CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate)
			@move3CooldownPixelsToMovePerFrame = number / 100
		
			#draw text over button saying how to use it
			@sprites["move3ButtonTextOverlay"] = BitmapSprite.new(Graphics.width/2, Graphics.height/2, @viewport)
			@sprites["move3ButtonTextOverlay"].x = @racerPlayer[:Move3ButtonSprite].x + @racerPlayer[:Move3ButtonSprite].width/2 + 8
			@sprites["move3ButtonTextOverlay"].y = @racerPlayer[:Move3ButtonSprite].y + @racerPlayer[:Move3ButtonSprite].height - 14
			@sprites["move3ButtonTextOverlay"].z = 999999
			@move3ButtonTextOverlay = @sprites["move3ButtonTextOverlay"].bitmap
			pbSetSystemFont(@move3ButtonTextOverlay)
			@move3ButtonTextOverlay.font.size = MessageConfig::SMALL_FONT_SIZE
			drawFormattedTextEx(@move3ButtonTextOverlay, 0, 4, Graphics.width, "C", @overlayBaseColor, @overlayShadowColor)
		end #if !@racerPlayer[:Move3].nil?
		
		###################################
		#============= Move 4 =============
		###################################
		if !@racerPlayer[:Move4].nil?
			#animname, framecount, framewidth, frameheight, frameskip
			filename = "button_#{@racerPlayer[:Move4][:EffectCode]}"
			@sprites["move4Button"] = AnimatedSprite.create("Graphics/Pictures/Crustang Racing/#{filename}", 2, 38, @viewport)
			@sprites["move4Button"].x = @racerPlayer[:Move3ButtonSprite].x + @racerPlayer[:Move3ButtonSprite].width + @sprites["move4Button"].width/3
			@sprites["move4Button"].y = Graphics.height - @sprites["move4Button"].height - 4
			@sprites["move4Button"].z = 999999

			@racerPlayer[:Move4ButtonSprite] = @sprites["move4Button"]
		
			#draw cooldown mask
			@racerPlayer[:Move4ButtonCooldownMaskSprite] = IconSprite.new(0, 0, @viewport)
			@racerPlayer[:Move4ButtonCooldownMaskSprite].setBitmap("Graphics/Pictures/Crustang Racing/move_button_msak")
			@racerPlayer[:Move4ButtonCooldownMaskSprite].x = @racerPlayer[:Move4ButtonSprite].x
			@racerPlayer[:Move4ButtonCooldownMaskSprite].y = @racerPlayer[:Move4ButtonSprite].y
			@racerPlayer[:Move4ButtonCooldownMaskSprite].z = 999999
			@racerPlayer[:Move4ButtonCooldownMaskSprite].opacity = 100
			@racerPlayer[:Move4ButtonCooldownMaskSprite].src_rect = Rect.new(0, 0, @racerPlayer[:Move4ButtonCooldownMaskSprite].width, 0)
		
			#numbers for cooldown mask
			number = @racerPlayer[:Move4ButtonSprite].height.percent_of(CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate)
			@move4CooldownPixelsToMovePerFrame = number / 100
		
			#draw text over button saying how to use it
			@sprites["move4ButtonTextOverlay"] = BitmapSprite.new(Graphics.width/2, Graphics.height/2, @viewport)
			@sprites["move4ButtonTextOverlay"].x = @racerPlayer[:Move4ButtonSprite].x + @racerPlayer[:Move4ButtonSprite].width/2 + 8
			@sprites["move4ButtonTextOverlay"].y = @racerPlayer[:Move4ButtonSprite].y + @racerPlayer[:Move4ButtonSprite].height - 14
			@sprites["move4ButtonTextOverlay"].z = 999999
			@move4ButtonTextOverlay = @sprites["move4ButtonTextOverlay"].bitmap
			pbSetSystemFont(@move4ButtonTextOverlay)
			@move4ButtonTextOverlay.font.size = MessageConfig::SMALL_FONT_SIZE
			drawFormattedTextEx(@move4ButtonTextOverlay, 0, 4, Graphics.width, "V", @overlayBaseColor, @overlayShadowColor)
		end #if !@racerPlayer[:Move4].nil?
	end #def self.drawMovesUI
	
	def self.setMiscVariables
		@accelerationAmountPerFrameForNormalTopSpeed = CrustangRacingSettings::TOP_BASE_SPEED.to_f / (CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED.to_f * Graphics.frame_rate.to_f)
		@decelerationAmountPerFrameForNormalTopSpeed = CrustangRacingSettings::BOOST_SPEED / (CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED.to_f * Graphics.frame_rate.to_f)
		
		@startingCooldownMultiplier = true
		
		@framesBetweenSpinOutDirections = (Graphics.frame_rate / CrustangRacingSettings::SPINOUT_ROTATIONS_PER_SECOND) / 4
		
		#for spinout animation
		@totalSpins = CrustangRacingSettings::SPINOUT_DURATION_IN_SECONDS + CrustangRacingSettings::SPINOUT_ROTATIONS_PER_SECOND
		@amountToSpin = 360/(CrustangRacingSettings::SPINOUT_DURATION_IN_SECONDS * Graphics.frame_rate)
		
		#for invincible status - changing sprite tone
		@hues = {
			Red: [250, 0, 0],#Red: [255, 0, 0],
			Orange: [250, 130, 0],#Orange: [255, 127, 0],
			Yellow: [250, 250, 0],#Yellow: [255, 255, 0],
			Green: [0, 250, 0],#Green: [0, 255, 0],
			Blue: [0, 0, 250],#Blue: [0, 0, 255],
			Indigo: [80, 0, 130],#Indigo: [75, 0, 130],
			Violet: [150, 0, 210]#Violet: [148, 0, 211]
		}
		
		#for helping us cancel a move if pressing more than one button at once
		@pressingMove1 = false
		@pressingMove2 = false
		@pressingMove3 = false
		@pressingMove4 = false
		@cancellingMove = nil
		
		#so we don't overlap SEs and get a very loud noise if multiple of the same SE are played at the same time
		@currentlyPlayingSETimer = 0
		@currentlyPlayingSE = nil
	end #def self.setMiscVariables
	
	def self.setupRacerHashes
		#set up racer hashes
		@racer1 = {
			EnteredCrustangContestant: CrustangRacingSettings::CONTESTANTS[0],
			#racer sprite
			RacerSprite: nil,
			#boost button sprites & cooldown timer
			BoostButtonSprite: nil, BoostCooldownTimer: CrustangRacingSettings::BOOST_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate, BoostButtonCooldownMaskSprite: nil, BoostCooldownMultiplier: CrustangRacingSettings::BOOST_BUTTON_COOLDOWN_SECONDS / CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED, BoostingStatus: false,
			#moves, move effects, cooldown timers, & move sprites
			Move1: nil, Move1CooldownTimer: CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate, Move1ButtonSprite: nil, Move2: nil, Move2CooldownTimer: CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate, Move2ButtonSprite: nil, Move3: nil, Move3CooldownTimer: CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate, Move3ButtonSprite: nil, Move4: nil, Move4CooldownTimer: CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate, Move4ButtonSprite: nil, MoveCoolDownMultiplier: CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS / CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED, ReduceCooldownCount: 0, SecondaryBoostTimer: 0, SpinOutRangeSprite: nil, SpinOutTimer: 0, SpinOutDirectionTimer: 0, SpinOutCharge: CrustangRacingSettings::SPINOUT_MIN_RANGE, DesiredHue: nil, InvincibilityTimer: 0, InvincibilityStatus: false, OverloadRangeSprite: nil, OverloadTimer: 0, OverloadCharge: CrustangRacingSettings::OVERLOAD_MIN_RANGE,
			#track positioning & speed
			PositionOnTrack: 0, PreviousPositionOnTrack: 0, CurrentSpeed: 0, DesiredSpeed: CrustangRacingSettings::TOP_BASE_SPEED.floor, BoostTimer: 0, PreviousDesiredSpeed: CrustangRacingSettings::TOP_BASE_SPEED.floor, Bumped: false, BumpedRecoveryTimer: 0, StrafeSpeed: CrustangRacingSettings::BASE_STRAFE_SPEED, Overloaded: false,
			#track overview positioning
			PointOnTrackOverview: nil, PositionXOnTrackOverview: nil, PositionYOnTrackOverview: nil, RacerTrackOverviewSprite: nil,
			#laps and Placement
			LapCount: 0, CurrentPlacement: 1, LapAndPlacement: 0,
			#hazards
			RockHazard: {Sprite: nil, OriginalPositionXOnScreen: nil, PositionXOnTrack: nil, PositionYOnTrack: nil, OverviewSprite: nil, PositionXOnTrackOverview: nil, PositionYOnTrackOverview: nil,}, MudHazard: {Sprite: nil, PositionXOnTrack: nil, PositionYOnTrack: nil,},
		}
		@racer2 = {
			EnteredCrustangContestant: CrustangRacingSettings::CONTESTANTS[1],
			#racer sprite
			RacerSprite: nil,
			#boost button sprites & cooldown timer
			BoostButtonSprite: nil, BoostCooldownTimer: CrustangRacingSettings::BOOST_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate, BoostButtonCooldownMaskSprite: nil, BoostCooldownMultiplier: CrustangRacingSettings::BOOST_BUTTON_COOLDOWN_SECONDS / CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED, BoostingStatus: false,
			#moves, move effects, cooldown timers, & move sprites
			Move1: nil, Move1CooldownTimer: CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate, Move1ButtonSprite: nil, Move2: nil, Move2CooldownTimer: CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate, Move2ButtonSprite: nil, Move3: nil, Move3CooldownTimer: CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate, Move3ButtonSprite: nil, Move4: nil, Move4CooldownTimer: CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate, Move4ButtonSprite: nil, MoveCoolDownMultiplier: CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS / CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED, ReduceCooldownCount: 0, SecondaryBoostTimer: 0, SpinOutRangeSprite: nil, SpinOutTimer: 0, SpinOutDirectionTimer: 0, SpinOutCharge: CrustangRacingSettings::SPINOUT_MIN_RANGE, DesiredHue: nil, InvincibilityTimer: 0, InvincibilityStatus: false, OverloadRangeSprite: nil, OverloadTimer: 0, OverloadCharge: CrustangRacingSettings::OVERLOAD_MIN_RANGE,
			#track positioning & speed
			PositionOnTrack: 0, PreviousPositionOnTrack: 0, CurrentSpeed: 0, DesiredSpeed: CrustangRacingSettings::TOP_BASE_SPEED.floor, BoostTimer: 0, PreviousDesiredSpeed: CrustangRacingSettings::TOP_BASE_SPEED.floor, Bumped: false, BumpedRecoveryTimer: 0, StrafeSpeed: CrustangRacingSettings::BASE_STRAFE_SPEED, Overloaded: false,
			#track overview positioning
			PointOnTrackOverview: nil, PositionXOnTrackOverview: nil, PositionYOnTrackOverview: nil, RacerTrackOverviewSprite: nil,
			#laps and Placement
			LapCount: 0, CurrentPlacement: 1, LapAndPlacement: 0,
			#hazards
			RockHazard: {Sprite: nil, OriginalPositionXOnScreen: nil, PositionXOnTrack: nil, PositionYOnTrack: nil, OverviewSprite: nil, PositionXOnTrackOverview: nil, PositionYOnTrackOverview: nil,}, MudHazard: {Sprite: nil, PositionXOnTrack: nil, PositionYOnTrack: nil,},
		}
		@racer3 = {
			EnteredCrustangContestant: CrustangRacingSettings::CONTESTANTS[2],
			#racer sprite
			RacerSprite: nil,
			#boost button sprites & cooldown timer
			BoostButtonSprite: nil, BoostCooldownTimer: CrustangRacingSettings::BOOST_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate, BoostButtonCooldownMaskSprite: nil, BoostCooldownMultiplier: CrustangRacingSettings::BOOST_BUTTON_COOLDOWN_SECONDS / CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED, BoostingStatus: false,
			#moves, move effects, cooldown timers, & move sprites
			Move1: nil, Move1CooldownTimer: CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate, Move1ButtonSprite: nil, Move2: nil, Move2CooldownTimer: CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate, Move2ButtonSprite: nil, Move3: nil, Move3CooldownTimer: CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate, Move3ButtonSprite: nil, Move4: nil, Move4CooldownTimer: CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate, Move4ButtonSprite: nil, MoveCoolDownMultiplier: CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS / CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED, ReduceCooldownCount: 0, SecondaryBoostTimer: 0, SpinOutRangeSprite: nil, SpinOutTimer: 0, SpinOutDirectionTimer: 0, SpinOutCharge: CrustangRacingSettings::SPINOUT_MIN_RANGE, DesiredHue: nil, InvincibilityTimer: 0, InvincibilityStatus: false, OverloadRangeSprite: nil, OverloadTimer: 0, OverloadCharge: CrustangRacingSettings::OVERLOAD_MIN_RANGE,
			#track positioning & speed
			PositionOnTrack: 0, PreviousPositionOnTrack: 0, CurrentSpeed: 0, DesiredSpeed: CrustangRacingSettings::TOP_BASE_SPEED.floor, BoostTimer: 0, PreviousDesiredSpeed: CrustangRacingSettings::TOP_BASE_SPEED.floor, Bumped: false, BumpedRecoveryTimer: 0, StrafeSpeed: CrustangRacingSettings::BASE_STRAFE_SPEED, Overloaded: false,
			#track overview positioning
			PointOnTrackOverview: nil, PositionXOnTrackOverview: nil, PositionYOnTrackOverview: nil, RacerTrackOverviewSprite: nil,
			#laps and Placement
			LapCount: 0, CurrentPlacement: 1, LapAndPlacement: 0,
			#hazards
			RockHazard: {Sprite: nil, OriginalPositionXOnScreen: nil, PositionXOnTrack: nil, PositionYOnTrack: nil, OverviewSprite: nil, PositionXOnTrackOverview: nil, PositionYOnTrackOverview: nil,}, MudHazard: {Sprite: nil, PositionXOnTrack: nil, PositionYOnTrack: nil,},
		}
		@racerPlayer = {
			#racer sprite
			RacerSprite: nil,
			#boost button sprites & cooldown timer
			BoostButtonSprite: nil, BoostCooldownTimer: CrustangRacingSettings::BOOST_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate, BoostButtonCooldownMaskSprite: nil, BoostCooldownMultiplier: CrustangRacingSettings::BOOST_BUTTON_COOLDOWN_SECONDS / CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED, BoostingStatus: false,
			#moves, move effects, cooldown timers, & move sprites
			Move1: nil, Move1CooldownTimer: CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate, Move1ButtonSprite: nil, Move1ButtonCooldownMaskSprite: nil, Move2: nil, Move2CooldownTimer: CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate, Move2ButtonSprite: nil, Move2ButtonCooldownMaskSprite: nil, Move3: nil, Move3CooldownTimer: CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate, Move3ButtonSprite: nil, Move3ButtonCooldownMaskSprite: nil, Move4: nil, Move4CooldownTimer: CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate, Move4ButtonSprite: nil, Move4ButtonCooldownMaskSprite: nil,  MoveCoolDownMultiplier: CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS / CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED, ReduceCooldownCount: 0, SecondaryBoostTimer: 0, SpinOutRangeSprite: nil, SpinOutTimer: 0, SpinOutDirectionTimer: 0, SpinOutCharge: CrustangRacingSettings::SPINOUT_MIN_RANGE, DesiredHue: nil, InvincibilityTimer: 0, InvincibilityStatus: false, OverloadRangeSprite: nil, OverloadTimer: 0, OverloadCharge: CrustangRacingSettings::OVERLOAD_MIN_RANGE,
			#track positioning & speed
			PositionOnTrack: 0, PreviousPositionOnTrack: 0, CurrentSpeed: 0, DesiredSpeed: CrustangRacingSettings::TOP_BASE_SPEED.floor, BoostTimer: 0, PreviousDesiredSpeed: CrustangRacingSettings::TOP_BASE_SPEED.floor, Bumped: false, BumpedRecoveryTimer: 0, StrafeSpeed: CrustangRacingSettings::BASE_STRAFE_SPEED, Overloaded: false,
			#track overview positioning
			PointOnTrackOverview: nil, PositionXOnTrackOverview: nil, PositionYOnTrackOverview: nil, RacerTrackOverviewSprite: nil,
			#laps and Placement
			LapCount: 0, CurrentPlacement: 1, LapAndPlacement: 0,
			#hazards
			RockHazard: {Sprite: nil, OriginalPositionXOnScreen: nil, PositionXOnTrack: nil, PositionYOnTrack: nil, OverviewSprite: nil, PositionXOnTrackOverview: nil, PositionYOnTrackOverview: nil,}, MudHazard: {Sprite: nil, PositionXOnTrack: nil, PositionYOnTrack: nil,},
		}
	end #def self.setupRacerHashes

end #class CrustangRacing