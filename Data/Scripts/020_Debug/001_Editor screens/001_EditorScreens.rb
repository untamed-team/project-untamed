#===============================================================================
# Wild encounters editor
#===============================================================================
# Main editor method for editing wild encounters. Lists all defined encounter
# sets, and edits them.
def pbEncountersEditor
  map_infos = pbLoadMapInfos
  commands = []
  maps = []
  list = pbListWindow([])
  help_window = Window_UnformattedTextPokemon.newWithSize(
    _INTL("Edit wild encounters"), Graphics.width / 2, 0, Graphics.width / 2, 96
  )
  help_window.z = 99999
  ret = 0
  need_refresh = true
  loop do
    if need_refresh
      commands.clear
      maps.clear
      commands.push(_INTL("[Add new encounter set]"))
      GameData::Encounter.each do |enc_data|
        name = (map_infos[enc_data.map]) ? map_infos[enc_data.map].name : nil
        if enc_data.version > 0 && name
          commands.push(sprintf("%03d (v.%d): %s", enc_data.map, enc_data.version, name))
        elsif enc_data.version > 0
          commands.push(sprintf("%03d (v.%d)", enc_data.map, enc_data.version))
        elsif name
          commands.push(sprintf("%03d: %s", enc_data.map, name))
        else
          commands.push(sprintf("%03d", enc_data.map))
        end
        maps.push([enc_data.map, enc_data.version])
      end
      need_refresh = false
    end
    ret = pbCommands2(list, commands, -1, ret)
    if ret == 0   # Add new encounter set
      new_map_ID = pbListScreen(_INTL("Choose a map"), MapLister.new(pbDefaultMap))
      if new_map_ID > 0
        new_version = LimitProperty2.new(999).set(_INTL("version number"), 0)
        if new_version && new_version >= 0
          if GameData::Encounter.exists?(new_map_ID, new_version)
            pbMessage(_INTL("A set of encounters for map {1} version {2} already exists.", new_map_ID, new_version))
          else
            # Construct encounter hash
            key = sprintf("%s_%d", new_map_ID, new_version).to_sym
            encounter_hash = {
              :id           => key,
              :map          => new_map_ID,
              :version      => new_version,
              :step_chances => {},
              :types        => {}
            }
            GameData::Encounter.register(encounter_hash)
            maps.push([new_map_ID, new_version])
            maps.sort! { |a, b| (a[0] == b[0]) ? a[1] <=> b[1] : a[0] <=> b[0] }
            ret = maps.index([new_map_ID, new_version]) + 1
            need_refresh = true
          end
        end
      end
    elsif ret > 0   # Edit an encounter set
      this_set = maps[ret - 1]
      case pbShowCommands(nil, [_INTL("Edit"), _INTL("Copy"), _INTL("Delete"), _INTL("Cancel")], 4)
      when 0   # Edit
        pbEncounterMapVersionEditor(GameData::Encounter.get(this_set[0], this_set[1]))
        need_refresh = true
      when 1   # Copy
        new_map_ID = pbListScreen(_INTL("Copy to which map?"), MapLister.new(this_set[0]))
        if new_map_ID > 0
          new_version = LimitProperty2.new(999).set(_INTL("version number"), 0)
          if new_version && new_version >= 0
            if GameData::Encounter.exists?(new_map_ID, new_version)
              pbMessage(_INTL("A set of encounters for map {1} version {2} already exists.", new_map_ID, new_version))
            else
              # Construct encounter hash
              key = sprintf("%s_%d", new_map_ID, new_version).to_sym
              encounter_hash = {
                :id           => key,
                :map          => new_map_ID,
                :version      => new_version,
                :step_chances => {},
                :types        => {}
              }
              GameData::Encounter.get(this_set[0], this_set[1]).step_chances.each do |type, value|
                encounter_hash[:step_chances][type] = value
              end
              GameData::Encounter.get(this_set[0], this_set[1]).types.each do |type, slots|
                next if !type || !slots || slots.length == 0
                encounter_hash[:types][type] = []
                slots.each { |slot| encounter_hash[:types][type].push(slot.clone) }
              end
              GameData::Encounter.register(encounter_hash)
              maps.push([new_map_ID, new_version])
              maps.sort! { |a, b| (a[0] == b[0]) ? a[1] <=> b[1] : a[0] <=> b[0] }
              ret = maps.index([new_map_ID, new_version]) + 1
              need_refresh = true
            end
          end
        end
      when 2   # Delete
        if pbConfirmMessage(_INTL("Delete the encounter set for map {1} version {2}?", this_set[0], this_set[1]))
          key = sprintf("%s_%d", this_set[0], this_set[1]).to_sym
          GameData::Encounter::DATA.delete(key)
          ret -= 1
          need_refresh = true
        end
      end
    else
      break
    end
  end
  if pbConfirmMessage(_INTL("Save changes?"))
    GameData::Encounter.save
    Compiler.write_encounters   # Rewrite PBS file encounters.txt
  else
    GameData::Encounter.load
  end
  list.dispose
  help_window.dispose
  Input.update
end

