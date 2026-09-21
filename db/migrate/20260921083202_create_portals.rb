class CreatePortals < ActiveRecord::Migration[8.1]
  def change
    create_table :portals do |t|
      t.string :name, null: false
      t.string :dimension, null: false
      t.datetime :departure_time, null: false
      t.integer :capacity, null: false

      t.timestamps
    end
  end
end
