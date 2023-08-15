#-------------------------------------------------------------------------------
#  SUNNYDAY
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SUNNYDAY) do
  factor = @targetIsPlayer ? 2 : 1.5
  vector = @scene.getRealVector(@userIndex, @userIsPlayer)
  # set up animation
  fp = {}
  fp["weatherball"] = Sprite.new(@viewport)
  fp["weatherball"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb156_9")
  fp["weatherball"].ox = fp["weatherball"].bitmap.width/2
  fp["weatherball"].oy = fp["weatherball"].bitmap.height/2
  fp["weatherball"].z = 50
  fp["weatherball"].x, fp["weatherball"].y = @userSprite.getCenter
  fp["weatherball"].opacity = 0
  fp["weatherball"].zoom_x = factor*1.4
  fp["weatherball"].zoom_y = factor*1.4
  fp["dnt"] = Sprite.new(@viewport)
  fp["dnt"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb156_10")
  fp["dnt"].ox = fp["dnt"].bitmap.width/2
  fp["dnt"].oy = fp["dnt"].bitmap.height/2
  fp["dnt"].z = 50
  fp["dnt"].opacity = 0
  # start animation
  @vector.set(vector)
  @scene.wait(20,true)
  pbSEPlay("Anim/Fire2")
  for i in 0...20
    cx, cy = @userSprite.getCenter
    fp["weatherball"].x = cx
    fp["weatherball"].y = cy
    fp["weatherball"].zoom_x -= factor*0.4/10
    fp["weatherball"].zoom_y -= factor*0.4/10
    fp["weatherball"].opacity += 51
    fp["dnt"].x = cx
    fp["dnt"].y = cy
    fp["dnt"].zoom_x = fp["weatherball"].zoom_x
    fp["dnt"].zoom_y = fp["weatherball"].zoom_y
    fp["dnt"].opacity += 25.5
    fp["dnt"].angle -= 16
    @scene.wait(1,true)
  end
  10.times do
    fp["weatherball"].zoom_x += factor*0.4/10
    fp["weatherball"].zoom_y += factor*0.4/10
    fp["dnt"].zoom_x = fp["weatherball"].zoom_x
    fp["dnt"].zoom_y = fp["weatherball"].zoom_y
    fp["dnt"].opacity -= 25.5
    fp["dnt"].angle -= 16
    @scene.wait(1,true)
  end
  @vector.set(vector[0],vector[1]+128,vector[2],vector[3],vector[4],vector[5])
  for i in 0...20
    @scene.wait(1,true)
    cx, cy = @userSprite.getCenter
    if i < 10
      fp["weatherball"].zoom_y -= factor*0.02
    elsif
      fp["weatherball"].zoom_x -= factor*0.02
      fp["weatherball"].zoom_y += factor*0.04
    end
    fp["weatherball"].x = cx
    fp["weatherball"].y = cy
    fp["weatherball"].y -= 32*(i-10) if i >= 10
    pbSEPlay("EBDX/Anim/flying1") if i == 10
  end
  for i in 0...20
    fp["weatherball"].y -= 32
    fp["weatherball"].opacity -= 25.5 if i >= 10
    @scene.wait(1,true)
  end
  pbDisposeSpriteHash(fp)
  @vector.reset
  @scene.wait(20,true)
end