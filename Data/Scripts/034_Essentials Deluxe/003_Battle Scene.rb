#===============================================================================
# Revamps and adds miscellaneous code related to the Battle scene as well as battle
# animations to allow for plugin compatibility.
#===============================================================================


#-------------------------------------------------------------------------------
# Allows for compatibility between effects that alter Pokemon sprites.
#-------------------------------------------------------------------------------
class Sprite
  def applyDynamax(arg); end
  def unDynamax;         end
  def applyDynamaxIcon;  end
  def applyTera;         end
  def unTera;            end
  def applyTeraIcon;     end
  
  def applyEffects(pokemon)
    if pokemon.is_a?(Pokemon) || pokemon.is_a?(Battle::Battler)
      self.resetEffects
      if pokemon.dynamax?
        self.applyDynamax(pokemon)
      elsif pokemon.tera?
        self.applyTera
      end
    end
  end
  
  def applyIconEffects
    self.resetEffects
    if @pokemon&.dynamax?
      self.applyDynamaxIcon
    elsif @pokemon&.tera?
      self.applyTeraIcon
    end
  end
  
  def resetEffects
    self.unDynamax
    self.unTera
  end
end


#-------------------------------------------------------------------------------
# Battle scene additions.
#-------------------------------------------------------------------------------
class Battle::Scene

  #-----------------------------------------------------------------------------
  # Edited so certain plugin mechanics will set the correct battler sprites.
  #-----------------------------------------------------------------------------
  def pbChangePokemon(idxBattler, pkmn)
    idxBattler = idxBattler.index if idxBattler.respond_to?("index")
    pkmnSprite   = @sprites["pokemon_#{idxBattler}"]
    shadowSprite = @sprites["shadow_#{idxBattler}"]
    back = !@battle.opposes?(idxBattler)
    params = [pkmn, back, nil]
    battler = @battle.battlers[idxBattler]
    if battler.dynamax?
      if battler.gmax_factor? && (pkmn.hasGmax? || pkmn.gmax?)
        params.push(:gmax)
      else
        params.push(:dmax)
      end
    else
      params.push(:none)
    end
    pkmnSprite.setPokemonBitmap(*params)
    shadowSprite.setPokemonBitmap(pkmn, params[3])
    shadowSprite.visible = pkmn.species_data.shows_shadow? if shadowSprite && !back
    pkmnSprite.applyEffects(battler)
  end
  
  #-----------------------------------------------------------------------------
  # Checks if a common animation exists.
  #-----------------------------------------------------------------------------
  def pbCommonAnimationExists?(animName)
    animations = pbLoadBattleAnimations
    animations.each do |a|
      next if !a || a.name != "Common:" + animName
      return true
    end
    return false
  end
  
  #-----------------------------------------------------------------------------
  # Calls an animation to revert a battler from various battle states.
  #-----------------------------------------------------------------------------
  def pbRevertBattlerStart(idxBattler)
    reversionAnim = Animation::RevertBattlerStart.new(@sprites, @viewport, idxBattler, @battle)
    loop do
      reversionAnim.update
      pbUpdate
      break if reversionAnim.animDone?
    end
    reversionAnim.dispose
  end
  
  def pbRevertBattlerEnd
    reversionAnim = Animation::RevertBattlerEnd.new(@sprites, @viewport, @battle)
    loop do
      reversionAnim.update
      pbUpdate
      break if reversionAnim.animDone?
    end
    reversionAnim.dispose
  end

  #-----------------------------------------------------------------------------
  # Sets up battler icons to be used by other plugins.
  #-----------------------------------------------------------------------------
  alias dx_pbInitSprites pbInitSprites
  def pbInitSprites
    dx_pbInitSprites
    if !pbInSafari?
      @battle.allBattlers.each do |b|
        @sprites["battler_icon#{b.index}"] = PokemonIconSprite.new(b.pokemon, @viewport)
        @sprites["battler_icon#{b.index}"].setOffset(PictureOrigin::CENTER)
        @sprites["battler_icon#{b.index}"].visible = false
        @sprites["battler_icon#{b.index}"].z = 400
        pbAddSpriteOutline(["battler_icon#{b.index}", @viewport, b.pokemon, PictureOrigin::CENTER])
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Compatibility with SOS Battles.
  #-----------------------------------------------------------------------------
  if PluginManager.installed?("SOS Battles")
    alias dx_pbSOSJoin pbSOSJoin
    def pbSOSJoin(battlerindex, pkmn)
      dx_pbSOSJoin(battlerindex, pkmn)
      if !@sprites["battler_icon#{battlerindex}"]
        @sprites["battler_icon#{battlerindex}"] = PokemonIconSprite.new(pkmn, @viewport)
        @sprites["battler_icon#{battlerindex}"].setOffset(PictureOrigin::CENTER)
        @sprites["battler_icon#{battlerindex}"].visible = false
        @sprites["battler_icon#{battlerindex}"].z = 400
        pbAddSpriteOutline(["battler_icon#{battlerindex}", @viewport, pkmn, PictureOrigin::CENTER])
      end
    end
  end
