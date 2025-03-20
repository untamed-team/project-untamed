class Pokemon
  attr_accessor :bossmonMutation
	bossmonMutation = false
	def enableBossPokemonMutation
		bossmonMutation = true
	end  
	def disableBossPokemonMutation
		bossmonMutation = false
	end    

	def toggleBossPokemonMutation
		if !bossmonMutation
			bossmonMutation = true
		else	
			bossmonMutation = false
		end	
	end 		
	
	def isBossPokemon?
		return true if bossmonMutation==true
	end
end

# array "@remaning HPBars" is [current hp bars, max hp bars]
class Battle::Battler
  def isBossPokemon?
    return (@pokemon) ? @pokemon.isBossPokemon? : false
  end
	
  ################################################################################

  def pbEffectsOnHPBarBreak
    @battle.scene.sprites["dataBox_#{self.index}"].refresh
    @battle.scene.pbAnimation(:BRICKBREAK, self.pbDirectOpposing, self)
    hpbarbreak = self.pokemon.remaningHPBars[0] - 1
    case self.species
    when :NOCTAVISPA # test battle
      case hpbarbreak
      when 0
        @battle.pbDisplayBrief(_INTL("{1}'s servants were ordered to help!", self.pbThis))
        pbUseExtraMidTurnMove(self, :DEFENDORDER, self)
        pbCureMidTurn(self, true, true)
      when 1
        pbChangeTypeZone(:DARK, "Noctavispa's malice summoned a Dark Zone!")
        pbChangeUserItemMidTurn(self, :STARFBERRY)
        pbRaiseStatsMidTurn(self, [:SPECIAL_DEFENSE, 2, :SPEED, 3])
        self.eachOpposing do |b|
          pbLowerStatsMidTurn(b, [:SPECIAL_ATTACK, 2, :SPEED, 3])
        end
      end
    when :CRUSTANG # steel gym fight
      case hpbarbreak
      when 0
        @battle.pbDisplayBrief(_INTL("{1}'s sharpens itself with nearby parts!", self.pbThis))
        pbUseExtraMidTurnMove(self, :SHARPEN, self)
      end
    end
  end
  
  def pbEffectsOnHPBarRestore
    @battle.scene.sprites["dataBox_#{self.index}"].refresh
    @battle.scene.pbAnimation(:PROTECT, self, self)
    @battle.pbDisplay(_INTL("{1} restored 1 of its shields!", self.pbThis))
  end

  def pbUseExtraMidTurnMove(boss, move, target)
    # has the side effect of making the "boss" unable to die in a single hit. Neat?
    # recording the move that the AI choose
    oldCurrentMove = boss.currentMove
    oldLastRoundMoved = boss.lastRoundMoved
    oldOutrage = boss.effects[PBEffects::Outrage]
    # using the extra move
    boss.pbUseMoveSimple(Pokemon::Move.new(move).id, target.index)
    # restoring old move action
    boss.lastRoundMoved = oldLastRoundMoved
    boss.effects[PBEffects::Outrage] = oldOutrage
    boss.currentMove = oldCurrentMove
    @battle.pbJudge
  end

  def pbCureMidTurn(boss, status = false, stats = false)
    if status
      @battle.pbParty(boss.index).each_with_index do |pkmn, i|
        next if !pkmn || !pkmn.able?
        if pkmn.status != :NONE
          if @battle.pbFindBattler(i, boss)
            boss.pbCureStatus(true)
          else
            pkmn.status      = :NONE
            pkmn.statusCount = 0
            @battle.pbDisplay(_INTL("Opposing {1} was healed from its status!", pkmn.name))
          end
        end
      end
      @battle.allSameSideBattlers(boss).each do |b|
        if b.effects[PBEffects::Confusion] > 0
          b.effects[PBEffects::Confusion] = 0
          @battle.pbDisplay(_INTL("{1} snapped out of its confusion!", b.pbThis))
        end
      end
    end
    if stats
      @battle.allSameSideBattlers(boss).each do |b|
        didsomething = false
        GameData::Stat.each_battle do |s|
          if @stages[s.id] < 0
            @statsRaisedThisRound = true
            @stages[s.id] = 0
            didsomething = true
          end
        end
        @battle.pbDisplay(_INTL("{1}'s negative stat changes were cleansed!", boss.pbThis)) if didsomething
      end
    end
  end

  def pbChangeUserItemMidTurn(boss, item = :ORANBERRY)
    if !boss.item # item was knocked off
      boss.item = item
      boss.pbHeldItemTriggerCheck
      @battle.pbDisplay(_INTL("{1} gained the item {2}!", boss.pbThis, boss.itemName))
    else
      boss.pbHeldItemTriggerCheck(item) # force the usage of a specific item
      @battle.pbDisplay(_INTL("{1} consumed the item {2}!", boss.pbThis, boss.itemName))
    end
  end

  def pbRaiseStatsMidTurn(target, stat)
    didanimonce = false
    (stat.length / 2).times do |i|
      if target.pbCanRaiseStatStage?(stat[i * 2], target)
        target.pbRaiseStatStage(stat[i * 2], stat[(i * 2) + 1], target, !didanimonce, true)
        didanimonce = true
      end
    end
  end

  def pbLowerStatsMidTurn(target, stat)
    didanimonce = false
    (stat.length / 2).times do |i|
      if target.pbCanLowerStatStage?(stat[i * 2], target)
        target.pbLowerStatStage(stat[i * 2], stat[(i * 2) + 1], target, !didanimonce)
        didanimonce = true
      end
    end
  end

  def pbChangeTypeZone(newZone, msg = nil)
    return if @battle.field.terrain == newZone
    @battle.field.terrain = newZone
    if msg.nil?
      typeofzone = GameData::Type.get(@battle.field.typezone).name
      @battle.pbDisplayBrief(_INTL("A {1} Zone was summoned, it will power up {1}-type attacks!",typeofzone))
    else
      @battle.pbDisplayBrief(_INTL(msg))
    end
    @battle.allBattlers.each { |b| b.pbAbilityOnTerrainChange }
    @battle.allBattlers.each { |b| b.pbItemTerrainStatBoostCheck }
  end

  ################################################################################

  def pbReduceHP(amt, anim = true, registerDamage = true, anyAnim = true)
    amt = amt.round
    amt *= (5.0 / 4.0) if self.effects[PBEffects::BoomInstalled]
    amt = @hp if amt > @hp
    amt = 1 if amt < 1 && !fainted?
    breakbar = 0
    if self.isBossPokemon?
      normalHP = (1.0 * self.totalhp / self.pokemon.remaningHPBars[1])
      currentHP = self.hp % normalHP.to_i == 0 ? self.hp / self.pokemon.remaningHPBars[0] : self.hp % normalHP.ceil.to_i
      amt2 = amt
      self.pokemon.remaningHPBars[0].times do |i|
        if amt2 >= currentHP
          breakbar += 1
          amt2 -= currentHP
        end
      end
    end
    oldHP = @hp
    self.hp -= amt
    PBDebug.log("[HP change] #{pbThis} lost #{amt} HP (#{oldHP}=>#{@hp})") if amt > 0
    raise _INTL("HP less than 0") if @hp < 0
    raise _INTL("HP greater than total HP") if @hp > @totalhp
    @battle.scene.pbHPChanged(self, oldHP, anim) if anyAnim && amt > 0
    if amt > 0 && registerDamage
      @droppedBelowHalfHP = true if @hp < @totalhp / 2 && @hp + amt >= @totalhp / 2
      @tookDamageThisRound = true
    end
    if self.isBossPokemon? && breakbar > 0
      self.pokemon.hpbarsstorage[0] = breakbar
    end
    return amt
  end
  
  def pbRecoverHPFromDrain(amt, target, msg = nil, ignoremsg = false)
    if target.hasActiveAbility?(:LIQUIDOOZE, true)
      @battle.pbShowAbilitySplash(target)
      pbReduceHP(amt)
      @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!", pbThis))
      @battle.pbHideAbilitySplash(target)
      pbItemHPHealCheck
    else
      if !ignoremsg
        msg = _INTL("{1} had its energy drained!", target.pbThis) if nil_or_empty?(msg)
        @battle.pbDisplay(msg)
      end
      if canHeal?
        amt = (amt * 1.3).floor if hasActiveItem?(:BIGROOT)
        pbRecoverHP(amt)
      end
    end
  end

  # array "@remaning HPBars" is [current hp bars, max hp bars]
  def pbRecoverHP(amt, anim = true, anyAnim = true, damagemove = false)
    amt = amt.round
    amt = (amt * 1.5).floor if hasActiveItem?(:COLOGNECASE) #by low
    #amt /= 2 if !pbOwnedByPlayer? && $game_variables[MASTERMODEVARS][12]==true
    amt = @totalhp - @hp if amt > @totalhp - @hp
    amt = 1 if amt < 1 && @hp < @totalhp
    restorebar = 0
    if self.isBossPokemon?
      normalHP = (1.0 * self.totalhp / self.pokemon.remaningHPBars[1])
      currentHP = self.hp % normalHP.to_i == 0 ? self.hp / self.pokemon.remaningHPBars[0] : self.hp % normalHP.ceil.to_i
      amt2 = amt
      self.pokemon.remaningHPBars[1].times do |i|
        if amt2 >= currentHP
          restorebar += 1
          amt2 -= currentHP
        end
      end
      restorebar = [restorebar, (self.pokemon.remaningHPBars[1] - 1)].min
    end
    oldHP = @hp
    self.hp += amt
    PBDebug.log("[HP change] #{pbThis} gained #{amt} HP (#{oldHP}=>#{@hp})") if amt > 0
    raise _INTL("HP less than 0") if @hp < 0
    raise _INTL("HP greater than total HP") if @hp > @totalhp
    if self.isBossPokemon? && restorebar > 0
      self.pokemon.hpbarsstorage[1] = restorebar
    end
    @battle.scene.pbHPChanged(self, oldHP, anim) if anyAnim && amt > 0
    @droppedBelowHalfHP = false if @hp >= @totalhp / 2
    return amt
  end
