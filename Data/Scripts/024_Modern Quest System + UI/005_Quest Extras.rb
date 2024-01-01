def pbChoosePumpkaboo
  $game_variables[36] = 0
pbChooseTradablePokemon(36, 37,
  proc { |pkmn|
    pkmn.isSpecies?(:PUMPKABOO) &&
  if !isTaskComplete(:Quest5,"Show a Small Pumpkaboo") then
    pkmn.form==0
  end ||
  if !isTaskComplete(:Quest5,"Show an Average Pumpkaboo") then
    pkmn.form==1
  end ||
  if !isTaskComplete(:Quest5,"Show a Large Pumpkaboo") then
    pkmn.form==2
  end ||
  if !isTaskComplete(:Quest5,"Show a Super Size Pumpkaboo") then
    pkmn.form==3
  end
  }
)
end

def pbPumpkabooQuestReward
  pkmn = Pokemon.new(:PHANTUMP, 5)
  pkmn.owner.id = $player.make_foreign_ID
  pkmn.ability_index = 2
  pkmn.learn_move(:BESTOW)
  pkmn.calc_stats
  pbAddForeignPokemon(pkmn, 5, _I("Gabriel"), _I("Stumpy"))
end