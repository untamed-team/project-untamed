class CrustangRacingSettings
#========================================================#
#=================== GENERAL SETTINGS ===================#
#========================================================#
TOP_BASE_SPEED = 12
SECONDS_TO_NORMALIZE_SPEED = 5
BASE_STRAFE_SPEED = 6
SLOWED_STRAFE_SPEED = 4
KPH_MULTIPLIER = 10

#========================================================#
#================= CONTESTANTS SETTINGS =================#
#========================================================#
CONTESTANTS = [
{TrainerName: "Sam", TrainerCharacter: "NPC 01", PkmnName: "Sparky"},
{TrainerName: "Luis", TrainerCharacter: "NPC 02", PkmnName: "Webster"},
{TrainerName: "Trevor", TrainerCharacter: "NPC 03", PkmnName: "Snake"},
{TrainerName: "Maxine", TrainerCharacter: "NPC 04", PkmnName: "Polly"},
]

#========================================================#
#==================== BUTTON SETTINGS ====================#
#========================================================#
BOOST_BUTTON_COOLDOWN_SECONDS = 20
BOOST_BUTTON = Input::SPECIAL
BOOST_LENGTH_SECONDS = 3
BOOST_SPEED = 18

#========================================================#
#==================== MOVE SETTINGS ====================#
#========================================================#
MOVE_BUTTON_COOLDOWN_SECONDS = 20
MOVE1_BUTTON = :Z
MOVE2_BUTTON = :X
MOVE3_BUTTON = :C
MOVE4_BUTTON = :V

#========================================================#
#===================== MOVE EFFECTS =====================#
#========================================================#
MOVE_EFFECTS = {
invincible:      {EffectName: "Invincible", EffectCode: "Invincible", Description: "Gain invincibility. The next obstacle that hits you does not affect you."},
spinOut:         {EffectName: "", EffectCode: "SpinOut", Description: "Racers around you spin out, slowing them down temporarily."},
burrow:          {EffectName: "Burrow", EffectCode: "Burrow", Description: "Go underground for a set amount of time. Avoid potentially multiple obstacles."}, #more OP than gain invincibility
speedUpTarget:   {EffectName: "Speed Up", EffectCode: "SpeedUpTarget", Description: "Speed up a target racer, making them more likely to hit obstacles."},
reduceCooldown:  {EffectName: "Reduce Cooldown", EffectCode: "ReduceCooldown", Description: "Move cooldowns are reduced by half for 3 uses."}, #a secondary boost that has a separate recharge than the primary boost action
secondBoost:     {EffectName: "Second Boost", EffectCode: "SecondBoost", Description: "Gain a little speed for a short time."},
rockHazard:      {EffectName: "Rock Hazard", EffectCode: "RockHazard", Description: "Place a hazard where you are, leaving it behind for another racer to hit."}, #put a hazard on the screen where you are, leaving it behind. It stays there until someone hits it. This is like a rock that causes someone to spin out if they hit it. This one you leave where you are when triggered
mudHazard:       {EffectName: "Mud Hazard", EffectCode: "MudHazard", Description: "Place a mud pit where you are, leaving it behind for another racer to hit."}, #put a mud pit on the screen where you are, leaving it behind. It stays there for a set amount of time and is slightly larger than rock hazards
push:            {EffectName: "Push", EffectCode: "Push", Description: "Push racers nearby further away from you."}, #push enemies away to your left or right (up or down)
destroyObstacle: {EffectName: "Destroy Obstacle", EffectCode: "DestroyObstacle", Description: "Destory an obstacle in front of you."}, #destroy obstacle - not as good as invincibility because this just gets rid of an obstacle in front of you
}
end #class CrustangRacingSettings