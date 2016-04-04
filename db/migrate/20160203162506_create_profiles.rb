class CreateProfiles < ActiveRecord::Migration[5.0]
  def up
    create_table(:profiles) do |t|
      t.string :nickname
      t.string :display_name
      t.text   :short_description
      t.text   :description

      t.references :profiles, :user, index: { unique: true }, foreign_key: true

      t.timestamps null: false

      t.datetime :deleted_at

      t.index :deleted_at
    end
  end

  def down
    drop_table :profiles
  end
end
