#===============================================================================
#
#===============================================================================
class PokemonLoadPanel < Sprite
  attr_reader :selected

  TEXTCOLOR             = Color.new(232, 232, 232)
  TEXTSHADOWCOLOR       = Color.new(136, 136, 136)
  MALETEXTCOLOR         = Color.new(56, 160, 248)
  MALETEXTSHADOWCOLOR   = Color.new(56, 104, 168)
  FEMALETEXTCOLOR       = Color.new(240, 72, 88)
  FEMALETEXTSHADOWCOLOR = Color.new(160, 64, 64)

  def initialize(index, title, isContinue, trainer, framecount, stats, mapid, viewport = nil)
    super(viewport)
    @index = index
    @title = title
    @isContinue = isContinue
    @trainer = trainer
    @totalsec = (stats) ? stats.play_time.to_i : ((framecount || 0) / Graphics.frame_rate)
    @mapid = mapid
    @selected = (index == 0)
    @bgbitmap = AnimatedBitmap.new("Graphics/Pictures/Save Select/blank")
    
    @buttonbitmap = AnimatedBitmap.new("Graphics/Pictures/Save Select/button")
    @overlaysprite = BitmapSprite.new(@bgbitmap.bitmap.width, @bgbitmap.bitmap.height, viewport)
    @overlaysprite.z = self.z + 1
    if @trainer
      textpos = []
      textpos.push([_INTL("Pokédex:"), 32, 322, 0, TEXTCOLOR, TEXTSHADOWCOLOR])
      textpos.push([@trainer.pokedex.seen_count.to_s, 170, 322, 1, TEXTCOLOR, TEXTSHADOWCOLOR])
      textpos.push([_INTL("Time:"), 204, 322, 0, TEXTCOLOR, TEXTSHADOWCOLOR])
      hour = @totalsec / 60 / 60
      min  = @totalsec / 60 % 60
      if hour > 0
        textpos.push([_INTL("{1}h {2}m", hour, min), 322, 322, 1, TEXTCOLOR, TEXTSHADOWCOLOR])
      else
        textpos.push([_INTL("{1}m", min), 322, 322, 1, TEXTCOLOR, TEXTSHADOWCOLOR])
      end
      if @trainer.male?
        textpos.push([@trainer.name, 112, 96, 0, MALETEXTCOLOR, MALETEXTSHADOWCOLOR])
      else
        textpos.push([@trainer.name, 112, 96, 0, FEMALETEXTCOLOR, FEMALETEXTSHADOWCOLOR])
      end
      pbDrawTextPositions(@overlaysprite.bitmap, textpos)
      
      imagePositions = []
      x = 38
      8.times do |i|
        if trainer.badges[i]
          imagePositions.push(["Graphics/Pictures/Trainer Card/icon_badges", x, 268, i * 32, 0, 32, 32])
        end
        x += 38
      end
      pbDrawImagePositions(@overlaysprite.bitmap, imagePositions)
    end

    @refreshBitmap = true
    @refreshing = false
    refresh
  end

  def dispose
    @bgbitmap.dispose
    self.bitmap.dispose
    super
  end

  def selected=(value)
    return if @selected == value
    @selected = value
    @refreshBitmap = true
    refresh
  end

  def isContinue
    return @isContinue
  end

  def pbRefresh
    @refreshBitmap = true
    refresh
  end

  def refresh
    return if @refreshing
    return if disposed?
    @refreshing = true
    if !self.bitmap || self.bitmap.disposed?
      self.bitmap = BitmapWrapper.new(@bgbitmap.width, 222)
      pbSetSystemFont(self.bitmap)
    end
    if @refreshBitmap
      @refreshBitmap = false
      self.bitmap&.clear
      if @isContinue
        self.bitmap.blt(0, 0, @bgbitmap.bitmap, Rect.new(0,  0, @bgbitmap.width, @bgbitmap.height))
      else
        self.bitmap.blt(0, 0, @buttonbitmap.bitmap, Rect.new(0, (@selected) ? 44 : 0, @buttonbitmap.width, 44))
      end
      textpos = []
      textpos.push([@title, 32, 16, 0, TEXTCOLOR, TEXTSHADOWCOLOR]) if @isContinue
      textpos.push([@title, 18, 14, 0, TEXTCOLOR, TEXTSHADOWCOLOR]) if !@isContinue
      pbDrawTextPositions(self.bitmap, textpos)
    end
    @refreshing = false
  end
end

