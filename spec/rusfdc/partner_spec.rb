require 'spec_helper'
require 'rusfdc/partner'

RSpec.describe Rusfdc::Partner do
  let(:savon_cli) { instance_double(Savon::Client) }
  let(:partner) { Rusfdc::Partner.new('any path') }

  before do
    conn = instance_double(Rusfdc::Connection)
    allow(Rusfdc::Connection).to receive(:new).with(anything).and_return(conn)
    allow(conn).to receive(:create_partner_client).and_return(savon_cli)
  end

  describe '#retrieve_custom_objects' do
    let(:res) { double('Response') }
    let(:response_body) do
      build_global_describe_response(
        [
          { name: 'name1', label: 'label1', custom: true },
          { name: 'name2', label: 'label2', custom: false },
          { name: 'name3', label: 'label3', custom: true }
        ]
      )
    end
    subject { partner.retrieve_custom_objects }

    before do
      allow(savon_cli).to receive(:call).with(:describe_global).and_return(res)
      allow(res).to receive(:body).and_return(response_body)
    end

    it 'select custom objects' do
      expect(subject.length).to eq(2)
      expect(subject[0]).to eq(name: 'name1', label: 'label1', custom: true)
      expect(subject[1]).to eq(name: 'name3', label: 'label3', custom: true)
    end
  end

  describe '#retrieve_fields_of' do
    let(:res) { double('Response') }
    let(:response_body) do
      build_describe_s_object_response(
        [
          { name: 'name1', label: 'label1', custom: true },
          { name: 'name2', label: 'label2', custom: false },
          { name: 'name3', label: 'label3', custom: true }
        ]
      )
    end
    subject { partner.retrieve_fields_of('Obj__c') }

    before do
      allow(savon_cli).to receive(:call)
        .with(:describe_s_object, anything)
        .and_return(res)
      allow(res).to receive(:body).and_return(response_body)
    end

    it 'select custom objects' do
      expect(subject.length).to eq(3)
      expect(subject[0]).to eq(name: 'name1', label: 'label1', custom: true)
      expect(subject[1]).to eq(name: 'name2', label: 'label2', custom: false)
      expect(subject[2]).to eq(name: 'name3', label: 'label3', custom: true)
    end
  end
end
