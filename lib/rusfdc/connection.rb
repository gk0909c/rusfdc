require 'json'
require 'yaml'
require 'savon'
require 'rusfdc/rest'

module Rusfdc
  # provide salesforce connection
  class Connection
    WSDL_DIR = "#{File.dirname(__FILE__)}/../../wsdl".freeze
    PARTNER_WSDL = "#{WSDL_DIR}/partner.wsdl".freeze

    def initialize(config_file)
      config = YAML.load_file(config_file)
      response = login_to_salesforce(config)
      keep_connection_info(config, response.body[:login_response][:result])
    end

    def create_partner_client
      Savon.client(
        wsdl: PARTNER_WSDL,
        endpoint: @server_url,
        soap_header: { 'tns:SessionHeader' => { 'tns:sessionId' => @session_id } }
      )
    end

    def create_rest_client
      Rusfdc::Rest.new(@server_url, @session_id)
    end

    private

      def login_to_salesforce(config)
        client = Savon.client(wsdl: PARTNER_WSDL, endpoint: config['endpoint'])
        client.call(
          :login,
          message: {
            username: config['username'],
            password: "#{config['password']}#{config['security_token']}"
          }
        )
      end

      def keep_connection_info(config, res)
        @username = config['username']
        @session_id = res[:session_id]
        @server_url = res[:server_url]
        @metadata_url = res[:metadata_server_url]
      end
  end
end
