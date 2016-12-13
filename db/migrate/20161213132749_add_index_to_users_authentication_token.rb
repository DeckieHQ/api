class AddIndexToUsersAuthenticationToken < ActiveRecord::Migration[5.0]
  def up
    add_index :users, :authentication_token, unique: true
  end

  def down
    remove_index :users, :authentication_token
  end
end
