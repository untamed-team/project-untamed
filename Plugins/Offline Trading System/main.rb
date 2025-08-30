#Offline trading system
class Game_Player < Game_Character
	attr_accessor :tradeID
	@tradeID = ""
end

class OfflineTradingSystem
	ELIGIBLE_CHARACTERS = ["A","a","B","b","C","c","D","d","E","e","F","f","G","g","H","h","I","i","J","j","K","k","L","l","M","m","N","n","O","o","P","p","Q","q","R","r","S","s","T","t","U","u","V","v","W","w","X","x","Y","y","Z","z","1","2","3","4","5","6","7","8","9","0"]
	
	ENCODER_MAPPING = {
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
		#this is where the codes will be input, you'll be able to copy the code, etc.
		createOfferCode(pkmn)
	end #def self.tradeMenu
	
	def self.createOfferCode(pkmn)
		pokemon_to_save = pkmn
		serialized_data = Marshal.dump(pokemon_to_save)
		#Console.echo_warn serialized_data
		
		#convert marshaldata to hex
		hex_data = serialized_data.unpack("H*")[0]
		#self.createQR(hex_string)
		
		#hide hex data in image metadata
		# Make sure to define your hex data and file path first
		file_path = "C:/Users/Chevy/OneDrive - North Greenville University/Documents/GitHub/project-untamed/Trading/EXCADRILL.png" # Assuming this is the correct path to your image

		# 1. Encode the data
		success = encode_hex_to_png(file_path, hex_data)

		if success
			puts "Encoding successful! The image should now contain the hex data."
  
			# 2. Decode the data and capture the return value
			decoded_string = decode_hex_from_png(file_path)

			if decoded_string
				puts "Decoding successful!"
				puts "Decoded hex data: #{decoded_string}"
			else
				puts "Decoding failed."
			end
		else
			puts "Encoding failed."
		end
		
		
		
		#encode the hex from the marshaldata
		#encodedHex = self.encode(hex_data)
		#Console.echo_warn encodedHex
		#print encodedHex
		#print encodedHex.length
		
		# Recreate the Pokemon object from the data
		#exact_pokemon = Marshal.load(serialized_data)
		# Add the recreated Pokémon to the player's party
		#pbAddPokemon(exact_pokemon)
		
	end #def self.createOfferCode

	def self.encode(data)
		Console.echo_warn data.to_s
		print data.length
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

end #class OfflineTradingSystem

#adds "Trade" to list of options at PC
MenuHandlers.add(:pc_menu, :offline_trade, {
  "name"      => _INTL("Trade Pokémon"),
  "order"     => 50,
  "effect"    => proc { |menu|
    OfflineTradingSystem.selectPkmnToTrade
  }
})