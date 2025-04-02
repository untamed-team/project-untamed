def parse_pokemon_file(file_content):
    pokemon_data = {}
    current_pokemon = None

    for line in file_content.splitlines():
        line = line.strip()
        if line.startswith("[") and line.endswith("]"):
            current_pokemon = line[1:-1]
            pokemon_data[current_pokemon] = {
                'egg_groups': [],
                'moves': [],
                'tutor_moves': [],
                'egg_moves': []
            }
        elif line.startswith("EggGroups ="):
            egg_groups = line.split(" = ")[1].split(",")
            pokemon_data[current_pokemon]['egg_groups'] = egg_groups
        elif line.startswith("Moves ="):
            moves = line.split(" = ")[1].split(",")
            pokemon_data[current_pokemon]['moves'] = moves
        elif line.startswith("TutorMoves ="):
            tutor_moves = line.split(" = ")[1].split(",")
            pokemon_data[current_pokemon]['tutor_moves'] = tutor_moves
        elif line.startswith("EggMoves ="):
            egg_moves = line.split(" = ")[1].split(",")
            pokemon_data[current_pokemon]['egg_moves'] = egg_moves

    return pokemon_data

def check_egg_moves(pokemon_data):
    warnings = []
    
    for species, data in pokemon_data.items():
        egg_moves = data['egg_moves']
        
        if egg_moves and 'Undiscovered' not in data['egg_groups']:
            for egg_move in egg_moves:
                can_learn_move = False
                
                for other_species, other_data in pokemon_data.items():
                    if other_species != species and any(group in other_data['egg_groups'] for group in data['egg_groups']):
                        if egg_move in other_data['moves'] or egg_move in other_data['tutor_moves'] or egg_move in other_data['egg_moves']:
                            can_learn_move = True
                            break
                
                if not can_learn_move:
                    warnings.append(f"{species} has an egg move '{egg_move}' that cannot be obtained via breeding.")
    
    return warnings

try:
    user_input = input("pokemon.txt or pokemon_2.txt? (0 or 1) ")
    if user_input.lower() == '0':
        input_file = 'pokemon.txt'
    else:
        input_file = 'pokemon_2.txt'

    with open(input_file, 'r') as file:
        file_content = file.read()
    pokemon_data = parse_pokemon_file(file_content)
    warnings = check_egg_moves(pokemon_data)
    if warnings:
        for warning in warnings:
            print(warning)
    else:
        print("No warnings found. Congratz.")

except Exception as e:
    print(f"An error occurred: {e}")


input("Press Enter to exit.")