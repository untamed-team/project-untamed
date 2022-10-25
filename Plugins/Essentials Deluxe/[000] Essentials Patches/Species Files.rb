#===============================================================================
# Revamps all base Essentials code related to obtaining Pokemon sprite or audio
# files, to allow for plugin compatibility.
#===============================================================================


#-------------------------------------------------------------------------------
# Species parameter hashes
#-------------------------------------------------------------------------------
def species_sprite_params(*params)
  data = {
    :species   => params[0] || nil,
    :form      => params[1] || 0,
    :gender    => params[2] || 0,
    :shiny     => params[3] || false,
    :shadow    => params[4] || false,
    :back      => params[5] || false,
    :egg       => params[6] || false,
    :dmax      => params[7] || false,
    :gmax      => params[8] || false,
    :celestial => params[9] || false
  }
  return data
end

def species_sprite_params2(*params)
  data = {
    :species   => params[0] || nil,
    :form      => params[2] || 0,
    :gender    => params[1] || 0,
    :shiny     => params[3] || false,
    :shadow    => params[4] || false,
    :back      => params[5] || false,
    :egg       => params[6] || false,
    :dmax      => params[7] || false,
    :gmax      => params[8] || false,
    :celestial => params[9] || false
  }
  return data
end

def species_icon_params(*params)
  data = {
    :species   => params[0] || nil,
    :form      => params[1] || 0,
    :gender    => params[2] || 0,
    :shiny     => params[3] || false,
    :shadow    => params[4] || false,
    :egg       => params[5] || false,
    :dmax      => params[6] || false,
    :gmax      => params[7] || false,
    :celestial => params[8] || false
  }
  return data
end

def species_overworld_params(*params)
  data = {
    :species   => params[0] || nil,
    :form      => params[1] || 0,
    :gender    => params[2] || 0,
    :shiny     => params[3] || false,
    :shadow    => params[4] || false,
    :celestial => params[5] || false
  }
  return data
end

def species_cry_params(*params)
  data = {
    :species   => params[0] || nil,
    :form      => params[1] || 0,
    :suffix    => params[2] || "",
    :shiny     => params[3] || false,
    :shadow    => params[4] || false,
    :dmax      => params[5] || false,
    :gmax      => params[6] || false,
    :celestial => params[7] || false
  }
  return data
end


