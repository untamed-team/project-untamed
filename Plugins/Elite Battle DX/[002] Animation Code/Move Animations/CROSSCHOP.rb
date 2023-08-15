#-------------------------------------------------------------------------------
#  CROSSCHOP
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:CROSSCHOP) do
  EliteBattle.playMoveAnimation(:BULKUP, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  factor = @targetSprite.zoom_x
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(8,true)
  factor = @targetSprite.zoom_x
  cx, cy = @targetSprite.getCenter(true)
  j = 0
  rndx = []
  rndy = []
  # set up animation
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(131,84,42))
  fp["bg"].opacity = 0
  fp["claw"] = Sprite.new(@viewport)
  fp["claw"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb602_8")
  fp["claw"].ox = fp["claw"].bitmap.width/2
  fp["claw"].oy = fp["claw"].bitmap.height/2
  fp["claw"].x = cx
  fp["claw"].y = cy
  fp["claw"].zoom_x = factor
  fp["claw"].zoom_y = factor
  fp["claw"].src_rect.height = 0
  fp["claw"].z = @targetSprite.z + 1
  for i in 0...16
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb303_2")
    fp["#{i}"].ox = 10
    fp["#{i}"].oy = 10
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 50
    r = rand(3)
    fp["#{i}"].zoom_x = (@targetSprite.zoom_x)*(r==0 ? 1 : 0.5)
    fp["#{i}"].zoom_y = (@targetSprite.zoom_y)*(r==0 ? 1 : 0.5)
    fp["#{i}"].tone = Tone.new(60,60,60)
    rndx.push(rand(128))
    rndy.push(rand(64))
  end
  @scene.wait(1,true)
  flashStart = 2
  for i in 1..20
    if i.between?(1,5)
      @targetSprite.still
      @targetSprite.zoom_y-=0.05*factor
      @targetSprite.tone.all-=12.8
    end
	cx, cy = @targetSprite.getCenter(true)
	for k in 0...16
		next if i < 4
		if j == 0 && i == 6
			fp["bg"].opacity += 45 if k.between?(flashStart,flashStart+2)
			fp["bg"].opacity -= 45 if k.between?(flashStart+3,flashStart+4)
			@targetSprite.still if k.between?(flashStart,flashStart+2)
			@targetSprite.zoom_y+=0.05*factor if k.between?(flashStart,flashStart+2)
			@targetSprite.tone.all+=12.8 if k.between?(flashStart,flashStart+2)
			@scene.wait(1,true)
			pbSEPlay("EBDX/Anim/normal1",100) if k == 4
			fp["claw"].src_rect.height += 15
			fp["claw"].opacity -= 45 if k >= 5
			j = 1 if k == 15		
		end
		#
		if fp["#{k}"].opacity == 0 && fp["#{k}"].visible
			fp["#{k}"].x = cx
			fp["#{k}"].y = cy
		end
		x2 = cx - 64*@targetSprite.zoom_x + rndx[k]*@targetSprite.zoom_x
		y2 = cy - 64*@targetSprite.zoom_y + rndy[k]*@targetSprite.zoom_y
		x0 = fp["#{k}"].x
		y0 = fp["#{k}"].y
		fp["#{k}"].x += (x2 - x0)*0.2
		fp["#{k}"].y += (y2 - y0)*0.2
		fp["#{k}"].zoom_x += 0.01
		fp["#{k}"].zoom_y += 0.01
		if i < 20
			fp["#{k}"].tone.red -= 6; fp["#{k}"].tone.blue -= 6; fp["#{k}"].tone.green -= 6
		end
		if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
			fp["#{k}"].opacity -= 51
		else
			fp["#{k}"].opacity += 51
		end
		fp["#{k}"].visible = false if fp["#{k}"].opacity <= 0
		#
	end
	@scene.wait(1,true)
  end
  @scene.wait(1,true)
  pbDisposeSpriteHash(fp)
  @vector.reset if !@multiHit
end
#-------------------------------------------------------------------------------
