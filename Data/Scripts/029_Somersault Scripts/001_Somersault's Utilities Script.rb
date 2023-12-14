#==============================================================================#
#                       SOMERSAULT'S UTILITIES SCRIPT v4.2                     #
#                              Give credit if used                             #
#==============================================================================#
# Several small functions to handle my other scripts and/or to use as standalone
#==============================================================================#
 XTRANSCEIVERADDED = false #turn on only if you install KleinStudio's Xtransceiver script
 DOUBLESCREEN      = false
 DEBUG_INTRO       = false #Look for pbCallTitle and add "&& !DEBUG_INTRO" at the
                           #end of the line "if $DEBUG" " to use this feature
#==============================================================================#
SM_SCREEN_WIDTH  = 512
SM_SCREEN_HEIGHT = 384

TOP_SCREEN_X=0
TOP_SCREEN_Y=0

#useful only when DOUBLESCREEN is set to true
BTM_SCREEN_X=0
BTM_SCREEN_Y=400
#==============================================================================#                         
 ICONSIDE = 64           # go to Pokemon_Sprites and look for:
 
                    ###############################
                    # @frames=[                   # (this should be at line 100)
                    #       Rect.new(0,0,64,64),  #
                    #       Rect.new(64,0,64,64)  #
                    #    ]                        #
                    ###############################
                    
# replace all "64" instances with ICONSIDE
#==============================================================================#
                         #How to use TEXTLENGTH: Look for all
# pbEnterPlayerName(_INTL("Some text here",A_VARIABLE),A_NUMBER,ANOTHER_NUMBER)
# And change every appearence of ANOTHER_NUMBER with "TEXTLENGTH".
# (Press ctrl + shift + F to access the search tab). Done!
 TEXTLENGTH = 10
 USEKEYBOARD = true   # To change between a keyboard input or a char table input 
#==============================================================================#
#==============================================================================#
#                              SET CHARACTER NAME                              #
#==============================================================================#
#     Simple function to name a character depending on the player's gender     #
#==============================================================================#
#Usage: pbSetCharName(male_name,female_name, variable_to_store_the_name_in)
#Suggestion: Use it in the intro event after setting the player's gender so that
#each time you want to access the name in a text you can simply do \v[var_value] 
#==============================================================================#
def pbSetCharName(name_m,name_f,var)
  pbSet(var,name_m) if $Trainer.isFemale?
  pbSet(var,name_f) if $Trainer.isMale?
end
#==============================================================================#
#==============================================================================#
#                          SET CUSTOM SUGGESTION NAMES                         #
#==============================================================================#
#Simple function to make a custom suggestion when choosing a name for the player
#==============================================================================#
#Usage: set the following boolean to true; change the names to the ones of your
#choice; DONE! (Yes! You don't have to even call it!)
#==============================================================================#
USE_CUSTOM_SUG_NAME = true

MALE_CHAR = "Lucas"
FEM_CHAR  = "Dawn"
#------------------------------------------------------------------------------#
alias pbSuggestTrainerNameOld pbSuggestTrainerName
#def pbSuggestTrainerName(gender)
#  if USE_CUSTOM_SUG_NAME
#    return FEM_CHAR  if gender == 1
#    return MALE_CHAR if gender == 0
#  else
#    pbSuggestTrainerNameOld
#  end
#end
#==============================================================================#
#==============================================================================#
#                                  DIGIT FORMAT                                #
#==============================================================================#
#An simple function to change the number of digits (and zeroes at the left) that
#a variable has. Call pbChDigitsAmount(NUMBER, NUMBER_OF_DIGITS)
#==============================================================================#
def pbChDigitsAmount(num, n = 5)
  stringNum = num.to_s
  
  digitFiller = n - stringNum.length
  digitFiller = 0 if digitFiller < 0
  
  zeroes = "0" * digitFiller
  return zeroes + stringNum
