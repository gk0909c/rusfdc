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

    def generate_nested_record_template(param)
      child = record_template(param.child_name, 'child id', Name: 'child name')
      relation_name = param.relation_name ? param.relation_name.to_sym : 'SomeRelation'.to_sym
      parent = record_template(param.parent_name, 'parent id', Name: 'parent name')
      parent[relation_name] = { records: [child] }
      { records: [parent] }
    end

    private

      def rest_header
        {
          Authorization: ['Bearer ', @session_id].join,
          'Content-Type' => 'application/json'
        }
      end

      def record_template(type, ref_id, values)
        template = {
          attributes: { type: type, referenceId: ref_id }
        }
        template.merge(values)
      end
  end
end
