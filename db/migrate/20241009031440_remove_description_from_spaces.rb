class RemoveDescriptionFromSpaces < ActiveRecord::Migration[7.1]
  def change
    remove_column :spaces, :description, :text
  end
end
