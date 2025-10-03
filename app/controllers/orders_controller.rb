class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :edit, :update, :destroy, :start_washing, :complete_washing, :make_payment]

  def index
    @orders = Order.includes(:customer).recent
    @orders = @orders.by_status(params[:status]) if params[:status].present?
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
          total_amount: params[:total_amount]
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

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:customer_name, :customer_phone, :laundry_type, :separate_whites, :weight, :total_amount)
  end
end
