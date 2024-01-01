#===============================================================================
# Battle Deluxe
#===============================================================================

#-------------------------------------------------------------------------------
# Temp data storage for deluxe battle settings.
#-------------------------------------------------------------------------------
class Game_Temp
  attr_accessor :dx_rules
  attr_accessor :dx_midbattle
  attr_accessor :dx_pokemon
  
  def dx_rules;      return @dx_rules;     end
  def dx_midbattle;  return @dx_midbattle; end
  def dx_pokemon;    return @dx_pokemon;   end
  
  def dx_rules?;     return @dx_rules     && !@dx_rules.empty?;     end
  def dx_midbattle?; return @dx_midbattle && !@dx_midbattle.empty?; end
  def dx_pokemon?;   return @dx_pokemon   && !@dx_pokemon.empty?;   end
  
  def dx_rules=(value)
    @dx_rules = value || {}
  end
  
  def dx_midbattle=(value)
    @dx_midbattle = value || {}
  end
  
  def dx_pokemon=(value)
    @dx_pokemon = value || {}
  end
  
  def dx_clear
    if dx_rules?
      @dx_rules.keys.each do |key|
        case key
        when :nomega then $game_switches[Settings::NO_MEGA_EVOLUTION] = false
        when :nozmove, :noultra, :nodynamax
          next if !PluginManager.installed?("ZUD Mechanics")
          $game_switches[Settings::NO_Z_MOVE]      = false if key == :nozmove
          $game_switches[Settings::NO_ULTRA_BURST] = false if key == :noultra
          $game_switches[Settings::NO_DYNAMAX]     = false if key == :nodynamax
        when :nostyles
          next if !PluginManager.installed?("PLA Battle Styles")
          $game_switches[Settings::NO_STYLE_MOVES] = false
        when :notera
          next if !PluginManager.installed?("Terastal Phenomenon")
          $game_switches[Settings::NO_TERASTALLIZE] = false
        when :nozodiac
          next if !PluginManager.installed?("Pokemon Birthsigns")
          $game_switches[Settings::NO_ZODIAC_POWER] = false
        when :nofocus
          next if !PluginManager.installed?("Focus Meter System")
          $game_switches[Settings::NO_FOCUS_MECHANIC] = false
        end
      end
      @dx_rules.clear
    end
    @dx_midbattle.clear if dx_midbattle?
    @dx_pokemon.clear if dx_pokemon?
    $PokemonGlobal.nextBattleBGM = nil
    pbDeregisterPartner
    clear_battle_rules
  end
end


#-------------------------------------------------------------------------------
# Initiates battles with deluxe settings.
#-------------------------------------------------------------------------------
class TrainerBattle
  def self.dx_start(foes, rules = {}, midbattle = {})
    $game_temp.dx_rules     = rules
    $game_temp.dx_midbattle = midbattle
    rules[:rank] = nil
    rules[:outcome] = 1 if !rules[:outcome]
    foe_size = 0
    foes.each { |f| foe_size += 1 if f.is_a?(Array) || f.is_a?(Symbol) || f.is_a?(NPCTrainer)}
    oldTrainer = [$player.name, $player.outfit, $player.party]
    pbApplyBattleRules(foe_size)
    if $game_temp.dx_midbattle.is_a?(Symbol) && hasConst?(EssentialsDeluxe, $game_temp.dx_midbattle)
      hash = getConst(EssentialsDeluxe, $game_temp.dx_midbattle).clone
      $game_temp.dx_midbattle = hash
    end
    outcome = TrainerBattle.start(*foes)
    if rules[:player]
      $player.name = oldTrainer[0]
      $player.outfit = oldTrainer[1]
    end
    if rules[:party]
      $player.party = oldTrainer[2]
    end
    $game_temp.dx_clear
    return outcome
  end
end

