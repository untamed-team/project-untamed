#-------------------------------------------------------------------------------
# Phenomenon: BW Style Grass Rustle, Water Drops, Cave Dust & Flying Birds
# v3.0 by Boonzeet with code help from Maruno & Marin, Grass graphic by DaSpirit
#-------------------------------------------------------------------------------
# Please give credit when using. Changes in this version:
# - Upgraded for Essentials v19
# - Block inaccessible tiles from showing phenomena
#-------------------------------------------------------------------------------
# Configuration
#-------------------------------------------------------------------------------
# For Exp boost to work, please change the following line of
# 004_Battle_ExpAndMoveLearning:
#   isOutsider = (pkmn.owner.id != pbPlayer.id ||
# to:
#   isOutsider = (pkmn.owner.id != pbPlayer.id || $PokemonTemp.phenomenonExp ||
#-------------------------------------------------------------------------------
module PhenomenonConfig
  Frequency = 450 # Chance for phenomenon to generate on step. Between 350-600.
  Timer = 2800 # How many frames to wait before phenomenon disappears
  Switch = 56 # Switch that when ON enables phenomena
  BattleMusic = "" # Custom music to play during Phenomenon
  Pokemon = {
    :shiny => true, # 4x chance of shininess
    :expBoost => false, # 1.5x Exp Boost (read above)
  }
  Types = {
    # Animation ID, sound, animation height (1: above player/ 0: below)
    :PhenomenonGrass => [57, "phenomenon_grass", 1],
    :PhenomenonWater => [58, "phenomenon_water", 0],
    :PhenomenonCave => [25, "phenomenon_cave", 1],
    :PhenomenonBird => [60, "phenomenon_bird", 0],
  }
  # Tiles that will not show Phenomena, on a per-map basis. Blocks whole x columns or y rows, or individual tiles
  # Array(A..B) will create an array including both numbers and everything inbetween
  BlockedTiles = {
 # 69 => {
       #   :x => Array(0..8) + Array(28..45),
       #   :y => [29, 30, 31, 32, 33, 34, 35],
       #   :tiles => [[27, 27]],
       # },
    }
  # Items that appear occasionally in dust clouds and flying birds
  Items = {
    # 80% chance of appearing in dust
    :commonCave => [:EVERSTONE, :OVALSTONE],
    # 10% chance
    :rareCave => [:RAREBONE, :FLOATSTONE, :PEARL],
    :bird => [:HEALTHWING, :RESISTWING, :CLEVERWING, :PRETTYWING, :MUSCLEWING, :GENIUSWING, :SWIFTWING],
  }
end

#-------------------------------------------------------------------------------
# EncounterTypes
#-------------------------------------------------------------------------------
GameData::EncounterType.register({
  :id => :PhenomenonGrass,
  :type => :land,
  :trigger_chance => 1,
  :old_slots => [50, 20, 10, 5, 5, 5, 5],
})
GameData::EncounterType.register({
  :id => :PhenomenonWater,
  :type => :water,
  :trigger_chance => 1,
  :old_slots => [50, 20, 10, 5, 5, 5, 5],
})
GameData::EncounterType.register({
  :id => :PhenomenonCave,
  :type => :cave,
  :trigger_chance => 1,
  :old_slots => [50, 20, 10, 5, 5, 5, 5],
})
GameData::EncounterType.register({
  :id => :PhenomenonBird,
  :type => :land,
  :trigger_chance => 1,
  :old_slots => [50, 20, 10, 5, 5, 5, 5],
})
#-------------------------------------------------------------------------------
# Terrain tag for Bird encounters. Important! This is
# to prevent encounters appearing in inaccessible spots
#-------------------------------------------------------------------------------
GameData::TerrainTag.register({
  :id => :BirdBridge,
  :id_number => 30,
})
