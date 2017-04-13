require 'json'
require 'yaml'
require 'savon'

module Rusfdc
  class Connection
    PARTNER_WSDL = 'wsdl/partner.wsdl'.freeze

    def initialize(config_file)
      config = YAML.load_file(config_file)
      response = login_to_salesforce(config)
      keep_connection_info(config['username'], response.body[:login_response][:result])
    end

    def create_partner_client
      Savon.client(
        wsdl: PARTNER_WSDL,
        endpoint: @server_url,
        soap_header: { 'tns:SessionHeader' => { 'tns:sessionId' => @session_id } }
      )
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

      def keep_connection_info(username, res)
        @username = username
        @session_id = res[:session_id]
        @server_url = res[:server_url]
        @metadata_url = res[:metadata_server_url]
        gen_server_instance
      end

      def gen_server_instance
        urls = @server_url.split('/')
        @server_instance = [urls[0], '//', urls[2]].join
      end

      def rest_header
        {
          Authorization: ['Bearer ', @session_id].join,
          'Content-Type' => 'application/json'
        }
      end
  end
end
