#Offline trading system
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
	
	def self.tradeMenu(pkmn)
		#create new screen for trading
		
		
		#save pokemon symbol as it will be used to delete the exact pokemon later
		$game_variables[1] = pkmn
		createOfferImage(pkmn)
		
		#the player then gives the offer to another player, who gives the original player THEIR offer image
		#the player replaces Trade.png in the "Trading" folder with the offer image from the other player, and then the original player proceeds in game
		self.readOfferImage(TRADE_FILE_PATH)
		##########################self.promptAcceptTrade
		
		#the game then asks the player if they wish to accept this trade (showing them the pkmn they would get and giving them the option to look at the summary screen)
		#if yes, the game creates an agreement code which would create an image of the pokemon they send and the pokemon they receive (maybe with a handshake icon in the center?)
		#if they decline, the game asks them to replace the file and check again or cancel the trade
		
		# Recreate the Pokemon object from the data
		#exact_pokemon = Marshal.load(serialized_data)
		# Add the recreated Pokémon to the player's party
		#pbAddPokemon(exact_pokemon)
		
	end #def self.tradeMenu
	
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
		
		command_list = [_INTL("Open Trade Folder"),_INTL("Check Offer"),_INTL("Cancel Trade")]
		# Main loop
		command = 0
		ready = false
		loop do
			choice = pbMessage(_INTL("Give Trade.png to the person you're trading with. Replace your Trade.png with their Trade.png."), command_list, -1, nil, command)
			case choice
			when 0
				root_folder = RTP.getPath('.', "Game.ini")
				system("start explorer \"#{root_folder}\\Trading\"")
			when 1
				ready = true
			when 2
				break
			end #case choice
		end #loop do
		if ready
			print "player chose to move on, so now we read the code again and combine 1st code and second code to create agreement"
		else
			#do nothing so we go back to PC box
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
				Console.echo_warn "#{char} will be encoded to #{keyValue}"
				@encodedString += keyValue
			else
				print "#{char} not included in encoder. Report this issue to the development team"
				return nil
			end
		end
		return @encodedString
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
		###############check the quests plugin (in IDE) to see how I split using a delimiter
		arrayOfText = text_from_png.split("_")
		@otherPlayerTradeID = arrayOfText[0]
		@pkmnOtherPlayerIsOfferingEncoded = arrayOfText[1]
		print "other player's tradeID is #{@otherPlayerTradeID}"
		Console.echo_warn "@pkmnOtherPlayerIsOfferingEncoded is #{@pkmnOtherPlayerIsOfferingEncoded}"
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