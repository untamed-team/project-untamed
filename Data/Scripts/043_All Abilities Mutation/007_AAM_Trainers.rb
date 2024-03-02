module GameData
  class Trainer
	attr_reader :gimmick
	attr_reader :real_gimmick
  #-----------------------------------------------------------------------------
  # COMPATIBILITY FIX - Previously overwrote Essentials Deluxe code.
  #-----------------------------------------------------------------------------
  # SCHEMA is just a hash, so you don't need to replace th entire hash to add
  # your data. You can just add it to the existing hash.
  #-----------------------------------------------------------------------------
    SCHEMA["AAM"] = [:abilityMutation, "b"]
    SCHEMA["MEM"] = [:megaevoMutation, "b"] #low MEM edits
    SCHEMA["BOSS"] = [:bossmonMutation,"b"] #low MEM edits
    SCHEMA["Status"] = [:status,       "s"]
    SCHEMA["HiddenPowerType"] = [:hp_type, "q"]
    SCHEMA["Gimmick"] = [:gimmick,     "q"] #note: this is a trait of the trainer, not a specific pokemon
	
	# for TGT
	def initialize(hash)
		@id             = hash[:id]
		@trainer_type   = hash[:trainer_type]
		@real_name      = hash[:name]         || "Unnamed"
		@version        = hash[:version]      || 0
		@items          = hash[:items]        || []
		@real_lose_text = hash[:lose_text]    || "..."
		@real_gimmick	  = hash[:gimmick]  	  || "None"
		@pokemon        = hash[:pokemon]      || []
		@pokemon.each do |pkmn|
			GameData::Stat.each_main do |s|
				pkmn[:iv][s.id] ||= 0 if pkmn[:iv]
				pkmn[:ev][s.id] ||= 0 if pkmn[:ev]
			end
		end
	end
	def gimmick
		return @real_gimmick
	end
	# for TGT

  #-----------------------------------------------------------------------------
  # COMPATIBILITY FIX - Previously overwrote Essentials Deluxe code.
  #-----------------------------------------------------------------------------
  # Original to_trainer just returns a trainer object after setting all the
  # attributes to the Pokemon in that trainer's party. Because of this, you can
  # just alias this method and iterate through their party to edit any additional
  # attributes you want.
  #-----------------------------------------------------------------------------
    alias aam_to_trainer to_trainer
    def to_trainer
    	trainer = aam_to_trainer
		trainer.gimmick = self.gimmick # for TGT
    	trainer.party.each_with_index do |pkmn, i|
        pkmn_data = @pokemon[i]
		if pkmn_data[:hp_type] && !pkmn_data[:hp_type].empty?
			# inefficient but whatever
			case pkmn_data[:hp_type]
			when "NORMAL" 	then pkmn.hptype = :NORMAL
			when "FIGHTING" then pkmn.hptype = :FIGHTING
			when "FLYING" 	then pkmn.hptype = :FLYING
			when "POISON" 	then pkmn.hptype = :POISON
			when "GROUND" 	then pkmn.hptype = :GROUND
			when "ROCK" 	then pkmn.hptype = :ROCK
			when "BUG" 		then pkmn.hptype = :BUG
			when "GHOST" 	then pkmn.hptype = :GHOST
			when "STEEL" 	then pkmn.hptype = :STEEL
			when "QMARKS" 	then pkmn.hptype = :QMARKS
			when "FIRE" 	then pkmn.hptype = :FIRE
			when "WATER" 	then pkmn.hptype = :WATER
			when "GRASS" 	then pkmn.hptype = :GRASS
			when "ELECTRIC" then pkmn.hptype = :ELECTRIC
			when "PSYCHIC" 	then pkmn.hptype = :PSYCHIC
			when "ICE" 		then pkmn.hptype = :ICE
			when "DRAGON" 	then pkmn.hptype = :DRAGON
			when "DARK" 	then pkmn.hptype = :DARK
			when "FAIRY" 	then pkmn.hptype = :FAIRY
			end
		end
        pkmn.moves.each_with_index do |m, i| # maxing out their PP
			pkmn.moves[i].ppup = 3
			pkmn.moves[i].pp = (pkmn.moves[i].pp * 1.6).floor
		end
        pkmn.abilityMutation = true if pkmn_data[:abilityMutation]
        pkmn.megaevoMutation = true if pkmn_data[:megaevoMutation]
        pkmn.bossmonMutation = true if pkmn_data[:bossmonMutation]
		if pkmn_data[:status] && !pkmn_data[:status].empty?
			case pkmn_data[:status]
			when "Dizzy", "dizzy"
				pkmn.status = :DIZZY
				pkmn.statusCount = 2
			when "Sleep", "sleep"
				pkmn.status = :SLEEP
				pkmn.statusCount = 2
			when "Poison", "poison"
				pkmn.status = :POISON
			when "Burn", "burn"
				pkmn.status = :BURN
			when "Paralysis", "paralysis"
				pkmn.status = :PARALYSIS
			when "Frozen", "frozen", "Frostbite", "frostbite"
				pkmn.status = :FROZEN
			end
		end
		if pkmn.level >= 45 && !pkmn.abilityMutation
			pkmn.nature = :SERIOUS
			GameData::Stat.each_main do |s|
				pkmn.iv[s.id] += 10 if s.id != :HP
			end
		end
        pkmn.calc_stats
      end
      return trainer
    end
  end
end
