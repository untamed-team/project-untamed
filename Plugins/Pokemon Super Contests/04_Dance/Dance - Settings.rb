module ContestSettings

#========================================================#
#================== DANCE COMPETITION ==================#
#========================================================#
#chance the AI dancers land an excellent, good, or miss on the respective rank
#chances are out of 100
#example: 'NORMAL_CHANCE_DANCE_TIMING_EXCELLENT = 15' would give a 15% chance of
#landing an excellent on normal rank
#make sure all of the percentages for excellent and good add up to something
#less than or equal to 100!
#the chance to miss is 100 minus chance of excellent minus chance of good
#example: if excellent chance is 20 and good chance is 70, all that is left of
#100 is 10, so there will be a 10% chance to miss

#NORMAL_CHANCE_DANCE_DIRECTION_CORRECT = 70 will give the AI a 70% chance to get
#the direction of the move correct. For example, if the AI is unlucky and gets
#the 30% chance and gets the direction incorrect, they will dance front, left,
#or right instead of jumping
#The direction correct chance is separate from timing

NORMAL_CHANCE_DANCE_TIMING_EXCELLENT  = 10
NORMAL_CHANCE_DANCE_TIMING_GOOD       = 70
NORMAL_CHANCE_DANCE_DIRECTION_CORRECT = 80

GREAT_CHANCE_DANCE_TIMING_EXCELLENT  = 35
GREAT_CHANCE_DANCE_TIMING_GOOD       = 50
GREAT_CHANCE_DANCE_DIRECTION_CORRECT = 85

ULTRA_CHANCE_DANCE_TIMING_EXCELLENT  = 60
ULTRA_CHANCE_DANCE_TIMING_GOOD       = 30
ULTRA_CHANCE_DANCE_DIRECTION_CORRECT = 90

MASTER_CHANCE_DANCE_TIMING_EXCELLENT  = 80
MASTER_CHANCE_DANCE_TIMING_GOOD       = 15
MASTER_CHANCE_DANCE_DIRECTION_CORRECT = 95

#the chance the lead dancer AI will choose moves right after the other in rapid
#succession in an attempt to mess the player up
#if the dice roll is unsuccessful, it is random what move is chosen, and the AI
#might still choose moves close to each other
#a successful dice roll just guarantees a move will be chosen right after
#another
#chance is out of 100
#to make it truly random, put the value at 0
NORMAL_CHANCE_MOVE_RAPID_SUCCESSION = 20
GREAT_CHANCE_MOVE_RAPID_SUCCESSION  = 40
ULTRA_CHANCE_MOVE_RAPID_SUCCESSION  = 60
MASTER_CHANCE_MOVE_RAPID_SUCCESSION = 80

#the chance the lead dancer AI will choose a move close to the beginning or end
#of the track in an attempt to mess up the player
#when a move is placed at the left-most possible position on the track or at the
#right-most possible position on the track, the player nearly has to be
#frame-perfect not to miss that
#if the dice roll is unsuccessful, it is random when is chosen (aside from
#choosing a move in rapid succession), and the AI might still choose moves close
#to the beginning or end of the track
#a successful dice roll just guarantees a move will be chosen at the beginning
#or end of the track
#chance is out of 100
#to make it truly random, put the value at 0
#this can clash with "CHANCE_MOVE_RAPID_SUCCESSION", so this will apply to only
#one move
NORMAL_CHANCE_MOVE_AT_BEGINNING_OR_END = 10
GREAT_CHANCE_MOVE_AT_BEGINNING_OR_END  = 30
ULTRA_CHANCE_MOVE_AT_BEGINNING_OR_END  = 60
MASTER_CHANCE_MOVE_AT_BEGINNING_OR_END = 80

#the chance the lead dancer AI will choose different kinds of moves to mess up
#the player
#example: "Jump, Front, Right" would be more difficult for the player to follow
#than "Jump, Jump, Jump"
#chance is out of 100
#to make it truly random, put the value at 0
NORMAL_CHANCE_NEXT_MOVE_DIFFERENT = 20
GREAT_CHANCE_NEXT_MOVE_DIFFERENT  = 40
ULTRA_CHANCE_NEXT_MOVE_DIFFERENT  = 60
MASTER_CHANCE_NEXT_MOVE_DIFFERENT = 80

end #module ContestSettings