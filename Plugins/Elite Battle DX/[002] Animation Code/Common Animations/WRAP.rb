#-------------------------------------------------------------------------------
#  WRAP
#-------------------------------------------------------------------------------
EliteBattle.defineCommonAnimation(:WRAP) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  factor = @targetIsPlayer ? 2 : 1.5
  # set up animation
  fp = {}
  #
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].opacity = 0
  #
  shake = 8
  zoom = -1
  # start animation
  @vector.set(vector)
  @sprites["battlebg"].defocus
  for i in 0...55
    pbSEPlay("Anim/Wrap",80) if i == 20
	if i < 10
      fp["bg"].opacity += 12
    elsif i >= 20
	  @targetSprite.ox += shake
      shake = -8 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 4
      shake = 8 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 4
      @targetSprite.still
    elsif i > 10
       	@targetSprite.zoom_x -= 0.04*factor
	    @targetSprite.zoom_y += 0.04*factor
	    @targetSprite.still
	end
    zoom *= -1 if i%2 == 0
    fp["bg"].update
    fp["bg"].zoom_y += 0.04*zoom
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  10.times do
    @targetSprite.zoom_x -= 0.04*factor
    @targetSprite.zoom_y += 0.04*factor
    @targetSprite.still
    @scene.wait
  end
  @scene.wait(8)
  @vector.reset if !@multiHit
  10.times do
    fp["bg"].opacity -= 25.5
    @targetSprite.still
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  pbDisposeSpriteHash(fp)
end