#By Gardenette, Micah
#Work in Progress

class Camping

	def resetTagPositions
		#move player to center of map
		$game_player.moveto(19, 18)
  
		pbMoveRoute($game_player, [
		PBMoveRoute::TurnDown
		])

		#move event a few tiles away from player
		$game_map.events[@event.id].moveto(19, 24)
  
		pbMoveRoute($game_map.events[@event.id], [
		PBMoveRoute::TurnUp
		])
	end #def resetTagPositions

	#Adapted from Voltseon's A-Star Pathfinding calc_move_route_inverted
	def getDirection(position_a, position_b)
		return 6 if position_a.x < position_b.x
		return 4 if position_a.x > position_b.x
		return 2 if position_a.y > position_b.y
		return 8 if position_a.y < position_b.y
	end

	def runAway
		x = $game_map.events[@event.id].x
		y = $game_map.events[@event.id].y
		dist = calc_dist([x, y], [$game_player.x, $game_player.y])
		if dist < 5
			d = getDirection($game_map.events[@event.id], $game_player)
			# Copied from passable? in game character 
			if $game_map.events[@event.id].passable?(x, y, d, true) 
				pbMoveRoute($game_map.events[@event.id], [
				calc_move_route_inverted($game_map.events[@event.id], $game_player)
				])
			end #if $game_map.events[@event.id].passable?
		end #if dist < 5
	end #def runAway
  
	def whoIsIt
		case @chaser
		when nil
			#flip a coin to see who is it first
			chance = rand(1..2)
			if chance == 1
				@chaser = "Pkmn"
			else
				@chaser = "Player"
			end
		when "Pkmn"
			@chaser = "Player"
		when "Player"
			@chaser = "Pkmn"
		end #case
		
		if @chaser == "Pkmn"
			pbMessage(_INTL("{1} is it! Run!", @pkmn.name))
		else
			pbMessage(_INTL("You are it! Chase {1}!", @pkmn.name))
		end #if @chaser == "Pkmn"
  
		#whistle blow?
		#START!
		
	end #of def whoIsIt

	def playAgain
		if pbConfirmMessage(_INTL("Do you want to keep playing tag?"))
			campFadeOut
			resetTagPositions
			campFadeIn
			whoIsIt
		else
			toggleOffCampPlayTag
			campFadeOut
			restoreCampersToCoords
			campFadeIn
		end #if pbConfirmMessage
	end #def playAgain

	def playTag
		campFadeOut  
		getCamperCoords
		moveCampersToSide
		resetTagPositions
		campFadeIn
		whoIsIt
		beginChasing
	end #def playTag
	
	def stopChasing
		#remove from the on_frame_update event handler to stop checking event positions, running away, etc.
		EventHandlers.remove(:on_frame_update, :tag_check_positions)
		
		pbMoveRoute($game_map.events[@event.id], [
			PBMoveRoute::TurnTowardPlayer,
			PBMoveRoute::Jump,0,0,
			PBMoveRoute::Jump,0,0
		])
  
		pbSEPlay("Cries/"+@species,100)
		
		case @chaser
		when "Pkmn"
			pbMessage(_INTL("{1} got close enough to grab you!", @pkmn.name))
		when "Player"
			pbMessage(_INTL("You caught up to {1}!", @pkmn.name))
		end

		playAgain
	end
	
	def beginChasing
		#add to the on_frame_update event handler to check event positions, run away, etc.
		EventHandlers.add(:on_frame_update, :tag_check_positions,
		proc {
			#pokemon chases you
			if @chaser == "Pkmn" && pbEventCanReachPlayer?($game_map.events[@event.id], $game_player, 1)
				stopChasing
			end #if @chaser == "Pkmn"
      
			#you chase pokemon
			if @chaser == "Player"
				runAway
				if pbEventCanReachPlayer?($game_player, $game_map.events[@event.id], 1)
					#player caught the pokemon
					stopChasing
				end #if pbEventCanReachPlayer?
			end #if @chaser == "Player"
        
		}) #end of eventhandler
	end #def beginChasing

	def toggleOffCampPlayTag
		EventHandlers.remove(:on_frame_update, :playTag)
	end

end #class Camping