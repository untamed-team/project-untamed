class CrustangRacing
	def self.chooseCrustang
		
		############################################## if $game_variables[36] == -1 then back out
		enteredCrustang = $game_variables[36]
		self.main(enteredCrustang)
	end
	
	#selecting a crustang if you want to rent one for a race
	def self.rentCrustang
		#save the player's current party
		#replace the player's party with rentable crustang
		self.pbChooseCrustang
		#get the crustang that was chosen and pass it to main.rb
		#restore user's original party
		
	end
	
	def self.chooseOwnCrustang
		$game_variables[36] = 0
		pbChooseTradablePokemon(36, 37,
			proc { |pkmn| pkmn.isSpecies?(:CRUSTANG) }
		)
	end
end

