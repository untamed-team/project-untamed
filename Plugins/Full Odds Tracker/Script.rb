class Pokemon
  # Number of times this pokemon has rolled for shininess
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
      @shiny_roll_count += 1
    end
    return fo_shiny?
  end

  alias fo_initialize initialize
  # Creates a new Pokémon object - added code to initialise counter for shiny rolls
  def initialize(*args)
    fo_initialize(*args)
    @shiny_roll_count = 0
  end
end
        