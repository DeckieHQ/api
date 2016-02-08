class CreateEventsAndSubscriptions < ActiveRecord::Migration[5.0]
  def up
    create_table(:events) do |t|
      t.string :title

      t.timestamps null: false

      t.belongs_to :profile, index: true
    end

    create_table(:subscriptions) do |t|
      t.belongs_to :event,   index: true
      t.belongs_to :profile, index: true

      t.timestamps null: false
    end
  end

  def down
    drop_table :subscriptions
    drop_table :events
  end
end
