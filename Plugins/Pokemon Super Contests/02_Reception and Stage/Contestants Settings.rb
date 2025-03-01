class ContestantSettings
  
#========================================================#
#================= CONTESTANTS SETTINGS =================#
#========================================================#
#the syntax for the CONTESTANTS_RANK arrays below are as follows:
#CONTESTANTS_NORMAL = [
#["TRAINER NAME", "CHARACTER SPRITE", :SPECIES, "POKEMON NAME", POINTS FROM DRESSUP, POINTS FROM CONDITION, [MOVE1, MOVE2, MOVE3, MOVE4]]
#]

#each contestant will use the graphic named after whatever the contestant's name
#is in the array
#so if we have [:PIKACHU, "Sparky"] in the CONTESTANT_PKMN_NORMAL array, that
#contestant will use the graphic "Graphics/Pictures/Contest/dressup/contestants/Normal/Sparky.png"
#at the end of dressup when contestants are revealed for judging by the crowd

#dressup hearts chart (pink hearts)
#Rank	               # of hearts
#             0	  1	    2	    3	    4
#Normal Rank	0	1-2	  3-4	  5-7	 8-10
#Great Rank	  0	1-4	  5-9	10-14	15-20
#Ultra Rank	  0	1-6	 7-14	15-22	23-30
#Master Rank	0	1-9	10-19	20-29	30-40


#condition hearts chart (red hearts)
#Rank	                   # of hearts
#             0	  1	  2	  3	  4	  5	  6	  7	  8
#Normal Rank	0	 10	 20	 30	 40	 50	 60	 70	 80
#Great Rank	  0	 90	110	130	150	170	190	210	230
#Ultra Rank	  0	170	200	230	260	290	320	350	380
#Master Rank	0	320	360	400	440	480	520	560	600

#points at the end of the contest will not be counted by how many hearts each
#contestant receives. The hearts chart just explains how many you can expect to
#pop up given how many points you want to award each pokemon for their condition

#lastly, you must assign moves to each of the contestant Pokemon
#these moves will be used during the acting competition
#choose your moves wisely based on what effects you give those moves

#===================== NORMAL RANK CONTESTANTS =====================#
CONTESTANTS_NORMAL = [
{TrainerName: "Sam", TrainerCharacter: "NPC 26", PkmnSpecies: :FLABEBE,
PkmnName: "Bebbe", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 7, ConditionPoints: 12},

{TrainerName: "Luis", TrainerCharacter: "NPC 02", PkmnSpecies: :CHICATTA,
PkmnName: "Carly", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 4, ConditionPoints: 18},

{TrainerName: "Trevor", TrainerCharacter: "NPC 03", PkmnSpecies: :DRILBUR,
PkmnName: "David", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 2, ConditionPoints: 19},

{TrainerName: "Maxine", TrainerCharacter: "NPC 04", PkmnSpecies: :FINNEON,
PkmnName: "Dory", PkmnGender: 1, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 5, ConditionPoints: 8},

{TrainerName: "Dalid", TrainerCharacter: "NPC 05", PkmnSpecies: :LEDYBA,
PkmnName: "Lady", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 7, ConditionPoints: 12},

{TrainerName: "Thomas", TrainerCharacter: "NPC 06", PkmnSpecies: :SUNKERN,
PkmnName: "Lilly", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 4, ConditionPoints: 18},

{TrainerName: "Bruno", TrainerCharacter: "NPC 10", PkmnSpecies: :MINIMELO,
PkmnName: "Minimo", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 2, ConditionPoints: 19},

{TrainerName: "Jillian", TrainerCharacter: "NPC 11", PkmnSpecies: :PACUNA,
PkmnName: "Pachi", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 5, ConditionPoints: 8},

{TrainerName: "Juan", TrainerCharacter: "NPC 13", PkmnSpecies: :WRENNER,
PkmnName: "Rickard", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 7, ConditionPoints: 12},

{TrainerName: "Vivian", TrainerCharacter: "NPC 14", PkmnSpecies: :EKANS,
PkmnName: "Snake", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 4, ConditionPoints: 18},

{TrainerName: "Leonard", TrainerCharacter: "NPC 25", PkmnSpecies: :EEVEE,
PkmnName: "Sweetie", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 2, ConditionPoints: 19},
]

