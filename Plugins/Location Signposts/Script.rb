################################################################################
# Location signpost - updated by:
# - LostSoulsDev / carmaniac
# - PurpleZaffre
# - Golisopod User
# - ENLS
# - spaceemotion
# - TechSkylander1518
# Please give credits when using this.
################################################################################

class LocationWindow
  def initialize(name)
    @sprites = {}
    @baseColor = MessageConfig::LIGHT_TEXT_MAIN_COLOR
    @shadowColor = MessageConfig::LIGHT_TEXT_SHADOW_COLOR
    @sprites["Image"] = Sprite.new
    mapname = name
    if pbResolveBitmap(PATH + mapname)
      @sprites["Image"].bitmap = Bitmap.new(PATH + mapname)
    elsif SIGNPOSTS.any?{|k,v| v.any?{|i| mapname.include?(i)}}
      @sprites["Image"].bitmap = Bitmap.new(PATH + SIGNPOSTS.select{|k,v| v.any?{|i| mapname.include?(i)}}.keys[0])
    else
      @sprites["Image"].bitmap = Bitmap.new(PATH + "Blank")
    end
    @sprites["Image"].x = 8
    @sprites["Image"].y = - @sprites["Image"].bitmap.height
    @sprites["Image"].z = 99990
    @sprites["Image"].opacity = 255
    @height = @sprites["Image"].bitmap.height
    pbSetSystemFont(@sprites["Image"].bitmap)
    pbDrawTextPositions(@sprites["Image"].bitmap,[[name,22,@sprites["Image"].bitmap.height-38,0,@baseColor,@shadowColor,true]])
    @currentmap = $game_map.map_id
    @frames = 0
  end

  def dispose
    @sprites["Image"].dispose
  end

  def disposed?
    return @sprites["Image"].disposed?
  end

  def update
    return if @sprites["Image"].disposed?
    if $game_temp.message_window_showing || @currentmap != $game_map.map_id
      @sprites["Image"].dispose
      return
    elsif @frames > DURATION
      @sprites["Image"].y-= ((@sprites["Image"].bitmap.height)/HIDE_FRAMES)
      @sprites["Image"].dispose if @sprites["Image"].y + @height < 6
    elsif $game_temp.in_menu == true
      @sprites["Image"].y-= ((@sprites["Image"].bitmap.height)/HIDE_FRAMES_MENU)
      @sprites["Image"].dispose if @sprites["Image"].y + @height < 6
    else
      @sprites["Image"].y+= ((@sprites["Image"].bitmap.height)/SHOW_FRAMES) if @sprites["Image"].y < 6
    end
    @frames += 1
  end
end