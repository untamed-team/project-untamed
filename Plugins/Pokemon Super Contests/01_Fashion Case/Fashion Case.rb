SaveData.register(:fashion_case) do
  save_value { $fashion_case }
  load_value { |value|  $fashion_case = value }
  new_game_value { FashionCase.new }
end

class FashionCase
  attr_accessor :unlocked_accessories
  attr_accessor :unlocked_backdrops
  
  def initialize
	@unlocked_accessories = []
    @unlocked_backdrops = []
  end
  
  #put in a quantity argument
  def accessory_unlock(accessory, silent=false)
    for i in 0...ContestSettings::ACCESSORIES.length
      ContestSettings::ACCESSORIES[i].each do |key, value|
        if key.to_s == accessory
          #add the accessory to the array if it exists in ContestSettings::ACCESSORIES
          ##and if the accessory is not already in the array
          #if silent is false or not specified
          if silent != true
            pbMEStop(0.0)
            meName = "Contests_Get Accessory"
            #play the jingle for getting an accessory and make a popup that says the
            #player got the accessory and added it to the fashion case
            pbMessage(_INTL("\\me[{1}]Obtained the \\c[1]{2}\\c[0]!\\wtnp[30]", meName, accessory))
            pbMessage(_INTL("\\PN put away the {1} in the Fashion Case.", accessory))
          end #if silent != true
          @unlocked_accessories.push(accessory)
        end #if key == accessory
      end #ContestSettings::ACCESSORIES[i].each do |key, value|
    end #for i in 0...ContestSettings::ACCESSORIES[i]
  end #def accessory_unlock(accessory, silent=false)
  
  def backdrop_unlock(backdrop, silent=false)
    if ContestSettings::BACKDROPS.include?(backdrop) && !@unlocked_backdrops.include?(backdrop)
      #add the backdrop to the array if it exists in ContestSettings::BACKDROPS
      #and if the backdrop is not already in the array
      
      #if silent is false or not specified
      if silent != true
        pbMEStop(0.0)
        meName = "Contests_Get Accessory"
        #play the jingle for getting an accessory and make a popup that says the
        #player got the accessory and added it to the fashion case
        pbMessage(_INTL("\\me[{1}]Obtained the \\c[1]{2}\\c[0]!\\wtnp[30]", meName, backdrop))
        pbMessage(_INTL("\\PN put away the {1} in the Fashion Case.", backdrop))
      end
      @unlocked_backdrops.push(backdrop)
    end
  end
  
  def emptyFashionCase
    @unlocked_accessories = []
    @unlocked_backdrops = []
  end
  
  def giveStarterPack
    #silently give the player the following accessories/backdrops to get them\
    #started with contests
    #contests will crash if no accessories are in the fashion case
	
	#give ALL the accessories. We aren't keeping super contests anyway
    3.times do
		accessory_unlock("Black Fluff", silent=true)
		accessory_unlock("Brown Fluff", silent=true)
		accessory_unlock("Orange Fluff", silent=true)
		accessory_unlock("Pink Fluff", silent=true)
		accessory_unlock("White Fluff", silent=true)
		accessory_unlock("Yellow Fluff", silent=true)
		
		accessory_unlock("Black Pebble", silent=true)
		accessory_unlock("Glitter Boulder", silent=true)
		accessory_unlock("Jagged Boulder", silent=true)
		accessory_unlock("Mini Pebble", silent=true)
		accessory_unlock("Round Pebble", silent=true)
		accessory_unlock("Snaggy Pebble", silent=true)
		
		accessory_unlock("Big Scale", silent=true)
		accessory_unlock("Blue Scale", silent=true)
		accessory_unlock("Green Scale", silent=true)
		accessory_unlock("Narrow Scale", silent=true)
		accessory_unlock("Pink Scale", silent=true)
		accessory_unlock("Purple Scale", silent=true)
		
		accessory_unlock("Blue Feather", silent=true)
		accessory_unlock("Blue Feather", silent=true)
		accessory_unlock("White Feather", silent=true)
		accessory_unlock("Yellow Feather", silent=true)
		
		accessory_unlock("Black Beard", silent=true)
		accessory_unlock("Black Moustache", silent=true)
		accessory_unlock("White Beard", silent=true)
		accessory_unlock("White Moustache", silent=true)
		
		accessory_unlock("Big Leaf", silent=true)
		accessory_unlock("Narrow Leaf", silent=true)
		accessory_unlock("Shed Claw", silent=true)
		accessory_unlock("Shed Horn", silent=true)
		accessory_unlock("Small Leaf", silent=true)
		accessory_unlock("Stump", silent=true)
		accessory_unlock("Thick Mushroom", silent=true)
		accessory_unlock("Thin Mushroom", silent=true)
		
		accessory_unlock("Determination", silent=true)
		accessory_unlock("Eerie Thing", silent=true)
		accessory_unlock("Glitter Powder", silent=true)
		accessory_unlock("Humming Note", silent=true)
		accessory_unlock("Mystic Fire", silent=true)
		accessory_unlock("Peculiar Spoon", silent=true)
		accessory_unlock("Poison Extract", silent=true)
		accessory_unlock("Pretty Dewdrop", silent=true)
		accessory_unlock("Puffy Smoke", silent=true)
		accessory_unlock("Seashell", silent=true)
		accessory_unlock("Shimmering Fire", silent=true)
		accessory_unlock("Shiny Powder", silent=true)
		accessory_unlock("Snow Crystal", silent=true)
		accessory_unlock("Sparks", silent=true)
		accessory_unlock("Spring", silent=true)
		accessory_unlock("Wealthy Coin", silent=true)
		
		accessory_unlock("Blue Flower", silent=true)
		accessory_unlock("Orange Flower", silent=true)
		accessory_unlock("Pink Flower", silent=true)
		accessory_unlock("Red Flower", silent=true)
		accessory_unlock("White Flower", silent=true)
		accessory_unlock("Yellow Flower", silent=true)
		
		accessory_unlock("Black Specs", silent=true)
		accessory_unlock("Googly Specs", silent=true)
		accessory_unlock("Gorgeous Specs", silent=true)
		
		accessory_unlock("Cape", silent=true)
		accessory_unlock("Carpet", silent=true)
		accessory_unlock("Colored Parasol", silent=true)
		accessory_unlock("Confetti", silent=true)
		accessory_unlock("Fluffy Bed", silent=true)
		accessory_unlock("Mirror Ball", silent=true)
		accessory_unlock("Old Umbrella", silent=true)
		accessory_unlock("Photo Board", silent=true)
		accessory_unlock("Retro Pipe", silent=true)
		accessory_unlock("Spotlight", silent=true)
		accessory_unlock("Standing Mike", silent=true)
		accessory_unlock("Surfboard", silent=true)
		accessory_unlock("Sweet Candy", silent=true)
		
		accessory_unlock("Blue Barrette", silent=true)
		accessory_unlock("Green Barrette", silent=true)
		accessory_unlock("Pink Barrette", silent=true)
		accessory_unlock("Red Barrette", silent=true)
		accessory_unlock("Yellow Barrette", silent=true)
		
		accessory_unlock("Blue Balloons", silent=true)
		accessory_unlock("Green Balloons", silent=true)
		accessory_unlock("Pink Balloons", silent=true)
		accessory_unlock("Red Balloons", silent=true)
		accessory_unlock("Yellow Balloons", silent=true)
		
		accessory_unlock("Heroic Headband", silent=true)
		accessory_unlock("Lace Headress", silent=true)
		accessory_unlock("Professor Hat", silent=true)
		accessory_unlock("Silk Veil", silent=true)
		accessory_unlock("Top Hat", silent=true)
		
		accessory_unlock("Award Podium", silent=true)
		accessory_unlock("Cube Stage", silent=true)
		accessory_unlock("Flower Stage", silent=true)
		accessory_unlock("Glass Stage", silent=true)
		accessory_unlock("Gold Pedestal", silent=true)
		
		accessory_unlock("Big Tree", silent=true)
		accessory_unlock("Chimchar Mask", silent=true)
		accessory_unlock("Comet", silent=true)
		accessory_unlock("Crown", silent=true)
		accessory_unlock("Flag", silent=true)
		accessory_unlock("Piplup Mask", silent=true)
		accessory_unlock("Tiara", silent=true)
		accessory_unlock("Turtwig Mask", silent=true)
	end
	
	#give ALL the backdrops. We aren't keeping super contests anyway
    backdrop_unlock("City at Night", silent=true)
    backdrop_unlock("Cumulus Cloud", silent=true)
    backdrop_unlock("Desert", silent=true)
    backdrop_unlock("Dress up", silent=true)
    backdrop_unlock("Fiery", silent=true)
    backdrop_unlock("Flower Patch", silent=true)
    backdrop_unlock("Future Room", silent=true)
    backdrop_unlock("Gingerbread Room", silent=true)
    backdrop_unlock("Open Sea", silent=true)
    backdrop_unlock("Outer Space", silent=true)
    backdrop_unlock("Ranch", silent=true)
    backdrop_unlock("Seafloor", silent=true)
    backdrop_unlock("Sky", silent=true)
    backdrop_unlock("Snowy town", silent=true)
    backdrop_unlock("Tatami Room", silent=true)
    backdrop_unlock("Theater", silent=true)
    backdrop_unlock("Total Darkness", silent=true)
    backdrop_unlock("Underground", silent=true)
  end
  
  #syntax:
  #$fashion_case.accessory_unlock("accessory")
  #$fashion_case.backdrop_unlock("backdrop")
end