end
#==============================================================================#
#==============================================================================#
#                              DISPLAY NUMBER LCD                              #
#==============================================================================#
#A simple function to represent a number with graphics.
#==============================================================================#
def pbDisplayNumberLCD(number, _digits, numDigits, numWidth, numHeight)
  daSteps = pbChDigitsAmount(number)
  daSteps = daSteps.to_s.split("")

  for i in 0...numDigits
    _digits[numDigits - 1 - i].set_src_rect(daSteps[i].to_i * numWidth, 0, numWidth, numHeight)
  end
end
#==============================================================================#
#==============================================================================#
#                         U.A.R.M. functions for sprites!                      #
#==============================================================================#
# Methods to apply basic Physics to sprites!
# Note: gravitation force is much weaker in the sprite world
# Note: Notice that since y axis grows downwards, gravity is now positive.
#==============================================================================#
#calculate next uarm position:
def pbNext_mrua_Pos(sprite,speed=[0,0],timePassed=1,g=1)
  sprite.x = (sprite.x + speed[0]*timePassed).to_i
  sprite.y = (sprite.y - speed[1]*timePassed + (g*timePassed*timePassed)/2).to_i
  sy = speed[1] - g*timePassed
  _speed = [speed[0],sy]
  return _speed
end

#calculate next n uarm positions:
def pbMrua(sprite,speed=[0,0],frames=1,deltaTime=1,g=1)
  _speed = speed
  frames.times do
    _speed = pbNext_mrua_Pos(sprite,_speed,deltaTime,g)
    Graphics.update
  end
end
#==============================================================================#
#==============================================================================#
#                               BUTTON ANIMATION                               #
#==============================================================================#
# An easy function to handle pressed button animations.
# Call pbBtnAnimation(sprite,frames,delay) where
#    -sprite is the sprite to play the animation
#    -frames is the number of frames the graphic has
#    -se is the sound to be played when clicked
#    -delay is de time between each frame
#==============================================================================#
def pbBtnAnimation(sprite,frames,se="",delay=2)
  btnWidth  = sprite.bitmap.width
  btnHeight = sprite.bitmap.height
  btnFr = btnWidth/frames
  
  pbSEPlay(se)
  for i in 0...frames
    sprite.src_rect.set(((i+1)%frames)*btnFr,0,btnFr,btnHeight)
    pbWait(delay)
  end
end
#==============================================================================#
#==============================================================================#
#                              AMBIENT SOUND                                   #
#==============================================================================#
# A function to add ambient sounds!
# 0. Create an event with parallel trigger at the source point
# 1. Call the script pbAmbSound(SOUNDFILE,EVENT_ID,MAX_VOLUME,SCOPE_RADIUS)
#
# NOTE:
#   -The files will be placed at SE folder.
#   -If at some point the radius is bigger than the distance to the map border,
#    then the SE will still be noticeable when the player goes out of the map.
#   -Only one ambient sound per map (for the moment)
#
# example: pbAmbSound("Crowd.mp3",24,80,15)
# =>The file "Crowd.mp3" will be played and you will start hearing at a distance
# of 15 tiles. The volume will be at 80 when you are on the source point. The
# event id that calls the script is 24.
#==============================================================================#
def pbAmbSound(soundFile,eventId,maxVolume,radius)
  if !$Battle_Started
    radius = radius.to_f
    distance = 0.0
    _maxVolume = maxVolume.to_f
    
    if $game_map.events[eventId]
      if ($game_player.x - $game_map.events[eventId].x).abs >= ($game_player.y - $game_map.events[eventId].y).abs
        distance = ($game_player.x - $game_map.events[eventId].x).abs
      else
        distance = ($game_player.y - $game_map.events[eventId].y).abs
      end
      distance = 1 if distance == 0
      
      if distance >= radius
        volume = 0
      else
        volume =(_maxVolume - (distance * _maxVolume.to_f/radius)).to_i + 30
      end
      
      volume = _maxVolume if volume > maxVolume + 30
  
      pbBGSPlay(soundFile,volume,100)
    end
  else
    pbBGSPlay(soundFile,0,100)
  end
