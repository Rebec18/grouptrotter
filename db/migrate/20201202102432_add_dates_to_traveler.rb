class AddDatesToTraveler < ActiveRecord::Migration[6.0]
  def change
    add_column :travelers, :date_from, :datetime
    add_column :travelers, :date_to, :datetime
  end
end
