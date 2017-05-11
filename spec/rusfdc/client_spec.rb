require 'spec_helper'
require 'rusfdc/client'

RSpec.describe Rusfdc::Client do
  before(:all) { savon.mock! }
  after(:all)  { savon.unmock! }
  before do
    allow(YAML).to receive(:load_file).and_return('username' => 'user1@test.com')
    expect_login
  end

  describe '#list_custom_object' do
    subject { Rusfdc::Client.new.invoke(:list_custom_object, [], {}) }

    before { expect_describe_global }

    it 'print object list to standard out' do
      out_format = "name: %s label: %s\n"
      out1 = format(out_format, 'Obj1__c'.ljust(20), 'Obj1_label')
      out2 = format(out_format, 'Obj3__c'.ljust(20), 'Obj3_label')

      expect { subject }.to output([out1, out2].join).to_stdout
    end
  end

  describe '#list_custom_field' do
    let(:target) { 'Obj__c' }
    subject { Rusfdc::Client.new.invoke(:list_object_field, [], name: target) }

    before { expect_describe_s_object_with(target) }

    it 'print field list to standard out' do
      out_format = "name: %s label: %s\n"
      expect = [
        %w(Field1__c Field1_label),
        %w(Field2__c Field2_label),
        %w(Field3__c Field3_label),
        %w(Field4__c Field4_label),
        %w(Field5__c Field5_label),
        ['CreatedById', '作成者 ID']
      ].map { |a| format(out_format, a[0].ljust(30), a[1]) }.join

      expect { subject }.to output(expect).to_stdout
    end
  end

  describe '#create_nested_record' do
    let(:param) { { name: 'Obj__c', file: 'test.json' } }
    let(:server) { 'https://server.com' }
    let(:endpoint) { "#{server}/services/data/v39.0/composite/tree/Obj__c/" }
    let(:out_file) { 'result_of_create_nested_record_20170401120000.json' }
    subject { Rusfdc::Client.new.invoke(:create_nested_record, [], param) }

    before do
      Timecop.freeze(Time.local(2017, 4, 1, 12, 0, 0))
      allow(IO).to receive(:read).and_call_original
      allow(IO).to receive(:read).with('test.json').and_return('{"fake":"json"}')
      stub_request(:post, endpoint).to_return(body: '{"result":"success"}', status: 200)
    end
    after { File.delete(out_file) }

    it 'out success and filename' do
      output = "success! result is in #{out_file}\n"
      expect { subject }.to output(output).to_stdout
    end

    it 'write result file' do
      subject
      expect(File.exist?(out_file)).to be_truthy
    end

    it 'write pretty json' do
      subject
      expect(IO.read(out_file)).to eq(%({\n  "result": "success"\n}))
    end
  end

  describe '#generate_nested_record_template' do
    let(:parent) { 'Obj__c' }
    let(:child) { 'ChildObj2__c' }
    let(:out_file) { "#{parent}_and_#{child}_20170401120000.json" }
    let(:param) { { parent: parent, child: child } }
    subject { Rusfdc::Client.new.invoke(:generate_nested_record_template, [], param) }

    before do
      Timecop.freeze(Time.local(2017, 4, 1, 12, 0, 0))
      expect_describe_s_object_with(parent)
    end
    after { File.delete(out_file) }

    it 'create nested record template file' do
      output = "success! result is in #{out_file}\n"
      expect { subject }.to output(output).to_stdout
      expect(File.exist?(out_file)).to be_truthy
    end
  end

  describe '#retrieve_layout_with_field_info' do
    let(:target) { 'Obj__c' }
    let(:out_file) { "#{target}_layout_info.json" }
    subject { Rusfdc::Client.new.invoke(:retrieve_layout_with_field_info, [], name: target) }

    before do
      expect_describe_layout_of(target)
      expect_describe_s_object_with(target)
    end
    after { File.delete(out_file) }

    it 'print success message' do
      output = "success! result is in #{out_file}\n"
      expect { subject }.to output(output).to_stdout
    end

    it 'create nested record template file' do
      subject
      expect(File.exist?(out_file)).to be_truthy
    end
  end
end
