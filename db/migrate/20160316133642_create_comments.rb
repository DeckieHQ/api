class CreateComments < ActiveRecord::Migration
  def up
    create_table(:comments) do |t|
      t.belongs_to :profile, index: true
      t.references :resource, polymorphic: true, index: true

      t.string :message, null: false
      t.boolean :private, null: false, default: false

      t.timestamps null: false
    end
  end

  def down
    drop_table :comments
  end
end