class WildBattle
  def self.dx_start(foes, rules = {}, pokemon = {}, midbattle = {})
    $game_temp.dx_rules     = rules
    $game_temp.dx_pokemon   = pokemon
    $game_temp.dx_midbattle = midbattle
    rules[:rank] = nil
    rules[:outcome] = 1 if !rules[:outcome]
    foe_size = 0
    foes.each { |f| foe_size += 1 if f.is_a?(Array) || f.is_a?(Symbol) || f.is_a?(Pokemon) }
    oldTrainer = [$player.name, $player.outfit, $player.party]
    pbApplyBattleRules(foe_size, true)
    pkmn = []
    for i in 0...foes.length / 2
      species, level = foes[i * 2], foes[i * 2 + 1]
      next if !GameData::Species.exists?(species)
      pkmn.push(Pokemon.new(species, level))
    end
    pbApplyWildAttributes(pkmn)
    if $game_temp.dx_midbattle.is_a?(Symbol) && hasConst?(EssentialsDeluxe, $game_temp.dx_midbattle)
      hash = getConst(EssentialsDeluxe, $game_temp.dx_midbattle).clone
      $game_temp.dx_midbattle = hash
    end
    outcome = WildBattle.start(*pkmn, can_override: false)
    if rules[:player]
      $player.name = oldTrainer[0]
      $player.outfit = oldTrainer[1]
    end
    if rules[:party]
      $player.party = oldTrainer[2]
    end	  
    $game_temp.dx_clear
    return outcome
  end
end


