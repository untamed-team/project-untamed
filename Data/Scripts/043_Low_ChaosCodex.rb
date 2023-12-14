# reworked the debug menu to be a ingame wiki, purely out of laziness and unwillingness of creating a dedicated menu

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

MenuHandlers.add(:battle_guide, :status_page, {
  "name"        => _INTL("Status Conditions..."),
  "parent"      => :main,
  "description" => _INTL("What are the Conditions a Pokémon can be afflicted with?")
})

MenuHandlers.add(:battle_guide, :status_page_whatisthis, {
  "name"        => _INTL("What are Status Conditions?"),
  "parent"      => :status_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[3]Status Conditions are effects that a Pokémon can have, they can deal passive damage and/or lower their capabilities. They remain after battle and after switching out."))
	}
})

MenuHandlers.add(:battle_guide, :status_page_burn, {
  "name"        => _INTL(" - Burn"),
  "parent"      => :status_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[5]When <b>burned</b>, the Pokémon loses 1/16th of their HP every turn. Their attack is also cut by 33%. \\nFire-types cannot be burned. \\n<b>Will-O-Wisp</b> is the most common way of causing a burn."))
	}
})

MenuHandlers.add(:battle_guide, :status_page_frostbite, {
  "name"        => _INTL(" - Frostbite"),
  "parent"      => :status_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[5]When <b>frostbitten</b>, the Pokémon loses lose 1/16th of their HP every turn. Their special attack is also cut by 33%. \\nIce-types cannot be frostbitten. \\n<b>Biting Cold</b> is the most common way of causing frostbite."))
	}
})

MenuHandlers.add(:battle_guide, :status_page_para, {
  "name"        => _INTL(" - Paralysis"),
  "parent"      => :status_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[5]When <b>paralyzed</b>, a Pokémon will have their speed lowered by 25%. After 6 turns, the Pokémon will cure itself on its own. \\nElectric-types cannot be paralyzed. \\n<b>Thunder Wave</b> is the most common way of causing paralysis."))
	}
})

MenuHandlers.add(:battle_guide, :status_page_poison, {
  "name"        => _INTL(" - Poison"),
  "parent"      => :status_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[5]When <b>poisoned</b>, the Pokémon loses 1/8th of their HP every turn. After 3 turns, the amount of HP lost for that turn is doubled. \\nPoison and Steel-types cannot be poisoned. \\n<b>Toxic</b> is the most common way of causing poison."))
	}
})

MenuHandlers.add(:battle_guide, :status_page_sleep, {
  "name"        => _INTL(" - Sleep"),
  "parent"      => :status_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[5]When <b>asleep</b>, a Pokémon will be unable to do anything for 2 turns. No more than 1 Pokémon per team can be put asleep at a time. \\nStatus moves are the most common way of causing sleep, however, most of them are inaccurate."))
	}
})

MenuHandlers.add(:battle_guide, :status_page_dizzy, {
  "name"        => _INTL(" - Dizzy"),
  "parent"      => :status_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[5]When <b>dizzied</b>, a Pokémon will have its ability nullified for 2 turns. \\nPsychic-types cannot be dizzied. \\n<b>Confuse Ray</b> is the most common way of causing dizziness."))
	}
})

MenuHandlers.add(:battle_guide, :status_page_healing, {
  "name"        => _INTL("Healing Status Conditions"),
  "parent"      => :status_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[3]Status Conditions are removed when you heal at the PokéCenter or when you use one of the charges of the PokeVial."))
	}
})

MenuHandlers.add(:battle_guide, :status_page_immunity, {
  "name"        => _INTL("Immunities to Status Conditions"),
  "parent"      => :status_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[3]Type immunities do not prevent status moves. However, some types give immunities to certain status conditions."))
	}
})

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

MenuHandlers.add(:battle_guide, :wtz_page, {
  "name"        => _INTL("Weathers/Terrains/Zones..."),
  "parent"      => :main,
  "description" => _INTL("What is <b>W.T.Z.</b>? and what does each do?")
})

