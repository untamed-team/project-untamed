#-------------------------------------------------------------------------------
#  AQUARING
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:AQUARING) do
  # inital configuration
  defaultvector = EliteBattle.get_vector(:MAIN, @battle)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  # set up animation
  fp = {}; dx = []; dy = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(42,78,131))
  fp["bg"].opacity = 0
  # circles
  fp["cir"] = Sprite.new(@viewport)
  fp["cir"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb536_2")
  fp["cir"].ox = fp["cir"].bitmap.width/2
  fp["cir"].oy = fp["cir"].bitmap.height/2
  fp["cir"].z = @userSprite.z + 1
  fp["cir"].mirror = @userIsPlayer
  fp["cir"].zoom_x = (@targetIsPlayer ? 1 : 0.8)
  fp["cir"].zoom_y = (@targetIsPlayer ? 2 : 1.2)
  fp["cir"].opacity = 0
  fp["cir2"] = Sprite.new(@viewport)
  fp["cir2"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb536_2")
  fp["cir2"].ox = fp["cir2"].bitmap.width/2
  fp["cir2"].oy = fp["cir2"].bitmap.height/2
  fp["cir2"].z = @userSprite.z + 1
  fp["cir2"].mirror = @userIsPlayer
  fp["cir2"].zoom_x = (@targetIsPlayer ? 0.75 : 0.6)
  fp["cir2"].zoom_y = (@targetIsPlayer ? 1 : 0.8)
  fp["cir2"].opacity = 0
  # water
  fp["water"] = Sprite.new(@viewport)
  fp["water"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb536")
  fp["water"].ox = fp["water"].bitmap.width/2
  fp["water"].oy = fp["water"].bitmap.height/2
  fp["water"].z = @userSprite.z + 1
  fp["water"].mirror = @userIsPlayer
  fp["water"].zoom_x = (@targetIsPlayer ? 1 : 0.8)
  fp["water"].zoom_y = (@targetIsPlayer ? 1 : 0.8)
  fp["water"].opacity = 0
  # user
  @userSprite.color = Color.new(51,153,255,0)
  shake = 4; k = 0
  # start animation
  @sprites["battlebg"].defocus
  for i in 0...40
    if i < 8
      fp["bg"].opacity += 32
    else
      fp["bg"].color.alpha -= 32
      fp["cir"].x, fp["cir"].y = @userSprite.getCenter
      fp["cir"].angle += 24*(@userIsPlayer ? -1 : 1)
      fp["cir"].opacity += 24
	  fp["cir2"].x, fp["cir2"].y = @userSprite.getCenter
      fp["cir2"].angle -= 24*(@userIsPlayer ? -1 : 1)
      fp["cir2"].opacity += 24
	  fp["water"].x, fp["water"].y = @userSprite.getCenter
      fp["water"].angle += 24*(@userIsPlayer ? -1 : 1)
      fp["water"].opacity += 24
    end
    if i == 8
      @vector.set(vector2)
      pbSEPlay("Anim/Water3",80)
    end
	pbSEPlay("Anim/Bubble1",80) if i == 16
	if i < 20
      @userSprite.color.alpha += 10
    else
      @userSprite.color.alpha -= 16
    end
    fp["bg"].update
	#@userSprite.still
    @userSprite.anim = true
    @scene.wait(1,true)
  end
  cx, cy = @userSprite.getCenter(true)
  dx = []
  dy = []
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb618_2")
    fp["#{i}s"].src_rect.set(rand(3)*36,0,36,36)
    fp["#{i}s"].ox = fp["#{i}s"].src_rect.width/2
    fp["#{i}s"].oy = fp["#{i}s"].src_rect.height/2
    r = 128*@userSprite.zoom_x
    z = [0.5,0.25,1,0.75][rand(4)]
    x, y = randCircleCord(r)
    x = cx - r + x
    y = cy - r + y
    fp["#{i}s"].x = cx
    fp["#{i}s"].y = cy
    fp["#{i}s"].zoom_x = z*@userSprite.zoom_x
    fp["#{i}s"].zoom_y = z*@userSprite.zoom_x
    fp["#{i}s"].visible = false
    fp["#{i}s"].z = @userSprite.z + 1
    dx.push(x); dy.push(y)
  end
  k = -1
  for i in 0...20
    cx, cy = @userSprite.getCenter
    if i > 0
      for j in 0...8
        fp["#{j}s"].visible = true
        fp["#{j}s"].opacity -= 32
        fp["#{j}s"].x -= (fp["#{j}s"].x - dx[j])*0.2
        fp["#{j}s"].y -= (fp["#{j}s"].y - dy[j])*0.2
      end
      fp["cir"].angle += 24*(@userIsPlayer ? -1 : 1)
      fp["cir"].opacity -= 30
      fp["cir"].x = cx
      fp["cir"].y = cy
	  fp["cir2"].angle -= 24*(@userIsPlayer ? -1 : 1)
      fp["cir2"].opacity -= 30
      fp["cir2"].x = cx
      fp["cir2"].y = cy
	  fp["water"].angle += 24*(@userIsPlayer ? -1 : 1)
      fp["water"].opacity -= 30
      fp["water"].x = cx
      fp["water"].y = cy
    end
  end
  16.times do
    fp["bg"].update
    fp["bg"].opacity -= 16
    fp["cir2"].opacity -= 16
    fp["water"].opacity -= 16
    @scene.wait(1,true)
  end
  @userSprite.ox = @userSprite.bitmap.width/2
  @vector.reset if !@multiHit
  @sprites["battlebg"].focus
  pbDisposeSpriteHash(fp)
end
