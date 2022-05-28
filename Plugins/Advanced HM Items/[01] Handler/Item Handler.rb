#===========================================
# Utility                       
#===========================================

class MoveHandlerHash
  def delete(sym)
    @hash.delete(sym) if sym && @hash[sym]
  end
end
  
def pbCheckForBadge(badge)
  return true if badge - 1 < 0
  return true if $Trainer.badges[badge - 1]
  return false
end

def pbCheckForSwitch(switches)
  return true if switches.length <= 0
  switches.each { |switch|
    if !$game_switches[switch]
      return false
    end
  }
  return true
end

def pbCanUseItem(item)
  if item[:use_in_debug]
    return true if $DEBUG
  end
  if $PokemonBag.pbHasItem?(item[:internal_name]) && 
     pbCheckForBadge(item[:needed_badge]) && 
     pbCheckForSwitch(item[:needed_switches])
    return true
  end
  return false
end

Item_RockSmash = AdvancedHMItems::ROCKSMASH_CONFIG
Item_Cut = AdvancedHMItems::CUT_CONFIG
Item_Strength = AdvancedHMItems::STRENGTH_CONFIG
Item_Surf = AdvancedHMItems::SURF_CONFIG
Item_Fly = AdvancedHMItems::FLY_CONFIG
Item_Headbutt = AdvancedHMItems::HEADBUTT_CONFIG
Item_Flash = AdvancedHMItems::FLASH_CONFIG
  
#===========================================
# Rock Smash                         
#===========================================
  
if Item_RockSmash[:active]

  HiddenMoveHandlers::CanUseMove.delete(:ROCKSMASH)
  HiddenMoveHandlers::UseMove.delete(:ROCKSMASH)

  def pbRockSmash
    if !pbCanUseItem(Item_RockSmash)
      pbMessage(_INTL("It's a rugged rock, but an item may be able to smash it."))
      return false
    end
    item_name = GameData::Item.get(Item_RockSmash[:internal_name]).name
    if pbConfirmMessage(_INTL("This rock appears to be breakable. Would you like to use the {1}?", item_name))
      pbMessage(_INTL("{1} used the {2}!", $Trainer.name, item_name))
      return true
    end
    return false
  end
  
  ItemHandlers::UseFromBag.add(Item_RockSmash[:internal_name], proc do |item|
    facingEvent = $game_player.pbFacingEvent
    if facingEvent && facingEvent.name[/smashrock/i] && pbCanUseItem(Item_RockSmash)
      next 2
    end
    pbMessage(_INTL("I can't use this now!"))
    next 0
  end)

  ItemHandlers::UseInField.add(Item_RockSmash[:internal_name], proc do |item|
    $game_player.pbFacingEvent.start
    next 1
  end)

end
  
#===========================================
# Cut                         
#===========================================
 
if Item_Cut[:active]

  HiddenMoveHandlers::CanUseMove.delete(:CUT)
  HiddenMoveHandlers::UseMove.delete(:CUT)

  def pbCut
    if !pbCanUseItem(Item_Cut)
      pbMessage(_INTL("This tree looks like it can be cut down."))
      return false
    end
    pbMessage(_INTL("This tree looks like it can be cut down!\1"))
    if pbConfirmMessage(_INTL("Would you like to cut it?"))
      item_name = GameData::Item.get(Item_Cut[:internal_name]).name
      pbMessage(_INTL("{1} used the {2}!", $Trainer.name, item_name))
      return true
    end
    return false
  end

  ItemHandlers::UseFromBag.add(Item_Cut[:internal_name], proc do |item|
    facingEvent = $game_player.pbFacingEvent
    if facingEvent && facingEvent.name[/cuttree/i] && pbCanUseItem(Item_Cut)
      next 2
    end
    pbMessage(_INTL("I can't use this now!"))
    next 0
  end)

  ItemHandlers::UseInField.add(Item_Cut[:internal_name], proc do |item| 
    $game_player.pbFacingEvent.start
    next 1 
  end)
end
  
#===========================================
# Strength                        
#===========================================