end
#==============================================================================#
#==============================================================================#
#                           LINEAR AMBIENT SOUNDS                              #
#==============================================================================#
# A function to add ambient sounds for bigger objects, like for example a coast.
# 0. Create an event with parallel trigger at the source point and Call the
# script: pbLAmbSound(SOUNDFILE,EVENT_ID,MAX_VOLUME,RANGE,MODE,LEFT/RIGHT)
# where MODE is true or false, being true horizontal and false vertical. You can
# also ommit this if want a vertical ambient; LEFT/RIGHT accepts true or false,
# and that will be the side of the sound sourece where the sounfile won't be
# played lower as you get away in that direction (false for left or up, true for
# right or down). Again, this is for sounds like the sea waves,
# for example.
#
# NOTE:
#   -The files will be placed at SE folder.
#   -If at some point the radius is bigger than the distance to the map border,
#    then the SE will still be noticeable when the player goes out of the map.
#   -Only one ambient sound per map (for the moment)
#
# example: pbLAmbSound("Waves.mp3",24,80,15)
# =>The file "Waves.mp3" will be played and you will start hearing at a distance
# of 15 tiles. The volume will be at 80 when you are on the source point. The
# event id that calls the script is 24. It will be in vertical and the volume will
# be lowered when you walk westwards.
#==============================================================================#
def pbLAmbSound(soundFile,eventId,maxVolume,range,mode=false,side=false)
  if @map_id==$game_map.map_id
    daRange = range.to_f
    daDistance = 0.0
    daMaxVolume = maxVolume.to_f
    
    if mode
      daPlayerPos = $game_player.y
      daEventPos = $game_map.events[eventId].y
    else
      daPlayerPos = $game_player.x
      daEventPos = $game_map.events[eventId].x
    end
    
    if $game_map.events[eventId]
      daDistance += (daPlayerPos - daEventPos)
      daDistance = 1 if daDistance == 0
      
      if (mode && daDistance < 0) || (!mode && daDistance >= 0)
        daDistance = daDistance.abs
        if daDistance >= daRange
          volume = 0
        else
          volume =(daMaxVolume - (daDistance * daMaxVolume.to_f/range)).to_i + 30
        end
      else
        volume = daMaxVolume + 30
      end
      
      volume = daMaxVolume + 30 if volume > daMaxVolume + 30
  
      pbBGSPlay(soundFile,volume,100)
    end
  end
end
#==============================================================================#
#==============================================================================#
#                              PLAY BGM WITH INTRO                             #
#==============================================================================#
# A function to play bgm with an intro that will be played only once:          #
# 0. Call the intro file the same as the main audio file you want to play, but #
#   add "_intro" at the end of it.                                             #
# 1. Place the intro file in ME and the main audio file in BGM.                #
# Call pbPlayBGM_withIntro(YOURFILE,VOLUME,PITCH) where:                       #
#   -YOURFILE is the name of your file (without "_intro")                      #
#   -VOLUME is, the volume you want to play it at (you can omit this param)    #
#   -PTICH is the pitch you want to play it at (you can also omit this param)  #
#                                                                              #
# example: pbPlayBGM_withIntro("Caught.mp3")                                   #
# =>The file "Caught.mp3" will be played and you will start hearing at the     #
# standard volume and pitch                                                    #
#==============================================================================#
def pbPlayBGM_withIntro(audioFile=nil,volume=100,pitch=100)
  pbMEPlay(audioFile + "_Intro",volume,pitch)
  pbBGMPlay(audioFile,volume,pitch)
end
#==============================================================================#
#                      Small function to add items anywhere                    #
#==============================================================================#
#for adding one or more items without noticing to the player at all.
def pbAddItem(item,amount=1)
  amount.times do
    $PokemonBag.pbStoreItem(item)
  end
end

