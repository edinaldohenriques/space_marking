class AddOccupiedToSpaces < ActiveRecord::Migration[7.1]
  def change
    add_column :spaces, :occupied, :boolean, default: false
  end
end
