module ContestSettings

#========================================================#
#================== ACTING COMPETITION ==================#
#========================================================#
#this is where you define the 3 judges for the acting competition including
#their names and sprites
#the judges appear from left to right with the lead judge in the center, so the
#judge defined second (in the middle of the array below) will be the lead judge
#syntax:
#{Name: "Judge Name", Sprite: "Sprite to Use in Graphics/Characters"}

JUDGES = [
{Name: "Lupe", Sprite: "trainer_COOLTRAINER_M"},
{Name: "Salvador", Sprite: "trainer_GENTLEMAN"},
{Name: "Graciela", Sprite: "trainer_LADY"}
]

#the amount to shift the judge sprites left/right/up/down
#judge on the left side
OFFSET_JUDGE_LEFT_X = 16
OFFSET_JUDGE_LEFT_Y = 18

#judge in the center, lead judge
OFFSET_JUDGE_CENTER_X = 0
OFFSET_JUDGE_CENTER_Y = 18

#judge on the right side
OFFSET_JUDGE_RIGHT_X = 16
OFFSET_JUDGE_RIGHT_Y = 18

#percentage the opponents avoid choosing the same judge as the player
JUDGE_AVOIDANCE_NORMAL = 90 #out of 100 percent
JUDGE_AVOIDANCE_GREAT  = 50 #out of 100 percent
JUDGE_AVOIDANCE_ULTRA  = 20 #out of 100 percent
JUDGE_AVOIDANCE_MASTER = 00 #out of 100 percent

end #module ContestSettings