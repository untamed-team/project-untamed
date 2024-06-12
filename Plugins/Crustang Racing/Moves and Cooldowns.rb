class CrustangRacing
	
	def self.beginCooldown(racer, moveNumber)
		#move number 0 is boost
		#Move1: nil, Move1Effect: nil, Move1CooldownTimer: nil, Move1ButtonSprite: nil
		case moveNumber
		when 0
			#boost
			#un-press button
			@sprites["boostButton"].frame = 0 if racer == @racerPlayer
			#start cooldown timer
			racer[:BoostCooldownTimer] = CrustangRacingSettings::BOOST_BUTTON_COOLDOWN_SECONDS * Graphics.frame_rate
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
		#============= Racer2 =============
		###################################
		#do not update cooldown sprites for non-player racers because they don't have any
		#boost timer
		@racer2[:BoostCooldownTimer] -= 1 if @racer2[:BoostCooldownTimer] > 0
		
		#move1 timer
		#move2 timer
		#move3 timer
		#move4 timer
		
		###################################
		#============= Racer3 =============
		###################################
		#do not update cooldown sprites for non-player racers because they don't have any
		#boost timer
		@racer3[:BoostCooldownTimer] -= 1 if @racer3[:BoostCooldownTimer] > 0
		
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
	
end #class CrustangRacing