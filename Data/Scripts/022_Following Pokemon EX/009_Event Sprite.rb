#-------------------------------------------------------------------------------
# Expose follower_sprites attribute of Spriteset_Map
#-------------------------------------------------------------------------------
class Spriteset_Global
  attr_reader :follower_sprites
end

#-------------------------------------------------------------------------------
# Add Reflections to Following Pokemon sprite
#-------------------------------------------------------------------------------
class Sprite_Character
  def set_reflection(viewport, event)
    @reflection = Sprite_Reflection.new(self, event, viewport) if !@reflection
  end
end

#-------------------------------------------------------------------------------
# Refresh Following Pokemon sprites whenever the map is refreshed
#-------------------------------------------------------------------------------
EventHandlers.add(:on_enter_map, :erase_following_pkmn, proc { |_old_map_id|
  event = FollowingPkmn.get_data
  next if !event
  FollowingPkmn.refresh(false)
  $map_factory.maps.each { |map|
    map.events[event.event_id]&.erase if event.original_map_id == event.current_map_id
  }
})

class FollowerSprites
  #-----------------------------------------------------------------------------
  # Updating the refresh method to allow clearing of base event in all maps,
  # add reflections and prevent crash when base map/event is deleted
  #-----------------------------------------------------------------------------
  alias __followingpkmn__refresh refresh unless method_defined?(:__followingpkmn__refresh)
  def refresh(*args)
    ret = __followingpkmn__refresh(*args)
    return ret if !FollowingPkmn.can_check?
    event = FollowingPkmn.get_event
    @sprites.each do |spr|
      next if !FollowingPkmn.get_data&.following_pkmn?
      spr.set_reflection(@viewport, event)
    end
    data = FollowingPkmn.get_data
    $map_factory.maps.each { |map|
      map&.events[data.event_id]&.erase if data && data.original_map_id == data.current_map_id
    }
    FollowingPkmn.refresh(false)
  end
  #-----------------------------------------------------------------------------
  # Adding DayNight and Status condition pulsing effect to Following Pokemon
  # sprite
  #-----------------------------------------------------------------------------
  alias __followingpkmn__update update unless method_defined?(:__followingpkmn__update)
  def update(*args)
    __followingpkmn__update(*args)
    return if !FollowingPkmn.active?
    @sprites.each_with_index do |sprite, i|
      next if !$PokemonGlobal.followers[i] || !$PokemonGlobal.followers[i].following_pkmn?
      first_pkmn = FollowingPkmn.get_pokemon
      next if !first_pkmn
      if first_pkmn.status == :NONE || !FollowingPkmn::APPLY_STATUS_TONES
        sprite.color.set(0, 0, 0, 0)
        $game_temp.status_pulse = [50.0, 50.0, 150.0, (100/(Graphics.frame_rate * 2.0))]
        next
      end
      status_tone = nil
      status_tone = FollowingPkmn.const_get("TONE_#{first_pkmn.status}") if FollowingPkmn.const_defined?("TONE_#{first_pkmn.status}")
      next if !status_tone || !status_tone.all? {|s| s > 0}
      $game_temp.status_pulse[0] += $game_temp.status_pulse[3]
      $game_temp.status_pulse[3] *= -1 if $game_temp.status_pulse[0] < $game_temp.status_pulse[1] ||
                                            $game_temp.status_pulse[0] > $game_temp.status_pulse[2]
      sprite.color.set(status_tone[0], status_tone[1], status_tone[2], $game_temp.status_pulse[0])
    end
  end
  #-----------------------------------------------------------------------------
  # Add emote animation to Following Pokemon
  #-----------------------------------------------------------------------------
  def set_animation(anim_id)
    @sprites.each do |spr|
      next if spr.character != FollowingPkmn.get_event
      spr.character.animation_id = anim_id
    end
  end
  #-----------------------------------------------------------------------------
end
