class CreateNotifications < ActiveRecord::Migration[5.0]
  def up
    create_table :notifications do |t|
      t.belongs_to :user,   index: true
      t.belongs_to :action, index: true

      t.index [:user_id, :action_id], unique: true

      t.string :type, null: false

      t.boolean :viewed, null: false, default: false

      t.timestamps null: false
    end
  end

  def down
    drop_table :notifications
  end
end
