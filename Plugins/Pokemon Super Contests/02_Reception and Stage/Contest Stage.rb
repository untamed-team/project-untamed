class ContestStage
  
  def self.start
    @chosenType = ContestTypeRank.getChosenType
    @chosenRank = ContestTypeRank.getChosenRank
    
    #the script looks at the names of events and gets the ones named
    #Contestant1, Contestant1Pkmn, Contestant2, Contestant2Pkmn, Contestant3,
    #Contestant3Pkmn, and PlayerPkmn
    #the script then saves those to variables
    $game_map.events.values.each {|event|
    @contestant1Event = event if event.name == "Contestant1"
    @contestant1PkmnEvent = event if event.name == "Contestant1Pkmn"
    @contestant2Event = event if event.name == "Contestant2"
    @contestant2PkmnEvent = event if event.name == "Contestant2Pkmn"
    @contestant3Event = event if event.name == "Contestant3"
    @contestant3PkmnEvent = event if event.name == "Contestant3Pkmn"
    @playerPkmnEvent = event if event.name == "PlayerPkmn"
    @announcerEvent = event if event.name == "Announcer"
    
    } #end of $game_map.events.values.each {|event|
    
    @playerPkmn = ContestContestant.getPlayerPkmn #this is the pokemon itself,
    #not the event on the map
    
    #set contestants
    self.chooseContestants
    self.setEventGraphics
    self.pbMain
  end
  
  def self.chooseContestants
    pool = ContestantSettings::CONTESTANTS_NORMAL if @chosenRank == "Normal"
    pool = ContestantSettings::CONTESTANTS_GREAT if @chosenRank == "Great"
    pool = ContestantSettings::CONTESTANTS_ULTRA if @chosenRank == "Ultra"
    pool = ContestantSettings::CONTESTANTS_MASTER if @chosenRank == "Master"
    
    @chosenContestants = pool.sample(3)
    
    #fill out other data for chosen contestants
    @chosenContestants[0].merge!({DanceMoves: nil})
    @chosenContestants[1].merge!({DanceMoves: nil})
    @chosenContestants[2].merge!({DanceMoves: nil})
    
    @chosenContestants[0].merge!({DancePoints: 0})
    @chosenContestants[1].merge!({DancePoints: 0})
    @chosenContestants[2].merge!({DancePoints: 0})
    
    @chosenContestants[0].merge!({CurrentRoundHearts: 0})
    @chosenContestants[1].merge!({CurrentRoundHearts: 0})
    @chosenContestants[2].merge!({CurrentRoundHearts: 0})
    
    @chosenContestants[0].merge!({ActingPoints: 0})
    @chosenContestants[1].merge!({ActingPoints: 0})
    @chosenContestants[2].merge!({ActingPoints: 0})
    
    @chosenContestants[0].merge!({TotalPoints: 0})
    @chosenContestants[1].merge!({TotalPoints: 0})
    @chosenContestants[2].merge!({TotalPoints: 0})
    
    @chosenContestants[0].merge!({PkmnMoves: ""})
    @chosenContestants[1].merge!({PkmnMoves: ""})
    @chosenContestants[2].merge!({PkmnMoves: ""})
    
    @chosenContestants[0].merge!({MovePerformedTwoTurnsAgo: ""})
    @chosenContestants[1].merge!({MovePerformedTwoTurnsAgo: ""})
    @chosenContestants[2].merge!({MovePerformedTwoTurnsAgo: ""})
    
    @chosenContestants[0].merge!({MoveLastPerformed: ""})
    @chosenContestants[1].merge!({MoveLastPerformed: ""})
    @chosenContestants[2].merge!({MoveLastPerformed: ""})
    
    @chosenContestants[0].merge!({JudgeLastPerformedTo: ""})
    @chosenContestants[1].merge!({JudgeLastPerformedTo: ""})
    @chosenContestants[2].merge!({JudgeLastPerformedTo: ""})
    
    @chosenContestants[0].merge!({ShowTurnOrder: false})
    @chosenContestants[1].merge!({ShowTurnOrder: false})
    @chosenContestants[2].merge!({ShowTurnOrder: false})
    
    #push "Player: false" key into each contestant hash at the end    
    @chosenContestants[0].merge!({Player: false})
    @chosenContestants[1].merge!({Player: false})
    @chosenContestants[2].merge!({Player: false})
    
    #push player data into @chosenContestants
    playerInfo = {TrainerName: $player.name, TrainerCharacter: "character sprite",
      PkmnSpecies: @playerPkmn.species, PkmnName: @playerPkmn.name,
      PkmnGender: @playerPkmn.gender, PkmnForm: @playerPkmn.form,
      PkmnShiny: @playerPkmn.shiny?, DressupPoints: 0, ConditionPoints: 0,
      DancePoints: 0, CurrentRoundHearts: 0, ActingPoints: 0,
      TotalPoints: 0, PkmnMoves: @playerPkmn.moves, MovePerformedTwoTurnsAgo: "",
      MoveLastPerformed: "", JudgeLastPerformedTo: "",
      ShowTurnOrder: false, Player: true}
      
      @chosenContestants.push(playerInfo)
    return @chosenContestants
  end
  
  def self.setEventGraphics
    #set each trainer event's graphic
    pbMoveRoute($game_map.events[@contestant1Event.id], [
        PBMoveRoute::Graphic, @chosenContestants[0][:TrainerCharacter], 0, 2, 0
      ])
    pbMoveRoute($game_map.events[@contestant2Event.id], [
        PBMoveRoute::Graphic, @chosenContestants[1][:TrainerCharacter], 0, 2, 0
      ])
    pbMoveRoute($game_map.events[@contestant3Event.id], [
        PBMoveRoute::Graphic, @chosenContestants[2][:TrainerCharacter], 0, 2, 0
      ])
    
    #set each pkmn event's graphic
    #CONTESTANT1
    if @chosenContestants[0][:PkmnGender] == 1
      gender = "_female"
    else
      gender = ""
    end
    if @chosenContestants[0][:PkmnForm] != 0
      form = "_#{@chosenContestants[0][:PkmnForm]}"
      gender = ""
    else
      form = ""
    end
    if @chosenContestants[0][:PkmnShiny] == true
      file_path = "Followers shiny"
    else
      file_path = "Followers"
    end
    
    fullPath = "#{file_path}/"+@chosenContestants[0][:PkmnSpecies].to_s+"#{form}#{gender}"
    if !safeExists?(fullPath)
      #if the file does not exist, it's probably that the gender of the
      #contestant is not male and the filename does not contain "female"
      gender = ""
    end
    
    pbMoveRoute($game_map.events[@contestant1PkmnEvent.id], [
        PBMoveRoute::Graphic, "#{file_path}/"+@chosenContestants[0][:PkmnSpecies].to_s+"#{form}#{gender}", 0, 2, 0,
        PBMoveRoute::StepAnimeOn
      ])
    #CONTESTANT2
    if @chosenContestants[1][:PkmnGender] == 1
      gender = "_female"
    else
      gender = ""
    end
    if @chosenContestants[1][:PkmnForm] != 0
      form = "_#{@chosenContestants[1][:PkmnForm]}"
      gender = ""
    else
      form = ""
    end
    if @chosenContestants[1][:PkmnShiny] == true
      file_path = "Followers shiny"
    else
      file_path = "Followers"
    end
    
    fullPath = "#{file_path}/"+@chosenContestants[1][:PkmnSpecies].to_s+"#{form}#{gender}"
    if !safeExists?(fullPath)
      #if the file does not exist, it's probably that the gender of the
      #contestant is not male and the filename does not contain "female"
      gender = ""
    end
    
    pbMoveRoute($game_map.events[@contestant2PkmnEvent.id], [
        PBMoveRoute::Graphic, "#{file_path}/"+@chosenContestants[1][:PkmnSpecies].to_s+"#{form}#{gender}", 0, 2, 0,
        PBMoveRoute::StepAnimeOn
      ])
    #CONTESTANT3
    if @chosenContestants[2][:PkmnGender] == 1
      gender = "_female"
    else
      gender = ""
    end
    if @chosenContestants[2][:PkmnForm] != 0
      form = "_#{@chosenContestants[2][:PkmnForm]}"
      gender = ""
    else
      form = ""
    end
    if @chosenContestants[2][:PkmnShiny] == true
      file_path = "Followers shiny"
    else
      file_path = "Followers"
    end
    
    fullPath = "#{file_path}/"+@chosenContestants[2][:PkmnSpecies].to_s+"#{form}#{gender}"
    if !safeExists?(fullPath)
      #if the file does not exist, it's probably that the gender of the
      #contestant is not male and the filename does not contain "female"
      gender = ""
    end
    
    pbMoveRoute($game_map.events[@contestant3PkmnEvent.id], [
        PBMoveRoute::Graphic, "#{file_path}/"+@chosenContestants[2][:PkmnSpecies].to_s+"#{form}#{gender}", 0, 2, 0,
        PBMoveRoute::StepAnimeOn
      ])
    #PLAYER
    if @chosenContestants[3][:PkmnGender] == 1
      gender = "_female"
    else
      gender = ""
    end
    if @chosenContestants[3][:PkmnForm] != 0
      form = "_#{@chosenContestants[3][:PkmnForm]}"
      gender = ""
    else
      form = ""
    end
    if @chosenContestants[3][:PkmnShiny] == true
      file_path = "Followers shiny"
    else
      file_path = "Followers"
    end
	
	fullPath = "#{file_path}/"+@chosenContestants[3][:PkmnSpecies].to_s+"#{form}#{gender}"
    if !safeExists?(fullPath)
      #if the file does not exist, it's probably that the gender of the
      #contestant is not male and the filename does not contain "female"
      gender = ""
    end
	
    pbMoveRoute($game_map.events[@playerPkmnEvent.id], [
        PBMoveRoute::Graphic, "#{file_path}/"+@chosenContestants[3][:PkmnSpecies].to_s+"#{form}#{gender}", 0, 2, 0,
        PBMoveRoute::StepAnimeOn
      ])
  end #def self.setEventGraphics

  def self.pbMain
    #fade in
    pbToneChangeAll(Tone.new(0, 0, 0), 6)
    
    #play crowd cheering se
    pbSEPlay("Contests_Crowd",80,100)
    
    #move announcer
    pbMoveRoute($game_map.events[@announcerEvent.id], [
      PBMoveRoute::Wait, 16,
      PBMoveRoute::TurnLeft,
      
      PBMoveRoute::Wait, 16,
      PBMoveRoute::TurnRight,
      
      PBMoveRoute::Wait, 16,
      PBMoveRoute::TurnDown
    ])
    
    pbWait(1 * Graphics.frame_rate) #wait one second
    
    pbMessage(_INTL("#{ContestSettings::JUDGES[1][:Name]}: We are about to get under way with this #{@chosenRank} rank Pokémon #{@chosenType} contest!"))
    pbMessage(_INTL("I'm #{ContestSettings::JUDGES[1][:Name]}, and I'll be serving as the MC and as one of the Judges!"))
    pbMessage(_INTL("The results will be announced at the end, so please bear with me!"))
    
    pbWait(1 * Graphics.frame_rate)
    pbMoveRoute($game_map.events[@announcerEvent.id], [
      PBMoveRoute::TurnLeft
    ])
    pbWait(1 * Graphics.frame_rate/2)
    
    pbMessage(_INTL("Let me introduce our contestants!"))
    pbMessage(_INTL("Entry number 1! \\nHere's #{@chosenContestants[0][:TrainerName]} with #{@chosenContestants[0][:PkmnName]}!"))
    #play crowd cheering se
    pbSEPlay("Contests_Crowd",80,100)    
    #whistle from crowd
    pbSEPlay("Contests_Whistle",80,100)
    #wait 6 frames
    pbWait(1 * Graphics.frame_rate/2) #half a second
    #camera flash
    pbFlash(Color.new(255,255,255), 2)
    #camera shutter sound
    pbSEPlay("Contests_Camera_Shutter",80,100)
    
    pbWait(1 * Graphics.frame_rate/2) #half a second
    
    #camera flash
    pbFlash(Color.new(255,255,255), 2)
    #camera shutter sound
    pbSEPlay("Contests_Camera_Shutter",80,100)    
    
    pbWait(1 * Graphics.frame_rate)
    pbMoveRoute($game_map.events[@announcerEvent.id], [
      PBMoveRoute::TurnUp
    ])
    pbWait(2 * Graphics.frame_rate)
    
    pbMessage(_INTL("Next, it's entry number 2! #{@chosenContestants[1][:TrainerName]} with #{@chosenContestants[1][:PkmnName]}!"))
    
    #play crowd cheering se
    pbSEPlay("Contests_Crowd",80,100)    
    #whistle from crowd
    pbSEPlay("Contests_Whistle",80,100)
    #wait 6 frames
    pbWait(1 * Graphics.frame_rate/2) #half a second
    #camera flash
    pbFlash(Color.new(255,255,255), 2)
    #camera shutter sound
    pbSEPlay("Contests_Camera_Shutter",80,100)
    
    pbWait(1 * Graphics.frame_rate/2) #half a second
    
    #camera flash
    pbFlash(Color.new(255,255,255), 2)
    #camera shutter sound
    pbSEPlay("Contests_Camera_Shutter",80,100)
    
    pbWait(2 * Graphics.frame_rate)
    pbMessage(_INTL("Entry number 3! #{@chosenContestants[2][:TrainerName]} with #{@chosenContestants[2][:PkmnName]}!"))
    
    #play crowd cheering se
    pbSEPlay("Contests_Crowd",80,100)    
    #whistle from crowd
    pbSEPlay("Contests_Whistle",80,100)
    #wait 6 frames
    pbWait(1 * Graphics.frame_rate/2) #half a second
    #camera flash
    pbFlash(Color.new(255,255,255), 2)
    #camera shutter sound
    pbSEPlay("Contests_Camera_Shutter",80,100)
    
    pbWait(1 * Graphics.frame_rate/2) #half a second
    
    #camera flash
    pbFlash(Color.new(255,255,255), 2)
    #camera shutter sound
    pbSEPlay("Contests_Camera_Shutter",80,100)
    
    pbWait(1 * Graphics.frame_rate)
    pbMoveRoute($game_map.events[@announcerEvent.id], [
      PBMoveRoute::TurnRight
    ])
    pbWait(2 * Graphics.frame_rate)
    
    pbMessage(_INTL("And last but not least, entry number 4! \\PN with #{$game_variables[ContestSettings::SELECTED_POKEMON_NAME_VARIABLE]}!"))
    
    #play crowd cheering se
    pbSEPlay("Contests_Crowd",80,100)    
    #whistle from crowd
    pbSEPlay("Contests_Whistle",80,100)
    #wait 6 frames
    pbWait(1 * Graphics.frame_rate/2) #half a second
    #camera flash
    pbFlash(Color.new(255,255,255), 2)
    #camera shutter sound
    pbSEPlay("Contests_Camera_Shutter",80,100)
    
    pbWait(1 * Graphics.frame_rate/2) #half a second
    
    #camera flash
    pbFlash(Color.new(255,255,255), 2)
    #camera shutter sound
    pbSEPlay("Contests_Camera_Shutter",80,100)
    
    pbWait(1 * Graphics.frame_rate)
    pbMoveRoute($game_map.events[@announcerEvent.id], [
      PBMoveRoute::TurnDown
    ])
    pbWait(1 * Graphics.frame_rate)
    
    pbMessage(_INTL("Let's begin by having everyone get in their proper attire for evaluations."))
    pbMessage(_INTL("Contestants, dress up your Pokemon for the Visual Competition!"))
    
    #play crowd cheering se
    pbSEPlay("Contests_Crowd",80,100)
    
    #fade out transition
    Dressup.pbMain(@chosenContestants)
    #Dance.pbMain(@chosenContestants)
    #Acting.pbMain(@chosenContestants)
    
  end #self.pbMain
end #class ContestStage