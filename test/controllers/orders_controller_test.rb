require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get orders_index_url
    assert_response :success
  end

  test "should get new" do
    get orders_new_url
    assert_response :success
  end

  test "should get create" do
    get orders_create_url
    assert_response :success
  end

  test "should get show" do
    get orders_show_url
    assert_response :success
  end

  test "should get edit" do
    get orders_edit_url
    assert_response :success
  end

  test "should get update" do
    get orders_update_url
    assert_response :success
  end

  test "should get destroy" do
    get orders_destroy_url
    assert_response :success
  end

  test "should get start_washing" do
    get orders_start_washing_url
    assert_response :success
  end

  test "should get complete_washing" do
    get orders_complete_washing_url
    assert_response :success
  end

  test "should get search_customer" do
    get orders_search_customer_url
    assert_response :success
  end
end
