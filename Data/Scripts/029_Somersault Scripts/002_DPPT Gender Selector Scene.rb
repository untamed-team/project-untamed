#==============================================================================#
#                         DPPT GENDER SELECTOR SCENE v2.1.1                    #
#                                (by A.Somersault)                             #
#==============================================================================#
# IMPORTANT: NEEDS SUSc v4.1+ in order to work properly                        #
#==============================================================================#
# Changelog 2.1.1 (25/6/2021):
# Fixed (more) minor SUSc-related problems
#-------------------------------------------------------------------------------
# Changelog 2.1 (21/6/2021):
# Fixed minor SUSc-related problems
#-------------------------------------------------------------------------------
# Changelog 2.0.1 (17/6/2021):
# -Polished a bit the quotes so that they fit more with the original cutscene
#-------------------------------------------------------------------------------
# Changelog 2.0 (3/6/2021):
# -Refactored to implement the new composite system SMObject;
# -Simplified code: grouped pairs of (very) similar functions into single ones.
#-------------------------------------------------------------------------------
# Changelog 1.2 (21/9/2020):
# Fixed a bug that happened only when selecting the boy: If you pressed escape in
# the nameCharacter menu, the script turned glitchy. Now solved.
#-------------------------------------------------------------------------------
# Changelog 1.1:
# Fixed a small bug: when selecting with the arrows for the first time, if you
# selected the male sprite, the script showed you the confirmation screen
# for the female and with an opacity of 127 instead of 255.
#===============================================================================
# How to use:
# Very simple. Just call pbDpptGdSelector and the script will show up. You must
# know that the script doesn't provide a background, though.
#
# You can also make an animated selector: you only have to make each graphic
# to contain all its corresponding animation frames.
#
# Note: Take in mind that after calling this script the player will lose all the
# items, Pokémon and pokédex, if they previously had one. Aka: a reset.
# So make sure you call it at the very start of your game.
#===============================================================================
#                                  PARAMETERS
#===============================================================================
GS_PATH = "Graphics/Pictures/"  #general path for both sprites

GENDERFEMALE = "introGirl.png"       #name of the female graphic.
GENDERMALE   = "introBoy.png"       #name of the male graphic.

ANIMATED = false              # whether the walking animation will be played

FRAMEWIDTH_M = 160              # width of each Male frame           
FRAMEHEIGHT_M = 160            # height of each Male frame

FRAMEWIDTH_F = 160              # width of each Female frame           
FRAMEHEIGHT_F = 160            # height of each Female frame

NUMFRAMES = 1                # number of frames in the animation
INVSPEED = 6                 #as higher, as slower the animation will be (min 1)

#Positioning modified by SpaceWestern
#Coordinates of the script 
SCRIPT_X_POS = 176 # Centered at 256, offset by 80 for some reason
SCRIPT_Y_POS = 100

#male position on screen:
MALEX = -85
MALEY = 0

#female position on screen:
FEMALEX = 85
FEMALEY = 0
#===============================================================================
#===============================================================================
class DpptGdSelScene < SMScreen
  def initialize(viewport,managerRef=nil)
    super("","",SCRIPT_X_POS,SCRIPT_Y_POS,viewport,managerRef)
    @select=0
    @brDone = false
    @finished=false
  
    #FEMALE TRAINER
    addObj("girl",FEMALEX,FEMALEY,GS_PATH+GENDERFEMALE)
    @objectsList["girl"].set_src_rect(0,0,FRAMEWIDTH_F,FRAMEHEIGHT_F)

    #MALE TRAINER
    addObj("boy",MALEX,MALEY,GS_PATH+GENDERMALE)
    @objectsList["boy"].set_src_rect(0,0,FRAMEWIDTH_M,FRAMEHEIGHT_M)

    for i in @objectsList.keys
      @objectsList[i].zoom_x=1
      @objectsList[i].zoom_y=1
      @objectsList[i].opacity=0
    end
    
    @objectsList["msgwindow"]=Kernel.pbCreateMessageWindow(@spriteViewport)
  end

  def pbHideShow(mode)
    10.times do
      Graphics.update
      @objectsList["boy"].opacity=@objectsList["boy"].opacity+25.5*mode
      @objectsList["girl"].opacity=@objectsList["girl"].opacity+25.5*mode
    end
  end
  
  INVSPEED = INVSPEED.abs
  INVSPEED = 1 if INVSPEED == 0

