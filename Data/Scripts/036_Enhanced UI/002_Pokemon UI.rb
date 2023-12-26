#===============================================================================
# Party Ball
#===============================================================================
if Settings::SHOW_PARTY_BALL
  class PokemonPartyPanel < SpriteWrapper
    alias enhanced_initialize initialize
    def initialize(*args)
      enhanced_initialize(*args)
      GameData::Item.each do |ball|
        next if !ball.is_poke_ball?
        sprite = "Graphics/Plugins/Enhanced UI/Party Ball/#{ball.id}"
        @ballsprite.addBitmap("#{ball.id}_desel", sprite)
        @ballsprite.addBitmap("#{ball.id}_sel", sprite + "_sel")
      end
      refresh
    end
	
    alias enhanced_refresh_ball_graphic refresh_ball_graphic
    def refresh_ball_graphic
      enhanced_refresh_ball_graphic
      if @ballsprite && !@ballsprite.disposed?
        ball = @pokemon.poke_ball
        path = "Graphics/Plugins/Enhanced UI/Party Ball/#{ball}"
        ball_sel   = pbResolveBitmap(path + "_sel") ? "#{ball}_sel"   : "sel"
        ball_desel = pbResolveBitmap(path)          ? "#{ball}_desel" : "desel"
        @ballsprite.changeBitmap((self.selected) ? ball_sel : ball_desel)
      end
    end
  end
end


#===============================================================================
# Shiny Leaf
#===============================================================================
if Settings::SUMMARY_SHINY_LEAF
  class PokemonSummary_Scene
    alias enhanced_drawPage drawPage
    def drawPage(page)
      enhanced_drawPage(page)
      overlay = @sprites["overlay"].bitmap
      coords = (PluginManager.installed?("BW Summary Screen")) ? [Graphics.width - 18, 114] : [182, 124]
      pbDisplayShinyLeaf(@pokemon, overlay, coords[0], coords[1])
    end
  end
end

#-------------------------------------------------------------------------------
# Adds Shiny Leaf to Pokemon data.
#-------------------------------------------------------------------------------
class Pokemon
  def shiny_leaf;   return @shiny_leaf || 0; end
  def shiny_crown?; return @shiny_leaf == 6; end
    
  def shiny_leaf?
    return false if @shiny_leaf.nil?
    return @shiny_leaf > 0
  end
  
  def shiny_leaf=(value)
    value = (value < 0) ? 0 : (value > 6) ? 6 : value
    @shiny_leaf = (value)
  end
  
  alias enhanced_initialize initialize  
  def initialize(*args)
    @shiny_leaf = 0
    enhanced_initialize(*args)
  end
end

#-------------------------------------------------------------------------------
# Displays a Pokemon's collected Shiny Leaves on an inputted overlay bitmap.
#-------------------------------------------------------------------------------
# If "vertical" is set to true, Shiny Leaves will be displayed in a vertically
# stacked layout. Otherwise, Shiny Leaves will be displayed horizontally. This
# has no effect on how the Shiny Leaf Crown is displayed.
#-------------------------------------------------------------------------------
def pbDisplayShinyLeaf(pokemon, overlay, xpos, ypos, vertical = false)
  imagepos = []
  path = "Graphics/Plugins/Enhanced UI/shiny_"
  if pokemon.shiny_crown?
    imagepos.push([sprintf(path + "crown"), xpos - 18, ypos - 3])
  elsif pokemon.shiny_leaf?
    offset_x = (vertical) ? 0  : 10
    offset_y = (vertical) ? 10 : 0
    pokemon.shiny_leaf.times do |i|
      imagepos.push([sprintf(path + "leaf"), xpos - (i * offset_x), ypos + (i * offset_y)])
    end
  end  
  pbDrawImagePositions(overlay, imagepos)
end

