def pbTweening(canvas)
  sliderwin2 = ControlWindow.new(0, 0, 320, 32 * 10)
  sliderwin2.viewport = canvas.viewport
  sliderwin2.opacity = 200
  s1set0 = sliderwin2.addSlider(_INTL("Starting Frame:"), 1, canvas.animation.length, 1)
  s1set1 = sliderwin2.addSlider(_INTL("Ending Frame:"), 1, canvas.animation.length, canvas.animation.length)
  s1set2 = sliderwin2.addSlider(_INTL("First Cel:"), 0, PBAnimation::MAX_SPRITES - 1, 0)
  s1set3 = sliderwin2.addSlider(_INTL("Last Cel:"), 0, PBAnimation::MAX_SPRITES - 1, PBAnimation::MAX_SPRITES - 1)
  set0 = sliderwin2.addCheckbox(_INTL("Pattern"))
  set1 = sliderwin2.addCheckbox(_INTL("Position/Zoom/Angle"))
  set2 = sliderwin2.addCheckbox(_INTL("Opacity/Blending"))
  set3 = sliderwin2.addCheckbox(_INTL("Color"))
  okbutton = sliderwin2.addButton(_INTL("OK"))
  cancelbutton = sliderwin2.addButton(_INTL("Cancel"))
  loop do
    Graphics.update
    Input.update
    sliderwin2.update
    if sliderwin2.changed?(okbutton) || Input.trigger?(Input::USE)
      startframe = sliderwin2.value(s1set0) - 1
      endframe = sliderwin2.value(s1set1) - 1
      break if startframe >= endframe
      frames = endframe - startframe
      startcel = sliderwin2.value(s1set2)
      endcel = sliderwin2.value(s1set3)
      (startcel..endcel).each do |j|
        cel1 = canvas.animation[startframe][j]
        cel2 = canvas.animation[endframe][j]
        next if !cel1 || !cel2
        diffPattern = cel2[AnimFrame::PATTERN] - cel1[AnimFrame::PATTERN]
        diffX = cel2[AnimFrame::X] - cel1[AnimFrame::X]
        diffY = cel2[AnimFrame::Y] - cel1[AnimFrame::Y]
        diffZoomX = cel2[AnimFrame::ZOOMX] - cel1[AnimFrame::ZOOMX]
        diffZoomY = cel2[AnimFrame::ZOOMY] - cel1[AnimFrame::ZOOMY]
        diffAngle = cel2[AnimFrame::ANGLE] - cel1[AnimFrame::ANGLE]
        diffOpacity = cel2[AnimFrame::OPACITY] - cel1[AnimFrame::OPACITY]
        diffBlend = cel2[AnimFrame::BLENDTYPE] - cel1[AnimFrame::BLENDTYPE]
        diffColorRed = cel2[AnimFrame::COLORRED] - cel1[AnimFrame::COLORRED]
        diffColorGreen = cel2[AnimFrame::COLORGREEN] - cel1[AnimFrame::COLORGREEN]
        diffColorBlue = cel2[AnimFrame::COLORBLUE] - cel1[AnimFrame::COLORBLUE]
        diffColorAlpha = cel2[AnimFrame::COLORALPHA] - cel1[AnimFrame::COLORALPHA]
        diffToneRed = cel2[AnimFrame::TONERED] - cel1[AnimFrame::TONERED]
        diffToneGreen = cel2[AnimFrame::TONEGREEN] - cel1[AnimFrame::TONEGREEN]
        diffToneBlue = cel2[AnimFrame::TONEBLUE] - cel1[AnimFrame::TONEBLUE]
        diffToneGray = cel2[AnimFrame::TONEGRAY] - cel1[AnimFrame::TONEGRAY]
        startPattern = cel1[AnimFrame::PATTERN]
        startX = cel1[AnimFrame::X]
        startY = cel1[AnimFrame::Y]
        startZoomX = cel1[AnimFrame::ZOOMX]
        startZoomY = cel1[AnimFrame::ZOOMY]
        startAngle = cel1[AnimFrame::ANGLE]
        startOpacity = cel1[AnimFrame::OPACITY]
        startBlend = cel1[AnimFrame::BLENDTYPE]
        startColorRed = cel1[AnimFrame::COLORRED]
        startColorGreen = cel1[AnimFrame::COLORGREEN]
        startColorBlue = cel1[AnimFrame::COLORBLUE]
        startColorAlpha = cel1[AnimFrame::COLORALPHA]
        startToneRed = cel1[AnimFrame::TONERED]
        startToneGreen = cel1[AnimFrame::TONEGREEN]
        startToneBlue = cel1[AnimFrame::TONEBLUE]
        startToneGray = cel1[AnimFrame::TONEGRAY]
        (0..frames).each do |k|
          cel = canvas.animation[startframe + k][j]
          curcel = cel
          if !cel
            cel = pbCreateCel(0, 0, 0)
            canvas.animation[startframe + k][j] = cel
          end
          if sliderwin2.value(set0) || !curcel
            cel[AnimFrame::PATTERN] = startPattern + (diffPattern * k / frames)
          end
          if sliderwin2.value(set1) || !curcel
            cel[AnimFrame::X] = startX + (diffX * k / frames)
            cel[AnimFrame::Y] = startY + (diffY * k / frames)
            cel[AnimFrame::ZOOMX] = startZoomX + (diffZoomX * k / frames)
            cel[AnimFrame::ZOOMY] = startZoomY + (diffZoomY * k / frames)
            cel[AnimFrame::ANGLE] = startAngle + (diffAngle * k / frames)
          end
          if sliderwin2.value(set2) || !curcel
            cel[AnimFrame::OPACITY] = startOpacity + (diffOpacity * k / frames)
            cel[AnimFrame::BLENDTYPE] = startBlend + (diffBlend * k / frames)
          end
          if sliderwin2.value(set3) || !curcel
            cel[AnimFrame::COLORRED] = startColorRed + (diffColorRed * k / frames)
            cel[AnimFrame::COLORGREEN] = startColorGreen + (diffColorGreen * k / frames)
            cel[AnimFrame::COLORBLUE] = startColorBlue + (diffColorBlue * k / frames)
            cel[AnimFrame::COLORALPHA] = startColorAlpha + (diffColorAlpha * k / frames)
            cel[AnimFrame::TONERED] = startToneRed + (diffToneRed * k / frames)
            cel[AnimFrame::TONEGREEN] = startToneGreen + (diffToneGreen * k / frames)
            cel[AnimFrame::TONEBLUE] = startToneBlue + (diffToneBlue * k / frames)
            cel[AnimFrame::TONEGRAY] = startToneGray + (diffToneGray * k / frames)
          end
        end
      end
      canvas.invalidate
      break
    end
    if sliderwin2.changed?(cancelbutton) || Input.trigger?(Input::BACK)
      break
    end
  end
  sliderwin2.dispose
end