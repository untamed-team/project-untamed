#===============================================================================
# Revamps base Essentials code related to the player's Pokedex to allow for 
# plugin compatibility.
#===============================================================================


#-------------------------------------------------------------------------------
# Pokedex sprites.
#-------------------------------------------------------------------------------
class PokemonPokedexInfo_Scene
  def pbUpdateDummyPokemon
    @species = @dexlist[@index][0]
    @gender, @form, @shiny, @gmax, @shadow = $player.pokedex.last_form_seen(@species)
    @celestial = false
    metrics_data = GameData::SpeciesMetrics.get_species_form(@species, @form)
    @sprites["infosprite"].setSpeciesBitmap(@species, @gender, @form, @shiny, @shadow, false, false, false, @gmax, @celestial)
    @sprites["infosprite"].unDynamax
    @sprites["formfront"]&.setSpeciesBitmap(@species, @gender, @form, @shiny, @shadow, false, false, false, @gmax, @celestial)
    @sprites["formfront"]&.unDynamax
    if @sprites["formback"]
      @sprites["formback"].setSpeciesBitmap(@species, @gender, @form, @shiny, @shadow, true, false, false, @gmax, @celestial)
      @sprites["formback"].unDynamax
      @sprites["formback"].y = 256
      @sprites["formback"].y += metrics_data.back_sprite[1] * 2
    end
    @sprites["formicon"]&.pbSetParams(@species, @gender, @form, @shiny, @shadow, false, @gmax, @celestial)
    if PluginManager.installed?("Generation 8 Pack Scripts")
      return if defined?(EliteBattle)
      sp_data = GameData::SpeciesMetrics.get_species_form(@species, @form)
      @sprites["infosprite"].constrict([208, 200])
      @sprites["formfront"].constrict([200, 196]) if @sprites["formfront"]
      return if !@sprites["formback"]
      @sprites["formback"].constrict([300, 294])
      return if sp_data.back_sprite_scale == sp_data.front_sprite_scale
      @sprites["formback"].setOffset(PictureOrigin::CENTER)
      @sprites["formback"].y = @sprites["formfront"].y if @sprites["formfront"]
      @sprites["formback"].zoom_x = (sp_data.front_sprite_scale.to_f / sp_data.back_sprite_scale)
      @sprites["formback"].zoom_y = (sp_data.front_sprite_scale.to_f / sp_data.back_sprite_scale)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Gets all displayable species forms. Includes shiny and shadow forms.
  #-----------------------------------------------------------------------------
  def pbGetAvailableForms
    ret = []
    last_ret = -1
    multiple_forms = false
    GameData::Species.each do |sp|
      next if sp.species != @species
      next if sp.form != 0 && (!sp.real_form_name || sp.real_form_name.empty?)
      next if sp.pokedex_form != sp.form
      multiple_forms = true if sp.form > 0
      if sp.single_gendered?
        real_gender = (sp.gender_ratio == :AlwaysFemale) ? 1 : 0
        form_gender = (sp.gender_ratio == :Genderless)   ? 2 : real_gender
        #-----------------------------------------------------------------------
        # Single-gendered
        #-----------------------------------------------------------------------
        if $player.pokedex.seen_form?(@species, real_gender, sp.form, false, false) || Settings::DEX_SHOWS_ALL_FORMS
          ret[last_ret + 1] = [sp.form_name, form_gender, sp.form, false, false]
          last_ret = ret.length
        end
        #-----------------------------------------------------------------------
        # Shiny single-gendered
        #-----------------------------------------------------------------------
        if $player.pokedex.seen_form?(@species, real_gender, sp.form, true, false) && Settings::POKEDEX_SHINY_FORMS
          ret[last_ret + 1] = [sp.form_name, form_gender, sp.form, true, false]
          last_ret = ret.length
        end
        #-----------------------------------------------------------------------
        # Shadow single-gendered
        #-----------------------------------------------------------------------
        if $player.pokedex.owned_shadow_species?(sp.id) && Settings::POKEDEX_SHADOW_FORMS
          ret[last_ret + 1] = [sp.form_name, form_gender, sp.form, false, false, true]
          last_ret = ret.length
        end
      else
        2.times do |real_gender|
          #---------------------------------------------------------------------
          # Male/Female
          #---------------------------------------------------------------------
          if $player.pokedex.seen_form?(@species, real_gender, sp.form, false, false) || Settings::DEX_SHOWS_ALL_FORMS
            ret[last_ret + 1] = [sp.form_name, real_gender, sp.form, false, false]
            last_ret = ret.length
          end
          #---------------------------------------------------------------------
          # Shiny Male/Female
          #---------------------------------------------------------------------
          if $player.pokedex.seen_form?(@species, real_gender, sp.form, true, false) && Settings::POKEDEX_SHINY_FORMS
            ret[last_ret + 1] = [sp.form_name, real_gender, sp.form, true, false]
            last_ret = ret.length
          end
          #---------------------------------------------------------------------
          # Shadow Male/Female
          #---------------------------------------------------------------------
          if $player.pokedex.owned_shadow_species?(sp.id) && Settings::POKEDEX_SHADOW_FORMS
            ret[last_ret + 1] = [sp.form_name, real_gender, sp.form, false, false, true]
            last_ret = ret.length
          end
          break if sp.form_name && !sp.form_name.empty?
        end
      end
      #-------------------------------------------------------------------------
      # Gigantamax forms
      #-------------------------------------------------------------------------
      if PluginManager.installed?("ZUD Mechanics")
        ret, last_ret = pbAddGmaxForms(sp, ret, last_ret)
      end
    end
    ret.compact!
    ret.uniq!
    ret.each do |entry|
      prefix = ""
      prefix += "Shiny "  if entry[3]
      prefix += "Shadow " if entry[5]
      if !entry[0] || entry[0].empty?
        prefix += "Gigantamax " if entry[4]
        case entry[1]
        when 0 then entry[0] = _INTL("#{prefix}Male")
        when 1 then entry[0] = _INTL("#{prefix}Female")
        else
          entry[0] = (multiple_forms) ? _INTL("#{prefix}One Form") : _INTL("#{prefix}Genderless")
        end
      else
        entry[0] = _INTL("#{prefix}#{entry[0]}")
      end
      entry[1] = 0 if entry[1] == 2
    end
    return ret
  end
  
  def pbChooseForm
    index = 0
    @available.length.times do |i|
      if @available[i][1] == @gender && 
         @available[i][2] == @form   &&
         @available[i][3] == @shiny  &&
         @available[i][4] == @gmax   &&
         @available[i][5] == @shadow
        index = i
        break
      end
    end
    oldindex = -1
    loop do
      if oldindex != index
        $player.pokedex.set_last_form_seen(@species, 
          @available[index][1], # Gender
          @available[index][2], # Form
          @available[index][3], # Shiny
          @available[index][4], # Gigantamax
          @available[index][5]  # Shadow
        )
        pbUpdateDummyPokemon
        drawPage(@page)
        @sprites["uparrow"].visible   = (index > 0)
        @sprites["downarrow"].visible = (index<@available.length - 1)
        oldindex = index
      end
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::UP)
        pbPlayCursorSE
        index = (index + @available.length - 1) % @available.length
      elsif Input.trigger?(Input::DOWN)
        pbPlayCursorSE
        index = (index + 1) % @available.length
      elsif Input.trigger?(Input::BACK)
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        break
      end
    end
    @sprites["uparrow"].visible   = false
    @sprites["downarrow"].visible = false
  end
  
  def drawPageForms
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_forms"))
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(88, 88, 80)
    shadow = Color.new(168, 184, 184)
    formname = ""
    @available.each do |i|
      if i[1] == @gender && 
         i[2] == @form   &&
         i[3] == @shiny  &&
         i[4] == @gmax   &&
         i[5] == @shadow
        formname = i[0]
        break
      end
    end
    textpos = [
      [GameData::Species.get(@species).name, Graphics.width / 2, Graphics.height - 82, 2, base, shadow],
      [formname, Graphics.width / 2, Graphics.height - 50, 2, base, shadow]
    ]
    pbDrawTextPositions(overlay, textpos)
  end
