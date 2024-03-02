Hello, and welcome to what's been my hell for the past 6 months at the time of this writing :)
If you aren't familiar with Pokemon Super Contests, they are a gimmick from the 4th generation of Pokemon (Diamond, Pearl, Platinum).
The video below shows what contests in gen 4 look like. I tried to make this plugin mimic that look and feel:
https://www.youtube.com/watch?v=pSFNfm2ycJQ

I think I've covered just about everything needed, but please give me feedback on how to make this more clear and what's missing from this README.

###################################
#========== Requirements ==========
###################################
The contest stage uses Follower Pokemon graphics. All the follower graphics can be obtained here:
https://reliccastle.com/threads/5101/
All you need from that resource is "Graphics\Characters\Followers" and "Graphics\Characters\Shiny Followers".

The next requirement (absolutely will not work without this): Luka's Easy Mouse System
That can be obtained here:
#https://luka-sj.com/res/ESMS

###################################
#===== What's not Supported? =====
###################################
I will NOT be supporting a way to create PokeBlocks/Poffins at this time.
For Pokeblocks, I recommend wrigty12's Contests script which contains Pokeblocks:
https://reliccastle.com/resources/1340/

I will be happy to help out with syntax of creating new Acting Move Effects, new accessories, or anything else you want to add to the plugin. However, I will NOT be coding this for you unless I want to use it myself in the plugin or if many people want it in the plugin. Please do not expect me to code your idea for you.

#############################################################################
#============================= Using the Plugin =============================
#############################################################################
Before we get into how to use this plugin, please know that there is quite a bit of setup involved, especially if you want to change the default behavior of the script. I am open to any and all feedback!

I will include a demo world in the download of the plugin so you can see how I set up the maps "Contest Reception" and "Contest Room".

######################
#=== Installation ====
######################
I will include a copy of the files needed separate from the demo.
Copy the Graphics folder you download here into your game's root folder.
Inside "Graphics\Pictures\Contest" is all the graphics you need for the plugin.

Copy the Audio folder you downloaded here into your game's root folder.
Inside there is all the audio you need for the plugin.

Copy maps 33 and 42 into your project, or open the demo world to study the events on those maps and then make your own maps.

Copy the Plugins folder into your game's root folder. Hotfixes and Luka's Easy Mouse System are not included in the Plugins folder that is separate from the demo.

##########################
#=== Dressup Settings ====
##########################
Before we talk about the fashion case, let's talk about defining an accessory/backdrop.
You can leave the defaults if you like, or tweak them anyway you want.
If you want to define a new accessory though, follow the pattern shown in the script file Dressup - Settings:

