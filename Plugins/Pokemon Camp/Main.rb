class PokemonGlobalMetadata
  #variables to use while not in a loop
  #to access these variables, do so like this: 
  #$PokemonGlobal.variableName
  #to assign the variables, do so like this:
  #$PokemonGlobal.variableName = assignment
  attr_accessor   :camping
  attr_accessor   :campers
  attr_accessor   :campingPlayerStartX
  attr_accessor   :campingPlayerStartY
  attr_accessor   :playingHideAndSeek
  attr_accessor   :hideAndSeekTimer
  attr_accessor   :hideAndSeekViewport
  attr_accessor   :hideAndSeekSprites
  attr_accessor   :campGenericTimer
  attr_accessor   :hideAndSeekPause
  attr_accessor   :hideAndSeekSuccessfulConsecutiveRounds
  
end #class PokemonGlobalMetadata

class Pokemon
  attr_accessor :campEvent
  attr_accessor :hideAndSeekSpot
  attr_accessor :hideAndSeekFound
  attr_accessor :campStartX
  attr_accessor :campStartY
  attr_accessor :hideAndSeekGamesWon
  attr_accessor :failedToHide
  attr_accessor :hideAndSeekIcon
  attr_accessor :awakeness
end

class Camping
  
  def initialize
  end

  def startCamping
	$PokemonGlobal.camping = true
    pbCommonEvent(9) #start camping 
	#get the player's current X and Y position when they enter camp
	$PokemonGlobal.campingPlayerStartX = $game_player.x
	$PokemonGlobal.campingPlayerStartY = $game_player.y
	
    #toggleOnCampEvents
  end

  def endCamping
    toggleOffCampEvents
    pbTransferWithTransition($game_variables[45], $game_variables[31], $game_variables[32], nil, $game_variables[46])
    pbCommonEvent(10)
	$PokemonGlobal.camping = false
  end
  
	def self.interact
		#toggleOffCampEvents
		event = $game_player.pbFacingEvent
		pkmn = $player.pokemon_party[event.id-1] #this means that events 1-6 MUST be reserved for the pkmn in the player's party
		species = pkmn.species.to_s
		pbSEPlay("Cries/"+species,100)
		
		cmds_new = [_INTL("Amie"),_INTL("Hide and Seek"),_INTL("Nevermind")]
		choice = pbMessage(_INTL("What would you like to do with {1}?", pkmn.name),cmds_new,2)
		
		case choice
		when 0
		#Amie
		pokemonAmie(event.id-1)
				
		when 1
		#hide and seek
		self.hideAndSeek
		
		when 2
		#nevermind
		end #of case
	end #def interact
  
  def interactCookingPot
	if pbConfirmMessage(_INTL("Do you want to make some candy?"))
		CookingMixing.new
	end
  end #def self.interactCookingPot
  
  def getCampers
	$PokemonGlobal.campers = []
    #do for every pokemon in your party
    for i in 0...$Trainer.pokemon_count
      #get the pokemon in the party
      pkmn = $Trainer.pokemon_party[i]
      #add the species to the camper array
      $PokemonGlobal.campers[i] = pkmn#.species
	end #for i in 0...$Trainer.pokemon_count
  end #def getCampers
  
  #Place the pokemon on the map (change events 1-6 into the pokemon in the party)
  def pbChangeCampers
    getCampers
    #do for every pokemon in your party
    for i in 0...$Trainer.pokemon_count
      #get the pokemon in the party
      pkmn = $Trainer.pokemon_party[i]
      #add the species to the camper array
      #@campers[i] = pkmn.species
  
      #if form is greater than 0, set pkmn_genderform to species_formNumber so the
      #file_path goes to the correct iteration of that species
      if pkmn.form > 0
        pkmn_genderform = (_INTL("{1}_{2}",pkmn.species,pkmn.form))
      else
        pkmn_genderform = pkmn.species
      end
  
      #if the pokemon has a different form based on gender 
      if pkmn.species == :M_ROSELIA || pkmn.species == :M_ROSERADE
        if pkmn.gender > 0
          #the pokemon is female
          pkmn_genderform = (_INTL("{1}_female",pkmn.species))
        else
          pkmn_genderform = pkmn.species
        end
      end
  
      if pkmn.shiny?
        #set path to followers shiny
        file_path = sprintf("Followers Shiny/%s", pkmn_genderform)
      else
        #set path to followers
        file_path = sprintf("Followers/%s", pkmn_genderform)
      end

      #changes the event number (like event 1, event 2, etc. on the map
      #into the graphic specified
      pbMoveRoute($game_map.events[i+1], [
        PBMoveRoute::Graphic, file_path, 0, 2, 0,
        PBMoveRoute::StepAnimeOn,
        PBMoveRoute::ThroughOff
      ])
	  
	  #put a reference to the pkmn's campEvent in $PokemonGlobal.campers[i]
	  $PokemonGlobal.campers[i].campEvent = $game_map.events[i+1]
	  
		#get pkmn events' current X and Y position when the player enters camp
		$PokemonGlobal.campers[i].campStartX = $PokemonGlobal.campers[i].campEvent.x
		$PokemonGlobal.campers[i].campStartY = $PokemonGlobal.campers[i].campEvent.y
	  
    end #for i in 0...$Trainer.pokemon_count
  end #of pbChangeCampers
  
	def self.resetPlayerPosition
		pbTransferWithTransition(map_id=$game_map.map_id, x=$PokemonGlobal.campingPlayerStartX, y=$PokemonGlobal.campingPlayerStartY, transition = nil, dir = 2)
	end #def resetPlayerPosition
  
  def self.resetCamperPositions
	$game_screen.start_tone_change(Tone.new(-255,-255,-255,0), 6 * Graphics.frame_rate / 20)
	pbWait(Graphics.frame_rate)
	for i in 0...$PokemonGlobal.campers.length
		pkmn = $PokemonGlobal.campers[i]
		pkmn.campEvent.moveto(pkmn.campStartX, pkmn.campStartY)
		pbMoveRoute(pkmn.campEvent, [PBMoveRoute::Opacity, 255])
		pbMoveRoute(pkmn.campEvent, [PBMoveRoute::TurnDown])
	end #for i in 0...$PokemonGlobal.campers.length
	$game_screen.start_tone_change(Tone.new(0,0,0,0), 6 * Graphics.frame_rate / 20)
  end #def resetCamperPositions
  
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
  
  def campFadeOut
    #screen tone dark
    pbToneChangeAll(Tone.new(-255,-255,-255,-255),20)
    pbWait(60)
  end
  
  def campFadeIn
    #screen tone dark
    pbToneChangeAll(Tone.new(0,0,0,0),20)
    pbWait(60)
  end
  
  def toggleOnCampEvents
    toggleOnPokemonBehavior
    toggleOnCampEncounters
  end
  
  def toggleOffCampEvents
    toggleOffPokemonBehavior
    toggleOffCampEncounters
  end
  
  def self.resetAwakeness(pkmn)
	pkmn.awakeness = Graphics.frame_rate * 120 #two minutes
  end #def self.resetAwakeness(pkmn)
  
  #on_player_interact with camper
	EventHandlers.add(:on_player_interact, :interact_with_camper_pkmn, proc {
		next if !$PokemonGlobal.camping
		next if $PokemonGlobal.playingHideAndSeek
		facingEvent = $game_player.pbFacingEvent
		self.interact if facingEvent && facingEvent.name.match(/CamperPkmn/i)
	})
	
	#show hunger or sleep emote
	EventHandlers.add(:on_frame_update, :pkmn_emote_in_camp, proc {
		next if !$PokemonGlobal.camping
		next if $PokemonGlobal.playingHideAndSeek
		
		#subtract from awakeness timer on each pkmn
		#pkmn should fall asleep after 2 minutes of no interaction with the player or other pkmn
		for i in 0...$PokemonGlobal.campers.length
			pkmn = $PokemonGlobal.campers[i]
			self.resetAwakeness(pkmn) if pkmn.awakeness.nil?
			next if pkmn.awakeness <= 0
			pkmn.awakeness -= 1
		end #for i in 0...$PokemonGlobal.campers.length
		
		#show sleep emote if pkmn is sleepy (0 or less awakeness)
		for i in 0...$PokemonGlobal.campers.length
			pkmn = $PokemonGlobal.campers[i]
			if pkmn.awakeness <= 0
				self.pbOverworldAnimationNoPause(pkmn.campEvent, emoteID=20, tinting = false)
			end #if pkmn.awakeness <= 0
		end #for i in 0...$PokemonGlobal.campers.length
		
		#check if each pkmn is hungry - pkmn.amie_fullness - range is 0 to 255
		
	})
end #of class Camping

