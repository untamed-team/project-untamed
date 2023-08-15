#-------------------------------------------------------------------------------
#  DIVE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:DIVE) do
  if @hitNum == 1
    EliteBattle.playMoveAnimation(:DIVE_DOWN, @scene, @userIndex, @targetIndex)
  elsif @hitNum == 0
    EliteBattle.playMoveAnimation(:DIVE_UP, @scene, @userIndex, @targetIndex)
  end
end

EliteBattle.defineMoveAnimation(:DIVE_DOWN) do
  factor = @targetIsPlayer ? 2 : 1.5
  vector = @scene.getRealVector(@userIndex, @userIsPlayer)
  splash = 50
  # set up animation
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(42,78,131))
  fp["bg"].opacity = 0
  fp["dive"] = Sprite.new(@viewport)
  fp["dive"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb156_4")
  fp["dive"].ox = fp["dive"].bitmap.width/2
  fp["dive"].oy = fp["dive"].bitmap.height/2
  fp["dive"].z = 50
  fp["dive"].x, fp["dive"].y = @userSprite.getCenter
  fp["dive"].opacity = 0
  fp["dive"].zoom_x = factor*1.4
  fp["dive"].zoom_y = factor*1.4
  fp["dnt"] = Sprite.new(@viewport)
  fp["dnt"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb156_2")
  fp["dnt"].ox = fp["dnt"].bitmap.width/2
  fp["dnt"].oy = fp["dnt"].bitmap.height/2
  fp["dnt"].z = 50
  fp["dnt"].opacity = 0
  # splash
  for j in 0...32
    fp["p#{j}"] = Sprite.new(@viewport)
    fp["p#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb618_2")
    fp["p#{j}"].center!
    fp["p#{j}"].x, fp["p#{j}"].y = @userSprite.getCenter(true)
    r = (40 + rand(24))*@userSprite.zoom_x
    x, y = randCircleCord(r)
    fp["p#{j}"].end_x = fp["p#{j}"].x - r + x
    fp["p#{j}"].end_y = fp["p#{j}"].y - r + y
    fp["p#{j}"].zoom_x = 0
    fp["p#{j}"].zoom_y = 0
    fp["p#{j}"].angle = rand(360)
    fp["p#{j}"].z = @userSprite.z + 1
    #fp["p#{j}"].color = Color.new(136,48,138)
  end
  # start animation
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end
  @vector.set(vector)
  @scene.wait(20,true)
  pbSEPlay("Anim/Water2")
  for i in 0...20
    cx, cy = @userSprite.getCenter
    fp["dive"].x = cx
    fp["dive"].y = cy
    fp["dive"].zoom_x -= factor*0.4/10
    fp["dive"].zoom_y -= factor*0.4/10
    fp["dive"].opacity += 51
    fp["dnt"].x = cx
    fp["dnt"].y = cy
    fp["dnt"].zoom_x = fp["dive"].zoom_x
    fp["dnt"].zoom_y = fp["dive"].zoom_y
    fp["dnt"].opacity += 25.5
    fp["dnt"].angle -= 16
    @userSprite.visible = false if i == 6
    @userSprite.hidden = true if i == 6
    @scene.wait(1,true)
  end
  10.times do
    fp["dive"].zoom_x += factor*0.4/10
    fp["dive"].zoom_y += factor*0.4/10
    fp["dnt"].zoom_x = fp["dive"].zoom_x
    fp["dnt"].zoom_y = fp["dive"].zoom_y
    fp["dnt"].opacity -= 25.5
    fp["dnt"].angle -= 16
    @scene.wait(1,true)
  end
  #@vector.set(vector[0],vector[1]+128,vector[2],vector[3],vector[4],vector[5])
  @vector.set(vector[0],vector[1],vector[2],vector[3],vector[4],vector[5])
  for i in 0...13
    @scene.wait(1,true)
    cx, cy = @userSprite.getCenter
    if i < 10
      fp["dive"].zoom_y -= factor*0.02
    elsif
      fp["dive"].zoom_x -= factor*0.02
      fp["dive"].zoom_y += factor*0.04
    end
    fp["dive"].x = cx
    fp["dive"].y = cy
    fp["dive"].y -= 25*(i-1) if i <= 6 && i > 1
	fp["dive"].y -= 149 + 15 if i == 7
	fp["dive"].y -= 164 + 10 if i == 8
	fp["dive"].y -= 174 + 5  if i == 9
	fp["dive"].y -= 197      if i == 10
	fp["dive"].y -= 197      if i == 11
	fp["dive"].y -= 197 - 10 if i == 12
	fp["dive"].y += 32*(i-13) if i >= 13
    pbSEPlay("Anim/Water1") if i == 10
  end
  # init splash
  for j in 0...splash
    fp["p#{j}"] = Sprite.new(@viewport)
    fp["p#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb618_2")
    fp["p#{j}"].center!
    fp["p#{j}"].x, fp["p#{j}"].y = @userSprite.getCenter(true)
	fp["p#{j}"].y + 30
    r = (40 + rand(24))*@userSprite.zoom_x
    x, y = randCircleCord(r)
    fp["p#{j}"].end_x = fp["p#{j}"].x - r + x
    fp["p#{j}"].end_y = fp["p#{j}"].y - r + y + 30
    fp["p#{j}"].zoom_x = 0
    fp["p#{j}"].zoom_y = 0
    fp["p#{j}"].angle = rand(360)
    fp["p#{j}"].z = @userSprite.z + 1
    #fp["p#{j}"].color = Color.new(136,48,138)
  end
  # splash animation
  for i in 0...64
	fp["dive"].y += 32			 if i >= 0 && i < 10
    fp["dive"].opacity -= 30 if i >= 0 && i < 10
	pbSEPlay("Anim/Bubble1",90) if i == 5
    for j in 0...splash
      next if i < 8
      next if j > (i-8)*2
      fp["p#{j}"].zoom_x += (1.6 - fp["p#{j}"].zoom_x)*0.1
      fp["p#{j}"].zoom_y += (1.6 - fp["p#{j}"].zoom_y)*0.1
      fp["p#{j}"].x += (fp["p#{j}"].end_x - fp["p#{j}"].x)*0.1
      fp["p#{j}"].y += (fp["p#{j}"].end_y - fp["p#{j}"].y)*0.1 - 15
      if fp["p#{j}"].zoom_x >= 1
        fp["p#{j}"].opacity -= 16
      end
      fp["p#{j}"].color.alpha -= 8
    end
	@scene.wait(1,i < 8)
  end
  16.times do
    fp["bg"].opacity -= 20
    @scene.wait(1,true)
  end
  pbDisposeSpriteHash(fp)
  @vector.reset
  @scene.wait(20,true)
end
########################################################################################################################
EliteBattle.defineMoveAnimation(:DIVE_UP) do
  defaultvector = EliteBattle.get_vector(:MAIN, @battle)
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  splash = 50
  # set up animation
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(42,78,131))
  fp["bg"].opacity = 0
  fp["drop"] = Sprite.new(@viewport)
  fp["drop"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb156_5")
  fp["drop"].ox = fp["drop"].bitmap.width/2
  fp["drop"].oy = fp["drop"].bitmap.height/2
  fp["drop"].y = 0
  fp["drop"].z = 50
  fp["drop"].visible = false
  # start animation
  @vector.set(defaultvector[0], defaultvector[1], defaultvector[2], defaultvector[3], defaultvector[4], defaultvector[5])
  @sprites["battlebg"].defocus
  @vector.set(vector)
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end
  fp["drop"].y = @targetSprite.y + 30
  fp["drop"].x = @targetSprite.x
  pbSEPlay("Anim/Water1")
  # init splash
  for j in 0...splash
    fp["p#{j}"] = Sprite.new(@viewport)
    fp["p#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb618_2")
    fp["p#{j}"].center!
    fp["p#{j}"].x, fp["p#{j}"].y = @targetSprite.getCenter(true)
	fp["p#{j}"].y += 30
    r = (40 + rand(24))*@targetSprite.zoom_x
    x, y = randCircleCord(r)
    fp["p#{j}"].end_x = fp["p#{j}"].x - r + x
    fp["p#{j}"].end_y = fp["p#{j}"].y - r + y + 30
    fp["p#{j}"].zoom_x = 0
    fp["p#{j}"].zoom_y = 0
    fp["p#{j}"].angle = rand(360)
    fp["p#{j}"].z = @targetSprite.z + 1
    #fp["p#{j}"].color = Color.new(136,48,138)
  end
  # splash animation
  for i in 0...64
	pbSEPlay("Anim/Bubble1",90) if i == 5
    for j in 0...splash
      next if i < 8
      next if j > (i-8)*2
      fp["p#{j}"].zoom_x += (1.6 - fp["p#{j}"].zoom_x)*0.1
      fp["p#{j}"].zoom_y += (1.6 - fp["p#{j}"].zoom_y)*0.1
      fp["p#{j}"].x += (fp["p#{j}"].end_x - fp["p#{j}"].x)*0.1
      fp["p#{j}"].y += (fp["p#{j}"].end_y - fp["p#{j}"].y)*0.1 - 15
      if fp["p#{j}"].zoom_x >= 1
        fp["p#{j}"].opacity -= 16
      end
      fp["p#{j}"].color.alpha -= 8
    end
	if i > 0 && i <= 10
		fp["drop"].visible = true
		fp["drop"].x = @targetSprite.x
		fp["drop"].y -= 25
		fp["drop"].zoom_x = @targetSprite.zoom_x
		fp["drop"].zoom_y = @targetSprite.zoom_y*1.4
	else 
		fp["drop"].opacity -= 20
	end
	@scene.wait(1,i < 8)
  end
  16.times do
    fp["bg"].opacity -= 20
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @userSprite.hidden = false
  @userSprite.visible = true
  @vector.reset
  pbDisposeSpriteHash(fp)
end
