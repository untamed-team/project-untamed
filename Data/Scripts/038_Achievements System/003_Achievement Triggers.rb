#this block of code is what causes the popups
EventHandlers.add(:on_frame_update, :achievement_message_queue,
proc {
  if !$achievementmessagequeue.nil?
    $achievementmessagequeue.each_with_index {|m,i|
    $achievementmessagequeue.delete_at(i)
    #Kernel.pbMessage(m)
    #pbMessage(m)
    
    #achievement pop up
    Achievements.showAchievement(m)
    }
  end
})

EventHandlers.add(:on_step_taken, :achievement_step_count,
proc {
  if !$PokemonGlobal.stepcount.nil?
    Achievements.setProgress("STEPS",$PokemonGlobal.stepcount)
  end
})

EventHandlers.add(:on_wild_species_chosen, :achievement_battle_count,
proc { |encounter|
    Achievements.incrementProgress("WILD_ENCOUNTERS",1)
})

EventHandlers.add(:on_trainer_load, :achievement_battle_count,
proc { |trainer|
    Achievements.incrementProgress("TRAINER_BATTLES",1)
})

EventHandlers.add(:on_end_battle, :achievement_pokemon_caught,
proc { |decision|
  if decision==4
    Achievements.incrementProgress("POKEMON_CAUGHT",1)
  end
})

class Battle::Battler
  def pbFaint(showMessage = true)
    if !fainted?
      PBDebug.log("!!!***Can't faint with HP greater than 0")
      return
    end
    return if @fainted   # Has already fainted properly
    @battle.pbDisplayBrief(_INTL("{1} fainted!", pbThis)) if showMessage
    PBDebug.log("[Pokémon fainted] #{pbThis} (#{@index})") if !showMessage
    @battle.scene.pbFaintBattler(self)
    @battle.pbSetDefeated(self) if opposes?
    pbInitEffects(false)
    # Reset status
    self.status      = :NONE
    self.statusCount = 0
    # Lose happiness
    if @pokemon && @battle.internalBattle
      badLoss = @battle.allOtherSideBattlers(@index).any? { |b| b.level >= self.level + 30 }
      @pokemon.changeHappiness((badLoss) ? "faintbad" : "faint")
    end
    # Reset form
    @battle.peer.pbOnLeavingBattle(@battle, @pokemon, @battle.usedInBattle[idxOwnSide][@index / 2])
    @pokemon.makeUnmega if mega?
    @pokemon.makeUnprimal if primal?
    # Do other things
    @battle.pbClearChoice(@index)   # Reset choice
    pbOwnSide.effects[PBEffects::LastRoundFainted] = @battle.turnCount
    if $game_temp.party_direct_damage_taken &&
       $game_temp.party_direct_damage_taken[@pokemonIndex] &&
       pbOwnedByPlayer?
      $game_temp.party_direct_damage_taken[@pokemonIndex] = 0
    end
    # Check other battlers' abilities that trigger upon a battler fainting
    pbAbilitiesOnFainting
    # Check for end of primordial weather
    @battle.pbEndPrimordialWeather
    Achievements.incrementProgress("FAINTED_POKEMON",1) if @battle.pbOwnedByPlayer?(self.index)
  end
  
  alias achieve_pbUseMove pbUseMove
  def pbUseMove(*args)
    achieve_pbUseMove(*args)
    Achievements.incrementProgress("MOVES_USED",1) if @battle.pbOwnedByPlayer?(self.index) 
  end
end

