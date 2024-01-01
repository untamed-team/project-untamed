# By Micah
# Work in Progress
VISITORS = [[:M_ROSELIA, 100]]



    
  
  def causeEncounter
   # if visitorCount == 0
      x = rand(100)
      for i in 0 ... VISITORS.size
        if (x < VISITORS[i][1])
          spawnSpecies(VISITORS[i][0])
          #visitorCount += 1
          break
        else
          x - VISITORS[i][1]
        end
      end
  #  end
  end
  
  def spawnSpecies(species)
      if false
        #set path to followers shiny
        file_path = sprintf("Followers Shiny/%s", species)
      else
        #set path to followers
        file_path = sprintf("Followers/%s", species)
      end

      #changes the event number (like event 1, event 2, etc. on the map
      #into the graphic specified
      pbMoveRoute($game_map.events[7], [
        PBMoveRoute::Graphic, file_path, 0, 2, 0,
        PBMoveRoute::StepAnimeOn,
        PBMoveRoute::ThroughOff
      ])
  end
  
  
  
  def interact
    pbMessage(_INTL("WIP"))
  end

    
  #visitorCount = 0
  
  
  
  def toggleOnCampEncounters
    causeEncounter
    EventHandlers.add(:on_hour_change, :campEncounters, proc {
      if Camping.noInteraction?
        x = rand(300)
        if x == 0
          causeEncounter
        end
      end
    })
  end
  def toggleOffCampEncounters
   EventHandlers.remove(:on_hour_change, :campEncounters)
  end