#for adding one or more items in a more custom way
def pbAddLotsOfItems(item, amount = 1, playFanfare=true, showMessage = true)
  pbMEPlay("BW2GetKeyItem.wav",100,100) if playFanfare
  pocket=pbGetPocket(getID(PBItems,item))
  
  if amount >= 2
    Kernel.pbMessageBlack(0,false,_INTL("{1} obtained <c3=52b5ff,29638c>{2}s\\c[0]!\1",$Trainer.name,PBItems.getName(getID(PBItems,item)))) if showMessage
    Kernel.pbMessageBlack(0,false,_INTL("{1} put the <c3=52b5ff,29638c>{2}s\\c[0]\r in the <c3=52b5ff,29638c>{3}\\c[0] Pocket.",
    $Trainer.name,PBItems.getName(getID(PBItems,item)),PokemonBag.pocketNames()[pocket]))
  elsif amount == 1
    Kernel.pbMessageBlack(0,false,_INTL("{1} obtained <c3=52b5ff,29638c>{2}\\c[0]!\1",$Trainer.name,PBItems.getName(getID(PBItems,item)))) if showMessage
    Kernel.pbMessageBlack(0,false,_INTL("{1} put the <c3=52b5ff,29638c>{2}\\c[0]\r in the <c3=52b5ff,29638c>{3}\\c[0] Pocket.",
    $Trainer.name,PBItems.getName(getID(PBItems,item)),PokemonBag.pocketNames()[pocket]))
  end

  pbAddItem(item,amount)
end
#==============================================================================#
#                Function to rescale a picture relative to a point             #
#                                    (deprecated)                              #
#==============================================================================#
def pbApplyRescaleRel(pic,relOX,relOY,scale); end
#==============================================================================#
#              Function to dispose all the graphics in a hash map              #
#==============================================================================#
def pbDisposeGraphicsOf(hashMap, exception1 = "", exception2 = "")
  for key in hashMap.keys
    hashMap[key].dispose unless key == exception1 || key == exception2
  end
  
  object = {}
end
#==============================================================================#
#              Small function to raise a custom exception message              #
#==============================================================================#
def pbThrow(msg="",closeGame=false)
  p msg
  Kernel.exit! if closeGame
end
#==============================================================================#
#            Classes to handle all the objects created by my scripts           #
#      (This class and all its childs implement the "Composite" pattern)       #
#==============================================================================#
#==============================================================================#
#                                 SMObject                                     #
#                              (parent class)                                  #
#==============================================================================#
class SMObject
  def initialize(viewport=nil)
    @objectsList={} #objects hash
    
    @spriteViewport= viewport == nil ?
      Viewport.new(0,0,Graphics.width,Graphics.height) : viewport
    @spriteViewport.z=999
  end

  def insertObj(obj,key); @objectsList[key]=obj; end
    
  def pbEndScene
    pbDisposeSpriteHash(@objectsList)
  end
    
 #GETTERS
  def toString;  end
  def getViewport; return @spriteViewport; end
  def list; return @objectsList; end
  def objectsList(key)
    ret =nil
    if @objectsList[key]
      ret = @objectsList[key]
    else
      for i in @objectsList.keys
        ret = @objectsList[i].objectsList(key)
        break if ret != nil
      end
    end
    
    return ret
  end
