class RemoveFlexibleFromEvents < ActiveRecord::Migration[5.0]
  def up
    Event.where(flexible: true).each { |e| e.flexible! }

    change_column :events, :type, :integer, null: false

    remove_column :events, :flexible
  end

  def down
    add_column :events, :flexible, :boolean, null: false, default: false

    Event.flexible.each { |e| e.update(flexible: true) }
  end
end
