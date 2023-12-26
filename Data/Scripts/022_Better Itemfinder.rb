#==============================================================================
# Better Itemfinder by Kotaro [v20.1]
# fuckin' weeb
#============================================================================== 
# Config   
# Set this to false if you don't want the player to spin and force stop for a
# bit when they walk over a hidden item 
FORCEWAIT = true
# set this to false if you don't want itemfinder and itemfinderoff to be 
# registered when only 1 of them is actually registered
REGISTERBOTHTOGETHER = true
#============================================================================== 
# Startup
#============================================================================== 
startupfinished = 'no'

def startup(startupfinished)
  x = 240
  y = 138 
  $arrowMap = ChangelingSprite.new(x,y,@viewport) 
  $arrowMap.addBitmap("down","Graphics/Pictures/BI/downArrow")
  $arrowMap.addBitmap("left","Graphics/Pictures/BI/leftArrow")
  $arrowMap.addBitmap("right","Graphics/Pictures/BI/rightArrow")
  $arrowMap.addBitmap("up","Graphics/Pictures/BI/upArrow")
  $arrowMap.addBitmap("no","Graphics/Pictures/BI/noItem")
  $arrowMap.addBitmap("none","Graphics/Pictures/BI/none")
  startupfinished.replace('yes')
end  
#============================================================================== 
# Method to track the Hidden Item
#============================================================================== 
def updateDirection(event)
  id=Settings::EXCLAMATION_ANIMATION_ID
  pbDayNightTint($arrowMap)    
  if !event
    $arrowMap.changeBitmap("no")
  else
    offsetX = event.x-$game_player.x
    offsetY = event.y-$game_player.y
    if offsetX==0 && offsetY==0   # Standing on the item, play exclamation mark + spin around
      $arrowMap.changeBitmap("none")
      $scene.spriteset.addUserAnimation(id,$game_player.x,$game_player.y,true,2)
      if FORCEWAIT == true
        4.times do
          pbWait(Graphics.frame_rate*1/10)
          $game_player.turn_right_90
        end
        pbWait(Graphics.frame_rate*2/10) 
      end  
    else   # Item is nearby, create the arrow to locate it
      direction = $game_player.direction
      if offsetX.abs>offsetY.abs
        direction = (offsetX<0) ? 4 : 6
      else
        direction = (offsetY<0) ? 8 : 2
      end
      case direction
      when 2 then $arrowMap.changeBitmap("down")
      when 4 then $arrowMap.changeBitmap("left")
      when 6 then $arrowMap.changeBitmap("right")
      when 8 then $arrowMap.changeBitmap("up")
      end
    end
  end
end  
#============================================================================== 
# Methods to disable BI or Refresh/Update it
#============================================================================== 
def bIdisable
  if $arrowMap
    $arrowMap.changeBitmap("none") 
  end  
end

def bIrefresh
  if $arrowMap
    updateDirection(pbClosestHiddenItem) 
  end  
end  
#============================================================================== 
# Utility Method which registers both itemfinders at once
#============================================================================== 
def registerboth
  if $bag.registered?(:ITEMFINDER)
    $bag.register(:ITEMFINDEROFF) 
  elsif $bag.registered?(:ITEMFINDEROFF)
    $bag.register(:ITEMFINDER)
  end
end 
#============================================================================== 
# Overrides of existing methods
#============================================================================== 
class Interpreter
  attr_reader :startupfinished
  def command_210
    @move_route_waiting = true if !$game_temp.in_battle
    bIdisable
    return true
  end
end  

