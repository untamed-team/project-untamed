#===============================================================================
# Tutorial Tips Log
#===============================================================================
# Class that creates the scrolling list of tutorial names
#===============================================================================
class Window_TutorialTipsLog < Window_DrawableCommand

  def initialize(x,y,width,height,viewport)
    super(x,y,width,height,viewport)
    self.windowskin = nil
    @selarrow = AnimatedBitmap.new("Graphics/Pictures/selarrow")
    RPG::Cache.retain("Graphics/Pictures/selarrow")
  end
  
  def itemCount
    return $tips_log.get_log.length
  end
  
  def drawCursorOffset(index, rect) #draws cursor to match text being on second line of item
    if self.index == index
      #pbCopyBitmap(self.contents, @selarrow.bitmap, rect.x, rect.y + 34)   # TEXT OFFSET (counters the offset above)
      pbCopyBitmap(self.contents, @selarrow.bitmap, rect.x, rect.y + 40)   # TEXT OFFSET (counters the offset above)
    end
    return Rect.new(rect.x + 16, rect.y, rect.width - 16, rect.height)
  end
  
  def drawItem(index,_count,rect)
    return if index>=self.top_row+self.page_item_max
    rect = Rect.new(rect.x+16,rect.y,rect.width-16,rect.height)
    name = @reversedList[index]+"\n"
    base = self.baseColor
      
    #Writes tutorial name
    drawFormattedTextEx(self.contents,rect.x,rect.y+40,436,"#{name}",base,nil,lineheight=32)
  end

  def refresh # edited some stuff with Space's help; #by low 
    #this is the number of tutorials that are in the list currently showing
    @item_max = itemCount
    
    #the width and height of the entire box that displays all the tutorial names
    dwidth  = self.width-self.borderX
    dheight = self.height-self.borderY
    self.contents = pbDoEnsureBitmap(self.contents,dwidth,dheight)
    self.contents.clear
    
    #remove old strings from array to avoid needing a new save file
    $tips_log.delete_old_strings
    
    #gets the array of unlocked tutorial tips and reverses the list so the
    #newest tutorials are on top, and the oldest tutorials are on bottom
    @reversedList = $tips_log.get_log.reverse
    
    for i in 0...itemCount
      next if i<self.top_item || i>self.top_item+self.page_item_max
      #itemRect(i) tells the game what line to draw everything on
      #if you say itemRect(0), it will draw all tutorials on the first line
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
class Tutorial_Tips_Log_Scene
    
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @base = Color.new(80,80,88)
    @shadow = Color.new(160,160,168)
    @sprites["base"] = IconSprite.new(0,0,@viewport)
    @sprites["base"].setBitmap("Graphics/Pictures/Tutorials/tutorial log bg")
    
    @sprites["itemlist"] = Window_TutorialTipsLog.new(22,15,Graphics.width-22,Graphics.height-48,@viewport)
    @sprites["itemlist"].index = 0
    
    @sprites["itemlist"].baseColor = @base
    
    #The line below gives proper spacing for the tips
    @sprites["itemlist"].rowHeight = 32
    
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

    #title
    pbDrawTextPositions(@sprites["overlay1"].bitmap,[
      [_INTL("Tutorials"),6,6,0,Color.new(248,248,248),Color.new(0,0,0),true]
    ])
    
    navigateControls = _INTL("{1}/{2}",$PokemonSystem.game_controls.find{|c| c.control_action=="Up"}.key_name,$PokemonSystem.game_controls.find{|c| c.control_action=="Down"}.key_name)
    pbDrawTextPositions(@sprites["overlay_control"].bitmap,[
      [_INTL("Navigate: "+navigateControls.to_s),12,Graphics.height-58,436,Color.new(248,248,248),Color.new(0,0,0),true]
    ])
    
    jumpUpDown = _INTL("CTRL + {1}/{2}",$PokemonSystem.game_controls.find{|c| c.control_action=="Up"}.key_name,$PokemonSystem.game_controls.find{|c| c.control_action=="Down"}.key_name)
    pbDrawTextPositions(@sprites["overlay_control"].bitmap,[
      [_INTL("Jump: "+jumpUpDown.to_s),12,Graphics.height-26,436,Color.new(248,248,248),Color.new(0,0,0),true]
    ])

    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbScene
    loop do
      selected = @sprites["itemlist"].index
      @sprites["itemlist"].active = true
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        showTip(selected)
        pbPlayDecisionSE
        #fadeContent
        #@sprites["itemlist"].active = false
        #showContent
      end
    end
  end
  
  def showTip(selected)
    @reversedList = $tips_log.get_log.reverse
    case @reversedList[selected]
    when "Auto Heal"
      $tips_log.tipAutoHeal
    when "Multiple Save Slots"
      $tips_log.tipMultiSave
    when "Advanced Dex"
      $tips_log.tipAdvancedDex
    when "Battle Info"
      $tips_log.tipBattleInfo
    when "Battle Info (cont.)"
      $tips_log.tipBattleInfoCont
    end
  end
  
  def fadeContent
    15.times do
      Graphics.update
      @sprites["itemlist"].contents_opacity -= 17
      @sprites["overlay1"].opacity -= 17; @sprites["overlay_control"].opacity -= 17
    end
  end
  
  def showContent
    15.times do
      Graphics.update
      @sprites["itemlist"].contents_opacity += 17
      @sprites["overlay1"].opacity += 17; @sprites["overlay_control"].opacity += 17
    end
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
class TutorialTipsList_Screen
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
def pbViewTips
  scene = Tutorial_Tips_Log_Scene.new
  screen = TutorialTipsList_Screen.new(scene)
  screen.pbStartScreen
