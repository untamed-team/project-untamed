#-------------------------------------------------------------------------------
#  CURSE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:CURSE) do
  if $game_switches[213]
    EliteBattle.playMoveAnimation(:NIGHTSHADE, @scene, @userIndex, @targetIndex)
  else
    EliteBattle.playMoveAnimation(:DRAGONDANCE, @scene, @userIndex, @targetIndex)
  end
end

