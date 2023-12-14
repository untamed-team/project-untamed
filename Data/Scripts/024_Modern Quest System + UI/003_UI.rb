#===============================================================================
# Class that creates the scrolling list of quest names
#===============================================================================
class Window_Quest < Window_DrawableCommand

  def initialize(x,y,width,height,viewport)
    @quests = []
    super(x,y,width,height,viewport)
    self.windowskin = nil
    @selarrow = AnimatedBitmap.new("Graphics/Pictures/selarrow")
    RPG::Cache.retain("Graphics/Pictures/selarrow")
  end
  
  def quests=(value)
    @quests = value
    refresh
  end
  
  def itemCount
    return @quests.length
  end
  
  def drawCursorOffset(index, rect) #draws cursor to match text being on second line of item
    if self.index == index
      pbCopyBitmap(self.contents, @selarrow.bitmap, rect.x, rect.y + 34)   # TEXT OFFSET (counters the offset above)
    end
    return Rect.new(rect.x + 16, rect.y, rect.width - 16, rect.height)
  end
  
  def drawItem(index,_count,rect)
    return if index>=self.top_row+self.page_item_max
    #moving the y up does not fix the quest giver sprite from being cut off
    #there's some kind of box there
    rect = Rect.new(rect.x+16,rect.y,rect.width-16,rect.height)
    name = $quest_data.getName(@quests[index].id)+"\n"
    name = "<b>" + "#{name}" + "</b>" if @quests[index].story
    base = self.baseColor
    #shadow = self.shadowColor
    col = @quests[index].color
    #drawFormattedTextEx(self.contents,rect.x,rect.y+4,
      #436,"<c2=#{col}>#{name}</c2>",base,shadow)
      
    #Writes quest name
    drawFormattedTextEx(self.contents,rect.x,rect.y+36,436,"<c2=#{col}>#{name}</c2>",base,nil,lineheight=32)
    
    #drawFormattedTextEx(self.contents,rect.x,rect.y+36,436,"",base,nil,lineheight=32)
    
    #pbDrawImagePositions(self.contents,[[sprintf("Graphics/Pictures/QuestUI/new"),rect.width-16,rect.y+2]]) if @quests[index].new
    #this draws the exclamation icon named "new" when there is new activity on an objective
    pbDrawImagePositions(self.contents,[[sprintf("Graphics/Pictures/QuestUI/new"),rect.width-80,rect.y+38]]) if @quests[index].new
    
    # Guest giver sprite - added by Gardenette
    questGiverSprite = $quest_data.getQuestGiverSprite(@quests[index].id)
    
    #added by Gardenette
    #draws the quest giver sprite next to the quest
    pbDrawImagePositions(self.contents,[[sprintf("Graphics/Characters/" + questGiverSprite),rect.width-46,rect.y+14,nil,nil,width=64,height=64]])
    
  end

  def refresh # edited some stuff with Space's help; #by low 
    #this is the number of quests that are in the list currently showing
    @item_max = itemCount
    #the width and height of the entire box that displays all the quest names
    dwidth  = self.width-self.borderX
    dheight = self.height-self.borderY
    self.contents = pbDoEnsureBitmap(self.contents,dwidth,dheight)
    self.contents.clear
    for i in 0...itemCount
      next if i<self.top_item || i>self.top_item+self.page_item_max
      #itemRect(i) tells the game what line to draw everything on
      #if you say itemRect(0), it will draw all quests on the first line
      drawItem(i,@item_max,itemRect(i))
    end
    drawCursorOffset(self.index,itemRect(self.index)) if itemCount > 0
  end
  
  def update
    super
    @uparrow.visible   = false
    @downarrow.visible = false
  end
end

