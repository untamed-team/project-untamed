#-------------------------------------------------------------------------------
#  FOCUSPUNCH
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:FOCUSPUNCH) do
  if @hitNum == 1
    EliteBattle.playMoveAnimation(:BULKUP, @scene, @userIndex, @targetIndex)
  elsif @hitNum == 0
    EliteBattle.playMoveAnimation(:ROCKCLIMB, @scene, @userIndex, @targetIndex)
  end
end