#Made by Gardenette
#class Game_Event < Game_Character
#attr_reader   :event #added by Gardenette to class Game_Event so we can access
#event pages

#this script was possible with help from Vendily, drago2308, and Black Mage

#######Using this system#######
#To specify the quests an NPC will have, use comments on the event's first page
#One quest per comment
#Comments should look like this:
#quest_marker Quest1 true true
#"quest_marker" tells the game this is a quest
#"questID" tells the game which quest the comment is about
#the first of two true/false statements tells the game whether this NPC is the
#quest giver and therefore should have an ! when the quest is ready to be given
#the second of two true/false statements tells the game whether this NPC is where
#the player will turn in the quest there and therefore should have a ? when the
#quest is ready to be turned in

#When you want to put an ! above an NPC's head, you need to ready the quest to
#signal the game that quest is ready to be given out
#Example:            readyQuest(:Quest1)
#This can be done whenever, like right when you start the game. For example, if
#you want quests 1, 5, 8, and 9 all to be available as soon as the player finds
#the NPC, you can ready those quests
#If you put :ReadyAtStart => true in the quest hash, it will automatically be
#marked as ready when a new game is started
#I would avoid flagging quest as ready if you plan to activate them during
#cutscenes, otherwise an ! will appear above the NPC's head during the cutscene

#When you want to activate a quest, use a conditional statement to make sure the
#quest is ready to be given out first
#Example:            getReadyQuests.include?(:Quest1)
#Unless you want to start a quest without displaying the ! over someone's head,
#which is reasonable

#When the player completes all the requirements to turn in a quest, you need to
#tell the game it is ready to be turned in so the NPC has a yellow/blue ? above
#them
#Example:            turninQuest(:Quest1)

#When you want to complete a quest, use a conditional statement to make sure the
#quest is ready to be turned in first
#Example:            getTurninQuests.include?(:Quest1)

class QuestIndicator
  def self.initialize
    #this will be used for putting the quest indicators on the screen
    
    #initialize the bobbing variables
    @bobStartY = 0
    @bobY = @bobStartY
    
    @timer = 0
    @bobDistance = 5
    @bobSpeed = 0.04
    
    #so we don't create multiple viewports and lose control over the previous
    #viewports
    @viewport.dispose if @viewport 
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @sprites = {}

    #get map events
    $game_map.events.values.each {|event|
      firstPage = event.event.pages[0]
      next if event.list == nil
      #for all commands on the event's first page, check for i
      for i in 0...firstPage.list.length - 1 #excludes the last command on the page, which is always blank
        if firstPage.list[i].code == 108 && firstPage.list[i].parameters[0].split[0] == 'quest_marker'
          #split the comment into different parameters. This splits by spaces
          questID = firstPage.list[i].parameters[0].split[1]
          giver   = firstPage.list[i].parameters[0].split[2]
          turnin  = firstPage.list[i].parameters[0].split[3]
        
          filename = nil
        
          if getReadyQuests.include?(questID.to_sym) && giver == "true"
            #the quest in the comment we are checking is active, and the NPC is the giver
            #show an ! if the NPC is the giver
              filename = "exclamation"
          end
        
          if getActiveQuests.include?(questID.to_sym) && turnin == "true"
            #the quest in the comment we are checking is active
            #show an ? if the NPC is the turnin
            filename = "inprogress"
          end
        
          if getTurninQuests.include?(questID.to_sym) && turnin == "true"
            #the quest in the comment we are checking is active
            #show an ? if the NPC is the turnin
              filename = "turnin"
          end
        
          if filename #if it's not nil, show ! or ?
            @event = $game_map.events[event.id]
        
            @sprites["icon_#{event}"] = ChangelingSprite.new(0, 0, @viewport)
            @sprites["icon_#{event}"].bitmap = Bitmap.new("Graphics/Pictures/QuestUI/"+filename)
        
            @sprites["icon_#{event}"].ox = @sprites["icon_#{event}"].bitmap.width / 2
            @sprites["icon_#{event}"].oy = (@sprites["icon_#{event}"].bitmap.height / 2) + 40
            @sprites["icon_#{event}"].opacity = 255
        
            #the conditional statement below keeps the icon above the event
            if (Object.const_defined?(:ScreenPosHelper) rescue false)
              @sprites["icon_#{event}"].x      = ScreenPosHelper.pbScreenX(@event)
              @sprites["icon_#{event}"].y      = ScreenPosHelper.pbScreenY(@event) - (@event.height * Game_Map::TILE_HEIGHT / 2) - @bobY
              @sprites["icon_#{event}"].zoom_x = ScreenPosHelper.pbScreenZoomX(@event)
              @sprites["icon_#{event}"].zoom_y = @sprites["icon_#{event}"].zoom_x
            else
              @sprites["icon_#{event}"].x = @event.screen_x
              @sprites["icon_#{event}"].y = @event.screen_y - (Game_Map::TILE_HEIGHT / 2) + @bobY
            end
            @sprites["icon_#{event}"].tone = $game_screen.tone
          end #end of if filename
          return if filename != nil #stop searching through quests if there is an active or ready quest for that NPC
        end #end of if firstPage.list[0].code == 108 && firstPage.list[0].parameters[0].split[0] == 'quest_marker'
      end
      
      } #end of $game_map.events.values.each {|event|
  end #of self.initialize
  
  def self.moveIndicator
    $game_map.events.values.each {|event|
      firstPage = event.event.pages[0]
      next if event.list == nil
      if firstPage.list[0].code == 108 && firstPage.list[0].parameters[0].split[0] == 'quest_marker'
        @event = $game_map.events[event.id]
        if @sprites["icon_#{event}"]
          @sprites["icon_#{event}"].ox = @sprites["icon_#{event}"].bitmap.width / 2
          @sprites["icon_#{event}"].oy = (@sprites["icon_#{event}"].bitmap.height / 2) + 40
          @sprites["icon_#{event}"].opacity = 255
        
          #the conditional statement below keeps the icon above the event
          if (Object.const_defined?(:ScreenPosHelper) rescue false)
            @sprites["icon_#{event}"].x      = ScreenPosHelper.pbScreenX(@event)
            @sprites["icon_#{event}"].y      = ScreenPosHelper.pbScreenY(@event) - (@event.height * Game_Map::TILE_HEIGHT / 2) - @bobY
            @sprites["icon_#{event}"].zoom_x = ScreenPosHelper.pbScreenZoomX(@event)
            @sprites["icon_#{event}"].zoom_y = @sprites["icon_#{event}"].zoom_x
          else
            @sprites["icon_#{event}"].x = @event.screen_x
            @sprites["icon_#{event}"].y = @event.screen_y - (Game_Map::TILE_HEIGHT / 2) + @bobY
          end #if (Object.const_defined?(:ScreenPosHelper) rescue false)
          @sprites["icon_#{event}"].tone = $game_screen.tone
        end #if @sprites["icon_#{event}"]
      end #if firstPage.list[0].code == 108
    } #end of $game_map.events.values.each {|event|
    end
  
  def self.bobIndicator
    @timer += 1
    @bobY = @bobY = Math.sin(@timer * @bobSpeed) * @bobDistance
  end

  EventHandlers.add(:on_frame_update, :indicator_bob,
  proc {
    if !@sprites.empty?
      #update the bobbing of the quest indicators
      QuestIndicator.bobIndicator
      QuestIndicator.moveIndicator
    end
  })
  
end

EventHandlers.add(:on_new_spriteset_map, :add_quest_indicator,
  proc { 
    QuestIndicator.initialize
  }
)