class AddMembersCountToTimeSlots < ActiveRecord::Migration[5.0]
  def up
    add_column :time_slots, :members_count, :integer, null: false, default: 0
  end

  def down
    remove_column :time_slots, :members_count
  end
end
