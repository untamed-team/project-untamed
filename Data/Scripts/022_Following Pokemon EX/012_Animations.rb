#-------------------------------------------------------------------------------
# New animation to show the Following Pokemon execcuting a field move in the
# overworld
#-------------------------------------------------------------------------------
alias __followingpkmn__pbHiddenMoveAnimation pbHiddenMoveAnimation unless defined?(__followingpkmn__pbHiddenMoveAnimation)

#added here by Gardenette from Game_Map
def playerPassable?(x, y, d, self_event = nil)
	map = $game_map
	tileset = $data_tilesets[map.tileset_id]
	terrain_tags    = tileset.terrain_tags
	passages        = tileset.passages
	priorities      = tileset.priorities

  bit = (1 << ((d / 2) - 1)) & 0x0f
  [2, 1, 0].each do |i|
    tile_id = $game_map.data[x, y, i]
    next if tile_id == 0
    terrain = GameData::TerrainTag.try_get(terrain_tags[tile_id])
    passage = passages[tile_id]
    if terrain
      # Ignore bridge tiles if not on a bridge
      next if terrain.bridge && $PokemonGlobal.bridge == 0
      # Make water tiles passable if player is surfing
      return true if $PokemonGlobal.surfing && terrain.can_surf && !terrain.waterfall
      # Prevent cycling in really tall grass/on ice
      return false if $PokemonGlobal.bicycle && terrain.must_walk
     # Depend on passability of bridge tile if on bridge
      if terrain.bridge && $PokemonGlobal.bridge > 0
        return (passage & bit == 0 && passage & 0x0f != 0x0f)
      end
    end
    next if terrain&.ignore_passability
    # Regular passability checks
    return false if passage & bit != 0 || passage & 0x0f == 0x0f
    return true if priorities[tile_id] == 0
  end
  return true
end

def pbHiddenMoveAnimation(pokemon, no_field_move = false)
  no_field_move = no_field_move || $game_temp.no_follower_field_move
  ret = __followingpkmn__pbHiddenMoveAnimation(pokemon)
  return ret if !ret || no_field_move || !FollowingPkmn.active? || pokemon != FollowingPkmn.get_pokemon
  
  #added by Gardenette
  $PokemonGlobal.using_field_move = true
  
  pbTurnTowardEvent(FollowingPkmn.get_event, $game_player)
  pbWait(Graphics.frame_rate / 5)
  FollowingPkmn.move_route([PBMoveRoute::Forward])
  initialDir = $game_player.direction
  movedDir = 0
  case $game_player.direction
  when 2
  #player is facing down
	#try going up
	if playerPassable?($game_player.x, $game_player.y-1, 8) && movedDir <= 0
		pbMoveRoute($game_player, [PBMoveRoute::Up], true)
		movedDir = 8
		pbMoveRoute($game_player, [PBMoveRoute::TurnDown], true)
	end
	#try going left
	if playerPassable?($game_player.x-1, $game_player.y, 4) && movedDir <= 0
		pbMoveRoute($game_player, [PBMoveRoute::Left], true)
		movedDir = 4
		pbMoveRoute($game_player, [PBMoveRoute::TurnRight], true)
	end
	#try going right
	if playerPassable?($game_player.x+1, $game_player.y, 6) && movedDir <= 0
		pbMoveRoute($game_player, [PBMoveRoute::Right], true)
		movedDir = 6
		pbMoveRoute($game_player, [PBMoveRoute::TurnLeft], true)
	end
  when 4
  #player is facing left
	#try going right
	if playerPassable?($game_player.x+1, $game_player.y, 6) && movedDir <= 0
		pbMoveRoute($game_player, [PBMoveRoute::Right], true)
		movedDir = 6
		pbMoveRoute($game_player, [PBMoveRoute::TurnLeft], true)
	end
	#try going down
	if playerPassable?($game_player.x, $game_player.y+1, 2) && movedDir <= 0
		pbMoveRoute($game_player, [PBMoveRoute::Down], true)
		movedDir = 2
		pbMoveRoute($game_player, [PBMoveRoute::TurnUp], true)
	end
	#try going up
	if playerPassable?($game_player.x, $game_player.y-1, 8) && movedDir <= 0
		pbMoveRoute($game_player, [PBMoveRoute::Up], true)
		movedDir = 8
		pbMoveRoute($game_player, [PBMoveRoute::TurnDown], true)
	end
  when 6
  #player is facing right
	#try going left
	if playerPassable?($game_player.x-1, $game_player.y, 4) && movedDir <= 0
		pbMoveRoute($game_player, [PBMoveRoute::Left], true)
		movedDir = 4
		pbMoveRoute($game_player, [PBMoveRoute::TurnRight], true)
	end
	#try going down
	if playerPassable?($game_player.x, $game_player.y+1, 2) && movedDir <= 0
		pbMoveRoute($game_player, [PBMoveRoute::Down], true)
		movedDir = 2
		pbMoveRoute($game_player, [PBMoveRoute::TurnUp], true)
	end
	#try going right
	if playerPassable?($game_player.x+1, $game_player.y, 6) && movedDir <= 0
		pbMoveRoute($game_player, [PBMoveRoute::Right], true)
		movedDir = 6
		pbMoveRoute($game_player, [PBMoveRoute::TurnLeft], true)
	end
	#try going up
	if playerPassable?($game_player.x, $game_player.y-1, 8) && movedDir <= 0
		pbMoveRoute($game_player, [PBMoveRoute::Up], true)
		movedDir = 8
		pbMoveRoute($game_player, [PBMoveRoute::TurnDown], true)
	end
  when 8
  #player is facing up
	#try going down
	if playerPassable?($game_player.x, $game_player.y+1, 2) && movedDir <= 0
		pbMoveRoute($game_player, [PBMoveRoute::Down], true)
		movedDir = 2
		pbMoveRoute($game_player, [PBMoveRoute::TurnUp], true)
	end
	#try going left
	if playerPassable?($game_player.x-1, $game_player.y, 4) && movedDir <= 0
		pbMoveRoute($game_player, [PBMoveRoute::Left], true)
		movedDir = 4
		pbMoveRoute($game_player, [PBMoveRoute::TurnRight], true)
	end
	#try going right
	if playerPassable?($game_player.x+1, $game_player.y, 6) && movedDir <= 0
		pbMoveRoute($game_player, [PBMoveRoute::Right], true)
		movedDir = 6
		pbMoveRoute($game_player, [PBMoveRoute::TurnLeft], true)
	end
	
  end #case $game_player.direction
  
  pbWait(Graphics.frame_rate / 5)
  pbTurnTowardEvent($game_player, FollowingPkmn.get_event)
  pbWait(Graphics.frame_rate / 5)
  
  case initialDir
  when 2
	#player's initial direction was down
	FollowingPkmn.move_route([PBMoveRoute::TurnDown])
  when 4
	#player's initial direction was left
	FollowingPkmn.move_route([PBMoveRoute::TurnLeft])
  when 6
	#player's initial direction was right
	FollowingPkmn.move_route([PBMoveRoute::TurnRight])
  when 8
	#player's initial direction was up
	FollowingPkmn.move_route([PBMoveRoute::TurnUp])
  end
  pbWait(Graphics.frame_rate / 5)
  case movedDir
  when 2
	#player moved down
	pbMoveRoute($game_player, [PBMoveRoute::TurnUp], true)
  when 4
	#player moved left
	pbMoveRoute($game_player, [PBMoveRoute::TurnRight], true)
  when 6
	#player moved right
	pbMoveRoute($game_player, [PBMoveRoute::TurnLeft], true)
  when 8
	#player moved up
	pbMoveRoute($game_player, [PBMoveRoute::TurnDown], true)
  end
  pbSEPlay("Player jump")
  FollowingPkmn.move_route([PBMoveRoute::Jump, 0, 0])
  pbWait(Graphics.frame_rate / 5)
  
  #added by Gardenette
  $PokemonGlobal.using_field_move = false
  
  return ret
