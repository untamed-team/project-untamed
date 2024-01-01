#By Gardenette, Micah
#Work in Progress

def resetTagPositions
  #move player to center of map
  $game_player.moveto(19, 18)
  
  pbMoveRoute($game_player, [
  PBMoveRoute::TurnDown
  ])

  #move event a few tiles away from player
  $game_map.events[@event.id].moveto(19, 24)
  
  pbMoveRoute($game_map.events[@event.id], [
  PBMoveRoute::TurnUp
  ])
end #of def resetTagPositions

#Adapted from Voltseon's A-Star Pathfinding calc_move_route_inverted
def getDirection(position_a, position_b)
  return 6 if position_a.x < position_b.x
  return 4 if position_a.x > position_b.x
  return 2 if position_a.y > position_b.y
  return 8 if position_a.y < position_b.y
end

def runAway
    x = $game_map.events[@event.id].x
    y = $game_map.events[@event.id].y
    dist = calc_dist([x, y],
    [$game_player.x, $game_player.y])
    if dist < 5
      d = getDirection($game_map.events[@event.id], $game_player)
      # Copied from passable? in game character 
      if $game_map.events[@event.id].passable?(x, y, d, true) 
        pbMoveRoute($game_map.events[@event.id], [
        calc_move_route_inverted($game_map.events[@event.id], $game_player)
        ])
      end
    end
end
  
def whoIsIt
  if $game_variables[47] == 1
    #pokemon is it
    pbMessage(_INTL("{1} is it! Run!", @pkmn.name))
    
    #whistle blow?
    #START!

    PathFinder.dyn_find(@event.id, $game_player)
    
  else
    #you are it
    pbMessage(_INTL("You are it! Chase {1}!", @pkmn.name))
    
    #whistle blow?
    #START!
    runAway
  end #of if $game_variables[47] == 1
end #of def whoIsIt

def playAgain(it)
  if pbConfirmMessage(_INTL("You're it! Do you want to keep playing tag?"))
    campFadeOut
    resetTagPositions
    $game_variables[47] = it
    campFadeIn
    whoIsIt
  else
    toggleOffCampPlayTag
    campFadeOut
    restoreCampersToCoords
    campFadeIn
    $game_variables[47] = 0
  end
end

def campPlayTag
  campFadeOut  
  getCamperCoords
  moveCampersToSide
  
  #set the type of campInteraction
  #tag
  #this will be set to 1 or 2 at random when I get around to doing that
  #1 will be the pokemon chasing you
  #2 will be you chasing the pokemon
  $game_variables[47] = rand(2) + 1
  
  resetTagPositions
  
  campFadeIn
  
  whoIsIt
      
  #loop logic to make the pokemon chase you or run from you
  EventHandlers.add(:on_frame_update, :playTag,
    proc {
      #pokemon chases you
      if $game_variables[47] == 1 && pbEventCanReachPlayer?($game_map.events[@event.id], $game_player, 1)
        #pokemon caught player
        
        $game_map.events[@event.id].clear_path_target
        pbMoveRoute($game_map.events[@event.id], [
        PBMoveRoute::Jump,0,0,
        PBMoveRoute::Jump,0,0
        ])
  
        pbSEPlay("Cries/"+@species,100)
        pbMessage(_INTL("{1} got close enough to grab you!", @pkmn.name))
        playAgain(2)
      end
      
      #you chase pokemon
      if $game_variables[47] == 2
        runAway
        if pbEventCanReachPlayer?($game_player, $game_map.events[@event.id], 1)
        #player caught the pokemon
        
        
        $game_map.events[@event.id].clear_path_target
        pbMoveRoute($game_map.events[@event.id], [
        PBMoveRoute::TurnTowardPlayer,
        PBMoveRoute::Jump,0,0,
        PBMoveRoute::Jump,0,0
        ])
        
        pbSEPlay("Cries/"+@species,100)
        
        pbMessage(_INTL("You caught up to {1}!", @pkmn.name))
        playAgain(1)
      end
      end
        
    }) #end of eventhandler
  
  end #of campPlayTag

def toggleOffCampPlayTag
  EventHandlers.remove(:on_frame_update, :playTag)
end