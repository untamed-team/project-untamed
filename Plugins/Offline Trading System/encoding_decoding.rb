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
#   success = encode_hex_to_png(file_path, hex_string)
#   if success
#     p "Encoding successful!"
#   else
#     p "Encoding failed."
#   end
#
# To decode a string:
#   file_path = "path/to/your/image.png"
#   decoded_string = decode_hex_from_png(file_path)
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
def encode_hex_to_png(file_path, hex_string)
  # Read the PNG file into memory.
  begin
    file_data = File.binread(file_path)
  rescue Errno::ENOENT
    puts "Error: File '#{file_path}' not found."
    return false
  end

  # The PNG header is always 8 bytes.
  png_signature = file_data[0..7]

  # We will compare the byte values directly to avoid any encoding issues.
  correct_png_signature_bytes = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
  unless png_signature.bytes == correct_png_signature_bytes
    puts "Error: Not a valid PNG file."
    return false
  end

  # Initialize a new array to hold the chunks of the new file.
  new_chunks = []
  current_position = 8

  while current_position < file_data.length
    begin
      # Break if there's not enough data left for a chunk header.
      break if (file_data.length - current_position) < 8
      
      # Read the chunk's length (4 bytes).
      length = file_data[current_position, 4].unpack('N')[0]
      
      # Read the chunk's type (4 bytes).
      chunk_type = file_data[current_position + 4, 4]
      
      # Read the entire chunk, including data and CRC.
      chunk_end = current_position + 8 + length + 4
      chunk_data = file_data[current_position...chunk_end]

      # Add the chunk to our new array of chunks.
      new_chunks << chunk_data

      # If the last chunk was an IDAT chunk, and the next chunk is not, insert our custom chunk.
      # This ensures the custom data is placed logically within the PNG file structure.
      if chunk_type == "IDAT"
        next_chunk_type = file_data[chunk_end + 4, 4]
        if next_chunk_type != "IDAT"
          # Create and insert the custom chunk.
          keyword = "HexData"
          custom_chunk_data = keyword + "\x00" + hex_string
          custom_chunk_type = 'tEXt'
          crc_data = custom_chunk_type + custom_chunk_data
          crc = Zlib::crc32(crc_data)
          new_chunk_with_crc = [custom_chunk_data.bytesize].pack('N') + custom_chunk_type + custom_chunk_data + [crc].pack('N')
          new_chunks << new_chunk_with_crc
        end
      end
      
      # Move to the start of the next chunk.
      current_position = chunk_end
      
    rescue StandardError
      # If any error occurs, the file is likely malformed. We'll skip the rest of the file.
      break
    end
  end

  # Combine all the chunks with the PNG signature.
  new_file_data = png_signature + new_chunks.join

  # Write the new file data, overwriting the original file.
  begin
    File.open(file_path, 'wb') do |f|
      f.write(new_file_data)
    end
    return true
  rescue StandardError => e
    puts "Error writing to file: #{e.message}"
    return false
  end
end


# Function to retrieve a hexadecimal string from a PNG file.
def decode_hex_from_png(file_path)
  # Read the PNG file into memory.
  begin
    file_data = File.binread(file_path)
  rescue Errno::ENOENT
    puts "Error: File '#{file_path}' not found."
    return nil
  end

  # Start after the 8-byte PNG header.
  current_position = 8
  
  while current_position < file_data.length
    begin
      # Ensure there are enough bytes to read the next chunk header.
      break if (file_data.length - current_position) < 8

      # Read the chunk's length (4 bytes).
      length = file_data[current_position, 4].unpack('N')[0]
      
      # Read the chunk's type (4 bytes).
      chunk_type = file_data[current_position + 4, 4]
      
      # DEBUG: Print the chunk type and length.
      puts "Processing chunk: Type=#{chunk_type}, Length=#{length}"
      
      # If we find our custom 'tEXt' chunk, read the data.
      if chunk_type == 'tEXt'
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
            # The hex string is after the null byte.
            return chunk_data[null_index+1..-1]
          end
        end
      end
  
      # Move to the next chunk: length (4) + type (4) + data (length) + crc (4).
      current_position += 4 + 4 + length + 4

      # Stop when the IEND chunk is reached.
      if chunk_type == 'IEND'
        break
      end
    rescue StandardError => e
      # This rescues any error that occurs during chunk processing, which usually
      # means the file is corrupt or the position is wrong.
      puts "Error during decoding: #{e.message}"
      return nil
    end
  end

  # If we reach the end and haven't found the chunk, return nil.
  return nil
end
