# OpenSSL-SSH - Modernization for Ruby 3.x / OpenSSL 3.x

Parse OpenSSH format public keys (`ssh-rsa AAAA...`) and return `OpenSSL::PKey` objects.

## Problem

The current implementation is **broken** on Ruby 2.4+ / OpenSSL 2.0+:

```ruby
# OLD approach - BROKEN
key = OpenSSL::PKey::RSA.new
key.n = n_value  # ❌ OpenSSL::PKey objects are now immutable
key.e = e_value  # ❌ Can't set properties after creation
```

## Solution

Use ASN.1 DER encoding to construct keys:

```ruby
# NEW approach - WORKS
asn1 = OpenSSL::ASN1::Sequence.new([
  OpenSSL::ASN1::Integer.new(n),
  OpenSSL::ASN1::Integer.new(e)
])
key = OpenSSL::PKey::RSA.new(asn1.to_der)  # ✅
```

## Tasks

### Phase 1: Fix Core
- [ ] Replace property assignment with ASN.1 DER construction
- [ ] Update `process_ops` method to build ASN.1 sequence
- [ ] Test with Ruby 3.x / OpenSSL 3.x
- [ ] Update specs

### Phase 2: Add Key Types
- [ ] Ed25519 support (default for modern OpenSSH)
  ```ruby
  OpenSSL::PKey.new_raw_public_key('ED25519', raw_key_bytes)
  ```
- [ ] ECDSA support (ssh-ed25519, ecdsa-sha2-nistp256, etc.)
- [ ] Keep RSA and DSA support

### Phase 3: Modernize
- [ ] Update gemspec dependencies
  - bundler ~> 2.0
  - rake ~> 13.0
  - rspec ~> 3.12
- [ ] Add required Ruby version (>= 3.0)
- [ ] Update CI for modern Ruby versions
- [ ] Add GitHub Actions workflow

### Phase 4: Improve
- [ ] Support OpenSSH private key format (new format, not just PEM)
- [ ] Add fingerprint generation (MD5, SHA256)
- [ ] Add key comment extraction
- [ ] Better error messages

## Code Changes

### lib/openssl/ssh.rb

```ruby
module OpenSSL
  module PKey
    class SSH
      SUPPORTED_TYPES = {
        'ssh-rsa' => :rsa,
        'ssh-dss' => :dsa,
        'ssh-ed25519' => :ed25519,
        'ecdsa-sha2-nistp256' => :ecdsa,
        'ecdsa-sha2-nistp384' => :ecdsa,
        'ecdsa-sha2-nistp521' => :ecdsa
      }.freeze

      def self.new(key, password = nil)
        return forward_private_key(key, password) if private_key?(key)
        parse_public_ssh_key(key)
      end

      def self.parse_public_ssh_key(key)
        type, data, _comment = key.strip.split(' ', 3)
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

        asn1 = OpenSSL::ASN1::Sequence.new([
          OpenSSL::ASN1::Integer.new(n),
          OpenSSL::ASN1::Integer.new(e)
        ])
        OpenSSL::PKey::RSA.new(asn1.to_der)
      end

      def self.build_ed25519(components)
        _type, raw_key = components
        OpenSSL::PKey.new_raw_public_key('ED25519', raw_key)
      end

      def self.bytes_to_bn(bytes)
        OpenSSL::BN.new(bytes, 2)
      end

      # ... rest of implementation
    end
  end
end
```

## Why This Gem?

- **Lightweight**: No dependencies beyond Ruby stdlib
- **Focused**: Does one thing well
- **Alternative to net-ssh**: When you just need SSH key parsing, not the full SSH client

## References

- [OpenSSL::PKey docs](https://ruby-doc.org/stdlib/libdoc/openssl/rdoc/OpenSSL/PKey.html)
- [RFC 4253 - SSH Transport](https://tools.ietf.org/html/rfc4253#section-6.6) - Key format
- [RFC 8709 - Ed25519 for SSH](https://tools.ietf.org/html/rfc8709)
