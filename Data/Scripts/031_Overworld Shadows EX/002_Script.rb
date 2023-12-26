#-------------------------------------------------------------------------------
# New Class for Shadow object
#-------------------------------------------------------------------------------
class Sprite_OWShadow
  attr_reader :visible
  #-----------------------------------------------------------------------------
  # Initialize a shadow sprite based on the name of the event
  #-----------------------------------------------------------------------------
  def initialize(sprite, event, viewport = nil)
    @rsprite  = sprite
    @event    = event
    @viewport = viewport
    @sprite   = Sprite.new(viewport)
    @disposed = false
    @remove   = false
    name      = ""
    if !defined?(Game_FollowingPkmn) || !@event.is_a?(Game_FollowingPkmn)
      if @event != $game_player
        name = $~[1] if @event.name[/shdw\((.*?)\)/]
        if OWShadowSettings::CASE_SENSITIVE_BLACKLISTS
          @remove = true if OWShadowSettings::SHADOWLESS_EVENT_NAME.any? {|e| @event.name[/#{e}/]}
        else
          @remove = true if OWShadowSettings::SHADOWLESS_EVENT_NAME.any? {|e| @event.name[/#{e}/i]}
        end
      else
        name = OWShadowSettings::PLAYER_SHADOW_FILENAME
      end
    end
    name = OWShadowSettings::DEFAULT_SHADOW_FILENAME if nil_or_empty?(name)
    @ow_shadow_bitmap = AnimatedBitmap.new("Graphics/Characters/Shadows/" + name)
    RPG::Cache.retain("Graphics/Characters/Shadows/" + name)
    update
  end
  #-----------------------------------------------------------------------------
  # Override the bitmap of the shadow sprite
  #-----------------------------------------------------------------------------
  def set_bitmap(name)
    if !pbResolveBitmap("Graphics/Characters/Shadows/" + name)
      echoln("The Shadow File you are trying to set it absent from /Graphics/Characters/Shadows/")
      return
    end
    @ow_shadow_bitmap = AnimatedBitmap.new("Graphics/Characters/Shadows/" + name)
    RPG::Cache.retain("Graphics/Characters/Shadows/" + name)
    @sprite.dispose if @sprite && !@sprite.disposed?
    @sprite = nil
    @sprite = Sprite.new(@viewport)
    @sprite.bitmap  = @ow_shadow_bitmap.bitmap
    update
  end
  #-----------------------------------------------------------------------------
  # Dispose the shadow bitmap
  #-----------------------------------------------------------------------------
  def dispose
    return if @disposed
    @sprite.dispose if @sprite
    @sprite = nil
    @disposed = true
  end
  #-----------------------------------------------------------------------------
  # Check whether the shadow has been disposed
  #-----------------------------------------------------------------------------
  def disposed?; return @disposed; end
  #-----------------------------------------------------------------------------
  # Calculation of shadow size when jumping
  #-----------------------------------------------------------------------------
  def jump_sprite
    return unless @sprite
    if @event.jump_distance_left >= 1 && @event.jump_distance_left < @event.jump_peak
      @sprite.zoom_x += 0.1
      @sprite.zoom_y += 0.1
    elsif @event.jump_distance_left >= @event.jump_peak
      @sprite.zoom_x -= 0.05
      @sprite.zoom_y -= 0.05
    end
    @sprite.zoom_x = 1 if @sprite.zoom_x > 1
    @sprite.zoom_x = 0 if @sprite.zoom_x < 0
    @sprite.zoom_y = 1 if @sprite.zoom_y > 1
    @sprite.zoom_y = 0 if @sprite.zoom_y < 0
    if @event.jump_count == 1
      @sprite.zoom_x = 1.0
      @sprite.zoom_y = 1.0
    end
    @sprite.x = @event.screen_x
    @sprite.y = @event.screen_y
    @sprite.z = @rsprite.z - 1
  end
  #-----------------------------------------------------------------------------
  # Check whether the shadow should be shown or not
  #-----------------------------------------------------------------------------
  def show_shadow?
    return false if nil_or_empty?(@event.character_name) || @event.transparent || @remove
    if OWShadowSettings::CASE_SENSITIVE_BLACKLISTS
      return false if OWShadowSettings::SHADOWLESS_CHARACTER_NAME.any?{ |e| @event.character_name[/#{e}/] }
    else
      return false if OWShadowSettings::SHADOWLESS_CHARACTER_NAME.any?{ |e| @event.character_name[/#{e}/i] }
    end
    terrain = $game_map.terrain_tag(@event.x, @event.y)
    return false if OWShadowSettings::SHADOWLESS_TERRAIN_NAME.any? { |e| terrain == e } if terrain
    return true
  end
  #-----------------------------------------------------------------------------
  # Calculation of shadow size when jumping
  #-----------------------------------------------------------------------------
  def update
    return if disposed? || !$scene.is_a?(Scene_Map)
    return jump_sprite if @event.jumping?
    @sprite = Sprite.new(@viewport) if !@sprite
    @ow_shadow_bitmap.update
    @sprite.bitmap  = @ow_shadow_bitmap.bitmap
    @sprite.x       = @rsprite.x
    @sprite.y       = @rsprite.y
    @sprite.ox      = @ow_shadow_bitmap.width / 2
    @sprite.oy      = @ow_shadow_bitmap.height - 2
    @sprite.z       = @event.screen_z(@ow_shadow_bitmap.height) - 1
    @sprite.zoom_x  = @rsprite.zoom_x
    @sprite.zoom_y  = @rsprite.zoom_y
    @sprite.opacity = @rsprite.opacity
    @sprite.visible = @rsprite.visible && show_shadow?
  end
  #-----------------------------------------------------------------------------
end

#-------------------------------------------------------------------------------
# New Method for setting shadow of any event given the map id and event id
#-------------------------------------------------------------------------------
def pbSetOverworldShadow(name, event_id = nil, map_id = nil)
  return if !$scene.is_a?(Scene_Map)
  return if nil_or_empty?(name)
  if !event_id
    $scene.spritesetGlobal.playersprite.ow_shadow.set_bitmap(name)
  else
    map_id = $game_map.map_id if !map_id
    $scene.spritesets[map_id].character_sprites[(event_id - 1)].ow_shadow.set_bitmap(name)
  end
end


#-------------------------------------------------------------------------------
# Referencing and initializing Shadow Sprite in Sprite_Character
#-------------------------------------------------------------------------------
class Sprite_Character
  attr_accessor :ow_shadow

# Initializing Shadow with Character
 alias __ow_shadow__initialize initialize unless private_method_defined?(:__ow_shadow__initialize)
  def initialize(viewport, character = nil)
    __ow_shadow__initialize(viewport, character)
    @ow_shadow = Sprite_OWShadow.new(self, character, viewport)
    update
  end

# Disposing Shadow with Character
  alias __ow_shadow__dispose dispose unless method_defined?(:__ow_shadow__dispose)
  def dispose(*args)
    __ow_shadow__dispose(*args)
    @ow_shadow.dispose if @ow_shadow
    @ow_shadow = nil
  end

# Updating Shadow with Character
  alias __ow_shadow__update update unless method_defined?(:__ow_shadow__update)
  def update(*args)
    __ow_shadow__update(*args)
    return if !@ow_shadow
    @ow_shadow.update
  end
end

#-------------------------------------------------------------------------------
# Adding accessors to the Game_Character class
#-------------------------------------------------------------------------------
class Game_Character
  attr_reader :jump_count
  attr_reader :jump_distance
  attr_reader :jump_distance_left
  attr_reader :jump_peak
end

#-------------------------------------------------------------------------------
# Adding accessors to the Scene_Map class
#-------------------------------------------------------------------------------
class Scene_Map
  attr_accessor :spritesets
end

#-------------------------------------------------------------------------------
# Adding accessors to the Game_Character class
#-------------------------------------------------------------------------------
class Spriteset_Map
  attr_accessor :character_sprites
end
