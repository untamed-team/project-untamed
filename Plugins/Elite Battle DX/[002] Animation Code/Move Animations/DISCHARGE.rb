#-------------------------------------------------------------------------------
#  DISCHARGE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:DISCHARGE) do
  @vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
  fp = {}
  # set up animation
  @scene.wait(5,true)
  EliteBattle.playMoveAnimation(:CHARGE, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  EliteBattle.playMoveAnimation(:THUNDERBOLT, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  @userSprite.ox = @userSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
