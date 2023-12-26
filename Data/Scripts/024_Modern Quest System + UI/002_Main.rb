#===============================================================================
# This class holds the information for an individual quest
#===============================================================================
class Quest
  attr_accessor :id
  attr_accessor :stage
  attr_accessor :time
  attr_accessor :location
  attr_accessor :new
  attr_accessor :color
  attr_accessor :story
  #added by Space
  attr_accessor :tasks

  def initialize(id,color,story)
    self.id       = id
    self.stage    = 1
    self.time     = Time.now
    self.location = $game_map.name
    self.new      = true
    self.color    = color
    self.story    = story
    self.tasks    = $quest_data.getQuestTasks(self.id)
  end
  
  def stage=(value)
    if value > $quest_data.getMaxStagesForQuest(self.id)
      value = $quest_data.getMaxStagesForQuest(self.id)
    end
    @stage = value
  end
  
  #added by Space
  # Sets a task to complete (true) or incomplete (false)
  # THIS SHOULD ONLY BE USED ON ACTIVE QUESTS
  # If this is used directly on the Quest Data, not only will 
  # the change not be displayed, but it will not be retained 
  # when the player saves and relaunches the game
  def markTask(task,completed=true)
    # Input the task's number when using the method, not its index
    self.tasks[task-1][2] = completed
  end
  
  # Returns the string output of the tasks for the current stage
  # Yes, this is a duplicate method
  def getStageTaskString()
    arr = []
    for i in self.tasks
      arr.push(i) if i[1] == self.stage
    end
    if arr.length == 0
      #return "\nNo sub-tasks for this stage."
      return #"\nNo sub-tasks for this stage."
    end
    ret = ""
    for t in arr
      ret = ret + "\n" + t[0] + ": " + (t[2] ? "<c2=#{colorQuest("green")}>Complete" : "<c2=#{colorQuest("red")}>Incomplete") + "</c2>"
    end
    return ret
  end
  #end of what Space added
  
end

