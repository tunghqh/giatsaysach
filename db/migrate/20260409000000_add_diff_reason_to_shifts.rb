class AddDiffReasonToShifts < ActiveRecord::Migration[7.1]
  def change
    add_column :shifts, :diff_reason, :text
  end
end