#the below method is handled in the script MEM_Battle
class Battle
  alias achieve_pbMegaEvolve pbMegaEvolve
  def pbMegaEvolve(index)
    achieve_pbMegaEvolve(index)
    return if !pbOwnedByPlayer?(index)
    if @battlers[index].mega?
      Achievements.incrementProgress("MEGA_EVOLUTIONS",1)
    end
  end
  
  alias achieve_pbPrimalReversion pbPrimalReversion
  def pbPrimalReversion(index)
    achieve_pbPrimalReversion(index)
    return if !pbOwnedByPlayer?(index)
    if @battlers[index].primal?
      Achievements.incrementProgress("PRIMAL_REVERSIONS",1)
    end
  end
  
  #use item on pokemon in battle
  def pbUseItemOnPokemon(item, idxParty, userBattler)
    trainerName = pbGetOwnerName(userBattler.index)
    pbUseItemMessage(item, trainerName)
    pkmn = pbParty(userBattler.index)[idxParty]
    battler = pbFindBattler(idxParty, userBattler.index)
    ch = @choices[userBattler.index]
    if ItemHandlers.triggerCanUseInBattle(item, pkmn, battler, ch[3], true, self, @scene, false)
      ItemHandlers.triggerBattleUseOnPokemon(item, pkmn, battler, ch, @scene)
      ch[1] = nil   # Delete item from choice
      Achievements.incrementProgress("ITEMS_USED",1)
      Achievements.incrementProgress("ITEMS_USED_IN_BATTLE",1)
      return
    end
    pbDisplay(_INTL("But it had no effect!"))
    # Return unused item to Bag
    pbReturnUnusedItemToBag(item, userBattler.index)
  end
  
  #use item on pokemon outside of battle
alias achieve_pbUseItemOnPokemon pbUseItemOnPokemon
def pbUseItemOnPokemon(*args)
  ret=achieve_pbUseItemOnPokemon(*args)
  if ret
    Achievements.incrementProgress("ITEMS_USED",1)
  end
end
  
def pbUseItemOnBattler(item, idxParty, userBattler)
  trainerName = pbGetOwnerName(userBattler.index)
  pbUseItemMessage(item, trainerName)
  battler = pbFindBattler(idxParty, userBattler.index)
  ch = @choices[userBattler.index]
  if battler
    if ItemHandlers.triggerCanUseInBattle(item, battler.pokemon, battler, ch[3], true, self, @scene, false)
      ItemHandlers.triggerBattleUseOnBattler(item, battler, @scene)
      ch[1] = nil   # Delete item from choice
      battler.pbItemOnStatDropped
      Achievements.incrementProgress("ITEMS_USED",1)
      Achievements.incrementProgress("ITEMS_USED_IN_BATTLE",1)
      return
    else
      pbDisplay(_INTL("But it had no effect!"))
    end
  else
    pbDisplay(_INTL("But it's not where this item can be used!"))
  end
  # Return unused item to Bag
  pbReturnUnusedItemToBag(item, userBattler.index)
end
end

#the below method is handled in the Evolve from Party script
alias achieve_pbUseItem pbUseItem
def pbUseItem(*args)
  ret=achieve_pbUseItem(*args)
  if ret==1 || ret==3
    Achievements.incrementProgress("ITEMS_USED",1)
  end
end

