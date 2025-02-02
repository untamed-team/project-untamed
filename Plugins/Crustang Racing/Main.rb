SaveData.register(:crustang_racing) do
  save_value { $crustang_racing }
  load_value { |value|  $crustang_racing = value }
  new_game_value { CrustangRacing.new }
end

class CrustangRacing
	attr_accessor :distance_personal_best
	attr_accessor :previous_race_distance

	def initialize
		#create variables
		@distance_personal_best = 0
		@previous_race_distance = 0
	end

	def self.updateOverlayText
		#Laps and Placement
		#@lapsAndPlaceOverlay
		#drawFormattedTextEx(bitmap, x, y, width, text, baseColor = nil, shadowColor = nil, lineheight = 32)
		@lapsAndPlaceOverlay.clear
		if @lastLapCount != @racerPlayer[:LapCount]
			@lastLapCount = @racerPlayer[:LapCount]
			#@lapsAndPlaceOverlay.clear
		end
		if @lastPlacement != @racerPlayer[:CurrentPlacement]
			@lastPlacement = @racerPlayer[:CurrentPlacement]
			#@lapsAndPlaceOverlay.clear
		end
		case @racerPlayer[:CurrentPlacement]
		when 1
			place = "1st"
		when 2
			place = "2nd"
		when 3
			place = "3rd"
		when 4
			place = "4th"
		end
		
		drawFormattedTextEx(@lapsAndPlaceOverlay, 20, 13, Graphics.width, "Place: #{place}", @overlayBaseColor, @overlayShadowColor)
		drawFormattedTextEx(@lapsAndPlaceOverlay, 20, 45, Graphics.width, "Laps: #{@racerPlayer[:LapTotal].round(2)}", @overlayBaseColor, @overlayShadowColor)
		
		#KPH
		if @lastCurrentSpeed != @racerPlayer[:CurrentSpeed].truncate(1).to_f
			#@lastCurrentSpeed = @racerPlayer[:CurrentSpeed].truncate(1).to_f      #draw with a decimal place
			@lastCurrentSpeed = @racerPlayer[:CurrentSpeed].floor     #draw with no decimal place
			@khpOverlay.clear
		end
		
		#drawFormattedTextEx(bitmap, x, y, width, text, baseColor = nil, shadowColor = nil, lineheight = 32)
		drawFormattedTextEx(@khpOverlay, 120, 45, Graphics.width, "KM/H: #{@lastCurrentSpeed*CrustangRacingSettings::KPH_MULTIPLIER}", @overlayBaseColor, @overlayShadowColor)
		
		#draw remaining time in race
		@raceTimerOverlay.clear
		drawFormattedTextEx(@raceTimerOverlay, 120, 13, Graphics.width, "Time: #{@raceRemainingTime}", @overlayBaseColor, @overlayShadowColor)
	end #def self.updateOverlayText
		
	def self.updateAnnouncementsText
		#@announcementsFeed
		if @lastAnnouncementsFeedString != @announcementsFeedString
			#Console.echo_warn "updating announcements feed, clearing overlay"
			@lastAnnouncementsFeedString = @announcementsFeedString
			@announcementsOverlay.clear
			@announcementsOverlay.fill_rect(0, 0, Graphics.width, Graphics.height, Color.black)
		end
		
		drawFormattedTextEx(@announcementsOverlay, 6, 12, Graphics.width, @announcementsFeedString, @overlayBaseColor, @overlayShadowColor) if !@announcementsFeedString.nil?

	end #def self.updateOverlayText
	
	def self.moveMiscSprites
		###################################
		#===== Spin Out Range Sprite =====
		###################################
		@racer1[:SpinOutRangeSprite].x = @racer1[:RacerSprite].x - @racer1[:SpinOutRangeSprite].width / 2 + @racer1[:RacerSprite].width / 2
		@racer1[:SpinOutRangeSprite].y = @racer1[:RacerSprite].y - @racer1[:SpinOutRangeSprite].height / 2 + @racer1[:RacerSprite].height / 2
		@racer2[:SpinOutRangeSprite].x = @racer2[:RacerSprite].x - @racer2[:SpinOutRangeSprite].width / 2 + @racer2[:RacerSprite].width / 2
		@racer2[:SpinOutRangeSprite].y = @racer2[:RacerSprite].y - @racer2[:SpinOutRangeSprite].height / 2 + @racer2[:RacerSprite].height / 2
		@racer3[:SpinOutRangeSprite].x = @racer3[:RacerSprite].x - @racer3[:SpinOutRangeSprite].width / 2 + @racer3[:RacerSprite].width / 2
		@racer3[:SpinOutRangeSprite].y = @racer3[:RacerSprite].y - @racer3[:SpinOutRangeSprite].height / 2 + @racer3[:RacerSprite].height / 2
		@racerPlayer[:SpinOutRangeSprite].x = @racerPlayer[:RacerSprite].x - @racerPlayer[:SpinOutRangeSprite].width / 2 + @racerPlayer[:RacerSprite].width / 2
		@racerPlayer[:SpinOutRangeSprite].y = @racerPlayer[:RacerSprite].y - @racerPlayer[:SpinOutRangeSprite].height / 2 + @racerPlayer[:RacerSprite].height / 2
		
		###################################
		#===== Overload Range Sprite =====
		###################################
		@racer1[:OverloadRangeSprite].x = @racer1[:RacerSprite].x - @racer1[:OverloadRangeSprite].width / 2 + @racer1[:RacerSprite].width / 2
		@racer1[:OverloadRangeSprite].y = @racer1[:RacerSprite].y - @racer1[:OverloadRangeSprite].height / 2 + @racer1[:RacerSprite].height / 2
		@racer2[:OverloadRangeSprite].x = @racer2[:RacerSprite].x - @racer2[:OverloadRangeSprite].width / 2 + @racer2[:RacerSprite].width / 2
		@racer2[:OverloadRangeSprite].y = @racer2[:RacerSprite].y - @racer2[:OverloadRangeSprite].height / 2 + @racer2[:RacerSprite].height / 2
		@racer3[:OverloadRangeSprite].x = @racer3[:RacerSprite].x - @racer3[:OverloadRangeSprite].width / 2 + @racer3[:RacerSprite].width / 2
		@racer3[:OverloadRangeSprite].y = @racer3[:RacerSprite].y - @racer3[:OverloadRangeSprite].height / 2 + @racer3[:RacerSprite].height / 2
		@racerPlayer[:OverloadRangeSprite].x = @racerPlayer[:RacerSprite].x - @racerPlayer[:OverloadRangeSprite].width / 2 + @racerPlayer[:RacerSprite].width / 2
		@racerPlayer[:OverloadRangeSprite].y = @racerPlayer[:RacerSprite].y - @racerPlayer[:OverloadRangeSprite].height / 2 + @racerPlayer[:RacerSprite].height / 2
		
	end #def self.moveMiscSprites
	
	def self.trackMovementUpdate #no need to modify
		@sprites["track1"].x -= @racerPlayer[:CurrentSpeed]
		@sprites["track2"].x -= @racerPlayer[:CurrentSpeed]
		
		#track image looping logic
		#if track2 is now on the screen, track2's X is now 0 or less, and track1's X is still < 0, move track1 to the end of track2 for a loop
		if @sprites["track2"].x <= 0 && @sprites["track1"].x < 0
			@sprites["track1"].x = @sprites["track2"].x
			#send track2 to the back of track1
			@sprites["track2"].x = @sprites["track1"].x + @sprites["track1"].width
		end
		
		#hotfix for track2 not being at the correct X
		if @sprites["track1"].x < @sprites["track1"].width - 500 #just a bullshit number not far from 0
			#move track2 to the end of track1 for good measure
			#YOU GET BACK THERE AT THE END RIGHT THIS INSTANT YOUNG SPRITE
			@sprites["track2"].x = @sprites["track1"].x + @sprites["track1"].width
		end
		
		#bottom of the tracks
		@sprites["track1Bottom"].x = @sprites["track1"].x
		@sprites["track2Bottom"].x = @sprites["track2"].x
		
		#lap line
		@sprites["lapLine"].x = @sprites["track1"].x + @lapLineStartingX
		@sprites["lapLineCopy"].x = @sprites["track2"].x + @lapLineStartingX
	end #def trackMovementUpdate
		
	def self.updateRacerPositionOnTrack
		#this is the position on the entire track, not the track overview
		###################################
		#============= Player =============
		###################################
		@racerPlayer[:PreviousPositionOnTrack] = @racerPlayer[:PositionOnTrack]
		@racerPlayer[:PositionOnTrack] = @sprites["track1"].x.abs

		#calculate the position of the other racers differently than the player. It would involve their X and the X of the track
		###################################
		#============= Racer1 =============
		###################################
		@racer1[:PreviousPositionOnTrack] = @racer1[:PositionOnTrack]
		@racer1[:PositionOnTrack] += @racer1[:CurrentSpeed].floor
		#reset position to near the beginning of the track when we get to the end of it
		if @racer1[:PositionOnTrack] > @sprites["track1"].width
			amountOverTrackLength = @racer1[:PositionOnTrack] - @sprites["track1"].width
			@racer1[:PositionOnTrack] = amountOverTrackLength
		end		
		
		###################################
		#============= Racer2 =============
		###################################
		@racer2[:PreviousPositionOnTrack] = @racer2[:PositionOnTrack]
		@racer2[:PositionOnTrack] += @racer2[:CurrentSpeed].floor
		#reset position to near the beginning of the track when we get to the end of it
		if @racer2[:PositionOnTrack] > @sprites["track1"].width
			amountOverTrackLength = @racer2[:PositionOnTrack] - @sprites["track1"].width
			@racer2[:PositionOnTrack] = amountOverTrackLength
		end		
		
		###################################
		#============= Racer3 =============
		###################################
		@racer3[:PreviousPositionOnTrack] = @racer3[:PositionOnTrack]
		@racer3[:PositionOnTrack] += @racer3[:CurrentSpeed].floor
		#reset position to near the beginning of the track when we get to the end of it
		if @racer3[:PositionOnTrack] > @sprites["track1"].width
			amountOverTrackLength = @racer3[:PositionOnTrack] - @sprites["track1"].width
			@racer3[:PositionOnTrack] = amountOverTrackLength
		end
	end #def self.updateRacerPositionOnTrack
	
	def self.updateRacerPositionOnScreen
		#this is the X on the screen, not the track or track overview
		###################################
		#============= Racer1 =============
		###################################
		#calculate normally based on track1's X
		@racer1[:RacerSprite].x = @sprites["track1"].x + @racerStartingX + @racer1[:PositionOnTrack]
		
		#keep the racer on screen if they reach track2 before we do
		#if track2 is on the screen, and the racer's position on the track is <= the width of track2, set the racer's position on the track relative to track2's x
		if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && @racer1[:PositionOnTrack] <= @sprites["track2"].width
			#make the racer's X relative to track2's x
			@racer1[:RacerSprite].x = @sprites["track2"].x + @racerStartingX + @racer1[:PositionOnTrack]
		end #if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && @racer1[:PositionOnTrack] <= @sprites["track2"].width
		
		#keep the racer on screen if we reach track2 before they do
		if @racer1[:RacerSprite].x > @sprites["track1"].width - @racer1[:RacerSprite].width
			@racer1[:RacerSprite].x -= @sprites["track1"].width
		end
		
		#if the racer's sprite is not on the screen, where is it?
		#print @racer1[:RacerSprite].x if !@racer1[:RacerSprite].x.between?(0-@racer1[:RacerSprite].width,Graphics.width-1)
		
		###################################
		#============= Racer2 =============
		###################################
		#calculate normally based on track1's X
		@racer2[:RacerSprite].x = @sprites["track1"].x + @racerStartingX + @racer2[:PositionOnTrack]
		
		#keep the racer on screen if they reach track2 before we do
		#if track2 is on the screen, and the racer's position on the track is <= the width of track2, set the racer's position on the track relative to track2's x
		if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && @racer2[:PositionOnTrack] <= @sprites["track2"].width
			#make the racer's X relative to track2's x
			@racer2[:RacerSprite].x = @sprites["track2"].x + @racerStartingX + @racer2[:PositionOnTrack]
		end #if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && @racer2[:PositionOnTrack] <= @sprites["track2"].width
		
		#keep the racer on screen if we reach track2 before they do
		if @racer2[:RacerSprite].x > @sprites["track1"].width - @racer2[:RacerSprite].width
			@racer2[:RacerSprite].x -= @sprites["track1"].width
		end
		
		###################################
		#============= Racer3 =============
		###################################
		#calculate normally based on track1's X
		@racer3[:RacerSprite].x = @sprites["track1"].x + @racerStartingX + @racer3[:PositionOnTrack]
		
		#keep the racer on screen if they reach track2 before we do
		#if track2 is on the screen, and the racer's position on the track is <= the width of track2, set the racer's position on the track relative to track2's x
		if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && @racer3[:PositionOnTrack] <= @sprites["track2"].width
			#make the racer's X relative to track2's x
			@racer3[:RacerSprite].x = @sprites["track2"].x + @racerStartingX + @racer3[:PositionOnTrack]
		end #if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && @racer3[:PositionOnTrack] <= @sprites["track2"].width
		
		#keep the racer on screen if we reach track2 before they do
		if @racer3[:RacerSprite].x > @sprites["track1"].width - @racer3[:RacerSprite].width
			@racer3[:RacerSprite].x -= @sprites["track1"].width
		end
	end #def self.updateRacerPositionOnTrack
		
	def self.updateHazardPositionOnScreen
		###################################
		#===== Racer1's Hazards =====
		###################################
		racer = @racer1
		
		#this is the X on the screen, not the track or track overview
		if racer[:RockHazard][:Sprite] && !racer[:RockHazard][:Sprite].disposed?
			#calculate normally based on track1's X
			racer[:RockHazard][:Sprite].x = @sprites["track1"].x + racer[:RockHazard][:PositionXOnTrack] + @racerStartingX

			#keep the hazard on screen
			#if track2 is on the screen, and the hazard's position on the track is <= the width of track2, set the hazard's position on the track relative to track2's x
			if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && racer[:RockHazard][:PositionXOnTrack] <= @sprites["track2"].width
				#make the hazard's X relative to track2's x
				racer[:RockHazard][:Sprite].x = @sprites["track2"].x + racer[:RockHazard][:PositionXOnTrack] + @racerStartingX
			end #if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1)
		
			#keep the hazard on screen if we reach track2
			if racer[:RockHazard][:Sprite].x > @sprites["track1"].width - racer[:RockHazard][:Sprite].width
				racer[:RockHazard][:Sprite].x -= @sprites["track1"].width
			end
		end #if @racer1[:RockHazard][:Sprite] && !@racer1[:RockHazard][:Sprite].disposed?
		
		#this is the X on the screen, not the track or track overview		
		if racer[:MudHazard][:Sprite] && !racer[:MudHazard][:Sprite].disposed?
			#calculate normally based on track1's X
			racer[:MudHazard][:Sprite].x = @sprites["track1"].x + racer[:MudHazard][:PositionXOnTrack] + @racerStartingX
			#keep the hazard on screen
			#if track2 is on the screen, and the hazard's position on the track is <= the width of track2, set the hazard's position on the track relative to track2's x
			if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && racer[:MudHazard][:PositionXOnTrack] <= @sprites["track2"].width
				#make the hazard's X relative to track2's x
				racer[:MudHazard][:Sprite].x = @sprites["track2"].x + racer[:MudHazard][:PositionXOnTrack] + @racerStartingX
			end #if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1)
		
			#keep the hazard on screen if we reach track2
			if racer[:MudHazard][:Sprite].x > @sprites["track1"].width - racer[:MudHazard][:Sprite].width
				racer[:MudHazard][:Sprite].x -= @sprites["track1"].width
			end
		end #if @racer1[:MudHazard][:Sprite] && !@racer1[:MudHazard][:Sprite].disposed?
		
		###################################
		#===== Racer2's Hazards =====
		###################################
		racer = @racer2
		
		#this is the X on the screen, not the track or track overview		
		if racer[:RockHazard][:Sprite] && !racer[:RockHazard][:Sprite].disposed?
			#calculate normally based on track1's X
			racer[:RockHazard][:Sprite].x = @sprites["track1"].x + racer[:RockHazard][:PositionXOnTrack] + @racerStartingX
			#keep the hazard on screen
			#if track2 is on the screen, and the hazard's position on the track is <= the width of track2, set the hazard's position on the track relative to track2's x
			if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && racer[:RockHazard][:PositionXOnTrack] <= @sprites["track2"].width
				#make the hazard's X relative to track2's x
				racer[:RockHazard][:Sprite].x = @sprites["track2"].x + racer[:RockHazard][:PositionXOnTrack] + @racerStartingX
			end #if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1)
		
			#keep the hazard on screen if we reach track2
			if racer[:RockHazard][:Sprite].x > @sprites["track1"].width - racer[:RockHazard][:Sprite].width
				racer[:RockHazard][:Sprite].x -= @sprites["track1"].width
			end
		end #if @racer2[:RockHazard][:Sprite] && !@racer2[:RockHazard][:Sprite].disposed?
		
		#this is the X on the screen, not the track or track overview		
		if racer[:MudHazard][:Sprite] && !racer[:MudHazard][:Sprite].disposed?
			#calculate normally based on track1's X
			racer[:MudHazard][:Sprite].x = @sprites["track1"].x + racer[:MudHazard][:PositionXOnTrack] + @racerStartingX
			#keep the hazard on screen
			#if track2 is on the screen, and the hazard's position on the track is <= the width of track2, set the hazard's position on the track relative to track2's x
			if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && racer[:MudHazard][:PositionXOnTrack] <= @sprites["track2"].width
				#make the hazard's X relative to track2's x
				racer[:MudHazard][:Sprite].x = @sprites["track2"].x + racer[:MudHazard][:PositionXOnTrack] + @racerStartingX
			end #if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1)
		
			#keep the hazard on screen if we reach track2
			if racer[:MudHazard][:Sprite].x > @sprites["track1"].width - racer[:MudHazard][:Sprite].width
				racer[:MudHazard][:Sprite].x -= @sprites["track1"].width
			end
		end #if @racer2[:MudHazard][:Sprite] && !@racer2[:MudHazard][:Sprite].disposed?
		
		###################################
		#===== Racer3's Hazards =====
		###################################
		racer = @racer3
		
		#this is the X on the screen, not the track or track overview		
		if racer[:RockHazard][:Sprite] && !racer[:RockHazard][:Sprite].disposed?
			#calculate normally based on track1's X
			racer[:RockHazard][:Sprite].x = @sprites["track1"].x + racer[:RockHazard][:PositionXOnTrack] + @racerStartingX
			#keep the hazard on screen
			#if track2 is on the screen, and the hazard's position on the track is <= the width of track2, set the hazard's position on the track relative to track2's x
			if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && racer[:RockHazard][:PositionXOnTrack] <= @sprites["track2"].width
				#make the hazard's X relative to track2's x
				racer[:RockHazard][:Sprite].x = @sprites["track2"].x + racer[:RockHazard][:PositionXOnTrack] + @racerStartingX
			end #if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1)
		
			#keep the hazard on screen if we reach track2
			if racer[:RockHazard][:Sprite].x > @sprites["track1"].width - racer[:RockHazard][:Sprite].width
				racer[:RockHazard][:Sprite].x -= @sprites["track1"].width
			end
		end #if @racer3[:RockHazard][:Sprite] && !@racer3[:RockHazard][:Sprite].disposed?
		
		#this is the X on the screen, not the track or track overview		
		if racer[:MudHazard][:Sprite] && !racer[:MudHazard][:Sprite].disposed?
			#calculate normally based on track1's X
			racer[:MudHazard][:Sprite].x = @sprites["track1"].x + racer[:MudHazard][:PositionXOnTrack] + @racerStartingX
			#keep the hazard on screen
			#if track2 is on the screen, and the hazard's position on the track is <= the width of track2, set the hazard's position on the track relative to track2's x
			if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && racer[:MudHazard][:PositionXOnTrack] <= @sprites["track2"].width
				#make the hazard's X relative to track2's x
				racer[:MudHazard][:Sprite].x = @sprites["track2"].x + racer[:MudHazard][:PositionXOnTrack] + @racerStartingX
			end #if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1)
		
			#keep the hazard on screen if we reach track2
			if racer[:MudHazard][:Sprite].x > @sprites["track1"].width - racer[:MudHazard][:Sprite].width
				racer[:MudHazard][:Sprite].x -= @sprites["track1"].width
			end
		end #if @racer3[:MudHazard][:Sprite] && !@racer3[:MudHazard][:Sprite].disposed?
		
		###################################
		#===== RacerPlayer's Hazards =====
		###################################
		racer = @racerPlayer
		
		#this is the X on the screen, not the track or track overview		
		if racer[:RockHazard][:Sprite] && !racer[:RockHazard][:Sprite].disposed?
			#calculate normally based on track1's X
			racer[:RockHazard][:Sprite].x = @sprites["track1"].x + racer[:RockHazard][:PositionXOnTrack] + @racerStartingX
			#keep the hazard on screen
			#if track2 is on the screen, and the hazard's position on the track is <= the width of track2, set the hazard's position on the track relative to track2's x
			if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && racer[:RockHazard][:PositionXOnTrack] <= @sprites["track2"].width
				#make the hazard's X relative to track2's x
				racer[:RockHazard][:Sprite].x = @sprites["track2"].x + racer[:RockHazard][:PositionXOnTrack] + @racerStartingX
			end #if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1)
		
			#keep the hazard on screen if we reach track2
			if racer[:RockHazard][:Sprite].x > @sprites["track1"].width - racer[:RockHazard][:Sprite].width
				racer[:RockHazard][:Sprite].x -= @sprites["track1"].width
			end
		end #if @racerPlayer[:RockHazard][:Sprite] && !@racerPlayer[:RockHazard][:Sprite].disposed?
		
		#this is the X on the screen, not the track or track overview		
		if racer[:MudHazard][:Sprite] && !racer[:MudHazard][:Sprite].disposed?
			#calculate normally based on track1's X
			racer[:MudHazard][:Sprite].x = @sprites["track1"].x + racer[:MudHazard][:PositionXOnTrack] + @racerStartingX
			#keep the hazard on screen
			#if track2 is on the screen, and the hazard's position on the track is <= the width of track2, set the hazard's position on the track relative to track2's x
			if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && racer[:MudHazard][:PositionXOnTrack] <= @sprites["track2"].width
				#make the hazard's X relative to track2's x
				racer[:MudHazard][:Sprite].x = @sprites["track2"].x + racer[:MudHazard][:PositionXOnTrack] + @racerStartingX
			end #if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1)
		
			#keep the hazard on screen if we reach track2
			if racer[:MudHazard][:Sprite].x > @sprites["track1"].width - racer[:MudHazard][:Sprite].width
				racer[:MudHazard][:Sprite].x -= @sprites["track1"].width
			end
		end #if @racerPlayer[:MudHazard][:Sprite] && !@racerPlayer[:MudHazard][:Sprite].disposed?
		
	end #def self.updateHazardPositionOnScreen
	
	def self.updateRockyPatchPositionOnScreen
		#for i in 0...@rockyPatches.length
		#	print @rockyPatches[i].x
		#end
		
		for i in 0...@rockyPatches.length
			sprite = @rockyPatches[i][0]
			positionXOnTrack = @rockyPatches[i][1]
		
			#calculate normally based on track1's X
			sprite.x = @sprites["track1"].x + positionXOnTrack + @racerStartingX

			#keep the patch on screen
			#if track2 is on the screen, and the patch's position on the track is <= the width of track2, set the patch's position on the track relative to track2's x
			if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && positionXOnTrack <= @sprites["track2"].width
				#make the patch's X relative to track2's x
				sprite.x = @sprites["track2"].x + positionXOnTrack + @racerStartingX
			end #if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1)
		
			#keep the patch on screen if we reach track2
			if sprite.x > @sprites["track1"].width - sprite.width
				sprite.x -= @sprites["track1"].width
			end
		end #for i in 0...@rockyPatches.length
	end #def self.updateRockyPatchPositionOnScreen

	def self.accelerateDecelerate
		###################################
		#============= Racer1 =============
		###################################
		@racer1[:DesiredSpeed] = CrustangRacingSettings::TOP_BASE_SPEED if @racer1[:BoostingStatus] != true && @racer1[:Bumped] != true && @racer1[:SpinOutTimer] <= 0
		@racer1[:DesiredSpeed] = 0 if @raceEnded
		
		if @racer1[:BoostingStatus] == true #boosting
			if @racer1[:CurrentSpeed].floor < @racer1[:DesiredSpeed]
				#accelerate
				@racer1[:CurrentSpeed] += CrustangRacingSettings::TOP_BASE_SPEED.to_f / (CrustangRacingSettings::SECONDS_TO_REACH_BOOST_SPEED.to_f * Graphics.frame_rate.to_f)
			end
		else #not boosting
			#accelerate
			if @racer1[:CurrentSpeed].floor < @racer1[:DesiredSpeed]
				@racer1[:CurrentSpeed] += CrustangRacingSettings::TOP_BASE_SPEED.to_f / (CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED.to_f * Graphics.frame_rate.to_f)
			end
		end
		
		#decelerate
		if @racer1[:CurrentSpeed].floor > @racer1[:DesiredSpeed]
			@racer1[:CurrentSpeed] -= @racer1[:PreviousDesiredSpeed] / (CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED.to_f * Graphics.frame_rate.to_f)
			@racer1[:CurrentSpeed] -= @racer1[:PreviousDesiredSpeed] / (CrustangRacingSettings::SECONDS_TO_STOP_AT_END.to_f * Graphics.frame_rate.to_f) if @raceEnded
		end
		
		#after speeding up or slowing down, if the floor of the current speed is exactly the desired speed, set the current speed to its floor
		if @racer1[:CurrentSpeed].floor == @racer1[:DesiredSpeed]
			@racer1[:CurrentSpeed] = @racer1[:CurrentSpeed].floor
		end
		
		#strafe speed
		@racer1[:StrafeSpeed] = CrustangRacingSettings::BOOSTED_STRAFE_SPEED if @racer1[:BoostingStatus] == true
		#prioritize being slowed by overload rather than speeding up strafe while boosting
		@racer1[:StrafeSpeed] = CrustangRacingSettings::OVERLOADED_STRAFE_SPEED if @racer1[:Overloaded] == true
		@racer1[:StrafeSpeed] = CrustangRacingSettings::BASE_STRAFE_SPEED if @racer1[:Overloaded] != true && @racer1[:BoostingStatus] != true
		
		###################################
		#============= Racer2 =============
		###################################
		@racer2[:DesiredSpeed] = CrustangRacingSettings::TOP_BASE_SPEED if @racer2[:BoostingStatus] != true && @racer2[:Bumped] != true && @racer2[:SpinOutTimer] <= 0
		@racer2[:DesiredSpeed] = 0 if @raceEnded
		
		if @racer2[:BoostingStatus] == true #boosting
			if @racer2[:CurrentSpeed].floor < @racer2[:DesiredSpeed]
				#accelerate
				@racer2[:CurrentSpeed] += CrustangRacingSettings::TOP_BASE_SPEED.to_f / (CrustangRacingSettings::SECONDS_TO_REACH_BOOST_SPEED.to_f * Graphics.frame_rate.to_f)
			end
		else #not boosting
			#accelerate
			if @racer2[:CurrentSpeed].floor < @racer2[:DesiredSpeed]
				@racer2[:CurrentSpeed] += CrustangRacingSettings::TOP_BASE_SPEED.to_f / (CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED.to_f * Graphics.frame_rate.to_f)
			end
		end
		
		#decelerate
		if @racer2[:CurrentSpeed].floor > @racer2[:DesiredSpeed]
			@racer2[:CurrentSpeed] -= @racer2[:PreviousDesiredSpeed] / (CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED.to_f * Graphics.frame_rate.to_f)
			@racer2[:CurrentSpeed] -= @racer2[:PreviousDesiredSpeed] / (CrustangRacingSettings::SECONDS_TO_STOP_AT_END.to_f * Graphics.frame_rate.to_f) if @raceEnded
		end
		
		#after speeding up or slowing down, if the floor of the current speed is exactly the desired speed, set the current speed to its floor
		if @racer2[:CurrentSpeed].floor == @racer2[:DesiredSpeed]
			@racer2[:CurrentSpeed] = @racer2[:CurrentSpeed].floor
		end
		
		#strafe speed
		@racer2[:StrafeSpeed] = CrustangRacingSettings::BOOSTED_STRAFE_SPEED if @racer2[:BoostingStatus] == true
		#prioritize being slowed by overload rather than speeding up strafe while boosting
		@racer2[:StrafeSpeed] = CrustangRacingSettings::OVERLOADED_STRAFE_SPEED if @racer2[:Overloaded] == true
		@racer2[:StrafeSpeed] = CrustangRacingSettings::BASE_STRAFE_SPEED if @racer2[:Overloaded] != true && @racer2[:BoostingStatus] != true
		
		###################################
		#============= Racer3 =============
		###################################
		@racer3[:DesiredSpeed] = CrustangRacingSettings::TOP_BASE_SPEED if @racer3[:BoostingStatus] != true && @racer3[:Bumped] != true && @racer3[:SpinOutTimer] <= 0
		@racer3[:DesiredSpeed] = 0 if @raceEnded
		
		if @racer3[:BoostingStatus] == true #boosting
			if @racer3[:CurrentSpeed].floor < @racer3[:DesiredSpeed]
				#accelerate
				@racer3[:CurrentSpeed] += CrustangRacingSettings::TOP_BASE_SPEED.to_f / (CrustangRacingSettings::SECONDS_TO_REACH_BOOST_SPEED.to_f * Graphics.frame_rate.to_f)
			end
		else #not boosting
			#accelerate
			if @racer3[:CurrentSpeed].floor < @racer3[:DesiredSpeed]
				@racer3[:CurrentSpeed] += CrustangRacingSettings::TOP_BASE_SPEED.to_f / (CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED.to_f * Graphics.frame_rate.to_f)
			end
		end
		
		#decelerate
		if @racer3[:CurrentSpeed].floor > @racer3[:DesiredSpeed]
			@racer3[:CurrentSpeed] -= @racer3[:PreviousDesiredSpeed] / (CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED.to_f * Graphics.frame_rate.to_f)
			@racer3[:CurrentSpeed] -= @racer3[:PreviousDesiredSpeed] / (CrustangRacingSettings::SECONDS_TO_STOP_AT_END.to_f * Graphics.frame_rate.to_f) if @raceEnded
		end
		
		#after speeding up or slowing down, if the floor of the current speed is exactly the desired speed, set the current speed to its floor
		if @racer3[:CurrentSpeed].floor == @racer3[:DesiredSpeed]
			@racer3[:CurrentSpeed] = @racer3[:CurrentSpeed].floor
		end
		
		#strafe speed
		@racer3[:StrafeSpeed] = CrustangRacingSettings::BOOSTED_STRAFE_SPEED if @racer3[:BoostingStatus] == true
		#prioritize being slowed by overload rather than speeding up strafe while boosting
		@racer3[:StrafeSpeed] = CrustangRacingSettings::OVERLOADED_STRAFE_SPEED if @racer3[:Overloaded] == true
		@racer3[:StrafeSpeed] = CrustangRacingSettings::BASE_STRAFE_SPEED if @racer3[:Overloaded] != true && @racer1[:BoostingStatus] != true
		
		###################################
		#============= Player =============
		###################################
		@racerPlayer[:DesiredSpeed] = CrustangRacingSettings::TOP_BASE_SPEED if @racerPlayer[:BoostingStatus] != true && @racerPlayer[:Bumped] != true && @racerPlayer[:SpinOutTimer] <= 0
		@racerPlayer[:DesiredSpeed] = 0 if @raceEnded
		
		if @racerPlayer[:BoostingStatus] == true #boosting
			if @racerPlayer[:CurrentSpeed].floor < @racerPlayer[:DesiredSpeed]
				#accelerate
				@racerPlayer[:CurrentSpeed] += CrustangRacingSettings::TOP_BASE_SPEED.to_f / (CrustangRacingSettings::SECONDS_TO_REACH_BOOST_SPEED.to_f * Graphics.frame_rate.to_f)
			end
		else #not boosting and not recovering from bump
			#accelerate
			if @racerPlayer[:CurrentSpeed].floor < @racerPlayer[:DesiredSpeed]
				@racerPlayer[:CurrentSpeed] += CrustangRacingSettings::TOP_BASE_SPEED.to_f / (CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED.to_f * Graphics.frame_rate.to_f)
			end
		end
		
		#decelerate
		if @racerPlayer[:CurrentSpeed].floor > @racerPlayer[:DesiredSpeed]
			@racerPlayer[:CurrentSpeed] -= @racerPlayer[:PreviousDesiredSpeed] / (CrustangRacingSettings::SECONDS_TO_NORMALIZE_SPEED.to_f * Graphics.frame_rate.to_f)
			@racerPlayer[:CurrentSpeed] -= @racerPlayer[:PreviousDesiredSpeed] / (CrustangRacingSettings::SECONDS_TO_STOP_AT_END.to_f * Graphics.frame_rate.to_f) if @raceEnded
		end
		
		#after speeding up or slowing down, if the floor of the current speed is exactly the desired speed, set the current speed to its floor
		if @racerPlayer[:CurrentSpeed].floor == @racerPlayer[:DesiredSpeed]
			@racerPlayer[:CurrentSpeed] = @racerPlayer[:CurrentSpeed].floor
		end
		
		#strafe speed
		@racerPlayer[:StrafeSpeed] = CrustangRacingSettings::BOOSTED_STRAFE_SPEED if @racerPlayer[:BoostingStatus] == true
		#prioritize being slowed by overload rather than speeding up strafe while boosting
		@racerPlayer[:StrafeSpeed] = CrustangRacingSettings::OVERLOADED_STRAFE_SPEED if @racerPlayer[:Overloaded] == true
		@racerPlayer[:StrafeSpeed] = CrustangRacingSettings::BASE_STRAFE_SPEED if @racerPlayer[:Overloaded] != true && @racerPlayer[:BoostingStatus] != true
		
	end #def self.accelerateDecelerate
	
	def self.bumpedIntoSomeone(racerBehind, racerInFront)
		#play SE for collision if on screen
		if (self.racerOnScreen?(racerBehind) || self.racerOnScreen?(racerInFront)) && @currentlyPlayingSE != CrustangRacingSettings::COLLISION_SE
			pbSEPlay(CrustangRacingSettings::COLLISION_SE)
			@currentlyPlayingSE = CrustangRacingSettings::COLLISION_SE
			CrustangRacingSettings::SE_SPAM_PREVENTION_WAIT_IN_SECONDS * Graphics.frame_rate
		end
		
		racerBehind[:Bumped] = true
		racerBehind[:BumpedRecoveryTimer] = Graphics.frame_rate * CrustangRacingSettings::SECONDS_TO_RECOVER_FROM_BUMP
		racerInFront[:Bumped] = true
		racerInFront[:BumpedRecoveryTimer] = Graphics.frame_rate * CrustangRacingSettings::SECONDS_TO_RECOVER_FROM_BUMP
		
		#the racer in behind should immediately go the same speed as the racer they bumped into in front of them
		racerBehind[:PreviousDesiredSpeed] = racerBehind[:DesiredSpeed]
		racerBehind[:DesiredSpeed] = racerInFront[:CurrentSpeed] if racerBehind[:DesiredSpeed] >= racerInFront[:CurrentSpeed]
		racerBehind[:CurrentSpeed] = racerInFront[:CurrentSpeed] if racerBehind[:CurrentSpeed] >= racerInFront[:CurrentSpeed]
		#the racer in front should immediately stop slowing down if they were spinning out, but they should not stop gaining speed if they were in the middle of gaining speed
		racerInFront[:CurrentSpeed] += 3
	
	end #def self.bumpedIntoSomeone
	
	def self.countdownToGo
		#wait
		waitTimer = Graphics.frame_rate
		loop do
			Graphics.update
			pbUpdateSpriteHash(@sprites)
			#subtract from waitTimer
			waitTimer -= 1
			break if waitTimer <= 0
		end #loop do
		
		#play countdown sound
		pbBGMPlay(CrustangRacingSettings::TRACK_COUNTDOWN_BGM, 200)
		
		@countdownTimerLengthBetween = Graphics.frame_rate * 2
		countdownTimer = 3
		3.times do
			waitTimer = @countdownTimerLengthBetween
			loop do
				Graphics.update
				pbUpdateSpriteHash(@sprites)
				#subtract from waitTimer
				waitTimer -= 1
				break if waitTimer <= 0
			end #loop do
			Graphics.update
			pbUpdateSpriteHash(@sprites)
			@countdownGOOverlay.clear
			drawFormattedTextEx(@countdownGOOverlay, Graphics.width/2 -10, Graphics.height/2 -60, Graphics.width, "#{countdownTimer}", @overlayBaseColor, @overlayShadowColor)
			countdownTimer -= 1
		end #3.times do
		
		#wait
		waitTimer = @countdownTimerLengthBetween
		loop do
			Graphics.update
			pbUpdateSpriteHash(@sprites)
			#subtract from waitTimer
			waitTimer -= 1
			break if waitTimer <= 0
		end #loop do
		
		#display GO
		@countdownGOOverlay.clear
		drawFormattedTextEx(@countdownGOOverlay, Graphics.width/2 -26, Graphics.height/2 -60, Graphics.width, "GO", @overlayBaseColor, @overlayShadowColor)
		
		#wait
		waitTimer = @countdownTimerLengthBetween + 10
		loop do
			Graphics.update
			pbUpdateSpriteHash(@sprites)
			#subtract from waitTimer
			waitTimer -= 1
			break if waitTimer <= 0
		end #loop do
		
		@countingDownGoTimer = false
		@countdownGOOverlay.clear
		
		#play full music track
		pbBGMPlay(CrustangRacingSettings::TRACK_BGM, 200)
	end
	
	def self.main(enteredCrustang)
		#remember Ferrera music
		@playingBGM = $game_system.getPlayingBGM
		$game_system.bgm_pause		
		pbBGMFade(0.8)
	
		@enteredCrustang = enteredCrustang
		self.setup
		self.setupRacerHashes
		self.drawContestants
		self.drawContestantsOnOverview
		self.assignMoveEffects
		self.drawMovesUI
		self.setMiscVariables
		self.moveMiscSprites
		self.updateHazardPositionOnScreen
		self.updateRockyPatchPositionOnScreen
		self.trackOverviewMovementUpdate
		self.updateOverlayText

		loop do
			Graphics.update
			pbUpdateSpriteHash(@sprites)
			
			self.countdownToGo if @countingDownGoTimer != false
			
			self.trackMovementUpdate #keep this as high up in the loop as possible below Graphics updates
			self.moveMiscSprites
			self.updateRacerPositionOnTrack
			self.updateRacerPositionOnScreen
			self.updateHazardPositionOnScreen
			self.updateRockyPatchPositionOnScreen
			self.trackOverviewMovementUpdate
			self.detectInput if @racerPlayer[:SpinOutTimer] <= 0
			self.updateTimers
			self.accelerateDecelerate
			self.checkForCollisions(@racer1)
			self.checkForCollisions(@racer2)
			self.checkForCollisions(@racer3)
			self.checkForCollisions(@racerPlayer)
			self.updateSpinOutAnimation
			self.updateRacerPlacement
			self.updateOverlayText
			self.checkForLap
			self.updateRacerTotalLaps
			self.updateSpinOutRangeSprites
			self.updateOverloadRangeSprites
			self.updateRacerHue
			self.monitorUpcomingHazards
			self.updateAnnouncementsText
			
			###################################
			#=============== AI ===============
			###################################
			self.aiAvoidObstacles
			self.aiWanderStrafe
			
			#AI - the order in which these methods run determines what types of moves the AI will prioritize using when available
			self.aiStrafeTowardTarget
			self.aiChargeSpinOutMove #this monitors for AIs using spin out
			self.aiChargeOverloadMove #this monitors for AIs using overload
			
			#priority of AI using moves
			self.aiLookForOpportunityToUseBoost #primary boost
			self.aiLookForOpportunityToUseSecondBoost #secondBoost / stabilize
			self.aiLookForOpportunityToUseReduceCooldown #reduceCooldown
			self.aiTargetAnotherRacer #spinOut and overload
			self.aiLookForOpportunityToUseRockHazard #rock hazard
			self.aiLookForOpportunityToUseMudHazard #mud hazard
			self.aiLookForOpportunityToUseInvincibility #invincibility

			break if @raceEnded
		end
		self.endRace
	end #def self.main
	
	def self.pbEndScene
		# Hide all sprites with FadeOut effect.
		pbFadeOutAndHide(@sprites) { pbUpdateSpriteHash(@sprites) }
		# Remove all sprites.
		pbDisposeSpriteHash(@sprites)
		# Remove the viewpoint.
		@viewport.dispose
	end
	
	def self.endRace
		pbSEStop
		pbSEPlay("Whistle Blow")
		pbBGMFade(CrustangRacingSettings::SECONDS_TO_STOP_AT_END)
		#slow down Crustang
		@racer1[:DesiredSpeed] = 0
		@racer2[:DesiredSpeed] = 0
		@racer3[:DesiredSpeed] = 0
		@racerPlayer[:DesiredSpeed] = 0
		
		loop do
			Graphics.update
			pbUpdateSpriteHash(@sprites)
			#$game_system.update #for fading the audio
			
			self.trackMovementUpdate #keep this as high up in the loop as possible below Graphics updates
			self.moveMiscSprites
			self.updateRacerPositionOnTrack
			self.updateRacerPositionOnScreen
			self.updateHazardPositionOnScreen
			self.updateRockyPatchPositionOnScreen
			self.trackOverviewMovementUpdate
			self.updateTimers
			self.accelerateDecelerate
			self.checkForCollisions(@racer1)
			self.checkForCollisions(@racer2)
			self.checkForCollisions(@racer3)
			self.checkForCollisions(@racerPlayer)
			self.updateSpinOutAnimation
			#self.updateRacerPlacement
			#self.updateOverlayText
			#self.checkForLap
			#self.updateRacerTotalLaps
			self.updateSpinOutRangeSprites
			self.updateOverloadRangeSprites
			self.updateRacerHue
			#self.monitorUpcomingHazards
			#self.updateAnnouncementsText
			
			break if @racerPlayer[:CurrentSpeed] <= 0
		end
		
		#save race details in Player data
		$crustang_racing.previous_race_distance = @racerPlayer[:LapTotal]
		
		self.pbEndScene
		$game_system.bgm_resume(@playingBGM)
		
		#after the scene has ended and we are back on the map from before the race started
		self.givePrize
		
		pbDiscardInstanceVariables
	end #def self.endRace
end #class CrustangRacing