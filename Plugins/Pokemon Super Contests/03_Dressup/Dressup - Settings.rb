module ContestSettings

#========================================================#
#================== VISUAL COMPETITION ==================#
#========================================================#
#the max amount of attachable accessories during dressup
MAX_ACCESSORIES_NORMAL = 5
MAX_ACCESSORIES_GREAT = 10
MAX_ACCESSORIES_ULTRA = 15
MAX_ACCESSORIES_MASTER = 20

#amount of time given during dressup
DRESSUP_TIME = 60

#put this setting as true if you expect to give the player a LOT of the same kind
#of accessories like 9 black fluff, etc. Making the accessories small will reduce
#clutter, and the item goes to full size when being dragged or when attached to
#the pokemon
DRESS_UP_ITEMS_SMALL = true

#when creating a contestant image, this is set to true by default since the
#script gives 9 of each accessory to work with
CONTESTANT_DRESS_UP_ITEMS_SMALL = true

CONTEST_THEMES =
[
"The Bright",
"The Colorful",
"The Created",
"The Festive",
"The Flexible",
"The Gaudy",
"The Intangible",
"The Natural",
"The Relaxed",
"The Shapely",
"The Sharp",
"The Solid",
]

#this is a list of accessories in the dressup minigame
#the array contains the following information:
#page number accessory belongs on in the selection window, accessory name
#(matches graphic name), and its worth in points for each theme
#The syntax is
#page accessory belongs on, ["accessory name", first theme in CONTEST_THEMES, second theme, third theme,
#fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelfth]
#worth in points: 1 is LOW, 2 is MEDIUM, 3 is high

#to access elements in this array, ContestSettings::ACCESSORIES[0] gives you everything
#on the first accessory page

