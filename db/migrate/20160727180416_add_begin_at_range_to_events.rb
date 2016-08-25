class AddBeginAtRangeToEvents < ActiveRecord::Migration[5.0]
  def up
    add_column :events, :begin_at_range, :jsonb, null: false, default: '{}'
  end

  def down
    remove_column :events, :begin_at_range
  end
end
