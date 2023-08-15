#-------------------------------------------------------------------------------
#  REVENGE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:REVENGE) do
  EliteBattle.playMoveAnimation(:SUPERPOWER, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  SUPERPOWER
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SUPERPOWER) do
  @vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
  fp = {}
  # set up animation
  @scene.wait(5,true)
  EliteBattle.playMoveAnimation(:DRAGONDANCE, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  EliteBattle.playMoveAnimation(:FINALGAMBIT, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  @userSprite.ox = @userSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end