MenuHandlers.add(:battle_guide, :wtz_page_w_whatisthis, {
  "name"        => _INTL("What are Weathers?"),
  "parent"      => :wtz_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[3]Weathers are special states that effect the entire battlefield and help or hinder the Pokémon battling. Only one weather can be active at once."))
	}
})

MenuHandlers.add(:battle_guide, :wtz_page_w_rain, {
  "name"        => _INTL(" - Rain"),
  "parent"      => :wtz_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[5]During Rain, the damage of Water-type attacks is multiplied by 1.5 and the damage of Fire-type attacks is multiplied by 0.5."))
	}
})

MenuHandlers.add(:battle_guide, :wtz_page_w_sun, {
  "name"        => _INTL(" - Sun"),
  "parent"      => :wtz_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[5]During Sun, the damage of Fire-type attacks is multiplied by 1.5 and the damage of Water-type attacks is multiplied by 0.5."))
	}
})

MenuHandlers.add(:battle_guide, :wtz_page_w_sand, {
  "name"        => _INTL(" - Sandstorm"),
  "parent"      => :wtz_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[5]During Sandstorm, all active Pokémon take damage at the end of each turn unless they are Steel, Rock or Ground-types. Additionally, Rock-types get 1.5x SpDef."))
	}
})

MenuHandlers.add(:battle_guide, :wtz_page_w_hail, {
  "name"        => _INTL(" - Hailstorm"),
  "parent"      => :wtz_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[5]During Hailstorm, all active Pokémon take damage at the end of each turn unless they are Ice-types. Additionally, Ice-types recive less damage from super effective attacks."))
	}
})

MenuHandlers.add(:battle_guide, :wtz_page_w_winds, {
  "name"        => _INTL(" - Strong Winds"),
  "parent"      => :wtz_page,
	"effect"      => proc {
		pbMessage(_INTL("During Strong Winds, Flying-type Pokémon have no Flying related weaknesses."))
	}
})

MenuHandlers.add(:battle_guide, :wtz_page_t_whatisthis, {
  "name"        => _INTL("What are Terrains?"),
  "parent"      => :wtz_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[3]Terrains affect the entire battlefield and help or hinder the Pokémon battling. Only one terrain can be active at once and airborne Pokémon are not affected."))
	}
})

MenuHandlers.add(:battle_guide, :wtz_page_t_electric, {
  "name"        => _INTL(" - Electric Terrain"),
  "parent"      => :wtz_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[5]During Electric Terrain, the damage of grounded Electric-type attacks is multiplied by 1.3 and grounded Pokémon cannot fall asleep."))
	}
})

MenuHandlers.add(:battle_guide, :wtz_page_t_grassy, {
  "name"        => _INTL(" - Grassy Terrain"),
  "parent"      => :wtz_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[5]During Grassy Terrain, the damage of grounded Grass-type attacks is multiplied by 1.3 and grounded Pokémon gains 1/16th HP every turn."))
	}
})

MenuHandlers.add(:battle_guide, :wtz_page_t_misty, {
  "name"        => _INTL(" - Misty Terrain"),
  "parent"      => :wtz_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[5]During Misty Terrain, the damage of Dragon-type attacks against grounded Pokémon is multiplied by 0.5 and grounded Pokémon cannot gain non-volatile Status Conditions"))
	}
})

MenuHandlers.add(:battle_guide, :wtz_page_t_psychic, {
  "name"        => _INTL(" - Psychic Terrain"),
  "parent"      => :wtz_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[5]During Psychic Terrain, the damage of grounded Psychic-type attacks is multiplied by 1.3 and grounded Pokémon are immune to moves with positive priority."))
	}
})

