class CrustangRacing
	def self.chooseCrustang
		choices = [_INTL("Rent a Crustang"), _INTL("Use my Crustang"), _INTL("Nevermind")]
		choice = pbMessage(_INTL("Alright! Would you like to rent a Crustang from us or race with your own?"), choices, -1)
		
		case choice
		when -1
			pbMessage(_INTL("No sweat. Just let me know if you wanna race, yeah?"))
			return
		when 0
			self.rentCrustang
		when 1
			self.chooseOwnCrustang
		when 2
			pbMessage(_INTL("No sweat. Just let me know if you wanna race, yeah?"))
		end
	end
	
	#selecting a crustang if you want to rent one for a race
	def self.rentCrustang
		#save the player's current party
		@currentParty = $player.party.clone
		#remove all party members
		$player.party.length.times do
			$player.party.delete_at(0)
		end
		
		#fill the player's party with rentable crustang
		for i in 0...CrustangRacingSettings::RENTABLE_CRUSTANG.length
			pkmn = Pokemon.new(:CRUSTANG, 20)
			pkmn.name = CrustangRacingSettings::RENTABLE_CRUSTANG[i][:PkmnName]
			pkmn.owner.gender = 3
			pkmn.owner.name = CrustangRacingSettings::RENTABLE_CRUSTANG[i][:TrainerName]
			pbAddToPartySilent(pkmn)
			pkmn.moves = []
			for j in 0...CrustangRacingSettings::RENTABLE_CRUSTANG[i][:Moves].length
				pkmn.learn_move(CrustangRacingSettings::RENTABLE_CRUSTANG[i][:Moves][j])
			end
		end
		
		self.chooseOwnCrustang
	end
	
	def self.chooseOwnCrustang
		$game_variables[36] = 0
		
		pbChooseRacingPokemon(36, 37,
			proc { |pkmn| pkmn.isSpecies?(:CRUSTANG) }
		)
		
		enteredCrustang = $player.party[$game_variables[36]]
		#restore user's original party if rented a Crustang
		$player.party = @currentParty if !@currentParty.nil?
		if $game_variables[36] != -1
			#subtract money
			$player.money -= CrustangRacingSettings::COST_TO_RACE
			pbSEPlay("Mart buy item")
			pbWait(1)
			pbMessage(_INTL("A nice choice! Good luck out there!"))
			pbFadeOutIn {
				self.main(enteredCrustang)
			}
		else
			pbMessage(_INTL("No sweat. Just let me know if you wanna race, yeah?"))
		end #if $game_variables[36] != -1
	end #def self.chooseOwnCrustang
end