#-------------------------------------------------------------------------------
# Applies all battle rules for the next battle.
#-------------------------------------------------------------------------------
def pbApplyBattleRules(foeside, wildbattle = false)
  rules = $game_temp.dx_rules
  #-----------------------------------------------------------------------------
  # General rules.
  #-----------------------------------------------------------------------------
  setBattleRule("setStyle")            if rules[:setmode]
  setBattleRule("canLose")             if rules[:canlose]
  setBattleRule("noexp")               if rules[:noexp]
  setBattleRule("nomoney")             if rules[:nomoney]
  setBattleRule("nopartner")           if rules[:nopartner]
  setBattleRule("outcomeVar",             rules[:outcome])
  #-----------------------------------------------------------------------------
  # Wild Battle-only rules.
  #-----------------------------------------------------------------------------
  setBattleRule("cannotRun")           if wildbattle && rules[:noflee]
  setBattleRule("disablePokeBalls")    if wildbattle && rules[:nocapture]
  setBattleRule("forceCatchIntoParty") if wildbattle && rules[:catchtoparty]
  #-----------------------------------------------------------------------------
  # Temporarily changes the player character's name and/or outfit.
  #-----------------------------------------------------------------------------
  if rules[:player]
    case rules[:player]
    when String  then $player.name = rules[:player]
    when Integer then $player.outfit = rules[:player]
    when Array
      rules[:player].each do |tr|
        case tr
        when String  then $player.name = tr
        when Integer then $player.outfit = tr
        end
      end
    end
  end
  #-----------------------------------------------------------------------------
  # Sets the player's temporary party.
  #-----------------------------------------------------------------------------
  if rules[:party]
    newparty = []
    species = nil
    rules[:party].each do |data|
      case data
      when Pokemon
        newparty.push(data)
      when Symbol
        next if !GameData::Species.exists?(data)
        species = data
      when Integer
        next if !species
        newparty.push(Pokemon.new(species, data))
        species = nil
      end
    end
    $player.party = newparty if !newparty.empty?
  end
  #-----------------------------------------------------------------------------
  # Sets partner trainer.
  #-----------------------------------------------------------------------------
  if rules[:partner].is_a?(Array)
    pbRegisterPartner(*rules[:partner])
    setBattleRule("double")
  end
  #-----------------------------------------------------------------------------
  # Sets the battle size.
  # Caps out at 3, and scales down if the player doesn't have enough viable
  # Pokemon to meet the set size.
  #-----------------------------------------------------------------------------
  case rules[:size]
  when String
    setBattleRule(rules[:size])
  when Numeric
    rules[:size] = 1 if rules[:size] < 1
    rules[:size] = 3 if rules[:size] > 3
    if rules[:size] > $player.able_pokemon_count
      until rules[:size] == $player.able_pokemon_count
        rules[:size] -= 1
      end
    end
  else
    rules[:size] = foeside
  end
  setBattleRule(sprintf("%dv%d", rules[:size], foeside)) if $game_temp.battle_rules["size"].nil?
  #-----------------------------------------------------------------------------
  # Sets weather.
  # Randomizes weather if set to :random. Converts primordial weathers to normal ones.
  #-----------------------------------------------------------------------------
  if rules[:weather] == :Random
    weather = []
    GameData::BattleWeather::DATA.keys.each { |key| weather.push(key) }
    rules[:weather] = weather.sample
  end
  case rules[:weather]
  when :HarshSun    then rules[:weather] = :Sun
  when :HeavyRain   then rules[:weather] = :Rain
  when :StrongWinds then rules[:weather] = nil
  when :None        then rules[:weather] = nil
  end
  setBattleRule("weather", rules[:weather]) if rules[:weather]
  #-----------------------------------------------------------------------------
  # Sets terrain.
  # Randomizes terrain if set to :random.
  #-----------------------------------------------------------------------------
  if rules[:terrain] == :Random
    terrain = []
    GameData::BattleTerrain::DATA.keys.each { |key| terrain.push(key) }
    rules[:terrain] = terrain.sample
  end
  case rules[:terrain]
  when :None then rules[:terrain] = nil
  end
  setBattleRule("terrain", rules[:terrain]) if rules[:terrain]
  #-----------------------------------------------------------------------------
  # Sets environment.
  # Randomizes environment if set to :random. Backdrop changes to suit the environment.
  #-----------------------------------------------------------------------------
  if rules[:environ] == :Random
    environment = []
    GameData::Environment::DATA.keys.each { |key| environment.push(key) }
    rules[:environ] = environment.sample
  end
  pbSetBackdrop(rules[:environ]) if rules[:environ]
  #-----------------------------------------------------------------------------
  # Sets the backdrop and bases.
  #-----------------------------------------------------------------------------
  if rules[:backdrop]
    if rules[:backdrop].is_a?(Array)
      bg, base = rules[:backdrop][0], rules[:backdrop][1]
    else
      bg = base = rules[:backdrop]
    end
    setBattleRule("backdrop", bg) if pbResolveBitmap("Graphics/Battlebacks/#{bg}_bg")
    setBattleRule("base", base) if base && pbResolveBitmap("Graphics/Battlebacks/#{base}_base0")
  end
  #-----------------------------------------------------------------------------
  # Sets raid battle rules.
  #-----------------------------------------------------------------------------
  if PluginManager.installed?("ZUD Mechanics") && rules[:rank]
    pokemon = $game_temp.dx_pokemon
    if !rules[:bgm]
      raid_music = (rules[:rank] == 6) ? "Battle! Legendary Raid" : "Battle! Max Raid"
      raid_music = "Battle! Eternatus - Phase 2" if pokemon[:species] == :ETERNATUS
      rules[:bgm] = raid_music
    end
    rules[:hard] = false if inMaxLair?
    if rules[:autoscale]
      rules[:turns] += ((pokemon[:level] + 5) / 10 * rules[:size]).ceil + 1 if rules[:size] < 3 && pokemon[:level] > 20
      rules[:kocount] -= 1 if pokemon[:level] > 55
      for i in [25, 35, 45, 55, 65]
        rules[:shield] += 1 if pokemon[:level] > i
      end
      rules[:shield] += 1 if rules[:hard] || pokemon[:level] > 70
    end
    rules[:turns]    = 5  if rules[:turns]  < 5
    rules[:turns]    = 25 if rules[:turns]  > 25
    rules[:kocount]  = 1 if rules[:kocount] < 1 || rules[:size] == 1
    rules[:kocount]  = 6 if rules[:kocount] > 6
    rules[:shield]   = 1 if rules[:shield]  < 1
    rules[:shield]   = 8 if rules[:shield]  > 8
    rules[:timer_bonus]    = rules[:turns]
    rules[:perfect_bonus]  = true if !rules.has_key?(:perfect_bonus) 
    rules[:fairness_bonus] = true
  end
  rules[:hard] = nil if rules[:hard] && !rules[:rank]
  #-----------------------------------------------------------------------------
  # Sets battle music.
  #-----------------------------------------------------------------------------
  case rules[:victory]
  when :None  then $PokemonGlobal.nextBattleVictoryBGM = ""
  when String then $PokemonGlobal.nextBattleVictoryBGM = rules[:victory]
  end
  $PokemonGlobal.nextBattleBGM = rules[:bgm] if rules[:bgm].is_a?(String)
  #-----------------------------------------------------------------------------
  # Sets rules for special battle mechanics.
  #-----------------------------------------------------------------------------
  $game_switches[Settings::NO_MEGA_EVOLUTION]   = true if rules[:nomega]
  if PluginManager.installed?("ZUD Mechanics")
    $game_switches[Settings::NO_Z_MOVE]         = true if rules[:nozmove]
    $game_switches[Settings::NO_ULTRA_BURST]    = true if rules[:noultra]
    $game_switches[Settings::NO_DYNAMAX]        = true if rules[:nodynamax]
  end
  if PluginManager.installed?("PLA Battle Styles") && rules[:nostyles]
    $game_switches[Settings::NO_STYLE_MOVES]    = true
  end
  if PluginManager.installed?("Terastal Phenomenon") && rules[:notera]
    $game_switches[Settings::NO_TERASTALLIZE]   = true
  end
  if PluginManager.installed?("Pokemon Birthsigns") && rules[:nozodiac]
    $game_switches[Settings::NO_ZODIAC_POWER]   = true
  end
  if PluginManager.installed?("Focus Meter System") && rules[:nofocus]
    $game_switches[Settings::NO_FOCUS_MECHANIC] = true
  end
