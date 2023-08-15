#-------------------------------------------------------------------------------
#  PUNISHMENT
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:PUNISHMENT) do
  EliteBattle.playMoveAnimation(:POWERTRIP, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  FOULPLAY
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:FOULPLAY) do
  EliteBattle.playMoveAnimation(:POWERTRIP, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  POWERTRIP
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:POWERTRIP) do
  @vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
  fp = {}
  # set up animation
  @scene.wait(5,true)
  EliteBattle.playMoveAnimation(:NASTYPLOT, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  EliteBattle.playMoveAnimation(:BEATUP, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  @userSprite.ox = @userSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
