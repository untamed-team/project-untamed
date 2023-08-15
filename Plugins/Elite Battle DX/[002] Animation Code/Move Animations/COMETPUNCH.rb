#-------------------------------------------------------------------------------
#  BELLYDRUM
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:BELLYDRUM) do
  EliteBattle.playMoveAnimation(:COMETPUNCH, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  COMETPUNCH
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:COMETPUNCH) do
  # configure animation
  fp = {};
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(16,true)
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
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
