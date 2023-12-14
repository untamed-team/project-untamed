#===============================================================================
# Essentials Deluxe module.
#===============================================================================
# Set up mid-battle triggers that may be called in a deluxe battle event.
# Add your custom midbattle hash here and you will be able to call upon it with
# the defined symbol, rather than writing out the entire thing in an event.
#-------------------------------------------------------------------------------


module EssentialsDeluxe
################################################################################
# Demo of all possible midbattle triggers.
################################################################################
  #-----------------------------------------------------------------------------
  # Displays speech indicating when each trigger is activated.
  #-----------------------------------------------------------------------------
  DEMO_SPEECH = {
    #---------------------------------------------------------------------------
    # Turn Phase Triggers
    #---------------------------------------------------------------------------
    "turnCommand"           => "Trigger: 'turnCommand'\nCommand Phase start.",
    "turnAttack"            => "Trigger: 'turnAttack'\nAttack Phase start.",
    "turnEnd"               => "Trigger: 'turnEnd'\nEnd of Round Phase end.",
    #---------------------------------------------------------------------------
    # Move Usage Triggers
    #---------------------------------------------------------------------------
    "move"                  => "Trigger: 'move'\nMy Pokémon successfully uses a move.",
    "move_foe"              => "Trigger: 'move_foe'\nOpponent successfully uses a move.",
    "move_ally"             => "Trigger: 'move_ally'\nMy Pokémon successfully uses a move.",
    "damageMove"            => "Trigger: 'damageMove'\nMy Pokémon successfully uses a damage-dealing move.",
    "damageMove_foe"        => "Trigger: 'damageMove_foe'\nOpponent successfully uses a damage-dealing move.",
    "damageMove_ally"       => "Trigger: 'damageMove_ally'\nMy Pokémon successfully uses a damage-dealing move.",
    "physicalMove"          => "Trigger: 'physicalMove'\nMy Pokémon successfully uses a physical move.",
    "physicalMove_foe"      => "Trigger: 'physicalMove_foe'\nOpponent successfully uses a physical move.",
    "physicalMove_ally"     => "Trigger: 'physicalMove_ally'\nMy Pokémon successfully uses a physical move.",
    "specialMove"           => "Trigger: 'specialMove'\nMy Pokémon successfully uses a special move.",
    "specialMove_foe"       => "Trigger: 'specialMove_foe'\nOpponent successfully uses a special move.",
    "specialMove_ally"      => "Trigger: 'specialMove_ally'\nMy Pokémon successfully uses a special move.",
    "statusMove"            => "Trigger: 'statusMove'\nMy Pokémon successfully uses a status move.",
    "statusMove_foe"        => "Trigger: 'statusMove_foe'\nOpponent successfully uses a status move.",
    "statusMove_ally"       => "Trigger: 'statusMove_ally'\nMy Pokémon successfully uses a status move.",
    #---------------------------------------------------------------------------
    # Attacker Triggers
    #---------------------------------------------------------------------------
    "superEffective"        => "Trigger: 'superEffective'\nMy Pokémon's attack was super effective.",
    "superEffective_foe"    => "Trigger: 'superEffective_foe'\nOpponent's attack was super effective.",
    "superEffective_ally"   => "Trigger: 'superEffective_ally'\nMy Pokémon's attack was super effective.",
    "notVeryEffective"      => "Trigger: 'notVeryEffective'\nMy Pokémon's attack was not very effective.",
    "notVeryEffective_foe"  => "Trigger: 'notVeryEffective_foe'\nOpponent's attack was not very effective.",
    "notVeryEffective_ally" => "Trigger: 'notVeryEffective_ally'\nMy Pokémon's attack was not very effective.",
    "immune"                => "Trigger: 'immune'\nMy Pokémon's attack was negated or has no effect.",
    "immune_foe"            => "Trigger: 'immune_foe'\nOpponent's attack was negated or has no effect.",
    "immune_ally"           => "Trigger: 'immune_ally'\nMy Pokémon's attack was negated or has no effect.",
    "miss"                  => "Trigger: 'miss'\nMy Pokémon's attack missed.",
    "miss_foe"              => "Trigger: 'miss_foe'\nOpponent's attack missed.",
    "miss_ally"             => "Trigger: 'miss_ally'\nMy Pokémon's attack missed.",
    "criticalHit"           => "Trigger: 'criticalHit'\nMy Pokémon's attack dealt a critical hit.",
    "criticalHit_foe"       => "Trigger: 'criticalHit_foe'\nOpponent's attack dealt a critical hit.",
    "criticalHit_ally"      => "Trigger: 'criticalHit_ally'\nMy Pokémon's attack dealt a critical hit.",
    #---------------------------------------------------------------------------
    # Defender Triggers
    #---------------------------------------------------------------------------
    "damageTaken"           => "Trigger: 'damageTaken'\nMy Pokémon took damage from an attack.",
    "damageTaken_foe"       => "Trigger: 'damageTaken_foe'\nOpponent took damage from an attack.",
    "damageTaken_ally"      => "Trigger: 'damageTaken_ally'\nMy Pokémon took damage from an attack.",
    "statusInflicted"       => "Trigger: 'statusInflicted'\nMy Pokémon was inflicted with a status condition.",
    "statusInflicted_foe"   => "Trigger: 'statusInflicted_foe'\nOpponent was inflicted with a status condition.",
    "statusInflicted_ally"  => "Trigger: 'statusInflicted_ally'\nMy Pokémon was inflicted with a status condition.",
    "halfHP"                => "Trigger: 'halfHP'\nMy Pokémon's HP fell to 50% or lower after taking damage.",
    "halfHP_foe"            => "Trigger: 'halfHP_foe'\nOpponent's HP fell to 50% or lower after taking damage.",
    "halfHP_ally"           => "Trigger: 'halfHP_ally'\nMy Pokémon's HP fell to 50% or lower after taking damage.",
    "halfHPLast"            => "Trigger: 'halfHPLast'\nMy final Pokémon's HP fell to 50% or lower after taking damage.",
    "halfHPLast_foe"        => "Trigger: 'halfHPLast_foe'\nFinal opponent's HP fell to 50% or lower after taking damage.",
    "halfHPLast_ally"       => "Trigger: 'halfHPLast_ally'\nMy final Pokémon's HP fell to 50% or lower after taking damage.",
    "lowHP"                 => "Trigger: 'lowHP'\nMy Pokémon's HP fell to 25% or lower after taking damage.",
    "lowHP_foe"             => "Trigger: 'lowHP_foe'\nOpponent's HP fell to 25% or lower after taking damage.",
    "lowHP_ally"            => "Trigger: 'lowHP_ally'\nMy Pokémon's HP fell to 25% or lower after taking damage.",
    "lowHPLast"             => "Trigger: 'lowHPLast'\nMy final Pokémon's HP fell to 25% or lower after taking damage.",
    "lowHPLast_foe"         => "Trigger: 'lowHPLast_foe'\nFinal opponent's HP fell to 25% or lower after taking damage.",
    "lowHPLast_ally"        => "Trigger: 'lowHPLast_ally'\nMy final Pokémon's HP fell to 25% or lower after taking damage.",
    "fainted"               => "Trigger: 'fainted'\nMy Pokémon fainted.",
    "fainted_foe"           => "Trigger: 'fainted_foe'\nOpponent fainted.",
    "fainted_ally"          => "Trigger: 'fainted_ally'\nMy Pokémon fainted.",
    #---------------------------------------------------------------------------
    # Switching Triggers
    #---------------------------------------------------------------------------
    "recall"                => "Trigger: 'recall'\nI intend to withdraw an active Pokémon.",
    "recall_foe"            => "Trigger: 'recall_foe'\nOpponent intends to withdraw an active Pokémon.",
    "recall_ally"           => "Trigger: 'recall_ally'\nI intend to withdraw an active Pokémon.",
    "beforeNext"            => "Trigger: 'beforeNext'\nI intend to send out a Pokémon.",
    "beforeNext_foe"        => "Trigger: 'beforeNext_foe'\nOpponent intends to send out a Pokémon.",
    "beforeNext_ally"       => "Trigger: 'beforeNext_ally'\nI intend to send out a Pokémon.",
    "afterNext"             => "Trigger: 'afterNext'\nI successfully sent out a Pokémon.",
    "afterNext_foe"         => "Trigger: 'afterNext_foe'\nOpponent successfully sent out a Pokémon.",
    "afterNext_ally"        => "Trigger: 'afterNext_ally'\nI successfully sent out a Pokémon.",
    "beforeLast"            => "Trigger: 'beforeLast'\nI intend to send out my final Pokémon.",
    "beforeLast_foe"        => "Trigger: 'beforeLast_foe'\nOpponent intends to send out final Pokémon.",
    "beforeLast_ally"       => "Trigger: 'beforeLast_ally'\nI intend to send out my final Pokémon.",
    "afterLast"             => "Trigger: 'afterLast'\nI successfully sent out my final Pokémon.",
    "afterLast_foe"         => "Trigger: 'afterLast_foe'\nOpponent successfully sent out final Pokémon.",
    "afterLast_ally"        => "Trigger: 'afterLast_ally'\nI successfully sent out my final Pokémon.",
    #---------------------------------------------------------------------------
    # Special Action Triggers
    #---------------------------------------------------------------------------
    "item"                  => "Trigger: 'item'\nI intend to use an item from my inventory.",
    "item_foe"              => "Trigger: 'item_foe'\nOpponent intends to use an item from their inventory.",
    "item_ally"             => "Trigger: 'item_ally'\nI intend to use an item from my inventory.",
    "mega"                  => "Trigger: 'mega'\nI intend to initiate Mega Evolution.",
    "mega_foe"              => "Trigger: 'mega_foe'\nOpponent intends to initiate Mega Evolution.",
    "mega_ally"             => "Trigger: 'mega_ally'\nI intend to initiate Mega Evolution.",
    "primal"                => "Trigger: 'primal'\nI intend to initiate Primal Reversion.",
    "primal_foe"            => "Trigger: 'primal_foe'\nOpponent intends to initiate Primal Reversion.",
    "primal_ally"           => "Trigger: 'primal_ally'\nI intend to initiate Primal Reversion.",
    #---------------------------------------------------------------------------
    # Plugin Triggers
    #---------------------------------------------------------------------------
    # Z-Move
    "zmove"                 => "Trigger: 'zmove'\nI intend to initiate a Z-Move.",
    "zmove_foe"             => "Trigger: 'zmove_foe'\nOpponent intends to initiate a Z-Move.",
    "zmove_ally"            => "Trigger: 'zmove_ally'\nI intend to initiate a Z-Move.",
    # Ultra Burst
    "ultra"                 => "Trigger: 'ultra'\nI intend to initiate Ultra Burst.",
    "ultra_foe"             => "Trigger: 'ultra_foe'\nOpponent intends to initiate Ultra Burst.",
    "ultra_ally"            => "Trigger: 'ultra_ally'\nI intend to initiate Ultra Burst.",
    # Dynamax
    "dynamax"               => "Trigger: 'dynamax'\nI intend to initiate Dynamax.",
    "dynamax_foe"           => "Trigger: 'dynamax_foe'\nOpponent intends to initiate Dynamax.",
    "dynamax_ally"          => "Trigger: 'dynamax_ally'\nI intend to initiate Dynamax.",
    "gmax"                  => "Trigger: 'gmax'\nI intend to initiate Gigantamax.",
    "gmax_foe"              => "Trigger: 'gmax_foe'\nOpponent intends to initiate Gigantamax.",
    "gmax_ally"             => "Trigger: 'gmax_ally'\nI intend to initiate Gigantamax.",
    # Battle Styles
    "battleStyle"           => "Trigger: 'battleStyle'\nI intend to initiate a battle style.",
    "battleStyle_foe"       => "Trigger: 'battleStyle_foe'\nOpponent intends to initiate a battle style.",
    "battleStyle_ally"      => "Trigger: 'battleStyle_ally'\nI intend to initiate a battle style.",
    "strongStyle"           => "Trigger: 'strongStyle'\nI intend to initiate Strong Style.",
    "strongStyle_foe"       => "Trigger: 'strongStyle_foe'\nOpponent intends to initiate Strong Style.",
    "strongStyle_ally"      => "Trigger: 'strongStyle_ally'\nI intend to initiate Strong Style.",
    "agileStyle"            => "Trigger: 'agileStyle'\nI intend to initiate Agile Style.",
    "agileStyle_foe"        => "Trigger: 'agileStyle_foe'\nOpponent intends to initiate Agile Style.",
    "agileStyle_ally"       => "Trigger: 'agileStyle_ally'\nI intend to initiate Agile Style.",
    "styleEnd"              => "Trigger: 'styleEnd'\nMy style cooldown expired.",
    "styleEnd_foe"          => "Trigger: 'styleEnd_foe'\nOpponent style cooldown expired.",
    "styleEnd_ally"         => "Trigger: 'styleEnd_ally'\nMy style cooldown expired.",
    # Terastallization
    "tera"                  => "Trigger: 'tera'\nI intend to initiate Terastallization.",
    "tera_foe"              => "Trigger: 'tera_foe'\nOpponent intends to initiate Terastallization.",
    "tera_ally"             => "Trigger: 'tera_ally'\nI intend to initiate Terastallization.",
    "teraType"              => "Trigger: 'teraType'\nMy Pokémon successfully uses a Tera-boosted move.",
    "teraType_foe"          => "Trigger: 'teraType_foe'\nOpponent successfully uses a Tera-boosted move.",
    "teraType_ally"         => "Trigger: 'teraType_ally'\nMy Pokémon successfully uses a Tera-boosted move.",
    "zodiac"                => "Trigger: 'zodiac'\nI intend to initiate a Zodiac Power.",
    "zodiac_foe"            => "Trigger: 'zodiac_foe'\nOpponent intends to initiate a Zodiac Power.",
    "zodiac_ally"           => "Trigger: 'zodiac_ally'\nI intend to initiate a Zodiac Power.",
    # Focus
    "focus"                 => "Trigger: 'focus'\nMy Pokémon intends to harness its focus.",
    "focus_foe"             => "Trigger: 'focus_foe'\nOpponent intends to harness its focus.",
    "focus_ally"            => "Trigger: 'focus_ally'\nMy Pokémon intends to harness its focus.",
    "focusBoss"             => "Trigger: 'focus_boss'\nPokémon harnesses its focus with the Enraged style.",
    "focusEnd"              => "Trigger: 'focusEnd'\nMy Pokemon's Focus was used.",
    "focusEnd_foe"          => "Trigger: 'focusEnd_foe'\nOpponent's Focus was used.",
    "focusEnd_ally"         => "Trigger: 'focusEnd_ally'\nMy Pokemon's Focus was used.",
    #---------------------------------------------------------------------------
    # Player-only Triggers
    #---------------------------------------------------------------------------
    "beforeCapture"         => "Trigger: 'beforeCapture'\nI intend to throw a selected Poké Ball.",
    "afterCapture"          => "Trigger: 'afterCapture'\nI successfully captured the targeted Pokémon.",
    "failedCapture"         => "Trigger: 'failedCapture'\nI failed to capture the targeted Pokémon.",
    "loss"                  => "Trigger: 'loss'\nThe battle ends in a loss."
  }
  
  
