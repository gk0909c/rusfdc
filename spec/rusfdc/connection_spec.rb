require 'spec_helper'
require 'savon/mock/spec_helper'
require 'rusfdc/connection'

RSpec.describe Rusfdc::Connection do
  include Savon::SpecHelper

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

  # describe '#create_partner_client' do
  #   subject { conn.create_partner_client }
  #
  #   it 'return Savon client with partner wsdl' do
  #     savon_client_param = {
  #       wsdl: Rusfdc::Connection::PARTNER_WSDL,
  #       endpoint: anything,
  #       soap_header: anything
  #     }
  #     expect(Savon).to receive(:client).with(savon_client_param)
  #     expect(subject).to eq(savon_cli)
  #   end
  # end

  describe '#create_rest_client' do
    it 'return Rusfdc::Rest instance with server instance and session id' do
      allow(Rusfdc::Rest).to receive(:new)
      conn.create_rest_client

      expect(Rusfdc::Rest).to have_received(:new).with('https://server.com', 'test_session_id')
    end
  end
end
