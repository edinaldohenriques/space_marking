class AddDescriptionToReservations < ActiveRecord::Migration[7.1]
  def change
    add_column :reservations, :description, :text
  end
end
