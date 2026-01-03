#Offline trading system

#LAST I LEFT OFF:
#Ready for testing

#Bugs:


#TO DO:
#don't forget to uncomment ##########################################################Game.save
#should not have the option to empty cloud storage if not in Debug. This is ready for testing

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
	
	def self.selectPkmnToTrade(command)
		self.setTradingID if $game_player.tradeID == ""
		
		case command
		when 0 #start new trade
			Console.echo_warn "going into regular storage"
			storage = $PokemonStorage
			@finalizingTradeLater = false
		when 1 #finalize old trade
			#if nothing in cloud storage, say so, then do not proceed
			foundPkmn = false
			$TradeCloud.maxBoxes.times do |i|
				$TradeCloud.maxPokemon(i).times do |j|
					foundPkmn = true if !$TradeCloud[i, j].nil?
				end
			end
			if !foundPkmn
				pbMessage(_INTL("No Pokémon from unfinished trades found. This is only accessible if you send a Pokémon away for a trade and have not received a Pokémon in return for it."))
				return
			end
			
			Console.echo_warn "going into cloud storage"
			$TradeCloud.maxBoxes.times do |i|
				$TradeCloud[i].background = 11
			end
			storage = $TradeCloud
			@finalizingTradeLater = true
		when 2 #clearing cloud storage
			$TradeCloud.maxBoxes.times do |i|
				$TradeCloud.maxPokemon(i).times do |j|
					$TradeCloud[i, j] = nil
				end
			end
			pbMessage(_INTL("The storage boxes were cleared."))
		end
		
		pbFadeOutIn {
			@boxScene = TradingPokemonStorageScene.new
			@boxScreen = TradingPokemonStorageScreen.new(@boxScene, storage)
			@boxScreen.pbStartScreen(command)
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
	
	###########################################################
	# This contains the main loop
	###########################################################
	def self.tradeMenu(pkmn, offerOrFinishScreen)
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
		
		###########################################################
		# Beginning Trade from Scratch
		###########################################################
		Console.echo_warn "Creating blank error log in Trading folder"
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "", "w")
		#create new screen for trading
		pbFadeOutIn {
			self.setupTradingScreen
		}
		
		if offerOrFinishScreen == "offer"
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
			self.getPkmnToTrade #this sets many variables such as @pkmnPlayerWillReceiveInSymbolFormat, but we might not need to do this since the pkmn the player is offering now has the data of the pkmn it must be traded with in 'pkmn.canOnlyBeTradedFor'
		
			###########################################################
			# Ask Player if They Accept Trade
			###########################################################		
			#here is where the user will have input
			command_list = [_INTL("#{@pkmnPlayerIsOfferingInSymbolFormat.name}'s Summary"),_INTL("#{@pkmnPlayerWillReceiveInSymbolFormat.name}'s Summary"),_INTL("Accept Trade"),_INTL("Cancel Trade")]
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
							scene = OTSPokemonSummary_Scene.new
							screen = OTSPokemonSummaryScreen.new(scene)
							screen.pbStartScreen([@pkmnPlayerIsOfferingInSymbolFormat,@pkmnPlayerWillReceiveInSymbolFormat], 0)
						}
					when 1
						#summary of @pkmnPlayerWillReceiveInSymbolFormat
						pbFadeOutIn {
							scene = OTSPokemonSummary_Scene.new
							screen = OTSPokemonSummaryScreen.new(scene)
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
			self.createAgreementFile(offerOrFinishScreen)
			
			#if they decline, the game asks them to replace the file and check again or cancel the trade - not sure this is needed. We'll see		
			command_list = [_INTL("Open Trade Folder"),_INTL("Finalize Trade"),_INTL("Cancel Trade")]
			# Main loop
			command = 0
			finalizedTrade = false
			cancel = false
				
		else #finishing a trade from cloud storage
			self.createAgreementFile(offerOrFinishScreen)
				
			command_list = [_INTL("Open Trade Folder"),_INTL("Finalize Trade"),_INTL("Cancel Trade")]
			# Main loop
			command = 0
			finalizedTrade = false
			cancel = false
		end	
		
		###########################################################
		# Ask Player to Finalize Trade
		###########################################################
		while !finalizedTrade && !cancel
			loop do
				choice = pbMessage(_INTL("Give 'Agreement - my #{@pkmnPlayerIsOfferingSpeciesUppercase} for your #{@pkmnPlayerWillReceiveSpeciesUppercase}.mazah' to the person you're trading with. Download their Agreement .mazah file to your Trading folder, then choose 'Finalize Trade' if you agree to the trade."), command_list, -1, nil, command)
				case choice
				when -1
					if pbConfirmMessage(_INTL("Cancel trading? You can finish this trade later."))
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
					if offerOrFinishScreen == "offer"
						if pbConfirmMessage(_INTL("Cancel trading? You can finish this trade later."))
							cancel = true
							break
						end
					elsif offerOrFinishScreen == "agreement"
						if pbConfirmMessage(_INTL("Cancel trading? Your Pokémon will remain in cloud storage until the trade is finalized."))
							cancel = true
							break
						end
					end #if offerOrFinishScreen == "offer"
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
		
		#when finalizedTrade is true, we'll get here #this is afteer reading an agreement file from the other player
		#legality checks for invalid pokemon and invalid moves
		@pkmnPlayerWillReceiveInSymbolFormat = self.legalitychecks(@pkmnPlayerWillReceiveInSymbolFormat)
		
		#add to the amount of trades player has completed
		#$stats.trade_count += 1 #this is already handled in the Trade screen
		
		##########################################################Game.save
		pbMessage(_INTL("\\wtnp[1]Saving game..."))
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Saving game...\n\n", "a")
		#finalizingTradeLater = false #######need a way to check if we're finalizing the trade later, then put something in the 'receivePkmnFromOtherPlayer' method to do something different than when doing a trade from scratch
		#Console.echo_warn "@finalizingTradeLater is #{@finalizingTradeLater}"
		self.receivePkmnFromOtherPlayer(@finalizingTradeLater)

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
	
	def self.createAgreementFile(offerOrFinishScreen)
		if offerOrFinishScreen == "offer"
			pbMessage(_INTL("\\wtnp[1]Generating agreement..."))
			GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Generating agreement file 'Agreement - my #{@pkmnPlayerIsOfferingSpeciesUppercase} for your #{@pkmnPlayerWillReceiveSpeciesUppercase}.mazah'...\n\n", "a")
			playerTradeID = $game_player.tradeID
			serialized_data_for_pkmn_player_is_offering = Marshal.dump(@pkmnPlayerIsOfferingInSymbolFormat)
		
			serialized_data_for_pkmn_player_is_receiving = Marshal.dump(@pkmnPlayerWillReceiveInSymbolFormat)
		
			#convert marshaldata to hex
			hex_data_for_pkmn_player_is_offering = serialized_data_for_pkmn_player_is_offering.unpack("H*")[0]
			#Console.echo_warn "hex_data_for_pkmn_player_is_offering is #{hex_data_for_pkmn_player_is_offering}"
			#Console.echo_warn "=============================================="
			@pkmnPlayerIsOfferingInHexFormat = hex_data_for_pkmn_player_is_offering
			encoded_hex_data_for_pkmn_player_is_offering = self.encode("#{playerTradeID}_#{hex_data_for_pkmn_player_is_offering}")
		
			hex_data_for_pkmn_player_is_receiving = serialized_data_for_pkmn_player_is_receiving.unpack("H*")[0]
			#Console.echo_warn "hex_data_for_pkmn_player_is_receiving is #{hex_data_for_pkmn_player_is_receiving}"
			encoded_hex_data_for_pkmn_player_is_receiving = self.encode("#{@otherPlayerTradeID}_#{hex_data_for_pkmn_player_is_receiving}")
			#GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Check Dusclops hex data decoded. hex_data_for_pkmn_player_is_receiving is #{hex_data_for_pkmn_player_is_receiving}\n\n", "a")
		
			entireEncodedAgreementCode = "#{encoded_hex_data_for_pkmn_player_is_offering}_#{encoded_hex_data_for_pkmn_player_is_receiving}"

			self.sendPkmnToCloud(@pkmnPlayerIsOfferingInSymbolFormat)
		
			#put hex data into .mazah file
			# Make sure to define your hex data and file path first
			# 1. Encode the data
			File.open("Trading/Agreement - my #{@pkmnPlayerIsOfferingSpeciesUppercase} for your #{@pkmnPlayerWillReceiveSpeciesUppercase}.mazah", "w") do |file|
				# 'file.write' writes the string content to the file.
				file.write(entireEncodedAgreementCode)
			end
		elsif offerOrFinishScreen == "agreement"
			#set all these variables according to what pkmn.canOnlyBeTradedFor is set to
			pbMessage(_INTL("\\wtnp[1]Generating agreement..."))
			#print @pkmnPlayerIsOfferingInSymbolFormat.canOnlyBeTradedFor

			#print @pkmnPlayerIsOfferingInSymbolFormat.canOnlyBeTradedFor #[ID of player it must be traded to, pkmn it must be traded for]
			@pkmnPlayerWillReceiveInSymbolFormat = self.createDummyPkmnFromHashOfProperties(@pkmnPlayerIsOfferingInSymbolFormat.canOnlyBeTradedFor[1])
			@pkmnPlayerIsOfferingSpeciesUppercase = @pkmnPlayerIsOfferingInSymbolFormat.species.upcase
			@pkmnPlayerWillReceiveSpeciesUppercase = @pkmnPlayerWillReceiveInSymbolFormat.species.upcase
			@otherPlayerTradeID = @pkmnPlayerIsOfferingInSymbolFormat.canOnlyBeTradedFor[0]
			GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Generating agreement file 'Agreement - my #{@pkmnPlayerIsOfferingSpeciesUppercase} for your #{@pkmnPlayerWillReceiveSpeciesUppercase}.mazah'...\n\n", "a")
			playerTradeID = $game_player.tradeID
			serialized_data_for_pkmn_player_is_offering = Marshal.dump(@pkmnPlayerIsOfferingInSymbolFormat)
		
			serialized_data_for_pkmn_player_is_receiving = Marshal.dump(@pkmnPlayerWillReceiveInSymbolFormat)
		
			#convert marshaldata to hex
			hex_data_for_pkmn_player_is_offering = serialized_data_for_pkmn_player_is_offering.unpack("H*")[0]
			#Console.echo_warn "hex_data_for_pkmn_player_is_offering is #{hex_data_for_pkmn_player_is_offering}"
			#Console.echo_warn "=============================================="
			@pkmnPlayerIsOfferingInHexFormat = hex_data_for_pkmn_player_is_offering
			encoded_hex_data_for_pkmn_player_is_offering = self.encode("#{playerTradeID}_#{hex_data_for_pkmn_player_is_offering}")
		
			hex_data_for_pkmn_player_is_receiving = serialized_data_for_pkmn_player_is_receiving.unpack("H*")[0]
			#Console.echo_warn "hex_data_for_pkmn_player_is_receiving is #{hex_data_for_pkmn_player_is_receiving}"
			encoded_hex_data_for_pkmn_player_is_receiving = self.encode("#{@otherPlayerTradeID}_#{hex_data_for_pkmn_player_is_receiving}")
			#GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Check Dusclops hex data decoded. hex_data_for_pkmn_player_is_receiving is #{hex_data_for_pkmn_player_is_receiving}\n\n", "a")
		
			entireEncodedAgreementCode = "#{encoded_hex_data_for_pkmn_player_is_offering}_#{encoded_hex_data_for_pkmn_player_is_receiving}"

			#self.sendPkmnToCloud(@pkmnPlayerIsOfferingInSymbolFormat) if player is not already in the cloud storage
		
			#put hex data into .mazah file
			# Make sure to define your hex data and file path first
			# 1. Encode the data
			File.open("Trading/Agreement - my #{@pkmnPlayerIsOfferingSpeciesUppercase} for your #{@pkmnPlayerWillReceiveSpeciesUppercase}.mazah", "w") do |file|
				# 'file.write' writes the string content to the file.
				file.write(entireEncodedAgreementCode)
			end
		end
	end #def self.createAgreementFile	
	
	def self.sendPkmnToCloud(pkmn)
		@pkmnToReplaceLocationAndIndex = []
		#locate the pkmn player is sending
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

		#pkmn.canOnlyBeTradedFor is an array with 2 elements. The 1st element is the trade ID of the player sending the pkmn. The 2nd element is the pkmn's values
		pkmn.canOnlyBeTradedFor = [@otherPlayerTradeID, self.getPkmnProperties(@pkmnPlayerWillReceiveInSymbolFormat)]
		#Console.echo_warn "sending this pkmn to the cloud where it cannot be used and will wait to be traded for the following pkmn in return:"
		#Console.echo_warn "#{pkmn.canOnlyBeTradedFor}"
		#store the pkmn in the trade cloud to finish the trade later
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Method self.sendPkmnToCloud(pkmn): Running '$TradeCloud.pbStoreCaught(pkmn)'...\n\n", "a")
		$TradeCloud.pbStoreCaught(pkmn)
		
		#remove pkmn from player's storage/party
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Method self.sendPkmnToCloud(pkmn): Removing pkmn from player's party or storage...\n\n", "a")
		if @pkmnToReplaceLocationAndIndex[0] == "party"
			GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Method self.sendPkmnToCloud(pkmn): Pkmn was in player's party. Deleting pkmn at index #{@pkmnToReplaceLocationAndIndex[1]}...\n\n", "a")
			$player.party.delete_at(@pkmnToReplaceLocationAndIndex[1])
		elsif @pkmnToReplaceLocationAndIndex[0] == "box"
			GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Method self.sendPkmnToCloud(pkmn): Pkmn was in player's PC storage. Turning pkmn into 'nil' in box index #{@pkmnToReplaceLocationAndIndex[1]}, position index #{@pkmnToReplaceLocationAndIndex[2]}...\n\n", "a")
			$PokemonStorage[@pkmnToReplaceLocationAndIndex[1], @pkmnToReplaceLocationAndIndex[2]] = nil
		end
		
		##########################################################Game.save
		pbMessage(_INTL("\\wtnp[1]Saving game..."))
		GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Saving game...\n\n", "a")
		
		#show animation for sending pkmn off
		pbFadeOutIn {
			#@sprites.dispose
			#@tradingViewport.dispose
			
			evo = ModifiedPokemonTrade_Scene.new
			evo.pbStartScreenScene1(@pkmnPlayerIsOfferingInSymbolFormat, @pkmnPlayerWillReceiveInSymbolFormat, $player.name, @pkmnPlayerWillReceiveInSymbolFormat.owner.name)
			evo.pbTradeSendPkmn
			evo.pbEndScreen(true, false)
			
			@boxScene.update
			#at this point, @pkmnToReplaceLocationAndIndex[0] == "party"
			if @pkmnToReplaceLocationAndIndex[0] == "party"
				#does this command really refresh the party?
				@boxScreen.pbRefreshSingle(@pkmnToReplaceLocationAndIndex[1])
			elsif @pkmnToReplaceLocationAndIndex[0] == "box"
				@boxScreen.pbRefreshSingle(@pkmnToReplaceLocationAndIndex[2]) 
			end
		}
		
	end #def self.sendPkmnToCloud(pkmn)
	
	def self.registerInDex(pkmn, scene) # Add 'scene' parameter
		pbMessageDisplay(@sprites["msgwindow"], _INTL("#{pkmn.species}'s data was added to the Pokédex.")) { 
			scene.pbUpdate # Call on the instance
		}
		$player.pokedex.register_last_seen(pkmn)
		pbFadeOutIn {
			scene_dex = PokemonPokedexInfo_Scene.new
			screen = PokemonPokedexInfoScreen.new(scene_dex)
			screen.pbDexEntry(pkmn.species)
			scene.pbEndScreen(false) # Call on the instance
		}
	end #def self.registerInDex
	
	def self.receivePkmnFromOtherPlayer(finalizingTradeLater = false)	
		#check here if player is finalizing a trade later or finalizing without ever leaving the trade screen
		if @finalizingTradeLater
			#if finalizing trade later...

			#make pkmn being replaced be NIL
			$TradeCloud[@pkmnToReplaceLocationAndIndex[1], @pkmnToReplaceLocationAndIndex[2]] = nil
		else
			#if finalizing trade without leaving trade screen
			#for replacing the pkmn on the spot (if never left the trade menu)
			if @pkmnToReplaceLocationAndIndex[0] == "party"
				$player.party[@pkmnToReplaceLocationAndIndex[1]] = @pkmnPlayerWillReceiveInSymbolFormat
			elsif @pkmnToReplaceLocationAndIndex[0] == "box"
				$PokemonStorage[@pkmnToReplaceLocationAndIndex[1], @pkmnToReplaceLocationAndIndex[2]] = @pkmnPlayerWillReceiveInSymbolFormat
			end
			Console.echo_warn "@pkmnToReplaceLocationAndIndex[0] is #{@pkmnToReplaceLocationAndIndex[0]}"
			#remove pkmn from cloud storage after trading it away
			if !self.findPkmnInCloudStorage(@pkmnPlayerIsOfferingInSymbolFormat).nil?
				Console.echo_warn "deleting pkmn traded away from cloud storage"
				location = self.findPkmnInCloudStorage(@pkmnPlayerIsOfferingInSymbolFormat)
				Console.echo_warn "location is '#{location}'"
				box = location[0]
				slot = location[1]
				$TradeCloud[box][slot] = nil
			end
		end #if @finalizingTradeLater
		
		#register new pkmn in dex
		was_owned_before_evolution = $player.owned?(@pkmnPlayerWillReceiveInSymbolFormat.species)
		pkmnBeforeEvolution = @pkmnPlayerWillReceiveInSymbolFormat
		$player.pokedex.register(@pkmnPlayerWillReceiveInSymbolFormat)
		$player.pokedex.set_owned(@pkmnPlayerWillReceiveInSymbolFormat.species)

		#receive the pkmn
		pbFadeOutIn {
			@sprites.dispose
			@tradingViewport.dispose
			
			#evolve pkmn if needed
			evo = ModifiedPokemonTrade_Scene.new
			evo.pbStartScreenScene2(@pkmnPlayerIsOfferingInSymbolFormat, @pkmnPlayerWillReceiveInSymbolFormat, $player.name, @pkmnPlayerWillReceiveInSymbolFormat.owner.name)
			evo.pbTradeReceivePkmn

			#but before checking for evolution, register pokemon to dex if it's new
			self.registerInDex(pkmnBeforeEvolution, evo) if Settings::SHOW_NEW_SPECIES_POKEDEX_ENTRY_MORE_OFTEN && !was_owned_before_evolution && $player.has_pokedex
			
			evo.pbEndScreen(true, true)
			@pkmnPlayerWillReceiveInSymbolFormat.obtain_method = 4 #fateful encounter
			
			#mark new pkmn as seen and owned
			was_owned_after_evolution = $player.owned?(@pkmnPlayerWillReceiveInSymbolFormat.species)
			$player.pokedex.register(@pkmnPlayerWillReceiveInSymbolFormat)
			$player.pokedex.set_owned(@pkmnPlayerWillReceiveInSymbolFormat.species)
			
			#the evolution scene already registers to the dex if the species is new
			
			if @finalizingTradeLater
				#add the pkmn you receive will go into your boxes
				if $player.party_full?
					stored_box = $PokemonStorage.pbStoreCaught(@pkmnPlayerWillReceiveInSymbolFormat)
					box_name   = $PokemonStorage[stored_box].name
					pbMessage(_INTL("{1} has been sent to Box \"{2}\"!", @pkmnPlayerWillReceiveInSymbolFormat.name, box_name))
				else
					pbMessage(_INTL("#{@pkmnPlayerWillReceiveInSymbolFormat.name} has been added to your party!"))
					pbAddPokemonSilent(@pkmnPlayerWillReceiveInSymbolFormat)
				end
				@boxScene.update
				Console.echo_warn "refreshing box at location #{@pkmnToReplaceLocationAndIndex[2]}"
				@boxScreen.pbRefreshSingle(@pkmnToReplaceLocationAndIndex[2])
			else
				@boxScene.update
				if @pkmnToReplaceLocationAndIndex[0] == "party"
					#does this really refresh the party?
					@boxScreen.pbRefreshSingle(@pkmnToReplaceLocationAndIndex[1]) 
				elsif @pkmnToReplaceLocationAndIndex[0] == "box"
					Console.echo_warn "refreshing box at location #{@pkmnToReplaceLocationAndIndex[2]}"
					@boxScreen.pbRefreshSingle(@pkmnToReplaceLocationAndIndex[2]) 
				end
			end #if @finalizingTradeLater
		}
	
	end #def self.receivePkmnFromOtherPlayer
	
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
			
			agreementFilePkmnOtherTrainerIsGivingToPlayerInSerializedFormat = Marshal.dump(agreementFilePkmnOtherTrainerIsGivingToPlayerInSymbolFormat)
			agreementFilePkmnPlayerIsGivingToOtherPlayerInSerializedFormat = Marshal.dump(agreementFilePkmnPlayerIsGivingToOtherPlayerInSymbolFormat)
			
			#Console.echo_warn "agreementFilePkmnOtherTrainerIsGivingToPlayerInSerializedFormat is #{agreementFilePkmnOtherTrainerIsGivingToPlayerInSerializedFormat}"
			#Console.echo_warn "================================================================="
			#Console.echo_warn "agreementFilePkmnPlayerIsGivingToOtherPlayerInSerializedFormat is #{agreementFilePkmnPlayerIsGivingToOtherPlayerInSerializedFormat}"
			
			#these variables come from the offer files, and we need to check them against the agreement file the player is processing
			#@pkmnPlayerIsOfferingInSymbolFormat
			#@pkmnPlayerWillReceiveInSymbolFormat
			print "1@pkmnToReplaceLocationAndIndex[0] is #{@pkmnToReplaceLocationAndIndex[0]}"
			#checking for trickery
			if $game_player.tradeID == @otherPlayerTradeID
				GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "Player's TradeID and @otherPlayerTradeID match for some reason. Invalid trade.\n\n", "a")
			elsif @otherPlayerTradeID.to_s != tradeIDOfPlayerWhoGeneratedThisFile.to_s
				GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "@otherPlayerTradeID (trade ID of other player from offer file) is not the same as the trade ID of the player who generated this agreement file. Invalid trade.\n\n", "a")
			elsif $game_player.tradeID == tradeIDOfPlayerWhoGeneratedThisFile
				GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "The agreement being checked is the one generated by the player. Invalid trade.\n\n", "a")
			elsif $game_player.tradeID != tradeIDOfPlayerThisTradeIsMeantFor
				GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "The agreement being checked is not meant to be redeemed by this player. Invalid trade.\n\n", "a")
			elsif self.getPkmnProperties(agreementFilePkmnOtherTrainerIsGivingToPlayerInSymbolFormat).to_s != self.getPkmnProperties(@pkmnPlayerWillReceiveInSymbolFormat).to_s
				GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "self.getPkmnProperties(agreementFilePkmnOtherTrainerIsGivingToPlayerInSymbolFormat) is #{self.getPkmnProperties(agreementFilePkmnOtherTrainerIsGivingToPlayerInSymbolFormat)}\n\n", "a")
				GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "self.getPkmnProperties(@pkmnPlayerWillReceiveInSymbolFormat) is #{self.getPkmnProperties(@pkmnPlayerWillReceiveInSymbolFormat)}\n\n", "a")
				GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "The pkmn the player would receive from this agreement is not what the player agreed upon. Error: agreementFilePkmnOtherTrainerIsGivingToPlayerInSymbolFormat != @pkmnPlayerWillReceiveInSymbolFormat\n\n", "a")
				
			elsif self.getPkmnProperties(@pkmnPlayerIsOfferingInSymbolFormat).to_s != self.getPkmnProperties(agreementFilePkmnPlayerIsGivingToOtherPlayerInSymbolFormat).to_s
				GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "self.getPkmnProperties(@pkmnPlayerIsOfferingInSymbolFormat) is #{self.getPkmnProperties(@pkmnPlayerIsOfferingInSymbolFormat)}\n\n", "a")
				GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "self.getPkmnProperties(agreementFilePkmnPlayerIsGivingToOtherPlayerInSymbolFormat) is #{self.getPkmnProperties(agreementFilePkmnPlayerIsGivingToOtherPlayerInSymbolFormat)}\n\n", "a")
				
				GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "The Pokémon you are giving to the other player is not what the other player agreed upon. Error: pkmnPlayerIsGivingToOtherPlayer != @pkmnPlayerIsOfferingInHexFormat\n\n", "a")
			
			elsif !self.pkmnExistsInTradeCloud(self.getPkmnProperties(agreementFilePkmnPlayerIsGivingToOtherPlayerInSymbolFormat), "agreement")
				GardenUtil.pbCreateTextFile(TRADING_ERROR_LOG_FILE_PATH, "You no longer have the Pokémon to finalize this trade.\n\n", "a")
			else
				#Console.echo_warn getPkmnProperties(@pkmnPlayerIsOfferingInSymbolFormat)
				#Console.echo_warn getPkmnProperties(agreementFilePkmnPlayerIsGivingToOtherPlayerInSymbolFormat)
				
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
		print "2@pkmnToReplaceLocationAndIndex[0] is #{@pkmnToReplaceLocationAndIndex[0]}"
		return found_valid_agreement_file	
	end #def self.readAgreementFile

	#this method is responsible for overwriting @pkmnToReplaceLocationAndIndex[0] to be "box" - bug
	def self.pkmnExistsInTradeCloud(pkmnPropertiesArray, offerOrFinishScreen = "offer")
		Console.echo_warn "checking cloud storage to see if the player has #{pkmnPropertiesArray}"
		#pkmnPropertiesArray is an array of properties of the pkmn the player is giving away
		#check if a pkmn with those exact properties exists in the trade cloud storage
		exists = false
		
		$TradeCloud.maxBoxes.times do |i|
			#Console.echo_warn "checking boxes in cloud storage"
			$TradeCloud.maxPokemon(i).times do |j|
				#Console.echo_warn "checking pokemon in box #{i}"
				#Console.echo_warn "================================="
				#Console.echo_warn "checking pkmn in storage to see if it matches: #{self.getPkmnProperties($TradeCloud[i, j]).to_s}"
				if self.getPkmnProperties($TradeCloud[i, j]).to_s == pkmnPropertiesArray.to_s
					exists = true
					#Console.echo_warn "found the pkmn in the cloud"
					#if finalizing trade later, do the below
					if offerOrFinishScreen == "agreement"
						@pkmnToReplaceLocationAndIndex = ["box", i, j]
					end
					return true
				end
			end
		end
		return exists
	end #def self.pkmnExistsInTradeCloud

	def self.findPkmnInCloudStorage(pkmnInSymbolFormat)
		if self.pkmnExistsInTradeCloud(self.getPkmnProperties(pkmnInSymbolFormat))
			properties = self.getPkmnProperties(pkmnInSymbolFormat).to_s
			Console.echo_warn "method 'self.findPkmnInCloudStorage': checking cloud storage to see if the player has #{properties}"
			location = nil
			$TradeCloud.maxBoxes.times do |i|
				#Console.echo_warn "checking boxes in cloud storage"
				$TradeCloud.maxPokemon(i).times do |j|
					#Console.echo_warn "checking pokemon in box #{i}"
					#Console.echo_warn "================================="
					#Console.echo_warn "checking pkmn in storage to see if it matches: #{self.getPkmnProperties($TradeCloud[i, j]).to_s}"
					#Console.echo_warn "method 'self.findPkmnInCloudStorage': checking if pokemon in box #{i} slot #{j} is #{self.getPkmnProperties(pkmnInSymbolFormat)}"
					print "$TradeCloud[i][j] is #{$TradeCloud[i][j]}"
					Console.echo_warn "pkmn in slot box #{i} slot #{j} is #{self.getPkmnProperties($TradeCloud[i, j]).to_s}"
					#Console.echo_warn "self.getPkmnProperties(pkmnInSymbolFormat) is #{self.getPkmnProperties(pkmnInSymbolFormat)}"
					if self.getPkmnProperties($TradeCloud[i, j]).to_s == self.getPkmnProperties(pkmnInSymbolFormat).to_s
						print "match in cloud storage"
						location = [i,j]
						Console.echo_warn "found the pkmn in the cloud"
						@pkmnToReplaceLocationAndIndex = ["box", i, j]
						return location
					end
				end
			end
		else
			return location
		end
	end #def self.findPkmnInCloudStorage

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
		pkmnHash = {}
		pkmnHash[:species] = pkmn.species
		pkmnHash[:name] = pkmn.name
		pkmnHash[:level] = pkmn.level
		
		if pkmn.item.nil?
			pkmnHash[:item] = nil
		else
			pkmnHash[:item] = pkmn.item.id
		end
		
		if pkmn.nature.nil?
			pkmnHash[:nature] = nil
		else
			pkmnHash[:nature] = pkmn.nature.id
		end		
		
		pkmnHash[:gender] = pkmn.gender
		pkmnHash[:form] = pkmn.form
		pkmnHash[:forced_form] = pkmn.forced_form
		pkmnHash[:time_form_set] = pkmn.time_form_set
		pkmnHash[:exp] = pkmn.exp
		pkmnHash[:steps_to_hatch] = pkmn.steps_to_hatch
		pkmnHash[:hp] = pkmn.hp
		pkmnHash[:status] = pkmn.status
		pkmnHash[:statusCount] = pkmn.statusCount
		pkmnHash[:shiny] = pkmn.shiny?
		
		moves = []
		if pkmn.moves.length > 0
			for i in pkmn.moves
				moves.push(i.id)
			end
		else
			#moves array will remain empty
		end
		pkmnHash[:moves] = pkmn.moves
		
		pkmnHash[:first_moves] = pkmn.first_moves
		pkmnHash[:ribbons] = pkmn.ribbons
		pkmnHash[:cool] = pkmn.cool
		pkmnHash[:beauty] = pkmn.beauty
		pkmnHash[:cute] = pkmn.cute
		pkmnHash[:smart] = pkmn.smart
		pkmnHash[:tough] = pkmn.tough
		pkmnHash[:sheen] = pkmn.sheen
		pkmnHash[:pokerus] = pkmn.pokerus
		pkmnHash[:happiness] = pkmn.happiness
		pkmnHash[:poke_ball] = pkmn.poke_ball
		pkmnHash[:markings] = pkmn.markings
		pkmnHash[:iv] = pkmn.iv
		pkmnHash[:ivMaxed] = pkmn.ivMaxed
		pkmnHash[:ev] = pkmn.ev
		#pkmnHash[:totalhp] = pkmn.totalhp
		pkmnHash[:attack] = pkmn.attack
		pkmnHash[:defense] = pkmn.defense
		pkmnHash[:spatk] = pkmn.spatk
		pkmnHash[:spdef] = pkmn.spdef
		pkmnHash[:speed] = pkmn.speed
		
		if pkmn.owner.nil?
			pkmnHash[:ownerID] = 80085
			pkmnHash[:ownerName] = "Sorb"
			pkmnHash[:ownerGender] = 2
			pkmnHash[:ownerLanguage] = 2
		else
			#Owner.new(0, "", 2, 2)
			#Owner.new(ID, name, gender, language)
			pkmnHash[:ownerID] = pkmn.owner.id
			pkmnHash[:ownerName] = pkmn.owner.name
			pkmnHash[:ownerGender] = pkmn.owner.gender
			pkmnHash[:ownerLanguage] = pkmn.owner.language
		end
		
		pkmnHash[:obtain_text] = pkmn.obtain_text
		pkmnHash[:obtain_level] = pkmn.obtain_level
		pkmnHash[:fused] = pkmn.fused
		pkmnHash[:personalID] = pkmn.personalID
		pkmnHash[:ready_to_evolve] = pkmn.ready_to_evolve
		pkmnHash[:cannot_store] = pkmn.cannot_store
		pkmnHash[:cannot_release] = pkmn.cannot_release
		pkmnHash[:cannot_trade] = pkmn.cannot_trade
		pkmnHash[:evolution_steps] = pkmn.evolution_steps
		pkmnHash[:willmega] = pkmn.willmega
		pkmnHash[:sketchMove] = pkmn.sketchMove
		pkmnHash[:triedEvolving] = pkmn.triedEvolving
		pkmnHash[:trainerevs] = pkmn.trainerevs
		
		if pkmn.ability.nil?
			pkmnHash[:ability] = nil
		else
			pkmnHash[:ability] = pkmn.ability.id
		end
		
		pkmnHash[:abilityMutation] = pkmn.abilityMutation
		pkmnHash[:pv] = pkmn.pv
		pkmnHash[:megaevoMutation] = pkmn.megaevoMutation
		pkmnHash[:natureBoostAI] = pkmn.natureBoostAI
		pkmnHash[:bossmonMutation] = pkmn.bossmonMutation
		pkmnHash[:shiny_roll_count] = pkmn.shiny_roll_count
		pkmnHash[:amie_fullness] = pkmn.amie_fullness
		pkmnHash[:amie_enjoyment] = pkmn.amie_enjoyment
		
		return pkmnHash
	end #def getPkmnProperties(pkmn)
	
	def self.createDummyPkmnFromHashOfProperties(hashOfProperties)
		h = hashOfProperties
		
		pkmn = Pokemon.new(h[:species], h[:level])
		
		pkmn.name = h[:name]
		pkmn.item = h[:item]
		pkmn.nature = h[:nature]
		pkmn.gender = h[:gender]
		pkmn.form = h[:form]
		pkmn.forced_form = h[:forced_form]
		pkmn.time_form_set = h[:time_form_set]
		pkmn.exp = h[:exp]
		pkmn.steps_to_hatch = h[:steps_to_hatch]
		pkmn.hp = h[:hp]
		pkmn.status = h[:status]
		pkmn.statusCount = h[:statusCount]
		pkmn.shiny = h[:shiny]
		pkmn.moves = h[:moves]
		pkmn.first_moves = h[:first_moves]
		pkmn.ribbons = h[:ribbons]
		pkmn.cool = h[:cool]
		pkmn.beauty = h[:beauty]
		pkmn.cute = h[:cute]
		pkmn.smart = h[:smart]
		pkmn.tough = h[:tough]
		pkmn.sheen = h[:sheen]
		pkmn.pokerus = h[:pokerus]
		pkmn.happiness = h[:happiness]
		pkmn.poke_ball = h[:poke_ball]
		pkmn.markings = h[:markings]
		pkmn.iv = h[:iv]
		pkmn.ivMaxed = h[:ivMaxed]
		pkmn.ev = h[:ev]
		#pkmn.totalhp = h[:totalhp]
		#pkmn.attack = h[:attack]
		#pkmn.defense = h[:defense]
		#pkmn.spatk = h[:spatk]
		#pkmn.spdef = h[:spdef]
		#pkmn.speed = h[:speed]
		pkmn.calc_stats
		
		#Owner.new(ID, name, gender, language)
		pkmn.owner = Pokemon::Owner.new(h[:ownerID], h[:ownerName], h[:ownerGender], h[:ownerLanguage])
		
		pkmn.obtain_text = h[:obtain_text]
		pkmn.obtain_level = h[:obtain_level]
		pkmn.fused = h[:fused]
		pkmn.personalID = h[:personalID]
		pkmn.ready_to_evolve = h[:ready_to_evolve]
		pkmn.cannot_store = h[:cannot_store]
		pkmn.cannot_release = h[:cannot_release]
		pkmn.cannot_trade = h[:cannot_trade]
		pkmn.evolution_steps = h[:evolution_steps]
		pkmn.willmega = h[:willmega]
		pkmn.sketchMove = h[:sketchMove]
		pkmn.triedEvolving = h[:triedEvolving]
		pkmn.trainerevs = h[:trainerevs]
		pkmn.ability = h[:ability]
		pkmn.abilityMutation = h[:abilityMutation]
		pkmn.pv = h[:pv]
		pkmn.megaevoMutation = h[:megaevoMutation]
		pkmn.natureBoostAI = h[:natureBoostAI]
		pkmn.bossmonMutation = h[:bossmonMutation]
		pkmn.shiny_roll_count = h[:shiny_roll_count]
		pkmn.amie_fullness = h[:amie_fullness]
		pkmn.amie_enjoyment = h[:amie_enjoyment]
		
		return pkmn
	end #def self.createDummyPkmnFromHashOfProperties(arrayOfProperties)
