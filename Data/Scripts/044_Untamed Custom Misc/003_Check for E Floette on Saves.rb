#$PokemonStorage[3][25]

def pbCheckSave
  if !$game_switches[82]
    #this method uses the Save File Calls script to check for Eternal Floette in
    #other save files, even in storage and the player's party, and gifts that
    #Pokemon to the player in the current save file
  
    #change the save file letter - 'A' and start searching there
    pbCheckEternalFloette if $player.save_slot != "File A" && $game_switches[82] != true
    pbCheckEternalFloette if $player.save_slot != "File B" && $game_switches[82] != true
    pbCheckEternalFloette if $player.save_slot != "File C" && $game_switches[82] != true
    pbCheckEternalFloette if $player.save_slot != "File D" && $game_switches[82] != true
    pbCheckEternalFloette if $player.save_slot != "File E" && $game_switches[82] != true
    pbCheckEternalFloette if $player.save_slot != "File F" && $game_switches[82] != true
    pbCheckEternalFloette if $player.save_slot != "File G" && $game_switches[82] != true
    pbCheckEternalFloette if $player.save_slot != "File H" && $game_switches[82] != true
  end
end

def pbCheckEternalFloette
  #if the player got Eternal floette in the save file
  
  if pbSaveTest("project-untamed","switch",82)
    #set the save file to search through
    save = pbSaveFile("project-untamed")
    
    #search party for eternal floette
    party = save[:player].party
    party.each { |pkmn|
      if pkmn && pkmn.species == :FLOETTE && pkmn.form == 5
        #found e floette in the party
        #restore pkmn
        pbAddPokemon(pkmn)
        
        #turn on floette switch
        $game_switches[82] = true
      end
    }
    
    #search boxes for eternal floette
    storage = save[:storage_system]
    storage.boxes.each do |box|
      box.pokemon.each {|pkmn|
        if pkmn && pkmn.species == :FLOETTE && pkmn.form == 5
          #found e floette in a box
          #restore pkmn
          pbAddPokemon(pkmn)
        
          #turn on floette switch
          $game_switches[82] = true
        end
      }
    end
  else
    #eternal floette not found
  end
end