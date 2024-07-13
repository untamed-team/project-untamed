#Track Setup
class CrustangRacing
	
	def self.detectInput
		Input.update
		
		###################################
		#============ Movement ============
		###################################
		if Input.press?(Input::UP)
			#if colliding with any racer in front or behind
			if self.collides_with_object_behind?(@racerPlayer[:RacerSprite],@racer1[:RacerSprite]) || self.collides_with_object_in_front?(@racerPlayer[:RacerSprite],@racer1[:RacerSprite]) || self.collides_with_object_behind?(@racerPlayer[:RacerSprite],@racer2[:RacerSprite]) || self.collides_with_object_in_front?(@racerPlayer[:RacerSprite],@racer2[:RacerSprite]) || self.collides_with_object_behind?(@racerPlayer[:RacerSprite],@racer3[:RacerSprite]) || self.collides_with_object_in_front?(@racerPlayer[:RacerSprite],@racer3[:RacerSprite])
				#don't restrict up and DOWN
			else
				#if not colliding with something below you and not in front or behind, allow movement
				@racerPlayer[:RacerSprite].y -= CrustangRacingSettings::BASE_STRAFE_SPEED if @racerPlayer[:RacerSprite].y > @trackBorderTopY && !self.collides_with_object_above?(@racerPlayer[:RacerSprite],@racer1[:RacerSprite]) && !self.collides_with_object_above?(@racerPlayer[:RacerSprite],@racer2[:RacerSprite]) && !self.collides_with_object_above?(@racerPlayer[:RacerSprite],@racer3[:RacerSprite])
			end
		elsif Input.press?(Input::DOWN)
			#if colliding with any racer in front or behind
			if self.collides_with_object_behind?(@racerPlayer[:RacerSprite],@racer1[:RacerSprite]) || self.collides_with_object_in_front?(@racerPlayer[:RacerSprite],@racer1[:RacerSprite]) || self.collides_with_object_behind?(@racerPlayer[:RacerSprite],@racer2[:RacerSprite]) || self.collides_with_object_in_front?(@racerPlayer[:RacerSprite],@racer2[:RacerSprite]) || self.collides_with_object_behind?(@racerPlayer[:RacerSprite],@racer3[:RacerSprite]) || self.collides_with_object_in_front?(@racerPlayer[:RacerSprite],@racer3[:RacerSprite])
			else
				#if not colliding with something below you and not in front or behind, allow movement
				@racerPlayer[:RacerSprite].y += CrustangRacingSettings::BASE_STRAFE_SPEED if @racerPlayer[:RacerSprite].y < @trackBorderBottomY && !self.collides_with_object_below?(@racerPlayer[:RacerSprite],@racer1[:RacerSprite]) && !self.collides_with_object_below?(@racerPlayer[:RacerSprite],@racer2[:RacerSprite]) && !self.collides_with_object_below?(@racerPlayer[:RacerSprite],@racer3[:RacerSprite])
			end
		end
		
		###################################
		#============= Boost =============
		###################################
		if Input.press?(CrustangRacingSettings::BOOST_BUTTON) && @racerPlayer[:BoostCooldownTimer] <= 0
			@racerPlayer[:BoostButtonSprite].frame = 1
		end
		if Input.release?(CrustangRacingSettings::BOOST_BUTTON) && @racerPlayer[:BoostCooldownTimer] <= 0
			self.moveEffect(@racerPlayer, 0)
			@racerPlayer[:BoostButtonSprite].frame = 0
		end
		
		###################################
		#============= Moves =============
		###################################
		#move1
		if Input.pressex?(CrustangRacingSettings::MOVE1_BUTTON) && @racerPlayer[:Move1CooldownTimer] <= 0
			@racerPlayer[:Move1ButtonSprite].frame = 1
			@racerPlayer[:SpinOutCharge] += 1 if self.getMoveEffect(1) == "spinOut" && @racerPlayer[:SpinOutCharge] < CrustangRacingSettings::SPINOUT_MAX_RANGE
		end
		if Input.releaseex?(CrustangRacingSettings::MOVE1_BUTTON) && @racerPlayer[:Move1CooldownTimer] <= 0
			self.moveEffect(@racerPlayer, 1)
			self.beginCooldown(@racerPlayer, 1)
			@racerPlayer[:Move1ButtonSprite].frame = 0
			@racerPlayer[:SpinOutCharge] = CrustangRacingSettings::SPINOUT_MIN_RANGE #it doesn't matter if the move is not a spinout move
		end
		#move2
		if Input.triggerex?(CrustangRacingSettings::MOVE2_BUTTON) && @racerPlayer[:Move2CooldownTimer] <= 0
			@racerPlayer[:Move2ButtonSprite].frame = 1
			@racerPlayer[:SpinOutCharge] += 1 if self.getMoveEffect(2) == "spinOut" && @racerPlayer[:SpinOutCharge] < CrustangRacingSettings::SPINOUT_MAX_RANGE
		end
		if Input.releaseex?(CrustangRacingSettings::MOVE2_BUTTON) && @racerPlayer[:Move2CooldownTimer] <= 0
			self.moveEffect(@racerPlayer, 2)
			self.beginCooldown(@racerPlayer, 2)
			@racerPlayer[:Move2ButtonSprite].frame = 0
			@racerPlayer[:SpinOutCharge] = CrustangRacingSettings::SPINOUT_MIN_RANGE
		end
		#move3
		if Input.triggerex?(CrustangRacingSettings::MOVE3_BUTTON) && @racerPlayer[:Move3CooldownTimer] <= 0
			@racerPlayer[:Move3ButtonSprite].frame = 1
			@racerPlayer[:SpinOutCharge] += 1 if self.getMoveEffect(3) == "spinOut" && @racerPlayer[:SpinOutCharge] < CrustangRacingSettings::SPINOUT_MAX_RANGE
		end
		if Input.releaseex?(CrustangRacingSettings::MOVE3_BUTTON) && @racerPlayer[:Move3CooldownTimer] <= 0
			self.moveEffect(@racerPlayer, 3)
			self.beginCooldown(@racerPlayer, 3)
			@racerPlayer[:Move3ButtonSprite].frame = 0
			@racerPlayer[:SpinOutCharge] = CrustangRacingSettings::SPINOUT_MIN_RANGE
		end
		#move4
		if Input.triggerex?(CrustangRacingSettings::MOVE4_BUTTON) && @racerPlayer[:Move4CooldownTimer] <= 0
			@racerPlayer[:Move4ButtonSprite].frame = 1
			@racerPlayer[:SpinOutCharge] += 1 if self.getMoveEffect(4) == "spinOut" && @racerPlayer[:SpinOutCharge] < CrustangRacingSettings::SPINOUT_MAX_RANGE
		end
		if Input.releaseex?(CrustangRacingSettings::MOVE4_BUTTON) && @racerPlayer[:Move4CooldownTimer] <= 0
			self.moveEffect(@racerPlayer, 4)
			self.beginCooldown(@racerPlayer, 4)
			@racerPlayer[:Move4ButtonSprite].frame = 0
			@racerPlayer[:SpinOutCharge] = CrustangRacingSettings::SPINOUT_MIN_RANGE
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
			#@lastCurrentSpeed = @racerPlayer[:CurrentSpeed].truncate(1).to_f      #draw with a decimal place
			@lastCurrentSpeed = @racerPlayer[:CurrentSpeed].floor     #draw with no decimal place
			@khpOverlay.clear
		end
		
		#drawFormattedTextEx(bitmap, x, y, width, text, baseColor = nil, shadowColor = nil, lineheight = 32)
		drawFormattedTextEx(@khpOverlay, 120, 45, Graphics.width, "KM/H: #{@lastCurrentSpeed*CrustangRacingSettings::KPH_MULTIPLIER}", @overlayBaseColor, @overlayShadowColor)
	end #def self.updateOverlayText
		
	def self.moveMiscSprites
		###################################
		#===== Spin Out Range Sprite =====
		###################################
		@racer1[:SpinOutRangeSprite].x = @racer1[:RacerSprite].x - @racer1[:SpinOutRangeSprite].width / 2 + @racer1[:RacerSprite].width / 2
		@racer1[:SpinOutRangeSprite].y = @racer1[:RacerSprite].y - @racer1[:SpinOutRangeSprite].height / 2 + @racer1[:RacerSprite].height / 2
		@racer2[:SpinOutRangeSprite].x = @racer2[:RacerSprite].x - @racer2[:SpinOutRangeSprite].width / 2 + @racer2[:RacerSprite].width / 2
		@racer2[:SpinOutRangeSprite].y = @racer2[:RacerSprite].y - @racer2[:SpinOutRangeSprite].height / 2 + @racer2[:RacerSprite].height / 2
		@racer3[:SpinOutRangeSprite].x = @racer3[:RacerSprite].x - @racer3[:SpinOutRangeSprite].width / 2 + @racer3[:RacerSprite].width / 2
		@racer3[:SpinOutRangeSprite].y = @racer3[:RacerSprite].y - @racer3[:SpinOutRangeSprite].height / 2 + @racer3[:RacerSprite].height / 2
		@racerPlayer[:SpinOutRangeSprite].x = @racerPlayer[:RacerSprite].x - @racerPlayer[:SpinOutRangeSprite].width / 2 + @racerPlayer[:RacerSprite].width / 2
		@racerPlayer[:SpinOutRangeSprite].y = @racerPlayer[:RacerSprite].y - @racerPlayer[:SpinOutRangeSprite].height / 2 + @racerPlayer[:RacerSprite].height / 2
		
	end #def self.moveMiscSprites
	
	def self.trackMovementUpdate #no need to modify
		@sprites["track1"].x -= @racerPlayer[:CurrentSpeed]
		@sprites["track2"].x -= @racerPlayer[:CurrentSpeed]
		
		#track image looping logic
		#if track2 is now on the screen, track2's X is now 0 or less, and track1's X is still < 0, move track1 to the end of track2 for a loop
		if @sprites["track2"].x <= 0 && @sprites["track1"].x < 0
			@sprites["track1"].x = @sprites["track2"].x
			#send track2 to the back of track1
			@sprites["track2"].x = @sprites["track1"].x + @sprites["track1"].width
		end
		
		#hotfix for track2 not being at the correct X
		if @sprites["track1"].x < @sprites["track1"].width - 500 #just a bullshit number not far from 0
			#move track2 to the end of track1 for good measure
			#YOU GET BACK THERE AT THE END RIGHT THIS INSTANT YOUNG SPRITE
			@sprites["track2"].x = @sprites["track1"].x + @sprites["track1"].width
		end
		
		#bottom of the tracks
		@sprites["track1Bottom"].x = @sprites["track1"].x
		@sprites["track2Bottom"].x = @sprites["track2"].x
		
		#lap line
		@sprites["lapLine"].x = @sprites["track1"].x + @lapLineStartingX
		@sprites["lapLineCopy"].x = @sprites["track2"].x + @lapLineStartingX
	end #def trackMovementUpdate
	
	def self.checkForLap
		#Lapping: true, LapCount: 0, CurrentPlacement: 1,
		###################################
		#============= Racer1 =============
		###################################
		@racer1[:LapCount] += 1 if @racer1[:PreviousPositionOnTrack] > @racer1[:PositionOnTrack]
		
		###################################
		#============= Racer2 =============
		###################################
		@racer2[:LapCount] += 1 if @racer2[:PreviousPositionOnTrack] > @racer2[:PositionOnTrack]
		
		###################################
		#============= Racer3 =============
		###################################
		@racer3[:LapCount] += 1 if @racer3[:PreviousPositionOnTrack] > @racer3[:PositionOnTrack]
		
		###################################
		#============= Player =============
		###################################
		@racerPlayer[:LapCount] += 1 if @racerPlayer[:PreviousPositionOnTrack] > @racerPlayer[:PositionOnTrack]
		
	end #def self.checkForLap
		
	def self.updateRacerPositionOnTrack
		#this is the position on the entire track, not the track overview
		###################################
		#============= Player =============
		###################################
		@racerPlayer[:PreviousPositionOnTrack] = @racerPlayer[:PositionOnTrack]
		@racerPlayer[:PositionOnTrack] = @sprites["track1"].x.abs

		#calculate the position of the other racers differently than the player. It would involve their X and the X of the track
		###################################
		#============= Racer1 =============
		###################################
		@racer1[:PreviousPositionOnTrack] = @racer1[:PositionOnTrack]
		@racer1[:PositionOnTrack] += @racer1[:CurrentSpeed].floor
		#reset position to near the beginning of the track when we get to the end of it
		if @racer1[:PositionOnTrack] > @sprites["track1"].width
			amountOverTrackLength = @racer1[:PositionOnTrack] - @sprites["track1"].width
			@racer1[:PositionOnTrack] = amountOverTrackLength
		end		
		
		###################################
		#============= Racer2 =============
		###################################
		@racer2[:PreviousPositionOnTrack] = @racer2[:PositionOnTrack]
		@racer2[:PositionOnTrack] += @racer2[:CurrentSpeed].floor
		#reset position to near the beginning of the track when we get to the end of it
		if @racer2[:PositionOnTrack] > @sprites["track1"].width
			amountOverTrackLength = @racer2[:PositionOnTrack] - @sprites["track1"].width
			@racer2[:PositionOnTrack] = amountOverTrackLength
		end		
		
		###################################
		#============= Racer3 =============
		###################################
		@racer3[:PreviousPositionOnTrack] = @racer3[:PositionOnTrack]
		@racer3[:PositionOnTrack] += @racer3[:CurrentSpeed].floor
		#reset position to near the beginning of the track when we get to the end of it
		if @racer3[:PositionOnTrack] > @sprites["track1"].width
			amountOverTrackLength = @racer3[:PositionOnTrack] - @sprites["track1"].width
			@racer3[:PositionOnTrack] = amountOverTrackLength
		end
	end #def self.updateRacerPositionOnTrack
	
	def self.updateRacerPositionOnScreen
		#this is the X on the screen, not the track or track overview
		###################################
		#============= Racer1 =============
		###################################
		#calculate normally based on track1's X
		@racer1[:RacerSprite].x = @sprites["track1"].x + @racerStartingX + @racer1[:PositionOnTrack]
		
		#keep the racer on screen if they reach track2 before we do
		#if track2 is on the screen, and the racer's position on the track is <= the width of track2, set the racer's position on the track relative to track2's x
		if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && @racer1[:PositionOnTrack] <= @sprites["track2"].width
			#make the racer's X relative to track2's x
			@racer1[:RacerSprite].x = @sprites["track2"].x + @racerStartingX + @racer1[:PositionOnTrack]
		end #if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && @racer1[:PositionOnTrack] <= @sprites["track2"].width
		
		#keep the racer on screen if we reach track2 before they do
		if @racer1[:RacerSprite].x > @sprites["track1"].width - @racer1[:RacerSprite].width
			@racer1[:RacerSprite].x -= @sprites["track1"].width
		end
		
		#if the racer's sprite is not on the screen, where is it?
		#print @racer1[:RacerSprite].x if !@racer1[:RacerSprite].x.between?(0-@racer1[:RacerSprite].width,Graphics.width-1)
		
		###################################
		#============= Racer2 =============
		###################################
		#calculate normally based on track1's X
		@racer2[:RacerSprite].x = @sprites["track1"].x + @racerStartingX + @racer2[:PositionOnTrack]
		
		#keep the racer on screen if they reach track2 before we do
		#if track2 is on the screen, and the racer's position on the track is <= the width of track2, set the racer's position on the track relative to track2's x
		if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && @racer2[:PositionOnTrack] <= @sprites["track2"].width
			#make the racer's X relative to track2's x
			@racer2[:RacerSprite].x = @sprites["track2"].x + @racerStartingX + @racer2[:PositionOnTrack]
		end #if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && @racer2[:PositionOnTrack] <= @sprites["track2"].width
		
		#keep the racer on screen if we reach track2 before they do
		if @racer2[:RacerSprite].x > @sprites["track1"].width - @racer2[:RacerSprite].width
			@racer2[:RacerSprite].x -= @sprites["track1"].width
		end
		
		###################################
		#============= Racer3 =============
		###################################
		#calculate normally based on track1's X
		@racer3[:RacerSprite].x = @sprites["track1"].x + @racerStartingX + @racer3[:PositionOnTrack]
		
		#keep the racer on screen if they reach track2 before we do
		#if track2 is on the screen, and the racer's position on the track is <= the width of track2, set the racer's position on the track relative to track2's x
		if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && @racer3[:PositionOnTrack] <= @sprites["track2"].width
			#make the racer's X relative to track2's x
			@racer3[:RacerSprite].x = @sprites["track2"].x + @racerStartingX + @racer3[:PositionOnTrack]
		end #if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && @racer3[:PositionOnTrack] <= @sprites["track2"].width
		
		#keep the racer on screen if we reach track2 before they do
		if @racer3[:RacerSprite].x > @sprites["track1"].width - @racer3[:RacerSprite].width
			@racer3[:RacerSprite].x -= @sprites["track1"].width
		end
	end #def self.updateRacerPositionOnTrack
		
	def self.updateHazardPositionOnScreen
		###################################
		#===== Racer Player's Hazards =====
		###################################
		racer = @racerPlayer
		
		#this is the X on the screen, not the track or track overview		
		if racer[:RockHazard][:Sprite] && !racer[:RockHazard][:Sprite].disposed?
			#calculate normally based on track1's X
			racer[:RockHazard][:Sprite].x = @sprites["track1"].x + racer[:RockHazard][:PositionXOnTrack] + racer[:RockHazard][:OriginalPositionXOnScreen] + racer[:RockHazard][:Sprite].width
			#keep the hazard on screen
			#if track2 is on the screen, and the hazard's position on the track is <= the width of track2, set the hazard's position on the track relative to track2's x
			if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && racer[:RockHazard][:PositionXOnTrack] <= @sprites["track2"].width
				#make the hazard's X relative to track2's x
				racer[:RockHazard][:Sprite].x = @sprites["track2"].x + racer[:RockHazard][:PositionXOnTrack] + racer[:RockHazard][:OriginalPositionXOnScreen] + racer[:RockHazard][:Sprite].width
			end #if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1)
		
			#keep the hazard on screen if we reach track2
			if racer[:RockHazard][:Sprite].x > @sprites["track1"].width - racer[:RockHazard][:Sprite].width
				racer[:RockHazard][:Sprite].x -= @sprites["track1"].width
			end
		end #if @racerPlayer[:RockHazard][:Sprite] && !@racerPlayer[:RockHazard][:Sprite].disposed?
		
	end #def self.updateHazardPositionOnScreen
	
	def self.accelerateDecelerate
		###################################
		#============= Racer1 =============
		###################################
		@racer1[:DesiredSpeed] = CrustangRacingSettings::TOP_BASE_SPEED if @racer1[:BoostingStatus] != true && @racer1[:Bumped] != true && @racer1[:SpinOutTimer] <= 0
		
		if @racer1[:BoostingStatus] == true #boosting
			if @racer1[:CurrentSpeed].floor < @racer1[:DesiredSpeed]
				#accelerate
				@racer1[:CurrentSpeed] += CrustangRacingSettings::TOP_BASE_SPEED.to_f / (CrustangRacingSettings::SECONDS_TO_REACH_BOOST_SPEED.to_f * Graphics.frame_rate.to_f)
			end
		else #not boosting
			#accelerate
			if @racer1[:CurrentSpeed].floor < @racer1[:DesiredSpeed]
				@racer1[:CurrentSpeed] += CrustangRacingSettings::TOP_BASE_SPEED.to_f / (CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED.to_f * Graphics.frame_rate.to_f)
			end
		end
		
		#decelerate
		if @racer1[:CurrentSpeed].floor > @racer1[:DesiredSpeed]
			@racer1[:CurrentSpeed] -= @racer1[:PreviousDesiredSpeed] / (CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED.to_f * Graphics.frame_rate.to_f)
		end
		
		#after speeding up or slowing down, if the floor of the current speed is exactly the desired speed, set the current speed to its floor
		if @racer1[:CurrentSpeed].floor == @racer1[:DesiredSpeed]
			@racer1[:CurrentSpeed] = @racer1[:CurrentSpeed].floor
		end
		
		###################################
		#============= Racer2 =============
		###################################
		@racer2[:DesiredSpeed] = CrustangRacingSettings::TOP_BASE_SPEED if @racer2[:BoostingStatus] != true && @racer2[:Bumped] != true && @racer2[:SpinOutTimer] <= 0
		
		if @racer2[:BoostingStatus] == true #boosting
			if @racer2[:CurrentSpeed].floor < @racer2[:DesiredSpeed]
				#accelerate
				@racer2[:CurrentSpeed] += CrustangRacingSettings::TOP_BASE_SPEED.to_f / (CrustangRacingSettings::SECONDS_TO_REACH_BOOST_SPEED.to_f * Graphics.frame_rate.to_f)
			end
		else #not boosting
			#accelerate
			if @racer2[:CurrentSpeed].floor < @racer2[:DesiredSpeed]
				@racer2[:CurrentSpeed] += CrustangRacingSettings::TOP_BASE_SPEED.to_f / (CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED.to_f * Graphics.frame_rate.to_f)
			end
		end
		
		#decelerate
		if @racer2[:CurrentSpeed].floor > @racer2[:DesiredSpeed]
			@racer2[:CurrentSpeed] -= @racer2[:PreviousDesiredSpeed] / (CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED.to_f * Graphics.frame_rate.to_f)
		end
		
		#after speeding up or slowing down, if the floor of the current speed is exactly the desired speed, set the current speed to its floor
		if @racer2[:CurrentSpeed].floor == @racer2[:DesiredSpeed]
			@racer2[:CurrentSpeed] = @racer2[:CurrentSpeed].floor
		end
		
		###################################
		#============= Racer3 =============
		###################################
		@racer3[:DesiredSpeed] = CrustangRacingSettings::TOP_BASE_SPEED if @racer3[:BoostingStatus] != true && @racer3[:Bumped] != true && @racer3[:SpinOutTimer] <= 0
		
		if @racer3[:BoostingStatus] == true #boosting
			if @racer3[:CurrentSpeed].floor < @racer3[:DesiredSpeed]
				#accelerate
				@racer3[:CurrentSpeed] += CrustangRacingSettings::TOP_BASE_SPEED.to_f / (CrustangRacingSettings::SECONDS_TO_REACH_BOOST_SPEED.to_f * Graphics.frame_rate.to_f)
			end
		else #not boosting
			#accelerate
			if @racer3[:CurrentSpeed].floor < @racer3[:DesiredSpeed]
				@racer3[:CurrentSpeed] += CrustangRacingSettings::TOP_BASE_SPEED.to_f / (CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED.to_f * Graphics.frame_rate.to_f)
			end
		end
		
		#decelerate
		if @racer3[:CurrentSpeed].floor > @racer3[:DesiredSpeed]
			@racer3[:CurrentSpeed] -= @racer3[:PreviousDesiredSpeed] / (CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED.to_f * Graphics.frame_rate.to_f)
		end
		
		#after speeding up or slowing down, if the floor of the current speed is exactly the desired speed, set the current speed to its floor
		if @racer3[:CurrentSpeed].floor == @racer3[:DesiredSpeed]
			@racer3[:CurrentSpeed] = @racer3[:CurrentSpeed].floor
		end
		
		###################################
		#============= Player =============
		###################################
		@racerPlayer[:DesiredSpeed] = CrustangRacingSettings::TOP_BASE_SPEED if @racerPlayer[:BoostingStatus] != true && @racerPlayer[:Bumped] != true && @racerPlayer[:SpinOutTimer] <= 0
		
		if @racerPlayer[:BoostingStatus] == true #boosting
			if @racerPlayer[:CurrentSpeed].floor < @racerPlayer[:DesiredSpeed]
				#accelerate
				@racerPlayer[:CurrentSpeed] += CrustangRacingSettings::TOP_BASE_SPEED.to_f / (CrustangRacingSettings::SECONDS_TO_REACH_BOOST_SPEED.to_f * Graphics.frame_rate.to_f)
			end
		else #not boosting and not recovering from bump
			#accelerate
			if @racerPlayer[:CurrentSpeed].floor < @racerPlayer[:DesiredSpeed]
				@racerPlayer[:CurrentSpeed] += CrustangRacingSettings::TOP_BASE_SPEED.to_f / (CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED.to_f * Graphics.frame_rate.to_f)
			end
		end
		
		#decelerate
		if @racerPlayer[:CurrentSpeed].floor > @racerPlayer[:DesiredSpeed]
			@racerPlayer[:CurrentSpeed] -= @racerPlayer[:PreviousDesiredSpeed] / (CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED.to_f * Graphics.frame_rate.to_f)
		end
		
		#after speeding up or slowing down, if the floor of the current speed is exactly the desired speed, set the current speed to its floor
		if @racerPlayer[:CurrentSpeed].floor == @racerPlayer[:DesiredSpeed]
			@racerPlayer[:CurrentSpeed] = @racerPlayer[:CurrentSpeed].floor
		end
		
	end #def self.accelerateDecelerate
	
	def self.checkForCollisions
		#make crashing into someone in front of you change your current speed and desired speed to the racer you crashed into
		###################################
		#============= Racer1 =============
		###################################
		#collide with racers
		self.bumpedIntoSomeone(@racer1, @racerPlayer) if self.collides_with_object_in_front?(@racer1[:RacerSprite],@racerPlayer[:RacerSprite])
		self.bumpedIntoSomeone(@racer1, @racer2) if self.collides_with_object_in_front?(@racer1[:RacerSprite],@racer2[:RacerSprite])
		self.bumpedIntoSomeone(@racer1, @racer3) if self.collides_with_object_in_front?(@racer1[:RacerSprite],@racer3[:RacerSprite])
		
		#collide with rock hazard
		#this method of checking for collisions does not account for weird sprite placement
		#spin out racer 1 (recipient) with racerPlayer as the attacher if racer1 hits racerPlayer's hazard
		if @racer1[:RockHazard][:Sprite] && !@racer1[:RockHazard][:Sprite].disposed? && self.collides_with?(@racer1[:RacerSprite],@racer1[:RockHazard][:Sprite])
			self.disposeHazard(@racer1, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer1[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racer1, @racer1)
			self.announceAttack(@racer1, @racer1, "rock")
		end
		if @racer2[:RockHazard][:Sprite] && !@racer2[:RockHazard][:Sprite].disposed? && self.collides_with?(@racer1[:RacerSprite],@racer2[:RockHazard][:Sprite])
			self.disposeHazard(@racer2, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer1[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racer2, @racer1)
			self.announceAttack(@racer2, @racer1, "rock")
		end
		if @racer3[:RockHazard][:Sprite] && !@racer3[:RockHazard][:Sprite].disposed? && self.collides_with?(@racer1[:RacerSprite],@racer3[:RockHazard][:Sprite])
			self.disposeHazard(@racer3, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer1[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racer3, @racer1)
			self.announceAttack(@racer3, @racer1, "rock")
		end
		if @racerPlayer[:RockHazard][:Sprite] && !@racerPlayer[:RockHazard][:Sprite].disposed? && self.collides_with?(@racer1[:RacerSprite],@racerPlayer[:RockHazard][:Sprite])
			self.disposeHazard(@racerPlayer, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer1[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racerPlayer, @racer1)
			self.announceAttack(@racerPlayer, @racer1, "rock")
		end
		
		#collide with mud hazard
		if @racer1[:MudHazard][:Sprite] && !@racer1[:MudHazard][:Sprite].disposed? && self.collides_with?(@racer1[:RacerSprite],@racer1[:MudHazard][:Sprite])
			self.disposeHazard(@racer1, "mud")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer1[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racer1, @racer1)
			self.announceAttack(@racer1, @racer1, "mud")
		end
		if @racer2[:MudHazard][:Sprite] && !@racer2[:MudHazard][:Sprite].disposed? && self.collides_with?(@racer1[:RacerSprite],@racer2[:MudHazard][:Sprite])
			self.disposeHazard(@racer2, "mud")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer1[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racer2, @racer1)
			self.announceAttack(@racer2, @racer1, "mud")
		end
		if @racer3[:MudHazard][:Sprite] && !@racer3[:MudHazard][:Sprite].disposed? && self.collides_with?(@racer1[:RacerSprite],@racer3[:MudHazard][:Sprite])
			self.disposeHazard(@racer3, "mud")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer1[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racer3, @racer1)
			self.announceAttack(@racer3, @racer1, "mud")
		end
		if @racerPlayer[:MudHazard][:Sprite] && !@racerPlayer[:MudHazard][:Sprite].disposed? && self.collides_with?(@racer1[:RacerSprite],@racerPlayer[:MudHazard][:Sprite])
			self.disposeHazard(@racerPlayer, "mud")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer1[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racerPlayer, @racer1)
			self.announceAttack(@racerPlayer, @racer1, "mud")
		end
		
		###################################
		#============= Racer2 =============
		###################################
		#collide with racers
		self.bumpedIntoSomeone(@racer2, @racer1) if self.collides_with_object_in_front?(@racer2[:RacerSprite],@racer1[:RacerSprite])
		self.bumpedIntoSomeone(@racer2, @racerPlayer) if self.collides_with_object_in_front?(@racer2[:RacerSprite],@racerPlayer[:RacerSprite])
		self.bumpedIntoSomeone(@racer2, @racer3) if self.collides_with_object_in_front?(@racer2[:RacerSprite],@racer3[:RacerSprite])
		
		#collide with rock hazard
		if @racer1[:RockHazard][:Sprite] && !@racer1[:RockHazard][:Sprite].disposed? && self.collides_with?(@racer2[:RacerSprite],@racer1[:RockHazard][:Sprite])
			self.disposeHazard(@racer1, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer2[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racer1, @racer2)
			self.announceAttack(@racer1, @racer2, "rock")
		end
		if @racer2[:RockHazard][:Sprite] && !@racer2[:RockHazard][:Sprite].disposed? && self.collides_with?(@racer2[:RacerSprite],@racer2[:RockHazard][:Sprite])
			self.disposeHazard(@racer2, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer2[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racer2, @racer2)
			self.announceAttack(@racer2, @racer2, "rock")
		end
		if @racer3[:RockHazard][:Sprite] && !@racer3[:RockHazard][:Sprite].disposed? && self.collides_with?(@racer2[:RacerSprite],@racer3[:RockHazard][:Sprite])
			self.disposeHazard(@racer3, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer2[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racer3, @racer2)
			self.announceAttack(@racer3, @racer2, "rock")
		end
		if @racerPlayer[:RockHazard][:Sprite] && !@racerPlayer[:RockHazard][:Sprite].disposed? && self.collides_with?(@racer2[:RacerSprite],@racerPlayer[:RockHazard][:Sprite])
			self.disposeHazard(@racerPlayer, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer2[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racerPlayer, @racer2)
			self.announceAttack(@racerPlayer, @racer2, "rock")
		end
		
		#collide with mud hazard
		if @racer1[:MudHazard][:Sprite] && !@racer1[:MudHazard][:Sprite].disposed? && self.collides_with?(@racer2[:RacerSprite],@racer1[:MudHazard][:Sprite])
			self.disposeHazard(@racer1, "mud")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer2[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racer1, @racer2)
			self.announceAttack(@racer1, @racer2, "mud")
		end
		if @racer2[:MudHazard][:Sprite] && !@racer2[:MudHazard][:Sprite].disposed? && self.collides_with?(@racer2[:RacerSprite],@racer2[:MudHazard][:Sprite])
			self.disposeHazard(@racer2, "mud")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer2[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racer2, @racer2)
			self.announceAttack(@racer2, @racer2, "mud")
		end
		if @racer3[:MudHazard][:Sprite] && !@racer3[:MudHazard][:Sprite].disposed? && self.collides_with?(@racer2[:RacerSprite],@racer3[:MudHazard][:Sprite])
			self.disposeHazard(@racer3, "mud")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer2[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racer3, @racer2)
			self.announceAttack(@racer3, @racer2, "mud")
		end
		if @racerPlayer[:MudHazard][:Sprite] && !@racerPlayer[:MudHazard][:Sprite].disposed? && self.collides_with?(@racer2[:RacerSprite],@racerPlayer[:MudHazard][:Sprite])
			self.disposeHazard(@racerPlayer, "mud")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer2[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racerPlayer, @racer2)
			self.announceAttack(@racerPlayer, @racer2, "mud")
		end
		
		###################################
		#============= Racer3 =============
		###################################
		#collide with racers
		self.bumpedIntoSomeone(@racer3, @racer1) if self.collides_with_object_in_front?(@racer3[:RacerSprite],@racer1[:RacerSprite])
		self.bumpedIntoSomeone(@racer3, @racer2) if self.collides_with_object_in_front?(@racer3[:RacerSprite],@racer2[:RacerSprite])
		self.bumpedIntoSomeone(@racer3, @racerPlayer) if self.collides_with_object_in_front?(@racer3[:RacerSprite],@racerPlayer[:RacerSprite])
		
		#collide with rock hazard
		if @racer1[:RockHazard][:Sprite] && !@racer1[:RockHazard][:Sprite].disposed? && self.collides_with?(@racer3[:RacerSprite],@racer1[:RockHazard][:Sprite])
			self.disposeHazard(@racer1, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer3[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racer1, @racer3)
			self.announceAttack(@racer1, @racer3, "rock")
		end
		if @racer2[:RockHazard][:Sprite] && !@racer2[:RockHazard][:Sprite].disposed? && self.collides_with?(@racer3[:RacerSprite],@racer2[:RockHazard][:Sprite])
			self.disposeHazard(@racer2, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer3[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racer2, @racer3)
			self.announceAttack(@racer2, @racer3, "rock")
		end
		if @racer3[:RockHazard][:Sprite] && !@racer3[:RockHazard][:Sprite].disposed? && self.collides_with?(@racer3[:RacerSprite],@racer3[:RockHazard][:Sprite])
			self.disposeHazard(@racer3, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer3[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racer3, @racer3)
			self.announceAttack(@racer3, @racer3, "rock")
		end
		if @racerPlayer[:RockHazard][:Sprite] && !@racerPlayer[:RockHazard][:Sprite].disposed? && self.collides_with?(@racer3[:RacerSprite],@racerPlayer[:RockHazard][:Sprite])
			self.disposeHazard(@racerPlayer, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer3[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racerPlayer, @racer3)
			self.announceAttack(@racerPlayer, @racer3, "rock")
		end
		
		#collide with mud hazard
		if @racer1[:MudHazard][:Sprite] && !@racer1[:MudHazard][:Sprite].disposed? && self.collides_with?(@racer3[:RacerSprite],@racer1[:MudHazard][:Sprite])
			self.disposeHazard(@racer1, "mud")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer3[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racer1, @racer3)
			self.announceAttack(@racer1, @racer3, "mud")
		end
		if @racer2[:MudHazard][:Sprite] && !@racer2[:MudHazard][:Sprite].disposed? && self.collides_with?(@racer3[:RacerSprite],@racer2[:MudHazard][:Sprite])
			self.disposeHazard(@racer2, "mud")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer3[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racer2, @racer3)
			self.announceAttack(@racer2, @racer3, "mud")
		end
		if @racer3[:MudHazard][:Sprite] && !@racer3[:MudHazard][:Sprite].disposed? && self.collides_with?(@racer3[:RacerSprite],@racer3[:MudHazard][:Sprite])
			self.disposeHazard(@racer3, "mud")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer3[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racer3, @racer3)
			self.announceAttack(@racer3, @racer3, "mud")
		end
		if @racerPlayer[:MudHazard][:Sprite] && !@racerPlayer[:MudHazard][:Sprite].disposed? && self.collides_with?(@racer3[:RacerSprite],@racerPlayer[:MudHazard][:Sprite])
			self.disposeHazard(@racerPlayer, "mud")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer3[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racerPlayer, @racer3)
			self.announceAttack(@racerPlayer, @racer3, "mud")
		end
		
		###################################
		#============= Player =============
		###################################
		#collide with racers
		self.bumpedIntoSomeone(@racerPlayer, @racer1) if self.collides_with_object_in_front?(@racerPlayer[:RacerSprite],@racer1[:RacerSprite])
		self.bumpedIntoSomeone(@racerPlayer, @racer2) if self.collides_with_object_in_front?(@racerPlayer[:RacerSprite],@racer2[:RacerSprite])
		self.bumpedIntoSomeone(@racerPlayer, @racer3) if self.collides_with_object_in_front?(@racerPlayer[:RacerSprite],@racer3[:RacerSprite])
		
		#collide with rock hazard
		if @racer1[:RockHazard][:Sprite] && !@racer1[:RockHazard][:Sprite].disposed? && self.collides_with?(@racerPlayer[:RacerSprite],@racer1[:RockHazard][:Sprite])
			self.disposeHazard(@racer1, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racerPlayer[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racer1, @racerPlayer)
			self.announceAttack(@racer1, @racerPlayer, "rock")
		end
		if @racer2[:RockHazard][:Sprite] && !@racer2[:RockHazard][:Sprite].disposed? && self.collides_with?(@racerPlayer[:RacerSprite],@racer2[:RockHazard][:Sprite])
			self.disposeHazard(@racer2, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racerPlayer[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racer2, @racerPlayer)
			self.announceAttack(@racer2, @racerPlayer, "rock")
		end
		if @racer3[:RockHazard][:Sprite] && !@racer3[:RockHazard][:Sprite].disposed? && self.collides_with?(@racerPlayer[:RacerSprite],@racer3[:RockHazard][:Sprite])
			self.disposeHazard(@racer3, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racerPlayer[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racer3, @racerPlayer)
			self.announceAttack(@racer3, @racerPlayer, "rock")
		end
		if @racerPlayer[:RockHazard][:Sprite] && !@racerPlayer[:RockHazard][:Sprite].disposed? && self.collides_with?(@racerPlayer[:RacerSprite],@racerPlayer[:RockHazard][:Sprite])
			self.disposeHazard(@racerPlayer, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racerPlayer[:RacerSprite].x.between?(0,Graphics.width)
			self.spinOut(@racerPlayer, @racerPlayer)
			self.announceAttack(@racerPlayer, @racerPlayer, "rock")
		end
		
		#collide with mud hazard
		if @racer1[:MudHazard][:Sprite] && !@racer1[:MudHazard][:Sprite].disposed? && self.collides_with?(@racerPlayer[:RacerSprite],@racer1[:MudHazard][:Sprite])
			self.disposeHazard(@racer1, "mud")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE)
			self.spinOut(@racer1, @racerPlayer)
			self.announceAttack(@racer1, @racerPlayer, "rock")
		end
		if @racer2[:MudHazard][:Sprite] && !@racer2[:MudHazard][:Sprite].disposed? && self.collides_with?(@racerPlayer[:RacerSprite],@racer2[:MudHazard][:Sprite])
			self.disposeHazard(@racer2, "mud")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE)
			self.spinOut(@racer2, @racerPlayer)
			self.announceAttack(@racer2, @racerPlayer, "rock")
		end
		if @racer3[:MudHazard][:Sprite] && !@racer3[:MudHazard][:Sprite].disposed? && self.collides_with?(@racerPlayer[:RacerSprite],@racer3[:MudHazard][:Sprite])
			self.disposeHazard(@racer3, "mud")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE)
			self.spinOut(@racer3, @racerPlayer)
			self.announceAttack(@racer3, @racerPlayer, "rock")
		end
		if @racerPlayer[:MudHazard][:Sprite] && !@racerPlayer[:MudHazard][:Sprite].disposed? && self.collides_with?(@racerPlayer[:RacerSprite],@racerPlayer[:MudHazard][:Sprite])
			self.disposeHazard(@racerPlayer, "mud")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE)
			self.spinOut(@racerPlayer, @racerPlayer)
			self.announceAttack(@racerPlayer, @racerPlayer, "rock")
		end

	end #def self.checkForCollisions
	
	def self.bumpedIntoSomeone(racerBehind, racerInFront)
		#play SE for collision
		pbSEPlay(CrustangRacingSettings::COLLISION_SE)
		
		racerBehind[:Bumped] = true
		racerBehind[:BumpedRecoveryTimer] = Graphics.frame_rate * CrustangRacingSettings::SECONDS_TO_RECOVER_FROM_BUMP
		racerInFront[:Bumped] = true
		racerInFront[:BumpedRecoveryTimer] = Graphics.frame_rate * CrustangRacingSettings::SECONDS_TO_RECOVER_FROM_BUMP
		
		#the racer in behind should immediately go the same speed as the racer they bumped into in front of them
		racerBehind[:PreviousDesiredSpeed] = racerBehind[:DesiredSpeed]
		racerBehind[:DesiredSpeed] = racerInFront[:CurrentSpeed] if racerBehind[:DesiredSpeed] >= racerInFront[:CurrentSpeed]
		racerBehind[:CurrentSpeed] = racerInFront[:CurrentSpeed] if racerBehind[:CurrentSpeed] >= racerInFront[:CurrentSpeed]
		#the racer in front should immediately stop slowing down if they were spinning out, but they should not stop gaining speed if they were in the middle of gaining speed
		racerInFront[:CurrentSpeed] += 3
	
	end #def self.bumpedIntoSomeone
	
	def self.main
		self.setup
		self.setupRacerHashes
		self.drawContestants
		self.drawContestantsOnOverview
		self.assignMoveEffects
		self.drawMovesUI
		self.setMiscVariables
		
		loop do
			Graphics.update
			pbUpdateSpriteHash(@sprites)
			self.trackMovementUpdate #keep this as high up in the loop as possible below Graphics updates
			self.moveMiscSprites
			self.updateRacerPositionOnTrack
			self.updateRacerPositionOnScreen
			self.updateHazardPositionOnScreen
			self.trackOverviewMovementUpdate
			self.detectInput
			self.updateCooldownMultipliers
			self.updateTimers
			self.accelerateDecelerate
			self.checkForCollisions
			self.updateSpinOutAnimation
			self.updateOverlayText
			self.checkForLap
			self.updateSpinOutRangeSprites
		end
	end #def self.main
	
end #class CrustangRacing