# OpenSSL-SSH - Ruby Gem Modernization

**Repo**: https://github.com/aladac/openssl-ssh
**Detailed TODO**: See [TODO.md in repo](https://github.com/aladac/openssl-ssh/blob/master/TODO.md)

## Summary
Ruby gem to parse OpenSSH format keys (`ssh-rsa AAAA...`) into `OpenSSL::PKey` objects.

## Problem
Current code is **broken** on Ruby 2.4+ / OpenSSL 2.0+. Uses property assignment on immutable objects:
```ruby
key.n = value  # ❌ Fails - OpenSSL::PKey is immutable
```

## Fix
Use ASN.1 DER construction:
```ruby
asn1 = OpenSSL::ASN1::Sequence.new([
  OpenSSL::ASN1::Integer.new(n),
  OpenSSL::ASN1::Integer.new(e)
])
key = OpenSSL::PKey::RSA.new(asn1.to_der)  # ✅ Works
```

## Quick Tasks
- [ ] Replace property assignment with ASN.1 DER approach
- [ ] Add Ed25519 support (modern default)
- [ ] Add ECDSA support
- [ ] Update gemspec for Ruby 3.x
- [ ] Add GitHub Actions CI
