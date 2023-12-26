#This page was created by Gardenette to keep all scripts used in Project Untamed
#that redefine "pbMessageDisplay" working by keeping "pbMessageDisplay" in one
#area where we can keep track of it and changes

def pbMessageDisplay(msgwindow,message,letterbyletter=true,commandProc=nil)
  return if !msgwindow
  oldletterbyletter=msgwindow.letterbyletter
  msgwindow.letterbyletter=(letterbyletter) ? true : false
  ret=nil
  
  
  #=======GELANAME2=======
      count=0
  #=======GELANAME2=======  
 
  commands=nil
  facewindow=nil
 
  #======GELA FACE2=================
  facewindowL=nil
  facewindowR=nil
  #=====GELA FACE2==================
 
  goldwindow=nil
  coinwindow=nil
  
  
  
  #from text skip script
  battlepointswindow=nil
  ###################
  
  
 
  #=======GELANAME3=======
       namewindow=nil
  #=======GELANAME3=======  
 
  cmdvariable=0
  cmdIfCancel=0
  msgwindow.waitcount=0
  autoresume=false
  text=message.clone
  msgback=nil
  linecount=(Graphics.height>400) ? 3 : 2
  ### Text replacement
  text.gsub!(/\\sign\[([^\]]*)\]/i) {   # \sign[something] gets turned into
    next "\\op\\cl\\ts[]\\w["+$1+"]"    # \op\cl\ts[]\w[something]
  }
  text.gsub!(/\\\\/,"\5")
  text.gsub!(/\\1/,"\1")
  if $game_actors
    text.gsub!(/\\n\[([1-8])\]/i) {
      m = $1.to_i
      next $game_actors[m].name
    }
  end
  text.gsub!(/\\pn/i,$Trainer.name) if $Trainer
  text.gsub!(/\\pm/i,_INTL("${1}",$Trainer.money.to_s_formatted)) if $Trainer
  text.gsub!(/\\n/i,"\n")
  text.gsub!(/\\\[([0-9a-f]{8,8})\]/i) { "<c2="+$1+">" }
  text.gsub!(/\\pg/i,"\\b") if $Trainer && $Trainer.male?
  text.gsub!(/\\pg/i,"\\r") if $Trainer && $Trainer.female?
  text.gsub!(/\\pog/i,"\\r") if $Trainer && $Trainer.male?
  text.gsub!(/\\pog/i,"\\b") if $Trainer && $Trainer.female?
  text.gsub!(/\\pg/i,"")
  text.gsub!(/\\pog/i,"")
  text.gsub!(/\\b/i,"<c3=3050C8,D0D0C8>")
  text.gsub!(/\\r/i,"<c3=E00808,D0D0C8>")
  
  
    #from pronouns script
  if $Trainer
          if $Trainer.themself
            if $Trainer.is==true
              text.gsub!(/\\hes/i,_INTL("{1}'s",$Trainer.they.downcase))
              text.gsub!(/\\uheis/i,_INTL("{1} is",$Trainer.they.capitalize))
              text.gsub!(/\\heis/i,_INTL("{1} is",$Trainer.they.downcase))
              text.gsub!(/\\uhes/i,_INTL("{1}'s",$Trainer.they.capitalize))
            end
            if $Trainer.is==false
              text.gsub!(/\\hes/i,_INTL("{1}'re",$Trainer.they.downcase))
              text.gsub!(/\\heis/i,_INTL("{1} are",$Trainer.they.downcase))
              text.gsub!(/\\uhes/i,_INTL("{1}'re",$Trainer.they.capitalize))
              text.gsub!(/\\uheis/i,_INTL("{1} are",$Trainer.they.capitalize))
            end
          text.gsub!(/\\he/i,$Trainer.they.downcase)
          text.gsub!(/\\uhe/i,$Trainer.they.capitalize)
          text.gsub!(/\\him/i,$Trainer.them.downcase)
          text.gsub!(/\\uhim/i,$Trainer.them.capitalize)
          text.gsub!(/\\his/i,$Trainer.their.downcase)
          text.gsub!(/\\uhis/i,$Trainer.their.capitalize)
          text.gsub!(/\\hrs/i,$Trainer.theirs.downcase)
          text.gsub!(/\\uhrs/i,$Trainer.theirs.capitalize)
          text.gsub!(/\\slf/i,$Trainer.themself.downcase)
          text.gsub!(/\\uslf/i,$Trainer.themself.capitalize)
          text.gsub!(/\\oa/o,$Trainer.conjugation.downcase)
          text.gsub!(/\\man/i,$Trainer.person.downcase)
          text.gsub!(/\\uman/i,$Trainer.person.capitalize)
        end
      end
  #####################################
  
  
  
  #from text skip script
    text.gsub!(/\\[Ww]\[([^\]]*)\]/) {
    w = $1.to_s
    if w==""
      msgwindow.windowskin = nil
    else
      msgwindow.setSkin("Graphics/Windowskins/#{w}",false)
    end
    next ""
  }  
  ############################3
  
  
  
  isDarkSkin = isDarkWindowskin(msgwindow.windowskin)
  text.gsub!(/\\[Cc]\[([0-9]+)\]/) {
    m = $1.to_i
    next getSkinColor(msgwindow.windowskin,m,isDarkSkin)
  }
  loop do
    last_text = text.clone
    text.gsub!(/\\v\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    break if text == last_text
  end
  loop do
    last_text = text.clone
    text.gsub!(/\\l\[([0-9]+)\]/i) {
      linecount = [1,$1.to_i].max
      next ""
    }
    break if text == last_text
  end
  colortag = ""

  if ($game_message && $game_message.background>0) || ($game_message && $game_message.background>0) ||($game_system && $game_system.respond_to?("message_frame") && $game_system.message_frame != 0)
    colortag = getSkinColor(msgwindow.windowskin,0,true)
  else
    colortag = getSkinColor(msgwindow.windowskin,0,isDarkSkin)
  end
  text = colortag+text
  ### Controls
  textchunks=[]
  controls=[]
  #==========GELA FACE, ADDING PORTRAIT CATCH, BASICALLY MR, ML ETC===========
  while text[/(?:\\(w|f|ff|ts|xn|cl|me|ml|mr|se|wt|wtnp|ch)\[([^\]]*)\]|\\(g|cn|pt|wd|wm|op|cl|wu|\.|\||\!|\^))/i]
    textchunks.push($~.pre_match)
  #==========GELA FACE, ADDING PORTRAIT CODES===========
    if $~[1]
      controls.push([$~[1].downcase,$~[2],-1])
    else
      controls.push([$~[3].downcase,"",-1])
    end
    text=$~.post_match
  end
  textchunks.push(text)
  for chunk in textchunks
    chunk.gsub!(/\005/,"\\")
  end
  textlen = 0
  for i in 0...controls.length
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
  text = textchunks.join("")
  unformattedText = toUnformattedText(text)
  signWaitCount = 0
  signWaitTime = Graphics.frame_rate/2
  haveSpecialClose = false
  specialCloseSE = ""
  for i in 0...controls.length
    control = controls[i][0]
    param = controls[i][1]
    case control
    when "op"
      signWaitCount = signWaitTime+1
    when "cl"
      text = text.sub(/\001\z/,"")   # fix: '$' can match end of line as well
      haveSpecialClose = true
      specialCloseSE = param


    #from text skip script
    when "f"
      facewindow.dispose if facewindow
      facewindow = PictureWindow.new("Graphics/Pictures/#{param}")
    when "ff"
      facewindow.dispose if facewindow
      facewindow = FaceWindowVX.new(param)
    ###########################3
      
      
    when "ch"
      cmds = param.clone
      cmdvariable = pbCsvPosInt!(cmds)
      cmdIfCancel = pbCsvField!(cmds).to_i
      commands = []
      while cmds.length>0
        commands.push(pbCsvField!(cmds))
      end
    when "wtnp", "^"
      text = text.sub(/\001\z/,"")   # fix: '$' can match end of line as well
    when "se"
      if controls[i][2]==0
        startSE = param
        controls[i] = nil
      end
    end
  end
  if startSE!=nil
    pbSEPlay(pbStringToAudioFile(startSE))
  elsif signWaitCount==0 && letterbyletter
    pbPlayDecisionSE()
  end
  ########## Position message window  ##############
  pbRepositionMessageWindow(msgwindow,linecount)
  if $game_message && $game_message.background==1
    msgback = IconSprite.new(0,msgwindow.y,msgwindow.viewport)
    msgback.z = msgwindow.z-1
    msgback.setBitmap("Graphics/System/MessageBack")
  end
 
 
  #==============GELA FACE3=========================================================
