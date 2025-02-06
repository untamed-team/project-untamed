class ContestReception
  
  def self.nevermind
    pbMessage(_INTL("We hope you will participate another time."))
    @exit = 1
    return @exit
  end
  
  def self.reception
    @exit = 0
    
    pbMessage(_INTL("Hello! This is the reception counter for Pokémon Contests."))
    enterCancel = [_INTL("Enter"),_INTL("Cancel")]
    choice = pbMessage(_INTL("Would you like to enter your Pokemon in our Contest?"),enterCancel,-1)
    
    case choice
    when 0
      #choose type of contest
      ContestTypeRank.chooseType
      
      #choose contest rank
      ContestTypeRank.chooseRank if @exit != 1
      
      #choose pokemon contestant
      ContestContestant.choosePokemonForContest if @exit != 1
    
      #determine the ribbon to be earned based on player's selection
      RibbonEarn.ribbonToBeEarned if @exit != 1
      
      #notice if the selected pokemon already has ribbon it would earn
      RibbonEarn.checkHasRibbon if @exit != 1
    else
      #player said nevermind
      self.nevermind
    end #case choice
  
    if @exit != 1
      #continue to enter the contest because the pokemon does not have the ribbon
      #or because it does have the ribbon but the player chose to enter the contest anyway
      pbMessage(_INTL("Okay, your Pokemon will be entered in this Contest."))
      pbMessage(_INTL("Your Pokemon is Entry No.4. The Contest will begin shortly."))
    else
      #tell the conditional statement outside the script that we cancelled entering
      #the contest
      return -1
    end
  end #self.reception
end #class ContestReception
################################################################
class ContestTypeRank
  
  def self.chooseType
    if $player.party.size <= 0
      pbMessage(_INTL("You must have at least one Pokémon in your party to participate."))
      return #exit the conversation with receiptionist
    end
    
    #choose type
    contestTypes = [_INTL("Coolness Contest"), _INTL("Beauty Contest"), _INTL("Cuteness Contest"), _INTL("Smartness Contest"), _INTL("Toughness Contest"), _INTL("Exit")]
    typeChoice = pbMessage(_INTL("Which type of Contest would you like to enter?"), contestTypes, -1)
      
    #save type to variable
    case typeChoice
    when 0
      @chosenType = "Coolness"
    when 1
      @chosenType = "Beauty"
    when 2
      @chosenType = "Cuteness"
    when 3
      @chosenType = "Smartness"
    when 4
      @chosenType = "Toughness"
    else
      ContestReception.nevermind
    end
  end
  
  def self.chooseRank
    #choose rank
    contestRanks = [_INTL("Normal Rank"), _INTL("Great Rank"), _INTL("Ultra Rank"), _INTL("Master Rank"), _INTL("Exit")]
    rankChoice = pbMessage(_INTL("Which Rank would you like to enter?"), contestRanks, -1)
      
    #save type to variable
    case rankChoice
    when 0
      @chosenRank = "Normal"
    when 1
      @chosenRank = "Great"
    when 2
      @chosenRank = "Ultra"
    when 3
      @chosenRank = "Master"
    else
      ContestReception.nevermind
    end
    
  end #self.chooseRank  
  
  def self.getChosenType
    return @chosenType
  end
  
  def self.getChosenRank
    return @chosenRank
  end
  
end #class ContestTypeRank
################################################################
#start choose pokemon scene
class ContestContestant
  def self.choosePokemonForContest
    rank = ContestTypeRank.getChosenRank
	type = ContestTypeRank.getChosenType
	
    #choose the contestant pokemon
    pbMessage(_INTL("Which Pokémon would you like to enter?"))

    #using pbChooseTradablePokemon because it already rules out eggs and shadow Pokemon
    pbChooseTradablePokemon(ContestSettings::SELECTED_POKEMON_VARIABLE, ContestSettings::SELECTED_POKEMON_NAME_VARIABLE,
			proc { |pkmn|
			next false if pkmn.moves.length <= 1
			next false if rank == "Great" && type == "Coolness" && !pkmn.hasRibbon?(:SINNOHCOOL)
			next false if rank == "Ultra" && type == "Coolness" && !pkmn.hasRibbon?(:SINNOHCOOLSUPER)
			next false if rank == "Master" && type == "Coolness" && !pkmn.hasRibbon?(:SINNOHCOOLHYPER)
			
			next false if rank == "Great" && type == "Beauty" && !pkmn.hasRibbon?(:SINNOHBEAUTY)
			next false if rank == "Ultra" && type == "Beauty" && !pkmn.hasRibbon?(:SINNOHBEAUTYSUPER)
			next false if rank == "Master" && type == "Beauty" && !pkmn.hasRibbon?(:SINNOHBEAUTYHYPER)
			
			next false if rank == "Great" && type == "Cuteness" && !pkmn.hasRibbon?(:SINNOHCUTE)
			next false if rank == "Ultra" && type == "Cuteness" && !pkmn.hasRibbon?(:SINNOHCUTESUPER)
			next false if rank == "Master" && type == "Cuteness" && !pkmn.hasRibbon?(:SINNOHCUTEHYPER)
			
			next false if rank == "Great" && type == "Smartness" && !pkmn.hasRibbon?(:SINNOHSMART)
			next false if rank == "Ultra" && type == "Smartness" && !pkmn.hasRibbon?(:SINNOHSMARTSUPER)
			next false if rank == "Master" && type == "Smartness" && !pkmn.hasRibbon?(:SINNOHSMARTHYPER)
			
			next false if rank == "Great" && type == "Toughness" && !pkmn.hasRibbon?(:SINNOHTOUGH)
			next false if rank == "Ultra" && type == "Toughness" && !pkmn.hasRibbon?(:SINNOHTOUGHSUPER)
			next false if rank == "Master" && type == "Toughness" && !pkmn.hasRibbon?(:SINNOHTOUGHHYPER)
			
			next true
			}
	)
	
    if $game_variables[ContestSettings::SELECTED_POKEMON_VARIABLE] == -1
      #player did not choose a pokemon
      ContestReception.nevermind
    else
      #an able pokemon was chosen
      pkmnIndex = $game_variables[ContestSettings::SELECTED_POKEMON_VARIABLE]
      @playerPkmn = $player.party[pkmnIndex]
    end
    
  end #def self.choosePokemonForContest
  
  def self.getPlayerPkmn
    return @playerPkmn
  end
  
