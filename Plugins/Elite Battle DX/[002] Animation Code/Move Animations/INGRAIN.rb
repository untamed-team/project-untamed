#-------------------------------------------------------------------------------
#  INGRAIN
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:INGRAIN) do
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  fp = {}
  # ini param
  factor = @targetIsPlayer ? 2 : 1.5
  roots = 3
  idx = []
  # ini fp
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(113,218,81))
  fp["bg"].opacity = 0
  for i in 0...roots
	  fp["seed#{i}"] = Sprite.new(@viewport)
	  fp["seed#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb625")
	  if rand(1) == 0
		fp["seed#{i}"].mirror = true
	  end
	  fp["seed#{i}"].src_rect.set(0,32*rand(3),32,32)
	  fp["seed#{i}"].ox = 16
	  fp["seed#{i}"].oy = 32
	  fp["seed#{i}"].zoom = @targetIsPlayer ? rand(5..6) : rand(3..4)
	  fp["seed#{i}"].opacity = 0
	  fp["seed#{i}"].z = @targetSprite.z + 100
	  idx[i] = 0
  end
  # set up animation
  @scene.wait(5,true)
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end
  for i in 0...roots
	  fp["seed#{i}"].x, fp["seed#{i}"].y = @targetSprite.getCenter(true)
	  fp["seed#{i}"].x += 40 * factor * (i-1) 
	  fp["seed#{i}"].y += 90
  end
  for i in 0...50
	for m in 0...roots
		next if (m == 1 && i < 10) || (m == 2 && i <20)
		fp["seed#{m}"].opacity += 16 
	end 
	if i%2 == 0
		for j in 0...roots
			next if (j == 1 && i < 10) || (j == 2 && i <20)
			if fp["seed#{j}"].tone.all < 10
				fp["seed#{j}"].tone.all += 10
			else 
				fp["seed#{j}"].tone.all -= 10 
			end
			fp["seed#{j}"].src_rect.x += 32 if i%10==0 && fp["seed#{j}"].src_rect.x < 32*3
			pbSEPlay("Anim/LeechSeedThrowing") if i%10 == 0 && i <= 20
			pbSEPlay("Anim/LeechSeedGrowing") if i%5 == 0
			if fp["seed#{j}"].src_rect.x == 32*3 && idx[j] < 2
				pbSEPlay("Anim/LeechSeedPlanted")  
				idx[j] += 1
			end
		end
	end
    #@scene.wait(2,true) if i%2 == 0
    @scene.wait(1,true)
  end
  16.times do
    fp["bg"].opacity -= 10
	for i in 0...roots
		fp["seed#{i}"].opacity -= 15
	end
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
