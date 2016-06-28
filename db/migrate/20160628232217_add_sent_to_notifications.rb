class AddSentToNotifications < ActiveRecord::Migration[5.0]
  def up
    add_column :notifications, :sent, :boolean, null: false, default: false
  end

  def down
    remove_column :notifications, :sent
  end
end
