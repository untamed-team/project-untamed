#===============================================================================
# * Set the Controls Screen - by FL (Credits will be apreciated) v20.1
#===============================================================================
#
# This script is for Pokémon Essentials. It creates a "Set the controls" screen
# on pause menu, allowing the player to map the actions to the keys in keyboard, 
# ignoring the values defined on F1. You can also define the default controls.
#
#== INSTALLATION ===============================================================
#
# To this script works, put it above main OR convert into a plugin.
#
#== NOTES ======================================================================
#
# '$PokemonSystem.game_controls = nil' resets the controls.
#
# This script, by default, doesn't allows the player to redefine some commands
# like F8 (screenshot key), but if the player assign an action to this key,
# like the "Cancel" action, this key will do this action AND take screenshots
# when pressed. Remember that F12 will reset the game.
#
#===============================================================================

#call the controls screen through F1
#handled at the top of Speed Up 2.0 script

if !PluginManager.installed?("Set the Controls Screen")
  PluginManager.register({                                                 
    :name    => "Set the Controls Screen",                                        
    :version => "1.1.2",                                                     
    :link    => "https://www.pokecommunity.com/showthread.php?t=309391",             
    :credits => "FL"
  })
end

# Open the controls UI.
# You can call this method directly from other places like an event.
def open_set_controls_ui(menu_to_refresh=nil)
  #added by Gardenette
  #initialize the controls if there is no save slot, meaning if this is the
  #first time controls are set
  #if the palyer doesn't save after setting controls, that's their fault :)
  $PokemonSystem.game_controls = nil if !SaveData.get_newest_save_slot
  scene=PokemonControls_Scene.new
  screen=PokemonControlsScreen.new(scene)
  pbFadeOutIn {
    screen.start_screen
    menu_to_refresh.pbRefresh if menu_to_refresh
  }
end