if facewindowL
    facewindowL.viewport=msgwindow.viewport
    facewindowL.z=msgwindow.z
  end
  if facewindowR
    facewindowR.viewport=msgwindow.viewport
    facewindowR.z=msgwindow.z
    end
  #===============GELA FACE3========================================================
 
 
  #from text skip script
  if facewindow
    pbPositionNearMsgWindow(facewindow,msgwindow,:left)
    facewindow.viewport = msgwindow.viewport
    facewindow.z        = msgwindow.z
  end
  
  ##################################################3
  
  
  atTop = (msgwindow.y==0)
  ########## Show text #############################
  msgwindow.text = text
  # ===============change this to the framerate your game is using ??
  Graphics.frame_reset if Graphics.frame_rate>40
 # ===============change this to the framerate your game is using ??
  loop do
    if signWaitCount>0
      signWaitCount -= 1
      if atTop
        msgwindow.y = -msgwindow.height*signWaitCount/signWaitTime
      else
        msgwindow.y = Graphics.height-msgwindow.height*(signWaitTime-signWaitCount)/signWaitTime
      end
    end
    for i in 0...controls.length
      next if !controls[i]
      next if controls[i][2]>msgwindow.position || msgwindow.waitcount!=0
      control = controls[i][0]
      param = controls[i][1]
      case control