#-------------------------------------------------------------------------------
# Species files
#-------------------------------------------------------------------------------
module GameData
  class Species
    def self.check_graphic_file(path, params, subfolder = "", dmax_folder = "")
      species   = params[:species]
      form      = params[:form]
      gender    = params[:gender]
      shiny     = params[:shiny]
      shadow    = params[:shadow]
      dmax      = params[:dmax]
      gmax      = params[:gmax]
      celestial = params[:celestial]
      try_dmax_folder = ""
      try_subfolder = sprintf("%s/", subfolder)
      try_species = species
      try_form    = (form > 0)    ? sprintf("_%d", form) : ""
      try_gender  = (gender == 1) ? "_female"    : ""
      try_shadow  = (shadow)      ? "_shadow"    : ""
      try_dmax    = (dmax)        ? "_dmax"      : ""
      try_gmax    = (gmax)        ? "_gmax"      : ""
      try_celest  = (celestial)   ? "_celestial" : ""
      factors = []
      factors.push([8, sprintf("%s", dmax_folder), try_dmax_folder]) if dmax || gmax
      factors.push([7, sprintf("%s shiny/", subfolder), try_subfolder]) if shiny
      factors.push([6, try_celest, ""]) if celestial
      factors.push([5, try_gmax,   ""]) if gmax
      factors.push([4, try_dmax,   ""]) if dmax
      factors.push([3, try_shadow, ""]) if shadow
      factors.push([2, try_gender, ""]) if gender == 1
      factors.push([1, try_form,   ""]) if form > 0
      factors.push([0, try_species, "000"])
      (2**factors.length).times do |i|
        factors.each_with_index do |factor, index|
          value = ((i / (2**index)).even?) ? factor[1] : factor[2]
          case factor[0]
          when 0 then try_species     = value
          when 1 then try_form        = value
          when 2 then try_gender      = value
          when 3 then try_shadow      = value
          when 4 then try_dmax        = value
          when 5 then try_gmax        = value
          when 6 then try_celest      = value
          when 7 then try_subfolder   = value
          when 8 then try_dmax_folder = value
          end
        end
        try_species_text = try_species
        ret = pbResolveBitmap(sprintf("%s%s%s%s%s%s%s%s%s%s", path, try_subfolder, try_dmax_folder,
                              try_species_text, try_form, try_gender, try_shadow, 
                              try_dmax, try_gmax, try_celest))
        return ret if ret
      end
      return nil
    end
    
    def apply_metrics_to_sprite(sprite, index, shadow = false, set = 0)
      metrics_data = GameData::SpeciesMetrics.get_species_form(@species, @form)
      metrics_data.apply_metrics_to_sprite(sprite, index, shadow, set)
    end
  
    #---------------------------------------------------------------------------
    # Sprite file names
    #---------------------------------------------------------------------------
    def self.front_sprite_filename(*params)
      params = species_sprite_params(*params)
      dmax = (params[:gmax]) ? "Gigantamax/" : (params[:dmax]) ? "Dynamax/" : ""
      return self.check_graphic_file("Graphics/Pokemon/", params, "Front", dmax)
    end

    def self.back_sprite_filename(*params)
      params = species_sprite_params(*params)
      dmax = (params[:gmax]) ? "Gigantamax/" : (params[:dmax]) ? "Dynamax/" : ""
      return self.check_graphic_file("Graphics/Pokemon/", params, "Back", dmax)
    end

    def self.sprite_filename(*params)
      data = species_sprite_params(*params)
      return self.egg_sprite_filename(data[:species], data[:form]) if data[:egg]
      return self.back_sprite_filename(*params) if data[:back]
      return self.front_sprite_filename(*params)
    end
	
    #---------------------------------------------------------------------------
    # Compatibility with Following Pokemon EX.
    #---------------------------------------------------------------------------
    def self.ow_sprite_filename(*params)
      params = species_overworld_params(*params)
      ret = self.check_graphic_file("Graphics/Characters/", params, "Followers")
      ret = "Graphics/Characters/Followers/" if nil_or_empty?(ret)
      return ret
    end

    #---------------------------------------------------------------------------
    # Sprite bitmaps
    #---------------------------------------------------------------------------
    def self.front_sprite_bitmap(*params)
      filename = self.front_sprite_filename(*params)
      hue = (PluginManager.installed?("Pokémon Birthsigns")) ? pbCelestialHue(params[0], params[9]) : 0
      if PluginManager.installed?("Generation 8 Pack Scripts")
        sp_data  = GameData::SpeciesMetrics.get_species_form(params[0], params[1])
        scale    = sp_data ? sp_data.front_sprite_scale : Settings::FRONT_BATTLER_SPRITE_SCALE
        bitmap   = (filename) ? EBDXBitmapWrapper.new(filename, scale) : nil
        bitmap.hue_change(hue) if bitmap && hue != 0
        return bitmap
      else
        return (filename) ? AnimatedBitmap.new(filename, hue) : nil
      end
    end

    def self.back_sprite_bitmap(*params)
      filename = self.back_sprite_filename(*params)
      hue = (PluginManager.installed?("Pokémon Birthsigns")) ? pbCelestialHue(params[0], params[9]) : 0
      if PluginManager.installed?("Generation 8 Pack Scripts")
        sp_data  = GameData::SpeciesMetrics.get_species_form(params[0], params[1])
        scale    = sp_data ? sp_data.back_sprite_scale : Settings::BACK_BATTLER_SPRITE_SCALE
        bitmap   = (filename) ? EBDXBitmapWrapper.new(filename, scale) : nil
        bitmap.hue_change(hue) if bitmap && hue != 0
        return bitmap
      else
        return (filename) ? AnimatedBitmap.new(filename, hue) : nil
      end
    end

    def self.sprite_bitmap(*params)
      data = species_sprite_params(*params)
      return self.egg_sprite_bitmap(data[:species], data[:form]) if data[:egg]
      return self.back_sprite_bitmap(*params) if data[:back]
      return self.front_sprite_bitmap(*params)
    end
    
    def self.sprite_bitmap_from_pokemon(*params)
      pkmn    = params[0]
      back    = params[1]
      species = params[2]
      target  = params[3]
      species = pkmn.species if !species
      species = GameData::Species.get(species).species
      return self.egg_sprite_bitmap(species, pkmn.form) if pkmn.egg?
      gmax   = (target) ? (target.gmax_factor? && target.dynamax? && pkmn.dynamax?) : pkmn.gmax?
      sprite = [species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?, back, pkmn.egg?, pkmn.dynamax?, gmax, pkmn.celestial?]
      ret    = (back) ? self.back_sprite_bitmap(*sprite) : self.front_sprite_bitmap(*sprite)
      if PluginManager.installed?("Generation 8 Pack Scripts")
        alter_bitmap_function = (ret && ret.total_frames == 1) ? MultipleForms.getFunction(species, "alterBitmap") : nil
        if ret && alter_bitmap_function
          ret.prepare_strip
          for i in 0...ret.total_frames
            alter_bitmap_function.call(pkmn, ret.alter_bitmap(i))
          end
          ret.compile_strip
        end
      else
        alter_bitmap_function = MultipleForms.getFunction(species, "alterBitmap")
        if ret && alter_bitmap_function
          new_ret = ret.copy
          ret.dispose
          new_ret.each { |bitmap| alter_bitmap_function.call(pkmn, bitmap) }
          ret = new_ret
        end
      end
      return ret
    end

    #---------------------------------------------------------------------------
    # Icons
    #---------------------------------------------------------------------------
    def self.icon_filename(*params)
      params = species_icon_params(*params)
      return self.egg_icon_filename(params[:species], params[:form]) if params[:egg]
      dmax = (params[:gmax]) ? "Gigantamax/" : (params[:dmax]) ? "Dynamax/" : ""
      return self.check_graphic_file("Graphics/Pokemon/", params, "Icons", dmax)
    end
    
    def self.icon_filename_from_pokemon(pkmn)
      return self.icon_filename(pkmn.species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?, pkmn.egg?, 
                                pkmn.dynamax?, pkmn.gmax?, pkmn.celestial?)
    end
    
    def self.icon_bitmap(*params)
      filename = self.icon_filename(*params)
      hue = (PluginManager.installed?("Pokémon Birthsigns")) ? pbCelestialHue(params[0], params[8]) : 0
      return (filename) ? AnimatedBitmap.new(filename, hue).deanimate : nil
    end
    
    def self.icon_bitmap_from_pokemon(pkmn)
      return self.icon_bitmap(pkmn.species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?, pkmn.egg?, 
                              pkmn.dynamax?, pkmn.gmax?, pkmn.celestial?)
    end
  
    #---------------------------------------------------------------------------
    # Cries
    #---------------------------------------------------------------------------
    def self.check_cry_file(*params)
      params = species_cry_params(*params)
      species_data = self.get_species_form(params[:species], params[:form])
      return nil if species_data.nil?
      base_file = "#{species_data.species}" + params[:suffix]
      form_file = "#{species_data.species}" + "_#{params[:form]}" + params[:suffix]
      file = (params[:form] > 0) ? form_file : base_file
      base_folder = "Cries/"
      #-------------------------------------------------------------------------
      # Plays Gigantamax cry if one exists.
      #-------------------------------------------------------------------------
      if params[:gmax]
        folder = base_folder + "Gigantamax/"
        cry = folder + file
        backup = folder + base_file
        return cry if pbResolveAudioSE(cry)
        return backup if pbResolveAudioSE(backup)
      end
      #-------------------------------------------------------------------------
      # Plays Dynamax cry if one exists.
      #-------------------------------------------------------------------------
      if params[:dmax]
        folder = base_folder + "Dynamax/"
        cry = folder + file
        backup = folder + base_file
        return cry if pbResolveAudioSE(cry)
        return backup if pbResolveAudioSE(backup)
      end
      #-------------------------------------------------------------------------
      # Plays Celestial cry if one exists.
      #-------------------------------------------------------------------------
      if params[:celestial]
        folder = base_folder + "Celestial/"
        cry = folder + file
        backup = folder + base_file
        return cry if pbResolveAudioSE(cry)
        return backup if pbResolveAudioSE(backup)
      end
      #-------------------------------------------------------------------------
      # Plays Shadow cry if one exists.
      #-------------------------------------------------------------------------
      if params[:shadow]
        folder = base_folder + "Shadow/"
        cry = folder + file
        backup = folder + base_file
        return cry if pbResolveAudioSE(cry)
        return backup if pbResolveAudioSE(backup)
      end
      #-------------------------------------------------------------------------
      # Plays Shiny cry if one exists.
      #-------------------------------------------------------------------------
      if params[:shiny]
        folder = base_folder + "Shiny/"
        cry = folder + file
        backup = folder + base_file
        return cry if pbResolveAudioSE(cry)
        return backup if pbResolveAudioSE(backup)
      end
      #-------------------------------------------------------------------------
      # Plays base cry.
      #-------------------------------------------------------------------------
      cry = base_folder + file
      backup = base_folder + base_file
      return cry if pbResolveAudioSE(cry)
      return (pbResolveAudioSE(backup)) ? backup : nil
    end
  
    def self.cry_filename(*params)
      return self.check_cry_file(*params)
    end
  
    def self.cry_filename_from_pokemon(pkmn, suffix = "")
      params = [pkmn.species, pkmn.form, suffix, pkmn.shiny?, pkmn.shadowPokemon?, pkmn.dynamax?, pkmn.gmax?, pkmn.celestial?]
      return self.check_cry_file(*params)
    end
  end
  
  
  #-----------------------------------------------------------------------------
  # Metrics
  #-----------------------------------------------------------------------------
  class SpeciesMetrics
    def apply_metrics_to_sprite(sprite, index, shadow = false, set = 0)
      metrics = {
        :back     => [@back_sprite,           @dmax_back_sprite,   @gmax_back_sprite],
        :front    => [@front_sprite,          @dmax_front_sprite,  @gmax_front_sprite],
        :altitude => [@front_sprite_altitude, @dmax_altitude,      @gmax_altitude],
        :shadow   => [@shadow_x,              @dmax_shadow_x,      @gmax_shadow_x]
      }
      if shadow
        if (index & 1) == 1
          sprite.x += metrics[:shadow][set] * 2
        end
      elsif (index & 1) == 0
        sprite.x += metrics[:back][set][0] * 2
        sprite.y += metrics[:back][set][1] * 2
      else
        offset = metrics[:front][set][0] * 2
        sprite.x = (sprite.mirror) ? sprite.x -= offset : sprite.x += offset
        sprite.y += metrics[:front][set][1] * 2
        sprite.y -= metrics[:altitude][set] * 2
      end
    end
  end
