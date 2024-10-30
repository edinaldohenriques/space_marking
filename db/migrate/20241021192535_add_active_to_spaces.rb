class AddActiveToSpaces < ActiveRecord::Migration[7.1]
  def change
    add_column :spaces, :active, :boolean, default: true
  end
end
