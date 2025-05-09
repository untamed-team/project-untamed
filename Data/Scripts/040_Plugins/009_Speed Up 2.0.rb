module Input

  def self.update
    update_KGC_ScreenCapture
    pbScreenCapture if trigger?(Input::F8)
    
    #open control screen with F1
    open_set_controls_ui if Input.triggerex?(:F3)
    
    #display game version
    if Input.triggerex?(:F7)
      print "Game Version: " + Settings::GAME_VERSION
    end
    
    if $PokemonSystem.speedtoggle == 1
      if $CanToggle && trigger?(Input::AUX1)
        $GameSpeed += 1
        $GameSpeed = 0 if $GameSpeed >= SPEEDUP_STAGES.size
        if $GameSpeed == 0
          pbSEPlay("Gear_Low",100)
        end
        if $GameSpeed == 1
          pbSEPlay("Gear_Mid",100)
        end
        if $GameSpeed == 2
          pbSEPlay("Gear_High",100)
        end
        if $GameSpeed == 3 # ULTRA
          pbSEPlay("Exclaim",100)
        end
        gametitle = System.game_title
        speed_text = SPEEDUP_STAGES[$GameSpeed] == 1 ? gametitle : "#{gametitle} | Speed: x#{SPEEDUP_STAGES[$GameSpeed]}"
        pbSetWindowText(speed_text)        
      end
    end
  end
end

SPEEDUP_STAGES = [1,2,5]
$GameSpeed = 0
$frame = 0
$CanToggle = true

module Graphics
  class << Graphics
    alias fast_forward_update update
  end

  def self.update
    $frame += 1
    return unless $frame % SPEEDUP_STAGES[$GameSpeed] == 0
    fast_forward_update
    $frame = 0
  end
end