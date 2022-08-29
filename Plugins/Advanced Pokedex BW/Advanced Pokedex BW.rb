class PokemonPokedexInfo_Scene
  # Switch number that toggle this script ON/OFF
  SWITCH=76
  
  # When true displays TMs/TRs/HMs/Tutors moves
  SHOW_MACHINE_TUTOR_MOVES = true
  
  # When false doesn't displays machine moves that aren't in any TM/TR/HM item
  SHOW_TUTOR_MOVES = true

  # When true displays TMs/TRs/HMs/Tutors without their subdivisions
  SHOW_ALL_MACHINE_TUTOR_TOGETHER = false
  
  # TMs/TRs/HMs digits to show on list. When 0, doesn't show number
  MACHINE_DIGITS = 3
  
  # When true always shows the egg moves of the first evolution stage
  EGG_MOVES_FIRST_STAGE = true
  
  alias :pbStartSceneOldFL :pbStartScene
  def pbStartScene(dexlist,index,region)
    @maxPage = $game_switches[SWITCH] ? 4 : 3
    @subPage=1
    pbStartSceneOldFL(dexlist,index,region)
    @sprites["advancedicon"]=PokemonSpeciesIconSprite.new(nil,@viewport)
    @sprites["advancedicon"].setOffset(PictureOrigin::Center)
    @sprites["advancedicon"].x = 52
    @sprites["advancedicon"].y = 310
    @sprites["advancedicon"].visible = false
  end
  
  alias :drawPageOldFL :drawPage
  def drawPage(page)
    drawPageOldFL(page)
    return if @brief
    dexbarVisible = $game_switches[SWITCH] && @page<=3
    @sprites["dexbar"] = IconSprite.new(0,0,@viewport) if !@sprites["dexbar"]
    @sprites["dexbar"].visible = dexbarVisible
    if dexbarVisible
      barBitmapPath = [
        nil,
        _INTL("Graphics/Pictures/Pokedex/advancedInfoBar"),
        _INTL("Graphics/Pictures/Pokedex/advancedAreaBar"),
        _INTL("Graphics/Pictures/Pokedex/advancedFormsBar")
      ]
      @sprites["dexbar"].setBitmap(barBitmapPath[@page])
      @sprites["dexbar"].y = Graphics.height - @sprites["dexbar"].bitmap.height
    end
    
    @sprites["advancedicon"].visible = page==4 if @sprites["advancedicon"]
    if @sprites["advancedicon"] && @sprites["advancedicon"].visible
      @sprites["advancedicon"].pbSetParams(@species,@gender,@form)
    end
    drawPageAdvanced if page==4
  end

  alias :pbUpdateOldFL :pbUpdate
  def pbUpdate
    pbUpdateOldFL
    if Input.trigger?(Input::ACTION)
      if @page == 4
        @subPage-=1
        @subPage=@totalSubPages if @subPage<1
        displaySubPage
      end
    elsif Input.trigger?(Input::USE)
      if @page == 4 
        @subPage+=1
        @subPage=1 if @subPage>@totalSubPages
        displaySubPage
      end
    end
  end
  
  BASE_COLOR = Color.new(255,255,255)
  SHADOW_COLOR = Color.new(115,115,115)
  BASE_X = 30
  EXTRA_X = 224
  BASE_Y = 56
  EXTRA_Y = 32

  class PageGroup
    attr_accessor :label
    attr_accessor :pages
    attr_accessor :array
    attr_accessor :isMove

    def self.newInfoGroup(array)
      ret = self.new
      ret.array=array
      ret.setupInfoPageSize
      ret.isMove = false
      return ret
    end

    def self.newMoveGroup(label, moveArray)
      ret = self.new
      ret.label=label
      ret.array=moveArray
      ret.pages = 1+(moveArray.size-1)/10
      ret.isMove = true
      return ret
    end

    def setupInfoPageSize
      @pages = 0
      for i in 0...@array.size
        j = @array.size-i-1
        next if @array[j].empty?
        @pages = 1+j/2
        break
      end
    end
  end
  
  def drawPageAdvanced
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_advanced"))
    @sprites["infoverlay"].setBitmap(_INTL("Graphics/Pictures/Pokedex/advanced_overlay"))
    @totalSubPages=0
    @data = GameData::Species.get_species_form(@species, @form)
    if $Trainer.owned?(@species)
      @groupArray = []
      @groupArray.push(PageGroup.newInfoGroup(getInfo))
      @groupArray.push(PageGroup.newMoveGroup(_INTL("LEVEL UP MOVES:"), getLevelMoves))
      @groupArray.push(PageGroup.newMoveGroup(_INTL("EGG MOVES:"), getEggMoves))
      if SHOW_MACHINE_TUTOR_MOVES
        machineMoves = getMachineMoves
        @groupArray.push(PageGroup.newMoveGroup(_INTL("TM MOVES:"), machineMoves[0]))
        @groupArray.push(PageGroup.newMoveGroup(_INTL("TR MOVES:"), machineMoves[1]))
        @groupArray.push(PageGroup.newMoveGroup(_INTL("HM MOVES:"), machineMoves[2]))
        @groupArray.push(PageGroup.newMoveGroup(_INTL("TUTOR MOVES:"), machineMoves[3]))
      end
      @totalSubPages = @groupArray.sum{|group| group.pages}
      @subPage= [@totalSubPages, @subPage].min
    end
    displaySubPage
  end
  
  def displaySubPage
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    line2Y =Graphics.height-94
    
    # Bottom text  
    textpos = [[@data.name,Graphics.width/2-76-16,line2Y,2,BASE_COLOR,SHADOW_COLOR]]
    if $Trainer.owned?(@species)
      textpos.push([
        _INTL("{1}/{2}",@subPage,@totalSubPages),Graphics.width-44,line2Y,1,BASE_COLOR,SHADOW_COLOR])
    end
    pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)
    
    # Type icon
    type1rect = Rect.new(0,GameData::Type.get(@data.type1).id_number*32,96,32)
    type2rect = Rect.new(0,GameData::Type.get(@data.type2).id_number*32,96,32)
    typeBaseX = (Graphics.width-type1rect.width)/2 + 76-16
    if(@data.type1==@data.type2)
      overlay.blt(typeBaseX,line2Y+6,@typebitmap.bitmap,type1rect)
    else
      overlay.blt(typeBaseX-34,line2Y+6,@typebitmap.bitmap,type1rect)
      overlay.blt(typeBaseX+34,line2Y+6,@typebitmap.bitmap,type2rect)
    end
    
    return if !$Trainer.owned?(@species)

    # Page content
    turnedPages=0
    for group in @groupArray
      if @subPage<=group.pages+turnedPages
        if group.isMove
          displaySubPageMoves(group, @subPage-turnedPages)
        else
          displaySubPageInfo(group, @subPage-turnedPages)
        end
        break
      end
      turnedPages+=group.pages
    end
    
    pbDrawTextPositions(@sprites["overlay"].bitmap, 
      [[_INTL("Advanced"),58,0,0,BASE_COLOR,SHADOW_COLOR]])
  end
  
  def displaySubPageInfo(group, subPage)
    textpos = []
    for i in (12*(subPage-1))...(12*subPage)
      line = i%6
      column = i/6
      next if !group.array[column][line]
      x = BASE_X+EXTRA_X*(column%2)
      y = BASE_Y+EXTRA_Y*line
      textpos.push([group.array[column][line],x,y,false,BASE_COLOR,SHADOW_COLOR])
    end
    pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)
  end  
    
  def displaySubPageMoves(group,subPage)
    textpos = [[group.label,BASE_X,BASE_Y,false,BASE_COLOR,SHADOW_COLOR]]
      for i in (10*(subPage-1))...(10*subPage)
      break if i>=group.array.size
      line = i%5
      column = i/5
      x = BASE_X+EXTRA_X*(column%2)
      y = BASE_Y+EXTRA_Y*(line+1)
      textpos.push([group.array[i],x,y,false,BASE_COLOR,SHADOW_COLOR])
    end
    pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
  end  
  
  def getInfo
    # ret works like a table with two columns per page
    ret = Array.new(2*4){ [] }
    # Base Stats
    ret[0][0]=_ISPRINTF("                             HP ATK DEF SPD SAT SDF TOT")
    ret[0][1]=_ISPRINTF(
        "BASE STATS:       {1:03d} {2:03d} {3:03d} {4:03d} {5:03d} {6:03d} {7:03d}",
        @data.base_stats[:HP],@data.base_stats[:ATTACK],@data.base_stats[:DEFENSE],
        @data.base_stats[:SPEED],@data.base_stats[:SPECIAL_ATTACK],
        @data.base_stats[:SPECIAL_DEFENSE],@data.base_stats.values.sum)
    # Effort Points
    ret[0][2]=_ISPRINTF(
        "EFFORT POINTS: {1:03d} {2:03d} {3:03d} {4:03d} {5:03d} {6:03d} {7:03d}",
        @data.evs[:HP],@data.evs[:ATTACK],@data.evs[:DEFENSE],
        @data.evs[:SPEED],@data.evs[:SPECIAL_ATTACK],
        @data.evs[:SPECIAL_DEFENSE],@data.evs.values.sum)
    # Abilities
    if @data.abilities.size<2
      abilityString = GameData::Ability.get(@data.abilities[0]).name
    else
      abilityString = _INTL("{1}, {2}", 
        GameData::Ability.get(@data.abilities[0]).name,
        GameData::Ability.get(@data.abilities[1]).name)
    end
    ret[0][3]=_INTL("ABILITIES: {1}",abilityString)
    # Hidden Abilities
    hiddenAbilityFirstString = case @data.hidden_abilities.size
      when 0
        _INTL("None")
      when 1
        GameData::Ability.get(@data.hidden_abilities[0]).name
      else
        _INTL("{1}, {2}",
          GameData::Ability.get(@data.hidden_abilities[0]).name,
          GameData::Ability.get(@data.hidden_abilities[1]).name)
    end
    ret[0][4]=_INTL("HIDDEN ABILITIES: {1}", hiddenAbilityFirstString)
    if @data.hidden_abilities.size == 3
      ret[0][5] = GameData::Ability.get(@data.hidden_abilities[2]).name
    elsif @data.hidden_abilities.size > 3
      ret[0][5] = _INTL("{1}, {2}",
        GameData::Ability.get(@data.hidden_abilities[2]).name,
        GameData::Ability.get(@data.hidden_abilities[3]).name)
    end
    # Base Exp
    ret[2][0]=_INTL("BASE EXP: {1}",@data.base_exp)
    # Catch Rate
    ret[2][1]=_INTL("CATCH RATE: {1}",@data.catch_rate)
    # Growth Rate
    growthRate = GameData::GrowthRate.get(@data.growth_rate)
    ret[2][2]=_INTL("GROWTH RATE: {1} ({2})",growthRate.name,growthRate.maximum_exp)
    # Gender Rate
    genderRatio = GameData::GenderRatio.get(@data.gender_ratio)
    if genderRatio.female_chance
      genderString = _INTL("Male {1}%",100-100*genderRatio.female_chance/256)
    else
      genderString = genderRatio.name
    end
    ret[2][3]= _INTL("GENDER RATE: {1}", genderString)
    # Egg Steps to Hatch
    ret[2][4]=_INTL("STEPS TO HATCH EGG: {1} ({2} cycles)",@data.hatch_steps,@data.hatch_steps/255)
    # Breed Group
    if @data.egg_groups.size==1
      eggGroups = GameData::EggGroup.get(@data.egg_groups[0]).name
    else
      eggGroups = _INTL("{1}, {2}",
        GameData::EggGroup.get(@data.egg_groups[0]).name,
        GameData::EggGroup.get(@data.egg_groups[1]).name)
    end
    ret[2][5]=_INTL("BREED GROUP: {1}",eggGroups)
    # Generation
    ret[4][0]=_INTL("GENERATION: {1}",@data.generation) 
    # Happiness base
    ret[4][1]=_INTL("HAPPINESS BASE: {1}",@data.happiness)
    # Color
    ret[4][2]=_INTL("COLOR: {1}",GameData::BodyColor.get(@data.color).name) 
    # Shape
    ret[4][3]=_INTL("SHAPE: {1}",GameData::BodyShape.get(@data.shape).name) 
    # Habitat
    if @data.habitat!=:None
      ret[4][4]=_INTL("HABITAT: {1}",GameData::Habitat.get(@data.habitat).name) 
    end
    # Wild hold item 
    holdItemsStrings=[]
    hasAlwaysHoldItem = (@data.wild_item_common && 
      @data.wild_item_common==@data.wild_item_uncommon && 
      @data.wild_item_common == @data.wild_item_rare)
    if hasAlwaysHoldItem
      holdItemsStrings.push(_INTL("{1} (always)",GameData::Item.get(@data.wild_item_common).name))
    else
      holdItemsStrings.push(_INTL("{1} (common)", GameData::Item.get(
        @data.wild_item_common).name)) if @data.wild_item_common
      holdItemsStrings.push(_INTL("{1} (uncommon)", GameData::Item.get(
        @data.wild_item_uncommon).name)) if @data.wild_item_uncommon
      holdItemsStrings.push(_INTL("{1} (rare)", GameData::Item.get(
        @data.wild_item_rare).name)) if @data.wild_item_rare
    end
    ret[6][0] = _INTL("WILD ITEMS: {1}",holdItemsStrings.empty? ? _INTL("None") : holdItemsStrings[0])
    ret[6][1] = holdItemsStrings[1] if holdItemsStrings.size>1
    ret[6][2] = holdItemsStrings[2] if holdItemsStrings.size>2
    # Evolutions
    evolutionsStrings = []
    lastEvolutionSpecies = nil
    for evoData in @data.get_evolutions
      # The below "if" it's to won't list the same evolution species more than
      # one time. Only the last is displayed.
      evolutionsStrings.pop if lastEvolutionSpecies==evoData[0]
      evolutionsStrings.push(getEvolutionMessage(evoData[0], evoData[1], evoData[2]))
      lastEvolutionSpecies=evoData[0]
    end
    line=3
    column=6
    ret[column][line] = _INTL("EVO: {1}",evolutionsStrings.empty? ? _INTL("None") : evolutionsStrings[0])
    evolutionsStrings.shift
    line+=1
    for string in evolutionsStrings
      if line>5  # For when the pokémon has more than 3 evolutions (AKA Eevee) 
        line=0
        column+=2
        ret += Array.new(2){ [] }
      end
      ret[column][line] = string
      line+=1
    end
    # Incenses
    babySpecies=@data.get_baby_species
    if babySpecies!=@data.id
      babyData = GameData::Species.get(babySpecies)
      if babyData.incense
        ret[6][5]=_INTL("Generates {1} holding {2}",babyData.name,GameData::Item.get(babyData.incense).name)
      end 
    end
    return ret
  end
    
  # Gets the evolution array and return evolution message
  def getEvolutionMessage(evolution, method, parameter)
    evoName = GameData::Species.get(evolution).name
    ret = case method
      when :Level
        _INTL("{1} at level {2}", evoName,parameter)
      when :LevelMale
        _INTL("{1} at level {2} and it's male", evoName,parameter)
      when :LevelFemale
        _INTL("{1} at level {2} and it's female", evoName,parameter)
      when :LevelRain
        _INTL("{1} at level {2} when raining", evoName,parameter)
      when :DefenseGreater
        _INTL("{1} at level {2} and ATK > DEF",evoName,parameter)
      when :AtkDefEqual
        _INTL("{1} at level {2} and ATK = DEF",evoName,parameter) 
      when :AttackGreater
        _INTL("{1} at level {2} and DEF < ATK",evoName,parameter)
      when :Silcoon,:Cascoon
        _INTL("{1} at level {2} with personalID", evoName,parameter)
      when :Ninjask
        _INTL("{1} at level {2}",evoName,parameter)
      when :Shedinja
        _INTL("{1} at level {2} with empty space",evoName,parameter)
      when :Happiness
        _INTL("{1} when happy",evoName)
      when :HappinessDay
        _INTL("{1} when happy at day",evoName)
      when :HappinessNight
        _INTL("{1} when happy at night",evoName)
      when :Beauty
        _INTL("{1} when beauty is greater than {2}",evoName,parameter) 
      when :DayHoldItem
        _INTL("{1} holding {2} at day",evoName,GameData::Item.get(parameter).name)
      when :NightHoldItem
        _INTL("{1} holding {2} at night",evoName,GameData::Item.get(parameter).name)
      when :HasMove
        _INTL("{1} when has move {2}",evoName,GameData::Move.get(parameter).name)
      when :HappinessMoveType
        _INTL("{1} when is happy with {2} move",evoName,GameData::Type.get(parameter).name)
      when :HasInParty
        _INTL("{1} when has {2} at party",evoName,GameData::Species.get(parameter).name)
      when :Location
        _INTL("{1} at {2}",evoName, pbGetMapNameFromId(parameter))
      when :Item
        _INTL("{1} using {2}",evoName,GameData::Item.get(parameter).name)
      when :ItemMale
        _INTL("{1} using {2} and it's male",evoName,GameData::Item.get(parameter).name)
      when :ItemFemale
        _INTL("{1} using {2} and it's female",evoName,GameData::Item.get(parameter).name)
      when :Trade
        _INTL("{1} trading",evoName)
      when :TradeItem
        _INTL("{1} trading holding {2}",evoName,GameData::Item.get(parameter).name)
      when :TradeSpecies
        _INTL("{1} trading by {2}",evoName,GameData::Species.get(parameter).name)
      else
        evoName
    end
    return ret    
  end 
  
  def getLevelMoves
    return @data.moves.map{|moveData|
      _ISPRINTF("{1:02d} {2:s}",moveData[0],GameData::Move.get(moveData[1]).name)
    }
  end 

  def getEggMoves
    eggMoveSpecies = EGG_MOVES_FIRST_STAGE ? @data.get_baby_species : @data.id
    return GameData::Species.get(eggMoveSpecies).egg_moves.map{|move|
      GameData::Move.get(move).name
    }.sort
  end 

  # Return a nested array with TMs, TRs, HMs and other tutors
  def getMachineMoves
    movesArray=@data.tutor_moves.dup
    tmArray = []
    trArray = []
    hmArray = []
    tutorArray = []
    if !SHOW_ALL_MACHINE_TUTOR_TOGETHER
      GameData::Item.each do |item|
        next if !item.is_machine? || !movesArray.include?(item.move)
        if MACHINE_DIGITS>0
          machineLabel = item.name[2,item.name.size].to_i
          machineLabel = "%0#{MACHINE_DIGITS}d" % (machineLabel % 10**MACHINE_DIGITS)
          moveLabel = _INTL("{1} {2}",machineLabel,GameData::Move.get(item.move).name)
        else
          moveLabel = GameData::Move.get(item.move).name
        end
        movesArray.delete(item.move)
        if item.is_HM?
          hmArray.push(moveLabel)
        elsif item.is_TR?
          trArray.push(moveLabel)
        else
          tmArray.push(moveLabel)
        end
      end
    end
    if SHOW_TUTOR_MOVES
      tutorArray = movesArray.map{|move| GameData::Move.get(move).name}
    end
    return [tmArray.sort, trArray.sort, hmArray.sort, tutorArray.sort]
  end  
end