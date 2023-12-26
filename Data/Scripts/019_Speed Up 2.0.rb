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
				#~ pbMessage(_INTL("WARNING: May cause performance issues on older hardware. - Mapping Department"))
				$GameSpeed += 1
				$GameSpeed = 0 if $GameSpeed >= SPEEDUP_STAGES.size
				if $GameSpeed == 0
					pbSEPlay("Gear_Low",80)
				end
				if $GameSpeed == 1
					pbSEPlay("Gear_Mid",80)
				end
				if $GameSpeed == 2
					pbSEPlay("Gear_High",80)
				end
				if $GameSpeed == 3 # ULTRA
					pbSEPlay("Exclaim",80)
				end
			end
    end
  end
end

SPEEDUP_STAGES = [1,2,3,5]
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