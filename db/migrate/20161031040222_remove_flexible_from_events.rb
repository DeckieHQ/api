class RemoveFlexibleFromEvents < ActiveRecord::Migration[5.0]
  def up
    remove_column :events, :flexible
  end

  def down
    add_column :events, :flexible, :boolean, null: false, default: false
  end
end
