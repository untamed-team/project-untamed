#-------------------------------------------------------------------------------
# Base class for defining a menu entry (Deprecated)
#-------------------------------------------------------------------------------
class MenuEntry
  attr_reader :name

  # defined by user
  def icon; return MENU_FILE_PATH + @icon; end
  def selectable?; return false; end
  def selected
    pbMessage(_INTL("This is a working Menu Entry for Voltseon's Pause Menu."))
  end
end

#-------------------------------------------------------------------------------
# Base class for defining a menu component
#-------------------------------------------------------------------------------
class Component
  attr_accessor :viewport
  attr_accessor :sprites

  def start_component(viewport, menu)
    @viewport = viewport
    @menu     = menu
    @sprites  = {}
  end

  # To be defined by user
  def should_draw?; return false; end
  def refresh; end

  def update; pbUpdateSpriteHash(@sprites); end
  def dispose; pbDisposeSpriteHash(@sprites); end
end

#-------------------------------------------------------------------------------
# Main Pause Menu class
#-------------------------------------------------------------------------------
class VoltseonsPauseMenu_Scene
  attr_accessor :should_exit
  attr_accessor :should_refresh

  attr_reader   :components
  attr_reader   :hidden
  attr_reader   :start_up

  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @sprites = {}
    # Background
    @sprites["backshade"]        = Sprite.new(@viewport)
    @sprites["backshade"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @sprites["backshade"].z      = -10
    @sprites["backshade"].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, BACKGROUND_TINT)
    # Location window
    @sprites["location"] = Sprite.new(@viewport)
    # Menu arrows
    filename = MENU_FILE_PATH + $PokemonSystem.from_current_menu_theme("arrow_left")
    @sprites["leftarrow"]         = AnimatedSprite.new(filename, 8, 40, 28, 2, @viewport)
    @sprites["leftarrow"].x       = (Graphics.width / 2) - @sprites["leftarrow"].bitmap.width - (($game_temp.menu_icon_width / 4) * 3)
    @sprites["leftarrow"].y       = Graphics.height - 56
    @sprites["leftarrow"].z       = 2
    @sprites["leftarrow"].visible = true
    @sprites["leftarrow"].play
    filename = MENU_FILE_PATH + $PokemonSystem.from_current_menu_theme("arrow_right")
    @sprites["rightarrow"]         = AnimatedSprite.new(filename, 8, 40, 28, 2, @viewport)
    @sprites["rightarrow"].x       = (Graphics.width / 2) + (($game_temp.menu_icon_width / 4) * 3)
    @sprites["rightarrow"].y       = Graphics.height - 56
    @sprites["rightarrow"].z       = 2
    @sprites["rightarrow"].visible = true
    @sprites["rightarrow"].play
    # Helpful Variables
    @should_exit    = false
    @should_refresh = true
    @hidden         = true
  end

  def pbStartScene
    @start_up = true
    @viewport.z = 99999
    @components = []
    @component_names = []
    MENU_COMPONENTS.each do |c|
      next if c[/VoltseonsPauseMenu/i]
      component = Object.const_get(c).new
      @components.push(component) if component.should_draw?
      @component_names.push(c)
    end
    @components.each { |component| component.start_component(@viewport, self) }
    @pause_menu = VoltseonsPauseMenu.new
    @pause_menu.start_component(@viewport, @sprites, self)
    pbSEPlay(MENU_OPEN_SOUND)
    pbRefresh
    @pause_menu.refresh_menu
    @sprites.each do |key, sprite|
      if key[/backshade/]
        sprite.opacity = 0
      elsif sprite.y >= (Graphics.height / 2)
        sprite.y += (Graphics.height / 2)
      elsif !key[/location/]
        sprite.y -= (Graphics.height / 2)
      end
    end
    @components.each_with_index do |component, i|
      sprites = component.sprites
      cname = @component_names[i]
      sprites.each_value do |sprite|
        if sprite.y >= (Graphics.height / 2)
          sprite.y += (Graphics.height / 2)
        else
          sprite.y -= (Graphics.height / 2)
        end
      end
    end
    pbShowMenu
    @start_up = false
  end

  def pbHideMenu
    return if @hidden
    xvals = {:main => {}}
    yvals = {:main => {}}
    @sprites.each do |key, sprite|
      xvals[:main][key] = sprite.x
      yvals[:main][key] = sprite.y
    end
    @components.each_with_index do |component, i|
      sprites = component.sprites
      cname = @component_names[i]
      xvals[cname] = {}
      yvals[cname] = {}
      sprites.each do |key, sprite|
        xvals[cname][key] = sprite.x
        yvals[cname][key] = sprite.y
      end
    end
    duration = Graphics.frame_rate / 6
    duration.times do |i|
      factor = (i + 1).to_f / duration
      Graphics.update
      pbUpdateSceneMap
      @sprites.each do |key, sprite|
        if key[/backshade/]
          sprite.opacity = 255 * (1 - factor)
        elsif key[/location/]
          sprite.x = xvals[:main][key] - (sprite.bitmap.width * factor)
        elsif sprite.y >= (Graphics.height / 2)
          sprite.y = yvals[:main][key] + ((Graphics.height / 2) * factor)
        else
          sprite.y = yvals[:main][key] - ((Graphics.height / 2) * factor)
        end
      end
      @components.each_with_index do |component, i|
        sprites = component.sprites
        cname = @component_names[i]
        sprites.each do |key, sprite|
          if sprite.y >= (Graphics.height / 2)
            sprite.y = yvals[cname][key] + ((Graphics.height / 2) * factor)
          else
            sprite.y = yvals[cname][key] - ((Graphics.height / 2) * factor)
          end
        end
      end
    end
    @hidden = true
  end

  def pbShowMenu
    return if !@hidden
    xvals = {:main => {}}
    yvals = {:main => {}}
    @sprites.each do |key, sprite|
      xvals[:main][key] = sprite.x
      yvals[:main][key] = sprite.y
    end
    @components.each_with_index do |component, i|
      sprites = component.sprites
      cname = @component_names[i]
      xvals[cname] = {}
      yvals[cname] = {}
      sprites.each do |key, sprite|
        xvals[cname][key] = sprite.x
        yvals[cname][key] = sprite.y
      end
    end
    duration = Graphics.frame_rate / 6
    duration.times do |i|
      factor = (i + 1).to_f / duration
      Graphics.update
      pbUpdateSceneMap
      @sprites.each do |key, sprite|
        if key[/backshade/]
          sprite.opacity = 255 * factor
        elsif key[/location/]
          sprite.x = xvals[:main][key] + (sprite.bitmap.width * factor)
        elsif sprite.y >= (Graphics.height / 2)
          sprite.y = yvals[:main][key] - ((Graphics.height / 2) * factor)
        else
          sprite.y = yvals[:main][key] + ((Graphics.height / 2) * factor)
        end
      end
      @components.each_with_index do |component, i|
        sprites = component.sprites
        cname = @component_names[i]
        sprites.each do |key, sprite|
          if sprite.y >= (Graphics.height / 2)
            sprite.y = yvals[cname][key] - ((Graphics.height / 2) * factor)
          else
            sprite.y = yvals[cname][key] + ((Graphics.height / 2) * factor)
          end
        end
      end
    end
    @hidden   = false
  end

  def update
    @has_terminated = false
    loop do
      Graphics.update
      Input.update
      @pause_menu.update
      @components.each { |component| component.update }
      pbUpdateSpriteHash(@sprites)
      pbUpdateSceneMap
      pbRefresh
      next if !@should_exit
      pbSEPlay(MENU_CLOSE_SOUND)
      pbHideMenu
      pbEndScene
      break
    end
  end

  def pbRefresh
    return if @should_exit || !@should_refresh
    # Refresh the location text
    @sprites["location"].bitmap.clear if @sprites["location"].bitmap
    bmp = RPG::Cache.load_bitmap(MENU_FILE_PATH, $PokemonSystem.from_current_menu_theme("bg_location"))
    @sprites["location"].bitmap = Bitmap.new(bmp.width, bmp.height)
    @sprites["location"].bitmap.blt(0, 0, bmp, Rect.new(0, 0, bmp.width, bmp.height))
    bmp.dispose
    mapname = $game_map.name
    base_color = $PokemonSystem.from_current_menu_theme(LOCATION_TEXTCOLOR, Color.new(248, 248, 248))
    shdw_color = $PokemonSystem.from_current_menu_theme(LOCATION_TEXTOUTLINE, Color.new(48, 48, 48))
    x_offset = @sprites["location"].bitmap.width - 64
    pbSetSystemFont(@sprites["location"].bitmap)
    pbDrawTextPositions(@sprites["location"].bitmap, [[$game_map.name, x_offset, 12, 1, base_color, shdw_color, true]])
    @sprites["location"].x = -@sprites["location"].bitmap.width + (@sprites["location"].bitmap.text_size($game_map.name).width + 64 + 32)
    @sprites["location"].x -= @sprites["location"].bitmap.width if @hidden
    @components.each { |component| component.refresh }
    @should_refresh = false
  end

  def pbEndScene
    return if @has_terminated
    $game_temp.in_menu = false
    @has_terminated    = true
    @pause_menu.dispose
    @components.each { |component| component.dispose }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#-------------------------------------------------------------------------------
