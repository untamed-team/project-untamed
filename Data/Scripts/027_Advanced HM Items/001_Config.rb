#===========================================
# Configuration
#===========================================

# :internal_name    -> has to be an unique name, the name you define for the item in the PBS file
# :active           -> defines if this item should be used, if set to false you do not have to add an item to the PBS  file (example: if you want an item for Rock Smash but not for Cut set active for Cut to false)
#                      if the item is active you will no longer be able to use the corresponding HM Move outside of battle
# :needed_badge     -> the id of the badge required in order to use the item (0 means no badge required)
# :needed_switches  -> the switches that needs to be active in order to use the item (leave the brackets empty for no switch requirement. example: [4,22,77] would mean that the switches 4, 22 and 77 must be active)
# :use_in_debug     -> when true this item can be used in debug regardless of the requirements

module AdvancedHMItems

ROCKSMASH_CONFIG = {
    :internal_name      => :ROCKSMASHITEM,
    :active             => true,
    :needed_badge       => 0,
    :needed_switches    => [],
    :use_in_debug       => false
}

CUT_CONFIG = {
    :internal_name      => :CUTITEM,
    :active             => true,
    :needed_badge       => 0,
    :needed_switches    => [],
    :use_in_debug       => false
}

STRENGTH_CONFIG = {
    :internal_name      => :STRENGTHITEM,
    :active             => true,
    :needed_badge       => 0,
    :needed_switches    => [],
    :use_in_debug       => false
}

SURF_CONFIG = {
    :internal_name      => :SURFITEM,
    :active             => true,
    :needed_badge       => 0,
    :needed_switches    => [],
    :use_in_debug       => false
}

FLY_CONFIG = {
    :internal_name      => :FLYITEM,
    :active             => true,
    :needed_badge       => 0,
    :needed_switches    => [],
    :use_in_debug       => false
}

HEADBUTT_CONFIG = {
    :internal_name      => :HEADBUTTITEM,
    :active             => true,
    :needed_badge       => 0,
    :needed_switches    => [],
    :use_in_debug       => false
}

FLASH_CONFIG = {
    :internal_name      => :FLASHITEM,
    :active             => true,
    :needed_badge       => 0,
    :needed_switches    => [],
    :use_in_debug       => false
}

end