module Keys
  def self.number_of_keys
    return default_controls.length
    end
  # Here you can change the number of keys for each action and the
  # default values
  def self.default_controls
    return [
      ControlConfig.new("Down", "Down"),
      ControlConfig.new("Left", "Left"),
      ControlConfig.new("Right", "Right"),
      ControlConfig.new("Up", "Up"),
      ControlConfig.new("Action", "C"),
      ControlConfig.new("Action", "Enter"),
      ControlConfig.new("Action", "Space"),
      ControlConfig.new("Cancel",  "X"),
      ControlConfig.new("Cancel", "Esc"),
      ControlConfig.new("Walk/Run", "Z"),
      ControlConfig.new("Registered Item", "Shift"),
      ControlConfig.new("Change Game Speed", "Q"),
      ControlConfig.new("Toggle Follower", "F"),
      ControlConfig.new("Cycle Follower", "D"),
      ControlConfig.new("Skip Text", "X"),
      ControlConfig.new("Quick Save", "S"),
      ControlConfig.new("Battle Info", "N"),
      ControlConfig.new("Move Info", "M")
      #ControlConfig.new("AUX4", "4")
    ]
  end 

  # Available keys
  CONTROLS_LIST = {
    # Mouse buttons
    "Backspace"    => 0x08,
    "Tab"          => 0x09,
    "Clear"        => 0x0C,
    "Enter"        => 0x0D,
    "Shift"        => 0x10,
    "Ctrl"         => 0x11,
    "Alt"          => 0x12,
    "Pause"        => 0x13,
    # IME keys
    "Caps Lock"    => 0x14,
    "Esc"          => 0x1B,
    "Space"        => 0x20,
    "Page Up"      => 0x21,
    "Page Down"    => 0x22,
    "End"          => 0x23,
    "Home"         => 0x24,
    "Left"         => 0x25,
    "Up"           => 0x26,
    "Right"        => 0x27,
    "Down"         => 0x28,
    "Select"       => 0x29,
    "Print"        => 0x2A,
    "Execute"      => 0x2B,
    "Print Screen" => 0x2C,
    "Insert"       => 0x2D,
    "Delete"       => 0x2E,
    "Help"         => 0x2F,
    "0"            => 0x30,
    "1"            => 0x31,
    "2"            => 0x32,
    "3"            => 0x33,
    "4"            => 0x34,
    "5"            => 0x35,
    "6"            => 0x36,
    "7"            => 0x37,
    "8"            => 0x38,
    "9"            => 0x39,
    "A"            => 0x41,
    "B"            => 0x42,
    "C"            => 0x43,
    "D"            => 0x44,
    "E"            => 0x45,
    "F"            => 0x46,
    "G"            => 0x47,
    "H"            => 0x48,
    "I"            => 0x49,
    "J"            => 0x4A,
    "K"            => 0x4B,
    "L"            => 0x4C,
    "M"            => 0x4D,
    "N"            => 0x4E,
    "O"            => 0x4F,
    "P"            => 0x50,
    "Q"            => 0x51,
    "R"            => 0x52,
    "S"            => 0x53,
    "T"            => 0x54,
    "U"            => 0x55,
    "V"            => 0x56,
    "W"            => 0x57,
    "X"            => 0x58,
    "Y"            => 0x59,
    "Z"            => 0x5A,
    # Windows keys
    "Numpad 0"     => 0x60,
    "Numpad 1"     => 0x61,
    "Numpad 2"     => 0x62,
    "Numpad 3"     => 0x63,
    "Numpad 4"     => 0x64,
    "Numpad 5"     => 0x65,
    "Numpad 6"     => 0x66,
    "Numpad 7"     => 0x67,
    "Numpad 8"     => 0x68,
    "Numpad 9"     => 0x69,
    "Multiply"     => 0x6A,
    "Add"          => 0x6B,
    "Separator"    => 0x6C,
    "Subtract"     => 0x6D,
    "Decimal"      => 0x6E,
    "Divide"       => 0x6F,
    "F1"           => 0x70,
    "F2"           => 0x71,
    "F3"           => 0x72,
    "F4"           => 0x73,
    "F5"           => 0x74,
    "F6"           => 0x75,
    "F7"           => 0x76,
    "F8"           => 0x77,
    "F9"           => 0x78,
    "F10"          => 0x79,
    "F11"          => 0x7A,
    "F12"          => 0x7B,
    "F13"          => 0x7C,
    "F14"          => 0x7D,
    "F15"          => 0x7E,
    "F16"          => 0x7F,
    "F17"          => 0x80,
    "F18"          => 0x81,
    "F19"          => 0x82,
    "F20"          => 0x83,
    "F21"          => 0x84,
    "F22"          => 0x85,
    "F23"          => 0x86,
    "F24"          => 0x87,
    "Num Lock"     => 0x90,
    "Scroll Lock"  => 0x91,
    # Multiple position Shift, Ctrl and Menu keys
    ";:"           => 0xBA,
    "+"            => 0xBB,
    ","            => 0xBC,
    "-"            => 0xBD,
    "."            => 0xBE,
    "/?"           => 0xBF,
    "`~"           => 0xC0,
    "{"            => 0xDB,
    "\|"           => 0xDC,
    "}"            => 0xDD,
    "'\""          => 0xDE,
    "AX"           => 0xE1 # Japan only
  }

  def self.key_name(key_code)
    return CONTROLS_LIST.key(key_code) if CONTROLS_LIST.key(key_code)
    return key_code==0 ? "None" : "?"
  end 

  def self.key_code(key_name)
    ret  = CONTROLS_LIST[key_name]
    raise "The button #{key_name} no longer exists! " if !ret
    return ret
  end 

  def self.detect_key
    loop do
      Graphics.update
      Input.update
      for key_code in CONTROLS_LIST.values
        return key_code if Input.triggerex?(key_code)
      end
    end
  end
end 

class ControlConfig
  attr_reader :control_action
  attr_accessor :key_code

  def initialize(control_action, default_key)
    @control_action = control_action
    @key_code = Keys.key_code(default_key)
  end

  def key_name
    return Keys.key_name(@key_code)
  end
end

