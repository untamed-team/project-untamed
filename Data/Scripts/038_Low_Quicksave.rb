class Scene_Map
$backup_memory = []

  alias quicksave_update update
  def update
    quicksave_update
    if Input.trigger?(Input::AUX4)
			$game_switches[101] = !$game_switches[101]
			if !$game_switches[101]
				pbMessage(_INTL("You won't be seeing messages when earning exp."))
			else
				pbMessage(_INTL("You will be seeing messages when earning exp."))					
			end	
		end
    if Input.trigger?(Input::AUX6) && !$game_player.moving? && !$game_switches[83] && !pbMapInterpreterRunning?
      if Game.save
				pbSEPlay("Pkmn exp full") if FileTest.audio_exist?("Audio/SE/Pkmn exp full")
        pbMessage(_INTL("\\PN saved the game."))
			else
				pbMessage(_INTL("\\se[]Save failed. If saving for the first time, you must save from the pause menu first.\\wtnp[30]")) if !$game_switches[136]
			end
		end
		# look back at this if lag is prevalent, maybe creating a dummy pokemon every frame might cause it
		if $game_variables[MECHANICSVAR] >= 3 && $backup_memory.empty?
			$bag.add(:CHAOSCODEX) if !$bag.has?(:CHAOSCODEX)
			dummypkmn = Pokemon.new(:QUETZILLIAN, 1) # quetz learns his dumb sig on level 1, so no need to check lvl 1-100 moveset
			$backup_memory.push(dummypkmn)
			moves = []
			dummypkmn.getMoveList.each do |m|
				next if m[0] > dummypkmn.level || dummypkmn.hasMove?(m[1])
				moves.push(m[1]) if !moves.include?(m[1])
			end
			if moves.include?(:ZEALOUSDANCE)
				#~ print "dumb shit detected"
				pbUpdatePBSFilesForDifficulty
			end
		end
    pbReturnToTitleSceneMap if Input.triggerex?(:F5)
  end
end

	def pbReturnToTitleSceneMap()
		#originally made by DemICE, adapted to this essentials #by low
		#unfortunately it does not work in battles, that is why it isnt in input and rather scene
		#Black the screen or you will be able to catch a glimpse 
		#of the game running in the background during some menu actions.
		pbUpdateSceneMap
		pbBGMStop(1.0) # Fade out music
    Graphics.transition(0)
		SaveData.mark_values_as_unloaded
    $scene = pbCallTitle
    Graphics.freeze
		return
	end

#===============================================================================
#Press button to view ability description
#===============================================================================
=begin
class PokemonSummary_Scene
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
          pbPlayDecisionSE
          pbMoveSelection
          dorefresh = true
        elsif @page == 5
          pbPlayDecisionSE
          pbRibbonSelection
          dorefresh = true
        elsif !@inbattle
          pbPlayDecisionSE
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
      #which button to press has been edited by Gardenette for keybinding purposes
			elsif Input.trigger?(Input::SPECIAL) && !@pokemon.egg? && @page == 3 # extra long ability desc #by low
				pbMessage(_INTL("{1}: {2}",@pokemon.ability.name,@pokemon.ability.description))
      end
      if dorefresh
        drawPage(@page)
      end
    end
    return @partyindex
  end
end #of class
=end