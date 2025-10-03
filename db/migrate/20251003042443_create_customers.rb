class CreateCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :customers do |t|
      t.string :name, null: false
      t.string :phone, null: false

      t.timestamps
    end

    add_index :customers, :phone, unique: true
  end
end
