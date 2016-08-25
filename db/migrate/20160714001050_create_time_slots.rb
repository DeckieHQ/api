class CreateTimeSlots < ActiveRecord::Migration[5.0]
  def up
    create_table(:time_slots) do |t|
      t.belongs_to :event, index: true

      t.datetime :begin_at, null: false

      t.timestamps null: false

      t.index [:event_id, :begin_at], unique: true
    end
  end

  def down
    drop_table :time_slots
  end
end
