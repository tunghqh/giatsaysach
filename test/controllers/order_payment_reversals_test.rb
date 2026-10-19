require "test_helper"

class OrderPaymentReversalsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @customer = customers(:one)
    @customer.update_columns(points: 500)
    @order = Order.create!(
      customer: @customer, customer_name: "Khách hàng",
      customer_phone: "0901234567", laundry_type: "clothes",
      status: :paid, payment_status: :payment_completed, payment_method: "cash",
      weight: 3, total_amount: 100_000, shipping_fee: 0, extra_fee: 0,
      redeemed_points: 200, paid_at: 1.hour.ago,
      completed_washing_at: 2.hours.ago
    )
  end

  test "admin reverses payment once and can collect payment again" do
    sign_in users(:one)
    completed_at = @order.completed_washing_at
    get order_path(@order)
    assert_select "form[action='#{reverse_payment_order_path(@order)}']"

    assert_difference -> { @customer.reload.points }, 200 do
      patch reverse_payment_order_path(@order)
    end
    assert_redirected_to order_path(@order)
    @order.reload
    assert @order.completed?
    assert @order.payment_pending?
    assert_nil @order.paid_at
    assert_nil @order.payment_method
    assert_equal 0, @order.redeemed_points
    assert_equal completed_at, @order.completed_washing_at

    assert_no_difference -> { @customer.reload.points } do
      patch reverse_payment_order_path(@order)
    end

    patch make_payment_order_path(@order), params: { payment_method: "transfer", redeemed_points: 100 }
    assert @order.reload.paid?
    assert @order.payment_completed?
    assert_not_nil @order.paid_at
    assert_equal 600, @customer.reload.points
  end

  test "staff cannot see or invoke reversal even with an open shift" do
    staff = users(:two)
    Shift.create!(user: staff, staff_name: "Nhân viên", start_time: Time.current, start_cash: 0)
    sign_in staff
    get order_path(@order)
    assert_response :success
    assert_select "form[action='#{reverse_payment_order_path(@order)}']", count: 0
    assert_no_difference -> { @customer.reload.points } do
      patch reverse_payment_order_path(@order)
    end
    assert_redirected_to orders_path
    assert @order.reload.paid?
  end

  test "anonymous request cannot reverse payment" do
    patch reverse_payment_order_path(@order)
    assert_redirected_to new_user_session_path
    assert @order.reload.paid?
  end

  test "reversal without redeemed points does not award completion points again" do
    @order.update!(redeemed_points: 0)
    sign_in users(:one)
    assert_no_difference -> { @customer.reload.points } do
      patch reverse_payment_order_path(@order)
    end
    assert @order.reload.completed?
  end

  test "invalid order rolls back refunded points" do
    @order.update_columns(laundry_type: "invalid")
    sign_in users(:one)
    assert_no_difference -> { @customer.reload.points } do
      patch reverse_payment_order_path(@order)
    end
    assert @order.reload.paid?
    assert_equal 200, @order.redeemed_points
    assert flash[:alert].present?
  end
end
