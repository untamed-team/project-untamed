

class Battle::Scene::PokemonDataBox < Sprite 
  
  alias aam_refresh refresh
  def refresh
    aam_refresh
    draw_mutation_icon
  end

  alias aam_draw_shiny_icon draw_shiny_icon
  def draw_shiny_icon
    if @battler.hasAbilityMutation?
      return if !@battler.shiny?
      shiny_x = (@battler.opposes?(0)) ? 220 : 8
      pbDrawImagePositions(self.bitmap, [["Graphics/Pictures/shiny", @spriteBaseX + shiny_x, 40]])
    else
      aam_draw_shiny_icon
    end
  end

  def draw_mutation_icon
    filename = nil
    specialX = (@battler.opposes?(0)) ? 198 : -18
    ypos = 30
    if @battler.hasAbilityMutation? && Settings::AAM_MUTATION_ICON
      if Settings::GLOBAL_MUTATION
        if Settings::GLOBAL_MUTATION_ICON
          filename = "Graphics/Pictures/icon_aam"
          pbDrawImagePositions(self.bitmap, [[filename, @spriteBaseX + specialX, ypos]]) if filename
        end
      else    
        filename = "Graphics/Pictures/icon_aam"
        pbDrawImagePositions(self.bitmap, [[filename, @spriteBaseX + specialX, ypos]]) if filename
      end
    end  
  end

end


class PokemonSummary_Scene
  alias abilityMutation_drawPage drawPage
	def drawPage(page)
	  abilityMutation_drawPage(page)
	  overlay = @sprites["overlay"].bitmap
	  coords = (PluginManager.installed?("BW Summary Screen")) ? [Graphics.width - 18, 114] : [182, 124]
	  pbDisplayAbilityMutation(@pokemon, overlay, coords[0], coords[1])
	end
end

def pbDisplayAbilityMutation(pokemon, overlay, xpos, ypos, vertical = false)
  imagepos = []
  path = "Graphics/Pictures/icon_aam"
  if pokemon.hasAbilityMutation? && Settings::AAM_MUTATION_ICON
    if Settings::GLOBAL_MUTATION
      if Settings::GLOBAL_MUTATION_ICON       
        imagepos.push([sprintf(path), xpos - 18, ypos - 33]) 
      end
    else   
      imagepos.push([sprintf(path), xpos - 18, ypos - 33])
    end
  end  
  pbDrawImagePositions(overlay, imagepos)
end
#########################################################################
#This is an example of an item that toggles abilityMutation on a Pokemon

ItemHandlers::UseOnPokemon.add(:EXAMPLEAAM, proc { |item, qty, pokemon, scene, screen, msg|
    scene.pbDisplay(_INTL("After consuming the [placeholder], {1} has awakened its untapped potential!",pokemon.name))
	pokemon.toggleAbilityMutation
})