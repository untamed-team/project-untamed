#===============================================================================
# BW Party Screen compatibility.
#===============================================================================
if PluginManager.installed?("BW Party Screen")
  class PokemonPartyPanel < Sprite
    def initialize(pokemon, index, viewport = nil)
      super(viewport)
      @pokemon = pokemon
      @active = (index == 0)
      @refreshing = true
      self.x = (index % 2) * Graphics.width / 2
      self.y = (16 * (index % 2)) + (96 * (index / 2))
      @panelbgsprite = ChangelingSprite.new(0, 0, viewport)
      @panelbgsprite.z = self.z
      if PARTY_B2W2_STYLE
        if @active
          @panelbgsprite.addBitmap("able", "Graphics/Pictures/Party/panel_round_B2W2")
          @panelbgsprite.addBitmap("ablesel", "Graphics/Pictures/Party/panel_round_sel_B2W2")
          @panelbgsprite.addBitmap("fainted", "Graphics/Pictures/Party/panel_round_faint_B2W2")
          @panelbgsprite.addBitmap("faintedsel", "Graphics/Pictures/Party/panel_round_faint_sel_B2W2")
          @panelbgsprite.addBitmap("swap", "Graphics/Pictures/Party/panel_round_swap_B2W2")
          @panelbgsprite.addBitmap("swapsel", "Graphics/Pictures/Party/panel_round_swap_sel_B2W2")
          @panelbgsprite.addBitmap("swapsel2", "Graphics/Pictures/Party/panel_round_swap_sel2_B2W2")
        else
          @panelbgsprite.addBitmap("able", "Graphics/Pictures/Party/panel_rect_B2W2")
          @panelbgsprite.addBitmap("ablesel", "Graphics/Pictures/Party/panel_rect_sel_B2W2")
          @panelbgsprite.addBitmap("fainted", "Graphics/Pictures/Party/panel_rect_faint_B2W2")
          @panelbgsprite.addBitmap("faintedsel", "Graphics/Pictures/Party/panel_rect_faint_sel_B2W2")
          @panelbgsprite.addBitmap("swap", "Graphics/Pictures/Party/panel_rect_swap_B2W2")
          @panelbgsprite.addBitmap("swapsel", "Graphics/Pictures/Party/panel_rect_swap_sel_B2W2")
          @panelbgsprite.addBitmap("swapsel2", "Graphics/Pictures/Party/panel_rect_swap_sel2_B2W2")
        end
      else
        if @active
          @panelbgsprite.addBitmap("able", "Graphics/Pictures/Party/panel_round")
          @panelbgsprite.addBitmap("ablesel", "Graphics/Pictures/Party/panel_round_sel")
          @panelbgsprite.addBitmap("fainted", "Graphics/Pictures/Party/panel_round_faint")
          @panelbgsprite.addBitmap("faintedsel", "Graphics/Pictures/Party/panel_round_faint_sel")
          @panelbgsprite.addBitmap("swap", "Graphics/Pictures/Party/panel_round_swap")
          @panelbgsprite.addBitmap("swapsel", "Graphics/Pictures/Party/panel_round_swap_sel")
          @panelbgsprite.addBitmap("swapsel2", "Graphics/Pictures/Party/panel_round_swap_sel2")
        else
          @panelbgsprite.addBitmap("able", "Graphics/Pictures/Party/panel_rect")
          @panelbgsprite.addBitmap("ablesel", "Graphics/Pictures/Party/panel_rect_sel")
          @panelbgsprite.addBitmap("fainted", "Graphics/Pictures/Party/panel_rect_faint")
          @panelbgsprite.addBitmap("faintedsel", "Graphics/Pictures/Party/panel_rect_faint_sel")
          @panelbgsprite.addBitmap("swap", "Graphics/Pictures/Party/panel_rect_swap")
          @panelbgsprite.addBitmap("swapsel", "Graphics/Pictures/Party/panel_rect_swap_sel")
          @panelbgsprite.addBitmap("swapsel2", "Graphics/Pictures/Party/panel_rect_swap_sel2")
        end
      end
      @hpbgsprite = ChangelingSprite.new(0, 0, viewport)
      @hpbgsprite.z = self.z + 1
      if PARTY_B2W2_STYLE
        @hpbgsprite.addBitmap("able", "Graphics/Pictures/Party/overlay_hp_back_B2W2")
        @hpbgsprite.addBitmap("fainted", "Graphics/Pictures/Party/overlay_hp_back_faint_B2W2")
        @hpbgsprite.addBitmap("swap", "Graphics/Pictures/Party/overlay_hp_back_swap_B2W2")
      else
        @hpbgsprite.addBitmap("able", "Graphics/Pictures/Party/overlay_hp_back")
        @hpbgsprite.addBitmap("fainted", "Graphics/Pictures/Party/overlay_hp_back_faint")
        @hpbgsprite.addBitmap("swap", "Graphics/Pictures/Party/overlay_hp_back_swap")
      end 
      @ballsprite = ChangelingSprite.new(0, 0, viewport)
      @ballsprite.z = self.z + 1
      @ballsprite.addBitmap("desel", "Graphics/Pictures/Party/icon_ball")
      @ballsprite.addBitmap("sel", "Graphics/Pictures/Party/icon_ball_sel")
      @ballsprite.visible = PluginManager.installed?("Enhanced UI") && Settings::SHOW_PARTY_BALL
      @pkmnsprite = PokemonIconSprite.new(pokemon, viewport)
      @pkmnsprite.setOffset(PictureOrigin::CENTER)
      @pkmnsprite.active = @active
      @pkmnsprite.z      = self.z + 2
      @helditemsprite = HeldItemIconSprite.new(0, 0, @pokemon, viewport)
      @helditemsprite.z = self.z + 3
      @overlaysprite = BitmapSprite.new(Graphics.width, Graphics.height, viewport)
      @overlaysprite.z = self.z + 4
      pbSetSystemFont(@overlaysprite.bitmap)
      @hpbar    = AnimatedBitmap.new("Graphics/Pictures/Party/overlay_hp")
      @statuses = AnimatedBitmap.new(_INTL("Graphics/Pictures/statuses"))
      @selected      = false
      @preselected   = false
      @switching     = false
      @text          = nil
      @refreshBitmap = true
      @refreshing    = false
      refresh
    end
  
    def dispose
      @panelbgsprite.dispose
      @hpbgsprite.dispose
      @ballsprite.dispose
      @pkmnsprite.dispose
      @helditemsprite.dispose
      @overlaysprite.bitmap.dispose
      @overlaysprite.dispose
      @hpbar.dispose
      @statuses.dispose
      super
    end
  end
end