#-------------------------------------------------------------------------------
# Adds Shiny Leaf debug tools to the "cosmetic" section in a Pokemon's debug options.
#-------------------------------------------------------------------------------
MenuHandlers.add(:pokemon_debug_menu, :set_shiny_leaf, {
  "name"   => _INTL("Shiny Leaf"),
  "parent" => :dx_pokemon_menu,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    cmd = 0
    loop do
      msg = [_INTL("Has shiny crown."), _INTL("Has shiny leaf x#{pkmn.shiny_leaf}.")][pkmn.shiny_crown? ? 0 : 1]
      cmd = screen.pbShowCommands(msg, [
           _INTL("Set leaf count"),
           _INTL("Set crown"),
           _INTL("Reset")], cmd)
      break if cmd < 0
      case cmd
      when 0   # Set Leaf
        params = ChooseNumberParams.new
        params.setRange(0, 6)
        params.setDefaultValue(pkmn.shiny_leaf)
        leafcount = pbMessageChooseNumber(
          _INTL("Set {1}'s leaf count (max. 6).", pkmn.name), params) { screen.pbUpdate }
        pkmn.shiny_leaf = leafcount
      when 1   # Set Crown
        pkmn.shiny_leaf = 6
      when 2   # Reset
        pkmn.shiny_leaf = 0
      end
      screen.pbRefreshSingle(pkmnid)
    end
    next false
  }
})


#===============================================================================
# IV Star Ratings
#===============================================================================
if Settings::SUMMARY_IV_RATINGS
  class PokemonSummary_Scene
    alias enhanced_drawPageThree drawPageThree
    def drawPageThree
      enhanced_drawPageThree
      overlay = @sprites["overlay"].bitmap
      coords = (PluginManager.installed?("BW Summary Screen")) ? [110, 82] : [465, 82]
      pbDisplayIVRating(@pokemon, overlay, coords[0], coords[1])
    end
	
    def pbDisplayIVRating(*args)
      return if args.length == 0
      pbDisplayIVRatings(*args)
    end
  end
end

#-------------------------------------------------------------------------------
# Displays star ratings for a Pokemon's IV's on an inputted overlay bitmap.
#-------------------------------------------------------------------------------
# If "horizontal" is set to true, IV stars will be displayed in a horizontal
# layout, side by side. Otherwise, IV stars will be displayed vertically and
# spaced out in a way to account for the stat display in the Summary.
#-------------------------------------------------------------------------------
def pbDisplayIVRatings(pokemon, overlay, xpos, ypos, horizontal = false)
  imagepos = []
  path  = "Graphics/Plugins/Enhanced UI/"
  case Settings::IV_DISPLAY_STYLE
  when 0 then path += "iv_stars"
  when 1 then path += "iv_letters"
  end
  maxIV = Pokemon::IV_STAT_LIMIT
  offset_x = (horizontal) ? 16 : 0
  offset_y = (horizontal) ? 0  : 32
  i = 0
  GameData::Stat.each_main do |s|
    stat = pokemon.iv[s.id]
    case stat
    when maxIV     then icon = 5  # 31 IV
    when maxIV - 1 then icon = 4  # 30 IV
    when 0         then icon = 0  #  0 IV
    else
      if stat > (maxIV - (maxIV / 4).floor)
        icon = 3 # 25-29 IV
      elsif stat > (maxIV - (maxIV / 2).floor)
        icon = 2 # 16-24 IV
      else
        icon = 1 #  1-15 IV
      end
    end
    imagepos.push([path, xpos + (i * offset_x), ypos + (i * offset_y), icon * 16, 0, 16, 16])
    if s.id == :HP && !horizontal
      ypos += (PluginManager.installed?("BW Summary Screen")) ? 18 : 12 
    end
    i += 1
  end
  pbDrawImagePositions(overlay, imagepos)
end


#===============================================================================
# Egg Groups
#===============================================================================
if Settings::SUMMARY_EGG_GROUPS
  class PokemonSummary_Scene
    alias enhanced_drawPageTwo drawPageTwo
    def drawPageTwo
      enhanced_drawPageTwo
      overlay = @sprites["overlay"].bitmap
      coords = (PluginManager.installed?("BW Summary Screen")) ? [162, 326] : [364, 338]
      vertical = (PluginManager.installed?("BW Summary Screen")) ? true : false
      pbDisplayEggGroups(@pokemon, overlay, coords[0], coords[1], "Egg Groups:", vertical)
    end
  end
end

