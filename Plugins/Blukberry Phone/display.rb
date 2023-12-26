class PhoneScene
	def getSelectableApps
		#selectable = PhoneScene::APPS.clone #this will be changed later
		selectable = []
		for i in 0...PhoneScene::APPS.length
			selectable.push(PhoneScene::APPS[i]) if PhoneScene::APPS[i][:condition]
		end
		return selectable
	end #def getSelectableApps
	
	def getMaxPages
		numOfPages = @selectableApps.length / (@maxAppsPerRow * @maxRowsOnScreen)
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
	
	def updateSideArrows
		#put left and right arrows on the screen if there's another page to go to
		@sprites["leftarrow"].visible = true if @currentPage > 0
		@sprites["leftarrow"].visible = false if @currentPage <= 0
		
		@sprites["rightarrow"].visible = true if @currentPage < @maxPages-1
		@sprites["rightarrow"].visible = false if @currentPage >= @maxPages-1
	end #def updateSideArrows
	
	def updateCursorPos
		case @cursorPos
		when 1
			@sprites["cursor"].x = 66
			@sprites["cursor"].y = 100
		when 2
			@sprites["cursor"].x = 214
			@sprites["cursor"].y = 100
		when 3
			@sprites["cursor"].x = 362
			@sprites["cursor"].y = 100
		when 4
			@sprites["cursor"].x = 66
			@sprites["cursor"].y = 224
		when 5
			@sprites["cursor"].x = 214
			@sprites["cursor"].y = 224
		when 6
			@sprites["cursor"].x = 362
			@sprites["cursor"].y = 224
		end #case @cursorPos
	end #def updateCursorPos
	
	def drawApps
		#clear apps from previous page
		pbDisposeSpriteHash(@appSprites)
	
		@selectableApps = getSelectableApps
		@maxAppsPerRow = PhoneScene::MAX_APPS_PER_ROW
		@maxRowsOnScreen = PhoneScene::APP_ROWS_ON_SCREEN
		@maxAppsOnScreen = @maxAppsPerRow * @maxRowsOnScreen
		@spaceBetweenApps = PhoneScene::APP_SPACING
		@maxPages = getMaxPages
		
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
				@appSprites["appBG#{j}"] = IconSprite.new(0, 0, @viewport)
				@appSprites["appBG#{j}"].setBitmap("Graphics/Pictures/BlukBerry Phone/appBg")
				@appSprites["appBG#{j}"].x = @appStartingX + (@spaceBetweenApps * j) + (@appSprites["appBG#{j}"].width * j)
				@appSprites["appBG#{j}"].y = 102
				@appSprites["appBG#{j}"].z = 99998
				
				appIcon = @appsOnThisPage[j][:icon]
				@appSprites["app#{j}"] = IconSprite.new(0, 0, @viewport)
				@appSprites["app#{j}"].setBitmap("Graphics/Pictures/BlukBerry Phone/#{appIcon}")
				#get the difference between the width and height of the appBG and the appIcon so we can center the icon
				xDifference = (@appSprites["appBG#{j}"].width - @appSprites["app#{j}"].width).abs
				@appSprites["app#{j}"].x = @appSprites["appBG#{j}"].x + (xDifference/2)
				yDifference = (@appSprites["appBG#{j}"].height - @appSprites["app#{j}"].height).abs
				@appSprites["app#{j}"].y = @appSprites["appBG#{j}"].y + (yDifference/2)
				@appSprites["app#{j}"].z = 99998
				
				@appsLeftToDraw -= 1
			end #for j in 0...@maxAppsPerRow.length
			
			#draw apps on bottom row
			for j in 0...@maxAppsPerRow
				break if @appsLeftToDraw <= 0
				@appSprites["appBG#{j+@maxAppsPerRow}"] = IconSprite.new(0, 0, @viewport)
				@appSprites["appBG#{j+@maxAppsPerRow}"].setBitmap("Graphics/Pictures/BlukBerry Phone/appBg")
				@appSprites["appBG#{j+@maxAppsPerRow}"].x = @appStartingX + (@spaceBetweenApps * j) + (@appSprites["appBG#{j+@maxAppsPerRow}"].width * j)
				@appSprites["appBG#{j+@maxAppsPerRow}"].y = 226
				@appSprites["appBG#{j+@maxAppsPerRow}"].z = 99998
				
				appIcon = @appsOnThisPage[j+@maxAppsPerRow][:icon]
				@appSprites["app#{j+@maxAppsPerRow}"] = IconSprite.new(0, 0, @viewport)
				@appSprites["app#{j+@maxAppsPerRow}"].setBitmap("Graphics/Pictures/BlukBerry Phone/#{appIcon}")
				#get the difference between the width and height of the appBG and the appIcon so we can center the icon
				xDifference = (@appSprites["appBG#{j+@maxAppsPerRow}"].width - @appSprites["app#{j+@maxAppsPerRow}"].width).abs
				@appSprites["app#{j+@maxAppsPerRow}"].x = @appSprites["appBG#{j+@maxAppsPerRow}"].x + (xDifference/2)
				yDifference = (@appSprites["appBG#{j+@maxAppsPerRow}"].height - @appSprites["app#{j+@maxAppsPerRow}"].height).abs
				@appSprites["app#{j+@maxAppsPerRow}"].y = @appSprites["appBG#{j+@maxAppsPerRow}"].y + (yDifference/2)
				@appSprites["app#{j+@maxAppsPerRow}"].z = 99998
				
				@appsLeftToDraw -= 1
			end #for j in 0...@maxAppsPerRow.length
		end #@appsOnThisPage.length.times do
		
		def correctCursorPos
			#this method runs when going to another page to the right and coming from the bottom row
			@cursorPos = 1 if @appsOnThisPage.length < @maxAppsPerRow+1
		end #def correctCursorPos
		
	end #def drawApps
end #class PhoneScene