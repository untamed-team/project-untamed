class CrustangRacing

	def self.aiBoost
		###################################
		#============= Racer1 =============
		###################################
		#cannot boost if spinning out
		self.moveEffect(@racer1, 0) if @racer1[:SpinOutTimer] <= 0 && @racer1[:BoostCooldownTimer] <= 0 && self.rngRoll(CrustangRacingSettings::PERCENT_CHANCE_TO_BOOST_WHEN_AVAILABLE)

		###################################
		#============= Racer2 =============
		###################################
		self.moveEffect(@racer2, 0) if @racer2[:SpinOutTimer] <= 0 && @racer2[:BoostCooldownTimer] <= 0 && self.rngRoll(CrustangRacingSettings::PERCENT_CHANCE_TO_BOOST_WHEN_AVAILABLE)

		###################################
		#============= Racer3 =============
		###################################
		self.moveEffect(@racer3, 0) if @racer3[:SpinOutTimer] <= 0 && @racer3[:BoostCooldownTimer] <= 0 && self.rngRoll(CrustangRacingSettings::PERCENT_CHANCE_TO_BOOST_WHEN_AVAILABLE)

	end #def self.aiBoost
	
	def self.aiMove1 #might not be used anymore or might be used for things that don't require targets like spinout and overload
		#this handles actually using the move, not WHEN to use the move
		###################################
		#============= Racer1 =============
		###################################
		racer = @racer1
		
		if racer[:Move1CooldownTimer] <= 0
			case self.getMoveEffect(racer, 1)
			#using 'case' so I can add conditions here since we don't want racers using the effect 100% of the time
			when "invincible"
				self.moveEffect(racer, 1) 
				self.beginCooldown(racer, 1)
			when "spinOut"
				racer[:SpinOutCharge] += 1 if racer[:SpinOutCharge] < CrustangRacingSettings::SPINOUT_MAX_RANGE
				if racer[:SpinOutCharge] >= CrustangRacingSettings::SPINOUT_MAX_RANGE #get to the max range
					self.moveEffect(racer, 1) 
					self.beginCooldown(racer, 1)
				end #if racer[:SpinOutCharge] >= CrustangRacingSettings::SPINOUT_MAX_RANGE
				
			when "overload"
				racer[:OverloadCharge] += 1 if racer[:OverloadCharge] < CrustangRacingSettings::OVERLOAD_MAX_RANGE
				if racer[:OverloadCharge] >= CrustangRacingSettings::OVERLOAD_MAX_RANGE #get to the max range
					self.moveEffect(racer, 1) 
					self.beginCooldown(racer, 1)
				end #if racer[:SpinOutCharge] >= CrustangRacingSettings::SPINOUT_MAX_RANGE

			when "reduceCooldown"
				self.moveEffect(racer, 1) 
				self.beginCooldown(racer, 1)
			when "secondBoost"
				self.moveEffect(racer, 1) 
				self.beginCooldown(racer, 1)
			when "rockHazard"
				self.moveEffect(racer, 1) 
				self.beginCooldown(racer, 1)
			when "mudHazard"
				self.moveEffect(racer, 1) 
				self.beginCooldown(racer, 1)
			end #case self.getMoveEffect(racer, 1)
		end #if racer[:Move1CooldownTimer] <= 0
		
	end #def self.useMove1	

	def self.aiAvoidObstacles
		###################################
		#============= Racer1 =============
		###################################
		racer = @racer1
		if racer[:SpinOutTimer] <= 0 #cannot avoid obstacles if spinning out
			case racer
			when @racer1
				opposingRacerA = @racerPlayer
				opposingRacerB = @racer2
				opposingRacerC = @racer3
			when @racer2
				opposingRacerA = @racer1
				opposingRacerB = @racer3
				opposingRacerC = @racerPlayer
			when @racer3
				opposingRacerA = @racer1
				opposingRacerB = @racer2
				opposingRacerC = @racerPlayer
			when @racerPlayer
				opposingRacerA = @racer1
				opposingRacerB = @racer2
				opposingRacerC = @racer3
			end
		
			hazardToAvoid = nil #this will get overwritten if another hazard further down in the code is closer than the current hazard to avoid (by using PositionXOnTrack)
			#I don't need to worry about oldHazard PositionXOnTrack < newHazard PositionXOnTrack after the racer passes oldHazard PositionXOnTrack because once the oldHazard is behind the racer, hazardToAvoid is set to nil,
			#and the oldHazard is no longer a thought for this chunk of code
		
			if !opposingRacerA[:RockHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(racer, opposingRacerA[:RockHazard]) && self.willCollideWithHazard?(racer, opposingRacerA[:RockHazard])
				#within range of rock hazard and will collide with it
				hazardToAvoid = opposingRacerA[:RockHazard]
			end
			if !opposingRacerA[:MudHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(racer, opposingRacerA[:MudHazard]) && self.willCollideWithHazard?(racer, opposingRacerA[:MudHazard])
				#within range of mud hazard and will collide with it
				hazardToAvoid = opposingRacerA[:MudHazard] if hazardToAvoid.nil? || opposingRacerA[:MudHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] || hazardToAvoid.nil? #overwrite as the current hazard to avoid if closer than other hazard
			end
			if !opposingRacerB[:RockHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(racer, opposingRacerB[:RockHazard]) && self.willCollideWithHazard?(racer, opposingRacerB[:RockHazard])
				#within range of rock hazard and will collide with it
				hazardToAvoid = opposingRacerB[:RockHazard] if hazardToAvoid.nil? || opposingRacerB[:RockHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] #overwrite as the current hazard to avoid if closer than other hazard
			end
			if !opposingRacerB[:MudHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(racer, opposingRacerB[:MudHazard]) && self.willCollideWithHazard?(racer, opposingRacerB[:MudHazard])
				#within range of mud hazard and will collide with it
				hazardToAvoid = opposingRacerB[:MudHazard] if hazardToAvoid.nil? || opposingRacerB[:MudHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] #overwrite as the current hazard to avoid if closer than other hazard
			end
			if !opposingRacerC[:RockHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(racer, opposingRacerC[:RockHazard]) && self.willCollideWithHazard?(racer, opposingRacerC[:RockHazard])
				#within range of rock hazard and will collide with it
				hazardToAvoid = opposingRacerC[:RockHazard] if hazardToAvoid.nil? || opposingRacerC[:RockHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] #overwrite as the current hazard to avoid if closer than other hazard
			end
			if !opposingRacerC[:MudHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(racer, opposingRacerC[:MudHazard]) && self.willCollideWithHazard?(racer, opposingRacerC[:MudHazard])
				#within range of mud hazard and will collide with it
				hazardToAvoid = opposingRacerC[:MudHazard] if hazardToAvoid.nil? || opposingRacerC[:MudHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] #overwrite as the current hazard to avoid if closer than other hazard
			end
		
			#should the racer strafe up or down to avoid the upcoming hazard?
			if !hazardToAvoid.nil?
				centerYOfHazardSprite = hazardToAvoid[:PositionYOnTrack] + hazardToAvoid[:Sprite].height/2
				centerYOfRacerSprite = racer[:RacerSprite].y + racer[:RacerSprite].height/2
			
				#if the racer does not have enough room between them and the wall (or maybe another racer as well), go the other direction
				#room needed to move should be the hazard's height/2
				roomNeededToMove = hazardToAvoid[:Sprite].height/2
			
				#how many pixels between the racer and the upper wall?
				#@trackBorderTopY
				pixelsBetweenRacerAndTrackTop = (racer[:RacerSprite].y - @trackBorderTopY).abs
				#how many pixels between the racer and the upper wall?
				pixelsBetweenRacerAndTrackBottom = (@trackBorderBottomY - racer[:RacerSprite].y).abs
			
				if centerYOfHazardSprite > centerYOfRacerSprite && !racer[:CannotGoUp]
					directionToStrafe = "up"
				elsif centerYOfHazardSprite <= centerYOfRacerSprite && !racer[:CannotGoDown]
					directionToStrafe = "down"
				elsif racer[:CannotGoUp]
					directionToStrafe = "down"
				elsif racer[:CannotGoDown]
					directionToStrafe = "up"
				end
			
				case directionToStrafe
				when "up"
					if pixelsBetweenRacerAndTrackTop <= roomNeededToMove
						Console.echo_warn "not enough room to move up!"
						racer[:CannotGoUp] = true
						directionToStrafe = "down"
					end
				when "down"
					if pixelsBetweenRacerAndTrackBottom < roomNeededToMove
						Console.echo_warn "not enough room to move down!"
						racer[:CannotGoDown] = true
						directionToStrafe = "up"
					end
				end
			
				Console.echo_warn "cannot go up" if racer[:CannotGoUp]
				Console.echo_warn "cannot go down" if racer[:CannotGoDown]
				Console.echo_warn directionToStrafe
			
				case directionToStrafe
				when "up"
					self.strafeUp(racer)
				when "down"
					self.strafeDown(racer)
				end
		
			else #hazard to avoid is nil
				racer[:CannotGoUp] = false
				racer[:CannotGoDown] = false
			end #if !hazardToAvoid.nil?
		end #if racer[:SpinOutTimer] <= 0
		
		###################################
		#============= Racer2 =============
		###################################
		racer = @racer2
		
		if racer[:SpinOutTimer] <= 0
			case racer
			when @racer1
				opposingRacerA = @racerPlayer
				opposingRacerB = @racer2
				opposingRacerC = @racer3
			when @racer2
				opposingRacerA = @racer1
				opposingRacerB = @racer3
				opposingRacerC = @racerPlayer
			when @racer3
				opposingRacerA = @racer1
				opposingRacerB = @racer2
				opposingRacerC = @racerPlayer
			when @racerPlayer
				opposingRacerA = @racer1
				opposingRacerB = @racer2
				opposingRacerC = @racer3
			end
		
			hazardToAvoid = nil
		
			if !opposingRacerA[:RockHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(racer, opposingRacerA[:RockHazard]) && self.willCollideWithHazard?(racer, opposingRacerA[:RockHazard])
				#within range of rock hazard and will collide with it
				hazardToAvoid = opposingRacerA[:RockHazard]
			end
			if !opposingRacerA[:MudHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(racer, opposingRacerA[:MudHazard]) && self.willCollideWithHazard?(racer, opposingRacerA[:MudHazard])
				#within range of mud hazard and will collide with it
				hazardToAvoid = opposingRacerA[:MudHazard] if hazardToAvoid.nil? || opposingRacerA[:MudHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] || hazardToAvoid.nil? #overwrite as the current hazard to avoid if closer than other hazard
			end
			if !opposingRacerB[:RockHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(racer, opposingRacerB[:RockHazard]) && self.willCollideWithHazard?(racer, opposingRacerB[:RockHazard])
				#within range of rock hazard and will collide with it
				hazardToAvoid = opposingRacerB[:RockHazard] if hazardToAvoid.nil? || opposingRacerB[:RockHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] #overwrite as the current hazard to avoid if closer than other hazard
			end
			if !opposingRacerB[:MudHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(racer, opposingRacerB[:MudHazard]) && self.willCollideWithHazard?(racer, opposingRacerB[:MudHazard])
				#within range of mud hazard and will collide with it
				hazardToAvoid = opposingRacerB[:MudHazard] if hazardToAvoid.nil? || opposingRacerB[:MudHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] #overwrite as the current hazard to avoid if closer than other hazard
			end
			if !opposingRacerC[:RockHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(racer, opposingRacerC[:RockHazard]) && self.willCollideWithHazard?(racer, opposingRacerC[:RockHazard])
				#within range of rock hazard and will collide with it
				hazardToAvoid = opposingRacerC[:RockHazard] if hazardToAvoid.nil? || opposingRacerC[:RockHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] #overwrite as the current hazard to avoid if closer than other hazard
			end
			if !opposingRacerC[:MudHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(racer, opposingRacerC[:MudHazard]) && self.willCollideWithHazard?(racer, opposingRacerC[:MudHazard])
				#within range of mud hazard and will collide with it
				hazardToAvoid = opposingRacerC[:MudHazard] if hazardToAvoid.nil? || opposingRacerC[:MudHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] #overwrite as the current hazard to avoid if closer than other hazard
			end
		
			#should the racer strafe up or down to avoid the upcoming hazard?
			if !hazardToAvoid.nil?
				centerYOfHazardSprite = hazardToAvoid[:PositionYOnTrack] + hazardToAvoid[:Sprite].height/2
				centerYOfRacerSprite = racer[:RacerSprite].y + racer[:RacerSprite].height/2
			
				#if the racer does not have enough room between them and the wall (or maybe another racer as well), go the other direction
				#room needed to move should be the hazard's height/2
				roomNeededToMove = hazardToAvoid[:Sprite].height/2
			
				#how many pixels between the racer and the upper wall?
				#@trackBorderTopY
				pixelsBetweenRacerAndTrackTop = (racer[:RacerSprite].y - @trackBorderTopY).abs
				#how many pixels between the racer and the upper wall?
				pixelsBetweenRacerAndTrackBottom = (@trackBorderBottomY - racer[:RacerSprite].y).abs
			
				if centerYOfHazardSprite > centerYOfRacerSprite && !racer[:CannotGoUp]
					directionToStrafe = "up"
				elsif centerYOfHazardSprite <= centerYOfRacerSprite && !racer[:CannotGoDown]
					directionToStrafe = "down"
				elsif racer[:CannotGoUp]
					directionToStrafe = "down"
				elsif racer[:CannotGoDown]
					directionToStrafe = "up"
				end
			
				case directionToStrafe
				when "up"
					if pixelsBetweenRacerAndTrackTop <= roomNeededToMove
						Console.echo_warn "not enough room to move up!"
						racer[:CannotGoUp] = true
						directionToStrafe = "down"
					end
				when "down"
					if pixelsBetweenRacerAndTrackBottom < roomNeededToMove
						Console.echo_warn "not enough room to move down!"
						racer[:CannotGoDown] = true
						directionToStrafe = "up"
					end
				end
			
				Console.echo_warn "cannot go up" if racer[:CannotGoUp]
				Console.echo_warn "cannot go down" if racer[:CannotGoDown]
				Console.echo_warn directionToStrafe
			
				case directionToStrafe
				when "up"
					self.strafeUp(racer)
				when "down"
					self.strafeDown(racer)
				end
		
			else #hazard to avoid is nil
				racer[:CannotGoUp] = false
				racer[:CannotGoDown] = false
			end #if !hazardToAvoid.nil?
		end #if racer[:SpinOutTimer] <= 0
		
		###################################
		#============= Racer3 =============
		###################################
		racer = @racer3
		
		if racer[:SpinOutTimer] <= 0
			case racer
			when @racer1
				opposingRacerA = @racerPlayer
				opposingRacerB = @racer2
				opposingRacerC = @racer3
			when @racer2
				opposingRacerA = @racer1
				opposingRacerB = @racer3
				opposingRacerC = @racerPlayer
			when @racer3
				opposingRacerA = @racer1
				opposingRacerB = @racer2
				opposingRacerC = @racerPlayer
			when @racerPlayer
				opposingRacerA = @racer1
				opposingRacerB = @racer2
				opposingRacerC = @racer3
			end
		
			hazardToAvoid = nil
		
			if !opposingRacerA[:RockHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(racer, opposingRacerA[:RockHazard]) && self.willCollideWithHazard?(racer, opposingRacerA[:RockHazard])
				#within range of rock hazard and will collide with it
				hazardToAvoid = opposingRacerA[:RockHazard]
			end
			if !opposingRacerA[:MudHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(racer, opposingRacerA[:MudHazard]) && self.willCollideWithHazard?(racer, opposingRacerA[:MudHazard])
				#within range of mud hazard and will collide with it
				hazardToAvoid = opposingRacerA[:MudHazard] if hazardToAvoid.nil? || opposingRacerA[:MudHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] || hazardToAvoid.nil? #overwrite as the current hazard to avoid if closer than other hazard
			end
			if !opposingRacerB[:RockHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(racer, opposingRacerB[:RockHazard]) && self.willCollideWithHazard?(racer, opposingRacerB[:RockHazard])
				#within range of rock hazard and will collide with it
				hazardToAvoid = opposingRacerB[:RockHazard] if hazardToAvoid.nil? || opposingRacerB[:RockHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] #overwrite as the current hazard to avoid if closer than other hazard
			end
			if !opposingRacerB[:MudHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(racer, opposingRacerB[:MudHazard]) && self.willCollideWithHazard?(racer, opposingRacerB[:MudHazard])
				#within range of mud hazard and will collide with it
				hazardToAvoid = opposingRacerB[:MudHazard] if hazardToAvoid.nil? || opposingRacerB[:MudHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] #overwrite as the current hazard to avoid if closer than other hazard
			end
			if !opposingRacerC[:RockHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(racer, opposingRacerC[:RockHazard]) && self.willCollideWithHazard?(racer, opposingRacerC[:RockHazard])
				#within range of rock hazard and will collide with it
				hazardToAvoid = opposingRacerC[:RockHazard] if hazardToAvoid.nil? || opposingRacerC[:RockHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] #overwrite as the current hazard to avoid if closer than other hazard
			end
			if !opposingRacerC[:MudHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(racer, opposingRacerC[:MudHazard]) && self.willCollideWithHazard?(racer, opposingRacerC[:MudHazard])
				#within range of mud hazard and will collide with it
				hazardToAvoid = opposingRacerC[:MudHazard] if hazardToAvoid.nil? || opposingRacerC[:MudHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] #overwrite as the current hazard to avoid if closer than other hazard
			end
		
			#should the racer strafe up or down to avoid the upcoming hazard?
			if !hazardToAvoid.nil?
				centerYOfHazardSprite = hazardToAvoid[:PositionYOnTrack] + hazardToAvoid[:Sprite].height/2
				centerYOfRacerSprite = racer[:RacerSprite].y + racer[:RacerSprite].height/2
			
				#if the racer does not have enough room between them and the wall (or maybe another racer as well), go the other direction
				#room needed to move should be the hazard's height/2
				roomNeededToMove = hazardToAvoid[:Sprite].height/2
			
				#how many pixels between the racer and the upper wall?
				#@trackBorderTopY
				pixelsBetweenRacerAndTrackTop = (racer[:RacerSprite].y - @trackBorderTopY).abs
				#how many pixels between the racer and the upper wall?
				pixelsBetweenRacerAndTrackBottom = (@trackBorderBottomY - racer[:RacerSprite].y).abs
			
				if centerYOfHazardSprite > centerYOfRacerSprite && !racer[:CannotGoUp]
					directionToStrafe = "up"
				elsif centerYOfHazardSprite <= centerYOfRacerSprite && !racer[:CannotGoDown]
					directionToStrafe = "down"
				elsif racer[:CannotGoUp]
					directionToStrafe = "down"
				elsif racer[:CannotGoDown]
					directionToStrafe = "up"
				end
			
				case directionToStrafe
				when "up"
					if pixelsBetweenRacerAndTrackTop <= roomNeededToMove
						Console.echo_warn "not enough room to move up!"
						racer[:CannotGoUp] = true
						directionToStrafe = "down"
					end
				when "down"
					if pixelsBetweenRacerAndTrackBottom < roomNeededToMove
						Console.echo_warn "not enough room to move down!"
						racer[:CannotGoDown] = true
						directionToStrafe = "up"
					end
				end
			
				Console.echo_warn "cannot go up" if racer[:CannotGoUp]
				Console.echo_warn "cannot go down" if racer[:CannotGoDown]
				Console.echo_warn directionToStrafe
			
				case directionToStrafe
				when "up"
					self.strafeUp(racer)
				when "down"
					self.strafeDown(racer)
				end
		
			else #hazard to avoid is nil
				racer[:CannotGoUp] = false
				racer[:CannotGoDown] = false
			end #if !hazardToAvoid.nil?
		end #if racer[:SpinOutTimer] <= 0
	end #def self.aiBoost

	def self.aiTargetAnotherRacer
		###################################
		#============= Racer1 =============
		###################################
		racer = @racer1
		
		if racer[:SpinOutTimer] <= 0 #cannot target racer if spinning out
			if self.hasMoveEffectThatRequiresTargetAndMoveIsReady?(racer)
				case racer
				when @racer1
					opposingRacerA = @racerPlayer
					opposingRacerB = @racer2
					opposingRacerC = @racer3
				when @racer2
					opposingRacerA = @racer1
					opposingRacerB = @racer3
					opposingRacerC = @racerPlayer
				when @racer3
					opposingRacerA = @racer1
					opposingRacerB = @racer2
					opposingRacerC = @racerPlayer
				when @racerPlayer
					opposingRacerA = @racer1
					opposingRacerB = @racer2
					opposingRacerC = @racer3
				end
		
				#if the racer has a move with certain move effects, target a nearby racer who is within MAX_RANGE on the X axis
				#set a value on the racer hash that this racer is targeting another racer
				#if racer is targeting someone, do not use any moves in aiMove1
		
				#does the racer have a move with the effect 'spinout'?
				if self.hasMoveEffect?(racer, "spinOut") != false && self.withinMaxSpinOutRangeX?(racer, opposingRacerA)
					#set a value on the racer hash that this racer is targeting another racer
					distanceBetweenRacerAndTarget = ((opposingRacerA[:RacerSprite].x + (opposingRacerA[:RacerSprite].width/2)) - (racer[:RacerSprite].x + (racer[:RacerSprite].width/2))).abs
					#set the target if this target is closer than a target that is already set, or if there is no target already
					if !racer[:TargetingRacer].nil?
						distanceBetweenRacerAndPreviousTarget = ((racer[:TargetingRacer][:RacerSprite].x + (racer[:TargetingRacer][:RacerSprite].width/2)) - (racer[:RacerSprite].x + (racer[:RacerSprite].width/2))).abs
					end
					if racer[:TargetingRacer].nil? || (distanceBetweenRacerAndPreviousTarget && distanceBetweenRacerAndPreviousTarget < distanceBetweenRacerAndTarget)
						Console.echo_warn "target is racerPlayer"
						racer[:TargetingRacer] = opposingRacerA
						racer[:TargetingMoveEffect] = "spinOut"
					end
				end #if self.hasMoveEffect?(racer, "spinOut")
				if self.hasMoveEffect?(racer, "spinOut") != false && self.withinMaxSpinOutRangeX?(racer, opposingRacerB)
					#set a value on the racer hash that this racer is targeting another racer
					distanceBetweenRacerAndTarget = ((opposingRacerB[:RacerSprite].x + (opposingRacerB[:RacerSprite].width/2)) - (racer[:RacerSprite].x + (racer[:RacerSprite].width/2))).abs
					#set the target if this target is closer than a target that is already set, or if there is no target already
					if !racer[:TargetingRacer].nil?
						distanceBetweenRacerAndPreviousTarget = ((racer[:TargetingRacer][:RacerSprite].x + (racer[:TargetingRacer][:RacerSprite].width/2)) - (racer[:RacerSprite].x + (racer[:RacerSprite].width/2))).abs
					end
					if racer[:TargetingRacer].nil? || (distanceBetweenRacerAndPreviousTarget && distanceBetweenRacerAndPreviousTarget < distanceBetweenRacerAndTarget)
						Console.echo_warn "target is racer2"
						racer[:TargetingRacer] = opposingRacerB
						racer[:TargetingMoveEffect] = "spinOut"
					end
				end #if self.hasMoveEffect?(racer, "spinOut")
				if self.hasMoveEffect?(racer, "spinOut") != false && self.withinMaxSpinOutRangeX?(racer, opposingRacerC)
					#set a value on the racer hash that this racer is targeting another racer
					distanceBetweenRacerAndTarget = ((opposingRacerC[:RacerSprite].x + (opposingRacerC[:RacerSprite].width/2)) - (racer[:RacerSprite].x + (racer[:RacerSprite].width/2))).abs
					#set the target if this target is closer than a target that is already set, or if there is no target already
					if !racer[:TargetingRacer].nil?
						distanceBetweenRacerAndPreviousTarget = ((racer[:TargetingRacer][:RacerSprite].x + (racer[:TargetingRacer][:RacerSprite].width/2)) - (racer[:RacerSprite].x + (racer[:RacerSprite].width/2))).abs
					end
					if racer[:TargetingRacer].nil? || (distanceBetweenRacerAndPreviousTarget && distanceBetweenRacerAndPreviousTarget < distanceBetweenRacerAndTarget)
						Console.echo_warn "target is racer3"
						racer[:TargetingRacer] = opposingRacerC
						racer[:TargetingMoveEffect] = "spinOut"
					end
				end #if self.hasMoveEffect?(racer, "spinOut")
			
				#if no longer within X range of target, lose the target to find another
				if !racer[:TargetingRacer].nil? && !self.withinMaxSpinOutRangeX?(racer, racer[:TargetingRacer])
					racer[:TargetingRacer] = nil
					racer[:TargetingMoveEffect] = nil
				end
		
			end #if self.hasMoveEffectThatRequiresTargetAndMoveIsReady?(racer)
		end #if racer[:SpinOutTimer] <= 0
		
		
	end #def self.aiTargetAnotherRacer
	
	def self.aiStrafeTowardTarget
		###################################
		#============= Racer1 =============
		###################################
		racer = @racer1
		
		if !racer[:TargetingRacer].nil?
			#the racer has a target they want to strafe towards
			
			#temporary distance to get away from target - example: 20 would mean the racer gets 20 pixels away from the target then stop strafing to get closer
			@minimumDistanceToTarget = 20
			
			case racer[:TargetingMoveEffect]
			when "spinOut"
				#set range to max spin out range
				minimumDistanceToTarget = CrustangRacingSettings::SPINOUT_MAX_RANGE
				#Console.echo_warn "targetingmoveeffect is spinOut"
			when "overload"
				#set range to max spin out range
				minimumDistanceToTarget = CrustangRacingSettings::OVERLOAD_MAX_RANGE
			end
			
			if !self.withinSpecifiedRangeY?(racer, racer[:TargetingRacer], minimumDistanceToTarget)
				#Console.echo_warn "not yet within range"
				if racer[:RacerSprite].y < racer[:TargetingRacer][:RacerSprite].y
					#strafe down closer to target
					self.strafeDown(racer)
				elsif racer[:RacerSprite].y > racer[:TargetingRacer][:RacerSprite].y
					#strafe up closer to target
					self.strafeUp(racer)
				end
			else
				#within range, start using move!
				case racer[:TargetingMoveEffect]
				when "spinOut"
					#set the racer's spinout charge to something over 0 so it keeps charging
					racer[:SpinOutCharge] = 1 if racer[:SpinOutCharge] < 1
				when "overload"
				end
			end
			
		end
	end #def self.aiStrafeTowardTarget

end #class CrustangRacing