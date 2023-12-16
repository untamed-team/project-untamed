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
	
	def getSelectableApps
		selectable = PhoneScene::APPS.clone #this will be changed later
		return selectable
	end #def getSelectableApps
	
	def getMaxPages
		numOfPages = PhoneScene::APPS.length / (PhoneScene::MAX_APPS_PER_ROW * PhoneScene::APP_ROWS_ON_SCREEN)
		#if there's a remainder, add another page
		numOfPages += 1 if numOfPages > 0
		return numOfPages
	end #def getMaxPages
	
	def getAppsOnThisPage
		#get the apps that will be on the currentPage
		#.drop is a non-destructive way to drop elements, so we'll assign a new variable
		appsOnPage = @selectableApps.drop(@currentPage * @maxAppsOnScreen)
		#if more than @maxAppsOnScreen, drop everything after @maxAppsOnScreen
		appsOnPage[@maxAppsOnScreen ..] = []
		#take out the nil elements destructively so we don't need to make another array
		appsOnPage.compact!
		
		return appsOnPage
	end #def getAppsOnThisPage
	
	def drawApps
	@currentPage = 1
		@selectableApps = getSelectableApps
		@maxPages = getMaxPages
		@maxAppsOnScreen = PhoneScene::MAX_APPS_PER_ROW * PhoneScene::APP_ROWS_ON_SCREEN
		
		#this is the app we start with drawing in the first slot
		#if on page 2, we exclude the first 6 apps (if that's how many are drawn on one page) and begin with drawing the 7th element in the available apps array
		startingAppPos = @currentPage * @maxAppsOnScreen
		
		appX = 68 #starting X
		@appsOnThisPage = getAppsOnThisPage
		
		print "page is #{@currentPage} and apps displayed are #{@appsOnThisPage}"
		
		#find out how many apps are on this page, because it might not be the max amount
		
		#draw apps on top row
		PhoneScene::MAX_APPS_PER_ROW.times do
			break if appsToDrawOnPage <= 0
			for j in 0...PhoneScene::MAX_APPS_PER_ROW.length
				break if appsToDrawOnPage <= 0
				@sprites["appBG"] = IconSprite.new(0, 0, @viewport)
				@sprites["appBG"].setBitmap("Graphics/Pictures/BlukBerry Phone/appBg")
				@sprites["appBG"].x = appX
				@sprites["appBG"].y = 102
				@sprites["appBG"].z = 99998
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