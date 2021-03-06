class CreateActions < ActiveRecord::Migration[5.0]
  def up
    create_table(:actions) do |t|
      t.belongs_to :profile, index: true

      t.references :resource, polymorphic: true, index: true

      t.string :title, null: false

      t.string :type, null: false

      t.text :receivers_ids, array: true, null: false, default: []

      t.timestamps null: false

      t.datetime :deleted_at

      t.index :deleted_at
    end
  end

  def down
    drop_table :actions
  end
end
