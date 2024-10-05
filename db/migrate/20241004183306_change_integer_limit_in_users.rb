class ChangeIntegerLimitInUsers < ActiveRecord::Migration[7.1]
  def change
    change_column :users, :student_id_number, :bigint
  end
end
