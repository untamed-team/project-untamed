#-------------------------------------------------------------------------------
#  ACIDARMOR
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:ACIDARMOR) do
  EliteBattle.playMoveAnimation(:COIL, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  COIL
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:COIL) do
  # set up animation
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(205,154,255))
  fp["bg"].opacity = 0
  fp["wrap1"] = Sprite.new(@viewport)
  fp["wrap1"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb028_7")
  fp["wrap1"].ox = fp["wrap1"].bitmap.width/2 - 10
  fp["wrap1"].oy = fp["wrap1"].bitmap.height - 60
  fp["wrap1"].angle = -90
  fp["wrap1"].opacity = 0
  fp["wrap1"].z = 41
  fp["wrap2"] = Sprite.new(@viewport)
  fp["wrap2"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb028_7")
  fp["wrap2"].ox = fp["wrap1"].bitmap.width/2 + 10
  fp["wrap2"].oy = fp["wrap1"].bitmap.height - 60
  fp["wrap2"].opacity = 0
  fp["wrap2"].z = 40
  fp["wrap2"].mirror = true
  fp["wrap2"].angle = 90
  shake = 4
  # start animation
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @sprites["battlebg"].defocus
  for i in 0...80
    cx, cy = @targetSprite.getCenter(true)
    fp["wrap1"].x = cx; fp["wrap1"].y = cy
    fp["wrap1"].zoom_x = 1.5*@targetSprite.zoom_x; fp["wrap1"].zoom_y = 1.5*@targetSprite.zoom_y
    fp["wrap2"].x = cx; fp["wrap2"].y = cy
    fp["wrap2"].zoom_x = 1.5*@targetSprite.zoom_x; fp["wrap2"].zoom_y = 1.5*@targetSprite.zoom_y
    if i.between?(20,35)
      fp["wrap1"].opacity += 5
      fp["wrap1"].oy += 2
      fp["wrap2"].opacity += 5
      fp["wrap2"].oy += 2
    elsif i.between?(35,45)
      fp["wrap1"].opacity += 25.5
      fp["wrap1"].oy -= 2
      fp["wrap2"].opacity += 25.5
      fp["wrap2"].oy -= 2
    else
      fp["wrap1"].opacity -= 26
      fp["wrap1"].oy += 2
      fp["wrap2"].opacity -= 26
      fp["wrap2"].oy += 2
    end
    pbSEPlay("EBDX/Anim/poison1") if i%20 == 0
    fp["bg"].opacity += 4 if  i < 40
    if i >= 40
      fp["bg"].opacity -= 10 if i >= 56
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
