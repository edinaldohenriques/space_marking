class RenameAvailableToSpace < ActiveRecord::Migration[7.1]
  def change
    rename_column :spaces, :available, :avaliable
  end
end
