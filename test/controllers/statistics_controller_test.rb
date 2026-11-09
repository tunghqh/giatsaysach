require "test_helper"

class StatisticsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @customer = customers(:one)
    @in_range_order = Order.create!(
      customer: @customer,
      customer_name: "Khách Trong Khoảng",
      customer_phone: "0901111222",
      laundry_type: "clothes",
      status: :paid,
      payment_status: :payment_completed,
      payment_method: "cash",
      weight: 3.5,
      total_amount: 50_000,
      shipping_fee: 10_000,
      extra_fee: 5_000,
      redeemed_points: 5_000,
      paid_at: Time.zone.local(2026, 5, 10, 14, 30)
    )

    @out_of_range_order = Order.create!(
      customer: @customer,
      customer_name: "Khách Ngoài Khoảng",
      customer_phone: "0903333444",
      laundry_type: "blanket",
      status: :paid,
      payment_status: :payment_completed,
      payment_method: "transfer",
      weight: 2.0,
      total_amount: 40_000,
      shipping_fee: 0,
      extra_fee: 0,
      redeemed_points: 0,
      paid_at: Time.zone.local(2026, 4, 15, 10, 0)
    )
  end

  test "admin can download orders CSV filtered by paid_at range" do
    sign_in users(:one)

    get export_orders_statistics_path, params: { from_date: "2026-05-01", to_date: "2026-05-31" }

    assert_response :success
    assert_includes response.media_type, "text/csv"
    assert_includes response.headers["Content-Disposition"], "don_hang_20260501_20260531.csv"
    assert_includes response.body, "Khách Trong Khoảng"
    assert_not_includes response.body, "Khách Ngoài Khoảng"
  end

  test "non-admin staff cannot download orders CSV" do
    staff = users(:two)
    Shift.create!(user: staff, staff_name: "Nhân viên", start_time: Time.current, start_cash: 0)
    sign_in staff

    get export_orders_statistics_path, params: { from_date: "2026-05-01", to_date: "2026-05-31" }

    assert_redirected_to root_path
  end

  test "anonymous user cannot download orders CSV" do
    get export_orders_statistics_path

    assert_redirected_to new_user_session_path
  end
end
