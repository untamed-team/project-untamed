#-------------------------------------------------------------------------------
#  FIRESPIN
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:FIRESPIN) do
  #-----------------------------------------------------------------------------
  #  configure variables
  @scene.wait(16, true) if @scene.afterAnim
  fp = {}; k = -1; flames = 8 ; shake = 2
  factor = @targetSprite.zoom_x
  reversed = []; cx, cy = @targetSprite.getCenter(true)
  #-----------------------------------------------------------------------------
  #  set up sprites
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(130,52,42))
  fp["bg"].opacity = 0
  for j in 0...flames
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb136")
    fp["#{j}"].src_rect.set(0,101*rand(3),53,101)
    fp["#{j}"].ox = 26
    fp["#{j}"].oy = 101
    fp["#{j}"].zoom_x = factor
    fp["#{j}"].zoom_y = factor
    fp["#{j}"].opacity = 0
    fp["#{j}"].y = cy - 48*factor - k*2*factor
    fp["#{j}"].x = cx + 64*factor - (j%4)*32*factor
    reversed.push([false,true][j/4])
  end
  #-----------------------------------------------------------------------------
  #  play animation
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end
  vol = 80
  for i in 0...70
    k = i if i < 16
    pbSEPlay("Anim/Fire2",80) if i%12==0
    pbSEPlay("Anim/Smokescreen",120) if i==50
    vol -= 5 if i%8 == 0
    for j in 0...flames
      reversed[j] = true if fp["#{j}"].x <= cx - 64*factor
      reversed[j] = false if fp["#{j}"].x >= cx + 64*factor
      fp["#{j}"].z = reversed[j] ? @targetSprite.z - 1 : @targetSprite.z + 1
      fp["#{j}"].y = cy - 48*factor - k*2*factor - (reversed[j] ? 4*factor : 0) + 120 if !@targetIsPlayer
      fp["#{j}"].y = cy - 48*factor - k*2*factor - (reversed[j] ? 4*factor : 0) + 200 if @targetIsPlayer
      fp["#{j}"].x -= reversed[j] ? -4*factor : 4*factor
	  next if j>(i/4)
      fp["#{j}"].opacity += 16 if fp["#{j}"].opacity < 150
      fp["#{j}"].opacity -= 25 if i >= 48
	  fp["#{j}"].src_rect.x += 53 if j%4==0
      fp["#{j}"].src_rect.x = 0 if fp["#{j}"].src_rect.x >= fp["#{j}"].bitmap.width
    end
    if i >= 30
      @targetSprite.ox += shake
      shake = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
	end
    @scene.wait(1,true)
  end
  20.times do
    @targetSprite.ox += shake
    shake = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
    shake = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
    @targetSprite.still
    fp["bg"].opacity -= 15
    @scene.wait(1,true)
  end
  #-----------------------------------------------------------------------------
  #  dispose sprites
  @userSprite.ox = @userSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
  #-----------------------------------------------------------------------------
end
