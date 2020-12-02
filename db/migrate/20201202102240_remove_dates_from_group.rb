class RemoveDatesFromGroup < ActiveRecord::Migration[6.0]
  def change
    remove_column :groups, :date_from
    remove_column :groups, :date_to
  end
end
