# OpenSSL-SSH - Modernization for Ruby 3.x / OpenSSL 3.x

Parse OpenSSH format public keys (`ssh-rsa AAAA...`) and return `OpenSSL::PKey` objects.

## Completed

### Phase 1: Fix Core
- [x] Replace property assignment with ASN.1 DER construction
- [x] Update `build_rsa` method to build ASN.1 sequence
- [x] Update `build_dsa` method to use SubjectPublicKeyInfo format
- [x] Test with Ruby 3.x / OpenSSL 3.x
- [x] Update specs

### Phase 2: Add Key Types
- [x] Ed25519 support (default for modern OpenSSH)
  ```ruby
  OpenSSL::PKey.new_raw_public_key('ED25519', raw_key_bytes)
  ```
- [x] ECDSA support (ecdsa-sha2-nistp256, ecdsa-sha2-nistp384, ecdsa-sha2-nistp521)
- [x] Keep RSA and DSA support

### Phase 3: Modernize
- [x] Update gemspec dependencies
  - bundler ~> 2.0
  - rake ~> 13.0
  - rspec ~> 3.12
  - simplecov ~> 0.22
  - base64 (runtime dependency for Ruby 3.4+)
- [x] Add required Ruby version (>= 3.0)
- [x] Add GitHub Actions workflow
- [x] Update metadata URIs

## Future Improvements

### Phase 4: OpenSSH Private Key Format
- [ ] Support OpenSSH private key format (new format, not just PEM)
  - Ed25519 and ECDSA private keys use new format by default
  - Requires custom parser for `-----BEGIN OPENSSH PRIVATE KEY-----`
- [ ] Add fingerprint generation (MD5, SHA256)
- [ ] Add key comment extraction
- [ ] Better error messages

## Supported Key Types

| Type | Public Key | Private Key (PEM) | Private Key (OpenSSH) |
|------|------------|-------------------|----------------------|
| RSA | ✅ | ✅ | ❌ |
| DSA | ✅ | ✅ | ❌ |
| Ed25519 | ✅ | N/A | ❌ (pending) |
| ECDSA | ✅ | ✅ | ❌ (pending) |

## References

- [OpenSSL::PKey docs](https://ruby-doc.org/stdlib/libdoc/openssl/rdoc/OpenSSL/PKey.html)
- [RFC 4253 - SSH Transport](https://tools.ietf.org/html/rfc4253#section-6.6) - Key format
- [RFC 8709 - Ed25519 for SSH](https://tools.ietf.org/html/rfc8709)
