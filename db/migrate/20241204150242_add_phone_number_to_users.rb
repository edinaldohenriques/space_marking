class AddPhoneNumberToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :phone_number, :string, null: true 

    User.update_all(phone_number: 0)

    # Alterarndo a coluna para não permitir valores nulos
    change_column_null :users, :phone_number, false
  end
end
