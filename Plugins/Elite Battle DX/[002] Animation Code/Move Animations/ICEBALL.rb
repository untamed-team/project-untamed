#-------------------------------------------------------------------------------
#  ICEBALL
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:ICEBALL) do | args |
  bomb = args[0]; bomb = true if bomb.nil?
  fp = {}
  fp["iceball"] = TrailingSprite.new(@viewport,pbBitmap("Graphics/EBDX/Animations/Moves/eb627"))
  fp["iceball"].keyFrame = 1
  fp["iceball"].z = @targetSprite.z + 1
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  # shooting out the iceball
  for i in 0...24
	pbSEPlay("EBDX/Anim/ice1") if i == 5
    cxT, cyT = @targetSprite.getCenter(true)
    cxP, cyP = @userSprite.getAnchor(true)
    mx = @vector.x + (@vector.x2 - @vector.x)*0.5
    points = calculateCurve(cxP,cyP,mx,-32,cxT,cyT,24)
    fp["iceball"].x = points[i][0]
    fp["iceball"].y = points[i][1]
    z = 1 + (1-(fp["iceball"].x - @vector.x).to_f/(@vector.x2 - @vector.x))
    fp["iceball"].zoom_x = z
    fp["iceball"].zoom_y = z
    fp["iceball"].update
	if i.between?(16,8)
		@targetSprite.color.alpha += 18
		@targetSprite.anim = true
		@targetSprite.still
	end
    @scene.wait(1,true)
  end
  @targetSprite.color = Color.new(204,255,255,0)
  fp["iceball"].dispose
  # zooming onto the target
  # 8.times do
    # @targetSprite.color.alpha += 18
    # @targetSprite.anim = true
    # @targetSprite.still
    # @scene.wait(1,true)
  # end
  # rest of the particles
  for j in 0...32
    fp["p#{j}"] = Sprite.new(@viewport)
	if rand(1)
		fp["p#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb627_2")
	else
		fp["p#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb627_3")
	end
    fp["p#{j}"].center!
    fp["p#{j}"].x, fp["p#{j}"].y = @targetSprite.getCenter(true)
    r = (40 + rand(24))*@targetSprite.zoom_x
    x, y = randCircleCord(r)
    fp["p#{j}"].end_x = fp["p#{j}"].x - r + x
    fp["p#{j}"].end_y = fp["p#{j}"].y - r + y
    fp["p#{j}"].zoom_x = 0
    fp["p#{j}"].zoom_y = 0
    fp["p#{j}"].angle = rand(360)
    fp["p#{j}"].z = @targetSprite.z + 1
  end
  # spike shatter animation
  for i in 0...64
    break if !bomb && i > 15
	pbSEPlay("EBDX/Anim/ice2") if i == 5
    for j in 0...32
      next if !bomb
      next if i < 8
      next if j > (i-8)*2
      fp["p#{j}"].zoom_x += (1.6 - fp["p#{j}"].zoom_x)*0.03
      fp["p#{j}"].zoom_y += (1.6 - fp["p#{j}"].zoom_y)*0.03
      fp["p#{j}"].x += (fp["p#{j}"].end_x - fp["p#{j}"].x)*0.1
      fp["p#{j}"].y += (fp["p#{j}"].end_y - fp["p#{j}"].y)*0.1
      if fp["p#{j}"].zoom_x >= 1
        fp["p#{j}"].opacity -= 16
      end
      fp["p#{j}"].color.alpha -= 8
    end
	@scene.wait(1,i < 8)
  end
  pbDisposeSpriteHash(fp)
  @vector.reset
end