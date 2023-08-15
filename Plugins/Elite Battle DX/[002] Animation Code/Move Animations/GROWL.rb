#-------------------------------------------------------------------------------
#  TICKLE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:TICKLE) do
  EliteBattle.playMoveAnimation(:GROWL, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  REST
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:REST) do
  EliteBattle.playMoveAnimation(:GROWL, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  NOBLEROAR
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:NOBLEROAR) do
  EliteBattle.playMoveAnimation(:GROWL, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  ENTRAINMENT
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:ENTRAINMENT) do
  EliteBattle.playMoveAnimation(:GROWL, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  YAWN
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:YAWN) do
  EliteBattle.playMoveAnimation(:GROWL, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  AFTERYOU
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:AFTERYOU) do
  EliteBattle.playMoveAnimation(:GROWL, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  FAKETEARS
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:FAKETEARS) do
  EliteBattle.playMoveAnimation(:GROWL, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  ASSIST
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:ASSIST) do
  EliteBattle.playMoveAnimation(:GROWL, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  HELPINGHAND
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:HELPINGHAND) do
  EliteBattle.playMoveAnimation(:GROWL, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  PLAYNICE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:PLAYNICE) do
  EliteBattle.playMoveAnimation(:GROWL, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  GROWL
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:GROWL) do
  @vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
  fp = {}
  #
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].opacity = 0
  #
  # set up animation
  @scene.wait(5,true)
  #
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end
  #
  shake = 6
  for i in 0...12
    @userSprite.still
	pbSEPlay("Cries/#{@userSprite.species}",85) if i == 4
    if i.between?(4,12)
      @userSprite.ox += shake
      shake = -6 if @userSprite.ox > @userSprite.bitmap.width/2 + 2
      shake = 6 if @userSprite.ox < @userSprite.bitmap.width/2 - 2
    end
    @scene.wait(1,true)
  end
  16.times do
    fp["bg"].opacity -= 20
    @scene.wait(1,true)
  end
  @userSprite.ox = @userSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