end


#-------------------------------------------------------------------------------
# Battle scene animations.
#-------------------------------------------------------------------------------
class Battle::Scene::Animation

  #-----------------------------------------------------------------------------
  # Used for animation compatibility with animated Pokemon sprites.
  #-----------------------------------------------------------------------------  
  def addPokeSprite(poke, origin = PictureOrigin::TOP_LEFT)
    case poke
    when Pokemon
      s = PokemonSprite.new(@viewport)
      s.setPokemonBitmap(poke)
    when Array
      s = PokemonSprite.new(@viewport)
      s.setSpeciesBitmap(*poke)
    end
    num = @pictureEx.length
    picture = PictureEx.new(s.z)
    picture.x       = s.x
    picture.y       = s.y
    picture.visible = s.visible
    picture.color   = s.color.clone
    picture.tone    = s.tone.clone
    picture.setOrigin(0, origin)
    @pictureEx[num] = picture
    @pictureSprites[num] = s
    @tempSprites.push(s)
    return picture
  end

  #-----------------------------------------------------------------------------
  # Used to darken all sprites in battle for cinematic animations.
  #-----------------------------------------------------------------------------
  def darkenBattlefield(battle, delay = 0, idxBattler = -1, sound = nil)
    tone = Tone.new(-60, -60, -60, 150)
    battleBG = addSprite(@sprites["battle_bg"])
    battleBG.moveTone(delay, 4, tone)
    battle.battlers.each do |b|
	    next if !b
      battler = addSprite(@sprites["pokemon_#{b.index}"], PictureOrigin::BOTTOM)
      shadow = addSprite(@sprites["shadow_#{b.index}"], PictureOrigin::CENTER)
      box = addSprite(@sprites["dataBox_#{b.index}"])
      if b.index == idxBattler
        battler.setSE(delay, sound) if sound
        battler.moveTone(delay, 4, Tone.new(255, 255, 255, 255))
      else
        battler.moveTone(delay, 4, tone)
      end
      shadow.moveTone(delay, 4, tone)
      box.moveTone(delay, 4, tone)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Reverts the changes made by darkenBattlefield.
  #-----------------------------------------------------------------------------
  def revertBattlefield(battle, delay)
    tone = Tone.new(0, 0, 0, 0)
    battleBG = addSprite(@sprites["battle_bg"])
    battleBG.moveTone(delay, 6, tone)
    battle.battlers.each do |b|
      next if !b
      battler = addSprite(@sprites["pokemon_#{b.index}"], PictureOrigin::BOTTOM)
      shadow = addSprite(@sprites["shadow_#{b.index}"], PictureOrigin::CENTER)
      box = addSprite(@sprites["dataBox_#{b.index}"])
      battler.moveTone(delay, 6, tone)
      shadow.moveTone(delay, 6, tone)
      box.moveTone(delay, 6, tone)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Sets the backdrop.
  #-----------------------------------------------------------------------------
  def dxSetBackdrop(checkfile, default, delay)
    zoom = 1
    if pbResolveBitmap(checkfile)
      file = checkfile
    elsif pbResolveBitmap(default)
      zoom = 1.5
      file = default
    else
      file = "Graphics/Pictures/evolutionbg"
    end
    pictureBG = addNewSprite(0, 0, file)
    pictureBG.setVisible(delay, false)
    spriteBG = @pictureEx.length - 1
    @pictureSprites[spriteBG].z = 999
    pictureBG.setZ(delay, @pictureSprites[spriteBG].z)
    pictureBG.setZoom(delay, 100 * zoom)
    return [pictureBG, spriteBG]
  end
  
  #-----------------------------------------------------------------------------
  # Sets the battle bases. Only sets one if a trainer doesn't appear.
  #-----------------------------------------------------------------------------
  def dxSetBases(checkfile, default, delay, xpos, ypos, offset = false)
    tr_base_offset = 0
    file = (pbResolveBitmap(checkfile)) ? checkfile : default
    pictureBASES = []
    if offset
      base = addNewSprite(0, 0, file)
      base.setVisible(delay, false)
      sprite = @pictureEx.length - 1
      if @opposes
        @pictureSprites[sprite].x = Graphics.width
      else
        @pictureSprites[sprite].x = -@pictureSprites[sprite].bitmap.width
      end
      @pictureSprites[sprite].y = ypos - 33
      @pictureSprites[sprite].z = 999
      tr_base_offset = @pictureSprites[sprite].bitmap.width / 4
      base.setXY(delay, @pictureSprites[sprite].x, @pictureSprites[sprite].y)
      base.setZ(delay, @pictureSprites[sprite].z)
      pictureBASES.push(base)
    end
    base = addNewSprite(0, 0, file)
    base.setVisible(delay, false)
    sprite = @pictureEx.length - 1
    @pictureSprites[sprite].x = xpos - @pictureSprites[sprite].bitmap.width / 2
    @pictureSprites[sprite].y = ypos
    @pictureSprites[sprite].y += 20 if offset
    @pictureSprites[sprite].z = 999
    base.setXY(delay, @pictureSprites[sprite].x, @pictureSprites[sprite].y)
    base.setZ(delay, @pictureSprites[sprite].z)
    pictureBASES.push(base)
    return [pictureBASES, tr_base_offset]
  end
  
  #-----------------------------------------------------------------------------
  # Sets a Pokemon sprite.
  #-----------------------------------------------------------------------------
  def dxSetPokemon(poke, delay, mirror = false, offset = false, opacity = 100, zoom = 100)
    battle_pos = Battle::Scene.pbBattlerPosition(1, 1)
    picturePOKE = addPokeSprite(poke, PictureOrigin::BOTTOM)
    picturePOKE.setVisible(delay, false)
    spritePOKE = @pictureEx.length - 1
    @pictureSprites[spritePOKE].mirror = mirror
    @pictureSprites[spritePOKE].x = battle_pos[0] - 128
    @pictureSprites[spritePOKE].y = battle_pos[1] + 80
    @pictureSprites[spritePOKE].y += 20 if offset
    @pictureSprites[spritePOKE].ox = @pictureSprites[spritePOKE].bitmap.width / 2
    @pictureSprites[spritePOKE].oy = @pictureSprites[spritePOKE].bitmap.height
    @pictureSprites[spritePOKE].z = 999
    case poke
    when Pokemon
      poke.species_data.apply_metrics_to_sprite(@pictureSprites[spritePOKE], 1)
    when Array
      metrics_data = GameData::SpeciesMetrics.get_species_form(poke[0], poke[2])
      metrics_data.apply_metrics_to_sprite(@pictureSprites[spritePOKE], 1)
    end
    picturePOKE.setXY(delay, @pictureSprites[spritePOKE].x, @pictureSprites[spritePOKE].y)
    picturePOKE.setZ(delay, @pictureSprites[spritePOKE].z)
    picturePOKE.setZoom(delay, zoom) if zoom != 100
    picturePOKE.setOpacity(delay, opacity) if opacity != 100
    return [picturePOKE, spritePOKE]
  end
  
  #-----------------------------------------------------------------------------
  # Sets a Pokemon sprite with an outline.
  #-----------------------------------------------------------------------------
  def dxSetPokemonWithOutline(poke, delay, mirror = false, offset = false, color = Color.white)
    battle_pos = Battle::Scene.pbBattlerPosition(1, 1)
    picturePOKE = []
    for i in [ [2, 0],  [-2, 0], [0, 2],  [0, -2], [2, 2],  [-2, -2], [2, -2], [-2, 2], [0, 0] ]
      outline = addPokeSprite(poke, PictureOrigin::BOTTOM)
      outline.setVisible(delay, false)
      sprite = @pictureEx.length - 1
      @pictureSprites[sprite].mirror = mirror
      @pictureSprites[sprite].x = battle_pos[0] + i[0] - 128
      @pictureSprites[sprite].y = battle_pos[1] + i[1] + 80
      @pictureSprites[sprite].y += 20 if offset
      @pictureSprites[sprite].ox = @pictureSprites[sprite].bitmap.width / 2
      @pictureSprites[sprite].oy = @pictureSprites[sprite].bitmap.height
      @pictureSprites[sprite].z = 999
      case poke
      when Pokemon
        poke.species_data.apply_metrics_to_sprite(@pictureSprites[sprite], 1)
      when Array
        set = (poke[8]) ? 2 : poke[7] ? 1 : 0
        metrics_data = GameData::SpeciesMetrics.get_species_form(poke[0], poke[2])
        metrics_data.apply_metrics_to_sprite(@pictureSprites[sprite], 1, false, set)
      end
      outline.setXY(delay, @pictureSprites[sprite].x, @pictureSprites[sprite].y)
      outline.setZ(delay, @pictureSprites[sprite].z)
      outline.setColor(delay, color) if i != [0, 0]
      picturePOKE.push([outline, sprite])
    end
    return picturePOKE
  end
  
  #-----------------------------------------------------------------------------
  # Sets up a trainer sprite along with an item sprite to be 'used'.
  #-----------------------------------------------------------------------------
  def dxSetTrainerWithItem(trainer, item, delay, mirror = false, color = Color.white)
    pictureTRAINER = addNewSprite(0, 0, trainer)
    pictureTRAINER.setVisible(delay, false)
    spriteTRAINER = @pictureEx.length - 1
    @pictureSprites[spriteTRAINER].y = 105
    if mirror
      @pictureSprites[spriteTRAINER].mirror = true
      @pictureSprites[spriteTRAINER].x = -@pictureSprites[spriteTRAINER].bitmap.width
      trainer_end_x = 0
    else
      @pictureSprites[spriteTRAINER].x = Graphics.width 
      trainer_end_x = Graphics.width - @pictureSprites[spriteTRAINER].bitmap.width
    end
    @pictureSprites[spriteTRAINER].z = 999
    trainer_x, trainer_y = @pictureSprites[spriteTRAINER].x, @pictureSprites[spriteTRAINER].y
    pictureTRAINER.setXY(delay, trainer_x, trainer_y)
    pictureTRAINER.setZ(delay, @pictureSprites[spriteTRAINER].z)
    trData = [pictureTRAINER, trainer_end_x, trainer_y]
    pictureITEM = []
    for i in [ [2, 0],  [-2, 0], [0, 2],  [0, -2], [2, 2],  [-2, -2], [2, -2], [-2, 2], [0, 0] ]
      outline = addNewSprite(0, 0, item, PictureOrigin::BOTTOM)
      outline.setVisible(delay, false)
      sprite = @pictureEx.length - 1
      @pictureSprites[sprite].x = trainer_end_x + (@pictureSprites[spriteTRAINER].bitmap.width / 2) + i[0]
      @pictureSprites[sprite].y = 97 + i[1]
      @pictureSprites[sprite].oy = @pictureSprites[sprite].bitmap.height
      @pictureSprites[sprite].z = 999
      outline.setXY(delay, @pictureSprites[sprite].x, @pictureSprites[sprite].y)
      outline.setZ(delay, @pictureSprites[sprite].z)
      outline.setOpacity(delay, 0)
      outline.setColor(delay, color) if i != [0, 0]
      pictureITEM.push([outline, sprite])
    end
    trData.push(pictureITEM)
    return trData
  end
  
  #-----------------------------------------------------------------------------
  # Sets a sprite.
  #-----------------------------------------------------------------------------
  def dxSetSprite(file, delay, xpos, ypos, offset = false, opacity = 100, zoom = 100)
    pictureSPRITE = addNewSprite(0, 0, file, PictureOrigin::CENTER)
    pictureSPRITE.setVisible(delay, false)
    spriteSPRITE = @pictureEx.length - 1
    @pictureSprites[spriteSPRITE].x = xpos
    @pictureSprites[spriteSPRITE].y = ypos
    @pictureSprites[spriteSPRITE].y += 20 if offset
    @pictureSprites[spriteSPRITE].z = 999
    @pictureSprites[spriteSPRITE].oy = @pictureSprites[spriteSPRITE].bitmap.height
    pictureSPRITE.setXY(delay, @pictureSprites[spriteSPRITE].x, @pictureSprites[spriteSPRITE].y)
    pictureSPRITE.setZ(delay, @pictureSprites[spriteSPRITE].z)
    pictureSPRITE.setZoom(delay, zoom) if zoom != 100
    pictureSPRITE.setOpacity(delay, opacity) if opacity != 100
    return [pictureSPRITE, spriteSPRITE]
  end
  
  #-----------------------------------------------------------------------------
  # Sets a sprite with an outline.
  #-----------------------------------------------------------------------------
  def dxSetSpriteWithOutline(file, delay, xpos, ypos, color = Color.white)
    pictureSPRITE = []
    if file && pbResolveBitmap(file)
      for i in [ [2, 0],  [-2, 0], [0, 2],  [0, -2], [2, 2],  [-2, -2], [2, -2], [-2, 2], [0, 0] ]
        outline = addNewSprite(0, 0, file, PictureOrigin::BOTTOM)
        outline.setVisible(delay, false)
        sprite = @pictureEx.length - 1
        @pictureSprites[sprite].x = xpos + i[0]
        @pictureSprites[sprite].y = ypos + i[1]
        @pictureSprites[sprite].z = 999
        @pictureSprites[sprite].oy = @pictureSprites[sprite].bitmap.height
        outline.setXY(delay, @pictureSprites[sprite].x, @pictureSprites[sprite].y)
        outline.setZ(delay, @pictureSprites[sprite].z)
        outline.setOpacity(delay, 0)
        outline.setColor(delay, color) if i != [0, 0]
        pictureSPRITE.push([outline, sprite])
      end
    end
    return pictureSPRITE
  end
  
  #-----------------------------------------------------------------------------
  # Sets a sprite to act as a title.
  #-----------------------------------------------------------------------------
  def dxSetTitleWithOutline(file, delay, upper = false, color = Color.white)
    pictureTITLE = []
    if file && pbResolveBitmap(file)
      for i in [ [2, 0],  [-2, 0], [0, 2],  [0, -2], [2, 2],  [-2, -2], [2, -2], [-2, 2], [0, 0] ]
        outline = addNewSprite(0, 0, file, PictureOrigin::CENTER)
        outline.setVisible(delay, false)
        sprite = @pictureEx.length - 1
        @pictureSprites[sprite].x = (Graphics.width - @pictureSprites[sprite].bitmap.width / 2) + i[0]
        if upper
          @pictureSprites[sprite].y = @pictureSprites[sprite].bitmap.height / 2 + i[1]
        else
          @pictureSprites[sprite].y = (Graphics.height - @pictureSprites[sprite].bitmap.height / 2) + i[1]
        end
        @pictureSprites[sprite].z = 999
        outline.setXY(delay, @pictureSprites[sprite].x, @pictureSprites[sprite].y)
        outline.setZ(delay, @pictureSprites[sprite].z)
        outline.setZoom(delay, 300)
        outline.setOpacity(delay, 0)
        outline.setColor(delay, color) if i != [0, 0]
        outline.setTone(delay, Tone.new(255, 255, 255, 255))
        pictureTITLE.push([outline, sprite])
      end
    end
    return pictureTITLE
  end
  
  #-----------------------------------------------------------------------------
  # Sets an overlay.
  #-----------------------------------------------------------------------------
  def dxSetOverlay(file, delay)
    pictureOVERLAY = addNewSprite(0, 0, file)
    pictureOVERLAY.setVisible(delay, false)
    spriteOVERLAY = @pictureEx.length - 1
    @pictureSprites[spriteOVERLAY].z = 999
    pictureOVERLAY.setZ(delay, @pictureSprites[spriteOVERLAY].z)
    pictureOVERLAY.setOpacity(delay, 0)
    return [pictureOVERLAY, spriteOVERLAY]
  end
  
  #-----------------------------------------------------------------------------
  # Sets a set of four particle sprites by repeating an image.
  #-----------------------------------------------------------------------------
  def dxSetParticles(file, delay, xpos, ypos, range, offset = false)
    picturePARTICLES = []
    4.times do |i|
      particle = addNewSprite(0, 0, file, PictureOrigin::CENTER)
      particle.setVisible(delay, false)
      sprite = @pictureEx.length - 1
      case i
      when 0
        @pictureSprites[sprite].x = xpos - range
        @pictureSprites[sprite].y = ypos - range
      when 1
        @pictureSprites[sprite].x = xpos + range
        @pictureSprites[sprite].y = ypos - range
      when 2
        @pictureSprites[sprite].x = xpos - range
        @pictureSprites[sprite].y = ypos + range
      when 3
        @pictureSprites[sprite].x = xpos + range
        @pictureSprites[sprite].y = ypos + range
      end
      @pictureSprites[sprite].y += 20 if offset
      @pictureSprites[sprite].z = 999
      origin_x, origin_y = @pictureSprites[sprite].x, @pictureSprites[sprite].y
      particle.setXY(delay, origin_x, origin_y)
      particle.setZ(delay, @pictureSprites[sprite].z)
      picturePARTICLES.push([particle, origin_x, origin_y])
    end
    return picturePARTICLES
  end
  
  #-----------------------------------------------------------------------------
  # Sets a set of four particle sprites cut up from a single image.
  #-----------------------------------------------------------------------------
  def dxSetParticlesRect(file, delay, width, length, range, offset = false, inwards = false, idxBattler = nil)
    picturePARTICLES = []
    if idxBattler
      batSprite = @sprites["pokemon_#{idxBattler}"]
      pos = Battle::Scene.pbBattlerPosition(idxBattler, batSprite.sideSize)
      xpos = pos[0]
      ypos = pos[1] - batSprite.bitmap.width / 2
      zpos = batSprite.z
    else
      xpos = Graphics.width / 2
      ypos = Graphics.height / 2
      zpos = 999
    end
    4.times do |i|
      particle = addNewSprite(0, 0, file, PictureOrigin::CENTER)
      particle.setVisible(delay, false)
      sprite = @pictureEx.length - 1
      hWidth = (width / 2).round
      hLength = (length / 2).round
      case i
      when 0
        particle.setSrc(delay, 0, 0)
        particle.setSrcSize(delay, hWidth, hLength)
        start_x, start_y = xpos - range, ypos - range
        end_x, end_y = -range, -range
      when 1
        particle.setSrc(delay, hWidth, 0)
        particle.setSrcSize(delay, width, hLength)
        start_x, start_y = xpos + hWidth + range, ypos - range
        end_x, end_y = Graphics.width + range, -range
      when 2
        particle.setSrc(delay, 0, hLength)
        particle.setSrcSize(delay, hWidth, length)
        start_x, start_y = xpos - range, ypos + hLength + range
        end_x, end_y = -range, Graphics.height + range
      when 3
        particle.setSrc(delay, hWidth, hLength)
        particle.setSrcSize(delay, width, length)
        start_x, start_y = xpos + hWidth + range, ypos + hLength + range
        end_x, end_y = Graphics.width + range, Graphics.height + range
      end
      @pictureSprites[sprite].z = zpos
      particle.setZ(delay, @pictureSprites[sprite].z)
      if inwards
        start_y += 20 if offset
        @pictureSprites[sprite].x = start_x
        @pictureSprites[sprite].y = start_y
        particle.setXY(delay, @pictureSprites[sprite].x, @pictureSprites[sprite].y)
        picturePARTICLES.push([particle, start_x, start_y])
      else
        @pictureSprites[sprite].x = xpos + (width / 4).round
        @pictureSprites[sprite].y = ypos + (length / 4).round
        @pictureSprites[sprite].y += 20 if offset
        particle.setXY(delay, @pictureSprites[sprite].x, @pictureSprites[sprite].y)
        picturePARTICLES.push([particle, end_x, end_y])
      end
    end
    return picturePARTICLES
  end

  #-----------------------------------------------------------------------------
  # Sets the skip button.
  #-----------------------------------------------------------------------------
  def dxSetSkipButton(delay)
    path = "Graphics/Plugins/Essentials Deluxe/Animations/skip_button"
    pictureBUTTON = addNewSprite(0, Graphics.height, path)
    sprite = @pictureEx.length - 1
    @pictureSprites[sprite].z = 999
    pictureBUTTON.setZ(delay, @pictureSprites[sprite].z)
    return pictureBUTTON
  end
  
  #-----------------------------------------------------------------------------
  # Sets a fade-in/fade-out overlay.
  #-----------------------------------------------------------------------------
  def dxSetFade(delay)
    path = "Graphics/Plugins/Essentials Deluxe/Animations/fade"
    pictureFADE = addNewSprite(0, 0, path)
    sprite = @pictureEx.length - 1
    @pictureSprites[sprite].z = 999
    pictureFADE.setZ(delay, @pictureSprites[sprite].z)
    pictureFADE.setOpacity(delay, 0)
    return pictureFADE
  end
