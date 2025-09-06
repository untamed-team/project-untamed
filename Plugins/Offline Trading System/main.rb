#Offline trading system
#TO DO:
#make pkmn evolve upon trading if holding specific item


class Game_Player < Game_Character
	attr_accessor :tradeID
	@tradeID = ""
end

class OfflineTradingSystem
	TRADE_FILE_PATH_PNG = "Trading/Trade.png"
	TRADE_FILE_PATH_MAZAH = "Trading/Trade.mazah"
	
	TRADING_ERROR_LOG_FILE_PATH = "Trading/ErrorLog.txt"
	
	ELIGIBLE_CHARACTERS = ["A","a","B","b","C","c","D","d","E","e","F","f","G","g","H","h","I","i","J","j","K","k","L","l","M","m","N","n","O","o","P","p","Q","q","R","r","S","s","T","t","U","u","V","v","W","w","X","x","Y","y","Z","z","1","2","3","4","5","6","7","8","9","0"]
	
	ENCODER_MAPPING = {
		"_" => "_",
		"A" => "t4m",
		"a" => "c5K",
		"B" => "3zG",
		"b" => "eY2",
		"C" => "jR0",
		"c" => "6L9",
		"D" => "8pW",
		"d" => "2iF",
		"E" => "uHk",
		"e" => "V5Q",
		"F" => "7Xo",
		"f" => "w9s",
		"G" => "M4b",
		"g" => "0Cg",
		"H" => "J7l",
		"h" => "P8f",
		"I" => "x1Z",
		"i" => "qW6",
		"J" => "1dN",
		"j" => "eX2",
		"K" => "V7r",
		"k" => "g4I",
		"L" => "L0u",
		"l" => "R6T",
		"M" => "B2M",
		"m" => "4cW",
		"N" => "d9S",
		"n" => "Yh8",
		"O" => "aF5",
		"o" => "oN3",
		"P" => "kQ0",
		"p" => "eD9",
		"Q" => "2yV",
		"q" => "f1t",
		"R" => "O5s",
		"r" => "H6u",
		"S" => "qK4",
		"s" => "P8z",
		"T" => "m7B",
		"t" => "j9W",
		"U" => "r0D",
		"u" => "Lp2",
		"V" => "Z7J",
		"v" => "c3n",
		"W" => "G4x",
		"w" => "F1i",
		"X" => "tS8",
		"x" => "uY5",
		"Y" => "B6q",
		"y" => "xJ9",
		"Z" => "D5e",
		"z" => "K4v",
		"1" => "I3g",
		"2" => "p8G",
		"3" => "X7s",
		"4" => "yN0",
		"5" => "Z1u",
		"6" => "m2a",
		"7" => "Q9j",
		"8" => "w7L",
		"9" => "o0c",
		"0" => "h6B",
	}

	def self.setTradingID
		Console.echo_warn "setting trade ID"
		$game_player.tradeID = ""
		#7 characters makes Trader IDs matching 1 in 1 million. Good enough for me
		7.times do
			char = ELIGIBLE_CHARACTERS.sample
			$game_player.tradeID << char
		end
	end #def self.setTradingID
	
	def self.selectPkmnToTrade
		self.setTradingID if $game_player.tradeID == ""
		pbFadeOutIn {
			@boxScene = TradingPokemonStorageScene.new
			@boxScreen = TradingPokemonStorageScreen.new(@boxScene, $PokemonStorage)
			@boxScreen.pbStartScreen(0)
		}
		
		#set the pkmn gamedata to game variable 1
		#game variable 65 is the 1st code the player will give to someone else - it's the pkmn they offer to trade. Needs to be stored so this can be copied over and over as needed
		#game variable 66 is the 2nd code the player will give to someone else - it's the agreed upon trade code. Needs to be stored so this can be copied over and over as needed
	end #def self.selectPkmnToTrade
	
	def self.setupTradingScreen
		@tradingViewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
		@tradingViewport.z = 99999
		@sprites = {}
		#def addBackgroundPlane(sprites, planename, background, viewport = nil)
		addBackgroundPlane(@sprites, "background", "TradingImages/bg", @tradingViewport)
		@sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @tradingViewport)
		pbSetSystemFont(@sprites["overlay"].bitmap)		
		#what player is offering
		@sprites["pkmnPlayerIsOffering"] = PokemonSprite.new(@tradingViewport)
		@sprites["pkmnPlayerIsOffering"].setSpeciesBitmap(@pkmnPlayerIsOfferingInSymbolFormat.species, @pkmnPlayerIsOfferingInSymbolFormat.gender, @pkmnPlayerIsOfferingInSymbolFormat.form, @pkmnPlayerIsOfferingInSymbolFormat.shiny?)
		@sprites["pkmnPlayerIsOffering"].setOffset(PictureOrigin::BOTTOM)
		@sprites["pkmnPlayerIsOffering"].x = 90
		@sprites["pkmnPlayerIsOffering"].y = 230
		@sprites["pkmnPlayerIsOffering"].mirror = true
		#what player is receiving
		@sprites["pkmnPlayerIsReceiving"] = PokemonSprite.new(@tradingViewport)
		@sprites["pkmnPlayerIsReceiving"].setOffset(PictureOrigin::BOTTOM)
		@sprites["pkmnPlayerIsReceiving"].x = Graphics.width - 90
		@sprites["pkmnPlayerIsReceiving"].y = 230
		@sprites["pkmnPlayerIsReceiving"].visible = false
	end #def self.setupTradingScreen
	
	def self.tradeMenu(pkmn)
		@pkmnPlayerIsOfferingInSymbolFormat = nil
		@pkmnPlayerIsOfferingInSymbolFormat = pkmn
		@errorLog = ""
		Console.echo_warn "Creating blank error log in Trading folder"
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "", "w")
		#create new screen for trading
		pbFadeOutIn {
			self.setupTradingScreen
		}
		
		#save pokemon symbol as it will be used to delete the exact pokemon later
		createOfferImage(@pkmnPlayerIsOfferingInSymbolFormat)
		
		#here is where the user will have input
		command_list = [_INTL("Open Trade Folder"),_INTL("Check Offer"),_INTL("Cancel Trade")]
		# Main loop
		command = 0
		ready = false
		validTrade = false
		cancel = false
		
		while !validTrade && !cancel
			loop do
				choice = pbMessage(_INTL("Give Trade.png to the person you're trading with. Replace your Trade.png with their Trade.png."), command_list, -1, nil, command)
				GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Give Trade.png to the person you're trading with. Replace your Trade.png with their Trade.png.\n\n", "a")
				case choice
				when -1
					if pbConfirmMessage(_INTL("Cancel trading?"))
						GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Method self.tradeMenu: Player chose pressed the back button.\n\n", "a")
						cancel = true
						break
					end
				when 0
					root_folder = RTP.getPath('.', "Game.ini")
					system("start explorer \"#{root_folder}\\Trading\"")
						GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Method self.tradeMenu: Player chose 'Open Trade Folder'\n\n", "a")
				when 1
					GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Method self.tradeMenu: Player chose 'Check Offer'\n\n", "a")
					break
				when 2
					if pbConfirmMessage(_INTL("Cancel trading?"))
						GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Method self.tradeMenu: Player chose 'Cancel Trade'\n\n", "a")
						cancel = true
						break
					end
				end #case choice
			end #loop do
			if !cancel
				self.readOfferImage(TRADE_FILE_PATH_PNG)
				if $game_player.tradeID == @otherPlayerTradeID
					pbMessage(_INTL("Trade.png in your Trading folder is the offer you generated."))
					GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Method self.tradeMenu: Trade.png in your Trading folder is the offer you generated.\n\n", "a")
				else
					validTrade = true
				end #if $game_player.tradeID == @otherPlayerTradeID
			end #if !cancel
		end #while !validTrade
		
		if cancel
			pbFadeOutIn {
				@tradingViewport.dispose
				return
			}
		end
		
		#the game then asks the player if they wish to accept this trade (showing them the pkmn they would get and giving them the option to look at the summary screen)
		self.getPkmnToTrade
		
		#here is where the user will have input
		command_list = [_INTL("<<< #{@pkmnPlayerIsOfferingInSymbolFormat.name}'s Summary"),_INTL("#{@pkmnPlayerWillReceiveInSymbolFormat.name}'s Summary >>>"),_INTL("Accept Trade"),_INTL("Cancel Trade")]
		if @pkmnPlayerWillReceiveInSymbolFormat.speciesName.include?("Failsafe")
			pbDisplay(_INTL("Warning! The Pkmn being offered cannot exist in this savefile!\\nYou may accept the trade, but the Pkmn will be deleted."))
		end
		# Main loop
		command = 0
		agreed = false
		cancel = false
		
		while !agreed && !cancel
			loop do
				choice = pbMessage(_INTL("Trade your #{@pkmnPlayerIsOfferingInSymbolFormat.name} for #{@pkmnPlayerWillReceiveInSymbolFormat.name}?"), command_list, -1, nil, command)
				case choice
				when -1
					if pbConfirmMessage(_INTL("Cancel trading?"))
						cancel = true
						break
					end
				when 0
					#summary of @pkmnPlayerIsOfferingInSymbolFormat
					pbFadeOutIn {
						scene = PokemonSummary_Scene.new
						screen = PokemonSummaryScreen.new(scene)
						screen.pbStartScreen([@pkmnPlayerIsOfferingInSymbolFormat,@pkmnPlayerWillReceiveInSymbolFormat], 0)
					}
				when 1
					#summary of @pkmnPlayerWillReceiveInSymbolFormat
					pbFadeOutIn {
						scene = PokemonSummary_Scene.new
						screen = PokemonSummaryScreen.new(scene)
						screen.pbStartScreen([@pkmnPlayerWillReceiveInSymbolFormat,@pkmnPlayerIsOfferingInSymbolFormat], 0)
					}
				when 2
					break
				when 3
					if pbConfirmMessage(_INTL("Cancel trading?"))
						cancel = true
						break
					end
				end #case choice
			end #loop do
			if !cancel
				agreed = true
			end #if !cancel
		end #while !agreed && !cancel
		
		if cancel
			pbFadeOutIn {
				@tradingViewport.dispose
				return
			}
		end
		
		#if yes, the game creates an agreement code which would create an image of the pokemon they send and the pokemon they receive
		success = self.createAgreementImage
		
		if success
			#players swap agreement images
		else
			#do something to try again?
			print "Error while encoding image. Need to try again"
		end
		
		#if they decline, the game asks them to replace the file and check again or cancel the trade - not sure this is needed. We'll see
		
		command_list = [_INTL("Open Trade Folder"),_INTL("Finalize Trade"),_INTL("Cancel Trade")]
		# Main loop
		command = 0
		finalizedTrade = false
		cancel = false
		
		while !finalizedTrade && !cancel
			loop do
				choice = pbMessage(_INTL("Give Trade.png to the person you're trading with. Replace your Trade.png with their Trade.png."), command_list, -1, nil, command)
				case choice
				when -1
					if pbConfirmMessage(_INTL("Cancel trading?"))
						GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Method self.tradeMenu: Player pressed the back button\n\n", "a")
						cancel = true
						break
					end
				when 0
					root_folder = RTP.getPath('.', "Game.ini")
					system("start explorer \"#{root_folder}\\Trading\"")
					GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Method self.tradeMenu: Player chose 'Open Trade Folder'\n\n", "a")
				when 1
					GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Method self.tradeMenu: Player chose 'Finalize Trade'\n\n", "a")
					break
				when 2
					GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Method self.tradeMenu: Player chose 'Cancel Trade'\n\n", "a")
					if pbConfirmMessage(_INTL("Cancel trading?"))
						cancel = true
						break
					end
				end #case choice
			end #loop do
			if !cancel
				#need to do several things here:
				#decode agreement string and split into array
				finalizedTrade = self.readAgreementImage
				#check that the offer can be redeemed by this player
				#check that the agreement contains the player's trade ID
			end #if !cancel
		end #while !finalizedTrade
		
		if cancel
			pbFadeOutIn {
				@tradingViewport.dispose
				return
			}
		end
		
		#when finalizedTrade is true, we'll get here
		#legality checks for invalid pokemon and invalid moves
		@pkmnPlayerWillReceiveInSymbolFormat = self.legalitychecks(@pkmnPlayerWillReceiveInSymbolFormat)
		#set obtain method to "Trade"
		@pkmnPlayerWillReceiveInSymbolFormat.obtain_method = 2
		
		if @pkmnToReplaceLocationAndIndex[0] == "party"
			$player.party[@pkmnToReplaceLocationAndIndex[1]] = @pkmnPlayerWillReceiveInSymbolFormat
		elsif @pkmnToReplaceLocationAndIndex[0] == "box"
			$PokemonStorage[@pkmnToReplaceLocationAndIndex[1], @pkmnToReplaceLocationAndIndex[2]] = @pkmnPlayerWillReceiveInSymbolFormat
		end
		
		#add to the amount of trades player has completed
		$stats.trade_count += 1
		
		######################Game.save
		pbMessage(_INTL("\\wtnp[1]Saving game..."))
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Saving game...\n\n", "a")
	
		pbFadeOutIn {
			@sprites.dispose
			@tradingViewport.dispose
			
			#evolve pkmn if needed
			evo = PokemonTrade_Scene.new
			evo.pbStartScreen(@pkmnPlayerIsOfferingInSymbolFormat, @pkmnPlayerWillReceiveInSymbolFormat, $player.name, "Other Player")
			evo.pbTrade
			evo.pbEndScreen
			@pkmnPlayerWillReceiveInSymbolFormat.obtain_method = 4
			
			@boxScene.update
			if @pkmnToReplaceLocationAndIndex[0] == "party"
				@boxScreen.pbRefreshSingle(@pkmnToReplaceLocationAndIndex[1]) 
			elsif @pkmnToReplaceLocationAndIndex[0] == "box"
				@boxScreen.pbRefreshSingle(@pkmnToReplaceLocationAndIndex[2]) 
			end
		}
	
	end #def self.tradeMenu
	
	def self.getPkmnToTrade
		@pkmnPlayerWillReceiveInSymbolFormat = nil
		@pkmnPlayerWillReceiveInMarshaldataFormat = nil
		#show the pkmn they will receive
		#this variable needs to be fully decoded
		@pkmnPlayerWillReceiveInMarshaldataFormat = [@pkmnPlayerWillReceiveInHexFormat].pack('H*')
		@pkmnPlayerWillReceiveInSymbolFormat = Marshal.load(@pkmnPlayerWillReceiveInMarshaldataFormat)
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "player will receive this pokemon in return: #{@pkmnPlayerWillReceiveInMarshaldataFormat}\n\n", "a")
		#set bitmap of sprite for what player is receiving and reveal it
		@sprites["pkmnPlayerIsReceiving"].setSpeciesBitmap(@pkmnPlayerWillReceiveInSymbolFormat.species, @pkmnPlayerWillReceiveInSymbolFormat.gender, @pkmnPlayerWillReceiveInSymbolFormat.form, @pkmnPlayerWillReceiveInSymbolFormat.shiny?)
		@sprites["pkmnPlayerIsReceiving"].visible = true
	end #def self.getPkmnToTrade
	
	def self.createAgreementImage
		pbMessage(_INTL("\\wtnp[1]Generating agreement..."))
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Generating agreement image...\n\n", "a")
		playerTradeID = $game_player.tradeID
		serialized_data_for_pkmn_player_is_offering = Marshal.dump(@pkmnPlayerIsOfferingInSymbolFormat)
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "serialized_data_for_pkmn_player_is_offering is #{serialized_data_for_pkmn_player_is_offering}\n\n", "a")
		otherPlayerTradeID = @otherPlayerTradeID
		serialized_data_for_pkmn_player_is_receiving = Marshal.dump(@pkmnPlayerWillReceiveInSymbolFormat)
		
		#convert marshaldata to hex
		hex_data_for_pkmn_player_is_offering = serialized_data_for_pkmn_player_is_offering.unpack("H*")[0]
		@pkmnPlayerIsOfferingInHexFormat = hex_data_for_pkmn_player_is_offering
		encoded_hex_data_for_pkmn_player_is_offering = self.encode("#{playerTradeID}_#{hex_data_for_pkmn_player_is_offering}")
		
		hex_data_for_pkmn_player_is_receiving = serialized_data_for_pkmn_player_is_receiving.unpack("H*")[0]
		encoded_hex_data_for_pkmn_player_is_receiving = self.encode("#{otherPlayerTradeID}_#{hex_data_for_pkmn_player_is_receiving}")
		
		entireEncodedAgreementCode = "#{encoded_hex_data_for_pkmn_player_is_offering}_#{encoded_hex_data_for_pkmn_player_is_receiving}"
		
		#find box file icon of pokemon player is offering
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "generating image for #{GameData::Species.icon_filename_from_pokemon(@pkmnPlayerIsOfferingInSymbolFormat)}\n\n", "a")
		boxFileIconPath_for_pkmn_player_is_offering = GameData::Species.icon_filename_from_pokemon(@pkmnPlayerIsOfferingInSymbolFormat)
		
		if !File.exist?(boxFileIconPath_for_pkmn_player_is_offering)
			print "#{@pkmnPlayerIsOfferingInSymbolFormat.species} has no box icon. Report this to developers"
			return nil
		end
		
		#find box file icon of pokemon player is receiving
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "generating image for #{GameData::Species.icon_filename_from_pokemon(@pkmnPlayerWillReceiveInSymbolFormat)}\n\n", "a")
		boxFileIconPath_for_pkmn_player_is_receiving = GameData::Species.icon_filename_from_pokemon(@pkmnPlayerWillReceiveInSymbolFormat)

		if !File.exist?(boxFileIconPath_for_pkmn_player_is_receiving)
			print "#{@pkmnPlayerWillReceiveInSymbolFormat} has no box icon. Report this to developers"
			return nil
		end
		
		#save the pokemons' box icon to the Trading folder
		self.saveTradeAgreementBitmap(boxFileIconPath_for_pkmn_player_is_offering, boxFileIconPath_for_pkmn_player_is_receiving)
		
		#hide hex data in image metadata
		# Make sure to define your hex data and file path first
		# 1. Encode the data
		success = add_text_to_png(TRADE_FILE_PATH_PNG, entireEncodedAgreementCode)

		if success
			GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Adding text to png successful! The image should now contain the encoded hex data.\n\n", "a")
			return true
		else
			GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Adding text to png failed.\n\n", "a")
			print "do something to try again"
			return false
		end
	end #def self.createAgreementImage
	
	def self.createOfferImage(pkmn)
		#this method takes the marshaldata of a pkmn offered for trading and turns the marshaldata into a hexadecimal format
		#a string is created (encoded_hex_data), which is "playerTradeID_pkmnInHex" but encoded (3x as long)
		#that string is then added to an image of the pkmn, which is created in the "Trading" folder. The image is named "Trade.png"
		pbMessage(_INTL("\\wtnp[1]Generating offer..."))
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Generating offer image...\n\n", "a")
		playerTradeID = $game_player.tradeID
		pokemon_to_save = pkmn
		serialized_data = Marshal.dump(pokemon_to_save)
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "serialized_data is #{serialized_data}\n\n", "a")
		
		#convert marshaldata to hex
		hex_data = serialized_data.unpack("H*")[0]
		@pkmnPlayerWillReceiveInHexFormat = hex_data
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "hex data of the pokemon you are offering before encoding: #{hex_data}\n\n", "a")
		encoded_hex_data = self.encode("#{playerTradeID}_#{hex_data}")
		#find box file icon of pokemon
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "generating image for the pokemon you are offering: #{GameData::Species.icon_filename_from_pokemon(pkmn)}\n\n", "a")
		boxFileIconPath = GameData::Species.icon_filename_from_pokemon(pkmn)
		#copy the box sprite of the pkmn to the Trading folder
		if !File.exist?(boxFileIconPath)
			print "This pokemon has no box icon. Report this to developers"
			return nil
		end
		
		#save the pokemon's box icon to the Trading folder
		self.saveTradeOfferBitmap(boxFileIconPath)
		
		#hide hex data in image metadata
		# Make sure to define your hex data and file path first
		# 1. Encode the data
		success = add_text_to_png(TRADE_FILE_PATH_PNG, encoded_hex_data)

		if success
			GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Adding text to your png was successful! The image should now contain the encoded hex data.\n\n", "a")
		else
			GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Adding text to png failed.\n\n", "a")
			print "do something to try again"
		end
	end #def self.createOfferImage

	def self.encode(data)
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "data.to_s is #{data.to_s}\n\n", "a")
		@encodedString = ""
		data.to_s.each_char do |char|
			#@encodedString
			#if key exists named after the character, add the key's value to @encodedString and move on
			#else (key does not exist named after the character), so add the character to @encodedString and move on
			if ENCODER_MAPPING.include?(char)
				keyValue = ENCODER_MAPPING[char]
				#GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "#{char} will be encoded to #{keyValue}\n\n", "a")
				@encodedString += keyValue
			else
				print "#{char} not included in encoder. Report this issue to the development team"
				return nil
			end
		end
		return @encodedString
	end #def self.encode
	
	def self.decode(data)
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "data.to_s is #{data.to_s}\n\n", "a")
		@decodedString = ""
		index = 0
		while index < data.length
			#GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "data.slice(index, 3) is #{data.slice(index, 3)}\n\n", "a")
			setOfCharactersToDecode = data.slice(index, 3)
			@decodedString += ENCODER_MAPPING.key("#{setOfCharactersToDecode}")
			index += 3
		end
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "decoded string is #{@decodedString}\n\n", "a")
		return @decodedString
	end #def self.encode

	def self.saveTradeOfferBitmap(imageFilePath)
		@bitmapViewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		imageFile = Sprite.new(@bitmapViewport)
		imageFile.bitmap = Bitmap.new(imageFilePath)
		bitmap = Bitmap.new(imageFile.width/2, imageFile.height) #cut off the 2nd half of the image, as we only need the first frame from the file
    
		#move the pokemon to the bitmap that will be saved to a file
		bitmap.blt(0, 0, imageFile.bitmap, Rect.new(0, 0, imageFile.width, imageFile.height))
    
		#export the bitmap to a file
		#if the filename already exists, overwrite it
		bitmap.to_file("Trading/Trade.png")
		@bitmapViewport.dispose
	end #def self.saveTradeOfferBitmap

	def self.saveTradeAgreementBitmap(imageFilePath_pkmn_player_is_offering, imageFilePath_pkmn_player_is_receiving)
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "creating agreement image for trading #{@pkmnPlayerIsOfferingInSymbolFormat.species} and #{@pkmnPlayerWillReceiveInSymbolFormat.species}\n\n", "a")
		@bitmapViewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		@bitmapViewport.z = 99999
		
		#########################
		#FIRST THIRD OF IMAGE
		#########################
		#pkmn1 = Sprite.new(@bitmapViewport)
		pkmn1Bitmap = Bitmap.new(imageFilePath_pkmn_player_is_offering)
		mirroredIcon = pkmn1Bitmap.mirror
		pkmn1 = Sprite.new(@bitmapViewport)
		pkmn1.bitmap = mirroredIcon
		
		bitmap = Bitmap.new((pkmn1.width/2)*3, pkmn1.height)
		#move the pokemon player is offering to the bitmap that will be saved to a file
		bitmap.blt(0, 0, pkmn1.bitmap, Rect.new(0, 0, pkmn1.width/2, pkmn1.height))
		
		#########################
		#SECOND THIRD OF IMAGE
		#########################
		agreementIcon = Sprite.new(@bitmapViewport)
		agreementIcon.bitmap = Bitmap.new("Graphics/Pictures/TradingImages/agreementIcon.png")
		#move the pokemon player is receiving to the bitmap that will be saved to a file
		bitmap.blt((bitmap.width/2)-(agreementIcon.width/2), (bitmap.height/2)-(agreementIcon.height/2), agreementIcon.bitmap, Rect.new(0, 0, agreementIcon.width, agreementIcon.height))
		
		#########################
		#THIRD THIRD OF IMAGE
		#########################
		pkmn2 = Sprite.new(@bitmapViewport)
		pkmn2.bitmap = Bitmap.new(imageFilePath_pkmn_player_is_receiving)
		#move the pokemon player is receiving to the bitmap that will be saved to a file
		bitmap.blt(bitmap.width-(pkmn2.width/2), 0, pkmn2.bitmap, Rect.new(0, 0, pkmn2.width/2, pkmn2.height))
    
		#export the bitmap to a file
		#if the filename already exists, overwrite it
		bitmap.to_file("Trading/Trade.png")
		@bitmapViewport.dispose
	end #def self.saveTradeOfferBitmap

	def self.readOfferImage(imagePath)
		
		#get .mazah file and change to .png
		if File.exist?(OfflineTradingSystem::TRADE_FILE_PATH_MAZAH)
			GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "Renaming .mazah file to .png file...\n\n", "a")
			# Rename the file
			File.rename(OfflineTradingSystem::TRADE_FILE_PATH_MAZAH, OfflineTradingSystem::TRADE_FILE_PATH_PNG)
		else
			GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "No .mazah file found to rename to .png file...\n\n", "a")
		end
		
		# 2. Decode the data and capture the return value
		text_from_png = get_text_from_png(imagePath)
		if !text_from_png
			GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Getting text from png failed.\n\n", "a")
			GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "text_from_png is '#{text_from_png}'\n\n", "a")
			print "do something to try again"
		else
		
			GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Getting text from png successful!\n\n", "a")
			GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Encoded hex from png: #{text_from_png}\n\n", "a")
			arrayOfText = text_from_png.split("_")
			@otherPlayerTradeID = self.decode(arrayOfText[0])
			@pkmnPlayerWillReceiveInHexFormat = self.decode(arrayOfText[1])
			GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "other player's tradeID is #{@otherPlayerTradeID}\n\n", "a")
		
			GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "player's trade ID is '#{$game_player.tradeID}'\n\n", "a")
			GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "================================================\n\n", "a")
			GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "player tradeID from Trade.png is #{@otherPlayerTradeID}\n\n", "a")
		
			#the game then extracts the text from that offer image, obtaining the encoded hex and other player's trade ID
			#the tradeID is extracted into its own variable - @otherPlayerTradeID
			#everything up to the _ in the encoded hex is deleted, and the _ is deleted too, so all that remains is the pkmn		
		end #if !text_from_png
		
		#get .png file and change to .mazah
		if File.exist?(OfflineTradingSystem::TRADE_FILE_PATH_PNG)
			GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "Renaming .png file to .mazah file...\n\n", "a")
			# Rename the file
			File.rename(OfflineTradingSystem::TRADE_FILE_PATH_PNG, OfflineTradingSystem::TRADE_FILE_PATH_MAZAH)
		else
			GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "No .png file found to rename to .mazah file...\n\n", "a")
		end	
	end #def self.readOfferImage

	def self.readAgreementImage
		@pkmnToReplaceLocationAndIndex = []
		success = false
		
		#get .mazah file and change to .png
		if File.exist?(OfflineTradingSystem::TRADE_FILE_PATH_MAZAH)
			GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "Renaming .mazah file to .png file...\n\n", "a")
			# Rename the file
			File.rename(OfflineTradingSystem::TRADE_FILE_PATH_MAZAH, OfflineTradingSystem::TRADE_FILE_PATH_PNG)
		else
			GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "No .mazah file found to rename to .png file...\n\n", "a")
		end
		
		# 2. Decode the data and capture the return value
		text_from_png = get_text_from_png(TRADE_FILE_PATH_PNG)
		if !text_from_png
			GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Getting text from png failed.\n\n", "a")
			print "do something to try again"
		end
		
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Getting text from png successful!\n\n", "a")
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Encoded hex from png: #{text_from_png}\n\n", "a")
		arrayOfText = text_from_png.split("_")
		decodedElement0 = self.decode(arrayOfText[0])
		decodedElement1 = self.decode(arrayOfText[1])
		decodedElement2 = self.decode(arrayOfText[2])
		decodedElement3 = self.decode(arrayOfText[3])
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "player's tradeID is #{$game_player.tradeID}, other player's ID is #{@otherPlayerTradeID}\n\n", "a")
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "========================\n\n", "a")
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "#{decodedElement0}\n\n", "a")
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "========================\n\n", "a")
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "#{[decodedElement1].pack('H*')}\n\n", "a")
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "========================\n\n", "a")
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "#{decodedElement2}\n\n", "a")
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "========================\n\n", "a")
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "#{[decodedElement3].pack('H*')}\n\n", "a")
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "========================\n\n", "a")
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "@pkmnPlayerWillReceiveInHexFormat is #{@pkmnPlayerWillReceiveInHexFormat}\n\n", "a")
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "========================\n\n", "a")
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "@pkmnPlayerIsOfferingInHexFormat is #{@pkmnPlayerIsOfferingInHexFormat}\n\n", "a")
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "========================\n\n", "a")
		
		tradeIDOfPersonPlayerIsTradingWith = decodedElement0
		pkmnOtherTrainerIsGivingToPlayer = decodedElement1
		tradeIDOfPlayer = decodedElement2
		pkmnPlayerIsGivingToOtherPlayer = decodedElement3
		
		foundInParty = false
		foundInBox = false
		if $player.party.include?(@pkmnPlayerIsOfferingInSymbolFormat)
			foundInParty = true
			@pkmnToReplaceLocationAndIndex = ["party", $player.party.index(@pkmnPlayerIsOfferingInSymbolFormat)]
		else
			for i in 0...$PokemonStorage.maxBoxes
				for j in 0...$PokemonStorage.maxPokemon(i)
					pkmn = $PokemonStorage[i, j]
					if pkmn && pkmn == @pkmnPlayerIsOfferingInSymbolFormat
						foundInBox = true
						@pkmnToReplaceLocationAndIndex = ["box", i, j]
						break
					end
				end
				break if foundInBox
			end #for i in 0...$PokemonStorage.maxBoxes
		end #if $player.party.include?(@pkmnPlayerIsOfferingInSymbolFormat)
		
		if tradeIDOfPersonPlayerIsTradingWith == $game_player.tradeID
			pbMessage(_INTL("Trade.png in your Trading folder is the agreement you generated."))
			GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Trade.png in your Trading folder is the agreement you generated.\n\n", "a")
		elsif tradeIDOfPlayer != $game_player.tradeID #player tries to redeem a trade where tradeIDOfPlayer is not equal to their trade ID
			pbMessage(_INTL("Trade ID of other player has changed. Trade is invalid."))
			GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Trade ID of other player has changed. Trade is invalid.\n\n", "a")
		elsif pkmnOtherTrainerIsGivingToPlayer != @pkmnPlayerWillReceiveInHexFormat
			pbMessage(_INTL("The Pokémon you are receiving is not what you agreed upon."))
			GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Error: pkmnOtherTrainerIsGivingToPlayer != @pkmnPlayerWillReceiveInHexFormat\n\n", "a")
		elsif pkmnPlayerIsGivingToOtherPlayer != @pkmnPlayerIsOfferingInHexFormat
			pbMessage(_INTL("The Pokémon you are giving to the other player is not what they agreed upon."))
			GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Error: pkmnPlayerIsGivingToOtherPlayer != @pkmnPlayerIsOfferingInHexFormat\n\n", "a")
		elsif !foundInParty && !foundInBox
			pbMessage(_INTL("You no longer have the Pokémon to finalize this trade."))
			GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "You no longer have the Pokémon to finalize this trade.\n\n", "a")
		else
			#valid trade
			success = true
		end
		
		#get .png file and change to .mazah
		if File.exist?(OfflineTradingSystem::TRADE_FILE_PATH_PNG)
			GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "Renaming .png file to .mazah file...\n\n", "a")
			# Rename the file
			File.rename(OfflineTradingSystem::TRADE_FILE_PATH_PNG, OfflineTradingSystem::TRADE_FILE_PATH_MAZAH)
		else
			GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "No .png file found to rename to .mazah file...\n\n", "a")
		end
			
		return success
	end #def self.readAgreementImage

	def self.legalitychecks(pkmn)
		pkmn.clear_first_moves
		if pkmn.speciesName.include?("Failsafe")
			pkmn.species = :DELETED_PKMN
			pkmn.ability_index = nil
			pkmn.ability = nil
			pkmn.reset_moves
			pkmn.calc_stats
		end
		egglist = pkmn.species_data.get_egg_moves
		pkmn.moves.each_with_index do |move, i|
			if !pkmn.compatible_with_move?(move.id) && !egglist.include?(move.id)
				pkmn.forget_move_at_index(i)
				pkmn.learn_move(:REST) unless pkmn.hasMove?(:REST)
			end
		end
		pkmn.obtain_method = 4
		return pkmn
	end
end #class OfflineTradingSystem

#adds "Trade" to list of options at PC
MenuHandlers.add(:pc_menu, :offline_trade, {
  "name"      => _INTL("Trade Pokémon"),
  "order"     => 50,
  "effect"    => proc { |menu|
    OfflineTradingSystem.selectPkmnToTrade
  }
})