end

#-------------------------------------------------------------------------------
# New sendout animation for Following Pokemon to slide in when sent out for
# the first time in battle. Toggleable.
#-------------------------------------------------------------------------------
class Battle::Scene::Animation::PokeballPlayerSendOut < Battle::Scene::Animation
  def initialize(sprites, viewport, idxTrainer, battler, startBattle, idxOrder=0)
    @idxTrainer     = idxTrainer
    @battler        = battler
    @showingTrainer = startBattle
    @idxOrder       = idxOrder
    @trainer        = @battler.battle.pbGetOwnerFromBattlerIndex(@battler.index)
    @shadowVisible  = sprites["shadow_#{battler.index}"].visible
    @sprites        = sprites
    @viewport       = viewport
    @pictureEx      = []   # For all the PictureEx
    @pictureSprites = []   # For all the sprites
    @tempSprites    = []   # For sprites that exist only for this animation
    @animDone       = false
    if FollowingPkmn.active? && startBattle &&
       battler.index == 0 && FollowingPkmn::SLIDE_INTO_BATTLE && !$Trainer.pokemon_party[0].fainted? #edited by Gardenette to accommodate for fainted followers
      createFollowerProcesses
    else
      createProcesses
    end
  end

  def createFollowerProcesses
    delay = 0
    delay = 5 if @showingTrainer
    batSprite = @sprites["pokemon_#{@battler.index}"]
    shaSprite = @sprites["shadow_#{@battler.index}"]
    battlerY = batSprite.y
    battler = addSprite(batSprite, PictureOrigin::BOTTOM)
    battler.setVisible(delay, true)
    battler.setZoomXY(delay, 100, 100)
    battler.setColor(delay, Color.new(0, 0, 0, 0))
    battler.setDelta(0, -240, 0)
    battler.moveDelta(delay, 12, 240, 0)
    battler.setCallback(delay + 12, [batSprite,:pbPlayIntroAnimation])
    if @shadowVisible
      shadow = addSprite(shaSprite, PictureOrigin::CENTER)
      shadow.setVisible(delay, @shadowVisible)
      shadow.setDelta(0, -Graphics.width/2, 0)
      shadow.setDelta(delay, 12, Graphics.width/2, 0)
    end
  end
end

#-------------------------------------------------------------------------------
# Tiny fix for emote Animations not playing in v20 since people are unable to
# read instructions and can't close RMXP before adding the Following Pokemon
# EX emote animations
#-------------------------------------------------------------------------------
class SpriteAnimation
  def effect?; return @_animation_duration > 0 if @_animation_duration; end
end
