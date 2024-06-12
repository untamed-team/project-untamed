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
MOVE1_BUTTON = Input.triggerex?(:Z)
MOVE2_BUTTON = Input.triggerex?(:X)
MOVE3_BUTTON = Input.triggerex?(:C)
MOVE4_BUTTON = Input.triggerex?(:V)

end #class CrustangRacingSettings