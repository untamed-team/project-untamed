class CrustangRacing
	def self.collides_with?(racer,object)
	collisionGrace = 1
		#if (object.x + object.width-object.width >= racer.x) && (object.x <= racer.x + racer.width) && (object.y + object.height >= racer.y) && (object.y <= racer.y + racer.height)
		if object.x.between?(racer.x - object.width + collisionGrace, racer.x + racer.width + collisionGrace) && object.y.between?(racer.y - object.height + collisionGrace, racer.y + racer.height - collisionGrace)
			return true
		end
	end
	
	#colliding with something in a direction
	def self.collides_with_object_above?(racer,object)
		#is the racer colliding with something above them?
		return true if object.y < racer.y && racer.y.between?(object.y, object.y + object.height) && (racer.x.between?(object.x, object.x + object.width) || object.x.between?(racer.x, racer.x + racer.width))
	end
	
	def self.collides_with_object_below?(racer,object)
		#is the racer colliding with something below them?
		return true if object.y > racer.y && object.y.between?(racer.y, racer.y + racer.height) && (object.x.between?(racer.x, racer.x + racer.width) || racer.x.between?(object.x, object.x + object.width))
	end
	
	def self.collides_with_object_behind?(racer,object)
		#is the racer colliding with something behind them?
		return true if object.x < racer.x && racer.x.between?(object.x, object.x + object.width) && (racer.y.between?(object.y, object.y + object.height-object.height/4) || object.y.between?(racer.y, racer.y + racer.height-racer.height/4))
	end
	
	def self.collides_with_object_in_front?(racer,object)
		#is the racer colliding with something in front of them?
		return true if object.x > racer.x && object.x.between?(racer.x, racer.x + racer.width) && (object.y.between?(racer.y, racer.y + racer.height-racer.height/4) || racer.y.between?(object.y, object.y + object.height-object.height/4))
	end
	
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
	
	def self.withinMaxSpinOutRangeX?(attacker, recipient)
		#used to check if someone is within max range of the attacker so the attacker knows they should start charging and strafe towards recipient
		withinRangeX = false
		
		###################################
		#========== WithinRangeX ==========
		###################################
		###### Checking next to attacker (same exact X)
		withinRangeX = true if attacker[:PositionOnTrack] == recipient[:PositionOnTrack]
		charge = CrustangRacingSettings::SPINOUT_MAX_RANGE
		
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

		return true if withinRangeX

		return false
	end #def self.withinSpinOutRange?
	
	def self.withinMaxSpinOutRangeY?(attacker, recipient)
		withinRangeY = false
		charge = CrustangRacingSettings::SPINOUT_MAX_RANGE
		
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

		return true if withinRangeY

		return false
	end #def self.withinSpinOutRange?
	
	def self.withinSpecifiedRangeY?(attacker, recipient, range)
		withinRangeY = false
		charge = range
		
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

		return true if withinRangeY

		return false
	end #def self.withinSpinOutRange?
	
	def self.withinOverloadRange?(attacker, recipient)
		withinRangeX = false
		withinRangeY = false
		
		###################################
		#========== WithinRangeX ==========
		###################################
		###### Checking next to attacker (same exact X)
		withinRangeX = true if attacker[:PositionOnTrack] == recipient[:PositionOnTrack]
		charge = attacker[:OverloadCharge]
		
		###### Checking behind attacker
		overloadRangeX = charge/2 + recipient[:RacerSprite].width/2
		
		if attacker[:PositionOnTrack] < overloadRangeX
			#there will be some overlap between the end of the track and the beginning of the track
			positionOnTrackBehindAttacker = []
			positionOnTrackBehindAttacker.push([0, attacker[:PositionOnTrack]])
			amountHittingEndOfTrack = overloadRangeX - attacker[:PositionOnTrack]
			positionOnTrackBehindAttacker.push([@sprites["track1"].width - amountHittingEndOfTrack, @sprites["track1"].width])
			#the above will result in something like this:
			#positionOnTrackBehindAttacker is an array with these elements: [[0, 106], [6100, 6144]]
			#so if the recipient is between positionOnTrackBehindAttacker[0][0] and positionOnTrackBehindAttacker[0][1]
			#or between positionOnTrackBehindAttacker[1][0] and positionOnTrackBehindAttacker[1][1], they are within range
		else
			positionOnTrackBehindAttacker = attacker[:PositionOnTrack] - overloadRangeX
		end
		
		#if positionOnTrackBehindAttacker is an array or not
		if positionOnTrackBehindAttacker.kind_of?(Array)
			withinRangeX = true if recipient[:PositionOnTrack].between?(positionOnTrackBehindAttacker[0][0], positionOnTrackBehindAttacker[0][1]) || recipient[:PositionOnTrack].between?(positionOnTrackBehindAttacker[1][0], positionOnTrackBehindAttacker[1][1])
		else
			withinRangeX = true if recipient[:PositionOnTrack].between?(positionOnTrackBehindAttacker, attacker[:PositionOnTrack])
		end
		
		###### Checking in front of attacker
		overloadRangeX = charge/2 + recipient[:RacerSprite].width/2
		
		if attacker[:PositionOnTrack] > @sprites["track1"].width - overloadRangeX
			#there will be some overlap between the end of the track and the beginning of the track
			positionOnTrackInFrontOfAttacker = []
			positionOnTrackInFrontOfAttacker.push([attacker[:PositionOnTrack], @sprites["track1"].width])
			amountHittingBeginningOfTrack = overloadRangeX - (@sprites["track1"].width - attacker[:PositionOnTrack])
			positionOnTrackInFrontOfAttacker.push([0, amountHittingBeginningOfTrack])
			#the above array will look something like this:
			#positionOnTrackInFrontOfAttacker is an array with these elements: [[6100, 6144], [0, 106]]
		else
			positionOnTrackInFrontOfAttacker = attacker[:PositionOnTrack] + overloadRangeX
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
		overloadRangeY = charge/2 - attacker[:RacerSprite].height/2
		
		withinRangeAbove = true if recipient[:RacerSprite].y.between?(attacker[:RacerSprite].y - recipient[:RacerSprite].height - overloadRangeY + 1, attacker[:RacerSprite].y)
		
		#checking above attacker
		withinRangeBelow = true if recipient[:RacerSprite].y.between?(attacker[:RacerSprite].y, attacker[:RacerSprite].y+attacker[:RacerSprite].height + overloadRangeY - 1)
		
		withinRangeY = true if withinRangeAbove || withinRangeBelow

		return true if withinRangeX && withinRangeY

		#print "recipient[:PositionOnTrack] is #{recipient[:PositionOnTrack]} and positionOnTrackBehindAttacker is #{positionOnTrackBehindAttacker}"
		#if all checks have been made and the recipient is not within range of any of them, return false
		return false
	end #def self.withinOverloadRange?
	
	def self.checkForLap
		#Lapping: true, LapCount: 0, CurrentPlacement: 1,
		###################################
		#============= Racer1 =============
		###################################
		@racer1[:LapCount] += 1 if @racer1[:PreviousPositionOnTrack] > @racer1[:PositionOnTrack]
		
		###################################
		#============= Racer2 =============
		###################################
		@racer2[:LapCount] += 1 if @racer2[:PreviousPositionOnTrack] > @racer2[:PositionOnTrack]
		
		###################################
		#============= Racer3 =============
		###################################
		@racer3[:LapCount] += 1 if @racer3[:PreviousPositionOnTrack] > @racer3[:PositionOnTrack]
		
		###################################
		#============= Player =============
		###################################
		@racerPlayer[:LapCount] += 1 if @racerPlayer[:PreviousPositionOnTrack] > @racerPlayer[:PositionOnTrack]
		
	end #def self.checkForLap

	def self.updateRacerPlacement
		@racer1[:LapAndPlacement] = (@racer1[:LapCount] * 1000000) + @racer1[:PositionOnTrack]
		@racer2[:LapAndPlacement] = (@racer2[:LapCount] * 1000000) + @racer2[:PositionOnTrack]
		@racer3[:LapAndPlacement] = (@racer3[:LapCount] * 1000000) + @racer3[:PositionOnTrack]
		@racerPlayer[:LapAndPlacement] = (@racerPlayer[:LapCount] * 1000000) + @racerPlayer[:PositionOnTrack]
		
		racersArray = [@racer1, @racer2, @racer3, @racerPlayer]
		racersSorted = racersArray.sort_by { |hsh| hsh[:LapAndPlacement] }.reverse
		@racer1[:CurrentPlacement] = (racersSorted.index(@racer1) + 1)
		@racer2[:CurrentPlacement] = (racersSorted.index(@racer2) + 1)
		@racer3[:CurrentPlacement] = (racersSorted.index(@racer3) + 1)
		@racerPlayer[:CurrentPlacement] = (racersSorted.index(@racerPlayer) + 1)
		#Console.echo_warn "#{@racerPlayer[:LapAndPlacement]}"
	end #def self.updateRacerPlacement

	def self.checkForCollisions(racer)
		#make crashing into someone in front of you change your current speed and desired speed to the racer you crashed into
		###################################
		#============= Racer1 =============
		###################################
		#collide with racers
		self.bumpedIntoSomeone(racer, @racer1) if racer != @racer1 && self.collides_with_object_in_front?(racer[:RacerSprite],@racer1[:RacerSprite])
		self.bumpedIntoSomeone(racer, @racer2) if racer != @racer2 && self.collides_with_object_in_front?(racer[:RacerSprite],@racer2[:RacerSprite])
		self.bumpedIntoSomeone(racer, @racer3) if racer != @racer3 && self.collides_with_object_in_front?(racer[:RacerSprite],@racer3[:RacerSprite])
		self.bumpedIntoSomeone(racer, @racerPlayer) if racer != @racerPlayer && self.collides_with_object_in_front?(racer[:RacerSprite],@racerPlayer[:RacerSprite])
		
		#collide with rock hazard
		#this method of checking for collisions does not account for weird sprite placement
		#spin out racer 1 (recipient) with racerPlayer as the attacher if racer1 hits racerPlayer's hazard
		if @racer1[:RockHazard][:Sprite] && !@racer1[:RockHazard][:Sprite].disposed? && self.collides_with?(racer[:RacerSprite],@racer1[:RockHazard][:Sprite])
			self.disposeHazard(@racer1, "rock")
			if self.racerOnScreen?(racer) && @currentlyPlayingSE != CrustangRacingSettings::ROCK_COLLISION_SE
				pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE)
				@currentlyPlayingSE = CrustangRacingSettings::ROCK_COLLISION_SE
				@currentlyPlayingSETimer = CrustangRacingSettings::SE_SPAM_PREVENTION_WAIT_IN_SECONDS * Graphics.frame_rate
			end
			self.spinOut(@racer1, racer) if racer[:InvincibilityStatus] == false
			self.endInvincibility(racer) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer1, racer, "rock")
		end
		if @racer2[:RockHazard][:Sprite] && !@racer2[:RockHazard][:Sprite].disposed? && self.collides_with?(racer[:RacerSprite],@racer2[:RockHazard][:Sprite])
			self.disposeHazard(@racer2, "rock")
			if self.racerOnScreen?(racer) && @currentlyPlayingSE != CrustangRacingSettings::ROCK_COLLISION_SE
				pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE)
				@currentlyPlayingSE = CrustangRacingSettings::ROCK_COLLISION_SE
				@currentlyPlayingSETimer = CrustangRacingSettings::SE_SPAM_PREVENTION_WAIT_IN_SECONDS * Graphics.frame_rate
			end
			self.spinOut(@racer2, racer) if racer[:InvincibilityStatus] == false
			self.endInvincibility(racer) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer2, racer, "rock")
		end
		if @racer3[:RockHazard][:Sprite] && !@racer3[:RockHazard][:Sprite].disposed? && self.collides_with?(racer[:RacerSprite],@racer3[:RockHazard][:Sprite])
			self.disposeHazard(@racer3, "rock")
			if self.racerOnScreen?(racer) && @currentlyPlayingSE != CrustangRacingSettings::ROCK_COLLISION_SE
				pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE)
				@currentlyPlayingSE = CrustangRacingSettings::ROCK_COLLISION_SE
				@currentlyPlayingSETimer = CrustangRacingSettings::SE_SPAM_PREVENTION_WAIT_IN_SECONDS * Graphics.frame_rate
			end
			self.spinOut(@racer3, racer) if racer[:InvincibilityStatus] == false
			self.endInvincibility(racer) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer3, racer, "rock")
		end
		if @racerPlayer[:RockHazard][:Sprite] && !@racerPlayer[:RockHazard][:Sprite].disposed? && self.collides_with?(racer[:RacerSprite],@racerPlayer[:RockHazard][:Sprite])
			self.disposeHazard(@racerPlayer, "rock")
			if self.racerOnScreen?(racer) && @currentlyPlayingSE != CrustangRacingSettings::ROCK_COLLISION_SE
				pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE)
				@currentlyPlayingSE = CrustangRacingSettings::ROCK_COLLISION_SE
				@currentlyPlayingSETimer = CrustangRacingSettings::SE_SPAM_PREVENTION_WAIT_IN_SECONDS * Graphics.frame_rate
			end
			self.spinOut(@racerPlayer, racer) if racer[:InvincibilityStatus] == false
			self.endInvincibility(racer) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racerPlayer, racer, "rock")
		end
		
		#collide with mud hazard
		if @racer1[:MudHazard][:Sprite] && !@racer1[:MudHazard][:Sprite].disposed? && self.collides_with?(racer[:RacerSprite],@racer1[:MudHazard][:Sprite])
			self.disposeHazard(@racer1, "mud")
			if self.racerOnScreen?(racer) && @currentlyPlayingSE != CrustangRacingSettings::MUD_COLLISION_SE
				pbSEPlay(CrustangRacingSettings::MUD_COLLISION_SE)
				@currentlyPlayingSE = CrustangRacingSettings::MUD_COLLISION_SE
				@currentlyPlayingSETimer = CrustangRacingSettings::SE_SPAM_PREVENTION_WAIT_IN_SECONDS * Graphics.frame_rate
			end
			self.spinOut(@racer1, racer) if racer[:InvincibilityStatus] == false
			self.endInvincibility(racer) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer1, racer, "mud")
		end
		if @racer2[:MudHazard][:Sprite] && !@racer2[:MudHazard][:Sprite].disposed? && self.collides_with?(racer[:RacerSprite],@racer2[:MudHazard][:Sprite])
			self.disposeHazard(@racer2, "mud")
			if self.racerOnScreen?(racer) && @currentlyPlayingSE != CrustangRacingSettings::MUD_COLLISION_SE
				pbSEPlay(CrustangRacingSettings::MUD_COLLISION_SE)
				@currentlyPlayingSE = CrustangRacingSettings::MUD_COLLISION_SE
				@currentlyPlayingSETimer = CrustangRacingSettings::SE_SPAM_PREVENTION_WAIT_IN_SECONDS * Graphics.frame_rate
			end
			self.spinOut(@racer2, racer) if racer[:InvincibilityStatus] == false
			self.endInvincibility(racer) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer2, racer, "mud")
		end
		if @racer3[:MudHazard][:Sprite] && !@racer3[:MudHazard][:Sprite].disposed? && self.collides_with?(racer[:RacerSprite],@racer3[:MudHazard][:Sprite])
			self.disposeHazard(@racer3, "mud")
			if self.racerOnScreen?(racer) && @currentlyPlayingSE != CrustangRacingSettings::MUD_COLLISION_SE
				pbSEPlay(CrustangRacingSettings::MUD_COLLISION_SE)
				@currentlyPlayingSE = CrustangRacingSettings::MUD_COLLISION_SE
				@currentlyPlayingSETimer = CrustangRacingSettings::SE_SPAM_PREVENTION_WAIT_IN_SECONDS * Graphics.frame_rate
			end
			self.spinOut(@racer3, racer) if racer[:InvincibilityStatus] == false
			self.endInvincibility(racer) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer3, racer, "mud")
		end
		if @racerPlayer[:MudHazard][:Sprite] && !@racerPlayer[:MudHazard][:Sprite].disposed? && self.collides_with?(racer[:RacerSprite],@racerPlayer[:MudHazard][:Sprite])
			self.disposeHazard(@racerPlayer, "mud")
			if self.racerOnScreen?(racer) && @currentlyPlayingSE != CrustangRacingSettings::MUD_COLLISION_SE
				pbSEPlay(CrustangRacingSettings::MUD_COLLISION_SE)
				@currentlyPlayingSE = CrustangRacingSettings::MUD_COLLISION_SE
				@currentlyPlayingSETimer = CrustangRacingSettings::SE_SPAM_PREVENTION_WAIT_IN_SECONDS * Graphics.frame_rate
			end
			self.spinOut(@racerPlayer, racer) if racer[:InvincibilityStatus] == false
			self.endInvincibility(racer) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racerPlayer, racer, "mud")
		end

	end #def self.checkForCollisions

	def self.endInvincibility(racer)
		#Console.echo_warn "ending invincibility" if racer == @racer1
		racer[:InvincibilityTimer] = 0
		racer[:DesiredHue] = nil
		racer[:InvincibilityStatus] = false
		if racer == @racerPlayer
			pbBGMStop(0.5) #stop bgm in 0.5 seconds, fading out
			#resume bgm
			$game_system.bgm_resume(@playingBGM)
		end
	end #def self.endInvincibility
	
	def self.cancellingMove?
		@cancellingMove = true if @pressingMove1 && @pressingMove2
		@cancellingMove = true if @pressingMove1 && @pressingMove3
		@cancellingMove = true if @pressingMove1 && @pressingMove4
		@cancellingMove = true if @pressingMove2 && @pressingMove3
		@cancellingMove = true if @pressingMove2 && @pressingMove4
		@cancellingMove = true if @pressingMove3 && @pressingMove4
		@cancellingMove = false if !@pressingMove1 && !@pressingMove2 && !@pressingMove3 && !@pressingMove4
		
		return @cancellingMove
	end #def self.cancellingMove?
	
	def self.racerOnScreen?(racer)
		if racer[:RacerSprite].x.between?(0-racer[:RacerSprite].width, Graphics.width)
			return true
		end
	end #self.racerOnScreen?(racer)
	
	def self.withinHazardDetectionRange?(racer, hazard)
		#hazard will be the entire hazard hash passed in like so:
		#self.withinHazardDetectionRange?(@racerPlayer, @racer1[:RockHazard])
		
		withinRangeX = false
			
		###### Checking in front of player
		detectionRange = CrustangRacingSettings::UPCOMING_HAZARD_DETECTION_DISTANCE
		
		if racer[:PositionOnTrack] > @sprites["track1"].width - detectionRange
			#there will be some overlap between the end of the track and the beginning of the track
			positionOnTrackInFrontOfRacer = []
			positionOnTrackInFrontOfRacer.push([racer[:PositionOnTrack], @sprites["track1"].width])
			amountHittingBeginningOfTrack = detectionRange - (@sprites["track1"].width - (racer[:PositionOnTrack]))
			positionOnTrackInFrontOfRacer.push([0, amountHittingBeginningOfTrack])
			#the above array will look something like this:
			#positionOnTrackInFrontOfRacer is an array with these elements: [[6100, 6144], [0, 106]]
		else
			positionOnTrackInFrontOfRacer = racer[:PositionOnTrack] + detectionRange
		end
		
		#if positionOnTrackInFrontOfRacer is an array or not
		if positionOnTrackInFrontOfRacer.kind_of?(Array)
			withinRangeX = true if hazard[:PositionXOnTrack].between?(positionOnTrackInFrontOfRacer[0][0], positionOnTrackInFrontOfRacer[0][1]) || hazard[:PositionXOnTrack].between?(positionOnTrackInFrontOfRacer[1][0], positionOnTrackInFrontOfRacer[1][1])
		else
			withinRangeX = true if hazard[:PositionXOnTrack].between?(racer[:PositionOnTrack], positionOnTrackInFrontOfRacer)
		end
		
		#crude way of saying it's no longer in range when on the screen
		withinRangeX = false if hazard[:Sprite].x.between?(0, Graphics.width) && racer == @racerPlayer #we don't want a hazard alarm happening for the player if the hazard is on screen, but we do want AI to detect upcoming hazards that are on the screen and beyond

		return withinRangeX
	end #def self.withinHazardDetectionRange?
	
	def self.willCollideWithHazard?(racer, hazard)
		#used specifically for detecting whether the racer needs to strafe out of the way of an upcoming hazard
		collisionGrace = 1
		
		###################################
		#==== Detecting Racer1 Hazards ====
		###################################
		if hazard == "rock"
			hazard = @racer1[:RockHazard]
		elsif hazard == "mud"
			hazard = @racer1[:RockHazard]
		end
		
		if !hazard[:Sprite].nil? && hazard[:Sprite].y.between?(racer[:RacerSprite].y - hazard[:Sprite].height + collisionGrace, racer[:RacerSprite].y + racer[:RacerSprite].height - collisionGrace)
			return true
		end
		
		###################################
		#==== Detecting Racer2 Hazards ====
		###################################
		if hazard == "rock"
			hazard = @racer2[:RockHazard]
		elsif hazard == "mud"
			hazard = @racer2[:RockHazard]
		end
		
		if !hazard[:Sprite].nil? && hazard[:Sprite].y.between?(racer[:RacerSprite].y - hazard[:Sprite].height + collisionGrace, racer[:RacerSprite].y + racer[:RacerSprite].height - collisionGrace)
			return true
		end
		
		###################################
		#==== Detecting Racer3 Hazards ====
		###################################
		if hazard == "rock"
			hazard = @racer3[:RockHazard]
		elsif hazard == "mud"
			hazard = @racer3[:RockHazard]
		end
		
		if !hazard[:Sprite].nil? && hazard[:Sprite].y.between?(racer[:RacerSprite].y - hazard[:Sprite].height + collisionGrace, racer[:RacerSprite].y + racer[:RacerSprite].height - collisionGrace)
			return true
		end
		
		###################################
		#==== Detecting Player Hazards ====
		###################################
		if hazard == "rock"
			hazard = @racerPlayer[:RockHazard]
		elsif hazard == "mud"
			hazard = @racerPlayer[:RockHazard]
		end
		
		if !hazard[:Sprite].nil? && hazard[:Sprite].y.between?(racer[:RacerSprite].y - hazard[:Sprite].height + collisionGrace, racer[:RacerSprite].y + racer[:RacerSprite].height - collisionGrace)
			return true
		end

		return false
	end #def self.withinHazardDetectionRange?
	
	def self.rngRoll(chance=nil)
		return if @rngRollsTimer > 0 #if not able to roll rng yet
		return if chance.nil? #if not rolling rng for anything at the moment
		
		#otherwise, roll rng
		return rand(100).between?(1, chance)
	end #self.rngRoll(chance)
	
	def self.hasMoveEffect?(racer, effect)
		if !racer[:Move1].nil? && self.getMoveEffect(racer, 1) == effect
			return 1
		end
		if !racer[:Move2].nil? && self.getMoveEffect(racer, 2) == effect
			return 2
		end
		if !racer[:Move3].nil? && self.getMoveEffect(racer, 3) == effect
			return 3
		end
		if !racer[:Move4].nil? && self.getMoveEffect(racer, 4) == effect
			return 4
		end
		return false
	end #def self.hasMoveEffect?(racer, effect)
	
	def self.hasMoveEffectThatRequiresTargetAndMoveIsReady?(racer)
		if self.hasMoveEffect?(racer, "spinOut") != false
			moveNumber = self.hasMoveEffect?(racer, "spinOut")
			case moveNumber
			when 1
				return true if racer[:Move1CooldownTimer] <= 0
			when 2
				return true if racer[:Move2CooldownTimer] <= 0
			when 3
				return true if racer[:Move3CooldownTimer] <= 0
			when 4
				return true if racer[:Move4CooldownTimer] <= 0
			end
		end
		if self.hasMoveEffect?(racer, "overload") != false
			moveNumber = self.hasMoveEffect?(racer, "overload")
			case moveNumber
			when 1
				return true if racer[:Move1CooldownTimer] <= 0
			when 2
				return true if racer[:Move2CooldownTimer] <= 0
			when 3
				return true if racer[:Move3CooldownTimer] <= 0
			when 4
				return true if racer[:Move4CooldownTimer] <= 0
			end
		end
		return false
	end #def self.hasMoveEffectThatRequiresTarget
	
end #class CrustangRacing

#from http://stackoverflow.com/questions/3668345/calculate-percentage-in-ruby
class Numeric
  def percent_of(n)
    self.to_f / n.to_f * 100.0
  end
end