#-------------------------------------------------------------------------------
#  RAZORWIND
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:RAZORWIND) do
  if @hitNum == 1
    EliteBattle.playMoveAnimation(:RAZORWIND_CHARGE, @scene, @userIndex, @targetIndex)
  elsif @hitNum == 0
    EliteBattle.playMoveAnimation(:HURRICANE, @scene, @userIndex, @targetIndex)
  end
end
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:RAZORWIND_CHARGE) do
  itself = (@userIndex==@targetIndex)
  # set up animation
  fp = {}
  rndx = []
  rndy = []
  numElements = 3
  for i in 0...numElements
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb637")
    fp["#{i}"].src_rect.set(0,128*rand(3),64,128)
    fp["#{i}"].ox = 26
    fp["#{i}"].oy = 101
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = (@targetIsPlayer ? 29 : 19)
    fp["#{i}"].z += 5
    rndx.push(rand(64))
    rndy.push(rand(64))
  end
  shake = 2
  # start animation
  @sprites["battlebg"].defocus
  for i in 0...80
    ax, ay = @userSprite.getAnchor
    cx, cy = @userSprite.getCenter(true)
    for j in 0...numElements
      if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
        fp["#{j}"].zoom_x = @userSprite.zoom_x
        fp["#{j}"].zoom_y = @userSprite.zoom_y
        fp["#{j}"].x = ax
        fp["#{j}"].y = ay + 50*@userSprite.zoom_y
      end
      next if j>(i/4)
      x2 = cx - 32*@userSprite.zoom_x + rndx[j]*@userSprite.zoom_x
      y2 = cy - 32*@userSprite.zoom_y + rndy[j]*@userSprite.zoom_y + 50*@userSprite.zoom_y
      x0 = fp["#{j}"].x
      y0 = fp["#{j}"].y
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].zoom_x -= (fp["#{j}"].zoom_x - @userSprite.zoom_x)*0.1
      fp["#{j}"].zoom_y -= (fp["#{j}"].zoom_y - @userSprite.zoom_y)*0.1
      fp["#{j}"].src_rect.x += 64 if i%4==0
      fp["#{j}"].src_rect.x = 0 if fp["#{j}"].src_rect.x >= fp["#{j}"].bitmap.width
      if (x2 - x0)*0.1 < 1 && (y2 - y0)*0.1 < 1
        fp["#{j}"].opacity -= 12
        fp["#{j}"].tone.gray += 8
        fp["#{j}"].zoom_x -= 0.02
        fp["#{j}"].zoom_y += 0.04
      else
        fp["#{j}"].opacity += 10
      end
    end
    pbSEPlay("Anim/Wind8",80) if i%24==0 && i <= 60
    if i >= 50
      @userSprite.ox += shake
      shake = -2 if @userSprite.ox > @userSprite.bitmap.width/2 + 2
      shake = 2 if @userSprite.ox < @userSprite.bitmap.width/2 - 2
      @userSprite.still
    end
    @vector.set(EliteBattle.get_vector(:DUAL)) if i == 24
    @vector.inc = 0.1 if i == 24
    @scene.wait(1,true)
  end
  20.times do
    @userSprite.ox += shake
    shake = -2 if @userSprite.ox > @userSprite.bitmap.width/2 + 2
    shake = 2 if @userSprite.ox < @userSprite.bitmap.width/2 - 2
    @userSprite.still
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @userSprite.ox = @userSprite.bitmap.width/2
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
