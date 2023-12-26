#===============================================================================
# BW Storage System compatibility.
#===============================================================================
if PluginManager.installed?("BW Storage System")
  class PokemonStorageScene
    def pbUpdateOverlay(selection, party = nil)
      overlay = @sprites["overlay"].bitmap
      overlay.clear
      if !@sprites["plugin_overlay"]
        @sprites["plugin_overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @boxsidesviewport)
        pbSetSystemFont(@sprites["plugin_overlay"].bitmap)
      end
      plugin_overlay = @sprites["plugin_overlay"].bitmap
      plugin_overlay.clear
      buttonbase = Color.new(239, 239, 239)
      buttonshadow = Color.new(132, 132, 132)
      pbDrawTextPositions(
        overlay,
        [[_INTL("PARTY: {1}", (@storage.party.length rescue 0)), 274, 350, 2, buttonbase, buttonshadow],
         [_INTL("Exit"), 450, 350, 2, buttonbase, buttonshadow]]
      )
      pokemon = nil
      if @screen.pbHeldPokemon
        pokemon = @screen.pbHeldPokemon
      elsif selection >= 0
        pokemon = (party) ? party[selection] : @storage[@storage.currentBox, selection]
      end
      if !pokemon
        @sprites["pokemon"].visible = false
        return
      end
      @sprites["pokemon"].visible = true
      base   = Color.new(90, 82, 82)
      shadow = Color.new(165, 165, 173)
      nonbase   = Color.new(90, 82, 82)
      nonshadow = Color.new(165, 165, 173)
      pokename = pokemon.name
      textstrings = [
        [pokename, 10, 16, false, base, shadow]
      ]
      if !pokemon.egg?
        imagepos = []
        if pokemon.male?
          textstrings.push([_INTL("♂"), 148, 16, false, Color.new(0, 0, 214), Color.new(15, 148, 255)])
        elsif pokemon.female?
          textstrings.push([_INTL("♀"), 148, 16, false, Color.new(198, 0, 0), Color.new(255, 155, 155)])
        end
        imagepos.push(["Graphics/Pictures/Storage/overlay_lv", 6, 268])
        textstrings.push([pokemon.level.to_s, 28, 262, false, Color.new(255, 255, 255), Color.new(90, 82, 82)])
        if pokemon.ability
          textstrings.push([pokemon.ability.name, 16, 328, 0, base, shadow])
        else
          textstrings.push([_INTL("No ability"), 16, 328, 0, nonbase, nonshadow])
        end
        if pokemon.item
          textstrings.push([pokemon.item.name, 16, 360, 0, base, shadow])
        else
          textstrings.push([_INTL("No item"), 16, 360, 0, nonbase, nonshadow])
        end
        if pokemon.shiny?
          imagepos.push(["Graphics/Pictures/shiny", 68, 262])
        end
        if PluginManager.installed?("ZUD Mechanics")
          pbDisplayGmaxFactor(pokemon, plugin_overlay, 8, 52)
        end
        if PluginManager.installed?("Terastal Phenomenon") && Settings::STORAGE_TERA_TYPES
          pbDisplayTeraType(pokemon, plugin_overlay, 8, 192)
        end
        if PluginManager.installed?("Pokémon Birthsigns")
          pbDisplayToken(pokemon, plugin_overlay, 149, 162, true)
        end
        if PluginManager.installed?("Enhanced UI")
          pbDisplayShinyLeaf(pokemon, plugin_overlay, 158, 52)      if Settings::STORAGE_SHINY_LEAF
          pbDisplayIVRatings(pokemon, plugin_overlay, 8, 226, true) if Settings::STORAGE_IV_RATINGS
        end
        typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
        pokemon.types.each_with_index do |type, i|
          type_number = GameData::Type.get(type).icon_position
          type_rect = Rect.new(0, type_number * 28, 64, 28)
          type_x = (pokemon.types.length == 1) ? 52 : 18 + (70 * i)
          overlay.blt(type_x, 292, typebitmap.bitmap, type_rect)
        end
        drawMarkings(overlay, 86, 262, 128, 20, pokemon.markings)
        pbDrawImagePositions(overlay, imagepos)
      end
      pbDrawTextPositions(overlay, textstrings)
      @sprites["pokemon"].setPokemonBitmap(pokemon)
    end
  end
end