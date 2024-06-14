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
		@racer1[:BoostCooldownTimer] -= 1 * @racer1[:BoostCoolDownMultiplier] if @racer1[:BoostCooldownTimer] > 0
		#move1 timer
		@racer1[:Move1CooldownTimer] -= 1 * @racer1[:MoveCoolDownMultiplier] if @racer1[:Move1CooldownTimer] > 0
		#move2 timer
		@racer1[:Move2CooldownTimer] -= 1 * @racer1[:MoveCoolDownMultiplier] if @racer1[:Move2CooldownTimer] > 0
		#move3 timer
		@racer1[:Move3CooldownTimer] -= 1 * @racer1[:MoveCoolDownMultiplier] if @racer1[:Move3CooldownTimer] > 0
		#move4 timer
		@racer1[:Move4CooldownTimer] -= 1 * @racer1[:MoveCoolDownMultiplier] if @racer1[:Move4CooldownTimer] > 0
		
		###################################
		#============= Racer2 =============
		###################################
		#do not update cooldown sprites for non-player racers because they don't have any
		#boost timer
		@racer2[:BoostCooldownTimer] -= 1 * @racer1[:BoostCoolDownMultiplier] if @racer2[:BoostCooldownTimer] > 0
		#move1 timer
		@racer2[:Move1CooldownTimer] -= 1 * @racer2[:MoveCoolDownMultiplier] if @racer2[:Move1CooldownTimer] > 0
		#move2 timer
		@racer2[:Move2CooldownTimer] -= 1 * @racer2[:MoveCoolDownMultiplier] if @racer2[:Move2CooldownTimer] > 0
		#move3 timer
		@racer2[:Move3CooldownTimer] -= 1 * @racer2[:MoveCoolDownMultiplier] if @racer2[:Move3CooldownTimer] > 0
		#move4 timer
		@racer2[:Move4CooldownTimer] -= 1 * @racer2[:MoveCoolDownMultiplier] if @racer2[:Move4CooldownTimer] > 0
		
		###################################
		#============= Racer3 =============
		###################################
		#do not update cooldown sprites for non-player racers because they don't have any
		#boost timer
		@racer3[:BoostCooldownTimer] -= 1 * @racer1[:BoostCoolDownMultiplier] if @racer3[:BoostCooldownTimer] > 0
		#move1 timer
		@racer3[:Move1CooldownTimer] -= 1 * @racer3[:MoveCoolDownMultiplier] if @racer3[:Move1CooldownTimer] > 0
		#move2 timer
		@racer3[:Move2CooldownTimer] -= 1 * @racer3[:MoveCoolDownMultiplier] if @racer3[:Move2CooldownTimer] > 0
		#move3 timer
		@racer3[:Move3CooldownTimer] -= 1 * @racer3[:MoveCoolDownMultiplier] if @racer3[:Move3CooldownTimer] > 0
		#move4 timer
		@racer3[:Move4CooldownTimer] -= 1 * @racer3[:MoveCoolDownMultiplier] if @racer3[:Move4CooldownTimer] > 0
		
		###################################
		#============= Player =============
		###################################
		#player moves' cooldown timers
		#boost
		if @racerPlayer[:BoostCooldownTimer] > 0
			@racerPlayer[:BoostCooldownTimer] -= 1 * @racer1[:BoostCoolDownMultiplier]
			#cooldown mask over move
			@racerPlayer[:BoostButtonCooldownMaskSprite].src_rect = Rect.new(0, 0, @racerPlayer[:BoostButtonCooldownMaskSprite].width, @boostCooldownPixelsToMovePerFrame*@racerPlayer[:BoostCooldownTimer].ceil)
		end #if @racerPlayer[:BoostCooldownTimer] > 0
		
		#move1 timer
		if @racerPlayer[:Move1CooldownTimer] > 0
			@racerPlayer[:Move1CooldownTimer] -= 1 * @racerPlayer[:MoveCoolDownMultiplier]
			@racerPlayer[:Move1ButtonCooldownMaskSprite].src_rect = Rect.new(0, 0, @racerPlayer[:Move1ButtonCooldownMaskSprite].width, @move1CooldownPixelsToMovePerFrame*@racerPlayer[:Move1CooldownTimer].ceil)
		end
		#move2 timer
		if @racerPlayer[:Move2CooldownTimer] > 0 && @racerPlayer[:Move2ButtonSprite]
			@racerPlayer[:Move2CooldownTimer] -= 1 * @racerPlayer[:MoveCoolDownMultiplier]
			@racerPlayer[:Move2ButtonCooldownMaskSprite].src_rect = Rect.new(0, 0, @racerPlayer[:Move2ButtonCooldownMaskSprite].width, @move2CooldownPixelsToMovePerFrame*@racerPlayer[:Move2CooldownTimer].ceil)
		end
		#move3 timer
		if @racerPlayer[:Move3CooldownTimer] > 0 && @racerPlayer[:Move3ButtonSprite]
			@racerPlayer[:Move3CooldownTimer] -= 1 * @racerPlayer[:MoveCoolDownMultiplier]
			@racerPlayer[:Move3ButtonCooldownMaskSprite].src_rect = Rect.new(0, 0, @racerPlayer[:Move3ButtonCooldownMaskSprite].width, @move3CooldownPixelsToMovePerFrame*@racerPlayer[:Move3CooldownTimer].ceil)
		end
		#move4 timer
		if @racerPlayer[:Move4CooldownTimer] > 0 && @racerPlayer[:Move4ButtonSprite]
			@racerPlayer[:Move4CooldownTimer] -= 1 * @racerPlayer[:MoveCoolDownMultiplier]
			@racerPlayer[:Move4ButtonCooldownMaskSprite].src_rect = Rect.new(0, 0, @racerPlayer[:Move4ButtonCooldownMaskSprite].width, @move4CooldownPixelsToMovePerFrame*@racerPlayer[:Move4CooldownTimer].ceil)
		end
	end
	
	def self.updateCooldownMultipliers
		if @startingCooldownMultiplier == true
			@initialCooldownMultiplierTimer = CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED * Graphics.frame_rate if !@initialCooldownMultiplierTimer
			@initialCooldownMultiplierTimer -= 1
			if @initialCooldownMultiplierTimer <= 0
				@startingCooldownMultiplier = false
				#set all cooldownmultipliers to 1
				@racer1[:BoostCoolDownMultiplier] = 1
				@racer1[:MoveCoolDownMultiplier] = 1
				@racer2[:BoostCoolDownMultiplier] = 1
				@racer2[:MoveCoolDownMultiplier] = 1
				@racer3[:BoostCoolDownMultiplier] = 1
				@racer3[:MoveCoolDownMultiplier] = 1
				@racerPlayer[:BoostCoolDownMultiplier] = 1
				@racerPlayer[:MoveCoolDownMultiplier] = 1
			end
		end
	end #def self.updateCooldownMultipliers
	
	def self.moveEffect(racer, moveNumber)
		#print "#{racer} used #{moveNumber}"
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