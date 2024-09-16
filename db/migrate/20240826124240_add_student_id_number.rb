class AddStudentIdNumber < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :student_id_number, :integer, null: true
    
    # Preenche os registros existentes com um valor aleatório
    User.update_all(student_id_number: 0)

    # Alterarndo a coluna para não permitir valores nulos
    change_column_null :users, :student_id_number, false
  end
end
