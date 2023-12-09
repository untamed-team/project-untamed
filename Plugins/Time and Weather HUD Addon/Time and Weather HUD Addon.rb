#-------------------------------------------------------------------------------
# Date and Time Hud component
#-------------------------------------------------------------------------------
class DateAndTimeHud < Component
  def initialize
    @last_time = pbGetTimeNow.strftime("%I:%M %p")
  end

  def startComponent(viewport)
    super(viewport)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width/2,96,viewport)
    @sprites["overlay"].ox = @sprites["overlay"].bitmap.width
    @sprites["overlay"].x = Graphics.width
    @baseColor = MENU_TEXTCOLOR[$PokemonSystem.current_menu_theme] || Color.new(248,248,248)
    @shadowColor = MENU_TEXTOUTLINE[$PokemonSystem.current_menu_theme] || Color.new(48,48,48)
  end

  def shouldDraw?; return !(pbInBugContest? || pbInSafari?); end

  def update
    super
    refresh if @last_time != pbGetTimeNow.strftime("%I:%M %p")
  end

  def refresh
    text = _INTL("{1} {2} {3}",Time.now.day.to_i,pbGetAbbrevMonthName(Time.now.month.to_i),Time.now.year.to_i)
    text2 = _INTL("{1}",pbGetTimeNow.strftime("%I:%M %p"))
	overlay = @sprites["overlay"].bitmap
	overlay.clear
    pbSetSystemFont(overlay)
    pbDrawTextPositions(overlay,[
		[text, Graphics.width/2 - 8, 12, 1, @baseColor, @shadowColor],
		[text2, Graphics.width/2 - 8, 44, 1, @baseColor, @shadowColor]
	])
    @last_time = pbGetTimeNow.strftime("%I:%M %p")
	
	imagepos = []
	textwidth = overlay.text_size(text2).width
	#added by Gardenette to display icons based on time of day and overworld weather
	time = -1
	if PBDayNight.isMorning?
	  time = 0
	elsif PBDayNight.isDay?
	  time = 1
	elsif PBDayNight.isAfternoon?
	  time = 1
	elsif PBDayNight.isEvening?
	  time = 2
	elsif PBDayNight.isNight?
	  time = 3
	end

	if time >= 0
	  imagepos.push(["Graphics/Pictures/Voltseon's Pause Menu/time_weather", Graphics.width/2 - textwidth - 36, 42, 0, 24 * time, 24, 24])
	end
	
	weather = -1
	case $game_screen.weather_type
	when :Rain 
	  weather = 4
	when :HeavyRain
	  weather = 5
	when :Storm
	  weather = 6
	when :Snow
	  weather = 7
	when :Blizzard
	  weather = 8
	when :Sandstorm
	  weather = 9
	when :Fog
	  weather = 10
	when :Sun
	  weather = 10
	end

	if weather >= 0
	  imagepos.push(["Graphics/Pictures/Voltseon's Pause Menu/time_weather", Graphics.width/2 - textwidth - 64, 42, 0, 24 * weather, 24, 24])
	end
	
    pbDrawImagePositions(overlay, imagepos)

  end
end