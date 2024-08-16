class CrustangRacing

	def self.aiBoost
		###################################
		#============= Racer1 =============
		###################################
		self.moveEffect(@racer1, 0) if @racer1[:BoostCooldownTimer] <= 0 && self.rngRoll(CrustangRacingSettings::PERCENT_CHANCE_TO_BOOST_WHEN_AVAILABLE)

		###################################
		#============= Racer2 =============
		###################################
		self.moveEffect(@racer2, 0) if @racer2[:BoostCooldownTimer] <= 0 && self.rngRoll(CrustangRacingSettings::PERCENT_CHANCE_TO_BOOST_WHEN_AVAILABLE)

		###################################
		#============= Racer3 =============
		###################################
		self.moveEffect(@racer3, 0) if @racer3[:BoostCooldownTimer] <= 0 && self.rngRoll(CrustangRacingSettings::PERCENT_CHANCE_TO_BOOST_WHEN_AVAILABLE)

	end #def self.aiBoost
	
	def self.aiMove1
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
		
		###################################
		#============= Racer2 =============
		###################################
		racer = @racer2
		
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
		
		###################################
		#============= Racer3 =============
		###################################
		racer = @racer3
		
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
	end #def self.aiBoost

	def self.targetAnotherRacer
		###################################
		#============= Racer1 =============
		###################################
		racer = @racer1
		
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
		
		#if the racer has a move with the effect 'spinout', target a nearby racer who is within MAX_RANGE on the X axis
		#set a value on the racer hash that this racer is targeting another racer
		#if racer is targeting someone, do not use any moves in aiMove1
		
		#does the racer have a move with the effect 'spinout'?
		if self.hasMoveEffect?(racer, "spinOut") && self.withinMaxSpinOutRangeX?(racer, opposingRacerA)
			#set a value on the racer hash that this racer is targeting another racer
			 racer[:TargetingRacer] = opposingRacerA
		end #if self.hasMoveEffect?(racer, "spinOut")
		if self.hasMoveEffect?(racer, "spinOut") && self.withinMaxSpinOutRangeX?(racer, opposingRacerB)
			 racer[:TargetingRacer] = opposingRacerB
		end #if self.hasMoveEffect?(racer, "spinOut")
		if self.hasMoveEffect?(racer, "spinOut") && self.withinMaxSpinOutRangeX?(racer, opposingRacerC)
			 racer[:TargetingRacer] = opposingRacerC
		end #if self.hasMoveEffect?(racer, "spinOut")
	end

end #class CrustangRacing