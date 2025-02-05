SaveData.register(:contest_save_data) do
  save_value { $contest_save_data }
  load_value { |value|  $contest_save_data = value }
  new_game_value { Contest_Save_Data.new }
end

class Contest_Save_Data
  attr_accessor :lastContestWinner
  
  attr_accessor :normalCoolWinner
  attr_accessor :normalBeautyWinner
  attr_accessor :normalCuteWinner
  attr_accessor :normalSmartWinner
  attr_accessor :normalToughWinner
  
  attr_accessor :greatCoolWinner
  attr_accessor :greatBeautyWinner
  attr_accessor :greatCuteWinner
  attr_accessor :greatSmartWinner
  attr_accessor :greatToughWinner
  
  attr_accessor :ultraCoolWinner
  attr_accessor :ultraBeautyWinner
  attr_accessor :ultraCuteWinner
  attr_accessor :ultraSmartWinner
  attr_accessor :ultraToughWinner
  
  attr_accessor :masterCoolWinner
  attr_accessor :masterBeautyWinner
  attr_accessor :masterCuteWinner
  attr_accessor :masterSmartWinner
  attr_accessor :masterToughWinner

  def initialize
    @lastContestWinner = nil
    
    #==================
    # NORMAL RANK
    #==================
    @normalCoolWinner   = nil
    @normalBeautyWinner = nil
    @normalCuteWinner   = nil
    @normalSmartWinner  = nil
    @normalToughWinner  = nil
    
    #==================
    # GREAT RANK
    #==================
    @greatCoolWinner   = nil
    @greatBeautyWinner = nil
    @greatCuteWinner   = nil
    @greatSmartWinner  = nil
    @greatToughWinner  = nil
    
    #==================
    # ULTRA RANK
    #==================
    @ultraCoolWinner   = nil
    @ultraBeautyWinner = nil
    @ultraCuteWinner   = nil
    @ultraSmartWinner  = nil
    @ultraToughWinner  = nil
    
    #==================
    # MASTER RANK
    #==================
    @masterCoolWinner   = nil
    @masterBeautyWinner = nil
    @masterCuteWinner   = nil
    @masterSmartWinner  = nil
    @masterToughWinner  = nil
    
  end #def initialize
  
  def showWinner(arg)
    case arg
    when "Previous"
      winner = @lastContestWinner
	  print @lastContestWinner
      if winner.nil?
        pbMessage(_INTL("Nobody has won a contest recently..."))
      else
        species = winner[:PkmnSpecies]
        gender = winner[:PkmnGender]
        form = winner[:PkmnForm]
        shiny = winner[:PkmnShiny]
        winnerSprite = createWinnerBitmap(species, gender, form, shiny)
        pbMessageWinner(_INTL("\\f[test]<ac>Most Recent Contest Winner: \n#{winner[:TrainerName]} with #{winner[:PkmnName]} the #{winner[:PkmnSpecies]}!"), winnerSprite)
      end
      
    #==================
    # NORMAL RANK
    #==================
    when "NormalCool"
      winner = @normalCoolWinner
      if winner.nil?
        pbMessage(_INTL("Nobody has won this contest recently..."))
      else
        species = winner[:PkmnSpecies]
        gender = winner[:PkmnGender]
        form = winner[:PkmnForm]
        shiny = winner[:PkmnShiny]
        winnerSprite = createWinnerBitmap(species, gender, form, shiny)
        pbMessageWinner(_INTL("\\f[test]<ac>Normal Cool Contest Winner: \n#{winner[:TrainerName]} with #{winner[:PkmnName]} the #{winner[:PkmnSpecies]}!"), winnerSprite)
      end
    when "NormalBeauty"
      winner = @normalBeautyWinner
      if winner.nil?
        pbMessage(_INTL("Nobody has won this contest recently..."))
      else
        species = winner[:PkmnSpecies]
        gender = winner[:PkmnGender]
        form = winner[:PkmnForm]
        shiny = winner[:PkmnShiny]
        winnerSprite = createWinnerBitmap(species, gender, form, shiny)
        pbMessageWinner(_INTL("\\f[test]<ac>Normal Beauty Contest Winner: \n#{winner[:TrainerName]} with #{winner[:PkmnName]} the #{winner[:PkmnSpecies]}!"), winnerSprite)
      end
    when "NormalCute"
      winner = @normalCuteWinner
      if winner.nil?
        pbMessage(_INTL("Nobody has won this contest recently..."))
      else
        species = winner[:PkmnSpecies]
        gender = winner[:PkmnGender]
        form = winner[:PkmnForm]
        shiny = winner[:PkmnShiny]
        winnerSprite = createWinnerBitmap(species, gender, form, shiny)
        pbMessageWinner(_INTL("\\f[test]<ac>Normal Cute Contest Winner: \n#{winner[:TrainerName]} with #{winner[:PkmnName]} the #{winner[:PkmnSpecies]}!"), winnerSprite)
      end
    when "NormalSmart"
      winner = @normalSmartWinner
      if winner.nil?
        pbMessage(_INTL("Nobody has won this contest recently..."))
      else
        species = winner[:PkmnSpecies]
        gender = winner[:PkmnGender]
        form = winner[:PkmnForm]
        shiny = winner[:PkmnShiny]
        winnerSprite = createWinnerBitmap(species, gender, form, shiny)
        pbMessageWinner(_INTL("\\f[test]<ac>Normal Smart Contest Winner: \n#{winner[:TrainerName]} with #{winner[:PkmnName]} the #{winner[:PkmnSpecies]}!"), winnerSprite)
      end
    when "NormalTough"
      winner = @normalToughWinner
      if winner.nil?
        pbMessage(_INTL("Nobody has won this contest recently..."))
      else
        species = winner[:PkmnSpecies]
        gender = winner[:PkmnGender]
        form = winner[:PkmnForm]
        shiny = winner[:PkmnShiny]
        winnerSprite = createWinnerBitmap(species, gender, form, shiny)
        pbMessageWinner(_INTL("\\f[test]<ac>Normal Tough Contest Winner: \n#{winner[:TrainerName]} with #{winner[:PkmnName]} the #{winner[:PkmnSpecies]}!"), winnerSprite)
      end
    
    #==================
    # GREAT RANK
    #==================
    when "GreatCool"
      winner = @greatCoolWinner
      if winner.nil?
        pbMessage(_INTL("Nobody has won this contest recently..."))
      else
        species = winner[:PkmnSpecies]
        gender = winner[:PkmnGender]
        form = winner[:PkmnForm]
        shiny = winner[:PkmnShiny]
        winnerSprite = createWinnerBitmap(species, gender, form, shiny)
        pbMessageWinner(_INTL("\\f[test]<ac>Great Cool Contest Winner: \n#{winner[:TrainerName]} with #{winner[:PkmnName]} the #{winner[:PkmnSpecies]}!"), winnerSprite)
      end
    when "GreatBeauty"
      winner = @greatBeautyWinner
      if winner.nil?
        pbMessage(_INTL("Nobody has won this contest recently..."))
      else
        species = winner[:PkmnSpecies]
        gender = winner[:PkmnGender]
        form = winner[:PkmnForm]
        shiny = winner[:PkmnShiny]
        winnerSprite = createWinnerBitmap(species, gender, form, shiny)
        pbMessageWinner(_INTL("\\f[test]<ac>Great Beauty Contest Winner: \n#{winner[:TrainerName]} with #{winner[:PkmnName]} the #{winner[:PkmnSpecies]}!"), winnerSprite)
      end
    when "GreatCute"
      winner = @greatCuteWinner
      if winner.nil?
        pbMessage(_INTL("Nobody has won this contest recently..."))
      else
        species = winner[:PkmnSpecies]
        gender = winner[:PkmnGender]
        form = winner[:PkmnForm]
        shiny = winner[:PkmnShiny]
        winnerSprite = createWinnerBitmap(species, gender, form, shiny)
        pbMessageWinner(_INTL("\\f[test]<ac>Great Cute Contest Winner: \n#{winner[:TrainerName]} with #{winner[:PkmnName]} the #{winner[:PkmnSpecies]}!"), winnerSprite)
      end
    when "GreatSmart"
      winner = @greatSmartWinner
      if winner.nil?
        pbMessage(_INTL("Nobody has won this contest recently..."))
      else
        species = winner[:PkmnSpecies]
        gender = winner[:PkmnGender]
        form = winner[:PkmnForm]
        shiny = winner[:PkmnShiny]
        winnerSprite = createWinnerBitmap(species, gender, form, shiny)
        pbMessageWinner(_INTL("\\f[test]<ac>Great Smart Contest Winner: \n#{winner[:TrainerName]} with #{winner[:PkmnName]} the #{winner[:PkmnSpecies]}!"), winnerSprite)
      end
    when "GreatTough"
      winner = @greatToughWinner
      if winner.nil?
        pbMessage(_INTL("Nobody has won this contest recently..."))
      else
        species = winner[:PkmnSpecies]
        gender = winner[:PkmnGender]
        form = winner[:PkmnForm]
        shiny = winner[:PkmnShiny]
        winnerSprite = createWinnerBitmap(species, gender, form, shiny)
        pbMessageWinner(_INTL("\\f[test]<ac>Great Tough Contest Winner: \n#{winner[:TrainerName]} with #{winner[:PkmnName]} the #{winner[:PkmnSpecies]}!"), winnerSprite)
      end
    
    #==================
    # ULTRA RANK
    #==================
    when "UltraCool"
      winner = @ultraCoolWinner
      if winner.nil?
        pbMessage(_INTL("Nobody has won this contest recently..."))
      else
        species = winner[:PkmnSpecies]
        gender = winner[:PkmnGender]
        form = winner[:PkmnForm]
        shiny = winner[:PkmnShiny]
        winnerSprite = createWinnerBitmap(species, gender, form, shiny)
        pbMessageWinner(_INTL("\\f[test]<ac>Ultra Cool Contest Winner: \n#{winner[:TrainerName]} with #{winner[:PkmnName]} the #{winner[:PkmnSpecies]}!"), winnerSprite)
      end
    when "UltraBeauty"
      winner = @ultraBeautyWinner
      if winner.nil?
        pbMessage(_INTL("Nobody has won this contest recently..."))
      else
        species = winner[:PkmnSpecies]
        gender = winner[:PkmnGender]
        form = winner[:PkmnForm]
        shiny = winner[:PkmnShiny]
        winnerSprite = createWinnerBitmap(species, gender, form, shiny)
        pbMessageWinner(_INTL("\\f[test]<ac>Ultra Beauty Contest Winner: \n#{winner[:TrainerName]} with #{winner[:PkmnName]} the #{winner[:PkmnSpecies]}!"), winnerSprite)
      end
    when "UltraCute"
      winner = @ultraCuteWinner
      if winner.nil?
        pbMessage(_INTL("Nobody has won this contest recently..."))
      else
        species = winner[:PkmnSpecies]
        gender = winner[:PkmnGender]
        form = winner[:PkmnForm]
        shiny = winner[:PkmnShiny]
        winnerSprite = createWinnerBitmap(species, gender, form, shiny)
        pbMessageWinner(_INTL("\\f[test]<ac>Ultra Cute Contest Winner: \n#{winner[:TrainerName]} with #{winner[:PkmnName]} the #{winner[:PkmnSpecies]}!"), winnerSprite)
      end
    when "UltraSmart"
      winner = @ultraSmartWinner
      if winner.nil?
        pbMessage(_INTL("Nobody has won this contest recently..."))
      else
        species = winner[:PkmnSpecies]
        gender = winner[:PkmnGender]
        form = winner[:PkmnForm]
        shiny = winner[:PkmnShiny]
        winnerSprite = createWinnerBitmap(species, gender, form, shiny)
        pbMessageWinner(_INTL("\\f[test]<ac>Ultra Smart Contest Winner: \n#{winner[:TrainerName]} with #{winner[:PkmnName]} the #{winner[:PkmnSpecies]}!"), winnerSprite)
      end
    when "UltraTough"
      winner = @ultraToughWinner
      if winner.nil?
        pbMessage(_INTL("Nobody has won this contest recently..."))
      else
        species = winner[:PkmnSpecies]
        gender = winner[:PkmnGender]
        form = winner[:PkmnForm]
        shiny = winner[:PkmnShiny]
        winnerSprite = createWinnerBitmap(species, gender, form, shiny)
        pbMessageWinner(_INTL("\\f[test]<ac>Ultra Tough Contest Winner: \n#{winner[:TrainerName]} with #{winner[:PkmnName]} the #{winner[:PkmnSpecies]}!"), winnerSprite)
      end
      
    #==================
    # MASTER RANK
    #==================
    when "MasterCool"
      winner = @masterCoolWinner
      if winner.nil?
        pbMessage(_INTL("Nobody has won this contest recently..."))
      else
        species = winner[:PkmnSpecies]
        gender = winner[:PkmnGender]
        form = winner[:PkmnForm]
        shiny = winner[:PkmnShiny]
        winnerSprite = createWinnerBitmap(species, gender, form, shiny)
        pbMessageWinner(_INTL("\\f[test]<ac>Master Cool Contest Winner: \n#{winner[:TrainerName]} with #{winner[:PkmnName]} the #{winner[:PkmnSpecies]}!"), winnerSprite)
      end
    when "MasterBeauty"
      winner = @masterBeautyWinner
      if winner.nil?
        pbMessage(_INTL("Nobody has won this contest recently..."))
      else
        species = winner[:PkmnSpecies]
        gender = winner[:PkmnGender]
        form = winner[:PkmnForm]
        shiny = winner[:PkmnShiny]
        winnerSprite = createWinnerBitmap(species, gender, form, shiny)
        pbMessageWinner(_INTL("\\f[test]<ac>Master Beauty Contest Winner: \n#{winner[:TrainerName]} with #{winner[:PkmnName]} the #{winner[:PkmnSpecies]}!"), winnerSprite)
      end
    when "MasterCute"
      winner = @masterCuteWinner
      if winner.nil?
        pbMessage(_INTL("Nobody has won this contest recently..."))
      else
        species = winner[:PkmnSpecies]
        gender = winner[:PkmnGender]
        form = winner[:PkmnForm]
        shiny = winner[:PkmnShiny]
        winnerSprite = createWinnerBitmap(species, gender, form, shiny)
        pbMessageWinner(_INTL("\\f[test]<ac>Master Cute Contest Winner: \n#{winner[:TrainerName]} with #{winner[:PkmnName]} the #{winner[:PkmnSpecies]}!"), winnerSprite)
      end
    when "MasterSmart"
      winner = @masterSmartWinner
      if winner.nil?
        pbMessage(_INTL("Nobody has won this contest recently..."))
      else
        species = winner[:PkmnSpecies]
        gender = winner[:PkmnGender]
        form = winner[:PkmnForm]
        shiny = winner[:PkmnShiny]
        winnerSprite = createWinnerBitmap(species, gender, form, shiny)
        pbMessageWinner(_INTL("\\f[test]<ac>Master Smart Contest Winner: \n#{winner[:TrainerName]} with #{winner[:PkmnName]} the #{winner[:PkmnSpecies]}!"), winnerSprite)
      end
    when "MasterTough"
      winner = @masterToughWinner
      if winner.nil?
        pbMessage(_INTL("Nobody has won this contest recently..."))
      else
        species = winner[:PkmnSpecies]
        gender = winner[:PkmnGender]
        form = winner[:PkmnForm]
        shiny = winner[:PkmnShiny]
        winnerSprite = createWinnerBitmap(species, gender, form, shiny)
        pbMessageWinner(_INTL("\\f[test]<ac>Master Tough Contest Winner: \n#{winner[:TrainerName]} with #{winner[:PkmnName]} the #{winner[:PkmnSpecies]}!"), winnerSprite)
      end
    end #case arg
  end #def showWinner(arg)
  
  def createWinnerBitmap(species, gender, form, shiny)
    viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    winner = PokemonSprite.new(viewport)
    winner.setSpeciesBitmap(species, gender, form, shiny, false, false)
    winner.setOffset(PictureOrigin::CENTER)
    winner.visible = false
    return winner.bitmap
  end #createWinnerBitmap(species, gender, form, shiny)
  
  #===============================================================================
  # Main message-displaying function
  #===============================================================================
  def pbMessageWinner(message, sprite, commands = nil, cmdIfCancel = 0, skin = nil, defaultCmd = 0, &block)
    ret = 0
    msgwindow = pbCreateMessageWindow(nil, skin)
    if commands
      ret = pbMessageDisplayWinner(msgwindow, message, sprite, true,
                           proc { |msgwindow|
                             next Kernel.pbShowCommands(msgwindow, commands, cmdIfCancel, defaultCmd, &block)
                           }, &block)
    else
      pbMessageDisplayWinner(msgwindow, message, sprite, &block)
    end
    pbDisposeMessageWindow(msgwindow)
    Input.update
    return ret
  end
  
  def pbMessageDisplayWinner(msgwindow, message, sprite, letterbyletter = true, commandProc = nil)
    return if !msgwindow
    oldletterbyletter = msgwindow.letterbyletter
    msgwindow.letterbyletter = (letterbyletter) ? true : false
    ret = nil
    commands = nil
    facewindow = nil
    goldwindow = nil
    coinwindow = nil
    battlepointswindow = nil
    cmdvariable = 0
    cmdIfCancel = 0
    msgwindow.waitcount = 0
    autoresume = false
    text = message.clone
    msgback = nil
    linecount = (Graphics.height > 400) ? 3 : 2
    ### Text replacement
    text.gsub!(/\\sign\[([^\]]*)\]/i) {   # \sign[something] gets turned into
      next "\\op\\cl\\ts[]\\w[" + $1 + "]"    # \op\cl\ts[]\w[something]
    }
    text.gsub!(/\\\\/, "\5")
    text.gsub!(/\\1/, "\1")
    if $game_actors
      text.gsub!(/\\n\[([1-8])\]/i) {
        m = $1.to_i
        next $game_actors[m].name
      }
    end
    text.gsub!(/\\pn/i,  $player.name) if $player
    text.gsub!(/\\pm/i,  _INTL("${1}", $player.money.to_s_formatted)) if $player
    text.gsub!(/\\n/i,   "\n")
    text.gsub!(/\\\[([0-9a-f]{8,8})\]/i) { "<c2=" + $1 + ">" }
    text.gsub!(/\\pg/i,  "\\b") if $player&.male?
    text.gsub!(/\\pg/i,  "\\r") if $player&.female?
    text.gsub!(/\\pog/i, "\\r") if $player&.male?
    text.gsub!(/\\pog/i, "\\b") if $player&.female?
    text.gsub!(/\\pg/i,  "")
    text.gsub!(/\\pog/i, "")
    text.gsub!(/\\b/i,   "<c3=3050C8,D0D0C8>")
    text.gsub!(/\\r/i,   "<c3=E00808,D0D0C8>")
    text.gsub!(/\\[Ww]\[([^\]]*)\]/) {
      w = $1.to_s
      if w == ""
        msgwindow.windowskin = nil
      else
        msgwindow.setSkin("Graphics/Windowskins/#{w}", false)
      end
      next ""
    }
    isDarkSkin = isDarkWindowskin(msgwindow.windowskin)
    text.gsub!(/\\c\[([0-9]+)\]/i) {
      m = $1.to_i
      next getSkinColor(msgwindow.windowskin, m, isDarkSkin)
    }
    loop do
      last_text = text.clone
      text.gsub!(/\\v\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
      break if text == last_text
    end
    loop do
      last_text = text.clone
      text.gsub!(/\\l\[([0-9]+)\]/i) {
        linecount = [1, $1.to_i].max
        next ""
      }
      break if text == last_text
    end
    colortag = ""
    if $game_system && $game_system.message_frame != 0
      colortag = getSkinColor(msgwindow.windowskin, 0, true)
    else
      colortag = getSkinColor(msgwindow.windowskin, 0, isDarkSkin)
    end
    text = colortag + text
    ### Controls
    textchunks = []
    controls = []
    while text[/(?:\\(f|ff|ts|cl|me|se|wt|wtnp|ch)\[([^\]]*)\]|\\(g|cn|pt|wd|wm|op|cl|wu|\.|\||\!|\^))/i]
      textchunks.push($~.pre_match)
      if $~[1]
        controls.push([$~[1].downcase, $~[2], -1])
      else
        controls.push([$~[3].downcase, "", -1])
      end
      text = $~.post_match
    end
    textchunks.push(text)
    textchunks.each do |chunk|
      chunk.gsub!(/\005/, "\\")
    end
    textlen = 0
    controls.length.times do |i|
      control = controls[i][0]
      case control
      when "wt", "wtnp", ".", "|"
        textchunks[i] += "\2"
      when "!"
        textchunks[i] += "\1"
      end
      textlen += toUnformattedText(textchunks[i]).scan(/./m).length
      controls[i][2] = textlen
    end
    text = textchunks.join
    signWaitCount = 0
    signWaitTime = Graphics.frame_rate / 2
    haveSpecialClose = false
    specialCloseSE = ""
    startSE = nil
    controls.length.times do |i|
      control = controls[i][0]
      param = controls[i][1]
      case control
      when "op"
        signWaitCount = signWaitTime + 1
      when "cl"
        text = text.sub(/\001\z/, "")   # fix: '$' can match end of line as well
        haveSpecialClose = true
        specialCloseSE = param
      when "f"
        facewindow&.dispose
        #facewindow = PictureWindow.new("Graphics/Pictures/#{param}")
        #facewindow = PictureWindow.new(sprite)
      when "ff"
        facewindow&.dispose
        facewindow = FaceWindowVX.new(param)
      when "ch"
        cmds = param.clone
        cmdvariable = pbCsvPosInt!(cmds)
        cmdIfCancel = pbCsvField!(cmds).to_i
        commands = []
        while cmds.length > 0
          commands.push(pbCsvField!(cmds))
        end
      when "wtnp", "^"
        text = text.sub(/\001\z/, "")   # fix: '$' can match end of line as well
      when "se"
        if controls[i][2] == 0
          startSE = param
          controls[i] = nil
        end
      end
    end
    if startSE
      pbSEPlay(pbStringToAudioFile(startSE))
    elsif signWaitCount == 0 && letterbyletter
      pbPlayDecisionSE
    end
    ########## Position message window  ##############
    pbRepositionMessageWindow(msgwindow, linecount)
    if facewindow
      pbPositionNearMsgWindow(facewindow, msgwindow, :left)
      facewindow.viewport = msgwindow.viewport
      facewindow.z        = msgwindow.z
    end
    atTop = (msgwindow.y == 0)
    ########## Show text #############################
    msgwindow.text = text
    Graphics.frame_reset if Graphics.frame_rate > 40
    loop do
      if signWaitCount > 0
        signWaitCount -= 1
        if atTop
          msgwindow.y = -msgwindow.height * signWaitCount / signWaitTime
        else
          msgwindow.y = Graphics.height - (msgwindow.height * (signWaitTime - signWaitCount) / signWaitTime)
        end
      end
      controls.length.times do |i|
        next if !controls[i]
        next if controls[i][2] > msgwindow.position || msgwindow.waitcount != 0
        control = controls[i][0]
        param = controls[i][1]
        case control
        when "f"
          facewindow&.dispose
          #facewindow = PictureWindow.new("Graphics/Pictures/#{param}")
          facewindow = PictureWindow.new(sprite)
          pbPositionNearMsgWindowMod(facewindow, msgwindow, :center)
          facewindow.viewport = msgwindow.viewport
          facewindow.z        = msgwindow.z
        when "ff"
          facewindow&.dispose
          facewindow = FaceWindowVX.new(param)
          pbPositionNearMsgWindow(facewindow, msgwindow, :left)
          facewindow.viewport = msgwindow.viewport
          facewindow.z        = msgwindow.z
        when "g"      # Display gold window
          goldwindow&.dispose
          goldwindow = pbDisplayGoldWindow(msgwindow)
       when "cn"     # Display coins window
          coinwindow&.dispose
          coinwindow = pbDisplayCoinsWindow(msgwindow, goldwindow)
        when "pt"     # Display battle points window
          battlepointswindow&.dispose
          battlepointswindow = pbDisplayBattlePointsWindow(msgwindow)
        when "wu"
          msgwindow.y = 0
          atTop = true
          msgback.y = msgwindow.y if msgback
          pbPositionNearMsgWindow(facewindow, msgwindow, :left)
          msgwindow.y = -msgwindow.height * signWaitCount / signWaitTime
        when "wm"
          atTop = false
          msgwindow.y = (Graphics.height - msgwindow.height) / 2
          msgback.y = msgwindow.y if msgback
          pbPositionNearMsgWindow(facewindow, msgwindow, :left)
        when "wd"
          atTop = false
          msgwindow.y = Graphics.height - msgwindow.height
          msgback.y = msgwindow.y if msgback
          pbPositionNearMsgWindow(facewindow, msgwindow, :left)
          msgwindow.y = Graphics.height - (msgwindow.height * (signWaitTime - signWaitCount) / signWaitTime)
        when "ts"     # Change text speed
          msgwindow.textspeed = (param == "") ? -999 : param.to_i
        when "."      # Wait 0.25 seconds
          msgwindow.waitcount += Graphics.frame_rate / 4
        when "|"      # Wait 1 second
          msgwindow.waitcount += Graphics.frame_rate
        when "wt"     # Wait X/20 seconds
          param = param.sub(/\A\s+/, "").sub(/\s+\z/, "")
          msgwindow.waitcount += param.to_i * Graphics.frame_rate / 20
        when "wtnp"   # Wait X/20 seconds, no pause
          param = param.sub(/\A\s+/, "").sub(/\s+\z/, "")
          msgwindow.waitcount = param.to_i * Graphics.frame_rate / 20
          autoresume = true
        when "^"      # Wait, no pause
          autoresume = true
        when "se"     # Play SE
          pbSEPlay(pbStringToAudioFile(param))
        when "me"     # Play ME
          pbMEPlay(pbStringToAudioFile(param))
        end
        controls[i] = nil
      end
      break if !letterbyletter
      Graphics.update
      Input.update
      facewindow&.update
      if autoresume && msgwindow.waitcount == 0
        msgwindow.resume if msgwindow.busy?
        break if !msgwindow.busy?
      end
      if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
        if msgwindow.busy?
          pbPlayDecisionSE if msgwindow.pausing?
          msgwindow.resume
        elsif signWaitCount == 0
          break
        end
      end
      pbUpdateSceneMap
      msgwindow.update
      yield if block_given?
      break if (!letterbyletter || commandProc || commands) && !msgwindow.busy?
    end
    Input.update   # Must call Input.update again to avoid extra triggers
    msgwindow.letterbyletter = oldletterbyletter
    if commands
      $game_variables[cmdvariable] = pbShowCommands(msgwindow, commands, cmdIfCancel)
      $game_map.need_refresh = true if $game_map
    end
    if commandProc
      ret = commandProc.call(msgwindow)
    end
    msgback&.dispose
    goldwindow&.dispose
    coinwindow&.dispose
    battlepointswindow&.dispose
    facewindow&.dispose
    if haveSpecialClose
      pbSEPlay(pbStringToAudioFile(specialCloseSE))
      atTop = (msgwindow.y == 0)
      (0..signWaitTime).each do |i|
        if atTop
          msgwindow.y = -msgwindow.height * i / signWaitTime
        else
          msgwindow.y = Graphics.height - (msgwindow.height * (signWaitTime - i) / signWaitTime)
        end
        Graphics.update
        Input.update
        pbUpdateSceneMap
        msgwindow.update
      end
    end
    return ret
  end #def pbMessageDisplayWinner
  
  def pbPositionNearMsgWindowMod(cmdwindow, msgwindow, side)
    return if !cmdwindow
    if msgwindow
      height = [cmdwindow.height, Graphics.height - msgwindow.height].min
      if cmdwindow.height != height
        cmdwindow.height = height
      end
      cmdwindow.y = msgwindow.y - cmdwindow.height
      if cmdwindow.y < 0
        cmdwindow.y = msgwindow.y + msgwindow.height
        if cmdwindow.y + cmdwindow.height > Graphics.height
          cmdwindow.y = msgwindow.y - cmdwindow.height
        end
      end
      case side
      when :left
        cmdwindow.x = msgwindow.x
      when :right
        cmdwindow.x = msgwindow.x + msgwindow.width - cmdwindow.width
      when :center
        cmdwindow.x = msgwindow.x + msgwindow.width/2 - cmdwindow.width/2
      else
        cmdwindow.x = msgwindow.x + msgwindow.width - cmdwindow.width
      end
    else
      cmdwindow.height = Graphics.height if cmdwindow.height > Graphics.height
      cmdwindow.x = 0
      cmdwindow.y = 0
    end
  end
  
end #class Contest_Save_Data