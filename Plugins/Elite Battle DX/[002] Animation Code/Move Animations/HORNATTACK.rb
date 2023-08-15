#-------------------------------------------------------------------------------
#  SPIKECANNON
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SPIKECANNON) do
  EliteBattle.playMoveAnimation(:HORNATTACK, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, true)
end
#-------------------------------------------------------------------------------
#  TWINEEDLE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:TWINEEDLE) do
  EliteBattle.playMoveAnimation(:HORNATTACK, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, true)
end
#-------------------------------------------------------------------------------
#  PECK
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:PECK) do
  EliteBattle.playMoveAnimation(:HORNATTACK, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, true)
end
#-------------------------------------------------------------------------------
#  FELLSTINGER
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:FELLSTINGER) do
  EliteBattle.playMoveAnimation(:HORNATTACK, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, true)
end
#-------------------------------------------------------------------------------
#  FURYATTACK
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:FURYATTACK) do
  EliteBattle.playMoveAnimation(:HORNATTACK, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, true)
end
#-------------------------------------------------------------------------------
#  HORNATTACK
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:HORNATTACK) do | args |
  factor = @targetSprite.zoom_x
  factorHorn = @userIsPlayer ? 1.9 : 2.5
  hornXMove = @userIsPlayer ? 2 : -2
  hornYMove = @userIsPlayer ? 10 : -10
  hornXOffset = @userIsPlayer ? 60 : -120
  hornYOffset = @userIsPlayer ? 60 : -120
  hornMoveHit = @userIsPlayer ? 5 : -5
  hornAngle = @userIsPlayer ? 0 : 180
  userOX = @userSprite.ox
  # set up animation
  fp = {}
  rndx = []
  rndy = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].opacity = 0
  for i in 0...12
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb303_2")
    fp["#{i}"].ox = 10
    fp["#{i}"].oy = 10
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 50
    r = rand(3)
    fp["#{i}"].zoom_x = (@targetSprite.zoom_x)*(r==0 ? 1 : 0.5)
    fp["#{i}"].zoom_y = (@targetSprite.zoom_y)*(r==0 ? 1 : 0.5)
    fp["#{i}"].tone = Tone.new(60,60,60)
    rndx.push(rand(128))
    rndy.push(rand(64))
  end
  # phase 1
  if @hitNum == 0 #&& @multiHit
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
  end
  # phase 2
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(12,true)
  factor = @targetSprite.zoom_y
  pbSEPlay("EBDX/Anim/normal1",80)
  frame = Sprite.new(@viewport)
  frame.z = 50
  frame.bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb303")
  frame.src_rect.set(0,0,64,64)
  frame.ox = 32
  frame.oy = 32
  frame.zoom_x = 0.5*factor
  frame.zoom_y = 0.5*factor
  frame.x, frame.y = @targetSprite.getCenter(true)
  frame.opacity = 0
  frame.tone = Tone.new(255,255,255)
  frame.y -= 32*@targetSprite.zoom_y
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
  for i in 1..30
	if i.between?(1,15)
		fp["horn"].opacity += 20
		fp["horn"].x += hornMoveHit 
		fp["horn"].y -= hornMoveHit
	else
		fp["horn"].opacity -= 20
	end
    if i.between?(1,5)
      @targetSprite.still
      @targetSprite.zoom_y-=0.05*factor
      @targetSprite.tone.all-=12.8
      frame.zoom_x += 0.1*factor
      frame.zoom_y += 0.1*factor
      frame.opacity += 51
    end
    frame.tone = Tone.new(0,0,0) if i == 6
    if i.between?(6,10)
      @targetSprite.still
      @targetSprite.zoom_y+=0.05*factor
      @targetSprite.tone.all+=12.8
      frame.angle += 2
    end
    frame.src_rect.x = 64 if i == 10
    if i >= 10
      frame.opacity -= 25.5
      frame.zoom_x += 0.1*factor
      frame.zoom_y += 0.1*factor
      frame.angle += 2
    end
    for j in 0...12
      cx = frame.x; cy = frame.y
      if fp["#{j}"].opacity == 0 && fp["#{j}"].visible
        fp["#{j}"].x = cx
        fp["#{j}"].y = cy
      end
      x2 = cx - 64*@targetSprite.zoom_x + rndx[j]*@targetSprite.zoom_x
      y2 = cy - 64*@targetSprite.zoom_y + rndy[j]*@targetSprite.zoom_y
      x0 = fp["#{j}"].x
      y0 = fp["#{j}"].y
      fp["#{j}"].x += (x2 - x0)*0.2
      fp["#{j}"].y += (y2 - y0)*0.2
      fp["#{j}"].zoom_x += 0.01
      fp["#{j}"].zoom_y += 0.01
      if i < 20
        fp["#{j}"].tone.red -= 6; fp["#{j}"].tone.blue -= 6; fp["#{j}"].tone.green -= 6
      end
      if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
        fp["#{j}"].opacity -= 51
      else
        fp["#{j}"].opacity += 51
      end
      fp["#{j}"].visible = false if fp["#{j}"].opacity <= 0
    end
    @scene.wait
  end
  16.times do
    fp["bg"].opacity -= 20
    @scene.wait(1,true)
  end
  @userSprite.ox = userOX
  frame.dispose
  pbDisposeSpriteHash(fp)
  @vector.reset if !@multiHit
end
