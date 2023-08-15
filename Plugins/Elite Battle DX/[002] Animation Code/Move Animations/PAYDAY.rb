#-------------------------------------------------------------------------------
#  PAYDAY
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:PAYDAY) do | args |
  bomb = args[0]; bomb = true if bomb.nil?
  fp = {}
  fp["ball"] = TrailingSprite.new(@viewport,pbBitmap("Graphics/EBDX/Animations/Moves/eb644"))
  fp["ball"].keyFrame = 1
  fp["ball"].z = @targetSprite.z + 1
  @vector.set(EliteBattle.get_vector(:DUAL))
  @scene.wait(5,true)
  # shooting out the ball
  for i in 0...24
	pbSEPlay("EBDX/Anim/move1") if i == 5
    cxT, cyT = @targetSprite.getCenter(true)
    cxP, cyP = @userSprite.getAnchor(true)
    mx = @vector.x + (@vector.x2 - @vector.x)*0.5
    my = @vector.y + (@vector.y2 - @vector.y)*0.5
    points = calculateCurve(cxP,cyP,mx,0,cxT,cyT,24)
    fp["ball"].x = points[i][0]
    fp["ball"].y = points[i][1]
    z = 1 + (1-(fp["ball"].x - @vector.x).to_f/(@vector.x2 - @vector.x))
    fp["ball"].zoom_x = z
    fp["ball"].zoom_y = z
    fp["ball"].update
	if i.between?(16,8)
		@targetSprite.color.alpha += 18
		@targetSprite.anim = true
		@targetSprite.still
	end
    @scene.wait(1,true)
  end
  @targetSprite.color = Color.new(70,70,70,0)
  fp["ball"].dispose
  # rest of the particles
  for j in 0...32
    fp["p#{j}"] = Sprite.new(@viewport)
	if rand(1)
		fp["p#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb644_2")
	else
		fp["p#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb644_2")
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
	pbSEPlay("Anim/Money") if i == 5 || i == 15 || i == 25
    for j in 0...32
      next if !bomb
      next if i < 8
      next if j > (i-8)*2
      fp["p#{j}"].zoom_x += (1.6 - fp["p#{j}"].zoom_x)*0.01
      fp["p#{j}"].zoom_y += (1.6 - fp["p#{j}"].zoom_y)*0.01
      fp["p#{j}"].x += (fp["p#{j}"].end_x - fp["p#{j}"].x)*0.25
      fp["p#{j}"].y += (fp["p#{j}"].end_y - fp["p#{j}"].y)*0.25
      if fp["p#{j}"].zoom_x >= 0.5
        fp["p#{j}"].opacity -= 16
      end
      fp["p#{j}"].color.alpha -= 8
    end
	@scene.wait(1,i < 8)
  end
  pbDisposeSpriteHash(fp)
  @vector.reset
end