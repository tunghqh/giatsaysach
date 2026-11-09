class StatisticsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin_permission
  before_action :set_date_range, only: [:index, :export_orders]

  def index
    orders = Order.where(created_at: @from_date.beginning_of_day..@to_date.end_of_day)
    paid_orders = Order.where(payment_status: :payment_completed).paid_between_dates(@from_date.beginning_of_day, @to_date.end_of_day)

    @total_orders = orders.count
    @paid_orders = paid_orders.count
    @cash_total = paid_orders.where(payment_method: 'cash').sum { |o| o.final_total_amount }
    @transfer_total = paid_orders.where(payment_method: 'transfer').sum { |o| o.final_total_amount }
    @total_paid = paid_orders.sum { |o| o.final_total_amount }
    @total_redeemed_points = paid_orders.sum(&:redeemed_points)
  end

  def export_orders
    paid_orders = Order.includes(:customer)
                       .where(payment_status: :payment_completed)
                       .paid_between_dates(@from_date.beginning_of_day, @to_date.end_of_day)
                       .order(paid_at: :desc)

    filename = "don_hang_#{@from_date.strftime('%Y%m%d')}_#{@to_date.strftime('%Y%m%d')}.csv"
    send_data Order.to_csv(paid_orders),
              filename: filename,
              type: 'text/csv; charset=utf-8',
              disposition: 'attachment'
  end

  private

  def set_date_range
    @from_date = parse_date(params[:from_date], Date.today.beginning_of_month)
    @to_date = parse_date(params[:to_date], Date.today)
    @from_date, @to_date = @to_date, @from_date if @from_date > @to_date
  end

  def parse_date(value, fallback)
    return fallback if value.blank?

    Date.parse(value)
  rescue ArgumentError
    fallback
  end

  def check_admin_permission
    unless current_user.admin?
      redirect_to root_path, alert: 'Bạn không có quyền truy cập trang này.'
    end
  end
end
