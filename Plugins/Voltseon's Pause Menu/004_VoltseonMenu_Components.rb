#-------------------------------------------------------------------------------
# Safari Hud component
#-------------------------------------------------------------------------------
class VPM_SafariHud < Component
  def start_component(viewport, menu)
    super(viewport, menu)
    @sprites["overlay"]    = BitmapSprite.new(Graphics.width / 2, 96, viewport)
    @sprites["overlay"].ox = @sprites["overlay"].bitmap.width
    @sprites["overlay"].x  = Graphics.width
    @base_color = $PokemonSystem.from_current_menu_theme(MENU_TEXTCOLOR, Color.new(248, 248, 248))
    @shdw_color = $PokemonSystem.from_current_menu_theme(MENU_TEXTOUTLINE, Color.new(48, 48, 48))
  end

  def should_draw?; return pbInSafari?; end

  def refresh
    text = _INTL("Balls: {1}",pbSafariState.ballcount)
    text2 = (Settings::SAFARI_STEPS > 0) ? _INTL("Steps: {1}/{2}", pbSafariState.steps, Settings::SAFARI_STEPS) : ""
    @sprites["overlay"].bitmap.clear
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbDrawTextPositions(@sprites["overlay"].bitmap, [
      [text, (Graphics.width / 2) - 8, 12, 1, @base_color, @shdw_color],
      [text2, (Graphics.width / 2) - 8, 44, 1, @base_color, @shdw_color]
    ])
  end
end

#-------------------------------------------------------------------------------
# Bug Contest Hud component
#-------------------------------------------------------------------------------
class VPM_BugContestHud < Component
  def start_component(viewport, menu)
    super(viewport, menu)
    @sprites["overlay"]    = BitmapSprite.new(Graphics.width / 2, 96, viewport)
    @sprites["overlay"].ox = @sprites["overlay"].bitmap.width
    @sprites["overlay"].x  = Graphics.width
    @base_color = $PokemonSystem.from_current_menu_theme(MENU_TEXTCOLOR, Color.new(248, 248, 248))
    @shdw_color = $PokemonSystem.from_current_menu_theme(MENU_TEXTOUTLINE, Color.new(48, 48, 48))
  end

  def should_draw?; return pbInBugContest?; end

  def refresh
    if pbBugContestState.lastPokemon
      text  =  _INTL("Caught: {1}", pbBugContestState.lastPokemon.speciesName)
      text2 =  _INTL("Level: {1}", pbBugContestState.lastPokemon.level)
      text3 =  _INTL("Balls: {1}", pbBugContestState.ballcount)
    else
      text = _INTL("Caught: None")
      text2 = _INTL("Balls: {1}", pbBugContestState.ballcount)
      text3 = ""
    end
    @sprites["overlay"].bitmap.clear
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbDrawTextPositions(@sprites["overlay"].bitmap, [
      [text, (Graphics.width / 2) - 8, 12, 1, @base_color, @shdw_color],
      [text2, (Graphics.width / 2) - 8, 44, 1, @base_color, @shdw_color],
      [text3, 248, 76, 1, @base_color, @shdw_color]
    ])
  end
end

