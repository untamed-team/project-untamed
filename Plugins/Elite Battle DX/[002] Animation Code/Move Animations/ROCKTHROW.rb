#-------------------------------------------------------------------------------
#  ROCKTOMB
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:ROCKTOMB) do
  EliteBattle.playMoveAnimation(:ROCKTHROW, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  ROCKTHROW
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:ROCKTHROW) do
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(12, true)
  # set up animation
  dy = @vector.y2/12
  fp = {}; da = []; 
  if @targetIsPlayer
	factors = 2
  else
	factors = 1
  end	
  stones = 20
  for j in 0...stones
      fp["r#{j}"] = Sprite.new(@viewport)
      fp["r#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb504")
      fp["r#{j}"].ox = fp["r#{j}"].bitmap.width/2
      fp["r#{j}"].oy = fp["r#{j}"].bitmap.height/2
	  r = 64*factors
      z = [1,0.5,0.75,0.25][rand(4)]
      fp["r#{j}"].zoom_x = z
      fp["r#{j}"].zoom_y = z
      fp["r#{j}"].x = @targetSprite.x - r + rand(r*2)
      fp["r#{j}"].y = rand(32*factors)
      fp["r#{j}"].visible = false
      fp["r#{j}"].angle = rand(360)
      fp["r#{j}"].z = @targetSprite.z + 1
      da.push(rand(2)==0 ? 1 : -1)
    end
    width = @targetSprite.bitmap.width/2 - 16
    max = 16# + (width/16)
    for j in 0...max
      fp["d#{j}"] = Sprite.new(@viewport)
      fp["d#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebDustParticle")
      fp["d#{j}"].ox = fp["d#{j}"].bitmap.width/2
      fp["d#{j}"].oy = fp["d#{j}"].bitmap.height/2
      fp["d#{j}"].opacity = 0
      fp["d#{j}"].angle = rand(360)
      fp["d#{j}"].x = @targetSprite.x - width*factors + rand(width*2*factors)
      fp["d#{j}"].y = @targetSprite.y - 16*factors + rand(32*factors)
      fp["d#{j}"].z = @targetSprite.z + (fp["d#{j}"].y < @targetSprite.y ? -1 : 1)
      zoom = [1,0.8,0.9,0.7][rand(4)]
      fp["d#{j}"].zoom_x = zoom*factors
      fp["d#{j}"].zoom_y = zoom*factors
    end
  # start animation
  for i in 0...30
    pbSEPlay("EBDX/Anim/rock2",70) if i%8==0
      for j in 0...stones
        next if j>(i*2)
        fp["r#{j}"].y += dy
        fp["r#{j}"].visible = fp["r#{j}"].y < @targetSprite.y - 16*factors
        fp["r#{j}"].angle += 8*da[j]
      end
      for j in 0...max
        next if i < 8
        next if j>(i-8)/2
        fp["d#{j}"].opacity += 25.5 if i < 18+j*2
        fp["d#{j}"].opacity -= 25.5 if i >= 22+j*2
        if fp["d#{j}"].x >= @targetSprite.x
          fp["d#{j}"].angle += 4
          fp["d#{j}"].x += 2
        else
          fp["d#{j}"].angle -= 4
          fp["d#{j}"].x -= 2
        end
      end
      if i >= 8 && i < 15
        @targetSprite.zoom_y -= 0.04*factors
        @targetSprite.zoom_x += 0.02*factors
        @targetSprite.still
      end
    @scene.wait
  end
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