################################################################################
# Example demo of a generic capture tutorial battle.
################################################################################

  #-----------------------------------------------------------------------------
  # Demo capture tutorial vs. wild Pokemon.
  #-----------------------------------------------------------------------------
  # Suggested Rules:
  #   :noexp      => true,
  #   :nodynamax  => true,
  #   :notera     => true,
  #   :autobattle => true,
  #   :setcapture => :Demo,
  #   :player     => ["Name", Integer]   (Set the name of the teacher of the tutorial, and outfit number for this back sprite)
  #   :party      => [:SPECIES, Integer] (Set the Species & level of the Pokemon the teacher of the tutorial will use (or a Pokemon object))
  #-----------------------------------------------------------------------------
  DEMO_CAPTURE_TUTORIAL = {
    #---------------------------------------------------------------------------
    # General speech events.
    #---------------------------------------------------------------------------
    "turnCommand"       => "Hey! A wild Pokémon!\nPay attention, now. I'll show you how to capture one of your own!",
    "damageMove"        => ["Weakening a Pokémon through battle makes them much easier to catch!",
                            "Be careful though - you don't want to knock them out completely!\nYou'll lose your chance if you do!",
                            "Let's try dealing some damage.\nGet 'em, {1}!"],
    "inflictStatus_foe" => ["It's always a good idea to inflict status conditions like Sleep or Paralysis!",
                            "This will really help improve your odds at capturing the Pokémon!"],
    #---------------------------------------------------------------------------
    # Continuous - Applies Endure effect to wild Pokemon whenever targeted by
    #              a damage-dealing move. Ensures it is not KO'd early.
    #---------------------------------------------------------------------------
    "damageMove_repeat" => {
      :battler => :Opposing,
      :effects => [[PBEffects::Endure, true]]
    },
    #---------------------------------------------------------------------------
    # Continuous - Checks if the wild Pokemon's HP is low. If so, initiates the
    #              capture sequence.
    #---------------------------------------------------------------------------
    "turnEnd_repeat" => {
      :delay   => ["halfHP_foe", "lowHP_foe"],
      :useitem => :POKEBALL
    },
    #---------------------------------------------------------------------------
    # Capture speech events.
    #---------------------------------------------------------------------------
    "beforeCapture" => "The Pokémon is weak!\nNow's the time to throw a Poké Ball!",
    "afterCapture"  => "Alright, that's how it's done!",
    #---------------------------------------------------------------------------
    # Capture failed - The wild Pokemon flees if it wasn't captured.
    #---------------------------------------------------------------------------
    "failedCapture" => {
      :speech    => "Drat! I thought I had it...",
      :playSE    => "Battle flee",
      :battler   => :Opposing,
      :text      => "{1} fled!",
      :endbattle => 3
    }
  }
  

