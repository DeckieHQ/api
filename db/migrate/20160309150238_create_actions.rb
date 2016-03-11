class CreateActions < ActiveRecord::Migration[5.0]
  def up
    create_table(:actions) do |t|
      t.belongs_to :profile, index: true

      t.references :target, polymorphic: true, index: true

      t.string :title, null: false

      t.string :type, null: false

      t.timestamps null: false
    end
  end

  def down
    drop_table :actions
  end
end