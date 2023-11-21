alias _rfMessageDisplay pbMessageDisplay

#===============================================================================
# Main message-displaying function
#===============================================================================
def pbMessageDisplay(msgwindow, message, letterbyletter = true, commandProc = nil, &block)
  return if !msgwindow
  namewindow=nil
  speakername = $game_temp.speaker
  if speakername
    namewindow = Window_UnformattedTextPokemon.new(speakername)
    namewindow.resizeToFit(speakername)
    # move it
    pbPositionNearMsgWindow(namewindow,msgwindow,:left)
    namewindow.viewport=msgwindow.viewport
    namewindow.x += 24
    namewindow.y += 16
    namewindow.z=msgwindow.z
  end
  ret = _rfMessageDisplay(msgwindow, message, letterbyletter, commandProc, &block)
  namewindow&.dispose
  return ret
end