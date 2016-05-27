class CreateInvitations < ActiveRecord::Migration[5.0]
  def up
    create_table(:invitations) do |t|
      t.belongs_to :event, index: true

      t.string :email, null: false

      t.text :message, null: false

      t.index [:event_id, :email], unique: true

      t.timestamps null: false
    end
  end

  def down
    drop_table :invitations
  end
end
