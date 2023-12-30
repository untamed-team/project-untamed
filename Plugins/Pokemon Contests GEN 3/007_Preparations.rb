#====================================================================================
#  DO NOT MAKE EDITS HERE
#====================================================================================

#====================================================================================
#  Main Command
#====================================================================================
def pbPokemonContest(rank: nil, category: nil, pokemon: nil)
	pbPrepPokemonContest(rank, category, pokemon)
	return if !$PokemonGlobal.pokemonContest
	pbCurrentPokemonContest.pbIntroductionRound
	pbCurrentPokemonContest.pbTalentRound
	pbCurrentPokemonContest.pbResults
	pbEndPokemonContest
end

#====================================================================================
#  Setup In Lobby
#====================================================================================
def pbPrepPokemonContest(rank = nil, category = nil, pokemon = nil)
	if $player.party.size <=0
		pbMessage(_INTL("Oh, you don't have any Pokémon!"))
		pbMessage(_INTL("Please come back when you have a Pokémon."))
		return
	end
	if ContestSettings::REQUIRE_CONTEST_PASS_ITEM && !$bag.has?(:CONTESTPASS)
		pbMessage(_INTL("Oh, you don't have a Contest Pass!"))
		pbMessage(_INTL("Please come back when you have a Contest Pass."))
		return
	end
	rank = ContestFunctions.sanitizeRank(rank)
	category = ContestFunctions.sanitizeCategory(category)
	pbMessage(_INTL("Hello!"))
	pbMessage(_INTL("This is the reception counter for Pokémon Contests."))
	cmds = [_INTL("Enter"),_INTL("Cancel")]
	if rank || category
		rankName = ContestFunctions.getRankName(rank,true)
		catName = ContestFunctions.getCategoryName(category,true)
		pbMessage(_INTL("We're currently accepting registrations for {1}{2}Pokémon Contests.",rankName,catName))
		choice = pbMessage(_INTL("Would you like to enter your Pokémon in a {1}{2}Contest?",rankName,catName),cmds,-1)	
	else
		choice = pbMessage(_INTL("Would you like to enter your Pokémon in a Contest?"),cmds,-1)
	end
	return pbMessage(_INTL("We hope you will participate another time.")) if choice < 0 || choice == 1
	#Choose Category
	if !category
		cmds_c = [_INTL("#{pbContestCatName(0)} Contest"), _INTL("#{pbContestCatName(1)} Contest"), _INTL("#{pbContestCatName(2)} Contest"), _INTL("#{pbContestCatName(3)} Contest"), _INTL("#{pbContestCatName(4)} Contest"), _INTL("Exit")]
		cat = pbMessage(_INTL("Which Contest would you like to enter?"), cmds_c, -1)
		return pbMessage(_INTL("We hope you will participate another time.")) if cat < 0 || cat == 5
		category = cat
	end
	#Choose Rank
	if !rank
		cmds_r = [_INTL("Normal Rank"), _INTL("Super Rank"), _INTL("Hyper Rank"), _INTL("Master Rank"), _INTL("Exit")]
		rnk = pbMessage(_INTL("Which Rank would you like to enter?"), cmds_r, -1)
		return pbMessage(_INTL("We hope you will participate another time.")) if rnk < 0 || rnk == 4
		rank = rnk
	end
	#Choose Pokemon
	loop do
		if !pokemon
			pbMessage(_INTL("Which Pokémon would you like to enter?"))
			if rank == 0
				pbChoosePokemon(1, 3, proc { |p| !p.egg? && !(p.shadowPokemon? rescue false)})
				pkmn = pbGet(1)
			else
				ribbon = ContestSettings::CONTEST_RIBBONS[category][rank-1]
				pbChoosePokemon(1, 3, proc { |p| !p.egg? && !(p.shadowPokemon? rescue false) && p.hasRibbon?(ribbon)})
				pkmn = pbGet(1)
			end
		end
		pokemon = pkmn
		if pokemon < 0
			if pbConfirmMessage(_INTL("Cancel participation?"))
				return pbMessage(_INTL("We hope you will participate another time."))
			else
				#pbMessage(_INTL("Which Pokémon would you like to enter?"))
				pokemon = nil
				next
			end
		end	
		#Pokemon has Ribbon
		if $player.party[pokemon].hasRibbon?(ContestSettings::CONTEST_RIBBONS[category][rank])
			pbMessage(_INTL("Oh, that Ribbon..."))
			pbMessage(_INTL("Your {1} has won this Contest before, hasn't it?", $player.party[pokemon].name))
			if pbConfirmMessage(_INTL("Would you like to enter it in this Contest anyway?"))
				
			else
				#pbMessage(_INTL("Which Pokémon would you like to enter?"))
				pokemon = nil
				next
			end
		end
		if pbConfirmMessage(_INTL("Enter {1} in the Contest?",$player.party[pokemon].name))
			#return pbMessage(_INTL("We hope you will participate another time."))
		else
			#pbMessage(_INTL("Which Pokémon would you like to enter?"))
			pokemon = nil
			next
		end	
		break
	end
	# if pbConfirmMessage("Cancel participation?")
		# return pbMessage(_INTL("We hope you will participate another time."))
	# else
		# pbMessage(_INTL("Which Pokémon would you like to enter?"))
		# pokemon = nil
		# next
	# end
	pbMessage(_INTL("Okay, your {1} will be entered in this Contest.", $player.party[pokemon].name))
	pbMessage(_INTL("{1} is Entry Number 4. The Contest will begin shortly.", $player.party[pokemon].name))	
	pbCurrentPokemonContest.set(rank, category, pokemon, ContestFunctions.getHallMapInfo(rank, category), ContestFunctions.getReturnMapInfo(rank, category))
	ContestFunctions.bringPlayerToContestHall
	return true
