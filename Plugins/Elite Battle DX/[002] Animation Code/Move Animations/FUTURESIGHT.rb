#-------------------------------------------------------------------------------
#  FUTURESIGHT
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:FUTURESIGHT) do
  if @hitNum == 1
    EliteBattle.playMoveAnimation(:SCARYFACE, @scene, @userIndex, @targetIndex)
  elsif @hitNum == 0
    EliteBattle.playMoveAnimation(:PSYCHIC, @scene, @userIndex, @targetIndex)
  end
end