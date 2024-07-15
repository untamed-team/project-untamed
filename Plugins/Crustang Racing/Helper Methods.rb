class CrustangRacing
	def self.collides_with?(racer,object)
		if (object.x + object.width-object.width >= racer.x) && (object.x <= racer.x + racer.width) &&
			 (object.y + object.height >= racer.y) && (object.y <= racer.y + racer.height)
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

	def self.checkForCollisions
		#make crashing into someone in front of you change your current speed and desired speed to the racer you crashed into
		###################################
		#============= Racer1 =============
		###################################
		#collide with racers
		self.bumpedIntoSomeone(@racer1, @racerPlayer) if self.collides_with_object_in_front?(@racer1[:RacerSprite],@racerPlayer[:RacerSprite])
		self.bumpedIntoSomeone(@racer1, @racer2) if self.collides_with_object_in_front?(@racer1[:RacerSprite],@racer2[:RacerSprite])
		self.bumpedIntoSomeone(@racer1, @racer3) if self.collides_with_object_in_front?(@racer1[:RacerSprite],@racer3[:RacerSprite])
		
		#collide with rock hazard
		#this method of checking for collisions does not account for weird sprite placement
		#spin out racer 1 (recipient) with racerPlayer as the attacher if racer1 hits racerPlayer's hazard
		if @racer1[:RockHazard][:Sprite] && !@racer1[:RockHazard][:Sprite].disposed? && self.collides_with?(@racer1[:RacerSprite],@racer1[:RockHazard][:Sprite])
			self.disposeHazard(@racer1, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer1[:RacerSprite].x.between?(0-@racer1[:RacerSprite].width,Graphics.width)
			self.spinOut(@racer1, @racer1) if @racer1[:InvincibilityStatus] == false
			self.endInvincibility(@racer1) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer1, @racer1, "rock")
		end
		if @racer2[:RockHazard][:Sprite] && !@racer2[:RockHazard][:Sprite].disposed? && self.collides_with?(@racer1[:RacerSprite],@racer2[:RockHazard][:Sprite])
			self.disposeHazard(@racer2, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer1[:RacerSprite].x.between?(0-@racer1[:RacerSprite].width,Graphics.width)
			self.spinOut(@racer2, @racer1) if @racer1[:InvincibilityStatus] == false
			self.endInvincibility(@racer1) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer2, @racer1, "rock")
		end
		if @racer3[:RockHazard][:Sprite] && !@racer3[:RockHazard][:Sprite].disposed? && self.collides_with?(@racer1[:RacerSprite],@racer3[:RockHazard][:Sprite])
			self.disposeHazard(@racer3, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer1[:RacerSprite].x.between?(0-@racer1[:RacerSprite].width,Graphics.width)
			self.spinOut(@racer3, @racer1) if @racer1[:InvincibilityStatus] == false
			self.endInvincibility(@racer1) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer3, @racer1, "rock")
		end
		if @racerPlayer[:RockHazard][:Sprite] && !@racerPlayer[:RockHazard][:Sprite].disposed? && self.collides_with?(@racer1[:RacerSprite],@racerPlayer[:RockHazard][:Sprite])
			self.disposeHazard(@racerPlayer, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer1[:RacerSprite].x.between?(0-@racer1[:RacerSprite].width,Graphics.width)
			self.spinOut(@racerPlayer, @racer1) if @racer1[:InvincibilityStatus] == false
			self.endInvincibility(@racer1) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racerPlayer, @racer1, "rock")
		end
		
		#collide with mud hazard
		if @racer1[:MudHazard][:Sprite] && !@racer1[:MudHazard][:Sprite].disposed? && self.collides_with?(@racer1[:RacerSprite],@racer1[:MudHazard][:Sprite])
			self.disposeHazard(@racer1, "mud")
			pbSEPlay(CrustangRacingSettings::MUD_COLLISION_SE) if @racer1[:RacerSprite].x.between?(0-@racer1[:RacerSprite].width,Graphics.width)
			self.spinOut(@racer1, @racer1) if @racer1[:InvincibilityStatus] == false
			self.endInvincibility(@racer1) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer1, @racer1, "mud")
		end
		if @racer2[:MudHazard][:Sprite] && !@racer2[:MudHazard][:Sprite].disposed? && self.collides_with?(@racer1[:RacerSprite],@racer2[:MudHazard][:Sprite])
			self.disposeHazard(@racer2, "mud")
			pbSEPlay(CrustangRacingSettings::MUD_COLLISION_SE) if @racer1[:RacerSprite].x.between?(0-@racer1[:RacerSprite].width,Graphics.width)
			self.spinOut(@racer2, @racer1) if @racer1[:InvincibilityStatus] == false
			self.endInvincibility(@racer1) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer2, @racer1, "mud")
		end
		if @racer3[:MudHazard][:Sprite] && !@racer3[:MudHazard][:Sprite].disposed? && self.collides_with?(@racer1[:RacerSprite],@racer3[:MudHazard][:Sprite])
			self.disposeHazard(@racer3, "mud")
			pbSEPlay(CrustangRacingSettings::MUD_COLLISION_SE) if @racer1[:RacerSprite].x.between?(0-@racer1[:RacerSprite].width,Graphics.width)
			self.spinOut(@racer3, @racer1) if @racer1[:InvincibilityStatus] == false
			self.endInvincibility(@racer1) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer3, @racer1, "mud")
		end
		if @racerPlayer[:MudHazard][:Sprite] && !@racerPlayer[:MudHazard][:Sprite].disposed? && self.collides_with?(@racer1[:RacerSprite],@racerPlayer[:MudHazard][:Sprite])
			self.disposeHazard(@racerPlayer, "mud")
			pbSEPlay(CrustangRacingSettings::MUD_COLLISION_SE) if @racer1[:RacerSprite].x.between?(0-@racer1[:RacerSprite].width,Graphics.width)
			self.spinOut(@racerPlayer, @racer1) if @racer1[:InvincibilityStatus] == false
			self.endInvincibility(@racer1) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racerPlayer, @racer1, "mud")
		end
		
		###################################
		#============= Racer2 =============
		###################################
		#collide with racers
		self.bumpedIntoSomeone(@racer2, @racer1) if self.collides_with_object_in_front?(@racer2[:RacerSprite],@racer1[:RacerSprite])
		self.bumpedIntoSomeone(@racer2, @racerPlayer) if self.collides_with_object_in_front?(@racer2[:RacerSprite],@racerPlayer[:RacerSprite])
		self.bumpedIntoSomeone(@racer2, @racer3) if self.collides_with_object_in_front?(@racer2[:RacerSprite],@racer3[:RacerSprite])
		
		#collide with rock hazard
		if @racer1[:RockHazard][:Sprite] && !@racer1[:RockHazard][:Sprite].disposed? && self.collides_with?(@racer2[:RacerSprite],@racer1[:RockHazard][:Sprite])
			self.disposeHazard(@racer1, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer2[:RacerSprite].x.between?(0-@racer2[:RacerSprite].width,Graphics.width)
			self.spinOut(@racer1, @racer2) if @racer2[:InvincibilityStatus] == false
			self.endInvincibility(@racer2) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer1, @racer2, "rock")
		end
		if @racer2[:RockHazard][:Sprite] && !@racer2[:RockHazard][:Sprite].disposed? && self.collides_with?(@racer2[:RacerSprite],@racer2[:RockHazard][:Sprite])
			self.disposeHazard(@racer2, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer2[:RacerSprite].x.between?(0-@racer2[:RacerSprite].width,Graphics.width)
			self.spinOut(@racer2, @racer2) if @racer2[:InvincibilityStatus] == false
			self.endInvincibility(@racer2) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer2, @racer2, "rock")
		end
		if @racer3[:RockHazard][:Sprite] && !@racer3[:RockHazard][:Sprite].disposed? && self.collides_with?(@racer2[:RacerSprite],@racer3[:RockHazard][:Sprite])
			self.disposeHazard(@racer3, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer2[:RacerSprite].x.between?(0-@racer2[:RacerSprite].width,Graphics.width)
			self.spinOut(@racer3, @racer2) if @racer2[:InvincibilityStatus] == false
			self.endInvincibility(@racer2) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer3, @racer2, "rock")
		end
		if @racerPlayer[:RockHazard][:Sprite] && !@racerPlayer[:RockHazard][:Sprite].disposed? && self.collides_with?(@racer2[:RacerSprite],@racerPlayer[:RockHazard][:Sprite])
			self.disposeHazard(@racerPlayer, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer2[:RacerSprite].x.between?(0-@racer2[:RacerSprite].width,Graphics.width)
			self.spinOut(@racerPlayer, @racer2) if @racer2[:InvincibilityStatus] == false
			self.endInvincibility(@racer2) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racerPlayer, @racer2, "rock")
		end
		
		#collide with mud hazard
		if @racer1[:MudHazard][:Sprite] && !@racer1[:MudHazard][:Sprite].disposed? && self.collides_with?(@racer2[:RacerSprite],@racer1[:MudHazard][:Sprite])
			self.disposeHazard(@racer1, "mud")
			pbSEPlay(CrustangRacingSettings::MUD_COLLISION_SE) if @racer2[:RacerSprite].x.between?(0-@racer2[:RacerSprite].width,Graphics.width)
			self.spinOut(@racer1, @racer2) if @racer2[:InvincibilityStatus] == false
			self.endInvincibility(@racer2) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer1, @racer2, "mud")
		end
		if @racer2[:MudHazard][:Sprite] && !@racer2[:MudHazard][:Sprite].disposed? && self.collides_with?(@racer2[:RacerSprite],@racer2[:MudHazard][:Sprite])
			self.disposeHazard(@racer2, "mud")
			pbSEPlay(CrustangRacingSettings::MUD_COLLISION_SE) if @racer2[:RacerSprite].x.between?(0-@racer2[:RacerSprite].width,Graphics.width)
			self.spinOut(@racer2, @racer2) if @racer2[:InvincibilityStatus] == false
			self.endInvincibility(@racer2) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer2, @racer2, "mud")
		end
		if @racer3[:MudHazard][:Sprite] && !@racer3[:MudHazard][:Sprite].disposed? && self.collides_with?(@racer2[:RacerSprite],@racer3[:MudHazard][:Sprite])
			self.disposeHazard(@racer3, "mud")
			pbSEPlay(CrustangRacingSettings::MUD_COLLISION_SE) if @racer2[:RacerSprite].x.between?(0-@racer2[:RacerSprite].width,Graphics.width)
			self.spinOut(@racer3, @racer2) if @racer2[:InvincibilityStatus] == false
			self.endInvincibility(@racer2) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer3, @racer2, "mud")
		end
		if @racerPlayer[:MudHazard][:Sprite] && !@racerPlayer[:MudHazard][:Sprite].disposed? && self.collides_with?(@racer2[:RacerSprite],@racerPlayer[:MudHazard][:Sprite])
			self.disposeHazard(@racerPlayer, "mud")
			pbSEPlay(CrustangRacingSettings::MUD_COLLISION_SE) if @racer2[:RacerSprite].x.between?(0-@racer2[:RacerSprite].width,Graphics.width)
			self.spinOut(@racerPlayer, @racer2) if @racer2[:InvincibilityStatus] == false
			self.endInvincibility(@racer2) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racerPlayer, @racer2, "mud")
		end
		
		###################################
		#============= Racer3 =============
		###################################
		#collide with racers
		self.bumpedIntoSomeone(@racer3, @racer1) if self.collides_with_object_in_front?(@racer3[:RacerSprite],@racer1[:RacerSprite])
		self.bumpedIntoSomeone(@racer3, @racer2) if self.collides_with_object_in_front?(@racer3[:RacerSprite],@racer2[:RacerSprite])
		self.bumpedIntoSomeone(@racer3, @racerPlayer) if self.collides_with_object_in_front?(@racer3[:RacerSprite],@racerPlayer[:RacerSprite])
		
		#collide with rock hazard
		if @racer1[:RockHazard][:Sprite] && !@racer1[:RockHazard][:Sprite].disposed? && self.collides_with?(@racer3[:RacerSprite],@racer1[:RockHazard][:Sprite])
			self.disposeHazard(@racer1, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer3[:RacerSprite].x.between?(0-@racer3[:RacerSprite].width,Graphics.width)
			self.spinOut(@racer1, @racer3) if @racer3[:InvincibilityStatus] == false
			self.endInvincibility(@racer3) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer1, @racer3, "rock")
		end
		if @racer2[:RockHazard][:Sprite] && !@racer2[:RockHazard][:Sprite].disposed? && self.collides_with?(@racer3[:RacerSprite],@racer2[:RockHazard][:Sprite])
			self.disposeHazard(@racer2, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer3[:RacerSprite].x.between?(0-@racer3[:RacerSprite].width,Graphics.width)
			self.spinOut(@racer2, @racer3) if @racer3[:InvincibilityStatus] == false
			self.endInvincibility(@racer3) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer2, @racer3, "rock")
		end
		if @racer3[:RockHazard][:Sprite] && !@racer3[:RockHazard][:Sprite].disposed? && self.collides_with?(@racer3[:RacerSprite],@racer3[:RockHazard][:Sprite])
			self.disposeHazard(@racer3, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer3[:RacerSprite].x.between?(0-@racer3[:RacerSprite].width,Graphics.width)
			self.spinOut(@racer3, @racer3) if @racer3[:InvincibilityStatus] == false
			self.endInvincibility(@racer3) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer3, @racer3, "rock")
		end
		if @racerPlayer[:RockHazard][:Sprite] && !@racerPlayer[:RockHazard][:Sprite].disposed? && self.collides_with?(@racer3[:RacerSprite],@racerPlayer[:RockHazard][:Sprite])
			self.disposeHazard(@racerPlayer, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE) if @racer3[:RacerSprite].x.between?(0-@racer3[:RacerSprite].width,Graphics.width)
			self.spinOut(@racerPlayer, @racer3) if @racer3[:InvincibilityStatus] == false
			self.endInvincibility(@racer3) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racerPlayer, @racer3, "rock")
		end
		
		#collide with mud hazard
		if @racer1[:MudHazard][:Sprite] && !@racer1[:MudHazard][:Sprite].disposed? && self.collides_with?(@racer3[:RacerSprite],@racer1[:MudHazard][:Sprite])
			self.disposeHazard(@racer1, "mud")
			pbSEPlay(CrustangRacingSettings::MUD_COLLISION_SE) if @racer3[:RacerSprite].x.between?(0-@racer3[:RacerSprite].width,Graphics.width)
			self.spinOut(@racer1, @racer3) if @racer3[:InvincibilityStatus] == false
			self.endInvincibility(@racer3) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer1, @racer3, "mud")
		end
		if @racer2[:MudHazard][:Sprite] && !@racer2[:MudHazard][:Sprite].disposed? && self.collides_with?(@racer3[:RacerSprite],@racer2[:MudHazard][:Sprite])
			self.disposeHazard(@racer2, "mud")
			pbSEPlay(CrustangRacingSettings::MUD_COLLISION_SE) if @racer3[:RacerSprite].x.between?(0-@racer3[:RacerSprite].width,Graphics.width)
			self.spinOut(@racer2, @racer3) if @racer3[:InvincibilityStatus] == false
			self.endInvincibility(@racer3) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer2, @racer3, "mud")
		end
		if @racer3[:MudHazard][:Sprite] && !@racer3[:MudHazard][:Sprite].disposed? && self.collides_with?(@racer3[:RacerSprite],@racer3[:MudHazard][:Sprite])
			self.disposeHazard(@racer3, "mud")
			pbSEPlay(CrustangRacingSettings::MUD_COLLISION_SE) if @racer3[:RacerSprite].x.between?(0-@racer3[:RacerSprite].width,Graphics.width)
			self.spinOut(@racer3, @racer3) if @racer3[:InvincibilityStatus] == false
			self.endInvincibility(@racer3) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer3, @racer3, "mud")
		end
		if @racerPlayer[:MudHazard][:Sprite] && !@racerPlayer[:MudHazard][:Sprite].disposed? && self.collides_with?(@racer3[:RacerSprite],@racerPlayer[:MudHazard][:Sprite])
			self.disposeHazard(@racerPlayer, "mud")
			pbSEPlay(CrustangRacingSettings::MUD_COLLISION_SE) if @racer3[:RacerSprite].x.between?(0-@racer3[:RacerSprite].width,Graphics.width)
			self.spinOut(@racerPlayer, @racer3) if @racer3[:InvincibilityStatus] == false
			self.endInvincibility(@racer3) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racerPlayer, @racer3, "mud")
		end
		
		###################################
		#============= Player =============
		###################################
		#collide with racers
		self.bumpedIntoSomeone(@racerPlayer, @racer1) if self.collides_with_object_in_front?(@racerPlayer[:RacerSprite],@racer1[:RacerSprite])
		self.bumpedIntoSomeone(@racerPlayer, @racer2) if self.collides_with_object_in_front?(@racerPlayer[:RacerSprite],@racer2[:RacerSprite])
		self.bumpedIntoSomeone(@racerPlayer, @racer3) if self.collides_with_object_in_front?(@racerPlayer[:RacerSprite],@racer3[:RacerSprite])
		
		#collide with rock hazard
		if @racer1[:RockHazard][:Sprite] && !@racer1[:RockHazard][:Sprite].disposed? && self.collides_with?(@racerPlayer[:RacerSprite],@racer1[:RockHazard][:Sprite])
			self.disposeHazard(@racer1, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE)
			self.spinOut(@racer1, @racerPlayer) if @racerPlayer[:InvincibilityStatus] == false
			self.endInvincibility(@racerPlayer) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer1, @racerPlayer, "rock")
		end
		if @racer2[:RockHazard][:Sprite] && !@racer2[:RockHazard][:Sprite].disposed? && self.collides_with?(@racerPlayer[:RacerSprite],@racer2[:RockHazard][:Sprite])
			self.disposeHazard(@racer2, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE)
			self.spinOut(@racer2, @racerPlayer) if @racerPlayer[:InvincibilityStatus] == false
			self.endInvincibility(@racerPlayer) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer2, @racerPlayer, "rock")
		end
		if @racer3[:RockHazard][:Sprite] && !@racer3[:RockHazard][:Sprite].disposed? && self.collides_with?(@racerPlayer[:RacerSprite],@racer3[:RockHazard][:Sprite])
			self.disposeHazard(@racer3, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE)
			self.spinOut(@racer3, @racerPlayer) if @racerPlayer[:InvincibilityStatus] == false
			self.endInvincibility(@racerPlayer) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer3, @racerPlayer, "rock")
		end
		if @racerPlayer[:RockHazard][:Sprite] && !@racerPlayer[:RockHazard][:Sprite].disposed? && self.collides_with?(@racerPlayer[:RacerSprite],@racerPlayer[:RockHazard][:Sprite])
			self.disposeHazard(@racerPlayer, "rock")
			pbSEPlay(CrustangRacingSettings::ROCK_COLLISION_SE)
			self.spinOut(@racerPlayer, @racerPlayer) if @racerPlayer[:InvincibilityStatus] == false
			self.endInvincibility(@racerPlayer) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racerPlayer, @racerPlayer, "rock")
		end
		
		#collide with mud hazard
		if @racer1[:MudHazard][:Sprite] && !@racer1[:MudHazard][:Sprite].disposed? && self.collides_with?(@racerPlayer[:RacerSprite],@racer1[:MudHazard][:Sprite])
			self.disposeHazard(@racer1, "mud")
			pbSEPlay(CrustangRacingSettings::MUD_COLLISION_SE)
			self.spinOut(@racer1, @racerPlayer) if @racerPlayer[:InvincibilityStatus] == false
			self.endInvincibility(@racerPlayer) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer1, @racerPlayer, "mud")
		end
		if @racer2[:MudHazard][:Sprite] && !@racer2[:MudHazard][:Sprite].disposed? && self.collides_with?(@racerPlayer[:RacerSprite],@racer2[:MudHazard][:Sprite])
			self.disposeHazard(@racer2, "mud")
			pbSEPlay(CrustangRacingSettings::MUD_COLLISION_SE)
			self.spinOut(@racer2, @racerPlayer) if @racerPlayer[:InvincibilityStatus] == false
			self.endInvincibility(@racerPlayer) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer2, @racerPlayer, "mud")
		end
		if @racer3[:MudHazard][:Sprite] && !@racer3[:MudHazard][:Sprite].disposed? && self.collides_with?(@racerPlayer[:RacerSprite],@racer3[:MudHazard][:Sprite])
			self.disposeHazard(@racer3, "mud")
			pbSEPlay(CrustangRacingSettings::MUD_COLLISION_SE)
			self.spinOut(@racer3, @racerPlayer) if @racerPlayer[:InvincibilityStatus] == false
			self.endInvincibility(@racerPlayer) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racer3, @racerPlayer, "mud")
		end
		if @racerPlayer[:MudHazard][:Sprite] && !@racerPlayer[:MudHazard][:Sprite].disposed? && self.collides_with?(@racerPlayer[:RacerSprite],@racerPlayer[:MudHazard][:Sprite])
			self.disposeHazard(@racerPlayer, "mud")
			pbSEPlay(CrustangRacingSettings::MUD_COLLISION_SE)
			self.spinOut(@racerPlayer, @racerPlayer) if @racerPlayer[:InvincibilityStatus] == false
			self.endInvincibility(@racerPlayer) if CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
			self.announceAttack(@racerPlayer, @racerPlayer, "mud")
		end

	end #def self.checkForCollisions
	
	def self.endInvincibility(racer)
		racer[:InvincibilityTimer] = 0
		racer[:DesiredHue] = nil
		racer[:InvincibilityStatus] = false
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
	
end #class CrustangRacing

#from http://stackoverflow.com/questions/3668345/calculate-percentage-in-ruby
class Numeric
  def percent_of(n)
    self.to_f / n.to_f * 100.0
  end
end