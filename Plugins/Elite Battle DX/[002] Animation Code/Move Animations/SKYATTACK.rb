#-------------------------------------------------------------------------------
#  SKYATTACK
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SKYATTACK) do
  if @hitNum == 1
    EliteBattle.playMoveAnimation(:SKYATTACK_CHARGE, @scene, @userIndex, @targetIndex)
  elsif @hitNum == 0
    EliteBattle.playMoveAnimation(:SKYATTACK_ATK, @scene, @userIndex, @targetIndex)
  end
end

EliteBattle.defineMoveAnimation(:SKYATTACK_CHARGE) do
  vector = @scene.getRealVector(@userIndex, @userIsPlayer)
  factor = @userIsPlayer ? 2 : 1
  # set up animation
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].opacity = 0
  for i in 0...12
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb195")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 50
  end
  k = 0
  c = [Tone.new(211,186,3),Tone.new(0,0,0)]
  # start animation
  @sprites["battlebg"].defocus
  @vector.set(vector)
  for i in 0...128
    cx, cy = @userSprite.getCenter
    for j in 0...12
      if fp["#{j}"].opacity == 0
        r = rand(2)
        fp["#{j}"].zoom_x = factor*(r==0 ? 1 : 0.5)
        fp["#{j}"].zoom_y = factor*(r==0 ? 1 : 0.5)
        x, y = randCircleCord(64*factor)
        fp["#{j}"].x = cx - 64*factor*@userSprite.zoom_x + x*@userSprite.zoom_x
        fp["#{j}"].y = cy - 64*factor*@userSprite.zoom_y + y*@userSprite.zoom_y
      end
      next if j>(i/4)
      x2 = cx
      y2 = cy
      x0 = fp["#{j}"].x
      y0 = fp["#{j}"].y
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].zoom_x -= fp["#{j}"].zoom_x*0.1
      fp["#{j}"].zoom_y -= fp["#{j}"].zoom_y*0.1
      if i >= 96
        fp["#{j}"].opacity -= 35
      elsif (x2 - x0)*0.1 < 1 && (y2 - y0)*0.1 < 1
        fp["#{j}"].opacity = 0
      else
        fp["#{j}"].opacity += 35
      end
    end
    if i < 96
      fp["bg"].opacity += 5 if fp["bg"].opacity < 255*0.6
    else
      fp["bg"].opacity -= 5
    end
    if i < 112
      if i%16 == 0
        k += 1
        k = 0 if k > 1
      end
      @userSprite.tone.red += (c[k].red - @userSprite.tone.red)*0.2
      @userSprite.tone.green += (c[k].green - @userSprite.tone.green)*0.2
      @userSprite.tone.blue += (c[k].blue - @userSprite.tone.blue)*0.2
    end
    pbSEPlay("Anim/Absorb2",100) if i == 16
    pbSEPlay("Anim/Saint8",70) if i == 16
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @userSprite.tone = Tone.new(0,0,0)
  @vector.reset
  pbDisposeSpriteHash(fp)
end

