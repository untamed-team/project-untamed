
def pbAnimList(animations, canvas, animwin, searchedIds = [])
  commands = []
  length = searchedIds.length
  length = animations.length if searchedIds.length < 1
  for i in 0..length-1
    j = i
    j = searchedIds[i] if searchedIds.length > 0
    if j == nil
      #pbMessage(_INTL("Error: tried iterating {1} times when array is\n{2}", i, searchedIds.to_s))
      break
    end
    animations[j] = PBAnimation.new if !animations[j]
    commands[commands.length] = _INTL("{1} {2}", j, animations[j].name)
  end
  cmdwin = pbListWindow(commands, 320)
  cmdwin.height = 416
  cmdwin.opacity = 224
  cmdwin.index = 0
  cmdwin.index = animations.selected if searchedIds.length < 1
  cmdwin.viewport = canvas.viewport
  helpwindow = Window_UnformattedTextPokemon.newWithSize(
    _INTL("Enter: Load/rename an animation\nF: Open search bar\nEsc: Cancel"),
    320, 0, 320, 160, canvas.viewport #128
  )
  maxsizewindow = ControlWindow.new(0, 416, 320, 32 * 3)
  if searchedIds.length < 1
    maxsizewindow.addSlider(_INTL("Total Animations:"), 1, 2000, animations.length)
    maxsizewindow.addButton(_INTL("Resize Animation List"))
    maxsizewindow.opacity = 224
    maxsizewindow.viewport = canvas.viewport
  end
  newSearch = []
  loop do
    Graphics.update
    Input.update
    cmdwin.update
    maxsizewindow.update if searchedIds.length < 1
    helpwindow.update
    if searchedIds.length < 1 && maxsizewindow.changed?(1)
      newsize = maxsizewindow.value(0)
      animations.resize(newsize)
      commands.clear
      for i in 0..length #animations.length.times do |i|
        j = i
        j = searchedIds[i] if searchedIds.length > 0
        commands[commands.length] = _INTL("{1} {2}", j, animations[j].name)
      end
      cmdwin.commands = commands
      cmdwin.index = 0
      cmdwin.index = animations.selected if searchedIds.length < 1
      next
    end
    if Input.triggerex?(:F)
        newSearch = pbOpenMoveSearch(animations, canvas, animwin, searchedIds)
        break if newSearch != false && newSearch != nil && newSearch.length > 0
    end
    if Input.trigger?(Input::USE) && animations.length > 0
      cmd2 = pbShowCommands(helpwindow,
                            [_INTL("Load Animation"),
                             _INTL("Rename"),
                             _INTL("Delete")], -1)
      case cmd2
      when 0 # Load Animation
        i = cmdwin.index
        i = searchedIds[cmdwin.index] if searchedIds.length > 0
        canvas.loadAnimation(animations[i])
        animwin.animbitmap = canvas.animbitmap
        animations.selected = i
        break
      when 1 # Rename
        i = cmdwin.index
        i = searchedIds[cmdwin.index] if searchedIds.length > 0
        pbAnimName(animations[i], cmdwin)
        cmdwin.refresh
      when 2 # Delete
        if pbConfirmMessage(_INTL("Are you sure you want to delete this animation?"))
          i = cmdwin.index
          i = searchedIds[cmdwin.index] if searchedIds.length > 0
          animations[i] = PBAnimation.new
          cmdwin.commands[i] = _INTL("{1} {2}", i, animations[i].name)
          cmdwin.refresh
        end
      end
    end
    if Input.trigger?(Input::BACK)
      break
    end
  end
  helpwindow.dispose
  maxsizewindow.dispose
  cmdwin.dispose
  pbAnimList(animations, canvas, animwin, newSearch) if newSearch.length > 0
end
