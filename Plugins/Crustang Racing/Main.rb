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
				#if colliding with something above you and not in front or behind, restrict movement
				return if self.collides_with_object_above?(@racerPlayer[:RacerSprite],@racer1[:RacerSprite]) || self.collides_with_object_above?(@racerPlayer[:RacerSprite],@racer2[:RacerSprite]) || self.collides_with_object_above?(@racerPlayer[:RacerSprite],@racer3[:RacerSprite])
			end
			@racerPlayer[:RacerSprite].y -= CrustangRacingSettings::BASE_STRAFE_SPEED if @racerPlayer[:RacerSprite].y > @trackBorderTopY
			
		elsif Input.press?(Input::DOWN)
			#if colliding with any racer in front or behind
			if self.collides_with_object_behind?(@racerPlayer[:RacerSprite],@racer1[:RacerSprite]) || self.collides_with_object_in_front?(@racerPlayer[:RacerSprite],@racer1[:RacerSprite]) || self.collides_with_object_behind?(@racerPlayer[:RacerSprite],@racer2[:RacerSprite]) || self.collides_with_object_in_front?(@racerPlayer[:RacerSprite],@racer2[:RacerSprite]) || self.collides_with_object_behind?(@racerPlayer[:RacerSprite],@racer3[:RacerSprite]) || self.collides_with_object_in_front?(@racerPlayer[:RacerSprite],@racer3[:RacerSprite])
				#don't restrict up and DOWN
			else
				#if colliding with something below you and not in front or behind, restrict movement
				return if self.collides_with_object_below?(@racerPlayer[:RacerSprite],@racer1[:RacerSprite]) || self.collides_with_object_below?(@racerPlayer[:RacerSprite],@racer2[:RacerSprite]) || self.collides_with_object_below?(@racerPlayer[:RacerSprite],@racer3[:RacerSprite])
			end
			@racerPlayer[:RacerSprite].y += CrustangRacingSettings::BASE_STRAFE_SPEED if @racerPlayer[:RacerSprite].y < @trackBorderBottomY
		end
		
		###################################
		#============= Boost =============
		###################################
		if Input.trigger?(CrustangRacingSettings::BOOST_BUTTON) && @racerPlayer[:BoostCooldownTimer] <= 0
			@racerPlayer[:BoostButtonSprite].frame = 1
			self.moveEffect(@racerPlayer, 0)
		end
		if Input.release?(CrustangRacingSettings::BOOST_BUTTON)
			@racerPlayer[:BoostButtonSprite].frame = 0
		end
		
		###################################
		#============= Moves =============
		###################################
		#move1
		if Input.triggerex?(CrustangRacingSettings::MOVE1_BUTTON) && @racerPlayer[:Move1CooldownTimer] <= 0
			@racerPlayer[:Move1ButtonSprite].frame = 1
			self.moveEffect(@racerPlayer, 1)
			self.beginCooldown(@racerPlayer, 1)
		end
		if Input.release?(CrustangRacingSettings::MOVE1_BUTTON)
			@racerPlayer[:Move1ButtonSprite].frame = 0
		end
		#move2
		if Input.triggerex?(CrustangRacingSettings::MOVE2_BUTTON) && @racerPlayer[:Move2CooldownTimer] <= 0
			@racerPlayer[:Move2ButtonSprite].frame = 1
			self.moveEffect(@racerPlayer, 2)
			self.beginCooldown(@racerPlayer, 2)
		end
		if Input.release?(CrustangRacingSettings::MOVE2_BUTTON)
			@racerPlayer[:Move2ButtonSprite].frame = 0
		end
		#move3
		if Input.triggerex?(CrustangRacingSettings::MOVE3_BUTTON) && @racerPlayer[:Move3CooldownTimer] <= 0
			@racerPlayer[:Move3ButtonSprite].frame = 1
			self.moveEffect(@racerPlayer, 3)
			self.beginCooldown(@racerPlayer, 3)
		end
		if Input.release?(CrustangRacingSettings::MOVE3_BUTTON)
			@racerPlayer[:Move3ButtonSprite].frame = 0
		end
		#move4
		if Input.triggerex?(CrustangRacingSettings::MOVE4_BUTTON) && @racerPlayer[:Move4CooldownTimer] <= 0
			@racerPlayer[:Move4ButtonSprite].frame = 1
			self.moveEffect(@racerPlayer, 4)
			self.beginCooldown(@racerPlayer, 4)
		end
		if Input.release?(CrustangRacingSettings::MOVE4_BUTTON)
			@racerPlayer[:Move4ButtonSprite].frame = 0
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
		@racer1[:SpinOutRangeSprite].x = @racer1[:RacerSprite].x - @racer1[:SpinOutRangeSprite].width/2 + @racer1[:RacerSprite].width/2
		@racer1[:SpinOutRangeSprite].y = @racer1[:RacerSprite].y - @racer1[:SpinOutRangeSprite].height/2 + @racer1[:RacerSprite].height/2
		@racer2[:SpinOutRangeSprite].x = @racer2[:RacerSprite].x - @racer2[:SpinOutRangeSprite].width/2 + @racer2[:RacerSprite].width/2
		@racer2[:SpinOutRangeSprite].y = @racer2[:RacerSprite].y - @racer2[:SpinOutRangeSprite].height/2 + @racer2[:RacerSprite].height/2
		@racer3[:SpinOutRangeSprite].x = @racer3[:RacerSprite].x - @racer3[:SpinOutRangeSprite].width/2 + @racer3[:RacerSprite].width/2
		@racer3[:SpinOutRangeSprite].y = @racer3[:RacerSprite].y - @racer3[:SpinOutRangeSprite].height/2 + @racer3[:RacerSprite].height/2
		@racerPlayer[:SpinOutRangeSprite].x = @racerPlayer[:RacerSprite].x - @racerPlayer[:SpinOutRangeSprite].width/2 + @racerPlayer[:RacerSprite].width/2
		@racerPlayer[:SpinOutRangeSprite].y = @racerPlayer[:RacerSprite].y - @racerPlayer[:SpinOutRangeSprite].height/2 + @racerPlayer[:RacerSprite].height/2
		
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
	
	def self.accelerateDecelerate
		###################################
		#============= Racer1 =============
		###################################
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
		if @racerPlayer[:BoostingStatus] == true #boosting
			if @racerPlayer[:CurrentSpeed].floor < @racerPlayer[:DesiredSpeed]
				#accelerate
				@racerPlayer[:CurrentSpeed] += CrustangRacingSettings::TOP_BASE_SPEED.to_f / (CrustangRacingSettings::SECONDS_TO_REACH_BOOST_SPEED.to_f * Graphics.frame_rate.to_f)
			end
		else #not boosting
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
		
		
		###################################
		#============= Racer2 =============
		###################################
		
		
		###################################
		#============= Racer3 =============
		###################################
		
		
		###################################
		#============= Player =============
		###################################
		#crash into another racer in front of this racer
		if self.collides_with_object_in_front?(@racerPlayer[:RacerSprite],@racer1[:RacerSprite])
			@racerPlayer[:PreviousDesiredSpeed] = @racerPlayer[:DesiredSpeed]
			@racerPlayer[:DesiredSpeed] = CrustangRacingSettings::TOP_BASE_SPEED
			@racerPlayer[:CurrentSpeed] = @racer1[:CurrentSpeed]
		end
		if self.collides_with_object_in_front?(@racerPlayer[:RacerSprite],@racer2[:RacerSprite])
			@racerPlayer[:PreviousDesiredSpeed] = @racerPlayer[:DesiredSpeed]
			@racerPlayer[:DesiredSpeed] = CrustangRacingSettings::TOP_BASE_SPEED
			@racerPlayer[:CurrentSpeed] = @racer2[:CurrentSpeed]
		end
		if self.collides_with_object_in_front?(@racerPlayer[:RacerSprite],@racer3[:RacerSprite])
			@racerPlayer[:PreviousDesiredSpeed] = @racerPlayer[:DesiredSpeed]
			@racerPlayer[:DesiredSpeed] = CrustangRacingSettings::TOP_BASE_SPEED
			@racerPlayer[:CurrentSpeed] = @racer3[:CurrentSpeed]
		end
		
	end #def self.checkForCollisions
	
	def self.main
		self.setup
		self.setupRacerHashes
		self.drawContestants
		self.drawContestantsOnOverview
		self.assignMoveEffects
		self.drawMovesUI
		self.setMiscVariables
		self.drawSpinOutRangeCircle
		
		loop do
			Graphics.update
			pbUpdateSpriteHash(@sprites)
			self.trackMovementUpdate #keep this as high up in the loop as possible below Graphics updates
			self.moveMiscSprites
			self.updateRacerPositionOnTrack
			self.updateRacerPositionOnScreen
			self.trackOverviewMovementUpdate
			self.detectInput
			self.updateCooldownMultipliers
			self.updateCooldownTimers
			self.accelerateDecelerate
			self.checkForCollisions
			self.updateSpinOutAnimation
			self.updateOverlayText
			self.checkForLap
		end
	end #def self.main
	
end #class CrustangRacing