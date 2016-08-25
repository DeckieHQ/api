class CreateTimeSlotSubmissions < ActiveRecord::Migration[5.0]
  def up
    create_table(:time_slot_submissions) do |t|
      t.belongs_to :time_slot, index: true
      t.belongs_to :profile,   index: true

      t.timestamps null: false

      t.index [:time_slot_id, :profile_id], unique: true
    end
  end

  def down
    drop_table :time_slot_submissions
  end
end
