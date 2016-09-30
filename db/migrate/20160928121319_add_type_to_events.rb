class AddTypeToEvents < ActiveRecord::Migration[5.0]
  def up
    add_column :events, :type, :integer, null: false, default: 0

    Event.where(flexible: true).each { |e| e.flexible! }

    change_column :events, :type, :integer, null: false

    remove_column :events, :flexible
  end

  def down
    add_column :events, :flexible, :boolean, null: false, default: false

    Event.flexible.each { |e| e.update(flexible: true) }

    remove_column :events, :type
  end
end
