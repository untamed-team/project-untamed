#-------------------------------------------------------------------------------
#  SPIKES
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SPIKES) do | args |
  bomb = args[0]; bomb = true if bomb.nil?
  if @userIndex == 0 || @userIndex == 2
	cxT = 367
	cyT = 168
	cxP = 101
	cyP = 317
	cxS = 270
	cyS = 230
	opp = :ENEMY
	zoom = 1
  else 
	cxP = 367
	cyP = 168
	cxT = 101
	cyT = 317
	cxS = 160
	cyS = 290
	opp = :PLAYER
	zoom = 2
  end
  fp = {}
  fp["spike"] = TrailingSprite.new(@viewport,pbBitmap("Graphics/EBDX/Animations/Moves/eb620"))
  fp["spike"].keyFrame = 1
  fp["spike"].z = @targetSprite.z + 30
  # shooting out the spike
  for i in 0...24
    mx = @vector.x + (@vector.x2 - @vector.x)*0.5
    points = calculateCurve(cxP,cyP,mx,-32,cxT,cyT,24)
    fp["spike"].x = points[i][0]
    fp["spike"].y = points[i][1]
    z = 1 + (1-(fp["spike"].x - @vector.x).to_f/(@vector.x2 - @vector.x))
    fp["spike"].zoom_x = z
    fp["spike"].zoom_y = z
    fp["spike"].update
	pbSEPlay("Anim/Throw",60) if i == 4
    @scene.wait(1,true)
  end
  @vector.set(EliteBattle.get_vector(opp))
  #@targetSprite.color = Color.new(128,128,128,0)
  fp["spike"].dispose
  # rest of the particles
  for j in 0...32
    fp["p#{j}"] = Sprite.new(@viewport)
    fp["p#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb620_2")
    fp["p#{j}"].center!
    fp["p#{j}"].x = cxS
	fp["p#{j}"].y = cyS
    r = (40 + rand(24))*1.5#zoom
    x, y = randCircleCord(r)
    fp["p#{j}"].end_x = fp["p#{j}"].x - r + x
    fp["p#{j}"].end_y = fp["p#{j}"].y - r + y
    fp["p#{j}"].zoom_x = 0
    fp["p#{j}"].zoom_y = 0
    fp["p#{j}"].angle = rand(360)
    fp["p#{j}"].z = @targetSprite.z + 30
    #fp["p#{j}"].color = Color.new(128,128,128)
  end
  # spike shatter animation
  for i in 0...64
    break if !bomb && i > 15
	pbSEPlay("Anim/Spikes1",90) if i == 5
    for j in 0...32
      next if !bomb
      next if i < 8
      next if j > (i-8)*2
      fp["p#{j}"].zoom_x += (1.6 - fp["p#{j}"].zoom_x)*0.1
      fp["p#{j}"].zoom_y += (1.6 - fp["p#{j}"].zoom_y)*0.1
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
