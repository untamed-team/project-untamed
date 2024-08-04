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
		
			#reset racer's spinout and overload ranges regardless of what move they just "released", as if they let go of the move button
			racer[:SpinOutCharge] = CrustangRacingSettings::SPINOUT_MIN_RANGE
			racer[:OverloadCharge] = CrustangRacingSettings::OVERLOAD_MIN_RANGE
		
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
	
	def self.getMoveEffect(racer, moveNumber)
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
		
		return move[:EffectCode]
	end #def self.getMoveEffect
	
	def self.moveEffect(racer, moveNumber)
		if moveNumber == 0
			###################################
			#============= Boost =============
			###################################
			racer[:BoostingStatus] = true
			if self.racerOnScreen?(racer) && @currentlyPlayingSE != CrustangRacingSettings::BOOST_SE
				pbSEPlay(CrustangRacingSettings::BOOST_SE)
				@currentlyPlayingSE = CrustangRacingSettings::BOOST_SE
				CrustangRacingSettings::SE_SPAM_PREVENTION_WAIT_IN_SECONDS * Graphics.frame_rate
			end
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
				racer[:DesiredHue] = @hues[:Red]
				racer[:InvincibilityStatus] = true
				racer[:InvincibilityTimer] = CrustangRacingSettings::INVINCIBILITY_DURATION_SECONDS * Graphics.frame_rate if !CrustangRacingSettings::INVINCIBLE_UNTIL_HIT
				if racer == @racerPlayer
					#pause bgm
					@playingBGM = $game_system.getPlayingBGM
					$game_system.bgm_pause(0.5) #pause over course of 0.5 seconds
					#play invinc SE
					pbBGMPlay(CrustangRacingSettings::INVINCIBLE_BGM)
				end
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
			when "overload" #Burden racers around you, decreasing their ability to strafe quickly.
				if racer != @racer1 && self.withinOverloadRange?(racer, @racer1)
					self.overload(racer, @racer1)
					self.announceAttack(racer, @racer1, "overload")
				end
				if racer != @racer2 && self.withinOverloadRange?(racer, @racer2)
					self.overload(racer, @racer2)
					self.announceAttack(racer, @racer2, "overload")
				end
				if racer != @racer3 && self.withinOverloadRange?(racer, @racer3)
					self.overload(racer, @racer3)
					self.announceAttack(racer, @racer3, "overload")
				end
				if racer != @racerPlayer && self.withinOverloadRange?(racer, @racerPlayer)
					self.overload(racer, @racerPlayer)
					self.announceAttack(racer, @racerPlayer, "overload")
				end
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
			racer[:RockHazard][:PositionXOnTrack] = racer[:PositionOnTrack] - sprite.width
			#if the racer is at position 0, and we put the hazard at 0 - the width of the sprite (16px), then the PositionXOnTrack is -16
			if racer[:RockHazard][:PositionXOnTrack] < 0
				#new position is (-16 + 6144).abs which is 6128
				newPosOnTrack = (racer[:RockHazard][:PositionXOnTrack] + @sprites["track1"].width).abs
				racer[:RockHazard][:PositionXOnTrack] = newPosOnTrack
			end
			racer[:RockHazard][:OriginalPositionXOnScreen] = sprite.x
			racer[:RockHazard][:PositionYOnTrack] = sprite.y
			offsetW = @sprites["racerPlayerPkmnOverview"].width/8
			offsetH = @sprites["racerPlayerPkmnOverview"].height/8
		elsif hazard == "mud"
			racer[:MudHazard][:Sprite] = sprite
			racer[:MudHazard][:PositionXOnTrack] = racer[:PositionOnTrack] - sprite.width
			#if the racer is at position 0, and we put the hazard at 0 - the width of the sprite (16px), then the PositionXOnTrack is -16
			if racer[:MudHazard][:PositionXOnTrack] < 0
				#new position is (-16 + 6144).abs which is 6128
				newPosOnTrack = (racer[:MudHazard][:PositionXOnTrack] + @sprites["track1"].width).abs
				racer[:MudHazard][:PositionXOnTrack] = newPosOnTrack
			end
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
		
		self.disposeHazardAlarm(racer, hazard)
	end #def self.disposeHazard
	
	def self.disposeHazardAlarm(racer, hazard)
		###################################
		#Remove Racer's Hazard Alarm of Same Type
		###################################
		if hazard == "rock" && racer[:RockHazard][:AlarmSprite] && !racer[:RockHazard][:AlarmSprite].disposed?
			racer[:RockHazard][:AlarmSprite].dispose
			racer[:RockHazard][:AlarmSprite] = nil
		elsif hazard == "mud" && racer[:MudHazard][:AlarmSprite] && !racer[:MudHazard][:AlarmSprite].disposed?
			racer[:MudHazard][:AlarmSprite].dispose
			racer[:MudHazard][:AlarmSprite] = nil
		end
	end #def self.disposeHazard
	
	def self.spinOut(attacker, recipient)
		#SPINOUT_DURATION_IN_SECONDS
		recipient[:SpinOutTimer] = CrustangRacingSettings::SPINOUT_DURATION_IN_SECONDS * Graphics.frame_rate #with this set to 3 seconds, that gives a value of 3*40 = 120 frames
		
		#maybe lock input / AI movement if being spun out?		
		recipient[:DesiredSpeed] = CrustangRacingSettings::SPINOUT_DESIRED_SPEED
		if self.racerOnScreen?(recipient) && @currentlyPlayingSE != CrustangRacingSettings::SPINOUT_SE
			pbSEPlay(CrustangRacingSettings::SPINOUT_SE)
			@currentlyPlayingSE = CrustangRacingSettings::SPINOUT_SE
			CrustangRacingSettings::SE_SPAM_PREVENTION_WAIT_IN_SECONDS * Graphics.frame_rate
		end
	end #self.spinOut
	
	def self.overload(attacker, recipient)
		#OVERLOAD_DURATION_IN_SECONDS
		recipient[:OverloadTimer] = CrustangRacingSettings::OVERLOAD_DURATION_IN_SECONDS * Graphics.frame_rate	
		recipient[:Overloaded] = true
		if self.racerOnScreen?(recipient) && @currentlyPlayingSE != CrustangRacingSettings::OVERLOADED_SE
			pbSEPlay(CrustangRacingSettings::OVERLOADED_SE)
			@currentlyPlayingSE = CrustangRacingSettings::OVERLOADED_SE
			CrustangRacingSettings::SE_SPAM_PREVENTION_WAIT_IN_SECONDS * Graphics.frame_rate
		end
	end #self.spinOut
	
	def self.assignMoveEffects
		#assign move effects based on the moves the racer has
		###################################
		#============= Racer1 =============
		###################################
		for i in 0...@racer1[:EnteredCrustangContestant][:Moves].length
			CrustangRacingSettings::MOVE_EFFECTS.each do |key, valueHash|
				if valueHash[:AssignedMoves].include?(@racer1[:EnteredCrustangContestant][:Moves][i])
					case i
					when 0
						@racer1[:Move1] = valueHash
					when 1
						@racer1[:Move2] = valueHash
					when 2
						@racer1[:Move3] = valueHash
					when 3
						@racer1[:Move4] = valueHash
					end
				end #if valueHash[:AssignedMoves].include?
			end #CrustangRacingSettings::MOVE_EFFECTS.each do |key, valueHash|
		end #for i in 0...
		
		###################################
		#============= Racer2 =============
		###################################
		for i in 0...@racer2[:EnteredCrustangContestant][:Moves].length
			CrustangRacingSettings::MOVE_EFFECTS.each do |key, valueHash|
				if valueHash[:AssignedMoves].include?(@racer2[:EnteredCrustangContestant][:Moves][i])
					case i
					when 0
						@racer2[:Move1] = valueHash
					when 1
						@racer2[:Move2] = valueHash
					when 2
						@racer2[:Move3] = valueHash
					when 3
						@racer2[:Move4] = valueHash
					end
				end #if valueHash[:AssignedMoves].include?
			end #CrustangRacingSettings::MOVE_EFFECTS.each do |key, valueHash|
		end #for i in 0...
		
		###################################
		#============= Racer3 =============
		###################################
		for i in 0...@racer3[:EnteredCrustangContestant][:Moves].length
			CrustangRacingSettings::MOVE_EFFECTS.each do |key, valueHash|
				if valueHash[:AssignedMoves].include?(@racer3[:EnteredCrustangContestant][:Moves][i])
					case i
					when 0
						@racer3[:Move1] = valueHash
					when 1
						@racer3[:Move2] = valueHash
					when 2
						@racer3[:Move3] = valueHash
					when 3
						@racer3[:Move4] = valueHash
					end
				end #if valueHash[:AssignedMoves].include?
			end #CrustangRacingSettings::MOVE_EFFECTS.each do |key, valueHash|
		end #for i in 0...
		
		###################################
		#============= Player =============
		###################################
		for i in 0...@enteredCrustang.moves.length
			CrustangRacingSettings::MOVE_EFFECTS.each do |key, valueHash|
				#valueHash is the move's hash containing the effect name, effect code, moves, etc.
				if valueHash[:AssignedMoves].include?(@enteredCrustang.moves[i].id)
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
		#attacker is an entire racer hash
		#need to set entered crustang value on each racer so I can use "attacker[:EnteredCrustang][:TrainerName]"
		
		case attacker
		when @racer1
			#attacker = "Racer1"
		when @racer2
			#attacker = "Racer2"
		when @racer3
			#attacker = "Racer3"
		when @racerPlayer
			#attacker = "RacerPlayer"
		end
		
		case recipient
		when @racer1
			#recipient = "Racer1"
		when @racer2
			#recipient = "Racer2"
		when @racer3
			#recipient = "Racer3"
		when @racerPlayer
			#recipient = "RacerPlayer"
		end
		announcement = "#{attacker[:EnteredCrustangContestant][:TrainerName]} -> #{action} -> #{recipient[:EnteredCrustangContestant][:TrainerName]}"
		Console.echo_warn announcement
		#keep the feed at 3 elements at most
		if @announcementsFeed.length >= 3
			@announcementsFeed.delete_at(0)
		end
		@announcementsFeed.push(announcement)
		case @announcementsFeed.length
		when 1
			@announcementsFeedString = "\n\n#{@announcementsFeed[0]}"
		when 2
			@announcementsFeedString = "\n#{@announcementsFeed[0]}\n#{@announcementsFeed[1]}"
		when 3
			@announcementsFeedString = "#{@announcementsFeed[0]}\n#{@announcementsFeed[1]}\n#{@announcementsFeed[2]}"
		end
	end #def self.announceAttack
	
	def self.monitorUpcomingHazards
		if !@racer1[:RockHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(@racerPlayer, @racer1[:RockHazard])
			#Console.echo_warn "racer1 rock in range!"
			pbBGSPlay(CrustangRacingSettings::HAZARD_ALARM_BGS)
			self.createHazardAlarmSprite(@racer1, "rock")
		end
		if !@racer1[:MudHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(@racerPlayer, @racer1[:MudHazard])
			#Console.echo_warn "racer1 mud in range!"
			pbBGSPlay(CrustangRacingSettings::HAZARD_ALARM_BGS)
			self.createHazardAlarmSprite(@racer1, "mud")
		end
		if !@racer2[:RockHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(@racerPlayer, @racer2[:RockHazard])
			#Console.echo_warn "racer2 rock in range!"
			pbBGSPlay(CrustangRacingSettings::HAZARD_ALARM_BGS)
			self.createHazardAlarmSprite(@racer2, "rock")
		end
		if !@racer2[:MudHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(@racerPlayer, @racer2[:MudHazard])
			#Console.echo_warn "racer2 mud in range!"
			pbBGSPlay(CrustangRacingSettings::HAZARD_ALARM_BGS)
			self.createHazardAlarmSprite(@racer2, "mud")
		end
		if !@racer3[:RockHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(@racerPlayer, @racer3[:RockHazard])
			#Console.echo_warn "racer3 rock in range!"
			pbBGSPlay(CrustangRacingSettings::HAZARD_ALARM_BGS)
			self.createHazardAlarmSprite(@racer3, "rock")
		end
		if !@racer3[:MudHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(@racerPlayer, @racer3[:MudHazard])
			#Console.echo_warn "racer3 mud in range!"
			pbBGSPlay(CrustangRacingSettings::HAZARD_ALARM_BGS)
			self.createHazardAlarmSprite(@racer3, "mud")
		end
		if !@racerPlayer[:RockHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(@racerPlayer, @racerPlayer[:RockHazard])
			#Console.echo_warn "racerPlayer rock in range!"
			pbBGSPlay(CrustangRacingSettings::HAZARD_ALARM_BGS)
			self.createHazardAlarmSprite(@racerPlayer, "rock")
		end
		if !@racerPlayer[:MudHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(@racerPlayer, @racerPlayer[:MudHazard])
			#Console.echo_warn "racerPlayer mud in range!"
			pbBGSPlay(CrustangRacingSettings::HAZARD_ALARM_BGS)
			self.createHazardAlarmSprite(@racerPlayer, "mud")
		end
			
		########################################
		# Stop Alarm if No Upcoming Hazards ====
		########################################
		anyUpcomingHazards = false

		anyUpcomingHazards = true if !@racer1[:RockHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(@racerPlayer, @racer1[:RockHazard])
		anyUpcomingHazards = true if !@racer2[:RockHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(@racerPlayer, @racer2[:RockHazard])
		anyUpcomingHazards = true if !@racer3[:RockHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(@racerPlayer, @racer3[:RockHazard])
		anyUpcomingHazards = true if !@racerPlayer[:RockHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(@racerPlayer, @racerPlayer[:RockHazard])
		anyUpcomingHazards = true if !@racer1[:MudHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(@racerPlayer, @racer1[:MudHazard])
		anyUpcomingHazards = true if !@racer2[:MudHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(@racerPlayer, @racer2[:MudHazard])
		anyUpcomingHazards = true if !@racer3[:MudHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(@racerPlayer, @racer3[:MudHazard])
		anyUpcomingHazards = true if !@racerPlayer[:MudHazard][:PositionXOnTrack].nil? && self.withinHazardDetectionRange?(@racerPlayer, @racerPlayer[:MudHazard])
		
		pbBGSStop(0) if !anyUpcomingHazards
		
		#dispose the alarm sprite if no longer in range
		self.disposeHazardAlarm(@racer1, "rock") if !@racer1[:RockHazard][:AlarmSprite].nil? && !self.withinHazardDetectionRange?(@racerPlayer, @racer1[:RockHazard])
		self.disposeHazardAlarm(@racer1, "mud") if !@racer1[:MudHazard][:AlarmSprite].nil? && !self.withinHazardDetectionRange?(@racerPlayer, @racer1[:MudHazard])
		self.disposeHazardAlarm(@racer2, "rock") if !@racer2[:RockHazard][:AlarmSprite].nil? && !self.withinHazardDetectionRange?(@racerPlayer, @racer2[:RockHazard])
		self.disposeHazardAlarm(@racer2, "mud") if !@racer2[:MudHazard][:AlarmSprite].nil? && !self.withinHazardDetectionRange?(@racerPlayer, @racer2[:MudHazard])
		self.disposeHazardAlarm(@racer3, "rock") if !@racer3[:RockHazard][:AlarmSprite].nil? && !self.withinHazardDetectionRange?(@racerPlayer, @racer3[:RockHazard])
		self.disposeHazardAlarm(@racer3, "mud") if !@racer3[:MudHazard][:AlarmSprite].nil? && !self.withinHazardDetectionRange?(@racerPlayer, @racer3[:MudHazard])
		self.disposeHazardAlarm(@racerPlayer, "rock") if !@racerPlayer[:RockHazard][:AlarmSprite].nil? && !self.withinHazardDetectionRange?(@racerPlayer, @racerPlayer[:RockHazard])
		self.disposeHazardAlarm(@racerPlayer, "mud") if !@racerPlayer[:MudHazard][:AlarmSprite].nil? && !self.withinHazardDetectionRange?(@racerPlayer, @racerPlayer[:MudHazard])
		
	end #def self.monitorUpcomingHazards
	
	def self.createHazardAlarmSprite(racer, hazard)
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
		#Remove Racer's Hazard Alarm of Same Type
		###################################
		self.disposeHazardAlarm(racer, hazard)
		
		#hazard_alarm_rock
		#hazard_alarm_mud
		@sprites["hazard_alarm_#{hazard}_#{number}"] = IconSprite.new(0, 0, @viewport)
		sprite = @sprites["hazard_alarm_#{hazard}_#{number}"]
		sprite.setBitmap("Graphics/Pictures/Crustang Racing/hazard_alarm_#{hazard}")
		sprite.x = Graphics.width - sprite.width
		sprite.z = 99999
		
		if hazard == "rock"
			sprite.y = racer[:RockHazard][:PositionYOnTrack] - 45 + racer[:RockHazard][:Sprite].height/2
			racer[:RockHazard][:AlarmSprite] = sprite
		elsif hazard == "mud"
			sprite.y = racer[:MudHazard][:PositionYOnTrack] - 45 + racer[:MudHazard][:Sprite].height/2
			racer[:MudHazard][:AlarmSprite] = sprite
		end
	end
	
end #class CrustangRacing