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
end

RSpec.configure do |c|
  c.include Helpers
end
