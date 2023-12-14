#===============================================================================
# Automatic Level Scaling Event Handlers
# By Benitex
#===============================================================================
=begin
# Activates script when a wild pokemon is created
EventHandlers.add(:on_wild_pokemon_created, :automatic_level_scaling,
  proc { |pokemon|
    id = $game_variables[LevelScalingSettings::WILD_VARIABLE]
    if $game_switches[68] #id != 0
      AutomaticLevelScaling.setDifficulty(id)
      AutomaticLevelScaling.setNewLevel(pokemon)
    end
  }
)
=end
# Activates script when a trainer pokemon is created
EventHandlers.add(:on_trainer_load, :automatic_level_scaling,
  proc { |trainer|
    id = $game_switches[LevelScalingSettings::TRAINER_VARIABLE]
    if trainer && id
      AutomaticLevelScaling.setDifficulty(id)
      avarage_level = 0
      trainer.party.each { |pokemon| avarage_level += pokemon.level }
      avarage_level /= trainer.party.length

      for pokemon in trainer.party do
        AutomaticLevelScaling.setNewLevel(pokemon, pokemon.level - avarage_level)
      end
    end
  }
)

# Updates partner's pokemon levels after battle
EventHandlers.add(:on_end_battle, :update_partner_levels,
  proc { |_decision, _canLose|
    if $PokemonGlobal.partner != nil
      avarage_level = 0
      $PokemonGlobal.partner[3].each { |pokemon| avarage_level += pokemon.level }
      avarage_level /= $PokemonGlobal.partner[3].length

      for pokemon in $PokemonGlobal.partner[3] do
        AutomaticLevelScaling.setNewLevel(pokemon, pokemon.level - avarage_level)
      end
    end
  }
)
