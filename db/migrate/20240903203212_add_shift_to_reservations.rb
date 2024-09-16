class AddShiftToReservations < ActiveRecord::Migration[7.1]
  def change
    add_column :reservations, :shifts, :string, array: true, default: []
  end
end
