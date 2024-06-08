#Track Setup
class CrustangRacing
	
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
			#@lastCurrentSpeed = @racerPlayer[:CurrentSpeed].truncate(1).to_f      #draw with a decimal place
			@lastCurrentSpeed = @racerPlayer[:CurrentSpeed].floor     #draw with no decimal place
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
			@sprites["boostButton"].frame = 0 if racer == @racerPlayer
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
		#============= Racer1 =============
		###################################
		#do not update cooldown sprites for non-player racers because they don't have any
		#boost timer
		@racer1[:BoostCooldownTimer] -= 1 if @racer1[:BoostCooldownTimer] > 0
		
		#move1 timer
		#move2 timer
		#move3 timer
		#move4 timer
		
		###################################
		#============= Player =============
		###################################
		#player moves' cooldown timers
		#boost timer
		if @racerPlayer[:BoostCooldownTimer] > 0
			@racerPlayer[:BoostCooldownTimer] -= 1
			#cooldown mask over move
			@racerPlayer[:BoostButtonCooldownMaskSprite].src_rect = Rect.new(0, 0, @racerPlayer[:BoostButtonCooldownMaskSprite].width, @boostCooldownPixelsToMovePerFrame*@racerPlayer[:BoostCooldownTimer].ceil)
		end #if @racerPlayer[:BoostCooldownTimer] > 0
		
		#move1 timer
		#move2 timer
		#move3 timer
		#move4 timer
		
	end
	
	def self.moveSpritesWithTrack
		#move sprites like the lap line, any obstacles, etc. along with the track as it passes by
		#lap line
		#@sprites["lapLine"].x -= @racerPlayer[:CurrentSpeed]
		#@sprites["lapLineCopy"].x -= @racerPlayer[:CurrentSpeed]
		
	end #def self.moveSpritesWithTrack
	
	def self.trackMovementUpdate
		@sprites["track1"].x -= @racerPlayer[:CurrentSpeed]
		@sprites["track2"].x -= @racerPlayer[:CurrentSpeed]
		
		#track image looping logic
		#if track2 is now on screen
		if @sprites["track2"].x.between?(0,Graphics.width-1)
			@trackSpriteInUse = @sprites["track2"] if @trackSpriteInUse != @sprites["track2"]
		end
		
		#if track2 is now on the screen, track2's X is now 0 or less, and track1's X is still < 0, move track1 to the end of track2 for a loop
		if @sprites["track2"].x <= 0 && @sprites["track1"].x < 0
			@sprites["track1"].x = @sprites["track2"].x + @sprites["track2"].width - 1024
		end
		#if track2's X is < 0, move track2 to the end of track1 for a loop
		if @sprites["track2"].x < 0
			@sprites["track2"].x = @sprites["track1"].x + @sprites["track1"].width
			@trackSpriteInUse = @sprites["track1"] if @trackSpriteInUse != @sprites["track1"]
			#any racers off screen teleport to their same positions on the track when it teleports
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
		
		#any racers off screen teleport to their same positions on the track when it teleports
		
	end #def trackMovementUpdate
	
	def self.checkForLap
		#Lapping: true, LapCount: 0, CurrentPlacement: 1,
		###################################
		#============= Racer1 =============
		###################################
		if self.collides_with?(@racer1[:RacerSprite],@sprites["lapLine"]) && @racer1[:Lapping] != true
			@racer1[:LapCount] += 1
			@racer1[:Lapping] = true
		end
		@racer1[:Lapping] = false if !self.collides_with?(@racer1[:RacerSprite],@sprites["lapLine"])
		
		###################################
		#============= Player =============
		###################################
		#if the racer is touching the lap line and not currently 'lapping', add a lap to the racer's count
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
		@racerPlayer[:PositionOnTrack] = @sprites["track1"].x.abs

		#calculate the position of the other racers differently than the player. It would involve their X and the X of the track
		###################################
		#============= Racer1 =============
		###################################
		
		#make it based on the amount INTO the track, not the racer's X on the screen or track1's X
		
		#@racer1[:PositionOnTrack] -= @racerPlayer[:CurrentSpeed] #because the track moves based on the player's current speed
		#then make the racer go FORWARD however fast their current speed is
		#@racer1[:PositionOnTrack] += @racer1[:CurrentSpeed]
		
		#racer2 position
		#racer3 position
		
	end #def self.updateRacerPositionOnTrack
	
	def self.updateRacerPositionOnScreen
		#this is the X on the screen, not the track or track overview
		###################################
		#============= Racer1 =============
		###################################
		@racer1[:RacerSprite].x = @trackSpriteInUse.x + @racerStartingX + @racer1[:PositionOnTrack] #sprite X should be their starting position relative to track1's x + their distance into the track (position on track)
		#then make the racer go FORWARD however fast their current speed is
		#@racer1[:RacerSprite].x += @racer1[:CurrentSpeed]
		
	end #def self.updateRacerPositionOnTrack
	
	def self.accelerateDecelerate
		###################################
		#============= Racer1 =============
		###################################
		if @racer1[:CurrentSpeed].floor < @racer1[:DesiredSpeed]
			#accelerate
			@racer1[:CurrentSpeed] += @accelerationAmountPerFrame
		end
		
		#decelerate
		if @racer1[:CurrentSpeed].floor > @racer1[:DesiredSpeed] && @racer1[:BoostTimer] <= 0
			#decelerate
			@racer1[:CurrentSpeed] -= @decelerationAmountPerFrame
		end
		
		#after speeding up or slowing down, if the floor of the current speed is exactly the desired speed, set the current speed to its floor
		if @racer1[:CurrentSpeed].floor == @racer1[:DesiredSpeed]
			@racer1[:CurrentSpeed] = @racer1[:CurrentSpeed].floor
		end
		
		#update boost timers for racers
		@racer1[:BoostTimer] -= 1
		
		###################################
		#============= Player =============
		###################################
		if @racerPlayer[:CurrentSpeed].floor < @racerPlayer[:DesiredSpeed]
			#accelerate
			@racerPlayer[:CurrentSpeed] += @accelerationAmountPerFrame
		end
		
		#decelerate
		if @racerPlayer[:CurrentSpeed].floor > @racerPlayer[:DesiredSpeed] && @racerPlayer[:BoostTimer] <= 0
			#decelerate
			@racerPlayer[:CurrentSpeed] -= @decelerationAmountPerFrame
		end
		
		#after speeding up or slowing down, if the floor of the current speed is exactly the desired speed, set the current speed to its floor
		if @racerPlayer[:CurrentSpeed].floor == @racerPlayer[:DesiredSpeed]
			@racerPlayer[:CurrentSpeed] = @racerPlayer[:CurrentSpeed].floor
		end
		
		#update boost timers for racers
		@racerPlayer[:BoostTimer] -= 1
	end #def self.accelerateDecelerate
	
	def self.main
		self.setup
		self.setupRacerHashes
		self.drawContestants
		self.drawContestantsOnOverview
		self.drawMovesUI
		self.setMiscVariables
		
		#set beginning desired speed
		@racerPlayer[:DesiredSpeed] = CrustangRacingSettings::TOP_BASE_SPEED.floor
		
		loop do
			Graphics.update
			pbUpdateSpriteHash(@sprites)
			self.trackMovementUpdate
			self.updateRacerPositionOnScreen
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