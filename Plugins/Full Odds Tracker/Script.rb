class Pokemon
  # Number of times this pokemon has rolled for shininess
  # Can be set to 2 to manually mark as not-full-odds
  attr_accessor   :shiny_roll_count

  # Indicates full odds, not shininess - a non-shiny pokemon can still return true
  # on this, as long as no shiny odds changes were active when caught
  def full_odds?
    return @shiny_roll_count == 1
  end

  alias fo_shiny? shiny?
  # Shiny calculation - added code to keep track of shiny rolls
  def shiny?
    if @shiny.nil?
      @shiny_roll_count = 0 if @shiny_roll_count.nil?
      @shiny_roll_count = @shiny_roll_count + 1
      echoln "Rolling for shininess..."
    end
    return fo_shiny?
  end

  # Also overriding shiny setting code, so that if shiny is set to true this is
  # manually marked as not-full-odds
  def shiny=(value)
    @shiny_roll_count = 2 if value == true
    if value == true
        echoln "Invalidated due to set shiny"
    end
    @shiny = value
  end
end

EventHandlers.add(:on_wild_pokemon_created, :full_odds_switch,
  proc { |pkmn|
    if $bag.has?(:SHINYCHARM)
        pkmn.shiny_roll_count = 2
        echoln "Invalidated due to shiny charm"
    end
    if $player.pokedex.battled_count(pkmn.species) > 51 && Settings::HIGHER_SHINY_CHANCES_WITH_NUMBER_BATTLED
        pkmn.shiny_roll_count = 2
        echoln "Invalidated due to higher shiny chance from number fought"
    end
  }
)
        