def pbItemBall(item, quantity = 1)
  item = GameData::Item.get(item)
  return false if !item || quantity < 1
  itemname = (quantity > 1) ? item.name_plural : item.name
  pocket = item.pocket
  move = item.move
  #updateDirection
  if $bag.add(item, quantity)   # If item can be picked up
    meName = (item.is_key_item?) ? "Key item get" : "Item get"
    if item == :LEFTOVERS
      pbMessage(_INTL("\\me[{1}]You found some \\c[1]{2}\\c[0]!\\wtnp[30]", meName, itemname))
    elsif item == :DNASPLICERS
      pbMessage(_INTL("\\me[{1}]You found \\c[1]{2}\\c[0]!\\wtnp[30]", meName, itemname))
    elsif item.is_machine?   # TM or HM
      pbMessage(_INTL("\\me[{1}]You found \\c[1]{2} {3}\\c[0]!\\wtnp[30]", meName, itemname, GameData::Move.get(move).name))
    elsif quantity > 1
      pbMessage(_INTL("\\me[{1}]You found {2} \\c[1]{3}\\c[0]!\\wtnp[30]", meName, quantity, itemname))
    elsif itemname.starts_with_vowel?
      pbMessage(_INTL("\\me[{1}]You found an \\c[1]{2}\\c[0]!\\wtnp[30]", meName, itemname))
    elsif item == :CROPMASTERPLANS
      pbMessage(_INTL("\\me[{1}]You found the \\c[1]{2}\\c[0]!\\wtnp[30]", meName, itemname))
    else
      pbMessage(_INTL("\\me[{1}]You found a \\c[1]{2}\\c[0]!\\wtnp[30]", meName, itemname))
    end
    pbMessage(_INTL("You put the {1} in\\nyour Bag's <icon=bagPocket{2}>\\c[1]{3}\\c[0] pocket.",
                    itemname, pocket, PokemonBag.pocket_names[pocket - 1]))
    event = pbClosestHiddenItem
    #~ event = event.update #by low
    if $arrowMap
      updateDirection(event)
    end
    
    #increment achievements
    Achievements.incrementProgress("ITEM_BALL_ITEMS",1)
  
    #Item Descriptions
    $item_log.register(item)
    
    return true
  end
  # Can't add the item
  if item == :LEFTOVERS
    pbMessage(_INTL("You found some \\c[1]{1}\\c[0]!\\wtnp[30]", itemname))
  elsif item.is_machine?   # TM or HM
    pbMessage(_INTL("You found \\c[1]{1} {2}\\c[0]!\\wtnp[30]", itemname, GameData::Move.get(move).name))
  elsif quantity > 1
    pbMessage(_INTL("You found {1} \\c[1]{2}\\c[0]!\\wtnp[30]", quantity, itemname))
  elsif itemname.starts_with_vowel?
    pbMessage(_INTL("You found an \\c[1]{1}\\c[0]!\\wtnp[30]", itemname))
  else
    pbMessage(_INTL("You found a \\c[1]{1}\\c[0]!\\wtnp[30]", itemname))
  end
  pbMessage(_INTL("But your Bag is full..."))
  return false
end
#============================================================================== 
# ItemHandlers
#============================================================================== 
ItemHandlers::UseInField.add(:ITEMFINDER,proc { |item|
    $bag.replace_item(:ITEMFINDER,:ITEMFINDEROFF)
    $arrowMap.visible = false
    startupfinished.replace('no')
    pbMessage(_INTL("The Item Finder was turned off."))
    next 1
})  

ItemHandlers::UseInField.add(:ITEMFINDEROFF,proc { |item|
    $bag.replace_item(:ITEMFINDEROFF,:ITEMFINDER)
    pbMessage(_INTL("The Item Finder was turned on."))
    startup(startupfinished)
    updateDirection(pbClosestHiddenItem)
    next 1
})
#============================================================================== 
# EventHandlers
#============================================================================== 
EventHandlers.add(:on_player_step_taken,:betterItemFinderTrigger,
	proc {
    if REGISTERBOTHTOGETHER == true
      registerboth
    end  
		if (GameData::Item.exists?(:ITEMFINDER) && $bag.has?(:ITEMFINDER) && startupfinished == 'no')
		  startup(startupfinished)
      if startupfinished == 'yes'
        updateDirection(pbClosestHiddenItem)
      end  
		elsif (GameData::Item.exists?(:ITEMFINDER) && $bag.has?(:ITEMFINDER) && startupfinished == 'yes')
      updateDirection(pbClosestHiddenItem)
		end 
	}
)

EventHandlers.add(:on_map_or_spriteset_change,:betterItemFinderTrigger,
	proc {
		if (GameData::Item.exists?(:ITEMFINDER) && $bag.has?(:ITEMFINDER) && startupfinished == 'no')
		  startup(startupfinished)
      if startupfinished == 'yes'
        updateDirection(pbClosestHiddenItem)
      end  
		elsif (GameData::Item.exists?(:ITEMFINDER) && $bag.has?(:ITEMFINDER) && startupfinished == 'yes')
      updateDirection(pbClosestHiddenItem) 
		end 
	}
)
#==============================================================================