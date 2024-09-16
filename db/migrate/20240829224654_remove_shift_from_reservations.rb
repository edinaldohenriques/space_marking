class RemoveShiftFromReservations < ActiveRecord::Migration[7.1]
  def change
    remove_column :reservations, :shift, :integer
  end
end
