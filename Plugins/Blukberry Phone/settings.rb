class PhoneScene
	APP_SPACING = 84
	MAX_APPS_PER_ROW = 3
	APP_ROWS_ON_SCREEN = 2
	APPS = [
		Pokedex      = {:functionName => "phonePokedex", :name => "Pokédex", :icon => "appPokedex", :condition => true},
		Map          = {:functionName => "phoneMap", :name => "Map", :icon => "appMap", :condition => true},
		Trainer      = {:functionName => "phoneTrainer", :name => "Trainer", :icon => "appTrainer", :condition => true},
		Options      = {:functionName => "phoneOptions", :name => "Options", :icon => "appOptions", :condition => true},
		Objectives   = {:functionName => "phoneObjectives", :name => "Objectives", :icon => "appObjectives", :condition => true},
		Wiki         = {:functionName => "phoneWiki", :name => "Wiki", :icon => "appWiki", :condition => true},
		TutorNet     = {:functionName => "phoneTutorNet", :name => "Tutor.net", :icon => "appTrainer", :condition => false},
		Tutorials    = {:functionName => "phoneTutorials", :name => "Tutorials", :icon => "appTrainer", :condition => false},
		Achievements = {:functionName => "phoneAchievements", :name => "Achievements", :icon => "appTrainer", :condition => true},
	]
end #class PhoneScene