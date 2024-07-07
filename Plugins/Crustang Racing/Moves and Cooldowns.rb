class CrustangRacing
	
	def self.beginCooldown(racer, moveNumber)
		#move number 0 is boost
		#Move1: nil, Move1Effect: nil, Move1CooldownTimer: nil, Move1ButtonSprite: nil
		#case moveNumber
		#when 0
			#boost
			#un-press button
		#	@racerPlayer[:BoostButtonSprite].frame = 0 if racer == @racerPlayer
		#	#start cooldown timer
		#	racer[:BoostCooldownTimer] = CrustangRacingSettings::BOOST_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate
		#when 1
			#move1
			#un-press button
		#	@racerPlayer[:Move1ButtonSprite].frame = 0 if racer == @racerPlayer
			#start cooldown timer
		#	racer[:Move1CooldownTimer] = CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate
		#when 2
			#move2
			#un-press button
		#	@racerPlayer[:Move2ButtonSprite].frame = 0 if racer == @racerPlayer
			#start cooldown timer
		#	racer[:Move2CooldownTimer] = CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate
		#when 3
			#move3
			#un-press button
		#	@racerPlayer[:Move3ButtonSprite].frame = 0 if racer == @racerPlayer
			#start cooldown timer
		#	racer[:Move3CooldownTimer] = CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate
		#when 4
			#move4
			#un-press button
		#	@racerPlayer[:Move4ButtonSprite].frame = 0 if racer == @racerPlayer
			#start cooldown timer
		#	racer[:Move4CooldownTimer] = CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate
		#end #case moveNumber
		
		#all moves except boost share a cooldown
		if moveNumber == 0
			#un-press button
			@racerPlayer[:BoostButtonSprite].frame = 0 if racer == @racerPlayer
			#start cooldown timer
			racer[:BoostCooldownTimer] = CrustangRacingSettings::BOOST_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate
		else
			#move1
			@racerPlayer[:Move1ButtonSprite].frame = 0 if racer == @racerPlayer
			#start cooldown timer
			racer[:Move1CooldownTimer] = CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate
			#move2
			@racerPlayer[:Move2ButtonSprite].frame = 0 if racer == @racerPlayer && @racerPlayer[:Move2ButtonSprite]
			#start cooldown timer
			racer[:Move2CooldownTimer] = CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate
			#move3
			@racerPlayer[:Move3ButtonSprite].frame = 0 if racer == @racerPlayer && @racerPlayer[:Move3ButtonSprite]
			#start cooldown timer
			racer[:Move3CooldownTimer] = CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate
			#move4
			@racerPlayer[:Move4ButtonSprite].frame = 0 if racer == @racerPlayer && @racerPlayer[:Move4ButtonSprite]
			#start cooldown timer
			racer[:Move4CooldownTimer] = CrustangRacingSettings::MOVE_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate
		end #if moveNumber == 0
		
	end #def self.beginCooldown(move)
	
	def self.updateCooldownTimers
		###################################
		#============= Racer1 =============
		###################################
		#do not update cooldown sprites for non-player racers because they don't have any
		#boost timer
		@racer1[:BoostCooldownTimer] -= 1 * @racer1[:BoostCooldownMultiplier] if @racer1[:BoostCooldownTimer] > 0
		#update boost timer
		@racer1[:BoostTimer] -= 1 if @racer1[:BoostTimer] > 0
		@racer1[:SecondaryBoostTimer] -= 1 if @racer1[:SecondaryBoostTimer] > 0
		
		#move1 timer
		if @racer1[:Move1CooldownTimer] > 0
			if @racer1[:ReduceCooldownCount].between?(1,3) && @racer1[:Move1][:EffectCode] == "reduceCooldown"
				#do not allow cool down if this move is a reduceCooldown move, and the racer still has cooldown reduction active (this is to prevent stacking)
			else
				#reduceCooldownCount is > 0 and move1 effect is NOT reduce cooldown or
				#reduceCooldownCount is <= 0 and move1 effect IS reduce cooldown or
				#reduce cooldownCount is <= 0 and move1 effect is NOT reduce cooldown
				@racer1[:Move1CooldownTimer] -= 1 * @racer1[:MoveCoolDownMultiplier]
			end
		end
		#move2 timer
		if @racer1[:Move2CooldownTimer] > 0
			if @racer1[:ReduceCooldownCount].between?(1,3) && @racer1[:Move2][:EffectCode] == "reduceCooldown"
			else
				@racer1[:Move2CooldownTimer] -= 1 * @racer1[:MoveCoolDownMultiplier]
			end
		end
		#move3 timer
		if @racer1[:Move3CooldownTimer] > 0
			if @racer1[:ReduceCooldownCount].between?(1,3) && @racer1[:Move3][:EffectCode] == "reduceCooldown"
			else
				@racer1[:Move3CooldownTimer] -= 1 * @racer1[:MoveCoolDownMultiplier]
			end
		end
		#move4 timer
		if @racer1[:Move4CooldownTimer] > 0
			if @racer1[:ReduceCooldownCount].between?(1,3) && @racer1[:Move4][:EffectCode] == "reduceCooldown"
			else
				@racer1[:Move4CooldownTimer] -= 1 * @racer1[:MoveCoolDownMultiplier]
			end
		end
		
		###################################
		#============= Racer2 =============
		###################################
		#do not update cooldown sprites for non-player racers because they don't have any
		#boost timer
		@racer2[:BoostCooldownTimer] -= 1 * @racer2[:BoostCooldownMultiplier] if @racer2[:BoostCooldownTimer] > 0
		#update boost timer
		@racer2[:BoostTimer] -= 1 if @racer2[:BoostTimer] > 0
		@racer2[:SecondaryBoostTimer] -= 1 if @racer2[:SecondaryBoostTimer] > 0
		
		#move1 timer
		if @racer2[:Move1CooldownTimer] > 0
			if @racer2[:ReduceCooldownCount].between?(1,3) && @racer2[:Move1][:EffectCode] == "reduceCooldown"
				#do not allow cool down if this move is a reduceCooldown move, and the racer still has cooldown reduction active (this is to prevent stacking)
			else
				#reduceCooldownCount is > 0 and move1 effect is NOT reduce cooldown or
				#reduceCooldownCount is <= 0 and move1 effect IS reduce cooldown or
				#reduce cooldownCount is <= 0 and move1 effect is NOT reduce cooldown
				@racer2[:Move1CooldownTimer] -= 1 * @racer2[:MoveCoolDownMultiplier]
			end
		end
		#move2 timer
		if @racer2[:Move2CooldownTimer] > 0
			if @racer2[:ReduceCooldownCount].between?(1,3) && @racer2[:Move2][:EffectCode] == "reduceCooldown"
			else
				@racer2[:Move2CooldownTimer] -= 1 * @racer2[:MoveCoolDownMultiplier]
			end
		end
		#move3 timer
		if @racer2[:Move3CooldownTimer] > 0
			if @racer2[:ReduceCooldownCount].between?(1,3) && @racer2[:Move3][:EffectCode] == "reduceCooldown"
			else
				@racer2[:Move3CooldownTimer] -= 1 * @racer2[:MoveCoolDownMultiplier]
			end
		end
		#move4 timer
		if @racer2[:Move4CooldownTimer] > 0
			if @racer2[:ReduceCooldownCount].between?(1,3) && @racer2[:Move4][:EffectCode] == "reduceCooldown"
			else
				@racer2[:Move4CooldownTimer] -= 1 * @racer2[:MoveCoolDownMultiplier]
			end
		end
		
		###################################
		#============= Racer3 =============
		###################################
		#do not update cooldown sprites for non-player racers because they don't have any
		#boost timer
		@racer3[:BoostCooldownTimer] -= 1 * @racer3[:BoostCooldownMultiplier] if @racer3[:BoostCooldownTimer] > 0
		#update boost timer
		@racer3[:BoostTimer] -= 1 if @racer3[:BoostTimer] > 0
		@racer3[:SecondaryBoostTimer] -= 1 if @racer3[:SecondaryBoostTimer] > 0
		
		#move1 timer
		if @racer3[:Move1CooldownTimer] > 0
			if @racer3[:ReduceCooldownCount].between?(1,3) && @racer3[:Move1][:EffectCode] == "reduceCooldown"
				#do not allow cool down if this move is a reduceCooldown move, and the racer still has cooldown reduction active (this is to prevent stacking)
			else
				#reduceCooldownCount is > 0 and move1 effect is NOT reduce cooldown or
				#reduceCooldownCount is <= 0 and move1 effect IS reduce cooldown or
				#reduce cooldownCount is <= 0 and move1 effect is NOT reduce cooldown
				@racer3[:Move1CooldownTimer] -= 1 * @racer3[:MoveCoolDownMultiplier]
			end
		end
		#move2 timer
		if @racer3[:Move2CooldownTimer] > 0
			if @racer3[:ReduceCooldownCount].between?(1,3) && @racer3[:Move2][:EffectCode] == "reduceCooldown"
			else
				@racer3[:Move2CooldownTimer] -= 1 * @racer3[:MoveCoolDownMultiplier]
			end
		end
		#move3 timer
		if @racer3[:Move3CooldownTimer] > 0
			if @racer3[:ReduceCooldownCount].between?(1,3) && @racer3[:Move3][:EffectCode] == "reduceCooldown"
			else
				@racer3[:Move3CooldownTimer] -= 1 * @racer3[:MoveCoolDownMultiplier]
			end
		end
		#move4 timer
		if @racer3[:Move4CooldownTimer] > 0
			if @racer3[:ReduceCooldownCount].between?(1,3) && @racer3[:Move4][:EffectCode] == "reduceCooldown"
			else
				@racer3[:Move4CooldownTimer] -= 1 * @racer3[:MoveCoolDownMultiplier]
			end
		end
		
		###################################
		#============= Player =============
		###################################
		#player moves' cooldown timers
		#boost
		if @racerPlayer[:BoostCooldownTimer] > 0
			@racerPlayer[:BoostCooldownTimer] -= 1 * @racerPlayer[:BoostCooldownMultiplier]
			#cooldown mask over move
			@racerPlayer[:BoostButtonCooldownMaskSprite].src_rect = Rect.new(0, 0, @racerPlayer[:BoostButtonCooldownMaskSprite].width, @boostCooldownPixelsToMovePerFrame*@racerPlayer[:BoostCooldownTimer].ceil)
		end #if @racerPlayer[:BoostCooldownTimer] > 0
		
		#update boost timer
		@racerPlayer[:BoostTimer] -= 1 if @racerPlayer[:BoostTimer] > 0
		@racerPlayer[:SecondaryBoostTimer] -= 1 if @racerPlayer[:SecondaryBoostTimer] > 0
		
		if @racerPlayer[:BoostTimer] <= 0 && @racerPlayer[:SecondaryBoostTimer] <= 0
			if @racerPlayer[:BoostingStatus] == true
				@racerPlayer[:BoostingStatus] = false
				@racerPlayer[:PreviousDesiredSpeed] = @racerPlayer[:DesiredSpeed]
				@racerPlayer[:DesiredSpeed] = CrustangRacingSettings::TOP_BASE_SPEED #if also not being boosted by another racer, etc.
			end
		end
		
		#move1 timer
		if @racerPlayer[:Move1CooldownTimer] > 0 && @racerPlayer[:Move1ButtonSprite]
			@racerPlayer[:Move1ButtonCooldownMaskSprite].src_rect = Rect.new(0, 0, @racerPlayer[:Move1ButtonCooldownMaskSprite].width, @move1CooldownPixelsToMovePerFrame*@racerPlayer[:Move1CooldownTimer].ceil)
			if @racerPlayer[:ReduceCooldownCount].between?(1,3) && @racerPlayer[:Move1][:EffectCode] == "reduceCooldown"
			else
				@racerPlayer[:Move1CooldownTimer] -= 1 * @racerPlayer[:MoveCoolDownMultiplier]
			end
		end
		#move2 timer
		if @racerPlayer[:Move2CooldownTimer] > 0 && @racerPlayer[:Move2ButtonSprite]
			@racerPlayer[:Move2ButtonCooldownMaskSprite].src_rect = Rect.new(0, 0, @racerPlayer[:Move2ButtonCooldownMaskSprite].width, @move2CooldownPixelsToMovePerFrame*@racerPlayer[:Move2CooldownTimer].ceil)
			if @racerPlayer[:ReduceCooldownCount].between?(1,3) && @racerPlayer[:Move2][:EffectCode] == "reduceCooldown"
			else
				@racerPlayer[:Move2CooldownTimer] -= 1 * @racerPlayer[:MoveCoolDownMultiplier]
			end
		end
		#move3 timer
		if @racerPlayer[:Move3CooldownTimer] > 0 && @racerPlayer[:Move3ButtonSprite]
			@racerPlayer[:Move3ButtonCooldownMaskSprite].src_rect = Rect.new(0, 0, @racerPlayer[:Move3ButtonCooldownMaskSprite].width, @move3CooldownPixelsToMovePerFrame*@racerPlayer[:Move3CooldownTimer].ceil)
			if @racerPlayer[:ReduceCooldownCount].between?(1,3) && @racerPlayer[:Move3][:EffectCode] == "reduceCooldown"
			else
				@racerPlayer[:Move3CooldownTimer] -= 1 * @racerPlayer[:MoveCoolDownMultiplier]
			end
		end
		#move4 timer
		if @racerPlayer[:Move4CooldownTimer] > 0 && @racerPlayer[:Move4ButtonSprite]
			@racerPlayer[:Move4ButtonCooldownMaskSprite].src_rect = Rect.new(0, 0, @racerPlayer[:Move4ButtonCooldownMaskSprite].width, @move4CooldownPixelsToMovePerFrame*@racerPlayer[:Move4CooldownTimer].ceil)
			if @racerPlayer[:ReduceCooldownCount].between?(1,3) && @racerPlayer[:Move4][:EffectCode] == "reduceCooldown"
			else
				@racerPlayer[:Move4CooldownTimer] -= 1 * @racerPlayer[:MoveCoolDownMultiplier]
			end
		end
	end
	
	def self.updateCooldownMultipliers
		if @startingCooldownMultiplier == true
			@initialCooldownMultiplierTimer = CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED * Graphics.frame_rate if !@initialCooldownMultiplierTimer
			@initialCooldownMultiplierTimer -= 1
			if @initialCooldownMultiplierTimer <= 0
				@startingCooldownMultiplier = false
				#set all cooldownmultipliers to 1
				@racer1[:BoostCooldownMultiplier] = 1
				@racer1[:MoveCoolDownMultiplier] = 1
				@racer2[:BoostCooldownMultiplier] = 1
				@racer2[:MoveCoolDownMultiplier] = 1
				@racer3[:BoostCooldownMultiplier] = 1
				@racer3[:MoveCoolDownMultiplier] = 1
				@racerPlayer[:BoostCooldownMultiplier] = 1
				@racerPlayer[:MoveCoolDownMultiplier] = 1
			end
		end
	end #def self.updateCooldownMultipliers
	
	def self.updateSpinOutRangeSprites
		outlineWidth = CrustangRacingSettings::SPINOUT_OUTLINE_WIDTH
		###################################
		#============= Player =============
		###################################
		sprite = @racerPlayer[:SpinOutRangeSprite]
		charge = @racerPlayer[:SpinOutCharge]
		if charge > CrustangRacingSettings::SPINOUT_MIN_RANGE
			sprite.visible = true
			#outline
			#sprite.bitmap.fill_rect(sprite.x, sprite.y, sprite.width, sprite.height, Color.red)
			sprite.bitmap.fill_rect(sprite.width/2 - charge/2, sprite.height/2 - charge/2, charge, charge, Color.red)
			#inside of the outline
			sprite.bitmap.fill_rect(sprite.width/2 - charge/2 + outlineWidth, sprite.height/2 - charge/2 + outlineWidth, charge - outlineWidth*2, charge - outlineWidth*2, Color.new(0,0,0,0))
		else
			sprite.visible = false
			#clear bitmap
			sprite.bitmap.fill_rect(0, 0, sprite.width, sprite.height, Color.new(0,0,0,0))
		end #if @racerPlayer[:SpinOutCharge] > CrustangRacingSettings::SPINOUT_MIN_RANGE
	end #def self.updateSpinOutRangeSprites
	
	def self.getMoveEffect(moveNumber)
		case moveNumber
		when 1
			move = @racerPlayer[:Move1]
		when 2
			move = @racerPlayer[:Move2]
		when 3
			move = @racerPlayer[:Move3]
		when 4
			move = @racerPlayer[:Move4]
		end
		
		return move[:EffectCode]
	end #def self.getMoveEffect
	
	def self.moveEffect(racer, moveNumber)
		if moveNumber == 0
			###################################
			#============= Boost =============
			###################################
			racer[:BoostingStatus] = true
			racer[:PreviousDesiredSpeed] = racer[:DesiredSpeed]
			racer[:DesiredSpeed] = CrustangRacingSettings::BOOST_SPEED
			racer[:BoostTimer] = (CrustangRacingSettings::BOOST_LENGTH_SECONDS + CrustangRacingSettings::SECONDS_TO_REACH_BOOST_SPEED) * Graphics.frame_rate
			self.beginCooldown(racer, 0)
			
			#give other racers temporary boost for testing purposes
			#@racer1[:CurrentSpeed] = CrustangRacingSettings::BOOST_SPEED + 3
			#@racer2[:CurrentSpeed] = CrustangRacingSettings::BOOST_SPEED - 4
			#@racer3[:CurrentSpeed] = CrustangRacingSettings::BOOST_SPEED + 6
		else
			#do something based on the racer's move's effect
			case moveNumber
			when 1
				move = racer[:Move1]
			when 2
				move = racer[:Move2]
			when 3
				move = racer[:Move3]
			when 4
				move = racer[:Move4]
			end
			
			racer[:ReduceCooldownCount] -= 1
			if racer[:ReduceCooldownCount] <= 0
				#reached the end of the reduceCooldownCount, so set cooldownMultiplier back to normal
				racer[:MoveCoolDownMultiplier] = 1
			end
			
			case move[:EffectCode]
			when "invincible" #Gain invincibility. The next obstacle that hits you does not affect you.
			when "spinOut" #Racers around you spin out, slowing them down temporarily.
				self.spinOut(racer, @racer1) if racer != @racer1 && self.withinSpinOutRange?(racer, @racer1)
				self.spinOut(racer, @racer2) if racer != @racer2 && self.withinSpinOutRange?(racer, @racer2)
				self.spinOut(racer, @racer3) if racer != @racer3 && self.withinSpinOutRange?(racer, @racer3)
				self.spinOut(racer, @racerPlayer) if racer != @racerPlayer && self.withinSpinOutRange?(racer, @racerPlayer)
			when "speedUpTarget" #Speed up another racer around you, making them more likely to hit obstacles.
			when "reduceCooldown" #Move cooldowns are reduced by half for 3 uses.
				racer[:ReduceCooldownCount] = 4
				racer[:MoveCoolDownMultiplier] = 2
			when "secondBoost" #Gain a little speed for a short time.
				racer[:BoostingStatus] = true
				racer[:PreviousDesiredSpeed] = racer[:DesiredSpeed]
				racer[:DesiredSpeed] = CrustangRacingSettings::SECONDARY_BOOST_SPEED
				racer[:SecondaryBoostTimer] = (CrustangRacingSettings::BOOST_LENGTH_SECONDS + CrustangRacingSettings::SECONDS_TO_REACH_BOOST_SPEED) * Graphics.frame_rate
			when "rockHazard" #Place a hazard where you are, leaving it behind for another racer to hit.
				self.placeHazard(racer, "rock")
			when "mudHazard" #Place a mud pit where you are, leaving it behind for another racer to hit.
			when "push" #Push racers nearby further away to your left or right.
			when "destroyObstacle" #Destory an obstacle in front of you.
			end
			
		end
	end #def self.moveEffect(racer, move)
	
	def self.placeHazard(racer, hazard)
		###################################
		#Remove Racer's Hazard of Same Type
		###################################
		if racer[:RockHazard][:Sprite] && !racer[:RockHazard][:Sprite].disposed?
			racer[:RockHazard][:Sprite].dispose
			racer[:RockHazard][:Sprite] = nil
			racer[:RockHazard][:PositionXOnTrack] = nil
			racer[:RockHazard][:OriginalPositionXOnScreen] = nil
			racer[:RockHazard][:PositionYOnTrack] = nil
			
			racer[:RockHazard][:OverviewSprite].dispose
			racer[:RockHazard][:OverviewSprite] = nil
			racer[:RockHazard][:PositionXOnTrackOverview] = nil
			racer[:RockHazard][:PositionYOnTrackOverview] = nil
		end
		
		case racer
		when @racer1
			number = 1
		when @racer2
			number = 2
		when @racer3
			number = 3
		when @racerPlayer
			number = 4
		end

		###################################
		#== Spawn Hazard Sprite on Track ==
		###################################	
		#@sprites["hazard_rock_1"]
		@sprites["hazard_#{hazard}_#{number}"] = IconSprite.new(0, 0, @viewport)
		sprite = @sprites["hazard_#{hazard}_#{number}"]
		sprite.setBitmap("Graphics/Pictures/Crustang Racing/hazard_#{hazard}")
		sprite.x = racer[:RacerSprite].x-sprite.width######### + @sprites["track1"].x#racer[:RacerSprite].x# + racer[:PositionOnTrack] + @sprites["track1"].x
		sprite.y = racer[:RacerSprite].y + racer[:RacerSprite].height/2 - sprite.height/2
		sprite.z = 99999
		racer[:RockHazard][:Sprite] = sprite
		racer[:RockHazard][:PositionXOnTrack] = racer[:PositionOnTrack]-racer[:RockHazard][:Sprite].width#-racer[:RacerSprite].width-racer[:RockHazard][:Sprite].width
		racer[:RockHazard][:OriginalPositionXOnScreen] = sprite.x
		racer[:RockHazard][:PositionYOnTrack] = sprite.y
		
		###################################
		# Spawn Hazard Sprite on Overview =
		###################################
		#@sprites["overview_hazard_rock_1"]
		@sprites["overview_hazard_#{hazard}_#{number}"] = IconSprite.new(0, 0, @viewport)
		overviewSprite = @sprites["overview_hazard_#{hazard}_#{number}"] = IconSprite.new(0, 0, @viewport)
		overviewSprite.setBitmap("Graphics/Pictures/Crustang Racing/overview_hazard_#{hazard}")
		overviewSprite.x = racer[:PositionXOnTrackOverview] + @sprites["racerPlayerPkmnOverview"].width/4
		overviewSprite.y = racer[:PositionYOnTrackOverview] + @sprites["racerPlayerPkmnOverview"].height/4
		overviewSprite.z = 99999
		racer[:RockHazard][:OverviewSprite] = overviewSprite
		racer[:RockHazard][:PositionXOnTrackOverview] = overviewSprite.x
		racer[:RockHazard][:PositionYOnTrackOverview] = overviewSprite.y
		
	end #def self.placeHazard
	
	def self.withinSpinOutRange?(attacker, recipient)
		withinRangeX = false
		withinRangeY = false
		
		###################################
		#========== WithinRangeX ==========
		###################################
		###### Checking next to attacker (same exact X)
		withinRangeX = true if attacker[:PositionOnTrack] == recipient[:PositionOnTrack]
		charge = attacker[:SpinOutCharge]
		
		###### Checking behind attacker
		spinOutRangeX = charge/2 + recipient[:RacerSprite].width/2
		
		if attacker[:PositionOnTrack] < spinOutRangeX
			#there will be some overlap between the end of the track and the beginning of the track
			positionOnTrackBehindAttacker = []
			positionOnTrackBehindAttacker.push([0, attacker[:PositionOnTrack]])
			amountHittingEndOfTrack = spinOutRangeX - attacker[:PositionOnTrack]
			positionOnTrackBehindAttacker.push([@sprites["track1"].width - amountHittingEndOfTrack, @sprites["track1"].width])
			#the above will result in something like this:
			#positionOnTrackBehindAttacker is an array with these elements: [[0, 106], [6100, 6144]]
			#so if the recipient is between positionOnTrackBehindAttacker[0][0] and positionOnTrackBehindAttacker[0][1]
			#or between positionOnTrackBehindAttacker[1][0] and positionOnTrackBehindAttacker[1][1], they are within range
		else
			positionOnTrackBehindAttacker = attacker[:PositionOnTrack] - spinOutRangeX
		end
		
		#if positionOnTrackBehindAttacker is an array or not
		if positionOnTrackBehindAttacker.kind_of?(Array)
			withinRangeX = true if recipient[:PositionOnTrack].between?(positionOnTrackBehindAttacker[0][0], positionOnTrackBehindAttacker[0][1]) || recipient[:PositionOnTrack].between?(positionOnTrackBehindAttacker[1][0], positionOnTrackBehindAttacker[1][1])
		else
			withinRangeX = true if recipient[:PositionOnTrack].between?(positionOnTrackBehindAttacker, attacker[:PositionOnTrack])
		end
		
		###### Checking in front of attacker
		spinOutRangeX = charge/2 + recipient[:RacerSprite].width/2
		
		if attacker[:PositionOnTrack] > @sprites["track1"].width - spinOutRangeX
			#there will be some overlap between the end of the track and the beginning of the track
			positionOnTrackInFrontOfAttacker = []
			positionOnTrackInFrontOfAttacker.push([attacker[:PositionOnTrack], @sprites["track1"].width])
			amountHittingBeginningOfTrack = spinOutRangeX - (@sprites["track1"].width - attacker[:PositionOnTrack])
			positionOnTrackInFrontOfAttacker.push([0, amountHittingBeginningOfTrack])
			#the above array will look something like this:
			#positionOnTrackInFrontOfAttacker is an array with these elements: [[6100, 6144], [0, 106]]
		else
			positionOnTrackInFrontOfAttacker = attacker[:PositionOnTrack] + spinOutRangeX
		end
		
		#if positionOnTrackBehindAttacker is an array or not
		if positionOnTrackInFrontOfAttacker.kind_of?(Array)
			withinRangeX = true if recipient[:PositionOnTrack].between?(positionOnTrackInFrontOfAttacker[0][0], positionOnTrackInFrontOfAttacker[0][1]) || recipient[:PositionOnTrack].between?(positionOnTrackInFrontOfAttacker[1][0], positionOnTrackInFrontOfAttacker[1][1])
		else
			withinRangeX = true if recipient[:PositionOnTrack].between?(attacker[:PositionOnTrack], positionOnTrackInFrontOfAttacker)
		end
		
		###################################
		#========== WithinRangeY ==========
		###################################
		###### Checking in front of or behind attacker (same exact Y)
		withinRangeY = true if attacker[:RacerSprite].y == recipient[:RacerSprite].y
		
		#checking above attacker
		spinOutRangeY = charge/2 - attacker[:RacerSprite].height/2
		
		withinRangeAbove = true if recipient[:RacerSprite].y.between?(attacker[:RacerSprite].y - recipient[:RacerSprite].height - spinOutRangeY + 1, attacker[:RacerSprite].y)
		
		#checking above attacker
		withinRangeBelow = true if recipient[:RacerSprite].y.between?(attacker[:RacerSprite].y, attacker[:RacerSprite].y+attacker[:RacerSprite].height + spinOutRangeY - 1)
		
		withinRangeY = true if withinRangeAbove || withinRangeBelow

		return true if withinRangeX && withinRangeY

		#print "recipient[:PositionOnTrack] is #{recipient[:PositionOnTrack]} and positionOnTrackBehindAttacker is #{positionOnTrackBehindAttacker}"
		#if all checks have been made and the recipient is not within range of any of them, return false
		return false
	end #def self.withinSpinOutRange?
	
	def self.spinOut(attacker, recipient)
		#print "Spinning out racer1" if recipient == @racer1
		#print "Spinning out racer2" if recipient == @racer2
		#print "Spinning out racer3" if recipient == @racer3
		#print "Spinning out player" if recipient == @racerPlayer
		
		#SPINOUT_DURATION_IN_SECONDS = 3
		recipient[:SpinOutTimer] = CrustangRacingSettings::SPINOUT_DURATION_IN_SECONDS * Graphics.frame_rate #with this set to 3 seconds, that gives a value of 3*40 = 120 frames
		
		#maybe lock input / AI movement if being spun out?
		
		recipient[:DesiredSpeed] = CrustangRacingSettings::SPINOUT_DESIRED_SPEED
		
	end #self.spinOut
	
	def self.updateSpinOutAnimation
		#right now, @framesBetweenSpinOutDirections is 10, so every 10 frames, we switch directions
		racer = @racer1
		if racer[:SpinOutTimer] > 0 && racer[:SpinOutDirectionTimer] <= 0
			case racer[:RacerSprite].src_rect.y
			when 0 #currently facing down
				racer[:RacerSprite].src_rect.y = 64 #spin left
				racer[:SpinOutDirectionTimer] = @framesBetweenSpinOutDirections #reset direction timer
			when 64 #currently facing left
				racer[:RacerSprite].src_rect.y = 192 #spin up
				racer[:SpinOutDirectionTimer] = @framesBetweenSpinOutDirections #reset direction timer
			when 128 #currently facing right
				racer[:RacerSprite].src_rect.y = 0 #spin down
				racer[:SpinOutDirectionTimer] = @framesBetweenSpinOutDirections #reset direction timer
			when 192 #currently facing up
				racer[:RacerSprite].src_rect.y = 128 #spin right
				racer[:SpinOutDirectionTimer] = @framesBetweenSpinOutDirections #reset direction timer
			end
		end
		
		racer = @racer2
		if racer[:SpinOutTimer] > 0 && racer[:SpinOutDirectionTimer] <= 0
			case racer[:RacerSprite].src_rect.y
			when 0 #currently facing down
				racer[:RacerSprite].src_rect.y = 64 #spin left
				racer[:SpinOutDirectionTimer] = @framesBetweenSpinOutDirections #reset direction timer
			when 64 #currently facing left
				racer[:RacerSprite].src_rect.y = 192 #spin up
				racer[:SpinOutDirectionTimer] = @framesBetweenSpinOutDirections #reset direction timer
			when 128 #currently facing right
				racer[:RacerSprite].src_rect.y = 0 #spin down
				racer[:SpinOutDirectionTimer] = @framesBetweenSpinOutDirections #reset direction timer
			when 192 #currently facing up
				racer[:RacerSprite].src_rect.y = 128 #spin right
				racer[:SpinOutDirectionTimer] = @framesBetweenSpinOutDirections #reset direction timer
			end
		end
		
		racer = @racer3
		if racer[:SpinOutTimer] > 0 && racer[:SpinOutDirectionTimer] <= 0
			case racer[:RacerSprite].src_rect.y
			when 0 #currently facing down
				racer[:RacerSprite].src_rect.y = 64 #spin left
				racer[:SpinOutDirectionTimer] = @framesBetweenSpinOutDirections #reset direction timer
			when 64 #currently facing left
				racer[:RacerSprite].src_rect.y = 192 #spin up
				racer[:SpinOutDirectionTimer] = @framesBetweenSpinOutDirections #reset direction timer
			when 128 #currently facing right
				racer[:RacerSprite].src_rect.y = 0 #spin down
				racer[:SpinOutDirectionTimer] = @framesBetweenSpinOutDirections #reset direction timer
			when 192 #currently facing up
				racer[:RacerSprite].src_rect.y = 128 #spin right
				racer[:SpinOutDirectionTimer] = @framesBetweenSpinOutDirections #reset direction timer
			end
		end
		
		racer = @racerPlayer
		if racer[:SpinOutTimer] > 0 && racer[:SpinOutDirectionTimer] <= 0
			case racer[:RacerSprite].src_rect.y
			when 0 #currently facing down
				racer[:RacerSprite].src_rect.y = 64 #spin left
				racer[:SpinOutDirectionTimer] = @framesBetweenSpinOutDirections
			when 64 #currently facing left
				racer[:RacerSprite].src_rect.y = 192 #spin up
				racer[:SpinOutDirectionTimer] = @framesBetweenSpinOutDirections
			when 128 #currently facing right
				racer[:RacerSprite].src_rect.y = 0 #spin down
				racer[:SpinOutDirectionTimer] = @framesBetweenSpinOutDirections
			when 192 #currently facing up
				racer[:RacerSprite].src_rect.y = 128 #spin right
				racer[:SpinOutDirectionTimer] = @framesBetweenSpinOutDirections #reset direction timer
			end
		end
		
		#subtract from the SpinOutTimer
		if @racer1[:SpinOutTimer] > 0
			@racer1[:SpinOutTimer] -= 1
			#set the racer's desired speed back to the top base speed when spinning out is over
			@racer1[:DesiredSpeed] = CrustangRacingSettings::TOP_BASE_SPEED if @racer1[:SpinOutTimer] <= 0
		end
		if @racer2[:SpinOutTimer] > 0
			@racer2[:SpinOutTimer] -= 1
			#set the racer's desired speed back to the top base speed when spinning out is over
			@racer2[:DesiredSpeed] = CrustangRacingSettings::TOP_BASE_SPEED if @racer2[:SpinOutTimer] <= 0
		end
		if @racer3[:SpinOutTimer] > 0
			@racer3[:SpinOutTimer] -= 1
			#set the racer's desired speed back to the top base speed when spinning out is over
			@racer3[:DesiredSpeed] = CrustangRacingSettings::TOP_BASE_SPEED if @racer3[:SpinOutTimer] <= 0
		end
		if @racerPlayer[:SpinOutTimer] > 0
			@racerPlayer[:SpinOutTimer] -= 1
			#set the racer's desired speed back to the top base speed when spinning out is over
			@racerPlayer[:DesiredSpeed] = CrustangRacingSettings::TOP_BASE_SPEED if @racerPlayer[:SpinOutTimer] <= 0
		end
		
		#subtract the SpinOutDirectionTimer, which signals the game to do the next rotation if <= 0, then it's set back to the full amount if the SpinOutTimer is still > 0
		@racer1[:SpinOutDirectionTimer] -= 1 if @racer1[:SpinOutDirectionTimer] > 0
		@racer2[:SpinOutDirectionTimer] -= 1 if @racer2[:SpinOutDirectionTimer] > 0
		@racer3[:SpinOutDirectionTimer] -= 1 if @racer3[:SpinOutDirectionTimer] > 0
		@racerPlayer[:SpinOutDirectionTimer] -= 1 if @racerPlayer[:SpinOutDirectionTimer] > 0
	end #def self.updateSpinOutAnimation
	
	def self.assignMoveEffects
		#assign move effects based on the moves the racer has
		###################################
		#============= Player =============
		###################################
		for i in 0...@enteredCrustang.moves.length
			CrustangRacingSettings::MOVE_EFFECTS.each do |key, valueHash|
				#valueHash is the move's hash containing the effect name, effect code, moves, etc.
				if valueHash[:AssignedMoves].include?(@enteredCrustang.moves[i].id)
					#print "found #{@enteredCrustang.moves[i].id} in #{valueHash}"
					case i
					when 0
						@racerPlayer[:Move1] = valueHash
					when 1
						@racerPlayer[:Move2] = valueHash
					when 2
						@racerPlayer[:Move3] = valueHash
					when 3
						@racerPlayer[:Move4] = valueHash
					end
				end #if valueHash[:AssignedMoves].include?(@enteredCrustang.moves[i].id)
			end #CrustangRacingSettings::MOVE_EFFECTS.each do |key, valueHash|
		end #for i in 0...@enteredCrustang.moves.length
	end #def self.assignMoveEffects
	
end #class CrustangRacing