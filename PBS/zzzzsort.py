import re

def extract_base_stats_and_types(input_file, forms_file, output_file):
    def parse_entries(file_content):
        entries = file_content.split('---')
        parsed_entries = {}
        dex_number = 1
        for entry in entries:
            name_match = re.search(r'\[([A-Z0-9_]+)\]', entry)
            stats_match = re.search(r'BaseStats\s*=\s*([\d,]+)', entry)
            types_match = re.search(r'Types\s*=\s*([A-Z,]+)', entry)
            if name_match and stats_match and types_match:
                name = name_match.group(1).strip()
                stats = stats_match.group(1).strip()
                types = types_match.group(1).strip()
                parsed_entries[name] = {'DexN°': dex_number, 'BaseStats': stats, 'Types': types}
                dex_number += 1
        return parsed_entries

    with open(input_file, 'r') as file:
        main_data = file.read()

    with open(forms_file, 'r') as file:
        forms_data = file.read()

    main_entries = parse_entries(main_data)
    form_entries = forms_data.split('---')
    results = []

    # Add base entries to results
    for name, data in main_entries.items():
        dex_number = f"{data['DexN°']:03}"
        results.append(f"DexN°={dex_number}; {name}; BaseStats={data['BaseStats']}; Types={data['Types']}")

    # Add form entries to results if they differ from base entries
    for entry in form_entries:
        form_match = re.search(r'\[([A-Z0-9_]+),(\d+)\]', entry)
        stats_match = re.search(r'BaseStats\s*=\s*([\d,]+)', entry)
        types_match = re.search(r'Types\s*=\s*([A-Z,]+)', entry)
        if form_match and (stats_match or types_match):
            name = form_match.group(1).strip()
            form_number = form_match.group(2).strip()
            form_stats = stats_match.group(1).strip() if stats_match else None
            form_types = types_match.group(1).strip() if types_match else None

            if name in main_entries:
                main_stats = main_entries[name]['BaseStats']
                main_types = main_entries[name]['Types']
                dex_number = f"{main_entries[name]['DexN°']:03}"
                if form_stats != main_stats or form_types != main_types:
                    result = f"DexN°={dex_number}; {name} (Form {form_number}); BaseStats={form_stats if form_stats else main_stats}; Types={form_types if form_types else main_types}"
                    results.append(result)

    with open(output_file, 'w') as file:
        for result in results:
            file.write(result + '\n')

# Usage
input_file = 'pokemon_2.txt'
forms_file = 'pokemon_forms_2.txt'
output_file = 'zzzzbase_stats_output.txt'
extract_base_stats_and_types(input_file, forms_file, output_file)