CONTESTANTS_GREAT = [
{TrainerName: "Sam", TrainerCharacter: "NPC 26", PkmnSpecies: :M_ROSELIA,
PkmnName: "Butter", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 20, ConditionPoints: 150},

{TrainerName: "Luis", TrainerCharacter: "NPC 02", PkmnSpecies: :PORYGON,
PkmnName: "Eugene", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 16, ConditionPoints: 128},

{TrainerName: "Trevor", TrainerCharacter: "NPC 03", PkmnSpecies: :ARBOK,
PkmnName: "Kobra", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 12, ConditionPoints: 114},

{TrainerName: "Maxine", TrainerCharacter: "NPC 04", PkmnSpecies: :UMBREON,
PkmnName: "Lord Dark", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 10, ConditionPoints: 136},

{TrainerName: "Dalid", TrainerCharacter: "NPC 05", PkmnSpecies: :LAGUNA,
PkmnName: "Mochi", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 20, ConditionPoints: 150},

{TrainerName: "Thomas", TrainerCharacter: "NPC 06", PkmnSpecies: :WHISCASH,
PkmnName: "Muddy", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 16, ConditionPoints: 128},

{TrainerName: "Bruno", TrainerCharacter: "NPC 10", PkmnSpecies: :NOCTAVISPA,
PkmnName: "Noct", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 12, ConditionPoints: 114},

{TrainerName: "Jillian", TrainerCharacter: "NPC 11", PkmnSpecies: :AVEOR,
PkmnName: "Rickard", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 10, ConditionPoints: 136},

{TrainerName: "Juan", TrainerCharacter: "NPC 13", PkmnSpecies: :VAPOREON,
PkmnName: "Salsa", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 20, ConditionPoints: 150},
]

CONTESTANTS_ULTRA = [
{TrainerName: "Sam", TrainerCharacter: "NPC 26", PkmnSpecies: :HONCHKROW,
PkmnName: "Boss", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 30, ConditionPoints: 320},

{TrainerName: "Luis", TrainerCharacter: "NPC 02", PkmnSpecies: :BLAZEA,
PkmnName: "Corn", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 24, ConditionPoints: 290},

{TrainerName: "Trevor", TrainerCharacter: "NPC 03", PkmnSpecies: :LUPACABRA,
PkmnName: "George", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 18, ConditionPoints: 270},

{TrainerName: "Maxine", TrainerCharacter: "NPC 04", PkmnSpecies: :GLACEON,
PkmnName: "Ice-cream", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 15, ConditionPoints: 300},

{TrainerName: "Dalid", TrainerCharacter: "NPC 05", PkmnSpecies: :LEAFEON,
PkmnName: "Leafy", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 30, ConditionPoints: 320},

{TrainerName: "Thomas", TrainerCharacter: "NPC 06", PkmnSpecies: :ESPEON,
PkmnName: "Lollipop", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 24, ConditionPoints: 290},

{TrainerName: "Bruno", TrainerCharacter: "NPC 10", PkmnSpecies: :ROADRAPTOR,
PkmnName: "Rickard", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 18, ConditionPoints: 270},

{TrainerName: "Jillian", TrainerCharacter: "NPC 11", PkmnSpecies: :EEVEE,
PkmnName: "Sandwich", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 15, ConditionPoints: 300},
]

CONTESTANTS_MASTER = [
{TrainerName: "Sam", TrainerCharacter: "NPC 26", PkmnSpecies: :LUDICOLO,
PkmnName: "Luve", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 40, ConditionPoints: 600},

{TrainerName: "Luis", TrainerCharacter: "NPC 02", PkmnSpecies: :DELCATTY,
PkmnName: "Majesty", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 32, ConditionPoints: 580},

{TrainerName: "Trevor", TrainerCharacter: "NPC 03", PkmnSpecies: :MILOTIC,
PkmnName: "Milo", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 24, ConditionPoints: 596},

{TrainerName: "Maxine", TrainerCharacter: "NPC 04", PkmnSpecies: :TROPIUS,
PkmnName: "Mr. Flowy", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 20, ConditionPoints: 540},

{TrainerName: "Dalid", TrainerCharacter: "NPC 05", PkmnSpecies: :M_ROSERADE,
PkmnName: "Skully", PkmnGender: 1, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 24, ConditionPoints: 596},

{TrainerName: "Thomas", TrainerCharacter: "NPC 06", PkmnSpecies: :NINETALES,
PkmnName: "Spot", PkmnGender: 0, PkmnForm: 0, PkmnShiny: false,
DressupPoints: 20, ConditionPoints: 540},
]

end #class ContestantSettings