# frozen_string_literal: true

RSpec.describe OpenSSL::SSH do
  it 'has a version number' do
    expect(OpenSSL::SSH::VERSION).not_to be nil
  end
end

RSpec.describe OpenSSL::PKey::SSH do
  describe 'RSA keys' do
    it 'parses public RSA key to OpenSSL::PKey::RSA' do
      key = File.read(File.expand_path('./spec/fixtures/sample.pub'))
      result = OpenSSL::PKey::SSH.new(key)
      expect(result).to be_a(OpenSSL::PKey::RSA)
      expect(result.public?).to be true
    end

    it 'parses private RSA key to OpenSSL::PKey::RSA' do
      key = File.read(File.expand_path('./spec/fixtures/sample'))
      result = OpenSSL::PKey::SSH.new(key)
      expect(result).to be_a(OpenSSL::PKey::RSA)
    end
  end

  describe 'DSA keys' do
    it 'parses public DSA key to OpenSSL::PKey::DSA' do
      key = File.read(File.expand_path('./spec/fixtures/sample-dsa.pub'))
      result = OpenSSL::PKey::SSH.new(key)
      expect(result).to be_a(OpenSSL::PKey::DSA)
      expect(result.public?).to be true
    end

    it 'parses private DSA key to OpenSSL::PKey::DSA' do
      key = File.read(File.expand_path('./spec/fixtures/sample-dsa'))
      result = OpenSSL::PKey::SSH.new(key, 'qwerty')
      expect(result).to be_a(OpenSSL::PKey::DSA)
    end
  end

  describe 'Ed25519 keys' do
    it 'parses public Ed25519 key' do
      key = File.read(File.expand_path('./spec/fixtures/sample-ed25519.pub'))
      result = OpenSSL::PKey::SSH.new(key)
      expect(result.oid).to eq('ED25519')
    end

    it 'parses private Ed25519 key (OpenSSH format)', pending: 'OpenSSH new format requires custom parser' do
      key = File.read(File.expand_path('./spec/fixtures/sample-ed25519'))
      result = OpenSSL::PKey::SSH.new(key)
      expect(result.oid).to eq('ED25519')
    end
  end

  describe 'ECDSA keys' do
    it 'parses public ECDSA key to OpenSSL::PKey::EC' do
      key = File.read(File.expand_path('./spec/fixtures/sample-ecdsa.pub'))
      result = OpenSSL::PKey::SSH.new(key)
      expect(result).to be_a(OpenSSL::PKey::EC)
      expect(result.public?).to be true
    end

    it 'parses private ECDSA key to OpenSSL::PKey::EC', pending: 'OpenSSH new format requires custom parser' do
      key = File.read(File.expand_path('./spec/fixtures/sample-ecdsa'))
      result = OpenSSL::PKey::SSH.new(key)
      expect(result).to be_a(OpenSSL::PKey::EC)
    end
  end

  describe 'error handling' do
    it 'raises error for unsupported key type' do
      expect do
        OpenSSL::PKey::SSH.new('ssh-unknown AAAA test@example.com')
      end.to raise_error(/Unsupported key type/)
    end

    it 'returns non-string input unchanged' do
      expect(OpenSSL::PKey::SSH.new(nil)).to be_nil
      expect(OpenSSL::PKey::SSH.new(123)).to eq(123)
    end
  end

  describe 'SUPPORTED_TYPES' do
    it 'includes all common SSH key types' do
      expect(OpenSSL::PKey::SSH::SUPPORTED_TYPES.keys).to include(
        'ssh-rsa',
        'ssh-dss',
        'ssh-ed25519',
        'ecdsa-sha2-nistp256',
        'ecdsa-sha2-nistp384',
        'ecdsa-sha2-nistp521'
      )
    end
  end
end
