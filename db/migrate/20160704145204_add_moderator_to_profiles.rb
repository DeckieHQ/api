class AddModeratorToProfiles < ActiveRecord::Migration[5.0]
  def up
    add_column :profiles, :moderator, :boolean, null: false, default: false
  end

  def down
    remove_column :profiles
  end
end
