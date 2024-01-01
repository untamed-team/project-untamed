#-------------------------------------------------------------------------------
# Step On Spot v1.0 by Boonzeet
#-------------------------------------------------------------------------------
# Makes a character or the player step on the spot, for cutscene animations.
#-------------------------------------------------------------------------------
# To use, either call event.step_on_spot with an event object, or from a script
# tag use pbStepOnSpot(eventID) for events or pbStepOnSpot for player.
#-------------------------------------------------------------------------------
PluginManager.register({
  :name => "Step On Spot",
  :version => "1.0",
  :credits => "Boonzeet",
  :link => "https://reliccastle.com/resources/648/"
})
class Game_Character
  def step_on_spot
    oldpattern = self.pattern
    frames = [0,1,1,0]
    4.times do |frame|
      self.pattern = frames[frame]
      4.times do
        Graphics.update
        Input.update
        pbUpdateSceneMap
      end
    end
    self.pattern = oldpattern
  end
end
def pbStepOnSpot(eventID=nil)
  if (eventID == nil)
    event = $game_player
  else
    return if eventID > $game_map.events.size
    event = $game_map.events[eventID]
    return if event == nil
  end
  event.step_on_spot
end