class AddOrganizationToUsers < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :organization, :boolean, null: false, default: false
  end

  def down
    remove_column :users, :organization
  end
end
