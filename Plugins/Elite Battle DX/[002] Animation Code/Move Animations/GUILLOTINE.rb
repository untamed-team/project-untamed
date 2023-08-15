#-------------------------------------------------------------------------------
#  GUILLOTINE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:GUILLOTINE) do
  factor = @targetSprite.zoom_x
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(8,true)
  factor = @targetSprite.zoom_x
  cx, cy = @targetSprite.getCenter(true)
  shake  = 10
  idx =  0 # counter
  dir = -1 # direction
  userOX = @userSprite.ox
  j = 0
  # set up animation
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb129_bg")
  fp["bg"].opacity = 0
  fp["claw"] = Sprite.new(@viewport)
  fp["claw"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb602_4")
  fp["claw"].ox = fp["claw"].bitmap.width/2
  fp["claw"].oy = fp["claw"].bitmap.height/2
  fp["claw"].x = cx
  fp["claw"].y = cy
  fp["claw"].zoom_x = factor
  fp["claw"].zoom_y = factor
  fp["claw"].src_rect.height = 0
  fp["claw"].z = @targetSprite.z + 1
  pbSEPlay("EBDX/Anim/ground1",75)
  @scene.wait(1,true)
  flashStart = 2
  8.times do
    fp["bg"].opacity += 24
    @scene.wait(1,true)
  end
  for i in 1..11
    if i.between?(1,5)
      @targetSprite.still
      @targetSprite.zoom_y-=0.05*factor
      @targetSprite.tone.all-=12.8
    end
	if j == 0 && i == 6
	  for k in 0...16
		@targetSprite.zoom_y+=0.05*factor if k.between?(flashStart,flashStart+2)
		@targetSprite.tone.all+=12.8 if k.between?(flashStart,flashStart+2)
		@scene.wait(1,true)
		pbSEPlay("EBDX/Anim/normal3",85) if k == 4
		fp["claw"].src_rect.height += 30
		fp["claw"].opacity -= 60 if k >= 10
		if k.between?(0,16)
			@targetSprite.still
			if dir == -1 #move left 
				@targetSprite.ox -= shake
			else # move right
				@targetSprite.ox += shake
			end
		  idx += 1 
		  if idx == 2
			idx = 0
			dir = dir * -1
		  end
		end
		@scene.wait(1,true)
	  end
	  j = 1
	end
    @scene.wait(1,true)
  end
  16.times do
    fp["bg"].opacity -= 25
    @scene.wait(1,true)
  end
  @userSprite.ox = userOX
  pbDisposeSpriteHash(fp)
  @vector.reset if !@multiHit
end
#-------------------------------------------------------------------------------