# Lists the map ID, version number and defined encounter types for the given
# encounter data (a GameData::Encounter instance), and edits them.
def pbEncounterMapVersionEditor(enc_data)
  map_infos = pbLoadMapInfos
  commands = []
  enc_types = []
  list = pbListWindow([])
  help_window = Window_UnformattedTextPokemon.newWithSize(
    _INTL("Edit map's encounters"), Graphics.width / 2, 0, Graphics.width / 2, 96
  )
  help_window.z = 99999
  ret = 0
  need_refresh = true
  loop do
    if need_refresh
      commands.clear
      enc_types.clear
      map_name = (map_infos[enc_data.map]) ? map_infos[enc_data.map].name : nil
      if map_name
        commands.push(_INTL("Map ID={1} ({2})", enc_data.map, map_name))
      else
        commands.push(_INTL("Map ID={1}", enc_data.map))
      end
      commands.push(_INTL("Version={1}", enc_data.version))
      enc_data.types.each do |enc_type, slots|
        next if !enc_type
        commands.push(_INTL("{1} (x{2})", enc_type.to_s, slots.length))
        enc_types.push(enc_type)
      end
      commands.push(_INTL("[Add new encounter type]"))
      need_refresh = false
    end
    ret = pbCommands2(list, commands, -1, ret)
    if ret == 0   # Edit map ID
      old_map_ID = enc_data.map
      new_map_ID = pbListScreen(_INTL("Choose a new map"), MapLister.new(old_map_ID))
      if new_map_ID > 0 && new_map_ID != old_map_ID
        if GameData::Encounter.exists?(new_map_ID, enc_data.version)
          pbMessage(_INTL("A set of encounters for map {1} version {2} already exists.", new_map_ID, enc_data.version))
        else
          GameData::Encounter::DATA.delete(enc_data.id)
          enc_data.map = new_map_ID
          enc_data.id = sprintf("%s_%d", enc_data.map, enc_data.version).to_sym
          GameData::Encounter::DATA[enc_data.id] = enc_data
          need_refresh = true
        end
      end
    elsif ret == 1   # Edit version number
      old_version = enc_data.version
      new_version = LimitProperty2.new(999).set(_INTL("version number"), old_version)
      if new_version && new_version != old_version
        if GameData::Encounter.exists?(enc_data.map, new_version)
          pbMessage(_INTL("A set of encounters for map {1} version {2} already exists.", enc_data.map, new_version))
        else
          GameData::Encounter::DATA.delete(enc_data.id)
          enc_data.version = new_version
          enc_data.id = sprintf("%s_%d", enc_data.map, enc_data.version).to_sym
          GameData::Encounter::DATA[enc_data.id] = enc_data
          need_refresh = true
        end
      end
    elsif ret == commands.length - 1   # Add new encounter type
      new_type_commands = []
      new_types = []
      GameData::EncounterType.each_alphabetically do |enc|
        next if enc_data.types[enc.id]
        new_type_commands.push(enc.real_name)
        new_types.push(enc.id)
      end
      if new_type_commands.length > 0
        chosen_type_cmd = pbShowCommands(nil, new_type_commands, -1)
        if chosen_type_cmd >= 0
          new_type = new_types[chosen_type_cmd]
          enc_data.step_chances[new_type] = GameData::EncounterType.get(new_type).trigger_chance
          enc_data.types[new_type] = []
          pbEncounterTypeEditor(enc_data, new_type)
          enc_types.push(new_type)
          ret = enc_types.sort.index(new_type) + 2
          need_refresh = true
        end
      else
        pbMessage(_INTL("There are no unused encounter types to add."))
      end
    elsif ret > 0   # Edit an encounter type (its step chance and slots)
      this_type = enc_types[ret - 2]
      case pbShowCommands(nil, [_INTL("Edit"), _INTL("Copy"), _INTL("Delete"), _INTL("Cancel")], 4)
      when 0   # Edit
        pbEncounterTypeEditor(enc_data, this_type)
        need_refresh = true
      when 1   # Copy
        new_type_commands = []
        new_types = []
        GameData::EncounterType.each_alphabetically do |enc|
          next if enc_data.types[enc.id]
          new_type_commands.push(enc.real_name)
          new_types.push(enc.id)
        end
        if new_type_commands.length > 0
          chosen_type_cmd = pbMessage(_INTL("Choose an encounter type to copy to."),
                                      new_type_commands, -1)
          if chosen_type_cmd >= 0
            new_type = new_types[chosen_type_cmd]
            enc_data.step_chances[new_type] = enc_data.step_chances[this_type]
            enc_data.types[new_type] = []
            enc_data.types[this_type].each { |slot| enc_data.types[new_type].push(slot.clone) }
            enc_types.push(new_type)
            ret = enc_types.sort.index(new_type) + 2
            need_refresh = true
          end
        else
          pbMessage(_INTL("There are no unused encounter types to copy to."))
        end
      when 2   # Delete
        if pbConfirmMessage(_INTL("Delete the encounter type {1}?", GameData::EncounterType.get(this_type).real_name))
          enc_data.step_chances.delete(this_type)
          enc_data.types.delete(this_type)
          need_refresh = true
        end
      end
    else
      break
    end
  end
  list.dispose
  help_window.dispose
  Input.update
end

# Lists the step chance and encounter slots for the given encounter type in the
# given encounter data (a GameData::Encounter instance), and edits them.
def pbEncounterTypeEditor(enc_data, enc_type)
  commands = []
  list = pbListWindow([])
  help_window = Window_UnformattedTextPokemon.newWithSize(
    _INTL("Edit encounter slots"), Graphics.width / 2, 0, Graphics.width / 2, 96
  )
  help_window.z = 99999
  enc_type_name = ""
  ret = 0
  need_refresh = true
  loop do
    if need_refresh
      enc_type_name = GameData::EncounterType.get(enc_type).real_name
      commands.clear
      commands.push(_INTL("Step chance={1}%", enc_data.step_chances[enc_type] || 0))
      commands.push(_INTL("Encounter type={1}", enc_type_name))
      if enc_data.types[enc_type] && enc_data.types[enc_type].length > 0
        enc_data.types[enc_type].each do |slot|
          commands.push(EncounterSlotProperty.format(slot))
        end
      end
      commands.push(_INTL("[Add new slot]"))
      need_refresh = false
    end
    ret = pbCommands2(list, commands, -1, ret)
    if ret == 0   # Edit step chance
      old_step_chance = enc_data.step_chances[enc_type] || 0
      new_step_chance = LimitProperty.new(255).set(_INTL("Step chance"), old_step_chance)
      if new_step_chance != old_step_chance
        enc_data.step_chances[enc_type] = new_step_chance
        need_refresh = true
      end
    elsif ret == 1   # Edit encounter type
      new_type_commands = []
      new_types = []
      chosen_type_cmd = 0
      GameData::EncounterType.each_alphabetically do |enc|
        next if enc_data.types[enc.id] && enc.id != enc_type
        new_type_commands.push(enc.real_name)
        new_types.push(enc.id)
        chosen_type_cmd = new_type_commands.length - 1 if enc.id == enc_type
      end
      chosen_type_cmd = pbShowCommands(nil, new_type_commands, -1, chosen_type_cmd)
      if chosen_type_cmd >= 0 && new_types[chosen_type_cmd] != enc_type
        new_type = new_types[chosen_type_cmd]
        enc_data.step_chances[new_type] = enc_data.step_chances[enc_type]
        enc_data.step_chances.delete(enc_type)
        enc_data.types[new_type] = enc_data.types[enc_type]
        enc_data.types.delete(enc_type)
        enc_type = new_type
        need_refresh = true
      end
    elsif ret == commands.length - 1   # Add new encounter slot
      new_slot_data = EncounterSlotProperty.set(enc_type_name, nil)
      if new_slot_data
        enc_data.types[enc_type].push(new_slot_data)
        need_refresh = true
      end
    elsif ret > 0   # Edit a slot
      case pbShowCommands(nil, [_INTL("Edit"), _INTL("Copy"), _INTL("Delete"), _INTL("Cancel")], 4)
      when 0   # Edit
        old_slot_data = enc_data.types[enc_type][ret - 2]
        new_slot_data = EncounterSlotProperty.set(enc_type_name, old_slot_data.clone)
        if new_slot_data && new_slot_data != old_slot_data
          enc_data.types[enc_type][ret - 2] = new_slot_data
          need_refresh = true
        end
      when 1   # Copy
        enc_data.types[enc_type].insert(ret - 1, enc_data.types[enc_type][ret - 2].clone)
        ret += 1
        need_refresh = true
      when 2   # Delete
        if pbConfirmMessage(_INTL("Delete this encounter slot?"))
          enc_data.types[enc_type].delete_at(ret - 2)
          need_refresh = true
        end
      end
    else
      break
    end
  end
  list.dispose
  help_window.dispose
  Input.update
end



