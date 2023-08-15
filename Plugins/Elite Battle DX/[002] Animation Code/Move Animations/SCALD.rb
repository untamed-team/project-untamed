#-------------------------------------------------------------------------------
#  SCALD
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SCALD) do
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  fp = {}
  # set up animation
  @scene.wait(2,true)
  EliteBattle.playMoveAnimation(:WATERGUN, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(1,true)
  EliteBattle.playCommonAnimation(:BURN, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  @userSprite.ox = @userSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
