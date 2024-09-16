class RemoveStartTimeAndEndTimeFromReservations < ActiveRecord::Migration[7.1]
  def change
    remove_column :reservations, :start_time, :time
    remove_column :reservations, :end_time, :time
  end
end
