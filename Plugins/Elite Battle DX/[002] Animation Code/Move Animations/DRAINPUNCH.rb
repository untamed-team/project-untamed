#-------------------------------------------------------------------------------
#  DRAINPUNCH
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:DRAINPUNCH) do
  #@vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
  fp = {}
  # set up animation
  @scene.wait(5,true)
  EliteBattle.playMoveAnimation(:WAKEUPSLAP, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  EliteBattle.playMoveAnimation(:ABSORB, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  @userSprite.ox = @userSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
