require 'base64'

module Silkedit::Savegame
  module Packer
    RAWHEADER = "\u0000\u0001\u0000\u0000\u0000\xFF\xFF\xFF\xFF\u0001\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0006\u0001\u0000\u0000\u0000"
    C_SHARP_HEADER = [0, 1, 0, 0, 0, 255, 255, 255, 255, 1, 0, 0, 0, 0, 0, 0, 0, 6, 1, 0, 0, 0]

    def self.can_unpack?(string)
      return string.start_with?(RAWHEADER)
    end

    def self.pack(string)
      string = Crypto.aes_encrypt(string)
      string = Base64.strict_encode64(string)
      string = self.add_header(string)
      string
    end

    def self.unpack(bytes)
      bytes = self.strip_header(bytes)
      bytes = Base64.decode64(bytes)
      bytes = Crypto.aes_decrypt(bytes)
      string = bytes.force_encoding('UTF-8')
      string
    end

    def self.generate_length_prefixed_string(length)
      length = [length, 0x7FFFFFFF].min
      bytes = []
      while true
        if length >> 7 != 0
          bytes << ((length & 0x7F) | 0x80)
          length >>= 7
        else
          bytes << (length & 0x7F)
          length >>= 7
          break
        end
      end
      bytes << length if length != 0
      bytes.pack("C*")
    end

    def self.add_header(data)
      # Ensure data is a binary string
      data = data.b if data.respond_to?(:b)
      length_data = generate_length_prefixed_string(data.bytesize)
      result = String.new
      result << RAWHEADER.dup.force_encoding("ASCII-8BIT")
      result << length_data
      result << data
      result << [11].pack("C")
      result
    end

    def self.strip_header(data)
      # Remove fixed header and ending byte (11)
      start = C_SHARP_HEADER.length
      finish = data.bytesize - 1
      data = data.byteslice(start...finish)

      # Remove variable-length LengthPrefixedString header
      bytes = data.bytes
      length_count = 0
      bytes.each do |byte|
        length_count += 1
        break if (byte & 0x80) == 0
      end

      # Slice off the length prefix header
      stripped = bytes[length_count..-1] || []
      stripped.pack("C*")
    end
  end
end