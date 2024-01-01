#===============================================================================
# Revamps base Essentials code related to PBS Compiling to allow for plugin
# compatibility.
#===============================================================================


#-------------------------------------------------------------------------------
# Allows certain data to be rewritten by plugin compilers.
#-------------------------------------------------------------------------------
module GameData
  class Ability
    attr_accessor :real_name
    attr_accessor :real_description
    attr_accessor :flags
  end

  class Item
    attr_accessor :real_name
    attr_accessor :real_name_plural
    attr_accessor :real_portion_name
    attr_accessor :real_portion_name_plural
    attr_accessor :pocket
    attr_accessor :real_description
    attr_accessor :real_held_description
    attr_accessor :field_use
    attr_accessor :battle_use
    attr_accessor :flags
  end

  class Move
    attr_accessor :real_name
    attr_accessor :type
    attr_accessor :category
    attr_accessor :base_damage
    attr_accessor :accuracy
    attr_accessor :total_pp
    attr_accessor :target
    attr_accessor :priority
    attr_accessor :function_code
    attr_accessor :flags
    attr_accessor :effect_chance
    attr_accessor :real_description
  end
  
  class Species
    attr_accessor :gender_ratio
    attr_accessor :egg_groups
    attr_accessor :egg_moves
    attr_accessor :offspring
    attr_accessor :habitat
    attr_accessor :flags
  end
end


