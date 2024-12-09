def process_tutor_moves(referential_moves):
    while True:
        # Get user input for TutorMoves
        user_input = input("Enter the list of TutorMoves separated by commas (or type 'exit' to quit): ")
        
        if user_input.lower() == 'exit':
            break
        
        tutor_moves = [move.strip() for move in user_input.split(',')]

        # Filter the moves based on the referential list
        filtered_moves = [move for move in tutor_moves if move in referential_moves]
        rejected_moves = [move for move in tutor_moves if move not in referential_moves]

        # Print the results without spaces
        print(f"Filtered TutorMoves: {','.join(filtered_moves)}")
        print(f"Rejected TutorMoves: {','.join(rejected_moves)}")

# Define the referential list of TM/HM/Move tutors
referential_moves = [
    'DRAININGKISS', 'DREAMEATER', 'METRONOME', 'SEISMICTOSS', 'STRUGGLEBUG', 'EXCITE', 'FIREPUNCH', 'ICEPUNCH', 
    'ICYWIND', 'THUNDERPUNCH', 'AQUATAIL', 'DRAINPUNCH', 'EARTHPOWER', 'GASTROACID', 'GUNKSHOT', 'HAUNT', 'HEALBELL', 
    'HEATWAVE', 'HYPERVOICE', 'IRONHEAD', 'IRONTAIL', 'SCORCHINGSANDS', 'ROCKBLAST', 'SHADOWBALL', 'SKYATTACK', 
    'SUPERPOWER', 'TAILWIND', 'DUALWINGBEAT', 'EXPANDINGFORCE', 'FLIPTURN', 'FORCEWAVE', 'FORGEBREATH', 'GRASSYGLIDE', 
    'KNOCKOFF', 'MISTYEXPLOSION', 'MYSTICBLADE', 'POLTERGEIST', 'RISINGVOLTAGE', 'SCALESHOT', 'SKITTERSMACK', 'SPIKES', 
    'STEALTHROCK', 'TOXICSPIKES', 'BLASTBURN', 'HYDROCANNON', 'FRENZYPLANT', 'VOLTTACKLE', 'DRACOMETOR', 'FIREPLEDGE', 
    'WATERPLEDGE', 'GRASSPLEDGE', 'TRICKROOM', 'WORKUP', 'HELPINGHAND', 'BULKUP', 'CALMMIND', 'ROAR', 'EXPLOSION', 
    'VENOSHOCK', 'DOUBLETEAM', 'SCATTERDUST', 'FLY', 'SWAGGER', 'TAUNT', 'ICEBEAM', 'BLIZZARD', 'HYPERBEAM', 'TRIATTACK', 
    'PROTECT', 'SANDSTORM', 'RAINDANCE', 'SUNNYDAY', 'HAIL', 'SOLARBEAM', 'SOLARBLADE', 'THUNDERBOLT', 'THUNDER', 
    'EARTHQUAKE', 'RETURN', 'DIG', 'PSYCHIC', 'PSYSHOCK', 'BRICKBREAK', 'HEX', 'LIGHTSCREEN', 'REFLECT', 'SAFEGUARD', 
    'FLAMETHROWER', 'FIREBLAST', 'SLUDGEBOMB', 'ROCKTOMB', 'AERIALACE', 'TORMENT', 'FACADE', 'REST', 'SLEEPTALK', 
    'LIQUIDATION', 'ATTRACT', 'ROUND', 'THIEF', 'LOWSWEEP', 'FRUSTRATION', 'ALLYSWITCH', 'FALSESWIPE', 'STEELWING', 
    'FLASHCANNON', 'FOCUSBLAST', 'BODYPRESS', 'PSYCRUSH', 'SCALD', 'ENERGYBALL', 'BULLETSEED', 'GRASSKNOT', 'ACROBATICS', 
    'SCOURINGWINDS', 'TOXIC', 'WILLOWISP', 'THUNDERWAVE', 'BITINGCOLD', 'FLAMECHARGE', 'GIGAIMPACT', 'BODYSLAM', 
    'ASSURANCE', 'FOULPLAY', 'BRUTALSWING', 'GYROBALL', 'SWORDSDANCE', 'SUBSTITUTE', 'NASTYPLOT', 'SPEEDSWAP', 
    'POWERSWAP', 'GUARDSWAP', 'ROCKSLIDE', 'DRAGONPULSE', 'DRAGONCLAW', 'POISONJAB', 'XSCISSOR', 'SCREECH', 'STONEEDGE', 
    'GEODEBURST', 'UTURN', 'VOLTSWITCH', 'SNARL', 'DARKPULSE', 'SHADOWCLAW', 'ZENHEADBUTT', 'PLAYROUGH', 'DAZZLINGGLEAM', 
    'WILDCHARGE', 'AVALANCHE', 'DRILLRUN', 'DEFOG', 'CUT', 'ROCKSMASH', 'STRENGTH', 'ROCKCLIMB', 'SURF', 'WATERFALL', 
    'DIVE'
]  # Replace with actual moves

# Process the TutorMoves
process_tutor_moves(referential_moves)