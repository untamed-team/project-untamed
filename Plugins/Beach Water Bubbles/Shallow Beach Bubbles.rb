#---------------------------------------------------------------
# Terrain Tag Register
# Change to any # needed to register a shallow beach Terrain Tag
#---------------------------------------------------------------
GameData::TerrainTag.register({
  :id                     => :ShallowBeach,
  :id_number              => 31
})

#---------------------------------------------------------------
# Class for the water bubble sprite
#---------------------------------------------------------------
class Sprite_WaterBubble
  attr_reader :visible
  attr_accessor :event

  def initialize(sprite, event, viewport = nil)
    @rsprite = sprite
    @event = event
    @viewport = viewport
    @disposed = false
    @visible = true
    load_water_texture
    @cws = 64  # Width of each frame. Change to 24 if using splashGBA.png
    @chs = 32  # Height of each frame. Change to 24 if using splashGBA.png
    @frame_counter = 0
    update
  end

  def load_water_texture
    texture_path = "Graphics/Plugins/Beach Water Bubbles/splash" # Change to Location of image path. If using splashGBA change from splash.png to splashGBA.png
    @waterbitmap = AnimatedBitmap.new(texture_path)
  end

  def dispose
    return if @disposed
    @sprite.dispose if @sprite
    @sprite = nil
    @disposed = true
  end

  def disposed?
    @disposed
  end

  def visible=(value)
    @visible = value
    update_visibility
  end

  def update
    return if disposed? || !$scene || !$scene.is_a?(Scene_Map)
    if @event.character_name.empty? || @event.character_name == "nil" || 
       $game_map.terrain_tag(@event.x, @event.y) != 31 || @event.transparent # Change != 31 to the tile # used in game.
      if @sprite
        @sprite.dispose
        @sprite = nil
      end
      return
    end
    pkmn = $player.able_party[0]
    return if disposed? || !$scene || !$scene.is_a?(Scene_Map)
    if @event.character_name.empty? || @event.character_name == "nil" || 
      $game_map.terrain_tag(@event.x, @event.y) != 31 || @event.transparent ||
      (@event.is_a?(Game_Follower) && (FollowingPkmn.airborne_follower? && 
      !FollowingPkmn::SURFING_FOLLOWERS_EXCEPTIONS.any? do |s|
        s == pkmn.species || s.to_s == "#{pkmn.species}_#{pkmn.form}"
      end))
      if @sprite
        @sprite.dispose
        @sprite = nil
      end
      return
    end
    if !@sprite
      @sprite = Sprite.new(@viewport)
      @sprite.bitmap = @waterbitmap.bitmap
      @sprite.visible = @visible
    end
    cw = @cws
    ch = @chs
    @sprite.src_rect.set(0, 0, cw, ch)
    @sprite.x = @rsprite.x
    @sprite.y = @rsprite.y
    @sprite.ox = cw / 2 # X Position of sprite, adjust as needed
    @sprite.oy = ch - 2 # Y Position of sprite, adjust as needed
    @sprite.z = @rsprite.z + 1 
    @sprite.zoom_x = @rsprite.zoom_x
    @sprite.zoom_y = @rsprite.zoom_y
    @sprite.opacity = @rsprite.opacity
    pbDayNightTint(@sprite) # Day and Night Tinting for sprite
    @sprite.color.set(0, 0, 0, 0) # Keeps sprite from changing color for following Pokémon and otherwise if poisoned, burned, etc.
    update_visibility
    update_animation
  end

  def update_visibility
    return unless @sprite
    @sprite.visible = !@event.transparent && @visible
  end

  def update_animation
    return unless @sprite
    @frame_counter += 1
    frame = (@frame_counter / 9) % 3 # Change 15 to a number you feel it animates well at if needed. 15 animates smoothly in v21.1 but runs slow in v20.1. Change to 9 in V20.1
    @sprite.src_rect.x = frame * @cws
  end

  def start_animation
    @animation_playing = true
    update_visibility
  end

  def end_animation
    @animation_playing = false
    update_visibility
  end
end

#---------------------------------------------------------------
# Class for the Character Sprites
#---------------------------------------------------------------
class Sprite_Character < RPG::Sprite
  alias initialize_with_bubbles initialize
  def initialize(viewport, character = nil)
    initialize_with_bubbles(viewport, character)
    @waterbubble = Sprite_WaterBubble.new(self, character, viewport)
  end

  alias dispose_with_bubbles dispose
  def dispose
    @waterbubble.dispose if @waterbubble
    dispose_with_bubbles
  end

  alias update_with_bubbles update
  def update
    update_with_bubbles
    @waterbubble.update if @waterbubble
    update_visibility
  end

  def update_visibility
    self.visible = !@character.transparent
  end

  alias visible_with_bubbles= visible=
  def visible=(value)
    super(value) 
    @waterbubble.visible = value if @waterbubble
  end
end
