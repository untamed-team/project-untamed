#-------------------------------------------------------------------------------
#  ICICLESPEAR
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:ICICLESPEAR) do | args |
  bomb = args[0]; bomb = true if bomb.nil?
  shake = 6
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(204,255,255))
  fp["bg"].opacity = 0
  # shooting out the icespear
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end
  fp["icespear"] = Sprite.new(@viewport)
  fp["icespear"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb244")
  fp["icespear"].z = @targetSprite.z + 1
  @targetSprite.color = Color.new(204,255,255,0)
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  for v in 0..2
	  for i in 0...24
		pbSEPlay("EBDX/Anim/ice1") if i == 3
		pbSEPlay("EBDX/Anim/ice2") if i == 20
		cxT, cyT = @targetSprite.getCenter(true)
		cxP, cyP = @userSprite.getAnchor(true)
		mx = @vector.x + (@vector.x2 - @vector.x)*0.5
		points = calculateCurve(cxP,cyP,mx,-32,cxT,cyT,24)
		fp["icespear"].x = points[i][0]
		fp["icespear"].y = points[i][1]
		z = 1 + (1-(fp["icespear"].x - @vector.x).to_f/(@vector.x2 - @vector.x))
		fp["icespear"].zoom_x = z/2
		fp["icespear"].zoom_y = z/2
		fp["icespear"].update
		fp["icespear"].angle = 135 - i*3.75 if @userIsPlayer
		fp["icespear"].angle = -135 + i*5 if @targetIsPlayer
		if i >= 16 && i%2 == 0
			@targetSprite.ox += shake
		end
		if i >= 16 && i%2 == 1
			@targetSprite.ox -= shake
		end
		if i.between?(17,20)
		    @targetSprite.color.alpha += 25
			@targetSprite.anim = true
			@targetSprite.still
		end
		if i.between?(20,24)
		    @targetSprite.color.alpha -= 25
			@targetSprite.anim = true
			@targetSprite.still
		end
		@scene.wait(1,true)
	  end
  end
  fp["icespear"].dispose
  16.times do
    fp["bg"].opacity -= 20
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @scene.wait(1,true)
  pbDisposeSpriteHash(fp)
  @vector.reset if !@multiHit
end