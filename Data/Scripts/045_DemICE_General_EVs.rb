#=====================================================================================================
# Settings
#=====================================================================================================
module Settings

	#------------------------------------------------------------------------------
	# Due to the complications this plugin creates with being compatible with stuff
	# I made this setting in case you have an edited summary screen that is not 
	# from the "EVs and IVs in Summary v20" or "BW Summary Screen" plugins.
	#
	# If the below setting is true, it will cause direct edits to drawPageThree instead of aliasing:
	# 1) Stat names will be a couple tiles to the left, making the screen look better.
	# 2) The ability + description text will be directly replaced with the EV allocation text
	# 3) The overlay picture used for hiding the ability+description doesn't happen anymore.
	#------------------------------------------------------------------------------

	I_EDITED_MY_SUMMARY = true  # default = false for compatibility

	#==================================================================================================================

	# If you dont like the Mixed EVs part but want to keep everyting else about this plugin, you can disable it below
	PURIST_MODE = false  # default = false  because i'm biased towards my system.
end

module Compiler
  module_function
  #=============================================================================
  # Compile individual trainer data
  #=============================================================================
  def compile_trainers(path = "PBS/trainers.txt")
    compile_pbs_file_message_start(path)
    GameData::Trainer::DATA.clear
    schema = GameData::Trainer::SCHEMA
    max_level = GameData::GrowthRate.max_level
    trainer_names      = []
    trainer_lose_texts = []
    trainer_hash       = nil
    current_pkmn       = nil
    # Read each line of trainers.txt at a time and compile it as a trainer property
    idx = 0
    pbCompilerEachPreppedLine(path) { |line, line_no|
      echo "." if idx % 50 == 0
      idx += 1
      Graphics.update if idx % 250 == 0
      if line[/^\s*\[\s*(.+)\s*\]\s*$/]
        # New section [trainer_type, name] or [trainer_type, name, version]
        if trainer_hash
          if !current_pkmn
            raise _INTL("Started new trainer while previous trainer has no Pokémon.\r\n{1}", FileLineData.linereport)
          end
          # Add trainer's data to records
          trainer_hash[:id] = [trainer_hash[:trainer_type], trainer_hash[:name], trainer_hash[:version]]
          GameData::Trainer.register(trainer_hash)
        end
        line_data = pbGetCsvRecord($~[1], line_no, [0, "esU", :TrainerType])
        # Construct trainer hash
        trainer_hash = {
          :trainer_type => line_data[0],
          :name         => line_data[1],
          :version      => line_data[2] || 0,
          :pokemon      => []
        }
        current_pkmn = nil
        trainer_names.push(trainer_hash[:name])
      elsif line[/^\s*(\w+)\s*=\s*(.*)$/]
        # XXX=YYY lines
        if !trainer_hash
          raise _INTL("Expected a section at the beginning of the file.\r\n{1}", FileLineData.linereport)
        end
        property_name = $~[1]
        line_schema = schema[property_name]
        next if !line_schema
        property_value = pbGetCsvRecord($~[2], line_no, line_schema)
        # Error checking in XXX=YYY lines
        case property_name
        when "Pokemon"
          if property_value[1] > max_level
            raise _INTL("Bad level: {1} (must be 1-{2}).\r\n{3}", property_value[1], max_level, FileLineData.linereport)
          end
        when "Name"
          if property_value.length > Pokemon::MAX_NAME_SIZE
            raise _INTL("Bad nickname: {1} (must be 1-{2} characters).\r\n{3}", property_value, Pokemon::MAX_NAME_SIZE, FileLineData.linereport)
          end
        when "Moves"
          property_value.uniq!
        when "IV"
          property_value.each do |iv|
            next if iv <= Pokemon::IV_STAT_LIMIT
            raise _INTL("Bad IV: {1} (must be 0-{2}).\r\n{3}", iv, Pokemon::IV_STAT_LIMIT, FileLineData.linereport)
          end
        when "EV"
		  # DemICE edit
          # property_value.each do |ev|
            # next if ev <= Pokemon::EV_STAT_LIMIT
            # raise _INTL("Bad EV: {1} (must be 0-{2}).\r\n{3}", ev, Pokemon::EV_STAT_LIMIT, FileLineData.linereport)
          # end
		  # DemICE end
          ev_total = 0
          GameData::Stat.each_main do |s|
            next if s.pbs_order < 0
            ev_total += (property_value[s.pbs_order] || property_value[0])
          end
		  # DemICE edit
          # if ev_total > Pokemon::EV_LIMIT
            # raise _INTL("Total EVs are greater than allowed ({1}).\r\n{2}", Pokemon::EV_LIMIT, FileLineData.linereport)
          # end
		  # DemICE end
        when "Happiness"
          if property_value > 255
            raise _INTL("Bad happiness: {1} (must be 0-255).\r\n{2}", property_value, FileLineData.linereport)
          end
        when "Ball"
          if !GameData::Item.get(property_value).is_poke_ball?
            raise _INTL("Value {1} isn't a defined Poké Ball.\r\n{2}", property_value, FileLineData.linereport)
          end
        end
        # Record XXX=YYY setting
        case property_name
        when "Items", "LoseText", "Gimmick"
          trainer_hash[line_schema[0]] = property_value
          trainer_lose_texts.push(property_value) if property_name == "LoseText"
        when "Pokemon"
          current_pkmn = {
            :species => property_value[0],
            :level   => property_value[1]
          }
          trainer_hash[line_schema[0]].push(current_pkmn)
        else
          if !current_pkmn
            raise _INTL("Pokémon hasn't been defined yet!\r\n{1}", FileLineData.linereport)
          end
          case property_name
          when "IV", "EV"
            value_hash = {}
            GameData::Stat.each_main do |s|
              next if s.pbs_order < 0
              value_hash[s.id] = property_value[s.pbs_order] || property_value[0]
            end
            current_pkmn[line_schema[0]] = value_hash
          else
            current_pkmn[line_schema[0]] = property_value
          end
        end
      end
    }
    # Add last trainer's data to records
    if trainer_hash
      if !current_pkmn
        raise _INTL("End of file reached while last trainer has no Pokémon.\r\n{1}", FileLineData.linereport)
      end
      trainer_hash[:id] = [trainer_hash[:trainer_type], trainer_hash[:name], trainer_hash[:version]]
      GameData::Trainer.register(trainer_hash)
    end
    # Save all data
    GameData::Trainer.save
    MessageTypes.setMessagesAsHash(MessageTypes::TrainerNames, trainer_names)
    MessageTypes.setMessagesAsHash(MessageTypes::TrainerLoseText, trainer_lose_texts)
    process_pbs_file_message_end
  end
  
