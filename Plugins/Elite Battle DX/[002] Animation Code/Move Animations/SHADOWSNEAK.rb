#-------------------------------------------------------------------------------
#  SHADOWSNEAK
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SHADOWSNEAK) do | args |
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
  shake = 30
  idx =  0 # counter
  dir = -1 # direction
  ports = 25
  xOrigin = @userSprite.ox
  for i in 0...ports
    pbSEPlay("EBDX/Anim/move1",80) if i == 4
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
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer)) if withvector
  @scene.wait(10,true)
  EliteBattle.playCommonAnimation(:GRUDGE, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
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
