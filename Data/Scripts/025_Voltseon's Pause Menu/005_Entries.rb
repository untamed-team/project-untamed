#-------------------------------------------------------------------------------
# Entry for Pokemon Party Screen
#-------------------------------------------------------------------------------
class MenuEntryPokemon < MenuEntry
  def initialize
    @icon = "menuPokemon"
    @name = "Pokémon"
  end

  def selected(menu)
    hiddenmove = nil
    pbFadeOutIn(99999) {
      sscene = PokemonParty_Scene.new
      sscreen = PokemonPartyScreen.new(sscene,$player.party)
      hiddenmove = sscreen.pbPokemonScreen
    }
    if hiddenmove
      menu.pbHideMenu
      $game_temp.in_menu = false
      pbUseHiddenMove(hiddenmove[0],hiddenmove[1])
      return true
    end
  end

  def selectable?
    #return ($player.party_count > 0)
    #added by Gardenette for camping menu
    return ($player.party_count > 0 && !$game_switches[83])
  end
end
#-------------------------------------------------------------------------------
# Entry for Pokedex Screen
#-------------------------------------------------------------------------------
class MenuEntryPokedex < MenuEntry
  def initialize
    @icon = "menuPokedex"
    @name = "Pokédex"
  end

  def selected(menu)
    if $Trainer.pokedex.accessible_dexes.length == 1
      $PokemonGlobal.pokedexDex = $Trainer.pokedex.accessible_dexes[0]
      pbFadeOutIn(99999) {
        scene = PokemonPokedex_Scene.new
        screen = PokemonPokedexScreen.new(scene)
        screen.pbStartScreen
      }
    else
      pbFadeOutIn(99999) {
        scene = PokemonPokedexMenu_Scene.new
        screen = PokemonPokedexMenuScreen.new(scene)
        screen.pbStartScreen
      }
    end
  end

  def selectable?
    #return ($Trainer.has_pokedex && $Trainer.pokedex.accessible_dexes.length > 0)
    #added by Gardenette for camping menu
    return ($Trainer.has_pokedex && $Trainer.pokedex.accessible_dexes.length > 0 && !$game_switches[83])
  end
end
#-------------------------------------------------------------------------------
# Entry for Bag Screen
#-------------------------------------------------------------------------------
class MenuEntryBag < MenuEntry
  def initialize
    @icon = "menuBag"
    @name = "Bag"
  end

  def selected(menu)
    item = nil
    pbFadeOutIn(99999) {
      scene = PokemonBag_Scene.new
      screen = PokemonBagScreen.new(scene,$bag)
      item = screen.pbStartScreen
    }
    if item
      menu.pbHideMenu
      $game_temp.in_menu = false
      pbUseKeyItemInField(item)
      return true
    end
  end

  def selectable?
    #return !pbInBugContest?
    #added by Gardenette for camping menu
    return !pbInBugContest? && !$game_switches[83]
  end
end
#-------------------------------------------------------------------------------
# Entry for Pokegear Screen
#-------------------------------------------------------------------------------
class MenuEntryPokegear < MenuEntry
  def initialize
    @icon = "menuPokegear"
    @name = "PokéGear"
  end

  def selected(menu)
    pbFadeOutIn(99999) {
      scene = PokemonPokegear_Scene.new
      screen = PokemonPokegearScreen.new(scene)
      screen.pbStartScreen
    }
  end

  def selectable?; return $Trainer.has_pokegear; end
end
#-------------------------------------------------------------------------------
# Entry for Trainer Card Screen
#-------------------------------------------------------------------------------
class MenuEntryTrainer < MenuEntry
  def initialize
    @icon = "menuTrainer"
    @name = $Trainer.name
  end

  def selected(menu)
    pbFadeOutIn(99999) {
      scene = PokemonTrainerCard_Scene.new
      screen = PokemonTrainerCardScreen.new(scene)
      screen.pbStartScreen
    }
  end

  def selectable?
    return true
    #added by Gardenette for camping menu
    #return !$game_switches[83]
  end
