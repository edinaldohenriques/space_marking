class DropShifts < ActiveRecord::Migration[7.1]
  def change
    drop_table :shifts
  end
end
