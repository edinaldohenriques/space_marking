class AddBoardAndLaboratoryAndProjectorToSpaces < ActiveRecord::Migration[7.1]
  def change
    add_column :spaces, :board, :boolean, default: false
    add_column :spaces, :laboratory, :boolean, default: false
    add_column :spaces, :projector, :boolean, default: false
  end
end
