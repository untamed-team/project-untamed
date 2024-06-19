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
#==================== BOOST SETTINGS ====================#
#========================================================#
BOOST_BUTTON_COOLDOWN_SECONDS = 20
BOOST_BUTTON = Input::SPECIAL
BOOST_LENGTH_SECONDS = 3
BOOST_SPEED = 18
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

#========================================================#
#===================== MOVE EFFECTS =====================#
#========================================================#
MOVE_EFFECTS = {
invincible:      {EffectName: "Invincible", EffectCode: "invincible", Description: "Gain invincibility. The next obstacle that hits you does not affect you.", AssignedMoves: [:IRONDEFENSE, :PROTECT, :SUBSTITUTE, :DIG],}, #does not stack if you get to use again before hitting something

spinOut:         {EffectName: "Spin Out", EffectCode: "spinOut", Description: "Racers around you spin out, slowing them down temporarily.", AssignedMoves: [:LEER, :BULLDOZE, :EARTHQUAKE, :THUNDERWAVE, :BRUTALSWING, :SCREECH],},

speedUpTarget:   {EffectName: "Speed Up", EffectCode: "speedUpTarget", Description: "Speed up another racer around you, making them more likely to hit obstacles.", AssignedMoves: [:HELPINGHAND, :SWAGGER, :TAUNT, :FOULPLAY],},

reduceCooldown:  {EffectName: "Reduce Cooldown", EffectCode: "reduceCooldown", Description: "Move cooldowns are reduced by half for 3 uses.", AssignedMoves: [:REST, :SLEEPTALK, :SWORDSDANCE, :FALSESWIPE],}, #a secondary boost that has a separate recharge than the primary boost action

secondBoost:     {EffectName: "Second Boost", EffectCode: "secondBoost", Description: "Gain a little speed for a short time.", AssignedMoves: [:RAPIDSPIN, :FLAMEWHEEL, :HIGHHORSEPOWER, :SHIFTGEAR, :HONECLAWS, :WORKUP],},

rockHazard:      {EffectName: "Rock Hazard", EffectCode: "rockHazard", Description: "Place a hazard where you are, leaving it behind for another racer to hit.", AssignedMoves: [:ROCKTOMB, :ROCKSLIDE, :STONEEDGE, :STEALTHROCK],}, #put a hazard on the screen where you are, leaving it behind. It stays there until someone hits it. This is like a rock that causes someone to spin out if they hit it. This one you leave where you are when triggered

mudHazard:       {EffectName: "Mud Hazard", EffectCode: "mudHazard", Description: "Place a mud pit where you are, leaving it behind for another racer to hit.", AssignedMoves: [:MUDSLAP, :MUDBOMB, :SANDSTORM, :SCORCHINGSANDS],}, #put a mud pit on the screen where you are, leaving it behind. It stays there for a set amount of time and is slightly larger than rock hazards

push:            {EffectName: "Push", EffectCode: "push", Description: "Push racers nearby further away to your left or right.", AssignedMoves: [:SEISMICTOSS, :EXPLOSION, :PURSUIT, :UTURN, :FLAMECHARGE, :SNARL],}, #push enemies away to your left or right (up or down)

destroyObstacle: {EffectName: "Destroy Obstacle", EffectCode: "destroyObstacle", Description: "Destory an obstacle in front of you.", AssignedMoves: [:VISEGRIP, :CRABHAMMER, :IRONHEAD, :HEAVYSLAM, :CUT, :STRENGTH, :METALCLAW, :RETURN, :BRICKBREAK, :FLASHCANNON, :BODYPRESS, :BODYSLAM, :XSCISSOR, :SUPERPOWER],}, #destroy obstacle - not as good as invincibility because this just gets rid of an obstacle in front of you
}
end #class CrustangRacingSettings