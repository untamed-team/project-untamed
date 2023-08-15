#-------------------------------------------------------------------------------
#  HONECLAWS
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:HONECLAWS) do
  EliteBattle.playMoveAnimation(:NASTYPLOT, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  COSMICPOWER
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:COSMICPOWER) do
  EliteBattle.playMoveAnimation(:NASTYPLOT, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  GRAVITY
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:GRAVITY) do
  EliteBattle.playMoveAnimation(:NASTYPLOT, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  NASTYPLOT
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:NASTYPLOT) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  # set up animation
  fp = {}
  speed = []
  for j in 0...32
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].z = @userIsPlayer ? 29 : 19
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb615_5")
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
  @userSprite.color = Color.new(64,64,64,0)
  # start animation
  @vector.set(vector2)
  @vector.inc = 0.1
  oy = @userSprite.oy
  k = -1
  for i in 0...64
    k *= -1 if i%4==0
    pbSEPlay("EBDX/Anim/dragon2") if i == 12
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
  @userSprite.oy = oy
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
