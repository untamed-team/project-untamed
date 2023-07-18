def animationEditorMain(animation)
  viewport = Viewport.new(0, 0, Settings::SCREEN_WIDTH + 288, Settings::SCREEN_HEIGHT + 288)
  viewport.z = 99999
  # Canvas
  canvas = AnimationCanvas.new(animation[animation.selected] || animation[0], viewport)
  # Right hand menu
  sidewin = ControlWindow.new(512 + 128, 0, 160, 384 + 128)
  sidewin.addButton(_INTL("SE and BG..."))
  sidewin.addButton(_INTL("Cel Focus..."))
  sidewin.addSpace
  sidewin.addButton(_INTL("Paste Last"))
  sidewin.addButton(_INTL("Copy Frames..."))
  sidewin.addButton(_INTL("Clear Frames..."))
  sidewin.addButton(_INTL("Tweening..."))
  sidewin.addButton(_INTL("Cel Batch..."))
  sidewin.addButton(_INTL("Entire Slide..."))
  sidewin.addSpace
  sidewin.addButton(_INTL("Play Animation"))
  sidewin.addButton(_INTL("Play Opp Anim"))
  sidewin.addButton(_INTL("Import Anim..."))
  sidewin.addButton(_INTL("Export Anim..."))
  sidewin.addButton(_INTL("Help"))
  sidewin.viewport = canvas.viewport
  # Bottom left menu
  sliderwin = ControlWindow.new(0, 384 + 128, 240, 160)
  sliderwin.addControl(FrameCountSlider.new(canvas))
  sliderwin.addControl(FrameCountButton.new(canvas))
  sliderwin.addButton(_INTL("Set Animation Sheet"))
  sliderwin.addButton(_INTL("List of Animations"))
  sliderwin.viewport = canvas.viewport
  # Animation sheet window
  animwin = CanvasAnimationWindow.new(canvas, 240, 384 + 128, 512, 96, canvas.viewport)
  # Name window
  bottomwindow = AnimationNameWindow.new(canvas, 240, 384 + 128 + 96, 512, 64, canvas.viewport)
  loop do
    Graphics.update
    Input.update
    sliderwin.update
    canvas.update
    sidewin.update
    animwin.update
    bottomwindow.update
    if animwin.changed?
      canvas.pattern = animwin.selected
    end
    if Input.trigger?(Input::BACK)
      if pbConfirmMessage(_INTL("Save changes?"))
        save_data(animation, "Data/PkmnAnimations.rxdata")
      end
      if pbConfirmMessage(_INTL("Exit from the editor?"))
        $game_temp.battle_animations_data = nil
        break
      end
    end
    if Input.triggerex?(:F5)
      pbAnimEditorHelpWindow
      next
    elsif Input.trigger?(Input::MOUSERIGHT) && sliderwin.hittest?(0)   # Right mouse button
      commands = [
        _INTL("Copy Frame"),
        _INTL("Paste Frame"),
        _INTL("Clear Frame"),
        _INTL("Insert Frame"),
        _INTL("Delete Frame")
      ]
      hit = pbTrackPopupMenu(commands)
      case hit
      when 0 # Copy
        if canvas.currentframe >= 0
          Clipboard.setData(canvas.animation[canvas.currentframe], "PBAnimFrame")
        end
      when 1 # Paste
        if canvas.currentframe >= 0
          canvas.pasteFrame(canvas.currentframe)
        end
      when 2 # Clear Frame
        canvas.clearFrame(canvas.currentframe)
      when 3 # Insert Frame
        canvas.insertFrame(canvas.currentframe)
        sliderwin.invalidate
      when 4 # Delete Frame
        canvas.deleteFrame(canvas.currentframe)
        sliderwin.controls[0].curvalue = canvas.currentframe + 1
        sliderwin.invalidate
      end
      next
    elsif Input.triggerex?(:Q)
      if canvas.currentCel
        pbDefinePath(canvas)
        sliderwin.invalidate
      end
      next
    elsif Input.trigger?(Input::MOUSERIGHT)  # Right mouse button
      mousepos = Mouse.getMousePos
      mousepos = [0, 0] if !mousepos
      commands = [
        _INTL("Properties..."),
        _INTL("Cut"),
        _INTL("Copy"),
        _INTL("Paste"),
        _INTL("Delete"),
        _INTL("Renumber..."),
        _INTL("Extrapolate Path...")
      ]
      hit = pbTrackPopupMenu(commands)
      case hit
      when 0 # Properties
        if canvas.currentCel
          pbCellProperties(canvas)
          canvas.invalidateCel(canvas.currentcel)
        end
      when 1 # Cut
        if canvas.currentCel
          Clipboard.setData(canvas.currentCel, "PBAnimCel")
          canvas.deleteCel(canvas.currentcel)
        end
      when 2 # Copy
        if canvas.currentCel
          Clipboard.setData(canvas.currentCel, "PBAnimCel")
        end
      when 3 # Paste
        canvas.pasteCel(mousepos[0], mousepos[1])
      when 4 # Delete
        canvas.deleteCel(canvas.currentcel)
      when 5 # Renumber
        if canvas.currentcel && canvas.currentcel >= 2
          cel1 = canvas.currentcel
          cel2 = pbChooseNum(cel1)
          if cel2 >= 2 && cel1 != cel2
            canvas.swapCels(cel1, cel2)
          end
        end
      when 6 # Extrapolate Path
        if canvas.currentCel
          pbDefinePath(canvas)
          sliderwin.invalidate
        end
      end
      next
    end
    if sliderwin.changed?(0) # Current frame changed
      canvas.currentframe = sliderwin.value(0) - 1
    end
    if sliderwin.changed?(1) # Change frame count
      pbChangeMaximum(canvas)
      if canvas.currentframe >= canvas.animation.length
        canvas.currentframe = canvas.animation.length - 1
        sliderwin.controls[0].curvalue = canvas.currentframe + 1
      end
      sliderwin.refresh
    end
    if sliderwin.changed?(2) # Set Animation Sheet
      pbSelectAnim(canvas, animwin)
      animwin.refresh
      sliderwin.refresh
    end
    if sliderwin.changed?(3) # List of Animations
      pbAnimList(animation, canvas, animwin)
      sliderwin.controls[0].curvalue = canvas.currentframe + 1
      bottomwindow.refresh
      animwin.refresh
      sliderwin.refresh
    end
    pbTimingList(canvas) if sidewin.changed?(0)
    if sidewin.changed?(1)
      positions = [_INTL("User"), _INTL("Target"), _INTL("User and target"), _INTL("Screen")]
      indexes = [2, 1, 3, 4] # Keeping backwards compatibility
      positions.length.times do |i|
        selected = "[  ]"
        if animation[animation.selected].position == indexes[i]
          selected = "[x]"
        end
        positions[i] = sprintf("%s %s", selected, positions[i])
      end
      pos = pbShowCommands(nil, positions, -1)
      if pos >= 0
        animation[animation.selected].position = indexes[pos]
        canvas.update
      end
    end
    canvas.pasteLast if sidewin.changed?(3)
    pbCopyFrames(canvas) if sidewin.changed?(4)
    pbClearFrames(canvas) if sidewin.changed?(5)
    pbTweening(canvas) if sidewin.changed?(6)
    pbCellBatch(canvas) if sidewin.changed?(7)
    pbEntireSlide(canvas) if sidewin.changed?(8)
    canvas.play if sidewin.changed?(10)
    canvas.play(true) if sidewin.changed?(11)
    if sidewin.changed?(12)
      pbImportAnim(animation, canvas, animwin)
      sliderwin.controls[0].curvalue = canvas.currentframe + 1
      bottomwindow.refresh
      animwin.refresh
      sliderwin.refresh
    end
    if sidewin.changed?(13)
      pbExportAnim(animation)
      bottomwindow.refresh
      animwin.refresh
      sliderwin.refresh
    end
    pbAnimEditorHelpWindow if sidewin.changed?(14)
  end
  canvas.dispose
  animwin.dispose
  sliderwin.dispose
  sidewin.dispose
  bottomwindow.dispose
  viewport.dispose
  RPG::Cache.clear
end
