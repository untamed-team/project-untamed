class CrustangRacing
	
	def self.beginCooldown(racer, moveNumber)
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
				print "invinc"
				racer[:DesiredHue] = @hues[:Red]
				racer[:InvincibilityStatus] = true
				racer[:InvincibilityTimer] = CrustangRacingSettings::INVINCIBILITY_DURATION_SECONDS * Graphics.frame_rate if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			when "spinOut" #Racers around you spin out, slowing them down temporarily.
				if racer != @racer1 && self.withinSpinOutRange?(racer, @racer1)
					self.spinOut(racer, @racer1)
					self.announceAttack(racer, @racer1, "spin")
				end
				if racer != @racer2 && self.withinSpinOutRange?(racer, @racer2)
					self.spinOut(racer, @racer2)
					self.announceAttack(racer, @racer2, "spin")
				end
				if racer != @racer3 && self.withinSpinOutRange?(racer, @racer3)
					self.spinOut(racer, @racer3)
					self.announceAttack(racer, @racer3, "spin")
				end
				if racer != @racerPlayer && self.withinSpinOutRange?(racer, @racerPlayer)
					self.spinOut(racer, @racerPlayer)
					self.announceAttack(racer, @racerPlayer, "spin")
				end
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
				self.placeHazard(racer, "mud")
			when "push" #Push racers nearby further away to your left or right.
			when "destroyObstacle" #Destory an obstacle in front of you.
			end
			
		end
	end #def self.moveEffect(racer, move)
	
	def self.placeHazard(racer, hazard)
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
		#Remove Racer's Hazard of Same Type
		###################################
		self.disposeHazard(racer, hazard)
		
		###################################
		#== Spawn Hazard Sprite on Track ==
		###################################
		@sprites["hazard_#{hazard}_#{number}"] = IconSprite.new(0, 0, @viewport)
		sprite = @sprites["hazard_#{hazard}_#{number}"]
		sprite.setBitmap("Graphics/Pictures/Crustang Racing/hazard_#{hazard}")
		sprite.x = racer[:RacerSprite].x-sprite.width
		sprite.y = racer[:RacerSprite].y + racer[:RacerSprite].height/2 - sprite.height/2
		sprite.z = 99999
		
		if hazard == "rock"
			racer[:RockHazard][:Sprite] = sprite
			racer[:RockHazard][:PositionXOnTrack] = racer[:PositionOnTrack]-racer[:RockHazard][:Sprite].width#-racer[:RacerSprite].width-racer[:RockHazard][:Sprite].width
			racer[:RockHazard][:OriginalPositionXOnScreen] = sprite.x
			racer[:RockHazard][:PositionYOnTrack] = sprite.y
			offsetW = @sprites["racerPlayerPkmnOverview"].width/8
			offsetH = @sprites["racerPlayerPkmnOverview"].height/8
		elsif hazard == "mud"
			racer[:MudHazard][:Sprite] = sprite
			racer[:MudHazard][:PositionXOnTrack] = racer[:PositionOnTrack]-racer[:MudHazard][:Sprite].width
			racer[:MudHazard][:OriginalPositionXOnScreen] = sprite.x
			racer[:MudHazard][:PositionYOnTrack] = sprite.y
			offsetW = @sprites["racerPlayerPkmnOverview"].width/1.45
			offsetH = @sprites["racerPlayerPkmnOverview"].height/1.45
		end
		
		###################################
		# Spawn Hazard Sprite on Overview =
		###################################
		#@sprites["overview_hazard_rock_1"]
		@sprites["overview_hazard_#{hazard}_#{number}"] = IconSprite.new(0, 0, @viewport)
		overviewSprite = @sprites["overview_hazard_#{hazard}_#{number}"] = IconSprite.new(0, 0, @viewport)
		overviewSprite.setBitmap("Graphics/Pictures/Crustang Racing/overview_hazard_#{hazard}")
		overviewSprite.x = racer[:PositionXOnTrackOverview] + offsetW
		overviewSprite.y = racer[:PositionYOnTrackOverview] + offsetH
		overviewSprite.ox = sprite.width/2
		overviewSprite.oy = sprite.height/2
		overviewSprite.z = 99999
		
		if hazard == "rock"
			racer[:RockHazard][:OverviewSprite] = overviewSprite
			racer[:RockHazard][:PositionXOnTrackOverview] = overviewSprite.x
			racer[:RockHazard][:PositionYOnTrackOverview] = overviewSprite.y
		elsif hazard == "mud"
			racer[:MudHazard][:OverviewSprite] = overviewSprite
			racer[:MudHazard][:PositionXOnTrackOverview] = overviewSprite.x
			racer[:MudHazard][:PositionYOnTrackOverview] = overviewSprite.y
		end
		
	end #def self.placeHazard
	
	def self.disposeHazard(racer, hazard)
		###################################
		#Remove Racer's Hazard of Same Type
		###################################
		if hazard == "rock" && racer[:RockHazard][:Sprite] && !racer[:RockHazard][:Sprite].disposed?
			racer[:RockHazard][:Sprite].dispose
			racer[:RockHazard][:Sprite] = nil
			racer[:RockHazard][:PositionXOnTrack] = nil
			racer[:RockHazard][:OriginalPositionXOnScreen] = nil
			racer[:RockHazard][:PositionYOnTrack] = nil
			
			racer[:RockHazard][:OverviewSprite].dispose
			racer[:RockHazard][:OverviewSprite] = nil
			racer[:RockHazard][:PositionXOnTrackOverview] = nil
			racer[:RockHazard][:PositionYOnTrackOverview] = nil
		elsif hazard == "mud" && racer[:MudHazard][:Sprite] && !racer[:MudHazard][:Sprite].disposed?
			racer[:MudHazard][:Sprite].dispose
			racer[:MudHazard][:Sprite] = nil
			racer[:MudHazard][:PositionXOnTrack] = nil
			racer[:MudHazard][:OriginalPositionXOnScreen] = nil
			racer[:MudHazard][:PositionYOnTrack] = nil
			
			racer[:MudHazard][:OverviewSprite].dispose
			racer[:MudHazard][:OverviewSprite] = nil
			racer[:MudHazard][:PositionXOnTrackOverview] = nil
			racer[:MudHazard][:PositionYOnTrackOverview] = nil
		end
	end #def self.disposeHazard
	
	def self.spinOut(attacker, recipient)
		#SPINOUT_DURATION_IN_SECONDS = 3
		recipient[:SpinOutTimer] = CrustangRacingSettings::SPINOUT_DURATION_IN_SECONDS * Graphics.frame_rate #with this set to 3 seconds, that gives a value of 3*40 = 120 frames
		
		#maybe lock input / AI movement if being spun out?		
		recipient[:DesiredSpeed] = CrustangRacingSettings::SPINOUT_DESIRED_SPEED
	end #self.spinOut
	
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
	
	def self.announceAttack(attacker, recipient, action)
		case attacker
		when @racer1
			attacker = "Racer1"
		when @racer2
			attacker = "Racer2"
		when @racer3
			attacker = "Racer3"
		when @racerPlayer
			attacker = "RacerPlayer"
		end
		
		case recipient
		when @racer1
			recipient = "Racer1"
		when @racer2
			recipient = "Racer2"
		when @racer3
			recipient = "Racer3"
		when @racerPlayer
			recipient = "RacerPlayer"
		end
		
		Console.echo_warn "#{attacker} -> #{action} -> #{recipient}"
	end #def self.announceAttack
	
end #class CrustangRacing