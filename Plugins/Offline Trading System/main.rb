#Offline trading system
#TO DO:
# replace '######################' with '' to decomment stuff

class Game_Player < Game_Character
	attr_accessor :tradeID
	@tradeID = ""
end

class OfflineTradingSystem
	TRADE_FILE_PATH = "Trading/Trade.png"
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
		#save pokemon symbol as it will be used to delete the exact pokemon later
		@pkmnPlayerIsOfferingInSymbolFormat = nil
		@pkmnPlayerIsOfferingInSymbolFormat = pkmn
		@pkmnPlayerIsOfferingSpeciesUppercase = pkmn.species.upcase
		
		Console.echo_warn "Emptying Trading folder..."
		files = Dir.glob(File.join("Trading", '*')).select { |f| File.file?(f) }

		# Iterate through the list and delete each file.
		files.each do |file|
		  File.delete(file)
		end
			
		Console.echo_warn "Creating blank error log in Trading folder"
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "", "w")
		#create new screen for trading
		pbFadeOutIn {
			self.setupTradingScreen
		}

		createOfferFile(@pkmnPlayerIsOfferingInSymbolFormat)
		
		#here is where the user will have input
		command_list = [_INTL("Open Trading Folder"),_INTL("Check Offer"),_INTL("Cancel Trade")]
		# Main loop
		command = 0
		ready = false
		validTrade = false
		cancel = false
		
		while !validTrade && !cancel
			loop do
				choice = pbMessage(_INTL("Give 'Offering #{@pkmnPlayerIsOfferingSpeciesUppercase}.mazah' to the person you're trading with. Download their Offering .mazah file to your Trading folder, then choose 'Check Offer'."), command_list, -1, nil, command)
				GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Give 'Offering #{@pkmnPlayerIsOfferingSpeciesUppercase}'.mazah to the person you're trading with. Download their Offering .mazah file to your Trading folder, then choose 'Check Offer'.\n\n", "a")
				case choice
				when -1
					if pbConfirmMessage(_INTL("Cancel trading?"))
						GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Method self.tradeMenu: Player pressed the back button.\n\n", "a")
						cancel = true
						break
					end
				when 0
					root_folder = RTP.getPath('.', "Game.ini")
					system("start explorer \"#{root_folder}\\Trading\"")
						GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Method self.tradeMenu: Player chose 'Open Trading Folder'\n\n", "a")
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
				validTrade = self.readOfferFile
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
		command_list = [_INTL("<icon=arrow_left> #{@pkmnPlayerIsOfferingInSymbolFormat.name}'s Summary"),_INTL("#{@pkmnPlayerWillReceiveInSymbolFormat.name}'s Summary <icon=arrow_right>"),_INTL("Accept Trade"),_INTL("Cancel Trade")]
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
		self.createAgreementFile

		#if they decline, the game asks them to replace the file and check again or cancel the trade - not sure this is needed. We'll see		
		command_list = [_INTL("Open Trade Folder"),_INTL("Finalize Trade"),_INTL("Cancel Trade")]
		# Main loop
		command = 0
		finalizedTrade = false
		cancel = false
		
		while !finalizedTrade && !cancel
			loop do
				choice = pbMessage(_INTL("Give 'Agreement - my #{@pkmnPlayerIsOfferingSpeciesUppercase} for your #{@pkmnPlayerWillReceiveSpeciesUppercase}.mazah' to the person you're trading with. Download their Agreement .mazah file to your Trading folder, then choose 'Finalize Trade' if you agree to the trade."), command_list, -1, nil, command)
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
				finalizedTrade = self.readAgreementFile
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
			@pkmnPlayerWillReceiveInSymbolFormat.obtain_method = 4 #fateful encounter
			
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
		@pkmnPlayerWillReceiveSpeciesUppercase = @pkmnPlayerWillReceiveInSymbolFormat.species.upcase
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "player will receive this pokemon in return: #{@pkmnPlayerWillReceiveInMarshaldataFormat}\n\n", "a")
		#set bitmap of sprite for what player is receiving and reveal it
		@sprites["pkmnPlayerIsReceiving"].setSpeciesBitmap(@pkmnPlayerWillReceiveInSymbolFormat.species, @pkmnPlayerWillReceiveInSymbolFormat.gender, @pkmnPlayerWillReceiveInSymbolFormat.form, @pkmnPlayerWillReceiveInSymbolFormat.shiny?)
		@sprites["pkmnPlayerIsReceiving"].visible = true
	end #def self.getPkmnToTrade
	
	def self.createAgreementFile
		pbMessage(_INTL("\\wtnp[1]Generating agreement..."))
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Generating agreement file 'Agreement - my #{@pkmnPlayerIsOfferingSpeciesUppercase} for your #{@pkmnPlayerWillReceiveSpeciesUppercase}.mazah'...\n\n", "a")
		playerTradeID = $game_player.tradeID
		serialized_data_for_pkmn_player_is_offering = Marshal.dump(@pkmnPlayerIsOfferingInSymbolFormat)
		
		serialized_data_for_pkmn_player_is_receiving = Marshal.dump(@pkmnPlayerWillReceiveInSymbolFormat)
		
		#convert marshaldata to hex
		hex_data_for_pkmn_player_is_offering = serialized_data_for_pkmn_player_is_offering.unpack("H*")[0]
		Console.echo_warn "hex_data_for_pkmn_player_is_offering is #{hex_data_for_pkmn_player_is_offering}"
		Console.echo_warn "=============================================="
		@pkmnPlayerIsOfferingInHexFormat = hex_data_for_pkmn_player_is_offering
		encoded_hex_data_for_pkmn_player_is_offering = self.encode("#{playerTradeID}_#{hex_data_for_pkmn_player_is_offering}")
		
		hex_data_for_pkmn_player_is_receiving = serialized_data_for_pkmn_player_is_receiving.unpack("H*")[0]
		Console.echo_warn "hex_data_for_pkmn_player_is_receiving is #{hex_data_for_pkmn_player_is_receiving}"
		encoded_hex_data_for_pkmn_player_is_receiving = self.encode("#{@otherPlayerTradeID}_#{hex_data_for_pkmn_player_is_receiving}")
		#GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Check Dusclops hex data decoded. hex_data_for_pkmn_player_is_receiving is #{hex_data_for_pkmn_player_is_receiving}\n\n", "a")
		
		entireEncodedAgreementCode = "#{encoded_hex_data_for_pkmn_player_is_offering}_#{encoded_hex_data_for_pkmn_player_is_receiving}"
		
		#put hex data into .mazah file
		# Make sure to define your hex data and file path first
		# 1. Encode the data
		File.open("Trading/Agreement - my #{@pkmnPlayerIsOfferingSpeciesUppercase} for your #{@pkmnPlayerWillReceiveSpeciesUppercase}.mazah", "w") do |file|
			# 'file.write' writes the string content to the file.
			file.write(entireEncodedAgreementCode)
		end
	end #def self.createAgreementFile
	
	def self.createOfferFile(pkmn)
		#this method takes the marshaldata of a pkmn offered for trading and turns the marshaldata into a hexadecimal format
		#a string is created (encoded_hex_data), which is "playerTradeID_pkmnInHex" but encoded (3x as long)
		#that string is then added to an image of the pkmn, which is created in the "Trading" folder. The image is named "Trade.png"
		pbMessage(_INTL("\\wtnp[1]Generating offer..."))
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Generating 'Offering #{@pkmnPlayerIsOfferingSpeciesUppercase}.mazah'...\n\n", "a")
		playerTradeID = $game_player.tradeID
		pokemon_to_save = pkmn
		serialized_data = Marshal.dump(pokemon_to_save)
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "serialized_data for pkmn player is offering is #{serialized_data}\n\n", "a")
		
		#convert marshaldata to hex
		hex_data = serialized_data.unpack("H*")[0]
		@pkmnPlayerWillReceiveInHexFormat = hex_data
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "hex data of the pokemon player is offering before encoding: #{hex_data}\n\n", "a")
		encoded_hex_data = self.encode("#{playerTradeID}_#{hex_data}")
		
		
		#put hex data into .mazah file
		File.open("Trading/Offering #{@pkmnPlayerIsOfferingSpeciesUppercase}.mazah", "w") do |file|
			# 'file.write' writes the string content to the file.
			file.write(encoded_hex_data)
		end
	end #def self.createOfferFile

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

	def self.readOfferFile
		found_valid_offer_file = false
		#get all .mazah files in 'Trading' folder
		#iterate through those files, reading the tradeIDs of each one until it differs from the tradeID of the player
		Dir.glob("Trading/*") do |file_path|
		  # This block will execute for each file or subdirectory
		  # You can add a check to only process files if needed
		  if File.file?(file_path) && File.extname(file_path) == ".mazah"
			#do this on each file
			text_from_mazah_file = File.read(file_path)
			GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "text_from_mazah_file: #{text_from_mazah_file}\n\n", "a")
			arrayOfText = text_from_mazah_file.split("_")
			if arrayOfText.length > 2
				#if more than 2 elements in the array, what's being read is an agreement file, not an offer file
				GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Found an agreement file instead of an offer file. Skipping this file...\n\n", "a")
				next
			end
			@otherPlayerTradeID = self.decode(arrayOfText[0])
			@pkmnPlayerWillReceiveInHexFormat = self.decode(arrayOfText[1])
			GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "other player's tradeID is #{@otherPlayerTradeID}\n\n", "a")
			
			#only a valid offer if players' tradeIDs do not match
			if $game_player.tradeID != @otherPlayerTradeID
				found_valid_offer_file = true
				break
			end #if $game_player.tradeID != @otherPlayerTradeID
		  end #if File.file?(file_path) && File.extname(file_path) == ".mazah"
		end #Dir.glob("Trading/*") do |file_path|
		
		if !found_valid_offer_file
			pbMessage(_INTL("No offer file from another player found."))
			GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "No offer file from another player found.\n\n", "a")
		end #if !found_valid_offer_file
		
		return found_valid_offer_file
	end #def self.readOfferFile

	def self.readAgreementFile
		@pkmnToReplaceLocationAndIndex = []
		found_valid_agreement_file = false
		#get all .mazah files in 'Trading' folder
		#iterate through those files, reading the tradeIDs of each one until it differs from the tradeID of the player
		Dir.glob("Trading/*") do |file_path|
		  # This block will execute for each file or subdirectory
		  # You can add a check to only process files if needed
		  if File.file?(file_path) && File.extname(file_path) == ".mazah"
			GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Checking file named '#{file_path}'...\n\n", "a")
			#do this on each file
			text_from_mazah_file = File.read(file_path)
			#GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "text_from_mazah_file, which is encoded: #{text_from_mazah_file}\n\n", "a")
			arrayOfText = text_from_mazah_file.split("_")
			
			#is the file an agreement file at all?
			if arrayOfText.length <= 2
				#if less than or equal to 2 elements in the array, what's being read is an offer file, not an agreement file
				GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Found an offer file instead of an agreement file. Skipping this file...\n\n", "a")
				next
			end			

			tradeIDOfPlayerWhoGeneratedThisFile = self.decode(arrayOfText[0])
			pkmnOtherTrainerIsGivingToPlayer = self.decode(arrayOfText[1])
			tradeIDOfPlayerThisTradeIsMeantFor = self.decode(arrayOfText[2])
			pkmnPlayerIsGivingToOtherPlayer = self.decode(arrayOfText[3])
			
			#these variables come from the agreement file the player is processing, and we need to check them against the offer files from each player
			agreementFilePkmnOtherTrainerIsGivingToPlayerInSymbolFormat = Marshal.load([pkmnOtherTrainerIsGivingToPlayer].pack('H*'))
			agreementFilePkmnPlayerIsGivingToOtherPlayerInSymbolFormat = Marshal.load([pkmnPlayerIsGivingToOtherPlayer].pack('H*'))
			
			#these variables come from the offer files, and we need to check them against the agreement file the player is processing
			#@pkmnPlayerIsOfferingInSymbolFormat
			#@pkmnPlayerWillReceiveInSymbolFormat
			
			#check the player still has the pkmn they are sending to someone else
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
			
			#checking for trickery
			if $game_player.tradeID == @otherPlayerTradeID
				GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Player's TradeID and @otherPlayerTradeID match for some reason. Invalid trade.\n\n", "a")
			elsif @otherPlayerTradeID != tradeIDOfPlayerWhoGeneratedThisFile
				GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "@otherPlayerTradeID (trade ID of other player from offer file) is not the same as the trade ID of the player who generated this agreement file. Invalid trade.\n\n", "a")
			elsif $game_player.tradeID == tradeIDOfPlayerWhoGeneratedThisFile
				GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "The agreement being checked is the one generated by the player. Invalid trade.\n\n", "a")
			elsif $game_player.tradeID != tradeIDOfPlayerThisTradeIsMeantFor
				GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "The agreement being checked is not meant to be redeemed by this player. Invalid trade.\n\n", "a")
				
			elsif self.getPkmnProperties(pkmnOtherTrainerIsGivingToPlayer) != self.getPkmnProperties(@pkmnPlayerWillReceiveInSymbolFormat)
				GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "self.getPkmnProperties(pkmnOtherTrainerIsGivingToPlayer) is #{self.getPkmnProperties(pkmnOtherTrainerIsGivingToPlayer)}\n\n", "a")
				GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "self.getPkmnProperties(@pkmnPlayerWillReceiveInHexFormat) is #{self.getPkmnProperties(@pkmnPlayerWillReceiveInHexFormat)}\n\n", "a")
				GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "The pkmn the player would receive from this agreement is not what the player agreed upon. Error: pkmnOtherTrainerIsGivingToPlayer != @pkmnPlayerWillReceiveInHexFormat\n\n", "a")
				
			elsif self.getPkmnProperties(@pkmnPlayerIsOfferingInSymbolFormat) != self.getPkmnProperties(agreementFilePkmnPlayerIsGivingToOtherPlayerInSymbolFormat)
				GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "self.getPkmnProperties(@pkmnPlayerIsOfferingInSymbolFormat) is #{self.getPkmnProperties(@pkmnPlayerIsOfferingInSymbolFormat)}\n\n", "a")
				GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "self.getPkmnProperties(agreementFilePkmnPlayerIsGivingToOtherPlayerInSymbolFormat) is #{self.getPkmnProperties(agreementFilePkmnPlayerIsGivingToOtherPlayerInSymbolFormat)}\n\n", "a")
				
				GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "The Pokémon you are giving to the other player is not what the other player agreed upon. Error: pkmnPlayerIsGivingToOtherPlayer != @pkmnPlayerIsOfferingInHexFormat\n\n", "a")
				
			elsif !foundInParty && !foundInBox
				GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "You no longer have the Pokémon to finalize this trade.\n\n", "a")
			else
			
				Console.echo_warn getPkmnProperties(@pkmnPlayerIsOfferingInSymbolFormat)
				Console.echo_warn getPkmnProperties(agreementFilePkmnPlayerIsGivingToOtherPlayerInSymbolFormat)
				
				#no trickery detected, assuming valid trade
				found_valid_agreement_file = true
				break
			end #checking for trickery
		  end #if File.file?(file_path) && File.extname(file_path) == ".mazah"
		end #Dir.glob("Trading/*") do |file_path|
		
		if !found_valid_agreement_file
			pbMessage(_INTL("No valid agreement file from another player found."))
			GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "No valid agreement file from another player found. Either there is no agreement file in the Trading folder, or trickery was detected, as outlined above in this log.\n\n", "a")
		end #if !found_valid_agreement_file
		
		return found_valid_agreement_file	
	end #def self.readAgreementFile

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
		pkmn.obtain_method = 4 #fateful encounter
		return pkmn
	end
	
	def self.getPkmnProperties(pkmn)
		propertiesArray = []
		propertiesArray.push(pkmn.species)
		propertiesArray.push(pkmn.name)
		propertiesArray.push(pkmn.level)
		propertiesArray.push(pkmn.item.id)
		propertiesArray.push(pkmn.nature.id)
		propertiesArray.push(pkmn.gender)
		propertiesArray.push(pkmn.form)
		propertiesArray.push(pkmn.forced_form)
		propertiesArray.push(pkmn.time_form_set)
		propertiesArray.push(pkmn.exp)
		propertiesArray.push(pkmn.steps_to_hatch)
		propertiesArray.push(pkmn.hp)
		propertiesArray.push(pkmn.status)
		propertiesArray.push(pkmn.statusCount)
		propertiesArray.push(pkmn.shiny?)
		
		for i in pkmn.moves
			propertiesArray.push(i.id)
		end
		
		propertiesArray.push(pkmn.first_moves)
		propertiesArray.push(pkmn.ribbons)
		propertiesArray.push(pkmn.cool)
		propertiesArray.push(pkmn.beauty)
		propertiesArray.push(pkmn.cute)
		propertiesArray.push(pkmn.smart)
		propertiesArray.push(pkmn.tough)
		propertiesArray.push(pkmn.sheen)
		propertiesArray.push(pkmn.pokerus)
		propertiesArray.push(pkmn.happiness)
		propertiesArray.push(pkmn.poke_ball)
		propertiesArray.push(pkmn.markings)
		propertiesArray.push(pkmn.iv)
		propertiesArray.push(pkmn.ivMaxed)
		propertiesArray.push(pkmn.ev)
		propertiesArray.push(pkmn.totalhp)
		propertiesArray.push(pkmn.attack)
		propertiesArray.push(pkmn.defense)
		propertiesArray.push(pkmn.spatk)
		propertiesArray.push(pkmn.spdef)
		propertiesArray.push(pkmn.speed)
		propertiesArray.push(pkmn.owner.id)
		propertiesArray.push(pkmn.obtain_text)
		propertiesArray.push(pkmn.obtain_level)
		propertiesArray.push(pkmn.fused)
		propertiesArray.push(pkmn.personalID)
		propertiesArray.push(pkmn.ready_to_evolve)
		propertiesArray.push(pkmn.cannot_store)
		propertiesArray.push(pkmn.cannot_release)
		propertiesArray.push(pkmn.cannot_trade)
		propertiesArray.push(pkmn.evolution_steps)
		propertiesArray.push(pkmn.willmega)
		propertiesArray.push(pkmn.sketchMove)
		propertiesArray.push(pkmn.triedEvolving)
		propertiesArray.push(pkmn.trainerevs)
		propertiesArray.push(pkmn.ability.id)
		propertiesArray.push(pkmn.abilityMutation)
		propertiesArray.push(pkmn.pv)
		propertiesArray.push(pkmn.megaevoMutation)
		propertiesArray.push(pkmn.natureBoostAI)
		propertiesArray.push(pkmn.bossmonMutation)
		propertiesArray.push(pkmn.shiny_roll_count)
		propertiesArray.push(pkmn.amie_fullness)
		propertiesArray.push(pkmn.amie_enjoyment)
		return propertiesArray
	end #def getPkmnProperties(pkmn)	
end #class OfflineTradingSystem

#adds "Trade" to list of options at PC
MenuHandlers.add(:pc_menu, :offline_trade, {
  "name"      => _INTL("Trade Pokémon"),
  "order"     => 50,
  "effect"    => proc { |menu|
    OfflineTradingSystem.selectPkmnToTrade
  }
})