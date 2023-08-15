#-------------------------------------------------------------------------------
#  EXPLOSION
#-------------------------------------------------------------------------------
EliteBattle.defineCommonAnimation(:EXPLOSION) do
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(7,true)
  cx, cy = @targetSprite.getCenter(true)
  dx = []
  dy = []
  factor = @targetSprite.zoom_x
  fp = {}
  for j in 0...24
    fp["#{j}"] = Sprite.new(@viewport)
	if rand(0..1)==0
		fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb010")
	else
		fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb010_2")
	end
    fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
    fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
    r = 64*factor
    x, y = randCircleCord(r)
    x = cx - r + x
    y = cy - r + y
    fp["#{j}"].x = cx
    fp["#{j}"].y = cx
    fp["#{j}"].z = @userSprite.z
    fp["#{j}"].visible = false
    fp["#{j}"].angle = rand(360)
    z = [0.5,1,0.75][rand(3)]
    fp["#{j}"].zoom_x = z
    fp["#{j}"].zoom_y = z
    dx.push(x)
    dy.push(y)
  end
  # rest of the particles
  for i in 0...48
	pbSEPlay("Anim/Explosion1",100) if i%8 == 0
    for j in 0...24
      next if j>(i*2)
      fp["#{j}"].visible = true
      if ((fp["#{j}"].x - dx[j])*0.1).abs < 1
        fp["#{j}"].opacity -= 32
      else
        fp["#{j}"].x -= (fp["#{j}"].x - dx[j])*0.1
        fp["#{j}"].y -= (fp["#{j}"].y - dy[j])*0.1
		fp["#{j}"].color.alpha += rand(-50..50)
      end
    end
	if i.between?(5,19)
		@targetSprite.tone.all-=12
	end
	if i.between?(20,34)
		@targetSprite.tone.all+=12
	end
    @scene.wait
  end
  pbDisposeSpriteHash(fp)
  @vector.reset
end