=begin
Formatting for the quests:
Technically you can put the components in any order you'd like,
but please keep them in this order for readability's sake
  QuestX = {
    :ID => "X"                                                # Quest's ID number, should be a string with the same value as the Quest #
    :Name => "Quest"                                          # The actual name of the quest that gets displayed in the UI
    :QuestGiver => "NPC"                                      # The name of the NPC you receive the quest from
    :QuestGiverSprite => "NPC Dad"                            # The name of the file in Graphics/Characters to appear next to the quest name. The sprite used for the quest giver
    :QuestGiverDescSprite => "COOLTRAINER_M"                  # The name of the file in Graphics/Trainers to appear next to the quest description. The sprite used for the quest giver in the quest description
    :StageY => "Do something"                                 # The DESCRIPTION for each stage of the quest (you can have as many stages as 
    :TurninConditionY => proc { $player.has_species?(:PIKACHU) }, #The CONDITION under which you want the quest to be automatically detected as available for TURNIN at stage Y. Copy and paste ":TurninCondition1 => proc { $player.has_species?(:PIKACHU) }", and only change what is inside the curly braces { }
    .                                                         # you'd like), must fit in 1 line of text
    :TaskZ => ["Do a smaller something", Y, false]            # A sub-objective of Stage Y (follows the data's numeration), THE LAST VALUE 
    .                                                         # MUST ALWAYS BE FALSE (it will be set to true only in the player's active
    .                                                         # quest data, by methods)
    :LocationW => "Somewhere"                                 # The location for a given stage, try to keep these informative so the player 
    .                                                         # knows where to go. You do NOT have to define a location for a stage if you 
    .                                                         # don't want to, in which case it will show up as ??? in the UI 
    :QuestDescription => "Here's why you're doing something"  # The description for the entire quest. This is what's seen in the first page 
                                                              # of the UI, and can take up almost a full page
    :ReadyAtStart =>                                          #if true, the quest will be ready to give out by its NPC when the game starts

###############################################################
Methods to use in events and such:

activateQuest(quest,color=colorQuest(nil),story=false)
  -> Activates the quest with the specified quest ID, picks the display color
     for the UI, and marks whether or not it's story-related
  -> quest is the quest ACCESSOR, not number or name. So you'd use
     activateQuest(:Quest5) to activate quest #5
  -> As shown above, you do not need to put anything in the color and story
     fields if you don't need to

completeQuest(quest,color=colorQuest(nil),story=false)
  -> Completes the quest with the specified quest ID , modifying its color
     and story relevance if necessary
  -> If the quest was active, it's removed from the player's active quests
  -> As with activateQuest, you do not need to put anything in the color and 
     story fields if you don't need to
  
def failQuest(quest,color=nil,story=false)
  -> Marks the specified quest as failed, modifying its color and story 
     relevance if necessary
  -> If the quest was active, it's removed from the player's active quests
  -> As with activateQuest, you do not need to put anything in the color and 
     story fields if you don't need to
  
def advanceQuestToStage(quest,stageNum,color=nil,story=false)
  -> Moves the specified quest to the specified stage number
  -> Unlike "quest", "stageNum" here is an integer, equal to the number of the
     desired stage (the number that comes after the accessor of :StageX)
  -> It's called "advanceQuest", but it can be used to move to a lower stage 
     if needed (though you should probably try to avoid this)
  -> As with activateQuest, you do not need to put anything in the color and 
     story fields if you don't need to

def markQuestTaskComplete(quest,task,complete=true,color=nil,story=false)
  -> Marks the specified task for the specified quest as complete 
     (complete = true) or incomplete (complete = false)
  -> If you only enter the quest ID and task #, the task will be marked as
     complete. If you wish to mark it as incomplete, put false (as a boolean
     value, not a string) into the "complete" field
  -> Unlike "quest", "task" here is an integer, equal to the number of the
     desired task (the number that comes after the accessor of :TaskX)
  -> As with activateQuest, you do not need to put anything in the color and 
     story fields if you don't need to
  
=end

module QuestModule
  # You don't actually need to add any information, but the respective fields in the UI will be blank or "???"
  # I included this here mostly as an example of what not to do, but also to show it's a thing that exists
  Quest1 = {
    :ID => "1",
    :Name => "Saying Goodbye",
    :QuestGiver => "Dad",
    :QuestGiverSprite => "NPC DAD",
    :QuestGiverDescSprite => "DAD",
    :Stage1 => "Meet with Professor Ceiba.",
    :Stage2 => "Bring the Pokémon to Professor Ceiba's lab.",
    :Location1 => "Veravalles Town",
    :Location2 => "Professor Ceiba's Lab",
    :QuestDescription => "Say goodbye to Professor Ceiba's Pokémon.",
    :RewardString => "Main Story",
  }
  Quest2 = {
    :ID => "2",
    :Name => "Victory Road",
    :QuestGiver => "Professor Ceiba",
    :QuestGiverSprite => "trainer_PROFESSOR",
    :QuestGiverDescSprite => "CEIBA",
    :Stage1 => "Defeat the gym in San Cerigold Town.",
    :Stage2 => "Defeat the gym in Calojarro.",
    :Stage3 => "Defeat the gym in Ferrera Town.",
    :Location1 => "San Cerigold Town",
    :Location2 => "Calojarro",
    :Location3 => "Ferrera Town",
    :QuestDescription => "Defeat all gyms in the Mazah Region.",
    :RewardString => "Adventure!",
    }
  Quest3 = {
    :ID => "3",
    :Name => "Stolen Invention Plans",
    :QuestGiver => "Scientist Curtis",
    :QuestGiverSprite => "NPC CropMaster",
    :QuestGiverDescSprite => "SCIENTIST_M3",
    :Stage1 => "Find the thieves who stole the plans.",
    :Stage2 => "Retrieve the plans from the crop field.",
    :Stage3 => "Return the plans to Scientist Curtis.",
    :Location1 => "Hacienda",
    :Location2 => "Hacienda Fields",
    :Location3 => "Route 1",
    :QuestDescription => "Find the stolen CropMaster plans.",
    :RewardString => "Adventure!",
  }
  Quest4 = {
    :ID => "4",
    :Name => "A Hungry Visitor",
    :QuestGiver => "Farmer Julio",
    :QuestGiverSprite => "NPC Farmer 3",
    :QuestGiverDescSprite => "FARMER",
    :Stage1 => "Investigate the crop field.",
    :Stage2 => "Tell Julio what you found.",
    :Location1 => "Hacienda Fields",
    :Location2 => "Hacienda",
    :QuestDescription => "Our crops have been disappearing. Find out what happened to the food!",
    :RewardString => "$200, Protein",
    :ReadyAtStart => true,
  }
  Quest5 = {
    :ID => "5",
    :Name => "A New Friend",
    :QuestGiver => "Farmer Gabriel",
    :QuestGiverSprite => "NPC Farmer",
    :QuestGiverDescSprite => "FARMER",
    :Stage1 => "Gift a Pumpkaboo to Farmer Gabriel.",
    :Location1 => "Hacienda Fields",
    :QuestDescription => "Gift a Pumpkaboo to Farmer Gabriel.",
    :RewardString => "$300",
    :ReadyAtStart => true,
  }
  Quest6 = {
    :ID => "6",
    :Name => "An Electrifying Feeling",
    :QuestGiver => "Coffee Enthusiast Matteo",
    :QuestGiverSprite => "NPC 25",
    :QuestGiverDescSprite => "STRIKER",
    :Stage1 => "Show Matteo a Cafécaracha",
    :Location1 => "San Cerigold Town",
    :QuestDescription => "Matteo wants to see a Cafécaracha since they're apparently packed full of energy.",
    :RewardString => "Electric Seed",
    :ReadyAtStart => true,
  }
  Quest7 = {
    :ID => "7",
    :Name => "Who Let the Dog out?",
    :QuestGiver => "Jacobo",
    :QuestGiverSprite => "trainer_OLDMAN",
    :QuestGiverDescSprite => "GENTLEMAN",
    :Stage1 => "Search for Scamp around water.",
    :Stage2 => "Search for Scamp in Route 2.",
    :Stage3 => "Search for Scamp in Calojarro.",
    :Stage4 => "Return to Jacobo",
    :Location1 => "San Cerigold Town",
    :Location2 => "Route 2",
    :Location3 => "Calojarro",
    :Location4 => "San Cerigold Town",
    :QuestDescription => "Jacobo is missing his Techuppi, Scamp! He said Scamp likes to play in water.",
    :RewardString => "Timer Ball, $800",
    :ReadyAtStart => true,
  }
  Quest8 = {
    :ID => "8",
    :Name => "Under the Stars",
    :QuestGiver => "Alex",
    :QuestGiverSprite => "trchar019",
    :QuestGiverDescSprite => "PICNICKER",
    :RewardString => "Camping Gear",
    :Stage1 => "Camp with your Pokémon.",
    :Task1 => ["Pet your Pokémon",1,false],
    :Task2 => ["Feed your Pokémon",1,false],
    :Task3 => ["Play hide and seek",1,false],
    :Stage2 => "Return the Camping Gear to Alex.",
    :Location1 => "Camp",
    :Location1 => "Route 2",
    :QuestDescription => "Alex has loaned you her camping gear so you can experience camping with your Pokémon.",
    :ReadyAtStart => true,
  }
  Quest9 = {
    :ID => "9",
    :Name => "Ol' Rusty",
    :QuestDescription => "Beat the gold panners to earn the greatest things they've found!",
    :ReadyAtStart => true,
    :QuestGiver => "Leo",
    :QuestGiverSprite => "NPC_Gold_Panner_M",
    :QuestGiverDescSprite => "GOLDPANNER",
    :RewardString => "Something shiny!",
    :Stage1 => "Beat the three gold panners.",
    :Task1 => ["Defeat Gold Panner Leo",1,false],
    :Task2 => ["Defeat Gold Panner Martina",1,false],
    :Task3 => ["Defeat Gold Panner Amalia",1,false],
    :Location1 => "Route 3",
    :Stage2 => "Talk to Gold Panner Leo.",
    :Location2 => "Route 3",
    :Stage3 => "Take the bike pieces to a woman at the Shady Shuckle.",
    :Location3 => "Route 5",
  }
  Quest10 = {
    :ID => "10",
    :Name => "Lost Prospector",
    :QuestDescription => "A prospector has gone missing in Dorado Mine. Bring a Mingot with you to help with the search!",
    :QuestGiver => "Minerva",
    :QuestGiverSprite => "NPC_Proespector_M",
    :QuestGiverDescSprite => "PROSPECTOR",
    :Stage1 => "Find the prospector's missing brother.",
    :Location1 => "Dorado Mine",
    :RewardString => "Big Nugget",
    :ReadyAtStart => true,
  }
  Quest11 = {
    :ID => "11",
    :Name => "Raspado Enthusiasts",
    :QuestDescription => "Two tourists each need an icey treat to cool down on the beach.",
    :QuestGiver => "Jimmy",
    :QuestGiverSprite => "TOURIST 1",
    :QuestGiverDescSprite => "TOURIST_M",
    :Stage1 => "Find and bring two Melolado Cones to the tourists on the beach.",
    :TurninCondition1 => proc { $bag.has?(:MELOLADOCONE,2) },
    :Location1 => "Calojarro",
    :RewardString => "Your money back plus maybe a tip?",
    :ReadyAtStart => true,
  }
  Quest12 = {
    :ID => "12",
    :Name => "Honest Work",
    :QuestDescription => "Grandpa needs someone to help with work around the ranch.",
    :QuestGiver => "Eustace",
    :QuestGiverSprite => "NPC 18",
    :QuestGiverDescSprite => "GENTLEMAN",
    :Stage1 => "Feed Oran berries to the 5 Gogoat in the barn. Then return to Grandpa.",
    :Location1 => "Asterado Ranch",
    :Stage2 => "Clear rocks and trees from the field, and take care of the bug Pokémon. Then return to Grandpa.",
    :Location2 => "Asterado Ranch",
    :Stage3 => "Stop the K'noggin in the barn!",
    :Location3 => "Asterado Ranch",
    :Stage4 => "Talk to Grandpa in his house for your reward.",
    :Location4 => "Asterado Ranch",
    :RewardString => "Something from the ranch!",
    :ReadyAtStart => false,
  }
  Quest13 = {
    :ID => "13",
    :Name => "All that Glitters",
    :QuestDescription => "Florian saw a shiny Magikarp in Asterado Lake! He thinks using a Nugget as bait will help him fish it up.",
    :QuestGiver => "Florian",
    :QuestGiverSprite => "NPC Shiny Hunter",
    :QuestGiverDescSprite => "SHINYHUNTER_M",
    :Stage1 => "Give Florian a Nugget.",
    :Location1 => "Asterado Ranch",
    :TurninCondition1 => proc { $bag.has?(:NUGGET) },
    :RewardString => '"Good money"',
    :ReadyAtStart => true,
  }
  Quest14 = {
    :ID => "14",
    :Name => "Eeveelution Beginner",
    :QuestDescription => "Immy needs help finding out what her Eevee wants to evolve into.",
    :QuestGiver => "Immy",
    :QuestGiverSprite => "NPC_Lass",
    :QuestGiverDescSprite => "LASS4",
    :Stage1 => "Show Immy a Water or Fire-type Pokémon.",
    :Location1 => "Calojarro",
    :Stage2 => "Battle Immy with a Dark or Psychic-type Pokémon in your party.",
    :Location2 => "Calojarro",
    :Stage3 => "Show Immy a Pokémon with a powerful Ice or Grass-type move (55+ power).",
    :Location3 => "Calojarro",
    :Stage4 => "Battle Immy's siblings alongside her. Let Immy or her siblings know when you're ready.",
    :Location4 => "Calojarro",
    :Stage5 => "Find Immy and her Eevee at #{!$game_variables.nil? ? $game_variables[135] : 0}.",
    :Location5 => "#{!$game_variables.nil? ? $game_variables[135] : 0}",
    :Stage6 => "Claim your reward from Grace and Nicco at Immy's house.",
    :Location6 => "Calojarro",
    :RewardString => "Eevee",
    :ReadyAtStart => true,
  }
  # Here's the simplest example of a single-stage quest with everything specified
#  Quest1 = {
#    :ID => "1",
#    :Name => "Introductions",
#    :QuestGiver => "Little Boy",
#    :Stage1 => "Look for clues.",
#    :Location1 => "Lappet Town",
#    :QuestDescription => "Some wild Pokémon stole a little boy's favourite toy. Find those troublemakers and help him get it back.",
#    :RewardString => "Something shiny!"
#  }
  
  # Here's an extension of the above that includes multiple stages
#  Quest2 = {
#    :ID => "2",
#    :Name => "Introductions",
#    :QuestGiver => "Little Boy",
#    :Stage1 => "Look for clues.",
#    :Stage2 => "Follow the trail.",
#    :Stage3 => "Catch the troublemakers!",
#    :Location1 => "Lappet Town",
#    :Location2 => "Viridian Forest",
#    :Location3 => "Route 3",
#    :QuestDescription => "Some wild Pokémon stole a little boy's favourite toy. Find those troublemakers and help him get it back.",
#    :RewardString => "Something shiny!"
#  }
  
  # Here's an example of a quest with lots of stages that also doesn't have a stage location defined for every stage
#  Quest3 = {
#    :ID => "3",
#    :Name => "Last-minute chores",
#    :QuestGiver => "Grandma",
#    :Stage1 => "A",
#    :Stage2 => "B",
#    :Stage3 => "C",
#    :Stage4 => "D",
#    :Stage5 => "E",
#    :Stage6 => "F",
#    :Stage7 => "G",
#    :Stage8 => "H",
#    :Stage9 => "I",
#    :Stage10 => "J",
#    :Stage11 => "K",
#    :Stage12 => "L",
#    :Location1 => "nil",
#    :Location2 => "nil",
#    :Location3 => "Dewford Town",
#    :QuestDescription => "Isn't the alphabet longer than this?",
#    :RewardString => "Chicken soup!"
#  }
  
  # Here's an example of not defining the quest giver and reward text
#  Quest4 = {
#    :ID => "4",
#    :Name => "A new beginning",
#    :QuestGiver => "nil",
#    :Stage1 => "Turning over a new leaf... literally!",
#    :Stage2 => "Help your neighbours.",
#    :Location1 => "Milky Way",
#    :Location2 => "nil",
#    :QuestDescription => "You crash landed on an alien planet. There are other humans here and they look hungry...",
#    :RewardString => "nil"
#  }
  
  # Other random examples you can look at if you want to fill out the UI and check out the page scrolling
#  Quest5 = {
#    :ID => "5",
#    :Name => "All of my friends",
#    :QuestGiver => "Barry",
#    :Stage1 => "Meet your friends near Acuity Lake.",
#    :QuestDescription => "Barry told me that he saw something cool at Acuity Lake and that I should go see. I hope it's not another trick.",
#    :RewardString => "You win nothing for giving in to peer pressure."
#  }
  
#  Quest6 = {
#    :ID => "6",
#    :Name => "The journey begins",
#    :QuestGiver => "Professor Oak",
#    :Stage1 => "Deliver the parcel to the Pokémon Mart in Viridian City.",
#    :Stage2 => "Return to the Professor.",
#    :Location1 => "Viridian City",
#    :Location2 => "nil",
#    :QuestDescription => "The Professor has entrusted me with an important delivery for the Viridian City Pokémon Mart. This is my first task, best not mess it up!",
#    :RewardString => "nil"
#  }
  
#  Quest7 = {
#    :ID => "7",
#    :Name => "Close encounters of the... first kind?",
#    :QuestGiver => "nil",
#    :Stage1 => "Make contact with the strange creatures.",
#    :Location1 => "Rock Tunnel",
#    :QuestDescription => "A sudden burst of light, and then...! What are you?",
#    :RewardString => "A possible probing."
#  }
  
#  Quest8 = {
#    :ID => "8",
#    :Name => "These boots were made for walking",
#    :QuestGiver => "Musician #1",
#    :Stage1 => "Listen to the musician's, uhh, music.",
#    :Stage2 => "Find the source of the power outage.",
#    :Location1 => "nil",
#    :Location2 => "Celadon City Sewers",
#    :QuestDescription => "A musician was feeling down because he thinks no one likes his music. I should help him drum up some business."
#  }
  
#  Quest9 = {
#    :ID => "9",
#    :Name => "Got any grapes?",
#    :QuestGiver => "Duck",
#    :Stage1 => "Listen to The Duck Song.",
#    :Stage2 => "Try not to sing it all day.",
#    :Location1 => "YouTube",
#    :QuestDescription => "Let's try to revive old memes by listening to this funny song about a duck wanting grapes.",
#    :RewardString => "A loss of braincells. Hurray!"
#  }
  
#  Quest10 = {
#    :ID => "10",
#    :Name => "Singing in the rain",
#    :QuestGiver => "Some old dude",
#    :Stage1 => "I've run out of things to write.",
#    :Stage2 => "If you're reading this, I hope you have a great day!",
#    :Location1 => "Somewhere prone to rain?",
#    :QuestDescription => "Whatever you want it to be.",
#    :RewardString => "Wet clothes."
#  }
  
#  Quest11 = {
#    :ID => "11",
#    :Name => "When is this list going to end?",
#    :QuestGiver => "Me",
#    :Stage1 => "When IS this list going to end?",
#    :Stage2 => "123",
#    :Stage3 => "456",
#    :Stage4 => "789",
#    :QuestDescription => "I'm losing my sanity.",
#    :RewardString => "nil"
#  }
  
#  Quest12 = {
#    :ID => "12",
#    :Name => "The laaast melon",
#    :QuestGiver => "Some stupid dodo",
#    :Stage1 => "Fight for the last of the food.",
#    :Stage2 => "Don't die.",
#    :Location1 => "A volcano/cliff thing?",
#    :Location2 => "Good advice for life.",
#    :QuestDescription => "Tea and biscuits, anyone?",
#    :RewardString => "Food, glorious food!"
#  }

end