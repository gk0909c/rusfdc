require 'spec_helper'
require 'rusfdc/connection'

RSpec.describe Rusfdc::Connection do
  let(:savon_cli) { spy('Savon Client') }
  let(:conn) { Rusfdc::Connection.new('somepath') }

  before do
    allow(YAML).to receive(:load_file).and_return('username' => 'user1@test.com')
  end

  describe '#initialize' do
    let(:response) { spy('Response') }
    let(:response_body) do
      build_login_response(
        'test_session_id',
        'https://server.com/soap/somepath',
        'https://server.com/meta/somepath'
      )
    end
    subject { conn }

    before do
      allow(Savon).to receive(:client).and_return(savon_cli)
      allow(savon_cli).to receive(:call).with(:login, anything).and_return(response)
      allow(response).to receive(:body).and_return(response_body)
    end

    it 'keep username as instance variables' do
      expect(subject.instance_variable_get(:@username)).to eq('user1@test.com')
    end

    it 'keep session id as instance variables' do
      expect(subject.instance_variable_get(:@session_id)).to eq('test_session_id')
    end

    it 'keep server_url id as instance variables' do
      expect(subject.instance_variable_get(:@server_url)).to eq('https://server.com/soap/somepath')
    end

    it 'keep metadata_server_url id as instance variables' do
      expect(subject.instance_variable_get(:@metadata_url)).to eq('https://server.com/meta/somepath')
    end
  end

  describe '#create_partner_client' do
    subject { conn.create_partner_client }

    before do
      allow(Savon).to receive(:client).and_return(savon_cli)
    end

    it 'return Savon client with partner wsdl' do
      savon_client_param = {
        wsdl: Rusfdc::Connection::PARTNER_WSDL,
        endpoint: anything,
        soap_header: anything
      }
      expect(Savon).to receive(:client).with(savon_client_param)
      expect(subject).to eq(savon_cli)
    end
  end
end
