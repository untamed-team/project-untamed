################################################################################
# "BerryPots for Essentials"
# Version 1.1
# By Caruban
#
# 1.1 Change log
# - Support planting apricorns
# - bug fixes: pbReceivePots error
# - bug fixes: fertilizer only can choose to plant a berry
#-------------------------------------------------------------------------------
# Run with:      pbBerryPots
#
# Add more pot by using this script:
# pbReceivePots or pbReceivePots(qty) for more than 1 pots.
################################################################################
#===============================================================================
# SETTINGS
#===============================================================================
# The count of Pots the player starts with.
INITIAL_POT_COUNT = 4

CAN_PLANT_APRICORN = false

#===============================================================================
# BerryPots Command
#===============================================================================
def pbBerryPots
  pbFadeOutIn{
    scene = ItemBerryPots_Scene.new
    screen = ItemBerryPots_Screen.new(scene)
    ret = screen.pbStartScreen
  }
end

def pbReceivePots(count=1)
  $PokemonGlobal.berrypot_count = INITIAL_POT_COUNT if !$PokemonGlobal.berrypot_count
  return false if $PokemonGlobal.berrypot_count >= 10
  count.times{|i|
    $PokemonGlobal.berrypot_count += 1
    break if $PokemonGlobal.berrypot_count == 10
  }
  return true
end
#===============================================================================
# PokemonGlobalMetadata
#===============================================================================
class PokemonGlobalMetadata
  attr_accessor :berrypots
  attr_accessor :berrypot_count
  attr_accessor :berrypots_can
end

#===============================================================================
# Pots Scene
#===============================================================================  
class ItemBerryPots_Screen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    ret = @scene.pbScene
    @scene.pbEndScene
    return ret
  end
end

