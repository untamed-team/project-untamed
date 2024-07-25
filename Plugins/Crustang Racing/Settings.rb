class CrustangRacingSettings
#========================================================#
#=================== GENERAL SETTINGS ===================#
#========================================================#
TOP_BASE_SPEED = 10
SECONDS_TO_NORMALIZE_SPEED = 5
BASE_STRAFE_SPEED = 8
BOOSTED_STRAFE_SPEED = 10
KPH_MULTIPLIER = 5
COLLISION_SE = "Battle damage weak"
SECONDS_TO_RECOVER_FROM_BUMP = 2
ROCK_COLLISION_SE = "Rock Smash"
MUD_COLLISION_SE = "Anim/PRSFX- Sandstorm"

#========================================================#
#==================== BOOST SETTINGS ====================#
#========================================================#
BOOST_BUTTON_COOLDOWN_SECONDS = 20
BOOST_BUTTON = Input::SPECIAL
BOOST_LENGTH_SECONDS = 3
BOOST_SPEED = 16
SECONDS_TO_REACH_BOOST_SPEED = 3
SECONDARY_BOOST_SPEED = 15

#========================================================#
#==================== MOVE SETTINGS ====================#
#========================================================#
MOVE_BUTTON_COOLDOWN_SECONDS = 20
MOVE1_BUTTON = :Z
MOVE2_BUTTON = :X
MOVE3_BUTTON = :C
MOVE4_BUTTON = :V

SPINOUT_MIN_RANGE = 70
SPINOUT_MAX_RANGE = 200
SPINOUT_OUTLINE_WIDTH = 6
SPINOUT_ROTATIONS_PER_SECOND = 2
SPINOUT_DURATION_IN_SECONDS = 3
SPINOUT_DESIRED_SPEED = 8

INVINCIBLE_UNTIL_HIT = false
INVINCIBILITY_DURATION_SECONDS = 10

OVERLOAD_MIN_RANGE = 70
OVERLOAD_MAX_RANGE = 200
OVERLOAD_OUTLINE_WIDTH = 6
OVERLOAD_DURATION_IN_SECONDS = 5
OVERLOADED_STRAFE_SPEED = 4

