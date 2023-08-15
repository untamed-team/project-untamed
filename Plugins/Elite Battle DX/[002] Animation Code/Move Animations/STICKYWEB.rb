#-------------------------------------------------------------------------------
#  STICKYWEB
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:STICKYWEB) do | args |
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
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(229,255,204))
  fp["bg"].opacity = 0
  fp["spike"] = TrailingSprite.new(@viewport,pbBitmap("Graphics/EBDX/Animations/Moves/eb223_3"))
  fp["spike"].keyFrame = 1
  fp["spike"].z = @targetSprite.z + 30
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end
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
	@scene.wait(15,true)
	fp["net"] = Sprite.new(@viewport)
	fp["net"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb621")
	fp["net"].center!
	fp["net"].x = cxS
	fp["net"].y = cyS
	fp["net"].zoom_x = 0
	fp["net"].zoom_y = 0
	fp["net"].angle = rand(360)
	fp["net"].z = @targetSprite.z + 30
  # spike shatter animation
  for i in 0...64
    break if !bomb && i > 15
	pbSEPlay("Anim/Splat",90) if i == 5
    next if !bomb
    next if i < 8
    fp["net"].zoom_x += (1.6 - fp["net"].zoom_x)*0.1
    fp["net"].zoom_y += (1.6 - fp["net"].zoom_y)*0.1
	if fp["net"].zoom_x >= 1
      fp["net"].opacity -= 16
    end
      fp["net"].color.alpha -= 8
	@scene.wait(1,i < 8)
  end
  16.times do
    fp["bg"].opacity -= 20
    @scene.wait(1,true)
  end
  pbDisposeSpriteHash(fp)
  @vector.reset
end
