module Settings

    #====================================================================================
    #================================= General Settings =================================
    #====================================================================================

        #--------------------------------------------------------------------------------
        # If true, use an updated method of determining growth time of a plant. This is
        # to accomodate dynamic settings that affect growth speed (like Weeds and Pests).
        #--------------------------------------------------------------------------------	
        BERRY_USE_NEW_UPDATE_LOGIC          = true

        #--------------------------------------------------------------------------------
        # If you place mulch down on a berry spot, but don't actually plant a berry,
        # define which graphic to show on the berry spot. The file should be in
        # Graphics/Characters. Set to "" or nil to not set a graphic.
        #--------------------------------------------------------------------------------	
        BERRY_JUST_MULCH_GRAPHIC            = "berrytreewet"

        #--------------------------------------------------------------------------------
        # Switch ID to be set to true for the player to be able to dig up a berry that is
        # still in its earliest planted state, in combination with BERRY_DIG_UP_ITEM
        # Set to 0 or true to always be treated as true.
        # Set to -1 or false to always be treated as false.
        #--------------------------------------------------------------------------------	
        BERRY_ALLOW_DIGGING_UP_SWITCH_ID    = 0

        #--------------------------------------------------------------------------------
        # Set the ID of an item the player is required to have in order to dig up planted
        # berries. Set to nil to not require an item.
        #--------------------------------------------------------------------------------	
        BERRY_DIG_UP_ITEM                   = nil

        #--------------------------------------------------------------------------------
        # Chance out of 100 that a dug up berry is kept. Otherwise, it will break apart
        # and not be returned to the player.
        #--------------------------------------------------------------------------------	
        BERRY_DIG_UP_KEEP_CHANCE            = 25

        #--------------------------------------------------------------------------------
        # Define items that can drop from a berry plant once it fully withers (replants
        # the max number of times so it disappears). The item will stick around until the
        # player next interacts with it. If a berry plant propagates onto the spot,
        # however, the item disappears. To have no items drop, set all chances to 0 or
        # clear out the BERRY_WITHERED_ITEMS array.
        # Format: [CHANCE, ITEM_ID]
        # CHANCE    => Chance out of 100 the item will drop. 
        # ITEM_ID   => Item ID of the item to drop. Use :DropParentBerry to drop the
        #              the berry that was originally planted, instead.
        #--------------------------------------------------------------------------------	
        BERRY_WITHERED_ITEMS                = [
            [5,:BIGROOT],
            [1,:DropParentBerry]
        ]

    #====================================================================================
    #================================ Mutation Settings =================================
    #====================================================================================
    # Berry mutations occur when a berry plant is next to another berry plant it is
    # compatible with and it produces a rare berry, replacing some of the original 
    # berries the plant would normally produce.
    # https://bulbapedia.bulbagarden.net/wiki/Berry_fields_(Kalos)#Mutation
    
        #--------------------------------------------------------------------------------
        # Switch ID to be set to true for berry mutations to occur.
        # Set to 0 or true to always allow berry mutations.
        # Set to -1 or false to never allow berry mutations.
        #--------------------------------------------------------------------------------	
        ALLOW_BERRY_MUTATIONS_SWITCH_ID     = 0

        #--------------------------------------------------------------------------------
        # Berry combinations and their mutation possibilities. 
        # The first array is the pair of original berries to be next to each other.
        # The second array is the list of possible berries to be produced as mutations.
        #--------------------------------------------------------------------------------		
        BERRY_MUTATION_POSSIBILITIES = {
            [:IAPAPABERRY,:MAGOBERRY]   => [:POMEGBERRY],
            [:CHESTOBERRY,:PERSIMBERRY] => [:KELPSYBERRY],
            [:ORANBERRY,:PECHABERRY]    => [:QUALOTBERRY],
            [:ASPEARBERRY,:LEPPABERRY]  => [:HONDEWBERRY],
            [:AGUAVBERRY,:FIGYBERRY]    => [:GREPABERRY],
            [:LUMBERRY,:SITRUSBERRY]    => [:TAMATOBERRY],
            [:HONDEWBERRY,:YACHEBERRY]  => [:LIECHIBERRY],
            [:QUALOTBERRY,:TANGABERRY]  => [:GANLONBERRY],
            [:GREPABERRY,:ROSELIBERRY]  => [:SALACBERRY],
            [:KASIBBERRY,:POMEGBERRY]   => [:PETAYABERRY],
            [:KELPSYBERRY,:WACANBERRY]  => [:APICOTBERRY],
            [:GANLONBERRY,:LIECHIBERRY] => [:KEEBERRY],
            [:PETAYABERRY,:SALACBERRY]  => [:MARANGABERRY]
        }
    
        #--------------------------------------------------------------------------------
        # Base chance out of 100 that berry mutation will occur without mulch influence.
        #--------------------------------------------------------------------------------		
        BERRY_BASE_MUTATION_CHANCE          = 20

        #--------------------------------------------------------------------------------
        # List of Mulch items that will impact the chance of berry mutations occuring
        # Format: ITEM_ID => CHANCE
        # ITEM_ID   => Item ID of the Mulch
        # CHANCE    => Chance out of 100 mutated berries will appear when the mulch is 
        #              used. This value overwrites BERRY_BASE_MUTATION_CHANCE.
        #--------------------------------------------------------------------------------		
        BERRY_MULCHES_IMPACTING_MUTATIONS = {
            :SURPRISEMULCH  => 50,
            :AMAZEMULCH     => 50
        }
    
        #--------------------------------------------------------------------------------
        # If berry mutations occur, how many of the original berries will be replaced by
        # mutations. The number of mutations will never completely overtake the original
        # berries. Examples:
        # - BERRY_MUTATION_COUNT is set to 1, but the plant will only produce 1 berry.
        #   The plant will only produce 1 original berry and no mutated berry.
        # - BERRY_MUTATION_COUNT is set to 2, but the plant will only produce 2 berries.
        #   The plant will produce 1 original berry and 1 mutated berry.
        # - BERRY_MUTATION_COUNT is set to 1, and the plant will produce 5 berries.
        #   The plant will produce 4 original berries and 1 mutated berry.
        #--------------------------------------------------------------------------------		
        BERRY_MUTATION_COUNT                = 1
    
        #--------------------------------------------------------------------------------
        # To give a hint to the player that a plant will produce a mutated berry, set a
        # string that will appear to the player if they interact with the plant while
        # it's in in the blooming stage (stage right before ready to pick).
        # Set to nil if you don't wish to show this comment.
        #
        # For example, when interacting with the blooming plant, it could say:
        #   Original message:   This Oran Berry plant is in bloom! 
        #   Message after:      There is something unique about it...
        #--------------------------------------------------------------------------------	
        BERRY_PLANT_BLOOMING_COMMENT        = _INTL("There is something unique about it...")

        #--------------------------------------------------------------------------------
        # If true, if a berry plant goes through replanting, mutation info will reset,
        # allowing another chance for mutation or losing an existing mutation.
        #--------------------------------------------------------------------------------		
        BERRY_REPLANT_RESETS_MUTATION       = true

    #====================================================================================
    #============================== Propagation Settings ================================
    #====================================================================================
    # Berry propagation can occur when a berry plant replants itself. Instead of just
    # replanting on its own spot, it can also plant one of its berries that "dropped" 
    # in a plantable spot next to it. As far as I know, this is not a mechanic available
    # in mainline Pokemon games.

        #--------------------------------------------------------------------------------
        # Switch ID to be set to true for berry propagations to occur.
        # Set to 0 or true to always allow berry propagations.
        # Set to -1 or false to never allow berry propagations.
        #--------------------------------------------------------------------------------	
        ALLOW_BERRY_PROPAGATION_SWITCH_ID   = 0
    
        #--------------------------------------------------------------------------------
        # Base chance out of 1000 that berry propagation will occur on an empty berry
        # spot when a plant replants itself. Since propagation should be a rare 
        # occurance, it's out of 1000 to allow smaller chances.
        #--------------------------------------------------------------------------------		
        BERRY_BASE_PROPAGATION_CHANCE       = 1

        #--------------------------------------------------------------------------------
        # List of Mulch items that will impact the chance of berry propagation occuring
        # on an empty berry spot nearby. The mulch must be put on the empty spot, not the
        # parent berry plant's spot.
        # Format: ITEM_ID => CHANCE
        # ITEM_ID   => Item ID of the Mulch
        # CHANCE    => Chance out of 1000 berries from nearby replanting plants get
        #              planted on the spot the mulch is. This value overwrites 
        #              BERRY_BASE_PROPAGATION_CHANCE. 
        #--------------------------------------------------------------------------------		
        BERRY_MULCHES_IMPACTING_PROPAGATION = {
            :ALLUREMULCH  => 100
        }

    #====================================================================================
    #============================= Persistent Plant Settings ============================
    #====================================================================================
    # Usually, berry plants will disappear after their berries are picked. You can make
    # it so berry plants persist after picking, just like real fruit trees.
    
        #--------------------------------------------------------------------------------
        # Chance out of 100 that a berry plant will persist after berries are picked.
        #--------------------------------------------------------------------------------		
        BERRY_PERSISTENT_PLANT_CHANCE       = 0
    
        #--------------------------------------------------------------------------------
        # Set the stage the berry plant should be after being picked (when persistent).
        #--------------------------------------------------------------------------------		
        BERRY_PERSISTENT_REPLANT_STAGE      = 3
    
        #--------------------------------------------------------------------------------
        # If true, each time a berry plant persists after picking, it counts towards the
        # plant's replant count and will stop replanting after the max is hit (set in
        # BerryPlant > NUMBER_OF_REPLANTS).
        #--------------------------------------------------------------------------------		
        BERRY_PERSISTENT_COUNTS_AS_REPLANT  = true
    
        #--------------------------------------------------------------------------------
        # If true, berry plants that are preplanted (ones that use pbPickBerry on the
        # first page of their events, i.e. ones the game developer creates for the player
        # to pick) will also follow persistence.
        #--------------------------------------------------------------------------------		
        BERRY_PERSISTENT_FOR_PREPLANTED     = false

    #====================================================================================
    #================================ Town Map Settings =================================
    #====================================================================================
    # The status of player-planted berries can show up on the Town Map (not when trying
    # to fly or viewing the map on a wall) like you can in BDSP.

        #--------------------------------------------------------------------------------
        # Switch ID to be set to true for berries to appear on the Town Map.
        # Set to 0 or true to always show.
        # Set to -1 or false to never show.
        #--------------------------------------------------------------------------------	
        SHOW_BERRIES_ON_MAP_SWITCH_ID       = 0

        #--------------------------------------------------------------------------------
        # List which berry status icons will appear on the Town Map, and in what priority
        # order if multiple apply at once. The first option listed will have the highest
        # priorty, while the last option listed will have the lowest priority. Omit an 
        # option if you never want it to show in the Town Map. If none of these statuses
        # apply to a berry plant in the location, the base berry icon mapBerry will show.
        # For example, if your settings are set to the follow array, the mapBerryDry icon
        # will appear for the location if any plant in that location needs watering, even
        # if there is a berry ready to pick, or a berry plant that has weeds (the map will
        # never show the pests icon since it is omitted):
        #       BERRIES_ON_MAP_SHOW_PRIORITY = [
        #           :NeedsWater,
        #           :ReadyToPick,
        #           :HasWeeds
        #       ]
        # Options:
        # - :ReadyToPick => Shows mapBerryReady icon if a berry in that location is ready
        #                   to be picked.
        # - :HasPests    => Shows mapBerryPest icon if a berry in that location has pests.
        # - :NeedsWater  => Shows mapBerryDry icon if a berry in that location has a
        #                   moisture level of 0.
        # - :HasWeeds    => Shows mapBerryWeeds icon if a berry in that location has weeds.
        #--------------------------------------------------------------------------------
        BERRIES_ON_MAP_SHOW_PRIORITY = [
            # Highest Priorty
            :ReadyToPick,
            :HasPests,
            :NeedsWater,
            :HasWeeds
            # Lowest Priorty
        ]

    #====================================================================================
    #=============================== Composter Settings =================================
    #====================================================================================

        #--------------------------------------------------------------------------------
        # Set how many Berries are needed to be used to create mulch in a composter.
        #--------------------------------------------------------------------------------	
        COMPOSTER_BERRY_AMOUNT              = 3
        #--------------------------------------------------------------------------------
        # Set how many bags of mulch will be dispensed each time using the composter.
        #--------------------------------------------------------------------------------	
        COMPOSTER_DISPENSE_AMOUNT           = 3

        #--------------------------------------------------------------------------------
        # Set which mulch item will be given to the player if no composter recipe is
        # satisfied by the chosen berries.
        #--------------------------------------------------------------------------------	
        COMPOSTER_DEFAULT_MULCH             = :GROWTHMULCH

        #--------------------------------------------------------------------------------
        # Mulch Recipes - Define what combination of berries, based on color or ID, will
        # dispense specific mulches.
        # The mulch item defined on the left will be dispensed if the recipe on the right
        # is satisfied.
        # Recipe options:
        #       [[<Berries>],[<Berries>]] => If a specific Berry, or set of Berries, is
        #                                    used. <Berries> can be a single berry or
        #                                    a list of berries.
        #       [<number>,<BerryColor>] => If <number> Berries of <BerryColor> were used.
        #                                  <BerryColor> can be set to :Any to be any
        #                                  color for matching.
        #       [<number>,:Any] => If <number> Berries of the same color were used.
        #       :DifferentColors => Berries of all different colors were used
        # Priority - sometimes a group of berries will satisfy multiple recipes. Recipes
        #   will be checked in the same order they are defined below in COMPOSTER_RECIPES
        #   so define more specific recipes near the top.
        #--------------------------------------------------------------------------------	

        COMPOSTER_RECIPES = {
            # Examples:
            # :STABLEMULCH  => [[:ORANBERRY],[:CHERIBERRY]],
            #                   => Will dispense Stable Mulch if an Oran Berry + a Cheri Berry is used
            # :DAMPMULCH    => [[:KEEBERRY,:MARANGABERRY],[:ORANBERRY]],
            #                   => Will dispense Damp Mulch if an Oran Berry + either a Kee or Maranga Berry is used
            # :GROWTHMULCH  => [[:KEEBERRY,:MARANGABERRY]], 
            #                   => Will dispense Growth Mulch if either a Kee or Maranga Berry is used
            # :GOOEYMULCH   => [3,:Any],
            #                   => Will dispense Gooey Mulch if 3 of the same-colored Berries are used
            # :SURPRISEMULCH => [2,:Blue],
            #                   => Will dispense Surprise Mulch if 2 Blue-colored Berries are used
            # :ALLUREMULCH  => :DifferentColors,
            #                   => Will dispense Allure Mulch if all different colored Berries are used
            :AMAZEMULCH     => [[:KEEBERRY],[:MARANGABERRY]],
            :SURPRISEMULCH  => [3,:Any],
            :DAMPMULCH      => [2,:Blue],
            :STABLEMULCH    => [2,:Yellow],
            :GOOEYMULCH     => [2,:Pink],
            :RICHMULCH      => [2,:Green],
            :ALLUREMULCH    => [2,:Red],
            :GROWTHMULCH    => :DifferentColors
        }

    #====================================================================================
    #============================== Preferred Settings ==================================
    #====================================================================================
    # Preferred functionality all requires the TDW Berry Core and Dex plugin.
        #--------------------------------------------------------------------------------
        # If true, each respective feature will be enabled.
        #--------------------------------------------------------------------------------

        BERRY_PREFERRED_WEATHER_ENABLED     = true
        BERRY_PREFERRED_ZONES_ENABLED       = true
        BERRY_UNPREFERRED_ZONES_ENABLED     = true
        BERRY_PREFERRED_SOIL_ENABLED        = true

        #--------------------------------------------------------------------------------
        # If true, show images to represent each of the respective pieces of information
        # in the Berrydex's Plant tab.
        # Images for each are found in the Plant Icons folder.
        #--------------------------------------------------------------------------------		
        BERRYDEX_SHOW_PREFERRED_WEATHER     = true
        BERRYDEX_SHOW_PREFERRED_ZONES       = true
        BERRYDEX_SHOW_UNPREFERRED_ZONES     = true
        BERRYDEX_SHOW_PREFERRED_SOIL        = true

        #--------------------------------------------------------------------------------
        # Define the term used to describe "Zones". For instance, you could treat this as
        # "Climate", instead.
        #--------------------------------------------------------------------------------		
        BERRYDEX_PREFERRED_ZONES_TERM       = _INTL("Zones")

        #--------------------------------------------------------------------------------
        # If true, the player will be told that they planted a berry in a preferred or 
        # unpreferred zone. This also applies to when a berry is planted in a preferred
        # soil type.
        #--------------------------------------------------------------------------------

        BERRY_PREFERRED_ZONE_WARNING        = true

        #--------------------------------------------------------------------------------
        # If a berry is planted and exposed to its preferred weather (as defined in the
        # berry_data.txt PBS file) before reaching its final stage of maturity, traits 
        # apply to the berry's plant. All traits are Additive, can be positive or negative.
        #--------------------------------------------------------------------------------	
        
        BERRY_PREFERRED_WEATHER_TRAITS = {
            :yield              => 2, # Positive increases final yield, negative decreases it
            :hours_per_stage    => 0, # Positive makes it grow slower, negative makes it faster
            :drying_per_hour    => 0, # Positive makes it dry out faster, negative makes it slower
            :mutation_chance    => 0, # Positive increases mutation chance, negative decreases it
            :max_replants       => 0  # Positive increases max replants, negative decreases them
        }

        #--------------------------------------------------------------------------------
        # If a berry is planted in its preferred zone (as defined in the berry_data.txt
        # PBS file), traits apply to the berry's plant. All traits are Additive, can be
        # positive or negative. If a planted in its unpreferred zone, different traits
        # apply.
        #--------------------------------------------------------------------------------	
        
        BERRY_PREFERRED_ZONE_TRAITS = {
            :yield              => 2, # Positive increases final yield, negative decreases it
            :hours_per_stage    => -1, # Positive makes it grow slower, negative makes it faster
            :drying_per_hour    => -1, # Positive makes it dry out faster, negative makes it slower
            :mutation_chance    => 5, # Positive increases mutation chance, negative decreases it
            :max_replants       => 2  # Positive increases max replants, negative decreases them
        }

        BERRY_UNPREFERRED_ZONE_TRAITS = {
            :yield              => -2, # Positive increases final yield, negative decreases it
            :hours_per_stage    => 2, # Positive makes it grow slower, negative makes it faster
            :drying_per_hour    => 0, # Positive makes it dry out faster, negative makes it slower
            :mutation_chance    => 0, # Positive increases mutation chance, negative decreases it
            :max_replants       => -2  # Positive increases max replants, negative decreases them
        }

        #--------------------------------------------------------------------------------
        # If a berry is planted in its preferred soil (as defined in the berry_data.txt
        # PBS file), traits apply to the berry's plant. All traits are Additive, can be
        # positive or negative.
        #--------------------------------------------------------------------------------	
        
        BERRY_PREFERRED_SOIL_TRAITS = {
            :yield              => 2, # Positive increases final yield, negative decreases it
            :hours_per_stage    => -1, # Positive makes it grow slower, negative makes it faster
            :drying_per_hour    => 0, # Positive makes it dry out faster, negative makes it slower
            :mutation_chance    => 0, # Positive increases mutation chance, negative decreases it
            :max_replants       => 2  # Positive increases max replants, negative decreases them
        }

    #====================================================================================
    #================================== Weeds Settings ==================================
    #====================================================================================
        #--------------------------------------------------------------------------------
        # If true, weeds can grow around berry plants.
        #--------------------------------------------------------------------------------	
        BERRY_USE_WEED_MECHANICS            = true

        #--------------------------------------------------------------------------------
        # Number of hours between weed growth checks.
        #--------------------------------------------------------------------------------	
        BERRY_WEED_HOURS_BETWEEN_CHECKS     = 2

        #--------------------------------------------------------------------------------
        # Chance out of 100 that weeds will grow during each check.
        #--------------------------------------------------------------------------------	
        BERRY_WEED_GROWTH_CHANCE            = 15

        #--------------------------------------------------------------------------------
        # List of Mulch items that will impact the chance of weeds growing.
        # Format: ITEM_ID => CHANCE
        # ITEM_ID   => Item ID of the Mulch
        # CHANCE    => Chance out of 100 weeds will appear when the mulch is used. This
        #              value overwrites BERRY_WEED_GROWTH_CHANCE.
        #--------------------------------------------------------------------------------		
        BERRY_MULCHES_IMPACTING_WEEDS = {
            :SURPRISEMULCH  => 5,
            :AMAZEMULCH     => -999
        }

        #--------------------------------------------------------------------------------
        # While a berry plant has weeds, traits apply. All traits are Additive, can be
        # positive or negative.
        #--------------------------------------------------------------------------------	
        
        BERRY_HAS_WEEDS_TRAITS = {
            :hours_per_stage    => 1, # Positive makes it grow slower, negative makes it faster
            :drying_per_hour    => 2, # Positive makes it dry out faster, negative makes it slower
            :mutation_chance    => 0, # Positive increases mutation chance, negative decreases it
            :pest_chance        => 10  # Positive increases chance of pests, negative decreases it
        }
    
    #====================================================================================
    #================================== Pests Settings ==================================
    #====================================================================================
        #--------------------------------------------------------------------------------
        # If true, Pokemon can be encountered on Berry trees.
        #--------------------------------------------------------------------------------	
        BERRY_USE_PEST_MECHANICS            = true

        #--------------------------------------------------------------------------------
        # If true, Pokemon on Berry trees will run away if you have an active repel.
        #--------------------------------------------------------------------------------	
        BERRY_REPEL_WORKS_ON_PESTS          = true

        #--------------------------------------------------------------------------------
        # Number of hours between checks for pests to attach themselves to a berry plant.
        #--------------------------------------------------------------------------------	
        BERRY_PEST_HOURS_BETWEEN_CHECKS     = 2

        #--------------------------------------------------------------------------------
        # Chance out of 100 that pests will attach themselves to a berry plant during 
        # each check.
        #--------------------------------------------------------------------------------	
        BERRY_PEST_APPEAR_CHANCE            = 15

        #--------------------------------------------------------------------------------
        # List of Mulch items that will impact the chance of pests appearing.
        # Format: ITEM_ID => CHANCE
        # ITEM_ID   => Item ID of the Mulch
        # CHANCE    => Chance out of 100 pests will appear when the mulch is used. This
        #              value overwrites BERRY_PEST_APPEAR_CHANCE.
        #--------------------------------------------------------------------------------		
        BERRY_MULCHES_IMPACTING_PESTS = {
            :SURPRISEMULCH  => 5,
            :AMAZEMULCH     => -999
        }

        #--------------------------------------------------------------------------------
        # While a berry plant has pests, traits apply. All traits are Additive, can be
        # positive or negative.
        #--------------------------------------------------------------------------------	
        
        BERRY_HAS_PESTS_TRAITS = {
            :hours_per_stage    => 2, # Positive makes it grow slower, negative makes it faster
            :drying_per_hour    => 0, # Positive makes it dry out faster, negative makes it slower
            :mutation_chance    => -5 # Positive increases mutation chance, negative decreases it
        }

        #--------------------------------------------------------------------------------
        # Set a Encounter Table to act as the default for Berry Pest encounters. If a 
        # map does not have a BerryPlantPest encounter table defined, this is used.
        #--------------------------------------------------------------------------------	
        BERRY_PEST_DEFAULT_ENCOUNTERS = [
            # [chance, :PokemonID, minLevel, maxLevel, (Optional)favoredColor],
            [20, :CATERPIE, 14, 15],
            [20, :LEDYBA, 14, 15, :Red],
            [20, :VOLBEAT, 14, 15, :Blue],
            [20, :ILLUMISE, 14, 15, :Purple],
            [20, :BURMY, 14, 15, :Green],
            [20, :COMBEE, 14, 15, :Yellow],
            [20, :SPEWPA, 14, 15, :Pink]
        ]

    #====================================================================================
    #================================ Watering Settings =================================
    #====================================================================================
        #--------------------------------------------------------------------------------
        # If true, the player shows an animation while watering berry plants.
        #--------------------------------------------------------------------------------	
        BERRY_SHOW_WATERING_ANIMATION       = true

        #--------------------------------------------------------------------------------
        # Set the spriteset to use for individual players. The order of the sprites
        # matches the trainers defined in metadata.txt
        #--------------------------------------------------------------------------------
        BERRY_WATERING_SPRITES = [
            "boy_watering", #Trainer [1]
            "girl_watering" #Trainer [2]
        ]

        #--------------------------------------------------------------------------------
        # If true, the player won't be given the option to water a berry plant if it 
        # already has maxed moisture.
        #--------------------------------------------------------------------------------	
        BERRY_PREVENT_WATERING_IF_MAXED     = false

        #--------------------------------------------------------------------------------
        # If true, berry plants will always be watered if it's raining on the same map. 
        #--------------------------------------------------------------------------------	
        BERRY_WATER_IF_RAINING              = true

        #--------------------------------------------------------------------------------
        # If true, the player must fill up watering cans to use them.
        #--------------------------------------------------------------------------------	
        BERRY_WATERING_MUST_FILL            = false

        #--------------------------------------------------------------------------------
        # If BERRY_WATERING_MUST_FILL is true, set how many times a watering can can be
        # used to water berry plants before becoming empty.
        #--------------------------------------------------------------------------------	
        BERRY_WATERING_USES_BEFORE_EMPTY    = 8

        #--------------------------------------------------------------------------------
        # List of watering can items that have different number of times they can be used 
        # to water berry plants before becoming empty than what's set in 
        # BERRY_WATERING_USES_BEFORE_EMPTY.
        # Format: ITEM_ID => TIMES
        # ITEM_ID   => Item ID of the Watering can
        # TIMES     => Positive integer representing the number of times the item can be
        #              used before becoming empty.
        #--------------------------------------------------------------------------------	
        BERRY_WATERING_USES_OVERRIDES = {
            # :SPRAYDUCK      => 10,
            # :SPRINKLOTAD    => 20
        }

        #--------------------------------------------------------------------------------
        # If you want some watering cans to have limited water, but some to always be 
        # considered full (such as a rare watering can later in the game), add those
        # watering cans that should always be considered full here.
        #--------------------------------------------------------------------------------
        BERRY_WATERING_USES_ALWAYS_FULL = [
            # :SPRINKLOTAD
            # :GOLDSPRAYDUCK
        ]

        #--------------------------------------------------------------------------------
        # If you water a berry plant with certain watering cans, traits can apply. To set
        # up, add a set of trait definitions to BERRY_WATERING_CAN_TRAIT_DEFINITIONS as a
        # hash, then assign a trait definition key to a watering can item in 
        # BERRY_WATERING_CAN_TRAITS. All traits are Additive, can be positive or negative.
        # BERRY_WATERING_CAN_TRAITS Format: ITEM_ID => TRAIT_DEFINITION
        # ITEM_ID           => Item ID of the Watering can
        # TRAIT_DEFINITION  => The name/key of a set of trait definitions as defined in
        #                      BERRY_WATERING_CAN_TRAIT_DEFINITIONS
        #--------------------------------------------------------------------------------	
        
        BERRY_WATERING_CAN_TRAITS = {
            # :SPRAYDUCK          => :TRAITS1
        }

        BERRY_WATERING_CAN_TRAIT_DEFINITIONS = {
            :TRAITS1 => {
                :hours_per_stage    => 0, # Positive makes it grow slower, negative makes it faster
                :drying_per_hour    => 0, # Positive makes it dry out faster, negative makes it slower
                :mutation_chance    => 0, # Positive increases mutation chance, negative decreases it
                :weed_chance        => -10,  # Positive increases chance of weeds, negative decreases it
                :pest_chance        => -10,  # Positive increases chance of pests, negative decreases it
                :yield              => 0 # Positive increases final yield, negative decreases it
            },
            :TRAITS2 => {
                :hours_per_stage    => -1, # Positive makes it grow slower, negative makes it faster
                :drying_per_hour    => 0, # Positive makes it dry out faster, negative makes it slower
                :mutation_chance    => 0, # Positive increases mutation chance, negative decreases it
                :weed_chance        => 10,  # Positive increases chance of weeds, negative decreases it
                :pest_chance        => 0,  # Positive increases chance of pests, negative decreases it
                :yield              => 1 # Positive increases final yield, negative decreases it
            }
        }

    #====================================================================================
    #================================== Soil Settings ===================================
    #====================================================================================
    BERRY_SOIL_DEFAULT = :Loamy

    BERRY_SOIL_DEFINITIONS = {
        # Loamy soil is the default, as if you didn't have any special soils.
        :Loamy => {
            :name               => _INTL("Loamy"), # Display name
            :planting_description => _INTL("soft, loamy"), # Description when planting. "It's {description} soil."
            :picked_description => _INTL("soft and loamy"), # Description after picking. "The soil returned to its {description} state."
            :moisture_graphic_ext => "", # Will use moisture graphics that end with this value. For example, "berrytreewet_sandy"
            :dex_graphic_ext    => "", # In the Berrydex, will use plant_dirt graphic that ends with this value. For example, "plant_dirt_sandy"
            :max_replants       => 0, # Positive increases max replants, negative decreases them
            :hours_per_stage    => 0, # Positive makes it grow slower, negative makes it faster
            :drying_per_hour    => 0, # Positive makes it dry out faster, negative makes it slower
            :mutation_chance    => 0, # Positive increases mutation chance, negative decreases it
            :weed_chance        => 0, # Positive increases chance of weeds, negative decreases it
            :pest_chance        => 0, # Positive increases chance of pests, negative decreases it
            :yield              => 0  # Positive increases final yield, negative decreases it; if an array of 2 integers, will be random in that range.
        },
        # Sandy soil dries out quite quickly.
        :Sandy => {
            :name               => _INTL("Sandy"), # Display name
            :planting_description => _INTL("coarse, sandy"), # Description when planting. "It's {description} soil."
            :picked_description => _INTL("coarse and sandy"), # Description after picking. "The soil returned to its {description} state."
            :moisture_graphic_ext => "_sandy", # Will use moisture graphics that end with this value. For example, "berrytreewet_sandy"
            :dex_graphic_ext    => "_sandy", # In the Berrydex, will use plant_dirt graphic that ends with this value. For example, "plant_dirt_sandy"
            :max_replants       => 0, # Positive increases max replants, negative decreases them
            :hours_per_stage    => 0, # Positive makes it grow slower, negative makes it faster
            :drying_per_hour    => 15, # Positive makes it dry out faster, negative makes it slower
            :mutation_chance    => 0, # Positive increases mutation chance, negative decreases it
            :weed_chance        => 0,  # Positive increases chance of weeds, negative decreases it
            :pest_chance        => 0,  # Positive increases chance of pests, negative decreases it
            :yield              => 0 # Positive increases final yield, negative decreases it; if an array of 2 integers, will be random in that range.
        },
        # Clay soil retains moisture longer and can increase the berry yield, but plants grow a lot slower.
        :Clay => {
            :name               => _INTL("Clay"), # Display name
            :planting_description => _INTL("dense, heavy"), # Description when planting. "It's {description} soil."
            :picked_description => _INTL("dense and heavy"), # Description after picking. "The soil returned to its {description} state."
            :moisture_graphic_ext => "_clay", # Will use moisture graphics that end with this value. For example, "berrytreewet_sandy"
            :dex_graphic_ext    => "_clay", # In the Berrydex, will use plant_dirt graphic that ends with this value. For example, "plant_dirt_sandy"
            :max_replants       => 0, # Positive increases max replants, negative decreases them
            :hours_per_stage    => 8, # Positive makes it grow slower, negative makes it faster
            :drying_per_hour    => -15, # Positive makes it dry out faster, negative makes it slower
            :mutation_chance    => 0, # Positive increases mutation chance, negative decreases it
            :weed_chance        => 0,  # Positive increases chance of weeds, negative decreases it
            :pest_chance        => 0,  # Positive increases chance of pests, negative decreases it
            :yield              => [0,3] # Positive increases final yield, negative decreases it; if an array of 2 integers, will be random in that range.
        },
        # Marshy soil never dries out, but plants replant themselves half as much, grow slower, and have an increased chance of weeds or pests.
        :Marshy => {
            :name               => _INTL("Marshy"), # Display name
            :planting_description => _INTL("wet, marshy"), # Description when planting. "It's {description} soil."
            :picked_description => _INTL("wet and marshy"), # Description after picking. "The soil returned to its {description} state."
            :moisture_graphic_ext => "", # Will use moisture graphics that end with this value. For example, "berrytreewet_sandy"
            :dex_graphic_ext    => "_marshy", # In the Berrydex, will use plant_dirt graphic that ends with this value. For example, "plant_dirt_sandy"
            :max_replants       => -5, # Positive increases max replants, negative decreases them
            :hours_per_stage    => 6, # Positive makes it grow slower, negative makes it faster
            :drying_per_hour    => -100, # Positive makes it dry out faster, negative makes it slower
            :mutation_chance    => 0, # Positive increases mutation chance, negative decreases it
            :weed_chance        => 15,  # Positive increases chance of weeds, negative decreases it
            :pest_chance        => 15,  # Positive increases chance of pests, negative decreases it
            :yield              => 0 # Positive increases final yield, negative decreases it; if an array of 2 integers, will be random in that range.
        },
        # Rocky soil has a higher mutation chance and decreased chance of weeds or pests, but plants grow a bit slower and yield less berries.
        :Rocky => {
            :name               => _INTL("Rocky"), # Display name
            :planting_description => _INTL("uneven, gravelly"), # Description when planting. "It's {description} soil."
            :picked_description => _INTL("uneven and gravelly"), # Description after picking. "The soil returned to its {description} state."
            :moisture_graphic_ext => "", # Will use moisture graphics that end with this value. For example, "berrytreewet_sandy"
            :dex_graphic_ext    => "_rocky", # In the Berrydex, will use plant_dirt graphic that ends with this value. For example, "plant_dirt_sandy"
            :max_replants       => 0, # Positive increases max replants, negative decreases them
            :hours_per_stage    => 3, # Positive makes it grow slower, negative makes it faster
            :drying_per_hour    => 0, # Positive makes it dry out faster, negative makes it slower
            :mutation_chance    => 25, # Positive increases mutation chance, negative decreases it
            :weed_chance        => -15,  # Positive increases chance of weeds, negative decreases it
            :pest_chance        => -15,  # Positive increases chance of pests, negative decreases it
            :yield              => -1 # Positive increases final yield, negative decreases it; if an array of 2 integers, will be random in that range.
        },
        # Fertile soil increases berry yield, plants grow faster, and plants replant themselves more, but there is an increased chance of pests.
        :Fertile => {
            :name               => _INTL("Fertile"), # Display name
            :planting_description => _INTL("rich, fertile"), # Description when planting. "It's {description} soil."
            :picked_description => _INTL("rich and fertile"), # Description after picking. "The soil returned to its {description} state."
            :moisture_graphic_ext => "", # Will use moisture graphics that end with this value. For example, "berrytreewet_sandy"
            :dex_graphic_ext    => "_fertile", # In the Berrydex, will use plant_dirt graphic that ends with this value. For example, "plant_dirt_sandy"
            :max_replants       => 0, # Positive increases max replants, negative decreases them
            :hours_per_stage    => -4, # Positive makes it grow slower, negative makes it faster
            :drying_per_hour    => 0, # Positive makes it dry out faster, negative makes it slower
            :mutation_chance    => 0, # Positive increases mutation chance, negative decreases it
            :weed_chance        => 0,  # Positive increases chance of weeds, negative decreases it
            :pest_chance        => 20,  # Positive increases chance of pests, negative decreases it
            :yield              => [1,3] # Positive increases final yield, negative decreases it; if an array of 2 integers, will be random in that range.
        }
    }

    #====================================================================================
    #=============================== Berry Seed Settings ================================
    #====================================================================================

        #--------------------------------------------------------------------------------
        # If true, Berry Seeds will be enabled. The player will only be able to plant 
        # berry seeds to start a berry plant.
        #--------------------------------------------------------------------------------	
        BERRY_USE_BERRY_SEEDS          = false

        #--------------------------------------------------------------------------------
        # Default chance out of 100 that berry seed items will be found when harvesting a
        # berry plant.
        #--------------------------------------------------------------------------------	
        BERRY_SEED_DROP_CHANCE          = 50

        #--------------------------------------------------------------------------------
        # If a berry seed item drops when harvesting a berry plant, this is the amount
        # of seed items that will drop. Set as an integer for a single value. Set as an
        # array of 2 integers for a random value in that range. For either the single
        # value or a value in the range, set to :Yield and that value will be equal to 
        # the berry yield at the time of harvesting.
        #--------------------------------------------------------------------------------	
        BERRY_SEED_DROP_AMOUNT          = [1, :Yield]

        #--------------------------------------------------------------------------------
        # Set seed drop chance and amount overrides for different berry types.
        #--------------------------------------------------------------------------------
        BERRY_SEED_DROP_OVERRIDES = {
            # :ORANBERRY => { #Use the Berry's Item ID
            #     :chance => 80, # Chance out of 100 that seeds will drop
            #     :amount => [2,4] # Amount to drop, same setup as BERRY_SEED_DROP_AMOUNT
            # },
            # :CHERIBERRY => {
            #     :chance => 10,
            #     :amount => 16
            # }
        }

        #--------------------------------------------------------------------------------
        # Set the pools of mystery seeds. If you plant a mystery seed, it will become
        # a berry plant based on the available berry IDs set in it's defined array,
        # randomly chosen. Set a weight for the berry to be chosen.
        #--------------------------------------------------------------------------------
        BERRY_MYSTERY_SEED_POOLS = {
            :MYSTERYBERRYSEED => [ # Use the Item ID of a mystery berry
                [:ORANBERRY, 33], # Each value should be an array consisting of [:BERRYID, weight]
                [:PECHABERRY, 33], 
                [:CHERIBERRY, 33], 
                [:MARANGABERRY, 1]
            ],
            # :MYSTERYBERRYSEEDRARE => [ 
            #     [:CUSTAPBERRY, 25], 
            #     [:MICLEBERRY, 25], 
            #     [:KEEBERRY, 25], 
            #     [:ENIGMABERRY, 25]
            # ],
        }
		
end