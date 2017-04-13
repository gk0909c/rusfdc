require 'rusfdc/connection'

module Rusfdc
  module Partner
    module_function

    def list_custom_object(config_file)
      conn = Rusfdc::Connection.new(config_file)
      client = conn.create_partner_client

      response = client.call(
        :describe_global
      )
      sobjects = response.body[:describe_global_response][:result][:sobjects]
      sobjects
        .select { |object| object[:custom] }
        .each { |object| puts "name: #{object[:name].ljust(20)} label: #{object[:label]}" }
    end
  end
end
