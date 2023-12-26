#===============================================================================
# * Advanced Pokédex - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. When a switch is ON, it displays at 
# pokédex the pokémon PBS data for a caught pokémon like: base exp, egg steps
# to hatch, abilities, wild hold item, evolution, the moves that pokémon can 
# learn by level/breeding/TM/TR/HM/tutors, among others.
#
#== INSTALLATION ===============================================================
#
# Put it above main, put a 512x384 background named  "advancedPokedex" for this 
# screen in "Graphics/Pictures/Pokedex/". At same folder, put three 512x32 
# images for the top pokédex selection named "advancedInfoBar",
# "advancedAreaBar" and "advancedFormsBar".
#
# In UI_Pokedex_Entry script section, change both lines (use Ctrl+F to find
# it) '@page = 3 if @page > 3' into '@page=@maxPage if @page>@maxPage'.
#
#===============================================================================

if !PluginManager.installed?("Advanced Pokédex")
  PluginManager.register({                                                 
    :name    => "Advanced Pokédex",                                        
    :version => "1.3.4",                                                     
    :link    => "https://www.pokecommunity.com/showthread.php?t=315535",             
    :credits => "FL"
  })
end

class PokemonPokedexInfo_Scene  
  
  #SOME OF THE CODE IN HERE HAS BEEN ADDED TO ARCKY'S REGION MAP FOR COMPATIBILITY
  
  # Switch number that toggle this script ON/OFF
  SWITCH=70
  
  # When true displays TMs/TRs/HMs/Tutors moves
  SHOW_MACHINE_TUTOR_MOVES = true
  
  # When false doesn't displays machine moves that aren't in any TM/TR/HM item
  SHOW_TUTOR_MOVES = true

  # When true displays TMs/TRs/HMs/Tutors without their subdivisions
  SHOW_ALL_MACHINE_TUTOR_TOGETHER = false
  
  # TMs/TRs/HMs digits to show on list. When 0, doesn't show number
  MACHINE_DIGITS = 3
  
  # Name of TM/TR usable only once
  TR_NAME = "TM"
  
  # When true always shows the egg moves of the first evolution stage
  EGG_MOVES_FIRST_STAGE = true

  # The Advanced Pokédex page number. You need to edit it (and barBitmapPath) if
  # you added more pages to the pokédex. Don't decrease it.
  ADVANCED_PAGE = 4

  # Returns a bar index with ADV label for each page index.
  def barBitmapPath
    return [
      nil,
      _INTL("Graphics/Pictures/Pokedex/advancedInfoBar"),
      _INTL("Graphics/Pictures/Pokedex/advancedAreaBar"),
      _INTL("Graphics/Pictures/Pokedex/advancedFormsBar")
    ]
  end
  
  alias :pbStartSceneOldFL :pbStartScene
  def pbStartScene(dexlist,index,region)
    #@maxPage = $game_switches[SWITCH] ? ADVANCED_PAGE : ADVANCED_PAGE-1
    @maxPage = ADVANCED_PAGE
    @subPage=1
    pbStartSceneOldFL(dexlist,index,region)
    @sprites["advancedicon"]=PokemonSpeciesIconSprite.new(nil,@viewport)
    @sprites["advancedicon"].setOffset(PictureOrigin::CENTER)
    @sprites["advancedicon"].x = 82
    @sprites["advancedicon"].y = 328
    @sprites["advancedicon"].visible = false
    
    #added by Gardenette
    $tips_log.tipAdvancedDex if !$tips_log.get_log.include?("Advanced Dex")
    
  end
  
  alias :drawPageOldFL :drawPage
  def drawPage(page)
    drawPageOldFL(page)
    return if @brief
    #dexbarVisible = $game_switches[SWITCH] && @page<ADVANCED_PAGE
    dexbarVisible = @page<ADVANCED_PAGE
    @sprites["dexbar"] = IconSprite.new(0,0,@viewport) if !@sprites["dexbar"]
    @sprites["dexbar"].visible = dexbarVisible
    @sprites["dexbar"].setBitmap(barBitmapPath[@page]) if dexbarVisible
    if @sprites["advancedicon"]
      @sprites["advancedicon"].visible = page==ADVANCED_PAGE
    end
    if @sprites["advancedicon"] && @sprites["advancedicon"].visible
      @sprites["advancedicon"].pbSetParams(@species,@gender,@form)
    end
    drawPageAdvanced if page==ADVANCED_PAGE
  end

  alias :pbUpdateOldFL :pbUpdate
  def pbUpdate
    pbUpdateOldFL
    if Input.trigger?(Input::ACTION)
      if @page == ADVANCED_PAGE
        @subPage-=1
        @subPage=@totalSubPages if @subPage<1
        displaySubPage
			elsif @page == 2 #area #by low
				pbSpeciesTypeMatchUI
      end
    elsif Input.trigger?(Input::USE)
      if @page == ADVANCED_PAGE
        @subPage+=1
        @subPage=1 if @subPage>@totalSubPages
        displaySubPage
      end
    elsif Input.trigger?(Input::SPECIAL)
      if @page == ADVANCED_PAGE && @subPage == 4
        if @revealEvo == false || @revealEvo == nil
          @revealEvo = true 
        else
          @revealEvo = false
        end
        drawPageAdvanced
      end
    end
  end
  
  BASE_COLOR = Color.new(88,88,80)
  SHADOW_COLOR = Color.new(168,184,184)
  BASE_X = 30
  EXTRA_X = 224
  BASE_Y = 66
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
    @sprites["background"].setBitmap(
      _INTL("Graphics/Pictures/Pokedex/advancedPokedex")
    )
    @totalSubPages=0
    @data = GameData::Species.get_species_form(@species, @form)
    if $player.owned?(@species)
      @groupArray = []
      @groupArray.push(PageGroup.newInfoGroup(getInfo))
      @groupArray.push(PageGroup.newMoveGroup(
        _INTL("LEVEL UP MOVES:"), getLevelMoves
      ))
      @groupArray.push(PageGroup.newMoveGroup(_INTL("EGG MOVES:"), getEggMoves))
      if SHOW_MACHINE_TUTOR_MOVES
        machineMoves = getMachineMoves
        @groupArray.push(PageGroup.newMoveGroup(
          _INTL("TM MOVES:"), machineMoves[0])
        )
        @groupArray.push(PageGroup.newMoveGroup(
          _INTL("#{TR_NAME} MOVES:"), machineMoves[1])
        )
        @groupArray.push(PageGroup.newMoveGroup(
          _INTL("HM MOVES:"), machineMoves[2])
        )
        @groupArray.push(PageGroup.newMoveGroup(
          _INTL("TUTOR MOVES:"), machineMoves[3])
        )
      end
      @totalSubPages = @groupArray.sum{|group| group.pages}
      @subPage= [@totalSubPages, @subPage].min
    end
    displaySubPage
  end
  
  def displaySubPage
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    line2Y = Graphics.height-54
    
    # Bottom text  
    textpos = [[
      @data.name,Graphics.width/2,Graphics.height-82,2,BASE_COLOR,SHADOW_COLOR
    ]]
    if $player.owned?(@species)
      textpos.push([
        #_INTL("{1}/{2}",@subPage,@totalSubPages),
        #edited by Gardenette
        _INTL("Page: {1}/{2}",@subPage,@totalSubPages),
        Graphics.width-52,Graphics.height-52,1,BASE_COLOR,SHADOW_COLOR
      ])
      #added by Gardenette
      #display "CONFIRM: Next Page"
      textpos.push([
        _INTL("{1}: Next",$PokemonSystem.game_controls.find{|c| c.control_action=="Action"}.key_name),
        Graphics.width-52,Graphics.height-88,1,BASE_COLOR,SHADOW_COLOR
      ])
      
    end
    pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)

    # Type icon
		#adv pokedex #triple type UI #by low
    type1rect = Rect.new(
      0,GameData::Type.get(@data.types[0]).icon_position*32,96,32
    )
    type2rect = @data.types.size==2 ? Rect.new(
      0,GameData::Type.get(@data.types[1]).icon_position*32,96,32
    ) : nil 
    typeBaseX = (Graphics.width-type1rect.width)/2
		if @data.types.size>2
			type2rect = Rect.new(
				0,GameData::Type.get(@data.types[1]).icon_position*32,96,32
			)
			type3rect = Rect.new(
				0,GameData::Type.get(@data.types[2]).icon_position*32,96,32
			)
		else
			type3rect = nil
		end
    typeBaseX = (Graphics.width-type1rect.width)/2
		if type3rect
      overlay.blt(typeBaseX-54,line2Y-10,@typebitmap.bitmap,type1rect)
      overlay.blt(typeBaseX+54,line2Y-10,@typebitmap.bitmap,type2rect)
      overlay.blt(typeBaseX,line2Y+10,@typebitmap.bitmap,type3rect)
    elsif type2rect
      overlay.blt(typeBaseX-54,line2Y,@typebitmap.bitmap,type1rect)
      overlay.blt(typeBaseX+54,line2Y,@typebitmap.bitmap,type2rect)
    else
      overlay.blt(typeBaseX,line2Y,@typebitmap.bitmap,type1rect)
    end
    
    return if !$player.owned?(@species)

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
  end
  
  def displaySubPageInfo(group, subPage)
    textpos = []
    for i in (12*(subPage-1))...(12*subPage)
      line = i%6
      column = i/6
      next if !group.array[column][line]
      x = BASE_X+EXTRA_X*(column%2)
      y = BASE_Y+EXTRA_Y*line
      textpos.push([
        group.array[column][line],x,y,false,BASE_COLOR,SHADOW_COLOR
      ])
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
    ret[0][0]=_ISPRINTF(
      "                             HP ATK DEF SPD SPA SDF TOT"
    )
    ret[0][1]=_ISPRINTF(
      "BASE STATS:       {1:03d} {2:03d} {3:03d} {4:03d} {5:03d} {6:03d} {7:03d}",
      @data.base_stats[:HP],@data.base_stats[:ATTACK],@data.base_stats[:DEFENSE],
      @data.base_stats[:SPEED],@data.base_stats[:SPECIAL_ATTACK],
      @data.base_stats[:SPECIAL_DEFENSE],@data.base_stats.values.sum
    )
    # Effort Points
    ret[0][2]=_ISPRINTF(
      "EFFORT VALUES: {1:03d} {2:03d} {3:03d} {4:03d} {5:03d} {6:03d} {7:03d}",
      @data.evs[:HP],@data.evs[:ATTACK],@data.evs[:DEFENSE],
      @data.evs[:SPEED],@data.evs[:SPECIAL_ATTACK],
      @data.evs[:SPECIAL_DEFENSE],@data.evs.values.sum
    )
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
    ret[2][2]=_INTL(
      "GROWTH RATE: {1} ({2})",growthRate.name,growthRate.maximum_exp
    )
    # Gender Rate
    genderRatio = GameData::GenderRatio.get(@data.gender_ratio)
    if genderRatio.female_chance
      genderString = _INTL("Male {1}%",100-100*genderRatio.female_chance/256)
    else
      genderString = genderRatio.name
    end
    #Commented out by Gardenette
    #ret[2][3]= _INTL("GENDER RATE: {1}", genderString)
    # Egg Steps to Hatch
    ret[2][4]= _INTL(
      "STEPS TO HATCH EGG: {1} ({2} cycles)",
      @data.hatch_steps,@data.hatch_steps/255
    )
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
    #Commented out by Gardenette
    #ret[4][0]=_INTL("GENERATION: {1}",@data.generation) 
    # Happiness base
    #Commented out by Gardenette
    #ret[4][1]=_INTL("HAPPINESS BASE: {1}",@data.happiness)
    # Color
    #Commented out by Gardenette
    #ret[4][2]=_INTL("COLOR: {1}",GameData::BodyColor.get(@data.color).name) 
    # Shape
    #Commented out by Gardenette
    #ret[4][3]=_INTL("SHAPE: {1}",GameData::BodyShape.get(@data.shape).name) 
    # Habitat
    #Commented out by Gardenette
    #if @data.habitat!=:None
    #  ret[4][4]=_INTL("HABITAT: {1}",GameData::Habitat.get(@data.habitat).name) 
    #end
    # Wild hold item 
    holdItemsStrings=[]
    hasAlwaysHoldItem = (
      @data.wild_item_common[0] &&
      @data.wild_item_common[0] == @data.wild_item_uncommon[0] && 
      @data.wild_item_common[0] == @data.wild_item_rare[0]
    )
    if hasAlwaysHoldItem
      holdItemsStrings.push(
        _INTL("{1} (always)",GameData::Item.get(@data.wild_item_common[0]).name)
      )
    else
      holdItemsStrings.push(_INTL("{1} (common)", GameData::Item.get(
        @data.wild_item_common[0]
      ).name)) if @data.wild_item_common[0]
      holdItemsStrings.push(_INTL("{1} (uncommon)", GameData::Item.get(
        @data.wild_item_uncommon[0]
      ).name)) if @data.wild_item_uncommon[0]
      holdItemsStrings.push(_INTL("{1} (rare)", GameData::Item.get(
        @data.wild_item_rare[0]
      ).name)) if @data.wild_item_rare[0]
    end
    ret[6][0] = _INTL(
      "WILD ITEMS: {1}",
      holdItemsStrings.empty? ? _INTL("None") : holdItemsStrings[0]
    )
    ret[6][1] = holdItemsStrings[1] if holdItemsStrings.size>1
    ret[6][2] = holdItemsStrings[2] if holdItemsStrings.size>2
    # Evolutions
    evolutionsStrings = []
    lastEvolutionSpecies = nil
    for evoData in @data.get_evolutions
      # The below "if" it's to won't list the same evolution species more than
      # one time. Only the last is displayed.
      evolutionsStrings.pop if lastEvolutionSpecies==evoData[0]
      evolutionsStrings.push(getEvolutionMessage(
        evoData[0], evoData[1], evoData[2])
      )
      lastEvolutionSpecies=evoData[0]
    end
    line=3
    column=6
    
    #edited by Gardenette to hide evo method unless player wants to see it
    if @revealEvo
      ret[column][line] = _INTL(
      "EVO: {1}",
      evolutionsStrings.empty? ? _INTL("None") : evolutionsStrings[0]
      )
    else
      ret[column][line] = _INTL("EVO: {1} to Reveal/Hide",$PokemonSystem.game_controls.find{|c| c.control_action=="Registered Item"}.key_name)
    end
    
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
        ret[6][5]=_INTL(
          "Generates {1} holding {2}",
          babyData.name,GameData::Item.get(babyData.incense).name
        )
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
			# edits #by low
			when :None
				_INTL("None")
      when :LevelDay
        _INTL("{1} at level {2} at day", evoName,parameter)
      when :LevelNight
        _INTL("{1} at level {2} at night", evoName,parameter)
      when :HappinessLevel
        _INTL("{1} at level {2} and when happy", evoName,parameter)
      when :Level30HasTypeMove
        _INTL("{1} at level 30 with {2} move",evoName,GameData::Type.get(parameter).name)
      else
        evoName
    end
    return ret
  end 
  
  def getLevelMoves
    return @data.moves.map{|moveData|
      _ISPRINTF(
        "{1:02d} {2:s}",moveData[0],GameData::Move.get(moveData[1]).name
      )
    }
  end 

  def getEggMoves
    if EGG_MOVES_FIRST_STAGE
      eggMoveSpecies = GameData::Species.get_species_form(
        @data.get_baby_species, @form
      )
    else
      eggMoveSpecies = @data.id
    end
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
          machineLabel = "%0#{MACHINE_DIGITS}d" % (
            machineLabel % 10**MACHINE_DIGITS
          )
          moveLabel = _INTL(
            "{1} {2}",machineLabel,GameData::Move.get(item.move).name
          )
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