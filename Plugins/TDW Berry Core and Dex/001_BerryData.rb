#===============================================================================
# Data
#=============================================================================== 
#if Essentials::VERSION.include?("20")
    module GameData
        class BerryData
            attr_reader :id
            # attr_reader :dex_number
            attr_reader :size
            attr_reader :firmness
            attr_reader :flavor
            attr_reader :smoothness
            attr_reader :color
            attr_reader :block_color
            attr_reader :description
            attr_reader :battle_description
            attr_reader :preferred_weather
            attr_reader :preferred_zones
            attr_reader :unpreferred_zones
            attr_reader :preferred_soil
        
            DATA = {}
            DATA_FILENAME = "berry_data.dat"
        
            SCHEMA = {
                # "DexNumber" 	    => [:dex_number, "i"],
                "Size"              => [:size, "f"],
                "Firmness"          => [:firmness, "q"],
                "Flavor" 		    => [:flavor, "uuuuu"],
                "Smoothness" 	    => [:smoothness, "u"],
                "Color"      	    => [:color, "e", :BerryColor],
                "BlockColor"	    => [:block_color, "e", :BerryColor],
                "Description"       => [:description, "q"],
                "BattleDescription" => [:battle_description, "q"],
                "PreferredWeather"	=> [:preferred_weather, "*e", :Weather],
                "PreferredZones"	=> [:preferred_zones, "*s"],
                "UnpreferredZones"	=> [:unpreferred_zones, "*s"],
                "PreferredSoil"	    => [:preferred_soil, "s"]
            }
    
            extend ClassMethodsSymbols
            include InstanceMethods
        
            def initialize(hash)
                @id              	= hash[:id]
                # @dex_number        	= hash[:dex_number]
                @size              	= hash[:size] || 0.0
                @firmness           = hash[:firmness] || "???"
                @flavor 			= hash[:flavor] || {}
                @smoothness 		= hash[:smoothness] || 20
                @color 			    = hash[:color] || :Red
                @block_color 		= hash[:block_color] || @color 
                @description        = hash[:description] || "???"
                @battle_description = hash[:battle_description] || nil
                @preferred_weather  = hash[:preferred_weather] || []
                @preferred_zones    = hash[:preferred_zones] || []
                @unpreferred_zones  = hash[:unpreferred_zones] || []
                @preferred_soil     = hash[:preferred_soil] || nil
            end
            
            # def dex; return @dex_number; end
            def size; return @size; end
            def spicy; return @flavor["Spicy"]; end
            def dry; return @flavor["Dry"]; end
            def sweet; return @flavor["Sweet"]; end
            def bitter; return @flavor["Bitter"]; end
            def sour; return @flavor["Sour"]; end
            def smooth; return @smoothness; end
            def color_name; return GameData::BerryColor.get(@color).name; end
            def block_color_name; return GameData::BerryColor.get(@block_color).name; end
            def preferred_soil; return @preferred_soil&.to_sym; end

            def description
                return pbGetMessageFromHash(MessageTypes::BerryDexDescriptions, @description)
            end

            def battle_description
                return pbGetMessageFromHash(MessageTypes::BerryDexBattleDescriptions, @battle_description)
            end

            def firmness
                return pbGetMessageFromHash(MessageTypes::BerryDexFirmness, @firmness)
            end
    
            def calculatedFlavor
                posArr = [spicy,dry,sweet,bitter,sour]
                negArr = posArr.clone
                negArr.push(negArr.shift)
                compArr = []
                5.times { |i|
                    compArr.push(posArr[i] - negArr[i])
                }
                return [posArr,compArr]
            end
        
            def plusProbability
                prob = [1,5,15,25,40,100]
                PokeblockSettings::SIMPLE_POKEBLOCK_PLUS_PROBABILITY.each_with_index { |(key,value),index|
                    return prob[index] if value.include?(self.id)			
                }
                return 1
            end
        end
        
        GameData.singleton_class.send(:alias_method, :berry_core_data_loadall, :load_all)
        def self.load_all
            berry_core_data_loadall
            BerryData.load
        end
    end

    #===============================================================================
    # Compiler
    #=============================================================================== 
    module Compiler
        module_function
        
        Compiler.singleton_class.send(:alias_method, :berry_core_comp_pbs, :compile_pbs_files)

        def compile_pbs_files
            berry_core_comp_pbs
            compile_berry_data
            compile_berry_dexes
        end
        
        def compile_berry_data(path = "PBS/berry_data.txt")
            compile_pbs_file_message_start(path)
            GameData::BerryData::DATA.clear
            schema = GameData::BerryData::SCHEMA
            dex_descriptions = []
            dex_battle_descriptions = []
            dex_firmness = []
            item_hash = nil
            old_format = nil
            # Read each line of berry_data.txt at a time and compile it into a berry 
            idx = 0
            pbCompilerEachPreppedLine(path) { |line, line_no|
                echo "." if idx % 250 == 0
                idx += 1
                if line[/^\s*\[\s*(.+)\s*\]\s*$/]   # New section [item_id]
                    old_format = false if old_format.nil?
                    if old_format
                        raise _INTL("Can't mix old and new formats.\r\n{1}", FileLineData.linereport)
                    end
                    # Add previous berry plant's data to records
                    GameData::BerryData.register(item_hash) if item_hash
                    # Parse item ID
                    item_id = $~[1].to_sym
                    if GameData::BerryData.exists?(item_id)
                        raise _INTL("Item ID '{1}' is used twice.\r\n{2}", item_id, FileLineData.linereport)
                    end
                    # Construct item hash
                    item_hash = {
                        :id => item_id
                    }
                elsif line[/^\s*(\w+)\s*=\s*(.*)\s*$/]   # XXX=YYY lines
                    old_format = true if old_format.nil?
                    if !item_hash
                        raise _INTL("Expected a section at the beginning of the file.\r\n{1}", FileLineData.linereport)
                    end
                    # Parse property and value
                    property_name = $~[1]
                    line_schema = schema[property_name]
                    next if !line_schema
                    property_value = pbGetCsvRecord($~[2], line_no, line_schema)
                    # Record XXX=YYY setting
                    item_hash[line_schema[0]] = property_value
                    if property_name == "Flavor"
                        item_hash[line_schema[0]] = {"Spicy" => property_value[0], "Dry" => property_value[1],
                            "Sweet" => property_value[2], "Bitter" => property_value[3], "Sour" => property_value[4],}
                    end
                    dex_descriptions.push(item_hash[:description]) if property_name == "Description"
                    dex_battle_descriptions.push(item_hash[:battle_description]) if property_name == "BattleDescription"
                    dex_firmness.push(item_hash[:firmness]) if property_name == "Firmness"
                end
            }
            # Add last berry plant's data to records
            GameData::BerryData.register(item_hash) if item_hash
            # Save all data
            GameData::BerryData.save
            MessageTypes.setMessagesAsHash(MessageTypes::BerryDexDescriptions, dex_descriptions)
            MessageTypes.setMessagesAsHash(MessageTypes::BerryDexBattleDescriptions, dex_battle_descriptions)
            MessageTypes.setMessagesAsHash(MessageTypes::BerryDexFirmness, dex_firmness)
            process_pbs_file_message_end
        end
        
        def compile_berry_data_21(path = "PBS/berry_data.txt")
            compile_pbs_file_message_start(path)
            GameData::BerryData::DATA.clear
            schema = GameData::BerryData::SCHEMA
            dex_descriptions = []
            dex_battle_descriptions = []
            dex_firmness = []
            item_hash = nil
            old_format = nil
            # Read each line of berry_data.txt at a time and compile it into a berry 
            idx = 0
            pbCompilerEachPreppedLine(path) { |line, line_no|
                echo "." if idx % 250 == 0
                idx += 1
                if line[/^\s*\[\s*(.+)\s*\]\s*$/]   # New section [item_id]
                    old_format = false if old_format.nil?
                    if old_format
                        raise _INTL("Can't mix old and new formats.\r\n{1}", FileLineData.linereport)
                    end
                    # Add previous berry plant's data to records
                    GameData::BerryData.register(item_hash) if item_hash
                    # Parse item ID
                    item_id = $~[1].to_sym
                    if GameData::BerryData.exists?(item_id)
                        raise _INTL("Item ID '{1}' is used twice.\r\n{2}", item_id, FileLineData.linereport)
                    end
                    # Construct item hash
                    item_hash = {
                        :id => item_id
                    }
                elsif line[/^\s*(\w+)\s*=\s*(.*)\s*$/]   # XXX=YYY lines
                    old_format = true if old_format.nil?
                    if !item_hash
                        raise _INTL("Expected a section at the beginning of the file.\r\n{1}", FileLineData.linereport)
                    end
                    # Parse property and value
                    property_name = $~[1]
                    line_schema = schema[property_name]
                    next if !line_schema
                    property_value = pbGetCsvRecord($~[2], line_no, line_schema)
                    # Record XXX=YYY setting
                    item_hash[line_schema[0]] = property_value
                    if property_name == "Flavor"
                        item_hash[line_schema[0]] = {"Spicy" => property_value[0], "Dry" => property_value[1],
                            "Sweet" => property_value[2], "Bitter" => property_value[3], "Sour" => property_value[4],}
                    end
                    dex_descriptions.push(item_hash[:description]) if property_name == "Description"
                    dex_battle_descriptions.push(item_hash[:battle_description]) if property_name == "BattleDescription"
                    dex_firmness.push(item_hash[:firmness]) if property_name == "Firmness"
                end
            }
            # Add last berry plant's data to records
            GameData::BerryData.register(item_hash) if item_hash
            # Save all data
            GameData::BerryData.save
            MessageTypes.setMessagesAsHash(MessageTypes::BerryDexDescriptions, dex_descriptions)
            MessageTypes.setMessagesAsHash(MessageTypes::BerryDexBattleDescriptions, dex_battle_descriptions)
            MessageTypes.setMessagesAsHash(MessageTypes::BerryDexFirmness, dex_firmness)
            process_pbs_file_message_end
        end

        def compile_berry_dexes(path = "PBS/berry_dexes.txt")
            compile_pbs_file_message_start(path)
            dex_lists = []
            section = nil
            pbCompilerEachPreppedLine(path) { |line, line_no|
                Graphics.update if line_no % 200 == 0
                if line[/^\s*\[\s*(\d+)\s*\]\s*$/]
                    section = $~[1].to_i
                    if dex_lists[section]
                        raise _INTL("Dex list number {1} is defined at least twice.\r\n{2}", section, FileLineData.linereport)
                    end
                    dex_lists[section] = []
                    else
                    raise _INTL("Expected a section at the beginning of the file.\r\n{1}", FileLineData.linereport) if !section
                    berry_list = line.split(",")
                    berry_list.each do |berry|
                        next if !berry || berry.empty?
                        s = GameData::BerryData.try_get(berry)
                        raise _INTL("Undefined berry constant name: {1}\r\nMake sure the berry is defined in PBS/berry_data.txt.\r\n{2}", berry, FileLineData.linereport) if !s
                        dex_lists[section].push(s)
                    end
                end
            }
            # Check for duplicates
            dex_lists.each_with_index do |list, index|
                unique_list = list.uniq
                next if list == unique_list
                list.each_with_index do |s, i|
                next if unique_list[i] == s
                raise _INTL("Berrydex list number {1} has berry {2} listed twice.\r\n{3}", index, s, FileLineData.linereport)
                end
            end
            # Save all data
            save_data(dex_lists, "Data/berry_dexes.dat")
            process_pbs_file_message_end
        end

    end
#end

module MessageTypes
	BerryDexDescriptions        = 45
	BerryDexFirmness            = 46
	BerryDexBattleDescriptions  = 47
end

#===============================================================================
# Misc Commands
#=============================================================================== 

class PokemonBag
	def hasAnyBerry?
		GameData::Item.each { |i| 
			return true if GameData::Item.get(i.id).is_berry? && $bag.quantity(i.id)>0 
		}
		return false
	end
end

def pbBerryGetNaturalGift(berry)
    berry = GameData::Item.get(berry)
    berry.flags.each { |flag| return [$~[1].to_sym,[$~[2].to_i, 10].max] if flag[/^NaturalGift_(\w+)_(\d+)$/i] }
end

#===============================================================================
# Temporary Suppression 
#=============================================================================== 

module Deprecation
    module_function
  
    Deprecation.singleton_class.send(:alias_method, :tdw_berry_dep_suppress, :warn_method)
    def warn_method(method_name, removal_version = nil, alternative = nil)
        tdw_berry_dep_suppress(method_name, removal_version, alternative) unless method_name == "pbGetCsvRecord"
    end
  end