module Input
  class << self
    if !method_defined?(:_old_fl_press?)
      alias :_old_fl_press? :press?
      def press?(button)
        key = buttonToKey(button)
        return key ? pressex_array?(key) : _old_fl_press?(button)
      end

      alias :_old_fl_trigger? :trigger?
      def trigger?(button)
        key = buttonToKey(button)
        return key ? triggerex_array?(key) : _old_fl_trigger?(button)
      end

      alias :_old_fl_repeat? :repeat?
      def repeat?(button)
        key = buttonToKey(button)
        return key ? repeatex_array?(key) : _old_fl_repeat?(button)
      end

      alias :_old_fl_release? :release?
      def release?(button)
        key = buttonToKey(button)
        return key ? releaseex_array?(key) : _old_fl_release?(button)
      end
    end

    def pressex_array?(array)
      for item in array
        return true if pressex?(item)
      end
      return false
    end

    def triggerex_array?(array)
      for item in array
        return true if triggerex?(item)
      end
      return false
    end

    def repeatex_array?(array)
      for item in array
        return true if repeatex?(item)
        return true if triggerex?(item) # Fix for MKXP-Z issue
      end
      return false
    end

    def releaseex_array?(array)
      for item in array
        return true if releaseex?(item)
      end
      return false
    end

    def dir4
      return 0 if press?(DOWN) && press?(UP)
      return 0 if press?(LEFT) && press?(RIGHT)
      for button in [DOWN,LEFT,RIGHT,UP]
        return button if press?(button)
      end
      return 0
    end

    def dir8
      buttons = []
      for b in [DOWN,LEFT,RIGHT,UP]
        buttons.push(b) if press?(b)
      end
      if buttons.length==0
        return 0
      elsif buttons.length==1
        return buttons[0]
      elsif buttons.length==2
        return 0 if (buttons[0]==DOWN && buttons[1]==UP)
        return 0 if (buttons[0]==LEFT && buttons[1]==RIGHT)
      end
      up_down    = 0
      left_right = 0
      for b in buttons
        up_down    = b if up_down==0 && (b==UP || b==DOWN)
        left_right = b if left_right==0 && (b==LEFT || b==RIGHT)
      end
      if up_down==DOWN
        return 1 if left_right==LEFT
        return 3 if left_right==RIGHT
        return 2
      elsif up_down==UP
        return 7 if left_right==LEFT
        return 9 if left_right==RIGHT
        return 8
      else
        return 4 if left_right==LEFT
        return 6 if left_right==RIGHT
        return 0
      end
    end

    def buttonToKey(button)
      $PokemonSystem = PokemonSystem.new if !$PokemonSystem
      case button
        when Input::DOWN
          return $PokemonSystem.game_control_code("Down")
        when Input::LEFT
          return $PokemonSystem.game_control_code("Left")
        when Input::RIGHT
          return $PokemonSystem.game_control_code("Right")
        when Input::UP
          return $PokemonSystem.game_control_code("Up")
        when Input::ACTION # Z, W, Y, Shift
          return $PokemonSystem.game_control_code("Walk/Run")
        when Input::BACK # X, ESC
          return $PokemonSystem.game_control_code("Cancel")
        when Input::USE # C, ENTER, Space
          return $PokemonSystem.game_control_code("Action")
        when Input::SPECIAL
          return $PokemonSystem.game_control_code("Registered Item")
        when Input::AUX1 # A, Q, Page Up
          return $PokemonSystem.game_control_code("Change Game Speed")
        when Input::AUX2 # S, Page Down
          return $PokemonSystem.game_control_code("Toggle Follower")
        when Input::AUX5 # F, F5, Tab
          return $PokemonSystem.game_control_code("Cycle Follower")
        when Input::AUX3
          return $PokemonSystem.game_control_code("Skip Text")
        when Input::AUX6
          return $PokemonSystem.game_control_code("Quick Save")
        #when Input::AUX4
          #return $PokemonSystem.game_control_code("AUX4")
        when Input::AUX7
          return $PokemonSystem.game_control_code("Battle Info")
        when Input::AUX8
          return $PokemonSystem.game_control_code("Move Info")
        else
          return nil
      end
    end
  end
