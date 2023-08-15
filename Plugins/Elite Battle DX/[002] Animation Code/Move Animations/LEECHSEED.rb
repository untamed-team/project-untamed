#-------------------------------------------------------------------------------
#  WORRYSEED
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:WORRYSEED) do
  EliteBattle.playMoveAnimation(:LEECHSEED, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  LEECHSEED
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:LEECHSEED) do | args |
  bomb = args[0]; bomb = true if bomb.nil?
  fp = {}
  fp["seed"] = Sprite.new(@viewport)
  fp["seed"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb223")
  fp["seed"].z = @targetSprite.z + 1
  fp["seed"].opacity = 0
  timeFactor = 40
  # shooting out the seed
  for i in 0...timeFactor
	pbSEPlay("EBDX/Anim/poison1") if i == 0
	fp["seed"].opacity += 50 if fp["seed"].opacity < 250
	fp["seed"].ox = fp["seed"].bitmap.width/2
    fp["seed"].oy = fp["seed"].bitmap.height/2
    cxT, cyT = @targetSprite.getCenter(true)
    cxP, cyP = @userSprite.getAnchor(true)
    mx = @vector.x + (@vector.x2 - @vector.x)*0.5
    points = calculateCurve(cxP,cyP,mx,-32,cxT,cyT,timeFactor)
    fp["seed"].x = points[i][0]
    fp["seed"].y = points[i][1]
    z = 1 + (1-(fp["seed"].x - @vector.x).to_f/(@vector.x2 - @vector.x))
    fp["seed"].zoom_x = z
    fp["seed"].zoom_y = z
	fp["seed"].angle += 30
    fp["seed"].update
    @scene.wait(1,true)
  end
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  pbSEPlay("EBDX/Anim/poison1")
  fp["seed"].dispose
  EliteBattle.playMoveAnimation(:INGRAIN, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  # zooming onto the target
  5.times do
    @targetSprite.color.alpha += 18
    @targetSprite.anim = true
    @targetSprite.still
    @scene.wait(1,true)
  end
  @scene.wait(10,true)
  pbDisposeSpriteHash(fp)
  @vector.reset
end
