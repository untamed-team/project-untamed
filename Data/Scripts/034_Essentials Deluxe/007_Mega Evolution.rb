#===============================================================================
# Revamps base Essentials code related to Mega Evolution and Primal Reversion to
# allow for plugin compatibility.
#===============================================================================


#-------------------------------------------------------------------------------
# Displays a held item icon for Mega Stones in the Party menu.
#-------------------------------------------------------------------------------
module GameData
  class << Item
    alias dx_held_icon_filename held_icon_filename
  end
  
  class Item
    def self.held_icon_filename(item)
      item_data = self.try_get(item)
      return nil if !item_data
      name_base = "mega" if item_data.is_mega_stone?
      ["Graphics/Plugins/Essentials Deluxe/icon_",
       "Graphics/Pictures/Party/icon_"].each do |p|
        ret = sprintf(p + "%s_%s", name_base, item_data.id)
        return ret if pbResolveBitmap(ret)
        ret = sprintf(p + "%s", name_base)
        return ret if pbResolveBitmap(ret)
      end
      return self.dx_held_icon_filename(item)
    end
  end
end


#-------------------------------------------------------------------------------
# Displays a new Mega Evolution icon on battler databoxes.
#-------------------------------------------------------------------------------
class Battle::Scene::PokemonDataBox < Sprite
  def draw_special_form_icon
    filename = nil
    specialX = (@battler.opposes?(0)) ? 208 : -28
    ypos = 4
    if @battler.mega?
      filename = "Graphics/Pictures/Battle/icon_mega"
      filename = "Graphics/Pictures/Battle/icon_mem" if @battler.hasMegaEvoMutation?
      ypos = 6
    elsif @battler.primal?
      if @battler.isSpecies?(:GROUDON)
        filename = "Graphics/Pictures/Battle/icon_primal_Groudon"
      elsif @battler.isSpecies?(:KYOGRE)
        filename = "Graphics/Pictures/Battle/icon_primal_Kyogre"
      end
    end
    pbDrawImagePositions(self.bitmap, [[filename, @spriteBaseX + specialX, ypos]]) if filename
  end
end


#-------------------------------------------------------------------------------
# Gets form number for a Pokemon's Primal form, if any.
#-------------------------------------------------------------------------------
class Pokemon
  def getPrimalForm
    v = MultipleForms.call("getPrimalForm", self)
    return v || @form
  end
end


#-------------------------------------------------------------------------------
# Mega Evolution
#-------------------------------------------------------------------------------
# Higher priority than:
#   -Dynamax
#   -Battle Styles
#   -Terastallization
#
# Lower priority than:
#   -Primal Reversion
#   -Zodiac Powers
#   -Ultra Burst
#   -Z-Moves
#-------------------------------------------------------------------------------
class Battle::Battler
  def hasMega?
    return false if shadowPokemon? || @effects[PBEffects::Transform]
    return false if mega? || primal? || ultra? || dynamax? || inStyle? || tera? || celestial?
    return false if hasPrimal? || hasZMove? || hasUltra? || hasZodiacPower?
    return @pokemon&.hasMegaForm?
  end
end


#-------------------------------------------------------------------------------
# Allows wild Pokemon to Mega Evolve if they are capable and flagged as an ace.
#-------------------------------------------------------------------------------
class Battle::AI
  def pbEnemyShouldMegaEvolve?(idxBattler)
    return false if @battle.pbScriptedMechanic?(idxBattler, :mega)
    battler = @battle.battlers[idxBattler]
    elig = (battler.wild?) ? battler.ace? : true
    if @battle.pbCanMegaEvolve?(idxBattler) && elig
      PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will Mega Evolve")
      return true
    end
    return false
  end
end


