class CreateProfiles < ActiveRecord::Migration[5.0]
  def up
    create_table(:profiles) do |t|
      t.string :nickname
      t.string :display_name
      t.string :avatar

      t.text :short_description
      t.text :description

      t.belongs_to :user, index: { unique: true }, foreign_key: true

      t.integer :hosted_events_count, null: false, default: 0

      t.timestamps null: false

      t.datetime :deleted_at

      t.index :deleted_at
    end
  end

  def down
    drop_table :profiles
  end
end
