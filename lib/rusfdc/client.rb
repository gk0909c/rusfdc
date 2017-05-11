require 'json'
require 'thor'
require 'rusfdc/connection'
require 'rusfdc/partner'
require 'rusfdc/rest'
require 'rusfdc/describes/detail_layout'

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
      p = create_partner_client(options[:config])
      p.retrieve_custom_objects
       .each { |object| puts "name: #{object[:name].ljust(20)} label: #{object[:label]}" }
    end

    desc 'list_object_field', 'show specified custom object field list'
    method_option(*config_option)
    option :name, type: :string, aliases: '-n', desc: 'custom object name', required: true
    def list_object_field
      p = create_partner_client(options[:config])
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

      out_file = "result_of_create_nested_record_#{now_str}.json"
      out_pretty_json(res, out_file)

      puts "success! result is in #{out_file}"
    end

    desc 'generate_nested_record_template', 'generate template file for create_nested_record'
    method_option(*config_option)
    option :parent, type: :string, desc: 'parent custom object name', required: true
    option :child, type: :string, desc: 'child custom object name', required: true
    def generate_nested_record_template
      parent = options[:parent]
      child = options[:child]
      p, r = create_partner_and_rest_client(options[:config])

      param = create_nested_record_param(p, parent, child)
      template = r.generate_nested_record_template(param)
      out_file = "#{parent}_and_#{child}_#{now_str}.json"
      out_pretty_json(template, out_file)

      puts "success! result is in #{out_file}"
    end

    desc 'retrieve_layout_with_field_info', 'retrieve standard layout info to json file'
    method_option(*config_option)
    option :name, type: :string, aliases: '-n', desc: 'custom object name', required: true
    def retrieve_layout_with_field_info
      target = options[:name]
      p = create_partner_client(options[:config])
      l = Rusfdc::Describes::DetailLayout.new(p.retrieve_layouts_of(target))
      l_f = l.merge_fields_with_hash(p.retrieve_fields_of(target))

      out_file = "#{target}_layout_info.json"
      out_pretty_json(l_f, out_file)

      puts "success! result is in #{out_file}"
    end

    private

      def create_partner_client(config)
        c = Connection.new(config)
        c.create_partner_client
      end

      def create_rest_client(config)
        c = Connection.new(config)
        c.create_rest_client
      end

      def create_partner_and_rest_client(config)
        c = Connection.new(config)
        [c.create_partner_client, c.create_rest_client]
      end

      def create_nested_record_param(partner, parent, child)
        relationship = partner.get_relationship_name_between(parent, child)
        Rusfdc::NestedRecordParam.new(parent, child, relationship)
      end

      def out_pretty_json(json, filename)
        File.open("./#{filename}", 'w') do |f|
          f.write(JSON.pretty_generate(json))
        end
      end

      def now_str
        DateTime.now.strftime('%Y%m%d%H%M%S')
      end
  end
end
