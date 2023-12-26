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
        pkmn.calc_stats
      end
      return trainer
    end
  end
end
