class StatisticsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin_permission

  def index
  @from_date = params[:from_date].present? ? Date.parse(params[:from_date]) : Date.today.beginning_of_month
  @to_date = params[:to_date].present? ? Date.parse(params[:to_date]) : Date.today

  orders = Order.where(created_at: @from_date.beginning_of_day..@to_date.end_of_day)
  paid_orders = Order.where(payment_status: :payment_completed).paid_between_dates(@from_date.beginning_of_day, @to_date.end_of_day)

  @total_orders = orders.count
  @paid_orders = paid_orders.count
  @cash_total = paid_orders.where(payment_method: 'cash').sum { |o| o.final_total_amount }
  @transfer_total = paid_orders.where(payment_method: 'transfer').sum { |o| o.final_total_amount }
  @total_paid = paid_orders.sum { |o| o.final_total_amount }
  @total_redeemed_points = paid_orders.sum(&:redeemed_points)
  end

  private

  def check_admin_permission
    unless current_user.admin?
      redirect_to root_path, alert: 'Bạn không có quyền truy cập trang này.'
    end
  end
end
