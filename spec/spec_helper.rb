require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rusfdc'
require 'timecop'
require 'webmock/rspec'
require 'savon/mock/spec_helper'

module Helpers
  def build_login_response(session_id, server_url, metadata_server_url)
    {
      login_response: {
        result: {
          session_id: session_id,
          server_url: server_url,
          metadata_server_url: metadata_server_url
        }
      }
    }
  end

  def build_global_describe_response(objects)
    {
      describe_global_response: {
        result: {
          sobjects: objects
        }
      }
    }
  end

  def build_describe_s_object_response(fields)
    {
      describe_s_object_response: {
        result: {
          fields: fields
        }
      }
    }
  end
end

RSpec.configure do |c|
  c.mock_with :rspec do |m|
    m.verify_partial_doubles = true
  end

  c.include Helpers
end
