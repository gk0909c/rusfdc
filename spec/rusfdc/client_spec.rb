require 'spec_helper'
require 'rusfdc/client'

RSpec.describe Rusfdc::Client do
  let(:partner) { double('Partner') }

  before do
    allow(Rusfdc::Partner).to receive(:new).with(anything).and_return(partner)
  end

  describe '#list_custom_object' do
    subject { Rusfdc::Client.new.invoke(:list_custom_object, [], {}) }

    before do
      allow(partner).to receive(:retrieve_custom_objects).and_return(
        [
          { name: 'name1', label: 'label1', custom: true },
          { name: 'name2', label: 'label2', custom: false }
        ]
      )
    end

    it 'print object list to standard out' do
      out_format = "name: %s label: %s\n"
      out1 = format(out_format, 'name1'.ljust(20), 'label1')
      out2 = format(out_format, 'name2'.ljust(20), 'label2')

      expect { subject }.to output([out1, out2].join).to_stdout
    end
  end

  describe '#list_custom_field' do
    subject { Rusfdc::Client.new.invoke(:list_object_field, [], name: 'Obj__c') }

    before do
      expect(partner).to receive(:retrieve_fields_of).with(anything).and_return(
        [
          { name: 'name1', label: 'label1' },
          { name: 'name2', label: 'label2' }
        ]
      )
    end

    it 'print field list to standard out' do
      out_format = "name: %s label: %s\n"
      out1 = format(out_format, 'name1'.ljust(30), 'label1')
      out2 = format(out_format, 'name2'.ljust(30), 'label2')

      expect { subject }.to output([out1, out2].join).to_stdout
    end
  end
end