end
#==============================================================================#
#                                  SMSprite                                    #
#                       (subclass that handles sprites)                        #
#==============================================================================#
class SMSprite < SMObject
  def initialize(x=0,y=0,path="",viewport=nil,managerRef=nil)
    super(viewport)
    @managerRef = managerRef
    @sprite = Sprite.new(@spriteViewport)
    @sprite.bitmap=Bitmap.new(path) if path != ""
    @sprite.x=x
    @sprite.y=y
    @path=path
    
    @x=x
    @y=y
  end

 #GETTERS:
  def x;         return @sprite.x;             end
  def y;         return @sprite.y;             end
  def ox;        return @sprite.ox;            end
  def oy;        return @sprite.oy;            end
  def z;         return @sprite.z;             end
  def zoom_x;    return @sprite.zoom_x;        end
  def zoom_y;    return @sprite.zoom_y;        end
  def visible;   return @sprite.visible;       end
  def opacity;   return @sprite.opacity;       end
  def bitmap;    return @sprite.bitmap;        end
  def width;     return @sprite.bitmap.width;  end
  def height;    return @sprite.bitmap.height; end    
  def sprite;    return @sprite;               end
  def disposed?; return @sprite.disposed?;     end
  def angle;     return @sprite.angle;         end
  def tone;      return @sprite.tone;          end
  def path;      return @path;                 end
    
  #SETTERS:
  def addObj(key,_x,_y,path="",viewport=@spriteViewport)
    @objectsList[key]=SMSprite.new(@sprite.x+_x,@sprite.y+_y,path,viewport,self)
  end
  
  def x=(val)
    for i in @objectsList.keys
      relx = @objectsList[i].x - @sprite.x
      @objectsList[i].x= val+relx
    end
    @sprite.x = val
    @x=val
  end
    
  def y=(val)
    for i in @objectsList.keys
      rely = @objectsList[i].y - @sprite.y
      @objectsList[i].y= val+rely
    end
    @sprite.y = val
    @y=val
  end
  
  def z=(val)
    @sprite.z = val
    for i in @objectsList.keys; @objectsList[i].z= val; end
  end
  
  def ox=(val); @sprite.ox=val; end
  def oy=(val); @sprite.oy=val; end
  
  def zoom_x=(val)
    @sprite.zoom_x=val
    
    for i in @objectsList.keys
      @objectsList[i].rescaleX_rel(val,@sprite.x)
    end
  end
  def zoom_y=(val)
    @sprite.zoom_y=val
    
    for i in @objectsList.keys
      @objectsList[i].rescaleY_rel(val,@sprite.y)
    end
  end
  
  def rescaleX_rel(scale,relOX=@sprite.x)
    @sprite.x = relOX + (@x - relOX) * scale
    @sprite.zoom_x = scale
    
    for i in @objectsList.keys; @objectsList[i].rescaleX_rel(scale,relOX); end
  end
    
  def rescaleY_rel(scale,relOY=@sprite.y)
    @sprite.y = relOY + (@y - relOY) * scale
    @sprite.zoom_y = scale
    for i in @objectsList.keys; @objectsList[i].rescaleY_rel(scale,relOY); end
  end
    
  def rescale_rel(scale,relOX=@sprite.x,relOY=@sprite.y)
    rescaleX_rel(POKETCH_SCALE,POKETCHXPOS)
    rescaleY_rel(POKETCH_SCALE,POKETCHYPOS)
  end
  
  def setSystemFont; pbSetSystemFont(@sprite.bitmap); end
  def drawText(val); pbDrawTextPositions(@sprite.bitmap,val); end
  def drawFTextEx(val); drawFormattedTextEx(@sprite.bitmap,val[0],val[1],val[2],val[3],val[4],val[5]); end
  
  def visible=(val)
    @sprite.visible=val
    for i in @objectsList.keys; @objectsList[i].visible=val; end
  end
  
  def opacity=(val)
    @sprite.opacity=val
    for i in @objectsList.keys; @objectsList[i].opacity=val; end
  end
    
  def bitmap=(val); @sprite.bitmap=val; end
  def set_src_rect(x,y,w,h); @sprite.src_rect.set(x,y,w,h); end
    
  def clear
    @sprite.bitmap.clear
    for i in @objectsList.keys; @objectsList[i].clear; end
  end
  
  def dispose
    @sprite.dispose if @sprite && !@sprite.disposed?
    for key in @objectsList.keys; @objectsList[key].dispose; end
  end
    
  def angle=(val)
    @sprite.angle=val
    
    #this needs to be fixed:
    for key in @objectsList.keys; @objectsList[key].angle=val; end
  end
    
  def red=(val)
    @sprite.tone.red=val
    for key in @objectsList.keys; @objectsList[key].red=val; end
  end
    
  def green=(val)
    @sprite.tone.green=val
    for key in @objectsList.keys; @objectsList[key].green=val; end
  end
  
  def blue=(val)
    @sprite.tone.blue=val
    for key in @objectsList.keys; @objectsList[key].blue=val; end
  end
    
  def gray=(val)
    @sprite.tone.gray=val
    for key in @objectsList.keys; @objectsList[key].gray=val; end
    end
    
  def path=(val); @path = val; end
  
  def curtainEffect(frames,dir,mode,scale=1)
    if mode == "h"
      for i in 0...frames
        self.zoom_x=(@sprite.zoom_x + dir*(1.0/frames)*scale)
        pbWait(1)
      end
    elsif mode == "v"
      for i in 0...frames
        self.zoom_y=(@sprite.zoom_y + dir*(1.0/frames)*scale)
        pbWait(1)
      end
    end
  end
    
  def fadeInOutSprite(sprite,frames,mode,delay=2)
    ok = false
    if sprite == nil
      fadeInOutSprite(self,frames,mode,delay)
    elsif @objectsList[sprite]
     begin
        obj = @objectsList[sprite]
        frames.times do
          obj.opacity=obj.opacity+mode*255/frames
          pbWait(delay)
          break if obj.opacity >= 255 || obj.opacity <= 0
        end
        ok = true
      rescue
        pbThrow("WARNING: Don't set the value of parameter 'frames' from function fadeInOutSprite to 0.",false)
        fadeInOutSprite(sprite,1,mode,delay)
      end
    else
      for i in @objectsList.keys
        ok = @objectsList[i].fadeInOutSprite(sprite,frames,mode,delay)
        break if ok
      end
    end
    return ok
  end
    
  def leftClick?(obj=nil,frames=1,se="",delay=2)
    ok = nil
    if obj == nil; ok = $mouse.leftClick?(@sprite); obj = @sprite
    elsif @objectsList[obj]
      obj = @objectsList[obj].sprite
      ok = $mouse.leftClick?(obj)
    else
      for i in @objectsList.keys
        ok = @objectsList[i].leftClick?(obj,frames,se,delay) && ($mouse.x - obj.x) < obj.bitmap.width/frames
        break if ok != nil
      end
    end
    
    pbBtnAnimation(obj,frames,se,delay) if ok
    return ok
  end
  
  def rightClick?(obj=nil,frames=1,se="",delay=2)
    ok = nil
    if obj == nil; ok = $mouse.rightClick?(@sprite); obj = @sprite
    elsif @objectsList[obj]
      obj = @objectsList[obj].sprite
      ok = $mouse.rightClick?(obj)
    else
      for i in @objectsList.keys
        ok = @objectsList[i].rightClick?(obj) && ($mouse.x - obj.x) < obj.bitmap.width/frames
        break if ok != nil
      end
    end
    
    pbBtnAnimation(obj,frames,se,delay) if ok
    return ok
  end
