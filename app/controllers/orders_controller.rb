class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :edit, :update, :destroy, :start_washing, :complete_washing, :make_payment, :print_invoice]
  before_action :check_admin_permission, only: [:edit, :update, :destroy]

  def index
    @orders = Order.includes(:customer).recent

    # Filter by status
    @orders = @orders.by_status(params[:status]) if params[:status].present?

    # Search by phone or customer name
    @orders = @orders.search_by_customer(params[:search].strip) if params[:search].present?


    # Filter by date type (created_at or paid_at)
    if params[:date].present?
      begin
        date = Date.parse(params[:date])
        if params[:date_type] == 'paid_at'
          @orders = @orders.paid_on_date(date)
        else
          @orders = @orders.created_on_date(date)
        end
      rescue ArgumentError
        # Invalid date format, ignore filter
      end
    end

    # Store search params for view
    @search_params = {
      search: params[:search],
      status: params[:status],
      date: params[:date],
      date_type: params[:date_type]
    }
  end

  def new
    @order = Order.new
    @customer = Customer.find_by(phone: params[:phone]) if params[:phone].present?

    if @customer
      @order.customer = @customer
      @order.customer_name = @customer.name
      @order.customer_phone = @customer.phone
    else
      @order.customer_phone = params[:phone]
    end
  end

  def create
    @order = Order.new(order_params)

    # Tìm hoặc tạo customer
    @customer = Customer.find_or_create_by(phone: @order.customer_phone) do |customer|
      customer.name = @order.customer_name
    end

    # Cập nhật tên nếu khác với tên hiện tại (trường hợp customer đã tồn tại)
    if @customer.persisted? && @customer.name != @order.customer_name && @order.customer_name.present?
      @customer.update(name: @order.customer_name)
    end

    @order.customer = @customer

    if @order.save
      redirect_to @order, notice: 'Đơn hàng đã được tạo thành công.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @order.update(order_params)
      redirect_to @order, notice: 'Đơn hàng đã được cập nhật.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @order.destroy
    redirect_to orders_path, notice: 'Đơn hàng đã được xóa.'
  end

  def start_washing
    if @order.received?
      @order.update(status: :washing)
      redirect_to @order, notice: 'Đã chuyển sang trạng thái đang giặt.'
    else
      redirect_to @order, alert: 'Không thể chuyển trạng thái.'
    end
  end

  def complete_washing
    if @order.washing?
      if params[:weight].present? && params[:total_amount].present?
        @order.update(
          status: :completed,
          weight: params[:weight],
          total_amount: params[:total_amount],
          shipping_fee: params[:shipping_fee].present? ? params[:shipping_fee] : 0,
          extra_fee: params[:extra_fee].present? ? params[:extra_fee] : 0
        )
        redirect_to @order, notice: 'Đã hoàn thành giặt.'
      else
        redirect_to @order, alert: 'Vui lòng nhập cân nặng và tổng tiền.'
      end
    else
      redirect_to @order, alert: 'Không thể hoàn thành.'
    end
  end

  def make_payment
    if @order.completed?
      if params[:payment_method].present?
        @order.update(
          status: :paid,
          payment_status: :payment_completed,
          payment_method: params[:payment_method]
        )
        redirect_to @order, notice: 'Đã thanh toán thành công.'
      else
        redirect_to @order, alert: 'Vui lòng chọn phương thức thanh toán.'
      end
    else
      redirect_to @order, alert: 'Không thể thanh toán.'
    end
  end

  def phone_search
  end

  def search_customer
    if params[:phone].present?
      @customer = Customer.find_by(phone: params[:phone])
      render json: {
        found: @customer.present?,
        customer: @customer ? { name: @customer.name, phone: @customer.phone } : nil
      }
    else
      render json: { found: false, customer: nil }
    end
  end

  def print_invoice
    unless @order.completed? || @order.paid?
      redirect_to @order, alert: 'Chỉ có thể in hóa đơn cho đơn hàng đã hoàn thành.'
      return
    end

    respond_to do |format|
      format.html { render layout: 'print' }
      format.pdf do
        # For future PDF generation if needed
        render html: render_to_string(layout: 'print')
      end
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def check_admin_permission
    unless current_user.admin?
      redirect_to orders_path, alert: 'Bạn không có quyền thực hiện hành động này. Chỉ quản lý mới có thể chỉnh sửa/xóa đơn hàng.'
    end
  end

  def order_params
    params.require(:order).permit(:customer_name, :customer_phone, :laundry_type, :separate_whites, :weight, :total_amount, :shipping_fee, :extra_fee)
  end
end
