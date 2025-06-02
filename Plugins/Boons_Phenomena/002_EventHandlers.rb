################################################################################
# Event handlers
################################################################################

# Cancels phenomenon on battle start to stop animation during battle intro
EventHandlers.add(:on_start_battle, :boon_phenomenon_start_battle,
                  proc {
  Phenomenon.expBoost = true if PhenomenonConfig::Pokemon[:expBoost] && Phenomenon.playerOn?
  Phenomenon.cancel
})

EventHandlers.add(:on_end_battle, :boon_phenomenon_end_battle,
                  proc {
  Phenomenon.expBoost = false
  Phenomenon.activated = false
})

# Generate the phenomenon or process the player standing on it
EventHandlers.add(:on_player_step_taken, :boon_phenomenon_update,
                  proc {
  if Phenomenon.possible
    if Phenomenon.playerOn?
      Phenomenon.activate
    elsif Phenomenon.waiting?
      if Graphics.frame_count >= Phenomenon.instance.timer
        Phenomenon.generate
      end
    elsif Phenomenon.instance == nil && Phenomenon.types.size && (PhenomenonConfig::Switch == -1 || $game_switches[PhenomenonConfig::Switch])
      Phenomenon.instance = PhenomenonInstance.new(Phenomenon.types)
    end
  end
})
# Remove any phenomenon events on map change
EventHandlers.add(:on_leave_map, :boon_phenomenon_leave_map,
                  proc {
  Phenomenon.cancel
})

# Process map available encounters on map change
EventHandlers.add(:on_enter_map, :boon_phenomenon_enter_map,
                  proc {
  Phenomenon.load_types
})

# Modify the wild encounter based on the settings above
EventHandlers.add(:on_wild_pokemon_created, :boon_phenomenon_wild_created,
                  proc { |pkmn|
  if Phenomenon.activated
    if PhenomenonConfig::Pokemon[:shiny] # 4x the normal shiny chance
      pkmn.makeShiny if rand(65536) <= Settings::SHINY_POKEMON_CHANCE * 4
    end
    if PhenomenonConfig::Pokemon[:ivs] > -1 && rand(PhenomenonConfig::Pokemon[:ivs]) == 0
      ivs = [:HP, :ATTACK, :SPECIAL_ATTACK, :DEFENSE, :SPECIAL_DEFENSE, :SPEED]
      ivs.shuffle!
      ivs[0..1].each do |i|
        pkmn.iv[i] = 31
      end
    end
    if PhenomenonConfig::Pokemon[:eggMoves] > -1 && rand(PhenomenonConfig::Pokemon[:eggMoves]) == 0
      moves = GameData::Species.get_species_form(pkmn.species, pkmn.form).egg_moves
      pkmn.learn_move(moves.random) if moves.length > 0
    end
    if PhenomenonConfig::Pokemon[:hiddenAbility] > -1 && rand(PhenomenonConfig::Pokemon[:hiddenAbility]) == 0
      a = GameData::Species.get(pkmn.species).hidden_abilities
      if !a.nil? && a.kind_of?(Array)
        pkmn.ability = a.random
      end
    end
  end
})

################################################################################
# Class modifiers
################################################################################
class Spriteset_Map
  alias update_phenomenon update

  def update
    if Phenomenon.possible && Phenomenon.active? && !$game_temp.in_menu
      ph = Phenomenon.instance
      return if !ph
      if (PhenomenonConfig::Switch != -1 &&
          !$game_switches[PhenomenonConfig::Switch]) || Graphics.frame_count >= ph.timer
        Phenomenon.cancel
      elsif !ph.drawing && Graphics.frame_count % 40 == 0 # play animation every 140 update ticks
        ph.drawing = true
        sound = ph.type == :PhenomenonGrass ? (Graphics.frame_count % 80 == 0) : true
        Phenomenon.drawAnim(sound)
      end
    end
    update_phenomenon
  end
end
