# inspired by Pokemon Clover, https://poclo.net/changelog

$chain_species = nil
$chain_length = 0

def increaseChain(species)
	if $chain_species.nil?
		$chain_length = 1
		$chain_species = species
	elsif $chain_species == species
		$chain_length += 1
	else
		$chain_length = 0
		$chain_species = nil
	end
end

def chainBonuses(mon,species)
	if $chain_species == species && !mon.shiny?
		if 		$chain_length.between?(5,9); 			shinyrate = 2
		elsif $chain_length.between?(10,19); 		shinyrate = 4
		elsif $chain_length.between?(20,29); 		shinyrate = 8
		elsif $chain_length.between?(30,49); 		shinyrate = 16
		elsif $chain_length.between?(50,74); 		shinyrate = 32
		elsif $chain_length.between?(75,99); 		shinyrate = 64
		elsif $chain_length.between?(100,149); 	shinyrate = 96
		elsif $chain_length.between?(150,199); 	shinyrate = 128
		elsif $chain_length > 200;							shinyrate = 256
		else
			shinyrate = Settings::SHINY_POKEMON_CHANCE
		end
		v = (65_536 / shinyrate.to_f).ceil
		mon.shiny = true if rand(65_536) < v
	end
end

EventHandlers.add(:on_wild_pokemon_created, :chain_shiny, proc { |pkmn| chainBonuses(pkmn, pkmn.species) } )