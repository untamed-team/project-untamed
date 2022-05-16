#===============================================================================
#  Advanced Transitions
#    by Luka S.J.
# ----------------
#  new script used for map transitions
#-------------------------------------------------------------------------------
#  Main function used to replace the default `Transfer Player` command and
#  apply a fancy new transition in between (you're welcome Marin)
#
#  Requires Map ID, destination X and Y coordinates at all times
#  Replace the `transition` argument with any of the following:
#      :DIRECTED - Applies a gradient, directional fade
#      :CIRCULAR - Applies a gradient, circular fade
#      :ZOOMED - Zooms into the map B/W styled
#      :MELT - fades into the next map
#      :CAVEIN - Plays the `Cave Entrance` animation by Maruno
#      :CAVEOUT - Plays the `Cave Exit` animation by Maruno
#      everything else - Applies a regular fade to black
#===============================================================================
def pbTransferWithTransition(map_id, x, y, transition = nil, dir = $game_player.direction)
  # abort if transferring player, showing message, or processing transition
  if $game_temp.player_transferring || $game_temp.message_window_showing || $game_temp.transition_processing
    return false
  end
  # temp viewport creation
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  # loads first stage of transition
  case transition
  when :MELT
    bmp = Transitions.melt(true)
  when :DIRECTED
    bmp = Transitions.directed
  when :CIRCULAR
    bmp = Transitions.circular
  when :ZOOMED
    bmp = Transitions.zoom
  when :CAVEIN
    bmp = Transitions.cave(viewport)
  when :CAVEOUT
    bmp = Transitions.cave(viewport, false, false)
  else
    bmp = Transitions.fade
  end
  # displays temporary state of screen as a sprite
  if ![:ZOOMED].include?(transition)
    screen = Sprite.new(viewport)
    screen.bitmap = bmp
  end
  # 4 frame wait
  4.times do
    next if [:ZOOMED, :MELT].include?(transition)
    Graphics.update
  end
  # part responsible for transferring the player around
    # Set transferring player flag
    $game_temp.player_transferring = true
    $game_temp.transition_processing = false
    # Set player move destination
    $game_temp.player_new_map_id = map_id
    $game_temp.player_new_x = x
    $game_temp.player_new_y = y
    $game_temp.player_new_direction = dir
    pbUpdateSceneMap
  # ----------------------------------------------------
  # 4 frame wait
  4.times do
    next if [:ZOOMED, :MELT].include?(transition)
    Graphics.update
  end
  screen.visible = false if ![:ZOOMED].include?(transition)
  # final stage of transition
  case transition
  when :MELT
    Transitions.melt(true, bmp)
  when :DIRECTED
    Transitions.directed(true)
  when :CIRCULAR
    Transitions.circular(true)
  when :ZOOMED
    Transitions.zoom(true, bmp)
  when :CAVEIN
    Transitions.cave(viewport, true)
  when :CAVEOUT
    Transitions.cave(viewport, true, false)
  else
    Transitions.fade(true)
  end
  # disposes of temporary elements
  screen.dispose if ![:ZOOMED].include?(transition)
  viewport.dispose