class PokemonMartScreen
  def pbBuyScreen
    @scene.pbStartBuyScene(@stock, @adapter)
    item = nil
    loop do
      item = @scene.pbChooseBuyItem
      break if !item
      quantity       = 0
      itemname       = @adapter.getDisplayName(item)
      itemnameplural = @adapter.getDisplayNamePlural(item)
      price = @adapter.getPrice(item)
      if @adapter.getMoney < price
        pbDisplayPaused(_INTL("You don't have enough money."))
        next
      end
      if GameData::Item.get(item).is_important?
        next if !pbConfirm(_INTL("So you want {1}?\nIt'll be ${2}. All right?",
                            itemname, price.to_s_formatted))
        quantity = 1
      else
        maxafford = (price <= 0) ? Settings::BAG_MAX_PER_SLOT : @adapter.getMoney / price
        maxafford = Settings::BAG_MAX_PER_SLOT if maxafford > Settings::BAG_MAX_PER_SLOT
        quantity = @scene.pbChooseNumber(
          _INTL("So how many {1}?", itemnameplural), item, maxafford
        )
        next if quantity == 0
        price *= quantity
        if quantity > 1
          next if !pbConfirm(_INTL("So you want {1} {2}?\nThey'll be ${3}. All right?",
                                   quantity, itemnameplural, price.to_s_formatted))
        elsif quantity > 0
          next if !pbConfirm(_INTL("So you want {1} {2}?\nIt'll be ${3}. All right?",
                                   quantity, itemname, price.to_s_formatted))
        end
      end
      if @adapter.getMoney < price
        pbDisplayPaused(_INTL("You don't have enough money."))
        next
      end
      added = 0
      quantity.times do
        break if !@adapter.addItem(item)
        added += 1
      end
      if added == quantity
        $stats.money_spent_at_marts += price
        $stats.mart_items_bought += quantity
        @adapter.setMoney(@adapter.getMoney - price)
        @stock.delete_if { |item| GameData::Item.get(item).is_important? && $bag.has?(item) }
        pbDisplayPaused(_INTL("Here you are! Thank you!")) { pbSEPlay("Mart buy item") }
        
        #added for achievement progression
        Achievements.setProgress("ITEMS_BOUGHT",$stats.mart_items_bought)
        
        if quantity >= 10 && GameData::Item.exists?(:PREMIERBALL)
          if Settings::MORE_BONUS_PREMIER_BALLS && GameData::Item.get(item).is_poke_ball?
            premier_balls_added = 0
            (quantity / 10).times do
              break if !@adapter.addItem(:PREMIERBALL)
              premier_balls_added += 1
            end
            ball_name = GameData::Item.get(:PREMIERBALL).name
            ball_name = GameData::Item.get(:PREMIERBALL).name_plural if premier_balls_added > 1
            $stats.premier_balls_earned += premier_balls_added
            pbDisplayPaused(_INTL("And have {1} {2} on the house!", premier_balls_added, ball_name))
          elsif !Settings::MORE_BONUS_PREMIER_BALLS && GameData::Item.get(item) == :POKEBALL
            if @adapter.addItem(:PREMIERBALL)
              ball_name = GameData::Item.get(:PREMIERBALL).name
              $stats.premier_balls_earned += 1
              pbDisplayPaused(_INTL("And have 1 {1} on the house!", ball_name))
            end
          end
        end
      else
        added.times do
          if !@adapter.removeItem(item)
            raise _INTL("Failed to delete stored items")
          end
        end
        pbDisplayPaused(_INTL("You have no room in your Bag."))
      end
    end
    @scene.pbEndBuyScene
  end
  
  def pbSellScreen
    item = @scene.pbStartSellScene(@adapter.getInventory, @adapter)
    loop do
      item = @scene.pbChooseSellItem
      break if !item
      itemname       = @adapter.getDisplayName(item)
      itemnameplural = @adapter.getDisplayNamePlural(item)
      if !@adapter.canSell?(item)
        pbDisplayPaused(_INTL("Oh, no. I can't buy {1}.", itemnameplural))
        next
      end
      price = @adapter.getPrice(item, true)
      qty = @adapter.getQuantity(item)
      next if qty == 0
      @scene.pbShowMoney
      if qty > 1
        qty = @scene.pbChooseNumber(
          _INTL("How many {1} would you like to sell?", itemnameplural), item, qty
        )
      end
      if qty == 0
        @scene.pbHideMoney
        next
      end
      price *= qty
      if pbConfirm(_INTL("I can pay ${1}.\nWould that be OK?", price.to_s_formatted))
        old_money = @adapter.getMoney
        @adapter.setMoney(@adapter.getMoney + price)
        $stats.money_earned_at_marts += @adapter.getMoney - old_money
        qty.times { @adapter.removeItem(item) }
        Achievements.incrementProgress("ITEMS_SOLD",qty)
        
        sold_item_name = (qty > 1) ? itemnameplural : itemname
        pbDisplayPaused(_INTL("You turned over the {1} and got ${2}.",
                              sold_item_name, price.to_s_formatted)) { pbSEPlay("Mart buy item") }
        @scene.pbRefresh
      end
      @scene.pbHideMoney
    end
    @scene.pbEndSellScene
  end
end


alias achieve_pbItemBall pbItemBall
def pbItemBall(*args)
  #the commented code below is handled in Better Itemfinder
  #ret=achieve_pbItemBall(*args)
  #Achievements.incrementProgress("ITEM_BALL_ITEMS",1) if ret
  #return ret
end