end

#====================================================================================
#  End the Contest
#====================================================================================

def pbEndPokemonContest
	ContestFunctions.bringPlayerToLobby
	$PokemonGlobal.pokemonContest = nil
	$PokemonGlobal.nextContestTrainerOne = nil
	$PokemonGlobal.nextContestTrainerTwo = nil
	$PokemonGlobal.nextContestTrainerThree = nil
	
end

#====================================================================================
#  Misc Contest Functions
#====================================================================================

module ContestFunctions
	module_function
	
	def bringPlayerToContestHall
		map = $game_map.map_id
		guideEvent = $game_map.events[ContestSettings::FRONT_DESK_GUIDE_EVENT]
		doors = ContestSettings::FRONT_DESK_DOOR_EVENTS
		# Front Desk Guide
		pbMoveRoute(guideEvent,[PBMoveRoute::Left,
			PBMoveRoute::Left,PBMoveRoute::TurnDown])
		pbWaitForCharacterMove(guideEvent)
		pbWait(5)
		doors.length.times{ |i| $game_self_switches[[map, doors[i], 'A']] = true; $game_map.need_refresh = true} # Front Desk Door
		pbMoveRoute(guideEvent,[PBMoveRoute::Down,PBMoveRoute::Down])
		pbWaitForCharacterMove(guideEvent)
		pbWait(5)
		doors.length.times{ |i| $game_self_switches[[map, doors[i], 'A']] = false; $game_map.need_refresh  = true} # Front Desk Door
		pbWait(5)
		pbMoveRoute(guideEvent,[PBMoveRoute::TurnRight])
		pbWaitForCharacterMove(guideEvent)
		pbMoveRoute($game_player,[PBMoveRoute::TurnLeft])
		pbWaitForCharacterMove($game_player)
		pbMessage(_INTL("Please, follow me."))
		pbMoveRoute($game_player,[PBMoveRoute::Left])
		pbWaitForCharacterMove($game_player)
		pbMoveRoute(guideEvent,[PBMoveRoute::Turn180])
		pbWaitForCharacterMove(guideEvent)
		pbMoveRoute(guideEvent,[PBMoveRoute::Left,PBMoveRoute::Left,
			PBMoveRoute::Left,PBMoveRoute::Up,PBMoveRoute::Up,PBMoveRoute::Turn180])
		pbWait(1)
		pbMoveRoute($game_player,[PBMoveRoute::Left,PBMoveRoute::Left,PBMoveRoute::Left,
			PBMoveRoute::Left,PBMoveRoute::Up])
		pbWaitForCharacterMove($game_player)
		pbMessage(_INTL("Please, go in through here. Good luck!"))
		pbMoveRoute($game_player,[PBMoveRoute::Left,PBMoveRoute::Up,PBMoveRoute::Up])
		pbWaitForCharacterMove($game_player)
		hallInfo = pbCurrentPokemonContest.hallMapInfo
		self.transfer(*hallInfo,8)
		pbScrollMap(8, 2, 3)
		pbScrollMap(4, 3, 3)
	end
	
	def bringPlayerToLobby
		returnInfo = pbCurrentPokemonContest.returnMapInfo
		self.transfer(*returnInfo)

	end

	def set_switch(map, event, switch='A', set=true)
		$game_self_switches[[map, event, switch]] = set
		return unless set
		$game_map.need_refresh = set
		loop do
			break if !$game_self_switches[[map, event, switch]]
			pbWait(1)
		end
	end
		
	def transfer(id, x, y, dir)
		if $scene.is_a?(Scene_Map)
			pbFadeOutIn {
				$game_temp.player_transferring   = true
				$game_temp.transition_processing = true
				$game_temp.player_new_map_id    = id
				$game_temp.player_new_x         = x
				$game_temp.player_new_y         = y
				$game_temp.player_new_direction = dir
				pbWait(35)
				$scene.transfer_player
				pbWait(5)
			}
		end
	end
	
	def getHallMapInfo(rank, category)
		get = ContestSettings::ROOM_MAP_COORDINATES[rank][category]
		get = ContestSettings::ROOM_MAP_COORDINATES[rank][0] if !get
		return get
	end
	
	def getReturnMapInfo(rank, category)
		get = ContestSettings::LOBBY_MAP_COORDINATES[rank][category]
		get = ContestSettings::DEFAULT_RETURN_COORDINATES if !get
		return get
	end
	
	def sanitizeRank(rank)
		return nil if rank == nil
		return rank if rank.is_a?(Integer) && [0,1,2,3].include?(rank)
		rank = rank.to_s if rank.is_a?(Symbol)
		rank = rank.upcase if rank.is_a?(String)
		case rank
		when "NORMAL" then rank = 0
		when "SUPER" then rank = 1
		when "HYPER" then rank = 2
		when "MASTER" then rank = 3
		else rank = nil; end		
		return rank
	end
	
	def sanitizeCategory(category)
		return nil if category == nil
		return category if category.is_a?(Integer) && [0,1,2,3,4].include?(category)
		return GameData::ContestType.get(category).icon_index if category.is_a?(Symbol)
		category = category.upcase if category.is_a?(String)
		GameData::ContestType.each { |type|
			return type.icon_index if [type.name.upcase,type.long_name.upcase].include?(category)
		}
		return nil
	end
	
	def getRankName(int,spaceAfter=false)
		return "" if !int
		arr = ["Normal Rank","Super Rank","Hyper Rank","Master Rank"]
		return arr[int] + (spaceAfter ? " " : "")
	end
	
	def getRankNameShort(int,spaceAfter=false)
		return "" if !int
		arr = ["Normal","Super","Hyper","Master"]
		return arr[int] + (spaceAfter ? " " : "")
	end
	
	def getCategoryName(int,spaceAfter=false)
		return "" if !int
		arr = []
		GameData::ContestType.each { |type|
			arr.push(type.long_name)
		}
		return arr[int] + (spaceAfter ? " " : "")
	end
	
	def getCategoryNameShort(int,spaceAfter=false)
		return "" if !int
		arr = []
		GameData::ContestType.each { |type|
			arr.push(type.name)
		}
		return arr[int] + (spaceAfter ? " " : "")
	end
	