#===============================================================================
# Trainer type editor
#===============================================================================
def pbTrainerTypeEditor
  gender_array = []
  GameData::TrainerType::SCHEMA["Gender"][2].each { |key, value| gender_array[value] = key if !gender_array[value] }
  trainer_type_properties = [
    [_INTL("ID"),         ReadOnlyProperty,               _INTL("ID of this Trainer Type (used as a symbol like :XXX).")],
    [_INTL("Name"),       StringProperty,                 _INTL("Name of this Trainer Type as displayed by the game.")],
    [_INTL("Gender"),     EnumProperty.new(gender_array), _INTL("Gender of this Trainer Type.")],
    [_INTL("BaseMoney"),  LimitProperty.new(9999),        _INTL("Player earns this much money times the highest level among the trainer's Pokémon.")],
    [_INTL("SkillLevel"), LimitProperty.new(9999),        _INTL("Skill level of this Trainer Type.")],
    [_INTL("Flags"),      StringListProperty,             _INTL("Words/phrases that can be used to make trainers of this type behave differently to others.")],
    [_INTL("IntroBGM"),   BGMProperty,                    _INTL("BGM played before battles against trainers of this type.")],
    [_INTL("BattleBGM"),  BGMProperty,                    _INTL("BGM played in battles against trainers of this type.")],
    [_INTL("VictoryBGM"), BGMProperty,                    _INTL("BGM played when player wins battles against trainers of this type.")]
  ]
  pbListScreenBlock(_INTL("Trainer Types"), TrainerTypeLister.new(0, true)) { |button, tr_type|
    if tr_type
      case button
      when Input::ACTION
        if tr_type.is_a?(Symbol) && pbConfirmMessageSerious("Delete this trainer type?")
          GameData::TrainerType::DATA.delete(tr_type)
          GameData::TrainerType.save
          pbConvertTrainerData
          pbMessage(_INTL("The Trainer type was deleted."))
        end
      when Input::USE
        if tr_type.is_a?(Symbol)
          t_data = GameData::TrainerType.get(tr_type)
          data = [
            t_data.id.to_s,
            t_data.real_name,
            t_data.gender,
            t_data.base_money,
            t_data.skill_level,
            t_data.flags,
            t_data.intro_BGM,
            t_data.battle_BGM,
            t_data.victory_BGM
          ]
          if pbPropertyList(t_data.id.to_s, data, trainer_type_properties, true)
            # Construct trainer type hash
            type_hash = {
              :id          => t_data.id,
              :name        => data[1],
              :gender      => data[2],
              :base_money  => data[3],
              :skill_level => data[4],
              :flags       => data[5],
              :intro_BGM   => data[6],
              :battle_BGM  => data[7],
              :victory_BGM => data[8]
            }
            # Add trainer type's data to records
            GameData::TrainerType.register(type_hash)
            GameData::TrainerType.save
            pbConvertTrainerData
          end
        else   # Add a new trainer type
          pbTrainerTypeEditorNew(nil)
        end
      end
    end
  }
end

def pbTrainerTypeEditorNew(default_name)
  # Choose a name
  name = pbMessageFreeText(_INTL("Please enter the trainer type's name."),
                           (default_name) ? default_name.gsub(/_+/, " ") : "", false, 30)
  if nil_or_empty?(name)
    return nil if !default_name
    name = default_name
  end
  # Generate an ID based on the item name
  id = name.gsub(/é/, "e")
  id = id.gsub(/[^A-Za-z0-9_]/, "")
  id = id.upcase
  if id.length == 0
    id = sprintf("T_%03d", GameData::TrainerType.count)
  elsif !id[0, 1][/[A-Z]/]
    id = "T_" + id
  end
  if GameData::TrainerType.exists?(id)
    (1..100).each do |i|
      trial_id = sprintf("%s_%d", id, i)
      next if GameData::TrainerType.exists?(trial_id)
      id = trial_id
      break
    end
  end
  if GameData::TrainerType.exists?(id)
    pbMessage(_INTL("Failed to create the trainer type. Choose a different name."))
    return nil
  end
  # Choose a gender
  gender = pbMessage(_INTL("Is the Trainer male, female or unknown?"),
                     [_INTL("Male"), _INTL("Female"), _INTL("Unknown")], 0)
  # Choose a base money value
  params = ChooseNumberParams.new
  params.setRange(0, 255)
  params.setDefaultValue(30)
  base_money = pbMessageChooseNumber(_INTL("Set the money per level won for defeating the Trainer."), params)
  # Construct trainer type hash
  tr_type_hash = {
    :id         => id.to_sym,
    :name       => name,
    :gender     => gender,
    :base_money => base_money
  }
  # Add trainer type's data to records
  GameData::TrainerType.register(tr_type_hash)
  GameData::TrainerType.save
  pbConvertTrainerData
  pbMessage(_INTL("The trainer type {1} was created (ID: {2}).", name, id.to_s))
  pbMessage(_INTL("Put the Trainer's graphic ({1}.png) in Graphics/Trainers, or it will be blank.", id.to_s))
  return id.to_sym
end



#===============================================================================
# Individual trainer editor
#===============================================================================
module TrainerBattleProperty
  NUM_ITEMS = 8

  def self.set(settingname, oldsetting)
    return nil if !oldsetting
    properties = [
      [_INTL("Trainer Type"), TrainerTypeProperty,     _INTL("Name of the trainer type for this Trainer.")],
      [_INTL("Trainer Name"), StringProperty,          _INTL("Name of the Trainer.")],
      [_INTL("Version"),      LimitProperty.new(9999), _INTL("Number used to distinguish Trainers with the same name and trainer type.")],
      [_INTL("Lose Text"),    StringProperty,          _INTL("Message shown in battle when the Trainer is defeated.")]
    ]
    Settings::MAX_PARTY_SIZE.times do |i|
      properties.push([_INTL("Pokémon {1}", i + 1), TrainerPokemonProperty, _INTL("A Pokémon owned by the Trainer.")])
    end
    NUM_ITEMS.times do |i|
      properties.push([_INTL("Item {1}", i + 1), ItemProperty, _INTL("An item used by the Trainer during battle.")])
    end
    return nil if !pbPropertyList(settingname, oldsetting, properties, true)
    oldsetting = nil if !oldsetting[0]
    return oldsetting
  end

  def self.format(value)
    return value.inspect
  end
end



def pbTrainerBattleEditor
  modified = false
  pbListScreenBlock(_INTL("Trainer Battles"), TrainerBattleLister.new(0, true)) { |button, trainer_id|
    if trainer_id
      case button
      when Input::ACTION
        if trainer_id.is_a?(Array) && pbConfirmMessageSerious("Delete this trainer battle?")
          tr_data = GameData::Trainer::DATA[trainer_id]
          GameData::Trainer::DATA.delete(trainer_id)
          modified = true
          pbMessage(_INTL("The Trainer battle was deleted."))
        end
      when Input::USE
        if trainer_id.is_a?(Array)   # Edit existing trainer
          tr_data = GameData::Trainer::DATA[trainer_id]
          old_type = tr_data.trainer_type
          old_name = tr_data.real_name
          old_version = tr_data.version
          data = [
            tr_data.trainer_type,
            tr_data.real_name,
            tr_data.version,
            tr_data.real_lose_text
          ]
          Settings::MAX_PARTY_SIZE.times do |i|
            data.push(tr_data.pokemon[i])
          end
          TrainerBattleProperty::NUM_ITEMS.times do |i|
            data.push(tr_data.items[i])
          end
          loop do
            data = TrainerBattleProperty.set(tr_data.real_name, data)
            break if !data
            party = []
            items = []
            Settings::MAX_PARTY_SIZE.times do |i|
              party.push(data[4 + i]) if data[4 + i] && data[4 + i][:species]
            end
            TrainerBattleProperty::NUM_ITEMS.times do |i|
              items.push(data[4 + Settings::MAX_PARTY_SIZE + i]) if data[4 + Settings::MAX_PARTY_SIZE + i]
            end
            if !data[0]
              pbMessage(_INTL("Can't save. No trainer type was chosen."))
            elsif !data[1] || data[1].empty?
              pbMessage(_INTL("Can't save. No name was entered."))
            elsif party.length == 0
              pbMessage(_INTL("Can't save. The Pokémon list is empty."))
            else
              trainer_hash = {
                :trainer_type => data[0],
                :name         => data[1],
                :version      => data[2],
                :lose_text    => data[3],
                :pokemon      => party,
                :items        => items
              }
              # Add trainer type's data to records
              trainer_hash[:id] = [trainer_hash[:trainer_type], trainer_hash[:name], trainer_hash[:version]]
              GameData::Trainer.register(trainer_hash)
              if data[0] != old_type || data[1] != old_name || data[2] != old_version
                GameData::Trainer::DATA.delete([old_type, old_name, old_version])
              end
              modified = true
              break
            end
          end
        else   # New trainer
          tr_type = nil
          ret = pbMessage(_INTL("First, define the new trainer's type."),
                          [_INTL("Use existing type"),
                           _INTL("Create new type"),
                           _INTL("Cancel")], 3)
          case ret
          when 0
            tr_type = pbListScreen(_INTL("TRAINER TYPE"), TrainerTypeLister.new(0, false))
          when 1
            tr_type = pbTrainerTypeEditorNew(nil)
          else
            next
          end
          next if !tr_type
          tr_name = pbMessageFreeText(_INTL("Now enter the trainer's name."), "", false, 30)
          next if nil_or_empty?(tr_name)
          tr_version = pbGetFreeTrainerParty(tr_type, tr_name)
          if tr_version < 0
            pbMessage(_INTL("There is no room to create a trainer of that type and name."))
            next
          end
          t = nil #pbNewTrainer(tr_type, tr_name, tr_version, false)
          if t
            trainer_hash = {
              :trainer_type => tr_type,
              :name         => tr_name,
              :version      => tr_version,
              :pokemon      => []
            }
            t[3].each do |pkmn|
              trainer_hash[:pokemon].push(
                {
                  :species => pkmn[0],
                  :level   => pkmn[1]
                }
              )
            end
            # Add trainer's data to records
            trainer_hash[:id] = [trainer_hash[:trainer_type], trainer_hash[:name], trainer_hash[:version]]
            GameData::Trainer.register(trainer_hash)
            pbMessage(_INTL("The Trainer battle was added."))
            modified = true
          end
        end
      end
    end
  }
  if modified && pbConfirmMessage(_INTL("Save changes?"))
    GameData::Trainer.save
    pbConvertTrainerData
  else
    GameData::Trainer.load
  end
