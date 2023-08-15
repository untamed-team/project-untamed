#-------------------------------------------------------------------------------
#  SOLARBLADE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SOLARBLADE) do
  if @hitNum == 1
    EliteBattle.playMoveAnimation(:SOLARBLADE_CHARGE, @scene, @userIndex, @targetIndex)
  elsif @hitNum == 0
    EliteBattle.playMoveAnimation(:SOLARBLADE_ATK, @scene, @userIndex, @targetIndex)
  end
end

EliteBattle.defineMoveAnimation(:SOLARBLADE_CHARGE) do
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

EliteBattle.defineMoveAnimation(:SOLARBLADE_ATK) do
  # set up animation
  fp = {}; rndx = []; rndy = []
  dx = []; dy = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].opacity = 0
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  # set up animation
  @vector.set(vector)
  @scene.wait(16,true)
  cx, cy = @targetSprite.getCenter(true)
  fp["whip"] = Sprite.new(@viewport)
  fp["whip"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb632_9")
  fp["whip"].ox = fp["whip"].bitmap.width*0.75
  fp["whip"].oy = fp["whip"].bitmap.height*0.5
  fp["whip"].angle = 315
  fp["whip"].zoom_x = @targetSprite.zoom_x*1.5
  fp["whip"].zoom_y = @targetSprite.zoom_y*1.5
  fp["whip"].color = Color.new(255,255,255,0)
  fp["whip"].opacity = 0
  fp["whip"].x = cx + 32*@targetSprite.zoom_x
  fp["whip"].y = cy - 48*@targetSprite.zoom_y
  fp["whip"].z = @targetIsPlayer ? 29 : 19
  fp["imp"] = Sprite.new(@viewport)
  fp["imp"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb244_14")
  fp["imp"].ox = fp["imp"].bitmap.width/2
  fp["imp"].oy = fp["imp"].bitmap.height/2
  fp["imp"].zoom_x = @targetSprite.zoom_x*2
  fp["imp"].zoom_y = @targetSprite.zoom_y*2
  fp["imp"].visible = false
  fp["imp"].x = cx
  fp["imp"].y = cy - 48*@targetSprite.zoom_y
  fp["imp"].z = @targetIsPlayer ? 29 : 19
  posx = []
  posy = []
  angl = []
  zoom = []
  for j in 0...12
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb195")
    fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
    fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
    fp["#{j}"].z = @targetIsPlayer ? 29 : 19
    fp["#{j}"].visible = false
    z = [1,1.25,0.75,0.5][rand(4)]
    fp["#{j}"].zoom_x = @targetSprite.zoom_x*z
    fp["#{j}"].zoom_y = @targetSprite.zoom_y*z
    fp["#{j}"].angle = rand(360)
    posx.push(rand(128))
    posy.push(rand(64))
    angl.push((rand(2)==0 ? 1 : -1))
    zoom.push(z)
    fp["#{j}"].opacity = (155+rand(100))
  end
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end
  # start animation
  k = 1
  for i in 0...32
    pbSEPlay("Anim/Absorb2",100) if i == 1
    pbSEPlay("Anim/Saint8",70) if i == 2
    pbSEPlay("EBDX/Anim/normal4",80) if i == 5
    if i < 16
      fp["whip"].opacity += 128 if i < 4
      fp["whip"].angle += 16
      fp["whip"].color.alpha += 16 if i >= 8
      fp["whip"].zoom_x -= 0.2 if i >= 8
      fp["whip"].zoom_y -= 0.16 if i >= 4
      fp["whip"].opacity -= 64 if i >= 12
      fp["imp"].visible = true if i == 3
      if i >= 4
        fp["imp"].angle += 4
        fp["imp"].zoom_x -= 0.02
        fp["imp"].zoom_x -= 0.02
        fp["imp"].opacity -= 32
      end
      @targetSprite.zoom_y -= 0.04*k
      @targetSprite.zoom_x += 0.02*k
      @targetSprite.tone = Tone.new(255,255,255) if i == 4
      @targetSprite.tone.red -= 51 if @targetSprite.tone.red > 0
      @targetSprite.tone.green -= 51 if @targetSprite.tone.green > 0
      @targetSprite.tone.blue -= 51 if @targetSprite.tone.blue > 0
      k *= -1 if (i-4)%6==0
    end
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...12
      next if i < 4
      next if j>(i-4)
      fp["#{j}"].visible = true
      fp["#{j}"].x = cx - 64*@targetSprite.zoom_x*zoom[j] + posx[j]*@targetSprite.zoom_x*zoom[j]
      fp["#{j}"].y = cy - posy[j]*@targetSprite.zoom_y*zoom[j] - 48*@targetSprite.zoom_y*zoom[j]# - (i-4)*2*@targetSprite.zoom_y
      fp["#{j}"].angle += angl[j]
    end
    @scene.wait
  end
  @vector.reset if !@multiHit
  for i in 0...16
    @scene.wait(1,true)
    cx, cy = @targetSprite.getCenter(true)
    k = 20 - i
    for j in 0...12
      fp["#{j}"].x = cx - 64*@targetSprite.zoom_x*zoom[j] + posx[j]*@targetSprite.zoom_x*zoom[j]
      fp["#{j}"].y = cy - posy[j]*@targetSprite.zoom_y*zoom[j] - 48*@targetSprite.zoom_y*zoom[j]# - (k)*2*@targetSprite.zoom_y
      fp["#{j}"].opacity -= 16
      fp["#{j}"].angle += angl[j]
      fp["#{j}"].zoom_x = @targetSprite.zoom_x
      fp["#{j}"].zoom_y = @targetSprite.zoom_y
    end
  end
  16.times do
    fp["bg"].opacity -= 20
    @scene.wait(1,true)
  end
  pbDisposeSpriteHash(fp)
end