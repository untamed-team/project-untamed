class CrustangRacing
	def self.updateTimers
		###################################
		#============= Racer1 =============
		###################################
		#do not update cooldown sprites for non-player racers because they don't have any
		racer = @racer1
		
		#boost
		racer[:BoostCooldownTimer] -= 1 * racer[:BoostCooldownMultiplier] if racer[:BoostCooldownTimer] > 0
		
		#update boost timer
		racer[:BoostTimer] -= 1 if racer[:BoostTimer] > 0
		racer[:SecondaryBoostTimer] -= 1 if racer[:SecondaryBoostTimer] > 0
		
		if racer[:BoostTimer] <= 0 && racer[:SecondaryBoostTimer] <= 0
			if racer[:BoostingStatus] == true
				racer[:BoostingStatus] = false
			end
		end
		
		#update bumped recovery timer
		racer[:BumpedRecoveryTimer] -= 1 if racer[:BumpedRecoveryTimer] > 0
		racer[:Bumped] = false if racer[:Bumped] == true && racer[:BumpedRecoveryTimer] <= 0
		
		#move1 timer
		if racer[:Move1CooldownTimer] > 0
			if racer[:ReduceCooldownCount].between?(1,3) && racer[:Move1][:EffectCode] == "reduceCooldown"
				#do not allow cool down if this move is a reduceCooldown move, and the racer still has cooldown reduction active (this is to prevent stacking)
			else
				#reduceCooldownCount is > 0 and move1 effect is NOT reduce cooldown or
				#reduceCooldownCount is <= 0 and move1 effect IS reduce cooldown or
				#reduce cooldownCount is <= 0 and move1 effect is NOT reduce cooldown
				racer[:Move1CooldownTimer] -= 1 * racer[:MoveCoolDownMultiplier]
			end
		end
		#move2 timer
		if racer[:Move2CooldownTimer] > 0
			if racer[:ReduceCooldownCount].between?(1,3) && racer[:Move2][:EffectCode] == "reduceCooldown"
			else
				racer[:Move2CooldownTimer] -= 1 * racer[:MoveCoolDownMultiplier]
			end
		end
		#move3 timer
		if racer[:Move3CooldownTimer] > 0
			if racer[:ReduceCooldownCount].between?(1,3) && racer[:Move3][:EffectCode] == "reduceCooldown"
			else
				racer[:Move3CooldownTimer] -= 1 * racer[:MoveCoolDownMultiplier]
			end
		end
		#move4 timer
		if racer[:Move4CooldownTimer] > 0
			if racer[:ReduceCooldownCount].between?(1,3) && racer[:Move4][:EffectCode] == "reduceCooldown"
			else
				racer[:Move4CooldownTimer] -= 1 * racer[:MoveCoolDownMultiplier]
			end
		end
		
		#subtract the SpinOutDirectionTimer, which signals the game to do the next rotation if <= 0, then it's set back to the full amount if the SpinOutTimer is still > 0
		racer[:SpinOutDirectionTimer] -= 1 if racer[:SpinOutDirectionTimer] > 0
		
		#update invincibility timer
		if racer[:InvincibilityTimer] <= 0 && !CrustangRacingSettings::INVINCIBLE_UNTIL_HIT && !racer[:DesiredHue].nil?
			self.endInvincibility(racer)
		end
		racer[:InvincibilityTimer] -= 1 if racer[:InvincibilityTimer] > 0 #the timer will not be above 0 if INVINCIBLE_UNTIL_HIT is true
		
		###################################
		#============= Racer2 =============
		###################################
		#do not update cooldown sprites for non-player racers because they don't have any
		racer = @racer2
		
		#boost
		racer[:BoostCooldownTimer] -= 1 * racer[:BoostCooldownMultiplier] if racer[:BoostCooldownTimer] > 0
		
		#update boost timer
		racer[:BoostTimer] -= 1 if racer[:BoostTimer] > 0
		racer[:SecondaryBoostTimer] -= 1 if racer[:SecondaryBoostTimer] > 0
		
		if racer[:BoostTimer] <= 0 && racer[:SecondaryBoostTimer] <= 0
			if racer[:BoostingStatus] == true
				racer[:BoostingStatus] = false
			end
		end
		
		#update bumped recovery timer
		racer[:BumpedRecoveryTimer] -= 1 if racer[:BumpedRecoveryTimer] > 0
		racer[:Bumped] = false if racer[:Bumped] == true && racer[:BumpedRecoveryTimer] <= 0
		
		#move1 timer
		if racer[:Move1CooldownTimer] > 0
			if racer[:ReduceCooldownCount].between?(1,3) && racer[:Move1][:EffectCode] == "reduceCooldown"
				#do not allow cool down if this move is a reduceCooldown move, and the racer still has cooldown reduction active (this is to prevent stacking)
			else
				#reduceCooldownCount is > 0 and move1 effect is NOT reduce cooldown or
				#reduceCooldownCount is <= 0 and move1 effect IS reduce cooldown or
				#reduce cooldownCount is <= 0 and move1 effect is NOT reduce cooldown
				racer[:Move1CooldownTimer] -= 1 * racer[:MoveCoolDownMultiplier]
			end
		end
		#move2 timer
		if racer[:Move2CooldownTimer] > 0
			if racer[:ReduceCooldownCount].between?(1,3) && racer[:Move2][:EffectCode] == "reduceCooldown"
			else
				racer[:Move2CooldownTimer] -= 1 * racer[:MoveCoolDownMultiplier]
			end
		end
		#move3 timer
		if racer[:Move3CooldownTimer] > 0
			if racer[:ReduceCooldownCount].between?(1,3) && racer[:Move3][:EffectCode] == "reduceCooldown"
			else
				racer[:Move3CooldownTimer] -= 1 * racer[:MoveCoolDownMultiplier]
			end
		end
		#move4 timer
		if racer[:Move4CooldownTimer] > 0
			if racer[:ReduceCooldownCount].between?(1,3) && racer[:Move4][:EffectCode] == "reduceCooldown"
			else
				racer[:Move4CooldownTimer] -= 1 * racer[:MoveCoolDownMultiplier]
			end
		end
		
		#subtract the SpinOutDirectionTimer
		racer[:SpinOutDirectionTimer] -= 1 if racer[:SpinOutDirectionTimer] > 0
		
		#update invincibility timer
		if racer[:InvincibilityTimer] <= 0 && !CrustangRacingSettings::INVINCIBLE_UNTIL_HIT && !racer[:DesiredHue].nil?
			self.endInvincibility(racer)
		end
		racer[:InvincibilityTimer] -= 1 if racer[:InvincibilityTimer] > 0 #the timer will not be above 0 if INVINCIBLE_UNTIL_HIT is true
		
		###################################
		#============= Racer3 =============
		###################################
		#do not update cooldown sprites for non-player racers because they don't have any
		racer = @racer3
		
		#boost
		racer[:BoostCooldownTimer] -= 1 * racer[:BoostCooldownMultiplier] if racer[:BoostCooldownTimer] > 0
		
		#update boost timer
		racer[:BoostTimer] -= 1 if racer[:BoostTimer] > 0
		racer[:SecondaryBoostTimer] -= 1 if racer[:SecondaryBoostTimer] > 0
		
		if racer[:BoostTimer] <= 0 && racer[:SecondaryBoostTimer] <= 0
			if racer[:BoostingStatus] == true
				racer[:BoostingStatus] = false
			end
		end
		
		#update bumped recovery timer
		racer[:BumpedRecoveryTimer] -= 1 if racer[:BumpedRecoveryTimer] > 0
		racer[:Bumped] = false if racer[:Bumped] == true && racer[:BumpedRecoveryTimer] <= 0
		
		#move1 timer
		if racer[:Move1CooldownTimer] > 0
			if racer[:ReduceCooldownCount].between?(1,3) && racer[:Move1][:EffectCode] == "reduceCooldown"
				#do not allow cool down if this move is a reduceCooldown move, and the racer still has cooldown reduction active (this is to prevent stacking)
			else
				#reduceCooldownCount is > 0 and move1 effect is NOT reduce cooldown or
				#reduceCooldownCount is <= 0 and move1 effect IS reduce cooldown or
				#reduce cooldownCount is <= 0 and move1 effect is NOT reduce cooldown
				racer[:Move1CooldownTimer] -= 1 * racer[:MoveCoolDownMultiplier]
			end
		end
		#move2 timer
		if racer[:Move2CooldownTimer] > 0
			if racer[:ReduceCooldownCount].between?(1,3) && racer[:Move2][:EffectCode] == "reduceCooldown"
			else
				racer[:Move2CooldownTimer] -= 1 * racer[:MoveCoolDownMultiplier]
			end
		end
		#move3 timer
		if racer[:Move3CooldownTimer] > 0
			if racer[:ReduceCooldownCount].between?(1,3) && racer[:Move3][:EffectCode] == "reduceCooldown"
			else
				racer[:Move3CooldownTimer] -= 1 * racer[:MoveCoolDownMultiplier]
			end
		end
		#move4 timer
		if racer[:Move4CooldownTimer] > 0
			if racer[:ReduceCooldownCount].between?(1,3) && racer[:Move4][:EffectCode] == "reduceCooldown"
			else
				racer[:Move4CooldownTimer] -= 1 * racer[:MoveCoolDownMultiplier]
			end
		end
		
		#subtract the SpinOutDirectionTimer
		racer[:SpinOutDirectionTimer] -= 1 if racer[:SpinOutDirectionTimer] > 0
		
		#update invincibility timer
		if racer[:InvincibilityTimer] <= 0 && !CrustangRacingSettings::INVINCIBLE_UNTIL_HIT && !racer[:DesiredHue].nil?
			self.endInvincibility(racer)
		end
		racer[:InvincibilityTimer] -= 1 if racer[:InvincibilityTimer] > 0 #the timer will not be above 0 if INVINCIBLE_UNTIL_HIT is true
		
		###################################
		#============= Player =============
		###################################
		#player moves' cooldown timers
		racer = @racerPlayer
		
		#boost
		if racer[:BoostCooldownTimer] > 0
			racer[:BoostCooldownTimer] -= 1 * racer[:BoostCooldownMultiplier]
			#cooldown mask over move
			racer[:BoostButtonCooldownMaskSprite].src_rect = Rect.new(0, 0, racer[:BoostButtonCooldownMaskSprite].width, @boostCooldownPixelsToMovePerFrame*racer[:BoostCooldownTimer].ceil)
		end #if racer[:BoostCooldownTimer] > 0
		
		#update boost timer
		racer[:BoostTimer] -= 1 if racer[:BoostTimer] > 0
		racer[:SecondaryBoostTimer] -= 1 if racer[:SecondaryBoostTimer] > 0
		
		if racer[:BoostTimer] <= 0 && racer[:SecondaryBoostTimer] <= 0
			if racer[:BoostingStatus] == true
				racer[:BoostingStatus] = false
			end
		end
		
		#update bumped recovery timer
		racer[:BumpedRecoveryTimer] -= 1 if racer[:BumpedRecoveryTimer] > 0
		racer[:Bumped] = false if racer[:Bumped] == true && racer[:BumpedRecoveryTimer] <= 0
		
		#move1 timer
		if racer[:Move1CooldownTimer] > 0 && racer[:Move1ButtonSprite]
			racer[:Move1ButtonCooldownMaskSprite].src_rect = Rect.new(0, 0, racer[:Move1ButtonCooldownMaskSprite].width, @move1CooldownPixelsToMovePerFrame*racer[:Move1CooldownTimer].ceil)
			if racer[:ReduceCooldownCount].between?(1,3) && racer[:Move1][:EffectCode] == "reduceCooldown"
			else
				racer[:Move1CooldownTimer] -= 1 * racer[:MoveCoolDownMultiplier]
			end
		end
		#move2 timer
		if racer[:Move2CooldownTimer] > 0 && racer[:Move2ButtonSprite]
			racer[:Move2ButtonCooldownMaskSprite].src_rect = Rect.new(0, 0, racer[:Move2ButtonCooldownMaskSprite].width, @move2CooldownPixelsToMovePerFrame*racer[:Move2CooldownTimer].ceil)
			if racer[:ReduceCooldownCount].between?(1,3) && racer[:Move2][:EffectCode] == "reduceCooldown"
			else
				racer[:Move2CooldownTimer] -= 1 * racer[:MoveCoolDownMultiplier]
			end
		end
		#move3 timer
		if racer[:Move3CooldownTimer] > 0 && racer[:Move3ButtonSprite]
			racer[:Move3ButtonCooldownMaskSprite].src_rect = Rect.new(0, 0, racer[:Move3ButtonCooldownMaskSprite].width, @move3CooldownPixelsToMovePerFrame*racer[:Move3CooldownTimer].ceil)
			if racer[:ReduceCooldownCount].between?(1,3) && racer[:Move3][:EffectCode] == "reduceCooldown"
			else
				racer[:Move3CooldownTimer] -= 1 * racer[:MoveCoolDownMultiplier]
			end
		end
		#move4 timer
		if racer[:Move4CooldownTimer] > 0 && racer[:Move4ButtonSprite]
			racer[:Move4ButtonCooldownMaskSprite].src_rect = Rect.new(0, 0, racer[:Move4ButtonCooldownMaskSprite].width, @move4CooldownPixelsToMovePerFrame*racer[:Move4CooldownTimer].ceil)
			if racer[:ReduceCooldownCount].between?(1,3) && racer[:Move4][:EffectCode] == "reduceCooldown"
			else
				racer[:Move4CooldownTimer] -= 1 * racer[:MoveCoolDownMultiplier]
			end
		end
		
		#subtract the SpinOutDirectionTimer
		racer[:SpinOutDirectionTimer] -= 1 if racer[:SpinOutDirectionTimer] > 0
		
		#update invincibility timer
		if racer[:InvincibilityTimer] <= 0 && !CrustangRacingSettings::INVINCIBLE_UNTIL_HIT && !racer[:DesiredHue].nil?
			self.endInvincibility(racer)
		end
		racer[:InvincibilityTimer] -= 1 if racer[:InvincibilityTimer] > 0 #the timer will not be above 0 if INVINCIBLE_UNTIL_HIT is true
		
		###################################
		#============= Misc =============
		###################################
		@currentlyPlayingSETimer -= 1
		@currentlyPlayingSE = nil if @currentlyPlayingSETimer <= 0
	end

	def self.updateSpinOutRangeSprites
		outlineWidth = CrustangRacingSettings::SPINOUT_OUTLINE_WIDTH
		###################################
		#============= Racer1 =============
		###################################
		sprite = @racer1[:SpinOutRangeSprite]
		charge = @racer1[:SpinOutCharge]
		if charge > CrustangRacingSettings::SPINOUT_MIN_RANGE
			sprite.visible = true
			#outline
			#sprite.bitmap.fill_rect(sprite.x, sprite.y, sprite.width, sprite.height, Color.red)
			sprite.bitmap.fill_rect(sprite.width/2 - charge/2, sprite.height/2 - charge/2, charge, charge, Color.red)
			#inside of the outline
			sprite.bitmap.fill_rect(sprite.width/2 - charge/2 + outlineWidth, sprite.height/2 - charge/2 + outlineWidth, charge - outlineWidth*2, charge - outlineWidth*2, Color.new(0,0,0,0))
		else
			sprite.visible = false
			#clear bitmap of color
			sprite.bitmap.fill_rect(0, 0, sprite.width, sprite.height, Color.new(0,0,0,0))
		end #if @racer1[:SpinOutCharge] > CrustangRacingSettings::SPINOUT_MIN_RANGE
		
		###################################
		#============= Racer2 =============
		###################################
		sprite = @racer2[:SpinOutRangeSprite]
		charge = @racer2[:SpinOutCharge]
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
		end #if @racer2[:SpinOutCharge] > CrustangRacingSettings::SPINOUT_MIN_RANGE
		
		###################################
		#============= Racer3 =============
		###################################
		sprite = @racer3[:SpinOutRangeSprite]
		charge = @racer3[:SpinOutCharge]
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
		end #if @racer3[:SpinOutCharge] > CrustangRacingSettings::SPINOUT_MIN_RANGE
		
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

	def self.updateOverloadRangeSprites
		outlineWidth = CrustangRacingSettings::OVERLOAD_OUTLINE_WIDTH
		###################################
		#============= Racer1 =============
		###################################
		sprite = @racer1[:OverloadRangeSprite]
		charge = @racer1[:OverloadCharge]
		if charge > CrustangRacingSettings::OVERLOAD_MIN_RANGE
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
		end #if @racer1[:OverloadCharge] > CrustangRacingSettings::OVERLOAD_MIN_RANGE
		
		###################################
		#============= Racer2 =============
		###################################
		sprite = @racer2[:OverloadRangeSprite]
		charge = @racer2[:OverloadCharge]
		if charge > CrustangRacingSettings::OVERLOAD_MIN_RANGE
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
		end #if @racer2[:OverloadCharge] > CrustangRacingSettings::OVERLOAD_MIN_RANGE
		
		###################################
		#============= Racer3 =============
		###################################
		sprite = @racer3[:OverloadRangeSprite]
		charge = @racer3[:OverloadCharge]
		if charge > CrustangRacingSettings::OVERLOAD_MIN_RANGE
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
		end #if @racer3[:OverloadCharge] > CrustangRacingSettings::OVERLOAD_MIN_RANGE
		
		###################################
		#============= Player =============
		###################################
		sprite = @racerPlayer[:OverloadRangeSprite]
		charge = @racerPlayer[:OverloadCharge]
		if charge > CrustangRacingSettings::OVERLOAD_MIN_RANGE
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
		end #if @racerPlayer[:OverloadCharge] > CrustangRacingSettings::OVERLOAD_MIN_RANGE
	end #def self.updateOverloadRangeSprites
	
	def self.updateSpinOutAnimation
		#right now, @framesBetweenSpinOutDirections is 10, so every 10 frames, we switch directions
		###################################
		#============ Racer 1 ============
		###################################
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
		#subtract from the SpinOutTimer
		if @racer1[:SpinOutTimer] > 0
			@racer1[:SpinOutTimer] -= 1
			#set the racer's desired speed back to the top base speed when spinning out is over
			@racer1[:DesiredSpeed] = CrustangRacingSettings::TOP_BASE_SPEED if @racer1[:SpinOutTimer] <= 0
		end
		
		#add to the spinoutTimer if it's <= 0 and the racer is not facing forward
		racer[:SpinOutTimer] += 1 if racer[:SpinOutTimer] <= 0 && racer[:RacerSprite].src_rect.y != 128
		
		#update overview sprite spinning
		if @racer1[:SpinOutTimer] > 0
			@racer1[:RacerTrackOverviewSprite].angle += @amountToSpin * @totalSpins
		elsif @racer1[:SpinOutTimer] <= 0 && @racer1[:RacerTrackOverviewSprite].angle > 0
			@racer1[:RacerTrackOverviewSprite].angle = 0
		end

		#subtract from the OverloadTimer
		if @racer1[:OverloadTimer] > 0
			@racer1[:OverloadTimer] -= 1
			@racer1[:Overloaded] = false if @racer1[:OverloadTimer] <= 0
		end
		
		###################################
		#============ Racer 2 ============
		###################################
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
		#subtract from the SpinOutTimer
		if @racer2[:SpinOutTimer] > 0
			@racer2[:SpinOutTimer] -= 1
			#set the racer's desired speed back to the top base speed when spinning out is over
			@racer2[:DesiredSpeed] = CrustangRacingSettings::TOP_BASE_SPEED if @racer2[:SpinOutTimer] <= 0
		end
		
		#add to the spinoutTimer if it's <= 0 and the racer is not facing forward
		racer[:SpinOutTimer] += 1 if racer[:SpinOutTimer] <= 0 && racer[:RacerSprite].src_rect.y != 128
		
		#update overview sprite spinning
		if @racer2[:SpinOutTimer] > 0
			@racer2[:RacerTrackOverviewSprite].angle += @amountToSpin * @totalSpins
		elsif @racer2[:SpinOutTimer] <= 0 && @racer2[:RacerTrackOverviewSprite].angle > 0
			@racer2[:RacerTrackOverviewSprite].angle = 0
		end

		#subtract from the OverloadTimer
		if @racer2[:OverloadTimer] > 0
			@racer2[:OverloadTimer] -= 1
			@racer2[:Overloaded] = false if @racer2[:OverloadTimer] <= 0
		end
		
		###################################
		#============ Racer 3 ============
		###################################
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
		#subtract from the SpinOutTimer
		if @racer3[:SpinOutTimer] > 0
			@racer3[:SpinOutTimer] -= 1
			#set the racer's desired speed back to the top base speed when spinning out is over
			@racer3[:DesiredSpeed] = CrustangRacingSettings::TOP_BASE_SPEED if @racer3[:SpinOutTimer] <= 0
		end
		
		#add to the spinoutTimer if it's <= 0 and the racer is not facing forward
		racer[:SpinOutTimer] += 1 if racer[:SpinOutTimer] <= 0 && racer[:RacerSprite].src_rect.y != 128
		
		#update overview sprite spinning
		if @racer3[:SpinOutTimer] > 0
			@racer3[:RacerTrackOverviewSprite].angle += @amountToSpin * @totalSpins
		elsif @racer3[:SpinOutTimer] <= 0 && @racer3[:RacerTrackOverviewSprite].angle > 0
			@racer3[:RacerTrackOverviewSprite].angle = 0
		end

		#subtract from the OverloadTimer
		if @racer3[:OverloadTimer] > 0
			@racer3[:OverloadTimer] -= 1
			@racer3[:Overloaded] = false if @racer3[:OverloadTimer] <= 0
		end
		
		###################################
		#============= Player =============
		###################################
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
		if @racerPlayer[:SpinOutTimer] > 0
			@racerPlayer[:SpinOutTimer] -= 1
			#set the racer's desired speed back to the top base speed when spinning out is over
			@racerPlayer[:DesiredSpeed] = CrustangRacingSettings::TOP_BASE_SPEED if @racerPlayer[:SpinOutTimer] <= 0
		end
		
		#add to the spinoutTimer if it's <= 0 and the racer is not facing forward
		racer[:SpinOutTimer] += 1 if racer[:SpinOutTimer] <= 0 && racer[:RacerSprite].src_rect.y != 128
		
		#update overview sprite spinning
		if @racerPlayer[:SpinOutTimer] > 0
			@racerPlayer[:RacerTrackOverviewSprite].angle += @amountToSpin * @totalSpins
		elsif @racerPlayer[:SpinOutTimer] <= 0 && @racerPlayer[:RacerTrackOverviewSprite].angle > 0
			@racerPlayer[:RacerTrackOverviewSprite].angle = 0
		end

		#subtract from the OverloadTimer
		if @racerPlayer[:OverloadTimer] > 0
			@racerPlayer[:OverloadTimer] -= 1
			@racerPlayer[:Overloaded] = false if @racerPlayer[:OverloadTimer] <= 0
		end

	end #def self.updateSpinOutAnimation

	def self.updateRacerHue
		###################################
		#============= Racer1 =============
		###################################
		#set [:DesiredHue] to nil when not invincible		
		racer = @racer1
		
		#change desired hue if reached desired hue
		case racer[:DesiredHue]
		when @hues[:Red]
			racer[:DesiredHue] = @hues[:Orange] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		when @hues[:Orange]
			racer[:DesiredHue] = @hues[:Yellow] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		when @hues[:Yellow]
			racer[:DesiredHue] = @hues[:Green] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		when @hues[:Green]
			racer[:DesiredHue] = @hues[:Blue] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		when @hues[:Blue]
			racer[:DesiredHue] = @hues[:Indigo] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		when @hues[:Indigo]
			racer[:DesiredHue] = @hues[:Violet] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		when @hues[:Violet]
			racer[:DesiredHue] = @hues[:Red] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		end
		
		if !racer[:DesiredHue].nil?
			#reach desired hue by modifying red, green. blue values os racer's sprite
			#modify red value
			racer[:RacerSprite].color.red += 10 if racer[:RacerSprite].color.red < racer[:DesiredHue][0]
			racer[:RacerSprite].color.red -= 10 if racer[:RacerSprite].color.red > racer[:DesiredHue][0]
			#modify green value
			racer[:RacerSprite].color.green += 10 if racer[:RacerSprite].color.green < racer[:DesiredHue][1]
			racer[:RacerSprite].color.green -= 10 if racer[:RacerSprite].color.green > racer[:DesiredHue][1]
			#modify blue value
			racer[:RacerSprite].color.blue += 10 if racer[:RacerSprite].color.blue < racer[:DesiredHue][2]
			racer[:RacerSprite].color.blue -= 10 if racer[:RacerSprite].color.blue > racer[:DesiredHue][2]

			racer[:RacerSprite].tone.set(racer[:RacerSprite].color.red, racer[:RacerSprite].color.green, racer[:RacerSprite].color.blue, 0)
			racer[:RacerTrackOverviewSprite].tone.set(racer[:RacerSprite].color.red, racer[:RacerSprite].color.green, racer[:RacerSprite].color.blue, 0)
		else
			racer[:RacerSprite].tone.set(0,0,0,0)
			racer[:RacerTrackOverviewSprite].tone.set(0,0,0,0)
		end #if !racer[:DesiredHue].nil?
		
		###################################
		#============= Racer2 =============
		###################################
		#set [:DesiredHue] to nil when not invincible		
		racer = @racer2
		
		#change desired hue if reached desired hue
		case racer[:DesiredHue]
		when @hues[:Red]
			racer[:DesiredHue] = @hues[:Orange] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		when @hues[:Orange]
			racer[:DesiredHue] = @hues[:Yellow] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		when @hues[:Yellow]
			racer[:DesiredHue] = @hues[:Green] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		when @hues[:Green]
			racer[:DesiredHue] = @hues[:Blue] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		when @hues[:Blue]
			racer[:DesiredHue] = @hues[:Indigo] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		when @hues[:Indigo]
			racer[:DesiredHue] = @hues[:Violet] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		when @hues[:Violet]
			racer[:DesiredHue] = @hues[:Red] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		end
		
		if !racer[:DesiredHue].nil?
			#reach desired hue by modifying red, green. blue values os racer's sprite
			#modify red value
			racer[:RacerSprite].color.red += 10 if racer[:RacerSprite].color.red < racer[:DesiredHue][0]
			racer[:RacerSprite].color.red -= 10 if racer[:RacerSprite].color.red > racer[:DesiredHue][0]
			#modify green value
			racer[:RacerSprite].color.green += 10 if racer[:RacerSprite].color.green < racer[:DesiredHue][1]
			racer[:RacerSprite].color.green -= 10 if racer[:RacerSprite].color.green > racer[:DesiredHue][1]
			#modify blue value
			racer[:RacerSprite].color.blue += 10 if racer[:RacerSprite].color.blue < racer[:DesiredHue][2]
			racer[:RacerSprite].color.blue -= 10 if racer[:RacerSprite].color.blue > racer[:DesiredHue][2]

			racer[:RacerSprite].tone.set(racer[:RacerSprite].color.red, racer[:RacerSprite].color.green, racer[:RacerSprite].color.blue, 0)
			racer[:RacerTrackOverviewSprite].tone.set(racer[:RacerSprite].color.red, racer[:RacerSprite].color.green, racer[:RacerSprite].color.blue, 0)
		else
			racer[:RacerSprite].tone.set(0,0,0,0)
			racer[:RacerTrackOverviewSprite].tone.set(0,0,0,0)
		end #if !racer[:DesiredHue].nil?
		
		###################################
		#============= Racer3 =============
		###################################
		#set [:DesiredHue] to nil when not invincible		
		racer = @racer3
		
		#change desired hue if reached desired hue
		case racer[:DesiredHue]
		when @hues[:Red]
			racer[:DesiredHue] = @hues[:Orange] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		when @hues[:Orange]
			racer[:DesiredHue] = @hues[:Yellow] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		when @hues[:Yellow]
			racer[:DesiredHue] = @hues[:Green] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		when @hues[:Green]
			racer[:DesiredHue] = @hues[:Blue] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		when @hues[:Blue]
			racer[:DesiredHue] = @hues[:Indigo] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		when @hues[:Indigo]
			racer[:DesiredHue] = @hues[:Violet] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		when @hues[:Violet]
			racer[:DesiredHue] = @hues[:Red] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		end
		
		if !racer[:DesiredHue].nil?
			#reach desired hue by modifying red, green. blue values os racer's sprite
			#modify red value
			racer[:RacerSprite].color.red += 10 if racer[:RacerSprite].color.red < racer[:DesiredHue][0]
			racer[:RacerSprite].color.red -= 10 if racer[:RacerSprite].color.red > racer[:DesiredHue][0]
			#modify green value
			racer[:RacerSprite].color.green += 10 if racer[:RacerSprite].color.green < racer[:DesiredHue][1]
			racer[:RacerSprite].color.green -= 10 if racer[:RacerSprite].color.green > racer[:DesiredHue][1]
			#modify blue value
			racer[:RacerSprite].color.blue += 10 if racer[:RacerSprite].color.blue < racer[:DesiredHue][2]
			racer[:RacerSprite].color.blue -= 10 if racer[:RacerSprite].color.blue > racer[:DesiredHue][2]

			racer[:RacerSprite].tone.set(racer[:RacerSprite].color.red, racer[:RacerSprite].color.green, racer[:RacerSprite].color.blue, 0)
			racer[:RacerTrackOverviewSprite].tone.set(racer[:RacerSprite].color.red, racer[:RacerSprite].color.green, racer[:RacerSprite].color.blue, 0)
		else
			racer[:RacerSprite].tone.set(0,0,0,0)
			racer[:RacerTrackOverviewSprite].tone.set(0,0,0,0)
		end #if !racer[:DesiredHue].nil?
		
		###################################
		#============= Player =============
		###################################
		#set [:DesiredHue] to nil when not invincible		
		racer = @racerPlayer
		
		#change desired hue if reached desired hue
		case racer[:DesiredHue]
		when @hues[:Red]
			racer[:DesiredHue] = @hues[:Orange] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		when @hues[:Orange]
			racer[:DesiredHue] = @hues[:Yellow] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		when @hues[:Yellow]
			racer[:DesiredHue] = @hues[:Green] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		when @hues[:Green]
			racer[:DesiredHue] = @hues[:Blue] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		when @hues[:Blue]
			racer[:DesiredHue] = @hues[:Indigo] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		when @hues[:Indigo]
			racer[:DesiredHue] = @hues[:Violet] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		when @hues[:Violet]
			racer[:DesiredHue] = @hues[:Red] if racer[:RacerSprite].color.red == racer[:DesiredHue][0] && racer[:RacerSprite].color.green == racer[:DesiredHue][1] && racer[:RacerSprite].color.blue == racer[:DesiredHue][2]
		end
		
		if !racer[:DesiredHue].nil?
			#reach desired hue by modifying red, green. blue values os racer's sprite
			#modify red value
			racer[:RacerSprite].color.red += 10 if racer[:RacerSprite].color.red < racer[:DesiredHue][0]
			racer[:RacerSprite].color.red -= 10 if racer[:RacerSprite].color.red > racer[:DesiredHue][0]
			#modify green value
			racer[:RacerSprite].color.green += 10 if racer[:RacerSprite].color.green < racer[:DesiredHue][1]
			racer[:RacerSprite].color.green -= 10 if racer[:RacerSprite].color.green > racer[:DesiredHue][1]
			#modify blue value
			racer[:RacerSprite].color.blue += 10 if racer[:RacerSprite].color.blue < racer[:DesiredHue][2]
			racer[:RacerSprite].color.blue -= 10 if racer[:RacerSprite].color.blue > racer[:DesiredHue][2]

			racer[:RacerSprite].tone.set(racer[:RacerSprite].color.red, racer[:RacerSprite].color.green, racer[:RacerSprite].color.blue, 0)
			racer[:RacerTrackOverviewSprite].tone.set(racer[:RacerSprite].color.red, racer[:RacerSprite].color.green, racer[:RacerSprite].color.blue, 0)
		else
			racer[:RacerSprite].tone.set(0,0,0,0)
			racer[:RacerTrackOverviewSprite].tone.set(0,0,0,0)
		end #if !racer[:DesiredHue].nil?
	end #self.updateRacerHue
end