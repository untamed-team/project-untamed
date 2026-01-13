class TimeMachinePokemonSummary_Scene
  MARK_WIDTH  = 16
  MARK_HEIGHT = 16
	
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(party, partyindex, inbattle = false)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @party      = party
    @partyindex = partyindex
    @pokemon    = @party[@partyindex]
    @inbattle   = inbattle
    @page = 1
    @typebitmap    = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    @markingbitmap = AnimatedBitmap.new("Graphics/Pictures/Summary/markings")
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["pokemon"] = PokemonSprite.new(@viewport)
    @sprites["pokemon"].setOffset(PictureOrigin::CENTER)
    @sprites["pokemon"].x = 104
    @sprites["pokemon"].y = 206
    @sprites["pokemon"].setPokemonBitmap(@pokemon)
    @sprites["pokeicon"] = PokemonIconSprite.new(@pokemon, @viewport)
    @sprites["pokeicon"].setOffset(PictureOrigin::CENTER)
    @sprites["pokeicon"].x       = 46
    @sprites["pokeicon"].y       = 92
    @sprites["pokeicon"].visible = false
    @sprites["itemicon"] = ItemIconSprite.new(30, 320, @pokemon.item_id, @viewport)
    @sprites["itemicon"].blankzero = true
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["movepresel"] = MoveSelectionSprite.new(@viewport)
    @sprites["movepresel"].visible     = false
    @sprites["movepresel"].preselected = true
    @sprites["movesel"] = MoveSelectionSprite.new(@viewport)
    @sprites["movesel"].visible = false
    @sprites["ribbonpresel"] = RibbonSelectionSprite.new(@viewport)
    @sprites["ribbonpresel"].visible     = false
    @sprites["ribbonpresel"].preselected = true
    @sprites["ribbonsel"] = RibbonSelectionSprite.new(@viewport)
    @sprites["ribbonsel"].visible = false
    @sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow", 8, 28, 40, 2, @viewport)
    @sprites["uparrow"].x = 350
    @sprites["uparrow"].y = 56
    @sprites["uparrow"].play
    @sprites["uparrow"].visible = false
    @sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow", 8, 28, 40, 2, @viewport)
    @sprites["downarrow"].x = 350
    @sprites["downarrow"].y = 260
    @sprites["downarrow"].play
    @sprites["downarrow"].visible = false
    @sprites["markingbg"] = IconSprite.new(260, 88, @viewport)
    @sprites["markingbg"].setBitmap("Graphics/Pictures/Summary/overlay_marking")
    @sprites["markingbg"].visible = false
    @sprites["markingoverlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["markingoverlay"].visible = false
    pbSetSystemFont(@sprites["markingoverlay"].bitmap)
    @sprites["markingsel"] = IconSprite.new(0, 0, @viewport)
    @sprites["markingsel"].setBitmap("Graphics/Pictures/Summary/cursor_marking")
    @sprites["markingsel"].src_rect.height = @sprites["markingsel"].bitmap.height / 2
    @sprites["markingsel"].visible = false
    @sprites["messagebox"] = Window_AdvancedTextPokemon.new("")
    @sprites["messagebox"].viewport       = @viewport
    @sprites["messagebox"].visible        = false
    @sprites["messagebox"].letterbyletter = true
    pbBottomLeftLines(@sprites["messagebox"], 2)
    @nationalDexList = [:NONE]
    GameData::Species.each_species { |s| @nationalDexList.push(s.species) }
    drawPage(@page)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbStartForgetScene(party, partyindex, move_to_learn)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @party      = party
    @partyindex = partyindex
    @pokemon    = @party[@partyindex]
    @page = 4
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["pokeicon"] = PokemonIconSprite.new(@pokemon, @viewport)
    @sprites["pokeicon"].setOffset(PictureOrigin::CENTER)
    @sprites["pokeicon"].x       = 46
    @sprites["pokeicon"].y       = 92
    @sprites["movesel"] = MoveSelectionSprite.new(@viewport, !move_to_learn.nil?)
    @sprites["movesel"].visible = false
    @sprites["movesel"].visible = true
    @sprites["movesel"].index   = 0
    new_move = (move_to_learn) ? Pokemon::Move.new(move_to_learn) : nil
    drawSelectedMove(new_move, @pokemon.moves[0])
    pbFadeInAndShow(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @typebitmap.dispose
    @markingbitmap&.dispose
    @viewport.dispose
  end

  def pbDisplay(text)
    @sprites["messagebox"].text = text
    @sprites["messagebox"].visible = true
    pbPlayDecisionSE
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if @sprites["messagebox"].busy?
        if Input.trigger?(Input::USE)
          pbPlayDecisionSE if @sprites["messagebox"].pausing?
          @sprites["messagebox"].resume
        end
      elsif Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
        break
      end
    end
    @sprites["messagebox"].visible = false
  end

  def pbConfirm(text)
    ret = -1
    @sprites["messagebox"].text    = text
    @sprites["messagebox"].visible = true
    using(cmdwindow = Window_CommandPokemon.new([_INTL("Yes"), _INTL("No")])) {
      cmdwindow.z       = @viewport.z + 1
      cmdwindow.visible = false
      pbBottomRight(cmdwindow)
      cmdwindow.y -= @sprites["messagebox"].height
      loop do
        Graphics.update
        Input.update
        cmdwindow.visible = true if !@sprites["messagebox"].busy?
        cmdwindow.update
        pbUpdate
        if !@sprites["messagebox"].busy?
          if Input.trigger?(Input::BACK)
            ret = false
            break
          elsif Input.trigger?(Input::USE) && @sprites["messagebox"].resume
            ret = (cmdwindow.index == 0)
            break
          end
        end
      end
    }
    @sprites["messagebox"].visible = false
    return ret
  end

  def pbShowCommands(commands, index = 0)
    ret = -1
    using(cmdwindow = Window_CommandPokemon.new(commands)) {
      cmdwindow.z = @viewport.z + 1
      cmdwindow.index = index
      pbBottomRight(cmdwindow)
      loop do
        Graphics.update
        Input.update
        cmdwindow.update
        pbUpdate
        if Input.trigger?(Input::BACK)
          pbPlayCancelSE
          ret = -1
          break
        elsif Input.trigger?(Input::USE)
          pbPlayDecisionSE
          ret = cmdwindow.index
          break
        end
      end
    }
    return ret
  end

  def drawMarkings(bitmap, x, y)
    mark_variants = @markingbitmap.bitmap.height / MARK_HEIGHT
    markings = @pokemon.markings
    markrect = Rect.new(0, 0, MARK_WIDTH, MARK_HEIGHT)
    (@markingbitmap.bitmap.width / MARK_WIDTH).times do |i|
      markrect.x = i * MARK_WIDTH
      markrect.y = [(markings[i] || 0), mark_variants - 1].min * MARK_HEIGHT
      bitmap.blt(x + (i * MARK_WIDTH), y, @markingbitmap.bitmap, markrect)
    end
  end

  def drawPage(page)
    if @pokemon.egg?
      drawPageOneEgg
      return
    end
    @sprites["itemicon"].item = @pokemon.item_id
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(248, 248, 248)
    shadow = Color.new(104, 104, 104)
    # Set background image
    @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_#{page}")
    imagepos = []
    # Show the Poké Ball containing the Pokémon
    ballimage = sprintf("Graphics/Pictures/Summary/icon_ball_%s", @pokemon.poke_ball)
    imagepos.push([ballimage, 14, 60])
    # Show status/fainted/Pokérus infected icon
    status = -1
    if @pokemon.fainted?
      status = GameData::Status.count - 1
    elsif @pokemon.status != :NONE
      status = GameData::Status.get(@pokemon.status).icon_position
    elsif @pokemon.pokerusStage == 1
      status = GameData::Status.count
    end
    if status >= 0
      imagepos.push(["Graphics/Pictures/statuses", 124, 100, 0, 16 * status, 44, 16])
    end
    # Show Pokérus cured icon
    if @pokemon.pokerusStage == 2
      imagepos.push([sprintf("Graphics/Pictures/Summary/icon_pokerus"), 176, 100])
    end
    # Show shininess star
    if @pokemon.shiny?
      imagepos.push([sprintf("Graphics/Pictures/shiny"), 2, 134])
    end
    # Draw all images
    pbDrawImagePositions(overlay, imagepos)
    # Write various bits of text
    pagename = [_INTL("INFO"),
                _INTL("TRAINER MEMO"),
                _INTL("SKILLS"),
                _INTL("MOVES"),
                _INTL("RIBBONS")][page - 1]
    textpos = [
      [pagename, 26, 22, 0, base, shadow],
      [@pokemon.name, 46, 68, 0, base, shadow],
      [@pokemon.level.to_s, 46, 98, 0, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL("Item"), 66, 324, 0, base, shadow]
    ]
    # Write the held item's name
    if @pokemon.hasItem?
      textpos.push([@pokemon.item.name, 16, 358, 0, Color.new(64, 64, 64), Color.new(176, 176, 176)])
    else
      textpos.push([_INTL("None"), 16, 358, 0, Color.new(192, 200, 208), Color.new(208, 216, 224)])
    end
    # Write the gender symbol
    if @pokemon.male?
      textpos.push([_INTL("♂"), 178, 68, 0, Color.new(24, 112, 216), Color.new(136, 168, 208)])
    elsif @pokemon.female?
      textpos.push([_INTL("♀"), 178, 68, 0, Color.new(248, 56, 32), Color.new(224, 152, 144)])
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Draw the Pokémon's markings
    drawMarkings(overlay, 84, 292)
    # Draw page-specific information
    case page
    when 1 then drawPageOne
    when 2 then drawPageTwo
    when 3 then drawPageThree
    when 4 then drawPageFour
    when 5 then drawPageFive
    end
  end

  def drawPageOne
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(248, 248, 248)
    shadow = Color.new(104, 104, 104)
    dexNumBase   = (@pokemon.shiny?) ? Color.new(248, 56, 32) : Color.new(64, 64, 64)
    dexNumShadow = (@pokemon.shiny?) ? Color.new(224, 152, 144) : Color.new(176, 176, 176)
    # If a Shadow Pokémon, draw the heart gauge area and bar
    if @pokemon.shadowPokemon?
      shadowfract = @pokemon.heart_gauge.to_f / @pokemon.max_gauge_size
      imagepos = [
        ["Graphics/Pictures/Summary/overlay_shadow", 224, 240],
        ["Graphics/Pictures/Summary/overlay_shadowbar", 242, 280, 0, 0, (shadowfract * 248).floor, -1]
      ]
      pbDrawImagePositions(overlay, imagepos)
    end
    # Write various bits of text
    textpos = [
      [_INTL("Dex No."), 238, 86, 0, base, shadow],
      [_INTL("Species"), 238, 118, 0, base, shadow],
      [@pokemon.speciesName, 435, 118, 2, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL("Type"), 238, 150, 0, base, shadow],
      [_INTL("OT"), 238, 182, 0, base, shadow],
      [_INTL("ID No."), 238, 214, 0, base, shadow]
    ]
    # Write the Regional/National Dex number
    dexnum = 0
    dexnumshift = false
    if $player.pokedex.unlocked?(-1)   # National Dex is unlocked
      dexnum = @nationalDexList.index(@pokemon.species_data.species) || 0
      dexnumshift = true if Settings::DEXES_WITH_OFFSETS.include?(-1)
    else
      ($player.pokedex.dexes_count - 1).times do |i|
        next if !$player.pokedex.unlocked?(i)
        num = pbGetRegionalNumber(i, @pokemon.species)
        next if num <= 0
        dexnum = num
        dexnumshift = true if Settings::DEXES_WITH_OFFSETS.include?(i)
        break
      end
    end
    if dexnum <= 0
      textpos.push(["???", 435, 86, 2, dexNumBase, dexNumShadow])
    else
      dexnum -= 1 if dexnumshift
      textpos.push([sprintf("%03d", dexnum), 435, 86, 2, dexNumBase, dexNumShadow])
    end
    # Write Original Trainer's name and ID number
    if @pokemon.owner.name.empty?
      textpos.push([_INTL("RENTAL"), 435, 182, 2, Color.new(64, 64, 64), Color.new(176, 176, 176)])
      textpos.push(["?????", 435, 214, 2, Color.new(64, 64, 64), Color.new(176, 176, 176)])
    else
      ownerbase   = Color.new(64, 64, 64)
      ownershadow = Color.new(176, 176, 176)
      case @pokemon.owner.gender
      when 0
        ownerbase = Color.new(24, 112, 216)
        ownershadow = Color.new(136, 168, 208)
      when 1
        ownerbase = Color.new(248, 56, 32)
        ownershadow = Color.new(224, 152, 144)
      end
      textpos.push([@pokemon.owner.name, 435, 182, 2, ownerbase, ownershadow])
      textpos.push([sprintf("%05d", @pokemon.owner.public_id), 435, 214, 2,
                    Color.new(64, 64, 64), Color.new(176, 176, 176)])
    end
    # Write Exp text OR heart gauge message (if a Shadow Pokémon)
    if @pokemon.shadowPokemon?
      textpos.push([_INTL("Heart Gauge"), 238, 246, 0, base, shadow])
      heartmessage = [_INTL("The door to its heart is open! Undo the final lock!"),
                      _INTL("The door to its heart is almost fully open."),
                      _INTL("The door to its heart is nearly open."),
                      _INTL("The door to its heart is opening wider."),
                      _INTL("The door to its heart is opening up."),
                      _INTL("The door to its heart is tightly shut.")][@pokemon.heartStage]
      memo = sprintf("<c3=404040,B0B0B0>%s\n", heartmessage)
      drawFormattedTextEx(overlay, 234, 308, 264, memo)
    else
      endexp = @pokemon.growth_rate.minimum_exp_for_level(@pokemon.level + 1)
      textpos.push([_INTL("Exp. Points"), 238, 246, 0, base, shadow])
      textpos.push([@pokemon.exp.to_s_formatted, 488, 278, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)])
      textpos.push([_INTL("To Next Lv."), 238, 310, 0, base, shadow])
      textpos.push([(endexp - @pokemon.exp).to_s_formatted, 488, 342, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)])
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Draw Pokémon type(s) 
		#pageone summary #triple type UI #by low
    @pokemon.types.each_with_index do |type, i|
      type_number = GameData::Type.get(type).icon_position
			type_rect = Rect.new(0, type_number * 28, 64, 28)
			case @pokemon.types.length
				when 2
					type_x = 370 + (66 * i)
				when 3
					type_x = 334 + (60 * i)
				else
					type_x = 402
			end
			overlay.blt(type_x, 146, @typebitmap.bitmap, type_rect)
    end
    # Draw Exp bar
    if @pokemon.level < GameData::GrowthRate.max_level
      w = @pokemon.exp_fraction * 128
      w = ((w / 2).round) * 2
      pbDrawImagePositions(overlay,
                           [["Graphics/Pictures/Summary/overlay_exp", 362, 372, 0, 0, w, 6]])
    end
  end

  def drawPageOneEgg
    @sprites["itemicon"].item = @pokemon.item_id
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(248, 248, 248)
    shadow = Color.new(104, 104, 104)
    # Set background image
    @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_egg")
    imagepos = []
    # Show the Poké Ball containing the Pokémon
    ballimage = sprintf("Graphics/Pictures/Summary/icon_ball_%s", @pokemon.poke_ball)
    imagepos.push([ballimage, 14, 60])
    # Draw all images
    pbDrawImagePositions(overlay, imagepos)
    # Write various bits of text
    textpos = [
      [_INTL("TRAINER MEMO"), 26, 22, 0, base, shadow],
      [@pokemon.name, 46, 68, 0, base, shadow],
      [_INTL("Item"), 66, 324, 0, base, shadow]
    ]
    # Write the held item's name
    if @pokemon.hasItem?
      textpos.push([@pokemon.item.name, 16, 358, 0, Color.new(64, 64, 64), Color.new(176, 176, 176)])
    else
      textpos.push([_INTL("None"), 16, 358, 0, Color.new(192, 200, 208), Color.new(208, 216, 224)])
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    memo = ""
    # Write date received
    if @pokemon.timeReceived
      date  = @pokemon.timeReceived.day
      month = pbGetMonthName(@pokemon.timeReceived.mon)
      year  = @pokemon.timeReceived.year
      memo += _INTL("<c3=404040,B0B0B0>{1} {2}, {3}\n", date, month, year)
    end
    # Write map name egg was received on
    mapname = pbGetMapNameFromId(@pokemon.obtain_map)
    mapname = @pokemon.obtain_text if @pokemon.obtain_text && !@pokemon.obtain_text.empty?
    if mapname && mapname != ""
      memo += _INTL("<c3=404040,B0B0B0>A mysterious Pokémon Egg received from <c3=F83820,E09890>{1}<c3=404040,B0B0B0>.\n", mapname)
    else
      memo += _INTL("<c3=404040,B0B0B0>A mysterious Pokémon Egg.\n", mapname)
    end
    memo += "\n" # Empty line
    # Write Egg Watch blurb
    memo += _INTL("<c3=404040,B0B0B0>\"The Egg Watch\"\n")
    eggstate = _INTL("It looks like this Egg will take a long time to hatch.")
    eggstate = _INTL("What will hatch from this? It doesn't seem close to hatching.") if @pokemon.steps_to_hatch < 10_200
    eggstate = _INTL("It appears to move occasionally. It may be close to hatching.") if @pokemon.steps_to_hatch < 2550
    eggstate = _INTL("Sounds can be heard coming from inside! It will hatch soon!") if @pokemon.steps_to_hatch < 1275
    memo += sprintf("<c3=404040,B0B0B0>%s\n", eggstate)
    # Draw all text
    drawFormattedTextEx(overlay, 232, 86, 268, memo)
    # Draw the Pokémon's markings
    drawMarkings(overlay, 84, 292)
  end

  def drawPageTwo
    overlay = @sprites["overlay"].bitmap
    memo = ""
    # Write nature
    showNature = !@pokemon.shadowPokemon? || @pokemon.heartStage <= 3
    if showNature
      natureName = @pokemon.nature.name
      memo += _INTL("<c3=F83820,E09890>{1}<c3=404040,B0B0B0> nature.\n", natureName)
    end
    # Write date received
    if @pokemon.timeReceived
      date  = @pokemon.timeReceived.day
      month = pbGetMonthName(@pokemon.timeReceived.mon)
      year  = @pokemon.timeReceived.year
      memo += _INTL("<c3=404040,B0B0B0>{1} {2}, {3}\n", date, month, year)
    end
    # Write map name Pokémon was received on
    mapname = pbGetMapNameFromId(@pokemon.obtain_map)
    mapname = @pokemon.obtain_text if @pokemon.obtain_text && !@pokemon.obtain_text.empty?
    mapname = _INTL("Faraway place") if nil_or_empty?(mapname)
    memo += sprintf("<c3=F83820,E09890>%s\n", mapname)
    # Write how Pokémon was obtained
    mettext = [_INTL("Met at Lv. {1}.", @pokemon.obtain_level),
               _INTL("Egg received."),
               _INTL("Traded at Lv. {1}.", @pokemon.obtain_level),
               "",
               _INTL("Had a fateful encounter at Lv. {1}.", @pokemon.obtain_level)][@pokemon.obtain_method]
    memo += sprintf("<c3=404040,B0B0B0>%s\n", mettext) if mettext && mettext != ""
    # If Pokémon was hatched, write when and where it hatched
    if @pokemon.obtain_method == 1
      if @pokemon.timeEggHatched
        date  = @pokemon.timeEggHatched.day
        month = pbGetMonthName(@pokemon.timeEggHatched.mon)
        year  = @pokemon.timeEggHatched.year
        memo += _INTL("<c3=404040,B0B0B0>{1} {2}, {3}\n", date, month, year)
      end
      mapname = pbGetMapNameFromId(@pokemon.hatched_map)
      mapname = _INTL("Faraway place") if nil_or_empty?(mapname)
      memo += sprintf("<c3=F83820,E09890>%s\n", mapname)
      memo += _INTL("<c3=404040,B0B0B0>Egg hatched.\n")
    else
      memo += "\n"   # Empty line
    end
    # Write characteristic
    if showNature
      best_stat = nil
      best_iv = 0
      stats_order = [:HP, :ATTACK, :DEFENSE, :SPEED, :SPECIAL_ATTACK, :SPECIAL_DEFENSE]
      start_point = @pokemon.personalID % stats_order.length   # Tiebreaker
      stats_order.length.times do |i|
        stat = stats_order[(i + start_point) % stats_order.length]
        if !best_stat || @pokemon.iv[stat] > @pokemon.iv[best_stat]
          best_stat = stat
          best_iv = @pokemon.iv[best_stat]
        end
      end
      characteristics = {
        :HP              => [_INTL("Loves to eat."),
                             _INTL("Takes plenty of siestas."),
                             _INTL("Nods off a lot."),
                             _INTL("Scatters things often."),
                             _INTL("Likes to relax.")],
        :ATTACK          => [_INTL("Proud of its power."),
                             _INTL("Likes to thrash about."),
                             _INTL("A little quick tempered."),
                             _INTL("Likes to fight."),
                             _INTL("Quick tempered.")],
        :DEFENSE         => [_INTL("Sturdy body."),
                             _INTL("Capable of taking hits."),
                             _INTL("Highly persistent."),
                             _INTL("Good endurance."),
                             _INTL("Good perseverance.")],
        :SPECIAL_ATTACK  => [_INTL("Highly curious."),
                             _INTL("Mischievous."),
                             _INTL("Thoroughly cunning."),
                             _INTL("Often lost in thought."),
                             _INTL("Very finicky.")],
        :SPECIAL_DEFENSE => [_INTL("Strong willed."),
                             _INTL("Somewhat vain."),
                             _INTL("Strongly defiant."),
                             _INTL("Hates to lose."),
                             _INTL("Somewhat stubborn.")],
        :SPEED           => [_INTL("Likes to run."),
                             _INTL("Alert to sounds."),
                             _INTL("Impetuous and silly."),
                             _INTL("Somewhat of a clown."),
                             _INTL("Quick to flee.")]
      }
      memo += sprintf("<c3=404040,B0B0B0>%s\n", characteristics[best_stat][best_iv % 5])
    end
    # Write all text
    drawFormattedTextEx(overlay, 232, 86, 268, memo)
  end

  def drawPageThree #overhauled #by low
		overlay = @sprites["overlay"].bitmap
		base   = Color.new(248, 248, 248)
		shadow = Color.new(104, 104, 104)
		# Determine which stats are boosted and lowered by the Pokémon's nature
		statshadows = {}
		GameData::Stat.each_main { |s| statshadows[s.id] = shadow }
		if !@pokemon.shadowPokemon? || @pokemon.heartStage <= 3
			@pokemon.nature_for_stats.stat_changes.each do |change|
			statshadows[change[0]] = Color.new(255, 0, 0) if change[1] > 0
			statshadows[change[0]] = Color.new(0, 148, 255) if change[1] < 0
			end
		end
    base_stats = @pokemon.baseStats
    stats = {}
    GameData::Stat.each_main do |s|
      stats[s.id] = base_stats[s.id]
    end
		# Write various bits of text		
		if Settings::PURIST_MODE
			spatk=:SPECIAL_ATTACK
		else
			spatk=:ATTACK
		end
    # Write various bits of text
    textpos = [
      [_INTL("HP"), 250, 82, 2, base, statshadows[:HP]],
      [sprintf("%d/%d", @pokemon.hp, @pokemon.totalhp), 442, 82, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
			[sprintf("%d", stats[:HP]), 496, 83, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL("Attack"), 238, 126, 0, base, statshadows[:ATTACK]],
      [sprintf("%d", @pokemon.attack), 436, 126, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
			[sprintf("%d", stats[:ATTACK]), 496, 127, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL("Defense"), 238, 158, 0, base, statshadows[:DEFENSE]],
      [sprintf("%d", @pokemon.defense),436, 158, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
			[sprintf("%d", stats[:DEFENSE]), 496, 159, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL("Sp. Atk"), 238, 190, 0, base, statshadows[:SPECIAL_ATTACK]],
      [sprintf("%d", @pokemon.spatk), 436, 190, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
			[sprintf("%d", stats[:SPECIAL_ATTACK]), 496, 191, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL("Sp. Def"), 238, 222, 0, base, statshadows[:SPECIAL_DEFENSE]],
      [sprintf("%d", @pokemon.spdef), 436, 222, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
			[sprintf("%d", stats[:SPECIAL_DEFENSE]), 496, 223, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL("Speed"), 238, 254, 0, base, statshadows[:SPEED]],
      [sprintf("%d", @pokemon.speed), 436, 254, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
			[sprintf("%d", stats[:SPEED]), 496, 255, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)]
    ]
		#DemICE adding the unused EVs
		totalevs=80+@pokemon.level*8
		totalevs=(totalevs.div(4))*4      
		totalevs=512 if totalevs>512        
		evpool=totalevs-@pokemon.ev[:HP]-@pokemon.ev[:ATTACK]-@pokemon.ev[:DEFENSE]-@pokemon.ev[:SPECIAL_DEFENSE]-@pokemon.ev[:SPEED]
		evpool-=@pokemon.ev[:SPECIAL_ATTACK] if Settings::PURIST_MODE  
		
		#DemICE adding ev allocation instructions
		if $evalloc
			textpos.push(
				[sprintf("%d", @pokemon.ev[:HP]), 348, 82, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
				[sprintf("%d", @pokemon.ev[:ATTACK]), 374, 127, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
				[sprintf("%d", @pokemon.ev[:DEFENSE]), 374, 159, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
				[sprintf("%d", @pokemon.ev[spatk]), 374, 191, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
				[sprintf("%d", @pokemon.ev[:SPECIAL_DEFENSE]), 374, 223, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
				[sprintf("%d", @pokemon.ev[:SPEED]), 374, 255, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)]
			)
			textpos.push(["EV Pool:",224,290,0,base, shadow])
			textpos.push([sprintf("%d", evpool), 344, 290, 1, base, shadow])
			textpos.push(["[S] resets EVs",362,290,0,Color.new(64,64,64),Color.new(176,176,176)])
			drawTextEx(overlay,224,322,282,2,"When EV is 0:     [<-] to max.  When EV is max: [->] to 0.",Color.new(64,64,64),Color.new(176,176,176))
		else
			# Draw ability name and description
			textpos.push([_INTL("Ability"), 224, 290, 0, base, shadow])
			ability = @pokemon.ability
			if ability
				textpos.push([ability.name, 362, 290, 0, Color.new(64, 64, 64), Color.new(176, 176, 176)])
				#abilitydesc = _INTL("Press {1} to view ability description.",$PokemonSystem.game_controls.find{|c| c.control_action=="Registered Item"}.key_name)
				abilitydesc = @pokemon.ability.description
        drawTextEx(overlay,224,320,282+12,2,abilitydesc,Color.new(64,64,64),Color.new(176,176,176))
			end
		end	
		
		# Draw all text
		pbDrawTextPositions(overlay, textpos)
		# Draw HP bar
		if @pokemon.hp > 0	
			w = @pokemon.hp * 96 / @pokemon.totalhp.to_f	
			w = 1 if w < 1	
			w = ((w / 2).round) * 2	
			hpzone = 0	
			hpzone = 1 if @pokemon.hp <= (@pokemon.totalhp / 2).floor	
			hpzone = 2 if @pokemon.hp <= (@pokemon.totalhp / 4).floor	
			imagepos = [["Graphics/Pictures/Summary/overlay_hp", 339, 111, 0, hpzone * 6, w, 6]]	
			pbDrawImagePositions(overlay, imagepos)
		end
	end

  def drawPageFour
    overlay = @sprites["overlay"].bitmap
    moveBase   = Color.new(64, 64, 64)
    moveShadow = Color.new(176, 176, 176)
    ppBase   = [moveBase,                # More than 1/2 of total PP
                Color.new(248, 192, 0),    # 1/2 of total PP or less
                Color.new(248, 136, 32),   # 1/4 of total PP or less
                Color.new(248, 72, 72)]    # Zero PP
    ppShadow = [moveShadow,             # More than 1/2 of total PP
                Color.new(144, 104, 0),   # 1/2 of total PP or less
                Color.new(144, 72, 24),   # 1/4 of total PP or less
                Color.new(136, 48, 48)]   # Zero PP
    @sprites["pokemon"].visible  = true
    @sprites["pokeicon"].visible = false
    @sprites["itemicon"].visible = true
    textpos  = []
    imagepos = []
    # Write move names, types and PP amounts for each known move
    yPos = 104
    Pokemon::MAX_MOVES.times do |i|
      move = @pokemon.moves[i]
      if move
        type_number = GameData::Type.get(move.display_type(@pokemon)).icon_position
        imagepos.push(["Graphics/Pictures/types", 248, yPos - 4, 0, type_number * 28, 64, 28])
        textpos.push([move.name, 316, yPos, 0, moveBase, moveShadow])
        if move.total_pp > 0
          textpos.push([_INTL("PP"), 342, yPos + 32, 0, moveBase, moveShadow])
          ppfraction = 0
          if move.pp == 0
            ppfraction = 3
          elsif move.pp * 4 <= move.total_pp
            ppfraction = 2
          elsif move.pp * 2 <= move.total_pp
            ppfraction = 1
          end
          textpos.push([sprintf("%d/%d", move.pp, move.total_pp), 460, yPos + 32, 1, ppBase[ppfraction], ppShadow[ppfraction]])
        end
      else
        textpos.push(["-", 316, yPos, 0, moveBase, moveShadow])
        textpos.push(["--", 442, yPos + 32, 1, moveBase, moveShadow])
      end
      yPos += 64
    end
    # Draw all text and images
    pbDrawTextPositions(overlay, textpos)
    pbDrawImagePositions(overlay, imagepos)
  end

  def drawPageFourSelecting(move_to_learn)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(248, 248, 248)
    shadow = Color.new(104, 104, 104)
    moveBase   = Color.new(64, 64, 64)
    moveShadow = Color.new(176, 176, 176)
    ppBase   = [moveBase,                # More than 1/2 of total PP
                Color.new(248, 192, 0),    # 1/2 of total PP or less
                Color.new(248, 136, 32),   # 1/4 of total PP or less
                Color.new(248, 72, 72)]    # Zero PP
    ppShadow = [moveShadow,             # More than 1/2 of total PP
                Color.new(144, 104, 0),   # 1/2 of total PP or less
                Color.new(144, 72, 24),   # 1/4 of total PP or less
                Color.new(136, 48, 48)]   # Zero PP
    # Set background image
    if move_to_learn
      @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_learnmove")
    else
      @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_movedetail")
    end
    # Write various bits of text
    textpos = [
      [_INTL("MOVES"), 26, 22, 0, base, shadow],
      [_INTL("CATEGORY"), 20, 128, 0, base, shadow],
      [_INTL("POWER"), 20, 160, 0, base, shadow],
      [_INTL("ACCURACY"), 20, 192, 0, base, shadow]
    ]
    imagepos = []
    # Write move names, types and PP amounts for each known move
    yPos = 104
    yPos -= 76 if move_to_learn
    limit = (move_to_learn) ? Pokemon::MAX_MOVES + 1 : Pokemon::MAX_MOVES
    limit.times do |i|
      move = @pokemon.moves[i]
      if i == Pokemon::MAX_MOVES
        move = move_to_learn
        yPos += 20
      end
      if move
        type_number = GameData::Type.get(move.display_type(@pokemon)).icon_position
        imagepos.push(["Graphics/Pictures/types", 248, yPos - 4, 0, type_number * 28, 64, 28])
        textpos.push([move.name, 316, yPos, 0, moveBase, moveShadow])
        if move.total_pp > 0
          textpos.push([_INTL("PP"), 342, yPos + 32, 0, moveBase, moveShadow])
          ppfraction = 0
          if move.pp == 0
            ppfraction = 3
          elsif move.pp * 4 <= move.total_pp
            ppfraction = 2
          elsif move.pp * 2 <= move.total_pp
            ppfraction = 1
          end
          textpos.push([sprintf("%d/%d", move.pp, move.total_pp), 460, yPos + 32, 1, ppBase[ppfraction], ppShadow[ppfraction]])
        end
      else
        textpos.push(["-", 316, yPos, 0, moveBase, moveShadow])
        textpos.push(["--", 442, yPos + 32, 1, moveBase, moveShadow])
      end
      yPos += 64
    end
    # Draw all text and images
    pbDrawTextPositions(overlay, textpos)
    pbDrawImagePositions(overlay, imagepos)
    # Draw Pokémon's type icon(s) 
		#pagefour summary #triple type UI #by low
    @pokemon.types.each_with_index do |type, i|
      type_number = GameData::Type.get(type).icon_position
			type_rect = Rect.new(0, type_number * 28, 64, 28)
			case @pokemon.types.length
				when 2
					type_x = 96 + (70 * i)
					type_y = 78
				when 3
					type_x = (i == 2) ? 132 : 96 + (70 * i)
					type_y = (i == 2) ? 88 : 68
				else
					type_x = 132
					type_y = 78
			end
			overlay.blt(type_x, type_y, @typebitmap.bitmap, type_rect)
    end
  end

  def drawSelectedMove(move_to_learn, selected_move)
    # Draw all of page four, except selected move's details
    drawPageFourSelecting(move_to_learn)
    # Set various values
    overlay = @sprites["overlay"].bitmap
    base = Color.new(64, 64, 64)
    shadow = Color.new(176, 176, 176)
    @sprites["pokemon"].visible = false if @sprites["pokemon"]
    @sprites["pokeicon"].pokemon = @pokemon
    @sprites["pokeicon"].visible = true
    @sprites["itemicon"].visible = false if @sprites["itemicon"]
    textpos = []
    # Write power and accuracy values for selected move
    case selected_move.display_damage(@pokemon)
    when 0 then textpos.push(["---", 216, 160, 1, base, shadow])   # Status move
    when 1 then textpos.push(["???", 216, 160, 1, base, shadow])   # Variable power move
    else        textpos.push([selected_move.display_damage(@pokemon).to_s, 216, 160, 1, base, shadow])
    end
    if selected_move.display_accuracy(@pokemon) == 0
      textpos.push(["---", 216, 192, 1, base, shadow])
    else
      textpos.push(["#{selected_move.display_accuracy(@pokemon)}%", 216 + overlay.text_size("%").width, 192, 1, base, shadow])
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Draw selected move's damage category icon
    imagepos = [["Graphics/Pictures/category", 166, 124, 0, selected_move.display_category(@pokemon) * 28, 64, 28]]
    pbDrawImagePositions(overlay, imagepos)
    # Draw selected move's description
    drawTextEx(overlay, 4, 224, 230, 5, selected_move.description, base, shadow)
  end

  def drawPageFive
    overlay = @sprites["overlay"].bitmap
    @sprites["uparrow"].visible   = false
    @sprites["downarrow"].visible = false
    # Write various bits of text
    textpos = [
      [_INTL("No. of Ribbons:"), 234, 338, 0, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [@pokemon.numRibbons.to_s, 450, 338, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)]
    ]
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Show all ribbons
    imagepos = []
    coord = 0
    (@ribbonOffset * 4...(@ribbonOffset * 4) + 12).each do |i|
      break if !@pokemon.ribbons[i]
      ribbon_data = GameData::Ribbon.get(@pokemon.ribbons[i])
      ribn = ribbon_data.icon_position
      imagepos.push(["Graphics/Pictures/ribbons",
                     230 + (68 * (coord % 4)), 78 + (68 * (coord / 4).floor),
                     64 * (ribn % 8), 64 * (ribn / 8).floor, 64, 64])
      coord += 1
    end
    # Draw all images
    pbDrawImagePositions(overlay, imagepos)
  end

  def drawSelectedRibbon(ribbonid)
    # Draw all of page five
    drawPage(5)
    # Set various values
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(64, 64, 64)
    shadow = Color.new(176, 176, 176)
    nameBase   = Color.new(248, 248, 248)
    nameShadow = Color.new(104, 104, 104)
    # Get data for selected ribbon
    name = ribbonid ? GameData::Ribbon.get(ribbonid).name : ""
    desc = ribbonid ? GameData::Ribbon.get(ribbonid).description : ""
    # Draw the description box
    imagepos = [
      ["Graphics/Pictures/Summary/overlay_ribbon", 8, 280]
    ]
    pbDrawImagePositions(overlay, imagepos)
    # Draw name of selected ribbon
    textpos = [
      [name, 18, 292, 0, nameBase, nameShadow]
    ]
    pbDrawTextPositions(overlay, textpos)
    # Draw selected ribbon's description
    drawTextEx(overlay, 18, 324, 480, 2, desc, base, shadow)
  end

  def pbGoToPrevious
    newindex = @partyindex
    while newindex > 0
      newindex -= 1
      if @party[newindex] && (@page == 1 || !@party[newindex].egg?)
        @partyindex = newindex
        break
      end
    end
  end

  def pbGoToNext
    newindex = @partyindex
    while newindex < @party.length - 1
      newindex += 1
      if @party[newindex] && (@page == 1 || !@party[newindex].egg?)
        @partyindex = newindex
        break
      end
    end
  end

  def pbChangePokemon
    @pokemon = @party[@partyindex]
    @sprites["pokemon"].setPokemonBitmap(@pokemon)
    @sprites["itemicon"].item = @pokemon.item_id
    pbSEStop
    @pokemon.play_cry
  end

  def pbMoveSelection
    @sprites["movesel"].visible = true
    @sprites["movesel"].index   = 0
    selmove    = 0
    oldselmove = 0
    switching = false
    drawSelectedMove(nil, @pokemon.moves[selmove])
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if @sprites["movepresel"].index == @sprites["movesel"].index
        @sprites["movepresel"].z = @sprites["movesel"].z + 1
      else
        @sprites["movepresel"].z = @sprites["movesel"].z
      end
      if Input.trigger?(Input::BACK)
        (switching) ? pbPlayCancelSE : pbPlayCloseMenuSE
        break if !switching
        @sprites["movepresel"].visible = false
        switching = false
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        if selmove == Pokemon::MAX_MOVES
          break if !switching
          @sprites["movepresel"].visible = false
          switching = false
        elsif !@pokemon.shadowPokemon?
          if switching
            tmpmove                    = @pokemon.moves[oldselmove]
            @pokemon.moves[oldselmove] = @pokemon.moves[selmove]
            @pokemon.moves[selmove]    = tmpmove
            @sprites["movepresel"].visible = false
            switching = false
            drawSelectedMove(nil, @pokemon.moves[selmove])
          else
            @sprites["movepresel"].index   = selmove
            @sprites["movepresel"].visible = true
            oldselmove = selmove
            switching = true
          end
        end
      elsif Input.trigger?(Input::UP)
        selmove -= 1
        if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
          selmove = @pokemon.numMoves - 1
        end
        selmove = 0 if selmove >= Pokemon::MAX_MOVES
        selmove = @pokemon.numMoves - 1 if selmove < 0
        @sprites["movesel"].index = selmove
        pbPlayCursorSE
        drawSelectedMove(nil, @pokemon.moves[selmove])
      elsif Input.trigger?(Input::DOWN)
        selmove += 1
        selmove = 0 if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
        selmove = 0 if selmove >= Pokemon::MAX_MOVES
        selmove = Pokemon::MAX_MOVES if selmove < 0
        @sprites["movesel"].index = selmove
        pbPlayCursorSE
        drawSelectedMove(nil, @pokemon.moves[selmove])
      end
    end
    @sprites["movesel"].visible = false
  end

  def pbRibbonSelection
    @sprites["ribbonsel"].visible = true
    @sprites["ribbonsel"].index   = 0
    selribbon    = @ribbonOffset * 4
    oldselribbon = selribbon
    switching = false
    numRibbons = @pokemon.ribbons.length
    numRows    = [((numRibbons + 3) / 4).floor, 3].max
    drawSelectedRibbon(@pokemon.ribbons[selribbon])
    loop do
      @sprites["uparrow"].visible   = (@ribbonOffset > 0)
      @sprites["downarrow"].visible = (@ribbonOffset < numRows - 3)
      Graphics.update
      Input.update
      pbUpdate
      if @sprites["ribbonpresel"].index == @sprites["ribbonsel"].index
        @sprites["ribbonpresel"].z = @sprites["ribbonsel"].z + 1
      else
        @sprites["ribbonpresel"].z = @sprites["ribbonsel"].z
      end
      hasMovedCursor = false
      if Input.trigger?(Input::BACK)
        (switching) ? pbPlayCancelSE : pbPlayCloseMenuSE
        break if !switching
        @sprites["ribbonpresel"].visible = false
        switching = false
      elsif Input.trigger?(Input::USE)
        if switching
          pbPlayDecisionSE
          tmpribbon                      = @pokemon.ribbons[oldselribbon]
          @pokemon.ribbons[oldselribbon] = @pokemon.ribbons[selribbon]
          @pokemon.ribbons[selribbon]    = tmpribbon
          if @pokemon.ribbons[oldselribbon] || @pokemon.ribbons[selribbon]
            @pokemon.ribbons.compact!
            if selribbon >= numRibbons
              selribbon = numRibbons - 1
              hasMovedCursor = true
            end
          end
          @sprites["ribbonpresel"].visible = false
          switching = false
          drawSelectedRibbon(@pokemon.ribbons[selribbon])
        else
          if @pokemon.ribbons[selribbon]
            pbPlayDecisionSE
            @sprites["ribbonpresel"].index = selribbon - (@ribbonOffset * 4)
            oldselribbon = selribbon
            @sprites["ribbonpresel"].visible = true
            switching = true
          end
        end
      elsif Input.trigger?(Input::UP)
        selribbon -= 4
        selribbon += numRows * 4 if selribbon < 0
        hasMovedCursor = true
        pbPlayCursorSE
      elsif Input.trigger?(Input::DOWN)
        selribbon += 4
        selribbon -= numRows * 4 if selribbon >= numRows * 4
        hasMovedCursor = true
        pbPlayCursorSE
      elsif Input.trigger?(Input::LEFT)
        selribbon -= 1
        selribbon += 4 if selribbon % 4 == 3
        hasMovedCursor = true
        pbPlayCursorSE
      elsif Input.trigger?(Input::RIGHT)
        selribbon += 1
        selribbon -= 4 if selribbon % 4 == 0
        hasMovedCursor = true
        pbPlayCursorSE
      end
      next if !hasMovedCursor
      @ribbonOffset = (selribbon / 4).floor if selribbon < @ribbonOffset * 4
      @ribbonOffset = (selribbon / 4).floor - 2 if selribbon >= (@ribbonOffset + 3) * 4
      @ribbonOffset = 0 if @ribbonOffset < 0
      @ribbonOffset = numRows - 3 if @ribbonOffset > numRows - 3
      @sprites["ribbonsel"].index    = selribbon - (@ribbonOffset * 4)
      @sprites["ribbonpresel"].index = oldselribbon - (@ribbonOffset * 4)
      drawSelectedRibbon(@pokemon.ribbons[selribbon])
    end
    @sprites["ribbonsel"].visible = false
  end

  def pbMarking(pokemon)
    @sprites["markingbg"].visible      = true
    @sprites["markingoverlay"].visible = true
    @sprites["markingsel"].visible     = true
    base   = Color.new(248, 248, 248)
    shadow = Color.new(104, 104, 104)
    ret = pokemon.markings.clone
    markings = pokemon.markings.clone
    mark_variants = @markingbitmap.bitmap.height / MARK_HEIGHT
    index = 0
    redraw = true
    markrect = Rect.new(0, 0, MARK_WIDTH, MARK_HEIGHT)
    loop do
      # Redraw the markings and text
      if redraw
        @sprites["markingoverlay"].bitmap.clear
        (@markingbitmap.bitmap.width / MARK_WIDTH).times do |i|
          markrect.x = i * MARK_WIDTH
          markrect.y = [(markings[i] || 0), mark_variants - 1].min * MARK_HEIGHT
          @sprites["markingoverlay"].bitmap.blt(300 + (58 * (i % 3)), 154 + (50 * (i / 3)),
                                                @markingbitmap.bitmap, markrect)
        end
        textpos = [
          [_INTL("Mark {1}", pokemon.name), 366, 102, 2, base, shadow],
          [_INTL("OK"), 366, 254, 2, base, shadow],
          [_INTL("Cancel"), 366, 304, 2, base, shadow]
        ]
        pbDrawTextPositions(@sprites["markingoverlay"].bitmap, textpos)
        redraw = false
      end
      # Reposition the cursor
      @sprites["markingsel"].x = 284 + (58 * (index % 3))
      @sprites["markingsel"].y = 144 + (50 * (index / 3))
      case index
      when 6   # OK
        @sprites["markingsel"].x = 284
        @sprites["markingsel"].y = 244
        @sprites["markingsel"].src_rect.y = @sprites["markingsel"].bitmap.height / 2
      when 7   # Cancel
        @sprites["markingsel"].x = 284
        @sprites["markingsel"].y = 294
        @sprites["markingsel"].src_rect.y = @sprites["markingsel"].bitmap.height / 2
      else
        @sprites["markingsel"].src_rect.y = 0
      end
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        case index
        when 6   # OK
          ret = markings
          break
        when 7   # Cancel
          break
        else
          markings[index] = ((markings[index] || 0) + 1) % mark_variants
          redraw = true
        end
      elsif Input.trigger?(Input::ACTION)
        if index < 6 && markings[index] > 0
          pbPlayDecisionSE
          markings[index] = 0
          redraw = true
        end
      elsif Input.trigger?(Input::UP)
        if index == 7
          index = 6
        elsif index == 6
          index = 4
        elsif index < 3
          index = 7
        else
          index -= 3
        end
        pbPlayCursorSE
      elsif Input.trigger?(Input::DOWN)
        if index == 7
          index = 1
        elsif index == 6
          index = 7
        elsif index >= 3
          index = 6
        else
          index += 3
        end
        pbPlayCursorSE
      elsif Input.trigger?(Input::LEFT)
        if index < 6
          index -= 1
          index += 3 if index % 3 == 2
          pbPlayCursorSE
        end
      elsif Input.trigger?(Input::RIGHT)
        if index < 6
          index += 1
          index -= 3 if index % 3 == 0
          pbPlayCursorSE
        end
      end
    end
    @sprites["markingbg"].visible      = false
    @sprites["markingoverlay"].visible = false
    @sprites["markingsel"].visible     = false
    if pokemon.markings != ret
      pokemon.markings = ret
      return true
    end
    return false
  end

  def pbOptions
    #dorefresh = false
    #commands = []
    #cmdGiveItem = -1
    #cmdTakeItem = -1
    #cmdPokedex  = -1
    #cmdMark     = -1
    #if !@pokemon.egg?
      #commands[cmdGiveItem = commands.length] = _INTL("Give item")
      #commands[cmdTakeItem = commands.length] = _INTL("Take item") if @pokemon.hasItem?
      #commands[cmdPokedex = commands.length]  = _INTL("View Pokédex") if $player.has_pokedex
    #end
    #commands[cmdMark = commands.length]       = _INTL("Mark")
    #commands[commands.length]                 = _INTL("Cancel")
    #command = pbShowCommands(commands)
    #if cmdGiveItem >= 0 && command == cmdGiveItem
      #item = nil
      #pbFadeOutIn {
        #scene = PokemonBag_Scene.new
        #screen = PokemonBagScreen.new(scene, $bag)
        #item = screen.pbChooseItemScreen(proc { |itm| GameData::Item.get(itm).can_hold? })
      #}
      #if item
        #dorefresh = pbGiveItemToPokemon(item, @pokemon, self, @partyindex)
      #end
    #elsif cmdTakeItem >= 0 && command == cmdTakeItem
      #dorefresh = pbTakeItemFromPokemon(@pokemon, self)
    #elsif cmdPokedex >= 0 && command == cmdPokedex
      #$player.pokedex.register_last_seen(@pokemon)
      #pbFadeOutIn {
        #scene = PokemonPokedexInfo_Scene.new
        #screen = PokemonPokedexInfoScreen.new(scene)
        #screen.pbStartSceneSingle(@pokemon.species)
      #}
      #dorefresh = true
    #elsif cmdMark >= 0 && command == cmdMark
      #dorefresh = pbMarking(@pokemon)
    #end
    #return dorefresh
  end

  def pbChooseMoveToForget(move_to_learn)
    new_move = (move_to_learn) ? Pokemon::Move.new(move_to_learn) : nil
    selmove = 0
    maxmove = (new_move) ? Pokemon::MAX_MOVES : Pokemon::MAX_MOVES - 1
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        selmove = Pokemon::MAX_MOVES
        pbPlayCloseMenuSE if new_move
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        break
      elsif Input.trigger?(Input::UP)
        selmove -= 1
        selmove = maxmove if selmove < 0
        if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
          selmove = @pokemon.numMoves - 1
        end
        @sprites["movesel"].index = selmove
        selected_move = (selmove == Pokemon::MAX_MOVES) ? new_move : @pokemon.moves[selmove]
        drawSelectedMove(new_move, selected_move)
      elsif Input.trigger?(Input::DOWN)
        selmove += 1
        selmove = 0 if selmove > maxmove
        if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
          selmove = (new_move) ? maxmove : 0
        end
        @sprites["movesel"].index = selmove
        selected_move = (selmove == Pokemon::MAX_MOVES) ? new_move : @pokemon.moves[selmove]
        drawSelectedMove(new_move, selected_move)
      end
    end
    return (selmove == Pokemon::MAX_MOVES) ? -1 : selmove
  end

  def pbScene
    @pokemon.play_cry
    loop do
      Graphics.update
      Input.update
      pbUpdate
      dorefresh = false
      if Input.trigger?(Input::ACTION)
        pbSEStop
        @pokemon.play_cry
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        if @page == 4
          #pbPlayDecisionSE
          #pbMoveSelection
          #dorefresh = true
        elsif @page == 5
          pbPlayDecisionSE
          pbRibbonSelection
          dorefresh = true
        elsif !@inbattle
          #pbPlayDecisionSE
          dorefresh = pbOptions
        end
      elsif Input.trigger?(Input::UP) && @partyindex > 0
        oldindex = @partyindex
        pbGoToPrevious
        if @partyindex != oldindex
          pbChangePokemon
          @ribbonOffset = 0
          dorefresh = true
        end
      elsif Input.trigger?(Input::DOWN) && @partyindex < @party.length - 1
        oldindex = @partyindex
        pbGoToNext
        if @partyindex != oldindex
          pbChangePokemon
          @ribbonOffset = 0
          dorefresh = true
        end
      elsif Input.trigger?(Input::LEFT) && !@pokemon.egg?
        oldpage = @page
        @page -= 1
        @page = 1 if @page < 1
        @page = 5 if @page > 5
        if @page != oldpage   # Move to next page
          pbSEPlay("GUI summary change page")
          @ribbonOffset = 0
          dorefresh = true
        end
      elsif Input.trigger?(Input::RIGHT) && !@pokemon.egg?
        oldpage = @page
        @page += 1
        @page = 1 if @page < 1
        @page = 5 if @page > 5
        if @page != oldpage   # Move to next page
          pbSEPlay("GUI summary change page")
          @ribbonOffset = 0
          dorefresh = true
        end
      end
      if dorefresh
        drawPage(@page)
      end
    end
    return @partyindex
  end
  
#===============================================================================
# Compatibility with Ability Mutation Summary Scene/Screen Stuff
#===============================================================================
  alias abilityMutation_drawPage drawPage
	def drawPage(page)
	  abilityMutation_drawPage(page)
	  overlay = @sprites["overlay"].bitmap
	  coords = (PluginManager.installed?("BW Summary Screen")) ? [Graphics.width - 18, 114] : [182, 124]
	  pbDisplayAbilityMutation(@pokemon, overlay, coords[0], coords[1])
	end

#===============================================================================
# Compatibility with Showing Happiness in Summary Screen
#===============================================================================
	def drawPageTwo
    overlay = @sprites["overlay"].bitmap
    memo = ""
    # Write nature
    showNature = !@pokemon.shadowPokemon? || @pokemon.heartStage <= 3
    if showNature
      natureName = @pokemon.nature.name
      memo += _INTL("<c3=F83820,E09890>{1}<c3=404040,B0B0B0> nature.\n", natureName)
    end
    # Write date received
    if @pokemon.timeReceived
      date  = @pokemon.timeReceived.day
      month = pbGetMonthName(@pokemon.timeReceived.mon)
      year  = @pokemon.timeReceived.year
      memo += _INTL("<c3=404040,B0B0B0>{1} {2}, {3}\n", date, month, year)
    end
    # Write map name Pokémon was received on
    mapname = pbGetMapNameFromId(@pokemon.obtain_map)
    mapname = @pokemon.obtain_text if @pokemon.obtain_text && !@pokemon.obtain_text.empty?
    mapname = _INTL("Faraway place") if nil_or_empty?(mapname)
    memo += sprintf("<c3=F83820,E09890>%s\n", mapname)
    # Write how Pokémon was obtained
    mettext = [_INTL("Met at Lv. {1}.", @pokemon.obtain_level),
               _INTL("Egg received."),
               _INTL("Traded at Lv. {1}.", @pokemon.obtain_level),
               "",
               _INTL("Had a fateful encounter at Lv. {1}.", @pokemon.obtain_level)][@pokemon.obtain_method]
    memo += sprintf("<c3=404040,B0B0B0>%s\n", mettext) if mettext && mettext != ""
    # If Pokémon was hatched, write when and where it hatched
    if @pokemon.obtain_method == 1
      if @pokemon.timeEggHatched
        date  = @pokemon.timeEggHatched.day
        month = pbGetMonthName(@pokemon.timeEggHatched.mon)
        year  = @pokemon.timeEggHatched.year
        memo += _INTL("<c3=404040,B0B0B0>{1} {2}, {3}\n", date, month, year)
      end
      mapname = pbGetMapNameFromId(@pokemon.hatched_map)
      mapname = _INTL("Faraway place") if nil_or_empty?(mapname)
      memo += sprintf("<c3=F83820,E09890>%s\n", mapname)
      memo += _INTL("<c3=404040,B0B0B0>Egg hatched.\n")
    else
      memo += "\n"   # Empty line
    end
    # Write characteristic
    if showNature # the gibberish on the middle is to make it blue colored
			memo += _INTL("\Hidden Power:<r><c3=1870D8,88A8D0>{1}<c3=404040,B0B0B0>\n",@pokemon.hptype) #by low
    end #of if show nature
		#draw happiness under nature message
    memo += _INTL("\nHappiness:<r>[{1}/255]\n",@pokemon.happiness)
    
    #drawing hearts
    imagepos = []
    grayHeart = sprintf("Graphics/Pictures/Summary/grayheart")
    pinkHeart = sprintf("Graphics/Pictures/Summary/heart")
    
    i = 0
    5.times do
      #draw all possible hearts but grayed out
      imagepos.push([grayHeart, 240+i, Graphics.height-44])
      i += 36
    end
    
    #max happiness is 255
    #first heart     50
    #second heart   100
    #third heart    150
    #fourth heart   200
    #fifth heart    255
    
    #draw hearts based on happiness
    if @pokemon.happiness >= 50
      imagepos.push([pinkHeart, 240, Graphics.height-44])
    end
    if @pokemon.happiness >= 100
      imagepos.push([pinkHeart, 276, Graphics.height-44])
    end
    if @pokemon.happiness >= 150
      imagepos.push([pinkHeart, 312, Graphics.height-44])
    end
    if @pokemon.happiness >= 200
      imagepos.push([pinkHeart, 348, Graphics.height-44])
    end
    if @pokemon.happiness >= 255
      imagepos.push([pinkHeart, 384, Graphics.height-44])
    end
    
    # Draw all images
    pbDrawImagePositions(overlay, imagepos)
    
    # Write all text
    drawFormattedTextEx(overlay, 232, 86, 268, memo)
  end #of draw page two
  
#===============================================================================
# Compatibility with Gen 3 Contests - Contest Stats/Moves in Summary
#===============================================================================
  #Compatibility checks
	BWSUMMARY = PluginManager.installed?("BW Summary Screen")

	alias tdw_contests_summary_start_scene pbStartScene
	def pbStartScene(party, partyindex, inbattle = false)
		@contestpage = false
		tdw_contests_summary_start_scene(party, partyindex, inbattle)
	end

	alias tdw_contests_summary_page_three drawPageThree
	def drawPageThree
		if !@contestpage
			tdw_contests_summary_page_three
		else
			simple = PokeblockSettings::SIMPLIFIED_BERRY_BLENDING
			noSheen = PokeblockSettings::DONT_USE_SHEEN
			bargraph = (PluginManager.installed?("Better Bitmaps") ? PokeblockSettings::STATS_BAR_GRAPH : true)
			if BWSUMMARY
				if SUMMARY_B2W2_STYLE
					@sprites["menuoverlay"].setBitmap("Graphics/Pictures/Summary/bg_3_contest_b2w2")
				else
					@sprites["menuoverlay"].setBitmap("Graphics/Pictures/Summary/bg_3_contest_bw")
				end
			else
				@sprites["background"].setBitmap(sprintf("Graphics/Pictures/Summary/bg_3_contest")) 
			end
			pbCreateConditionBars(simple,noSheen,bargraph)
		end
	end
	
	alias tdw_contests_summary_page_four drawPageFour
	def drawPageFour
		if !@contestpage
			tdw_contests_summary_page_four
		else
			overlay = @sprites["overlay"].bitmap
			if BWSUMMARY
				moveBase   = Color.new(255, 255, 255)
				moveShadow = Color.new(123, 123, 123)
				ppBase   = [moveBase,                # More than 1/2 of total PP
						  Color.new(255, 214, 0),    # 1/2 of total PP or less
						  Color.new(255, 115, 0),   # 1/4 of total PP or less
						  Color.new(255, 8, 72)]    # Zero PP
				ppShadow = [moveShadow,             # More than 1/2 of total PP
						  Color.new(123, 99, 0),   # 1/2 of total PP or less
						  Color.new(115, 57, 0),   # 1/4 of total PP or less
						  Color.new(123, 8, 49)]   # Zero PP
			else
				moveBase   = Color.new(64, 64, 64)
				moveShadow = Color.new(176, 176, 176)
				ppBase   = [moveBase,                # More than 1/2 of total PP
							Color.new(248, 192, 0),    # 1/2 of total PP or less
							Color.new(248, 136, 32),   # 1/4 of total PP or less
							Color.new(248, 72, 72)]    # Zero PP
				ppShadow = [moveShadow,             # More than 1/2 of total PP
							Color.new(144, 104, 0),   # 1/2 of total PP or less
							Color.new(144, 72, 24),   # 1/4 of total PP or less
							Color.new(136, 48, 48)]   # Zero PP
			end
			@sprites["pokemon"].visible  = true
			@sprites["pokeicon"].visible = false
			@sprites["itemicon"].visible = true
			textpos  = []
			imagepos = []
			# Write move names, types and PP amounts for each known move
			if BWSUMMARY
				xPos = 32
				yPos = 76
				yAdj = 12
			else
				xPos = 248
				yPos = 104
				yAdj = 0
			end
			Pokemon::MAX_MOVES.times do |i|
			  move = @pokemon.moves[i]
			  if move
				type_number = GameData::Move.get(move.id).contest_type_position
				imagepos.push(["Graphics/Pictures/Contest/contesttype", xPos, yPos + yAdj - 4, 0, type_number * 28, 64, 28])
				textpos.push([move.name, xPos+68, yPos + yAdj, 0, moveBase, moveShadow])
				if move.total_pp > 0
				  textpos.push([_INTL("PP"), xPos+94, yPos + yAdj + 32, 0, moveBase, moveShadow])
				  ppfraction = 0
				  if move.pp == 0
					ppfraction = 3
				  elsif move.pp * 4 <= move.total_pp
					ppfraction = 2
				  elsif move.pp * 2 <= move.total_pp
					ppfraction = 1
				  end
				  textpos.push([sprintf("%d/%d", move.pp, move.total_pp), xPos+212, yPos + yAdj + 32, 1, ppBase[ppfraction], ppShadow[ppfraction]])
				end
			  else
				textpos.push(["-", xPos+68, yPos, 0, moveBase, moveShadow])
				textpos.push(["--", xPos+194, yPos + yAdj + 32, 1, moveBase, moveShadow])
			  end
			  yPos += 64
			end
			# Draw all text and images
			pbDrawTextPositions(overlay, textpos)
			pbDrawImagePositions(overlay, imagepos)
		end
	end

	def drawPageFourContestSelecting(move_to_learn)
		overlay = @sprites["overlay"].bitmap
		overlay.clear
		if BWSUMMARY
			base   = Color.new(255, 255, 255)
			shadow = Color.new(123, 123, 123)
			moveBase   = Color.new(255, 255, 255)
			moveShadow = Color.new(123, 123, 123)
			ppBase   = [moveBase,                # More than 1/2 of total PP
					  Color.new(255, 214, 0),    # 1/2 of total PP or less
					  Color.new(255, 115, 0),   # 1/4 of total PP or less
					  Color.new(255, 8, 74)]    # Zero PP
			ppShadow = [moveShadow,             # More than 1/2 of total PP
					  Color.new(123, 99, 0),   # 1/2 of total PP or less
					  Color.new(115, 57, 0),   # 1/4 of total PP or less
					  Color.new(123, 8, 49)]   # Zero PP
		else
			base   = Color.new(248, 248, 248)
			shadow = Color.new(104, 104, 104)
			moveBase   = Color.new(64, 64, 64)
			moveShadow = Color.new(176, 176, 176)
			ppBase   = [moveBase,                # More than 1/2 of total PP
						Color.new(248, 192, 0),    # 1/2 of total PP or less
						Color.new(248, 136, 32),   # 1/4 of total PP or less
						Color.new(248, 72, 72)]    # Zero PP
			ppShadow = [moveShadow,             # More than 1/2 of total PP
						Color.new(144, 104, 0),   # 1/2 of total PP or less
						Color.new(144, 72, 24),   # 1/4 of total PP or less
						Color.new(136, 48, 48)]   # Zero PP
		end
		# Set background image
		if move_to_learn
		  @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_learnmove")
		else
		  if BWSUMMARY
		    if SUMMARY_B2W2_STYLE
			  @sprites["menuoverlay"].setBitmap("Graphics/Pictures/Summary/bg_movedetail_B2W2")
			else
			  @sprites["menuoverlay"].setBitmap("Graphics/Pictures/Summary/bg_movedetail")
			end
		  else
			@sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_movedetail")
		  end
		end
		# Write various bits of text
		if BWSUMMARY
			if move_to_learn || SUMMARY_B2W2_STYLE
				textpos = [
				  [_INTL("APPEAL"), 20, 128, 0, base, shadow],
				  #[_INTL("JAMMING"), 20, 160, 0, base, shadow]
				]
			else
				textpos = [
				  [_INTL("MOVES"), 26, 14, 0, base, shadow],
				  [_INTL("APPEAL"), 20, 128, 0, base, shadow],
				  #[_INTL("JAMMING"), 20, 160, 0, base, shadow]
				]
			end
		else
			textpos = [
			  [_INTL("MOVES"), 26, 22, 0, base, shadow],
			  [_INTL("APPEAL"), 20, 128, 0, base, shadow],
			  #[_INTL("JAMMING"), 20, 160, 0, base, shadow]
			]
		end
		imagepos = []
		# Write move names, types and PP amounts for each known move
		if BWSUMMARY
			xPos = 260
			yPos = 92
			yAdj = 12
		else
			xPos = 248
			yPos = 104
			yAdj = 0
		end
		yPos -= 76 if move_to_learn
		limit = (move_to_learn) ? Pokemon::MAX_MOVES + 1 : Pokemon::MAX_MOVES
		limit.times do |i|
		  move = @pokemon.moves[i]
		  if i == Pokemon::MAX_MOVES
			move = move_to_learn
			yPos += 20
		  end
		  if move
			type_number = GameData::Move.get(move.id).contest_type_position
			imagepos.push(["Graphics/Pictures/Contest/contesttype", xPos, yPos + yAdj - 4, 0, type_number * 28, 64, 28])
			textpos.push([move.name, xPos + 68, yPos + yAdj, 0, moveBase, moveShadow])
			if move.total_pp > 0
			  textpos.push([_INTL("PP"), xPos + 94, yPos + yAdj + 32, 0, moveBase, moveShadow])
			  ppfraction = 0
			  if move.pp == 0
				ppfraction = 3
			  elsif move.pp * 4 <= move.total_pp
				ppfraction = 2
			  elsif move.pp * 2 <= move.total_pp
				ppfraction = 1
			  end
			  textpos.push([sprintf("%d/%d", move.pp, move.total_pp), xPos + 212, yPos + yAdj + 32, 1, ppBase[ppfraction], ppShadow[ppfraction]])
			end
		  else
			textpos.push(["-", xPos + 68, yPos + yAdj, 0, moveBase, moveShadow])
			textpos.push(["--", xPos + 194, yPos + yAdj + 32, 1, moveBase, moveShadow])
		  end
		  yPos += 64
		end
		# Draw all text and images
		pbDrawTextPositions(overlay, textpos)
		pbDrawImagePositions(overlay, imagepos)
		# Draw Pokémon's type icon(s)
		@pokemon.types.each_with_index do |type, i|
		  type_number = GameData::Type.get(type).icon_position
		  type_rect = Rect.new(0, type_number * 28, 64, 28)
		  type_x = (@pokemon.types.length == 1) ? 130 : 96 + (70 * i)
		  overlay.blt(type_x, 78, @typebitmap.bitmap, type_rect)
		end
	end
		
	def drawSelectedContestMove(move_to_learn, selected_move)
		# Draw all of page four, except selected move's details
		drawPageFourContestSelecting(move_to_learn)
		move = GameData::Move.get(selected_move.id)
		# Set various values
		overlay = @sprites["overlay"].bitmap
		base = Color.new(64, 64, 64)
		shadow = Color.new(176, 176, 176)
		@sprites["pokemon"].visible = false if @sprites["pokemon"]
		@sprites["pokeicon"].pokemon = @pokemon
		@sprites["pokeicon"].visible = true
		@sprites["itemicon"].visible = false if @sprites["itemicon"]
		hearts = !move.contest_can_be_used? ? 0 : move.contest_hearts
		jam = !move.contest_can_be_used? ? 0 : move.contest_jam
		description = move.contest_description
		textpos = []
		imagepos = []
		# Draw all text
		pbDrawTextPositions(overlay, textpos)
		# Draw selected move's information
		imagepos.push(["Graphics/Pictures/Contest/move_heart#{hearts}", 166, 124+6]) if hearts > 0
		#imagepos.push(["Graphics/Pictures/Contest/move_negaheart#{jam}", 166, 156]) if jam > 0
		pbDrawImagePositions(overlay, imagepos)
		# Draw selected move's description
		drawTextEx(overlay, 4, 224, 230, 5, description, base, shadow)
	end
	
	def pbScene
		@pokemon.play_cry
		loop do
		  Graphics.update
		  Input.update
		  pbUpdate
		  dorefresh = false
		  if Input.trigger?(Input::ACTION)
			pbSEStop
			@pokemon.play_cry
		  elsif Input.trigger?(Input::BACK)
			pbPlayCloseMenuSE
			break
		  elsif Input.trigger?(Input::USE)
			if @page == 4
			  #pbPlayDecisionSE
			  #pbMoveSelection
			  #dorefresh = true
			elsif @page == 5
			  pbPlayDecisionSE
			  pbRibbonSelection
			  dorefresh = true
			elsif !@inbattle
			  #pbPlayDecisionSE
			  #dorefresh = pbOptions
			end
		  elsif Input.trigger?(Input::SPECIAL) 
			if @page == 3# && $game_switches[ContestSettings::CONTEST_INFO_IN_SUMMARY_SWITCH]
			  @contestpage = !@contestpage
			  pbPlayDecisionSE
			  dorefresh = true
			end
			if @page == 4# && $game_switches[ContestSettings::CONTEST_INFO_IN_SUMMARY_SWITCH]
			  @contestpage = !@contestpage
			  pbPlayDecisionSE
			  dorefresh = true
			end
		  elsif Input.trigger?(Input::UP) && @partyindex > 0
			oldindex = @partyindex
			pbGoToPrevious
			if @partyindex != oldindex
			  pbChangePokemon
			  @ribbonOffset = 0
			  dorefresh = true
			end
		  elsif Input.trigger?(Input::DOWN) && @partyindex < @party.length - 1
			oldindex = @partyindex
			pbGoToNext
			if @partyindex != oldindex
			  pbChangePokemon
			  @ribbonOffset = 0
			  dorefresh = true
			end
		  elsif Input.trigger?(Input::LEFT) && !@pokemon.egg?
			oldpage = @page
			@page -= 1
			@page = 1 if @page < 1
			@page = 5 if @page > 5
			if @page != oldpage   # Move to next page
			  pbSEPlay("GUI summary change page")
			  @ribbonOffset = 0
			  dorefresh = true
			end
		  elsif Input.trigger?(Input::RIGHT) && !@pokemon.egg?
			oldpage = @page
			@page += 1
			@page = 1 if @page < 1
			@page = 5 if @page > 5
			if @page != oldpage   # Move to next page
			  pbSEPlay("GUI summary change page")
			  @ribbonOffset = 0
			  dorefresh = true
			end
		  end
		  if dorefresh
			disposeContestStats
			drawPage(@page)
		  end
		end
		return @partyindex
	end
	
	alias tdw_contests_summary_move_select drawSelectedMove
	def drawSelectedMove(move_to_learn, selected_move)
		if !@contestpage
			tdw_contests_summary_move_select(move_to_learn, selected_move)
		else
			drawSelectedContestMove(move_to_learn, selected_move)
		end
	end

	def pbMoveSelection
		@sprites["movesel"].visible = true
		@sprites["movesel"].index   = 0
		selmove    = 0
		oldselmove = 0
		switching = false
		drawSelectedMove(nil, @pokemon.moves[selmove])
		loop do
		  Graphics.update
		  Input.update
		  pbUpdate
		  if @sprites["movepresel"].index == @sprites["movesel"].index
			@sprites["movepresel"].z = @sprites["movesel"].z + 1
		  else
			@sprites["movepresel"].z = @sprites["movesel"].z
		  end
		  if Input.trigger?(Input::BACK)
			(switching) ? pbPlayCancelSE : pbPlayCloseMenuSE
			break if !switching
			@sprites["movepresel"].visible = false
			switching = false
		  elsif Input.trigger?(Input::USE)
			pbPlayDecisionSE
			if selmove == Pokemon::MAX_MOVES
			  break if !switching
			  @sprites["movepresel"].visible = false
			  switching = false
			elsif !@pokemon.shadowPokemon?
			  if switching
				tmpmove                    = @pokemon.moves[oldselmove]
				@pokemon.moves[oldselmove] = @pokemon.moves[selmove]
				@pokemon.moves[selmove]    = tmpmove
				@sprites["movepresel"].visible = false
				switching = false
				drawSelectedMove(nil, @pokemon.moves[selmove])
			  else
				@sprites["movepresel"].index   = selmove
				@sprites["movepresel"].visible = true
				oldselmove = selmove
				switching = true
			  end
			end
		  elsif Input.trigger?(Input::UP)
			selmove -= 1
			if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
			  selmove = @pokemon.numMoves - 1
			end
			selmove = 0 if selmove >= Pokemon::MAX_MOVES
			selmove = @pokemon.numMoves - 1 if selmove < 0
			@sprites["movesel"].index = selmove
			pbPlayCursorSE
			drawSelectedMove(nil, @pokemon.moves[selmove])
		  elsif Input.trigger?(Input::DOWN)
			selmove += 1
			selmove = 0 if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
			selmove = 0 if selmove >= Pokemon::MAX_MOVES
			selmove = Pokemon::MAX_MOVES if selmove < 0
			@sprites["movesel"].index = selmove
			pbPlayCursorSE
			drawSelectedMove(nil, @pokemon.moves[selmove])
		  elsif Input.trigger?(Input::SPECIAL) 
			if @page == 3 && $game_switches[ContestSettings::CONTEST_INFO_IN_SUMMARY_SWITCH]
			  @contestpage = !@contestpage
			  pbPlayDecisionSE
			  drawSelectedMove(nil, @pokemon.moves[selmove])
			end
			if @page == 4 && $game_switches[ContestSettings::CONTEST_INFO_IN_SUMMARY_SWITCH]
			  @contestpage = !@contestpage
			  pbPlayDecisionSE
			  drawSelectedMove(nil, @pokemon.moves[selmove])
			end
		  end
		end
		@sprites["movesel"].visible = false
	end
	

	def pbChooseMoveToForget(move_to_learn)
		new_move = (move_to_learn) ? Pokemon::Move.new(move_to_learn) : nil
		selmove = 0
		maxmove = (new_move) ? Pokemon::MAX_MOVES : Pokemon::MAX_MOVES - 1
		loop do
		  Graphics.update
		  Input.update
		  pbUpdate
		  if Input.trigger?(Input::BACK)
			selmove = Pokemon::MAX_MOVES
			pbPlayCloseMenuSE if new_move
			break
		  elsif Input.trigger?(Input::USE)
			pbPlayDecisionSE
			break
		  elsif Input.trigger?(Input::UP)
			selmove -= 1
			selmove = maxmove if selmove < 0
			if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
			  selmove = @pokemon.numMoves - 1
			end
			@sprites["movesel"].index = selmove
			selected_move = (selmove == Pokemon::MAX_MOVES) ? new_move : @pokemon.moves[selmove]
			drawSelectedMove(new_move, selected_move)
		  elsif Input.trigger?(Input::DOWN)
			selmove += 1
			selmove = 0 if selmove > maxmove
			if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
			  selmove = (new_move) ? maxmove : 0
			end
			@sprites["movesel"].index = selmove
			selected_move = (selmove == Pokemon::MAX_MOVES) ? new_move : @pokemon.moves[selmove]
			drawSelectedMove(new_move, selected_move)
		  elsif Input.trigger?(Input::SPECIAL) 
			if $game_switches[ContestSettings::CONTEST_INFO_IN_SUMMARY_SWITCH]
			  @contestpage = !@contestpage
			  pbPlayDecisionSE
			  selected_move = (selmove == Pokemon::MAX_MOVES) ? new_move : @pokemon.moves[selmove]
			  drawSelectedMove(new_move, selected_move)
			end
		  end
		end
		return (selmove == Pokemon::MAX_MOVES) ? -1 : selmove
	end
	
	def disposeContestStats
		@sprites["statsgraphbase"]&.dispose
		@sprites["statsgraph"]&.dispose
		arr = ["Cool", "Beauty", "Cute", "Smart", "Tough", "Sheen"]
			6.times { |i|
				@sprites["#{arr[i]} bar"]&.dispose
			}
	end
	
	def pbCreateConditionBars(simple,noSheen,bargraph)
		pkmn = @pokemon
		arr = ["Cool", "Beauty", "Cute", "Smart", "Tough", "Sheen"]
		fea = [pkmn.cool, pkmn.beauty, pkmn.cute, pkmn.smart, pkmn.tough, pkmn.sheen]
		imagepos = []
		xBase = 236
		xBaseAdj = 0
		xBaseAdj = -228 if BWSUMMARY
		xBase += xBaseAdj
		yBase = ((simple || noSheen) ? 126 : 104)
		if bargraph
			6.times { |i|
				next if (simple || noSheen) && i == 5
				overlay = @sprites["overlay"].bitmap
				pbSetSmallFont(overlay)
				textpos = []
				barBitmap = AnimatedBitmap.new("Graphics/Pictures/Pokeblock/UI Pokeblock/Bar_#{arr[i]}")
				@sprites["#{arr[i]} bar"] = Sprite.new(@viewport)
				@sprites["#{arr[i]} bar"].bitmap = barBitmap.bitmap
				@sprites["#{arr[i]} bar"].src_rect.width = fea[i]
				@sprites["#{arr[i]} bar"].x = xBase + 4
				@sprites["#{arr[i]} bar"].y = yBase + 48 * i
				@sprites["#{arr[i]} bar"].z=5
				string = i < 5 ? ContestFunctions.getCategoryNameShort(i) : _INTL("Sheen")
				string_width = overlay.text_size(string).width
				textpos.push([string, xBase, yBase - 18 + 48 * i, 0, Color.new(96, 96, 112), Color.new(240, 248, 248)])
				pbDrawTextPositions(overlay, textpos)
				pbSetSystemFont(overlay)
				imagepos.push(["Graphics/Pictures/Pokeblock/UI Pokeblock/Bar_bg",xBase,yBase + 48 * i])
				imagepos.push(["Graphics/Pictures/Pokeblock/UI Pokeblock/max", xBase+string_width+4, @sprites["#{arr[i]} bar"].y-20]) if fea[i] >=255
			}
		else				
			pentagon_outline_color = Color.new(165,83,147)
			pentagon_back_color = Color.white
			pentagon_stat_color = Color.new(71,226,191)
			graphX = xBase + 130
			graphY = ((simple || noSheen) ? 120 : 104) + 110
			@sprites["statsgraphbase"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
			pbDrawStatsPentagonBase(@sprites["statsgraphbase"],graphX,graphY,77,pentagon_outline_color,pentagon_back_color)
			@sprites["statsgraph"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
			@sprites["statsgraph"].opacity = 180
			pbDrawStatsPentagon(@sprites["statsgraph"],[fea[0],fea[1],fea[2],fea[3],fea[4]],graphX,graphY,77,pentagon_stat_color)
			xPos = [334,436,398,270,232]
			yPos = [100,159,284,284,159]
			5.times { |i|
				x = xPos[i]
				x += xBaseAdj
				y = yPos[i] 
				y += ((simple || noSheen) ? 16 : 0)
				imagepos.push(["Graphics/Pictures/Contest/contesttype", x, y, 0, i * 28, 64, 28])
				if fea[i] >= 255
					x = [400,420,464,336,298][i]
					x += xBaseAdj
					y = [118,176,302,302,176][i]
					y -= ((simple || noSheen) ? 0 : 16)
					imagepos.push(["Graphics/Pictures/Pokeblock/UI Pokeblock/max", x, y])
				end
			}
			if !(simple || noSheen)	
				barBitmap = AnimatedBitmap.new("Graphics/Pictures/Pokeblock/UI Pokeblock/Bar_Sheen")
				@sprites["Sheen bar"] = Sprite.new(@viewport)
				@sprites["Sheen bar"].bitmap = barBitmap.bitmap
				@sprites["Sheen bar"].src_rect.width = fea[5]
				@sprites["Sheen bar"].x = xBase + 4
				@sprites["Sheen bar"].y = yBase + 48 * 5
				@sprites["Sheen bar"].z=5
				pbSetSmallFont(@sprites["overlay"].bitmap)
				string_width = @sprites["overlay"].bitmap.text_size("Sheen").width
				imagepos.push(["Graphics/Pictures/Pokeblock/UI Pokeblock/Bar_bg",xBase,yBase + 48 * 5])
				imagepos.push(["Graphics/Pictures/Pokeblock/UI Pokeblock/max", xBase+string_width+4, @sprites["Sheen bar"].y-20]) if fea[5] >=255
				textpos=[[_INTL("Sheen"), xBase, yBase - 18 + 48 * 5, 0, Color.new(96, 96, 112), Color.new(240, 248, 248)]]
				pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)
				pbSetSystemFont(@sprites["overlay"].bitmap)
			end
		end
		pbDrawImagePositions(@sprites["overlay"].bitmap, imagepos)
	end
  
end

#===============================================================================
#
#===============================================================================
class TimeMachinePokemonSummaryScreen
  def initialize(scene, inbattle = false)
    @scene = scene
    @inbattle = inbattle
  end

  def pbStartScreen(party, partyindex)
    @scene.pbStartScene(party, partyindex, @inbattle)
    ret = @scene.pbScene
    @scene.pbEndScene
    return ret
  end

  def pbStartForgetScreen(party, partyindex, move_to_learn)
    ret = -1
    @scene.pbStartForgetScene(party, partyindex, move_to_learn)
    loop do
      ret = @scene.pbChooseMoveToForget(move_to_learn)
      break if ret < 0 || !move_to_learn
      break if $DEBUG || !party[partyindex].moves[ret].hidden_move?
      pbMessage(_INTL("HM moves can't be forgotten now.")) { @scene.pbUpdate }
    end
    @scene.pbEndScene
    return ret
  end

  def pbStartChooseMoveScreen(party, partyindex, message)
    ret = -1
    @scene.pbStartForgetScene(party, partyindex, nil)
    pbMessage(message) { @scene.pbUpdate }
    loop do
      ret = @scene.pbChooseMoveToForget(nil)
      break if ret >= 0
      pbMessage(_INTL("You must choose a move!")) { @scene.pbUpdate }
    end
    @scene.pbEndScene
    return ret
  end
end