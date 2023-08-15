#-------------------------------------------------------------------------------
#  SKULLBASH
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SKULLBASH) do
  if @hitNum == 1
    EliteBattle.playMoveAnimation(:SWORDSDANCE, @scene, @userIndex, @targetIndex)
  elsif @hitNum == 0
    EliteBattle.playMoveAnimation(:TAKEDOWN, @scene, @userIndex, @targetIndex)
  end
end