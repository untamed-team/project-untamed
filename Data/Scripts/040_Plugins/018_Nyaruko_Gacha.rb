#Script de lootboxes creado por Nyaruko
#Si metes micropagos no me hago responsable
#edited, heavily, maybe even a little bit too much #by low
POSSIBLE_TICKETS = ["Ticket A", "Ticket B", "Ticket C", "Gold Milage Ticket"]
GACHA_COST = 100 # in coins
GACHA_PITY = 4   # in gold tickets
TICKET_EXCHANGE_TXT = { # just meaningless text, though every tickets needs to be mentioned here
  "Ticket A" => "Hex Sex",
  "Ticket B" => "Zinnia Plush",
  "Ticket C" => "Elegg Figurine"
}

COMMON     = [:POTION, :ANTIDOTE, :BURNHEAL, :PARALYZEHEAL, :ICEHEAL, :POKEBALL, :REPEL, :CHARIZARDITEY, :CHARIZARDITEX]
UNCOMMON   = [:SUPERPOTION, :AWAKENING, :GREATBALL, :SUPERREPEL, :HPUP, :PROTEIN, :IRON, :CALCIUM, :ZINC, :CARBOS]
RARE       = [:HYPERPOTION, :FULLHEAL, :REVIVALHERB, :ULTRABALL, :MAXREPEL, :PEARL, :OLDGATEAU]
SUPER_RARE = [:MAXPOTION, :REVIVE, :QUICKBALL, :STARDUST, :RARECANDY, :SHINYBERRY]
ULTRA_RARE = [:FULLRESTORE, :MAXREVIVE, :MASTERBALL, :NUGGET]
PENIS_RARE = POSSIBLE_TICKETS.reject { |tckt| tckt == "Gold Milage Ticket" }
# (pokeman species, ability_index, item, form)
TICKETMONS_ARRAY = [[:PACUNA, 0, :LEFTOVERS],[:NOCTAVISPA, 1, :STICKYBARB],[:BANAGNAW, 1, :SPLASHPLATE]] 
# ^these rewards are tied to their index in comparison to the ticket exchange txt hash index, does that make sense?

# game variables, do not edit
GACHA_USED = 97
GACHA_TIME = 96

# to call this scene, use gachaPullsNPC on a npc
# the first time the player interacts with the npc; the NPC needs to force the player to pull only 3 times

class PokemonGlobalMetadata
  attr_accessor :ticketStorage
  attr_accessor :goldencamera
  alias initialize_gamble initialize
  def initialize
    initialize_gamble
    super
    @ticketStorage = []
    @goldencamera  = false
  end
  # golden camera is mentioned in the following defs:
  # pbGainMoney, pbCalcDamage, pbRoughDamage
end

def gachaPullsNPC
  commands = []
  pulloptions = []
  [1, 3, 5, 10].each do |i|
    totalpullcost = i * GACHA_COST
    next if totalpullcost > $player.coins
    commands.push(_INTL("Pull #{i} time(s) at the cost of #{totalpullcost} coins?"))
    pulloptions.push([i, totalpullcost])
  end
  commands.push(_INTL("Cancel"))

  helpwindow = Window_UnformattedTextPokemon.new("")
  helpwindow.visible = false
  cmd = UIHelper.pbShowCommands(helpwindow,"",commands) {}
  Input.update
  selectedCommander = commands[cmd]
  if selectedCommander == "Cancel"
    return false
  else
    pulloptions.each do |pullamount, totalpullcost|
      if selectedCommander == "Pull #{pullamount} time(s) at the cost of #{totalpullcost} coins?"
        $player.coins -= totalpullcost
        LootBox.new.pbStartMainScene(pullamount)
        pbMessage(_INTL("Thank you, Highroller. Please come again!"))
        return true
      end
    end
  end
end