end

class Window_PokemonControls < Window_DrawableCommand
  attr_reader :reading_input
  attr_reader :controls
  attr_reader :changed

  DEFAULT_EXTRA_INDEX = 0
  EXIT_EXTRA_INDEX = 1

  def initialize(controls,x,y,width,height)
    @controls = controls
    @name_base_color   = Color.new(0,0,0)
    @name_shadow_color = Color.new(255,255,255)
    #the key bound to the control
    @sel_base_color    = Color.new(24,112,216)
    @sel_shadow_color  = Color.new(255,255,255)
    @reading_input = false
    @changed = false
    super(x,y,width,height)
  end

  def itemCount
    return @controls.length+EXIT_EXTRA_INDEX+1
  end

  def set_new_input(new_input)
    @reading_input = false
    return if @controls[@index].key_code==new_input
    for control in @controls # Remove the same input for the same array
      control.key_code = 0 if control.key_code==new_input
    end
    @controls[@index].key_code=new_input
    @changed = true
    refresh
  end

  def on_exit_index?
    return @controls.length + EXIT_EXTRA_INDEX == @index
  end

  def on_default_index?
    return @controls.length + DEFAULT_EXTRA_INDEX == @index
  end
  
  def item_description
    ret=nil
    if on_exit_index?
      ret=_INTL("Exit. If you changed anything, asks if you want to keep changes.")
    elsif on_default_index?
      ret=_INTL("Restore the default controls.")
    else
      ret= control_description(@controls[@index].control_action)
    end
    return ret
  end 

  def control_description(control_action)
    hash = {}
    hash["Down"] = _INTL("Moves the character. Select entries and navigate menus.")
    hash["Left"] = hash["Down"]
    hash["Right"] = hash["Down"]
    hash["Up"] = hash["Down"]
    hash["Action"] = _INTL("Confirm a choice, check things, talk to people, and move through text.")
    hash["Cancel"] = _INTL("Exit, cancel a choice or mode, and move at field in a different speed.")
    hash["Walk/Run"] = _INTL("Holding this button makes you run if your default is walking and vice versa.")
    hash["Registered Item"] = _INTL("Used as the hotkey for registered items. Also acts as the Select button.")
    hash["Change Game Speed"] = _INTL("Press to change the game speed to fast, faster, or reset it.")
    hash["Toggle Follower"] = _INTL("Toggle whether a party Pokémon follows you.")
    hash["Cycle Follower"] = _INTL("Cycle through your party Pokémon, changing which one follows you.")
    hash["Skip Text"] = _INTL("Hold this button to skip through text.")
    hash["Quick Save"] = _INTL("Press to save your game immediately.")
    hash["Battle Info"] = _INTL("Show information about the current battle.")
    hash["Move Info"] = _INTL("Show information about the currently selected move.")
    #hash["AUX6"] = _INTL("Test")
    return hash.fetch(control_action, _INTL("Set the controls."))
  end

  def drawItem(index,count,rect)
    rect=drawCursor(index,rect)
    name = case index-@controls.length
      when DEFAULT_EXTRA_INDEX   ; _INTL("Default")
      when EXIT_EXTRA_INDEX      ; _INTL("Exit")
      else                       ; @controls[index].control_action
    end
    width= rect.width*9/20
    pbDrawShadowText(
      self.contents,rect.x,rect.y,width,rect.height,
      name,@name_base_color,@name_shadow_color
    )
    self.contents.font.name = "Power Green"
    #self.contents.draw_text(rect.x,rect.y,width,rect.height,name)
    return if index>=@controls.length
    value = _INTL(@controls[index].key_name)
    xpos = width+rect.x
    pbDrawShadowText(
      self.contents,xpos,rect.y,width,rect.height,
      value,@sel_base_color,@sel_shadow_color
    )
    self.contents.font.name = "Power Green"
    #self.contents.draw_text(xpos,rect.y,width,rect.height,value)
  end

  def update
    oldindex=self.index
    super
    do_refresh=self.index!=oldindex
    if self.active && self.index<=@controls.length
      if Input.trigger?(Input::C)
        if on_default_index?
          if pbConfirmMessage(_INTL("Do you want to revert to default controls?"))
            pbPlayDecisionSE()
            @controls = Keys.default_controls
            @changed = true
            do_refresh = true
          end
        elsif self.index<@controls.length
          @reading_input = true
        end
      end
    end
    refresh if do_refresh
  end