end # of module Compiler

##################################################################################################################################

alias mixed_ev_alloc_pbChangeLevel pbChangeLevel
def pbChangeLevel(pkmn, new_level, scene)
  if new_level > pkmn.level
    # DemICE edit
    evpool=80+pkmn.level*8
    evpool=(evpool.div(4))*4      
    evpool=512 if evpool>512    
    evcap=40+pkmn.level*4
    evcap=(evcap.div(4))*4
    evcap=252 if evcap>252
    increment=4*(new_level-pkmn.level)
    evsum=pkmn.ev[:HP]+pkmn.ev[:ATTACK]+pkmn.ev[:DEFENSE]+pkmn.ev[:SPECIAL_DEFENSE]+pkmn.ev[:SPEED] 	
		evsum+=pkmn.ev[:SPECIAL_ATTACK] if Settings::PURIST_MODE
    evarray=[]
    GameData::Stat.each_main do |s|
      evarray.push(pkmn.ev[s.id])
    end
    if evsum>0 && evpool>evsum && evarray.max<evcap && evarray.max_nth(2)<evcap
      GameData::Stat.each_main do |s|
        if pkmn.ev[s.id]==evarray.max
          pkmn.ev[s.id]+=increment
          pkmn.calc_stats
          pkmn.ev[s.id]+=increment if pkmn.ev[s.id]<evcap
          pkmn.calc_stats
        end
      end	
      evsum=pkmn.ev[:HP]+pkmn.ev[:ATTACK]+pkmn.ev[:DEFENSE]+pkmn.ev[:SPECIAL_DEFENSE]+pkmn.ev[:SPEED] 
      evsum+=pkmn.ev[:SPECIAL_ATTACK] if Settings::PURIST_MODE
      evarray=[]
      GameData::Stat.each_main do |s|
        evarray.push(pkmn.ev[s.id])
      end
      if evpool>evsum
        GameData::Stat.each_main do |s|
          if pkmn.ev[s.id]==evarray.max_nth(2)
            pkmn.ev[s.id]+=increment
            pkmn.calc_stats
          end
        end	
      end														
    end		    
    # DemICE end
  elsif new_level < pkmn.level
    GameData::Stat.each_main do |s|
      if pkmn.ev[s.id]=0
        pkmn.calc_stats
      end
    end	    
  end
  mixed_ev_alloc_pbChangeLevel(pkmn, new_level, scene)
