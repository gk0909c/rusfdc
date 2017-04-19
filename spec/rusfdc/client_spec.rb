require 'spec_helper'
require 'rusfdc/client'

RSpec.describe Rusfdc::Client do
  include Savon::SpecHelper

  before(:all) { savon.mock! }
  after(:all)  { savon.unmock! }
  before do
    allow(YAML).to receive(:load_file).and_return('username' => 'user1@test.com')
    message = { username: 'user1@test.com', password: '' }
    fixture = File.read('spec/fixtures/login_response.xml')
    savon.expects(:login).with(message: message).returns(fixture)
  end

  describe '#list_custom_object' do
    subject { Rusfdc::Client.new.invoke(:list_custom_object, [], {}) }

    before do
      fixture = File.read('spec/fixtures/describe_global_response.xml')
      savon.expects(:describe_global).returns(fixture)
    end

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

    before do
      message = { s_object_type: target }
      fixture = File.read('spec/fixtures/describe_s_object_response.xml')
      savon.expects(:describe_s_object).with(message: message).returns(fixture)
    end

    it 'print field list to standard out' do
      out_format = "name: %s label: %s\n"
      out1 = format(out_format, 'Field1__c'.ljust(30), 'Field1_label')
      out2 = format(out_format, 'Field2__c'.ljust(30), 'Field2_label')

      expect { subject }.to output([out1, out2].join).to_stdout
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
    after do
      File.delete(out_file)
    end

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
end
