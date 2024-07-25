class CrustangRacing
	def self.chooseCrustang
		choices = [_INTL("Rent a Crustang"), _INTL("Use my Crustang"), _INTL("Nevermind")]
		choice = pbMessage(_INTL("Do you want to rent a Crustang or use your own?"), choices, -1)
		
		case choice
		when -1
			return
		when 0
			self.rentCrustang
		when 1
			self.chooseOwnCrustang
		end
	end
	
	#selecting a crustang if you want to rent one for a race
	def self.rentCrustang
		#save the player's current party
		@currentParty = $player.party.clone
		#remove all party members
		$player.party.length.times do
			$player.party.delete_at(0)
		end
		
		#fill the player's party with rentable crustang
		for i in 0...CrustangRacingSettings::RENTABLE_CRUSTANG.length
			pkmn = Pokemon.new(:CRUSTANG, 20)
			pkmn.name = CrustangRacingSettings::RENTABLE_CRUSTANG[i][:PkmnName]
			pkmn.owner.gender = 3
			pkmn.owner.name = CrustangRacingSettings::RENTABLE_CRUSTANG[i][:TrainerName]
			pbAddToPartySilent(pkmn)
			pkmn.moves = []
			for j in 0...CrustangRacingSettings::RENTABLE_CRUSTANG[i][:Moves].length
				pkmn.learn_move(CrustangRacingSettings::RENTABLE_CRUSTANG[i][:Moves][j])
			end
		end
		
		self.chooseOwnCrustang		
	end
	
	def self.chooseOwnCrustang
		$game_variables[36] = 0
		pbChooseTradablePokemon(36, 37,
			proc { |pkmn| pkmn.isSpecies?(:CRUSTANG) }
		)
		
		enteredCrustang = $player.party[$game_variables[36]]
		#restore user's original party if rented a Crustang
		$player.party = @currentParty if !@currentParty.nil?
		self.main(enteredCrustang) if enteredCrustang != -1
	end
end

