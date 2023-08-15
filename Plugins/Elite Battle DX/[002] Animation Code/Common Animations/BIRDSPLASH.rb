#-------------------------------------------------------------------------------
#  BIRDSPLASH
#-------------------------------------------------------------------------------
EliteBattle.defineCommonAnimation(:BIRDSPLASH) do
  #vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  factor = @targetIsPlayer ? 2 : 1.5
  # set up animation
  fp = {}
  bomb = true
  idxStonesM = 10
  idxSontesS = 5
  #@vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  # rest of the particles
  for j in 0...idxStonesM
    fp["p#{j}"] = Sprite.new(@viewport)
    fp["p#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebConfused")
    fp["p#{j}"].center!
    fp["p#{j}"].x, fp["p#{j}"].y = @targetSprite.getCenter(true)
    r = (40 + rand(24))*@targetSprite.zoom_x
    x, y = randCircleCord(r)
    fp["p#{j}"].end_x = fp["p#{j}"].x - r + x
    fp["p#{j}"].end_y = fp["p#{j}"].y - r + y
    fp["p#{j}"].zoom_x = 0
    fp["p#{j}"].zoom_y = 0
    fp["p#{j}"].angle = rand(360)
    fp["p#{j}"].z = @targetSprite.z + 1
  end
  for j in 0...idxSontesS
    fp["c#{j}"] = Sprite.new(@viewport)
    fp["c#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebConfused")
    fp["c#{j}"].center!
    fp["c#{j}"].x, fp["c#{j}"].y = @targetSprite.getCenter(true)
    #fp["c#{j}"].y -= (@targetSprite.bitmap.height*0.5)*@userSprite.zoom_y
    r = (48 + rand(32))*@targetSprite.zoom_x
    fp["c#{j}"].end_x = fp["c#{j}"].x - r + rand(r*2)
    fp["c#{j}"].end_y = fp["c#{j}"].y - r + rand(r*2)#(52 - rand(64))*@targetSprite.zoom_y
    fp["c#{j}"].zoom_x = 0
    fp["c#{j}"].zoom_y = 0
    fp["c#{j}"].opacity = 0
    fp["c#{j}"].z = @targetSprite.z + 1
    fp["c#{j}"].toggle = 1.2 + rand(10)/10.0
    fp["c#{j}"].visible = bomb
  end
  # splash
  for i in 0...idxStonesM * 5
    break if !bomb && i > 15
	pbSEPlay("Anim/confusion1") if i%(idxStonesM/2) == 0
    for j in 0...idxStonesM
      next if !bomb
      next if i < 8
      next if j > (i-8)*2
      fp["p#{j}"].zoom_x += (1.6 - fp["p#{j}"].zoom_x)*0.05
      fp["p#{j}"].zoom_y += (1.6 - fp["p#{j}"].zoom_y)*0.05
      fp["p#{j}"].x += (fp["p#{j}"].end_x - fp["p#{j}"].x)*0.05
      fp["p#{j}"].y += (fp["p#{j}"].end_y - fp["p#{j}"].y)*0.05
      if fp["p#{j}"].zoom_x >= 1
        fp["p#{j}"].opacity -= 16
      end
      fp["p#{j}"].color.alpha -= 8
    end
    for j in 0...idxSontesS
      next if j > i
      fp["c#{j}"].x += (fp["c#{j}"].end_x - fp["c#{j}"].x)*0.05
      fp["c#{j}"].y += (fp["c#{j}"].end_y - fp["c#{j}"].y)*0.05
      fp["c#{j}"].opacity += 16
      fp["c#{j}"].toggle = -1 if fp["c#{j}"].opacity >= 255
      fp["c#{j}"].zoom_x += (fp["c#{j}"].toggle - fp["c#{j}"].zoom_x)*0.05
      fp["c#{j}"].zoom_y += (fp["c#{j}"].toggle - fp["c#{j}"].zoom_y)*0.05
	  if fp["c#{j}"].zoom_x >= 0.5
        fp["c#{j}"].opacity -= 20
      end
    end
    @targetSprite.color.alpha -= 16 if i >= 48
    @targetSprite.anim = true
    @targetSprite.still
    @scene.wait(1,i < 8)
  end
end