class PokemonSummary_Scene
  def drawPageThree
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(248,248,248)
    shadow = Color.new(104,104,104)
    # Determine which stats are boosted and lowered by the Pokémon's nature
    statshadows = {}
    GameData::Stat.each_main { |s| statshadows[s.id] = shadow }
    if !@pokemon.shadowPokemon? || @pokemon.heartStage > 3
      @pokemon.nature_for_stats.stat_changes.each do |change|
        statshadows[change[0]] = Color.new(136,96,72) if change[1] > 0
        statshadows[change[0]] = Color.new(64,120,152) if change[1] < 0
      end
    end
    # Write various bits of text
    textpos = [
       [_INTL("HP"),243,70,2,base,statshadows[:HP]],
       [sprintf("%d/%d",@pokemon.hp,@pokemon.totalhp),382,70,1,Color.new(64,64,64),Color.new(176,176,176)],
	   [sprintf("%d",@pokemon.iv[:HP]),444,70,1,Color.new(64,64,64),Color.new(176,176,176)],
	   [sprintf("%d",@pokemon.ev[:HP]),500,70,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Attack"),225,114,0,base,statshadows[:ATTACK]],
       [sprintf("%d",@pokemon.attack),382,114,1,Color.new(64,64,64),Color.new(176,176,176)],
	   [sprintf("%d",@pokemon.iv[:ATTACK]),444,114,1,Color.new(64,64,64),Color.new(176,176,176)],
	   [sprintf("%d",@pokemon.ev[:ATTACK]),500,114,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Defense"),225,146,0,base,statshadows[:DEFENSE]],
       [sprintf("%d",@pokemon.defense),382,146,1,Color.new(64,64,64),Color.new(176,176,176)],
	   [sprintf("%d",@pokemon.iv[:DEFENSE]),444,146,1,Color.new(64,64,64),Color.new(176,176,176)],
	   [sprintf("%d",@pokemon.ev[:DEFENSE]),500,146,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Sp. Atk"),225,178,0,base,statshadows[:SPECIAL_ATTACK]],
       [sprintf("%d",@pokemon.spatk),382,178,1,Color.new(64,64,64),Color.new(176,176,176)],
	   [sprintf("%d",@pokemon.iv[:SPECIAL_ATTACK]),444,178,1,Color.new(64,64,64),Color.new(176,176,176)],
	   [sprintf("%d",@pokemon.ev[:SPECIAL_ATTACK]),500,178,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Sp. Def"),225,210,0,base,statshadows[:SPECIAL_DEFENSE]],
       [sprintf("%d",@pokemon.spdef),382,210,1,Color.new(64,64,64),Color.new(176,176,176)],
	   [sprintf("%d",@pokemon.iv[:SPECIAL_DEFENSE]),444,210,1,Color.new(64,64,64),Color.new(176,176,176)],
	   [sprintf("%d",@pokemon.ev[:SPECIAL_DEFENSE]),500,210,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Speed"),225,242,0,base,statshadows[:SPEED]],
       [sprintf("%d",@pokemon.speed),382,242,1,Color.new(64,64,64),Color.new(176,176,176)],
	   [sprintf("%d",@pokemon.iv[:SPEED]),444,242,1,Color.new(64,64,64),Color.new(176,176,176)],
	   [sprintf("%d",@pokemon.ev[:SPEED]),500,242,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Ability"),224,278,0,base,shadow]
    ]
    # Draw ability name and description
    ability = @pokemon.ability
    if ability
      textpos.push([ability.name,362,278,0,Color.new(64,64,64),Color.new(176,176,176)])
      drawTextEx(overlay,224,320,282,2,ability.description,Color.new(64,64,64),Color.new(176,176,176))
    end
    # Draw all text
    pbDrawTextPositions(overlay,textpos)
    # Draw HP bar
    if @pokemon.hp>0
      w = @pokemon.hp*96*1.0/@pokemon.totalhp
      w = 1 if w<1
      w = ((w/2).round)*2
      hpzone = 0
      hpzone = 1 if @pokemon.hp<=(@pokemon.totalhp/2).floor
      hpzone = 2 if @pokemon.hp<=(@pokemon.totalhp/4).floor
      imagepos = [
         ["Graphics/Pictures/Summary/overlay_hp",339,111,0,hpzone*6,w,6]
      ]
      pbDrawImagePositions(overlay,imagepos)
    end
  end
end