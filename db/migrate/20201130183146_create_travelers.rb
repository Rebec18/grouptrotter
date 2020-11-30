class CreateTravelers < ActiveRecord::Migration[6.0]
  def change
    create_table :travelers do |t|
      t.string :name
      t.string :fly_from
      t.integer :price_from, default: 0
      t.integer :price_to
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