end
#-------------------------------------------------------------------------------
# Entry for Save Screen
#-------------------------------------------------------------------------------
class MenuEntrySave < MenuEntry
  def initialize
    @icon = "menuSave"
    @name = "Save"
  end

  def selected(menu)
    menu.pbHideMenu
    scene = PokemonSave_Scene.new
    screen = PokemonSaveScreen.new(scene)
    screen.pbSaveScreen
    menu.pbShowMenu
  end

  def selectable?
    #return (!pbInBugContest? && $game_system && !$game_system.save_disabled && !pbInSafari?)
    #added by Gardenette for camping menu
    return (!pbInBugContest? && $game_system && !$game_system.save_disabled && !pbInSafari? && !$game_switches[83])
  end
end
#-------------------------------------------------------------------------------
# Entry for Town Map Screen
#-------------------------------------------------------------------------------
class MenuEntryMap < MenuEntry # Play Pokémon Splice
  def initialize
    @icon = "menuMap"
    @name = "Map"
  end

  def selected(menu)
    pbShowMap(-1,false)
  end

  def selectable?
    #return $bag.has?(:TOWNMAP)
    #added by Gardenette for camping menu
    return $bag.has?(:TOWNMAP) && !$game_switches[83]
  end
end
#-------------------------------------------------------------------------------
# Entry for Options Screen
#-------------------------------------------------------------------------------
class MenuEntryOptions < MenuEntry
  def initialize
    @icon = "menuOptions"
    @name = "Options"
  end

  def selected(menu)
    pbFadeOutIn(99999) {
      scene = PokemonOption_Scene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
      pbUpdateSceneMap
    }
    return false #$game_temp.menu_theme_changed
  end

  def selectable?; return true; end
end
#-------------------------------------------------------------------------------
# Entry for Debug Menu Screen
#-------------------------------------------------------------------------------
class MenuEntryDebug < MenuEntry
  def initialize
    @icon = "menuDebug"
    @name = "Debug"
  end

  def selected(menu)
    pbFadeOutIn(99999) { pbDebugMenu }
    return $game_temp.menu_theme_changed
  end

  def selectable?; return $DEBUG; end
end
#-------------------------------------------------------------------------------
# Entry for quitting Safari Zone
#-------------------------------------------------------------------------------
class MenuEntryExitSafari < MenuEntry
  def initialize
    @icon = "menuBack"
    @name = "Quit Safari"
  end

  def selected(menu)
    menu.pbHideMenu
    if pbConfirmMessage(_INTL("Would you like to leave the Safari Game right now?"))
      $game_temp.in_menu = false
      pbSafariState.decision = 1
      pbSafariState.pbGoToStart
      return true
    end
    menu.pbShowMenu
  end

  def selectable?; return pbInSafari?; end
end
#-------------------------------------------------------------------------------
# Entry for quitting Bug Contest
#-------------------------------------------------------------------------------
class MenuEntryExitBugContest < MenuEntry
  def initialize
    @icon = "menuBack"
    @name = "Quit Contest"
  end

  def selected(menu)
    menu.pbHideMenu
    if pbConfirmMessage(_INTL("Would you like to end the Contest now?"))
      $game_temp.in_menu = false
      pbBugContestState.pbStartJudging
      return true
    end
    menu.pbShowMenu
  end

  def selectable?; return pbInBugContest?; end
end
#-------------------------------------------------------------------------------
# Entry for quitting the game
#-------------------------------------------------------------------------------
class MenuEntryQuit < MenuEntry
  def initialize
    @icon = "menuQuit"
    @name = "Quit"
  end

  def selected(menu)
    menu.pbHideMenu
    if pbConfirmMessage(_INTL("Are you sure you want to quit the game?"))
      scene = PokemonSave_Scene.new
      screen = PokemonSaveScreen.new(scene)
      screen.pbSaveScreen
      menu.pbEndScene
      #$scene = nil
      $scene = pbCallTitle
      exit!
    end
    menu.pbShowMenu
  end

  def selectable?
    #return (!pbInBugContest? && !pbInSafari?)
    #added by Gardenette for camping menu
    return (!pbInBugContest? && !pbInSafari? && !$game_switches[83])
  end
