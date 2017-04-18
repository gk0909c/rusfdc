require 'spec_helper'
require 'rusfdc/connection'
require 'rusfdc/rest'

RSpec.describe Rusfdc::Rest do
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
    subject { conn.create_rest_client }

    before do
      allow(Savon).to receive(:client).and_return(savon_cli)
      allow(savon_cli).to receive(:call).with(:login, anything).and_return(response)
      allow(response).to receive(:body).and_return(response_body)
    end

    it 'keep server instance as instance variables' do
      expect(subject.instance_variable_get(:@server_instance)).to eq('https://server.com')
    end

    it 'keep session id as instance variables' do
      expect(subject.instance_variable_get(:@session_id)).to eq('test_session_id')
    end
  end
end
