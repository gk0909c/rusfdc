require 'rusfdc/connection'

module Rusfdc
  # provide salesforce operation via partner api
  class Partner
    def initialize(config_file)
      conn = Rusfdc::Connection.new(config_file)
      @client = conn.create_partner_client
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
