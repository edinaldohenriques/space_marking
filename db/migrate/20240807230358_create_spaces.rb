class CreateSpaces < ActiveRecord::Migration[7.1]
  def change
    create_table :spaces, id: :uuid do |t|
      t.string :name, null: false
      t.text :description, null: false 
      t.string :location, null: false 
      t.integer :capacity, null: false 
      t.integer :available 

      t.timestamps
    end
  end
end
