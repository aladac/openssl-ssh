# ![OpenSSL](https://raw.githubusercontent.com/aladac/openssl-ssh/master/doc/openssl.png) + ![OpenSSH](https://raw.githubusercontent.com/aladac/openssl-ssh/master/doc/openssh.gif) 4 ![Ruby](https://raw.githubusercontent.com/aladac/openssl-ssh/master/doc/ruby.png)

[![Maintainability](https://api.codeclimate.com/v1/badges/76e285ab4467fa52bc70/maintainability)](https://codeclimate.com/github/aladac/openssl-ssh/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/76e285ab4467fa52bc70/test_coverage)](https://codeclimate.com/github/aladac/openssl-ssh/test_coverage)

# OpenSSL::PKey::SSH

This gem introduces `OpenSSL::PKey::SSH` class with the ability to parse **OpenSSH** format public keys and return a correct `OpenSSL::PKey` type object. This is a convenience class used to parse the specific format of the **OpenSSH** public key.

Private **OpenSSH** key strings are forwarderd without modification to `OpenSSL::PKey::RSA.new` and `OpenSSL::Pkey::DSA.new` respectively.

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
