#-------------------------------------------------------------------------------
#  IMPRISON
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:IMPRISON) do
  EliteBattle.playMoveAnimation(:HEALBLOCK, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  EMBARGO
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:EMBARGO) do
  EliteBattle.playMoveAnimation(:HEALBLOCK, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  HEALBLOCK
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:HEALBLOCK) do
  # set up animation
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  factor = @targetIsPlayer ? 2.5 : 1.5
  # set up animation
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].opacity = 0
  sparks = 25
  for i in 0...sparks
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb619_3")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 50
  end
  k = 0
  c = [Tone.new(102,0,0),Tone.new(0,0,0)]
  # start animation
  @sprites["battlebg"].defocus
  @vector.set(vector)
  for i in 0...128
    cx, cy = @targetSprite.getCenter
    for j in 0...sparks
      if fp["#{j}"].opacity == 0
        r = rand(2)
        fp["#{j}"].zoom_x = factor*(r==0 ? 1 : 0.5)
        fp["#{j}"].zoom_y = factor*(r==0 ? 1 : 0.5)
        x, y = randCircleCord(64*factor)
        fp["#{j}"].x = cx - 64*factor*@targetSprite.zoom_x + x*@targetSprite.zoom_x
        fp["#{j}"].y = cy - 64*factor*@targetSprite.zoom_y + y*@targetSprite.zoom_y
      end
      next if j>(i/4)
      x2 = cx
      y2 = cy
      x0 = fp["#{j}"].x
      y0 = fp["#{j}"].y
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].zoom_x -= fp["#{j}"].zoom_x*0.1
      fp["#{j}"].zoom_y -= fp["#{j}"].zoom_y*0.1
      if i >= 96
        fp["#{j}"].opacity -= 35
      elsif (x2 - x0)*0.1 < 1 && (y2 - y0)*0.1 < 1
        fp["#{j}"].opacity = 0
      else
        fp["#{j}"].opacity += 35
      end
    end
    if i < 96
      fp["bg"].opacity += 5 if fp["bg"].opacity < 255*0.6
    else
      fp["bg"].opacity -= 5
    end
    if i < 112
      if i%16 == 0
        k += 1
        k = 0 if k > 1
      end
      @targetSprite.tone.red += (c[k].red - @targetSprite.tone.red)*0.2
      @targetSprite.tone.green += (c[k].green - @targetSprite.tone.green)*0.2
      @targetSprite.tone.blue += (c[k].blue - @targetSprite.tone.blue)*0.2
    end
    pbSEPlay("Anim/PerishSong",100) if i == 16
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @targetSprite.tone = Tone.new(0,0,0)
  @vector.reset
  pbDisposeSpriteHash(fp)
 end