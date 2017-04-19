require 'json'
require 'thor'
require 'rusfdc/connection'
require 'rusfdc/partner'
require 'rusfdc/rest'

module Rusfdc
  # provide command line interface
  class Client < Thor
    config_option = [
      :config, {
        type: :string, aliases: '-c', desc: 'sfdc connection info', default: './connection.yml'
      }
    ]

    desc 'list_custom_object', 'show custom object list'
    method_option(*config_option)
    def list_custom_object
      p = Partner.new(options[:config])
      p.retrieve_custom_objects
       .each { |object| puts "name: #{object[:name].ljust(20)} label: #{object[:label]}" }
    end

    desc 'list_custom_field', 'show specified custom object field list'
    method_option(*config_option)
    option :name, type: :string, aliases: '-n', desc: 'custom object name', required: true
    def list_object_field
      p = Partner.new(options[:config])
      p.retrieve_fields_of(options[:name])
       .each { |field| puts "name: #{field[:name].ljust(30)} label: #{field[:label]}" }
    end

    desc 'create_nested_record', 'create nested record from json file'
    method_option(*config_option)
    option :name, type: :string, aliases: '-n', desc: 'parent custom object name', required: true
    option :file, type: :string, aliases: '-f', desc: 'json file path', required: true
    def create_nested_record
      rest = create_rest_client(options[:config])

      json_data = JSON.parse(IO.read(options[:file]))
      res = rest.create_nested_record(options[:name], json_data)

      out_file = "result_of_create_nested_record_#{DateTime.now.strftime('%Y%m%d%H%M%S')}.json"
      out_pretty_json(res, out_file)

      puts "success! result is in #{out_file}"
    end

    private

      def create_rest_client(config)
        c = Connection.new(config)
        c.create_rest_client
      end

      def out_pretty_json(json, filename)
        File.open("./#{filename}", 'w') do |f|
          f.write(JSON.pretty_generate(json))
        end
      end
  end
end
