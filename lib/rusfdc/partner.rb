require 'rusfdc/connection'

module Rusfdc
  class Partner
    def initialize(config_file)
      conn = Rusfdc::Connection.new(config_file)
      @client = conn.create_partner_client
    end

    def list_custom_object
      response = @client.call(
        :describe_global
      )
      sobjects = response.body[:describe_global_response][:result][:sobjects]
      sobjects
        .select { |object| object[:custom] }
        .each { |object| puts "name: #{object[:name].ljust(20)} label: #{object[:label]}" }
    end

    def list_custom_field(object_name)
      response = @client.call(
        :describe_s_object,
        message: {
          s_object_type: object_name
        }
      )
      fields = response.body[:describe_s_object_response][:result][:fields]
      fields
        .each { |field| puts "name: #{field[:name].ljust(30)} label: #{field[:label]}" }
    end
  end
end
