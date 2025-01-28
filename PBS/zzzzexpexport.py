import re

def extract_data_from_file(input_file, output_file):
    with open(input_file, 'r') as f:
        lines = f.readlines()
    name = ""
    growth_rate = ""
    base_exp = ""
    extracted_data = []
    for line in lines:
        if line.startswith("["):
            name = re.findall(r'\[(.*?)\]', line)[0]
        elif line.startswith("GrowthRate"):
            growth_rate = line.split('=')[1].strip()
        elif line.startswith("BaseExp"):
            base_exp = line.split('=')[1].strip()
        elif line.startswith("#-------------------------------"):
            if name and growth_rate and base_exp:
                extracted_data.append(f"{name},{growth_rate},{base_exp}")
            name = ""
            growth_rate = ""
            base_exp = ""
    with open(output_file, 'w') as f:
        for data in extracted_data:
            f.write(data + '\n')
extract_data_from_file('pokemon.txt', 'zzzextracted_exp.txt')

def extract_trainer_data(input_file, output_file):
    with open(input_file, 'r') as f:
        lines = f.readlines()
    internal_name = ""
    external_name = ""
    trainer_id = "0"
    area_main = ""
    area_mandatory = ""
    pokemon_list = []
    extracted_data = []
    for line in lines:
        if line.startswith("[") and "," in line:
            parts = line.strip("[]\n").split(",")
            internal_name = parts[0]
            external_name = parts[1]
            trainer_id = parts[2] if len(parts) > 2 else "0"
        elif line.startswith("#Area"):
            area_info = line.split('=')[1].strip()
            area_parts = area_info.split('_')
            area_main = area_parts[0]
            area_mandatory = area_parts[1] if len(area_parts) > 1 else ""
        elif line.startswith("Pokemon"):
            pokemon_info = line.split('=')[1].strip()
            pokemon_parts = pokemon_info.split(',')
            pokemon_name = pokemon_parts[0]
            pokemon_level = pokemon_parts[1]
            pokemon_list.append(f"{pokemon_name}; {pokemon_level}")
        elif line.startswith("#-------------------------------"):
            if internal_name and external_name and area_main:
                extracted_data.append(f"{internal_name},{external_name},{trainer_id},{area_main},{area_mandatory}, Pokemon; {', '.join(pokemon_list)}")
            internal_name = ""
            external_name = ""
            trainer_id = "0"
            area_main = ""
            area_mandatory = ""
            pokemon_list = []
    with open(output_file, 'w') as f:
        for data in extracted_data:
            f.write(data + '\n')

extract_trainer_data('trainers.txt', 'zzzextracted_trainers.txt')