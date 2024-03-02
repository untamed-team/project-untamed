def pbMessageContest(message, commands = nil, cmdIfCancel = 0, skin = nil, defaultCmd = 0, clear=true, &block)
  ret = 0
  msgwindow = pbCreateMessageWindowContest(nil, skin)
  #if commands
  #  ret = pbMessageDisplay(msgwindow, message, true,
  #                         proc { |msgwindow|
  #                           next Kernel.pbShowCommands(msgwindow, commands, cmdIfCancel, defaultCmd, &block)
  #                         }, &block)
  #else
    pbMessageDisplay(msgwindow, message, &block)
  #end
  pbDisposeMessageWindow(msgwindow) if clear != false
  Input.update
  #return ret
  return msgwindow
end

def pbCreateMessageWindowContest(viewport = nil, skin = nil)
  msgwindow = Window_AdvancedTextPokemon.new("")
  if viewport
    msgwindow.viewport = viewport
  else
    msgwindow.z = 999999
  end
  msgwindow.visible = true
  msgwindow.letterbyletter = true
  msgwindow.back_opacity = MessageConfig::WINDOW_OPACITY
  pbBottomRightWindow(msgwindow, 2, nil)
  $game_temp.message_window_showing = true if $game_temp
  skin = nil
  msgwindow.setSkin(skin)
  msgwindow.opacity = 0
  return msgwindow
end

def pbBottomRightWindow(window, lines, width = nil)
  window.x = 160
  window.width = Graphics.width - window.x
  window.height = (window.borderY rescue 32) + (lines * 32)
  window.y = Graphics.height - window.height
end