class ChangeAvaliableToBooleanInSpace < ActiveRecord::Migration[7.1]
  def up
    change_column :spaces, :avaliable, 'boolean USING CAST(avaliable AS boolean)'
  end

  def down
    change_column :spaces, :avaliable, :integer
  end
end
