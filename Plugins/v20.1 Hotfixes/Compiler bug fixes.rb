#===============================================================================
# "v20.1 Hotfixes" plugin
# This file contains fixes for bugs in the Compiler in Essentials v20.1.
# These bug fixes are also in the dev branch of the GitHub version of
# Essentials:
# https://github.com/Maruno17/pokemon-essentials
#===============================================================================

#===============================================================================
# Fixed crash when the Compiler rewrites a door event.
#===============================================================================
module Compiler
  module_function

  def update_door_event(event, mapData)
    changed = false
    return false if event.is_a?(RPG::CommonEvent)
    # Check if event has 2+ pages and the last page meets all of these criteria:
    #   - Has a condition of a Switch being ON
    #   - The event has a charset graphic
    #   - There are more than 5 commands in that page, the first of which is a
    #     Conditional Branch
    lastPage = event.pages[event.pages.length - 1]
    if event.pages.length >= 2 &&
       lastPage.condition.switch1_valid &&
       lastPage.graphic.character_name != "" &&
       lastPage.list.length > 5 &&
       lastPage.list[0].code == 111
      # This bit of code is just in case Switch 22 has been renamed/repurposed,
      # which is highly unlikely. It changes the Switch used in the condition to
      # whichever is named 's:tsOff?("A")'.
      if lastPage.condition.switch1_id == 22 &&
         mapData.switchName(lastPage.condition.switch1_id) != 's:tsOff?("A")'
        lastPage.condition.switch1_id = mapData.registerSwitch('s:tsOff?("A")')
        changed = true
      end
      # If the last page's Switch condition uses a Switch named 's:tsOff?("A")',
      # check the penultimate page. If it contains exactly 1 "Transfer Player"
      # command and does NOT contain a "Change Transparent Flag" command, rewrite
      # both the penultimate page and the last page.
      if mapData.switchName(lastPage.condition.switch1_id) == 's:tsOff?("A")'
        list = event.pages[event.pages.length - 2].list
        transferCommand = list.find_all { |cmd| cmd.code == 201 }   # Transfer Player
        if transferCommand.length == 1 && list.none? { |cmd| cmd.code == 208 }   # Change Transparent Flag
          # Rewrite penultimate page
          list.clear
          push_move_route_and_wait(   # Move Route for door opening
            list, 0,
            [PBMoveRoute::PlaySE, RPG::AudioFile.new("Door enter"), PBMoveRoute::Wait, 2,
             PBMoveRoute::TurnLeft, PBMoveRoute::Wait, 2,
             PBMoveRoute::TurnRight, PBMoveRoute::Wait, 2,
             PBMoveRoute::TurnUp, PBMoveRoute::Wait, 2]
          )
          push_move_route_and_wait(   # Move Route for player entering door
            list, -1,
            [PBMoveRoute::ThroughOn, PBMoveRoute::Up, PBMoveRoute::ThroughOff]
          )
          push_event(list, 208, [0])   # Change Transparent Flag (invisible)
          push_script(list, "Followers.follow_into_door")
          push_event(list, 210, [])   # Wait for Move's Completion
          push_move_route_and_wait(   # Move Route for door closing
            list, 0,
            [PBMoveRoute::Wait, 2,
             PBMoveRoute::TurnRight, PBMoveRoute::Wait, 2,
             PBMoveRoute::TurnLeft, PBMoveRoute::Wait, 2,
             PBMoveRoute::TurnDown, PBMoveRoute::Wait, 2]
          )
          push_event(list, 223, [Tone.new(-255, -255, -255), 6])   # Change Screen Color Tone
          push_wait(list, 8)   # Wait
          push_event(list, 208, [1])   # Change Transparent Flag (visible)
          push_event(list, transferCommand[0].code, transferCommand[0].parameters)   # Transfer Player
          push_event(list, 223, [Tone.new(0, 0, 0), 6])   # Change Screen Color Tone
          push_end(list)
          # Rewrite last page
          list = lastPage.list
          list.clear
          push_branch(list, "get_self.onEvent?")   # Conditional Branch
          push_event(list, 208, [0], 1)   # Change Transparent Flag (invisible)
          push_script(list, "Followers.hide_followers", 1)
          push_move_route_and_wait(   # Move Route for setting door to open
            list, 0,
            [PBMoveRoute::TurnLeft, PBMoveRoute::Wait, 6],
            1
          )
          push_event(list, 208, [1], 1)   # Change Transparent Flag (visible)
          push_move_route_and_wait(list, -1, [PBMoveRoute::Down], 1)   # Move Route for player exiting door
          push_script(list, "Followers.put_followers_on_player", 1)
          push_move_route_and_wait(   # Move Route for door closing
            list, 0,
            [PBMoveRoute::TurnUp, PBMoveRoute::Wait, 2,
             PBMoveRoute::TurnRight, PBMoveRoute::Wait, 2,
             PBMoveRoute::TurnDown, PBMoveRoute::Wait, 2],
            1
          )
          push_branch_end(list, 1)
          push_script(list, "setTempSwitchOn(\"A\")")
          push_end(list)
          changed = true
        end
      end
    end
    return changed
  end
end