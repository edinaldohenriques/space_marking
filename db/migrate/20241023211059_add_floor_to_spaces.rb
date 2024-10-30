class AddFloorToSpaces < ActiveRecord::Migration[7.1]
  def change
    add_column :spaces, :floor, :integer, default: 0
  end
end
