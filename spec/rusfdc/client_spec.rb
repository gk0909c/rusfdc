require 'spec_helper'
require 'rusfdc/client'

RSpec.describe Rusfdc::Partner do
  let(:savon_cli) { double('Savon Cli') }

  before do
    conn = double('conn')
    allow(Rusfdc::Connection).to receive(:new).with(anything).and_return(conn)
    allow(conn).to receive(:create_partner_client).and_return(savon_cli)
  end

  describe '#list_custom_object' do
    let(:res) { spy('Response') }
    let(:response_body) do
      build_global_describe_response(
        [
          { name: 'name1', label: 'label1', custom: true },
          { name: 'name2', label: 'label2', custom: false },
          { name: 'name3', label: 'label3', custom: true }
        ]
      )
    end
    subject { Rusfdc::Client.new.invoke(:list_custom_object, [], {}) }

    before do
      allow(savon_cli).to receive(:call).with(:describe_global).and_return(res)
      allow(res).to receive(:body).and_return(response_body)
    end

    it 'print object list to standard out' do
      out_format = "name: %s label: %s\n"
      out1 = format(out_format, 'name1'.ljust(20), 'label1')
      out2 = format(out_format, 'name3'.ljust(20), 'label3')
      expect { subject }.to output([out1, out2].join).to_stdout
    end
  end
end
