#-------------------------------------------------------------------------------
#  MIMIC
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:MIMIC) do
  EliteBattle.playMoveAnimation(:SPLASH, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  METRONOME
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:METRONOME) do
  EliteBattle.playMoveAnimation(:SPLASH, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  SPLASH
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SPLASH) do
  @vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
  fp = {}
  #
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].opacity = 0
  #
  # set up animation
  @scene.wait(5,true)
  shake = 60
  shakePart = shake/3
  jump = 20
  OX = @userSprite.ox
  OY = @userSprite.oy
  for i in 0...12
    @userSprite.still
	 pbSEPlay("Anim/Bubble1",100) if i == 0 || i == 3 || i == 6 || i == 9
    if i == 1 || i == 10
	  @userSprite.ox += shakePart
	  @userSprite.oy += jump
    end
	if i == 2 || i == 11
	  @userSprite.ox += shakePart
    end
	if i == 3 || i == 12
	  @userSprite.ox += shakePart
	  @userSprite.oy -= jump
    end
	if i == 4 || i == 7
	  @userSprite.ox -= shakePart
	  @userSprite.oy += jump
    end
	if i == 5 || i == 8
	  @userSprite.ox -= shakePart
    end
	if i == 6 || i == 9
	  @userSprite.ox -= shakePart
	  @userSprite.oy -= jump
    end
    @scene.wait(4,true)
  end
  @userSprite.ox = OX
  @userSprite.oy = OY
  @userSprite.ox = @userSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end