#===============================================================================
# This class holds all the trainers quests
#===============================================================================
class Player_Quests
  attr_accessor :active_quests
  attr_accessor :completed_quests
  attr_accessor :failed_quests
  attr_accessor :selected_quest_id
  attr_accessor :ready_quests #added by Gardenette
  attr_accessor :turnin_quests #added by Gardenette
  
  def initialize
    @ready_quests      = [] #added by Gardenette
    @active_quests     = []
    @turnin_quests     = [] #added by Gardenette
    @completed_quests  = []
    @failed_quests     = []
    @selected_quest_id = 0
  end
  
  def self.numOfQuests
    i = 1
    loop do
      quest = "Quest"+i.to_s
      if QuestModule.const_defined?(quest.to_s)
        i += 1
      else
        break
      end
    end
    return i-1
  end
  
  #added by Gardenette
  def self.readyQuestsAtStart
    #readyQuest(:Quest1)
    for i in 1..self.numOfQuests
      quest = "Quest"+i.to_s
      if QuestData.getReadyAtStart(quest) == "true"
        #print quest
        quest = quest.to_sym
        readyQuest(quest)
      end
    end
  end
  
  #added by Gardenette
  def deleteFromArray(value, array)
    position = nil
    for i in 0...array.length
      if array[i].id == value
        position = i
        break
      end
    end
    array.delete_at(position) if position != nil
  end
  
  #added by Gardenette
  # questID should be the symbolic name of the quest, e.g. :Quest1
  def readyQuest(quest,color,story)
    if !quest.is_a?(Symbol)
      raise _INTL("The 'quest' argument should be a symbol, e.g. ':Quest1'.")
      return
    end
    deleteFromArray(quest, @active_quests)
    deleteFromArray(quest, @turnin_quests)
    deleteFromArray(quest, @completed_quests)
    deleteFromArray(quest, @failed_quests)

    for i in 0...@ready_quests.length
      if @ready_quests[i].id == quest
        pbMessage("You have already readied this objective to be given out.")
        return
      end
    end
    @ready_quests.push(Quest.new(quest,color,story))
  end
  
  #added by Gardenette
  # questID should be the symbolic name of the quest, e.g. :Quest1
  def turninQuest(quest,color,story)
    if !quest.is_a?(Symbol)
      raise _INTL("The 'quest' argument should be a symbol, e.g. ':Quest1'.")
      return
    end
    
    deleteFromArray(quest, @ready_quests)
    deleteFromArray(quest, @completed_quests)
    deleteFromArray(quest, @failed_quests)
    
    for i in 0...@turnin_quests.length
      if @turnin_quests[i].id == quest
        pbMessage("You have already marked this objective as available for turn-in.")
        return
      end
    end
    @turnin_quests.push(Quest.new(quest,color,story))
    
    #refresh all icons above events
    QuestIndicator.initialize
  end
  
  # questID should be the symbolic name of the quest, e.g. :Quest1
  def activateQuest(quest,color,story)
    if !quest.is_a?(Symbol)
      raise _INTL("The 'quest' argument should be a symbol, e.g. ':Quest1'.")
    end
    
    deleteFromArray(quest, @ready_quests)
    deleteFromArray(quest, @completed_quests)
    deleteFromArray(quest, @failed_quests)
    deleteFromArray(quest, @turnin_quests)
    
    for i in 0...@active_quests.length
      if @active_quests[i].id == quest
        pbMessage("You have already started this objective.")
        return
      end
    end
    @active_quests.push(Quest.new(quest,color,story))
    pbMessage(_INTL("\\se[{1}]<ac><c2=#{colorQuest("red")}>New objective discovered!</c2>\nCheck your objective list <icon=menuObjectives> in the menu for more details!</ac>",QUEST_JINGLE))
    #update quest indicators
    QuestIndicator.initialize
  end
  
  def failQuest(quest,color,story)
    if !quest.is_a?(Symbol)
      raise _INTL("The 'quest' argument should be a symbol, e.g. ':Quest1'.")
    end
    
    deleteFromArray(quest, @completed_quests)
    deleteFromArray(quest, @ready_quests)
    deleteFromArray(quest, @turnin_quests)
    deleteFromArray(quest, @failed_quests)
    
    found = false

    for i in 0...@failed_quests.length
      if @failed_quests[i].id == quest
        pbMessage("You have already failed this objective.")
        return
      end
    end
    for i in 0...@active_quests.length
      if @active_quests[i].id == quest
        temp_quest = @active_quests[i]
        temp_quest.color = color if color != nil
        temp_quest.new = true # Setting this back to true makes the "!" icon appear when the quest updates
        temp_quest.time = Time.now
        @failed_quests.push(temp_quest)
        @active_quests.delete_at(i)
        found = true
        pbMessage(_INTL("\\se[{1}]<ac><c2=#{colorQuest("red")}>Objective failed!</c2>\nYour objective list <icon=menuObjectives> in the menu has been updated!</ac>",QUEST_FAIL))
        break
      end
    end
    if !found
      color = colorQuest(nil) if color == nil
      @failed_quests.push(Quest.new(quest,color,story))
    end
    #update quest indicators
    QuestIndicator.initialize
  end
  
  def completeQuest(quest,color,story)
    if !quest.is_a?(Symbol)
      raise _INTL("The 'quest' argument should be a symbol, e.g. ':Quest1'.")
    end
    found = false
    
    deleteFromArray(quest, @ready_quests)
    deleteFromArray(quest, @turnin_quests)
    deleteFromArray(quest, @failed_quests)
    
    for i in 0...@failed_quests.length
      if @failed_quests[i].id == quest
        pbMessage("You have already failed this objective.")
        return
      end
    end
    for i in 0...@completed_quests.length
      if @completed_quests[i].id == quest
        pbMessage("You have already completed this objective.")
        return
      end
    end
    for i in 0...@active_quests.length
      if @active_quests[i].id == quest
        temp_quest = @active_quests[i]
        temp_quest.color = color if color != nil
        temp_quest.new = true # Setting this back to true makes the "!" icon appear in the menu when the quest updates
        temp_quest.time = Time.now
        @completed_quests.push(temp_quest)
        @active_quests.delete_at(i)
        found = true
        pbMessage(_INTL("\\se[{1}]<ac><c2=#{colorQuest("red")}>Objective completed!</c2>\nYour objective list <icon=menuObjectives> in the menu has been updated!</ac>",QUEST_JINGLE))
        break
      end
    end
    if !found
      color = colorQuest(nil) if color == nil
      @completed_quests.push(Quest.new(quest,color,story))
    end
    #update quest indicators
    QuestIndicator.initialize
  end
  
  def advanceQuestToStage(quest,stageNum,color,story)
    if !quest.is_a?(Symbol)
      raise _INTL("The 'quest' argument should be a symbol, e.g. ':Quest1'.")
    end
    found = false
    for i in 0...@active_quests.length
      if @active_quests[i].id == quest
        @active_quests[i].stage = stageNum
        @active_quests[i].color = color if color != nil
        @active_quests[i].new = true # Setting this back to true makes the "!" icon appear when the quest updates
        found = true
        pbMessage(_INTL("\\se[{1}]<ac><c2=#{colorQuest("red")}>New task added!</c2>\nYour objective list <icon=menuObjectives> in the menu has been updated!</ac>",QUEST_JINGLE))
      end
      return if found
    end
    if !found
      color = colorQuest(nil) if color == nil
      questNew = Quest.new(quest,color,story)
      questNew.stage = stageNum
      @active_quests.push(questNew)
    end
  end
  
  #added by Space
  def markQuestTaskComplete(quest,task,complete,color,story)
    if !quest.is_a?(Symbol)
      raise _INTL("The 'quest' argument should be a symbol, e.g. ':Quest1'.")
    end
    found = false
    for i in 0...@active_quests.length
      if @active_quests[i].id == quest
        @active_quests[i].markTask(task,complete)
        @active_quests[i].color = color if color != nil
        @active_quests[i].new = true # Setting this back to true makes the "!" icon appear when the quest updates
        found = true
        pbMessage(_INTL("\\se[{1}]<ac><c2=#{colorQuest("red")}>Task completed!</c2>\nYour objective list <icon=menuObjectives> in the menu has been updated!</ac>",QUEST_JINGLE))
      end
      return if found
    end
    if !found
      color = colorQuest(nil) if color == nil
      questNew = Quest.new(quest,color,story)
      questNew.markTask(taskNum,complete)
      @active_quests.push(questNew)
    end
  end
  #end of what space added
  