end


#-------------------------------------------------------------------------------
# Actual animation for reverting battlers from various battle states.
#-------------------------------------------------------------------------------
class Battle::Scene::Animation::RevertBattlerStart < Battle::Scene::Animation
  def initialize(sprites, viewport, idxBattler, battle)
    @battle = battle
    @index = idxBattler
    super(sprites, viewport)
  end

  def createProcesses
    darkenBattlefield(@battle, 0, @index, "Anim/Psych Up")
  end
end

class Battle::Scene::Animation::RevertBattlerEnd < Battle::Scene::Animation
  def initialize(sprites, viewport, battle)
    @battle = battle
    super(sprites, viewport)
  end

  def createProcesses
    revertBattlefield(@battle, 4)
  end
end


#-------------------------------------------------------------------------------
# Gets the file names for battle background elements. Used by certain animations.
#-------------------------------------------------------------------------------
class Battle
  def pbGetBattlefieldFiles
    case @time
    when 1 then time = "eve"
    when 2 then time = "night"
    end
    backdropFilename = @backdrop
    baseFilename = @backdrop
    baseFilename = sprintf("%s_%s", baseFilename, @backdropBase) if @backdropBase
    if time
      trialName = sprintf("%s_%s", backdropFilename, time)
      if pbResolveBitmap(sprintf("Graphics/Battlebacks/" + trialName + "_bg"))
        backdropFilename = trialName
      end
      trialName = sprintf("%s_%s", baseFilename, time)
      if pbResolveBitmap(sprintf("Graphics/Battlebacks/" + trialName + "_base1"))
        baseFilename = trialName
      end
    end
    if !pbResolveBitmap(sprintf("Graphics/Battlebacks/" + baseFilename + "_base1")) && @backdropBase
      baseFilename = @backdropBase
      if time
        trialName = sprintf("%s_%s", baseFilename, time)
        if pbResolveBitmap(sprintf("Graphics/Battlebacks/" + trialName + "_base1"))
          baseFilename = trialName
        end
      end
    end
    return backdropFilename, baseFilename
  end
