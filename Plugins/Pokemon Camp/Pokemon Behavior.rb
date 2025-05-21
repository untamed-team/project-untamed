class Camping
	
	def self.resetAwakeness(pkmn)
		pkmn.campAwakeness = Graphics.frame_rate * 120 #two minutes
	end #def self.resetAwakeness(pkmn)
	
	def self.pkmnStartNap(pkmn)
		pkmn.campNapping = true
		#set move type to fixed so the pkmn stops roaming
		pkmn.campEvent.move_type = 0
		#turn off step animation
		pbMoveRoute(pkmn.campEvent, [PBMoveRoute::StepAnimeOff])
		self.showEventAnimation(pkmn.campEvent.id, animation_id=21)
		pbSEPlay("FollowEmote",100,80)
	end #def self.pkmnStartNap
	
	def self.pkmnStopNap(pkmn)
		self.resetAwakeness(pkmn)
		pkmn.campNapping = false
		#set move type to fixed so the pkmn starts roaming
		pkmn.campEvent.move_type = 1
		#turn on step animation
		pbMoveRoute(pkmn.campEvent, [PBMoveRoute::StepAnimeOn])
		#exclamation point emote
		self.showEventAnimation(pkmn.campEvent.id, animation_id=3)
	end #self.pkmnStopNap(pkmn)
	
	def self.pkmnChasing
		possiblePkmnPlaying = []
		for i in 0...$PokemonGlobal.campers.length
			pkmn = $PokemonGlobal.campers[i]
			next if pkmn.campNapping
			next if pkmn.interactingWithTrainer
			possiblePkmnPlaying.push(pkmn)
		end #for i in 0...$PokemonGlobal.campers.length
		
		if possiblePkmnPlaying.length < 2
			return
		else
			$PokemonGlobal.campPkmnChasing = possiblePkmnPlaying.sample
			possiblePkmnPlaying.delete($PokemonGlobal.campPkmnChasing)
			$PokemonGlobal.campPkmnRunning = possiblePkmnPlaying.sample
		
			#set move routes to fixed
			$PokemonGlobal.campPkmnChasing.campEvent.move_type = 0
			$PokemonGlobal.campPkmnRunning.campEvent.move_type = 0
		end
	end #def self.pkmnChasing
	
	def self.chaserCaughtRunner
		#pkmn look at each other
		PathfindingTile.look_at_event($PokemonGlobal.campPkmnRunning.campEvent.id, $PokemonGlobal.campPkmnChasing.campEvent.id)
		PathfindingTile.look_at_event($PokemonGlobal.campPkmnChasing.campEvent.id, $PokemonGlobal.campPkmnRunning.campEvent.id)
		
		#exclamation point on runner
		self.showEventAnimation($PokemonGlobal.campPkmnRunning.campEvent.id, animation_id=3)
		#runner jump
		pbMoveRoute($PokemonGlobal.campPkmnRunning.campEvent, [PBMoveRoute::Jump, 0, 0])
		
		#set move routes back to random
		$PokemonGlobal.campPkmnChasing.campEvent.move_type = 1
		$PokemonGlobal.campPkmnRunning.campEvent.move_type = 1
		
		#end the chase scene and allow it to happen again
		$PokemonGlobal.campPkmnChasing = nil
		$PokemonGlobal.campPkmnRunning = nil
	end #def self.chaserCaughtRunner
	
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
		
		#hunger emote
		for i in 0...$PokemonGlobal.campers.length
			pkmn = $PokemonGlobal.campers[i]
			#show hunger emote if hungry instead of showing sleep emote
			#can't go to bed hungry :)
			#check if each pkmn is hungry - pkmn.amie_fullness - range is 0 to 255
			next if pkmn.amie_fullness.nil?
			next if pkmn.campHungerEmoteTimer.nil?
			if pkmn.amie_fullness <= 0 && pkmn.campHungerEmoteTimer <= 0
				self.showEventAnimation(pkmn.campEvent.id, animation_id=22)
				next #don't show sleep timer if hungry. We don't want to show both hunger and sleep emotes within the emoteTimer window
			end #if pkmn.amie_fullness <= 0
		
			#pkmn starts napping if not already napping and awakeness is <= 0
			if pkmn.campAwakeness <= 0 && !pkmn.campNapping && pkmn.amie_fullness > 0
				self.pkmnStartNap(pkmn)
			end #if pkmn.campAwakeness <= 0
		end #for i in 0...$PokemonGlobal.campers.length
		
		#subtract from campHungerEmoteTimer
		for i in 0...$PokemonGlobal.campers.length
			pkmn = $PokemonGlobal.campers[i]
			next if pkmn.campHungerEmoteTimer.nil?
			#don't subtract from hunger timer if napping
			next if pkmn.campNapping
			#reset emote timer if <= 0
			pkmn.campHungerEmoteTimer = pkmn.campHungerEmoteTimerPermanent if pkmn.campHungerEmoteTimer.nil? || pkmn.campHungerEmoteTimer <= 0
			pkmn.campHungerEmoteTimer -= 1
		end #for i in 0...$PokemonGlobal.campers.length
		
		#subtract from campNappingEmoteTimer
		for i in 0...$PokemonGlobal.campers.length
			pkmn = $PokemonGlobal.campers[i]
			#don't subtract from napping emote timer if not napping
			next if !pkmn.campNapping
			#reset emote timer if <= 0
			pkmn.campNappingEmoteTimer = Graphics.frame_rate*15 if pkmn.campNappingEmoteTimer.nil? || pkmn.campNappingEmoteTimer <= 0
			pkmn.campNappingEmoteTimer -= 1
		end #for i in 0...$PokemonGlobal.campers.length
		
		#show sleep emote if napping
		for i in 0...$PokemonGlobal.campers.length
			pkmn = $PokemonGlobal.campers[i]
			next if !pkmn.campNapping
			next if pkmn.campNappingEmoteTimer.nil?
			self.showEventAnimation(pkmn.campEvent.id, animation_id=21) if pkmn.campNappingEmoteTimer <= 0			
		end #for i in 0...$PokemonGlobal.campers.length
	})
	
	EventHandlers.add(:on_frame_update, :pkmn_chase_each_other, proc {
		next if !$PokemonGlobal.camping
		next if $PokemonGlobal.playingHideAndSeek
		#don't run any code if pkmn are already playing
		if $PokemonGlobal.campPkmnChasing.nil?
			chance = rand(1..30*Graphics.frame_rate)
			self.pkmnChasing if chance == 1
		else
			#check distance between the two events to see when the chaser has reached its destination
			distanceX = ($PokemonGlobal.campPkmnChasing.campEvent.x - $PokemonGlobal.campPkmnRunning.campEvent.x).abs
			distanceY = ($PokemonGlobal.campPkmnChasing.campEvent.y - $PokemonGlobal.campPkmnRunning.campEvent.y).abs
			if (distanceX == 0 && distanceY == 1) || (distanceX == 1 && distanceY == 0)
				self.chaserCaughtRunner
			else
				PathfindingTile.move_to_event($PokemonGlobal.campPkmnChasing.campEvent, $PokemonGlobal.campPkmnRunning.campEvent, false) if !$PokemonGlobal.campPkmnChasing.campEvent.move_route_forcing
				$PokemonGlobal.campPkmnRunning.campEvent.move_away_from_event($PokemonGlobal.campPkmnChasing.campEvent)
			end
		end
	})
end #class Camping

class Game_Character
	def move_away_from_event(eventToRunFrom)
		sx = @x + (@width / 2.0) - (eventToRunFrom.x + (eventToRunFrom.width / 2.0))
		sy = @y - (@height / 2.0) - (eventToRunFrom.y - (eventToRunFrom.height / 2.0))
		return if sx == 0 && sy == 0
		abs_sx = sx.abs
		abs_sy = sy.abs
		if abs_sx == abs_sy
		(rand(2) == 0) ? abs_sx += 1 : abs_sy += 1
		end
		if abs_sx > abs_sy
		(sx > 0) ? move_right : move_left
		if !moving? && sy != 0
			(sy > 0) ? move_down : move_up
		end
		else
		(sy > 0) ? move_down : move_up
		if !moving? && sx != 0
			(sx > 0) ? move_right : move_left
		end
		end
	end
end #class Game_Character