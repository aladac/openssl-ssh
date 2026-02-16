# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'openssl/ssh/version'

Gem::Specification.new do |spec|
  spec.name = 'openssl-ssh'
  spec.version = OpenSSL::SSH::VERSION
  spec.authors = ['Adam Ladachowski']
  spec.email = ['adam.ladachowski@gmail.com']

  spec.summary = 'Handling for OpenSSH public keys'
  spec.description = 'Parse OpenSSH format public keys (ssh-rsa, ssh-dss, ssh-ed25519, ecdsa-sha2-*) and return OpenSSL::PKey objects'
  spec.homepage = 'https://github.com/aladac/openssl-ssh'
  spec.license = 'MIT'

  spec.required_ruby_version = '>= 3.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/aladac/openssl-ssh'
  spec.metadata['changelog_uri'] = 'https://github.com/aladac/openssl-ssh/blob/master/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Runtime dependencies (base64 extracted from stdlib in Ruby 3.4)
  spec.add_dependency 'base64'

  spec.add_development_dependency 'bundler', '>= 2.5'
  spec.add_development_dependency 'rake', '~> 13.2'
  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'simplecov', '~> 0.22'
  spec.add_development_dependency 'standard', '~> 1.53'
end
