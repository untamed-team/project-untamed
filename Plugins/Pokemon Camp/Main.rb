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
  attr_accessor   :beforeCampPlayerMapID
  attr_accessor   :beforeCampPlayerMapX
  attr_accessor   :beforeCampPlayerMapY
  attr_accessor   :beforeCampPlayerDirection
  attr_accessor   :campPkmnChasing
  attr_accessor   :campPkmnRunning
  
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
  attr_accessor :campAwakeness
  attr_accessor :campHungerEmoteTimerPermanent
  attr_accessor :campHungerEmoteTimer
  attr_accessor :campNapping
  attr_accessor :campNappingEmoteTimer
  attr_accessor :interactingWithTrainer
end

class Camping
  
  def initialize
  end

  def startCamping
	#save some variables about the player's current position and map before camp
	$PokemonGlobal.beforeCampPlayerMapID = $game_map.map_id
	$PokemonGlobal.beforeCampPlayerMapX = $game_player.x
	$PokemonGlobal.beforeCampPlayerMapY = $game_player.y
	$PokemonGlobal.beforeCampPlayerDirection = $game_player.direction
	
	#choose which camping map to teleported to, and set the name value to variable 50
	#1 = Beach - campMapBeach
	#2 = Cave - campMapCave
	#3 = Grassy - campMapGrassy
	#4 = Desert - campMapDesert
	#5 = Meadow - campMapMeadow
	#6 = Farmland - campMapFarmland
	#7 = Forest - campMapForest
	#8 = Canyon - campMapCanyon
	#9 = Snowy - campMapSnowy
	if GameData::MapMetadata.get($game_map.map_id)&.has_flag?("campMapBeach")
		$game_variables[50] = 1
	elsif GameData::MapMetadata.get($game_map.map_id)&.has_flag?("campMapCave")
		$game_variables[50] = 2
	elsif GameData::MapMetadata.get($game_map.map_id)&.has_flag?("campMapGrassy")
		$game_variables[50] = 3
	elsif GameData::MapMetadata.get($game_map.map_id)&.has_flag?("campMapDesert")
		$game_variables[50] = 4
	elsif GameData::MapMetadata.get($game_map.map_id)&.has_flag?("campMapMeadow")
		$game_variables[50] = 5
	elsif GameData::MapMetadata.get($game_map.map_id)&.has_flag?("campMapFarmland")
		$game_variables[50] = 6
	elsif GameData::MapMetadata.get($game_map.map_id)&.has_flag?("campMapForest")
		$game_variables[50] = 7
	elsif GameData::MapMetadata.get($game_map.map_id)&.has_flag?("campMapCanyon")
		$game_variables[50] = 8
	elsif GameData::MapMetadata.get($game_map.map_id)&.has_flag?("campMapSnowy")
		$game_variables[50] = 9
	else #default is Grassy
		$game_variables[50] = 3
	end
	
	pbCommonEvent(9) #start camping
	
	#get the player's current X and Y position when they enter camp
	$PokemonGlobal.campingPlayerStartX = $game_player.x
	$PokemonGlobal.campingPlayerStartY = $game_player.y
	
	#set the pkmn events
	pbChangeCampers
	
	#fade screen in
	$game_screen.start_tone_change(Tone.new(0,0,0,0), 6 * Graphics.frame_rate / 20)
	
	$PokemonGlobal.camping = true
  end

  def endCamping
    resetVariables
	
	pbTransferWithTransition($PokemonGlobal.beforeCampPlayerMapID, $PokemonGlobal.beforeCampPlayerMapX, $PokemonGlobal.beforeCampPlayerMapY, nil, $PokemonGlobal.beforeCampPlayerDirection)
    pbCommonEvent(10)
	$PokemonGlobal.camping = false
  end
  
  def resetVariables
	#make sure no pkmn are chasing each other
	$PokemonGlobal.campPkmnChasing = nil
	$PokemonGlobal.campPkmnRunning = nil
	
	for i in 0...$PokemonGlobal.campers.length
		pkmn = $PokemonGlobal.campers[i]
		pkmn.interactingWithTrainer = false
		pkmn.campNapping = false
		pkmn.campNappingEmoteTimer = nil
		pkmn.campHungerEmoteTimer = nil
		pkmn.campHungerEmoteTimerPermanent = nil
	end #for i in 0...$PokemonGlobal.campers.length
  end #def self.resetVariables
  
	def self.interact
		event = $game_player.pbFacingEvent
		pkmn = $player.pokemon_party[event.id-1] #this means that events 1-6 MUST be reserved for the pkmn in the player's party
		pkmn.interactingWithTrainer = true
		
		#set chasingpkmn and runningpkmn to nil if the pkmn is either of these
		if $PokemonGlobal.campPkmnChasing == pkmn
			$PokemonGlobal.campPkmnChasing = nil
			$PokemonGlobal.campPkmnRunning = nil
		end
		if $PokemonGlobal.campPkmnRunning == pkmn
			$PokemonGlobal.campPkmnChasing = nil
			$PokemonGlobal.campPkmnRunning = nil
		end
		
		
		#set move type to fixed so the pkmn stops roaming
		pkmn.campEvent.move_type = 0
		
		#wake the pkmn if napping
		if pkmn.campNapping
			self.pkmnStopNap(pkmn) 
			pbWait(Graphics.frame_rate)
		end
		
		species = pkmn.species.to_s
		pbSEPlay("Cries/"+species,100)
		
		pbMoveRoute(pkmn.campEvent, [PBMoveRoute::TurnTowardPlayer])
		
		cmds_new = [_INTL("Summary"),_INTL("Amie"),_INTL("Hide and Seek"),_INTL("Nevermind")]
		choice = pbMessage(_INTL("What would you like to do with {1}?", pkmn.name),cmds_new,-1)
		
		case choice
		when 0
			#summary
			self.callPkmnSummary(pkmn)
		when 1
			#Amie
			pokemonAmie(event.id-1)	
		when 2
			#hide and seek
			self.hideAndSeek
		when 3
			#nevermind
		end #of case
		
		pkmn.interactingWithTrainer = false
		
		#set move type to random so the pkmn roams again
		pkmn.campEvent.move_type = 1
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
	  
	  ################## set certain variables for each pkmn ##################
	  #put a reference to the pkmn's campEvent in $PokemonGlobal.campers[i]
	  $PokemonGlobal.campers[i].campEvent = $game_map.events[i+1]
	  
		#get pkmn events' current X and Y position when the player enters camp
		$PokemonGlobal.campers[i].campStartX = $PokemonGlobal.campers[i].campEvent.x
		$PokemonGlobal.campers[i].campStartY = $PokemonGlobal.campers[i].campEvent.y
		
		#emote timer - amount of time needed to pass before the pkmn emotes again, sent to random between 2 values
		#each pkmn has their own unique value for how often they emote
		$PokemonGlobal.campers[i].campHungerEmoteTimerPermanent = Graphics.frame_rate * rand(60..120) if $PokemonGlobal.campers[i].campHungerEmoteTimerPermanent.nil?
		$PokemonGlobal.campers[i].campHungerEmoteTimer = $PokemonGlobal.campers[i].campHungerEmoteTimerPermanent if $PokemonGlobal.campers[i].campHungerEmoteTimer.nil?
		
		#set move type to fixed so the pkmn starts roaming
		pkmn.campEvent.move_type = 1
		
		#set pkmn event move frequency
		self.setPkmnEventFreq(pkmn)
    end #for i in 0...$Trainer.pokemon_count
  end #of pbChangeCampers
  
  def setPkmnEventFreq(pkmn)
	case pkmn.nature.id
	when :ADAMANT
		pkmn.campEvent.move_frequency = 3
	when :BASHFUL
		pkmn.campEvent.move_frequency = 3
	when :BOLD
		pkmn.campEvent.move_frequency = 3
	when :BRAVE
		pkmn.campEvent.move_frequency = 2
	when :CALM
		pkmn.campEvent.move_frequency = 3
	when :CAREFUL
		pkmn.campEvent.move_frequency = 3
	when :DOCILE
		pkmn.campEvent.move_frequency = 3
	when :GENTLE
		pkmn.campEvent.move_frequency = 3
	when :HARDY
		pkmn.campEvent.move_frequency = 3
	when :HASTY
		pkmn.campEvent.move_frequency = 4
	when :IMPISH
		pkmn.campEvent.move_frequency = 3
	when :JOLLY
		pkmn.campEvent.move_frequency = 4
	when :LAX
		pkmn.campEvent.move_frequency = 3
	when :LONELY
		pkmn.campEvent.move_frequency = 3
	when :MILD
		pkmn.campEvent.move_frequency = 3
	when :MODEST
		pkmn.campEvent.move_frequency = 3
	when :NAIVE
		pkmn.campEvent.move_frequency = 4
	when :NAUGHTY
		pkmn.campEvent.move_frequency = 3
	when :QUIET
		pkmn.campEvent.move_frequency = 2
	when :QUIRKY
		pkmn.campEvent.move_frequency = 3
	when :RASH
		pkmn.campEvent.move_frequency = 3
	when :RELAXED
		pkmn.campEvent.move_frequency = 2
	when :SASSY
		pkmn.campEvent.move_frequency = 2
	when :SERIOUS
		pkmn.campEvent.move_frequency = 3
	when :TIMID
		pkmn.campEvent.move_frequency = 3
	end
  end #def self.setPkmnEventFreq
  
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
  
  def self.showEventAnimation(eventID, animation_id)
    character = $game_map.events[eventID]
    return true if character.nil?
    character.animation_id = animation_id
    return true
  end

	def self.callPkmnSummary(pkmn)
		for i in 0...$Trainer.pokemon_party.length
			pkmnPartyIndex = i if $Trainer.pokemon_party[i] == pkmn
		end
		
		scene = PokemonSummary_Scene.new
		screen = PokemonSummaryScreen.new(scene, inbattle=false)
		#screen.pbStartScreen(@party, pkmnid)
		screen.pbStartScreen($Trainer.pokemon_party, pkmnPartyIndex)
		#scene.pbSummary(idxParty, true)
	end #def callPkmnSummary

  #on_player_interact with camper
	EventHandlers.add(:on_player_interact, :interact_with_camper_pkmn, proc {
		next if !$PokemonGlobal.camping
		next if $PokemonGlobal.playingHideAndSeek
		facingEvent = $game_player.pbFacingEvent
		self.interact if facingEvent && facingEvent.name.match(/CamperPkmn/i)
	})