#===========GELANAME4=========
      # NEW
        when "xn"
          # Show name box, based on #{param}
          namewindow.dispose if namewindow
          namewindow=pbDisplayNameWindow(msgwindow,dark=false,param)
        when "dxn"
          # Show name box, based on #{param}
          namewindow.dispose if namewindow
          namewindow=pbDisplayNameWindow(msgwindow,dark=true,param)
#===========GELANAME4=========                                                          
      when "f"
        facewindow.dispose if facewindow
        facewindow = PictureWindow.new("Graphics/Pictures/#{param}")
        pbPositionNearMsgWindow(facewindow,msgwindow,:left)
        facewindow.viewport = msgwindow.viewport
        facewindow.z        = msgwindow.z


        #from text skip script
        when "ff"
        facewindow.dispose if facewindow
        facewindow = FaceWindowVX.new(param)
        ##########################
        
        
       
#====================GELA FACE4==================================
        when "ml" # Mug Shot (Left)
          facewindowL.dispose if facewindowL
          facewindowL=FaceWindowVXNew.new(param)
          facewindowL.windowskin=nil
          facewindowL.x=8
          facewindowL.y=148-32  #changes in Y position. Adjust accordingly
          facewindowL.viewport=msgwindow.viewport
          facewindowL.z=msgwindow.z
        when "mr" # Mug Shot (Right)
          facewindowR.dispose if facewindowR
          
          facewindowR=FaceWindowVXNew.new(param)
          facewindowR.windowskin=nil
          facewindowR.x=320
          facewindowR.y=148-32  #changes in Y position. Adjust accordingly
          facewindowR.viewport=msgwindow.viewport
          #facewindowR.z=msgwindow.z
          
          #added by Gardenette to make portrait full
          facewindowR.z=msgwindow.z-1
          
        when "ff"
          facewindow.dispose if facewindow
          facewindow = FaceWindowVX.new(param)
          facewindow.x=320
          facewindow.y=148-32  #changes in Y position. Adjust accordingly