end

#===============================================================================
# Tutorial Tips - what will appear when called and in the log
#===============================================================================
#by Gardenette and SpaceWestern

#put this line wherever the tip should show up
#$tips_log.METHOD
#Example: $tips_log.tipAdvancedDex

SaveData.register(:tips_log) do
  save_value { $tips_log }
  load_value { |value|  $tips_log = value }
  new_game_value { Tips.new }
end

class Tips
  attr_accessor :viewedTips
  
  def initialize
    @viewedTips = []
    #this adds "Multiple Save Slots to the list of unlocked tips if you had a save file
    #before this was implemented"
    if !@viewedTips.include?("Multiple Save Slots") && SaveData.get_newest_save_slot
      @viewedTips.push("Multiple Save Slots")
    end
  end
  
  def get_log
    return @viewedTips
  end
  
  def delete_old_strings
    @viewedTips.delete("autoheal") if @viewedTips.include?("autoheal")
    @viewedTips.delete("multisave") if @viewedTips.include?("multisave")
    @viewedTips.delete("advanceddex") if @viewedTips.include?("advanceddex")
  end
  
  #located in def pbStartScene inside the Autoheal script
  def tipAutoHeal
    pbMessage(_INTL("\\f[Tutorials\\auto heal1]The Auto Heal feature will automatically select items from your bag and use them to heal your Pokémon."))
    pbMessage(_INTL("\\f[Tutorials\\auto heal2]To use Auto Heal, highlight the Pokémon you want to heal from the party menu and press the button next to \\c[2]Auto Heal\\c[0]."))
    #create an array for all the tips that have been unlocked
    #they should be viewable later once unlocked, ideally
    @viewedTips.push("Auto Heal") if !@viewedTips.include?("Auto Heal")
  end

  #located in def pbSaveScreen inside the Auto Multi Save script
  def tipMultiSave
    pbMessage(_INTL("\\f[Tutorials\\multi save1]This game supports multiple save slots. When saving for the first time, you will select a save slot."))
    pbMessage(_INTL("\\f[Tutorials\\multi save2]When loading a save file, if you have multiple save files, you can press \\c[2]{1}\\c[0] or \\c[2]{2}\\c[0] on the continue screen to change save files.",$PokemonSystem.game_controls.find{|c| c.control_action=="Left"}.key_name,$PokemonSystem.game_controls.find{|c| c.control_action=="Right"}.key_name))
    pbMessage(_INTL("\\f[Tutorials\\multi save3]To create another save file, you must save through the menu instead of using Quicksave, and you must select a new slot."))
    @viewedTips.push("Multiple Save Slots") if !@viewedTips.include?("Multiple Save Slots")
  end
  
  #located in def pbStartScene inside FL's Advanced Pokedex script
  def tipAdvancedDex
    pbMessage(_INTL("\\f[Tutorials\\advanced dex1]Your Pokédex has an 'Advanced' page."))
    pbMessage(_INTL("\\f[Tutorials\\advanced dex2]When you go over to this page, you will see advanced information about the selected Pokémon if you have caught it."))
    pbMessage(_INTL("\\f[Tutorials\\advanced dex3]You can press \\c[2]{1}\\c[0] to go to the next page.",$PokemonSystem.game_controls.find{|c| c.control_action=="Action"}.key_name))
    pbMessage(_INTL("This information is also on the Untamed Wiki, but this feature provides an alternative to view the information offline."))
    @viewedTips.push("Advanced Dex") if !@viewedTips.include?("Advanced Dex")
  end

  #located in pbCommandMenuEx in the Battle Script from Essentials Deluxe
   def tipBattleInfo
    pbMessage(_INTL("\\f[Tutorials\\stats battle1]You can view information about the battle by pressing \\c[2]{1}\\c[0].",$PokemonSystem.game_controls.find{|c| c.control_action=="Battle Info"}.key_name))
    pbMessage(_INTL("\\f[Tutorials\\stats battle2]You can see information such as stat changes, used moves, abilities, etc."))
    pbMessage(_INTL("\\f[Tutorials\\stats battle3]You can see similar information about your opponent(s) too."))
    pbMessage(_INTL("\\f[Tutorials\\stats battle4]You can view information about the currently selected move by pressing \\c[2]{1}\\c[0].",$PokemonSystem.game_controls.find{|c| c.control_action=="Move Info"}.key_name))
    #pbMessage(_INTL("\\f[Tutorials\\stats battle4]You can see information such as a move's effectiveness against your opponent, the chance the move has of adding effects, etc.")) #commented by styma, not needed
    pbMessage(_INTL("For more information, view this tip again from the \\c[2]Trainer Tips\\c[0] app on your phone."))
    @viewedTips.push("Battle Info") if !@viewedTips.include?("Battle Info")
    #Battle Info (cont.) will only be viewable from the trainer tips app on your phone since there's A LOT of information to cover
    @viewedTips.push("Battle Info (cont.)") if !@viewedTips.include?("Battle Info (cont.)")
  end
  
  def tipBattleInfoCont
    pbMessage(_INTL("About icons and stuff, more in depth"))
    @viewedTips.push("Battle Info") if !@viewedTips.include?("Battle Info")
    #Battle Info (cont.) will only be viewable from the trainer tips app on your phone since there's A LOT of information to cover
    @viewedTips.push("Battle Info (cont.)") if !@viewedTips.include?("Battle Info (cont.)")
  end
  
end #of class Tips