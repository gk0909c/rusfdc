require 'spec_helper'

# see spec/fixtures/*.xml about expect response xml data
RSpec.describe Rusfdc::Partner do
  let(:partner) { Rusfdc::Partner.new('server url', 'session id') }

  before(:all) { savon.mock! }
  after(:all)  { savon.unmock! }

  describe '#retrieve_custom_objects' do
    subject { partner.retrieve_custom_objects }

    before do
      expect_describe_global
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
      expect_describe_s_object_with(target)
    end

    it 'return fields of object' do
      expect(subject.length).to eq(5)
      expect(subject[0][:name]).to eq('Field1__c')
      expect(subject[1][:name]).to eq('Field2__c')
      expect(subject[2][:name]).to eq('Field3__c')
      expect(subject[3][:name]).to eq('Field4__c')
      expect(subject[4][:name]).to eq('Field5__c')
    end
  end

  describe '#retrieve_child_relationships_of' do
    let(:target) { 'Obj__c' }
    subject { partner.retrieve_child_relationships_of(target) }

    before do
      expect_describe_s_object_with(target)
    end

    it 'return child relationships of object' do
      expect(subject.length).to eq(2)
      expect(subject[0]).to eq(child_s_object: 'ChildObj1__c', relationship_name: 'ChildObj1s__r')
      expect(subject[1]).to eq(child_s_object: 'ChildObj2__c', relationship_name: 'ChildObj2s__r')
    end
  end

  describe '#get_relationship_name_between' do
    let(:target) { 'Obj__c' }

    before do
      expect_describe_s_object_with(target)
    end

    context 'when found relation' do
      subject { partner.get_relationship_name_between(target, 'ChildObj2__c') }

      it 'return relationship name' do
        expect(subject).to eq('ChildObj2s__r')
      end
    end

    context 'when not found relation' do
      let(:child) { 'ChildObj99__c' }
      subject { partner.get_relationship_name_between(target, 'ChildObj99__c') }

      it 'raise error' do
        message = "found no relation between #{target} and {#child}"
        expect { subject }.to raise_error(RuntimeError, message)
      end
    end
  end
end
