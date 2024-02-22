class Camping

	def self.pbOverworldAnimationNoPause(event, id, tinting = false)
		if event.is_a?(Array)
			sprite = nil
			done = []
			event.each do |i|
				next if done.include?(i.id)
				spriteset = $scene.spriteset(i.map_id)
				sprite ||= spriteset&.addUserAnimation(id, i.x, i.y, tinting, 5)
				done.push(i.id)
			end
		else
			spriteset = $scene.spriteset(event.map_id)
			sprite = spriteset&.addUserAnimation(id, event.x, event.y, tinting, 5)
		end
	end
	
	def self.resetAwakeness(pkmn)
		pkmn.campAwakeness = Graphics.frame_rate * 120 #two minutes
	end #def self.resetAwakeness(pkmn)
	
	#####################################
	#####      Event Handlers       #####
	#####################################
	#show hunger or sleep emote
	EventHandlers.add(:on_frame_update, :pkmn_emote_in_camp, proc {
		next if !$PokemonGlobal.camping
		next if $PokemonGlobal.playingHideAndSeek
		
		#subtract from awakeness timer on each pkmn
		#pkmn should fall asleep after 2 minutes of no interaction with the player or other pkmn
		for i in 0...$PokemonGlobal.campers.length
			pkmn = $PokemonGlobal.campers[i]
			self.resetAwakeness(pkmn) if pkmn.campAwakeness.nil?
			next if pkmn.campAwakeness <= 0
			pkmn.campAwakeness -= 1
		end #for i in 0...$PokemonGlobal.campers.length
		
		for i in 0...$PokemonGlobal.campers.length
			pkmn = $PokemonGlobal.campers[i]
			#show hunger emote if hungry instead of showing sleep emote
			#can't go to bed hungry :)
			#check if each pkmn is hungry - pkmn.amie_fullness - range is 0 to 255
			next if pkmn.amie_fullness.nil?
			if pkmn.amie_fullness <= 0 && pkmn.campEmoteTimer <= 0
				self.pbOverworldAnimationNoPause(pkmn.campEvent, emoteID=19, tinting = false)
				next #don't show sleep timer if hungry. We don't want to show both hunger and sleep emotes within the emoteTimer window
			end #if pkmn.amie_fullness <= 0
		
			#show sleep emote if pkmn is sleepy (0 or less awakeness) and the campEmoteTimer is <= 0, then reset the campEmoteTimer
			if pkmn.campAwakeness <= 0 && pkmn.campEmoteTimer <= 0
				self.pbOverworldAnimationNoPause(pkmn.campEvent, emoteID=20, tinting = false)
			end #if pkmn.campAwakeness <= 0
		end #for i in 0...$PokemonGlobal.campers.length
		
		#subtract from emoteTimer
		for i in 0...$PokemonGlobal.campers.length
			pkmn = $PokemonGlobal.campers[i]
			next if pkmn.campEmoteTimer.nil?
			#reset emote timer if <= 0
			pkmn.campEmoteTimer = pkmn.campEmoteTimerPermanent if pkmn.campEmoteTimer <= 0
			pkmn.campEmoteTimer -= 1
		end #for i in 0...$PokemonGlobal.campers.length
	})

end #class Camping