MenuHandlers.add(:battle_guide, :wtz_page_z_whatisthis, {
  "name"        => _INTL("What are Type Zones?"),
  "parent"      => :wtz_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[3]Type Zones affect the entire battlefield and boost the damage of moves of their corresponding type by 1.5x. Only one type zone can be active at once."))
	}
})

MenuHandlers.add(:battle_guide, :wtz_page_abilities, {
  "name"        => _INTL("Passively creating WTZ"),
  "parent"      => :wtz_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[5]When any of the field conditions that boost or lower damage for specific types are set by Abilities, the damage multiplier and damage divisor are cut to 25% and 50%."))
	}
})

MenuHandlers.add(:battle_guide, :wtz_page_abilities_ex, {
  "name"        => _INTL("Passively creating WTZ (Example)"),
  "parent"      => :wtz_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[5]Taking Rain as an example: \\nIf set by <b>RAIN DANCE</b>: Water-type moves damage are multiplied by 1.5x while Fire-type moves damage are divided by 2;\\nIf set by <b>DRIZZLE</b>: Water-type moves damage are multiplied by 1.25x while Fire-type moves damage are divided by 1.5;"))
	}
})

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

MenuHandlers.add(:battle_guide, :moves_page, {
  "name"        => _INTL("Moves Changes..."),
  "parent"      => :main,
  "description" => _INTL("What notable moves where changed?")
})

MenuHandlers.add(:battle_guide, :moves_page_flinch, {
  "name"        => _INTL("Flinch"),
  "parent"      => :moves_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[5]When <b>flinched</b>, a Pokémon will be unable to do anything for the rest of the turn. Pokémon cannot be flinched on the first turn of the battle, unless the move used was <b>Fake Out</b>. Flinched Pokémon are immune to flinches for the next turn."))
	}
})

MenuHandlers.add(:battle_guide, :moves_page_setup, {
  "name"        => _INTL("Setup Moves"),
  "parent"      => :moves_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[5]Setup moves can only be used once per switch, but there is no limit on how many setup moves you can use. \\nMoves with a guaranteed chance of raising stats only raise stats once."))
	}
})

MenuHandlers.add(:battle_guide, :moves_page_misc, {
  "name"        => _INTL("Specific Moves"),
  "parent"      => :moves_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[5]<b>Knock Off</b> no longer deals increased damage to foes holding an item.\\n<b>Leech Seed</b> does damage equal to 1/10th HP, has a maximum damage of 100 HP and heals only 50% of the damage dealt."))
	}
})

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

MenuHandlers.add(:battle_guide, :trainers_page, {
  "name"        => _INTL("Trainer Changes... (Spoiler Warning!)"),
  "parent"      => :main,
  "description" => _INTL("What should I expect from trainers?")
})

MenuHandlers.add(:battle_guide, :trainers_page_gimmick, {
  "name"        => _INTL("T.G.T."),
  "parent"      => :trainers_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[5]Specific Trainers may have <b>Trainer Gimmick Traits</b>. These traits allow for field effects and statuses to take effect before the battle even starts. \\nAs an example, a trainer can have a <b>pre-burnt</b> Pokémon with Guts and Choice Band under permanent <b>pre-set Trick Room</b>."))
	}
})

MenuHandlers.add(:battle_guide, :trainers_page_megas, {
  "name"        => _INTL("M.E.M."),
  "parent"      => :trainers_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[5]Specific Pokémon may have a mutation called <b>Mega Evolution Mutation</b>. \\nThis mutation allows for the affected Pokémon to Mega Evolve (if possible) regardless of held item or if a previous Pokémon has already Mega Evolved on their side."))
	}
})

MenuHandlers.add(:battle_guide, :trainers_page_ability, {
  "name"        => _INTL("A.A.M"),
  "parent"      => :trainers_page,
	"effect"      => proc {
		pbMessage(_INTL("\\l[5]Specific Pokémon may have a mutation called <b>All Abilities Mutation</b>. \\nThis mutation allows for the affected Pokémon to all their possible abilities active at once. \\nAs an example, with this mutation a Excadrill can have <b>Sand Rush</b>, <b>Sand Force</b> and <b>Mold Breaker</b> all active at the same time."))
	}
})

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

