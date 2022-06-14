class NewDexNav

  def initialize
    @viewport1 = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport1.z = 99999
    @viewport2 = Viewport.new(30, 120, Graphics.width, Graphics.height)
    @viewport2.z = 999999
    @viewport3 = Viewport.new(0, 120, Graphics.width, Graphics.height)
    @viewport3.z = 999999
    $viewport1 = nil
    searchmon = 0
    @sprites = {}
    @encarray = []
    @pkmnsprite = []
    @navChoice = 0
    navAbil = []
    @ab = []
    encstringarray = [] # Savordez simplified this on discord but I kept it for me to understand better
    getEncData
    # Following variable is unused, but can be a good sub in if you need it
    #textColor=["0070F8,78B8E8","E82010,F8A8B8","0070F8,78B8E8"][$Trainer.gender]
    loctext = _INTL("<ac><c2=43F022E8>{1}</c2></ac>", $game_map.name)
    temparray = @encarray.dup  # doing `if @encarray.pop==7` actually pops the last species off before the loop!
    if temparray.pop==7 || @encarray.length == 0 # i picked 7 cause funny
      loctext += sprintf("<al><c2=FFCADE00>This area has no encounters</c2></al>")
      loctext += sprintf("<c2=63184210>-----------------------------------------</c2>")
    else
      i = 0
      @encarray.each do |specie|
     #   loctext += _INTL("<ar><c2=7FFF5EF7>{1}</c2></ar>",PBSpecies.getName(specie))
         iform = 0
         iform = iform
         encstringarray.push(GameData::Species.get(specie).name)#+", ")
         if iform != 0
           speciepic = "#{specie}_#{iform}"
         else
           speciepic = specie
         end
         @pkmnsprite[i]=PokemonSpeciesIconSprite.new(speciepic,@viewport2)
         if i > 6 && i < 14
           @pkmnsprite[i].y += 64
           @pkmnsprite[i].x = (64 * (i-7))
         elsif i > 13
           @pkmnsprite[i].y += 128
           @pkmnsprite[i].x = (64 * (i-14))
         else
           @pkmnsprite[i].x += 64 * i
         end
         i +=1
       end
      loctext += sprintf("<al><c2=FFCADE00>Total encounters for area: %s</c2></al>",@encarray.length)
      loctext += sprintf("<c2=63184210>-----------------------------------------</c2>")
      #loctext += sprintf("<al>%s</al>",encstringarray.join(", "))#.map{|a| a.to_s})
    end
    @sprites["locwindow"]=Window_AdvancedTextPokemon.new(loctext)
    @sprites["locwindow"].viewport=@viewport1
    @sprites["locwindow"].x=0
    @sprites["locwindow"].y=20
    @sprites["locwindow"].width=512 #if @sprites["locwindow"].width<420
    @sprites["locwindow"].height=344
    @sprites["locwindow"].setSkin("Graphics/Windowskins/frlgtextskin")
    @sprites["locwindow"].opacity=200
    @sprites["locwindow"].visible=true
    @sprites["nav"] = AnimatedSprite.new("Graphics/Pictures/rightarrow",8,40,28,2,@viewport3)
    @sprites["nav"].x = 5
    @sprites["nav"].y = 18
    @sprites["nav"].visible
    @sprites["nav"].play
    pbFadeInAndShow(@sprites)
    main
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def dispose
    pbFadeOutAndHide(@sprites) {pbUpdate}
    pbDisposeSpriteHash(@sprites)
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
  end

  def pbListOfEncounters(encounter)   # this method is from Nuri Yuri
    return [] unless encounter

    encable = encounter.compact # remove nils
    encable.map! { |enc_list| enc_list.map { |enc| enc[0] } }
    encable.flatten! # transform array of array into array
    encable.uniq! # prevent duplication

    return encable
  end

  def getEncData
    mapid = $game_map.map_id
    encounters = GameData::Encounter.get(mapid, $PokemonGlobal.encounter_version)
    return 0 if encounters == nil
    enc_type = encounters.types.keys[0]
    enc_type2 = encounters.types.keys[1]
    enc_type3 = encounters.types.keys[2]
    enc_type4 = encounters.types.keys[3]
    enc_type5 = encounters.types.keys[4]
    encounter_tables = Marshal.load(Marshal.dump(encounters.types))
    enc_list = encounter_tables[enc_type]
    enc_list2 = encounter_tables[enc_type2]
    enc_list3 = encounter_tables[enc_type3]
    enc_list4 = encounter_tables[enc_type4]
    enc_list5 = encounter_tables[enc_type5]
    encdata = []
    eLength = enc_list.length-1
    eLength2 = enc_list2.length-1 if enc_list2 != nil
    eLength3 = enc_list3.length-1 if enc_list3 != nil
    eLength4 = enc_list4.length-1 if enc_list4 != nil
    eLength5 = enc_list5.length-1 if enc_list5 != nil
      e1 = enc_list[0][1] if eLength >= 0
      e2 = enc_list[1][1] if eLength >= 1
      e3 = enc_list[2][1] if eLength >= 2
      e4 = enc_list[3][1] if eLength >= 3
      e5 = enc_list[4][1] if eLength >= 4
      e6 = enc_list[5][1] if eLength >= 5
      e7 = enc_list[6][1] if eLength >= 6
      e8 = enc_list[7][1] if eLength >= 7
      e9 = enc_list[8][1] if eLength >= 8
      e10 = enc_list[9][1] if eLength >= 9
      e11 = enc_list[10][1] if eLength >= 10
      e12 = enc_list[11][1] if eLength >= 11
      if enc_list2 != nil
        e13 = enc_list2[0][1] if eLength2 >= 0
        e14 = enc_list2[1][1] if eLength2 >= 1
        e15 = enc_list2[2][1] if eLength2 >= 2
        e16 = enc_list2[3][1] if eLength2 >= 3
        e17 = enc_list2[4][1] if eLength2 >= 4
        e18 = enc_list2[5][1] if eLength2 >= 5
        e19 = enc_list2[6][1] if eLength2 >= 6
        e20 = enc_list2[7][1] if eLength2 >= 7
        e21 = enc_list2[8][1] if eLength2 >= 8
        e22 = enc_list2[9][1] if eLength2 >= 9
        e23 = enc_list2[10][1] if eLength2 >= 10
        e24 = enc_list2[11][1] if eLength2 >= 11
      end
      if enc_list3 != nil
        e25 = enc_list3[0][1] if eLength3 >= 0
        e26 = enc_list3[1][1] if eLength3 >= 1
        e27 = enc_list3[2][1] if eLength3 >= 2
        e28 = enc_list3[3][1] if eLength3 >= 3
        e29 = enc_list3[4][1] if eLength3 >= 4
        e30 = enc_list3[5][1] if eLength3 >= 5
        e31 = enc_list3[6][1] if eLength3 >= 6
        e32 = enc_list3[7][1] if eLength3 >= 7
        e33 = enc_list3[8][1] if eLength3 >= 8
        e34 = enc_list3[9][1] if eLength3 >= 9
        e35 = enc_list3[10][1] if eLength3 >= 10
        e36 = enc_list3[11][1] if eLength3 >= 11
      end
      if enc_list4 != nil
        e37 = enc_list4[0][1] if eLength4 >= 0
        e38 = enc_list4[1][1] if eLength4 >= 1
        e39 = enc_list4[2][1] if eLength4 >= 2
        e40 = enc_list4[3][1] if eLength4 >= 3
        e41 = enc_list4[4][1] if eLength4 >= 4
        e42 = enc_list4[5][1] if eLength4 >= 5
        e43 = enc_list4[6][1] if eLength4 >= 6
        e44 = enc_list4[7][1] if eLength4 >= 7
        e45 = enc_list4[8][1] if eLength4 >= 8
        e46 = enc_list4[9][1] if eLength4 >= 9
        e47 = enc_list4[10][1] if eLength4 >= 10
        e48 = enc_list4[11][1] if eLength4 >= 11
      end
      if enc_list5 != nil
        e49 = enc_list5[0][1] if eLength5 >= 0
        e50 = enc_list5[1][1] if eLength5 >= 1
        e51 = enc_list5[2][1] if eLength5 >= 2
        e52 = enc_list5[3][1] if eLength5 >= 3
        e53 = enc_list5[4][1] if eLength5 >= 4
        e54 = enc_list5[5][1] if eLength5 >= 5
        e55 = enc_list5[6][1] if eLength5 >= 6
        e56 = enc_list5[7][1] if eLength5 >= 7
        e57 = enc_list5[8][1] if eLength5 >= 8
        e58 = enc_list5[9][1] if eLength5 >= 9
        e59 = enc_list5[10][1] if eLength5 >= 10
        e60 = enc_list5[11][1] if eLength5 >= 11
      end
      pLoc = $game_map.terrain_tag($game_player.x,$game_player.y)
      if GameData::TerrainTag.get(pLoc).id == :Grass || GameData::TerrainTag.get(pLoc).id == :None
        if $MapFactory.getFacingTerrainTag == :Water || $MapFactory.getFacingTerrainTag == :StillWater || $MapFactory.getFacingTerrainTag == :DeepWater
          $encTerr = :OldRod
        else
          $encTerr = :Land if $PokemonEncounters.has_land_encounters?
          $encTerr = :Cave if !$PokemonEncounters.has_land_encounters?
        end
      elsif GameData::TerrainTag.get(pLoc).id == :Rock
        if $MapFactory.getFacingTerrainTag == :Water || $MapFactory.getFacingTerrainTag == :StillWater || $MapFactory.getFacingTerrainTag == :DeepWater
          $encTerr = :OldRod
        else
          $encTerr = :Cave
        end
      elsif GameData::TerrainTag.get(pLoc).id == :HighBridge
        if $MapFactory.getFacingTerrainTag == :Water || $MapFactory.getFacingTerrainTag == :StillWater || $MapFactory.getFacingTerrainTag == :DeepWater
          $encTerr = :OldRod
        else
          $encTerr = :HighBridge
        end
      elsif GameData::TerrainTag.get(pLoc).id == :Graveyard
        if $MapFactory.getFacingTerrainTag == :Water || $MapFactory.getFacingTerrainTag == :StillWater || $MapFactory.getFacingTerrainTag == :DeepWater
          $encTerr = :OldRod
        else
          $encTerr = :Graveyard
        end
      elsif GameData::TerrainTag.get(pLoc).id == :Snow
        if $MapFactory.getFacingTerrainTag== :Water || $MapFactory.getFacingTerrainTag == :StillWater || $MapFactory.getFacingTerrainTag == :DeepWater
          $encTerr = :OldRod
        else
          $encTerr = :Snow if $PokemonEncounters.has_snow_encounters?
        end
      elsif GameData::TerrainTag.get(pLoc).id == :Sandy || GameData::TerrainTag.get(pLoc).id == :Sand
        if $MapFactory.getFacingTerrainTag == :Water || $MapFactory.getFacingTerrainTag == :StillWater || $MapFactory.getFacingTerrainTag == :DeepWater
          $encTerr = :OldRod
        else
          $encTerr = :Sandy if $PokemonEncounters.has_sandy_encounters?
          $encTerr = :Cave if $PokemonEncounters.has_cave_encounters? && !$PokemonEncounters.has_sandy_encounters?
          $encTerr = :Land if !$PokemonEncounters.has_cave_encounters? && !$PokemonEncounters.has_sandy_encounters?
        end
      elsif GameData::TerrainTag.get(pLoc).can_surf
        $encTerr = :OldRod
      elsif GameData::TerrainTag.get(pLoc).id == :Bridge
        $encTerr = :Water
      end
      terr = 0
      case $encTerr
      when enc_type
        terr = 0
      when enc_type2
        terr = 1
      when enc_type3
        terr = 2
      when enc_type4
        terr = 3
      when enc_type5
        terr = 4
      end
      if $encTerr == :OldRod
        terr += 4
      end
      case terr
      when 0
        encdata = [e1,e2,e3,e4,e5,e6,e7,e8,e9,e10,e11,e12]
      when 1
        encdata = [e13,e14,e15,e16,e17,e18,e19,e20,e21,e22,e23,e24]
      when 2
        encdata = [e25,e26,e27,e28,e29,e30,e31,e32,e33,e34,e35,e36]
      when 3
        encdata = [e37,e38,e39,e40,e41,e42,e43,e44,e45,e46,e47,e48]
      when 4
        encdata = [e1,e2,e3,e4,e5,e6,e7,e8,e9,e10,e11,e12,e13,e14,e15,e16,e17,e18,e19,e20,e21,e22,e23,e24,e25,e26,e27,e28,e29,e30,e31,e32,e33,e34,e35,e36]
      when 5
        encdata = [e1,e2,e3,e4,e5,e6,e7,e8,e9,e10,e11,e12,e13,e14,e15,e16,e17,e18,e19,e20,e21,e22,e23,e24,e25,e26,e27,e28,e29,e30,e31,e32,e33,e34,e35,e36,e37,e38,e39,e40,e41,e42,e43,e44,e45,e46,e47,e48]
      when 6
        encdata = [e13,e14,e15,e16,e17,e18,e19,e20,e21,e22,e23,e24,e25,e26,e27,e28,e29,e30,e31,e32,e33,e34,e35,e36,e37,e38,e39,e40,e41,e42,e43,e44,e45,e46,e47,e48,e49,e50,e51,e52,e53,e54,e55,e56,e57,e58,e59,e60]
      end
      encdata = encdata.uniq
      encdata = encdata.compact

      if $encTerr == nil
        @encarray = [7]
      else
        @encarray = encdata
        @temp = 0
        for i in 0..@encarray.length-1
          j = @encarray.length-2
          while (j >= i)
            if GameData::Species.get(@encarray[j]).id > GameData::Species.get(@encarray[j+1]).id
              #Kernel.pbMessage(_INTL("{1}",PBSpecies::pbGetSpeciesConst(@encarray[j])))
              @temp = @encarray[j]
              @encarray[j] = @encarray[j+1]
              @encarray[j+1] = @temp
            end
            j -= 1
          end
        end
      end
  end

  def main
    navMon = 0
    @navChoice = 0
    lastMon = @encarray.length - 1
    return if lastMon == -1
    if @encarray[navMon] == nil
      @sprites["navMon"]=Window_AdvancedTextPokemon.new(_INTL("<c2=FFCADE00>-</c2>"))
    else
      @sprites["navMon"]=Window_AdvancedTextPokemon.new(_INTL("<c2=FFCADE00>{1}</c2>",GameData::Species.get(@encarray[navMon]).name))
    end
    @sprites["navMon"].viewport = @viewport1
    @sprites["navMon"].x=340
    @sprites["navMon"].y=52
    @sprites["navMon"].width=156
    @sprites["navMon"].windowskin = nil
    textColor = "7FE00000"
    loop do
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)
      if Input.trigger?(Input::DOWN)
        next if lastMon < 7 && @navChoice < 7
        next if lastMon > 6 && lastMon <14 && @navChoice > 6 && @navChoice < 14
        next if (@navChoice + 7) > lastMon
        @navChoice +=7
        navMon += 7
        @sprites["nav"].y += 64
        @sprites["navMon"].text = _INTL("<c2={FFCADE00}>{1}</c2>",GameData::Species.get(@encarray[navMon]).name)
      elsif Input.trigger?(Input::UP) && @navChoice > 6
        @navChoice -=7
        navMon -=7
        @sprites["navMon"].text = _INTL("<c2=FFCADE00>{1}</c2>",GameData::Species.get(@encarray[navMon]).name)
        @sprites["nav"].y -= 64
      elsif Input.trigger?(Input::LEFT)
        if (@navChoice != 0 && @navChoice != 7 && @navChoice != 14)
          @navChoice -=1
          navMon -=1
          @sprites["navMon"].text = _INTL("<c2=FFCADE00>{1}</c2>",GameData::Species.get(@encarray[navMon]).name)
          @sprites["nav"].x -= 64
        else
          if lastMon < 6 && @navChoice == 0 || (lastMon < 13 && lastMon > 6 && @navChoice > 6) || (lastMon < 20 && lastMon > 13 && @navChoice > 13)
            @navChoice = lastMon
            navMon = lastMon
            @sprites["nav"].x = 5 + (64*navMon)
            @sprites["navMon"].text = _INTL("<c2=FFCADE00>{1}</c2>",GameData::Species.get(@encarray[navMon]).name)
          else
            @navChoice +=6
            navMon +=6
            @sprites["navMon"].text = _INTL("<c2=FFCADE00>{1}</c2>",GameData::Species.get(@encarray[navMon]).name)
            @sprites["nav"].x = 384
          end
        end
      elsif Input.trigger?(Input::RIGHT)
        if @navChoice == 6 || @navChoice == 13 || @navChoice == 20 || @navChoice == lastMon
          if lastMon < 6 && @navChoice == lastMon || (lastMon < 13 && lastMon > 6 && @navChoice > 6) || (lastMon < 20 && lastMon > 13 && @navChoice > 13)
            if lastMon < 6 && @navChoice == lastMon
              @navChoice = 0
              navMon = 0
              @sprites["navMon"].text = _INTL("<c2=FFCADE00>{1}</c2>",GameData::Species.get(@encarray[navMon]).name)
            elsif (lastMon < 13 && lastMon > 6 && @navChoice > 6)
              @navChoice = 7
              navMon = 7
              @sprites["navMon"].text = _INTL("<c2=FFCADE00>{1}</c2>",GameData::Species.get(@encarray[navMon]).name)
            elsif (lastMon < 20 && lastMon > 13 && @navChoice > 13)
              @navChoice = 14
              navMon = 14
              @sprites["navMon"].text = _INTL("<c2=FFCADE00>{1}</c2>",GameData::Species.get(@encarray[navMon]).name)
            end
            @sprites["nav"].x = 5
          else
            @navChoice -= 6
            navMon -= 6
            @sprites["navMon"].text = _INTL("<c2=FFCADE00>{1}</c2>",GameData::Species.get(@encarray[navMon]).name)
            @sprites["nav"].x -= 384
          end
        elsif (@navChoice !=6 && @navChoice !=13 && @navChoice !=20) || (@navChoice != lastMon)
          @navChoice +=1
          navMon +=1
          @sprites["navMon"].text = _INTL("<c2=FFCADE00>{1}</c2>",GameData::Species.get(@encarray[navMon]).name)
          @sprites["nav"].x += 64
        end
      elsif Input.trigger?(Input::C)
        if !$Trainer.pokedex.seen?(@encarray[navMon])
          pbMessage(_INTL("<c2={1}>You cannot search for this Pokémon yet!</c2>",textColor))
          pbMessage(_INTL("<c2={1}>Try looking for it first to register it to your Pokédex!</c2>",textColor))
          next
        elsif $currentDexSearch != nil
          pbMessage(_INTL("<c2={1}>You're already searching for one. Try having a look around!</c2>",textColor))
          @viewport2.dispose
          break
        else
          pbMessage(_INTL("<c2={1}>Searching\\ts[15]...\\wtnp[5]</c2>",textColor))
            if rand(2) == 0
               pbMessage(_INTL("<c2={1}>Oh! A Pokemon was found nearby!</c2>",textColor))
                species=@encarray[@navChoice]
               # We generate the pokemon they found (added to the encounters),
                # giving it some rare "egg moves"to incentivize using  this function
               $currentDexSearch=[species,DexNav.addRandomEggMove(species)]
               pbMessage(_INTL("<c2={1}>Try looking in wild Pokemon spots near you- it might appear!</c2>",textColor))
               pbFadeOutAndHide(@sprites)
               break
            else
               pbMessage(_INTL("<c2={1}>Nothing was found. Try looking somewhere else!</c2>",textColor))
            end
          end
      elsif Input.trigger?(Input::B)
        navMon = -1
        dispose
        break
      else
        next
      end
    end
    if navMon != -1
      @viewport2.dispose
      main2
    end
  end

  def main2
    if $currentDexSearch != nil
      searchmon = GameData::Species.get($currentDexSearch[0]).id
      maps = GameData::MapMetadata.try_get($game_map.map_id)   # Map IDs for Zharonian Forme
      form = 0
      form = form
      navRand = rand(3)
      $game_variables[400] = navRand
      hAbil = GameData::Species.get_species_form(searchmon,form).hidden_abilities
      navAbil1 = GameData::Species.get_species_form(searchmon,form).abilities
      if navAbil1.length == 1
        navAbil = [navAbil1[0],navAbil1[0],hAbil[0]]
      else
        navAbil = [navAbil1[0],navAbil1[1],hAbil[0]]
      end
      ab = GameData::Ability.get(navAbil[navRand]).name
      Graphics.update
      if $currentDexSearch[1] == nil
        dexMove = "-"
      else
        dexMove = GameData::Move.get($currentDexSearch[1]).name
      end
      searchmonName = GameData::Species.get($currentDexSearch[0]).name
      searchtext = [searchmonName,ab,dexMove]
      searchpic = "#{searchmon}_#{form}"
      @sprites["search"] = Window_AdvancedTextPokemon.newWithSize("",265,130,250,126,@viewport3)
      if navRand == 2
        @sprites["search"].text = _INTL("{1}\n<c2=463F0000>{2}</c2>\n{3}",searchtext[0],searchtext[1],searchtext[2])
      else
        @sprites["search"].text = _INTL("{1}\n{2}\n{3}",searchtext[0],searchtext[1],searchtext[2])
      end
      @sprites["search"].setSkin("Graphics/Windowskins/frlgtextskin")
      @sprites["search"].opacity = 200
      if form != 0
        @sprites["searchIcon"] = PokemonSpeciesIconSprite.new(searchpic,@viewport3)
      else
        @sprites["searchIcon"] = PokemonSpeciesIconSprite.new(searchmon,@viewport3)
      end
      @sprites["searchIcon"].x = 450
      @sprites["searchIcon"].y = 65
      $viewport1 = @viewport3
      pbFadeInAndShow(@sprites) {pbUpdate}
      $game_switches[NavNums::Dispose] = true
    end
  end
