class AddTypeToEvents < ActiveRecord::Migration[5.0]
  def up
    add_column :events, :type, :integer, null: false, default: 0


  end

  def down
    remove_column :events, :type
  end
end
