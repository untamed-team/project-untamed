class PhoneScene
APP_SPACING = 84
MAX_APPS_PER_ROW = 3
APP_ROWS_ON_SCREEN = 2
APPS = [
	Pokedex = {:name => "Pokédex", :icon => "appPokedex"},
	Map = {:name => "Map", :icon => "appMap"},
	Trainer = {:name => "Trainer", :icon => "appTrainer"},
	Options = {:name => "Options", :icon => "appOptions"},
	Objectives = {:name => "Objectives", :icon => "appObjectives"},
	Wiki = {:name => "Wiki", :icon => "appWiki"},
	TutorNet = {:name => "Tutor.net", :icon => "appTrainer"},
	Tutorials = {:name => "Tutorials", :icon => "appTrainer"},
	Achievements = {:name => "Achievements", :icon => "appTrainer"},
]

	def drawApps
		numOfApps = PhoneScene::APPS.length
		@maxPages = PhoneScene::APPS.length / (PhoneScene::MAX_APPS_PER_ROW * PhoneScene::APP_ROWS_ON_SCREEN) + 1
		numOfApps - (@appPage * (PhoneScene::MAX_APPS_PER_ROW * PhoneScene::APP_ROWS_ON_SCREEN)).abs
		appX = 68 #starting X
		#draw apps on top row
		PhoneScene::MAX_APPS_PER_ROW.times do
			break if appsToDrawOnPage <= 0
			for j in 0...PhoneScene::MAX_APPS_PER_ROW.length
				break if appsToDrawOnPage <= 0
				
				
				appsToDrawOnPage -= 1
			end #PhoneScene::MAX_APPS_PER_ROW.times do
		end #PhoneScene::MAX_APPS_PER_ROW.times do
		
		
		
		
		
		
		appNum = 0
		rowNum = 1
		for j in 0...PhoneScene::APPS.length
			@sprites["appBG"] = IconSprite.new(0, 0, @viewport)
			@sprites["appBG"].setBitmap("Graphics/Pictures/BlukBerry Phone/appBg")
			@sprites["appBG"].x = appX
			@sprites["appBG"].y = 102
			@sprites["appBG"].z = 99998
			appNum += 1
			appX += @sprites["appBG"].width + PhoneScene::APP_SPACING
			if appNum >= PhoneScene::MAX_APPS_PER_ROW
				rowNum = 2 if rowNum == 1
				rowNum = 1 if rowNum == 2
			end
		end #for j in PhoneScene::APPS.length
	end #def drawApps
end #class PhoneScene