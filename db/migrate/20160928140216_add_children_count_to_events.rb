class AddChildrenCountToEvents < ActiveRecord::Migration[5.0]
  def up
    add_column :events, :children_count, :integer, null: false, default: 0
  end

  def down
    remove_column :events, :children_count
  end
end