end

class PokemonControls_Scene
  def start_scene
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites["title"]=Window_UnformattedTextPokemon.newWithSize(
      _INTL("Controls"),0,0,Graphics.width,64,@viewport
    )
    @sprites["textbox"]=pbCreateMessageWindow
    @sprites["textbox"].letterbyletter=false
    game_controls = $PokemonSystem.game_controls.map{|c| c.clone}
    @sprites["controlwindow"]=Window_PokemonControls.new(
      game_controls,0,@sprites["title"].height,Graphics.width,
      Graphics.height-@sprites["title"].height-@sprites["textbox"].height
    )
    @sprites["controlwindow"].viewport=@viewport
    @sprites["controlwindow"].visible=true
    @changed = false
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites) { update }
  end

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def main
    last_index=-1
    should_refresh_text = false
    pbActivateWindow(@sprites,"controlwindow"){
    loop do
      Graphics.update
      Input.update
      update
      should_refresh_text = @sprites["controlwindow"].index!=last_index
      if @sprites["controlwindow"].reading_input
        @sprites["textbox"].text=_INTL("Press a new key.")
        @sprites["controlwindow"].set_new_input(Keys.detect_key)
        should_refresh_text = true
        @changed = true
      else
        if Input.trigger?(Input::B) || (
          Input.trigger?(Input::C) && @sprites["controlwindow"].on_exit_index?
        )
          if(
            @sprites["controlwindow"].changed && 
            pbConfirmMessage(_INTL("Keep changes?"))
          )
            should_refresh_text = true # Visual effect
            if @sprites["controlwindow"].controls.find{|c| c.key_code == 0}
              @sprites["textbox"].text=_INTL("Fill all fields!")
              should_refresh_text = false
            else
              $PokemonSystem.game_controls = @sprites["controlwindow"].controls
              break
            end
          else
            break
          end
        end
      end
      if should_refresh_text
        if @sprites["textbox"].text!=@sprites["controlwindow"].item_description
          @sprites["textbox"].text = @sprites["controlwindow"].item_description
        end
        last_index = @sprites["controlwindow"].index
      end
    end
    }
  end

  def end_scene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeMessageWindow(@sprites["textbox"])
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

class PokemonControlsScreen
  def initialize(scene)
    @scene=scene
  end

  def start_screen
    @scene.start_scene
    @scene.main
    @scene.end_scene
  end
end

class PokemonSystem
  attr_writer :game_controls
  def game_controls
    @game_controls = Keys.default_controls if !@game_controls
    return @game_controls
  end

  def game_control_code(control_action)
    ret = []
    for control in game_controls
      ret.push(control.key_code) if control.control_action == control_action
    end
    return ret
  end
end

#add to options menu