#========================================================#
#===================== MOVE EFFECTS =====================#
#========================================================#
MOVE_EFFECTS = {
invincible:      {EffectName: "Invincible", EffectCode: "invincible", Description: "Gain invincibility. The next obstacle that hits you does not affect you.", AssignedMoves: [:IRONDEFENSE, :PROTECT, :SUBSTITUTE, :DIG],}, #does not stack if you get to use again before hitting something

#spinOut:         {EffectName: "Spin Out", EffectCode: "spinOut", Description: "Racers around you spin out, slowing them down temporarily.", AssignedMoves: [:LEER, :BULLDOZE, :EARTHQUAKE, :THUNDERWAVE, :BRUTALSWING, :SCREECH],},

spinOut:         {EffectName: "Spin Out", EffectCode: "spinOut", Description: "Racers around you spin out, slowing them down temporarily.", AssignedMoves: [:LEER, :BULLDOZE, :EARTHQUAKE, :THUNDERWAVE, :BRUTALSWING, :SCREECH, :SEISMICTOSS, :EXPLOSION, :PURSUIT, :UTURN, :FLAMECHARGE, :SNARL, :VISEGRIP, :CRABHAMMER, :IRONHEAD, :HEAVYSLAM, :CUT, :STRENGTH, :METALCLAW, :RETURN, :BRICKBREAK, :FLASHCANNON, :BODYPRESS, :BODYSLAM, :XSCISSOR, :SUPERPOWER],},

overload:   {EffectName: "Overload", EffectCode: "overload", Description: "Burden racers around you, decreasing their ability to strafe quickly.", AssignedMoves: [:HELPINGHAND, :SWAGGER, :TAUNT, :FOULPLAY],},

reduceCooldown:  {EffectName: "Reduce Cooldown", EffectCode: "reduceCooldown", Description: "Move cooldowns are reduced by half for 3 uses.", AssignedMoves: [:REST, :SLEEPTALK, :SWORDSDANCE, :FALSESWIPE],}, #a secondary boost that has a separate recharge than the primary boost action

secondBoost:     {EffectName: "Second Boost", EffectCode: "secondBoost", Description: "Gain a little speed for a short time.", AssignedMoves: [:RAPIDSPIN, :FLAMEWHEEL, :HIGHHORSEPOWER, :SHIFTGEAR, :HONECLAWS, :WORKUP],},

rockHazard:      {EffectName: "Rock Hazard", EffectCode: "rockHazard", Description: "Place a hazard where you are, leaving it behind for another racer to hit.", AssignedMoves: [:ROCKTOMB, :ROCKSLIDE, :STONEEDGE, :STEALTHROCK],}, #put a hazard on the screen where you are, leaving it behind. It stays there until someone hits it. This is like a rock that causes someone to spin out if they hit it. This one you leave where you are when triggered

mudHazard:       {EffectName: "Mud Hazard", EffectCode: "mudHazard", Description: "Place a mud pit where you are, leaving it behind for another racer to hit.", AssignedMoves: [:MUDSLAP, :MUDBOMB, :SANDSTORM, :SCORCHINGSANDS],}, #put a mud pit on the screen where you are, leaving it behind. It stays there for a set amount of time and is slightly larger than rock hazards

###########push:            {EffectName: "Push", EffectCode: "push", Description: "Push racers nearby further away to your left or right.", AssignedMoves: [:SEISMICTOSS, :EXPLOSION, :PURSUIT, :UTURN, :FLAMECHARGE, :SNARL],}, #push enemies away to your left or right (up or down)

###########destroyObstacle: {EffectName: "Destroy Obstacle", EffectCode: "destroyObstacle", Description: "Destory an obstacle in front of you.", AssignedMoves: [:VISEGRIP, :CRABHAMMER, :IRONHEAD, :HEAVYSLAM, :CUT, :STRENGTH, :METALCLAW, :RETURN, :BRICKBREAK, :FLASHCANNON, :BODYPRESS, :BODYSLAM, :XSCISSOR, :SUPERPOWER],}, #destroy obstacle - not as good as invincibility because this just gets rid of an obstacle in front of you
}

#========================================================#
#================= CONTESTANTS SETTINGS =================#
#========================================================#
CONTESTANTS = [
{TrainerName: "Sam", TrainerCharacter: "NPC 01", PkmnName: "King Crab", Moves: [:VISEGRIP, :IRONDEFENSE, :HELPINGHAND]}, #gives: spinOut, invincible, overload
{TrainerName: "Luis", TrainerCharacter: "NPC 02", PkmnName: "Santa Claws", Moves: [:ROCKTOMB, :RAPIDSPIN, :HELPINGHAND]}, #gives: rockHazard, secondBoost, overload
{TrainerName: "Trevor", TrainerCharacter: "NPC 03", PkmnName: "Crusty", Moves: [:VISEGRIP, :REST, :MUDSLAP]}, #gives: spinOut, reduceCooldown, mudHazard
]

#========================================================#
#=============== RENTAL CRUSTANG SETTINGS ===============#
#========================================================#
RENTABLE_CRUSTANG = [
{TrainerName: "Rental Ron", PkmnName: "MsJeavious", Moves: [:VISEGRIP, :IRONDEFENSE, :HELPINGHAND]}, #gives: spinOut, invincible, overload
{TrainerName: "Rental Ron", PkmnName: "Mister Crab", Moves: [:ROCKTOMB, :RAPIDSPIN, :HELPINGHAND]}, #gives: rockHazard, secondBoost, overload
{TrainerName: "Rental Ron", PkmnName: "Striker", Moves: [:VISEGRIP, :REST, :MUDSLAP]}, #gives: spinOut, reduceCooldown, mudHazard
]

end #class CrustangRacingSettings
