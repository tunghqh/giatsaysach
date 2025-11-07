class AddPointsToCustomers < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :points, :integer, default: 0, null: false
  end
end
