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
		if Input.trigger?(Input::AUX6) && !$game_player.moving? && !$PokemonGlobal.camping && !pbMapInterpreterRunning?
			if Game.save
				pbSEPlay("Pkmn exp full") if FileTest.audio_exist?("Audio/SE/Pkmn exp full")
				pbMessage(_INTL("\\PN saved the game."))
			else
				pbMessage(_INTL("\\se[]Save failed. If saving for the first time, you must save from the pause menu first.\\wtnp[30]")) if !$game_switches[136]
			end
		end
		# look back at this if lag is prevalent, maybe creating a dummy pokemon every frame might cause it
		if $player.difficulty_mode?("chaos") && $backup_memory.empty?
			$bag.add(:CHAOSCODEX) if !$bag.has?(:CHAOSCODEX)
			dummypkmn = Pokemon.new(:QUETZILLIAN, 1) # quetz learns his dumb sig on level 1, so no need to check lvl 1-100 moveset
			$backup_memory.push(dummypkmn)
			moves = []
			dummypkmn.getMoveList.each do |m|
				next if m[0] > dummypkmn.level || dummypkmn.hasMove?(m[1])
				moves.push(m[1]) if !moves.include?(m[1])
			end
			pbUpdatePBSFilesForDifficulty if moves.include?(:ZEALOUSDANCE)
		end
	end
end