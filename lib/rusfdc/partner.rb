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

    def retrieve_fields_of(object_name)
      response = @client.call(
        :describe_s_object,
        message: {
          s_object_type: object_name
        }
      )
      response.body[:describe_s_object_response][:result][:fields]
    end
  end
end