#-------------------------------------------------------------------------------
# Pokemon Party Hud component
#-------------------------------------------------------------------------------
class VPM_PokemonPartyHud < Component
  def start_component(viewport, menu)
    super(viewport, menu)
    # Overlay stuff
    @sprites["overlay"]   = BitmapSprite.new(Graphics.width, Graphics.height / 2, @viewport)
    @sprites["overlay"].y = (Graphics.height / 2)
    @info_bar_bmp = RPG::Cache.load_bitmap(MENU_FILE_PATH, "overlay_info")
    @hp_bar_bmp   = RPG::Cache.load_bitmap(MENU_FILE_PATH, "overlay_hp")
    @exp_bar_bmp  = RPG::Cache.load_bitmap(MENU_FILE_PATH, "overlay_exp")
    @status_bmp   = RPG::Cache.load_bitmap(MENU_FILE_PATH, "overlay_status")
    @item_bmp     = RPG::Cache.load_bitmap(MENU_FILE_PATH, "overlay_item")
    @shiny_bmp    = RPG::Cache.load_bitmap(MENU_FILE_PATH, "overlay_shiny")
  end

  def should_draw?; return $player.party_count > 0; end

  def refresh
    # Iterate through all the player's Pokémon
    @sprites["overlay"].bitmap.clear
    Settings::MAX_PARTY_SIZE.times do |i|
      next if !@sprites["pokemon_#{i}"]
      @sprites["pokemon_#{i}"].dispose
      @sprites["pokemon_#{i}"] = nil
      @sprites.delete("pokemon_#{i}")
    end
    $player.party.each_with_index do |pokemon, i|
      next if !pokemon.is_a?(Pokemon)
      spacing = (Graphics.width / 8) * i
      # Pokémon Icon
      @sprites["pokemon_#{i}"] = PokemonIconSprite.new(pokemon, @viewport) if !@sprites["pokemon#{i}"] || @sprites["pokemon#{i}"].disposed?
      @sprites["pokemon_#{i}"].x = spacing + (Graphics.width / 8)
      @sprites["pokemon_#{i}"].y = Graphics.height - 164
      @sprites["pokemon_#{i}"].y += Graphics.height / 2 if @menu.hidden && !@menu.start_up
      @sprites["pokemon_#{i}"].z = -2
      next if pokemon.egg?
      # Information Overlay
      @sprites["overlay"].bitmap.blt(spacing + (Graphics.width / 8) + 16, (Graphics.height / 2) - 102,
                          @info_bar_bmp, Rect.new(0, 0, @info_bar_bmp.width, @info_bar_bmp.height))
      # Health
      if pokemon.hp > 0
        w = (pokemon.hp * 32 * 1.0) / pokemon.totalhp
        w = 1 if w < 1
        w = ((w / 2).round) * 2
        hpzone = 0
        hpzone = 1 if pokemon.hp <= (pokemon.totalhp/2).floor
        hpzone = 2 if pokemon.hp <= (pokemon.totalhp/4).floor
        hprect = Rect.new(0, hpzone * 4, w, 4)
        @sprites["overlay"].bitmap.blt(spacing + (Graphics.width/8) + 18, (Graphics.height / 2) - 100, @hp_bar_bmp, hprect)
      end
      # EXP
      if pokemon.exp > 0
        minexp = pokemon.growth_rate.minimum_exp_for_level(pokemon.level)
        currentexp = minexp-pokemon.exp
        maxexp = minexp-pokemon.growth_rate.minimum_exp_for_level(pokemon.level + 1)
        w = (currentexp * 24 * 1.0)/maxexp
        w = 1 if w < 1.0
        w = 0 if w.is_a?(Float) && w.nan?
        w = ((w / 2).round) * 2 if w > 0 # I heard Pokémon Beekeeper was good
        exprect = Rect.new(0, 0, w, 2)
        @sprites["overlay"].bitmap.blt(spacing + (Graphics.width / 8) + 22, (Graphics.height / 2) - 94, @exp_bar_bmp, exprect)
      end
      # Item Icon
      if pokemon.hasItem?
        @sprites["overlay"].bitmap.blt(spacing + (Graphics.width / 8) + 52, (Graphics.height / 2) - 116,
        @item_bmp,Rect.new(0, 0, @item_bmp.width, @item_bmp.height))
      end
      # Status
      status = 0
      if pokemon.fainted?
        status = GameData::Status.count - 1
      elsif pokemon.status != :NONE
        status = GameData::Status.get(pokemon.status).icon_position
      elsif pokemon.pokerusStage == 1
        status = GameData::Status.count
      end
      if status > 0
        statusrect = Rect.new(0, 8 * status, 8, 8)
        @sprites["overlay"].bitmap.blt(spacing + (Graphics.width/8) + 48, (Graphics.height / 2) - 106, @status_bmp, statusrect)
      end
      # Shiny Icon
      if pokemon.shiny?
        @sprites["overlay"].bitmap.blt(spacing + (Graphics.width / 8) + 52, (Graphics.height / 2) - 142,
                          @shiny_bmp,Rect.new(0, 0, @shiny_bmp.width, @shiny_bmp.height))
      end
    end
  end

  def dispose
    super
    @info_bar_bmp.dispose
    @hp_bar_bmp.dispose
    @exp_bar_bmp.dispose
    @status_bmp.dispose
    @item_bmp .dispose
    @shiny_bmp.dispose
  end
end

