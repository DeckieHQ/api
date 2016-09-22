class ChangeEventsCapacity < ActiveRecord::Migration[5.0]
  def up
    change_column :events, :capacity, :integer, null: true, default: nil
  end

  def down
    change_column :events, :capacity, :integer, null: false
  end
end
