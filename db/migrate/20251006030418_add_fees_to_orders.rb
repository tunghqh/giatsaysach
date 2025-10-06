class AddFeesToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :shipping_fee, :decimal, precision: 10, scale: 2, default: 0
    add_column :orders, :extra_fee, :decimal, precision: 10, scale: 2, default: 0
  end
end
