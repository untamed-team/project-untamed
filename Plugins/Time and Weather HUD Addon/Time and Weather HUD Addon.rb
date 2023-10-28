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
	
	#added by Gardenette to display icons based on time of day and overworld weather
	@sprites["time_icon"] = IconSprite.new(0, 0, viewport)
    @sprites["time_icon"].setBitmap("Graphics/Pictures/Voltseon's Pause Menu/time/day")
	@sprites["time_icon"].visible = false
    @sprites["time_icon"].x = Graphics.width - 124
    @sprites["time_icon"].y = 42
    @sprites["time_icon"].z = 99999
	
	@sprites["weather_icon"] = IconSprite.new(0, 0, viewport)
    @sprites["weather_icon"].setBitmap("Graphics/Pictures/Voltseon's Pause Menu/weather/sun")
	@sprites["weather_icon"].visible = false
    @sprites["weather_icon"].x = @sprites["time_icon"].x - @sprites["weather_icon"].width
    @sprites["weather_icon"].y = 42
    @sprites["weather_icon"].z = 99999
  end

  def shouldDraw?; return !(pbInBugContest? || pbInSafari?); end

  def update
    super
    refresh if @last_time != pbGetTimeNow.strftime("%I:%M %p")
  end

  def refresh
    text = _INTL("{1} {2} {3}",Time.now.day.to_i,pbGetAbbrevMonthName(Time.now.month.to_i),Time.now.year.to_i)
    text2 = _INTL("{1}",pbGetTimeNow.strftime("%I:%M %p"))
    @sprites["overlay"].bitmap.clear
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbDrawTextPositions(@sprites["overlay"].bitmap,[[text,Graphics.width/2 - 8, 12,1,
      @baseColor,@shadowColor],[text2,Graphics.width/2 - 8,44,1,@baseColor,@shadowColor]])
    @last_time = pbGetTimeNow.strftime("%I:%M %p")
	
	#added by Gardenette to display icons based on time of day and overworld weather
	time_icon = "morning" if PBDayNight.isMorning?
	time_icon = "day" if PBDayNight.isDay?
	time_icon = "afternoon" if PBDayNight.isAfternoon?
	time_icon = "evening" if PBDayNight.isEvening?
	time_icon = "night" if PBDayNight.isNight?
	
	@sprites["time_icon"].setBitmap("Graphics/Pictures/Voltseon's Pause Menu/time/#{time_icon}")
	@sprites["time_icon"].visible = true
	
	case $game_screen.weather_type
	when :Rain 
	  weather_icon = "rain"
	when :HeavyRain
	  weather_icon = "rain"
	when :Storm
	  weather_icon = "storm"
	when :Snow
	  weather_icon = "snow"
	when :Blizzard
	  weather_icon = "snow"
	when :Sandstorm
	  weather_icon = "sandstorm"
	when :Fog
	  weather_icon = "sandstorm"
	when :Sun
	  weather_icon = "sun"
	end
	
	@sprites["weather_icon"].setBitmap("Graphics/Pictures/Voltseon's Pause Menu/weather/#{weather_icon}")
	if $game_screen.weather_type == :None
	  @sprites["weather_icon"].visible = false
	else
	  @sprites["weather_icon"].visible = true
	end
  end
end