class Battle
  def pbSetSeen(battler)
    return if !battler || !@internalBattle
    if battler.is_a?(Battler)
      pbPlayer.pokedex.register(battler.displaySpecies, battler.displayGender, battler.displayForm, battler.shiny?)
      registerSpeciesSeen(battler.displaySpecies, battler.displayGender, battler.displayForm, battler.shiny?) if wildBattle? && battler.index.odd?
    else
      pbPlayer.pokedex.register(battler.species)
    end
  end

  def pbSetCaught(battler)
    return if !battler || !@internalBattle
    if battler.is_a?(Battler)
      pbPlayer.pokedex.register_caught(battler.displaySpecies)
      registerSpeciesCaught(battler.displaySpecies, battler.displayGender, battler.displayForm, battler.shiny?) if wildBattle? && battler.index.odd?
    else
      pbPlayer.pokedex.register_caught(battler.species)
      registerSpeciesCaught(battler.species, battler.gender, battler.form, battler.shiny?) if wildBattle?
    end
  end

  def pbSetDefeated(battler)
    return if !battler || !@internalBattle
    if battler.is_a?(Battler)
      pbPlayer.pokedex.register_defeated(battler.displaySpecies)
      registerSpeciesDefeated(battler.displaySpecies, battler.displayGender, battler.displayForm, battler.shiny?) if wildBattle? && battler.index.odd?
    else
      pbPlayer.pokedex.register_defeated(battler.species)
    end
  end
end 

class SafariBattle
  def pbSetSeen(battler)
    return if !battler
    if battler.is_a?(Battle::Battler)
      pbPlayer.pokedex.register(battler.displaySpecies, battler.displayGender, battler.displayForm, battler.shiny?)
      registerSpeciesSeen(battler.displaySpecies, battler.displayGender, battler.displayForm, battler.shiny?) if wildBattle? #&& battler.index.odd?
    else
      pbPlayer.pokedex.register(battler.species)
      registerSpeciesSeen(battler.species, battler.gender, battler.form, battler.shiny?) if wildBattle? #&& battler.index.odd?
    end
  end

  def pbSetCaught(battler)
    return if !battler
    if battler.is_a?(Battle::Battler)
      pbPlayer.pokedex.register_caught(battler.displaySpecies)
      registerSpeciesCaught(battler.displaySpecies, battler.displayGender, battler.displayForm, battler.shiny?) if wildBattle? #&& battler.index.odd?
    else
      pbPlayer.pokedex.register_caught(battler.species)
      registerSpeciesCaught(battler.species, battler.gender, battler.form, battler.shiny?) if wildBattle? #&& battler.index.odd?
    end
  end
end 
