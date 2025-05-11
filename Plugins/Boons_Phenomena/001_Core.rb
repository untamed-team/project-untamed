#-------------------------------------------------------------------------------
# Phenomenon: BW Style Grass Rustle, Water Drops, Cave Dust & Flying Birds
# v3.0 by Boonzeet with code help from Maruno & Marin, Grass graphic by DaSpirit
# v20.1 Upgrade with help from Ned & Vendily
#-------------------------------------------------------------------------------
# Please give credit when using. Changes in this version:
# - Upgraded for Essentials v20.1
# - Updates to algorithms for efficiency
#===============================================================================
# Main code
#-------------------------------------------------------------------------------
# SUPPORT CAN'T BE PROVIDED FOR EDITS MADE TO THIS FILE.
#===============================================================================

class Array # Add quick random array fetch - by Marin
  def random
    return self[rand(self.size)]
  end
end

class PhenomenonInstance
  attr_accessor :timer # number
  attr_accessor :x
  attr_accessor :y
  attr_accessor :type # symbol
  attr_accessor :active # bool
  attr_accessor :drawing # bool

  def initialize(types)
    Kernel.echoln("Initializing for map with types: #{types}")
    @x = nil
    @y = nil
    @types = types
    timer_val = PhenomenonConfig::Frequency <= 60 ? 60 : rand(PhenomenonConfig::Frequency - 60) + 6
    @timer = Graphics.frame_count + timer_val
    @active = false
  end
end

class Phenomenon
  @@instance = nil
  @@possible = false
  @@activated = false
  @@expBoost = false
  @@types = nil

  class << self
    attr_accessor :instance    # [x,y,type,timer]
    attr_accessor :possible    # bool
    attr_accessor :activated   # bool
    attr_accessor :expBoost
    attr_accessor :types
  end

  def self.generate
    ph = self.instance
    return if !ph
    Kernel.echo("Generating phenomena...\n")
    phenomenon_tiles = []   # x, y, type
    # limit range to around the player
    x_range = [[$game_player.x - 16, 0].max, [$game_player.x + 16, $game_map.width].min]
    y_range = [[$game_player.y - 16, 0].max, [$game_player.y + 16, $game_map.height].min]
    hasGrass = self.types.include?(:PhenomenonGrass)
    hasWater = self.types.include?(:PhenomenonWater)
    hasCave = self.types.include?(:PhenomenonCave)
    hasBird = self.types.include?(:PhenomenonBird)
    # list all grass tiles
    blocked_tiles = nil
    if PhenomenonConfig::BlockedTiles.key?($game_map.map_id)
      blocked_tiles = PhenomenonConfig::BlockedTiles[$game_map.map_id]
    end
    for x in x_range[0]..x_range[1]
      for y in y_range[0]..y_range[1]
        if !blocked_tiles.nil?
          next if blocked_tiles[:x] && blocked_tiles[:x].include?(x)
          next if blocked_tiles[:y] && blocked_tiles[:x].include?(y)
          next if blocked_tiles[:tiles] && blocked_tiles[:x].include?([x, y])
        end
        terrain_tag = $game_map.terrain_tag(x, y)
        if hasGrass && terrain_tag.id == :Grass
          phenomenon_tiles.push([x, y, :PhenomenonGrass])
        elsif hasWater && (terrain_tag.id == :Water || terrain_tag.id == :StillWater)
          phenomenon_tiles.push([x, y, :PhenomenonWater])
        elsif hasCave && !terrain_tag.can_surf && $MapFactory.isPassableStrict?($game_map.map_id, x, y, $game_player)
          phenomenon_tiles.push([x, y, :PhenomenonCave])
        elsif hasBird && terrain_tag.id == :BirdBridge && $MapFactory.isPassableStrict?($game_map.map_id, x, y, $game_player)
          phenomenon_tiles.push([x, y, :PhenomenonBird])
        end
      end
    end
    if phenomenon_tiles.length == 0
      Kernel.echoln("A phenomenon is set up but no compatible tiles are available! Phenomena: #{@types}")
      self.cancel
    else
      selected_tile = phenomenon_tiles.random
      ph.x = selected_tile[0]
      ph.y = selected_tile[1]
      ph.type = selected_tile[2]
      ph.timer = Graphics.frame_count + PhenomenonConfig::Timer
      ph.active = true
    end
  end

  def self.activate
    ph = self.instance
    Kernel.echoln("Activating phenomenon for #{ph.type}")
    encounter = nil
    encounter = $PokemonEncounters.choose_wild_pokemon(ph.type)
    if encounter != nil
      if PhenomenonConfig::BattleMusic != "" && FileTest.audio_exist?("Audio/BGM/#{PhenomenonConfig::BattleMusic}")
        $PokemonGlobal.nextBattleBGM = PhenomenonConfig::BattleMusic
      end
      $game_temp.force_single_battle
      self.activated = true
      WildBattle.start(encounter[0], encounter[1])
    end
  end

  def self.drawAnim(sound)
    return if !self.instance
    x, y = self.instance.x, self.instance.y
    dist = (((x - $game_player.x).abs + (y - $game_player.y).abs) / 4).floor
    if dist <= 6 && dist >= 0
      animation = PhenomenonConfig::Types[self.instance.type]
      $scene.spriteset.addUserAnimation(animation[0], x, y, true, animation[2])
      pbSEPlay(animation[1], [75, 65, 55, 40, 27, 22, 15][dist]) if sound
    end
    pbWait(1)
    self.instance.drawing = false if (self.instance)
  end

  def self.cancel
    self.instance = nil
  end

  def self.load_types
    types = []
    PhenomenonConfig::Types.each do |(key, value)|
      # Kernel.echo("Testing map #{$game_map.map_id}, against #{key}, with value #{value}...\n")
      types.push(key) if $PokemonEncounters && $PokemonEncounters.map_has_encounter_type?($game_map.map_id, key)
    end
    self.possible = types.size > 0 && $Trainer.party.length > 0 # set to false if no encounters for map or trainer has no pokemon
    self.types = types
  end

  def self.waiting?
    return defined?(self.instance) && self.instance != nil && !self.instance.active
  end

  # Returns true if an existing phenomenon has been set up and exists
  def self.active?
    return defined?(self.instance) && self.instance != nil && self.instance.active
  end

  # Returns true if there's a phenomenon and the player is on top of it
  def self.playerOn?
    return self.active? && ($game_player.x == self.instance.x && $game_player.y == self.instance.y)
  end
end