end

module NavNums
  Dispose = 350 #switch to dispose the Pokémon info overlay
  Ability = 400 #variable to set the ability of the chosen encounter
end

Events.onStartBattle+=proc {|_sender,e|
  if $game_switches[NavNums::Dispose] == true
    $viewport1.dispose
    $game_switches[NavNums::Dispose] = false
  end
}

Events.onMapChanging +=proc {|_sender,e|
  if $game_switches[NavNums::Dispose] == true
    if $currentDexSearch != nil
      $viewport1.dispose
    end
    $currentDexSearch = nil
    $game_switches[NavNums::Dispose] = false
  end
}

Events.onWildPokemonCreate+=proc {|sender,e|
    pokemon=e[0]
    # Checks current search value, if it exists, sets the Pokemon to it
    if $currentDexSearch != nil && $currentDexSearch.is_a?(Array)
      pLoc = $game_map.terrain_tag($game_player.x,$game_player.y)
      if GameData::TerrainTag.get(pLoc).id == $encTerr || (GameData::TerrainTag.get(pLoc).id == :Sand && encTerr == :Sandy) || ((GameData::TerrainTag.get(pLoc).id == :Rock || GameData::TerrainTag.get(pLoc).id == :Sand || GameData::TerrainTag.get(pLoc).id == :None) && $encTerr == :Cave) ||((GameData::TerrainTag.get(pLoc).id == :Grass || GameData::TerrainTag.get(pLoc).id == :None || GameData::TerrainTag.get(pLoc).id == :Sand) && $encTerr == :Land) ||((GameData::TerrainTag.get(pLoc).id == :Water || GameData::TerrainTag.get(pLoc).id == :StillWater || GameData::TerrainTag.get(pLoc).id == :DeepWater) && $encTerr == :OldRod)
        pokemon.species=$currentDexSearch[0]
        $chainNav = [$currentDexSearch[0],0] if $chain == nil
        $chain = 0 if $chain == nil
        if $chain == 0
          $chainNav[0]=$currentDexSearch[0]
          $chainNav[1]=1
        elsif $chain != nil && $currentDexSearch[0] == $chainNav[0]
          $chainNav[1]+=1
        elsif $chain != nil && $currentDexSearch[0] != $chainNav[0]
          $chainNav[0]=$currentDexSearch[0]
          $chainNav[1]=1
        end
        $chain = $chainNav[1]
        lvl = rand(100)
        if lvl > 80
          pokemon.level = pokemon.level + 10
        else
          pokemon.level = pokemon.level
        end
        pokemon.name=GameData::Species.get(pokemon.species).name
        pokemon.ability_index = $game_variables[NavNums::Ability]
        maps = GameData::MapMetadata.try_get($game_map.map_id)
        if $chain >= 0
          ivRand1 = rand(6)
        elsif $chain >= 5
          ivRand1 = rand(6)
          ivRand2 = rand(6)
        elsif $chain >= 10
          ivRand2 = rand(6)
          ivRand1 = rand(6)
          ivRand3 = rand(6)
        end
        if ivRand1 != nil
          case ivRand1
          when 0 then pokemon.iv[:HP] = 31
          when 1 then pokemon.iv[:ATTACK] = 31
          when 2 then pokemon.iv[:DEFENSE] = 31
          when 3 then pokemon.iv[:SPECIAL_ATTACK] = 31
          when 4 then pokemon.iv[:SPECIAL_DEFENSE] = 31
          when 5 then pokemon.iv[:SPEED] = 31
          end
        end
        if ivRand2 != nil
          case ivRand2
          when 0 then pokemon.iv[:HP] = 31
          when 1 then pokemon.iv[:ATTACK] = 31
          when 2 then pokemon.iv[:DEFENSE] = 31
          when 3 then pokemon.iv[:SPECIAL_ATTACK] = 31
          when 4 then pokemon.iv[:SPECIAL_DEFENSE] = 31
          when 5 then pokemon.iv[:SPEED] = 31
          end
        end
        if ivRand3 != nil
          case ivRand3
          when 0 then pokemon.iv[:HP] = 31
          when 1 then pokemon.iv[:ATTACK] = 31
          when 2 then pokemon.iv[:DEFENSE] = 31
          when 3 then pokemon.iv[:SPECIAL_ATTACK] = 31
          when 4 then pokemon.iv[:SPECIAL_DEFENSE] = 31
          when 5 then pokemon.iv[:SPEED] = 31
          end
        end
        pokemon.reset_moves
        if pokemon.moves[1] == nil
          pokemon.moves[1]=Pokemon::Move.new($currentDexSearch[1]) if $currentDexSearch[1]
        elsif pokemon.moves[1] != nil && pokemon.moves[2] == nil
          pokemon.moves[2]=Pokemon::Move.new($currentDexSearch[1]) if $currentDexSearch[1]
        elsif pokemon.moves[1] != nil && pokemon.moves[2] != nil
          pokemon.moves[3]=Pokemon::Move.new($currentDexSearch[1]) if $currentDexSearch[1]
        end
        # There is a higher chance for shininess, so we give it another chance to force it to be shiny
        tempInt = $PokemonBag.pbQuantity(GameData::Item.get(:SHINYCHARM))>0 ? 256 : 768
        if rand(tempInt)<=1+($chain/5).floor && $chain<46
         pokemon.makeShiny
        end
      end
        $currentDexSearch = nil
    end
}

