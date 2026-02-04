<div align="center">

# OpenSSL::PKey::SSH

**Parse OpenSSH public keys into Ruby OpenSSL::PKey objects**

[![CI](https://github.com/aladac/openssl-ssh/actions/workflows/ci.yml/badge.svg)](https://github.com/aladac/openssl-ssh/actions/workflows/ci.yml)
[![Gem Version](https://img.shields.io/gem/v/openssl-ssh)](https://rubygems.org/gems/openssl-ssh)
[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.0-CC342D?logo=ruby&logoColor=white)](https://www.ruby-lang.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

</div>

---

This gem introduces `OpenSSL::PKey::SSH` class with the ability to parse **OpenSSH** format public keys and return a correct `OpenSSL::PKey` type object. This is a convenience class used to parse the specific format of the **OpenSSH** public key.

Private **OpenSSH** key strings are forwarded without modification to `OpenSSL::PKey::RSA.new` and `OpenSSL::PKey::DSA.new` respectively.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'openssl-ssh'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install openssl-ssh

## Usage

```ruby
require 'openssl/ssh'

OpenSSL::PKey::SSH.new File.read('/path/to/openssh/public.key')
# <OpenSSL::PKey::RSA:0x00007fb93f9f8788>

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aladac/openssl-ssh.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits

This is almost entirely a refactored and gem packaged variation of a gist by @tombh

https://gist.github.com/tombh/f66de84fd3a63e670ad9
