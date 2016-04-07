class CreateUsers < ActiveRecord::Migration[5.0]
  def up
    create_table(:users) do |t|
      ## Identity
      t.string :first_name, null: false
      t.string :last_name,  null: false
      t.date   :birthday,   null: false
      t.string :phone_number
      t.string :culture,    null: false

      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Token Authentication
      t.string :authentication_token, null: false

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      # Email Verifiable
      t.string   :email_verification_token
      t.datetime :email_verification_sent_at
      t.datetime :email_verified_at

      # SMS Verifiable
      t.integer  :phone_number_verification_token
      t.datetime :phone_number_verification_sent_at
      t.datetime :phone_number_verified_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip

      t.jsonb :preferences, null: false, default: '{}'

      t.timestamps null: false

      t.datetime :deleted_at

      t.integer :notifications_count, null: false, default: 0

      t.index :deleted_at

      t.index :email, unique: true, where: 'deleted_at IS NULL'

      t.index :reset_password_token,            unique: true, where: 'deleted_at IS NULL'
      t.index :email_verification_token,        unique: true, where: 'deleted_at IS NULL'
      t.index :phone_number_verification_token, unique: true, where: 'deleted_at IS NULL'
    end
  end

  def down
    drop_table :users
  end
end