class DexNav
  def self.addRandomEggMove(species)
    baby = GameData::Species.get(species).get_baby_species
    maps = GameData::MapMetadata.try_get($game_map.map_id)
    form = GameData::Species.get(species).form
    egg = GameData::Species.get_species_form(baby,form).egg_moves
    moveChoice = rand(egg.length)
    moves = egg[moveChoice]
    return moves
  end
end

class PokemonPauseMenu
  def pbStartPokemonMenu
    if !$Trainer
      if $DEBUG
        pbMessage(_INTL("The player trainer was not defined, so the pause menu can't be displayed."))
        pbMessage(_INTL("Please see the documentation to learn how to set up the trainer player."))
      end
      return
    end
    @scene.pbStartScene
    endscene = true
    commands = []
    cmdPokedex  = -1
    cmdPokemon  = -1
    cmdBag      = -1
    cmdTrainer  = -1
    cmdSave     = -1
    cmdOption   = -1
    cmdPokegear = -1
    cmdDexnav   = -1
    cmdDebug    = -1
    cmdQuit     = -1
    cmdEndGame  = -1
    if $Trainer.has_pokedex && $Trainer.pokedex.accessible_dexes.length > 0
      commands[cmdPokedex = commands.length] = _INTL("Pokédex")
    end
    commands[cmdPokemon = commands.length]   = _INTL("Pokémon") if $Trainer.party_count > 0
    commands[cmdBag = commands.length]       = _INTL("Bag") if !pbInBugContest?
    commands[cmdPokegear = commands.length]  = _INTL("Pokégear") if $Trainer.has_pokegear
    commands[cmdDexnav = commands.length]  = _INTL("DexNav")
    commands[cmdTrainer = commands.length]   = $Trainer.name
    if pbInSafari?
      if Settings::SAFARI_STEPS <= 0
        @scene.pbShowInfo(_INTL("Balls: {1}",pbSafariState.ballcount))
      else
        @scene.pbShowInfo(_INTL("Steps: {1}/{2}\nBalls: {3}",
           pbSafariState.steps, Settings::SAFARI_STEPS, pbSafariState.ballcount))
      end
      commands[cmdQuit = commands.length]    = _INTL("Quit")
    elsif pbInBugContest?
      if pbBugContestState.lastPokemon
        @scene.pbShowInfo(_INTL("Caught: {1}\nLevel: {2}\nBalls: {3}",
           pbBugContestState.lastPokemon.speciesName,
           pbBugContestState.lastPokemon.level,
           pbBugContestState.ballcount))
      else
        @scene.pbShowInfo(_INTL("Caught: None\nBalls: {1}",pbBugContestState.ballcount))
      end
      commands[cmdQuit = commands.length]    = _INTL("Quit Contest")
    else
      commands[cmdSave = commands.length]    = _INTL("Save") if $game_system && !$game_system.save_disabled
    end
    commands[cmdOption = commands.length]    = _INTL("Options")
    commands[cmdDebug = commands.length]     = _INTL("Debug") if $DEBUG
    commands[cmdEndGame = commands.length]   = _INTL("Quit Game")
    loop do
      command = @scene.pbShowCommands(commands)
      if cmdPokedex>=0 && command==cmdPokedex
        pbPlayDecisionSE
        if Settings::USE_CURRENT_REGION_DEX
          pbFadeOutIn {
            scene = PokemonPokedex_Scene.new
            screen = PokemonPokedexScreen.new(scene)
            screen.pbStartScreen
            @scene.pbRefresh
          }
        else
          if $Trainer.pokedex.accessible_dexes.length == 1
            $PokemonGlobal.pokedexDex = $Trainer.pokedex.accessible_dexes[0]
            pbFadeOutIn {
              scene = PokemonPokedex_Scene.new
              screen = PokemonPokedexScreen.new(scene)
              screen.pbStartScreen
              @scene.pbRefresh
            }
          else
            pbFadeOutIn {
              scene = PokemonPokedexMenu_Scene.new
              screen = PokemonPokedexMenuScreen.new(scene)
              screen.pbStartScreen
              @scene.pbRefresh
            }
          end
        end
      elsif cmdPokemon>=0 && command==cmdPokemon
        pbPlayDecisionSE
        hiddenmove = nil
        pbFadeOutIn {
          sscene = PokemonParty_Scene.new
          sscreen = PokemonPartyScreen.new(sscene,$Trainer.party)
          hiddenmove = sscreen.pbPokemonScreen
          (hiddenmove) ? @scene.pbEndScene : @scene.pbRefresh
        }
        if hiddenmove
          $game_temp.in_menu = false
          pbUseHiddenMove(hiddenmove[0],hiddenmove[1])
          return
        end
      elsif cmdBag>=0 && command==cmdBag
        pbPlayDecisionSE
        item = nil
        pbFadeOutIn {
          scene = PokemonBag_Scene.new
          screen = PokemonBagScreen.new(scene,$PokemonBag)
          item = screen.pbStartScreen
          (item) ? @scene.pbEndScene : @scene.pbRefresh
        }
        if item
          $game_temp.in_menu = false
          pbUseKeyItemInField(item)
          return
        end
      elsif cmdPokegear>=0 && command==cmdPokegear
        pbPlayDecisionSE
        pbFadeOutIn {
          scene = PokemonPokegear_Scene.new
          screen = PokemonPokegearScreen.new(scene)
          screen.pbStartScreen
          @scene.pbRefresh
        }
      elsif cmdDexnav>=0 && command==cmdDexnav
        pbPlayDecisionSE
        $viewport4.dispose
        pbFadeOutIn {
          if $currentDexSearch != nil && $currentDexSearch.is_a?(Array)
            pbMessage(_INTL("<c2=7FE00000>You are already searching!</c2>"))
            pbMessage(_INTL("<c2=7FE00000>Leave the route and return to search again!</c2>"))
            pbShowMenu
          else
            @scene = NewDexNav.new
          end
          return
        }
      elsif cmdTrainer>=0 && command==cmdTrainer
        pbPlayDecisionSE
        pbFadeOutIn {
          scene = PokemonTrainerCard_Scene.new
          screen = PokemonTrainerCardScreen.new(scene)
          screen.pbStartScreen
          @scene.pbRefresh
        }
      elsif cmdQuit>=0 && command==cmdQuit
        @scene.pbHideMenu
        if pbInSafari?
          if pbConfirmMessage(_INTL("Would you like to leave the Safari Game right now?"))
            @scene.pbEndScene
            pbSafariState.decision = 1
            pbSafariState.pbGoToStart
            return
          else
            pbShowMenu
          end
        else
          if pbConfirmMessage(_INTL("Would you like to end the Contest now?"))
            @scene.pbEndScene
            pbBugContestState.pbStartJudging
            return
          else
            pbShowMenu
          end
        end
      elsif cmdSave>=0 && command==cmdSave
        @scene.pbHideMenu
        scene = PokemonSave_Scene.new
        screen = PokemonSaveScreen.new(scene)
        if screen.pbSaveScreen
          @scene.pbEndScene
          endscene = false
          break
        else
          pbShowMenu
        end
      elsif cmdOption>=0 && command==cmdOption
        pbPlayDecisionSE
        pbFadeOutIn {
          scene = PokemonOption_Scene.new
          screen = PokemonOptionScreen.new(scene)
          screen.pbStartScreen
          pbUpdateSceneMap
          @scene.pbRefresh
        }
      elsif cmdDebug>=0 && command==cmdDebug
        pbPlayDecisionSE
        pbFadeOutIn {
          pbDebugMenu
          @scene.pbRefresh
        }
      elsif cmdEndGame>=0 && command==cmdEndGame
        @scene.pbHideMenu
        if pbConfirmMessage(_INTL("Are you sure you want to quit the game?"))
          scene = PokemonSave_Scene.new
          screen = PokemonSaveScreen.new(scene)
          if screen.pbSaveScreen
            @scene.pbEndScene
          end
          @scene.pbEndScene
          $scene = nil
          return
        else
          pbShowMenu
        end
      else
        pbPlayCloseMenuSE
        break
      end
    end
    @scene.pbEndScene if endscene
  end
end