################################################################################
# Demo scenario vs. AI Sada, as encountered in Pokemon Scarlet.
################################################################################

  #-----------------------------------------------------------------------------
  # Phase 1 - Speech events.
  #-----------------------------------------------------------------------------
  DEMO_VS_SADA_PHASE_1 = {
    "turnCommand"        => "I don't know who you think you are, but I'm not about to let anyone get in the way of my goals.",
    "damageTaken"        => "This is the power the ancient past holds.\nSplendid, isn't it?",
    "superEffective"     => "Now, this is interesting... Child, do you actually understand ancient Pokémon's weaknesses?",
    "superEffective_foe" => "Do you imagine you can best the wealth of data at my disposal with your human brain?",
    "criticalHit"        => "What?! Some sort of error has occurred here...\nRecalculating for critical damage...",
    "criticalHit_foe"    => "Just as calculated: a critical hit to your Pokémon.\nIt's time you simply gave up, child.",
    "beforeLast_foe"     => "Everything is proceeding within my expectations. I'm afraid the probability of you winning is zero."
  }
  
  #-----------------------------------------------------------------------------
  # Phase 2 - Scripted Koraidon battle.
  #-----------------------------------------------------------------------------
  # Suggested Rules:
  #   :noexp    => true,
  #   :nomoney  => true,
  #   :notera   => true,
  #   :party    => [:KORAIDON, 68]
  #-----------------------------------------------------------------------------
  DEMO_VS_SADA_PHASE_2 = {
    #---------------------------------------------------------------------------
    # Continuous - Applies Endure effect to player's Pokemon when the opponent
    #              uses a damaging move. Ensures the player's Pokemon is not KO'd
    #              even if they fail to select Endure when necessary.
    #---------------------------------------------------------------------------
    "damageMove_foe_repeat" => {
      :battler => :Opposing,
      :effects => [[PBEffects::Endure, true]]
    },
    #---------------------------------------------------------------------------
    # Continuous - Forces opponent to Taunt every turn after Turn 6. Ensures
    #              the player must eventually defeat the opponent.
    #---------------------------------------------------------------------------
    "turnAttack_repeat" => {
      :delay   => "turnAttack_6",
      :battler => :Opposing,
      :usemove => :TAUNT
    },
    #---------------------------------------------------------------------------
    # Turn 1 - Battle intro; ensures opponent has correct moves. Opponent is
    #          forced to Taunt this turn. Speech event.
    #---------------------------------------------------------------------------
    "turnCommand" => {
      :moves       => [:ENDURE, :FLAMETHROWER, :COLLISIONCOURSE, :TERABLAST],
      :battler     => :Opposing,
      :moves_1     => [:TAUNT, :BULKUP, :FLAMETHROWER, :GIGAIMPACT],
      :blankspeech => [:GROWL, "Grah! Grrrrrraaagh!"]
    }, 
    "turnAttack_1" => {
      :battler => :Opposing,
      :usemove => :TAUNT
    },
    "turnEnd_1" => {
      :blankspeech => "NEMONA: It changed into its battle form! Let's go, Koraidon - you got this!"
    },
    #---------------------------------------------------------------------------
    # Turn 2 - Opponent is forced to Flamethrower. Player's side silently given
    #          Safeguard this turn to ensure burn cannot occur. Opponent speech.
    #---------------------------------------------------------------------------
    "turnAttack_2" => {
      :team      => [[PBEffects::Safeguard, 2]],
      :battler   => :Opposing,
      :speech    => "You will fall here, within this garden paradise - and achieve nothing in the end.",
      :usemove   => :FLAMETHROWER
    },
    "turnEnd_2" => {
      :team => [[PBEffects::Safeguard, 0]]
    },
    #---------------------------------------------------------------------------
    # Turn 3 - Opponent is forced to Bulk Up. Ensures Taunt effect is ended on
    #          Player's Pokemon to setup Endure next turn. Speech events.
    #---------------------------------------------------------------------------
    "turnAttack_3" => {
      :battler => :Opposing,
      :speech  => "You will not be allowed to destroy my paradise. Obstacles to my goals WILL be eliminated.",
      :usemove => :BULKUP
    },
    "turnEnd_3" => {
      :effects     => [[PBEffects::Taunt, 0, "{1} shook off the taunt!"]],
      :blankspeech => "PENNY: Th-this looks like it could be bad! Uh...hang in there, {2}!"
    },
    #---------------------------------------------------------------------------
    # Turn 4 - Opponent is forced to Giga Impact. Opponent silently given No Guard
    #          ability this turn to ensure move lands. Player's Pokemon's Attack
    #          increased by 2 stages. Speech events.
    #---------------------------------------------------------------------------
    "turnAttack_4" => {
      :battler => :Opposing,
      :speech  => "The data says I am the superior. Fall, and become a foundation upon which my dream may be built.",
      :ability => :NOGUARD,
      :usemove => :GIGAIMPACT
    },
    "turnEnd_4" => {
      :blankspeech => "ARVEN: You took that hit like a champ! You can do this! I know you can!",
      :stats       => [:ATTACK, 2],
      :battler     => :Opposing,
      :ability     => :Reset,
    },
    #---------------------------------------------------------------------------
    # Turn 5 - Toggles the availability of Terastallization, assuming its
    #          functionality has been turned off for this battle. Raises Player's
    #          Pokemon's stats by 1 stage if the opponent's HP is low. Speech event.
    #---------------------------------------------------------------------------
    "turnEnd_5" => {
      :blankspeech => ["NEMONA: Oh man, can we really not pull off a win here? This doesn't look good...",
                       "PENNY: H-hey {2}! Your Tera Orb is glowing!",
                       "ARVEN: {2}! Koraidon! Terastallize and finish this off!"],
      :teracharge  => true,
      :lockspecial => :Terastallize,
      :delay       => ["lowHP_foe", "halfHP_foe"],
      :stats       => [:ATTACK, 1, :DEFENSE, 1, :SPECIAL_ATTACK, 1, :SPECIAL_DEFENSE, 1, :SPEED, 1]
    },
    #---------------------------------------------------------------------------
    # Turn 6 - Raises Player's Pokemon's stats by 1 stage in case it wasn't
    #          triggered on the previous turn. Speech event.
    #---------------------------------------------------------------------------
    "turnEnd_6" => {
      :blankspeech => "PENNY: Show'em you won't be pushed around! Time to Terastallize and get in some supereffective hits!",
      :stats       => [:ATTACK, 1, :DEFENSE, 1, :SPECIAL_ATTACK, 1, :SPECIAL_DEFENSE, 1, :SPEED, 1]
    }
  }
  