end


#-------------------------------------------------------------------------------
# Gets colors related to each type. Used by certain animations.
#-------------------------------------------------------------------------------
def pbGetTypeColors(type)
  case type
  when :NORMAL   then outline = [216, 216, 192]; bg = [168, 168, 120]
  when :FIGHTING then outline = [240, 128, 48];  bg = [192, 48, 40]
  when :FLYING   then outline = [200, 192, 248]; bg = [168, 144, 240]
  when :POISON   then outline = [216, 128, 184]; bg = [160, 64, 160]
  when :GROUND   then outline = [248, 248, 120]; bg = [224, 192, 104]
  when :ROCK     then outline = [224, 192, 104]; bg = [184, 160, 56]
  when :BUG      then outline = [216, 224, 48];  bg = [168, 184, 32]
  when :GHOST    then outline = [168, 144, 240]; bg = [112, 88, 152]
  when :STEEL    then outline = [216, 216, 192]; bg = [184, 184, 208]
  when :FIRE     then outline = [248, 208, 48];  bg = [240, 128, 48]
  when :WATER    then outline = [152, 216, 216]; bg = [104, 144, 240]
  when :GRASS    then outline = [192, 248, 96];  bg = [120, 200, 80]
  when :ELECTRIC then outline = [248, 248, 120]; bg = [248, 208, 48]
  when :PSYCHIC  then outline = [248, 192, 176]; bg = [248, 88, 136]
  when :ICE      then outline = [208, 248, 232]; bg = [152, 216, 216]
  when :DRAGON   then outline = [184, 160, 248]; bg = [112, 56, 248]
  when :DARK     then outline = [168, 168, 120]; bg = [112, 88, 72]
  when :FAIRY    then outline = [248, 216, 224]; bg = [240, 168, 176]
  else                outline = [255, 255, 255]; bg = [200, 200, 200]
  end
  return outline, bg
end