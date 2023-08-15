#-------------------------------------------------------------------------------
#  ROCKCLIMB
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:ROCKCLIMB) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  # set up animation
  fp = {}
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb086_bg_7")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  # animation start
  @sprites["battlebg"].defocus
  @vector.set(vector)
  for i in 0...16
    fp["bg"].opacity += 32 if i >= 8
    @scene.wait(1,true)
  end
  factor = @targetSprite.zoom_x
  cx, cy = @targetSprite.getCenter(true)
  dx = []
  dy = []
  for j in 0...12
    fp["s#{j}"] = Sprite.new(@viewport)
    fp["s#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb244_2")
    fp["s#{j}"].ox = fp["s#{j}"].bitmap.width/2
    fp["s#{j}"].oy = fp["s#{j}"].bitmap.height/2
    r = 32*factor
    fp["s#{j}"].x = cx - r + rand(r*2)
    fp["s#{j}"].y = cy - r + rand(r*2)
    fp["s#{j}"].z = @targetSprite.z + 1
    fp["s#{j}"].visible = false
    fp["s#{j}"].tone = Tone.new(255,255,255)
    fp["s#{j}"].angle = rand(360)
  end
  for j in 0...96
    fp["p#{j}"] = Sprite.new(@viewport)
    fp["p#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb086_2")
    fp["p#{j}"].ox = fp["p#{j}"].bitmap.width/2
    fp["p#{j}"].oy = fp["p#{j}"].bitmap.height/2
    fp["p#{j}"].z = @targetSprite.z
    r = 148*factor + rand(32)*factor
    x, y = randCircleCord(r)
    fp["p#{j}"].x = cx
    fp["p#{j}"].y = cy
    fp["p#{j}"].visible = false
    fp["p#{j}"].zoom_x = factor
    fp["p#{j}"].zoom_y = factor
    fp["p#{j}"].color = Color.new(182,74,41,0)
    dx.push(cx - r + x)
    dy.push(cy - r + y)
  end
  k = -4
  #animation
  for i in 0...50
    k *= - 1 if i%4==0
    fp["bg"].color.alpha -= 32 if fp["bg"].color.alpha > 0
    for j in 0...12
      next if j>(i*3)
      fp["s#{j}"].visible = true
      fp["s#{j}"].opacity -= 32
      fp["s#{j}"].zoom_x += 0.02
      fp["s#{j}"].zoom_y += 0.02
      fp["s#{j}"].angle += 8
      fp["s#{j}"].tone.red -= 32
      fp["s#{j}"].tone.green -= 32
      fp["s#{j}"].tone.blue -= 32
    end
    @targetSprite.still
    pbSEPlay("EBDX/Anim/normal1",80) if i%4==0 && i < 16
    for j in 0...50
      next if j>(i*3)
      fp["p#{j}"].visible = true
      fp["p#{j}"].x -= (fp["p#{j}"].x - dx[j])*0.2
      fp["p#{j}"].y -= (fp["p#{j}"].y - dy[j])*0.2
      fp["p#{j}"].opacity -= 32 if ((fp["p#{j}"].x - dx[j])*0.2).abs < 16
      fp["p#{j}"].color.alpha += 16 if ((fp["p#{j}"].x - dx[j])*0.2).abs < 32
      fp["p#{j}"].zoom_x += 0.1
      fp["p#{j}"].zoom_y += 0.1
      fp["p#{j}"].angle = -Math.atan(1.0*(fp["p#{j}"].y-cy)/(fp["p#{j}"].x-cx))*(180.0/Math::PI)
    end
    fp["bg"].update
    @targetSprite.still
    @targetSprite.zoom_x -= factor*0.01*k if i < 56
    @targetSprite.zoom_y += factor*0.02*k if i < 56
    @scene.wait
  end
  @vector.reset if !@multiHit
  16.times do
    fp["bg"].color.alpha += 16
    fp["bg"].opacity -= 16
    fp["bg"].update
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  pbDisposeSpriteHash(fp)
end