end



#===============================================================================
# Trainer Pokémon editor
#===============================================================================
module TrainerPokemonProperty
  def self.set(settingname, initsetting)
    initsetting = { :species => nil, :level => 10 } if !initsetting
    oldsetting = [
      initsetting[:species],
      initsetting[:level],
      initsetting[:name],
      initsetting[:form],
      initsetting[:gender],
      initsetting[:shininess],
      initsetting[:super_shininess],
      initsetting[:shadowness]
    ]
    Pokemon::MAX_MOVES.times do |i|
      oldsetting.push((initsetting[:moves]) ? initsetting[:moves][i] : nil)
    end
    oldsetting.concat([initsetting[:ability],
                       initsetting[:ability_index],
                       initsetting[:item],
                       initsetting[:nature],
                       initsetting[:iv],
                       initsetting[:ev],
                       initsetting[:happiness],
                       initsetting[:poke_ball]])
    max_level = GameData::GrowthRate.max_level
    pkmn_properties = [
      [_INTL("Species"),       SpeciesProperty,                         _INTL("Species of the Pokémon.")],
      [_INTL("Level"),         NonzeroLimitProperty.new(max_level),     _INTL("Level of the Pokémon (1-{1}).", max_level)],
      [_INTL("Name"),          StringProperty,                          _INTL("Name of the Pokémon.")],
      [_INTL("Form"),          LimitProperty2.new(999),                 _INTL("Form of the Pokémon.")],
      [_INTL("Gender"),        GenderProperty,                          _INTL("Gender of the Pokémon.")],
      [_INTL("Shiny"),         BooleanProperty2,                        _INTL("If set to true, the Pokémon is a different-colored Pokémon.")],
      [_INTL("SuperShiny"),    BooleanProperty2,                        _INTL("Whether the Pokémon is super shiny (shiny with a special shininess animation).")],
      [_INTL("Shadow"),        BooleanProperty2,                        _INTL("If set to true, the Pokémon is a Shadow Pokémon.")]
    ]
    Pokemon::MAX_MOVES.times do |i|
      pkmn_properties.push([_INTL("Move {1}", i + 1),
                            MovePropertyForSpecies.new(oldsetting), _INTL("A move known by the Pokémon. Leave all moves blank (use Z key to delete) for a wild moveset.")])
    end
    pkmn_properties.concat(
      [[_INTL("Ability"),       AbilityProperty,                         _INTL("Ability of the Pokémon. Overrides the ability index.")],
       [_INTL("Ability index"), LimitProperty2.new(99),                  _INTL("Ability index. 0=first ability, 1=second ability, 2+=hidden ability.")],
       [_INTL("Held item"),     ItemProperty,                            _INTL("Item held by the Pokémon.")],
       [_INTL("Nature"),        GameDataProperty.new(:Nature),           _INTL("Nature of the Pokémon.")],
       [_INTL("IVs"),           IVsProperty.new(Pokemon::IV_STAT_LIMIT), _INTL("Individual values for each of the Pokémon's stats.")],
       [_INTL("EVs"),           EVsProperty.new(Pokemon::EV_STAT_LIMIT), _INTL("Effort values for each of the Pokémon's stats.")],
       [_INTL("Happiness"),     LimitProperty2.new(255),                 _INTL("Happiness of the Pokémon (0-255).")],
       [_INTL("Poké Ball"),     BallProperty.new(oldsetting),            _INTL("The kind of Poké Ball the Pokémon is kept in.")]]
    )
    pbPropertyList(settingname, oldsetting, pkmn_properties, false)
    return nil if !oldsetting[0]   # Species is nil
    ret = {
      :species         => oldsetting[0],
      :level           => oldsetting[1],
      :name            => oldsetting[2],
      :form            => oldsetting[3],
      :gender          => oldsetting[4],
      :shininess       => oldsetting[5],
      :super_shininess => oldsetting[6],
      :shadowness      => oldsetting[7],
      :ability         => oldsetting[8 + Pokemon::MAX_MOVES],
      :ability_index   => oldsetting[9 + Pokemon::MAX_MOVES],
      :item            => oldsetting[10 + Pokemon::MAX_MOVES],
      :nature          => oldsetting[11 + Pokemon::MAX_MOVES],
      :iv              => oldsetting[12 + Pokemon::MAX_MOVES],
      :ev              => oldsetting[13 + Pokemon::MAX_MOVES],
      :happiness       => oldsetting[14 + Pokemon::MAX_MOVES],
      :poke_ball       => oldsetting[15 + Pokemon::MAX_MOVES]
    }
    moves = []
    Pokemon::MAX_MOVES.times do |i|
      moves.push(oldsetting[8 + i])
    end
    moves.uniq!
    moves.compact!
    ret[:moves] = moves
    return ret
  end

  def self.format(value)
    return "-" if !value || !value[:species]
    return sprintf("%s,%d", GameData::Species.get(value[:species]).name, value[:level])
  end
end



#===============================================================================
# Metadata editor
#===============================================================================
def pbMetadataScreen
  sel_player = -1
  loop do
    sel_player = pbListScreen(_INTL("SET METADATA"), MetadataLister.new(sel_player, true))
    break if sel_player == -1
    case sel_player
    when -2   # Add new player
      pbEditPlayerMetadata(-1)
    when 0   # Edit global metadata
      pbEditMetadata
    else   # Edit player character
      pbEditPlayerMetadata(sel_player) if sel_player >= 1
    end
  end
end