# Overriding the default Pause Menu Screen calls
#-------------------------------------------------------------------------------
class Scene_Map
  def call_menu
    $game_temp.menu_calling = false
    $game_temp.in_menu      = true
    $game_player.straighten
    $game_map.update
    if safeExists?(MENU_FILE_PATH)
      sscene = VoltseonsPauseMenu_Scene.new
    else
      if !$game_temp.menu_warining_done
        pbMessage("Current MENU_FILE_PATH defined for Voltseon's Pause Menu is #{MENU_FILE_PATH}")
        pbMessage("This directory does not exist in your game folder.")
        pbMessage("To rectify this, open the 001_VoltseonMenu_Config.rb using the text editor of your choice, and edit the MENU_FILE_PATH you see there.")
        pbMessage("Opening default pause menu as a failsafe...")
        $game_temp.menu_warining_done = true
      end
      sscene = PokemonPauseMenu_Scene.new
    end
    sscreen = PokemonPauseMenu.new(sscene)
    sscreen.pbStartPokemonMenu
    $game_temp.in_menu = false
  end
end

if safeExists?(MENU_FILE_PATH)
  class PokemonPauseMenu
    def pbStartPokemonMenu
      @scene.pbStartScene
      @scene.update
    end
  end
end

#-------------------------------------------------------------------------------
# Debug command to change menu themes
#-------------------------------------------------------------------------------
MenuHandlers.add(:debug_menu, :set_menu_theme, {
  "name"        => _INTL("Set Menu Theme"),
  "parent"      => "playermenu",
  "description" => _INTL("Change the Menu Theme for Voltseon's Pause Menu..."),
  "effect"      => proc {
    maxval = 0
    oldval = $PokemonSystem.current_menu_theme
    params = ChooseNumberParams.new
    params.setRange(1, MENU_TEXTCOLOR.length)
    params.setDefaultValue($PokemonSystem.current_menu_theme)
    $PokemonSystem.current_menu_theme = pbMessageChooseNumber(_INTL("Set the menu theme. (1 - {1})", maxval), params)
    pbMessage(_INTL("The menu theme has been set to {1}.", $PokemonSystem.current_menu_theme))
    $game_temp.menu_theme_changed = (oldval != $PokemonSystem.current_menu_theme)
  }
})

