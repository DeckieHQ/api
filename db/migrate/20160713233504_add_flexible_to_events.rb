class AddFlexibleToEvents < ActiveRecord::Migration[5.0]
  def up
    add_column :events, :flexible, :boolean, null: false, default: false
  end

  def down
    remove_column :events, :flexible
  end
end