def pbEditMetadata
  data = []
  metadata = GameData::Metadata.get
  properties = GameData::Metadata.editor_properties
  properties.each do |property|
    data.push(metadata.property_from_string(property[0]))
  end
  if pbPropertyList(_INTL("Global Metadata"), data, properties, true)
    # Construct metadata hash
    metadata_hash = {
      :id                  => 0,
      :start_money         => data[0],
      :start_item_storage  => data[1],
      :home                => data[2],
      :storage_creator     => data[3],
      :wild_battle_BGM     => data[4],
      :trainer_battle_BGM  => data[5],
      :wild_victory_BGM    => data[6],
      :trainer_victory_BGM => data[7],
      :wild_capture_ME     => data[8],
      :surf_BGM            => data[9],
      :bicycle_BGM         => data[10]
    }
    # Add metadata's data to records
    GameData::Metadata.register(metadata_hash)
    GameData::Metadata.save
    Compiler.write_metadata
  end
end

def pbEditPlayerMetadata(player_id = 1)
  metadata = nil
  if player_id < 1
    # Adding new player character; get lowest unused player character ID
    ids = GameData::PlayerMetadata.keys
    1.upto(ids.max + 1) do |i|
      next if ids.include?(i)
      player_id = i
      break
    end
    metadata = GameData::PlayerMetadata.new({ :id => player_id })
  elsif !GameData::PlayerMetadata.exists?(player_id)
    pbMessage(_INTL("Metadata for player character {1} was not found.", player_id))
    return
  end
  data = []
  metadata = GameData::PlayerMetadata.try_get(player_id) if metadata.nil?
  properties = GameData::PlayerMetadata.editor_properties
  properties.each do |property|
    data.push(metadata.property_from_string(property[0]))
  end
  if pbPropertyList(_INTL("Player {1}", metadata.id), data, properties, true)
    # Construct player metadata hash
    metadata_hash = {
      :id                => player_id,
      :trainer_type      => data[0],
      :walk_charset      => data[1],
      :run_charset       => data[2],
      :cycle_charset     => data[3],
      :surf_charset      => data[4],
      :dive_charset      => data[5],
      :fish_charset      => data[6],
      :surf_fish_charset => data[7]
    }
    # Add player metadata's data to records
    GameData::PlayerMetadata.register(metadata_hash)
    GameData::PlayerMetadata.save
    Compiler.write_metadata
  end
end



#===============================================================================
# Map metadata editor
#===============================================================================
def pbMapMetadataScreen(map_id = 0)
  loop do
    map_id = pbListScreen(_INTL("SET METADATA"), MapLister.new(map_id))
    break if map_id < 0
    (map_id == 0) ? pbEditMetadata : pbEditMapMetadata(map_id)
  end
end

def pbEditMapMetadata(map_id)
  mapinfos = pbLoadMapInfos
  data = []
  map_name = mapinfos[map_id].name
  metadata = GameData::MapMetadata.try_get(map_id)
  metadata = GameData::MapMetadata.new({ :id => map_id }) if !metadata
  properties = GameData::MapMetadata.editor_properties
  properties.each do |property|
    data.push(metadata.property_from_string(property[0]))
  end
  if pbPropertyList(map_name, data, properties, true)
    # Construct map metadata hash
    metadata_hash = {
      :id                   => map_id,
      :name                 => data[0],
      :outdoor_map          => data[1],
      :announce_location    => data[2],
      :can_bicycle          => data[3],
      :always_bicycle       => data[4],
      :teleport_destination => data[5],
      :weather              => data[6],
      :town_map_position    => data[7],
      :dive_map_id          => data[8],
      :dark_map             => data[9],
      :safari_map           => data[10],
      :snap_edges           => data[11],
      :random_dungeon       => data[12],
      :battle_background    => data[13],
      :wild_battle_BGM      => data[14],
      :trainer_battle_BGM   => data[15],
      :wild_victory_BGM     => data[16],
      :trainer_victory_BGM  => data[17],
      :wild_capture_ME      => data[18],
      :town_map_size        => data[19],
      :battle_environment   => data[20],
      :flags                => data[21]
    }
    # Add map metadata's data to records
    GameData::MapMetadata.register(metadata_hash)
    GameData::MapMetadata.save
    Compiler.write_map_metadata
  end
end



#===============================================================================
# Item editor
#===============================================================================
def pbItemEditor
  field_use_array = [_INTL("Can't use in field")]
  GameData::Item::SCHEMA["FieldUse"][2].each { |key, value| field_use_array[value] = key if !field_use_array[value] }
  battle_use_array = [_INTL("Can't use in battle")]
  GameData::Item::SCHEMA["BattleUse"][2].each { |key, value| battle_use_array[value] = key if !battle_use_array[value] }
  item_properties = [
    [_INTL("ID"),          ReadOnlyProperty,                   _INTL("ID of this item (used as a symbol like :XXX).")],
    [_INTL("Name"),        ItemNameProperty,                   _INTL("Name of this item as displayed by the game.")],
    [_INTL("NamePlural"),  ItemNameProperty,                   _INTL("Plural name of this item as displayed by the game.")],
    [_INTL("Pocket"),      PocketProperty,                     _INTL("Pocket in the Bag where this item is stored.")],
    [_INTL("Price"),       LimitProperty.new(999_999),         _INTL("Purchase price of this item.")],
    [_INTL("SellPrice"),   LimitProperty.new(999_999),         _INTL("Sell price of this item. If blank, is half the purchase price.")],
    [_INTL("Description"), StringProperty,                     _INTL("Description of this item")],
    [_INTL("FieldUse"),    EnumProperty.new(field_use_array),  _INTL("How this item can be used outside of battle.")],
    [_INTL("BattleUse"),   EnumProperty.new(battle_use_array), _INTL("How this item can be used within a battle.")],
    [_INTL("Consumable"),  BooleanProperty,                    _INTL("Whether this item is consumed after use.")],
    [_INTL("Flags"),       StringListProperty,                 _INTL("Words/phrases that can be used to group certain kinds of items.")],
    [_INTL("Move"),        MoveProperty,                       _INTL("Move taught by this HM, TM or TR.")]
  ]
  pbListScreenBlock(_INTL("Items"), ItemLister.new(0, true)) { |button, item|
    if item
      case button
      when Input::ACTION
        if item.is_a?(Symbol) && pbConfirmMessageSerious("Delete this item?")
          GameData::Item::DATA.delete(item)
          GameData::Item.save
          Compiler.write_items
          pbMessage(_INTL("The item was deleted."))
        end
      when Input::USE
        if item.is_a?(Symbol)
          itm = GameData::Item.get(item)
          data = [
            itm.id.to_s,
            itm.real_name,
            itm.real_name_plural,
            itm.pocket,
            itm.price,
            itm.sell_price,
            itm.real_description,
            itm.field_use,
            itm.battle_use,
            itm.consumable,
            itm.flags,
            itm.move
          ]
          if pbPropertyList(itm.id.to_s, data, item_properties, true)
            # Construct item hash
            item_hash = {
              :id          => itm.id,
              :name        => data[1],
              :name_plural => data[2],
              :pocket      => data[3],
              :price       => data[4],
              :sell_price  => data[5],
              :description => data[6],
              :field_use   => data[7],
              :battle_use  => data[8],
              :consumable  => data[9],
              :flags       => data[10],
              :move        => data[11]
            }
            # Add item's data to records
            GameData::Item.register(item_hash)
            GameData::Item.save
            Compiler.write_items
          end
        else   # Add a new item
          pbItemEditorNew(nil)
        end
      end
    end
  }