################################################################################
# Custom demo scenario vs. wild Pokemon.
################################################################################

  #-----------------------------------------------------------------------------
  # Demo scenario vs. wild Rotom that shifts forms.
  #-----------------------------------------------------------------------------
  # Suggested Rules:
  #   :nocapture => true
  #-----------------------------------------------------------------------------
  DEMO_WILD_ROTOM = {
    #---------------------------------------------------------------------------
    # Turn 1 - Battle intro.
    #---------------------------------------------------------------------------
    "turnCommand" => {
      :text      => [:Opposing, "{1} emited a powerful magnetic pulse!"],
      :anim      => [:CHARGE, :Opposing],
      :playsound => "Anim/Paralyze3",
      :text_1    => "Your Poké Balls short-circuited!\nThey cannot be used this battle!"
    },
    #---------------------------------------------------------------------------
    # Continuous - After taking a supereffective hit, the wild Rotom changes to
    #              a random form and changes its item/ability. HP and status
    #              are also healed.
    #---------------------------------------------------------------------------
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
    #---------------------------------------------------------------------------
    # Continuous - After the wild Rotom's HP gets low, applies the Charge,
    #              Magnet Rise, and Electric Terrain effects whenever the wild
    #              Rotom takes damage from an attack.
    #---------------------------------------------------------------------------
    "damageTaken_foe_repeat" => {
      :delay   => ["halfHP_foe", "lowHP_foe"],
      :effects => [
        [PBEffects::Charge,     5, "{1} began charging power!"],
        [PBEffects::MagnetRise, 5, "{1} levitated with electromagnetism!"],
      ],
      :terrain => :Electric
    },
    #---------------------------------------------------------------------------
    # Player's Pokemon becomes paralyzed after dealing supereffective damage. 
    #---------------------------------------------------------------------------
    "superEffective" => {
      :text    => [:Opposing, "{1} emited an electrical pulse out of desperation!"],
      :status  => [:PARALYSIS, true]
    }
  }
  
  
