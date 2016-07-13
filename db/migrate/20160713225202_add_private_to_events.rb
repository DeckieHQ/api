class AddPrivateToEvents < ActiveRecord::Migration[5.0]
  def up
    add_column :events, :private, :boolean, null: false, default: false
  end

  def down
    remove_column :events, :private
  end
end
