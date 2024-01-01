RECEIVE_OLD = false
RECEIVE_MASTER = false
ItemHandlers::UseOnPokemon.addIf(proc { |item| GameData::Item.get(item).is_poke_ball? },
  proc { |item, qty, pkmn, scene|
    ballname = GameData::Item.get(item).name
    if pkmn.poke_ball != item
      
      newitem = pkmn.poke_ball
      newname = GameData::Item.get(newitem).name
      
      #if using on a pokemon with the special starter pokeballs, warn the player
      if pkmn.poke_ball == :STARTERBALLGRASS || pkmn.poke_ball == :STARTERBALLFIRE || pkmn.poke_ball == :STARTERBALLWATER
        warning = "\\c[2]Its current Pokéball is special and can never be obtained again since it will break! Are you sure you want to put {1} in the {2}?"
      else
        warning = "Place {1} in the {2}? Its current Pokéball will break."
      end
      
      if pbConfirmMessage(_INTL(warning,pkmn.name,ballname))  { scene.pbUpdate }        
        pbSEPlay("Battle recall")
        pbMessage(_INTL("{1} was placed in the {2}.",pkmn.name,ballname))  { scene.pbUpdate }
        if RECEIVE_OLD == true
          if pkmn.poke_ball!=:MASTERBALL || RECEIVE_MASTER == true
            pbSEPlay("Battle catch click")
            pbMessage(_INTL("Took {1}'s old {2}.",pkmn.name,newname))  { scene.pbUpdate }
            $bag.add(newitem)
          else
            pbSEPlay("Battle damage weak")
            pbMessage(_INTL("{1}'s old {2} broke when you tried to remove it!",pkmn.name,newname))  { scene.pbUpdate }
          end
        else
          pbSEPlay("Battle damage weak")
          pbMessage(_INTL("{1}'s old {2} broke when you tried to remove it!",pkmn.name,newname))  { scene.pbUpdate }
        end
        pkmn.poke_ball = item
        next true
      end
    else
      pbMessage(_INTL("{1} is already stored in a {2}.",pkmn.name,ballname))  { scene.pbUpdate }
    end
    next false
  }
)