end

#===============================================================================
# Initiate quest data
#===============================================================================
class PokemonGlobalMetadata
#  attr_writer :quests

  def quests
    @quests = Player_Quests.new if !@quests
    return @quests
  end
  
  alias quest_init initialize
  def initialize
    quest_init
    @quests = Player_Quests.new
  end
end

#===============================================================================
# Helper and utility functions for managing quests
#===============================================================================

# Helper function for readying quests
# This is used by objective indicator system to put the ! above an event only
# when the quest is ready to be given
def readyQuest(quest,color=nil,story=nil)
  return if !$PokemonGlobal
  $PokemonGlobal.quests.readyQuest(quest,color,story)
end

# Helper function for readying quests
# This is used by objective indicator system to put the ! above an event only
# when the quest is ready to be given
def turninQuest(quest,color=nil,story=nil)
  return if !$PokemonGlobal
  $PokemonGlobal.quests.turninQuest(quest,color,story)
end

# Helper function for activating quests
def activateQuest(quest,color=colorQuest(nil),story=false)
  return if !$PokemonGlobal
  $PokemonGlobal.quests.activateQuest(quest,color,story)
end

# Helper function for marking quests as completed
def completeQuest(quest,color=nil,story=false)
  return if !$PokemonGlobal
  $PokemonGlobal.quests.completeQuest(quest,color,story)
