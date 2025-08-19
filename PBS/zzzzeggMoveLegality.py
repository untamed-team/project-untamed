from collections import deque

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
                'egg_moves': [],
                'gender_ratio': 'Unknown'
            }
        elif line.startswith("EggGroups ="):
            egg_groups = [g.strip() for g in line.split(" = ")[1].split(",")]
            pokemon_data[current_pokemon]['egg_groups'] = egg_groups
        elif line.startswith("Moves ="):
            moves = [m.strip() for m in line.split(" = ")[1].split(",")]
            pokemon_data[current_pokemon]['moves'] = moves
        elif line.startswith("TutorMoves ="):
            tutor_moves = [m.strip() for m in line.split(" = ")[1].split(",")]
            pokemon_data[current_pokemon]['tutor_moves'] = tutor_moves
        elif line.startswith("EggMoves ="):
            egg_moves = [m.strip() for m in line.split(" = ")[1].split(",")]
            pokemon_data[current_pokemon]['egg_moves'] = egg_moves
        elif line.startswith("GenderRatio ="):
            gender = line.split(" = ")[1].strip()
            pokemon_data[current_pokemon]['gender_ratio'] = gender

    return pokemon_data

def get_species_with_move(pokemon_data, move):
    level_tutor_learners = set()
    egg_learners = set()

    for species, data in pokemon_data.items():
        if move in data['moves'] or move in data['tutor_moves']:
            level_tutor_learners.add(species)
        elif move in data['egg_moves']:
            egg_learners.add(species)

    return level_tutor_learners, egg_learners

def find_all_breeding_paths(pokemon_data, target, move, level_tutor_learners, egg_learners, max_depth=6):
    all_paths = set()
    queue = deque([(target, [])])

    while queue:
        current, path = queue.popleft()
        if len(path) >= max_depth:
            continue

        current_egg_groups = pokemon_data[current]['egg_groups']

        for species in pokemon_data:
            if species == target or species in path or species == current:
                continue

            if not any(group in pokemon_data[species]['egg_groups'] for group in current_egg_groups):
                continue

            gender = pokemon_data[species]['gender_ratio']
            if species in level_tutor_learners:
                if gender not in ('Genderless', 'AlwaysFemale'):
                    all_paths.add(tuple(path + [species]))
            elif species in egg_learners:
                queue.append((species, path + [species]))

    return sorted(all_paths)

def trace_egg_move_inheritance(pokemon_data, show_all=False, show_all_fathers=False):
    found_illegal = False

    for species, data in pokemon_data.items():
        if 'Undiscovered' in data['egg_groups']:
            continue

        for egg_move in data['egg_moves']:
            level_tutor_learners, egg_learners = get_species_with_move(pokemon_data, egg_move)

            valid_fathers = [
                s for s in level_tutor_learners
                if s != species
                and any(g in pokemon_data[s]['egg_groups'] for g in data['egg_groups'])
            ]

            if valid_fathers:
                if show_all:
                    gender_note = " (genderless, requires egg move tutor)" if pokemon_data[valid_fathers[0]]['gender_ratio'] == 'Genderless' else ""
                    if show_all_fathers:
                        print(f"{species} can inherit '{egg_move}' directly from: {', '.join(valid_fathers)}{gender_note}")
                    else:
                        print(f"{species} can inherit '{egg_move}' directly from: {valid_fathers[0]}{gender_note}")
                continue

            paths = find_all_breeding_paths(pokemon_data, species, egg_move, level_tutor_learners, egg_learners)
            if paths:
                if show_all:
                    for path in paths:
                        full_path = [species] + list(path)
                        final_parent = path[-1]
                        gender_note = " (genderless, requires egg move tutor)" if pokemon_data[final_parent]['gender_ratio'] == 'Genderless' else ""
                        chain_str = " ← ".join(full_path)
                        print(f"{species} can inherit '{egg_move}' via chain breeding: {chain_str}{gender_note}")
                        if show_all_fathers == False:
                            break
                continue


            # If we reach here, the move is illegal
            found_illegal = True
            print(f"{species} cannot inherit '{egg_move}' via any known breeding path.")

    if not found_illegal and not show_all:
        print("No illegal egg moves found. congratz.")

# Persistent settings
show_all = None
input_file = None
show_all_fathers = None

while True:
    try:
        if show_all is None:
            show_all_input = input("all egg moves or only illegal ones? (0 = only illegal, 1 = all) ")
            show_all = show_all_input.strip() == '1'

        if input_file is None:
            user_input = input("pokemon.txt or pokemon_2.txt? (0 or 1) ")
            input_file = 'pokemon.txt' if user_input.strip() == '0' else 'pokemon_2.txt'

        if show_all_fathers is None:
            father_input = input("show all valid fathers or just one sample? (0 = one sample, 1 = all) ")
            show_all_fathers = father_input.strip() == '1'

        with open(input_file, 'r') as file:
            file_content = file.read()

        pokemon_data = parse_pokemon_file(file_content)
        trace_egg_move_inheritance(pokemon_data, show_all=show_all, show_all_fathers=show_all_fathers)

    except Exception as e:
        print(f"An error occurred: {e}")

    refresh = input("\nType 'r' to refresh with same settings, 'c' to change settings, or press Enter to exit: ").strip().lower()
    if refresh == 'r':
        continue
    elif refresh == 'c':
        show_all = None
        input_file = None
        show_all_fathers = None
    else:
        break