class LootBox
  def pbStartMainScene(pullamount = 3)
    if $PokemonGlobal.ticketStorage.nil?
      $PokemonGlobal.ticketStorage = []
    end
    viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    viewport.z = 99999

    $game_variables[GACHA_TIME] = Time.now.to_i
    gachaamt = $game_variables[GACHA_USED]
    random0 = semiRandomRNG(85..100, gachaamt)
    
    common     = COMMON
    uncommon   = UNCOMMON
    rare       = RARE
    s_rare     = SUPER_RARE
    u_rare     = ULTRA_RARE
    p_rare     = PENIS_RARE
    
    sprites={}
    sprites["bg"]=Sprite.new
    sprites["bg"].z=99998
    sprites["bg"].bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/Lootboxes/","background")
    
    sprites["bolsa"]=IconSprite.new(0,0,viewport)
    sprites["bolsa"].setBitmap("Graphics/Pictures/Lootboxes/bag_closed")
    sprites["bolsa"].x = 157
    sprites["bolsa"].y = 256

    possiblepullamount = 0
    sprite_cords = GACHA_SPRITES_COORDINATES[pullamount]
    sprite_cords[:items].each_with_index do |pos, index|
      if index + 1 > pullamount || pos.nil?
        break
      else
        possiblepullamount += 1
      end
      sprites["item#{index + 1}"] = IconSprite.new(0, 0, viewport)
      sprites["item#{index + 1}"].x = pos[:x]
      sprites["item#{index + 1}"].y = pos[:y]
    end
    sprite_cords[:icons].each_with_index do |pos, index|
      if index + 1 > pullamount || pos.nil?
        break
      else
        possiblepullamount += 1
      end
      sprites["icon#{index + 1}"] = ItemIconSprite.new(0, 0, nil, viewport)
      sprites["icon#{index + 1}"].x = pos[:x]
      sprites["icon#{index + 1}"].y = pos[:y]
    end
    possiblepullamount /= 2
    
    sprites["overlay"]=BitmapSprite.new(Graphics.width, Graphics.height, viewport)
    
    loop do
      Graphics.update
      Input.update
      #if Input.trigger?(Input::C)
        pbSEPlay("select")
        pbWait(20)
        sprites["bolsa"].setBitmap("Graphics/Pictures/Lootboxes/bag_open")
        for i in 1..possiblepullamount
          gachaamt = $game_variables[GACHA_USED]
          random_val = semiRandomRNG(random0, gachaamt)
          if Time.now.to_i - $game_variables[GACHA_TIME] > 172800 # 2 days
            random_val = random_val * 0.8
            random_val = random_val.to_i
          end
          $game_variables[GACHA_USED] += 1
          random_val = 0 if i == pullamount && $game_variables[GACHA_USED] == pullamount

          case random_val
            when 0..3 # 4
              sprites["item#{i}"].setBitmap("Graphics/Pictures/Lootboxes/item_p_rare")
              pbWait(20)
              pokeman = semiRandomRNG(p_rare.length, gachaamt)
              sprites["icon#{i}"].item = GameData::Item.get(:GOLDTICKET).id
              pbMessage(_INTL("\\me[{1}]You obtained a \\c[1]{2}\\c[0]!\\wtnp[30]", "Item get", p_rare[pokeman].to_s))
              $PokemonGlobal.ticketStorage.push(p_rare[pokeman])
            when 4..10 # 7
              sprites["item#{i}"].setBitmap("Graphics/Pictures/Lootboxes/item_u_rare")
              pbWait(20)
              item = semiRandomRNG(u_rare.length, gachaamt)
              sprites["icon#{i}"].item = GameData::Item.get(u_rare[item]).id
              pbReceiveItem(u_rare[item])
            when 11..21 # 11
              sprites["item#{i}"].setBitmap("Graphics/Pictures/Lootboxes/item_s_rare")
              pbWait(20)
              item = semiRandomRNG(s_rare.length, gachaamt)
              sprites["icon#{i}"].item = GameData::Item.get(s_rare[item]).id
              pbReceiveItem(s_rare[item])
            when 22..42 # 21
              sprites["item#{i}"].setBitmap("Graphics/Pictures/Lootboxes/item_rare")
              pbWait(20)
              item = semiRandomRNG(rare.length, gachaamt)
              sprites["icon#{i}"].item = GameData::Item.get(rare[item]).id
              pbReceiveItem(rare[item])
            when 48..73 # 26
              sprites["item#{i}"].setBitmap("Graphics/Pictures/Lootboxes/item_uncommon")
              pbWait(20)
              item = semiRandomRNG(uncommon.length, gachaamt)
              sprites["icon#{i}"].item = GameData::Item.get(uncommon[item]).id
              pbReceiveItem(uncommon[item])
            else        # 32
              sprites["item#{i}"].setBitmap("Graphics/Pictures/Lootboxes/item_common")
              pbWait(20)
              item = semiRandomRNG(common.length, gachaamt)
              sprites["icon#{i}"].item = GameData::Item.get(common[item]).id
              pbReceiveItem(common[item])
            end
            
            if $game_variables[GACHA_USED] % 100 == 0
              pbMessage(_INTL("Congratulations Highroller! You've earned a Gold Milage Ticket for your dedication!"))
              $PokemonGlobal.ticketStorage.push("Gold Milage Ticket")
            end
        end
        pbWait(10)
        pbFadeOutAndHide(sprites){pbUpdateSpriteHash(sprites)}
        pbDisposeSpriteHash(sprites)
        viewport.dispose if viewport
        break
     # end  
    end  
  end
