require "test_helper"

class ShiftsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:one)
    @user = users(:two)
  end

  test "admin can delete shifts from previous month only" do
    sign_in @admin

    previous_month_shift = create_shift(created_at: 1.month.ago.beginning_of_month + 1.day)
    current_month_shift = create_shift(created_at: Time.current)
    older_shift = create_shift(created_at: 2.months.ago)

    assert_difference -> { Shift.count }, -1 do
      delete delete_previous_month_shifts_path
    end

    assert_not Shift.exists?(previous_month_shift.id)
    assert Shift.exists?(current_month_shift.id)
    assert Shift.exists?(older_shift.id)
    assert_redirected_to shifts_path
  end

  test "non admin cannot delete previous month shifts" do
    sign_in @user
    create_shift(created_at: 1.month.ago.beginning_of_month + 1.day)

    assert_no_difference -> { Shift.count } do
      delete delete_previous_month_shifts_path
    end

    assert_redirected_to shifts_path
  end

  private

  def create_shift(created_at:)
    Shift.create!(
      user: @admin,
      staff_name: "Tâm",
      start_time: created_at,
      end_time: created_at + 8.hours,
      start_cash: 0,
      created_at: created_at,
      updated_at: created_at
    )
  end
end
