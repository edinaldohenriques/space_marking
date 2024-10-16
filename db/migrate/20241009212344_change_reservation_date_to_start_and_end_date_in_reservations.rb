class ChangeReservationDateToStartAndEndDateInReservations < ActiveRecord::Migration[7.1]
  def change
    add_column :reservations, :start_date, :date, null: false
    add_column :reservations, :end_date, :date, null: false
    remove_column :reservations, :reservation_date, :date
  end
end
