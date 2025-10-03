class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :customer_name, null: false
      t.string :customer_phone, null: false
      t.string :laundry_type, null: false
      t.boolean :separate_whites, default: false
      t.integer :status, default: 0
      t.decimal :weight, precision: 8, scale: 2
      t.decimal :total_amount, precision: 10, scale: 2

      t.timestamps
    end

    add_index :orders, :status
    add_index :orders, :customer_phone
  end
end