#-------------------------------------------------------------------------------
# Compiler.
#-------------------------------------------------------------------------------
module Compiler
  module_function
  
  PLUGIN_FILES = []
  
  #-----------------------------------------------------------------------------
  # Writing data
  #-----------------------------------------------------------------------------
  alias plugin_write_all write_all
  def write_all
    plugin_write_all
    if !PLUGIN_FILES.empty?
      Console.echo_h1 _INTL("Writing all PBS/Plugin files")
      if PluginManager.installed?("Improved Field Skills")
        write_field_skills
      end
      if PluginManager.installed?("ZUD Mechanics")
        write_dynamax_metrics
        write_power_moves
        write_raid_ranks
        write_lair_maps
      end
      if PluginManager.installed?("Pokémon Birthsigns")
        write_birthsigns
      end
      echoln ""
      Console.echo_h2("Successfully compiled all additional PBS/Plugin files", text: :green)
    end
  end
  
  def write_items(path = "PBS/items.txt")
    write_pbs_file_message_start(path)
    File.open(path, "wb") { |f|
      idx = 0
      add_PBS_header_to_file(f)
      GameData::Item.each do |item|
        echo "." if idx % 50 == 0
        idx += 1
        Graphics.update if idx % 250 == 0
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%s]\r\n", item.id))
        f.write(sprintf("Name = %s\r\n", item.real_name))
        f.write(sprintf("NamePlural = %s\r\n", item.real_name_plural))
        f.write(sprintf("PortionName = %s\r\n", item.real_portion_name)) if item.real_portion_name
        f.write(sprintf("PortionNamePlural = %s\r\n", item.real_portion_name_plural)) if item.real_portion_name_plural
        f.write(sprintf("Pocket = %d\r\n", item.pocket))
        f.write(sprintf("Price = %d\r\n", item.price))
        f.write(sprintf("SellPrice = %d\r\n", item.sell_price)) if item.sell_price != item.price / 2
        field_use = GameData::Item::SCHEMA["FieldUse"][2].key(item.field_use)
        f.write(sprintf("FieldUse = %s\r\n", field_use)) if field_use
        battle_use = GameData::Item::SCHEMA["BattleUse"][2].key(item.battle_use)
        f.write(sprintf("BattleUse = %s\r\n", battle_use)) if battle_use
        f.write(sprintf("Consumable = false\r\n")) if !item.is_important? && !item.consumable
        f.write(sprintf("Flags = %s\r\n", item.flags.join(","))) if item.flags.length > 0
        f.write(sprintf("Move = %s\r\n", item.move)) if item.move
        f.write(sprintf("Description = %s\r\n", item.real_description))
        f.write(sprintf("HeldDescription = %s\r\n", item.real_held_description)) if item.real_held_description
      end
    }
    process_pbs_file_message_end
  end
  
  def write_trainers(path = "PBS/trainers.txt")
    write_pbs_file_message_start(path)
    File.open(path, "wb") { |f|
      idx = 0
      add_PBS_header_to_file(f)
      GameData::Trainer.each do |trainer|
        echo "." if idx % 50 == 0
        idx += 1
        Graphics.update if idx % 250 == 0
        f.write("\#-------------------------------\r\n")
        if trainer.version > 0
          f.write(sprintf("[%s,%s,%d]\r\n", trainer.trainer_type, trainer.real_name, trainer.version))
        else
          f.write(sprintf("[%s,%s]\r\n", trainer.trainer_type, trainer.real_name))
        end
        f.write(sprintf("Items = %s\r\n", trainer.items.join(","))) if trainer.items.length > 0
        if trainer.real_lose_text && !trainer.real_lose_text.empty?
          f.write(sprintf("LoseText = %s\r\n", trainer.real_lose_text))
        end
        trainer.pokemon.each do |pkmn|
          f.write(sprintf("Pokemon = %s,%d\r\n", pkmn[:species], pkmn[:level]))
          f.write(sprintf("    Name = %s\r\n", pkmn[:name])) if pkmn[:name] && !pkmn[:name].empty?
          f.write(sprintf("    Form = %d\r\n", pkmn[:form])) if pkmn[:form] && pkmn[:form] > 0
          f.write(sprintf("    Gender = %s\r\n", (pkmn[:gender] == 1) ? "female" : "male")) if pkmn[:gender]
          f.write("    Shiny = yes\r\n") if pkmn[:shininess] && !pkmn[:super_shininess]
          f.write("    SuperShiny = yes\r\n") if pkmn[:super_shininess]
          f.write("    Shadow = yes\r\n") if pkmn[:shadowness]
          f.write(sprintf("    Moves = %s\r\n", pkmn[:moves].join(","))) if pkmn[:moves] && pkmn[:moves].length > 0
          f.write(sprintf("    Ability = %s\r\n", pkmn[:ability])) if pkmn[:ability]
          f.write(sprintf("    AbilityIndex = %d\r\n", pkmn[:ability_index])) if pkmn[:ability_index]
          f.write(sprintf("    Item = %s\r\n", pkmn[:item])) if pkmn[:item]
          f.write(sprintf("    Nature = %s\r\n", pkmn[:nature])) if pkmn[:nature]
          ivs_array = []
          evs_array = []
          GameData::Stat.each_main do |s|
            next if s.pbs_order < 0
            ivs_array[s.pbs_order] = pkmn[:iv][s.id] if pkmn[:iv]
            evs_array[s.pbs_order] = pkmn[:ev][s.id] if pkmn[:ev]
          end
          f.write(sprintf("    IV = %s\r\n", ivs_array.join(","))) if pkmn[:iv]
          f.write(sprintf("    EV = %s\r\n", evs_array.join(","))) if pkmn[:ev]
          f.write(sprintf("    Happiness = %d\r\n", pkmn[:happiness])) if pkmn[:happiness]
          f.write(sprintf("    Ball = %s\r\n", pkmn[:poke_ball])) if pkmn[:poke_ball]
          f.write("    Ace = yes\r\n") if pkmn[:trainer_ace]
          f.write(sprintf("    Focus = %s\r\n", pkmn[:focus])) if PluginManager.installed?("Focus Meter System") && pkmn[:focus]
          f.write(sprintf("    Birthsign = %s\r\n", pkmn[:birthsign])) if PluginManager.installed?("Pokémon Birthsigns") && pkmn[:birthsign]
          f.write(sprintf("    DynamaxLvl = %d\r\n", pkmn[:dynamax_lvl])) if PluginManager.installed?("ZUD Mechanics") && pkmn[:dynamax_lvl]
          f.write("    Gigantamax = yes\r\n") if PluginManager.installed?("ZUD Mechanics") && pkmn[:gmaxfactor]
          f.write("    Mastery = yes\r\n") if PluginManager.installed?("PLA Battle Styles") && pkmn[:mastery]
          f.write(sprintf("    TeraType = %s\r\n", pkmn[:teratype])) if PluginManager.installed?("Terastal Phenomenon") && pkmn[:teratype]
        end
      end
    }
    process_pbs_file_message_end
  end
  
  #-----------------------------------------------------------------------------
  # Compiles any additional abilities included by a plugin.
  #-----------------------------------------------------------------------------
  def compile_plugin_abilities
    compiled = false
    return if PLUGIN_FILES.empty?
    schema = GameData::Ability::SCHEMA
    ability_names        = []
    ability_descriptions = []
    PLUGIN_FILES.each do |plugin|
      path = "PBS/Plugins/#{plugin}/abilities.txt"
      next if !safeExists?(path)
      compile_pbs_file_message_start(path)
      ability_hash = nil
      idx = 0
      #-------------------------------------------------------------------------
      # Ability is an existing ability to be edited.
      #-------------------------------------------------------------------------
      File.open(path, "rb") { |f|
        FileLineData.file = path
        pbEachFileSectionEx(f) { |contents, ability_id|
          echo "." if idx % 250 == 0
          idx += 1
          FileLineData.setSection(ability_id, "header", nil)
          id = ability_id.to_sym
          next if !GameData::Ability.try_get(id)
          ability = GameData::Ability::DATA[id]
          schema.keys.each do |key|
            if nil_or_empty?(contents[key])
              contents[key] = nil
              next
            end
            FileLineData.setSection(ability_id, key, contents[key])
            value = pbGetCsvRecord(contents[key], key, schema[key])
            value = nil if value.is_a?(Array) && value.length == 0
            contents[key] = value
            case key
            when "Name"
              if ability.real_name != contents[key]
                ability.real_name = contents[key]
                ability_names.push(contents[key])
                compiled = true
              end
            when "Description"
              if ability.real_description != contents[key]
                ability.real_description = contents[key]
                ability_descriptions.push(contents[key])
                compiled = true
              end
            when "Flags"
              contents[key] = [contents[key]] if !contents[key].is_a?(Array)
              contents[key].compact!
              contents[key].each do |flag|
                next if ability.flags.include?(flag)
                if flag.include?("Remove_")
                  string = flag.split("_")
                  ability.flags.delete(string[1])
                else
                  ability.flags.push(flag)
                end
                compiled = true
              end
            end
          end
        }
      }
      #-------------------------------------------------------------------------
      # Ability is a newly added ability.
      #-------------------------------------------------------------------------
      pbCompilerEachPreppedLine(path) { |line, line_no|
        echo "." if idx % 250 == 0
        idx += 1
        if line[/^\s*\[\s*(.+)\s*\]\s*$/]
          GameData::Ability.register(ability_hash) if ability_hash
          ability_id = $~[1].to_sym
          if GameData::Ability.exists?(ability_id)
            ability_hash = nil
            next
          end
          ability_hash = {
            :id => ability_id
          }
        elsif line[/^\s*(\w+)\s*=\s*(.*)\s*$/] && !ability_hash.nil?
          property_name = $~[1]
          if property_name == "EditOnly"
            ability_hash = nil
            next
          end
          line_schema = schema[property_name]
          next if !line_schema
          property_value = pbGetCsvRecord($~[2], line_no, line_schema)
          ability_hash[line_schema[0]] = property_value
          case property_name
          when "Name"
            ability_names.push(ability_hash[:name])
          when "Description"
            ability_descriptions.push(ability_hash[:description])
          end
        end
      }
      if ability_hash
        GameData::Ability.register(ability_hash)
        compiled = true
      end
      process_pbs_file_message_end
      begin
        File.delete(path)
        rescue SystemCallError
      end
    end
    if compiled
      GameData::Ability.save
      Compiler.write_abilities
      MessageTypes.setMessagesAsHash(MessageTypes::Abilities, ability_names)
      MessageTypes.setMessagesAsHash(MessageTypes::AbilityDescs, ability_descriptions)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Compiles any additional items included by a plugin.
  #-----------------------------------------------------------------------------
  def compile_plugin_items
    compiled = false
    return if PLUGIN_FILES.empty?
    schema = GameData::Item::SCHEMA
    item_names                = []
    item_names_plural         = []
    item_portion_names        = []
    item_portion_names_plural = []
    item_descriptions         = []
    item_held_descriptions    = []
    PLUGIN_FILES.each do |plugin|
      path = "PBS/Plugins/#{plugin}/items.txt"
      next if !safeExists?(path)
      compile_pbs_file_message_start(path)
      item_hash = nil
      idx = 0
      #-------------------------------------------------------------------------
      # Item is an existing item to be edited.
      #-------------------------------------------------------------------------
      File.open(path, "rb") { |f|
        FileLineData.file = path
        pbEachFileSectionEx(f) { |contents, item_id|
          echo "." if idx % 250 == 0
          idx += 1
          FileLineData.setSection(item_id, "header", nil)
          id = item_id.to_sym
          next if !GameData::Item.try_get(id)
          item = GameData::Item::DATA[id]
          schema.keys.each do |key|
            if nil_or_empty?(contents[key])
              contents[key] = nil
              next
            end
            FileLineData.setSection(item_id, key, contents[key])
            value = pbGetCsvRecord(contents[key], key, schema[key])
            value = nil if value.is_a?(Array) && value.length == 0
            contents[key] = value
            case key
            when "Name"
              if item.real_name != contents[key]
                item.real_name = contents[key]
                item_names.push(contents[key])
                compiled = true
              end
            when "NamePlural"
              if item.real_name_plural != contents[key]
                item.real_name_plural = contents[key]
                item_names_plural.push(contents[key])
                compiled = true
              end
            when "PortionName"
              if item.real_portion_name != contents[key]
                item.real_portion_name = contents[key]
                item_portion_names.push(contents[key])
                compiled = true
              end
            when "PortionNamePlural"
              if item.real_portion_name_plural != contents[key]
                item.real_portion_name_plural = contents[key]
                item_portion_names_plural.push(contents[key])
                compiled = true
              end
            when "Description"
              if item.real_description != contents[key]
                item.real_description = contents[key]
                item_descriptions.push(contents[key])
                compiled = true
              end
            when "HeldDescription"
              if item.real_held_description != contents[key]
                item.real_held_description = contents[key]
                item_held_descriptions.push(contents[key])
                compiled = true
              end
            when "Flags"
              contents[key] = [contents[key]] if !contents[key].is_a?(Array)
              contents[key].compact!
              contents[key].each do |flag|
                next if item.flags.include?(flag)
                if flag.include?("Remove_")
                  string = flag.split("_")
                  item.flags.delete(string[1])
                else
                  item.flags.push(flag)
                end
                compiled = true
              end
            when "Pocket"
              if item.pocket != contents[key]
                item.pocket = contents[key]
                compiled = true
              end
            when "FieldUse"
              if item.field_use != contents[key]
                item.field_use = contents[key]
                compiled = true
              end
            when "BattleUse"
              if item.battle_use != contents[key]
                item.battle_use = contents[key]
                compiled = true
              end
            end
          end
        }
      }
	  #-------------------------------------------------------------------------
	  # Item is a newly added item.
	  #-------------------------------------------------------------------------
      pbCompilerEachPreppedLine(path) { |line, line_no|
        echo "." if idx % 250 == 0
        idx += 1
        if line[/^\s*\[\s*(.+)\s*\]\s*$/]
          GameData::Item.register(item_hash) if item_hash
          item_id = $~[1].to_sym
          if GameData::Item.exists?(item_id)
            item_hash = nil
            next
          end
          item_hash = {
            :id => item_id
          }
        elsif line[/^\s*(\w+)\s*=\s*(.*)\s*$/] && !item_hash.nil?
          property_name = $~[1]
          if property_name == "EditOnly"
            item_hash = nil
            next
          end
          line_schema = schema[property_name]
          next if !line_schema
          property_value = pbGetCsvRecord($~[2], line_no, line_schema)
          item_hash[line_schema[0]] = property_value
          case property_name
          when "Name"
            item_names.push(item_hash[:name])
          when "NamePlural"
            item_names_plural.push(item_hash[:name_plural])
          when "PortionName"
            item_portion_names.push(item_hash[:portion_name])
          when "PortionNamePlural"
            item_portion_names_plural.push(item_hash[:portion_name_plural])
          when "Description"
            item_descriptions.push(item_hash[:description])
          when "HeldDescription"
            item_held_descriptions.push(item_hash[:held_description])
          end
        end
      }
      if item_hash
        GameData::Item.register(item_hash)
        compiled = true
      end
      process_pbs_file_message_end
      begin
        File.delete(path)
        rescue SystemCallError
      end
    end
    if compiled
      GameData::Item.save
      Compiler.write_items
      MessageTypes.setMessagesAsHash(MessageTypes::Items, item_names)
      MessageTypes.setMessagesAsHash(MessageTypes::ItemPlurals, item_names_plural)
      MessageTypes.setMessagesAsHash(MessageTypes::ItemPortionNames, item_portion_names)
      MessageTypes.setMessagesAsHash(MessageTypes::ItemPortionNamePlurals, item_portion_names_plural)
      MessageTypes.setMessagesAsHash(MessageTypes::ItemDescriptions, item_descriptions)
      MessageTypes.setMessagesAsHash(MessageTypes::ItemHeldDescriptions, item_held_descriptions)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Compiles any additional moves included by a plugin.
  #-----------------------------------------------------------------------------
  def compile_plugin_moves
    compiled = false
    return if PLUGIN_FILES.empty?
    schema = GameData::Move::SCHEMA
    move_names        = []
    move_descriptions = []
    PLUGIN_FILES.each do |plugin|
      path = "PBS/Plugins/#{plugin}/moves.txt"
      next if !safeExists?(path)
      compile_pbs_file_message_start(path)
      move_hash = nil
      idx = 0
      #-------------------------------------------------------------------------
      # Move is an existing move to be edited.
      #-------------------------------------------------------------------------
      File.open(path, "rb") { |f|
        FileLineData.file = path
        pbEachFileSectionEx(f) { |contents, move_id|
          echo "." if idx % 500 == 0
          idx += 1
          FileLineData.setSection(move_id, "header", nil)
          id = move_id.to_sym
          next if !GameData::Move.try_get(id)
          move = GameData::Move::DATA[id]
          schema.keys.each do |key|
            if nil_or_empty?(contents[key])
              contents[key] = nil
              next
            end
            compiled = true
            FileLineData.setSection(move_id, key, contents[key])
            value = pbGetCsvRecord(contents[key], key, schema[key])
            value = nil if value.is_a?(Array) && value.length == 0
            contents[key] = value
            case key
            when "Name"
              if move.real_name != contents[key]
                move.real_name = contents[key]
                move_names.push(contents[key])
              end
            when "Description"
              if move.real_description != contents[key]
                move.real_description = contents[key]
                move_descriptions.push(contents[key])
              end
            when "Flags"
              contents[key] = [contents[key]] if !contents[key].is_a?(Array)
              contents[key].compact!
              contents[key].each do |flag|
                next if move.flags.include?(flag)
                if flag.include?("Remove_")
                  string = flag.split("_")
                  move.flags.delete(string[1])
                else
                  move.flags.push(flag)
                end
              end
            when "Type"         then move.type          = contents[key] if move.type          != contents[key]
            when "Category"     then move.category      = contents[key] if move.category      != contents[key]
            when "Power"        then move.base_damage   = contents[key] if move.base_damage   != contents[key]
            when "Accuracy"     then move.accuracy      = contents[key] if move.accuracy      != contents[key]
            when "TotalPP"      then move.total_pp      = contents[key] if move.total_pp      != contents[key]
            when "Target"       then move.target        = contents[key] if move.target        != contents[key]
            when "Priority"     then move.priority      = contents[key] if move.priority      != contents[key]
            when "FunctionCode" then move.function_code = contents[key] if move.function_code != contents[key]
            when "EffectChance" then move.effect_chance = contents[key] if move.effect_chance != contents[key]
            end
          end
        }
      }
      #-------------------------------------------------------------------------
      # Move is a newly added move.
      #-------------------------------------------------------------------------
      pbCompilerEachPreppedLine(path) { |line, line_no|
        echo "." if idx % 500 == 0
        idx += 1
        if line[/^\s*\[\s*(.+)\s*\]\s*$/]
          if move_hash
            if (move_hash[:category] || 2) == 2 && (move_hash[:base_damage] || 0) != 0
              raise _INTL("Move {1} is defined as a Status move with a non-zero base damage.\r\n{2}", line[2], FileLineData.linereport)
            elsif (move_hash[:category] || 2) != 2 && (move_hash[:base_damage] || 0) == 0
              print _INTL("Warning: Move {1} was defined as Physical or Special but had a base damage of 0. Changing it to a Status move.\r\n{2}", line[2], FileLineData.linereport)
              move_hash[:category] = 2
            end
            GameData::Move.register(move_hash)
          end
          move_id = $~[1].to_sym
          if GameData::Move.exists?(move_id)
            move_hash = nil
            next
          end
          move_hash = {
            :id => move_id
          }
        elsif line[/^\s*(\w+)\s*=\s*(.*)\s*$/] && !move_hash.nil?
          property_name = $~[1]
          if property_name == "EditOnly"
            move_hash = nil
            next
          end
          line_schema = schema[property_name]
          next if !line_schema
          property_value = pbGetCsvRecord($~[2], line_no, line_schema)
          move_hash[line_schema[0]] = property_value
          case property_name
          when "Name"
            move_names.push(move_hash[:name])
          when "Description"
            move_descriptions.push(move_hash[:description])
          end
        end
      }
      if move_hash
        if (move_hash[:category] || 2) == 2 && (move_hash[:base_damage] || 0) != 0
          raise _INTL("Move {1} is defined as a Status move with a non-zero base damage.\r\n{2}", line[2], FileLineData.linereport)
        elsif (move_hash[:category] || 2) != 2 && (move_hash[:base_damage] || 0) == 0
          print _INTL("Warning: Move {1} was defined as Physical or Special but had a base damage of 0. Changing it to a Status move.\r\n{2}", line[2], FileLineData.linereport)
          move_hash[:category] = 2
        end
        GameData::Move.register(move_hash)
        compiled = true
      end
      process_pbs_file_message_end
      begin
        File.delete(path)
        rescue SystemCallError
      end
    end
    if compiled
      GameData::Move.save
      Compiler.write_moves
      MessageTypes.setMessagesAsHash(MessageTypes::Moves, move_names)
      MessageTypes.setMessagesAsHash(MessageTypes::MoveDescriptions, move_descriptions)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Compiles changes to species data altered by a plugin.
  #-----------------------------------------------------------------------------
  def compile_plugin_species_data
    compiled = false
    return if PLUGIN_FILES.empty?
    schema = {
      "GenderRatio" => [0, "e",  :GenderRatio],
      "EggMoves"    => [0, "*e", :Move],
      "EggGroups"   => [0, "*e", :EggGroup],
      "Offspring"   => [0, "*e", :Species],
      "Habitat"     => [0, "e",  :Habitat],
      "Flags"       => [0, "*s"]
    }
    PLUGIN_FILES.each do |plugin|
      path = "PBS/Plugins/#{plugin}/pokemon.txt"
      next if !safeExists?(path)
      compile_pbs_file_message_start(path)
      File.open(path, "rb") { |f|
        FileLineData.file = path
        idx = 0
        pbEachFileSectionEx(f) { |contents, species_id|
          FileLineData.setSection(species_id, "header", nil)
          id = species_id.to_sym
          next if !GameData::Species.try_get(id)
          species = GameData::Species::DATA[id]
          schema.keys.each do |key|
            if nil_or_empty?(contents[key])
              contents[key] = nil
            end
            FileLineData.setSection(species_id, key, contents[key])
            if !contents[key].nil?
              value = pbGetCsvRecord(contents[key], key, schema[key])
              value = nil if value.is_a?(Array) && value.length == 0
              contents[key] = value
            end
            case key
            when "GenderRatio"
              next if contents[key].nil?
              species.gender_ratio = contents[key]
            when "Habitat"
              next if contents[key].nil?
              species.habitat = contents[key]
            when "EggGroups"
              if species.form > 0 && contents[key].nil?
                base_groups = GameData::Species.get(species.species).egg_groups
                species.egg_groups = base_groups
              else
                next if contents[key].nil?
                contents[key] = [contents[key]] if !contents[key].is_a?(Array)
                contents[key].compact!
                species.egg_groups = contents[key]
              end
            when "Flags"
              contents[key] = [contents[key]] if !contents[key].is_a?(Array)
              contents[key].compact!
              contents[key].each do |flag|
                next if species.flags.include?(flag)
                if flag.include?("Remove_")
                  string = flag.split("_")
                  species.flags.delete(string[1])
                else
                  species.flags.push(flag)
                end
              end
            when "EggMoves", "Offspring"
              contents[key] = [contents[key]] if !contents[key].is_a?(Array)
              contents[key].compact!
              species.egg_moves  = contents[key] if key == "EggMoves"
              species.offspring  = contents[key] if key == "Offspring"
            end
          end
          compiled = true
        }
      }
      process_pbs_file_message_end
      begin
        File.delete(path)
        rescue SystemCallError
      end
    end
    if compiled
      GameData::Species.save
      Compiler.write_pokemon
      Compiler.write_pokemon_forms
      Compiler.compile_pokemon
      Compiler.compile_pokemon_forms
    end
  end
  
  
  #-----------------------------------------------------------------------------
  # Compiles changes to map metadata altered by a plugin.
  #-----------------------------------------------------------------------------
  def compile_plugin_map_metadata
    compiled = false
    return if PLUGIN_FILES.empty?
    schema = GameData::MapMetadata::SCHEMA
    PLUGIN_FILES.each do |plugin|
      path = "PBS/Plugins/#{plugin}/map_metadata.txt"
      next if !safeExists?(path)
      compile_pbs_file_message_start(path)
      idx = 0
      File.open(path, "rb") { |f|
        FileLineData.file = path
        pbEachFileSectionNumbered(f) { |contents, map_id|
          echo "." if idx % 50 == 0
          idx += 1
          Graphics.update if idx % 250 == 0
          FileLineData.setSection(map_id, "header", nil)
          next if !GameData::MapMetadata::DATA[map_id]
          map = GameData::MapMetadata::DATA[map_id]
          schema.each_key do |key|
            if nil_or_empty?(contents[key])
              contents[key] = nil
              next
            end
            FileLineData.setSection(map_id, key, contents[key])
            value = pbGetCsvRecord(contents[key], key, schema[key])
            value = nil if value.is_a?(Array) && value.length == 0
            contents[key] = value
            case key
            when "Flags"
              contents[key] = [contents[key]] if !contents[key].is_a?(Array)
              contents[key].compact!
              contents[key].each do |flag|
                next if map.flags.include?(flag)
                if flag.include?("Remove_")
                  string = flag.split("_")
                  map.flags.delete(string[1])
                else
                  map.flags.push(flag)
                end
                compiled = true
              end
            end
          end
        }
      }
      process_pbs_file_message_end
      begin
        File.delete(path)
        rescue SystemCallError
      end
    end
    if compiled
      GameData::MapMetadata.save
      Compiler.write_map_metadata
    end
  end
  
  
  #-----------------------------------------------------------------------------
  # Compiling all plugin data
  #-----------------------------------------------------------------------------
  def compile_all(mustCompile)
    PLUGIN_FILES.each do |plugin|
      for file in ["abilities", "items", "moves", "pokemon", "map_metadata"]
        path = "PBS/Plugins/#{plugin}/#{file}.txt"
        mustCompile = true if safeExists?(path)
      end
      if plugin == "Improved Field Skills"
        path = "PBS/Plugins/#{plugin}/field_skills.txt"
        mustCompile = true if !safeExists?(path)
      end
    end
    return if !mustCompile
    FileLineData.clear
    Console.echo_h1 _INTL("Starting full compile")
    compile_pbs_files
    if !PLUGIN_FILES.empty?
      echoln ""
      Console.echo_h1 _INTL("Compiling additional plugin data")
      compile_plugin_abilities
      compile_plugin_items
      compile_plugin_moves
      compile_plugin_species_data
      compile_plugin_map_metadata
      echoln ""
      if PluginManager.installed?("Improved Field Skills")
        Console.echo_li "Improved Field Skills"
        write_field_skills       # Depends on Species, Moves
        Console.echo_li "Improved Field Skills"
        compile_field_skills     # Depends on Species
      end
      if PluginManager.installed?("ZUD Mechanics")
        Console.echo_li "ZUD Mechanics"
        compile_lair_maps
        Console.echo_li "ZUD Mechanics"
        compile_raid_ranks       # Depends on Species
        Console.echo_li "ZUD Mechanics"
        compile_power_moves      # Depends on Moves, Items, Types, Species
        Console.echo_li "ZUD Mechanics"
        compile_dynamax_metrics  # Depends on Species, Power Moves
      end
      if PluginManager.installed?("Pokémon Birthsigns")
        Console.echo_li "Pokémon Birthsigns"
        compile_birthsigns       # Depends on Types, Moves, Abilities, Species
      end
      echoln ""
      Console.echo_h2("Plugin data fully compiled", text: :green)
      echoln ""
    end
    compile_animations
    compile_trainer_events(mustCompile)
    Console.echo_li _INTL("Saving messages...")
    pbSetTextMessages
    MessageTypes.saveMessages
    MessageTypes.loadMessageFile("Data/messages.dat") if safeExists?("Data/messages.dat")
    Console.echo_done(true)
    Console.echo_li _INTL("Reloading cache...")
    System.reload_cache
    Console.echo_done(true)
    echoln ""
    Console.echo_h2("Successfully fully compiled", text: :green)
  end
  
  def main
    return if !$DEBUG
    begin
      dataFiles = [
        "abilities.dat",
        "berry_plants.dat",
        "encounters.dat",
        "items.dat",
        "map_connections.dat",
        "map_metadata.dat",
        "metadata.dat",
        "moves.dat",
        "phone.dat",
        "player_metadata.dat",
        "regional_dexes.dat",
        "ribbons.dat",
        "shadow_pokemon.dat",
        "species.dat",
        "species_metrics.dat",
        "town_map.dat",
        "trainer_lists.dat",
        "trainer_types.dat",
        "trainers.dat",
        "types.dat"
      ]
      textFiles = [
        "abilities.txt",
        "battle_facility_lists.txt",
        "berry_plants.txt",
        "encounters.txt",
        "items.txt",
        "map_connections.txt",
        "map_metadata.txt",
        "metadata.txt",
        "moves.txt",
        "phone.txt",
        "pokemon.txt",
        "pokemon_forms.txt",
        "pokemon_metrics.txt",
        "regional_dexes.txt",
        "ribbons.txt",
        "shadow_pokemon.txt",
        "town_map.txt",
        "trainer_types.txt",
        "trainers.txt",
        "types.txt"
      ]
      if PluginManager.installed?("ZUD Mechanics")
        dataFiles.push("power_moves.dat", "raid_ranks.dat", "adventure_maps.dat")
        textFiles.push("Plugins/ZUD/power_moves.txt", "Plugins/ZUD/raid_ranks.txt", "Plugins/ZUD/adventure_maps.txt")
      end
      if PluginManager.installed?("Pokémon Birthsigns")
        dataFiles.push("birthsigns.dat")
        textFiles.push("Plugins/Birthsigns/birthsigns.txt")
      end
      latestDataTime = 0
      latestTextTime = 0
      mustCompile = false
      mustCompile |= import_new_maps
      if !safeIsDirectory?("PBS")
        Dir.mkdir("PBS") rescue nil
        write_all
        mustCompile = true
      end
      dataFiles.each do |filename|
        if safeExists?("Data/" + filename)
          begin
            File.open("Data/#{filename}") { |file|
              latestDataTime = [latestDataTime, file.mtime.to_i].max
            }
          rescue SystemCallError
            mustCompile = true
          end
        else
          mustCompile = true
          break
        end
      end
      textFiles.each do |filename|
        next if !safeExists?("PBS/" + filename)
        begin
          File.open("PBS/#{filename}") { |file|
            latestTextTime = [latestTextTime, file.mtime.to_i].max
          }
        rescue SystemCallError
        end
      end
      mustCompile |= (latestTextTime >= latestDataTime)
      Input.update
      mustCompile = true if Input.press?(Input::CTRL)
      if mustCompile
        dataFiles.length.times do |i|
          begin
            File.delete("Data/#{dataFiles[i]}") if safeExists?("Data/#{dataFiles[i]}")
          rescue SystemCallError
          end
        end
      end
      compile_all(mustCompile)
      rescue Exception
      e = $!
      raise e if e.class.to_s == "Reset" || e.is_a?(Reset) || e.is_a?(SystemExit)
      pbPrintException(e)
      dataFiles.length.times do |i|
        begin
          File.delete("Data/#{dataFiles[i]}")
        rescue SystemCallError
        end
      end
      raise Reset.new if e.is_a?(Hangup)
      loop do
        Graphics.update
      end
    end
  end
