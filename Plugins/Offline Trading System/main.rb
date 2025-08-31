#Offline trading system
#TO DO:
#as a backup, i would do some checks at the end of the trade:
#does this savefile have a pokemon with the exact same pkmnID? If so, the alien pokemon is deleted
#if the pokemon received is above the badge level, the pokemon will always disobey. No ifs or buts
#everytime a pokemon is deleted/added, the game automatically saves. The player does not confirm to save, the game forces the player to do so

class Game_Player < Game_Character
	attr_accessor :tradeID
	@tradeID = ""
end

class OfflineTradingSystem
	TRADE_FILE_PATH = "Trading/Trade.png"
	
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
		$game_player.tradeID = ""
		#7 characters makes Trader IDs matching 1 in 1 million. Good enough for me
		7.times do
			char = ELIGIBLE_CHARACTERS.sample
			$game_player.tradeID << char
		end
	end #def self.setTradingID
	
	def self.selectPkmnToTrade
		$PokemonGlobal.inTradingMenu = true
		
		pbFadeOutIn {
			scene = TradingPokemonStorageScene.new
			screen = TradingPokemonStorageScreen.new(scene, $PokemonStorage)
			screen.pbStartScreen(0)
		}
		
		#set the pkmn gamedata to game variable 1
		#game variable 65 is the 1st code the player will give to someone else - it's the pkmn they offer to trade. Needs to be stored so this can be copied over and over as needed
		#game variable 66 is the 2nd code the player will give to someone else - it's the agreed upon trade code. Needs to be stored so this can be copied over and over as needed
	end #def self.selectPkmnToTrade
	
	def self.setupTradingScreen(pkmnPlayerIsOffering)
		@tradingViewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
		@tradingViewport.z = 99999
		@sprites = {}
		#def addBackgroundPlane(sprites, planename, background, viewport = nil)
		addBackgroundPlane(@sprites, "background", "TradingImages/bg", @tradingViewport)
		@sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @tradingViewport)
		pbSetSystemFont(@sprites["overlay"].bitmap)		
		#what player is offering
		@sprites["pkmnPlayerIsOffering"] = PokemonSprite.new(@tradingViewport)
		@sprites["pkmnPlayerIsOffering"].setSpeciesBitmap(pkmnPlayerIsOffering.species, pkmnPlayerIsOffering.gender, pkmnPlayerIsOffering.form, pkmnPlayerIsOffering.shiny?)
		@sprites["pkmnPlayerIsOffering"].setOffset(PictureOrigin::CENTER)
		@sprites["pkmnPlayerIsOffering"].x = 90
		@sprites["pkmnPlayerIsOffering"].y = 134
		@sprites["pkmnPlayerIsOffering"].mirror = true
		#what player is receiving
		@sprites["pkmnPlayerIsReceiving"] = PokemonSprite.new(@tradingViewport)
		@sprites["pkmnPlayerIsReceiving"].setOffset(PictureOrigin::CENTER)
		@sprites["pkmnPlayerIsReceiving"].x = Graphics.width - 90 #- @sprites["pkmnPlayerIsOffering"].width
		@sprites["pkmnPlayerIsReceiving"].y = Graphics.height - 134 #- @sprites["pkmnPlayerIsOffering"].height
		@sprites["pkmnPlayerIsReceiving"].visible = false
	end #def self.setupTradingScreen
	
	def self.tradeMenu(pkmn)
		#create new screen for trading
		pbFadeOutIn {
			self.setupTradingScreen(pkmn)
		}
		
		#save pokemon symbol as it will be used to delete the exact pokemon later
		$game_variables[1] = pkmn
		createOfferImage(pkmn)
		
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
				case choice
				when -1
					cancel = true
					break
				when 0
					root_folder = RTP.getPath('.', "Game.ini")
					system("start explorer \"#{root_folder}\\Trading\"")
				when 1
					break
				when 2
					cancel = true
					break
				end #case choice
			end #loop do
			if !cancel
				self.readOfferImage(TRADE_FILE_PATH)
				if $game_player.tradeID == @otherPlayerTradeID
					pbMessage(_INTL("Trade.png in your Trading folder is the offer you generated."))
				else
					print "players' tradeIDs do not match each other, so we can move on"
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
		self.promptAcceptTrade
		#if yes, the game creates an agreement code which would create an image of the pokemon they send and the pokemon they receive (maybe with a handshake icon in the center?)
		#if they decline, the game asks them to replace the file and check again or cancel the trade
		
		# Recreate the Pokemon object from the data
		#exact_pokemon = Marshal.load(serialized_data)
		# Add the recreated Pokémon to the player's party
		#pbAddPokemon(exact_pokemon)
		
	end #def self.tradeMenu
	
	def self.promptAcceptTrade
		@pkmnPlayerWillReceive = nil
		@marshalDataOfPkmnOtherPlayerIsOffering = nil
		#show the pkmn they will receive
		#this variable needs to be fully decoded
		@marshalDataOfPkmnOtherPlayerIsOffering = [@pkmnOtherPlayerIsOfferingDecoded].pack('H*')
		@pkmnPlayerWillReceive = Marshal.load(@marshalDataOfPkmnOtherPlayerIsOffering)
		Console.echo_warn "player will receive this pokemon in return: #{@marshalDataOfPkmnOtherPlayerIsOffering}"
		#set bitmap of sprite for what player is receiving and reveal it
		@sprites["pkmnPlayerIsReceiving"].setSpeciesBitmap(@pkmnPlayerWillReceive.species, @pkmnPlayerWillReceive.gender, @pkmnPlayerWillReceive.form, @pkmnPlayerWillReceive.shiny?)
		@sprites["pkmnPlayerIsReceiving"].visible = true
	end #def self.promptAcceptTrade
	
	def self.createOfferImage(pkmn)
		#this method takes the marshaldata of a pkmn offered for trading and turns the marshaldata into a hexadecimal format
		#a string is created (encoded_hex_data), which is "playerTradeID_pkmnInHex" but encoded (3x as long)
		#that string is then added to an image of the pkmn, which is created in the "Trading" folder. The image is named "Trade.png"
		pbMessage(_INTL("\\wtnp[1]Generating offer..."))
		playerTradeID = $game_player.tradeID
		pokemon_to_save = pkmn
		serialized_data = Marshal.dump(pokemon_to_save)
		#Console.echo_warn serialized_data
		
		#convert marshaldata to hex
		hex_data = serialized_data.unpack("H*")[0]
		Console.echo_warn "hex data before encoding: #{hex_data}"
		encoded_hex_data = self.encode("#{playerTradeID}_#{hex_data}")
		#find box file icon of pokemon
		Console.echo_warn "generating image for #{GameData::Species.icon_filename_from_pokemon(pkmn)}"
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
		success = add_text_to_png(TRADE_FILE_PATH, encoded_hex_data)

		if success
			puts "Adding text to png successful! The image should now contain the encoded hex data."
		else
			puts "Adding text to png failed."
			print "do something to try again"
		end
	end #def self.createOfferImage

	def self.encode(data)
		Console.echo_warn data.to_s
		@encodedString = ""
		data.to_s.each_char do |char|
			#@encodedString
			#if key exists named after the character, add the key's value to @encodedString and move on
			#else (key does not exist named after the character), so add the character to @encodedString and move on
			if ENCODER_MAPPING.include?(char)
				keyValue = ENCODER_MAPPING[char]
				#Console.echo_warn "#{char} will be encoded to #{keyValue}"
				@encodedString += keyValue
			else
				print "#{char} not included in encoder. Report this issue to the development team"
				return nil
			end
		end
		return @encodedString
	end #def self.encode
	
	def self.decode(data)
		Console.echo_warn data.to_s
		@decodedString = ""
		index = 0
		while index < data.length
			#puts data.slice(index, 3)
			setOfCharactersToDecode = data.slice(index, 3)
			@decodedString += ENCODER_MAPPING.key("#{setOfCharactersToDecode}")
			index += 3
		end
		#puts "decoded string is #{@decodedString}"
		return @decodedString
	end #def self.encode

	def self.saveTradeOfferBitmap(imageFilePath)
		@viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		imageFile = Sprite.new(@viewport)
		imageFile.bitmap = Bitmap.new(imageFilePath)
		bitmap = Bitmap.new(imageFile.width/2, imageFile.height) #cut off the 2nd half of the image, as we only need the first frame from the file
    
		#move the pokemon to the bitmap that will be saved to a file
		bitmap.blt(0, 0, imageFile.bitmap, Rect.new(0, 0, imageFile.width, imageFile.height))
    
		#export the bitmap to a file
		#if the filename already exists, overwrite it
		bitmap.to_file("Trading/Trade.png")
	end #def self.saveTradeOfferBitmap

	def self.readOfferImage(trade_file_path)
		# 2. Decode the data and capture the return value
		text_from_png = get_text_from_png(trade_file_path)
		if !text_from_png
			puts "Getting text from png failed."
			print "do something to try again"
		end
		
		puts "Getting text from png successful!"
		puts "Encoded hex from png: #{text_from_png}"
		arrayOfText = text_from_png.split("_")
		@otherPlayerTradeID = self.decode(arrayOfText[0])
		@pkmnOtherPlayerIsOfferingDecoded = self.decode(arrayOfText[1])
		#Console.echo_warn "other player's tradeID is #{@otherPlayerTradeID}"
		#Console.echo_warn "@pkmnOtherPlayerIsOfferingEncoded is #{@pkmnOtherPlayerIsOfferingEncoded}"
		
		Console.echo_warn "player's trade ID is '#{$game_player.tradeID}'"
		Console.echo_warn "================================================"
		Console.echo_warn "player tradeID from Trade.png is #{@otherPlayerTradeID}"
		
		#the game then extracts the text from that offer image, obtaining the encoded hex and other player's trade ID
		#the tradeID is extracted into its own variable - @otherPlayerTradeID
		#everything up to the _ in the encoded hex is deleted, and the _ is deleted too, so all that remains is the pkmn		
	end #def self.readOfferImage

end #class OfflineTradingSystem

#adds "Trade" to list of options at PC
MenuHandlers.add(:pc_menu, :offline_trade, {
  "name"      => _INTL("Trade Pokémon"),
  "order"     => 50,
  "effect"    => proc { |menu|
    OfflineTradingSystem.selectPkmnToTrade
  }
})