if Settings::POKEDEX_EGG_GROUPS
  class PokemonPokedexInfo_Scene
    alias enhanced_drawPageInfo drawPageInfo
    def drawPageInfo
      enhanced_drawPageInfo
	  return if !$player.owned?(@species)
      overlay = @sprites["overlay"].bitmap
      species_data = GameData::Species.get_species_form(@species, @form)
      pbDisplayEggGroups(species_data, overlay, 148, 204, true)
    end
  end
end

#-------------------------------------------------------------------------------
# Displays a Pokemon's Egg Groups on an inputted overlay bitmap.
#-------------------------------------------------------------------------------
# "pokemon" can be set to either a Pokemon object, or a GameData::Species.
#
# If "showDisplay" is set as a string, that text will be displayed in front of the
# Egg Group icons. If "showDisplay" is set to true, it will instead add a background
# behind the Egg Group icons (used for the Pokedex). Otherwise, no additional
# displays will appear.
#
# If "vertical" is set to true, Egg Group icons will be displayed in a vertically
# stacked layout, if the Pokemon belongs to more than one Egg Group. Otherwise,
# Egg Groups will be displayed horizontally from each other.
#-------------------------------------------------------------------------------
def pbDisplayEggGroups(pokemon, overlay, xpos, ypos, showDisplay = nil, vertical = false)
  egg_groups = egg_group_hash
  if pokemon.is_a?(Pokemon)
    noeggs = pokemon.egg? || pokemon.shadowPokemon? || pokemon.celestial? || pokemon.hasAbility?(:BATTLEBOND)
	compat = (noeggs) ? [:Undiscovered] : pokemon.species_data.egg_groups 
  else
    compat = GameData::Species.get(pokemon).egg_groups
  end
  compat1 = compat[0]
  compat2 = compat[1] || compat[0]
  eggGroupbitmap = AnimatedBitmap.new(_INTL("Graphics/Plugins/Enhanced UI/egg_groups"))
  if pokemon.is_a?(Pokemon)
    isGenderless = (pokemon.genderless? && !pokemon.isSpecies?(:DITTO))
  else
    isGenderless = (GameData::Species.get(pokemon).gender_ratio == :Genderless && pokemon != :DITTO)
  end
  if showDisplay.is_a?(String)
    if egg_groups[compat1] > 14 || egg_groups[compat2] > 14
      base   = Color.new(250, 213, 165)
      shadow = Color.new(204, 85, 0)
    elsif PluginManager.installed?("BW Summary Screen")
	    base   = Color.new(255, 255, 255)
      shadow = Color.new(123, 123, 123)
    else
      base   = Color.new(64, 64, 64)
      shadow = Color.new(176, 176, 176)
    end
    textpos = [ [_INTL("#{showDisplay}"), xpos - 130, ypos + 2, 0, base, shadow] ]
    pbDrawTextPositions(overlay, textpos)
  elsif showDisplay
    imagepos = [ [sprintf("Graphics/Plugins/Enhanced UI/dex_bg"), xpos - 6, ypos - 14] ]
    pbDrawImagePositions(overlay, imagepos)
  end
  if isGenderless && !compat.include?(:Undiscovered)
    xpos += 34 if !vertical
    eggGroupRect = Rect.new(0, egg_groups[:Unknown] * 28, 64, 28)
    overlay.blt(xpos, ypos, eggGroupbitmap.bitmap, eggGroupRect)
  elsif compat1 == compat2
    xpos += 34 if !vertical
    eggGroupRect = Rect.new(0, egg_groups[compat1] * 28, 64, 28)
    overlay.blt(xpos, ypos, eggGroupbitmap.bitmap, eggGroupRect)
  else
    offset_x = (vertical) ? 0  : 68
    offset_y = (vertical) ? 28 : 0
    eggGroup1Rect = Rect.new(0, egg_groups[compat1] * 28, 64, 28)
    eggGroup2Rect = Rect.new(0, egg_groups[compat2] * 28, 64, 28)
    overlay.blt(xpos, ypos, eggGroupbitmap.bitmap, eggGroup1Rect)
    overlay.blt(xpos + offset_x, ypos + offset_y, eggGroupbitmap.bitmap, eggGroup2Rect)
  end
end