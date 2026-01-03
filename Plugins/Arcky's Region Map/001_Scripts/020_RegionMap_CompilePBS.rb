if Essentials::VERSION.include?("20")
  module Compiler
    module_function

    #=============================================================================
    # Compile Town Map data
    #=============================================================================
    def compile_town_map(path = "PBS/town_map.txt")
      compile_pbs_file_message_start(path)
      nonglobaltypes = {
        "Name"     => [0, "s"],
        "Filename" => [1, "s"],
        "Point"    => [2, "uussUUUUs"]
      }
      currentmap = -1
      rgnnames   = []
      placenames = []
      placedescs = []
      sections   = []
      pbCompilerEachCommentedLine(path) { |line, lineno|
        if line[/^\s*\[\s*(\d+)\s*\]\s*$/]
          currentmap = $~[1].to_i
          sections[currentmap] = []
        else
          if currentmap < 0
            raise _INTL("Expected a section at the beginning of the file\r\n{1}", FileLineData.linereport)
          end
          if !line[/^\s*(\w+)\s*=\s*(.*)$/]
            raise _INTL("Bad line syntax (expected syntax like XXX=YYY)\r\n{1}", FileLineData.linereport)
          end
          settingname = $~[1]
          schema = nonglobaltypes[settingname]
          if schema
            record = pbGetCsvRecord($~[2], lineno, schema)
            case settingname
            when "Name"
              rgnnames[currentmap] = record
              sections[currentmap][schema[0]] = record
            when "Point"
              placenames.push(record[2])
              placedescs.push(record[3])
              sections[currentmap][schema[0]] = [] if !sections[currentmap][schema[0]]
              sections[currentmap][schema[0]].push(record)
            else   # Filename
              sections[currentmap][schema[0]] = record
            end
          end
        end
      }
      save_data(sections, "Data/town_map.dat")
      MessageTypes.setMessages(MessageTypes::RegionNames, rgnnames)
      MessageTypes.setMessagesAsHash(MessageTypes::PlaceNames, placenames)
      MessageTypes.setMessagesAsHash(MessageTypes::PlaceDescriptions, placedescs)
      process_pbs_file_message_end
    end
  end
end 