#-------------------------------------------------------------------------------
#  RAPIDSPIN
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:RAPIDSPIN) do
  @vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
  fp = {}
  # set up animation
  @scene.wait(5,true)
  # extra parameters
  xt,yt = @targetSprite.getCenter(true)
  xp,yp = @userSprite.getCenter(true)
  flashStart = 16
  @scene.wait(16,true)
  # set up animation
  cx, cy = @userSprite.getCenter(true)
  factor = @userSprite.zoom_x
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(200,200,200))
  fp["bg"].opacity = 0
  # init
  for j in 0...5
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb458_9")
    fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
    fp["#{j}"].oy = fp["#{j}"].bitmap.height + 16
    fp["#{j}"].zoom_x = factor*0.75
    fp["#{j}"].zoom_y = factor*0.75
    fp["#{j}"].opacity = 0
    fp["#{j}"].x = cx
    fp["#{j}"].y = cy
    fp["#{j}"].z = @userIsPlayer ? 29 : 19
    fp["#{j}"].angle = 60*j + 30
  end
  fp["ring"] = Sprite.new(@viewport)
  fp["ring"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb458_8")
  fp["ring"].ox = fp["ring"].bitmap.width/2
  fp["ring"].oy = fp["ring"].bitmap.height/2
  fp["ring"].x = cx
  fp["ring"].y = cy
  fp["ring"].zoom_x = 0
  fp["ring"].zoom_y = 0
  fp["ring"].z = @userIsPlayer ? 29 : 19
  # animation
  for i in 0...72#96
	fp["bg"].opacity += 45 if i.between?(flashStart,flashStart+4)
	fp["bg"].opacity -= 45 if i.between?(flashStart+5,flashStart+9)
    @vector.reset if !@multiHit && i == 64
    pbSEPlay("Anim/Psych Up",90) if i == 8
    if i < 16
      fp["ring"].zoom_x += factor/16.0
      fp["ring"].zoom_y += factor/16.0
    elsif i < 64
      for j in 0...5
        fp["#{j}"].zoom_x += 0.05*factor*((i < 24) ? 0.5 : 0.25)
        fp["#{j}"].zoom_y += 0.05*factor*((i < 24) ? 0.5 : 0.25)
        fp["#{j}"].opacity += 32*((i < 24) ? 1 : -1)
      end
      fp["ring"].opacity -= 8
    end
    @scene.wait(1,true)
  end
  EliteBattle.playMoveAnimation(:COMETPUNCH, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  @userSprite.ox = @userSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