#-------------------------------------------------------------------------------
# Date and Time Hud component
#-------------------------------------------------------------------------------
class VPM_DateAndTimeHud < Component   
  def initialize
    @last_time = pbGetTimeNow.strftime("%I:%M %p")
  end

  def start_component(viewport, menu)
    super(viewport, menu)
    @sprites["overlay"]    = BitmapSprite.new(Graphics.width / 2, 96, viewport)
    @sprites["overlay"].ox = @sprites["overlay"].bitmap.width
    @sprites["overlay"].x  = Graphics.width
    @base_color = $PokemonSystem.from_current_menu_theme(MENU_TEXTCOLOR, Color.new(248, 248, 248))
    @shdw_color = $PokemonSystem.from_current_menu_theme(MENU_TEXTOUTLINE, Color.new(48, 48, 48))
  end

  def should_draw?; return !(pbInBugContest? || pbInSafari?); end

  def update
    super
    refresh if (pbGetTimeNow.min != @last_time) && !@menu.should_exit
  end

  def refresh
    time  = pbGetTimeNow 
    text  = _INTL("{1} {2} {3}", time.day.to_i, pbGetAbbrevMonthName(time.month.to_i), time.year.to_i)
    text2 = _INTL("{1}", time.strftime("%I:%M %p"))
    @sprites["overlay"].bitmap.clear
    pbSetSmallFont(@sprites["overlay"].bitmap)
    pbDrawTextPositions(@sprites["overlay"].bitmap,[[text, (Graphics.width / 2) - 8, 12, 1,
      @base_color, @shdw_color], [text2, (Graphics.width / 2) - 8, 34, 1, @base_color, @shdw_color]])
    @last_time = time.min
  end
end

#-------------------------------------------------------------------------------
# New Quesst Message Hud component
#-------------------------------------------------------------------------------
class VPM_NewQuestHud < Component
  def initialize
    @counter = 0
  end

  def start_component(viewport, menu)
    super(viewport, menu)
    @sprites["overlay"]    = BitmapSprite.new(Graphics.width / 2, 32, viewport)
    @sprites["overlay"].ox = @sprites["overlay"].bitmap.width
    @sprites["overlay"].x  = Graphics.width
    @sprites["overlay"].y  = 96
    @sprites["overlay"].oy = 32
    @base_color = $PokemonSystem.from_current_menu_theme(MENU_TEXTCOLOR, Color.new(248, 248, 248))
    @shdw_color = $PokemonSystem.from_current_menu_theme(MENU_TEXTOUTLINE, Color.new(48, 48, 48))
  end

  def should_draw?
    return false if !defined?(hasAnyQuests?)
    return false if !$PokemonGlobal
    return false if !$PokemonGlobal.respond_to?(:quests)
	#added by Gardenette for camping menu
    return false if $PokemonGlobal.camping
    return $PokemonGlobal.quests.active_quests.any? { |quest| quest.respond_to?(:new) && quest.new }
  end

  def update
    super
    @counter += 1
    if @counter > Graphics.frame_rate / 2
      @sprites["overlay"].y += 1 if @counter % (Graphics.frame_rate / 8) == 0
    else
      @sprites["overlay"].y -= 1 if @counter % (Graphics.frame_rate / 8) == 0
    end
    @counter = 0 if @counter >= Graphics.frame_rate
  end

  def refresh
    quest_count = $PokemonGlobal.quests.active_quests.count { |quest| quest.respond_to?(:new) && quest.new }
    @sprites["overlay"].bitmap.clear
    if quest_count > 0
      if quest_count == 1
        text = _INTL("You have {1} new quest!",quest_count)
      else
        text = _INTL("You have {1} new quests!",quest_count)
      end
      pbSetSmallFont(@sprites["overlay"].bitmap)
      pbDrawTextPositions(@sprites["overlay"].bitmap, [[text, (Graphics.width / 2) - 8, 12, 1, @base_color, @shdw_color]])
    end
  end
end

#-------------------------------------------------------------------------------
# GameSpeed Hud component
#-------------------------------------------------------------------------------
class VPM_GameSpeedHud < Component
  def initialize
    @currentGameSpeed = $GameSpeed.to_i
  end

  def start_component(viewport, menu)
    super(viewport, menu)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,viewport)
    @sprites["overlay"].ox = @sprites["overlay"].bitmap.width
    @sprites["overlay"].x = (Graphics.width)
	@sprites["overlay"].y = 0
    @base_color = $PokemonSystem.from_current_menu_theme(MENU_TEXTCOLOR, Color.new(248, 248, 248))
    @shdw_color = $PokemonSystem.from_current_menu_theme(MENU_TEXTOUTLINE, Color.new(48, 48, 48))
  end

  def should_draw?; return true; end

  def update
    super
    refresh
  end

  def refresh
    @currentGameSpeed = $GameSpeed.to_i
    if $GameSpeed > 0
		text = _INTL("{1} Speed: {2}",$PokemonSystem.game_controls.find{|c| c.control_action=="Change Game Speed"}.key_name,$GameSpeed.to_s)
    else
		text = _INTL("")
    end
    @sprites["overlay"].bitmap.clear
    pbSetSmallFont(@sprites["overlay"].bitmap)
    pbDrawTextPositions(@sprites["overlay"].bitmap,[[text,100,50,1,@base_color,@shdw_color]])
  end
end