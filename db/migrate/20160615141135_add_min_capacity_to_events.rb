class AddMinCapacityToEvents < ActiveRecord::Migration[5.0]
  def up
    add_column :events, :min_capacity, :integer, null: false, default: 0
  end

  def down
    remove_column :events, :min_capacity
  end
end