################################################################################
# Custom demo scenario vs. trainer.
################################################################################

  #-----------------------------------------------------------------------------
  # Demo scenario vs. Rocket Grunt in a collapsing cave.
  #-----------------------------------------------------------------------------
  # Suggested Rules
  #   :canlose => true,
  #-----------------------------------------------------------------------------
  DEMO_COLLAPSING_CAVE = {
    #---------------------------------------------------------------------------
    # Turn 1 - Battle intro.
    #---------------------------------------------------------------------------
    "turnCommand" => {
      :playSE  => "Mining collapse",
      :text    => "The cave ceiling begins to crumble down all around you!",
      :speech  => [:Opposing, "I am not letting you escape!", 
                   "I don't care if this whole cave collapses down on the both of us...haha!"],
      :text_1  => "Defeat your opponent before time runs out!"
    },
    #---------------------------------------------------------------------------
    # Turn 2 - Player's Pokemon takes damage and becomes confused.
    #---------------------------------------------------------------------------
    "turnEnd_2" => {
      :text    => "{1} was struck on the head by a falling rock!",
      :anim    => [:ROCKSMASH, :Self],
      :hp      => -4,
      :status  => :CONFUSION
    },
    #---------------------------------------------------------------------------
    # Turn 3 - Text event.
    #---------------------------------------------------------------------------
    "turnEnd_3" => {
      :text => ["You're running out of time!", 
                "You need to escape immediately!"]
    },
    #---------------------------------------------------------------------------
    # Turn 4 - Battle prematurely ends in a loss.
    #---------------------------------------------------------------------------
    "turnEnd_4" => {
      :text      => ["You failed to defeat your opponent in time!", 
                     "You were forced to flee the battle!"],
      :playsound => "Battle flee",
      :endbattle => 2
    },
    #---------------------------------------------------------------------------
    # Continuous - Text event at the end of each turn.
    #---------------------------------------------------------------------------
    "turnEnd_repeat" => {
      :playsound => "Mining collapse",
      :text      => "The cave continues to collapse all around you!"
    },
    #---------------------------------------------------------------------------
    # Opponent's final Pokemon is healed and increases its defenses when HP is low.
    #---------------------------------------------------------------------------
    "lowHPLast_foe" => {
      :speech  => "My {1} will never give up!",
      :anim    => [:BULKUP, :Self],
      :playcry => true,
      :hp      => [2, "{1} is standing its ground!"],
      :stats   => [:DEFENSE, 2, :SPECIAL_DEFENSE, 2]
    },
    #---------------------------------------------------------------------------
    # Speech event upon losing the battle.
    #---------------------------------------------------------------------------
    "loss" => "Haha...you'll never make it out alive!"
  }
  
  
