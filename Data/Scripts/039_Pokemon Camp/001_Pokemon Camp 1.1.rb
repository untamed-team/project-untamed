#By Gardenette
#Work in Progress

#Since I don't know enough about bitmaps and manipulating sprites, I think the
#best approach for me for now would be to display a 32x32 invisible sprite at
#the same coordinates as the party pokemon events (updated in a loop) that you
#can click on with the easy mouse system

class Camping
  
  def initialize
  end

  def startCamping
    pbCommonEvent(9) #start camping 
    toggleOnCampEvents
  end

  def endCamping
    toggleOffCampEvents
    pbTransferWithTransition($game_variables[45], $game_variables[31], $game_variables[32], nil, $game_variables[46])
    pbCommonEvent(10)
  end
  
   # Whenever you add an event that you don't want to have pokemon behavior
   # and encounters happen during please add to this.
  def self.noInteraction?
    return false if $game_variables[47] != 0
    return true
  end
  
  #Place the pokemon on the map (change events 1-6 into the pokemon in the party)
  def pbChangeCampers
    @campers = []
    
    #do for every pokemon in your party
    for i in 0...$Trainer.pokemon_count
      #get the pokemon in the party
      pkmn = $Trainer.pokemon_party[i]
      #add the species to the camper array
      @campers[i] = pkmn.species
  
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
    end #for i in 0...$Trainer.pokemon_count
  end #of pbChangeCampers

  def campInteract
    toggleOffCampEvents
    @event = pbMapInterpreter.get_self
    @pkmn = $player.pokemon_party[@event.id-1]
    @species = @pkmn.species.to_s
    pbSEPlay("Cries/"+@species,100)
    
    cmds_new = [_INTL("Play Tag"),_INTL("Nevermind")]
    choice = pbMessage(_INTL("What would you like to do with {1}?", @pkmn.name),cmds_new,2)
    
    case choice
      when 0
      #tag
      campPlayTag
          
      when 1
      #nevermind
      
    end #of case
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
  
  def getCamperCoords
    #save campers' coordinates
    @camper1X = $game_map.events[1].x
    @camper1Y = $game_map.events[1].y
    @camper2X = $game_map.events[2].x
    @camper2Y = $game_map.events[2].y
    @camper3X = $game_map.events[3].x
    @camper3Y = $game_map.events[3].y
    @camper4X = $game_map.events[4].x
    @camper4Y = $game_map.events[4].y
    @camper5X = $game_map.events[5].x
    @camper5Y = $game_map.events[5].y
    @camper6X = $game_map.events[6].x
    @camper6Y = $game_map.events[6].y
    
    #save player's coords
    @playerInCampX = $game_player.x
    @playerInCampY = $game_player.y
  end
  
  def restoreCampersToCoords
    #move all the campers back to where they were before the last interaction
    $game_map.events[1].moveto(@camper1X, @camper1Y)
    $game_map.events[2].moveto(@camper2X, @camper2Y)
    $game_map.events[3].moveto(@camper3X, @camper3Y)
    $game_map.events[4].moveto(@camper4X, @camper4Y)
    $game_map.events[5].moveto(@camper5X, @camper5Y)
    $game_map.events[6].moveto(@camper6X, @camper6Y)
    
    #move the player back to where they were before the last interaction
    $game_player.moveto(@playerInCampX, @playerInCampY)
  end
  
  def moveCampersToSide
    #move all other campers out of the way
    @camperMovedX = 16
    @camperMovedY = 8
    
    #event = pbMapInterpreter.get_self
    for i in 0...$Trainer.pokemon_count
      $game_map.events[i+1].clear_path_target
      if i != @event.id - 1
        $game_map.events[i+1].moveto(@camperMovedX, @camperMovedY)
        @camperMovedX += 1
      end
    end
  end
  
  def toggleOnCampEvents
    toggleOnPokemonBehavior
    toggleOnCampEncounters
  end
  
  def toggleOffCampEvents
    toggleOffPokemonBehavior
    toggleOffCampEncounters
  end
end #of class