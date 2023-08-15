#-------------------------------------------------------------------------------
#  PHANTOMFORCE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:PHANTOMFORCE) do
  EliteBattle.playMoveAnimation(:SHADOWFORCE, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  SHADOWFORCE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SHADOWFORCE) do
  if @hitNum == 1
    EliteBattle.playMoveAnimation(:SHADOWFORCE_HIDE, @scene, @userIndex, @targetIndex)
  elsif @hitNum == 0
    EliteBattle.playMoveAnimation(:SHADOWFORCE_ATTACK, @scene, @userIndex, @targetIndex)
  end
end

EliteBattle.defineMoveAnimation(:SHADOWFORCE_HIDE) do | args |
  withvector, shake = *args; withvector = true if withvector.nil?; shake = false if shake.nil?
  withvector = true
  @vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
  fp = {}
  rndx = []
  rndy = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].opacity = 0
  # set up animation
  @scene.wait(5,true)
  # charge
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end
  shake = 2
  idx =  0 # counter
  dir = -1 # direction
  ports = 25
  xOrigin = @userSprite.ox
  for i in 0...ports
    pbSEPlay("EBDX/Anim/ghost1",80) if i == 4
	pbSEPlay("Anim/NightShade",80) if i == 15
    @userSprite.still
	#default movement
	if i == 3
		@userSprite.ox += shake
	end
    if i.between?(4,ports)
		if dir == -1 #move left 
			@userSprite.ox -= shake
		else # move right
		    @userSprite.ox += shake
		end
		@userSprite.opacity -= 5
	  idx += 1 
	  if idx == 2
		idx = 0
		dir = dir * -1
	  end
    end
	if i.between?(14,ports)
		@userSprite.opacity -= 35
	end
    @scene.wait(1,true)
  end
  @userSprite.visible = false
  @userSprite.hidden = true
  16.times do
    fp["bg"].opacity -= 20
	@userSprite.opacity += 20
    @scene.wait(1,true)
  end
  @userSprite.ox = @userSprite.bitmap.width/2
  #frame.dispose
  pbDisposeSpriteHash(fp)
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end

EliteBattle.defineMoveAnimation(:SHADOWFORCE_ATTACK) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  # set up animation
  frame = []
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb614_bg_8")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  @vector.set(vector)
  @scene.wait(16,true)
  cx, cy = @targetSprite.getCenter
  fp["flare"] = Sprite.new(@viewport)
  fp["flare"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb614_9")
  fp["flare"].ox = fp["flare"].bitmap.width/2
  fp["flare"].oy = fp["flare"].bitmap.height/2
  fp["flare"].x = cx
  fp["flare"].y = cy
  fp["flare"].zoom_x = @targetSprite.zoom_x
  fp["flare"].zoom_y = @targetSprite.zoom_y
  fp["flare"].z = @targetSprite.z
  fp["flare"].opacity = 0
  for j in 0...3
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb244_9")
    fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
    fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
    fp["#{j}"].x = cx - 32 + rand(64)
    fp["#{j}"].y = cy - 32 + rand(64)
    fp["#{j}"].z = @targetSprite.z + 1
    fp["#{j}"].visible = false
    fp["#{j}"].zoom_x = @targetSprite.zoom_x
    fp["#{j}"].zoom_y = @targetSprite.zoom_y
  end
  for m in 0...12
    fp["p#{m}"] = Sprite.new(@viewport)
    fp["p#{m}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb614_10")
    fp["p#{m}"].ox = fp["p#{m}"].bitmap.width/2
    fp["p#{m}"].oy = fp["p#{m}"].bitmap.height/2
    fp["p#{m}"].x = cx - 48 + rand(96)
    fp["p#{m}"].y = cy - 48 + rand(96)
    fp["p#{m}"].z = @targetSprite.z + 2
    fp["p#{m}"].visible = false
    fp["p#{m}"].zoom_x = @targetSprite.zoom_x
    fp["p#{m}"].zoom_y = @targetSprite.zoom_y
  end
  @targetSprite.color = Color.new(0,0,0,0)
  for i in 0...64
    fp["bg"].opacity += 16 if fp["bg"].opacity < 255 && i < 32
    fp["bg"].color.alpha -= 32 if fp["bg"].color.alpha > 0
    fp["flare"].opacity += 32*(i < 8 ? 1 : -1)
    fp["flare"].angle += 32
    pbSEPlay("EBDX/Anim/ghost3",80) if i == 8
    pbSEPlay("Anim/Comet Punch",80) if i == 8
	@userSprite.visible = true
    @userSprite.hidden = false
    for j in 0...3
      next if i < 12
      next if j>(i-12)/4
      fp["#{j}"].visible = true
      fp["#{j}"].opacity -= 16
      fp["#{j}"].angle += 16
      fp["#{j}"].zoom_x += 0.1
      fp["#{j}"].zoom_y += 0.1
    end
    for m in 0...12
      next if i < 6
      next if m>(i-6)
      fp["p#{m}"].visible = true
      fp["p#{m}"].opacity -= 16
      fp["p#{m}"].y -= 8
    end
    if i >= 48
      fp["bg"].opacity -= 16
      @targetSprite.color.alpha -= 16
    else
      @targetSprite.color.alpha += 16 if @targetSprite.color.alpha < 192
    end
    @targetSprite.anim = true
    @scene.wait
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end