end

#-------------------------------------------------------------------------------
# Entry for Modern Quest System by ThatWelshOne
#-------------------------------------------------------------------------------
class MenuEntryQuests < MenuEntry
  def initialize
    @icon = "menuObjectives"
    @name = "Objectives"
  end

  def selected(menu); pbFadeOutIn(99999) { pbViewQuests }; end

  def selectable?
    #return defined?(hasAnyQuests?) && hasAnyQuests?
    #added by Gardenette for camping menu
    return defined?(hasAnyQuests?) && hasAnyQuests? && !$game_switches[83]
  end
end

#-------------------------------------------------------------------------------
# Entry for DexNav #by low
#-------------------------------------------------------------------------------
class MenuEntryDexNav < MenuEntry
  def initialize
    @icon = "menuDexNav"
    @name = "DexNav"
  end

  def selected(menu); pbFadeOutIn(99999) { NewDexNav.new }; end

  def selectable?
    #return $Trainer.has_dexnav
    #added by Gardenette for camping menu
    return $Trainer.has_dexnav && !$game_switches[83]
  end
end

#-------------------------------------------------------------------------------
# Entry for Wiki
#-------------------------------------------------------------------------------
class MenuEntryWiki < MenuEntry
  def initialize
    @icon = "menuWiki"
    @name = "Wiki"
  end

  def selected(menu); pbFadeOutIn(99999) { system("start https://pokemon-untamed.fandom.com/wiki/Pok%C3%A9mon_Untamed_Wiki") }; end

  def selectable?; return true; end
end

#-------------------------------------------------------------------------------
# Entry for Portable PC
#-------------------------------------------------------------------------------
class MenuEntryPC < MenuEntry
  def initialize
    @icon = "menuDexNav"
    @name = "PC"
  end

  def selected(menu)
		if $bag.has?(:PORTABLEBATTERY)
			# PC maps Blacklist
			if [999].include?($game_map.map_id)
				pbMessage("The poor signal blocks you from using this device.")
			else
				$bag.remove(:PORTABLEBATTERY)
				pbFadeOutIn(99999) { pbPokeCenterPC	}
			end
		else
			pbMessage("You have no batteries to power this device.")
		end
	end

  def selectable?
		#return $bag.has?(:PORTABLEPC)
    #added by Gardenette for camping menu
    return $bag.has?(:PORTABLEPC) && !$game_switches[83]
	end
end

#-------------------------------------------------------------------------------
# Entry for Camping
#-------------------------------------------------------------------------------
class MenuEntryCamp < MenuEntry
  def initialize
    @icon = "menuPokegear"
    @name = "Camp"
  end

  def selected(menu)
    menu.pbHideMenu
		camp = Camping.new
    camp.startCamping
	end

  def selectable?
    return $bag.has?(:CAMPINGGEAR) && !$game_switches[83]
	end
end

#-------------------------------------------------------------------------------
# Entry for Exiting Camp
#-------------------------------------------------------------------------------
class MenuEntryExitCamp < MenuEntry
  def initialize
    @icon = "menuBack"
    @name = "Pack up"
  end

  def selected(menu)
    menu.pbHideMenu
		camp = Camping.new
    camp.endCamping
	end

  def selectable?
    return $game_switches[83]
	end
end

#-------------------------------------------------------------------------------
# Entry for Achievements
#-------------------------------------------------------------------------------
class MenuEntryAchievements < MenuEntry
  def initialize
    @icon = "menuTrainer"
    @name = "Achievements"
  end

  def selected(menu)
    pbPlayDecisionSE
      scene = PokemonAchievements_Scene.new
      screen = PokemonAchievements.new(scene)
      pbFadeOutIn(99999) { 
      screen.pbStartScreen
    }
	end

  def selectable?
    return true
	end
end