#===============================================================================
# Main options list
#===============================================================================
class Window_PokemonOption < Window_DrawableCommand
  def itemCount
    #return @options.length + 1
	return @options.length + 2
  end

  def drawItem(index, _count, rect)
    rect = drawCursor(index, rect)
    sel_index = self.index
    # Draw option's name
    #optionname = (index == @options.length) ? _INTL("Close") : @options[index].name
    optionname = case index
      when @options.length+1; _INTL("Close")
      when @options.length;   _INTL("Controls")
      else; @options[index].name
    end
	
	optionwidth = rect.width * 9 / 20
    pbDrawShadowText(self.contents, rect.x, rect.y, optionwidth, rect.height, optionname,
                     (index == sel_index) ? SEL_NAME_BASE_COLOR : self.baseColor,
                     (index == sel_index) ? SEL_NAME_SHADOW_COLOR : self.shadowColor)
    #return if index == @options.length
    return if index >= @options.length
	# Draw option's values
    case @options[index]
    when EnumOption
      if @options[index].values.length > 1
        totalwidth = 0
        @options[index].values.each do |value|
          totalwidth += self.contents.text_size(value).width
        end
        spacing = (rect.width - rect.x - optionwidth - totalwidth) / (@options[index].values.length - 1)
        spacing = 0 if spacing < 0
        xpos = optionwidth + rect.x
        ivalue = 0
        @options[index].values.each do |value|
          pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value,
                           (ivalue == self[index]) ? SEL_VALUE_BASE_COLOR : self.baseColor,
                           (ivalue == self[index]) ? SEL_VALUE_SHADOW_COLOR : self.shadowColor)
          xpos += self.contents.text_size(value).width
          xpos += spacing
          ivalue += 1
        end
      else
        pbDrawShadowText(self.contents, rect.x + optionwidth, rect.y, optionwidth, rect.height,
                         optionname, self.baseColor, self.shadowColor)
      end
    when NumberOption
      value = _INTL("Type {1}/{2}", @options[index].lowest_value + self[index],
                    @options[index].highest_value - @options[index].lowest_value + 1)
      xpos = optionwidth + (rect.x * 2)
      pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value,
                       SEL_VALUE_BASE_COLOR, SEL_VALUE_SHADOW_COLOR, 1)
    when SliderOption
      value = sprintf(" %d", @options[index].highest_value)
      sliderlength = rect.width - rect.x - optionwidth - self.contents.text_size(value).width
      xpos = optionwidth + rect.x
      self.contents.fill_rect(xpos, rect.y - 2 + (rect.height / 2), sliderlength, 4, self.baseColor)
      self.contents.fill_rect(
        xpos + ((sliderlength - 8) * (@options[index].lowest_value + self[index]) / @options[index].highest_value),
        rect.y - 8 + (rect.height / 2),
        8, 16, SEL_VALUE_BASE_COLOR
      )
      value = sprintf("%d", @options[index].lowest_value + self[index])
      xpos += (rect.width - rect.x - optionwidth) - self.contents.text_size(value).width
      pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value,
                       SEL_VALUE_BASE_COLOR, SEL_VALUE_SHADOW_COLOR)
    else
      value = @options[index].values[self[index]]
      xpos = optionwidth + rect.x
      pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value,
                       SEL_VALUE_BASE_COLOR, SEL_VALUE_SHADOW_COLOR)
    end
  end
end

#===============================================================================
# Options main screen
#===============================================================================
class PokemonOption_Scene
  def pbChangeSelection
    hash = @hashes[@sprites["option"].index]
    # Call selected option's "on_select" proc (if defined)
    @sprites["textbox"].letterbyletter = false
    hash["on_select"]&.call(self) if hash
    # Set descriptive text
    description = ""
    if hash
      if hash["description"].is_a?(Proc)
        description = hash["description"].call
      elsif !hash["description"].nil?
        description = _INTL(hash["description"])
      end
    else
      #description = _INTL("Close the screen.")
	  if @sprites["option"].index==@options.length
        description = _INTL("View and set the controls of the game.")
      else  
        description = _INTL("Close the screen.")
      end
    end
    @sprites["textbox"].text = description
  end

  def pbOptions
    pbActivateWindow(@sprites, "option") {
      index = -1
      loop do
        Graphics.update
        Input.update
        pbUpdate
        if @sprites["option"].index != index
          pbChangeSelection
          index = @sprites["option"].index
        end
        @options[index].set(@sprites["option"][index], self) if @sprites["option"].value_changed
        if Input.trigger?(Input::BACK)
          break
        elsif Input.trigger?(Input::USE)
          #break if @sprites["option"].index == @options.length
		  break if @sprites["option"].index == @options.length+1
          open_set_controls_ui if @sprites["option"].index == @options.length
        end
      end
    }
  end
end