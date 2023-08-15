#-------------------------------------------------------------------------------
#  PSYCHOBOOST
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:PSYCHOBOOST) do | args |
  EliteBattle.playMoveAnimation(:CALMMIND, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  KINESIS
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:KINESIS) do | args |
  EliteBattle.playMoveAnimation(:CALMMIND, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  LUNARDANCE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:LUNARDANCE) do | args |
  EliteBattle.playMoveAnimation(:CALMMIND, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  TELEKINESIS
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:TELEKINESIS) do | args |
  EliteBattle.playMoveAnimation(:CALMMIND, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  TRICK
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:TRICK) do | args |
  EliteBattle.playMoveAnimation(:CALMMIND, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  CALMMIND
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:CALMMIND) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  # set up animation
  fp = {}
  speed = []
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 6
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb452",true)
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  fp["bg"].oy = fp["bg"].src_rect.height/2
  fp["bg"].y = @viewport.height/2
  shake = 8
  zoom = -1
  #
  for j in 0...32
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].z = @userIsPlayer ? 29 : 19
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb615_4")
    fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
    fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
    fp["#{j}"].color = Color.new(255,255,255,255)
    z = [0.5,1.5,1,0.75,1.25][rand(5)]
    fp["#{j}"].zoom_x = z
    fp["#{j}"].zoom_y = z
    fp["#{j}"].opacity = 0
    speed.push((rand(8)+1)*4)
  end
  for j in 0...8
    fp["s#{j}"] = Sprite.new(@viewport)
    fp["s#{j}"].z = @userIsPlayer ? 29 : 19
    fp["s#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb057_2")
    fp["s#{j}"].ox = fp["s#{j}"].bitmap.width/2
    fp["s#{j}"].oy = fp["s#{j}"].bitmap.height
    #z = [0.5,1.5,1,0.75,1.25][rand(5)]
    fp["s#{j}"].color = Color.new(255,255,255,255)
    #fp["s#{j}"].zoom_y = z
    fp["s#{j}"].opacity = 0
  end
  @userSprite.color = Color.new(255,51,255,0)
  # start animation
  @vector.set(vector2)
  @vector.inc = 0.1
  oy = @userSprite.oy
  k = -1
  for i in 0...64
  pbSEPlay("EBDX/Anim/psychic1",80) if i == 12
    pbSEPlay("EBDX/Anim/psychic2",80) if i == 20
    if i < 10
      fp["bg"].opacity += 25.5
    elsif i < 20
      fp["bg"].color.alpha -= 25.5
    elsif i >= 67
      fp["bg"].color.alpha += 25.5
      @targetSprite.tone.red += 18
      @targetSprite.tone.green += 18
      @targetSprite.tone.blue += 18
      #@targetSprite.zoom_x += 0.04*factor
      #@targetSprite.zoom_y += 0.04*factor
    elsif i >= 40
      @targetSprite.ox += shake
      shake = -8 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 4
      shake = 8 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 4
      @targetSprite.still
    end
    zoom *= -1 if i%2 == 0
    fp["bg"].update
    fp["bg"].zoom_y += 0.04*zoom
	#
    k *= -1 if i%4==0
    #pbSEPlay("EBDX/Anim/dragon2") if i == 12
    cx, cy = @userSprite.getCenter(true)
    for j in 0...32
      next if i < 8
      next if j>(i-8)
      if fp["#{j}"].opacity == 0 && fp["#{j}"].color.alpha == 255
        fp["#{j}"].y = @userSprite.y + 8*@userSprite.zoom_y - rand(24)*@userSprite.zoom_y
        fp["#{j}"].x = cx - 64*@userSprite.zoom_x + rand(128)*@userSprite.zoom_x
      end
      if fp["#{j}"].color.alpha <= 96
        fp["#{j}"].opacity -= 32
      else
        fp["#{j}"].opacity += 32
      end
      fp["#{j}"].color.alpha -= 16
      fp["#{j}"].y -= speed[j]
    end
    for j in 0...8
      next if i < 12
      next if j>(i-12)/2
      if fp["s#{j}"].opacity == 0 && fp["s#{j}"].color.alpha == 255
        fp["s#{j}"].y = @userSprite.y + 48*@userSprite.zoom_y - rand(16)*@userSprite.zoom_y
        fp["s#{j}"].x = cx - 64*@userSprite.zoom_x + rand(128)*@userSprite.zoom_x
      end
      if fp["s#{j}"].color.alpha <= 96
        fp["s#{j}"].opacity -= 32
      else
        fp["s#{j}"].opacity += 32
      end
      fp["s#{j}"].color.alpha -= 16
      fp["s#{j}"].zoom_y += speed[j]*0.25*0.01
      fp["s#{j}"].y -= speed[j]
    end
    if i < 48
      @userSprite.color.alpha += 4
    else
      @userSprite.color.alpha -= 16
    end
    @userSprite.oy -= 2*k if i%2==0
    @userSprite.still
    @userSprite.anim = true
    @scene.wait(1,true)
  end
  10.times do
    fp["bg"].opacity -= 25.5
    @targetSprite.still
	@scene.wait(1,true)
  end
  @userSprite.oy = oy
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
