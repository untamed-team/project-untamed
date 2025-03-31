class Pokemon
  # @return [Integer] the number of times this pokemon has rolled for shininess
  attr_reader   :shiny_roll_count

  # Indicates full odds, not shininess - a non-shiny pokemon can still return true
  # on this, as long as no shiny odds changes were active when caught
  # @return [Boolean] whether this pokemon's shininess was determined at full odds
  def full_odds?
    return @shiny_roll_count == 1
  end

  # Shiny calculation - overriden from Scripts/014_Pokemon/001_Pokemon.rb to keep track of shiny rolls
  # @return [Boolean] whether this Pokémon is shiny (differently colored)
  def shiny?
    if @shiny.nil?
      @shiny_roll_count += 1
      a = @personalID ^ @owner.id
      b = a & 0xFFFF
      c = (a >> 16) & 0xFFFF
      d = b ^ c
      @shiny = d < Settings::SHINY_POKEMON_CHANCE
    end
    return @shiny
  end

  # Creates a new Pokémon object - overriden from Scripts/014_Pokemon/001_Pokemon.rb to initialise counter for shiny rolls
  # @param species [Symbol, String, GameData::Species] Pokémon species
  # @param level [Integer] Pokémon level
  # @param owner [Owner, Player, NPCTrainer] Pokémon owner (the player by default)
  # @param withMoves [Boolean] whether the Pokémon should have moves
  # @param recheck_form [Boolean] whether to auto-check the form
  def initialize(species, level, owner = $player, withMoves = true, recheck_form = true)
    species_data = GameData::Species.get(species)
    @species          = species_data.species
    @form             = species_data.base_form
    @forced_form      = nil
    @time_form_set    = nil
    self.level        = level
    @steps_to_hatch   = 0
    heal_status
    @gender           = nil
    @shiny            = nil
    @shiny_roll_count = 0
    @ability_index    = nil
    @ability          = nil
    @nature           = nil
    @nature_for_stats = nil
    @item             = nil
    @mail             = nil
    @moves            = []
    reset_moves if withMoves
    @first_moves      = []
    @ribbons          = []
    @cool             = 0
    @beauty           = 0
    @cute             = 0
    @smart            = 0
    @tough            = 0
    @sheen            = 0
    @pokerus          = 0
    @name             = nil
    @happiness        = species_data.happiness
    @poke_ball        = :POKEBALL
    @markings         = []
    @iv               = {}
    @ivMaxed          = {}
    @ev               = {}
    GameData::Stat.each_main do |s|
      @iv[s.id]       = 0#rand(IV_STAT_LIMIT + 1) #by low
      @ev[s.id]       = 0
    end
    case owner
    when Owner
      @owner = owner
    when Player, NPCTrainer
      @owner = Owner.new_from_trainer(owner)
    else
      @owner = Owner.new(0, "", 2, 2)
    end
    @obtain_method    = 0   # Met
    @obtain_method    = 4 if $game_switches && $game_switches[Settings::FATEFUL_ENCOUNTER_SWITCH]
    @obtain_map       = ($game_map) ? $game_map.map_id : 0
    @obtain_text      = nil
    @obtain_level     = level
    @hatched_map      = 0
    @timeReceived     = pbGetTimeNow.to_i
    @timeEggHatched   = nil
    @fused            = nil
    @personalID       = rand(2**16) | (rand(2**16) << 16)
    @hp               = 1
    @totalhp          = 1
    #by low
    @evolution_steps  = 0
    @remaningHPBars   = [0, 0] # current, max hp bar
    @hpbarsstorage    = [0, 0] # break, restore hp bar
    @willmega         = false
    @sketchMove       = nil
    calc_stats
    if @form == 0 && recheck_form
      f = MultipleForms.call("getFormOnCreation", self)
      if f
        self.form = f
        reset_moves if withMoves
      end
    end
  end
end
        