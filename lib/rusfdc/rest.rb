require 'httpclient'

module Rusfdc
  # provide salesforce rest api
  class Rest
    def initialize(server_url, session_id)
      gen_server_instance(server_url)
      @session_id = session_id
    end

    def create_nested_record(sobject, nested_record)
      http_client = HTTPClient.new
      res = http_client.post_content(
        [@server_instance, '/services/data/v39.0/composite/tree/', sobject, '/'].join,
        nested_record.to_json,
        rest_header
      )
      JSON.parse(res)
    end

    private

      def gen_server_instance(server_url)
        urls = server_url.split('/')
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
