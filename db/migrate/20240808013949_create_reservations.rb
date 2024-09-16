class CreateReservations < ActiveRecord::Migration[7.1]
  def change
    create_table :reservations, id: :uuid do |t|
      t.date :reservation_date, null: false 
      t.time :start_time, null: false 
      t.time :end_time, null: false 
      t.integer :status, default: 0
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :space, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
