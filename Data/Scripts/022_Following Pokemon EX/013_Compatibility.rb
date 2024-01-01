#-------------------------------------------------------------------------------
# Change EBDX Following Pokemon check since EBDX hasn't updated
#-------------------------------------------------------------------------------
if PluginManager.findDirectory("Elite Battle: DX")
  module EliteBattle
    def self.follower(battle)
      return nil if !EliteBattle::USE_FOLLOWER_EXCEPTION
      return (FollowingPkmn.active? && battle.scene.firstsendout) ? 0 : nil
    end
  end
end

#-------------------------------------------------------------------------------
# New GameData::Species method for easily get the appropriate Following Pokemon
# graphic
#-------------------------------------------------------------------------------
module GameData
  class Species
    def self.ow_sprite_filename(species, form = 0, gender = 0, shiny = false, shadow = false)
      ret = self.check_graphic_file("Graphics/Characters/", species, form,
                                    gender, shiny, shadow, "Followers")
      ret = "Graphics/Characters/Followers/" if nil_or_empty?(ret)
	    return ret
    end
  end
end

#-------------------------------------------------------------------------------
# New option in the Options menu to toggle Following Pokemon
#-------------------------------------------------------------------------------
MenuHandlers.add(:options_menu, :follower_toggle, {
  "name"        => _INTL("Following Pokemon"),
  "order"       => 999,
  "type"        => EnumOption,
  "parameters"  => [_INTL("On"), _INTL("Off")],
  "description" => _INTL("Let the first Pokemon in your party follow you in the overworld."),
  "condition"   => proc { FollowingPkmn.can_check? && FollowingPkmn.get_event && FollowingPkmn::SHOW_TOGGLE_IN_OPTIONS },
  "get_proc"    => proc { next ($PokemonGlobal&.follower_toggled ? 0 : 1) },
  "set_proc"    => proc { |value, _scene|
    next if !FollowingPkmn.can_check?
    next if $PokemonGlobal.follower_toggled == (value == 0)
    $PokemonGlobal.follower_toggled = (value == 0)
    FollowingPkmn.refresh(false)
  }
})

class PokemonOptionScreen
  alias __followingpkmn__pbStartScreen pbStartScreen unless method_defined?(:__followingpkmn__pbStartScreen)
  def pbStartScreen(*args)
    __followingpkmn__pbStartScreen(*args)
    pbRefreshSceneMap
  end
end

#-------------------------------------------------------------------------------
# New trigger method for Named Events that returns the value of the callback
#-------------------------------------------------------------------------------
class NamedEvent
  def trigger_2(*args)
    @callbacks.each_value { |callback|
      ret = callback.call(*args)
      return ret if !ret.nil?
    }
    return -1
  end
end

#-------------------------------------------------------------------------------
# New trigger method for EventHandlers that returns the value of the callback
#-------------------------------------------------------------------------------
module EventHandlers
  def self.trigger_2(event, *args)
    return @@events[event]&.trigger_2(*args)
  end
end
