require 'test_helper'

class AdminControllerTest < ActionDispatch::IntegrationTest
  test "should get all_users" do
    get admin_all_users_url
    assert_response :success
  end

  test "should get edit_users" do
    get admin_edit_users_url
    assert_response :success
  end

  test "should get show_users" do
    get admin_show_users_url
    assert_response :success
  end

end
