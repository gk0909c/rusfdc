require 'rusfdc/version'
require 'rusfdc/client'

# salesforce operation via ruby
module Rusfdc
  WSDL_DIR = "#{File.dirname(__FILE__)}/../wsdl".freeze
  PARTNER_WSDL = "#{WSDL_DIR}/partner.wsdl".freeze

  NestedRecordParam = Struct.new(:parent_name, :child_name, :relation_name)
end