end

def ticketExchangeNPC
  commands = []
  commands.push(_INTL("My Tickets"))
  counts = Hash.new(0)
  $PokemonGlobal.ticketStorage.each { |str| counts[str] += 1 }
  ticketExchange = TICKET_EXCHANGE_TXT
  duped=false
  counts.each do |str, count|
    unless str == "Gold Milage Ticket"
      commands.push(_INTL("A #{str} for 1 #{ticketExchange[str]}")) if count >= 1
      duped=true if count > 1
    end
  end
  commands.push(_INTL("2 Dupe Tickets for 1 Milage Ticket")) if duped
  commands.push(_INTL("Cancel"))

  helpwindow = Window_UnformattedTextPokemon.new("")
  helpwindow.visible = false
  cmd = UIHelper.pbShowCommands(helpwindow,"You can exchange tickets for various things.",commands) {}
  Input.update
  selectedCommander = commands[cmd]
  case selectedCommander
  when "Cancel"
    return false
  when "My Tickets"
    ticketbag = POSSIBLE_TICKETS.map { |b| "#{b}: #{counts[b]}" }.join("\n")
    pbMessage(_INTL("You have the following tickets:\n#{ticketbag}"))
  when "2 Dupe Tickets for 1 Milage Ticket"
    counts.each do |str, count|
      if count > 1 && str != "Gold Milage Ticket"
        $PokemonGlobal.ticketStorage.delete_at($PokemonGlobal.ticketStorage.index(str))
        $PokemonGlobal.ticketStorage.delete_at($PokemonGlobal.ticketStorage.index(str))
        $PokemonGlobal.ticketStorage.push("Gold Milage Ticket")
        pbMessage(_INTL("You exchanged 2 #{str} for 1 Milage Tickets."))
        break
      end
    end
  else
    oldv = $game_switches[NOINITIALVALUES]
    ticketExchange.each_with_index do |(str, count), index|
      if selectedCommander == "A #{str} for 1 #{ticketExchange[str]}"
        $game_switches[NOINITIALVALUES] = true
        pbMessage(_INTL("You exchanged 1 #{str} for..."))
        pkmn = ticketReward(index)
        pbAddPokemon(pkmn)
        $PokemonGlobal.ticketStorage.delete_at($PokemonGlobal.ticketStorage.index(str))
        $game_switches[NOINITIALVALUES] = oldv
      end
    end
  end
end

def ticketReward(id)
  t_array = TICKETMONS_ARRAY
  pkmn = Pokemon.new(t_array[id][0], (pbBalancedLevel($player.party) - 10))
  pkmn.ability_index = t_array[id][1] if !t_array[id][1].nil?
  pkmn.item = t_array[id][2] if !t_array[id][2].nil?
  pkmn.form = t_array[id][3] if !t_array[id][3].nil?
  pkmn.makeFemale if !pkmn.singleGendered?
  pkmn.owner = Pokemon::Owner.new_foreign("Mustang", 0)
  pkmn.obtain_method = 4
  return pkmn
end

def goldTicketExchangeNPC
  pity = GACHA_PITY
  commands = []
  counts = Hash.new(0)
  $PokemonGlobal.ticketStorage.each { |str| counts[str] += 1 }
  if counts["Gold Milage Ticket"] >= pity
    POSSIBLE_TICKETS.each { |tckt|
      next if tckt == "Gold Milage Ticket"
      commands.push(_INTL("#{pity} Milage Tickets for 1 #{tckt}"))
    }
  end
  commands.push(_INTL("Cancel"))

  helpwindow = Window_UnformattedTextPokemon.new("")
  helpwindow.visible = false
  cmd = UIHelper.pbShowCommands(helpwindow,"You can exchange milage tickets for various things.",commands) {}
  Input.update
  selectedCommander = commands[cmd]
  if selectedCommander == "Cancel"
    return false
  else
    POSSIBLE_TICKETS.each do |ticket|
      next if ticket == "Gold Milage Ticket"
      if selectedCommander == "#{pity} Milage Tickets for 1 #{ticket}"
        pity.times do
          $PokemonGlobal.ticketStorage.delete_at($PokemonGlobal.ticketStorage.index("Gold Milage Ticket"))
        end
        $PokemonGlobal.ticketStorage.push(ticket)
        pbMessage(_INTL("You exchanged #{pity} Milage Tickets for 1 #{ticket}."))
      end
    end
  end
end

#===============================================================================
# settings too big to be added at the top
#===============================================================================

ItemHandlers::UseInField.add(:GOLDCAMERA,proc { |item|
  $PokemonGlobal.goldencamera = !$PokemonGlobal.goldencamera
  if $PokemonGlobal.goldencamera
    pbMessage(_INTL("The camera was turned on. It will make your Pokemon weaker but it will give you coins passively."))
  else
    pbMessage(_INTL("The camera was turned off."))
  end
  next true
})

GACHA_SPRITES_COORDINATES = {
  1 => {
    items: [{ x: 227, y: 135 }],
    icons: [{ x: 260, y: 195 }]
  },
  3 => {
    items: [
      { x: 227, y: 135 },
      { x: 99, y: 135 },
      { x: 355, y: 135 }
    ],
    icons: [
      { x: 260, y: 195 },
      { x: 134, y: 195 },
      { x: 389, y: 195 }
    ]
  },
  5 => {
    items: [
      { x: 227, y: 135 },
      { x: 139, y: 135 },
      { x: 315, y: 135 },
      { x: 51, y: 135 },
      { x: 403, y: 135 }
    ],
    icons: [
      { x: 260, y: 195 },
      { x: 174, y: 195 },
      { x: 349, y: 195 },
      { x: 85, y: 195 },
      { x: 438, y: 195 }
    ]
  },
  10 => {
    items: [
      { x: 227, y: 55 },
      { x: 139, y: 55 },
      { x: 315, y: 55 },
      { x: 51, y: 55 },
      { x: 403, y: 55 },
      { x: 227, y: 175 },
      { x: 139, y: 175 },
      { x: 315, y: 175 },
      { x: 51, y: 175 },
      { x: 403, y: 175 }
    ],
    icons: [
      { x: 260, y: 115 },
      { x: 174, y: 115 },
      { x: 349, y: 115 },
      { x: 85, y: 115 },
      { x: 438, y: 115 },
      { x: 260, y: 235 },
      { x: 174, y: 235 },
      { x: 349, y: 235 },
      { x: 85, y: 235 },
      { x: 438, y: 235 }
    ]
  }
}