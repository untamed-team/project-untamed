#===============================================================================
# Adds battle animations used for deluxe battle trainer dialogue.
#===============================================================================


#-------------------------------------------------------------------------------
# Animation used to toggle visibility of data boxes.
#-------------------------------------------------------------------------------
class Battle::Scene::Animation::ToggleDataBoxes < Battle::Scene::Animation
  def initialize(sprites, viewport, battlers)
    @battlers = battlers
    super(sprites, viewport)
  end

  def createProcesses
    delay = 0
    @battlers.each do |b|
	  next if b.fainted?
      if @sprites["dataBox_#{b.index}"]
        toggle = !@sprites["dataBox_#{b.index}"].visible
        box = addSprite(@sprites["dataBox_#{b.index}"])
        case toggle
        when true
          box.setOpacity(delay, 0)
          box.moveOpacity(delay, 3, 255)
        when false
          box.moveOpacity(delay, 3, 0)
        end
        box.setVisible(delay + 3, toggle)
      end
    end
  end
end


#-------------------------------------------------------------------------------
# Animation used to toggle black bars during trainer speech.
#-------------------------------------------------------------------------------
class Battle::Scene::Animation::ToggleBlackBars < Battle::Scene::Animation
  def initialize(sprites, viewport, toggle)
    @toggle = toggle
    super(sprites, viewport)
  end

  def createProcesses
    delay = 10
    topBar = addSprite(@sprites["topBar"], PictureOrigin::TOP_LEFT)
    topBar.setZ(0, 200)
    bottomBar = addSprite(@sprites["bottomBar"], PictureOrigin::BOTTOM_RIGHT)
    bottomBar.setZ(0, 200)
    if @toggle
      toMoveBottom = [@sprites["bottomBar"].bitmap.width, Graphics.width].max
      toMoveTop = [@sprites["topBar"].bitmap.width, Graphics.width].max
      topBar.setOpacity(0, 255)
      bottomBar.setOpacity(0, 255)
      topBar.setXY(0, Graphics.width, 0)
      bottomBar.setXY(0, 0, Graphics.height)
      topBar.moveXY(delay, 10, (Graphics.width-toMoveTop), 0)
      bottomBar.moveXY(delay, 10, toMoveBottom, Graphics.height)
    else
      topBar.moveOpacity(delay, 8, 0)
      bottomBar.moveOpacity(delay, 8, 0)
      topBar.setXY(delay + 5, Graphics.width, 0)
      bottomBar.setXY(delay + 5, 0, Graphics.height)
    end
  end
end


#-------------------------------------------------------------------------------
# Animation used to slide a trainer off screen.
#-------------------------------------------------------------------------------
class Battle::Scene::Animation::TrainerDisappear < Battle::Scene::Animation
  def initialize(sprites, viewport, idxTrainer)
    @idxTrainer = idxTrainer + 1
    super(sprites, viewport)
  end

  def createProcesses
    delay = 0
    if @sprites["trainer_#{@idxTrainer}"].visible
      trainer = addSprite(@sprites["trainer_#{@idxTrainer}"], PictureOrigin::BOTTOM)
      trainer.moveDelta(delay, 8, Graphics.width / 4, 0)
      trainer.setVisible(delay + 8, false)
    end
  end
end


#-------------------------------------------------------------------------------
# Plays animations.
#-------------------------------------------------------------------------------
class Battle::Scene
  def pbHideOpponent(idxTrainer)
    hideAnim = Animation::TrainerDisappear.new(@sprites, @viewport, idxTrainer)
    @animations.push(hideAnim)
    while inPartyAnimation?
      pbUpdate
    end
  end
  
  def pbToggleDataboxes
    dataBoxAnim = Animation::ToggleDataBoxes.new(@sprites, @viewport, @battle.battlers)
    loop do
      dataBoxAnim.update
      pbUpdate
      break if dataBoxAnim.animDone?
    end
    dataBoxAnim.dispose
  end
  
  def pbToggleBlackBars(toggle = false)
    pbAddSprite("topBar", Graphics.width, 0, "Graphics/Plugins/Essentials Deluxe/blackbar_top", @viewport) if !@sprites["topBar"]
    pbAddSprite("bottomBar", 0, Graphics.height, "Graphics/Plugins/Essentials Deluxe/blackbar_bottom", @viewport) if !@sprites["bottomBar"]
    blackBarAnim = Animation::ToggleBlackBars.new(@sprites, @viewport, toggle)
    loop do
      blackBarAnim.update
      pbUpdate
      break if blackBarAnim.animDone?
    end
    blackBarAnim.dispose
    @sprites["messageWindow"].text = ""
    if toggle
      @sprites["messageWindow"].baseColor = MessageConfig::LIGHT_TEXT_MAIN_COLOR
      @sprites["messageWindow"].shadowColor = MessageConfig::LIGHT_TEXT_SHADOW_COLOR
      @sprites["messageWindow"].z += 1
    else
      colors = getDefaultTextColors(@sprites["messageWindow"].windowskin)
      @sprites["messageWindow"].baseColor = colors[0]
      @sprites["messageWindow"].shadowColor = colors[1]
      @sprites["messageWindow"].z -= 1
    end
  end
  
  def pbFlashRefresh
    tone = 0
    toneDiff = 20 * 20 / Graphics.frame_rate
    loop do
      Graphics.update
      pbUpdate
      tone += toneDiff
      @viewport.tone.set(tone, tone, tone, 0)
      break if tone >= 255
    end
    pbRefreshEverything
    (Graphics.frame_rate / 4).times do
      Graphics.update
      pbUpdate
    end
    tone = 255
    toneDiff = 40 * 20 / Graphics.frame_rate
    loop do
      Graphics.update
      pbUpdate
      tone -= toneDiff
      @viewport.tone.set(tone, tone, tone, 0)
      break if tone <= 0
    end
  end
end