ACCESSORIES = [

Fluffs = {
"Black Fluff":
{"The Bright": 1, "The Colorful": 3, "The Created": 1,
"The Festive": 2, "The Flexible": 3, "The Gaudy": 2, "The Intangible": 2,
"The Natural": 3, "The Relaxed": 3, "The Shapely": 2, "The Sharp": 1, "The Solid": 2},
]

In the example above, "Fluffs = {" is a whole section of accessory. If you want to add a new fluff for example, copy and paste the black fluff and change whatever you want.
The parts that say "The Bright", "The Colorful", etc. are your contest themes. The number that comes after that theme name is the amount of points the accessory is worth when attached to your Pokemon if that theme is chosen.
For example, if the theme is "The Bright", and you attach a black fluff to your Pokemon, that's one point that goes towards your score.

Also be sure the name of the accessory matches the name of the graphic you want to use for that accessory in "Graphics\Pictures\Contest\dressup\accessories". See the files already in there for examples.

You can define new themes in "CONTEST_THEMES = ["

At the bottom of settings, you can define new backdrops in "BACKDROPS = ["

######################
#=== Fashion Case ====
######################
Currently you do not need to have a Fashion Case item in your bag for this to work.
Before you can do anything with the fashion case commands, you must run the following code to create the fashion case variables:
$fashion_case.emptyFashionCase

Currently I have this above the event command that gives the fashion case starter pack on the Reception map, so unless you remove that command, you will be resetting the fashion case every time you talk to that event.

Use the following command to give the player an accessory:
$fashion_case.accessory_unlock("accessory")
Change "accessory" to the name of an accessory you've defined in the scripts, but keep it within quotes.
For example, in the script file Dressup - Settings, you can name your accessories.
"Black Fluff", "Yellow Fluff", "Green Scale", etc.
If you want to give an accessory to the player without any popup message or sound effect, add the silent = true argument to the command like so:
$fashion_case.accessory_unlock("Black Fluff", silent=true)
Otherwise, $fashion_case.accessory_unlock("Black Fluff") will play a jingle and display a message saying the player received that accessory.

Use the following command to give the player a backdrop:
$fashion_case.backdrop_unlock("backdrop")
Change "backdrop" to the name of a backdrop you've defined in the scripts, but keep it within quotes.
If you want to give a backdrop to the player without any popup message or sound effect, add the silent = true argument to the command like so:
$fashion_case.backdrop_unlock("Black Fluff", silent=true)
Otherwise, $fashion_case.backdrop_unlock("Dress up") will play a jingle and display a message saying the player received that backdrop.

The following command clears out the player's fashion case, deleting all the accessories and backdrops they own:
$fashion_case.emptyFashionCase

The following command gives the player a "starter pack" of accessories and backdrops to use during Dressup:
$fashion_case.giveStarterPack

You can define what's given in this starter pack in the plugin file "01_Fashion Case\Fashion Case.rb" in the section
def giveStarterPack

###########################
#=== Reception & Stage ====
###########################
The way you start the receptionist asking what contest you want to do is ContestReception.reception
I recommend using the conditional branch I have set up on the map "Contest Reception". It detects whether you've actually entered the contest or not, and then anything within that conditional branch you can put your path to walking in the room/getting dressed/whatever you want.

You can see in the event that I transferred the player to "Contest Room", where I have an autorun event set up in the top-left corner of the map.
I transferred the player to a square on the right side of the "stage", and the autorun events scrolls the map to the left so the player is not at the center of the screen.
When I'm ready for the announcer to begin talking, I trigger this script code:
ContestStage.start

The events on this map are the trainers and their Pokemon you will face, plus the announcer, who is also the lead judge.
You don't need to change these events at all. The script handles everything for you including changing the events' graphics and move routes.
Again, this was made to mimic gen 4 contests as much as possible. If you want the announcer to say something else, or if you want something else done differently that is not handled by an event command, you'll need to edit the script files. I hope this isn't too much of a bother.

###################
#==== Dressup =====
###################
During dressup, you'll drag accessories around with the left click of the mouse, and you can drag your Pokemon around with the right click of the mouse.
The only thing different about this compared to how it worked in the gen 4 Pokemon games is that you can drag your Pokemon around.

#########################
#==== Dressup Debug =====
#########################
Let's say you want to create some opponents to face in contests. Dressup Debug is a large part of how you create them!
To call the dressup debug game, run this code:
Dressup_Debug.pbMain(:PIKACHU, "Normal")
The :PIKACHU is whatever species of Pokemon you want your opponent to be. You don't really need to change that part of the code though since in the debug game, you change change the species.
The "Normal" is the rank you want that opponent to appear in when you play. You don't really need to change this either since you can change this in the minigame as well.

Once you enter dressup debug, you'll notice it works just like the dressup minigame except:
You can click on the rank in the top left to change which rank you want the opponent to appear in.
You can click the Pokeball icon in the top middle to get a list of debug commands such as changing the Pokemon's species, shininess, form, etc.
Clicking the "Done" button asks you what you want to name the Pokemon opponent, and then it saves the file to "Graphics\Pictures\Contest\dressup\contestants\RANK"
The minigame is not exited when you click Done. That just saves the file. After you save the file, you can change the species, form, etc., change the rank, and make another contestant.
To exit the dressup debug minigame, press the BACK button.

#################################
#==== Defining a Contestant =====
#################################
Now that you've made a contestant graphic and put it in the rank you want it in, you've got to change the Contestant Settings in the script file "Contestants Settings"
Once in that file, you'll see contestants already set up by default. You'll see CONTESTANTS_RANK = [
followed by some information about the opponent:

CONTESTANTS_NORMAL = [
{TrainerName: "Sam", TrainerCharacter: "NPC 01", PkmnSpecies: :PIKACHU,
PkmnName: "Sparky", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 7, ConditionPoints: 12},

The TrainerName is the Pokemon's trainer.
The TrainerCharacter is the sprite used for the trainer from "Graphics\Characters". This determines what sprite appears for the trainer on the stage.
The following I feel is self explanatory: PkmnSpecies, PkmnName, PkmnGender, PkmnForm, PkmnShiny
Last is DressupPoints and ConditionPoints. These are the amount of points you want the contestant to score during the dressup portion. Since you get to control what accessories are placed on the contestant, it's up to you to score them. Maybe at some point in the future that will be automated with PBS or something. Who knows?

As for where to put your contestant... in CONTESTANTS_NORMAL, CONTESTANTS_GREAT, CONTESTANTS_ULTRA, or CONTESTANTS_MASTER, put the contestant in whatever rank you want, but make sure their picture in "Graphics\Pictures\Contest\dressup\contestants\RANK" is in the correct rank folder. For example, if you put a Garchomp in Master rank, make sure its sprite that's named after its PkmnName is in "Graphics\Pictures\Contest\dressup\contestants\Master"

##########################
#==== Dance Settings =====
##########################
There is little you can customize in Dance settings, but it's all explained in the file "Dance - Settings" what each setting does and how to adjust it.

###########################
#==== Acting Settings =====
###########################
There is little you can customize in Acting settings, but it's all explained in the file "Acting - Settings" what each setting does and how to adjust it.

###################################
#==== Move Effects and Appeal =====
###################################
How does the Acting portion know if a move is Cool/Smart/Tough, etc., and how does it know how much appeal the move gives or what effect the move has (like letting the user move first next round)?
The answer is the moves PBS.
I have looked up on Bulbpedia what moves are cool/smart, etc., what moves give how much appeal, and what moves have what effects.
All of these attributes of the move have been defined by flags in the moves PBS.
I have included in the plugin folder my copy of moves.txt, and inside is all (I think) moves that were in the gen 4 games.
I excluded all other moves for your sanity of looking through it for what has flags and what does not.

If you look at a move moves.txt, you'll notice flags like this:
Contest_Cool,Contest_Appeal_2,Contest_Effect_Plus2IfLast
All moves you want to define contest flags for should have these kinds of flags.

What do they do?
Contest_Cool tells the plugin that the move is a Cool move, and it will make voltage rise in Cool contests since it fits that type of contest.

##############################
#==== Contest Type Flags =====
##############################
Here are the possible Contest TYPE flags:
Contest_Cool
Contest_Beauty
Contest_Smart
Contest_Cute
Contest_Tough

Any move without one of these flags will be handled by the plugin as a COOL move.

################################
#==== Contest Appeal Flags =====
################################
The next flag in the set of examples above is Contest_Appeal_2
Contest_Appeal_# tells the plugin how much appeal the move gives.
Contest_Appeal_0 gives no appeal hearts (used for moves with powerful effects usually)
Contest_Appeal_1 gives 1 appeal heart
Contest_Appeal_2 gives 2 appeal hearts
Contest_Appeal_3 gives 3 appeal hearts

Any move without one of these flags will be handled by the plugin as a having 1 appeal.

################################
#==== Contest Effect Flags =====
################################
The next flag in the set of examples above is Contest_Effect_Plus2IfLast
Contest_Effect_... tells the plugin what effect the move should have during the Acting portion.
All possible move effect flags are listed in "def self.getEffect(move, requestedVar)" in the script file "Acting - Helping Methods"

If you want to add any custom effects, go for it!
Any moves without an effect flag defined do nothing, and the description on the move during the Acting portion will say "A basic act."
Any moves with the effect flag Contest_Effect_Basic will do nothing, and the description on the move during the Acting portion will say "A basic act."

#####################################
#=== Reception & Stage Continued ====
#####################################
Once the player goes through all the competitions, they will be back on the stage, where the winner is announced.
If the player wins, the Pokemon they entered will win a ribbon. The ribbon received depends on the contest type and rank you entered and what ribbon you put in "02_Reception and Stage\General Settings" as the ribbon to be awarded from that contest type and rank.

Once the ribbon is awarded and the announcer says his words, the event commands in the autorun event after the script code "ContestStage.start" will run.
In my example map, I transfer the player back to the reception area and award the player with an accessory and a backdrop to use in the Dressup competition.
You can do whatever you want here. I assume you would want to make conditional branches to give the player rewards based on something.
Currently there is nothing in the plugin that handles giving out prizes based on performance, the contest you just participated in, whether you won, etc.
If that's something people want, I'd be happy to include it!

##################################
#=== Previous Contest Winners ====
##################################
I've included in the map for Reception an event where you can select a contest TYPE and RANK and see who last won that contest.
The idea is that you can have a picture hanging on a wall in your contest hall to allow the player to feel like they're showing off filling up the wall with their name and Pokemon.
The event can show the Pokemon who won the last contest the player participated in as well.
Please study that event and what script is called if you're interested in having something like this.
In that event is every possible script call for showing the winners.

The following command clears out all saved winners such as the last Pokemon to win a contest and the last Pokemon to win a specific contest:
Contest_Save_Data.new