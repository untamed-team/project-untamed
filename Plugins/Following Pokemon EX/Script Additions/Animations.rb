#-------------------------------------------------------------------------------
# New animation to show the Following Pokemon execcuting a field move in the
# overworld
#-------------------------------------------------------------------------------
alias __followingpkmn__pbHiddenMoveAnimation pbHiddenMoveAnimation unless defined?(__followingpkmn__pbHiddenMoveAnimation)
def pbHiddenMoveAnimation(pokemon, field_move = false)
  no_field_move = !field_move || $game_temp.no_follower_field_move
  FollowingPkmn.move_route([PBMoveRoute::Wait, 60]) if pokemon && FollowingPkmn.active?
  ret = __followingpkmn__pbHiddenMoveAnimation(pokemon)
  return ret if !ret || no_field_move || !FollowingPkmn.active? || pokemon != FollowingPkmn.get_pokemon
  initial_dir  = $game_player.direction
  pbTurnTowardEvent(FollowingPkmn.get_event, $game_player)
  pbWait(Graphics.frame_rate / 5)
  moved_dir    = 0
  possible_dir = []
  possible_dir.push($game_player.direction)
  possible_dir.push(10 - $game_player.direction)
  [2, 8, 4, 6].each { |d| possible_dir.push(d) if !possible_dir.include?(d) }
  possible_dir.each do |d|
    next if !$game_player.passable?($game_player.x, $game_player.y, 10 - d)
    moved_dir = 10 - d
    break
  end 
  if moved_dir > 0
    FollowingPkmn.get_event.move_toward_player
    pbMoveRoute($game_player, [(moved_dir) / 2], true)
    pbWait(Graphics.frame_rate / 4)
    pbTurnTowardEvent($game_player, FollowingPkmn.get_event)
    pbWait(Graphics.frame_rate / 4)
    FollowingPkmn.move_route([15 + (initial_dir / 2)])
    pbWait(Graphics.frame_rate / 5)
  end
  pbSEPlay("Player jump")
  FollowingPkmn.move_route([PBMoveRoute::JUMP, 0, 0])
  pbWait(Graphics.frame_rate / 5)
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
       battler.index == 0 && FollowingPkmn::SLIDE_INTO_BATTLE
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