end

class Battle::Scene::PokemonDataBox < Sprite
  def refreshHP
    @hpNumbers.bitmap.clear
    return if !@battler.pokemon
    # Show HP numbers
    if @showHP
      pbDrawNumber(self.hp, @hpNumbers.bitmap, 54, -2, 1) #stygma
      pbDrawNumber(-1, @hpNumbers.bitmap, 54, -2)   # / char
      pbDrawNumber(@battler.totalhp, @hpNumbers.bitmap, 70, -2)
    end
    # Resize HP bar(s)
    w = 0
    remainingPoints = 0
    if self.hp > 0
      if @battler.pokemon.remaningHPBars[1] > 0 && @battler.pokemon.remaningHPBars[0] > 0
        normalHP = (1.0 * @battler.totalhp / @battler.pokemon.remaningHPBars[1])
        currentHP = self.hp % normalHP.to_i == 0 ? self.hp / @battler.pokemon.remaningHPBars[0] : self.hp % normalHP.ceil.to_i
        w = @hpBarBitmap.width.to_f * currentHP / normalHP
      else
        normalHP = @battler.totalhp
        currentHP = self.hp
        w = @hpBarBitmap.width.to_f * currentHP / normalHP
      end
      remainingPoints = (self.hp / normalHP).ceil.to_i - 1
      w = 1 if w < 1
      # NOTE: The line below snaps the bar's width to the nearest 2 pixels, to
      #       fit in with the rest of the graphics which are doubled in size.
      w = @hpBar.bitmap.width if w > @hpBar.bitmap.width
      w = ((w / 2.0).round) * 2
    end
    if @battler.isBossPokemon?
      @hpBar.src_rect.x = @hpBar.bitmap.width - w if !@showHP
      @hpBar.src_rect.width = w
      hpColor = 0                                      # Green bar
      hpColor = 1 if self.hp <= @battler.totalhp / 2   # Yellow bar
      hpColor = 2 if self.hp <= @battler.totalhp / 4   # Red bar
      @hpBar.src_rect.y = hpColor * @hpBarBitmap.height / 3
      if remainingPoints > 0
        @hpBar2.y = @hpBar.y
        @hpBar2.x = @hpBar.x
        @hpBar2.z = @hpBar.z - 1
        @hpBar2.src_rect.x = 0
        @hpBar2.visible = true
				@hpBar2.src_rect.width = @hpBar.bitmap.width
      else
        @hpBar2.visible = false
      end
      draw_bossHPBars
    else
      @hpBar.src_rect.width = w
      hpColor = 0                                      # Green bar
      hpColor = 1 if self.hp <= @battler.totalhp / 2   # Yellow bar
      hpColor = 2 if self.hp <= @battler.totalhp / 4   # Red bar
      @hpBar.src_rect.y = hpColor * @hpBarBitmap.height / 3
    end
  end

  def updateHPAnimation
    return if !@animatingHP
    if @currentHP < @endHP      # Gaining HP
      @currentHP += @hpIncPerFrame
      @currentHP = @endHP if @currentHP >= @endHP
    elsif @currentHP > @endHP   # Losing HP
      @currentHP -= @hpIncPerFrame
      @currentHP = @endHP if @currentHP <= @endHP
    end
    # Refresh the HP bar/numbers
    refreshHP
    draw_bossHPBars
    @animatingHP = false if @currentHP == @endHP
    if !@animatingHP && @battler.isBossPokemon?
      breakbar = @battler.pokemon.hpbarsstorage[0]
      if breakbar > 0
        breakbar.times do
          @battler.pokemon.remaningHPBars[0] -= 1
          @battler.pbEffectsOnHPBarBreak
        end
        @battler.pokemon.hpbarsstorage[0] = 0
      end
      restorebar = @battler.pokemon.hpbarsstorage[1]
      if restorebar > 0
        restorebar.times do
          @battler.pokemon.remaningHPBars[0] += 1
          @battler.pbEffectsOnHPBarRestore
        end
        @battler.pokemon.hpbarsstorage[1] = 0
      end
    end
  end

  def draw_bossHPBars
    return if !@battler.isBossPokemon?
    hpbars = @battler.pokemon.remaningHPBars[0] - 1
    i = 0
    hpbars.times do
      pbDrawImagePositions(self.bitmap,
        [["Graphics/Pictures/Battle/icon_HPBar", @spriteBaseX + i + 8, 48]]
      )
      i += 16
    end
  end
end

class Battle::FakeBattler
  def isBossPokemon?
    return (@pokemon) ? @pokemon.isBossPokemon? : false
  end
end