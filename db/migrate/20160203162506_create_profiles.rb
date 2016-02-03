class CreateProfiles < ActiveRecord::Migration[5.0]
  def up
    create_table(:profiles) do |t|
      t.string :nickname

      t.timestamps null: false
    end

    add_reference :profiles, :user, index: { unique: true }, foreign_key: true
  end

  def down
    remove_reference :profiles, :user, index: { unique: true }, foreign_key: true

    drop_table :profiles
  end
end
