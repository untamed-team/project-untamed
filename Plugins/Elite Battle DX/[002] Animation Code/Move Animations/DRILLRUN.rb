#-------------------------------------------------------------------------------
#  DRILLRUN
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:DRILLRUN) do | args |
  factor = @targetSprite.zoom_x
  factorHorn = @userIsPlayer ? 1.9 : 2.5
  hornXMove = @userIsPlayer ? 2 : -2
  hornYMove = @userIsPlayer ? 10 : -10
  hornXOffset = @userIsPlayer ? 100 : -120
  hornYOffset = @userIsPlayer ? 100 : -120
  hornMoveHit = @userIsPlayer ? 3 : -3
  hornAngle = @userIsPlayer ? 0 : 180
  userOX = @userSprite.ox
  # set up animation
  fp = {}
  rndx = []
  rndy = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(131,92,42))
  fp["bg"].opacity = 0
  # phase 1
  @vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end
  # user move
  for i in 0...30
    @userSprite.still
	#default movement
    if i.between?(0,20)
		@userSprite.ox += hornXMove
	else
		@userSprite.ox -= hornYMove
    end
    @scene.wait(1,true)
  end
  # phase 2
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(7,true)
  factor = @targetSprite.zoom_y
  pbSEPlay("EBDX/Anim/normal1",80)
  fp["horn"] = Sprite.new(@viewport)
  fp["horn"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb626")
  fp["horn"].ox = fp["horn"].bitmap.width/2
  fp["horn"].oy = fp["horn"].bitmap.height/2
  fp["horn"].x, fp["horn"].y = @targetSprite.getCenter(true)
  fp["horn"].x -= hornXOffset
  fp["horn"].y += hornYOffset
  fp["horn"].opacity = 0
  fp["horn"].zoom = factorHorn
  fp["horn"].angle = hornAngle
  fp["horn"].z = 41
  # horn attack
  for i in 1..20
	if i.between?(1,15)
		fp["horn"].opacity += 20
		fp["horn"].x += hornMoveHit 
		fp["horn"].y -= hornMoveHit
	else
		fp["horn"].opacity -= 50
	end
	@scene.wait(1,true)
  end
  # phase 3
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(10,true)
  factor = @targetSprite.zoom_x
  cx, cy = @targetSprite.getCenter(true)
  for j in 0...12
    fp["s#{j}"] = Sprite.new(@viewport)
    fp["s#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb244_2")
    fp["s#{j}"].ox = fp["s#{j}"].bitmap.width/2
    fp["s#{j}"].oy = fp["s#{j}"].bitmap.height/2
    r = 32*factor
    fp["s#{j}"].x = cx - r + rand(r*2)
    fp["s#{j}"].y = cy - r + rand(r*2)
    fp["s#{j}"].z = @targetSprite.z + 1
    fp["s#{j}"].visible = false
    fp["s#{j}"].tone = Tone.new(255,255,255)
    fp["s#{j}"].angle = rand(360)
  end
  # anim2
  for i in 0...32
    for j in 0...12
      next if j>(i*2)
      fp["s#{j}"].visible = true
      fp["s#{j}"].opacity -= 32
      fp["s#{j}"].zoom_x += 0.02
      fp["s#{j}"].zoom_y += 0.02
      fp["s#{j}"].angle += 8
      fp["s#{j}"].tone.red -= 32
      fp["s#{j}"].tone.green -= 32
      fp["s#{j}"].tone.blue -= 32
    end
    @targetSprite.still
    pbSEPlay("EBDX/Anim/normal2",80) if i%4==0 && i < 16
    @scene.wait
  end
  16.times do
    fp["bg"].opacity -= 20
    @scene.wait(1,true)
  end
  @userSprite.ox = userOX
  pbDisposeSpriteHash(fp)
  @vector.reset if !@multiHit
end
