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

def pbChooseDarkOrPsychicType
  $game_variables[36] = 0
  pbChooseTradablePokemon(36, 37, proc { |pkmn| pkmn.types.contains?(:PSYCHIC)|| pkmn.types.contains?(:DARK)})
end

def pbChoosePkmnWithPowerfulIceOrGrassMove
  $game_variables[36] = 0
  pbChooseTradablePokemon(36, 37, proc { |pkmn| pkmn.moves.any? { |m| (m&.type == :ICE || m&.type == :GRASS) && m&.base_damage >= 55 }})
end #def pbChoosePkmnWithPowerfulIceOrGrassMove

def pbUsePowerfulIceOrGrassMove(pkmn)
  for move in pkmn.moves
    #find the first ice or grass move with 55+ bp
    moveSymbol = move.id if (move.type == :ICE || move.type == :GRASS) && move.base_damage >= 55
  end

  userEventID = $game_player
  targetEventID = 2
  GardenUtil.showMoveAnimationOnScreen(moveSymbol, userEventID, targetEventID)
end #def pbUsePowerfulIceOrGrassMove