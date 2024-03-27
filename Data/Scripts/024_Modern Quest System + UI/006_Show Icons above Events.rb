#Made by Gardenette
#class Game_Event < Game_Character
#attr_reader   :event #added by Gardenette to class Game_Event so we can access
#event pages

#this script was possible with help from Vendily, drago2308, and Black Mage

#######Using this system#######
#To specify the quests an NPC will have, use comments on the event's first page
#One quest per comment
#Comments should look like this:
#quest_marker Quest1 true 1
#"quest_marker" tells the game this is a quest
#"questID" tells the game which quest the comment is about. This should not be a symbol iwth ':' in front
#the true/false statement tells the game whether this NPC is the
#quest giver and therefore should have an ! when the quest is ready to be given
#the number at the end of the statement tells the game whether this NPC is where
#the player will turn in the quest once the requirements are met
#when you flag the quest for "turnin", the NPC should have a yellow ? above their head
#The number itself signifies 'stage 1', and this is used when you have the plugin automatically detect
#when the quest can be turned in at its stage
#alternatively if you are going to have the same NPC be the turnin location for all stages of the quest, you can leave this number out
#Example: quest_marker Quest1 true

#When you want to put an ! above an NPC's head, you need to ready the quest to
#signal the game that quest is ready to be given out
#Example:            readyQuest(:Quest1)
#This can be done whenever, like right when you start the game. For example, if
#you want quests 1, 5, 8, and 9 all to be available as soon as the player finds
#the NPC, you can ready those quests
#If you put :ReadyAtStart => true in the quest hash, it will automatically be
#marked as ready when you run this line of code:
#Player_Quests.readyQuestsAtStart
#I recommend running this code at the start of your game.
#I would avoid flagging quest as ready if you plan to activate them during
#cutscenes, otherwise an ! will appear above the NPC's head during the cutscene

#When you want to activate a quest, use a conditional statement to make sure the
#quest is ready to be given out first
#Example:            getReadyQuests.include?(:Quest1)
#Unless you want to start a quest without displaying the ! over someone's head,
#which is reasonable
#Example:
#if getReadyQuests.include?(:Quest1)
#"I have a quest for you!"
#else
#"Come back later, and I might have something for you to do."

#When the player completes all the requirements to turn in a quest, you need to
#tell the game it is ready to be turned in so the NPC has a yellow ? above
#them
#Example:            turninQuest(:Quest1)

#When you want to complete a quest, use a conditional statement to make sure the
#quest is ready to be turned in first
#Example:
#if getTurninQuests.include?(:Quest1)
#"You did it! Thanks!"
#else
#"I'm waiting for you to finish my quest."

#to hide indicators like during a cutscene, run QuestIndicator.hideIndicators
#to show indicators after hiding them, run QuestIndicator.showIndicators

class Game_Event < Game_Character
	attr_reader   :event
end

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
      #for all commands on the event's first page, check for a quest_marker comment
      for i in 0...firstPage.list.length - 1 #excludes the last command on the page, which is always blank
        if firstPage.list[i].code == 108 && firstPage.list[i].parameters[0].split[0] == 'quest_marker'

			#quest_marker Quest1 giver? turninStage taskForStage#
			#Example: quest_marker Quest1 true 1 1

          #split the comment into different parameters. This splits by spaces
          questID = firstPage.list[i].parameters[0].split[1]
          giver   = firstPage.list[i].parameters[0].split[2]
          turninStage = firstPage.list[i].parameters[0].split[3]
          taskForStage = firstPage.list[i].parameters[0].split[4]
          currentStage = getCurrentStage(questID.to_sym)
        
          filename = nil
		
		  if getReadyQuests.include?(questID.to_sym) && giver == "true"
            #the quest in the comment we are checking is active, and the NPC is the giver
            #show an ! if the NPC is the giver
            filename = "exclamation"
          end
		
          if getActiveQuests.include?(questID.to_sym) && (turninStage == currentStage.to_s || turninStage.nil?)
            #the quest in the comment we are checking is active
            #show an ? if the NPC is the turnin
            filename = "inprogress"
          end
		  
          #is this event the place you need to go to complete the stage before turning it in? (is this event the "task"?)
          if getActiveQuests.include?(questID.to_sym) && taskForStage.to_s == currentStage.to_s
                #the quest in the comment we are checking is active
                #show a ? if the NPC is the turnin
                filename = "turnin"
          end
        
          if getTurninQuests.include?(questID.to_sym) && (turninStage == currentStage.to_s || turninStage.nil?)
            #the quest in the comment we are checking is active
            #show an ? if the NPC is the turnin
              filename = "turnin"
          end
		  
          if getTurninQuests.include?(questID.to_sym) && taskForStage.to_s == currentStage.to_s
                  #if a quest is ready for turnin, get rid of the icon above the event that's the stage's task
            filename = nil
          end
          
          if filename #if it's not nil, show ! or ?
            @event = $game_map.events[event.id]
            @sprites["icon_#{event}"] = ChangelingSprite.new(0, 0, @viewport) if !@sprites["icon_#{event}"]
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
			
			      case @indicatorVisible
			      when true
				      @sprites["icon_#{event}"].visible = true
			      when false
				      @sprites["icon_#{event}"].visible = false
			      end

          end #end of if filename
          
          next if filename == "turnin" #prioritize showing a quest is ready for turn in when the NPC has multiple quests
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
  
  def self.hideIndicators
	@indicatorVisible = false
	QuestIndicator.initialize
  end #def self.hideIndicators
  
  def self.showIndicators
	@indicatorVisible = true
	QuestIndicator.initialize
  end #def self.showIndicators

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

EventHandlers.add(:on_frame_update, :check_if_turnincondition_met,
proc {
  for i in 0...$PokemonGlobal.quests.active_quests.length
    quest = $PokemonGlobal.quests.active_quests[i]
    activeStage = quest.stage
    next if $quest_data.getStageTurninCondition(quest.id.to_sym, activeStage).nil? #go to next quest if there is no condition for this quest's active stage

    #turnin the quest if current stage's condition is met
    if !getTurninQuests.include?(quest.id.to_sym) && $quest_data.getStageTurninCondition(quest.id.to_sym, activeStage).call
      turninQuest(quest.id.to_sym)
    end

    #remove the quest from turn in if the current stage's condition is not met any more
    if getTurninQuests.include?(quest.id.to_sym) && !$quest_data.getStageTurninCondition(quest.id.to_sym, activeStage).call
      removeTurninQuest(quest.id.to_sym)
    end
  end #for i in all active quests
})