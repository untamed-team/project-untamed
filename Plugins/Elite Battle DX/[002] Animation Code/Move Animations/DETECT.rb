#-------------------------------------------------------------------------------
#  QUICKGUARD
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:QUICKGUARD) do
  EliteBattle.playMoveAnimation(:DETECT, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  WIDEGUARD
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:WIDEGUARD) do
  EliteBattle.playMoveAnimation(:DETECT, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false)
end
#-------------------------------------------------------------------------------
#  DETECT
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:DETECT) do
  factor = @targetSprite.zoom_x
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(8,true)
  factor = @targetSprite.zoom_x
  cx, cy = @targetSprite.getCenter(true)
  j = 0
  # set up animation
  fp = {}
  fp["x"] = Sprite.new(@viewport)
  fp["x"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb608")
  fp["x"].ox = fp["x"].bitmap.width/2
  fp["x"].oy = fp["x"].bitmap.height/2
  if @targetIsPlayer
	  fp["x"].x = cx + 100
	  fp["x"].y = cy - 50
	  fp["x"].z = @targetSprite.z - 1
  else
  	  fp["x"].x = cx - 80
	  fp["x"].y = cy + 45
	  fp["x"].z = @targetSprite.z + 1
  end
  fp["x"].zoom_x = factor
  fp["x"].zoom_y = factor
  fp["x"].src_rect.height = 0
  pbSEPlay("EBDX/Anim/psychic2",60)
  @scene.wait(1,true)
  for i in 1..11
    # if i < 8
      # x=(i/4 < 1) ? 2 : -2
      # @scene.moveEntireScene(0, x*2, true, true)
    # end
    if i.between?(1,5)
      #@targetSprite.still
      @targetSprite.zoom_y-=0.05*factor
      #@targetSprite.tone.all-=12.8
    end
	if j == 0 && i == 6
	  for k in 0...50
		pbSEPlay("EBDX/Anim/shine1",60) if k == 25
		fp["x"].src_rect.height += 5
		fp["x"].opacity -= 20 if k >= 25
		@scene.wait(1,true)
	  end
	  #bSEPlay("EBDX/Anim/normal1",80)
	  j = 1
	end
    if i.between?(7,11)
      #@targetSprite.still
      @targetSprite.zoom_y+=0.05*factor
      #@targetSprite.tone.all+=12.8
    end
  end
  pbDisposeSpriteHash(fp)
  @vector.reset #if !@multiHit
end
#-------------------------------------------------------------------------------