end


#-------------------------------------------------------------------------------
# Compatibility with Visible Overworld Wild Encounters.
#-------------------------------------------------------------------------------
def ow_sprite_filename(*params)
  params = species_overworld_params(*params)
  fname = GameData::Species.check_graphic_file("Graphics/Characters/", params, "Followers")
  fname = "Graphics/Characters/Followers/000.png" if nil_or_empty?(fname)
  return fname
end


#-------------------------------------------------------------------------------
# Pokemon bitmaps (Out of battle)
#-------------------------------------------------------------------------------
class PokemonSprite < SpriteWrapper
  def setPokemonBitmap(pokemon, back = false)
    @_iconbitmap&.dispose
    @_iconbitmap = (pokemon) ? GameData::Species.sprite_bitmap_from_pokemon(pokemon, back) : nil
    self.bitmap = (@_iconbitmap) ? @_iconbitmap.bitmap : nil
    self.color = Color.new(0, 0, 0, 0)
    if PluginManager.installed?("ZUD Mechanics")
      if pokemon.dynamax?
        self.applyDynamax(pokemon.isSpecies?(:CALYREX))
      else
        self.unDynamax
      end
    end
    changeOrigin
  end

  def setPokemonBitmapSpecies(pokemon, species, back = false, target = nil)
    @_iconbitmap&.dispose
    @_iconbitmap = (pokemon) ? GameData::Species.sprite_bitmap_from_pokemon(pokemon, back, species, target) : nil
    self.bitmap = (@_iconbitmap) ? @_iconbitmap.bitmap : nil
    if PluginManager.installed?("ZUD Mechanics")
      if pokemon.dynamax?
        self.applyDynamax(pokemon.isSpecies?(:CALYREX))
      else
        self.unDynamax
      end
    end
    changeOrigin
  end

  def setSpeciesBitmap(*params)
    data = species_sprite_params2(*params)
    @_iconbitmap&.dispose
    @_iconbitmap = GameData::Species.sprite_bitmap(*data.values)
    self.bitmap = (@_iconbitmap) ? @_iconbitmap.bitmap : nil
    if PluginManager.installed?("ZUD Mechanics")
      if data[:dmax] || data[:gmax]
        self.applyDynamax(data[:species] == :CALYREX)
      else
        self.unDynamax
      end
    end
    changeOrigin
  end