EliteBattle.defineMoveAnimation(:SKYATTACK_ATK) do
  # inital configuration
  defaultvector = EliteBattle.get_vector(:MAIN, @battle)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  # set up animation
  fp = {}; dx = []; dy = []
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb628_bg_2")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  shake = 4; k = 0
  # start animation
  @sprites["battlebg"].defocus
  for i in 0...20
	pbSEPlay("Anim/wind1",80) if i == 2
    if i < 8
      fp["bg"].opacity += 32
    else
      fp["bg"].color.alpha -= 32
	  @userSprite.opacity-=25
    end
    if i == 8
      @vector.set(vector2)
    end
    fp["bg"].update
    @scene.wait(1,true)
  end
  cx, cy = @userSprite.getCenter(true)
  dx = []
  dy = []
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb628_4")
    fp["#{i}s"].src_rect.set(rand(3)*36,0,36,36)
    fp["#{i}s"].ox = fp["#{i}s"].src_rect.width/2
    fp["#{i}s"].oy = fp["#{i}s"].src_rect.height/2
    r = 128*@userSprite.zoom_x
    z = [0.5,0.25,1,0.75][rand(4)]
    x, y = randCircleCord(r)
    x = cx - r + x
    y = cy - r + y
    fp["#{i}s"].x = cx
    fp["#{i}s"].y = cy
    fp["#{i}s"].zoom_x = z*@userSprite.zoom_x
    fp["#{i}s"].zoom_y = z*@userSprite.zoom_x
    fp["#{i}s"].visible = false
    fp["#{i}s"].z = @userSprite.z + 1
    dx.push(x); dy.push(y)
  end
  fp["shot"] = Sprite.new(@viewport)
  fp["shot"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb628_3")
  fp["shot"].ox = fp["shot"].bitmap.width/2
  fp["shot"].oy = fp["shot"].bitmap.height/2
  fp["shot"].z = @userSprite.z + 1
  fp["shot"].zoom_x = @userSprite.zoom_x*0.8
  fp["shot"].zoom_y = @userSprite.zoom_y*0.8
  fp["shot"].opacity = 0
  x = defaultvector[0]; y = defaultvector[1]
  x2, y2 = @vector.spoof(defaultvector)
  fp["shot"].x = cx
  fp["shot"].y = cy
  pbSEPlay("EBDX/Anim/normal1",80)
  k = -1
  for i in 0...20
    cx, cy = @userSprite.getCenter
    @vector.reset if i == 0
    if i > 0
      fp["shot"].angle = Math.atan(1.0*(@vector.y-@vector.y2)/(@vector.x2-@vector.x))*(180.0/Math::PI) + (@targetIsPlayer ? 180 : 0)
      fp["shot"].opacity += 32
      fp["shot"].zoom_x -= (fp["shot"].zoom_x - @targetSprite.zoom_x)*0.1
      fp["shot"].zoom_y -= (fp["shot"].zoom_y - @targetSprite.zoom_y)*0.1
      fp["shot"].x += (@targetIsPlayer ? -1 : 1)*(x2 - x)/24
      fp["shot"].y -= (@targetIsPlayer ? -1 : 1)*(y - y2)/24
      for j in 0...8
        fp["#{j}s"].visible = true
        fp["#{j}s"].opacity -= 32
        fp["#{j}s"].x -= (fp["#{j}s"].x - dx[j])*0.2
        fp["#{j}s"].y -= (fp["#{j}s"].y - dy[j])*0.2
      end
    end
    fp["bg"].update
    factor = @targetSprite.zoom_x if i == 12
    if i >= 12
      k *= -1 if i%4==0
      @targetSprite.zoom_x -= factor*0.01*k
      @targetSprite.zoom_y += factor*0.04*k
      @targetSprite.still
    end
    cx, cy = @targetSprite.getCenter(true)
    if !@targetIsPlayer
      fp["shot"].z = @targetSprite.z - 1 if fp["shot"].x > cx && fp["shot"].y < cy
    else
      fp["shot"].z = @targetSprite.z + 1 if fp["shot"].x < cx && fp["shot"].y > cy
    end
    @scene.wait(1,i < 12)
  end
  shake = 2
  16.times do
    fp["shot"].angle = Math.atan(1.0*(@vector.y-@vector.y2)/(@vector.x2-@vector.x))*(180.0/Math::PI) + (@targetIsPlayer ? 180 : 0)
    fp["shot"].opacity += 32
    fp["shot"].zoom_x -= (fp["shot"].zoom_x - @targetSprite.zoom_x)*0.1
    fp["shot"].zoom_y -= (fp["shot"].zoom_y - @targetSprite.zoom_y)*0.1
    fp["shot"].x += (@targetIsPlayer ? -1 : 1)*(x2 - x)/24
    fp["shot"].y -= (@targetIsPlayer ? -1 : 1)*(y - y2)/24
    fp["bg"].color.alpha += 16
    fp["bg"].update
    @targetSprite.ox += shake
    shake = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 4
    shake = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 4
    @targetSprite.still
    cx, cy = @targetSprite.getCenter(true)
    if !@targetIsPlayer
      fp["shot"].z = @targetSprite.z - 1 if fp["shot"].x > cx && fp["shot"].y < cy
    else
      fp["shot"].z = @targetSprite.z + 1 if fp["shot"].x < cx && fp["shot"].y > cy
    end
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  16.times do
    fp["bg"].update
    fp["bg"].opacity -= 16
	@userSprite.opacity+=20
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  pbDisposeSpriteHash(fp)
end
