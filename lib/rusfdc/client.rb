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
      partner = Partner.new(options[:config])
      partner.list_custom_object
    end

    desc 'list_custom_field', 'show specified custom object field list'
    method_option(*config_option)
    option :name, type: :string, aliases: '-n', desc: 'custom object name', required: true
    def list_custom_field
      partner = Partner.new(options[:config])
      partner.list_custom_field(options[:name])
    end
  end
end
