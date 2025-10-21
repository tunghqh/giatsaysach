class CreateShifts < ActiveRecord::Migration[7.0]
  def change
    create_table :shifts do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :start_time, null: false
      t.datetime :end_time
      t.integer :start_cash, null: false, default: 0
      t.integer :end_cash
      t.integer :total_paid, null: false, default: 0

      t.timestamps
    end
  end
end
