require 'json'
require 'yaml'
require 'savon'
require 'rusfdc/rest'

module Rusfdc
  # provide salesforce connection
  class Connection
    def initialize(config_file)
      config = YAML.load_file(config_file)
      response = login_to_salesforce(config)
      keep_connection_info(config, response.body[:login_response][:result])
      gen_server_instance
    end

    def create_partner_client
      Rusfdc::Partner.new(@server_url, @session_id)
    end

    def create_rest_client
      Rusfdc::Rest.new(@server_instance, @session_id)
    end

    private

      def login_to_salesforce(config)
        client = Savon.client(wsdl: Rusfdc::PARTNER_WSDL, endpoint: config['endpoint'])
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

      def gen_server_instance
        urls = @server_url.split('/')
        @server_instance = [urls[0], '//', urls[2]].join
      end
  end
end