end

# Helper function for marking quests as failed
def failQuest(quest,color=nil,story=false)
  return if !$PokemonGlobal
  $PokemonGlobal.quests.failQuest(quest,color,story)
end

# Helper function for advancing quests to given stage
def advanceQuestToStage(quest,stageNum,color=nil,story=false)
  return if !$PokemonGlobal
  $PokemonGlobal.quests.advanceQuestToStage(quest,stageNum,color,story)
end

#added by Space
# Helper function to mark a task as complete
def markQuestTaskComplete(quest,task,complete=true,color=nil,story=false)
  return if !$PokemonGlobal
  $PokemonGlobal.quests.markQuestTaskComplete(quest,task,complete,color,story)
end
#end of what Space added

def getReadyQuests
  ready = []
  $PokemonGlobal.quests.ready_quests.each do |s|
    ready.push(s.id)
  end
  return ready
end

def getTurninQuests
  turnin = []
  $PokemonGlobal.quests.turnin_quests.each do |s|
    turnin.push(s.id)
  end
  return turnin
end

# Get symbolic names of active quests
# Unused
def getActiveQuests
  active = []
  $PokemonGlobal.quests.active_quests.each do |s|
    active.push(s.id)
  end
  return active
end

# Get symbolic names of completed quests
# Unused
def getCompletedQuests
  completed = []
  $PokemonGlobal.quests.completed_quests.each do |s|
    completed.push(s.id)
  end
  return completed
end

# Get symbolic names of failed quests
# Unused
def getFailedQuests
  failed = []
  $PokemonGlobal.quests.failed_quests.each do |s|
    failed.push(s.id)
  end
  return failed
end

#===============================================================================
# Class that contains utility methods to return quest properties
#===============================================================================
class QuestData

  # Get ID number for quest
  def getID(quest)
    return "#{QuestModule.const_get(quest)[:ID]}"
  end

  # Get quest name
  def getName(quest)
    return "#{QuestModule.const_get(quest)[:Name]}"
  end

  # Get name of quest giver
  def getQuestGiver(quest)
    return "#{QuestModule.const_get(quest)[:QuestGiver]}"
  end
  
  # Get sprite of quest giver - added by Gardenette
  def getQuestGiverSprite(quest)
    return "#{QuestModule.const_get(quest)[:QuestGiverSprite]}"
  end
  
    # Get description sprite of quest giver - added by Gardenette
  def getQuestGiverDescSprite(quest)
    return "#{QuestModule.const_get(quest)[:QuestGiverDescSprite]}"
  end
  
  # Get ReadyAtStart data
  def self.getReadyAtStart(quest)
    return "#{QuestModule.const_get(quest)[:ReadyAtStart]}"
  end
  
  # Get Repeatable data
  def self.getRepeatable(quest)
    return "#{QuestModule.const_get(quest)[:Repeatable]}"
  end
  
  # Get RepeatableCooldown data
  def self.getRepeatableCooldown(quest)
    return "#{QuestModule.const_get(quest)[:RepeatableCooldown]}"
  end

  # Get array of quest stages
  def getQuestStages(quest)
    arr = []
    for key in QuestModule.const_get(quest).keys
      arr.push(key) if key.to_s.include?("Stage")
    end
    return arr
  end

  #added by Gardenette - not needed though?
  # Get array of quest stages
  def getQuestTasks(quest)
    arr = []
    for key in QuestModule.const_get(quest).keys
      arr.push(key) if key.to_s.include?("Task")
    end
    return arr
  end
  #end of what was added by Gardenette
  
  
  # Get quest reward
  def getQuestReward(quest)
    return "#{QuestModule.const_get(quest)[:RewardString]}"
  end

  # Get overall quest description
  def getQuestDescription(quest)
    return "#{QuestModule.const_get(quest)[:QuestDescription]}"
  end

  # Get current task location
  def getStageLocation(quest,stage)
    loc = ("Location" + "#{stage}").to_sym
    return "#{QuestModule.const_get(quest)[loc]}"
  end  

  # Get summary of current task
  def getStageDescription(quest,stage)
    stg = ("Stage" + "#{stage}").to_sym
    return "#{QuestModule.const_get(quest)[stg]}"
  end 