end #of class Camping

################ Game Event Class ################
class Game_Event < Game_Character
	attr_accessor :move_type
	attr_accessor :move_route
	attr_accessor :move_route_forcing
end

#---------------------------
# Entry for Entering Camp
#---------------------------
MenuHandlers.add(:pause_menu, :camp, {
	"name"      => _INTL("Camp"),
	"order"     => 60,
	"condition" => proc { next $bag.has?(:CAMPINGGEAR) && (!$PokemonGlobal.camping || $PokemonGlobal.camping.nil?) },
	"effect"    => proc { |menu|
		#in what cases can you not use the camping gear?
		if $PokemonGlobal.diving || GameData::MapMetadata.get($game_map.map_id)&.has_flag?("CannotCamp") || (GameData::MapMetadata.get($game_map.map_id).outdoor_map == false && !GameData::MapMetadata.get($game_map.map_id)&.has_flag?("CanCamp"))
			#if not outdoors or if underwater, you can't use the camping gear
			pbMessage(_INTL("You can't set up camp here."))
			next false #do not exit the pause menu
		else
			menu.pbHideMenu
			camp = Camping.new
			camp.startCamping
			menu.pbRefresh
			#menu.pbEndScene
			$game_temp.in_menu = false
			next true #exit the pause menu
		end
	}
})


#---------------------------
# Entry for Exiting Camp
#---------------------------
MenuHandlers.add(:pause_menu, :exit_camp, {
	"name"      => _INTL("Pack up"),
	"order"     => 50,
	"condition" => proc { next $PokemonGlobal.camping },
	"effect"    => proc { |menu|
		menu.pbHideMenu
		camp = Camping.new
		camp.endCamping
		menu.pbRefresh
		#menu.pbEndScene
		$game_temp.in_menu = false
		next true
	}
})