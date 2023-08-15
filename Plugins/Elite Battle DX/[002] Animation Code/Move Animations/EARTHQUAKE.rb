#-------------------------------------------------------------------------------
#  FISSURE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:FISSURE) do
  EliteBattle.playMoveAnimation(:EARTHQUAKE, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  BULLDOZE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:BULLDOZE) do
  EliteBattle.playMoveAnimation(:EARTHQUAKE, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  MAGNITUDE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:MAGNITUDE) do
  EliteBattle.playMoveAnimation(:EARTHQUAKE, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  ROTOTILLER
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:ROTOTILLER) do
  EliteBattle.playMoveAnimation(:EARTHQUAKE, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  Earthquake
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:EARTHQUAKE) do
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].opacity = 0
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @sprites["battlebg"].defocus
  16.times do
    fp["bg"].opacity += 8
    @scene.wait(1,true)
  end
  # set up animation
  factor = @targetSprite.zoom_x
  cx, cy = @targetSprite.getCenter(true)
  y0 = @targetSprite.y
  x = [cx - 64*factor, cx + 64*factor, cx]
  y = [y0, y0, y0 + 24*factor]
  dx = []
  # start animation
    j = -1
    pbSEPlay("EBDX/Anim/rock1",110)
    pbSEPlay("Anim/Earth4",80,70)
    for i in 0...70
      j *= -1 if i%4==0
      if i <= 55
		  if i%2 == 0
			l = 35 
		  else
			l = -35
		  end
	  else
		  if i%2 == 0
			l = 15 
		  else
			l = -15
		  end
	  end
      @scene.moveEntireScene(j*l, j, true, true)# if i < 24
      @scene.wait
    end
  #end
  16.times do
    fp["bg"].opacity -= 8
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  pbDisposeSpriteHash(fp)
  @vector.reset if !@multiHit
end
