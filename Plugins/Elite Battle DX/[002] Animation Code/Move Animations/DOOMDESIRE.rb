#-------------------------------------------------------------------------------
#  DOOMDESIRE
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:DOOMDESIRE) do
  if @hitNum == 1
    EliteBattle.playMoveAnimation(:SWORDSDANCE, @scene, @userIndex, @targetIndex)
  elsif @hitNum == 0
    EliteBattle.playMoveAnimation(:DOOMDESIRE_ATT, @scene, @userIndex, @targetIndex)
  end
end
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:DOOMDESIRE_ATT) do
  # set up animation
  fp = {}
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
# clash
  @vector.set(vector)
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb614_bg_7")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  @vector.inc = 0.2
  @scene.wait(16,true)
  pbSEPlay("EBDX/Anim/iron4",60) #change
  #pbSEPlay("Anim/Psych Up",60) #change
  @sprites["battlebg"].defocus
  for i in 0...10
    fp["bg"].opacity += 14
    @scene.wait(1,true)
  end
  #pbSEPlay("EBDX/Anim/psychic4",80) #change
  cx, cy = @targetSprite.getCenter
  fp["flare"] = Sprite.new(@viewport)
  fp["flare"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb614_13")
  fp["flare"].ox = fp["flare"].bitmap.width/2
  fp["flare"].oy = fp["flare"].bitmap.height/2
  fp["flare"].x = cx
  fp["flare"].y = cy
  fp["flare"].zoom_x = @targetSprite.zoom_x
  fp["flare"].zoom_y = @targetSprite.zoom_y
  fp["flare"].z = @targetSprite.z
  fp["flare"].opacity = 0
  for j in 0...3
    fp["#{j}x"] = Sprite.new(@viewport)
    fp["#{j}x"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb244_4")
    fp["#{j}x"].ox = fp["#{j}x"].bitmap.width/2
    fp["#{j}x"].oy = fp["#{j}x"].bitmap.height/2
    fp["#{j}x"].x = cx - 32 + rand(64)
    fp["#{j}x"].y = cy - 32 + rand(64)
    fp["#{j}x"].z = @targetSprite.z + 1
    fp["#{j}x"].visible = false
    fp["#{j}x"].zoom_x = @targetSprite.zoom_x
    fp["#{j}x"].zoom_y = @targetSprite.zoom_y
  end
  for m in 0...12
    fp["p#{m}"] = Sprite.new(@viewport)
    fp["p#{m}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb614_11")
    fp["p#{m}"].ox = fp["p#{m}"].bitmap.width/2
    fp["p#{m}"].oy = fp["p#{m}"].bitmap.height/2
    fp["p#{m}"].x = cx - 48 + rand(96)
    fp["p#{m}"].y = cy - 48 + rand(96)
    fp["p#{m}"].z = @targetSprite.z + 2
    fp["p#{m}"].visible = false
    fp["p#{m}"].zoom_x = @targetSprite.zoom_x
    fp["p#{m}"].zoom_y = @targetSprite.zoom_y
  end
  @targetSprite.color = Color.new(0,0,0,0)
  for i in 0...64
    fp["bg"].opacity += 16 if fp["bg"].opacity < 255 && i < 32
    fp["bg"].color.alpha -= 32 if fp["bg"].color.alpha > 0
    fp["flare"].opacity += 32*(i < 8 ? 1 : -1)
    fp["flare"].angle += 32
    pbSEPlay("EBDX/Anim/iron1",80) if i == 8 || i == 16 || i == 24 # keep
    for j in 0...3
      next if i < 12
      next if j>(i-12)/4
      fp["#{j}x"].visible = true
      fp["#{j}x"].opacity -= 16
      fp["#{j}x"].angle += 16
      fp["#{j}x"].zoom_x += 0.1
      fp["#{j}x"].zoom_y += 0.1
    end
    for m in 0...12
      next if i < 6
      next if m>(i-6)
      fp["p#{m}"].visible = true
      fp["p#{m}"].opacity -= 16
      fp["p#{m}"].y -= 8
    end
    if i >= 48
      fp["bg"].opacity -= 16
      @targetSprite.color.alpha -= 16
    else
      @targetSprite.color.alpha += 16 if @targetSprite.color.alpha < 192
    end
    @targetSprite.anim = true
    @scene.wait
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end