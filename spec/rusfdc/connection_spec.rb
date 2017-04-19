require 'spec_helper'

RSpec.describe Rusfdc::Connection do
  let(:conn) { Rusfdc::Connection.new('somepath') }

  before(:all) { savon.mock! }
  after(:all)  { savon.unmock! }

  before do
    allow(YAML).to receive(:load_file).and_return('username' => 'user1@test.com')
    message = { username: 'user1@test.com', password: '' }
    fixture = File.read('spec/fixtures/login_response.xml')
    savon.expects(:login).with(message: message).returns(fixture)
  end

  describe '#initialize' do
    subject { conn }

    before do
    end

    it 'keep username' do
      expect(subject.instance_variable_get(:@username)).to eq('user1@test.com')
    end

    it 'keep session id' do
      expect(subject.instance_variable_get(:@session_id)).to eq('test_session_id')
    end

    it 'keep server_url' do
      expect(subject.instance_variable_get(:@server_url)).to eq('https://server.com/soap/somepath')
    end

    it 'keep metadata_server_url' do
      expect(subject.instance_variable_get(:@metadata_url)).to eq('https://server.meta.com/meta/somepath')
    end

    it 'keep server_instance' do
      expect(subject.instance_variable_get(:@server_instance)).to eq('https://server.com')
    end
  end
end