#==================GELA FACE4=======================


        pbPositionNearMsgWindow(facewindow,msgwindow,:left)
        facewindow.viewport = msgwindow.viewport
        facewindow.z        = msgwindow.z
       
      when "g"      # Display gold window
        goldwindow.dispose if goldwindow
        goldwindow = pbDisplayGoldWindow(msgwindow)
      when "cn"     # Display coins window
        coinwindow.dispose if coinwindow
        coinwindow = pbDisplayCoinsWindow(msgwindow,goldwindow)
        
        
        #from text skip script
        when "pt"     # Display battle points window
        battlepointswindow.dispose if battlepointswindow
        battlepointswindow = pbDisplayBattlePointsWindow(msgwindow)
        ######################
        
        
      when "wu"
        msgwindow.y = 0
        atTop = true
        msgback.y = msgwindow.y if msgback
        pbPositionNearMsgWindow(facewindow,msgwindow,:left)
        msgwindow.y = -msgwindow.height*signWaitCount/signWaitTime
      when "wm"
        atTop = false
        msgwindow.y = (Graphics.height-msgwindow.height)/2
        msgback.y = msgwindow.y if msgback
        pbPositionNearMsgWindow(facewindow,msgwindow,:left)
      when "wd"
        atTop = false
        msgwindow.y = Graphics.height-msgwindow.height
        msgback.y = msgwindow.y if msgback
        pbPositionNearMsgWindow(facewindow,msgwindow,:left)
        msgwindow.y = Graphics.height-msgwindow.height*(signWaitTime-signWaitCount)/signWaitTime
      when "w"      # Change windowskin
        if param==""
          msgwindow.windowskin = nil
        else
          msgwindow.setSkin("Graphics/Windowskins/#{param}",false)
        end
      when "ts"     # Change text speed
        msgwindow.textspeed = (param=="") ? -999 : param.to_i
      when "."      # Wait 0.25 seconds
        msgwindow.waitcount += Graphics.frame_rate/4
      when "|"      # Wait 1 second
        msgwindow.waitcount += Graphics.frame_rate
      when "wt"     # Wait X/20 seconds
        param = param.sub(/\A\s+/,"").sub(/\s+\z/,"")
        msgwindow.waitcount += param.to_i*Graphics.frame_rate/20
      when "wtnp"   # Wait X/20 seconds, no pause
        param = param.sub(/\A\s+/,"").sub(/\s+\z/,"")
        msgwindow.waitcount = param.to_i*Graphics.frame_rate/20
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
    facewindow.update if facewindow
    #===================GELA FACE5===============================
        facewindowL.update if facewindowL
        facewindowR.update if facewindowR
#===================GELA FACE5===============================
    if $DEBUG && Input.trigger?(Input::F6)
      pbRecord(unformattedText)
    end
    if autoresume && msgwindow.waitcount==0
      msgwindow.resume if msgwindow.busy?
      break if !msgwindow.busy?
    end
#===============================================
    ########## Text Skipping #######################
    if $PokemonSystem.text_skip
      if Input.press?(TEXT_SKIP_BUTTON)
        msgwindow.textspeed=-999
        msgwindow.update
        if msgwindow.busy?
          pbPlayDecisionSE() if msgwindow.pausing?
          msgwindow.resume
        else
          break if signWaitCount==0
        end
      end
    end
  ############################################3
    
    
    
    if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
      if msgwindow.busy?
        pbPlayDecisionSE if msgwindow.pausing?
        msgwindow.resume
      else
        break if signWaitCount==0
      end
    end
    pbUpdateSceneMap
    msgwindow.update
    yield if block_given?
    break if (!letterbyletter || commandProc || commands) && !msgwindow.busy?
  end
  Input.update   # Must call Input.update again to avoid extra triggers
  msgwindow.letterbyletter=oldletterbyletter
  if commands
    $game_variables[cmdvariable]=pbShowCommands(msgwindow,commands,cmdIfCancel)
    $game_map.need_refresh = true if $game_map
  end
  if commandProc
    ret=commandProc.call(msgwindow)
  end
  msgback.dispose if msgback
 #======GELANAME5==========
  # NEW
  namewindow.dispose if namewindow    
 #======GELANAME5==========
 
  goldwindow.dispose if goldwindow
  #==========GELA FACE6===================================
    facewindowL.dispose if facewindowL
    facewindowR.dispose if facewindowR
  #============GELA FACE6=================================
  coinwindow.dispose if coinwindow
  
  #from text skip script
  battlepointswindow.dispose if battlepointswindow
  #########################
  
  facewindow.dispose if facewindow
  if haveSpecialClose
    pbSEPlay(pbStringToAudioFile(specialCloseSE))
    atTop = (msgwindow.y==0)
    for i in 0..signWaitTime
      if atTop
        msgwindow.y = -msgwindow.height*i/signWaitTime
      else
        msgwindow.y = Graphics.height-msgwindow.height*(signWaitTime-i)/signWaitTime
      end
      Graphics.update
      Input.update
      pbUpdateSceneMap
      msgwindow.update
    end
  end
  return ret
end