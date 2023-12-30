#====================================================================================
#  DO NOT MAKE EDITS HERE
#====================================================================================

#====================================================================================
# Move Data
#====================================================================================
module GameData
	class Move
		attr_accessor :contest_type
		attr_accessor :contest_hearts
		attr_accessor :contest_jam
		attr_accessor :contest_function_code
		attr_accessor :contest_flags
		attr_accessor :contest_description

		CONTEST_SCHEMA = {
		  "ContestType"         => [:contest_type,     "E", :ContestType],
		  "ContestHearts"       => [:contest_hearts,   "U"],
		  "ContestJam"     		=> [:contest_jam,      "U"],
		  "ContestFunctionCode" => [:contest_function_code, "E", :ContestMoveFunction],
		  "ContestFlags"        => [:contest_flags,         "*s"],
		  "ContestDescription"  => [:contest_description,   "q"],
		}

		extend ClassMethodsSymbols
		include InstanceMethods
	
		# alias contests_move_init initialize
		# def initialize(hash)
		  # contests_move_init(hash)
		  # # @contest_type     		= hash[:contest_type]     || :NONE
		  # # @contest_hearts   		= hash[:contest_hearts]   || 0
		  # # @contest_jam      		= hash[:contest_jam]      || 0
		  # # @contest_function_code    = hash[:contest_function_code] || "None"
		  # # @contest_flags            = hash[:contest_flags]         || []
		  # # @contest_flags            = [@contest_flags] if !@contest_flags.is_a?(Array)
		  # # @contest_description 		= hash[:contest_description]   || "???"
		  # @contest_type     		= hash[:contest_type]     || :NONE
		  # @contest_hearts   		= hash[:contest_hearts]   || nil
		  # @contest_jam      		= hash[:contest_jam]      || nil
		  # @contest_function_code    = hash[:contest_function_code] || nil
		  # @contest_flags            = hash[:contest_flags]         || []
		  # @contest_flags            = [@contest_flags] if !@contest_flags.is_a?(Array)
		  # @contest_description 		= hash[:contest_description]   || nil
		# end

		# @return [String] the translated description of this move
		def contest_description(compile = false)
			return getFunctionContestDescription if !compile && ContestSettings::GET_MOVE_DESCRIPTIONS_FROM_FUNCTION
			return _INTL("Cannot be used in a contest.") if !compile && !contest_can_be_used?
			return pbGetMessageFromHash(MessageTypes::MoveContestDescriptions, @contest_description)
		end

		def has_contest_flag?(flag)
			return @contest_flags.any? { |f| f.downcase == flag.downcase }
		end
	
		alias contests_hasflag has_flag?
		def has_flag?(flag)
			ret = contests_hasflag(flag)
			return ret || has_contest_flag?(flag)
		end
		
		def contest_type_position
			return 5 if !contest_can_be_used?
			return GameData::ContestType.get(@contest_type).icon_index || 0
		end	
		
		def startsContestCombo
			return ContestSettings::COMBOS.include?(self.id)
			return false
		end
		
		def contest_can_be_used?
			return false if (has_contest_flag?("CannotBeUsed") || @contest_function_code.nil?)
			return true
		end
		
		def is_positive_category?(contestCategory)
			return contest_type_position == contestCategory
		end
	
		def is_neutral_category?(contestCategory)
			case contestCategory
			when 0
				return [4,1].include?(contest_type_position)
			when 1
				return [0,2].include?(contest_type_position)
			when 2
				return [1,3].include?(contest_type_position)
			when 3
				return [2,4].include?(contest_type_position)
			when 4
				return [3,0].include?(contest_type_position)
			end
			return false
		end
	
		def is_negative_category?(contestCategory)
			case contestCategory
			when 0
				return [3,2].include?(contest_type_position)
			when 1
				return [4,3].include?(contest_type_position)
			when 2
				return [0,4].include?(contest_type_position)
			when 3
				return [1,0].include?(contest_type_position)
			when 4
				return [2,1].include?(contest_type_position)
			end
			return false
		end

	end
end

