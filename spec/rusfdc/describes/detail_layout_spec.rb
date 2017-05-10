require 'spec_helper'

RSpec.describe Rusfdc::Describes::DetailLayout do
  let(:obj) { 'Obj__c' }
  let(:partner) { Rusfdc::Partner.new('', '') }
  let(:detail_layout) { Rusfdc::Describes::DetailLayout.new(partner.retrieve_layouts_of(obj)) }

  before(:all) { savon.mock! }
  before { expect_describe_layout_of(obj) }
  after(:all) { savon.unmock! }

  describe '#merge_fields' do
    let(:fields) { partner.retrieve_fields_of(obj) }
    subject { detail_layout.merge_fields(fields) }

    before { expect_describe_s_object_with(obj) }

    it 'return layouted fields per session' do
      expect(subject.count).to eq(2)
      expect(subject[0][:name]).to eq('セクション１')
      expect(subject[1][:name]).to eq('セクション２')
    end

    it 'return layouted items info' do
      items = subject[0][:items]
      expect(items.count).to eq(4)

      # assert Field1 - Field4
      items.each_with_index do |i, idx|
        expect(i.label).to eq("Field#{idx + 1}")
        expect(i.required).to eq(idx == 1 ? true : false) # only Field2 is required
        expect(i.field).to eq("Field#{idx + 1}__c")
        expect(i.type).to eq('Field')
      end

      items = subject[1][:items]
      expect(items.count).to eq(1)
      expect(items[0].label).to eq('Field5')
      expect(items[0].required).to be_falsey
      expect(items[0].field).to eq('Field5__c')
      expect(items[0].type).to eq('Field')
    end

    it 'return layouted fields list with field info' do
      items = subject[0][:items]
      expect(items[0].field_type).to eq('string')
      expect(items[1].field_type).to eq('reference')
      expect(items[2].field_type).to eq('double')
      expect(items[3].field_type).to eq('string')

      expect(subject[1][:items][0].field_type).to eq('string')
    end
  end
end
