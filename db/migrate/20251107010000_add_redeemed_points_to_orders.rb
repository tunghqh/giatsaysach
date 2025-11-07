class AddRedeemedPointsToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :redeemed_points, :integer, default: 0, null: false
  end
end