ACCESSORIES = [

#===========================
#========== Page ===========
#===========================
Fluffs = {
"Black Fluff":
{"The Bright": 1, "The Colorful": 3, "The Created": 1,
"The Festive": 2, "The Flexible": 3, "The Gaudy": 2, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 3, "The Shapely": 2, "The Sharp": 1, "The Solid": 2},

"Brown Fluff":
{"The Bright": 2, "The Colorful": 3, "The Created": 1,
"The Festive": 2, "The Flexible": 3, "The Gaudy": 2, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 3, "The Shapely": 2, "The Sharp": 1, "The Solid": 2},

"Orange Fluff":
{"The Bright": 2, "The Colorful": 3, "The Created": 1,
"The Festive": 2, "The Flexible": 3, "The Gaudy": 2, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 2, "The Shapely": 2, "The Sharp": 1, "The Solid": 2},

"Pink Fluff":
{"The Bright": 2, "The Colorful": 3, "The Created": 1,
"The Festive": 2, "The Flexible": 3, "The Gaudy": 2, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 2, "The Shapely": 2, "The Sharp": 1, "The Solid": 2},

"White Fluff":
{"The Bright": 0, "The Colorful": 0, "The Created": 0,
"The Festive": 0, "The Flexible": 0, "The Gaudy": 0, "The Intangible": 0,
"The Natural": 0, "The Relaxed": 0, "The Shapely": 0, "The Sharp": 0, "The Solid": 0},

"Yellow Fluff":
{"The Bright": 0, "The Colorful": 0, "The Created": 0,
"The Festive": 0, "The Flexible": 0, "The Gaudy": 0, "The Intangible": 0,
"The Natural": 0, "The Relaxed": 0, "The Shapely": 0, "The Sharp": 0, "The Solid": 0}
}, #end of page hash

#===========================
#========== Page ===========
#===========================
Pebbles_and_Boulders = {
"Black Pebble":
{"The Bright": 1, "The Colorful": 3, "The Created": 2,
"The Festive": 2, "The Flexible": 1, "The Gaudy": 3, "The Intangible": 1,
"The Natural": 2, "The Relaxed": 3, "The Shapely": 3, "The Sharp": 1, "The Solid": 3},

"Glitter Boulder":
{"The Bright": 3, "The Colorful": 2, "The Created": 2,
"The Festive": 3, "The Flexible": 1, "The Gaudy": 3, "The Intangible": 1,
"The Natural": 2, "The Relaxed": 1, "The Shapely": 3, "The Sharp": 1, "The Solid": 3},

"Jagged Boulder":
{"The Bright": 2, "The Colorful": 1, "The Created": 1,
"The Festive": 1, "The Flexible": 1, "The Gaudy": 2, "The Intangible": 1,
"The Natural": 3, "The Relaxed": 3, "The Shapely": 3, "The Sharp": 1, "The Solid": 3},

"Mini Pebble":
{"The Bright": 2, "The Colorful": 2, "The Created": 2,
"The Festive": 2, "The Flexible": 1, "The Gaudy": 3, "The Intangible": 1,
"The Natural": 2, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 1, "The Solid": 3},

"Round Pebble":
{"The Bright": 2, "The Colorful": 2, "The Created": 2,
"The Festive": 2, "The Flexible": 1, "The Gaudy": 3, "The Intangible": 1,
"The Natural": 2, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 1, "The Solid": 3},

"Snaggy Pebble":
{"The Bright": 2, "The Colorful": 1, "The Created": 1,
"The Festive": 1, "The Flexible": 1, "The Gaudy": 2, "The Intangible": 1,
"The Natural": 3, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 1, "The Solid": 3},
}, #end of page hash

#===========================
#========== Page ===========
#===========================
Scales = {
"Big Scale":
{"The Bright": 3, "The Colorful": 2, "The Created": 1,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 1, "The Shapely": 2, "The Sharp": 3, "The Solid": 3},

"Blue Scale":
{"The Bright": 2, "The Colorful": 3, "The Created": 1,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 3, "The Shapely": 2, "The Sharp": 3, "The Solid": 3},

"Green Scale":
{"The Bright": 2, "The Colorful": 3, "The Created": 1,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 2, "The Shapely": 2, "The Sharp": 1, "The Solid": 3},

"Narrow Scale":
{"The Bright": 1, "The Colorful": 2, "The Created": 1,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 3, "The Shapely": 2, "The Sharp": 3, "The Solid": 3},

"Pink Scale":
{"The Bright": 2, "The Colorful": 3, "The Created": 1,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 2, "The Shapely": 2, "The Sharp": 2, "The Solid": 3},

"Purple Scale":
{"The Bright": 2, "The Colorful": 3, "The Created": 1,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 2, "The Shapely": 2, "The Sharp": 3, "The Solid": 3},
}, #end of page hash

#===========================
#========== Page ===========
#===========================
Feathers = {
"Blue Feather":
{"The Bright": 2, "The Colorful": 3, "The Created": 1,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 2, "The Shapely": 2, "The Sharp": 3, "The Solid": 3},

"Red Feather":
{"The Bright": 2, "The Colorful": 3, "The Created": 1,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 2, "The Shapely": 2, "The Sharp": 3, "The Solid": 2},

"White Feather":
{"The Bright": 3, "The Colorful": 3, "The Created": 1,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 1, "The Shapely": 2, "The Sharp": 3, "The Solid": 2},

"Yellow Feather":
{"The Bright": 3, "The Colorful": 3, "The Created": 1,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 2, "The Shapely": 2, "The Sharp": 3, "The Solid": 2},
}, #end of page hash

#===========================
#========== Page ===========
#===========================
Facial_Hair = {
"Black Beard":
{"The Bright": 1, "The Colorful": 3, "The Created": 3,
"The Festive": 1, "The Flexible": 3, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 1, "The Relaxed": 3, "The Shapely": 2, "The Sharp": 3, "The Solid": 2},

"Black Moustache":
{"The Bright": 1, "The Colorful": 3, "The Created": 3,
"The Festive": 1, "The Flexible": 3, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 1, "The Relaxed": 3, "The Shapely": 2, "The Sharp": 2, "The Solid": 2},

"White Beard":
{"The Bright": 3, "The Colorful": 2, "The Created": 3,
"The Festive": 1, "The Flexible": 3, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 1, "The Relaxed": 1, "The Shapely": 2, "The Sharp": 3, "The Solid": 2},

"White Moustache":
{"The Bright": 3, "The Colorful": 2, "The Created": 3,
"The Festive": 1, "The Flexible": 3, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 1, "The Relaxed": 1, "The Shapely": 2, "The Sharp": 2, "The Solid": 2},
}, #end of page hash

#===========================
#========== Page ===========
#===========================
Natural = {
"Big Leaf":
{"The Bright": 2, "The Colorful": 2, "The Created": 1,
"The Festive": 1, "The Flexible": 3, "The Gaudy": 2, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 2, "The Solid": 2},

"Narrow Leaf":
{"The Bright": 2, "The Colorful": 2, "The Created": 1,
"The Festive": 1, "The Flexible": 3, "The Gaudy": 2, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 2, "The Shapely": 2, "The Sharp": 3, "The Solid": 2},

"Shed Claw":
{"The Bright": 3, "The Colorful": 1, "The Created": 2,
"The Festive": 2, "The Flexible": 1, "The Gaudy": 2, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 1, "The Shapely": 3, "The Sharp": 3, "The Solid": 3},

"Shed Horn":
{"The Bright": 3, "The Colorful": 1, "The Created": 2,
"The Festive": 2, "The Flexible": 1, "The Gaudy": 2, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 1, "The Shapely": 3, "The Sharp": 3, "The Solid": 3},

"Small Leaf":
{"The Bright": 2, "The Colorful": 2, "The Created": 1,
"The Festive": 1, "The Flexible": 3, "The Gaudy": 2, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 2, "The Shapely": 2, "The Sharp": 2, "The Solid": 2},

"Stump":
{"The Bright": 2, "The Colorful": 1, "The Created": 2,
"The Festive": 1, "The Flexible": 1, "The Gaudy": 2, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 2, "The Solid": 3},

"Thick Mushroom":
{"The Bright": 2, "The Colorful": 2, "The Created": 2,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 2, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 1, "The Shapely": 3, "The Sharp": 2, "The Solid": 2},

"Thin Mushroom":
{"The Bright": 3, "The Colorful": 2, "The Created": 2,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 2, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 1, "The Shapely": 2, "The Sharp": 3, "The Solid": 2},
}, #end of page hash

#===========================
#========== Page ===========
#===========================
Massage_Accessories = {
"Determination":
{"The Bright": 3, "The Colorful": 2, "The Created": 2,
"The Festive": 2, "The Flexible": 3, "The Gaudy": 3, "The Intangible": 3,
"The Natural": 2, "The Relaxed": 2, "The Shapely": 1, "The Sharp": 2, "The Solid": 1},

"Eerie Thing":
{"The Bright": 1, "The Colorful": 3, "The Created": 2,
"The Festive": 1, "The Flexible": 3, "The Gaudy": 1, "The Intangible": 3,
"The Natural": 3, "The Relaxed": 3, "The Shapely": 2, "The Sharp": 1, "The Solid": 1},

"Glitter Powder":
{"The Bright": 3, "The Colorful": 2, "The Created": 3,
"The Festive": 3, "The Flexible": 3, "The Gaudy": 3, "The Intangible": 3,
"The Natural": 2, "The Relaxed": 1, "The Shapely": 2, "The Sharp": 1, "The Solid": 2},

"Humming Note":
{"The Bright": 2, "The Colorful": 2, "The Created": 3,
"The Festive": 3, "The Flexible": 3, "The Gaudy": 3, "The Intangible": 3,
"The Natural": 2, "The Relaxed": 2, "The Shapely": 1, "The Sharp": 2, "The Solid": 2},

"Mystic Fire":
{"The Bright": 3, "The Colorful": 2, "The Created": 2,
"The Festive": 3, "The Flexible": 3, "The Gaudy": 2, "The Intangible": 3,
"The Natural": 3, "The Relaxed": 2, "The Shapely": 1, "The Sharp": 1, "The Solid": 1},

"Peculiar Spoon":
{"The Bright": 2, "The Colorful": 1, "The Created": 3,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 2, "The Intangible": 1,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 2, "The Solid": 3},

"Poison Extract":
{"The Bright": 1, "The Colorful": 3, "The Created": 2,
"The Festive": 1, "The Flexible": 3, "The Gaudy": 1, "The Intangible": 3,
"The Natural": 3, "The Relaxed": 3, "The Shapely": 1, "The Sharp": 1, "The Solid": 1},

"Pretty Dewdrop":
{"The Bright": 2, "The Colorful": 2, "The Created": 1,
"The Festive": 3, "The Flexible": 3, "The Gaudy": 2, "The Intangible": 3,
"The Natural": 3, "The Relaxed": 1, "The Shapely": 2, "The Sharp": 1, "The Solid": 1},

"Puffy Smoke":
{"The Bright": 2, "The Colorful": 2, "The Created": 1,
"The Festive": 1, "The Flexible": 3, "The Gaudy": 2, "The Intangible": 3,
"The Natural": 3, "The Relaxed": 2, "The Shapely": 1, "The Sharp": 1, "The Solid": 1},

"Seashell":
{"The Bright": 3, "The Colorful": 1, "The Created": 1,
"The Festive": 2, "The Flexible": 1, "The Gaudy": 2, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 2, "The Solid": 3},

"Shimmering Fire":
{"The Bright": 3, "The Colorful": 2, "The Created": 2,
"The Festive": 3, "The Flexible": 3, "The Gaudy": 3, "The Intangible": 3,
"The Natural": 3, "The Relaxed": 2, "The Shapely": 1, "The Sharp": 1, "The Solid": 1},

"Shiny Powder":
{"The Bright": 3, "The Colorful": 2, "The Created": 3,
"The Festive": 3, "The Flexible": 3, "The Gaudy": 3, "The Intangible": 3,
"The Natural": 2, "The Relaxed": 1, "The Shapely": 2, "The Sharp": 1, "The Solid": 2},

"Snow Crystal":
{"The Bright": 3, "The Colorful": 2, "The Created": 1,
"The Festive": 3, "The Flexible": 3, "The Gaudy": 2, "The Intangible": 3,
"The Natural": 3, "The Relaxed": 1, "The Shapely": 2, "The Sharp": 2, "The Solid": 1},

"Sparks":
{"The Bright": 3, "The Colorful": 2, "The Created": 2,
"The Festive": 3, "The Flexible": 3, "The Gaudy": 2, "The Intangible": 3,
"The Natural": 3, "The Relaxed": 2, "The Shapely": 1, "The Sharp": 1, "The Solid": 1},

"Spring":
{"The Bright": 2, "The Colorful": 2, "The Created": 3,
"The Festive": 2, "The Flexible": 3, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 3, "The Solid": 3},

"Wealthy Coin":
{"The Bright": 2, "The Colorful": 2, "The Created": 3,
"The Festive": 3, "The Flexible": 1, "The Gaudy": 3, "The Intangible": 1,
"The Natural": 1, "The Relaxed": 1, "The Shapely": 3, "The Sharp": 1, "The Solid": 3},
}, #end of page hash

#===========================
#========== Page ===========
#===========================
Flowers = {
"Blue Flower":
{"The Bright": 2, "The Colorful": 3, "The Created": 1,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 2, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 2, "The Solid": 2},

"Orange Flower":
{"The Bright": 2, "The Colorful": 3, "The Created": 1,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 2, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 2, "The Solid": 2},

"Pink Flower":
{"The Bright": 2, "The Colorful": 3, "The Created": 1,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 2, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 2, "The Solid": 2},

"Red Flower":
{"The Bright": 2, "The Colorful": 3, "The Created": 1,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 2, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 2, "The Solid": 2},

"White Flower":
{"The Bright": 3, "The Colorful": 2, "The Created": 1,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 2, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 1, "The Shapely": 3, "The Sharp": 2, "The Solid": 2},

"Yellow Flower":
{"The Bright": 3, "The Colorful": 3, "The Created": 1,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 2, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 2, "The Solid": 2},
}, #end of page hash

#===========================
#========== Page ===========
#===========================
Specs = {
"Black Specs":
{"The Bright": 1, "The Colorful": 3, "The Created": 3,
"The Festive": 1, "The Flexible": 1, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 1, "The Relaxed": 3, "The Shapely": 3, "The Sharp": 2, "The Solid": 3},

"Googly Specs":
{"The Bright": 2, "The Colorful": 2, "The Created": 3,
"The Festive": 1, "The Flexible": 1, "The Gaudy": 2, "The Intangible": 2,
"The Natural": 1, "The Relaxed": 3, "The Shapely": 3, "The Sharp": 2, "The Solid": 3},

"Gorgeous Specs":
{"The Bright": 1, "The Colorful": 3, "The Created": 3,
"The Festive": 3, "The Flexible": 1, "The Gaudy": 3, "The Intangible": 3,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 2, "The Solid": 3},
}, #end of page hash

#===========================
#========== Page ===========
#===========================
Misc = {
"Cape":
{"The Bright": 1, "The Colorful": 3, "The Created": 3,
"The Festive": 2, "The Flexible": 3, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 1, "The Relaxed": 3, "The Shapely": 3, "The Sharp": 3, "The Solid": 2},

"Carpet":
{"The Bright": 2, "The Colorful": 3, "The Created": 3,
"The Festive": 3, "The Flexible": 3, "The Gaudy": 3, "The Intangible": 3,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 1, "The Solid": 3},

"Colored Parasol":
{"The Bright": 3, "The Colorful": 3, "The Created": 3,
"The Festive": 3, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 3, "The Solid": 3},

"Confetti":
{"The Bright": 2, "The Colorful": 3, "The Created": 3,
"The Festive": 2, "The Flexible": 3, "The Gaudy": 3, "The Intangible": 3,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 2, "The Sharp": 2, "The Solid": 2},

"Fluffy Bed":
{"The Bright": 2, "The Colorful": 2, "The Created": 3,
"The Festive": 2, "The Flexible": 3, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 1, "The Solid": 2},

"Mirror Ball":
{"The Bright": 3, "The Colorful": 2, "The Created": 3,
"The Festive": 3, "The Flexible": 1, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 1, "The Relaxed": 1, "The Shapely": 3, "The Sharp": 1, "The Solid": 3},

"Old Umbrella":
{"The Bright": 2, "The Colorful": 2, "The Created": 3,
"The Festive": 1, "The Flexible": 2, "The Gaudy": 2, "The Intangible": 2,
"The Natural": 1, "The Relaxed": 3, "The Shapely": 3, "The Sharp": 3, "The Solid": 3},

"Photo Board":
{"The Bright": 2, "The Colorful": 2, "The Created": 3,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 3,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 2, "The Solid": 3},

"Retro Pipe":
{"The Bright": 2, "The Colorful": 2, "The Created": 3,
"The Festive": 1, "The Flexible": 1, "The Gaudy": 2, "The Intangible": 1,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 2, "The Solid": 3},

"Spotlight":
{"The Bright": 3, "The Colorful": 1, "The Created": 3,
"The Festive": 3, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 3,
"The Natural": 1, "The Relaxed": 1, "The Shapely": 3, "The Sharp": 2, "The Solid": 3},

"Standing Mike":
{"The Bright": 2, "The Colorful": 2, "The Created": 3,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 3, "The Solid": 3},

"Surfboard":
{"The Bright": 2, "The Colorful": 2, "The Created": 3,
"The Festive": 2, "The Flexible": 1, "The Gaudy": 3, "The Intangible": 2,
"The Natural":1 , "The Relaxed": 2, "The Shapely": 3, "The Sharp": 3, "The Solid": 3},

"Sweet Candy":
{"The Bright": 2, "The Colorful": 2, "The Created": 3,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 2, "The Solid": 3},
}, #end of page hash

#===========================
#========== Page ===========
#===========================
Barrettes = {
"Blue Barrette":
{"The Bright": 2, "The Colorful": 3, "The Created": 3,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 2, "The Sharp": 2, "The Solid": 2},

"Green Barrette":
{"The Bright": 2, "The Colorful": 3, "The Created": 3,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 2, "The Sharp": 2, "The Solid": 2},

"Pink Barrette":
{"The Bright": 2, "The Colorful": 3, "The Created": 3,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 2, "The Sharp": 2, "The Solid": 2},

"Red Barrette":
{"The Bright": 2, "The Colorful": 3, "The Created": 3,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 2, "The Sharp": 2, "The Solid": 2},

"Yellow Barrette":
{"The Bright": 3, "The Colorful": 3, "The Created": 3,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 2, "The Sharp": 2, "The Solid": 2},
}, #end of page hash

#===========================
#========== Page ===========
#===========================
Balloons = {
"Blue Balloons":
{"The Bright": 2, "The Colorful": 3, "The Created": 3,
"The Festive": 2, "The Flexible": 3, "The Gaudy": 3, "The Intangible": 3,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 2, "The Sharp": 1, "The Solid": 1},

"Green Balloons":
{"The Bright": 2, "The Colorful": 3, "The Created": 3,
"The Festive": 2, "The Flexible": 3, "The Gaudy": 3, "The Intangible": 3,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 2, "The Sharp": 1, "The Solid": 1},

"Pink Balloons":
{"The Bright": 2, "The Colorful": 3, "The Created": 3,
"The Festive": 2, "The Flexible": 3, "The Gaudy": 3, "The Intangible": 3,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 2, "The Sharp": 1, "The Solid": 1},

"Red Balloons":
{"The Bright": 2, "The Colorful": 3, "The Created": 3,
"The Festive": 2, "The Flexible": 3, "The Gaudy": 3, "The Intangible": 3,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 2, "The Sharp": 1, "The Solid": 1},

"Yellow Balloons":
{"The Bright": 3, "The Colorful": 3, "The Created": 3,
"The Festive": 2, "The Flexible": 3, "The Gaudy": 3, "The Intangible": 3,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 2, "The Sharp": 1, "The Solid": 1},
}, #end of page hash

#===========================
#========== Page ===========
#===========================
Headwear = {
"Heroic Headband":
{"The Bright": 2, "The Colorful": 2, "The Created": 3,
"The Festive": 2, "The Flexible": 3, "The Gaudy": 3, "The Intangible": 3,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 2, "The Solid": 2},

"Lace Headress":
{"The Bright": 3, "The Colorful": 1, "The Created": 3,
"The Festive": 3, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 3, "The Solid": 2},

"Professor Hat":
{"The Bright": 2, "The Colorful": 3, "The Created": 3,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 3, "The Solid": 3},

"Silk Veil":
{"The Bright": 3, "The Colorful": 2, "The Created": 3,
"The Festive": 3, "The Flexible": 3, "The Gaudy": 3, "The Intangible": 3,
"The Natural": 1, "The Relaxed": 1, "The Shapely": 3, "The Sharp": 2, "The Solid": 2},

"Top Hat":
{"The Bright": 1, "The Colorful": 3, "The Created": 3,
"The Festive": 3, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 1, "The Relaxed": 3, "The Shapely": 3, "The Sharp": 2, "The Solid": 2},
}, #end of page hash

#===========================
#========== Page ===========
#===========================
Stages = {
"Award Podium":
{"The Bright": 3, "The Colorful": 2, "The Created": 3,
"The Festive": 2, "The Flexible": 1, "The Gaudy": 3, "The Intangible": 1,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 2, "The Solid": 3},

"Cube Stage":
{"The Bright": 2, "The Colorful": 2, "The Created": 3,
"The Festive": 2, "The Flexible": 1, "The Gaudy": 3, "The Intangible": 1,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 2, "The Solid": 3},

"Flower Stage":
{"The Bright": 2, "The Colorful": 2, "The Created": 3,
"The Festive": 3, "The Flexible": 1, "The Gaudy": 3, "The Intangible": 1,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 2, "The Solid": 3},

"Glass Stage":
{"The Bright": 3, "The Colorful": 2, "The Created": 3,
"The Festive": 3, "The Flexible": 1, "The Gaudy": 3, "The Intangible": 1,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 2, "The Solid": 3},

"Gold Pedestal":
{"The Bright": 3, "The Colorful": 3, "The Created": 3,
"The Festive": 3, "The Flexible": 1, "The Gaudy": 3, "The Intangible": 1,
"The Natural": 1, "The Relaxed": 1, "The Shapely": 3, "The Sharp": 2, "The Solid": 3},
}, #end of page hash

#===========================
#========== Page ===========
#===========================
Special = {
"Big Tree":
{"The Bright": 2, "The Colorful": 2, "The Created": 1,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 2, "The Intangible": 1,
"The Natural": 3, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 2, "The Solid": 3},

"Chimchar Mask":
{"The Bright": 2, "The Colorful": 2, "The Created": 3,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 1, "The Solid": 2},

"Comet":
{"The Bright": 3, "The Colorful": 3, "The Created": 1,
"The Festive": 3, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 2, "The Solid": 3},

"Crown":
{"The Bright": 3, "The Colorful": 2, "The Created": 3,
"The Festive": 3, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 1, "The Relaxed": 1, "The Shapely": 3, "The Sharp": 3, "The Solid": 3},

"Flag":
{"The Bright": 2, "The Colorful": 3, "The Created": 3,
"The Festive": 2, "The Flexible": 3, "The Gaudy": 3, "The Intangible": 3,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 3, "The Solid": 3},

"Piplup Mask":
{"The Bright": 2, "The Colorful": 2, "The Created": 3,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 1, "The Solid": 2},

"Tiara":
{"The Bright": 3, "The Colorful": 2, "The Created": 3,
"The Festive": 3, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 1, "The Relaxed": 1, "The Shapely": 3, "The Sharp": 3, "The Solid": 3},

"Turtwig Mask":
{"The Bright": 2, "The Colorful": 2, "The Created": 3,
"The Festive": 2, "The Flexible": 2, "The Gaudy": 3, "The Intangible": 2,
"The Natural": 1, "The Relaxed": 2, "The Shapely": 3, "The Sharp": 1, "The Solid": 2},
} #end of page hash
] #end of the accessories array

#this is a list of the backdrops for the dressup minigame
BACKDROPS = [
"City at Night",
"Cumulus Cloud",
"Desert",
"Dress up",
"Fiery",
"Flower Patch",
"Future Room",
"Gingerbread Room",
"Open Sea",
"Outer Space",
"Ranch",
"Seafloor",
"Sky",
"Snowy town",
"Tatami Room",
"Theater",
"Total Darkness",
"Underground",
]

end #module ContestSettings