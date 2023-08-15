#-------------------------------------------------------------------------------
#  INFESTATION
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:INFESTATION) do
  # configure animation
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(16,true)
  factor = @targetSprite.zoom_x
  cx, cy = @targetSprite.getCenter(true)
  dx = []
  dy = []
  fp = {}
  numElements = 60
  for j in 0...numElements
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb010_5")
    fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
    fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
    r = 45*factor
    x, y = randCircleCord(r)
    x = cx - r + x
    y = cy - r + y
    fp["#{j}"].x = cx
    fp["#{j}"].y = cy
    fp["#{j}"].z = @targetSprite.z + 1
    fp["#{j}"].visible = false
    fp["#{j}"].angle = rand(360)
    z = [0.5,1,0.75][rand(3)]
    fp["#{j}"].zoom_x = z
    fp["#{j}"].zoom_y = z
    dx.push(x)
    dy.push(y)
  end
  # target coloring
  @targetSprite.color = Color.new(11,50,10,0)
  # start animation
  pbSEPlay("EBDX/Anim/ground1",80)
  for i in 0...48
    for j in 0...numElements
      next if j>(i*2)
      fp["#{j}"].visible = true
      if ((fp["#{j}"].x - dx[j])*0.1).abs < 1
        fp["#{j}"].opacity -= 32
      else
        fp["#{j}"].x -= (fp["#{j}"].x - dx[j])*0.1
        fp["#{j}"].y -= (fp["#{j}"].y - dy[j])*0.1
      end
    end
	if i < 24
      @targetSprite.color.alpha += 10
    else
      @targetSprite.color.alpha -= 10
    end
	@targetSprite.still
    @targetSprite.anim = true
    @scene.wait
  end
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