#-------------------------------------------------------------------------------
# Options command to change menu themes
#-------------------------------------------------------------------------------
MenuHandlers.add(:options_menu, :menu_theme, {
  "name"        => _INTL("Menu Theme"),
  "order"       => 200,
  "type"        => NumberOption,
  "condition"   => proc { next CHANGE_THEME_IN_OPTIONS && MENU_TEXTCOLOR.length > 1 },
  "parameters"  => 1..MENU_TEXTCOLOR.length,
  "description" => _INTL("Set pause menu theme."),
  "get_proc"    => proc { next $PokemonSystem.current_menu_theme },
  "set_proc"    => proc { |value, scene| $PokemonSystem.current_menu_theme = value }
})

#-------------------------------------------------------------------------------
# Attribute in PokemonSystem to save the current menu theme in the save file
#-------------------------------------------------------------------------------
class PokemonSystem
  attr_writer :current_menu_theme

  def current_menu_theme
    @current_menu_theme = DEFAULT_MENU_THEME if !@current_menu_theme
    return @current_menu_theme
  end

  def from_current_menu_theme(data, default = nil)
    default = data if default.nil?
    if data.is_a?(String)
      path = MENU_FILE_PATH
      file = "Theme #{$PokemonSystem.current_menu_theme + 1}/#{default}"
      return file if pbResolveBitmap(MENU_FILE_PATH + file)
      return default
    elsif data.is_a?(Array)
      return data[$PokemonSystem.current_menu_theme] || default
    end
    return default
  end
end

#-------------------------------------------------------------------------------
# Attribute in Game_Temp to store the last selected  menu option
#-------------------------------------------------------------------------------
class Game_Temp
  attr_accessor :menu_warining_done
  attr_accessor :menu_icon_width

  def menu_icon_width
    if !@menu_icon_width
      width = 48
      if pbResolveBitmap(MENU_FILE_PATH + "menu_debug")
        bmp = RPG::Cache.load_bitmap(MENU_FILE_PATH, "menu_debug")
        width = bmp.width
        bmp.dispose
      end
      @menu_icon_width = width
    end
    return @menu_icon_width
  end
end

# The person reading this is very cool!
# Thanks (:
