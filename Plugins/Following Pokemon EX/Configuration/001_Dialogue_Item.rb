#-------------------------------------------------------------------------------
# Special hold item on a map which includes battle in the name
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_item, :battle_map, proc { |_pkmn, _random_val|
  if $game_map.name.include?(_INTL("Battle"))
    # This array can be edited and extended to your hearts content.
    items = [:POKEBALL, :POKEBALL, :POKEBALL, :GREATBALL, :GREATBALL, :ULTRABALL]
    # Choose a random item from the items array, give the player 2 of the item
    # with the message "{1} is holding a round object..."
    next true if FollowingPkmn.item(items.sample, 2, _INTL("{1} is holding a round object..."))
  end
})
#-------------------------------------------------------------------------------
# Generic Item Dialogue
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_item, :regular, proc { |_pkmn, _random_val|
  items = [
    :POTION,        :SUPERPOTION,  :FULLRESTORE,    :REVIVE,        :PPUP,
    :PPMAX,         :RARECANDY,    :REPEL,          :MAXREPEL,      :ESCAPEROPE,
    :HONEY,         :TINYMUSHROOM, :PEARL,          :NUGGET,        :GREATBALL,
    :ULTRABALL,     :THUNDERSTONE, :MOONSTONE,      :SUNSTONE,      :DUSKSTONE,
    :REDAPRICORN,   :BLUEAPRICORN, :YELLOWAPRICORN, :GREENAPRICORN, :PINKAPRICORN,
    :BLACKAPRICORN, :WHITEAPRICORN
  ]
  # If no message or quantity is specified the default message is used and the quantity of item is 1
  next true if FollowingPkmn.item(items.sample)
})
#-------------------------------------------------------------------------------
