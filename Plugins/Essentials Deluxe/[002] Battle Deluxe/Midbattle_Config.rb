#===============================================================================
# Essentials Deluxe module.
#===============================================================================


#-------------------------------------------------------------------------------
# Set up mid-battle triggers that may be called in a deluxe battle event.
# Add your custom midbattle hash here and you will be able to call upon it with
# the defined symbol, rather than writing out the entire thing in an event.
#-------------------------------------------------------------------------------
module EssentialsDeluxe
  #-----------------------------------------------------------------------------
  # Demonstration of all possible midbattle triggers.
  # Plug this into any Deluxe Battle to get a message describing when each
  # trigger activates.
  #-----------------------------------------------------------------------------
  DEMO_SPEECH = {
    #---------------------------------------------------------------------------
    # Turn Phase Triggers
    #---------------------------------------------------------------------------
    "turnCommand"           => [:Self, "Trigger: 'turnCommand'\nCommand Phase start."],
    "turnAttack"            => [:Self, "Trigger: 'turnAttack'\nAttack Phase start."],
    "turnEnd"               => [:Self, "Trigger: 'turnEnd'\nEnd of Round Phase end."],
    #---------------------------------------------------------------------------
    # Move Triggers
    #---------------------------------------------------------------------------
    "attack"                => [:Self, "Trigger: 'attack'\nYour Pokémon successfully launches a damage-dealing move."],
    "attack_foe"            => [:Self, "Trigger: 'attack_foe'", "{1} successfully launches a damage-dealing move."],
    "attack_ally"           => [:Self, "Trigger: 'attack_ally'\nYour partner's Pokémon successfully launches a damage-dealing move."],
    "status"                => [:Self, "Trigger: 'status'\nYour Pokémon successfully launches a status move."],
    "status_foe"            => [:Self, "Trigger: 'status_foe'", "{1} successfully launches a status move."],
    "status_ally"           => [:Self, "Trigger: 'status_ally'\nYour partner's Pokémon successfully launches a status move."],
    "superEffective"        => [:Self, "Trigger: 'superEffective'\nYour Pokémon's attack dealt super effective damage."],
    "superEffective_foe"    => [:Self, "Trigger: 'superEffective_foe'", "{1}'s attack dealt super effective damage."],
    "superEffective_ally"   => [:Self, "Trigger: 'superEffective_ally'\nYour partner's Pokémon's attack dealt super effective damage."],
    "notVeryEffective"      => [:Self, "Trigger: 'notVeryEffective'\nYour Pokémon's attack dealt not very effective damage."],
    "notVeryEffective_foe"  => [:Self, "Trigger: 'notVeryEffective_foe'", "{1}'s attack dealt not very effective damage."],
    "notVeryEffective_ally" => [:Self, "Trigger: 'notVeryEffective_ally'\nYour partner's Pokémon's attack dealt not very effective damage."],
    "immune"                => [:Self, "Trigger: 'immune'\nYour Pokémon's attack was negated or has no effect."],
    "immune_foe"            => [:Self, "Trigger: 'immune_foe'", "{1}'s attack was negated or has no effect."],
    "immune_ally"           => [:Self, "Trigger: 'immune_ally'\nYour partner's Pokémon's attack was negated or has no effect."],
    "miss"                  => [:Self, "Trigger: 'miss'\nYour Pokémon's attack missed."],
    "miss_foe"              => [:Self, "Trigger: 'miss_foe'", "{1}'s attack missed."],
    "miss_ally"             => [:Self, "Trigger: 'miss_ally'\nYour partner's Pokémon's attack missed."],
    "criticalHit"           => [:Self, "Trigger: 'criticalHit'\nYour Pokémon's attack dealt a critical hit."],
    "criticalHit_foe"       => [:Self, "Trigger: 'criticalHit_foe'", "{1}'s attack dealt a critical hit."],
    "criticalHit_ally"      => [:Self, "Trigger: 'criticalHit_ally'\nYour partner's Pokémon's attack dealt a critical hit."],
    #---------------------------------------------------------------------------
    # Damage State Triggers
    #---------------------------------------------------------------------------
    "damage"                => [:Self, "Trigger: 'damage'\nYour Pokémon took damage from an attack."],
    "damage_foe"            => [:Self, "Trigger: 'damage_foe'", "{1} took damage from an attack."],
    "damage_ally"           => [:Self, "Trigger: 'damage_ally'\nYour partner's Pokémon took damage from an attack."],
    "lowhp"                 => [:Self, "Trigger: 'lowhp'\nYour Pokémon took damage and its HP fell to 1/4th max HP or lower."],
    "lowhp_foe"             => [:Self, "Trigger: 'lowhp_foe'", "{1} took damage and its HP fell to 1/4th max HP or lower."],
    "lowhp_ally"            => [:Self, "Trigger: 'lowhp_ally'\nYour partner's Pokémon took damage and its HP fell to 1/4th max HP or lower."],
    "lowhp_final"           => [:Self, "Trigger: 'lowhp_final'\nYour final Pokémon took damage and its HP fell to 1/4th max HP or lower."],
    "lowhp_final_foe"       => [:Self, "Trigger: 'lowhp_final_foe'", "{1} is the final Pokémon; damage was taken and its HP fell to 1/4th max HP or lower."],
    "lowhp_final_ally"      => [:Self, "Trigger: 'lowhp_final_ally'\nYour partner's final Pokémon took damage and its HP fell to 1/4th max HP or lower."],
    "fainted"               => [:Self, "Trigger: 'fainted'\nYour Pokémon fainted."],
    "fainted_foe"           => [:Self, "Trigger: 'fainted_foe'", "{1} fainted."],
    "fainted_ally"          => [:Self, "Trigger: 'fainted_ally'\nYour partner's Pokémon fainted."],
    #---------------------------------------------------------------------------
    # Switch Triggers
    #---------------------------------------------------------------------------
    "recall"                => [:Self, "Trigger: 'recall'\nYou withdrew an active Pokémon."],
    "recall_foe"            => [:Self, "Trigger: 'recall_foe'\nI withdrew an active Pokémon."],
    "recall_ally"           => [:Self, "Trigger: 'recall_ally'\nYour partner withdrew an active Pokémon."],
    "beforeNext"            => [:Self, "Trigger: 'beforeNext'\nYou intend to send out a Pokémon."],
    "beforeNext_foe"        => [:Self, "Trigger: 'beforeNext_foe'\nI intend to send out a Pokémon."],
    "beforeNext_ally"       => [:Self, "Trigger: 'beforeNext_ally'\nYour partner intends to send out a Pokémon."],
    "afterNext"             => [:Self, "Trigger: 'afterNext'\nYou successfully sent out a Pokémon."],
    "afterNext_foe"         => [:Self, "Trigger: 'afterNext_foe'\nI successfully sent out a Pokémon."],
    "afterNext_ally"        => [:Self, "Trigger: 'afterNext_ally'\nYour partner successfully sent out a Pokémon."],
    "beforeLast"            => [:Self, "Trigger: 'beforeLast'\nYou intend to send out your final Pokémon."],
    "beforeLast_foe"        => [:Self, "Trigger: 'beforeLast_foe'\nI intend to send out my final Pokémon."],
    "beforeLast_ally"       => [:Self, "Trigger: 'beforeLast_ally'\nYour partner intends to send out their final Pokémon."],
    "afterLast"             => [:Self, "Trigger: 'afterLast'\nYou successfully sent out your final Pokémon."],
    "afterLast_foe"         => [:Self, "Trigger: 'afterLast_foe'\nI successfully sent out my final Pokémon."],
    "afterLast_ally"        => [:Self, "Trigger: 'afterLast_ally'\nYour partner successfully sent out their final Pokémon."],
    #---------------------------------------------------------------------------
    # Special Action Triggers
    #---------------------------------------------------------------------------
    "item"                  => [:Self, "Trigger: 'item'\nYou used an item from your inventory."],
    "item_foe"              => [:Self, "Trigger: 'item_foe'\nI used an item from my inventory."],
    "item_ally"             => [:Self, "Trigger: 'item_ally'\nYour partner used an item from their inventory."],
    "mega"                  => [:Self, "Trigger: 'mega'\nYou initiate Mega Evolution."],
    "mega_foe"              => [:Self, "Trigger: 'mega_foe'\nI initiate Mega Evolution."],
    "mega_ally"             => [:Self, "Trigger: 'mega_ally'\nYour partner initiates Mega Evolution."],
    "zmove"                 => [:Self, "Trigger: 'zmove'\nYou initiate a Z-Move."],
    "zmove_foe"             => [:Self, "Trigger: 'zmove_foe'\nI initiate a Z-Move."],
    "zmove_ally"            => [:Self, "Trigger: 'zmove_ally'\nYour partner initiates a Z-Move."],
    "ultra"                 => [:Self, "Trigger: 'ultra'\nYou initiate Ultra Burst."],
    "ultra_foe"             => [:Self, "Trigger: 'ultra_foe'\nI initiate Ultra Burst."],
    "ultra_ally"            => [:Self, "Trigger: 'ultra_ally'\nYour partner initiates Ultra Burst."],
    "dynamax"               => [:Self, "Trigger: 'dynamax'\nYou initiate Dynamax."],
    "dynamax_foe"           => [:Self, "Trigger: 'dynamax_foe'\nI initiate Dynamax."],
    "dynamax_ally"          => [:Self, "Trigger: 'dynamax_ally'\nYour partner initiates Dynamax."],
	"strongStyle"           => [:Self, "Trigger: 'strongStyle'\nYou initiate Strong Style."],
	"strongStyle_foe"       => [:Self, "Trigger: 'strongStyle_foe'\nI initiate Strong Style."],
	"strongStyle_ally"      => [:Self, "Trigger: 'strongStyle_ally'\nYour partner initiates Strong Style."],
	"agileStyle"            => [:Self, "Trigger: 'agileStyle'\nYou initiate Agile Style."],
	"agileStyle_foe"        => [:Self, "Trigger: 'agileStyle_foe'\nI initiate Agile Style."],
	"agileStyle_ally"       => [:Self, "Trigger: 'agileStyle_ally'\nYour partner initiates Agile Style."],
    "zodiac"                => [:Self, "Trigger: 'zodiac'\nYou initiate a Zodiac Power."],
    "zodiac_foe"            => [:Self, "Trigger: 'zodiac_foe'\nI initiate a Zodiac Power."],
    "zodiac_ally"           => [:Self, "Trigger: 'zodiac_ally'\nYour partner initiates a Zodiac Power."],
    "focus"                 => [:Self, "Trigger: 'focus'\nYour Pokémon harnesses its focus."],
    "focus_foe"             => [:Self, "Trigger: 'focus_foe'", "{1} harnesses its focus."],
    "focus_ally"            => [:Self, "Trigger: 'focus_ally'\nYour partner's Pokémon harnesses its focus."],
    "focus_boss"            => [:Self, "Trigger: 'focus_boss'", "{1} harnesses its focus with the Enraged style."],  
    #---------------------------------------------------------------------------
    # Player-only Triggers
    #---------------------------------------------------------------------------
    "beforeCapture"         => [:Self, "Trigger: 'beforeCapture'\nYou intend to throw a selected Poké Ball."],
    "afterCapture"          => [:Self, "Trigger: 'afterCapture'\nYou successfully captured the targeted Pokémon."],
    "failedCapture"         => [:Self, "Trigger: 'failedCapture'\nYou failed to capture the targeted Pokémon."],
    "loss"                  => [:Self, "Trigger: 'loss'\nYou lost the battle."]
  }
  
  
  
  #-----------------------------------------------------------------------------
  # Demo scenario vs. wild Rotom that shifts forms.
  #-----------------------------------------------------------------------------
  DEMO_WILD_ROTOM = {
    "turnCommand" => {
      :text      => [1, "{1} emited a powerful magnetic pulse!"],
      :anim      => [:CHARGE, 1],
      :playsound => "Anim/Paralyze3",
      :text_1    => "Your Poké Balls short-circuited!\nThey cannot be used this battle!"
    },
    "turnEnd_repeat" => {
      :delay   => "superEffective",
      :battler => :Opposing,
      :anim    => [:NIGHTMARE, :Self],
      :form    => [:Random, "{1} possessed a new appliance!"],
      :hp      => 4,
      :status  => :NONE,
      :ability => [:MOTORDRIVE, true],
      :item    => [:CELLBATTERY, "{1} equipped a Cell Battery it found in the appliance!"]
    },
    "superEffective" => {
      :battler => :Self,
      :text    => [:Opposing, "{1} emited an electrical pulse out of desperation!"],
      :status  => [:PARALYSIS, true]
    },
    "damage_foe_repeat" => {
      :delay   => ["halfhp_foe", "lowhp_foe"],
      :effects => [
        [PBEffects::Charge, 5, "{1} began charging power!"],
        [PBEffects::MagnetRise, 5, "{1} levitated with electromagnetism!"],
      ],
      :terrain => :Electric
    }
  }
  
  
  #-----------------------------------------------------------------------------
  # Demo scenario vs. Rocket Grunt in a collapsing cave.
  #-----------------------------------------------------------------------------
  DEMO_COLLAPSING_CAVE = {
    "turnCommand" => {
      :playsound  => "Mining collapse",
      :text    => "The cave ceiling begins to crumble down all around you!",
      :speech  => ["I am not letting you escape!", 
                   "I don't care if this whole cave collapses down on the both of us...haha!"],
      :text_1  => "Defeat your opponent before time runs out!"
    },
    "turnEnd_repeat" => {
      :playsound => "Mining collapse",
      :text      => "The cave continues to collapse all around you!"
    },
    "turnEnd_2" => {
      :battler => 0,
      :text    => "{1} was struck on the head by a falling rock!",
      :anim    => [:ROCKSMASH, 0],
      :hp      => -4,
      :status  => :CONFUSION
    },
    "turnEnd_3" => {
      :text => ["You're running out of time!", 
                "You need to escape immediately!"]
    },
    "turnEnd_4" => {
      :text      => ["You failed to defeat your opponent in time!", 
                     "You were forced to flee the battle!"],
      :playsound => "Battle flee",
      :endbattle => 2
    },
    "lowhp_final_foe" => {
      :speech  => "My {1} will never give up!",
      :anim    => [:BULKUP, :Self],
      :playcry => true,
      :hp      => [2, "{1} is standing its ground!"],
      :stats   => [:DEFENSE, 2, :SPECIAL_DEFENSE, 2]
    },
    "loss" => "Haha...you'll never make it out alive!"
  }
end