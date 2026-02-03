# frozen_string_literal: true

require "openssl/ssh/version"
require "base64"
require "openssl"

module OpenSSL
  module PKey
    class SSH
      SUPPORTED_TYPES = {
        "ssh-rsa" => :rsa,
        "ssh-dss" => :dsa,
        "ssh-ed25519" => :ed25519,
        "ecdsa-sha2-nistp256" => :ecdsa,
        "ecdsa-sha2-nistp384" => :ecdsa,
        "ecdsa-sha2-nistp521" => :ecdsa
      }.freeze

      ECDSA_CURVES = {
        "ecdsa-sha2-nistp256" => "prime256v1",
        "ecdsa-sha2-nistp384" => "secp384r1",
        "ecdsa-sha2-nistp521" => "secp521r1"
      }.freeze

      def self.new(key, password = nil)
        forward_private_key(key, password) || parse_public_ssh_key(key)
      end

      def self.forward_private_key(key, password)
        case key
        when /BEGIN RSA PRIVATE KEY/, /BEGIN PRIVATE KEY/
          OpenSSL::PKey::RSA.new(key, password)
        when /BEGIN DSA PRIVATE KEY/
          OpenSSL::PKey::DSA.new(key, password)
        when /BEGIN EC PRIVATE KEY/
          OpenSSL::PKey::EC.new(key, password)
        when /BEGIN OPENSSH PRIVATE KEY/
          parse_openssh_private_key(key, password)
        end
      end

      def self.parse_openssh_private_key(key, password)
        # OpenSSH new format private keys - delegate to OpenSSL if supported
        OpenSSL::PKey.read(key, password)
      rescue OpenSSL::PKey::PKeyError
        raise "OpenSSH private key format not supported by your OpenSSL version"
      end

      def self.parse_public_ssh_key(key)
        return key unless key.is_a?(String) && key.match?(/^(ssh-|ecdsa-)/)

        parts = key.strip.split(" ", 3)
        type = parts[0]
        data = parts[1]
        # comment = parts[2] # Available if needed

        raise "Unsupported key type: #{type}" unless SUPPORTED_TYPES.key?(type)

        decoded = Base64.decode64(data)
        components = unpack_pubkey_components(decoded)

        case SUPPORTED_TYPES[type]
        when :rsa then build_rsa(components)
        when :dsa then build_dsa(components)
        when :ed25519 then build_ed25519(components)
        when :ecdsa then build_ecdsa(components, type)
        end
      end

      def self.build_rsa(components)
        _type, e_bytes, n_bytes = components
        e = bytes_to_bn(e_bytes)
        n = bytes_to_bn(n_bytes)

        # RSA public key ASN.1 structure:
        # RSAPublicKey ::= SEQUENCE {
        #   modulus           INTEGER,  -- n
        #   publicExponent    INTEGER   -- e
        # }
        asn1 = OpenSSL::ASN1::Sequence.new([
          OpenSSL::ASN1::Integer.new(n),
          OpenSSL::ASN1::Integer.new(e)
        ])
        OpenSSL::PKey::RSA.new(asn1.to_der)
      end

      def self.build_dsa(components)
        _type, p_bytes, q_bytes, g_bytes, pub_key_bytes = components
        p = bytes_to_bn(p_bytes)
        q = bytes_to_bn(q_bytes)
        g = bytes_to_bn(g_bytes)
        pub_key = bytes_to_bn(pub_key_bytes)

        # DSA public key requires SubjectPublicKeyInfo format:
        # DSAParameters ::= SEQUENCE {
        #   p INTEGER,
        #   q INTEGER,
        #   g INTEGER
        # }
        # DSAPublicKey ::= INTEGER -- public key y
        #
        # SubjectPublicKeyInfo ::= SEQUENCE {
        #   algorithm AlgorithmIdentifier,
        #   subjectPublicKey BIT STRING
        # }
        dsa_params = OpenSSL::ASN1::Sequence.new([
          OpenSSL::ASN1::Integer.new(p),
          OpenSSL::ASN1::Integer.new(q),
          OpenSSL::ASN1::Integer.new(g)
        ])

        # OID for DSA: 1.2.840.10040.4.1
        algo_id = OpenSSL::ASN1::Sequence.new([
          OpenSSL::ASN1::ObjectId.new("DSA"),
          dsa_params
        ])

        pub_key_asn1 = OpenSSL::ASN1::Integer.new(pub_key)
        pub_key_bitstring = OpenSSL::ASN1::BitString.new(pub_key_asn1.to_der)

        spki = OpenSSL::ASN1::Sequence.new([
          algo_id,
          pub_key_bitstring
        ])

        OpenSSL::PKey::DSA.new(spki.to_der)
      end

      def self.build_ed25519(components)
        _type, raw_key = components

        # Ed25519 requires Ruby 3.0+ with OpenSSL 1.1.1+
        unless OpenSSL::PKey.respond_to?(:new_raw_public_key)
          raise "Ed25519 requires Ruby 3.0+ with OpenSSL 1.1.1+"
        end

        OpenSSL::PKey.new_raw_public_key("ED25519", raw_key)
      end

      def self.build_ecdsa(components, key_type)
        _type, _, point_data = components
        curve = ECDSA_CURVES[key_type]

        # ECDSA public key in SubjectPublicKeyInfo format
        # The point_data is already in uncompressed point format (04 || x || y)

        # OID for EC: 1.2.840.10045.2.1
        # Named curve OIDs
        algo_id = OpenSSL::ASN1::Sequence.new([
          OpenSSL::ASN1::ObjectId.new("id-ecPublicKey"),
          OpenSSL::ASN1::ObjectId.new(curve)
        ])

        pub_key_bitstring = OpenSSL::ASN1::BitString.new(point_data)

        spki = OpenSSL::ASN1::Sequence.new([
          algo_id,
          pub_key_bitstring
        ])

        OpenSSL::PKey::EC.new(spki.to_der)
      end

      def self.unpack_pubkey_components(str)
        components = []
        i = 0
        while i < str.length
          len = str[i, 4].unpack1("N")
          components << str[i + 4, len]
          i += 4 + len
        end
        components
      end

      def self.bytes_to_bn(bytes)
        OpenSSL::BN.new(bytes, 2)
      end
    end
  end
end
