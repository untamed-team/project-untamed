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
		@selectableApps = getSelectableApps
		@maxPages = getMaxPages
		@maxAppsOnScreen = PhoneScene::MAX_APPS_PER_ROW * PhoneScene::APP_ROWS_ON_SCREEN
		@maxAppsPerRow = PhoneScene::MAX_APPS_PER_ROW
		@spaceBetweenApps = PhoneScene::APP_SPACING
		
		#this is the app we start with drawing in the first slot
		#if on page 2, we exclude the first 6 apps (if that's how many are drawn on one page) and begin with drawing the 7th element in the available apps array
		startingAppPos = @currentPage * @maxAppsOnScreen
		
		@appStartingX = 68
		
		#find out how many apps are on this page, because it might not be the max amount
		@appsOnThisPage = getAppsOnThisPage
		@appsLeftToDraw = @appsOnThisPage.length
		
		#begin drawing apps
		@appsOnThisPage.length.times do
		break if @appsLeftToDraw <= 0
			#draw apps on top row
			for j in 0...@maxAppsPerRow
				break if @appsLeftToDraw <= 0
				@sprites["appBG"] = IconSprite.new(0, 0, @viewport)
				@sprites["appBG"].setBitmap("Graphics/Pictures/BlukBerry Phone/appBg")
				@sprites["appBG"].x = @appStartingX + (@spaceBetweenApps * j) + (@sprites["appBG"].width * j)
				@sprites["appBG"].y = 102
				@sprites["appBG"].z = 99998
				@appsLeftToDraw -= 1
			end #for j in 0...@maxAppsPerRow.length
			
			#draw apps on bottom row
			for j in 0...@maxAppsPerRow
				break if @appsLeftToDraw <= 0
				@sprites["appBG"] = IconSprite.new(0, 0, @viewport)
				@sprites["appBG"].setBitmap("Graphics/Pictures/BlukBerry Phone/appBg")
				@sprites["appBG"].x = @appStartingX + (@spaceBetweenApps * j) + (@sprites["appBG"].width * j)
				@sprites["appBG"].y = 226
				@sprites["appBG"].z = 99998
				@appsLeftToDraw -= 1
			end #for j in 0...@maxAppsPerRow.length
		end #@appsOnThisPage.length.times do
		
	end #def drawApps
end #class PhoneScene