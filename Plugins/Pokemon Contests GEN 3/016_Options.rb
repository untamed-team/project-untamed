#====================================================================================
#  Options menu 
#====================================================================================

class PokemonSystem
  attr_accessor :contestsceneanimations
  
  alias pokemon_contests_options_init initialize
  def initialize
	pokemon_contests_options_init
	@contestsceneanimations = 0 #Contest effects (animations) (0=on, 1=off)
  end
  
end

MenuHandlers.add(:options_menu, :contest_animations, {
  "name"        => _INTL("Contest Effects"),
  "order"       => 41,
  "type"        => EnumOption,
  "parameters"  => [_INTL("On"), _INTL("Off")],
  "description" => _INTL("Choose whether you wish to see move animations in contests."),
  "get_proc"    => proc { next $PokemonSystem.contestsceneanimations },
  "set_proc"    => proc { |value, _scene| $PokemonSystem.contestsceneanimations = value }
})