end


#-------------------------------------------------------------------------------
# Plugin manager.
#-------------------------------------------------------------------------------
module PluginManager
  class << PluginManager
    alias dx_register register
  end
  
  def self.register(options)
    dx_register(options)
    self.dx_plugin_check
  end
  
  # Used to ensure all plugins that rely on Essentials Deluxe are up to date.
  def self.dx_plugin_check(version = "1.2.2")
    if self.installed?("Essentials Deluxe", version, true)
      {"ZUD Mechanics"         => "1.1.7",
       "Enhanced UI"           => "1.0.9",
       "Focus Meter System"    => "1.0.9",
       "PLA Battle Styles"     => "1.0.7",
       "Improved Field Skills" => "1.0.4",
       "Legendary Breeding"    => "1.0.1",
       "Improved Item Text"    => "1.0.1",
       "Terastal Phenomenon"   => "1.0",
       "Pokémon Birthsigns"    => "1.0"
      }.each do |p_name, v_num|
        next if !self.installed?(p_name)
        p_ver = self.version(p_name)
        valid = self.compare_versions(p_ver, v_num)
        next if valid > -1
        link = self.link(p_name)
        self.error("Plugin '#{p_name}' is out of date.\nPlease download the latest version at:\n#{link}")
      end
    end
  end
