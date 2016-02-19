class CreateSubscriptions < ActiveRecord::Migration[5.0]
  def up
    create_table(:subscriptions) do |t|
      t.belongs_to :event,   index: true
      t.belongs_to :profile, index: true

      t.integer :status, null: false

      t.timestamps null: false
    end
  end

  def down
    drop_table :subscriptions
  end
end