end

def pbItemEditorNew(default_name)
  # Choose a name
  name = pbMessageFreeText(_INTL("Please enter the item's name."),
                           (default_name) ? default_name.gsub(/_+/, " ") : "", false, 30)
  if nil_or_empty?(name)
    return if !default_name
    name = default_name
  end
  # Generate an ID based on the item name
  id = name.gsub(/é/, "e")
  id = id.gsub(/[^A-Za-z0-9_]/, "")
  id = id.upcase
  if id.length == 0
    id = sprintf("ITEM_%03d", GameData::Item.count)
  elsif !id[0, 1][/[A-Z]/]
    id = "ITEM_" + id
  end
  if GameData::Item.exists?(id)
    (1..100).each do |i|
      trial_id = sprintf("%s_%d", id, i)
      next if GameData::Item.exists?(trial_id)
      id = trial_id
      break
    end
  end
  if GameData::Item.exists?(id)
    pbMessage(_INTL("Failed to create the item. Choose a different name."))
    return
  end
  # Choose a pocket
  pocket = PocketProperty.set("", 0)
  return if pocket == 0
  # Choose a price
  price = LimitProperty.new(999_999).set(_INTL("Purchase price"), -1)
  return if price == -1
  # Choose a description
  description = StringProperty.set(_INTL("Description"), "")
  # Construct item hash
  item_hash = {
    :id          => id.to_sym,
    :name        => name,
    :name_plural => name + "s",
    :pocket      => pocket,
    :price       => price,
    :description => description
  }
  # Add item's data to records
  GameData::Item.register(item_hash)
  GameData::Item.save
  Compiler.write_items
  pbMessage(_INTL("The item {1} was created (ID: {2}).", name, id.to_s))
  pbMessage(_INTL("Put the item's graphic ({1}.png) in Graphics/Items, or it will be blank.", id.to_s))
end



#===============================================================================
# Pokémon species editor
#===============================================================================
def pbPokemonEditor
  species_properties = [
    [_INTL("ID"),                ReadOnlyProperty,                   _INTL("The ID of the Pokémon.")],
    [_INTL("Name"),              LimitStringProperty.new(Pokemon::MAX_NAME_SIZE), _INTL("Name of the Pokémon.")],
    [_INTL("FormName"),          StringProperty,                     _INTL("Name of this form of the Pokémon.")],
    [_INTL("Category"),          StringProperty,                     _INTL("Kind of Pokémon species.")],
    [_INTL("Pokédex"),           StringProperty,                     _INTL("Description of the Pokémon as displayed in the Pokédex.")],
    [_INTL("Type 1"),            TypeProperty,                       _INTL("Pokémon's type. If same as Type 2, this Pokémon has a single type.")],
    [_INTL("Type 2"),            TypeProperty,                       _INTL("Pokémon's type. If same as Type 1, this Pokémon has a single type.")],
    [_INTL("BaseStats"),         BaseStatsProperty,                  _INTL("Base stats of the Pokémon.")],
    [_INTL("EVs"),               EffortValuesProperty,               _INTL("Effort Value points earned when this species is defeated.")],
    [_INTL("BaseExp"),           LimitProperty.new(9999),            _INTL("Base experience earned when this species is defeated.")],
    [_INTL("GrowthRate"),        GameDataProperty.new(:GrowthRate),  _INTL("Pokémon's growth rate.")],
    [_INTL("GenderRatio"),       GameDataProperty.new(:GenderRatio), _INTL("Proportion of males to females for this species.")],
    [_INTL("CatchRate"),         LimitProperty.new(255),             _INTL("Catch rate of this species (0-255).")],
    [_INTL("Happiness"),         LimitProperty.new(255),             _INTL("Base happiness of this species (0-255).")],
    [_INTL("Moves"),             LevelUpMovesProperty,               _INTL("Moves which the Pokémon learns while levelling up.")],
    [_INTL("TutorMoves"),        EggMovesProperty.new,               _INTL("Moves which the Pokémon can be taught by TM/HM/Move Tutor.")],
    [_INTL("EggMoves"),          EggMovesProperty.new,               _INTL("Moves which the Pokémon can learn via breeding.")],
    [_INTL("Ability 1"),         AbilityProperty,                    _INTL("One ability which the Pokémon can have.")],
    [_INTL("Ability 2"),         AbilityProperty,                    _INTL("Another ability which the Pokémon can have.")],
    [_INTL("HiddenAbility 1"),   AbilityProperty,                    _INTL("A secret ability which the Pokémon can have.")],
    [_INTL("HiddenAbility 2"),   AbilityProperty,                    _INTL("A secret ability which the Pokémon can have.")],
    [_INTL("HiddenAbility 3"),   AbilityProperty,                    _INTL("A secret ability which the Pokémon can have.")],
    [_INTL("HiddenAbility 4"),   AbilityProperty,                    _INTL("A secret ability which the Pokémon can have.")],
    [_INTL("WildItemCommon"),    GameDataPoolProperty.new(:Item),    _INTL("Item(s) commonly held by wild Pokémon of this species.")],
    [_INTL("WildItemUncommon"),  GameDataPoolProperty.new(:Item),    _INTL("Item(s) uncommonly held by wild Pokémon of this species.")],
    [_INTL("WildItemRare"),      GameDataPoolProperty.new(:Item),    _INTL("Item(s) rarely held by wild Pokémon of this species.")],
    [_INTL("EggGroup 1"),        GameDataProperty.new(:EggGroup),    _INTL("Compatibility group (egg group) for breeding purposes.")],
    [_INTL("EggGroup 2"),        GameDataProperty.new(:EggGroup),    _INTL("Compatibility group (egg group) for breeding purposes.")],
    [_INTL("HatchSteps"),        LimitProperty.new(99_999),          _INTL("Number of steps until an egg of this species hatches.")],
    [_INTL("Incense"),           ItemProperty,                       _INTL("Item needed to be held by a parent to produce an egg of this species.")],
    [_INTL("Offspring"),         GameDataPoolProperty.new(:Species), _INTL("All possible species that an egg can be when breeding for an egg of this species (if blank, the egg can only be this species).")],
    [_INTL("Evolutions"),        EvolutionsProperty.new,             _INTL("Evolution paths of this species.")],
    [_INTL("Height"),            NonzeroLimitProperty.new(999),      _INTL("Height of the Pokémon in 0.1 metres (e.g. 42 = 4.2m).")],
    [_INTL("Weight"),            NonzeroLimitProperty.new(9999),     _INTL("Weight of the Pokémon in 0.1 kilograms (e.g. 42 = 4.2kg).")],
    [_INTL("Color"),             GameDataProperty.new(:BodyColor),   _INTL("Pokémon's body color.")],
    [_INTL("Shape"),             GameDataProperty.new(:BodyShape),   _INTL("Body shape of this species.")],
    [_INTL("Habitat"),           GameDataProperty.new(:Habitat),     _INTL("The habitat of this species.")],
    [_INTL("Generation"),        LimitProperty.new(99_999),          _INTL("The number of the generation the Pokémon debuted in.")],
    [_INTL("Flags"),             StringListProperty,                 _INTL("Words/phrases that distinguish this species from others.")]
  ]
  pbListScreenBlock(_INTL("Pokémon species"), SpeciesLister.new(0, false)) { |button, species|
    if species
      case button
      when Input::ACTION
        if species.is_a?(Symbol) && pbConfirmMessageSerious("Delete this species?")
          GameData::Species::DATA.delete(species)
          GameData::Species.save
          Compiler.write_pokemon
          pbMessage(_INTL("The species was deleted."))
        end
      when Input::USE
        if species.is_a?(Symbol)
          spec = GameData::Species.get(species)
          moves = []
          spec.moves.each_with_index { |m, i| moves.push(m.clone.push(i)) }
          moves.sort! { |a, b| (a[0] == b[0]) ? a[2] <=> b[2] : a[0] <=> b[0] }
          moves.each { |m| m.pop }
          evolutions = []
          spec.evolutions.each { |e| evolutions.push(e.clone) if !e[3] }
          data = [
            spec.id.to_s,
            spec.real_name,
            spec.real_form_name,
            spec.real_category,
            spec.real_pokedex_entry,
            spec.types[0],
            spec.types[1],
            spec.base_stats,
            spec.evs,
            spec.base_exp,
            spec.growth_rate,
            spec.gender_ratio,
            spec.catch_rate,
            spec.happiness,
            moves,
            spec.tutor_moves.clone,
            spec.egg_moves.clone,
            spec.abilities[0],
            spec.abilities[1],
            spec.hidden_abilities[0],
            spec.hidden_abilities[1],
            spec.hidden_abilities[2],
            spec.hidden_abilities[3],
            spec.wild_item_common.clone,
            spec.wild_item_uncommon.clone,
            spec.wild_item_rare.clone,
            spec.egg_groups[0],
            spec.egg_groups[1],
            spec.hatch_steps,
            spec.incense,
            spec.offspring,
            evolutions,
            spec.height,
            spec.weight,
            spec.color,
            spec.shape,
            spec.habitat,
            spec.generation,
            spec.flags.clone
          ]
          # Edit the properties
          if pbPropertyList(spec.id.to_s, data, species_properties, true)
            # Sanitise data
            types = [data[5], data[6]].uniq.compact          # Types
            types = nil if types.empty?
            egg_groups = [data[26], data[27]].uniq.compact   # Egg groups
            egg_groups = nil if egg_groups.empty?
            abilities = [data[17], data[18]].uniq.compact    # Abilities
            hidden_abilities = [data[19], data[20], data[21], data[22]].uniq.compact   # Hidden abilities
            # Construct species hash
            species_hash = {
              :id                 => spec.id,
              :name               => data[1],
              :form_name          => data[2],
              :category           => data[3],
              :pokedex_entry      => data[4],
              :types              => types,              # 5, 6
              :base_stats         => data[7],
              :evs                => data[8],
              :base_exp           => data[9],
              :growth_rate        => data[10],
              :gender_ratio       => data[11],
              :catch_rate         => data[12],
              :happiness          => data[13],
              :moves              => data[14],
              :tutor_moves        => data[15],
              :egg_moves          => data[16],
              :abilities          => abilities,          # 17, 18
              :hidden_abilities   => hidden_abilities,   # 19, 20, 21, 22
              :wild_item_common   => data[23],
              :wild_item_uncommon => data[24],
              :wild_item_rare     => data[25],
              :egg_groups         => egg_groups,         # 26, 27
              :hatch_steps        => data[28],
              :incense            => data[29],
              :offspring          => data[30],
              :evolutions         => data[31],
              :height             => data[32],
              :weight             => data[33],
              :color              => data[34],
              :shape              => data[35],
              :habitat            => data[36],
              :generation         => data[37],
              :flags              => data[38]
            }
            # Add species' data to records
            GameData::Species.register(species_hash)
            GameData::Species.save
            Compiler.write_pokemon
            pbMessage(_INTL("Data saved."))
          end
        else
          pbMessage(_INTL("Can't add a new species."))
        end
      end
    end
  }
