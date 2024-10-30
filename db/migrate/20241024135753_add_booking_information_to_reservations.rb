class AddBookingInformationToReservations < ActiveRecord::Migration[7.1]
  def up
    # Adiciona a coluna como null: true
    add_column :reservations, :booking_information, :text, null: true

    # Atualiza todos os registros existentes
    Reservation.update_all(booking_information: 'informação pendente')

    # Altera a coluna para null: false
    change_column_null :reservations, :booking_information, false
  end

  def down
    # Remove a coluna se a migração for revertida
    remove_column :reservations, :booking_information
  end
end
