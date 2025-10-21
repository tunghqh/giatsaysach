class AddStaffNameToShifts < ActiveRecord::Migration[7.0]
  def change
    add_column :shifts, :staff_name, :string
    add_index :shifts, :staff_name
  end
end
