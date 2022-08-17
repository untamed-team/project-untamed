###YUMIL - 01 - QUEST LOG - START   
SaveData.register(:QuestLog) do
  ensure_class :Array
  save_value { $QuestLog }
  load_value { |value| $QuestLog = value }
  new_game_value { initializeQuestLog }
end
###YUMIL - 01 - QUEST LOG - END

class PokemonPokegearScreen
  def pbStartScreen
    commands = []
    cmdMap     = -1
    cmdPhone   = -1
    cmdJukebox = -1
	###Yumil - Quest Log - 02###
    cmdQuest   = -1
    ###Yumil - Quest Log - 02###
    commands[cmdMap = commands.length]     = ["map",_INTL("Map")]
    if $PokemonGlobal.phoneNumbers && $PokemonGlobal.phoneNumbers.length>0
      commands[cmdPhone = commands.length] = ["phone",_INTL("Phone")]
    end
    commands[cmdJukebox = commands.length] = ["jukebox",_INTL("Jukebox")]
	###Yumil - Quest Log - 03###
    commands[cmdQuest=commands.length]     = ["questlog",_INTL("Quest Log")]
    ###Yumil - Quest Log - 03###
    @scene.pbStartScene(commands)
    loop do
      cmd = @scene.pbScene
      if cmd<0
        break
      elsif cmdMap>=0 && cmd==cmdMap
        pbShowMap(-1,false)
      elsif cmdPhone>=0 && cmd==cmdPhone
        pbFadeOutIn {
          PokemonPhoneScene.new.start
        }
      elsif cmdJukebox>=0 && cmd==cmdJukebox
        pbFadeOutIn {
          scene = PokemonJukebox_Scene.new
          screen = PokemonJukeboxScreen.new(scene)
          screen.pbStartScreen
        }
	  elsif cmdQuest>=0 && cmd==cmdQuest
        pbPlayDecisionSE()
        $game_variables[998] ||= 0
        $game_variables[997] ||= 0
        ###Yumil -- 04 -- Quest Log
        if ($game_variables[999]!=true && $game_variables[999]!=false)
          $game_variables[999]=true
        end
        if $game_variables[999]
		  pbFadeOutIn {
			  scene = QuestLog_Scene.new($game_variables[998])
			  screen = QuestLogScreen.new(scene)
			  screen.pbStartScreen
		  }
        else
		  pbFadeOutIn {
			  scene = QuestLog_Scene.new($game_variables[997])
			  screen = QuestLogScreen.new(scene)
			  screen.pbStartScreen
		  }
        end
        ###Yumil -- 04 -- Quest Log
      end
    end
    @scene.pbEndScene
  end
end

=begin
class PokemonLoadScreen
  def initialize(scene)
    @scene = scene
    if SaveData.exists?
      @save_data = load_save_file(SaveData::FILE_PATH)
    else
      @save_data = {}
    end
    ###Yumil - 05 - Quest Log - Begin
		$QuestLog = load_data("Data/quests.dat") if !$QuestLog
		###Yumil - 05 - Quest Log - End
  end
end

