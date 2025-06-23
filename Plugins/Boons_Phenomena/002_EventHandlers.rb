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
      pkmn.shiny = true if rand(65536) <= Settings::SHINY_POKEMON_CHANCE * 4
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