end


#-------------------------------------------------------------------------------
# Pokemon bitmaps (In battle)
#-------------------------------------------------------------------------------
class Battle::Scene::BattlerSprite < RPG::Sprite
  def setPokemonBitmap(*params)
    @pkmn    = params[0]
    back     = params[1]
    target   = params[2]
    @dynamax = 0
    @calyrex = @pkmn.isSpecies?(:CALYREX)
    @_iconBitmap&.dispose
    @_iconBitmap = GameData::Species.sprite_bitmap_from_pokemon(@pkmn, back, nil, target)
    self.bitmap = (@_iconBitmap) ? @_iconBitmap.bitmap : nil
    if PluginManager.installed?("ZUD Mechanics")
      if target
        if target.dynamax?
          @dynamax = (target.gmax_factor? && @pkmn.gmax?) ? 2 : 1 
        end
      else
        if @pkmn.dynamax?
          @dynamax = (@pkmn.gmax?) ? 2 : 1
        end
      end
      self.applyDynamax(@calyrex) if @dynamax > 0
    end
    pbSetPosition
  end
  
  def pbSetPosition
    return if !@_iconBitmap
    pbSetOrigin
    if @index.even?
      self.z = 50 + (5 * @index / 2)
    else
      self.z = 50 - (5 * (@index + 1) / 2)
    end
    p = Battle::Scene.pbBattlerPosition(@index, @sideSize)
    @spriteX = p[0]
    @spriteY = p[1]
    @pkmn.species_data.apply_metrics_to_sprite(self, @index, false, @dynamax)
  end
  
  def update(frameCounter = 0)
    return if !@_iconBitmap
    @updating = true
    @_iconBitmap.update
    self.bitmap = @_iconBitmap.bitmap
    @spriteYExtra = 0
    if @selected==1
      case (frameCounter / QUARTER_ANIM_PERIOD).floor
      when 1 then @spriteYExtra = 2
      when 3 then @spriteYExtra = -2
      end
    end
    self.x       = self.x
    self.y       = self.y
    if PluginManager.installed?("ZUD Mechanics")
      self.applyDynamax(@calyrex) if @dynamax > 0
    end
    self.visible = @spriteVisible
    if @selected==2 && @spriteVisible
      case (frameCounter / SIXTH_ANIM_PERIOD).floor
      when 2, 5; self.visible = false
      else;      self.visible = true
      end
    end
    @updating = false
  end