end


#-------------------------------------------------------------------------------
# Controls capture outcomes with the [:setcapture] rule.
#-------------------------------------------------------------------------------
module Battle::CatchAndStoreMixin
  alias dx_pbCaptureCalc pbCaptureCalc
  def pbCaptureCalc(*args)
    if $game_temp.dx_rules? && !$game_temp.dx_rules[:setcapture].nil?
      return ($game_temp.dx_rules[:setcapture]) ? 4 : 0
    end
    dx_pbCaptureCalc(*args)
  end
  
  alias dx_pbRecordAndStoreCaughtPokemon pbRecordAndStoreCaughtPokemon
  def pbRecordAndStoreCaughtPokemon
    return if $game_temp.dx_rules? && $game_temp.dx_rules[:setcapture] == :Demo
    dx_pbRecordAndStoreCaughtPokemon
  end
end


#-------------------------------------------------------------------------------
# Applies environment and background settings from the [:environ] rule.
#-------------------------------------------------------------------------------
def pbSetBackdrop(environment)
  return if !GameData::Environment.exists?(environment)
  case environment
  when :None;                     bg = base = "city";            ebdx = :CITY        
  when :Grass, :TallGrass;        bg = "field"; base = "grass";  ebdx = :OUTDOOR
  when :MovingWater, :StillWater; bg = base = "water";           ebdx = :WATER  
  when :Puddle;                   bg = "water"; base = "puddle"; ebdx = :MOUNTAINLAKE
  when :Underwater;               bg = base = "underwater";      ebdx = :UNDERWATER        
  when :Cave;                     bg = base = "cave3";           ebdx = :DARKCAVE            
  when :Rock;                     bg = base = "rocky";           ebdx = :MOUNTAIN
  when :Volcano;                  bg = base = "rocky";           ebdx = :MAGMA			
  when :Sand;                     bg = "rocky"; base = "sand";   ebdx = :SAND   
  when :Forest;                   bg = base = "forest";          ebdx = :FOREST            
  when :ForestGrass;              bg = "forest"; base = "grass"; ebdx = :FOREST  
  when :Snow;                     bg = base = "snow";            ebdx = :SNOW              
  when :Ice;                      bg = "snow"; base = "ice";     ebdx = :ICE     
  when :Graveyard;                bg = base = "distortion";      ebdx = :DARKNESS        
  when :Sky;                      bg = base = "sky";             ebdx = :SKY               
  when :Space;                    bg = base = "space";           ebdx = :SPACE  
  when :UltraSpace;               bg = base = "ultraspace";      ebdx = :DIMENSION  
  end
  setBattleRule("environ", environment)
  setBattleRule("base", base) if pbResolveBitmap("Graphics/Battlebacks/#{bg}_bg")
  setBattleRule("backdrop", bg) if pbResolveBitmap("Graphics/Battlebacks/#{base}_base0")
