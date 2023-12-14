#==============================================================================
# Config
# LA Move Relearner base by IndianAnimator script by Kotaro
# Heavily modified (just commented stuff out lol) by Gardenette
module Settings
  EGGMOVESSWITCH  = 1000
end
EGGMOVES = false
#==============================================================================

class Pokemon
  attr_writer :unlocked_relearner
  
  def unlocked_relearner
    return @unlocked_relearner ||= false
  end
end

MenuHandlers.add(:party_menu, :relearner, {
  "name"      => _INTL("Relearn Moves"),
  "order"     => 65,
	"condition" => proc { |screen, party, party_idx| # added #by low
		next $game_switches[RELEARNERSWITCH]
		next false if pkmn.egg? || pkmn.shadowPokemon? || !pkmn.can_relearn_move?
		next true
	},
  "effect"    => proc { |screen, party, party_idx|
    pkmn = party[party_idx]
		if !$game_switches[RELEARNERSWITCH]
			pbMessage(_INTL("This menu has yet to be unlocked."))
    elsif pkmn.egg?
      pbMessage(_INTL("An egg can't remember moves."))
    elsif pkmn.shadowPokemon?
      pbMessage(_INTL("You can't use the Move Relearner on a shadow Pokémon."))
    elsif !pkmn.can_relearn_move?
      pbMessage(_INTL("This Pokémon has no moves to relearn."))
    elsif
      #disable if flag "LockRelearnMoves" is on the map (probably will be used
      #for E4)
      if $game_map.metadata&.has_flag?("LockRelearnMoves")
        pbSEPlay("Anim/buzzer")
        pbMessage(_INTL("You can't do that here."))
      else
        pbRelearnMoveScreen(party[party_idx])
      end
    end
    #else
      #if $bag.has?(:HEARTSCALE)
      #  yes = pbConfirmMessage(
      #      _INTL("Would you like to unlock the Move Relearner for this Pokémon for 1 Heart Scale?"))
      #  if yes
      #    pkmn.unlocked_relearner = true
      #    $bag.remove(:HEARTSCALE)
      #    pbMessage(_INTL("You can now use the Move Relearner for this Pokémon."))
      #    pbRelearnMoveScreen(party[party_idx])
      #  end
      #else
      #  pbMessage(_INTL("You can unlock the Move Relearner for this Pokémon for 1 Heart Scale."))
      #end
    #end
  }
})

# edited to accomodate egg move relearners #by low
class MoveRelearnerScreen
  def pbGetRelearnableMoves(pkmn,eggmoverelearn=false)
    return [] if !pkmn || pkmn.egg? || pkmn.shadowPokemon?
    moves = []
		if eggmoverelearn
			GameData::Species.get(pkmn.species).get_egg_moves.each do |m|
				next if pkmn.hasMove?(m)
				moves.push(m)
			end
		else
			# necturna clause #by low
			necclause = false
			if !pkmn.sketchMove.nil?
				necclause = true if pkmn.hasMove?(pkmn.sketchMove)
				#~ print necclause
			end
			pkmn.getMoveList.each do |m|
				next if m[0] > pkmn.level || pkmn.hasMove?(m[1])
				next if m[1] == :SKETCH && necclause
				moves.push(m[1]) if !moves.include?(m[1])
			end
			if $game_switches[Settings::EGGMOVESSWITCH] && pkmn.first_moves || EGGMOVES==true && pkmn.first_moves
				tmoves = []
				pkmn.first_moves.each do |i|
					tmoves.push(i) if !moves.include?(i) && !pkmn.hasMove?(i)
				end
				moves = tmoves + moves   # List first moves before level-up moves
			end
    end
    return moves | []   # remove duplicates
  end
end