end #class OfflineTradingSystem

#adds "Trade" to list of options at PC
MenuHandlers.add(:pc_menu, :offline_trade, {
  "name"      => _INTL("Trade Pokémon"),
  "order"     => 50,
  "effect"    => proc { |menu|
	OfflineTradingSystem.selectPkmnToTrade
  }
})

MenuHandlers.add(:pc_menu, :offline_trade, {
  "name"      => _INTL("Trade Pokémon"),
  "order"     => 50,
  "effect"    => proc { |menu|
  pbMessage(_INTL("\\se[PC access]The Trading Storage System was opened."))
    command = 0
    loop do
		if $DEBUG
			command = pbShowCommandsWithHelp(nil,
			[_INTL("Start New Trade"),
			_INTL("Finalize Old Trade"),
			_INTL("Empty Cloud Storage"),
			#_INTL("Deposit Pokémon"),
			_INTL("See ya!")],
			[_INTL("Start a new trade from scratch."),
			_INTL("Finish a trade started before."),
			_INTL("Erase unfinished trades."),
			#_INTL("Store Pokémon in your party in Boxes."),
			_INTL("Return to the previous menu.")], -1, command)
			break if command < 0 || command == 3
		else
			command = pbShowCommandsWithHelp(nil,
				[_INTL("Start New Trade"),
				_INTL("Finalize Old Trade"),
				#_INTL("Deposit Pokémon"),
				_INTL("See ya!")],
				[_INTL("Start a new trade from scratch."),
				_INTL("Finish a trade started before."),
				#_INTL("Store Pokémon in your party in Boxes."),
				_INTL("Return to the previous menu.")], -1, command)
			break if command < 0 || command == 2
		end
		OfflineTradingSystem.selectPkmnToTrade(command)
    end
    next false
  }
})