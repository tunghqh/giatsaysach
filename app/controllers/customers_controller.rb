
class CustomersController < ApplicationController
  include Pagy::Backend
  before_action :authenticate_user!, except: [:intro]
  before_action :set_customer, only: [:show, :edit, :update]

  def index
    customers = Customer.left_joins(:orders)
      .select('customers.*, COUNT(orders.id) AS orders_count, MAX(orders.created_at) AS latest_order_created_at')
      .group('customers.id')
      .order(:name)
    customers = customers.search_by_phone(params[:search]) if params[:search].present?
    @pagy, @customers = pagy(customers)
  end

  def show
    @orders = @customer.orders.recent
  end

  def edit
  end

  def update
    if @customer.update(customer_params)
      # Đồng bộ thông tin sang các đơn hàng liên quan
      @customer.orders.update_all(customer_name: @customer.name, customer_phone: @customer.phone)
      redirect_to @customer, notice: 'Thông tin khách hàng đã được cập nhật.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Trang giới thiệu sản phẩm/dịch vụ cho khách hàng
  def intro
    # Có thể truyền dữ liệu sản phẩm/dịch vụ ở đây nếu cần
  end

  private

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(:name, :phone)
  end
end
