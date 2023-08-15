#-------------------------------------------------------------------------------
#  DYNAMICPUNCH
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:DYNAMICPUNCH) do
  #@vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
  fp = {}
  # set up animation
  @scene.wait(5,true)
  @multiHit = true
  EliteBattle.playMoveAnimation(:BULKUP, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  EliteBattle.playMoveAnimation(:BRICKBREAK, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  EliteBattle.playCommonAnimation(:EXPLOSION, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  @multiHit = false
  @userSprite.ox = @userSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