#-------------------------------------------------------------------------------
# Battle code for Mega Evolution and Primal Reversion.
#-------------------------------------------------------------------------------
class Battle
  def pbAttackPhaseMegaEvolution
    pbPriority.each do |b|
      next if b.wild? # removed "ace" bit, useless
      next unless @choices[b.index][0] == :UseMove && !b.fainted?
			if !b.hasMegaEvoMutation? #by low
				owner = pbGetOwnerIndexFromBattlerIndex(b.index)
				next if @megaEvolution[b.idxOwnSide][owner] != b.index
			end
      pbMegaEvolve(b.index)
    end
  end
  
  alias dx_pbHasMegaRing? pbHasMegaRing?
  def pbHasMegaRing?(idxBattler)
    return true if @battlers[idxBattler].wild?
    dx_pbHasMegaRing?(idxBattler)
  end

  def pbCanMegaEvolve?(idxBattler)
    battler = @battlers[idxBattler]
    return false if $game_switches[Settings::NO_MEGA_EVOLUTION]
    return false if !battler.hasMega?
    return true if $DEBUG && Input.press?(Input::CTRL) && !battler.wild?
    return false if battler.effects[PBEffects::SkyDrop] >= 0
    return false if !pbHasMegaRing?(idxBattler)
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @megaEvolution[side][owner] == -1
  end
  
  def pbMegaEvolve(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.hasMega? || battler.mega?
    triggers = ["mega", "mega" + battler.species.to_s]
    battler.pokemon.types.each { |t| triggers.push("mega" + t.to_s) }
    @scene.pbDeluxeTriggers(idxBattler, nil, triggers)
    $stats.mega_evolution_count += 1 if battler.pbOwnedByPlayer?
    old_ability = battler.ability_id
    if battler.hasActiveAbility?(:ILLUSION)
      Battle::AbilityEffects.triggerOnBeingHit(battler.ability, nil, battler, nil, self)
    end
    if battler.wild?
      case battler.pokemon.megaMessage
      when 1
        pbDisplay(_INTL("{1} radiates with Mega energy!", battler.pbThis))
      else
        pbDisplay(_INTL("{1}'s {2} radiates with Mega energy!", battler.pbThis, battler.itemName))
      end
    else
      trainerName = pbGetOwnerName(idxBattler)
      case battler.pokemon.megaMessage
      when 1
        pbDisplay(_INTL("{1}'s fervent wish has reached {2}!", trainerName, battler.pbThis))
      else
        pbDisplay(_INTL("{1}'s {2} is reacting to {3}'s {4}!",
                        battler.pbThis, battler.itemName, trainerName, pbGetMegaRingName(idxBattler)))
      end
    end
    if @scene.pbCommonAnimationExists?("MegaEvolution")
      pbCommonAnimation("MegaEvolution", battler)
      battler.pokemon.makeMega
      battler.form = battler.pokemon.form
      @scene.pbChangePokemon(battler, battler.pokemon)
      pbCommonAnimation("MegaEvolution2", battler)
    else 
      if Settings::SHOW_MEGA_ANIM && $PokemonSystem.battlescene == 0
        @scene.pbShowMegaEvolution(idxBattler)
        battler.pokemon.makeMega
        battler.form = battler.pokemon.form
        @scene.pbChangePokemon(battler, battler.pokemon)
      else
        @scene.pbRevertBattlerStart(idxBattler)
        battler.pokemon.makeMega
        battler.form = battler.pokemon.form
        @scene.pbChangePokemon(battler, battler.pokemon)
        @scene.pbRevertBattlerEnd
      end
    end
    battler.pbUpdate(true)
    @scene.pbRefreshOne(idxBattler)
    megaName = battler.pokemon.megaName
    megaName = _INTL("Mega {1}", battler.pokemon.speciesName) if nil_or_empty?(megaName)
    pbDisplay(_INTL("{1} has Mega Evolved into {2}!", battler.pbThis, megaName))
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @megaEvolution[side][owner] = -2
    if battler.isSpecies?(:GENGAR) && battler.mega?
      battler.effects[PBEffects::Telekinesis] = 0
    end
    battler.pbOnLosingAbility(old_ability)
    battler.pbTriggerAbilityOnGainingIt
    pbCalculatePriority(false, [idxBattler]) if Settings::RECALCULATE_TURN_ORDER_AFTER_MEGA_EVOLUTION
  end

  def pbPrimalReversion(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon || battler.fainted?
    return if !battler.hasPrimal? || battler.primal?
    triggers = ["primal", "primal" + battler.species.to_s]
    battler.pokemon.types.each { |t| triggers.push("primal" + t.to_s) }
    @scene.pbDeluxeTriggers(idxBattler, nil, triggers)
    if @scene.pbCommonAnimationExists?("PrimalKyogre") ||
       @scene.pbCommonAnimationExists?("PrimalGroudon")
      case battler.species
      when :KYOGRE
        pbCommonAnimation("PrimalKyogre", battler)
        battler.pokemon.makePrimal
        battler.form = battler.pokemon.form
        @scene.pbChangePokemon(battler, battler.pokemon)
        pbCommonAnimation("PrimalKyogre2", battler)
      when :GROUDON
        pbCommonAnimation("PrimalGroudon", battler)
        battler.pokemon.makePrimal
        battler.form = battler.pokemon.form
        @scene.pbChangePokemon(battler, battler.pokemon)
        pbCommonAnimation("PrimalGroudon2", battler)
      end
    else
      if Settings::SHOW_PRIMAL_ANIM && $PokemonSystem.battlescene == 0
        @scene.pbShowPrimalReversion(idxBattler)
        battler.pokemon.makePrimal
        battler.form = battler.pokemon.form
        @scene.pbChangePokemon(battler, battler.pokemon)
      else
        @scene.pbRevertBattlerStart(idxBattler)
        battler.pokemon.makePrimal
        battler.form = battler.pokemon.form
        @scene.pbChangePokemon(battler, battler.pokemon)
        @scene.pbRevertBattlerEnd
      end
    end
    battler.pbUpdate(true)
    @scene.pbRefreshOne(idxBattler)
    pbDisplay(_INTL("{1}'s Primal Reversion!\nIt reverted to its primal form!", battler.pbThis))
  end
end


#===============================================================================
# Battle animation for triggering Mega Evolution.
#===============================================================================
class Battle::Scene::Animation::BattlerMegaEvolve < Battle::Scene::Animation
  #-----------------------------------------------------------------------------
  # Initializes data used for the animation.
  #-----------------------------------------------------------------------------
  def initialize(sprites, viewport, idxBattler, battle)
    #---------------------------------------------------------------------------
    # Gets Pokemon data from battler index.
    @battle = battle
    @battler = @battle.battlers[idxBattler]
    @opposes = @battle.opposes?(idxBattler)
    @pkmn = @battler.pokemon
    @mega = [@pkmn.species, @pkmn.gender, @pkmn.getMegaForm, @pkmn.shiny?, @pkmn.shadowPokemon?]
    @cry_file = GameData::Species.cry_filename(@mega[0], @mega[2])
    if @battler.item && @battler.item.is_mega_stone?
      @megastone_file = "Graphics/Items/" + @battler.item_id.to_s
    end
    #---------------------------------------------------------------------------
    # Gets trainer data from battler index (non-wild only).
    if !@battler.wild?
      items = []
      trainer_item = :MEGARING
      trainer = @battle.pbGetOwnerFromBattlerIndex(idxBattler)
      @trainer_file = GameData::TrainerType.front_sprite_filename(trainer.trainer_type)
      GameData::Item.each { |item| items.push(item.id) if item.has_flag?("MegaRing") }
      if @battle.pbOwnedByPlayer?(idxBattler)
        items.each do |item|
          next if !$bag.has?(item)
          trainer_item = item
        end
      else
        trainer_items = @battle.pbGetOwnerItems(idxBattler)
        items.each do |item|
          next if !trainer_items&.include?(item)
          trainer_item = item
        end
      end
      @item_file = "Graphics/Items/" + trainer_item.to_s
    end
    #---------------------------------------------------------------------------
    # Gets background and animation data.
    @path = "Graphics/Plugins/Essentials Deluxe/Animations/"
    backdropFilename, baseFilename = @battle.pbGetBattlefieldFiles
    @bg_file   = "Graphics/Battlebacks/" + backdropFilename + "_bg"
    @base_file = "Graphics/Battlebacks/" + baseFilename + "_base1"
    super(sprites, viewport)
  end
  
  #-----------------------------------------------------------------------------
  # Plays the animation.
  #-----------------------------------------------------------------------------
  def createProcesses
    delay = 0
    center_x, center_y = Graphics.width / 2, Graphics.height / 2
    #---------------------------------------------------------------------------
    # Sets up background.
    bgData = dxSetBackdrop(@path + "Mega/bg", @bg_file, delay)
    picBG, sprBG = bgData[0], bgData[1]
    #---------------------------------------------------------------------------
    # Sets up bases.
    baseData = dxSetBases(@path + "Mega/base", @base_file, delay, center_x, center_y, !@battler.wild?)
    arrBASES, tr_base_offset = baseData[0], baseData[1]
    #---------------------------------------------------------------------------
    # Sets up trainer & Mega Ring                                          
    if !@battler.wild?
      trData = dxSetTrainerWithItem(@trainer_file, @item_file, delay, !@opposes)
      picTRAINER, trainer_end_x, trainer_y, arrITEM = trData[0], trData[1], trData[2], trData[3]
    end
    #---------------------------------------------------------------------------
    # Sets up overlay.
    overlayData = dxSetOverlay(@path + "burst", delay)
    picOVERLAY, sprOVERLAY = overlayData[0], overlayData[1]
    #---------------------------------------------------------------------------
    # Sets up battler.
    pokeData = dxSetPokemon(@pkmn, delay, !@opposes, !@battler.wild?)
    picPOKE, sprPOKE = pokeData[0], pokeData[1]
    #---------------------------------------------------------------------------
    # Sets up Mega Stone.
    item_y = @pictureSprites[sprPOKE]. y - @pictureSprites[sprPOKE].bitmap.height
    arrSTONE = dxSetSpriteWithOutline(@megastone_file, delay, center_x, item_y)
    #---------------------------------------------------------------------------
    # Animation objects.
    orbData = dxSetSprite(@path + "Mega/orb_1", delay, center_x, center_y, !@battler.wild?, 0, 0)
    picORB, sprORB = orbData[0], orbData[1]
    shineData = dxSetSprite(@path + "Mega/shine", delay, center_x, center_y, !@battler.wild?)
    picSHINE, sprSHINE = shineData[0], shineData[1]
    #---------------------------------------------------------------------------
    # Sets up Mega Pokemon.
    arrPOKE = dxSetPokemonWithOutline(@mega, delay, !@opposes, !@battler.wild?)
    arrPOKE.last[0].setColor(delay, Color.white)
    #---------------------------------------------------------------------------
    # Animation objects.
    orb2Data = dxSetSprite(@path + "Mega/orb_2", delay, center_x, center_y, !@battler.wild?, 0)
    picORB2, sprORB2 = orb2Data[0], orb2Data[1]
    arrPARTICLES = dxSetParticles(@path + "particle", delay, center_x, center_y, 200)
    pulseData = dxSetSprite(@path + "pulse", delay, center_x, center_y, !@battler.wild?, 100, 50)
    picPULSE, sprPULSE = pulseData[0], pulseData[1]
    #---------------------------------------------------------------------------
    # Sets up Mega icon.
    icon_y = @pictureSprites[arrPOKE.last[1]].y - @pictureSprites[arrPOKE.last[1]].bitmap.height - 20
    iconData = dxSetSprite(@path + "Mega/icon", delay, center_x, icon_y, false, 0)
    picICON, sprICON = iconData[0], iconData[1]
    #---------------------------------------------------------------------------
    # Sets up skip button & fade out.
    picBUTTON = dxSetSkipButton(delay)
    picFADE = dxSetFade(delay)
    ############################################################################
    # Animation start.
    ############################################################################
    # Fades in scene.
    picFADE.moveOpacity(delay, 8, 255)
    delay = picFADE.totalDuration
    picBG.setVisible(delay, true)
    arrBASES.last.setVisible(delay, true)
    picPOKE.setVisible(delay, true)
    picFADE.moveOpacity(delay, 8, 0)
    delay = picFADE.totalDuration
    picBUTTON.moveXY(delay, 6, 0, Graphics.height - 38)
    picBUTTON.moveXY(delay + 36, 6, 0, Graphics.height)
    #---------------------------------------------------------------------------
    # Slides trainer on screen with base (non-wild only).
    if !@battler.wild?
      picTRAINER.setVisible(delay + 4, true)
      arrBASES.first.setVisible(delay + 4, true)
      picTRAINER.moveXY(delay + 4, 8, trainer_end_x, trainer_y)
      arrBASES.first.moveXY(delay + 4, 8, trainer_end_x - tr_base_offset, center_y - 33)
      delay = picTRAINER.totalDuration + 1
      #-------------------------------------------------------------------------
      # Mega Ring appears with outline; slide upwards.
      picTRAINER.setSE(delay, "DX Power Up")
      arrITEM.each do |p, s| 
        p.setVisible(delay, true)
        p.moveXY(delay, 15, @pictureSprites[s].x, @pictureSprites[s].y - 20)
        p.moveOpacity(delay, 15, 255)
        p.moveOpacity(delay + 15, 8, 0)
      end
      delay = picTRAINER.totalDuration
    end
    #---------------------------------------------------------------------------
    # Mega Stone appears with outline; slide upwards.
    arrSTONE.each do |p, s| 
      p.setVisible(delay, true)
      p.moveXY(delay, 15, @pictureSprites[s].x, @pictureSprites[s].y - 20)
      p.moveOpacity(delay, 15, 255)
      p.moveOpacity(delay + 15, 8, 0)
    end
    #---------------------------------------------------------------------------
    # Darkens background/base tone; brightens Pokemon to white.
    picBG.setSE(delay, "DX Power Up") if @battler.wild?
    picBG.moveTone(delay, 15, Tone.new(-200, -200, -200))
    arrBASES.each { |p| p.moveTone(delay, 15, Tone.new(-200, -200, -200)) }
    picPOKE.moveTone(delay, 8, Tone.new(-255, -255, -255, 255))
    picPOKE.moveColor(delay + 8, 6, Color.white)
    #---------------------------------------------------------------------------
    # Particles begin drawing in to Pokemon.
    repeat = delay
    2.times do |t|
      repeat -= 4 if t > 0
      arrPARTICLES.each_with_index do |p, i|
        p[0].setVisible(repeat + i, true)
        p[0].moveXY(repeat + i, 4, center_x, center_y)
        repeat = p[0].totalDuration
        p[0].setVisible(repeat + i, false)
        p[0].setXY(repeat + i, p[1], p[2])
        p[0].setZoom(repeat + i, 100)
        repeat = p[0].totalDuration - 2
      end
    end
    particleEnd = arrPARTICLES.last[0].totalDuration
    delay = picPOKE.totalDuration + 4
    #---------------------------------------------------------------------------
    # White orb engulfs Pokemon; cracks appear; orb expands away from Pokemon.
    picORB.setVisible(delay, true)
    picORB2.setVisible(delay, true)
    picORB.setSE(delay, "Anim/Psych Up")
    picORB.moveZoom(delay, 12, 100)
    picORB.moveOpacity(delay, 12, 255)
    picORB2.moveOpacity(particleEnd, 16, 255)
    delay = picORB2.totalDuration
    picSHINE.setVisible(delay, true)
    picSHINE.moveOpacity(delay, 4, 255)
    picPOKE.setVisible(delay, false)
    t = 0.5
    16.times do |i|
      picORB.moveXY(delay, t, @pictureSprites[sprORB].x + 2, @pictureSprites[sprORB].y)
      picORB2.moveXY(delay, t, @pictureSprites[sprORB2].x + 2, @pictureSprites[sprORB2].y)
      picORB.moveXY(delay + t, t, @pictureSprites[sprORB].x - 2, @pictureSprites[sprORB].y)
      picORB2.moveXY(delay + t, t, @pictureSprites[sprORB2].x - 2, @pictureSprites[sprORB2].y)
      delay = picORB2.totalDuration
    end
    picORB2.setSE(delay, "Anim/fog2")
    picORB2.moveZoom(delay, 8, 1000)
    picORB2.moveOpacity(delay, 8, 0)
    arrPOKE.each { |p, s| p.setVisible(delay + 6, true) }
    picORB.moveZoom(delay + 6, 8, 1000)
    picORB.moveOpacity(delay + 6, 8, 0)
    #---------------------------------------------------------------------------
    # White screen flash; shows silhouette of Mega Pokemon.
    picFADE.setColor(delay + 4, Color.white)
    picFADE.moveOpacity(delay + 4, 12, 255)
    delay = picFADE.totalDuration
    arrPOKE.last[0].setColor(delay, Color.black)
    picFADE.moveOpacity(delay, 6, 0)
    picFADE.setColor(delay + 6, Color.black)
    delay = picFADE.totalDuration
    #---------------------------------------------------------------------------
    # Mega Pokemon revealed; pulse expands outwards; overlay & Mega icon shown.
    picOVERLAY.setVisible(delay, true)
    picOVERLAY.moveOpacity(delay, 5, 0)
    picSHINE.setVisible(delay, true)
    picICON.setVisible(delay, true)
    picICON.moveOpacity(delay + 4, 8, 255)
    picPULSE.setVisible(delay, true)
    picPULSE.moveZoom(delay, 5, 1000)
    picPULSE.moveOpacity(delay + 2, 5, 0)
    arrPOKE.last[0].moveColor(delay, 8, Color.new(0, 0, 0, 0))
    #---------------------------------------------------------------------------
    # Shakes Pokemon; plays cry; flashes overlay. Fades out.
    16.times do |i|
      if i > 0
        arrPOKE.each { |p, s| p.moveXY(delay, t, @pictureSprites[s].x, @pictureSprites[s].y + 2) }
        arrPOKE.each { |p, s| p.moveXY(delay + t, t, @pictureSprites[s].x, @pictureSprites[s].y - 2) }
        picOVERLAY.moveOpacity(delay + t, 2, 160)
        picSHINE.moveOpacity(delay + t, 2, 160)
      else
        picPOKE.setSE(delay + t, @cry_file) if @cry_file
      end
      picOVERLAY.moveOpacity(delay + t, 2, 240)
      picSHINE.moveOpacity(delay + t, 2, 240)
      delay = arrPOKE.last[0].totalDuration
    end
    picOVERLAY.moveOpacity(delay, 4, 0)
    picSHINE.moveOpacity(delay, 4, 0)
    picFADE.moveOpacity(delay + 20, 8, 255)
  end
end

#-------------------------------------------------------------------------------
# Calls the animation.
#-------------------------------------------------------------------------------
class Battle::Scene
  def pbShowMegaEvolution(idxBattler)
    megaAnim = Animation::BattlerMegaEvolve.new(@sprites, @viewport, idxBattler, @battle)
    loop do
      if Input.press?(Input::ACTION)
        pbPlayCancelSE
        break 
      end
      megaAnim.update
      pbUpdate
      break if megaAnim.animDone?
    end
    megaAnim.dispose
  end
end


#===============================================================================
# Battle animation for triggering Primal Reversion.
#===============================================================================
class Battle::Scene::Animation::BattlerPrimalReversion < Battle::Scene::Animation
  def initialize(sprites, viewport, idxBattler, battle)
    @idxBattler = idxBattler
    #---------------------------------------------------------------------------
    # Gets Pokemon data from battler index.
    @battle = battle
    @battler = @battle.battlers[idxBattler]
    @opposes = @battle.opposes?(idxBattler)
    @pkmn = @battler.pokemon
    @primal = [@pkmn.species, @pkmn.gender, @pkmn.getPrimalForm, @pkmn.shiny?, @pkmn.shadowPokemon?]
    @cry_file = GameData::Species.cry_filename(@primal[0], @primal[2])
    case @pkmn.species
    when :GROUDON then @bg_color = Color.new(255, 0, 0, 180)
    when :KYOGRE  then @bg_color = Color.new(0, 0, 255, 180)
    end
    #---------------------------------------------------------------------------
    # Gets background and animation data.
    @path = "Graphics/Plugins/Essentials Deluxe/Animations/"
    backdropFilename, baseFilename = @battle.pbGetBattlefieldFiles
    @bg_file   = "Graphics/Battlebacks/" + backdropFilename + "_bg"
    @base_file = "Graphics/Battlebacks/" + baseFilename + "_base1"
    super(sprites, viewport)
  end
  
  #-----------------------------------------------------------------------------
  # Plays the animation.
  #-----------------------------------------------------------------------------
  def createProcesses
    delay = 0
    center_x, center_y = Graphics.width / 2, Graphics.height / 2
    #---------------------------------------------------------------------------
    # Sets up background.
    bgData = dxSetBackdrop(@path + "Primal/bg", @bg_file, delay)
    picBG, sprBG = bgData[0], bgData[1]
    #---------------------------------------------------------------------------
    # Sets up bases.
    baseData = dxSetBases(@path + "Primal/base", @base_file, delay, center_x, center_y)
    arrBASES = baseData[0]
    #---------------------------------------------------------------------------
    # Sets up overlay.
    overlayData = dxSetOverlay(@path + "burst", delay)
    picOVERLAY, sprOVERLAY = overlayData[0], overlayData[1]
    #---------------------------------------------------------------------------
    # Sets up battler.
    pokeData = dxSetPokemon(@pkmn, delay, !@opposes)
    picPOKE, sprPOKE = pokeData[0], pokeData[1]
    #---------------------------------------------------------------------------
    # Animation objects.
    orbData = dxSetSprite(@path + "Primal/orb_" + @pkmn.species.to_s, delay, center_x, center_y, false, 0, 0)
    picORB, sprORB = orbData[0], orbData[1]
    shineData = dxSetSprite(@path + "shine", delay, center_x, center_y)
    picSHINE, sprSHINE = shineData[0], shineData[1]
    #---------------------------------------------------------------------------
    # Sets up Primal Pokemon.
    arrPOKE = dxSetPokemonWithOutline(@primal, delay, !@opposes)
    arrPOKE.last[0].setColor(delay, Color.white)
    #---------------------------------------------------------------------------
    # Sets up Primal icon.
    iconData = dxSetSprite(@path + "Primal/icon_" + @pkmn.species.to_s, delay, center_x, center_y, false, 0)
    picORB2, sprORB2 = iconData[0], iconData[1]
    #---------------------------------------------------------------------------
    # Animation objects.
    arrPARTICLES = dxSetParticles(@path + "particle", delay, center_x, center_y, 200)
    pulseData = dxSetSprite(@path + "pulse", delay, center_x, center_y, false, 100, 50)
    picPULSE, sprPULSE = pulseData[0], pulseData[1]
    #---------------------------------------------------------------------------
    # Sets up skip button & fade out.
    picBUTTON = dxSetSkipButton(delay)
    picFADE = dxSetFade(delay)
    ############################################################################
    # Animation start.
    ############################################################################
    # Fades in scene.
    picFADE.moveOpacity(delay, 8, 255)
    delay = picFADE.totalDuration
    picBG.setVisible(delay, true)
    arrBASES.first.setVisible(delay, true)
    picPOKE.setVisible(delay, true)
    picFADE.moveOpacity(delay, 8, 0)
    delay = picFADE.totalDuration
    picBUTTON.moveXY(delay, 6, 0, Graphics.height - 38)
    picBUTTON.moveXY(delay + 36, 6, 0, Graphics.height)
    #---------------------------------------------------------------------------
    # Darkens background/base tone; brightens Pokemon to white.
    picPOKE.setSE(delay, "DX Power Up")
    picBG.moveTone(delay, 15, Tone.new(-200, -200, -200))
    arrBASES.first.moveTone(delay, 15, Tone.new(-200, -200, -200))
    picPOKE.moveTone(delay, 8, Tone.new(-255, -255, -255, 255))
    picPOKE.moveColor(delay + 8, 6, Color.white)
    #---------------------------------------------------------------------------
    # Particles begin drawing in to Pokemon.
    repeat = delay
    2.times do |t|
      repeat -= 4 if t > 0
      arrPARTICLES.each_with_index do |p, i|
        p[0].setVisible(repeat + i, true)
        p[0].moveXY(repeat + i, 4, center_x, center_y)
        repeat = p[0].totalDuration
        p[0].setVisible(repeat + i, false)
        p[0].setXY(repeat + i, p[1], p[2])
        p[0].setZoom(repeat + i, 100)
        repeat = p[0].totalDuration - 2
      end
    end
    particleEnd = arrPARTICLES.last[0].totalDuration
    delay = picPOKE.totalDuration + 4
    #---------------------------------------------------------------------------
    # White orb engulfs Pokemon; Primal icon appears; orb expands away from Pokemon.
    picORB.setVisible(delay, true)
    picORB2.setVisible(delay, true)
    picORB.moveZoom(delay, 8, 100)
    picORB.moveOpacity(delay, 8, 255)
    picPOKE.moveOpacity(delay + 8, 4, 0)
    picORB2.setSE(particleEnd, "Anim/Scary Face")
    picORB2.moveOpacity(particleEnd, 16, 255)
    delay = picORB2.totalDuration
    picSHINE.setVisible(delay, true)
    picSHINE.moveOpacity(delay, 4, 255)
    if @bg_color
      picBG.moveColor(delay, 12, @bg_color)
      arrBASES.first.moveColor(delay, 12, @bg_color)
    end
    t = 0.5
    16.times do |i|
      picORB.setSE(delay, "Anim/Wring Out", 100, 60) if i == 0
      picORB.moveXY(delay, t, @pictureSprites[sprORB].x + 2, @pictureSprites[sprORB].y)
      picORB2.moveXY(delay, t, @pictureSprites[sprORB2].x + 2, @pictureSprites[sprORB2].y)
      picORB.moveXY(delay + t, t, @pictureSprites[sprORB].x - 2, @pictureSprites[sprORB].y)
      picORB2.moveXY(delay + t, t, @pictureSprites[sprORB2].x - 2, @pictureSprites[sprORB2].y)
      delay = picORB2.totalDuration
    end
    picORB2.setSE(delay, "Anim/Explosion")
    picORB2.moveZoom(delay, 8, 1000)
    picORB2.moveOpacity(delay, 8, 0)
    arrPOKE.each { |p, s| p.setVisible(delay + 6, true) }
    picORB.moveZoom(delay + 6, 8, 1000)
    picORB.moveOpacity(delay + 6, 8, 0)
    #---------------------------------------------------------------------------
    # White screen flash; shows silhouette of Primal Pokemon.
    picFADE.setColor(delay + 4, @bg_color || Color.white)
    picFADE.moveOpacity(delay + 4, 12, 255)
    delay = picFADE.totalDuration
    arrPOKE.last[0].setColor(delay, Color.black)
    picFADE.moveOpacity(delay, 6, 0)
    picFADE.setColor(delay + 6, Color.black)
    delay = picFADE.totalDuration
    #---------------------------------------------------------------------------
    # Primal Pokemon revealed; pulse expands outwards; overlay shown.
    picOVERLAY.setVisible(delay, true)
    picOVERLAY.moveOpacity(delay, 5, 0)
    picSHINE.setVisible(delay, true)
    picPULSE.setVisible(delay, true)
    picPULSE.moveZoom(delay, 5, 1000)
    picPULSE.moveOpacity(delay + 2, 5, 0)
    arrPOKE.last[0].moveColor(delay, 8, Color.new(0, 0, 0, 0))
    #---------------------------------------------------------------------------
    # Shakes Pokemon; plays cry; flashes overlay. Fades out.
    16.times do |i|
      if i > 0
        arrPOKE.each { |p, s| p.moveXY(delay, t, @pictureSprites[s].x, @pictureSprites[s].y + 2) }
        arrPOKE.each { |p, s| p.moveXY(delay + t, t, @pictureSprites[s].x, @pictureSprites[s].y - 2) }
        picOVERLAY.moveOpacity(delay + t, 2, 160)
        picSHINE.moveOpacity(delay + t, 2, 160)
      else
        picPOKE.setSE(delay + t, @cry_file) if @cry_file
      end
      picOVERLAY.moveOpacity(delay + t, 2, 240)
      picSHINE.moveOpacity(delay + t, 2, 240)
      delay = arrPOKE.last[0].totalDuration
    end
    picOVERLAY.moveOpacity(delay, 4, 0)
    picSHINE.moveOpacity(delay, 4, 0)
    picFADE.moveOpacity(delay + 20, 8, 255)
  end
end

#-------------------------------------------------------------------------------
# Calls the animation.
#-------------------------------------------------------------------------------
class Battle::Scene
  def pbShowPrimalReversion(idxBattler)
    primalAnim = Animation::BattlerPrimalReversion.new(@sprites, @viewport, idxBattler, @battle)
    loop do
      if Input.press?(Input::ACTION)
        pbPlayCancelSE
        break 
      end
      primalAnim.update
      pbUpdate
      break if primalAnim.animDone?
    end
    primalAnim.dispose
  end
end