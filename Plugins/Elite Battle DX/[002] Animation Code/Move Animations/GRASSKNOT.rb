#-------------------------------------------------------------------------------
#  GRASSKNOT
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:GRASSKNOT) do
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(0,204,102))
  fp["bg"].opacity = 0
  # set up animation
  16.times do
    fp["bg"].opacity += 15
    @scene.wait(1,true)
  end
  @multiHit = true
  EliteBattle.playMoveAnimation(:LEAFBLADE, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  EliteBattle.playMoveAnimation(:COMETPUNCH, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  @multiHit = false
  16.times do
    fp["bg"].opacity -= 20
    @scene.wait(1,true)
  end
  @userSprite.ox = @userSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