end
#==============================================================================#
#                                    SMScreen                                  #
# (subclass that makes more user friendly placing and moving objects in blocks)#
#==============================================================================#
class SMScreen < SMSprite
  def initialize(path,name,x,y,viewport,managerRef=nil)
    super(x,y,path+name,viewport,managerRef)
    @path = path
  end
  
  def path; return @path; end
  def update; end
  def addObj(key,x,y,path=""); super(key,x,y,@path+path); end
  def updateRef(newVal); @managerRef = newVal; end
end
#==============================================================================#
# Just don't touch ============================================================#
 $Poketch_On_Forced = false
 $Battle_Started = false
 $this_Is_a_Trainer_Battle = false
 $CatchingTutorial = false
 $introName = ""
 
 BSX = DOUBLESCREEN ? BTM_SCREEN_X : TOP_SCREEN_X
 BSY = DOUBLESCREEN ? BTM_SCREEN_Y : TOP_SCREEN_Y
 
 $btmScreen = SMScreen.new("","",0,0,Viewport.new(BSX,BSY,SM_SCREEN_WIDTH,SM_SCREEN_HEIGHT))
 $topScreen = SMScreen.new("","",0,0,Viewport.new(TOP_SCREEN_X,TOP_SCREEN_Y,SM_SCREEN_WIDTH,SM_SCREEN_HEIGHT))
#==============================================================================#
# Here ends Somersault's settings                                              #
#==============================================================================#