#===============================================================================
# Class that controls the UI
#===============================================================================
class QuestList_Scene
  
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @base = Color.new(80,80,88)
    @shadow = Color.new(160,160,168)
    addBackgroundPlane(@sprites,"bg","QuestUI/bg_1",@viewport)
    @sprites["base"] = IconSprite.new(0,0,@viewport)
    @sprites["base"].setBitmap("Graphics/Pictures/QuestUI/bg_2")
    
    @quests = [
      $PokemonGlobal.quests.active_quests,
      $PokemonGlobal.quests.completed_quests
    ]
    @quests_text = ["Active", "Completed"]
    if SHOW_FAILED_QUESTS
      @quests.push($PokemonGlobal.quests.failed_quests)
      @quests_text.push("Failed")
    end
	###
	if SORT_QUESTS
	  @quests.each do |s|
	    s.sort_by! {|x| [x.story ? 0 : 1, x.time]}
	  end
    end
	###
    @current_quest = 0
    
    #added by Gardenette to show arrows
    #right arrow shows at the start
    @sprites["rightarrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow",8,40,28,2,@viewport)
    @sprites["rightarrow"].x = Graphics.width - @sprites["rightarrow"].bitmap.width
    @sprites["rightarrow"].y = Graphics.height/2 - @sprites["rightarrow"].bitmap.height/16
    @sprites["rightarrow"].visible = false
    @sprites["rightarrow"].play
    
    @sprites["leftarrow"] = AnimatedSprite.new("Graphics/Pictures/leftarrow",8,40,28,2,@viewport)
    @sprites["leftarrow"].x = 0
    @sprites["leftarrow"].y = Graphics.height/2 - @sprites["rightarrow"].bitmap.height/16
    @sprites["leftarrow"].visible = false
    @sprites["leftarrow"].play
    
    #@sprites["itemlist"] = Window_Quest.new(22,28,Graphics.width-22,Graphics.height-80,@viewport)
    #shows the objectives by name in the list
    @sprites["itemlist"] = Window_Quest.new(22,15,Graphics.width-22,Graphics.height-48,@viewport)
    @sprites["itemlist"].index = 0
    
    @sprites["itemlist"].baseColor = @base
    #@sprites["itemlist"].shadowColor = @shadow
    
    #The line below gives proper spacing for the quests
    @sprites["itemlist"].rowHeight = 64
    
    @sprites["itemlist"].quests = @quests[@current_quest]
    @sprites["overlay1"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay1"].bitmap)
    @sprites["overlay2"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["overlay2"].opacity = 0
    pbSetSystemFont(@sprites["overlay2"].bitmap)
    @sprites["overlay3"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["overlay3"].opacity = 0
    pbSetSystemFont(@sprites["overlay3"].bitmap)
    @sprites["overlay_control"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay_control"].bitmap)
    @sprites["overlay_page_number"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay_page_number"].bitmap)

    #shows the objectives by name in the list
    pbDrawTextPositions(@sprites["overlay1"].bitmap,[
      [_INTL("{1} Objectives", @quests_text[@current_quest]),6,6,0,Color.new(248,248,248),Color.new(0,0,0),true]
    ])
    
    updatePageNumber1
    
    navigateControls = _INTL("{1}/{2}/{3}/{4}",$PokemonSystem.game_controls.find{|c| c.control_action=="Up"}.key_name,$PokemonSystem.game_controls.find{|c| c.control_action=="Down"}.key_name,$PokemonSystem.game_controls.find{|c| c.control_action=="Left"}.key_name,$PokemonSystem.game_controls.find{|c| c.control_action=="Right"}.key_name)
    pbDrawTextPositions(@sprites["overlay_control"].bitmap,[
      [_INTL("Navigate: "+navigateControls.to_s),12,Graphics.height-58,436,Color.new(248,248,248),Color.new(0,0,0),true]
    ])
    
    jumpUpDown = _INTL("CTRL + {1}/{2}",$PokemonSystem.game_controls.find{|c| c.control_action=="Up"}.key_name,$PokemonSystem.game_controls.find{|c| c.control_action=="Down"}.key_name)
    pbDrawTextPositions(@sprites["overlay_control"].bitmap,[
      [_INTL("Jump: "+jumpUpDown.to_s),12,Graphics.height-26,436,Color.new(248,248,248),Color.new(0,0,0),true]
    ])
    
    pbDrawTextPositions(@sprites["overlay_control"].bitmap,[
      [_INTL("New:"),Graphics.width-120,Graphics.height-26,436,Color.new(248,248,248),Color.new(0,0,0),true]
    ])
    
    pbDrawImagePositions(@sprites["overlay_control"].bitmap,[
      [sprintf("Graphics/Pictures/QuestUI/new activity"),Graphics.width-46,Graphics.height-30]
    ])
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
  
  def updatePageNumber1
    #page number when looking at list of quests
    @sprites["overlay_page_number"].bitmap.clear
    pbDrawTextPositions(@sprites["overlay_page_number"].bitmap,[
      [_INTL("Page {1}/{2}", @current_quest+1, @quests.length),Graphics.width-98,6,0,Color.new(248,248,248),Color.new(0,0,0),true]
    ])
  end
  
  def updatePageArrows1
    #changes left and right arrows
    if @current_quest == 0
      @sprites["leftarrow"].visible = false
      @sprites["rightarrow"].visible = true
    else
      @sprites["leftarrow"].visible = true
      @sprites["rightarrow"].visible = false
    end
  end

  def pbScene
    loop do
      selected = @sprites["itemlist"].index
      @sprites["itemlist"].active = true
      dorefresh = false
      updatePageNumber1
      updatePageArrows1
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        if @quests[@current_quest].length==0
          pbPlayBuzzerSE
				elsif @quests[@current_quest][selected] == nil #by low
					pbPlayBuzzerSE
        else
          pbPlayDecisionSE
          fadeContent
          @sprites["itemlist"].active = false
          pbQuest(@quests[@current_quest][selected]) 
          showContent
        end
      elsif Input.trigger?(Input::RIGHT)
        pbPlayCursorSE
        @current_quest +=1; @current_quest = 0 if @current_quest > @quests.length-1
        dorefresh = true
      elsif Input.trigger?(Input::LEFT)
        pbPlayCursorSE
        @current_quest -=1; @current_quest = @quests.length-1 if @current_quest < 0
        dorefresh = true
      end
      swapQuestType if dorefresh
    end
  end
  
  def swapQuestType
    @sprites["overlay1"].bitmap.clear
    @sprites["itemlist"].index = 0 # Resets cursor position
    @sprites["itemlist"].quests = @quests[@current_quest]
    pbDrawTextPositions(@sprites["overlay1"].bitmap,[
      [_INTL("{1} Objectives", @quests_text[@current_quest]),6,6,0,Color.new(248,248,248),Color.new(0,0,0),true]
    ])
    
    updatePageNumber1
    
    updatePageArrows1
    
  end
  
  def fadeContent
    15.times do
      Graphics.update
      @sprites["itemlist"].contents_opacity -= 17
      @sprites["overlay1"].opacity -= 17; @sprites["overlay_control"].opacity -= 17
      @sprites["overlay_page_number"].opacity -= 17
      @sprites["rightarrow"].opacity -= 17; @sprites["leftarrow"].opacity -= 17
    end
  end
  
  def showContent
    15.times do
      Graphics.update
      @sprites["itemlist"].contents_opacity += 17
      @sprites["overlay1"].opacity += 17; @sprites["overlay_control"].opacity += 17
      @sprites["overlay_page_number"].opacity += 17
      @sprites["rightarrow"].opacity += 17; @sprites["leftarrow"].opacity += 17
    end
  end
  
  def updatePageNumber2(page)
    #page number when looking at a specific quest
    @sprites["overlay_page_number"].bitmap.clear
    pbDrawTextPositions(@sprites["overlay_page_number"].bitmap,[
      [_INTL("Page {1}/3", page),Graphics.width-98,6,0,Color.new(248,248,248),Color.new(0,0,0),true]
    ])
  end
  
  def updatePageArrows2(page)
    #changes left and right arrows
    if page == 1
      @sprites["leftarrow"].visible = false
      @sprites["rightarrow"].visible = true
    elsif page == 2
      @sprites["leftarrow"].visible = true
      @sprites["rightarrow"].visible = true
    else
      #page is 3, the max
      @sprites["leftarrow"].visible = true
      @sprites["rightarrow"].visible = false
    end
  end
  
  def pbQuest(quest)
    quest.new = false
    drawQuestDesc(quest)
    
#arrows
       
    15.times do
      Graphics.update
      @sprites["overlay2"].opacity += 17; @sprites["overlay3"].opacity += 17
      @sprites["overlay_page_number"].opacity += 17
      @sprites["rightarrow"].opacity += 17; @sprites["leftarrow"].opacity += 17
    end
    
    page = 1
    updatePageNumber2(page)
    updatePageArrows2(page)
    
    loop do
      Graphics.update
      Input.update
      pbUpdate
      showOtherInfo = false
    
      #modified by Space and moved here from after the loop's end
      @sprites["itemlist"].refresh
      #end of what was modified by Space
      
      if Input.trigger?(Input::RIGHT) && page==1
        pbPlayCursorSE
        page += 1
        
        #added by Space
        drawStageTasks(quest)
      elsif Input.trigger?(Input::RIGHT) && page==2
        pbPlayCursorSE
        page += 1
        #end of what was added by Space
        
        drawOtherInfo(quest)
      elsif Input.trigger?(Input::LEFT) && page==2
        pbPlayCursorSE
        page -= 1
        drawQuestDesc(quest)
      
      #added by Space
      elsif Input.trigger?(Input::LEFT) && page==3
        pbPlayCursorSE
        page -= 1
        drawStageTasks(quest)
      #end of what was added by Space
      
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      end
    end
    
    #added by Gardenette
      #change the bg to be the quest list bg
      @sprites["base"].setBitmap("Graphics/Pictures/QuestUI/bg_2")
    
    15.times do
      Graphics.update
      @sprites["overlay2"].opacity -= 17; @sprites["overlay3"].opacity -= 17;
      @sprites["overlay_page_number"].opacity -= 17
      @sprites["rightarrow"].opacity -= 17; @sprites["leftarrow"].opacity -= 17
    end
    
  end
  
  #######################
  ### Page 2 of Quest ###
  #######################
  def drawQuestDesc(quest)
    #added by Gardenette
    page = 1
    updatePageNumber2(page)
    updatePageArrows2(page)
    
    #change the bg to be the quest details bg
    @sprites["base"].setBitmap("Graphics/Pictures/QuestUI/quest ui_summary")
    
    @sprites["overlay2"].bitmap.clear; @sprites["overlay3"].bitmap.clear
    # Quest name
    questName = $quest_data.getName(quest.id)
    #pbDrawTextPositions(@sprites["overlay2"].bitmap,[
    #  ["#{questName}",6,-2,0,Color.new(248,248,248),Color.new(0,0,0),true]
    #])
    pbDrawTextPositions(@sprites["overlay2"].bitmap,[
      ["#{questName}",6,6,0,Color.new(248,248,248),Color.new(0,0,0),true]
    ])
    # Quest description
    #questDesc = "<c2=#{colorQuest("blue")}>Overview:</c2> #{$quest_data.getQuestDescription(quest.id)}"
    questDesc = "#{$quest_data.getQuestDescription(quest.id)}"
    #drawFormattedTextEx(@sprites["overlay3"].bitmap,38,48,
     # 436,questDesc,@base,@shadow)
     drawFormattedTextEx(@sprites["overlay3"].bitmap,220,98,240,questDesc,@base,@shadow)
    # Stage description
    questStageDesc = $quest_data.getStageDescription(quest.id,quest.stage)
    # Stage location
    questStageLocation = $quest_data.getStageLocation(quest.id,quest.stage)
    # If 'nil' or missing, set to '???'
    if questStageLocation=="nil" || questStageLocation==""
      questStageLocation = "???"
    end
    
    #commented out by Gardenette
    #drawFormattedTextEx(@sprites["overlay3"].bitmap,38,316,
    #  436,"<c2=#{colorQuest("orange")}>Task:</c2> #{questStageDesc}",@base,@shadow)
    
    #Added by Space
      #drawFormattedTextEx(@sprites["overlay3"].bitmap,38,348,
      #436,"<c2=#{colorQuest("purple")}>Location:</c2> #{questStageLocation}",@base,@shadow)
      
      #edited by Gardenette
      pbDrawTextPositions(@sprites["overlay3"].bitmap,[["Location: #{questStageLocation}",16,308,436,Color.new(248,248,248),Color.new(0,0,0),true]])
    
      #edited by Gardenette - quest reward
      questReward = $quest_data.getQuestReward(quest.id)
      if questReward=="nil" || questReward==""
        questReward = "???"
      end
      pbDrawTextPositions(@sprites["overlay3"].bitmap,[["Reward: #{questReward}",16,348,436,Color.new(248,248,248),Color.new(0,0,0),true]])
    
    # Guest giver sprite - added by Gardenette
    #questGiverDescSprite = $quest_data.getQuestGiverDescSprite(@quests[index].id)
    questGiverDescSprite = $quest_data.getQuestGiverDescSprite(quest.id)
    
    #added by Gardenette
    #draws the quest giver sprite next to the quest
    pbDrawImagePositions(@sprites["overlay2"].bitmap,[[sprintf("Graphics/Trainers/" + questGiverDescSprite),38,88,nil,nil]])
      
  end
  
  def drawStageTasks(quest)
    @sprites["overlay2"].bitmap.clear; @sprites["overlay3"].bitmap.clear
    
    page = 2
    updatePageNumber2(page)
    updatePageArrows2(page)
    
    #added by Gardenette
    #change the bg to be the subtasks page
    @sprites["base"].setBitmap("Graphics/Pictures/QuestUI/subtasks")
    
    #added down here by Gardenette - this is the quest title. It should be drawn
    #on all pages, not just the first page
    # Quest name
    questName = $quest_data.getName(quest.id)
    
    pbDrawTextPositions(@sprites["overlay2"].bitmap,[
      ["#{questName}",6,6,0,Color.new(248,248,248),Color.new(0,0,0),true]
      ])
    #end of added by Gardenette
    
    # Tasks
    #questDesc = "<c2=#{colorQuest("blue")}>Sub-Tasks:</c2> #{quest.getStageTaskString}"
    #drawFormattedTextEx(@sprites["overlay3"].bitmap,38,48,
    #  436,questDesc,@base,@shadow)
    # Stage description
    questStageDesc = $quest_data.getStageDescription(quest.id,quest.stage)
    # Stage location
    questStageLocation = $quest_data.getStageLocation(quest.id,quest.stage)
    # If 'nil' or missing, set to '???'
    if questStageLocation=="nil" || questStageLocation==""
      questStageLocation = "???"
    end
    
    drawFormattedTextEx(@sprites["overlay3"].bitmap,38,48,
      436,questStageDesc,@base,@shadow)
      
    questDesc = "#{quest.getStageTaskString}"
    #drawFormattedTextEx(@sprites["overlay3"].bitmap,38,48,
    #  436,questDesc,@base,@shadow)
    
    drawFormattedTextEx(@sprites["overlay3"].bitmap,38,80,
      436,questDesc,@base,@shadow)
    
    #commented out by Gardenette
    #drawFormattedTextEx(@sprites["overlay3"].bitmap,38,316,
    #  436,"<c2=#{colorQuest("orange")}>Task:</c2> #{questStageDesc}",@base,@shadow)
    
    #drawFormattedTextEx(@sprites["overlay3"].bitmap,38,348,    
    #  436,"<c2=#{colorQuest("purple")}>Location:</c2> #{questStageLocation}",@base,@shadow)
    #end of what was added by Space
    
    #edited by Gardenette - quest location
    pbDrawTextPositions(@sprites["overlay3"].bitmap,[["Location: #{questStageLocation}",16,308,436,Color.new(248,248,248),Color.new(0,0,0),true]])
    
    #edited by Gardenette - quest reward
    questReward = $quest_data.getQuestReward(quest.id)
    if questReward=="nil" || questReward==""
      questReward = "???"
    end
    pbDrawTextPositions(@sprites["overlay3"].bitmap,[["Reward: #{questReward}",16,348,436,Color.new(248,248,248),Color.new(0,0,0),true]])
    
  end

  def drawOtherInfo(quest)
    @sprites["overlay3"].bitmap.clear
    
    page = 3
    updatePageNumber2(page)
    updatePageArrows2(page)
    
    #added by Gardenette
    #change the bg to be the quest details bg (where the quest was obtained,
    #when it was started, etc.)
    @sprites["base"].setBitmap("Graphics/Pictures/QuestUI/details")
    
    # Guest giver
    questGiver = $quest_data.getQuestGiver(quest.id)
    # If 'nil' or missing, set to '???'
    if questGiver=="nil" || questGiver==""
      questGiver = "???"
    end
    
    # Total number of stages for quest
    questLength = $quest_data.getMaxStagesForQuest(quest.id)
    # Map quest was originally started
    originalMap = quest.location
    # Vary text according to map name
    loc = originalMap.include?("Route") ? "on" : "in"
    # Format time
    time = quest.time.strftime("%B %d %Y %H:%M")
    if getActiveQuests.include?(quest.id)
      time_text = "start"
    elsif getCompletedQuests.include?(quest.id)
      time_text = "completion"
    else
      time_text = "failure"
    end
    # Quest reward
    questReward = $quest_data.getQuestReward(quest.id)
	active_quests = getActiveQuests
    if questReward=="nil" || questReward==""
      questReward = "???"
    end
    textpos = [
      #[sprintf("Stage %d/%d",quest.stage,questLength),38,38,0,@base,@shadow],
      #["#{questGiver}",38,110,0,@base,@shadow],
      #["#{originalMap}",38,182,0,@base,@shadow],
      #["#{time}",38,254,0,@base,@shadow]
    ]


    #quest stage
    pbDrawTextPositions(@sprites["overlay3"].bitmap,[[_INTL("Stage {1}/{2}",quest.stage,questLength),38,44,436,@base,@shadow]])
    
    #quest giver
    #using "drawFormattedTextEx" so we can have color coding in the text
    drawFormattedTextEx(@sprites["overlay3"].bitmap,38,108,436,"<c2=#{colorQuest("cyan")}>Received from:</c2> #{questGiver}",@base,@shadow)
    
    #quest discovered
    #not needed since we have "Location" acting as a turn-in location
    #drawFormattedTextEx(@sprites["overlay3"].bitmap,38,160,436,"<c2=#{colorQuest("magenta")}>Quest discovered #{loc}:</c2>",@base,@shadow)
    
    #date and time discovered/started
    drawFormattedTextEx(@sprites["overlay3"].bitmap,38,172,436,"<c2=#{colorQuest("green")}>Started:</c2> #{time}",@base,@shadow)
    
    
    #drawFormattedTextEx(@sprites["overlay3"].bitmap,38,232,436,"<c2=#{colorQuest("green")}>Quest #{time_text} time:</c2>",@base,@shadow)
    
    #commented out by Gardenette
    #drawFormattedTextEx(@sprites["overlay3"].bitmap,38,Graphics.height-68,
     # 436,"<c2=#{colorQuest("red")}>Reward:</c2> #{questReward}",@base,@shadow)
    
     
     
     
    #comment this out last 
    pbDrawTextPositions(@sprites["overlay3"].bitmap,textpos)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
# Class to call UI
#===============================================================================
class QuestList_Screen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbScene
    @scene.pbEndScene
  end
end

# Utility method for calling UI
def pbViewQuests
  scene = QuestList_Scene.new
  screen = QuestList_Screen.new(scene)
  screen.pbStartScreen
end