require 'savon/mock/spec_helper'

module SavonHelper
  def expect_login
    message = { username: 'user1@test.com', password: '' }
    fixture = File.read('spec/fixtures/login_response.xml')
    savon.expects(:login).with(message: message).returns(fixture)
  end

  def expect_describe_global
    fixture = File.read('spec/fixtures/describe_global_response.xml')
    savon.expects(:describe_global).returns(fixture)
  end

  def expect_describe_s_object_with(target)
    message = { s_object_type: target }
    fixture = File.read('spec/fixtures/describe_s_object_response.xml')
    savon.expects(:describe_s_object).with(message: message).returns(fixture)
  end

  def expect_describe_layout_of(target)
    message = { s_object_type: target }
    fixture = File.read('spec/fixtures/describe_layout_response.xml')
    savon.expects(:describe_layout).with(message: message).returns(fixture)
  end
end
