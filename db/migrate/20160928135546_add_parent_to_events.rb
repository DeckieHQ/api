class AddParentToEvents < ActiveRecord::Migration[5.0]
  def up
    add_reference :events, :event, foreign_key: true
  end

  def down
    remove_reference :events, :event, foreign_key: true
  end
end
