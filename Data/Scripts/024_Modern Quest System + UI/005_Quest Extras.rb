def pbChoosePumpkaboo
  $game_variables[36] = 0
  pbChooseTradablePokemon(36, 37, proc { |pkmn| pkmn.isSpecies?(:PUMPKABOO) })
end

def pbPumpkabooQuestReward
  pkmn = Pokemon.new(:PHANTUMP, 5)
  pkmn.owner.id = $player.make_foreign_ID
  #pkmn.ability_index = 2
  pkmn.learn_move(:BESTOW)
  pkmn.calc_stats
  pbAddForeignPokemon(pkmn, 5, _I("Gabriel"), _I("Stumpy"))
end

def pbChooseWaterOrFireType
  $game_variables[36] = 0
  pbChooseTradablePokemon(36, 37, proc { |pkmn| pkmn.types.contains?(:FIRE)|| pkmn.types.contains?(:WATER)})
end