end

class Battle

  alias mixed_ev_alloc_pbGainExpOne pbGainExpOne
  def pbGainExpOne(idxParty, defeatedBattler, numPartic, expShare, expAll, showMessages = true)
    pkmn = pbParty(0)[idxParty]   # The Pokémon gaining Exp from defeatedBattler
    current_level = pkmn.level

    mixed_ev_alloc_pbGainExpOne(idxParty, defeatedBattler, numPartic, expShare, expAll, showMessages)
    
    if pkmn.level > current_level
      # DemICE edit
      evpool=80+pkmn.level*8
      evpool=(evpool.div(4))*4      
      evpool=512 if evpool>512    
      evcap=40+pkmn.level*4
      evcap=(evcap.div(4))*4
      evcap=252 if evcap>252
      evsum=pkmn.ev[:HP]+pkmn.ev[:ATTACK]+pkmn.ev[:DEFENSE]+pkmn.ev[:SPECIAL_DEFENSE]+pkmn.ev[:SPEED] 	
      evsum+=pkmn.ev[:SPECIAL_ATTACK] if Settings::PURIST_MODE
        evarray=[]
        GameData::Stat.each_main do |s|
        evarray.push(pkmn.ev[s.id])
        end
      if evsum>0 && evpool>evsum && evarray.max<evcap && evarray.max_nth(2)<evcap
        GameData::Stat.each_main do |s|
          if pkmn.ev[s.id]==evarray.max
            pkmn.ev[s.id]+=4
            pkmn.calc_stats
            pkmn.ev[s.id]+=4 if pkmn.ev[s.id]<evcap
            pkmn.calc_stats
          end
        end	
        evsum=pkmn.ev[:HP]+pkmn.ev[:ATTACK]+pkmn.ev[:DEFENSE]+pkmn.ev[:SPECIAL_DEFENSE]+pkmn.ev[:SPEED] 
        evsum+=pkmn.ev[:SPECIAL_ATTACK] if Settings::PURIST_MODE
        evarray=[]
        GameData::Stat.each_main do |s|
          evarray.push(pkmn.ev[s.id])
        end
        if evpool>evsum
          GameData::Stat.each_main do |s|
            if pkmn.ev[s.id]==evarray.max_nth(2)
              pkmn.ev[s.id]+=4
              pkmn.calc_stats
            end
          end	
        end														
      end	
      pkmn.calc_stats
      # DemICE end
    elsif pkmn.level < current_level
      GameData::Stat.each_main do |s|
        if pkmn.ev[s.id]=0
          pkmn.calc_stats
        end
      end	       
    end  
  end

  def pbGainEVsOne(idxParty, defeatedBattler)
    return
  end

end  # of pbChangeLevel

##################################################################################################################################

module Enumerable	
  def max_nth(n)
    inject([]) do |acc, x|
      (acc + [x]).sort[[acc.size-(n-1), 0].max..-1]
    end.first
  end	
end

