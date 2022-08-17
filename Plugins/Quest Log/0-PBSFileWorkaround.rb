def initializeQuestLog
	$QuestLog=[
	["Our first Side quest","1","false",
	[["1","1) Pick up the Poké Ball on the ground!"]]],

	["Berry Harvest","1","false",
	[["1","1) Colllect an Oran Berry."],
	["1","2) Colllect a Pecha Berry."],
	["1","3) Colllect a Chesto Berry."],
	["1","4) Colllect a Cheri Berry."]]],

	["Apricorn collect","1","false",
	[["1","1) Gather An Apricorn."],
	["0","2) Talk to the old man in front of the house with an Apricorn in your bag"]]],

	["A simple back and forth","0","true",
	[["1","1) Talk to the Police Officer."],
	["0","2) Talk to the kid near the berry fields."]]],
	
	["Multi Page Demo","1","true",
	[["0","1) I made this Quest"],
	["0","2) With the specific intent of having so many objectives"],
	["0","3) The quest log would have to display it on multiple pages"],
	["0","4) in order to showcase how it\'d work."], 
	["0","5) First, you\'ll notice that even if some objectives"],
	["1","6) are hidden while the next one is revealed,"],
	["0","7) the script will process it accordingly and display the next goal in it\'s place."], 
	["0","8) So,even if you can\'t see this message, there\'s no blank spots on the screen."],
	["0","9) As you can see, it displays arrows indicating whether there's stuff or not remaining"],
	["0","10) to display, so the player knows to check for another page."],
	["0","11) However, the whole process is, it turns out, somewhat consuming on the game."],
	["0","12) You can notice a slight delay when opening that quest page."],
	["0","13) There\'s complicated reasons behind it, so if you\'re unfamilliar with scripting"],
	["0","14) Just know that the bottom line is that this script is pain."], 
	["0","15) Thankfully, this lag should only come up for quests that long."],
	["0","16) And, to be frank, you probably shouldn\'t be making quests this big"],
	["0","17) Would be way better to make separate quests, both for you and the player."],
	["0","18) Oh cool we\'re reaching the end I can stop talking."],
	["0","19) So anyway, how was your day ?"]]]
]
end