end


#-------------------------------------------------------------------------------
# General debug menus.
#-------------------------------------------------------------------------------
MenuHandlers.add(:debug_menu, :dx_menu, {
  "name"        => _INTL("Deluxe Plugins..."),
  "parent"      => :main,
  "description" => _INTL("Edit settings related to various plugins that utilize Essentials Deluxe.")
})


MenuHandlers.add(:debug_menu, :deluxe_menu, {
  "name"        => _INTL("Essentials Deluxe..."),
  "parent"      => :dx_menu,
  "description" => _INTL("Edit settings related to the Essentials Deluxe plugin.")
})


MenuHandlers.add(:debug_menu, :debug_mega, {
  "name"        => _INTL("Toggle Switch"),
  "parent"      => :deluxe_menu,
  "description" => _INTL("Toggles the availability of Mega Evolution functionality."),
  "effect"      => proc {
    $game_switches[Settings::NO_MEGA_EVOLUTION] = !$game_switches[Settings::NO_MEGA_EVOLUTION]
    toggle = ($game_switches[Settings::NO_MEGA_EVOLUTION]) ? "disabled" : "enabled"
    pbMessage(_INTL("Mega Evolution {1}.", toggle))
  }
})


#-------------------------------------------------------------------------------
# Pokemon debug menus.
#-------------------------------------------------------------------------------
MenuHandlers.add(:pokemon_debug_menu, :dx_pokemon_menu, {
  "name"   => _INTL("Deluxe Options..."),
  "parent" => :main
})


MenuHandlers.add(:pokemon_debug_menu, :set_ace, {
  "name"   => _INTL("Toggle Ace"),
  "parent" => :dx_pokemon_menu,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    if pkmn.ace?
      pkmn.ace = false
      toggle = "unflagged"
    else
      pkmn.ace = true
      toggle = "flagged"
    end
    screen.pbDisplay(_INTL("{1} is {2} as an ace Pokémon.", pkmn.name, toggle))
    next false
  }
})