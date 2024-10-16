class AddAccessibilityToSpaces < ActiveRecord::Migration[7.1]
  def change
    add_column :spaces, :accessibility, :boolean, default: false
  end
end