#====================================================================================
# Compiler
#====================================================================================
module Compiler
	module_function

	def write_moves_contests(path = "PBS/movesx_contest.txt")
		write_pbs_file_message_start(path)
		File.open(path, "wb") { |f|
			idx = 0
			#add_PBS_header_to_file(f)
			# Write each move in turn
			GameData::Move.each do |move|
				echo "." if idx % 50 == 0
				idx += 1
				Graphics.update if idx % 250 == 0
				f.write("\#-------------------------------\r\n")
				f.write("[#{move.id}]\r\n")
				f.write("\##{move.real_name}\r\n")
				if move.contest_type == nil then f.write("ContestType = NONE\r\n");
				else f.write("ContestType = #{move.contest_type}\r\n"); end
				f.write("ContestHearts = #{move.contest_hearts}\r\n");
				f.write("ContestJam = #{move.contest_jam}\r\n");
				f.write("ContestFunctionCode = #{move.contest_function_code}\r\n");
				if move.contest_flags then f.write("ContestFlags = #{move.contest_flags.join(',')}\r\n");
				else f.write("ContestFlags = \r\n"); end
				f.write("ContestDescription = #{move.contest_description(true)}\r\n");
			end
		}
		process_pbs_file_message_end
	end
  
	self.singleton_class.send(:alias_method, :contests_move_compiler_, :compile_moves)

	def compile_moves(path = "PBS/moves.txt")
		contests_move_compiler_(path)
		path = "PBS/movesx_contest.txt"
		compile_pbs_file_message_start(path)
		schema = GameData::Move::CONTEST_SCHEMA
		move_contest_descriptions = []
		move_contest_hash = nil
		idx = 0
		pbCompilerEachPreppedLine(path) { |line, line_no|
			echo "." if idx % 500 == 0
			idx += 1
			if line[/^\s*\[\s*(.+)\s*\]\s*$/]   # New section [move_id]
				# Add previous move's data to records		
				contestMovesMerge(move_contest_hash) if move_contest_hash
				move_id = $~[1].to_sym
				move_contest_hash = {:id => move_id }
			elsif line[/^\s*(\w+)\s*=\s*(.*)\s*$/]   # XXX=YYY lines
				if !move_contest_hash
					raise _INTL("Expected a section at the beginning of the file.\r\n{1}", FileLineData.linereport)
				end
				# Parse property and value
				property_name = $~[1]
				property_value = $~[2]
				if property_name == "ContestFunctionCode" && property_value.to_i_threedigit.to_s == property_value
					Console.echo_warn _INTL("#{move_contest_hash[:id]} has an old integer function code (#{property_value}). It will be cleared if written to movesx_contest.txt.")
				end
				line_schema = schema[property_name]
				next if !line_schema
				next if property_name == "Name" #|| property_value.empty?
				property_value = pbGetCsvRecord(property_value, line_no, line_schema)
				# Record XXX=YYY setting
				move_contest_hash[line_schema[0]] = property_value
				move_contest_descriptions.push(move_contest_hash[:contest_description]) if property_name == "ContestDescription"
			end
		}
		# Add last move's data to records
		contestMovesMerge(move_contest_hash) if move_contest_hash
		GameData::Move.save
		MessageTypes.setMessagesAsHash(MessageTypes::MoveContestDescriptions, move_contest_descriptions)
		process_pbs_file_message_end
	end
  
	def contestMovesMerge(hash)
		#GameData::Move.get(move_contest_hash[:id]).merge!(move_contest_hash) if move_contest_hash
		original = GameData::Move.get(hash[:id])
		original.contest_type = hash[:contest_type]
		original.contest_hearts = hash[:contest_hearts]
		original.contest_jam = hash[:contest_jam]
		original.contest_function_code = hash[:contest_function_code]
		original.contest_flags = hash[:contest_flags]
		original.contest_flags = [original.contest_flags] if !original.contest_flags.is_a?(Array)
		original.contest_description = hash[:contest_description]	
	end
end

module MessageTypes
	MoveContestDescriptions     = 35
end

class String
	def to_i_threedigit
		val = self.to_i
		val = format('%03d',val)
	end
end

#====================================================================================
# Debug Options
#====================================================================================

MenuHandlers.add(:debug_menu, :contest_menu, {
  "name"        => _INTL("Pokeblock/Contest Options..."),
  "parent"      => :main,
  "description" => _INTL("Control Pokeblocks, Contest Options, etc."),
  "always_show" => false
})

MenuHandlers.add(:debug_menu, :contest_file_menu, {
  "name"        => _INTL("Contest Move Files..."),
  "parent"      => :contest_menu,
  "description" => _INTL("Controlling the Contest Moves movesx_contest.txt PBS"),
  "always_show" => false
})

MenuHandlers.add(:debug_menu, :create_moves_contest_file, {
  "name"        => _INTL("Create Movesx_Contest PBS File"),
  "parent"      => :contest_file_menu,
  "description" => _INTL("Create the Movesx_Contest PBS File from the existing Move data. (Best if you have custom moves)"),
  "effect"      => proc {
    cmd = 0
    cmds = [
      _INTL("Create movesx_contest.txt")
    ]
    loop do
      cmd = pbShowCommands(nil, cmds, -1, cmd)
      case cmd
      when 0  then Compiler.write_moves_contests
      else break
      end
      pbMessage(_INTL("File written."))
    end
  }
})