if Item_Strength[:active]

  HiddenMoveHandlers::CanUseMove.delete(:STRENGTH)
  HiddenMoveHandlers::UseMove.delete(:STRENGTH)

  def pbStrength
    if $PokemonMap.strengthUsed
      item_name = GameData::Item.get(Item_Strength[:internal_name]).name
      pbMessage(_INTL("The {1} made it possible to move boulders around!", item_name))
      return false
    end
    if !pbCanUseItem(Item_Strength)
      pbMessage(_INTL("It's a big boulder, but an item may be able to push it aside."))
      return false
    end
    item_name = GameData::Item.get(Item_Strength[:internal_name]).name
    pbMessage(_INTL("It's a big boulder, but an item may be able to push it aside.\1"))
    if pbConfirmMessage(_INTL("Would you like to use the {1}?", item_name))
      pbMessage(_INTL("{1} used the {2}!", $Trainer.name, item_name))
      pbMessage(_INTL("The {1} made it possible to move boulders around!", item_name))
      $PokemonMap.strengthUsed = true
      return true
    end
    return false
  end

  ItemHandlers::UseFromBag.add(Item_Strength[:internal_name], proc do |item|
    if $PokemonMap.strengthUsed
      item_name = GameData::Item.get(Item_Strength[:internal_name]).name
      pbMessage(_INTL("The {1} were already used!", item_name))
      next 0
    end
    facingEvent = $game_player.pbFacingEvent
    if facingEvent && facingEvent.name[/strengthboulder/i] && pbCanUseItem(Item_Strength)
      next 2
    end
    pbMessage(_INTL("I can't use this now!"))
    next 0
  end)

  ItemHandlers::UseInField.add(Item_Strength[:internal_name], proc do |item|
    pbStrength
    next 1
  end)
end

#===========================================
# Surf                        
#===========================================

if Item_Surf[:active]

  HiddenMoveHandlers::CanUseMove.delete(:SURF)
  HiddenMoveHandlers::UseMove.delete(:SURF)

    def pbSurf
      return false if $game_player.pbFacingEvent
      return false if $game_player.pbHasDependentEvents?
      if !pbCanUseItem(Item_Surf)
        return false
      end
      if pbConfirmMessage(_INTL("The water is a deep blue...\nWould you like to surf on it?"))
        pbMessage(_INTL("{1} used the {2}!", $Trainer.name, GameData::Item.get(Item_Surf[:internal_name]).name))
        pbCancelVehicles
        surfbgm = GameData::Metadata.get.surf_BGM
        pbCueBGM(surfbgm, 0.5) if surfbgm
        pbStartSurfing
        return true
      end
      return false
    end
  
    ItemHandlers::UseInField.add(Item_Surf[:internal_name], proc do |item|
      $game_temp.in_menu = false
      pbSurf
      next 1
    end)
  
    ItemHandlers::UseFromBag.add(Item_Surf[:internal_name], proc do |item|
      if !pbCanUseItem(Item_Surf)
        pbMessage(_INTL("I can't use this now!"))
        next 0
      end
      if $PokemonGlobal.surfing
        pbMessage(_INTL("You're already surfing."))
        next 0
      end
      if $game_player.pbHasDependentEvents?
        pbMessage(_INTL("It can't be used when you have someone with you."))
        next 0
      end
      if GameData::MapMetadata.exists?($game_map.map_id) && 
         GameData::MapMetadata.get($game_map.map_id).always_bicycle
        pbMessage(_INTL("Let's enjoy cycling!"))
        next 0
      end
      if !$game_player.pbFacingTerrainTag.can_surf_freely || 
         !$game_map.passable?($game_player.x, $game_player.y, $game_player.direction, $game_player)
        pbMessage(_INTL("No surfing here!"))
        next 0
      end
      next 2
    end)
end