module Compiler
def compile_all(mustCompile)
    FileLineData.clear
    if (!$INEDITOR || Settings::LANGUAGES.length < 2) && safeExists?("Data/messages.dat")
      MessageTypes.loadMessageFile("Data/messages.dat")
    end
    if mustCompile
      echoln _INTL("*** Starting full compile ***")
      echoln ""
      yield(_INTL("Compiling town map data"))
      compile_town_map               # No dependencies
      yield(_INTL("Compiling map connection data"))
      compile_connections            # No dependencies
      yield(_INTL("Compiling phone data"))
      compile_phone
      yield(_INTL("Compiling type data"))
      compile_types                  # No dependencies
      yield(_INTL("Compiling ability data"))
      compile_abilities              # No dependencies
      yield(_INTL("Compiling move data"))
      compile_moves                  # Depends on Type
      yield(_INTL("Compiling item data"))
      compile_items                  # Depends on Move
      yield(_INTL("Compiling berry plant data"))
      compile_berry_plants           # Depends on Item
      yield(_INTL("Compiling Pokémon data"))
      compile_pokemon                # Depends on Move, Item, Type, Ability
      yield(_INTL("Compiling Pokémon forms data"))
      compile_pokemon_forms          # Depends on Species, Move, Item, Type, Ability
      yield(_INTL("Compiling machine data"))
      compile_move_compatibilities   # Depends on Species, Move
      yield(_INTL("Compiling shadow moveset data"))
      compile_shadow_movesets        # Depends on Species, Move
      yield(_INTL("Compiling Regional Dexes"))
      compile_regional_dexes         # Depends on Species
      yield(_INTL("Compiling ribbon data"))
      compile_ribbons                # No dependencies
      yield(_INTL("Compiling encounter data"))
      compile_encounters             # Depends on Species
      yield(_INTL("Compiling Trainer type data"))
      compile_trainer_types          # No dependencies
      yield(_INTL("Compiling Trainer data"))
      compile_trainers               # Depends on Species, Item, Move
      yield(_INTL("Compiling battle Trainer data"))
      compile_trainer_lists          # Depends on TrainerType
      yield(_INTL("Compiling metadata"))
      compile_metadata               # Depends on TrainerType
      yield(_INTL("Compiling animations"))
      compile_animations
      yield(_INTL("Converting events"))
      compile_trainer_events(mustCompile)
      ###Yumil -- 06 -- QUEST LOG -- BEGIN
      yield(_INTL("Compiling Quests"))
      pbCompileQuestLog
      ###Yumil -- 06 -- QUEST LOG -- END
      yield(_INTL("Saving messages"))
      pbSetTextMessages
      MessageTypes.saveMessages
      echoln ""
      echoln _INTL("*** Finished full compile ***")
      echoln ""
      System.reload_cache
    end
    pbSetWindowText(nil)
  end
  
  def main
    return if !$DEBUG
    begin
      dataFiles = [
         "berry_plants.dat",
         "encounters.dat",
         "form2species.dat",
         "items.dat",
         "map_connections.dat",
         "metadata.dat",
         "moves.dat",
         "phone.dat",
         "regional_dexes.dat",
         "ribbons.dat",
         "shadow_movesets.dat",
         "species.dat",
         "species_eggmoves.dat",
         "species_evolutions.dat",
         "species_metrics.dat",
         "species_movesets.dat",
         "tm.dat",
         "town_map.dat",
         "trainer_lists.dat",
         "trainer_types.dat",
         "trainers.dat",
         ###Yumil - 07 - QUEST LOG - Begin
         "quests.dat",
         ###Yumil - 07 - QUEST LOG - End
         "types.dat"
      ]
      textFiles = [
         "abilities.txt",
         "berryplants.txt",
         "connections.txt",
         "encounters.txt",
         "items.txt",
         "metadata.txt",
         "moves.txt",
         "phone.txt",
         "pokemon.txt",
         "pokemonforms.txt",
         "regionaldexes.txt",
         "ribbons.txt",
         "shadowmoves.txt",
         "townmap.txt",
         "trainerlists.txt",
         "trainers.txt",
         "trainertypes.txt",
          ###Yumil - 08 - QUEST LOG - Begin
         "quests.txt",
          ###Yumil - 08 - QUEST LOG - End
         "types.txt"
      ]
      latestDataTime = 0
      latestTextTime = 0
      mustCompile = false
      # Should recompile if new maps were imported
      mustCompile |= import_new_maps
      # If no PBS file, create one and fill it, then recompile
      if !safeIsDirectory?("PBS")
        Dir.mkdir("PBS") rescue nil
        write_all
        mustCompile = true
      end
      # Check data files and PBS files, and recompile if any PBS file was edited
      # more recently than the data files were last created
      dataFiles.each do |filename|
        next if !safeExists?("Data/" + filename)
        begin
          File.open("Data/#{filename}") { |file|
            latestDataTime = [latestDataTime, file.mtime.to_i].max
          }
        rescue SystemCallError
          mustCompile = true
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
      # Should recompile if holding Ctrl
      Input.update
      mustCompile = true if Input.press?(Input::CTRL)
      # Delete old data files in preparation for recompiling
      if mustCompile
        for i in 0...dataFiles.length
          begin
            File.delete("Data/#{dataFiles[i]}") if safeExists?("Data/#{dataFiles[i]}")
          rescue SystemCallError
          end
        end
      end
      # Recompile all data
      compile_all(mustCompile) { |msg| pbSetWindowText(msg); echoln(msg) }
    rescue Exception
      e = $!
      raise e if "#{e.class}"=="Reset" || e.is_a?(Reset) || e.is_a?(SystemExit)
      pbPrintException(e)
      for i in 0...dataFiles.length
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

module Compiler
  ###Yumil -- 09 -- QUEST LOG -- BEGIN
def pbCompileQuestLog
  quests = []
  if File.exists?("PBS/quests.txt") 
    file = File.open("PBS/quests.txt", "r")
    file_data = file.read
    title=nil
    state=nil
    ismain =false
    objectives=[]
    file_data.each_line {|line|
      if line.chomp == "#-------------------"
        if objectives != [] || title !=nil
          quests<<[title, state,objectives,ismain]
          title = nil
          state = nil
          ismain= false
          objectives = []
        end
        title = nil
        state = nil
        ismain= false
        objectives = []
      elsif (objectives==[] && title ==nil && state ==nil)
        title = line.chomp.split(",")[0]
        state = line.chomp.split(",")[1]
        ismain= line.chomp.split(",")[2]
      elsif(line[0..1]=="##")
        
      else
        objectives << [line.chomp.split(",")[0],line.chomp.split(",")[1]]
      end
    }
    file.close
    save_data(quests,"Data/quests.dat")
    $QuestLog = quests
  end
###-- Yumil -- 09 -- QUEST LOG -- END
end
=end