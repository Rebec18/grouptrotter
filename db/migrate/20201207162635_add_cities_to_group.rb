class AddCitiesToGroup < ActiveRecord::Migration[6.0]
  def change
    add_column :groups, :cities, :string, array: true
  end
end
