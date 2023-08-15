#-------------------------------------------------------------------------------
#  POUND
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:POUND) do
  @vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
  vector2 = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  fp = {}
  #
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].opacity = 0
  #
  # set up animation
  @scene.wait(5,true)
  #
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end
  #
  shake = 8
  for i in 0...12
    @userSprite.still
	pbSEPlay("EBDX/Anim/move1",100) if i == 4 || i == 8
    if i.between?(4,12)
      @userSprite.ox += shake
      shake = -8 if @userSprite.ox > @userSprite.bitmap.width/2 + 2
      shake = 8 if @userSprite.ox < @userSprite.bitmap.width/2 - 2
    end
    @scene.wait(1,true)
  end
  @vector.set(vector2)
  @scene.wait(10,true)
  EliteBattle.playMoveAnimation(:TACKLE, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  16.times do
    fp["bg"].opacity -= 20
    @scene.wait(1,true)
  end
  @userSprite.ox = @userSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