end #class ContestContestant
################################################################
class RibbonEarn
  def self.ribbonToBeEarned
    #modify this section depending on what ribbon you want to be earned from the
    #chosen selection
    #the names come from what ribbons are defined in PBS
    
    @chosenType = ContestTypeRank.getChosenType
    @chosenRank = ContestTypeRank.getChosenRank
    
    case @chosenType
    when "Coolness"
      ribbon = ContestSettings::RIBBON_NORMAL_COOL if @chosenRank == "Normal"
      ribbon = ContestSettings::RIBBON_GREAT_COOL if @chosenRank == "Great"
      ribbon = ContestSettings::RIBBON_ULTRA_COOL if @chosenRank == "Ultra"
      ribbon = ContestSettings::RIBBON_MASTER_COOL if @chosenRank == "Master"
    
    when "Beauty"
      ribbon = ContestSettings::RIBBON_NORMAL_BEAUTY if @chosenRank == "Normal"
      ribbon = ContestSettings::RIBBON_GREAT_BEAUTY if @chosenRank == "Great"
      ribbon = ContestSettings::RIBBON_ULTRA_BEAUTY if @chosenRank == "Ultra"
      ribbon = ContestSettings::RIBBON_MASTER_BEAUTY if @chosenRank == "Master"

    when "Cuteness"
      ribbon = ContestSettings::RIBBON_NORMAL_CUTE if @chosenRank == "Normal"
      ribbon = ContestSettings::RIBBON_GREAT_CUTE if @chosenRank == "Great"
      ribbon = ContestSettings::RIBBON_ULTRA_CUTE if @chosenRank == "Ultra"
      ribbon = ContestSettings::RIBBON_MASTER_CUTE if @chosenRank == "Master"
    
    when "Smartness"
      ribbon = ContestSettings::RIBBON_NORMAL_SMART if @chosenRank == "Normal"
      ribbon = ContestSettings::RIBBON_GREAT_SMART if @chosenRank == "Great"
      ribbon = ContestSettings::RIBBON_ULTRA_SMART if @chosenRank == "Ultra"
      ribbon = ContestSettings::RIBBON_MASTER_SMART if @chosenRank == "Master"
  
    when "Toughness"
      ribbon = ContestSettings::RIBBON_NORMAL_TOUGH if @chosenRank == "Normal"
      ribbon = ContestSettings::RIBBON_GREAT_TOUGH if @chosenRank == "Great"
      ribbon = ContestSettings::RIBBON_ULTRA_TOUGH if @chosenRank == "Ultra"
      ribbon = ContestSettings::RIBBON_MASTER_TOUGH if @chosenRank == "Master"
    end
    ribbon_data = GameData::Ribbon.try_get(ribbon)
    return ribbon_data
  end #self.ribbonToBeEarned
    
  def self.getRibbon
    return @ribbon
  end
  
  def self.checkHasRibbon
    pkmnIndex = $game_variables[ContestSettings::SELECTED_POKEMON_VARIABLE]
    if $player.party[pkmnIndex].hasRibbon?(@ribbon)
      pbMessage(_INTL("Oh, but that Ribbon..."))
      pbMessage(_INTL("Your Pokemon has won this Contest before, hasn't it?"))
      if pbConfirmMessage("Would you like to enter it in this Contest anyway?")
        #ContestReception.reception will enter the player into the contest
      else
        ContestReception.nevermind
      end
    else
      #ContestReception.reception will enter the player into the contest
    end
    
  end #def self.checkHasRibbon
    
end #class RibbonEarn