class Pokemon
  attr_accessor :trainerevs
  # Max total EVs
  EV_LIMIT      = 0  # DemICE edit
  # Max EVs that a single stat can have
  EV_STAT_LIMIT = 0  # DemICE edit

  
  # Recalculates this Pokémon's stats.
  alias mixed_ev_alloc_calc_stats calc_stats
  def calc_stats
    #DemICE failsafe for the new EV system
    evpool=80+self.level*8
    evpool=(evpool.div(4))*4      
    evpool=512 if evpool>512 
    evsum=@ev[:HP]+@ev[:ATTACK]+@ev[:DEFENSE]+@ev[:SPECIAL_DEFENSE]+@ev[:SPEED]
		evsum+=@ev[:SPECIAL_ATTACK] if Settings::PURIST_MODE
    GameData::Stat.each_main do |s|
      if evsum>evpool
        @ev[s.id]=0  
      end  
    end 
    if !Settings::PURIST_MODE 
      @ev[:SPECIAL_ATTACK]=@ev[:ATTACK]
    end  
    mixed_ev_alloc_calc_stats
  end

end  #of module Enumerable

##################################################################################################################################

module GameData
  class Trainer

    #SCHEMA["TEV"] = [:trainerevs,              "uUUUUU"]

    # alias mixed_ev_alloc_initialize initialize
    # def initialize(hash)
    #   mixed_ev_alloc_initialize(hash)
    #   @pokemon.each do |pkmn|
    #     GameData::Stat.each_main do |s|
    #       print pkmn
    #       pkmn[:trainerevs][s.id] ||= 0 if pkmn[:trainerevs]
    #     end
    #   end
    # end    

    alias mixed_ev_alloc_to_trainer to_trainer
    def to_trainer
      trainer = mixed_ev_alloc_to_trainer
      trainer.party.each_with_index do |pkmn, i|
        pkmn_data = @pokemon[i]
        GameData::Stat.each_main do |s|
          if pkmn_data[:ev]
            evcap=40+pkmn_data[:level]*4
            pkmn.ev[s.id] = pkmn_data[:ev][s.id]
            if pkmn.ev[s.id] >evcap
              pkmn.ev[s.id]=evcap
            end 
          else
            limit=80+pkmn_data[:level]*8
            pkmn.ev[s.id] = [pkmn_data[:level] * 3 / 2, limit / 6].min
          end	
        end  
        if !Settings::PURIST_MODE 
          pkmn.ev[:ATTACK]=pkmn.ev[:SPECIAL_ATTACK] if pkmn.ev[:SPECIAL_ATTACK]>pkmn.ev[:ATTACK]
        end 
        pkmn.calc_stats
      end
      return trainer
    end
    
  end
end #of module GameData

##################################################################################################################################

ItemHandlers::UseOnPokemon.add(:HPUP, proc { |item, qty, pkmn, scene|
	commands=[]
	natures=["HARDY",
					 "DOCILE",
					 "SERIOUS",
					 "BASHFUL",
					 "QUIRKY"]
	for i in natures
		commands.push(i)
	end	
	commands.push(_INTL("Go Back"))	
	cmd=0
	cmd=scene.pbShowCommands(nil,commands,cmd)
	case cmd
	when 0
		scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
		pkmn.nature = :HARDY
		pkmn.calc_stats
		next true
	when 1
		scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
		pkmn.nature = :DOCILE
		pkmn.calc_stats
		next true
	when 2
		scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
		pkmn.nature = :SERIOUS
		pkmn.calc_stats
		next true
	when 3
		scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
		pkmn.nature = :BASHFUL
		pkmn.calc_stats
		next true
	when 4
		scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
		pkmn.nature = :QUIRKY
		pkmn.calc_stats
		next true
	else
		next false
	end
})

ItemHandlers::UseOnPokemon.add(:PROTEIN, proc { |item, qty, pkmn, scene|
	commands=[]
	natures=["ADAMANT (-SpAtk)",
					 "LONELY (-Def)",
					 "NAUGHTY (-SpDef)",
					 "BRAVE (-Speed)"]
	for i in natures
		commands.push(i)
	end	
	commands.push(_INTL("Go Back"))	
	cmd=0
	cmd=scene.pbShowCommands(nil,commands,cmd)
	case cmd
	when 0
		scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
		pkmn.nature = :ADAMANT
		pkmn.calc_stats
		next true
	when 1
		scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
		pkmn.nature = :LONELY
		pkmn.calc_stats
		next true
	when 2
		scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
		pkmn.nature = :NAUGHTY
		pkmn.calc_stats
		next true
	when 3
		scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
		pkmn.nature = :BRAVE
		pkmn.calc_stats
		next true
	else
		next false
	end
})