end


#-------------------------------------------------------------------------------
# Icon sprites (Defined Pokemon)
#-------------------------------------------------------------------------------
class PokemonIconSprite < SpriteWrapper
  def pokemon=(value)
    @pokemon = value
    @animBitmap&.dispose
    @animBitmap = nil
    if !@pokemon
      self.bitmap = nil
      @currentFrame = 0
      @counter = 0
      return
    end
    hue = (PluginManager.installed?("Pokémon Birthsigns")) ? pbCelestialHue(@pokemon.species, @pokemon.celestial?) : 0
    @animBitmap = AnimatedBitmap.new(GameData::Species.icon_filename_from_pokemon(value), hue)
    self.bitmap = @animBitmap.bitmap
    self.src_rect.width  = @animBitmap.height
    self.src_rect.height = @animBitmap.height
    @numFrames    = @animBitmap.width / @animBitmap.height
    @currentFrame = 0 if @currentFrame >= @numFrames
    changeOrigin
  end
end


#-------------------------------------------------------------------------------
# Icon sprites (for species)
#-------------------------------------------------------------------------------
class PokemonSpeciesIconSprite < SpriteWrapper
  attr_reader :shadow
  attr_reader :dmax
  attr_reader :gmax
  attr_reader :celestial
  
  def initialize(species, viewport = nil)
    super(viewport)
    @species      = species
    @gender       = 0
    @form         = 0
    @shiny        = 0
    @shadow       = 0
    @dmax         = 0
    @gmax         = 0
    @celestial    = 0
    @numFrames    = 0
    @currentFrame = 0
    @counter      = 0
    refresh
  end
  
  def shadow=(value)
    @shadow = value
    refresh
  end
  
  def dmax=(value)
    @dmax = value
    refresh
  end
  
  def gmax=(value)
    @gmax = value
    refresh
  end
  
  def celestial=(value)
    @celestial = value
    refresh
  end

  def pbSetParams(*params)
    @species   = params[0]
    @gender    = params[1]
    @form      = params[2]
    @shiny     = params[3] || false
    @shadow    = params[4] || false
    @dmax      = params[5] || false
    @gmax      = params[6] || false
    @celestial = params[7] || false
    refresh
  end
  
  def refresh
    @animBitmap&.dispose
    @animBitmap = nil
    bitmapFileName = GameData::Species.icon_filename(@species, @form, @gender, @shiny, @shadow, false, @dmax, @gmax, @celestial)
    return if !bitmapFileName
    hue = (PluginManager.installed?("Pokémon Birthsigns")) ? pbCelestialHue(@species, @celestial) : 0
    @animBitmap = AnimatedBitmap.new(bitmapFileName, hue)
    self.bitmap = @animBitmap.bitmap
    self.src_rect.width  = @animBitmap.height
    self.src_rect.height = @animBitmap.height
    @numFrames = @animBitmap.width / @animBitmap.height
    @currentFrame = 0 if @currentFrame >= @numFrames
    changeOrigin
  end
end


#-------------------------------------------------------------------------------
# Icon sprites (Storage)
#-------------------------------------------------------------------------------
class PokemonBoxIcon < IconSprite
  def refresh
    return if !@pokemon
    hue = (PluginManager.installed?("Pokémon Birthsigns")) ? pbCelestialHue(@pokemon.species, @pokemon.celestial?) : 0
    self.setBitmap(GameData::Species.icon_filename_from_pokemon(@pokemon), hue)
    self.src_rect = Rect.new(0, 0, self.bitmap.height, self.bitmap.height)
  end
end