#===============================================================================  

  def selectChar(mode)
    @brDone = false
    @select = mode
    frame=0
    
    @vars={}
    case mode
      when 0;
        @vars["gender0"]="boy"
        @vars["gender1"]="girl"
        @vars["dir"]=Input::RIGHT
        @vars["frW"]=FRAMEWIDTH_M
        @vars["frH"]=FRAMEHEIGHT_M
      when 1;
        @vars["gender0"]="girl"
        @vars["gender1"]="boy"
        @vars["dir"]=Input::LEFT
        @vars["frW"]=FRAMEWIDTH_F
        @vars["frH"]=FRAMEHEIGHT_F       
    end
    @objectsList[@vars["gender0"]].opacity=255
    @objectsList[@vars["gender1"]].opacity=125
    
    loop do
      Input.update
      if Input.trigger?(@vars["dir"])
        @select = 1-@select
      elsif Input.trigger?(Input::C)
        @brDone = true
      end
      break if @brDone || Input.trigger?(@vars["dir"])
      
      Graphics.update
      if ANIMATED
        @objectsList[@vars["gender0"]].set_src_rect((frame / NUMFRAMES) * @vars["frW"], 0, @vars["frW"], @vars["frH"]) if frame % NUMFRAMES == 0
        frame += 1
        frame = frame % (INVSPEED * NUMFRAMES)
      end
    end
  end
#===============================================================================
  def selection
    sign = @select == 0 ? 1 : -1
    17.times do
      Graphics.update
      @objectsList[@vars["gender1"]].opacity=@objectsList[@vars["gender1"]].opacity-15
      @objectsList[@vars["gender0"]].x=@objectsList[@vars["gender0"]].x+5*sign
    end
    
    if !Kernel.pbConfirmMessage(_INTL("All done?"))
      17.times do
        Graphics.update
        @objectsList[@vars["gender1"]].opacity=@objectsList[@vars["gender1"]].opacity+7.5
        @objectsList[@vars["gender0"]].x=@objectsList[@vars["gender0"]].x-5*sign
      end
      @objectsList["msgwindow"].visible=true
      
      #Kernel.pbMessageDisplay(@objectsList["msgwindow"],
      #_INTL("Get ready!"))
      @select = 0
    else
      #Added/adjusted by SpaceWestern & stygma
      if @select == 0
      pbChangePlayer(1)
      else
      pbChangePlayer(2)
      end
      @objectsList["msgwindow"].visible=false
      #Kernel.pbMessage("What is your name?")
      #selectName
      #Kernel.pbMessage("What are your pronouns?")
      #pbPronouns
      #Kernel.pbMessage("\\xn[Ceiba]Ok, now hold still...")
      #pbWait(5)
      #pbFlash(Color.new(255, 255, 255, 128), 5)
      #pbSEPlay("picture snap",80,100)
      pbWait(30)
      pbHideShow(-1)
      @finished=true
    end
  end
#===============================================================================

  def selectName
    pbTrainerName
    if !Kernel.pbConfirmMessage(_INTL("Your name is {1}?",$Trainer.name))
      #selectName
    else
      #Kernel.pbMessage("A fine name, that is!")
    end
  end
 
  def pbUpdate
    pbHideShow(1)
    Kernel.pbMessageDisplay(@objectsList["msgwindow"],
        _INTL("\\wtnp[1]Get ready!"))
    selectChar(@select)
    loop do
      loop do    
        selectChar(@select)
        break if @brDone
      end
      selection
      break if @finished
    end
  end
end
################################################################################

class DpptGdSelector
  def initialize
    @scene = DpptGdSelScene.new($topScreen.getViewport)
    pbStartScreen
  end

  def pbStartScreen
   @scene.pbUpdate
   @scene.pbEndScene
  end
end

def pbDpptGdSelector
  screen=DpptGdSelector.new
end