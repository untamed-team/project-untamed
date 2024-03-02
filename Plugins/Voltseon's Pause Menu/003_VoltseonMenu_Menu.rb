#-------------------------------------------------------------------------------
# Main Pause Menu component
#-------------------------------------------------------------------------------
class VoltseonsPauseMenu < Component
  def start_component(viewport, spritehash, menu)
    super(viewport, menu)
    @sprites = spritehash
    @entries = []
    @current_selection = $game_temp.menu_last_choice
    @current_selection = 0 if @current_selection < 0
    @should_refresh    = true
    # Background image
    @sprites["menuback"] = Sprite.new(@viewport)
    @sprites["menuback"].bitmap = RPG::Cache.load_bitmap(MENU_FILE_PATH, $PokemonSystem.from_current_menu_theme("bg"))
    @sprites["menuback"].z  = -5
    @sprites["menuback"].oy = @sprites["menuback"].bitmap.height
    @sprites["menuback"].y  = @sprites["menuback"].bitmap.height
    # Did you know that the first pokémon you see in Red and Blue, Nidorino plays a Nidorina cry?
    # This could have been prevented if they just used vCry("Nidorino") ;)
    # Voltseon's Handy Tools is available at https://reliccastle.com/resources/400/4
    recalc_menu_entries
    calc_display_index
    redraw_menu_icons
    @sprites["icon_dummy_l"]    = IconSprite.new(0, 0, @viewport)
    @sprites["icon_dummy_l"].y  = Graphics.height - 42
    @sprites["icon_dummy_l"].ox = $game_temp.menu_icon_width / 2
    @sprites["icon_dummy_l"].oy = $game_temp.menu_icon_width / 2
    @sprites["icon_dummy_r"]    = IconSprite.new(0, 0, @viewport)
    @sprites["icon_dummy_r"].y  = Graphics.height - 42
    @sprites["icon_dummy_r"].ox = $game_temp.menu_icon_width / 2
    @sprites["icon_dummy_r"].oy = $game_temp.menu_icon_width / 2
    recalc_icon_positions(true)
    @sprites["entrytext"]       = BitmapSprite.new(Graphics.width / 2, 40, @viewport)
    @sprites["entrytext"].y     = Graphics.height - 188
    @sprites["entrytext"].ox    = Graphics.width / 4
    @sprites["entrytext"].x     = Graphics.width / 2
    @sprites["leftarrow"].visible  = @disp_indices.length != 1
    @sprites["rightarrow"].visible = @disp_indices.length > 1
  end

  def update
    exit = false # should the menu-loop continue
    if Input.trigger?(Input::BACK) || Input.trigger?(Input::ACTION)
      $game_temp.menu_last_choice = @current_selection
      @menu.should_exit = true
      return
    elsif Input.press?(Input::LEFT)
      shift_cursor(-1)
    elsif Input.press?(Input::RIGHT) && @disp_indices.length > 1
      shift_cursor(1)
    elsif Input.trigger?(Input::USE)
      pbPlayDecisionSE
      old_menu_theme = $PokemonSystem.current_menu_theme
      exit = @entries[@current_selection][:proc].call(@menu)
      $game_temp.menu_last_choice = @current_selection
      exit = true if old_menu_theme != $PokemonSystem.current_menu_theme
      @menu.should_exit = exit
      if !exit
        recalc_menu_entries
        calc_display_index
        redraw_menu_icons
        recalc_icon_positions(true)
        @should_refresh = true
      end
    end
    if @should_refresh && !@menu.should_exit
      refresh_menu
      @menu.should_refresh = true
      @should_refresh      = false
      @sprites["leftarrow"].visible  = @entries.length != 1
      @sprites["rightarrow"].visible = @disp_indices.length > 1
    end
    @menu.should_exit = exit
  end

  # direction is either 1 (right) or -1 (left)
  def shift_cursor(direction)
    return false if @entries.length < 2
    @current_selection += direction
    # keep selection within array bounds
    @current_selection = @entries.length - 1 if @current_selection < 0
    @current_selection = 0 if @current_selection >= @entries.length
    # Shift array elements
    if direction < 0
      el = @entries.length - 1
      temp = @entry_indices[el].clone
      @entry_indices[el] = nil
      e_temp = @entry_indices.clone
      (el + 1).times { |i| @entry_indices[i + 1] = e_temp[i] }
      @entry_indices[0] = temp
      @entry_indices.compact!
    else
      ret = @entry_indices.shift
      @entry_indices.push(ret)
    end
    pbSEPlay(MENU_CURSOR_SOUND)
    # Animation stuff
    duration = (Graphics.frame_rate / 8)
    middle   = @disp_indices.length / 2
    if @disp_indices.length < 3
      recalc_icon_positions
      duration.times do
        Graphics.update
        @menu.components.each { |component| component.update }
        pbUpdateSpriteHash(@sprites)
      end
      return
    end
    duration.times do
      Graphics.update
      pbUpdateSpriteHash(@sprites)
      @menu.components.each { |component| component.update }
      pbUpdateSceneMap
      @sprites.each do |key, sprite|
        next if !key[/icon/]
        total     = (direction > 0) ? @icon_offset_left[key] : @icon_offset_right[key]
        amt2      = total / (duration * 1.0)
        amt       = ((direction > 0) ? amt2.floor : amt2.ceil).to_i
        amt       -= (direction * 1) if @disp_indices.length < 5
        sprite.x  += amt
        final_pos = (@icon_base_x[key] + total)
        base_x    = direction > 0 ? (sprite.x <= final_pos) : (sprite.x >= final_pos)
        sprite.x  = (@icon_base_x[key] + total) if base_x
      end
      @sprites["icon_#{middle}"].zoom_x -= (ACTIVE_SCALE - 1.0) / duration
      @sprites["icon_#{middle}"].zoom_y -= (ACTIVE_SCALE - 1.0) / duration
      mdr = middle + direction
      mdr = mdr.clamp(0, 6)
      @sprites["icon_#{mdr}"].zoom_x += (ACTIVE_SCALE - 1.0) / duration
      @sprites["icon_#{mdr}"].zoom_y += (ACTIVE_SCALE - 1.0) / duration
    end
    recalc_icon_positions
    refresh_menu
    @sprites["leftarrow"].visible  = @entries.length != 1
    @sprites["rightarrow"].visible = @disp_indices.length > 1
  end

  # Calculate indexes of sprites to be displayed
  def calc_display_index
    @disp_indices = @entry_indices.clone
    if @entry_indices.length.even?
      @disp_indices[0] = nil
      @disp_indices.compact!
    end
    if @disp_indices.length > 7
      offset  = (@entry_indices.length - 7) / 2
      end_val = 7 + offset
      @disp_indices = @disp_indices[offset...end_val]
    end
  end

  # Get all the entries to be displayed
  def recalc_menu_entries
    old_entries = @entries.length
    @entries    = []
    MenuHandlers.each_available(:pause_menu) do |option, hash, name|
      icon = $PokemonSystem.from_current_menu_theme("menu_#{option}")
      @entries.push({:icon => icon, :name => name, :proc => hash["effect"]})
    end
    if @entries.length != old_entries && old_entries != 0
      @current_selection += (@entries.length - old_entries)
      @current_selection = @current_selection.clamp(0, @entries.length - 1)
    end
    @entry_indices = []
    middle = @entries.length / 2
    @entry_indices[middle] = @current_selection
    current = @current_selection + 1
    # Calculating an array in the fashion [...,5,6,0,1,2....]
    ((middle + 1)...@entries.length).each do |i|
      current = 0 if current >= @entries.length
      @entry_indices[i] = current
      current += 1
    end
    middle.times do |i|
      current = 0 if current >= @entries.length
      @entry_indices[i] = current
      current += 1
    end
  end

  def redraw_menu_icons
    @sprites.each_key do |key|
      next if !key[/icon/] || key[/dummy/]
      @sprites[key].dispose
      @sprites[key] = nil
      @sprites.delete(key)
    end
    middle = @disp_indices.length / 2
    @disp_indices.length.times do |i|
      @sprites["icon_#{i}"]    = IconSprite.new(0, 0, @viewport)
      @sprites["icon_#{i}"].y  = Graphics.height - 42
      @sprites["icon_#{i}"].ox = $game_temp.menu_icon_width / 2
      @sprites["icon_#{i}"].oy = $game_temp.menu_icon_width / 2
      @sprites["icon_#{i}"].visible = true
    end
    if @disp_indices.length == 2
      @sprites["icon_1"]    = IconSprite.new(0, 0, @viewport)
      @sprites["icon_1"].y  = Graphics.height - 42
      @sprites["icon_1"].ox = $game_temp.menu_icon_width / 2
      @sprites["icon_1"].oy = $game_temp.menu_icon_width / 2
      @sprites["icon_1"].visible = true
    end
  end

  # Calculate x positions of icons after animation is complete
  def recalc_icon_positions(recalc = false)
    middle = @disp_indices.length / 2
    @sprites["icon_#{middle}"].x = Graphics.width / 2
    max_dist = Graphics.width / 8
    offset = middle == 0 ? max_dist : max_dist / (@disp_indices.length / 2)
    offset = offset.clamp(max_dist / 3, max_dist)
    last_x = 0
    addl_space = 48 - $game_temp.menu_icon_width
    middle.times do |i|
      final_x = Graphics.width / 2 - ($game_temp.menu_icon_width / 2) - ((offset - 21) * @disp_indices.length / 2)
      final_x -= ($game_temp.menu_icon_width + offset + addl_space) * (middle - i)
      @sprites["icon_#{i}"].x = final_x
      last_x = final_x if i == 0
    end
    @sprites["icon_dummy_l"].x = last_x - ($game_temp.menu_icon_width + offset + addl_space)
    last_x = 0
    ((middle + 1)...@disp_indices.length).each do |i|
      final_x = Graphics.width/2 + ($game_temp.menu_icon_width / 2) + (@disp_indices.length < 5 ?  offset / 2 : ((offset - 21) * @disp_indices.length / 2))
      final_x += ($game_temp.menu_icon_width + offset + addl_space) * (i - middle)
      @sprites["icon_#{i}"].x = final_x
      last_x = final_x
    end
    @sprites["icon_dummy_r"].x = last_x + ($game_temp.menu_icon_width + offset + addl_space)
    return if !recalc
    @icon_base_x = {}
    @icon_offset_left = {}
    @icon_offset_right = {}
    @sprites.each do |key, sprite|
      next if !key[/icon/]
      @icon_base_x[key] = sprite.x
    end
    @sprites.each do |key, sprite|
      next if !key[/icon/]
      if key[/dummy/]
        if key[/_l/]
          max_dev = @sprites["icon_0"].x - sprite.x
        elsif key[/_r/]
          max_dev = @sprites[key].x - @sprites["icon_#{@disp_indices.length - 1}"].x
        end
        @icon_offset_left[key]  = -max_dev
        @icon_offset_right[key] = max_dev
        next
      end
      index = key.gsub("icon_", "").to_i
      new_l = (index == 0)? "icon_dummy_l" : "icon_#{index - 1}"
      new_r = (index == @disp_indices.length - 1)? "icon_dummy_r" : "icon_#{index + 1}"
      @icon_offset_left[key]  = @sprites[new_l].x - sprite.x
      @icon_offset_right[key] = @sprites[new_r].x - sprite.x
    end
  end

  def refresh_menu
    calc_display_index
    middle = @disp_indices.length / 2
    @disp_indices.each_with_index do |idx, val|
      icon = MENU_FILE_PATH + @entries[idx][:icon]
      @sprites["icon_#{val}"].setBitmap(icon)
      @sprites["icon_#{val}"].zoom_x = 1
      @sprites["icon_#{val}"].zoom_y = 1
    end
    @sprites["icon_#{middle}"].zoom_x = ACTIVE_SCALE
    @sprites["icon_#{middle}"].zoom_y = ACTIVE_SCALE
    if @entries.length <= 8
      b2  = MENU_FILE_PATH + @entries[@entry_indices[0]][:icon]
      idx = (@entries.length.even?) ? @entry_indices[0] : @entry_indices[@disp_indices.length - 1]
      b1  = MENU_FILE_PATH + @entries[idx][:icon]
    else
      offset = (@entry_indices.length - 7) / 2
      of2    = ((@entry_indices.length % 2) - 1).abs
      idx    = @entry_indices[offset - 1 + of2]
      b1     = MENU_FILE_PATH + @entries[idx][:icon]
      idx    = @entry_indices[@entry_indices.length - offset]
      b2     = MENU_FILE_PATH + @entries[idx][:icon]
    end
    @sprites["icon_dummy_l"].setBitmap(b1)
    @sprites["icon_dummy_r"].setBitmap(b2)
    return if !SHOW_MENU_NAMES
    @sprites["entrytext"].bitmap.clear
    text = @entries[@current_selection][:name]
    pbSetSystemFont(@sprites["entrytext"].bitmap)
    base_color = $PokemonSystem.from_current_menu_theme(MENU_TEXTCOLOR, Color.new(248, 248, 248))
    shdw_color = $PokemonSystem.from_current_menu_theme(MENU_TEXTOUTLINE, Color.new(48, 48, 48))
    pbDrawTextPositions(@sprites["entrytext"].bitmap, [[text, Graphics.width / 4, 8, 2, base_color, shdw_color]])
  end
end
