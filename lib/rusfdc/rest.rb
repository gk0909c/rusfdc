require 'httpclient'

module Rusfdc
  # provide salesforce rest api
  class Rest
    def initialize(server_instance, session_id)
      @server_instance = server_instance
      @session_id = session_id
      @http_client = HTTPClient.new
    end

    def create_nested_record(sobject, nested_record)
      res = @http_client.post_content(
        [@server_instance, '/services/data/v39.0/composite/tree/', sobject, '/'].join,
        nested_record.to_json,
        rest_header
      )
      JSON.parse(res)
    end

    def generate_nested_record_template(parent_name, child_name, relation_name)
      child = [{
        attributes: { type: child_name, referenceId: 'child id' },
        Name: 'child name'
      }]

      parent = [{
        attributes: { type: parent_name, referenceId: 'parent id' },
        Name: 'parent name',
        relation_name.to_sym => { records: child }
      }]

      { records: parent }
    end

    private

      def rest_header
        {
          Authorization: ['Bearer ', @session_id].join,
          'Content-Type' => 'application/json'
        }
      end
  end
end
