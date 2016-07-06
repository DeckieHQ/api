class ChangeInvitationsMessage < ActiveRecord::Migration[5.0]
  def up
    change_column :invitations, :message, :text, null: true
  end

  def down
    change_column :invitations, :message, :text, null: false
  end
end
