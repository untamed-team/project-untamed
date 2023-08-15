#-------------------------------------------------------------------------------
#  MINIMIZE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:MINIMIZE) do | args |
  EliteBattle.playMoveAnimation(:DOUBLETEAM, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  ACUPRESSURE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:ACUPRESSURE) do | args |
  EliteBattle.playMoveAnimation(:DOUBLETEAM, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  TEETERDANCE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:TEETERDANCE) do | args |
  EliteBattle.playMoveAnimation(:DOUBLETEAM, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  SKETCH
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SKETCH) do | args |
  EliteBattle.playMoveAnimation(:DOUBLETEAM, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  AGILITY
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:AGILITY) do
  EliteBattle.playMoveAnimation(:DOUBLETEAM, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  DOUBLETEAM
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:DOUBLETEAM) do
  @vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
  fp = {}
  #
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].opacity = 0
  #
  # set up animation
  @scene.wait(8,true)
  #
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end
  #
  shake = 30
  idx =  0 # counter
  dir = -1 # direction
  ports = 40
  xOrigin = @userSprite.ox
  for i in 0...ports
	pbSEPlay("EBDX/Anim/move1",80) if i%10 == 0
    @userSprite.still
	#default movement
	if i == 3
		@userSprite.ox += shake
	end
    if i.between?(4,ports)
		if dir == -1 #move left 
			@userSprite.ox -= shake
		else # move right
		    @userSprite.ox += shake
		end
	  idx += 1 
	  if idx == 2
		idx = 0
		dir = dir * -1
	  end
    end
    @scene.wait(1,true)
  end
  16.times do
    fp["bg"].opacity -= 20
    @scene.wait(1,true)
  end
  @userSprite.ox = @userSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
