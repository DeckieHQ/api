class AddOrganizationToProfiles < ActiveRecord::Migration[5.0]
  def up
    add_column :profiles, :organization, :boolean, null: false, default: false
  end

  def down
    remove_column :profiles, :organization
  end
end
