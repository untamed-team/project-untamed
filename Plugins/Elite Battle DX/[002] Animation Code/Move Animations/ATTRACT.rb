#-------------------------------------------------------------------------------
#  HEARTSTAMP
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:HEARTSTAMP) do
  EliteBattle.playMoveAnimation(:ATTRACT, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  ATTRACT
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:ATTRACT) do | args |
  bomb = args[0]; bomb = true if bomb.nil?
  itself = (@userIndex==@targetIndex)
  # set up animation
  fp = {}
  rndx = []
  rndy = []
  factor = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(223,67,67))
  fp["bg"].opacity = 0
  for i in 0...16
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb636_2")
    fp["#{i}"].src_rect.set(0,0*rand(3),53,101)
    fp["#{i}"].ox = 26
    fp["#{i}"].oy = 101
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = (@targetIsPlayer ? 29 : 19)
    rndx.push(rand(64))
    rndy.push(rand(64))
  end
  shake = 2
  # start animation
  @sprites["battlebg"].defocus
  for i in 0...132
    ax, ay = @userSprite.getAnchor
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...16
      if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
        fp["#{j}"].zoom_x = @userSprite.zoom_x
        fp["#{j}"].zoom_y = @userSprite.zoom_y
        fp["#{j}"].x = ax
        fp["#{j}"].y = ay + 50*@userSprite.zoom_y
      end
      next if j>(i/4)
      x2 = cx - 32*@targetSprite.zoom_x + rndx[j]*@targetSprite.zoom_x
      y2 = cy - 32*@targetSprite.zoom_y + rndy[j]*@targetSprite.zoom_y + 50*@targetSprite.zoom_y
      x0 = fp["#{j}"].x
      y0 = fp["#{j}"].y
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].zoom_x -= (fp["#{j}"].zoom_x - @targetSprite.zoom_x)*0.1
      fp["#{j}"].zoom_y -= (fp["#{j}"].zoom_y - @targetSprite.zoom_y)*0.1
      fp["#{j}"].src_rect.x += 53 if i%4==0
      fp["#{j}"].src_rect.x = 0 if fp["#{j}"].src_rect.x >= fp["#{j}"].bitmap.width
      if (x2 - x0)*0.1 < 1 && (y2 - y0)*0.1 < 1
        fp["#{j}"].opacity -= 8
        fp["#{j}"].tone.gray += 8
        fp["#{j}"].tone.red -= 2; fp["#{j}"].tone.green -= 2; fp["#{j}"].tone.blue -= 2
        fp["#{j}"].zoom_x -= 0.02
        fp["#{j}"].zoom_y += 0.04
      else
        fp["#{j}"].opacity += 12
      end
    end
    fp["bg"].opacity += 5 if fp["bg"].opacity < 255*0.5
    pbSEPlay("Anim/Love",80) if i%12==0 && i <= 96
    if i >= 96
      @targetSprite.tone.all += 1.4*2 if @targetSprite.tone.all < 48*2
      @targetSprite.ox += shake
      shake = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @vector.set(EliteBattle.get_vector(:DUAL)) if i == 24
    @vector.inc = 0.1 if i == 24
    @scene.wait(1,true)
  end
  #heart splatter
  for j in 0...32
    fp["p#{j}"] = Sprite.new(@viewport)
	fp["p#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb636_2")
    fp["p#{j}"].center!
    fp["p#{j}"].x, fp["p#{j}"].y = @targetSprite.getCenter(true)
    r = (40 + rand(24))*@targetSprite.zoom_x
    x, y = randCircleCord(r)
    fp["p#{j}"].end_x = fp["p#{j}"].x - r + x
    fp["p#{j}"].end_y = fp["p#{j}"].y - r + y
    fp["p#{j}"].zoom_x = 0
    fp["p#{j}"].zoom_y = 0
	factor[j] = rand(1)
    #fp["p#{j}"].angle = rand(360)
    fp["p#{j}"].z = @targetSprite.z + 1
  end
  # spike shatter animation
  for i in 0...64
    break if !bomb && i > 15
	pbSEPlay("Anim/LoveSplatter") if i == 1
    for j in 0...32
	  next if !bomb
      next if i < 8
      next if j > (i-8)*2
	  if factor[j] == 0 || true
		  fp["p#{j}"].zoom_x += (1.6 - fp["p#{j}"].zoom_x)*0.03
		  fp["p#{j}"].zoom_y += (1.6 - fp["p#{j}"].zoom_y)*0.03
	  else
	  	  fp["p#{j}"].zoom_x += (1.0 - fp["p#{j}"].zoom_x)*0.03
		  fp["p#{j}"].zoom_y += (1.0 - fp["p#{j}"].zoom_y)*0.03
	  end
      fp["p#{j}"].x += (fp["p#{j}"].end_x - fp["p#{j}"].x)*0.1
      fp["p#{j}"].y += (fp["p#{j}"].end_y - fp["p#{j}"].y)*0.1
      if fp["p#{j}"].zoom_x >= 0.8
        fp["p#{j}"].opacity -= 25
      end
      fp["p#{j}"].color.alpha -= 8
    end
	@scene.wait(1,i < 8)
  end
  20.times do
    @targetSprite.tone.all -= 1.6*2
    @targetSprite.ox += shake
    shake = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
    shake = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
    @targetSprite.still
    fp["bg"].opacity -= 15
    @scene.wait(1,true)
  end
  @targetSprite.tone.all = 0
  @sprites["battlebg"].focus
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
