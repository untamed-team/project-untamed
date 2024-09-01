class CrustangRacing

	def self.aiLookForOpportunityToUseBoost
		###################################
		#============= Racer1 =============
		###################################
		racer = @racer1
		
		#cannot boost if spinning out
		self.moveEffect(racer, 0) if racer[:SpinOutTimer] <= 0 && racer[:BoostCooldownTimer] <= 0 && self.rngRollThrottled(CrustangRacingSettings::PERCENT_CHANCE_TO_BOOST_WHEN_AVAILABLE)

		###################################
		#============= Racer2 =============
		###################################
		racer = @racer2
		
		#cannot boost if spinning out
		self.moveEffect(racer, 0) if racer[:SpinOutTimer] <= 0 && racer[:BoostCooldownTimer] <= 0 && self.rngRollThrottled(CrustangRacingSettings::PERCENT_CHANCE_TO_BOOST_WHEN_AVAILABLE)

		###################################
		#============= Racer3 =============
		###################################
		racer = @racer3
		
		#cannot boost if spinning out
		self.moveEffect(racer, 0) if racer[:SpinOutTimer] <= 0 && racer[:BoostCooldownTimer] <= 0 && self.rngRollThrottled(CrustangRacingSettings::PERCENT_CHANCE_TO_BOOST_WHEN_AVAILABLE)

	end #def self.aiLookForOpportunityToUseBoost

	def self.aiWanderStrafe
		###################################
		#============= Racer1 =============
		###################################
		racer = @racer1

		if racer[:AvoidingSomething] != true && racer[:SpinOutTimer] <= 0 && racer[:TargetingRacer].nil? #if not avoiding something, not spinning out, and not targeting someone
			if racer[:WanderStrafeDistance] > 0
				if racer[:WanderingUp]
					self.strafeUp(racer)
				elsif racer[:WanderingDown]
					self.strafeDown(racer)
				end
			else
				#roll throttled RNG to see if we start wandering
				if self.rngRollThrottled(CrustangRacingSettings::CHANCE_TO_WANDER_STRAFE)
					#pick a direction to strafe in
					direction = rand(1..2)
				
					case direction
					when 1
						racer[:WanderingUp] = true
						racer[:WanderingDown] = false
						#Console.echo_warn "racer1 starts wandering up"
					when 2
						racer[:WanderingUp] = false
						racer[:WanderingDown] = true
						#Console.echo_warn "racer1 starts wandering down"
					end
				
					#pick a distance to strafe in that direction (random with maximum of amount possible to strafe on track until hitting a wall)
					if CrustangRacingSettings::MAX_DISTANCE_TO_WANDER_STRAFE.nil?
						maxAmountToWander = (@trackBorderBottomY - @trackBorderTopY).abs #max amount possible to wander before hitting the sides of the track
					else
						maxAmountToWander = CrustangRacingSettings::MIN_DISTANCE_TO_WANDER_STRAFE
					end
					maxAmountToWander = CrustangRacingSettings::MIN_DISTANCE_TO_WANDER_STRAFE if maxAmountToWander < CrustangRacingSettings::MIN_DISTANCE_TO_WANDER_STRAFE #in case somebody tries to set min higher than max
				
					amountOfWander = rand(CrustangRacingSettings::MIN_DISTANCE_TO_WANDER_STRAFE..maxAmountToWander)
				
					racer[:WanderStrafeDistance] = amountOfWander
				end #if self.rngRollThrottled(CrustangRacingSettings::CHANCE_TO_WANDER_STRAFE)
			end #if racer[:WanderStrafeDistance] > 0
		end #if racer[:AvoidingSomething]
		
		###################################
		#============= Racer2 =============
		###################################
		racer = @racer2

		if racer[:AvoidingSomething] != true && racer[:SpinOutTimer] <= 0 && racer[:TargetingRacer].nil? #if not avoiding something, not spinning out, and not targeting someone
			if racer[:WanderStrafeDistance] > 0
				if racer[:WanderingUp]
					self.strafeUp(racer)
				elsif racer[:WanderingDown]
					self.strafeDown(racer)
				end
			else
				#roll throttled RNG to see if we start wandering
				if self.rngRollThrottled(CrustangRacingSettings::CHANCE_TO_WANDER_STRAFE)
					#pick a direction to strafe in
					direction = rand(1..2)
				
					case direction
					when 1
						racer[:WanderingUp] = true
						racer[:WanderingDown] = false
						#Console.echo_warn "racer2 starts wandering up"
					when 2
						racer[:WanderingUp] = false
						racer[:WanderingDown] = true
						#Console.echo_warn "racer2 starts wandering down"
					end
				
					#pick a distance to strafe in that direction (random with maximum of amount possible to strafe on track until hitting a wall)
					if CrustangRacingSettings::MAX_DISTANCE_TO_WANDER_STRAFE.nil?
						maxAmountToWander = (@trackBorderBottomY - @trackBorderTopY).abs #max amount possible to wander before hitting the sides of the track
					else
						maxAmountToWander = CrustangRacingSettings::MIN_DISTANCE_TO_WANDER_STRAFE
					end
					maxAmountToWander = CrustangRacingSettings::MIN_DISTANCE_TO_WANDER_STRAFE if maxAmountToWander < CrustangRacingSettings::MIN_DISTANCE_TO_WANDER_STRAFE #in case somebody tries to set min higher than max
				
					amountOfWander = rand(CrustangRacingSettings::MIN_DISTANCE_TO_WANDER_STRAFE..maxAmountToWander)
				
					racer[:WanderStrafeDistance] = amountOfWander
				end #if self.rngRollThrottled(CrustangRacingSettings::CHANCE_TO_WANDER_STRAFE)
			end #if racer[:WanderStrafeDistance] > 0
		end #if racer[:AvoidingSomething]
		
		###################################
		#============= Racer3 =============
		###################################
		racer = @racer3

		if racer[:AvoidingSomething] != true && racer[:SpinOutTimer] <= 0 && racer[:TargetingRacer].nil? #if not avoiding something, not spinning out, and not targeting someone
			if racer[:WanderStrafeDistance] > 0
				if racer[:WanderingUp]
					self.strafeUp(racer)
				elsif racer[:WanderingDown]
					self.strafeDown(racer)
				end
			else
				#roll throttled RNG to see if we start wandering
				if self.rngRollThrottled(CrustangRacingSettings::CHANCE_TO_WANDER_STRAFE)
					#pick a direction to strafe in
					direction = rand(1..2)
				
					case direction
					when 1
						racer[:WanderingUp] = true
						racer[:WanderingDown] = false
						#Console.echo_warn "racer3 starts wandering up"
					when 2
						racer[:WanderingUp] = false
						racer[:WanderingDown] = true
						#Console.echo_warn "racer3 starts wandering down"
					end
				
					#pick a distance to strafe in that direction (random with maximum of amount possible to strafe on track until hitting a wall)
					if CrustangRacingSettings::MAX_DISTANCE_TO_WANDER_STRAFE.nil?
						maxAmountToWander = (@trackBorderBottomY - @trackBorderTopY).abs #max amount possible to wander before hitting the sides of the track
					else
						maxAmountToWander = CrustangRacingSettings::MIN_DISTANCE_TO_WANDER_STRAFE
					end
					maxAmountToWander = CrustangRacingSettings::MIN_DISTANCE_TO_WANDER_STRAFE if maxAmountToWander < CrustangRacingSettings::MIN_DISTANCE_TO_WANDER_STRAFE #in case somebody tries to set min higher than max
				
					amountOfWander = rand(CrustangRacingSettings::MIN_DISTANCE_TO_WANDER_STRAFE..maxAmountToWander)
				
					racer[:WanderStrafeDistance] = amountOfWander
				end #if self.rngRollThrottled(CrustangRacingSettings::CHANCE_TO_WANDER_STRAFE)
			end #if racer[:WanderStrafeDistance] > 0
		end #if racer[:AvoidingSomething]
	end #def self.aiWanderStrafe

	def self.aiAvoidObstacles
		###################################
		#============= Racer1 =============
		###################################
		racer = @racer1
		if racer[:InvincibilityTimer] <= 0 && racer[:SpinOutTimer] <= 0
			
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
			
			#prioritize AI avoiding hazards rather than avoiding rocky patches
			
			#should the racer strafe up or down to avoid the upcoming hazard?
			if !hazardToAvoid.nil?
				racer[:AvoidingSomething] = true
				Console.echo_warn "racer1 stops wandering to avoid something" if racer[:WanderStrafeDistance] > 0
				racer[:WanderingUp] = false
				racer[:WanderingDown] = false
				racer[:WanderStrafeDistance] = 0
			
				centerYOfHazardSprite = hazardToAvoid[:PositionYOnTrack] + hazardToAvoid[:Sprite].height/2
				centerYOfRacerSprite = racer[:RacerSprite].y + racer[:RacerSprite].height/2
			
				#if the racer does not have enough room between them and the wall (or maybe another racer as well), go the other direction
				#room needed to move should be the hazard's height/2
				roomNeededToMove = hazardToAvoid[:Sprite].height/2
			
				#how many pixels between the racer and the upper wall?
				#@trackBorderTopY
				pixelsBetweenRacerAndTrackTop = (racer[:RacerSprite].y - @trackBorderTopY).abs
				#how many pixels between the racer and the bottom wall?
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
						#Console.echo_warn "not enough room to move up!"
						racer[:CannotGoUp] = true
						directionToStrafe = "down"
					end
				when "down"
					if pixelsBetweenRacerAndTrackBottom < roomNeededToMove
						#Console.echo_warn "not enough room to move down!"
						racer[:CannotGoDown] = true
						directionToStrafe = "up"
					end
				end
			
				#Console.echo_warn "cannot go up" if racer[:CannotGoUp]
				#Console.echo_warn "cannot go down" if racer[:CannotGoDown]
				#Console.echo_warn directionToStrafe
			
				case directionToStrafe
				when "up"
					self.strafeUp(racer)
				when "down"
					self.strafeDown(racer)
				end
		
			else #hazard to avoid is nil
				if self.rngRoll(CrustangRacingSettings::CHANCE_TO_AVOID_ROCKY_PATCH_EVERY_FRAME)
					#check for rocky patches to avoid then since there is no upcoming hazard to avoid
					rockyPatchToAvoid = nil
					for i in 0...@rockyPatches.length
						if self.withinRockyPatchDetectionRange?(racer, @rockyPatches[i]) && self.willCollideWithRockyPatch?(racer, @rockyPatches[i])
							rockyPatchToAvoid = @rockyPatches[i]
						end
					end
					
					#should the racer strafe up or down to avoid the upcoming rocky patch?
					if !rockyPatchToAvoid.nil?
						racer[:AvoidingSomething] = true
						Console.echo_warn "racer1 stops wandering to avoid something" if racer[:WanderStrafeDistance] > 0
						racer[:WanderingUp] = false
						racer[:WanderingDown] = false
						racer[:WanderStrafeDistance] = 0
						
						sprite = rockyPatchToAvoid[0]
				
						centerYOfPatchSprite = sprite.y + sprite.height/2
						centerYOfRacerSprite = racer[:RacerSprite].y + racer[:RacerSprite].height/2
				
						#if the racer does not have enough room between them and the wall (or maybe another racer as well), go the other direction
						#room needed to move should be the patch's height/2
						roomNeededToMove = sprite.height/2
				
						#how many pixels between the racer and the upper wall?
						#@trackBorderTopY
						pixelsBetweenRacerAndTrackTop = (racer[:RacerSprite].y - @trackBorderTopY).abs
						#how many pixels between the racer and the bottom wall?
						pixelsBetweenRacerAndTrackBottom = (@trackBorderBottomY - racer[:RacerSprite].y).abs
			
						if centerYOfPatchSprite > centerYOfRacerSprite && !racer[:CannotGoUp]
							directionToStrafe = "up"
						elsif centerYOfPatchSprite <= centerYOfRacerSprite && !racer[:CannotGoDown]
							directionToStrafe = "down"
						elsif racer[:CannotGoUp]
							directionToStrafe = "down"
						elsif racer[:CannotGoDown]
							directionToStrafe = "up"
						end
			
						case directionToStrafe
						when "up"
							if pixelsBetweenRacerAndTrackTop <= roomNeededToMove
								#Console.echo_warn "not enough room to move up!"
								racer[:CannotGoUp] = true
								directionToStrafe = "down"
							end
						when "down"
							if pixelsBetweenRacerAndTrackBottom < roomNeededToMove
								#Console.echo_warn "not enough room to move down!"
								racer[:CannotGoDown] = true
								directionToStrafe = "up"
							end
						end
			
						#Console.echo_warn "cannot go up" if racer[:CannotGoUp]
						#Console.echo_warn "cannot go down" if racer[:CannotGoDown]
						#Console.echo_warn directionToStrafe
			
						case directionToStrafe
						when "up"
							self.strafeUp(racer)
						when "down"
							self.strafeDown(racer)
						end
			
					else #hazardToAvoid and rockyPatchToAvoid are both nil
						racer[:AvoidingSomething] = false
						Console.echo_warn "racer1 stops wandering to avoid something" if racer[:WanderStrafeDistance] > 0
						
						racer[:CannotGoUp] = false
						racer[:CannotGoDown] = false
					end #if !rockyPatchToAvoid.nil?
				end #if self.rngRoll
			end #if !hazardToAvoid.nil?
		end #if racer[:InvincibilityTimer] <= 0 && racer[:SpinOutTimer] <= 0
		
		###################################
		#============= Racer2 =============
		###################################
		racer = @racer2
		
		if racer[:InvincibilityTimer] <= 0 && racer[:SpinOutTimer] <= 0
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
		
			#prioritize AI avoiding hazards rather than avoiding rocky patches
			
			#should the racer strafe up or down to avoid the upcoming hazard?
			if !hazardToAvoid.nil?
				racer[:AvoidingSomething] = true
				Console.echo_warn "racer2 stops wandering to avoid something" if racer[:WanderStrafeDistance] > 0
				racer[:WanderingUp] = false
				racer[:WanderingDown] = false
				racer[:WanderStrafeDistance] = 0
			
				centerYOfHazardSprite = hazardToAvoid[:PositionYOnTrack] + hazardToAvoid[:Sprite].height/2
				centerYOfRacerSprite = racer[:RacerSprite].y + racer[:RacerSprite].height/2
			
				#if the racer does not have enough room between them and the wall (or maybe another racer as well), go the other direction
				#room needed to move should be the hazard's height/2
				roomNeededToMove = hazardToAvoid[:Sprite].height/2
			
				#how many pixels between the racer and the upper wall?
				#@trackBorderTopY
				pixelsBetweenRacerAndTrackTop = (racer[:RacerSprite].y - @trackBorderTopY).abs
				#how many pixels between the racer and the bottom wall?
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
						#Console.echo_warn "not enough room to move up!"
						racer[:CannotGoUp] = true
						directionToStrafe = "down"
					end
				when "down"
					if pixelsBetweenRacerAndTrackBottom < roomNeededToMove
						#Console.echo_warn "not enough room to move down!"
						racer[:CannotGoDown] = true
						directionToStrafe = "up"
					end
				end
			
				#Console.echo_warn "cannot go up" if racer[:CannotGoUp]
				#Console.echo_warn "cannot go down" if racer[:CannotGoDown]
				#Console.echo_warn directionToStrafe
			
				case directionToStrafe
				when "up"
					self.strafeUp(racer)
				when "down"
					self.strafeDown(racer)
				end
		
			else #hazard to avoid is nil
				if self.rngRoll(CrustangRacingSettings::CHANCE_TO_AVOID_ROCKY_PATCH_EVERY_FRAME)
					#check for rocky patches to avoid then since there is no upcoming hazard to avoid
					rockyPatchToAvoid = nil
					for i in 0...@rockyPatches.length
						if self.withinRockyPatchDetectionRange?(racer, @rockyPatches[i]) && self.willCollideWithRockyPatch?(racer, @rockyPatches[i])
							rockyPatchToAvoid = @rockyPatches[i]
						end
					end
					
					#should the racer strafe up or down to avoid the upcoming rocky patch?
					if !rockyPatchToAvoid.nil?
						racer[:AvoidingSomething] = true
						Console.echo_warn "racer2 stops wandering to avoid something" if racer[:WanderStrafeDistance] > 0
						racer[:WanderingUp] = false
						racer[:WanderingDown] = false
						racer[:WanderStrafeDistance] = 0
						
						sprite = rockyPatchToAvoid[0]
				
						centerYOfPatchSprite = sprite.y + sprite.height/2
						centerYOfRacerSprite = racer[:RacerSprite].y + racer[:RacerSprite].height/2
				
						#if the racer does not have enough room between them and the wall (or maybe another racer as well), go the other direction
						#room needed to move should be the patch's height/2
						roomNeededToMove = sprite.height/2
				
						#how many pixels between the racer and the upper wall?
						#@trackBorderTopY
						pixelsBetweenRacerAndTrackTop = (racer[:RacerSprite].y - @trackBorderTopY).abs
						#how many pixels between the racer and the bottom wall?
						pixelsBetweenRacerAndTrackBottom = (@trackBorderBottomY - racer[:RacerSprite].y).abs
			
						if centerYOfPatchSprite > centerYOfRacerSprite && !racer[:CannotGoUp]
							directionToStrafe = "up"
						elsif centerYOfPatchSprite <= centerYOfRacerSprite && !racer[:CannotGoDown]
							directionToStrafe = "down"
						elsif racer[:CannotGoUp]
							directionToStrafe = "down"
						elsif racer[:CannotGoDown]
							directionToStrafe = "up"
						end
			
						case directionToStrafe
						when "up"
							if pixelsBetweenRacerAndTrackTop <= roomNeededToMove
								#Console.echo_warn "not enough room to move up!"
								racer[:CannotGoUp] = true
								directionToStrafe = "down"
							end
						when "down"
							if pixelsBetweenRacerAndTrackBottom < roomNeededToMove
								#Console.echo_warn "not enough room to move down!"
								racer[:CannotGoDown] = true
								directionToStrafe = "up"
							end
						end
			
						#Console.echo_warn "cannot go up" if racer[:CannotGoUp]
						#Console.echo_warn "cannot go down" if racer[:CannotGoDown]
						#Console.echo_warn directionToStrafe
			
						case directionToStrafe
						when "up"
							self.strafeUp(racer)
						when "down"
							self.strafeDown(racer)
						end
			
					else #hazardToAvoid and rockyPatchToAvoid are both nil
						racer[:AvoidingSomething] = false
						Console.echo_warn "racer2 stops wandering to avoid something" if racer[:WanderStrafeDistance] > 0
						
						racer[:CannotGoUp] = false
						racer[:CannotGoDown] = false
					end #if !rockyPatchToAvoid.nil?
				end #if self.rngRoll
			end #if !hazardToAvoid.nil?
		end #if racer[:InvincibilityTimer] <= 0 && racer[:SpinOutTimer] <= 0
		
		###################################
		#============= Racer3 =============
		###################################
		racer = @racer3
		
		if racer[:InvincibilityTimer] <= 0 && racer[:SpinOutTimer] <= 0
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
			
			#prioritize AI avoiding hazards rather than avoiding rocky patches
			
			#should the racer strafe up or down to avoid the upcoming hazard?
			if !hazardToAvoid.nil?
				racer[:AvoidingSomething] = true
				Console.echo_warn "racer3 stops wandering to avoid something" if racer[:WanderStrafeDistance] > 0
				racer[:WanderingUp] = false
				racer[:WanderingDown] = false
				racer[:WanderStrafeDistance] = 0
			
				centerYOfHazardSprite = hazardToAvoid[:PositionYOnTrack] + hazardToAvoid[:Sprite].height/2
				centerYOfRacerSprite = racer[:RacerSprite].y + racer[:RacerSprite].height/2
			
				#if the racer does not have enough room between them and the wall (or maybe another racer as well), go the other direction
				#room needed to move should be the hazard's height/2
				roomNeededToMove = hazardToAvoid[:Sprite].height/2
			
				#how many pixels between the racer and the upper wall?
				#@trackBorderTopY
				pixelsBetweenRacerAndTrackTop = (racer[:RacerSprite].y - @trackBorderTopY).abs
				#how many pixels between the racer and the bottom wall?
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
						#Console.echo_warn "not enough room to move up!"
						racer[:CannotGoUp] = true
						directionToStrafe = "down"
					end
				when "down"
					if pixelsBetweenRacerAndTrackBottom < roomNeededToMove
						#Console.echo_warn "not enough room to move down!"
						racer[:CannotGoDown] = true
						directionToStrafe = "up"
					end
				end
			
				#Console.echo_warn "cannot go up" if racer[:CannotGoUp]
				#Console.echo_warn "cannot go down" if racer[:CannotGoDown]
				#Console.echo_warn directionToStrafe
			
				case directionToStrafe
				when "up"
					self.strafeUp(racer)
				when "down"
					self.strafeDown(racer)
				end
		
			else #hazard to avoid is nil
				if self.rngRoll(CrustangRacingSettings::CHANCE_TO_AVOID_ROCKY_PATCH_EVERY_FRAME)
					#check for rocky patches to avoid then since there is no upcoming hazard to avoid
					rockyPatchToAvoid = nil
					for i in 0...@rockyPatches.length
						if self.withinRockyPatchDetectionRange?(racer, @rockyPatches[i]) && self.willCollideWithRockyPatch?(racer, @rockyPatches[i])
							rockyPatchToAvoid = @rockyPatches[i]
						end
					end
					
					#should the racer strafe up or down to avoid the upcoming rocky patch?
					if !rockyPatchToAvoid.nil?
						racer[:AvoidingSomething] = true
						Console.echo_warn "racer3 stops wandering to avoid something" if racer[:WanderStrafeDistance] > 0
						racer[:WanderingUp] = false
						racer[:WanderingDown] = false
						racer[:WanderStrafeDistance] = 0
						
						sprite = rockyPatchToAvoid[0]
				
						centerYOfPatchSprite = sprite.y + sprite.height/2
						centerYOfRacerSprite = racer[:RacerSprite].y + racer[:RacerSprite].height/2
				
						#if the racer does not have enough room between them and the wall (or maybe another racer as well), go the other direction
						#room needed to move should be the patch's height/2
						roomNeededToMove = sprite.height/2
				
						#how many pixels between the racer and the upper wall?
						#@trackBorderTopY
						pixelsBetweenRacerAndTrackTop = (racer[:RacerSprite].y - @trackBorderTopY).abs
						#how many pixels between the racer and the bottom wall?
						pixelsBetweenRacerAndTrackBottom = (@trackBorderBottomY - racer[:RacerSprite].y).abs
			
						if centerYOfPatchSprite > centerYOfRacerSprite && !racer[:CannotGoUp]
							directionToStrafe = "up"
						elsif centerYOfPatchSprite <= centerYOfRacerSprite && !racer[:CannotGoDown]
							directionToStrafe = "down"
						elsif racer[:CannotGoUp]
							directionToStrafe = "down"
						elsif racer[:CannotGoDown]
							directionToStrafe = "up"
						end
			
						case directionToStrafe
						when "up"
							if pixelsBetweenRacerAndTrackTop <= roomNeededToMove
								#Console.echo_warn "not enough room to move up!"
								racer[:CannotGoUp] = true
								directionToStrafe = "down"
							end
						when "down"
							if pixelsBetweenRacerAndTrackBottom < roomNeededToMove
								#Console.echo_warn "not enough room to move down!"
								racer[:CannotGoDown] = true
								directionToStrafe = "up"
							end
						end
			
						#Console.echo_warn "cannot go up" if racer[:CannotGoUp]
						#Console.echo_warn "cannot go down" if racer[:CannotGoDown]
						#Console.echo_warn directionToStrafe
			
						case directionToStrafe
						when "up"
							self.strafeUp(racer)
						when "down"
							self.strafeDown(racer)
						end
			
					else #hazardToAvoid and rockyPatchToAvoid are both nil
						racer[:AvoidingSomething] = false
						Console.echo_warn "racer3 stops wandering to avoid something" if racer[:WanderStrafeDistance] > 0
						
						racer[:CannotGoUp] = false
						racer[:CannotGoDown] = false
					end #if !rockyPatchToAvoid.nil?
				end #if self.rngRoll
			end #if !hazardToAvoid.nil?
		end #if racer[:InvincibilityTimer] <= 0 && racer[:SpinOutTimer] <= 0
	end #def self.aiAvoidObstacles

	def self.aiTargetAnotherRacer
		###################################
		#============= Racer1 =============
		###################################
		racer = @racer1
		
		#Console.echo_warn self.hasMoveEffectThatRequiresTargetAndMoveIsReady?(racer)
		if self.hasMoveEffectThatRequiresTargetAndMoveIsReady?(racer) && racer[:SpinOutTimer] <= 0 && self.rngRollThrottled(CrustangRacingSettings::PERCENT_CHANCE_TO_TARGET_RACER)
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
				distanceXBetweenRacerAndTarget = ((opposingRacerA[:RacerSprite].x + (opposingRacerA[:RacerSprite].width/2)) - (racer[:RacerSprite].x + (racer[:RacerSprite].width/2))).abs
				distanceYBetweenRacerAndTarget = ((opposingRacerA[:RacerSprite].y + (opposingRacerA[:RacerSprite].height/2)) - (racer[:RacerSprite].y + (racer[:RacerSprite].height/2))).abs
				combinedDistanceBetweenRacerAndTarget = distanceXBetweenRacerAndTarget + distanceYBetweenRacerAndTarget
				#set the target if this target is closer than a target that is already set, or if there is no target already
				if !racer[:TargetingRacer].nil?
					distanceXBetweenRacerAndPreviousTarget = ((racer[:TargetingRacer][:RacerSprite].x + (racer[:TargetingRacer][:RacerSprite].width/2)) - (racer[:RacerSprite].x + (racer[:RacerSprite].width/2))).abs
					distanceYBetweenRacerAndPreviousTarget = ((racer[:TargetingRacer][:RacerSprite].y + (racer[:TargetingRacer][:RacerSprite].height/2)) - (racer[:RacerSprite].y + (racer[:RacerSprite].height/2))).abs
					combinedDistanceBetweenRacerAndPreviousTarget = distanceXBetweenRacerAndPreviousTarget + distanceYBetweenRacerAndPreviousTarget
				end
				if racer[:TargetingRacer].nil? || (combinedDistanceBetweenRacerAndPreviousTarget && combinedDistanceBetweenRacerAndTarget < combinedDistanceBetweenRacerAndPreviousTarget)
					#Console.echo_warn "distance between racer1 and player is #{combinedDistanceBetweenRacerAndTarget}"
					#Console.echo_warn "target is racerPlayer"
					racer[:TargetingRacer] = opposingRacerA
					racer[:TargetingMoveEffect] = "spinOut"
				end
			end #if self.hasMoveEffect?(racer, "spinOut")
			if self.hasMoveEffect?(racer, "spinOut") != false && self.withinMaxSpinOutRangeX?(racer, opposingRacerB)
				#set a value on the racer hash that this racer is targeting another racer
				distanceXBetweenRacerAndTarget = ((opposingRacerB[:RacerSprite].x + (opposingRacerB[:RacerSprite].width/2)) - (racer[:RacerSprite].x + (racer[:RacerSprite].width/2))).abs
				distanceYBetweenRacerAndTarget = ((opposingRacerB[:RacerSprite].y + (opposingRacerB[:RacerSprite].height/2)) - (racer[:RacerSprite].y + (racer[:RacerSprite].height/2))).abs
				combinedDistanceBetweenRacerAndTarget = distanceXBetweenRacerAndTarget + distanceYBetweenRacerAndTarget
				#set the target if this target is closer than a target that is already set, or if there is no target already
				if !racer[:TargetingRacer].nil?
					distanceXBetweenRacerAndPreviousTarget = ((racer[:TargetingRacer][:RacerSprite].x + (racer[:TargetingRacer][:RacerSprite].width/2)) - (racer[:RacerSprite].x + (racer[:RacerSprite].width/2))).abs
					distanceYBetweenRacerAndPreviousTarget = ((racer[:TargetingRacer][:RacerSprite].y + (racer[:TargetingRacer][:RacerSprite].height/2)) - (racer[:RacerSprite].y + (racer[:RacerSprite].height/2))).abs
					combinedDistanceBetweenRacerAndPreviousTarget = distanceXBetweenRacerAndPreviousTarget + distanceYBetweenRacerAndPreviousTarget
				end
				if racer[:TargetingRacer].nil? || (combinedDistanceBetweenRacerAndPreviousTarget && combinedDistanceBetweenRacerAndTarget < combinedDistanceBetweenRacerAndPreviousTarget)
					#Console.echo_warn "distance between racer1 and previous target is #{combinedDistanceBetweenRacerAndPreviousTarget} and distance between racer1 and racer2 is #{combinedDistanceBetweenRacerAndTarget}"
					#Console.echo_warn "target is racer2"
					racer[:TargetingRacer] = opposingRacerB
					racer[:TargetingMoveEffect] = "spinOut"
				end
			end #if self.hasMoveEffect?(racer, "spinOut")
			if self.hasMoveEffect?(racer, "spinOut") != false && self.withinMaxSpinOutRangeX?(racer, opposingRacerC)
				#set a value on the racer hash that this racer is targeting another racer
				distanceXBetweenRacerAndTarget = ((opposingRacerC[:RacerSprite].x + (opposingRacerC[:RacerSprite].width/2)) - (racer[:RacerSprite].x + (racer[:RacerSprite].width/2))).abs
				distanceYBetweenRacerAndTarget = ((opposingRacerC[:RacerSprite].y + (opposingRacerC[:RacerSprite].height/2)) - (racer[:RacerSprite].y + (racer[:RacerSprite].height/2))).abs
				combinedDistanceBetweenRacerAndTarget = distanceXBetweenRacerAndTarget + distanceYBetweenRacerAndTarget
				#set the target if this target is closer than a target that is already set, or if there is no target already
				if !racer[:TargetingRacer].nil?
					distanceXBetweenRacerAndPreviousTarget = ((racer[:TargetingRacer][:RacerSprite].x + (racer[:TargetingRacer][:RacerSprite].width/2)) - (racer[:RacerSprite].x + (racer[:RacerSprite].width/2))).abs
					distanceYBetweenRacerAndPreviousTarget = ((racer[:TargetingRacer][:RacerSprite].y + (racer[:TargetingRacer][:RacerSprite].height/2)) - (racer[:RacerSprite].y + (racer[:RacerSprite].height/2))).abs
					combinedDistanceBetweenRacerAndPreviousTarget = distanceXBetweenRacerAndPreviousTarget + distanceYBetweenRacerAndPreviousTarget
				end
				if racer[:TargetingRacer].nil? || (combinedDistanceBetweenRacerAndPreviousTarget && combinedDistanceBetweenRacerAndTarget < combinedDistanceBetweenRacerAndPreviousTarget)
					#Console.echo_warn "distance between racer1 and previous target is #{combinedDistanceBetweenRacerAndPreviousTarget} and distance between racer1 and racer3 is #{combinedDistanceBetweenRacerAndTarget}"
					#Console.echo_warn "target is racer3"
					racer[:TargetingRacer] = opposingRacerC
					racer[:TargetingMoveEffect] = "spinOut"
				end
			end #if self.hasMoveEffect?(racer, "spinOut")
			
			#if no longer within X range of target, lose the target to find another
			#Console.echo_warn self.withinMaxSpinOutRangeX?(racer, racer[:TargetingRacer])
			if !racer[:TargetingRacer].nil? && !self.withinMaxSpinOutRangeX?(racer, racer[:TargetingRacer])
				#Console.echo_warn "target is no longer in range, so setting target to nil"
				racer[:TargetingRacer] = nil
				racer[:TargetingMoveEffect] = nil
			end
			
			if !racer[:TargetingRacer].nil?
				Console.echo_warn "racer1 stops wandering to target someone" if racer[:WanderStrafeDistance] > 0
				racer[:WanderingUp] = false
				racer[:WanderingDown] = false
				racer[:WanderStrafeDistance] = 0
			end
		end #if self.hasMoveEffectThatRequiresTargetAndMoveIsReady?(racer) && racer[:SpinOutTimer] <= 0
		
		###################################
		#============= Racer2 =============
		###################################
		racer = @racer2
		
		#Console.echo_warn self.hasMoveEffectThatRequiresTargetAndMoveIsReady?(racer)
		if self.hasMoveEffectThatRequiresTargetAndMoveIsReady?(racer) && racer[:SpinOutTimer] <= 0 && self.rngRollThrottled(CrustangRacingSettings::PERCENT_CHANCE_TO_TARGET_RACER)
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
				distanceXBetweenRacerAndTarget = ((opposingRacerA[:RacerSprite].x + (opposingRacerA[:RacerSprite].width/2)) - (racer[:RacerSprite].x + (racer[:RacerSprite].width/2))).abs
				distanceYBetweenRacerAndTarget = ((opposingRacerA[:RacerSprite].y + (opposingRacerA[:RacerSprite].height/2)) - (racer[:RacerSprite].y + (racer[:RacerSprite].height/2))).abs
				combinedDistanceBetweenRacerAndTarget = distanceXBetweenRacerAndTarget + distanceYBetweenRacerAndTarget
				#set the target if this target is closer than a target that is already set, or if there is no target already
				if !racer[:TargetingRacer].nil?
					distanceXBetweenRacerAndPreviousTarget = ((racer[:TargetingRacer][:RacerSprite].x + (racer[:TargetingRacer][:RacerSprite].width/2)) - (racer[:RacerSprite].x + (racer[:RacerSprite].width/2))).abs
					distanceYBetweenRacerAndPreviousTarget = ((racer[:TargetingRacer][:RacerSprite].y + (racer[:TargetingRacer][:RacerSprite].height/2)) - (racer[:RacerSprite].y + (racer[:RacerSprite].height/2))).abs
					combinedDistanceBetweenRacerAndPreviousTarget = distanceXBetweenRacerAndPreviousTarget + distanceYBetweenRacerAndPreviousTarget
				end
				if racer[:TargetingRacer].nil? || (combinedDistanceBetweenRacerAndPreviousTarget && combinedDistanceBetweenRacerAndTarget < combinedDistanceBetweenRacerAndPreviousTarget)
					#Console.echo_warn "distance between racer1 and player is #{combinedDistanceBetweenRacerAndTarget}"
					#Console.echo_warn "target is racerPlayer"
					racer[:TargetingRacer] = opposingRacerA
					racer[:TargetingMoveEffect] = "spinOut"
				end
			end #if self.hasMoveEffect?(racer, "spinOut")
			if self.hasMoveEffect?(racer, "spinOut") != false && self.withinMaxSpinOutRangeX?(racer, opposingRacerB)
				#set a value on the racer hash that this racer is targeting another racer
				distanceXBetweenRacerAndTarget = ((opposingRacerB[:RacerSprite].x + (opposingRacerB[:RacerSprite].width/2)) - (racer[:RacerSprite].x + (racer[:RacerSprite].width/2))).abs
				distanceYBetweenRacerAndTarget = ((opposingRacerB[:RacerSprite].y + (opposingRacerB[:RacerSprite].height/2)) - (racer[:RacerSprite].y + (racer[:RacerSprite].height/2))).abs
				combinedDistanceBetweenRacerAndTarget = distanceXBetweenRacerAndTarget + distanceYBetweenRacerAndTarget
				#set the target if this target is closer than a target that is already set, or if there is no target already
				if !racer[:TargetingRacer].nil?
					distanceXBetweenRacerAndPreviousTarget = ((racer[:TargetingRacer][:RacerSprite].x + (racer[:TargetingRacer][:RacerSprite].width/2)) - (racer[:RacerSprite].x + (racer[:RacerSprite].width/2))).abs
					distanceYBetweenRacerAndPreviousTarget = ((racer[:TargetingRacer][:RacerSprite].y + (racer[:TargetingRacer][:RacerSprite].height/2)) - (racer[:RacerSprite].y + (racer[:RacerSprite].height/2))).abs
					combinedDistanceBetweenRacerAndPreviousTarget = distanceXBetweenRacerAndPreviousTarget + distanceYBetweenRacerAndPreviousTarget
				end
				if racer[:TargetingRacer].nil? || (combinedDistanceBetweenRacerAndPreviousTarget && combinedDistanceBetweenRacerAndTarget < combinedDistanceBetweenRacerAndPreviousTarget)
					#Console.echo_warn "distance between racer1 and previous target is #{combinedDistanceBetweenRacerAndPreviousTarget} and distance between racer1 and racer2 is #{combinedDistanceBetweenRacerAndTarget}"
					#Console.echo_warn "target is racer2"
					racer[:TargetingRacer] = opposingRacerB
					racer[:TargetingMoveEffect] = "spinOut"
				end
			end #if self.hasMoveEffect?(racer, "spinOut")
			if self.hasMoveEffect?(racer, "spinOut") != false && self.withinMaxSpinOutRangeX?(racer, opposingRacerC)
				#set a value on the racer hash that this racer is targeting another racer
				distanceXBetweenRacerAndTarget = ((opposingRacerC[:RacerSprite].x + (opposingRacerC[:RacerSprite].width/2)) - (racer[:RacerSprite].x + (racer[:RacerSprite].width/2))).abs
				distanceYBetweenRacerAndTarget = ((opposingRacerC[:RacerSprite].y + (opposingRacerC[:RacerSprite].height/2)) - (racer[:RacerSprite].y + (racer[:RacerSprite].height/2))).abs
				combinedDistanceBetweenRacerAndTarget = distanceXBetweenRacerAndTarget + distanceYBetweenRacerAndTarget
				#set the target if this target is closer than a target that is already set, or if there is no target already
				if !racer[:TargetingRacer].nil?
					distanceXBetweenRacerAndPreviousTarget = ((racer[:TargetingRacer][:RacerSprite].x + (racer[:TargetingRacer][:RacerSprite].width/2)) - (racer[:RacerSprite].x + (racer[:RacerSprite].width/2))).abs
					distanceYBetweenRacerAndPreviousTarget = ((racer[:TargetingRacer][:RacerSprite].y + (racer[:TargetingRacer][:RacerSprite].height/2)) - (racer[:RacerSprite].y + (racer[:RacerSprite].height/2))).abs
					combinedDistanceBetweenRacerAndPreviousTarget = distanceXBetweenRacerAndPreviousTarget + distanceYBetweenRacerAndPreviousTarget
				end
				if racer[:TargetingRacer].nil? || (combinedDistanceBetweenRacerAndPreviousTarget && combinedDistanceBetweenRacerAndTarget < combinedDistanceBetweenRacerAndPreviousTarget)
					#Console.echo_warn "distance between racer1 and previous target is #{combinedDistanceBetweenRacerAndPreviousTarget} and distance between racer1 and racer3 is #{combinedDistanceBetweenRacerAndTarget}"
					#Console.echo_warn "target is racer3"
					racer[:TargetingRacer] = opposingRacerC
					racer[:TargetingMoveEffect] = "spinOut"
				end
			end #if self.hasMoveEffect?(racer, "spinOut")
			
			#if no longer within X range of target, lose the target to find another
			#Console.echo_warn self.withinMaxSpinOutRangeX?(racer, racer[:TargetingRacer])
			if !racer[:TargetingRacer].nil? && !self.withinMaxSpinOutRangeX?(racer, racer[:TargetingRacer])
				#Console.echo_warn "target is no longer in range, so setting target to nil"
				racer[:TargetingRacer] = nil
				racer[:TargetingMoveEffect] = nil
			end
			
			if !racer[:TargetingRacer].nil?
				Console.echo_warn "racer2 stops wandering to target someone" if racer[:WanderStrafeDistance] > 0
				racer[:WanderingUp] = false
				racer[:WanderingDown] = false
				racer[:WanderStrafeDistance] = 0
			end
		end #if self.hasMoveEffectThatRequiresTargetAndMoveIsReady?(racer) && racer[:SpinOutTimer] <= 0
		
		###################################
		#============= Racer3 =============
		###################################
		racer = @racer3
		
		#Console.echo_warn self.hasMoveEffectThatRequiresTargetAndMoveIsReady?(racer)
		if self.hasMoveEffectThatRequiresTargetAndMoveIsReady?(racer) && racer[:SpinOutTimer] <= 0 && self.rngRollThrottled(CrustangRacingSettings::PERCENT_CHANCE_TO_TARGET_RACER)
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
				distanceXBetweenRacerAndTarget = ((opposingRacerA[:RacerSprite].x + (opposingRacerA[:RacerSprite].width/2)) - (racer[:RacerSprite].x + (racer[:RacerSprite].width/2))).abs
				distanceYBetweenRacerAndTarget = ((opposingRacerA[:RacerSprite].y + (opposingRacerA[:RacerSprite].height/2)) - (racer[:RacerSprite].y + (racer[:RacerSprite].height/2))).abs
				combinedDistanceBetweenRacerAndTarget = distanceXBetweenRacerAndTarget + distanceYBetweenRacerAndTarget
				#set the target if this target is closer than a target that is already set, or if there is no target already
				if !racer[:TargetingRacer].nil?
					distanceXBetweenRacerAndPreviousTarget = ((racer[:TargetingRacer][:RacerSprite].x + (racer[:TargetingRacer][:RacerSprite].width/2)) - (racer[:RacerSprite].x + (racer[:RacerSprite].width/2))).abs
					distanceYBetweenRacerAndPreviousTarget = ((racer[:TargetingRacer][:RacerSprite].y + (racer[:TargetingRacer][:RacerSprite].height/2)) - (racer[:RacerSprite].y + (racer[:RacerSprite].height/2))).abs
					combinedDistanceBetweenRacerAndPreviousTarget = distanceXBetweenRacerAndPreviousTarget + distanceYBetweenRacerAndPreviousTarget
				end
				if racer[:TargetingRacer].nil? || (combinedDistanceBetweenRacerAndPreviousTarget && combinedDistanceBetweenRacerAndTarget < combinedDistanceBetweenRacerAndPreviousTarget)
					#Console.echo_warn "distance between racer1 and player is #{combinedDistanceBetweenRacerAndTarget}"
					#Console.echo_warn "target is racerPlayer"
					racer[:TargetingRacer] = opposingRacerA
					racer[:TargetingMoveEffect] = "spinOut"
				end
			end #if self.hasMoveEffect?(racer, "spinOut")
			if self.hasMoveEffect?(racer, "spinOut") != false && self.withinMaxSpinOutRangeX?(racer, opposingRacerB)
				#set a value on the racer hash that this racer is targeting another racer
				distanceXBetweenRacerAndTarget = ((opposingRacerB[:RacerSprite].x + (opposingRacerB[:RacerSprite].width/2)) - (racer[:RacerSprite].x + (racer[:RacerSprite].width/2))).abs
				distanceYBetweenRacerAndTarget = ((opposingRacerB[:RacerSprite].y + (opposingRacerB[:RacerSprite].height/2)) - (racer[:RacerSprite].y + (racer[:RacerSprite].height/2))).abs
				combinedDistanceBetweenRacerAndTarget = distanceXBetweenRacerAndTarget + distanceYBetweenRacerAndTarget
				#set the target if this target is closer than a target that is already set, or if there is no target already
				if !racer[:TargetingRacer].nil?
					distanceXBetweenRacerAndPreviousTarget = ((racer[:TargetingRacer][:RacerSprite].x + (racer[:TargetingRacer][:RacerSprite].width/2)) - (racer[:RacerSprite].x + (racer[:RacerSprite].width/2))).abs
					distanceYBetweenRacerAndPreviousTarget = ((racer[:TargetingRacer][:RacerSprite].y + (racer[:TargetingRacer][:RacerSprite].height/2)) - (racer[:RacerSprite].y + (racer[:RacerSprite].height/2))).abs
					combinedDistanceBetweenRacerAndPreviousTarget = distanceXBetweenRacerAndPreviousTarget + distanceYBetweenRacerAndPreviousTarget
				end
				if racer[:TargetingRacer].nil? || (combinedDistanceBetweenRacerAndPreviousTarget && combinedDistanceBetweenRacerAndTarget < combinedDistanceBetweenRacerAndPreviousTarget)
					#Console.echo_warn "distance between racer1 and previous target is #{combinedDistanceBetweenRacerAndPreviousTarget} and distance between racer1 and racer2 is #{combinedDistanceBetweenRacerAndTarget}"
					#Console.echo_warn "target is racer2"
					racer[:TargetingRacer] = opposingRacerB
					racer[:TargetingMoveEffect] = "spinOut"
				end
			end #if self.hasMoveEffect?(racer, "spinOut")
			if self.hasMoveEffect?(racer, "spinOut") != false && self.withinMaxSpinOutRangeX?(racer, opposingRacerC)
				#set a value on the racer hash that this racer is targeting another racer
				distanceXBetweenRacerAndTarget = ((opposingRacerC[:RacerSprite].x + (opposingRacerC[:RacerSprite].width/2)) - (racer[:RacerSprite].x + (racer[:RacerSprite].width/2))).abs
				distanceYBetweenRacerAndTarget = ((opposingRacerC[:RacerSprite].y + (opposingRacerC[:RacerSprite].height/2)) - (racer[:RacerSprite].y + (racer[:RacerSprite].height/2))).abs
				combinedDistanceBetweenRacerAndTarget = distanceXBetweenRacerAndTarget + distanceYBetweenRacerAndTarget
				#set the target if this target is closer than a target that is already set, or if there is no target already
				if !racer[:TargetingRacer].nil?
					distanceXBetweenRacerAndPreviousTarget = ((racer[:TargetingRacer][:RacerSprite].x + (racer[:TargetingRacer][:RacerSprite].width/2)) - (racer[:RacerSprite].x + (racer[:RacerSprite].width/2))).abs
					distanceYBetweenRacerAndPreviousTarget = ((racer[:TargetingRacer][:RacerSprite].y + (racer[:TargetingRacer][:RacerSprite].height/2)) - (racer[:RacerSprite].y + (racer[:RacerSprite].height/2))).abs
					combinedDistanceBetweenRacerAndPreviousTarget = distanceXBetweenRacerAndPreviousTarget + distanceYBetweenRacerAndPreviousTarget
				end
				if racer[:TargetingRacer].nil? || (combinedDistanceBetweenRacerAndPreviousTarget && combinedDistanceBetweenRacerAndTarget < combinedDistanceBetweenRacerAndPreviousTarget)
					#Console.echo_warn "distance between racer1 and previous target is #{combinedDistanceBetweenRacerAndPreviousTarget} and distance between racer1 and racer3 is #{combinedDistanceBetweenRacerAndTarget}"
					#Console.echo_warn "target is racer3"
					racer[:TargetingRacer] = opposingRacerC
					racer[:TargetingMoveEffect] = "spinOut"
				end
			end #if self.hasMoveEffect?(racer, "spinOut")
			
			#if no longer within X range of target, lose the target to find another
			#Console.echo_warn self.withinMaxSpinOutRangeX?(racer, racer[:TargetingRacer])
			if !racer[:TargetingRacer].nil? && !self.withinMaxSpinOutRangeX?(racer, racer[:TargetingRacer])
				#Console.echo_warn "target is no longer in range, so setting target to nil"
				racer[:TargetingRacer] = nil
				racer[:TargetingMoveEffect] = nil
			end
			
			if !racer[:TargetingRacer].nil?
				Console.echo_warn "racer3 stops wandering to target someone" if racer[:WanderStrafeDistance] > 0
				racer[:WanderingUp] = false
				racer[:WanderingDown] = false
				racer[:WanderStrafeDistance] = 0
			end
		end #if self.hasMoveEffectThatRequiresTargetAndMoveIsReady?(racer) && racer[:SpinOutTimer] <= 0
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
				end #if racer[:RacerSprite].y < racer[:TargetingRacer][:RacerSprite].y
			end #if !self.withinSpecifiedRangeY?(racer, racer[:TargetingRacer], minimumDistanceToTarget)
		end #if !racer[:TargetingRacer].nil?
		
		###################################
		#============= Racer2 =============
		###################################
		racer = @racer2
		
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
				end #if racer[:RacerSprite].y < racer[:TargetingRacer][:RacerSprite].y
			end #if !self.withinSpecifiedRangeY?(racer, racer[:TargetingRacer], minimumDistanceToTarget)
		end #if !racer[:TargetingRacer].nil?
		
		###################################
		#============= Racer3 =============
		###################################
		racer = @racer3
		
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
				end #if racer[:RacerSprite].y < racer[:TargetingRacer][:RacerSprite].y
			end #if !self.withinSpecifiedRangeY?(racer, racer[:TargetingRacer], minimumDistanceToTarget)
		end #if !racer[:TargetingRacer].nil?
	end #def self.aiStrafeTowardTarget

	def self.aiLookForOpportunityToUseRockHazard
		###################################
		#============= Racer1 =============
		###################################
		racer = @racer1
		
		if self.hasMoveEffect?(racer, "rockHazard") != false && racer[:SpinOutTimer] <= 0 && racer[:RockHazard][:Sprite].nil? && self.rngRollThrottled(CrustangRacingSettings::PERCENT_CHANCE_TO_USE_ROCKHAZARD) #cannot use rock hazard unless not spinning out and has specific move and doesn't have a rock out already
				moveNumber = self.hasMoveEffect?(racer, "rockHazard")
				
				case moveNumber
				when 1
					timer = racer[:Move1CooldownTimer]
				when 2
					timer = racer[:Move2CooldownTimer]
				when 3
					timer = racer[:Move3CooldownTimer]
				when 4
					timer = racer[:Move4CooldownTimer]
				end
				
				self.moveEffect(racer, moveNumber) if timer <= 0
				self.beginCooldown(racer, moveNumber) if timer <= 0
		end #if racer[:SpinOutTimer] <= 0
		
		###################################
		#============= Racer2 =============
		###################################
		racer = @racer2
		
		if self.hasMoveEffect?(racer, "rockHazard") != false && racer[:SpinOutTimer] <= 0 && racer[:RockHazard][:Sprite].nil? && self.rngRollThrottled(CrustangRacingSettings::PERCENT_CHANCE_TO_USE_ROCKHAZARD)
				moveNumber = self.hasMoveEffect?(racer, "rockHazard")
				
				case moveNumber
				when 1
					timer = racer[:Move1CooldownTimer]
				when 2
					timer = racer[:Move2CooldownTimer]
				when 3
					timer = racer[:Move3CooldownTimer]
				when 4
					timer = racer[:Move4CooldownTimer]
				end
				
				self.moveEffect(racer, moveNumber) if timer <= 0
				self.beginCooldown(racer, moveNumber) if timer <= 0
		end #if racer[:SpinOutTimer] <= 0
		
		###################################
		#============= Racer3 =============
		###################################
		racer = @racer3
		
		if self.hasMoveEffect?(racer, "rockHazard") != false && racer[:SpinOutTimer] <= 0 && racer[:RockHazard][:Sprite].nil? && self.rngRollThrottled(CrustangRacingSettings::PERCENT_CHANCE_TO_USE_ROCKHAZARD)
				moveNumber = self.hasMoveEffect?(racer, "rockHazard")
				
				case moveNumber
				when 1
					timer = racer[:Move1CooldownTimer]
				when 2
					timer = racer[:Move2CooldownTimer]
				when 3
					timer = racer[:Move3CooldownTimer]
				when 4
					timer = racer[:Move4CooldownTimer]
				end
				
				self.moveEffect(racer, moveNumber) if timer <= 0
				self.beginCooldown(racer, moveNumber) if timer <= 0
		end #if racer[:SpinOutTimer] <= 0
	end #def self.aiLookForOpportunityToUseRockHazard
	
	def self.aiLookForOpportunityToUseMudHazard
		###################################
		#============= Racer1 =============
		###################################
		racer = @racer1
		
		if self.hasMoveEffect?(racer, "mudHazard") != false && racer[:SpinOutTimer] <= 0 && racer[:MudHazard][:Sprite].nil? && self.rngRollThrottled(CrustangRacingSettings::PERCENT_CHANCE_TO_USE_MUDHAZARD) #cannot use mud hazard unless not spinning out and has specific move and doesn't have a mud pit out already
				moveNumber = self.hasMoveEffect?(racer, "mudHazard")
				
				case moveNumber
				when 1
					timer = racer[:Move1CooldownTimer]
				when 2
					timer = racer[:Move2CooldownTimer]
				when 3
					timer = racer[:Move3CooldownTimer]
				when 4
					timer = racer[:Move4CooldownTimer]
				end
				
				self.moveEffect(racer, moveNumber) if timer <= 0
				self.beginCooldown(racer, moveNumber) if timer <= 0
		end #if racer[:SpinOutTimer] <= 0
		
		###################################
		#============= Racer2 =============
		###################################
		racer = @racer2
		
		if self.hasMoveEffect?(racer, "mudHazard") != false && racer[:SpinOutTimer] <= 0 && racer[:MudHazard][:Sprite].nil? && self.rngRollThrottled(CrustangRacingSettings::PERCENT_CHANCE_TO_USE_MUDHAZARD)
				moveNumber = self.hasMoveEffect?(racer, "mudHazard")
				
				case moveNumber
				when 1
					timer = racer[:Move1CooldownTimer]
				when 2
					timer = racer[:Move2CooldownTimer]
				when 3
					timer = racer[:Move3CooldownTimer]
				when 4
					timer = racer[:Move4CooldownTimer]
				end
				
				self.moveEffect(racer, moveNumber) if timer <= 0
				self.beginCooldown(racer, moveNumber) if timer <= 0
		end #if racer[:SpinOutTimer] <= 0
		
		###################################
		#============= Racer3 =============
		###################################
		racer = @racer3
		
		if self.hasMoveEffect?(racer, "mudHazard") != false && racer[:SpinOutTimer] <= 0 && racer[:MudHazard][:Sprite].nil? && self.rngRollThrottled(CrustangRacingSettings::PERCENT_CHANCE_TO_USE_MUDHAZARD)
				moveNumber = self.hasMoveEffect?(racer, "mudHazard")
				
				case moveNumber
				when 1
					timer = racer[:Move1CooldownTimer]
				when 2
					timer = racer[:Move2CooldownTimer]
				when 3
					timer = racer[:Move3CooldownTimer]
				when 4
					timer = racer[:Move4CooldownTimer]
				end
				
				self.moveEffect(racer, moveNumber) if timer <= 0
				self.beginCooldown(racer, moveNumber) if timer <= 0
		end #if racer[:SpinOutTimer] <= 0
	end #def self.aiLookForOpportunityToUseRockHazard
	
	def self.aiLookForOpportunityToUseReduceCooldown
		###################################
		#============= Racer1 =============
		###################################
		racer = @racer1
		
		if self.hasMoveEffect?(racer, "reduceCooldown") != false && racer[:SpinOutTimer] <= 0 && racer[:ReduceCooldownCount] <= 0 && self.reduceCooldownMoveIsReady?(racer) && self.rngRollThrottled(CrustangRacingSettings::PERCENT_CHANCE_TO_USE_REDUCECOOLDOWN) #cannot use reduce cooldown unless not spinning out and has specific move
				moveNumber = self.hasMoveEffect?(racer, "reduceCooldown")
				
				case moveNumber
				when 1
					timer = racer[:Move1CooldownTimer]
				when 2
					timer = racer[:Move2CooldownTimer]
				when 3
					timer = racer[:Move3CooldownTimer]
				when 4
					timer = racer[:Move4CooldownTimer]
				end
				
				self.moveEffect(racer, moveNumber) if timer <= 0
				self.beginCooldown(racer, moveNumber) if timer <= 0
				#Console.echo_warn "Racer1 just used reduceCooldown"
		end #if racer[:SpinOutTimer] <= 0
		
		###################################
		#============= Racer2 =============
		###################################
		racer = @racer2
		
		if self.hasMoveEffect?(racer, "reduceCooldown") != false && racer[:SpinOutTimer] <= 0 && racer[:ReduceCooldownCount] <= 0 && self.reduceCooldownMoveIsReady?(racer) && self.rngRollThrottled(CrustangRacingSettings::PERCENT_CHANCE_TO_USE_REDUCECOOLDOWN) #cannot use reduce cooldown unless not spinning out and has specific move
				moveNumber = self.hasMoveEffect?(racer, "reduceCooldown")
				
				case moveNumber
				when 1
					timer = racer[:Move1CooldownTimer]
				when 2
					timer = racer[:Move2CooldownTimer]
				when 3
					timer = racer[:Move3CooldownTimer]
				when 4
					timer = racer[:Move4CooldownTimer]
				end
				
				self.moveEffect(racer, moveNumber) if timer <= 0
				self.beginCooldown(racer, moveNumber) if timer <= 0
				#Console.echo_warn "Racer2 just used reduceCooldown"
		end #if racer[:SpinOutTimer] <= 0
		
		###################################
		#============= Racer3 =============
		###################################
		racer = @racer3
		
		if self.hasMoveEffect?(racer, "reduceCooldown") != false && racer[:SpinOutTimer] <= 0 && racer[:ReduceCooldownCount] <= 0 && self.reduceCooldownMoveIsReady?(racer) && self.rngRollThrottled(CrustangRacingSettings::PERCENT_CHANCE_TO_USE_REDUCECOOLDOWN) #cannot use reduce cooldown unless not spinning out and has specific move
				moveNumber = self.hasMoveEffect?(racer, "reduceCooldown")
				
				case moveNumber
				when 1
					timer = racer[:Move1CooldownTimer]
				when 2
					timer = racer[:Move2CooldownTimer]
				when 3
					timer = racer[:Move3CooldownTimer]
				when 4
					timer = racer[:Move4CooldownTimer]
				end
				
				self.moveEffect(racer, moveNumber) if timer <= 0
				self.beginCooldown(racer, moveNumber) if timer <= 0
				#Console.echo_warn "Racer3 just used reduceCooldown"
		end #if racer[:SpinOutTimer] <= 0
	end #def self.aiLookForOpportunityToUseReduceCooldown
	
	def self.aiLookForOpportunityToUseSecondBoost
		###################################
		#============= Racer1 =============
		###################################
		racer = @racer1
		
		if self.hasMoveEffect?(racer, "secondBoost") != false && racer[:SpinOutTimer] <= 0 && self.secondBoostMoveIsReady?(racer) && racer[:CurrentSpeed] < CrustangRacingSettings::SECONDARY_BOOST_SPEED && self.rngRollThrottled(CrustangRacingSettings::PERCENT_CHANCE_TO_USE_SECONDBOOST) #cannot use second boost unless not spinning out and has specific move and speed from secondBoost is higher than currentSpeed
				moveNumber = self.hasMoveEffect?(racer, "secondBoost")
				
				case moveNumber
				when 1
					timer = racer[:Move1CooldownTimer]
				when 2
					timer = racer[:Move2CooldownTimer]
				when 3
					timer = racer[:Move3CooldownTimer]
				when 4
					timer = racer[:Move4CooldownTimer]
				end
				
				self.moveEffect(racer, moveNumber) if timer <= 0
				self.beginCooldown(racer, moveNumber) if timer <= 0
		end #if racer[:SpinOutTimer] <= 0
		
		###################################
		#============= Racer2 =============
		###################################
		racer = @racer2
		
		if self.hasMoveEffect?(racer, "secondBoost") != false && racer[:SpinOutTimer] <= 0 && self.secondBoostMoveIsReady?(racer) && racer[:CurrentSpeed] < CrustangRacingSettings::SECONDARY_BOOST_SPEED && self.rngRollThrottled(CrustangRacingSettings::PERCENT_CHANCE_TO_USE_SECONDBOOST) #cannot use second boost unless not spinning out and has specific move and speed from secondBoost is higher than currentSpeed
				moveNumber = self.hasMoveEffect?(racer, "secondBoost")
				
				case moveNumber
				when 1
					timer = racer[:Move1CooldownTimer]
				when 2
					timer = racer[:Move2CooldownTimer]
				when 3
					timer = racer[:Move3CooldownTimer]
				when 4
					timer = racer[:Move4CooldownTimer]
				end
				
				self.moveEffect(racer, moveNumber) if timer <= 0
				#Console.echo_warn "racer2 - secondBoost"
				self.beginCooldown(racer, moveNumber) if timer <= 0
		end #if racer[:SpinOutTimer] <= 0
		
		###################################
		#============= Racer3 =============
		###################################
		racer = @racer3
		
		if self.hasMoveEffect?(racer, "secondBoost") != false && racer[:SpinOutTimer] <= 0 && self.secondBoostMoveIsReady?(racer) && racer[:CurrentSpeed] < CrustangRacingSettings::SECONDARY_BOOST_SPEED && self.rngRollThrottled(CrustangRacingSettings::PERCENT_CHANCE_TO_USE_SECONDBOOST) #cannot use second boost unless not spinning out and has specific move and speed from secondBoost is higher than currentSpeed
				moveNumber = self.hasMoveEffect?(racer, "secondBoost")
				
				case moveNumber
				when 1
					timer = racer[:Move1CooldownTimer]
				when 2
					timer = racer[:Move2CooldownTimer]
				when 3
					timer = racer[:Move3CooldownTimer]
				when 4
					timer = racer[:Move4CooldownTimer]
				end
				
				self.moveEffect(racer, moveNumber) if timer <= 0
				self.beginCooldown(racer, moveNumber) if timer <= 0
		end #if racer[:SpinOutTimer] <= 0
	end #def self.aiLookForOpportunityToUseSecondBoost

	def self.aiLookForOpportunityToUseInvincibility
		###################################
		#============= Racer1 =============
		###################################
		racer = @racer1
		
		if self.hasMoveEffect?(racer, "invincible") != false && racer[:SpinOutTimer] <= 0 && racer[:InvincibilityTimer] <= 0 && self.invincibilityMoveIsReady?(racer) && self.rngRollThrottled(CrustangRacingSettings::PERCENT_CHANCE_TO_USE_INVINCIBLE)
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
			
			if !opposingRacerA[:RockHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRangePlusGrace?(racer, opposingRacerA[:RockHazard], 64)
				hazardToAvoid = opposingRacerA[:RockHazard]
			end
			if !opposingRacerA[:MudHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRangePlusGrace?(racer, opposingRacerA[:MudHazard], 64)
				hazardToAvoid = opposingRacerA[:MudHazard] if hazardToAvoid.nil? || opposingRacerA[:MudHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] || hazardToAvoid.nil? #overwrite as the current hazard to avoid if closer than other hazard
			end
			if !opposingRacerB[:RockHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRangePlusGrace?(racer, opposingRacerB[:RockHazard], 64)
				hazardToAvoid = opposingRacerB[:RockHazard] if hazardToAvoid.nil? || opposingRacerB[:RockHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] #overwrite as the current hazard to avoid if closer than other hazard
			end
			if !opposingRacerB[:MudHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRangePlusGrace?(racer, opposingRacerB[:MudHazard], 64)
				hazardToAvoid = opposingRacerB[:MudHazard] if hazardToAvoid.nil? || opposingRacerB[:MudHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] #overwrite as the current hazard to avoid if closer than other hazard
			end
			if !opposingRacerC[:RockHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRangePlusGrace?(racer, opposingRacerC[:RockHazard], 64)
				hazardToAvoid = opposingRacerC[:RockHazard] if hazardToAvoid.nil? || opposingRacerC[:RockHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] #overwrite as the current hazard to avoid if closer than other hazard
			end
			if !opposingRacerC[:MudHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRangePlusGrace?(racer, opposingRacerC[:MudHazard], 64)
				hazardToAvoid = opposingRacerC[:MudHazard] if hazardToAvoid.nil? || opposingRacerC[:MudHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] #overwrite as the current hazard to avoid if closer than other hazard
			end
		
			#should the racer strafe up or down to avoid the upcoming hazard?
			if !hazardToAvoid.nil?
				#use invincibility
				moveNumber = self.hasMoveEffect?(racer, "invincible")
				
				case moveNumber
				when 1
					timer = racer[:Move1CooldownTimer]
				when 2
					timer = racer[:Move2CooldownTimer]
				when 3
					timer = racer[:Move3CooldownTimer]
				when 4
					timer = racer[:Move4CooldownTimer]
				end
				
				self.moveEffect(racer, moveNumber) if timer <= 0
				self.beginCooldown(racer, moveNumber) if timer <= 0
			end #if !hazardToAvoid.nil?
		end #if racer[:SpinOutTimer] <= 0
		
		###################################
		#============= Racer2 =============
		###################################
		racer = @racer2
		
		if self.hasMoveEffect?(racer, "invincible") != false && racer[:SpinOutTimer] <= 0 && racer[:InvincibilityTimer] <= 0 && self.invincibilityMoveIsReady?(racer) && self.rngRollThrottled(CrustangRacingSettings::PERCENT_CHANCE_TO_USE_INVINCIBLE)
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
			
			if !opposingRacerA[:RockHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRangePlusGrace?(racer, opposingRacerA[:RockHazard], 64)
				hazardToAvoid = opposingRacerA[:RockHazard]
			end
			if !opposingRacerA[:MudHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRangePlusGrace?(racer, opposingRacerA[:MudHazard], 64)
				hazardToAvoid = opposingRacerA[:MudHazard] if hazardToAvoid.nil? || opposingRacerA[:MudHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] || hazardToAvoid.nil? #overwrite as the current hazard to avoid if closer than other hazard
			end
			if !opposingRacerB[:RockHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRangePlusGrace?(racer, opposingRacerB[:RockHazard], 64)
				hazardToAvoid = opposingRacerB[:RockHazard] if hazardToAvoid.nil? || opposingRacerB[:RockHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] #overwrite as the current hazard to avoid if closer than other hazard
			end
			if !opposingRacerB[:MudHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRangePlusGrace?(racer, opposingRacerB[:MudHazard], 64)
				hazardToAvoid = opposingRacerB[:MudHazard] if hazardToAvoid.nil? || opposingRacerB[:MudHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] #overwrite as the current hazard to avoid if closer than other hazard
			end
			if !opposingRacerC[:RockHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRangePlusGrace?(racer, opposingRacerC[:RockHazard], 64)
				hazardToAvoid = opposingRacerC[:RockHazard] if hazardToAvoid.nil? || opposingRacerC[:RockHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] #overwrite as the current hazard to avoid if closer than other hazard
			end
			if !opposingRacerC[:MudHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRangePlusGrace?(racer, opposingRacerC[:MudHazard], 64)
				hazardToAvoid = opposingRacerC[:MudHazard] if hazardToAvoid.nil? || opposingRacerC[:MudHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] #overwrite as the current hazard to avoid if closer than other hazard
			end
		
			#should the racer strafe up or down to avoid the upcoming hazard?
			if !hazardToAvoid.nil?
				#use invincibility
				moveNumber = self.hasMoveEffect?(racer, "invincible")
				
				case moveNumber
				when 1
					timer = racer[:Move1CooldownTimer]
				when 2
					timer = racer[:Move2CooldownTimer]
				when 3
					timer = racer[:Move3CooldownTimer]
				when 4
					timer = racer[:Move4CooldownTimer]
				end
				
				self.moveEffect(racer, moveNumber) if timer <= 0
				self.beginCooldown(racer, moveNumber) if timer <= 0
			end #if !hazardToAvoid.nil?
		end #if racer[:SpinOutTimer] <= 0
		
		###################################
		#============= Racer3 =============
		###################################
		racer = @racer3
		
		if self.hasMoveEffect?(racer, "invincible") != false && racer[:SpinOutTimer] <= 0 && racer[:InvincibilityTimer] <= 0 && self.invincibilityMoveIsReady?(racer) && self.rngRollThrottled(CrustangRacingSettings::PERCENT_CHANCE_TO_USE_INVINCIBLE)
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
			
			if !opposingRacerA[:RockHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRangePlusGrace?(racer, opposingRacerA[:RockHazard], 64)
				hazardToAvoid = opposingRacerA[:RockHazard]
			end
			if !opposingRacerA[:MudHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRangePlusGrace?(racer, opposingRacerA[:MudHazard], 64)
				hazardToAvoid = opposingRacerA[:MudHazard] if hazardToAvoid.nil? || opposingRacerA[:MudHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] || hazardToAvoid.nil? #overwrite as the current hazard to avoid if closer than other hazard
			end
			if !opposingRacerB[:RockHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRangePlusGrace?(racer, opposingRacerB[:RockHazard], 64)
				hazardToAvoid = opposingRacerB[:RockHazard] if hazardToAvoid.nil? || opposingRacerB[:RockHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] #overwrite as the current hazard to avoid if closer than other hazard
			end
			if !opposingRacerB[:MudHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRangePlusGrace?(racer, opposingRacerB[:MudHazard], 64)
				hazardToAvoid = opposingRacerB[:MudHazard] if hazardToAvoid.nil? || opposingRacerB[:MudHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] #overwrite as the current hazard to avoid if closer than other hazard
			end
			if !opposingRacerC[:RockHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRangePlusGrace?(racer, opposingRacerC[:RockHazard], 64)
				hazardToAvoid = opposingRacerC[:RockHazard] if hazardToAvoid.nil? || opposingRacerC[:RockHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] #overwrite as the current hazard to avoid if closer than other hazard
			end
			if !opposingRacerC[:MudHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRangePlusGrace?(racer, opposingRacerC[:MudHazard], 64)
				hazardToAvoid = opposingRacerC[:MudHazard] if hazardToAvoid.nil? || opposingRacerC[:MudHazard][:PositionXOnTrack] < hazardToAvoid[:PositionXOnTrack] #overwrite as the current hazard to avoid if closer than other hazard
			end
		
			#should the racer strafe up or down to avoid the upcoming hazard?
			if !hazardToAvoid.nil?
				#use invincibility
				moveNumber = self.hasMoveEffect?(racer, "invincible")
				
				case moveNumber
				when 1
					timer = racer[:Move1CooldownTimer]
				when 2
					timer = racer[:Move2CooldownTimer]
				when 3
					timer = racer[:Move3CooldownTimer]
				when 4
					timer = racer[:Move4CooldownTimer]
				end
				
				self.moveEffect(racer, moveNumber) if timer <= 0
				self.beginCooldown(racer, moveNumber) if timer <= 0
			end #if !hazardToAvoid.nil?
		end #if racer[:SpinOutTimer] <= 0
	end #def self.aiLookForOpportunityToUseInvincibility

end #class CrustangRacing