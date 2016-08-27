class AddCommentsCountToComments < ActiveRecord::Migration[5.0]
  def up
    add_column :comments, :comments_count, :integer, null: false, default: 0
  end

  def down
    remove_column :comments, :comments_count
  end
end
