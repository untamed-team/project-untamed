#==============================================================================#
#                              Pokémon Essentials                              #
#                                 Version 20.1                                 #
#                https://github.com/Maruno17/pokemon-essentials                #
#==============================================================================#

module Settings
  # The version of your game. It has to adhere to the MAJOR.MINOR.PATCH format.
  GAME_VERSION = "1.0.4"

  # The generation that the battle system follows. Used throughout the battle
  # scripts, and also by some other settings which are used in and out of battle
  # (you can of course change those settings to suit your game).
  # Note that this isn't perfect. Essentials doesn't accurately replicate every
  # single generation's mechanics. It's considered to be good enough. Only
  # generations 5 and later are reasonably supported.
  MECHANICS_GENERATION = 8

  #=============================================================================

  # The maximum amount of money the player can have.
  MAX_MONEY            = 999_999
  # The maximum number of Game Corner coins the player can have.
  MAX_COINS            = 99_999
  # The maximum number of Battle Points the player can have.
  MAX_BATTLE_POINTS    = 9_999
  # The maximum amount of soot the player can have.
  MAX_SOOT             = 9_999
  # The maximum length, in characters, that the player's name can be.
  MAX_PLAYER_NAME_SIZE = 11
  # The maximum number of Pokémon that can be in the party.
  MAX_PARTY_SIZE       = 6
  # The maximum level Pokémon can reach.
  MAXIMUM_LEVEL        = 100
  # The level of newly hatched Pokémon.
  EGG_LEVEL            = 1
  # The odds of a newly generated Pokémon being shiny (out of 65536).
  #If MECHANICS_GENERATION >= 6, the chances are # out of 65536 OR # out of
  #65536. The : means OR
  SHINY_POKEMON_CHANCE = 16
  # Whether super shininess is enabled (uses a different shiny animation).
  SUPER_SHINY          = false
  # The odds of a wild Pokémon/bred egg having Pokérus (out of 65536).
  POKERUS_CHANCE       = 3

  #=============================================================================

  # Whether outdoor maps should be shaded according to the time of day.
  TIME_SHADING                               = true
  # Whether poisoned Pokémon will lose HP while walking around in the field.
  POISON_IN_FIELD                            = (MECHANICS_GENERATION <= 4)
  # Whether poisoned Pokémon will faint while walking around in the field
  # (true), or survive the poisoning with 1 HP (false).
  POISON_FAINT_IN_FIELD                      = (MECHANICS_GENERATION <= 3)
  # Whether planted berries grow according to Gen 4 mechanics (true) or Gen 3
  # mechanics (false).
  NEW_BERRY_PLANTS                           = (MECHANICS_GENERATION >= 4)
  # Whether fishing automatically hooks the Pokémon (true), or whether there is
  # a reaction test first (false).
  FISHING_AUTO_HOOK                          = true
  # The ID of the common event that runs when the player starts fishing (runs
  # instead of showing the casting animation).
  FISHING_BEGIN_COMMON_EVENT                 = -1
  # The ID of the common event that runs when the player stops fishing (runs
  # instead of showing the reeling in animation).
  FISHING_END_COMMON_EVENT                   = -1
  # Whether Pokémon in the Day Care gain Exp for each step the player takes.
  # This is true for the Day Care and false for the Pokémon Nursery, both of
  # which use the same code in Essentials.
  DAY_CARE_POKEMON_GAIN_EXP_FROM_WALKING     = true#(MECHANICS_GENERATION <= 6)
  # Whether two Pokémon in the Day Care can learn egg moves from each other if
  # they are the same species.
  DAY_CARE_POKEMON_CAN_SHARE_EGG_MOVES       = true#(MECHANICS_GENERATION >= 8)
  # Whether a bred baby Pokémon can inherit any TM/TR/HM moves from its father.
  # It can never inherit TM/TR/HM moves from its mother.
  BREEDING_CAN_INHERIT_MACHINE_MOVES         = (MECHANICS_GENERATION <= 5)
  # Whether a bred baby Pokémon can inherit egg moves from its mother. It can
  # always inherit egg moves from its father.
  BREEDING_CAN_INHERIT_EGG_MOVES_FROM_MOTHER = (MECHANICS_GENERATION >= 6)
  # Whether the Pokédex entry of a newly owned species will be shown after it
  # hatches from an egg, after it evolves and after obtaining it from a trade,
  # in addition to after catching it in battle.
  SHOW_NEW_SPECIES_POKEDEX_ENTRY_MORE_OFTEN  = (MECHANICS_GENERATION >= 7)
  # Whether you get 1 Premier Ball for every 10 of any kind of Poké Ball bought
  # at once (true), or 1 Premier Ball for buying 10+ Poké Balls (false).
  MORE_BONUS_PREMIER_BALLS                   = (MECHANICS_GENERATION >= 8)
  # The number of steps allowed before a Safari Zone game is over (0=infinite).
  SAFARI_STEPS                               = 600
  # The number of seconds a Bug Catching Contest lasts for (0=infinite).
  BUG_CONTEST_TIME                           = 20 * 60   # 20 minutes

  #=============================================================================

  # If a move taught by a TM/HM/TR replaces another move, this setting is
  # whether the machine's move retains the replaced move's PP (true), or whether
  # the machine's move has full PP (false).
  TAUGHT_MACHINES_KEEP_OLD_PP          = (MECHANICS_GENERATION == 5)
  # Whether the Move Relearner can also teach egg moves that the Pokémon knew
  # when it hatched and moves that the Pokémon was once taught by a TR. Moves
  # from the Pokémon's level-up moveset of the same or a lower level than the
  # Pokémon can always be relearned.
  MOVE_RELEARNER_CAN_TEACH_MORE_MOVES  = (MECHANICS_GENERATION >= 6)
  # Whether various HP-healing items heal the amounts they do in Gen 7+ (true)
  # or in earlier Generations (false).
  REBALANCED_HEALING_ITEM_AMOUNTS      = (MECHANICS_GENERATION >= 7)
  # Whether Rage Candy Bar acts as a Full Heal (true) or a Potion (false).
  RAGE_CANDY_BAR_CURES_STATUS_PROBLEMS = (MECHANICS_GENERATION >= 7)
  # Whether vitamins can add EVs no matter how many that stat already has in it
  # (true), or whether they can't make that stat's EVs greater than 100 (false).
  NO_VITAMIN_EV_CAP                    = (MECHANICS_GENERATION >= 8)
  # Whether Rare Candy can be used on a Pokémon that is already at its maximum
  # level if it is able to evolve by level-up (if so, triggers that evolution).
  RARE_CANDY_USABLE_AT_MAX_LEVEL       = (MECHANICS_GENERATION >= 8)
  # Whether the player can choose how many of an item to use at once on a
  # Pokémon. This applies to Exp-changing items (Rare Candy, Exp Candies) and
  # EV-changing items (vitamins, feathers, EV-lowering berries).
  USE_MULTIPLE_STAT_ITEMS_AT_ONCE      = (MECHANICS_GENERATION >= 8)

  #=============================================================================

  # Whether Repel uses the level of the first Pokémon in the party regardless of
  # its HP (true), or it uses the level of the first unfainted Pokémon (false).
  REPEL_COUNTS_FAINTED_POKEMON             = (MECHANICS_GENERATION >= 6)
  # Whether more abilities affect whether wild Pokémon appear, which Pokémon
  # they are, etc.
  MORE_ABILITIES_AFFECT_WILD_ENCOUNTERS    = (MECHANICS_GENERATION >= 8)
  # Whether the Black/White Flutes will raise/lower the levels of wild Pokémon
  # respectively (true), or will lower/raise the wild encounter rate
  # respectively (false).
  FLUTES_CHANGE_WILD_ENCOUNTER_LEVELS      = (MECHANICS_GENERATION >= 6)
  # Whether shiny wild Pokémon are more likely to appear if the player has
  # previously defeated/caught lots of other Pokémon of the same species.
  HIGHER_SHINY_CHANCES_WITH_NUMBER_BATTLED = (MECHANICS_GENERATION >= 8)
  # Whether overworld weather can set the default terrain effect in battle.
  # Storm weather sets Electric Terrain, and fog weather sets Misty Terrain.
  OVERWORLD_WEATHER_SETS_BATTLE_TERRAIN    = (MECHANICS_GENERATION >= 8)

  #=============================================================================

  # A set of arrays each containing a trainer type followed by a Game Variable
  # number. If the Variable isn't set to 0, then all trainers with the
  # associated trainer type will be named as whatever is in that Variable.
  RIVAL_NAMES = [
    [:RIVAL1,   12],
    [:RIVAL2,   12],
    [:CHAMPION, 12]
  ]

  #=============================================================================

  # Whether you need at least a certain number of badges to use some hidden
  # moves in the field (true), or whether you need one specific badge to use
  # them (false). The amounts/specific badges are defined below.
  FIELD_MOVES_COUNT_BADGES = true
  # Depending on FIELD_MOVES_COUNT_BADGES, either the number of badges required
  # to use each hidden move in the field, or the specific badge number required
  # to use each move. Remember that badge 0 is the first badge, badge 1 is the
  # second badge, etc.
  #   e.g. To require the second badge, put false and 1.
  #        To require at least 2 badges, put true and 2.
  BADGE_FOR_CUT       = 1
  BADGE_FOR_FLASH     = 2
  BADGE_FOR_ROCKSMASH = 3
  BADGE_FOR_SURF      = 4
  BADGE_FOR_FLY       = 5
  BADGE_FOR_STRENGTH  = 6
  BADGE_FOR_DIVE      = 7
  BADGE_FOR_WATERFALL = 8

  #=============================================================================

  # The names of each pocket of the Bag.
  def self.bag_pocket_names
    return [
      _INTL("Items"),
      _INTL("Medicine"),
      _INTL("Poké Balls"),
      _INTL("TMs & HMs"),
      _INTL("Berries"),
      _INTL("Mail"),
      _INTL("Battle Items"),
      _INTL("Key Items")
    ]
  end
  # The maximum number of slots per pocket (-1 means infinite number).
  BAG_MAX_POCKET_SIZE  = [-1, -1, -1, -1, -1, -1, -1, -1]
  # Whether each pocket in turn auto-sorts itself by item ID number.
  BAG_POCKET_AUTO_SORT = [false, false, false, true, true, false, false, false]
  # The maximum number of items each slot in the Bag can hold.
  BAG_MAX_PER_SLOT     = 999

  #=============================================================================

  # The number of boxes in Pokémon storage.
  NUM_STORAGE_BOXES   = 40
  # Whether putting a Pokémon into Pokémon storage will heal it. IF false, they
  # are healed by the Recover All: Entire Party event command (at Poké Centers).
  HEAL_STORED_POKEMON = (MECHANICS_GENERATION >= 8)

  #=============================================================================

  # Whether the Pokédex list shown is the one for the player's current region
  # (true), or whether a menu pops up for the player to manually choose which
  # Dex list to view if more than one is available (false).
  USE_CURRENT_REGION_DEX = true
  # The names of the Pokédex lists, in the order they are defined in the PBS
  # file "regional_dexes.txt". The last name is for the National Dex and is
  # added onto the end of this array (remember that you don't need to use it).
  # This array's order is also the order of $player.pokedex.unlocked_dexes,
  # which records which Dexes have been unlocked (the first is unlocked by
  # default). If an entry is just a name, then the region map shown in the Area
  # page while viewing that Dex list will be the region map of the region the
  # player is currently in. The National Dex entry should always behave like
  # this. If an entry is of the form [name, number], then the number is a region
  # number, and that region's map will appear in the Area page while viewing
  # that Dex list, no matter which region the player is currently in.
  def self.pokedex_names
    return [
      [_INTL("Mazah Pokédex"), 0],
      [_INTL("Johto Pokédex"), 1],
      _INTL("National Pokédex")
    ]
  end
  # Whether all forms of a given species will be immediately available to view
  # in the Pokédex so long as that species has been seen at all (true), or
  # whether each form needs to be seen specifically before that form appears in
  # the Pokédex (false).
  DEX_SHOWS_ALL_FORMS = false
  # An array of numbers, where each number is that of a Dex list (in the same
  # order as above, except the National Dex is -1). All Dex lists included here
  # will begin their numbering at 0 rather than 1 (e.g. Victini in Unova's Dex).
  DEXES_WITH_OFFSETS  = []

  #=============================================================================

  # A set of arrays, each containing details of a graphic to be shown on the
  # region map if appropriate. The values for each array are as follows:
  #   * Region number.
  #   * Game Switch; the graphic is shown if this is ON (non-wall maps only).
  #   * X coordinate of the graphic on the map, in squares.
  #   * Y coordinate of the graphic on the map, in squares.
  #   * Name of the graphic, found in the Graphics/Pictures folder.
  #   * The graphic will always (true) or never (false) be shown on a wall map.
  REGION_MAP_EXTRAS = [
    [0, 51, 16, 15, "mapHiddenBerth", false],
    [0, 52, 20, 14, "mapHiddenFaraday", false]
  ]

  # Whether the player can use Fly while looking at the Town Map. This is only
  # allowed if the player can use Fly normally.
  CAN_FLY_FROM_TOWN_MAP = true

  #=============================================================================

  # Pairs of map IDs, where the location signpost isn't shown when moving from
  # one of the maps in a pair to the other (and vice versa). Useful for single
  # long routes/towns that are spread over multiple maps.
  #   e.g. [4,5,16,17,42,43] will be map pairs 4,5 and 16,17 and 42,43.
  # Moving between two maps that have the exact same name won't show the
  # location signpost anyway, so you don't need to list those maps here.
  NO_SIGNPOSTS = []

  #=============================================================================

  # A list of maps used by roaming Pokémon. Each map has an array of other maps
  # it can lead to.
  ROAMING_AREAS = {
    5  => [   21, 28, 31, 39, 41, 44, 47, 66, 69],
    21 => [5,     28, 31, 39, 41, 44, 47, 66, 69],
    28 => [5, 21,     31, 39, 41, 44, 47, 66, 69],
    31 => [5, 21, 28,     39, 41, 44, 47, 66, 69],
    39 => [5, 21, 28, 31,     41, 44, 47, 66, 69],
    41 => [5, 21, 28, 31, 39,     44, 47, 66, 69],
    44 => [5, 21, 28, 31, 39, 41,     47, 66, 69],
    47 => [5, 21, 28, 31, 39, 41, 44,     66, 69],
    66 => [5, 21, 28, 31, 39, 41, 44, 47,     69],
    69 => [5, 21, 28, 31, 39, 41, 44, 47, 66    ]
  }
  # A set of arrays, each containing the details of a roaming Pokémon. The
  # information within each array is as follows:
  #   * Species.
  #   * Level.
  #   * Game Switch; the Pokémon roams while this is ON.
  #   * Encounter type (0=any, 1=grass/walking in cave, 2=surfing, 3=fishing,
  #     4=surfing/fishing). See the bottom of PField_RoamingPokemon for lists.
  #   * Name of BGM to play for that encounter (optional).
  #   * Roaming areas specifically for this Pokémon (optional).
  ROAMING_SPECIES = [
    [:LATIAS, 30, 53, 0, "Battle roaming"],
    [:LATIOS, 30, 53, 0, "Battle roaming"],
    [:KYOGRE, 40, 54, 2, nil, {
      2  => [   21, 31    ],
      21 => [2,     31, 69],
      31 => [2, 21,     69],
      69 => [   21, 31    ]
    }],
    [:ENTEI, 40, 55, 1]
  ]

  #=============================================================================

  # A set of arrays, each containing the details of a wild encounter that can
  # only occur via using the Poké Radar. The information within each array is as
  # follows:
  #   * Map ID on which this encounter can occur.
  #   * Probability that this encounter will occur (as a percentage).
  #   * Species.
  #   * Minimum possible level.
  #   * Maximum possible level (optional).
  POKE_RADAR_ENCOUNTERS = [
    [5,  20, :STARLY,     12, 15],
    [21, 10, :STANTLER,   14],
    [28, 20, :BUTTERFREE, 15, 18],
    [28, 20, :BEEDRILL,   15, 18]
  ]

  #=============================================================================

  # The Game Switch that is set to ON when the player blacks out.
  STARTING_OVER_SWITCH      = 1
  # The Game Switch that is set to ON when the player has seen Pokérus in the
  # Poké Center (and doesn't need to be told about it again).
  SEEN_POKERUS_SWITCH       = 2
  # The Game Switch which, while ON, makes all wild Pokémon created be shiny.
  SHINY_WILD_POKEMON_SWITCH = 31
  # The Game Switch which, while ON, makes all Pokémon created considered to be
  # met via a fateful encounter.
  FATEFUL_ENCOUNTER_SWITCH  = 32
  # The Game Switch which, while ON, disables the effect of the Pokémon Box Link
  # and prevents the player from accessing Pokémon storage via the party screen
  # with it.
  DISABLE_BOX_LINK_SWITCH   = 35

  #=============================================================================

  # ID of the animation played when the player steps on grass (grass rustling).
  GRASS_ANIMATION_ID           = 1
  # ID of the animation played when the player lands on the ground after hopping
  # over a ledge (shows a dust impact).
  DUST_ANIMATION_ID            = 2
  # ID of the animation played when a trainer notices the player (an exclamation
  # bubble).
  EXCLAMATION_ANIMATION_ID     = 3
  # ID of the animation played when a patch of grass rustles due to using the
  # Poké Radar.
  RUSTLE_NORMAL_ANIMATION_ID   = 1
  # ID of the animation played when a patch of grass rustles vigorously due to
  # using the Poké Radar. (Rarer species)
  RUSTLE_VIGOROUS_ANIMATION_ID = 5
  # ID of the animation played when a patch of grass rustles and shines due to
  # using the Poké Radar. (Shiny encounter)
  RUSTLE_SHINY_ANIMATION_ID    = 6
  # ID of the animation played when a berry tree grows a stage while the player
  # is on the map (for new plant growth mechanics only).
  PLANT_SPARKLE_ANIMATION_ID   = 7

  #=============================================================================

  # The default screen width (at a scale of 1.0).
  SCREEN_WIDTH  = 512
  # The default screen height (at a scale of 1.0).
  SCREEN_HEIGHT = 384
  # The default screen scale factor. Possible values are 0.5, 1.0, 1.5 and 2.0.
  SCREEN_SCALE  = 1.0

  #=============================================================================

  # An array of available languages in the game, and their corresponding message
  # file in the Data folder. Edit only if you have 2 or more languages to choose
  # from.
  LANGUAGES = [
  #  ["English", "english.dat"],
  #  ["Deutsch", "deutsch.dat"]
  ]

  #=============================================================================

  # Available speech frames. These are graphic files in "Graphics/Windowskins/".
  SPEECH_WINDOWSKINS = [
    #"speech text transparent",
    "speech hgss 1",
    "speech hgss 2",
    "speech hgss 3",
    "speech hgss 4",
    "speech hgss 5",
    "speech hgss 6",
    "speech hgss 7",
    "speech hgss 8",
    "speech hgss 9",
    "speech hgss 10",
    "speech hgss 11",
    "speech hgss 12",
    "speech hgss 13",
    "speech hgss 14",
    "speech hgss 15",
    "speech hgss 16",
    "speech hgss 17",
    "speech hgss 18",
    "speech hgss 19",
    "speech hgss 20",
    "speech pl 18"
  ]

  # Available menu frames. These are graphic files in "Graphics/Windowskins/".
  MENU_WINDOWSKINS = [
    "menuTheme1",
    "choice 1",
    "choice 2",
    "choice 3",
    "choice 4",
    "choice 5",
    "choice 6",
    "choice 7",
    "choice 8",
    "choice 9",
    "choice 10",
    "choice 11",
    "choice 12",
    "choice 13",
    "choice 14",
    "choice 15",
    "choice 16",
    "choice 17",
    "choice 18",
    "choice 19",
    "choice 20",
    "choice 21",
    "choice 22",
    "choice 23",
    "choice 24",
    "choice 25",
    "choice 26",
    "choice 27",
    "choice 28"
  ]
end

# DO NOT EDIT THESE!
module Essentials
  VERSION = "20.1"
  ERROR_TEXT = ""
end