#===============================================================================
#
#===============================================================================
class PokemonLoad_Scene
  def pbStartScene(commands, show_continue, trainer, frame_count, stats, map_id)
  end

  def pbStartScene2
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbStartDeleteScene
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99998
    addBackgroundOrColoredPlane(@sprites, "background", "loadbg", Color.new(248, 248, 248), @viewport)
  end

  def pbUpdate
    oldi = @sprites["cmdwindow"].index rescue 0
    pbUpdateSpriteHash(@sprites)
    newi = @sprites["cmdwindow"].index rescue 0
    if oldi != newi
      @sprites["panel#{oldi}"].selected = false
      @sprites["panel#{oldi}"].pbRefresh
      @sprites["panel#{newi}"].selected = true
      @sprites["panel#{newi}"].pbRefresh
    end
  end

  def pbSetParty(trainer)
    return if !trainer || !trainer.party
    meta = GameData::PlayerMetadata.get(trainer.character_ID)
    if meta
      filename = pbGetPlayerCharset(meta.walk_charset, trainer, true)
      @sprites["player"] = TrainerWalkingCharSprite.new(filename, @viewport)
      charwidth  = @sprites["player"].bitmap.width
      charheight = @sprites["player"].bitmap.height
      @sprites["player"].x        = 58 - (charwidth / 8)
      @sprites["player"].y        = 108 - (charheight / 8)
      @sprites["player"].src_rect = Rect.new(0, 0, charwidth / 4, charheight / 4)
    end
    trainer.party.each_with_index do |pkmn, i|
      @sprites["party#{i}"] = PokemonIconSprite.new(pkmn, @viewport)
      @sprites["party#{i}"].setOffset(PictureOrigin::CENTER)
      @sprites["party#{i}"].x = 118 + (66 * (i % 3))
      @sprites["party#{i}"].y = 174 + (50 * (i / 3))
      @sprites["party#{i}"].z = 99999
    end
  end

  def pbChoose(commands)
    @sprites["cmdwindow"].commands = commands
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::USE)
        return @sprites["cmdwindow"].index
      end
    end
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbCloseScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
#
#===============================================================================
class PokemonLoadScreen
  def initialize(scene)
    @scene = scene
    if SaveData.exists?
      @save_data = load_save_file(SaveData::FILE_PATH)
    else
      @save_data = {}
    end
  end

  # @param file_path [String] file to load save data from
  # @return [Hash] save data
  def load_save_file(file_path)
    save_data = SaveData.read_from_file(file_path)
    unless SaveData.valid?(save_data)
      if File.file?(file_path + ".bak")
        pbMessage(_INTL("The save file is corrupt. A backup will be loaded."))
        save_data = load_save_file(file_path + ".bak")
      else
        self.prompt_save_deletion
        return {}
      end
    end
    return save_data
  end

  # Called if all save data is invalid.
  # Prompts the player to delete the save files.
  def prompt_save_deletion
    pbMessage(_INTL("The save file is corrupt, or is incompatible with this game."))
    exit unless pbConfirmMessageSerious(
      _INTL("Do you want to delete the save file and start anew?")
    )
    self.delete_save_data
    $game_system   = Game_System.new
    $PokemonSystem = PokemonSystem.new
  end

  def pbStartDeleteScreen
    @scene.pbStartDeleteScene
    @scene.pbStartScene2
    if SaveData.exists?
      if pbConfirmMessageSerious(_INTL("Delete all saved data?"))
        pbMessage(_INTL("Once data has been deleted, there is no way to recover it.\1"))
        if pbConfirmMessageSerious(_INTL("Delete the saved data anyway?"))
          pbMessage(_INTL("Deleting all data. Don't turn off the power.\\wtnp[0]"))
          self.delete_save_data
        end
      end
    else
      pbMessage(_INTL("No save file was found."))
    end
    @scene.pbEndScene
    $scene = pbCallTitle
  end

  def delete_save_data
    begin
      SaveData.delete_file
      pbMessage(_INTL("The saved data was deleted."))
    rescue SystemCallError
      pbMessage(_INTL("All saved data could not be deleted."))
    end
  end

  def pbStartLoadScreen
    commands = []
    cmd_continue     = -1
    cmd_new_game     = -1
    cmd_options      = -1
    cmd_language     = -1
    cmd_mystery_gift = -1
    cmd_debug        = -1
    cmd_quit         = -1
    show_continue = !@save_data.empty?
    if show_continue
      commands[cmd_continue = commands.length] = _INTL("Continue")
      if @save_data[:player].mystery_gift_unlocked
        commands[cmd_mystery_gift = commands.length] = _INTL("Mystery Gift")
      end
    end
    commands[cmd_new_game = commands.length]  = _INTL("New Game")
    commands[cmd_options = commands.length]   = _INTL("Options")
    commands[cmd_language = commands.length]  = _INTL("Language") if Settings::LANGUAGES.length >= 2
    commands[cmd_debug = commands.length]     = _INTL("Debug") if $DEBUG
    commands[cmd_quit = commands.length]      = _INTL("Quit Game")
    map_id = show_continue ? @save_data[:map_factory].map.map_id : 0
    @scene.pbStartScene(commands, show_continue, @save_data[:player],
                        @save_data[:frame_count] || 0, @save_data[:stats], map_id)
    @scene.pbSetParty(@save_data[:player]) if show_continue
    @scene.pbStartScene2
    loop do
      command = @scene.pbChoose(commands)
      pbPlayDecisionSE if command != cmd_quit
      case command
      when cmd_continue
        @scene.pbEndScene
        Game.load(@save_data)
        return
      when cmd_new_game
        @scene.pbEndScene
        Game.start_new
        return
      when cmd_mystery_gift
        pbFadeOutIn { pbDownloadMysteryGift(@save_data[:player]) }
      when cmd_options
        pbFadeOutIn do
          scene = PokemonOption_Scene.new
          screen = PokemonOptionScreen.new(scene)
          screen.pbStartScreen(true)
        end
      when cmd_language
        @scene.pbEndScene
        $PokemonSystem.language = pbChooseLanguage
        pbLoadMessages("Data/" + Settings::LANGUAGES[$PokemonSystem.language][1])
        if show_continue
          @save_data[:pokemon_system] = $PokemonSystem
          File.open(SaveData::FILE_PATH, "wb") { |file| Marshal.dump(@save_data, file) }
        end
        $scene = pbCallTitle
        return
      when cmd_debug
        pbFadeOutIn { pbDebugMenu(false) }
      when cmd_quit
        pbPlayCloseMenuSE
        @scene.pbEndScene
        $scene = nil
        return
      else
        pbPlayBuzzerSE
      end
    end
  end
end