class ItemBerryPots_Scene
  def potsCount
    $PokemonGlobal.berrypot_count = INITIAL_POT_COUNT if !$PokemonGlobal.berrypot_count
    return $PokemonGlobal.berrypot_count
  end
  def xPos(i)
    pos = 54*(i%5)
    pos += 24 if potsCount <= 4
    return pos
  end
  def yPos(i); return potsCount < 5 ? 0 : i/5 == 0 ? -28 : 28 ;end
  def pbStartScene
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @index = 0
    @frame = 0
    @anim = 0
    $PokemonGlobal.berrypots=[] if !$PokemonGlobal.berrypots
    @berry_plant=$PokemonGlobal.berrypots
    for i in 0...potsCount
      @berry_plant[i] = BerryPlantData.new if !@berry_plant[i]
      @berry_plant[i].update if @berry_plant[i].planted?
    end
    @sprites = {}
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/BerryPots/bg_pot"))
    @sprites["space"] = IconSprite.new(0,64,@viewport)
    @sprites["space"].setBitmap(_INTL("Graphics/Pictures/BerryPots/pot_space"))
    @spark = []
    for i in 0...potsCount
      @sprites["pot#{i}"] = IconSprite.new(4 + xPos(i),136+yPos(i),@viewport)
      @sprites["pot#{i}"].setBitmap(_INTL("Graphics/Pictures/BerryPots/pot"))
      @sprites["soil#{i}"] = IconSprite.new(14 + xPos(i) + 2,182+yPos(i) - 16,@viewport)#(38 + 54*i,182,@viewport)
      @sprites["soil#{i}"].setBitmap(_INTL("Graphics/Characters/berrytreeDry"))
      
      @sprites["plant#{i}"] = IconSprite.new(70,102,@viewport)
      @sprites["plant#{i}"].setBitmap("Graphics/Characters/berrytreeplanted")
      charwidth  = @sprites["plant#{i}"].bitmap.width
      charheight = @sprites["plant#{i}"].bitmap.height
      @sprites["plant#{i}"].x = (30-charwidth/8) + xPos(i) + 2
      @sprites["plant#{i}"].y = 172-charheight/8 + yPos(i) - 16
      @sprites["plant#{i}"].z = 10
      @sprites["plant#{i}"].src_rect = Rect.new(0,charheight*3/4,charwidth/4,charheight/4)

      @sprites["spark#{i}"] = IconSprite.new(150,150,@viewport)
      @sprites["spark#{i}"].setBitmap(_INTL("Graphics/Animations/Overworld dust and grass"))
      @sprites["spark#{i}"].src_rect = Rect.new(0,192,192,192)
      @sprites["spark#{i}"].x = -62 + xPos(i)
      @sprites["spark#{i}"].y = 80 + yPos(i)
      @sprites["spark#{i}"].z = 12
      @sprites["spark#{i}"].visible = false
      @spark.push(0)
    end
    @sprites["arrowu"] = IconSprite.new(452,178,@viewport)
    @sprites["arrowu"].setBitmap(_INTL("Graphics/Pictures/BerryPots/arrowu"))
    @sprites["arrowu"].src_rect = Rect.new(0,0,24,22)
    @sprites["arrowu"].z = 8
    @sprites["arrowd"] = IconSprite.new(452,246,@viewport)
    @sprites["arrowd"].setBitmap(_INTL("Graphics/Pictures/BerryPots/arrowd"))
    @sprites["arrowd"].src_rect = Rect.new(0,0,24,22)
    @sprites["arrowd"].z = 8
    @sprites["arrowu"].visible = false
    @sprites["arrowd"].visible = false
    
    @sprites["cancel"] = IconSprite.new(384,328,@viewport)
    @sprites["cancel"].setBitmap(_INTL("Graphics/Pictures/BerryPots/cancel_btn"))
    @sprites["cancel"].src_rect = Rect.new(0,0,124,48)
    @sprites["cancel"].z = 8
    
    @cursorname = "cursor-anim"
    @sprites["cursor"] = IconSprite.new(0,150,@viewport)
    @sprites["cursor"].setBitmap(_INTL("Graphics/Pictures/BerryPots/"+@cursorname))
    @sprites["cursor"].src_rect = Rect.new(0,0,64,64)
    @sprites["cursor"].z = 9
    
    @can_temp = []
    GameData::BerryPlant::WATERING_CANS.each_with_index do |item,i|
      next if !$bag.has?(item)
      $PokemonGlobal.berrypots_can = item if !$PokemonGlobal.berrypots_can || !$bag.has?($PokemonGlobal.berrypots_can)
      @can_temp.push(item)
    end
    @item = $bag.has?($PokemonGlobal.berrypots_can) ? $PokemonGlobal.berrypots_can : nil
    @item = :SQUIRTBOTTLE if !@item && $DEBUG
    @can_id = @can_temp.length > 0 ? @can_temp.index(@item) : nil
    @sprites["spray"] = IconSprite.new(0,0,@viewport)
    @sprites["spray"].setBitmap(_INTL("Graphics/Pictures/BerryPots/#{@item}"))
    @sprites["spray"].visible = false
    @sprites["spray"].z = 11

    @sprites["spray_item"] = IconSprite.new(440,198,@viewport)
    @sprites["spray_item"].setBitmap(_INTL("Graphics/Items/#{@item}"))
    @sprites["spray_item"].visible = (@can_temp.length > 1)
    @sprites["spray_item"].z = 7

    @sprites["space_can"] = IconSprite.new(412,172,@viewport)
    @sprites["space_can"].setBitmap(_INTL("Graphics/Pictures/BerryPots/space_watering_can"))
    @sprites["space_can"].visible = (@can_temp.length > 1)
    @sprites["space_can"].z = 5

    @sprites["helpwindow"] = Window_AdvancedTextPokemon.new("")
    pbBottomLeftLines(@sprites["helpwindow"], 2,Graphics.width-128)
    @sprites["helpwindow"].viewport = @viewport
    @sprites["helpwindow"].setSkin(MessageConfig.pbGetSpeechFrame)
    @sprites["helpwindow"].text = "Choose one of the\nBerry Pots."
    
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
  
  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
  
  def pbUpdateCursor
    @sprites["cancel"].src_rect.y = 0
    case @index
    when -1 
      curtype = "cursor_watering_can"
      @sprites["cursor"].x = 418
      @sprites["cursor"].y = 184
      text = "Change the Watering Can."
    when -2
      curtype = "cursor_cancel"
      @sprites["cursor"].x = 380
      @sprites["cursor"].y = 324
      @sprites["cancel"].src_rect.y = @sprites["cancel"].bitmap.height/2
      text = "Quit the Berry Pots."
    else
      curtype = "cursor-anim"
      @sprites["cursor"].x = xPos(@index)
      @sprites["cursor"].y = 150+yPos(@index)
      text = "Choose one of the\nBerry Pots."
    end
    file = _INTL("Graphics/Pictures/BerryPots/"+curtype)
    if @cursorname != curtype
      @cursorname = curtype
      @sprites["cursor"].setBitmap(file)
      @sprites["cursor"].src_rect.width = @sprites["cursor"].bitmap.width/2
      @sprites["cursor"].src_rect.height = @sprites["cursor"].bitmap.height
      @sprites["helpwindow"].text = text
    end
  end

  def pbUpdate
    for i in 0...potsCount
      berry_plant = @berry_plant[i]
      old_growth = berry_plant.growth_stage
      berry_plant.update if berry_plant.planted?
      pbUpdateSoilSprite(berry_plant,i)
      pbUpdatePlantSprite(berry_plant,i,old_growth)
    end
    pbUpdateAnim
    pbUpdateCursor
    pbUpdateSpriteHash(@sprites)
  end
  
  def pbUpdateSoilSprite(berry_plant,i)
    moisture_stage=-1
    if berry_plant.is_a?(BerryPlantData) && berry_plant.planted?
      new_moisture = berry_plant.moisture_stage
    end
    if new_moisture != moisture_stage
      moisture_stage = new_moisture if new_moisture
      case moisture_stage
      when -1 then @sprites["soil#{i}"].setBitmap("")
      when 0  then @sprites["soil#{i}"].setBitmap("Graphics/Characters/berrytreedry")
      when 1  then @sprites["soil#{i}"].setBitmap("Graphics/Characters/berrytreedamp")
      when 2  then @sprites["soil#{i}"].setBitmap("Graphics/Characters/berrytreewet")
      end
    end
  end
  
  def pbUpdatePlantSprite(berry_plant,i,old_growth)
    berry_plant = BerryPlantData.new if !berry_plant || !berry_plant.is_a?(BerryPlantData)
    case berry_plant.growth_stage
    when 0
      nama = ""
    when 1
      nama = "berrytreeplanted"   # Common to all berries
    else
      filename = sprintf("berrytree_%s", GameData::Item.get(berry_plant.berry_id).id.to_s)
      if pbResolveBitmap("Graphics/Characters/" + filename)
        nama = filename
      else
        nama = "Object ball"
      end
    end
    @sprites["plant#{i}"].setBitmap("Graphics/Characters/#{nama}")
    charwidth  = @sprites["plant#{i}"].bitmap.width
    charheight = @sprites["plant#{i}"].bitmap.height
    if berry_plant.growth_stage>1
      stage = (berry_plant.growth_stage-2).clamp(0,3)
      @sprites["plant#{i}"].src_rect = Rect.new(0,charheight*stage/4,charwidth/4,charheight/4)
    else
      @sprites["plant#{i}"].src_rect = Rect.new(0,0,charwidth/4,charheight/4)
    end
    if berry_plant.new_mechanics && old_growth != berry_plant.growth_stage &&
        old_growth > 0 && berry_plant.growth_stage <= GameData::BerryPlant::NUMBER_OF_GROWTH_STAGES + 1
        @spark[i] = 24
        @sprites["spark#{i}"].visible = true
    end
  end
  
  def pbWateringAnim(i)
    @sprites["spray"].x = xPos(i)
    @sprites["spray"].y = 80 + yPos(i)
    @sprites["spray"].visible = true
    charwidth  = @sprites["spray"].bitmap.width
    charheight = @sprites["spray"].bitmap.height
    frame=0 ; anim=0
    animtree = @anim
    charwidthtree  = @sprites["plant#{i}"].bitmap.width
    charwidthcursor  = @sprites["cursor"].bitmap.width
    loop do
      if frame == 10
        @sprites["spray"].setBitmap("Graphics/Pictures/BerryPots/#{@item}_anim")
        @sprites["spray"].src_rect = Rect.new(0,0,charwidth,charheight)
      end
      if frame>10 && frame<80
        anim += 1 if frame%10==0
        anim = 0 if anim > 1
        @sprites["spray"].src_rect.x = charwidth*anim
        pbSEPlay("Anim/sand",20) if anim == 1
      end
      if frame == 80
        @sprites["spray"].setBitmap("Graphics/Pictures/BerryPots/#{@item}")
        @sprites["spray"].src_rect = Rect.new(0,0,charwidth,charheight)
      end
      # anim berry tree
      animtree += 1 if frame%10==0
      animtree=0 if animtree>3
      for i in 0...potsCount
        @sprites["plant#{i}"].src_rect.x = charwidthtree*animtree/4
      end
      # anim cursor
      @sprites["cursor"].src_rect.x = charwidthcursor*(animtree%2)/2
      pbWait(1)
      break if frame == 90
      frame += 1
    end
    @anim = animtree
    @sprites["spray"].visible = false
  end
  
  def pbUpdateAnim
    @frame +=1
    if @frame>10
      @frame=0
      @anim+=1
      @anim=0 if @anim>3
    end
    for i in 0...potsCount
      charwidth  = @sprites["plant#{i}"].bitmap.width
      @sprites["plant#{i}"].src_rect.x = charwidth*@anim/4
      @sprites["spark#{i}"].src_rect.x = 192*(@anim%2 + 2)
      if @spark[i] > 0
        @spark[i] -= 1
        @sprites["spark#{i}"].visible = false if @spark[i] == 0
      end
    end
    charwidthcursor  = @sprites["cursor"].bitmap.width
    @sprites["cursor"].src_rect.x = charwidthcursor*(@anim%2)/2
    @sprites["arrowu"].src_rect.x = @sprites["arrowu"].bitmap.width*(@anim%2)/2
    @sprites["arrowd"].src_rect.x = @sprites["arrowd"].bitmap.width*(@anim%2)/2
  end
  
  def pbScene
    loop do
      Graphics.update
      Input.update
      pbUpdate
      y = @index >= 0 ? @index/5 : 0
      oldindex = @index
      oldid = @can_id
      if Input.trigger?(Input::USE)
        if @index >= 0
          pbPlayDecisionSE
          pbBerryPlantVar(@index)
        elsif @index == -1 && @can_temp.length > 1
          @sprites["cursor"].visible = false
          olditem = @item
          loop do
            Graphics.update
            Input.update
            pbUpdate
            old_can_id = @can_id
            if Input.trigger?(Input::BACK)
              pbPlayCloseMenuSE
              @item = olditem
              @can_id = oldid
              @sprites["spray"].setBitmap(_INTL("Graphics/Pictures/BerryPots/#{@item}"))
              @sprites["spray_item"].setBitmap(_INTL("Graphics/Items/#{@item}"))
              break
            elsif  Input.trigger?(Input::USE)
              pbPlayDecisionSE
              $PokemonGlobal.berrypots_can = @can_temp[@can_id]
              @item = @can_temp[@can_id]
              break
            elsif Input.trigger?(Input::UP) && @can_id > 0
              @can_id -= 1
              @item = @can_temp[@can_id]
            elsif Input.trigger?(Input::DOWN) && @can_id < @can_temp.length-1
              @can_id += 1
              @item = @can_temp[@can_id]
            end
            @sprites["spray"].setBitmap(_INTL("Graphics/Pictures/BerryPots/#{@item}"))
            @sprites["spray_item"].setBitmap(_INTL("Graphics/Items/#{@item}"))
            
            @sprites["arrowu"].visible = (@can_id > 0 && @can_temp.length>1)
            @sprites["arrowd"].visible = (@can_id < @can_temp.length-1 && @can_temp.length>1)
            pbSEPlay("GUI sel cursor",80) if old_can_id != @can_id
          end
          @sprites["cursor"].visible = true
          @sprites["arrowu"].visible = false
          @sprites["arrowd"].visible = false
        elsif @index == -2 # End
          pbPlayCloseMenuSE
          break
        end
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif (Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN))# && potsCount > 5
        if @index >= 0
          add = y == 0 ? 5 : -5
          add = 0 if @index+add >= potsCount 
          @index += add
        else
          if Input.trigger?(Input::UP) && @index == -2
            @index = -1 if @can_temp.length > 1
            @index = potsCount - y*5 -1 if @can_temp.length == 0
          end
          @index = -2 if Input.trigger?(Input::DOWN) && @index == -1
        end
      elsif Input.trigger?(Input::LEFT)
        if @index > y*5 && @index > 0
          @index -= 1
        elsif @index < 0
          @index = potsCount - y*5 -1
        end
      elsif Input.trigger?(Input::RIGHT)
        if @index >= 0 && ((potsCount <= 4 && @index+1 < potsCount) || (potsCount > 4 && ((y == 0 && @index+1 < 5) || (y == 1 && @index+1 < potsCount))))
          @index +=1
        elsif @index == potsCount-1 || (@index == 4 && potsCount > 5)
          @index = @can_temp.length > 1 ? -1 : -2
        end
      end
      pbSEPlay("GUI sel cursor",80) if oldindex != @index
    end
    return @index
  end
  
  def pbBerryPlantVar(idx)
    berry_plant=$PokemonGlobal.berrypots[idx]
    berry_plant = BerryPlantData.new if !berry_plant
    berry_plant.update if berry_plant.planted?
    berry = berry_plant.berry_id
    # Interact with the event based on its growth
    if berry_plant.grown?
      berry_plant.reset if pbPickBerry(berry, berry_plant.berry_yield)
      return
    elsif berry_plant.growing?
      berry_name = GameData::Item.get(berry).name
      case berry_plant.growth_stage
      when 1   # X planted
        pbMessage(_INTL("A {1} was planted here.", berry_name))
      when 2   # X sprouted
        pbMessage(_INTL("The {1} has sprouted.", berry_name))
      when 3   # X taller
        pbMessage(_INTL("The {1} plant is growing bigger.", berry_name))
      else     # X flowering
        if Settings::NEW_BERRY_PLANTS
          pbMessage(_INTL("This {1} plant is in bloom!", berry_name))
        else
          case berry_plant.watering_count
          when 4
            pbMessage(_INTL("This {1} plant is in fabulous bloom!", berry_name))
          when 3
            pbMessage(_INTL("This {1} plant is blooming very beautifully!", berry_name))
          when 2
            pbMessage(_INTL("This {1} plant is blooming prettily!", berry_name))
          when 1
            pbMessage(_INTL("This {1} plant is blooming cutely!", berry_name))
          else
            pbMessage(_INTL("This {1} plant is in bloom!", berry_name))
          end
        end
      end
      # Water the growing plant
      return if !@item
      return if !pbConfirmMessage(_INTL("Want to sprinkle some water with the {1}?",
                                      GameData::Item.get(@item).name))
      berry_plant.water
      pbWateringAnim(idx)
      pbUpdateSoilSprite(berry_plant,idx)
      pbMessage(_INTL("{1} watered the plant.\\wtnp[40]", $player.name))
      if Settings::NEW_BERRY_PLANTS
        pbMessage(_INTL("There! All happy!"))
      else
        pbMessage(_INTL("The plant seemed to be delighted."))
      end
      return
    end
    # Nothing planted yet
    ask_to_plant = true
    choose = :plantberry
    cmds_new = [_INTL("Berry"),_INTL("Apricorn"),_INTL("Cancel")]
    if Settings::NEW_BERRY_PLANTS
      # New mechanics
      all_cmd = [[_INTL("Fertilize"),:fertilize], 
                 [_INTL("Plant Berry"),:plantberry]]
      all_cmd.push([_INTL("Plant Apricorn"),:plantapricorn]) if CAN_PLANT_APRICORN
      all_cmd.push([_INTL("Exit"),:exit])
      if berry_plant.mulch_id
        pbMessage(_INTL("{1} has been laid down.\1", GameData::Item.get(berry_plant.mulch_id).name))
      else
        cmds = []
        all_cmd.each{|cmd| cmds.push(cmd[0])}
        choose = pbMessage(_INTL("It's soft, earthy soil."), cmds, -1)
        choose = all_cmd[choose][1]
        case choose
        when :fertilize   # Fertilize
          if !hasMulchItem
            pbMessage(_INTL("You don't have any fertilizer!"))
            return
          end
          mulch = nil
          pbFadeOutIn {
            scene = PokemonBag_Scene.new
            screen = PokemonBagScreen.new(scene, $bag)
            mulch = screen.pbChooseItemScreen(proc { |item| GameData::Item.get(item).is_mulch? })
          }
          return if !mulch
          mulch_data = GameData::Item.get(mulch)
          if mulch_data.is_mulch?
            berry_plant.mulch_id = mulch
            $bag.remove(mulch)
            pbMessage(_INTL("The {1} was scattered on the soil.\1", mulch_data.name))
          else
            pbMessage(_INTL("That won't fertilize the soil!"))
            return
          end
        when :plantberry   # Plant Berry
          ask_to_plant = false
        when :plantapricorn   # Plant Apricorn
          choose = :plantapricorn
          ask_to_plant = false
        else   # Exit/cancel
          return
        end
      end
    else
      # Old mechanics
      # return if !pbConfirmMessage(_INTL("It's soft, loamy soil.\nPlant a berry?"))
      if !CAN_PLANT_APRICORN
        return if !pbConfirmMessage(_INTL("It's soft, loamy soil.\nPlant a berry?"))
        ask_to_plant = false
      else
        choose = pbMessage(_INTL("It's soft, loamy soil.\nPlant a berry or apricorn?"),cmds_new,2)#!pbConfirmMessage(_INTL("It's soft, loamy soil.\nPlant an apricorn?"))
        return if choose == 2
        choose = all_cmd[choose+1][1]
        ask_to_plant = false
        # end
      end
    end
    if ask_to_plant && !CAN_PLANT_APRICORN
      choose = nil if !pbConfirmMessage(_INTL("Want to plant a Berry?"))
    elsif ask_to_plant && CAN_PLANT_APRICORN
      choose = pbMessage(_INTL("It's soft, loamy soil.\nPlant a berry or apricorn?"),cmds_new,2)
      choose = choose == 2 ? nil : all_cmd[choose+1][1]
    end
    if !ask_to_plant || !choose.nil?
      if choose == :plantberry
        if !hasBerryItem
          pbMessage(_INTL("You don't have any Berries!"))
          return
        end
      else
        if !hasApricorn
          pbMessage(_INTL("You don't have any Apricorns!"))
          return
        end
      end
      if PluginManager.installed?("Apricorn Box") && choose != :plantberry
        berry = pbChooseApricornBox(1,"Select which Apricorn to plant.")[0]
      else
        pbFadeOutIn {
          scene = PokemonBag_Scene.new
          screen = PokemonBagScreen.new(scene, $bag)
          #berry farm blacklist, could be made better but it works so whatever #by low
          berry = screen.pbChooseItemScreen(choose == :plantberry ? proc { |item| GameData::Item.get(item).is_berry? && (![:CHERIBERRY, :CHESTOBERRY, :PECHABERRY, :RAWSTBERRY, :ASPEARBERRY, :PERSIMBERRY, :LUMBERRY, :LEPPABERRY, :SITRUSBERRY, :FIGYBERRY, :WIKIBERRY, :MAGOBERRY, :AGUAVBERRY, :IAPAPABERRY, :OCCABERRY, :PASSHOBERRY, :WACANBERRY, :RINDOBERRY, :YACHEBERRY, :CHOPLEBERRY, :KEBIABERRY, :SHUCABERRY, :COBABERRY, :PAYAPABERRY, :TANGABERRY, :CHARTIBERRY, :KASIBBERRY, :HABANBERRY, :COLBURBERRY, :BABIRIBERRY, :ROSELIBERRY, :CHILANBERRY, :KEEBERRY, :MARANGABERRY, :LIECHIBERRY, :GANLONBERRY, :SALACBERRY, :PETAYABERRY, :APICOTBERRY, :LANSATBERRY, :STARFBERRY, :MICLEBERRY, :CUSTAPBERRY, :JABOCABERRY, :ROWAPBERRY, :ENIGMABERRY].include?(item) && $game_variables[MECHANICSVAR] >= 3) } : 
                                                                    proc { |item| GameData::Item.get(item).is_apricorn? })
        }
      end
      if berry
        $stats.berries_planted += 1
        berry_plant.plant(berry)
        $bag.remove(berry)
        if Settings::NEW_BERRY_PLANTS
          pbMessage(_INTL("The {1} was planted in the soft, earthy soil.",
                          GameData::Item.get(berry).name))
        else
          pbMessage(_INTL("{1} planted a {2} in the soft loamy soil.",
                          $player.name, GameData::Item.get(berry).name))
        end
      end
    end
  end

  def pbPickBerry(berry, qty = 1)
    berry = GameData::Item.get(berry)
    berry_name = (qty > 1) ? berry.name_plural : berry.name
    if qty > 1
      message = _INTL("There are {1} \\c[1]{2}\\c[0]!\nWant to pick them?", qty, berry_name)
    else
      message = _INTL("There is 1 \\c[1]{1}\\c[0]!\nWant to pick it?", berry_name)
    end
    return false if !pbConfirmMessage(message)
    if !$bag.can_add?(berry, qty)
      pbMessage(_INTL("Too bad...\nThe Bag is full..."))
      return false
    end
    $stats.berry_plants_picked += 1
    
    #for Item Description
    $item_log.register(berry)
    
    if qty >= GameData::BerryPlant.get(berry.id).maximum_yield
      $stats.max_yield_berry_plants += 1
    end
    $bag.add(berry, qty)
    if qty > 1
      pbMessage(_INTL("\\me[Berry get]You picked the {1} \\c[1]{2}\\c[0].\\wtnp[30]", qty, berry_name))
    else
      pbMessage(_INTL("\\me[Berry get]You picked the \\c[1]{1}\\c[0].\\wtnp[30]", berry_name))
    end
    pocket = berry.pocket
    pbMessage(_INTL("{1} put the \\c[1]{2}\\c[0] in the <icon=bagPocket{3}>\\c[1]{4}\\c[0] Pocket.\1",
                    $player.name, berry_name, pocket, PokemonBag.pocket_names[pocket - 1]))
    if Settings::NEW_BERRY_PLANTS
      pbMessage(_INTL("The soil returned to its soft and earthy state."))
    else
      pbMessage(_INTL("The soil returned to its soft and loamy state."))
    end
    return true
  end
  
  def pbMessage(message,commands=nil,cmdIfCancel=0,skin=nil,defaultCmd=0,&block)
    ret = 0
    msgwindow = pbCreateMessageWindow(nil,skin)
    if commands
      ret = pbMessageDisplay(msgwindow,message,true,
         proc { |msgwindow|
           next Kernel.pbShowCommands(msgwindow,commands,cmdIfCancel,defaultCmd){ pbUpdate }
         }){ pbUpdate }
    else
      pbMessageDisplay(msgwindow,message){ pbUpdate }
    end
    pbDisposeMessageWindow(msgwindow)
    Input.update
    return ret
  end
  
  def pbConfirmMessage(message)
    return (pbMessage(message,[_INTL("Yes"),_INTL("No")],2)==0)
  end
  
  def hasMulchItem
    ret = false
    GameData::Item.each { |i| 
      next if !GameData::Item.get(i).is_mulch?
      ret = true if $bag.quantity(i)>0
      break if ret
    }
    return ret
  end
  def hasBerryItem
    ret = false
    GameData::Item.each { |i| 
      next if !GameData::Item.get(i).is_berry?
      ret = true if $bag.quantity(i)>0
      break if ret
    }
    return ret
  end
  def hasApricorn
    ret = false
    GameData::Item.each { |i| 
      next if !GameData::Item.get(i).is_apricorn?
      ret = true if $bag.quantity(i)>0
      break if ret
    }
    return ret
  end
end

#===============================================================================
# Item Handlers
#===============================================================================
ItemHandlers::UseInField.add(:BERRYPOTS,proc { |item|
  pbBerryPots
  next 1
})