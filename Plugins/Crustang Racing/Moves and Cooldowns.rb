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
		
		#move1 timer
		if @racer1[:Move1CooldownTimer] > 0
			if @racer1[:ReduceCooldownCount] > 0 && @racer1[:Move1][:EffectCode] == "reduceCooldown"
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
			if @racer1[:ReduceCooldownCount] > 0 && @racer1[:Move2][:EffectCode] == "reduceCooldown"
			else
				@racer1[:Move2CooldownTimer] -= 1 * @racer1[:MoveCoolDownMultiplier]
			end
		end
		#move3 timer
		if @racer1[:Move3CooldownTimer] > 0
			if @racer1[:ReduceCooldownCount] > 0 && @racer1[:Move3][:EffectCode] == "reduceCooldown"
			else
				@racer1[:Move3CooldownTimer] -= 1 * @racer1[:MoveCoolDownMultiplier]
			end
		end
		#move4 timer
		if @racer1[:Move4CooldownTimer] > 0
			if @racer1[:ReduceCooldownCount] > 0 && @racer1[:Move4][:EffectCode] == "reduceCooldown"
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
		
		#move1 timer
		if @racer2[:Move1CooldownTimer] > 0
			if @racer2[:ReduceCooldownCount] > 0 && @racer2[:Move1][:EffectCode] == "reduceCooldown"
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
			if @racer2[:ReduceCooldownCount] > 0 && @racer2[:Move2][:EffectCode] == "reduceCooldown"
			else
				@racer2[:Move2CooldownTimer] -= 1 * @racer2[:MoveCoolDownMultiplier]
			end
		end
		#move3 timer
		if @racer2[:Move3CooldownTimer] > 0
			if @racer2[:ReduceCooldownCount] > 0 && @racer2[:Move3][:EffectCode] == "reduceCooldown"
			else
				@racer2[:Move3CooldownTimer] -= 1 * @racer2[:MoveCoolDownMultiplier]
			end
		end
		#move4 timer
		if @racer2[:Move4CooldownTimer] > 0
			if @racer2[:ReduceCooldownCount] > 0 && @racer2[:Move4][:EffectCode] == "reduceCooldown"
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
		
		#move1 timer
		if @racer3[:Move1CooldownTimer] > 0
			if @racer3[:ReduceCooldownCount] > 0 && @racer3[:Move1][:EffectCode] == "reduceCooldown"
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
			if @racer3[:ReduceCooldownCount] > 0 && @racer3[:Move2][:EffectCode] == "reduceCooldown"
			else
				@racer3[:Move2CooldownTimer] -= 1 * @racer3[:MoveCoolDownMultiplier]
			end
		end
		#move3 timer
		if @racer3[:Move3CooldownTimer] > 0
			if @racer3[:ReduceCooldownCount] > 0 && @racer3[:Move3][:EffectCode] == "reduceCooldown"
			else
				@racer3[:Move3CooldownTimer] -= 1 * @racer3[:MoveCoolDownMultiplier]
			end
		end
		#move4 timer
		if @racer3[:Move4CooldownTimer] > 0
			if @racer3[:ReduceCooldownCount] > 0 && @racer3[:Move4][:EffectCode] == "reduceCooldown"
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
		if @racerPlayer[:BoostTimer] > 0
			@racerPlayer[:BoostTimer] -= 1
		else
			if @racerPlayer[:BoostingStatus] == true
				@racerPlayer[:BoostingStatus] = false
				@racerPlayer[:PreviousDesiredSpeed] = @racerPlayer[:DesiredSpeed]
				@racerPlayer[:DesiredSpeed] = CrustangRacingSettings::TOP_BASE_SPEED #if also not being boosted by another racer, etc.
			end
		end
		
		#move1 timer
		if @racerPlayer[:Move1CooldownTimer] > 0 && @racerPlayer[:Move1ButtonSprite]
			@racerPlayer[:Move1ButtonCooldownMaskSprite].src_rect = Rect.new(0, 0, @racerPlayer[:Move1ButtonCooldownMaskSprite].width, @move1CooldownPixelsToMovePerFrame*@racerPlayer[:Move1CooldownTimer].ceil)
			if @racerPlayer[:ReduceCooldownCount] > 0 && @racerPlayer[:Move1][:EffectCode] == "reduceCooldown"
			else
				@racerPlayer[:Move1CooldownTimer] -= 1 * @racerPlayer[:MoveCoolDownMultiplier]
			end
		end
		#move2 timer
		if @racerPlayer[:Move2CooldownTimer] > 0 && @racerPlayer[:Move2ButtonSprite]
			@racerPlayer[:Move2ButtonCooldownMaskSprite].src_rect = Rect.new(0, 0, @racerPlayer[:Move2ButtonCooldownMaskSprite].width, @move2CooldownPixelsToMovePerFrame*@racerPlayer[:Move2CooldownTimer].ceil)
			if @racerPlayer[:ReduceCooldownCount] > 0 && @racerPlayer[:Move2][:EffectCode] == "reduceCooldown"
			else
				@racerPlayer[:Move2CooldownTimer] -= 1 * @racerPlayer[:MoveCoolDownMultiplier]
			end
		end
		#move3 timer
		if @racerPlayer[:Move3CooldownTimer] > 0 && @racerPlayer[:Move3ButtonSprite]
			@racerPlayer[:Move3ButtonCooldownMaskSprite].src_rect = Rect.new(0, 0, @racerPlayer[:Move3ButtonCooldownMaskSprite].width, @move3CooldownPixelsToMovePerFrame*@racerPlayer[:Move3CooldownTimer].ceil)
			if @racerPlayer[:ReduceCooldownCount] > 0 && @racerPlayer[:Move3][:EffectCode] == "reduceCooldown"
			else
				@racerPlayer[:Move3CooldownTimer] -= 1 * @racerPlayer[:MoveCoolDownMultiplier]
			end
		end
		#move4 timer
		if @racerPlayer[:Move4CooldownTimer] > 0 && @racerPlayer[:Move4ButtonSprite]
			@racerPlayer[:Move4ButtonCooldownMaskSprite].src_rect = Rect.new(0, 0, @racerPlayer[:Move4ButtonCooldownMaskSprite].width, @move4CooldownPixelsToMovePerFrame*@racerPlayer[:Move4CooldownTimer].ceil)
			if @racerPlayer[:ReduceCooldownCount] > 0 && @racerPlayer[:Move4][:EffectCode] == "reduceCooldown"
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
			#@racer1[:CurrentSpeed] = CrustangRacingSettings::BOOST_SPEED + 2
			#@racer2[:CurrentSpeed] = CrustangRacingSettings::BOOST_SPEED - 12
			#@racer3[:CurrentSpeed] = CrustangRacingSettings::BOOST_SPEED + 3
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
			
			if racer[:ReduceCooldownCount] > 0
				racer[:ReduceCooldownCount] -= 1
			else
				#reached the end of the reduceCooldownCount, so set cooldownMultiplier back to normal
				racer[:MoveCoolDownMultiplier] = 1
			end
			
			case move[:EffectCode]
			when "invincible" #Gain invincibility. The next obstacle that hits you does not affect you.
			when "spinOut" #Racers around you spin out, slowing them down temporarily.
			when "speedUpTarget" #Speed up another racer around you, making them more likely to hit obstacles.
			when "reduceCooldown" #Move cooldowns are reduced by half for 3 uses.
				racer[:ReduceCooldownCount] = 3
				racer[:MoveCoolDownMultiplier] = 8
			when "secondBoost" #Gain a little speed for a short time.
			when "rockHazard" #Place a hazard where you are, leaving it behind for another racer to hit.
			when "mudHazard" #Place a mud pit where you are, leaving it behind for another racer to hit.
			when "push" #Push racers nearby further away to your left or right.
			when "destroyObstacle" #Destory an obstacle in front of you.
			end
			
		end
		
	end #def self.moveEffect(racer, move)
	
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