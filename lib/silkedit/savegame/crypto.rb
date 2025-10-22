require 'openssl'

module Silkedit::Savegame
  module Crypto
    AES_KEY = YAML.safe_load_file(File.join(Silkedit::LIBDIR, 'config', 'savegame.yaml'), symbolize_names: true)[:aes_key]

    def initialize(key)
      @aes_key = key
    end

    def self.aes_encrypt(data)
      cipher = OpenSSL::Cipher.new('AES-256-ECB')
      cipher.encrypt
      cipher.key = AES_KEY
      cipher.update(data) + cipher.final
    end

    def self.aes_decrypt(data)
      cipher = OpenSSL::Cipher.new('AES-256-ECB')
      cipher.decrypt
      cipher.key = AES_KEY
      cipher.update(data) + cipher.final
    end
  end
end