class PhoneScene
	APP_SPACING = 84
	MAX_APPS_PER_ROW = 3
	APP_ROWS_ON_SCREEN = 2
	APPS = [
		Pokedex      = {:functionName => "phonePokedex", :name => "Pokédex", :icon => "appPokedex", :condition => proc {$player.has_pokedex} },
		Map          = {:functionName => "phoneMap", :name => "Map", :icon => "appMap", :condition => proc {$game_switches[76]} }, #after starter is picked
		Trainer      = {:functionName => "phoneTrainer", :name => "Trainer", :icon => "appTrainer", :condition => proc {true} },
		Options      = {:functionName => "phoneOptions", :name => "Options", :icon => "appOptions", :condition => proc {false} },
		Objectives   = {:functionName => "phoneObjectives", :name => "Objectives", :icon => "appObjectives", :condition => proc {true} },
		Wiki         = {:functionName => "phoneWiki", :name => "Wiki", :icon => "appWiki", :condition => proc {true} },
		TutorNet     = {:functionName => "phoneTutorNet", :name => "Tutor.net", :icon => "appTrainer", :condition => proc {$game_switches[104]} }, #'tutor.net unlocked' switch is on
		Achievements = {:functionName => "phoneAchievements", :name => "Achievements", :icon => "appTrainer", :condition => proc {false} },
		AdventureGuide = {:functionName => "phoneAdventureGuide", :name => "Adventure Guide", :icon => "appAdventureGuide", :condition => proc {true} },
	]
end #class PhoneScene