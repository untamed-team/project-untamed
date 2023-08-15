#-------------------------------------------------------------------------------
#  SURF
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SURF) do
  # def ini
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  factor = @userIsPlayer ? 1 : 0.75
  factorY = @userIsPlayer ? 0.992 : 1.01#1.01
  BubbleSplash = @userIsPlayer ? 15 : -15
  splash = 30
  shake = 8
  # graphic ini
  fp = {};
  fp["surf"] = Sprite.new(@viewport)
  fp["surf"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  if @userIsPlayer
	fp["surf"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb624_PU")
	fp["surf"].x = -200
	fp["surf"].y =  800
	moveX = 15
	moveY = -7
  else
	fp["surf"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb624_EU") 
	fp["surf"].x =  900
	fp["surf"].y =  -550
	moveX = -15
	moveY = 7
  end
  fp["surf"].zoom_x = factor
  fp["surf"].zoom_y = factor
  fp["surf"].ox = fp["surf"].bitmap.width/2
  fp["surf"].oy = fp["surf"].bitmap.height/2
  fp["surf"].z = @targetSprite.z + 1
  fp["surf"].opacity = 0
  # sprite ini
  @userSprite.color = Color.new(51,153,255,0)
  # start animation
  @sprites["battlebg"].defocus
  @vector.set(vector)
  @scene.wait(4,true)
  for i in 0...75
	pbSEPlay("Anim/Water1") if i%25 == 0
    fp["surf"].opacity += 25 if fp["surf"].opacity <= 125
	fp["surf"].x += moveX
	fp["surf"].y += moveY
	fp["surf"].zoom_y = factorY * fp["surf"].zoom_y
	if i == 35
		for v in 0...splash
			fp["p#{v}"] = Sprite.new(@viewport)
			fp["p#{v}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb540_4")
			fp["p#{v}"].center!
			fp["p#{v}"].x, fp["p#{v}"].y = @targetSprite.getCenter(true)
			r = (40 + rand(24))*@targetSprite.zoom_x
			x, y = randCircleCord(r)
			fp["p#{v}"].end_x = fp["p#{v}"].x - r + x
			fp["p#{v}"].end_y = fp["p#{v}"].y - r + y
			fp["p#{v}"].zoom_x = 0
			fp["p#{v}"].zoom_y = 0
			fp["p#{v}"].angle = rand(360)
			fp["p#{v}"].z = @targetSprite.z + 1
		  end
		end
	if i.between?(40,70)
      for j in 0...splash
		  next if j > (i-8)*2
		  fp["p#{j}"].zoom_x += (1.6 - fp["p#{j}"].zoom_x)*0.1
		  fp["p#{j}"].zoom_y += (1.6 - fp["p#{j}"].zoom_y)*0.1
		  fp["p#{j}"].x += (fp["p#{j}"].end_x - fp["p#{j}"].x)*0.1 + BubbleSplash
		  fp["p#{j}"].y += (fp["p#{j}"].end_y - fp["p#{j}"].y)*0.1 - BubbleSplash
		  if fp["p#{j}"].zoom_x >= 0.5
			fp["p#{j}"].opacity -= 16
		  end
		  fp["p#{j}"].color.alpha -= 8
	  end
      @targetSprite.ox += shake
      shake = -8 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 8 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
	  if i < 55
		@userSprite.color.alpha += 10
	  else
		@userSprite.color.alpha -= 16
	  end
	  @userSprite.still
	  @userSprite.anim = true
    end
	@scene.wait(1,true)
  end
  @userSprite.ox = @userSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end