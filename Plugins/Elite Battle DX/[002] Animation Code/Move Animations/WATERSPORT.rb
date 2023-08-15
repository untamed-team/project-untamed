#-------------------------------------------------------------------------------
#  WATERSPORT
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:WATERSPORT) do
  @vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
  splash = 60
  fp = {}
  # bg
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(51,153,255))
  fp["bg"].opacity = 0
  # user
  @userSprite.color = Color.new(51,153,255,0)
  # set up animation
  @scene.wait(5,true)
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end
  # init splash
  for j in 0...splash
    fp["p#{j}"] = Sprite.new(@viewport)
    fp["p#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb618_2")
    fp["p#{j}"].center!
    fp["p#{j}"].x, fp["p#{j}"].y = @userSprite.getCenter(true)
    r = (40 + rand(24))*@userSprite.zoom_x
    x, y = randCircleCord(r)
    fp["p#{j}"].end_x = fp["p#{j}"].x - r + x
    fp["p#{j}"].end_y = fp["p#{j}"].y - r + y
    fp["p#{j}"].zoom_x = 0
    fp["p#{j}"].zoom_y = 0
    fp["p#{j}"].angle = rand(360)
    fp["p#{j}"].z = @userSprite.z + 1
  end
  for i in 0...64
	pbSEPlay("Anim/Bubble1",100) if i == 5 || i == 15
    for j in 0...splash
      next if i < 8
      next if j > (i-8)*2
      fp["p#{j}"].zoom_x += (1.6 - fp["p#{j}"].zoom_x)*0.1
      fp["p#{j}"].zoom_y += (1.6 - fp["p#{j}"].zoom_y)*0.1
      fp["p#{j}"].x += (fp["p#{j}"].end_x - fp["p#{j}"].x)*0.1
      fp["p#{j}"].y += (fp["p#{j}"].end_y - fp["p#{j}"].y)*0.1 - 15
      if fp["p#{j}"].zoom_x >= 1
        fp["p#{j}"].opacity -= 16
      end
      fp["p#{j}"].color.alpha -= 8
    end
    if i < 48
      @userSprite.color.alpha += 4
    else
      @userSprite.color.alpha -= 16
    end
	@scene.wait(1)
	@userSprite.still
    @userSprite.anim = true
  end
  16.times do
    fp["bg"].opacity -= 20
    @scene.wait(1,true)
  end
  @userSprite.ox = @userSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
