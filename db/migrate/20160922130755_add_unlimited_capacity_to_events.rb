class AddUnlimitedCapacityToEvents < ActiveRecord::Migration[5.0]
  def up
    add_column :events, :unlimited_capacity, :boolean, null: false, default: false
  end

  def down
    remove_column :events, :unlimited_capacity
  end
end
