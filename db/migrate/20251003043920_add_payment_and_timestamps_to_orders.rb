class AddPaymentAndTimestampsToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :payment_method, :string
    add_column :orders, :payment_status, :integer, default: 0
    add_column :orders, :received_at, :datetime
    add_column :orders, :started_washing_at, :datetime
    add_column :orders, :completed_washing_at, :datetime
    add_column :orders, :paid_at, :datetime

    add_index :orders, :payment_status
  end
end
