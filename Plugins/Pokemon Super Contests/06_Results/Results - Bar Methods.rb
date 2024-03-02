class Results
  def self.setPointsProportion
    #the max pixels you can go for each tally is 128
    #I need to make points proportional, where max is 128 "points"
    #the top scoring pokemon is given 33 points total, so split up into 3
    #segements of 11
    #if there's a tie for total points, the contestant that gets 33 points is
    #randomly selected
    
    #set the standard proportion for points where the player with the most
    #points has 384
    #for example, if @contestant_order[0] has 100 total points, 384/100 is 3.84,
    #all points get divided by 3.84
    #if @contestant_order[1] has 80 points, they have 80*3.84 float for the
    #purpose of this scene
    if @contestant_order[0][:TotalPoints] > 384
      @pointsProportion = @contestant_order[0][:TotalPoints] / 384.to_f
    else
      @pointsProportion = 384 / @contestant_order[0][:TotalPoints].to_f
    end
  end #def self.setPointsProportion
  
  #=====================
  # Dressup Points
  #=====================
  def self.dressupPointsBar
    @dressupBarBitmap = AnimatedBitmap.new("Graphics/Pictures/Contest/results/dressup_bar")
    
    #Contestant1
    @c1dressupBarSprite = Sprite.new(@viewport)
    @c1dressupBarSprite.bitmap = @dressupBarBitmap.bitmap
    @c1dressupBarSprite.src_rect.width = 0
    @sprites["contestant1DressupBar"] = @c1dressupBarSprite
    @sprites["contestant1DressupBar"].x = 96
    @sprites["contestant1DressupBar"].y = 56
    @sprites["contestant1DressupBar"].z = 99999
    
    #Contestant2
    @c2dressupBarSprite = Sprite.new(@viewport)
    @c2dressupBarSprite.bitmap = @dressupBarBitmap.bitmap
    @c2dressupBarSprite.src_rect.width = 0
    @sprites["contestant2DressupBar"] = @c2dressupBarSprite
    @sprites["contestant2DressupBar"].x = 96
    @sprites["contestant2DressupBar"].y = 120
    @sprites["contestant2DressupBar"].z = 99999
    
    #Contestant3
    @c3dressupBarSprite = Sprite.new(@viewport)
    @c3dressupBarSprite.bitmap = @dressupBarBitmap.bitmap
    @c3dressupBarSprite.src_rect.width = 0
    @sprites["contestant3DressupBar"] = @c3dressupBarSprite
    @sprites["contestant3DressupBar"].x = 96
    @sprites["contestant3DressupBar"].y = 184
    @sprites["contestant3DressupBar"].z = 99999
    
    #Contestant4
    @c4dressupBarSprite = Sprite.new(@viewport)
    @c4dressupBarSprite.bitmap = @dressupBarBitmap.bitmap
    @c4dressupBarSprite.src_rect.width = 0
    @sprites["contestant4DressupBar"] = @c4dressupBarSprite
    @sprites["contestant4DressupBar"].x = 96
    @sprites["contestant4DressupBar"].y = 248
    @sprites["contestant4DressupBar"].z = 99999
    
    c1DressupPoints = @chosenContestants[0][:DressupPoints] + @chosenContestants[0][:ConditionPoints]
    c2DressupPoints = @chosenContestants[1][:DressupPoints] + @chosenContestants[1][:ConditionPoints]
    c3DressupPoints = @chosenContestants[2][:DressupPoints] + @chosenContestants[2][:ConditionPoints]
    c4DressupPoints = @chosenContestants[3][:DressupPoints] + @chosenContestants[3][:ConditionPoints]
    
    timer = 0
    pbSEStop
    pbSEPlay("Contests_Results_Drumroll",150)
    pbSEPlay("Contests_Results_Tally")
    
    loop do
      Graphics.update
      self.update
      timer += 1
      if @sprites["contestant1DressupBar"].src_rect.width < @pointsProportion*c1DressupPoints && c1DressupPoints > 0
        @sprites["contestant1DressupBar"].src_rect.width = timer
      end
      if @sprites["contestant2DressupBar"].src_rect.width < @pointsProportion*c2DressupPoints && c1DressupPoints > 0
        @sprites["contestant2DressupBar"].src_rect.width = timer
      end
      if @sprites["contestant3DressupBar"].src_rect.width < @pointsProportion*c3DressupPoints && c1DressupPoints > 0
        @sprites["contestant3DressupBar"].src_rect.width = timer
      end
      if @sprites["contestant4DressupBar"].src_rect.width < @pointsProportion*c4DressupPoints && c1DressupPoints > 0
        @sprites["contestant4DressupBar"].src_rect.width = timer
      end
      
      break if @sprites["contestant1DressupBar"].src_rect.width >= @pointsProportion*c1DressupPoints && @sprites["contestant2DressupBar"].src_rect.width >= @pointsProportion*c2DressupPoints && @sprites["contestant3DressupBar"].src_rect.width >= @pointsProportion*c3DressupPoints && @sprites["contestant4DressupBar"].src_rect.width >= @pointsProportion*c4DressupPoints
    end #loop do
      
    pbSEStop
    pbSEPlay("Contests_Results_Tally_End",150)
  end #def self.dressupPointsBar
  
  #=====================
  # Dance Points
  #=====================
  def self.dancePointsBar
    @danceBarBitmap = AnimatedBitmap.new("Graphics/Pictures/Contest/results/dance_bar")
    
    #Contestant1
    @c1danceBarSprite = Sprite.new(@viewport)
    @c1danceBarSprite.bitmap = @danceBarBitmap.bitmap
    @c1danceBarSprite.src_rect.width = 0
    @sprites["contestant1DanceBar"] = @c1danceBarSprite
    @sprites["contestant1DanceBar"].x = @sprites["contestant1DressupBar"].x+@sprites["contestant1DressupBar"].src_rect.width
    @sprites["contestant1DanceBar"].y = 56
    @sprites["contestant1DanceBar"].z = 99999
    
    #Contestant2
    @c2danceBarSprite = Sprite.new(@viewport)
    @c2danceBarSprite.bitmap = @danceBarBitmap.bitmap
    @c2danceBarSprite.src_rect.width = 0
    @sprites["contestant2DanceBar"] = @c2danceBarSprite
    @sprites["contestant2DanceBar"].x = @sprites["contestant2DressupBar"].x+@sprites["contestant2DressupBar"].src_rect.width
    @sprites["contestant2DanceBar"].y = 120
    @sprites["contestant2DanceBar"].z = 99999
    
    #Contestant3
    @c3danceBarSprite = Sprite.new(@viewport)
    @c3danceBarSprite.bitmap = @danceBarBitmap.bitmap
    @c3danceBarSprite.src_rect.width = 0
    @sprites["contestant3DanceBar"] = @c3danceBarSprite
    @sprites["contestant3DanceBar"].x = @sprites["contestant3DressupBar"].x+@sprites["contestant3DressupBar"].src_rect.width
    @sprites["contestant3DanceBar"].y = 184
    @sprites["contestant3DanceBar"].z = 99999
    
    #Contestant4
    @c4danceBarSprite = Sprite.new(@viewport)
    @c4danceBarSprite.bitmap = @danceBarBitmap.bitmap
    @c4danceBarSprite.src_rect.width = 0
    @sprites["contestant4DanceBar"] = @c4danceBarSprite
    @sprites["contestant4DanceBar"].x = @sprites["contestant4DressupBar"].x+@sprites["contestant4DressupBar"].src_rect.width
    @sprites["contestant4DanceBar"].y = 248
    @sprites["contestant4DanceBar"].z = 99999
    
    timer = 0
    
    pbSEStop
    pbSEPlay("Contests_Results_Drumroll",150)
    pbSEPlay("Contests_Results_Tally")
    
    loop do
      Graphics.update
      self.update
      timer += 1
      if @sprites["contestant1DanceBar"].src_rect.width < @pointsProportion*@chosenContestants[0][:DancePoints] && @chosenContestants[0][:DancePoints] > 0
        @sprites["contestant1DanceBar"].src_rect.width = timer
      end
      if @sprites["contestant2DanceBar"].src_rect.width < @pointsProportion*@chosenContestants[1][:DancePoints] && @chosenContestants[1][:DancePoints] > 0
        @sprites["contestant2DanceBar"].src_rect.width = timer
      end
      if @sprites["contestant3DanceBar"].src_rect.width < @pointsProportion*@chosenContestants[2][:DancePoints] && @chosenContestants[2][:DancePoints] > 0
        @sprites["contestant3DanceBar"].src_rect.width = timer
      end
      if @sprites["contestant4DanceBar"].src_rect.width < @pointsProportion*@chosenContestants[3][:DancePoints] && @chosenContestants[3][:DancePoints] > 0
        @sprites["contestant4DanceBar"].src_rect.width = timer
      end
      
      break if @sprites["contestant1DanceBar"].src_rect.width >= @pointsProportion*@chosenContestants[0][:DancePoints] && @sprites["contestant2DanceBar"].src_rect.width >= @pointsProportion*@chosenContestants[1][:DancePoints] && @sprites["contestant3DanceBar"].src_rect.width >= @pointsProportion*@chosenContestants[2][:DancePoints] && @sprites["contestant4DanceBar"].src_rect.width >= @pointsProportion*@chosenContestants[3][:DancePoints]
    end #loop do
    
    pbSEStop
    pbSEPlay("Contests_Results_Tally_End",150)
  end #def self.dancePointsBar
  
  #=====================
  # Acting Points
  #=====================
  def self.actingPointsBar
    @actingBarBitmap = AnimatedBitmap.new("Graphics/Pictures/Contest/results/acting_bar")
    
    #Contestant1
    @c1actingBarSprite = Sprite.new(@viewport)
    @c1actingBarSprite.bitmap = @actingBarBitmap.bitmap
    @c1actingBarSprite.src_rect.width = 0
    @sprites["contestant1ActingBar"] = @c1actingBarSprite
    @sprites["contestant1ActingBar"].x = @sprites["contestant1DanceBar"].x+@sprites["contestant1DanceBar"].src_rect.width
    @sprites["contestant1ActingBar"].y = 56
    @sprites["contestant1ActingBar"].z = 99999
    
    #Contestant2
    @c2actingBarSprite = Sprite.new(@viewport)
    @c2actingBarSprite.bitmap = @actingBarBitmap.bitmap
    @c2actingBarSprite.src_rect.width = 0
    @sprites["contestant2ActingBar"] = @c2actingBarSprite
    @sprites["contestant2ActingBar"].x = @sprites["contestant2DanceBar"].x+@sprites["contestant2DanceBar"].src_rect.width
    @sprites["contestant2ActingBar"].y = 120
    @sprites["contestant2ActingBar"].z = 99999
    
    #Contestant3
    @c3actingBarSprite = Sprite.new(@viewport)
    @c3actingBarSprite.bitmap = @actingBarBitmap.bitmap
    @c3actingBarSprite.src_rect.width = 0
    @sprites["contestant3ActingBar"] = @c3actingBarSprite
    @sprites["contestant3ActingBar"].x = @sprites["contestant3DanceBar"].x+@sprites["contestant3DanceBar"].src_rect.width
    @sprites["contestant3ActingBar"].y = 184
    @sprites["contestant3ActingBar"].z = 99999
    
    #Contestant4
    @c4actingBarSprite = Sprite.new(@viewport)
    @c4actingBarSprite.bitmap = @actingBarBitmap.bitmap
    @c4actingBarSprite.src_rect.width = 0
    @sprites["contestant4ActingBar"] = @c4actingBarSprite
    @sprites["contestant4ActingBar"].x = @sprites["contestant4DanceBar"].x+@sprites["contestant4DanceBar"].src_rect.width
    @sprites["contestant4ActingBar"].y = 248
    @sprites["contestant4ActingBar"].z = 99999
    
    timer = 0
    
    pbSEStop
    pbSEPlay("Contests_Results_Drumroll",150)
    pbSEPlay("Contests_Results_Tally",150)
    
    loop do
      Graphics.update
      self.update
      timer += 1
      if @sprites["contestant1ActingBar"].src_rect.width < @pointsProportion*@chosenContestants[0][:ActingPoints] && @chosenContestants[0][:ActingPoints] > 0
        @sprites["contestant1ActingBar"].src_rect.width = timer
      end
      if @sprites["contestant2ActingBar"].src_rect.width < @pointsProportion*@chosenContestants[1][:ActingPoints] && @chosenContestants[1][:ActingPoints] > 0
        @sprites["contestant2ActingBar"].src_rect.width = timer
      end
      if @sprites["contestant3ActingBar"].src_rect.width < @pointsProportion*@chosenContestants[2][:ActingPoints] && @chosenContestants[2][:ActingPoints] > 0
        @sprites["contestant3ActingBar"].src_rect.width = timer
      end
      if @sprites["contestant4ActingBar"].src_rect.width < @pointsProportion*@chosenContestants[3][:ActingPoints] && @chosenContestants[3][:ActingPoints] > 0
        @sprites["contestant4ActingBar"].src_rect.width = timer
      end
      
      break if @sprites["contestant1ActingBar"].src_rect.width >= @pointsProportion*@chosenContestants[0][:ActingPoints] && @sprites["contestant2ActingBar"].src_rect.width >= @pointsProportion*@chosenContestants[1][:ActingPoints] && @sprites["contestant3ActingBar"].src_rect.width >= @pointsProportion*@chosenContestants[2][:ActingPoints] && @sprites["contestant4ActingBar"].src_rect.width >= @pointsProportion*@chosenContestants[3][:ActingPoints]
    end #loop do
    
    pbSEStop
    pbSEPlay("Contests_Results_Tally_End",150)
  end #def self.actingPointsBar

end #class Results