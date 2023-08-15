#-------------------------------------------------------------------------------
#  SWAGGER
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SWAGGER) do
  EliteBattle.playMoveAnimation(:TAUNT, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  TAUNT
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:TAUNT) do
  @vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
  fp = {}
  #
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].opacity = 0
  #
  # set up animation
  @scene.wait(5,true)
  #
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end
  #
  shake = 6
  for i in 0...12
    @userSprite.still
	pbSEPlay("Cries/#{@userSprite.species}",85) if i == 4
    if i.between?(4,12)
      @userSprite.ox += shake
      shake = -6 if @userSprite.ox > @userSprite.bitmap.width/2 + 2
      shake = 6 if @userSprite.ox < @userSprite.bitmap.width/2 - 2
    end
    @scene.wait(1,true)
  end
  #taunt
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(16,true)
  factor = @targetSprite.zoom_x
  cx, cy = @targetSprite.getCenter(true)
  dx = []
  dy = []
  t = 1
  for j in 0..t
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb643")
    fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
    fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
    fp["#{j}"].x = cx + 20 if j == 0
    fp["#{j}"].x = cx - 20 if j == 1
    fp["#{j}"].y = cy - 40
    fp["#{j}"].z = @targetSprite.z
    fp["#{j}"].visible = false
    fp["#{j}"].angle = rand(360)
    z = [0.5,1,0.75][rand(3)]
    fp["#{j}"].zoom_x = z
    fp["#{j}"].zoom_y = z
  end
  # start animation
  for i in 0...30
	pbSEPlay("Anim/Taunt",100) if i == 3 || i == 9
    for j in 0..t
      next if j>(i*2)
	  next if i <= 5 && j == 1
      fp["#{j}"].visible = true
      if i > 20
        fp["#{j}"].opacity -= 32
      else
		if fp["#{j}"].zoom <= 1.5
			fp["#{j}"].zoom += 0.1
		else
		    fp["#{j}"].opacity -= 32
		end
      end
    end
    @scene.wait
  end
  16.times do
    fp["bg"].opacity -=12
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
