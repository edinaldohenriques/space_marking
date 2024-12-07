class AddDisabledReasonToSpaces < ActiveRecord::Migration[7.1]
  def change
    add_column :spaces, :disabled_reason, :text
  end
end