end


class PokemonPokedex_Scene
  def setIconBitmap(species)
    gender, form, shiny, gmax, shadow = $player.pokedex.last_form_seen(species)
    @sprites["icon"].setSpeciesBitmap(species, gender, form, shiny, shadow, false, false, false, gmax)
    @sprites["icon"].unDynamax
    if PluginManager.installed?("Generation 8 Pack Scripts")
      @sprites["icon"].constrict([224, 216]) if !defined?(EliteBattle)
    end
  end
end


#-------------------------------------------------------------------------------
# Allows for special forms to be recorded in the Pokedex.
#-------------------------------------------------------------------------------
class Player < Trainer
  class Pokedex
    SEEN_ARRAY = [ # Species
      [            # Species[Male]   
        [          # Species[Male][Non Shiny] 
          [        # Species[Male][Non Shiny][Non G-max]
            []     # Species[Male][Non Shiny][Non G-max][Form]
          ], 
          [        # Species[Male][Non Shiny][G-max]
            []     # Species[Male][Non Shiny][G-max][Form]
          ]
        ], 
        [          # Species[Male][Shiny]
          [        # Species[Male][Shiny][Non G-max]
            []     # Species[Male][Shiny][Non G-max][Form]
          ], 
          [        # Species[Male][Shiny][G-max]
            []     # Species[Male][Shiny][G-max][Form]
          ]
        ] 
      ],  
      [            # Species[Female] 
        [          # Species[Female][Non Shiny]
          [        # Species[Female][Non Shiny][Non G-max]
            []     # Species[Female][Non Shiny][Non G-max][Form]
          ], 
          [        # Species[Female][Non Shiny][G-max]
            []     # Species[Female][Non Shiny][G-max][Form]
          ]
        ], 
        [          # Species[Female][Shiny]  
          [        # Species[Female][Shiny][Non G-max]
            []     # Species[Female][Shiny][Non G-max][Form]
          ], 
          [        # Species[Female][Shiny][G-max]
            []     # Species[Female][Shiny][G-max][Form]
          ]
        ] 
      ]   
    ]
    
    def seen_form?(species, gender, form, shiny = nil, gmax = nil)
      species_id = GameData::Species.try_get(species)&.species
      return false if species_id.nil?
      @seen_forms[species_id] ||= SEEN_ARRAY
      if shiny.nil? && gmax.nil?
        return @seen_forms[species_id][gender][0][0][form] ||
               @seen_forms[species_id][gender][0][1][form] ||
               @seen_forms[species_id][gender][1][0][form] ||
               @seen_forms[species_id][gender][1][1][form]
      end
      gmax  = (gmax)  ? 1 : 0
      shiny = (shiny) ? 1 : 0
      return @seen_forms[species_id][gender][shiny][gmax][form] == true
    end
    
    def seen_forms_count(species)
      species_id = GameData::Species.try_get(species)&.species
      return 0 if species_id.nil?
      ret = 0
      @seen_forms[species_id] ||= SEEN_ARRAY
      array = @seen_forms[species_id]
      [array[0].length, array[1].length].max.times do |i|
        ret += 1 if array[0][0][0][i] ||  # male, non-shiny, non-gmax
                    array[0][0][1][i] ||  # male, non-shiny, gmax
                    array[0][1][0][i] ||  # male, shiny, non-gmax
                    array[0][1][1][i] ||  # male, shiny, gmax
                    array[1][0][0][i] ||  # female, non-shiny, non-gmax
                    array[1][0][1][i] ||  # female, non-shiny, gmax
                    array[1][1][0][i] ||  # female, shiny, non-gmax
                    array[1][1][1][i]     # female, shiny, gmax
      end
      return ret
    end
    
    def last_form_seen(species)
      @last_seen_forms[species] ||= []
      return @last_seen_forms[species][0] || 0, 
             @last_seen_forms[species][1] || 0, 
             @last_seen_forms[species][2] || false, 
             @last_seen_forms[species][3] || false,
             @last_seen_forms[species][4] || nil
    end
    
    def set_last_form_seen(species, gender = 0, form = 0, shiny = false, gmax = false, shadow = nil)
      @last_seen_forms[species] = [gender, form, shiny, gmax, shadow]
    end
    
    def register(species, gender = 0, form = 0, shiny = false, should_refresh_dexes = true, gmax = false, shadow = false)
      if species.is_a?(Pokemon)
        species_data = species.species_data
        gender = species.gender
        shiny = species.shiny?
        gmax = species.gmax?
        shadow = species.shadowPokemon?
      else
        species_data = GameData::Species.get_species_form(species, form)
      end
      species = species_data.species
      gender = 0 if gender >= 2
      form = species_data.form
      _shiny = (shiny) ? 1 : 0
      _gmax = (gmax) ? 1 : 0
      if form != species_data.pokedex_form
        species_data = GameData::Species.get_species_form(species, species_data.pokedex_form)
        form = species_data.form
      end
      form = 0 if species_data.form_name.nil? || species_data.form_name.empty?
      @seen[species] = true
      @seen_forms[species] ||= SEEN_ARRAY
      @seen_forms[species][gender][_shiny][_gmax][form] = true
      @last_seen_forms[species] ||= []
      @last_seen_forms[species] = [gender, form, shiny, gmax, shadow] if @last_seen_forms[species] == []
      self.refresh_accessible_dexes if should_refresh_dexes
    end
    
    def register_last_seen(pkmn)
      validate pkmn => Pokemon
      species_data = pkmn.species_data
      form = species_data.pokedex_form
      form = 0 if species_data.form_name.nil? || species_data.form_name.empty?
      @last_seen_forms[pkmn.species] = [pkmn.gender, form, pkmn.shiny?, pkmn.gmax?, pkmn.shadowPokemon?]
    end
	
    def set_shadow_pokemon_owned(species)
      species_id = GameData::Species.try_get(species)&.species
      return if species_id.nil?
      @owned_shadow[species_id] = true
      @owned_shadow[species] = true if species != species_id 
      self.refresh_accessible_dexes
    end
	
    def owned_shadow_pokemon?(species)
      species_id = GameData::Species.try_get(species)&.species
      return false if species_id.nil?
      return @owned_shadow[species] || @owned_shadow[species_id]
    end
	
    def owned_shadow_species?(species)
      species_id = GameData::Species.try_get(species)&.id
      return false if species_id.nil?
      return @owned_shadow[species] == true
    end
  end
end