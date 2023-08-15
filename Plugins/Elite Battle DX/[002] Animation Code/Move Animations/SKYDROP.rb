#-------------------------------------------------------------------------------
#  SKYDROP
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SKYDROP) do
  if @hitNum == 1
    EliteBattle.playMoveAnimation(:SKYDROP_UP, @scene, @userIndex, @targetIndex)
  elsif @hitNum == 0
    EliteBattle.playMoveAnimation(:SKYDROP_DOWN, @scene, @userIndex, @targetIndex)
  end
end

EliteBattle.defineMoveAnimation(:SKYDROP_UP) do
  # inital configuration
  defaultvector = EliteBattle.get_vector(:MAIN, @battle)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  # set up animation
  fp = {}; dx = []; dy = []
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb086_bg")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  shake = 4; k = 0; factor = @targetIsPlayer ? 2 : 1.5
  # set up animation
  fp["fly"] = Sprite.new(@viewport)
  fp["fly"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb156")
  fp["fly"].ox = fp["fly"].bitmap.width/2
  fp["fly"].oy = fp["fly"].bitmap.height/2
  fp["fly"].z = 50
  fp["fly"].x, fp["fly"].y = @targetSprite.getCenter
  fp["fly"].opacity = 0
  fp["fly"].zoom_x = factor*1.4
  fp["fly"].zoom_y = factor*1.4
  fp["dnt"] = Sprite.new(@viewport)
  fp["dnt"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb156_2")
  fp["dnt"].ox = fp["dnt"].bitmap.width/2
  fp["dnt"].oy = fp["dnt"].bitmap.height/2
  fp["dnt"].z = 50
  fp["dnt"].opacity = 0
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
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb628_2")
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
  fp["shot"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb628")
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
  factor = @targetIsPlayer ? 2 : 1.5
  for i in 0...20
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
	cx, cy = @targetSprite.getCenter
    fp["fly"].x = cx
    fp["fly"].y = cy
    fp["fly"].zoom_x -= factor*0.4/10
    fp["fly"].zoom_y -= factor*0.4/10
    fp["fly"].opacity += 51
    fp["dnt"].x = cx
    fp["dnt"].y = cy
    fp["dnt"].zoom_x = fp["fly"].zoom_x
    fp["dnt"].zoom_y = fp["fly"].zoom_y
    fp["dnt"].opacity += 25.5
    fp["dnt"].angle -= 16
    @targetSprite.visible = false if i == 6
    @targetSprite.hidden = true if i == 6
	fp["bg"].update
    fp["bg"].opacity -= 16
    @scene.wait(1,true)
  end
  #flyup
  # start animation
  pbSEPlay("Anim/Refresh")
    10.times do
    fp["fly"].zoom_x += factor*0.4/10
    fp["fly"].zoom_y += factor*0.4/10
    fp["dnt"].zoom_x = fp["fly"].zoom_x
    fp["dnt"].zoom_y = fp["fly"].zoom_y
    fp["dnt"].opacity -= 25.5
    fp["dnt"].angle -= 16
    @scene.wait(1,true)
  end
  #@vector.set(vector[0],vector[1]+128,vector[2],vector[3],vector[4],vector[5])
  for i in 0...20
    @scene.wait(1,true)
    cx, cy = @targetSprite.getCenter
    if i < 10
      fp["fly"].zoom_y -= factor*0.02
    elsif
      fp["fly"].zoom_x -= factor*0.02
      fp["fly"].zoom_y += factor*0.04
    end
    fp["fly"].x = cx
    fp["fly"].y = cy
    fp["fly"].y -= 32*(i-10) if i >= 10
    pbSEPlay("EBDX/Anim/flying2") if i == 10
  end
  for i in 0...20
    fp["fly"].y -= 32
    fp["fly"].opacity -= 25.5 if i >= 10
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
    @userSprite.visible = false
    @userSprite.hidden = true 
	@targetSprite.visible = false
    @targetSprite.hidden = true
  @sprites["battlebg"].focus
  pbDisposeSpriteHash(fp)
end

EliteBattle.defineMoveAnimation(:SKYDROP_DOWN) do
  defaultvector = EliteBattle.get_vector(:MAIN, @battle)
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  # set up animation
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].opacity = 0
  fp["drop"] = Sprite.new(@viewport)
  fp["drop"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb156_3")
  fp["drop"].ox = fp["drop"].bitmap.width/2
  fp["drop"].oy = fp["drop"].bitmap.height/2
  fp["drop"].y = 0
  fp["drop"].z = 50
  fp["drop"].visible = false
  # start animation
  @vector.set(defaultvector[0], defaultvector[1]+128, defaultvector[2], defaultvector[3], defaultvector[4], defaultvector[5])
  @sprites["battlebg"].defocus
  32.times do
    fp["bg"].opacity += 2
    @scene.wait(1,true)
  end
  @vector.set(vector)
  maxy = ((@targetIsPlayer ? @vector.y : @vector.y2)*0.1).ceil*10 - 80
  fp["drop"].y = -((maxy-(@targetIsPlayer ? @vector.y-80 : @vector.y2-80))*0.1).ceil*10
  fp["drop"].x = @targetSprite.x
  pbSEPlay("Anim/Wind1")
  for i in 0...20
    @scene.wait(1,true)
    if i >= 10
      fp["drop"].visible = true
      fp["drop"].x = @targetSprite.x
      fp["drop"].y += maxy/10
      fp["drop"].zoom_x = @targetSprite.zoom_x
      fp["drop"].zoom_y = @targetSprite.zoom_y*1.4
    end
    fp["bg"].opacity -= 51 if i >= 15
  end
  @sprites["battlebg"].focus
  @userSprite.hidden = false
  @userSprite.visible = true  
  @userSprite.opacity = 255
  @targetSprite.hidden = false
  @targetSprite.visible = true
  @scene.wait(1,true)
  pbDisposeSpriteHash(fp)
  EliteBattle.playMoveAnimation(:TACKLE, @scene, @userIndex, @targetIndex, 0, false, nil, false, true)
end