MenuHandlers.add(:battle_guide, :clovercatchchain, {
  "name"        => _INTL("Catch Chains"),
  "parent"      => :main,
	"effect"      => proc {
		pbMessage(_INTL("\\l[5]Catch Chains increase the chance of encountering a shiny Pokémon of a particular species. \\nChaining begins by catching a Pokémon, and increases by catching more of that particular Pokémon. \\nThe larger the chain, the more likely it is that you will encounter the shiny version of the chained Pokémon.\\nThe chain will break if you catch another species of Pokémon or close the game."))
	}
})
# ==============================================================================================================================

class CommandMenuList
  def getDesc(index, chaoscodex = false)
    count = 0
    @commands.each do |cmd|
      next if cmd[1] != @currentList
      return cmd[3] if count == index && cmd[3]
      break if count == index
      count += 1
    end
		text = (chaoscodex) ? "Interact to Expand." : "<No description available>"
    return text
  end
end

def pbBattleGuideMenu(show_all = true)
  # Get all commands
  commands = CommandMenuList.new
  MenuHandlers.each_available(:battle_guide) do |option, hash, name|
    next if !show_all && !hash["always_show"].nil? && !hash["always_show"]
    if hash["description"].is_a?(Proc)
      description = hash["description"].call
    elsif !hash["description"].nil?
      description = _INTL(hash["description"])
    end
    commands.add(option, hash, name, description)
  end
  # Setup windows
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  sprites = {}
  sprites["textbox"] = pbCreateMessageWindow
  sprites["textbox"].letterbyletter = false
  sprites["cmdwindow"] = Window_CommandPokemonEx.new(commands.list)
  cmdwindow = sprites["cmdwindow"]
  cmdwindow.x        = 0
  cmdwindow.y        = 0
  cmdwindow.width    = Graphics.width
  cmdwindow.height   = Graphics.height - sprites["textbox"].height
  cmdwindow.viewport = viewport
  cmdwindow.visible  = true
  sprites["textbox"].text = commands.getDesc(cmdwindow.index, true)
  pbFadeInAndShow(sprites)
  # Main loop
  ret = -1
  refresh = true
  loop do
    loop do
      oldindex = cmdwindow.index
      cmdwindow.update
      if refresh || cmdwindow.index != oldindex
        sprites["textbox"].text = commands.getDesc(cmdwindow.index, true)
        refresh = false
      end
      Graphics.update
      Input.update
      if Input.trigger?(Input::BACK)
        parent = commands.getParent
        if parent
          pbPlayCancelSE
          commands.currentList = parent[0]
          cmdwindow.commands = commands.list
          cmdwindow.index = parent[1]
          refresh = true
        else
          ret = -1
          break
        end
      elsif Input.trigger?(Input::USE)
        ret = cmdwindow.index
        break
      end
    end
    break if ret < 0
    cmd = commands.getCommand(ret)
    if commands.hasSubMenu?(cmd)
      pbPlayDecisionSE
      commands.currentList = cmd
      cmdwindow.commands = commands.list
      cmdwindow.index = 0
      refresh = true
    else
      MenuHandlers.call(:battle_guide, cmd, "effect")
    end
  end
  pbPlayCloseMenuSE
  pbFadeOutAndHide(sprites)
  pbDisposeMessageWindow(sprites["textbox"])
  pbDisposeSpriteHash(sprites)
  viewport.dispose
end

# ==============================================================================================================================

ItemHandlers::UseFromBag.add(:CHAOSCODEX, proc { |item| 
	pbBattleGuideMenu 
	next 2 
})

ItemHandlers::UseInField.add(:CHAOSCODEX, proc { |item| pbBattleGuideMenu })