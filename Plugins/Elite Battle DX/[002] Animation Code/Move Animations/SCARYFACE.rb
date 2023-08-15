#-------------------------------------------------------------------------------
#  SNATCH
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SNATCH) do
  EliteBattle.playMoveAnimation(:SCARYFACE, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  MIRACLEEYE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:MIRACLEEYE) do
  EliteBattle.playMoveAnimation(:SCARYFACE, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  MINDREADER
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:MINDREADER) do
  EliteBattle.playMoveAnimation(:SCARYFACE, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  SCARYFACE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SCARYFACE) do
  @vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
  @scene.wait(5,true)
  fp = {}
  cx, cy = @userSprite.getCenter(true)
  #
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].opacity = 0
  #eyes
  fp["l"] = Sprite.new(@viewport)
  fp["l"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb619_5")
  fp["l"].ox = fp["l"].bitmap.width/2
  fp["l"].oy = fp["l"].bitmap.height/2
  if @userIsPlayer
	# fp["l"].x = 212
    # fp["l"].y = 245
	fp["l"].x = cx + 100
    fp["l"].y = cy - 50
  else 
	# fp["l"].x = 230
    # fp["l"].y = 200	
	fp["l"].x = cx - 65
    fp["l"].y = cy + 58
  end
  fp["l"].opacity = 0
  fp["l"].z = 29#(@userIsPlayer ? 29 : 19)
  fp["r"] = Sprite.new(@viewport)
  fp["r"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb619_5")
  fp["r"].ox = fp["r"].bitmap.width/2
  fp["r"].oy = fp["r"].bitmap.height/2
  if @userIsPlayer
  # fp["r"].x = cx + @userSprite.width/2 + 90
  # fp["r"].y = cy - @userSprite.height/2 - 5
	fp["r"].x = fp["l"].x + 40
    fp["r"].y = fp["l"].y
  else 
	fp["r"].x = fp["l"].x + 40
    fp["r"].y = fp["l"].y
  end
  fp["r"].opacity = 0
  fp["r"].z = 29#(@userIsPlayer ? 29 : 19)
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
  for i in 0...19
	pbSEPlay("Anim/ScaryFace",95) if i == 5
    @userSprite.still
    if i.between?(4,12)
      @userSprite.ox += shake
      shake = -6 if @userSprite.ox > @userSprite.bitmap.width/2 + 2
      shake = 6 if @userSprite.ox < @userSprite.bitmap.width/2 - 2
    end
	if i.between?(2,10)
		fp["l"].opacity += 20
		fp["r"].opacity += 20
	end
	if i.between?(11,19)
		fp["l"].opacity -= 20
		fp["r"].opacity -= 20
	end	
	fp["l"].angle += 15
	fp["r"].angle += 15
	if i.between?(2,10)
		if i%2==0
			fp["l"].zoom_x += 1
			fp["l"].zoom_y += 1
			fp["r"].zoom_x += 1
			fp["r"].zoom_y += 1
		end
		fp["l"].tone.red += 10
		fp["l"].tone.green += 10
		fp["l"].tone.blue += 10
		fp["r"].tone.red += 10
		fp["r"].tone.green += 10
		fp["r"].tone.blue += 10
	end
	if i.between?(11,19)
		if i%2==1
			fp["l"].zoom_x -= 1
			fp["l"].zoom_y -= 1
			fp["r"].zoom_x -= 1
			fp["r"].zoom_y -= 1
		end
		fp["l"].tone.red -= 10
		fp["l"].tone.green -= 10
		fp["l"].tone.blue -= 10
		fp["r"].tone.red -= 10
		fp["r"].tone.green -= 10
		fp["r"].tone.blue -= 10
	end
    @scene.wait(1,true)
  end
  16.times do
    fp["bg"].opacity -= 20
    @scene.wait(1,true)
  end
  @userSprite.ox = @userSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
