#Full transparancy, this was written by AI :)

# This script provides functions to embed and retrieve a hexadecimal string
# directly from the metadata chunks of a PNG file. This is a self-contained
# solution that does not require any external gems or command-line tools,
# making it suitable for use within a constrained Ruby environment like
# Pokémon Essentials.

# The script works by reading the PNG file's chunks and inserting a new
# 'tEXt' chunk just before the 'IEND' (Image End) chunk.

# --- Usage ---
#
# To use these functions, you can copy this code into a new file in your
# Pokémon Essentials project (e.g., a script called 'Data_Encoder').
#
# To encode a string:
#   file_path = "path/to/your/image.png"
#   hex_string = "454445584859" # The hex string you want to encode
#   success = add_text_to_png(file_path, hex_string)
#   if success
#     p "Encoding successful!"
#   else
#     p "Encoding failed."
#   end
#
# To decode a string:
#   file_path = "path/to/your/image.png"
#   decoded_string = get_text_from_png(file_path)
#   if decoded_string
#     p "Decoded string: #{decoded_string}"
#   else
#     p "Decoding failed."
#   end
#

# --- Required Libraries ---
# Note: zlib is a standard library included with Ruby.
require 'zlib'

# --- Functions ---

# Function to embed a hexadecimal string into a PNG file.
def add_text_to_png(file_path, hex_string)
	#get .mazah file and change to .png
	# The original file path
	###################original_path = "path/to/your/file.txt"

	# The new file path with the desired extension
	###################new_path = "path/to/your/file.md"

# Rename the file
###################File.rename(original_path, new_path)
	
  GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "Method add_text_to_png\n\n", "a")
  # Read the PNG file into memory.
  GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "Reading png file into memory...\n\n", "a")
  begin
    file_data = File.binread(file_path)
  rescue Errno::ENOENT
    puts "Error: File '#{file_path}' not found."
    GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "Error: File '#{file_path}' not found.\n\n", "a")
    return false
  end

  # The PNG header is always 8 bytes.
  GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "Getting png header...\n\n", "a")
  png_signature = file_data[0..7]
  GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "png_signature is #{png_signature}\n\n", "a")

  correct_png_signature_bytes = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
  unless png_signature.bytes == correct_png_signature_bytes
    puts "Error: Not a valid PNG file."
    GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "Error: Not a valid PNG file.\n\n", "a")
    return false
  end

  # Initialize a new array to hold the chunks of the new file.
  new_chunks = []
  current_position = 8

  while current_position < file_data.length
    begin
      if (file_data.length - current_position) < 8
        GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "There's not enough data left for a chunk header.\n\n", "a")
        break
      end
      
      length = file_data[current_position, 4].unpack('N')[0]
      chunk_type = file_data[current_position + 4, 4]
      
      chunk_end = current_position + 8 + length + 4
      chunk_data = file_data[current_position...chunk_end]

      # Check for the IEND chunk and insert the custom chunk before it.
      if chunk_type == 'IEND'
        GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "Found the IEND chunk, inserting custom chunk before it.\n\n", "a")
        
        # Create and insert the custom chunk.
        keyword = "HexData"
        custom_chunk_data = keyword + "\x00" + hex_string
        custom_chunk_type = 'tEXt'
        crc_data = custom_chunk_type + custom_chunk_data
        crc = Zlib::crc32(crc_data)
        new_chunk_with_crc = [custom_chunk_data.bytesize].pack('N') + custom_chunk_type + custom_chunk_data + [crc].pack('N')
        
        new_chunks << new_chunk_with_crc
        new_chunks << chunk_data # Add the IEND chunk after the new chunk
        break # We're done, exit the loop
      end

      new_chunks << chunk_data
      current_position = chunk_end
      
    rescue StandardError => e
      GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "The file is likely malformed. Error: #{e.message}\n\n", "a")
      break
    end
  end

  # Combine all the chunks with the PNG signature.
  new_file_data = png_signature + new_chunks.join

  # Write the new file data, overwriting the original file.
  GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "Overwriting original file...\n\n", "a")
  begin
    File.open(file_path, 'wb') do |f|
      f.write(new_file_data)
    end
    return true
  rescue StandardError => e
    puts "Error writing to file: #{e.message}"
    GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "Error writing to file: #{e.message}\n\n", "a")
    return false
  end
end


# Function to retrieve a hexadecimal string from a PNG file.
def get_text_from_png(file_path)

	GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "Trying new version of method 'get_text_from_png'\n\n", "a")
	
  GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "Method get_text_from_png\n\n", "a")
  # Read the PNG file into memory.
  begin
    file_data = File.binread(file_path)
  rescue Errno::ENOENT
    puts "Error: File '#{file_path}' not found."
    GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "Error: File '#{file_path}' not found.\n\n", "a")
    return nil
  end

  # Start after the 8-byte PNG header.
  current_position = 8
  
  while current_position < file_data.length
    begin
      # Ensure there are enough bytes to read the next chunk header.
      if (file_data.length - current_position) < 8
        GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "There are not enough bytes to read the next chunk header.\n\n", "a")
        break
      end

      # Read the chunk's length (4 bytes).
      length = file_data[current_position, 4].unpack('N')[0]
      GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "length is #{length}\n\n", "a")
      
      # Read the chunk's type (4 bytes).
      chunk_type = file_data[current_position + 4, 4]
      GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "chunk_type is #{chunk_type}\n\n", "a")
      
      # DEBUG: Print the chunk type and length.
      puts "Processing chunk: Type=#{chunk_type}, Length=#{length}"
      GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "Processing chunk: Type=#{chunk_type}, Length=#{length}\n\n", "a")
      
      # If we find our custom 'tEXt' chunk, read the data.
      if chunk_type == 'tEXt'
        GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "chunk_type is 'tEXt'\n\n", "a")
        
        # The data starts 8 bytes after the length.
        chunk_data_start = current_position + 8
        
        # Read the data based on the length.
        chunk_data = file_data[chunk_data_start, length]
        
        # The data format is 'keyword' + null byte + 'text'.
        # We need to find the null byte to separate them.
        null_index = chunk_data.index("\x00")
        
        if null_index
          keyword = chunk_data[0..null_index-1]
          
          # Check if this is our custom keyword.
          if keyword == "HexData"
            GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "keyword is HexData\n\n", "a")
            # The hex string is after the null byte.
            return chunk_data[null_index+1..-1]
          end
        end
      end

      # Move to the next chunk: length (4) + type (4) + data (length) + crc (4).
      # The position is updated regardless of the chunk type.
      current_position += 4 + 4 + length + 4

      # Stop when the IEND chunk is reached.
      if chunk_type == 'IEND'
        GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "chunk_type is 'IEND'\n\n", "a")
        break
      end
    rescue StandardError => e
      # This rescues any error that occurs during chunk processing, which usually
      # means the file is corrupt or the position is wrong.
      puts "Error during decoding: #{e.message}"
      GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "Error during decoding: #{e.message}\n\n", "a")
      return nil
    end
  end

  # If we reach the end and haven't found the chunk, return nil.
  GardenUtil.pbCreateTextFile(OfflineTradingSystem::TRADING_ERROR_LOG_FILE_PATH, "Reached the end of the method and have not found a chunk. Returning nil\n\n", "a")
  return nil
end