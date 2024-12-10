class AddJustificationToReservations < ActiveRecord::Migration[7.1]
  def change
    add_column :reservations, :justification, :text
  end
end
