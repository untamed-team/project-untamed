class Dance
  #=========================================================
  # Dancer Methods
  #=========================================================
  def self.playerJump
    #this is only used at the beginning before the music starts
    genericTimer = 0
    bobDistance = 24
    bobSpeed = 0.4#3
    loop do
      Graphics.update
      playerBobY = Math.sin(genericTimer * bobSpeed) * bobDistance
      absPlayerBobY = playerBobY.abs
      @sprites["contestant4"].y = 0 - absPlayerBobY.truncate
      genericTimer += 1
      break if playerBobY < 0
    end
    @sprites["contestant4"].y = 0
  end
  
  def self.toneDancers
    if @timerY < 4 + (Graphics.frame_rate * 4)
      #first half of track is in use
      self.normalToneLeadDancer
      self.darkToneBackupDancers
    end
    if @timerY >= 4 + (Graphics.frame_rate * 4)
      #second half of track is in use
      self.darkToneLeadDancer
      self.normalToneBackupDancers
    end
  end
  
  def self.playerCanDance?
    return false if @pauseDancing == true
    return false if @danceMovesLeft <= 0
    
    #if lead dancer - using first half of the track
    return true if @dancerTurn == 4 && @timerY >= @leadMovesOnBeat[0] && @timerY <= @leadMovesOnBeat[-1] #first half of track
    
    #if backup dancer - using second half of the track
    return true if @dancerTurn < 4 && @timerY >= @backupMovesOnBeat[0] && @timerY <= @backupMovesOnBeat[-1] #second half of track
    
    return false #catch all
  end
  
  def self.darkToneLeadDancer
    targetTone = -100
    @leadDancerSprite.tone.red -= 20 if @leadDancerSprite.tone.red > targetTone
    @leadDancerSprite.tone.green -= 20 if @leadDancerSprite.tone.green > targetTone
    @leadDancerSprite.tone.blue -= 20 if @leadDancerSprite.tone.blue > targetTone
  end
  
  def self.normalToneLeadDancer
    targetTone = 0
    @leadDancerSprite.tone.red += 20 if @leadDancerSprite.tone.red < targetTone
    @leadDancerSprite.tone.green += 20 if @leadDancerSprite.tone.green < targetTone
    @leadDancerSprite.tone.blue += 20 if @leadDancerSprite.tone.blue < targetTone
  end
  
  def self.darkToneBackupDancers
    targetTone = -100
    @backupDancer1Sprite.tone.red -= 20 if @backupDancer1Sprite.tone.red > targetTone
    @backupDancer1Sprite.tone.green -= 20 if @backupDancer1Sprite.tone.green > targetTone
    @backupDancer1Sprite.tone.blue -= 20 if @backupDancer1Sprite.tone.blue > targetTone
    @backupDancer2Sprite.tone.red -= 20 if @backupDancer2Sprite.tone.red > targetTone
    @backupDancer2Sprite.tone.green -= 20 if @backupDancer2Sprite.tone.green > targetTone
    @backupDancer2Sprite.tone.blue -= 20 if @backupDancer2Sprite.tone.blue > targetTone
    @backupDancer3Sprite.tone.red -= 20 if @backupDancer3Sprite.tone.red > targetTone
    @backupDancer3Sprite.tone.green -= 20 if @backupDancer3Sprite.tone.green > targetTone
    @backupDancer3Sprite.tone.blue -= 20 if @backupDancer3Sprite.tone.blue > targetTone
  end
  
  def self.normalToneBackupDancers
    targetTone = 0
    @backupDancer1Sprite.tone.red += 20 if @backupDancer1Sprite.tone.red < targetTone
    @backupDancer1Sprite.tone.green += 20 if @backupDancer1Sprite.tone.green < targetTone
    @backupDancer1Sprite.tone.blue += 20 if @backupDancer1Sprite.tone.blue < targetTone
    @backupDancer2Sprite.tone.red += 20 if @backupDancer2Sprite.tone.red < targetTone
    @backupDancer2Sprite.tone.green += 20 if @backupDancer2Sprite.tone.green < targetTone
    @backupDancer2Sprite.tone.blue += 20 if @backupDancer2Sprite.tone.blue < targetTone
    @backupDancer3Sprite.tone.red += 20 if @backupDancer3Sprite.tone.red < targetTone
    @backupDancer3Sprite.tone.green += 20 if @backupDancer3Sprite.tone.green < targetTone
    @backupDancer3Sprite.tone.blue += 20 if @backupDancer3Sprite.tone.blue < targetTone
  end
  
end #class Dance