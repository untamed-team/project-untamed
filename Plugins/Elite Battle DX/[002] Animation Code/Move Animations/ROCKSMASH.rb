#-------------------------------------------------------------------------------
#  ROCKSMASH
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:ROCKSMASH) do
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  fp = {}
  # set up animation
  @scene.wait(5,true)
  @multiHit = true
  EliteBattle.playMoveAnimation(:WAKEUPSLAP, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  EliteBattle.playCommonAnimation(:ROCKSPLASH, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  @multiHit = false
  @userSprite.ox = @userSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
