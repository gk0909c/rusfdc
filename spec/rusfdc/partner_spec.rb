require 'spec_helper'

RSpec.describe Rusfdc::Partner do
  let(:partner) { Rusfdc::Partner.new('server url', 'session id') }

  before(:all) { savon.mock! }
  after(:all)  { savon.unmock! }

  describe '#retrieve_custom_objects' do
    subject { partner.retrieve_custom_objects }

    before do
      fixture = File.read('spec/fixtures/describe_global_response.xml')
      savon.expects(:describe_global).returns(fixture)
    end

    it 'select custom objects' do
      expect(subject.length).to eq(2)
      expect(subject[0]).to eq(name: 'Obj1__c', label: 'Obj1_label', custom: true)
      expect(subject[1]).to eq(name: 'Obj3__c', label: 'Obj3_label', custom: true)
    end
  end

  describe '#retrieve_fields_of' do
    let(:target) { 'Obj__c' }
    subject { partner.retrieve_fields_of(target) }

    before do
      message = { s_object_type: target }
      fixture = File.read('spec/fixtures/describe_s_object_response.xml')
      savon.expects(:describe_s_object).with(message: message).returns(fixture)
    end

    it 'select custom objects' do
      expect(subject.length).to eq(2)
      expect(subject[0]).to eq(name: 'Field1__c', label: 'Field1_label')
      expect(subject[1]).to eq(name: 'Field2__c', label: 'Field2_label')
    end
  end
end
