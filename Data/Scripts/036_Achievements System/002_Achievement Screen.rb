class AchievementButton < SpriteWrapper
  attr_reader :name
  attr_accessor :selected

  def initialize(x,y,name="",level="",internal="",viewport=nil)
    super(viewport)
    @name=name
    @level=level
    @selected=false
    currgoal=Achievements.getCurrentGoal(internal)
    if currgoal
      @button=AnimatedBitmap.new("Graphics/Pictures/Achievements/achievementsButton")
    else
      @button=AnimatedBitmap.new("Graphics/Pictures/Achievements/completedButton")
    end
    @contents=BitmapWrapper.new(@button.width,@button.height)
    self.bitmap=@contents
    self.x=x
    self.y=y
    refresh
    update
  end

  def dispose
    @button.dispose
    @contents.dispose
    super
  end

  def refresh
    self.bitmap.clear
    self.bitmap.blt(0,0,@button.bitmap,Rect.new(0,0,@button.width,@button.height))
    pbSetSystemFont(self.bitmap)
    textpos=[          # Name is written on both unselected and selected buttons
       [@name,14,10,0,Color.new(248,248,248),Color.new(40,40,40)],
       [@name,14,62,0,Color.new(248,248,248),Color.new(40,40,40)],
       [@level,482,10,1,Color.new(248,248,248),Color.new(40,40,40)],
       [@level,482,62,1,Color.new(248,248,248),Color.new(40,40,40)]
    ]
    pbDrawTextPositions(self.bitmap,textpos)
  end

  def update
    if self.selected
      self.src_rect.set(0,self.bitmap.height/2,self.bitmap.width,self.bitmap.height/2)
    else
      self.src_rect.set(0,0,self.bitmap.width,self.bitmap.height/2)
    end
    super
  end
end

class AchievementText < SpriteWrapper
  attr_reader :index
  attr_reader :name

  def initialize(x,y,description="",progress="",viewport=nil)
    super(viewport)
    @description=description
    @progress=progress
    @button=AnimatedBitmap.new("Graphics/Pictures/Achievements/achievementsText")
    @window=Window_AdvancedTextPokemon.newWithSize("",16,Graphics.height-96,Graphics.width-32,96,viewport)
    @window.letterbyletter=false
    @window.windowskin=nil
    @window.baseColor=MessageConfig::LIGHT_TEXT_MAIN_COLOR
    @window.shadowColor=MessageConfig::LIGHT_TEXT_SHADOW_COLOR
    self.bitmap=@button.bitmap
    self.x=x
    self.y=y
    refresh
    update
  end

  def color=(val)
    @window.color=val
    super
  end
  
  def dispose
    @button.dispose
    @window.dispose
    super
  end

  def refresh
    @window.setText(@description+"\n"+"<ac>"+@progress+"</ac>")
  end

  def change(description,progress)
    @description=description.to_s
    @progress=progress.to_s
    refresh
  end
  
  def update
    @window.update
    super
  end
end

class PokemonAchievements_Scene
  def initialize(menu_index = 0)
    @menu_index = menu_index
    @buttons=[]
    @_buttons=[]
    @achievements=[]
    @achievementInternalNames=[]
  end
  #-----------------------------------------------------------------------------
  # start the scene
  #-----------------------------------------------------------------------------
  def pbStartScene
    buttonList={}
    al=Achievements.list.keys
    al=al.sort{|a,b|Achievements.list[a]["id"]<=>Achievements.list[b]["id"]}
    al.each{|k|
      @buttons.push(_INTL(Achievements.list[k]["name"]))
      @_buttons.push([k,_INTL(Achievements.list[k]["goals"])])
      @achievements.push(Achievements.list[k])
      @achievementInternalNames.push(k)
      buttonList[k.to_s]=-1
    }
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @buttonport=Viewport.new(0,46,Graphics.width,250)
    @buttonport.z=99999
    @button=AnimatedBitmap.new("Graphics/Pictures/Achievements/achievementsButton")
    @sprites={}
    addBackgroundPlane(@sprites,"background","Achievements/achievementsbg",@viewport)
    @sprites["command_window"] = Window_CommandPokemon.new(@buttons,160)
    @sprites["command_window"].visible = false
    @sprites["command_window"].index = @menu_index
    @sprites["achievementText"]=AchievementText.new(8,296,"Error.",_INTL("{1}/{2}","-1","-1"), @viewport)
    currgoal=Achievements.getCurrentGoal(@achievementInternalNames[0])
    if currgoal
      progress=_INTL("{1}/{2}",$PokemonGlobal.achievements[@_buttons[0][0]]["progress"],currgoal)
    else
      progress=_INTL("{1}",$PokemonGlobal.achievements[@_buttons[0][0]]["progress"])
    end
    @sprites["achievementText"].change(_INTL(@achievements[0]["description"]),progress)
    @sprites["achievementText"].visible = true
    for i in 0...@buttons.length
      x=8
      y=(i*50)
      @sprites["button#{i}"]=AchievementButton.new(x,y,@buttons[i],_INTL("{1}/{2}",$PokemonGlobal.achievements[@_buttons[i][0]]["level"],@_buttons[i][1].length),@_buttons[i][0],@buttonport)
      @sprites["button#{i}"].selected=(i==@sprites["command_window"].index)
    end
    pbFadeInAndShow(@sprites) { update }
  end
  #-----------------------------------------------------------------------------
  # play the scene
  #-----------------------------------------------------------------------------
  def pbAchievements
    loop do
      Graphics.update
      Input.update
      update
      if Input.trigger?(Input::B)
        break
      end
    end
  end
  #-----------------------------------------------------------------------------
  # end the scene
  #-----------------------------------------------------------------------------
  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
  #-----------------------------------------------------------------------------
  # update the scene
  #-----------------------------------------------------------------------------
  def update
    if @sprites["command_window"].nil?
      pbUpdateSpriteHash(@sprites)
      return true
    end
    oldi = @sprites["command_window"].index rescue 0
    pbUpdateSpriteHash(@sprites)
    newi = @sprites["command_window"].index rescue 0
    if oldi!=newi
      @sprites["button#{oldi}"].selected=false
      @sprites["button#{oldi}"].update
      @sprites["button#{newi}"].selected=true
      @sprites["button#{newi}"].update
      currgoal=Achievements.getCurrentGoal(@achievementInternalNames[newi])
      if currgoal
        progress=_INTL("{1}/{2}",$PokemonGlobal.achievements[@_buttons[newi][0]]["progress"],currgoal)
      else
        progress=_INTL("{1}",$PokemonGlobal.achievements[@_buttons[newi][0]]["progress"])
      end
      @sprites["achievementText"].change(_INTL(@achievements[newi]["description"]),progress)
      while @sprites["button#{newi}"].y>200
        for i in 0...@buttons.length
          @sprites["button#{i}"].y-=50
        end
      end
      while @sprites["button#{newi}"].y<0
        for i in 0...@buttons.length
          @sprites["button#{i}"].y+=50
        end
      end
    end
  end
end

class PokemonAchievements
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbAchievements
    @scene.pbEndScene
  end
end