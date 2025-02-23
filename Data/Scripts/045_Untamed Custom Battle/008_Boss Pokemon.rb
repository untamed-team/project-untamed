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

class Battle::Battler
  def isBossPokemon?
    return (@pokemon) ? @pokemon.isBossPokemon? : false
  end
	
  ################################################################################

  def pbEffectsOnHPBarBreak(boss) 
    case boss.species
    when :NOCTAVISPA
      if boss.pokemon.remaningHPBars == 1
        @battle.pbDisplayBrief(_INTL("{1}'s servants were ordered to help!",self.pbThis))
        pbUseExtraMidTurnMove(boss, :DEFENDORDER, boss)
        pbCureMidTurn(boss, true, true)
      elsif boss.pokemon.remaningHPBars == 2
        pbChangeTypeZone(boss, :DARK, "Noctavispa's  malice summoned a Dark Zone!")
        pbChangeUserItemMidTurn(boss, :STARFBERRY)
        pbRaiseStatsMidTurn(boss, [:SPECIAL_DEFENSE, 2, :SPEED, 3])
        boss.eachOpposing do |b|
          pbLowerStatsMidTurn(b, [:SPECIAL_ATTACK, 2, :SPEED, 3])
        end
      end
    when :CRUSTANG
      if boss.pokemon.remaningHPBars == 1
        @battle.pbDisplayBrief(_INTL("1 left"))
      elsif boss.pokemon.remaningHPBars == 2
        @battle.pbDisplayBrief(_INTL("2 left"))
      elsif boss.pokemon.remaningHPBars == 3
        @battle.pbDisplayBrief(_INTL("3 left"))
      end
    end
  end

  def pbUseExtraMidTurnMove(boss, move, target)
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

  def pbChangeTypeZone(user, newZone, msg = nil)
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
      normalHP = (1.0 * self.totalhp / self.pokemon.remaningHPBars)
      amt2 = amt
      point = [self.pokemon.remaningHPBars, 1].max
      point.times do |i|
        if amt2 >= normalHP
          breakbar += 1
          amt2 -= normalHP
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
    if breakbar > 0 
      breakbar.times do
        self.pokemon.remaningHPBars -= 1
        pbEffectsOnHPBarBreak(self)
        echoln "here the hp bars ICONS drawed by the UI should update to account for the new amount, though in a ideal world, it should happen only after the hp change animation stops"
      end
    end
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
    if self.hp > 0
      echoln "here should be calc'd the individual %% of the current HP bar"
      if @battler.pokemon.remaningHPBars > 0
        normalHP = (1.0 * @battler.totalhp / @battler.pokemon.remaningHPBars)
        currentHP = self.hp / @battler.pokemon.remaningHPBars
        w = @hpBarBitmap.width.to_f * currentHP / normalHP
      else
        normalHP = @battler.totalhp
        currentHP = self.hp
        w = @hpBarBitmap.width.to_f * currentHP / normalHP
      end
      w = 1 if w < 1
      # NOTE: The line below snaps the bar's width to the nearest 2 pixels, to
      #       fit in with the rest of the graphics which are doubled in size.
      w = ((w / 2.0).round) * 2
    end
    @hpBar.src_rect.width = w
    hpColor = 0                                      # Green bar
    hpColor = 1 if self.hp <= @battler.totalhp / 2   # Yellow bar
    hpColor = 2 if self.hp <= @battler.totalhp / 4   # Red bar
    echoln "here a second HP bar should be shown underneath the first one if the remaining hp bars is higher than 0 and the current HP bar is less than 100%%"
    @hpBar.src_rect.y = hpColor * @hpBarBitmap.height / 3
    draw_bossHPBars
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
  end

  def draw_bossHPBars
    return if !@battler.isBossPokemon?
    return if @battler.pokemon.remaningHPBars == 0
    i = 0
    @battler.pokemon.remaningHPBars.times do
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