end
#===============================================================================
#  Main module used to handle the greatness of the new transitions
#===============================================================================
module Transitions
  #-----------------------------------------------------------------------------
  #  linear directional fade to black, based on player's direction
  #-----------------------------------------------------------------------------
  def self.directed(reverse = false)
    return if !$game_player || !$scene.is_a?(Scene_Map)
    bmp = Graphics.snap_to_bitmap
    dir = $game_player.direction
    dir = 10 - dir if reverse
    horizontal = (dir == 4 || dir == 6)
    parts = horizontal ? 32 : 24
    flip = (horizontal && dir == 6) || (!horizontal && dir == 8)
    viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    viewport.z = 99999
    fp = {}
    fp["screen"] = Sprite.new(viewport)
    fp["screen"].bitmap = bmp
    fp["screen"].blur_sprite
    fp["screen"].opacity = 0
    width = horizontal ? Graphics.width/parts : Graphics.width
    height = horizontal ? Graphics.height : Graphics.height/parts
    fp["trans"] = Sprite.new(viewport)
    fp["trans"].bitmap = Bitmap.new(horizontal ? Graphics.width*2 : Graphics.width,
                                    horizontal ? Graphics.height : Graphics.height*2)
    push = flip
    push != push if reverse
    for j in 0...parts
      x = horizontal ? (push ? Graphics.width*2 - (j+1)*width : j*width) : 0
      y = horizontal ? 0 : (push ? Graphics.height*2 - (j+1)*height : j*height)
      opacity = (256/parts)*j
      fp["trans"].bitmap.fill_rect(x,y,width,height,Color.new(0,0,0,opacity))
    end
    x1 = horizontal ? (push ? 0 : Graphics.width) : 0
    y1 = horizontal ? 0 : (push ? 0 : Graphics.height)
    fp["trans"].bitmap.fill_rect(x1,y1,Graphics.width,Graphics.height,Color.new(0,0,0))
    fp["trans"].x = horizontal ? (flip ? -Graphics.width*2 : Graphics.width) : 0
    fp["trans"].x = horizontal ? (flip ? 0 : -Graphics.width) : 0 if reverse
    fp["trans"].y = horizontal ? 0 : (flip ? -Graphics.height*2 : Graphics.height)
    fp["trans"].y = horizontal ? 0 : (flip ? 0 : -Graphics.height) if reverse
    for i in 0...16.delta_add
      fp["trans"].x -= ((Graphics.width/8)*(flip ? -1 : 1)*(horizontal ? 1 : 0)*(reverse ? -1 : 1))/self.delta
      fp["trans"].y -= ((Graphics.height/8)*(flip ? -1 : 1)*(horizontal ? 0 : 1)*(reverse ? -1 : 1))/self.delta
      fp["screen"].opacity += (16*(reverse ? -1 : 1))/self.delta
      Graphics.update
    end
    bmp = Graphics.snap_to_bitmap
    pbDisposeSpriteHash(fp)
    viewport.dispose
    return bmp
  end
  #-----------------------------------------------------------------------------
  #  circular fading to black
  #-----------------------------------------------------------------------------
  def self.circular(reverse = false)
    return if !$game_player || !$scene.is_a?(Scene_Map)
    viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    viewport.z = 99999
    zoom = reverse ? 0 : 2.0
    bmp = Bitmap.new(Graphics.width,Graphics.height)
    bmp.fill_rect(0,0,bmp.width,bmp.height,Color.new(0,0,0))
    for i in 0...4
      bmp.draw_circle(Color.new(0,0,0,120 - 40*i),bmp.height/2 - 12*i)
    end
    bg = Sprite.new(viewport)
    bg.bitmap = Graphics.snap_to_bitmap
    bg.blur_sprite
    bg.opacity = 0
    sprite = Sprite.new(viewport)
    sprite.bitmap = Bitmap.new(bmp.width,bmp.height)
    sprite.opacity = reverse ? 255 : 0
    for i in 0..20.delta_add
      sprite.bitmap.clear
      ox = (1 - zoom)*viewport.rect.width*0.5
      oy = (1 - zoom)*viewport.rect.height*0.5
      width = (ox < 0 ? 0 : ox).ceil
      height = (oy < 0 ? 0 : oy).ceil
      sprite.bitmap.fill_rect(0,0,width,viewport.rect.height,Color.new(0,0,0))
      sprite.bitmap.fill_rect(viewport.rect.width-width,0,width,viewport.rect.height,Color.new(0,0,0))
      sprite.bitmap.fill_rect(0,0,viewport.rect.width,height,Color.new(0,0,0))
      sprite.bitmap.fill_rect(0,viewport.rect.height-height,viewport.rect.width,height,Color.new(0,0,0))
      sprite.bitmap.stretch_blt(Rect.new(ox,oy,(bmp.width*zoom).ceil,(bmp.height*zoom).ceil),bmp,Rect.new(0,0,bmp.width,bmp.height))
      sprite.opacity += 48/self.delta
      zoom -= (2.0/20*(reverse ? -1 : 1))/self.delta
      bg.opacity += (16*(reverse ? -1 : 1))/self.delta
      Graphics.update
    end
    bmp = Graphics.snap_to_bitmap
    bg.dispose
    sprite.dispose
    viewport.dispose
    return bmp
  end
  #-----------------------------------------------------------------------------
  #  standard fade to black
  #-----------------------------------------------------------------------------
  def self.fade(reverse = false)
    return if !$game_player || !$scene.is_a?(Scene_Map)
    viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    viewport.z = 99999
    viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    viewport.z = 99999
    viewport.color = Color.new(0,0,0,reverse ? 255 : 0)
    8.delta_add.times do
      viewport.color.alpha += (32*(reverse ? -1 : 1))/self.delta
      Graphics.update
    end
    bmp = Graphics.snap_to_bitmap
    viewport.dispose
    return bmp
  end
  #-----------------------------------------------------------------------------
  #  B/W styled zoom
  #-----------------------------------------------------------------------------
  def self.zoom(reverse = false, screen = nil)
    return if !$game_player || !$scene.is_a?(Scene_Map)
    if !screen
      viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
      viewport.z = 99999
      screen = Sprite.new(viewport)
      screen.snap_screen
      screen.center!
      screen.x = Graphics.width/2
      screen.y = Graphics.height/2
    end
    (reverse ? 32 : 48).delta_add.times do
      screen.opacity -= 16/self.delta if reverse
      screen.zoom_x += 0.01/self.delta
      screen.zoom_y += 0.01/self.delta
      Graphics.update
    end
    if reverse
      screen.viewport.dispose
      screen.dispose
    end
    return reverse ? nil : screen
  end
  #-----------------------------------------------------------------------------
  #  Support for Maruno's Cave entrance and exit animations
  #-----------------------------------------------------------------------------
  def self.cave(viewport, reverse = false, entrance = true)
    return if !$game_player || !$scene.is_a?(Scene_Map)
    viewport.color = Color.new(0,0,0,0)
    if reverse
      if entrance
        pbCaveEntrance
      else
        pbCaveExit
      end
    end
    8.delta_add.times do
      next if reverse
      viewport.color.alpha += (32*(reverse ? -1 : 1))/self.delta
      Graphics.update
    end
    return nil
  end
  #-----------------------------------------------------------------------------
  #  fade without black
  #-----------------------------------------------------------------------------
  def self.melt(reverse = false, bmp = nil)
    return if !$game_player || !$scene.is_a?(Scene_Map)
    bmp = Graphics.snap_to_bitmap if bmp.nil?
    viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    viewport.z = 99999
    spr = Sprite.new(@viewport)
    spr.bitmap = bmp
    for i in 0...16.delta_add
      next if !reverse
      spr.opacity -= 16/self.delta
      Graphics.update
    end
    spr.dispose
    viewport.dispose
    return bmp
  end
  #-----------------------------------------------------------------------------
  #  calculate delta
  #-----------------------------------------------------------------------------
  def self.delta; return Graphics.frame_rate/40.0; end
  #-----------------------------------------------------------------------------
end