MenuHandlers.add(:crustang_selection_menu, :summary, {
  "name"      => _INTL("Summary"),
  "order"     => 10,
  "effect"    => proc { |screen, party, party_idx|
    screen.scene.pbSummary(party_idx) {
      screen.scene.pbSetHelpText((party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
    }
  }
})

def pbChooseRacingPokemon(variableNumber, nameVarNumber, ableProc = nil, allowIneligible = false)
  chosen = 0
  pbFadeOutIn {
    scene = PokemonParty_Scene.new
    screen = PokemonPartyScreen.new(scene, $player.party)
    chosen = screen.pbChooseRacingPokemon1(ableProc, allowIneligible)
  }
  pbSet(variableNumber, chosen)
  if chosen >= 0
    pbSet(nameVarNumber, $player.party[chosen].name)
  else
    pbSet(nameVarNumber, "")
  end
end

def pbChooseRacingPokemon1(ableProc, allowIneligible = false)
    annot = []
    eligibility = []
    @party.each do |pkmn|
      elig = ableProc.call(pkmn)
      elig = false if pkmn.egg?
      eligibility.push(elig)
      annot.push((elig) ? _INTL("ABLE") : _INTL("NOT ABLE"))
    end
    ret = -1
    @scene.pbStartScene(
      @party,
      (@party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."),
      annot
    )
    loop do
      @scene.pbSetHelpText(
        (@party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel.")
      )
      pkmnid = @scene.pbChoosePokemon
      break if pkmnid < 0
      if !eligibility[pkmnid] && !allowIneligible
        pbDisplay(_INTL("This Pokémon can't be chosen."))
      else
		
		#print "clicked on eligible pkmn"
		choices = ["Choose", "Summary", "Nevermind"]
		#pbShowCommands("Do what with #{pkmnid}?", commands, defaultValue = -1)
		#@scene.pbShowCommands(_INTL("Do what with #{pkmnid}?"), choices, -1)
		menuChoice = pbMessage(_INTL("Do what with #{$player.party[pkmnid].name}?"), choices, -1)
        case menuChoice
		when 0
			#Choose
			ret = pkmnid
			break
		when 1
			#Summary
			pbFadeOutIn {
            summary_scene = CrustangSummary_Scene.new
            summary_screen = CrustangSummaryScreen.new(summary_scene, true)
            summary_screen.pbStartScreen([$player.party[pkmnid]], 0)
          }
		end

      end
    end
    @scene.pbEndScene
    return ret
end

class CrustangSummary_Scene
  MARK_WIDTH  = 16
  MARK_HEIGHT = 16

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(party, partyindex, inbattle = false)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @party      = party
    @partyindex = partyindex
    @pokemon    = @party[@partyindex]
    @inbattle   = inbattle
    @page = 3
    @typebitmap    = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    @markingbitmap = AnimatedBitmap.new("Graphics/Pictures/Summary/markings")
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["pokemon"] = PokemonSprite.new(@viewport)
    @sprites["pokemon"].setOffset(PictureOrigin::CENTER)
    @sprites["pokemon"].x = 104
    @sprites["pokemon"].y = 206
    @sprites["pokemon"].setPokemonBitmap(@pokemon)
    @sprites["pokeicon"] = PokemonIconSprite.new(@pokemon, @viewport)
    @sprites["pokeicon"].setOffset(PictureOrigin::CENTER)
    @sprites["pokeicon"].x       = 46
    @sprites["pokeicon"].y       = 92
    @sprites["pokeicon"].visible = false
    @sprites["itemicon"] = ItemIconSprite.new(30, 320, @pokemon.item_id, @viewport)
    @sprites["itemicon"].blankzero = true
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["movepresel"] = MoveSelectionSprite.new(@viewport)
    @sprites["movepresel"].visible     = false
    @sprites["movepresel"].preselected = true
    @sprites["movesel"] = MoveSelectionSprite.new(@viewport)
    @sprites["movesel"].visible = false
    @sprites["ribbonpresel"] = RibbonSelectionSprite.new(@viewport)
    @sprites["ribbonpresel"].visible     = false
    @sprites["ribbonpresel"].preselected = true
    @sprites["ribbonsel"] = RibbonSelectionSprite.new(@viewport)
    @sprites["ribbonsel"].visible = false
    @sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow", 8, 28, 40, 2, @viewport)
    @sprites["uparrow"].x = 350
    @sprites["uparrow"].y = 56
    @sprites["uparrow"].play
    @sprites["uparrow"].visible = false
    @sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow", 8, 28, 40, 2, @viewport)
    @sprites["downarrow"].x = 350
    @sprites["downarrow"].y = 260
    @sprites["downarrow"].play
    @sprites["downarrow"].visible = false
    @sprites["markingbg"] = IconSprite.new(260, 88, @viewport)
    @sprites["markingbg"].setBitmap("Graphics/Pictures/Summary/overlay_marking")
    @sprites["markingbg"].visible = false
    @sprites["markingoverlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["markingoverlay"].visible = false
    pbSetSystemFont(@sprites["markingoverlay"].bitmap)
    @sprites["markingsel"] = IconSprite.new(0, 0, @viewport)
    @sprites["markingsel"].setBitmap("Graphics/Pictures/Summary/cursor_marking")
    @sprites["markingsel"].src_rect.height = @sprites["markingsel"].bitmap.height / 2
    @sprites["markingsel"].visible = false
    @sprites["messagebox"] = Window_AdvancedTextPokemon.new("")
    @sprites["messagebox"].viewport       = @viewport
    @sprites["messagebox"].visible        = false
    @sprites["messagebox"].letterbyletter = true
    pbBottomLeftLines(@sprites["messagebox"], 2)
    @nationalDexList = [:NONE]
    GameData::Species.each_species { |s| @nationalDexList.push(s.species) }
    drawPageFour
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
  
  def drawPageFour
			overlay = @sprites["overlay"].bitmap
			
			moveBase   = Color.new(64, 64, 64)
				moveShadow = Color.new(176, 176, 176)
				ppBase   = [moveBase,                # More than 1/2 of total PP
							Color.new(248, 192, 0),    # 1/2 of total PP or less
							Color.new(248, 136, 32),   # 1/4 of total PP or less
							Color.new(248, 72, 72)]    # Zero PP
				ppShadow = [moveShadow,             # More than 1/2 of total PP
							Color.new(144, 104, 0),   # 1/2 of total PP or less
							Color.new(144, 72, 24),   # 1/4 of total PP or less
							Color.new(136, 48, 48)]   # Zero PP
							
			@sprites["pokemon"].visible  = true
			@sprites["pokeicon"].visible = false
			@sprites["itemicon"].visible = true
			textpos  = []
			imagepos = []
			# Write move names, types and PP amounts for each known move
			if BWSUMMARY
				xPos = 32
				yPos = 76
				yAdj = 12
			else
				xPos = 248
				yPos = 104
				yAdj = 0
			end
			Pokemon::MAX_MOVES.times do |i|
			  move = @pokemon.moves[i]
			  if move
				type_number = 0#GameData::Move.get(move.id).contest_type_position
				moveSymbol = GameData::Move.get(move.id).id
				CrustangRacingSettings::MOVE_EFFECTS.each do |key, valueHash|
					#valueHash is the move's hash containing the effect name, effect code, moves, etc.
					if valueHash[:AssignedMoves].include?(moveSymbol)
						case valueHash[:EffectCode]
						when "invincible"
							type_number = 5
						when "spinOut"
							type_number = 6
						when "overload"
							type_number = 0
						when "reduceCooldown"
							type_number = 3
						when "secondBoost"
							type_number = 4
						when "rockHazard"
							type_number = 2
						when "mudHazard"
							type_number = 1
						end
					end #if valueHash[:AssignedMoves].include?
				end #CrustangRacingSettings::MOVE_EFFECTS.each do |key, valueHash|
				
				
				imagepos.push(["Graphics/Pictures/Crustang Racing/moveEffectType", xPos, yPos + yAdj - 4, 0, type_number * 28, 64, 28])
				textpos.push([move.name, xPos+68, yPos + yAdj, 0, moveBase, moveShadow])
				if move.total_pp > 0
				  textpos.push([_INTL("PP"), xPos+94, yPos + yAdj + 32, 0, moveBase, moveShadow])
				  ppfraction = 0
				  if move.pp == 0
					ppfraction = 3
				  elsif move.pp * 4 <= move.total_pp
					ppfraction = 2
				  elsif move.pp * 2 <= move.total_pp
					ppfraction = 1
				  end
				  textpos.push([sprintf("%d/%d", move.pp, move.total_pp), xPos+212, yPos + yAdj + 32, 1, ppBase[ppfraction], ppShadow[ppfraction]])
				end
			  else
				textpos.push(["-", xPos+68, yPos, 0, moveBase, moveShadow])
				textpos.push(["--", xPos+194, yPos + yAdj + 32, 1, moveBase, moveShadow])
			  end
			  yPos += 64
			end
			# Draw all text and images
			pbDrawTextPositions(overlay, textpos)
			pbDrawImagePositions(overlay, imagepos)
	end
end

class CrustangSummaryScreen
  def initialize(scene, inbattle = false)
    @scene = scene
    @inbattle = inbattle
  end

  def pbStartScreen(party, partyindex)
    @scene.pbStartScene(party, partyindex, @inbattle)
    ret = @scene.pbScene
    @scene.pbEndScene
    return ret
  end

  def pbStartForgetScreen(party, partyindex, move_to_learn)
    ret = -1
    @scene.pbStartForgetScene(party, partyindex, move_to_learn)
    loop do
      ret = @scene.pbChooseMoveToForget(move_to_learn)
      break if ret < 0 || !move_to_learn
      break if $DEBUG || !party[partyindex].moves[ret].hidden_move?
      pbMessage(_INTL("HM moves can't be forgotten now.")) { @scene.pbUpdate }
    end
    @scene.pbEndScene
    return ret
  end

  def pbStartChooseMoveScreen(party, partyindex, message)
    ret = -1
    @scene.pbStartForgetScene(party, partyindex, nil)
    pbMessage(message) { @scene.pbUpdate }
    loop do
      ret = @scene.pbChooseMoveToForget(nil)
      break if ret >= 0
      pbMessage(_INTL("You must choose a move!")) { @scene.pbUpdate }
    end
    @scene.pbEndScene
    return ret
  end
end