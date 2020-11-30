class CreateGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :groups do |t|
      t.datetime :date_from
      t.datetime :date_to
      t.string :fly_to

      t.timestamps
    end
  end
end
