def pbChoosePumpkaboo
  $game_variables[36] = 0
  pkmn = pbChooseTradablePokemon(36, 37, proc { |pkmn| pkmn.isSpecies?(:PUMPKABOO) })
  print pkmn.name
end

def pbPumpkabooQuestReward
  pkmn = Pokemon.new(:PHANTUMP, 5)
  pkmn.owner.id = $player.make_foreign_ID
  #pkmn.ability_index = 2
  pkmn.learn_move(:BESTOW)
  pkmn.calc_stats
  pbAddForeignPokemon(pkmn, 5, _I("Gabriel"), _I("Stumpy"))
end