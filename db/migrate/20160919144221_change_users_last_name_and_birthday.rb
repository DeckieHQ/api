class ChangeUsersLastNameAndBirthday < ActiveRecord::Migration[5.0]
  def up
    change_column :users, :last_name, :string, null: true
    change_column :users, :birthday,  :date,   null: true
  end

  def down
    change_column :users, :last_name, :string, null: false
    change_column :users, :birthday,  :date,   null: false
  end
end
