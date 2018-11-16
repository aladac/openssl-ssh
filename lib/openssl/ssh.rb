require 'openssl/ssh/version'
require 'base64'
require 'openssl'

module OpenSSL
  module PKey
    class SSH
      RSA_COMPONENTS = ['ssh-rsa', :e, :n].freeze
      DSA_COMPONENTS = ['ssh-dss', :p, :q, :g, :pub_key].freeze

      def self.new(key, password = nil)
        forward_private_key(key, password) || parse_public_ssh_key(key)
      end

      def self.forward_private_key(key, password)
        case key
        when /BEGIN RSA PRIVATE KEY/
          OpenSSL::PKey::RSA.new(key, password)
        when /BEGIN DSA PRIVATE KEY/
          OpenSSL::PKey::DSA.new(key, password)
        end
      end

      def self.parse_public_ssh_key(key)
        if key && key.is_a?(String) && key.match?(/^ssh-/)
          key = key.split[1]
          key = decode_pubkey(key)
        end
        key
      end

      def self.decode_pubkey(string)
        components = unpack_pubkey_components Base64.decode64(string)
        raise "Unsupported key type #{components.first}" unless components.first.match?(/#{RSA_COMPONENTS.first}|#{DSA_COMPONENTS.first}/)

        ops, key = process_components(components)
        process_ops(key, ops)
      end

      def self.key_type_components(components)
        (components.first.match?(RSA_COMPONENTS.first) ? RSA_COMPONENTS : DSA_COMPONENTS).zip(components)
      end

      def self.key_type_object(components)
        components.first.match?(RSA_COMPONENTS.first) ? OpenSSL::PKey::RSA.new : OpenSSL::PKey::DSA.new
      end

      def self.process_components(components)
        [key_type_components(components), key_type_object(components)]
      end

      def self.process_ops(key, ops)
        ops.each do |o|
          next unless o.first.is_a? Symbol

          key.send "#{o.first}=", decode_mpi(o.last)
        end
        key
      end

      def self.unpack_pubkey_components(str)
        cs = []
        i = 0
        while i < str.length
          len = str[i, 4].unpack1('N')
          cs << str[i + 4, len]
          i += 4 + len
        end
        cs
      end

      def self.decode_mpi(mpi_str)
        mpi_str.unpack('C*').inject(0) { |a, e| (a << 8) | e }
      end
    end
  end
end