### Code for Percy
  # Get current stage label
  def getStageLabel(quest,stage)
    lab = ("StageLabel" + "#{stage}").to_sym
    return "#{QuestModule.const_get(quest)[lab]}"
  end 
###
  # Get maximum number of tasks for quest
  def getMaxStagesForQuest(quest)
    quests = getQuestStages(quest)
    return quests.length
  end
  
  # Added by Space
  # Returns an array of all tasks for the quest
  def getQuestTasks(quest)
    arr = []
    for key in QuestModule.const_get(quest).keys
      arr.push(QuestModule.const_get(quest)[key]) if key.to_s.include?("Task")
    end
    return arr
  end
  
  # Returns an array of the tasks for a stage
  def getStageTasks(quest,stage)
    arr = getQuestTasks(quest)
    arr2 = []
    for t in arr
      # Tasks are formatted as [Description, Stage #, Complete/Incomplete]
      # So taking t[1] here returns the Stage # associated with the task
      arr2.push(t) if t[1] == stage
    end
    return arr2
  end
  
  # Returns the string output of the tasks for a stage
  def getStageTaskString(quest,stage)
    arr = getStageTasks(quest,stage)
    if arr.length == 0
      return "\nNo sub-tasks for this stage."
    end
    ret = ""
    for t in arr
      ret = ret + "\n" + t[0] + ": " + (t[2] ? "<c2=#{colorQuest("green")}>Complete" : "<c2=#{colorQuest("red")}>Incomplete") + "</c2>"
    end
    return ret
  end
  
  # Returns the maximum number of tasks across all stages
  def getMaxTasksForQuest(quest)
    quests = getQuestTasks(quest)
    return quests.length
  end
  
  # Returns the maximum number of tasks within a given stage
  def getMaxTasksForStage(quest,stage)
    quests = getStageTasks(quest)
    return quests.length
  end #of what was added by Space
  
end

# Global variable to make it easier to refer to methods in above class
$quest_data = QuestData.new

#===============================================================================
# Class that contains utility methods to return quest properties
#===============================================================================

# Utility function to check whether the player current has any quests
def hasAnyQuests?
  if $PokemonGlobal.quests.active_quests.length >0 || 
    $PokemonGlobal.quests.completed_quests.length >0 ||
    $PokemonGlobal.quests.failed_quests.length >0
    return true
  end
  return false      
end

def getCurrentStage(quest)
  $PokemonGlobal.quests.active_quests.each do |s|
    return s.stage if s.id == quest
  end
  return nil
end

def getCurrentTasks(quest)
  $PokemonGlobal.quests.active_quests.each do |s|
    return s.tasks if s.id == quest
  end
  return nil
end

def getCompletedTasks(quest)
#gets the list of tasks that have not been completed yet
    arr = getCurrentTasks(quest)
    if arr.length == 0
      return "\nNo active tasks."
    end
    ret = ""
    arr3 = []
    for t in arr
      #ret = ret + "\n" + t[0] + ": " + (t[2] ? "<c2=#{colorQuest("green")}>Complete" : "<c2=#{colorQuest("red")}>Incomplete") + "</c2>"
      #ret = ret + "\n" + t[0] + ": " + t[2].to_s
      arr3.push(t[0]) if t[2] == true
    end
    return arr3
  end
  
def isTaskComplete(quest,task)
  arr = getCompletedTasks(quest)
  return true if arr.include?(task) #then it's active, so ret true
  return false if !arr.include?(task) #then it's active, so ret true
end

def taskCompleteJingle
  pbMessage(_INTL("\\se[{1}]<ac><c2=#{colorQuest("red")}>Task completed!</c2>\nYour objective list has been updated!</ac>",QUEST_JINGLE))
end