end



#===============================================================================
# Regional Dexes editor
#===============================================================================
def pbRegionalDexEditor(dex)
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  cmd_window = pbListWindow([])
  info = Window_AdvancedTextPokemon.newWithSize(
    _INTL("Z+Up/Down: Rearrange entries\nZ+Right: Insert new entry\nZ+Left: Delete entry\nD: Clear entry"),
    Graphics.width / 2, 64, Graphics.width / 2, Graphics.height - 64, viewport
  )
  info.z = 2
  dex.compact!
  ret = dex.clone
  commands = []
  refresh_list = true
  cmd = [0, 0]   # [action, index in list]
  loop do
    # Populate commands
    if refresh_list
      loop do
        break if dex.length == 0 || dex[-1]
        dex.slice!(-1)
      end
      commands = []
      dex.each_with_index do |species, i|
        text = (species) ? GameData::Species.get(species).real_name : "----------"
        commands.push(sprintf("%03d: %s", i + 1, text))
      end
      commands.push(sprintf("%03d: ----------", commands.length + 1))
      cmd[1] = [cmd[1], commands.length - 1].min
      refresh_list = false
    end
    # Choose to do something
    cmd = pbCommands3(cmd_window, commands, -1, cmd[1], true)
    case cmd[0]
    when 1   # Swap entry up
      if cmd[1] < dex.length - 1
        dex[cmd[1] + 1], dex[cmd[1]] = dex[cmd[1]], dex[cmd[1] + 1]
        refresh_list = true
      end
    when 2   # Swap entry down
      if cmd[1] > 0
        dex[cmd[1] - 1], dex[cmd[1]] = dex[cmd[1]], dex[cmd[1] - 1]
        refresh_list = true
      end
    when 3   # Delete spot
      if cmd[1] < dex.length
        dex.delete_at(cmd[1])
        refresh_list = true
      end
    when 4   # Insert spot
      if cmd[1] < dex.length
        dex.insert(cmd[1], nil)
        refresh_list = true
      end
    when 5   # Clear spot
      if dex[cmd[1]]
        dex[cmd[1]] = nil
        refresh_list = true
      end
    when 0
      if cmd[1] >= 0   # Edit entry
        case pbMessage(_INTL("\\ts[]Do what with this entry?"),
                       [_INTL("Change species"), _INTL("Clear"),
                        _INTL("Insert entry"), _INTL("Delete entry"),
                        _INTL("Cancel")], 5)
        when 0   # Change species
          species = pbChooseSpeciesList(dex[cmd[1]])
          if species
            dex[cmd[1]] = species
            dex.each_with_index { |s, i| dex[i] = nil if i != cmd[1] && s == species }
            refresh_list = true
          end
        when 1   # Clear spot
          if dex[cmd[1]]
            dex[cmd[1]] = nil
            refresh_list = true
          end
        when 2   # Insert spot
          if cmd[1] < dex.length
            dex.insert(cmd[1], nil)
            refresh_list = true
          end
        when 3   # Delete spot
          if cmd[1] < dex.length
            dex.delete_at(cmd[1])
            refresh_list = true
          end
        end
      else   # Cancel
        case pbMessage(_INTL("Save changes?"),
                       [_INTL("Yes"), _INTL("No"), _INTL("Cancel")], 3)
        when 0   # Save all changes to Dex
          dex.slice!(-1) until dex[-1]
          ret = dex
          break
        when 1   # Just quit
          break
        end
      end
    end
  end
  info.dispose
  cmd_window.dispose
  viewport.dispose
  ret.compact!
  return ret
end

