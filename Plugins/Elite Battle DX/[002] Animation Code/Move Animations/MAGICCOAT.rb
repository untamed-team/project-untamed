#-------------------------------------------------------------------------------
#  MAGICCOAT
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:MAGICCOAT) do
  factor = @userSprite.zoom_x
  @vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
  @scene.wait(10,true)
  factor = @userSprite.zoom_x
  cx, cy = @userSprite.getCenter(true)
  j = 0
  # set up animation
  fp = {}
  fp["x"] = Sprite.new(@viewport)
  fp["x"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb607")
  fp["x"].ox = fp["x"].bitmap.width/2
  fp["x"].oy = fp["x"].bitmap.height/2
  if @userIsPlayer
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
      @userSprite.zoom_y-=0.05*factor
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
    @scene.wait(1,true)				
    if i.between?(7,11)
      #@targetSprite.still
      @userSprite.zoom_y+=0.05*factor
      #@targetSprite.tone.all+=12.8
    end
  end
  pbDisposeSpriteHash(fp)
  @vector.reset #if !@multiHit
end
#-------------------------------------------------------------------------------
