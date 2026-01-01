#---------------------------------------------------------------
# Configuration Settings
#---------------------------------------------------------------
module BeachWaterBubbles
  # Set to true to disable water bubbles for all followers regardless of species
  TOGGLE_BUBBLES_FOR_ALL_FOLLOWERS = false

  # List of Pokemon species that should not have water bubbles
  NO_BUBBLE_FOLLOWERS = [
    # Gen 1
    :BEEDRILL, :VENOMOTH, :ABRA, :GEODUDE, :MAGNEMITE, :GASTLY, :HAUNTER,
    :KOFFING, :WEEZING, :PORYGON, :MEW,
    # Gen 2
    :MISDREAVUS, :UNOWN, :PORYGON2, :CELEBI,
    # Gen 3
    :DUSTOX, :SHEDINJA, :MEDITITE, :VOLBEAT, :ILLUMISE, :FLYGON, :LUNATONE,
    :SOLROCK, :BALTOY, :CLAYDOL, :CASTFORM, :SHUPPET, :DUSKULL, :CHIMECHO,
    :GLALIE, :BELDUM, :METANG, :LATIAS, :LATIOS, :JIRACHI,
    # Gen 4
    :MISMAGIUS, :BRONZOR, :BRONZONG, :SPIRITOMB, :CARNIVINE, :MAGNEZONE,
    :PORYGONZ, :PROBOPASS, :DUSKNOIR, :FROSLASS, :ROTOM, :UXIE, :MESPRIT,
    :AZELF, :GIRATINA_1, :CRESSELIA, :DARKRAI,
    # Gen 5
    :MUNNA, :MUSHARNA, :YAMASK, :COFAGRIGUS, :SOLOSIS, :DUOSION, :REUNICLUS,
    :VANILLITE, :VANILLISH, :VANILLUXE, :ELGYEM, :BEHEEYEM, :LAMPENT,
    :CHANDELURE, :CRYOGONAL, :HYDREIGON, :VOLCARONA, :RESHIRAM, :ZEKROM,
    # Gen 6
    :SPRITZEE, :DRAGALGE, :CARBINK, :KLEFKI, :PHANTUMP, :DIANCIE, :HOOPA,
    # Gen 7
    :VIKAVOLT, :CUTIEFLY, :RIBOMBEE, :COMFEY, :DHELMISE, :TAPUKOKO, :TAPULELE,
    :TAPUBULU, :COSMOG, :COSMOEM, :LUNALA, :NIHILEGO, :KARTANA, :NECROZMA,
    :MAGEARNA, :POIPOLE, :NAGANADEL,
    # Gen 8
    :ORBEETLE, :FLAPPLE, :SINISTEA, :POLTEAGEIST, :FROSMOTH, :DREEPY, :DRAKLOAK,
    :DRAGAPULT, :ETERNATUS, :REGIELEKI, :REGIDRAGO, :CALYREX
  ]
end

#---------------------------------------------------------------
# Terrain Tag Register
# Change to any # needed to register a shallow beach Terrain Tag
#---------------------------------------------------------------
GameData::TerrainTag.register({
  :id                     => :ShallowBeach,
  :id_number              => 18
})

#---------------------------------------------------------------
# Class for the water bubble sprite
#---------------------------------------------------------------
class Sprite_WaterBubble
  attr_reader :visible
  attr_accessor :event

  FRAME_WIDTH = 64     # Width of each frame
  FRAME_HEIGHT = 32    # Height of each frame
  ANIMATION_TIME = 0.3 # Seconds per animation cycle
  FRAMES_COUNT = 3     # Total number of animation frames
  TERRAIN_TAG = 18     # Terrain tag for shallow beach

  def initialize(sprite, event, viewport = nil)
    @rsprite = sprite
    @event = event
    @viewport = viewport
    @disposed = false
    @visible = true
    @animation_timer = 0.0
    @sprite = nil
    load_water_texture
    update
  end

  def load_water_texture
    @waterbitmap = AnimatedBitmap.new("Graphics/Plugins/Beach Water Bubbles/splash")
  end

  def dispose
    return if @disposed
    @sprite&.dispose
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

  def should_show_bubble?
    return false if @event.character_name.empty? || @event.character_name == "nil" ||
                   @event.transparent || $game_map.terrain_tag(@event.x, @event.y) != TERRAIN_TAG

    if @event.is_a?(Game_Follower)
      return false if BeachWaterBubbles::TOGGLE_BUBBLES_FOR_ALL_FOLLOWERS
      pkmn = $player.able_party[0]
      return false if BeachWaterBubbles::NO_BUBBLE_FOLLOWERS.any? { |s|
                        s == pkmn.species || s.to_s == "#{pkmn.species}_#{pkmn.form}"
                      }
      if defined?(FollowingPkmn)
        return false if FollowingPkmn.airborne_follower? &&
                       !FollowingPkmn::SURFING_FOLLOWERS_EXCEPTIONS.any? { |s|
                         s == pkmn.species || s.to_s == "#{pkmn.species}_#{pkmn.form}"
                       }
      end
    end
    return true
  end

  def update
    return if disposed? || !$scene || !$scene.is_a?(Scene_Map)

    unless should_show_bubble?
      if @sprite
        @sprite.dispose
        @sprite = nil
      end
      return
    end

    create_sprite if !@sprite
    update_sprite_properties
    update_visibility
    update_animation
  end

  private

  def create_sprite
    @sprite = Sprite.new(@viewport)
    @sprite.bitmap = @waterbitmap.bitmap
    @sprite.visible = @visible
  end

  def update_sprite_properties
    @sprite.src_rect.set(0, 0, FRAME_WIDTH, FRAME_HEIGHT)
    @sprite.x = @rsprite.x
    @sprite.y = @rsprite.y
    @sprite.ox = FRAME_WIDTH / 2
    @sprite.oy = FRAME_HEIGHT - 2
    @sprite.z = @rsprite.z + (@rsprite.respond_to?(:priority) ? @rsprite.priority : 1)
    @sprite.zoom_x = @rsprite.zoom_x
    @sprite.zoom_y = @rsprite.zoom_y
    @sprite.opacity = @rsprite.opacity
    pbDayNightTint(@sprite)
    @sprite.color.set(0, 0, 0, 0)
  end

  def update_visibility
    @sprite&.visible = !@event.transparent && @visible
  end

  def update_animation
    return unless @sprite
    delta = Graphics.delta
    @animation_timer += delta
    if @animation_timer >= ANIMATION_TIME
      @animation_timer = 0.0
    end
    frame = ((@animation_timer / ANIMATION_TIME) * FRAMES_COUNT).to_i % FRAMES_COUNT
    @sprite.src_rect.x = frame * FRAME_WIDTH
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
    @waterbubble&.dispose
    dispose_with_bubbles
  end

  alias update_with_bubbles update
  def update
    update_with_bubbles
    @waterbubble&.update
    update_visibility
  end

  def update_visibility
    self.visible = !@character.transparent
  end

  alias visible_with_bubbles= visible=
  def visible=(value)
    super(value)
    @waterbubble&.visible = value
  end
end
