#-------------------------------------------------------------------------------
#  PSYCHOSHIFT
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:PSYCHOSHIFT) do | args |
  bomb = args[0]; bomb = true if bomb.nil?
  fp = {}
  fp["change1"] = TrailingSprite.new(@viewport,pbBitmap("Graphics/EBDX/Animations/Moves/eb645_5"))
  fp["change1"].keyFrame = 1
  fp["change1"].z = @targetSprite.z + 1
  fp["change2"] = TrailingSprite.new(@viewport,pbBitmap("Graphics/EBDX/Animations/Moves/eb645_5"))
  fp["change2"].keyFrame = 1
  fp["change2"].z = @userSprite.z + 1
  # shooting out the change1
  for i in 0...24
    cxT, cyT = @targetSprite.getCenter(true)
    cxP, cyP = @userSprite.getAnchor(true)
    mx = @vector.x + (@vector.x2 - @vector.x)*0.5
    points = calculateCurve(cxP,cyP,mx,-32,cxT,cyT,24)
    fp["change1"].x = points[i][0]
    fp["change1"].y = points[i][1]
    z = 1 + (1-(fp["change1"].x - @vector.x).to_f/(@vector.x2 - @vector.x))
    fp["change1"].zoom_x = z
    fp["change1"].zoom_y = z
    fp["change1"].update
    mx = @vector.x + (@vector.x2 - @vector.x)*0.5
    points = calculateCurve(cxT,cyT,mx,32,cxP,cyP,24)
    fp["change2"].x = points[i][0]
    fp["change2"].y = points[i][1]
    z = 1 + (1-(fp["change2"].x - @vector.x).to_f/(@vector.x2 - @vector.x))
    fp["change2"].zoom_x = z
    fp["change2"].zoom_y = z
    fp["change2"].update
    @scene.wait(1,true)
  end
  @vector.set(EliteBattle.get_vector(:DUAL))
  pbSEPlay("Anim/Saint7")
  @targetSprite.color = Color.new(253,161,255,0)
  @userSprite.color = Color.new(253,161,255,0)
  fp["change1"].dispose
  fp["change2"].dispose
  # zooming onto the target
  8.times do
    @targetSprite.color.alpha += 18
    @targetSprite.anim = true
    @targetSprite.still
	@userSprite.color.alpha += 18
    @userSprite.anim = true
    @userSprite.still
    @scene.wait(1,true)
  end
  # rest of the particles
  for j in 0...32
    fp["p#{j}"] = Sprite.new(@viewport)
    fp["p#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb645_6")
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
  for j in 0...32
    fp["p2#{j}"] = Sprite.new(@viewport)
    fp["p2#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb645_6")
    fp["p2#{j}"].center!
    fp["p2#{j}"].x, fp["p2#{j}"].y = @userSprite.getCenter(true)
    r = (40 + rand(24))*@userSprite.zoom_x
    x, y = randCircleCord(r)
    fp["p2#{j}"].end_x = fp["p2#{j}"].x - r + x
    fp["p2#{j}"].end_y = fp["p2#{j}"].y - r + y
    fp["p2#{j}"].zoom_x = 0
    fp["p2#{j}"].zoom_y = 0
    fp["p2#{j}"].angle = rand(360)
    fp["p2#{j}"].z = @userSprite.z + 1
  end
  # sparkle animation
  for i in 0...64
    break if !bomb && i > 15
    for j in 0...32
      next if !bomb
      next if i < 8
      next if j > (i-8)*2
      fp["p#{j}"].zoom_x += (1.6 - fp["p#{j}"].zoom_x)*0.1
      fp["p#{j}"].zoom_y += (1.6 - fp["p#{j}"].zoom_y)*0.1
      fp["p#{j}"].x += (fp["p#{j}"].end_x - fp["p#{j}"].x)*0.1
      fp["p#{j}"].y += (fp["p#{j}"].end_y - fp["p#{j}"].y)*0.1
	  
	  fp["p2#{j}"].zoom_x += (1.6 - fp["p2#{j}"].zoom_x)*0.1
      fp["p2#{j}"].zoom_y += (1.6 - fp["p2#{j}"].zoom_y)*0.1
      fp["p2#{j}"].x += (fp["p2#{j}"].end_x - fp["p2#{j}"].x)*0.1
      fp["p2#{j}"].y += (fp["p2#{j}"].end_y - fp["p2#{j}"].y)*0.1
      if fp["p#{j}"].zoom_x >= 1
        fp["p#{j}"].opacity -= 16
      end
	  if fp["p2#{j}"].zoom_x >= 1
        fp["p2#{j}"].opacity -= 16
      end
      fp["p#{j}"].color.alpha -= 8
      fp["p2#{j}"].color.alpha -= 8
    end
    @targetSprite.color.alpha -= 16 if i >= 48
    @targetSprite.anim = true
    @targetSprite.still
	@userSprite.color.alpha -= 16 if i >= 48
    @userSprite.anim = true
    @userSprite.still
    @scene.wait(1,i < 8)
  end
  pbDisposeSpriteHash(fp)
  @vector.reset
end