class ChangeEventsBeginAt < ActiveRecord::Migration[5.0]
  def up
    change_column :events, :begin_at, :datetime, null: true
  end

  def down
    change_column :events, :begin_at, :datetime, null: false
  end
end
