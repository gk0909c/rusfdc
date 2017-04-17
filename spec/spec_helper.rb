require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rusfdc'

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
end

RSpec.configure do |c|
  c.include Helpers
end
