
if Settings::TM_TO_TUTOR 
    #===============================================================================
    # Picking up an item found on the ground
    #===============================================================================
    alias tmtutor_pbItemBall pbItemBall
    def pbItemBall(item, quantity = 1)
        item = GameData::Item.get(item)
        return false if !item || quantity < 1
        itemname = (quantity > 1) ? item.name_plural : item.name
        pocket = item.pocket
        move = item.move
        meName = (item.is_key_item?) ? "Key item get" : "Item get"
        itemname = Settings::ITEM_TITLE if Settings::SCRAP_TM_NUMBERS
        if item.is_machine?   # TM or HM
            pbMessage(_INTL("\\me[{1}]You found \\c[1]{2} {3}\\c[0]!\\wtnp[30]", meName, itemname, GameData::Move.get(move).name))
            if !$Trainer.tutornet
                pbMessage(_INTL("It seems to come with instructions on how to create an account on ...Tutor.net?"))
                pbSEPlay("Voltorb flip gain coins",volume=80,pitch=80)
                pbMessage(_INTL("You have successfully created an account and saved Tutor.net in your PokéGear's shortcuts."))
                !$Trainer.tutornet=true
            end
            pbTutorNetAdd(move)
            return true
        end    
        tmtutor_pbItemBall(item, quantity)
    end

    #===============================================================================
    # Being given an item
    #===============================================================================
    alias tmtutor_pbReceiveItem pbReceiveItem
    def pbReceiveItem(item, quantity = 1)
        item = GameData::Item.get(item)
        return false if !item || quantity < 1
        itemname = (quantity > 1) ? item.name_plural : item.name
        pocket = item.pocket
        move = item.move
        meName = (item.is_key_item?) ? "Key item get" : "Item get"
        itemname = Settings::ITEM_TITLE if Settings::SCRAP_TM_NUMBERS
        if item.is_machine?   # TM or HM
            pbMessage(_INTL("\\me[{1}]You obtained \\c[1]{2} {3}\\c[0]!\\wtnp[30]", meName, itemname, GameData::Move.get(move).name))
            if !$Trainer.tutornet
                pbMessage(_INTL("It seems to come with instructions on how to create an account on ...Tutor.net?"))
                pbSEPlay("Voltorb flip gain coins",volume=80,pitch=80)
                pbMessage(_INTL("You have successfully created an account and saved Tutor.net in your PokéGear's shortcuts."))
                !$Trainer.tutornet=true
            end
            pbTutorNetAdd(move)
            return true
        end    
        tmtutor_pbReceiveItem(item, quantity)
    end


    class PokemonMartAdapter

        def getDisplayName(item)
            item_name = getName(item)
            if GameData::Item.get(item).is_machine?
            machine = GameData::Item.get(item).move
            item_name = "TM:"
            item_name = _INTL("{1} {2}", item_name, GameData::Move.get(machine).name)
            end
            return item_name
        end
    
        def addItem(item)
            if GameData::Item.get(item).is_machine?   # TM or HM
                if !$Trainer.tutornet
                    pbMessage(_INTL("Huh, it seems to come with instructions on how to create an account on ...Tutor.net?"))
                    pbSEPlay("Voltorb flip gain coins",volume=80,pitch=80)
                    pbMessage(_INTL("You have successfully created an account and saved Tutor.net in your PokéGear's shortcuts."))
                    !$Trainer.tutornet=true
                end
                move = GameData::Item.get(item).move
                pbTutorNetAdd(move)
                return true
            else  
                return $bag.add(item)
            end  
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
            if GameData::Item.get(item).is_important? || GameData::Item.get(item).is_machine?
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
                movelist=[]
                for entry in $Trainer.tutorlist
                    movelist.push(entry[0])
                end  
                @stock.delete_if { |item| GameData::Item.get(item).is_machine? && movelist.include?(GameData::Item.get(item).move) }
                pbDisplayPaused(_INTL("Here you are! Thank you!")) { pbSEPlay("Mart buy item") }
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
    
    end  
    
    
    alias tutornet_pbPokemonMart pbPokemonMart  
    def pbPokemonMart(stock, speech = nil, cantsell = false)
        movelist=[]
        for entry in $Trainer.tutorlist
          movelist.push(entry[0])
        end  
        stock.delete_if { |item| GameData::Item.get(item).is_machine? && movelist.include?(GameData::Item.get(item).move) }  
        tutornet_pbPokemonMart(stock, speech = nil, cantsell = false)
    end

end


#===============================================================================
# Transfer existing TMs to Tutor.net and then clear the TM pocket.
#===============================================================================
def tmtutor_convert
    for i in $bag.pockets[4]
        item = GameData::Item.get(i[0])
        pbTutorNetAdd(item.move)
    end    
end

#===============================================================================
# Transfer existing TMs to Tutor.net and then clear the TM pocket.
#===============================================================================
def tmtutor_clear 
    $bag.pockets[4].clear 
end
  