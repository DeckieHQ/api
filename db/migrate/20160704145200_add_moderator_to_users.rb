class AddModeratorToUsers < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :moderator, :boolean, null: false, default: false
  end

  def down
    remove_column :users, :moderator
  end
end
