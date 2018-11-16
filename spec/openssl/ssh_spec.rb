RSpec.describe OpenSSL::SSH do
  it 'has a version number' do
    expect(OpenSSL::SSH::VERSION).not_to be nil
  end

  it 'Public RSA key string should become a OpenSSL::PKey::RSA' do
    key = File.read(File.expand_path('./spec/fixtures/sample.pub'))
    expect(OpenSSL::PKey::SSH.new(key)).to be_a(OpenSSL::PKey::RSA)
  end

  it 'Private RSA key string should become a OpenSSL::PKey::RSA' do
    key = File.read(File.expand_path('./spec/fixtures/sample'))
    expect(OpenSSL::PKey::SSH.new(key)).to be_a(OpenSSL::PKey::RSA)
  end

  it 'Public DSA key string should become a OpenSSL::PKey::DSA' do
    key = File.read(File.expand_path('./spec/fixtures/sample-dsa.pub'))
    expect(OpenSSL::PKey::SSH.new(key)).to be_a(OpenSSL::PKey::DSA)
  end

  it 'Private DSA key string should become a OpenSSL::PKey::DSA' do
    key = File.read(File.expand_path('./spec/fixtures/sample-dsa'))
    expect(OpenSSL::PKey::SSH.new(key, 'qwerty')).to be_a(OpenSSL::PKey::DSA)
  end
end
