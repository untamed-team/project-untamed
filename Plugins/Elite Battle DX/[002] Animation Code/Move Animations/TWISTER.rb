#-------------------------------------------------------------------------------
#  TWISTER
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:TWISTER) do
  # set up animation
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(103,113,164))
  fp["bg"].opacity = 0
  fp["wave"] = AnimatedPlane.new(@viewport)
  fp["wave"].bitmap = Bitmap.new(1026,@viewport.height)
  fp["wave"].bitmap.stretch_blt(Rect.new(0,0,fp["wave"].bitmap.width,fp["wave"].bitmap.height),pbBitmap("Graphics/EBDX/Animations/Moves/eb132_5"),Rect.new(0,0,1026,212))
  fp["wave"].opacity = 0
  fp["wave"].z = 50
  rndx = []
  rndy = []
  numElements = 9
  for i in 0...numElements
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb637_3")
    fp["#{i}"].src_rect.set(0,128*rand(3),64,128)
    fp["#{i}"].ox = 26
    fp["#{i}"].oy = 101
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = (@targetIsPlayer ? 29 : 19)
    rndx.push(rand(64))
    rndy.push(rand(64))
  end
  @vector.set(EliteBattle.get_vector(:DUAL))
  @vector.inc = 0.1
  pulse = 10
  shake = [4,4,4,4]
  # start animation
  for j in 0...80#64
    pbSEPlay("Anim/Wind8") if j == 24
    fp["wave"].ox += 48
    fp["wave"].opacity += pulse
    pulse = -5 if fp["wave"].opacity > 160
    pulse = +5 if fp["wave"].opacity < 100
    fp["bg"].opacity += 1 if fp["bg"].opacity < 255*0.35
    for i in 0...4
      next if !(@targetIsPlayer ? [0,2] : [1,3]).include?(i)
      next if !(@sprites["pokemon_#{i}"] && @sprites["pokemon_#{i}"].visible) || @sprites["pokemon_#{i}"].disposed?
      @sprites["pokemon_#{i}"].tone.all += 3 if j.between?(16,48)
      if j >= 32
        @sprites["pokemon_#{i}"].ox += shake[i]
        shake[i] = -4 if @sprites["pokemon_#{i}"].ox > @sprites["pokemon_#{i}"].bitmap.width/2 + 2
        shake[i] = 4 if @sprites["pokemon_#{i}"].ox < @sprites["pokemon_#{i}"].bitmap.width/2 - 2
      end
    end
	ax, ay = @userSprite.getAnchor
    cx, cy = @targetSprite.getCenter(true)
	for i in 0...numElements
      if fp["#{i}"].opacity == 0 && fp["#{i}"].tone.gray == 0
        fp["#{i}"].zoom_x = @userSprite.zoom_x
        fp["#{i}"].zoom_y = @userSprite.zoom_y
        fp["#{i}"].x = ax
        fp["#{i}"].y = ay + 50*@userSprite.zoom_y
      end
      next if i>(j/4)
      x2 = cx - 32*@targetSprite.zoom_x + rndx[i]*@targetSprite.zoom_x
      y2 = cy - 32*@targetSprite.zoom_y + rndy[i]*@targetSprite.zoom_y + 50*@targetSprite.zoom_y
      x0 = fp["#{i}"].x
      y0 = fp["#{i}"].y
      fp["#{i}"].x += (x2 - x0)*0.1
      fp["#{i}"].y += (y2 - y0)*0.1
      fp["#{i}"].zoom_x -= (fp["#{i}"].zoom_x - @targetSprite.zoom_x)*0.1
      fp["#{i}"].zoom_y -= (fp["#{i}"].zoom_y - @targetSprite.zoom_y)*0.1
      fp["#{i}"].src_rect.x += 64 if i%4==0
      fp["#{i}"].src_rect.x = 0 if fp["#{i}"].src_rect.x >= fp["#{i}"].bitmap.width
      if (x2 - x0)*0.1 < 1 && (y2 - y0)*0.1 < 1
        fp["#{i}"].opacity -= 8
        fp["#{i}"].tone.gray += 8
        fp["#{i}"].zoom_x -= 0.02
        fp["#{i}"].zoom_y += 0.04
      else
        fp["#{i}"].opacity += 3
      end
    end
    pbSEPlay("Anim/Wind8",80) if j%24==0 && j <= 60
    @sprites["pokemon_#{@userIndex}"].tone.all += 3 if j < 32
    @sprites["pokemon_#{@userIndex}"].still
    @scene.wait(1,true)
  end
  for i in 0...4
    next if !(@targetIsPlayer ? [0,2] : [1,3]).include?(i)
    next if !(@sprites["pokemon_#{i}"] && @sprites["pokemon_#{i}"].visible) || @sprites["pokemon_#{i}"].disposed?
    @sprites["pokemon_#{i}"].ox = @sprites["pokemon_#{i}"].bitmap.width/2
  end
  for j in 0...64
    fp["wave"].ox += 48
    if j < 32
      fp["wave"].opacity += pulse
      pulse = -5 if fp["wave"].opacity > 160
      pulse = +5 if fp["wave"].opacity < 100
    end
    fp["wave"].opacity -= 4 if j >= 32
    fp["bg"].opacity -= 4 if j >= 32
    for i in 0...4
      next if !(@targetIsPlayer ? [0,2] : [1,3]).include?(i)
      next if !(@sprites["pokemon_#{i}"] && @sprites["pokemon_#{i}"].visible)
      @sprites["pokemon_#{i}"].tone.all -= 3 if j >= 32
    end
    @sprites["pokemon_#{@userIndex}"].tone.all -= 3 if j >= 32
    @sprites["pokemon_#{@userIndex}"].still
    @scene.wait(1,true)
  end
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
