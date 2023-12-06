class Battle  
  def pbGainExp
    values = []
    moves  = {}
    # Play wild victory music if it's the end of the battle (has to be here)
    @scene.pbWildBattleSuccess if wildBattle? && pbAllFainted?(1) && !pbAllFainted?(0)
    return if !@internalBattle || !@expGain
    # Go through each battler in turn to find the Pokémon that participated in
    # battle against it, and award those Pokémon Exp/EVs
    expAll = true
    p1 = pbParty(0)
    @battlers.each do |b|
      next unless b&.opposes?   # Can only gain Exp from fainted foes
      next if b.participants.length == 0
      next unless b.fainted? || b.captured
      # Count the number of participants
      numPartic = 0
		if $game_variables[MECHANICSVAR] < 3
			eachInTeam(0, 0) do |pkmn, i|
				b.participants.push(i) # brute forcing my way to get this thing to have all possible allys to be "participants"
			end
			b.participants.uniq! # removing repeats
		end
      b.participants.each do |partic|
        next unless pbIsOwner?(0, partic)
        numPartic += 1
      end
      # Find which Pokémon have an Exp Share
      expShare = [] # filler
		haveexpleech = 0
		expleechtargets = []
		eachInTeam(0, 0) do |pkmn, i|
			next if !pkmn.hasItem?(:EXPSHARE)
			haveexpleech += 1
			expleechtargets.push(i)
		end
		vanillaStuff = false
		vanillaStuff = true if $bag.has?(:EXPALLOFF) && $game_variables[MECHANICSVAR] < 3
		expAll = false if haveexpleech>0
		expAll = false if vanillaStuff
      # Calculate EV and Exp gains for the participants
			if expAll
				# Gain Exp for all Pokémon due to no Exp Leech users
				eachInTeam(0, 0) do |pkmn, i|
					values[i] = pbGainExpOne_Panel(i, b, numPartic, expShare, expAll, true)
				end
			else
				if !vanillaStuff
					# Gain Exp for Exp Leech users
					eachInTeam(0, 0) do |pkmn, i|
						next unless expleechtargets.include?(i)
						values[i] = pbGainExpOne_Panel(i, b, haveexpleech, expleechtargets, expAll, !pkmn.shadowPokemon?)
					end
				else
					eachInTeam(0, 0) do |pkmn, i|
						unless b.participants.include?(i)
							values[i] = 0
							next
						end
						values[i] = pbGainExpOne_Panel(i, b, numPartic, expShare, expAll, true)
					end
				end
			end
      vr = []
			totalexps=0
      for v in values
        t_v = v ? v : 0
        vr.push(t_v)
			totalexps+=v.to_i
      end
			if totalexps>0
				values = vr
				s = Swdfm_Exp_Screen.new(values)
				# Clear the participants array
				for i in 0...$player.party.size
					next if values[i] == 0
					pbActualLevelUpAndGatherMoves(i, values[i])
				end
			end
      b.participants = []
    end
  end
  
  def pbGainExpOne_Panel(idxParty, defeatedBattler, numPartic, expShare, expAll, showMessages = true)
    pkmn = pbParty(0)[idxParty]   # The Pokémon gaining Exp from defeatedBattler
    growth_rate = pkmn.growth_rate
		if defeatedBattler.isSpecies?(:PHYTIDE) && pkmn.isSpecies?(:PHYTIDE) # Phytide evolution method
			pkmn.evolution_steps += 1
		end
    # Don't bother calculating if gainer is already at max Exp
    if pkmn.exp >= growth_rate.maximum_exp
      pkmn.calc_stats   # To ensure new EVs still have an effect
      return 0
    end
    isPartic    = defeatedBattler.participants.include?(idxParty)
    hasExpShare = expShare.include?(idxParty)
    level = defeatedBattler.level
    # Main Exp calculation
    exp = 0
		if !expAll # if someone has exp leech
			haveexpshare = numPartic # number of mons with exp leech
		else
			haveexpshare = 1	
		end
		a = level * defeatedBattler.pokemon.base_exp
		exp = (a/defeatedBattler.participants.length).floor * haveexpshare
    return 0 if exp <= 0
		# level cap #by low
		truelevel = defeatedBattler.level															# stuff
		truelevel -= 10 if $game_variables[MASTERMODEVARS][7]==true		# for
		truelevel -= 20 if $game_variables[MASTERMODEVARS][22]==true	# master
		truelevel -= 30 if $game_variables[MASTERMODEVARS][24]==true	# mode
		truelevel -= 60 if $game_variables[MASTERMODEVARS][27]==true	# settings
		exp = (exp / 3).floor
		expvariable = ($game_switches[LOWEREXPGAINSWITCH]) ? 50 : 33
		exp = (exp * (100 + expvariable * (truelevel - pkmn.level)) / 100).floor
		exp = 0 if pkmn.level - truelevel == 3
		exp = (exp / 2).floor if pkmn.level>40
		#exp = (exp * 0.2).floor if $game_switches[319] 				# custom wild
		#exp = 0 if $game_switches[305] && pkmn.level>=level 		# leader rematch
		# exp leech #by low
		if !expAll
			# exp is multiplied by (number of allies in party) / (number of allies with exp leech) 
			# 100.0 so we get some not round numbers
			exp *= ((defeatedBattler.participants.length)*100)/(numPartic*100.0)
		end
    # Make sure Exp doesn't exceed the maximum
    expFinal = growth_rate.add_exp(pkmn.exp, exp)
    expGained = expFinal - pkmn.exp
    return 0 if expGained <= 0
    return expGained
  end
  
  def pbActualLevelUpAndGatherMoves(idxParty, expGained)
    pkmn = pbParty(0)[idxParty]
    $stats.total_exp_gained += expGained
    battler  = pbFindBattler(idxParty)
    new_lvl  = pkmn.growth_rate.level_from_exp(pkmn.exp + expGained)
    moves    = []
    moveList = pkmn.getMoveList
    for level in (pkmn.level + 1)..new_lvl
      pkmn.changeHappiness("levelup")
      moveList.each { |m| moves.push(m[1]) if m[0] == level }
    end
    # Actual adding of exp
    pkmn.exp = pkmn.exp + expGained
    pkmn.calc_stats
    battler&.pbUpdate(false)
    @scene.pbRefreshOne(battler.index) if battler
    return if moves.empty?
	moves.each { |m|
  	  pbLearnMove(idxParty, m)
	}
  end
end