################################################################################
# Demo speech displays for use with certain battle mechanics.
################################################################################
  
  #-----------------------------------------------------------------------------
  # Demo trainer speech when triggering Mega Evolution.
  #-----------------------------------------------------------------------------
  DEMO_MEGA_EVOLUTION = {
    "mega_foe"           => ["C'mon, {1}!", "Let's blow them away with Mega Evolution!"],
    "megaGYARADOS_foe"   => "Behold the serpent of the darkest depths!",
    "megaGENGAR_foe"     => "Good luck escaping THIS nightmare!",
    "megaKANGASKHAN_foe" => "Parent and child fight as one!",
    "megaAERODACTYL_foe" => "Prepare yourself for my prehistoric beast!",
    "megaFIRE_foe"       => "Maximum firepower!",
    "megaELECTRIC_foe"   => "Prepare yourself for a mighty force of nature!",
    "megaBUG_foe"        => "Emerge from you caccoon as a mighty warrior!"
  }
  
  #-----------------------------------------------------------------------------
  # Demo trainer speech when triggering Primal Reversion.
  #-----------------------------------------------------------------------------
  DEMO_PRIMAL_REVERSION = {
    "primal_foe"        => "Prepare yourself for an ancient force beyond imagination!",
    "primalKYOGRE_foe"  => "{1}! Let the seas burst forth by your mighty presence!",
    "primalGROUDON_foe" => "{1}! Let the ground crack by your might presence!",
    "primalWATER_foe"   => "{1}! Flood the world with your majesty!",
    "primalGROUND_foe"  => "{1}! Shatter the world with your majesty!"
  }

  #-----------------------------------------------------------------------------
  # Demo trainer speech when triggering ZUD Mechanics. (ZUD Plugin)
  #-----------------------------------------------------------------------------
  DEMO_ZUD_MECHANICS = {
    # Z-Moves
    "zmove_foe"         => ["Alright, {1}!", "Time to unleash our Z-Power!"],
    "zmoveRAICHU_foe"   => "Surf's up, {1}!",
    "zmoveSNORLAX_foe"  => "Let's flatten 'em, {1}!",
    "zmoveNECROZMA_foe" => "{1}! Let your light burn them to ashes!",
    "zmoveELECTRIC_foe" => "Smite them with a mighty bolt!",
    "zmoveFIGHTING_foe" => "Time for an all-out assault!",
    # Ultra Burst
    "ultra_foe"         => "Hah! Prepare to witness my {1}'s ultimate form!",
    "ultraNECROZMA_foe" => "{1}! Let your light burst forth!",
    "ultraPSYCHIC_foe"  => "{1}! Unleash your cosmic energies!",
    # Dynamax
    "dynamax_foe"       => ["No holding back!", "It's time to Dynamax!"],
    "dynamaxWATER_foe"  => "Lets drown them out with a mega-rain storm!",
    "dynamaxFIRE_foe"   => "Lets burn 'em up with the heat of the sun!",
    "gmax_foe"          => "Witness my {1}'s Gigantamax form!",
    "gmaxPIKACHU_foe"   => "Behold my precious chonky-chu!",
    "gmaxMEOWTH_foe"    => "Tower over your competition, {1}!"
  }

  #-----------------------------------------------------------------------------
  # Demo trainer speech when entering Strong/Agile styles. (PLA Battle Styles)
  #-----------------------------------------------------------------------------
  DEMO_BATTLE_STYLES = {
    # Strong Style
    "strongStyle_foe" => "Let's strike 'em down with all your strength, {1}!",
    "strongStyle_foe_repeat" => {
      :delay  => "styleEnd_foe",
      :speech => ["Let's keep up the pressure!", 
                  "Hit 'em with your Strong Style, {1}!"]
    },
    # Agile Style
    "agileStyle_foe" => "Let's strike 'em down before they know what hit 'em, {1}!",
    "agileStyle_foe_repeat" => {
      :delay  => "styleEnd_foe",
      :speech => ["Let's keep them on their toes!", 
                  "Hit 'em with your Agile Style, {1}!"]
    }
  }
  
  #-----------------------------------------------------------------------------
  # Demo trainer speech when triggering Terastallization mechanics. (Terastal Phenomenon)
  #-----------------------------------------------------------------------------
  DEMO_TERASTALLIZE = {
    # Terastallization
    "tera_foe"           => "Let your true self shine forth, {1}!",
    "teraDARK_foe"       => "{1}, let's show them how devious you can really be!",
    "teraGHOST_foe"      => "{1}! It's time for your to ascend to the spirit world!",
    "teraFIRE_foe"       => "Let your fiery rage come through, {1}!",
    # Tera-Boosted Attack
    "teraType_foe"       => "Now let me show you my {1}'s true power!",
    "teraTypeGRASS_foe"  => "Give them the full force of nature, {1}!",
    "teraTypePOISON_foe" => "{1}'s poison is too potent for you to handle!",
    "teraTypeSTEEL_foe"  => "Taste the cold steel of your defeat!"
  }
  
  #-----------------------------------------------------------------------------
  # Demo trainer speech when triggering the Focus Meter. (Focus Meter System)
  #-----------------------------------------------------------------------------
  DEMO_FOCUS_METER = {
    "focus_foe" => "Focus, {1}!\nWe got this!", 
    "focus_foe_repeat" => {
      :delay  => "focusEnd_foe",
      :speech => "Keep your eye on the prize, {1}!"
    },
    "focusBoss" => "It's time to let loose, {1}!",
    "focusBoss_repeat" => {
      :delay  => "focusEnd_foe",
      :speech => "No mercy! Show them your rage, {1}!"
    }
  }
end