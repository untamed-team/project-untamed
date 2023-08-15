#-------------------------------------------------------------------------------
#  TRIATTACK
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:TRIATTACK) do | args |
  bomb = args[0]; bomb = true if bomb.nil?
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].opacity = 0
  fp["tri"] = Sprite.new(@viewport)
  fp["tri"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb629")
  fp["tri"].z = @targetSprite.z + 1
  fp["tri"].opacity = 0
  timeFactor = 40
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end
  # shooting out the tri
  for i in 0...timeFactor
	pbSEPlay("Anim/Psych Up") if i%20 == 0
	fp["tri"].opacity += 50 if fp["tri"].opacity < 250
	fp["tri"].ox = fp["tri"].bitmap.width/2
    fp["tri"].oy = fp["tri"].bitmap.height/2
    cxT, cyT = @targetSprite.getCenter(true)
    cxP, cyP = @userSprite.getAnchor(true)
    mx = @vector.x + (@vector.x2 - @vector.x)*0.5
    my = @vector.y + (@vector.y2 - @vector.y)*0.5
    points = calculateCurve(cxP,cyP,mx,my,cxT,cyT,timeFactor)
    fp["tri"].x = points[i][0]
    fp["tri"].y = points[i][1]
    z = 1 + (1-(fp["tri"].x - @vector.x).to_f/(@vector.x2 - @vector.x))
    fp["tri"].zoom_x = z
    fp["tri"].zoom_y = z
	fp["tri"].angle += 30
    fp["tri"].update
    @scene.wait(1,true)
  end
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  pbSEPlay("Anim/Psych Up")
  fp["tri"].dispose
  @scene.wait(10,true)
  # zooming onto the target
  EliteBattle.playCommonAnimation(:BURN, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  EliteBattle.playCommonAnimation(:PARALYSIS, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  EliteBattle.playCommonAnimation(:FROZEN, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  16.times do
    fp["bg"].opacity -= 20
    @scene.wait(1,true)
  end
  pbDisposeSpriteHash(fp)
  @vector.reset
end
