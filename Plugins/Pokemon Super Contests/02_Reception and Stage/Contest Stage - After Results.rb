class ContestStage
  def self.moveWinnerNextToJudge(winnerNumber)
    case winnerNumber
    when 1
      @contestant1Event.moveto(@announcerEvent.x-1, @announcerEvent.y)
      @contestant1PkmnEvent.moveto(@announcerEvent.x-2, @announcerEvent.y)
    when 2
      @contestant2Event.moveto(@announcerEvent.x-1, @announcerEvent.y)
      @contestant2PkmnEvent.moveto(@announcerEvent.x-2, @announcerEvent.y)
    when 3
      @contestant3Event.moveto(@announcerEvent.x+1, @announcerEvent.y)
      @contestant3PkmnEvent.moveto(@announcerEvent.x+2, @announcerEvent.y)
    when 4
      $game_player.moveto(@announcerEvent.x+1, @announcerEvent.y)
      @playerPkmnEvent.moveto(@announcerEvent.x+2, @announcerEvent.y)
    end #case winnerNumber
  end
  
  def self.pbMainAfterResults(winner, winnerNumber)
	#reset variable tracking what rank the player just won
	$game_variables[126] = 0
  
    pbSEPlay("Contests_Crowd",80,100)
    #whistle
    pbSEPlay("Contests_Whistle",80,100)
    
    pbWait(1 * Graphics.frame_rate/2)
    
    #camera snap
    pbSEPlay("Contests_Camera_Shutter",80,100)
    pbFlash(Color.new(255,255,255), 2)
    
    pbWait(1 * Graphics.frame_rate)
    
    mainJudge = ContestSettings::JUDGES[1][:Name]
    pbMessage(_INTL("#{mainJudge}: Congratulations!"))
    pbMessage(_INTL("Let's recognize our winner! \n#{winner[:TrainerName]}'s #{winner[:PkmnName]}!"))
    
    ribbon = RibbonEarn.ribbonToBeEarned
    pbMessage(_INTL("Our winner is awared with the #{ribbon.name}!"))
    
    case winnerNumber
    when 1
      #winner faces judge
      pbMoveRoute($game_map.events[@contestant1Event.id], [PBMoveRoute::TurnRight])
      #judge faces winner
      pbMoveRoute($game_map.events[@announcerEvent.id], [PBMoveRoute::TurnLeft])
      pbWait(1 * Graphics.frame_rate)
      pbMoveRoute($game_map.events[@contestant1Event.id], [PBMoveRoute::TurnDown])
    when 2
      #winner faces judge
      pbMoveRoute($game_map.events[@contestant2Event.id], [PBMoveRoute::TurnRight])
      #judge faces winner
      pbMoveRoute($game_map.events[@announcerEvent.id], [PBMoveRoute::TurnLeft])
      pbWait(1 * Graphics.frame_rate)
      pbMoveRoute($game_map.events[@contestant2Event.id], [PBMoveRoute::TurnDown])
    when 3
      #winner faces judge
      pbMoveRoute($game_map.events[@contestant3Event.id], [PBMoveRoute::TurnLeft])
      #judge faces winner
      pbMoveRoute($game_map.events[@announcerEvent.id], [PBMoveRoute::TurnRight])
      pbWait(1 * Graphics.frame_rate)
      pbMoveRoute($game_map.events[@contestant3Event.id], [PBMoveRoute::TurnDown])
    when 4
      #winner faces judge
      pbMoveRoute($game_player, [PBMoveRoute::TurnLeft])
      #judge faces winner
      pbMoveRoute($game_map.events[@announcerEvent.id], [PBMoveRoute::TurnRight])
      pbWait(1 * Graphics.frame_rate)
	  #give the ribbon
	  pkmnIndex = $game_variables[ContestSettings::SELECTED_POKEMON_VARIABLE]
      @playerPkmn = $player.party[pkmnIndex]
	  @playerPkmn.giveRibbon(ribbon)
      #play get sound
      pbMEPlay("Item get")
      pbWait(1 * Graphics.frame_rate)
      pbMoveRoute($game_player, [PBMoveRoute::TurnDown])
	  
	  #save the rank level to be returned after the player leaves the contest
		case @chosenRank
		when "Normal"
			$game_variables[126] = 1
		when "Great"
			$game_variables[126] = 2
		when "Ultra"
			$game_variables[126] = 3
		when "Master"
			$game_variables[126] = 4
		end
    end #case winner
    
    pbMoveRoute($game_map.events[@announcerEvent.id], [PBMoveRoute::TurnDown])
    
    pbWait(1 * Graphics.frame_rate)
    pbMessage(_INTL("We look forward to your next Contest challenge!"))
    
    pbSEPlay("Contests_Crowd",80,100)
    #whistle
    pbSEPlay("Contests_Whistle",80,100)
    pbWait(1 * Graphics.frame_rate/2)
    
    #camera snap
    pbSEPlay("Contests_Camera_Shutter",80,100)
    pbFlash(Color.new(255,255,255), 2)
    
    pbWait(1 * Graphics.frame_rate)
    
    #camera snap
    pbSEPlay("Contests_Camera_Shutter",80,100)
    pbFlash(Color.new(255,255,255), 2)
    
    pbWait(1 * Graphics.frame_rate)

    #the script ends and control goes back to the autorun/parallel process event
    #in the contestant hall to teleport the contestant back to reception
  end
  
  def self.givePrize
	case $game_variables[126]
	when 0
		pbMessage(_INTL("I'm sorry, but it looks like you didn't win anything this time. Better luck next time."))
	when 1
		prize = ContestSettings::PRIZE_POOL_NORMAL.sample
	when 2
		prize = ContestSettings::PRIZE_POOL_GREAT.sample
	when 3
		prize = ContestSettings::PRIZE_POOL_ULTRA.sample
	when 4
		prize = ContestSettings::PRIZE_POOL_MASTER.sample
	end
	
	if $game_variables[126] > 0
		pbMessage(_INTL("Congratulations! Here is your prize."))
		num = 1
		num = 10 if GameData::Item.get(prize).is_berry?
		pbReceiveItem(prize,num)
	end
  end #def self.givePrize
end #class ContestStage