end


#-------------------------------------------------------------------------------
# Applies wild Pokemon settings for the next wild battle.
#-------------------------------------------------------------------------------
def pbApplyWildAttributes(pkmn)
  #-----------------------------------------------------------------------------
  # Gets the appropriate Pokemon to modify.
  #-----------------------------------------------------------------------------
  multiple = pkmn.length > 1
  settings = $game_temp.dx_pokemon
  settings.keys.each do |order|
    if multiple
      break if !settings.has_key?(:first)
      break if !settings.has_key?(:second) && pkmn.length == 2
      break if !settings.has_key?(:third)  && pkmn.length == 3
      case order
      when :first  then pokemon = pkmn[0]
      when :second then pokemon = pkmn[1]
      when :third  then pokemon = pkmn[2]
      end
      pkmn_hash = settings[order]
    else
      pokemon = pkmn[0]
      pkmn_hash = settings
    end
    next if !pokemon || !pkmn_hash
    #---------------------------------------------------------------------------
    # Modifies each Pokemon. Sets form first to ensure nothing is overridden.
    #---------------------------------------------------------------------------
    if pkmn_hash[:form].is_a?(Symbol)
      total_forms = [0]
      GameData::Species.each { |s| total_forms.push(s.form) if s.species == pokemon.species }
      pokemon.form = total_forms.sample
    elsif pkmn_hash[:form].is_a?(Numeric)
      pokemon.form = pkmn_hash[:form]
    end
    pkmn_hash.keys.each do |attribute|
      case attribute
      #-------------------------------------------------------------------------
      # Sets status.
      #-------------------------------------------------------------------------
      when :status
        pokemon.status = pkmn_hash[attribute]
        pokemon.statusCount = 3 if pkmn_hash[attribute] == :SLEEP
      #-------------------------------------------------------------------------
      # Sets owner info.
      #-------------------------------------------------------------------------  
      when :owner
        case pkmn_hash[attribute]
        when Pokemon::Owner then pokemon.owner = pkmn_hash[attribute]
        when NPCTrainer     then pokemon.owner = Pokemon::Owner.new_from_trainer(pkmn_hash[attribute])
        when Array          then pokemon.owner = Pokemon::Owner.new(*pkmn_hash[attribute])
        end
      #-------------------------------------------------------------------------
      # Sets general attributes.
      #-------------------------------------------------------------------------
      when :name       then pokemon.name         = pkmn_hash[attribute]
      when :level      then pokemon.level        = pkmn_hash[attribute]
      when :gender     then pokemon.gender       = pkmn_hash[attribute]
      when :nature     then pokemon.nature       = pkmn_hash[attribute]
      when :item       then pokemon.item         = pkmn_hash[attribute]
      when :shiny      then pokemon.shiny        = pkmn_hash[attribute]
      when :supershiny then pokemon.super_shiny  = pkmn_hash[attribute]
      when :happiness  then pokemon.happiness    = pkmn_hash[attribute]
      when :obtaintext then pokemon.obtain_text  = pkmn_hash[attribute]
      when :pokerus    then pokemon.givePokerus if pkmn_hash[attribute]
      #-------------------------------------------------------------------------
      # Sets an Ability or an Ability Index.
      #-------------------------------------------------------------------------
      when :ability
        if pkmn_hash[attribute].is_a?(Symbol)
          pokemon.ability = pkmn_hash[attribute]
        else
          pokemon.ability_index = pkmn_hash[attribute]
        end
      #-------------------------------------------------------------------------
      # Sets a move, or an array of moves.
      #-------------------------------------------------------------------------
      when :move, :moves
        if pkmn_hash[attribute].is_a?(Array)
          pkmn_hash[attribute].each do |m| 
            m = m.id if m.is_a?(Pokemon::Move)
            pokemon.learn_move(m)
          end
        else
          pokemon.learn_move(pkmn_hash[attribute])
        end
      #-------------------------------------------------------------------------
      # Sets all IV's to a number, or an array of numbers.
      #-------------------------------------------------------------------------
      when :iv, :ivs
        if pkmn_hash[attribute].is_a?(Array)
          GameData::Stat.each_main { |s| pokemon.iv[s.id] = pkmn_hash[attribute][s.pbs_order] }
        else
          GameData::Stat.each_main { |s| pokemon.iv[s.id] = pkmn_hash[attribute] }
        end
        pokemon.calc_stats
      #-------------------------------------------------------------------------
      # Sets all EV's to a number, or an array of numbers.
      #-------------------------------------------------------------------------
      when :ev, :evs
        if pkmn_hash[attribute].is_a?(Array)
          GameData::Stat.each_main { |s| pokemon.ev[s.id] = pkmn_hash[attribute][s.pbs_order] }
        else
          GameData::Stat.each_main { |s| pokemon.ev[s.id] = pkmn_hash[attribute] }
        end
        pokemon.calc_stats
      #-------------------------------------------------------------------------
      # Sets a particular ribbon, or an array of ribbons.
      #-------------------------------------------------------------------------
      when :ribbon, :ribbons
        if pkmn_hash[attribute].is_a?(Array)
          pkmn_hash[attribute].each { |r| pokemon.giveRibbon(r) }
        else
          pokemon.giveRibbon(pkmn_hash[attribute])
        end
      #-------------------------------------------------------------------------
      # Sets plugin-specific attributes.
      #-------------------------------------------------------------------------
      when :ace        then pokemon.ace           = pkmn_hash[attribute]
      when :focus      then pokemon.focus_style   = pkmn_hash[attribute] if PluginManager.installed?("Focus Meter System")
      when :birthsign  then pokemon.birthsign     = pkmn_hash[attribute] if PluginManager.installed?("Pokémon Birthsigns")
      when :blessed    then pokemon.blessing      = pkmn_hash[attribute] if PluginManager.installed?("Pokémon Birthsigns")
      when :celestial  then pokemon.celestial     = pkmn_hash[attribute] if PluginManager.installed?("Pokémon Birthsigns")
      when :dynamaxlvl then pokemon.raid_dmax_lvl = pkmn_hash[attribute] if PluginManager.installed?("ZUD Mechanics")
      when :gmaxfactor then pokemon.gmax_factor   = pkmn_hash[attribute] if PluginManager.installed?("ZUD Mechanics")
      when :teratype   then pokemon.tera_type     = pkmn_hash[attribute] if PluginManager.installed?("Terastal Phenomenon")
      when :mastery    then pokemon.master_moveset                       if PluginManager.installed?("PLA Battle Styles")
      end
    end
    #---------------------------------------------------------------------------
    # Sets HP.
    #---------------------------------------------------------------------------
    if pkmn_hash[:hp]
      pokemon.hp = (pokemon.hp / pkmn_hash[:hp]).ceil
      pokemon.hp = 1 if pokemon.hp <= 0
      pokemon.calc_stats
    end
    #---------------------------------------------------------------------------
    # Sets Dynamax.
    #---------------------------------------------------------------------------
    if PluginManager.installed?("ZUD Mechanics") && pkmn_hash[:dynamax] && pokemon.dynamax_able?
      pokemon.dynamax = true
      pokemon.calc_stats
      pokemon.hp = pokemon.totalhp if !pkmn_hash[:hp]
      pokemon.reversion = true
    else
      pokemon.calc_stats
    end
    break if !multiple
  end
end