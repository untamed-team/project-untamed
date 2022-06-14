class Adventure_Scene
	def getIndexFromCursor
		case @cursorpos
		when 0,2
			return 0
		when 1,3
			return 1
		when 5,7
			return 2
		when 6,8
			return 3
		when 10,12
			return 4
		when 11,13
			return 5
		else
			return -1
		end
	end
	def pbSummary(list,id)
		oldsprites = pbFadeOutAndHide(@sprites)
		scene = PokemonSummary_Scene.new
		screen = PokemonSummaryScreen.new(scene)
		screen.pbStartScreen(list,id)
		pbFadeInAndShow(@sprites,oldsprites)
	end
	def adventurechoices
		if !pbCursorValid?
			pbMessage(_INTL("There is nothing here!"))
		else
			pos = getIndexFromCursor
			answer=pbMessage("What do you want to do?", ["Move to party", "Move to PC","Summary", "Cancel"],4,nil,0)
			if answer == 0
				pbMoveToParty(pos)
			elsif answer == 1
				@adventure.pbMovetoPC(pos)
			elsif answer == 2
				pbSummary(@adventureparty,pos)
			end
		end
	end
	def partychoices
		if !pbCursorValid?
			pbMessage(_INTL("There is nothing here!"))
		else
			pos = getIndexFromCursor
			answer=pbMessage("What do you want to do?", ["Send adventuring", "Move to PC", "Summary", "Cancel"],4,nil,0)
			if answer == 0
				pbMoveToAdventure(pos)
			elsif answer == 1
				if pbBoxesFull?
					pbMessage(_INTL("The Boxes on your PC are full!"))
					return false
				else
					$PokemonStorage.pbStoreCaught(@party[pos].dup)
					$Trainer.remove_pokemon_at_index(pos)
					return true
				end
			elsif answer == 2
				pbSummary(@party,pos)
			end
		end
	end
	def pbMoveToAdventure(pos)
		if $Trainer.has_other_able_pokemon?(pos) 
			if !@adventure.party_full?
				@party[pos].play_cry
				@adventure.add_pokemon(@party[pos].dup)
				$Trainer.remove_pokemon_at_index(pos)
			else
				pbMessage(_INTL("The adventuring Party is already full!"))
			end
		else
			pbMessage(_INTL("That is your last Pokémon that can battle. You cant send it Adventuring!"))
		end
	end
	def pbMoveToParty(pos) 
		if !$Trainer.party_full?
			@party.append(@adventureparty[pos].dup)
			@adventure.remove_pokemon_at_index(pos)
		else
			pbMessage(_INTL("You have no space in your party for this Pokémon!"))
		end
	end
	def pbPerformCursorAction
		case @cursorpos
		when 14
			@off=true
		when 4
			if @adventure.items.empty?
				pbMessage(_INTL("There are no items to be collected!"))
			elsif @fastcollect
				@adventure.harvestItemsSilent
				pbMessage(_INTL("All Items Collected!"))
			else
				@adventure.harvestItems
			end
		when 9
			if GameData::Item.exists?(:POKEMONBOXLINK) && $PokemonBag.pbHasItem?(:POKEMONBOXLINK)
				pbFadeOutIn {
					$PokemonStorage.party = @adventureparty
					scene = PokemonStorageScene.new
					screen = PokemonStorageScreen.new(scene,$PokemonStorage)
					screen.pbStartScreen(0)
				}
				$PokemonStorage.party = $Trainer.party
			elsif pbConfirmMessage(_INTL("Do you want to send all adventurers to the PC?"))
				@adventure.sendEveryoneToBox
			end
		when 0,1,5,6,10,11
			partychoices
		else
			adventurechoices
		end
		pbUpdateChangingGraphics
		Graphics.update
	end
	def pbUpdateCursorPos
		positions = [[30,75],[103,89],[200,89],[265,89],[430,79],[30,137],[103,153],[200,153],[265,153],[430,180],[30,201],[103,217],[200,217],[265,217],[430,259]]
		pos = positions[@cursorpos]
		@sprites["pointer"].x = pos[0]
		@sprites["pointer"].y = pos[1]
	end
	def pbCursorValid?
		return true if [0,4,9,14].include? @cursorpos
		if @cursorpos == 1
			return @party[1]
		elsif @cursorpos == 2
			return @adventureparty[0]
		elsif @cursorpos == 3
			return @adventureparty[1]
		elsif @cursorpos == 5
			return @party[2]
		elsif @cursorpos == 6
			return @party[3]
		elsif @cursorpos == 7
			return @adventureparty[2]
		elsif @cursorpos == 8
			return @adventureparty[3]
		elsif @cursorpos == 10
			return @party[4]
		elsif @cursorpos == 11
			return @party[5]
		elsif @cursorpos == 12
			return @adventureparty[4]
		elsif @cursorpos == 13
			return @adventureparty[5]
		end
		return true
	end
	def pbPointerRight
		@cursorpos = @cursorpos+1
		@cursorpos = 0 if @cursorpos == 5
		@cursorpos = 5 if @cursorpos == 10
		@cursorpos = 10 if @cursorpos == 15
	end
	def pbPointerLeft
		@cursorpos = @cursorpos-1
		@cursorpos = 14 if @cursorpos == 9
		@cursorpos = 9 if @cursorpos == 4
		@cursorpos = 4 if @cursorpos == -1
	end
	def pbPointerDown
		@cursorpos = @cursorpos+5
		@cursorpos = @cursorpos-15 if @cursorpos > 14
	end
	def pbPointerUp
		@cursorpos = @cursorpos-5
		@cursorpos = @cursorpos+15 if @cursorpos < 0
	end
	def pbUpdateChangingGraphics
		if @adventure.items.empty?
			@sprites["apple"].visible = false
		else
			if @fastcollect
				@sprites["apple"].setBitmap("Graphics/Pictures/Pokeventures/gold_apple.png")
			else
				@sprites["apple"].setBitmap("Graphics/Pictures/Pokeventures/apple.png")
			end
			@sprites["apple"].visible = true
		end
		if @party[0]
			@sprites["icon_#{0}"].pokemon=(@party[0])
			@sprites["icon_#{0}"].visible = true
		else 
			@sprites["icon_#{0}"].pokemon=(nil)
			@sprites["icon_#{0}"].visible = false
		end
		if @party[1]
			@sprites["icon_#{1}"].pokemon=(@party[1])
			@sprites["icon_#{1}"].visible = true
		else 
			@sprites["icon_#{1}"].pokemon=(nil)
			@sprites["icon_#{1}"].visible = false
		end
		if @party[2]
			@sprites["icon_#{2}"].pokemon=(@party[2])
			@sprites["icon_#{2}"].visible = true
		else 
			@sprites["icon_#{2}"].pokemon=(nil)
			@sprites["icon_#{2}"].visible = false
		end
		if @party[3]
			@sprites["icon_#{3}"].pokemon=(@party[3])
			@sprites["icon_#{3}"].visible = true
		else 
			@sprites["icon_#{3}"].pokemon=(nil)
			@sprites["icon_#{3}"].visible = false
		end
		if @party[4]
			@sprites["icon_#{4}"].pokemon=(@party[4])
			@sprites["icon_#{4}"].visible = true
		else 
			@sprites["icon_#{4}"].pokemon=(nil)
			@sprites["icon_#{4}"].visible = false
		end
		if @party[5]
			@sprites["icon_#{5}"].pokemon=(@party[5])
			@sprites["icon_#{5}"].visible = true
		else 
			@sprites["icon_#{5}"].pokemon=(nil)
			@sprites["icon_#{5}"].visible = false
		end
		# Adventure Party
		if @adventureparty[0]
			@sprites["icon_#{6}"].pokemon=(@adventureparty[0])
			@sprites["icon_#{6}"].visible = true
		else 
			@sprites["icon_#{6}"].pokemon=(nil)
			@sprites["icon_#{6}"].visible = false
		end
		if @adventureparty[1]
			@sprites["icon_#{7}"].pokemon=(@adventureparty[1])
			@sprites["icon_#{7}"].visible = true
		else 
			@sprites["icon_#{7}"].pokemon=(nil)
			@sprites["icon_#{7}"].visible = false
		end
		if @adventureparty[2]
			@sprites["icon_#{8}"].pokemon=(@adventureparty[2])
			@sprites["icon_#{8}"].visible = true
		else 
			@sprites["icon_#{8}"].pokemon=(nil)
			@sprites["icon_#{8}"].visible = false
		end
		if @adventureparty[3]
			@sprites["icon_#{9}"].pokemon=(@adventureparty[3])
			@sprites["icon_#{9}"].visible = true
		else 
			@sprites["icon_#{9}"].pokemon=(nil)
			@sprites["icon_#{9}"].visible = false
		end
		if @adventureparty[4]
			@sprites["icon_#{10}"].pokemon=(@adventureparty[4])
			@sprites["icon_#{10}"].visible = true
		else 
			@sprites["icon_#{10}"].pokemon=(nil)
			@sprites["icon_#{10}"].visible = false
		end
		if @adventureparty[5]
			@sprites["icon_#{11}"].pokemon=(@adventureparty[5])
			@sprites["icon_#{11}"].visible = true
		else 
			@sprites["icon_#{11}"].pokemon=(nil)
			@sprites["icon_#{11}"].visible = false
		end
		
  end
	def pbStartScene(party)
		@viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
		@viewport.z = 99999
		@sprites = {}
		@party = party
		@adventure = $Adventure
		@adventureparty = @adventure.party
		@cursorpos = 0
		@off = false
		@fastcollect = false
		if defined?(ScrollingSprite)
			@sprites["background"] = IconSprite.new(0,0,@viewport)
			@sprites["background"] = ScrollingSprite.new(@viewport)
			@sprites["background"].speed = 1
			@sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokeventures/bg"))
		else
			addBackgroundPlane(@sprites,"bg","Pokeventures/bg",@viewport)
		end
		@sprites["base"] = IconSprite.new(0,0,@viewport)
		@sprites["base"].setBitmap("Graphics/Pictures/Pokeventures/fg.png")
		@sprites["base"].ox = @sprites["base"].bitmap.width/2
		@sprites["base"].oy = @sprites["base"].bitmap.height/2
		@sprites["base"].x = Graphics.width/2; @sprites["base"].y = Graphics.height/2
		pbSetSystemFont(@sprites["base"].bitmap)
		textpos = [
			[_INTL("Pokémon Adventures"), 158, 25, 0, Color.new(88,88,80), Color.new(168,184,184)],
			[_INTL("Collect Items"),344, 164, 0, Color.new(239, 239, 239), Color.new(140, 140, 140)],
			[_INTL("Send to Box"),344, 248, 0, Color.new(239, 239, 239), Color.new(140, 140, 140)],
			[_INTL("Exit"),344, 328, 0, Color.new(239, 239, 239), Color.new(140, 140, 140)]
		]
		overlay = @sprites["base"].bitmap
		pbDrawTextPositions(overlay, textpos)
		@sprites["apple"] = IconSprite.new(0,0,@viewport)
		@sprites["apple"].setBitmap("Graphics/Pictures/Pokeventures/apple.png")
		@sprites["apple"].x = 480
		@sprites["apple"].y = 120
		if @party[0]
			@sprites["icon_#{0}"] = PokemonIconSprite.new(@party[0],@viewport)
			@sprites["icon_#{0}"].x = 20
			@sprites["icon_#{0}"].y = 114
			@sprites["icon_#{0}"].visible = true
		else 
			@sprites["icon_#{0}"] = PokemonIconSprite.new(nil,@viewport)
			@sprites["icon_#{0}"].x = 20
			@sprites["icon_#{0}"].y = 114
			@sprites["icon_#{0}"].visible = false
		end
		if @party[1]
			@sprites["icon_#{1}"] = PokemonIconSprite.new(@party[1],@viewport)
			@sprites["icon_#{1}"].x = 93
			@sprites["icon_#{1}"].y = 130
			@sprites["icon_#{1}"].visible = true
		else 
			@sprites["icon_#{1}"] = PokemonIconSprite.new(nil,@viewport)
			@sprites["icon_#{1}"].x = 93
			@sprites["icon_#{1}"].y = 130
			@sprites["icon_#{1}"].visible = false
		end
		if @party[2]
			@sprites["icon_#{2}"] = PokemonIconSprite.new(@party[2],@viewport)
			@sprites["icon_#{2}"].x = 20
			@sprites["icon_#{2}"].y = 178
			@sprites["icon_#{2}"].visible = true
		else 
			@sprites["icon_#{2}"] = PokemonIconSprite.new(nil,@viewport)
			@sprites["icon_#{2}"].x = 20
			@sprites["icon_#{2}"].y = 178
			@sprites["icon_#{2}"].visible = false
		end
		if @party[3]
			@sprites["icon_#{3}"] = PokemonIconSprite.new(@party[3],@viewport)
			@sprites["icon_#{3}"].x = 93
			@sprites["icon_#{3}"].y = 194
			@sprites["icon_#{3}"].visible = true
		else 
			@sprites["icon_#{3}"] = PokemonIconSprite.new(nil,@viewport)
			@sprites["icon_#{3}"].x = 93
			@sprites["icon_#{3}"].y = 194
			@sprites["icon_#{3}"].visible = false
		end
		if @party[4]
			@sprites["icon_#{4}"] = PokemonIconSprite.new(@party[4],@viewport)
			@sprites["icon_#{4}"].x = 20
			@sprites["icon_#{4}"].y = 242
			@sprites["icon_#{4}"].visible = true
		else 
			@sprites["icon_#{4}"] = PokemonIconSprite.new(nil,@viewport)
			@sprites["icon_#{4}"].x = 20
			@sprites["icon_#{4}"].y = 242
			@sprites["icon_#{4}"].visible = false
		end
		if @party[5]
			@sprites["icon_#{5}"] = PokemonIconSprite.new(@party[5],@viewport)
			@sprites["icon_#{5}"].x = 93
			@sprites["icon_#{5}"].y = 258
			@sprites["icon_#{5}"].visible = true
		else 
			@sprites["icon_#{5}"] = PokemonIconSprite.new(nil,@viewport)
			@sprites["icon_#{5}"].x = 93
			@sprites["icon_#{5}"].y = 258
			@sprites["icon_#{5}"].visible = false
		end
		# Pokemon on Adventure
		if @adventureparty[0]
			@sprites["icon_#{6}"] = PokemonIconSprite.new(@adventureparty[0],@viewport)
			@sprites["icon_#{6}"].x = 190
			@sprites["icon_#{6}"].y = 130
			@sprites["icon_#{6}"].visible = true
		else 
			@sprites["icon_#{6}"] = PokemonIconSprite.new(nil,@viewport)
			@sprites["icon_#{6}"].x = 190
			@sprites["icon_#{6}"].y = 130
			@sprites["icon_#{6}"].visible = false
		end
		if @adventureparty[1]
			@sprites["icon_#{7}"] = PokemonIconSprite.new(@adventureparty[1],@viewport)
			@sprites["icon_#{7}"].x = 255
			@sprites["icon_#{7}"].y = 130
			@sprites["icon_#{7}"].visible = true
		else 
			@sprites["icon_#{7}"] = PokemonIconSprite.new(nil,@viewport)
			@sprites["icon_#{7}"].x = 255
			@sprites["icon_#{7}"].y = 130
			@sprites["icon_#{7}"].visible = false
		end
		if @adventureparty[2]
			@sprites["icon_#{8}"] = PokemonIconSprite.new(@adventureparty[2],@viewport)
			@sprites["icon_#{8}"].x = 190
			@sprites["icon_#{8}"].y = 194
			@sprites["icon_#{8}"].visible = true
		else 
			@sprites["icon_#{8}"] = PokemonIconSprite.new(nil,@viewport)
			@sprites["icon_#{8}"].x = 190
			@sprites["icon_#{8}"].y = 194
			@sprites["icon_#{8}"].visible = false
		end
		if @adventureparty[3]
			@sprites["icon_#{9}"] = PokemonIconSprite.new(@adventureparty[3],@viewport)
			@sprites["icon_#{9}"].x = 255
			@sprites["icon_#{9}"].y = 194
			@sprites["icon_#{9}"].visible = true
		else 
			@sprites["icon_#{9}"] = PokemonIconSprite.new(nil,@viewport)
			@sprites["icon_#{9}"].x = 255
			@sprites["icon_#{9}"].y = 194
			@sprites["icon_#{9}"].visible = false
		end
		if @adventureparty[4]
			@sprites["icon_#{10}"] = PokemonIconSprite.new(@adventureparty[4],@viewport)
			@sprites["icon_#{10}"].x = 190
			@sprites["icon_#{10}"].y = 258
			@sprites["icon_#{10}"].visible = true
		else 
			@sprites["icon_#{10}"] = PokemonIconSprite.new(nil,@viewport)
			@sprites["icon_#{10}"].x = 190
			@sprites["icon_#{10}"].y = 258
			@sprites["icon_#{10}"].visible = false
		end
		if @adventureparty[5]
			@sprites["icon_#{11}"] = PokemonIconSprite.new(@adventureparty[5],@viewport)
			@sprites["icon_#{11}"].x = 255
			@sprites["icon_#{11}"].y = 258
			@sprites["icon_#{11}"].visible = true
		else 
			@sprites["icon_#{11}"] = PokemonIconSprite.new(nil,@viewport)
			@sprites["icon_#{11}"].x = 255
			@sprites["icon_#{11}"].y = 258
			@sprites["icon_#{11}"].visible = false
		end
		pbUpdateChangingGraphics
		@sprites["pointer"] = IconSprite.new(0,0,@viewport)
		@sprites["pointer"].setBitmap("Graphics/Pictures/Pokeventures/cursor.PNG")
		@sprites["pointer"].x = 30
		@sprites["pointer"].y = 75
		pbBGMPlay(PokeventureConfig::CustomMusic)
		pbFadeInAndShow(@sprites) { pbUpdate }
	end
  
  
 
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end
  
  # Main function that controls the UI
  def pbEncounter
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK) || @off
        pbPlayCloseMenuSE
		map_id = $game_map.map_id
		map = load_data(sprintf("Data/Map%03d.rxdata",map_id))
		pbBGMPlay(map.bgm)
        break
	  elsif Input.trigger?(Input::USE)
		pbPerformCursorAction
	  elsif Input.trigger?(Input::RIGHT)
		oldpos = @cursorpos.dup
		pbPointerRight
		while (!pbCursorValid?) && !(oldpos == @cursorpos)
			pbPointerRight
		end
		if oldpos == @cursorpos
			pbPlayBuzzerSE
		else
			pbPlayCursorSE
		end
		pbUpdateCursorPos
	  elsif Input.trigger?(Input::LEFT)
		oldpos = @cursorpos.dup
		pbPointerLeft
		while (!pbCursorValid?) && !(oldpos == @cursorpos)
			pbPointerLeft
		end
		if oldpos == @cursorpos
			pbPlayBuzzerSE
		else
			pbPlayCursorSE
		end
		pbUpdateCursorPos
	  elsif Input.trigger?(Input::DOWN)
		oldpos = @cursorpos.dup
		pbPointerDown
		while (!pbCursorValid?) && !(oldpos == @cursorpos)
			pbPointerDown
		end
		if oldpos == @cursorpos
			pbPlayBuzzerSE
		else
			pbPlayCursorSE
		end
		pbUpdateCursorPos
	  elsif Input.trigger?(Input::UP)
		oldpos = @cursorpos.dup
		pbPointerUp
		while (!pbCursorValid?) && !(oldpos == @cursorpos)
			pbPointerUp
		end
		if oldpos == @cursorpos
			pbPlayBuzzerSE
		else
			pbPlayCursorSE
		end
		pbUpdateCursorPos
	  elsif Input.trigger?(Input::ACTION)
		@fastcollect = !@fastcollect
		pbUpdateChangingGraphics
      end
    end
  end
  
  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
    
end

class Adventure_Screen
  def initialize(scene,party)
    @scene = scene
	@party = party
  end

  def pbStartScreen
    @scene.pbStartScene(@party)
    @scene.pbEncounter
    @scene.pbEndScene
  end
end

class PokemonStorage
	attr_accessor	:party
	
	def party
		return @party if !@party.nil?
		return $Trainer.party
	
	end
	def party=(value)
		@party = value
	end

	def party_full?
		return @party.length >= Settings::MAX_PARTY_SIZE if !@party.nil?
		return $Trainer.party_full?
	end
end

def pbStartAdventureMenu
	pbFadeOutIn(99999) {
		scene = Adventure_Scene.new
		screen = Adventure_Screen.new(scene,$Trainer.party)
		screen.pbStartScreen
     }
end