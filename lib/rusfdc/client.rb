require 'thor'
require 'rusfdc/partner'

module Rusfdc
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
  end
end