def pbRegionalDexEditorMain
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  cmd_window = pbListWindow([])
  cmd_window.viewport = viewport
  cmd_window.z        = 2
  title = Window_UnformattedTextPokemon.newWithSize(
    _INTL("Regional Dexes Editor"), Graphics.width / 2, 0, Graphics.width / 2, 64, viewport
  )
  title.z = 2
  info = Window_AdvancedTextPokemon.newWithSize(
    _INTL("Z+Up/Down: Rearrange Dexes"), Graphics.width / 2, 64,
    Graphics.width / 2, Graphics.height - 64, viewport
  )
  info.z = 2
  dex_lists = []
  pbLoadRegionalDexes.each_with_index { |d, index| dex_lists[index] = d.clone }
  commands = []
  refresh_list = true
  oldsel = -1
  cmd = [0, 0]   # [action, index in list]
  loop do
    # Populate commands
    if refresh_list
      commands = [_INTL("[ADD DEX]")]
      dex_lists.each_with_index do |list, i|
        commands.push(_INTL("Dex {1} (size {2})", i + 1, list.length))
      end
      refresh_list = false
    end
    # Choose to do something
    oldsel = -1
    cmd = pbCommands3(cmd_window, commands, -1, cmd[1], true)
    case cmd[0]
    when 1   # Swap Dex up
      if cmd[1] > 0 && cmd[1] < commands.length - 1
        dex_lists[cmd[1] - 1], dex_lists[cmd[1]] = dex_lists[cmd[1]], dex_lists[cmd[1] - 1]
        refresh_list = true
      end
    when 2   # Swap Dex down
      if cmd[1] > 1
        dex_lists[cmd[1] - 2], dex_lists[cmd[1] - 1] = dex_lists[cmd[1] - 1], dex_lists[cmd[1] - 2]
        refresh_list = true
      end
    when 0   # Clicked on a command/Dex
      if cmd[1] == 0   # Add new Dex
        case pbMessage(_INTL("Fill in this new Dex?"),
                       [_INTL("Leave blank"), _INTL("National Dex"),
                        _INTL("Nat. Dex grouped families"), _INTL("Cancel")], 4)
        when 0   # Leave blank
          dex_lists.push([])
          refresh_list = true
        when 1   # Fill with National Dex
          new_dex = []
          GameData::Species.each_species { |s| new_dex.push(s.species) }
          dex_lists.push(new_dex)
          refresh_list = true
        when 2   # Fill with National Dex (grouped families)
          new_dex = []
          seen = []
          GameData::Species.each_species do |s|
            next if seen.include?(s.species)
            family = s.get_family_species
            new_dex.concat(family)
            seen.concat(family)
          end
          dex_lists.push(new_dex)
          refresh_list = true
        end
      elsif cmd[1] > 0   # Edit a Dex
        case pbMessage(_INTL("\\ts[]Do what with this Dex?"),
                       [_INTL("Edit"), _INTL("Copy"), _INTL("Delete"), _INTL("Cancel")], 4)
        when 0   # Edit
          dex_lists[cmd[1] - 1] = pbRegionalDexEditor(dex_lists[cmd[1] - 1])
          refresh_list = true
        when 1   # Copy
          dex_lists[dex_lists.length] = dex_lists[cmd[1] - 1].clone
          cmd[1] = dex_lists.length
          refresh_list = true
        when 2   # Delete
          dex_lists.delete_at(cmd[1] - 1)
          cmd[1] = [cmd[1], dex_lists.length].min
          refresh_list = true
        end
      else   # Cancel
        case pbMessage(_INTL("Save changes?"),
                       [_INTL("Yes"), _INTL("No"), _INTL("Cancel")], 3)
        when 0   # Save all changes to Dexes
          save_data(dex_lists, "Data/regional_dexes.dat")
          $game_temp.regional_dexes_data = nil
          Compiler.write_regional_dexes
          pbMessage(_INTL("Data saved."))
          break
        when 1   # Just quit
          break
        end
      end
    end
  end
  title.dispose
  info.dispose
  cmd_window.dispose
  viewport.dispose
end

def pbAppendEvoToFamilyArray(species, array, seenarray)
  return if seenarray[species]
  array.push(species)
  seenarray[species] = true
  evos = GameData::Species.get(species).get_evolutions
  if evos.length > 0
    subarray = []
    evos.each do |i|
      pbAppendEvoToFamilyArray(i[0], subarray, seenarray)
    end
    array.push(subarray) if subarray.length > 0
  end
end

def pbGetEvoFamilies
  seen = []
  ret = []
  GameData::Species.each_species do |sp|
    species = sp.get_baby_species
    next if seen[species]
    subret = []
    pbAppendEvoToFamilyArray(species, subret, seen)
    ret.push(subret.flatten) if subret.length > 0
  end
  return ret
end

def pbEvoFamiliesToStrings
  ret = []
  families = pbGetEvoFamilies
  families.length.times do |fam|
    string = ""
    families[fam].length.times do |p|
      if p >= 3
        string += " + #{families[fam].length - 3} more"
        break
      end
      string += "/" if p > 0
      string += GameData::Species.get(families[fam][p]).name
    end
    ret[fam] = string
  end
  return ret
end



#===============================================================================
# Battle animations rearranger
#===============================================================================
def pbAnimationsOrganiser
  list = pbLoadBattleAnimations
  if !list || !list[0]
    pbMessage(_INTL("No animations exist."))
    return
  end
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  cmdwin = pbListWindow([])
  cmdwin.viewport = viewport
  cmdwin.z        = 2
  title = Window_UnformattedTextPokemon.newWithSize(
    _INTL("Animations Organiser"), Graphics.width / 2, 0, Graphics.width / 2, 64, viewport
  )
  title.z = 2
  info = Window_AdvancedTextPokemon.newWithSize(
    _INTL("Z+Up/Down: Swap\nZ+Left: Delete\nZ+Right: Insert"),
    Graphics.width / 2, 64, Graphics.width / 2, Graphics.height - 64, viewport
  )
  info.z = 2
  commands = []
  refreshlist = true
  oldsel = -1
  cmd = [0, 0]
  loop do
    if refreshlist
      commands = []
      list.length.times do |i|
        commands.push(sprintf("%d: %s", i, (list[i]) ? list[i].name : "???"))
      end
    end
    refreshlist = false
    oldsel = -1
    cmd = pbCommands3(cmdwin, commands, -1, cmd[1], true)
    case cmd[0]
    when 1   # Swap animation up
      if cmd[1] >= 0 && cmd[1] < commands.length - 1
        list[cmd[1] + 1], list[cmd[1]] = list[cmd[1]], list[cmd[1] + 1]
        refreshlist = true
      end
    when 2   # Swap animation down
      if cmd[1] > 0
        list[cmd[1] - 1], list[cmd[1]] = list[cmd[1]], list[cmd[1] - 1]
        refreshlist = true
      end
    when 3   # Delete spot
      list.delete_at(cmd[1])
      cmd[1] = [cmd[1], list.length - 1].min
      refreshlist = true
      pbWait(Graphics.frame_rate * 2 / 10)
    when 4   # Insert spot
      list.insert(cmd[1], PBAnimation.new)
      refreshlist = true
      pbWait(Graphics.frame_rate * 2 / 10)
    when 0
      cmd2 = pbMessage(_INTL("Save changes?"),
                       [_INTL("Yes"), _INTL("No"), _INTL("Cancel")], 3)
      if [0, 1].include?(cmd2)
        if cmd2 == 0
          # Save animations here
          save_data(list, "Data/PkmnAnimations.rxdata")
          $game_temp.battle_animations_data = nil
          pbMessage(_INTL("Data saved."))
        end
        break
      end
    end
  end
  title.dispose
  info.dispose
  cmdwin.dispose
  viewport.dispose
end