#===========================================
# Fly                        
#===========================================

  if Item_Fly[:active]

    HiddenMoveHandlers::CanUseMove.delete(:FLY)
    HiddenMoveHandlers::UseMove.delete(:FLY)
  
    ItemHandlers::UseInField.add(Item_Fly[:internal_name], proc do |item|
      $game_temp.in_menu = false
      next 0 if !$PokemonTemp.flydata
      if !$PokemonTemp.flydata
        pbMessage(_INTL("Can't use that here."))
        next 0
      end
      pbMessage(_INTL("{1} used the {2}!", $Trainer.name, GameData::Item.get(Item_Fly[:internal_name]).name))
      pbFadeOutIn {
        $game_temp.player_new_map_id    = $PokemonTemp.flydata[0]
        $game_temp.player_new_x         = $PokemonTemp.flydata[1]
        $game_temp.player_new_y         = $PokemonTemp.flydata[2]
        $game_temp.player_new_direction = 2
        $PokemonTemp.flydata = nil
        $scene.transfer_player
        $game_map.autoplay
        $game_map.refresh
      }
      pbEraseEscapePoint
      next 1
    end)

    ItemHandlers::UseFromBag.add(Item_Fly[:internal_name], proc do |item|
      if !pbCanUseItem(Item_Fly)
        pbMessage(_INTL("I can't use this now!"))
        next 0
      end
      if $game_player.pbHasDependentEvents?
        pbMessage(_INTL("{1} can't be used when you have someone with you.", GameData::Item.get(Item_Fly[:internal_name]).name))
        next 0
      end
      if !GameData::MapMetadata.exists?($game_map.map_id) ||
        !GameData::MapMetadata.get($game_map.map_id).outdoor_map
       pbMessage(_INTL("Can't use that here."))
       next 0
      end
      ret = nil
      pbFadeOutIn(99999) {
        scene = PokemonRegionMap_Scene.new(-1, false)
        screen = PokemonRegionMapScreen.new(scene)
        ret = screen.pbStartFlyScreen
      }
      if ret
        $PokemonTemp.flydata = ret
        next 2
      end
      next 0
    end)
  end

#===========================================
# Headbutt                       
#===========================================

if Item_Headbutt[:active]

  HiddenMoveHandlers::CanUseMove.delete(:HEADBUTT)
  HiddenMoveHandlers::UseMove.delete(:HEADBUTT)

  def pbHeadbutt(event=nil)
    if !pbCanUseItem(Item_Headbutt)
      pbMessage(_INTL("A Pokémon could be in this tree. Maybe something could shake it."))
      return false
    end
    item_name = GameData::Item.get(Item_Headbutt[:internal_name]).name
    if pbConfirmMessage(_INTL("A Pokémon could be in this tree. Would you like to use {1}?", item_name))
      pbMessage(_INTL("{1} used the {2}!", $Trainer.name, item_name))
      pbHeadbuttEffect(event)
      return true
    end
    return false
  end

  ItemHandlers::UseInField.add(Item_Headbutt[:internal_name], proc do |item|
    pbMessage(_INTL("{1} used the {2}!", $Trainer.name, GameData::Item.get(Item_Headbutt[:internal_name]).name)) 
    facingEvent = $game_player.pbFacingEvent
    pbHeadbuttEffect(facingEvent)
    next 1 
  end)

  ItemHandlers::UseFromBag.add(Item_Headbutt[:internal_name], proc do |item|
    if !pbCanUseItem(Item_Headbutt)
      pbMessage(_INTL("I can't use this now!"))
      next 0  
    end
    facingEvent = $game_player.pbFacingEvent
    if !facingEvent || !facingEvent.name[/headbutttree/i]
      pbMessage(_INTL("Can't use that here."))
      next 0  
    end
    next 2
  end)
end

#===========================================
# Flash                      
#===========================================

if Item_Flash[:active]

  HiddenMoveHandlers::CanUseMove.delete(:FLASH)
  HiddenMoveHandlers::UseMove.delete(:FLASH) 
  
  ItemHandlers::UseInField.add(Item_Flash[:internal_name], proc do |item|
    darkness = $PokemonTemp.darknessSprite
    next 0 if !darkness || darkness.disposed?
    pbMessage(_INTL("{1} used the {2}!", $Trainer.name, GameData::Item.get(Item_Flash[:internal_name]).name)) 
    $PokemonGlobal.flashUsed = true
    radiusDiff = 8*20/Graphics.frame_rate
    while darkness.radius<darkness.radiusMax
      Graphics.update
      Input.update
      pbUpdateSceneMap
      darkness.radius += radiusDiff
      darkness.radius = darkness.radiusMax if darkness.radius>darkness.radiusMax
    end
    next 2
  end)

  ItemHandlers::UseFromBag.add(Item_Flash[:internal_name], proc do |item|
    if !pbCanUseItem(Item_Flash)
      pbMessage(_INTL("I can't use this now!"))
      next 0
    end
    if !GameData::MapMetadata.exists?($game_map.map_id) ||
       !GameData::MapMetadata.get($game_map.map_id).dark_map
      pbMessage(_INTL("Can't use that here."))
      next 0
    end
    if $PokemonGlobal.flashUsed
      pbMessage(_INTL("The {1} was already used.", GameData::Item.get(Item_Flash[:internal_name]).name))
      next 0
    end
    next 2
  end)
end