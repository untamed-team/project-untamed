#-------------------------------------------------------------------------------
#  SEEDBOMB
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SEEDBOMB) do | args |
  bomb = args[0]; bomb = true if bomb.nil?
  factor = @targetSprite.zoom_x
  dx = []
  dy = []
  fp = {}
  fp["bomb"] = TrailingSprite.new(@viewport,pbBitmap("Graphics/EBDX/Animations/Moves/eb223"))
  fp["bomb"].keyFrame = 1
  fp["bomb"].z = @targetSprite.z + 1
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  # shooting out the bomb
  for i in 0...24
	pbSEPlay("Anim/throw") if i == 5
    cxT, cyT = @targetSprite.getCenter(true)
    cxP, cyP = @userSprite.getAnchor(true)
    mx = @vector.x + (@vector.x2 - @vector.x)*0.5
    points = calculateCurve(cxP,cyP,mx,-32,cxT,cyT,24)
    fp["bomb"].x = points[i][0]
    fp["bomb"].y = points[i][1]
    z = 1 + (1-(fp["bomb"].x - @vector.x).to_f/(@vector.x2 - @vector.x))
    fp["bomb"].zoom_x = z *2
    fp["bomb"].zoom_y = z *2
    fp["bomb"].update
	if i.between?(16,8)
		@targetSprite.color.alpha += 18
		@targetSprite.anim = true
		@targetSprite.still
	end
    @scene.wait(1,true)
  end
  @targetSprite.color = Color.new(74,4,4,0)
  fp["bomb"].dispose
  # zooming onto the target
  8.times do
    @targetSprite.color.alpha += 18
    @targetSprite.anim = true
    @targetSprite.still
    @scene.wait(1,true)
  end
  cx, cy = @targetSprite.getCenter(true)
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
    @scene.wait
  end
  pbDisposeSpriteHash(fp)
  @vector.reset
end