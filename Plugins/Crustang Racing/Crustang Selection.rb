class CrustangRacing
	def self.chooseCrustang
		choices = [_INTL("Rent a Crustang"), _INTL("Use my Crustang"), _INTL("Nevermind")]
		choice = pbMessage(_INTL("Alright! Would you like to rent a Crustang from us or race with your own?"), choices, -1)
		
		case choice
		when -1
			pbMessage(_INTL("No sweat. Just let me know if you wanna race, yeah?"))
			return
		when 0
			self.rentCrustang
		when 1
			self.chooseOwnCrustang
		when 2
			pbMessage(_INTL("No sweat. Just let me know if you wanna race, yeah?"))
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
		if $game_variables[36] != -1
			#subtract money
			$player.money -= CrustangRacingSettings::COST_TO_RACE
			pbSEPlay("Mart buy item")
			pbWait(1)
			pbMessage(_INTL("A nice choice! Good luck out there!"))
			pbFadeOutIn {
				self.main(enteredCrustang)
			}
		else
			pbMessage(_INTL("No sweat. Just let me know if you wanna race, yeah?"))
		end #if $game_variables[36] != -1
	end #def self.chooseOwnCrustang
end