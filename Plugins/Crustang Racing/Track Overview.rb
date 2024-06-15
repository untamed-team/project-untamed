class CrustangRacing
	
	def self.drawContestantsOnOverview
		#draw the racer's sprite over on the track overview (box sprite)
		###################################
		#============= Racer1 =============
		###################################
		pokemon = Pokemon.new(:LILORINA, 1)
		@sprites["racer1PkmnOverview"] = PokemonBoxIcon.new(pokemon, @viewport)
        @sprites["racer1PkmnOverview"].x = @trackEllipsesPoints[0][0] - @sprites["racer1PkmnOverview"].width/4
        @sprites["racer1PkmnOverview"].y = @trackEllipsesPoints[0][1] - @sprites["racer1PkmnOverview"].height/4
		@sprites["racer1PkmnOverview"].z = 99999
		@sprites["racer1PkmnOverview"].zoom_x = 0.5
		@sprites["racer1PkmnOverview"].zoom_y = 0.5
		@racer1[:RacerTrackOverviewSprite] = @sprites["racer1PkmnOverview"]
		
		###################################
		#============= Racer2 =============
		###################################
		pokemon = Pokemon.new(:LILORINA, 1)
		@sprites["racer2PkmnOverview"] = PokemonBoxIcon.new(pokemon, @viewport)
        @sprites["racer2PkmnOverview"].x = @trackEllipsesPoints[0][0] - @sprites["racer2PkmnOverview"].width/4
        @sprites["racer2PkmnOverview"].y = @trackEllipsesPoints[0][1] - @sprites["racer2PkmnOverview"].height/4
		@sprites["racer2PkmnOverview"].z = 99999
		@sprites["racer2PkmnOverview"].zoom_x = 0.5
		@sprites["racer2PkmnOverview"].zoom_y = 0.5
		@racer2[:RacerTrackOverviewSprite] = @sprites["racer2PkmnOverview"]
		
		###################################
		#============= Racer3 =============
		###################################
		pokemon = Pokemon.new(:LILORINA, 1)
		@sprites["racer3PkmnOverview"] = PokemonBoxIcon.new(pokemon, @viewport)
        @sprites["racer3PkmnOverview"].x = @trackEllipsesPoints[0][0] - @sprites["racer3PkmnOverview"].width/4
        @sprites["racer3PkmnOverview"].y = @trackEllipsesPoints[0][1] - @sprites["racer3PkmnOverview"].height/4
		@sprites["racer3PkmnOverview"].z = 99999
		@sprites["racer3PkmnOverview"].zoom_x = 0.5
		@sprites["racer3PkmnOverview"].zoom_y = 0.5
		@racer3[:RacerTrackOverviewSprite] = @sprites["racer3PkmnOverview"]
		
		###################################
		#============= Player =============
		###################################
		pokemon = Pokemon.new(:BATHYGIGAS, 1)
		@sprites["racerPlayerPkmnOverview"] = PokemonBoxIcon.new(pokemon, @viewport)
        @sprites["racerPlayerPkmnOverview"].x = @trackEllipsesPoints[0][0] - @sprites["racerPlayerPkmnOverview"].width/4
        @sprites["racerPlayerPkmnOverview"].y = @trackEllipsesPoints[0][1] - @sprites["racerPlayerPkmnOverview"].height/4
		@sprites["racerPlayerPkmnOverview"].z = 99999
		@sprites["racerPlayerPkmnOverview"].zoom_x = 0.5
		@sprites["racerPlayerPkmnOverview"].zoom_y = 0.5
		@racerPlayer[:RacerTrackOverviewSprite] = @sprites["racerPlayerPkmnOverview"]
	end #def self.drawContestantsOnOverview
	
	def self.trackOverviewMovementUpdate	
		###################################
		#============= Racer1 =============
		###################################
		#racer point on overview
		@racer1[:PointOnTrackOverview] = (@racer1[:PositionOnTrack] / @trackDistanceBetweenPoints).floor
		#get the amount of pixels past the point we are at on the overview
		remainder = @racer1[:PositionOnTrack] % @trackDistanceBetweenPoints
		#get the percentage we have traveled into the point, 100% being when we reach the next point
		percentageIntoCurrentPoint = remainder.percent_of(@trackDistanceBetweenPoints)
		percentageIntoCurrentPoint = percentageIntoCurrentPoint / 100
		
		if @racer1[:PointOnTrackOverview] >= @trackEllipsesPoints.length
			@racer1[:PointOnTrackOverview] = 0
		end
		
		if @racer1[:PointOnTrackOverview] >= @trackEllipsesPoints.length-1
			nextPoint = @trackEllipsesPoints[0]
		else
			nextPoint = @trackEllipsesPoints[@racer1[:PointOnTrackOverview]+1]
		end
		
		#how many pixels in distance is it on the X axis between this point and the next one coming up?
		if @trackEllipsesPoints[@racer1[:PointOnTrackOverview]].nil?
			print "trackEllipsesPoints is #{@trackEllipsesPoints}, racer1 pointOnTrackOverview is #{@racer1[:PointOnTrackOverview]}, and @trackEllipsesPoints[@racer1[:PointOnTrackOverview]] is  #{@trackEllipsesPoints[@racer1[:PointOnTrackOverview]]}"
			distanceBetweenPixelsX = (@trackEllipsesPoints[@racer1[:PointOnTrackOverview]-1][0] - nextPoint[0]).abs
			distanceBetweenPixelsY = (@trackEllipsesPoints[@racer1[:PointOnTrackOverview]-1][1] - nextPoint[1]).abs
			overflowProtectionPointOnTrack = @trackEllipsesPoints[@racer1[:PointOnTrackOverview]-1]
		else
			distanceBetweenPixelsX = (@trackEllipsesPoints[@racer1[:PointOnTrackOverview]][0] - nextPoint[0]).abs
			distanceBetweenPixelsY = (@trackEllipsesPoints[@racer1[:PointOnTrackOverview]][1] - nextPoint[1]).abs
			overflowProtectionPointOnTrack = @trackEllipsesPoints[@racer1[:PointOnTrackOverview]]
		end
		
		#how many pixels away are we on the overview from the current point e.g. @racer1[:PointOnTrackOverview]
		pixelsAwayFromCurrentPointX = distanceBetweenPixelsX * percentageIntoCurrentPoint
		pixelsAwayFromCurrentPointY = distanceBetweenPixelsY * percentageIntoCurrentPoint
		#calculate whether we need to increase X or decrease X for the overview icon sprite
		if @trackEllipsesPoints[@racer1[:PointOnTrackOverview]][0] > nextPoint[0]
			#decrease X
			currentOverviewX = @trackEllipsesPoints[@racer1[:PointOnTrackOverview]][0] - (pixelsAwayFromCurrentPointX.floor)
		elsif @trackEllipsesPoints[@racer1[:PointOnTrackOverview]][0] < nextPoint[0]
			#increase X
			currentOverviewX = @trackEllipsesPoints[@racer1[:PointOnTrackOverview]][0] + (pixelsAwayFromCurrentPointX.floor)
		end
		
		#calculate whether we need to increase Y or decrease Y for the overview icon sprite
		if @trackEllipsesPoints[@racer1[:PointOnTrackOverview]][1] > nextPoint[1]
			#decrease Y
			currentOverviewY = @trackEllipsesPoints[@racer1[:PointOnTrackOverview]][1] - (pixelsAwayFromCurrentPointY.floor)
		elsif @trackEllipsesPoints[@racer1[:PointOnTrackOverview]][1] < nextPoint[1]
			#increase Y
			currentOverviewY = @trackEllipsesPoints[@racer1[:PointOnTrackOverview]][1] + (pixelsAwayFromCurrentPointY.floor)
		end	
		@racer1[:PositionXOnTrackOverview] = currentOverviewX - @sprites["racer1PkmnOverview"].width/4
		@racer1[:PositionYOnTrackOverview] = currentOverviewY - @sprites["racer1PkmnOverview"].height/4
		#put the overview icon sprite where it should be
		#print @sprites["racer1PkmnOverview"].x if @racer1[:PointOnTrackOverview] == 0
		@sprites["racer1PkmnOverview"].x = @racer1[:PositionXOnTrackOverview]
		@sprites["racer1PkmnOverview"].y = @racer1[:PositionYOnTrackOverview]
		
		###################################
		#============= Racer2 =============
		###################################
		#racer point on overview
		@racer2[:PointOnTrackOverview] = (@racer2[:PositionOnTrack] / @trackDistanceBetweenPoints).floor
		#get the amount of pixels past the point we are at on the overview
		remainder = @racer2[:PositionOnTrack] % @trackDistanceBetweenPoints
		#get the percentage we have traveled into the point, 100% being when we reach the next point
		percentageIntoCurrentPoint = remainder.percent_of(@trackDistanceBetweenPoints)
		percentageIntoCurrentPoint = percentageIntoCurrentPoint / 100
		
		if @racer2[:PointOnTrackOverview] >= @trackEllipsesPoints.length
			@racer2[:PointOnTrackOverview] = 0
		end
		
		if @racer2[:PointOnTrackOverview] >= @trackEllipsesPoints.length-1
			nextPoint = @trackEllipsesPoints[0]
		else
			nextPoint = @trackEllipsesPoints[@racer2[:PointOnTrackOverview]+1]
		end
		
		#how many pixels in distance is it on the X axis between this point and the next one coming up?
		if @trackEllipsesPoints[@racer2[:PointOnTrackOverview]].nil?
			print "trackEllipsesPoints is #{@trackEllipsesPoints}, racer2 pointOnTrackOverview is #{@racer2[:PointOnTrackOverview]}, and @trackEllipsesPoints[@racer2[:PointOnTrackOverview]] is  #{@trackEllipsesPoints[@racer2[:PointOnTrackOverview]]}"
			distanceBetweenPixelsX = (@trackEllipsesPoints[@racer2[:PointOnTrackOverview]-1][0] - nextPoint[0]).abs
			distanceBetweenPixelsY = (@trackEllipsesPoints[@racer2[:PointOnTrackOverview]-1][1] - nextPoint[1]).abs
			overflowProtectionPointOnTrack = @trackEllipsesPoints[@racer2[:PointOnTrackOverview]-1]
		else
			distanceBetweenPixelsX = (@trackEllipsesPoints[@racer2[:PointOnTrackOverview]][0] - nextPoint[0]).abs
			distanceBetweenPixelsY = (@trackEllipsesPoints[@racer2[:PointOnTrackOverview]][1] - nextPoint[1]).abs
			overflowProtectionPointOnTrack = @trackEllipsesPoints[@racer2[:PointOnTrackOverview]]
		end
		
		#how many pixels away are we on the overview from the current point e.g. @racer2[:PointOnTrackOverview]
		pixelsAwayFromCurrentPointX = distanceBetweenPixelsX * percentageIntoCurrentPoint
		pixelsAwayFromCurrentPointY = distanceBetweenPixelsY * percentageIntoCurrentPoint
		#calculate whether we need to increase X or decrease X for the overview icon sprite
		if @trackEllipsesPoints[@racer2[:PointOnTrackOverview]][0] > nextPoint[0]
			#decrease X
			currentOverviewX = @trackEllipsesPoints[@racer2[:PointOnTrackOverview]][0] - (pixelsAwayFromCurrentPointX.floor)
		elsif @trackEllipsesPoints[@racer2[:PointOnTrackOverview]][0] < nextPoint[0]
			#increase X
			currentOverviewX = @trackEllipsesPoints[@racer2[:PointOnTrackOverview]][0] + (pixelsAwayFromCurrentPointX.floor)
		end
		
		#calculate whether we need to increase Y or decrease Y for the overview icon sprite
		if @trackEllipsesPoints[@racer2[:PointOnTrackOverview]][1] > nextPoint[1]
			#decrease Y
			currentOverviewY = @trackEllipsesPoints[@racer2[:PointOnTrackOverview]][1] - (pixelsAwayFromCurrentPointY.floor)
		elsif @trackEllipsesPoints[@racer2[:PointOnTrackOverview]][1] < nextPoint[1]
			#increase Y
			currentOverviewY = @trackEllipsesPoints[@racer2[:PointOnTrackOverview]][1] + (pixelsAwayFromCurrentPointY.floor)
		end	
		@racer2[:PositionXOnTrackOverview] = currentOverviewX - @sprites["racer2PkmnOverview"].width/4
		@racer2[:PositionYOnTrackOverview] = currentOverviewY - @sprites["racer2PkmnOverview"].height/4
		#put the overview icon sprite where it should be
		#print @sprites["racer2PkmnOverview"].x if @racer2[:PointOnTrackOverview] == 0
		@sprites["racer2PkmnOverview"].x = @racer2[:PositionXOnTrackOverview]
		@sprites["racer2PkmnOverview"].y = @racer2[:PositionYOnTrackOverview]
		
		###################################
		#============= Racer3 =============
		###################################
		#racer point on overview
		@racer3[:PointOnTrackOverview] = (@racer3[:PositionOnTrack] / @trackDistanceBetweenPoints).floor
		#get the amount of pixels past the point we are at on the overview
		remainder = @racer3[:PositionOnTrack] % @trackDistanceBetweenPoints
		#get the percentage we have traveled into the point, 100% being when we reach the next point
		percentageIntoCurrentPoint = remainder.percent_of(@trackDistanceBetweenPoints)
		percentageIntoCurrentPoint = percentageIntoCurrentPoint / 100
		
		if @racer3[:PointOnTrackOverview] >= @trackEllipsesPoints.length
			@racer3[:PointOnTrackOverview] = 0
		end
		
		if @racer3[:PointOnTrackOverview] >= @trackEllipsesPoints.length-1
			nextPoint = @trackEllipsesPoints[0]
		else
			nextPoint = @trackEllipsesPoints[@racer3[:PointOnTrackOverview]+1]
		end
		
		#how many pixels in distance is it on the X axis between this point and the next one coming up?
		if @trackEllipsesPoints[@racer3[:PointOnTrackOverview]].nil?
			print "trackEllipsesPoints is #{@trackEllipsesPoints}, racer3 pointOnTrackOverview is #{@racer3[:PointOnTrackOverview]}, and @trackEllipsesPoints[@racer3[:PointOnTrackOverview]] is  #{@trackEllipsesPoints[@racer3[:PointOnTrackOverview]]}"
			distanceBetweenPixelsX = (@trackEllipsesPoints[@racer3[:PointOnTrackOverview]-1][0] - nextPoint[0]).abs
			distanceBetweenPixelsY = (@trackEllipsesPoints[@racer3[:PointOnTrackOverview]-1][1] - nextPoint[1]).abs
			overflowProtectionPointOnTrack = @trackEllipsesPoints[@racer3[:PointOnTrackOverview]-1]
		else
			distanceBetweenPixelsX = (@trackEllipsesPoints[@racer3[:PointOnTrackOverview]][0] - nextPoint[0]).abs
			distanceBetweenPixelsY = (@trackEllipsesPoints[@racer3[:PointOnTrackOverview]][1] - nextPoint[1]).abs
			overflowProtectionPointOnTrack = @trackEllipsesPoints[@racer3[:PointOnTrackOverview]]
		end
		
		#how many pixels away are we on the overview from the current point e.g. @racer3[:PointOnTrackOverview]
		pixelsAwayFromCurrentPointX = distanceBetweenPixelsX * percentageIntoCurrentPoint
		pixelsAwayFromCurrentPointY = distanceBetweenPixelsY * percentageIntoCurrentPoint
		#calculate whether we need to increase X or decrease X for the overview icon sprite
		if @trackEllipsesPoints[@racer3[:PointOnTrackOverview]][0] > nextPoint[0]
			#decrease X
			currentOverviewX = @trackEllipsesPoints[@racer3[:PointOnTrackOverview]][0] - (pixelsAwayFromCurrentPointX.floor)
		elsif @trackEllipsesPoints[@racer3[:PointOnTrackOverview]][0] < nextPoint[0]
			#increase X
			currentOverviewX = @trackEllipsesPoints[@racer3[:PointOnTrackOverview]][0] + (pixelsAwayFromCurrentPointX.floor)
		end
		
		#calculate whether we need to increase Y or decrease Y for the overview icon sprite
		if @trackEllipsesPoints[@racer3[:PointOnTrackOverview]][1] > nextPoint[1]
			#decrease Y
			currentOverviewY = @trackEllipsesPoints[@racer3[:PointOnTrackOverview]][1] - (pixelsAwayFromCurrentPointY.floor)
		elsif @trackEllipsesPoints[@racer3[:PointOnTrackOverview]][1] < nextPoint[1]
			#increase Y
			currentOverviewY = @trackEllipsesPoints[@racer3[:PointOnTrackOverview]][1] + (pixelsAwayFromCurrentPointY.floor)
		end	
		@racer3[:PositionXOnTrackOverview] = currentOverviewX - @sprites["racer3PkmnOverview"].width/4
		@racer3[:PositionYOnTrackOverview] = currentOverviewY - @sprites["racer3PkmnOverview"].height/4
		#put the overview icon sprite where it should be
		#print @sprites["racer3PkmnOverview"].x if @racer3[:PointOnTrackOverview] == 0
		@sprites["racer3PkmnOverview"].x = @racer3[:PositionXOnTrackOverview]
		@sprites["racer3PkmnOverview"].y = @racer3[:PositionYOnTrackOverview]
		
		###################################
		#============= Player =============
		###################################
		#the array with the points on the track are @trackEllipsesPoints
		#@trackDistanceBetweenPoints is currently 256 pixels
		
		#player point on overview
		@racerPlayer[:PointOnTrackOverview] = (@racerPlayer[:PositionOnTrack] / @trackDistanceBetweenPoints).floor
		
		#calculate overX and Y like so:
		#Current overviewX is the number of pixels in distance between current point and next point on the X axis. We'll say we are at point 0 and the next point is at 1.
		#Regardless of where we are, we want to use the distance in pixels between those points to calculate.
		#If we are at point 0.9, that's 90% of the distance between points.
		#Let's say 72 pixels are between the points on the X axis.
		#90% of 72 pixels is 66.6 so we put the current X of the overview icon at the X of the current point PLUS 66.6 (use floor)
		#to get the percentage of the distance we are into the point, use this:
		#DistanceCurrentToNextPointX = blah blah blah, we'll say it's 74 pixels, the amount between point 0 and point 1
		#PercentageIntoCurrentPoint = pointOnTrack / @distanceBetweenPoints (get remainder, and the remainder is the PercentageIntoCurrentPoint)
		
		#get the amount of pixels past the point we are at on the overview
		remainder = @racerPlayer[:PositionOnTrack] % @trackDistanceBetweenPoints

		#get the percentage we have traveled into the point, 100% being when we reach the next point
		percentageIntoCurrentPoint = remainder.percent_of(@trackDistanceBetweenPoints)
		percentageIntoCurrentPoint = percentageIntoCurrentPoint / 100
		
		if @racerPlayer[:PointOnTrackOverview] >= @trackEllipsesPoints.length-1
			nextPoint = @trackEllipsesPoints[0]
		else
			nextPoint = @trackEllipsesPoints[@racerPlayer[:PointOnTrackOverview]+1]
		end
		
		#how many pixels in distance is it on the X axis between this point and the next one coming up?
		distanceBetweenPixelsX = (@trackEllipsesPoints[@racerPlayer[:PointOnTrackOverview]][0] - nextPoint[0]).abs
		distanceBetweenPixelsY = (@trackEllipsesPoints[@racerPlayer[:PointOnTrackOverview]][1] - nextPoint[1]).abs
		#how many pixels away are we on the overview from the current point e.g. @racerPlayer[:PointOnTrackOverview]
		pixelsAwayFromCurrentPointX = distanceBetweenPixelsX * percentageIntoCurrentPoint
		pixelsAwayFromCurrentPointY = distanceBetweenPixelsY * percentageIntoCurrentPoint
		
		#calculate whether we need to increase X or decrease X for the overview icon sprite
		if @trackEllipsesPoints[@racerPlayer[:PointOnTrackOverview]][0] > nextPoint[0]
			#decrease X
			currentOverviewX = @trackEllipsesPoints[@racerPlayer[:PointOnTrackOverview]][0] - (pixelsAwayFromCurrentPointX.floor)
		elsif @trackEllipsesPoints[@racerPlayer[:PointOnTrackOverview]][0] < nextPoint[0]
			#increase X
			currentOverviewX = @trackEllipsesPoints[@racerPlayer[:PointOnTrackOverview]][0] + (pixelsAwayFromCurrentPointX.floor)
		end
		
		#calculate whether we need to increase Y or decrease Y for the overview icon sprite
		if @trackEllipsesPoints[@racerPlayer[:PointOnTrackOverview]][1] > nextPoint[1]
			#decrease Y
			currentOverviewY = @trackEllipsesPoints[@racerPlayer[:PointOnTrackOverview]][1] - (pixelsAwayFromCurrentPointY.floor)
		elsif @trackEllipsesPoints[@racerPlayer[:PointOnTrackOverview]][1] < nextPoint[1]
			#increase Y
			currentOverviewY = @trackEllipsesPoints[@racerPlayer[:PointOnTrackOverview]][1] + (pixelsAwayFromCurrentPointY.floor)
		end
				
		@racerPlayer[:PositionXOnTrackOverview] = currentOverviewX - @sprites["racerPlayerPkmnOverview"].width/4
		@racerPlayer[:PositionYOnTrackOverview] = currentOverviewY - @sprites["racerPlayerPkmnOverview"].height/4
		
		#put the overview icon sprite where it should be
		@sprites["racerPlayerPkmnOverview"].x = @racerPlayer[:PositionXOnTrackOverview]
		@sprites["racerPlayerPkmnOverview"].y = @racerPlayer[:PositionYOnTrackOverview]
	end #def self.trackOverviewMovementUpdate
	
end #class CrustangRacing