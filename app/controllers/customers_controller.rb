
class CustomersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_customer, only: [:show, :edit, :update]

  def index
    @customers = Customer.includes(:orders).order(:name)
    @customers = @customers.search_by_phone(params[:search]) if params[:search].present?
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

  private

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(:name, :phone)
  end
end
