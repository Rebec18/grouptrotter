class CreateTravellers < ActiveRecord::Migration[6.0]
  def change
    create_table :travellers do |t|
      t.string :name
      t.string :fly_from
      t.integer :price_from
      t.integer :price_to
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
