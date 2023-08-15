#-------------------------------------------------------------------------------
#  PRESENT
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:PRESENT) do | args |
  bomb = args[0]; bomb = true if bomb.nil?
  fp = {}
  fp["bone"] = Sprite.new(@viewport)
  fp["bone"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb635")
  fp["bone"].z = @targetSprite.z + 1
  fp["bone"].opacity = 0
  timeFactor = 40
  # shooting out the bone
  pbSEPlay("Anim/Saint9")
  for i in 0...timeFactor
	#pbSEPlay("Anim/wind7") if i%5 == 0
	fp["bone"].opacity += 50 if fp["bone"].opacity < 250
	fp["bone"].ox = fp["bone"].bitmap.width/2
    fp["bone"].oy = fp["bone"].bitmap.height/2
    cxT, cyT = @targetSprite.getCenter(true)
    cxP, cyP = @userSprite.getAnchor(true)
    mx = @vector.x + (@vector.x2 - @vector.x)*0.5
    points = calculateCurve(cxP,cyP,mx,-32,cxT,cyT,timeFactor)
    fp["bone"].x = points[i][0]
    fp["bone"].y = points[i][1]
    z = 1 + (1-(fp["bone"].x - @vector.x).to_f/(@vector.x2 - @vector.x))
    fp["bone"].zoom_x = z
    fp["bone"].zoom_y = z
	fp["bone"].angle += 30
    fp["bone"].update
    @scene.wait(1,true)
  end
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  fp["bone"].dispose
  # zooming onto the target
  if $game_switches[212] == true
	  EliteBattle.playCommonAnimation(:SPARKLE_YELLOW, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  else
	  EliteBattle.playCommonAnimation(:EXPLOSION, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  end
  @scene.wait(10,true)
  pbDisposeSpriteHash(fp)
  @vector.reset
end