end

def pbContestCatName(int,spaceAfter=false)
	return ContestFunctions.getCategoryName(int,spaceAfter)
end

def pbContestCatShortName(int,spaceAfter=false)
	return ContestFunctions.getCategoryNameShort(int,spaceAfter)
end

class ContestTrainerSprite
	def initialize(event, map, _viewport)
		@event     = event
		@id		   = event.id
		@map       = map
		@disposed  = false
		@event.character_name = ""
		set_event_graphic   # Set the event's graphic
	end

	def dispose
		@event    = nil
		@map      = nil
		@disposed = true
	end

	def disposed?
		@disposed
	end

	def set_event_graphic
		if @id == ContestSettings::TRAINER_NPC_ONE_EVENT
			@event.character_name = pbCurrentPokemonContest.trainerOne.character_sprite
		elsif @id == ContestSettings::TRAINER_NPC_TWO_EVENT
			@event.character_name = pbCurrentPokemonContest.trainerTwo.character_sprite
		elsif @id == ContestSettings::TRAINER_NPC_THREE_EVENT
			@event.character_name = pbCurrentPokemonContest.trainerThree.character_sprite
		end
	end

	def update
		set_event_graphic
	end
end


EventHandlers.add(:on_new_spriteset_map, :add_contest_trainer_graphics,
  proc { |spriteset, viewport|
    map = spriteset.map
    map.events.each do |event|
      next if !event[1].name[/contesttrainer/i]
      spriteset.addUserSprite(ContestTrainerSprite.new(event[1], map, viewport))
    end
  }
)