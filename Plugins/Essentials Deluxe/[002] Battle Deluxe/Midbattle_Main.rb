#===============================================================================
# The main method for executing mid-battle effects once triggered.
#===============================================================================


#-------------------------------------------------------------------------------
# Procs mid-battle effects.
#-------------------------------------------------------------------------------
class Battle::Scene
  def dx_midbattle(idxBattler, idxTarget, *triggers)
    return if !$game_temp.dx_midbattle?
    alt_trainer = alt_battler = nil
    base_battler = midbattle_Battler(idxBattler, idxTarget, :Self)
    base_trainer = (idxBattler) ? @battle.pbGetOwnerIndexFromBattlerIndex(idxBattler) : 0
    midbattle    = $game_temp.dx_midbattle
    all_triggers = []
    triggers.each do |trigger| 
      all_triggers.push(trigger,
                        trigger + "_repeat",
                        trigger + "_repeat_alt",
                        trigger + "_random",
                        trigger + "_repeat_random") 
    end
    $game_temp.dx_midbattle.keys.each do |mid|
      next if !$game_temp.dx_midbattle[mid].is_a?(Hash)
      next if !$game_temp.dx_midbattle[mid].has_key?(:delay)
      if $game_temp.dx_midbattle[mid][:delay].is_a?(Array)
        $game_temp.dx_midbattle[mid][:delay].each do |delay_trigger|
        $game_temp.dx_midbattle[mid][:delay] = nil if all_triggers.include?(delay_trigger)
      end
      else
        if all_triggers.include?($game_temp.dx_midbattle[mid][:delay])
          $game_temp.dx_midbattle[mid][:delay] = nil 
        end
      end
    end
    all_triggers.each do |trigger|
      next if !midbattle.has_key?(trigger)
      next if trigger.include?("_random") && rand(10) < 5
      next if trigger.include?("repeat_alt") && @battle.turnCount.even?
      case midbattle[trigger]
      #-------------------------------------------------------------------------
      # When trigger is set to a String or Array, plays trainer speech if possible.
      #-------------------------------------------------------------------------
      when String, Array
        pbMidbattleSpeech(base_trainer, idxTarget, base_battler, midbattle[trigger])
        $game_temp.dx_midbattle.delete(trigger) if !trigger.include?("_repeat")
      #-------------------------------------------------------------------------
      # When trigger is set to a proc (not implemented).
      #-------------------------------------------------------------------------
      when Proc
        #midbattle[trigger].call
        $game_temp.dx_midbattle.delete(trigger) if !trigger.include?("_repeat")
      #-------------------------------------------------------------------------
      # When trigger is set to a hash, applies all effects entered in the hash.
      #-------------------------------------------------------------------------
      when Hash
        keys = []
        midbattle[trigger].keys.each do |k|
          string = k.to_s.split("_")
          keys.push([string[0].to_sym, k])
        end
        delay = false
        for key in keys
          trainer = (alt_trainer.nil?) ? base_trainer : alt_trainer
          battler = (alt_battler.nil?) ? base_battler : alt_battler
          value = midbattle[trigger][key[1]]
          case key[0]
          #---------------------------------------------------------------------
          # Sets the battler.
          #---------------------------------------------------------------------
          when :battler
            alt_battler = midbattle_Battler(idxBattler, idxTarget, value)
          #---------------------------------------------------------------------
          # Sets the trainer.
          #---------------------------------------------------------------------
          when :trainer
            temp_battler = midbattle_Battler(idxBattler, idxTarget, value)
            alt_trainer = @battle.pbGetOwnerIndexFromBattlerIndex(temp_battler.index)
          #---------------------------------------------------------------------
          # Renames a battler.
          #---------------------------------------------------------------------	
          when :rename
            battler.pokemon.name = value
            battler.name = battler.pokemon.name
            pbRefresh
          #---------------------------------------------------------------------
          # Delays further actions until the inputted trigger has been met.
          #---------------------------------------------------------------------	
          when :delay
            if value.is_a?(String) || value.is_a?(Array)
            delay = true
            break
          end
          #---------------------------------------------------------------------
          # Pauses further actions for a number of frames.
          #---------------------------------------------------------------------
          when :wait, :pause          then pbWait(value)
          #---------------------------------------------------------------------
          # Changes BGM.
          #---------------------------------------------------------------------
          when :bgm, :music           then midbattle_ChangeBGM(value)
          #---------------------------------------------------------------------
          # Plays a sound effect.
          #---------------------------------------------------------------------
          when :playcry, :cry         then battler.pokemon.play_cry
          when :playsound, :playSE    then pbSEPlay(value)
          #---------------------------------------------------------------------
          # Displays text and speech.
          #---------------------------------------------------------------------
          when :text, :message        then pbMidbattleSpeech(trainer, idxTarget, battler, value, false)
          when :speech, :dialogue     then pbMidbattleSpeech(trainer, idxTarget, battler, value)
          #---------------------------------------------------------------------
          # Plays an animation.
          #---------------------------------------------------------------------
          when :anim, :animation      then midbattle_PlayAnimation(battler, idxTarget, value)
          #---------------------------------------------------------------------
          # Uses an item on a battler.
          #---------------------------------------------------------------------
          when :useitem               then midbattle_UseItem(battler, value)
          #---------------------------------------------------------------------
          # Changes to battlers or battle states.
          #---------------------------------------------------------------------
          when :hp                    then midbattle_ChangeHP(battler, value)
          when :status                then midbattle_ChangeStatus(battler, value)
          when :form                  then midbattle_ChangeForm(battler, value)
          when :ability               then midbattle_ChangeAbility(battler, value)
          when :item, :helditem       then midbattle_ChangeItem(battler, value)
          when :move, :moves      	  then midbattle_ChangeMoves(battler, value)
          when :stat, :stats          then midbattle_ChangeStats(battler, value) 
          when :effect, :effects      then midbattle_BattlerEffects(battler, value)
          when :team, :teams          then midbattle_TeamEffects(battler, value)
          when :field                 then midbattle_FieldEffects(battler, value)
          when :weather               then midbattle_ChangeWeather(battler, value)
          when :terrain               then midbattle_ChangeTerrain(battler, value)
          when :environ, :environment then midbattle_ChangeEnvironment(value)
          when :backdrop, :background then midbattle_ChangeBackdrop(value)
          #---------------------------------------------------------------------
          # Prematurely ends the battle.
          #---------------------------------------------------------------------
          when :endbattle
            next if @battle.decision > 0
            @battle.decision = value
          end
        end
        next if trigger.include?("_repeat") || delay
        $game_temp.dx_midbattle.delete(trigger)
      end
    end
  end
              
  #-----------------------------------------------------------------------------
  # Animation for trainer speech.
  #-----------------------------------------------------------------------------
  def pbMidbattleSpeech(idxTrainer, idxTarget, battler, speech = [], dialogue = true)
    return if speech.empty?
    pbWait(8)
    if @battle.opponent.nil?
      trainer = @battle.player[idxTrainer]
      foe_trainer = false
    elsif dialogue || @battle.decision == 2 || @battle.pbAllFainted? 
      trainer = @battle.opponent[idxTrainer]
      foe_trainer = true
    else
      trainer = @battle.player[idxTrainer]
      foe_trainer = false
    end
    if foe_trainer
      pbToggleDataboxes
      pbToggleBlackBars(true)
      pbShowOpponent(idxTrainer)
    end
    index = battler.index
    if speech.is_a?(Array)
      speech.each_with_index do |text, i|
        case text
        when String
          next if !battler
          if foe_trainer
            name = (i == 0) ? "#{trainer.name.upcase}: " : ""
            @battle.pbDisplayPaused(_INTL("#{name}#{text}", battler.name))
          else
            lowercase = (text.first == "{") ? false : true
            @battle.pbDisplay(_INTL("#{text}", battler.pbThis(lowercase)))
          end
        else
          battler = midbattle_Battler(battler.index, idxTarget, text)
        end
      end
    else
      if foe_trainer
        @battle.pbDisplayPaused(_INTL("#{trainer.name.upcase}: #{speech}", battler.name))
      else
        lowercase = (speech.first == "{") ? false : true
        @battle.pbDisplay(_INTL("#{speech}", battler.pbThis(lowercase)))
      end
    end
    if foe_trainer
      pbToggleBlackBars
	  pbToggleDataboxes
      pbHideOpponent(idxTrainer)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Gets a particular battler to target during midbattle checks.
  #-----------------------------------------------------------------------------
  def midbattle_Battler(idxBattler, idxTarget, index)
    case index
    when Numeric
      return (@battle.battlers[index]) ? @battle.battlers[index] : @battle.battlers[0]
    when :Self, :Ally, :Ally2
      battler = (idxBattler) ? @battle.battlers[idxBattler] : @battle.battlers[0]
      if battler.allAllies.length > 0
        case index
        when :Ally  then return battler.allAllies.first
        when :Ally2 then return battler.allAllies.last
        end
      end
      return battler
    when :Opposing, :OpposingAlly, :OpposingAlly2
      default = (idxBattler) ? @battle.battlers[idxBattler] : @battle.battlers[0]
      battler = (idxTarget) ? @battle.battlers[idxTarget] : default.pbDirectOpposing
      if battler.allAllies.length > 0 
        case index
        when :OpposingAlly  then return battler.allAllies.first
        when :OpposingAlly2 then return battler.allAllies.last
        end
      end
      return battler
    end
  end
  
  #-------------------------------------------------------------------------------
  # Plays an animation.
  #-------------------------------------------------------------------------------
  def midbattle_PlayAnimation(battler, idxTarget, value)
    if value.is_a?(Array)
      anim, index = value[0], value[1]
    else
      anim, index = value, nil
    end
    target = (index) ? midbattle_Battler(battler.index, idxTarget, index) : nil
    case anim
    when Symbol then pbAnimation(anim, battler, target)
    when String then pbCommonAnimation(anim, battler, target)
    end
  end
  
  #-------------------------------------------------------------------------------
  # Uses an item on a battler.
  #-------------------------------------------------------------------------------
  def midbattle_UseItem(battler, item)
    trainerName = @battle.pbGetOwnerName(battler.index)
    @battle.pbUseItemMessage(item, trainerName)
    if battler
      if ItemHandlers.triggerCanUseInBattle(item, battler.pokemon, battler, 0, true, @battle, self, false)
        ItemHandlers.triggerBattleUseOnBattler(item, battler, self)
        battler.pbItemOnStatDropped
      else
        @battle.pbDisplay(_INTL("But it had no effect!"))
      end
    else
      @battle.pbDisplay(_INTL("But it's not where this item can be used!"))
    end
  end
  
  #-------------------------------------------------------------------------------
  # Changes a battler's HP.
  #-------------------------------------------------------------------------------
  def midbattle_ChangeHP(battler, value)
    return if !battler || battler.fainted? || @battle.decision > 0
    if value.is_a?(Array)
      amt, msg = value[0], value[1]
    else
      amt, msg = value, nil
    end
    lowercase = (msg && msg.first == "{") ? false : true
    if amt > 0
      case amt
      when 1 then healed = battler.pbRecoverHP(battler.totalhp)
      else        healed = battler.pbRecoverHP(battler.totalhp / amt)
      end
      @battle.pbDisplay(_INTL("#{msg}", battler.pbThis(lowercase))) if msg && healed > 0
    elsif amt < 0
      oldHP = battler.hp
      case amt.abs
      when 1 then battler.hp = 0
      else        battler.hp -= (battler.totalhp / amt.abs).round
      end
      battler.hp = 0 if battler.hp < 0
      pbHitAndHPLossAnimation([[battler, oldHP, 0]])
      @battle.pbDisplay(_INTL("#{msg}", battler.pbThis(lowercase))) if msg
      battler.pbFaint if battler.fainted?
    end
  end
  
  #-------------------------------------------------------------------------------
  # Changes a battler's status.
  #-------------------------------------------------------------------------------
  def midbattle_ChangeStatus(battler, value)
    return if !battler || battler.fainted? || @battle.decision > 0
    if value.is_a?(Array)
      status, msg = value[0], value[1]
    else
      status, msg = value, false
    end
    case status
    # Cures status
    when :NONE
      battler.pbCureAttract
      battler.pbCureConfusion
      battler.pbCureStatus(msg)
    # Inflicts status
    when :CONFUSION
      battler.pbConfuse(msg) if battler.pbCanConfuse?(battler, msg)
    when :TOXIC
      battler.pbPoison(nil, msg, true) if battler.pbCanPoison?(battler, msg)
    else
      if GameData::Status.exists?(status) && battler.pbCanInflictStatus?(status, battler, msg)
        battler.pbInflictStatus(status, (status == :SLEEP) ? battler.pbSleepDuration : 0)
      end
    end
  end
  
  #-------------------------------------------------------------------------------
  # Changes a battler's form.
  #-------------------------------------------------------------------------------
  def midbattle_ChangeForm(battler, value)
    return if !battler || battler.fainted? || @battle.decision > 0
    if value.is_a?(Array)
      form, msg = value[0], value[1]
    else
      form, msg = value, nil
    end
    if msg.is_a?(String)
      lowercase = (msg.first == "{") ? false : true
      msg = _INTL("#{msg}", battler.pbThis(lowercase))
    end
    case form
    when :Cycle
      form = battler.form + 1
    when :Random
      total_forms = []
      GameData::Species.each do |s|
        next if s.species != battler.species
        next if s.form == battler.form || s.form == 0			
        total_forms.push(s.form)
      end
      form = total_forms.sample
    end
    return if !form
    species = GameData::Species.get_species_form(battler.species, form)
    form = GameData::Species.get(species).form
    if battler.form != form
      battler.pbChangeForm(form, msg) 
      battler.pokemon.numMoves.times do |i|
        move = battler.pokemon.moves[i]
        battler.moves[i] = Battle::Move.from_pokemon_move(@battle, move)
      end
    end
  end
  
  #-------------------------------------------------------------------------------
  # Changes a battler's ability.
  #-------------------------------------------------------------------------------
  def midbattle_ChangeAbility(battler, value)
    return if !battler || battler.fainted? || @battle.decision > 0
    if value.is_a?(Array)
      abil, msg = value[0], value[1]
    else
      abil, msg = value, nil
    end
    if GameData::Ability.exists?(abil) && !battler.unstoppableAbility? && battler.ability != abil
      @battle.pbShowAbilitySplash(battler, true, false) if msg
      oldAbil = battler.ability
      battler.ability = abil
      if msg
        @battle.pbReplaceAbilitySplash(battler)
        if msg.is_a?(String)
          lowercase = (msg.first == "{") ? false : true
          @battle.pbDisplay(_INTL("#{msg}", battler.pbThis(lowercase)))
        else
          @battle.pbDisplay(_INTL("{1} acquired {2}!", battler.pbThis, battler.abilityName))
        end
        @battle.pbHideAbilitySplash(battler)
      end
      battler.pbOnLosingAbility(oldAbil)
      battler.pbTriggerAbilityOnGainingIt
    end
  end
  
  #-------------------------------------------------------------------------------
  # Changes a battler's item.
  #-------------------------------------------------------------------------------
  def midbattle_ChangeItem(battler, value)
    return if !battler || battler.fainted? || @battle.decision > 0
    if value.is_a?(Array)
      item, msg = value[0], value[1]
    else
      item, msg = value, nil
    end
    if GameData::Item.exists?(item) && battler.item != item
      battler.item = item
      if msg
        if msg.is_a?(String)
          lowercase = (msg.first == "{") ? false : true
          @battle.pbDisplay(_INTL("#{msg}", battler.pbThis(lowercase)))
        else
          text = (battler.item == :LEFTOVERS) ? "some" : (battler.itemName.starts_with_vowel?) ? "an" : "a"
          @battle.pbDisplay(_INTL("{1} obtained {2} {3}!", battler.pbThis, text, battler.itemName))
        end
      end
    end
  end
  
  #-------------------------------------------------------------------------------
  # Changes a battler's moves.
  #-------------------------------------------------------------------------------
  def midbattle_ChangeMoves(battler, value)
    return if !battler || battler.fainted? || @battle.decision > 0
    case value
    when Array
      value.each_with_index do |m, i|
        next if !GameData::Move.exists?(m)
        move = Pokemon::Move.new(m)
        battler.moves[i] = Battle::Move.from_pokemon_move(@battle, move)
      end
    when :Reset
      battler.pokemon.reset_moves
      battler.pokemon.numMoves.times do |i|
        move = battler.pokemon.moves[i]
        battler.moves[i] = Battle::Move.from_pokemon_move(@battle, move)
      end
    else
      if GameData::Move.exists?(value)
        move = Pokemon::Move.new(value)
        battler.moves[0] = Battle::Move.from_pokemon_move(@battle, move)
      end
    end
    battler.pbCheckFormOnMovesetChange
  end
  
  #-------------------------------------------------------------------------------
  # Changes a battler's stat stages.
  #-------------------------------------------------------------------------------
  def midbattle_ChangeStats(battler, value)
    return if !battler || battler.fainted? || @battle.decision > 0
    case value
    when Array
      showAnim = true
      last_change = 0
      for i in 0...value.length / 2
        stat, stage = value[i * 2], value[i * 2 + 1]
        next if stage == 0
        if stage > 0 # Raise stats
          next if !battler.pbCanRaiseStatStage?(stat, battler)
          showAnim = true if !showAnim && last_change == -1
          if battler.pbRaiseStatStage(stat, stage, battler, showAnim)
            showAnim = false
            last_change = 1
          end
        else # Lower stats
          next if !battler.pbCanLowerStatStage?(stat, battler)
          showAnim = true if !showAnim && last_change == 1
          if battler.pbLowerStatStage(stat, stage.abs, battler, showAnim)
            showAnim = false
            last_change = -1
          end
        end
      end
    when :Reset
      if battler.hasAlteredStatStages?
        battler.pbResetStatStages
        @battle.pbDisplay(_INTL("{1}'s stat changes were removed!", battler.pbThis))
      end
    when :Reset_Raised
      if battler.hasRaisedStatStages?
        GameData::Stat.each_battle { |s| battler.stages[s.id] = 0 if battler.stages[s.id] > 0 }
        @battle.pbDisplay(_INTL("{1}'s raised stat changes were removed!", battler.pbThis))
      end
    when :Reset_Lowered
      if battler.hasLoweredStatStages?
        GameData::Stat.each_battle { |s| battler.stages[s.id] = 0 if battler.stages[s.id] < 0 }
        @battle.pbDisplay(_INTL("{1}'s lowered stat changes were removed!", battler.pbThis))
      end
    end
  end
  
  #-------------------------------------------------------------------------------
  # Applies effects on a battler.
  #-------------------------------------------------------------------------------
  def midbattle_BattlerEffects(battler, value)
    return if !battler || battler.fainted? || @battle.decision > 0
    value.each do |eff|
      effect, setting, msg = eff[0], eff[1], eff[2]
      lowercase = (msg && msg.first == "{") ? false : true
      battler.apply_battler_effects(effect, setting, msg, lowercase)
    end
  end
  
  #-------------------------------------------------------------------------------
  # Applies effects on a battler's team.
  #-------------------------------------------------------------------------------
  def midbattle_TeamEffects(battler, value)
    return if !battler || @battle.decision > 0
    skip_message = []
    value.each do |eff|
      effect, setting, msg, user_msg = eff[0], eff[1], eff[2], eff[3]
      lowercase = (msg && msg.first == "{") ? false : true
      case battler.idxOwnSide
      when 0 then index = (battler.index.even?) ? 0 : 1
      when 1 then index = (battler.index.odd?) ? 0 : 1
      end
      ret = battler.apply_team_effects(effect, setting, index, skip_message, msg, lowercase, user_msg)
      skip_message.push(ret) if ret
    end
  end
  
  #-------------------------------------------------------------------------------
  # Applies effects on the battlefield.
  #-------------------------------------------------------------------------------
  def midbattle_FieldEffects(battler, value)
    return if !battler || @battle.decision > 0
    value.each do |eff|
      effect, setting, msg = eff[0], eff[1], eff[2]
      lowercase = (msg && msg.first == "{") ? false : true
      battler.apply_field_effects(effect, setting, msg, lowercase)
    end
  end
  
  #-------------------------------------------------------------------------------
  # Changes the weather.
  #-------------------------------------------------------------------------------
  def midbattle_ChangeWeather(battler, value)
    return if [:HarshSun, :HeavyRain, :StrongWinds].include?(@battle.field.weather) || @battle.decision > 0
    case value
    when :Random
      array = []
      GameData::BattleWeather::DATA.keys.each do |w_key|
        next if [:None, :HarshSun, :HeavyRain, :StrongWinds, @battle.field.weather].include?(w_key)
        array.push(w_key)
      end
      weather = array.sample
      @battle.pbStartWeather(battler, weather, true)
    when :None
      case @battle.field.weather
      when :Sun       then @battle.pbDisplay(_INTL("The sunlight faded."))
      when :Rain      then @battle.pbDisplay(_INTL("The rain stopped."))
      when :Sandstorm then @battle.pbDisplay(_INTL("The sandstorm subsided."))
      when :Hail      then @battle.pbDisplay(_INTL("The hail stopped."))
      when :ShadowSky then @battle.pbDisplay(_INTL("The shadow sky faded."))
      else                 @battle.pbDisplay(_INTL("The weather cleared."))
      end
      @battle.pbStartWeather(battler, :None, true)
    else
      if GameData::BattleWeather.exists?(value) && @battle.field.weather != value
        @battle.pbStartWeather(battler, value, true)
      end
    end
  end
  
  #-------------------------------------------------------------------------------
  # Changes the terrain.
  #-------------------------------------------------------------------------------
  def midbattle_ChangeTerrain(battler, value)
    return if @battle.decision > 0
    case value
    when :Random
      array = []
      GameData::BattleTerrain::DATA.keys.each do |t_key|
        next if [:None, @battle.field.terrain].include?(t_key)
        array.push(t_key)
      end
      terrain = array.sample
      @battle.pbStartTerrain(battler, terrain)
    when :None
      case @battle.field.terrain
      when :Electric  then @battle.pbDisplay(_INTL("The electricity disappeared from the battlefield."))
      when :Grassy    then @battle.pbDisplay(_INTL("The grass disappeared from the battlefield."))
      when :Misty     then @battle.pbDisplay(_INTL("The mist disappeared from the battlefield."))
      when :Psychic   then @battle.pbDisplay(_INTL("The weirdness disappeared from the battlefield."))
      else                 @battle.pbDisplay(_INTL("The battlefield normalized."))
      end
      @battle.pbStartTerrain(battler, :None)
    else
      if GameData::BattleTerrain.exists?(value) && @battle.field.terrain != value
        @battle.pbStartTerrain(battler, value)
      end
    end
  end
  
  #-------------------------------------------------------------------------------
  # Changes the environment.
  #-------------------------------------------------------------------------------
  def midbattle_ChangeEnvironment(value)
    return if @battle.decision > 0
    case value
    when :Random
      array = []
      GameData::Environment::DATA.keys.each do |e_key|
        next if [:None, @battle.environment].include?(e_key)
        array.push(e_key)
      end
      environ = array.sample
      @battle.environment = environ
    else
      if GameData::Environment.exists?(value)
        @battle.environment = value
      end
    end
  end
  
  #-------------------------------------------------------------------------------
  # Changes the background music.
  #-------------------------------------------------------------------------------
  def midbattle_ChangeBGM(value)
    return if @battle.decision > 0
    if value.is_a?(Array)
      bgm, fade = value[0], value[1] * 1.0
    else
      bgm, fade = value, 0.0
    end
    pbBGMFade(fade)
    pbWait((fade * 60).round)
    pbBGMPlay(bgm)
  end
  
  #-------------------------------------------------------------------------------
  # Changes the backdrop.
  #-------------------------------------------------------------------------------
  def midbattle_ChangeBackdrop(value)
    return if @battle.decision > 0
    if value.is_a?(Array)
      backdrop, base = value[0], value[1]
    else
      backdrop = base = value
    end
    @battle.backdrop = backdrop if pbResolveBitmap("Graphics/Battlebacks/#{backdrop}_bg")
    if base && pbResolveBitmap("Graphics/Battlebacks/#{base}_base0")
      @battle.backdropBase = base 
      if base.include?("city")          then @battle.environment = :None
      elsif base.include?("grass")      then @battle.environment = :Grass
      elsif base.include?("water")      then @battle.environment = :MovingWater
      elsif base.include?("puddle")     then @battle.environment = :Puddle
      elsif base.include?("underwater") then @battle.environment = :Underwater
      elsif base.include?("cave")       then @battle.environment = :Cave
      elsif base.include?("rocky")      then @battle.environment = :Rock
      elsif base.include?("volcano")    then @battle.environment = :Volcano
      elsif base.include?("sand")       then @battle.environment = :Sand
      elsif base.include?("forest")     then @battle.environment = :Forest
      elsif base.include?("snow")       then @battle.environment = :Snow
      elsif base.include?("ice")        then @battle.environment = :Ice
      elsif base.include?("distortion") then @battle.environment = :Graveyard
      elsif base.include?("sky")        then @battle.environment = :Sky
      elsif base.include?("ultra")      then @battle.environment = :UltraSpace
      elsif base.include?("space")      then @battle.environment = :Space
      end
    end
    pbFlashRefresh
  end
end


#-------------------------------------------------------------------------------
# Battle Facility compatibility.
#-------------------------------------------------------------------------------
class Battle::DebugSceneNoLogging
  def dx_midbattle(idxBattler, idxTarget, *triggers); end
end