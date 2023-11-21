class Spriteset_Global
    alias rf_portraits_init initialize
    alias rf_portraits_update update

    attr_accessor :activePortrait

    def initialize
        rf_portraits_init
        @activePortrait = nil
        @oldPortrait = nil
    end

    def newPortrait(portrait, align = 0)
        @oldPortrait = @activePortrait
        @oldPortrait&.state = :closing
        @activePortrait = RfDialoguePortrait.new(portrait, align, @@viewport2)
    end

    def update
        rf_portraits_update
        @activePortrait&.update
        @oldPortrait&.update
    end

    def self.viewport
        return @@viewport2
    end
end

class RfDialoguePortrait
    attr_reader :state
    attr_reader :portrait

    # portrait: Name of the portrait graphic in Graphics/Portraits (ANIMATED GIFS ARE NOT SUPPORTED)
    # align: 0 aligns left, 1 aligns right
    # viewport: if you don't understand what this does you probably shouldn't be creating this object yourself
    def initialize(portrait, align = 0, viewport = nil)
        @align = align
        @sprite = Sprite.new(viewport)
        @sprite.bitmap = Bitmap.new("Graphics/Portraits/#{portrait}")
        @sprite.ox = @sprite.bitmap.width * (align % 2)
        @sprite.oy = @sprite.bitmap.height
        @sprite.x = align > 0 ? Graphics.width + 128 : -128
        @sprite.y = Graphics.height
        @sprite.opacity = 0
        @outline = @sprite.create_outline_sprite
        @outline.opacity = 0
        @state = :opening
        @state_change = System.uptime
        @disposed = false
        rescue # nullify the bitmap if something goes wrong
        @sprite.bitmap = nil
    end

    def state=(new_state_id)
        @state = new_state_id
        @state_change = System.uptime
    end

    def portrait=(portrait)
        # dispose old sprites
        @outline&.dispose
        @sprite.bitmap&.dispose
        # create new ones
        @sprite.bitmap = Bitmap.new("Graphics/Portraits/#{portrait}")
        @outline = @sprite.create_outline_sprite
        rescue # nullify the bitmap if something goes wrong
        @sprite.bitmap = nil
        @outline = nil
    end

    def update
        return if @disposed
        case @state
        when :opening
            openAnimation
        when :active
            mainUpdate
        when :closing
            closeAnimation
        else
            raise "Invalid dialogue portrait state"
        end
    end

    def openAnimation
        @sprite.opacity = lerp(0,255,0.1,@state_change,System.uptime)
        @outline.opacity = lerp(0,255,0.1,@state_change,System.uptime)
        if @align > 0
            @sprite.x = lerp(Graphics.width + 128, Graphics.width, 0.15, @state_change, System.uptime)
            @outline.x = lerp(Graphics.width + 126, Graphics.width - 2, 0.15, @state_change, System.uptime)
            @state = :active if @sprite.x <= Graphics.width
        else 
            @sprite.x = lerp(-128, 0, 0.15, @state_change, System.uptime)
            @outline.x = lerp(-130, -2, 0.15, @state_change, System.uptime)
            @state = :active if @sprite.x >= 0
        end
    end

    def mainUpdate
        self.state = :closing if !pbMapInterpreterRunning? && PORTRAITS_AUTO_CLOSE_ON_EVENT_END
        # lip flaps would go here, however these are currently not implemented
    end

    def closeAnimation
        return if @disposed
        @sprite.opacity = lerp(255,0,0.1,@state_change,System.uptime)
        @outline.opacity = lerp(255,0,0.1,@state_change,System.uptime)
        if @align > 0
            @sprite.x = lerp(Graphics.width, Graphics.width + 128, 0.15, @state_change, System.uptime)
            @outline.x = lerp(Graphics.width - 2, Graphics.width + 126, 0.15, @state_change, System.uptime)
            dispose if @sprite.x >= Graphics.width + 128
        else 
            @sprite.x = lerp(0, -128, 0.15, @state_change, System.uptime)
            @outline.x = lerp(-2, -130, 0.15, @state_change, System.uptime)
            dispose if @sprite.x <= -128
        end
    end

    def dispose
        @sprite.bitmap&.dispose
        @sprite.dispose
        @outline.dispose
        @disposed = true
    end

    def disposed?
        return @disposed
    end
end

if RfSettings::PORTRAITS_ENABLE_CAVEOVERLAY_FIX
    EventHandlers.remove(:on_map_or_spriteset_change, :show_darkness)
    EventHandlers.add(:on_map_or_spriteset_change, :show_darkness,
    proc { |scene, _map_changed|
        next if !scene || !scene.spriteset
        map_metadata = $game_map.metadata
        if map_metadata&.dark_map
            $game_temp.darkness_sprite = DarknessSprite.new(Spriteset_Map.viewport)
            scene.spriteset.addUserSprite($game_temp.darkness_sprite)
            if $PokemonGlobal.flashUsed
            $game_temp.darkness_sprite.radius = $game_temp.darkness_sprite.radiusMax
            end
        else
            $PokemonGlobal.flashUsed = false
            $game_temp.darkness_sprite&.dispose
            $game_temp.darkness_sprite = nil
        end
        }
    )
end