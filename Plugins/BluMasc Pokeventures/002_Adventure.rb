class Adventure 
	attr_accessor :party
	attr_accessor :items
	
	def initialize
		@items		= []
		@party      = []
		@steps		= 0
	end
	def newStep
		if @steps.nil?
			@steps = 0
		end
		@steps = @steps+1
		for egg in @party
			next if egg.steps_to_hatch <= 0
			egg.steps_to_hatch -= 1
			for i in @party
				next if [:FLAMEBODY, :MAGMAARMOR, :STEAMENGINE].include?(i.ability_id)
				egg.steps_to_hatch -= 1
				break
			end
			if egg.steps_to_hatch <= 0
				egg.steps_to_hatch = 0
				speciesname = egg.speciesName
				egg.name           = nil
				egg.owner          = Pokemon::Owner.new_from_trainer($Trainer)
				egg.happiness      = 100
				egg.timeEggHatched = pbGetTimeNow
				egg.obtain_method  = 1   # hatched from egg
				egg.hatched_map    = $game_map.map_id
				$Trainer.pokedex.register(egg)
				$Trainer.pokedex.set_owned(egg.species)
				egg.record_first_moves
			end
		end
		if @steps >= PokeventureConfig::Updatesteps
			if able_pokemon_count>0
				pbAdventuringEvent
			end
			@steps=0
		end
	end
	def pbAdventuringEvent
		chances = rand(500)
		if chances >269 && PokeventureConfig::CollectRandomItem
			@items.append(pbGetItem)
		elsif chances==59 && PokeventureConfig::ChanceToFindEggs#egg
			encounter = $PokemonEncounters.choose_wild_pokemon(:AdventureEggs)
			encounter = [nil, nil] if encounter.nil?
			if PokeventureConfig::GlobalPkmn
				encounter[0] = pbGetEgg
			end
			pbGenerateAdEgg(encounter[0])
		else
			battle
		end
		itemcollect		
	end
	def remove_pokemon_at_index(index)
		return false if index < 0 || index >= @party.length
		@party.delete_at(index)
		return true
	end
	def all_fainted?
		return able_pokemon_count == 0
	end
	def party_full?
		return @party.length >= Settings::MAX_PARTY_SIZE
	end
	def able_pokemon_count
		ret = 0
		@party.each { |p| ret += 1 if p && !p.egg? && !p.fainted? }
		return ret
	end
	def battle
		encounter = $PokemonEncounters.choose_wild_pokemon(:Adventure)
		encounter = [nil, nil] if encounter.nil?
		if PokeventureConfig::GlobalPkmn
			encounter[0] = pbGetPokemon
		end
		if !encounter.nil? && !encounter[0].nil?
			if PokeventureConfig::GlobalLeveling || encounter[1].nil?
				badges = $Trainer.badge_count
				levels = PokeventureConfig::PkmnLevel[[PokeventureConfig::PkmnLevel.length()-1,badges].min]
				encounter[1] = rand(levels[0]...levels[1])
			end
			puts(encounter[0])
			partylevel = pbBalancedLevel(@party)
			win = false
			if partylevel > encounter[1] && rand(5)==4
				win = true
			else
				chance = encounter[1] - partylevel
				win = true if 1 == rand(chance)
			end
			if win
				poke = Pokemon.new(encounter[0],encounter[1])
				if PokeventureConfig::FindFriends && 0 == rand(PokeventureConfig::ChanceToFindFriend-1) && !party_full? 
					poke.generateBrilliant if (PokeventureConfig::AreFoundFriendsBrilliant && defined?(poke.generateBrilliant))
					poke.name= nil
					poke.owner= Pokemon::Owner.new_from_trainer($Trainer)
					poke.obtain_method= 0  
					poke.obtain_text= "Encountered on an adventure!"
					poke.timeReceived= pbGetTimeNow
					$Trainer.pokedex.register(poke)
					$Trainer.pokedex.set_owned(poke.species)
					@party.append(poke)
				end
				if PokeventureConfig::CollectItemsFromBattles && 0 ==rand(PokeventureConfig::ChanceToGetEnemyItem)
					drops = poke.wildHoldItems
					if !drops.compact.empty?
						@items.append(drops.compact.sample)
					end
				end
				@party.each do |pkmn|
					if pkmn.able? && PokeventureConfig::GainExp
							pbGainAventureExp(pkmn,poke,able_pokemon_count)
					end
				end
			end
		end
		@party.each do |pkmn|
			PokeventureConfig::pbAdventureAbilities(pkmn)
		end
	end
	def add_pokemon(pkmn)
		@party.append(pkmn)
		itemcollect
	end
	def itemcollect
		@party.each do |pkmn|
			if pkmn.hasItem?
				item = GameData::Item.get(pkmn.item).id
				@items.append(item)
				pkmn.item = nil
			end
		end
	end
	def harvestItems
		@items.each { |x| Kernel.pbReceiveItem(x) if !x.nil?}
		@items = []
	end
	def harvestItemsSilent
		giveAdventureItemList(@items)
		@items = []
	end
	def sendEveryoneToBox
		success = true
		while success && !(@party.empty?)
			success = pbMovetoPC(0)
		end
		if success
			pbMessage(_INTL("All adventurers were send to the PC!"))
		end
	end
	def pbMovetoPC(pos)
		if pbBoxesFull?
			pbMessage(_INTL("The Boxes on your PC are full!"))
			return false
		else
			$PokemonStorage.pbStoreCaught(@party[pos].dup)
			remove_pokemon_at_index(pos)
			return true
		end
	end
	def heal_party
		@party.each { |pkmn| pkmn.heal }
	end
	def pbPlayer
		return $Trainer 
	end
	def pbGainAventureExp(pkmn,defeatedBattler,numPartic)
		growth_rate = pkmn.growth_rate
		if pkmn.exp>=growth_rate.maximum_exp
			pkmn.calc_stats   # To ensure new EVs still have an effect
			return
		end
		isPartic    = true
		level = defeatedBattler.level
    # Main Exp calculation
    exp = 0
    a = level*defeatedBattler.base_exp
    if isPartic   # Participated in battle, no Exp Shares held by anyone
      exp = a / (Settings::SPLIT_EXP_BETWEEN_GAINERS ? numPartic : 1)
    end
    return if exp<=0
    # Scale the gained Exp based on the gainer's level (or not)
    if Settings::SCALED_EXP_FORMULA
      exp /= 5
      levelAdjust = (2*level+10.0)/(pkmn.level+level+10.0)
      levelAdjust = levelAdjust**5
      levelAdjust = Math.sqrt(levelAdjust)
      exp *= levelAdjust
      exp = exp.floor
      exp += 1 if isPartic || hasExpShare
    else
      exp /= 7
    end
    # Foreign Pokémon gain more Exp
    isOutsider = (pkmn.owner.id != pbPlayer.id ||
                 (pkmn.owner.language != 0 && pkmn.owner.language != pbPlayer.language))
    if isOutsider
      if pkmn.owner.language != 0 && pkmn.owner.language != pbPlayer.language
        exp = (exp*1.7).floor
      else
        exp = (exp*1.5).floor
      end
    end
    # Modify Exp gain based on EXP Charm's Presence
    exp = (exp * 1.5).floor if GameData::Item.exists?(:EXPCHARM) && $PokemonBag.pbHasItem?(:EXPCHARM)
    oldlevel = pkmn.level
    pkmn.exp += exp   # Gain Exp
    if !pkmn.level==oldlevel
		pkmn.calc_stats
		movelist = pkmn.getMoveList
		for i in movelist
			pkmn.learn_move(i[1]) if i[0]==pkmn.level   # Learned a new move
		end
    end
	end
	def pbGetItem
		items = PokeventureConfig::Items
		items.sort! { |a, b| b[1] <=> a[1] }
		chance_total = 0
		items.each { |a| chance_total += a[1] }
		rnd = rand(chance_total)
		item = nil
		items.each do |itm|
			rnd -= itm[1]
			next if rnd >= 0
			item = itm[0]
			break
		end
		return item
	end
	def pbGetPokemon
		pkmn = PokeventureConfig::PkmnList
		pkmn.sort! { |a, b| b[1] <=> a[1] }
		chance_total = 0
		pkmn.each { |a| chance_total += a[1] }
		rnd = rand(chance_total)
		item = nil
		pkmn.each do |itm|
			rnd -= itm[1]
			next if rnd >= 0
			item = itm[0]
			break
		end
		return item
	end
	def pbGetEgg
		eggs = PokeventureConfig::EggList
		eggs.sort! { |a, b| b[1] <=> a[1] }
		chance_total = 0
		eggs.each { |a| chance_total += a[1] }
		rnd = rand(chance_total)
		item = nil
		eggs.each do |itm|
			rnd -= itm[1]
			next if rnd >= 0
			item = itm[0]
			break
		end
		return item
	end
	def pbGenerateAdEgg(pkmn)
		return false if !pkmn || party_full?
		pkmn = Pokemon.new(pkmn, Settings::EGG_LEVEL) if !pkmn.is_a?(Pokemon)
		# Set egg's details
		pkmn.name           = _INTL("Egg")
		pkmn.steps_to_hatch = pkmn.species_data.hatch_steps
		pkmn.obtain_text    = "Found on an adventure"
		pkmn.calc_stats
		pkmn.generateBrilliant if (PokeventureConfig::AreFoundFriendsBrilliant && defined?(poke.generateBrilliant))
		# Add egg to party
		party[party.length] = pkmn
		return true
	end
end

def giveAdventureItemList(itemlist)
  list = itemlist.dup.compact()
  string = ""
  while list.length() > 0
    item = list.pop
    count = list.tally[item]
    if count
      count+=1
    else
      count=1
    end
    itemdata = GameData::Item.get(item)
    name = (count>1) ? itemdata.name_plural : itemdata.name
    string += count.to_s+" "+name+", "
    $PokemonBag.pbStoreItem(item,count)
    list.delete(item)
  end
  Kernel.pbMessage(string[0...-2])
end
