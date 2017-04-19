require 'spec_helper'
require 'rusfdc/connection'
require 'rusfdc/rest'
require 'json'

RSpec.describe Rusfdc::Rest do
  let(:server) { 'https://server.com' }
  let(:rest) { Rusfdc::Rest.new(server, 'session') }

  describe '#create_rest_client' do
    let(:endpoint) { "#{server}/services/data/v39.0/composite/tree/Account/" }
    subject { rest.create_nested_record('Account', test: 'test') }

    context 'when http code is 200' do
      let(:res) do
        {
          hasErrors: false,
          results: [
            { referenceId: 'refA1', id: '0012800001GbZVtAAN' },
            { referenceId: 'refC1', id: '0032800000y5BauAAE' }
          ]
        }
      end

      before do
        stub_request(:post, endpoint).to_return(body: res.to_json, status: 200)
      end

      it 'return hash response' do
        expect(subject.class).to eq(Hash)
      end
    end

    context 'when http code is 400' do
      before do
        stub_request(:post, endpoint).to_return(body: '{}', status: 400)
      end

      it 'raise BadResponseError' do
        expect { subject }.to raise_error(HTTPClient::BadResponseError)
      end
    end
  end

  describe '#generate_nested_record_template' do
    let(:fixture) { 'spec/fixtures/rest/AccountWithContact.json' }
    let(:expected_template) { JSON.parse(IO.read(fixture), symbolize_names: true) }
    let(:param) { Rusfdc::NestedRecordParam.new('Account', 'Contact', 'Contacts') }
    subject { rest.generate_nested_record_template(param) }

    it 'return template as Hash' do
      expect(subject).to eq(expected_template)
    end
  end
end