ItemHandlers::UseOnPokemon.add(:IRON, proc { |item, qty, pkmn, scene|
	commands=[]
	natures=["BOLD (-Atk)",
					 "IMPISH (-SpAtk)",
					 "LAX (-SpDef)",
					 "RELAXED (-Speed)"]
	for i in natures
		commands.push(i)
	end	
	commands.push(_INTL("Go Back"))	
	cmd=0
	cmd=scene.pbShowCommands(nil,commands,cmd)
	case cmd
	when 0
		scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
		pkmn.nature = :BOLD
		pkmn.calc_stats
		next true
	when 1
		scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
		pkmn.nature = :IMPISH
		pkmn.calc_stats
		next true
	when 2
		scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
		pkmn.nature = :LAX
		pkmn.calc_stats
		next true
	when 3
		scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
		pkmn.nature = :RELAXED
		pkmn.calc_stats
		next true
	else
		next false
	end
})

ItemHandlers::UseOnPokemon.add(:CALCIUM, proc { |item, qty, pkmn, scene|
	commands=[]
	natures=["MODEST (-Atk)",
					 "RASH (-Def)",
					 "MILD (-SpDef)",
					 "QUIET (-Speed)"]
	for i in natures
		commands.push(i)
	end	
	commands.push(_INTL("Go Back"))	
	cmd=0
	cmd=scene.pbShowCommands(nil,commands,cmd)
	case cmd
	when 0
		scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
		pkmn.nature = :MODEST
		pkmn.calc_stats
		next true
	when 1
		scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
		pkmn.nature = :RASH
		pkmn.calc_stats
		next true
	when 2
		scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
		pkmn.nature = :MILD
		pkmn.calc_stats
		next true
	when 3
		scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
		pkmn.nature = :QUIET
		pkmn.calc_stats
		next true
	else
		next false
	end
})

ItemHandlers::UseOnPokemon.add(:ZINC, proc { |item, qty, pkmn, scene|
	commands=[]
	natures=["CALM (-Atk)",
					 "CAREFUL (-SpAtk)",
					 "GENTLE (-Def)",
					 "SASSY (-Speed)"]
	for i in natures
		commands.push(i)
	end	
	commands.push(_INTL("Go Back"))	
	cmd=0
	cmd=scene.pbShowCommands(nil,commands,cmd)
	case cmd
	when 0
		scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
		pkmn.nature = :CALM
		pkmn.calc_stats
		next true
	when 1
		scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
		pkmn.nature = :CAREFUL
		pkmn.calc_stats
		next true
	when 2
		scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
		pkmn.nature = :GENTLE
		pkmn.calc_stats
		next true
	when 3
		scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
		pkmn.nature = :SASSY
		pkmn.calc_stats
		next true
	else
		next false
	end
})

ItemHandlers::UseOnPokemon.add(:CARBOS, proc { |item, qty, pkmn, scene|
	commands=[]
	natures=["TIMID (-Atk)",
					 "JOLLY (-SpAtk)",
					 "HASTY (-Def)",
					 "NAIVE (-SpDef)"]
	for i in natures
		commands.push(i)
	end	
	commands.push(_INTL("Go Back"))	
	cmd=0
	cmd=scene.pbShowCommands(nil,commands,cmd)
	case cmd
	when 0
		scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
		pkmn.nature = :TIMID
		pkmn.calc_stats
		next true
	when 1
		scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
		pkmn.nature = :JOLLY
		pkmn.calc_stats
		next true
	when 2
		scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
		pkmn.nature = :HASTY
		pkmn.calc_stats
		next true
	when 3
		scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
		pkmn.nature = :NAIVE
		pkmn.calc_stats
		next true
	else
		next false
	end
})
