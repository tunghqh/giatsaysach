class CustomersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_customer, only: [:show]

  def index
    @customers = Customer.includes(:orders).order(:name)
    @customers = @customers.search_by_phone(params[:search]) if params[:search].present?
  end

  def show
    @orders = @customer.orders.recent
  end

  private

  def set_customer
    @customer = Customer.find(params[:id])
  end
end
