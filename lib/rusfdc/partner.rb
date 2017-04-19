require 'savon'

module Rusfdc
  # provide salesforce operation via partner api
  class Partner
    def initialize(server_url, session_id)
      @client = Savon.client(
        wsdl: Rusfdc::PARTNER_WSDL,
        endpoint: server_url,
        soap_header: { 'tns:SessionHeader' => { 'tns:sessionId' => session_id } }
      )
    end

    def retrieve_custom_objects
      response = @client.call(
        :describe_global
      )
      sobjects = response.body[:describe_global_response][:result][:sobjects]
      sobjects
        .select { |object| object[:custom] }
    end

    def retrieve_describe_of(object_name)
      response = @client.call(
        :describe_s_object,
        message: {
          s_object_type: object_name
        }
      )
      response.body[:describe_s_object_response][:result]
    end

    def retrieve_fields_of(object_name)
      retrieve_describe_of(object_name)[:fields]
    end

    def retrieve_child_relationships_of(object_name)
      retrieve_describe_of(object_name)[:child_relationships]
    end

    def get_relationship_name_between(parent, child)
      relationship = retrieve_child_relationships_of(parent)
                     .find { |r| r[:child_s_object] == child }

      raise "found no relation between #{parent} and {#child}" unless relationship
      relationship[:relationship_name]
    end
  end
end
