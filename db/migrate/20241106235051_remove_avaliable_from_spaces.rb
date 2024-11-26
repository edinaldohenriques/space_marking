class RemoveAvaliableFromSpaces < ActiveRecord::Migration[7.1]
  def change
    remove_column :spaces, :avaliable, :boolean
  end
end
