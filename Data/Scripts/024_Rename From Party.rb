#Modified by Gardenette to bring up the full naming screen from party

MenuHandlers.add(:party_menu, :rename, {
  "name"      => _INTL("Rename"),
  "order"     => 55,
  "condition" => proc { |screen, party, party_idx| next !party[party_idx].egg? },
  "effect"    => proc { |screen, party, party_idx|
    pkmn = party[party_idx]
    #name = pbMessageFreeText("#{pkmn.speciesName}'s nickname?",_INTL(""),false,Pokemon::MAX_NAME_SIZE) { screen.pbUpdate }

    pkmn.name = pbEnterPokemonName(_INTL("{1}'s nickname?", pkmn.speciesName),
                                   0, Pokemon::MAX_NAME_SIZE, initialText = pkmn.name, pkmn)
    #name=pkmn.speciesName if name ==""
    #pkmn.name=name
    screen.pbDisplay(_INTL("{1} was renamed to {2}.",pkmn.speciesName,pkmn.name))
  }
})